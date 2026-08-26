# Streak & grace day (locked)

> Qualifying activity, streak increment, grace auto-apply, week boundary **Sun–Sat**.

## Calendar

| Rule | Value |
|------|-------|
| Day boundary | Midnight **device local timezone** |
| Grace week | **Sunday 00:00 → Saturday 23:59** |
| `graceUsedThisWeek` | Resets each **Sunday** at week start |

## Qualifying activity (either counts)

1. **Plan day complete** — user marks today’s reading plan day done (Read or Journey).
2. **≥ 5 minutes** cumulative **Pray + Talk** foreground time in one calendar day.

Timer pauses when app backgrounded > 30s.

## Streak increment

On first qualifying activity of a **new** calendar day:

- `streakDays += 1`
- `longestStreak = max(longestStreak, streakDays)`
- `lastQualifyingDate = today`

Same day: no double increment.

## Missed day — grace **auto-apply** (locked)

When app opens (or at midnight rollover) and **yesterday** had no qualifying activity:

| Condition | Action |
|-----------|--------|
| `graceAvailable` (not used this Sun–Sat week) | **Auto-apply** grace → streak **unchanged**, `graceUsedThisWeek = true`, log `grace_day_applied` |
| Grace already used this week | Streak **resets to 0**, soft UI (no red shame) |

No modal forcing user to tap “Use grace day.” Journey may show gentle note: *“Grace covered yesterday.”*

## Events (analytics)

| Event | When |
|-------|------|
| `streak_increment` | New qualifying day |
| `grace_day_applied` | Auto-applied on miss |
| `streak_reset` | Miss without grace |
| `qualifying_plan_complete` | Plan path |
| `qualifying_pray_talk_time` | 5 min threshold hit |

## Demo mode

`DemoSeedData` bypasses algorithm; fixed `streakDays = 18`, `graceDayAvailable = true`.

## SwiftData

Model `StreakState`: `streakDays`, `longestStreak`, `lastQualifyingDate`, `graceUsedThisWeek`, `weekStartSunday`.
