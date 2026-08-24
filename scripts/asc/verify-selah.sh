#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

BUNDLE_ID="${SELAH_BUNDLE_ID:-com.lilgroup.selah}"
BUNDLE_RESOURCE_ID="${SELAH_BUNDLE_RESOURCE_ID:-VVCJFJW56Y}"

echo "== asc doctor =="
asc doctor

echo ""
echo "== API auth =="
asc auth status

echo ""
echo "== Web session =="
asc web auth status

echo ""
echo "== Bundle ID capabilities =="
asc bundle-ids capabilities list --bundle "$BUNDLE_RESOURCE_ID"

echo ""
echo "== ASC app record =="
asc apps list --bundle-id "$BUNDLE_ID"
