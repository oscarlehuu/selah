#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="$ROOT/assets/brand/selah-icon-pause-1024.png"
DST="$ROOT/Selah/Selah/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
cp "$SRC" "$DST"
echo "Synced App Store icon → $DST"
