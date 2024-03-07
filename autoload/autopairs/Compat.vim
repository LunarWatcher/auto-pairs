" Plugin compatibility hacks, one function per hack
" Called from VimEnter autocmd in plugin/autopairs.vim

" https://github.com/mg979/vim-visual-multi
" NOTE: the typo does NOT stem from auto-pairs; blame vim-visual-multi for
" that.
" If it ever changes, this will break. if it does, this is where to look to
" fix it.
fun! autopairs#Compat#visualMulti()
    if exists('g:VM_plugins_compatibilty') || exists('*vm#maps#init')
        " The test doesn't include any of the `exists`s, because it's pretty damn
        " obvious that they exist when the plugin creating them is setting it.
        " No need for those checks when it's set like this.
        let g:VM_plugins_compatibilty = extend(get(g:, 'VM_plugins_compatibilty', {}), {
            \'AutoPairs': {
                    \   'test': { -> 1 },
                    \   'enable': 'unlet b:autopairs_loaded | call autopairs#AutoPairsTryInit() | let b:autopairs_enabled = 1',
                    \   'disable': 'let b:autopairs_enabled = 0',
                    \}
            \})
    endif
endfun
