# Crisis safety (locked)

> On-device keyword scan. Hotline sheet. **Never log message content.**

## Trigger

Scan **user input** in Talk (and optional Pray free-text) before sending to FM.

Categories: self-harm, suicide, harm to others, abuse, overdose, hopeless crisis language.

Maintain list in `data/crisis-keywords-en.txt` (~50–80 phrases, updateable without app release if bundled).

## Action flow

1. Block FM response for that message.
2. Present **Urgent help** sheet (modal).
3. Analytics: `crisis_sheet_shown` — **no** message text in properties.
4. Do not save message to journal or persistent Talk log.

## Hotlines (v1 markets)

| Region | Resource | Action |
|--------|----------|--------|
| US | **988** Suicide & Crisis Lifeline | `tel:988` |
| US | Crisis Text Line | UI: text **741741** |
| UK | Samaritans **116 123** | `tel:116123` |
| AU | Lifeline **13 11 14** | `tel:131114` |
| Fallback | [findahelpline.com](https://findahelpline.com) | Link |

Pick sheet content from device region / App Store storefront.

## Settings

Permanent row: **Urgent help & hotlines** (same sheet).

## Copy footer (Talk)

*“Selah is not a pastor or therapist.”* + link **Need urgent help?**

## App Review

Honest limitations in Terms + in-app sheet.
