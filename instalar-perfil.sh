#!/usr/bin/env bash
# Herramientas de mi perfil: visión/datos, verificación formal, embebidos, FPGA,
# GameBoy (Z80), Java/compiladores, perfilado, TUIs y drones.
#   ./instalar-perfil.sh            todo
#   ./instalar-perfil.sh --sin-opam sin Frama-C/Why3/Alt-Ergo (tardan ~30 min en compilar)
source "$(dirname "${BASH_SOURCE[0]}")/lib-paquetes.sh"
OPAM=1; [[ ${1:-} == --sin-opam ]] && OPAM=0

echo ":: Datos y notebooks"
#  pgcli: psql con autocompletado · duckdb: SQL directo sobre CSV/Parquet/GeoJSON
#  marimo: notebooks de Python como .py (se versionan bien) · harlequin: TUI de SQL (DuckDB y Postgres)
instalar pgcli duckdb
uv tool install --upgrade marimo || FALLIDOS+=(marimo)
uv tool install --upgrade 'harlequin[postgres]' || FALLIDOS+=(harlequin)

echo ":: C++ avanzado"
#  ninja + mold + ccache: compilar y enlazar mucho más rápido · lldb · rr: grabar una ejecución y
#  depurarla hacia atrás · catch2/gtest + benchmark: tests y microbenchmarks
#  include-what-you-use: limpiar includes · bear: compile_commands.json para clangd · conan: paquetes
instalar ninja mold ccache lldb rr catch2 gtest benchmark include-what-you-use bear perf
uv tool install --upgrade conan || FALLIDOS+=(conan)
# rr necesita poder leer los contadores de rendimiento
[[ $(cat /proc/sys/kernel/perf_event_paranoid 2>/dev/null) -le 1 ]] || {
  echo 'kernel.perf_event_paranoid = 1' | sudo tee /etc/sysctl.d/90-rr.conf >/dev/null
  sudo sysctl -q kernel.perf_event_paranoid=1; }

echo ":: Verificación formal"
#  cppcheck (con el addon MISRA desde Neovim) · z3/cvc5: probadores SMT para Why3/Frama-C
#  tlc: TLA+ (el jar oficial, lo baja ~/.local/bin/tlc la primera vez; necesita Java)
instalar cppcheck clang z3 cvc5 jdk-openjdk
tlc -h >/dev/null 2>&1 || true
if ((OPAM)); then
  #  Frama-C (WP con ACSL), Why3 y Alt-Ergo no están en Arch: van con opam (OCaml)
  instalar opam gmp zlib gtk3 gtksourceview3 graphviz
  [[ -d $HOME/.opam ]] || opam init -y --disable-sandboxing --bare
  opam switch list 2>/dev/null | grep -q frama || opam switch create frama ocaml-base-compiler.5.2.1 -y
  if opam install -y --switch=frama alt-ergo why3 frama-c; then
    opam exec --switch=frama -- why3 config detect || true
  else
    FALLIDOS+=(frama-c)
  fi
fi

echo ":: Embebidos (ESP32 / FreeRTOS)"
#  esp-idf: SDK oficial en /opt/esp-idf; las toolchains van a ~/.espressif
#  (actívalo en cada terminal con 'get_idf') · platformio · picocom: puerto serie
instalar platformio-core picocom esp-idf
[[ -x /opt/esp-idf/install.sh && ! -d $HOME/.espressif/tools ]] && { /opt/esp-idf/install.sh esp32,esp32s3,esp32c3 || FALLIDOS+=(esp-idf-toolchains); }

echo ":: FPGA / SystemVerilog"
#  Simulación y síntesis libres sin abrir Vivado; verible (LSP y formato) lo pone Mason en Neovim
instalar verilator iverilog gtkwave yosys

echo ":: GameBoy (Z80)"
#  rgbds: ensamblador · sameboy / mgba: emuladores · bgb: emulador con depurador (wine, ~/.local/bin/bgb)
instalar rgbds sameboy mgba-qt wine

echo ":: Java (compiladores: Java -> ensamblador)"
#  jdtls: servidor de Java para Neovim (el de Mason falla bajando lombok); flex y bison ya vienen
instalar jdk-openjdk jdtls wget

echo ":: Perfilado y documentación"
#  heaptrack: memoria · hotspot: perf con flame graphs · zeal: documentación offline (OpenCV, PyTorch, C++...)
instalar heaptrack hotspot zeal

echo ":: TUIs"
#  binsider: ELF · dive: capas de imágenes Docker · mprocs: varios procesos en un panel
#  jqp: jq interactivo · navi: chuletas interactivas · doxx: .docx en la terminal
instalar binsider dive mprocs jqp navi doxx

echo ":: Drones"
#  QGroundControl: estación de tierra PX4/ArduPilot · MAVProxy: MAVLink desde la terminal
#  WebODM (fotogrametría: ortofotos, MDS, nubes de puntos) va en Docker: ~/.local/bin/webodm start
instalar qgroundcontrol-bin
uv tool install --upgrade mavproxy || FALLIDOS+=(mavproxy)

echo ""
echo "Listo ✔  Prueba: marimo edit · harlequin · pgcli · duckdb · tlc Spec.tla · frama-c -wp archivo.c"
echo "   mprocs · binsider ./binario · dive imagen · navi · webodm start · get_idf (ESP-IDF)"

resumen
