# auto.pairs

A fork of the [auto-pairs](https://github.com/jiangmiao/auto-pairs) plugin for vim with more sensible auto-completion rules. This fork is currently only intended to be used by myself. If you want to know how to use the plugin, please read the [original readme](https://github.com/jiangmiao/auto-pairs).

## Installation

With `vim-plug`

```vim
Plug 'Krasjet/auto.pairs'
```

## Main changes

Basic principle: auto-completion and jump should be as lazy as possible,
because **correcting** one completion mistake would take more keystrokes than
closing the pair manually.

- Only insert the closing pair if the next character is a space or a non-string
  closing character.
```
input: | s    (press '(')
output: (|) s

input: |s    (press '(')
output: (|s

input: (|)    (press '(')
output: ((|))

input: (|)    (press '[')
output: ([|])

input: '|'    (press '[')
output: '[|'
```

All the string characters can be set as a global variable `g:StringClosingChar`
or buffer variable `b:StringClosingChar`.
```vim
let g:StringClosingChar = \['"', \"'",'\`'\]
let b:StringClosingChar = \['"', \"'",'\`'\]
```
If the next character of the cursor is any of these characters, auto-completion
will be inhibited.

- Do not search for the closing pair if spaces are in between
```
input: " | "    (press '"')
output: " "| "

input: " |"    (press '"')
output: " "|
```

- Only jump across the closing pair if pairs are balanced
```
input: (((|))    (press ')')
output: (((|)))

input: (((|)))    (press ')')
output: ((()|))
```

- Do not complete the closing pair until pairs are balanced
```
input: ((|)))    (press '(')
output: (((|)))

input: (((|)))    (press '(')
output: ((((|))))
```

More to be added when I encounter more problems.

## Side note

I am using the plugin with the multi-line close option set to false.

```vim
let g:AutoPairsMultilineClose = 0
```

This fork might break it (and the fly mode, which is disabled by default), but I don't need them anyways.

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
