#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../victims"
docker compose down
echo "[+] Web victims stopped."
