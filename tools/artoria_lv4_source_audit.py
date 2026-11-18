#!/usr/bin/env python3
"""Line-by-line verbatim audit of `data/staff/doc_artoria/lv4_events.json`
against `research/source_scripts/HOSHIMI_ARTORIA_LV4_JUST_ARTORIA_V1_1.md`.

Exhaustively verifies all 3 * 3 * 3 = 27 choice paths for 100% verbatim
Chinese wording, speaker attribution, punctuation, order, H Runner handoff
at `ar4_s5_1_26`, zero Choice numerical/flag drift, and 100% English coverage,
allowing ONLY the 2 explicit user-authorized outfit-word micro-adjustments.
"""

from __future__ import annotations

import itertools
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from import_artoria_lv4 import (  # noqa: E402
    AUTHORIZED_OUTFIT_ADJUSTMENTS,
    EN_LOCALE_PATH,
    EVENT_ID,
    EVENTS_PATH,
    MANUSCRIPT_PATH,
    MIXED_PREFIX_SPEAKERS,
    PURE_SPEAKERS,
    ZH_LOCALE_PATH,
)

CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")
FORBIDDEN_LEAKS = re.compile(r"\b(Saber|Maiya)\b|久宇舞弥", re.IGNORECASE)

checks = 0
failures = 0


def expect(cond: bool, msg: str) -> None:
    global checks, failures
    checks += 1
    if not cond:
        failures += 1
        print(f"FAIL: {msg}", file=sys.stderr)


def parse_expected_sections() -> tuple[dict[str, list[tuple[str, str]]], dict[str, str]]:
    md = MANUSCRIPT_PATH.read_text(encoding="utf-8")
    body = md.split("## 二、 完整中文 VN 剧本正文", 1)[1].split(
        "**【阿尔托莉雅·潘德拉贡 Relationship Lv4《只是阿尔托莉雅》事件结束】**", 1
    )[0]

    sec = ""
    active = False
    cur_choice = ""
    sections: dict[str, list[tuple[str, str]]] = {}
    choices: dict[str, str] = {}
    seen_adjustments: set[str] = set()

    def push(section: str, spk: str, txt: str) -> None:
        sections.setdefault(section, []).append((spk, txt))

    for raw in body.splitlines():
        s = raw.strip()
        if not s or s == "---":
            continue
        if s in AUTHORIZED_OUTFIT_ADJUSTMENTS:
            seen_adjustments.add(s)
            s = AUTHORIZED_OUTFIT_ADJUSTMENTS[s]
        if s.startswith("### 【第一幕"):
            sec, active = "s1", False
            continue
        if s.startswith("### 【第二幕"):
            sec, active = "s2", False
            continue
        if s.startswith("### 【第三幕"):
            sec, active = "s3", False
            continue
        if s.startswith("### 【第四幕"):
            sec, active = "s4", False
            continue
        if s.startswith("### 【第五幕"):
            sec, active = "s5_1", False
            continue
        if s.startswith("#### 【5.2 "):
            sec, active = "s5_2", True
            continue
        if s.startswith("### 【第六幕"):
            continue
        if s.startswith("#### 6.1 "):
            sec, active = "s6_1", False
            continue
        if s.startswith("#### 6.2 "):
            sec, active = "s6_2", False
            continue
        if s == "**【玩家可见正文】**":
            active = True
            continue
        if s.startswith("*性质：") or s.startswith("> - "):
            continue
        if s.startswith("> **【语义接入点"):
            active = False
            continue
        m_ch = re.match(r"^\*\*【选择 (\d+)：.+】\*\*$", s)
        if m_ch:
            cur_choice = f"c{m_ch.group(1)}"
            active = False
            continue
        m_opt = re.match(r"^-\s*\*\*选项 ([ABC])：(.+)\*\*$", s)
        if m_opt:
            choices[f"choice_ar4_{cur_choice}_{m_opt.group(1).lower()}"] = m_opt.group(2).strip()
            continue
        m_br = re.match(r"^#### 【分支 ([ABC])\b", s)
        if m_br:
            sec = f"{cur_choice}{m_br.group(1).lower()}"
            active = True
            continue
        if s.startswith("> **【主线汇合"):
            sec = {"c1": "s2m", "c2": "s4m", "c3": "s6_2m"}[cur_choice]
            active = True
            continue
        if not active:
            continue

        m_pure = re.match(r"^(" + "|".join(map(re.escape, PURE_SPEAKERS)) + r")：(「.*」)$", s)
        if m_pure:
            push(sec, m_pure.group(1), m_pure.group(2))
            continue

        if "：「" in s and s.endswith("」"):
            act, quote = s.split("：", 1)
            spk = next((target for pfx, target in MIXED_PREFIX_SPEAKERS if act.startswith(pfx)), None)
            expect(spk is not None, f"Unmapped mixed line: {s}")
            push(sec, "旁白", act + "：")
            push(sec, spk or "", quote)
            continue

        push(sec, "旁白", s)

    expect(len(seen_adjustments) == 2, f"Expected exactly 2 authorized adjustments, saw {len(seen_adjustments)}")
    return sections, choices


def main() -> None:
    sections, expected_choices = parse_expected_sections()
    events = json.loads(EVENTS_PATH.read_text(encoding="utf-8"))
    expect(len(events) == 1, "Expected single event in lv4_events.json")
    ev = events[0]
    expect(ev["id"] == EVENT_ID, "Event ID mismatch")
    expect(ev["title"] == "只是阿尔托莉雅", "Event title mismatch")
    expect(ev["trigger_mode"] == "sunday" and ev["consumes_sunday"] is True, "Sunday trigger contract mismatch")
    expect(ev["target_level"] == 4 and ev["benefit_id"] == "unlock_intimacy_events", "Lv4 rank-up benefit mismatch")
    expect(ev["completion_day_offset"] == 1 and ev["completion_absolute_clock"] == 540, "Monday 09:00 settlement mismatch")

    nodes_by_id = {n["id"]: n for n in ev["nodes"]}
    expect(len(nodes_by_id) == 244, f"Expected 244 nodes (241 beats + 3 choices), got {len(nodes_by_id)}")

    # Verify H Runner handoff node contract
    h_node = nodes_by_id.get("ar4_s5_1_26", {})
    expect(h_node.get("action") == "launch_artoria_lv4_h", "Missing launch_artoria_lv4_h on ar4_s5_1_26")
    expect(h_node.get("choices", [{}])[0].get("next") == "ar4_s5_2_01", "H handoff must resume ar4_s5_2_01")
    for nid, node in nodes_by_id.items():
        if nid != "ar4_s5_1_26":
            expect("action" not in node, f"Unexpected action on {nid}")

    # Verify all 27 choice paths verbatim
    for c1, c2, c3 in itertools.product(["a", "b", "c"], repeat=3):
        expected_seq: list[tuple[str, str]] = []
        for sec_name in ["s1", "s2", f"c1{c1}", "s2m", "s3", "s4", f"c2{c2}", "s4m", "s5_1", "s5_2", "s6_1", "s6_2", f"c3{c3}", "s6_2m"]:
            expected_seq.extend(sections[sec_name])

        cur = ev["start"]
        actual_seq: list[tuple[str, str]] = []
        steps = 0
        while cur != "@end":
            steps += 1
            expect(steps <= 400, f"Cycle detected on path ({c1},{c2},{c3})")
            if steps > 400:
                break
            node = nodes_by_id[cur]
            if node["presentation"] == "choice":
                pick_map = {
                    "ar4_choice_c1": f"choice_ar4_c1_{c1}",
                    "ar4_choice_c2": f"choice_ar4_c2_{c2}",
                    "ar4_choice_c3": f"choice_ar4_c3_{c3}",
                }
                cid = pick_map[cur]
                ch = next(x for x in node["choices"] if x["id"] == cid)
                expect(ch["label"] == expected_choices[cid], f"Choice label mismatch on {cid}")
                expect(ch["effects"] == {"affection": 0, "familiarity": 0} and ch["flags"] == [], f"Choice {cid} must have zero numeric/flag drift")
                cur = ch["next"]
            else:
                actual_seq.append((node["speaker_label"], node["text"]))
                expect(len(node["choices"]) == 1, f"Beat node {cur} must have single continue")
                ch = node["choices"][0]
                expect(ch["effects"] == {"affection": 0, "familiarity": 0} and ch["flags"] == [], f"Beat {cur} must have zero effects")
                cur = ch["next"]

        expect(len(actual_seq) == len(expected_seq), f"Length mismatch on ({c1},{c2},{c3}): {len(actual_seq)} vs {len(expected_seq)}")
        for idx, ((exp_spk, exp_txt), (act_spk, act_txt)) in enumerate(zip(expected_seq, actual_seq)):
            expect(act_spk == exp_spk and act_txt == exp_txt, f"Mismatch on ({c1},{c2},{c3}) beat #{idx}: expected ({exp_spk}, {exp_txt!r}) got ({act_spk}, {act_txt!r})")

    # Verify zh_CN and en localization + zero leaks
    zh_strings = json.loads(ZH_LOCALE_PATH.read_text(encoding="utf-8"))["strings"]
    en_strings = json.loads(EN_LOCALE_PATH.read_text(encoding="utf-8"))["strings"]
    prefix = f"collections.character_events.{EVENT_ID}."
    for k in ["title", "teaser", "gallery.caption"]:
        expect(prefix + k in zh_strings and prefix + k in en_strings, f"Missing locale header {k}")
        expect(not CJK_RE.search(en_strings[prefix + k]), f"CJK leak in en {k}")
        expect(not FORBIDDEN_LEAKS.search(en_strings[prefix + k]), f"Forbidden codename leak in en {k}")

    for nid, node in nodes_by_id.items():
        np = f"{prefix}nodes.{nid}."
        expect(np + "speaker_label" in en_strings and not CJK_RE.search(en_strings[np + "speaker_label"]), f"Speaker EN missing/CJK on {nid}")
        if node["text"]:
            expect(zh_strings.get(np + "text") == node["text"], f"ZH locale mismatch on {nid}")
            en_txt = en_strings.get(np + "text", "")
            expect(bool(en_txt) and not CJK_RE.search(en_txt), f"EN text missing/CJK on {nid}")
            expect(not FORBIDDEN_LEAKS.search(en_txt) and not FORBIDDEN_LEAKS.search(node["text"]), f"Codename/Maiya leak on {nid}")
        for ch in node["choices"]:
            ck = f"{np}choices.{ch['id']}.label"
            expect(ck in en_strings and not CJK_RE.search(en_strings[ck]), f"EN choice missing/CJK on {ck}")

    print(f"ARTORIA LV4 SOURCE AUDIT PASS: {checks} checks; {failures} failure(s)")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
