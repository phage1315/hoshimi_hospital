#!/usr/bin/env python3
"""Audit every ordinary VN text through the runtime dialogue-page budget."""

from __future__ import annotations

import json
import math
import unicodedata
from pathlib import Path
from collection_io import load_collection

ROOT = Path(__file__).resolve().parents[1]
COLUMNS = 44.0
LINES = 3
TERMINATORS = set("。！？；!?;")
QUOTE_PAIRS = {"「": "」", "『": "』", "“": "”"}


def visual_units(text: str) -> float:
    return sum(1.0 if unicodedata.east_asian_width(char) in "WFA" else 0.55 for char in text)


def estimated_lines(text: str) -> int:
    return max(1, math.ceil(visual_units(text) / COLUMNS))


def sentence_chunks(text: str) -> list[str]:
    chunks: list[str] = []
    current = ""
    for char in text:
        current += char
        if char in TERMINATORS:
            chunks.append(current.strip())
            current = ""
    if current.strip():
        chunks.append(current.strip())
    return chunks


def beat_chunks(text: str) -> list[str]:
    chunks: list[str] = []
    current = ""
    closing_quote = ""
    for char in text:
        if not closing_quote and char in QUOTE_PAIRS:
            prefix = current.strip()
            keep_player_prefix = (
                prefix.startswith(("坂口", "Sakaguchi"))
                and prefix.endswith(("：", ":"))
            )
            if prefix and not keep_player_prefix:
                chunks.append(current.strip())
                current = ""
            current += char
            closing_quote = QUOTE_PAIRS[char]
            continue
        current += char
        if closing_quote and char == closing_quote:
            chunks.append(current.strip())
            current = ""
            closing_quote = ""
    if current.strip():
        chunks.append(current.strip())
    return chunks


def hard_wrap(text: str) -> list[str]:
    pages: list[str] = []
    current = ""
    units = 0.0
    maximum = COLUMNS * LINES
    for char in text:
        char_units = 1.0 if unicodedata.east_asian_width(char) in "WFA" else 0.55
        if current and units + char_units > maximum:
            pages.append(current.strip())
            current = ""
            units = 0.0
        current += char
        units += char_units
    if current.strip():
        pages.append(current.strip())
    return pages


def dialogue_pages(text: str, allow_scroll: bool = False) -> list[str]:
    if allow_scroll:
        return [text]
    pages: list[str] = []
    authored_lines = [line.strip() for line in text.replace("\r", "").split("\n") if line.strip()]
    line_index = 0
    while line_index < len(authored_lines):
        authored_line = authored_lines[line_index]
        player_lead_in = (
            authored_line.startswith(("坂口", "Sakaguchi"))
            and authored_line.endswith(("：", ":"))
        )
        if player_lead_in and line_index + 1 < len(authored_lines):
            following_line = authored_lines[line_index + 1]
            if following_line.startswith(("「", "『", "“", '"')):
                authored_line += following_line
                line_index += 1
        for line in beat_chunks(authored_line):
            if not line:
                continue
            if estimated_lines(line) <= LINES:
                pages.append(line)
                continue
            current = ""
            for sentence in sentence_chunks(line):
                if estimated_lines(sentence) > LINES:
                    if current:
                        pages.append(current)
                        current = ""
                    pages.extend(hard_wrap(sentence))
                elif not current:
                    current = sentence
                elif estimated_lines(current + sentence) <= LINES:
                    current += sentence
                else:
                    pages.append(current)
                    current = sentence
            if current:
                pages.append(current)
        line_index += 1
    return pages or [text]


def authored_nodes() -> list[tuple[str, dict]]:
    rows: list[tuple[str, dict]] = []
    introduction = json.loads((ROOT / "data/dialogue/introduction.json").read_text(encoding="utf-8"))
    rows.extend((f"introduction/{node['id']}", node) for node in introduction["nodes"])
    for relative, collection, skip_presentations in (
        ("data/events/character_events/index.json", "character_events", False),
        ("data/events/special_event_steps/index.json", "special_event_steps", True),
    ):
        for record in load_collection(ROOT / relative):
            for node in record["nodes"]:
                if skip_presentations and node.get("presentation", "narrative") != "narrative":
                    continue
                rows.append((f"{collection}/{record['id']}/{node['id']}", node))
    for event in json.loads((ROOT / "data/events/micro_events.json").read_text(encoding="utf-8")):
        for section in ("opening_lines", "closing_lines"):
            for index, node in enumerate(event.get(section, [])):
                rows.append((f"micro_events/{event['id']}/{section}/{index}", node))
    return rows


def main() -> int:
    failures: list[str] = []
    node_count = 0
    page_count = 0
    paginated_count = 0
    exception_count = 0
    for source, node in authored_nodes():
        text = node.get("text")
        if not isinstance(text, str) or not text.strip():
            continue
        node_count += 1
        allow_scroll = bool(node.get("allow_dialogue_scroll", False))
        pages = dialogue_pages(text, allow_scroll)
        page_count += len(pages)
        paginated_count += len(pages) > 1
        exception_count += allow_scroll
        if allow_scroll:
            continue
        for index, page in enumerate(pages, 1):
            if "\n" in page or estimated_lines(page) > LINES:
                failures.append(f"{source} page {index}: exceeds normal dialogue frame")
    if failures:
        print("\n".join(failures))
    print(
        f"DIALOGUE LAYOUT: {node_count} authored nodes -> {page_count} click points; "
        f"{paginated_count} nodes split; {exception_count} scroll exceptions; {len(failures)} failure(s)"
    )
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
