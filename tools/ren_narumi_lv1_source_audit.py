#!/usr/bin/env python3
"""Audit the revised Ren V2.2 and Narumi V2.1 events against their manuscripts."""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

from import_ren_narumi_lv1 import (
    EVENTS,
    LEGACY_TRANSLATIONS,
    LOCALIZATION,
    REVISED_TRANSLATIONS,
    ROOT,
    SOURCE,
    source_beats,
)

SOURCE_SHA256 = {
    "ren_lv1_night_ward_1": "f9d4ecf5de4ffd15b9ee8a81c559499583b1516b3eb329df41d84ea4c0c234ec",
    "narumi_lv1_beyond_the_resume": "10c39175adc205e1570d11ff2fc3b4fe9ddff5094f1ac185314cbc6d1f97ee68",
}
ATTACHMENT_ROOT = Path("/Users/ningye/Downloads/HOSHIMI_NARUMI_V2_1_REN_V2_2_LV1_REVISED")


def check(ok: bool, message: str) -> None:
    if not ok:
        raise AssertionError(message)


def english_lines(spec: dict, beats: list[dict]) -> list[str]:
    legacy = json.loads(LEGACY_TRANSLATIONS.read_text(encoding="utf-8")).get(spec["id"], {})
    revised = json.loads(REVISED_TRANSLATIONS.read_text(encoding="utf-8")).get(spec["id"], {})
    return [revised.get(beat["text"], legacy.get(beat["text"], "")) for beat in beats]


def reachable_nodes(event: dict) -> set[str]:
    by_id = {node["id"]: node for node in event["nodes"]}
    pending = [event["start"]]
    reached: set[str] = set()
    while pending:
        node_id = pending.pop()
        check(node_id in by_id, f"Broken node link: {event['id']}:{node_id}")
        if node_id in reached:
            continue
        reached.add(node_id)
        node = by_id[node_id]
        check(node["choices"], f"Dead-end node: {event['id']}:{node_id}")
        for choice in node["choices"]:
            target = choice["next"]
            if target != "@end":
                pending.append(target)
    return reached


def audit_mixed_action_dialogue(spec: dict, beats: list[dict]) -> None:
    lines = (SOURCE / spec["source"]).read_text(encoding="utf-8").splitlines()
    mixed = []
    for raw in lines:
        line = raw.strip()
        match = re.fullmatch(r"([^：]+)：(「.*」)", line)
        if not match or match.group(1) in spec["speaker_ids"]:
            continue
        speaker = next((name for name in spec["speaker_ids"] if match.group(1).startswith(name)), "")
        if speaker:
            mixed.append((line, match.group(1) + "：", match.group(2), speaker))
    for original, action, dialogue, speaker in mixed:
        matches = [
            index for index in range(len(beats) - 1)
            if beats[index]["text"] == action
            and beats[index]["speaker_label"] == "旁白"
            and beats[index + 1]["text"] == dialogue
            and beats[index + 1]["speaker_label"] == speaker
        ]
        check(len(matches) == 1, f"Mixed action/dialogue split drift: {spec['id']}:{original}")
        check(action + dialogue == original, f"Mixed action/dialogue character loss: {spec['id']}:{original}")


def main() -> None:
    english = json.loads(LOCALIZATION.read_text(encoding="utf-8"))["strings"]
    expected_counts = {"ren_lv1_night_ward_1": 220, "narumi_lv1_beyond_the_resume": 198}
    for spec in EVENTS:
        event_id = spec["id"]
        original = ATTACHMENT_ROOT / spec["source"]
        copied = SOURCE / spec["source"]
        copied_digest = hashlib.sha256(copied.read_bytes()).hexdigest()
        check(copied_digest == SOURCE_SHA256[event_id], f"Archived original changed: {event_id}")
        if original.exists():
            check(hashlib.sha256(original.read_bytes()).hexdigest() == copied_digest, f"Attachment differs from archive: {event_id}")
        source = source_beats(spec)
        translated = english_lines(spec, source)
        generated = json.loads((ROOT / spec["output"]).read_text(encoding="utf-8"))
        check(len(generated) == 1, f"Wrong event file shape: {event_id}")
        event = generated[0]
        nodes = event["nodes"]
        check(len(source) == len(nodes) == len(translated) == expected_counts[event_id], f"Line count drift: {event_id}")
        check(event["category"] == "bond" and event["target_level"] == 1, f"Wrong rank settlement: {event_id}")
        check(event["actor_id"] == spec["actor"] and event["start"] == nodes[0]["id"], f"Wrong actor/start: {event_id}")
        check(reachable_nodes(event) == {node["id"] for node in nodes}, f"Unreachable authored node: {event_id}")
        check(sum(len(node["choices"]) == 2 for node in nodes) == 2, f"Authored A/B choice count drift: {event_id}")
        check(sum(choice["next"] == "@end" for node in nodes for choice in node["choices"]) == 1, f"Ending count drift: {event_id}")

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

        choice_en_index = 0
        for raw, node, translated_line in zip(source, nodes, translated):
            node_id = node["id"]
            for key in ("id", "speaker", "actor_id", "speaker_label", "text", "background_id", "outfit", "hide_portrait"):
                check(node[key] == raw[key], f"Source mismatch {event_id}:{node_id}:{key}")
            check(node["choices"] == raw["choices"], f"Authored branch wiring mismatch {event_id}:{node_id}")
            check(len(node["choices"]) in (1, 2), f"Invalid choice count {event_id}:{node_id}")
            stem = f"{prefix}.nodes.{node_id}"
            check(english.get(stem + ".text") == translated_line, f"English mismatch {event_id}:{node_id}")
            check(bool(english.get(stem + ".speaker_label")), f"English speaker missing {event_id}:{node_id}")
            check(bool(translated_line) and not re.search(r"[\u3400-\u9fff]", translated_line), f"Chinese fallback {event_id}:{node_id}")
            for choice in node["choices"]:
                check(choice["effects"] == {"affection": 0, "familiarity": 0} and not choice["flags"], f"Unexpected reward {event_id}:{node_id}")
                if len(node["choices"]) == 2:
                    expected_label = spec["choice_en"][choice_en_index]
                    choice_en_index += 1
                else:
                    expected_label = "Finish" if choice["next"] == "@end" else "Continue"
                check(english.get(stem + f".choices.{choice['id']}.label") == expected_label, f"English choice missing {event_id}:{node_id}:{choice['id']}")
            check((ROOT / backgrounds[node["background_id"]]).is_file(), f"Background missing {event_id}:{node_id}")
            if not node["hide_portrait"]:
                portrait = portraits.get(node["outfit"] + "/" + node["expression"])
                check(portrait is not None and (ROOT / portrait).is_file(), f"Portrait missing {event_id}:{node_id}")
        check(choice_en_index == 4, f"English A/B choice count drift: {event_id}")
        audit_mixed_action_dialogue(spec, source)
        print(f"{event_id}: {len(nodes)} source-faithful nodes, two A/B choices, complete EN and assets OK")


if __name__ == "__main__":
    main()
