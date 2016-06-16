" My default syntax stuff
exec "autocmd Syntax txt source " . expand("<sfile>:h") . "/txt.vim"
exec "autocmd Syntax log source " . expand("<sfile>:h") . "/log.vim"
exec "autocmd Syntax ls source " . expand("<sfile>:h") . "/ls.vim"

highlight BoldMsg      gui=bold
highlight Statement    gui=NONE guifg=Blue
highlight Type         gui=NONE guifg=Blue
highlight Structure    gui=NONE guifg=Blue
highlight StorageClass gui=NONE guifg=Blue
highlight Boolean      gui=NONE guifg=Blue
highlight Constant     gui=NONE guifg=Blue
highlight Include      gui=NONE guifg=Blue
highlight Preproc      gui=NONE guifg=Blue
highlight Macro        gui=NONE guifg=Blue
highlight String       gui=NONE guifg=Brown
highlight Comment      gui=NONE guifg=DarkGreen
highlight Number       guifg=fg
highlight Title        gui=bold guifg=#6666CC
" Color used to highlight search matches
highlight Search       guibg=#c0c0c0
" Color used to highlight in visual mode
highlight Visual       guibg=#f0f0f0

" cursor itself - magenta
highlight Cursor       guifg=white guibg=magenta

" line with cursor when cursorline is set - light magenta
"NOTE: clashes with red from error
highlight CursorLine   guibg=#f8f8f8
"highlight CursorLine   gui=underline guibg=white

" This is for ~ and @ at end of window and chars from 'showbreak'.
highlight NonText gui=bold guifg=#aaaaff

" Default is guibg=Red guifg=White
" That doesn't work well with Cursorline
highlight Error gui=bold guifg=Red guibg=White
