#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/docs"

pick_port() {
  local p="${PORT:-8765}"
  if python3 -c "import socket; s=socket.socket(); s.bind(('', $p))" 2>/dev/null; then
    echo "$p"
    return
  fi
  for p in 8766 8767 8770 8780; do
    if python3 -c "import socket; s=socket.socket(); s.bind(('', $p))" 2>/dev/null; then
      echo "$p"
      return
    fi
  done
  echo "No free port found (tried 8765–8780). Set PORT=." >&2
  exit 1
}

PORT="$(pick_port)"
echo "Open http://localhost:${PORT}/selah-interactive-mock-v4.html"
echo "Hero images: docs/assets/heroes/ (symlink → assets/heroes/)"
python3 -m http.server "$PORT"
