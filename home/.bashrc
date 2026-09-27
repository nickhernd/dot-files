# Omarchy environment (OMARCHY_PATH + PATH), needed even for non-interactive shells
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# If not running interactively, don't do anything else (leave this above the rc source)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source "$OMARCHY_PATH/default/bash/rc"

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# ---- Personal (portado de dot-files) ----
alias search='w3m "https://duckduckgo.com/html?q="'
alias gsync='gdrive-sync'
alias gsync-preview='gdrive-sync --dry-run'
alias gsync-log='gdrive-sync --status'

export EDITOR=nvim
export VISUAL=nvim
export PATH="$HOME/.local/bin:$PATH"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

# Secretos (API keys) fuera del repo de dot-files
[[ -r ~/.config/secrets.env ]] && source ~/.config/secrets.env

# FZF Moon Pink Theme
export FZF_DEFAULT_OPTS="
  --color=bg+:#2a1f38,bg:#1a1625,spinner:#ff9ed2,hl:#ffc2e8:bold:underline
  --color=fg:#e6d5f0,header:#ff9ed2,info:#c8b6ff,pointer:#ff9ed2
  --color=marker:#ffb3d9,fg+:#ffffff,prompt:#ff9ed2,hl+:#ffc2e8:bold:underline
  --color=border:#d47fa6,label:#ff9ed2,query:#e6d5f0
  --color=gutter:#1a1625,selected-bg:#d47fa6,selected-fg:#ffffff
  --border=rounded
  --border-label-pos=0
  --preview-window=border-rounded
  --padding=1
  --margin=1
  --prompt='  '
  --marker=' '
  --pointer=' '
  --separator='─'
  --scrollbar='│'
"

# Yazi: cambiar directorio al salir
function ya() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
alias nvim-classic='NVIM_APPNAME=nvim-classic nvim'

# ---- Herramientas de trabajo ----
alias gd='gh dash'          # issues/PRs de GitHub
alias lzd='lazydocker'
alias df='duf'
alias http='xh'
alias md='glow'
alias calc='qalc'
alias math='mathpad'
