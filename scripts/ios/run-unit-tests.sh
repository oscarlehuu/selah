#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT/Selah"
xcodebuild -scheme Selah \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:SelahTests \
  test
