#!/usr/bin/env bash
# Download midvash KJV SQLite for offline Read tab.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../" && pwd)"
OUT_DIR="$ROOT/assets/bible"
OUT_FILE="$OUT_DIR/kjv.sqlite"
URL="https://github.com/midvash/bible-data/raw/main/versions/en/kjv/kjv.sqlite"

mkdir -p "$OUT_DIR"
echo "Fetching KJV SQLite..."
curl -fsSL "$URL" -o "$OUT_FILE"
BYTES=$(wc -c < "$OUT_FILE" | tr -d ' ')
echo "Wrote $OUT_FILE ($BYTES bytes)"
echo "Pin this URL in docs/bible-data-sources.md when updating."
