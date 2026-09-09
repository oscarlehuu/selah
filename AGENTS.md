# AGENTS.md — Selah

Instructions for AI agents working in this repository. Read this file first, then `docs/project-playbook.md` for full product and growth context.

---

## Project

**Selah** is an iOS-native app that helps Christians in US, Australia, and Europe build a daily Bible and prayer habit, with a **private on-device spiritual companion** (talk, reflect, confess to God). Nothing sensitive leaves the device.

**Workspace:** `/Users/a1241968/Desktop/Oscar/Bible` (pre-code; greenfield as of 2026-08-24)

---

## Documentation map

| File | Purpose |
|---|---|
| **`docs/project-playbook.md`** | **Main doc** — product, paywall, ASO, growth, guardrails |
| **`docs/onboarding-spec.md`** | 16-screen onboarding — copy, psychology, analytics |
| **`docs/app-screens-spec.md`** | 6 core screens — features, nav, monetization |
| **`docs/selah-interactive-mock-v3.html`** | **Interactive mock (current)** — iOS-fidelity prototype: 17-screen onboarding + 6 app screens, push/pop nav, swipe-back, sheets. Open in browser |
| `docs/selah-interactive-mock.html`, `-v2.html` | Superseded mocks — keep for reference only |
| **`design-system/selah/MASTER.md`** | **Design tokens** — Sunday Light palette, type, spacing, components |
| **`docs/brand/selah-icon-pause.svg`** | **App icon (locked)** — gold pause bars, Sunday Light sky |
| **`docs/site/`** | **GitHub Pages legal** — privacy + terms (publish from `/docs`) |
| `plans/` | Implementation plans only (phases, spikes). Not product truth. |
| `AGENTS.md` | This file — agent entry point and locked decisions |

When product decisions change, update **`docs/project-playbook.md`** and the **Locked decisions** section below.

---

## Locked decisions

### Brand & ASO (App Store Connect)

| Field | Value |
|---|---|
| Brand name | **Selah** |
| Title (30 chars) | `Selah: Private Bible & Prayer` |
| Subtitle (30 chars) | `Private Christian Devotional` |
| Keywords (100 chars) | `scripture,verse,study,faith,worship,meditation,quiet,kjv,holy,spiritual,reading,habit,streak,psalm,amen,guide,reflection` |

Do not repeat words across title, subtitle, and keywords field. Validate with Astro before ship.

**Selah meaning:** Hebrew mark in Psalms (~74×). Pause, reflect, listen to God. Onboarding explains once: *“Selah — pause. Reflect. Listen to God.”*

**App icon (locked):** `docs/brand/selah-icon-pause.svg` — export 1024×1024 PNG (opaque) for App Store Connect.

### Markets

1. **US** (primary — ads + highest LTV)
2. **Australia**
3. **UK / Ireland** (English EU)
4. **EU localize** (DE/FR) later — accept lower margin (VAT)

**Audience:** Protestant broad. Not Catholic-first (no rosary in v1 metadata).

### iOS app identity (locked for RC / ASC)

| Field | Value |
|---|---|
| Bundle ID | `com.lilgroup.selah` |
| Bundle ID resource ID | `VVCJFJW56Y` (IN_APP_PURCHASE enabled) |
| ASC App ID | `6804629231` |
| ASC record name | `Selah: Private Bible & Prayer` (confirmed in ASC 2026-09-09) |
| ASC SKU | `selah-ios` |
| App Store URL | https://apps.apple.com/us/app/id6804629231 |
| RevenueCat project | `proj75404991` (Selah) |
| RevenueCat iOS app | `appebafc80e37` |
| RC public SDK key | `appl_AaSHElZdDxAyaZCEQHnBOSjMpfB` |
| PostHog project | `573828` (Selah, US) |
| PostHog project API key | `phc_obHdAy4NerRVKJf2Z5xyYMdkbEvpZZKmvZvEthkW56mq` |
| Privacy Policy URL | `https://oscarlehuu.github.io/selah/site/privacy.html` |
| Terms of Use URL | `https://oscarlehuu.github.io/selah/site/terms.html` |
| GitHub repo | https://github.com/oscarlehuu/selah (public; Pages from `/docs`) |

**ASC app + subscriptions pushed 2026-08-24.** Subscription group **`Selah Premium`** on ASC. All 3 tiers `READY_TO_SUBMIT` (175 territories equalized from US base). Sandbox purchase tests OK before App Review. First submit must attach IAPs to an app version in ASC UI (Apple rule).

### Platform & stack (planned)

- **iOS only** v1 — SwiftUI, native
- **AI:** Apple Foundation Models (on-device). No cloud for spiritual chat v1
- **Bible:** offline SQLite/USFM — translation + license TBD (KJV likely for US)
- **Paywall / subscriptions:** **RevenueCat** — hard paywall, no trial v1; custom SwiftUI paywall UI + RC purchases
- **Analytics:** **PostHog** — onboarding funnel events (`onboarding-spec.md`)
- **Attribution:** AppsFlyer → TikTok (post-MVP)
- **MCP (Cursor, this repo):** `.cursor/mcp.json` — RevenueCat + PostHog (project-scoped keys). See **MCP setup** below.

### Pricing

| Tier | USD |
|---|---|
| Weekly | $7.99 |
| Monthly | $14.99 |
| Yearly | $49.99 (default push) |

### Core user issue (conversion spine)

Users feel **distant from God**, **inconsistent with Bible reading**, and lack a **truly private space** for prayer and repentance. Onboarding agitates this issue before paywall. See playbook §1.

### Design & UI/UX (locked)

**North star:** Opening Selah feels like **Sunday morning church** or **retreat garden at golden hour**. Joy, peace, welcome. Not guilt, shame, or gothic dark.

**Direction:** **Sunday Light** (soft sky blue + warm white + soft gold accents). Not dark/light theme as brand identity.

| Principle | Rule |
|---|---|
| Onboarding hooks | May agitate issue (growth). In-app tone = grace |
| Confession / tâm sự | Soft private room, warm light. Never “sin dark” aesthetic |
| Streak | Gentle encouragement + grace day. No red shame UI |
| Motion | Slow breathe, soft fade. No gamified dopamine |
| Avoid | Black confession booth, blood red, skulls, harsh OLED black as default |

Full spec: `docs/project-playbook.md` §5.

### Positioning

- Sell **impact** (private space with God, 5 min/day, no shame), not “Bible app with AI”
- Tagline: *Không gian riêng với Chúa — trên điện thoại của bạn.*
- TikTok creative lead: emotional hook + privacy on-device. **In-app UI stays joyful sanctuary** (not guilt-dark)

### App structure (locked)

**6 screens:** Today · Read · Talk · Pray · Journey · Settings (sheet).

**Nav:** 5 tabs (Today, Read, Talk, Pray, Journey) + Settings from header.

**Monetize:** hard paywall once at onboarding end. All screens unlocked for subscribers. No ads, no per-screen IAP v1.

Full spec: `docs/app-screens-spec.md`.

### Moat

Private on-device companion + encrypted journal vs YouVersion / Hallow / PrayerLock / Glorify.

### Guardrails (non-negotiable)

- AI is **not** God, priest, pastor, or therapist — disclaimers in app and near paywall
- Sacramental confession (Catholic) is **not** replaced
- Crisis language → hotline resources, not only AI comfort
- Confession content: no long-term logs; optional auto-delete after session
- App Review: honest, premium UX; no misleading claims

---

## Competitors (benchmark, do not copy 1:1)

| App | Note |
|---|---|
| YouVersion | Bible reading leader; no private AI |
| Hallow | Prayer & meditation; Catholic tilt |
| Glorify | Devotional & prayer |
| PrayerLock | Onboarding masterclass; screen-time + prayer |
| Abide | Meditation / sleep Bible |

Apple Search Ads: bid on competitor names (not in keyword metadata).

---

## Metrics targets (MVP)

| Metric | Target |
|---|---|
| Onboarding completion | ≥ 75% |
| Download → paid (D2P) | ≥ 8% |
| Refund rate | monitor; yearly > $50 increases refunds |

---

## Agent workflow

1. Read `AGENTS.md` (this file) and `docs/project-playbook.md` before implementation.
2. Product/growth changes → edit `docs/project-playbook.md`, then sync **Locked decisions** here.
3. Implementation plans → `plans/` with dated folders (not duplicate playbook content).
4. iOS native SwiftUI. Keep files focused (<200 lines when code exists).
5. No commits unless user asks. No secrets in repo.

---

## MCP setup (Cursor)

MCP configs live in **`.cursor/mcp.json`** (this project only — not global). RevenueCat MCP is **account-level** (one endpoint, `list-projects`), but use a **Selah-scoped API v2 key** here so agents in other repos do not inherit Selah RC access.

| Server | Env var | Where to create |
|--------|---------|-----------------|
| `revenuecat-selah` | `REVENUECAT_API_V2_KEY` | RevenueCat dashboard → API keys (v2, scoped to Selah project) |
| `posthog-selah` | `POSTHOG_PERSONAL_API_KEY` | PostHog → Personal API keys → MCP Server preset |

Set env vars in Cursor (**Settings → MCP → env**) or shell before opening this workspace. EU PostHog: change URL to `https://mcp-eu.posthog.com/mcp` in `.cursor/mcp.json`.

When calling MCP tools, always pass **`REVENUECAT_PROJECT_ID`** / **`POSTHOG_PROJECT_ID`** for Selah (see table above; `.env.example`). OAuth alternative: Cursor Marketplace plugins `revenuecat` + `posthog` (account-wide).

### RevenueCat catalog (configured 2026-08-24)

| Item | ID / identifier |
|---|---|
| Entitlement `premium` | `entl5dc80bc63a` |
| Offering `default` (current) | `ofrngb83fda3921` |
| Subscription group (ASC) | **Selah Premium** |
| Weekly | `com.lilgroup.selah.weekly` → `$rc_weekly` (`prod4fc9532ee1`, $7.99 US) |
| Monthly | `com.lilgroup.selah.monthly` → `$rc_monthly` (`prodaf18f525cd`, $14.99 US) |
| Yearly | `com.lilgroup.selah.yearly` → `$rc_annual` (`prodd3639c9049`, $49.99 US) |
| ASC store status (2026-08-24) | All 3 → `READY_TO_SUBMIT` |
| ASC API key + IAP key | Linked from `AppStoreAPI/` (Admin + Subscription keys) |

### PostHog insights (configured 2026-08-24)

| Insight | URL |
|---|---|
| Onboarding → Paywall | https://us.posthog.com/project/573828/insights/k7BbFQMA |
| Paywall → Subscribe | https://us.posthog.com/project/573828/insights/5V3J7S3e |

**RC → PostHog integration:** enable manually in RevenueCat dashboard (Integrations → PostHog) with PostHog project API key after app ships events.

## ASC CLI (agents)

**Tool:** [Rork `asc`](https://github.com/rorkhq/asc) (`/opt/homebrew/bin/asc`). Repo-local config at **`.asc/config.json`** (API key profile `Selah-ASC`). Keys live in sibling folder `../AppStoreAPI/` (never commit `.p8` files).

| What | Command |
|---|---|
| Verify auth + bundle + app | `./scripts/asc/verify-selah.sh` |
| Create ASC app record | `./scripts/asc/create-selah-app.sh` |
| Register StoreKit IAP key | `./scripts/asc/setup-storekit.sh` (uses `--skip-validation` until IAP products exist in ASC) |

**API key auth** (bundle IDs, list apps, capabilities): works headless via `.asc/config.json` + env `ASC_BYPASS_KEYCHAIN=1`.

**Web session auth** (create app, subscriptions UI flows): Apple does not expose `POST /v1/apps` on the official API. Use `asc web apps create`. Requires one-time login:

```bash
asc web auth login --apple-id lehuunghia.oscar@gmail.com
```

For headless agents, set in Cursor/shell env (not in repo):

| Env var | Purpose |
|---|---|
| `ASC_WEB_PASSWORD` | Apple ID password for web session |
| `ASC_WEB_2FA_CODE_COMMAND` | Shell command that prints 2FA code (recommended for automation) |
| `ASC_WEB_APPLE_ID` | Override Apple ID (default: `lehuunghia.oscar@gmail.com`) |

Cached web session from `asc web auth login` is enough for `./scripts/asc/create-selah-app.sh` (no password env required).

After ASC app exists, re-run RevenueCat product store sync (`get-product-store-state` / `submit-products-to-store`).

## GitHub Pages (legal)

Legal site lives in **`docs/site/`** inside this repo (not a separate repo).

| Page | Path | Published URL |
|---|---|---|
| Hub | `docs/site/index.html` | `https://oscarlehuu.github.io/selah/site/` |
| Privacy | `docs/site/privacy.html` | `https://oscarlehuu.github.io/selah/site/privacy.html` |
| Terms | `docs/site/terms.html` | `https://oscarlehuu.github.io/selah/site/terms.html` |

**Live:** GitHub repo [oscarlehuu/selah](https://github.com/oscarlehuu/selah) — Pages enabled on branch `main`, folder `/docs`.  
To move under `LilGroup` org later, transfer repo and update URLs + RevenueCat `privacy_policy_url`.

Local preview: open `docs/site/privacy.html` in a browser.

## Open questions

- Bible translation license (KJV, NIV, etc.)
- Vietnamese AI companion (future market)
- Domain registration (`selah.app`) — legal URLs use GitHub Pages until custom domain
- PrayerLock funnel teardown

---

## References

- Growth framework: [Frederick James tweet/tutorial](https://x.com/frederickjames/status/2091503229146194334)
- Onboarding benchmark: PrayerLock
- ASO tool: Astro (pre-ship validation)
