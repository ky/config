" .vimrc


" options "{{{1
set nocompatible

if has('win16') || has('win32') || has('win64')
  let s:windows = 1
else
  let s:windows = 0
endif

syntax on
filetype indent plugin on
set hidden
set nobackup
set noswapfile
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
if s:windows
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
command! -nargs=? -bang Jis edit<bang> Iso2022jp<bang> <args>
command! -nargs=? -bang Sjis Cp932<bang> <args>
command! -nargs=? -bang Utf8 edit<bang> ++enc=utf-8 <args>




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
  if exists(':' . a:cmd) == 2 && (!a:0 || a:000[0] ==# bufname('%'))
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
if !exists('g:smartfinder_options')
  runtime! autoload/smartfinder.vim
endif
if exists('g:smartfinder_options')
  function! s:smartfinder_bufname()
    return g:smartfinder_options.global.bufname
  endfunction

  autocmd MyAutoCommand BufEnter *
        \ call s:do_command('AutoComplPopLock', s:smartfinder_bufname())
  autocmd MyAutoCommand BufFilePost *
        \ call s:do_command('AutoComplPopLock', s:smartfinder_bufname())
  autocmd MyAutoCommand BufLeave *
        \ call s:do_command('AutoComplPopUnlock', s:smartfinder_bufname())
endif





" encoding {{{1

" from http://www.kawaz.jp/pukiwiki/?vim#content_1_7
if &encoding !=# 'utf-8'
  set encoding=japan
  set fileencoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  let s:test_code = "\x87\x64\x87\x6a"
  let s:conv_result = "\xad\xc5\xad\xcb"
  if iconv(s:test_code, 'cp932', 'eucjp-ms') ==# s:conv_result
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
  elseif iconv(s:test_code, 'cp932', 'euc-jisx0213') ==# s:conv_result
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
    let &fileencodings = &fileencodings .','. s:fileencodings_default
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  unlet s:enc_euc
  unlet s:enc_jis
  unlet s:test_code
  unlet s:conv_result
endif
function! s:au_recheck_fenc()
  if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
    let &fileencoding=&encoding
  endif
endfunction
autocmd MyAutoCommand BufReadPost * call s:au_recheck_fenc()
set ambiwidth=double




" mappings {{{1

function! s:toggle_option(option_name)
  " toggle
  execute "setlocal " . a:option_name . "!"
  " show status
  execute "setlocal " . a:option_name . "?"
endfunction

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
if s:windows
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
nnoremap <Space>h  :<C-u>nohlsearch<CR>
nnoremap <Space>j  <Nop>
nnoremap <Space>jb :<C-u>SmartFinder buffer<CR>
nnoremap <Space>jf :<C-u>SmartFinder file<CR>
nnoremap <Space>jk :<C-u>SmartFinder bookmark<CR>
nnoremap <Space>n  :<C-u>cnext<CR>
nnoremap <Space>N  :<C-u>cprevious<CR>
nnoremap <Space>p  :<C-u>call <SID>toggle_option('paste')<CR>
nnoremap <Space>w  :<C-u>call <SID>toggle_option('wrap')<CR>
nnoremap <Space>s  <Nop>
nnoremap <Space>so :<C-u>source %<CR>

" cmap
cnoremap <C-A> <Home>
cnoremap <C-F> <Right>
cnoremap <C-B> <Left>
cnoremap <C-D> <Delete>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>
cnoremap <C-J> <Nop>
set cedit=<C-O>




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
if s:windows
  let g:vimball_home = '$VIM/vimfiles'
endif

" smartfinder.vim
" http://github.com/ky/smartfinder/tree/master
if exists('g:smartfinder_options')
  if s:windows
    let s:bookmark = [
          \ [ 'vimfiles', '$VIM/vimfiles/' ],
          \ [ 'work', 'E:/work/' ]
          \]
  else
    let s:bookmark = [
          \ [ 'work', '~/work/' ],
          \ [ 'memo', '~/memo/' ]
          \]
  endif

  function! g:SmartFinderBookmarkKeyMap()
    call smartfinder#bookmark#map_default_keys()
    imap <buffer> / <Plug>SmartFinderBookmarkSelected
  endfunction

  function! g:SmartFinderBookmarkKeyUnmap()
    call smartfinder#safe_iunmap(['/'])
    call smartfinder#bookmark#unmap_default_keys()
  endfunction

  let g:smartfinder_options.mode.bookmark = {
        \ 'bookmark_list'          : s:bookmark,
        \ 'key_mapping_function'   : 'g:SmartFinderBookmarkKeyMap',
        \ 'key_unmapping_function' : 'g:SmartFinderBookmarkKeyUnmap',
        \}
  unlet s:bookmark
endif




" end {{{1

" unlet
unlet s:windows


" :help 'secure'
set secure




" vim: expandtab shiftwidth=2 softtabstop=2 foldmethod=marker
