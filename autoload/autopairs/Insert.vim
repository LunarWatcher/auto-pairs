fun! autopairs#Insert#checkBalance(open, close, opt, before, after, afterline) 
    if a:close == ""
        return 1
    endif
    let [closePre, openPre, closePost, openPost, strClose, strOpen, totClose, totOpen] = autopairs#Strings#countHighlightMatches(a:open, a:close, 'string') 
    " Krasjet: do not complete the closing pair until pairs are balanced
    if a:open !~# b:autopairs_open_blacklist
        if g:AutoPairsStringHandlingMode == 1 && autopairs#Strings#isInString()
            " We only need to address mode == 1 here.
            return strClose <= strOpen 
                        \ || ((a:open == a:close || a:close == "'") && (strOpen + strClose) % 2 == 0)
        else
            if a:open == a:close || (b:AutoPairsSingleQuoteBalanceCheck && a:close ==# "'")
                if (totOpen % 2 != 0)
                    return 0
                end
            else

                " Olivia: aside making sure there's an overall imbalance
                " in the line, only balance the brackets if there's an
                " imbalance after the cursor (we can disregard anything
                " before the cursor), and make sure there's actually a
                " close character to close after the cursor
                if (totOpen < totClose
                            \ && closePost > 0
                            \ && openPost < closePost)
                    return 0
                endif
            end
        endif
    end
    return 1
endfun

" Like checkClose, but for scripts that don't already have before, after, and
" afterline easily available.
fun! autopairs#Insert#checkCloseScript(key, ...)
    let l:multilineClose = get(a:, '1', 0)
    let [before, after, afterline] = s:getline()
    return autopairs#Insert#checkClose(key, before, after, afterline)
endfun

fun! autopairs#Insert#checkClose(key, before, after, afterline)

    " Whether or not to use a multiline close.
    " This functionality is disabled by default and requires an explicit
    " argument turning it on.

    for [open, close, opt] in b:AutoPairsList
        if close == ''
            continue
        end
        " This contains jump and close logic
        " The first if statement is to make sure the key pressed matches
        " either an explicit map close, an implicit mapped close, or both if
        " both are enabled.
        if opt['mapclose'] && opt['key'] == a:key || opt["alwaysmapdefaultclose"] == 1 && a:key == autopairs#Strings#GetFirstUnicodeChar(close)
            " the close pair is in the same line
            " ... but it's possible to enable only looking for the close pair 
            let searchRegex = b:AutoPairsSearchCloseAfterSpace == 1 ?  '^\v\s*\V' : '^\V'

            " Krasjet: do not search for the closing pair if spaces are in between
            " Olivia: Add override for people who want this (like me)
            " Note: this only checks the current line
            let m = matchstr(a:afterline, searchRegex . close)
            if m != ''
                " Krasjet: only jump across the closing pair if pairs are balanced

                if open == close || (b:AutoPairsSingleQuoteBalanceCheck && close ==# "'")
                    if count(a:before . a:afterline, close) % 2 != 0
                        return a:key
                    endif
                else
                    if autopairs#Strings#regexCount(a:before . a:afterline, open) > count(a:before . a:afterline, close)
                        return a:key
                    endif
                endif

                " Olivia: return the key if we aren't jumping.
                if b:AutoPairsNoJump == 1 || index(b:AutoPairsJumpBlacklist, close) != -1
                    return a:key
                endif
                if a:before =~ '\V'.open.'\v\s*$' && m[0] =~ '\v\s'
                    " remove the space we inserted if the text in pairs is blank
                    return "\<DEL>".autopairs#Strings#right(m[1:])
                else
                    return autopairs#Strings#right(m)
                endif
            end

            " Olivia: return the key if we aren't jumping.
            if b:AutoPairsNoJump == 1 || index(b:AutoPairsJumpBlacklist, close) != -1
                return a:key
            endif
            " This may check multiline depending on something.
            " Still not entirely sure what this brings to the table that the
            " other clause doesn't
            let m = matchstr(a:after, '\v^\s*\zs\V'.close)
            if m != ''
                if opt['multiline']
                    if b:AutoPairsMultilineCloseDeleteSpace && b:autopairs_return_pos == line('.') && getline('.') =~ '\v^\s*$'
                        exec 'normal! ddk$'
                    end
                    call search(m, 'We')
                    return "\<Right>"
                else
                    break
                end
            end
        end
    endfor
    return ""
endfun

