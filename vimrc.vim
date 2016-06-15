" Use Help command to add help info, conventionally:
"   Help "<map> - <descr>"
" Then ,he searches it.

" vim bindings in firefox: C:\Documents and Settings\Administrator\_vimperatorrc

set nocompatible

" Vim 70 stuff:
let loaded_matchparen = 1  " disable matchparen

" left and right arrow move between tabs
nmap <right> :call Update(1)<bar>tabnext<bar>e%<cr>
nmap <left> :call Update(1)<bar>tabprev<bar>e%<cr>

" alt left and right move through history of places
nmap <a-left> <c-o>
nmap <a-right> <c-i>

" TODO: make this work like alt-tab - i.e. remember most recently used
    "call GUIMsg('tab='.tabpagenr().' cmd='.b:page_cmd)
"nnoremap <c-tab> :call Update(1)<bar>tabnext<cr>
"inoremap <c-tab> <esc>:call Update(1)<bar>tabnext<cr>

" It seems like this will only ever switch between adjacent tabs???
nnoremap <c-tab> :call PrevTab()<cr>
inoremap <c-tab> <esc>:call PrevTab()<cr>
function! PrevTab()
    call Update(1)
    let this_tab = tabpagenr()
    if !exists('g:prev_tab')
        if this_tab == 1
            let g:prev_tab = 1
        else
            let g:prev_tab = this_tab - 1
        endif
    endif
    let prev_tab = g:prev_tab
    let g:prev_tab = tabpagenr()
    call Normal(prev_tab . 'gt')
endfunction

set guitablabel=%!GuiTabLabel()

" Customize tab labels here: by default simple file name.
" Special handling for page: the command name.
function! GuiTabLabel()
    if exists('b:page_cmd')
        " just first work of command (and remove .pl)
        return substitute(b:page_cmd, '\(\.pl\)\= .*', '', '')
    else
        return '%t'
    endif
endfunction

" end Vim 70 stuff

" Config for vim-notes (https://github.com/xolox/vim-notes)
"let g:notes_directories = ['C:/tsk/notes2']
"let g:notes_suffix = '.txt'
"let g:notes_word_boundaries = 1
"let g:notes_smart_quotes = 0

" This prevents zipPlugin.vim from handling zip and jar:
let g:loaded_zipPlugin = "skip this"

let g:cr = nr2char(13)  " explicit ^M confuses tags
let g:nl = nr2char(10)

let g:help_info = ""
let g:help_sep = g:cr

function! HelpInfo(x)
    let g:help_info = g:help_info
        \ . substitute(a:x, '^\s\+', '', '') . g:help_sep
endfunction
command! -nargs=1 Help call HelpInfo(<args>)

Help ',he - search and display help info'
nmap ,he :call Help()<cr>
function! Help()
    let pat = input("Pattern? ")
    echo "\r"
    call TempWin(&lines/2)
    call append(0, g:help_info)
    exec "1 s/" . g:help_sep . '/' . g:help_sep . '/g'
    g/^$/d
    if pat != ""
        silent exec "v/" . pat . "/d"
    endif
    silent %!sort
    call Align(0, 1, line("$"), "l", "- ")
    1
    call WinShrink()
    echo '<esc> to dismiss'
    set nomod
endfunction

Help ',ha - add help for current map'
nmap ,ha :call HelpAdd()<cr>
function! HelpAdd()
    let line = getline('.')
    let map = substitute(line, '^\s*\S*map \(\S\+\).*', '\1', '')
    if map == line
        return Warning("not on a map")
    endif
    call append(line('.')-1, 'Help "' . map . ' - Enter description"')
    normal! k^fE
endfunction


" Sourced files
Help 'V / - search for highlighted string'
source <sfile>:h/vim/search.vim

Help ',nc - after "Copy as Document Link" in notes, this creates a "notes://" link'
Help ',no - open a "notes://" link created by ,nc (gu also works)'
source <sfile>:h/vim/notes.vim

source <sfile>:h/vim/text-enable-code-snip.vim

" Remove ALL autocommands.
autocmd!

" See help runtimepath -- supposedly that can replace mysyntaxfile

" vimfiles & syntax files are relative to this file
let myvimfiles = expand("<sfile>:p:h") . '/vim'
"exec "set runtimepath+=" . myvimfiles
"exec "set runtimepath=" . myvimfiles . "," . &runtimepath
set runtimepath+=myvimfiles

" Typescript support
set runtimepath+=~/git/typescript-vim
autocmd BufNewFile,BufReadPost *.ts set filetype=typescript
autocmd BufNewFile,BufReadPost *.ts set iskeyword-=.  " don't know where this is coming from

" Scala support
set runtimepath+=~/git/vim-scala

" Swift support
autocmd BufNewFile,BufReadPost *.swift set filetype=swift
set runtimepath+=~/git/vim/swift.vim

" Dockerfile support
"set runtimepath+=C:\tsk\git\Dockerfile.vim

" javascript
set runtimepath+=~/git/vim-javascript

" JSX support
set runtimepath+=~/git/vim-jsx/after

" Go (golang) support
autocmd BufNewFile,BufReadPost *.go set filetype=go
" auto-add closing brace after { at end of line
autocmd FileType go inoremap {<CR> {<CR>}<C-o>O
set runtimepath+=~/git/vim-go
let g:go_fmt_command = 'goimports'

" class outline viewer for Vim - depends on exuberant ctags
" toggle with ":TagbarToggle<cr>"
set runtimepath+=~/git/tagbar

" configure key mappings in tagbar
let g:tagbar_map_togglesort = 'ss'
let g:tagbar_map_toggleautoclose = 'cc'

function! Test()
    for i in range(tabpagenr('$'))
        echo "??? i = <".i.">"
        for x in tabpagebuflist(i + 1)
            echo "??? x = <".x.">"
            echo "bufname: " . bufname(x)
        endfor
    endfor
endfunction

" Is there a tagbar in any tab page?
function! TagbarExists()
    for i in range(tabpagenr('$'))
        for x in tabpagebuflist(i + 1)
            if bufname(x) == '__Tagbar__'
                return 1
            endif
        endfor
    endfor
    return 0
endfunction

" 'toggle outline' - toggle tagbar and adjust window size accordingly
nmap <silent> ,to :call TagbarToggle()<cr>
function! TagbarToggle()
    let exists0 = TagbarExists()
    TagbarToggle
    let exists1 = TagbarExists()
    "if bufwinnr("__Tagbar__") == -1
    if exists0 > exists1
        " was one, now there isn't
        "TODO: can we do this on window close?
        let &columns = &columns - 41
    elseif exists0 < exists1
        " wasn't one, now there is
        let &columns = &columns + 41
    endif
endfunction

" Rust support
"set runtimepath+=C:\tsk\git\rust.vim

" Jade support
autocmd BufNewFile,BufReadPost *.jade set filetype=jade
set runtimepath+=~/git/vim-jade

" Stylus support
autocmd BufNewFile,BufReadPost *.styl set filetype=stylus
set runtimepath+=~/git/vim-stylus

"cson support
autocmd BufNewFile,BufReadPost *.cson set filetype=coffee

" Coffeescript support
autocmd BufNewFile,BufReadPost *.coffee set filetype=coffee
autocmd BufNewFile,BufReadPost *
    \ if getline(1) =~# '^#!.*/bin/env\s\+coffee\>' | setfiletype coffee | endif
set runtimepath+=~/git/vim-coffee-script

" IcedCoffeeScript
"autocmd BufNewFile,BufReadPost *.iced call InitIced()
autocmd BufReadPost,FileReadPost *.iced call InitIced()
function! InitIced()
    set filetype=coffee
    syntax match icedStatement /\<\%(await\|defer\)\>/ display
    highlight default link icedStatement Statement
endfunction

" run \tsk\bin\vim\scripts.vim
runtime scripts.vim

runtime macros/matchit.vim

let g:root = expand("<sfile>:p:h:h")
let g:vimrc = expand("<sfile>")
let mysyntaxfile = myvimfiles . '/mysyntax.vim'
syntax off
"set guifont=Lucida_Console:h10:cANSI
"set guifont=Droid_Sans_Mono:h9:cANSI

" Use the ROOT envariable if defined, otherwise our grandparent.
function! GetRoot()
    let root = exists($ROOT) ? $ROOT : g:root
    return substitute(root, '\\', '/', 'g')
endfunction

" hijack several commands like "s" as a prefix for mappings.
" To ensure unmapped commands starting with "s" don't cause problems
" we have the maps below.  These commands can be canceled with <esc>
nnoremap b <esc>
nnoremap e <esc>
nnoremap s <esc>
nnoremap D <esc>

" Temp dir to use with forward slashes
function! GetTempDir()
    if $TEMP
        let temp = $TEMP
    else
        let temp = $HOME . '/tmp'
    endif
    if !isdirectory(temp)
        call mkdir(temp, 'p')
    endif
    return substitute(temp, '\\', '/', 'g')
endfunction
let g:temp = GetTempDir()

" No error in vim files (it's not accurate on continuation lines)
let g:vimsyntax_noerror = 1

" Treat "#!/bin/sh" files as bash, not sh
let g:is_bash = 1

" explorer.vim customization
let g:explDateFormat="%Y %b %d %H:%M"
function! ExplorerCustomMap()
    nmap <buffer> <cr> gf
endfunction

" groovy -- allows keywords from C++
let groovy_allow_cpp_keywords = 1

" override stuff in C:\vimfiles\after\ftplugin\java.vim
filetype plugin on  " see: ~/vimfiles/ftplugin & $VIMRUNTIME/ftplugin
filetype indent on  " see: ~/vimfiles/indent & $VIMRUNTIME/indent

exec 'source ' . mysyntaxfile
syntax enable

autocmd TabLeave * call TabLeave()
function! TabLeave()
    let g:prev_tab = tabpagenr()
endfunction

autocmd FileChangedShell * call FileChangedShell()
function! FileChangedShell()
    if !exists('g:expecting_file_change') || !g:expecting_file_change
        call Warning(expand('<afile>') . ' has changed outside of vim')
    endif
endfunction

" Call ExpectChange(1) to disable the above warning; then ExpectChange(0)
function! ExpectChange(x)
    checktime
    let g:expecting_file_change = a:x
endfunction

autocmd FileType jade set shiftwidth=2

" Now done in C:\tsk\bin\vim\after\ftplugin\html.vim
" DOESN'T WORK so keep it here
autocmd FileType xml set shiftwidth=2
autocmd FileType html set shiftwidth=2

autocmd FileType html highlight link htmlArg Identifier
autocmd FileType html highlight link htmlTagName Statement

" In templating langs (e.g. meteor) sometimes stuff that looks like errors is ok.
autocmd FileType html highlight link htmlError Todo

autocmd FileType jade highlight link htmlArg Identifier
autocmd FileType jade highlight link jadeAttributes Identifier
autocmd FileType jade highlight link jadeTag Statement

" XML files should be utf-8
autocmd FileType xml set encoding=utf-8

" Treat . as part of keyword in xml (e.g. org.eclipse.core)
autocmd FileType xml set iskeyword+=.

" Fold methods
autocmd FileType xml set foldmethod=syntax
autocmd FileType java set foldmethod=marker foldmarker={,}
" indent/java.vim messes with cinoptions
autocmd FileType java set cinoptions=:0,g0,+1s,(1s,j1

"??? Use cindent for everything?
" File types to use cindent for
"autocmd FileType java       set cindent
"autocmd FileType c          set cindent
"autocmd FileType javascript set cindent
"autocmd FileType cpp        set cindent

" Allow comments at end of line, not just starting at ^
autocmd FileType dosini syntax match dosiniComment ';.*$'

" extra vim errors: elsif and trailing semi
autocmd FileType vim syntax match   vimElseIfErr	"\<elsif\>"
autocmd FileType vim syntax match   vimSemiError	";$"
autocmd FileType vim highlight      default link vimSemiError	Error

" NETRW customization
let g:loaded_netrwPlugin = "ignore!"

" date/time format for editing directories
let g:netrw_timefmt = '%Y/%m/%d %H:%M:%S'
" hide . and ..
let g:netrw_list_hide='^\./$,^\.\./$,^CVS/$,^ID$,^tags$,^tagspath.vim$'
let g:netrw_sort_sequence = '[\/]$,*'

autocmd FileType netrw call DoNetRW()
function! DoNetRW()
    highlight link netrwSizeDate Special
    highlight link netrwTime Comment
    nmap <buffer> dd <del>
    let old_map = maparg('<cr>', 'n')
echo "??? old_map = <".old_map.">"
    exec 'nnoremap <buffer> <silent> <cr> :call PushLoc()<cr>' . old_map
    " use bb to bookmark, bl to list
    " these don't seem to work very well
    unmap b
"    exec 'nnoremap <silent> bb ' . maparg('b', 'n')
"    exec 'nnoremap <silent> bl ' . maparg('q', 'n')
endfunction

"autocmd FileType netrw highlight link netrwSizeDate Special
"autocmd FileType netrw highlight link netrwTime Comment

" Vim 7.0 customization
" have <cr> push loc first
"autocmd FileType netrw
"    \ exec 'nnoremap <buffer> <silent> <cr> :call PushLoc()<cr>'
"        \ . maparg('<cr>', 'n')

" don't show unclosed strings -- too annoying when typing
autocmd FileType java highlight link javaStringError NONE
" no special color for javadoc titles
autocmd FileType java highlight link javaCommentTitle Comment

" Treat *.md as markdown
autocmd BufNewFile,BufRead *.md set filetype=markdown
" Color line breaks in markdown file (two spaces at end of line)
autocmd FileType markdown syntax match markdownLineBreak "\(\S\s*\)\@<=\s\{2\}$"
autocmd FileType markdown highlight markdownLineBreak guibg=#ffbbbb

" .cjsx is coffeescript jsx; use coffee for now
autocmd BufReadPost,FileReadPost *.cjsx set filetype=coffee
autocmd FileType coffee set shiftwidth=2

" This doesn't seem to work in comments?
" NOTE use \C to force case-sensitive
autocmd FileType * syntax match myTodo containedin=Comment
  \ '\C???\|\<\(TODO\|NOTE\|BUG\|TEST\|TEMP\|NYI\|CHANGE\|KLUDGE\)\>'
autocmd FileType * highlight link myTodo Todo

" Highlight a specific pattern.
function! Highlight(...)
    if a:0 > 0 
        let pat = a:1
    else
        let pat = input("Pattern to highlight? ")
        echo "\r"
        if pat == ""
            return Warning("Canceled")
        endif
    endif
    if exists('b:did_my_highlight')
        " only clear if we already set
        syntax clear myHighlight
    endif
    let b:did_my_highlight = 1
    exec 'syntax match myHighlight containedin=ALL "'
        \ . escape(pat, '"[].*') . '"'
    highlight link myHighlight Todo
endfunction
Help ',hi - highlight a specific pattern'
Help ',ho - turn off highlighting of specific pattern'
nmap ,hi :call Highlight()<cr>
nmap ,hw :call Highlight(GetWord())<cr>
vmap ,hi y:call Highlight(@")<cr>
nmap ,ho :syntax clear myHighlight<cr>

" Make ^M at end of line invisible.
"??? Only seems to work on otherwise uncoloured lines.
syntax match trailingCR "\r$"
"highlight link trailingCR Ignore
hi def link trailingCR Ignore

imap <c-s> <c-o>zz
nmap <silent> <c-s> :call Update(1)<cr>
nmap <silent> zz :call Update(1)<cr>
nmap zu :let b:auto_update = 0<cr>

" Save changes automatically every &updatetime milliseconds.
autocmd CursorHold * silent! update
" Also check for new version on disk (cf. set autoread)
" Problem: if we do nothing, it isn't checked again.
autocmd CursorHold * silent! checktime

function! SetAutoRead()
    let file = substitute(expand('%:p'), '\\', '/', 'g')
    exec "autocmd CursorHold " . file . " call AutoRead('".file."')"
endfunction
function! AutoRead(file)
    edit %
    set updatetime=0
    set updatetime=4000
"    exec "autocmd! CursorHold " . a:file
"    exec "autocmd CursorHold " . a:file . " call AutoRead('".a:file."')"
endfunction

" Like modeline but for vars:
"   vimvar: g:page_prefix='Metadata: '
" in line 1 causes that var to be set when file is read.
autocmd BufReadPost * if getline(1) =~ '^\W*vimvar:' | call SetVimVar() | endif
autocmd BufReadPost * call DeduceIndent()

" Assume files with interpreter specified with #! are meant to be used on Linux
"autocmd BufReadPost * if getline(1) =~ '^#!/' | set fileformat=unix | endif

" Assume files under C:\tsk\vagrant should be unix format, since they will be
" mounted in linux VMs.
autocmd BufNewFile,BufReadPost *
    \ if stridx(expand('%:p'), 'C:\tsk\vagrant') == 0 | set fileformat=unix | endif

" This doesn't seem to work in scripts.vim:
" Check for perl script wrapped in .bat -- some use this marker
autocmd FileType dosbatch
    \ if getline(1) =~? '-\*- *perl *-\*-' | set filetype=perl | endif

" .coffee file with "js: <dir>" in first line is compiled to javascript in <dir>
autocmd BufWritePost *.coffee call CompileCoffee()
function! CompileCoffee()
    let line1 = getline(1)
    let js = substitute(line1, '.*\<js: *\(\S\+\).*', '\1', '')
    if js == line1
        return
    endif
    "let cmd = 'coffee -c -o "' . js . '" "' . expand('%') . '"'
    "let output = system(cmd)
    "call Warning(output)
    " get this into error list
    call ErrorMaps()
    let tmp = GetTemp("coffee")
    let cmd = 'coffee -c -o "' . js . '" "' . expand('%') . '" > ' . tmp . ' 2>&1'
    echo system(cmd)
    if v:shell_error == 0
        let msg = Chomp(system("cat " . tmp))
        if msg != ''
            echo msg
        endif
    else
        exec 'cfile ' . tmp
    endif
    call delete(tmp)

"    let pat = '\(%[:a-z]*\)\(.*\)'
"    let exp = substitute(js, pat, '\1', '')
"    if exp != js
"        let rest = substitute(js, pat, '\2', '')
"        let js = expand(exp) . rest
"    endif
"echo "??? js = <".js.">"
"    let cmd = 'coffee -c -p "' . expand('%') . ' > ' . js
endfunction

" TODO: this is still windows-specific
" On save, compile: .jade->.html, .less->.css, .coffee->.js, .cjsx->.js
"autocmd BufWritePost *.jade call NodeCmd('.html', 'jade\bin\jade', ' --pretty ')
"autocmd BufWritePost *.less call NodeCmd('.css', 'less\bin\lessc', ' ')
"autocmd BufWritePost *.coffee call NodeCmd('.js', 'coffee-script\bin\coffee', ' -b -o . ')
"autocmd BufWritePost *.cjsx call NodeCmd('.js',
"    \ 'C:\PROGRA~1\IBM\SDP_1\cordova_cli\node_modules\coffee-react\bin\cjsx',
"    \ ' -o . ')
"@"C:\Program Files\nodejs\node.exe" ^
"  "C:\Program Files\IBM\SDP_1\cordova_cli\node_modules\coffee-react\bin\cjsx" -o . %*

function! NodeCmd(dst_ext, module, opts)
    let is_less = a:dst_ext == '.css'
    let opts = a:opts
    let src = expand('<afile>')
    let dst = expand('<afile>:r')
    let line1 = getline(1)
    " Note: can't currently use both src: and out:
    let src2 = substitute(line1, '\(\#\|//\) src: *', '', '')
    if src2 != line1
        let src = src2  " different source file to compile is specified
        let dst = substitute(src, '\.' . expand('<afile>:e'), '', '')
    endif
    let out = substitute(line1, '\(#\|//\) out: ', '', '')
    if out != line1
        let dir = expand('<afile>:h') . '\' . out
        call Mkdir(dir)
        if !is_less
            let opts = opts . '-o ' . dir . ' '
        endif
        let dst = dir . '\' . expand('<afile>:t:r')
    endif
    let dst = dst . a:dst_ext
    call delete(dst)
    let module = a:module
    if module !~ '^[a-zA-Z]:'
        let module = 'C:\Users\IBM_ADMIN\AppData\Roaming\npm\node_modules\' . module
    endif
    let cmd = 'C:\PROGRA~1\nodejs\node.exe "' . module . '"' . opts . src
    if is_less
        let cmd = cmd . ' ' . dst
    endif
    "call GUImsg(cmd)
    "echo cmd
    "call setline(line('.'), cmd)
    let output = system(cmd)
    if !filereadable(dst)
        echohl WarningMsg
        echo 'Error from: ' . cmd
        echo substitute(output, "\n$", '', '')
        echohl None
    endif
endfunction

" get correct filetype for clearcase .keep files backup files
autocmd BufNewFile,BufReadPost *.keep*          call DoBackupFileType()
autocmd BufNewFile,BufReadPost *.save*          call DoBackupFileType()
autocmd BufNewFile,BufReadPost *.merge*         call DoBackupFileType()
autocmd BufNewFile,BufReadPost *.contrib*       call DoBackupFileType()
autocmd BufNewFile,BufReadPost *~*              call DoBackupFileType()
autocmd BufNewFile,BufReadPost */[0-9]*[0-9]    call DoBackupFileType2()
function! DoBackupFileType()
    let afile = expand("<afile>")
    let orig = Sub('', afile,
        \ '\.keep$',    '', '\.keep\.\d\+$',    '',
        \ '\.save$',    '', '\.save\.\d\+$',    '',
        \ '\.merge$',   '', '\.merge\.\d\+$',   '',
        \ '\.contrib$', '', '\.contrib\.\d\+$', '',
        \ '\~\w\+$', '')
    if orig != afile
        exec "doautocmd BufRead " . orig
    endif
endfunction
" AutoSave files
function! DoBackupFileType2()
    let tail = expand("<afile>:p:t")
    if tail =~ '^\d\+$'
        let head = expand("<afile>:p:h")
        exec "doautocmd BufRead " . head
    endif
endfunction

"AutoHotkey files: color comments and key specifications
" See: C:\tsk\vim\vimfiles\after\syntax\ahk.vim
autocmd BufReadPost,FileReadPost AutoHotkey.ini set filetype=autohotkey
"autocmd BufReadPost,FileReadPost *.ahk set filetype=ahk

"NOTE: jar -tf is much slower than unzip -l

"NOTE: modified tarPlugin.vim to disable netrw crap
autocmd! BufReadPost,FileReadPost *.tar set filetype=tar
autocmd FileType tar nmap <buffer> <cr> gf
autocmd FileType tar call DoUntar()

autocmd BufReadPost,FileReadPost *.class set filetype=jclass
"autocmd FileType jclass call Filter("javap -classpath " . expand('%:p:h') . ' ' . expand('%:t:r'))
autocmd FileType jclass call DoClass()

autocmd BufReadPost,FileReadPost *.jar set filetype=zip
autocmd BufReadPost,FileReadPost *.war set filetype=zip
"autocmd FileType jar call Filter('jar -tf "' . @% . '"')
"autocmd FileType jar nmap <cr> gf

autocmd! BufReadPost,FileReadPost *.zip set filetype=zip
autocmd BufReadPost,FileReadPost *.ras set filetype=zip
"autocmd FileType zip call Filter("unzip -l " . @%)
autocmd FileType zip call DoUnzip()
" modify gf to skip over detail info
autocmd FileType zip nmap <buffer> gf gU,di$:call GoFile()<cr>
autocmd FileType zip nmap <buffer> <cr> gf

function! DoClass()
    set noreadonly
    let save = SaveSet('eventignore', 'BufReadCmd,FileReadCmd')
    " -c includes disassembly
    " -verbose shows major/minor version number but a bunch of extra stuff too
    call Filter('javap -c -s -private -classpath ' . expand('%:p:h') . ' ' . expand('%:t:r'))
    exec save
    set filetype=java
    syntax on
    " 1s#^Compiled from #// &#
endfunction

function! DoUnzip()
    set noreadonly
    let save = SaveSet('eventignore', 'BufReadCmd,FileReadCmd')
    call Filter('unzip -l "' . @% . '"')
    exec save
    if !exists('b:zip_verbose')
        let b:zip_verbose = 0
    endif
    if !b:zip_verbose
        "non-verbose listing: leave out headers, size&date, directories
        silent g/^ *---[- ]*$/d
        silent 1 g/^Archive:/d
        silent 1 g/^PACK200$/d
        silent 1 g/^ *Length /d
        silent $ g/\d files\=$/d
        silent % s/^ *\d\+ \+\S\+ \+\S\+ \+//g
        silent g/\/$/d
        1
        set nomod readonly
    else
        4
        norm 0
    endif
endfunction

function! DoUntar()
    set noreadonly
    let save = SaveSet('eventignore', 'BufReadCmd,FileReadCmd')
    call Filter('tar -tf "' . @% . '"')
    exec save
    if !exists('b:zip_verbose')
        let b:zip_verbose = 0
    endif
endfunction

Help 'i - in zip display, toggle details listing (like directory edit)'
autocmd FileType zip nmap <buffer> i :call ToggleZipVerbose()<cr>
function! ToggleZipVerbose()
    let b:zip_verbose = !b:zip_verbose
    call DoUnzip()
endfunction

" Replace the contents of this file with the output of cmd
function! Filter(cmd)
    let save = SaveSet('report', 999999)
    % delete
    exec "read !" . a:cmd
    exec save
    1 delete
    set nomod readonly
endfunction

" override filetype plugins that this set this:
autocmd BufReadPost,FileReadPost * setlocal formatoptions-=o

" Save paths of editted files.
"let g:vim_hist = expand($USERPROFILE . '/vim_hist.txt')
" History in this file: vim/vim_hist.txt
let g:vim_hist = myvimfiles . '/vim_hist.txt'

autocmd BufNewFile,BufReadPre * call AddToHistory()
function! AddToHistory()
    let path = expand('%:p')
    if path != '' && path != g:vim_hist && &modifiable
        let time = strftime('%Y-%m-%d %H:%M:%S')
        let line = time . ' ' . path
        if !filereadable(g:vim_hist)
            call Write('# history of files edited', g:vim_hist)
        endif
        call Append(line, g:vim_hist)
    endif
endfunction

" Prune vim_hist file before reading it
autocmd BufReadPre vim_hist.txt call system("vim_hist.pl -prune")
" syntax highlighting
autocmd BufEnter vim_hist.txt syntax match myDate '\d\d\d\d-\d\d-\d\d\>'
autocmd BufEnter vim_hist.txt syntax match myTime ' \d\d:\d\d:\d\d '
autocmd BufEnter vim_hist.txt highlight link myDate SpecialKey
autocmd BufEnter vim_hist.txt highlight link myTime Special

autocmd BufEnter * call BufEnter()
autocmd BufLeave * call BufLeave()
let g:no_more_items = 0
let g:old_dir = ""
let g:tagspath = ""
let g:viewpath = ""
"Bug? When we start with --remote-tab-silent, BufEnter doesn't seem to be called
function! BufEnter()
"    call GUImsg("BufEnter for " . expand('%'))
    let save = ""
    if exists('b:directory') " force to this directory
        exec 'chdir ' . b:directory
    endif
    let dir = Dir()
    if g:old_dir != dir
        call DirEnter(dir, g:old_dir)
        let g:old_dir = dir
    endif
    if exists("b:filetype")
        let &ft = b:filetype  " override file type by setting b:filetype
"        exec "silent doautocmd filetype BufRead " . @%
    endif
    if !exists("b:titlestring")
        " compute the title string the first time in (unless already set)
        let b:titlestring = '%t%( %m%)%( %r%)  -  ' . TitleDir(Dir())
        if exists('g:page_prefix')
            let b:titlestring = g:page_prefix . b:titlestring
        endif
    endif
    let &titlestring = b:titlestring
    if &ft == "java"
        " don't show unclosed strings -- too annoying when typing
        "highlight link javaStringError NONE
        " no special color for javadoc titles
        "highlight link javaCommentTitle Comment
        map <buffer> [[ ^[m^:call PositionBlank()<cr>
        map <buffer> ]] $]m^:call PositionBlank()<cr>
    elseif &ft == 'perl'
        nmap <buffer> <silent> [[
            \ :call SearchOrEnd('^\s*sub\s\+\w\+', 'bW')<cr>
"            \ :call SearchOrEnd('^\s*sub\s.*[^;\s]\s*$', 'bW')<cr>
        nmap <buffer> <silent> ]]
            \ :call SearchOrEnd('^\s*sub\s\+\w\+', 'W')<cr>
"            \ :call SearchOrEnd('^\s*sub\s.*[^;\s]\s*$', 'W')<cr>
    elseif &ft == 'ls'
        nmap <buffer> <silent> [[ :call search('.*:$', 'bW')<cr>
        nmap <buffer> <silent> ]] :call search('.*:$', 'W')<cr>
    endif

    if !exists('g:did_syntax_enable')
        " For some reason when vim first starts we don't get syntax
        " customizations from mysyntaxfile.
        "TODO: what if we have syntax off for some reason?
        syntax enable
        let g:did_syntax_enable = 1
    endif
    if &ft == "vim"
        " error highlighting is sometimes wrong (e.g. "nmap be ...")
        highlight link vimError NONE
    endif
    if &ft == 'xml'
        " Syntax highlighting takes too long on big files;
        " be sure it's on before turning it off
"        if exists('b:current_syntax') && line('$') >= 10000
        if exists('b:current_syntax') && getfsize(@%) >= 1000000
            syntax off
            let save = save . 'syntax enable|'
        endif
    endif
    if &ft == 'diff'
        "NOTE can't use setlocal for this (it doesn't work)
        let save = save
            \ . SaveSet('wrapscan', 0)
            \ . SaveSet('columns', &columns+2)
            " why did we have nolinebreak?
            "\ . SaveSet('linebreak', 0)
    endif
"    if (&ft == 'java' || &ft == 'html') && !exists('b:columns')
"        " use 50 lines and 100 column width for Java and HTML
"        let b:columns = 100
"        let &lines = 50
"    endif
    let b:buf_restore = save
    if exists('g:remove_crs')
        if &readonly && !&modified
            call RemoveCRs()
        endif
    endif
    " creating g:make_wide forces every buffer to adapt its width
    if exists('b:columns')
        call SetWidth(b:columns)
    elseif exists('g:make_wide')
        call MakeWideEnough()
    endif
endfunction

function! BufLeave()
    if exists('b:buf_restore')
        exec b:buf_restore
    endif
endfunction

function! AddBufRestore(string)
    if !exists('b:buf_restore')
        let b:buf_restore = ''
    endif
    let b:buf_restore = a:string . b:buf_restore
endfunction

" Called when we enter a buffer in a new dir.
" State to restore when we leave dir is saved in g:dir_restore.
" NOTE: can't be b: var because there are more than one buffer in a dir.
function! DirEnter(dir, old)
    if exists('g:dir_restore')
        exec g:dir_restore
    endif
    let g:dir_restore = ''
"   call SetPath()
    let g:dir_restore = g:dir_restore . SetTags(a:dir)
endfunction

" Add to tags based on g:tagspath file.  Return cmd to restore.
" NOTE: g:tagspath may contain anything, but we only attempt to restore tags.
function! SetTags(dir)
    let tagspath = a:dir . "\\" . g:tagspath
    if filereadable(tagspath)
        let result = SaveSet('tags')
        exec "source " . tagspath
        return result
    else
        return ''
    endif
endfunction

" set path based on components in view
function! SetPath()
"FIX
"    exec "set path-=" . g:viewpath
"    let g:viewpath = system("viewpath")
"    exec "set path+=" . g:viewpath
endfunction

" Set vim vars from line 1 and following
function! SetVimVar()
    let lineno = 1
    while 1
        let line = getline(lineno)
        let lineno = lineno + 1
        let expr = substitute(line, '^\W*vimvar:\s*', '', '')
        if expr == line
            return
        endif
        exec 'let ' . expr
    endwhile
endfunction

Help ',in - show indentation calculations for this file'
Help ',IN - show verbose indentation calculations for this file'
" (replaces bin\tabstop.bat)
nmap ,in :call DeduceIndent(1)<cr>
nmap ,IN :call DeduceIndent(2)<cr>
" Modes: 0 => set shiftwidth tabstop expandtab,
"        1 => show settings, 2 => also show effect of each tab line
function! DeduceIndent(...)
    let mode = a:0 == 0 ? 0 : a:1
    let sw2 = 0
    let sw3 = 0
    let sw4 = 0
    let ts4 = 0
    let ts8 = 0
    let tabs = 0 " lines with tabs in indent
    let spaces = 0 " lines with spaces in indent
    let l = 1
    let last = Max(1000, line("$"))
    while l < last
        let l0 = l
        let x = getline(l)
        let in1 = matchstr(x, '^\s*')
        if x !~ '^\s*\*'  " ignore C-style comments
"            if in1 =~ ' '
"                let spaces = spaces + 1
"            endif
            if in1 =~ '\t'
                let tabs = tabs + 1
            elseif in1 =~ ' '
                let spaces = spaces + 1
            endif
        endif
        " find next non-blank line
        while l < last
            let l = l + 1
            let y = getline(l)
            if y =~ '\S'
                break
            endif
        endwhile
        let in2 = matchstr(y, '^\s*')
        if in1 == in2
            " tells us nothing
        elseif in2 == in1 . '    '
            let sw4 = sw4 + 1
        elseif in2 == in1 . '  '
            let sw2 = sw2 + 1
        elseif in2 == in1 . '   '
            let sw3 = sw3 + 1
        elseif in2 == in1 . "\t"
            let ts4 = ts4 + 1
            if mode == 2
                echo "ts4 at lines " . l0 . " and " . l
            endif
        elseif in2 == substitute(in1, '    $', "\t", '')
            let sw4 = sw4 + 1
            let ts8 = ts8 + 1
            if mode == 2
                echo "ts8 at lines " . l0 . " and " . l
            endif
        else
"           echo 'unknown <' . in1 . '> <' . in2 . '>'
        endif
    endwhile
    let max_sw = Max(sw2, Max(sw3, sw4))
    let sw = max_sw == sw4 ? 4 : max_sw == sw2 ? 2 : 3
    let ts = ts4 >= ts8 ? 4 : 8
    let expandtab = tabs <= 4 * spaces
    if mode > 0
        echo "sw=".sw.", ts=".ts.", expandtab=".expandtab
        echo 'sw234 = ( ' sw2 sw3 sw4 ' )'
        echo 'ts48 = (' ts4 ts8 ' )'
        echo 'tabs = ' tabs
        echo 'spaces = ' spaces
    else
        let &shiftwidth = sw
        let &tabstop = ts
        let &expandtab = expandtab
    endif
endfunction

" make <alt>-space pop down the system menu (normal windows behaviour)
map <M-Space> :simalt ~<CR>
" this does it to: set winaltkeys=yes

" only do this stuff once, unless initialized is unset
if !exists("initialized") || !initialized
    let initialized = 1
    " SETTINGS
"    set shell=c:\winnt\system32\cmd.exe
"    set shellcmdflag=/c
"    set shellpipe=>
"    set shellquote=
"    set shellredir=>%s\ 2>&1
"    set shellxquote=
"    set noshellslash
    set exrc    " read local _vimrc files
    set notimeout nottimeout timeoutlen=999999999  " no timeouts
    set noswapfile
    set autowrite
    set autoread " automatically re-read files when they change on disk
    set noruler
    set tildeop     " make ~ act like an operator
    set cpoptions-=$
    set cpoptions+=$
    set cinoptions-=:0,g0,+1s,(1s,j1
    set cinoptions+=:0,g0,+1s,(1s,j1 " labels, scope, continuation, parens, java
    set cinkeys-=0#                 " don't put # in col 1
    set indentkeys-=0#
    set cinkeys-=:                  " don't reindent on colon
"    set indentkeys=o,O,<return>     " don't indent html when typing > etc.
    set formatoptions+=r            " insert comment leader after <cr>
    set formatoptions-=o            " don't insert comment leader with o & O
    set guicursor=a:blinkon0  	" turn off blinking
    set guioptions-=T  			" remove toolbar
    set guioptions-=r  			" no right scrollbar
    set guioptions-=R  			" no right scrollbar
    set guioptions-=m           " no menu bar
    set guioptions-=l           " no left scrollbar
    set guioptions-=L           " no left scrollbar
    set comments-=:%            " % doesn't start comment line
    set nobackup
    set visualbell
    set cindent nosmartindent  " always use cindent to avoid problems with #
    set tabstop=4 shiftwidth=4 autoindent expandtab smarttab
    " For perl: just smartindent causes # lines to be indented like cpp
    " Also, in any file, lines like "rm -rf /tmp/*" get confused like its a
    " comment.
    set ignorecase smartcase
    "set lines=40 columns=100 textwidth=100
    " setting textwidth causes lines to be split while typing in insert mode - blech
    set lines=40 columns=100
    set path=.,..,..\..,..\..\..
    set hlsearch
    set backspace=indent,start  " allow backspace over indent & start of insert
    set shiftround              " want this?
    set cursorline  " highlight current line
    " bunch of weird chars in default file name
    set isfname-=+
    set isfname-=\,
    set isfname-=#
    set isfname-=$
    set isfname-={,}
    set isfname-=[,]
    set isfname-=!
    set isfname-=~
    set isfname-==
    "set makeef=c:\temp\vim##.err
    set errorformat-=%f(%l\\,%c)\ :\ %m
    set errorformat+=%f(%l\\,%c)\ :\ %m
    set errorformat-=%m\ at\ %f\ line\ %l
    set errorformat+=%m\ at\ %f\ line\ %l
    set errorformat+=%f(%l)\ :\ %m
    "??? bug: the %{...} doesn't evaluate right in CursorHold autocmd
"    set titlestring=%t%(\ %m%)%(\ %r%)\ \ -\ \ %{TSDir1()}%<%{TSDir2()}
    let g:ts_dir = '<no directory>'  " set in BufEnter
    set titlestring=%t%(\ %m%)%(\ %r%)\ \ -\ \ %{g:ts_dir}
    set titlelen=0
    set suffixes+=.contrib,.keep,.0,.1,.2,.3,.4,.5,.6,.7,.8,.9,.old,.orig,.save
    set matchpairs+=<:>    " make % work on <...>
    set foldlevelstart=99   " start with folds open
    set linebreak
    let &breakat = '/ 	'  " / space tab
    "set showbreak=»
    "let &showbreak = ' »'
    let &showbreak='»' . repeat(' ', 15)
    set laststatus=0  " no status line after last window
    " keep crap out of viminfo
    set viminfo='0,\"0,/0,:0,f0,h
    set sessionoptions=curdir,winpos,resize,buffers  " saved by mksession
"    set scrolloff=3  " keep this many lines above & below cursor
    let java_allow_cpp_keywords = 1  " affects Java syntax coloring
endif
"TODO save session file in dir of last file; restore if there

"??? no longer necessary?
"" indent # normally, not at column 1
"inoremap # X<c-h>#

"TODO any other filetypes that need this???
autocmd FileType java inoremap # X#<left><bs><right>

"??? No longer a problem???
" cindent messes up this: foo: function() {<NL>xxx
"autocmd FileType javascript set nocindent smartindent

" make <c-e> and <c-y> work in insert mode
inoremap <c-e> <c-x><c-e>
inoremap <c-y> <c-x><c-y>

"TODO: have <tab> do normal completion, <f1> do syntactic constructs
" after keyword char, <tab> does completion (like ^P)
" after ( or [ or { it inserts closing one unless that's what's next
" ??? if followed by id, match idents ending in that?
" ??? lang-specific constructs

" <tab> in insert mode:
"   - after identifier <tab> does insert mode completion (:help ins-completion)
"   - after ( or [ or { inserts the closing bracket and stays in the middle
"   - otherwise inserts a tab
inoremap <tab> <c-r>=InsertTab()<cr>
inoremap <s-tab> <c-x><c-p>
function! SimpleInsertTab()
    let column = col('.') - 1
    if column == 0
        return "\<tab>"
    endif
    let chr = getline('.')[column - 1]
    if chr =~ '\k'
        return "\<c-p>"
    else
        return "\<tab>"
    endif
endfunction
function! InsertTab()
    let column = col('.') - 1
    if column == 0
        return "\<tab>"
    endif
    let line = getline('.')
    let chr = line[column - 1]
    if chr =~ '\k'
        return "\<c-p>"
    elseif chr == '('
        if line[column] == ')'
            return "\<right>"
        else
            return ")\<left>"
        endif
    elseif chr == '['
        if line[column] == ']'
            return "\<right>"
        else
            return "]\<left>"
        endif
    elseif chr == '{'
        return "\<cr>}\<up>\<end>\<cr>"
    else
        return "\<tab>"
    endif
endfunction

function! InsertTab2()
    let column = col('.') - 1
    if column == 0
        return "\<tab>"
    endif
    let line = getline('.')
    let chr = line[column - 1]
    if chr =~ '\k'
        echo "id = <".matchstr(strpart(line, 0, column), '\k\+$').">"
        return "\<c-p>"
    elseif chr == "("
        if line[column] == ')'
            return "\<right>"
        else
            return ")\<left>"
        endif
    elseif chr == "["
        if line[column] == ']'
            return "\<right>"
        else
            return "]\<left>"
        endif
    elseif chr == "{"
        return "\<cr>}\<up>\<end>\<cr>"
    else
        return "\<tab>"
    endif
endfunction

function! InsertTabLang(id)
endfunction

"??? lang-specific stuffs? e.g. "if<tab>"
"??? special handling for middle of ident
function! TestInsertTab()
    let column = col('.') - 1
    if column == 0
        return "\<tab>"
    endif
    let line = getline('.')
"echo "??? column =" column
"echo "??? line =" line
"echo match(line, '^\(.\{' . column . '}\)\(.*\)$')
"echo "match1 =" substitute(line, '^\(.\{' . column . '}\)\(.*\)$', '\1', '')
    if !Match(line, '^\(.\{' . column . '}\)\(.*\)$')
        return Internal('InsertTab', 'match failed')
    endif
    let pre = g:match1
    let post = g:match2
    if pre =~ '\k$' && post =~ '^\k'
        " ??? need special case for middle of id
        return "\<c-p>"
    endif
    ??? lang-specific

"echo "??? pre =" pre
"echo "??? post =" post
"return
    if Match(line, '^\(\{-,' . column . '}\)\(\k\+\).*$')
        " in an id
        let pre = g:match1
        let id = g:match2
    endif
"    let id = substitute(line, '^.\{-,' . column . '}\(\k\+\).*$', '\1', '')
"echo "??? id =" id
"return

    let chr = line[column - 1]
    if chr =~ '\k'
        return "\<c-p>"
    elseif chr == "("
        if line[column] == ')'
            return "\<right>"
        else
            return ")\<left>"
        endif
    elseif chr == "["
        if line[column] == ']'
            return "\<right>"
        else
            return "]\<left>"
        endif
    elseif chr == "{"
        return "\<cr>}\<up>\<end>\<cr>"
    else
        return "\<tab>"
    endif
endfunction


" TODO f1 in n-mode
nmap <f1> <esc>

Help '<f1> - do syntactic completion'
inoremap <f1> <c-r>=InsertCompletion()<cr>
function! InsertCompletion()
"    let line = getline('.')
"    let col = col('.') - 1
"    let pre = strpart(line, 0, col)
"    let post = strpart(line, col)
    let pre = BeforeCursor()
    let post = AfterCursor()
    if &ft == 'java' || &ft == 'scala'
        if pre =~ '/\*\**\s*$'  " javadoc comment
            return "\<cr>\<bs>/\<up>\<cr>"
        elseif post =~ '^.*)\s*{\s*$'  " many constructs
            return "\<end>\<cr>"
        elseif pre =~ '\<if\s*$'
            return "() {\<cr>}\<up>\<end>\<left>\<left>\<left>"
        elseif pre =~ '\<if\s*(.*$'
            if post =~ '^\s*$'
                return ") {\<cr>}\<up>\<end>\<left>\<left>\<left>"
            endif
        endif
    elseif &ft == 'vim'
        if pre =~ '^\<fun$'
            return "ction! ()\<cr>endfunction\<up>\<left>"
        elseif post =~ '()$'
            return "\<end>\<cr>"
        endif
    elseif &ft == 'perl'
        if pre =~ '^ *sub .*(.*)\= *{\=$' "TEMP && post == ''
            if pre =~ '{$'
                let x = ''
            elseif pre =~ ' $'
                let x = '{'
            elseif pre =~ ')$'
                let x = ' {'
            else
                let x = ') {'
            endif
            let proto = matchstr(pre.x, '([\$\;\@\%]*)')
            if proto =~ '^(.*)$'
                let proto = substitute(proto, ';', '', 'g')
                let proto = substitute(proto, '\([\$\%\@]\)', '\1x, ', 'g')
                let proto = substitute(proto, ', )', ')', '')
                let proto = substitute(proto, '()', '(undef)', '')
                let proto = 'my' . proto . ' = @_;'
                return x . "\<cr>" . proto . "\<cr>}\<cr>\<up>\<up>\<end>\<cr>"
            endif
        endif
    else
        " don't actually see this warning
        call Warning("don't know how to do syntactic completion for " . &ft)
    endif
    return ''  " no completion
endfunction

nmap <f2> a<f2><esc>
Help '<f2> - filetype-specific insert mode operation'

inoremap <f2> <c-r>=DoF2()<cr>
function! DoF2()
    if &ft == 'xml' || &ft == 'xsd' || &ft == 'html' || &ft == 'xhtml' || &ft == 'xslt'
        return CloseUnclosedXML()
    elseif &ft == 'perl'
        call MakeProto()
    else
        call Warning('<f2> not implement for ' . &ft . ' files')
    endif
    " need this to get back to right place in insert mode
    return virtcol('.') == 1 ? '' : "\<right>"
endfunction

function! CloseUnclosedXML()
    let pos = GetPos()  " get back to where we were at end
    let save = SaveSet('iskeyword', '+-,:')  " allow for '-' or ':' in tag
    let result = ''
    while 1
        if search('<', 'bW') == 0
            "??? this message disappears under "-- INSERT --"
            call Warning('no unclosed tag')
            break
        endif
        call Norm('l')  " move to tag
        let tg = GetWord()
        " in html, <br> is equivalent to <br/>, also <hr> and others???
        if tg =~ '^\k*$' && tg != 'br' && tg != 'hr'
            " check if this is a '<.../>' element
            let pos2 = GetPos(1)
            call Norm("0f<%")
            let line = getline('.')
            call Norm(pos2)
            if line !~ '/>'
                let result = '</' . tg . '>'
                break
            endif
        endif
        " May be on '<?' or '<!' -- just search again for those
        if tg == '</'
            " end tag -- go to matching start tag
            let p = GetPos(1)
            "NOTE: not Norm here -- % is a mapping
            normal l%
            if p == GetPos(1)
                break  " didn't find match
            endif
        endif
        call Norm('0')  " don't find this tag in next search
    endwhile
    exec save
    let line = line('.')
    call Norm(pos)
    " put tag on new line unless this line is empty or same as open tag
    if line != line('.') && BeforeCursor() =~ '\S'
        let result = "\<cr>" . result
    endif
    if PosCol(pos) != 1
        " Need this <right> due to the way pos works in insert mode
        let result = "\<right>" . result
    endif
    return result
endfunction

"nnoremap <f3> hea<f3>
"inoremap <f3> <c-o>diw<c-r>=DoF3()<cr>
"function! DoF3()
"    return 
"    let word = GetWord()
"endfunction

" Change case of current id.
"Help 'I <c-c> - change case of initial letter of current id'
Help 'I <c-c>u - change case of initial letter of current id'
Help 'I <c-c>U - change case of current id'
Help 'I <c-c><c-u> - change case of current id'
imap <c-c>u <c-r>=ChangeIdCase(0)<cr>
imap <c-c>U <c-r>=ChangeIdCase(1)<cr>
imap <c-c><c-u> <c-r>=ChangeIdCase(1)<cr>
nnoremap <c-c>u hea<c-r>=ChangeIdCase(0)<cr><esc>
nnoremap <c-c>U hea<c-r>=ChangeIdCase(1)<cr><esc>
nnoremap <c-c><c-u> hea<c-r>=ChangeIdCase(1)<cr><esc>
"function! ChangeIdCase(kind)
"    let before = BeforeCursor()
"    let id = matchstr(before, '\k\+$')
"    if id == ''
"        return ''
"    endif
"    let c = strpart(id, 0, 1)
"    let c2 = tolower(c)
"    if c ==# c2
"        let c2 = toupper(c)
"        if c ==# c2
"            return  ''
"        endif
"    endif
"    let move_l = ''   " cmd to move left to start of id
"    let move_r = ''  " cmd to move back
"    let l = strlen(id)
"    while l > 1
"        let l = l - 1
"        let move_l = move_l . "\<left>"
"        let move_r = move_r . "\<right>"
"    endwhile
"    let result = move_l . "\<bs>" . c2 . move_r
"    return move_l . "\<bs>" . c2 . move_r
"endfunction

function! ChangeIdCase(kind)
    let before = BeforeCursor()
    " remove indent because backspacing over it depends on set backspace
    let before = substitute(before, '^\s*', '', '')
    let replace = substitute(before, '\w\+\s*$', a:kind?'\U&':'\u&', '')
    if replace ==# before
        let replace = substitute(before, '\w\+\s*$', a:kind?'\L&':'\l&', '')
        if replace ==# before
            return ''
        endif
    endif
    let result = replace
    let i = strlen(before)
    while i > 0
        let i = i - 1
        let result = "\<bs>" . result
    endwhile
"    let result = "\<c-u>" . replace

"    if before =~ '^\s'
"        " extra ^U to get past autoindent
"        let result = "\<c-u>" . result
"    endif
    return result 

"    let id = matchstr(before, '\k\+$')
"    if id == ''
"        return ''
"    endif
"    let c = strpart(id, 0, 1)
"    let c2 = tolower(c)
"    if c ==# c2
"        let c2 = toupper(c)
"        if c ==# c2
"            return  ''
"        endif
"    endif
"    let move_l = ''   " cmd to move left to start of id
"    let move_r = ''  " cmd to move back
"    let l = strlen(id)
"    while l > 1
"        let l = l - 1
"        let move_l = move_l . "\<left>"
"        let move_r = move_r . "\<right>"
"    endwhile
"    let result = move_l . "\<bs>" . c2 . move_r
"    return move_l . "\<bs>" . c2 . move_r
endfunction

"NOTE use <c-q> for quoting
"NOTE for ubuntu seems to use + instead of *
" in insert mode, paste selection
"imap <c-v> <c-r><c-o>*
imap <c-v> <c-r><c-o>+
" in normal mode, paste selection line-oriented
"nmap <c-v> :put *<cr>
nmap <c-v> :put +<cr>


Help 'V ,* - copy selection into clipboard'
Help 'V ^C - copy selection into clipboard'
"vmap * "*y
vmap * "+y
"vmap <c-c> "*y
vmap <c-c> "+y

"Help 'V ,* - copy selection, stripping off common leading whitespace'
"vmap <silent> ,* "*y:let @* = StripLeadingSpaces(@*)<cr>
"function! StripLeadingSpaces(str)
"    return substitute(a:str, '\(^\|\n\)\@<=\s\+', '', 'g')
"endfunction

Help '<c-a> - select and yank all'
"nnoremap <c-a> GV1G"*ygv
nnoremap <c-a> GV1G"+ygv

Help ',cw - copy current word into clipboard'
"nnoremap ,cw "*yiw:echo @*<cr>
nnoremap ,cw "+yiw:echo @+<cr>

Help ',CW - copy current dotted word into clipboard'
nmap ,CW :call SetNorm('"+yiw', 'iskeyword', '+.')<bar>echo @*<cr>

" . in v-mode repeats last normal mode command on each line
vnoremap . :normal .<CR>

"??? -- not needed without # in cinkeys?
"" do shift without smartindent set, to avoid strange stuff with #
"" note: "." doesn't redo correctly
"nmap >> :<c-u>call ShiftRight(line("."), line(".")+v:count1-1)<cr>
"vmap > :<c-u>call ShiftRight(line("'<"), line("'>"))<cr>
"function! ShiftRight(l1, l2)
"    let save = SaveSet("smartindent", 0)
"    exec a:l1 . "," . a:l2 . ">"
"    exec save
"    exec a:l1
"endfunction

" reverse meaning of v and V, except when followed by certain motions
nnoremap v V
nnoremap V v
nnoremap vl vl
nnoremap vh vh
nnoremap v$ v$
nnoremap vw vw
nnoremap ve ve
nnoremap vi vi

" Make l & h in V-mode switch to v-mode
"???
"vmap <silent> l :<c-u>call SetVMode('v')<cr>:vunmap l<cr>gv,VV<right>
"vmap <silent> h :<c-u>call SetVMode('v')<cr>:vunmap h<cr>gv,VV<left>

function! SetVMode(vmode)
    "NOTE: use '==#' to ensure case matches!!!
    if visualmode() ==# a:vmode
        vnoremap ,VV <nop>
    else
        exec 'vnoremap ,VV ' . a:vmode
    endif
endfunction

Help ',vr - edit vimrc'
nmap ,vr gU,di:exec 'edit ' . g:vimrc<cr>
Help ',rc - re-source _vimrc file'
nmap ,rc :call Update()<cr>:exec 'source ' . g:vimrc<cr>
Help ',RC - re-initialize completely'
" re-edit to get autocmds (does it do them all?); ,md to set lines&columns
nmap ,RC zz:let initialized=0<cr>:set all&<cr>,rc,re,md

Help ',so - source current file'
nmap ,so zz:source %<cr>
nmap <up> zz:<up>
"Help '<right> <left> - scroll right or left'
"nmap <right> zl
"nmap <left> zh
Help '<space> - page forward'
"NOTE: when scrolloff is set, have to do something special
"nmap <space> Lzt
nmap <silent> <space> :call SetNorm('Lzt', 'scrolloff', 0)<cr>:echo<cr>
vmap <silent> <space> Lzt
Help '<c-space> - page backword'
"nmap <c-space> Hzb
nmap <c-space> :call SetNorm('Hzb', 'scrolloff', 0)<cr>:echo<cr>
vmap <c-space> Hzb
Help 'zz - update current file'
Help 'g<c-g> - show full path of current file'
nmap g<c-g> :echo expand("%:p")<cr>
Help ',, - switch to next window'
nmap ,, <c-w>w
Help 'dr - delete rest of windows'
nmap dr <c-w>o
Help ',FS ,fs ,fb ,FB - change font size to small or big'
"nmap ,fs :set guifont=courier:h10<cr>
"nmap ,fb :set guifont=fixedsys<cr>
nmap ,FS :set guifont=Lucida_Console:h8:cANSI<cr>
nmap ,fs :set guifont=Lucida_Console:h9:cANSI<cr>
nmap ,fb :set guifont=Lucida_Console:h10:cANSI<cr>
nmap ,FB :set guifont=Lucida_Console:h12:cANSI<cr>

" no meaning by default (i.e. not help)
if maparg('K', 'n') == ''
    nmap K <esc>
endif
if maparg('K', 'v') == ''
    vmap K <esc><esc>gv
endif

nmap zm z.
nmap z[ [z
nmap z] ]z


Help ',li - toggle "set list"'
"nmap ,li :set list!<cr>
nmap ,li :call ListCharsToggle()<cr>
function! ListCharsToggle()
    let default_listchars = 'eol:$'
    " let special_listchars = 'tab:»º'
    if !&list
        let &list = 1
        echo 'turn on list'
    elseif &listchars == default_listchars
        let &listchars = ''
        echo 'turn on list without eol'
    else  " go back to default
        let &listchars = default_listchars
        let &list = 0
        echo 'turn off list'
    endif
endfunction

Help ',hl - turn off search highlighting'
nmap ,hl :nohlsearch<cr>
Help ',wr - toggle line wrapping'
nmap ,wr :set wrap!<cr>
Help 'gV - highlight last change'
nnoremap gV '[']V''

vmap gf ygU,di:call Edit(@@)<cr>

Help 'v mi - make var inline'
vmap mi y<esc>:call MakeInline(1)<cr>
nmap mi :call MakeInline(0)<cr>

function! MakeInline(visual)
    if a:visual
        let id = @@
    else
        let id = GetWord()
    endif
    if id !~ '^\w\+$'
        return Warning('Not an id: ' . id)
    endif
    let pat = '^[^=]*\<' . id . '\>\s*=\s*'
    let decl = search(pat, 'bWn')
    if decl == 0
        return Warning('Did not find decl of ' . id)
    endif
    let stmt = GetJavaStmt(decl)
    let value = substitute(stmt, pat, '', '')
    let value = substitute(value, ';\s*', '', '')
    echo value
    let line1 = getline('.')
    let line2 = substitute(line1, '\<' . id . '\>', value, 'g')
    if line1 == line2
        return Warning('Did not find ' . id . ' on current line')
    endif
    call setline(line('.'), line2)
    " TODO: if stmt spans more than one line, this doesn't delete it all
    exec decl . ' delete'
endfunction

" Return the full java statement starting on this line, ending before next semicolon
function! GetJavaStmt(...)
    let line = a:0 > 0 ? a:1 : line('.')
    let result = ''
    let i = line
    while i <= line('$')
        let result = result . ' ' . substitute(getline(i), '\s//.*', '', '')
        let i = i + 1
        if result =~ ';'
            let result = substitute(result, ';.*', '', '')
            let result = substitute(result, '\s\+', ' ', 'g')
            return result
        endif
    endwhile
    return ''
endfunction

Help 'v ge - extract an expression into a variable'
vmap ge <esc>:call ExtractVar()<cr>
function! ExtractVar()
    if line("'<") != line("'>")
        return Warning('Selected expression must be on one line')
    endif
    let c1 = col("'<")-1
    let c2 = col("'>")
    if c1 == 0 && c2 == col('$')
        return Warning('Selected expression may not be entire line')
    endif
    let semi = ';'  " terminator on assignment line
    if &filetype == 'perl' || &filetype == 'vim'
        let var = Input('Enter <var>: ')
        if &filetype == 'perl'
            if var !~ '\$'
                let var = '$' . var
            endif
            let type = 'my'
        elseif &filetype == 'vim'
            let type = 'let'
            let semi = ''
        else
            call Error('Missing case')
        endif
    else
        if &filetype != 'java'
            call Warning('Warning: No explicit support for ' . &filetype)
        endif
        let in = Input('Enter <type> <var>: ')
        if in == ''
            return
        endif
        if in !~ ' ' || in =~ ' \S.* '
            return Warning('Enter two words, type and var')
        endif
        let type = substitute(in, ' .*', '', '')
        let var = substitute(in, '.* ', '', '')
    endif
    let line = getline('.')
    let pre = strpart(line, 0, c1)
    let expr = strpart(line, c1, c2-c1)
    let post = strpart(line, c2)
    let indent = substitute(line, '\S.*', '', '')
    call setline('.', pre . var . post)
    call append(line('.')-1, indent . type . ' ' . var . ' = ' . expr . semi)
    let @/ = expr
endfunction

Help 'J - join and delete space as appropriate'
nnoremap <silent> J :call Join()<cr>
function! Join()
    call Norm("J")
    let before = BeforeCursor(1)  " include cursor
    let after = AfterCursor(1)  " exclude cursor
    "echo "before|after: " . before . '|' . after
    if before =~ '( $'
        call Norm("x")  " delete the space
    elseif &ft == 'java' && before =~ ' $' && after =~ '^\.'
        call Norm('x')  " delete the space
    elseif &ft != 'txt' && after =~ '^[\[(]'
        call Norm('x')  " delete the space
    elseif &ft=='html'||&ft=='xhtml'||&ft=='xml'||&ft=='xsd'||&ft=='xslt'
        if after =~ '^\s*<' || before =~ '>\s*$'
            call DelAfterCursor('\s*')
        endif
        if before =~ '= $'
            call Norm('x')  " delete the space
        endif
    endif
endfunction

Help 'qf - edit a new file'
nmap qf gU:call CdToDir(1)<cr>:call EditFile()<cr><up>

" Write each line matching the current search pattern to the specified file.
" Output file will be overwritten.
command! -nargs=1 -complete=file GrepTo call delete(<q-args>) | global//.write! >> <args>

command! -nargs=? -complete=file Edit call EditCmd(<q-args>)
function! EditCmd(file)
    if a:file != ""
        exec "edit " . a:file
    elseif @* != "" && FileExists(@*)
        exec "edit " . @*
    else
        call Warning("no file name in copy buffer")
    endif
endfunction

function! EditFile()
    " Get matching suffixes to show up first by adding everything else
    " to &suffixes
    " bunch of commonly found suffixes
    let all_suffixes = "opt,co_,lex,dbg,pjx,sd,sc_,packlist,olb,res,mof,wiz,off"
        \.",ax_,lo_,ecf,dsr,prx,cl_,library,cs_,ocm,oc_,pty,cp_,ms_,opentools"
        \.",mi_,cn_,htt,msc,dcx,sll,dbc,ctl,dct,contrib,gi_,xsl,ax,com,aw,mdb"
        \.",pch,keep,bm_,ht_,ca_,cmd,wdx,htx,as_,sam,fon,emf,rtf,vbs,an_,ani"
        \.",cpl,id,drv,lc,pjt,mif,tab,vrg,asm,pf,idb,srg,ppt,app,1,dib,odl,tt_"
        \.",0,pkx,nls,schema,rc2,ic_,pdf,mnu,icm,prg,avi,map,dep,asf,ebs,snm"
        \.",prl,mdx,msk,frt,mak,au,fts,pku,gid,reg,cfg,tem,pot,cc,vct,vcx,inc"
        \.",ebx,sql,tlb,pod,zip,bs,template,sub,dsw,vbw,jpr,dot,fpt,css,js,exp"
        \.",wa_,def,png,elm,inl,fo_,wav,nl_,xls,log,cu_,cdx,ocx,sct,idl,scx,cab"
        \.",asp,frx,tmp,hl_,pdb,ttf,properties,dbf,sys,vbp,xml,url,sy_,rgs,ch_"
        \.",dsp,cnt,rc,jar,frm,ini,script,bas,cls,al,rvb,bat,chi,cur,vim,ex_"
        \.",wmf,mdl,cat,csv,class,hlp,sbr,jpg,pl,dir,hpp,dat,lib,chm,pnf,pm,in_"
        \.",c,lnk,ico,doc,inf,obj,dl_,txt,exe,java,bmp,cpp,dll,html,htm,gif,h"
        \.",ts,jade,sass"

    let save = SaveSet("suffixes", "+".all_suffixes)
    call AddBufRestore(save)
    "TODO: if ESC out, stays in b:buf_restore
    exec "set suffixes-=" . expand('%:e')
    call histadd(":", "Edit ")
endfunction

" Save text with p in visual mode; get it back with gt; view with ge

let g:vi_tmp = g:temp . '/vi.tmp'  " file to save text in
"let g:vi_tmp2 = '//tsk-build/share/tsk/vi.tmp'
let g:vi_txt = g:temp . '/vi.txt'
let g:vi_pat = g:temp . '/vi.pat'  " file to save search pattern in
let g:vi_pos = g:temp . '/vi.pos'  " file to save position in
" File to set tags
let g:tagspath = 'tagspath.vim'

" Don't scan included files -- too slow in Perl
set complete-=i
" have completion look in vi.tmp (but don't add more than once)
exec 'set complete-=k' . g:vi_tmp
exec 'set complete+=k' . g:vi_tmp

Help 'gt ,gt - get saved text from another vim session'
nmap gt :call SetCmd('read ' . g:vi_tmp, 'cpo', '-a')<cr>
"nmap ,gt :call SetCmd('read ' . g:vi_tmp2, 'cpo', '-a')<cr>
"Help 'ge - edit all old saved text from vim sessions'
"nmap ge gU:e c:\temp\vi.txt<cr>G
Help 'V p P ,p - put text to common temp file'
vmap p :<c-u>call PutText('', g:vi_tmp)<cr>
vmap P :<c-u>call PutText('>>', g:vi_tmp)<cr>
"vmap ,p :<c-u>call PutText('', g:vi_tmp2)<cr>
"vmap ,P :<c-u>call PutText('>>', g:vi_tmp2)<cr>
function! PutText(append, tmp)
    " don't change # to tmp; allow writes always
    let save = SaveSet('cpo', '-A') . SaveSet('write', 1)
    let col1 = col("'<")
    if line("'<") == line("'>") && col1 > 1
        let nchars = col("'>") - col1 + 1
        let x = strpart(getline("'<"), col1-1, nchars)
        call Write(x, a:tmp, a:append != '')
        echo '"' . a:tmp . '" 1L, ' . nchars . 'C written'
    else
        exec "'<,'>write!" . a:append . a:tmp
    endif
    "call system('perl -S vimsave.pl ' . a:tmp . ' ' . g:vi_txt)
    call RestoreSet(save)
endfunction

Help 'V ,di - diff selected text against common temp file (from "p" in visual mode)'
vmap ,di :<c-u>call DiffText()<cr>
function! DiffText()
    let tmp2 = g:vi_tmp . '2'
    call PutText('', tmp2)
    call system('page diff -w ' . g:vi_tmp . ' ' . tmp2)
endfunction

" Get the first line from a (possibly) multi-line string.
function! GetFirstLine(string)
    let string = substitute(a:string, g:nl . '.*', '', '')
    return string
endfunction

Help 's<c-v> - search for pattern from clipboard'
nmap s<c-v> :call histadd('/', GetFirstLine(@*))<cr>/<up><cr>

Help 'e/ - edit the current search pattern'
nmap e/ :call histadd('/', @/)<cr>/<up>

Help 's/ g/ - save and restore search pattern'
nmap s/ :call PutPattern()<cr>
nmap g/ :call GetPattern()<cr>n
function! PutPattern()
    call Write('let @/ = "' . escape(@/, '"\$') . '"', g:vi_pat)
    echo "wrote " . g:vi_pat
endfunction
function! GetPattern()
    exec "source " . g:vi_pat
    echo "/" . @/
endfunction

" Save and restore the current file name
Help ',fp ,fe ,fg - save current file name; edit saved file; get saved file'
nmap ,fp :call PutFilename()<cr>
nmap ,fe :exec '1 new ' . g:vi_tmp<cr>yy:close<cr>:call Edit(@@)<cr>
nmap ,fg gt
function! PutFilename()
    call Write(expand('%:p'), g:vi_tmp)
    call system('perl -S vimsave.pl ' . g:vi_tmp . ' ' . g:vi_txt)
endfunction

Help '[2348]ts - set tabstop and shiftwidth'
nmap 2ts :set ts=2 sw=2<cr>
nmap 3ts :set ts=3 sw=3<cr>
nmap 4ts :set ts=4 sw=4<cr>
nmap 8ts :set ts=8 sw=8<cr>

Help ',nm - create the skeleton of a new map that calls a function'
nmap ,nm :call NewMap()<cr>/\<[xX][xX]\><cr>
function! NewMap()
    let l = line('.')
    call append(l, '')
    call append(l, 'endfunction')
    call append(l, 'function! XX()')
    call append(l, 'nmap ,xx :call XX()<cr>')
    call append(l, 'Help ",xx - xx"')
endfunction

Help ',ma - show map and functions it calls'
nmap ,ma :call ShowMap()<cr>
function! ShowMap()
    let m = input("Map? ")
    echo "\r"
    if m == ""
        return Warning("Canceled")
    endif
    let rhs = maparg(m)
    if rhs == ""
        let rhs = maparg("," . m)
        if rhs == ""
            return Warning("no mapping found for " . m)
        endif
        let m = "," . m
    endif
    echo m rhs
    while 1
        let f = substitute(rhs, '.\{-}\<call \(\w\+\)(.*', '\1', '')
        if f == rhs
            break
        endif
        let rhs = substitute(rhs, '.\{-}\<call \(\w\+\)', '', '')
        exec "function " . f
    endwhile
endfunction

Help 'V ,tw - display highlighted text in temp window'
vmap <silent> ,tw y:call TempWinPut(6)<cr>
nmap <silent> ,tw :call TempWinPut(6)<cr>

Help 'gp zgp <c-x>gp gs - pop or show the location stack'
nmap gp :call Update(1)<bar>call PopLoc()<cr>
nmap <bs> gp
nmap <c-x>gp :call NextFile('gp')<cr>
nmap zgp :call NextFile('gp')<cr>
nmap gs :call ShowLoc()<cr>
" Jump to the current loc, so that it is put in the jump list.
" Use this before movement commands that wouldn't otherwise add to jump list.
Help 'g. - put current pos in jump list'
nmap <silent> g. :call Norm(GetPos())<cr>
Help 'gU - update & push current pos'
nmap gU g.:call Update(1)<bar>call PushLoc()<cr>


" use e as prefix; ee as old e
nnoremap ee e

"???
Help 'el/eh - next/prev tab'
nmap el :call Update(1)<bar>tabnext<bar>e%<cr>
nmap eh :call Update(1)<bar>tabprev<bar>e%<cr>

Help 'ef - list the current dir'
nmap ef ,ls

" Go to parallel stream, based on number
nmap <silent> e0 :call EditOtherStream(0)<cr>
nmap <silent> e1 :call EditOtherStream(1)<cr>
nmap <silent> e2 :call EditOtherStream(2)<cr>
function! EditOtherStream(n)
    let n = a:n
    if !Update() | return | endif
    let path = expand("%:p")
    let p1 = MatchNth(path, '\(.*\)\(\\r_.*\)', 1)
    if p1 == ''
        return Warning('not in a view: ' . path)
    endif
    let p2 = MatchNth(path, '\(.*\)\(\\r_.*\)', 2)
    let p1 = substitute(p1, '_\d\+$', '', '')
    let num = n == 0 ? '' : '_' . n
    let other = p1 . num . p2
    call Edit(other)
endfunction

" execute the current file in its directory and view its output
Help 'eo - edit the output of executing the current file'
Help ',eo - edit the output of running a command'
Help 'ec - change the command for eo'
Help ',ro - read the output of a command set by ec'
"nmap eo :call EditOutput()<cr>:echo "status = " . v:shell_error <cr>
nmap <silent> eo :echo EditOutput()<cr>
"TODO this doesn't work:
nmap <silent> ec :call histadd(":", "let b:outputcmd='" . EvalVar("b:outputcmd") . "'")<cr>:<up>
nmap ,eo :call histadd(":", "Run " . EvalVar("b:outputcmd"))<cr>:<up>
"nmap ,eo :call EditOutputCmd()<cr>:<up>
nmap ,ro :exec "read! " . EvalVar("b:outputcmd", @%)<cr>
command! -nargs=* Run let b:outputcmd = <q-args><bar>call EditOutput()
function! EditOutput()
    if !Update() | return | endif
    call CdToDir()
    let save = SaveSet('ch', 2)
    " See if the file specifies a cmd
    if getline(1) =~ '[ :]eo: '
        let cmd = substitute(getline(1), '.*[ :]eo:  *', '', '')
        let b:outputcmd = cmd
        let b:outputcmd_from_file = 1  " can't edit it with ,eo
    endif
    if EvalVar('b:outputcmd') == ''
        let cmd = @%
        if @% =~ '\.pl$'
            let cmd = @%
        elseif @% =~ '\.rb'
            let cmd = 'ruby ' . expand('%:t')
        else
            exec save
            return 'no output command set'
        endif
        let b:outputcmd = cmd
    else
        let cmd = b:outputcmd
        let cmd = substitute(cmd, '%', @%, 'g')
    endif
    call TempWin(10)
    let &titlestring = "! " . cmd
    exec 'silent read !' . cmd . ' 2>&1'
    keepjumps 1 delete
    set nomod
    exec save
    call WinShrink2()
    if line('$') == 1 && getline(1) == ""
        " nothing here, so close window
        " can't distinguish no lines from 1 empty line?
        close
    endif
    return 'status = ' . v:shell_error
endfunction
"function! EditOutputCmd()
"    if exists('b:outputcmd_from_file')
"        call Warning("edit command by changing first line of file")
"    else
"        call histadd(":", "Run " . EvalVar("b:outputcmd"))
"    endif
"endfunction

Help 'eb - edit backup file'
nmap eb :call EditBackup()<cr>
function! EditBackup()
    if !Update() | return | endif
    let f = system('perl -S autosave.pl -prev ' . @%)
    if f == ''
        return Warning("can't find backup file for " . @%)
    endif
    call EditFT(f)
endfunction

Help 'ex - edit an ex command and then execute it'
nmap <silent> ex :call EditCommand()<cr>
function! EditCommand()
    if !Update() | return | endif
    call TempWin(1)
    set insertmode
    nmap <buffer> <silent> <cr> :set nomod<cr>:call EditCommandFinish()<cr>
    imap <buffer> <silent> <cr> <esc>:set nomod<cr>:call EditCommandFinish()<cr>
endfunction
function! EditCommandFinish()
    set noinsertmode
    let cmd = getline('.')
    close
    call histadd(':', cmd)
    exec cmd
endfunction

Help 'eg - edit grep output in temp window'
nmap <silent> eg :call EditGrep()<cr>
function! EditGrep()
    if !Update() | return | endif
    call histadd('input', @/)
    let pat = input("Pattern? ")
    echo "\r"
    if pat == ""
        return Warning("Canceled")
    endif
    let save = SaveSet('report', 999999)
    1,$ yank
    call TempWin(10)
    put
    1 delete
    exec "v/" . pat . "/d"
    exec save
endfunction

Help 'ca - copy entire file into clipboard'
nnoremap ca :1,$y*<cr>

Help 'cp - get path of file into clipboard'
nnoremap cp :let @* = expand("%:p")<cr>:echo @*<cr>

Help 'cP - get path of file and line number into clipboard'
nnoremap cP :let @* = expand('%:p') . ':' . line('.')<cr>:echo @*<cr>

Help 'ep - edit the current path and jump to new name'
nmap <silent> ep :call EditPath()<cr>
function! EditPath()
    if !Update() | return | endif
    " preserve the unnamed buffer
    let g:edit_path_save = @@
    let path = expand("%:p")
    call TempWin(VirtLines(path))
    call append(0, path)
    $ delete
    nmap <buffer> <silent> <cr> :set nomod<cr>:call EditPathGo()<cr>
    imap <buffer> <silent> <cr> <esc>:set nomod<cr>:call EditPathGo()<cr>
endfunction
" we are on a line containing the path -- jump there
function! EditPathGo()
    let path = getline(".")
    close
    if path =~ '[*?]'
        let path = system('perlglob "' . path . '"')
    endif
    let @@ = g:edit_path_save
    unlet g:edit_path_save
    call Edit(path)
endfunction

Help ',GU - start guidgen to generate guids'
nmap ,GU :!start guidgen<cr>
Help ',gu - insert a GUID from the copy buffer'
nmap ,gu :call InsertGUID()<cr>
function! InsertGUID()
    let guid = substitute(@*, '^{*\([-a-fA-F0-9]*\)}*'."\n$", '\1', '')
    if guid !~ '^\x\{8}-\x\{4}-\x\{4}-\x\{4}-\x\{12}$'
        return Warning("paste buffer does not contain guid: " . @*)
    endif
    if GetAfter() =~ '^uuid('
        let cmd = "cf)uuid"
    else
        let cmd = "a"
    endif
    call Norm(cmd . "(" . guid . ")\<esc>")
endfunction


" Get this line from beginning to just before cursor.
function! GetBefore()
    return strpart(getline("."), 0, col(".")-1)
endfunction

" Get this line from cursor to end.
function! GetAfter()
    return strpart(getline("."), col(".")-1, 999999)
endfunction

nmap ,mv :call MoveOrCopy('mv')<cr>
nmap ,cp :call MoveOrCopy('cp')<cr>
function! MoveOrCopy(op)
    let op = a:op
    if op != 'mv' && op != 'cp'
        return Error('Internal error: bad op to MoveOrCopy: ' . op)
    endif
    if !Update() | return | endif
    call CdToDir()
    let from = expand("%")
    call histadd("input", from)
    let to = input(op . ' ' . from . " where? ")
    echo "\r"
    if to == ""
        return Warning("Canceled     ")
    endif
    if isdirectory(to)
        let to = to . "\\" . from
    endif
    if filereadable(to)
        let x = input('Overwrite "' . to . '"? ')
        echo "\r"
        if x !~ '^[yY]'
            return Warning("Canceled     ")
        endif
    endif
    " let opt = ' /y '  "Windows
    let opt = ' '
    echo op . opt . from . ' ' . to . ' 2>&1'
    call Warning(Chomp(system(op . opt . from . ' ' . to . ' 2>&1')))
    if filereadable(to) && !filereadable(from)
        call Edit(to)
    endif
endfunction

" Reindent the file from the current indentation size (in shiftwidth) to the
" specified one, default 4.
nmap ,ri :call Reindent()<cr>
function! Reindent(...)
    if a:0 > 0
        let newts = a:1
    else
        let newts = 4
    endif
    if &shiftwidth == newts
        return Warning("shiftwidth is already set to " . newts)
    endif
    let save = SaveSet("expandtab", 1)
    % retab
    let &tabstop = &shiftwidth
    let &expandtab = 0
    % retab!
    exec save
    let &tabstop = newts
    let &shiftwidth = newts
    % retab
endfunction

" Remove tabs from file with current tabstop setting and remove trailing
" spaces.  Preserve position and search pattern.
nnoremap ,RT :set expandtab<cr>:call Retab(1, line('$'), 1)<cr>
vnoremap ,rt :<c-u>call Retab(line("'<"), line("'>"), 1)<cr>
nnoremap ,rt :call Retab(1, line('$'), &expandtab)<cr>
function! Retab(first, last, expandtab)
    let pos = GetPos()
    let pat = @/
    let expandtab = &expandtab
    let &expandtab = a:expandtab
    let range = a:first . ',' . a:last
    exec range . 'retab!'
    exec 'silent! ' . range . 's/\s\+$//'
    let @/ = pat
    let &expandtab = expandtab
    call Norm(pos)
endfunction

" Operate on y buffer:  yx, yd - yank, delete into it; yc - clear; ys - show
" yp - put; Vmode: x, X - yank, delete
Help 'yx yd - yank/delete current line appending to y buffer'
Help 'V x X - yank/delete highlighted lines appending to y buffer'
Help 'ys yc - show/clean y buffer'
Help 'yp - put y buffer'
Help 'yg gy - grep whole file for current search pattern and put in y buffer'
Help 'V gy - grep highlighted lines for current search pattern and put in y buffer'
nmap yx "Yyy:echo Lines(@y) "lines"<cr>
nmap yd "Ydd
nmap yc :let @y=""<cr>
nmap ys :call Bold("y buffer:")<bar>echo Chomp2(@y)<cr>
nmap yp "yp
nmap yg :call GrepBuffer(1, line('$'))<cr>
nmap gy yg
vmap x  "Yy
vmap X  "Yd
vmap gy :<c-u>call GrepBuffer(line("'<"), line("'>"))<cr>

function! GrepBuffer(line0, line1)
    let line0 = a:line0
    let line1 = a:line1
    let pos = getpos('.')
    let @y = ""
    let matches = 0
    call cursor(line0, 1)
    while search(@/, 'c', line1) > 0
        yank Y
        call cursor(line('.')+1, 1)  " only match once per line
        let matches = matches + 1
    endwhile
    call setpos('.', pos)
    echo matches . ' matches'
endfunction

" use b as prefix; bb as old b
nnoremap bb b
nmap bd :bdelete<cr>

nmap bu :Buffer<space>
command! -nargs=1 -complete=buffer -complete=file Buffer call Buffer(<q-args>)
function! Buffer(b)
    call CdToDir()
    if !Update() | return | endif
    let b = a:b
    let n = bufnr(b)
    if n != -1 && match(bufname(n), b) == 0
        " match at start
        exec 'buffer ' . n
    elseif filereadable(b)
        exec 'edit ' . b
    elseif n != -1
        " match anywhere
        exec 'buffer ' . n
    else
        let n = BufMatch(b)
        if n != -1
            exec 'buffer ' . n
        else
            let f = Chomp(system('glob.pl ' . b . '*'))
            if f == ''
                call Warning('no match for ' . b)
            elseif match(f, "\n") != -1
                call Warning(b . ' is ambiguous; could be: '
                    \ . substitute(f, "\n", " ", "g"))
            else
                exec 'edit ' . f
            endif
        endif
    endif
endfunction

" match pat against buffer names, returning buffer number if found
function! BufMatch(pat)
    let bufs = ViCmd('buffers')
    let n = TryBufMatch(bufs, '\<' . a:pat . '\>')
    if n != -1 | return n | endif
    let n = TryBufMatch(bufs, '\<' . a:pat)
    if n != -1 | return n | endif
    let n = TryBufMatch(bufs, a:pat . '\>')
    if n != -1 | return n | endif
    let n = TryBufMatch(bufs, a:pat)
    if n != -1 | return n | endif
    return -1
endfunction

function! TryBufMatch(bufs, pat)
    let n = Match1(a:bufs, ' \(\d\+\) [^"]* "[^"]*' . a:pat . '[^"]*"')
    return n == '' ? -1 : n
endfunction

"    if n != -1
"        exec 'buffer ' . n
"        return
"    endif
"    " try to find a match -- first at start
"    let bufs = ViCmd("buffers")
"    let x = Match1(bufs, ' \(\d\+\) [^"]* "' . b)
"    if x != ''
"        echo "x = " . x
"    endif
"echo "??? bufs = <".bufs.">"
"endfunction

Help 'b1 - go to the first listed buffer (i.e. not deleted)'
"nmap <silent> b1 :call FirstBuffer()<cr>
nmap <silent> b1 :call GotoBuffer(1)<cr>
nmap <silent> b2 :call GotoBuffer(2)<cr>
nmap <silent> b3 :call GotoBuffer(3)<cr>
nmap <silent> b4 :call GotoBuffer(4)<cr>
nmap <silent> b5 :call GotoBuffer(5)<cr>
nmap <silent> b6 :call GotoBuffer(6)<cr>
nmap <silent> b7 :call GotoBuffer(7)<cr>
nmap <silent> b8 :call GotoBuffer(8)<cr>
nmap <silent> b9 :call GotoBuffer(9)<cr>
" Go to buffer number num, skipping deleted ones and those with empty names
function! GotoBuffer(num)
    if !Update() | return | endif
    call BufferMaps()
    let b = 0
    let num = a:num
    while num > 0
        let b = b + 1
        if !bufexists(b)
            return Warning(
                \ 'There are only ' . (a:num-num) . ' undeleted buffers')
        endif
        if buflisted(b) && bufname(b) != ''
            let num = num - 1
        endif
    endwhile
    if bufnr('%') == b
        " already at that buffer
        echo bufname(b)
    else
        exec 'buffer ' . b
    endif
endfunction

"function! FirstBuffer()
"    if !Update() | return | endif
"    call BufferMaps()
"    let i = 1
"    while !buflisted(i)
"        let i = i + 1
"    endwhile
"    exec "buffer " . i
"endfunction

"Note: this used to be for tags, but no longer used
Help ',tm - make ^N, ^P go through tabs'
nmap ,tm :call TabMaps()<cr>
function! TabMaps()
    nmap <c-n> :tabnext<cr>
    nmap <c-p> :tabprev<cr>
    nmap <c-j> :tabs<cr>
    nmap <c-k> <esc>
endfunction

Help ',bm - switch to buffer maps for ^N, ^P, ^J'
nmap ,bm :call BufferMaps()<cr>
function! BufferMaps()
    nmap <c-n> :bnext<cr>
    nmap <c-p> :bprev<cr>
    nmap <c-j> :buffers<cr>
    nmap <c-k> <esc>
endfunction

"TODO - not done
Help 'V ( ) - add or remove parens around highlighted area'
vmap ( :<c-u>call AddParens()<cr>
function! AddParens()
"    if getline("'<") != getline("'>")
"        return Warning("cannot span lines")
"    endif
    let c1 = col("'<")
    let c2 = col("'>")
    if c2 < 0
        call Norm("gvv\<esc>")
        let c1 = col("'<")
        let c2 = col("'>")
    endif
    let l1 = line("'<")
    let l2 = line("'>")
    let x1 = getline(l1)
    if l1 != l2
        let x2 = getline(l2)
    else
        let y2 = substitute(x2, '^\(.\{'.(c2-1).'}\))\s*', '\1', '')

        let x1 = strpart(l1, 0, c1)
        let x2 = strpart(l2, c2-1)
        if x1 =~ '($'
        if x2 !~ '^)'
            return Warning(
                \ "visual area starts with '(' but doesn't end with ')'")
        endif
        " remove parens
    else
        if x2 =~ '^)'
            return Warning(
                \ "visual area ends with ')' but doesn't start with '('")
        endif
        " add parens
    endif
    return
    call Norm("`<d`>x")
    let x = @2 . @1  " stuff deleted
    let y = substitute(x, '(\(.*\))$', '\1', '')
    if x != y
        let @@ = y
        call Norm('P')
    endif

endfunction

nmap <silent> D( :call DeleteParens('(')<cr>
nmap <silent> D{ :call DeleteParens('{')<cr>
nmap <silent> D[ :call DeleteParens('[')<cr>
nmap <silent> D< :call DeleteParens('<')<cr>
function! DeleteParens(paren)
    let c = GetChar()
    if c != a:paren
        call Norm("dt" . a:paren)
    endif
    let before = BeforeCursor()
    let after = AfterCursor()
    call Norm2("%x``x")
    if before =~ '\S$' && after =~ '^.\S'
        call Norm2("i \<esc>")
    endif
endfunction

nmap d: d2f:
nmap c: c2f:

"??? add dummy mappings for sX for all X
" use s as prefix; ss means old s
nnoremap ss s
nnoremap 1s 1s
nnoremap 2s 2s
nnoremap 3s 3s
nnoremap 4s 4s
nnoremap 5s 5s
nnoremap 6s 6s
nnoremap 7s 7s
nnoremap 8s 8s
nnoremap 9s 9s

Help 'sb - search for multiple (>1) blank lines'
nmap sb :call SearchBlankLines()<cr>
function! SearchBlankLines()
    let start_pos = line('.')
    while 1
        let prev_pos = line('.')
        let l1 = search('^\s*$', 'n')
        if l1 == 0
            echo "No blank lines found"
            return
        endif
        "if l1 >= start_pos && (prev_pos < start_pos || prev_pos > l1)
        if (prev_pos < start_pos && (l1 < prev_pos || l1 >= start_pos))
        \ || (l1 < prev_pos && l1 >= start_pos)
            " went past start_pos without finding a match
            call cursor(start_pos, 1)
            echo "No multiple blank lines found"
            return
        endif

        call cursor(l1, 1)
        let l2 = search('^\s*$', 'n')
        if l2 == l1 + 1
            " found a match
            call cursor(start_pos, 1)
            call AddToJumpList()
            call cursor(l1, 1)
            call PushSearchMapping('n', 'sb')
            "nmap n sb
            return
        endif
    endwhile
endfunction

" Add current position to jump list (jumplist)
function! AddToJumpList()
    exec "normal m'"
endfunction

" Search for a line that contains text.
" It may be preceded by whitespace.
function! SearchLine(text)
    let pat = '\(^\s*\)\@<=' . QuoteMeta(a:text)
    call search(pat)
endfunction

" Make a regex that matches this string literally
function! QuoteMeta(text)
    return '\V' . escape(a:text, '\')
endfunction

Help 's0 s1 s2 s3 - search for next public/package/protected/private decl'
nmap s0 /^\s*public\>/<cr>
nmap s2 /^\s*protected\>/<cr>
nmap s3 /^\s*private\>/<cr>

"nmap s0 :call SearchProt('public')<cr>
"nmap s1 :call SearchProt('')<cr>
"nmap s2 :call SearchProt('protected')<cr>
"nmap s3 :call SearchProt('private')<cr>
function! SearchProt(key)
    let key = a:key
    if key != ''
        if search('^\s*' . key . ' ') == 0
            call Warning('no ' . key . ' declarations found')
        endif
    else
        "TODO
    endif
endfunction

let g:java_qual_pat = '\(public\s\+\|private\s\+\|protected\s\+\|\)'

Help 'si - search for constructor of main class in this file'
nmap si :call SearchCtor()<cr>n
function! SearchCtor()
    let class = expand("%:t:r")
"    let @/ = '^\s*\(public\|private\|protected\|\)\s*' . class . '\s*(.*'
    let @/ = '^\s*' . g:java_qual_pat . class . '\s*(.*'
endfunction

" What was this for?
"Help 'sf - search for private fields'
"nmap sf /^\s*private\s.*\(=.*\\|[^\s{}()]\s*\)$<cr>

Help 'sf - search for word under cursor as field ref that is not qualified with this.'
nmap sf :call SearchField()<cr>n
function! SearchField()
    let field = GetWord()
"    let pat = '\C\(^.*//.*\|^.*\<this\.\|^\s*\*\s.*\)\@<!\<' . field . '\>'
    " want field not preceded by 'this.' or '//.*' or '/\*.*' or '^\s*\*\s.*'
    " last three are to avoid comments
    let pat = '\C\(/[/*].*\|\<this\.\|^\s*\*\s.*\)\@<!\<' . field . '\>'
    let @/ = pat
endfunction

Help 'sa - search for current id in "alternate" file'
nmap sa m*ean
Help 'so - search for current id in "other" file'
nmap so m*gon
Help 'sw - search for same pattern as a word (or non-word if already word)'
nmap sw :call SearchWord()<cr>n
function! SearchWord()
    let nonword = substitute(@/, '^\\<\(.*\)\\>$', '\1', '')
    if nonword != @/
        let @/ = nonword  " change word to non-word
    else
        let test_pat = 'x' . @/ . 'x'
        let pat = @/
        if pat =~ '\\|'  " add parens around pat if necesary
            let pat = '\(' . pat . '\)'
        endif
        if test_pat !~ '^x\>'  " check if it already starts with word boundary
            let pat = '\<' . pat
        endif
        if test_pat !~ '\<x$'  " check if it already ends with word boundary
            let pat = pat . '\>'
        endif
        let @/ = pat
    endif
endfunction

"TODO: which is easier to remember s* or ,/ ?
Help ',/ - search for pattern in clipboard'
Help ',w/ - search for pattern in clipboard as word'
        \ . ' (or non-word if already word)'
nmap ,/  :let @/ = @*<cr>n
nmap ,w/ :let @/ = @*<cr>sw

Help 'sg* - search for pattern in clipboard'
Help 's* - search for pattern in clipboard as word'
        \ . ' (or non-word if already word)'
nmap s*  :let @/ = @*<cr>sw
nmap sg* :let @/ = @*<cr>n


" toggle which chars are part of iskeyword
nmap ,k_ :call ToggleIsKeyword('_')<cr>
nmap ,k- :call ToggleIsKeyword('-')<cr>
nmap ,k. :call ToggleIsKeyword('.')<cr>
nmap ,kk :call ToggleIsKeyword()<cr>
function! ToggleIsKeyword(...)
    if a:0 > 0
        let char = a:1
    else
        let char = input('char? ')
        echo "\r"
        if strlen(char) != 1
            return Warning("Canceled")
        endif
    endif
    let old = &iskeyword
    exec "set iskeyword-=" . char
    if old == &iskeyword
        echo "set iskeyword+=" . char
        exec "set iskeyword+=" . char
    else
        echo "set iskeyword-=" . char
    endif
    nohlsearch
endfunction

Help 'sc - search for current pattern case-sensitively'
nmap sc :call MakeCaseSensitive()<cr>n
function! MakeCaseSensitive()
    if HasUpperCase(@/)
        let @/ = @/
    else
        let @/ = '\(' . @/ . '\)\|RandomUpperCasePattern'
    endif
    set smartcase
endfunction

Help 'sn sN - search again for non-comment'
nmap sn :call SearchNonComment('n')<cr>
nmap sN :call SearchNonComment('N')<cr>
function! SearchNonComment(cmd)
    let pos = GetPos()
    let match1 = ''
    while 1
        call Norm(a:cmd)
        if match1 == ''
            let match1 = GetPos(1)
        elseif GetPos(1) == match1
            call Norm(pos)  " go back where we were
            return Error('no non-Comment match')
        endif
        if GetSyntaxTranslated() != 'Comment'
            return
        endif
    endwhile
endfunction

Help 's! - search for the next line that does not match the current pattern'
nmap s! :call SearchNonMatch()<cr>
Help 's1 - search for the next line that does not match the current word'
nmap s1 *<c-o>s!
function! SearchNonMatch()
    let pos = GetPos()
	let pat = @/
	let last = line('$')
	let start = line('.')
	let l = start
	while 1
		call Normal('$')  " don't match current line
		let x = search(pat, 'W')  " could use '' to get wrapscan effect
		"TODO x may be current line
		let l = l + 1
		if x != l
"			call Norm(l . 'Gz.')
			call Norm(l . 'G')
			break
		endif
		if l == last
			call Norm(pos)
			return Warning('no lines failed to match: ' . pat)
		endif
	endwhile
endfunction

Help 'd# - count the number lines added/removed in a diff'
nmap d# :call DiffCount()<cr>
function! DiffCount()
    let add = SearchCount('^+ ')
    let rem = SearchCount('^- ')
    let delta = add - rem
    if delta >= 0
        let what = 'added'
    else
        let what = 'removed'
        let delta = -delta
    endif
    echo what . ' ' . delta . ' lines net (' . add . ' added, ' . rem . ' removed)'
endfunction

Help 's# - count the number of matches for the search pattern'
nmap s# :echo SearchCount(@/) . ' matches'<cr>
function! SearchCount(pat)
    let pos = GetPos()
    1
    let matches = 0
    while search(a:pat, 'W') > 0
        let matches = matches + 1
    endwhile
"    echo matches . ' matches'
    call Norm(pos)
    return matches
endfunction

"Help 'sv - search for perl var under cursor'
"nmap sv :call SearchVar()<cr>n
"function! SearchVar()
"    let save = SaveSet('iskeyword', '+$,@-@,%')
"    let var = expand("<cword>")
"    exec save
"    if var !~ '\k'
"        return Warning('not on a var')
"    endif
"    let @/ = MakeWordPat(escape(var, '$'))
"endfunction

Help 'sv - search for vlad leavings in java source file'
nmap sv :call SearchVlad()<cr>n
function! SearchVlad()
    let @/ = '\(\<\l*_\w*\>\|//\s*[-_=/]\{3,}\)'
endfunction

" \< and \> only match before/after keyword -- can't add unnecessarily
function! MakeWordPat(pat)
    let pat = a:pat
    if pat =~ '^\k'
        let pat = '\<' . pat
    endif
    if pat =~ '\k$'
        let pat = pat . '\>'
    endif
    return pat
endfunction

Help '* - search for current word using regular rules, including smartcase'
nnoremap <silent> * :call SearchCurrentWord()<cr>n
function! SearchCurrentWord()
    let word = expand("<cword>")
    if word == ''
        return Warning('not on word')
    endif
    let @/ = '\<' . word . '\>'
endfunction

Help 'm* - like * but do not move'
nmap <silent> m* :call SearchCurrentWord()<cr>
"nmap <silent> m* :let @/ = expand("<cword>")<cr>

"??? Hijack r -- do we want to do this?
"Use for "replace" and "reverse" operations

Help 'v r, - reverse selected text around a comma'
vmap r, <esc>:call Reverse('\s*,\s*')<cr>
vmap r<space> <esc>:call Reverse(' ')<cr>
vmap rv <esc>:call ReversePrompt()<cr>
" Reverse selected text around a pattern
function! Reverse(pat)
    let text = GetVisual()
    let text2 = substitute(text,
        \ '^\(.*\)\(' . a:pat . '\)\(.*\)$', '\3\2\1', '')
    if text2 == text
        return Warning('No change')
    endif
    call Norm('gvs' . text2)
    call Highlight(a:pat)
endfunction
function! ReversePrompt()
    let pat = input('Pattern to reverse around: ')
    if pat == ''
        return Warning('Canceled')
    endif
    call Reverse(pat)
endfunction

" Get the text selected by the visual selection.
function! GetVisual()
    let save = @@
    call Norm('gvy')
    let result = @@
    let @@ = save
    return result
endfunction

Help 'v r? - reverse conditional expression'
vmap r? <esc>:call ReverseCondExpr()<cr>
function! ReverseCondExpr()
    if line("'<") != line("'>")
        return Warning('Conditional must be all on one line');
    endif
    let text = GetVisual()
    let pat = '^\(.*\S\)\s*?\s*\(.*\S\)\s*:\s*\(.*\)$'
    let cond = substitute(text, pat, '\1', '')
    if cond == text
        return Warning('Failed to parse conditional: ' . text)
    endif
    let true = substitute(text, pat, '\2', '')
    let false = substitute(text, pat, '\3', '')
    let text2 = ReverseCond(cond) . ' ? ' . false . ' : ' . true
    call Norm('gvs' . text2)
endfunction

Help ',rI - reverse if statement on current line'
map ,rI :call ReverseIf()<cr>
function! ReverseIf()
    let l0 = line('.')
    call Norm('0')
    let l1 = search('^\s*if\s*(', 'cnW')
    if l1 != l0
        return Warning('Did not find "if (" on current line')
    endif
    call Norm('f(')
    let cond = getpos('.')  " start of condition
    call Norm('%')
    let after = AfterCursor()
    if after =~ ')\s*{'
        " brace on same line
    elseif after =~ '^)\s*$'
        call Norm('j0')
        let after = AfterCursor()
        if after !~ '^\s*{'
            return Warning('Expected "{", found: ' . after)
        endif
    else
        return Warning('Expected ") {", found: ' . after)
    endif
    call Norm('f{v%y%')
    let then_end = getpos('.')  " end of then
    let then_part = @"
    let after = AfterCursor()
    if after =~ '^}\s*else\s*{'
        " okay
    else
        return Error("TODO: else on new line")
    endif
    call Norm('f{v%y')
    let else_part = @"
    let @" = then_part
    call Norm('v%p')  " replace else with then
    call setpos('.', then_end)
    let @" = else_part
    call Norm('v%p')  " replace then with else
    call setpos('.', cond)
    call Norm('v%y')
"    let cond_part = @"
"    if cond_part =~ '^([^()]*==[^()]*)$'
"        let cond_part = substitute(cond_part, '==', '!=', '')
"    elseif cond_part =~ '^([^()]*!=[^()]*)$'
"        let cond_part = substitute(cond_part, '!=', '==', '')
"    elseif cond_part =~ '^(![^&|^?!]*)$'
"        let cond_part = substitute(cond_part, '!', '', '')
"    else
"        " default
"        let cond_part = '(!' . cond_part . ')'
"    endif
"    let @" = cond_part
    let @" = ReverseCondIf(@")
    call Norm('v%p')
endfunction

" Reverse a condition from an if.  Expect parens around it.
function! ReverseCondIf(cond)
    if a:cond =~ '^(.*)'
        let cond = substitute(a:cond, '^(\(.*\))$', '\1', '')
        return '(' . Reverse(cond) . ')'
    else
        " unexpected: no parens around cond
        return '!(' . a:cond . ')'
    endif
endfunction

" Reverse a condition
function! ReverseCond(cond)
    if a:cond =~ '^[^()]*==[^()]*$'
        return substitute(a:cond, '==', '!=', '')
    elseif a:cond =~ '^[^()]*!=[^()]*$'
        return substitute(a:cond, '!=', '==', '')
    elseif a:cond =~ '^![^&|^?!]*$'
        return substitute(a:cond, '!', '', '')
    else
        " default
        return '!(' . a:cond . ')'
    endif
endfunction

Help 'v rw - replace one word with another in all cases (foo, Foo, FOO)'
vmap rw <esc>:call ReplaceWord()<cr>
function! ReplaceWord()
    let x = Input('enter old/new: ')
    if x == ''
        return
    endif
    if x !~ '/'
        return Warning('enter two words separated by /')
    endif
    if x !~# '^[A-Za-z0-9_]\+/[A-Za-z0-9_]\+$'
        return Warning 'words must be letters, numbers, or _'
    endif
    let w1 = substitute(x, '/.*', '', '')
    let w2 = substitute(x, '.*/', '', '')

    let save = SaveSet('ignorecase', 0)
    " fooFoo => barBar
    exec "silent! '<,'> s/" . w1 . '/' . w2 . '/g'
    " FooFoo => BarBar
    let w1 = substitute(w1, '\(.\)', '\U\1', '')
    let w2 = substitute(w2, '\(.\)', '\U\1', '')
    exec "silent! '<,'> s/" . w1 . '/' . w2 . '/g'
    " FOO_FOO => BAR_BAR
    let w1 = substitute(w1, '\(.\)\([A-Z]\)', '\1_\2', 'g')
    let w1 = substitute(w1, '\(.*\)', '\U\1', '')
    let w2 = substitute(w2, '\(.\)\([A-Z]\)', '\1_\2', 'g')
    let w2 = substitute(w2, '\(.*\)', '\U\1', '')
    exec "silent! '<,'> s/" . w1 . '/' . w2 . '/g'
    exec save
endfunction

if 0

Help 'dm - delete current partial word; e.g. Foo in BarFooGorn'
nmap sm  :call SubPartialWord(0)<cr>,SP
nmap dm  :call SubPartialWord(1)<cr>,SP

" Substitute for current partial word:  map ,SP to the appropriate action
"??? what about in middle of partial word?
function! SubPartialWord(do_delete)
    let save = SaveSet('ignorecase', 0)
    let len = matchend(AfterCursor(), '^[A-Za-z][a-z]\+')
    exec save
    let mapping = "nnoremap ,SP "
    if len == -1
        let mapping = mapping . ":call Warning('not on partial word')<cr>"
    elseif a:do_delete
        let mapping = mapping . len . "x"
    else
        let mapping = mapping . len . "s"
    endif
    exec mapping
endfunction

endif


" ,sw - global substitute for current pattern
" TODO: figure out escaping backslash: don't want to do it for \<asdf\>
nmap ,sw  :call histadd(":", "%s/".escape(@/,'/')."//g")<cr>:<up><left><left>
vmap ,sw y:call histadd(":", "%s/".escape(@@,'\\/')."//g")<cr>:<up><left><left>

" Substitute for current pattern.  SubPat maps ,SP to the appropriate action
nmap sp :call SubPat(0)<cr>,SP
nmap dp :call SubPat(1)<cr>,SP
function! SubPat(do_delete)
    let len = matchend(AfterCursor(), '^' . @/)
    let mapping = "nnoremap ,SP "
    if len == -1
        let mapping = mapping . ":call Warning('not on pattern /".@/."/')<cr>"
    elseif a:do_delete
        let mapping = mapping . len . "x"
    else
        let mapping = mapping . len . "s"
    endif
    exec mapping
endfunction

Help 's> - split after ">"'
nmap s> :call SplitAfter('>')<cr>
Help 's< - split after "<"'
nmap s< :call SplitBefore('<[^<]*$')<cr><<<<k^
Help 's+ - split before "+"'
nmap s+ :call SplitBefore('+')<cr>
Help 's= - split before "="'
nmap s= :call SplitBefore('=')<cr>
Help 's, - split after ","'
nmap s, :call SplitAfter(',')<cr>
Help 's; - split after ";"'
nmap s; :call SplitAfter(';')<cr>
Help 's( - split after "("'
nmap s( :call SplitAfter('(')<cr>
Help 's? - split before "?" in conditional expr'
nmap s? :call SplitBefore('?')<cr>
Help 's: - split before ":" in conditional expr'
" NOTE: match only : not next to other ones because of Foo::bar in perl
nmap s: :call SplitBefore(':\@<!::\@!')<cr>

function! SplitBefore(pat)
    let in = matchstr(getline('.'), '\s*') . Spaces(&shiftwidth)
"    exec 's/\s*' . a:pat . "/\<cr>" . in . a:pat . '/'
    exec "s/\\s*\\(" . a:pat . "\\)/\<cr>" . in . "\\1/"
endfunction
function! SplitAfter(pat)
    let in = matchstr(getline('.'), '\s*') . Spaces(&shiftwidth)
"    exec 's/' . a:pat . '\s*/' . a:pat . "\<cr>" . in . '/'
    exec "s/\\(" . a:pat . "\\)\\s*/\\1\<cr>" . in . "/g"
endfunction

" n spaces
function! Spaces(n)
    let x = ''
    let n = a:n
    while n > 0
        let n = n - 1
        let x = x . ' '
    endwhile
    return x
endfunction

" execute the file name under the cursor
nmap ,ef :call system(expand("<cfile>"))<cr>
"nmap ,re :e%<cr>
nmap <silent> ,re :call ReEdit()<cr>
function! ReEdit()
    if !Update() | return | endif
    let pos = GetPos()
    if expand('%') == ''
        " assume we are editting a dir
        edit .
    else
        edit %
    endif
    call Norm(pos)
endfunction

" start cmd interpreter
nmap ,cm ,di:!start cmd<cr>
nmap ,sh ,cm

" Diff two strings
" Problem: newlines come out as ^@
function! DiffStr(str1, str2)
    let tmp1 = GetTemp('diff1')
    let tmp2 = GetTemp('diff2')
    call Write(a:str1, tmp1)
    call Write(a:str2, tmp2)
    call system('page diff -w ' . tmp1 . ' ' . tmp2)
"    call delete(tmp1)
"    call delete(tmp2)
endfunction

" ,d# - diff 
Help ',d# - diff this file against alternate file (#)'
nmap ,d# :call DiffAlternate()<cr>
function! DiffAlternate()
    let cmd = 'diff -w "' . @% . '" "' . @# . '"'
    echo cmd
    echo System('page ' . cmd)
endfunction

" ,dd - diff contents of file with that on disk
nmap ,dd :call DiffFile()<cr>
function! DiffFile()
    let tmp = GetTemp("diff")
    call SetCmd("write " . tmp, "cpo", "-A")
    exec "!diff -w " . tmp . " %"
    call delete(tmp)
endfunction

Help ',df - delete the current file'
Help ',DF - delete the current file; do not prompt for confirmation'
Help 'v ,df - delete the selected file'
Help 'v ,DF - delete the selected file; do not prompt for confirmation'
nmap ,df :call DeleteFile(@%, 0)<cr>
nmap ,DF :call DeleteFile(@%, 1)<cr>
vmap ,df :<c-u>call DeleteFile(GetVisual(), 0)<cr>
vmap ,DF :<c-u>call DeleteFile(GetVisual(), 1)<cr>
function! DeleteFile(file, force)
    " strip leading and trailing whitespace for vmode cases
    let f = substitute(Chomp(a:file), '^\s*\(.*\S\)\s*$', '\1', '')
    if f =~ "\n"
        return Warning('Multi-line file name not allowed')
    endif
    if !filereadable(f) && !filewritable(f)
        return Warning('File not found: ' . f)
    endif
    if !a:force
        echohl BoldMsg
        let x = input('Delete ' . f . '? ')
        echohl None
        echo "\r"
        if match(x, '^[yY]') != 0
            return Warning('Canceled     ')
        endif
    else
        echo "delete " . f
    endif
    if delete(f) != 0
        echo Warning(Chomp(system('del "' . f . '"')))
    endif
endfunction

"??? try histadd for debug msgs!
"let msg = "dir = " . dir . " getcwd = " . getcwd()
"call histadd("input", msg)
"echo msg
"call GUImsg(msg)

" Prompt for input.  2nd arg is default response.
function! Input(prompt, ...)
    let prompt = a:prompt
    let result = a:0 == 0 ? input(prompt) : input(prompt, a:1)
    echo "\r"
    if result == ""
        return Warning("Canceled")
    endif
    return result
endfunction

Help ',ru - run a command; output (if any) in bottom window'
nnoremap ,ru :call histadd(":", "RunCmd ")<cr>:<up>
command! -nargs=+ -complete=file RunCmd call RunCmd(<q-args>)
function! RunCmd(cmd)
    call CdToDir()
    call TempWin(&lines/2)
    exec 'silent read !' . a:cmd . ' 2>&1'
"    call SetCmd('read !' . a:cmd . ' 2>&1', "ch", 2)
    if line('$') == 1
        close
        echo 'No output'
    else
        1
        delete
        call WinShrink()
        echo '<esc> to dismiss'
        set nomod
    endif
endfunction

function! System(cmd)
    let result = Chomp(system(a:cmd . ' 2>&1'))
    if v:shell_error
        return Warning(result)
    else
        return result
    endif
endfunction

" Run a command like System in a specified dir.
function! System2(dir, cmd)
    let cwd = getcwd()
    exec 'chdir ' . a:dir
    let result = System(a:cmd)
    exec 'chdir ' . cwd
    return result
endfunction

Help ',CD - force cd to dir in clipboard'
nmap ,CD :call BufferDirectory(@*)<cr>:echo @*<cr>

" Force cwd for this buffer to dir
function! BufferDirectory(dir)
    let b:directory = a:dir
    exec 'chdir ' . b:directory
endfunction

" cd to dir of current file
nmap ,DI :call CdToDir(2)<cr>
nmap ,di zz:call CdToDir()<cr>
function! CdToDir(...)
    let quiet = a:0 > 0 && a:1 == 1
    let force = a:0 > 0 && a:1 == 2
    if !exists('b:directory')
        let dir = DirNonUNC()
"TODO special handling for dirs?
"            && isdirectory(expand('%'))
        if dir !=? getcwd()
            if !force && dir ==? $TEMP
                " skip it
                echo "skip due to temp"
            else
                if !quiet
                    echo dir
                endif
                exec "cd " . dir
            endif
        endif
    endif
endfunction

function! DirNonUNC()
    let dir = Dir()
    if dir !~ '^\\\\'
        return dir
    else
        return System('fix_unc "' . dir . '"')
    endif
endfunction

" return dir of current file
function! Dir()
    return expand("%:p:h")
endfunction

" the dir for a title
function! TitleDir(dir)
    let dir = a:dir
    let dir = substitute(dir, '\\', '/', 'g')
    let dir = substitute(dir, '.*/unzipped/', '', '')
    let eclipse = substitute(GetRoot() . '/eclipse/', '\\', '/', 'g')
    let d1 = substitute(dir, '\c' . eclipse, '', '')
    if d1 != dir
        let dir = substitute(d1, '\(-win32\)*/', ' - ', '')
        let dir = substitute(dir, 'eclipse-', '', '')
    endif
    if (&ft == 'java' || &ft == 'scala') && !exists('g:page_prefix')
        " use package name if found; assume page_prefix contains it if there
        let p1 = substitute(dir, '.*/\(org\|com\)/', '\1/', '')
        if p1 != dir
            let p2 = substitute(dir, '/\(org\|com\).*', '', '')
            let p1 = substitute(p1, '/', '.', 'g')
            return p1 . ' - ' . p2
        endif
    endif
    return dir
endfunction

function! TSDir()
    return system('dirs -title ' . Dir())
endfunction

let tspat = '^tsk_asy_olympus\(_\(\d\)\)\=\\r_asy\(\\\|$\)'
" Split up dir for in title string.
function! TSDir1()
    let x = Dir()
    let y = substitute(x, g:tspat . '.*', 'asy\2  ', '')
    return Cond(x == y, '', y)
endfunction
function! TSDir2()
    let x = Dir()
    let y = substitute(x, g:tspat, '', '')
    return y
endfunction

" close current window, or quit
nmap qq :call Quit()<cr>
function! Quit()
    if !Update(1) | return | endif
    if winbufnr(2) == -1
        quit   " only one window -- exit vim
    else
        close  " more than one window -- close current one
    endif
endfunction

"Help ',as - add buffers for all matching source in current directory'
"nmap ,as :call AddAllSource()<cr>
" NOTE: reusing ,as
function! AddAllSource()
    call CdToDir()
    let dir = Dir() . '\'
    let all_files = system('ls -1')
    let g:tmp = all_files
    while g:tmp != ""
        let f = Pop("\n", "g:tmp")
        let ext = MatchNth(f, '.\+\.\(.*\)', 1)
        " TODO smarter check for C++
        if ext == &filetype && bufnr(dir . f) == -1
            echo "add " . f
            exec 'badd ' . f
        endif
    endwhile
endfunction

Help ',af - add matching files from current dir to args list; <c-n> and <c-p> work'
nmap ,af :call AddFiles()<cr>:call ListArgs()<cr>
function! AddFiles()
    let ext = expand('%:e')
    let glb = '*.' . ext
    let all_files = ''
    while 1
        let new_files = glob(glb)
        if new_files == ''
            break
        endif
        let glb = '*/' . glb
        let all_files = all_files . new_files . "\n"
    endwhile
    let all_files = substitute(all_files, "\n", ' ', 'g')
    exec "args " . all_files
    call ArgMaps()
endfunction

Help 'gb - go to Jazz defect in firefox'
nmap gb gU:call GoJazzDefect()<cr>
function! GoJazzDefect()
    let save = SaveSet('isfname', '48-57')
    let wi = GetCfile()
    call RestoreSet(save)
    if wi == ''
        return Warning('No work item found under cursor')
    endif
    echo "Work Item:" wi
    let server = 'https://jazzop03.rtp.raleigh.ibm.com:9943'
    let path = '/jazz/web/projects/Capilano#action=com.ibm.team.workitem.viewWorkItem&id='
    let url = server . path . wi
    let browser = 'C:\PROGRA~1\MOZILL~1\firefox.exe'
    echo system(browser . ' "' . url . '"')
endfunction

Help 'gu - go to URL in firefox'
Help 'V gu - go to highlighted URL in firefox'

vmap gu <esc>:call DoGoUrl(GetVisual())<cr>

nmap gu gU:call GoURL()<cr>
function! GoURL()
    " get URL under cursor: like file name but add '?', '#', '='
    let save = SaveSet('isfname', '+?,#,=,&')
    let url = GetCfile()
    call RestoreSet(save)
    let url = substitute(url, '^[().;,]*\(.\{-1,}\)[).;,]*$', '\1', '')
    if url !~ '^\w\+'
        if &ft != 'xml' && $ft != 'html'
            return Warning('No URL under cursor, found: ' . url)
        endif
        " open this file in browser
        let url = expand('%:p')
    endif
    if url =~? '^notes:'
        call DoNotesUrl(url)
    else
        call DoGoUrl(url)
    endif
endfunction

function! DoGoUrl(url)
    " For some reason normal path doesn't work so use 8.3 path
    "let browser = '"C:/Program Files/Mozilla Firefox/firefox.exe"'
    "let browser = 'C:\PROGRA~1\MOZILL~1\firefox.exe'
    let browser = 'fire.pl'
    echo a:url
    call CdToDir() " so relative file URLs work right
    echo system(browser . ' "' . a:url . '"')
endfunction

"nmap gu :call GoToUrl()<cr>
"function! GoToUrl()
"    " For some reason path with space doesn't work so use 8.3 path
"    "let browser = '"C:/Program Files/Mozilla Firefox/firefox.exe"'
"    let browser = 'C:/PROGRA~1/MOZILL~1/firefox.exe'
"    " get URL under cursor: like file name but add '?', '#', '&'
"    let isfname = &isfname
"    set isfname+=?,#,&
"    let url = expand('<cfile>')
"    let &isfname = isfname
"    " strip off punctuation at beginning and end
"    let url = substitute(url, '^[().;,]*\(.\{-1,}\)[().;,]*$', '\1', '')
"    if url !~ '^\w\+:'
"        echo 'No URL under cursor, found: ' . url
"        return
"    endif
"    echo url
"    echo system(browser . ' "' . url . '"')
"endfunction

" C:\tsk\bin

" open a Windows Explorer
nmap ge :call GoToExplorer()<cr>
function! GoToExplorer()
    let path = expand('<cfile>')
    " strip off punctuation at beginning and end
    let path = substitute(path, '^[().;,]*\(.\{-1,}\)[().;,]*$', '\1', '')
    if path == ''
        echo 'No file name under cursor'
    elseif !filereadable(path) && !isdirectory(path)
        echo 'File under cursor not found: ' . path
    else
        echo path
        call system('explorer /e,"' . path . '"')
    endif
endfunction

Help ',xx - execute the current file'
"nmap ,xx ,di:call ViCmd('!%')<cr>
nmap ,xx ,di:call ExecuteFile(expand('%'))<cr>
" Look at ExecuteFile

Help ',xf - execute the file under the cursor'
nmap ,xf ,di:call GoFile(1)<cr>

" goto file under cursor
"nmap gf gU,di:call GoFile()<cr>
nmap gf :call DoGF()<cr>

" This is what we want gf to do
function! DoGF()
    call Norm(GetPos())
    call Update(1)
    call PushLoc()
    call CdToDir()
    call GoFile()
endfunction

" builtin gf doesn't always seem to work, so implement it ourselves
" Try to ignore colons that shouldn't be included, and include spaces
" that should.
" GoFile(1) => execute the file instead of editting
function! GoFile(...)
    let xf = a:0 > 0 && a:1
    if &filetype == 'zip'
        "Can't use GetFile because the path has to exist
        let save = SaveSet("isfname", "+32,36")
        let path = GetCfile()
        call RestoreSet(save)
        " editing a .zip: unzip the file to a temp and edit there
        " NOTE: need UnixSlash for autocmd BufLeave
        let zipfile = UnixSlash(expand('%:p'))
        let temp = UnixSlash($TEMP . "/unzipped/" . expand("%:p:t:r"))
        let full = temp . '/' . path
        " extract path from zipfile
        call Mkdir(temp)
        echo System2(temp, Format('unzip -o -q "{0}" "{1}"', zipfile, path))
        call Edit(full)
        " put back into zip when we leave
        exec Format(
        \ 'autocmd BufLeave,VimLeave {0} echo System2("{1}", "zip -u \"{2}\" \"{3}\"")',
            \ full, temp, zipfile, path)
        return
    endif
    let path = GetFile()
    if path == ''
        return
    endif
    if xf
        call ExecuteFile(path)
        return
    endif
    if &filetype == 'jar' || &filetype == 'war'
        " editing a .jar: unjar the file to a temp and edit there
        " Warning: what if edit same path in two jars
        " (e.g. META-INF/MANIFEST.MF).  Things get messed up.
        let temp = $TEMP . "\\unzipped\\" . expand("%:p:t")
        call GUImsg("temp=" . temp . " path=" . @%)
        echo System("unzip -o -q " . @% . " " . path . " -d " . temp)
        call Edit(temp . "\\" . path)
        return
    endif
    if &filetype == 'tar'
        " editing a .tar: untar the file to a temp and edit there
        let tarfile = UnixSlash(expand('%:p'))
        let tarfile = substitute(tarfile, '^\([a-z]\):', '/cygdrive/\1', '')
        let temp = UnixSlash($TEMP . "/untarred/" . expand("%:p:t:r"))
        let full = temp . '/' . path
        " extract path from tarfile
        call Mkdir(temp)
        echo System2(temp, Format('tar -xf "{0}" "{1}"', tarfile, path))
        call Edit(full)
        "TODO:
        " put back into tar when we leave
"        exec Format(
"        \ 'autocmd BufLeave,VimLeave {0} echo System2("{1}", "tar -u \"{2}\" \"{3}\"")',
"            \ full, temp, tarfile, path)
        return
    endif
"    if has('perl') && filereadable(path)
    if !filereadable(path)
        "TODO: this could be more general
        if path =~ '^node_modules/'
            if filereadable('../' . path)
                let path = '../' . path
            endif
        endif
    endif
    if filereadable(path)
"NOTE this doesn't always seem to work
"        " Use perl to test if file is binary
"        let p = escape(path, '\\')
"        exec "perl VIM::DoCommand('let text = ' . (0 + -T '" . p . "'))"
"        if !text
        if !IsText(path) && path !~? '\.\(jar\|zip\)$'
            let ans = input(path . ' is binary; execute [n/y/e]? ')
            echo "\r"
            if ans =~? '^e'
                " edit anyway
            elseif ans =~? '^y'
                call ExecuteFile(path)
                return
            else
                return Warning('Canceled')
            endif
        endif
    endif
    call Edit(path)
endfunction

" Check if view needs to be started or vob mounted
function! CheckCCPath(path)
    call system('cc_check_path.pl "' . a:path . '"')
"    let path = substitute(a:path, '/', '\\', 'g')
"    if path !~ '^[mM]:\\'
"        echo "not cc"
"        return
"    endif
"    let path = substitute(path, '^[mM]:\\', '', '')
"    let ccview = substitute(path, '\\.*', '', '')
"    if !isdirectory("m:\\" . ccview)
"        call system('cleartool startview "' . ccview . '"')
"    endif
"    let vob = substitute(substitute(path, '^[^\\]*\\', '', ''), '\\.*', '', '')
"    if vob != ccview && !isdirectory("m:\\" . ccview . "\\" . vob)
"        call system("cleartool mount \\" . vob)
"    endif
endfunction

function! UnixSlash(str)
    return substitute(a:str, '\\', '/', 'g')
endfunction

function! WinSlash(str)
    return substitute(a:str, '/', '\\', 'g')
endfunction

function! IsText(path)
    return 1
    let result = Chomp(system('is_text.pl "' . a:path . '"'))
    if result == "1" || result == "0"
        return result
    else
        call GUImsg("is_text.pl failed on " . a:path . ": " . result)
        return 1
    endif
"    return system('is_text "' . a:path . '"')
endfunction

function! ExecuteFile(path)
    "TODO see how explorer.vim executes files
    let path = substitute(a:path, '\.jade$', '.html', '')
    let cmd = 'explorer'
    if path =~ '\.md$' || path =~ '\.markdown$'
        let cmd = 'show_markdown.pl'
    endif
    echo system(cmd . ' "' . path . '"')
"    echo system('"' . a:path . '"')
endfunction

" Get the file name under the cursor
function! GetFile()
    if &ft == 'ls'  " special handling in ls -r output
        let line = getline('.')
        " skip date etc in long output
        if line =~ '^\d\d-\w\w\w-\d\d \d\d:\d\d  '
        \ || line =~ '^ *\d\+[kM]* \+\w\w\w \+\d\+ \+\d\d:\=\d\d  '
            call Norm('$')
        endif
        " file names are delimited by two spaces
        "??? names with spaces:
        let path = substitute(BeforeCursor(), '.*  ', '', '')
            \ . substitute(AfterCursor(), '  .*', '', '')
        let dir = FindDirName()
        if dir != path
            let path = dir . '\' . path
        endif
"        let pos = GetPos()
"        +1  " allow for gf on dirname
"        let l = search(':$', 'bW')  " find dir name
"        call Norm(pos)
"        if l != 0
"            let dir = substitute(getline(l), ':$', '', '')
"            if dir != path  " otherwise we're already on a dir
"                let path = dir . '\' . path
"            endif
"        endif
    else
        let path = GetCfile()
        if path == 'include' || path == '==='
            " on include -- try to find file name
            call Norm("el")
            let path = GetCfile()
        endif
        if path == 'diff' && &ft == 'diff'
            call Norm('w')
            let path = GetCfile()
"            if path == 'diff'
"                call Norm('w')
"                let path = GetCfile()
"            endif
        endif
        if path =~ '^\d\d/\d\d/\d\d$' || path =~ '^\(---\|===\|<<<\|>>>\)$'
            " on a date -- skip it
            normal! W
            let path = GetCfile()
        endif
        if path =~ '^file:'
            let path = substitute(path, '^file:', '', '')
            let path = substitute(path, '^/\+\([a-zA-Z]:\)', '\1', '')
            let path = substitute(path, '^///*', '//', '')
            let path = substitute(path, '%20', ' ', 'g') " may be others
            let path = substitute(path, '/', '\\', 'g')
        endif
        " file names in perl strings may have extra \'s at front
        let path = substitute(path, '^\\\\\\\\', '\\\\', '')
    endif
    if path == ''
        return Warning("no file name under cursor")
    endif
"    " end at colon if after 2nd char
"    let path = substitute(path, '\(..\):.*', '\1', '')
    " end at ': '
    let path = substitute(path, ': .*', '', '')
    if &filetype == 'jar' || &filetype == 'zip'
        return path  " don't care if it doesn't exist
    endif
    if FileExists(path)
        return path
    endif
    let path = SubAbbrevs(path)
    let ws_path = GetWorkspaceFile(path)
    if FileExists(ws_path)
        return ws_path
    endif
    " try to start view and mount vob
    call CheckCCPath(path)
    if FileExists(path)
        return path
    endif
    " look for line that has directory name
    let dir = FindDirName()
    if dir != ''
        let path2 = dir . "\\" . path
        if FileExists(path2)
            return path2
        endif
    endif
    let path2 = GetCfile2()
    " see if allowing spaces finds it
"    let save = SaveSet("isfname", "+32")
"    let path2 = GetCfile()
    " strip file:/
    let path2 = substitute(path2, '.*file:/', '', '')
    " strip junk before C:
    let path2 = substitute(path2, '.* \([a-zA-Z]:\)', '\1', '')
    " strip stuff after a colon (e.g. line num)
    let path2 = substitute(path2, '^\(..[^:]*\):.*', '\1', '')
"    let g:tmp = save
"    exec save
    if FileExists(path2)
        return path2
    endif
    " search on path
    let g:tmp = &path . ","
    while g:tmp != ""
        let d = Pop(",", "g:tmp")
        if d == ""
            break
        endif
        let f = d . "\\" . path
        if filereadable(f)
            return f
        endif
    endwhile
    return path
endfunction

function! SubAbbrevs(path)
    let path = a:path
    let i = 0
    while 1
        let i = match(path, '_[-a-zA-z]\+_', i)
        if i < 0
            break
        endif
        let j = match(path, '_', i+1)
        let key = strpart(path, i+1, j-i-1)
        let value = system('abbrev.bat -query ' . key)
        if value != ''
            let path = strpart(path, 0, i) . value . strpart(path, j+1)
        endif
        let i = j + 1
    endwhile
    return path
endfunction

" Find a directory name followed by ':' on a line by itself
function! FindDirName()
    let pos = GetPos()
    let l = search(':\s*$', 'bW')  " find dir name
    let dir = ""
    if l != 0
        call Norm('?[^ \t:]')  " search back to end (skip spaces and :)
        let dir = GetCfile2()
        if !isdirectory(dir)
            let dir = ""
        endif
    endif
    call Norm(pos)
    return dir
endfunction

Help ',ge - go to eclipse feature or plugin under cursor'
Help ',GE - prompt for eclipse feature or plugin id and go there'
nmap ,ge gU,di:call GoEclipse(0)<cr>
nmap ,GE gU,di:call GoEclipse(1)<cr>
function! GoEclipse(prompt)
    let save = SaveSet('iskeyword', '+.')
    if a:prompt
        let id = GetID(1)
        if id == ''
            exec save
            return
        endif
    else
        let id = GetWord()
        if id !~ '^\k\+$'
            let id = Match1(
                \ getline('.'),
                \ "\\<id\\s*=\\s*['\"]\\(\\k\\+\\)['\"]")
            if id == ''
                exec save
                return Warning('not on an id or a line with an id')
            endif
        endif
    endif
    exec save

    let cwd = getcwd()
    let dir = Match1(cwd, '^\(.*\)\\eclipse\(\\.*\|\)$')
    if dir == ''
        return Warning('not in an eclipse directory')
    endif
    let dir = dir . '\eclipse'
    let kind = Match1(cwd, '\.*\\eclipse\\\(features\|plugins\|$\).*')
    if kind == ''
        let kind = 'features'  " default: look in features first
    endif

    if TryGoEclipse(dir, id, kind, '')
        return
    endif
    let kind2 = kind == 'features' ? 'plugins' : 'features'
    if TryGoEclipse(dir, id, kind2, '')
        return
    endif
    call Warning('no match for ' . id . ' under ' . dir)
endfunction

" kind is features or plugins; kind1 is feature, plugin, fragment, or empty
function! TryGoEclipse(dir, id, kind, kind1)
    let kind1 = a:kind1
    if kind1 == ''
        let kind1 = substitute(a:kind, 's$', '', '')
    endif
    " try with no version (or if version is already in id)
    let path = a:dir . '\' . a:kind . '\' . a:id . '\' . kind1 . '.xml'
    if filereadable(path)
        call Edit(path)
        return 1
    endif
    " glob and get latest version
    let glb = a:dir . '\' . a:kind . '\' . a:id . '_*\' . kind1 . '.xml'
    let match = glob(glb)
    let match = substitute(match, '.*\n', '', '')  " in case more than one
    if match != ''
        call Edit(match)
        return 1
    endif
    if kind1 == 'plugin'
        return TryGoEclipse(a:dir, a:id, a:kind, 'fragment')
    endif
    return 0
endfunction

" go to other part

nmap go :call GoOther()<cr>
function! GoOther()
    normal gU
    let ext = expand('%:e')
    let root = expand('%:r') . '.'
    if ext == "cpp" || ext == "c"
        let new = "h"
    elseif ext == "h"
        let new = "cpp"
    elseif ext == "java"
        normal ,js
        return
    elseif ext == "jspec"
        normal gl
        return
    elseif &filetype == 'coffee'
        if filereadable(root . '.js')
            let new = 'js'
        elseif filereadable(root . '.html')
            let new = 'html'
        else
            let new = 'jade'
        endif
    elseif &filetype == 'typescript'
        if filereadable(root . 'jade')
            let new = 'jade'
        else
            let new = 'html'
        endif
    elseif &filetype == 'jade' || &filetype == 'html'
        if filereadable(root . 'coffee')
            let new = 'coffee'
        elseif filereadable(root . 'ts')
            let new = 'ts'
        else
            let new = 'js'
        endif
    else
        return Warning("don't know other part for ." . ext . " files")
    endif
    exec 'edit ' . root . new
endfunction

"Help ',CR - remove <cr>s when entering any readonly buffer'
"nnoremap <silent> ,CR :let g:remove_crs = 1<cr>:call RemoveCRs()<cr>
Help 'cr - remove <cr>s'
nnoremap <silent> cr :call RemoveCRs()<cr>
function! RemoveCRs()
    if &readonly && &modified
        return Error("can't use cr on readonly file that has been modified")
    endif
    let pos = GetPos()
    silent! %s///g
    call Norm(pos)
    if &readonly
        set nomodified
    endif
endfunction

Help ',cr - make all line endings consistently windows-style'
nnoremap <silent> ,cr :call RemoveCRs()<bar>set ff=dos<cr>

" Used by autohotkey as mapping for ^/
" visual mode: same as #; normal mode: comment current line
vmap ,CO #gv
nmap ,CO V#

Help 'V C - duplicate and comment selected lines'
vmap C yP:call Comment(3, '.', line("'<")-1)<cr>'<

Help 'c# c? c* cC - comment current paragraph'
nnoremap c# Vip:<c-u>call Comment(0, "'<", "'>")<cr>
nnoremap c? Vip:<c-u>call Comment(1, "'<", "'>")<cr>
nnoremap c* Vip:<c-u>call Comment(2, "'<", "'>")<cr>
nnoremap cC VapyP:call Comment(3, '.', line("'<")-1)<cr>'<

Help 'V # ? g* - comment or uncomment selected lines'
vmap # :<c-u>call Comment(0, "'<", "'>")<cr>
vmap ? :<c-u>call Comment(1, "'<", "'>")<cr>
vmap g* :<c-u>call Comment(2, "'<", "'>")<cr>
vmap g# :<c-u>call Comment(2, "'<", "'>")<cr>
" kind = 1 => add ??? to comment
" kind = 2 => use multi-line comment if available
" kind = 3 => force comment (not uncomment)
function! Comment(kind, start, end)
    let kind = a:kind
    let start = a:start =~ '^\d*$' ? a:start : line(a:start)
    let end = a:end =~ '^\d*$' ? a:end : line(a:end)
    let start = nextnonblank(start)
    let end = prevnonblank(end)

    let comment = ""
    let comment1 = ""
    let comment2 = ""
    let comment1a = ""
    let comment2a = ""
    if &ft == 'c' || &ft == 'cpp' || &ft == 'java' || &ft == 'groovy' || &ft == 'scala'
            \ || &ft == 'idl' || &ft == 'css' || &ft == 'javascript' || &ft == 'dart'
            \ || &ft == 'rust' || &ft == 'stylus' || &ft == 'go' || &ft == 'swift'
            \ || &ft == 'typescript'
        if &ft != 'css'
            let comment = '\/\/'
        endif
        let comment1 = '/*'
        let comment2 = '*/'
        " /* */ comments don't nest, so they are replaced with those below
        let comment1a = '/{*'
        let comment2a = '*}/'
    elseif &ft == "vim"
        let comment = '\"'
    elseif &ft == "vb"
        let comment = "'"
    elseif &ft == "dosbatch"
        "let comment = '@rem '
        let comment = ':: '
    elseif &ft == 'ahk' || &ft == 'autohotkey'
        let comment = ';'
    elseif &ft == 'jade' || &ft == 'less'
        let comment = '\/\/'
        let comment1 = '/*'
        let comment2 = '*/'
    elseif &ft == 'htmldjango'
        let comment1 = '{#'
        let comment2 = '#}'
    elseif &ft == 'xml' || &ft == 'ant' || &ft == 'html' || &ft == 'xhtml' || &ft == 'dtd' || &ft == 'xslt' || &ft == 'xsd'
        if GetSyntaxName() =~ '^css'
            let comment1 = '/*'
            let comment2 = '*/'
            let comment1a = '/{*'
            let comment2a = '*}/'
        else
            let comment1 = "<!--"
            let comment2 = "-->"
            " these comments don't nest
            let comment1a = "<!- -"
            let comment2a = "- ->"
        endif
    else " default
        let comment = '\#'
    endif
    if comment == "" || (kind == 2 && comment1 != "")
        " delimit with comment1 and comment2
        if getline(start) =~ '^\s*' . escape(comment1, '\/*')
            " undo comment
            if getline(end) !~ comment2 . '\s*$'
                call Norm(start."G%%")
                let end = line("''")
            endif
            echo "start = " . start . ", end = " . end
            if comment1a != ''
                " non-nesting comments
                silent exec start . ',' . end
                    \ . 'snomagic/' . escape(comment1a, '\/*')
                    \ .         '/' . escape(comment1, '\/*') . '/ge'
                silent exec start . ',' . end
                    \ . 'snomagic/' . escape(comment2a, '\/*')
                    \ .         '/' . escape(comment2, '\/*') . '/ge'
            endif
            if end == start
                silent exec start . 's/' . escape(comment1, '\/*') . '\s*//'
                silent exec start . 's/\s*' . escape(comment2, '\/*') . '\s*$//'
            else
                exec end . 'delete'
                exec start . 'delete'
            endif
"            if end != start
"                exec end . 'delete'
"            endif
"            exec start . 'delete'
        else
            if comment1a != ''
                " non-nesting comments
                silent exec start . ',' . end
                    \ . 'snomagic!' . escape(comment1, '\!')
                    \ .         '!' . escape(comment1a, '\!') . '!ge'
                silent exec start . ',' . end
                    \ . 'snomagic!' . escape(comment2, '\!')
                    \ .         '!' . escape(comment2a, '\!') . '!ge'
            endif
            if end == start
                "exec start . 's/^\s*/&' . escape(comment1, '\/*') . ' /'
                "exec start . 's/$/ ' . escape(comment2, '\/*') . '/'
                exec start . 's!^\s*!&' . escape(comment1, '\!*') . ' !'
                exec start . 's!$! ' . escape(comment2, '\!*') . '!'
            else
                call append(end, comment2)
                call append(start-1, comment1)
            endif
            exec start
        endif
        return
    endif

    " end-of-line comments starting with comment
    let line = getline(start)
    if match(line, "^\\s*" . comment . '???') == 0
        let kind = 1
    endif
    let range = start . "," . end
    if kind == 1
        if match(line, "^\\s*" . comment . '???') == 0
            exec range . "s/^\\(\\s*\\)" . comment . "/\\1/"
            exec start . " delete"
        else
            exec range . "s/^/" . comment . "/"
            call append(start-1, substitute(comment,"\\","","g") . '???')
        endif
    else
        if kind != 3 && match(line, "^\\s*" . comment) == 0
            " uncomment
            exec range . "s/^\\(\\s*\\)" . comment . "/\\1/"
        else
            let indent = GetMinIndent(start, end)
            exec range . "s/^" . indent . "/" . indent . comment . "/"
        endif
    endif
endfunction

" Find the line with the minimum indent in this range and return it
function! GetMinIndent(start, end)
    let indent = matchstr(getline(a:start), '^\s*')
    let i = a:start
    while i < a:end
        let i = i + 1
        let indent2 = matchstr(getline(i), '^\s*')
        if indent2 =~ '^' . indent
            " already ok
        elseif indent =~ '^' . indent2
            let indent = indent2
        else
            " could do better if they have a common prefix
            let indent = ''
        endif
    endwhile
    return indent
endfunction


" 0-based arrays implemented as strings separated by g:array_sep
" GetArray indexes into an array
" MakeArray makes one out of a bunch of scalars

let g:array_sep = "\001"

function! GetArray(arr, ind)
    if a:ind == 0
        let arr = a:arr
    else
        let pat = '^\([^' . g:array_sep . ']*.\)\{' . a:ind . '}'
        let arr = substitute(a:arr, pat, '', '')
    endif
    return substitute(arr, g:array_sep . '.*', '', '')
endfunction

function! MakeArray(...)
    let result = ''
    let i = 0
    while i < a:0
        let i = i + 1
        exec 'let arg = a:' . i
        let result = result . arg . "\001"
    endwhile
    return result
endfunction

"TODO use this in Comment()
function! GetCommentDelimiters()
    let comment = ""
    let comment1 = ""
    let comment2 = ""
    let comment1a = ""
    let comment2a = ""
    if &ft == 'c' || &ft == 'cpp' || &ft == 'java' || &ft == 'scala' || &ft == 'idl' || &ft == 'css'
        let comment = '\/\/'
        let comment1 = '/*'
        let comment2 = '*/'
        " /* */ comments don't nest, so they are replaced with those below
        let comment1a = '/{*'
        let comment2a = '*}/'
    elseif &ft == "vim"
        let comment = '\"'
    elseif &ft == "vb"
        let comment = "'"
    elseif &ft == "dosbatch"
        "let comment = '@rem '
        let comment = ':: '
    elseif &ft == 'xml' || &ft == 'html' || &ft == 'xhtml' || &ft == 'dtd' || &ft == 'xslt' || &ft == 'xsd'
        let comment1 = "<!--"
        let comment2 = "-->"
        " these comments don't nest
        let comment1a = "<!- -"
        let comment2a = "- ->"
    else " default
        let comment = '\#'
    endif
    return MakeArray(comment, comment1, comment2, comment1a, comment2a)
endfunction

"TODO change javadoc back to //
Help 'V gj - convert comment to javadoc'
vmap gj <esc>:call ChangeJavaDoc()<cr>
function! ChangeJavaDoc()
    let pos = GetPos()
    let first_line = line("'<")
    let last_line = line("'>")
    let append_line = last_line  " append new text after this one
    let lnum = first_line
    if getline(first_line) =~ '^\s*\/\*\+\s*\((non-Javadoc)\)*$'
        if getline(last_line) !~ '^\s*\*\/\s*$'
            return Warning("selection doesn't end with */")
        endif
        let lnum = lnum + 1
        while lnum < last_line
            let line = getline(lnum)
            let new_line = substitute(line, '^\(\s*\) \*', '\1//', '')
            if new_line == line
                call Warning("line " . lnum . " doesn't start with *")
            endif
            call append(append_line, new_line)
            let append_line = append_line + 1
            let lnum = lnum + 1
        endwhile
    else
        while lnum <= last_line
            let line = getline(lnum)
            let new_line = substitute(line, '^\(\s*\)//', '\1 *', '')
            if new_line == line
                call Norm(pos)
                if append_line > last_line
                    undo  " made a change, so undo it
                endif
                return Warning("line " . lnum . " doesn't start with //")
            endif
            call append(append_line, new_line)
            let append_line = append_line + 1
            let lnum = lnum + 1
        endwhile
        " get indent from first line
        let indent = substitute(getline(first_line), '\S.*', '', '')
        call append(append_line, indent . " */")
        call append(last_line, indent . "/**")
    endif
    '<,'> delete
endfunction

Help 'gc - go to class in java'
nmap gc :call GoToClass()<cr>
" Find the import for the class and edit its file.
function! GoToClass()
    if &filetype != java
        return Warning('gc only works for java files')
    endif
    call CdToDir()
    let class = GetID(0)
    let import = search('^import\s.*\.' . class . ';', 'nw')
    if import == 0
        " assume same dir
        let file = class . '.java'
    else
        let pkg_line = search('^package\s.*;', 'nw')
        if pkg_line == 0
            return Warning('No package decl found in this file')
        endif
        let pkg0 = split(substitute(getline(pkg_line), '^package\s\+\(.*\);.*', '\1', ''), '\.')
        let pkg1 = split(substitute(getline(import), '^import\s\+\(.*\)\.' . class . '.*', '\1', ''), '\.')
        let i = 0
        while i < len(pkg0) && i < len(pkg1) && pkg0[i] == pkg1[i]
            let i = i + 1
        endwhile
        " i is first index to differ
        let rel = ''
        let j = i
        while j < len(pkg0)
            let rel = rel . '../'
            let j = j + 1
        endwhile
        while i < len(pkg1)
            let rel = rel . pkg1[i] . '/'
            let i = i + 1
        endwhile
        let file = rel . class . '.java'
    endif
    call Edit(file)
endfunction

" Precede <c-i>, <c-o>, <c-n> or <c-p> with <c-x> to repeat until reaching
" different file.  Problems with quoting if we try to use: NextFile('<c-i>')
nmap ,Jn <c-i>
nmap ,Jp <c-o>
nmap <c-x><c-i> :call NextFile(',Jn')<cr>
nmap <c-x><c-o> :call NextFile(',Jp')<cr>
nmap ,nn <c-n>
nmap ,pp <c-p>
nmap <c-x><c-n> :call NextFile(',nn')<cr>
nmap <c-x><c-p> :call NextFile(',pp')<cr>
function! NextFile(cmd)
    let path = expand("%:p")
    let g:no_more_items = 0
    let v:errmsg = ""
    let n = 0
    let prev_pos = ""
    while 1
        " NOTE don't use Norm() or normal! here -- want maps
        exec 'normal ' . a:cmd
        if path != expand("%:p")
            return
        endif
        " assume that if we didn't move there are no more items
        let pos = GetPos(1)
        if pos == prev_pos
            " didn't move -- assume no more
            return
        endif
        let prev_pos = pos
        let n = n + 1
        if n == 1000
            return Warning("infinite loop?")
        endif
    endwhile
endfunction

" Maps to go thru args -- this is the default
nmap ,am :call ArgMaps()<cr>
nmap ,an ,am<c-n>
nmap ,ap ,am<c-p>
function! ArgMaps()
    nmap <c-n> :next<cr>
    nmap <c-p> :previous<cr>
    nmap <c-j> :call ListArgs()<cr>
    nmap <c-k> :<c-u>call GotoArg(v:count)<cr>
endfunction
function! GotoArg(i)
    let n = (a:i - 1) - argidx()
    if n == 0
        " at right one
    elseif n > 0
        exec n . 'next'
    else
        exec -n . 'previous'
    endif
endfunction
function! ListArgs()
    let i = 0
    while i < argc()
        echo (i+1) . (argidx()==i ? '% ' : '  ') . argv(i)
        let i = i + 1
    endwhile
endfunction
call ArgMaps()

nmap ,em :call ErrorMaps()<cr>
nmap ,en ,em<c-n>
nmap ,ep ,em<c-p>
function! ErrorMaps()
    nmap <c-n> :cnext<cr>
    nmap <c-p> :cprev<cr>
    nmap <c-j> :clist<cr>
    nmap <c-k> :<c-u>exec "cc " . Make0Empty(v:count)<cr>
    call CdToDir()
endfunction

" Map 0 to ""
function! Make0Empty(x)
    if a:x == 0
        return ""
    else
        return a:x
    endif
endfunction

" Options for 2html.vim
"let html_use_css = 1
"let html_no_pre = 1
"let use_xhtml = 1
Help ',2h - Convert current file to html with syntax coloring (for Notes)'
Help ',2H - Convert current file to html with syntax coloring with CSS (for browser)'
"nmap ,2h :unlet! html_use_css<cr>:source $VIMRUNTIME/syntax/2html.vim<cr>
"nmap ,2H :let html_use_css=1<cr>:source $VIMRUNTIME/syntax/2html.vim<cr>
nmap ,2h :unlet! html_use_css<cr>:source $VIM/vimfiles/after/syntax/2html.vim<cr>
nmap ,2H :let html_use_css=1<cr>:source $VIM/vimfiles/after/syntax/2html.vim<cr>

" have problems remembering ,ht vs ,th
Help ',th - run txt2html on current file or highlighted text'
Help ',ht - run txt2html on current file or highlighted text'
nmap ,th :call Txt2Html('1', '$')<cr>
vmap ,th <esc>:call Txt2Html("'<", "'>")<cr>
nmap ,ht ,th
vmap ,ht ,th
function! Txt2Html(l1, l2)
    let temp = GetTemp('txt2html', 'txt')
    exec a:l1 . ',' . a:l2 . ':w ' . temp
    call system("perl -S txt2html.pl -view " . temp)
    call delete(temp)
endfunction


Help ',tt - open a new tab for current file'
nmap ,tt ea:exec 'tabnew ' . @#<cr>

Help 'et - toggle between this tab and last one accessed'
let g:lasttab = 1
autocmd TabLeave * let g:lasttab = tabpagenr()
nmap et :exec 'tabnext ' . g:lasttab<cr>

" Tags stuff -- no longer needed?
if 0
    " tags -- use UpdateTags to ensure up to date
    Help 'qt - qualified name tag (names separated with ".")'
    nmap <silent> qt :call TagQualified()<cr>
    "nnoremap <silent> <c-]> :call UpdateTags(0)<cr><c-]>
    Help ',tm - make ^N and ^P go through tags'
    "nmap ,tm :call TagMaps()<cr>
    if 0
    nmap ,ta :call UpdateTags(0)<cr>:tag<space>
    else
    " try updating tags after getting tag name
    Help ',ta - go to a tag in a new tab'
    nmap ,ta :Tag<space>
    command! -nargs=1 -complete=tag Tag call UpdateTags(0)<bar>:tab tag <args>
    endif
    nmap ,TA :call TagGlobal('-vob')<cr>
    Help ',tn ,tp ,ts - next, prev, select tag'
    nmap ,tn ,tm<c-n>
    nmap ,tp ,tm<c-p>
    nmap ,ts ,tm<c-j>
    Help ',tc - create tags file for this dir'
    nmap <silent> ,tc :call UpdateTags(1)<cr>
    Help ',TC - create tags file for this dir and others in tags list'
    nmap <silent> ,TC :call UpdateTags(2)<cr>

    Help ',td - add a dir to list to seach for tags from cwd'
    nmap ,td :call TagDir()<cr>
    function! TagDir()
        call CdToDir()
        let dir = input('dir to add to tags: ')
        echo "\r"
        if dir == ''
            set tags
            return
        endif
        if !isdirectory(dir)
            return Warning("not a directory " . dir)
        endif
        call Warning(system('perl -S tagdir.pl ' . dir))
        if filereadable(g:tagspath)
            exec "source " . g:tagspath
            set tags
        endif
    endfunction

    Help ',TD - add all of the source directories in this plugin to tags'
    nmap ,TD :call TagDirPlugin()<cr>
    function! TagDirPlugin()
        call CdToDir()
        let result = system('perl -S tagdir.pl -plugin .')
        if v:shell_error != 0
            call Warning(result)
        endif
        if filereadable(g:tagspath)
            exec "source " . g:tagspath
            set tags
        endif
    endfunction


    "Help ',tu - update tags file for current dir'
    "nmap <silent> ,tu :call UpdateTags()<cr>
    "???
    "function! UpdateTags(...)
    "    let force = a:0 > 0 && a:1
    "    call Update()
    "    call TagMaps()
    "    call CdToDir()
    "    if force
    "        call delete('tags')
    "    endif
    "    call Warning(Chomp(system('update_tags 2>&1')))
    "endfunction

    function! UpdateTags(kind)
        call Update()
        call TagMaps()
        call CdToDir()
        if a:kind > 0
            call delete('tags')
        endif
        let cmd = 'perl -S update_tags.pl'
        if a:kind == 2
            let cmd = cmd . ' ' . &tags
        endif
        call Warning(system(cmd . ' 2>&1'))
    endfunction

    " Update and find tags files, using opt for update_tags cmd.
    function! TagGlobal(opt,...)
        let opt = a:opt
        let id = a:0 > 0 ? a:1 : ''
        call Update()
        call TagMaps()
        call CdToDir()
        if id == ''
            let id = GetID(0)
        endif
        let tagspath = system('update_tags ' . opt . ' -vi 2>&1')
        let save = SaveSet('tags', tagspath)
        exec 'tag ' . id
        exec save
    endfunction

    function! TagMaps()
        nmap <c-n> :tnext<cr>
        nmap <c-p> :tprev<cr>
        nmap <c-j> :tselect<cr>
        nmap <c-k> <esc>
    endfunction

    function! TagQualified()
        call UpdateTags(0)
        call SetNorm('yiw', 'iskeyword', '+.')
        let id = @@
        exec "tag " . id
    endfunction

endif

Help ',vw - bring vim window matching a pattern to foreground'
nmap ,vw :call VimWindow()<cr>
function! VimWindow()
    let pat = Input('Pattern? ')
    if pat != ''
        echo System('perl -S vw.pl ' . pat)
    endif
endfunction

Help 'bc - bring console window to foreground'
nmap bc :echo System('bc.bat')<cr>
Help 'bv - bring vim window to foreground'
"nmap bv :echo System('bv.bat')<cr>
nmap bv :call SetCmd("echo System('bv.bat')", 'titlestring', '-')<cr>
"function! VimWindow2()
"    echo System('bv.bat')
"function! SetCmd(cmd, name, value)
"endfunction

Help ',ol - bring Outlook to foreground'
nmap ,ol :call System('perl -S ol.pl')<cr>


" pattern that matches Java modifiers
let g:java_mods_pat = '\(\(public\|private\|protected\|static\|final\)\s\+\)*'

" ,ff - search for a Vim function
nmap ,ff gU:call FindFunction(0)<cr>
nmap ,FF gU:call FindFunction(1)<cr>
function! FindFunction(ask)
    let post = ''
    if &ft == 'vim'
        let key = 'function!'
    elseif &ft == 'perl'
        let key = 'sub'
    elseif &ft == 'idl'
        let key = 'HRESULT'
    elseif &ft == 'java'
        let key = g:java_mods_pat . '\i\+'
        let post = '\s*('
    else
        return Warning("don't know how to find function in " . &ft)
    endif
    call FindSomething(a:ask, 'function', key, post)
endfunction

nmap ,fm gU:call FindMap(0)<cr>
nmap ,FM gU:call FindMap(1)<cr>
function! FindMap(ask)
    " allow ',' as they are often in maps
    let save = SaveSet("iskeyword", '+92,44,<,>')  " add \ and ,
    call FindSomething(a:ask, 'map', '\w*map\(\s\+<\w\+>\)*')
    exec save
endfunction

"??? can this work with NextClass???
nmap ,fc gU:call FindClass(0)<cr>
nmap ,FC gU:call FindClass(1)<cr>
function! FindClass(ask)
    let post = ''
    if &ft == 'idl'
        let key = '\(class\|interface\|typedef .* enum\)'
        let post = '\s*\($\|[{:]\)'
    elseif &ft == 'java'
        let key = g:java_mods_pat . '\(class\|interface\)'
    else
        return Warning("don't know how to find class in " . &ft)
    endif
    call FindSomething(a:ask, 'class', key, post)
endfunction

function! FindSomething(ask, kind, key, ...)
    let post = ""
    if a:0 > 0
        let post = a:1
    endif
    let id = GetID(a:ask, 'Enter ' . a:kind)
    if id == "" | return | endif
    let pat = '^\s*' . a:key . '\s\+' . escape(id, '\') . '\>' . post
    call histadd('/', pat)
    call PushLoc()
    if search(pat, 'sw') == 0
        call Warning('pattern is ' . pat)
        return Warning(a:kind . ' "' . id . '" not found')
    endif
endfunction

" New style:
"     for (Type var : expr) {
" Old style:
"     for (Iterator i = expr.iterator(); i.hasNext(); ) {
"         Type var = (Type) i.next();
Help ',ti - toggle iterator between regular and enhanced for loop'
nmap ,ti :call ToggleIterator()<cr>
function! ToggleIterator()
    let text = getline('.')
    if text !~ '^\s*for *(.*)\s*{\s*$'
        return Warning('Not on a line containing "for(...) {"')
    endif
    "                1-indent      2-type      3-var             4-expr
    let pat_new = '^\(\s*\)for\s*(\(\S\+\)\s\+\(\S\{-1,}\)\s*:\s*\(.*\))\s*{\s*$'
    "             1-indent                    2-expr
    let pat_old = '^\(\s*\)for\s*(Iterator\s\+\w\+\s*=\s*\(.\{-1,}\)\.iterator()\s*;\s*\w\+\.hasNext()\s*;\s*)\s*{\s*$'
    if text =~ pat_new  " new style iterator
        let new_text1 = substitute(text, pat_new,
            \ '\1for (Iterator i = \4.iterator(); i.hasNext(); ) {', '')
        if new_text1 == text
            return Error('Internal error')
        endif
        let new_text2 = substitute(text, pat_new, '\1    \2 \3 = (\2) i.next();', '')
        call setline('.', new_text1)
        call append(line('.'), new_text2)
    elseif text =~ pat_old
        "                1-type   2-var
        let pat_old2 = '^\s*\(\S\+\)\s\+\(\w\+\)\s*=\s*(\s*\S\+\s*)\s*\w\+\.next()\s*;\s*$'
        let text2 = getline(line('.') + 1)
        if text2 !~ pat_old2
            return Warning("Failed to find 2nd line of old-style iterator:\n" . text2)
        endif
        let decl = substitute(text2, pat_old2, '\1 \2', '')
        let new_text = substitute(text, pat_old, '\1for (' . decl . ' : \2) {', '')
"        let new_text = substitute(text, pat_old, '\1for (# : \2) {', '')
        if new_text == text
            return Error('Internal error - failed to substitute')
        endif
        call setline('.', new_text)
        .+1 delete
        -
    else
        return Warning('Current line does not look like old or new style iterator')
    endif
endfunction

Help ',ma - make array iterator'
nmap ,ma :call MakeIter(1)<cr>
Help ',mi - make iterator'
nmap ,mi :call MakeIter(0)<cr>
function! MakeIter(isarray)
    let prompt = 'Enter ' . (a:isarray ? 'array' : 'collection') . ' name'
    let id = GetID(0, prompt, 1)
    if id == "" | return | endif
    if a:isarray
        call Norm("ofor (int i = 0; i < " . id
            \ . ".length; i += 1) {\<cr>}\<esc>")
    else
"        call Norm("ofor (Iterator i = " . id
"            \ . ".iterator(); i.hasNext(); ) {\<cr>i.next();\<cr>}\<esc>\<up>")
        if id =~ 'ies$'
            let id2 = substitute(id, 'ies$', 'y', '')
        else
            let id2 = substitute(id, '\(.\)\(s\|Map\|List\|Set\)$', '\1', '')
        endif
        if id2 == id
            let id2 = 'x'
        endif
        call Norm("ofor (Iterator i = " . id
            \ . ".iterator(); i.hasNext(); ) {\<cr>"
            \ . "Type " . id2 . " = (Type) i.next();\<cr>}\<esc>\<up>^")
        let @/ = '\<Type\>'
    endif
endfunction

Help ',mg - make getter function for current field (Java)'
nmap ,mg :call MakeGetter()<cr>
function! MakeGetter()
    let line = getline('.')
    let line = substitute(line, '\s*=.*;', ';', '') " remove initializer
    let line2 = substitute(line, '^\s*private\s\+\(.*\S\)\s*;\s*$', ' \1', '')
    if line2 == line
        return Warning('not on a private field decl')
    endif
    let type = MatchNth(line2, '.*\s\(\S\+\)\s\+\(\S\+\)$', 1)
    let name = MatchNth(line2, '.*\s\(\S\+\)\s\+\(\S\+\)$', 2)
    let getter = substitute(name, '^.', 'get\u&', '')
    if line2 =~ '\sstatic\s'
        let type = 'static ' . type
    else
        let name = 'this.' . name
    endif
"    call PutBelow(
"        \ 'public ' . type . ' ' . getter . '() {',
"        \ "\<space>\<bs>" . 'return ' . name . ';',
"        \ '}')
    call PutBelow(
        \ 'public ' . type . ' ' . getter . '() {',
        \ "\<tab>return " . name . ';',
        \ '}')
endfunction

"TODO: see AddGetterSetter for something similar
Help ',jf - add final Java field with getter'
Help ',JF - add Java field with getter and setter'
noremap ,jf :call JavaAddField(1)<cr>
noremap ,JF :call JavaAddField(0)<cr>
function! JavaAddField(isfinal)
    let x = Input('Enter <type> <name>: ')
    if x == ''
        return
    endif
    let pat = '^\(\w\+\) \(\w\+\)$'
    if x !~ pat
        return Warning('Expected two java ids')
    endif
    let type = MatchNth(x, pat, 1)
    let name = MatchNth(x, pat, 2)
    let field = 'private ' . (a:isfinal ? 'final ' : '') . type . ' ' . name . ';'

    let gname = substitute(name, '\w', 'get\u&', '')
    let sname = substitute(name, '\w', 'set\u&', '')
"    let getter = 'public ' . type . ' ' . gname . "() {\n    return this."
"        \ . name . ";\n}\n"
"    echo getter

    let indent = substitute(getline('.'), '\S.*', '', '')

    let getter = [ '' ]
    let getter += [ printf('public %s %s() {', type, gname) ]
    let getter += [ printf('    return this.%s;', name) ]
    let getter += [ '}' ]

    let setter = [ '' ]
    let setter += [ printf('public void %s(%s %s) {', sname, type, name) ]
    let setter += [ printf('    this.%s = %s;', name, name) ]
    let setter += [ '}' ]

    call append('.', Indent(indent, setter))
    call append('.', Indent(indent, getter))
    call append('.', Indent(indent, [ field ]))


"    if !a:isfinal
"        let sname = substitute(name, '\w', 'set\u&', '')
"        let setter = printf("public void %s(%s %s) {\n    this.%s = %s;\n}\n",
"            \ sname, type, name, name, name)
"        echo setter
"    endif
endfunction

" Indent each element of a:list the a:indent string
function! Indent(indent, list)
    return map(a:list, 'strlen(v:val) > 0 ? a:indent . v:val : ""')
endfunction

" TODO still have problems restoring position (due to echoing more than
" one line?)
Help ',wh - show where we are, lexically, in a language with braces'
nmap <silent> ,wh :call Bold(Where())<cr>
function! Where()
    let start = GetPos()
    let out = ""
    while 1
        let pos = GetPos(1)
        silent! normal! [{
        if pos == GetPos(1)
            break  " didn't move, so we are done
        endif
        normal! b
        let line = getline(".")
        if line =~ '^\s*\(implements\|extends\|throws\)\s'
            -
            let line = getline(".")
        endif
        let out = line . "\n" . out
    endwhile
    call Norm(start)
    return Chomp(out)
endfunction


" FIX

Help ',fi - Java: fix import -- search for use of import & delete if none'
Help ',fi - html: fix id -- add an id to the current html element'

autocmd FileType html nmap ,fi :call HtmlFixIdent()<cr>
function! HtmlFixIdent()
    let curr_line = getline('.')
    let text = substitute(curr_line, '.*>\(.\+\)<.*', '\1', '')
    if text == curr_line
        return Warning('No closed html element found on this line')
    endif
    let id = substitute(text, '\W\+', '-', 'g')
    if id == ''
        return Warning('No id chars in text: ' . text)
    endif
    let id = "'" . id . "'"
    let curr_line = substitute
        \ (curr_line, '>\(.\+\)<', ' id=' . id . '>\1<', '')
    call setline(line('.'), curr_line)
endfunction

autocmd FileType java nmap ,fi :call JavaFixIf()<cr>
function! JavaFixIf()
    let pat = '^\s*\(\(}\s*\|\)else\s\+if\s*(\|\(}\s*\|\)else\|if\s*(\)[^{]*$'
    let line = getline('.')
    if line !~ pat
        " not on a bad if line -- search for the next one
        let @/ = pat
        call Norm('n')
        return
    endif
    let line2 = substitute(line, '\(\s*//.*\)', ' {\1', '')
    if line2 == line
        let line2 = substitute(line, '\s*$', ' {', '')
    endif
    call setline('.', line2)
    if search(';', 'W') == 0
        return Warning('Did not find ; at end of stmt')
    endif
    call Norm('j')
    if getline('.') =~ '^\s*else\>'
        call Norm("I} \<esc>")
    else
        call Norm("O}\<esc>")
    endif
endfunction

"autocmd FileType java nmap ,fi :call JavaFixImport()<cr>
function! JavaFixImport()
    let import = Match1(getline('.'), '^\s*import\s\+\S\+\.\([A-Z]\w\+\)\s*;')
    if import == ""
        return Warning("not on an import-type line")
    endif
    let l = Search('\<'.import.'\>', +1, line('.')+1)
    if l == 0
        call Bold(import . ' is not needed')
        delete
    else
        call Bold(import . ' is needed on line ' . l)
        +
    endif
    let l = Search('^\s*import\s', +1)
    if l != 0
        exec l
    endif
endfunction

Help ',f; - split multiple ;-separated statements on one line'
nmap ,f; :call FixStmts()<cr>
function! FixStmts()
    call Norm('0')
    let l = line('.')
    while getline('.') =~ ';.*\S'
        call Norm("0f;a\<cr>\<esc>")
    endwhile
    exec l
endfunction

Help ',f) - method decl after ), putting throws on own line'
nmap ,fT :call FixThrows()<cr>
function! FixThrows()
    call Norm("0f)a\<cr>\<esc>f{bea\<cr>\<esc>^")
endfunction
"foo ()
"throws
"bar {

" split parameters to separate lines
nmap ,f, :call FixParams2()<cr>
" in this version, do "throws" first
function! FixParams2()
    if getline('.') !~ '('
        " maybe not java -- just split at commas
        let pos = GetPos()
        exec "s/,\\s*/,\<cr>/g"
        call Norm(pos)
        return
    endif
    call Norm("0f(mx%my")
    if AfterCursor() =~ '^)\s*throws\>'
        call Norm("a\<cr>\<esc>")
    endif
    call Norm("f{")
    if GetChar() == '{'
        call Norm("?\\S\<cr>a\<cr>\<esc>")
    endif
    let n = line("'y") - line("'x")
    call Norm("`xa\<cr>\<esc>")
    while n >= 0
        let n = n - 1
        while match(getline('.'), ',') >= 0
            call Norm("f,a\<cr>\<esc>")
        endwhile
    endwhile
    if match(getline('.'), ')\s*throws\s') >= 0
        call Norm("])a\<cr>\<tab>")
        call Norm("f{bhea\<cr>\<c-d>")  " need ^D in this case
    elseif match(getline('.'), '{\s*$') >= 0
        call Norm("f{bhea\<cr>")
    endif
    call Norm("'x")
endfunction

function! FixParams()
    call Norm("0f(%%")
    let line0 = line("''")
    let n = line0 - line(".")
    call Norm("a\<cr>\<esc>")
    while n >= 0
        let n = n - 1
        while match(getline('.'), ',') >= 0
            call Norm("f,a\<cr>\<esc>")
        endwhile
    endwhile
    if match(getline('.'), ')\s*throws\s') >= 0
        call Norm("])a\<cr>\<tab>")
        call Norm("f{bhea\<cr>\<c-d>")  " need ^D in this case
    elseif match(getline('.'), '{\s*$') >= 0
        call Norm("f{bhea\<cr>")
    endif
"    exec line0
endfunction

Help ',fd - remove diff prefixes'
"vmap ,fd :s/^\(< \\|> \\|+\\|-\)//<cr>
vmap ,fd :<c-u>call FixDiff()<cr>
function! FixDiff()
    '<,'>s/^\(< \|> \|+\|-\)//
endfunction

Help ',f* - change /* */ comments to //'
vmap ,f* <esc>:call FixComment()<cr>
nmap ,f* :call HighlightComment()<cr><esc>:call FixComment()<cr>
function! FixComment()
    let l2 = line("'>")
    let x2 = getline(l2)
    let y2 = substitute(x2, '\s*\*/\s*$', '', '')
    if x2 == y2
        if y2 =~ '\*/'
            return Error("comment not at end of line: " . x2)
        else
            return Error("no comment found: " . x2)
        endif
    endif
    if !SetOrDelete(l2, y2)
        let l2 = l2 - 1
    endif

    let l1 = line("'<")
    let x1 = getline(l1)
    let y1 = substitute(x1, '\s*\/\*\+\s*$', '', '')
    if x1 == y1
        let y1 = substitute(x1, '/\*\+', '//', '')
        if x1 == y1
            return Error("didn't find /* on line: " . x1)
        endif
    endif

    if l2 > l1
        silent exec (l1+1) . ',' . l2 . 's/\s*\**/\/\//'
    endif

    call SetOrDelete(l1, y1)
endfunction

" Set line l1 to x1, or delete it if there is only whitespace
" Return 1 for set, 0 for delete
function! SetOrDelete(l1, x1)
    if a:x1 =~ '\S'
        call setline(a:l1, a:x1)
        return 1
    else
        exec a:l1 . " delete"
        return 0
    endif
endfunction

Help ',fq - fix java qualified name not to have package'
nmap ,fq :call FixQualified()<cr>
function! FixQualified()
    let save = SaveSet('iskeyword', '+.') . SaveSet('ignorecase', 0)
    let name = GetWord()
    exec save
    let save = SaveSet('ignorecase', 0)
    let simple = substitute(name, '^\([a-z]\w*\.\)*\([A-Z].*\)', '\2', '')
    exec save
    if name == simple
        call Warning('Did not find qualified name under cursor: ' + name)
    else
        let save = SaveSet('iskeyword', '-.') . SaveSet('ignorecase', 0)
        let class = substitute(name, '^\(\([a-z]\w*\.\)*[A-Z]\w*\).*', '\1', '')
        exec save
        let import = 'import ' .  class . ';'
        " add the import (at end of imports) if not already there
        let i = search(import, 'bn')
        if i > 0
            "call Note('Already imported: ' . class)
            "echo 'Already imported: ' . class
            echo 'Already imported:' class
        else
            let i = search('^import\s', 'bn')
            if i == 0
                call Warning('No imports found -- can insert new one')
            else
                call append(i, import)
            endif
        endif
        let save = SaveSet('iskeyword', '+.')
        call Norm('ciw' . simple)
        call Norm('b')  " start of name, not end
        exec save
    endif
endfunction

Help ',f/ - change forward slashes to backslashes'
nmap ,f/ :let tmp = @/<cr>:s#/#\\#g<cr>:let @/ = tmp<cr>:<cr>
Help ',f\ - change forward slashes to backslashes'
nmap ,f\ :let tmp = @/<cr>:s#\\#/#g<cr>:let @/ = tmp<cr>:<cr>

Help ',f" - change double quoted string to single'
Help ",f' - change single quoted string to double"
"nmap ,f" :s/"\([^"']\)*"/'\1'/<cr>
vmap ,f" :call FixQuotes1()<cr>
nmap ,f" :call FixQuotes1()<cr>
vmap ,f' :call FixQuotes2()<cr>
nmap ,f' :call FixQuotes2()<cr>
function! FixQuotes1()
    s/"\([^"']*\)"/'\1'/e
endfunction
function! FixQuotes2()
    s/'\([^"']*\)'/"\1"/e
endfunction

Help ',FQ - change normal single and double quotes to “nice” ones'
nmap ,FQ :call FixQuotes3()<cr>
vmap ,FQ :call FixQuotes3()<cr>
function! FixQuotes3()
    silent! s/"\([^"]*\)"/“\1”/g
    silent! s/'/’/g
endfunction

Help ',fk - fix keywords: remove space between them & "("'
Help ',FK - fix keywords: add space between them & "("'
"nmap ,fk :exec "%s/\(if\|while\|for\|catch\)\s\+(/\1(/g"<cr>
nmap ,fk :%s/\<\(if\\|while\\|for\\|catch\)\s*(/\1 (/g<cr>:%s/)\s*{/) {/g<cr>,hl
nmap ,FK :%s/\<\(if\\|while\\|for\\|catch\)\(\\|\t\\|\s\s\+\)(\s*/\1 (/g<cr>

Help ',fw - fix whitespace around (), {}, etc'
nmap ,fw :call FixWhiteSpace()<cr>
function! FixWhiteSpace()
    keepjumps silent %s/\<\(if\|while\|for\|switch\|catch\)\s*(\s*/\1 (/g
    keepjumps silent %s/\(try\|else\|finally\)\s*{/\1 {/g
    keepjumps silent %s/}\s*\(catch\|else\|finally\)/} \1/g
    keepjumps silent %s/)\s*{/) {/g
    keepjumps silent %s/\([^; ]\)\s*)/\1)/g
endfunction

"TODO: this breaks $NON-NLS-1$
Help ',fo - fix operators: add spaces around them if missing (incl. strings!)'
nmap ,fo :%s/\([^-+=<>! \t]\)\s*\([-+=<>!]\+\)\s*\([^-+=<>! \t]\)/\1 \2 \3/g<cr>,hl

function! FixBlock(start, end)
    let start = a:start
    let end = a:end
    call Norm(start . "GkA {")
    call Norm(end . "GA\<cr>}\<esc>")
endfunction

Help ',f{ - fix unbracketed block'
vmap ,f{ :<c-u>call FixBlock(line("'<"), line("'>"))<cr>
nmap ,f{ :call FixBlock(line('.'), line('.'))<cr>
function! FixBlock(start, end)
    let start = a:start
    let end = a:end
    call Norm(start . "GkA {")
    call Norm(end . "GA\<cr>}\<esc>")
endfunction

Help ',f< - fix < and > in html or xml: map to &lt and &gt;'
vmap ,f< d:call FixXML()<cr>
function! FixXML()
    let @" = Sub('g', @", '<', '\&lt;', '>', '\&gt;')
    call Norm('P')
endfunction


" grep
Help 'gi ,gi ,GI - grep for id, in cwd, tagspath, or whole vob'
nmap gi :call GrepId(2)<cr>
nmap ,GI :call GrepId(1)<cr>
nmap ,gi :call GrepId(0)<cr>
Help 'gr - prompt for pattern and grep'
Help 'gw - grep for current word'
Help ',gw - prompt for word and grep'
nmap gr :call Grep(0)<cr>
nmap gw :call Grep(2)<cr>
nmap ,gw :call Grep(1)<cr>
vmap gw y:call DoGrep(1, @@)<cr>
vmap gr y:call DoGrep(0, @@)<cr>

" Kind = 1 => search tags path
" Kind = 2 => search whole vob
function! GrepId(kind)
    if !Update() | return | endif
    let id = GetID(0)
    if id == "" | return | endif
    call ErrorMaps()
    let @/ = '\<' . id . '\>'
    let cmd = 'perl -S id.pl '
        \ . (a:kind == 1 ? '-vob ' : a:kind == 2 ? '-tags ' : '') . id
    call SetCmd('make', 'makeprg', cmd)
endfunction
" old way (without make)
"        let tmp = GetTemp("grep")
"        echo system("perl -S id.pl -g -o " . tmp . " " . id)
"        exec "cfile " . tmp
"        call delete(tmp)

" kind: 0 => prompt & non-word; 1 => prompt & word; 2 => current word
function! Grep(kind)
    let kind = a:kind
    if kind == 2
        let pat = GetID(0)
"        let pat = expand("<cword>")
"        if pat == ""
"            let kind = 1
"        endif
    endif
    if kind != 2
        call histadd('input', @/)
        let pat = input("Pattern? ")
        echo "\r"
        if pat == ""
            return Warning("Canceled")
        endif
    endif
    call DoGrep(kind != 0, pat)
endfunction

function! DoGrep(word, pat)
    if !Update() | return | endif
    call ErrorMaps()
    let cmd = 'perl -S g.pl -col'
    " apply smartcase to grep: use -i if no upper case letters
    if &smartcase && &ignorecase && !HasUpperCase(a:pat)
        let cmd = cmd . ' -i'
    endif
    " if in source file, only grep source
    if &ft == 'c' || &ft == 'cpp' || &ft == 'java' || &ft == 'scala' || &ft == 'idl'
        let cmd = cmd . ' -src'
    endif
    let pat = a:pat
    if a:word
        let pat = '\<' . pat . '\>'
    endif
    " double quotes in pattern cause problems on command line
    let pat = substitute(pat, '"', '[\\x22]', 'g')
    " assume pat is a vim pattern -- convert to perl for "g"
    let perlpat = VimReToPerl(pat)
    let cmd = cmd . ' -pat="' . perlpat . '" .'
    let @/ = pat
    call SetCmd("make", "makeprg", cmd)
endfunction

" Convert a Vim regular expression to a perl one.
" TODO: \(...\|...\)  =>  (...|...)
function! VimReToPerl(pat)
    return Sub('g', a:pat,
        \ '\\<', '\\b', '\\>', '\\b',
        \ '(', '\\(', ')', '\\)')
endfunction


nmap ,jd :call JDis()<cr>
function! JDis()
    let save = SaveSet('iskeyword', '+.') . SaveSet('ignorecase', 0)
    let id = GetID(0)
    " get packages & first class:
    let id = matchstr(id, '^\([a-z0-9_]\+\.\)*[A-Z]\w\+')
    exec save
    if id == "" | return | endif
    echon system("perl -S jdis.pl -vi " . id)
endfunction

Help 'dx - add debug print of current var'
Help 'DX - add debug print of current var using GUI'
Help ',dx - add debug print of current method'
nmap DX :call DebugPrint(2)<cr>
nmap dx :call DebugPrint(1)<cr>
nmap ,dx :call DebugPrint(0)<cr>
function! DebugPrint(kind)
    if !Update() | return | endif
    let save = ''
    let id = ''
    let need_indent = 0  " set for python-like langs
    if &ft == 'perl'
        let out = a:kind
            \ ? 'print "??? <id>=$<id>\n";'
            \ : 'print "??? enter <id>(@_)\n";'
        " try to add '@' to iskeyword -- doesn't seem to work
        let save = SaveSet("iskeyword", "+$,@-@,{,},[,]")
    elseif &ft == 'vim'
        let out = a:kind == 0 ? 'echo "??? enter <id>"'
            \ : a:kind == 1 ? 'echo "??? <id> = <".<id>.">"'
            \ : a:kind == 2 ? 'call GUIMsg("<id> = <".<id>.">")'
            \ : '???'
        let save = SaveSet("iskeyword", "+:")
    elseif &ft == 'go'
        let out = a:kind
            \ ? 'fmt.Printf("??? <id>: %s\n", <id>)'
            \ : 'fmt.Printf("??? enter <id>\n")'
        let need_indent = 1
    elseif &ft == 'swift'
        let out = a:kind
            \ ? 'print("??? <id>: \(<id>)")'
            \ : 'print("??? enter \(<id>)")'
    elseif &ft == 'java' || &ft == 'scala'
        if a:kind
            let out = 'System.err.println(">>> <id> = " + <id>);'
        else
            " for FQN of current pos
            let id = JavaPosition(0)
            let out = 'System.err.println(">>> enter <id>");'
        endif
    elseif &ft == 'groovy'
        let out = 'println "${<id>?.class?.simpleName} <id>=${<id>}"'
    elseif &ft == 'javascript' || &ft == 'typescript'
        let out = "console.log('<id>:', <id>);"
    elseif &ft == 'coffee'
        let out = a:kind
            \ ? "console.log '<id>:', <id>"
            \ : "  console.log 'enter <id>'"
        let need_indent = 1
        let save = SaveSet("iskeyword", "+@-@")  " include @ in iskeyword
    elseif &ft == 'python'
        let out = "print '<id>:', <id>"
        let need_indent = 1
    elseif &ft == 'sh'
        let out = 'echo "<id>=$<id>"'
    else
        return Warning("don't know how to do debug print for " . &ft)
    endif
    if id == ''
        let id = GetID(0)
    endif
    exec save
    if id == "" | return | endif
    if &ft == 'perl'
        let id = substitute(id, '^[{[]\(.*\)[]}]$', '\1', '')
        if a:kind == 0 && id == 'sub'
            call Norm("w")
            let id = GetWord()
        else
            if id =~ '^@'
                let out = substitute(out, '\$', '@', '')
            endif
            let id = substitute(id, '^[$@]', '', '')
        endif
    endif
    let out = substitute(out, '<id>', id, 'g')
    let pos = GetPos()
    if !a:kind && &ft == 'java' || &ft == 'scala'  " insert after {
        call search('{', 'W')
    endif
    if need_indent
        let indent = Match1st(getline('.'), '^\(\s*\)')
        let out = indent . out
    endif
    call append(line('.'), out)
    call Norm(pos)
endfunction

Help ',pd - run perldoc'
nmap ,pd :call PerlDoc()<cr>
function! PerlDoc()
    if !Update() | return | endif
    let save = SaveSet('iskeyword', '+:,/')
    if AfterCursor() =~ '^use\s'
        " on 'use Foo' want to get Foo
        call Norm('w')
    endif
    let id = GetID(0)
    exec save
    if id == '' | return | endif
    call Warning(system('pd ' . id))
endfunction

function! MakeCProto(quiet)
    call Norm('mz')
    1
    let l = search('^static .*);$', 'c')
    if l > 0
        let l = l - 1
        if getline('.') == ''
            delete
            let l = l - 1
        endif
        silent g/^static .*);$/delete
        call cursor(l, 1)
    else
        " no proto decls yet
        " find last include/typedef/struct
        " search backward from end without moving cursor
        $
        let l1 = search('^# *include', 'bcn')
        let l2 = search('^struct ', 'bcn')
        let l3 = search('^typedef ', 'bcn')
        let l = max([l1, l2, l3])
        if l > 0
            call cursor(l, 1)
            call Norm('f{%')  " end of multi-line struct decl
            call Norm("o\<esc>")
        else
            call Norm("1GO\<esc>")
        endif
    endif
    let l = line('.')
    silent read !cproto -S %
    if getline(l+1) =~ '/\*'
        call cursor(l+1, 1)
        delete
    endif

    call Norm('`z')
    "marks
endfunction

Help ',mp - make perl prototypes'
"nmap <silent> ,mp :call MakeProto()<cr>
nmap ,mp :call MakeProto()<cr>
function! MakeProto(...)
    let quiet = a:0 > 0 && a:1
    if !Update() | return | endif
    if &ft == 'c'
        return MakeCProto(quiet)
    endif
    if &ft != 'perl'
        return Warning("don't know how to make protos for " . &ft . " files")
    endif
    let pos = GetPos()
    1
    let protos = ''   " new protos
    let proto_l = 0   " old ones started at
    let adjust = 0    " number of lines added
    let fixed = 0     " number of subs fixed
    while 1
"        let l = search('^\s*sub\s\+\w\+', 'W')
        " NOTE: don't do indented ones because we don't put protos in right
        " place; don't do 'sub foo::bar()' either
        let l = search('^sub\s\+\w\+[^:\w]', 'W')
        if l == 0
            break  " no more subs
        endif
        let sub = getline(l)
        if sub =~ '^[^{]*;\s*\(#\|$\)'  " old proto -- delete it
            let adjust = adjust - 1
            delete
            -
            if proto_l == 0
                let proto_l = l - 1
            endif
        else
            " try to fix up sub from arg decl, if any
            if sub !~ '(.*[&;].*)'  "NOTE can't replace proto with ; or &
                let p = GetProtoFromArgs(getline(l+1))
                if p != ''
                    let new_sub = substitute(
                        \ sub, '\(sub\s\+\(\w\|:\)\+\)\(\s*(.*)\)\=', '\1' . p, '')
                    if new_sub != sub
                        call setline(l, new_sub)
                        let fixed = fixed + 1
                        let sub = new_sub
                    endif
                endif
            endif
            if sub =~ '(.*)'
                let adjust = adjust + 1
                let private = matchstr(sub, '{.*\<private\>')
                let p = substitute(sub, ').*', ');', '')
                if private != ''
                    let p = p . '  # private'
                endif
                let p = substitute(p, '^\s\+', '', '')
                let protos = protos . p . g:cr
            endif
        endif
    endwhile
    if protos != ''
        if proto_l == 0
            " no protos found; look for 'use', but not 'use constant'
            let proto_l = search('^use \(constant\)\@!.*;\s*$', 'b')
        endif
        call append(proto_l, protos)
        let proto_l = proto_l + 1
        " turn ^M into real newlines
        exec proto_l . 's/' . g:cr . '/' . g:cr . '/g'
        delete
        silent update
    endif
    " adjust the saved pos based on lines added or removed
    let line = Match1st(pos, '\(\d*\)\(.*\)') + adjust
    let pos = line . Match2nd(pos, '\(\d*\)\(.*\)')
    call Norm(pos)
    if !quiet
        let msg = adjust . ' new protos found'
        if fixed > 0
            let msg = msg . '; ' . fixed . ' protos fixed'
        endif
        echo msg
    endif
endfunction

" look for perl arg assignment and construct a proto
function! GetProtoFromArgs(x)
    let x = substitute(a:x, '\s\+', '', 'g')
    let y = substitute(x, '^\(my\|local\)\((.*)\)=@_;.*', '\2', '')
    if y == x
        return ''  " didn't find one
    endif
    return substitute(y, '\w\+,\=', '', 'g')
endfunction

Help ',al - add a Logger for this class'
nmap ,al :call AddLogger()<cr>
function! AddLogger()
    if &filetype != 'java'
        return Warning(',al only applies to java source files')
    endif
    let pos = GetPos()
    let pat = '^\s*\%(public\s\+\)\=class\s\+'
    " search backward for class decl
    + " move forward in case we are on the line of the decl
    let l = search(pat, 'bW')
    if l == 0
        let l = search(pat, 'W')
        if l == 0
            call Norm(pos)
            return Warning('No class declaration found in this file')
        endif
    endif
    let class = substitute(getline(l), pat . '\(\w*\).*', '\1', '')
    call Norm("Oimport com.ibm.cic.common.logging.Logger;\<esc>")
    let l = search('{')
    call Norm("A\<cr>"
        \ . 'private static final Logger log = Logger.getLogger('
        \ . class . ".class);\<esc>")
    call Norm(pos)
endfunction

Help ',ag - add java getter method for declaration on current line'
Help ',aG - add java setter method for declaration on current line'
nmap ,ag :call AddGetterSetter(1)<cr>
nmap ,aG :call AddGetterSetter(0)<cr>
function! AddGetterSetter(want_getter)
    let line = getline('.')
    let pat = '^\(\s*\).\{-}\(\S\+\)\s\+\(\S\+\)\s*[=;].*'
    let indent = substitute(line, pat, '\1', '')
    let type = substitute(line, pat, '\2', '')
    let var = substitute(line, pat, '\3', '')
    if type == line
        return Warning('No declaration found on current line')
    endif
    let name = substitute(var, '.', '\u&', '')

    let method = [ '' ]
    if a:want_getter
        let method += [ indent . 'public ' . type . ' get' . name . '() {' ]
        let method += [ indent . '    return this.' . var . ';' ]
    else
        let method += [ indent . 'public void set' . name
            \ . '(' . type . ' ' . var . ') {' ]
        let method += [ indent . '    this.' . var . ' = ' . var . ';' ]
    endif
    let method += [ indent . '}' ]
    "let method += [ '' ]
    call append('.', method)
endfunction

Help ',ac - add java cast to assignment on current line'
nmap ,ac :call AddCast()<cr>
function! AddCast()
    let line = getline('.')
    if line !~ '='
        return Warning('no assignment on current line')
    endif
    let class = substitute(line, '^\s*\([A-Z]\w*\).*', '\1', '')
    if class == line
        return Warning("can't find class name")
    endif
    let line = substitute(line, '=\s*', '= (' . class . ') ', '')
    call setline(line('.'), line)
endfunction

Help ',si - sort java imports for current file'
nmap ,si :call SortImports()<cr>
function! SortImports()
    if !Update() | return | endif
    let msg = system("perl -S sort_imports.pl " . @% . " 2>&1")
    let msg = Chomp(msg)
    if v:shell_error == 0
        if msg != "--- no change"
            normal ,re
        endif
        call Bold(msg)
    else
        call Warning(msg)
    endif
endfunction

" For autohotkey: ,GP finds the patch file and puts in clipboard
nmap ,GP :call GetPatchFile()<cr>
function! GetPatchFile()
    let l1 = getline(1)
    if l1 =~ '^Patch in '
        let patch = substitute(l1, 'Patch in ', '', '')
    elseif l1 == '### Jazz Patch 1.0'
        let patch = expand('%')
    else
        let @* = ''
        return Warning('Did not find patch file')
    endif
    let @* = patch
    echo patch
endfunction

" For autohotkey: return current file and line number as 2-element array.
" Special handling for diffs: return the info for the file being diffed, rather than the diff file.
function! GetFileAndLine()
    if &filetype == 'diff'
        "TODO: file needs to be relative to cwd of vim
        let _ = GetDiffLine2()
        let _[0] = substitute(getcwd() . '/' . _[0], '/', '\\', 'g')
        return _
    else
        return [expand('%:p'), line('.')]
    endif
endfunction

" For autohotkey: save current position in vi.pos
" ,sp1 - file and line
" ,sp2 - class and line
nmap ,sp1 :call SavePosition1()<cr>
vmap ,sp1 <esc>,sp1gv
function! SavePosition1()
    call Update()
    let file = expand('%:p')
    let line = line('.')
    call writefile([file, line], g:vi_pos)
    echo expand('%:t') . ' ' . line
endfunction

nmap ,sp2 :call SavePosition2()<cr>
"vmap ,sp2 <esc>,sp2gv
vmap ,sp2 y:call SavePositionVisual()<cr>gv
function! SavePositionVisual()
    call Update()
    let text = @@
    "              1 2            3           4   5
    let pat = '^\C\(\(\w\+\.\)*\)\([A-Z]\w*\)\(\.\([a-z]\w*\)\)\=$'
    let class = substitute(text, pat, '\3', '')
    if class == text
        echo 'no match'
        call SavePosition2()
        return
    endif
    let pkg = substitute(text, pat, '\1', '')
    let method = substitute(text, pat, '\5', '')
"    echo 'pkg='.pkg . ' class='.class . ' method='.method
    call writefile([pkg.class, '0', method], g:vi_pos)
    echo pkg.class . ' ' . method
endfunction
function! SavePosition2()
    if exists(g:vi_pos)
        call delete(g:vi_pos)
    endif
    call Update()
    let file = ''
    let class = ''
    let line = ''
    if &filetype == 'java' || &filetype == 'scala'
        let file = expand('%:p')
        let line = line('.')
    elseif &filetype == 'diff'
        let [file, line] = GetDiffLine2()
    elseif &filetype == 'xml'
        " assume it's an IM log with a call stack element
        let stack = getline('.')
        if stack =~ '<stack>.*</stack>'
            let class = substitute(stack, '.*<stack>\(\S\+\)\.\(\S\+\)(.*:\(\d\+\)).*', '\1', '')
            let line = substitute(stack, '.*<stack>\(\S\+\)\.\(\S\+\)(.*:\(\d\+\)).*', '\3', '')
        endif
    elseif expand('%:t') == 'all.properties'
        " look for Messages.java and line number
        let text = getline('.')
        if text =~ '^ \+\w\+\s*='
            let text = getline(line('.') - 1)
        endif
        let class = substitute(text, '.*\\src\\\(.*\)\.java:\(\d\+\)$', '\1', '')
        let class = substitute(class, '\\', '.', 'g')
        let line = substitute(text, '.*\\src\\\(.*\)\.java:\(\d\+\)$', '\2', '')
    endif
    if line == ''
        " fall back on file + line
        call SavePosition1()
    else
        if class == ''
            let class = fnamemodify(file, ':t:r')
            let file = substitute(file, '\\', '/', 'g')
            if file =~ '/src/'
                let pkg = substitute(file, '^.*/src/\(.*\)/' . class . '.java$', '\1', '')
                if pkg != file
                    let pkg = substitute(pkg, '/', '.', 'g')
                    let class = pkg . '.' . class
                endif
            endif
        endif
        call writefile([class, line], g:vi_pos)
        echo class . ' ' . line
    endif
endfunction

" Put fully-qualified class name and line number into clipboard
nmap ,sp3 :call SavePosition3()<cr>
function! SavePosition3()
    call Update()
    let file = ''
    let class = ''
    let line = ''
    if &filetype == 'java' || &filetype == 'scala'
        let file = expand('%:p')
        let line = line('.')
    elseif &filetype == 'diff'
        let [file, line] = GetDiffLine2()
    elseif &filetype == 'xml'
        " assume it's an IM log with a call stack element
        let stack = getline('.')
        if stack =~ '<stack>.*</stack>'
            let class = substitute(stack, '.*<stack>\(\S\+\)\.\(\S\+\)(.*:\(\d\+\)).*', '\1', '')
            let line = substitute(stack, '.*<stack>\(\S\+\)\.\(\S\+\)(.*:\(\d\+\)).*', '\3', '')
        endif
    elseif expand('%:t') == 'all.properties'
        " look for Messages.java and line number
        let text = getline('.')
        if text =~ '^ \+\w\+\s*='
            let text = getline(line('.') - 1)
        endif
        let class = substitute(text, '.*\\src\\\(.*\)\.java:\(\d\+\)$', '\1', '')
        let class = substitute(class, '\\', '.', 'g')
        let line = substitute(text, '.*\\src\\\(.*\)\.java:\(\d\+\)$', '\2', '')
    endif
    if line == ''
        " fall back on file + line
        return Warning("Couldn't determine class name")
    else
        if class == ''
            let class = fnamemodify(file, ':t:r')
            let file = substitute(file, '\\', '/', 'g')
            if file =~ '/src/'
                let pkg = substitute(file, '^.*/src/\(.*\)/' . class . '.java$', '\1', '')
                if pkg != file
                    let pkg = substitute(pkg, '/', '.', 'g')
                    let class = pkg . '.' . class
                endif
            endif
        endif
        call writefile([class, line], g:vi_pos)
        let @* = class . ':' . line
        echo @*
    endif
endfunction

" This mapping is for use by AutoHotkey.
" It is supposed to determine the "current class" and set it in the clipboard.
" AutoHotkey will activate eclipse and go to that class.
nmap ,GC :call JavaGetClass(0)<cr>
vmap ,GC <esc>:call JavaGetClass(1)<cr>
function! JavaGetClass(is_visual)
    let id = ''
    if a:is_visual
        " get id that was highlighted
        if line("'<") == line("'>")
            call Norm("gvy")
            let id = @@
        endif
    else
        " get id under cursor
        let id = GetWord()
    endif
    " Class name must start with uppercase, contain lower case, no _
    let id_pat = '^\([A-Z]\+[a-z0-9]\+\)\+$'
    if id =~# id_pat
        " this one is good
    elseif &filetype == 'diff'
        let diff_line = search('^=== diff ', 'bcnW')
        if diff_line != 0
            let id = substitute(getline(diff_line), '.*/\(.*\)\.java.*', '\1', '')
        endif
    elseif &ft == 'java' || &ft == 'scala'
        let id = expand('%:t:r')
    endif
    if id =~# id_pat
        let @* = id
        echo 'Class: ' . id
    else
        let @* = ''
        call Warning('Failed to determine class')
    endif
endfunction

"jspec has bugs
"nmap ,jp :call Bold(Chomp(system('jspec -show ' . line('.') . ' ' . @%)))<cr>

Help ',jc - go to the enclosing java class or interface'
nmap <silent> ,jc g.:call JavaEnclosingClass()<cr>
function! JavaEnclosingClass()
    echo
    let l = Chomp(system('joutline -class ' . line('.') . ' "' . @% . '"'))
    if v:shell_error
        return Warning(l)
    endif
    exec l
endfunction

Help ',jm - go to the enclosing java method'
nmap <silent> ,jm g.:call JavaEnclosingMethod()<cr>
function! JavaEnclosingMethod()
    echo
    let l = Chomp(system('joutline -method ' . line('.') . ' "' . @% . '"'))
    if v:shell_error
        return Warning(l)
    endif
    exec l
endfunction

" TODO: java only?
Help 'cq - copy java qualified name'
nmap <silent> cq :call Bold(JavaQualifiedName(0))<cr>

function! JavaQualifiedName(qualified)
    if &filetype != 'java'
        return Error('Only works in java file')
    endif
    let class_pat = '.*\<\(class\|interface\|enum\)\s\+\(\w\+\).*'
    let pos = GetPos()
    let cline = getline('.')
    let name = Match1st(cline, '.*\s\(\w\+\)\s*(.*')
    if name == ''
        let name = Match2nd(cline, class_pat)
        if name == ''
            return Error('Did not find method or class name on current line')
        endif
    endif
    " Find context by going outward
    while matchstr(cline, '^\s*') != ''
        call FindIndent('b', 1)
        let cline = getline('.')
        let class = Match2nd(cline, class_pat)
        if class == ''
            break
        endif
        let name = class . '.' . name
    endwhile
    if a:qualified
        " add package if there is one
        if search('^\s*package\s\+', 'beW') != 0
            let package = substitute(AfterCursor(1), ';.*', '', '')
            let name = package . '.' . name
        endif
    endif
    call Norm(pos)
    let @* = name
    return name
endfunction

Help ',jq - show the class-qualified name of current element in a java file'
Help ',JQ - show the fully-qualified name of current element in a java file'
nmap <silent> ,jq :call Bold(JavaPosition(0))<cr>
nmap <silent> ,JQ :call Bold(JavaPosition(1))<cr>

" Get the name of the java element on current line.
" qualified => include package
function! JavaPosition(qualified)
    if &filetype == 'diff'
        return JavaFQNameInDiff()
    endif
    return JavaQualifiedName(a:qualified)
endfunction

" Return the fully-qualified name of the name under the cursor in a java diff
function! JavaFQNameInDiff()
    let name = GetWord()
    if name !~ '^\w\+$'
        return Warning('No name under cursor')
    endif
    let file_line = search('^\(---\|+++\|===\) ', 'bnW')
    if file_line == 0
        return Warning('Cannot find name of file in diff')
    endif
    let class_name = substitute(getline(file_line), '^... \(.*\)\.java\t.*', '\1', '')
    let class_name = substitute(class_name, '.*/src/', '', '')
    let class_name = substitute(class_name, '/', '.', 'g')
    let fqname = class_name . '.' . name
    let @* = fqname
    return fqname
endfunction

" Editing a .jspec file causes jspec to be run on the corresponding .java
" file.  Then "gl" goes back to the corresponding line in the .java file.

"??? would be nice to from .java to corresponding line of .jspec

Help ',js - edit a spec of the current java file'
nmap ,js :let g:js_line=line('.')<cr>gU:e %:r.jspec<cr>

autocmd BufEnter *.jspec call DoJavaSpec()
function! DoJavaSpec()
    let jfile = expand("%:r") . ".java"
    let save = SaveSet('report', 999999)
"    call Filter('jspec -vi ' . g:js_line . ' "' . jfile . '"')
    call Filter('joutline -spec "' . jfile . '"')
    exec save
    1

"TODO add -vi to joutline
"it is to write dest line in last line of file; this goes there:
"    let l = getline('$')
"    set noreadonly
"    $ delete
"    exec l
"    normal! zz

    setlocal nowrap
    set nomod readonly ft=java

    set buftype=nowrite
    set bufhidden=delete
    set noswapfile
    set nobuflisted
endfunction

function! GotoJSpecLine()
    let line = line(".")
    let tmp = 'c:\temp\jspec.tmp'
    let save = SaveSet("cpo", "-A") . SaveSet("write", 1) . SaveSet("ch", 2)
    exec "write! " . tmp
    let new_line = system("jspec -line " . line . " " . tmp)
    call GotoLoc(expand("%:r") . ".java%" . new_line)
    exec save
endfunction

Help ',ji ,JI - add Java import of current id, based on prefix or eclipse path'
noremap ,ji :call JavaAddImport('')<cr>
noremap ,JI :call JavaAddImport('-eclipse ')<cr>
function! JavaAddImport(opt)
    if !Update() | return | endif
    let id = GetID(0)
    if id == "" | return | endif
    let import = system("perl -S add_import.pl -vi " . a:opt . id . " " . @% . " 2>&1")
    " this returns the line# and import line to insert (or error)
    let l = MatchNth(import, '^\(\d\+\) \(.\+\)', 1)
    if l == ""
        call Warning(Chomp(import))
    else
        let import = MatchNth(import, '^\(\d\+\) \(.\+\)', 2)
        call Bold(import)
        call append(l, import)
    endif
endfunction

Help 'zp - show the current position in a file'
nnoremap <silent> zp :call Bold(ShowPosition())<cr>

function! ShowPosition()
    let pos = GetPos()
    if &ft == 'java'
        let result = JavaPosition(0)
    elseif &ft == 'perl'
        let sub = ''
        let pack = ''
        let save2 = SaveSet('iskeyword', '+:')
        let l = search('^\s*sub\s\+\k', 'Wb')
        if l != 0
            let sub = Match1st(getline(l), '^\s*sub\s\+\(\k\+\)')
        endif
        let l = search('^\s*package\s\+\k', 'Wb')
        if l != 0
            let pack = Match1st(getline(l), '^\s*package\s\+\(\k\+\)')
        endif
        let sep = sub != '' && pack != '' ? '::' : ''
        let result = pack . sep . sub
        exec save2
    else
        call Warning("don't know how to show position for " . &ft)
        let result = ''
    endif
    call Norm(pos)
    return result
endfunction

" UTILITIES

" Get the char under the cursor
function! GetChar()
    return Yank('yl')
endfunction

" Get the word under the cursor, not like expand('<cword>')
function! GetWord()
    return Yank('yiw')
endfunction

" Get the word under the cursor, not like expand('<cword>')
function! GetWordBig()
    return Yank('yiW')
endfunction

" Execute a "yank" command and return the string yanked.
" Preserve the unnamed buffer
function! Yank(cmd)
    let save = @"
    " set report or we may get 'n lines yanked' message
    call SetNorm(a:cmd, 'report', 999999)
    let result = @"
    let @" = save
    return result
endfunction


" Return the part of the current line before the cursor; exclude cursor by
" default, pass in 1 to include it.
function! BeforeCursor(...)
    let exclude = a:0 == 0 || a:1 == 0
    let line = getline('.')
    let col = col('.') - exclude
    return strpart(line, 0, col)
endfunction

" Return the part of the current line after the cursor; include cursor by
" default, pass in 1 to exclude it.
function! AfterCursor(...)
    let include = a:0 == 0 || a:1 == 0
    let line = getline('.')
    let col = col('.') - include
    return strpart(line, col)
endfunction

" Replace the part of the current line after the cursor (including cursor)
" with the specified string.
function! PutAfterCursor(str)
    call setline('.', BeforeCursor() . a:str)
endfunction

" Delete pattern at cursor (including cursor);
" return 1 if line changed, 0 if not.
function! DelAfterCursor(pat)
    let pat = '^' . a:pat
    let s1 = AfterCursor()
    let s2 = substitute(s1, pat, '', '')
    if s1 == s2
        return 0
    else
        call PutAfterCursor(s2)
        return 1
    endif
endfunction

" Our best attempt at determining the existence of a file.
" filewritable added in 7.0?
function! FileExists(path)
    " avoid slow check: // comments that look like shares
    if a:path =~ '^\(//\|\\\\\) '
        return 0
    endif
    return filereadable(a:path) || filewritable(a:path) || isdirectory(a:path)
endfunction

" Get the current file under the cursor
" Move right to first file chars
" Strip off spaces and other chars that shouldn't be at start or end.
function! GetCfile()
    let col = col('.')
    while 1
        let c = GetChar()
        if c =~ '\f'
            break
        endif
        call Norm('l')
        let new_col = col('.')
        if new_col == col
            break  " didn't move -- at end of line
        endif
    endwhile
    return Sub('', expand("<cfile>"), '^[ \t@]\+', '', '[ \t@]\+$', '')
endfunction

" Like GetCfile, but allow spaces too.
function! GetCfile2()
    let path = GetCfile()
    if FileExists(path)
        return path
    endif
    " see if allowing spaces finds it
    let save = SaveSet("isfname", "+32")
    let path2 = GetCfile()
    call RestoreSet(save)
    " ignore double spaces
    let path2 = substitute(path2, '  .*', '', '')
    " strip junk before C: or \ or / (preceded by space)
    let path2 = substitute(path2, '.* \(\\\|/\|[a-zA-Z]:\)', '\1', '')
    " strip stuff after a colon (e.g. line num)
    let path2 = substitute(path2, '^\(..[^:]*\):.*', '\1', '')
    let path2 = substitute(path2, '\s\+$', '', '')
    if FileExists(path2)
        return path2
    endif
    return path
endfunction

" call search(), and if it fails go to the end in that direction
function! SearchOrEnd(pat, ...)
    let pat = a:pat
    let flags = a:0 == 0 ? '' : a:1
    let l = search(pat, flags)
    if l == 0
        if flags =~ 'b'
            1
        else
            $
        endif
    endif
    return l
endfunction


"??? see new builtin search()

" Return first line number where pat is found.  Args 3 and 4 are starting
" and ending lines (default: current and last in given direction), dir is
" direction (+1/-1).
function! Search(pat, dir, ...)
    let line1 = 0
    if a:0 == 0
        let line0 = line(".")
    else
        let line0 = a:1
        if a:0 == 2
            let line1 = a:2
        endif
    endif
    if line1 == 0
        let line1 = Cond(a:dir == 1, line("$"), 1)
    endif
    while 1
        if match(getline(line0), a:pat) >= 0
            return line0
        endif
        if line0 == line1
            return 0
        endif
        let line0 = line0 + a:dir
    endwhile
endfunction

function! PositionBlank()
    let l = Search('^\s*$', -1, line("."), 1)
    let x = line(".") - l - 1
    call Norm("zt")
    if x > 0
        call Norm(x . "\<c-y>")
    endif
endfunction

function! Unchomp(x)
    return substitute(a:x, "\n*$", "\n", "")
endfunction

function! Chomp(x)
    return substitute(a:x, "\n$", '', '')
endfunction

function! Chomp2(x)
    return substitute(Chomp(a:x), "^\n", '', '')
endfunction

function! Norm(x)
    exec "keepjumps normal! " . a:x
endfunction

" Use this version to allow mappings and jumps
function! Norm2(x)
    exec "normal " . a:x
endfunction
function! Normal(x)
    exec "normal! " . a:x
endfunction

" Put each arg as a line above current.  Use normal mode to get auto indent.
function! PutAbove(...)
    let i = 0
    while i < a:0
        let i = i + 1
        exec 'let arg = a:' . i
        call Norm("O" . arg . "\<esc>\<cr>")
    endwhile
endfunction

" Put each arg as a line below current.  Use normal mode to get auto indent.
function! PutBelow(...)
    let i = a:0
    while i > 0
        exec 'let arg = a:' . i
        let i = i - 1
        call Norm("o" . arg . "\<esc>-")
    endwhile
endfunction

" Get the value of a var; return 2nd ard or "" if not defined.
function! EvalVar(var, ...)
    if exists(a:var)
        exec "return " . a:var
    elseif a:0 > 0
        return a:1
    else
        return ""
    endif
endfunction

" Taking into account wrapping, how many lines will x take?
" ??? Currently we assume it is a single line (no \n)
function! VirtLines(x)
    return (strlen(a:x) + &columns - 1) / &columns
endfunction

function! VirtLines2(x)
    let x = a:x
    let l = 0
    while 1
        let i = matchend(x, "\n")
        if i == -1  " no more lines
            return l + (strlen(x) + &columns - 1) / &columns
        endif
        let l = l + (i - 1 + &columns - 1) / &columns
        let x = strpart(x, i)
    endwhile
endfunction

" how many lines in x
function! Lines(x)
    let x = a:x
    let l = 0
    while 1
        let i = matchend(x, "\n")
        if i == -1  " no more lines
            return l + (strlen(x) + &columns - 1) / &columns
        endif
        let l = l + 1
        let x = strpart(x, i)
    endwhile
endfunction

function! HasUpperCase(x)
    return match(a:x, '\u') >= 0
endfunction

" Write out the file, push current loc, and return 1.
" e.g:  if !Update() | return | endif
" Update(1) skips the push.
function! Update(...)
    let nopush = a:0 > 0 && a:1
    let b:auto_update = 1 " updating turns autoupdate back on
    let result = 1
    if &modified
        if @% == ''
            call Error("can't update -- no file name")
            return 0
        endif
        if &readonly
            call Error("can't update -- readonly is set")
            return 0
        endif
        if &write == 0
            call Error("can't update -- nowrite is set")
            return 0
        endif
        let v:errmsg = ""
        "TEMP try not silent update
        "silent update
        update
        "TEMP: try including clist or cc
        "cc
        if v:errmsg != ""
            call Error(v:errmsg)
            let result = 0
        endif
        "call AutoSave()
    endif
    if !nopush
        call PushLoc()
    endif
    return 1
endfunction

function! Mkdir(dir)
    if isdirectory(a:dir)
        return
    endif
    if filereadable(a:dir)
        return Error("can't mkdir; file already exists: " . a:dir)
    endif
    call mkdir(a:dir, 'p')
"    call Mkdir(fnamemodify(a:dir, ":h"))  " make parent dir
"    call System('mkdir "' . a:dir . '"')
endfunction

function! AutoSave()
    call SetAutoSaveDir()
    call Mkdir(b:autosave_dir)
    let time = localtime() / 60
    let save = b:autosave_dir . '/' . time
    " remove ones created in last 5 min
    let old = time - 5
    while old <= time
        call delete(b:autosave_dir . '/' . old)
        let old = old + 1
    endwhile
    " avoid changing #
    call SetCmd('silent write ' . save, 'cpo', '-A')
    let b:last_autosave = save
endfunction

" Set b:autosave_dir for this buffer if it is not already set
function! SetAutoSaveDir()
    if !exists('b:autosave_dir')
        let x = expand('%:p')
        let autosave = GetRoot() . '/Save/Auto/'
        "let autosave = substitute(GetRoot() . '/Save/Auto/', '/', '\\', 'g')
        let b:autosave_dir = autosave
            \ . substitute(expand('%:p'), '[:~]', '', 'g')
    endif
endfunction

nmap ,as :call EditAutoSaveDir()<cr>
function! EditAutoSaveDir()
    call PushLoc()
    call SetAutoSaveDir()
    let w:longlist = 1
    exec "edit " . b:autosave_dir
endfunction

" Get the id under the cursor, or prompt for one.
" When ask is true, always ask.
" 2nd arg is optional prompt string
" 3rd arg is 1 if reponse is not required to be id.
function! GetId(ask, ...)
    return a:0 > 0 ? GetID(a:ask, a:1) : GetID(a:ask)
endfunction
function! GetID(ask, ...)
    if a:0 > 0
        let prompt = a:1
    else
        let prompt = "Enter id"
    endif
    let id_not_required = a:0 > 1 && a:2
    if a:ask || getline('.') =~ '^\s*$'
        let id = ''
    else
        let id = GetWord()
    endif
    if id =~ '^\k\+$'
        " put in history as if typed in
        call histadd('input', id)
    else
        " put search pattern in history, if it matches a word
        let default = substitute(@/, '^\\<\(\k\+\)\\>$', '\1', '')
        if default != @/
            call histadd('input', default)
        endif
        let id = input(prompt . ': ')
        echo "\r"
        if id == ""
            return Warning("Canceled")
        endif
        if !id_not_required && id !~ '^\k\+$'
            return Warning("Not an id: " . id)
        endif
    endif
    return id
endfunction

function! Edit(f)
    exec "edit " . escape(a:f, '%#')
endfunction

" Edit a file, preserving the filetype (either current or specified one).
function! EditFT(f, ...)
    if a:0 == 0
        let ft = &ft
    else
        let ft = a:1
    endif
    call Edit(a:f)
    let b:filetype = ft
    let &ft = ft
endfunction

function! Cond(cond, x, y)
    if a:cond
        return a:x
    else
        return a:y
    endif
endfunction

function! Max(x, y)
    return Cond(a:x > a:y, a:x, a:y)
endfunction

function! Min(x, y)
    return Cond(a:x < a:y, a:x, a:y)
endfunction

" multiple calls to substitute
function! Sub(gflag, x, ...)
    let x = a:x
    if a:gflag != "" && a:gflag != "g"
        call Warning("bad value for gflag in Sub: " . a:gflag)
        return ""
    endif
    let n = 1
    while n < a:0
        exec "let y = a:" . n
        exec "let z = a:" . (n+1)
        let n = n + 2
        let x = substitute(x, y, z, a:gflag)
    endwhile
    if n == a:0
        call Warning("Sub must have even number of args")
    endif
    return x
endfunction

" Match string against pattern.  If it matches, return 1 and set
" g:match1, g:match2, ... to strings in \(...\).  The next is unset.
" ??? add this?
" If third param, use that for prefix instead of "match".
function! Match(str, pat)
    unlet! g:match1
    if a:pat !~ '\\('
        return match(a:str, a:pat) != -1
    endif
    let pos = 0
    let nparens = 0
    let pat = a:pat
    if pat !~ '^\^'
        let pat = '^.\{-}' . pat
    endif
    if pat !~ '\$'
        let pat = pat . '.*$'
    endif
    while 1
        " is there another set of parens?
        let nparens = nparens + 1
        let pos = match(a:pat, '\\(', pos) + 1
        if pos == 0
            " no more parens to match
            if nparens == 1
                call Error("internal error in Match -- no parens found")
            endif
            exec "unlet! g:match" . nparens
            return 1  " no more parens
        endif

        " match this set of parens
        let matchstr = substitute(a:str, pat, "\\" . nparens, '')
        if matchstr == a:str
            if nparens > 1
                call Error("internal error in Match -- failed to match paren "
                    \. nparens . '; str=<' . a:str . '>, pat=<' . pat . '>')
            endif
            return 0  " didn't match at all
        endif

        exec 'let g:match' . nparens . '=matchstr'
    endwhile
endfunction

" match Nth set of parens
function! MatchNth(str, pat, n)
    let pat = a:pat
    if pat !~ '^\^'
        let pat = '^.\{-}' . pat
    endif
    if pat !~ '\$'
        let pat = pat . '.*$'
    endif
    let result = substitute(a:str, pat, "\\" . a:n, '')
    return result == a:str ? "" : result
endfunction

" match one set of parens
function! Match1(str, pat)
    return MatchNth(a:str, a:pat, 1)
endfunction

" match one set of parens
function! Match1st(str, pat)
    return MatchNth(a:str, a:pat, 1)
endfunction

" match one set of parens
function! Match2nd(str, pat)
    return MatchNth(a:str, a:pat, 2)
endfunction

" Optional 2nd arg is suffix
function! GetTemp(prefix, ...)
    let suffix = a:0 > 0 ? a:1 : 'tmp'
    "let prefix = WinSlash(g:temp . '/' . a:prefix)
    let prefix = g:temp . '/' . a:prefix
    let n = 0
    while 1
        let n = n + 1
        let file = prefix . '.' . n . '.' . suffix
        if !filereadable(file)
            return file
        endif
    endwhile
endfunction

"function! GUIMsg(msg1, msg2)
"    call GUImsg(a:msg1, msg2)
"endfunction

function! GUIMsg(msg, ...)
    let msg = a:msg
    if a:0 > 0
        let msg = msg . ' = ' . a:1
    endif
    call confirm(msg, "&OK")
endfunction
function! GUImsg(msg, ...)
    let msg = a:msg
    if a:0 > 0
        let msg = msg . ' = ' . a:1
    endif
    call confirm(msg, "&OK")
endfunction

function! Internal(func, msg)
    call Error('Internal error in ' . func . ': ' . msg)
endfunction

function! Error(msg)
    echohl ErrorMsg
    echo Chomp(a:msg)
    echohl None
    return ''
endfunction

function! Warning(msg)
    echohl WarningMsg
    echo Chomp(a:msg)
    echohl None
    return ''
endfunction

function! Note(msg)
    echo Chomp(a:msg)
    return ''
endfunction

function! Bold(msg)
    echohl BoldMsg
    echo Chomp(a:msg)
    echohl None
    return ''
endfunction

" Push a value on stack named by stack
function! Push(value, sep, stack)
    if !exists(a:stack)
        exec "let " . a:stack . " = \"\""
    endif
    exec "let " . a:stack . " = a:value . a:sep . " . a:stack
endfunction

" Pop value off stack named by stack
function! Pop(sep, stack)
    let result = Peek(a:sep, a:stack)
    if result == ""
        return ""
    endif
    exec "let stack = " . a:stack
    let stack = strpart(stack, strlen(result)+strlen(a:sep), 999999)
    exec "let " . a:stack . " = stack"
    return result
endfunction

" Pop value off the bottom of the named stack.
function! PopEnd(sep, stack)
    let sep = a:sep
    if !exists(a:stack)
        return ""
    endif
    exec "let stack = " . a:stack
    let pat = '^\(.*' . sep . '\)\(.*\)' . sep . '$'
    let result = substitute(stack, pat, '\2', '')
    let stack = substitute(stack, pat, '\1', '')
    exec "let " . a:stack . " = stack"
    return result
endfunction

" Look at top value of named stack.
function! Peek(sep, stack)
    if !exists(a:stack)
        return ""
    endif
    exec "let stack = " . a:stack
    let x = match(stack, a:sep)  "??? watch out for magic -- escape()?
    if x == -1
        return ""
    endif
    return strpart(stack, 0, x)
endfunction

function! Goto(path, line)
    if a:path != expand("%:p")
        call Edit(a:path)
    endif
    exec a:line
endfunction

function! Goto2(path, line, column)
    if a:path != expand("%:p")
        call Edit(a:path)
    endif
    call cursor(a:line, a:column)
endfunction

"???
"" NOTE use GetPos to restore position
"function! GetLineCol()
"    return line(".") . " " . col(".")
"endfunction
"function! GotoLineCol(loc)
"    let loc = a:loc
"    if loc !~ '^\d\+ \d\+$'
"        return Error('bad arg to GotoLineCol: "' . loc . '"')
"    endif
"    let line = substitute(loc, ' .*', '', '')
"    let col = substitute(loc, '.* ', '', '') - 1
"    exec line
"    normal! 0
"    if col != 0
"        call Norm(col . "l")
"    endif
"endfunction

"Two different implementations of GetPos -- both have a problem in
"insert mode.

"TODO: consider new functions getpos() and setpos()
if 1
" Save the position in file and on screen.  Restore with Norm()
" Be careful about '~' lines at end of file
" GetPos(1) just gets line & col, not position on screen.
function! GetPos(...)
    let linecol_only = a:0 > 0 && a:1
    let l1 = line('.')
    if linecol_only
        let result = l1 . 'G' . virtcol('.') . '|'
    else
        let result = l1 . 'Gzt' . virtcol('.') . '|'
        call Norm("H")
        let d = l1 - line('.')
        if d > 0
            let result = result . d . "\<c-y>"
        endif
        call Norm(result)  " leave cursor where it was
    endif
    return result
endfunction

" Get the line number from a pos.
function! PosLine(pos)
    return matchstr(a:pos, '^\d\+')
endfunction

" Get the line number from a pos.
function! PosCol(pos)
    return Match1st(a:pos, '\(\d\+\)|')
endfunction

else

" Save the position in file and on screen.  Restore with Norm()
" Be careful about '~' lines at end of file
" GetPos(1) just gets line & col, not position on screen.
"BUG doesn't work right in insert mode!
function! GetPos(...)
    let linecol_only = a:0 > 0 && a:1
    let l = line('.')
    let c = virtcol('.')
    if linecol_only
        let result = l . 'G' . c . '|'
    else
        call Norm('H')
        let l0 = line('.')
        let result = l0 . 'Gzt'
        if l0 != l
            let result = result . (l - l0) . 'j'
        endif
        let result = result . c . '|'
        call Norm(result)  " leave cursor where it was
    endif
    return result
endfunction

" Get the line number from a pos.
function! PosLine(pos)
    let pos = a:pos
    let l = matchstr(pos, '^\d\+')
    if l == ''
        return Internal('PosLine', 'bad pos: ' . pos)
    endif
    let x = Match1st(pos, 'zt\(\d\+\)j')
    if x != ''
        let l = l + x
    endif
    return l
endfunction

" Get the line number from a pos.
function! PosCol(pos)
    return Match1st(a:pos, '\(\d\+\)|')
endfunction

endif


" This is a re-implementation of location stack using "ma" and "'a"
let g:loc_stack2 = []
nnoremap <silent> ma ma:call PushLoc2()<cr>
nnoremap <silent> 'a :call PopLoc2()<cr>
nnoremap <silent> gs :call ShowLoc2()<cr>

" Save file, line, column, lines down from top
function! PushLoc2()
    let line = line('.')
    let column = col('.')
    keepjumps normal! H
    let down = line - line('.')  " lines down from top
    call cursor(line, column)
    let g:loc_stack2 += [[expand('%:p'), line, column, down]]
endfunction
function! PeekLoc2()
    return len(g:loc_stack2) == 0 ? [] : g:loc_stack2[-1]
endfunction
" TODO: keep popped locs on stack until pushing a new one so that
" we can go forward too (e.g. 'A)
function! PopLoc2()
    if len(g:loc_stack2) == 0
        return Warning('Location stack is empty')
    else
        let [file, line, column, down] = g:loc_stack2[-1]
        call remove(g:loc_stack2, -1)
        call Goto2(file, line, column)
        call Norm('zt')
        if down != 0
            call Norm(down . "\<c-y>")
        endif
    endif
endfunction
function! ShowLoc2()
    call Bold(printf(
        \ '%5s %6s  %s', 'line', 'column', 'file  -  location stack'))
    for loc in g:loc_stack2
        let [file, line, column, down] = loc
        echo printf('%5d %6d  %s', line, column, file)
    endfor
endfunction
" Return the number of lines down from the top of the screen the cursor is at
function! ScreenPos()
endfunction

"TEMP setting this causes locs to include column & place on screen
"make this default?  Get rid of various Goto functions?
let g:new_loc = 1

function! GetLoc()
    if g:new_loc
        return expand("%:p") . "%" . GetPos()
    else
        return expand("%:p") . "%" . line(".")
    endif
endfunction

function! GotoLoc(loc)
    let f = substitute(a:loc, '%.*', '', '')
    let l = substitute(a:loc, '.*%', '', '')
    if g:new_loc
        if f != expand("%:p")
            call Edit(f)
        endif
        call Norm(l)  " really a pos
    else
        call Goto(f, l)
    endif
endfunction

function! PushLoc()
    let loc = GetLoc()
    if loc != PeekLoc()  " don't push duplicates
        call Push(loc, "#", "g:loc_stack")
        " limit the size of the stack:
        while strlen(g:loc_stack) > 10000
            call PopEnd("#", "g:loc_stack")
        endwhile
    endif
endfunction
function! PeekLoc()
    return Peek("#", "g:loc_stack")
endfunction
function! PopLoc()
    let loc = Pop("#", "g:loc_stack")
    if loc == ""
        let g:no_more_items = 1
        return Warning("location stack is empty")
    endif
    call GotoLoc(loc)
endfunction
function! ShowLoc()
    if !exists("g:loc_stack") || g:loc_stack == ""
        return Warning("location stack is empty")
    endif
    call Bold("Location stack:")
    let g:temp_loc_stack = g:loc_stack
    let out = ""
    let n = 1
    while g:temp_loc_stack != ""
        let loc = Pop("#", "g:temp_loc_stack")
        if loc == ""
            return
        endif
        let file = substitute(loc, '%.*', '', '')
        let line = substitute(loc, '.*%', '', '')
        if g:new_loc
"            let line = matchstr(line, '^\d\+')
            let line = PosLine(line)
        endif
        let out = NumFormat(n, 2) . ": " . NumFormat(line, 5) . "  "
            \ . file . "\n" . out
        let n = n + 1
    endwhile
    echo Chomp(out)
    unlet g:temp_loc_stack
endfunction

" Pad number with spaces on left up to width.
function! NumFormat(x, width)
    let x = a:x
    while strlen(x) < a:width
        let x = " " . x
    endwhile
    return x
endfunction

" Like Java MessageFormat - replace {0}, {1}, etc with arguments
function! Format(str, ...)
    let i = 0
    let str = a:str
    while i < a:0
        let i = i + 1
        exec 'let arg = a:' . i
        let str = substitute(str, '{'.(i-1).'}', arg, 'g')
    endwhile
    return str
endfunction

" How many active buffers are there?
function! BufCount()
    let n = 0
    let i = bufnr("$")
    while i > 0
        if bufexists(i)
            let n = n + 1
        endif
        let i = i - 1
    endwhile
    return n
endfunction

" Goto buffer n
function! BufGoto(n)
    exec "buffer " . a:n
endfunction

" Goto window n.  0 => last on screen
function! WinGoto(n)
    let n = a:n
    if n == 0
        call Norm("\<c-w>b")
    elseif n != winnr()
        call Norm(n . "\<c-w>w")
    endif
endfunction

" Read file and return its contents
function! Read(file)
    1 new
    exec "silent read " . a:file
    set nomod
    silent %yank
    bdelete
    return @@
endfunction

" write contents to named file.  If arg3 is set, append instead.
function! Write(contents, file, ...)
    return WriteList([a:contents], a:file, a:0 > 0 && a:1)
endfunction

" write list of lines to named file.  If arg3 is set, append instead.
function! WriteList(list, file, ...)
    let list = a:list
    if a:0 != 0 && a:1
        let list = readfile(a:file) + list
    endif
    call writefile(list, a:file)
endfunction

" write contents of x to named file.  If arg3 is set, append instead.
function! Write_old(x, file, ...)
    let cmd = "silent 1 write! "
    if a:0 != 0 && a:1
        let cmd = cmd . ">> "
    endif
    1 new
    call append(0, a:x)
    set nomod
    call SetCmd(cmd . a:file, "write", 1)
    bdelete
endfunction

" append contents of x to named file
function! Append(x, file)
    call Write(a:x, a:file, 1)
endfunction

" Return old setting of named option.  If value is specified, set it to that.
" value can start with + or - to modify instead of set.
" Restore with RestoreSet.  Old settings can be catenated.
function! SaveSet(name, ...)
    exec "let old = &" . a:name
    let save = 'let &' . a:name . '="' . escape(old, '\"') . '"|'
    if a:0 == 1
        let mod = ""
        let val = substitute(a:1, '^\([-+]\)\(.\+\)$', '\2', '')
        if val != a:1
            let mod = substitute(a:1, '^\([-+]\)\(.\+\)$', '\1', '')
            exec "set " . a:name . mod . "=" . escape(val, '\ ')
        else
            exec 'let &' . a:name . '="' . escape(a:1, '\"') . '"'
        endif
    endif
    return save
endfunction
function! RestoreSet(save)
    exec a:save
endfunction
" Execute cmd with name set to value (as above), then restore.
function! SetCmd(cmd, name, value)
    let save = SaveSet(a:name, a:value)
    exec a:cmd
    call RestoreSet(save)
endfunction
" Execute normal cmd with name set to value (as above), then restore.
function! SetNorm(cmd, name, value)
    let save = SaveSet(a:name, a:value)
    call Norm(a:cmd)
    call RestoreSet(save)
endfunction

" Perform a mapping, return the old rhs.  Restore with RestoreSet or exec.
" NOTE: does noremap to set and restore.
function! SaveMap(lhs, rhs, ...)
    if a:0 == 1
        let mode = a:1
    else
        let mode = "n"
    endif
    let old = maparg(a:lhs, mode)
    if old == ""
        let save = mode . "unmap " . a:lhs . "|"
    else
        let save = mode . "noremap " . a:lhs . " " . old . "|"
    endif
    if a:rhs == ""
        exec mode . "unmap " . a:lhs
    else
        exec mode . "noremap " . a:lhs . " " . a:rhs
    endif
    return save
endfunction

" Shrink the window if the text is smaller
function! ShrinkToFit()
    let lines = line("$")
    if lines < &lines
        " NOTE: only make narrower if have already made shorter
        let virt_lines = 0  " number of screen lines needed
        let longest = 0  " length of longest line
        let line = 1
        while line <= lines
            exec line
            let len = virtcol('$')
            if len > longest
                let longest = len
            endif
            let virt_lines = virt_lines + VirtLines(getline(line))
            let line = line + 1
        endwhile
        if longest <= 80
            call SetWidth(longest - 1)
        endif
        let &lines = virt_lines + 2
        exec 1
    endif
endfunction

Help ',sl - show long lines (more than 100 chars)'
nmap ,sl :let @/ = '\(.\{100\}\)\@<=.\+'<cr>

Help ',md - make the window the default size (100x40)'
nmap ,md :set lines=40<cr>:call SetWidth(100)<cr>:set columns?<cr>
Help ',mt - make the window as tall as the number of lines (some may wrap)'
nmap ,mt :call MakeTallEnough()<cr>:set columns?<cr>
Help ',MW - make window wide enough upon entering each buffer'
nmap ,MW :let g:make_wide = 1<cr>:call MakeWideEnough()<cr>:set columns?<cr>
Help ',mw - make the window as wide as the longest line'
nmap ,mw :call MakeWideEnough()<cr>:set columns?<cr>
Help ',mc - make the window as wide as the longest line, ignoring comments'
nmap ,mc :call MakeWideEnough(1)<cr>:set columns?<cr>
function! MakeTallEnough()
    let lines = line("$")
    if &wrap && lines < 100
        let l = 1
        let n = 0
        while l <= lines
            let n = n + Max(1, VirtLines(getline(l)))
            let l = l + 1
        endwhile
        let lines = n
    endif
    let &lines = lines + 1
    call Norm(lines . "\<c-y>")  " get whole file on screen
endfunction

" Find longest line, make the screen that wide.
function! MakeWideEnough(...)
    let ignore_comments = a:0 > 0 && a:1
    let longest = FindLongestLine(ignore_comments)
    let max = &columns * 5 / 4  " don't expand more than 25% at a time
    let width = Max(80, Min(max, longest))
    " This is kind of annoying - try setting it globally:
    "call SetWidth(width)
    let &columns = width
endfunction

" Find longest line.
" Only search around current line, in case file is big.
" Option arg: ignore_comments => skip lines starting with: * # //
function! FindLongestLine(...)
    let ignore_comments = a:0 > 0 && a:1
    " determine longest line -- use virtcol to account for tabs
    let save = SaveSet('linebreak', 0)  " linebreak screws up virtcol
    let pos = GetPos()
    let longest = 0
    let line = Max(1, line('.') - 100)
    let last = Min(line('$'), line('.') + 100)
    while line <= last
        exec line
        let line = line + 1
        if ignore_comments
            let text = getline('.')
            if text =~ '^\s*\(\*\|#|//\)\s'
                continue
            endif
        endif
        let len = virtcol('$') - 1
        if len > longest
            let longest = len
        endif
    endwhile
    call Norm(pos)
    exec save
    return longest
endfunction

" Set the width of this buffer; restored at end
function! SetWidth(width)
    let b:columns = a:width
    let restore = SaveSet('columns', b:columns)
        \ . SaveSet('textwidth', b:columns - 1)
    call AddBufRestore(restore)
endfunction

" StartPage is called from page.bat
" ,pa reruns the same command
" ,pc changes the command
Help ',pa - rerun page command'
Help ',pc - change the page command'
Help ',pf - change change and remember the page file type'
nmap <silent> ,pa :call Page()<cr>
nmap <silent> ,pc :call ChangePage()<cr>
nmap <silent> ,pf :call PageFileType()<cr>
function! Page()
    if !exists('b:page_cmd')
        return Error('Not in a page cmd')
    endif
    " if we're re-doing a page, undo the mappings, etc.
    call BufLeave()
    " special title for page; change when switching buffers
"    let b:titlestring = '| '
"        \ . substitute(b:page_cmd,'%','%%','g')
"        \ . ' - %<' . TitleDir(b:page_dir)
    " omit dir?
    let b:titlestring = '| ' . substitute(b:page_cmd,'%','%%','g')
    if exists('b:page_ft')
        let b:filetype = b:page_ft
    endif
    set noro
    % delete
    " a page cmd in a different tab may have changed dir
    exec 'chdir ' . b:page_dir
    " TODO still a problem with < in cmd
    exec 'silent read !' . escape(b:page_cmd, '%#<>') . ' 2>&1'
    1 delete
    silent update
    silent edit %  " re-edit to get modelines
    set readonly
    echo b:page_cmd
    let g:page_prefix = substitute(b:page_cmd, '\s.*', '', '') . '> '
endfunction

function! PageFileType(...)
    if a:0 > 0
        let ft = a:1
    else
        let ft = GetID(1, 'Enter filetype')
    endif
    let &filetype = ft
    let b:filetype = ft
    let b:page_ft = ft
    exec "doautocmd BufEnter " . @%
endfunction

" Start a page command, given dir to run in and temp file.
" When unique is set close other tabs with the same page cmd.
function! StartPage(cmd, dir, tmp, unique)
    "call GUImsg('StartPage')
    exec "silent edit " . a:tmp
"    let b:page_cmd = substitute(a:cmd, '\\042', '"', 'g')
    let b:page_cmd = Sub('g', a:cmd, '\\042', '"', '\\047', "'")
    let b:page_dir = a:dir
    let b:page_tmp = a:tmp
    let b:directory = a:dir
    nmap <buffer> eo ,pa
    nmap <buffer> ,eo ,pc
    call Page()
    call DeleteOnExit()
    " see if we can set the filetype
    "NOTE: iskeyword can affect \> so use \w\@! instead
    if b:page_cmd =~ '^\(diff\|git diff\|show_diff\|gdiff\)\w\@!'
        call PageFileType('diff')
    elseif b:page_cmd =~ '^normxml'
        call PageFileType('xml')
    elseif b:page_cmd =~ '^ls\=\>'
        call PageFileType('ls')
    else
        runtime scripts.vim
        if &ft == ''
            call PageFileType('txt')
        else
            call PageFileType(&ft)
        endif
    endif
    " b1 goes back to command in this tab
    " TODO: can we generalize to anything with tabs?
    let t:page_buf = bufnr('%')
    nmap b1 :exec 'buffer ' . t:page_buf<cr>
    if a:unique
        call CloseMatchingPageTabs()
    endif
    "call GUImsg('end StartPage')
endfunction

function! ChangePage()
    " add old cmd to history, input new one
    call histadd("input", b:page_cmd)
    let cmd = input("New command: ")
    echo "\r"
    if cmd == ""
        return Warning("Canceled")
    endif
    " Allow '@*' to represent clipboard contents
    let cmd = substitute(cmd, '@\*', @*, 'g')
    let b:page_cmd = cmd
    call Page()
endfunction

nmap ,ft :call SetFileType()<cr>
function! SetFileType(...)
    if a:0 > 0
        let ft = a:1
    else
        let ft = GetID(1, 'Enter filetype')
    endif
    if ft == ''
        return
    endif
    let &filetype = ft
    let b:filetype = ft
    if exists('b:page_cmd')
        let b:page_ft = ft
    endif
endfunction

" Find tabs that have the same command as this one and close them
" Do this after creating new one
function! CloseMatchingPageTabs()
    let cmd = substitute(b:page_cmd, ' .*', ' ', '')  " just first word
    let b:keep_this_tab = 1  " mark this as the one to keep
    tabdo call CloseMatchingPageTab(cmd)
    unlet b:keep_this_tab
endfunction

function! CloseMatchingPageTab(cmd)
    "call GUIMsg('tab='.tabpagenr().' cmd='.b:page_cmd)
    if !exists('b:keep_this_tab') && exists('b:page_cmd') && match(b:page_cmd, a:cmd) == 0
        tabclose
    endif
endfunction


" Delete the current file or named file upon exitting Vim
function! DeleteOnExit(...)
    let f = a:0 > 0 ? a:1 : expand("%:p")
    let g:file_to_be_deleted = f
    "*** doesn't work!
"    call GUImsg(g:file_to_be_deleted)
    autocmd VimLeave * call delete(g:file_to_be_deleted)
endfunction

" Goto file and line number under cursor
" ??? this looks for " [<line>] <file>" -- could allow (e.g. "<file>:<line>")
nmap <silent> gl gU:call GotoLine(getline("."))<cr>
nmap <silent> ,gl :call GotoLine(getline("."))<cr>
"function! GotoLine(line)
"    if !Update() | return | endif
"    call CdToDir()
"    if expand("%:e") == "jspec"
"        return GotoJSpecLine()
"    endif
"    let line = a:line
"    if line =~ '^\([<>] \|---$\|\d\+\(,\d\+\)\=[acd]\d\+\(,\d\+\)\=$\)'
"        return GotoDiffLine()
"    endif
"    " try: <line> <file>
"    let l = substitute(line, '^\s*\(\d\+\)\s\+\(\(\f\| \)\+\).*', '\1', '')
"    if l != line
"        let f = substitute(line, '^\s*\(\d\+\)\s\+\(\(\f\| \)\+\).*', '\2', '')
"    else
"        " try: <file>(<line>)
"        let loc = substitute(line,
"            \ '^\s*\(\(\f\| \)\+\)(\(\d\+\)[,)].*', '\1%\3', '')
"        if loc != line
"            call GotoLoc(loc)
"            return
"        endif
"        " try: <file>:<line>:
"        let loc = substitute(line,
"            \ '^\s*\(\(\f\| \)\+\):\(\d\+\):.*', '\1%\3', '')
"        if loc != line
"            call GotoLoc(loc)
"            return
"        endif
"        "??? can we use GoFile here?
"        " try just: <file>
"        let line = substitute(line, '^=== ', '', '')
"        let f = matchstr(line, '^\s*\(\f\| \)\+')
"        if f == ""
"            return Warning("no file name found in line")
"        endif
"        let f = substitute(f, '^\s*', '', '')
"        let l = 1
"    endif
"    call Goto(f, l)
"endfunction

"function! GotoLine(line)
"    if !Update() | return | endif
"    call CdToDir()
"    if expand("%:e") == "jspec"
"        return GotoJSpecLine()
"    endif
"    let line = a:line
"    if line =~ '^\([<>] \|---$\|\d\+\(,\d\+\)\=[acd]\d\+\(,\d\+\)\=$\)'
"        return GotoDiffLine()
"    endif
"    let save = SaveSet('isfname', '+32')  " allow space in filename
"    " try: <line> <file>
"    let pat = '^\s*\(\d\+\)\s\+\(\f\+\)'
"    let l = Match1st(line, pat)
"    if l != ''
"        let f = Match2nd(line, pat)
"    else
"        " try: <file>(<line>)
"        let pat = '^\s*\(\f\+\)(\(\d\+\)[,)]'
"        let f = Match1st(line, pat)
"        if f != ''
"            let l = Match2nd(line, pat)
"        else
"            let pat = '^\s*\(\f\+\):\(\d\+\):'
"            let f = Match1st(line, pat)
"            if f != ''
"                let l = Match2nd(line, pat)
"            else
"                " try just: <file>
"                let line = substitute(line, '^=== ', '', '')
"                let pat = '^\s*\(\f\+\)'
"                let f = Match1st(line, pat)
"                if f != ''
"                    let l = 1
"                endif
"            endif
"        endif
"    endif
"    exec save
"    if f == ''
"        return Warning('no file name found in line')
"    endif
"    call Goto(f, l)
"endfunction

function! GotoLine(line)
    if !Update() | return | endif
    call CdToDir()
    if expand("%:e") == "jspec"
        return GotoJSpecLine()
    endif
    let line = a:line
"    if line =~ '^\([<>] \|---$\|\d\+\(,\d\+\)\=[acd]\d\+\(,\d\+\)\=$\)'
    if &ft == 'diff'
        return GotoDiffLine()
    endif

    "TEST: strip diagnostic messages
    let line = substitute(line, '^.*\(warning\|error\) *: *', '', '')
    let save = SaveSet('isfname', '+32')  " allow space in filename
    if   TryGotoLine(line, '\(\d\+\)\s\+\(\f\+\)',  2, 1)
    \ || TryGotoLine(line, '\(\f\+\)(\(\d\+\)[,)]', 1, 2)
    \ || TryGotoLine(line, '\(\f\+\):\(\d\+\)\($\|[: \t]\)',    1, 2)
    \ || TryGotoLine(line, '\(\f\+\)',              1, 2)
    \ || TryGotoLine(line, '.*Starting at line \(\d\+\) of \(\f\+\)', 2, 1)
        " worked
    else
        call Warning('no file name found in line')
    endif
    exec save
endfunction

" See if line matches pat.  fi and li are index of filename and line in pat.
function! TryGotoLine(line, pat, fi, li)
    let pat = '^\s*' . a:pat
    let f = MatchNth(a:line, pat, a:fi)
    if f == '' || f =~ '..:'  " don't allow ':' after 2nd char
        return 0
    else
        let f = substitute(f, '\s\+$', '', '')
        let l = MatchNth(a:line, pat, a:li)
        if l == ''
            let l = 1
        endif
        call Goto(f, l)
        return 1
    endif
endfunction

Help 'sd - search for next diff'
" After sd, n implicitly does zt until the next search
nnoremap sd :call SearchDiff()<cr>nzt
function! SearchDiff()
    call PushSearchMapping('n', 'nzt')
    "nnoremap n nzt
    let @/ = '^\(cvs \w\+:\|[^-+ <>].*\<error:\|\(diff\|===\) .*\)'
endfunction

" Call this when you re-map "n" and want to unmap at next search
function! PushSearchMapping(lhs, rhs)
    if exists('g:search_map_restore')
        " already have mappings saved; just keep them
        call SaveMap(a:lhs, a:rhs)
    else
        " TODO: need not to have noremap for v!
        let g:search_map_restore =
            \   SaveMap(a:lhs, a:rhs)
            \ . SaveMap('/', ':<c-u>call PopSearchMap()<cr>gv/', 'v')
            \ . SaveMap('/', ':call PopSearchMap()<cr>/')
            \ . SaveMap('*', ':call PopSearchMap()<cr>*')
            \ . SaveMap('#', ':call PopSearchMap()<cr>#')
    endif
    "nnoremap / :call UnmapSearch()<cr>/
    "nnoremap * :call UnmapSearch()<cr>*
    "nnoremap # :call UnmapSearch()<cr>#
endfunction
function! PopSearchMap()
    exec g:search_map_restore
    unlet g:search_map_restore
endfunction
"function! UnmapSearch()
"    silent! nunmap n
"    silent! nunmap N
"    silent! nunmap /
"    silent! nunmap *
"    silent! nunmap #
"endfunction

" Go to next diff in given direction. (+1 => forward, -1 => back).
function! NextDiff(dir)
    let flags = a:dir == 1 ? 'W' : 'Wb'
    let pat = '^\(@@ .* @@\|\d\+\(,\d\+\)\=[acd]\d\+\(,\d\+\)\=\)$'
    let l = search(pat, flags)
    if l == 0
        return Warning("no more diffs")
    endif
    " look for next one to ensure this whole diff is on screen
    let l2 = search(pat, flags) - 1
    if l2 < 0
        let l2 = line('$') - 1
    endif
    let last_line_of_screen = LastLineOfScreen()
    let want = l2 - l
    if want > &lines - 1
        let want = &lines - 1
    endif
    let have = last_line_of_screen - l
    let need = want - have
    if need > 0
        echo "need " . need . " more lines"
        call Norm(need . "\<c-e>")
        return
    endif
    exec l
endfunction

Help ',gp - in diff, apply current diff as patch'
" After sd, n implicitly does zt until the next search
nnoremap ,gp :call ApplyPatch()<cr>
function! ApplyPatch()
    " see GetDiffLine2
    let start = search('^=== ', 'bcnW')
    if start == 0
        return Warning('No "=== " line found before this one')
    endif
    " End is first blank line; some in diff may have only whitespace
    let end = search('^$', 'cnW')
    if end == 0
        return Warning('No blank line found after this one')
    endif
    echo 'Patch is lines ' . start . ' to ' . end
    let patch_file = $TEMP . '\vi.patch'
    let cmd = 'silent ' . start . ',' . end . ' write! ' . patch_file
    echo cmd
    exec cmd
endfunction

function! LastLineOfScreen()
    call Norm('L')
    let l = line('.')
    call Norm('``')
    return l
endfunction

" Number of lines below current on screen
function! ScreenPos()
    return LastLineOfScreen() - line('.')
endfunction
function! RestoreScreenPos(n)
    let l = line('.')
    let last = l + a:n
    exec last
    call Norm('zb')
    exec l
endfunction

Help 'cd - copy the file currently being diffed'
nmap cd :call CopyDiff()<cr>
function! CopyDiff()
    let files = GetDiffFiles()
    let file1 = GetArray(files, 0)
    let file2 = GetArray(files, 1)
    if file2 == ''
        return Warning("can't determine diff files")
    endif
    let cmd = 'copy "' . file1 . '" "' . file2 . '"'
    echo cmd
    let answer = input("Copy? [yn] ")
    echo "\r"
    if answer =~? '^y'
        echo system(cmd)
    else
        call Warning('Canceled')
    endif

"    let answer = Input("Copy? [yn] ", "y")
"    call GUImsg("answer = " . answer)
"    if answer =~? '^y'
"        call GUImsg("do copy")
"        echo "do copy"
"    endif
endfunction

"Help 'gd - goto a line from diff'
"nmap gd :call GotoDiffLine()<cr>

function! GotoDiffLine(...)
    let show = a:0 > 0 && a:1
    if !Update() | return | endif
    let [file, line] = GetDiffLine2()
    if file == ''
        " already reported error
    elseif show
        echo "file=".file
        echo "line=".line
    else
        call Goto(file, line)
    endif
endfunction

" Return [file, line] of location in file represented by current line of diff
" This version only works for unidiff format.
function! GetDiffLine2()
    let l = line('.')
    let line = getline(l)
    let prefix = strpart(line, 0, 1)  " first char
    let adjust = 0
    let pat = '[-+<>@ ]'
    if prefix !~ pat
        if line =~ '^=== '
            " start of diff -- go to first line
            return [ strpart(line, 4), 1]
        else
            return Warning('Not on line starting with ' . pat)
        endif
    endif
    if prefix == ' '
        " no-prefix lines treated like '+'
        let prefix = '+'
    endif
    " count lines that match prefix
    let ll = l
    while 1
        let ll = ll - 1
        let line = getline(ll)
        if line == '\ No newline at end of file'
            continue  " ignore these lines
        endif
        let p = strpart(line, 0, 1)
        if p !~ pat
            return Warning('Unexpected line: ' . line)
        endif
        if p == '@'
            break
        endif
        if p == ' ' || p == prefix
            let adjust = adjust + 1
        endif
    endwhile
    let line = getline(ll)
    let start = substitute(line, '@@.* ' . prefix . '\(\d\+\).*', '\1', '')
    if line == start
        return Warning('Failed to parse @@ line: ' . line)
    endif
    let root = ''  " file is relative to this, if set
    let fpat = '^' . prefix . '\{3}\s\+\([^\t]\+\)\t.*'
    let fl = search(fpat, 'bnW')
    if fl == 0
        " try git diff format: --- a/<file> or +++b/<file>
        let fpat = '^' . prefix . '\{3} [ab]/\(.*\)'
        let fl = search(fpat, 'bnW')
        if fl == 0
            return Warning('Failed to find file line in diff matching ' . fpat)
        endif
        " gdiff.pl puts git repo at the top; files are relative to that
        let rpat = '^Git repo: \(.*\)'
        let rl = search(rpat, 'bnW')
        if rl > 0
            let root = substitute(getline(rl), rpat, '\1\\', '')
        endif
    endif
    let file = substitute(getline(fl), fpat, '\1', '')
    return [root . file, start + adjust]
endfunction

" Return [file, line] corresponding to current place in diff
function! GetDiffLine()
    let l = line('.')
    let prefix = strpart(getline(l), 0, 1)  " first char
    let adjust = 0
    if prefix =~ '[-+<>]'
        " count lines that match prefix
        let ll = l
        while 1
            let ll = ll - 1
            let p = strpart(getline(ll), 0, 1)
            if p !~ '[-+<> ]'
                break
            endif
            if p == ' ' || p == prefix
                let adjust = adjust + 1
            endif
        endwhile
    endif
    " find diff line containing line numbers
    let nl = Search('^\(@@ [-<]\d\+\|\d\+\(,\d\+\)\=\( \++\)\|[acd])\d\+\(,\d\+\)\=$\)', -1)
    if nl != 0
        let fl = Search('^\(<<<\|---\|===\|diff\) ', -1, nl)
    endif
    if nl == 0 || fl == 0
        call PopLoc()
        call Warning("this doesn't appear to be a diff file -- no /^=== /")
        return ['', '']
    endif
    exec fl

    call Norm('W') " skip '===' or '<<<' or 'diff'
    while GetWordBig() =~ '^-'
        call Norm('W') " skip diff options (e.g. -r -w)
    endwhile

    let file = GetFile()
    if file == ''
        call PopLoc()
        call Warning("can't determine original file name")
        return ['', '']
    endif
    " Get second file name on this line, or on next line
    if getline(fl) =~ '^\(<<<\|---\) '
        call Norm("j0W")
    else 
        call Norm("$")
    endif
    let file2 = GetFile()
"    call GUImsg('fl='.fl.' file2='.file2)
    exec l
    if prefix == '>' || prefix == '-'
        if file == file2
            call PopLoc()
            call Warning("can't determine other file")
            return ['', '']
        endif
        let file = file2
        let line = matchstr(getline(nl), '[-acd>]\d\+')
        let line = substitute(line, '[-acd>]', '', '')
    elseif prefix == '+'
        let line = matchstr(getline(nl), '+\d\+')
        let line = substitute(line, '+', '', '')
    else
        let line = matchstr(getline(nl), '\d\+')
    endif
"    call GUImsg('line='.line.' adjust='.adjust)
    let line = line + adjust
    if !FileExists(file) && prefix =~ '[<+]'
        let file = GetWorkspaceFile(file)
    endif
    return [file, line]
endfunction

function! GetWorkspaceFile(file)
    let ws = GetWorkspace()
    if ws == ''
        return a:file
    endif
    let file2 = ws . '/' . a:file
    if FileExists(file2)
        return file2
    endif
    " try path of file from '=== diff' line
    let l3 = search('^=== diff ', 'bnW')
    if l3 != 0
        let file3 = getline(l3)
        let file3 = substitute(file3, '^=== diff ', '', '')
        let file3 = substitute(file3, ' \d[0-9.]*$', '', '')  " remove version
        let file3 = ws . '/' . file3
        if FileExists(file3)
            return file3
        endif
    endif
    return a:file
endfunction
            

"???
"        " try to find file in workspace
"        let fl2 = Search('^=== diff ', -1, fl)
"        if fl2 != 0
"            let dir = substitute(getline(fl2 + 1), '.* ', '', '')
"            " ??? keep dir after this?
""            let file = dir . '/' . file
""            if !FileExists(file)
"            let file2a = dir . '/' . file
"call GUImsg('file2a = ' . file2a)
"            if FileExists(file2a)
"                let file = file2a
"            else
"                let ws = GetWorkspace()
"                if ws != ''
"                    let file3 = ws . '/' . file
"                    if FileExists(file3)
"                        let file = file3
"                    else
"                        let fl4 = search('^#P ', 'bW')
"                        if fl4 > 0
"                            let proj = substitute(getline(fl4), '^#P ', '', '')
"                            let file4 = ws . '/' . proj . '/' . file
"                            if FileExists(file4)
"                                let file = file4
"                            endif
"                        endif
"                    endif
"                endif
"            endif
"        endif
"    endif

function! SetWorkspace(...)
    if a:0 > 0
        let workspace = a:1
    else
        let workspace = @*
        echo 'workspace = ' . @*
    endif
    if !isdirectory(workspace)
        return Warning('Not a directory: ' . workspace)
    endif
    if !isdirectory(workspace . '/.metadata')
        return Warning('Not a workspace (no .metadata): ' . workspace)
    endif
    let g:workspace = workspace
endfunction

" Determine workspace from dirs.pl "ws" abbreviations, or g:workspace
function! GetWorkspace()
    if exists('g:workspace')
        return g:workspace
    endif
    let abbrevs = $USERPROFILE . '/abbrev.txt'
    if !FileExists(abbrevs)
        return ''
    endif
    " For some reason operations below change position
    let pos = GetPos()
    1 new
    set readonly
    exec "silent read " . abbrevs
    let save = @@  " these overwrite @@
    silent v/^ws /d
    " There may be more than one; be sure to get the last one
    silent %s/^ws //
    let @@ = save
    set nomodified
    let workspace = getline('$')
    bdelete
    call Norm(pos)
    return workspace
"    let g:workspace = getline('$')
"    bdelete
"    return g:workspace
endfunction

" Return the two files being diffed as an Array, or empty if can't find.
" GetArray(result, 0) is the first, GetArray(result, 1) is the second.
function! GetDiffFiles()
    let pos = GetPos()  " get back to where we were at end

    let l1 = search('^\(<<<\|===\|diff\) ', "bW")
    if l1 == 0
        return ''
    endif

    call Norm('W') " skip '===' or '<<<' or 'diff'
    while GetWordBig() =~ '^-'
        call Norm('W') " skip diff options (e.g. -r -w)
    endwhile

    let file1 = GetFile()
    if file1 == ''
        call Norm(pos)
        return ''
    endif
    " Get second file name on this line, or on next line
    if getline('.') =~ '^<<< '
        call Norm("jW")
    else 
        call Norm("$")
    endif
    let file2 = GetFile()

    call Norm(pos)
    return MakeArray(WinSlash(file1), WinSlash(file2))
endfunction

" Explore -- edit dirs

"TODO: delete copy below
runtime explorer.vim

if 0
    " use new plugin in C:\Vim\vim\vim60\plugin\explorer.vim
    " don't filter out .0, etc. files: e.g. eclipse feature dirs
    let g:explHideFiles=Sub('g', &suffixes,
        \ '\.\d,', '', '\.', '\\.', ',', '$,', '$', '$')
    let g:explHideFiles='^CVS$,^ID$,^tagspath.vim$,^tags$,' . g:explHideFiles
    let g:explDetailedHelp=0
elseif 0

" Problem: when exploring, call TempWin(), then "e <file>" from there.
" Stuff from explorer doesn't get restored (maps, etc.).

" ex - start explorer on dir of current file
nmap ex gU:call Edit(expand("%:p:h") . "\\_explorer_")<cr>

function! ExploreHelp()
    echo "^R    - refresh"
    echo "<cr>  - edit file or directory"
    echo "<bs>  - goto parent directory"
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

augroup explorer
    autocmd!
    autocmd BufEnter * nested   call Explore()
    autocmd BufEnter _explorer_ call ExploreStart()
augroup end

function! Explore()
    let path = expand("%:p")
    if isdirectory(path)
        call Edit(substitute(path, '\\*$', '\\_explorer_', ''))
    endif
endfunction

function! ExploreStart()
    call ExplorerSyntax()
    let b:buf_restore =
        \   SaveMap("<c-r>", ":call ExploreDisplay(line('.'))<cr>zb")
        \ . SaveMap("<cr>",  ":call ExploreFile(ExploreGetFile())<cr>")
        \ . SaveMap("o",     ":exec 'split ' . ExploreGetFile()<cr>")
        \ . SaveMap("<del>", ":call ExploreDeleteFile()<cr>")
        \ . SaveMap("dd",    ":call ExploreDeleteFile()<cr>")
        \ . SaveMap("r",     ":call ExploreRenameFile()<cr>")
        \ . SaveMap("f",     ":call ExploreFindFile()<cr>")
        \ . SaveMap("<bs>",  ":call ExploreFile('..')<cr>")
        \ . SaveMap("cd",    ":call ExploreChdir()<cr>")
        \ . SaveMap("p",     ":call ExploreChdir()<cr>")
        \ . SaveMap("A",     ":call ExploreDisplay(line('.'), 2)<cr>zb")
        \ . SaveMap("C",     ":call ExploreDisplay(line('.'), 1)<cr>zb")
        \ . SaveMap("cc",
            \ ":echo system('cleartool desc -short '.ExploreGetFile())<cr>")
        \ . SaveMap("x",
            \ ":echo system('explorer \"' . ExploreGetFile() . '\"')<cr>")
        \ . SaveMap("!",     ":!start cmd<cr>")
        \ . SaveMap("?",     ":call ExploreHelp()<cr>")
        \ . SaveMap("<c-l>", ":<c-u>let g:explore_level = v:count1<cr><c-r>")
        \ . SaveSet("swapfile", 0)
        \ . SaveSet("titlestring")
        \ . SaveSet("lines")
        \ . SaveSet("write", 0)
    call ExploreFile(expand("%:p:h"))
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
    if a:0 == 1 && a:1 == 1
        " display clearcase attributes
        let cmd = cmd . " -cc"
    endif
    if a:0 == 1 && a:1 == 2
        " display date & size
        let cmd = cmd . " -full"
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
            let where = 2
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

endif

" Number of last window
function! WinLast()
    let i = 1
    while winheight(i) != -1
        let i = i + 1
    endwhile
    return i - 1
endfunction

" Make current window as small as the number of lines in it, if less than
" current size.
function! WinShrink()
    let l = line('$')
    if l < winheight(0)
        exec 'resize ' . l
    endif
endfunction

" Handle lines that wrap.
function! WinShrink2()
    let max = winheight(0)  " don't let it get bigger than this
    let lines = line('$')
    if lines >= max
        " can't shrink
        return
    endif
    exec 'resize ' . lines
    let pos = GetPos()
    while 1
        call Norm('G$H')
        let diff = line('.') - 1
        if diff == 0
            break
        endif
        let size = Min(max, winheight(0) + diff)
        exec 'resize ' . size
        if size == max
            break
        endif
    endwhile
    call Norm(pos)

endfunction

" Open a temporary window at the bottom of given size.
" 2nd arg is name, if supplied.  If not, nowrite is set.
function! TempWin(size, ...)
    if a:0 == 1
        let name = a:1
    else
        let name = "_temp_"
        call delete(name)
    endif

    let save = SaveSet('splitbelow', 1)
    exec 'silent split ' . name
    exec save
    exec 'resize ' . a:size

    nmap <buffer> <silent> <esc> :echo<cr>:set nomod<cr>:close<cr>
    setlocal nolinebreak
    set buftype=nowrite
    set bufhidden=delete
    set noswapfile
    set nobuflisted
endfunction

" Resize temp win to exactly fit, unless bigger than max
function! TempWinResize(max)
    let size = Min(a:max, line("$"))
    call Norm(size . "\<c-w>_")
    if line('$') > size
        echo '(' . (line('$')-size) . ' more)'
    endif
endfunction

" Create a temp win and put unnamed buffer in it
function! TempWinPut(size)
    let ft = &ft
    call TempWin(a:size)
    let b:filetype = ft
    silent put
    1 delete
    call TempWinResize(a:size)
    wincmd w
    wincmd w
    wincmd w
endfunction

" Create temp win and run cmd in it
function! TempWinCmd(size, cmd)
    call TempWin(a:size)
    call SetCmd("read !" . a:cmd, "ch", 2)
    1 delete
    call TempWinResize(a:size)
"    if line("$") < a:size
"        call Norm(line("$") . "\<c-w>_")
"    endif
    set nomod readonly
endfunction

" TODO: new bookmark implementation
" Have ids associated with bookmarks, don't bother with line numbers. Comments?
" ba would add, prompt for id
" E.g. clog -> IM log properties
" From command line, "be clog" edits at that bookmark

Help 'ba - add bookmark for current location'
Help 'be - edit bookmarks in temp window'
Help ',be - edit bookmarks in new vim instance'
let g:bookmarks = GetRoot() . '/bookmarks.txt'
nmap ba :call BookMarkAdd()<cr>
nmap be gU:call BookMarkEdit()<cr>
nmap ,be :echo Chomp(system("be"))<cr>

function! BookMarkAdd()
    let file = expand("%:p")
    let file = BookMarkAdjust(file, 0)
    let line = ''
    if !isdirectory(file) && line('.') > 1
        let line = '  ' . line('.')
    endif
    let comment = input("Comment? ")
    if comment == ''
        let comment = expand('%:p:t')
    endif
    call Append('# ' . comment, g:bookmarks)
    call Append('  ' . file . line, g:bookmarks)
endfunction

function! BookMarkEdit()
    call TempWin(&lines/2, g:bookmarks)
    set buftype=  " TempWin sets this
endfunction

autocmd BufEnter bookmarks.txt call DoBookmarks()

" mappings and syntax for bookmarks file
function! DoBookmarks()
    nmap <buffer> <silent> <cr> :call BookMarkGoto()<cr>
    nmap <buffer> <silent> gl :call BookMarkGoto()<cr>
    syntax match bookmarkDirectory ".*\\$"
    syntax match bookmarkComment   "#.*"
    syntax match bookmarkLinenum   "\d\+$"
    syntax match bookmarkVar       containedin=bookmarkDirectory "%[^%]\+%"
    highlight link bookmarkDirectory Directory
    highlight link bookmarkComment   Comment
    highlight link bookmarkLinenum   String
    highlight link bookmarkVar       Special
endfunction

function! BookMarkGoto()
    if !Update(0) | return | endif
    let loc = substitute(getline('.'), '^\s*', '', '')
    if loc =~ '^#'
        let loc = getline(line('.') + 1)
    endif
    let file = substitute(loc, '  \d\+$', '', '')
    if file == loc
        let line = 1
    else
        let line = substitute(loc, '.*  ', '', '')
    endif
    let file = BookMarkAdjust(file, 1)
    if FileExists(file)
        exec 'edit ' . file
        exec line
        silent only
    else
        call Warning('File not found: ' . file)
    endif
endfunction

" Expand or contract path for bookmark file.
" Env vars, etc.
function! BookMarkAdjust(file, expand)
    let file = a:file
    let envvars = ['foo', 'ROOT', 'USERPROFILE', 'ALLUSERSPROFILE']
    for var in envvars
        exec 'let val = $' . var
        if val != ''
            let val = escape(substitute(val, '\\$', '', ''), '\\')
            let var_pat = '%' . var . '%'
            if a:expand
                let file = substitute(file, var_pat, val, '')
            else
                let file = substitute(file, '^' . val, var_pat, '')
            endif
        endif
    endfor
    return file
endfunction


nmap ,ls gU:call FileShow('ls')<cr>
nmap ,lt gU:call FileShow('lt')<cr>
function! FileShow(cmd)
    call CdToDir()
    call TempWin(5)
    call SetCmd('read !' . a:cmd, "ch", 2)
    1 delete
    let size = Min(10, line("$"))
    call Norm(size . "\<c-w>_")
    set nomod ro
"    let b:state = b:state . SaveMap("<cr>",  ":call GoFile()<cr>")
    nmap <buffer> <silent> <cr> :call GoFile()<cr>:only<cr>
endfunction

" Go to alt buffer if it's a real one, otherwise last buffer in jump list
Help 'ea - go to previous buffer'
nmap \e <esc>

nmap <c-b> ea
nmap <silent> ea gU:call BufPrev()<cr>
function! BufPrev()
    if buflisted(@#)
        edit #
        return
    endif
    redir @t
    call SilentExec('jumps')
    redir END
    let t = @t
    let t = Sub('g', t, "\n>", '')
    while 1
        let x = matchstr(t, "[^\n]*$")
        if x == ""
            echo "no other buffer found"
            return
        endif
        let t = substitute(t, "\n[^\n]*$", '', '')
        let f = substitute(x, '^\s*\d\+\s\+\d\+\s\+\d\+\s\+\(.*\)', '\1', '')
        if buflisted(f)
            exec "buffer " . f
            return
        endif
    endwhile
endfunction

function! SilentExec(cmd)
    silent exec a:cmd
endfunction

nmap ,bs :call BufShow2()<cr>
function! BufShow2()
    buffers
    let b = input("Buffer? ")
    if b != ""
        exec "buffer " . b
    endif
endfunction

"??? OLD
"nmap <silent> bs gU:call BufShow()<cr>
"function! BufShow()
"    call CdToDir()
"    let n = bufnr("$")
"    let l = 0
"    let all = ""
"    while n > 0
"        if bufexists(n) && buflisted(n)
"            if bufnr("#") == n
"                let flag = "#"
"            elseif bufnr("%") == n
"                let flag = "%"
"                let mainbuf = n
"            else
"                let flag = " "
"            endif
"            let name = bufname(n)
"            if flag != "%"
"            \ && match(name, 'Vim\\vim\\vim\d\+\\doc\\') >= 0
"                " help buffer -- delete it
"                exec "bdelete " . n
"            else
"                let this = NumFormat(n, 2) . " " . flag . " " . bufname(n)
"                let all = this . "" . all
"                let l = l + VirtLines(this)
"            endif
"        endif
"        let n = n - 1
"    endwhile
"    if l == 1
"        return Warning("only one buffer")
"    endif
"    call TempWin(l, "Buffers")
"    call append(0, all)
"    1 s//^M/g
"    $-1,$ delete
"    1
"    if mainbuf == 1
"        2
"    endif
"    set nomod readonly
""    let b:state = b:state
""        \.SaveMap("<cr>",  ":call BufGoto(BuffersGetNum())<cr>")
""        \.SaveMap("?",     ":call BuffersHelp()<cr>")
""        \.SaveMap("dd",    ":call BuffersDelete()<cr>")
""        \.SaveMap("<del>", ":call BuffersDelete()<cr>")
""        \.SaveMap(".",     ":call BuffersDelete()<cr>")
"
""    map <buffer> <cr>   :call BufGoto(BuffersGetNum())<cr>
"    map <buffer> <cr>   :exec "buffer " . BuffersGetNum()<bar>only<cr>
"    map <buffer> ?      :call BuffersHelp()<cr>
"    map <buffer> dd     :call BuffersDelete()<cr>
"    map <buffer> <del>  :call BuffersDelete()<cr>
"    map <buffer> .      :call BuffersDelete()<cr>
"    echo "<cr> to goto; dd or <del> to delete"
"endfunction

"??? experimental version using redir
nmap <silent> bs gU:call BufShow3()<cr>
function! BufShow3()
    " save & restore buffer -- the delete messes it up
    let save_buf = @"
    call CdToDir(1)
    let bufs = ViCmd("buffers")
    let bufs = substitute(bufs, "\n", "\t", 'g')
    let bufs = substitute(bufs, "^\t", '', '')
    if match(bufs, "\t") == -1
        return Warning("only one buffer")
    endif
    let bufs = substitute(bufs, '"', "'", 'g')
    " this makes paths relative to cwd:
    if strlen(bufs) > 8000
        return Error('Too many buffers')
    endif
    let bufs = system('perl -S vim_buffers.pl "' . bufs . '"')
    call TempWin(10, "Buffers")
    call append(0, bufs)
    silent exec '%s/	/' . g:cr . '/ge'
    silent $ delete
    call WinShrink()
    " no line nums if too wide
    if strlen(getline(1)) >= &columns
        silent % s/\s\+line \d\+$//e
    endif
    1
    if match(getline('.'), '^ *\d\+ \+%') != -1
        2
    endif
    setlocal nolinebreak
    setlocal nowrap
    set nomod readonly buftype=nowrite
    " use buffer name to goto, so we can edit it
"    map <buffer> <cr>   :exec "buffer " . BuffersGetNum()<bar>only<cr>
    nmap <buffer> <silent> <cr>   :call BuffersGoto()<cr>
    imap <buffer> <silent> <cr>   <esc>:call BuffersGoto()<cr>
    nmap <buffer> <silent> ?      :call BuffersHelp()<cr>
    nmap <buffer> <silent> dd     :call BuffersDelete()<cr>
    nmap <buffer> <silent> <del>  :call BuffersDelete()<cr>
    nmap <buffer> <silent> .      :call BuffersDelete()<cr>
    echo "<cr> to goto; dd or <del> to delete"
    let @" = save_buf
endfunction

function! BuffersGoto()
    let f = Match1(getline('.'),  '"\(.*\)"')
    let n = bufnr(f)
    bdelete
    if n == -1
        exec "edit " . f
    else
        exec "buffer " . n
    endif
endfunction

function! BuffersHelp()
    echo "<cr>  - goto buffer"
    echo "dd    - delete buffer"
    echo "<esc> - cancel"
    echo "?     - this message"
endfunction

function! BuffersDelete()
    exec BuffersGetNum() . " bdelete"
    set noreadonly
    delete
    set nomodified readonly
endfunction

function! BuffersGetNum()
    return matchstr(getline('.'), '^ *\d\+')
endfunction

Help ',vx - execute vim command that is on this line'
nmap ,vx :call ViExecute()<cr>
function! ViExecute()
    if GetSyntaxTranslated() != 'Comment'
        return Error("not on a comment")
    endif
    let cmd = getline('.')
    let cmd = substitute(cmd, '^\s*', '', '')
    let cmd = substitute(cmd, '\s*$', '', '')
    let comments = GetCommentDelimiters()
    let c1 = GetArray(comments, 0)
    if c1 != ''
        let cmd = substitute(cmd, '^' . c1 . '\s*', '', '')
    endif
    let c2 = GetArray(comments, 1)
    if c2 != ''
        let cmd = substitute(cmd, '^' . c2 . '\s*', '', '')
        let c3 = GetArray(comments, 2)
        if c3 != ''
            let cmd = substitute(cmd, '\s*' . c3 . '$', '', '')
        endif
    endif
    if cmd != ''
        exec cmd
    endif
endfunction
"echo g:foo

Help ',vi - start a new vi on file in this buffer'
nmap ,vi :call ViFile()<cr>
function! ViFile()
    if BufCount() == 1
        return Warning("only one buffer")
    endif
    exec "!start gvim " . expand("%")
    bdelete
endfunction

" Run a vi cmd and return its output.
" This was fixed with silent => NOTE: output still goes to screen!
function! ViCmd(cmd)
    let x = @x
    redir @x
    silent exec a:cmd
    redir END
    let result = @x
    let @x = x
    return result
endfunction

Help 'dac yac - delete/yank enclosing comment'
nnoremap dac v<esc>:call HighlightComment()<cr>d
nnoremap yac v<esc>:call HighlightComment()<cr>y

Help 'V ac - highlight the enclosing comment (C++/Java style)'
vmap ac <esc>:call HighlightComment()<cr>
function! HighlightComment()
    let before = BeforeCursor()
    let i = match(before, '\s*//')
    if i == -1
        let j = match(AfterCursor(), '^\s*//')
        if j >= 0
            let i = strlen(before) + j
        endif
    endif
    if i >= 0
        " //-style comment; i points to whitespace before //
        if i == 0
            " whole line: expand to preceding and following lines
            let last = line('.')
            while getline(last + 1) =~ '^\s*//'
                let last = last + 1
            endwhile
            let first = line('.')
            while getline(first - 1) =~ '^\s*//'
                let first = first - 1
            endwhile
            call Norm(last . 'GV' . first . 'G')
        else
            " just to end of line
            call Norm("$v" . (i+1) . "|")
        endif
    else
        call Norm("]*v%\<esc>")
        " note: use <esc> and gv or '< and '> don't get updated
        if getline("'<") =~ '^\s*/\*' && getline("'>") =~ '\*/\s*$'
            call Norm("gvV")
        else
            call Norm("gv")
        endif
    endif
endfunction

" Go backwards until preceding line is non-comment
function! ScanForNonComment()
    let line = line('.')
    while line > 1
        let text = getline(line - 1)
        if text =~ '^\s*//'
            " // style comment
            let line = line - 1
            call Norm('k')
        elseif text =~ '\*/\s*$'
            " /* style comment
            call Norm('k$F*%')  " go to opening of comment
            let line = line('.')
        else
            break
        endif
    endwhile
endfunction

Help 'V am - highlight the enclosing method'
vmap am :<c-u>call HighlightMethod(1)<cr>
vmap im :<c-u>call HighlightMethod(0)<cr>
function! HighlightMethod(outer)
    call search('[{}]', 'c')
    call JavaNextMethod('b')
    call ScanForNonComment()
    let l1 = line('.')
    call search('{')
    call Norm('%')
    if a:outer
        " Include blank lines after method, if any
        let l2 = search('\S', 'nW')
        if l2 != 0
            let l2 = l2 - 1
            exec l2
        endif
    endif
    call Norm('V' . l1 . 'G')
endfunction

Help 'V ab - highlight the enclosing block'
vmap ab :<c-u>call HighlightBlock()<cr>

function! HighlightBlock()
    let ol1 = line("'<")
    let ol2 = line("'>")
    let range = GetBlockContaining2(ol1, ol2)
    let l1 = matchstr(range, '^\d\+')
    let l2 = matchstr(range, '\d\+$')
    if l1 == ol1 && l2 == ol2
        let range = GetBlockContaining2(l1-1, l2+1)
        let l1 = matchstr(range, '^\d\+')
        let l2 = matchstr(range, '\d\+$')
    endif
"echo "??? range =" range
    call Norm(l2 . 'GV' . l1 . 'G')
endfunction

function! GetBlockContaining2(pos1, pos2)
    let r1 = GetBlockContaining(a:pos1)
    let r2 = GetBlockContaining(a:pos2)
    let l1 = matchstr(r1, '^\d\+')
    let l2 = matchstr(r2, '^\d\+')
    if l1 < l2
        return r1
    elseif l2 < l1
        return r2
    else
        let l1 = matchstr(r1, '\d\+$')
        let l2 = matchstr(r2, '\d\+$')
        if l1 > l2
            return r1
        else
            return r2
        endif
    endif
endfunction

" pos can be anything acceptable to getline()
function! GetBlockContaining(pos)
    exec a:pos
    let line = getline('.')
    if line =~ '{$'
        call Norm('$')
    elseif line =~ '{\s\+$'
        call Norm('$F{')
    else
        call Norm('[{')  " not on starting line -- go there
    endif
    if getline('.') =~ ')\s*{\s*$'
        call Norm('$F)%')  " go to line of opening paren
    endif
    let l1 = line('.')
    while getline('.') =~ '^\s*}'
        call Norm("F}%")
        if line('.') == l1
            break
        endif
        let l1 = line('.')
    endwhile
    call Norm("%")
    " extend if on '} else {', e.g.
    let l2 = line('.')
    while getline('.') =~ '{\s*$'
        call Norm("f{%")
        if line('.') == l2
            break
        endif
        let l2 = line('.')
    endwhile
    return l1 . ',' . l2
endfunction

function! GetVRange()
    return line("'<") . "," . line("'>")
endfunction

" Align text
" Highlight in visual mode, then a< or a>, then type pattern (get last search
" pattern from history).  Each line is aligned before or after pattern.

Help 'V a< a> - align text to left or right of given pattern'
Help 'V A< A> - like a< and a> but delete whitespace first'
command! -nargs=? -range AlignL call Align(0, <line1>, <line2>, "l", <q-args>)
command! -nargs=? -range AlignR call Align(0, <line1>, <line2>, "r", <q-args>)
command! -nargs=? -range AlignLX call Align(1, <line1>, <line2>, "l", <q-args>)
command! -nargs=? -range AlignRX call Align(1, <line1>, <line2>, "r", <q-args>)

vmap a< :<c-u>call AlignIt("AlignL")<cr>:<up>
vmap a> :<c-u>call AlignIt("AlignR")<cr>:<up>
vmap A< :<c-u>call AlignIt("AlignLX")<cr>:<up>
vmap A> :<c-u>call AlignIt("AlignRX")<cr>:<up>

Help 'V a/ a= a# - align text before // or = or #'
vmap a/ :<c-u>call Align(1, line("'<"), line("'>"), "l", "//")<cr>
vmap a= :<c-u>call Align(1, line("'<"), line("'>"), "l", "=")<cr>
vmap a# :<c-u>call Align(1, line("'<"), line("'>"), "l", "#")<cr>

Help 'V a: a, - align text after : or ,'
vmap a: :<c-u>call Align(1, line("'<"), line("'>"), "r", ":")<cr>
vmap a, :<c-u>call Align(1, line("'<"), line("'>"), "r", ",")<cr>

"vmap a<tab> :<c-u>:call Align(1, l1, l2, 'l', "\<tab>")<cr>'<,'>s/\<tab>/  /<cr>

vmap a<tab> :<c-u>call AlignTab(line("'<"), line("'>"))<cr>
function! AlignTab(l1, l2)
    let l1 = a:l1
    let l2 = a:l2
    call Align(1, l1, l2, 'l', "\<tab>")
    exec l1 . ',' . l2 . "s/\<tab>/  /"
endfunction

Help 'V a1 a2 ... - align text after column 1, 2, ...'

vmap a1 :<c-u>call AlignColumn(0, 1)<cr>
vmap a2 :<c-u>call AlignColumn(0, 2)<cr>
vmap a3 :<c-u>call AlignColumn(0, 3)<cr>
vmap a4 :<c-u>call AlignColumn(0, 4)<cr>
vmap a5 :<c-u>call AlignColumn(0, 5)<cr>
vmap a6 :<c-u>call AlignColumn(0, 6)<cr>
vmap a7 :<c-u>call AlignColumn(0, 7)<cr>
vmap a8 :<c-u>call AlignColumn(0, 8)<cr>
vmap a9 :<c-u>call AlignColumn(0, 9)<cr>

vmap A1 :<c-u>call AlignColumn(1, 1)<cr>
vmap A2 :<c-u>call AlignColumn(1, 2)<cr>
vmap A3 :<c-u>call AlignColumn(1, 3)<cr>
vmap A4 :<c-u>call AlignColumn(1, 4)<cr>
vmap A5 :<c-u>call AlignColumn(1, 5)<cr>
vmap A6 :<c-u>call AlignColumn(1, 6)<cr>
vmap A7 :<c-u>call AlignColumn(1, 7)<cr>
vmap A8 :<c-u>call AlignColumn(1, 8)<cr>
vmap A9 :<c-u>call AlignColumn(1, 9)<cr>


function! AlignColumn(del, n)
    let n = a:n
    let pat = '\S\+'
    while n > 1
        let n = n - 1
        let pat = pat . '\s\+\S\+'
    endwhile
    call Align(a:del, line("'<"), line("'>"), "r", pat)
endfunction

Help 'V ar - compress ws to one space, except at start'
Help 'V ar - compress ws to one space, except at start'
vmap ar :call AlignRemove(0)<cr>
vmap Ar :call AlignRemove(1)<cr>
function! AlignRemove(all)
    if a:all
        s/\(\S\)\s\+/\1/
    else
        s/\(\S\)\s\+/\1 /
    endif
endfunction

function! AlignIt(func)
    call histadd(":", "'<,'>" . a:func . " " . @/)
    call histadd(":", "'<,'>" . a:func . " ")
endfunction

" Align lines from l1 to l2 before or after pat, depending on kind.
function! Align(del, l1, l2, kind, pat)
    let pat = a:pat
    " if aligning to right and not deleting extra space, have to include in pat
    if a:del == 0 && a:kind == "r" && pat !~ '\$$'
        let pat = pat . '\s*'
    endif
    " Find col to align at, then align.
    let col = AlignFindPat(a:del, a:l1, a:l2, a:kind, pat)
    if col > 0
        call AlignDoPat(a:l1, a:l2, a:kind, pat, col)
    endif
endfunction

function! AlignDoPat(l1, l2, kind, pat, col)
    " simulate smartcase -- only ignorecase applies to match & matchend
    if &ignorecase && &smartcase && !HasUpperCase(a:pat)
        let save = SaveSet("ignorecase", 0)
    else
        let save = ""
    endif

    let i = a:l1
    while i <= a:l2
        let line = getline(i)
        if a:kind == "l"
            let j = match(line, a:pat)
        else
            let j = matchend(line, a:pat)
        endif
        if j != -1
            " insert col - j spaces after col j
            let x = strpart(line, 0, j)
            let y = strpart(line, j, 999999)
            while j < a:col
                let x = x . " "
                let j = j + 1
            endwhile
            call setline(i, x . y)
        endif
        let i = i + 1
    endwhile

    exec save
endfunction

function! AlignFindPat(del, l1, l2, kind, pat)
    let pat = a:pat
    let i = a:l1
    let max = 0
    while i <= a:l2
        let line = getline(i)
        if a:kind == "l"
            if a:del
                let line = substitute(line, '\s\+\('.a:pat.'\)', ' \1', '')
                call setline(i, line)
            endif
            let j = match(line, pat)
        else
            if a:del
                let line = substitute(line, '\('.a:pat.'\)\s\+', '\1 ', '')
                call setline(i, line)
            endif
            let j = matchend(line, pat)
        endif
        if j > max
            let max = j
        endif
        let i = i + 1
    endwhile
    return max
endfunction

Help 'V a( a) - add/remove parens around selected code'
vmap a( c<c-r>=DoParens()<cr><esc>`<
vmap a) a(
function! DoParens()
    let x = @@
    if x =~ '^('
        return Sub('', x, '^(', '', ')$', '')
    else
        return '(' . x . ')'
    endif
endfunction

Help 'V a{ a} - add/remove braces around selected lines'
vmap a{ :<c-u>call DoBraces()<cr>
vmap a} a{
function! DoBraces()
    let l0 = line("'<")
    let l1 = line("'>")
    if match(getline(l0), '^\s*{\s*$') == 0
            \ && match(getline(l1), '^\s*}\s*$') == 0
        " already have braces -- delete them
        '> delete
        '< delete
    else
        '<,'> >
        exec l0
        call Norm("O{\<esc>")
        let l1 = l1 + 1  " to account for new line
        exec l1
        call Norm("o}\<esc>")
        exec l0
    endif
endfunction


"??? lang-specific
Help 'at - add try block around selected code'
vnoremap at >'<Otry {<esc>'>o} catch() {<cr>}<esc>bba
Help 'af - add try-finally block around selected code'
vnoremap af >'<Otry {<esc>'>o} finally {<cr>}<esc>ba<cr>

"vmap at :call AddTry()<cr>
"function! AddTry()
"    normal! >>
"    call Norm("'<Otry {\<esc>")
"    call Norm("'>o} catch() {\<cr>}")
"    call Norm("bba")
"endfunction

" idea from findfile.vim http://www.freespeech.org/aziz/vim/my_macros/
nmap ,fp :call FindFilePat()<cr>
function! FindFilePat()
    if !Update() | return | endif
    let pat = input("File pattern? ")
    echo "\r"
    if pat == ""
        return Warning("Canceled     ")
    endif
    call TempWin(10)
    call FindFile(".", pat)
    $ delete
    1
    set nomod readonly
endfunction

function! FindFile(dir, pat)
    let fls = expand(a:dir."/*")."\n"
    let fls = substitute(fls,"\\","/","g")
    let fls = substitute(fls,"//","/","g")
    let dirs = ""
    while fls != ""
        let fl = substitute(fls, "\n.*", "", "")
        let fls = substitute(fls, ".\\{-}\n", "", "")
        let simple = substitute(fl, '.*/\(.\+\)', '\1', "")
        if match(simple, a:pat) != -1
            call append(line("$")-1, fl)
        endif
        if isdirectory(fl)
            let dirs = dirs . fl . "\n"
        endif
    endwhile
    while dirs != ""
        let dir = substitute(dirs, "\n.*", "", "")
        let dirs = substitute(dirs, ".\\{-}\n", "", "")
        call FindFile(dir, a:pat)
    endwhile
endfunction

"FIX ,cx doesn't work right -- paths are relative to top instead of cwd
" Compile - current file or its directory
nmap <silent> cx :call Compile(0)<cr>
nmap <silent> ,cx :call Compile(1)<cr>
function! Compile(all)
    if exists('b:page_cmd')
        return Page()
    endif
    if !Update() | return | endif
    call ErrorMaps()
    if &ft == 'perl'
        if !&readonly && (!exists('g:no_protos') || !g:no_protos)
            call MakeProto(1)  " often have errors due to out-of-date protos
        endif
        let cmd_one = 'perl -S perlc.pl -o <tmp> ' . @%
        let cmd_all = 'perl -S perlc.pl -o <tmp> ' . Dir()
    elseif &filetype == 'c'
        " only generate prototypes for static fns
        call MakeCProto(1)
        return
    else
        return Warning("don't know how to compile " . &ft . " files")
    endif
    let cmd = Cond(a:all, cmd_all, cmd_one)
    let tmp = GetTemp("cx")
if 1
    let cmd = substitute(cmd, '<tmp>', escape(tmp, '\\'), 'g')
"    echo cmd
    echo system(cmd)
    if v:shell_error == 0
        echo Chomp(system("cat " . tmp))
        echo "No errors"
    else
        exec "cfile " . tmp
    endif
    call delete(tmp)
else
    let cmd = substitute(cmd, '-o <tmp> ', '', '')
    call SetCmd("make", "makeprg", cmd)
    let &ch=1
    if v:shell_error == 0
        clist
    endif
endif
endfunction


Help 'sm - prompt for java method name and search for it'
nnoremap sm :call SearchMethod()<cr>
function! SearchMethod(...)
    if a:0 == 0
        let name = GetID(1, 'Method name')
    else
        let name = a:1
    endif
    let pat = '^\s*' . g:java_qual_pat . '\(static \)\=\S\+ ' . name . '\s*('
    if search(pat, 's') == 0
        return Warning('Method ' . name . ' not found')
    endif
endfunction

" a:flags may have 'b' to search backwards
function! JavaNextMethod(flags)
    " use \w for method name and \i for return type (allow: . [ ])
    let save = SaveSet("isident", "+.,[,]")
    let pat = '^\s*' . g:java_qual_pat . '\(static\s\+\)\='
    let pat = pat . '\i\+\s\+\w\+\s*('
    if search(pat, a:flags . 's') == 0
        call Warning('No more methods found')
    endif
    exec save
    " check for spurious match on line like this:
    "   new Type(...)
    if getline('.') =~ '^\s*new\s'
        return JavaNextMethod(a:flags)
    endif
endfunction

" Find the next (dir == "/") or previous (dir == "?") Java method,
" by searching for formal parameter decls.
"function! JavaNextMethod(dir)
"    let save = SaveSet("isident", "+.")
"    if a:dir == "/"   " if we're on the line of a method, go past params
"        let save = save . SaveSet("visualbell", 1) . SaveSet("t_vb", "")
"        normal f(
"        normal ])
"    endif
"    while 1
""        exec a:dir . '[,(]\s*\i\+\s\+\i\+\s*)'
"        exec a:dir.'\((\s*)\|[,(]\s*\i\+\s\+\i\+\s*)\)\s*\($\|;\|{\|throws\>\)'
"        " don't stop at catch clauses, which has similar formal params
"        if getline(".") !~ '\<catch\>'
"            break
"        endif
"    endwhile
"    exec save
"    normal f)%^
"endfunction

"??? make [C ]C go to enclosing class or next at same level
"??? do [{ until at class (i.e. point where class appears before {})
"??? check ]m & [m

" ]c and [c go to next class/interface
nmap ]c g.:call NextClass("/")<cr>
nmap [c g.:call NextClass("?")<cr>
function! NextClass(dir)
"    exec a:dir . '\<\(class\|interface\)\s\+\i\+'
    exec a:dir . '^\s*' . g:java_mods_pat . '\(class\|interface\)\s\+\i\+'
endfunction

Help ',gj - goto java package or class (dotted-name)'
nnoremap ,gj :call GotoJavaName()<cr>
function! GotoJavaName()
    let save = SaveSet('iskeyword', '+.')
    let id = GetID(0, "Enter dotted name")
    exec save
    if id == ''
        return
    endif
    if id !~ '\.' && FileExists(id . '.java')
        call Edit(id . '.java')
        return
    endif
    let full = expand("%:p")
echo "??? full = <".full.">"
"    let root = substitute(full, '^\(.*\\\|\)\(org\|com\)\\', '\2\\', '')
    let root = substitute(full, '\\\(org\|com\)\\.*', '', '')
    if root == full
        return Error("can't determine source root for this file")
    endif
echo "??? root = <".root.">"
    let path = root . "\\" . substitute(id, '\.', '\\', 'g')
    if !isdirectory(path)
        let path = path . '.java'
    endif
echo "??? path = <".path.">"
    call Edit(path)
endfunction
" zxcv.asdf.qwer

Help ',co - update copyright for this year'
nnoremap ,co :call FixCopyright()<cr>
function! FixCopyright()
    let pos = GetPos()  " get back to where we were at end
    call cursor(1, 1) " search from start of file
    let line = search('Copyright IBM', 'n', 10)  " only look in first 10 lines
    call Norm(pos)
    if line == 0
        " TODO: add copyright; consider filetype
        return Warning('No copyright found')
    endif
    let text = getline(line)
    let year = strftime('%Y')
    if text =~ '\<'.year.'\>'
        return Note('Copyright already contains ' . year)
    endif
    let yearPat = '\<\(\d\d\d\d\)\(,\s*\d\d\d\d\)\=\>'
    let newText = substitute(text, yearPat, '\1, ' . year, '')
    if newText == text
        return Warning('Failed to find old year in copyright: ' . text)
    endif
    let delta = strlen(newText) - strlen(text)
    if delta > 0
        " line got longer -- if there is a box, fix it
        let newText = substitute(newText, '\(.*\) \{'.delta.'}', '\1', '')
    endif
    call setline(line, newText)
endfunction


Help ',fu - find non-generic collections classes'
nnoremap ,fu :call FindUngeneric()<cr>n
function! FindUngeneric()
    " These classes should all be generic
    let classes = [ 'Collection', 'Iterator', 'Entry' ]
    let classes += [ 'Map', 'HashMap', 'LinkedHashMap', 'TreeMap' ]
    let classes += [ 'MapMap', 'MapHashMap', 'MapTreeMap' ]
    let classes += [ 'Set', 'HashSet', 'LinkedHashSet', 'TreeSet' ]
    let classes += [ 'MapSet', 'MapHashSet', 'MapLinkedHashSet', 'MapTreeSet' ]
    let classes += [ 'List', 'ArrayList', 'LinkedList' ]
    let pat = ''
    for class in classes
        let pat = pat . '\|' . class
    endfor
    let pat = substitute(pat, '^\\|', '', '')
    let pat = '\<\(' . pat . '\)\>[^<.;]'
    let @/ = pat
    echo pat
endfunction

Help ',na - add NON-NLS marker'
nnoremap ,na :call AddNonNLS()<cr>
Help ',nr - remove NON-NLS marker on current line'
nnoremap ,nr :call RemoveNonNLS()<cr>
Help ',ns - find non-localized strings without NON-NLS marker (beware 2 strings on a line)'
"nnoremap ,ns /^[^/]*\(\/[^/*][^/]*\)*"[^"]*".*\(\$NON-NLS-1\$.*\)\@<!$/<cr>
nnoremap ,ns /\(^[^/]*\(\/[^/*][^/]*\)*\)\@<="[^"]*".*\(\$NON-NLS-1\$.*\)\@<!$/<cr>

Help ',nf - fix non-localized string'
nnoremap ,nf :call NonLocalizedFix2()<cr>

function! AddNonNLS()
    let line = getline('.')
    let n = 1
    while line =~ '\$NON-NLS-'.n.'\$'
        let n = n + 1
    endwhile
    if n == 1
        let line = line . ' '
    endif
    let line = line . '//$NON-NLS-' . n . '$'
    call setline(line('.'), line)
endfunction

function! RemoveNonNLS()
    let line = substitute(getline('.'), ' *//\$NON-NLS-\d\$\s*$', '', '')
    call setline(line('.'), line)
endfunction

function! NonLocalizedFix()
    let pre = BeforeCursor()
    let post = AfterCursor()
    "NOTE clever regexs: they match " but not \"
    let line = pre . post
    if pre =~ '"' && post =~ '"'
        let string = substitute(pre, '.*\\\@<!"', '', '')
            \ . substitute(post, '\\\@<!".*', '', '')
    else
        let string
            \ = substitute(line, '.\{-}\\\@<!"\(.\{-}\)\\\@<!".*', '\1', '')
        if string == line
            return Warning("no string on current line")
        endif
    endif
    let id = string  " map string to reasonable id for message
    if 0
        " this one does: "This is message {0}" -> "This_is_message_0"
        " problem with this is it can get long
        let id = substitute(id, '\W\+', '_', 'g')
        let id = substitute(id, '^_', '', '')
        let id = substitute(id, '_$', '', '')
    else
        " this one does: "This is message {0}" -> "ThisIsMessage"
        let id = substitute(id, '\<\(\w\)', '\u\1', 'g')
        let id = substitute(id, '\W', '', 'g')
    endif
    " prepend class
    let id = expand("%:t:r") . '.' . id
    let get = 'Messages.get("' . id . '")'
    let estring = escape(string, '\\.*')
    let line = getline('.')
    let line2 = substitute(line, '"' . estring . '"', get, '')
    if line2 == line
        return Warning("failed to substitute for string: " . estring)
    endif
    let line2 = line2 . ' //$NON-NLS-1$'
    call setline(line('.'), line2)
    call System('add_message.pl "' . id . '" "' . string . '"')
endfunction

" New version using NLS.bind(NLS.<field>,...)
function! NonLocalizedFix2()
    if !Update() | return | endif
    call CdToDir()
    let pre = BeforeCursor()
    let post = AfterCursor()
    "NOTE clever regexs: they match " but not \"
    let line = pre . post
    if pre =~ '"' && post =~ '"'
        let string = substitute(pre, '.*\\\@<!"', '', '')
            \ . substitute(post, '\\\@<!".*', '', '')
    else
        let string
            \ = substitute(line, '.\{-}\\\@<!"\(.\{-}\)\\\@<!".*', '\1', '')
        if string == line
            return Warning("no string on current line")
        endif
    endif
    let id = tolower(string)  " map string to reasonable id for message
    " problem with this is it can get long
    let id = substitute(id, '{\d\+}', '', 'g')
    let id = substitute(id, '\W\+', '_', 'g')
    let id = substitute(id, '^_', '', '')
    let id = substitute(id, '_$', '', '')
    let id = substitute(id, '[^_]\+', '\u&', 'g')
    let id = expand('%:t:r') . '_' . id
    let id = Input2('enter id', id)
    if id == ''
        return Warning('Canceled')
    endif

    let class = expand('%:t:r')
    let string2 = substitute(string, '\\"', '\\042', 'g')
    let cmd = 'add_message.pl -vi ' . class . ' "' . id . '" "' . string2 . '" -file=' . expand('%')
    echo cmd
    "return
    let get = system(cmd)
    if v:shell_error
        return Warning(get)
    endif
    let estring = escape(string, '\\.*')
    let line = getline('.')
    let line2 = substitute(line, '"' . estring . '"', get, '')
    if line2 == line
        return Warning("failed to substitute for string: " . estring)
    endif
    call setline(line('.'), line2)
endfunction


Help 'md - make the containing method a delegate by calling a method with the same name'
nmap md :call MakeDelegate()<cr>
function! MakeDelegate()
    normal! j[{
    let insert = line('.')
    normal! b
    let method = getline('.')
    if method !~ ')'
        return Warning('No method found on line ' . line('.') . ': ' . method)
    endif
    while method !~ '('
        normal k
        let method = getline('.') . method
    endwhile
    let name = substitute(method, '.*\<\(\w\+\)\s*(\s*\(.*\)).*', '\1', '')
    if name == method
        return Warning('Failed to parse method decl: ' . method)
    endif
    let args = substitute(method, '.*\<\(\w\+\)\s*(\s*\(.*\)).*', '\2', '')
    let args = substitute(args, '[a-zA-Z0-9_\[\] ]\+ \(\w\+\)', '\1', 'g')
    let args = substitute(args, ',', ', ', 'g')
    if method =~ '\<void\>'
        let ret = ''
    else
        let ret = 'return '
    endif
    if exists('g:delegate')
        let delegate = g:delegate
    else
        let delegate = 'delegate'
        echo 'Set g:delegate to use a name other than "delegate"'
    endif
    let text = ret . delegate . '.' . name . '(' . args . ');'
    exec insert
    call Normal('o' . text)
    call Normal('^')
endfunction


function! Input2(prompt, default)
    let input = input(a:prompt . ': ', a:default)
    echo "\r"
    return input
endfunction


" bk - save a backup copy of current file
" ,bk - view saved backup copies (of all files)
nmap bk :echo system('backup.pl "' . expand("%:p") . '"')<cr>
nmap ,bk :echo system('backup.pl -vi "' . expand("%:p") . '"')<cr>

" This is used by backup.pl
function! RestoreInit()
    let path = expand("%:p")
    let path = substitute(path, '\\', '/', 'g')
    call RestoreEnter()
    exec "autocmd BufEnter " . path . " call RestoreEnter()"
    call append(0, '# r  -> restore file')
    call append(1, '# di -> diff backup with original')
    call append(2, '# dd -> delete backup file')
    call append(3, '')
    if !Update(1) | return | endif
    call SetFileType('ls')
"    syntax match txtComment "#.*"
"    highlight link txtComment Comment
endfunction

function! RestoreEnter()
    call CdToDir()
    call AddBufRestore(
        \ SaveMap("r",     ":call RestoreFile('r')<cr>")
        \ . SaveMap("di",    ":call RestoreFile('di')<cr>")
        \ . SaveMap("dd",    ":call RestoreFile('dd')<cr>dd")
        \ . SaveMap(".",     ":call RestoreFile('dd')<cr>dd")
        \ . SaveMap("<del>", ":call RestoreFile('dd')<cr>dd")
        \ )
endfunction

function! RestoreFile(op)
    let name = substitute(getline('.'), '.* ', '', '')
    let dir = expand('%:h')
    let full = dir . '/' . name
    if a:op == 'di'
        echo 'diff ' . name
        call system('backup.pl -diff "' . full . '"')
    elseif a:op == "r"
        echo 'restore ' . name
        call system('backup.pl -restore "' . full . '"')
    elseif a:op == "dd"
        echo 'delete ' . name
        call system('backup.pl -delete "' . full . '"')
    else
        call Error('Unknown op: ' . op)
    endif
endfunction

" ClearQuest
"Help 'cq - go to ClearQuest defect under cursor'
"Help 'ce - go to ClearQuest escalation under cursor'
"nmap cq :call GoClearQuest()<cr>
"nmap ce :call GoClearQuest('-escalation')<cr>
"function! GoClearQuest(...)
"    let opt = a:0 == 0 ? '' : a:1
"    let id = GetWord()
"    if id =~ '^\d\+$'
"        let id = printf('RATLC%08d', id)
"    elseif id =~? '^ratlc\d\+$'
"        let id = toupper(id)
"    else
"        return Warning('Not a RATLC id: ' . id)
"    endif
"    echo id
"    call System('view_defect.pl ' . opt . ' ' . id)
"endfunction

" Find RATLC change request under cursor and view in firefox, using CQ web client
" in beaverton replica.
" NOTE: this won't find other ratlc records, e.g. escalations.
"nmap cQ :call GoClearQuest()<cr>
"function! GoClearQuest()
"    let id = expand('<cword>')
"    if id =~ '^\d\+$'
"        let id = printf('RATLC%08d', id)
"    elseif id =~? '^ratlc\d\+$'
"        let id = toupper(id)
"    else
"        echo 'Not a RATLC id: ' . id
"        return
"    endif
"    echo id
"    let url = 'https://sus-or1ratljw1.beaverton.ibm.com/cqweb/main'
"        \ . '?command=GenerateMainFrame'
"        \ . '&service=CQ'
"        \ . '&schema=CQMS.RATIONALC.BEAVERTON'
"        \ . '&contextid=RATLC'
"        \ . '&entityDefName=ChangeRequest'
"        \ . '&entityID=' . id
"    let browser = 'C:\PROGRA~1\MOZILL~1\firefox.exe'
"    echo system(browser . ' "' . url . '"')
"endfunction

" clearcase stuff

if 0
"nmap ,ci :!ct ci %<cr>,re
Help ',ci - clearcase checkin'
"nmap ,ci :echo Cleartool("ci %")<cr>,re
"nmap ,ci :!cleartool ci %<cr>,re
nmap ,ci :call Checkin()<cr>
Help ',CI - clearcase GUI checkin of current dir'
nmap ,CI :echo Cleartool("lsco -g " . Dir(), 1)<cr>
"nmap ,ca ,DI:!newact<space>
nmap ,ca :call NewAct()<cr>
Help ',CA - show the current activity'
nmap ,CA :call Bold(Chomp(substitute(Cleartool("lsact -cact"), '^\d\d-\S* \+', '', '')))<cr>
nmap ,co :call Checkout()<cr>
nmap ,cu :call UndoCheckout()<cr>
"nmap ,cd :call ClearDiff(0)<cr>
"nmap ,CD :call ClearDiff(1)<cr>
nmap ,cl :call ListCheckouts()<cr>
nmap ,cs :echo Cleartool("describe -short %")<cr>
nmap ,cv :echo Cleartool("lsvtree -g %", 1)<cr>
nmap <silent> ei :call EditCI()<cr>

function! NewAct()
    call CdToDir()
    let desc = Input('newact ')
    if desc != ''
        echo System('newact ' . desc)
    endif
endfunction

" Run a cleartool command.  If the 2nd arg is set, use "start" and don't
" try to capture output.
function! Cleartool(cmd, ...)
    let start = a:0 > 0 && a:1
    let cmd = substitute(a:cmd, '%', escape(expand('%'), " \\"), 'g')
    if start
        silent exec "!start cleartool " . cmd
        return ""
    else
"        return system("vimct " . cmd)
        return system('cleartool ' . cmd . ' 2>&1')
    endif
endfunction

function! ListCheckouts()
    let path = expand("%:p")
    let path = substitute(path, '\\r_.*', '', '')
    call Cleartool("lsco -g " . path, 1)
endfunction

function! Checkin()
    call ExpectChange(1)
    let x = Cleartool("ci -nc %")
    let x = Chomp(x)
    if v:shell_error != 0
        return Warning(x)
    endif
    set noro
    if !&modified
        edit %
    endif
    if !Update(1) | return | endif
    call ExpectChange(0)
    echo x
endfunction

function! Checkout()
    call ExpectChange(1)
    let x = Cleartool("co -nc %")
    let x = Chomp(x)
    if v:shell_error != 0
        return Warning(x)
    endif
    set noro
    if !&modified
        edit %
    endif
    if !Update(1) | return | endif
    call ExpectChange(0)
    echo x
endfunction

function! UndoCheckout()
    call ExpectChange(1)
    let x = Cleartool('unco -keep "%"')
    let x = Chomp(x)
    if v:shell_error != 0
        return Warning(x)
    endif
    edit %
    call ExpectChange(0)
    echo x
endfunction

function! ClearDiff(full)
    call CdToDir()
    let path = '.'
"    if expand("%:t") == "_explorer_"
"        let path = getcwd()
"    else
"        let path = expand("%:p:h")
"    endif
    if a:full
        " start new vim in this case
        let cmd = "page nd -vob " . expand("%:h")
"        let cmd = "page nd -r "
"            \ . substitute(path, '\(\\r_[^\\]*\)\\.*', '\1', '')
        echo system(cmd)
    else
        let cmd = 'page nd ' . @%
        echo system(cmd)
"        let pred = system('nd -get ' . @% . ' 2>&1')
"        if pred =~ '^\*\*\*'
"            return Warning(pred)
"        endif
"???
"        "TODO save & restore
"        set diffexpr=NdDiff()
"        call VimDiff('dummy')
"        set diffexpr=
    endif
endfunction


"??? doesn't work???
"        set diffexpr=NdDiff()
"function NdDiff()
"echo "??? v:fname_in = <".v:fname_in.">"
"echo "??? v:fname_out = <".v:fname_out.">"
"    silent execute "!nd " . v:fname_in . ' > ' . v:fname_out
"endfunction

" Edit checked in version of file.
function! EditCI()
    if !Update() | return | endif
    let pred = system('nd -get ' . @% . ' 2>&1')
    if v:shell_error
        return Warning(pred)
    endif
    call EditFT(pred)
endfunction

" Edit corresponding integration file
function! EditInt()
    let path = expand("%:p")
    let vrel = substitute(path, 'C:\\ViewStore\\', '', '')
    if vrel == path
        return Warning("not in C:\\ViewStore: " . path)
    endif
    let vtag = matchstr(vrel, '^[^\\]*')
    let vrel = substitute(vrel, '^[^\\]*\\', '', '')
    let vint = vtag . "_integration"
    let int = "M:\\" . vint . "\\" . vrel
    if !filereadable(int)
        " maybe it's not there because the view hasn't been started
        call system("cleartool startview " . vint)
    endif
    call Edit(int)
endfunction

endif

" cvs commands

Help ',ci - commit the current file'
nmap ,ci :call CVS_Commit()<cr>
function! CVS_Commit()
    if !Update() | return | endif
    call CdToDir()
    if &filetype == 'diff'
        " GetFile
        " check it's okay
        " cd to that dir
    endif

    let status = System('cvs status ' . @%)
    if status =~ 'Status: Unknown'
        return Warning('not a controlled file: ' . @%)
    elseif status =~ 'Status: Up-to-date'
        return Warning('not changed: ' . @%)
    elseif status !~ 'Status: Locally Modified'
        return Warning('unknown status: ' . status)
    endif
    call TempWin(3, "Checkin message")
    "TODO enter insert mode
    nmap <buffer> <silent> qq :call CVS_Commit_End(0)<cr>
    nmap <buffer> <silent> <esc> :call CVS_Commit_End(1)<cr>
endfunction

function! CVS_Commit_End(cancel)
    %yank
    let msg = @"
    if a:cancel
        if Input('Cancel checkin? ', 'y') == 'y'
            let @a = msg
            close
            return Warning('Canceled (message in "a)')
        endif
        return
    endif
    close
    let tmp = 'C:\Temp\tmp\ci.txt'
    call Write(msg, tmp)
    echo System('cvs commit -F ' . tmp . ' ' . @%)
endfunction


"Help ',cr - review last 5 CVS changes to current file'
"nmap ,cr :call CVS_Review()<cr>
"function! CVS_Review()
"    call system('page cvs_diff.pl -num=5 -review ' . @%)
"endfunction
"
"Help ',CR - review CVS changes to current file'
"nmap ,CR :call CVS_Review()<cr>
"function! CVS_Review()
"    call system('page cvs_diff.pl -num=5 -review ' . @%)
"endfunction

"nmap ,nd ,cd
"nmap ,ND ,CD
"
"Help ',cd - diff current file with CVS version'
"Help ',CD - diff current CVS project with latest version'
"nmap <silent> ,cd :call CVS_Diff('')<cr>
"nmap <silent> ,CD :call CVS_Diff(' -ignore=launch -root')<cr>
"function! CVS_Diff(opts)
"    let cmd = 'page cvs_diff.pl ' . a:opts . ' "' . @% . '"'
"    echo cmd
"    call system(cmd)
"endfunction

"Help ',cp - format the current paragraph'
"nmap ,cp :call ChangeParagraph()<cr>
"function! ChangeParagraph()
"    if &textwidth == 0
"        let save = SaveSet("textwidth", 72)
"    else
"        let save = ""
"    endif
"    normal! gqap
"    exec save
"endfunction

Help ',xs - split current line of XML after first tag and before last'
nmap ,xs s>s<
nmap ,XS s>s<gql

Help ',xd - delete current XML/HTML tag'
nmap ,xd :call XMLDelete()<cr>
"TODO: this only works if % for xml is implemented -- how to check
function! XMLDelete()
    let char = GetChar()
    " Move off of < or > onto tag itself
    if char == '<'
        call Norm('l')
    elseif char == '>'
        call Norm('h')
    endif
    if BeforeCursor() !~ '<[^<>]*$'
        return Error('Not on xml/html tag')
    endif
    " Check for <foo.../> tag
    call Norm('F<%')
    let before = BeforeCursor()
    if before =~ '/$'
        call Norm('d``x')
    else
        call Norm('%l') " to start of start/end tag
        if GetChar() == '/'
            call Norm2('%') " on end tag , go to start
        endif
        " Norm2 allows % and jump list to work
        call Norm2('ma%') " to start of end tag
        call Norm('hdf>') " delete end tag
        call Norm2("\<c-o>") " NOTE: must be double quote!
        call Norm('hdf>') " delete start tag
    endif
    if getline('.') !~ '\S'
        call Norm('dd')
    endif
endfunction

Help ',xm - add an XML tag'
nmap ,xm :call XMLAdd()<cr>
function! XMLAdd()
    let id = input("XML tag? ")
    echo "\r"
    if id == ""
        return Warning("Canceled")
    endif
    call Norm("o<".id.">\<cr></".id.">\<esc>")
endfunction

Help ',xw - add an XML tag around current word'
nmap ,xw viw,x

Help ',XW - add an XML tag around current big word'
nmap ,XW viW,x

Help 'V ax - add an XML tag around highlighted text'
Help 'V ,x - add an XML tag around highlighted text'
vmap ,x :<c-u>call XMLAddV()<cr>
function! XMLAddV()
    let id = input("XML tag? ")
    echo "\r"
    if id == ""
        return Warning("Canceled")
    endif
    call PushLoc()
    let save = SaveSet('paste', 1)  " prevent indenting
    if line("'<") < line("'>") || col("'>") > 999999
        " line-oriented -- insert new lines
        call Norm("'>o</" . id . ">\<esc>'<O<" . id . ">\<esc>='>")
    else
        call Norm("`>a</" . id . ">\<esc>`<i<" . id . ">\<esc>")
        '<,'>=
    endif
    exec save
endfunction

Help '[<space> ]<space> - find prev/next line with less indent than current'
nmap [<space> :call FindIndent('b', 1)<cr>
nmap ]<space> :call FindIndent('', 1)<cr>
"function! FindIndent(dir)
"    let in = matchstr(getline('.'), '^\s*')
"    if in =~ '\t'
"        return Warning("can't use [<space> or ]<space> on lines with a tab")
"    endif
"    if in == ''
"        return Warning("no indent on this line")
"    endif
"    let i = strlen(in) - 1
"    call search('^ \{,' . i . '}\S', a:dir == 1 ? '' : 'b')
"    call Norm('^')
"endfunction


Help '[= ]= - find prev/next line with same indent as current'
nmap [= :call FindIndent('b', 0)<cr>
nmap ]= :call FindIndent('', 0)<cr>
" Find line with certain indentation relative to current one
" dir is direction ('' - forward, 'b' - backwards)
" less true means want less indent than current
function! FindIndent(dir, less)
    call PushLoc()
    let in = matchstr(getline('.'), '^\s*')
    if in =~ '\t' && in =~ ' '
        return Warning("can't use [<space> or ]<space> or [= or ]= on lines with mixed indent")
    endif
    if a:less
        if in == ''
            return Warning("no indent on this line")
        endif
        let i = strlen(in) - 1
        let pat = '\s\{,' . i . '}'
    else
        let pat = in
    endif
    " keep searching until finding line without comment
    let s_opt = 's'
    while 1
        call Norm('0')  " else backward search might find this line
        call search('^' . pat . '\S', s_opt . a:dir)
        if getline('.') !~ '^\s*\(//\|\*/\|/\*\)'
            break
        endif
        let s_opt = '' " this is only for first time through
    endwhile
    call Norm('^')
    let new_in = matchstr(getline('.'), '^\s*')
    if new_in =~ '\t' && new_in =~ ' '
        return Warning("found line with mixed indent -- result is probably wrong")
    endif
endfunction


"???
"Help ',xx - match an XML tag'
"nmap ,xx :call XMLMatch()<cr>
"function! XMLMatch()
"    let x = GetAfter()
"    if x =~ '^\s*<'
"        let adjust = strlen(matchstr(x, '\s*'))
"    else
"        let y = GetBefore()
"        if y =~ '<'
"            let adjust = -strlen(matchstr(y, '<[^<]*$'))
"        else
"            return Warning("no '<' on current line")
"        endif
"    endif
"    let col = col('.') + adjust
"    let z = system("xml_match.pl " . expand("%") . " " . line(".") . ' ' . col)
"    let z = Chomp(z)
"    if z =~ '^\*\*\*'
"        return Warning(z)
"    endif
"    call GotoLineCol(z)
"endfunction

Help ',vd - Vim Diff'
nmap ,vd :call VimDiff()<cr>
function! VimDiff(...)
    if &diff  " already doing diff, just update
        diffupdate
        return
    endif
    " prompt for file if not supplied
    if a:0 == 0
        call histadd("input", @%)
        let f = input("File to diff against? ")
        echo "\r"
        if f == ""
            return Warning("Canceled")
        endif
    else
        let f = a:1
    endif

    let save = SaveSet('columns', 2*&columns)
        \ . SaveSet('diff')
        \ . SaveSet('scrollbind')
        \ . SaveSet('scrollopt')
        \ . SaveSet('wrap')
        \ . SaveSet('foldmethod')
        \ . SaveSet('foldlevel')
        \ . SaveSet('foldcolumn')
        \ . SaveMap('[c', '')
        \ . SaveMap(']c', '')
    " when we close the other file, restore everything
    let f_pat = substitute(f, '\\', '/', 'g')
    augroup diff_restore
        autocmd!
        exec "autocmd BufUnload " . f_pat . " call DiffRestore('" . save . "')"
    augroup end
    exec 'vertical diffsplit ' . f
    " return to the original file; go to top; close folds
    call Norm("\<c-w>x1GzM")
endfunction
function! DiffRestore(x)
"    call GUImsg('DiffRestore: ' . a:x)
    call WinGoto(1)  " restore state in original window
    exec a:x
"    call Norm("zE")  " eliminate folds
    augroup diff_restore
        autocmd!
    augroup end
endfunction

" info about syntax highlighting under cursor
nmap ,sy :call SyntaxInfo()<cr>
function! SyntaxInfo()
    let name = GetSyntaxName()
    echo "name of syntax item:" name
    let transparent = GetSyntaxTransparent()
    if transparent != name
        echo "transparent item:" transparent
    endif
    let trans = GetSyntaxTranslated()
    echo "translates to:" trans
endfunction

" Syntax name
function! GetSyntaxName()
    let id = synID(line('.'), col('.'), 1)
    return synIDattr(id, 'name')
endfunction

" Syntax name
function! GetSyntaxTransparent()
    let id = synID(line('.'), col('.'), 0)
    return synIDattr(id, 'name')
endfunction

" Translated syntax name
function! GetSyntaxTranslated()
    let id = synID(line('.'), col('.'), 1)
    return synIDattr(synIDtrans(id), 'name')
endfunction

Help 'do - mark current item as done'
nmap do :call TodoDone()<cr>
" If on line starting with TODO: , change to DONE: in place
" Else move to end and mark done
function! TodoDone()
    let curr = getline('.')
    if curr =~ 'TODO:'
        s/TODO:/DONE:/
    else
        " in todo list at top: move to bottom to mark done
        let pos = GetPos()
        call InsertDateEnd() " in case not there
        call Norm(pos)
        call Norm("dapGpIDONE: \<esc>")
    endif
endfunction

"Help ',DT - insert a line with the date on it at end of file'
"Help 'DY - insert a line with the date on it at end of file'
"nmap DY ,DT
"nmap ,DT :call InsertDateEnd()<cr>
"function! InsertDateEnd()
"    " ensure file ends with blank line
"    $
"    if getline('.') !~ '^\s*$'
"        call append('.', '')
"        $
"    endif
"    let date = GetDate()
"    if search('^' . date . '$', 'bn') == 0
"        " date not there yet
"        call append('.', '')
"        call append('.', date)
"        $
"    endif
"    echo date
"endfunction
"
"Help ',dt - insert a line with the date on it'
"Help 'dy - insert a line with the date on it'
"nmap dy ,dt
"nmap ,dt :call InsertDate()<cr>
"function! InsertDate()
"    call append('.', GetDate())
"endfunction
"
"" Return a dated separator line.
"function! GetDate()
"    return strftime('--- %Y %b %d, %a')
"endfunction

Help ',fl - format long lines individually'
nnoremap ,fl :call FormatLongLines()<cr>
function! FormatLongLines()
    let pos = GetPos()
    let pat = '.\{' . &columns . ',}'
    let changed = 0
    call cursor(1, 1)
    while search(pat, 'cW') > 0
        call Norm('gqgq$')
        let changed += 1
    endwhile
    call Norm(pos)
    echo 'formatted ' . changed . ' lines'
endfunction

nnoremap ,fx :call FormatXML('')<cr>
nnoremap ,FX :call FormatXML('-width=0')<cr>
function! FormatXML(opt)
    call System('format_xml ' . a:opt . ' ' . @%)
    call ReEdit()
endfunction

Help ',hc - change html tags to lower case'
Help 'v ,hc - change html tags to lower case'
nmap ,hc :let tmp = @/<cr>:s/<\/\=\w\+/\L&/g<cr>:let @/ = tmp<cr>
vmap ,hc :<c-u>let tmp = @/<cr>:'<,'>s/<\/\=\w\+/\L&/g<cr>:let @/ = tmp<cr>

Help ',hf - fix up current line of html'
Help 'v ,hf - fix up selected lines of html'
nmap ,hf v,hf
vmap ,hf :<c-u>call FixHtml()<cr>
function! FixHtml()
    silent! '<,'>s#\(\S\)</a>\(\S\)#\1\2#g
    silent! '<,'>s#>\s*<#\>\<#g
    " <style> contents (just guessing at: { ... : ... }
    silent! '<,'>s/\({[^{}]*:[^{}]*}\)\s*\(\S\)/\1\2/g
    " <td/> => <td> </td> -- vim formatting has a problem otherwise
    silent! '<,'>s#<td/>#<td></td>#g
    silent! '<,'>s#\(\S\)\s*\(<[^/]\)#\1\2#g
    silent! '<,'>s#\(</[^>]*>\)\s*\(\S\)#\1\2#g
    " <foo> asdfasdf
    silent! '<,'>s#\(<[^<>]*>\)\s*\([^<> \t][^<>]*\)$#\1\2#g
    " asdf </foo>
    silent! '<,'>s#^\([^<>]*\S[^<> \t]*\)\s*\(<[^<>]*>\)#\1\2#g
    silent! '<,'>s#\%x01#</a>#g
    call Norm("'<='>")
endfunction

Help ',HF - format an html file'
nmap ,HF :call FormatHtml()<cr>
function! FormatHtml()
    set sw=2 expandtab ft=html
    silent! %s#\(\S\)</a>\(\S\)#\1\2#g
    silent! %s#>\s*<#\>\<#g
    " <style> contents (just guessing at: { ... : ... }
    silent! %s/\({[^{}]*:[^{}]*}\)\s*\(\S\)/\1\2/g
    " <td/> => <td> </td> -- vim formatting has a problem otherwise
    silent! %s#<td/>#<td></td>#g
    silent! %s#\(\S\)\s*\(<[^/]\)#\1\2#g
    silent! %s#\(</[^>]*>\)\s*\(\S\)#\1\2#g
    " <foo> asdfasdf
    silent! %s#\(<[^<>]*>\)\s*\([^<> \t][^<>]*\)$#\1\2#g
    " asdf </foo>
    silent! %s#^\([^<>]*\S[^<> \t]*\)\s*\(<[^<>]*>\)#\1\2#g
    silent! %s#\%x01#</a>#g
    silent! g/<[^<>]*= *$/join
    silent! %s/\(<[^<>]*=\)  */\1/g
    call Norm("1G=G")
endfunction

vmap mf :<c-u>call MailFormat()<cr>
function! MailFormat()
    '<,'>write! c:\temp\mail.txt
    let l = line("'<")-1
    call append(l, '')
    '<,'>delete
    -
    read !mail_fmt c:\temp\mail.txt
    exec l
    delete
endfunction

Help 'V ,bu - replace leading "-" or "." with bullet'
vmap ,bu :s/^\(\s*\)[-.]\(\s\)/\1•\2/<cr>

Help ',bu - replace leading "-" or "." with bullet in whole file'
nmap ,bu :%s/^\(\s*\)[-.]\(\s\)/\1•\2/<cr>

vmap ,te :<c-u>call ToHtml(line("'<"), line("'>"))<cr>

" Get highlighted text and convert to html in clipboard
function! ToHtml(start, end)
    let lnum = a:start
    let body = ''
    let style = ''
    while lnum <= a:end
        let line = getline(lnum)

        " Loop over each character in the line
        let col = 1
        let len = strlen(line)
        while col <= len
            let startcol = col " The start column for processing text
            let id = synIDtrans(synID(lnum, col, 1))
            let col = col + 1
            " Speed loop (it's small - that's the trick)
            " Go along till we find a change in synID
            while col <= len && id == synIDtrans(synID(lnum, col, 1))
                let col = col + 1
            endwhile
            let str = strpart(line, startcol-1, col-startcol)
            let str = substitute(str, '<', '\&lt;', 'g')
            let str = substitute(str, '>', '\&gt;', 'g')
"            let id = synIDtrans(id)
            if id != 0 && str =~ '\S'
                let name = synIDattr(id, 'name')
                let color = synIDattr(id, 'fg')
                if color != '' && style !~ '\.' . name . ' {'
                    let style = style . '.' . name . ' {color:' . color . "}\n"
                endif
                let ht = '<span class="' . name . '">' . str . '</span>'
                let str = ht
            endif
            let body = body . str
        endwhile
        let body = body . "\n"
        let lnum = lnum + 1
    endwhile
    let html = "<html>\n"
    let html = html . "<head>\n"
    let html = html . "<style type='text/css'>\n"
    let html = html . style
    let html = html . "</style>\n"
    let html = html . "</head>\n"
    let html = html . "<body>\n"
    let html = html . "<pre>\n"
    let html = html . body
    let html = html . "</pre>\n"
    let html = html . "</body>\n"
    let html = html . "</html>\n"
    let @* = html
endfunction

map mm :call FixMessage()<cr>
function! FixMessage()
    let match = search('Messages\.', 'cnW', line('.')+10)
    if match == 0
        return Warning('No match for /Messages\./ found in next 10 lines')
    endif
    let new_line = substitute(getline(match), '^\(\s*\).*\(Messages\.\w*\).*', '\1Messages.get(\2)', '')
    call append(line('.')-1, new_line)
    -
endfunction

" Regular expressions (regex)
" Capability                    in Vimspeak     in Perlspeak ~
" ----------------------------------------------------------------
" force case insensitivity      \c              (?i)
" force case sensitivity        \C              (?-i)
" backref-less grouping         \%(atom\)       (?:atom)
" conservative quantifiers      \{-n,m}         *?, +?, ??, {}?
" zero or one                   \= or \?        ?
" 0-width match                 atom\@=         (?=atom)
" 0-width non-match             atom\@!         (?!atom)
" 0-width preceding match       atom\@<=        (?<=atom)
" 0-width preceding non-match   atom\@<!        (?<!atom)
" match without retry           atom\@>         (?>atom)

" n to m, as many as possible   \{n,m}
" n to m, as few as possible    \{-n,m}
