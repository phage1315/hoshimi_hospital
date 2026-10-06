#!/usr/bin/env python3
"""Verify every visible Chinese leaf in a patient bundle resolves in English."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HAN = re.compile(r"[\u3400-\u9fff]")


def walk(value: object, path: str, strings: dict[str, str], failures: list[str]) -> None:
    if isinstance(value, dict):
        for field, child in value.items():
            walk(child, f"{path}.{field}", strings, failures)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            identity = str(child.get("id", index)) if isinstance(child, dict) else str(index)
            walk(child, f"{path}.{identity}", strings, failures)
    elif isinstance(value, str) and HAN.search(value):
        translated = strings.get(path, value)
        if HAN.search(translated):
            failures.append(path)


def main() -> int:
    strings = json.loads((ROOT / "data/localization/en.json").read_text(encoding="utf-8"))["strings"]
    index = json.loads((ROOT / "data/patients/index.json").read_text(encoding="utf-8"))
    failures: list[str] = []
    checks = 0
    for relative in index:
        bundle = json.loads((ROOT / "data/patients" / relative).read_text(encoding="utf-8"))
        patient_id = str(bundle["patient"]["id"])
        before = len(failures)
        walk(bundle, f"patient_bundles.{patient_id}", strings, failures)
        checks += sum(
            1 for key in strings
            if key.startswith(f"patient_bundles.{patient_id}.")
        )
        if len(failures) != before:
            print(f"{patient_id}: {len(failures) - before} unresolved field(s)")
    print(f"PATIENT BUNDLE LOCALIZATION: {checks} English entries; {len(failures)} failure(s)")
    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
