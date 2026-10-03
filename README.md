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
| `config/omarchy/themes/moon-pink/` | Tema Moon Pink (rosa `#ff9ed2`, lavanda `#c8b6ff`, fondo `#1a1625`) |
| `config/yazi/` | yazi con plugins (git, previews con glow/hexyl/eza, ouch, mount, chmod…) y flavor Moon Pink |
| `config/omarchy/shell.json` | Shell de Omarchy (barra oculta; notificaciones/OSD/fondo los da el rice) |
| `config/rclone/` `config/systemd/user/` | Google Drive montado en `~/GoogleDrive` (`gdrive-mount.service`); `gdrive-sync` bidireccional como alternativa |
| `wallpapers/` | Fondo actual (Malaz en Moon Pink, créditos en `wallpapers/CREDITOS.md`) |
| `home/` | `.bashrc`, `.bash_profile`, scripts de `~/.local/bin` |

### Widgets de escritorio (tema *Still*, en español)

Reloj · tiempo (wttr.in) · seguridad (cortafuegos, puertos, CVEs) · fórmula del día (Typst) · noticias de El País ·
tiempo programando · pomodoro · música · sistema · batería · red · desarrollo (Docker, git, GitHub).
Borde izquierdo de la pantalla: centro de control.

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

## Instalación en un ordenador nuevo (automática)

Requisito: [Omarchy](https://omarchy.org/) instalado.

```bash
git clone https://github.com/nickhernd/dot-files.git ~/dot-files
~/dot-files/bootstrap.sh          # pregunta qué bloques instalar
~/dot-files/bootstrap.sh --all    # todo sin preguntar
```

`bootstrap.sh` hace, en orden:

1. `install.sh` — enlaces de la config (backup `.bak` de lo existente; nunca reemplaza `~/.local` entero)
2. `instalar-rice.sh` — rice de Quickshell, TUIs, LaTeX/Typst, Python científico, Docker, rclone
3. `instalar-extras.sh` — TeXstudio, sioyek, Zotero, Anki, Lean 4, atuin, direnv, just…
4. `instalar-seguridad.sh` — bajo nivel (nasm, pwndbg, qemu, cross-compiladores), ingeniería inversa (ghidra, rizin/cutter, imhex), redes (wireshark, nmap), protección (arch-audit, lynis, opensnitch) y laboratorio de VMs
5. Fuentes de iconos, `wallpapers.sh` (descarga los fondos de `wallpapers.txt` y genera los del tema), tema **Moon Pink** y plugins de Neovim/yazi

El fondo actual está en `wallpapers/` (*The Longest Sword* de Ina Wong, [artofinca.com](https://artofinca.com),
recoloreado en Moon Pink). El resto se descargan de wallhaven.cc.

Pasos manuales al final: `~/.config/secrets.env`, `gh auth login`, `rclone config create gdrive drive` y `systemctl --user enable --now gdrive-mount.service`.

## Actualizar el repo

```bash
./update.sh   # ejecuta sync.sh (sistema -> repo), commit y push opcional
```
