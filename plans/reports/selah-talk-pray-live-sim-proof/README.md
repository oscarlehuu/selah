# Talk / Pray live sim proof

**This iPhone 17 Pro simulator reports Apple Intelligence available, but Foundation Model catalog assets are missing, so live generation cannot run here.**

Need from a device that actually has Apple Intelligence: iPhone 15 Pro or later (or a Mac/sim with the on-device language model downloaded), Apple Intelligence enabled, then send Heart “I’m exhausted” and tap Another prayer — replies must come from `LanguageModelSession`, not a scripted prayer.

## What this branch proves without the model

- Heart / Reflect / Release prompts, parser, Talk send, Lectio context, and regen are unit-tested (`SelahTests`: 61 passed, 4 skipped).
- UI path is real: suggestion send, Lectio Pray step, Another prayer, Amen → Today.
- No “God is typing”. No pastor/priest/therapist voice. No “Heavenly Father” fake fallback.

## Shots (iPhone 17 Pro, iOS 26.5)

| File | What |
|------|------|
| `01-talk-heart-before-send.png` | Talk · Heart · suggestions including “I’m exhausted” |
| `02-talk-heart-after-send.png` | Heart turn after send (honest no-model result) |
| `03-pray-draft.png` | Lectio Pray step + Another prayer |
| `04-pray-another.png` | Regen tapped |
| `05-amen-today.png` | Amen closed to Today |
| `talk-pray-companion.mp4` | Short recording of the same flow |

## Visible strings (read off the shots)

**Talk Heart**
- Heart / Reflect / Release
- On-device only
- I’m exhausted / I feel far from God / Something good happened
- Need urgent help?
- Selah is a companion for prayer — not a pastor, priest, or therapist.
- After send: `Selah could not generate a response right now. You are still heard by God.`
- Never: “God is typing”, “Heavenly Father”, pastor voice

**Pray**
- Say it back to God
- Here is a prayer in your own weather. Change any word. It is yours.
- Another prayer
- Continue to rest / Amen closes to Today
- Same honest failure copy on this sim (not a drafted prayer pretending to be the model)

## Real generation path (wired, tested)

Talk instructions (Heart): listen first, not God / pastor / priest / therapist, short reply + one Scripture + follow-ups.

Pray draft: first-person prayer the user can say to God, from verse + reflection word + mood. Regen calls `prayerDraft` again.

Code: `CompanionPrompts.swift`, `CompanionTextService.swift`, `TalkSessionEngine.swift`, `LectioPrayEngine.swift`.
