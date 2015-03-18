set sw=4 ts=4 expandtab autoindent cindent
set cinkeys-=0#

" this colorscheme is better on a light background
colorscheme delek

" Make the cursor be a block in cygwin
if &term == 'cygwin'
    let &t_ti.="\e[1 q"
    let &t_SI.="\e[5 q"
    let &t_EI.="\e[1 q"
    let &t_te.="\e[0 q"
endif

" === Mappings

nnoremap ,rc :so ~/.vimrc<cr>

nnoremap qq :wq<cr>
nnoremap zz :update<cr>

nnoremap qf :update<cr>:cd %:p:h<cr>:e 
nnoremap ea :e#<cr>

" reverse meaning of v and V, except when followed by certain motions
nnoremap v V
nnoremap V v
nnoremap vl vl
nnoremap vh vh
nnoremap v$ v$
nnoremap vw vw
nnoremap ve ve
nnoremap vi vi

nnoremap <space> <c-f>
nnoremap <c-space> <c-b>

"NOTE use <c-q> for quoting
" in insert mode, paste selection
imap <c-v> <c-r><c-o>*
" in normal mode, paste selection line-oriented
nmap <c-v> :put *<cr>

" Tab in insert mode completes a partial word
inoremap <tab> <c-r>=InsertTab()<cr>
inoremap <s-tab> <c-x><c-p>
function! InsertTab()
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

source ~/vim/comment.vim
