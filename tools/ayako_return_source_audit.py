#!/usr/bin/env python3
"""Strict verbatim line-by-line audit of Katagiri Ayako's 30-day return arc (V1.1).

Audits:
  1. research/source_scripts/HOSHIMI_AYAKO_RETURN_01_OPENING_V1_1.md
  2. research/source_scripts/HOSHIMI_AYAKO_RETURN_02_WEEK1_WEEK2_V1_1.md
  3. research/source_scripts/HOSHIMI_AYAKO_RETURN_03_WEEK3_WEEK4_END_V1_1.md
  4. research/source_scripts/HOSHIMI_AYAKO_RETURN_04_AMBIENT_POOL_V1_1.md
against:
  - data/events/special_events/ayako_return.json
  - data/events/special_event_steps/ayako_return.json
  - data/localization/zh_CN.json & data/localization/en.json
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VOL1 = ROOT / "research/source_scripts/HOSHIMI_AYAKO_RETURN_01_OPENING_V1_1.md"
VOL2 = ROOT / "research/source_scripts/HOSHIMI_AYAKO_RETURN_02_WEEK1_WEEK2_V1_1.md"
VOL3 = ROOT / "research/source_scripts/HOSHIMI_AYAKO_RETURN_03_WEEK3_WEEK4_END_V1_1.md"
VOL4 = ROOT / "research/source_scripts/HOSHIMI_AYAKO_RETURN_04_AMBIENT_POOL_V1_1.md"

EVENTS_JSON = ROOT / "data/events/special_events/ayako_return.json"
STEPS_JSON = ROOT / "data/events/special_event_steps/ayako_return.json"
LOCALE_ZH = ROOT / "data/localization/zh_CN.json"
LOCALE_EN = ROOT / "data/localization/en.json"
BACKGROUNDS_JSON = ROOT / "data/backgrounds.json"

CJK_RE = re.compile(r"[\u3400-\u9fff\u3040-\u30ff]")

EXPECTED_EVENTS = [
    ("ayako_return_00_opening", "她真的又来了", 25, "day_start", True),
    ("ayako_return_01_week1_nurses", "真正的护士工作", 20, "location", False),
    ("ayako_return_02_week2_sketches", "你们医院的人都很奇怪", 25, "after_work", False),
    ("ayako_return_03_week3_shiori", "诗织，以前也是这样吗？", 20, "after_work", False),
    ("ayako_return_04_week4_storyboard", "星见医院物语", 25, "after_work", False),
    ("ayako_return_05_departure", "留作纪念的胸牌", 20, "day_start", True),
    ("ayako_amb_01_badge_reflex", "胸牌的标准使用方法", 15, "location", False),
    ("ayako_amb_02_gyn_danger_sense", "妇科走廊的危险直觉", 15, "location", False),
    ("ayako_amb_03_postop_vending_sketch", "下台五分钟的灵魂速写", 15, "after_work", False),
    ("ayako_amb_04_lightning_corridor", "自带背景闪电的走廊", 15, "location", False),
    ("ayako_amb_05_cool_drug_name", "听起来很厉害的药名", 15, "after_work", False),
    ("ayako_amb_06_two_thick_notebooks", "两本写满的笔记本", 15, "location", False),
    ("ayako_amb_07_dynamic_uniform_folds", "动态衣褶的最佳模特", 15, "location", False),
    ("ayako_amb_08_observed_observer", "逃不过法眼的观察者", 15, "location", False),
    ("ayako_amb_09_director_uniform_audit", "院长大人的版型抽查", 15, "location", False),
    ("ayako_amb_10_yellow_line_honor_student", "四楼黄线外的模范生", 15, "location", False),
]


def strip_md(s: str) -> str:
    s = re.sub(r"\*\*([^*]+)\*\*", r"\1", s)
    s = re.sub(r"\*([^*]+)\*", r"\1", s)
    return s


def extract_visible_atoms(section_md: str) -> tuple[list[str], list[str]]:
    """Independently extract ordered visible text atoms and choice option labels from a manuscript section."""
    atoms: list[str] = []
    options: list[str] = []

    buf: list[str] = []
    in_yaml = False
    in_visible = False

    def flush_paragraph() -> None:
        if not buf:
            return
        raw_block = "\n".join(buf)
        buf.clear()
        if not in_visible:
            return
        if raw_block.startswith(">"):
            lines = [strip_md(re.sub(r"^>\s*", "", ln).strip()) for ln in raw_block.splitlines()]
            atoms.append("\n".join(lines))
            return
        if "\n" in raw_block:
            lines = [strip_md(ln.strip()) for ln in raw_block.splitlines()]
            atoms.append("\n".join(lines))
            return
        line = strip_md(raw_block.strip())
        m_dir = re.match(
            r"^(坂口隆司|片桐彩子|女患者|深山佳織|藤崎詩織|城宮明日香|七瀬恋|朝倉美幸|石神千鹤|御堂江美子|阿尔托莉雅|水城阿库娅|飯村真奈美|本庄萌恵|杉村弘子|岩崎留美|米田栞|神宮寺成美|南条小夜香)：(「.+」)$",
            line,
        )
        if m_dir:
            atoms.append(m_dir.group(2))
            return
        m_mix = re.match(r"^(.+?)：(「[^「」]+」)$", line)
        if m_mix:
            atoms.append(m_mix.group(1) + "：")
            atoms.append(m_mix.group(2))
            return
        atoms.append(line)

    for raw in section_md.splitlines():
        s = raw.strip()
        if s.startswith("```"):
            flush_paragraph()
            in_yaml = not in_yaml
            continue
        if in_yaml:
            continue
        if not s:
            flush_paragraph()
            continue
        if s.startswith("#"):
            flush_paragraph()
            if s.startswith("## 【Scene ") or s.startswith("## 【Ambient "):
                in_visible = False
            continue
        if s == "**【玩家可见正文】**":
            flush_paragraph()
            in_visible = True
            continue
        if not in_visible:
            continue
        if s == "---" or s.startswith("*性质："):
            flush_paragraph()
            continue
        if s.startswith("- **选项 "):
            flush_paragraph()
            m_opt = re.match(r"^- \*\*选项 [AB]：(「.+」)\*\*$", s)
            if m_opt:
                options.append(m_opt.group(1))
            continue
        if s.startswith("**【") and s.endswith("】**"):
            flush_paragraph()
            continue
        buf.append(s)
    flush_paragraph()
    return atoms, options


def slice_between(md: str, start: str, end: str | None) -> str:
    i = md.index(start)
    j = md.index(end, i + len(start)) if end else len(md)
    return md[i:j]


def audit() -> tuple[int, list[str]]:
    checks = 0
    failures: list[str] = []

    def expect(cond: bool, msg: str) -> None:
        nonlocal checks
        checks += 1
        if not cond:
            failures.append(msg)

    events = json.loads(EVENTS_JSON.read_text(encoding="utf-8"))
    steps = json.loads(STEPS_JSON.read_text(encoding="utf-8"))
    zh = json.loads(LOCALE_ZH.read_text(encoding="utf-8"))["strings"]
    en = json.loads(LOCALE_EN.read_text(encoding="utf-8"))["strings"]
    bg_ids = {b["id"] for b in json.loads(BACKGROUNDS_JSON.read_text(encoding="utf-8"))}

    events_by_id = {e["id"]: e for e in events}
    steps_by_id = {s["id"]: s for s in steps}
    expect(len(events) == 16, f"Expected 16 special events, got {len(events)}")
    expect(len(steps) == 16, f"Expected 16 special event steps, got {len(steps)}")

    # 1. Event-level contracts & cameo non-pollution
    for ev_id, title_zh, dur_min, trig_mode, auto_sched in EXPECTED_EVENTS:
        ev = events_by_id.get(ev_id)
        expect(ev is not None, f"Missing event {ev_id}")
        if ev is None:
            continue
        expect(ev.get("title") == title_zh, f"{ev_id}: title mismatch {ev.get('title')!r} != {title_zh!r}")
        expect(ev.get("consumes_full_day") is False, f"{ev_id}: consumes_full_day must be False")
        expect(ev.get("settled_minutes") == dur_min, f"{ev_id}: expected {dur_min}m, got {ev.get('settled_minutes')}")
        expect(ev.get("trigger_mode") == trig_mode, f"{ev_id}: expected trigger_mode={trig_mode}, got {ev.get('trigger_mode')}")
        expect(ev.get("auto_schedule") is auto_sched, f"{ev_id}: expected auto_schedule={auto_sched}, got {ev.get('auto_schedule')}")

    expect(
        "nurse_ishigami" not in events_by_id["ayako_return_01_week1_nurses"].get("required_characters", []),
        "Week 1 must NOT list nurse_ishigami in required_characters (cameo met non-pollution)",
    )
    for cameo_id in ("doc_emiko", "doc_artoria", "doc_serika", "doc_minato"):
        expect(
            cameo_id not in events_by_id["ayako_return_02_week2_sketches"].get("required_characters", []),
            f"Week 2 must NOT list {cameo_id} in required_characters (cameo met non-pollution)",
        )

    # 2. Verbatim source text & choice audit across all 16 sections
    v1 = VOL1.read_text(encoding="utf-8")
    v2 = VOL2.read_text(encoding="utf-8")
    v3 = VOL3.read_text(encoding="utf-8")
    v4 = VOL4.read_text(encoding="utf-8")

    sections: dict[str, str] = {
        "ayako_return_00_opening_main": slice_between(v1, "## 【Scene A ", "# 三、 后续 30 天驻留"),
        "ayako_return_01_week1_nurses_main": slice_between(v2, "## 【Scene 1A ", "# 第二部分：Week 2"),
        "ayako_return_02_week2_sketches_main": slice_between(v2, "## 【Scene 2A ", "# 附：Codex 工程实装"),
        "ayako_return_03_week3_shiori_main": slice_between(v3, "## 【Scene 3A ", "# 第二部分：Week 4"),
        "ayako_return_04_week4_storyboard_main": slice_between(v3, "## 【Scene 4A ", "# 第三部分：驻留结束离院事件"),
        "ayako_return_05_departure_main": slice_between(v3, "## 【Scene 5A ", "# 附：Codex 工程实装"),
        "ayako_amb_01_badge_reflex_main": slice_between(v4, "## 【Ambient 01 ", "## 【Ambient 02 "),
        "ayako_amb_02_gyn_danger_sense_main": slice_between(v4, "## 【Ambient 02 ", "## 【Ambient 03 "),
        "ayako_amb_03_postop_vending_sketch_main": slice_between(v4, "## 【Ambient 03 ", "## 【Ambient 04 "),
        "ayako_amb_04_lightning_corridor_main": slice_between(v4, "## 【Ambient 04 ", "## 【Ambient 05 "),
        "ayako_amb_05_cool_drug_name_main": slice_between(v4, "## 【Ambient 05 ", "## 【Ambient 06 "),
        "ayako_amb_06_two_thick_notebooks_main": slice_between(v4, "## 【Ambient 06 ", "## 【Ambient 07 "),
        "ayako_amb_07_dynamic_uniform_folds_main": slice_between(v4, "## 【Ambient 07 ", "## 【Ambient 08 "),
        "ayako_amb_08_observed_observer_main": slice_between(v4, "## 【Ambient 08 ", "## 【Ambient 09 "),
        "ayako_amb_09_director_uniform_audit_main": slice_between(v4, "## 【Ambient 09 ", "## 【Ambient 10 "),
        "ayako_amb_10_yellow_line_honor_student_main": slice_between(v4, "## 【Ambient 10 ", "# 三、 全四卷统合"),
    }

    cg_counts = {"cg_01_nurse_badge.png": 0, "cg_02_storyboard.png": 0}

    for step_id, sec_md in sections.items():
        st = steps_by_id.get(step_id)
        expect(st is not None, f"Missing step {step_id}")
        if st is None:
            continue
        expected_atoms, expected_opts = extract_visible_atoms(sec_md)
        nodes = st["nodes"]
        actual_atoms = [n["text"] for n in nodes]
        expect(
            len(actual_atoms) == len(expected_atoms),
            f"{step_id}: node count {len(actual_atoms)} != manuscript atom count {len(expected_atoms)}",
        )
        for idx, (exp_t, act_t) in enumerate(zip(expected_atoms, actual_atoms)):
            expect(
                exp_t == act_t,
                f"{step_id} beat #{idx + 1} verbatim mismatch:\n  manuscript: {exp_t!r}\n  json:       {act_t!r}",
            )

        actual_opts: list[str] = []
        for n in nodes:
            if len(n.get("choices", [])) > 1:
                for ch in n["choices"]:
                    actual_opts.append(ch["label"])
        expect(
            actual_opts == expected_opts,
            f"{step_id}: choice labels {actual_opts!r} != manuscript {expected_opts!r}",
        )

        by_id = {n["id"]: n for n in nodes}
        visited: set[str] = set()
        stack = [st["start"]]
        has_day_end = False
        while stack:
            nid = stack.pop()
            if nid in visited:
                continue
            visited.add(nid)
            node = by_id[nid]
            expect(node["background_id"] in bg_ids, f"{step_id}/{nid}: unknown background {node['background_id']}")
            if node.get("cg_path"):
                cg_p = ROOT / node["cg_path"]
                expect(cg_p.is_file(), f"{step_id}/{nid}: missing CG {node['cg_path']}")
                for cg_name in cg_counts:
                    if node["cg_path"].endswith(cg_name):
                        cg_counts[cg_name] += 1
            for p in node.get("event_portraits", []):
                expect((ROOT / p["path"]).is_file(), f"{step_id}/{nid}: missing portrait {p['path']}")
            if node.get("fallback_next"):
                fn = node["fallback_next"]
                if fn == "@day_end":
                    has_day_end = True
                else:
                    expect(fn in by_id, f"{step_id}/{nid}: invalid fallback_next {fn}")
                    if fn in by_id:
                        stack.append(fn)
            expect(bool(node.get("choices")), f"{step_id}/{nid}: dead-end node with empty choices")
            for ch in node.get("choices", []):
                nxt = ch["next"]
                if nxt == "@day_end":
                    has_day_end = True
                else:
                    expect(nxt in by_id, f"{step_id}/{nid}: invalid choice next {nxt}")
                    if nxt in by_id:
                        stack.append(nxt)
        expect(has_day_end, f"{step_id}: no path reaches @day_end")
        expect(len(visited) == len(nodes), f"{step_id}: unreachable nodes {sorted(set(by_id) - visited)}")

    expect(cg_counts["cg_01_nurse_badge.png"] >= 10, f"Expected >=10 badge CG nodes, got {cg_counts['cg_01_nurse_badge.png']}")
    expect(cg_counts["cg_02_storyboard.png"] >= 10, f"Expected >=10 storyboard CG nodes, got {cg_counts['cg_02_storyboard.png']}")

    # 3. Specific conditional branch checks (Week 2 Serika/Minato & Week 3 Shiori >=4)
    w2_nodes = steps_by_id["ayako_return_02_week2_sketches_main"]["nodes"]
    serika_nodes = [n for n in w2_nodes if n.get("requirements") == [{"type": "staff_unlocked", "actor_id": "doc_serika"}]]
    minato_nodes = [n for n in w2_nodes if n.get("requirements") == [{"type": "staff_unlocked", "actor_id": "doc_minato"}]]
    expect(len(serika_nodes) == 4, f"Expected 4 Serika conditional nodes in Week 2, got {len(serika_nodes)}")
    expect(len(minato_nodes) == 2, f"Expected 2 Minato conditional nodes in Week 2, got {len(minato_nodes)}")

    w3_nodes = steps_by_id["ayako_return_03_week3_shiori_main"]["nodes"]
    shiori4_nodes = [
        n
        for n in w3_nodes
        if n.get("requirements") == [{"type": "relationship_level", "actor_id": "doc_shiori", "minimum": 4}]
    ]
    expect(len(shiori4_nodes) == 7, f"Expected 7 Shiori>=4 nodes in Week 3, got {len(shiori4_nodes)}")

    # 4. Localization completeness & English CJK cleanliness
    for ev in events:
        eid = ev["id"]
        for field in ("title", "completion_hint", "announcement"):
            if field not in ev:
                continue
            k = f"collections.special_events.{eid}.{field}"
            expect(zh.get(k) == ev[field], f"Missing/mismatched zh key {k}")
            expect(bool(en.get(k, "").strip()), f"Missing en key {k}")
            if en.get(k):
                expect(not CJK_RE.search(en[k]), f"CJK characters found in en[{k}]: {en[k]!r}")
        ge = ev.get("gallery_entry", {})
        if ge:
            gtk = f"collections.special_events.{eid}.gallery_entry.title"
            expect(zh.get(gtk) == ge["title"], f"Missing/mismatched zh key {gtk}")
            expect(bool(en.get(gtk, "").strip()), f"Missing en key {gtk}")
            if en.get(gtk):
                expect(not CJK_RE.search(en[gtk]), f"CJK characters found in en[{gtk}]: {en[gtk]!r}")
            for c_idx, ch_txt in enumerate(ge.get("chapters", [])):
                gck = f"collections.special_events.{eid}.gallery_entry.chapters.{c_idx}"
                expect(zh.get(gck) == ch_txt, f"Missing/mismatched zh key {gck}")
                expect(bool(en.get(gck, "").strip()), f"Missing en key {gck}")
                if en.get(gck):
                    expect(not CJK_RE.search(en[gck]), f"CJK characters found in en[{gck}]: {en[gck]!r}")

    for st in steps:
        sid = st["id"]
        tk = f"collections.special_event_steps.{sid}.title"
        expect(zh.get(tk) == st["title"], f"Missing/mismatched zh key {tk}")
        expect(bool(en.get(tk, "").strip()), f"Missing en key {tk}")
        if en.get(tk):
            expect(not CJK_RE.search(en[tk]), f"CJK characters found in en[{tk}]: {en[tk]!r}")
        for n in st["nodes"]:
            nid = n["id"]
            nk = f"collections.special_event_steps.{sid}.nodes.{nid}.text"
            expect(zh.get(nk) == n["text"], f"Missing/mismatched zh key {nk}")
            expect(bool(en.get(nk, "").strip()), f"Missing en key {nk}")
            if en.get(nk):
                expect(not CJK_RE.search(en[nk]), f"CJK characters found in en[{nk}]: {en[nk]!r}")
            if "speaker_label" in n:
                sk = f"collections.special_event_steps.{sid}.nodes.{nid}.speaker_label"
                expect(zh.get(sk) == n["speaker_label"], f"Missing/mismatched zh key {sk}")
                expect(bool(en.get(sk, "").strip()), f"Missing en key {sk}")
                if en.get(sk):
                    expect(not CJK_RE.search(en[sk]), f"CJK characters found in en[{sk}]: {en[sk]!r}")
            for ch in n.get("choices", []):
                ck = f"collections.special_event_steps.{sid}.nodes.{nid}.choices.{ch['id']}.label"
                expect(zh.get(ck) == ch["label"], f"Missing/mismatched zh key {ck}")
                expect(bool(en.get(ck, "").strip()), f"Missing en key {ck}")
                if en.get(ck):
                    expect(not CJK_RE.search(en[ck]), f"CJK characters found in en[{ck}]: {en[ck]!r}")

    return checks, failures


def main() -> int:
    checks, failures = audit()
    if failures:
        print(f"FAILED ({len(failures)} failures across {checks} checks):")
        for f in failures[:40]:
            print(" -", f)
        if len(failures) > 40:
            print(f" ... and {len(failures) - 40} more.")
        return 1
    print(f"OK ({checks} checks passed): Ayako Return V1.1 100% verbatim & localized.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
