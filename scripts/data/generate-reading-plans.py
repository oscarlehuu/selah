#!/usr/bin/env python3
"""Generate data/reading-plans/*.json — 4 themes × 365 days (52 weeks + day 365)."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "data" / "reading-plans"

DAYS_PER_YEAR = 365
WEEK_LABELS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

WEEK_TITLE_CYCLE = [
    "Be still",
    "Quiet the noise",
    "Surrender",
    "Deep rest",
    "Morning anchor",
    "Trust His path",
    "Cast your care",
    "Gentle strength",
    "Refuge",
    "Still waters",
    "Held by God",
    "Breath and pause",
    "Selah",
]


def psalms(nums: list[int], focus: str) -> list[tuple[str, int, str, int]]:
    return [("Psalms", n, focus, 4 if n < 50 else 5) for n in nums]


def chapters(book: str, nums: list[int], focus: str, minutes: int = 5) -> list[tuple[str, int, str, int]]:
    return [(book, n, focus, minutes) for n in nums]


def build_pool(entries: list[tuple[str, int, str, int]]) -> list[tuple[str, int, str, int]]:
    return entries


PEACE_POOL = build_pool(
    psalms([4, 8, 16, 19, 23, 27, 32, 34, 37, 46, 51, 55, 62, 91, 94, 100, 103, 121, 131], "Peace in His presence")
    + chapters("Matthew", [5, 6, 11, 14], "Rest with Jesus", 5)
    + chapters("John", [14, 15, 16], "Peace He gives", 5)
    + chapters("Philippians", [4], "Trade every worry", 5)
    + chapters("Isaiah", [26, 40, 41], "Strength renewed", 5)
    + chapters("Lamentations", [3], "Mercies new each morning", 5)
    + chapters("Romans", [8], "Spirit of life", 6)
    + chapters("2 Corinthians", [12], "Grace for weakness", 5)
    + chapters("Colossians", [3], "Peace that rules", 5)
    + chapters("Hebrews", [4], "Enter His rest", 5)
    + psalms([3, 18, 25, 30, 42, 56, 63, 86, 90, 116, 118, 145], "Quiet soul")
)

CONSISTENCY_POOL = build_pool(
    chapters("Mark", [1, 4, 9], "Follow daily", 5)
    + chapters("Luke", [5, 9, 18], "Keep showing up", 5)
    + chapters("Matthew", [6, 7, 25], "Faithful in small things", 5)
    + psalms([1, 19, 56, 63, 86, 90, 119], "Daily rhythm")
    + chapters("Joshua", [1], "Meditate day and night", 5)
    + chapters("Romans", [12], "Daily renewal", 5)
    + chapters("Colossians", [3], "Steady heart", 5)
    + chapters("Hebrews", [10, 12], "Hold fast", 5)
    + chapters("Galatians", [6], "Do not grow weary", 5)
    + chapters("1 Timothy", [4], "Train in godliness", 5)
    + chapters("James", [1], "Doers of the word", 5)
    + chapters("2 Timothy", [2], "Study to show", 5)
    + chapters("Proverbs", [3, 16], "Trust the path", 5)
    + chapters("Ecclesiastes", [3], "Time under heaven", 4)
    + chapters("Revelation", [2], "Hold what you have", 4)
    + psalms([25, 42, 56, 143], "Seek Him early")
)

FREEDOM_POOL = build_pool(
    psalms([32, 38, 40, 51, 69, 86, 103, 130], "Come honestly")
    + chapters("Romans", [3, 5, 6, 8], "Grace over guilt", 5)
    + chapters("John", [8], "Truth sets free", 5)
    + chapters("Isaiah", [1, 43], "Washed clean", 5)
    + chapters("Ephesians", [1, 2], "Forgiven richly", 5)
    + chapters("Micah", [7], "Pardon and delight", 4)
    + chapters("1 John", [1], "Walk in light", 4)
    + chapters("Colossians", [2], "Record wiped", 5)
    + chapters("Galatians", [5], "Called to freedom", 5)
    + chapters("Luke", [15], "Father runs", 5)
    + chapters("2 Corinthians", [5], "New creation", 5)
    + chapters("Zechariah", [3], "Robes of righteousness", 4)
    + chapters("Matthew", [9], "Be of good cheer", 5)
    + chapters("Hebrews", [8], "Sins remembered no more", 5)
    + psalms([25, 34, 51, 147], "Live forgiven")
)

SCRIPTURE_POOL = build_pool(
    chapters("John", [1, 3, 14, 15, 17, 20], "Know His story", 6)
    + psalms([8, 19, 22, 23, 46, 100, 110, 119, 139, 145], "Know God in Scripture")
    + chapters("Genesis", [1], "In the beginning", 5)
    + chapters("Isaiah", [53], "Suffering servant", 6)
    + chapters("Acts", [2], "Spirit poured out", 6)
    + chapters("Hebrews", [11], "Faith of ancients", 6)
    + chapters("Deuteronomy", [6], "Teach diligently", 5)
    + chapters("Romans", [1, 8, 12], "Power of the gospel", 5)
    + chapters("1 Corinthians", [13], "Love chapter", 5)
    + chapters("Matthew", [5, 28], "King's teaching", 6)
    + chapters("Ephesians", [2], "Saved by grace", 5)
    + chapters("Revelation", [21], "New creation", 5)
    + chapters("Luke", [24], "He is risen", 5)
    + psalms([33, 90], "Glory of God")
)

THEME_POOLS = {
    "peace": ("Peace", "peace", PEACE_POOL),
    "consistency": ("Consistency", "daily", CONSISTENCY_POOL),
    "freedom": ("Freedom", "free", FREEDOM_POOL),
    "scripture": ("Scripture", "know", SCRIPTURE_POOL),
}


def flatten_year(pool: list[tuple[str, int, str, int]]) -> list[tuple[str, int, str, int]]:
    days: list[tuple[str, int, str, int]] = []
    for i in range(DAYS_PER_YEAR):
        days.append(pool[i % len(pool)])
    return days


def to_weeks(flat_days: list[tuple[str, int, str, int]]) -> list[dict]:
    weeks_out: list[dict] = []
    for week_idx in range(52):
        week_num = week_idx + 1
        week_title = WEEK_TITLE_CYCLE[week_idx % len(WEEK_TITLE_CYCLE)]
        days_out = []
        for day_idx in range(7):
            global_idx = week_idx * 7 + day_idx
            book, chapter, focus, minutes = flat_days[global_idx]
            days_out.append(
                {
                    "dayIndex": day_idx + 1,
                    "globalDay": global_idx + 1,
                    "label": WEEK_LABELS[day_idx],
                    "book": book,
                    "chapter": chapter,
                    "focus": focus,
                    "minutes": minutes,
                    "reflectionPrompt": f"What is God showing you through {focus.lower()}?",
                }
            )
        weeks_out.append({"week": week_num, "weekTitle": week_title, "days": days_out})

    book, chapter, focus, minutes = flat_days[364]
    weeks_out.append(
        {
            "week": 53,
            "weekTitle": "Year closing",
            "days": [
                {
                    "dayIndex": 1,
                    "globalDay": 365,
                    "label": "Sun",
                    "book": book,
                    "chapter": chapter,
                    "focus": focus,
                    "minutes": minutes,
                    "reflectionPrompt": f"What is God showing you through {focus.lower()}?",
                }
            ],
        }
    )
    return weeks_out


def build_theme(theme_key: str, label: str, desire_key: str, pool: list) -> dict:
    flat = flatten_year(pool)
    weeks = to_weeks(flat)
    return {
        "theme": theme_key,
        "themeLabel": label,
        "desireKey": desire_key,
        "daysPerYear": DAYS_PER_YEAR,
        "weeks": weeks,
    }


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    index = {"themes": [], "daysPerTheme": DAYS_PER_YEAR, "totalDaysAllThemes": 0}
    for theme_key, (label, desire_key, pool) in THEME_POOLS.items():
        doc = build_theme(theme_key, label, desire_key, pool)
        path = OUT / f"{theme_key}.json"
        path.write_text(json.dumps(doc, indent=2) + "\n", encoding="utf-8")
        index["themes"].append(
            {
                "theme": theme_key,
                "desireKey": desire_key,
                "themeLabel": label,
                "file": f"{theme_key}.json",
                "weeks": len(doc["weeks"]),
                "days": DAYS_PER_YEAR,
            }
        )
        index["totalDaysAllThemes"] += DAYS_PER_YEAR
    (OUT / "index.json").write_text(json.dumps(index, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {DAYS_PER_YEAR} days × {len(THEME_POOLS)} themes to {OUT}")


if __name__ == "__main__":
    main()
