#!/usr/bin/env python3
"""Independent verbatim manuscript, 81-path graph, V1.1 revision, localization, and asset audit
for Emiko Mido (`doc_emiko`) Relationship Lv3 event:
《今天我主刀》 / *Today, I Lead the Table* (`emiko_lv3_today_i_lead`, V1.1).
"""

from __future__ import annotations

import hashlib
import itertools
import json
import re
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT = ROOT / "research/source_scripts/HOSHIMI_MIDO_EMIKO_LV3_TODAY_I_LEAD_V1_1.md"
EN_JSON = ROOT / "research/translations/emiko_lv3_en.json"
EVENTS_JSON = ROOT / "data/staff/doc_emiko/lv3_events.json"
BUNDLE_JSON = ROOT / "data/staff/doc_emiko/bundle.json"
PROFILE_JSON = ROOT / "data/staff/doc_emiko/profile.json"
RELATIONSHIP_JSON = ROOT / "data/staff/doc_emiko/relationship.json"
BACKGROUNDS_JSON = ROOT / "data/backgrounds.json"
ZH_LOCALE = ROOT / "data/localization/zh_CN.json"
EN_LOCALE = ROOT / "data/localization/en.json"
MANIFEST_JSON = ROOT / "research/imports/emiko_lv3_2026-11-15.json"

EVENT_ID = "emiko_lv3_today_i_lead"
EXPECTED_MANUSCRIPT_SHA256 = "54e959f0de88af4a382303b8779eff2ba94bc9bc9ad379c398168dac5426e71f"
CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\u3040-\u30ff\uf900-\ufaff]")
BRACE_RE = re.compile(r"\{[A-Za-z_][A-Za-z0-9_]*\}")

# V1.0 superseded strings & prohibited phrases (Section 4 & Section 5 Revision Log + user 27yo age & silver-violet hair revisions)
FORBIDDEN_ZH = [
    "上次八十五，上上次之外的主刀八十八",
    "争各凭本事",
    "各凭本事来试",
    "你自己在页边加的那几条复核顺序也不用擦",
    "连半句复核都省了",
    "侧壁钳",
    "五十二岁",
    "52岁",
    "乌黑利落的长发",
    "长发重新束得一丝不苟",
]

checks = 0
failures: list[str] = []


def require(cond: bool, label: str) -> None:
    global checks
    checks += 1
    if not cond:
        failures.append(label)


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def parse_manuscript_buckets(md_text: str) -> tuple[dict[str, list[tuple[str, str]]], dict[str, str]]:
    sec2 = md_text.split("## 二、 完整中文 VN 剧本正文", 1)[1].split("**【御堂江美子 Relationship Lv3《今天我主刀》事件结束】**", 1)[0]
    buckets: dict[str, list[tuple[str, str]]] = {
        k: []
        for k in (
            "s1",
            "s",
            "o",
            "g",
            "c1a",
            "c1a_s",
            "c1a_og",
            "c1a_tail",
            "c1b",
            "c1c",
            "s1r",
            "s2",
            "s3",
            "c2a",
            "c2b",
            "c2c",
            "s3r",
            "s4",
            "s5",
            "s6",
            "c3a",
            "c3b",
            "c3c",
            "s6r",
        )
    }
    choices_zh: dict[str, str] = {}
    mixed_prefixes = [
        ("听见推门声，寿司店师傅", "寿司店师傅"),
        ("本庄萌恵", "本庄萌恵"),
        ("站在一旁的坂口隆司", "坂口隆司"),
        ("女患者", "患者"),
        ("杉村弘子", "杉村弘子"),
        ("坂口隆司", "坂口隆司"),
        ("御堂江美子", "御堂江美子"),
    ]

    cur = ""
    in_meta = False
    cur_choice = ""

    for raw in sec2.splitlines():
        s = raw.strip()
        if s.startswith("### 【第一幕"):
            cur = "s1"
            in_meta = True
            continue
        if s.startswith("### 【第二幕"):
            cur = "s2"
            in_meta = True
            continue
        if s.startswith("### 【第三幕"):
            cur = "s3"
            in_meta = True
            continue
        if s.startswith("### 【第四幕"):
            cur = "s4"
            in_meta = True
            continue
        if s.startswith("### 【第五幕"):
            cur = "s5"
            in_meta = True
            continue
        if s.startswith("### 【第六幕"):
            cur = "s6"
            in_meta = True
            continue
        if in_meta:
            if s == "**【玩家可见正文】**":
                in_meta = False
            continue
        if not s or s == "---" or s.startswith("*性质：") or s.startswith("*(") or s.startswith("#### 3."):
            continue
        if s.startswith("#### 〈前置分支 S"):
            cur = "s"
            continue
        if s.startswith("#### 〈前置分支 O"):
            cur = "o"
            continue
        if s.startswith("#### 〈前置分支 G"):
            cur = "g"
            continue
        m_ch = re.match(r"^\*\*【选择 (\d+)：.+】\*\*$", s)
        if m_ch:
            cur_choice = f"c{m_ch.group(1)}"
            continue
        m_opt = re.match(r"^- \*\*选项 ([ABC])：(.+)\*\*$", s)
        if m_opt:
            choices_zh[f"choice_em3_{cur_choice}_{m_opt.group(1).lower()}"] = m_opt.group(2)
            continue
        m_br = re.match(r"^#### 【分支 ([ABC]) — .+】$", s)
        if m_br:
            cur = f"{cur_choice}{m_br.group(1).lower()}"
            continue
        if s.startswith("- **〈若前置为 S〉** "):
            rest = s.replace("- **〈若前置为 S〉** ", "", 1)
            m = re.match(r"^坂口隆司：(「.+」)$", rest)
            require(bool(m), f"Valid S conditional line: {s}")
            if m:
                buckets["c1a_s"].append(("坂口隆司", m.group(1)))
            continue
        if s.startswith("- **〈若前置为 O 或 G〉** "):
            rest = s.replace("- **〈若前置为 O 或 G〉** ", "", 1)
            m = re.match(r"^坂口隆司：(「.+」)$", rest)
            require(bool(m), f"Valid O/G conditional line: {s}")
            if m:
                buckets["c1a_og"].append(("坂口隆司", m.group(1)))
            continue
        if s.startswith("> **【主线汇合"):
            cur = {"c1": "s1r", "c2": "s3r", "c3": "s6r"}[cur_choice]
            continue
        if cur == "c1a" and buckets["c1a_s"]:
            cur = "c1a_tail"

        m_pure = re.match(r"^(御堂江美子|坂口隆司|杉村弘子|本庄萌恵|寿司店师傅|患者|麻醉医生|灌注师)：(「.+」)$", s)
        if m_pure:
            buckets[cur].append((m_pure.group(1), m_pure.group(2)))
            continue
        if "：「" in s:
            act, quote = s.split("：", 1)
            spk = next((t for pfx, t in mixed_prefixes if act.startswith(pfx)), None)
            require(spk is not None, f"Mapped mixed prefix: {s}")
            if spk is not None:
                buckets[cur].append(("旁白", act + "："))
                buckets[cur].append((spk, quote))
            continue
        buckets[cur].append(("旁白", s))

    return buckets, choices_zh


def simulate_path(nodes_by_id: dict[str, dict], probe: str, c1: str, c2: str, c3: str) -> tuple[list[tuple[str, str]], set[str]]:
    visited_ids: set[str] = set()
    transcript: list[tuple[str, str]] = []
    chosen_ids: set[str] = set()
    nid = "em3_s1_01"
    steps = 0
    while nid != "@end":
        steps += 1
        if steps > 1000:
            raise RuntimeError(f"Infinite loop on path {(probe, c1, c2, c3)} at {nid}")
        node = nodes_by_id[nid]
        visited_ids.add(nid)
        if node["presentation"] == "authored":
            txt = node["text"].replace("{recent_assistant_doctor}", "[最近非御堂一助医生]")
            transcript.append((node["speaker_label"], txt))
            ch = node["choices"][0]
            chosen_ids.add(ch["id"])
            if nid == "em3_s1_52":
                nid = {"S": "em3_s_01", "O": "em3_o_01", "G": "em3_g_01"}[probe]
            elif nid == "em3_c1a_04":
                cond = ch.get("next_if_choice", {})
                if cond and cond["choice_id"] in chosen_ids:
                    nid = cond["next"]
                else:
                    nid = ch["next"]
                expected_c1a = "em3_c1a_s_01" if probe == "S" else "em3_c1a_og_01"
                require(nid == expected_c1a, f"Branch A conditional routing matches probe={probe}")
            else:
                nid = ch["next"]
        elif node["presentation"] == "choice":
            pick_map = {
                "em3_choice_c1": f"choice_em3_c1_{c1}",
                "em3_choice_c2": f"choice_em3_c2_{c2}",
                "em3_choice_c3": f"choice_em3_c3_{c3}",
            }
            want = pick_map[nid]
            picked = next(c for c in node["choices"] if c["id"] == want)
            chosen_ids.add(picked["id"])
            nid = picked["next"]
        else:
            raise RuntimeError(f"Unexpected presentation on {nid}")
    return transcript, visited_ids


def main() -> None:
    require(MANUSCRIPT.is_file(), "Manuscript V1.1 exists")
    require(sha256_of(MANUSCRIPT) == EXPECTED_MANUSCRIPT_SHA256, "Manuscript SHA-256 matches V1.1 lock")

    md_text = MANUSCRIPT.read_text(encoding="utf-8")
    buckets, expected_choices = parse_manuscript_buckets(md_text)

    bundle = json.loads(BUNDLE_JSON.read_text(encoding="utf-8"))
    require("lv3_events.json" in bundle.get("additional_character_event_files", []), "bundle.json registers lv3_events.json")

    rel = json.loads(RELATIONSHIP_JSON.read_text(encoding="utf-8"))
    slot3 = next((s for s in rel["rank_slots"] if s["target_level"] == 3), {})
    require(slot3.get("event_id") == EVENT_ID, "relationship.json Lv3 slot points to emiko_lv3_today_i_lead")
    require(slot3.get("content_status") == "authored", "relationship.json Lv3 slot is authored")
    require(slot3.get("min_familiarity") == 40, "relationship.json Lv3 min_familiarity == 40")
    require(slot3.get("cooldown_days") == 3, "relationship.json Lv3 cooldown_days == 3")
    special_reqs = slot3.get("special_requirements", [])
    require(
        {"type": "player_attribute", "attribute": "presence", "minimum": 20} in special_reqs,
        "relationship.json Lv3 requires presence >= 20",
    )
    require(
        {"type": "staff_unlocked", "actor_id": "doc_artoria"} in special_reqs,
        "relationship.json Lv3 requires doc_artoria met",
    )

    events = json.loads(EVENTS_JSON.read_text(encoding="utf-8"))
    require(len(events) == 1 and events[0]["id"] == EVENT_ID, "lv3_events.json contains emiko_lv3_today_i_lead")
    ev = events[0]
    require(ev["trigger_mode"] == "after_work", "trigger_mode == after_work")
    require(ev["locks_saving"] is True, "locks_saving == True")
    require(ev["target_level"] == 3, "target_level == 3")
    require(ev["completion_day_offset"] == 1 and ev["completion_absolute_clock"] == 840, "Next-day 14:00 completion clock")
    require(
        set(ev["completion_story_flags"]) == {"emiko_lv3_complete", "emiko_cabg_teaching_complete"},
        "Exact completion_story_flags without surgery-director withdrawal flags",
    )

    nodes = ev["nodes"]
    require(len(nodes) == 314, f"Expected 314 total nodes, got {len(nodes)}")
    nodes_by_id = {n["id"]: n for n in nodes}
    require(nodes_by_id["em3_s3r_16"]["choices"][0]["id"] == "em3_cabg_teaching_complete", "Scene 3 end carries CABG teaching choice ID")

    # Verify all 3 choices match verbatim
    for cid_node in ("em3_choice_c1", "em3_choice_c2", "em3_choice_c3"):
        for ch in nodes_by_id[cid_node]["choices"]:
            cid = ch["id"]
            require(ch["label"] == expected_choices[cid], f"Choice {cid} verbatim match")
            require(ch["effects"] == {"affection": 0, "familiarity": 0} and ch["flags"] == [], f"Choice {cid} zero stat/flag side effects")

    # Exhaustive 3 x 3 x 3 x 3 = 81 path audit
    union_visited: set[str] = set()
    for probe, c1, c2, c3 in itertools.product(("S", "O", "G"), ("a", "b", "c"), ("a", "b", "c"), ("a", "b", "c")):
        expected_seq: list[tuple[str, str]] = []
        expected_seq.extend(buckets["s1"])
        expected_seq.extend(buckets[probe.lower()])
        if c1 == "a":
            expected_seq.extend(buckets["c1a"])
            expected_seq.extend(buckets["c1a_s" if probe == "S" else "c1a_og"])
            expected_seq.extend(buckets["c1a_tail"])
        else:
            expected_seq.extend(buckets[f"c1{c1}"])
        expected_seq.extend(buckets["s1r"])
        expected_seq.extend(buckets["s2"])
        expected_seq.extend(buckets["s3"])
        expected_seq.extend(buckets[f"c2{c2}"])
        expected_seq.extend(buckets["s3r"])
        expected_seq.extend(buckets["s4"])
        expected_seq.extend(buckets["s5"])
        expected_seq.extend(buckets["s6"])
        expected_seq.extend(buckets[f"c3{c3}"])
        expected_seq.extend(buckets["s6r"])

        actual_seq, visited = simulate_path(nodes_by_id, probe, c1, c2, c3)
        union_visited |= visited
        path_tag = f"path({probe},{c1},{c2},{c3})"
        require(len(actual_seq) == len(expected_seq), f"{path_tag} length {len(actual_seq)} == {len(expected_seq)}")
        for idx, (act_pair, exp_pair) in enumerate(zip(actual_seq, expected_seq)):
            require(act_pair == exp_pair, f"{path_tag}[{idx}] verbatim speaker+text match")

    require(union_visited == set(nodes_by_id.keys()), "Zero orphan nodes across union of 81 S/O/G paths")

    # Core dramatic anchors & V1.1 prohibitions
    all_zh_text = "\n".join(n["text"] for n in nodes if n["text"])
    for anchor in (
        "「今天我主刀。你绝对不会死。」",
        "「今天不打分。」",
        "「你已经不是来参加考试的了。」",
        "「当然。别指望我让你。」",
        "第一次给你做助手是八十五，上次换我主刀拿了八十八，今天总能摸到九十了吧？",
        "二十七岁的女患者躺在手术床中央。",
        "患者身份、二十七岁女性、",
        "银紫色的长发利落地垂在肩后，暗红修身上衣旁搭着一件剪裁干练的薄风衣，",
        "长发重新理得一丝不苟，",
    ):
        require(anchor in all_zh_text, f"Dramatic anchor preserved verbatim: {anchor}")
    for bad in FORBIDDEN_ZH:
        require(bad not in all_zh_text, f"Superseded V1.0 phrase absent: {bad}")

    # Scene 4 & 5 strict restraint check (no blush/intimate expressions)
    for n in nodes:
        if n["id"].startswith(("em3_s4_", "em3_s5_")):
            require(n["expression"] in ("neutral", "focused", "serious"), f"{n['id']} uses restrained expression {n['expression']}")

    # Localization & placeholder parity audit
    zh_strings = json.loads(ZH_LOCALE.read_text(encoding="utf-8"))["strings"]
    en_strings = json.loads(EN_LOCALE.read_text(encoding="utf-8"))["strings"]
    prefix = f"collections.character_events.{EVENT_ID}."
    zh_keys = {k for k in zh_strings if k.startswith(prefix)}
    en_keys = {k for k in en_strings if k.startswith(prefix)}
    require(zh_keys == en_keys and len(zh_keys) == 948, f"Exact locale key parity ({len(zh_keys)} event keys)")
    for k in sorted(en_keys):
        zv = zh_strings[k]
        ev_str = en_strings[k]
        require(bool(ev_str.strip()), f"Non-empty EN string: {k}")
        require(not CJK_RE.search(ev_str), f"Zero CJK leak in EN string: {k}")
        require(BRACE_RE.findall(zv) == BRACE_RE.findall(ev_str), f"Placeholder parity on {k}")

    bg_key = "collections.backgrounds.emiko_lv3_sushi_bar_night.label"
    require(bg_key in zh_strings and bg_key in en_strings and not CJK_RE.search(en_strings[bg_key]), "Sushi bar background localized")

    # Art asset technical checks (RGBA 1024x1536 portraits + 1376x768 background)
    profile = json.loads(PROFILE_JSON.read_text(encoding="utf-8"))
    for pkey in ("scrubs_masked/neutral", "scrubs_masked/focused"):
        rel_p = profile["visuals"]["portraits"].get(pkey, "")
        fp = ROOT / rel_p
        require(fp.is_file(), f"Portrait exists: {rel_p}")
        if fp.is_file():
            with Image.open(fp) as im:
                require(im.size == (1024, 1536) and im.mode == "RGBA", f"{pkey} is 1024x1536 RGBA")
                alpha = im.getchannel("A")
                require(alpha.getpixel((0, 0)) == 0 and alpha.getpixel((1023, 0)) == 0, f"{pkey} top corners transparent")

    for pat_rel in (
        "assets/characters/emiko_lv3_v1/cabg_patient/or_cap/panicked.png",
        "assets/characters/emiko_lv3_v1/cabg_patient/or_cap/relieved.png",
        "assets/characters/emiko_lv3_v1/cabg_patient/or_cap/mask_drowsy.png",
    ):
        fp = ROOT / pat_rel
        require(fp.is_file(), f"CABG patient portrait exists: {pat_rel}")
        if fp.is_file():
            with Image.open(fp) as im:
                require(im.size == (1448, 1086) and im.mode == "RGBA", f"{pat_rel} is 1448x1086 RGBA")
                alpha = im.getchannel("A")
                require(alpha.getpixel((0, 0)) == 0 and alpha.getpixel((1447, 0)) == 0, f"{pat_rel} top corners transparent")

    require("twenty-seven-year-old female patient" in en_strings[f"{prefix}nodes.em3_s2_03.text"], "EN em3_s2_03 reflects age 27")
    require("twenty-seven-year-old female," in en_strings[f"{prefix}nodes.em3_s2_28.text"], "EN em3_s2_28 reflects age 27")
    require("fifty-two-year-old" not in "\n".join(en_strings[k] for k in en_keys), "Zero residual fifty-two-year-old in EN")
    require("Long silver-violet hair" in en_strings[f"{prefix}nodes.em3_s1_04.text"], "EN em3_s1_04 reflects silver-violet hair")
    require("smoothed into flawless order" in en_strings[f"{prefix}nodes.em3_s5_06.text"], "EN em3_s5_06 reflects smoothed hair")
    require("Sleek black hair" not in "\n".join(en_strings[k] for k in en_keys), "Zero residual Sleek black hair in EN")

    bgs = {b["id"]: b for b in json.loads(BACKGROUNDS_JSON.read_text(encoding="utf-8"))}
    sushi_bg = bgs.get("emiko_lv3_sushi_bar_night", {})
    sushi_fp = ROOT / sushi_bg.get("path", "")
    require(sushi_fp.is_file(), "Sushi bar background PNG exists")
    if sushi_fp.is_file():
        with Image.open(sushi_fp) as im:
            require(im.size == (1376, 768), f"Sushi bar background size {im.size} == (1376, 768)")

    manifest = json.loads(MANIFEST_JSON.read_text(encoding="utf-8"))
    require(manifest["source_manuscript_sha256"] == EXPECTED_MANUSCRIPT_SHA256, "Import manifest SHA-256 matches")

    print(f"EMIKO LV3 SOURCE AUDIT: {checks} checks; {len(failures)} failure(s)")
    if failures:
        for f in failures[:30]:
            print("  FAIL:", f)
        sys.exit(1)


if __name__ == "__main__":
    main()
