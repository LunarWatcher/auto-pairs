if !has('nvim') && has('vimscript-4')
    scriptversion 4
endif

" 7.4.849 support <C-G>U to avoid breaking '.'
" Issue talk: https://github.com/jiangmiao/auto-pairs/issues/3
" Vim note: https://github.com/vim/vim/releases/tag/v7.4.849
if v:version > 704 || v:version == 704 && has("patch849")
    let g:autopairs#Strings#Go = "\<C-G>U"
else
    let g:autopairs#Strings#Go = ""
endif

let g:autopairs#Strings#Left = g:autopairs#Strings#Go.."\<LEFT>"
let g:autopairs#Strings#Right = g:autopairs#Strings#Go.."\<RIGHT>"

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
            let after = after .. ' ' .. line

            if line !~? '\v^\s*$'
                break
            end
            let i += 1
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
func! autopairs#Strings#matchend(text, open, ...)
    let opt = get(a:, '1', {'regex': 0})
    let m = matchstr(a:text, (type(opt) == v:t_number ? a:open : autopairs#Utils#escape(a:open, opt)) .. '\v$')
    if m == ""
        return []
    end
    return [a:text, strpart(a:text, 0, len(a:text)-len(m)), m]
endf

" returns [orig, close, text_after_close]
func! autopairs#Strings#matchbegin(text, close, ...)
    let opt = get(a:, '1', {'regex': 0})
    let m = matchstr(a:text, '^' .. (type(opt) == v:t_number ? a:open : autopairs#Utils#escape(a:close, opt)) .. '\v$')
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

    call substitute('' .. a:string, '' .. a:pattern, '\=add(matches, submatch(0))[-1]', 'g')

    return len(matches)
endfun

" {{{ Syngroups
" Returns: [int, int, int, int, int, int, int, int]
" Which are, in order:
" * closes before the cursor
" * opens before the cursor
" * closes after the cursor
" * opens after the cursor
" The four above groups are all outside strings. The final four are (still in
" order):
" * closes in string
" * opens in string
" * overall close (before and after, without strings if option != 0)
" * overall open (before and after, without strings of option != 0)
fun! autopairs#Strings#countHighlightMatches(open, close, opt, highlightGroup)
    let close = a:close
    let open = a:opt["balancebyclose"] ? close : a:open
    let regex = a:opt["regex"]

    let lineNum = line('.')
    " TODO: Add a counter for some increased multiline stuff
    if b:AutoPairsStringHandlingMode == 0 || &ft == ""
        " This is pretty much the stuff we used to have to check for balance.
        " TODO: determine the significance of s:getline()
        let [before, after, afterline] = autopairs#Strings#getline()

        if open == close
            let openPre = regex ? autopairs#Strings#regexCount(before, autopairs#Utils#escape(open, a:opt)) : count(before, open)
            let openPost = regex ? autopairs#Strings#regexCount(after, autopairs#Utils#escape(open, a:opt)) : count(after, open)
            let closePre = 0
            let closePost = 0
        else
            let openPre = regex ? autopairs#Strings#regexCount(before, autopairs#Utils#escape(open, a:opt)) : count(before, open)
            let openPost = regex ? autopairs#Strings#regexCount(after, autopairs#Utils#escape(open, a:opt)) : count(after, open)
            let closePre = regex ? autopairs#Strings#regexCount(before, autopairs#Utils#escape(close, a:opt)) : count(before, close)
            let closePost = regex ? autopairs#Strings#regexCount(after, autopairs#Utils#escape(close, a:opt)) : count(after, close)
        endif

        return [closePre, openPre, closePost, openPost, 0, 0, closePre + closePost, openPre + openPost]
    endif
    let line = getline(lineNum)
    " The clusterfuck of variables.
    " These keep track of closes and opens in various bits of the current
    " line.
    let closePre = 0
    let openPre = 0
    let closePost = 0
    let openPost = 0
    let closeString = 0
    let openString = 0
    " We wanna keep track of the current index as well
    let cursorIdx = col('.')
    let last = col('$')
    " In order to facilitate multibyte, we need to do a search
    " First, let's sweep open
    let offset = 0

    let lastPos = 1
    let wasLastAString = 0

    while offset < last
        let pos = match(line, autopairs#Utils#escape(open, a:opt), offset)
        if pos == -1
            break
        endif
        let offset = pos + len(open)
        let pos = pos + 1
        " Hack to make it slightly more unicode-friendly.
        " At least this way we can traverse over the first character, which is
        " what we wanna do here.
        let firstChar = autopairs#Strings#GetFirstUnicodeChar(open)
        if lastPos == pos - 1 && !wasLastAString
            " Can't use wasLastAString as all three parameters, because it
            " creates a false positive for "" - this is largely a problem
            " because it incorrectly reports the second " as an open in a
            " string.
            " Might be worth using wasLastAString && a:open != a:close though.
            " /shrug
            let [hlBefore, hlAt, hlAfter] = [0, 0, 0]
        else
            " Optimization: only look for hlAt first
            let [hlBefore, hlAt, hlAfter] = [0, autopairs#Strings#posInGroup(lineNum, pos, a:highlightGroup), 0]
                                                                                    " We check the length of open here to make sure we get _past_ the string.
                                                                                    " Not unicode-friendly wrt. multibyte unicode pairs. Creative ideas welcome
            " If the current character is highlighted, _then_ we care about what comes next.
            " This is largely because if the current character isn't
            " highlighted, who cares? It's obviously not in a string, so fuck that.
            " If, however, it is highlighted, then we need to check the next characters as well.
            " This can be further optimized by detecting string characters,
            " but that's a job for later.
            if hlAt
                let [hlBefore, hlAfter] = [autopairs#Strings#posInGroup(lineNum, pos - len(firstChar), a:highlightGroup),
                            \ autopairs#Strings#posInGroup(lineNum, pos + len(open), a:highlightGroup)]
            endif
        endif
        let lastPos = pos
        if !hlAt || (hlBefore && !hlAfter && pos != last - len(open)) || (!hlBefore && hlAfter)
            let {offset >= cursorIdx ? 'openPost' : 'openPre'} += 1
            let wasLastAString = 0
        else
            let wasLastAString = 1
            let openString += 1
        endif
        " This is NOT unicode multibyte compatible, but it produces very few edge
        " cases.
        " To be clear, this only affects unicode characters, not multibyte
        " pairs of normal single-byte characters.
    endwhile

    let wasLastAString = 0
    let lastPos = 0
    if (open != close)
        " If open == close, we've already processed everything.
        " Otherwise, here we go again

        let offset = 0
        while offset < last
            let pos = match(line, autopairs#Utils#escape(a:close, a:opt), offset)
            if pos == -1
                break
            endif
            let offset = pos + len(a:close)
            " Optimization (based on an assumption; feel free to prove me
            " wrong): I've not been able to find a single language with
            " asymmetric open and close. The obvious exception is if someone
            " i.e. maps 'f"': '"', but better handling of these in general
            " makes these pointless. Those pairs still expand on ", meaning
            " it's not asymmetric.
            " if there's options I've missed, please open an issue on GitHub
            let inHl = (lastPos == pos - 1 ? wasLastAString : autopairs#Strings#posInGroup(lineNum, pos + 1, a:highlightGroup))
            let lastPos = pos
            if !inHl
                let {offset >= cursorIdx - 1 ? 'closePost' : 'closePre'} += 1
                let wasLastAString = 0
            else
                let closeString += 1
                let wasLastAString = 1
            endif
        endwhile
    endif
    return [closePre, openPre, closePost, openPost, closeString,
                \ openString, closePre + closePost, openPre + openPost]
endfun

fun! autopairs#Strings#posInGroup(y, x, group)
    if (a:y > len(col('$')))
        return 0
    endif
    return match(map(synstack(a:y, min([a:x, col('$')])), 'synIDattr(v:val, "name")'), '\c' .. a:group) != -1
endfun

fun! autopairs#Strings#isInString()
    " Checks whether or not the cursor is in a string
    " We have to do a double check to account for the fact that we don't
    " actually have the chars yet. We therefore check both the current and the
    " past char. This results in the edge cases of 'string'|'string', but in a
    " case like this, a space isn't gonna kill you.
    " More creative ideas are welcome here, though. A double check is somewhat
    " heavy, though. Synstack seems to be an overall heavy call.
    " TODO: revisit
    return match(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), '\cstring') != -1 &&
                \ match(map(synstack(line('.'), col('.') - 1), 'synIDattr(v:val, "name")'), '\cstring') != -1

endfun
" }}}
" Unicode handling {{{
" Idea by https://github.com/fenuks: https://github.com/jiangmiao/auto-pairs/issues/251#issuecomment-573901691
" Patch for #14 by https://github.com/j-hui: https://github.com/LunarWatcher/auto-pairs/issues/14
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
