#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

BUNDLE_ID="${SELAH_BUNDLE_ID:-com.lilgroup.selah}"
KEY_ID="${ASC_IAP_KEY_ID:-CFP9CT7H6R}"
ISSUER_ID="${ASC_ISSUER_ID:-4c17d337-1631-45c1-b951-f46eae44269b}"
PRIVATE_KEY="${ASC_IAP_PRIVATE_KEY_PATH:-/Users/a1241968/Desktop/Oscar/AppStoreAPI/SubscriptionKey_CFP9CT7H6R.p8}"

asc storekit auth login \
  --local \
  --bypass-keychain \
  --skip-validation \
  --name Selah-IAP \
  --key-id "$KEY_ID" \
  --issuer-id "$ISSUER_ID" \
  --private-key "$PRIVATE_KEY" \
  --bundle-id "$BUNDLE_ID"

echo "StoreKit profile Selah-IAP registered for $BUNDLE_ID (network validation deferred until IAP products exist)"
