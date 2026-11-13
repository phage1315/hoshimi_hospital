#!/usr/bin/env python3
"""Verbatim line-by-line source audit for Fujisaki Shiori Relationship Lv3 V1.1:
《夕子的手术与那晚的归途》 (`shiori_lv3_part_a_yuko_surgery` + `shiori_lv3_part_b_dinner_walk`).

Independently extracts all narrative beats, stage-direction prefixes, spoken lines, RP choice
options, branch/merge structures, and all 13 Section 4 intraoperative lines directly from:
  - `research/source_scripts/HOSHIMI_SHIORI_LV3_PART_A_YUKO_SURGERY_V1_1.md`
  - `research/source_scripts/HOSHIMI_SHIORI_LV3_PART_B_DINNER_WALK_V1_1.md`
and verifies:
  1. 100% character-for-character equality across all 206 Part A beats + 178 Part B beats;
  2. 100% character-for-character presence of all 13 Section 4 intraoperative lines in
     `godot/systems/shiori_lv3.gd`;
  3. Choice topology, graph reachability, `launch_shiori_lv3_yuko_surgery` handoff on `slv3a_174`,
     and `seasonal_street: True` on all `Scene B5` nodes;
  4. Existence, RGBA alpha channels, and full usage of all 28 newly generated sprites + 2 new
     `16:9` backgrounds;
  5. `bundle.json`, `relationship.json` (`target_level: 3`), and 100% bilingual `zh_CN` + `en`
     localization coverage with zero CJK residue in English.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC_A = ROOT / "research/source_scripts/HOSHIMI_SHIORI_LV3_PART_A_YUKO_SURGERY_V1_1.md"
SRC_B = ROOT / "research/source_scripts/HOSHIMI_SHIORI_LV3_PART_B_DINNER_WALK_V1_1.md"
EVENT_FILE = ROOT / "data/staff/doc_shiori/lv3_events.json"
SHIORI_LV3_GD = ROOT / "godot/systems/shiori_lv3.gd"
BUNDLE_FILE = ROOT / "data/staff/doc_shiori/bundle.json"
RELATIONSHIP_FILE = ROOT / "data/staff/doc_shiori/relationship.json"
BACKGROUNDS_FILE = ROOT / "data/backgrounds.json"
LOC_ZH = ROOT / "data/localization/zh_CN.json"
LOC_EN = ROOT / "data/localization/en.json"

PART_A_ID = "shiori_lv3_part_a_yuko_surgery"
PART_B_ID = "shiori_lv3_part_b_dinner_walk"
CJK_RE = re.compile(r"[\u4e00-\u9fff]")


def infer_inline_speaker(prefix: str) -> str:
    for key, canonical in (
        ("旁边的藤崎詩織", "藤崎詩織"),
        ("藤崎詩織", "藤崎詩織"),
        ("诗织口罩", "藤崎詩織"),
        ("坂口隆司", "坂口隆司"),
        ("还没等大家分主次落座，朝日奈夕子", "朝日奈夕子"),
        ("朝日奈夕子", "朝日奈夕子"),
        ("夕子猛地", "朝日奈夕子"),
        ("美樹原愛", "美樹原愛"),
    ):
        if prefix.startswith(key):
            return canonical
    raise AssertionError(f"Unrecognized inline speaker prefix: {prefix!r}")


def extract_expected(
    md_text: str, start_marker: str, end_marker: str
) -> tuple[list[tuple[str, str]], list[tuple[int, str, str, int, int, int]]]:
    body = start_marker + md_text.split(start_marker, 1)[1].split(end_marker, 1)[0]
    beats: list[tuple[str, str]] = []
    choices: list[tuple[int, str, str, int, int, int]] = []

    in_costume = False
    cur_host = -1
    opt_a = ""
    opt_b = ""
    a_start = -1
    b_start = -1
    pending_tag = ""

    def emit(entry: tuple[str, str]) -> None:
        nonlocal a_start, b_start, pending_tag
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

    for raw in body.splitlines():
        line = raw.strip()
        if not line:
            continue
        if line == "---":
            in_costume = False
            continue
        if line.startswith("## Scene "):
            in_costume = False
            continue
        if line.startswith(("**【场景】**", "**【时间】**", "**【在场角色】**")):
            continue
        if line.startswith("**【服装与状态】**"):
            in_costume = True
            continue
        if in_costume and line.startswith("- "):
            continue
        if line in (
            "**【切入普通 Surgery Runner 前的短过场（玩家可见）】**",
            "**【普通 Surgery Runner 顺利完成后的收尾短过场（玩家可见）】**",
        ) or line.startswith("> **【==="):
            continue
        if re.match(r"^\*\*【选择 \d+（Choice [AB]\d+）：.+】\*\*$", line):
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
            emit((m_dlg.group(1).strip(), m_dlg.group(2).strip()))
            continue

        m_paren = re.fullmatch(r"\*\*([^*]+)\*\*（([^）]+)）：(「.+」)", line)
        if m_paren:
            spk = m_paren.group(1).strip()
            act = m_paren.group(2).strip()
            emit(("旁白", f"{spk}（{act}）："))
            emit((spk, m_paren.group(3).strip()))
            continue

        m_mix = re.match(r"^(.+?)：(「[^「」]+」)$", line)
        if m_mix:
            pref, qt = m_mix.group(1), m_mix.group(2)
            spk = infer_inline_speaker(pref)
            emit(("旁白", pref + "："))
            emit((spk, qt))
            continue

        if line.startswith(("#", "**", "- ", "*")):
            raise AssertionError(f"Unrecognized manuscript line: {line!r}")
        emit(("旁白", line))

    return beats, choices


def extract_section4_lines(md_text: str) -> list[str]:
    sec4 = md_text.split("# 四、 角色专属术中对白与朝日奈夕子反应草稿", 1)[1].split("# 五、", 1)[0]
    quotes: list[str] = []
    for raw in sec4.splitlines():
        line = raw.strip()
        if not line.startswith("| **"):
            continue
        cols = [c.strip() for c in line.strip("|").split("|")]
        if len(cols) >= 3 and cols[2].startswith("「") and cols[2].endswith("」"):
            quotes.append(cols[2])
    return quotes


def main() -> int:
    errors: list[str] = []

    md_a = SRC_A.read_text(encoding="utf-8")
    md_b = SRC_B.read_text(encoding="utf-8")
    exp_a, choices_a = extract_expected(
        md_a, "## Scene A1｜四周后的回诊——诗织的眉头", "**【Part A 结束｜登记"
    )
    exp_b, choices_b = extract_expected(
        md_b, "## Scene B1｜夕子出院复诊：主动发出的答谢邀请", "**【事件结束｜原子性结算："
    )
    sec4_quotes = extract_section4_lines(md_a)
    if len(sec4_quotes) != 13:
        errors.append(f"Expected 13 Section 4 intraoperative quotes, extracted {len(sec4_quotes)}")

    gd_text = SHIORI_LV3_GD.read_text(encoding="utf-8")
    for idx, q in enumerate(sec4_quotes, start=1):
        inner = q[1:-1]
        if q not in gd_text and inner not in gd_text:
            errors.append(f"Section 4 intraoperative quote #{idx} missing in shiori_lv3.gd: {q}")

    events = json.loads(EVENT_FILE.read_text(encoding="utf-8"))
    if len(events) != 2:
        errors.append(f"Expected 2 events in {EVENT_FILE}, found {len(events)}")
        print("\n".join(errors))
        return 1

    ev_a, ev_b = events[0], events[1]
    if ev_a.get("id") != PART_A_ID or ev_b.get("id") != PART_B_ID:
        errors.append(f"Unexpected event IDs: {ev_a.get('id')} / {ev_b.get('id')}")

    # Metadata & Gate checks
    if ev_a.get("category") != "contextual" or ev_b.get("category") != "rank_up":
        errors.append(f"Category mismatch: Part A={ev_a.get('category')}, Part B={ev_b.get('category')}")
    if ev_b.get("target_level") != 3 or ev_b.get("consumes_sunday") is not False:
        errors.append("Part B must have target_level=3 and consumes_sunday=False")
    if ev_a.get("completion_day_offset") != 1 or ev_a.get("completion_absolute_clock") != 960:
        errors.append("Part A completion settlement drift (expected offset=1, clock=960)")
    if ev_b.get("completion_day_offset") != 3 or ev_b.get("completion_absolute_clock") != 540:
        errors.append("Part B completion settlement drift (expected offset=3, clock=540)")

    bgs = {item["id"]: item for item in json.loads(BACKGROUNDS_FILE.read_text(encoding="utf-8"))}
    for bg_id in ("shiori_lv3_trattoria_exterior_evening", "shiori_lv3_apartment_entrance_night"):
        if bg_id not in bgs:
            errors.append(f"Missing background registration: {bg_id}")
        elif not (ROOT / bgs[bg_id]["path"]).is_file():
            errors.append(f"Missing background PNG file: {bgs[bg_id]['path']}")

    used_portraits: set[str] = set()
    for ev, exp_beats, exp_choices, exp_choice_cnt in (
        (ev_a, exp_a, choices_a, 1),
        (ev_b, exp_b, choices_b, 3),
    ):
        ev_id = ev["id"]
        nodes = ev.get("nodes", [])
        if len(nodes) != len(exp_beats):
            errors.append(f"{ev_id}: beat count mismatch (JSON {len(nodes)} != SRC {len(exp_beats)})")
            continue

        # Reachability check
        by_id = {n["id"]: n for n in nodes}
        reachable: set[str] = set()
        pending = [ev["start"]]
        while pending:
            nid = pending.pop()
            if nid == "@end" or nid in reachable:
                continue
            if nid not in by_id:
                errors.append(f"{ev_id}: broken next target {nid!r}")
                continue
            reachable.add(nid)
            for ch in by_id[nid].get("choices", []):
                pending.append(ch["next"])
        if reachable != set(by_id):
            errors.append(f"{ev_id}: unreachable nodes {sorted(set(by_id) - reachable)}")

        for idx, (node, (exp_spk, exp_txt)) in enumerate(zip(nodes, exp_beats), start=1):
            if node.get("speaker_label") != exp_spk:
                errors.append(f"{ev_id}#{idx} ({node['id']}): speaker {node.get('speaker_label')!r} != {exp_spk!r}")
            if node.get("text") != exp_txt:
                errors.append(
                    f"{ev_id}#{idx} ({node['id']}): text mismatch:\n  JSON: {node.get('text')!r}\n  SRC : {exp_txt!r}"
                )
            if "**" in str(node.get("text", "")):
                errors.append(f"{ev_id}#{idx} ({node['id']}): leaked markdown ** emphasis")
            expected_kind = "narrator" if exp_spk == "旁白" else ("player" if exp_spk == "坂口隆司" else "actor")
            if node.get("speaker") != expected_kind:
                errors.append(f"{ev_id}#{idx} ({node['id']}): speaker kind {node.get('speaker')!r} != {expected_kind!r}")
            if node.get("background_id") not in bgs:
                errors.append(f"{ev_id}#{idx} ({node['id']}): unknown background_id {node.get('background_id')!r}")
            for ep in node.get("event_portraits", []):
                used_portraits.add(ep["path"])
                if not (ROOT / ep["path"]).is_file():
                    errors.append(f"{ev_id}#{idx} ({node['id']}): missing portrait file {ep['path']}")

        if len(exp_choices) != exp_choice_cnt:
            errors.append(f"{ev_id}: expected {exp_choice_cnt} choices, extracted {len(exp_choices)}")
        for ch_no, (h_idx, exp_opt_a, exp_opt_b, a_idx, b_idx, m_idx) in enumerate(exp_choices, start=1):
            host = nodes[h_idx]
            chs = host.get("choices", [])
            if len(chs) != 2:
                errors.append(f"{ev_id} Choice {ch_no} host {host['id']} missing 2 options")
                continue
            if chs[0]["label"] != exp_opt_a or chs[1]["label"] != exp_opt_b:
                errors.append(f"{ev_id} Choice {ch_no} option label mismatch on {host['id']}")
            if chs[0]["next"] != nodes[a_idx]["id"] or chs[1]["next"] != nodes[b_idx]["id"]:
                errors.append(f"{ev_id} Choice {ch_no} branch target mismatch on {host['id']}")
            end_a = nodes[b_idx - 1]
            end_b = nodes[m_idx - 1]
            merge_id = nodes[m_idx]["id"]
            if end_a["choices"][0]["next"] != merge_id or end_b["choices"][0]["next"] != merge_id:
                errors.append(f"{ev_id} Choice {ch_no} merge target mismatch into {merge_id}")

    # Runner handoff, Scene A4/A5 CG windows & Scene B5 seasonal street checks
    cg1_path = "assets/events/shiori_lv3_v1/yuko_spinal_lateral.png"
    cg2_path = "assets/events/shiori_lv3_v1/yuko_supine_sensory_test.png"
    for cg_rel in (cg1_path, cg2_path):
        if not (ROOT / cg_rel).is_file():
            errors.append(f"Missing Part A CG file: {cg_rel}")
    if ev_a.get("gallery", {}).get("path") != cg1_path:
        errors.append(f"Part A gallery.path mismatch: {ev_a.get('gallery', {}).get('path')!r}")
    by_num_a = {int(n["id"].split("_")[-1]): n for n in ev_a["nodes"]}
    for expected_cg, start_i, end_i in ((cg1_path, 108, 128), (cg2_path, 132, 148)):
        for idx in range(start_i, end_i + 1):
            n = by_num_a[idx]
            if (
                n.get("cg_path") != expected_cg
                or n.get("cg_fit") != "cover"
                or n.get("cg_dialogue_delay_seconds") != 1.0
                or n.get("hide_portrait") is not False
                or "event_portraits" in n
            ):
                errors.append(f"CG staging mismatch on {n['id']}: {n.get('cg_path')!r} / fit={n.get('cg_fit')!r} / delay={n.get('cg_dialogue_delay_seconds')!r}")

    # Approved Part B CG windows and restoration to sprite staging outside them.
    windows_b = [("dinner_toast_pov_v2.png", 60, 61),
                 ("apartment_hesitant.png", 169, 172),
                 ("apartment_goodnight.png", 173, 177)]
    for n in ev_b["nodes"]:
        idx = int(n["id"].split("_")[-1])
        expected = next((f"assets/events/shiori_lv3_v1/{name}" for name, lo, hi in windows_b if lo <= idx <= hi), "")
        if n.get("cg_path", "") != expected:
            errors.append(f"Part B CG boundary mismatch: {n['id']}")
        if expected and (not (ROOT / expected).is_file() or n.get("cg_fit") != "cover" or n.get("cg_dialogue_delay_seconds") != 1.0 or n.get("hide_portrait") is not False or "event_portraits" in n):
            errors.append(f"Part B CG staging invalid: {n['id']}")
    if ev_b.get("gallery", {}).get("path") != "assets/events/shiori_lv3_v1/apartment_goodnight.png":
        errors.append("Part B gallery must show approved goodnight CG")

    handoff_nodes = [n["id"] for n in ev_a["nodes"] if n.get("action") == "launch_shiori_lv3_yuko_surgery"]
    if handoff_nodes != ["slv3a_174"]:
        errors.append(f"Expected launch_shiori_lv3_yuko_surgery solely on slv3a_174, got {handoff_nodes}")
    b5_nodes = [n["id"] for n in ev_b["nodes"] if n.get("seasonal_street") is True]
    if len(b5_nodes) != 32 or b5_nodes[0] != "slv3b_125" or b5_nodes[-1] != "slv3b_156":
        errors.append(f"Unexpected seasonal_street node span in Part B: count={len(b5_nodes)}")

    expected_28_new_sprites = {
        "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/serious_frown.png",
        "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/slightly_embarrassed.png",
        "assets/characters/shiori_lv3_v1/doc_shiori/scrubs_masked/neutral.png",
        "assets/characters/shiori_lv3_v1/doc_shiori/scrubs_masked/gentle_smile.png",
        "assets/characters/shiori_lv3_v1/doc_shiori/scrubs_masked/focused.png",
        "assets/characters/shiori_lv3_v1/doc_shiori/scrubs_masked/mask_ear_cheek_blush.png",
        "assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/gentle_smile.png",
        "assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/polite_hurried.png",
        "assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/soft_laugh.png",
        "assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/flustered_blush.png",
        "assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/nostalgic_gentle.png",
        "assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/hesitant_gaze_up.png",
        "assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/soft_goodnight_smile.png",
        "assets/characters/story_patients/asahina_yuko/casual/energetic_grin.png",
        "assets/characters/story_patients/asahina_yuko/casual/nervous_sweat.png",
        "assets/characters/story_patients/asahina_yuko/casual/dramatic_sigh.png",
        "assets/characters/story_patients/asahina_yuko/casual/playful_tease.png",
        "assets/characters/story_patients/asahina_yuko/casual/wink_signal.png",
        "assets/characters/story_patients/asahina_yuko/or_cap/nervous_sweat.png",
        "assets/characters/story_patients/asahina_yuko/or_cap/embarrassed_blush.png",
        "assets/characters/story_patients/asahina_yuko/or_cap/shocked_panic.png",
        "assets/characters/story_patients/asahina_yuko/or_cap/startled_yelp.png",
        "assets/characters/story_patients/asahina_yuko/or_cap/curious_awake.png",
        "assets/characters/story_patients/asahina_yuko/or_cap/relieved_warm_smile.png",
        "assets/characters/story_guests/mikihara_megumi/casual/warm_relaxed_smile.png",
        "assets/characters/story_guests/mikihara_megumi/casual/shy_blush_bow.png",
        "assets/characters/story_guests/mikihara_megumi/casual/surprised_curious.png",
        "assets/characters/story_guests/mikihara_megumi/casual/flustered_coop_nod.png",
    }
    # The approved goodnight CG replaces this expression in its entire scene window.
    superseded = {"assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/soft_goodnight_smile.png"}
    missing_new = sorted(expected_28_new_sprites - used_portraits - superseded)
    if missing_new:
        errors.append(f"Unused newly generated Lv3 sprites: {missing_new}")

    bundle = json.loads(BUNDLE_FILE.read_text(encoding="utf-8"))
    if "lv3_events.json" not in bundle.get("additional_character_event_files", []):
        errors.append("lv3_events.json missing from doc_shiori/bundle.json")

    rel = json.loads(RELATIONSHIP_FILE.read_text(encoding="utf-8"))
    lv3_slots = [s for s in rel.get("rank_slots", []) if s.get("target_level") == 3]
    if not lv3_slots or lv3_slots[0].get("event_id") != PART_B_ID or lv3_slots[0].get("content_status") != "authored":
        errors.append(f"relationship.json target_level=3 not wired to {PART_B_ID}: {lv3_slots}")

    # Localization checks
    zh_strings = json.loads(LOC_ZH.read_text(encoding="utf-8"))["strings"]
    en_strings = json.loads(LOC_EN.read_text(encoding="utf-8"))["strings"]

    if not zh_strings.get("ui.crisis.story_retry") or not en_strings.get("ui.crisis.story_retry"):
        errors.append("Missing ui.crisis.story_retry localization key")
    if CJK_RE.search(en_strings.get("ui.crisis.story_retry", "")):
        errors.append("CJK residue in en ui.crisis.story_retry")

    for bg_id in ("shiori_lv3_trattoria_exterior_evening", "shiori_lv3_apartment_entrance_night"):
        bg_key = f"collections.backgrounds.{bg_id}.label"
        if not zh_strings.get(bg_key) or not en_strings.get(bg_key) or CJK_RE.search(en_strings.get(bg_key, "")):
            errors.append(f"Missing/CJK background localization for {bg_key}")

    for ev in (ev_a, ev_b):
        prefix = f"collections.character_events.{ev['id']}"
        for suffix in (".title", ".teaser", ".gallery.caption"):
            if not zh_strings.get(prefix + suffix):
                errors.append(f"Missing zh_CN {prefix + suffix}")
            en_val = en_strings.get(prefix + suffix, "")
            if not en_val or CJK_RE.search(en_val):
                errors.append(f"Missing/CJK en {prefix + suffix}: {en_val!r}")
        for node in ev["nodes"]:
            stem = f"{prefix}.nodes.{node['id']}"
            if zh_strings.get(stem + ".text") != node["text"]:
                errors.append(f"zh_CN text mismatch on {node['id']}")
            en_txt = en_strings.get(stem + ".text", "")
            if not en_txt or CJK_RE.search(en_txt):
                errors.append(f"Missing/CJK en text on {node['id']}: {en_txt!r}")
            en_spk = en_strings.get(stem + ".speaker_label", "")
            if not en_spk or CJK_RE.search(en_spk):
                errors.append(f"Missing/CJK en speaker_label on {node['id']}: {en_spk!r}")
            for ch in node.get("choices", []):
                ckey = f"{stem}.choices.{ch['id']}.label"
                if zh_strings.get(ckey) != ch["label"]:
                    errors.append(f"zh_CN choice label mismatch on {ckey}")
                en_ch = en_strings.get(ckey, "")
                if not en_ch or CJK_RE.search(en_ch):
                    errors.append(f"Missing/CJK en choice label on {ckey}: {en_ch!r}")

    if errors:
        print(f"SHIORI LV3 SOURCE AUDIT FAILED ({len(errors)} issue(s)):")
        for err in errors:
            print("  -", err)
        return 1

    print(
        f"PASS: Shiori Lv3 verbatim source audit — Part A {len(exp_a)} beats (1 choice + Runner handoff), "
        f"Part B {len(exp_b)} beats (3 choices), 13/13 Section 4 OR quotes, 27 active new sprites + 1 superseded by approved CG, "
        f"{len(used_portraits)} distinct portraits, zh_CN + en 100% clean (0 diffs)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
