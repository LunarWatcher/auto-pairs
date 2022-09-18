if !has('nvim') && has('vimscript-4')
    scriptversion 4
endif

fun! s:define(name, default)
    " g:AutoPairsForceDefine is a variable meant for tests.
    " It's undocumented because it shouldn't be used outside testing,
    " as this will hard reset any options defined by the user.
    if !exists(a:name) || exists('g:AutoPairsForceDefine')
        let {a:name} = a:default
    endif
endfun

" TODO: sort this garbage
fun! autopairs#Variables#_InitVariables()
    " Default autopairs
    call s:define("g:AutoPairs", {'(': ')', '[': ']', '{': '}', "'": "'", '"': '"',
                \ '```': '```', '"""':'"""', "'''":"'''", "`":"`"})

    " Defines language-specific pairs. Please read the documentation before using!
    " The last paragraph of the help is extremely important.
    call s:define("g:AutoPairsLanguagePairs", {
        \ "erlang": {'<<': '>>'},
        \ "tex": {'``': "''", '$': '$'},
        \ "html": {'<': '>'},
        \ 'vim': {'\v(^\s*\zs"\ze|".*"\s*\zs"\ze$|^(\s*[a-zA-Z]+\s*([a-zA-Z]*\s*\=\s*)?)@!(\s*\zs"\ze((\\\"|[^"])*$)@=))': {"close": '', 'mapclose': 0}},
        \ 'rust': {'\w\zs<': '>', '&\zs''': ''},
        \ 'php': {'<?': { 'close': '?>', 'mapclose': ']'}, '<?php': {'close': '?>', 'mapclose': ']'}}
        \ })

    " Krasjet: the closing character for quotes, auto completion will be
    " inhibited when the next character is one of these
    call s:define('g:AutoPairsQuoteClosingChar', ['"', "'", '`'])

    " Krasjet: if the next character is any of these, auto-completion will still
    " be triggered
    call s:define('g:AutoPairsNextCharWhitelist', [])

    " Krasjet: don't perform open balance check on these characters
    call s:define('g:AutoPairsOpenBalanceBlacklist', [])

    " Krasjet: turn on/off the balance check for single quotes (')
    " suggestions: use ftplugin/autocmd to turn this off for text documents
    call s:define('g:AutoPairsSingleQuoteBalanceCheck', 1)

    " Disables the plugin in some directories.
    " This is not available in a whitelist variant, because I'm lazy.
    " (Pro tip: also a great use for autocmds and default-disable rather than
    " plugin configuration. Project .vimrcs work too)
    call s:define('g:AutoPairsDirectoryBlacklist', [])
    call s:define('g:AutoPairsFiletypeBlacklist', [])

    call s:define('g:AutoPairsCompatibleMaps', 0)

    " Olivia: set to 0 based on my own personal biases
    call s:define('g:AutoPairsMapBS', 0)
    call s:define('g:AutoPairsMultilineBackspace', 0)

    call s:define('g:AutoPairsMapCR', 1)

    call s:define('g:AutoPairsCRKey', '<CR>')

    call s:define('g:AutoPairsMapSpace', 1)

    call s:define('g:AutoPairsCenterLine', 1)

    call s:define('g:AutoPairsShortcutToggle', g:AutoPairsCompatibleMaps ? '<M-p>': '<C-p><C-t>')
    call s:define("g:AutoPairsShortcutIgnore", '<C-p><C-e>')
    call s:define('g:AutoPairsShortcutFastWrap', g:AutoPairsCompatibleMaps ? '<M-e>' : '<C-f>')

    call s:define('g:AutoPairsMoveCharacter', "()[]{}\"'")
    call s:define('g:AutoPairsMoveExpression', '<C-p>%key')

    " Variable controlling whether or not to require a space or EOL to complete
    " bracket pairs. Extension off Krasjet.
    call s:define('g:AutoPairsCompleteOnlyOnSpace', 0)
    call s:define('g:AutoPairsAutoBuildSpaceWhitelist', 1)
    call s:define('g:AutoPairsDefaultSpaceWhitelist', '')

    call s:define('g:AutoPairsShortcutJump', g:AutoPairsCompatibleMaps ? '<M-n>' : '<C-p><C-s>')

    " Fly mode will for closed pair to jump to closed pair instead of insert.
    " also support AutoPairsBackInsert to insert pairs where jumped.
    call s:define('g:AutoPairsFlyMode', 0)

    " Default behavior for jiangmiao/auto-pairs: 1
    call s:define('g:AutoPairsMultilineCloseDeleteSpace', 1)

    " Work with Fly Mode, insert pair where jumped
    call s:define('g:AutoPairsShortcutBackInsert', g:AutoPairsCompatibleMaps ? '<M-b>' : '<C-p><C-b>')

    call s:define('g:AutoPairsNoJump', 0)

    call s:define('g:AutoPairsInitHook', 0)

    call s:define('g:AutoPairsSearchCloseAfterSpace', 1)

    call s:define('g:AutoPairsSingleQuoteMode', 2)

    call s:define('g:AutoPairsSingleQuoteExpandFor', 'fbr')

    call s:define('g:AutoPairsAutoLineBreak', [])
    call s:define('g:AutoPairsAutoBreakBefore', [])

    call s:define('g:AutoPairsCarefulStringExpansion', 1)
    call s:define('g:AutoPairsQuotes', ["'", '"'])

    call s:define('g:AutoPairsMultilineFastWrap', 0)

    call s:define('g:AutoPairsFlyModeList', '}\])')
    call s:define('g:AutoPairsJumpBlacklist', [])

    call s:define('g:AutoPairsMultibyteFastWrap', 1)

    call s:define('g:AutoPairsReturnOnEmptyOnly', 1)

    call s:define('g:AutoPairsExperimentalAutocmd', 1)

    call s:define('g:AutoPairsStringHandlingMode', 0)
    call s:define('g:AutoPairsSingleQuotePrefixGroup', '^|\W')

    call s:define('g:AutoPairsPreferClose', 1)

    call s:define('g:AutoPairsMultilineClose', 0)
    call s:define('g:AutoPairsShortcutToggleMultilineClose', '<C-p><C-m>')
    call s:define('g:AutoPairsSearchEscape', 1)

    call s:define("g:AutoPairsBSAfter", 1)
    call s:define("g:AutoPairsBSIn", 1)

    call s:define("g:AutoPairsSyncAutoBreakOptions", 0)
endfun


fun! autopairs#Variables#_InitBufferVariables()
    call s:define('b:autopairs_enabled', 1)
    call s:define('b:AutoPairs', autopairs#AutoPairsDefaultPairs())
    call s:define('b:AutoPairsQuoteClosingChar', copy(g:AutoPairsQuoteClosingChar))
    call s:define('b:AutoPairsOpenBalanceBlacklist', copy(g:AutoPairsOpenBalanceBlacklist))
    call s:define('b:AutoPairsSingleQuoteBalanceCheck', g:AutoPairsSingleQuoteBalanceCheck)
    call s:define('b:AutoPairsMoveCharacter', g:AutoPairsMoveCharacter)

    call s:define('b:AutoPairsCompleteOnlyOnSpace', g:AutoPairsCompleteOnlyOnSpace)
    call s:define('b:AutoPairsAutoBuildSpaceWhitelist', g:AutoPairsAutoBuildSpaceWhitelist)
    call s:define('b:AutoPairsNextCharWhitelist', copy(g:AutoPairsNextCharWhitelist))

    call s:define('b:AutoPairsFlyMode', g:AutoPairsFlyMode)
    call s:define('b:AutoPairsNoJump', g:AutoPairsNoJump)
    call s:define('b:AutoPairsSearchCloseAfterSpace', g:AutoPairsSearchCloseAfterSpace)
    call s:define('b:AutoPairsSingleQuoteMode', g:AutoPairsSingleQuoteMode)
    call s:define('b:AutoPairsSingleQuoteExpandFor', g:AutoPairsSingleQuoteExpandFor)
    call s:define('b:AutoPairsCarefulStringExpansion', g:AutoPairsCarefulStringExpansion)
    call s:define('b:AutoPairsQuotes', g:AutoPairsQuotes)
    call s:define('b:AutoPairsFlyModeList', g:AutoPairsFlyModeList)
    call s:define('b:AutoPairsJumpBlacklist', g:AutoPairsJumpBlacklist)
    call s:define('b:AutoPairsMultilineCloseDeleteSpace', g:AutoPairsMultilineCloseDeleteSpace)
    call s:define('b:AutoPairsMultibyteFastWrap', g:AutoPairsMultibyteFastWrap)
    call s:define('b:AutoPairsReturnOnEmptyOnly', g:AutoPairsReturnOnEmptyOnly)
    call s:define('b:AutoPairsStringHandlingMode', g:AutoPairsStringHandlingMode)
    call s:define('b:AutoPairsSingleQuotePrefixGroup', g:AutoPairsSingleQuotePrefixGroup)
    call s:define('b:AutoPairsMoveExpression', g:AutoPairsMoveExpression)
    call s:define('b:AutoPairsMultilineBackspace', g:AutoPairsMultilineBackspace)

    call s:define('b:AutoPairsMultilineClose', g:AutoPairsMultilineClose)
    call s:define('b:AutoPairsSearchEscape', g:AutoPairsSearchEscape)

    call s:define('b:AutoPairsBSAfter', g:AutoPairsBSAfter)
    call s:define('b:AutoPairsBSIn', g:AutoPairsBSIn)
    " Keybinds
    call s:define('b:AutoPairsMapCR', g:AutoPairsMapCR)
    call s:define('b:AutoPairsCRKey', g:AutoPairsCRKey)
    call s:define('b:AutoPairsMapBS', g:AutoPairsMapBS)
    call s:define('b:AutoPairsMapSpace', g:AutoPairsMapSpace)
    call s:define('b:AutoPairsShortcutFastWrap', g:AutoPairsShortcutFastWrap)
    call s:define('b:AutoPairsShortcutBackInsert', g:AutoPairsShortcutBackInsert)
    call s:define('b:AutoPairsShortcutToggle', g:AutoPairsShortcutToggle)
    call s:define('b:AutoPairsShortcutJump', g:AutoPairsShortcutJump)
    call s:define('b:AutoPairsShortcutToggleMultilineClose', g:AutoPairsShortcutToggleMultilineClose)
    call s:define("b:AutoPairsShortcutIgnore", g:AutoPairsShortcutIgnore)

    call s:define("b:AutoPairsIgnoreSingle", 0)
    call s:define("b:AutoPairsSyncAutoBreakOptions", g:AutoPairsSyncAutoBreakOptions)

    " Linebreaks
    call s:define('b:AutoPairsAutoLineBreak', g:AutoPairsAutoLineBreak)
    if !b:AutoPairsSyncAutoBreakOptions
        call s:define('b:AutoPairsAutoBreakBefore', g:AutoPairsAutoBreakBefore)
    else
        let b:AutoPairsAutoBreakBefore = b:AutoPairsAutoLineBreak
    endif
endfun
