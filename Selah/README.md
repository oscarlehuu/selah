# Selah iOS

SwiftUI scaffold for **Selah** (`com.lilgroup.selah`). No feature implementation yet.

## Open in Xcode

```bash
./scripts/ios/generate-project.sh   # if project.yml changed
open Selah/Selah.xcodeproj
```

Set **Development Team** only if `project.yml` `DEVELOPMENT_TEAM` is wrong for your machine (default: `R8GJL3N9WX`).

Bundled at build: `kjv.sqlite`, reading plans JSON, VOTD JSON, Newsreader + Figtree fonts.

After updating the locked icon in `assets/brand/`, run `./scripts/ios/sync-app-icon.sh`.

**Screenshots / marketing:** Run scheme **Selah Demo** (`-DemoMode`) or mock v4 → **Screenshot demo**. See `docs/demo-mode-spec.md`.

## Test on Mac (simulator)

```bash
./scripts/ios/run-unit-tests.sh         # logic gates (14 tests)
./scripts/ios/run-demo-ui-tests.sh      # 5 tabs + Settings sheet
./scripts/ios/run-app-flow-ui-tests.sh  # onboarding + paywall/notification
```

Demo UI output: `plans/reports/demo-ui-<timestamp>/screenshots/tab-*.png`

App flow output: `plans/reports/app-flow-ui-<timestamp>/screenshots/flow-*.png`

## Project facts (locked)

| Field | Value |
|-------|-------|
| Bundle ID | `com.lilgroup.selah` |
| Display name | Selah |
| ASC App ID | `6804629231` |
| Min iOS | 18.0 |
| Swift | 6.0 |
| Icon | Pause (`assets/brand/selah-icon-pause-1024.png`) |

## Structure

```
Selah/
├── project.yml          # XcodeGen — edit then regenerate
├── Selah.xcodeproj      # generated
└── Selah/
    ├── App/             # entry + AppConfiguration
    ├── Navigation/      # MainTabView (5 tabs)
    ├── Features/        # Today, Read, Talk, Pray, Journey, Settings
    ├── DesignSystem/    # Sunday Light colors, SelahFont
    ├── Services/        # CompanionAvailability (FM iOS 26+)
    └── Resources/       # Info.plist, Assets, Fonts, bundled data via XcodeGen
```

Settings opens as a sheet from Today (not a tab). Matches `docs/app-screens-spec.md`.

## Not included yet

- Onboarding (16 screens)
- RevenueCat / StoreKit
- PostHog analytics
- Hero photos in app bundle (source: `../assets/heroes/` — add when building UI)
- On-device AI runtime (Foundation Models **iOS 26+**; `CompanionAvailability` stub in repo)

See `AGENTS.md` and `docs/project-playbook.md` for product truth.
