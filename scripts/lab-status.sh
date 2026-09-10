#!/usr/bin/env bash
set -uo pipefail
CONN="qemu:///system"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "==================== SECLAB STATUS ===================="
echo "-- Networks --"
virsh -c "$CONN" net-list --all 2>/dev/null | sed 's/^/  /'
echo "  seclab forward mode: $(virsh -c "$CONN" net-dumpxml seclab 2>/dev/null | grep -q '<forward' && echo 'ROUTED (WARN!)' || echo 'isolated (safe)')"
echo "-- VMs --"
virsh -c "$CONN" list --all 2>/dev/null | sed 's/^/  /'
echo "-- Web victims (docker) --"
docker ps --filter name=seclab- --format '  {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null || echo "  docker not available"
echo "-- Downloads --"
for f in "$ROOT"/iso/*.iso "$ROOT"/vms/*.zip; do
  [ -e "$f" ] || continue
  printf '  %-55s %s\n' "$(basename "$f")" "$(du -h "$f" | cut -f1)"
done
pgrep -a wget >/dev/null 2>&1 && echo "  (a download is still running)" || echo "  (no downloads running)"
echo "======================================================="
