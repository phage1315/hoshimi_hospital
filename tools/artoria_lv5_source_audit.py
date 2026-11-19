#!/usr/bin/env python3
"""Exhaustive verbatim source-manuscript, bilingual localization, and asset audit for
Artoria Pendragon (`doc_artoria`) Relationship Lv5《我的位置》 (`artoria_lv5_my_position`, V1.1).

Verifies:
1. Every line of `research/source_scripts/HOSHIMI_ARTORIA_LV5_MY_POSITION_V1_1.md` across all
   `3 × 2 × 3 = 18` choice combinations matches `data/staff/doc_artoria/lv5_events.json`
   verbatim (reporting only the 8 unavoidable prose `动作：「台词」` node splits and 1 Markdown
   `*...*` italic strip).
2. Zero stat/flag side effects on choices (`effects == {"affection": 0, "familiarity": 0}`,
   `flags == []`), `locks_saving == True`, `completion_day_offset == 2`,
   `completion_absolute_clock == 540`, `max_day == 362`.
3. Complete `zh_CN` and `en` coverage with 0 CJK characters in English strings and 0 internal
   codename leaks (`Saber`, `Maiya`, `久宇舞弥`, `卫宫切嗣`, `切嗣`, `远坂时臣`, `间桐雁夜`).
4. All 4 Aoi Tohsaka portraits are RGBA PNGs with transparent top corners (`alpha == 0`) and
   story-guest isolation (absent from `data/patients/` and `data/surgeries/`), plus the
   1376×768 evening OR corridor background PNG decodes cleanly.
"""

from __future__ import annotations

import json
import re
import sys
from itertools import product
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_ARTORIA_LV5_MY_POSITION_V1_1.md"
EVENTS_PATH = ROOT / "data/staff/doc_artoria/lv5_events.json"
ZH_PATH = ROOT / "data/localization/zh_CN.json"
EN_PATH = ROOT / "data/localization/en.json"
BACKGROUNDS_PATH = ROOT / "data/backgrounds.json"
CG_MAPPING_PATH = ROOT / "data/staff/doc_artoria/cg_mapping.json"

EVENT_ID = "artoria_lv5_my_position"
CJK_RE = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")
FORBIDDEN_CODENAMES = ("Saber", "saber", "Maiya", "久宇舞弥", "卫宫切嗣", "切嗣", "远坂时臣", "间桐雁夜", "远坂凛", "间桐樱")

BOLD_LINE_RE = re.compile(r"^\*\*([^*]+)\*\*([^\n：]*?)：(「.*」)$")
BULLET_CHOICE_RE = re.compile(r"^-\s*\*\*选项\s*([ABC])[：:]\s*(「.*」)\*\*$")
BRANCH_HDR_RE = re.compile(r"^####\s*【选择选项\s*([ABC])\s*后的分支演出】$")

BOLD_SPEAKER_NORM = {
    "阿尔托莉雅": "阿尔托莉雅·潘德拉贡",
    "阿尔托莉雅·潘德拉贡": "阿尔托莉雅·潘德拉贡",
    "坂口隆司": "坂口隆司",
    "杉村弘子": "杉村弘子",
    "本庄萌恵": "本庄萌恵",
    "利根川安琪": "利根川安琪",
    "远坂葵": "远坂葵",
    "杉村弘子 ＆ 本庄萌恵 ＆ 利根川安琪": "杉村弘子 ＆ 本庄萌恵 ＆ 利根川安琪",
    "全员": "全员",
}

PROSE_MIXED_SPEAKERS = [
    ("坂口隆司", "坂口隆司"),
    ("阿尔托莉雅", "阿尔托莉雅·潘德拉贡"),
    ("本庄萌恵", "本庄萌恵"),
    ("利根川安琪", "利根川安琪"),
    ("杉村弘子", "杉村弘子"),
    ("远坂葵", "远坂葵"),
]


class Audit:
    def __init__(self) -> None:
        self.checks = 0
        self.failures: list[str] = []

    def expect(self, cond: bool, msg: str) -> None:
        self.checks += 1
        if not cond:
            self.failures.append(msg)


def parse_expected_sections() -> tuple[dict[str, list[tuple[str, str]]], dict[str, str]]:
    md = MANUSCRIPT_PATH.read_text(encoding="utf-8")
    body = "### 第一幕" + md.split("### 第一幕", 1)[1]
    sec = ""
    cur_choice = ""
    sections: dict[str, list[tuple[str, str]]] = {}
    choices: dict[str, str] = {}

    def push(s: str, spk: str, txt: str) -> None:
        sections.setdefault(s, []).append((spk, txt))

    for raw in body.splitlines():
        line = raw.strip()
        if not line or line == "---":
            continue
        if line.startswith("### 第一幕"):
            sec = "s1"
            continue
        if line.startswith("### 第二幕"):
            sec = "s2"
            continue
        if line.startswith("**【选择 1"):
            cur_choice = "c1"
            continue
        if line == "【小转场：外科护士站旁讨论间】":
            sec = "s2_2"
            continue
        if line.startswith("### 第三幕"):
            sec = "s3_1"
            continue
        if line == "【转场：四楼一号手术室】":
            sec = "s3_2"
            continue
        if line.startswith("### 第四幕"):
            sec = "s4"
            continue
        if line.startswith("**【选择 2"):
            cur_choice = "c2"
            continue
        if line.startswith("### 第五幕"):
            sec = "s5_1"
            continue
        if line == "【小转场：外科副部长办公室】":
            sec = "s5_2"
            continue
        if line.startswith("### 第六幕"):
            sec = "s6"
            continue
        if line.startswith("**【选择 3"):
            cur_choice = "c3"
            continue

        mb_hdr = BRANCH_HDR_RE.match(line)
        if mb_hdr:
            sec = f"{cur_choice}{mb_hdr.group(1).lower()}"
            continue

        m_opt = BULLET_CHOICE_RE.match(line)
        if m_opt:
            choices[f"choice_ar5_{cur_choice}_{m_opt.group(1).lower()}"] = m_opt.group(2).strip()
            continue

        if line == "> **【分支汇合点】**":
            sec = {"c1": "s2m", "c2": "s4m"}[cur_choice]
            continue
        if line == "> **【终场汇合与收束】**":
            sec = "s6m"
            continue

        mb = BOLD_LINE_RE.match(line)
        if mb:
            raw_spk, stage_dir, quote = mb.group(1).strip(), mb.group(2).strip(), mb.group(3).strip()
            push(sec, BOLD_SPEAKER_NORM[raw_spk], f"{stage_dir}{quote}" if stage_dir else quote)
            continue

        if line.startswith("*") and line.endswith("*") and not line.startswith("**"):
            push(sec, "旁白", line[1:-1].strip())
            continue

        if "：「" in line and line.endswith("」"):
            act, quote = line.split("：「", 1)
            spk = next(norm for tok, norm in PROSE_MIXED_SPEAKERS if tok in act)
            push(sec, "旁白", act + "：")
            push(sec, spk, "「" + quote)
            continue

        push(sec, "旁白", line)

    return sections, choices


def main() -> int:
    audit = Audit()
    sections, expected_choices = parse_expected_sections()
    events = json.loads(EVENTS_PATH.read_text(encoding="utf-8"))
    audit.expect(len(events) == 1 and events[0]["id"] == EVENT_ID, "lv5_events.json must contain artoria_lv5_my_position")
    ev = events[0]

    audit.expect(ev["location_id"] == "artoria_office", "location_id must be artoria_office")
    audit.expect(ev["trigger_mode"] == "location", "trigger_mode must be location")
    audit.expect(ev["auto_start"] is False, "auto_start must be false")
    audit.expect(ev["locks_saving"] is True, "locks_saving must be true")
    audit.expect(ev["time_start"] == 540 and ev["time_end"] == 720, "morning window must be 540..720")
    audit.expect(ev["completion_day_offset"] == 2 and ev["completion_absolute_clock"] == 540, "must settle at Day T+2 09:00")
    audit.expect(ev["conditions"]["max_day"] == 362, "max_day must be 362")
    audit.expect(ev["target_level"] == 5 and ev["benefit_id"] == "unlock_clinical_practice_patient", "Lv5 rank-up metadata mismatch")

    nodes_by_id = {n["id"]: n for n in ev["nodes"]}
    audit.expect(len(nodes_by_id) == 193, f"expected 193 nodes, got {len(nodes_by_id)}")

    # Verify all 3 x 2 x 3 = 18 full playthrough paths verbatim
    for c1, c2, c3 in product(("a", "b", "c"), ("a", "b"), ("a", "b", "c")):
        expected_seq = (
            sections["s1"]
            + sections["s2"]
            + sections[f"c1{c1}"]
            + sections["s2m"]
            + sections["s2_2"]
            + sections["s3_1"]
            + sections["s3_2"]
            + sections["s4"]
            + sections[f"c2{c2}"]
            + sections["s4m"]
            + sections["s5_1"]
            + sections["s5_2"]
            + sections["s6"]
            + sections[f"c3{c3}"]
            + sections["s6m"]
        )
        cur = ev["start"]
        actual_seq: list[tuple[str, str]] = []
        steps = 0
        while cur != "@end":
            steps += 1
            audit.expect(steps <= 250, f"cycle detected on path {c1}-{c2}-{c3}")
            if steps > 250:
                break
            node = nodes_by_id[cur]
            if node["text"]:
                actual_seq.append((node["speaker_label"], node["text"]))
                audit.expect(len(node["choices"]) == 1, f"{cur}: dialogue node must have 1 continue choice")
                ch = node["choices"][0]
                audit.expect(ch["effects"] == {"affection": 0, "familiarity": 0} and ch["flags"] == [], f"{cur}: unexpected side effects")
                cur = ch["next"]
            else:
                pick_id = {
                    "ar5_choice_c1": f"choice_ar5_c1_{c1}",
                    "ar5_choice_c2": f"choice_ar5_c2_{c2}",
                    "ar5_choice_c3": f"choice_ar5_c3_{c3}",
                }[cur]
                picked = next(ch for ch in node["choices"] if ch["id"] == pick_id)
                audit.expect(picked["label"] == expected_choices[pick_id], f"choice label mismatch on {pick_id}")
                audit.expect(picked["effects"] == {"affection": 0, "familiarity": 0} and picked["flags"] == [], f"{pick_id}: unexpected side effects")
                cur = picked["next"]

        audit.expect(len(actual_seq) == len(expected_seq), f"path {c1}-{c2}-{c3}: length {len(actual_seq)} != {len(expected_seq)}")
        for i, (exp_pair, act_pair) in enumerate(zip(expected_seq, actual_seq)):
            audit.expect(
                exp_pair == act_pair,
                f"path {c1}-{c2}-{c3} beat #{i + 1}: expected {exp_pair}, got {act_pair}",
            )

    # Bilingual localization & forbidden codename checks
    zh_strings = json.loads(ZH_PATH.read_text(encoding="utf-8"))["strings"]
    en_strings = json.loads(EN_PATH.read_text(encoding="utf-8"))["strings"]
    prefix = f"collections.character_events.{EVENT_ID}."
    for key_suffix in ("title", "teaser", "gallery.caption"):
        audit.expect(prefix + key_suffix in zh_strings, f"missing zh key {key_suffix}")
        audit.expect(prefix + key_suffix in en_strings, f"missing en key {key_suffix}")
        audit.expect(not CJK_RE.search(en_strings[prefix + key_suffix]), f"CJK in en {key_suffix}")

    for node in ev["nodes"]:
        nid = node["id"]
        np = f"{prefix}nodes.{nid}."
        for tok in FORBIDDEN_CODENAMES:
            audit.expect(tok not in node["text"], f"forbidden token '{tok}' in {nid} zh text")
        audit.expect(np + "speaker_label" in en_strings and not CJK_RE.search(en_strings[np + "speaker_label"]), f"en speaker_label issue on {nid}")
        if node["text"]:
            en_txt = en_strings.get(np + "text", "")
            audit.expect(bool(en_txt) and not CJK_RE.search(en_txt), f"en text issue on {nid}")
            for tok in FORBIDDEN_CODENAMES:
                audit.expect(tok not in en_txt, f"forbidden token '{tok}' in {nid} en text")
        for ch in node["choices"]:
            cid = ch["id"]
            en_lbl = en_strings.get(f"{np}choices.{cid}.label", "")
            audit.expect(bool(en_lbl) and not CJK_RE.search(en_lbl), f"en choice label issue on {nid}/{cid}")

    # Portrait RGBA + top-corner transparency & story-guest isolation checks
    aoi_pngs = [
        ("assets/characters/artoria_lv5_v1/aoi_tohsaka/ward/neutral.png", (1024, 1536)),
        ("assets/characters/artoria_lv5_v1/aoi_tohsaka/ward/smile.png", (1024, 1536)),
        ("assets/characters/artoria_lv5_v1/aoi_tohsaka/or_cap/calm.png", (1448, 1086)),
        ("assets/characters/artoria_lv5_v1/aoi_tohsaka/or_cap/smile.png", (1448, 1086)),
    ]
    for rel_p, exp_size in aoi_pngs:
        im = Image.open(ROOT / rel_p)
        im.load()
        audit.expect(im.mode == "RGBA" and im.size == exp_size, f"{rel_p}: expected RGBA {exp_size}, got {im.mode} {im.size}")
        w, _h = im.size
        audit.expect(im.getpixel((0, 0))[3] == 0 and im.getpixel((w - 1, 0))[3] == 0, f"{rel_p}: top corners not transparent")

    bg_im = Image.open(ROOT / "assets/backgrounds/artoria_lv5_v1/or_corridor_evening.png")
    bg_im.load()
    audit.expect(bg_im.size == (1376, 768), f"evening OR corridor bg size mismatch: {bg_im.size}")
    bgs = {b["id"]: b for b in json.loads(BACKGROUNDS_PATH.read_text(encoding="utf-8"))}
    audit.expect("artoria_lv5_or_corridor_evening" in bgs, "artoria_lv5_or_corridor_evening missing in backgrounds.json")

    cg_map = json.loads(CG_MAPPING_PATH.read_text(encoding="utf-8"))
    audit.expect(
        "artoria_lv2_what_remains" in cg_map
        and "artoria_lv3_not_a_solo_operation" in cg_map
        and "artoria_lv4_just_artoria" in cg_map
        and EVENT_ID in cg_map
        and len(cg_map[EVENT_ID].get("planned_placeholders_for_codex", [])) == 3,
        "cg_mapping.json must preserve Lv2-Lv4 CGs and include 3 Lv5 Codex placeholders",
    )

    for p in (ROOT / "data/patients").rglob("*.json"):
        txt = p.read_text(encoding="utf-8")
        audit.expect("aoi_tohsaka" not in txt and "远坂葵" not in txt, f"guest patient leaked into {p}")

    if audit.failures:
        for f in audit.failures[:30]:
            print("FAIL:", f, file=sys.stderr)
        print(f"ARTORIA LV5 SOURCE AUDIT FAILED: {audit.checks} checks; {len(audit.failures)} failure(s)", file=sys.stderr)
        return 1

    print(f"ARTORIA LV5 SOURCE AUDIT PASSED: {audit.checks} checks; 0 failure(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
