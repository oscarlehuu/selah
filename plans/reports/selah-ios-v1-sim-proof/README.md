# Selah iOS — simulator proof (iPhone 17 Pro)

Captured on the local M5 Mac, **iPhone 17 Pro** simulator, iOS 26.5, bundle `com.lilgroup.selah`.

## What these files show

| File | Screen |
|---|---|
| `01-welcome.png` | Onboarding welcome (Sunday Light, **Begin**) |
| `06-paywall.png` | Hard paywall, photo hero, weekly $7.99, **Start Selah** |
| `07-today.png` | Today tab (demo seed: 18-day streak, Peace week 2) |
| `08-read-kjv.png` | Read tab — real KJV (Psalm 62) |
| `09-talk.png` | Talk tab — on-device companion, Heart / Reflect / Release |
| `10-pray.png` | Pray tab — lectio divina timer |
| `11-journey.png` | Journey tab — week list, no Coming Soon |
| `12-settings.png` | Settings sheet |
| `walkthrough-clip.mp4` | ~2 min recording of the UITest pass (onboarding → paywall → tabs) |

## Run on simulator

```bash
cd Selah
xcodegen generate   # optional; repo already contains Selah.xcodeproj
open Selah.xcodeproj
```

Xcode: scheme **Selah** or **Selah Demo**, destination **iPhone 17 Pro**.

```bash
# unit tests
xcodebuild -project Selah.xcodeproj -scheme Selah \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:SelahTests test

# UITests (onboarding + demo tabs) — use Demo scheme
xcodebuild -project Selah.xcodeproj -scheme 'Selah Demo' \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:SelahUITests test
```

Demo launch argument: `-DemoMode` (scheme **Selah Demo**). Fresh onboarding: `-UITestFreshStart`.
