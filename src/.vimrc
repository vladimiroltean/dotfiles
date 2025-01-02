set nocp
" Break compatibility with vi

set shortmess=a

" Swap, backup and undo files
" Create them if they don't exist
let s:vim_backup = expand('$HOME/.vim/.backup')
if filewritable(s:vim_backup) == 0 && exists("*mkdir")
    call mkdir(s:vim_backup, "p", 0700)
endif
let s:vim_undo = expand('$HOME/.vim/.undo')
if filewritable(s:vim_undo) == 0 && exists("*mkdir")
    call mkdir(s:vim_undo, "p", 0700)
endif
let s:vim_swap = expand('$HOME/.vim/.swap')
if filewritable(s:vim_swap) == 0 && exists("*mkdir")
    call mkdir(s:vim_swap, "p", 0700)
endif

let &backupdir=s:vim_backup
let &undodir=s:vim_undo
let &dir=s:vim_swap

call plug#begin('~/.vim/plugged')

Plug 'lervag/vimtex'
Plug 'https://github.com/tpope/vim-dispatch'
" Provides C-Up and C-Down maps for swapping lines
Plug 'tpope/vim-unimpaired'
Plug 'https://github.com/vim-scripts/Colour-Sampler-Pack'
Plug 'https://github.com/ntpeters/vim-better-whitespace'
Plug 'scrooloose/nerdtree'
" Plug 'gu-fan/riv.vim'
" Handy mappings for <Leader>ci etc
Plug 'scrooloose/nerdcommenter'
" Handy search with <C>-f
Plug 'rking/ag.vim', { 'on': 'Ag' }
" Fuzzy file search
Plug 'https://github.com/ctrlpvim/ctrlp.vim'
" Accelerate motions with <Leader><Leader>w etc
Plug 'https://github.com/easymotion/vim-easymotion'
" Provides the handy info in statusbar and left of buffer for modified files
Plug 'airblade/vim-gitgutter' ", { 'on': 'GitGutterToggle' }
" Provides mappings for git checkout, branch etc
Plug 'tpope/vim-fugitive'
" Provides handy commands like :SudoWrite etc
Plug 'tpope/vim-eunuch'
" Easy searching through Vim change list
Plug 'vim-scripts/Gundo', { 'on': 'GundoToggle' }
Plug 'majutsushi/tagbar' ", { 'on': 'TagbarToggle' }
" Syntax-aware % matching
Plug 'tmhedberg/matchit'
Plug 'drn/zoomwin-vim', { 'on': 'ZoomWin' }
" For vimpager compatibility with git colors
Plug 'https://github.com/vim-scripts/AnsiEsc.vim'
" For marks
Plug 'kshenoy/vim-signature'
" At match %d out of %d matched
Plug 'google/vim-searchindex'
" Vim / Tmux pane split integration
Plug 'christoomey/vim-tmux-navigator'

" Add plugins to &runtimepath
call plug#end()

" Maintain persistent undo history of files
set undofile
" For files edited outside of vim
set autoread
" Search options
set incsearch
set ignorecase
set smartcase
set hlsearch
set wrapscan
set mousemodel=extend
" scroll offset from the cursor to the top and bottom
set scrolloff=7
set ruler
set backspace=eol,start,indent
set whichwrap+=<,>,h,l
set encoding=utf8
" Show autocompletion menu for command mode
set wildmenu
" Mark tabs and spaces.
set list listchars=tab:»\ ,trail:·,extends:»,precedes:«
" Load manual pages.
runtime ftplugin/man.vim
" Set tex flavor.
let g:tex_flavor = 'latex'
" For yank to use " register and work with X11 clipboard
set clipboard=unnamedplus
set guioptions+=a
" For better tmux compatibility (mouse scrolling)
set mouse=a
set term=xterm-256color
" For mouse clicks beyond column 220
if has("mouse_sgr")
    set ttymouse=sgr
else
    set ttymouse=xterm2
end

"set foldmethod=syntax
set tags=./tags.headers;/,./tags;/,tags;/;
function! LoadCscope()
  let db = findfile("cscope.out", ".;")
    if (!empty(db))
        let path = strpart(db, 0, match(db, "/cscope.out$"))
        set nocscopeverbose " suppress 'duplicate connection' error
        exe "cs add " . db . " " . path
        set cscopeverbose
    endif
endfunction
au BufEnter /* call LoadCscope()

set number
"set relativenumber

" Indent with tabs, align with spaces
set tabstop=8
set shiftwidth=8
set softtabstop=0
"set smarttab
set noexpandtab
set preserveindent
set copyindent
set autoindent
"set smartindent
"set cindent

"set textwidth=80
set wrap
"set list breaks this
set linebreak

" Colorscheme
" Use "bluegreen" for now, previously was using "molokai"
colorscheme bluegreen
" Repair colors for completion menu
highlight Pmenu ctermbg=238 ctermfg=cyan gui=bold

" Make vim use nice colors
"set background = "dark"
" Disable opaque background
"highlight Normal    ctermbg=none
"highlight NonText   ctermbg=none
"highlight VertSplit ctermbg=none
"highlight LineNr    ctermbg=none
"highlight Special   ctermbg=none
set wildmenu

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Taken from Janus
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("statusline") && !&cp
  hi User0 cterm=bold ctermfg=black ctermbg=white
  hi User1 cterm=bold ctermfg=red   ctermbg=none
  hi User2 cterm=bold ctermfg=white ctermbg=none
  hi User3 cterm=bold ctermfg=green ctermbg=none
  hi User4 cterm=bold ctermfg=cyan  ctermbg=none

  set laststatus=2  " always show the status bar

  " Start the status line
  set statusline=
  set statusline+=%0*                           " User0 highlight
  set statusline+=%t\ %m\ %r                    " Tail of filename, Modified flag, Read-only
  set statusline+=%4*                           " User4 highlight
  set statusline+=\ %y                          " File Type
  set statusline+=%2*                           " User2 highlight
  set statusline+=\ Line\ %3l\ of\ %L\ [%3p%%]
  set statusline+=\ Col%3v
  set statusline+=%1*                           " User1 highlight
  set statusline+=\ %{fugitive#statusline()}
  set statusline+=%0*                           " Return to User0 highlight

endif


filetype plugin indent on " Turn on filetype plugins (:help filetype-plugin)

if has("autocmd")
  " In Makefiles, use real tabs, not tabs expanded to spaces
  au FileType make setlocal noexpandtab

  " Make sure all markdown files have the correct filetype set and setup wrapping
  au BufRead,BufNewFile *.{md,markdown,mdown,mkd,mkdn,txt} setf markdown
  if !exists("g:disable_markdown_autostyle")
    au FileType markdown setlocal wrap linebreak textwidth=72 nolist
  endif

  " make Python follow PEP8 for whitespace ( http://www.python.org/dev/peps/pep-0008/ )
  au FileType python setlocal tabstop=4 shiftwidth=4

  " Remember last location in file, but not for commit messages.
  " see :help last-position-jump
  au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g`\"" | endif
endif

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

autocmd! User YouCompleteMe if !has('vim_starting') | call youcompleteme#Enable() | endif

let g:ctrlp_extensions = ['tag', 'buffertag', 'quickfix', 'dir', 'rtscript',
                        \ 'undo', 'line', 'changes', 'mixed', 'bookmarkdir']
let g:ycm_global_ycm_extra_conf = '~/.vim/_ycm_extra_conf.py'


" NERDTree

" If the parameter is a directory, cd into it
function! s:CdIfDirectory(directory)
  let explicitDirectory = isdirectory(a:directory)
  let directory = explicitDirectory || empty(a:directory)

  if explicitDirectory
    exe "cd " . fnameescape(a:directory)
  endif

  " Allows reading from stdin
  " ex: git diff | mvim -R -
  if strlen(a:directory) == 0
    return
  endif

  if directory
    NERDTree
    wincmd p
    bd
  endif

  if explicitDirectory
    wincmd p
  endif
endfunction

" NERDTree utility function
function! s:UpdateNERDTree(...)
  let stay = 0

  if(exists("a:1"))
    let stay = a:1
  end

  if exists("t:NERDTreeBufName")
    let nr = bufwinnr(t:NERDTreeBufName)
    if nr != -1
      exe nr . "wincmd w"
      exe substitute(mapcheck("R"), "<CR>", "", "")
      if !stay
        wincmd p
      end
    endif
  endif
endfunction

let NERDTreeHijackNetrw = 0
let NERDTreeShowHidden = 1

function! NERDTreeIsOpen()
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

function! NERDTreeSync(buffername)
  if &modifiable && NERDTreeIsOpen() && strlen(a:buffername) > 0 && !&diff
    NERDTreeFind
    wincmd l
  endif
endfunction

augroup AuNERDTreeCmd
  " Open NERDTree on left-hand side if requested to open a directory
  autocmd AuNERDTreeCmd VimEnter * call s:CdIfDirectory(expand("<amatch>"))
  autocmd AuNERDTreeCmd FocusGained * call s:UpdateNERDTree()
  " close vim if the only window left open is a NERDTree?
  "autocmd AuNERDTreeCmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
  " Highlight a file in NERDTree when opening it in a buffer
  "autocmd AuNERDTreeCmd BufEnter * call s:NERDTreeSync(expand("<amatch>"))
augroup END

source ~/.vimrc.keymaps
