# Release 1.0 (4) privacy boundary

Only onboarding screen events, paywall events, purchase success/restore, and notification permission choices are sent to PostHog. Only a validated subscription tier is attached. No global quiz or plan properties, mood values, Talk/Pray events, crisis signals, session replay, automatic screen capture, or location enrichment. All other events in the historical catalog below are local no-ops.

# PostHog analytics events (locked catalog)

> Project `573828`. Filter `is_demo=true` or exclude demo scheme sessions.

## Global properties

| Property | When |
|----------|------|
| `is_demo` | `true` when `-DemoMode` |
| `fm_available` | Talk/Pray/FM surfaces |
| `plan_theme` | peace / daily / free / know |
| `quiz_distance_branch` | From onboarding quiz |

## Onboarding

| Event | Screen |
|-------|--------|
| `onboarding_01_welcome` | Welcome |
| `onboarding_02_hook` | Emotional hook |
| `onboarding_03_stat` | Stat |
| `onboarding_04_quiz_distance` | Distance quiz |
| `onboarding_05_quiz_desire` | Desire quiz |
| `onboarding_06_quiz_habit` | Habit quiz |
| `onboarding_07_mirror` | Mirror |
| `onboarding_08_commitment` | Commitment |
| `onboarding_09_privacy` | Privacy |
| `onboarding_10_demo` | Live demo (FM only) |
| `onboarding_11_demo_result` | Demo result |
| `onboarding_12_building` | Building plan |
| `onboarding_13_plan` | Plan reveal |
| `onboarding_14_widget` | Widget hook |
| `onboarding_15_social` | Social proof |
| `paywall_view` | Paywall #16 |
| `paywall_payment_sheet_cancelled` | StoreKit sheet dismissed |
| `paywall_exit_offer_view` | Exit #1 monthly sheet — **deferred v1** (`ui-parity-audit-v4.md`) |
| `paywall_exit_subscribe` | Exit purchase success — **deferred v1** |
| `paywall_relaunch_weekly_emphasis` | 2nd+ paywall presentation |
| `subscribe` | Success + `tier` + `surface` (`primary` / `exit_monthly` / `exit_weekly`) |
| `onboarding_17_notifications` | Notification prompt |

## App screens

| Event | Screen |
|-------|--------|
| `today_open`, `cta_5min`, `mood_quick`, `streak_view` | Today |
| `read_open`, `plan_read_complete`, `verse_reflect_tap` | Read |
| `talk_open`, `mode_heart`, `mode_reflect`, `mode_release`, `session_complete`, `crisis_sheet_shown` | Talk |
| `pray_open`, `lectio_step_read`, `lectio_step_reflect`, `lectio_step_pray`, `lectio_step_rest`, `lectio_complete`, `amen_tap` | Pray |
| `journey_open`, `grace_day_applied`, `plan_day_complete`, `streak_reset`, `streak_increment` | Journey |
| `settings_open`, `restore_tap`, `auto_delete_toggle` | Settings |

## Reading journey

`plan_week_start`, `plan_week_complete`, `plan_arc_complete`, `read_open_chapter_picker`

## FM / safety

`fm_unavailable_shown`, `crisis_sheet_shown` (no message content)

## Notifications

`notification_permission_allow`, `notification_permission_deny`, `notification_time_changed`

## RevenueCat → PostHog

Enable manual integration in RC dashboard after first `subscribe` events ship.
