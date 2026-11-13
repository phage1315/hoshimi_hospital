#!/usr/bin/env python3
"""Verbatim line-by-line source audit for Shiori Fujisaki Relationship Lv2 V1.0:
《唱片店里的藤崎诗织》 (`shiori_lv2_record_shop`).

Independently extracts all narrative beats, spoken lines, RP choice options, and branch/merge
structures from `research/source_scripts/HOSHIMI_SHIORI_LV2_RECORD_SHOP_V1_0.md` and verifies
100% character-for-character equality of text, speaker attribution, beat order, choice labels,
branch topology, portrait & background asset existence (all 14 sprites exercised), bundle and
relationship registration, and bilingual localization coverage.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts/HOSHIMI_SHIORI_LV2_RECORD_SHOP_V1_0.md"
EVENT_FILE = ROOT / "data/staff/doc_shiori/lv2_events.json"
BUNDLE_FILE = ROOT / "data/staff/doc_shiori/bundle.json"
RELATIONSHIP_FILE = ROOT / "data/staff/doc_shiori/relationship.json"
BACKGROUNDS_FILE = ROOT / "data/backgrounds.json"
LOCATIONS_FILE = ROOT / "data/locations.json"
LOC_ZH = ROOT / "data/localization/zh_CN.json"
LOC_EN = ROOT / "data/localization/en.json"

EVENT_ID = "shiori_lv2_record_shop"
CJK_RE = re.compile(r"[\u4e00-\u9fff]")


def extract_expected(md_text: str) -> tuple[list[tuple[str, str]], list[tuple[int, str, str, int, int, int]]]:
    """Returns:
    - expected_beats: list of (speaker_label, text) in exact manuscript order
    - expected_choices: list of (host_idx_0based, opt_a_label, opt_b_label, a_start_idx, b_start_idx, merge_idx)
    """
    body = md_text.split("## Scene 1｜意想不到的住院患者", 1)[1].split(
        "**【事件结束｜结算：藤崎詩織 Relationship 等级提升至 Lv2】**", 1
    )[0]
    beats: list[tuple[str, str]] = []
    choices: list[tuple[int, str, str, int, int, int]] = []

    in_costume = False
    cur_host = -1
    opt_a = ""
    opt_b = ""
    a_start = -1
    b_start = -1
    pending_tag = ""

    for raw in body.splitlines():
        line = raw.strip()
        if not line:
            continue
        if line == "---":
            in_costume = False
            continue
        if line == "# 下半部分：古典音乐唱片店" or line.startswith("## Scene "):
            in_costume = False
            continue
        if line.startswith(("**【场景】**", "**【时间】**", "**【在场角色】**")):
            continue
        if line.startswith("**【服装与状态】**"):
            in_costume = True
            continue
        if in_costume and line.startswith("- "):
            continue
        if re.match(r"^\*\*【选择 [123]：.+】\*\*$", line):
            cur_host = len(beats) - 1
            opt_a = ""
            opt_b = ""
            a_start = -1
            b_start = -1
            continue
        if line.startswith("*选项说明：") and line.endswith("*"):
            continue
        m_opt = re.match(r"^- \*\*选项 ([AB])：(「.+」)\*\*$", line)
        if m_opt:
            if m_opt.group(1) == "A":
                opt_a = m_opt.group(2)
            else:
                opt_b = m_opt.group(2)
            continue
        if line == "**【选择选项 A 后的分支演出】**":
            pending_tag = "A"
            continue
        if line == "**【选择选项 B 后的分支演出】**":
            pending_tag = "B"
            continue
        if re.match(r"^\*\*【分支汇合点：.+】\*\*$", line):
            pending_tag = "M"
            continue

        m_dlg = re.fullmatch(r"\*\*([^*]+)\*\*：(「.+」)", line)
        if m_dlg:
            entry = (m_dlg.group(1).strip(), m_dlg.group(2).strip())
        else:
            if line.startswith(("#", "**", "- ", "*")):
                raise AssertionError(f"Unrecognized manuscript line: {line!r}")
            entry = ("旁白", line)

        idx = len(beats)
        beats.append(entry)
        if pending_tag == "A":
            a_start = idx
            pending_tag = ""
        elif pending_tag == "B":
            b_start = idx
            pending_tag = ""
        elif pending_tag == "M":
            choices.append((cur_host, opt_a, opt_b, a_start, b_start, idx))
            pending_tag = ""

    return beats, choices


def main() -> int:
    errors: list[str] = []
    md_text = SOURCE.read_text(encoding="utf-8")
    expected_beats, expected_choices = extract_expected(md_text)

    events = json.loads(EVENT_FILE.read_text(encoding="utf-8"))
    if len(events) != 1 or events[0].get("id") != EVENT_ID:
        errors.append(f"Expected single event {EVENT_ID} in {EVENT_FILE}")
        print("\n".join(errors))
        return 1

    ev = events[0]
    if ev.get("title") != "唱片店里的藤崎诗织":
        errors.append(f"Title mismatch: {ev.get('title')!r}")
    if ev.get("location_id") != "ward" or ev.get("background_id") != "ward":
        errors.append(f"Location/background mismatch: {ev.get('location_id')} / {ev.get('background_id')}")
    if ev.get("category") != "rank_up" or ev.get("target_level") != 2:
        errors.append(f"Category/target_level mismatch: {ev.get('category')} / {ev.get('target_level')}")
    if ev.get("completion_day_offset") != 1 or ev.get("completion_absolute_clock") != 540:
        errors.append("Cross-day safe-boundary settlement drift (expected offset=1, clock=540)")
    if not ev.get("locks_saving") or not ev.get("hide_calendar_header"):
        errors.append("Expected locks_saving=True and hide_calendar_header=True")

    cond = ev.get("conditions", {})
    if (
        cond.get("min_familiarity") != 25
        or cond.get("required_events") != ["shiori_lv1_doctors_worry"]
        or cond.get("days_after_required_events") != 3
        or cond.get("special_requirements") != []
    ):
        errors.append(f"Gate conditions mismatch: {cond}")

    bgs = {item["id"]: item for item in json.loads(BACKGROUNDS_FILE.read_text(encoding="utf-8"))}
    for bg_id in ("shiori_lv2_classical_record_shop", "shiori_lv2_station_plaza_night"):
        if bg_id not in bgs:
            errors.append(f"Missing background registration in data/backgrounds.json: {bg_id}")
        elif not (ROOT / bgs[bg_id]["path"]).is_file():
            errors.append(f"Missing background image file: {bgs[bg_id]['path']}")

    nodes = ev.get("nodes", [])
    used_portrait_paths: set[str] = set()
    if len(nodes) != len(expected_beats):
        errors.append(f"Beat count mismatch: JSON has {len(nodes)}, manuscript has {len(expected_beats)}")
    else:
        for idx, (node, (exp_spk, exp_txt)) in enumerate(zip(nodes, expected_beats), start=1):
            if node.get("speaker_label") != exp_spk:
                errors.append(f"Beat {idx} ({node.get('id')}): speaker {node.get('speaker_label')!r} != {exp_spk!r}")
            if node.get("text") != exp_txt:
                errors.append(
                    f"Beat {idx} ({node.get('id')}): text mismatch:\n  JSON: {node.get('text')!r}\n  SRC : {exp_txt!r}"
                )
            expected_kind = "narrator" if exp_spk == "旁白" else ("player" if exp_spk == "坂口隆司" else "actor")
            if node.get("speaker") != expected_kind:
                errors.append(f"Beat {idx} ({node.get('id')}): speaker kind {node.get('speaker')!r} != {expected_kind!r}")
            bg_id = str(node.get("background_id", ""))
            if bg_id not in bgs:
                errors.append(f"Beat {idx} ({node.get('id')}): unknown background_id {bg_id!r}")
            for ep in node.get("event_portraits", []):
                used_portrait_paths.add(ep["path"])
                if not (ROOT / ep["path"]).is_file():
                    errors.append(f"Missing portrait file at {node.get('id')}: {ep['path']}")

        # Verify all 3 RP choice blocks and branch/merge wiring
        if len(expected_choices) != 3:
            errors.append(f"Expected 3 choice blocks in manuscript, got {len(expected_choices)}")
        for ch_no, (h_idx, exp_a, exp_b, a_idx, b_idx, m_idx) in enumerate(expected_choices, start=1):
            host = nodes[h_idx]
            chs = host.get("choices", [])
            if len(chs) != 2:
                errors.append(f"Choice {ch_no} host {host['id']} does not have 2 choices")
                continue
            if chs[0]["label"] != exp_a or chs[1]["label"] != exp_b:
                errors.append(f"Choice {ch_no} label mismatch on {host['id']}")
            if chs[0]["next"] != nodes[a_idx]["id"] or chs[1]["next"] != nodes[b_idx]["id"]:
                errors.append(f"Choice {ch_no} branch target mismatch on {host['id']}")
            end_a = nodes[b_idx - 1]
            end_b = nodes[m_idx - 1]
            merge_id = nodes[m_idx]["id"]
            if end_a["choices"][0]["next"] != merge_id or end_b["choices"][0]["next"] != merge_id:
                errors.append(f"Choice {ch_no} merge wiring mismatch into {merge_id}")

    expected_14_sprites = {
        "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/gentle_smile.png",
        "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/surprised.png",
        "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/wry_smile.png",
        "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/professional.png",
        "assets/characters/shiori_lv2_v1/doc_shiori/casual_coat/gentle_smile.png",
        "assets/characters/shiori_lv2_v1/doc_shiori/casual_coat/enthusiastic.png",
        "assets/characters/shiori_lv2_v1/doc_shiori/casual_coat/slightly_embarrassed.png",
        "assets/characters/shiori_lv2_v1/doc_shiori/casual_coat/pensive_shy.png",
        "assets/characters/shiori_lv2_v1/doc_shiori/casual_coat/relieved_blush.png",
        "assets/characters/story_patients/asahina_yuko/ward/cheerful_tease.png",
        "assets/characters/story_patients/asahina_yuko/ward/sigh_troubled.png",
        "assets/characters/story_patients/asahina_yuko/ward/shocked_panic.png",
        "assets/characters/story_patients/asahina_yuko/ward/nervous_blush.png",
        "assets/characters/story_patients/asahina_yuko/ward/relieved.png",
    }
    if used_portrait_paths != expected_14_sprites:
        missing = sorted(expected_14_sprites - used_portrait_paths)
        extra = sorted(used_portrait_paths - expected_14_sprites)
        errors.append(f"Portrait usage mismatch: missing={missing}, extra={extra}")

    bundle = json.loads(BUNDLE_FILE.read_text(encoding="utf-8"))
    if "lv2_events.json" not in bundle.get("additional_character_event_files", []):
        errors.append("lv2_events.json missing from doc_shiori/bundle.json additional_character_event_files")

    rel = json.loads(RELATIONSHIP_FILE.read_text(encoding="utf-8"))
    lv2_slots = [s for s in rel.get("rank_slots", []) if s.get("target_level") == 2]
    if not lv2_slots or lv2_slots[0].get("event_id") != EVENT_ID or lv2_slots[0].get("content_status") != "authored":
        errors.append(f"relationship.json Lv2 rank_slot not wired: {lv2_slots}")

    locations = json.loads(LOCATIONS_FILE.read_text(encoding="utf-8"))
    ward = next((loc for loc in locations if loc.get("id") == "ward"), {})
    if "doc_shiori" not in ward.get("staff_ids", []):
        errors.append("doc_shiori missing from ward.staff_ids in data/locations.json")

    zh_strings = json.loads(LOC_ZH.read_text(encoding="utf-8"))["strings"]
    en_strings = json.loads(LOC_EN.read_text(encoding="utf-8"))["strings"]
    prefix = f"collections.character_events.{EVENT_ID}"
    for suffix in (".title", ".teaser", ".gallery.caption"):
        if not zh_strings.get(prefix + suffix):
            errors.append(f"Missing zh_CN {prefix + suffix}")
        en_val = en_strings.get(prefix + suffix, "")
        if not en_val or CJK_RE.search(en_val):
            errors.append(f"Missing or CJK-contaminated en {prefix + suffix}: {en_val!r}")

    for bg_id in ("shiori_lv2_classical_record_shop", "shiori_lv2_station_plaza_night"):
        bg_key = f"collections.backgrounds.{bg_id}.label"
        if not zh_strings.get(bg_key) or not en_strings.get(bg_key) or CJK_RE.search(en_strings.get(bg_key, "")):
            errors.append(f"Missing/CJK background localization for {bg_key}")

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
            if zh_strings.get(ckey) != ch["label"]:
                errors.append(f"zh_CN choice mismatch on {ckey}")
            en_ch = en_strings.get(ckey, "")
            if not en_ch or CJK_RE.search(en_ch):
                errors.append(f"Missing or CJK-contaminated en choice on {ckey}: {en_ch!r}")

    if errors:
        print(f"FAIL ({len(errors)} errors):")
        for e in errors:
            print(" -", e)
        return 1

    print(
        f"PASS: Shiori Lv2 verbatim source audit ({len(nodes)} beats, 3 two-option RP choices, "
        f"0 text/speaker/order/punctuation diffs, all 14 portrait sprites + 2 new BGs verified, EN/ZH 100% clean)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
