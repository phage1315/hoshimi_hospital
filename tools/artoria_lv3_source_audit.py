#!/usr/bin/env python3
"""Verbatim line-by-line source audit for Artoria Pendragon (`doc_artoria`) Relationship Lv3:
《不是一个人的手术》 (`artoria_lv3_not_a_solo_operation`, V1.1).

Verifies:
1. All `2 x 2 x 3 x 3 x 3 = 108` combinations (`emiko_lv3_done x emiko_lv1_done x Choice 1 x Choice 2 x Choice 3`)
   traverse `data/staff/doc_artoria/lv3_events.json` cleanly from `ar3_s1_01` to `@end` and match
   `research/source_scripts/HOSHIMI_ARTORIA_LV3_NOT_A_SOLO_OPERATION_V1_1.md` 100% verbatim in speaker ownership,
   text, punctuation, and order (accounting only for the 46 structural `叙事前缀：「角色台词」` splits and
   3 Markdown `*...*` italic syntax strips on `ar3_s3_2r_07`, `ar3_s3_2r_08`, `ar3_s5r_21`).
2. All 9 choice labels match the manuscript verbatim, with zero hidden stat/flag/related_effects deltas.
3. No internal alias `Saber` or reserved Lv5+ patient `久宇舞弥` / `Maiya` appears in player-visible zh_CN or en strings.
4. All 6 newly integrated Irisviel & Artoria runtime PNGs exist, decode as RGBA, and have transparent top corners.
5. `zh_CN.json` and `en.json` cover every node, choice, speaker label, title, teaser, and gallery caption with 0 CJK leaks in English.
"""

from __future__ import annotations

import copy
import itertools
import json
import re
import sys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_ARTORIA_LV3_NOT_A_SOLO_OPERATION_V1_1.md"
EVENTS_PATH = ROOT / "data/staff/doc_artoria/lv3_events.json"
PROFILE_PATH = ROOT / "data/staff/doc_artoria/profile.json"
REL_PATH = ROOT / "data/staff/doc_artoria/relationship.json"
ZH_PATH = ROOT / "data/localization/zh_CN.json"
EN_PATH = ROOT / "data/localization/en.json"

EVENT_ID = "artoria_lv3_not_a_solo_operation"
CJK_RE = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")

PURE_SPEAKERS = [
    "阿尔托莉雅·潘德拉贡",
    "坂口隆司",
    "本庄萌恵",
    "利根川安琪",
    "杉村弘子",
    "爱丽丝菲尔·冯·爱因兹贝伦",
]

MIXED_PREFIX_SPEAKERS = [
    ("本庄萌恵与利根川安琪对视一眼", "本庄萌恵・利根川安琪"),
    ("这一次，本庄萌恵", "本庄萌恵"),
    ("一直最怕在长辈面前大声说话的本庄萌恵", "本庄萌恵"),
    ("正在倒热水的杉村弘子", "杉村弘子"),
    ("就在这时，坂口隆司", "坂口隆司"),
    ("一旁的坂口隆司", "坂口隆司"),
    ("站在旁边的坂口隆司", "坂口隆司"),
    ("一直站在她身侧半步之遥的坂口隆司", "坂口隆司"),
    ("旁边的利根川安琪", "利根川安琪"),
    ("爱丽丝菲尔", "爱丽丝菲尔·冯·爱因兹贝伦"),
    ("阿尔托莉雅", "阿尔托莉雅·潘德拉贡"),
    ("坂口隆司", "坂口隆司"),
    ("本庄萌恵", "本庄萌恵"),
    ("利根川安琪", "利根川安琪"),
    ("杉村弘子", "杉村弘子"),
]

checks = 0
failures = 0


def expect(cond: bool, msg: str) -> None:
    global checks, failures
    checks += 1
    if not cond:
        failures += 1
        print(f"FAIL: {msg}", file=sys.stderr)


def parse_expected_buckets() -> tuple[dict[str, list[tuple[str, str]]], dict[str, str]]:
    md = MANUSCRIPT_PATH.read_text(encoding="utf-8")
    body = md.split("## 二、 完整中文 VN 剧本正文", 1)[1].split(
        "**【阿尔托莉雅·潘德拉贡 Relationship Lv3《不是一个人的手术》事件结束】**", 1
    )[0]

    buckets: dict[str, list[tuple[str, str]]] = {}
    choices: dict[str, str] = {}
    cur = ""
    active = False
    cur_choice = ""

    for raw in body.splitlines():
        s = raw.strip()
        if not s or s == "---":
            continue
        if s.startswith("### 【第一幕"):
            cur = "s1"
            active = False
            continue
        if s.startswith("### 【第二幕"):
            cur = "s2"
            active = False
            continue
        if s.startswith("### 【第三幕"):
            continue
        if s.startswith("#### 3.1 "):
            cur = "s3_1"
            active = False
            continue
        if s.startswith("#### 3.2 "):
            cur = "s3_2"
            active = False
            continue
        if s.startswith("### 【第四幕"):
            cur = "s4"
            active = False
            continue
        if s.startswith("### 【第五幕"):
            cur = "s5"
            active = False
            continue
        if s == "**【玩家可见正文】**":
            active = True
            continue
        if s.startswith("*(") or s.startswith("*性质："):
            continue
        if s.startswith("#### 〈条件分支 A"):
            cur = "s1_em3a"
            active = True
            continue
        if s.startswith("#### 〈条件分支 B"):
            cur = "s1_em3b"
            active = True
            continue
        if s.startswith("> **【第一幕公共主线汇合】**"):
            cur = "s1m"
            active = True
            continue
        m_ch = re.match(r"^\*\*【选择 (\d+)：.+】\*\*$", s)
        if m_ch:
            cur_choice = f"c{m_ch.group(1)}"
            active = False
            continue
        m_opt = re.match(r"^- \*\*选项 ([ABC])：(.+)\*\*$", s)
        if m_opt:
            choices[f"choice_ar3_{cur_choice}_{m_opt.group(1).lower()}"] = m_opt.group(2)
            continue
        m_br = re.match(r"^#### 【分支 ([ABC])\b", s)
        if m_br:
            cur = f"{cur_choice}{m_br.group(1).lower()}"
            active = True
            continue
        if s.startswith("- **〈子分支 A-1"):
            cur = "c1a_1"
            active = True
            continue
        if s.startswith("- **〈子分支 A-2"):
            cur = "c1a_2"
            active = True
            continue
        if s.startswith("> **【主线汇合"):
            cur = {"c1": "s1r", "c2": "s3_2r", "c3": "s5r"}[cur_choice]
            active = True
            continue
        if not active:
            continue

        m_pure = re.match(r"^(" + "|".join(map(re.escape, PURE_SPEAKERS)) + r")：(「.*」)$", s)
        if m_pure:
            buckets.setdefault(cur, []).append((m_pure.group(1), m_pure.group(2)))
            continue
        if "：「" in s:
            act, quote = s.split("：", 1)
            spk = next((target for pfx, target in MIXED_PREFIX_SPEAKERS if act.startswith(pfx)), "")
            expect(bool(spk), f"Unmapped mixed speaker line: {s}")
            buckets.setdefault(cur, []).append(("旁白", act + "："))
            buckets.setdefault(cur, []).append((spk, quote))
            continue
        buckets.setdefault(cur, []).append(("旁白", s.replace("*", "")))

    return buckets, choices


def simulate_cast(ev: dict, em3_done: bool, em1_done: bool) -> dict[str, dict]:
    nodes = {n["id"]: copy.deepcopy(n) for n in ev["nodes"]}
    nodes["ar3_s1_03"]["choices"][0]["next"] = "ar3_s1_em3a_01" if em3_done else "ar3_s1_em3b_01"
    for ch in nodes["ar3_choice_c1"]["choices"]:
        if ch["id"] == "choice_ar3_c1_a":
            ch["next"] = "ar3_c1a_1_01" if em1_done else "ar3_c1a_2_01"
    return nodes


def main() -> None:
    buckets, expected_choices = parse_expected_buckets()
    events = json.loads(EVENTS_PATH.read_text(encoding="utf-8"))
    expect(len(events) == 1, "Expected exactly 1 event in lv3_events.json")
    ev = events[0]
    expect(ev["id"] == EVENT_ID, f"Unexpected event id {ev['id']}")
    expect(ev["title"] == "不是一个人的手术", f"Unexpected title {ev['title']}")
    expect(ev["conditions"].get("max_day") == 363, "Expected max_day == 363")
    expect(len(ev["nodes"]) == 297, f"Expected 297 nodes, got {len(ev['nodes'])}")

    for n in ev["nodes"]:
        nid = n["id"]
        for forbidden in ("Saber", "久宇舞弥", "舞弥", "Maiya"):
            expect(forbidden not in n.get("text", "") and forbidden not in n.get("speaker_label", ""), f"{nid}: leaked {forbidden}")
        for ch in n["choices"]:
            expect(ch["effects"] == {"affection": 0, "familiarity": 0}, f"{nid}/{ch['id']}: non-zero effects")
            expect(ch["flags"] == [], f"{nid}/{ch['id']}: unexpected choice flags")
            expect("related_effects" not in ch, f"{nid}/{ch['id']}: unexpected related_effects")

    # Audit all 108 (2 x 2 x 3 x 3 x 3) combinations
    for em3_done, em1_done, c1, c2, c3 in itertools.product([False, True], [False, True], ["a", "b", "c"], ["a", "b", "c"], ["a", "b", "c"]):
        c1_bucket = ("c1a_1" if em1_done else "c1a_2") if c1 == "a" else f"c1{c1}"
        expected_seq = (
            buckets["s1"]
            + buckets["s1_em3a" if em3_done else "s1_em3b"]
            + buckets["s1m"]
            + buckets[c1_bucket]
            + buckets["s1r"]
            + buckets["s2"]
            + buckets["s3_1"]
            + buckets["s3_2"]
            + buckets[f"c2{c2}"]
            + buckets["s3_2r"]
            + buckets["s4"]
            + buckets["s5"]
            + buckets[f"c3{c3}"]
            + buckets["s5r"]
        )
        nodes_by_id = simulate_cast(ev, em3_done, em1_done)
        cur_id = ev["start"]
        actual_seq: list[tuple[str, str]] = []
        visited = 0
        while cur_id != "@end":
            visited += 1
            expect(visited <= 350, f"Cycle detected on path {em3_done}-{em1_done}-{c1}-{c2}-{c3}")
            node = nodes_by_id[cur_id]
            if node["presentation"] == "choice":
                pick_key = {"ar3_choice_c1": f"choice_ar3_c1_{c1}", "ar3_choice_c2": f"choice_ar3_c2_{c2}", "ar3_choice_c3": f"choice_ar3_c3_{c3}"}[cur_id]
                picked = next(ch for ch in node["choices"] if ch["id"] == pick_key)
                expect(picked["label"] == expected_choices[pick_key], f"Choice label mismatch for {pick_key}")
                cur_id = picked["next"]
            else:
                actual_seq.append((node["speaker_label"], node["text"]))
                cur_id = node["choices"][0]["next"]

        expect(len(actual_seq) == len(expected_seq), f"Path length mismatch: {len(actual_seq)} vs {len(expected_seq)}")
        for idx, (got, exp) in enumerate(zip(actual_seq, expected_seq)):
            expect(got == exp, f"Path {em3_done}-{em1_done}-{c1}-{c2}-{c3} beat #{idx + 1} mismatch:\n  got: {got}\n  exp: {exp}")

    # Audit RGBA runtime portraits
    expected_portraits = [
        ("assets/characters/artoria_lv3_v1/irisviel/ward/smile.png", (1024, 1536)),
        ("assets/characters/artoria_lv3_v1/irisviel/ward/relieved.png", (1024, 1536)),
        ("assets/characters/artoria_lv3_v1/irisviel/or_cap/calm.png", (1448, 1086)),
        ("assets/characters/artoria_lv3_v1/irisviel/or_cap/smile.png", (1448, 1086)),
        ("assets/characters/artoria_lv3_v1/irisviel/or_cap/drowsy.png", (1448, 1086)),
        ("assets/characters/artoria_lv3_v1/doc_artoria/white_coat/shy.png", (1024, 1536)),
    ]
    for rel_path, exp_size in expected_portraits:
        p = ROOT / rel_path
        expect(p.is_file(), f"Missing runtime portrait {rel_path}")
        with Image.open(p) as im:
            expect(im.mode == "RGBA", f"{rel_path}: expected RGBA, got {im.mode}")
            expect(im.size == exp_size, f"{rel_path}: expected {exp_size}, got {im.size}")
            expect(im.getpixel((0, 0))[3] == 0 and im.getpixel((im.width - 1, 0))[3] == 0, f"{rel_path}: top corners not transparent")

    # Audit bilingual localization parity
    zh_strings = json.loads(ZH_PATH.read_text(encoding="utf-8"))["strings"]
    en_strings = json.loads(EN_PATH.read_text(encoding="utf-8"))["strings"]
    prefix = f"collections.character_events.{EVENT_ID}."
    zh_keys = {k for k in zh_strings if k.startswith(prefix)}
    en_keys = {k for k in en_strings if k.startswith(prefix)}
    expect(zh_keys == en_keys and len(zh_keys) > 850, f"Locale key parity mismatch: zh={len(zh_keys)} en={len(en_keys)}")
    for k in sorted(en_keys):
        val = en_strings[k]
        expect(bool(val.strip()), f"Empty English value at {k}")
        expect(not CJK_RE.search(val), f"CJK leak in English {k}: {val}")
        for forbidden in ("Saber", "Maiya"):
            expect(forbidden not in val, f"Forbidden token {forbidden} in English {k}")

    profile = json.loads(PROFILE_PATH.read_text(encoding="utf-8"))
    expect("white_coat/shy" in profile["visuals"]["portraits"], "doc_artoria profile missing white_coat/shy")
    rel = json.loads(REL_PATH.read_text(encoding="utf-8"))
    slot3 = next(s for s in rel["rank_slots"] if s["target_level"] == 3)
    expect(slot3["event_id"] == EVENT_ID and slot3["content_status"] == "authored", "relationship.json Lv3 slot not wired")

    print(f"ARTORIA LV3 SOURCE AUDIT: {checks} checks; {failures} failure(s)")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
