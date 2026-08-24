# Selah — Onboarding Spec

> **Target:** 16 screens (14 pre-paywall + paywall + post-paywall notification).
> **Benchmark:** Frederick James (~12 screens) + PrayerLock (45 steps, 10–15 min, 3-act story).
> **Design:** Sunday Light. Agitate in hooks, grace in tone. See `docs/project-playbook.md` §5.
> **Metrics:** completion ≥ 75% · D2P ≥ 8% before scaling TikTok ads.

---

## Frederick James (X article) — onboarding rules

| Rule | Selah application |
|---|---|
| **Twofold goal** | (1) Remind user they have an issue. (2) Show Selah solves it. |
| **~12 screens directionally** | Start at **16**; cut screens that lose in funnel data |
| **Longer onboarding** | Can ↑ drop-off OR ↑ conversion. PrayerLock stretched 5 min → 15 min and CVR jumped |
| **Every screen fights for its place** | Outcome, not product feature list |
| **Images over text** | Full-bleed light, nature, windows. Minimal copy per screen |
| **Quizzes: 4 options max** | Tap cards, no keyboard until demo screen |
| **Social proof + stats** | One stat screen; reviews before paywall |
| **Permissions inside app** | Notifications **after** paywall, not before |
| **Measure funnel** | PostHog event per screen |
| **Study PrayerLock** | Masterclass. Copy **structure**, not 1:1 aggression |
| **Study CalAI / Feeld / Hinge** | Data quiz + investment + necessary friction |

**Do not copy PrayerLock 1:1:** 45 aggressive RPG-text screens, handwritten signature, guilt-dark tone. Selah stays **bright sanctuary**.

---

## PrayerLock patterns worth stealing

| Pattern | PrayerLock | Selah adaptation |
|---|---|---|
| 3-act story | Problem → experience → paywall | Same structure |
| Aha in first minute | Block flow demo fast | Breath + verse + mood → prayer draft |
| Mirror quiz answers | Personalized prayer | Mirror + 7-day plan label |
| Investment effect | Long flow, signature | Plan “building…” animation (skip signature v1) |
| Show don't tell | Generate prayer before pay | **Live mood → prayer/reflection** on-device |
| Review at peak | After core feature | v2: after demo prayer screen |
| Commitment | Signature | Gentle “ready this week?” yes tap |

---

## Three-act structure (16 screens)

```
ACT 1 — PROBLEM     Screens 1–6    ~3 min   Feel the gap
ACT 2 — JOURNEY     Screens 7–12   ~5 min   Personal + experience Selah
ACT 3 — CONVERT     Screens 13–16  ~2 min   Trust + paywall + notify
```

**Total target time:** 8–12 minutes (shorter than PrayerLock 15 min; longer than bare 12-screen generic flow).

---

## Screen-by-screen

### ACT 1 — PROBLEM (remind the issue)

| # | Name | UI (Sunday Light) | Copy / interaction | Psychology | Analytics |
|---|---|---|---|---|---|
| **1** | **Welcome + Aha** | Full-bleed golden morning light. Soft verse fades in. | *“Selah — pause. Reflect. Listen.”* 3-second breathe animation. Single CTA: **Continue** | Aha < 60s. Beauty first. Not a login wall | `onboarding_01_welcome` |
| **2** | **Emotional hook** | Person in soft light, phone aside, window glow | *“You have time to scroll for hours. Five minutes with God feels hard.”* | Agitate without shame. Frederick issue reminder | `onboarding_02_hook` |
| **3** | **Stat + social proof** | Clean typographic card on sky gradient | *“Most Christians want to read the Bible daily. Few build the habit.”* Small cite footnote if sourced | Scientific stat (Frederick). Credibility | `onboarding_03_stat` |
| **4** | **Quiz — distance** | 4 pastel tap cards | *“What keeps you furthest from God right now?”* Busy life / Guilt or heaviness / Inconsistency / I feel distant | Branch data. 4 options max | `onboarding_04_quiz_distance` |
| **5** | **Quiz — desire** | 4 cards with soft icons | *“What do you want most?”* Peace / Daily consistency / Freedom from guilt / Know Scripture better | Personalization input | `onboarding_05_quiz_desire` |
| **6** | **Quiz — habit** | CalAI-style slider or 4 frequency cards | *“How often do you read the Bible now?”* Never / Sometimes / Often / Daily (aspiring) | Investment + honesty | `onboarding_06_quiz_habit` |

---

### ACT 2 — JOURNEY (solution + experience)

| # | Name | UI | Copy / interaction | Psychology | Analytics |
|---|---|---|---|---|---|
| **7** | **Mirror** | Personalized text on warm white | Dynamic: *“You want [desire]. [Distance] has made it hard. That honesty matters.”* | Mirror answers (PrayerLock). User feels “built for me” | `onboarding_07_mirror` |
| **8** | **Commitment** | Soft gold accent button | *“Will you make space for God this week?”* **Yes, I’m ready** / **I want to try** | Cialdini commitment. No signature v1 | `onboarding_08_commitment` |
| **9** | **Privacy** | 🔒 on soft blue card | *“Your prayers and reflections stay on this phone. Not the cloud. Not us.”* | Moat + trust for confession use case | `onboarding_09_privacy` |
| **10** | **Live demo (core)** | Private talk UI preview | Pick mood (4): Heavy / Anxious / Grateful / Empty → **generate short prayer or reflection** on-device (or scripted MVP) | **Show don't tell.** Second aha. Peak emotion | `onboarding_10_demo` |
| **11** | **Demo result** | Scripture line + short prayer draft | User reads result. *“This is Selah — space to talk to God.”* CTA: **Continue** | Value before paywall | `onboarding_11_demo_result` |
| **12** | **Building plan** | 15–20s animation: path forming, soft progress | *“Creating your 7-day journey…”* No fake spinner only | Investment effect (Feeld/Hinge) | `onboarding_12_building` |

---

### ACT 3 — CONVERT

| # | Name | UI | Copy / interaction | Psychology | Analytics |
|---|---|---|---|---|---|
| **13** | **Plan reveal** | Timeline cards Mon–Sun | *“Your week: [Peace / Consistency / Freedom]”* + 3 bullets | Tangible personalized outcome | `onboarding_13_plan` |
| **14** | **Widget hook** | Lock Screen mock | *“A verse on your Lock Screen every morning.”* | Habit hook beyond onboarding | `onboarding_14_widget` |
| **15** | **Social proof** | Stars + 2 short testimonials | *“Finally a place that doesn’t shame me.”* | Frederick paywall anatomy #1 | `onboarding_15_social` |
| **16** | **Paywall** | Same Sunday Light palette | Branch headline + 3 bullets (Private / Daily / Companion) + yearly push $49.99 + disclaimer | Hard paywall. Impact not product | `paywall_view` · `subscribe` |
| **17** | **Notifications** (post-paywall only) | Soft prompt | *“A gentle reminder each morning?”* Allow / Not now | Permission after convert (Frederick) | `onboarding_17_notifications` |

---

## Paywall headlines (quiz branch)

| Branch (from screen 4–5) | Headline |
|---|---|
| A — Distant | *“Start talking to God every day”* |
| B — Inconsistent | *“Read the Bible 5 minutes a day — without quitting”* |
| C — Heavy / guilt | *“A private space to talk to God”* |
| Default | *“Your private space with God”* |

---

## What we deliberately skip (v1)

| Screen | Why skip |
|---|---|
| Handwritten signature | PrayerLock pattern; too aggressive for Selah tone |
| 30+ RPG text walls | Hurts Sunday Light; Onbo Hub calls PrayerLock “excessive” |
| Sign in with Apple before paywall | Friction before convert |
| Screen Time permission | Not Selah core (PrayerLock-specific) |
| Abandon / exit discount offers | Frederick: skip first App Review submission |
| “How did you hear about us?” | Add when attribution needs it |

---

## v2 experiments (if D2P < 8%)

- App Store review prompt after screen 11 (peak)
- +2 quiz screens for deeper mirror
- Video testimonial screen
- Extend to 18–20 screens only if completion stays ≥ 70%

---

## Funnel targets

| Screen zone | Drop-off alert if |
|---|---|
| 1 → 3 | > 25% (hook too slow) |
| 4 → 6 | > 20% (quiz fatigue) |
| 10 demo | > 30% (demo broken/slow) |
| 12 → 16 | > 40% (plan/paywall weak) |
| Overall completion (16 → paywall seen) | < 75% |

---

## Design notes per phase

| Phase | Visual |
|---|---|
| Act 1 | Brighter, more sky/window imagery. Hooks can be honest but never red/black guilt |
| Act 2 | Intimate warm light for demo. Privacy screen soft blue |
| Act 3 | Gold accents on plan reveal. Paywall feels continuation, not jarring sales page |

---

## References

- [Frederick James — app tutorial](https://x.com/frederickjames/status/2091503229146194334)
- PrayerLock onboarding (Onbo Hub: 45 steps, commitment signature, long narrative)
- Mao / Prayer Lock case studies: 3-act story, 10–15 min, mood → prayer before paywall
