#!/usr/bin/env python3
"""Strict source/localization/asset audit for Narumi and Ren's shared Lv3."""
from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import import_narumi_ren_shared_lv3 as imp

failures: list[str] = []


def require(ok: bool, message: str) -> None:
    if not ok:
        failures.append(message)


expected = imp.parse_beats()
events = json.loads(imp.OUTPUT.read_text(encoding="utf-8"))
require(len(events) == 1, "shared Lv3 output must contain exactly one event")
event = events[0] if events else {}
actual = event.get("nodes", [])
require(len(expected) == 478, f"canonical parser page count drift: {len(expected)}")
require(len(actual) == len(expected), f"runtime page count drift: {len(actual)}/{len(expected)}")

for index, source in enumerate(expected):
    if index >= len(actual):
        break
    node = actual[index]
    for field in ["id", "speaker", "actor_id", "speaker_label", "text", "background_id", "hide_portrait", "choices"]:
        require(node.get(field) == source.get(field), f"{source['id']} source drift in {field}")
    require("**" not in str(node.get("text", "")), f"{source['id']} leaked Markdown emphasis")
    require(not (node.get("speaker") == "narrator" and node.get("event_portraits")), f"{source['id']} narrator borrowed a portrait")

by_id = {str(node.get("id", "")): node for node in actual}
reachable: set[str] = set()
pending = [str(event.get("start", ""))]
while pending:
    node_id = pending.pop()
    if node_id in reachable or node_id == "@end":
        continue
    reachable.add(node_id)
    node = by_id.get(node_id)
    if not node:
        failures.append(f"unresolved node target {node_id}")
        continue
    pending.extend(str(choice.get("next", "")) for choice in node.get("choices", []))
require(reachable == set(by_id), f"unreachable nodes: {sorted(set(by_id) - reachable)}")
require(sum(len(node.get("choices", [])) == 2 for node in actual) == 3, "expected exactly three authored choices")
require(sum(any(choice.get("next") == "@end" for choice in node.get("choices", [])) for node in actual) == 1, "expected exactly one ending")
require(len({node.get("background_id") for node in actual}) == 7, "expected seven runtime backgrounds across fifteen scenes")

require(event.get("relationship_actor_ids") == ["doc_aoi", "nurse_haru"], "shared relationship participants drift")
require(event.get("completion_story_flags") == ["narumi_ren_shared_lv3_complete", "hirasaka_investigation_ended"], "completion flags drift")
require(event.get("completion_day_offset") == 7, "seven-day settlement drift")
require(event.get("completion_absolute_clock") == 1019, "persistent settlement must remain inside the 16:59 safe work-ledger boundary")
require(event.get("completion_display_clock") == 1080, "Scene 15 presentation must close at 18:00")
conditions = event.get("conditions", {})
require(conditions.get("required_events") == ["narumi_ren_shared_lv2_sign_here"], "Lv2 prerequisite drift")
require(conditions.get("days_after_required_events") == 3, "relationship cooldown drift")
require(conditions.get("min_familiarity") == 40, "familiarity gate drift")
require(conditions.get("special_requirements") == [{"type": "player_attribute", "attribute": "skill", "minimum": 60}], "skill gate drift")
require(event.get("gallery", {}).get("show_on_complete") is False and not event.get("gallery", {}).get("path"), "event must not invent a CG")
require(not any(key in event for key in ["runner", "surgery", "rewards", "patient_id"]), "event leaked into a clinical runner")

expected_yayoi_assets = {
    value for (actor_id, _), value in imp.PORTRAITS.items() if actor_id == "kunizuka_yayoi"
}
require(len(expected_yayoi_assets) == 8, "Yayoi SFW portrait checklist must contain eight assets")
for asset in expected_yayoi_assets:
    require((ROOT / asset).is_file(), f"missing Yayoi asset: {asset}")
for node in actual:
    for portrait in node.get("event_portraits", []):
        path = str(portrait.get("path", ""))
        require(bool(path) and (ROOT / path).is_file(), f"{node.get('id')} missing portrait path: {path}")
    if node.get("actor_id") == "kunizuka_yayoi" and not node.get("hide_portrait"):
        expression = str(node.get("expression", ""))
        expected_path = imp.PORTRAITS.get(("kunizuka_yayoi", expression), "")
        mapped_path = str(node.get("event_portraits", [{}])[0].get("path", ""))
        require(bool(expected_path) and mapped_path == expected_path,
                f"{node.get('id')} Yayoi expression/path mismatch: {expression} -> {mapped_path}")

strings = json.loads(imp.LOCALIZATION.read_text(encoding="utf-8"))["strings"]
prefix = f"collections.character_events.{imp.EVENT_ID}"
cjk = re.compile(r"[\u3400-\u9fff]")
for node in actual:
    stem = f"{prefix}.nodes.{node['id']}"
    en_text = str(strings.get(stem + ".text", ""))
    en_speaker = str(strings.get(stem + ".speaker_label", ""))
    require(bool(en_text) and not cjk.search(en_text), f"{node['id']} missing/Chinese English text")
    require(bool(en_speaker) and not cjk.search(en_speaker), f"{node['id']} missing/Chinese English speaker")
    for choice in node.get("choices", []):
        label = str(strings.get(f"{stem}.choices.{choice['id']}.label", ""))
        require(bool(label) and not cjk.search(label), f"{node['id']} choice missing/Chinese English label")
for suffix in ["title", "teaser", "gallery.caption"]:
    value = str(strings.get(f"{prefix}.{suffix}", ""))
    require(bool(value) and not cjk.search(value), f"English {suffix} missing/Chinese")

for actor_id in ["doc_aoi", "nurse_haru"]:
    relation = json.loads((ROOT / f"data/staff/{actor_id}/relationship.json").read_text(encoding="utf-8"))
    slots = [slot for slot in relation.get("rank_slots", []) if slot.get("target_level") == 3]
    require(len(slots) == 1 and slots[0].get("event_id") == imp.EVENT_ID and slots[0].get("content_status") == "authored", f"{actor_id} Lv3 slot drift")
    require(slots and slots[0].get("special_requirements") == [{"type": "player_attribute", "attribute": "skill", "minimum": 60}], f"{actor_id} Lv3 gate drift")
bundle = json.loads((ROOT / "data/staff/doc_aoi/bundle.json").read_text(encoding="utf-8"))
require("shared_lv3_events.json" in bundle.get("additional_character_event_files", []), "shared event file not registered")

archive_sha = hashlib.sha256(imp.SOURCE.read_bytes()).hexdigest()
require(archive_sha == "9234a6b35aeebaa73bb62bf43aaab2417c9c68bc58a20ae3476cfccc2e9246b2", "archived V2.3 manuscript SHA drift")

print(f"NARUMI REN SHARED LV3 SOURCE AUDIT: {len(actual)} bilingual pages; {len(failures)} failures")
for failure in failures:
    print(failure)
raise SystemExit(bool(failures))
