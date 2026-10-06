#!/usr/bin/env python3
"""Require complete English coverage for the three finished narrative packs."""

from __future__ import annotations

import json
import re
from pathlib import Path
from collection_io import load_collection
from staff_bundles import load_staff_bundles

ROOT = Path(__file__).resolve().parents[1]
ENGLISH = json.loads((ROOT / "data/localization/en.json").read_text(encoding="utf-8"))["strings"]
TARGETS = {
    "character_events": ROOT / "data/events/character_events/index.json",
    "micro_events": ROOT / "data/events/micro_events.json",
    "special_event_steps": ROOT / "data/events/special_event_steps/index.json",
}
FIELDS = {
    "name", "family_name", "given_name", "professional_name", "title", "subtitle",
    "description", "label", "text", "prompt", "response", "teaser", "caption",
    "announcement", "location_label", "speaker_label", "specialty", "personality",
    "presenting_complaint", "diagnosis", "intake_notes", "result", "summary", "section",
    "correction",
}
HAN = re.compile(r"[\u3400-\u9fff]")
FORMAT = re.compile(r"%(?:0?\d+)?[sdif]")


def walk(value: object, path: str, rows: list[tuple[str, str]]) -> None:
    if isinstance(value, dict):
        for field, child in value.items():
            child_path = f"{path}.{field}"
            if field in FIELDS and isinstance(child, str) and child.strip():
                rows.append((child_path, child))
            walk(child, child_path, rows)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            identity = str(child.get("id", index)) if isinstance(child, dict) else str(index)
            walk(child, f"{path}.{identity}", rows)


def main() -> int:
    failures: list[str] = []
    checked = 0
    manifest = json.loads((ROOT / "data/manifest.json").read_text(encoding="utf-8"))
    staff_collections, _bundles = load_staff_bundles(ROOT / "data", manifest["staff_bundles"])
    for collection, path in TARGETS.items():
        rows: list[tuple[str, str]] = []
        authored = load_collection(path) + staff_collections.get(collection, [])
        walk(authored, f"collections.{collection}", rows)
        for key, source in rows:
            # Already-English authored labels such as "Lucky!" need no locale entry.
            if not HAN.search(source):
                continue
            checked += 1
            translated = ENGLISH.get(key, "")
            if not translated.strip():
                failures.append(f"missing: {key}")
            elif HAN.search(translated):
                failures.append(f"Chinese remains: {key}")
            elif FORMAT.findall(source) != FORMAT.findall(translated):
                failures.append(f"placeholder mismatch: {key}")
    if failures:
        print("\n".join(failures))
        print(f"NARRATIVE LOCALIZATION: {checked} checks; {len(failures)} failure(s)")
        return 1
    print(f"NARRATIVE LOCALIZATION: {checked} checks; 0 failure(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
