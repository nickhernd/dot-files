" =============================================
"  Neovim minimal - sin plugins, sin Lua
" =============================================

" --- General ---
set encoding=utf-8
set noswapfile
set nobackup
set undofile
set undodir=~/.vim/undodir
set hidden                  " cambiar buffer sin guardar

" --- Apariencia ---
set termguicolors
set background=dark

" =============================================
"  Selector de temas (built-in, sin plugins)
"  <leader>ft  → elegir tema en cualquier momento
"  El tema elegido se guarda y se restaura solo
" =============================================
let s:theme_file = expand('~/.local/share/nvim/selected_theme')

let s:themes = [
  \ ['retrobox',   'Retrobox    (oscuro, retro - por defecto)'],
  \ ['habamax',    'Habamax     (oscuro, colores vivos)'],
  \ ['zaibatsu',   'Zaibatsu    (oscuro, cyberpunk)'],
  \ ['wildcharm',  'Wildcharm   (oscuro, equilibrado)'],
  \ ['slate',      'Slate       (oscuro, gris azulado)'],
  \ ['industry',   'Industry    (oscuro, profesional)'],
  \ ['elflord',    'Elflord     (oscuro, verde/cyan)'],
  \ ['lunaperche', 'Lunaperche  (oscuro, minimalista)'],
  \ ['desert',     'Desert      (cálido, arena)'],
  \ ['evening',    'Evening     (medio, suave)'],
  \ ['sorbet',     'Sorbet      (claro, pastel rosa/naranja)'],
  \ ['quiet',      'Quiet       (claro, minimalista gris)'],
  \ ['morning',    'Morning     (claro, azul suave)'],
  \ ['peachpuff',  'Peachpuff   (claro, melocotón pastel)'],
  \ ['shine',      'Shine       (claro, muy luminoso)'],
  \ ['zellner',    'Zellner     (claro, tonos suaves)'],
  \ ['delek',      'Delek       (claro, amarillo pastel)'],
  \ ['unokai',     'Unokai      (claro, verde pastel)'],
  \ ]

function! s:SaveTheme(name)
  call mkdir(fnamemodify(s:theme_file, ':h'), 'p')
  call writefile([a:name], s:theme_file)
endfunction

function! s:LoadTheme()
  if filereadable(s:theme_file)
    let l:lines = readfile(s:theme_file)
    if len(l:lines) > 0 | return l:lines[0] | endif
  endif
  return ''
endfunction

function! SelectTheme()
  let l:menu = ['Elegir tema (intro = cancelar):']
  for i in range(len(s:themes))
    call add(l:menu, printf('%2d. %s', i + 1, s:themes[i][1]))
  endfor
  let l:choice = inputlist(l:menu)
  if l:choice >= 1 && l:choice <= len(s:themes)
    let l:name = s:themes[l:choice - 1][0]
    execute 'colorscheme ' . l:name
    call s:SaveTheme(l:name)
    echo 'Tema aplicado: ' . l:name
  endif
endfunction

" Aplicar tema guardado al inicio (o retrobox si no hay ninguno)
let s:saved = s:LoadTheme()
if s:saved != ''
  execute 'colorscheme ' . s:saved
else
  colorscheme retrobox
  " Primera vez: pedir tema al terminar de cargar
  autocmd VimEnter * ++once call SelectTheme()
endif

set number relativenumber    " nros absoluto + relativo
set cursorline               " resalta linea actual
set colorcolumn=120          " linea vertical en col 120
set scrolloff=8              " margen al hacer scroll
set signcolumn=yes           " columna para errores/git
set nowrap
set showmatch                " resalta parentesis/brackets

" --- Indentacion ---
set tabstop=4
set shiftwidth=4
set expandtab                " espacios en vez de tabs
set smartindent
set autoindent

" --- Busqueda ---
set hlsearch                 " resalta resultados
set incsearch                " busqueda incremental
set ignorecase               " case insensitive
set smartcase                " case sensitive si hay mayusculas

" --- Grep con ripgrep ---
set grepprg=rg\ --vimgrep\ --smart-case
set grepformat=%f:%l:%c:%m

" --- Encontrar archivos (sin plugins) ---
set wildmenu
set wildmode=longest:full,full
set path+=**                 " busca en subcarpetas con :find

" --- Splits ---
set splitright
set splitbelow

" =============================================
"  File tree: netrw (built-in)
" =============================================
let g:netrw_banner     = 0   " sin banner
let g:netrw_liststyle  = 3   " vista de arbol
let g:netrw_winsize    = 25  " 25% de ancho
let g:netrw_browse_split = 4 " abre archivos en ventana anterior

" =============================================
"  Keymaps
" =============================================
let mapleader = " "

" File tree
nnoremap <leader>e :Lex<CR>

" Elegir tema
nnoremap <leader>ft :call SelectTheme()<CR>

" Buscar archivo por nombre
nnoremap <leader>f :find

" Limpiar resaltado de busqueda
nnoremap <Esc> :nohlsearch<CR>

" Buscar y reemplazar palabra bajo el cursor (en archivo actual)
nnoremap <leader>r :%s/\<<C-r><C-w>\>//g<Left><Left>

" Buscar palabra bajo cursor en TODOS los archivos → quickfix
nnoremap <leader>fw :grep <C-r><C-w><CR>:copen<CR>

" Buscar texto libre en TODOS los archivos → quickfix
nnoremap <leader>fg :grep<Space>

" Navegacion en quickfix (resultados de busqueda)
nnoremap <leader>n :cnext<CR>
nnoremap <leader>p :cprev<CR>
nnoremap <leader>c :cclose<CR>

" Navegar entre splits
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k

" Mover lineas arriba/abajo
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Guardar rapido
nnoremap <leader>s :w<CR>
nnoremap <leader>w :w<CR>

" Reajustar ventanas (splits)
nnoremap <leader>= <C-w>=        " igualar todas las ventanas
nnoremap <leader>+ :resize +5<CR>
nnoremap <leader>- :resize -5<CR>
nnoremap <leader>> :vertical resize +10<CR>
nnoremap <leader>< :vertical resize -10<CR>

" Cerrar buffer
nnoremap <leader>q :q<CR>

" Ver buffers abiertos y cambiar
nnoremap <leader>b :ls<CR>:b<Space>

" =============================================
"  Statusline minimalista (sin plugins)
" =============================================
set laststatus=2
set statusline=
set statusline+=\ %f                 " nombre archivo
set statusline+=\ %m                 " modificado [+]
set statusline+=%=                   " separador derecha
set statusline+=\ %y                 " tipo de archivo
set statusline+=\ %l:%c              " linea:columna
set statusline+=\ %p%%\             " porcentaje

" =============================================
"  Autocmds utiles
" =============================================
" Quitar espacios al final al guardar
autocmd BufWritePre * :%s/\s\+$//e

" Volver a la ultima posicion al abrir archivo
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
