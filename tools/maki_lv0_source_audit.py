#!/usr/bin/env python3
"""Verbatim manuscript, schema, graph, localization, and asset audit for
Maki Aizawa (`doc_maki`) Lv0 standalone onboarding event:
《排班表上的名字》 (`maki_lv0_onboarding`).
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path

from jsonschema import Draft202012Validator
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import import_maki_lv0 as imp  # noqa: E402

MANUSCRIPT = ROOT / "research/source_scripts/HOSHIMI_AIZAWA_MAKI_LV0_NAME_ON_ROSTER_V1_1.md"
EN_JSON = ROOT / "research/translations/maki_lv0_en.json"
EVENT_JSON = ROOT / "data/staff/doc_maki/lv0_events.json"
EVENTS_BASE_JSON = ROOT / "data/staff/doc_maki/events.json"
BUNDLE_JSON = ROOT / "data/staff/doc_maki/bundle.json"
PROFILE_JSON = ROOT / "data/staff/doc_maki/profile.json"
SCHEMA_JSON = ROOT / "data/schemas/content.schema.json"
BACKGROUNDS_JSON = ROOT / "data/backgrounds.json"
ZH_LOCALE = ROOT / "data/localization/zh_CN.json"
EN_LOCALE = ROOT / "data/localization/en.json"
IMPORT_MANIFEST = ROOT / "research/imports/maki_lv0_2026-11-13.json"

CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\u3040-\u30ff]")
FORBIDDEN_SPOILERS = [
    "继父",
    "再婚",
    "去世",
    "过世",
    "逝世",
    "亡母",
    "遗志",
    "共同退休",
]

checks = 0
failures: list[str] = []


def require(cond: bool, label: str) -> None:
    global checks
    checks += 1
    if not cond:
        failures.append(label)


def main() -> None:
    require(MANUSCRIPT.is_file(), "Manuscript exists")
    require(EN_JSON.is_file(), "English translation JSON exists")
    require(EVENT_JSON.is_file(), "lv0_events.json exists")
    require(IMPORT_MANIFEST.is_file(), "Import manifest exists")

    # Preserve Codex's V1.1 empty events.json invariant
    require(json.loads(EVENTS_BASE_JSON.read_text(encoding="utf-8")) == [], "events.json preserved as []")
    bundle = json.loads(BUNDLE_JSON.read_text(encoding="utf-8"))
    require("lv0_events.json" in bundle.get("additional_character_event_files", []), "bundle.json registers lv0_events.json")

    profile = json.loads(PROFILE_JSON.read_text(encoding="utf-8"))
    require(profile.get("staff_unlock_event") == "maki_lv0_onboarding", "profile.staff_unlock_event == maki_lv0_onboarding")
    require(profile.get("surgical_roles") == ["assistant_surgeon"], "surgical_roles restricted to assistant_surgeon")
    require(profile.get("allowed_team_roles") == ["assistant_surgeon"], "allowed_team_roles restricted to assistant_surgeon")

    rows = json.loads(EVENT_JSON.read_text(encoding="utf-8"))
    require(isinstance(rows, list) and len(rows) == 1, "Single event in lv0_events.json")
    event = rows[0]

    # Schema validation
    schema = json.loads(SCHEMA_JSON.read_text(encoding="utf-8"))
    validator = Draft202012Validator({"$ref": "#/$defs/character_event", "$defs": schema["$defs"]})
    schema_errors = list(validator.iter_errors(event))
    require(len(schema_errors) == 0, f"JSON Schema valid ({[e.message for e in schema_errors[:3]]})")

    # Contract header checks (MK0-L01..L09)
    require(event["id"] == "maki_lv0_onboarding", "Event ID")
    require(event["actor_id"] == "doc_maki", "Actor ID")
    require(event["category"] == "introduction", "Introduction category")
    require(event["introduction_actor_ids"] == ["doc_maki"], "Introduction actor IDs")
    require(event["trigger_mode"] == "day_start", "day_start trigger mode")
    require(event["time_start"] == 540 and event["time_end"] == 719, "09:00-11:59 morning day_start window")
    require(event["minutes"] == 0, "minutes == 0 (time settled via completion_day_offset)")
    require(event["completion_day_offset"] == 1, "completion_day_offset == 1")
    require(event["completion_absolute_clock"] == 540, "completion_absolute_clock == 540")
    require(event["completion_display_clock"] == 1070, "completion_display_clock == 1070 (17:50)")
    require(event["locks_saving"] is True and event["hide_calendar_header"] is True, "Save lock & hidden header")
    require(
        event["conditions"]["required_events"] == ["asuka_lv2_right_person_right_gown"],
        "Requires asuka_lv2_right_person_right_gown",
    )
    require(
        event["conditions"]["min_affection"] == 0
        and event["conditions"]["min_familiarity"] == 0
        and event["conditions"]["special_requirements"] == [],
        "Zero extra Charm/Surgery/Reputation gates",
    )

    # Verbatim beat-by-beat check against manuscript
    beats, choice_labels_zh = imp.parse_manuscript()
    require(len(beats) == 158, "158 verbatim manuscript beats")
    nodes = event["nodes"]
    require(len(nodes) == 159, "159 total nodes (158 authored + 1 choice)")
    node_map = {n["id"]: n for n in nodes}

    for num, nid, _scene, _sec, role, aid, slabel, expected_text in beats:
        require(nid in node_map, f"Node {nid} present")
        node = node_map[nid]
        require(node["presentation"] == "authored", f"{nid} authored presentation")
        require(node["speaker"] == role, f"{nid} speaker role == {role}")
        require(node["actor_id"] == aid, f"{nid} actor_id == {aid}")
        require(node["speaker_label"] == slabel, f"{nid} speaker_label == {slabel}")
        require(node["text"] == expected_text, f"{nid} verbatim text match")
        for bad in FORBIDDEN_SPOILERS:
            require(bad not in node["text"], f"{nid} free of spoiler term '{bad}'")

    # Choice D1 verification
    ch_node = node_map["mk0_choice_d1"]
    require(ch_node["presentation"] == "choice" and ch_node["text"] == "", "Choice D1 node presentation")
    require(len(ch_node["choices"]) == 2, "Choice D1 has 2 options")
    for idx, cid in enumerate(["choice_mk0_d1_a", "choice_mk0_d1_b"]):
        opt = ch_node["choices"][idx]
        require(opt["id"] == cid, f"Choice ID {cid}")
        require(opt["label"] == choice_labels_zh[cid], f"Verbatim label for {cid}")
        require(opt["effects"] == {"affection": 0, "familiarity": 0}, f"Zero effects on {cid}")
        require(opt["flags"] == [], f"Zero flags on {cid}")

    # Graph reachability across both branches
    visited_all: set[str] = set()
    for pick in ("choice_mk0_d1_a", "choice_mk0_d1_b"):
        cur = event["start"]
        seen_path: list[str] = []
        steps = 0
        while cur != "@end" and steps < 300:
            require(cur in node_map, f"Valid target {cur} on {pick}")
            seen_path.append(cur)
            visited_all.add(cur)
            nd = node_map[cur]
            if cur == "mk0_choice_d1":
                chosen = next(c for c in nd["choices"] if c["id"] == pick)
            else:
                require(len(nd["choices"]) == 1, f"Single continue on {cur}")
                chosen = nd["choices"][0]
                require(chosen["effects"] == {"affection": 0, "familiarity": 0} and chosen["flags"] == [], f"Zero delta on {cur}")
            cur = chosen["next"]
            steps += 1
        require(cur == "@end", f"Branch {pick} reaches @end")
        require("mk0_122" in seen_path and seen_path[-1] == "mk0_158", f"Branch {pick} rejoins mk0_122..mk0_158")
    require(visited_all == set(node_map.keys()), "Zero unreachable orphan nodes")

    # Background & portrait asset checks
    bg_ids = {row["id"]: row["path"] for row in json.loads(BACKGROUNDS_JSON.read_text(encoding="utf-8"))}
    referenced_portraits: set[str] = set()
    for node in nodes:
        bg_id = node["background_id"]
        require(bg_id in bg_ids and (ROOT / bg_ids[bg_id]).is_file(), f"{node['id']} valid background {bg_id}")
        for ep in node.get("event_portraits", []):
            referenced_portraits.add(ep["path"])

    for rel_path in sorted(referenced_portraits):
        full = ROOT / rel_path
        imp_file = ROOT / (rel_path + ".import")
        require(full.is_file(), f"Portrait exists: {rel_path}")
        require(imp_file.is_file(), f".import exists: {rel_path}")
        if imp_file.is_file():
            imp_txt = imp_file.read_text(encoding="utf-8")
            require("mipmaps/generate=true" in imp_txt or "compress/mode=" in imp_txt, f".import valid: {rel_path}")
        with Image.open(full) as im:
            require(im.mode == "RGBA", f"RGBA mode: {rel_path}")
            if "maki_original_style_v1" in rel_path:
                require(im.size == (1024, 1536), f"1024x1536 size: {rel_path}")
                require(im.getpixel((0, 0))[3] == 0 and im.getpixel((1023, 0))[3] == 0, f"Transparent top corners: {rel_path}")

    # Bilingual localization audit
    zh_strings = json.loads(ZH_LOCALE.read_text(encoding="utf-8"))["strings"]
    en_strings = json.loads(EN_LOCALE.read_text(encoding="utf-8"))["strings"]
    prefix = "collections.character_events.maki_lv0_onboarding"

    for mkey in ("title", "teaser", "gallery.caption"):
        fk = f"{prefix}.{mkey}"
        require(bool(zh_strings.get(fk)), f"zh_CN {fk}")
        require(bool(en_strings.get(fk)) and not CJK_RE.search(en_strings[fk]), f"en {fk} non-empty & zero-CJK")

    for node in nodes:
        nid = node["id"]
        tk = f"{prefix}.nodes.{nid}.text"
        sk = f"{prefix}.nodes.{nid}.speaker_label"
        if node["presentation"] == "choice":
            require(tk not in zh_strings and tk not in en_strings, f"{tk} omitted on empty-text choice node")
        else:
            require(tk in zh_strings and zh_strings[tk] == node["text"], f"zh_CN {tk}")
            require(tk in en_strings and bool(en_strings[tk].strip()) and not CJK_RE.search(en_strings[tk]), f"en {tk} translated & zero-CJK")
        require(bool(en_strings.get(sk)) and not CJK_RE.search(en_strings[sk]), f"en {sk} zero-CJK")
        for ch in node["choices"]:
            ck = f"{prefix}.nodes.{nid}.choices.{ch['id']}.label"
            require(zh_strings.get(ck) == ch["label"], f"zh_CN {ck}")
            require(bool(en_strings.get(ck)) and not CJK_RE.search(en_strings[ck]), f"en {ck} zero-CJK")

    manifest = json.loads(IMPORT_MANIFEST.read_text(encoding="utf-8"))
    require(
        manifest["source_manuscript_sha256"] == hashlib.sha256(MANUSCRIPT.read_bytes()).hexdigest(),
        "Manifest manuscript SHA-256 matches",
    )

    if failures:
        for f in failures:
            print("FAIL:", f)
        print(f"MAKI LV0 SOURCE AUDIT FAILED: {checks} checks; {len(failures)} failure(s).")
        sys.exit(1)

    print(f"MAKI LV0 SOURCE AUDIT PASS: {checks} checks; 0 failure(s).")


if __name__ == "__main__":
    main()
