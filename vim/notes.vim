" These assume that do_notes.pl is on the path

" Do "Copy As Document Link" in notes then execute this to insert a
" reference with notes:// url.
nnoremap ,nc :read !do_notes.pl -create<cr>

" Get "notes:" url under cursor and open with notes
nnoremap ,no :call DoNotesOpen()<cr>
function! DoNotesOpen()
    let url = expand('<cfile>')
    if url !~? '^notes:'
        echohl WarningMsg
        echo 'Cursor is not on a "Notes:" url'
        echohl None
    endif
    call DoNotesUrl(url)
endfunction

" Open the "notes:" url
function! DoNotesUrl(url)
    call system('do_notes.pl -open "' . a:url . '"')
endfunction
