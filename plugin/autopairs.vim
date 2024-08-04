" Insert or delete brackets, parens, quotes in pairs.
" Fork Maintainer: Olivia
" Version: See g:AutoPairsVersion, or the git tag
" Fork Repository: https://github.com/LunarWatcher/auto-pairs
" License: MIT

if exists('g:AutoPairsLoaded') || &cp
    finish
end

if !has('nvim') && has('vimscript-4')
    scriptversion 4
endif

let g:AutoPairsLoaded = 1

if !exists('g:AutoPairsExperimentalAutocmd') || g:AutoPairsExperimentalAutocmd
    au BufWinEnter * :call autopairs#AutoPairsTryInit()
else
    au BufEnter * :call autopairs#AutoPairsTryInit()
endif


" There's already a keybind for toggle
command! AutoPairsToggle call autopairs#AutoPairsToggle()

" These don't have keybinds, as toggle is (realistically speaking) more likely
" to be used through a keybind declared by auto-pairs than these two.
" Could consider adding keybinds if it's used heavily that way, but future
" problem and so on.
command! AutoPairsDisable let b:autopairs_enabled = 0 | echo "Disabled auto-pairs"
command! AutoPairsEnable let b:autopairs_enabled = 1 | echo "Enabled auto-pairs"

" Plugin compatibility, see autoload/autopairs/Compat.vim
autocmd VimEnter *
    \ call autopairs#Compat#visualMulti()

" vim:sw=4:expandtab
