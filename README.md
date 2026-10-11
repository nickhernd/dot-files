# dot-files

Dotfiles personales para Arch Linux con [Omarchy 4](https://omarchy.org/) (Hyprland con configuración en Lua) y el rice de Quickshell [dhrruvsharma/shell](https://github.com/dhrruvsharma/shell), adaptado.

## Contenido

| Directorio | Descripción |
|---|---|
| `config/hypr/` | Hyprland en Lua: monitores (escala 1), teclado ES, look del rice, atajos, modo ratón; lo propio de cada máquina en `perfiles/` |
| `config/quickshell/` | Rice de Quickshell: barra, centro de control, wallpapers, lockscreen y widgets de escritorio |
| `config/matugen/` | Plantillas de colores generados desde el wallpaper (Quickshell, kitty, Hyprland, rofi, cava) |
| `config/rofi/` `config/cava/` | Menús y visualizador de audio del rice |
| `config/kitty/` `foot/` `ghostty/` `alacritty/` | Terminales |
| `config/nvim/` | LazyVim + extras (Python, C/C++, LaTeX, Typst, Markdown, SQL, Docker) y mis atajos |
| `config/nvim-classic/` | Mi config antigua con vim-plug (`nvim-classic`) |
| `config/gh-dash/` | TUI de issues y PRs de GitHub |
| `config/omarchy/themes/moon-pink/` | Tema Moon Pink (rosa `#ff9ed2`, lavanda `#c8b6ff`, fondo `#1a1625`) |
| `config/yazi/` | yazi con plugins (git, previews con glow/hexyl/eza, ouch, mount, chmod…) y flavor Moon Pink |
| `config/termshark/themes/` | Tema Moon Pink para termshark (Wireshark en terminal); `install.sh` lo deja activo |
| `config/omarchy/shell.json` | Shell de Omarchy (barra oculta; notificaciones/OSD/fondo los da el rice) |
| `config/rclone/` `config/systemd/user/` | Google Drive montado en `~/GoogleDrive` (`gdrive-setup` + `gdrive-mount.service`); `gdrive-sync` bidireccional como alternativa |
| `wallpapers/` | Fondos Malaz en Moon Pink: *Ascendiente* (sobremesa) y *The Longest Sword* (portátil); créditos en `wallpapers/CREDITOS.md` |
| `home/` | `.bashrc`, `.bash_profile`, scripts de `~/.local/bin` |

### Widgets de escritorio (tema *Still*, en español)

Reloj · tiempo (wttr.in) · seguridad (cortafuegos, puertos, CVEs) · GPU NVIDIA · contribuciones de GitHub · fórmula del día (Typst) · ciencia de El País y palabra del día (Wikcionario) ·
tiempo programando · pomodoro · música · sistema · batería · red · desarrollo (Docker, git, GitHub).
Borde izquierdo de la pantalla: centro de control, con **Enfoque** (pomodoro con historial semanal) y **Hábitos**.

### Tracker de hábitos

Diarios: rachas (sin fap, sin Monster), sin redes, hidratación, sueño, deporte, natación, lectura, estudio
(pomodoros automáticos), RAE, palabra del día, Wikipedia, conocimiento diario, escribir diario, Gmail/WhatsApp/
Telegram, preparar comidas, agenda y cuidado personal. **Cada domingo**: preparar la semana, limpiar y actualizar
portátil y sobremesa, revisar gastos. **Cada día 1**: organizar series/películas/libros/teatro, proyectos de
GitHub, clubes de lectura, suscripciones. Más libros con marcapáginas.

**Excel** (semanas de **sábado a viernes**): `~/Documents/Tracker/habitos.xlsx` y copia en
`~/GoogleDrive/Tracker/`, regenerado solo en cada sincronización (`tracker excel` para forzarlo). Hojas: Semanas,
Resumen (% con fórmulas), Periódicas, Registro, Libros y Leyenda. Se usa desde el panel izquierdo o con `tracker` en la terminal (`tracker week`, `tracker add-book`,
`tracker start nofap AAAA-MM-DD`, `tracker edit` para añadir hábitos…).

Datos en `~/.local/share/tracker/tracker.json`, **sincronizados entre ordenadores** a través de este repo
con una copia cifrada (AES-256) en `data/tracker/tracker.json.enc`. `tracker-backup` baja la copia del repo,
la **combina** con la local (contadores → el mayor, casillas → hecho en cualquiera, rachas → la recaída más
reciente, libros → la página más avanzada) y sube el resultado. Se ejecuta al encender, cada 15 min y 2 min
después de cada cambio en el panel; a mano: `tracker sync`.

La clave (`~/.config/tracker/backup.key`) **no está en el repo** y tiene que ser **la misma** en todos los
ordenadores. En uno nuevo: copia la clave y ejecuta `tracker sync`.

### Atajos principales

| Atajo | Acción |
|---|---|
| `SUPER+ALT+C / N / W / P` | Centro de control / red / wallpaper / apagado |
| `SUPER+ALT+O` | Pomodoro iniciar/pausar |
| `SUPER+SHIFT+I` | gh-dash (issues/PRs) |
| `serie` | grafo de commits y ramas del repo actual (TUI, imágenes en kitty) |
| `SUPER+SHIFT+D` | lazydocker |
| `SUPER+SHIFT+J` | mathpad (IPython + SymPy) |
| `SUPER+SHIFT+Q` | calculadora qalc |
| `SUPER+SHIFT+U` / `K` | yazi / gdu |
| `SUPER+ALT+M` | modo ratón con teclado |
| `nb archivo.py` / `sql` | notebook marimo / harlequin (SQL sobre DuckDB o Postgres) |
| `tlc Spec.tla` | model checker de TLA+ (en Neovim: `\m` TLC, `\p` PlusCal, `\s` SANY) |
| `<leader>cM` (Neovim) | activar/desactivar MISRA en cppcheck |
| `get_idf` | activar ESP-IDF en la terminal |
| `webodm start` | WebODM en http://localhost:8000 (fotogrametría de dron) |

### C/C++

`cpp-new nombre` crea un proyecto C++23 compilado y con git: CMakePresets (`debug` con ASan+UBSan, `release`
-O3+LTO, `relwithdeb` para perf/rr, `tsan`), ninja + mold + ccache, warnings estrictos, `.clang-tidy` (clangd lo
aplica al escribir), `.clang-format`, Catch2 y Google Benchmark. `cpp-new --c nombre`: C11 para embebido con
cppcheck + MISRA en cada compilación y un ejemplo con ACSL para Frama-C.

| Terminal | Neovim (`<leader>m…`) |
|---|---|
| `cb` / `ct` / `cr` / `cbench` — compilar / tests / ejecutar / benchmarks (`CPRESET=release cb`) | `p` preset · `b` compilar · `r` ejecutar · `t` tests · `d` depurar |
| `perf-flame ./build/relwithdeb/prog` — perf + flame graph en hotspot | `a` ensamblador (Compiler Explorer) |
| `asm-diff archivo.cpp -O2 -O3` — diferencias del ensamblador | `R` reproducir la última grabación de `rr record` y depurar hacia atrás |

## Perfiles: portátil y sobremesa

Lo que cambia entre ordenadores se elige con un perfil, guardado en `~/.config/dotfiles/perfil` (fuera del
repo). `install.sh` lo pregunta la primera vez; para cambiarlo: `./install.sh --perfil sobremesa|portatil`.

| | Portátil | Sobremesa |
|---|---|---|
| Monitores (`config/hypr/perfiles/`) | pantalla interna `eDP-1` | AOC (`DP-4`) a la izquierda, Samsung (`HDMI-A-1`) a la derecha |
| Barra, reloj, widgets, tracker y paneles | en la pantalla interna | en el AOC; el Samsung solo con el fondo |
| Fondo inicial | *The Longest Sword* | *Ascendiente* |
| Tableta | `eDP-1` | Samsung |

La pantalla del rice se define en `config/quickshell/services/Screens.qml`. Si cambias de monitor, actualiza
ese archivo y `config/hypr/perfiles/sobremesa.lua`.

**Teclado**: Bloq Mayús funciona normal (Omarchy lo usa como tecla Compose); Compose está en la tecla Menú.

## Instalación en un ordenador nuevo (automática)

Requisito: [Omarchy](https://omarchy.org/) instalado.

```bash
git clone https://github.com/nickhernd/dot-files.git ~/dot-files
~/dot-files/bootstrap.sh          # pregunta qué bloques instalar
~/dot-files/bootstrap.sh --all    # todo sin preguntar
```

`bootstrap.sh` hace, en orden:

1. `install.sh` — perfil de la máquina y enlaces de la config (backup `.bak` de lo existente; nunca reemplaza `~/.local` entero)
2. `instalar-rice.sh` — rice de Quickshell, TUIs, LaTeX/Typst, Python científico, Docker, rclone
3. `instalar-extras.sh` — TeXstudio, sioyek, Zotero, Anki, Lean 4, atuin, direnv, just…
4. `instalar-seguridad.sh` — bajo nivel (nasm, pwndbg, qemu, cross-compiladores), ingeniería inversa (ghidra, rizin/cutter, imhex), redes (wireshark, nmap), protección (arch-audit, lynis, opensnitch) y laboratorio de VMs
5. `instalar-perfil.sh` — mi perfil de trabajo: C++ avanzado (ninja, mold, ccache, rr, lldb, catch2, benchmark,
   include-what-you-use, conan), verificación (cppcheck + MISRA, Frama-C/Why3/Alt-Ergo con opam, z3, cvc5, TLA+ con
   `tlc`), ESP32 (esp-idf, platformio, picocom), FPGA (verilator, iverilog, gtkwave, yosys), GameBoy (rgbds, sameboy,
   mgba, `bgb` con wine), Java (jdk + jdtls), datos (marimo, pgcli, harlequin, duckdb), perfilado (heaptrack,
   hotspot), zeal, TUIs (binsider, dive, mprocs, jqp, navi, doxx) y drones (QGroundControl, MAVProxy, `webodm`)
6. Fuentes de iconos, `wallpapers.sh` (descarga los fondos de `wallpapers.txt` y genera los del tema), tema **Moon Pink** y plugins de Neovim/yazi

El fondo actual está en `wallpapers/` (*The Longest Sword* de Ina Wong, [artofinca.com](https://artofinca.com),
recoloreado en Moon Pink). El resto se descargan de wallhaven.cc.

Los instaladores de paquetes no se paran si uno falla: siguen y al final dicen cuáles no se instalaron. Se pueden
repetir cuando quieras (lo ya instalado se salta); para todos de una vez: `./instalar-todo.sh`.

Pasos manuales al final: `~/.config/secrets.env`, `gh auth login` y `gdrive-setup` (autoriza Google Drive en el
navegador y lo deja montado en `~/GoogleDrive` en cada arranque; `gdrive-setup --reauth` si caduca el permiso).

## Actualizar el repo

```bash
./update.sh   # ejecuta sync.sh (sistema -> repo), commit y push opcional
```
