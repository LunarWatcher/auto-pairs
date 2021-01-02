" Insert or delete brackets, parens, quotes in pairs.
" Fork Maintainer: Olivia
" Version: 3.0.0-alpha5
" Fork Repository: https://github.com/LunarWatcher/auto-pairs
" License: MIT

if exists('g:AutoPairsLoaded') || &cp
    finish
end
let g:AutoPairsLoaded = 1

au BufEnter * :call autopairs#AutoPairsTryInit()

" vim:sw=4
