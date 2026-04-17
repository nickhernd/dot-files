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
| `config/nwg-look/` / `gtk-*` | Personalización de apariencia GTK |
| `config/ripgrep/` | Optimización de búsquedas en terminal |
| `config/mpv/` / `imv/` | Visores de contenido multimedia |
| `config/starship.toml` | Prompt de shell personalizable |
| `home/` | Configuraciones de base (`.bashrc`, `.nanorc`, etc.) |
| `omarchy-core/` | Núcleo de configuraciones y temas de Omarchy |

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
