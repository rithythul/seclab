#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ISO="$ROOT/iso/blackarch-linux-slim-2023.05.01-x86_64.iso"
ZIP="$ROOT/vms/metasploitable-linux-2.0.0.zip"
LOG="$ROOT/docs/autobuild.log"
exec >>"$LOG" 2>&1
echo "=== autobuild started $(date -Is) ==="

# wait until no wget is running (both downloads finished/stopped)
while pgrep -x wget >/dev/null 2>&1; do sleep 20; done
echo "downloads finished at $(date -Is)"

# verify Metasploitable zip is intact, then build
if [ -f "$ZIP" ] && unzip -tqq "$ZIP" >/dev/null 2>&1; then
  echo "-> building metasploitable"
  "$ROOT/scripts/create-metasploitable-vm.sh" || echo "metasploitable build FAILED"
else
  echo "metasploitable zip missing or corrupt: $ZIP"
fi

# verify ISO size is sane (>5 GB), then build attacker
if [ -f "$ISO" ] && [ "$(stat -c%s "$ISO")" -gt 5000000000 ]; then
  echo "-> building attacker"
  "$ROOT/scripts/create-attacker-vm.sh" || echo "attacker build FAILED"
else
  echo "ISO missing or too small: $ISO ($(stat -c%s "$ISO" 2>/dev/null || echo 0) bytes)"
fi

echo "=== autobuild done $(date -Is) ==="
virsh -c qemu:///system list --all
