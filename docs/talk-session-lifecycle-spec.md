# Talk session lifecycle (locked)

## Session boundary

| Event | Behavior |
|-------|----------|
| Open Talk tab | New `TalkSession` if none active in last 30s |
| Background < 30s | Same session |
| Background > 30s | Next open = new session |
| User taps **End session** | Close session explicitly |

## Persistence (`autoDeleteSessions` default **OFF**)

| Setting | On session end |
|---------|----------------|
| **OFF** | Messages remain in SwiftData until user clears |
| **ON** | Delete all `TalkMessage` rows for session ID |

Session end triggers: End button, tab away > 30s, app terminate (best-effort on next launch).

## Journal

Saving to journal copies **user-selected** text through encrypt path — independent of auto-delete.

## Crisis messages

Never persisted.

## Confession / Release mode

UI encourages auto-delete ON in Settings copy; product default remains OFF globally.

## Analytics

`talk_open`, `talk_session_end`, `talk_auto_delete_wiped` (count only, no content).
