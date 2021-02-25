" Insert or delete brackets, parens, quotes in pairs.
" Fork Maintainer: Olivia
" Version: See g:AutoPairsVersion, or the git tag
" Fork Repository: https://github.com/LunarWatcher/auto-pairs
" License: MIT

scriptencoding utf-8

" Current version; not representative of tags or real versions, but purely
" meant as a number associated with the version. Semantic meaning on the first
" digit will take place. See the documentation for more details.
let g:AutoPairsVersion = 30053

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
    \ 'vim': {'\v(^\s*\zs"\ze|".*"\s*\zs"\ze$|^(\s*[a-zA-Z]+\s*([a-zA-Z]*\s*\=\s*)?)@!(\s*\zs"\ze(\\\"|[^"])*$))': ''},
    \ 'rust': {'\w\zs<': '>', '&\zs''': ''},
    \ 'php': {'<?': '?>//k]', '<?php': '?>//k]'}
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

call autopairs#Strings#define('g:AutoPairsMapCR', 1)

call autopairs#Strings#define('g:AutoPairsWildClosedPair', '')

call autopairs#Strings#define('g:AutoPairsCRKey', '<CR>')

call autopairs#Strings#define('g:AutoPairsMapSpace', 1)

call autopairs#Strings#define('g:AutoPairsCenterLine', 1)

call autopairs#Strings#define('g:AutoPairsShortcutToggle', g:AutoPairsCompatibleMaps ? '<M-p>': '<C-p><C-t>')
call autopairs#Strings#define('g:AutoPairsShortcutFastWrap', g:AutoPairsCompatibleMaps ? '<M-e>' : '<C-f>')

call autopairs#Strings#define('g:AutoPairsMoveCharacter', "()[]{}\"'")

" Variable controlling whether or not to require a space or EOL to complete
" bracket pairs. Extension off Krasjet.
call autopairs#Strings#define('g:AutoPairsCompleteOnlyOnSpace', 0)

call autopairs#Strings#define('g:AutoPairsShortcutJump', g:AutoPairsCompatibleMaps ? '<M-n>' : '<C-p><C-s>')

" Fly mode will for closed pair to jump to closed pair instead of insert.
" also support AutoPairsBackInsert to insert pairs where jumped.
call autopairs#Strings#define('g:AutoPairsFlyMode', 0)

" When skipping the closed pair, look at the current and
" next line as well.
call autopairs#Strings#define('g:AutoPairsMultilineClose', 0)

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

call autopairs#Strings#define('g:AutoPairsEnableMove', 0)

call autopairs#Strings#define('g:AutoPairsReturnOnEmptyOnly', 1)

fun! autopairs#AutoPairsScriptInit()
    " This currently does nothing; see :h autopairs#AutoPairsScriptInit()
endfun

" default pairs base on filetype
func! autopairs#AutoPairsDefaultPairs()
    if exists('b:autopairs_defaultpairs')
        return b:autopairs_defaultpairs
    end

    let r = copy(g:AutoPairs)
    if has_key(g:AutoPairsLanguagePairs, &ft)
        for [open, close] in items(g:AutoPairsLanguagePairs[&ft])
            let r[open] = close
        endfor
    endif

    let b:autopairs_defaultpairs = r
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
    for [open, close] in items(a:pairs)
        let r[open] = close
    endfor
    return r
endf

func! autopairs#AutoPairsInsert(key)
    if !b:autopairs_enabled
        return a:key
    end

    let b:autopairs_saved_pair = [a:key, getpos('.')]

    let [before, after, afterline] = autopairs#Strings#getline()

    " Ignore auto close if prev character is \
    " And skip if it's double-escaped
    if before[-1:-1] == '\' && before[-2:-1] != "\\\\"
        return a:key
    end

    " check open pairs
    for [open, close, opt] in b:AutoPairsList
        let ms = autopairs#Strings#matchend(before.a:key, open)
        let m = matchstr(afterline, '^\v\s*\zs\V'.close)

        if len(ms) > 0

            " process the open pair

            " Krasjet: only insert the closing pair if the next character is a space
            " or a non-quote closing pair, or a whitelisted character (string)
            " Olivia: that ^ if and only if it's desired.

            if b:AutoPairsCompleteOnlyOnSpace == 1 && afterline[0] =~? '^\v\S' && afterline[0] !~# b:autopairs_next_char_whitelist
                break
            end

            " Krasjet: do not complete the closing pair until pairs are balanced
            if open !~# b:autopairs_open_blacklist
                if open == close || (b:AutoPairsSingleQuoteBalanceCheck && close ==# "'")
                    if count(before.afterline, close) % 2 != 0
                        break
                    end
                else

                    " Olivia: aside making sure there's an overall imbalance
                    " in the line, only balance the brackets if there's an
                    " imbalance after the cursor (we can disregard anything
                    " before the cursor), and make sure there's actually a
                    " close character to close after the cursor

                    if (autopairs#Strings#regexCount(before.afterline, open) < count(before.afterline, close)
                                \ && stridx(after, close) != -1
                                \ && autopairs#Strings#regexCount(after, open) < count(after, close))

                        break
                    end
                end
            end

            " remove inserted pair
            " eg: if the pairs include < > and  <!-- -->
            " when <!-- is detected the inserted pair < > should be clean up
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

    " check close pairs
    for [open, close, opt] in b:AutoPairsList
        if close == ''
            continue
        end
        " Contains jump logic, apparently.
        if a:key == g:AutoPairsWildClosedPair || opt['mapclose'] && opt['key'] == a:key
            " the close pair is in the same line
            let searchRegex = b:AutoPairsSearchCloseAfterSpace == 1 ?  '^\v\s*\V' : '^\V'

            " Krasjet: do not search for the closing pair if spaces are in between
            " Olivia: Add override for people who want this (like me)
            " Note: this only checks the current line
            let m = matchstr(afterline, searchRegex . close)
            if m != ''
                " Krasjet: only jump across the closing pair if pairs are balanced

                if open == close || (b:AutoPairsSingleQuoteBalanceCheck && close ==# "'")
                    if count(before.afterline,close) % 2 != 0
                        return a:key
                    endif
                else
                    if autopairs#Strings#regexCount(before.afterline, open) > count(before.afterline, close)
                        return a:key
                    endif
                endif

                " Olivia: return the key if we aren't jumping.
                if b:AutoPairsNoJump == 1 || index(b:AutoPairsJumpBlacklist, close) != -1
                    return a:key
                endif
                if before =~ '\V'.open.'\v\s*$' && m[0] =~ '\v\s'
                    " remove the space we inserted if the text in pairs is blank
                    return "\<DEL>".autopairs#Strings#right(m[1:])
                else
                    return autopairs#Strings#right(m)
                endif
            end
            " I have no idea why this isn't an if-else. Is execution
            " guaranteed? More testing required
            " FIXME pl0x

            " Olivia: return the key if we aren't jumping.
            if b:AutoPairsNoJump == 1 || index(b:AutoPairsJumpBlacklist, close) != -1
                return a:key
            endif
            " This may check multiline depending on something.
            " Still not entirely sure what this brings to the table that the
            " other clause doesn't
            let m = matchstr(after, '\v^\s*\zs\V'.close)
            if m != ''

                if a:key == g:AutoPairsWildClosedPair || opt['multiline']
                    if b:AutoPairsMultilineCloseDeleteSpace && b:autopairs_return_pos == line('.') && getline('.') =~ '\v^\s*$'
                        normal! ddk$
                    end
                    call search(m, 'We')
                    return "\<Right>"
                else
                    break
                end
            end
        end
    endfor


    " Fly Mode, and the key is closed-pairs, search closed-pair and jump
    if g:AutoPairsFlyMode &&  a:key =~ '\v[' . b:AutoPairsFlyModeList . ']'
        if search(a:key, 'We')
            return "\<Right>"
        endif
    endif

    return a:key
endf

func! autopairs#AutoPairsDelete()
    if !b:autopairs_enabled
        return "\<BS>"
    end

    let [before, after, ig] = autopairs#Strings#getline()

    for [open, close, opt] in b:AutoPairsList
        let rest_of_line = opt['multiline'] ? after : ig
        let b = matchstr(before, '\V'.open.'\v\s?$')
        let a = matchstr(rest_of_line, '^\v\s*\V'.close)

        if b != '' && a != ''
            if b[-1:-1] == ' '
                if a[0] == ' '
                    return "\<BS>\<DELETE>"
                else
                    return "\<BS>"
                end
            end
            return autopairs#Strings#backspace(b).autopairs#Strings#delete(a)
        end
    endfor

    " delete the pair foo[]| <BS> to foo
    for [open, close, opt] in b:AutoPairsList
        if (close == '')
            continue
        endif
        let m = autopairs#Strings#matchend(before, '\V'.open.'\v\s*'.'\V'.close.'\v$')

        if len(m) > 0
            return autopairs#Strings#backspace(m[2])
        else
            let m = matchstr(before, '^\v\s*\V' . close)
            if m != ''
                let b = ""
                let offset = 1
                " a = m
                while getline(line('.') - offset) =~ "^\s*$"
                    let b .= getline(line('.') - offset) . ' '
                    let offset += 1
                    if (line('.') - offset == 0)
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
    endif

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
                    exec "normal! " . repeat('h', cursorOffset)
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
        if cursorOffset > 0
            exec "normal! " . repeat('h', cursorOffset)
        endif

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
        " Defines teh start of a regex group
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

func! autopairs#AutoPairsMap(key)
    " | is special key which separate map command from text
    let key = a:key
    if key == '|'
        let key = '<BAR>'
    end
    let escaped_key = substitute(key, "'", "''", 'g')
    " use expr will cause search() doesn't work

    execute 'inoremap <buffer> <silent> '.key." <C-R>=autopairs#AutoPairsInsert('".escaped_key."')<cr>"
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
    call autopairs#Strings#define('b:AutoPairsMultilineClose', g:AutoPairsMultilineClose)

    let b:autopairs_return_pos = 0
    let b:autopairs_saved_pair = [0, 0]
    " Krasjet: only auto-complete if the next character, or characters, is one of
    " these
    let b:autopairs_next_char_whitelist = []
    let b:AutoPairsList = []

    " buffer level map pairs keys
    " This contains primary mapping logic, and is a prime target for
    " converting keybinds to supporting maps as well as strings.
    " n - do not map the first character of closed pair to close key
    " m - close key jumps through multi line
    " s - close key jumps only in the same line
    for [open, close] in items(b:AutoPairs)
        let o = autopairs#Strings#GetLastUnicodeChar(open)
        let c = autopairs#Strings#GetFirstUnicodeChar(close)
        let opt = {'mapclose': 1, 'multiline':1}
        let opt['key'] = c
        if o == c || len(c) == 0
            let opt['multiline'] = 0
        end
        let m = matchlist(close, '\v(.*)//(.*)$')
        if len(m) > 0
            if m[2] =~ 'n'
                let opt['mapclose'] = 0
            end
            if m[2] =~ 'm'
                let opt['multiline'] = 1
            end
            if m[2] =~ 's'
                let opt['multiline'] = 0
            end
            let ks = matchlist(m[2], '\vk(.)')
            if len(ks) > 0
                let opt['key'] = ks[1]
                let c = opt['key']
            end
            let close = m[1]
        end
        call autopairs#AutoPairsMap(o)
        if o != c && c != '' && opt['mapclose']
            call autopairs#AutoPairsMap(c)
        end

        " Krasjet: add any non-string closing characters to a list
        let b:AutoPairsList += [[open, close, opt]]
        if close !=? '' && close !~# '\V\['.escape(join(b:AutoPairsQuoteClosingChar,''),'\').']'
            let b:autopairs_next_char_whitelist += [escape(close,'\')]
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
            if b:AutoPairsSingleQuoteMode == 0
                let item[0] = '\v(^|\W)\zs'''
            elseif b:AutoPairsSingleQuoteMode == 1
                let item[0] = '\v(^|\W)\w?\zs'''
            elseif b:AutoPairsSingleQuoteMode == 2
                let item[0] = '\v(^|\W)[' . b:AutoPairsSingleQuoteExpandFor . ']?\zs'''
            else
                echoerr 'Invalid b:AutoPairsSingleQuoteMode: ' . b:AutoPairsSingleQuoteMode
                    \ . ". Only 0, 1, or 2 are allowed."
            endif
        end
    endfor

    if g:AutoPairsEnableMove
        for key in split(b:AutoPairsMoveCharacter, '\s*')
            let escaped_key = substitute(key, "'", "''", 'g')
            execute 'inoremap <silent> <buffer> <C-'.key."> <C-R>=autopairs#AutoPairsMoveCharacter('".escaped_key."')<CR>"
        endfor
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

