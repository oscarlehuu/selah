# Local notifications (locked)

## Permission timing

- **After paywall** — onboarding screen **#17** only.
- Never before subscribe.

## Default schedule

| Field | Value |
|-------|-------|
| Time | **6:30 AM** local (Settings picker) |
| Frequency | Daily |
| Identifier | `selah.morning.reminder` |

## Content

- Title: **Selah**
- Body: VOTD snippet (first ~80 chars) + *“Your 5 minutes with God.”*
- `UNNotificationDefault` sound — soft default.

## Deep link

`selah://today` or SwiftUI `onOpenURL` → **Today** tab.

## Implementation

- One `UNCalendarNotificationTrigger` repeating daily.
- Re-schedule when user changes time in Settings.
- Idempotent: remove pending before add.

## Denied permission

- Today card: gentle reminder to enable in Settings.
- No repeated nagging.

## Analytics

`notification_permission_allow`, `notification_permission_deny`, `notification_time_changed`.
