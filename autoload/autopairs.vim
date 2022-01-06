" Insert or delete brackets, parens, quotes in pairs.
" Fork Maintainer: Olivia
" Version: See g:AutoPairsVersion, or the git tag
" Fork Repository: https://github.com/LunarWatcher/auto-pairs
" License: MIT

scriptencoding utf-8

if !has('nvim') && has('vimscript-4')
    " We'll enforce the new version for versions of Vim that support the
    " fantastic |scriptversion|. The rest are gonna have to sort themselves
    " out.
    " This also lets me make sure I write better Vimscript
    scriptversion 4
endif

" Current version; not representative of tags or real versions, but purely
" meant as a number associated with the version. Semantic meaning on the first
" digit will take place. See the documentation for more details.
let g:AutoPairsVersion = 30061

let s:save_cpo = &cpoptions
set cpoptions&vim

call autopairs#Variables#_InitVariables()

fun! autopairs#AutoPairsAddLanguagePair(pair, language)
    if !has_key(a:pair, "open") || !has_key(a:pair, "close")
        echoerr "Invalid pair: missing open and/or close"
        return
    endif

    let open = get(a:pair, 'open')
    let close = get(a:pair, 'close')

    if (!has_key(g:AutoPairsLanguagePairs, a:language))
        let g:AutoPairsLanguagePairs[a:language] = {}
    endif
    " As usual, make simple open:close pairs just that, and ditch objects.
    if (len(a:pair) == 2)
        let g:AutoPairsLanguagePairs[a:language][open] = close
    else
        " Make sure we don't have redundant information
        unlet a:pair["open"]
        let g:AutoPairsLanguagePairs[a:language][open] = a:pair
    endif
endfun

fun! autopairs#AutoPairsAddPairs(pairs, ...)
    let PairsObject = get(a:, '1', g:AutoPairs)
    for pair in a:pairs
        call autopairs#AutoPairsAddPair(pair, PairsObject)
    endfor
endfun

" @param pair       A object containing a pair and other metadata
fun! autopairs#AutoPairsAddPair(pair, ...)
    if !has_key(a:pair, "open") || !has_key(a:pair, "close")
        echoerr "Invalid pair: missing open and/or close"
        return
    endif
    let PairsObject = get(a:, '1', g:AutoPairs)

    let open = get(a:pair, 'open')
    let close = get(a:pair, 'close')

    " Prevent empty open
    " Empty close is fine, but empty open isn't.
    if (open == "")
        echoerr "Open cannot be empty. Discarding invalid pair"
        return
    endif
    " We know close is defined (and well-defined)
    " Meta-optimization; pairs consisting of close and open
    " are plain and not objects
    if len(a:pair) == 2 && has_key(a:pair, "close")
        let PairsObject[open] = close
    else
        " Now, that was clearly not a basic pair, which means it may have a
        " language attribute.
        " Let's check:

        if has_key(a:pair, "filetype")

            let filetypes = a:pair["filetype"]
            unlet a:pair["filetype"]
            if type(filetypes) == v:t_string

                call autopairs#AutoPairsAddLanguagePair(a:pair, filetypes)
                return
            elseif type(filetypes) == v:t_list
                for ft in filetypes
                    call autopairs#AutoPairsAddLanguagePair(a:pair, ft)
                endfor
                return
            else
                echoerr "Invalid filetype: " .. filetypes .. " - must be string or list. Discarding pair"
                return
            endif
        endif
        " Prevent information duplication
        unlet a:pair["open"]
        " Otherwise, we inject the entire pair
        let PairsObject[open] = a:pair
    endif
endfun

" default pairs base on filetype
func! autopairs#AutoPairsDefaultPairs(...)
    let r = copy(g:AutoPairs)
    if has_key(g:AutoPairsLanguagePairs, &ft)
        for [open, close] in items(g:AutoPairsLanguagePairs[&ft])
            let r[open] = close
        endfor
    endif

    return r
endf

" add or delete pairs base on g:AutoPairs
" AutoPairsDefine(addPairs:dict[, removeOpenPairList:list])
"
" eg:
"   au FileType html let b:AutoPairs = autopairs#AutoPairsDefine({'<!--' : '-->'}, ['{'])
"   add <!-- --> pair and remove '{' for html file
func! autopairs#AutoPairsDefine(pairs, ...)
    let r = autopairs#AutoPairsDefaultPairs()
    if a:0 > 0
        for open in a:1
            if has_key(r, open)
                unlet r[open]
            endif
        endfor
    end
    " Dict: iterate as normal
    if type(a:pairs) == v:t_dict
        for [open, close] in items(a:pairs)
            let r[open] = close
        endfor
    else
        call autopairs#AutoPairsAddPairs(a:pairs, r)
    endif
    return r
endf

func! autopairs#AutoPairsInsert(key, ...)
    if !b:autopairs_enabled || b:AutoPairsIgnoreSingle
        let b:AutoPairsIgnoreSingle = 0
        return a:key
    end
    let balanced = -3

    let l:multiline = get(a:, '1', b:AutoPairsMultilineClose)

    let b:autopairs_saved_pair = [a:key, getpos('.')]

    let [before, after, afterline] = autopairs#Strings#getline(l:multiline)
    " Check open pairs {{{
    " TODO: maybe move this to another file?
    for [open, close, opt] in b:AutoPairsList
        let ms = autopairs#Strings#matchend(before .. a:key, open)
        let m = matchstr(afterline, '^\v\s*\zs\V' .. escape(close, '\'))

        if len(ms) > 0
            let target = ms[1]
            " Contains the real pair, as opposed to the potential regex `open`
            " contains. This really needs some cleanup
            let openPair = ms[2]

            " To compensate for multibyte pairs,
            " we need to search for escaping after we find a match.
            " Since b:AutoPairsList is sorted by pair size, we can assume that
            " if we find \[ and it's matched, it's because there's a pair that
            " matches \[, and not that we have [ escaped.
            if b:AutoPairsSearchEscape
                " Intermediate length
                let pLen = len(openPair)
                " First check the character prior to the character of the
                " current pair. Take \[ in LaTeX:
                "  0 0 \ [
                " -1 0 1 2
                "      ^ pair match found starting here -- that's why we're
                "        referencing the length of the found pair.
                "        Because of potentially varying width, we need to figure
                "        out how long the match we wanna search is.
                "    ^ Look for backslash here. If one is found,
                "  ^ Look for one here. Essentially, this is to make sure we
                "    don't trigger a false positive on, among other things,
                "    '\\|', type ' at |. Essentially, if the backslash is
                "    escaped, we assume that the pair character isn't.
                "    This doesn't take into account '\\\|', ' at |,
                "    because it only checks the last two backslashes.
                "    There's no good way to check for correct escaping without
                "    doing an obnoxious amount of checks, which is overkill
                "    for a case like this.
                " (0 is a reference to null, meaning there's no string at that
                " position)
                "
                " TL;DR: if we find a backslash in front of the pair, we then know
                " it's escaped, and we don't want to insert the close.
                " If there's another backslash in front of the backslash in
                " front of the pair, we assume the backslash is escaped and
                " insert the pair anyway.
                if before[-pLen:-pLen] == '\' && before[-pLen - 1:-pLen - 1] != '\'
                    return a:key
                endif
            endif

            " Krasjet: only insert the closing pair if the next character is a space
            " or a non-quote closing pair, or a whitelisted character (string)
            " Olivia: that ^ if and only if it's desired.
            if b:AutoPairsCompleteOnlyOnSpace == 1 && afterline[0] =~? '^\v\S' && afterline[0] !~# b:autopairs_next_char_whitelist
                break
            end

            let balanced = autopairs#Insert#checkBalance(open, close, opt, before, after, afterline,
                        \ {"openPair": openPair, "m": m}, 0)
            if balanced <= 0
                break
            endif

            return autopairs#Balancing#doInsert(open, close, openPair, before, afterline, target)
        end
    endfor
    " }}}

    let checkClose = autopairs#Insert#checkClose(a:key, before, after, afterline)
    if checkClose != ""
        " If we end up with checkClose != "", we know the close returned
        " something. That means the check was successful, and we wanna return
        " it
        return checkClose
    endif
    " Fly Mode, and the key is closed-pairs, search closed-pair and jump
    if g:AutoPairsFlyMode &&  a:key =~ '\v[' .. b:AutoPairsFlyModeList .. ']'
        if search(a:key, 'We')
            return "\<Right>"
        endif
    endif
    " As a final fallback, if we end up at the end, just return the key to
    " minimize distruption.
    return a:key
endf

func! autopairs#AutoPairsDelete()
    if !b:autopairs_enabled || b:AutoPairsIgnoreSingle
        let b:AutoPairsIgnoreSingle = 0
        return "\<BS>"
    end

    let [before, after, ig] = autopairs#Strings#getline(b:AutoPairsMultilineBackspace)

    for [open, close, opt] in b:AutoPairsList
        if !opt["delete"] || close == ''
            " Non-deletable pairs? Skip 'em
            continue
        endif
        let rest_of_line = opt['multiline'] ? after : ig
        let b = matchstr(before, '\V' .. open .. '\v\s?$')
        let a = matchstr(rest_of_line, '^\v\s*\V' .. close)

        if b != '' && a != ''
            if b[-1:-1] == ' '
                if a[0] == ' '
                    return "\<BS>\<DELETE>"
                else
                    return "\<BS>"
                end
            end
            return autopairs#Strings#backspace(b) .. autopairs#Strings#delete(a)
        end
    endfor

    " delete the pair foo[]| <BS> to foo
    for [open, close, opt] in b:AutoPairsList
        if !opt["delete"]
            continue
        endif
        if (close == '')
            continue
        endif
        let m = autopairs#Strings#matchend(before, '\V' .. open .. '\v\s*' .. '\V' .. close .. '\v$')

        if len(m) > 0
            return autopairs#Strings#backspace(m[2])
        elseif opt["multiline"] && b:AutoPairsMultilineBackspace
            let m = matchstr(before, '^\v\s*\V' .. close)
            if m != ''
                let b = ""
                let offset = 1
                " a = m
                while getline(line('.') - offset) =~ "^\s*$"
                    let b ..= getline(line('.') - offset) .. ' '
                    let offset += 1
                    if (line('.') - offset <= 0)
                        return "\<BS>"
                    endif
                endwhile
                let a = matchstr(getline(line('.') - offset), '\V' .. open .. '\v\s*$') .. ' '
                if a != ' '
                    return autopairs#Strings#backspace(a) .. autopairs#Strings#backspace(b) .. autopairs#Strings#backspace(m)
                endif
            endif
        end
    endfor
    return "\<BS>"
endf

" Fast wrap the word in brackets
" Note to self: default arguments aren't supported until
" 8.1 patch 1310, and doesn't support neovim. Implementing it here at this
" time would break the plugin for a lot of people.
" This being a fork, that isn't desired.
func! autopairs#AutoPairsFastWrap(...)
    let movement = get(a:, 1, 'e')
    let c = @"

    if b:AutoPairsMultibyteFastWrap
        let [before, after, ig] = autopairs#Strings#getline()
        " At this point, after refers to the bit after the cursor.
        " We haven't cut anything yet.
        if after == ''
            " While we do have multiline fast wrap, we actually do need
            " something to wrap.
            return ''
        endif
        let length = 1
        for [open, close, opt] in b:AutoPairsList
            if close == ''
                continue
            endif

            let match = []
            let esc = substitute(close, "'", "''", "g")
            let esc = substitute(esc, '\', '\\\\', "g")

            let res = substitute(after, '^\V' .. esc, '\=add(match, submatch(0))', '')

            if len(match) > 0 && len(match[0]) > length

                let length = len(match[0])
            endif
        endfor

        exec "normal!" length .. "x"
        let cursorOffset = length - 1
    else
        let cursorOffset = 0
        normal! x
    endi

    " Note regarding the previous note: an after == "" check doesn't make
    " sense here, because we've already cut at this point. We may want
    " multiline wrapping.
    " I think xd This has always been a bit weird. Might be better to
    " outsource the above check to outside the if-check to prevent weird
    " moves
    let [before, after, ig] = autopairs#Strings#getline()


    if after[0] =~ '\v[{[(<]'
        normal! %
        normal! p
    else
        for [open, close, opt] in b:AutoPairsList
            if close == ''
                continue
            end
            if after =~ '^\s*\V' .. open
                if open == close && count(before, open) % 2 != 0
                            \ && before =~ '\V' .. open .. '\v.*$' && after =~ '^\V' .. close
                    break
                endif

                call search(close, 'We')
                " Search goes for the first one rather than the logical option
                " -- the last one. This is only a problem when open == close,
                "  which means in the case of quotes.
                if open == close && after =~ '^\v\s+\V' .. close
                    call search(close, 'We')
                endif
                normal! p
                if cursorOffset > 0
                    exec "normal!" cursorOffset .. 'h'
                endif
                let @" = c
                return ""

            endif
        endfor
        let g:AutoPairsDebug = after
        if after[1:1] =~ '\v' .. (g:AutoPairsMultilineFastWrap ? '(\w|$)' : '\w')
            exec "normal! " .. movement
        endif
        normal! p

    endif
    if cursorOffset > 0
        exec "normal!" cursorOffset .. 'h'
    endif
    let @" = c
    return ""
endfun

" Contains manual jumping
func! autopairs#AutoPairsJump()
    if len(b:AutoPairs) == 0 || b:autopairs_enabled == 0
        return
    endif

    " Cache to prevent regenerating the regex
    if !exists('b:AutoPairsJumpRegex')
        " Defines the start of a regex group
        let b:AutoPairsJumpRegex = '\('
        " We then iterate all the pairs...
        for [open, close, _] in b:AutoPairsList
            if close == ''
                continue
            endif
            " ... and do some quick substitutions
            let res = substitute(close, "'", "''", 'g')
            let res = substitute(res, '\', '\\\\', 'g')
            " Append the element
            let b:AutoPairsJumpRegex ..= (len(b:AutoPairsJumpRegex) > 2 ? '\|' : '') .. res
        endfor
        " End the regex group and finalize the variable
        let b:AutoPairsJumpRegex ..= '\)'
    endif

    " Use the variable (either freshly generated or cached)
    call search('\V' .. b:AutoPairsJumpRegex, 'W')
endf

" Handles the move feature -- note that the move feature has been disabled by
" default. DO NOT confuse this for the jump feature.
func! autopairs#AutoPairsMoveCharacter(key)
    let c = getline(".")[col(".")-1]
    let escaped_key = substitute(a:key, "'", "''", 'g')
    return "\<DEL>\<ESC>:call search("."'" .. escaped_key .. "'" .. ")\<CR>a" .. c .. "\<LEFT>"
endf

" Back insert for flymode.
" setpos() makes this method unfit to be used as a backup for anything using
" mutation. If the code changes, the position to jump back to is unreliable
" and may be completely wrong.
func! autopairs#AutoPairsBackInsert()
    let pair = b:autopairs_saved_pair[0]
    let pos  = b:autopairs_saved_pair[1]
    call setpos('.', pos)
    return pair
endf

" Helper function. Determines what movement to do when <CR> is pushed.
" It's modularized to also enable g:AutoPairsAutoLineBreak.
fun! autopairs#AutoPairsDetermineCRMovement()
    let cmd = ''
    if g:AutoPairsCenterLine && winline() * 3 >= winheight(0) * 2
        " Recenter before adding new line to avoid replacing line content
        let cmd = "zz"
    end

    " If equalprg has been set, then avoid call
    " https://github.com/jiangmiao/auto-pairs/issues/24
    " This is essentially custom balancing beyond what Vim does.
    if &equalprg != ''
        return "\<ESC>" .. cmd .. "O"
    endif

    " Note: for indent issues, see :h autopairs-diagnose-indent
    " conflict with javascript and coffee
    " javascript   need   indent new line
    " coffeescript forbid indent new line
    if &filetype == 'coffeescript' || &filetype == 'coffee'
        return "\<ESC>" .. cmd .. "k==o"
    else
        return "\<ESC>" .. cmd .. "=ko"
    endif
endfun

func! autopairs#AutoPairsReturn()
    if b:autopairs_enabled == 0 || b:AutoPairsIgnoreSingle
        let b:AutoPairsIgnoreSingle = 0
        return ''
    end

    let b:autopairs_return_pos = 0
    let before = getline(line('.') - 1)
    let [ig, ig, afterline] = autopairs#Strings#getline()

    for [open, close, opt] in b:AutoPairsList
        if close == ''
            continue
        end

        " \V<open>\v is basically escaping. Makes sure ( isn't considered the
        " start of a group, which would yield incorrect results.
        " Used to prevent fuckups
        if before =~ '\V' .. open .. '\v' .. (b:AutoPairsReturnOnEmptyOnly ? '\s*' : '.*') .. '$' && afterline =~ '^\s*\V' .. close
            if b:AutoPairsCarefulStringExpansion && index(b:AutoPairsQuotes, open) != -1 && count(before, open) % 2 == 0
                return ""
            endif

            let b:autopairs_return_pos = line('.')
            " Determining the exact movement has been moved to a separate
            " function when autobreak was added as an option.
            return autopairs#AutoPairsDetermineCRMovement()
        end
    endfor
    return ''
endf

func! autopairs#AutoPairsSpace()
    if !b:autopairs_enabled || b:AutoPairsIgnoreSingle
        let b:AutoPairsIgnoreSingle = 0
        return "\<SPACE>"
    end

    let [before, after, ig] = autopairs#Strings#getline()

    for [open, close, opt] in b:AutoPairsList
        if close == ''
            continue
        end
        if before =~ '\V' .. open .. '\v$' && after =~ '^\V' .. close
            if close =~ '\v^[''"`]$'
                return "\<SPACE>"
            else
                return "\<SPACE>\<SPACE>" .. g:autopairs#Strings#Left
            end
        end
    endfor
    return "\<SPACE>"
endf

func! autopairs#AutoPairsMap(key, ...)
    " | is special key which separate map command from text
    let l:explicit = get(a:, '1', 0)
    let key = a:key
    if key == '|'
        let key = '<BAR>'
    end
    let escaped_key = substitute(key, "'", "''", 'g')
    " use expr will cause search() doesn't work
    if l:explicit && len(maparg(key, "i")) != 0
        return
    endif
    execute 'inoremap <buffer> <silent>' key "<C-R>=autopairs#AutoPairsInsert('" .. escaped_key .. "')<cr>"
endf

func! autopairs#AutoPairsToggle()
    let b:autopairs_enabled = !b:autopairs_enabled
    echo 'AutoPairs' (b:autopairs_enabled ? 'enabled' : 'disabled')
    return ''
endf

func! autopairs#AutoPairsIgnore()
    let b:AutoPairsIgnoreSingle = !b:AutoPairsIgnoreSingle
    echo (b:AutoPairsIgnoreSingle ? "Skipping next pair" : "Not skipping next pair")
    return ''
endfunc

fun! autopairs#AutoPairsToggleMultilineClose()
    let b:AutoPairsMultilineClose = !b:AutoPairsMultilineClose
    echo (b:AutoPairsMultilineClose ? "Enabled" : "Disabled") "multiline close"
    return ''
endfun

func! autopairs#AutoPairsInit()
    " Why can't we be consistent about capitalization? Ugh
    let b:autopairs_loaded = 1

    " Buffer definitions

    let b:autopairs_return_pos = 0
    let b:autopairs_saved_pair = [0, 0]
    " Krasjet: only auto-complete if the next character, or characters, is one of
    " these
    let b:autopairs_next_char_whitelist = []
    let b:AutoPairsList = []

    " Deal with mappings associated with specific pairs
    call autopairs#Keybinds#mapPairKeybinds()

    " Map keys associated with various functions
    call autopairs#Keybinds#mapKeys()

    " TODO: Is this really necessary?
    if &keymap != ''
        let l:imsearch = &imsearch
        let l:iminsert = &iminsert
        let l:imdisable = &imdisable
        execute 'setlocal keymap=' .. &keymap
        execute 'setlocal imsearch=' .. l:imsearch
        execute 'setlocal iminsert=' .. l:iminsert
        if l:imdisable
            execute 'setlocal imdisable'
        else
            execute 'setlocal noimdisable'
        end
    end

endf

func! autopairs#AutoPairsTryInit()
    if exists('b:autopairs_loaded')
        return
    endif

    if type(g:AutoPairsInitHook) == 2
        call g:AutoPairsInitHook()
    endif
    if index(g:AutoPairsDirectoryBlacklist, getcwd()) >= 0 || index(g:AutoPairsFiletypeBlacklist, &ft) != -1
        " TODO: return and make an explicit enable possible
        let b:autopairs_enabled = 0
    endif

    call autopairs#Variables#_InitBufferVariables()

    call autopairs#AutoPairsInit()
endf

let &cpoptions = s:save_cpo
unlet s:save_cpo
