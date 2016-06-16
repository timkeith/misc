" Edit directories in vim

" Problem: when exploring, call TempWin(), then "e <file>" from there.
" Stuff from explorer doesn't get restored (maps, etc.).


augroup explorer
    autocmd!
    autocmd BufEnter * nested   call Explore()
    autocmd BufEnter _explorer_ call ExploreStart()
augroup end

" ex - start explorer on dir of current file
nmap ex gU:call Edit(expand("%:p:h") . "\\_explorer_")<cr>

function! ExploreHelp()
    echo "^R    - refresh"
    echo "<cr>  - edit file or directory"
    echo "-     - goto parent directory"
    echo "<del> - delete current file"
    echo "dd    - same"
    echo "r     - rename current file"
    echo "f     - find file"
    echo "x     - execute current file"
    echo "A     - display date & size"
    echo "C     - display clearcase attributes"
    echo ",C    - display clearcase info for current file"
    echo "!     - start cmd interpreter in this dir"
    echo "?     - produce this message"
endfunction

function! Explore()
    let path = expand("%:p")
    if isdirectory(path)
        call Edit(substitute(path, '\\*$', '\\_explorer_', ''))
    endif
endfunction

"TODO: should "i" switch modes so it stays until doing i again?
"TODO: fix help

function! ExploreStart()
    call ExplorerSyntax()
    "Note: SaveMap does nnoremap
    let b:buf_restore = ''
        \ . SaveMap("<cr>",  ":call DoGF()<cr>")
        \ . SaveMap("-",     ":call ExploreFile('..')<cr>")
        \ . SaveMap("p",     ":exec 'split ' . ExploreGetFile()<cr>")
        \ . SaveMap("<del>", ":call ExploreDeleteFile()<cr>")
        \ . SaveMap("dd",    ":call ExploreDeleteFile()<cr>")
        \ . SaveMap("r",     ":call ExploreRenameFile()<cr>")
        \ . SaveMap("x",     ":echo system('explorer \"' . ExploreGetFile() . '\"')<cr>")
        \ . SaveMap("cp",    ":let @* = expand('%:p:h')<cr>:echo @*<cr>")
        \ . SaveMap("i",     ":call ExploreDisplay(line('.'), 2)<cr>zb")
        \ . SaveMap("?",     ":call ExploreHelp()<cr>")

    "let b:buf_restore +=
    "    \ . SaveMap("<c-r>", ":call ExploreDisplay(line('.'))<cr>zb")
    "    \ . SaveMap("<c--r>",  ":call ExploreFile(ExploreGetFile())<cr>")
    "    \ . SaveMap("f",     ":call ExploreFindFile()<cr>")
    "    \ . SaveMap("cd",    ":call ExploreChdir()<cr>")
    "    \ . SaveMap("p",     ":call ExploreChdir()<cr>")
    "    \ . SaveMap("A",     ":call ExploreDisplay(line('.'), 2)<cr>zb")
    "    \ . SaveMap("!",     ":call ExploreStartCmd()<cr>")
    "    \ . SaveMap("?",     ":call ExploreHelp()<cr>")
    "    \ . SaveMap("<c-l>", ":<c-u>let g:explore_level = v:count1<cr><c-r>")

    let b:buf_restore = b:buf_restore
        \ . SaveSet("swapfile", 0)
        \ . SaveSet("titlestring")
        \ . SaveSet("lines")
        \ . SaveSet("write", 0)
    call ExploreFile(expand("%:p:h"))
endfunction

function! ExplorerStartCmd()
    !explorer C:\Users\IBM_ADMIN\Desktop\cmd.lnk
endfunction

function! ExploreDeleteFile()
    call delete(ExploreGetFile())
    call ExploreDisplay(line('.'))
endfunction

function! ExploreRenameFile()
    let orig = ExploreGetFile()
    call histadd("input", orig)
    let name = input("new name for " . orig . "? ")
    echo "\r"
    if name == ""
        return Warning("Canceled")
    endif
    if rename(orig, name) != 0
        call Error("rename " . orig . " " . name . " failed")
    endif
    call ExploreDisplay(line('.'))
endfunction

" Where is a command-mode command to execute that positions us in the new dir.
function! ExploreDisplay(where, ...)
    if !exists("g:explore_level")
        let g:explore_level = 1
    endif
    "let cmd = "$ read !perl -S vimls.pl -level " . g:explore_level
    let cmd = "$ read !perl -S ls.pl -1"
    if a:0 == 1 && a:1 == 2
        " display date & size
        let cmd = cmd . " -l"
    endif
    let save = SaveSet("report", 999999) . SaveSet("ch", 6)
    let cwd = getcwd()
    let &titlestring = matchstr(
        \ cwd, '[^\\]\+$') . '\ - ' . matchstr(cwd, '^.*\\')
    set noreadonly
    % delete
    exec cmd
    1 delete
    set nomodified readonly
    call RestoreSet(save)
    exec a:where
endfunction

" Get the file name from the current line of explorer.
function! ExploreGetFile()
    " strip leading clearcase info & trailing /
"    return substitute(getline("."), '^\(\S  \|\)\(.*[^/]\)/*$', '\2', '')
    return Sub('', getline('.'), '^\S ', '', '/$', '')
endfunction

function! ExploreFile(file)
    let file = a:file
    if isdirectory(file)
        if file =~ '^\.\./*$'
            let where = '/' . substitute(getcwd(), '.*\\', '', '') . '\/'
        else
            let where = 1
        endif
        exec "chdir " . file
        call Edit("_explorer_")
        call ExplorerSyntax()
        call ExploreDisplay(where)
    else
        call Warning(system('perl -S vimshow.pl "' . file . '"'))
    endif
endfunction

function! ExploreChdir()
    let x = input("chdir where? ")
    echo "\r"
    if x == ""
        return Warning("Canceled")
    endif
    let d = Chomp(system("redirect dirs q " . x))
    if d =~ '^\*\*\*'
        return Warning(d)
    endif
    call PushLoc()
    call ExploreFile(d)
endfunction

function! ExploreFindFile()
    let x = input("file pat to search for? ")
    echo "\r"
    if x == ""
        return Warning("Canceled               ")
    endif
    call TempWinCmd(10, 'ff "' . x . '"')
endfunction

function! ExplorerSyntax()
    syntax match explorerDirectory	    ".*/$"
    syntax match explorerCurDir	        "^\(\|\S  \)\. .*$"
    syntax match explorerSourceFile	    ".*\.\(java\|h\|c\|cpp\|idl\)$"
    highlight link explorerDirectory	Directory
    highlight link explorerCurDir	    Comment
    highlight link explorerSourceFile   Identifier
endfunction
