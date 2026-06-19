""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Primary Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set the timeout for key combintion (chord) inputs.
set timeoutlen=333

" Change the default leader from ';' to something faster/easier to enter.
let mapleader=" "

" Map the escape key to something faster/easier to enter.
vnoremap fd <esc>
inoremap fd <esc>

" Enable relative line numbers and a shortcut to toggle them on and off.
set number
set relativenumber
nnoremap <leader>tln :set number!<cr>

" Convert new tab characters to spaces and render existing tab characters annoyingly.
set tabstop=12
set softtabstop=4
set expandtab

" Enable incrimental search with search highlighting. Also add a shortcut to
" turn off search highlights.
set incsearch
set nowrapscan
set hlsearch
nnoremap <leader>cls :nohlsearch<cr>
nnoremap <leader>hls :set hlsearch<cr>

" Enable syntax highlighting.
filetype on
syntax on

" Set the color scheme to match the terminal's color scheme. If the terminal
" color scheme isn't set to something decent, 'murphy' or 'torte' are decent
" color schemes.
colorscheme default

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Custom Movement Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Enable page scrolling with the angle bracket keys but without <shift>.
nnoremap , <c-y>
nnoremap . <c-e>

" Enable jumping between diff blocks in vimdiff using the angle bracket keys.
if &diff
    nnoremap <shift>, [c
    nnoremap <shift>. ]c
endif

" Go to the beginning of all words on a line (exclude leading whitespace).
nnoremap BLT ^
vnoremap BLT ^

" Go to the end of all words on a line (exclude trailing whitespace).
nnoremap ELT g_
vnoremap ELT g_

" Go to the beginning of the line (include leading whitespace).
nnoremap ^ 0
vnoremap ^ 0

" Move up or down to the next non-blank row within the current column.
"nnoremap <leader>j J
"nnoremap K :call search('\%'.virtcol('.').'v\S', 'bW')<cr>
"nnoremap J :call search('\%'.virtcol('.').'v\S', 'W')<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Shortcuts
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Cross instance clipboard.
"vnoremap <leader>y :w! /dev/shm/vimcb<cr>
"vnoremap <leader>p :r! cat /dev/shm/vimcb<cr>
"noremap <leader>p :r! cat /dev/shm/vimcb<cr>

" Mappable shortcut template.
"nmap <leader>1 <esc>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Style Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Disable matching parenthesis highlight.
"                      highlight MatchParen ctermbg=none
"autocmd ColorScheme * highlight MatchParen ctermbg=none


" Highlight the current line number.
"set cursorline
"set cursorlineopt=number

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Dracula Style Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" All line numbers color.
"                      highlight LineNr cterm=bold ctermbg=none ctermfg=8
"autocmd ColorScheme * highlight LineNr cterm=bold ctermbg=none ctermfg=8


" Current line number color.
"                      highlight CursorLineNr cterm=bold ctermbg=none ctermfg=5
"autocmd ColorScheme * highlight CursorLineNr cterm=bold ctermbg=none ctermfg=5

" Search results color.
"                      highlight Search cterm=bold ctermbg=1 ctermfg=16
"autocmd ColorScheme * highlight Search cterm=bold ctermbg=1 ctermfg=16

"" Incrimental search results color.
"                      highlight IncSearch cterm=bold ctermbg=1 ctermfg=16
"autocmd ColorScheme * highlight IncSearch cterm=bold ctermbg=1 ctermfg=16

" Visual selection color.
"                      highlight Visual cterm=bold ctermbg=4 ctermfg=3
"autocmd ColorScheme * highlight Visual cterm=bold ctermbg=4 ctermfg=3

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VimDiff Style Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" VimDiff line addition color.
                      highlight DiffAdd cterm=bold ctermbg=53 ctermfg=255
autocmd ColorScheme * highlight DiffAdd cterm=bold ctermbg=53 ctermfg=255

" VimDiff line deletion color.
                      highlight DiffDelete cterm=bold ctermbg=53 ctermfg=255
autocmd ColorScheme * highlight DiffDelete cterm=bold ctermbg=53 ctermfg=255

" VimDiff line changed color.
                      highlight DiffChange cterm=bold ctermbg=53 ctermfg=255
autocmd ColorScheme * highlight DiffChange cterm=bold ctermbg=53 ctermfg=255

" VimDiff word changed color.
                      highlight DiffText cterm=bold ctermbg=88 ctermfg=255
autocmd ColorScheme * highlight DiffText cterm=bold ctermbg=88 ctermfg=255

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Removed
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Minimize redraw operations
"set lazyredraw

" Enable folding.
"set foldmethod=syntax
"set nofoldenable " Only disables auto fold on load.
"set foldlevelstart=99 " Disables auto fold on the first fold operation.

" Disable auto code folding.
"set diffopt+=context:9999

" Show last executed command.
"set showcmd

" Set the cursor format to be a blinking block all the time.
"   Reference: https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes
"   Reference: https://nickjanetakis.com/blog/change-your-vim-cursor-from-a-block-to-line-in-normal-and-insert-mode
"let &t_SI.="\e[1 q"
"let &t_SR.="\e[1 q"
"let &t_EI.="\e[1 q"
"let &t_ti.="\e[1 q"
"let &t_te.="\e[1 q"

" Disable automatic comment continuation and comment reflowing.
"autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Disable automatic indenting after a carriage return.
"set noautoindent
"filetype indent off

" Create a shortcut for listing and switching buffers.
"nnoremap <leader>b :buffers<cr>:buffer<space>
