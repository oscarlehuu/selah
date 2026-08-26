# Persistence architecture (locked)

## Stack

| Concern | Technology |
|---------|------------|
| App models | **SwiftData** (`@Model`, `@Query`) |
| Bible text | **Bundled SQLite** (`kjv.sqlite`) via GRDB or native C API — not SwiftData |
| Secrets / master key | **Keychain** |
| Lightweight prefs | `@AppStorage` / `UserDefaults` |
| Journal ciphertext + CloudKit | SwiftData + **NSPersistentCloudKitContainer** |

## SwiftData models (v1)

| Model | Purpose |
|-------|---------|
| `StreakState` | Streak, grace, last qualifying date |
| `PlanProgress` | Theme, week, dayIndex, completedAt per day |
| `JournalEntry` | Encrypted payload metadata |
| `TalkMessage` | Session messages (wiped per auto-delete policy) |
| `TalkSession` | Session id, startedAt, mode |
| `AppSettings` | Notification time, auto-delete, cloud sync flags |

## BibleRepository

- Read-only queries against bundled DB.
- No network at runtime for Read tab.

## Migrations

SwiftData lightweight migration for model tweaks v1.1.

See `docs/journal-encryption-spec.md`, `docs/streak-grace-spec.md`.
