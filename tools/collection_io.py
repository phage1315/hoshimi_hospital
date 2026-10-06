"""Read a content collection stored as one array or an indexed set of shards."""

from __future__ import annotations

import json
from pathlib import Path


def load_collection(path: Path) -> list[object]:
    source = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(source, list):
        return source
    if not isinstance(source, dict) or not isinstance(source.get("files"), list):
        raise ValueError(f"Invalid collection or collection index: {path}")
    rows: list[object] = []
    for relative in source["files"]:
        part_path = path.parent / str(relative)
        part = json.loads(part_path.read_text(encoding="utf-8"))
        if not isinstance(part, list):
            raise ValueError(f"Collection shard must be an array: {part_path}")
        rows.extend(part)
    return rows
