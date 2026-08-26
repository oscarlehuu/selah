# Apple platform handoff checklist

> Final gate before feature development. Re-run `./scripts/asc/verify-selah.sh`.

## ASC / signing (2026-08-24)

| Item | Status | Action if missing |
|------|--------|-------------------|
| API key auth | ✅ | `.asc/config.json` + `AppStoreAPI/` |
| Web session | ✅ | `asc web auth login` |
| App `6804629231` | ✅ | — |
| Bundle `com.lilgroup.selah` | ✅ | — |
| IAP capability | ✅ | IN_APP_PURCHASE on bundle |
| 3 subscriptions READY_TO_SUBMIT | ✅ | Attach to version at submit |
| `DEVELOPMENT_TEAM` in project | ✅ `R8GJL3N9WX` | Fix in `project.yml` |

## Capabilities to enable (before CloudKit / optional SIWA)

| Capability | Purpose | ASC action |
|------------|---------|------------|
| iCloud + CloudKit | Journal ciphertext sync | Enable on bundle ID |
| Sign in with Apple | Optional Settings polish | Enable if shipping SIWA UI |
| Push Notifications | Morning reminder | Enable + entitlement |

Run when implementing those features:

```bash
asc bundle-ids capabilities enable --bundle VVCJFJW56Y --capability ICLOUD
asc bundle-ids capabilities enable --bundle VVCJFJW56Y --capability SIGN_IN_WITH_APPLE
asc bundle-ids capabilities enable --bundle VVCJFJW56Y --capability PUSH_NOTIFICATIONS
```

(Exact `asc` subcommand — verify with `asc bundle-ids capabilities --help`.)

## Xcode project

| Item | Status |
|------|--------|
| Min iOS 18 / Swift 6 | ✅ |
| App icon Pause 1024 | ✅ |
| Fonts bundled | ✅ |
| `kjv.sqlite` bundled | ✅ |
| Reading plan JSON bundled | ✅ |
| `Selah.storekit` | ✅ (StoreKit Testing) |
| `SelahTests` target | ✅ |
| `Selah.entitlements` | ✅ (template — extend for iCloud) |
| Privacy strings (Face ID, etc.) | ✅ Info.plist |
| Hero JPGs in bundle | ⏳ add when building UI screens |

## Info.plist usage strings

| Key | Purpose |
|-----|---------|
| `NSFaceIDUsageDescription` | Journal decrypt |
| `NSUserNotificationsUsageDescription` | Morning reminder (add when implementing) |

## Simulator testing

| Item | Note |
|------|------|
| XcodeBuildMCP defaults | Set `projectPath`, `scheme`, simulator |
| StoreKit Testing | Scheme → Run → Options → `Selah.storekit` |
| Sandbox tester | ASC → Users and Access → Sandbox |
| FM companion | iOS **26** sim/device + Apple Intelligence |

## RevenueCat

| Item | Status |
|------|--------|
| Offering `default` | ✅ |
| Products weekly/monthly/yearly | ✅ |
| Entitlement `premium` | ✅ |
| Public SDK key in `AppConfiguration` | Wire at implement |
| RC → PostHog integration | Manual pre-ship |

## Pre-ship (not dev blockers)

- App Store screenshots (Selah Demo scheme)
- IAP attach to app version in ASC UI
- Astro ASO validation
- Privacy nutrition labels
