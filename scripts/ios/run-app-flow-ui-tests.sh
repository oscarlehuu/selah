#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../Selah" && pwd)"
REPORTS="$(cd "$(dirname "$0")/../../plans/reports" && pwd)"
STAMP="$(date +%Y%m%d-%H%M)"
OUT_DIR="${REPORTS}/app-flow-ui-${STAMP}"
RESULT_BUNDLE="${OUT_DIR}/SelahFlow.xcresult"
SIM_NAME="${SIM_NAME:-iPhone 17 Pro}"

mkdir -p "$OUT_DIR"
rm -rf "${RESULT_BUNDLE}"

echo "Selah app-flow UI tests (onboarding + paywall)"
echo "  results: ${RESULT_BUNDLE}"
echo ""

xcrun simctl uninstall booted com.lilgroup.selah 2>/dev/null || true

xcodebuild test \
  -project "${ROOT}/Selah.xcodeproj" \
  -scheme "Selah Demo" \
  -destination "platform=iOS Simulator,name=${SIM_NAME}" \
  -only-testing:SelahUITests/AppFlowScreenshotTests/testOnboardingAndPaywallScreens \
  -resultBundlePath "${RESULT_BUNDLE}" || EXIT=$?

if [[ "${EXIT:-0}" -ne 0 ]]; then
  echo "TEST FAILED (exit ${EXIT})"
  exit "${EXIT}"
fi

echo ""
echo "TEST SUCCEEDED"
echo "Exporting screenshots..."

SCREEN_DIR="${OUT_DIR}/screenshots"
mkdir -p "${SCREEN_DIR}"
xcrun xcresulttool export attachments \
  --path "${RESULT_BUNDLE}" \
  --output-path "${SCREEN_DIR}"

python3 - <<'PY' "${SCREEN_DIR}/manifest.json" "${SCREEN_DIR}"
import json, os, shutil, sys
manifest_path, out_dir = sys.argv[1], sys.argv[2]
with open(manifest_path) as f:
    entries = json.load(f)
attachments = []
for entry in entries:
    attachments.extend(entry.get("attachments", []))
for item in attachments:
    suggested = item.get("suggestedHumanReadableName", "")
    exported = item.get("exportedFileName", "")
    if not exported:
        continue
    base = suggested.split("_")[0] if suggested else exported
    src = os.path.join(out_dir, exported)
    dest = os.path.join(out_dir, f"{base}.png")
    shutil.copy2(src, dest)
    print(f"  {dest}")
PY

echo ""
echo "Screenshots:  ${SCREEN_DIR}/*.png"
echo "Xcode bundle: open \"${RESULT_BUNDLE}\""
