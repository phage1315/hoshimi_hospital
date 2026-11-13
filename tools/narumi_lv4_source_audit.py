#!/usr/bin/env python3
"""Strict source, bilingual Profile/Flow/Context, and registration audit for Narumi Lv4."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import import_narumi_lv4 as event_import
import import_narumi_h_profile as h_import

failures: list[str] = []


def require(ok: bool, message: str) -> None:
    if not ok:
        failures.append(message)


expected = event_import.parse_beats()
events = json.loads(event_import.OUTPUT.read_text(encoding="utf-8"))
require(len(events) == 1, "Lv4 output must contain exactly one event")
event = events[0] if events else {}
actual = event.get("nodes", [])
require(len(expected) == 148, f"canonical page count drift: {len(expected)}")
require(len(actual) == len(expected), f"runtime page count drift: {len(actual)}/{len(expected)}")
for index, source in enumerate(expected):
    if index >= len(actual):
        break
    node = actual[index]
    for field in ["id", "speaker", "actor_id", "speaker_label", "text", "background_id", "choices"]:
        require(node.get(field) == source.get(field), f"{source['id']} source drift in {field}")
    expected_hide_portrait = False if node.get("cg_path") else source.get("hide_portrait")
    require(node.get("hide_portrait") == expected_hide_portrait, f"{source['id']} visual mode drift in hide_portrait")
    require("**" not in str(node.get("text", "")), f"{source['id']} leaked Markdown markup")
    require(not (node.get("speaker") == "narrator" and node.get("event_portraits")), f"{source['id']} narrator borrowed a portrait")

by_id = {str(node.get("id", "")): node for node in actual}
reachable: set[str] = set()
pending = [str(event.get("start", ""))]
while pending:
    node_id = pending.pop()
    if node_id == "@end" or node_id in reachable:
        continue
    reachable.add(node_id)
    node = by_id.get(node_id)
    if node is None:
        failures.append(f"unresolved node target {node_id}")
        continue
    for choice in node.get("choices", []):
        pending.append(str(choice.get("next", "")))
        conditional = choice.get("next_if_relationship_level", {})
        if conditional:
            pending.append(str(conditional.get("next", "")))
require(reachable == set(by_id), f"unreachable pages: {sorted(set(by_id) - reachable)}")
require(sum(len(node.get("choices", [])) == 2 for node in actual) == 2, "expected exactly two authored choices")
conditionals = [
    choice["next_if_relationship_level"]
    for node in actual
    for choice in node.get("choices", [])
    if choice.get("next_if_relationship_level")
]
require(conditionals == [{"actor_id": "nurse_haru", "minimum": 4, "next": "nar4_033"}], f"Ren Lv4 conditional drift: {conditionals}")
require(event.get("completion_story_flags") == ["narumi_lv4_complete"], "completion flag drift")
require(event.get("completion_day_offset") == 1 and event.get("completion_absolute_clock") == 780, "Monday 13:00 settlement drift")
require(event.get("title") == "下班以后" and event.get("teaser") == "褪去白大褂后的成年人狩猎与真情", "title/teaser source drift")
conditions = event.get("conditions", {})
require(conditions.get("required_events") == ["narumi_ren_shared_lv3_settled_accounts"], "shared Lv3 prerequisite drift")
require(conditions.get("days_after_required_events") == 3, "cooldown drift")
require(conditions.get("min_familiarity") == 55, "familiarity gate drift")
gallery = event.get("gallery", {})
require(
    gallery.get("show_on_complete") is True and gallery.get("path") == event_import.CG_PATH,
    "approved Lv4 rooftop CG gallery registration drift",
)
cg_nodes = [node for node in actual if node.get("cg_path") == event_import.CG_PATH]
require(
    {node.get("id") for node in cg_nodes} == event_import.CG_NODE_IDS,
    "approved Lv4 rooftop CG node window drift",
)
require(all(node.get("cg_fit") == "cover" for node in cg_nodes), "approved Lv4 rooftop CG fit drift")
require((ROOT / event_import.CG_PATH).is_file(), "approved Lv4 rooftop CG asset missing")

strings = json.loads(event_import.LOCALIZATION.read_text(encoding="utf-8"))["strings"]
prefix = f"collections.character_events.{event_import.EVENT_ID}"
cjk = re.compile(r"[\u3400-\u9fff]")
for node in actual:
    stem = f"{prefix}.nodes.{node['id']}"
    for suffix in ["text", "speaker_label"]:
        value = str(strings.get(f"{stem}.{suffix}", ""))
        require(bool(value) and not cjk.search(value), f"{node['id']} missing/Chinese English {suffix}")
    for choice in node.get("choices", []):
        value = str(strings.get(f"{stem}.choices.{choice['id']}.label", ""))
        require(bool(value) and not cjk.search(value), f"{node['id']} choice missing/Chinese English label")
for suffix in ["title", "teaser", "gallery.caption"]:
    value = str(strings.get(f"{prefix}.{suffix}", ""))
    require(bool(value) and not cjk.search(value), f"English {suffix} missing/Chinese")

source_text = h_import.SOURCE.read_text(encoding="utf-8")
blocks = re.findall(r"\x60\x60\x60json\s*\n(.*?)\n\x60\x60\x60", source_text, flags=re.S)
require(len(blocks) == 2, "archived H manuscript must contain two JSON blocks")
if len(blocks) == 2:
    require(json.loads(blocks[0]) == json.loads(h_import.PROFILE.read_text(encoding="utf-8")), "Profile differs from supplied JSON")
    require(json.loads(blocks[1]) == json.loads(h_import.FLOW.read_text(encoding="utf-8")), "Flow differs from supplied JSON")

profile = json.loads(h_import.PROFILE.read_text(encoding="utf-8"))
flow = json.loads(h_import.FLOW.read_text(encoding="utf-8"))
context = json.loads(h_import.CONTEXT.read_text(encoding="utf-8"))
translation = json.loads(h_import.TRANSLATIONS.read_text(encoding="utf-8"))
bodymap = json.loads((ROOT / "data/h/doc_aoi/h_bodymap.json").read_text(encoding="utf-8"))
expected_pools = h_import.expected_translation_keys(profile)
require(context.get("content_status") == "ready", "Context must expose the completed Free H assets")
require(context.get("layout_status") == "final_hotspots_calibrated", "body-map calibration status drift")
require(bodymap.get("status") == "final", "body-map data must be final after calibration")
require(
    bodymap.get("image_width") == 1024 and bodymap.get("image_height") == 1536,
    "body-map dimensions drift",
)
require(set(bodymap.get("hotspots", {})) == {"lips", "cheeks", "neck", "breasts", "nipples", "navel", "torso_other", "genitals", "thighs"}, "body-map zone coverage drift")
for key, count in expected_pools.items():
    pool = translation.get("dialogue", {}).get(key, [])
    require(len(pool) == count and all(str(line).strip() and not cjk.search(str(line)) for line in pool), f"English pool invalid: {key}")
for key, count in {
    "max_prompt": 1, "style.opening.gentle": 1, "style.opening.intense": 1,
    "style.midpoint.gentle": 1, "style.midpoint.intense": 1,
    "finish.responses": 4, "aftercare": 2, "finish.labels": 5,
}.items():
    pool = translation.get("dialogue", {}).get(key, [])
    require(len(pool) == count and all(str(line).strip() and not cjk.search(str(line)) for line in pool), f"English flow pool invalid: {key}")
require(context.get("base", {}).get("dialogue", {}).get("en") == translation.get("dialogue"), "Context English dialogue overlay drift")
require(flow.get("patch_version") == "1.3.4" and profile.get("schema_version") == "1.3", "Profile/Flow versions drift")

relation = json.loads((ROOT / "data/staff/doc_aoi/relationship.json").read_text(encoding="utf-8"))
slots = [slot for slot in relation.get("rank_slots", []) if slot.get("target_level") == 4]
require(len(slots) == 1 and slots[0].get("event_id") == event_import.EVENT_ID and slots[0].get("content_status") == "authored", "Lv4 relationship slot drift")
bundle = json.loads((ROOT / "data/staff/doc_aoi/bundle.json").read_text(encoding="utf-8"))
require("lv4_events.json" in bundle.get("additional_character_event_files", []), "Lv4 event file not registered")
registry = (ROOT / "godot/systems/free_h_registry.gd").read_text(encoding="utf-8")
require('"doc_aoi"' in registry and '"content_status": "ready"' in registry, "ready Free H registration missing")
for key in ["ui.free_h.location.doc_aoi_hotel", "ui.free_h.doc_aoi.booking_response"]:
    zh = json.loads((ROOT / "data/localization/zh_CN.json").read_text(encoding="utf-8"))["strings"].get(key, "")
    en = json.loads((ROOT / "data/localization/en.json").read_text(encoding="utf-8"))["strings"].get(key, "")
    require(bool(zh), f"missing Chinese UI localization {key}")
    require(bool(en) and not cjk.search(en), f"missing/Chinese English UI localization {key}")

print(f"NARUMI LV4/H SOURCE AUDIT: {len(actual)} bilingual pages; {len(translation['dialogue'])} H pools; {len(failures)} failures")
for failure in failures:
    print(failure)
raise SystemExit(bool(failures))
