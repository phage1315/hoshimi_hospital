#!/usr/bin/env python3
"""Verbatim source, portrait, and bilingual localization audit for Asuka Lv1:
《院长也是外科医生》 (`research/source_scripts/HOSHIMI_ASUKA_LV1_DIRECTOR_IS_ALSO_A_SURGEON_V1.md`).
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")

APPROVED_REPLACEMENTS = {
    "「早呀，坂口医生。患者刚刚已经接进手术间核对信息了，器械台那边也清点得很顺利哦。」": "「来得正好呀，坂口医生。患者刚刚已经接进手术间核对信息了，器械台那边也清点得很顺利哦。」",
    "「哼哼，小看人了吧？急着要签的文件我今天早上八点前就全部批完发回行政科了，上午剩下的时间，日历上可是堂堂正正标着『临床外勤』四个大字的。」": "「哼哼，小看人了吧？急着要签的文件我今天一早八点前就全部批完发回行政科了，眼下这段时间，日历上可是堂堂正正标着『临床外勤』四个大字的。」",
    "「我去换回白大褂继续批下午的件啦。下次有合适的手术需要第一助手，还记得叫我哦——回见啦，坂口君！」": "「我去换回白大褂继续批剩下的件啦。下次有合适的手术需要第一助手，还记得叫我哦——回见啦，坂口君！」",
}


def parse_manuscript_scene(lines: list[str]) -> list[tuple[str, str]]:
    beats: list[tuple[str, str]] = []
    for raw in lines:
        line = raw.strip()
        if not line or line == "---" or line.startswith("**【"):
            continue
        m = re.match(r"^\*\*(.+?)\*\*：(.+)$", line)
        if m:
            speaker_name = m.group(1)
            text = m.group(2).strip()
            role = {"城宮明日香": "actor", "坂口隆司": "player"}.get(speaker_name, "unknown")
            beats.append((role, text))
        else:
            beats.append(("narrator", line))
    return beats


def main() -> int:
    checks = 0
    failures: list[str] = []

    def expect(cond: bool, msg: str) -> None:
        nonlocal checks
        checks += 1
        if not cond:
            failures.append(msg)

    manuscript = (ROOT / "research/source_scripts/HOSHIMI_ASUKA_LV1_DIRECTOR_IS_ALSO_A_SURGEON_V1.md").read_text(encoding="utf-8")
    s1_part = manuscript.split("## 二、 Scene 1：术前 · 手术室刷手池", 1)[1].split("## 三、 Scene 2：", 1)[0]
    s2_part = manuscript.split("## 三、 Scene 2：", 1)[1].split("## 四、 Scene 3：", 1)[0]
    s3_part = manuscript.split("## 四、 Scene 3：术后 · 退出无菌工作区域", 1)[1].split("## 五、 事件结束标记与关系升级说明", 1)[0]

    ms_s1 = parse_manuscript_scene(s1_part.splitlines())
    ms_s3 = parse_manuscript_scene(s3_part.splitlines())

    events = {
        e["id"]: e
        for e in json.loads((ROOT / "data/staff/doc_asuka/events.json").read_text(encoding="utf-8"))
    }
    preop = events.get("asuka_lv1_director_surgeon_preop", {})
    postop = events.get("asuka_lv1_director_surgeon_postop", {})
    expect(bool(preop), "Missing asuka_lv1_director_surgeon_preop")
    expect(bool(postop), "Missing asuka_lv1_director_surgeon_postop")

    approved_hits = 0
    for scene_name, ms_beats, ev in [
        ("Scene 1", ms_s1, preop),
        ("Scene 3", ms_s3, postop),
    ]:
        nodes = ev.get("nodes", [])
        expect(len(nodes) == len(ms_beats), f"{scene_name}: beat count mismatch ({len(nodes)} vs {len(ms_beats)})")
        for idx, ((ms_role, ms_text), node) in enumerate(zip(ms_beats, nodes), start=1):
            nid = node["id"]
            expect(node["speaker"] == ms_role, f"{scene_name} #{idx} ({nid}): speaker mismatch {node['speaker']} != {ms_role}")
            expected_text = APPROVED_REPLACEMENTS.get(ms_text, ms_text)
            if ms_text in APPROVED_REPLACEMENTS:
                approved_hits += 1
            expect(node["text"] == expected_text, f"{scene_name} #{idx} ({nid}): text mismatch\n  got: {node['text']}\n  exp: {expected_text}")

    expect(approved_hits == 3, f"Expected exactly 3 user-approved time generalizations, hit {approved_hits}")

    # Audit Scene 2 light assistant lines in godot/systems/asuka_lv1.gd
    gd_text = (ROOT / "godot/systems/asuka_lv1.gd").read_text(encoding="utf-8")
    ms_s2_lines = re.findall(r"\*\*城宮明日香\*\*：（.+）|\*\*城宮明日香\*\*：(「.+?」)", s2_part)
    s2_quotes = [q for _, q in re.findall(r"(\*\*城宮明日香\*\*：)(「.+?」)", s2_part)]
    expect(len(s2_quotes) == 3, f"Expected 3 Scene 2 assistant lines in manuscript, found {len(s2_quotes)}")
    for q in s2_quotes:
        expect(q in gd_text, f"Scene 2 assistant line missing verbatim in asuka_lv1.gd: {q}")

    # Audit 7 RGBA portraits
    profile = json.loads((ROOT / "data/staff/doc_asuka/profile.json").read_text(encoding="utf-8"))
    portraits = profile["visuals"]["portraits"]
    expected_slots = [
        "scrubs/masked_bright",
        "scrubs/masked_smile",
        "scrubs/cap_smile",
        "scrubs/cap_critique",
        "scrubs/cap_shy",
        "scrubs/hair_down_smile",
        "scrubs/hair_down_wave",
    ]
    for slot in expected_slots:
        expect(slot in portraits, f"Missing portrait slot in doc_asuka profile: {slot}")
        p = ROOT / portraits.get(slot, "")
        expect(p.is_file(), f"Portrait file missing on disk: {p}")
        if p.is_file():
            img = Image.open(p)
            expect(img.mode == "RGBA", f"{slot}: image mode {img.mode} != RGBA")
            expect(img.size == (1024, 1536), f"{slot}: image size {img.size} != (1024, 1536)")
            expect(img.getpixel((0, 0))[3] == 0 and img.getpixel((1023, 0))[3] == 0, f"{slot}: top corners not transparent")

    # Audit zh_CN & en localization
    zh = json.loads((ROOT / "data/localization/zh_CN.json").read_text(encoding="utf-8"))["strings"]
    en = json.loads((ROOT / "data/localization/en.json").read_text(encoding="utf-8"))["strings"]
    for ev in (preop, postop):
        base = f"collections.character_events.{ev['id']}"
        for field in ("title", "teaser", "gallery.caption"):
            k = f"{base}.{field}"
            expect(bool(zh.get(k)), f"Missing zh_CN key {k}")
            expect(bool(en.get(k)), f"Missing en key {k}")
            expect(not CJK_RE.search(en.get(k, "")), f"CJK residue in en key {k}: {en.get(k)}")
        for node in ev["nodes"]:
            nid = node["id"]
            for field in ("text", "speaker_label"):
                k = f"{base}.nodes.{nid}.{field}"
                expect(bool(zh.get(k)), f"Missing zh_CN key {k}")
                expect(bool(en.get(k)), f"Missing en key {k}")
                expect(not CJK_RE.search(en.get(k, "")), f"CJK residue in en key {k}: {en.get(k)}")
            for choice in node["choices"]:
                k = f"{base}.nodes.{nid}.choices.{choice['id']}.label"
                expect(bool(zh.get(k)), f"Missing zh_CN key {k}")
                expect(bool(en.get(k)), f"Missing en key {k}")
                expect(not CJK_RE.search(en.get(k, "")), f"CJK residue in en key {k}: {en.get(k)}")

    if failures:
        for f in failures:
            print("FAIL:", f, file=sys.stderr)
        print(f"ASUKA LV1 SOURCE AUDIT: {checks} checks; {len(failures)} failure(s)", file=sys.stderr)
        return 1

    print(f"ASUKA LV1 SOURCE AUDIT: {checks} checks; 0 failure(s) (3/3 user-approved time generalizations verified)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
