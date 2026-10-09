#!/usr/bin/env python3
"""Require real English translations for every isolated staff dialogue surface."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

from staff_bundles import load_staff_bundles

ROOT = Path(__file__).resolve().parents[1]
HAN = re.compile(r"[\u3400-\u9fff]")
FORMAT_FIELD = re.compile(r"\{[A-Za-z0-9_]+\}|%(?:0?\d+)?[sdif]")


def walk(value: object, path: str):
    if isinstance(value, dict):
        for field, child in value.items():
            yield from walk(child, f"{path}.{field}")
    elif isinstance(value, list):
        for index, child in enumerate(value):
            identity = str(child.get("id", index)) if isinstance(child, dict) else str(index)
            yield from walk(child, f"{path}.{identity}")
    elif isinstance(value, str):
        yield path, value


def is_staff_dialogue_key(key: str) -> bool:
    return (
        ".team_dialogue." in key
        or ".procedure_group_team_dialogue." in key
        or ".personal_nurse.dialogue." in key
        or ".preop_graphic_wrapper." in key
        or ".crisis_callouts." in key
        or (key.startswith("collections.time_events.") and ".responses." in key)
    )


def main() -> int:
    manifest = json.loads((ROOT / "data/manifest.json").read_text(encoding="utf-8"))
    collections, _ = load_staff_bundles(ROOT / "data", manifest["staff_bundles"])
    english = json.loads((ROOT / "data/localization/en.json").read_text(encoding="utf-8"))["strings"]
    failures: list[str] = []
    checked = 0

    for collection, rows in collections.items():
        for key, source in walk(rows, f"collections.{collection}"):
            if not HAN.search(source) or not is_staff_dialogue_key(key):
                continue
            checked += 1
            translated = english.get(key)
            if not isinstance(translated, str) or not translated.strip():
                failures.append(f"missing: {key}")
                continue
            if HAN.search(translated):
                failures.append(f"Chinese remains: {key} = {translated}")
            if FORMAT_FIELD.findall(source) != FORMAT_FIELD.findall(translated):
                failures.append(
                    f"placeholder mismatch: {key}: "
                    f"{FORMAT_FIELD.findall(source)} != {FORMAT_FIELD.findall(translated)}"
                )

    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    print(f"STAFF LOCALIZATION TEST: {checked} isolated staff dialogue lines translated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
