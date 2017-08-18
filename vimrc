"-----------------------------------------------------------
" Setting up Vundle - the vim plugin bundler
    let iCanHazVundle=1
    let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
    if !filereadable(vundle_readme)
        echo "Installing Vundle.."
        echo ""
        silent !mkdir -p ~/.vim/bundle
        silent !git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/vundle
        let iCanHazVundle=0
    endif
    set nocompatible              " be iMproved, required
    filetype off                  " required
    set rtp+=~/.vim/bundle/vundle/
    call vundle#begin()
    Plugin 'VundleVim/Vundle.vim'
    "Add your bundles here
    Plugin 'scrooloose/syntastic' "uber awesome syntax and errors highlighter
    Plugin 'tpope/vim-surround'
    Plugin 'vim-airline/vim-airline'
    Plugin 'tir_black'
    "...All your other bundles...
    if iCanHazVundle == 0
        echo "Installing Vundles, please ignore key map error messages"
        echo ""
        :PluginInstall
    endif

    call vundle#end()
    "must be last
    filetype plugin indent on " load filetype plugins/indent settings
    syntax on                      " enable syntax

" Setting up Vundle - the vim plugin bundler end
"------------------------------------------------------------
" Must have options {{{1
"
" These are highly recommended options.

" Vim with default settings does not allow easy switching between multiple files
" in the same editor window. Users can use multiple split windows or multiple
" tab pages to edit multiple files, but it is still best to enable an option to
" allow easier switching between files.
"
" One such option is the 'hidden' option, which allows you to re-use the same
" window and switch from an unsaved buffer without saving it first. Also allows
" you to keep an undo history for multiple files when re-using the same window
" in this way. Note that using persistent undo also lets you undo in multiple
" files even in the same window, but is less efficient and is actually designed
" for keeping undo history after closing Vim entirely. Vim will complain if you
" try to quit without saving, and swap files will keep you safe if your computer
" crashes.
set hidden

" Note that not everyone likes working this way (with the hidden option).
" Alternatives include using tabs or split windows instead of re-using the same
" window as mentioned above, and/or either of the following options:
" set confirm
" set autowriteall

" Better command-line completion
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch

" Modelines have historically been a source of security vulnerabilities. As
" such, it may be a good idea to disable them and use the securemodelines
" script, <http://www.vim.org/scripts/script.php?script_id=1876>.
" set nomodeline


"------------------------------------------------------------
" Usability options {{{1
"
" These are options that users frequently set in their .vimrc. Some of them
" change Vim's behaviour in ways which deviate from the true Vi way, but
" which are considered to add usability. Which, if any, of these options to
" use is very much a personal preference, but they are harmless.

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
"set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
"set nostartofline"

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
"set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=

" Enable use of the mouse for all modes
set mouse=a

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Display line numbers on the left
set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>


"------------------------------------------------------------
" Indentation options {{{1
"
" Indentation settings according to personal preference.

" Indentation settings for using 4 spaces instead of tabs.
" Do not change 'tabstop' from its default value of 8 with this setup.
"set shiftwidth=4
"set softtabstop=4
"set expandtab

" Indentation settings for using hard tabs for indent. Display tabs as
" four characters wide.
set shiftwidth=4
set tabstop=4
set expandtab


"------------------------------------------------------------
" Mappings {{{1
"
" Useful mappings

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

"------------------------------------------------------------
"
highlight ExtraWhitespace ctermbg=darkred guibg=darkred ctermfg=yellow guifg=yellow
match ExtraWhitespace /\s\+$/


function! RaiseWarningForFlake8Issues()
    if &filetype == 'python'
        let s:v_control = 'svn'
        let s:dir_name = expand("%:p:h")
        let s:start_dir = getcwd()
        silent exe 'cd ' . s:dir_name
        silent exe '!svn info > /dev/null 2>&1'
        if v:shell_error > 0
            let s:v_control = 'git'
            silent exe '!git status > /dev/null 2>&1'
        endif
        if v:shell_error == 0
            let s:file_name = expand('%:p')
            new
            if s:v_control == 'svn'
                silent exe ':read !svn diff -x -U0 ' . s:file_name . ' | flake8 --diff'
            elseif s:v_control == 'git'
                try
                    let s:git_repo_path = system("git rev-parse --show-toplevel")
                    if v:shell_error == 0
                        silent exe 'cd ' . s:git_repo_path
                        silent exe ':read !git diff -U0 ' . s:file_name . ' | flake8 --diff'
                    endif
                catch /.*/
                    echohl WarningMsg | echo "Flake8 hit a traceback attempting to run on git diff" | echohl None
                endtry
            endif
            let s:res_length = line('$')
            if s:res_length != 1
                if search('\v^(fatal|svn: E155010)', 'nw') != 0
                    silent 2d
                    silent exe ':read !flake8 ' . s:file_name
                endif
                silent 1d
                silent %yank p
                echohl WarningMsg | echo @p | echohl None
            endif
            bd!
        endif
        silent exe 'cd ' . s:start_dir
    endif
endfunction


function! RaiseExceptionForUnresolvedIssues()
    if search('\v^[<=>]{7}( .*|$)', 'nw') != 0
        throw 'Found unresolved conflicts'
    endif
    if search('\s\+$', 'nw') != 0
        throw 'Found trailing whitespace'
    endif
    if &filetype == 'python'
        let s:file_name = expand('%:t')

        silent %yank p
        new
        silent 0put p
        silent $,$d
        silent %!pyflakes
        silent exe '%s/<stdin>/' . s:file_name . '/e'
        unlet! s:file_name

        let s:un_res = search('undefined name', 'nw')
        if s:un_res != 0
            let s:message = 'Syntax error! ' . getline(s:un_res)
            bd!
            throw s:message
        endif

        let s:ui_res = search('unexpected indent', 'nw')
        if s:ui_res != 0
            let s:message = 'Syntax error! ' . getline(s:ui_res)
            bd!
            throw s:message
        endif

        let s:is_res = search('invalid syntax', 'nw')
        if s:is_res != 0
            let s:message = 'Syntax error! ' . getline(s:is_res)
            bd!
            throw s:message
        endif

        bd!
    endif
endfunction
autocmd BufWritePre * call RaiseExceptionForUnresolvedIssues()
autocmd BufWritePost * call RaiseExceptionForFlake8Issues()

set foldenable
set whichwrap=b,s,h,l,<,>,[,] " Backspace and cursor keys wrap too
set incsearch " Find as you type search
set showmatch " Show matching brackets/parenthesis

" Persistent undo
set undodir=/home/nberrios/.vim/undodir
set undofile

if $TMUX == ''
        set clipboard+=unnamed
    endif

set list
set listchars=tab:›\
set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
set cursorline
set statusline=\ %f%m%r%h%w\ %=%({%{&ff}\|%{(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\",B\":\"\")}%k\|%Y}%)\ %([%l,%v][%p%%]\ %)
let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_loc_list_height = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1
let g:syntastic_enable_balloons = 1
let g:syntastic_auto_jump = 1
let g:syntastic_enable_signs = 0
let g:syntastic_python_checkers = ["pyflakes"]
let g:airline#extensions#syntastic#enabled = 1
let g:syntastic_stl_format = '[%E{Err: %fe #%e}%B{, }%W{Warn: %fw #%w}]'
let g:syntastic_mode_map = { 'mode': 'passive' }
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set ttymouse=xterm2
set tags=~/mytags
vnoremap gb :<C-U>!svn blame <C-R>=expand("%:p") <CR> \| sed -n <C-R>=line("'<") <CR>,<C-R>=line("'>") <CR>p <CR>
vnoremap <F8> :<C-U>!flake8 % \| awk -F: '$2 >= <C-R>=line("'<") <CR> && $2 <= <C-R>=line("'>") <CR>' <CR>
