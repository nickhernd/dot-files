#!/bin/bash
# =============================================================
# XP-Pen Deco LW/L -- Fix completo de configuración
# Ejecutar cuando la tablet no mapee bien la pantalla
# =============================================================
set -e

SETTINGS="$HOME/.config/OpenTabletDriver/settings.json"
OVERRIDE_DIR="$HOME/.config/systemd/user/opentabletdriver.service.d"
OVERRIDE="$OVERRIDE_DIR/override.conf"

echo "[1/4] Verificando override systemd (GDK_SCALE=1)..."
mkdir -p "$OVERRIDE_DIR"
if ! grep -q "GDK_SCALE=1" "$OVERRIDE" 2>/dev/null; then
    cat > "$OVERRIDE" << 'EOF'
[Service]
Environment=GDK_SCALE=1
EOF
    systemctl --user daemon-reload
    echo "    -> Override creado y recargado"
else
    echo "    -> OK (ya existía)"
fi

echo "[2/4] Escribiendo settings.json correctos..."
python3 - << 'PYEOF'
import json, sys

SETTINGS = __import__('os').path.expanduser("~/.config/OpenTabletDriver/settings.json")

# Valores correctos derivados del bug de OTD:
# OTD spec MaxX=50800, MaxY=30480 pero el dispositivo reporta max=32767
# Área efectiva: 32767/50800*254 = 163.835mm  y  32767/30480*152.4 = 163.835mm
TABLET_AREA = {"Width": 163.835, "Height": 92.157, "X": 81.9175, "Y": 81.9175, "Rotation": 0.0}
DISPLAY_AREA = {"Width": 1920.0, "Height": 1080.0, "X": 960.0, "Y": 540.0, "Rotation": 0.0}

try:
    with open(SETTINGS) as f:
        d = json.load(f)
except Exception:
    print("    ERROR: no se pudo leer settings.json"); sys.exit(1)

for profile in d["Profiles"]:
    ams = profile["AbsoluteModeSettings"]
    ams["Tablet"] = TABLET_AREA
    ams["Display"] = DISPLAY_AREA
    ams["EnableClipping"] = True
    ams["EnableAreaLimiting"] = False
    ams["LockAspectRatio"] = True

d["LockUsableAreaDisplay"] = False
d["LockUsableAreaTablet"] = False

with open(SETTINGS, "w") as f:
    json.dump(d, f, indent=2)

print("    -> settings.json actualizado")
PYEOF

echo "[3/4] Aplicando configuración al daemon OTD..."
if otd loadsettings "$SETTINGS" 2>/dev/null; then
    echo "    -> OK"
else
    echo "    -> Reiniciando daemon..."
    systemctl --user restart opentabletdriver
    sleep 3
    otd loadsettings "$SETTINGS" 2>/dev/null && echo "    -> OK tras reinicio"
fi

echo "[4/4] Verificando resultado..."
sleep 1
AREA=$(otd getareas "XP-Pen Deco L" 2>/dev/null)
echo "$AREA"

if echo "$AREA" | grep -q "163.835"; then
    echo ""
    echo "✓ Tablet configurada correctamente."
    echo "  Mueve el lápiz hasta los 4 bordes para confirmar."
else
    echo ""
    echo "⚠ Algo falló. Ejecuta: systemctl --user restart opentabletdriver"
    echo "  y luego vuelve a lanzar este script."
fi
