" detect file types
" See: C:\Old\tsk\vim\vimfiles\filetype.vim

augroup filetypedetect

    autocmd! BufNewFile,BufRead *
        \ if isdirectory(expand('%')) |
        \     setfiletype directory |
        \ endif

    autocmd! BufNewFile,BufRead *
        \ if getline(1) =~ '<?\s*xml.*?>' |
        \   setfiletype xml |
        \ endif

augroup end
