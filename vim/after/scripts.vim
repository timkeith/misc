" filetypes detected by file contents
" Note that StartPage in vimrc.vim has some special handling too
if did_filetype()
    finish
endif
let s:line1 = getline(1)
echo "??? s:line1 = <".s:line1.">"
let s:line2 = getline(2)
if s:line1 =~# '^#!.*/bin/env\s\+coffee\>'
    setfiletype coffee
elseif s:line1 =~ '^=== ' && s:line1 !~ '.==='
    setfiletype diff
elseif s:line2 =~ '^=== ' && s:line2 !~ '.==='
    setfiletype diff
elseif s:line1 =~ '-\*- perl -\*-'
    setfiletype perl
elseif s:line1 =~ '<?xml'
    set filetype=xml
endif
