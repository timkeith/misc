" To reload this file:
" :unlet b:loaded_html | set ft=html
if exists('b:loaded_html')
    finish
endif
let b:loaded_html=1

highlight link htmlArg Identifier

"set columns=100
"set lines=50
set shiftwidth=2

Help ',ul - html: insert a new unordered list'
nmap <buffer> ,ul o<ul><cr><li><cr></li><cr><li><cr></li><cr></ul><up><up><up><up><end><cr>
Help ',ol - html: insert a new ordered list'
nmap <buffer> ,ol o<ol><cr><li><cr></li><cr><li><cr></li><cr></ol><up><up><up><up><end><cr>
Help ',li - html: insert a new list item'
nmap <buffer> ,li o<li><cr></li><up><cr>
Help ',tr - html: insert a new table row'
nmap <buffer> ,tr o<tr><cr><td><cr></td><cr></tr><up><up><end><cr>
Help ',td - html: insert a new table element'
nmap <buffer> ,td o<td><cr></td><up><cr>
Help ',br - html: insert a new <br/> element'
nmap <buffer> ,br o<br/><cr>

imap <c-b>ul <esc>,ul
imap <c-b>ol <esc>,ol
imap <c-b>li <esc>,li
imap <c-b>tr <esc>,tr
imap <c-b>td <esc>,td
imap <c-b>br <esc>,br

Help 'V ,fl - convert listed separated by newline or <br> to bulleted'
vmap <buffer> ,fl :<c-u>call HtmlFixList()<cr>
function! HtmlFixList()
    '<
    if search('<br/*>', 'nW', line("'>")) == 0
        " every line is a list item
        '<,'>-1s#$#\</li\>\<li\>#g
    else
        " list items are separated by <br/>
        '<,'>s#<br/*>#\</li\>\<li\>#g
    endif
    call append(line("'>"), '</ul>')
    call append(line("'>"), '</li>')
    call append(line("'<")-1, '<ul>')
    call append(line("'<")-1, '<li>')
    let l1 = line("'<") - 2
    let l2 = line("'>") + 2
    call Norm(l1 . 'G=' . l2 . 'G')  " format
endfunction


"vmap <buffer> ,ul !perl.exe -S html_filter.pl -ul<cr>
vmap <buffer> ,ul :<c-u>call HtmlFilter('ul')<cr>

function! HtmlFilter(kind)
    exec "'<,'>!perl.exe -S html_filter.pl -" . a:kind
    call Norm("'[=']")
endfunction
