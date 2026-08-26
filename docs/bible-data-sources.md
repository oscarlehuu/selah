# Bible text — open sources (research 2026-08-24)

> **Locked for v1 US ship:** **KJV** from **`midvash/bible-data`** (SQLite). Protestant 66-book canon.

## Recommendation

| Priority | Source | What | License | Why Selah |
|----------|--------|------|---------|-----------|
| **1 (use)** | [midvash/bible-data](https://github.com/midvash/bible-data) | `en/kjv/kjv.sqlite` — 31,102 verses, indexed | Repo **MIT**; KJV text **public domain** | Ready SQLite, clear schema, KJV 1769, used in production apps (midvash iOS) |
| 2 | [scrollmapper/bible_databases](https://github.com/scrollmapper/bible_databases) | KJV + 140 translations, SQLite/JSON | Repo **MIT**; check per-translation `license` column | Huge catalog; schema changed on 2025 branch — more integration work |
| 3 | [VerseWell/BibleKit-swift](https://github.com/VerseWell/BibleKit-Swift) | Swift package + `bible.db` | **Apache 2.0** | Good search/API layer; ship your own DB (WEB example included; swap for KJV if schema matches) |
| Avoid as dependency | [vanities/swiftbible](https://github.com/vanities/swiftbible) | Full competitor app | **GPLv3** | Commercial Selah cannot embed GPLv3 app code; use only as UX reference |

## KJV legal (US / AU / UK v1)

- KJV text (1769 Oxford standard) is **public domain** in the US and commonly treated as PD in UK/AU for the text itself.
- **Crown copyright** applies to UK **printing** of KJV in some contexts; digital app use of PD text is standard for US Protestant apps (YouVersion, etc. ship KJV).
- **Not v1:** NIV, ESV, NASB — require publisher licenses.

## midvash schema (integration)

- Metadata: `versions/en/kjv/metadata.json`
- SQLite: download `versions/en/kjv/kjv.sqlite` (or raw GitHub URL in README)
- Schema doc: `SCHEMA.md` in repo — books, chapters, verses tables
- **iOS:** bundle `selah-bible-kjv.sqlite` in app; query via SQLite.swift or GRDB; no network for Read tab

## Alternatives if schema changes

- Generate SQLite from USFM via [@helloao/bible](https://github.com/HelloAOLab/bible) (MIT tooling) from [ebible.org](https://ebible.org) USFM (WEB, ASV PD)
- **WEB / ASV** as fallback translation in Settings v2 if you want zero attribution friction everywhere

## Not chosen v1

| Item | Reason |
|------|--------|
| Live API only | Offline Read is product requirement |
| Multi-translation | Settings shows KJV only until licenses secured |

## Next implementation step

1. Vendor `kjv.sqlite`: `./scripts/bible/fetch-kjv-sqlite.sh` → `assets/bible/` (bundled in `Selah/project.yml`)
2. Swift `BibleRepository` — getChapter(book, chapter), search (v2)
3. Attribution line in Read footer if metadata requires (KJV: optional/null in midvash)
