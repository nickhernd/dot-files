#!/usr/bin/env bash
# TUIs recomendadas (ingeniería informática, mates, bajo nivel y seguridad).
source "$(dirname "${BASH_SOURCE[0]}")/lib-paquetes.sh"

echo ":: Sistema"
#  lazyjournal: logs de journalctl/docker con búsqueda · isd: gestionar servicios systemd
#  nvtop: uso de GPU · bluetui / impala: bluetooth y wifi
instalar lazyjournal isd nvtop bluetui impala

echo ":: Git"
#  serie: grafo de commits y ramas del repo con imágenes en la terminal (va bien en kitty)
instalar serie

echo ":: Redes y seguridad"
#  termshark: Wireshark en terminal · bandwhich: ancho de banda por proceso/conexión
#  trippy (trip): traceroute + ping con gráficas · gping: ping con gráfica
instalar termshark bandwhich trippy gping

echo ":: Datos y documentos"
#  csvlens: ver CSV como tabla · jless / fx: explorar JSON · presenterm: diapositivas en Markdown
instalar csvlens jless fx presenterm

echo ":: Organización"
#  newsboat: noticias RSS (El País + seguridad ya configurado) · calcurse: calendario y agenda
#  taskwarrior-tui: tareas con prioridades y fechas
instalar newsboat calcurse taskwarrior-tui

echo ":: Música"
#  ytermusic: YouTube Music en terminal (tus listas y biblioteca) · reproduce con mpv + yt-dlp
instalar ytermusic mpv yt-dlp

echo ":: Estudio y mates"
#  kalker: calculadora con sintaxis matemática (funciones, sumatorios, integrales, derivadas)
#  visidata: hoja de cálculo/análisis de datos en terminal (CSV, JSON, SQLite, Excel)
#  wiki-tui: Wikipedia en la terminal · ttyper: practicar mecanografía
instalar kalker visidata wiki-tui ttyper

echo ":: Productividad y seguridad"
#  television (tv): buscador difuso universal (archivos, texto, git, procesos, env...)
#  lnav: navegar y analizar logs (detecta formatos, filtra, SQL sobre logs)
#  sshs: elegir host de ~/.ssh/config · dysk: discos y puntos de montaje
instalar television lnav sshs dysk

echo ""
echo "Listo ✔  Prueba: serie (dentro de un repo) · newsboat · lazyjournal · trip 1.1.1.1 · sudo bandwhich · ytermusic · kalker · tv"

resumen
