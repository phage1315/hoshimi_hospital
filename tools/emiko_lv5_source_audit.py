#!/usr/bin/env python3
"""Exhaustive verbatim source-manuscript, bilingual localization, and asset audit for
Emiko Mido (`doc_emiko`) Relationship Lv5《神的双手》 (`emiko_lv5_hands_of_god`, V1.0).

Verifies:
1. Every line of `research/source_scripts/HOSHIMI_MIDO_EMIKO_LV5_HANDS_OF_GOD_V1_0.md` across all
   `2 × 2 × 2 × 2 = 16` choice combinations matches `data/staff/doc_emiko/lv5_events.json`
   100% verbatim (accounting solely for the 5 unavoidable `动作：「台词」` node splits, 4 inline
   `**` emphasis strips, and 1 outer `*...*` italic syntax strip).
2. Zero stat/flag side effects on choices (`effects == {"affection": 0, "familiarity": 0}`,
   `flags == []`), `locks_saving == True`, `completion_day_offset == 1`,
   `completion_absolute_clock == 540`, `max_day == 363`, `completion_story_flags == ["emiko_lv5_complete"]`
   (zero Chief-of-Surgery competition boolean flags).
3. Complete `zh_CN` and `en` coverage with 0 CJK characters in English strings and 0 raw `**`
   asterisks in Chinese or English strings.
4. All 4 Haruko Takase & Naomi Miyahara portraits exist as RGBA PNGs with transparent top corners
   (`alpha == 0`), `.png.import` `mipmaps/generate=true`, and strict story-guest isolation
   (absent from `data/patients/` and `data/surgeries/`).
"""

from __future__ import annotations

import json
import re
import sys
from itertools import product
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_MIDO_EMIKO_LV5_HANDS_OF_GOD_V1_0.md"
EVENTS_PATH = ROOT / "data/staff/doc_emiko/lv5_events.json"
ZH_PATH = ROOT / "data/localization/zh_CN.json"
EN_PATH = ROOT / "data/localization/en.json"
CG_MAPPING_PATH = ROOT / "data/staff/doc_emiko/cg_mapping.json"

EVENT_ID = "emiko_lv5_hands_of_god"
CJK_RE = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")
BOLD_LINE_RE = re.compile(r"^\*\*([^*]+)\*\*([^\n：]*?)：(「.*」)$")
BULLET_CHOICE_RE = re.compile(r"^-\s*\*\*选项\s*([ABC])[：:]\s*(「.*」)\*\*$")
BRANCH_HDR_RE = re.compile(r"^####\s*【选择选项\s*([ABC])\s*后的分支演出】$")

PROSE_MIXED_SPEAKERS = [
    ("杉村弘子", "杉村弘子"),
    ("值班麻醉医师", "值班麻醉医师"),
    ("晴子", "高瀬晴子"),
    ("高瀬晴子", "高瀬晴子"),
    ("坂口隆司", "坂口隆司"),
]

PATIENT_SPRITES = {
    "assets/characters/emiko_lv5_v1/haruko_takase/casual/neutral.png": (1024, 1536),
    "assets/characters/emiko_lv5_v1/haruko_takase/casual/smile.png": (1024, 1536),
    "assets/characters/emiko_lv5_v1/haruko_takase/casual/afraid.png": (1024, 1536),
    "assets/characters/emiko_lv5_v1/haruko_takase/ward/neutral.png": (1024, 1536),
    "assets/characters/emiko_lv5_v1/haruko_takase/ward/smile.png": (1024, 1536),
    "assets/characters/emiko_lv5_v1/haruko_takase/ward/shy.png": (1024, 1536),
    "assets/characters/emiko_lv5_v1/haruko_takase/ward/pain.png": (1024, 1536),
    "assets/characters/emiko_lv5_v1/haruko_takase/or_cap/calm.png": (1448, 1086),
    "assets/characters/emiko_lv5_v1/haruko_takase/or_cap/afraid.png": (1448, 1086),
    "assets/characters/emiko_lv5_v1/naomi_miyahara/ward/neutral.png": (1024, 1536),
    "assets/characters/emiko_lv5_v1/naomi_miyahara/ward/smile.png": (1024, 1536),
    "assets/characters/emiko_lv5_v1/naomi_miyahara/or_cap/calm.png": (1448, 1086),
    "assets/characters/emiko_lv5_v1/naomi_miyahara/or_cap/smile.png": (1448, 1086),
}


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
    body = md.split("## 一、 完整中文 VN 剧本正文（第一至六幕）\n", 1)[1].split("\n## 二、 附表 1：六幕 Scene / Beat 索引表", 1)[0]

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
            sec = "s1_1"
            continue
        if line == "【简短回忆切入：半年前·外科门诊咨询室】":
            sec = "s1_2"
            continue
        if line == "【回忆结束：回到外科医长办公室】":
            sec = "s1_3"
            continue
        if line.startswith("**【选择 1"):
            cur_choice = "c1"
            continue
        if line.startswith("### 第二幕"):
            sec = "s2"
            continue
        if line.startswith("**【选择 2"):
            cur_choice = "c2"
            continue
        if line.startswith("### 第三幕"):
            sec = "s3"
            continue
        if line.startswith("### 第四幕"):
            sec = "s4_1"
            continue
        if line == "【镜头切入：一号手术室（供者侧）】":
            sec = "s4_2"
            continue
        if line == "【镜头切入：二号手术室（受者侧）】":
            sec = "s4_3"
            continue
        if line.startswith("### 第五幕"):
            sec = "s5_1"
            continue
        if line == "【一号手术室·短暂切入】":
            sec = "s5_1"
            continue
        if line == "【回到二号手术室：受者侧核心重建】":
            sec = "s5_2"
            continue
        if line.startswith("**【选择 3"):
            cur_choice = "c3"
            continue
        if line.startswith("### 第六幕"):
            sec = "s6_1"
            continue
        if line.startswith("走出病房轻轻掩上门"):
            sec = "s6_2"
        if line.startswith("**【选择 4"):
            cur_choice = "c4"
            continue

        if (
            line.startswith("**【场景】**")
            or line.startswith("**【时间】**")
            or line.startswith("**【在场角色】**")
            or line.startswith("**【服装与可视状态】**")
            or line.startswith("- **分流走廊：**")
            or line.startswith("- **一号手术室")
            or line.startswith("- **二号手术室")
            or line.startswith("- 开场时坂口")
            or line.startswith("- 随后御堂褪去")
            or line.startswith("*选项说明：")
            or line.startswith("> **【剧本终场结算锚点")
            or line.startswith("> - ")
        ):
            continue

        mb_hdr = BRANCH_HDR_RE.match(line)
        if mb_hdr:
            sec = f"{cur_choice}{mb_hdr.group(1).lower()}"
            continue
        m_opt = BULLET_CHOICE_RE.match(line)
        if m_opt:
            choices[f"choice_em5_{cur_choice}_{m_opt.group(1).lower()}"] = m_opt.group(2).strip()
            continue
        if line == "> **【分支汇合点】**":
            sec = {"c1": "s1m", "c2": "s2m", "c3": "s5m"}[cur_choice]
            continue
        if line == "> **【终场汇合与收束】**":
            sec = "s6m"
            continue

        mb = BOLD_LINE_RE.match(line)
        if mb:
            raw_spk, stage_dir, quote = mb.group(1).strip(), mb.group(2).strip(), mb.group(3).strip()
            push(sec, raw_spk, f"{stage_dir}{quote}" if stage_dir else quote)
            continue
        if line.startswith("*") and line.endswith("*") and not line.startswith("**"):
            push(sec, "旁白", line[1:-1].strip())
            continue
        line = line.replace("**", "")
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
    audit.expect(len(events) == 1 and events[0]["id"] == EVENT_ID, "lv5_events.json must contain emiko_lv5_hands_of_god")
    ev = events[0]

    audit.expect(ev["location_id"] == "emiko_office", "location_id must be emiko_office")
    audit.expect(ev["trigger_mode"] == "after_work", "trigger_mode must be after_work")
    audit.expect(ev["auto_start"] is True, "auto_start must be true")
    audit.expect(ev["locks_saving"] is True, "locks_saving must be true")
    audit.expect(ev["time_start"] == 960 and ev["time_end"] == 1320, "after_work window must be 960..1320")
    audit.expect(ev["completion_day_offset"] == 1 and ev["completion_absolute_clock"] == 540, "must settle at Day T+1 09:00")
    audit.expect(ev["conditions"]["max_day"] == 363, "max_day must be 363")
    audit.expect(ev["target_level"] == 5 and ev["benefit_id"] == "unlock_clinical_practice_patient", "Lv5 rank-up metadata mismatch")
    audit.expect(ev["completion_story_flags"] == ["emiko_lv5_complete"], "must set only emiko_lv5_complete (zero chief flags)")

    nodes_by_id = {n["id"]: n for n in ev["nodes"]}
    audit.expect(len(nodes_by_id) == 321, f"expected 321 nodes, got {len(nodes_by_id)}")

    # Verify all 2^4 = 16 full playthrough paths verbatim
    for c1, c2, c3, c4 in product(("a", "b"), ("a", "b"), ("a", "b"), ("a", "b")):
        expected_seq = (
            sections["s1_1"]
            + sections["s1_2"]
            + sections["s1_3"]
            + sections[f"c1{c1}"]
            + sections["s1m"]
            + sections["s2"]
            + sections[f"c2{c2}"]
            + sections["s2m"]
            + sections["s3"]
            + sections["s4_1"]
            + sections["s4_2"]
            + sections["s4_3"]
            + sections["s5_1"]
            + sections["s5_2"]
            + sections[f"c3{c3}"]
            + sections["s5m"]
            + sections["s6_1"]
            + sections["s6_2"]
            + sections[f"c4{c4}"]
            + sections["s6m"]
        )
        cur = ev["start"]
        actual_seq: list[tuple[str, str]] = []
        steps = 0
        while cur != "@end":
            steps += 1
            audit.expect(steps <= 400, f"cycle detected on path {c1}-{c2}-{c3}-{c4}")
            if steps > 400:
                break
            node = nodes_by_id[cur]
            if node["text"]:
                actual_seq.append((node["speaker_label"], node["text"]))
                audit.expect("**" not in node["text"], f"{cur}: raw markdown ** found in text")
                audit.expect(len(node["choices"]) == 1, f"{cur}: dialogue node must have 1 continue choice")
                ch = node["choices"][0]
                audit.expect(ch["effects"] == {"affection": 0, "familiarity": 0} and ch["flags"] == [], f"{cur}: unexpected side effects")
                cur = ch["next"]
            else:
                pick_id = {
                    "em5_choice_c1": f"choice_em5_c1_{c1}",
                    "em5_choice_c2": f"choice_em5_c2_{c2}",
                    "em5_choice_c3": f"choice_em5_c3_{c3}",
                    "em5_choice_c4": f"choice_em5_c4_{c4}",
                }[cur]
                picked = next(ch for ch in node["choices"] if ch["id"] == pick_id)
                audit.expect(picked["label"] == expected_choices[pick_id], f"choice label mismatch on {pick_id}")
                audit.expect(picked["effects"] == {"affection": 0, "familiarity": 0} and picked["flags"] == [], f"{pick_id}: unexpected side effects")
                cur = picked["next"]

        audit.expect(len(actual_seq) == len(expected_seq), f"path {c1}-{c2}-{c3}-{c4}: length {len(actual_seq)} != {len(expected_seq)}")
        for i, (exp_pair, act_pair) in enumerate(zip(expected_seq, actual_seq)):
            audit.expect(
                exp_pair == act_pair,
                f"path {c1}-{c2}-{c3}-{c4} beat #{i + 1}: expected {exp_pair}, got {act_pair}",
            )

    # Bilingual localization checks
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
        audit.expect(np + "speaker_label" in zh_strings and np + "speaker_label" in en_strings, f"{nid}: missing speaker_label locale")
        audit.expect(not CJK_RE.search(en_strings[np + "speaker_label"]), f"{nid}: CJK in en speaker_label")
        if node["text"]:
            audit.expect(zh_strings.get(np + "text") == node["text"], f"{nid}: zh text mismatch")
            en_txt = en_strings.get(np + "text", "")
            audit.expect(bool(en_txt), f"{nid}: empty en text")
            audit.expect(not CJK_RE.search(en_txt), f"{nid}: CJK in en text: {en_txt}")
            audit.expect("**" not in en_txt, f"{nid}: raw ** in en text")
        for ch in node["choices"]:
            cid = ch["id"]
            ck = f"{np}choices.{cid}.label"
            audit.expect(ck in zh_strings and ck in en_strings, f"{nid}/{cid}: missing choice locale")
            audit.expect(not CJK_RE.search(en_strings[ck]), f"{nid}/{cid}: CJK in en choice")
        for portrait in node.get("event_portraits", []):
            audit.expect((ROOT / portrait["path"]).is_file(), f"{nid}: missing portrait file {portrait['path']}")

    # Patient RGBA & pool-isolation checks
    for rel_path, expected_size in PATIENT_SPRITES.items():
        fp = ROOT / rel_path
        audit.expect(fp.is_file(), f"missing sprite {rel_path}")
        if fp.is_file():
            im = Image.open(fp)
            audit.expect(im.mode == "RGBA" and im.size == expected_size, f"{rel_path}: mode={im.mode} size={im.size}")
            audit.expect(im.getpixel((0, 0))[3] == 0 and im.getpixel((im.width - 1, 0))[3] == 0, f"{rel_path}: top corners not transparent")
            imp = Path(str(fp) + ".import")
            audit.expect(imp.is_file() and "mipmaps/generate=true" in imp.read_text(encoding="utf-8"), f"{rel_path}: mipmaps/generate=true missing")

    for pool_dir in ("data/patients", "data/surgeries"):
        for jf in (ROOT / pool_dir).rglob("*.json"):
            raw_txt = jf.read_text(encoding="utf-8")
            audit.expect("haruko_takase" not in raw_txt and "naomi_miyahara" not in raw_txt, f"story guest leaked into {jf}")

    cg_map = json.loads(CG_MAPPING_PATH.read_text(encoding="utf-8"))
    audit.expect(EVENT_ID in cg_map and len(cg_map[EVENT_ID].get("planned_placeholders_for_codex", [])) == 3, "cg_mapping.json placeholders missing")
    scenes = cg_map[EVENT_ID].get("scenes", [])
    cover_path = cg_map[EVENT_ID].get("cover", "")
    audit.expect(len(scenes) == 7, f"expected 7 CG scenes in cg_mapping.json, got {len(scenes)}")
    audit.expect(cover_path == "assets/events/emiko_lv5_cg_v1/corridor_lapel.png", f"unexpected cover CG {cover_path}")
    audit.expect(ev["gallery"]["path"] == cover_path and ev["gallery"]["show_on_complete"] is True, "event gallery cover / show_on_complete mismatch")

    assets_manifest = json.loads((ROOT / "data/staff/doc_emiko/assets_manifest.json").read_text(encoding="utf-8"))
    manifest_by_path = {a["path"]: a for a in assets_manifest.get("assets", []) if a.get("path")}
    mapped_node_ids: set[str] = set()
    for sc in scenes:
        cg_rel = sc["path"]
        cg_fp = ROOT / cg_rel
        audit.expect(cg_fp.is_file(), f"missing CG file {cg_rel}")
        if cg_fp.is_file():
            cg_im = Image.open(cg_fp)
            audit.expect(cg_im.mode == "RGB" and cg_im.size == (1536, 1024), f"{cg_rel}: mode={cg_im.mode} size={cg_im.size}")
            cg_imp = Path(str(cg_fp) + ".import")
            audit.expect(cg_imp.is_file(), f"{cg_rel}: .import file missing")
        am_entry = manifest_by_path.get(cg_rel, {})
        audit.expect(am_entry.get("runtime_connected") is True and am_entry.get("status") == "integrated", f"{cg_rel}: missing or unintegrated in assets_manifest.json")
        for nid in sc["nodes"]:
            mapped_node_ids.add(nid)
            n = nodes_by_id.get(nid, {})
            audit.expect(n.get("cg_path") == cg_rel and n.get("cg_fit") == "contain", f"{nid}: CG path/fit mismatch")
            audit.expect(not n.get("hide_portrait", False) and not n.get("portrait_path", ""), f"{nid}: CG node cannot keep hide_portrait or portrait_path")
    audit.expect(len(mapped_node_ids) == 45, f"expected 45 CG-mapped nodes, got {len(mapped_node_ids)}")

    print(f"EMIKO LV5 SOURCE AUDIT: {audit.checks} checks; {len(audit.failures)} failure(s)")
    for f in audit.failures[:25]:
        print("  FAIL:", f)
    return 1 if audit.failures else 0


if __name__ == "__main__":
    sys.exit(main())
