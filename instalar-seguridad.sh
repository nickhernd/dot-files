#!/usr/bin/env bash
# Bajo nivel, ingeniería inversa y seguridad defensiva (para estudiar y proteger tu equipo).
set -e

echo ":: Bajo nivel: ensamblador, depuración y trazas"
#  nasm: ensamblador x86 · lldb: depurador LLVM · pwndbg: GDB con vistas de registros/pila/memoria
#  strace/ltrace: llamadas al sistema y a librerías · perf: perfilado · bear: compile_commands.json para clangd
yay -S --needed nasm lldb pwndbg strace ltrace perf bear hexyl

echo ":: Otras arquitecturas (ARM, RISC-V) y emulación"
#  Compilar y ejecutar binarios de otras CPUs, útil para Arquitectura de Computadores y Sistemas Operativos
yay -S --needed aarch64-linux-gnu-gcc riscv64-linux-gnu-gcc arm-none-eabi-gcc \
  qemu-base qemu-user qemu-system-x86 qemu-system-aarch64 qemu-system-riscv

echo ":: Ingeniería inversa y análisis de binarios"
#  ghidra: decompilador de la NSA · rizin + cutter: desensamblador con interfaz
#  radare2: clásico en terminal · imhex: editor hexadecimal con patrones
#  binwalk: analizar firmware · checksec: ver protecciones de un binario (NX, PIE, canary, RELRO)
yay -S --needed ghidra rizin rz-cutter radare2 imhex binwalk checksec

echo ":: Redes (analizar tu propia red y tus servicios)"
#  wireshark: capturar y entender tráfico · nmap: inventario de tu red y tus puertos
#  tcpdump/socat/netcat: depurar conexiones
yay -S --needed wireshark-qt nmap tcpdump socat openbsd-netcat
sudo usermod -aG wireshark "$USER"

echo ":: Protección del equipo"
#  arch-audit: paquetes instalados con CVEs conocidos (lo usa el widget de seguridad)
#  lynis: auditoría de endurecimiento del sistema · opensnitch: cortafuegos por aplicación
#  firejail: aislar apps · keepassxc: contraseñas · age/gnupg: cifrado de archivos
yay -S --needed arch-audit lynis opensnitch firejail keepassxc age gnupg
sudo systemctl enable --now opensnitchd.service

echo ":: Laboratorio de máquinas virtuales (practicar sin riesgo para tu equipo)"
yay -S --needed virt-manager libvirt dnsmasq
sudo systemctl enable --now libvirtd.service
sudo usermod -aG libvirt "$USER"

echo ""
echo "Listo ✔  Cierra sesión y vuelve a entrar para los grupos wireshark y libvirt."
echo "   Prueba: 'sudo lynis audit system' (informe de endurecimiento) y 'arch-audit'."
