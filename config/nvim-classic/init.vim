" Auto-instala vim-plug si falta
let s:plug = stdpath('data') . '/site/autoload/plug.vim'
if empty(glob(s:plug))
  silent execute '!curl -fLo ' . s:plug . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" =============================================
"  Neovim con vim-plug
" =============================================

call plug#begin('~/.local/share/nvim/plugged')

" Auto-cierre de paréntesis
Plug 'windwp/nvim-autopairs'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'

" Autocompletado
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'

" Snippets (requerido por nvim-cmp)
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

" Búsqueda con preview (fzf)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

call plug#end()

" ---- Configuracion de LSP + autocompletado (Lua) ----
lua << EOF

-- mason: instala servidores LSP facilmente con :MasonInstall <nombre>
require('mason').setup()
require('mason-lspconfig').setup()


local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),   -- forzar menu
    ['<CR>']      = cmp.mapping.confirm({ select = true }),
    ['<Tab>']     = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
      else fallback() end
    end, { 'i', 's' }),
    ['<S-Tab>']   = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then luasnip.jump(-1)
      else fallback() end
    end, { 'i', 's' }),
    ['<C-e>'] = cmp.mapping.abort(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
})

-- Auto-cierre de paréntesis integrado con nvim-cmp
require('nvim-autopairs').setup({})
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

-- Conectar nvim-cmp con los servidores LSP
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Ejemplo: activa pyright para Python. Instala con :MasonInstall pyright
-- require('lspconfig').pyright.setup({ capabilities = capabilities })

-- Ejemplo: activa tsserver para JS/TS. Instala con :MasonInstall typescript-language-server
-- require('lspconfig').ts_ls.setup({ capabilities = capabilities })

-- Ejemplo: clangd para C/C++. Instala con :MasonInstall clangd
-- require('lspconfig').clangd.setup({ capabilities = capabilities })

EOF

" =============================================
"  fzf: búsqueda con preview
" =============================================
let g:fzf_preview_window = ['right:50%:wrap', 'ctrl-/']
let g:fzf_layout = { 'window': { 'width': 0.92, 'height': 0.85, 'border': 'rounded' } }

command! -bang -nargs=* RG
  \ call fzf#vim#grep2(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- ', <q-args>,
  \   fzf#vim#with_preview({'options': ['--delimiter=:', '--nth=4..']}),
  \   <bang>0)

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
let g:netrw_banner     = 0
let g:netrw_liststyle  = 3
let g:netrw_winsize    = 25

" Abrir archivos de netrw siempre en la ventana de la derecha
function! s:NetrwOpenRight()
  let l:cur  = expand('<cfile>')
  let l:base = substitute(get(b:, 'netrw_curdir', getcwd()), '/$', '', '')
  let l:path = simplify((l:cur =~# '^/') ? l:cur : l:base . '/' . l:cur)

  if isdirectory(l:path)
    " Dejar que netrw maneje el toggle del directorio de forma nativa
    call feedkeys("\<Plug>NetrwLocalBrowseCheck", 'n')
    return
  endif

  if filereadable(l:path)
    for w in range(1, winnr('$'))
      if getbufvar(winbufnr(w), '&filetype') !=# 'netrw'
        execute w . 'wincmd w'
        execute 'edit ' . fnameescape(l:path)
        return
      endif
    endfor
    wincmd v
    execute 'edit ' . fnameescape(l:path)
  endif
endfunction

augroup NetrwOpenRight
  autocmd!
  autocmd FileType netrw nnoremap <buffer> <CR> :call <SID>NetrwOpenRight()<CR>
augroup END

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

" Buscar palabra bajo cursor en todos los archivos (con preview)
nnoremap <leader>fw :RG <C-r><C-w><CR>

" Buscar texto libre en todos los archivos (live grep con preview)
nnoremap <leader>fg :RG<CR>

" Buscar archivo por nombre (con preview)
nnoremap <leader>ff :Files<CR>

" Navegacion en quickfix (resultados de busqueda)
nnoremap <leader>n :cnext<CR>
nnoremap <leader>p :cprev<CR>
nnoremap <leader>c :cclose<CR>

" Navegar entre splits (hjkl y Ctrl+flechas)
nnoremap <C-h>     <C-w>h
nnoremap <C-l>     <C-w>l
nnoremap <C-j>     <C-w>j
nnoremap <C-k>     <C-w>k
nnoremap <C-Left>  <C-w>h
nnoremap <C-Right> <C-w>l
nnoremap <C-Down>  <C-w>j
nnoremap <C-Up>    <C-w>k

" Redimensionar ventanas con Shift+flechas
nnoremap <S-Left>  :vertical resize -3<CR>
nnoremap <S-Right> :vertical resize +3<CR>
nnoremap <S-Up>    :resize +3<CR>
nnoremap <S-Down>  :resize -3<CR>

" Mover lineas arriba/abajo
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv
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


" Terminal
" Abrir terminal a la derecha y entrar en modo insert automáticamente
nnoremap <leader>t :vsplit <bar> terminal<CR>i

" Salir del modo terminal con Esc
tnoremap <Esc> <C-\><C-n>

" Portapapeles (Copy/Paste estilo estándar)
vnoremap <C-c> "+y
vnoremap <C-x> "+x
nnoremap <C-v> "+p
inoremap <C-v> <C-r>+
vnoremap <C-v> "+p

" Habilitar el uso del portapapeles del sistema por defecto
set clipboard+=unnamedplus

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

" Auto-guardado cada 15 segundos
set updatetime=15000
autocmd CursorHold,CursorHoldI * silent! update

" Ajuste para rellenar espacio inferior
set cmdheight=1
