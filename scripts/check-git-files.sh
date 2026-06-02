#!/usr/bin/env bash
# Verifica que GitHub/Railway reciba la carpeta dashboard (código fuente).
set -euo pipefail
cd "$(dirname "$0")/.."

echo "=== Archivos dashboard en git ==="
count=$(git ls-files dashboard/src 2>/dev/null | wc -l)
echo "dashboard/src: $count archivos"
if [ "$count" -lt 5 ]; then
  echo "ERROR: casi no hay dashboard/src en git. Railway no puede compilar la UI."
  echo "Ejecuta: git add dashboard && git commit -m 'add dashboard source' && git push"
  exit 1
fi

echo "=== Último commit ==="
git log -1 --oneline

echo "=== OK ==="
