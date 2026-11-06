#!/usr/bin/env python3
"""Audit the two fixed Lv1 events against their unchanged Chinese manuscripts."""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

from import_ren_narumi_lv1 import EVENTS, ROOT, SOURCE, TRANSLATIONS, LOCALIZATION, source_beats

SOURCE_SHA256 = {
    "ren_lv1_night_ward_1": "eb52f77ad217241f346c9e1627d16cee5f0f879fd110e9a764d0edf33967a306",
    "narumi_lv1_beyond_the_resume": "74915ee3c333579276b0078dc0511cb1570478d9f802c4f0ef6d609feaad1a4e",
}


def check(ok: bool, message: str) -> None:
    if not ok:
        raise AssertionError(message)


def main() -> None:
    translations = json.loads(TRANSLATIONS.read_text(encoding="utf-8"))
    english = json.loads(LOCALIZATION.read_text(encoding="utf-8"))["strings"]
    expected_counts = {"ren_lv1_night_ward_1": 243, "narumi_lv1_beyond_the_resume": 202}
    for spec in EVENTS:
        event_id = spec["id"]
        original = Path("/Users/ningye/Downloads") / spec["source"]
        copied = SOURCE / spec["source"]
        copied_digest = hashlib.sha256(copied.read_bytes()).hexdigest()
        check(copied_digest == SOURCE_SHA256[event_id], f"Archived original changed: {event_id}")
        if original.exists():
            check(hashlib.sha256(original.read_bytes()).hexdigest() == copied_digest, f"Attachment differs from archive: {event_id}")
        source = source_beats(spec)
        generated = json.loads((ROOT / spec["output"]).read_text(encoding="utf-8"))
        check(len(generated) == 1, f"Wrong event file shape: {event_id}")
        event = generated[0]
        nodes = event["nodes"]
        check(len(source) == len(nodes) == len(translations[event_id]) == expected_counts[event_id], f"Line count drift: {event_id}")
        check(event["category"] == "bond" and event["target_level"] == 1, f"Wrong rank settlement: {event_id}")
        check(event["actor_id"] == spec["actor"] and event["start"] == nodes[0]["id"], f"Wrong actor/start: {event_id}")
        relation = json.loads((ROOT / "data/staff" / spec["actor"] / "relationship.json").read_text(encoding="utf-8"))
        slot = next(item for item in relation["rank_slots"] if item["target_level"] == 1)
        check(slot["event_id"] == event_id and slot["content_status"] == "authored", f"Rank slot missing: {event_id}")
        bundle = json.loads((ROOT / "data/staff" / spec["actor"] / "bundle.json").read_text(encoding="utf-8"))
        check("lv1_events.json" in bundle["additional_character_event_files"], f"Bundle missing: {event_id}")
        profile = json.loads((ROOT / "data/staff" / spec["actor"] / "profile.json").read_text(encoding="utf-8"))
        portraits = profile["visuals"]["portraits"]
        backgrounds = {entry["id"]: entry["path"] for entry in json.loads((ROOT / "data/backgrounds.json").read_text(encoding="utf-8"))}
        prefix = f"collections.character_events.{event_id}"
        for field in ("title", "teaser", "gallery.caption"):
            check(bool(english.get(f"{prefix}.{field}")), f"Missing English {field}: {event_id}")
        for i, (raw, node, translated) in enumerate(zip(source, nodes, translations[event_id])):
            node_id = node["id"]
            for key in ("id", "speaker", "actor_id", "speaker_label", "text", "background_id", "outfit", "hide_portrait"):
                check(node[key] == raw[key], f"Source mismatch {event_id}:{node_id}:{key}")
            check(len(node["choices"]) == 1, f"Branch added {event_id}:{node_id}")
            choice = node["choices"][0]
            check(choice["next"] == ("@end" if i + 1 == len(nodes) else nodes[i + 1]["id"]), f"Wrong order {event_id}:{node_id}")
            check(choice["effects"] == {"affection": 0, "familiarity": 0} and not choice["flags"], f"Unexpected reward {event_id}:{node_id}")
            stem = f"{prefix}.nodes.{node_id}"
            check(english.get(stem + ".text") == translated, f"English mismatch {event_id}:{node_id}")
            check(bool(english.get(stem + ".speaker_label")), f"English speaker missing {event_id}:{node_id}")
            check(english.get(stem + f".choices.{choice['id']}.label") == ("Finish" if choice["next"] == "@end" else "Continue"), f"English choice missing {event_id}:{node_id}")
            check(not re.search(r"[\u3400-\u9fff]", translated), f"Chinese fallback {event_id}:{node_id}")
            check((ROOT / backgrounds[node["background_id"]]).is_file(), f"Background missing {event_id}:{node_id}")
            if not node["hide_portrait"]:
                portrait = portraits.get(node["outfit"] + "/" + node["expression"])
                check(portrait is not None and (ROOT / portrait).is_file(), f"Portrait missing {event_id}:{node_id}")
        print(f"{event_id}: {len(nodes)} original Chinese lines, speakers, order, EN entries, choices and assets OK")


if __name__ == "__main__":
    main()
