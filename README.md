# dot-files

Dotfiles personales para Arch Linux con [Omarchy](https://omarchy.org/) (Hyprland).

## Contenido

| Directorio | Descripción |
|---|---|
| `config/hypr/` | Hyprland (WM, keybindings, monitores, animaciones) |
| `config/waybar/` | Barra de estado (layout + CSS) |
| `config/nvim/` | Neovim (init.vim) |
| `config/yazi/` | Gestor de archivos terminal (Rápido/Moderno) |
| `config/swayosd/` | OSD para volumen, brillo y caps-lock |
| `config/micro/` | Editor de texto CLI con atajos modernos |
| `config/kitty/` / `alacritty/` / `ghostty/` | Emuladores de terminal configurados |
| `config/walker/` | Lanzador de aplicaciones y menús |
| `config/mako/` | Sistema de notificaciones ligero |
| `config/btop/` / `fastfetch/` | Monitorización e info del sistema |
| `config/ranger/` | Gestor de archivos CLI clásico |
| `config/lazygit/` / `lazydocker/` | TUIs para gestión de Git y Docker |
| `config/nwg-look/` | Personalización de apariencia GTK |
| `config/ripgrep/` | Optimización de búsquedas en terminal |
| `config/mpv/` / `imv/` | Visores de contenido multimedia |
| `config/tmux/` | Multiplexor de terminal |
| `config/omarchy/` | Temas, hooks y extensiones de Omarchy |
| `config/mise/` | Gestor de versiones de herramientas (Node, Python, etc.) |
| `config/opencode/` | Configuración de OpenCode |
| `config/wiremix/` | Mezclador de audio Pipewire |
| `config/starship.toml` | Prompt de shell personalizable |
| `home/` | Dotfiles de base (`.bashrc`, `.bash_profile`, etc.) |

## Instalación

```bash
git clone https://github.com/nickhernd/dot-files.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

El script crea symlinks desde el repo hacia las ubicaciones correctas. Hace backup automático de cualquier archivo existente (`.bak`).

## Requisitos

- Arch Linux + [Omarchy](https://omarchy.org/)
- Hyprland, Waybar, Mako, Walker
- Neovim, Kitty/Alacritty/Ghostty
- Starship prompt
- Herramientas adicionales: `yazi`, `swayosd`, `micro`, `lazygit`, `lazydocker`
