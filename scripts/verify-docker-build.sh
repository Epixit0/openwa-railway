#!/usr/bin/env bash
# Reproduce el build de Railway en local. Muestra el error completo.
set -euo pipefail
cd "$(dirname "$0")/.."
echo "=== Build API ==="
npm run build
echo "=== Install dashboard deps (si falta) ==="
npm ci --prefix dashboard 2>/dev/null || npm install --prefix dashboard
echo "=== Build dashboard ==="
npm run dashboard:build
echo "=== OK ==="
