# dot-files

Dotfiles personales para Arch Linux con [Omarchy 4](https://omarchy.org/) (Hyprland con configuración en Lua) y el rice de Quickshell [dhrruvsharma/shell](https://github.com/dhrruvsharma/shell), adaptado.

## Contenido

| Directorio | Descripción |
|---|---|
| `config/hypr/` | Hyprland en Lua: monitores (escala 1), teclado ES, look del rice, atajos, modo ratón |
| `config/quickshell/` | Rice de Quickshell: barra, centro de control, wallpapers, lockscreen y widgets de escritorio |
| `config/matugen/` | Plantillas de colores generados desde el wallpaper (Quickshell, kitty, Hyprland, rofi, cava) |
| `config/rofi/` `config/cava/` | Menús y visualizador de audio del rice |
| `config/kitty/` `foot/` `ghostty/` `alacritty/` | Terminales |
| `config/nvim/` | LazyVim + extras (Python, C/C++, LaTeX, Typst, Markdown, SQL, Docker) y mis atajos |
| `config/nvim-classic/` | Mi config antigua con vim-plug (`nvim-classic`) |
| `config/gh-dash/` | TUI de issues y PRs de GitHub |
| `config/omarchy/shell.json` | Shell de Omarchy (barra oculta; notificaciones/OSD/fondo los da el rice) |
| `config/rclone/` `config/systemd/user/` | Sincronización con Google Drive cada 15 min |
| `home/` | `.bashrc`, `.bash_profile`, scripts de `~/.local/bin` |

### Widgets de escritorio (tema *Still*, en español)

Reloj · tiempo (wttr.in) · tareas (`~/todo.md`) · fórmula del día (Typst) · entregas (`~/deadlines.md`) ·
tiempo programando · pomodoro · música · sistema · batería · red · desarrollo (Docker, git, GitHub).

### Atajos principales

| Atajo | Acción |
|---|---|
| `SUPER+ALT+C / N / W / P` | Centro de control / red / wallpaper / apagado |
| `SUPER+ALT+O` | Pomodoro iniciar/pausar |
| `SUPER+SHIFT+I` | gh-dash (issues/PRs) |
| `SUPER+SHIFT+D` | lazydocker |
| `SUPER+SHIFT+J` | mathpad (IPython + SymPy) |
| `SUPER+SHIFT+Q` | calculadora qalc |
| `SUPER+SHIFT+U` / `K` | yazi / gdu |
| `SUPER+ALT+M` | modo ratón con teclado |

## Instalación

```bash
git clone https://github.com/nickhernd/dot-files.git ~/dot-files
cd ~/dot-files
./install.sh          # symlinks (con backup .bak de lo existente)
./instalar-rice.sh    # paquetes: rice, TUIs, LaTeX/Typst, Python científico, rclone, Docker
```

Después: `gh auth login`, `gh extension install dlvhdr/gh-dash`, `gdrive-sync --setup` y
`systemctl --user enable --now gdrive-sync.timer`.

Los secretos (API keys) van en `~/.config/secrets.env`, que **no** está en el repo.

## Actualizar el repo

```bash
./update.sh   # ejecuta sync.sh (sistema -> repo), commit y push opcional
```
