#!/usr/bin/env python3
"""Strict source/localization/asset audit for Narumi and Ren's shared Lv2."""
from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import import_narumi_ren_shared_lv2 as imp

failures: list[str] = []


def require(ok: bool, message: str) -> None:
    if not ok:
        failures.append(message)


expected = imp.parse_beats()
events = json.loads(imp.OUTPUT.read_text(encoding="utf-8"))
require(len(events) == 1, "shared Lv2 output must contain exactly one event")
event = events[0] if events else {}
actual = event.get("nodes", [])
require(len(expected) == 294, f"canonical parser page count drift: {len(expected)}")
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
require(sum(len(node.get("choices", [])) == 2 for node in actual) == 2, "expected exactly two authored choices")
require(sum(any(choice.get("next") == "@end" for choice in node.get("choices", [])) for node in actual) == 1, "expected exactly one ending")

require(event.get("relationship_actor_ids") == ["doc_aoi", "nurse_haru"], "shared relationship participants drift")
require(event.get("completion_story_flags") == ["narumi_ren_hirasaka_informed", "narumi_ren_shared_lv2_complete"], "completion flags drift")
require(event.get("completion_day_offset") == 1 and event.get("completion_absolute_clock") == 540, "cross-day safe-boundary settlement drift")
require(event.get("time_start") == 870 and event.get("time_end") == 900, "natural lobby trigger window must begin at 14:30")
require(event.get("gallery", {}).get("show_on_complete") is True and event.get("gallery", {}).get("path") == imp.ENDING_CG_PATH,
        "approved ending CG gallery registration drift")
for cg_path, expected_node_ids in imp.CG_WINDOWS.items():
    require((ROOT / cg_path).is_file(), f"missing approved CG: {cg_path}")
    mapped_cg_nodes = {str(node.get("id", "")) for node in actual if str(node.get("cg_path", "")) == cg_path}
    require(mapped_cg_nodes == expected_node_ids, f"approved CG window drift for {cg_path}: {sorted(mapped_cg_nodes)}")
    require(all(node.get("cg_fit") == "cover" for node in actual if str(node.get("id", "")) in expected_node_ids),
            f"approved CG must use cover fit: {cg_path}")
require(not any(str(node.get("cg_path", "")) for node in actual if 143 <= int(str(node.get("id", "nr2_000")).split("_")[-1]) <= 145),
        "scalpel handoff and tension buildup must remain clear before the contact CG")
require(not any(str(node.get("cg_path", "")) for node in actual if 150 <= int(str(node.get("id", "nr2_000")).split("_")[-1]) <= 175),
        "scalpel contact CG must clear immediately after Mika's confession")
require(not any(key in event for key in ["runner", "surgery", "rewards", "patient_id"]), "event leaked into a clinical runner")

expected_mika_portraits = {
    value for (actor_id, _), value in imp.PORTRAITS.items() if actor_id == "shimotsuki_mika"
}
for asset in expected_mika_portraits:
    require((ROOT / asset).is_file(), f"missing Mika asset: {asset}")
mapped_mika_portraits = {
    portrait.get("path") for node in actual if node.get("actor_id") == "shimotsuki_mika"
    for portrait in node.get("event_portraits", [])
}
require(mapped_mika_portraits == expected_mika_portraits,
        f"Mika expression portrait coverage drift: {sorted(expected_mika_portraits - mapped_mika_portraits)}")
for node in actual:
    if node.get("actor_id") != "shimotsuki_mika":
        continue
    expression = str(node.get("expression", ""))
    expected_path = imp.PORTRAITS.get(("shimotsuki_mika", expression), "")
    mapped_path = str(node.get("event_portraits", [{}])[0].get("path", ""))
    require(bool(expected_path) and mapped_path == expected_path,
            f"{node.get('id')} Mika expression/path mismatch: {expression} -> {mapped_path}")
require(sum(node.get("text") == "「成美医生。她已经说了。」" for node in actual) == 1, "Ren's locked closing line drift")

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
require(strings.get("ui.character_event.shared_rank_up") == "Both relationships rose to Lv.%s", "shared completion UI English missing")

for actor_id in ["doc_aoi", "nurse_haru"]:
    relation = json.loads((ROOT / f"data/staff/{actor_id}/relationship.json").read_text(encoding="utf-8"))
    slots = [slot for slot in relation.get("rank_slots", []) if slot.get("target_level") == 2]
    require(len(slots) == 1 and slots[0].get("event_id") == imp.EVENT_ID and slots[0].get("content_status") == "authored", f"{actor_id} Lv2 slot drift")
bundle = json.loads((ROOT / "data/staff/doc_aoi/bundle.json").read_text(encoding="utf-8"))
require("shared_lv2_events.json" in bundle.get("additional_character_event_files", []), "shared event file not registered")

archive_sha = hashlib.sha256(imp.SOURCE.read_bytes()).hexdigest()
require(archive_sha == "f9d9c270617cbf126e3f4c0aa078fe6d3b8f27f0795d5dae0510ee315c12717f", "archived V2.4 manuscript SHA drift")

print(f"NARUMI REN SHARED LV2 SOURCE AUDIT: {len(actual)} bilingual pages; {len(failures)} failures")
for failure in failures:
    print(failure)
raise SystemExit(bool(failures))
