#!/usr/bin/env python3
"""Verbatim line-by-line source audit for Shiori Fujisaki Relationship Lv1 V1.2:
《藤崎医生的烦恼》 (`shiori_lv1_doctors_worry`).

Independently extracts all narrative and spoken lines from `research/source_scripts/HOSHIMI_SHIORI_LV1_DOCTORS_WORRY_V1_2.md`
and verifies 100% character-for-character equality of text, speaker attribution, beat order,
portrait asset existence, bundle/relationship registration, and bilingual localization coverage.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts/HOSHIMI_SHIORI_LV1_DOCTORS_WORRY_V1_2.md"
EVENT_FILE = ROOT / "data/staff/doc_shiori/lv1_events.json"
BUNDLE_FILE = ROOT / "data/staff/doc_shiori/bundle.json"
RELATIONSHIP_FILE = ROOT / "data/staff/doc_shiori/relationship.json"
PROFILE_FILE = ROOT / "data/staff/doc_shiori/profile.json"
LOCATIONS_FILE = ROOT / "data/locations.json"
LOC_ZH = ROOT / "data/localization/zh_CN.json"
LOC_EN = ROOT / "data/localization/en.json"

EVENT_ID = "shiori_lv1_doctors_worry"
CJK_RE = re.compile(r"[\u4e00-\u9fff]")


def extract_expected_beats(md_text: str) -> list[tuple[str, str]]:
    body = md_text.split("## S1｜诊察券背面的签名请求", 1)[1].split(
        "**【事件结束｜结算：藤崎詩織 Relationship 等级提升至 Lv1】**", 1
    )[0]
    expected: list[tuple[str, str]] = []
    for raw in body.splitlines():
        line = raw.strip()
        if not line or line == "---" or line.startswith("## S"):
            continue
        if line.startswith("**【场景】**") or line.startswith("**【时间】**") or line.startswith("**【服装】**"):
            continue
        if line.startswith("*(") and line.endswith(")*"):
            inner = line[2:-2].strip()
            # Strip authorial expression annotation `【藤崎詩織：...】`
            inner_clean = re.sub(r"^【藤崎詩織：[^】]+】", "", inner).strip()
            if inner_clean:
                expected.append(("旁白", inner_clean))
            continue
        m = re.fullmatch(r"\*\*([^*]+)\*\*：(「.*」)", line)
        if m:
            expected.append((m.group(1).strip(), m.group(2).strip()))
            continue
        raise AssertionError(f"Unrecognized manuscript line: {line!r}")
    return expected


def main() -> int:
    errors: list[str] = []
    md_text = SOURCE.read_text(encoding="utf-8")
    expected = extract_expected_beats(md_text)

    events = json.loads(EVENT_FILE.read_text(encoding="utf-8"))
    if len(events) != 1 or events[0].get("id") != EVENT_ID:
        errors.append(f"Expected single event {EVENT_ID} in {EVENT_FILE}")
        print("\n".join(errors))
        return 1

    ev = events[0]
    if ev.get("title") != "藤崎医生的烦恼":
        errors.append(f"Title mismatch: {ev.get('title')!r}")
    if ev.get("location_id") != "lounge" or ev.get("background_id") != "staff_lounge":
        errors.append(f"Location/background mismatch: {ev.get('location_id')} / {ev.get('background_id')}")
    if ev.get("category") != "bond" or ev.get("target_level") != 1:
        errors.append(f"Category/target_level mismatch: {ev.get('category')} / {ev.get('target_level')}")
    if ev.get("conditions", {}).get("min_familiarity") != 10:
        errors.append(f"Expected min_familiarity=10, got {ev.get('conditions')}")
    if ev.get("conditions", {}).get("required_events") != []:
        errors.append("Expected empty required_events so both clinic and ward Lv0 intros unlock Lv1")

    nodes = ev.get("nodes", [])
    if len(nodes) != len(expected):
        errors.append(f"Beat count mismatch: JSON has {len(nodes)}, manuscript has {len(expected)}")
    else:
        for idx, (node, (exp_spk, exp_txt)) in enumerate(zip(nodes, expected), start=1):
            if node.get("speaker_label") != exp_spk:
                errors.append(
                    f"Beat {idx} ({node.get('id')}): speaker mismatch {node.get('speaker_label')!r} != {exp_spk!r}"
                )
            if node.get("text") != exp_txt:
                errors.append(
                    f"Beat {idx} ({node.get('id')}): text mismatch:\n  JSON: {node.get('text')!r}\n  SRC : {exp_txt!r}"
                )
            expected_kind = "narrator" if exp_spk == "旁白" else ("player" if exp_spk == "坂口隆司" else "actor")
            if node.get("speaker") != expected_kind:
                errors.append(
                    f"Beat {idx} ({node.get('id')}): speaker kind {node.get('speaker')!r} != {expected_kind!r}"
                )
            for ep in node.get("event_portraits", []):
                p = ROOT / ep["path"]
                if not p.is_file():
                    errors.append(f"Missing portrait file referenced at {node.get('id')}: {ep['path']}")

    # Verify expression variety (all 6 white_coat expressions used)
    used_exprs = {n.get("expression") for n in nodes}
    expected_exprs = {"neutral", "wry_smile", "gentle_smile", "shy_reproach", "professional", "pensive"}
    if used_exprs != expected_exprs:
        errors.append(f"Expression set mismatch: used={sorted(used_exprs)}, expected={sorted(expected_exprs)}")

    # Verify bundle, relationship, profile, and lounge registration
    bundle = json.loads(BUNDLE_FILE.read_text(encoding="utf-8"))
    if "lv1_events.json" not in bundle.get("additional_character_event_files", []):
        errors.append("lv1_events.json missing from doc_shiori/bundle.json additional_character_event_files")

    rel = json.loads(RELATIONSHIP_FILE.read_text(encoding="utf-8"))
    lv1_slots = [s for s in rel.get("rank_slots", []) if s.get("target_level") == 1]
    if not lv1_slots or lv1_slots[0].get("event_id") != EVENT_ID or lv1_slots[0].get("content_status") != "authored":
        errors.append(f"relationship.json Lv1 rank_slot not wired: {lv1_slots}")

    prof = json.loads(PROFILE_FILE.read_text(encoding="utf-8"))
    portraits = prof.get("visuals", {}).get("portraits", {})
    for ex in expected_exprs:
        key = f"white_coat/{ex}"
        rel_path = portraits.get(key, "")
        if not rel_path or not (ROOT / rel_path).is_file():
            errors.append(f"Missing profile portrait mapping or file for {key}: {rel_path!r}")

    locations = json.loads(LOCATIONS_FILE.read_text(encoding="utf-8"))
    lounge = next((loc for loc in locations if loc.get("id") == "lounge"), {})
    if "doc_shiori" not in lounge.get("staff_ids", []):
        errors.append("doc_shiori missing from lounge.staff_ids in data/locations.json")

    # Verify zh_CN and en localization
    zh_strings = json.loads(LOC_ZH.read_text(encoding="utf-8"))["strings"]
    en_strings = json.loads(LOC_EN.read_text(encoding="utf-8"))["strings"]
    prefix = f"collections.character_events.{EVENT_ID}"
    for suffix in (".title", ".teaser", ".gallery.caption"):
        if not zh_strings.get(prefix + suffix):
            errors.append(f"Missing zh_CN {prefix + suffix}")
        en_val = en_strings.get(prefix + suffix, "")
        if not en_val or CJK_RE.search(en_val):
            errors.append(f"Missing or CJK-contaminated en {prefix + suffix}: {en_val!r}")

    for node in nodes:
        stem = f"{prefix}.nodes.{node['id']}"
        if zh_strings.get(stem + ".text") != node["text"]:
            errors.append(f"zh_CN text mismatch on {node['id']}")
        en_txt = en_strings.get(stem + ".text", "")
        if not en_txt or CJK_RE.search(en_txt):
            errors.append(f"Missing or CJK-contaminated en text on {node['id']}: {en_txt!r}")
        en_spk = en_strings.get(stem + ".speaker_label", "")
        if not en_spk or CJK_RE.search(en_spk):
            errors.append(f"Missing or CJK-contaminated en speaker_label on {node['id']}: {en_spk!r}")
        for ch in node.get("choices", []):
            ckey = f"{stem}.choices.{ch['id']}.label"
            en_ch = en_strings.get(ckey, "")
            if not en_ch or CJK_RE.search(en_ch):
                errors.append(f"Missing or CJK-contaminated en choice on {ckey}: {en_ch!r}")

    if errors:
        print(f"FAIL ({len(errors)} errors):")
        for e in errors:
            print(" -", e)
        return 1

    print(
        f"PASS: Shiori Lv1 verbatim source audit ({len(nodes)} beats, 0 text/speaker/order diffs, "
        f"6 white_coat expressions verified, EN/ZH 100% clean)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
