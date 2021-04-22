" Insert or delete brackets, parens, quotes in pairs.
" Fork Maintainer: Olivia
" Version: See g:AutoPairsVersion, or the git tag
" Fork Repository: https://github.com/LunarWatcher/auto-pairs
" License: MIT

scriptencoding utf-8

" Current version; not representative of tags or real versions, but purely
" meant as a number associated with the version. Semantic meaning on the first
" digit will take place. See the documentation for more details.
let g:AutoPairsVersion = 30055

let s:save_cpo = &cpoptions
set cpoptions&vim

" Default autopairs
call autopairs#Strings#define("g:AutoPairs", {'(': ')', '[': ']', '{': '}', "'": "'", '"': '"',
            \ '```': '```', '"""':'"""', "'''":"'''", "`":"`"})

" Defines language-specific pairs. Please read the documentation before using!
" The last paragraph of the help is extremely important.
call autopairs#Strings#define("g:AutoPairsLanguagePairs", {
    \ "erlang": {'<<': '>>'},
    \ "tex": {'``': "''", '$': '$'},
    \ "html": {'<': '>'},
    \ 'vim': {'\v(^\s*\zs"\ze|".*"\s*\zs"\ze$|^(\s*[a-zA-Z]+\s*([a-zA-Z]*\s*\=\s*)?)@!(\s*\zs"\ze(\\\"|[^"])*$))': {"close": '', 'mapclose': 0}},
    \ 'rust': {'\w\zs<': '>', '&\zs''': ''},
    \ 'php': {'<?': { 'close': '?>', 'mapclose': ']'}, '<?php': {'close': '?>', 'mapclose': ']'}}
    \ })

" Krasjet: the closing character for quotes, auto completion will be
" inhibited when the next character is one of these
call autopairs#Strings#define('g:AutoPairsQuoteClosingChar', ['"', "'", '`'])

" Krasjet: if the next character is any of these, auto-completion will still
" be triggered
call autopairs#Strings#define('g:AutoPairsNextCharWhitelist', [])

" Krasjet: don't perform open balance check on these characters
call autopairs#Strings#define('g:AutoPairsOpenBalanceBlacklist', [])

" Krasjet: turn on/off the balance check for single quotes (')
" suggestions: use ftplugin/autocmd to turn this off for text documents
call autopairs#Strings#define('g:AutoPairsSingleQuoteBalanceCheck', 1)

" Disables the plugin in some directories.
" This is not available in a whitelist variant, because I'm lazy.
" (Pro tip: also a great use for autocmds and default-disable rather than
" plugin configuration. Project .vimrcs work too)
call autopairs#Strings#define('g:AutoPairsDirectoryBlacklist', [])
call autopairs#Strings#define('g:AutoPairsFiletypeBlacklist', [])

call autopairs#Strings#define('g:AutoPairsCompatibleMaps', 1)

" Olivia: set to 0 based on my own personal biases
call autopairs#Strings#define('g:AutoPairsMapBS', 0)
call autopairs#Strings#define('g:AutoPairsMultilineBackspace', 0)

call autopairs#Strings#define('g:AutoPairsMapCR', 1)

call autopairs#Strings#define('g:AutoPairsCRKey', '<CR>')

call autopairs#Strings#define('g:AutoPairsMapSpace', 1)

call autopairs#Strings#define('g:AutoPairsCenterLine', 1)

call autopairs#Strings#define('g:AutoPairsShortcutToggle', g:AutoPairsCompatibleMaps ? '<M-p>': '<C-p><C-t>')
call autopairs#Strings#define('g:AutoPairsShortcutFastWrap', g:AutoPairsCompatibleMaps ? '<M-e>' : '<C-f>')

call autopairs#Strings#define('g:AutoPairsMoveCharacter', "()[]{}\"'")
call autopairs#Strings#define('g:AutoPairsMoveExpression', '<C-p>%key')

" Variable controlling whether or not to require a space or EOL to complete
" bracket pairs. Extension off Krasjet.
call autopairs#Strings#define('g:AutoPairsCompleteOnlyOnSpace', 0)

call autopairs#Strings#define('g:AutoPairsShortcutJump', g:AutoPairsCompatibleMaps ? '<M-n>' : '<C-p><C-s>')

" Fly mode will for closed pair to jump to closed pair instead of insert.
" also support AutoPairsBackInsert to insert pairs where jumped.
call autopairs#Strings#define('g:AutoPairsFlyMode', 0)

" Default behavior for jiangmiao/auto-pairs: 1
call autopairs#Strings#define('g:AutoPairsMultilineCloseDeleteSpace', 1)

" Work with Fly Mode, insert pair where jumped
call autopairs#Strings#define('g:AutoPairsShortcutBackInsert', g:AutoPairsCompatibleMaps ? '<M-b>' : '<C-p><C-b>')

call autopairs#Strings#define('g:AutoPairsNoJump', 0)

call autopairs#Strings#define('g:AutoPairsInitHook', 0)

call autopairs#Strings#define('g:AutoPairsSearchCloseAfterSpace', 1)

call autopairs#Strings#define('g:AutoPairsSingleQuoteMode', 2)

call autopairs#Strings#define('g:AutoPairsSingleQuoteExpandFor', 'fbr')

call autopairs#Strings#define('g:AutoPairsAutoLineBreak', [])

call autopairs#Strings#define('g:AutoPairsCarefulStringExpansion', 1)
call autopairs#Strings#define('g:AutoPairsQuotes', ["'", '"'])

call autopairs#Strings#define('g:AutoPairsMultilineFastWrap', 0)

call autopairs#Strings#define('g:AutoPairsFlyModeList', '}\])')
call autopairs#Strings#define('g:AutoPairsJumpBlacklist', [])

call autopairs#Strings#define('g:AutoPairsMultibyteFastWrap', 1)

call autopairs#Strings#define('g:AutoPairsReturnOnEmptyOnly', 1)

call autopairs#Strings#define('g:AutoPairsShortcutMultilineClose', '<C-p>c')

call autopairs#Strings#define('g:AutoPairsExperimentalAutocmd', 0)
call autopairs#Strings#define('g:AutoPairsStringHandlingMode', 0)
call autopairs#Strings#define('g:AutoPairsSingleQuotePrefixGroup', '^|\W')

if exists('g:AutoPairsEnableMove')
    echom "g:AutoPairsEnableMove has been deprecated. If you set it to 1, you may remove it."
                \ . " If you set it to 0, let g:AutoPairsMoveExpression = '' to disable move again."
                \ . "  See the documentation for both variables for more details."
endif

fun! autopairs#AutoPairsScriptInit()
    echoerr "This method has been deprecated. See the help for further steps"
endfun

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
                echoerr "Invalid filetype: " . filetypes . " - must be string or list. Discarding pair"
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
    if !b:autopairs_enabled || (b:AutoPairsStringHandlingMode == 2 && autopairs#Strings#isInString())
        return a:key
    end
    let l:multiline = get(a:, '1', 0)

    let b:autopairs_saved_pair = [a:key, getpos('.')]

    let [before, after, afterline] = autopairs#Strings#getline(l:multiline)

    " Ignore auto close if prev character is \
    " And skip if it's double-escaped
    if before[-1:-1] == '\' && before[-2:-1] != "\\\\"
        return a:key
    end

    " check open pairs
    for [open, close, opt] in b:AutoPairsList
        let ms = autopairs#Strings#matchend(before . a:key, open)
        let m = matchstr(afterline, '^\v\s*\zs\V'.close)

        if len(ms) > 0

            " Krasjet: only insert the closing pair if the next character is a space
            " or a non-quote closing pair, or a whitelisted character (string)
            " Olivia: that ^ if and only if it's desired.

            if b:AutoPairsCompleteOnlyOnSpace == 1 && afterline[0] =~? '^\v\S' && afterline[0] !~# b:autopairs_next_char_whitelist
                break
            end

            if !autopairs#Insert#checkBalance(open, close, opt, before, after, afterline)
                break
            endif

            " remove inserted pair
            " eg: if the pairs include < > and  <!-- -->
            " when <!-- is detected the inserted pair < > should be clean up
            "
            let target = ms[1]
            let openPair = ms[2]

            if (len(openPair) == 1 && m == openPair) || (close == '')
                break
            end
            let bs = ''
            let del = ''
            while len(before) > len(target)
                let found = 0
                " delete pair
                for [o, c, opt] in b:AutoPairsList
                    let os = autopairs#Strings#matchend(before, o)
                    if len(os) && len(os[1]) < len(target)
                        " any text before openPair should not be deleted
                        continue
                    end
                    let cs = autopairs#Strings#matchbegin(afterline, c)
                    if len(os) && len(cs)
                        let found = 1
                        let before = os[1]
                        let afterline = cs[2]
                        let bs = bs.autopairs#Strings#backspace(os[2])
                        let del = del.autopairs#Strings#delete(cs[1])
                        break
                    end
                endfor
                if !found
                    " delete character
                    let ms = autopairs#Strings#matchend(before, '\v.')
                    if len(ms)
                        let before = ms[1]|
                        let bs = bs.autopairs#Strings#backspace(ms[2])
                    end
                end
            endwhile

            return bs.del.openPair.close.autopairs#Strings#left(close)
                        \ . (index(b:AutoPairsAutoLineBreak, open) != -1 ?
                        \     "\<cr>".autopairs#AutoPairsDetermineCRMovement()
                        \     : '')

        end
    endfor

    let checkClose = autopairs#Insert#checkClose(a:key, before, after, afterline)
    if checkClose != ""
        " If we end up with checkClose != "", we know the close returned
        " something. That means the check was successful, and we wanna return
        " it
        return checkClose
    endif
    " Fly Mode, and the key is closed-pairs, search closed-pair and jump
    if g:AutoPairsFlyMode &&  a:key =~ '\v[' . b:AutoPairsFlyModeList . ']'
        if search(a:key, 'We')
            return "\<Right>"
        endif
    endif

    " As a final fallback, if we end up at the end, just return the key to
    " minimize distruption.
    return a:key
endf

func! autopairs#AutoPairsDelete()
    if !b:autopairs_enabled
        return "\<BS>"
    end

    let [before, after, ig] = autopairs#Strings#getline(b:AutoPairsMultilineBackspace)

    for [open, close, opt] in b:AutoPairsList
        if !opt["delete"] || close == ''
            " Non-deletable pairs? Skip 'em
            continue
        endif
        let rest_of_line = opt['multiline'] ? after : ig
        let b = matchstr(before, '\V' . open . '\v\s?$')
        let a = matchstr(rest_of_line, '^\v\s*\V' . close)

        if b != '' && a != ''
            if b[-1:-1] == ' '
                if a[0] == ' '
                    return "\<BS>\<DELETE>"
                else
                    return "\<BS>"
                end
            end
            return autopairs#Strings#backspace(b) . autopairs#Strings#delete(a)
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
        let m = autopairs#Strings#matchend(before, '\V' . open . '\v\s*' . '\V' . close . '\v$')

        if len(m) > 0
            return autopairs#Strings#backspace(m[2])
        elseif opt["multiline"] && b:AutoPairsMultilineBackspace
            let m = matchstr(before, '^\v\s*\V' . close)
            if m != ''
                let b = ""
                let offset = 1
                " a = m
                while getline(line('.') - offset) =~ "^\s*$"
                    let b .= getline(line('.') - offset) . ' '
                    let offset += 1
                    if (line('.') - offset <= 0)
                        return "\<BS>"
                    endif
                endwhile
                let a = matchstr(getline(line('.') - offset), '\V' . open . '\v\s*$') . ' '
                if a != ' '
                    return autopairs#Strings#backspace(a) . autopairs#Strings#backspace(b) . autopairs#Strings#backspace(m)
                endif
            endif
        end
    endfor
    return "\<BS>"
endf

fun! autopairs#AutoPairsMultilineClose()
    " We get a char
    let char = getchar()
    " If the char is empty or esc (or CR), we skip and assume the user
    " aborted.
    if char == "" || char == "\<ESC>" || char == "\<CR>"
        return ""
    endif

    return autopairs#AutoPairsInsert(nr2char(char), 1)
endfun

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

            let res = substitute(after, '^\V' . esc, '\=add(match, submatch(0))', '')

            if len(match) > 0 && len(match[0]) > length

                let length = len(match[0])
            endif
        endfor

        exec "normal! " . length . "x"
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
            if after =~ '^\s*\V'.open
                if open == close && count(before, open) % 2 != 0
                            \ && before =~ '\V' . open . '\v.*$' && after =~ '^\V' . close
                    break
                endif

                call search(close, 'We')
                " Search goes for the first one rather than the logical option
                " -- the last one. This is only a problem when open == close,
                "  which means in the case of quotes.
                if open == close && after =~ '^\v\s+\V' . close
                    call search(close, 'We')
                endif
                normal! p
                if cursorOffset > 0
                    exec "normal! " . cursorOffset . 'h'
                endif
                let @" = c
                return ""

            endif
        endfor
        let g:AutoPairsDebug = after
        if after[1:1] =~ '\v' . (g:AutoPairsMultilineFastWrap ? '(\w|$)' : '\w')
            exec "normal! " . movement
            normal! p
        else
            normal! p
        endif

    endif
    if cursorOffset > 0
        exec "normal! " cursorOffset . 'h'
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
            let b:AutoPairsJumpRegex .= (len(b:AutoPairsJumpRegex) > 2 ? '\|' : '') . res
        endfor
        " End the regex group and finalize the variable
        let b:AutoPairsJumpRegex .= '\)'
    endif

    " Use the variable (either freshly generated or cached)
    call search('\V' . b:AutoPairsJumpRegex, 'W')
endf

" Handles the move feature -- note that the move feature has been disabled by
" default. DO NOT confuse this for the jump feature.
func! autopairs#AutoPairsMoveCharacter(key)
    let c = getline(".")[col(".")-1]
    let escaped_key = substitute(a:key, "'", "''", 'g')
    return "\<DEL>\<ESC>:call search("."'".escaped_key."'".")\<CR>a".c."\<LEFT>"
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
        return "\<ESC>".cmd."O"
    endif

    " Note: for indent issues, see :h autopairs-diagnose-indent
    " conflict with javascript and coffee
    " javascript   need   indent new line
    " coffeescript forbid indent new line
    if &filetype == 'coffeescript' || &filetype == 'coffee'
        return "\<ESC>".cmd."k==o"
    else
        return "\<ESC>".cmd."=ko"
    endif
endfun

func! autopairs#AutoPairsReturn()
    if b:autopairs_enabled == 0
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
        if before =~ '\V'.open.'\v' . (b:AutoPairsReturnOnEmptyOnly ? '\s*' : '.*') . '$' && afterline =~ '^\s*\V'.close
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
    if !b:autopairs_enabled
        return "\<SPACE>"
    end

    let [before, after, ig] = autopairs#Strings#getline()

    for [open, close, opt] in b:AutoPairsList
        if close == ''
            continue
        end
        if before =~ '\V'.open.'\v$' && after =~ '^\V'.close
            if close =~ '\v^[''"`]$'
                return "\<SPACE>"
            else
                return "\<SPACE>\<SPACE>" . g:autopairs#Strings#Left
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
    if explicit && len(maparg(key, "i")) != 0
        return
    endif
    execute 'inoremap <buffer> <silent> '.key." <C-R>=autopairs#AutoPairsInsert('". escaped_key."')<cr>"
endf

func! autopairs#AutoPairsToggle()
    if b:autopairs_enabled
        let b:autopairs_enabled = 0
        echo 'AutoPairs Disabled.'
    else
        let b:autopairs_enabled = 1
        echo 'AutoPairs Enabled.'
    end
    return ''
endf

func! autopairs#AutoPairsInit()
    " Why can't we be consistent about capitalization? Ugh
    let b:autopairs_loaded = 1

    call autopairs#Strings#define('b:autopairs_enabled', 1)
    call autopairs#Strings#define('b:AutoPairs', autopairs#AutoPairsDefaultPairs())
    call autopairs#Strings#define('b:AutoPairsQuoteClosingChar', copy(g:AutoPairsQuoteClosingChar))
    call autopairs#Strings#define('b:AutoPairsNextCharWhitelist', copy(g:AutoPairsNextCharWhitelist))
    call autopairs#Strings#define('b:AutoPairsOpenBalanceBlacklist', copy(g:AutoPairsOpenBalanceBlacklist))
    call autopairs#Strings#define('b:AutoPairsSingleQuoteBalanceCheck', g:AutoPairsSingleQuoteBalanceCheck)
    call autopairs#Strings#define('b:AutoPairsMoveCharacter', g:AutoPairsMoveCharacter)
    call autopairs#Strings#define('b:AutoPairsCompleteOnlyOnSpace', g:AutoPairsCompleteOnlyOnSpace)
    call autopairs#Strings#define('b:AutoPairsFlyMode', g:AutoPairsFlyMode)
    call autopairs#Strings#define('b:AutoPairsNoJump', g:AutoPairsNoJump)
    call autopairs#Strings#define('b:AutoPairsSearchCloseAfterSpace', g:AutoPairsSearchCloseAfterSpace)
    call autopairs#Strings#define('b:AutoPairsSingleQuoteMode', g:AutoPairsSingleQuoteMode)
    call autopairs#Strings#define('b:AutoPairsSingleQuoteExpandFor', g:AutoPairsSingleQuoteExpandFor)
    call autopairs#Strings#define('b:AutoPairsAutoLineBreak', g:AutoPairsAutoLineBreak)
    call autopairs#Strings#define('b:AutoPairsCarefulStringExpansion', g:AutoPairsCarefulStringExpansion)
    call autopairs#Strings#define('b:AutoPairsQuotes', g:AutoPairsQuotes)
    call autopairs#Strings#define('b:AutoPairsFlyModeList', g:AutoPairsFlyModeList)
    call autopairs#Strings#define('b:AutoPairsJumpBlacklist', g:AutoPairsJumpBlacklist)
    call autopairs#Strings#define('b:AutoPairsMultilineCloseDeleteSpace', g:AutoPairsMultilineCloseDeleteSpace)
    call autopairs#Strings#define('b:AutoPairsMultibyteFastWrap', g:AutoPairsMultibyteFastWrap)
    call autopairs#Strings#define('b:AutoPairsReturnOnEmptyOnly', g:AutoPairsReturnOnEmptyOnly)
    call autopairs#Strings#define('b:AutoPairsStringHandlingMode', g:AutoPairsStringHandlingMode)
    call autopairs#Strings#define('b:AutoPairsSingleQuotePrefixGroup', g:AutoPairsSingleQuotePrefixGroup)
    call autopairs#Strings#define('b:AutoPairsMoveExpression', g:AutoPairsMoveExpression)
    call autopairs#Strings#define('b:AutoPairsMultilineBackspace', g:AutoPairsMultilineBackspace)

    " Buffer definitions

    let b:autopairs_return_pos = 0
    let b:autopairs_saved_pair = [0, 0]
    " Krasjet: only auto-complete if the next character, or characters, is one of
    " these
    let b:autopairs_next_char_whitelist = []
    let b:AutoPairsList = []

    for [open, close] in items(b:AutoPairs)
        let o = autopairs#Strings#GetLastUnicodeChar(open)
        " We wanna proxy the string value of close so we can start converting
        " to a different format. There's _way_ too many formats, admittedly,
        " but this means we can sort shit into opt instead, which is already
        " present in the system. This also means close gets a canonical
        " meaning, and we don't need to rewrite other bits of the code to
        " add a proxy for something we already have.
        let stringClose = ""
        if type(close) == v:t_dict
            if !has_key(close, "close")
                " Let's silently make sure we have a close.
                let close["close"] = ""
            endif
            " Objects store it in a key
            let stringClose = close["close"]
        else
            " Strings store it in itself, for obvious reasons.
            let stringClose = close
        endif
        " This line right here is part of why we filter it out this early.
        let c = autopairs#Strings#GetFirstUnicodeChar(stringClose)
        " TODO: link some global options against (some of) these
        let opt = {'mapclose': 1,
                    \ 'alwaysmapdefaultclose': 1,
                    \ 'delete': 1, 'multiline': 1,
                    \ 'passiveclose': 1}
        " Default: set key = c
        let opt['key'] = c

        if o == c || len(c) == 0
            let opt['multiline'] = 0
        elseif type(close) == v:t_dict && has_key(close, 'multiline')
            let opt['multiline'] = close['multiline']
        endif

        if type(close) == v:t_dict
            " We have a brand fucking new object!
            " Let's handle mappings first
            if (has_key(close, "mapclose"))
                let mc = close["mapclose"]
                if type(mc) == v:t_number
                    let opt["mapclose"] = mc
                else
                    let opt["key"] = mc
                    " This is largely a compat util; if the key is empty, it's
                    " equivalent to setting it to 0
                    if (mc != "")
                        let opt["mapclose"] = 1
                    else
                        let opt["mapclose"] = 0
                    endif
                endif
            endif
            " We've handled multiline earlier, so we only need to handle
            " delete.
            " Filetype is only handled in intialization methods (and is purely
            " syntactic sugar for using a different variable), and therefore
            " isn't used here.
            if has_key(close, "delete")
                let opt["delete"] = close["delete"]
            endif
            let opt["alwaysmapdefaultclose"] = get(close, 'alwaysmapdefaultclose', 1)
            let opt["passiveclose"] = get(close, "passiveclose", 1)
        endif

        call autopairs#AutoPairsMap(o)
        if o != c && c != '' && opt['mapclose']
            if opt["key"] != c && opt["alwaysmapdefaultclose"]
                call autopairs#AutoPairsMap(c)
            endif

            call autopairs#AutoPairsMap(opt["key"], opt["key"] != c && opt["passiveclose"])
        end

        " Krasjet: add any non-string closing characters to a list
        let b:AutoPairsList += [[open, stringClose, opt]]
        " What in the fuck is this?
        " This is arguably Krasjet's least documented feature. Figure out what
        " it does pl0x
        if stringClose !=? '' && stringClose !~# '\V\['.escape(join(b:AutoPairsQuoteClosingChar,''),'\').']'
            let b:autopairs_next_char_whitelist += [escape(stringClose, '\')]
        end
    endfor

    " sort pairs by length, longer pair should have higher priority
    let b:AutoPairsList = sort(b:AutoPairsList, "autopairs#Strings#sortByLength")

    " Krasjet: add whitelisted strings to the list
    for str in b:AutoPairsNextCharWhitelist
        let b:autopairs_next_char_whitelist += [escape(str,'\')]
    endfor
    " Krasjet: construct a regex for whitelisted strings
    if empty(b:autopairs_next_char_whitelist)
        let b:autopairs_next_char_whitelist = '^$'
    else
        let b:autopairs_next_char_whitelist = '^\V\('.join(b:autopairs_next_char_whitelist, '\|').'\)'
    endif

    " Krasjet: add blacklisted open strings to the list
    let b:autopairs_open_blacklist = []
    for str in b:AutoPairsOpenBalanceBlacklist
        let b:autopairs_open_blacklist += [escape(str,'\')]
    endfor
    if empty(b:autopairs_open_blacklist)
        let b:autopairs_open_blacklist = '^$'
    else
        let b:autopairs_open_blacklist = '\V\('.join(b:autopairs_open_blacklist, '\|').'\)'
    endif

    for item in b:AutoPairsList
        let [open, close, opt] = item
        " Note to self: this is the bit that's responsible for checking
        " whether a single-quote is in a word or not.
        " Olivia: altered to allow three different modes, to prevent issues
        "         with things like string types in some languages (Python)
        "         where the programmers either can't use anything but single
        "         quotes, or (ew) decide to use single-quotes when
        "         double-quotes are possible
        if open == "'" && open == close
            if b:AutoPairsSingleQuoteMode == -1
                let item[0] = '\v\zs'''
            elseif b:AutoPairsSingleQuoteMode == 0
                let item[0] = '\v(' . b:AutoPairsSingleQuotePrefixGroup . ')\zs'''
            elseif b:AutoPairsSingleQuoteMode == 1
                let item[0] = '\v(' . b:AutoPairsSingleQuotePrefixGroup . ')\w?\zs'''
            elseif b:AutoPairsSingleQuoteMode == 2
                " Note that g:AutoPairsSingleQuoteExpandFor is a separate
                " group to make sure prefix conditions still hold. This means
                " it still works for normal characters, and shouldn't expand
                " for i.e. blahf'
                " Largely quality of life; can be worked around with
                " |b:AutoPairsSingleQuotePrefixGroup| and mode == 0 if other
                " behavior is desired.
                let item[0] = '\v(' . b:AutoPairsSingleQuotePrefixGroup . ')[' . b:AutoPairsSingleQuoteExpandFor . ']?\zs'''
            else
                echoerr 'Invalid b:AutoPairsSingleQuoteMode: ' . b:AutoPairsSingleQuoteMode
                    \ . ". Only -1, 0, 1, and 2 are allowed values."
            endif
        end
    endfor

    if b:AutoPairsMoveExpression != ""
        for key in split(b:AutoPairsMoveCharacter, '\s*')
            let escaped_key = substitute(key, "'", "''", 'g')
            execute 'inoremap <silent> <buffer> ' . substitute(b:AutoPairsMoveExpression, "%key", key, "") . " <C-R>=autopairs#AutoPairsMoveCharacter('".escaped_key."')<CR>"
        endfor
    endif

    if g:AutoPairsShortcutMultilineClose != ""
        execute 'inoremap <buffer> <silent> ' . g:AutoPairsShortcutMultilineClose . " <C-r>=autopairs#AutoPairsMultilineClose()<CR>"
    endif

    " Still use <buffer> level mapping for <BS> <SPACE>
    if g:AutoPairsMapBS
        " Use <C-R> instead of <expr> for issue #14 sometimes press BS output strange words
        execute 'inoremap <buffer> <silent> <BS> <C-R>=autopairs#AutoPairsDelete()<CR>'
    end

    if g:AutoPairsMapSpace
        " Try to respect abbreviations on a <SPACE>
        let do_abbrev = ""
        " neovim appears to set v:version to 800, so it should be compatible
        " with this.
        " Admittedly, probably not compatible with the same version checks,
        " but hey, it's fine.
        if v:version == 703 && has("patch489") || v:version > 703
            let do_abbrev = "<C-]>"
        endif
        execute 'inoremap <buffer> <silent> <SPACE> '.do_abbrev.'<C-R>=autopairs#AutoPairsSpace()<CR>'
    end

    if g:AutoPairsShortcutFastWrap != ''
        execute 'inoremap <buffer> <silent> '.g:AutoPairsShortcutFastWrap.' <C-R>=autopairs#AutoPairsFastWrap()<CR>'
    end

    if b:AutoPairsFlyMode && g:AutoPairsShortcutBackInsert != ''
        execute 'inoremap <buffer> <silent> '.g:AutoPairsShortcutBackInsert.' <C-R>=autopairs#AutoPairsBackInsert()<CR>'
    end

    if g:AutoPairsShortcutToggle != ''
        " use <expr> to ensure showing the status when toggle
        execute 'inoremap <buffer> <silent> <expr> '.g:AutoPairsShortcutToggle.' autopairs#AutoPairsToggle()'
        execute 'noremap <buffer> <silent> '.g:AutoPairsShortcutToggle.' :call autopairs#AutoPairsToggle()<CR>'
    end

    if g:AutoPairsShortcutJump != ''
        execute 'inoremap <buffer> <silent> ' . g:AutoPairsShortcutJump. ' <ESC>:call autopairs#AutoPairsJump()<CR>a'
        execute 'noremap <buffer> <silent> ' . g:AutoPairsShortcutJump. ' :call autopairs#AutoPairsJump()<CR>'
    end

    if &keymap != ''
        let l:imsearch = &imsearch
        let l:iminsert = &iminsert
        let l:imdisable = &imdisable
        execute 'setlocal keymap=' . &keymap
        execute 'setlocal imsearch=' . l:imsearch
        execute 'setlocal iminsert=' . l:iminsert
        if l:imdisable
            execute 'setlocal imdisable'
        else
            execute 'setlocal noimdisable'
        end
    end

endf

func! autopairs#ExpandMap(map)
    let map = a:map
    let map = substitute(map, '\(<Plug>\w\+\)', '\=maparg(submatch(1), "i")', 'g')
    let map = substitute(map, '\(<Plug>([^)]*)\)', '\=maparg(submatch(1), "i")', 'g')
    return map
endf

func! autopairs#AutoPairsTryInit()
    if exists('b:autopairs_loaded')
        return
    endif

    if type(g:AutoPairsInitHook) == 2
        call g:AutoPairsInitHook()
    endif
    if index(g:AutoPairsDirectoryBlacklist, getcwd()) >= 0 || index(g:AutoPairsFiletypeBlacklist, &ft) != -1
        let b:autopairs_enabled = 0
    endif

    " TODO: decode this comment
    " for auto-pairs starts with 'a', so the priority is higher than supertab and vim-endwise
    "
    " vim-endwise doesn't support <Plug>AutoPairsReturn
    " when use <Plug>AutoPairsReturn will cause <Plug> isn't expanded
    "
    " supertab doesn't support <SID>AutoPairsReturn
    " when use <SID>AutoPairsReturn  will cause Duplicated <CR>
    "
    " and when load after vim-endwise will cause unexpected endwise inserted.
    " so always load AutoPairs at last

    " Buffer level keys mapping
    " comptible with other plugin
    if g:AutoPairsMapCR
        if v:version == 703 && has('patch32') || v:version > 703
            " VIM 7.3 supports advancer maparg which could get <expr> info
            " then auto-pairs could remap <CR> in any case.
            let info = maparg(g:AutoPairsCRKey, 'i', 0, 1)
            if empty(info)
                " Not _entirely_ sure if this should be <CR> or
                " g:AutoPairsCRKey.
                let old_cr = '<CR>'
                let is_expr = 0
            else
                let old_cr = info['rhs']
                let old_cr = autopairs#ExpandMap(old_cr)
                let old_cr = substitute(old_cr, '<SID>', '<SNR>' . info['sid'] . '_', 'g')
                let is_expr = info['expr']
                let wrapper_name = '<SID>AutoPairsOldCRWrapper73'
            endif
        else
            " VIM version less than 7.3
            " the mapping's <expr> info is lost, so guess it is expr or not, it's
            " not accurate.
            let old_cr = maparg(g:AutoPairsCRKey, 'i')
            if old_cr == ''
                let old_cr = '<CR>'
                let is_expr = 0
            else
                let old_cr = autopairs#ExpandMap(old_cr)
                " old_cr contain (, I guess the old cr is in expr mode
                let is_expr = old_cr =~ '\V(' && toupper(old_cr) !~ '\V<C-R>'

                " The old_cr start with " it must be in expr mode
                let is_expr = is_expr || old_cr =~ '\v^"'
                let wrapper_name = '<SID>AutoPairsOldCRWrapper'
            endif
        endif

        if old_cr !~ 'AutoPairsReturn'
            if is_expr
                " remap <expr> to `name` to avoid mix expr and non-expr mode
                execute 'inoremap <buffer> <expr> <script> '. wrapper_name . ' ' . old_cr
                let old_cr = wrapper_name
            end
            " Always silent mapping
            execute 'inoremap <script> <buffer> <silent> ' .g:AutoPairsCRKey. ' ' .old_cr.'<SID>autopairs#AutoPairsReturn'
        endif
    endif
    call autopairs#AutoPairsInit()
endf

" Always silent the command
inoremap <silent> <SID>autopairs#AutoPairsReturn <C-R>=autopairs#AutoPairsReturn()<CR>
imap <script> <Plug>autopairs#AutoPairsReturn <SID>autopairs#AutoPairsReturn

let &cpoptions = s:save_cpo
unlet s:save_cpo

