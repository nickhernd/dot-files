Scripts de mantenimiento -- XP-Pen Deco LW/L en Arch Linux + Hyprland
======================================================================

SCRIPTS (ejecutar con bash nombre_script.sh):

  1_fix_xppen.sh     -- ARREGLAR la tablet cuando no mapea bien la pantalla
                        Aplica todos los valores correctos de una vez.
                        Ejecutar siempre que el cursor no llegue a los bordes.

  2_status_xppen.sh  -- VER el estado actual de la configuración
                        Muestra si todo está OK o qué falla exactamente.

  3_test_xppen.sh    -- TEST interactivo de movimiento
                        Mueve el lápiz y ve las coordenadas en tiempo real.
                        Ctrl+C para salir.

----------------------------------------------------------------------
POR QUÉ SE DESCONFIGURA
----------------------------------------------------------------------
El problema raíz son DOS bugs simultáneos:

1) Bug de GDK_SCALE:
   Hyprland/Omarchy fija GDK_SCALE=2 para apps GTK.
   OTD hereda esa variable y piensa que la pantalla mide 960x540
   en lugar de 1920x1080. Solución: override systemd con GDK_SCALE=1.

2) Bug de MaxX en las specs de OTD:
   OTD tiene en su base de datos: MaxX=50800 para el Deco L.
   Pero el dispositivo físico reporta raw máx=32767 (15 bits).
   Ratio: 32767/50800 = 64.5%, por eso el cursor para al 64.5% de la pantalla.
   Solución: configurar el área del tablet en 163.835×92.157mm
   en lugar de 254×142.875mm.

----------------------------------------------------------------------
VALORES CORRECTOS (settings.json -> AbsoluteModeSettings -> Tablet)
----------------------------------------------------------------------
  Width  : 163.835   (= 254 × 32767/50800)
  Height :  92.157   (= 163.835 × 9/16, ratio 16:9)
  X      :  81.9175  (centro del área)
  Y      :  81.9175  (centro del área)

----------------------------------------------------------------------
FICHEROS DE CONFIGURACIÓN MODIFICADOS
----------------------------------------------------------------------
  ~/.config/OpenTabletDriver/settings.json
  ~/.config/systemd/user/opentabletdriver.service.d/override.conf
  ~/.config/hypr/input.conf          (tablet { output = eDP-1 })
  ~/.config/hypr/autostart.conf      (exec-once xppen-monitor.sh)
  ~/.local/bin/xppen-monitor.sh      (monitor de reconexión USB)
