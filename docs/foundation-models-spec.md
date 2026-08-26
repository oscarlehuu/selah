# Foundation Models — on-device companion (locked)

> **No cloud LLM v1.** **No template/scripted fallback** when Apple Intelligence unavailable.

## Policy (locked 2026-08-24)

If the device **cannot** run on-device Foundation Models (no Apple Intelligence, model disabled, unsupported hardware):

- Talk, Pray generation, onboarding live demo (#10–11) show **unavailable state**.
- **Do not** substitute canned prayers, template pools, or remote APIs.

User-facing copy example: *“Your private companion needs Apple Intelligence on this iPhone. You can still read, pray with Lectio, and journal.”*

## When available

| Surface | FM use |
|---------|--------|
| Talk — Heart / Reflect / Release | Short companion responses + optional verse suggestion |
| Pray — generated prayer step | From mood / verse context |
| Onboarding #10–11 | Live demo mood → short reflection |

## Modes (Talk)

| Mode | System tone |
|------|-------------|
| Heart | Warm listen; validate; invite honesty with God |
| Reflect | Scripture-centered; one question at a time |
| Release | Repentance without shame; grace-forward |

## Guardrails (all prompts)

- Not God, priest, pastor, therapist — disclaimer in UI.
- No sacramental absolution language.
- Crisis keywords → `docs/crisis-safety-spec.md` (no FM-only comfort).
- Max response length ~120 words v1.

## Availability check

`CompanionAvailability.isOnDeviceCompanionAvailable` — **Foundation Models require iOS 26+** (`SystemLanguageModel`). App deployment target remains iOS 18; companion surfaces hidden when unavailable.

At app launch and before Talk/Pray: cache `isCompanionAvailable` for UI.

## Onboarding without FM

Skip or replace #10–11 with static **privacy + preview screenshot** of Talk UI and CTA Continue — **no fake generation**.

## Analytics

`fm_unavailable_shown`, `talk_open` (with `fm_available` property).

## Spike before ship

Real device: latency, memory, Apple Intelligence off/on paths.
