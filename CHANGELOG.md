
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

