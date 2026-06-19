""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Essential Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set the cursor format to be a blinking block all the time.
"   Reference: https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes
"   Reference: https://nickjanetakis.com/blog/change-your-vim-cursor-from-a-block-to-line-in-normal-and-insert-mode
let &t_SI.="\e[1 q"
let &t_SR.="\e[1 q"
let &t_EI.="\e[1 q"
"let &t_ti.="\e[1 q"
"let &t_te.="\e[1 q"

" Enable page scrolling with the angle bracket ('<', '>') keys.
nnoremap , <c-y>
nnoremap . <c-e>

" Disable automatic comment continuation and comment reflowing.
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Disable automatic indenting after a carriage return.
set noautoindent
filetype indent off

" Set the timeout for key combintion (chord) inputs.
set timeoutlen=300

" Change the default leader from ';' to something custom.
let mapleader=" "

" Map the escape key to something on the home row.
vnoremap asdf <esc>
inoremap asdf <esc>

" Create a shortcut for listing and switching buffers.
nnoremap <leader>b :buffers<cr>:buffer<space>

" Show line numbers by default, but create a shortcut to toggle them off.
set number
nnoremap <leader>n :set number!<cr>

" Set the number of space characters a tab character gets rendered as.
set tabstop=12

" Sets the number of columns to add when pressing the tab key.
set softtabstop=4

" Convert each column in newly added tab characters to a space character.
set expandtab

" Move the cursor to the next available match while typing the search term.
set incsearch

" Highlight all matches of the last executed search.
set hlsearch

" Create a shortcut to toggle highlighting for search results.
nnoremap <leader>c :nohlsearch<cr>

" Enable syntax highlighting.
filetype on
syntax on

" Set the color scheme to match the terminal's color scheme. If the terminal
" color scheme isn't set to something decent, 'murphy' or 'torte' are decent
" color schemes.
colorscheme default

" Highlight the current line number. Change the colors in 'Style Settings'.
set cursorline
set cursorlineopt=number

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Movement Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Go to the beginning of all words on a line (exclude leading whitespace).
nnoremap B ^
vnoremap B ^

" Go to the beginning of the line (include leading whitespace).
nnoremap ^ 0
vnoremap ^ 0

" Go to the end of all words on a line (exclude trailing whitespace).
nnoremap E g_
vnoremap E g_

" Join the current line and the next line.
nnoremap <leader>j J

" Move up the next non-blank row within the current column.
nnoremap K :call search('\%'.virtcol('.').'v\S', 'bW')<cr>

" Move down the next non-blank row within the current column.
nnoremap J :call search('\%'.virtcol('.').'v\S', 'W')<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Shortcuts
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Toggle relative line numbers.
nnoremap <leader>ni :set invrelativenumber<cr>

" Cross instance clipboard.
vnoremap <leader>y :w! /dev/shm/vimcb<cr>
vnoremap <leader>p :r! cat /dev/shm/vimcb<cr>
noremap <leader>p :r! cat /dev/shm/vimcb<cr>

" Mappable shortcut template.
nmap <leader>1 <esc>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VimDiff Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set the angle bracket keys ('<', '>') to move between diff chunks.
if &diff
    nnoremap , [c
    nnoremap . ]c
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Style Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Disable matching parenthesis highlight.
                      highlight MatchParen ctermbg=none
autocmd ColorScheme * highlight MatchParen ctermbg=none

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Dracula Terminal Theme Style Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" All line numbers color.
                      highlight LineNr cterm=bold ctermbg=none ctermfg=8
autocmd ColorScheme * highlight LineNr cterm=bold ctermbg=none ctermfg=8


" Current line number color.
                      highlight CursorLineNr cterm=bold ctermbg=none ctermfg=5
autocmd ColorScheme * highlight CursorLineNr cterm=bold ctermbg=none ctermfg=5

" Search results color.
                      highlight Search cterm=bold ctermbg=1 ctermfg=16
autocmd ColorScheme * highlight Search cterm=bold ctermbg=1 ctermfg=16

"" Incrimental search results color.
"                      highlight IncSearch cterm=bold ctermbg=1 ctermfg=16
"autocmd ColorScheme * highlight IncSearch cterm=bold ctermbg=1 ctermfg=16

" Visual selection color.
                      highlight Visual cterm=bold ctermbg=4 ctermfg=3
autocmd ColorScheme * highlight Visual cterm=bold ctermbg=4 ctermfg=3

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
" Unsure/Need Documentation
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
