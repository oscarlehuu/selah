# Selah bundled data

Canonical JSON and keyword lists for the iOS app. Not duplicated in `docs/`.

## Reading plans (365 days per theme)

| Path | Description |
|------|-------------|
| `reading-plans/index.json` | Theme index |
| `reading-plans/peace.json` | 365 days |
| `reading-plans/consistency.json` | 365 days |
| `reading-plans/freedom.json` | 365 days |
| `reading-plans/scripture.json` | 365 days |

Regenerate: `python3 scripts/data/generate-reading-plans.py`

## Bible SQLite

Fetched to `assets/bible/kjv.sqlite` (~4.5 MB). Bundled via XcodeGen.

```bash
./scripts/bible/fetch-kjv-sqlite.sh
```

## Verse of the day

`verse-of-the-day.json` — 366 KJV references. Regenerate: `python3 scripts/data/generate-verse-of-the-day.py`

## Crisis keywords

`crisis-keywords-en.txt` — on-device Talk input scan list.

See `docs/bible-data-sources.md`.
