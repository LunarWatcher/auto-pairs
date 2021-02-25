" 7.4.849 support <C-G>U to avoid breaking '.'
" Issue talk: httpautopairs#Strings#//github.com/jiangmiao/auto-pairs/issues/3
" Vim note: httpautopairs#Strings#//github.com/vim/vim/releases/tag/v7.4.849
if v:version > 704 || v:version == 704 && has("patch849")
    let g:autopairs#Strings#Go = "\<C-G>U"
else
    let g:autopairs#Strings#Go = ""
endif

let g:autopairs#Strings#Left = g:autopairs#Strings#Go."\<LEFT>"
let g:autopairs#Strings#Right = g:autopairs#Strings#Go."\<RIGHT>"

fun! autopairs#Strings#define(name, default)
    if !exists(a:name)
        let {a:name} = a:default
    endif
endfun

" unicode len
func! autopairs#Strings#ulen(s)
    return len(split(a:s, '\zs'))
endf

func! autopairs#Strings#left(s)
    return repeat(g:autopairs#Strings#Left, autopairs#Strings#ulen(a:s))
endf

func! autopairs#Strings#right(s)
    return repeat(g:autopairs#Strings#Right, autopairs#Strings#ulen(a:s))
endf

func! autopairs#Strings#delete(s)
    return repeat("\<DEL>", autopairs#Strings#ulen(a:s))
endf

func! autopairs#Strings#backspace(s)
    return repeat("\<BS>", autopairs#Strings#ulen(a:s))
endf

func! autopairs#Strings#getline()

    let line = getline('.')
    let pos = col('.') - 1
    let before = strpart(line, 0, pos)
    let after = strpart(line, pos)
    let afterline = after
    "if b:AutoPairsMultilineClose
        "let n = line('$')
        "let i = line('.')+1
        "while i <= n
            "let line = getline(i)
            "let after = after.' '.line

            "if line !~? '\v^\s*$'
                "break
            "end
            "let i = i+1
        "endwhile
    "end

    " before: text before the cursor
    " after: text after the cursor
    " afterline: appears to be the line after the modifications (AKA the line
    "            in its current state)
    return [before, after, afterline]
endf

" split text to two part
" returns [orig, text_before_open, open]
func! autopairs#Strings#matchend(text, open)
    let m = matchstr(a:text, '\V'.a:open.'\v$')
    if m == ""
        return []
    end
    return [a:text, strpart(a:text, 0, len(a:text)-len(m)), m]
endf

" returns [orig, close, text_after_close]
func! autopairs#Strings#matchbegin(text, close)
    let m = matchstr(a:text, '^\V'.a:close)
    if m == ""
        return []
    end
    return [a:text, m, strpart(a:text, len(m), len(a:text)-len(m))]
endf

func! autopairs#Strings#sortByLength(i1, i2)
    return len(a:i2[0])-len(a:i1[0])
endf

fun! autopairs#Strings#regexCount(string, pattern)
    if a:string == "" || a:pattern == ""
        return 0
    endif
    let matches = []

    call substitute('' . a:string, '' . a:pattern, '\=add(matches, submatch(0))[-1]', 'g')

    return len(matches)
endfun!

" Unicode handling {{{
" Idea by httpautopairs#Strings#//github.com/fenukautopairs#Strings# httpautopairs#Strings#//github.com/jiangmiao/auto-pairs/issues/251#issuecomment-573901691
" Patch for #14 by httpautopairs#Strings#//github.com/j-hui: httpautopairs#Strings#//github.com/LunarWatcher/auto-pairs/issues/14
fun! autopairs#Strings#GetFirstUnicodeChar(string)
    if a:string == ""
        return ""
    endif

    let l:nr = strgetchar(a:string, 0)
    if l:nr == -1
        return ""
    else
        return nr2char(l:nr)
    endif
endfun

fun! autopairs#Strings#GetLastUnicodeChar(string)
    if a:string == ""
        return ""
    endif

    let l:nr = strgetchar(a:string, strchars(a:string) - 1)
    if l:nr == -1
        return ""
    else
        return nr2char(l:nr)
    endif
endfun

" }}}
