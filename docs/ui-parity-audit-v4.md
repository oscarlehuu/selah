# UI Parity Audit — SwiftUI vs `selah-interactive-mock-v4.html`

Audited 2026-08-25. Mock v4 is the design source of truth. This file is the fix checklist.

> **STATUS 2026-08-25 (evening): FIXED.** All screens below rewritten to mock v4 custom layouts
> (Paywall, Today, Read, Talk, Pray, Journey, Settings, onboarding gaps 08/10/11/14/17, tab bar blur).
> iCloud-sync + Face ID toggles removed from Settings (re-add post-ship if wanted). Widget onboarding
> screen implemented but intentionally kept out of the pre-paywall flow (locked by
> `OnboardingFlowMappingTests`). 67 unit + 9 UI tests green. Chrome expectations now enforced by
> `NativeChromeUITests` (custom SelahNavBar, no native nav titles, paywall footer legal row).

## Root cause (systemic)

The SwiftUI app was built with **native `List` / `Form` / `insetGrouped` / toolbars**, while the mock is a
**custom Sunday Light layout** (hero photos, glass cards, gold tier cards, custom navbar/tabbar with blur).
Agents also **invented UI not in the mock** (nav titles, toolbar buttons, extra sections).

### Global rules for any fix agent (non-negotiable)

1. Mock v4 is pixel truth. Do NOT add any element not present in the mock (no `navigationTitle`, no toolbar
   buttons, no section headers, no extra CTAs) unless this file says "keep".
2. Replace `List`/`Form` screens with custom `ScrollView` layouts using SelahColors/SelahFont tokens.
3. Navbar = custom: blurred `rgba(250,247,242,.82)`, centered display-font title, 40px icon buttons.
4. Tab bar: translucent blur `rgba(250,247,242,.78)`, top hairline border, small uppercase labels.
5. Keep all existing logic/analytics/accessibility identifiers; only the view layer changes.

## Paywall (`PaywallView.swift`) — worst drift

| # | Mock (lines 1104–1131, CSS 343–361) | Code |
|---|---|---|
| 1 | Hero photo 118px + veil, back + progress | Missing — native nav bar |
| 2 | No title | Added `navigationTitle("Selah Premium")` — REMOVE |
| 3 | Restore = small underlined link in footer row (Restore · Terms · Privacy) | Added toolbar top-right — MOVE to footer |
| 4 | Headline display font, centered under hero | In List section, leading, + extra subtitle — fix |
| 5 | Bullets: 34px gold icon tiles, no header | "Included" section header — REMOVE header, custom rows |
| 6 | Tier cards: 1.5px border, selected = gold border + accent-soft bg + shadow, floating "BEST VALUE" badge, price + unit right | Native List rows + checkmark, "Choose a plan" header — rebuild custom |
| 7 | Order Weekly → Yearly(badge) → Monthly, default Yearly, CTA "Start Selah · $49.99/yr" | `emphasizeWeekly` default-weekly + "Popular" label — REMOVE (decision: delete PaywallExitPolicy UI influence) |
| 8 | No "See monthly plan" | Added — DELETE (and remove `ExitMonthlyOfferView` from v1 per decision) |
| 9 | Disclaimer centered under gold CTA, then legal row | In section footer — move |

**Decision (2026-08-25):** delete `PaywallExitPolicy` / exit-monthly-offer / emphasizeWeekly from paywall v1.

## Today (`TodayView.swift`)

- Missing: photo hero (`.today-hero` 330px) + veil; glass verse card (white .62 + blur, save/share icons);
  streak chip absolute top-left; date label "Monday · 24 August"; section heads (display font h2 + link);
  4-col mood quick grid; Lock-Screen-widget promo gradient card; gold gradient CTA in `.today-actions`.
- Remove: native large title "Today", toolbar gear (use custom header row with streak chip + gear), List sections.

## Read (`ReadView.swift`)

- Missing: custom navbar (chapter-picker title button, "Aa" text-size, bookmark); plan-tag blue chip;
  chapter intro label; verse superscript numbers; gold gradient-underline highlight (`data-hl`);
  blue tap-selection background; bottom read-toolbar (mark as read + reflect); verse action sheet options
  (Highlight, Reflect, Copy, Save to journal).
- Remove/replace: "Plan day / Jump to plan" section, " ★" suffix highlight hack, native List.

## Talk (`TalkView.swift`)

- Missing: custom mode-seg pills (not native segmented picker); privacy banner blue-soft card w/ lock icon;
  asymmetric bubble corners (19/19/6/19); bubble reveal animation; custom composer pill w/ blur + circular
  send button; mic icon; warm gradient background; suggestion chips w/ shadow.
- Remove: native title "Talk", List sections. Keep: crisis handling, clear-session (style per mock),
  companion-unavailable state (style as quiet note, not tech text).

## Pray (`PrayView.swift`)

- Missing: custom step bars w/ labels (not ProgressView); breath circle animation ("Slow down"/"Stay here");
  warm gold gradient bg; prayer card w/ shadow + serif italic; amen gold burst; timer chip w/ clock icon;
  gold reflection chips.
- Remove: native title "Pray". Keep logic (LectioPrayEngine) untouched.

## Journey (`JourneyView.swift`)

- Missing: SVG-style curved streak path w/ day dots + checkmarks; 3-tile stat grid (Longest streak / Minutes
  in prayer / Chapters read); grace-day chip styling; journal date block (big day number + month, 42px col);
  gold "Encrypted" lock chip header; custom navbar.
- Remove: extra "This week" LabeledContent section; native toolbar; List layout.

## Settings (`SettingsView.swift`)

- Missing: sheet-with-grab-handle presentation; subscription gradient sub-card (plan, renewal, price,
  Manage/Restore); 30px colored row icons; "Lock Screen widget · Soon" row; "What Selah is not" row;
  version footer "Selah v1.0 · Made for quiet mornings."
- Added not in mock: iCloud sync + Face ID toggles (product decision — confirm keep/drop), Stepper for time
  (mock uses time picker).

## Onboarding (`OnboardingStepContent.swift` etc.)

Mostly faithful. Fix list:
- Screen 08 Commitment: sky hero (214px) MISSING entirely.
- Screen 10 Demo mood: "Only on this device" priv-banner missing.
- Screen 11 Demo result: 3-dot typing indicator (not ProgressView); footer companion disclaimer missing.
- Screen 14 Widget: `EmptyView()` — entire screen missing (Coming-soon chip + lock screen preview).
- Screen 17 Notifications: rebuilt as native List w/ nav title "Reminders" + "Preview" header — rebuild as
  centered custom layout: 72px gold bell tile, title, sub, notification preview card ("Selah · now").
- Polish: window light-beam + breathing glow on hero (01/02), bar entry animation timing (03).

## Global chrome

- TabView: needs translucent blurred custom-styled bar (or heavy appearance customization).
- Sheets: 22px top radius + grab handle.
- Background #FAF7F2 matches ✅.

## Suggested fix order

1. Paywall (highest-visibility, screenshot in review) 2. Today 3. Talk 4. Pray 5. Read 6. Journey
7. Settings 8. Onboarding gaps (08, 10, 11, 14, 17) 9. Chrome (tabbar/navbar/sheets).
