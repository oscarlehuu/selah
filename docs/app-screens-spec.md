# Selah — 6 Core Screens (locked)

> **Post-onboarding app structure.** One outcome per screen. Sunday Light UI.
> **Monetization:** single hard paywall at onboarding end. All 6 screens unlocked for subscribers. No per-screen paywall v1.

---

## Navigation (locked)

**5 tabs + Settings entry** (iOS HIG-friendly). Pray is a full screen, launched as tab #4.

```
[ Today ] [ Read ] [ Talk ] [ Pray ] [ Journey ]     ⚙️ Settings (toolbar / top-right on Today)
```

| Tab | Screen | Icon metaphor |
|---|---|---|
| 1 | Today | Sun / morning |
| 2 | Read | Open book |
| 3 | **Talk** | Soft bubble / heart (center emphasis optional) |
| 4 | Pray | Hands / flame gentle |
| 5 | Journey | Path / footsteps |
| — | Settings | Gear (not tab bar; sheet from Today header) |

**Why not 6 tabs in bar?** iOS tab bar degrades past 5. Settings lives as sheet. Product still has **6 primary screens**.

---

## Monetization model (locked v1)

| Layer | Rule |
|---|---|
| **When user pays** | Onboarding screen **#16 paywall** only |
| **Model** | Auto-renew subscription. **No free tier.** **No trial** v1 |
| **Tiers** | $7.99/w · $14.99/m · **$49.99/y** (push yearly) |
| **Stack** | RevenueCat offerings + native SwiftUI paywall |
| **Inside app** | **100% unlocked** for active subscriber. No ads. No coin packs |
| **Restore** | Settings → Restore purchases |
| **Manage** | Settings → Manage subscription (App Store) |
| **v2 only** | Exit offer on cancel, yearly upsell from weekly, retention offers (Frederick §8 extras) |

**Frederick logic:** downloads are expensive. Don't waste attention on free users inside app. Hard paywall after investment onboarding.

**Per-screen monetize?** **No.** Each screen drives **retention + LTV**, not second paywall.

| Screen | Monetization role |
|---|---|
| Today | Daily open → retention → renew |
| Read | Habit → streak → renew |
| Talk | Moat → churn defense |
| Pray | Emotional peak → reviews + word of mouth |
| Journey | Streak guilt-free → retention |
| Settings | Restore / manage sub |

---

## Screen 1 — **Today** (Home)

**Outcome:** *“Start my 5 minutes with God right now.”*

| Area | Feature v1 |
|---|---|
| **Hero** | Full-bleed morning light + **verse of the day** |
| **Primary CTA** | *“5 minutes with God”* → launches **Pray** flow (or quick pick: Read / Talk / Pray) |
| **Streak chip** | Soft ring, grace day badge if used |
| **Reading snippet** | Next passage from 7-day plan (1 tap → Read) |
| **Mood quick** | 4 moods → shortcut to **Talk** with context |
| **Widget promo** | If widget not enabled, gentle card |

**Not on Today:** settings clutter, full Bible nav, paywall (already subscribed).

**Analytics:** `today_open`, `cta_5min`, `mood_quick`, `streak_view`

---

## Screen 2 — **Read** (Bible)

**Outcome:** *“Read today’s passage without distraction.”*

| Area | Feature v1 |
|---|---|
| **Reader** | Offline Bible (KJV TBD license). Clean typography, Sunday Light |
| **Today’s plan** | Auto-opens plan chapter/section |
| **Navigate** | Book → chapter (simple, not YouVersion depth v1) |
| **Interact** | Highlight verse (soft gold). Tap verse → *“Reflect on this”* → Talk with verse context |
| **Audio** | v2 |
| **Search** | v2 |

**Monetize:** none. Plan progress feeds Journey.

**Analytics:** `read_open`, `plan_read_complete`, `verse_reflect_tap`

---

## Screen 3 — **Talk** (Private companion) — **MOAT**

**Outcome:** *“Say what I can’t say elsewhere — safely.”*

| Area | Feature v1 |
|---|---|
| **Modes** (top) | **Heart** (tâm sự) · **Reflect** (suy niệm) · **Release** (ăn năn / bring to God) |
| **UI** | Warm private room. Soft gradient. 🔒 *“Only on this device”* |
| **Chat** | On-device Foundation Models. Short responses + scripture suggestion |
| **Input** | Voice or text (voice v2 if heavy) |
| **Session** | Optional **auto-delete** after session (Settings toggle) |
| **Guardrails** | Disclaimer footer. Crisis → hotline sheet |
| **Not** | Infinite chatbot. No “God is typing” persona |

**Monetize:** none. This is why they paid.

**Analytics:** `talk_open`, `mode_*`, `session_complete`, `crisis_sheet_shown`

---

## Screen 4 — **Pray**

**Outcome:** *“Pray with structure — not stare at blank page.”*

| Area | Feature v1 |
|---|---|
| **Lectio Divina** | 4 steps: Read → Reflect → Pray → Rest (guided, soft timers) |
| **Generated prayer** | From mood (same engine as onboarding demo) |
| **Amen** | Gentle close animation. Optional journal save |
| **From Read** | Deep link with selected verse |
| **Music** | v2 (ambient worship optional) |

**Distinct from Talk:** Pray = **structured worship time**. Talk = **open conversation**.

**Monetize:** none. Peak moment for v2 App Store review prompt.

**Analytics:** `pray_open`, `lectio_complete`, `amen_tap`

---

## Screen 5 — **Journey**

**Outcome:** *“See I’m growing — without shame.”*

| Area | Feature v1 |
|---|---|
| **Streak** | Visual path, not fire emoji gamification |
| **Grace day** | 1/week. Miss → *“Grace day available”* not red X |
| **7-day plan** | From onboarding, expandable weekly |
| **Stats soft** | Days with God · Minutes in prayer · Chapters read |
| **Journal entries** | List encrypted snippets (optional, from Pray/Talk save) |

**Monetize:** none. Retention mechanic.

**Analytics:** `journey_open`, `grace_day_used`, `plan_day_complete`

---

## Screen 6 — **Settings**

**Outcome:** *“Trust, control, compliance.”*

| Area | Feature v1 |
|---|---|
| **Subscription** | Status, manage, restore |
| **Privacy** | On-device AI explanation. Auto-delete sessions toggle |
| **Notifications** | Morning verse time |
| **Bible** | Translation picker (when multiple) |
| **Legal** | Disclaimer, privacy policy, terms |
| **Support** | Email / FAQ |
| **Account** | Sign in with Apple optional v2 (local-first v1) |

**Monetize:** restore only. No upsell v1.

**Analytics:** `settings_open`, `restore_tap`, `auto_delete_toggle`

---

## Cross-screen flows

```
Today ──CTA──► Pray (Lectio quick)
Today ──mood──► Talk (prefilled mode)
Read ──verse──► Talk (verse in context)
Read ──plan──► Journey (progress)
Talk ──end──► optional Journal (Journey)
Onboarding demo ──► Talk/Pray (same engine)
```

---

## MVP vs v2 per screen

| Screen | MVP | v2 |
|---|---|---|
| Today | Verse, CTA, streak chip | Widget deep link, personalized greeting |
| Read | Plan + basic nav | Audio, search, more translations |
| Talk | 3 modes, text AI | Voice input, longer context |
| Pray | Lectio + generated prayer | Worship audio, review prompt |
| Journey | Streak + 7-day plan | Badges gentle, export journal |
| Settings | Sub + privacy + legal | Sign in sync (if ever) |

---

## Wireframe priority (design next)

1. **Today** — defines daily habit
2. **Talk** — moat screen
3. **Pray** — Lectio flow
4. **Onboarding #10** — demo (same components as Talk)
5. **Paywall #16** — conversion
6. **Read** — reader layout

---

## Locked summary

| # | Screen | One line | Paid? |
|---|---|---|---|
| 1 | Today | Start 5 min with God | After sub |
| 2 | Read | Bible + daily plan | After sub |
| 3 | Talk | Private on-device companion | After sub |
| 4 | Pray | Lectio + guided prayer | After sub |
| 5 | Journey | Streak + plan, no shame | After sub |
| 6 | Settings | Trust + subscription | After sub |

**Pay once at onboarding. Everything inside is the product they bought.**
