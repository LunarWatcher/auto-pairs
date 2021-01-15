" Insert or delete brackets, parens, quotes in pairs.
" Fork Maintainer: Olivia
" Version: 3.0.0-beta3
" Fork Repository: https://github.com/LunarWatcher/auto-pairs
" License: MIT

if exists('g:AutoPairsLoaded') || &cp
    finish
end
let g:AutoPairsLoaded = 1

" Try to do a sane default for backwards compat.
" For now, the only known incompatibility is with vim_visual_multi
" This doesn't override anything specific, so it can be disabled entirely if
" this behavior isn't desired.
if !exists("g:AutoPairsBackwardsCompat")
    let g:AutoPairsBackwardsCompat = exists("g:loaded_visual_multi") || exists("*vm#maps#init")
endif

" Expose backwards compat API if and only if it's enabled.
" At this time, I'm only aware of one function used by other plugins that
" needs to be exposed for compatibility.
" If there are other functions, please open an issue or submit a PR
if g:AutoPairsBackwardsCompat
    fun! AutoPairsTryInit()
        call autopairs#AutoPairsTryInit()
    endfun
endif

au BufEnter * :call autopairs#AutoPairsTryInit()

" vim:sw=4:expandtab
