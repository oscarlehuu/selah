# Verse of the day (locked)

> Offline-first. Text from bundled `kjv.sqlite` at runtime.

## Pool

`data/verse-of-the-day.json` — ordered list of `{ "book", "chapter", "verse" }`.

Regenerate: `python3 scripts/data/generate-verse-of-the-day.py`

## Rotation

```
anchor = 2026-01-01 (UTC or local — lock **local** for devotional consistency)
dayIndex = daysBetween(anchor, todayLocal)
entry = pool[dayIndex % pool.length]
text = BibleRepository.verse(book, chapter, verse)
```

Same user sees same verse all day; changes at local midnight.

## Midvash API

`api.midvash.com/v1/votd` may seed the pool at build time only — **no** runtime network for VOTD.

## Surfaces

- Today hero
- Local notification body (truncated)
- Widget UI mock (coming soon)

## Analytics

Optional `votd_view` on Today open.
