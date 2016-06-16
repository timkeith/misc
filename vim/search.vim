if &compatible
    echo "search.vim is not vi-compatible; you need to :set nocompatible"
    finish
endif

" Highlight text in visual mode then hit / to search for that text.
" If you highlight right to the end of line it will only match at end of line.
" This supercedes normal meaning of / in visual mode.
Help 'v / - search for highlighted pattern'
vnoremap / :<c-u>call <SID>SearchVisual()<cr>
function! <SID>SearchVisual()
    if line("'<") != line("'>")
        echohl WarningMsg
        echo 'Cannot search for multi-line pattern'
        echohl None
        return
    endif
    let save = @@
    normal! gvy
    let pat = @@
    let @@ = save
    " escape characters that are special in searches; there are probably more
    let pat = escape(pat, '[].*\$')
    " replace end-of-line with $
    let pat = substitute(pat, nr2char(10), '$', '')
    call histadd('/', pat)
    let @/ = pat
    normal! n
endfunction
