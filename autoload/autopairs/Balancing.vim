fun! autopairs#Balancing#doInsert(open, close, openPair, before, afterline, target)
    let open = a:open
    let close = a:close
    let openPair = a:openPair
    let before = a:before
    let afterline = a:afterline
    let target = a:target
    " This first block makes sure we remove old insertions. This is
    " exclusively used for multibyte pairs.
    "
    " For an instance, if we have a pair <: > and <%: %], in the lack
    " of a better, real-world example (but the point being that one char is a
    " pair, multiple isn't), we'll want to clear the > from the previous pair
    " entirely when the % is inserted.
    "
    " Strictly speaking, this just does a bunch of calculations on
    " deletion numbers
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
                let bs = bs .. autopairs#Strings#backspace(os[2])
                let del = del .. autopairs#Strings#delete(cs[1])
                break
            end
        endfor
        if !found
            " delete character
            let ms = autopairs#Strings#matchend(before, '\v.')
            if len(ms)
                let before = ms[1]
                let bs = bs .. autopairs#Strings#backspace(ms[2])
            end
        end
    endwhile
    return bs .. del .. openPair
                \ .. close .. autopairs#Strings#left(close)
                \ .. (index(b:AutoPairsAutoLineBreak, open) != -1 ?
                \     "\<cr>" .. autopairs#AutoPairsDetermineCRMovement()
                \     : '')
endfun
