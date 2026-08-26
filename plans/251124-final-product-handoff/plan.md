# Selah v1 — Final product handoff

> **Date:** 2026-08-24  
> **Audience:** Agents building the shippable app, Oscar as product client  
> **Mode:** **Product delivery** — not incremental “next feature” tickets

---

## What changes from prior handoffs

| Before | Now |
|--------|-----|
| “Implement paywall next” | Build **entire shippable v1** through App Review |
| Scaffold + specs = progress | **Only user-visible flows + store binary** count |
| TDD one matrix row | TDD **per phase** + simulator proof each phase |
| Client picks next step | Client **reviews simulator**; agents **own the program** |

**Success:** Subscriber can complete onboarding → pay → use all 6 surfaces daily. Demo scheme produces real screenshots. ASC submission package complete.

---

## Shippable v1 — definition of done

### User can

1. Finish **17-screen onboarding** (quiz, FM demo or honest unavailable state, social proof, paywall, notification prompt).
2. **Subscribe** (yearly default, exit offers) or stay locked (PrayerLock).
3. **Today:** VOTD, streak, today’s plan day, quick actions.
4. **Read:** today’s passages + full KJV chapter reader (offline).
5. **Talk:** on-device FM chat when available; crisis sheet on keywords; disclaimers.
6. **Pray:** Lectio-style flow + generated prayer when FM available.
7. **Journey:** week progress, plan arc, journal list.
8. **Settings:** restore, manage sub, notifications, auto-delete Talk, legal, support.

### System must

- `AppGate` at root — unsubscribed never sees tabs.
- RevenueCat purchases + restore + entitlement `premium`.
- PostHog onboarding + paywall funnel events.
- Streak + auto grace (Sun–Sat).
- Journal encrypted at rest (Keychain + AES-GCM); CloudKit **only if** privacy copy updated.
- Local notification schedule (default 6:30 AM) after onboarding #17.
- Demo scheme: seeded state on **real UI**, not placeholders.

### Store must

- Binary on ASC version with **3 IAPs attached**.
- Screenshots from Selah Demo on real screens.
- Privacy/Terms accurate (PostHog, RC, encryption, iCloud if shipped).
- Astro ASO validation pre-submit.
- Sandbox purchase verified on device/sim.

---

## Current truth (2026-08-24 audit)

**Overall completion: ~18%.** Specs and store infra lead the app by months.

### Ready (use now)

| Asset | Location |
|-------|----------|
| Product specs (21 docs) | `docs/` |
| Interactive mock v4 | `docs/selah-interactive-mock-v4.html` |
| Design tokens | `design-system/selah/MASTER.md` |
| KJV SQLite | `assets/bible/kjv.sqlite` (bundled) |
| Reading plans 365×4 | `data/reading-plans/` |
| VOTD pool | `data/verse-of-the-day.json` |
| Crisis keywords | `data/crisis-keywords-en.txt` (not bundled) |
| Hero photos | `assets/heroes/` (2 JPG, not bundled) |
| App icon 1024 | `assets/brand/` (bundled) |
| Fonts Newsreader + Figtree | `Selah/Resources/Fonts/` (not used in UI) |
| ASC app + 3 IAPs READY_TO_SUBMIT | `6804629231` |
| RC offering + products | `default`, entitlement `premium` |
| PostHog project + 2 insights | `573828` |
| Legal Pages | `docs/site/` |
| StoreKit config | `Selah/Configuration/Selah.storekit` |
| Unit tests | 12 (gate + exit policy only) |

### Scaffold only (not shippable)

| Item | Gap |
|------|-----|
| `SelahApp` | Opens `MainTabView` — **paywall bypass** |
| All 6 screens | `PlaceholderScreen` |
| GRDB / RC / PostHog | SPM linked, **zero usage** |
| `AppGate` / `PaywallExitPolicy` | Exist, **not wired** |
| `CompanionAvailability` | Stub only |
| Entitlements | Empty — no iCloud, Push, SIWA |
| Persistence | `AppSession` in-memory only |

### Per-area %

| Area | % | Blocker |
|------|---|---------|
| Onboarding | 12 | No UI |
| Paywall + RC | 28 | No UI, no Purchases |
| Today | 15 | Placeholder |
| Read | 22 | No BibleRepository |
| Talk | 12 | No FM, no crisis |
| Pray | 10 | No Lectio |
| Journey | 14 | Placeholder + UX/doc drift |
| Settings | 22 | Links only |
| Streak/grace | 12 | No engine |
| Journal | 8 | No crypto/SwiftData |
| Demo mode | 42 | Real UI missing |
| Analytics | 18 | SDK unused |
| Notifications | 8 | Not implemented |
| Design polish | 25 | Tokens exist, no components |
| ASC/legal | 76 | Binary + screenshots missing |

---

## Phase 0 — Lock product truth (before code)

Resolve doc conflicts. **No implementation until locked.**

| # | Conflict | Recommendation |
|---|----------|----------------|
| 1 | **16 vs 17 screens** | Lock **17** (onboarding-spec header wrong) |
| 2 | **28-day UX vs 365-day data** | Ship **365×4 JSON**; Journey copy = “Week N of theme” not “28 days” |
| 3 | **CloudKit journal v1** vs “Not the cloud” onboarding | **Locked:** CloudKit v1 — update onboarding #9 + privacy (Oscar 2026-08-24) |
| 4 | **SIWA** optional v1 vs v2 in screens spec | **Defer SIWA** to v1.1 (IAP identity only) |
| 5 | Support email | `people@lilgroup.studio` everywhere |
| 6 | `ITSAppUsesNonExemptEncryption` | Set honest value when AES ships |
| 7 | Generated plan quality | **Editorial pass** on week 1–4 copy before ship (generator cycles titles) |
| 8 | FM no-fallback + iOS 26 | Ship unavailable state; position as premium device feature |

**Output:** Oscar confirms Phase 0 table → update `AGENTS.md` + affected specs in one commit.

---

## Build program (final product)

Each phase ends with: **tests green + XcodeBuildMCP simulator proof + screenshot**.

### Phase 1 — Foundation

- SwiftUI design system (Sunday Light, mock v4 parity)
- Bundle heroes, crisis list, font registration in UI
- `RootView` with `AppGate` routing
- SwiftData models (`persistence-spec.md`)
- `BibleRepository` (GRDB + kjv.sqlite)
- `ReadingPlanRepository` (JSON themes)
- `StreakEngine` (grace auto-apply, Sun–Sat)
- `VerseOfTheDayService`

### Phase 2 — Monetization spine

- `SubscriptionService` (RC configure, offerings, purchase, restore)
- Paywall #16 UI + Exit #1/#2 sheets
- Wire PostHog paywall events
- **Gate:** unsubscribed sim never reaches tabs; sandbox purchase opens Today

### Phase 3 — Onboarding

- 17 SwiftUI screens (mock v4 copy + heroes)
- FM demo screen #10 (available vs unavailable branches)
- Persist onboarding completion + quiz branches
- PostHog funnel events 01–15

### Phase 4 — Core daily loop

- **Today** (VOTD, streak, plan card, actions)
- **Read** (today passages + chapter picker + reader)
- **Journey** (week list, progress, journal preview)

### Phase 5 — Spiritual companion

- **Talk** (FM session, disclaimers, auto-delete option)
- Crisis keyword detection + hotline sheet
- **Pray** (Lectio steps + FM prayer generation)

### Phase 6 — Journal + settings

- Encrypted journal (per `journal-encryption-spec.md`)
- CloudKit sync **if Phase 0 chose (A)**
- Settings: restore, manage sub, notifications picker, auto-delete, legal

### Phase 7 — Notifications + polish

- Onboarding #17 permission + `local-notifications-spec.md`
- Widget “coming soon” promo cards (#14, Today)
- Accessibility IDs (`accessibility-ids.md`)
- Motion (slow breathe, soft fade)

### Phase 8 — Demo + analytics

- Demo seed on **real screens**
- PostHog full catalog (`analytics-events.md`)
- Selah Demo scheme screenshot run

### Phase 9 — App Review package

- ASC capabilities (iCloud, Push if used)
- Attach IAPs to version
- Encryption export compliance
- Privacy/terms sync
- Astro ASO check
- RC → PostHog integration (dashboard)

### Phase 10 — Client acceptance

- Oscar simulator pass (non-technical client role)
- Fix UX feedback
- Submit for review

---

## Verification gates (non-negotiable)

| Gate | Check |
|------|-------|
| G1 | `./scripts/ios/run-unit-tests.sh` — all pass |
| G2 | XcodeBuildMCP `build_run_sim` — no crash |
| G3 | Fresh install path: onboarding → paywall → locked until purchase |
| G4 | Sandbox purchase yearly → all tabs work |
| G5 | Cancel payment → Exit #1 monthly sheet |
| G6 | Relaunch 2× unsubscribed → weekly emphasis |
| G7 | Read: open Psalm 23 from SQLite offline |
| G8 | Talk: crisis keyword → hotline sheet (no AI comfort only) |
| G9 | Demo scheme: 7-day streak visible on real Today |
| G10 | Settings restore works after reinstall |

---

## Agent workflow (product mode)

From `docs/vibecode-workflow.md`, extended:

1. Work **one phase at a time** — no skipping to “fun” features.
2. TDD for logic; UI verified on simulator.
3. Subagents: Auto or Grok 4.6 High only.
4. Oscar reviews simulator after each phase — not CI-only.
5. No “scaffold shipped” claims — phase done only when gate passes.

---

## Risk register

| Risk | Mitigation |
|------|------------|
| FM only on iOS 26 + Apple Intelligence | Honest unavailable UI; sell privacy + habit moat |
| Generated 365-day plans feel repetitive | Editorial week 1–4; regenerate script later |
| CloudKit + privacy mismatch | Phase 0 decision |
| PrayerLock frustrates users | Exit offers v1 locked; monitor D2P |
| App Review placeholder rejection | No PlaceholderScreen in submission binary |
| Encryption export | Update Info.plist when AES ships |

---

## Files to read first (every agent)

1. `AGENTS.md`
2. This plan
3. `docs/project-playbook.md`
4. `docs/selah-interactive-mock-v4.html` (visual truth)
5. Phase-specific spec from table in `AGENTS.md`

---

## Unresolved for Oscar (Phase 0)

1. ~~CloudKit journal v1 **yes** (update privacy + onboarding #9) **or local-only** v1?~~ **Locked: CloudKit v1** (Oscar 2026-08-24)
2. Editorial pass on reading plan week 1–4 copy — agent draft (default) or Oscar writes?
3. FM unavailable messaging tone — grace (default) vs upgrade nudge?

**Status:** Phase 0 sufficient to start Phase 1. Oscar says **“bắt đầu”** to kick off build program.
