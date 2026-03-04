# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

alias search='w3m "https://duckduckgo.com/html?q="'

# Editor por defecto
export EDITOR=nvim
export VISUAL=nvim

# Gemini API Key (get yours at https://aistudio.google.com/apikey)
export GEMINI_API_KEY="AIzaSyA252rgL4vxZNVWO4RF2XF6Ex7Eu7LCmqU"
export PATH="$HOME/.local/bin:$PATH"

# Ripgrep config
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

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
