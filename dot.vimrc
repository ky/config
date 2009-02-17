" .vimrc


" options "{{{1

set nocompatible

if has('win16') || has('win32') || has('win64')
  let s:WINDOWS = 1
else
  let s:WINDOWS = 0
endif

syntax on
filetype indent plugin on
set hidden
set nobackup
set swapfile
set showmode
set showcmd
set noshowmatch
set autoindent
set smartindent
set ignorecase
set smartcase
set hlsearch
set incsearch
set wrapscan
set laststatus=2
set cmdheight=1
set noruler
set wildmenu
set wildmode=list:longest
set backspace=2
set nonumber
set nolist
set listchars=tab:>-,extends:<,trail:-,eol:<
set nowrap
set tags=./tags,./TAGS,tags,TAGS
set nopaste
set history=100
set formatoptions=croqnM1
set runtimepath&
if s:WINDOWS
  set runtimepath+=$VIM/chalice
else
  set runtimepath+=$HOME/chalice
endif
set diffopt=filler,iwhite
let &statusline = ''
let &statusline .= '%<%m%r%h%w'
let &statusline .= '['
let &statusline .= '%{&fileencoding != "" ? &fileencoding : &encoding}'
let &statusline .= '%{":" . &fileformat}'
let &statusline .= ']'
let &statusline .= '%y %f%=0x%B(%b) %l/%L %c%V%6P'
set cinoptions=:0,g0,t0,(0
set nrformats=hex




" colorscheme "{{{1

if !exists('g:colors_name')
  if has('gui_running')
    colorscheme xoria256
  else
    colorscheme console
  endif
endif




" commands {{{1

command! -nargs=? -bang Cp932 edit<bang> ++enc=cp932 <args>
command! -nargs=? -bang Euc edit<bang> ++enc=euc-jp <args>
command! -nargs=? -bang Iso2022jp edit<bang> ++enc=iso-2022-jp <args>
command! -nargs=? -bang Utf8 edit<bang> ++enc=utf-8 <args>

command! -nargs=? -bang Jis Iso2022jp<bang> <args>
command! -nargs=? -bang Sjis Cp932<bang> <args>




" autocommands {{{1

augroup MyAutoCommand
  autocmd!
augroup END


function! s:ruby_settings()
  let g:rubycomplete_buffer_loading = 1
  let g:rubycomplete_rails = 1
  let g:rubycomplete_classes_in_global = 1
  setlocal omnifunc=rubycomplete#Complete
  setlocal expandtab
  setlocal tabstop=8
  setlocal shiftwidth=2
  setlocal softtabstop=2
  setlocal fileencoding=utf-8
endfunction


function! s:do_command(cmd, ...)
  if exists(':' . a:cmd) == 2 && (a:0 ? a:1 ==# bufname('%') : 1)
    silent execute a:cmd
  endif
endfunction


autocmd MyAutoCommand FileType ruby,eruby
      \ call s:ruby_settings()
autocmd MyAutoCommand FileType html,xhtml,xml,vim,d,zsh
      \ setlocal expandtab tabstop=8 shiftwidth=2 softtabstop=2
autocmd MyAutoCommand FileType c,cpp,java
      \ setlocal tabstop=4 shiftwidth=4 softtabstop=0
autocmd MyAutoCommand QuickfixCmdPost
      \ make,grep,grepadd,vimgrep,vimgrepadd
      \ cwindow
autocmd MyAutoCommand QuickfixCmdPost
      \ lmake,lgrep,lgrepadd,lvimgrep,lvimgrepadd
      \ lwindow
autocmd MyAutoCommand CmdwinEnter *
      \ call s:do_command('AutoComplPopLock')
autocmd MyAutoCommand CmdwinLeave *
      \ call s:do_command('AutoComplPopUnlock')


" load smartfinder
runtime! plugin/smartfinder.vim
if exists('g:loaded_smartfinder')
  function! s:smartfinder_bufname()
    return smartfinder#get_option('bufname')
  endfunction

  autocmd MyAutoCommand BufEnter *
        \ call s:do_command('AutoComplPopDisable', s:smartfinder_bufname())
  autocmd MyAutoCommand BufFilePost *
        \ call s:do_command('AutoComplPopDisable', s:smartfinder_bufname())
  autocmd MyAutoCommand BufLeave *
        \ call s:do_command('AutoComplPopEnable', s:smartfinder_bufname())
endif





" encoding {{{1

if &encoding !=# 'utf-8'
  set encoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  " ton doru
  let s:test_code = "\x88\x64\x87\x6a"
  let s:conv_result = "\xad\xc5\xad\xcb"

  if iconv(s:test_code, 'cp932', 'eucjp-ms') ==# s:conv_result
    let s:enc_euc = 'eucjp-ms,euc-jp'
    let s:enc_jis = 'iso-2022-jp-3'
  elseif iconv(s:test_code, 'cp932', 'euc-jisx0213') ==# s:conv_result
    let s:enc_euc = 'euc-jisx0213,euc-jp'
    let s:enc_jis = 'iso-2022-jp-3'
  endif

  unlet s:test_code
  unlet s:conv_result

  let &fileencodings = 'ucs-bom'
  if &encoding ==# 'utf-8'
    "let &fileencodings .= ',' . 'ucs-2le'
    "let &fileencodings .= ',' . 'ucs-2'
    let &fileencodings .= ',' . s:enc_jis 
    let &fileencodings .= ',' . s:enc_euc 
    let &fileencodings .= ',' . 'cp932'
    let &fileencodings .= ',' . 'utf-8'
  elseif &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
    let &fileencodings .= ',' . 'ucs-2le'
    let &fileencodings .= ',' . 'ucs-2'
    let &fileencodings .= ',' . 'utf-8'
    let &fileencodings .= ',' . s:enc_jis
    let &fileencodings .= ',' . 'cp932'
    let &fileencodings .= ',' . s:enc_euc
    let &encoding = split(s:enc_euc, ',')[0]
  else
    let &fileencodings .= ',' . 'ucs-2le'
    let &fileencodings .= ',' . 'ucs-2'
    let &fileencodings .= ',' . 'utf-8'
    let &fileencodings .= ',' . s:enc_jis
    let &fileencodings .= ',' . s:enc_euc 
    let &fileencodings .= ',' . 'cp932'
  endif
  unlet s:enc_euc
  unlet s:enc_jis
endif
autocmd MyAutoCommand BufReadPost * 
      \ if &modifiable && search("[^\x01-\x7f]", 'cnw') == 0 |
      \   setlocal fileencoding=  |
      \ endif
set ambiwidth=double




" mappings {{{1

function! s:toggle_option(option_name)
  " toggle
  execute "setlocal " . a:option_name . "!"
  " show status
  execute "setlocal " . a:option_name . "?"
endfunction


" smartword.vim
" http://www.vim.org/scripts/script.php?script_id=2470
runtime! plugin/smartword.vim
if exists('g:loaded_smartword')
  map w <Plug>(smartword-w)
  map b <Plug>(smartword-b)
  map e <Plug>(smartword-e)
  map ge <Plug>(smartword-ge)
  noremap W w
  noremap B b
  noremap E e
  noremap gE ge
endif

" nmap
nnoremap gt :<C-u>bnext<CR>
nnoremap gT :<C-u>bprevious<CR>
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>
nnoremap <C-]> g<C-]>
nnoremap g<C-]> <C-]>
noremap ' `
noremap ` '

nnoremap <Space> <Nop>
if s:WINDOWS
  nnoremap <Space>, :<C-u>edit $VIM/_gvimrc<CR>
  nnoremap <Space>. :<C-u>edit $VIM/_vimrc<CR>
else
  nnoremap <Space>. :<C-u>edit $HOME/.vimrc<CR>
endif

nnoremap <Space>c  <Nop>
nnoremap <Space>cc :<C-u>cclose<CR>
nnoremap <Space>d  <Nop>
nnoremap <Space>di :<C-u>vert diffsplit<Space>
nnoremap <Space>dt :<C-u>diffthis<CR>
nnoremap <Space>do :<C-u>diffoff<CR>
nnoremap <Space>du :<C-u>diffupdate<CR>
nnoremap <Space>e  <Nop>
nnoremap <Space>ee :<C-u>Euc<CR>
nnoremap <Space>eE :<C-u>Euc!<CR>
nnoremap <Space>ej :<C-u>Jis<CR>
nnoremap <Space>eJ :<C-u>Jis!<CR>
nnoremap <Space>es :<C-u>Sjis<CR>
nnoremap <Space>eS :<C-u>Sjis!<CR>
nnoremap <Space>eu :<C-u>Utf8<CR>
nnoremap <Space>eU :<C-u>Utf8!<CR>
nnoremap <Space>f  <Nop>
nnoremap <Space>fb :<C-u>SmartFinder buffer<CR>
nnoremap <Space>ff :<C-u>SmartFinder file --cache-clear<CR>
nnoremap <Space>fk :<C-u>SmartFinder bookmark<CR>
nnoremap <Space>h <C-w>h
nnoremap <Space>H :<C-u>vertical aboveleft split<CR>
nnoremap <Space><C-h> :<C-u>vertical topleft split<CR>
nnoremap <Space>j <C-w>j
nnoremap <Space>J :<C-u>belowright split<CR>
nnoremap <Space><C-j> :<C-u>botright split<CR>
nnoremap <Space>k <C-w>k
nnoremap <Space>K :<C-u>aboveleft split<CR>
nnoremap <Space><C-k> :<C-u>topleft split<CR>
nnoremap <Space>l <C-w>l
nnoremap <Space>L :<C-u>vertical belowright split<CR>
nnoremap <Space><C-l> :<C-u>vertical botright split<CR>
nnoremap <Space>n  :<C-u>cnext<CR>
nnoremap <Space>N  :<C-u>cprevious<CR>
nnoremap <Space>p  :<C-u>call <SID>toggle_option('paste')<CR>
nnoremap <Space>w  :<C-u>call <SID>toggle_option('wrap')<CR>
nnoremap <Space>s  <Nop>
nnoremap <Space>sh :<C-u>call <SID>toggle_option('hlsearch')<CR>
nnoremap <Space>so :<C-u>source %<CR>


" cmap
cnoremap <C-a> <Home>
cnoremap <C-f> <Right>
cnoremap <C-b> <Left>
cnoremap <C-d> <Delete>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>
cnoremap <C-j> <Nop>
set cedit=<C-o>




" plugins {{{1

" rails.vim 
" http://www.vim.org/scripts/script.php?script_id=1567
let g:rails_gnu_screen=1

" $VIMRUNTIME/plugin/matchparen.vim
" I don't use this plugin.
let g:loaded_matchparen = 1

" grep.vim
" http://www.vim.org/scripts/script.php?script_id=311
if has('mac')
  let g:Grep_Xargs_Options = '-0'
end

" vimball.vim
" http://www.vim.org/scripts/script.php?script_id=1502
if s:WINDOWS
  let g:vimball_home = '$VIM/vimfiles'
endif

" smartfinder.vim
" http://github.com/ky/smartfinder/tree/master
if exists('g:loaded_smartfinder')
  function! g:SmartFinderMapBookmarkKey()
    imap <buffer> / <Plug>SmartFinderBookmarkSelected
  endfunction


  function! g:SmartFinderUnmapBookmarkKey()
    call smartfinder#safe_iunmap('/')
  endfunction


  if s:WINDOWS
    let s:bookmark = [
          \ [ '.vim', '$VIM/vimfiles/' ],
          \ [ '.vim/autoload', '$VIM/vimfiles/autoload/' ],
          \ [ '.vim/doc', '$VIM/vimfiles/doc/' ],
          \ [ '.vim/plugin', '$VIM/vimfiles/plugin/' ],
          \ [ 'work', 'E:/work/' ]
          \]
  else
    let s:bookmark = [
          \ [ '.vim', '~/.vim/' ],
          \ [ '.vim/autoload', '~/.vim/autoload/' ],
          \ [ '.vim/doc', '~/.vim/doc/' ],
          \ [ '.vim/plugin', '~/.vim/plugin/' ],
          \ [ 'work', '~/work/' ],
          \ [ 'memo', '~/memo/' ]
          \]
  endif

  call smartfinder#set_mode_option('bookmark', 'bookmark_list', s:bookmark)
  call smartfinder#set_mode_option('bookmark', 'key_mappings',
        \ 'g:SmartFinderMapBookmarkKey')
  call smartfinder#set_mode_option('bookmark', 'key_unmappings',
        \ 'g:SmartFinderUnmapBookmarkKey')

  unlet s:bookmark
endif




" end {{{1

" unlet
unlet s:WINDOWS


" :help 'secure'
set secure




" vim: expandtab shiftwidth=2 softtabstop=2 foldmethod=marker
