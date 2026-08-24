#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

BUNDLE_ID="${SELAH_BUNDLE_ID:-com.lilgroup.selah}"
APPLE_ID="${ASC_WEB_APPLE_ID:-lehuunghia.oscar@gmail.com}"
APP_NAME="${SELAH_ASC_APP_NAME:-Selah}"
SKU="${SELAH_ASC_SKU:-selah-ios}"

existing_total="$(asc apps list --bundle-id "$BUNDLE_ID" | python3 -c "import sys, json; print(json.load(sys.stdin).get('meta', {}).get('paging', {}).get('total', 0))")"

if [[ "$existing_total" != "0" ]]; then
  echo "ASC app already exists for $BUNDLE_ID"
  asc apps list --bundle-id "$BUNDLE_ID"
  exit 0
fi

if [[ -z "${ASC_WEB_PASSWORD:-}" ]]; then
  web_auth="$(asc web auth status 2>/dev/null || true)"
  if ! echo "$web_auth" | python3 -c "import sys, json; d=json.load(sys.stdin); sys.exit(0 if d.get('authenticated') else 1)" 2>/dev/null; then
    echo "No ASC web session and ASC_WEB_PASSWORD is unset."
    echo "Run once in a terminal:"
    echo "  asc web auth login --apple-id \"$APPLE_ID\""
    echo "Or export ASC_WEB_PASSWORD (and ASC_WEB_2FA_CODE_COMMAND if needed), then rerun this script."
    exit 1
  fi
fi

asc web apps create \
  --name "$APP_NAME" \
  --bundle-id "$BUNDLE_ID" \
  --sku "$SKU" \
  --platform IOS \
  --primary-locale en-US \
  --apple-id "$APPLE_ID"

echo ""
echo "== Created app =="
asc apps list --bundle-id "$BUNDLE_ID"
