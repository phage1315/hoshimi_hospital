#!/usr/bin/env python3
"""Import the authored awake-patient bark package without changing its prose."""

from __future__ import annotations

import json
from pathlib import Path


SOURCE = Path("/Users/ningye/Downloads/HOSHIMI_ORDINARY_POOL_AWAKE_SPECIAL_BARKS_V1_3_REVISED.json")
TARGET = Path("data/surgeries/awake_special_barks.json")


def main() -> None:
    package = json.loads(SOURCE.read_text(encoding="utf-8"))
    records = package.get("records", [])
    if not isinstance(records, list) or len(records) != 28:
        raise SystemExit("unexpected awake bark package: expected 28 records")
    ids = [record.get("id", "") for record in records]
    if len(set(ids)) != len(ids) or any(not record_id for record_id in ids):
        raise SystemExit("unexpected awake bark package: duplicate or missing record id")
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    TARGET.write_text(json.dumps(records, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"imported {len(records)} awake special barks to {TARGET}")


if __name__ == "__main__":
    main()
