fun! autopairs#Insert#checkBalance(open, close, opt, before, after, afterline) 
    
    " Krasjet: do not complete the closing pair until pairs are balanced
    if a:open !~# b:autopairs_open_blacklist
        if a:open == a:close || (b:AutoPairsSingleQuoteBalanceCheck && a:close ==# "'")
            if count(a:before . a:afterline, a:close) % 2 != 0
                return 0
            end
        else

            " Olivia: aside making sure there's an overall imbalance
            " in the line, only balance the brackets if there's an
            " imbalance after the cursor (we can disregard anything
            " before the cursor), and make sure there's actually a
            " close character to close after the cursor

            if (autopairs#Strings#regexCount(a:before . a:afterline, a:open) < count(a:before . a:afterline, a:close)
                        \ && stridx(a:after, a:close) != -1
                        \ && autopairs#Strings#regexCount(a:after, a:open) < count(a:after, a:close))
                return 0
            end
        end
    end
    return 1
endfun
