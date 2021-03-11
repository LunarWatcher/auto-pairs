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

func! autopairs#Strings#getline(...)
    let multilineClose = get(a:, '1', 0)

    let line = getline('.')
    let pos = col('.') - 1
    let before = strpart(line, 0, pos)
    let after = strpart(line, pos)
    let afterline = after
    if multilineClose
        let n = line('$')
        let i = line('.')+1
        while i <= n
            let line = getline(i)
            let after = after.' '.line

            if line !~? '\v^\s*$'
                break
            end
            let i = i+1
        endwhile
    end

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
endfun

" Returns: [int, int, int, int, int, int]
" Which are, in order:
" * closes before the cursor
" * opens before the cursor
" * closes after the cursor
" * opens after the cursor
" The four above groups are all outside strings. The final two are (still in
" order):
" * closes in string
" * closes outside string
fun! autopairs#Strings#countHighlightMatches(open, close, highlightGroup, checkInside)
    if g:AutoPairsStringHandlingMode == 0 || g:AutoPairsStringHandlingMode > 2 || close == ''
        return [0, 0, 0, 0, 0, 0]
    endif
    let lineNum = line('.')
    " TODO: Add a counter for some increased multiline stuff
    let line = getline(lineNum)
    " We wanna keep track of the current index as well
    let cursorIdx = col('.')
    " This is largely just a tracker to check whether we're inside or outside
    " a string. This is partly used to keep counts, and partly to separate
    " string opens from string content. That's actually relatively tricky.
    let inString = 0
    " Where we're at in the string parsing
    let parseIdx = 0
    " The clusterfuck of variables.
    " These keep track of closes and opens in various bits of the current
    " line.
    let closePre = 0
    let openPre = 0
    let closePost = 0
    let openPost = 0
    let closeString = 0
    let openString = 0


    let last = col('$')

    while parseIdx < last
        let curr = line[parseIdx]
        if curr == a:open
            " Check the hl group
            " TODO: determine performance impact
            if (autopairs#Strings#posInGroup(lineNum, parseIdx + 1, 'string'))
                let openString += 1 
            else
                if parseIdx >= cursorIdx
                    let openPost += 1
                else
                    let openPre += 1
                endif
            endif
        elseif curr == a:close
            if (autopairs#Strings#posInGroup(lineNum, parseIdx + 1, 'string'))
                let closeString += 1
            else
                if parseIdx >= cursorIdx
                    let closePost += 1
                else
                    let closePre += 1
                endif
            endif
            
        endif
        
        let parseIdx += 1
    endwhile

    return [closePre, openPre, closePost, openPost, closeString, openString]
endfun

fun! autopairs#Strings#posInGroup(y, x, group)

    return join(map(synstack(y, x), 'synIDattr(v:val, "name")'), ',') =~? group
endfun

fun! autopairs#Strings#isInString()
    " Checks whether or not the cursor is in a comment. 
    return join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), ',') =~? 'string'
endfun

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
