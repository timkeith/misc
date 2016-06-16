" Syntax for output of ls
syntax clear

syntax match lsComment ".*:$"
"syntax match lsDirectory "\S\+/"
syntax match lsDirectory "[^/]\+/\(\s\|$\)"

if !exists("did_ls_syntax_inits")
    let did_ls_syntax_inits = 1
    highlight link lsComment Comment
    highlight link lsDirectory Directory
endif

let b:current_syntax = 'ls'
