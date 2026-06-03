#!/bin/bash
# =============================================================
# XP-Pen Deco LW/L -- Diagnóstico rápido del estado actual
# =============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

echo "========================================="
echo " XP-Pen Deco LW/L -- Estado de la tablet"
echo "========================================="

# 1. Servicio OTD
echo ""
echo "[ Servicio OpenTabletDriver ]"
if systemctl --user is-active opentabletdriver -q; then
    ok "Servicio activo"
else
    fail "Servicio INACTIVO -- ejecuta: systemctl --user start opentabletdriver"
fi

# 2. GDK_SCALE en el daemon
echo ""
echo "[ Variable GDK_SCALE en el daemon ]"
PID=$(systemctl --user show opentabletdriver --property=MainPID --value 2>/dev/null)
if [ -n "$PID" ] && [ "$PID" != "0" ]; then
    GDK=$(cat /proc/$PID/environ 2>/dev/null | tr '\0' '\n' | grep GDK_SCALE | cut -d= -f2)
    if [ "$GDK" = "1" ]; then
        ok "GDK_SCALE=1 (correcto)"
    else
        fail "GDK_SCALE=$GDK (debe ser 1) -- ejecuta: 1_fix_xppen.sh"
    fi
else
    warn "No se pudo leer el entorno del daemon"
fi

# 3. Override systemd
echo ""
echo "[ Override systemd ]"
OVERRIDE="$HOME/.config/systemd/user/opentabletdriver.service.d/override.conf"
if grep -q "GDK_SCALE=1" "$OVERRIDE" 2>/dev/null; then
    ok "Override presente: $OVERRIDE"
else
    fail "Override ausente -- ejecuta: 1_fix_xppen.sh"
fi

# 4. Áreas OTD en memoria
echo ""
echo "[ Áreas OTD (en memoria del daemon) ]"
AREA=$(otd getareas "XP-Pen Deco L" 2>/dev/null)
if echo "$AREA" | grep -q "163.835"; then
    ok "Tablet area correcta (163.835×92.157)"
elif echo "$AREA" | grep -q "1920x1080"; then
    TAREA=$(echo "$AREA" | grep -i tablet)
    fail "Tablet area INCORRECTA: $TAREA"
    warn "  Debe ser 163.835×92.157 -- ejecuta: 1_fix_xppen.sh"
else
    warn "No se pudo leer las áreas (¿tablet desconectada?)"
fi

# 5. settings.json en disco
echo ""
echo "[ settings.json en disco ]"
WIDTH=$(python3 -c "
import json
d=json.load(open('$HOME/.config/OpenTabletDriver/settings.json'))
print(d['Profiles'][0]['AbsoluteModeSettings']['Tablet']['Width'])
" 2>/dev/null)
if [ "$WIDTH" = "163.835" ]; then
    ok "settings.json correcto (Width=163.835)"
else
    fail "settings.json INCORRECTO (Width=$WIDTH, debe ser 163.835) -- ejecuta: 1_fix_xppen.sh"
fi

# 6. uinput ABS max
echo ""
echo "[ Dispositivo uinput (lo que ve Hyprland) ]"
ABSMAX=$(python3 -c "
import struct, fcntl, glob
def EVIOCGABS(a): return (2<<30)|(24<<16)|(0x45<<8)|(0x40+a)
for e in sorted(glob.glob('/dev/input/event*')):
    try:
        with open(e,'rb') as f:
            buf=bytearray(256); fcntl.ioctl(f,0x80ff4506,buf)
            name=buf.split(b'\x00')[0].decode()
            if 'OpenTablet' in name:
                buf2=bytearray(24); fcntl.ioctl(f,EVIOCGABS(0),buf2)
                print(struct.unpack('iiiiii',buf2)[2])
    except: pass
" 2>/dev/null)
if [ "$ABSMAX" = "1920000" ]; then
    ok "ABS_X max=1920000 (correcto)"
else
    fail "ABS_X max=$ABSMAX (debe ser 1920000)"
fi

# 7. Monitor virtual activo
echo ""
echo "[ Monitors activos ]"
hyprctl monitors 2>/dev/null | grep "Monitor" | while read -r line; do
    warn "$line"
done

echo ""
echo "========================================="
