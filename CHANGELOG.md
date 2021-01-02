# 3.0.0-alpha5

## Added
* `autopairs#AutoPairsScriptInit` (dummy function for autoload; see the docs)
* `g:AutoPairsLanguagePairs` (exposed previously private API)

## Fixed
* Load autopairs functions properly (switch primary script to autoload)
* Jump keybind and backticks ([#299](https://github.com/jiangmiao/auto-pairs/issues/299))

# 3.0.0-alpha4

## Added
* `g:AutoPairsSearchCloseAfterSpace`
* `g:AutoPairsSingleQuoteMode`
* `g:AutoPairsSingleQuoteExpandFor`

## Fixed
* `g:AutoPairsNoJump` didn't work as intended; this has now been fixed. An if-statement in the wrong place prevented it from doing what it was meant to do; avoid jumping.
* Typo in AutoPairsDelete causing backspace errors
* Bad backslash use in character group ([#10](https://github.com/LunarWatcher/auto-pairs/pull/10))

## Changes
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

