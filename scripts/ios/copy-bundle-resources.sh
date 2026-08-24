#!/bin/bash
set -euo pipefail
DEST="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
SRC="${SRCROOT}/Selah/Resources"
REPO_ASSETS="${SRCROOT}/../assets/heroes"
mkdir -p "${DEST}/Data/reading-plans"
cp -f "${SRC}/Data/kjv.sqlite" "${DEST}/Data/"
cp -f "${SRC}/Data/verse-of-the-day.json" "${DEST}/Data/"
cp -f "${SRC}/Data/crisis-keywords-en.txt" "${DEST}/Data/"
cp -f "${SRC}/Data/reading-plans/"*.json "${DEST}/Data/reading-plans/"
for hero in selah-hero-window.jpg selah-hero-morning.jpg; do
  if [[ -f "${SRC}/${hero}" ]]; then
    cp -f "${SRC}/${hero}" "${DEST}/"
  elif [[ -f "${REPO_ASSETS}/${hero}" ]]; then
    cp -f "${REPO_ASSETS}/${hero}" "${DEST}/"
  fi
done
