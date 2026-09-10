#!/usr/bin/env bash
# Create the BlackArch attacker VM: dual-homed (internet via 'default' NAT,
# lab traffic via isolated 'seclab'). Boots the slim live ISO.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ISO="$(ls -1 "$ROOT"/iso/blackarch-linux-slim-*-x86_64.iso 2>/dev/null | head -1)"
NAME="blackarch-attacker"
CONN="qemu:///system"
DISK="$ROOT/vms/attacker.qcow2"
DISK_GB=40
RAM_MB=6144
VCPUS=4

if virsh -c "$CONN" dominfo "$NAME" >/dev/null 2>&1; then
  echo "[=] VM '$NAME' already defined. Start it with: virsh -c $CONN start $NAME"
  exit 0
fi
[ -n "$ISO" ] && [ -f "$ISO" ] || { echo "[!] BlackArch ISO not found in $ROOT/iso (download still running?)" >&2; exit 1; }

echo "[*] Creating attacker VM from $(basename "$ISO")..."
virt-install \
  --connect "$CONN" \
  --name "$NAME" \
  --memory "$RAM_MB" --vcpus "$VCPUS" \
  --cpu host-passthrough \
  --disk path="$DISK",size="$DISK_GB",format=qcow2,bus=virtio \
  --cdrom "$ISO" \
  --network network=default,model=virtio \
  --network network=seclab,model=virtio \
  --os-variant archlinux \
  --graphics spice \
  --video qxl --channel spicevmc \
  --noautoconsole
echo "[+] '$NAME' created and booting the live ISO."
echo "    Open the desktop: virt-viewer --connect $CONN $NAME"
echo "    Live user: root/blackarch or user/user (varies by build); boot the live session,"
echo "    then run the installer 'blackarch-install' when ready to install to disk."
