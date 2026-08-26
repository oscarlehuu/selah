# Demo mode — screenshots & marketing (locked)

> **Not** onboarding live demo (#10–11). **Demo mode** = pre-seeded app state for App Store screenshots, TikTok capture, and marketing stills. No paywall, no empty states.

## Purpose

| Use | Goal |
|-----|------|
| App Store screenshots | Today hero, streak, plan progress, Talk with sample thread |
| Social / TikTok | Same build; status bar 9:41 optional in capture |
| Press / landing | Optional screen recording from Demo scheme |

## When active

| Trigger | Audience |
|---------|----------|
| Launch argument `-DemoMode` | Xcode scheme **Selah Demo**, CI screenshot pipeline |
| Env `SELAH_DEMO_MODE=1` | Fastlane / automation |
| Interactive mock: **Screenshot demo** button | Browser marketing without iOS build |

**Never** enabled for App Store release builds (no hidden toggle in production Settings v1).

## Seeded state (locked)

| Field | Value | Visible on |
|-------|-------|------------|
| `subscribed` | `true` | All tabs unlocked; Settings shows Yearly |
| `streakDays` | `18` | Today chip, Journey hero (strong but believable) |
| `longestStreak` | `24` | Journey stats |
| `graceDayAvailable` | `true` | Journey |
| `planTheme` | `Peace` | Read tag, Journey plan header |
| `planWeek` | `2` | Journey “Week 2 of Peace” |
| `planDaysComplete` | 5 of 7 this week | Journey path dots |
| `readTodayComplete` | `true` | Read toolbar |
| `verseOfDay` | Psalm 46:10 KJV | Today |
| `talkMessages` | 3 messages (Heart mode sample) | Talk |
| `journalEntries` | 2 entries | Journey |
| `autoDeleteSessions` | `false` | Settings switch off |
| `notificationsTime` | `6:30 AM` | Settings |
| Onboarding | **Skipped** — land on **Today** tab | Launch |

Copy and numbers may tune for final screenshots; structure stays.

## iOS implementation

- `DemoMode.isEnabled` — `ProcessInfo.processInfo.arguments.contains("-DemoMode")` or env
- `AppSession` — `@Observable`; applies `DemoSeedData` when demo
- Xcode scheme **Selah Demo** — `-DemoMode` launch arg
- Regenerate: `./scripts/ios/generate-project.sh`

```bash
# Simulator screenshot run
xcodebuild -scheme "Selah Demo" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

## Interactive mock

Panel → **Screenshot demo** sets the same story and jumps to App · Today (see `enterScreenshotDemo()` in mock v4).

## Analytics

Demo sessions **do not** send PostHog events (or filter `is_demo=true` if accidentally shipped). Wire when PostHog lands.

## Security

Demo mode does not bypass real IAP in production. Release archive must use scheme **Selah** only (no `-DemoMode`).
