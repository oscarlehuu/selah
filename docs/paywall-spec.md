# Paywall — hard gate + exit offers (locked)

> PrayerLock hard paywall. Frederick conversion-first. RevenueCat + custom SwiftUI + StoreKit 2.

## v1 model (locked)

| Rule | Value |
|------|-------|
| When | Onboarding screen **#16** (+ relaunch if unsubscribed) |
| Free tier | **None** |
| Trial | **None** |
| Tiers | Weekly $7.99 · Monthly $14.99 · **Yearly $49.99** (default selected) |
| Stack | RC offering `default` · entitlement `premium` |
| Inside app | 100% unlocked for active subscriber |

## PrayerLock gate (locked)

| Behavior | Rule |
|----------|------|
| Not subscribed | **Cannot** reach main tabs |
| Kill app / relaunch | Return to paywall |
| No skip to home | No “maybe later” free access |
| Demo mode | `-DemoMode` bypasses only |

## Primary paywall (#16)

- Branch headline from quiz (paywall-spec headlines in `onboarding-spec.md`)
- 3 bullets: Private / Daily / Companion
- Tier cards: yearly **pre-selected**
- CTA: Start Selah (yearly price)
- Link: **See monthly plan** → triggers Exit #1 monthly sheet
- Restore · legal · disclaimer
- **No** fake countdown · **No** fake star ratings

## Exit offers v1 (locked — conversion-first)

Frederick spirit: **reframe commitment**, not scam discount. Same public ASC prices.

### Exit #1 — Monthly reframe

| Trigger | User closes StoreKit sheet **without purchase** OR taps **See monthly plan** |
|---------|-----------------------------------------------------------------------------|
| UI | Sunday Light sheet (grace tone) |
| Copy | *“Not ready for a full year? Start monthly — same full Selah.”* |
| CTA | Monthly **$14.99** → `com.lilgroup.selah.monthly` |
| Secondary | Small link → Weekly **$7.99** |
| After decline | Stay on paywall; still locked |

### Exit #2 — Weekly emphasis on relaunch

| Trigger | Paywall shown **≥ 2 times** (relaunch while still unsubscribed) |
|---------|----------------------------------------------------------------|
| UI | Primary paywall layout |
| Change | **Weekly $7.99** highlighted / pre-selected (not yearly) |
| Copy | *“Try one week — full access, private space with God.”* |
| Still no free tier | PrayerLock unchanged |

### Not v1

| Item | When |
|------|------|
| Intro yearly **$39.99** | v1.1 if D2P < 8% (ASC intro offer) |
| Trial | Never v1 |
| Fake % off countdown | Never |
| Remote-only discount after App Review | Never (Apple policy) |

## RC implementation

Custom SwiftUI paywall — **not** embedded `PaywallView`. Exit sheets call `Purchases.shared.purchase(package:)`. Optional RC offering `exit` for analytics segmentation (same products or monthly-first metadata).

## Identity (locked)

Apple IAP receipt → RC. **No SIWA required** for purchase. Optional SIWA in Settings only.

## Restore & manage

Settings → Restore · Manage subscription (App Store). Paywall → Restore link.

## Analytics (locked)

| Event | When |
|-------|------|
| `paywall_view` | Primary paywall shown |
| `paywall_payment_sheet_cancelled` | StoreKit sheet dismissed without purchase |
| `paywall_exit_offer_view` | Exit #1 sheet (`monthly`) |
| `paywall_exit_subscribe` | Exit purchase success + `tier` |
| `paywall_relaunch_weekly_emphasis` | Exit #2 layout (session ≥ 2) |
| `subscribe` | Any successful purchase + `tier` + `surface` (`primary` \| `exit_monthly` \| `exit_weekly`) |
| `restore_tap` | Restore tapped |

Demo: no events or `is_demo=true`.

## App Review

Subscription required. Exit offers use **listed App Store prices** — honest reframe, not hidden discount.

See `docs/paywall-tdd-spec.md`.
