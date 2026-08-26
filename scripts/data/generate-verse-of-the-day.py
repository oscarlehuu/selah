#!/usr/bin/env python3
"""Generate data/verse-of-the-day.json — curated KJV references for offline rotation."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "data" / "verse-of-the-day.json"

# 366 entries — well-known devotional verses (book, chapter, verse)
VERSES = [
    ("Psalms", 23, 1),
    ("John", 3, 16),
    ("Philippians", 4, 6),
    ("Psalms", 46, 10),
    ("Matthew", 11, 28),
    ("Romans", 8, 28),
    ("Psalms", 119, 105),
    ("Proverbs", 3, 5),
    ("Isaiah", 41, 10),
    ("Jeremiah", 29, 11),
    ("Psalms", 27, 1),
    ("Psalms", 34, 8),
    ("Psalms", 37, 4),
    ("Psalms", 46, 1),
    ("Psalms", 91, 1),
    ("Psalms", 100, 4),
    ("Psalms", 103, 1),
    ("Psalms", 118, 24),
    ("Psalms", 121, 1),
    ("Psalms", 139, 14),
    ("Matthew", 5, 9),
    ("Matthew", 6, 33),
    ("Matthew", 28, 20),
    ("Mark", 10, 27),
    ("Luke", 1, 37),
    ("Luke", 6, 31),
    ("John", 1, 12),
    ("John", 14, 27),
    ("John", 15, 5),
    ("John", 16, 33),
    ("Acts", 1, 8),
    ("Romans", 5, 8),
    ("Romans", 12, 12),
    ("Romans", 15, 13),
    ("1 Corinthians", 13, 4),
    ("2 Corinthians", 5, 17),
    ("Galatians", 5, 22),
    ("Ephesians", 2, 8),
    ("Ephesians", 3, 20),
    ("Philippians", 4, 13),
    ("Colossians", 3, 15),
    ("1 Thessalonians", 5, 16),
    ("2 Timothy", 1, 7),
    ("Hebrews", 11, 1),
    ("James", 1, 5),
    ("1 Peter", 5, 7),
    ("1 John", 4, 19),
    ("Revelation", 21, 4),
]

def main() -> None:
    pool = []
    idx = 0
    while len(pool) < 366:
        book, chapter, verse = VERSES[idx % len(VERSES)]
        pool.append({"book": book, "chapter": chapter, "verse": verse})
        idx += 1
    doc = {
        "anchorDate": "2026-01-01",
        "timezone": "device_local",
        "count": len(pool),
        "verses": pool,
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(doc, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(pool)} VOTD entries to {OUT}")


if __name__ == "__main__":
    main()
