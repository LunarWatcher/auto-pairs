# Auto Pairs
[![Tests](https://github.com/LunarWatcher/auto-pairs/actions/workflows/tests.yml/badge.svg)](https://github.com/LunarWatcher/auto-pairs/actions/workflows/tests.yml)

Insert or delete brackets, parens, and quotes in pair: a maintained fork of [jiangmiao/auto-pairs](https://github.com/jiangmiao/auto-pairs)

## Installation

There's several installation methods, and you're free to use whatever you want, but I personally cannot recommend [vim-plug](https://github.com/junegunn/vim-plug) enough, in part because of the previous line of text. Installation, if you expect a more or less working variant, should be done with:

```vim
Plug 'LunarWatcher/auto-pairs', { 'tag': '*' }
```
(... = from Lunarwatcher/auto-pairs, pull the latest tag matching '*' -- a wildcard, which means the latest tag)

You can also use the latest commit, though tags are recommended:

```vim
Plug 'LunarWatcher/auto-pairs'
```

**Note:** I highly recommend using `let g:AutoPairsCompatibleMaps = 0` with this plugin. Setting it to 0 changes various mappings to use a control-based variant rather than a meta-based variant. This is to prevent issues with various alt combinations also being letters on the keyboard layout, as well as keeping things consistent if new maps are added (new maps will largely not use meta-based keybinds).

## Running tests (not required)

Auto-pairs comes with a few tests aimed at making sure nothing accidentally regresses without manually testing everything. Tests are in the test folder, and are in the vimspec format (using [themis.vim](https://github.com/thinca/vim-themis)); follow its instructions to run the tests.

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

Note that this section is currently out of date.

`|` represents the cursor.

*   Insert in pair

        input: [
        output: [|]

*   Delete in pair

        input: foo[<BS>]
        output: foo

*   Insert new indented line after Return

        input: {|} (press <CR> at |)
        output: {
            |
        }          (press } to close the pair)
        output: {
        }|         (the inserted blank line will be deleted)


*   Insert spaces before closing characters, only for [], (), {}

        input: {|} (press <SPACE> at |)
        output: { | }

        input: {|} (press <SPACE>foo} at |)
        output: { foo }|

        input: '|' (press <SPACE> at |)
        output: ' |'

*   Skip ' when inside a word

        input: foo| (press ' at |)
        output: foo'

*   Skip closed bracket.

        input: []
        output: []

*   Ignore auto pair when previous character is \

        input: "\'
        output: "\'"

*   Fast Wrap

        input: |[foo, bar()] (press (<M-e> at |)
        output: ([foo, bar()])

*   Quick move char to closed pair

        input: (|){["foo"]} (press <M-}> at |)
        output: ({["foo"]}|)

        input: (|)[foo, bar()] (press (<M-]> at |)
        output: ([foo, bar()]|)

*   Quick jump to closed pair.

        input:
        {
            something;|
        }

        (press } at |)

        output:
        {

        }|

*  Fly Mode

        input: if(a[3)
        output: if(a[3])| (In Fly Mode)
        output: if(a[3)]) (Without Fly Mode)

        input:
        {
            hello();|
            world();
        }

        (press } at |)

        output:
        {
            hello();
            world();
        }|

        (then press <M-b> at | to do backinsert)
        output:
        {
            hello();}|
            world();
        }

        See Fly Mode section for details

*  Multibyte Pairs

        Support any multibyte pairs such as <!-- -->, <% %>, """ """
        See multibyte pairs section for details

For more features, as well as documentation, [see doc/AutoPairs.txt](https://github.com/LunarWatcher/auto-pairs/blob/master/doc/AutoPairs.txt)

## Contributors
See [Contributors](https://github.com/lunarwatcher/auto-pairs/graphs/contributors)

## License

```
Copyright (C) 2011-2013 Miao Jiang
Copyright (C) 2020 Krasjet
Copyright (C) 2021 Olivia Zoe

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
