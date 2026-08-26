# Reading journey — beyond the first 7 days (locked)

> Onboarding sells a **personal week**. The product is a **long-term habit**, not a one-week course.

## Model (locked v1)

```
Onboarding quiz (desire) → theme label → Week 1 curated plan (7 days)
        ↓
Complete Day 7 → auto-unlock Week 2 of same theme (another 7 days)
        ↓
After theme arc (52 weeks) → continue year rhythm or open Bible chapter picker
```

| Layer | Rule |
|-------|------|
| **Week 1** | Shown in onboarding #13. Personalized **theme** from desire quiz: Peace · Consistency · Freedom · Scripture |
| **Week 2–52** | Same theme, new passages each week from static JSON (`data/reading-plans/`) |
| **Day 365** | Closing day in week 53 (single day) |
| **After year** | Journey: continue daily rhythm or open Bible nav |
| **Today / Read** | Always surfaces **today’s plan day** first; full Bible available from Read chapter picker |
| **Streak** | Any plan day OR ≥5 min Pray/Talk counts (grace day unchanged) |

## Theme library (content)

Four themes × **365 days** each — **`data/reading-plans/`** (regenerate: `python3 scripts/data/generate-reading-plans.py`).

| Theme | Desire quiz | File |
|-------|-------------|------|
| Peace | `peace` | `data/reading-plans/peace.json` |
| Consistency | `daily` | `data/reading-plans/consistency.json` |
| Freedom | `free` | `data/reading-plans/freedom.json` |
| Scripture | `know` | `data/reading-plans/scripture.json` |

Index: `data/reading-plans/index.json`.

| Theme | Week 1 focus (onboarding reveal) | Week 2–4 direction |
|-------|-----------------------------------|-------------------|
| Peace | Be still, refuge psalms | Anxiety → rest, surrender |
| Consistency | Short Gospels + habit psalms | Building rhythm, morning anchors |
| Freedom | Psalm 51, forgiveness, Romans | Guilt → grace, honest talk with God |
| Scripture | Foundational passages (John, Psalms) | Know God’s story, not trivia |

**Distance quiz** branches paywall headline and Talk tone hints; does **not** change plan theme v1.

## UX copy (Journey)

- While on plan: “Your 7-day plan” + week indicator (`Week 2 of Peace`)
- Day 8+: “This week” list + completed weeks collapsed below
- Plan complete (year arc): celebration + CTA Read / continue rhythm (v2: theme switch)

## MVP scope

| Ship | Defer |
|------|-------|
| Week 1 playlists (4 themes × 7 days) | FM-custom per-user plan generation |
| Auto-advance to Week 2 when Week 1 complete | User-picked theme switch mid-arc |
| Full KJV reader (any chapter) | Audio, search, second translation |

## Analytics

`plan_week_start`, `plan_day_complete`, `plan_week_complete`, `plan_arc_complete`, `read_open_chapter_picker`
