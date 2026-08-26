# Paywall TDD matrix (locked)

> Failing tests before implementation. XCTest + `Selah.storekit` + sandbox + XcodeBuildMCP.

## SubscriptionService protocol (test double)

```text
isSubscribed
packages (weekly, monthly, yearly)
purchase(package) -> Result
restore() -> Result
onPaymentSheetCancelled -> trigger exit flow
paywallPresentationCount
```

## Gate tests (PrayerLock)

| ID | Case | Expected |
|----|------|----------|
| PW-G01 | Onboarding done, not subscribed | Paywall, not main app |
| PW-G02 | Subscribed | Main app |
| PW-G03 | Kill + relaunch unsubscribed | Paywall |
| PW-G04 | Demo mode | Main app bypass |
| PW-G05 | No purchase | Never main tabs |

## Purchase tests

| ID | Case | Expected |
|----|------|----------|
| PW-P01 | Purchase yearly | `premium` active |
| PW-P02 | Purchase monthly (primary or exit) | `premium` active |
| PW-P03 | Purchase weekly | `premium` active |
| PW-P04 | Cancel StoreKit sheet | Locked + Exit #1 eligible |
| PW-P05 | Purchase fail | Error UI, locked |
| PW-P06 | Primary default tier | Yearly pre-selected |

## Exit offer tests (locked v1)

| ID | Case | Expected |
|----|------|----------|
| PW-E01 | Payment sheet cancelled | Show Exit #1 monthly sheet |
| PW-E02 | Tap “See monthly plan” | Show Exit #1 monthly sheet |
| PW-E03 | Exit #1 → purchase monthly | Gate opens, `surface=exit_monthly` |
| PW-E04 | Exit #1 → tap weekly link | Purchase weekly package |
| PW-E05 | Decline exit sheet | Still paywall, locked |
| PW-E06 | Paywall presentation count ≥ 2 | Weekly emphasized (Exit #2) |
| PW-E07 | Paywall presentation count 1 | Yearly default (primary) |
| PW-E08 | After exit purchase fail | Still locked |

## Restore tests

| ID | Case | Expected |
|----|------|----------|
| PW-R01 | Restore active sub | Gate opens |
| PW-R02 | Restore none | Gentle alert, locked |
| PW-R03 | Reinstall + restore | Gate opens |

## RC / offering

| ID | Case | Expected |
|----|------|----------|
| PW-O01 | Offering load fail | Retry UI |
| PW-O02 | Product IDs | `com.lilgroup.selah.{weekly,monthly,yearly}` |
| PW-O03 | Already subscribed | No paywall |

## Analytics

| ID | Case | Expected |
|----|------|----------|
| PW-A01 | Primary paywall | `paywall_view` |
| PW-A02 | Payment cancelled | `paywall_payment_sheet_cancelled` |
| PW-A03 | Exit sheet | `paywall_exit_offer_view` |
| PW-A04 | Relaunch ≥ 2 | `paywall_relaunch_weekly_emphasis` |
| PW-A05 | Subscribe | `subscribe` + tier + surface |
| PW-A06 | Demo | No events / `is_demo` |

## Deferred (not v1 tests)

- Intro yearly $39.99
- Trial
- RC promotional offers on cancel subscription

## XcodeBuildMCP

`build_run_sim` → paywall snapshot → cancel sheet → exit sheet snapshot → sandbox purchase → Today tab.
