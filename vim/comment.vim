" # comments selected lines (or uncomments if first is commented)
vmap # :<c-u>call Comment("'<", "'>")<cr>

function! Comment(start, end)
    let start = a:start =~ '^\d*$' ? a:start : line(a:start)
    let end = a:end =~ '^\d*$' ? a:end : line(a:end)
    let start = nextnonblank(start)
    let end = prevnonblank(end)
    let comment = escape(GetCommentStr(), '\/')

    let range = start . "," . end
    if match(getline(start), "^\\s*" . comment) == 0
        " uncomment
        exec range . "s/^\\(\\s*\\)" . comment . "/\\1/"
    else
        exec range . "s/^/" . comment . "/"
    endif
endfunction

" Return the line-comment string for this file type
function! GetCommentStr()
    let comment_strs = {
        \ 'c': '//', 'cpp': '//', 'java': '//', 'groovy': '//', 'scala': '//',
        \ 'javascript': '//', 'dart': '//', 'idl': '//', 'jade': '//', 'less': '//',
        \ 'vim': '"',
        \ 'dosbatch': '::',
        \ 'autohotkey': ';',
    \ }
    return get(comment_strs, &filetype, '#')
endfunction
