" Escapes a pair in a way that respects the 'regex' option for a pair
" This ensures the pairs are properly escaped according to pair settings.
fun! autopairs#Utils#escape(pair, opt)
    if !a:opt["regex"]
        return '\V' .. escape(a:pair, '\')
    else
        return '\v' .. a:pair .. '\V'
    endif
endfun
