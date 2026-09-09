# Selah — Project Playbook

> **Main project document.** Agents and humans should read `AGENTS.md` first, then this file for full product/growth context.
>
> **Nguồn growth framework:** [Frederick James — Financial freedom from mobile apps](https://x.com/frederickjames/status/2091503229146194334)
> **Cập nhật:** 2026-08-24

---

## 0. TL;DR

| | |
|---|---|
| **App** | Selah — private daily Bible + prayer companion (iOS native) |
| **Markets** | US → Australia → UK/EU English (Protestant broad) |
| **Moat** | On-device AI (Foundation Models), encrypted journal, no cloud for spiritual chat |
| **Monetization** | Hard paywall, $7.99/w · $14.99/m · $49.99/y |
| **Growth** | Onboarding issue-hook → paywall → TikTok + Apple Search Ads |

| Frederick nói | Selah áp dụng |
|---|---|
| Sell to **core human desire** | religion / meaning — gần Chúa, bình an, giải phóng |
| Onboarding: **nhắc issue → giải pháp** | mồi câu subscribe |
| Study **PrayerLock** onboarding | benchmark cùng niche |
| iOS native SwiftUI | Foundation Models on-device |
| Hard paywall + RevenueCat | subscription sau onboarding |
| TikTok + Apple Search Ads | creative = khoảng trống với Chúa |

---

## 1. Core User Issue — “Mồi câu”

### Issue spine

> **“Tôi muốn gần Chúa hơn — nhưng cuộc sống quá nhiễu loạn, tôi không đọc Lời Chúa đều, và khi cần tâm sự hoặc ăn năn, tôi không có không gian riêng tư thật sự.”**

### Quiz branches (onboarding)

| ID | Issue | Hook |
|---|---|---|
| **A** | Khoảng cách với Chúa | *“Lần cuối bạn thật sự nói chuyện với Chúa — không phải đọc lại một câu — là khi nào?”* |
| **B** | Không đọc đều | *“Bạn đã bắt đầu đọc Kinh Thánh bao nhiêu lần… và bỏ giữa chừng?”* |
| **C** | Mang nặng / guilt | *“Có điều gì bạn chưa dám mang đến trước mặt Chúa?”* |

TikTok lead: **C**. Onboarding: user self-selects A/B/C.

### Tránh

- “Học Kinh Thánh” / tra cứu verse (utilitarian)
- “Thay linh mục” (guardrails + App Review)
- “Chatbot AI về Chúa” (fake, mất trust)

---

## 2. Positioning

**Tagline:** *“Không gian riêng với Chúa — trên điện thoại của bạn.”*

**Bán impact, không bán product:**

| Impact | Under the hood |
|---|---|
| 5 phút im lặng với Chúa mỗi ngày | daily reading plan |
| Không ai biết, không ai đọc | on-device AI + encryption |
| Được lắng nghe trước khi bị phán xét | tâm sự mode |
| Bắt đầu lại — không shame | grace day streak |

**Selah brand:** Hebrew liturgical mark in Psalms (~74×). Meaning: **pause, reflect, listen to God**. Onboarding one-liner: *“Selah — pause. Reflect. Listen to God.”*

---

## 3. Onboarding

**Full spec:** `docs/onboarding-spec.md` (16 screens, screen-by-screen).

Benchmark: **PrayerLock** (structure, not 1:1 tone). Frederick: ~12 screens directional; Selah starts at **16** + post-paywall notify. Target completion ≥ 75%, D2P ≥ 8% before ads.

**3-act story:** Problem (1–6) → Journey + live demo (7–12) → Convert (13–17).

**Frederick rules applied:** remind issue → show solution · images over text · quiz 4 max · social proof · measure funnel · permissions after paywall.

**Selah twist:** Sunday Light UI · mood → prayer/reflection demo before paywall · no guilt-dark · no signature v1.

| Branch | Paywall headline |
|---|---|
| A — Distant | Start talking to God every day |
| B — Inconsistent | Read the Bible 5 minutes a day — without quitting |
| C — Heavy | A private space to talk to God |

Hard paywall (no trial v1). PostHog event per screen.

---

## 4. Paywall & Pricing

1. Social proof → 2. Impact headline → 3. 3 bullets (Private / Daily / Companion) → 4. Compliant pricing → 5. CTA *“Bắt đầu hành trình”*

| Tier | Price |
|---|---|
| Weekly | $7.99/w (anchor) |
| Monthly | $14.99/m |
| Yearly | $49.99/y (**push this**, cap ≤ $50) |

RevenueCat (purchases + entitlements; SwiftUI paywall UI native). PostHog (onboarding funnel). Apple Small Business Program. Disclaimer: không thay linh mục/mục sư/counselor.

---

## 5. Design & UI/UX (locked)

### Feeling (north star)

Opening Selah should feel like **walking into a bright church on Sunday morning**, or a quiet retreat garden at golden hour. **Joy, peace, welcome.** Not guilt, shame, or gothic darkness.

| Feel this | Not this |
|---|---|
| Light through windows, soft air, warmth | Black confession booth, heavy shadows |
| Happy to meet God | Afraid of judgment |
| Retreat / sanctuary | Productivity / dark-mode “focus app” |
| Soft color, living light | Flat dark / flat light toggle as brand |

**Onboarding may agitate the issue** (TikTok/hooks). **Inside the app, grace wins.** Confession / tâm sự modes stay soft and private. Never “dark sin aesthetic.”

### Direction chosen: **Sunday Light**

Compared three options; locked **Sunday Light**.

| Option | Mood | Why not / why |
|---|---|---|
| A. Sunday Light ⭐ | Soft sky, warm white, gentle gold | Matches “nhà thờ hạnh phúc + retreat” |
| B. Garden Retreat | Botanical greens | Pretty but can feel wellness/spa, less “sanctuary” |
| C. Stained Glass Joy | Soft color washes | Risk busy / childish if overdone; accents only |

### Visual system (v1)

| Token | Guidance |
|---|---|
| **Base** | Soft morning white / pale sky wash. Not pure gray sterile. Not cream-terracotta cliché. |
| **Primary** | Soft sky blue (calm, open air) |
| **Accent** | Soft gold / sun (joy, hope). Sparingly. |
| **Text** | Warm soft charcoal. Never harsh pure black on bright white. |
| **Scripture** | Readable serif or soft display for verses. UI chrome = friendly sans (SF Pro OK). |
| **Surfaces** | Soft gradients, light bloom, gentle depth. Prefer atmosphere over card grids. |
| **Imagery** | Real light, windows, open sky, soft nature. Avoid skulls, crosses-as-horror, blood red. |

### Modes (not “Dark vs Light brand”)

| Mode | Use | Look |
|---|---|---|
| **Day (default)** | Home, reading, onboarding, paywall | Sunday Light |
| **Quiet evening** (optional later) | Night reading | Soft dusk blue, still gentle. Not OLED black guilt. |
| **Private talk** | Tâm sự / xưng tội | Soft private room + warm light. Intimate, safe, hopeful. |

No dark theme as identity. Optional system appearance later only if it stays soft.

### Motion & micro-UX

- Slow breathe / fade. Soft spring. No aggressive bounce or “level-up dopamine.”
- Streak = gentle encouragement (“grace day”), not red fail states.
- Empty states warm and inviting (“Come sit a while”).

### Competitor contrast

| App | Typical feel | Selah |
|---|---|---|
| Hallow | Contemplative, often moody | Brighter, happier sanctuary |
| Abide | Sleep / calm dark | Daylight joy first |
| YouVersion | Utility / content | Retreat atmosphere |
| PrayerLock | Urgency / lock | Welcome / open door |

### Design open polish (later)

- Exact hex palette + Figma tokens
- Illustration vs photography mix

**Locked:** App icon = `docs/brand/selah-icon-pause.svg` → **`docs/brand/selah-icon-pause-1024.png`** (App Store). Legal = GitHub Pages at `docs/site/` ([live](https://oscarlehuu.github.io/selah/site/privacy.html)).

---

## 6. Markets

**Order:** US → Australia → UK → Ireland → EU English → DE/FR localize later.

**Audience:** Protestant broad (subtitle/metadata). EU VAT lowers margin; scale US/AU first.

---

## 7. ASO (locked)

| Field | Value |
|---|---|
| **Brand** | Selah |
| **Title** | `Selah: Private Bible & Prayer` |
| **Subtitle** | `Private Christian Devotional` |
| **Keywords** | `scripture,verse,study,faith,worship,meditation,quiet,kjv,holy,spiritual,reading,habit,streak,psalm,amen,guide,reflection` |

Release 1.0 (4): Apple rejected the availability of `Selah: Daily Prayer & Bible` and `Selah: Bible & Prayer` because both names were taken. The user approved `Selah: Private Bible & Prayer`, which ASC accepted on 2026-09-09. Subtitle remains `Private Christian Devotional` as approved, including the repeated word Private. China mainland is excluded from distribution.

Analytics now permits only onboarding/paywall/subscription funnel events and notification permission choices, with a random app identifier and an allowlisted subscription tier. Quiz, mood, plan, conversation and crisis context are blocked before capture and before send. See `docs/analytics-events.md` and the current privacy policy.

Prefer no word repeats across title / subtitle / keywords for future experiments. Astro validate pre-ship. ASA bid competitors (YouVersion, Hallow, Glorify, PrayerLock, Abide).

**Promo text:** Your private space with God. Daily Bible, prayer, and reflection — only on your phone.

---

## 8. MVP Checklist

- [ ] iOS SwiftUI native
- [ ] Hard paywall (RevenueCat) at onboarding #16
- [ ] Onboarding 16 screens (`docs/onboarding-spec.md`)
- [ ] 6 core screens (`docs/app-screens-spec.md`): Today, Read, Talk, Pray, Journey, Settings
- [ ] Bible reader offline (license TBD)
- [ ] Daily verse + streak (grace day 1/week)
- [ ] AI companion on-device (Foundation Models) — Tâm sự mode minimum
- [ ] Encrypted journal (Keychain)
- [ ] Analytics funnel
- [ ] App Store assets (emotion-first screenshots)

**Metrics:** onboarding ≥ 75% · D2P ≥ 8% · track paywall conversion

---

## 9. Growth (post-MVP)

TikTok US English, $50–70/day, GBBI 20%, ≥5 creative formats, CPA < LTV ~$20.

Apple Search Ads: $100 credit, competitor keywords, Search Match OFF.

AppsFlyer → TikTok Events (`app_open`, `subscribe`).

---

## 10. Moat vs Competitors

| Competitor | Gap | Selah |
|---|---|---|
| YouVersion | No private AI companion | on-device tâm sự |
| Hallow | Cloud-heavy | 100% on-device |
| PrayerLock | Lock-only | read + reflect + companion |
| Glorify | Content library | personalized by issue/mood |

---

## 11. Guardrails

1. Crisis keywords → hotline, not only AI
2. Catholic confession: not sacramental replacement
3. Confession sessions may auto-delete; no long-term confession logs
4. App Review: honest, premium, no misleading
5. Never “AI replaces God/priest” in marketing

---

## 12. Execution Order

```
Week 1–2   Reader + onboarding (no AI)
Week 2     Paywall + RC + analytics
Week 3     Submit MVP (early Apple review)
Week 4–5   Foundation Models + encrypted journal
Week 6     Onboarding AB + App Store assets
Week 7+    TikTok + Apple Search Ads
```

---

## 13. Open Questions

- [ ] Bible translation + license (KJV first for US?)
- [ ] Foundation Models Vietnamese quality (later market)
- [ ] PrayerLock onboarding teardown (install + funnel record)
- [ ] Domain: `selah.app` / `getselah.com`

---

## Appendix: Frederick Framework

**App:** desire → iOS → gap vs competitor → MVP ship → paywall → onboarding → metrics

**Ads:** MMP → TikTok ($50–70/day, GBBI, US manual) → 5 formats → scale winners

**Apple Ads:** search intent, competitor keywords, $100 credit

**Margins:** ~30% realistic on paid-only; EU VAT haircut
