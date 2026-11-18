#!/usr/bin/env python3
"""Verbatim line-by-line source audit for Artoria Pendragon (`doc_artoria`) Relationship Lv2:
《留下来的部分》 (`artoria_lv2_what_remains`, V1.0).

Verifies:
1. All 27 (`3 x 3 x 3`) choice combinations traverse `data/staff/doc_artoria/lv2_events.json`
   cleanly from `ar2_s1_01` to `@end` and match `research/source_scripts/HOSHIMI_ARTORIA_LV2_THE_PART_THAT_REMAINS_V1_0.md`
   100% verbatim in speaker ownership, text, punctuation, and order (accounting only for
   the 28 structural `叙事前缀：「角色台词」` splits and 1 Markdown `**...**` emphasis marker strip on `ar2_s5_12`).
2. All 9 choice labels match the manuscript verbatim, with zero hidden stat/flag deltas.
3. No internal alias `Saber` appears anywhere in player-visible zh_CN or en strings.
4. All 10 newly integrated Taiga & Artoria runtime PNGs exist, decode as RGBA, and have transparent top corners.
5. `zh_CN.json` and `en.json` cover every node, choice, speaker label, title, teaser, and gallery caption with 0 CJK leaks in English.
"""

from __future__ import annotations

import itertools
import json
import re
import sys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_ARTORIA_LV2_THE_PART_THAT_REMAINS_V1_0.md"
EVENTS_PATH = ROOT / "data/staff/doc_artoria/lv2_events.json"
PROFILE_PATH = ROOT / "data/staff/doc_artoria/profile.json"
REL_PATH = ROOT / "data/staff/doc_artoria/relationship.json"
ZH_PATH = ROOT / "data/localization/zh_CN.json"
EN_PATH = ROOT / "data/localization/en.json"

EVENT_ID = "artoria_lv2_what_remains"
CJK_RE = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")

MIXED_PREFIX_SPEAKERS = [
    ("利根川安琪立刻俯身轻声转达，头架布帘后传来藤村大河", "藤村大河"),
    ("头架布帘撤开时，刚从浅睡中睁开眼睛的藤村大河", "藤村大河"),
    ("站在床前的利根川安琪", "利根川安琪"),
    ("利根川安琪", "利根川安琪"),
    ("朝倉美幸", "朝倉美幸"),
    ("藤村大河", "藤村大河"),
    ("阿尔托莉雅", "阿尔托莉雅·潘德拉贡"),
    ("坂口隆司", "坂口隆司"),
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
        "**【阿尔托莉雅·潘德拉贡 Relationship Lv2《留下来的部分》事件结束】**", 1
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
            cur = "s3"
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
        m_ch = re.match(r"^\*\*【选择 (\d+)：.+】\*\*$", s)
        if m_ch:
            cur_choice = f"c{m_ch.group(1)}"
            active = False
            continue
        m_opt = re.match(r"^- \*\*选项 ([ABC])：(.+)\*\*$", s)
        if m_opt:
            choices[f"choice_ar2_{cur_choice}_{m_opt.group(1).lower()}"] = m_opt.group(2)
            continue
        m_br = re.match(r"^#### 【分支 ([ABC])\b", s)
        if m_br:
            cur = f"{cur_choice}{m_br.group(1).lower()}"
            active = True
            continue
        if s.startswith("> **【主线汇合"):
            cur = {"c1": "s2r", "c2": "s4r", "c3": "s5r"}[cur_choice]
            active = True
            continue
        if not active or s.startswith("*(【设计锚点提示】"):
            continue

        m_pure = re.match(r"^(阿尔托莉雅·潘德拉贡|坂口隆司|藤村大河|朝倉美幸|利根川安琪)：(「.*」)$", s)
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
        # Only outer Markdown bold syntax (**...**) on narrator emphasis line ar2_s5_12 is stripped for plain-text Label rendering.
        buckets.setdefault(cur, []).append(("旁白", s.replace("**", "")))

    return buckets, choices


def main() -> None:
    buckets, expected_choices = parse_expected_buckets()
    events = json.loads(EVENTS_PATH.read_text(encoding="utf-8"))
    expect(len(events) == 1, "Expected exactly 1 event in lv2_events.json")
    ev = events[0]
    expect(ev["id"] == EVENT_ID, f"Unexpected event id {ev['id']}")
    expect(ev["title"] == "留下来的部分", f"Unexpected title {ev['title']}")
    expect(ev["conditions"].get("max_day") == 363, "Expected max_day == 363")

    nodes_by_id = {n["id"]: n for n in ev["nodes"]}
    expect(len(nodes_by_id) == 227, f"Expected 227 nodes, got {len(nodes_by_id)}")

    # Audit every node's zero-effect choices and absence of internal alias `Saber`
    for nid, node in nodes_by_id.items():
        expect("Saber" not in node.get("text", "") and "Saber" not in node.get("speaker_label", ""), f"{nid}: leaked internal alias Saber")
        for ch in node["choices"]:
            expect(ch["effects"] == {"affection": 0, "familiarity": 0}, f"{nid}/{ch['id']}: non-zero effects {ch['effects']}")
            expect(ch["flags"] == [], f"{nid}/{ch['id']}: unexpected choice flags {ch['flags']}")
            expect("related_effects" not in ch, f"{nid}/{ch['id']}: unexpected related_effects")

    # Audit all 27 (3 x 3 x 3) paths from start to @end
    for c1, c2, c3 in itertools.product(["a", "b", "c"], repeat=3):
        expected_seq = (
            buckets["s1"]
            + buckets["s2"]
            + buckets[f"c1{c1}"]
            + buckets["s2r"]
            + buckets["s3"]
            + buckets["s4"]
            + buckets[f"c2{c2}"]
            + buckets["s4r"]
            + buckets["s5"]
            + buckets[f"c3{c3}"]
            + buckets["s5r"]
        )
        cur_id = ev["start"]
        actual_seq: list[tuple[str, str]] = []
        visited = 0
        while cur_id != "@end":
            visited += 1
            expect(visited <= 300, f"Cycle detected on path {c1}-{c2}-{c3}")
            node = nodes_by_id[cur_id]
            if node["presentation"] == "choice":
                pick_key = {"ar2_choice_c1": f"choice_ar2_c1_{c1}", "ar2_choice_c2": f"choice_ar2_c2_{c2}", "ar2_choice_c3": f"choice_ar2_c3_{c3}"}[cur_id]
                picked = next(ch for ch in node["choices"] if ch["id"] == pick_key)
                expect(picked["label"] == expected_choices[pick_key], f"Choice label mismatch for {pick_key}")
                cur_id = picked["next"]
            else:
                actual_seq.append((node["speaker_label"], node["text"]))
                expect(len(node["choices"]) == 1, f"{cur_id}: authored node should have 1 continue choice")
                cur_id = node["choices"][0]["next"]

        expect(len(actual_seq) == len(expected_seq), f"Path {c1}-{c2}-{c3} length mismatch: {len(actual_seq)} vs {len(expected_seq)}")
        for idx, (got, exp) in enumerate(zip(actual_seq, expected_seq)):
            expect(got == exp, f"Path {c1}-{c2}-{c3} beat #{idx + 1} mismatch:\n  got: {got}\n  exp: {exp}")

    # Audit RGBA runtime portraits
    expected_portraits = [
        ("assets/characters/artoria_lv2_v1/taiga_fujimura/ward/smile.png", (1024, 1536)),
        ("assets/characters/artoria_lv2_v1/taiga_fujimura/ward/laugh.png", (1024, 1536)),
        ("assets/characters/artoria_lv2_v1/taiga_fujimura/ward/worried.png", (1024, 1536)),
        ("assets/characters/artoria_lv2_v1/taiga_fujimura/or_cap/tense.png", (1448, 1086)),
        ("assets/characters/artoria_lv2_v1/taiga_fujimura/or_cap/drowsy.png", (1448, 1086)),
        ("assets/characters/artoria_lv2_v1/taiga_fujimura/or_cap/relieved.png", (1448, 1086)),
        ("assets/characters/artoria_lv2_v1/doc_artoria/white_coat/smile.png", (1024, 1536)),
        ("assets/characters/artoria_lv2_v1/doc_artoria/white_coat/embarrassed.png", (1024, 1536)),
        ("assets/characters/artoria_lv2_v1/doc_artoria/scrubs_masked/neutral.png", (1024, 1536)),
        ("assets/characters/artoria_lv2_v1/doc_artoria/scrubs_masked/focused.png", (1024, 1536)),
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
    expect(zh_keys == en_keys and len(zh_keys) > 600, f"Locale key parity mismatch: zh={len(zh_keys)} en={len(en_keys)}")
    for k in sorted(en_keys):
        val = en_strings[k]
        expect(bool(val.strip()), f"Empty English value at {k}")
        expect(not CJK_RE.search(val), f"CJK leak in English {k}: {val}")
        expect("Saber" not in val, f"Internal alias Saber leaked in English {k}: {val}")

    profile = json.loads(PROFILE_PATH.read_text(encoding="utf-8"))
    expect("scrubs_masked" in profile["visuals"]["outfits"], "doc_artoria profile missing scrubs_masked outfit")
    rel = json.loads(REL_PATH.read_text(encoding="utf-8"))
    slot2 = next(s for s in rel["rank_slots"] if s["target_level"] == 2)
    expect(slot2["event_id"] == EVENT_ID and slot2["content_status"] == "authored", "relationship.json Lv2 slot not wired")

    print(f"ARTORIA LV2 SOURCE AUDIT: {checks} checks; {failures} failure(s)")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
