#!/usr/bin/env python3
"""Compare all 51 approved paragraphs to their source and loaded staff bundles."""
import json
import re
from pathlib import Path
from staff_bundles import load_staff_bundles

ROOT = Path(__file__).resolve().parents[1]


def main():
    source = (ROOT / "docs/source/HOSHIMI_IDLE_CHAT_51_CHINESE_DRAFT_2026-10-13.md").read_text()
    manifest = json.loads((ROOT / "data/manifest.json").read_text())
    collections, _ = load_staff_bundles(ROOT / "data", manifest["staff_bundles"])
    fixture = json.loads((ROOT / "tools/fixtures/idle_chat_51.json").read_text())
    checks = 0
    actors = set()
    expected = {}
    for section in re.split(r"^## \d+\. 角色：", source, flags=re.M)[1:]:
        actor = re.search(r"技术ID：`([^`]+)`", section)[1]
        actors.add(actor)
        for part in re.split(r"^### 场合：", section, flags=re.M)[1:]:
            location = re.search(r"`([^`]+)`", part)[1]
            lines = re.findall(r"^\d+\. (.+)$", part, re.M)
            assert len(lines) == 3
            expected[f"{location}_chat_{actor}"] = (actor, location, lines)
    assert len(actors) == 10 and len(expected) == 17 and len(fixture) == 17
    for event_id, (actor, location, lines) in expected.items():
        matches = [r for r in collections["time_events"] if r["id"] == event_id]
        assert len(matches) == 1, event_id
        row = matches[0]
        assert row["actor_id"] == actor and row["location_id"] == location
        assert row["responses"] == lines, event_id + " changed wording, order or punctuation"
        assert row["minutes"] == 30 and row["repeatable"] is True and not row.get("effects")
        assert row == next(r for r in fixture if r["id"] == event_id)
        person = next(p for p in collections["staff"] if p["id"] == actor)
        assert location in person["presence"]["fixed_locations"] + person["presence"]["random_locations"]
        checks += 6
    print(f"IDLE CHAT SOURCE AUDIT: {checks} checks; 10 actors; 17 entries; 51 exact paragraphs; passed")


if __name__ == "__main__":
    main()
