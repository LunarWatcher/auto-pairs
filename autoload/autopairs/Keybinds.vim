if !has('nvim') && has('vimscript-4')
    scriptversion 4
endif

function! autopairs#Keybinds#IgnoreInsertEnter(f, ...) abort
    " TODO: Change this to use <cmd> when support for vim 8.2.19xx is dropped
    let l:pre = "\<C-r>=autopairs#Keybinds#SetEventignore()\<CR>"
    let l:val = call(function(a:f), a:000)
    let l:post = "\<C-r>=autopairs#Keybinds#ResetEventignore()\<CR>"
    return l:pre .. l:val .. l:post
endfunction

function! autopairs#Keybinds#IgnoreInsertEnterCmd(cmd) abort
    call autopairs#Keybinds#SetEventignore()
    normal a:cmd
    call autopairs#Keybinds#ResetEventignore()
    return ''
endfunction

function! autopairs#Keybinds#SetEventignore()
    " TODO: Add InsertLeavePre when we know how to check version correctly on nvim
    " or when support for vim 8.2.1873 and below is dropped
    let b:autopairs_eventignore = &eventignore
    set eventignore+=InsertEnter,InsertLeave
    if exists('##InsertLeavePre')
        set eventignore+=InsertLeavePre
    endif

    return ''
endfunction

function! autopairs#Keybinds#ResetEventignore()
    let &eventignore = b:autopairs_eventignore
    return ''
endfunction

" Always silent the command
inoremap <silent> <SID>AutoPairsReturn <C-r>=autopairs#Keybinds#IgnoreInsertEnter('autopairs#AutoPairsReturn')<cr>
imap <Plug>AutoPairsReturn <SID>AutoPairsReturn

func! autopairs#Keybinds#ExpandMap(map)
    let map = a:map
    let map = substitute(map, '\(<Plug>\w\+\)', '\=maparg(submatch(1), "i")', 'g')
    let map = substitute(map, '\(<Plug>([^)]*)\)', '\=maparg(submatch(1), "i")', 'g')
    return map
endf

fun! autopairs#Keybinds#mapPairKeybinds()
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
                    \ 'passiveclose': 1,
                    \ 'balancebyclose': 0,
                    \ 'regex': 0}
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
            let mapDefaultClose = 1
            if (has_key(close, "mapclose"))
                let mc = close["mapclose"]
                if type(mc) == v:t_number
                    let opt["mapclose"] = mc
                    let mapDefaultClose = 0
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

            let opt["alwaysmapdefaultclose"] = get(close, 'alwaysmapdefaultclose', mapDefaultClose)
            let opt["passiveclose"] = get(close, "passiveclose", 1)
            let opt["balancebyclose"] = get(close, "balancebyclose", 0)
            let opt["regex"] = get(close, "regex", 0)
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

        " Inserts all non-string close characters into a regex for matching
        " whitelisted characters for the following character
        if b:AutoPairsAutoBuildSpaceWhitelist &&
                    \ stringClose !=? '' && stringClose !~# '\V\[' .. escape(join(b:AutoPairsQuoteClosingChar, ''), '\') .. ']'
            let b:autopairs_whitespace_exceptions += [escape(stringClose, '\')]
        end
    endfor

    " sort pairs by length, longer pair should have higher priority
    let b:AutoPairsList = sort(b:AutoPairsList, "autopairs#Strings#sortByLength")

    " Krasjet: add whitelisted strings to the list
    for str in b:AutoPairsNextCharWhitelist
        let b:autopairs_whitespace_exceptions += [escape(str,'\')]
    endfor
    " Krasjet: construct a regex for whitelisted strings
    if empty(b:autopairs_whitespace_exceptions)
        let b:autopairs_whitespace_exceptions = '^$'
    else
        let b:autopairs_whitespace_exceptions = '^\V\(' .. join(b:autopairs_whitespace_exceptions, '\|') .. '\)'
    endif

    " Krasjet: add blacklisted open strings to the list
    let b:autopairs_balance_blacklist = []
    for str in b:AutoPairsOpenBalanceBlacklist
        let b:autopairs_balance_blacklist += [escape(str,'\')]
    endfor
    if empty(b:autopairs_balance_blacklist)
        let b:autopairs_balance_blacklist = '^$'
    else
        let b:autopairs_balance_blacklist = '\V\('..join(b:autopairs_balance_blacklist, '\|') .. '\)'
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
                let item[0] = '\zs'''
            elseif b:AutoPairsSingleQuoteMode == 0
                let item[0] = '(' .. b:AutoPairsSingleQuotePrefixGroup .. ')\zs'''
            elseif b:AutoPairsSingleQuoteMode == 1
                let item[0] = '(' .. b:AutoPairsSingleQuotePrefixGroup .. ')\w?\zs'''
            elseif b:AutoPairsSingleQuoteMode == 2
                " Note that g:AutoPairsSingleQuoteExpandFor is a separate
                " group to make sure prefix conditions still hold. This means
                " it still works for normal characters, and shouldn't expand
                " for i.e. blahf'
                " Largely quality of life; can be worked around with
                " |b:AutoPairsSingleQuotePrefixGroup| and mode == 0 if other
                " behavior is desired.
                let item[0] = '(' .. b:AutoPairsSingleQuotePrefixGroup .. ')[' .. b:AutoPairsSingleQuoteExpandFor .. ']?\zs'''
            else
                echoerr 'Invalid b:AutoPairsSingleQuoteMode: ' .. b:AutoPairsSingleQuoteMode
                    \ .. ". Only -1, 0, 1, and 2 are allowed values.."
            endif
            let item[2]["balancebyclose"] = 1
            let item[2]["regex"] = 1
        end
    endfor
endfun

fun! autopairs#Keybinds#mapKeys()

    " This bit of code attempts to be compatible with other plugins.
    " It isn't always successful (:h autopairs-bad-cr), which is
    " overwhelmingly caused by other plugins doing weird shit with their
    " functions, in a way that often expects dedicated `<CR>` access.
    "
    " This leads to incompatibilities, some of which were previously listed in
    " a comment here, but have been moved to :h autopairs-incompatible-cr, at
    " least for plugins that have a confirmed incompatibility
    if b:AutoPairsMapCR
        " VIM 7.3 supports the advanced maparg, which can get <expr> info
        let info = maparg(g:AutoPairsCRKey, 'i', 0, 1)
        echom "maparg returned" info
        if empty(info)
            " Not _entirely_ sure if this should be <CR> or
            " g:AutoPairsCRKey.
            let old_cr = '<CR>'
            let is_expr = 0
        else
            let old_cr = info['rhs']
            let old_cr = autopairs#Keybinds#ExpandMap(old_cr)
            let old_cr = substitute(old_cr, '<SID>', '<SNR>' .. info['sid'] .. '_', 'g')
            let is_expr = info['expr']
            let wrapper_name = '<SID>AutoPairsOldCRWrapper73'
        endif

        if old_cr !~ 'AutoPairsReturn'
            if is_expr
                " remap <expr> to `name` to avoid mix expr and non-expr mode
                execute 'inoremap <buffer> <expr> <script> '.. wrapper_name .. ' ' .. old_cr
                let old_cr = wrapper_name
            end
            " Always silent mapping
            execute 'imap <script> <buffer> <silent> ' .. b:AutoPairsCRKey .. ' ' ..old_cr..'<SID>AutoPairsReturn'
        endif
    endif

    if b:AutoPairsMoveExpression != ""
        for key in split(b:AutoPairsMoveCharacter, '\s*')
            let escaped_key = substitute(key, "'", "''", 'g')
            execute 'inoremap <silent> <buffer> ' .. substitute(b:AutoPairsMoveExpression, "%key", key, "") .. " <C-R>=autopairs#Keybinds#IgnoreInsertEnter('autopairs#AutoPairsMoveCharacter', '"..escaped_key.."')<CR>"
        endfor
    endif

    " Still use <buffer> level mapping for <BS> <SPACE>
    if b:AutoPairsMapBS
        " Use <C-R> instead of <expr> for issue #14 sometimes press BS output strange words
        execute 'inoremap <buffer> <silent> <BS> <C-R>=autopairs#AutoPairsDelete()<CR>'
    end

    if b:AutoPairsMapSpace

        " <C-]> is required to respect abbreviations
        execute 'inoremap <buffer> <silent> <SPACE> <C-]><C-R>=autopairs#AutoPairsSpace()<CR>'
    end

    if b:AutoPairsShortcutFastWrap != ''
        execute 'inoremap <buffer> <silent> ' .. b:AutoPairsShortcutFastWrap .. ' <C-R>=autopairs#AutoPairsFastWrap()<CR>'
    end

    if b:AutoPairsFlyMode && b:AutoPairsShortcutBackInsert != ''
        execute 'inoremap <buffer> <silent> ' .. b:AutoPairsShortcutBackInsert .. ' <C-R>=autopairs#AutoPairsBackInsert()<CR>'
    end

    if b:AutoPairsShortcutToggle != ''
        " use <expr> to ensure showing the status when toggle
        execute 'inoremap <buffer> <silent> <expr> ' .. b:AutoPairsShortcutToggle .. ' autopairs#AutoPairsToggle()'
        execute 'noremap <buffer> <silent> ' .. b:AutoPairsShortcutToggle .. ' :call autopairs#AutoPairsToggle()<CR>'
    end

    if b:AutoPairsShortcutToggleMultilineClose != ''

        execute 'inoremap <buffer> <silent> <expr> ' .. b:AutoPairsShortcutToggleMultilineClose .. ' autopairs#AutoPairsToggleMultilineClose()'
        execute 'noremap <buffer> <silent> ' .. b:AutoPairsShortcutToggleMultilineClose .. ' :call autopairs#AutoPairsToggleMultilineClose()<CR>'
    endif

    if b:AutoPairsShortcutJump != ''
        " execute 'inoremap <buffer> <silent> ' .. b:AutoPairsShortcutJump .. ' <cmd>set eventignore+=InsertEnter,InsertLeavePre,InsertLeave<CR><ESC>:call autopairs#AutoPairsJump()<CR>a<cmd>set eventignore-=InsertEnter,InsertLeavePre,InsertLeave<CR>'
        execute 'inoremap <buffer> <silent> ' .. b:AutoPairsShortcutJump .. ' <C-r>=autopairs#Keybinds#IgnoreInsertEnterCmd("<ESC>:call autopairs#AutoPairsJump()<CR>a")'
        execute 'inoremap <buffer> <silent> ' .. b:AutoPairsShortcutJump .. ' <cmd>call autopairs#AutoPairsJump()<CR>'
        execute 'noremap <buffer> <silent> ' .. b:AutoPairsShortcutJump .. ' :call autopairs#AutoPairsJump()<CR>'
    end

    if b:AutoPairsShortcutIgnore != ''
        execute 'inoremap <buffer> <silent> ' .. b:AutoPairsShortcutIgnore .. ' <C-r>=autopairs#AutoPairsIgnore()<cr>'
    end
endfun
