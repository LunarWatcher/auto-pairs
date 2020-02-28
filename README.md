# auto.pairs

A fork of the [auto-pairs](https://github.com/jiangmiao/auto-pairs) plugin for
vim with more sensible auto-completion rules. This fork is currently only
intended to be used by myself. If you want to know how to use the plugin,
please read the [original readme](https://github.com/jiangmiao/auto-pairs).

Since auto-pairing can be extremely subjective, if you are unsatisfied with
your own auto-pairing configurations, I would suggest you read the
[survey](https://github.com/Krasjet/auto.pairs#a-survey-on-similar-plugins)
below. Pick one of the plugins, make a fork and customize it to your liking.
The issues listed below should be enough to get you started.

Of course, if you want to use
[auto-pairs](https://github.com/jiangmiao/auto-pairs), the comments in my
[auto-pairs.vim](https://github.com/Krasjet/auto.pairs/blob/master/plugin/auto-pairs.vim)
might be helpful (search for `Krasjet`).

## Installation

With `vim-plug`

```vim
Plug 'Krasjet/auto.pairs'
```

## Main changes

Basic principles: auto-completion and jump should be as lazy as possible,
because **correcting** one completion mistake would take more keystrokes than
closing the pair manually.

- Only insert the closing pair if the next character is a space or a non-string
  closing character.
```
input:  | s    (press '(')
output: (|) s

input:  |s     (press '(')
output: (|s

input:  (|)    (press '(')
output: ((|))

input:  (|)    (press '[')
output: ([|])

input:  '|'    (press '[')
output: '[|'
```

All the string characters can be set as a global variable `g:AutoPairsQuoteClosingChar`
or buffer variable `b:AutoPairsQuoteClosingChar`.
```vim
let g:AutoPairsQuoteClosingChar = \['"', \"'",'\`'\]
let b:AutoPairsQuoteClosingChar = \['"', \"'",'\`'\]
```
If the next character of the cursor is any of these characters, auto-completion
will be inhibited.

- Do not search for the closing pair if spaces are in between
```
input:  " | "    (press '"')
output: " "| "

input:  " |"     (press '"')
output: " "|
```

- Only jump across the closing pair if pairs are balanced
```
input:  (((|))     (press ')')
output: (((|)))

input:  (((|)))    (press ')')
output: ((()|))
```

- Do not complete the closing pair until pairs are balanced
```
input: ((|)))      (press '(')
output: (((|)))

input: (((|)))     (press '(')
output: ((((|))))

input:  "str|      (press '"')
output: "str"|
```

- The default value of `g:AutoPairsMultilineClose` has been changed to 0.
If you want to enable it, set
```
let g:AutoPairsMultilineClose = 1
```
but be cautious that this fork might break it (and the fly mode, which is also
disabled by default), but I haven't tested them, and I don't need them anyways.

More to be added when I encounter more problems.

## A survey on similar plugins

### [auto-pairs](https://github.com/jiangmiao/auto-pairs)

The one I'm most familiar with, despite some minor annoyances. This is why
the fork is based on this plugin. However, this plugin has too many mappings
that I don't need, such as `<M-e>`, `<M-n>`, and the fly mode.

#### Issues

```
// settings
let g:AutoPairsMultilineClose = 0

// before character
input:  |s         (press '(')
output: (|)s
// inside quote
input:  '|'        (press '[')
output: '[|]'
// seach for closing pair
input:  " | "      (press '"')
output: " "|
// closing pair balance
input:  (((|))     (press ')')
output: ((()|)
// open pair balance
input:  ((|)))     (press '(')
output: (((|))))
// open pair balance
input:  "str|      (press '"')
output: "str"|"
```

### [pear-tree](https://github.com/tmsvg/pear-tree)

I would say I'm pretty impressed with the smart pairing of this plugin. You can
even set completion rules based on syntax groups. There are still some minor
issues, though. One issue is that I never got the `g:pear_tree_smart_backspace`
working. Also, if `g:pear_tree_repeatable_expand` is enabled, the closing braces
will disappear after a line break, which can be quite annoying.

#### Issues

```
// settings
let g:pear_tree_smart_openers = 1
let g:pear_tree_smart_closers = 1
let g:pear_tree_smart_backspace = 1
let g:pear_tree_repeatable_expand = 0

// backspace (might be a bug in smart backspace)
input:  (|)       (press '<bs>')
output: |)
// open pair balance
input:  ((|)))    (press '(')
output: (((|))))
```

### [coc-pairs](https://github.com/neoclide/coc-pairs)

One of the biggest drawback is that this plugin has to be installed on top of
[coc.nvim](https://github.com/neoclide/coc.nvim), which can make your vimrc
less portable, but if you are already using coc.nvim for auto-completions, it
can be an option. However, do notice that there are several minor issues (but
in the case of auto-completion, minor annoyances can be exaggerated).

#### Issues

```
// inside quote
input:  '|'    (press '[')
output: '[|]'
// closing pair balance
input:  (((|))    (press ')')
output: ((()|)
// open pair balance
input:  ((|)))    (press '(')
output: (((|))))
// multiple character opening (very wierd)
input:  `|`           (press '`')
output: ``|           (press '`')
        ```|          (press '`')
        ```|```       (press '`')
        ```|``````    (press '`')
// <cr> mapping
input:
   """|"""    (press '<cr>')
output:
   """
  |"""
```

### [UltiSnips](https://github.com/SirVer/ultisnips)

It is possible to set up some snippets for auto pairing, e.g.
```snippet
snippet ( "()" iA
($1)$0
endsnippet
```
Since you can use regex and scripting in UltiSnips, it can be very powerful.
However, there is no mechanism for deleting pairs, which can be very critical.

### [delimitMate](https://github.com/Raimondi/delimitMate)

This plugin is extremely customizable. The number of options can be very
overwhelming (with regular expressions). The smart pairing rules are also
fairly good.

#### Issues

However, there is one critical issue. I don't think it support multi-byte
opening/closing pair very well. For example,

```
// setting
let delimitMate_expand_cr = 1
let delimitMate_balance_matchpairs = 1
let delimitMate_nesting_quotes = ['"','`']
let delimitMate_quotes = "\" ' ` * **"

// multi-byte
input:  |        (press '**')
output: ***|*
// multi-byte
input:  |        (press '*', wait)
output: *|*      (press '*', wait)
        **|
```
It will add a `imap` for `**`, which will cause some delay when you type `*`.
In addition, there are some other problems,

```
// inside quote
input:  '|'        (press '[')
output: '[|]'
// closing pair balance
input:  (((|))     (press ')')
output: ((()|)
// <cr> mapping
input:
   """|"""    (press '<cr>')
output:
   """
  |"""
```

### [lexima.vim](https://github.com/cohama/lexima.vim)

The completion and deletion are based on "rules", which can be very
customizable, but the default rules are not very smart, so it can take some
time to properly set it up.

#### Issues

```
// before character
input:  |s         (press '(')
output: (|)s
// inside quote
input:  '|'        (press '[')
output: '[|]'
// open pair balance
input:  ((|)))     (press '(')
output: (((|))))
// open pair balance
input:  "str|      (press '"')
output: "str"|"
// <cr> mapping
input:
   """|"""    (press '<cr>')
output:
   """
  |"""
```


## License

```
Copyright (C) 2011-2013 Miao Jiang
Copyright (C) 2020 Krasjet

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
