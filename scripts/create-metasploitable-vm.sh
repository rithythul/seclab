#!/usr/bin/env bash
# Import Metasploitable2 as a VM on the ISOLATED seclab network (no internet).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VMS="$ROOT/vms"
ZIP="$VMS/metasploitable-linux-2.0.0.zip"
NAME="metasploitable2"
CONN="qemu:///system"

if virsh -c "$CONN" dominfo "$NAME" >/dev/null 2>&1; then
  echo "[=] VM '$NAME' already defined. Start it with: virsh -c $CONN start $NAME"
  exit 0
fi
[ -f "$ZIP" ] || { echo "[!] Missing $ZIP (download still running?)" >&2; exit 1; }

echo "[*] Unzipping Metasploitable2..."
( cd "$VMS" && unzip -o -q "$ZIP" )
VMDK="$(find "$VMS" -iname 'Metasploitable.vmdk' | head -1)"
[ -n "$VMDK" ] || { echo "[!] Metasploitable.vmdk not found after unzip" >&2; exit 1; }

QCOW="$VMS/metasploitable2.qcow2"
if [ ! -f "$QCOW" ]; then
  echo "[*] Converting vmdk -> qcow2 (keeps original read-only)..."
  qemu-img convert -O qcow2 "$VMDK" "$QCOW"
fi

echo "[*] Defining VM on isolated network 'seclab'..."
virt-install \
  --connect "$CONN" \
  --name "$NAME" \
  --memory 512 --vcpus 1 \
  --disk path="$QCOW",bus=ide,format=qcow2 \
  --network network=seclab,mac=52:54:00:66:00:0a \
  --os-variant ubuntu8.04 \
  --graphics vnc,listen=127.0.0.1 \
  --import --noautoconsole
echo "[+] '$NAME' created. It gets 172.31.66.10 on the isolated net."
echo "    Console: virt-viewer --connect $CONN $NAME   (login msfadmin / msfadmin)"
