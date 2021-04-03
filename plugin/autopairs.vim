" Insert or delete brackets, parens, quotes in pairs.
" Fork Maintainer: Olivia
" Version: See g:AutoPairsVersion, or the git tag 
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
    let g:AutoPairsBackwardsCompat = 0
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

if exists('g:AutoPairsExperimentalAutocmd') && g:AutoPairsExperimentalAutocmd
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

" Plugin compatibility

" https://github.com/mg979/vim-visual-multi
if exists('g:VM_plugins_compatibilty') || exists('*vm#maps#init')
    " The test doesn't include any of the `exists`s, because it's pretty damn
    " obvious that they exist when the plugin creating them is setting it.
    " No need for those checks when it's set like this.
    let g:VM_plugins_compatibilty = extend(get(g:, 'VM_plugins_compatibilty', {}), {
        \'AutoPairs': {
                \   'test': { -> b:autopairs_enabled },
                \   'enable': 'unlet b:autopairs_loaded | call autopairs#AutoPairsTryInit() | let b:autopairs_enabled = 1',
                \   'disable': 'let b:autopairs_enabled = 0',
                \}
        \})
endif

" vim:sw=4:expandtab
