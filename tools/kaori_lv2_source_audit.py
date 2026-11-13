#!/usr/bin/env python3
"""Strict verbatim line-by-line audit of Miyama Kaori Lv2 V9.1 (`miyama_02_manga_artist_wrong_patient`)."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts/HOSHIMI_KAORI_LV2_OVER_RESEARCHED_V9_1.md"
SPECIAL_EVENTS = ROOT / "data/staff/doc_rei/special_events.json"
SPECIAL_EVENT_STEPS = ROOT / "data/staff/doc_rei/special_event_steps.json"
LOCALIZATION_ZH = ROOT / "data/localization/zh_CN.json"
LOCALIZATION_EN = ROOT / "data/localization/en.json"

EVENT_ID = "miyama_02_manga_artist_wrong_patient"
STEP_ID = "miyama_02_manga_artist_wrong_patient_main"
HAN = re.compile(r"[\u3400-\u9fff]")


def parse_source_scenes() -> dict[str, dict[int, tuple[str | None, str]]]:
    md = SOURCE.read_text(encoding="utf-8")
    sections = re.split(r"(?m)^(# \d+(?:\.\d+)?\.?\s+[^\n]+)\n", md)
    parsed: dict[str, dict[int, tuple[str | None, str]]] = {}
    for idx in range(1, len(sections), 2):
        header = sections[idx].strip()
        body = sections[idx + 1]
        m_sc = re.search(r"Scene (\d+B?)", header)
        if not m_sc:
            continue
        sid = "s" + m_sc.group(1).lower()
        body_main = re.split(r"(?m)^##\s+", body)[0]
        beats = re.split(r"(?m)^###\s+(\d+)\s*\n", body_main)
        beat_dict: dict[int, tuple[str | None, str]] = {}
        current_speaker: str | None = None
        for j in range(1, len(beats), 2):
            bnum = int(beats[j])
            raw = re.sub(r"(?m)\n---\s*$", "", beats[j + 1].strip()).strip()
            lines: list[str] = []
            explicit_speaker: str | None = None
            has_narration_tag = False
            has_quote = False
            in_code = False
            for ln in raw.splitlines():
                s = ln.strip()
                if s.startswith("```"):
                    in_code = not in_code
                    continue
                if not s:
                    continue
                if not in_code:
                    if s == "**Narration**":
                        has_narration_tag = True
                        current_speaker = "旁白"
                        continue
                    m_bold = re.match(r"^\*\*([^*]+)\*\*(\s*—\s*`[^`]+`)?$", s)
                    if m_bold:
                        explicit_speaker = m_bold.group(1).strip()
                        current_speaker = explicit_speaker
                        continue
                    m_colon = re.match(
                        r"^(深山佳織|深山|坂口隆司|坂口|城宮明日香|明日香|片桐彩子|彩子|藤崎詩織|藤崎|系统)[：:]$",
                        s,
                    )
                    if m_colon:
                        who = m_colon.group(1)
                        if who == "系统":
                            explicit_speaker = "旁白"
                            current_speaker = "旁白"
                            lines.append("系统：")
                        else:
                            explicit_speaker = who
                            current_speaker = who
                        continue
                    if s.startswith("> "):
                        s = s[2:].strip()
                        if s.startswith("「") or s.startswith("『"):
                            has_quote = True
                    s = re.sub(r"\*\*([^*]+)\*\*", r"\1", s)
                lines.append(s)
            if explicit_speaker:
                beat_speaker = explicit_speaker
            elif sid == "s32" and bnum == 3:
                # Beat 03 answers Miyama's "什么？" from Sakaguchi's Beat 01 setup.
                beat_speaker = "坂口隆司"
                current_speaker = "坂口隆司"
            elif has_narration_tag or not has_quote:
                beat_speaker = "旁白"
            else:
                beat_speaker = current_speaker
            beat_dict[bnum] = (beat_speaker, "\n\n".join(lines))
        parsed[sid] = beat_dict
    return parsed


def normalize_speaker(name: str | None) -> str:
    mapping = {
        None: "旁白",
        "旁白": "旁白",
        "Narration": "旁白",
        "深山佳織": "doc_rei",
        "深山": "doc_rei",
        "坂口隆司": "player",
        "坂口": "player",
        "城宮明日香": "doc_asuka",
        "明日香": "doc_asuka",
        "片桐彩子": "guest_ayako",
        "彩子": "guest_ayako",
        "藤崎詩織": "doc_shiori",
        "藤崎": "doc_shiori",
    }
    return mapping.get(name, str(name))


def node_speaker_canonical(node: dict) -> str:
    if node.get("speaker") == "player":
        return "player"
    if node.get("actor_id"):
        return str(node["actor_id"])
    lbl = node.get("speaker_label", "旁白")
    return normalize_speaker(lbl)


def audit() -> tuple[int, list[str]]:
    checks = 0
    failures: list[str] = []

    def expect(cond: bool, msg: str) -> None:
        nonlocal checks
        checks += 1
        if not cond:
            failures.append(msg)

    events = json.loads(SPECIAL_EVENTS.read_text(encoding="utf-8"))
    steps = json.loads(SPECIAL_EVENT_STEPS.read_text(encoding="utf-8"))
    zh = json.loads(LOCALIZATION_ZH.read_text(encoding="utf-8"))["strings"]
    en = json.loads(LOCALIZATION_EN.read_text(encoding="utf-8"))["strings"]

    ev = next((e for e in events if e.get("id") == EVENT_ID), None)
    step = next((s for s in steps if s.get("id") == STEP_ID), None)
    expect(ev is not None, f"Missing event {EVENT_ID}")
    expect(step is not None, f"Missing step {STEP_ID}")
    if ev is None or step is None:
        return checks, failures

    expect(ev.get("title") == "取材过头了", "Event title mismatch")
    expect(ev.get("prerequisite_events") == ["miyama_01_safety_pin"], "Prerequisite event must be miyama_01_safety_pin")
    expect(step.get("start") == "s01_001", f"Expected start == s01_001, got {step.get('start')}")
    nodes: list[dict] = step.get("nodes", [])
    expect(len(nodes) == 563, f"Expected 563 nodes in V9.1, got {len(nodes)}")

    by_id = {n["id"]: n for n in nodes}
    for obs in ("lv1_callback", "lv2_asuka_private", "lv2_pattern", "lv2_doctor"):
        expect(obs not in by_id, f"Obsolete bridge node still present: {obs}")

    # Verify linear node chain from s01_001 to s34_001 -> @day_end
    cur = step["start"]
    visited: list[str] = []
    while cur != "@day_end" and len(visited) <= len(nodes) + 5:
        expect(cur in by_id, f"Broken link to missing node: {cur}")
        if cur not in by_id:
            break
        visited.append(cur)
        choices = by_id[cur].get("choices", [])
        expect(len(choices) >= 1, f"Node {cur} has no choices")
        if not choices:
            break
        cur = choices[0]["next"]
    expect(cur == "@day_end", f"Traversal did not end at @day_end (stopped at {cur})")
    expect(len(visited) == 563, f"Expected linear traversal of all 563 nodes, visited {len(visited)}")

    # Strict verbatim line-by-line audit of all V9.1 revised/added scenes & beats
    parsed = parse_source_scenes()
    full_v9_scenes = ["s01", "s25b", "s32"]
    for sid in full_v9_scenes:
        src_beats = parsed[sid]
        actual_nodes = [n for n in nodes if re.match(rf"^{sid}_\d{{3}}$", n["id"])]
        expect(len(actual_nodes) == len(src_beats), f"{sid}: count mismatch ({len(actual_nodes)} vs {len(src_beats)})")
        for bnum, (exp_spk, exp_txt) in sorted(src_beats.items()):
            nid = f"{sid}_{bnum:03d}"
            node = by_id.get(nid)
            expect(node is not None, f"Missing node {nid}")
            if node is None:
                continue
            expect(node["text"] == exp_txt, f"{nid}: verbatim text mismatch\n  EXP: {exp_txt!r}\n  ACT: {node['text']!r}")
            expect(
                node_speaker_canonical(node) == normalize_speaker(exp_spk),
                f"{nid}: speaker mismatch (expected {normalize_speaker(exp_spk)}, got {node_speaker_canonical(node)})",
            )

    # Audit targeted V8 -> V9.1 revised beats across other scenes
    targeted_beats = [
        ("s08", 23),
        ("s09", 1),
        ("s24", 6),
        ("s25", 15),
        ("s25", 16),
        ("s25", 17),
        ("s26", 14),
        ("s28", 9),
    ]
    for sid, bnum in targeted_beats:
        nid = f"{sid}_{bnum:03d}"
        exp_spk, exp_txt = parsed[sid][bnum]
        node = by_id.get(nid)
        expect(node is not None, f"Missing targeted node {nid}")
        if node is not None:
            expect(node["text"] == exp_txt, f"{nid}: verbatim text mismatch\n  EXP: {exp_txt!r}\n  ACT: {node['text']!r}")
            expect(
                node_speaker_canonical(node) == normalize_speaker(exp_spk),
                f"{nid}: speaker mismatch (expected {normalize_speaker(exp_spk)}, got {node_speaker_canonical(node)})",
            )

    # Ensure zero "下午手术" timeline contradictions remain
    for n in nodes:
        txt = n.get("text", "")
        expect("下午有台胃部病例" not in txt, f"{n['id']}: stale afternoon gastric line remained")
        expect("那下午手术室见" not in txt, f"{n['id']}: stale afternoon OR line remained")
        expect("属于下午患者的腕带" not in txt, f"{n['id']}: stale afternoon wristband line remained")

    # Verify asset paths & bilingual localization coverage on all 563 nodes
    step_prefix = f"collections.special_event_steps.{STEP_ID}"
    for n in nodes:
        nid = n["id"]
        for ep in n.get("event_portraits", []):
            p = ROOT / ep["path"]
            expect(p.is_file(), f"{nid}: missing event_portrait file {ep['path']}")
        if n.get("portrait_path"):
            expect((ROOT / n["portrait_path"]).is_file(), f"{nid}: missing portrait_path {n['portrait_path']}")
        if n.get("cg_path"):
            expect((ROOT / n["cg_path"]).is_file(), f"{nid}: missing cg_path {n['cg_path']}")

        t_key = f"{step_prefix}.nodes.{nid}.text"
        expect(zh.get(t_key) == n["text"], f"{nid}: zh_CN text out of sync")
        if HAN.search(n["text"]):
            en_txt = en.get(t_key, "")
            expect(bool(en_txt.strip()), f"{nid}: missing English text")
            expect(not HAN.search(en_txt), f"{nid}: CJK characters remain in English text")
            expect("Shenshan" not in en_txt and "SakaguchiLongji" not in en_txt, f"{nid}: legacy machine-translation typo in English text")

        if n.get("speaker_label") and HAN.search(n["speaker_label"]):
            s_key = f"{step_prefix}.nodes.{nid}.speaker_label"
            en_spk = en.get(s_key, "")
            expect(bool(en_spk.strip()) and not HAN.search(en_spk), f"{nid}: invalid English speaker_label")
            expect("SakaguchiLongji" not in en_spk, f"{nid}: legacy speaker_label typo")

        for c in n.get("choices", []):
            if HAN.search(c["label"]):
                c_key = f"{step_prefix}.choices.{c['id']}.label"
                c_key_node = f"{step_prefix}.nodes.{nid}.choices.{c['id']}.label"
                en_lbl = en.get(c_key_node, en.get(c_key, ""))
                expect(bool(en_lbl.strip()) and not HAN.search(en_lbl), f"{nid}/{c['id']}: missing/CJK English choice label")

    return checks, failures


def main() -> int:
    checks, failures = audit()
    if failures:
        for f in failures[:30]:
            print(f"FAIL: {f}", file=sys.stderr)
        print(f"KAORI LV2 V9.1 SOURCE AUDIT FAILED: {checks} checks; {len(failures)} failure(s)", file=sys.stderr)
        return 1
    print(f"KAORI LV2 V9.1 SOURCE AUDIT PASSED: {checks} checks; 0 failure(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
