" Syntax for txt files
syntax clear

syntax match txtComment "#.*"

if !exists("did_txt_syntax_inits")
    let did_txt_syntax_inits = 1
    highlight link txtComment Comment
endif

let b:current_syntax = "txt"
