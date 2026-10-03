#!/usr/bin/env bash
# TUIs recomendadas (ingeniería informática, mates, bajo nivel y seguridad).
set -e

echo ":: Sistema"
#  lazyjournal: logs de journalctl/docker con búsqueda · isd: gestionar servicios systemd
#  nvtop: uso de GPU · bluetui / impala: bluetooth y wifi
yay -S --needed lazyjournal isd nvtop bluetui impala

echo ":: Redes y seguridad"
#  termshark: Wireshark en terminal · bandwhich: ancho de banda por proceso/conexión
#  trippy (trip): traceroute + ping con gráficas · gping: ping con gráfica
yay -S --needed termshark bandwhich trippy gping

echo ":: Datos y documentos"
#  csvlens: ver CSV como tabla · jless / fx: explorar JSON · presenterm: diapositivas en Markdown
yay -S --needed csvlens jless fx presenterm

echo ":: Organización"
#  newsboat: noticias RSS (El País + seguridad ya configurado) · calcurse: calendario y agenda
#  taskwarrior-tui: tareas con prioridades y fechas · ncspot: Spotify en terminal
yay -S --needed newsboat calcurse taskwarrior-tui ncspot

echo ""
echo "Listo ✔  Prueba: newsboat · lazyjournal · trip 1.1.1.1 · sudo bandwhich · csvlens archivo.csv"
