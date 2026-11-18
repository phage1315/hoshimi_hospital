#!/usr/bin/env python3
"""Verbatim source audit for Asuka Shiromiya (`doc_asuka`) Relationship Lv2:
《合适的人，合适的手术袍》 (`asuka_lv2_right_person_right_gown`).

Independently verifies:
1. 100% character-for-character verbatim match of every dialogue beat, narration
   paragraph, split action+dialogue line, speaker ownership, and choice option
   against `research/source_scripts/HOSHIMI_ASUKA_LV2_RIGHT_PERSON_RIGHT_GOWN_V1_1.md`
   (0 unauthorized edits, additions, omissions, or speaker changes).
2. Graph integrity: reachable nodes, both Choice B1 and Choice C1 branches,
   zero-delta RP choices, clean `@end` settlement, and stable completion flags.
3. Bilingual coverage (`zh_CN.json` and `en.json`) with zero CJK leaks in English.
4. Portrait technical checks (`1024x1536` RGBA, transparent corners, `mipmaps/generate=true`)
   for Asuka's `sample_gown/*` and Codex's `doc_maki/interview/*`.
5. Dark-thread & Lv3/Lv4 spoiler boundary checks (zero deceased-parent wording,
   zero premature Lv3 private collection / romantic-flattery pivot).
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT = ROOT / "research/source_scripts/HOSHIMI_ASUKA_LV2_RIGHT_PERSON_RIGHT_GOWN_V1_1.md"
EVENT_ID = "asuka_lv2_right_person_right_gown"

CJK_RE = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")


class Audit:
    def __init__(self) -> None:
        self.checks = 0
        self.failures: list[str] = []

    def check(self, cond: bool, msg: str) -> None:
        self.checks += 1
        if not cond:
            self.failures.append(msg)

    def equal(self, actual, expected, msg: str) -> None:
        self.checks += 1
        if actual != expected:
            self.failures.append(f"{msg}: expected {expected!r}, got {actual!r}")


def reconstruct_manuscript_units(md_text: str) -> tuple[list[tuple[str, str]], list[str]]:
    """Independently extract (speaker_label, text) units and 4 choice labels from Section 1."""
    lines = md_text.splitlines()
    start_idx = next(i for i, l in enumerate(lines) if l.strip().startswith("# 一、"))
    end_idx = next(i for i, l in enumerate(lines) if l.strip().startswith("> **【事件结束"))
    in_header = False
    units: list[tuple[str, str]] = []
    choices: list[str] = []

    unbold_map = [
        ("坂口隆司", "坂口隆司"),
        ("御堂江美子", "御堂江美子"),
        ("阿尔托莉雅", "阿尔托莉雅·潘德拉贡"),
        ("神宮寺成美", "神宮寺成美"),
        ("城宮明日香", "城宮明日香"),
        ("明日香", "城宮明日香"),
        ("她低头看了看袖口", "城宮明日香"),
    ]

    for raw in lines[start_idx + 1 : end_idx]:
        s = raw.strip()
        if s.startswith("## Scene "):
            in_header = True
            continue
        if in_header:
            if s == "---":
                in_header = False
            continue
        if not s or s == "---" or s.startswith("*选项说明") or s.startswith("**【"):
            continue
        if s.startswith("- **选项 "):
            m_opt = re.match(r"^- \*\*选项 [AB]：(「.*」)\*\*$", s)
            assert m_opt is not None, f"Malformed choice line: {s}"
            choices.append(m_opt.group(1))
            continue
        m_pure = re.match(r"^\*\*([^*]+)\*\*：(「.*」)$", s)
        if m_pure:
            units.append((m_pure.group(1), m_pure.group(2)))
            continue
        m_bold_act = re.match(r"^\*\*([^*]+)\*\*(.+?)：(「.*」)$", s)
        if m_bold_act:
            sp, act, q = m_bold_act.groups()
            units.append(("旁白", f"{sp}{act}："))
            units.append((sp, q))
            continue
        m_mix = re.match(r"^([^「]+?)：(「.*」)$", s)
        if m_mix:
            pref, q = m_mix.groups()
            sp = next(lbl for k, lbl in unbold_map if pref.startswith(k))
            units.append(("旁白", f"{pref}："))
            units.append((sp, q))
            continue
        units.append(("旁白", s))
    return units, choices


def main() -> int:
    a = Audit()
    a.check(MANUSCRIPT.is_file(), "Manuscript V1.1 exists")
    md_text = MANUSCRIPT.read_text(encoding="utf-8")
    expected_units, expected_choices = reconstruct_manuscript_units(md_text)

    bundle = json.loads((ROOT / "data/staff/doc_asuka/bundle.json").read_text(encoding="utf-8"))
    a.check("lv2_events.json" in bundle.get("additional_character_event_files", []), "bundle.json registers lv2_events.json")

    profile = json.loads((ROOT / "data/staff/doc_asuka/profile.json").read_text(encoding="utf-8"))
    a.check("sample_gown" in profile["visuals"]["outfits"], "profile.json registers sample_gown outfit")
    for k in ("sample_gown/neutral", "sample_gown/smile", "sample_gown/proud", "sample_gown/reluctant_cuff"):
        a.check(k in profile["visuals"]["portraits"], f"profile.json registers {k}")

    rel = json.loads((ROOT / "data/staff/doc_asuka/relationship.json").read_text(encoding="utf-8"))
    slot2 = next((s for s in rel["rank_slots"] if s["target_level"] == 2), {})
    a.equal(slot2.get("event_id"), EVENT_ID, "Lv2 rank slot event_id")
    a.equal(slot2.get("content_status"), "authored", "Lv2 rank slot content_status")
    a.equal(slot2.get("min_familiarity"), 25, "Lv2 rank slot min_familiarity")
    a.equal(slot2.get("cooldown_days"), 3, "Lv2 rank slot cooldown_days")

    events = json.loads((ROOT / "data/staff/doc_asuka/lv2_events.json").read_text(encoding="utf-8"))
    a.equal(len(events), 1, "lv2_events.json has 1 event")
    ev = events[0]
    a.equal(ev["id"], EVENT_ID, "event id")
    a.equal(ev["title"], "合适的人，合适的手术袍", "event title")
    a.equal(ev["location_id"], "director_office", "location_id")
    a.equal(ev["trigger_mode"], "location", "trigger_mode")
    a.equal(ev["background_id"], "conference_room", "background_id")
    a.equal(ev["time_start"], 720, "time_start (12:00)")
    a.equal(ev["time_end"], 960, "time_end (16:00)")
    a.equal(ev["minutes"], 125, "minutes")
    a.equal(ev["category"], "rank_up", "category")
    a.equal(ev["target_level"], 2, "target_level")
    a.check(ev.get("locks_saving") is True, "locks_saving is True")
    a.check("asuka_lv2_complete" in ev.get("completion_story_flags", []), "completion_story_flags contains asuka_lv2_complete")
    a.check("maki_aizawa_offer_accepted" in ev.get("completion_story_flags", []), "completion_story_flags contains maki_aizawa_offer_accepted")

    nodes: list[dict] = ev["nodes"]
    authored_nodes = [n for n in nodes if n["presentation"] == "authored"]
    choice_nodes = [n for n in nodes if n["presentation"] == "choice"]
    a.equal(len(authored_nodes), len(expected_units), "authored beat count matches manuscript 1-to-1")
    a.equal(len(choice_nodes), 2, "2 choice marker nodes (Choice B1 & Choice C1)")

    # Verbatim line-by-line audit
    for idx, (node, (exp_speaker, exp_text)) in enumerate(zip(authored_nodes, expected_units), start=1):
        a.equal(node["speaker_label"], exp_speaker, f"Node {node['id']} (#{idx}) speaker_label")
        a.equal(node["text"], exp_text, f"Node {node['id']} (#{idx}) verbatim text")

    actual_choices = [ch["label"] for cn in choice_nodes for ch in cn["choices"]]
    a.equal(actual_choices, expected_choices, "All 4 RP choice labels match manuscript verbatim")
    for cn in choice_nodes:
        for ch in cn["choices"]:
            a.equal(ch["effects"], {"affection": 0, "familiarity": 0}, f"Choice {ch['id']} zero stat delta")
            a.equal(ch["flags"], [], f"Choice {ch['id']} zero flag delta")

    # Spoiler & dark-thread guard
    joined_text = "\n".join(n["text"] for n in authored_nodes)
    for forbidden in ("去世", "过世", "遗物", "亡母", "在天之灵", "穿着它的我好不好看", "穿着它的我漂亮吗"):
        a.check(forbidden not in joined_text, f"Forbidden spoiler phrase absent: {forbidden}")

    # Graph reachability across all 4 choice combinations
    node_map = {n["id"]: n for n in nodes}
    for b1_idx in (0, 1):
        for c1_idx in (0, 1):
            cur = ev["start"]
            visited = []
            steps = 0
            while cur != "@end" and steps < 500:
                a.check(cur in node_map, f"Valid node target {cur}")
                nd = node_map[cur]
                visited.append(cur)
                if nd["id"] == "al2_choice_b1":
                    cur = nd["choices"][b1_idx]["next"]
                elif nd["id"] == "al2_choice_c1":
                    cur = nd["choices"][c1_idx]["next"]
                else:
                    cur = nd["choices"][0]["next"]
                steps += 1
            a.equal(cur, "@end", f"Path (B1={b1_idx}, C1={c1_idx}) terminates cleanly at @end")
            a.check("al2_134" in visited and "al2_142" in visited and "al2_214" in visited, "Path hits convergence & ending")

    # Localization checks
    zh_strings = json.loads((ROOT / "data/localization/zh_CN.json").read_text(encoding="utf-8"))["strings"]
    en_strings = json.loads((ROOT / "data/localization/en.json").read_text(encoding="utf-8"))["strings"]
    prefix = f"collections.character_events.{EVENT_ID}"
    for key_suffix in ("title", "teaser", "gallery.caption"):
        full_key = f"{prefix}.{key_suffix}"
        a.check(bool(zh_strings.get(full_key)), f"zh_CN has {full_key}")
        en_val = en_strings.get(full_key, "")
        a.check(bool(en_val), f"en has {full_key}")
        a.check(not CJK_RE.search(en_val), f"en {full_key} has zero CJK")

    for n in nodes:
        nid = n["id"]
        if n["presentation"] != "choice":
            for field in ("text", "speaker_label"):
                fk = f"{prefix}.nodes.{nid}.{field}"
                a.equal(zh_strings.get(fk), n[field], f"zh_CN matches {fk}")
                ev_en = en_strings.get(fk, "")
                a.check(bool(ev_en), f"en has {fk}")
                a.check(not CJK_RE.search(ev_en), f"en {fk} has zero CJK")
        for ch in n["choices"]:
            ck = f"{prefix}.nodes.{nid}.choices.{ch['id']}.label"
            a.equal(zh_strings.get(ck), ch["label"], f"zh_CN matches {ck}")
            ce_en = en_strings.get(ck, "")
            a.check(bool(ce_en), f"en has {ck}")
            a.check(not CJK_RE.search(ce_en), f"en {ck} has zero CJK")

    # Technical asset checks (Asuka sample_gown + Maki interview)
    portrait_files = [
        "assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/smile.png",
        "assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/proud.png",
        "assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/reluctant_cuff.png",
        "assets/characters/maki_original_style_v1/doc_maki/interview/neutral.png",
        "assets/characters/maki_original_style_v1/doc_maki/interview/focused.png",
        "assets/characters/maki_original_style_v1/doc_maki/interview/worried.png",
        "assets/characters/maki_original_style_v1/doc_maki/interview/relieved.png",
    ]
    for rel_p in portrait_files:
        fp = ROOT / rel_p
        a.check(fp.is_file(), f"Portrait exists: {rel_p}")
        with Image.open(fp) as im:
            a.equal(im.size, (1024, 1536), f"{rel_p} size 1024x1536")
            a.equal(im.mode, "RGBA", f"{rel_p} RGBA mode")
            a.check(im.getpixel((0, 0))[3] == 0 and im.getpixel((1023, 0))[3] == 0, f"{rel_p} top corners transparent")
        imp = ROOT / (rel_p + ".import")
        a.check(imp.is_file(), f"Import file exists: {rel_p}.import")
        if imp.is_file():
            a.check("mipmaps/generate=true" in imp.read_text(encoding="utf-8"), f"{rel_p}.import has mipmaps/generate=true")

    if a.failures:
        print(f"FAIL: {len(a.failures)} failure(s) out of {a.checks} checks:")
        for f in a.failures[:40]:
            print(" -", f)
        return 1
    print(f"PASS: {a.checks} checks; 0 failure(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
