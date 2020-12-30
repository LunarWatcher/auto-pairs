# Auto Pairs

Insert or delete brackets, parens, quotes in pair.

NOTE: This plugin is currently under the process of catching up with [a few years of unreviewed issues and pull requests](https://github.com/LunarWatcher/auto-pairs/issues/5). Effective now, it's highly recommended 

## Installation

There's several installation methods, and you're free to use whatever you want, but I personally cannot recommened [vim-plug](https://github.com/junegunn/vim-plug) enough, in part because of the previous line of text. Installation, if you expect a more or less working variant, should be done with:

```vim
Plug 'LunarWatcher/auto-pairs', { 'tag': '*' }
```
(... = from Lunarwatcher/auto-pairs, pull the latest tag matching '*' -- a wildcard, which means the latest tag)

If you're fine with risking breaking changes and the plugin being literally unusable, use the master branch instead:

```vim
Plug 'LunarWatcher/auto-pairs'
```
... but know that if it breaks, you were warned. Some bugs may still leak into the tags, but there will be significantly fewer.

## Differences from jiangmiao

This version contains a few updates that were never merged into the upstream repo. Additionally, it includes Krasjet's improvements, though with some extra tweaks.

The following tweaks have been made (relative to both Krasjet and jiangmiao):

* `g:AutoPairsCompleteOnSpace` determines whether or not a closing pair should be inserted only when there's a space. 1 = space required, 0 = always insert pair
* `g:AutoPairsMapCh` has been deleted. If you need to map a key that isn't backspace for bracket pair deletion, map one yourself.

Additionally, there's a few potential plans that may or may not be implemented at some point (AKA depending on whether or not I'm in the mood for vimscript):
* ["Endwise rules"](https://github.com/cohama/lexima.vim), possibly in combination with an extended ruleset, without changing core functionality
* More flexibility for file-specific rules: some people might want to autoinsert &lt;&gt;, unless it's in a language like shell, where &lt; and &gt; aren't required to be in pairs.
* Code cleanup: aside formatting (never been a fan of 2 spaces to indent), try to reduce verbosity by introducing functions.

A couple of these will have to wait until I properly understand the code; I have at least 9 years of development to catch up with, and while there isn't that much code, I'm far from proficient enough in Vimscript to just jump in. I've also naturally missed out on several issues explaining why some bit sof the plugin are  the way they are.

Finally, this fork has an additional goal: bringing the plugin back to life. I've already merged in 3 PRs to jiangmiao/auto-pairs that were never handled. The current plan is to handle a few issues as well. If it's a FR and it's reasonable, do it. If it's a bug and I can repro in the current state of the project, fix it.

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
Copyright (C) 2020 Olivia Zoe

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
