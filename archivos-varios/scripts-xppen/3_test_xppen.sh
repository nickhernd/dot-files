#!/bin/bash
# =============================================================
# XP-Pen Deco LW/L -- Test interactivo de movimiento
# Mueve el lápiz y ve las coordenadas en tiempo real
# Ctrl+C para salir
# =============================================================

echo "Leyendo eventos del lápiz... (Ctrl+C para salir)"
echo "Mueve el lápiz hasta los 4 bordes para ver si llega al 100%"
echo ""
echo "$(printf '%10s %7s  %10s %7s  %15s' 'ABS_X' '%X' 'ABS_Y' '%Y' 'Pixel (x,y)')"
echo "$(printf '%s' '------------------------------------------------------------------------')"

python3 - << 'EOF'
import struct, glob, signal, sys

EVENT_SIZE = 24
EV_ABS = 3
ABS_X, ABS_Y = 0, 1
MAX_X, MAX_Y = 1920000, 1080000

signal.signal(signal.SIGINT, lambda *_: sys.exit(0))

# Encontrar el dispositivo OTD
dev = None
for e in sorted(glob.glob('/dev/input/event*')):
    try:
        import fcntl
        with open(e, 'rb') as f:
            buf = bytearray(256)
            fcntl.ioctl(f, 0x80ff4506, buf)
            if b'OpenTablet' in buf:
                dev = e
                break
    except Exception:
        pass

if not dev:
    print("ERROR: No se encontró el dispositivo OTD. ¿Está la tablet conectada?")
    sys.exit(1)

last_x, last_y, prev = None, None, None
with open(dev, 'rb') as f:
    while True:
        data = f.read(EVENT_SIZE)
        if not data or len(data) < EVENT_SIZE:
            break
        _, _, typ, code, val = struct.unpack('qqHHi', data)
        if typ == EV_ABS:
            if code == ABS_X: last_x = val
            elif code == ABS_Y: last_y = val
        if typ == 0 and last_x is not None and last_y is not None:
            cur = (last_x, last_y)
            if cur == prev:
                continue
            prev = cur
            px = round(last_x / MAX_X * 1920)
            py = round(last_y / MAX_Y * 1080)
            pct_x = last_x / MAX_X * 100
            pct_y = last_y / MAX_Y * 100
            # Color rojo si no llega al borde, verde si llega al 95%+
            ok_x = pct_x >= 95
            ok_y = pct_y >= 95
            line = f"{last_x:>10} {pct_x:>5.1f}%  {last_y:>10} {pct_y:>5.1f}%  ({px:4d}, {py:4d}) px"
            print(line, flush=True)
EOF
