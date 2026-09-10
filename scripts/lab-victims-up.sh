#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../victims"
echo "[*] Pulling and starting vulnerable web victims..."
docker compose pull
docker compose up -d
echo
echo "[+] Victims are up. Reachable from the host and from lab VMs (not from LAN/tailnet):"
echo "    DVWA        http://192.168.122.1:8081   (login admin / password, then Create/Reset DB)"
echo "    Juice Shop  http://192.168.122.1:3000"
echo "    WebGoat     http://192.168.122.1:8080/WebGoat   (register a local account)"
echo "    WebWolf     http://192.168.122.1:9090/WebWolf"
