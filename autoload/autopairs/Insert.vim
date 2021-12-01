" Checks whether or not the open-close pair is balanced
" Returns:
"   1 if balanced
"   0 if not
"   -1 if not balanced, but b:AutoPairsStringHandlingMode indicates this is
"      fine in this context, and should jump if possible
fun! autopairs#Insert#checkBalance(open, close, opt, before, after, afterline, ...)
    " TODO: do more caching here to avoid unnecessary calls to the balance
    " checker. It's potentially an expensive operation
    if a:close == ""
        return 1
    endif
    let checkingClose = get(a:, "0", 0)

    if b:AutoPairsStringHandlingMode == 2 && autopairs#Strings#isInString()
        return autopairs#Strings#GetFirstUnicodeChar(getline('.')[col('.') - 1:])
                    \ != autopairs#Strings#GetFirstUnicodeChar(a:close) ? 0 : -1
    endif
    let [closePre, openPre, closePost, openPost, strClose, strOpen, totClose, totOpen] = autopairs#Strings#countHighlightMatches(a:open, a:close, a:opt, 'string')
    echom closePre openPre closePost openPost strClose strOpen totClose totOpen
    " Krasjet: do not complete the closing pair until pairs are balanced
    if a:open !~# b:autopairs_open_blacklist
        if b:AutoPairsStringHandlingMode == 1 && autopairs#Strings#isInString()
            " We only need to address mode == 1 here.
            return strClose <= strOpen
                        \ || ((a:open == a:close || a:opt["balancebyclose"]) && (strOpen + strClose) % 2 == 0)
        else
            if a:open == a:close || (b:AutoPairsSingleQuoteBalanceCheck && a:close ==# "'") || a:opt["balancebyclose"]
                if (totOpen % 2 != 0)
                    return 0
                end

            " The first check is the standard check: if open < close, there's
            " an imbalance
            " The second check is if there are any close characters after the
            " cursor
            " The third check checks if everything is balanced after the
            " cursor.
            elseif ((!checkingClose || g:AutoPairsPreferClose)
                        \ && totOpen < totClose
                        \ && closePost > 0
                        \ && openPost < closePost
                        \ )

                " Olivia: aside making sure there's an overall imbalance
                " in the line, only balance the brackets if there's an
                " imbalance after the cursor (we can disregard anything
                " before the cursor), and make sure there's actually a
                " close character to close after the cursor
                return 0
            elseif checkingClose
                        \ && totOpen > totClose
                        \ && (!g:AutoPairsPreferClose && openPre > closePost
                        \     || openPost < closePost
                        \ )
                return 0
            endif
        endif
    endif

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
            let m = matchstr(a:afterline, searchRegex .. escape(close, '\'))
            if m != ''
                " Krasjet: only jump across the closing pair if pairs are balanced
                let balance = autopairs#Insert#checkBalance(open, close, opt, a:before, a:after, a:afterline, 1)
                if balance == 0
                    return a:key
                endif

                " Olivia: return the key if we aren't jumping.
                if b:AutoPairsNoJump == 1 || index(b:AutoPairsJumpBlacklist, close) != -1
                    return a:key
                endif
                if a:before =~ '\V' .. open .. '\v\s*$' && m[0] =~ '\v\s'
                    " remove the space we inserted if the text in pairs is blank
                    return "\<DEL>" .. autopairs#Strings#right(m[1:])
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
            let m = matchstr(a:after, '\v^\s*\zs\V' .. escape(close, '\'))
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
