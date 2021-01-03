# Auto Pairs

Insert or delete brackets, parens, and quotes in pair.

## Installation

There's several installation methods, and you're free to use whatever you want, but I personally cannot recommened [vim-plug](https://github.com/junegunn/vim-plug) enough, in part because of the previous line of text. Installation, if you expect a more or less working variant, should be done with:

```vim
Plug 'LunarWatcher/auto-pairs', { 'tag': '*' }
```
(... = from Lunarwatcher/auto-pairs, pull the latest tag matching '*' -- a wildcard, which means the latest tag)

You can also use the latest commit, though tags are recommended:

```vim
Plug 'LunarWatcher/auto-pairs'
```

## Differences from jiangmiao

At this point, there's far too many differences to list all of them. Aside removing some variables (such as remapping `<C-h>`), and tweaking defaults, many additional variables have been added. Including changes by Krasjet, here's a short list of some of the things this fork does that upstream doesn't:

* Option for inserting pairs only if there's whitespace
* Option for automatic linebreaks for some openers
* Built-in support for language-specific pairs
* Option for searching for closers after space (jiangmiao always did this, Krasjet never did this)
* Option for entirely disabling jump
* Option for a pre-init hook
* Option for disabling in some directories
* ... Lots of bugfixes and general improvements

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
