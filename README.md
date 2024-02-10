# Auto Pairs

[![Tests](https://github.com/LunarWatcher/auto-pairs/actions/workflows/tests.yml/badge.svg)](https://github.com/LunarWatcher/auto-pairs/actions/workflows/tests.yml)
[![Minimum Vim version 8.1 patch 1114](https://img.shields.io/badge/Vim-8.1%201--1114%20or%20newer-%23FFC0CB?logo=vim&labelColor=019833)](//github.com/vim/vim)

Insert or delete brackets, parens, and quotes in pair: a maintained fork of [jiangmiao/auto-pairs](https://github.com/jiangmiao/auto-pairs)

## Note to migrating users

If you're migrating from jiangmiao's version, it's highly recommended that you read `:h autopairs-migrating` after installing. There have been a number of breaking changes made in this fork, as well as changes to default behavior. See the migration guide for important differences that are may affect your workflow.

## Installation


**NOTE:** Auto-pairs currently requires at least vim 8.1 with patch 1114. See [#37](https://github.com/LunarWatcher/auto-pairs/discussions/37)

There's several installation methods, and you're free to use whatever you want, but I personally cannot recommend [vim-plug](https://github.com/junegunn/vim-plug) enough, in part because of the previous line of text. Installation, if you expect a more or less working variant, should be done with:

```vim
Plug 'LunarWatcher/auto-pairs'
```
You can also specify a tag, but this is no longer needed as of the release of 3.0.0.

To use experimental changes before they're deployed, use:
```vim
Plug 'LunarWatcher/auto-pairs', {'branch': 'develop'}
```

**Note:** As of 4.0.0, `let g:AutoPairsCompatibleMaps = 0` is the default. Set the variable to 1 to use jiangmiao-compatible keybinds.

## Running tests (not required)

Auto-pairs comes with a few tests aimed at making sure nothing accidentally regresses without manually testing everything. Tests are in the test folder, and are in the vimspec format (using [themis.vim](https://github.com/thinca/vim-themis)); follow its instructions to run the tests.

Some plugins may interfere with the tests and cause erroneous failures, but the CI is generally indicative of the general state of auto-pairs. If it fails locally, that may be an indication of a plugin incompatibility (though these are often possible to fix)

### Versioning system (meta)

This project roughly uses [semantic versioning](https://semver.org/spec/v2.0.0.html), with the minor exception that major version bumps may not be breaking in the sense that everything breaks, but introduces a set of features that significantly changes auto-pairs' functionality.

Breaking API changes that affect code compatibility will never happen outside major version bumps (looking aside bugs). Additionally, the master branch is the main development branch and may therefore periodically break. While I do as many tests as I can before I push, there may still be bugs introduced on the main branch. If you want a stable (ish) experience, stick to tags. If you want updates when they're released, stick to the master branch.

## Differences from jiangmiao

At this point, there's far too many differences to list all of them. Aside removing some variables (such as remapping `<C-h>`), and tweaking defaults, many additional variables have been added. Including changes by Krasjet, here's a short list of some of the things this fork does that upstream doesn't:

* Option for inserting pairs only if there's whitespace
* Option for automatic linebreaks for some openers
* Built-in support for language-specific pairs
* Option for searching for closers after space (jiangmiao always did this, Krasjet never did this)
* Option for entirely disabling jump
* Option for a pre-init hook
* Option for disabling in some directories
* Options for single-quote handling around text
* QOL improvements for matching
* Balance checks with advanced modes (See `:h g:AutoPairsStringHandlingMode`)
* ... Lots of bugfixes and general improvements
* Better standards
* Support and continued development :)

The entire list is too long to place in its entirety here -- the documentation should cover all the variables, so reading it should give you a complete idea of the changes.

### Compatibility

Quite a lot of code compatibility was thrown out the window with a massive change that moved the plugin to be partially autoloaded. This mainly leads to improvements in terms of making it easier to customize (i.e. `autopairs#AutoPairsDefine` is available without an autocmd now). Additionally, it makes sure to reduce the chance of a conflict between functions.

Functionally, however, it's meant to resemble upstream as much as possible, partly to make migration less annoying for people with lots of customization.

## Goals
* Improving on jiangmiao's original code
* Updating the plugin with long-requested features
* ... and with new ones.
* Increased customizability


## Non-goals
* Being a drop-in snippet replacement -- use UltiSnips or lexima.vim instead.
* Supporting very old versions of Vim
* HTML support: hardcoding HTML tags works, but writing a tag autoinserter requires substantial rewrites to the core engine. Instead, may I introduce you to [Tim Pope](https://github.com/tpope/vim-ragtag)? Or alternatively [alvan](https://github.com/alvan/vim-closetag)?

## Features


* Obviously, the insertion and deletion of pairs (note that deletion is disabled by default. See `:h g:AutoPairsMapBS`)
* An enter mapping for pair expansion
* Quote handling aimed at avoiding accidental expansions
* The ability to ignore pair insertion unless there's a whitespace (`:h autopairs-howto-whitespace-only`)
* Extended balance checks
* Fast pair wrapping
* Several customisable features for various personal preferences

For more features, as well as documentation, [see doc/AutoPairs.txt](https://github.com/LunarWatcher/auto-pairs/blob/master/doc/AutoPairs.txt)

## Contributors
See [Contributors](https://github.com/lunarwatcher/auto-pairs/graphs/contributors)

## License

The code is licensed under the MIT license. See [LICENSE.md](https://github.com/LunarWatcher/auto-pairs/blob/master/LICENSE.md) for the full license text.
