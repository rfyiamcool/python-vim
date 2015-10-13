
"set iskeyword+=_,$,@,%,#,-,'
    " for nerdtree
    "let NERDTreeWinSize=20
    "let NERDChristmasTree=1
    "let NERDTreeMouseMode=2
    "autocmd vimenter * NERDTree

	let Tlist_Auto_Open=1 
	let Tlist_Exit_OnlyWindow=1
	let Tlist_WinWidth=24
    set fileencodings=utf-8,gbk,ucs-bom,latin1
    set termencoding=utf-8
    set encoding=utf-8
    let &termencoding=&encoding
"    set backup
"    set backupdir=~/.vim/backup
    let g:doxygenToolkit_authorName="xiaorui"
    let g:DoxygenToolkit_authorName="xiaorui"
    let g:doxygenToolkit_briefTag_funcName="yes"
    "set list
    "set listchars=tab:>-,trail:-


    " for pathogen
    call pathogen#infect()
    highlight WhitespaceEOL ctermbg=blue guibg=blue
    match WhitespaceEOL /\s\+$/

    " for supertab
    let g:SuperTabRetainCompletionType=2
" Basics {
    set nocompatible " explicitly get out of vi-compatible mode
    set noexrc " don't use local version of .(g)vimrc, .exrc
    set background=dark " we plan to use a dark background
    set cpoptions=aABceFsmq
    "             |||||||||
    "             ||||||||+-- When joining lines, leave the cursor 
    "             |||||||      between joined lines
    "             |||||||+-- When a new match is created (showmatch) 
    "             ||||||      pause for .5
    "             ||||||+-- Set buffer options when entering the 
    "             |||||      buffer
    "             |||||+-- :write command updates current file name
    "             ||||+-- Automatically add <CR> to the last line 
    "             |||      when using :@r
    "             |||+-- Searching continues at the end of the match 
    "             ||      at the cursor position
    "             ||+-- A backslash has no special meaning in mappings
    "             |+-- :write updates alternative file name
    "             +-- :read updates alternative file name
    syntax on " syntax highlighting on
" }

" General {
    filetype plugin indent on " load filetype plugins/indent settings
"    set autochdir " always switch to the current file directory 
    colorscheme desert
    set backspace=indent,eol,start " make backspace a more flexible
    set clipboard+=unnamed " share windows clipboard
    set fileformats=unix " support all three, in this order
    set hidden " you can change buffers without saving
    " (XXX: #VIM/tpope warns the line below could break things)
  "  set mouse=a " use mouse everywhere
    set noerrorbells " don't make noise
    set whichwrap=b,s,h,l,<,>,~,[,] " everything wraps
    "             | | | | | | | | |
    "             | | | | | | | | +-- "]" Insert and Replace
    "             | | | | | | | +-- "[" Insert and Replace
    "             | | | | | | +-- "~" Normal
    "             | | | | | +-- <Right> Normal and Visual
    "             | | | | +-- <Left> Normal and Visual
    "             | | | +-- "l" Normal and Visual (not recommended)
    "             | | +-- "h" Normal and Visual (not recommended)
    "             | +-- <Space> Normal and Visual
    "             +-- <BS> Normal and Visual
    "set wildmenu " turn on command line completion wild style
    " ignore these list file extensions
    "set wildignore=*.dll,*.o,*.obj,*.bak,*.exe,*.pyc,
                    \*.jpg,*.gif,*.png
    "set wildmode=list:longest " turn on wild mode huge list
" }

 "Vim UI {
    "set cursorcolumn " highlight the current column
    set cursorline " highlight current line
    set incsearch " BUT do highlight as you type you 
                   " search phrase
    "set laststatus=2 " always show the status line
   " set lazyredraw " do not redraw while running macros
    set linespace=0 " don't insert any extra pixel lines 
                     " betweens rows
              " out of my files
   " set matchtime=5 " how many tenths of a second to blink 
                     " matching brackets for
    set hlsearch " do not highlight searched for phrases
    set nostartofline " leave my cursor where it was
    set novisualbell " don't blink
    set number " turn on line numbers
    set numberwidth=4 " We are good up to 99999 lines
    set report=0 " tell us when anything is changed via :...
    set ruler " Always show current positions along the bottom
    set scrolloff=10 " Keep 10 lines (top/bottom) for scope
    set shortmess=aOstT " shortens messages to avoid 
                         " 'press a key' prompt
    set showcmd " show the command being typed
    set showmatch " show matching brackets
    set sidescrolloff=10 " Keep 5 lines at the size
    set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
    "              | | | | |  |   |      |  |     |    |
    "              | | | | |  |   |      |  |     |    + current 
    "              | | | | |  |   |      |  |     |       column
    "              | | | | |  |   |      |  |     +-- current line
    "              | | | | |  |   |      |  +-- current % into file
    "              | | | | |  |   |      +-- current syntax in 
    "              | | | | |  |   |          square brackets
    "              | | | | |  |   +-- current fileformat
    "              | | | | |  +-- number of lines
    "              | | | | +-- preview flag in square brackets
    "              | | | +-- help flag in square brackets
    "              | | +-- readonly flag in square brackets
    "              | +-- rodified flag in square brackets
    "              +-- full path to file in the buffer
 "}

" Text Formatting/Layout {
   " set completeopt= " don't use a pop up menu for completions
	"set noexpandtab " no real tabs please!
    set formatoptions=rq " Automatically insert comment leader on return, 
                          " and let gq format comments
    set ignorecase " case insensitive by default
    set infercase " case inferred by default
   " set nowrap " do not wrap line
    set shiftround " when at 3 spaces, and I hit > ... go to 4, not 5
    set smartcase " if there are caps, go case-sensitive
   " set shiftwidth=4 " auto-indent amount when using cindent, 
                      " >>, << and stuff like that
    "set softtabstop=4 " when hitting tab or backspace, how many spaces 
                       "should a tab be (see expandtab)
   " set tabstop=8 " real tabs should be 8, and they will show with 
                   " set list on
     "set sw=8 noet
     set sw=4 ts=4 tw=100 sts=4  et
	if has("autocmd")
		au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
			\| exe "normal g'\"" | endif
	endif
" }

" Folding {
    set nocompatible

    set foldenable " Turn on folding
    set foldmarker={,} " Fold C style code (only use this as default 
                        " if you use a high foldlevel)
    set foldmethod=marker " Fold on the marker
    set foldlevel=100 " Don't autofold anything (but I can still 
                      " fold manually)
    set foldopen=block,hor,mark,percent,quickfix,tag " what movements
                                                      " open folds 
    function SimpleFoldText() " {
        return getline(v:foldstart).' '
    endfunction " }
    set foldtext=SimpleFoldText() " Custom fold text function 
                                   " (cleaner than default)
" }

" Plugin Settings {
                              " inside strings

    " TagList Settings {
                                 " read my functions
        " Language Specifics {
            " just functions and classes please
            " just functions and subs please
            " don't show variables in freaking php
            " just functions and classes please
        " }
    " }
" }

 "Mappings {
    " ROT13 - fun
    "map <F12> ggVGg?
    map <C-]> g]

    " space / shift-space scroll in normal mode
    "noremap <S-space> <C-b>
    "noremap <space> <C-f>

    " Make Arrow Keys Useful Again {
    " }
 "}

" Autocommands {
    " Ruby {
        " ruby standard 2 spaces, always
     "   au BufRead,BufNewFile *.rb,*.rhtml set shiftwidth=2 
      "  au BufRead,BufNewFile *.rb,*.rhtml set softtabstop=2 
    " }
    " Notes {
        " I consider .notes files special, and handle them differently, I
        " should probably put this in another file
      "  au BufRead,BufNewFile *.notes set foldlevel=2
      "  au BufRead,BufNewFile *.notes set foldmethod=indent
      "  au BufRead,BufNewFile *.notes set foldtext=foldtext()
      "  au BufRead,BufNewFile *.notes set listchars=tab:\ \ 
      "  au BufRead,BufNewFile *.notes set noexpandtab
      "  au BufRead,BufNewFile *.notes set shiftwidth=8
      "  au BufRead,BufNewFile *.notes set softtabstop=8
      "  au BufRead,BufNewFile *.notes set tabstop=8
      "  au BufRead,BufNewFile *.notes set syntax=notes
      "  au BufRead,BufNewFile *.notes set nocursorcolumn
      "  au BufRead,BufNewFile *.notes set nocursorline
      "  au BufRead,BufNewFile *.notes set guifont=Consolas:h12
      "  au BufRead,BufNewFile *.notes set spell
    " }
    "au BufNewFile,BufRead *.ahk setf ahk 
" }

" GUI Settings {
"if has("gui_running")
    " Basics {
     "   colorscheme metacosm " my color scheme (only works in GUI)
    "    set guifont=Consolas:h10 " My favorite font
   "     set guioptions=ce 
        "              ||
        "              |+-- use simple dialogs rather than pop-ups
        "              +  use GUI tabs, not console style tabs
 "       set lines=55 " perfect size for me
  "      set mousehide " hide the mouse cursor when typing
    " }

       " map <F9> <ESC>:set guifont=Consolas:h10<CR>
       " map <F10> <ESC>:set guifont=Consolas:h12<CR>
       " map <F11> <ESC>:set guifont=Consolas:h16<CR>
       " map <F12> <ESC>:set guifont=Consolas:h20<CR>
    " }
"endif
" }

set nolinebreak
"set nowrap
set textwidth=0
colorscheme monokai
au! CursorMoved * let &cc=col('.')
set rtp+=/usr/local/lib/python2.7/site-packages/powerline/bindings/vim

" ............

set nocompatible               " be iMproved
filetype off                   " required!

 set rtp+=~/.vim/bundle/vundle/
 call vundle#rc()

 " let Vundle manage Vundle
 " required! 
 Bundle 'gmarik/vundle'

 " My Bundles here:
 "
 filetype plugin indent on     " required!
 " Brief help
 " :BundleList          - list configured bundles
 " :BundleInstall(!)    - install(update) bundles
 " :BundleSearch(!) foo - search(or refresh cache first) for foo
 " :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
Bundle 'thinca/vim-quickrun'
let g:quickrun_config = {
\   "_" : {
\       "outputter" : "message",
\   },
\}

let g:quickrun_no_default_key_mappings = 1
nmap <Leader>r <Plug>(quickrun)
map <F10> :QuickRun<CR>
