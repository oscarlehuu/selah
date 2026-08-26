# Selah assets

Production image and media for the iOS app, interactive prototype, legal site, and App Store.

Canonical paths live here at repo root. `docs/assets` is a symlink to this folder so GitHub Pages (branch `main`, folder `/docs`) can serve the same files.

## Layout

| Path | Use |
|------|-----|
| `brand/selah-icon-pause.svg` | **Locked app icon** (source vector) |
| `brand/selah-icon-pause-1024.png` | App Store Connect export (1024×1024, opaque) |
| `brand/icon-preview.html` | Browser preview of icon variants at multiple sizes |
| `brand/selah-icon-*.svg` / `*.png` | Reference variants (sunrise, window, pause exports) |
| `heroes/selah-hero-window.jpg` | Church window light — onboarding Welcome, paywall |
| `heroes/selah-hero-morning.jpg` | Garden dawn — Today home hero |

## Consumers

- **Interactive mock:** `docs/selah-interactive-mock-v4.html` → `assets/heroes/` (relative; do not use `../assets` — breaks file:// and GitHub Pages). Preview: `./scripts/preview-interactive-mock.sh`
- **Legal site:** `docs/site/*.html` → `../assets/brand/` (via `docs/assets` symlink on Pages)
- **iOS:** copy from `assets/brand/` into `Selah/Resources` when updating AppIcon (see `Selah/README.md`)

Hero veil overlay spec: `design-system/selah/MASTER.md`.
