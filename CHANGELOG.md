# 4.0.2
`g:AutoPairsVersion = 40002`

## Changed
* Setting `mapclose = 0` now makes `alwaysmapdefaultclose` default to 0 instead of 1
* The LaTeX pairs no longer jump by default

## Added
* `g:AutoPairsSpaceCompletionRegex` ([#75 followups](https://github.com/LunarWatcher/auto-pairs/issues/75#issuecomment-1403772146))

## Docs
* Described the exact reason for [#66](https://github.com/LunarWatcher/auto-pairs/issues/66) in `:h autopairs-autocomplete-cr`

# 4.0.1
`g:AutoPairsVersion = 40001`

## Fixed
* Missing escape ([#74](https://github.com/LunarWatcher/auto-pairs/issues/74))

# 4.0.0
`g:AutoPairsVersion = 40000`

## Changed
* `g:AutoPairsCompatibleMaps` is now 0 by default.
* Added enforcement of scriptversion 4 to all files

## Documentation
* Added docs for `<CR>` incompatibilities
* Documentation with some basic how-to guides for auto-pairs features. These can technically be figured out by just reading the documentation, but it's easier to compress it into concrete guides.
* Documentation for Krasjet's space-only completion exceptions, and first-class support for it.
* Documentation and first-class support for Krasjet's balance blacklist

## Fixed
* Minimum Vim version is now correctly listed as 8.1 patch 1114; I severely misread the minimum required version before.
* Missing `...` specifier prevented argument forwarding for IgnoreInsertEnter
* Missing period for string concatenation seems to have broken the move feature
* Switched to a variable for universal event ignoring, without overwriting the variable unrecoverably (`exists('##InsertLeavePre')` &lt;3)
* [parallel-fixed in an unversioned 3.0.x-version] Fixed bad regex management for multibyte pairs ([#71](https://github.com/LunarWatcher/auto-pairs/issues/71))

## Added
* Tests for both the character whitelist for only completing on space, and the balance check blacklist.
* Added `g:AutoPairsAutoBreakBefore` and `g:AutoPairsSyncAutoBreakOptions` ([#57](https://github.com/LunarWatcher/auto-pairs/issues/57))
* `InsertLeavePre` is now ignored
* Regex pairs are now disabled and made opt-in only ([#53](https://github.com/LunarWatcher/auto-pairs/issues/53))
* `g:AutoPairsPrefix`, used for switching the default prefix in incompatible map mode.
* The LaTeX pairs `\[\]` and `\(\)` are supported out of the box for the `tex` filetype
* **Breaking:** regex is now disabled by default, and requires a manual parameter. See `:h autopairs-pair-object`. 
* The auto-pairs compatible maps prefix can now be adjusted with `g:AutoPairsPrefix` ([#48](https://github.com/LunarWatcher/auto-pairs/discussions/48), [#70](https://github.com/LunarWatcher/auto-pairs/issues/70))

## Meta
* Removed pre-commit
* Added a test to catch duplicate helptags

# 3.0.4
`g:AutoPairsVersion = 30063`

## Changed
* Renamed `autopairs#Variables#_InitVariables` to `autopairs#Variables#InitVariables`, as the API is now more intended for public use
* `g:AutoPairsFiletypeBlacklist` now contains `"registers"` by default, and fully prevents loading in the buffer

## Documentation

* Documented `autopairs#Variables#InitVariables()`

# 3.0.3
`g:AutoPairsVersion = 30062`

## Changed
* Enabled experimental autocmd by default; preparing for the eventual deprecation of it

# 3.0.2
`g:AutoPairsVersion = 30061`

## Meta
* Cleaned up the help documents to, hopefully, be easier to navigate.

## Removed
* `g:AutoPairsBackwardsCompat`, as it doesn't appear to have any uses at this time.

## Added
* `g:AutoPairsBSIn`
* `g:AutoPairsBSAfter`
* Troubleshooting docs for Rust

## Fixed
* Duplicate tags in help docs ([#59](https://github.com/LunarWatcher/auto-pairs/pull/59))

# 3.0.1
`g:AutoPairsVersion = 30060`

## Fixed
* Annoying escape problem ([#52](https://github.com/LunarWatcher/auto-pairs/discussions/52))
* Open == close-pairs struggled to verify balance. ([#40](https://github.com/LunarWatcher/auto-pairs/discussions/40) (discussion) and its associated issue ([#41](https://github.com/LunarWatcher/auto-pairs/issues/41)))
* Bug preventing `open: 'not empty', close: ''` from clearing output inserted by other pairs
* Typo in offset potentially breaking balancing (not sure if this was a problem before 3.0.1 or if the changes made here made it painfully obvious, but it's fixed now nonetheless)
* Add a lookahead to the regex group for single quotes in vim files. Just using `\ze` doesn't actually prevent it from matching the rest of the quote, causing weird quote insertion behavior with the changes made as a part of 3.0.1.

# 3.0.0

No changes; Purely a symbolic packaging for 3.0.0-beta13.

# 3.0.0-beta13
`g:AutoPairsVersion = 30058`

## Meta
* Code cleanup
* Vimscript standard update #1

## Added
* Skip single completion ([jiangmiao#335](https://github.com/jiangmiao/auto-pairs/issues/335))
* More tests (including tests to cover single skip)

# 3.0.0-beta12
`g:AutoPairsVersion = 30057`

## Fixed
* Better escape handing ([jiangmiao#325](https://github.com/jiangmiao/auto-pairs/issues/325))
* Typos in the help document
* Update variable list in the help document
* Add a help document covering plugin interop for specific plugins
* Bug from beta11 breaking the autopairs toggle shortcut

## Added
* `g:AutoPairsSearchEscape`

## Removed
* `g:AutoPairsShortcutMultilineClose`

# 3.0.0-beta11
`g:AutoPairsVersion = 30056`

## Fixed
* Close pair balance checks weren't up to date with new balance systems
* `g:AutoPairsStringHandlingMode` shouldn't prevent skipping characters
* Add buffer variables for keybinds ([#35](https://github.com/LunarWatcher/auto-pairs/issues/35))

## Changed
* Cleaned up the implementation of the beta9 hotpatch (AKA properly fix #30)
* Moved variable (global + buffer) declaration to a separate file to reduce clutter in `autoload/autopairs.vim`
* Tweaks to the close balance logic making it more jump-happy than previously
* Reordered method calls to reduce unnecessary synstack calls for people who don't want it
* Rolled back the change to multiline close ([#32](https://github.com/LunarWatcher/auto-pairs/issues/32))
    * `g:AutoPairsMultilineClose` is back

## Added
* Tests to reduce the chances [#30](https://github.com/LunarWatcher/auto-pairs/issues/30) occurs again
* `balancebyclose` added to pair objects ([#31](https://github.com/LunarWatcher/auto-pairs/issues/31)) to aid balancing. Also helps towards #30
* CI to auto-run tests on the three major operating systems (doesn't affect the plugin itself; only the dev process)
* `g:AutoPairsShortcutToggleMultilineClose`
* `g:AutoPairsPreferClose`

## Removed
* `autopairs#AutoPairsScriptInit()`

# Deprecated
* `g:AutoPairsShortcutMultilineClose`

# 3.0.0-beta10
`g:AutoPairsVersion = 30055`

* Some docs
* Accidental debug logging

# 3.0.0-beta9
`g:AutoPairsVersion = 30054`

## Fixed
* Broken open == close balance check ([#30](https://github.com/LunarWatcher/auto-pairs/issues/30))
* Fix single-quote edge case for balance checks
* Fix no ft edge-case for syntax checking

# 3.0.0-beta8
`g:AutoPairsVersion = 30053`

## Added
* [Meta] Testing
* `autopairs#AutoPairsAddPair()`
* `autopairs#AutoPairsAddPairs()`
* Lots of customization functionality through `:h autopairs-pair-object`. Highlights:
    * `g:AutoPairs` and `autopairs#AutoPairsAddPair` (+ `autopairs#AutoPairsAddPairs` by extension) support a `language` tag, meaning there's now a way to make all your pairs work by modifying a single variable. The language tag also takes a single language as well as a list of languages, meaning it's easy to apply a single pair to several languages.
    * The option to disable delete for individual pairs
    * The option to map a related or unrelated key to explicitly jump through the pair.
* `g:AutoPairsShortcutMultilineClose` ([#19](https://github.com/lunarwatcher/auto-pairs/issues/19), [#21](https://github.com/lunarwatcher/auto-pairs/issues/21))
* Added `g:AutoPairsExperimentalAutocmd`
* Added `g:AutoPairsStringHandlingMode`
* Added `:AutoPairsToggle`, `:AutoPairsDisable`, and `:AutoPairsEnable` (upstream [#278](https://github.com/jiangmiao/auto-pairs/issues/278), missed in the initial ticket crunch)
* Added `g:AutoPairsMoveExpression` (fixes [#25](https://github.com/LunarWatcher/auto-pairs/issues/25); an issue introduced by a fix to [#317](https://github.com/jiangmiao/auto-pairs/issues/317) that remapped from `<M-key>` to `<C-key>` (which doesn't work because input processing artifacts)).
* Explicit support for vim-visual-multi (Completely fixes [#12](https://github.com/LunarWatcher/auto-pairs/issues/12))
* Added `g:AutoPairsMultilineBackspace` ([#29](https://github.com/LunarWatcher/auto-pairs/issues/29))

## Changed
* Made `autopairs#AutoPairsDefine` accept a list as well. The list contains a different type of more powerful objects; see the documentation (autopairs-pair-object)
* Made explicit jump keys map themselves if no mappings are defined. The explicit meaning of the map may change, but it's designed not to conflict with other keys (and as such, it's designed to maintain backwards-compatibility, without breaking stuff)
* Internal: moved open pair balancing to a separate function
* Prevent an explicit close key from preventing close when it's also desired to close by the normal key
* Documentation cleanup of the troubleshooting section (copy editing, general updates, remove bad advice)
* Made `g:AutoPairsBackwardsCompat` default to 0 instead of a conditional

## Removed
* An API that gave some minor customization access to pairs. The API has been replaced with a substantially more flexible API (see `:h autopairs-pair-object` for more details; **potentially breaking**)
* `g:AutoPairsWildClosedPair` (has been unused for a long time)

## Deprecated
* `autopairs#AutoPairsScriptInit`
* `g:AutoPairsEnableMove` (deprecated in favor of `let g:AutoPairsMoveExpression = ""`)

## Fixed
* Multibyte fast wrap around vim pairs (`%`-able built-in (and manually specified) pairs)
* Make multiline reverse pair deletion opt-in (`g:AutoPairsMultilineBackspace`)

# 3.0.0-beta7
`g:AutoPairsVersion = 30052`

## Fixed
* Bug in backspace triggered by empty close not being ignored ([#22](https://github.com/LunarWatcher/auto-pairs/issues/22))
* Bug in backspace triggered by a bad comparison (causing bad `<bs>` when not deleting actual pairs, but i.e. half a pair
* Add `g:AutoPairsReturnOnEmptyOnly`

# 3.0.0-beta6
`g:AutoPairsVersion = 30051`

## Changed
* All the keybinds ([#18](https://github.com/LunarWatcher/auto-pairs/issues/18))
    - The new scheme uses largely compound keybinds: `<C-p>` as a prefix (ctrl-auto**p**airs), followed by some semi-representative ctrl keybind. `<C-p><C-s>` for jump (ctrl skip), `<C-p><C-b>` for back insert, `<C-p><C-t>` for toggling auto-pairs. `<C-f>` is for fast wrap, but note that `<C-p>` is not used for this keybind at all.
    - `let g:AutoPairsCompatibleMaps` added ([#20](https://github.com/LunarWatcher/auto-pairs/issues/20); defaults to 1 for the near foreseeable future)
* Re-disable `g:AutoPairsMultilineClose`

# 3.0.0-beta5
`g:AutoPairsVersion = 30050`

## Fixed

* Bad fast wrap when open == close and there isn't a space before open ([#17](https://github.com/LunarWatcher/auto-pairs/issues/17))
* Bad balance check caused by `if index(...)` rather than `if index(...) != -1`
* Fixed broken `foo[]|<BS>`-check (early return, bugged since the start)
* Make `foo[]|<BS>` run a multiline check in reverse

## Changed
* `g:AutoPairsVersion` no longer has a semantic meaning

# 3.0.0-beta4

## Added
* `b:AutoPairsJumpRegex`

## Fixed

* Balance checks where the open bracket is regex ([#15](https://github.com/LunarWatcher/auto-pairs/issues/15)) (`count(whatever, open) => s:regexCount(whatever, open)`)
* Manual jump now includes custom pairs ([#16](https://github.com/LunarWatcher/auto-pairs/issues/16))

# 3.0.0-beta3

## Added
* `g:AutoPairsMultilineCloseDeleteSpace`
* `g:AutoPairsMultibyteFastWrap` -- fast wrap now supports multibyte pairs
* `g:AutoPairsFiletypeBlacklist`

## Fixed

* Made the vim comment regex less awful
* `AutoPairsMultilineClose` didn't work
* `g:AutoPairsCompleteOnlyOnSpace` regex: \S is enough. Newlines appear to be stripped anyway, so EOL is fine
* Revert `g:AutoPairsMultilineClose` to 0; not sure when it changed to 1
* Corrected multiline pair regex (`'^\V'.close` -> `'\v^\s*\zs\V'.close`); not sure why it was changed in the first place, doesn't appear to be relevant for space-only autoinsert. (Objections are welcome on this one; open an issue if you disagree or if this breaks your use of the plugin)
* Slightly saner check for escaped characters

## Changed
* Made `g:AutoPairsOpenBalanceBlacklist` empty by default. Can't remember the rationale behind adding them in the first place
* [Meta] Removed old, outdated comments and add new confused ones

# 3.0.0-beta2

## Added
* Added `g:AutoPairsVersion`
* Added `g:AutoPairsBackwardsCompat`
* Backwards compat documentation
* Added `g:AutoPairsMultilineFastWrap`; also means minor, optional changes to the fast wrap system
* Added `g:AutoPairsFlyModeList`
* Added `g:AutoPairsJumpBlacklist` ([jiangmiao/313](https://github.com/jiangmiao/auto-pairs/issues/313))

## Fixed
* Incompatibility with vim-visual-multi
* Fixed weird fast wrap behavior when the closer is identical to the opener ([jiangmiao/296](https://github.com/jiangmiao/auto-pairs/issues/296))
* Try to fix issue where brackets are imbalanced on the line, but that isn't indicative of bad balancing. Primarily an issue in multiline if-else blocks, or try-catch blocks in languages like C, C++, and Java. (fix has since been fixed)
* Some function calls were not renamed (bad refactoring; [#13](https://github.com/LunarWatcher/auto-pairs/issues/13))
* Handle strgetchar() returning -1 ([#14](https://github.com/LunarWatcher/auto-pairs/issues/14))
* `g:AutoPairsCRKey` looking for expansions on `<CR>` when `g:AutoPairsCRKey` isn't `<CR>` (should look for keybinds to `g:AutoPairsCRKey` rather than just `<CR>`)
* Update to flymode pairs that unescaped values unescaped ], which _has_ to be escaped.
* Make sure g/b:AutoPairsNoJump = 1 doesn't interfere with balancing logic.

## Changed
* `autopairs#AutoPairsFastWrap` argument movement changed from a required argument to a vararg to make it optional; defaults to `e` when not supplied

# 3.0.0-beta1

## Added
* `autopairs#AutoPairsScriptInit` (dummy function for autoload; see the docs)
* `g:AutoPairsLanguagePairs` (exposed previously private API)
* `g:AutoPairsAutoLineBreak`
* `g:AutoPairsCarefulStringExpansion`, `g:AutoPairsQuotes`

## Fixed
* Load autopairs functions properly (switch primary script to autoload)
* Jump keybind and backticks ([jiangmiao/299](https://github.com/jiangmiao/auto-pairs/issues/299))
* Moved variables from the wrong section of the help document to the right section. Whoops!
* Make `g:AutoPairsOpenBalanceBlacklist` work (+ add docs)

## Changed
* Merged `b:AutoPairs` help into `g:AutoPairs`
* Added notice of the existence of a buffer variable for (hopefully) all the variables that have a buffer variant.
* Moved the movement logic in `autopairs#AutoPairReturn()` to a separate function to enable `g:AutoPairsAutoLineBreak`

# 3.0.0-alpha4

## Added
* `g:AutoPairsSearchCloseAfterSpace`
* `g:AutoPairsSingleQuoteMode`
* `g:AutoPairsSingleQuoteExpandFor`

## Fixed
* `g:AutoPairsNoJump` didn't work as intended; this has now been fixed. An if-statement in the wrong place prevented it from doing what it was meant to do; avoid jumping.
* Typo in AutoPairsDelete causing backspace errors
* Bad backslash use in character group ([#10](https://github.com/LunarWatcher/auto-pairs/pull/10))

## Changed
* Corrected documentation of AutoPairsDefine to include the optional second argument.

# 3.0.0-alpha3

## Changes
* AutoPairsFastWrap now has a parameter that decides the movement. The one mapped by default is `e`, but due to how Vim works, the argument has to be passed explicitly. (Vim 8.1 patch 1310 supports default arguments in functions, but anything before that as well as neovim would lose support). ([#8](https://github.com/LunarWatcher/auto-pairs/pull/8))

## Fixed
* `AutoPairsDefine` called `AutoPairsDefaultPairs` without `autopairs#` (missed part of the breaking change from 3.0.0-alpha2)
* Prevent issues when removing a key that doesn't exist in `AutoPairsDefine` ([#9](https://github.com/LunarWatcher/auto-pairs/pull/9))
* Fix comment regex for vimscript files ([#7](https://github.com/LunarWatcher/auto-pairs/pull/7))


# 3.0.0-alpha2

## Added
* `g:AutoPairsNoJump`
* `g:AutoPairsDirectoryBlacklist`
* `g:AutoPairsCompleteOnSpace`
* `g:AutoPairsInitHook`
* Added function documentation
* Added multibyte pair documentation
* Document `b:autopairs_enabled`
* Add more buffer variants of variables

## Changes
* [Breaking] Moved all autopair functions to have an `autopairs#` prefix

## Fixes
* Clarified the addition of pairs
* Cleaned up the define cascades with a function (3 lines -> 1 line)
* Fixed pair regex in vimscripts to better detect when quotes are likely to be comments. Largely [#7](https://github.com/LunarWatcher/auto-pairs/pull/7) (thanks to [lemeb](https://github.com/lemeb)!), but with a minor change to ignore Plug, Plugin, echo, and echoerr (where you can use double-quotes for strings, but these commands cannot have a comment on the same line -- Vimscript is weird). The changes ignoring those four commands are hackish -- improvements are welcome.

# 3.0.0-alpha1

Initial release of this fork; primarily fixes a few bugs, contains documentation updates, and merges a few pull requests of varying sizes. The changelog wasn't added until 3.0.0-alpha2, which means the changes here weren't properly tracked.
