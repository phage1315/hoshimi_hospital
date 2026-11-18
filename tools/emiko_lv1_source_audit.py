#!/usr/bin/env python3
"""Independent verbatim manuscript, schema, 27-path graph, localization, and asset audit
for Emiko Mido (`doc_emiko`) Relationship Lv1 event:
《她的手术》 / *Her Kind of Surgery* (`emiko_lv1_first_operation`, V2.2).
"""

from __future__ import annotations

import hashlib
import itertools
import json
import re
import sys
from pathlib import Path

from jsonschema import Draft202012Validator
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT = ROOT / "research/source_scripts/HOSHIMI_MIDO_EMIKO_LV1_HER_SURGERY_V2_2.md"
EN_JSON = ROOT / "research/translations/emiko_lv1_en.json"
EVENTS_JSON = ROOT / "data/staff/doc_emiko/events.json"
RELATIONSHIP_JSON = ROOT / "data/staff/doc_emiko/relationship.json"
SCHEMA_JSON = ROOT / "data/schemas/content.schema.json"
BACKGROUNDS_JSON = ROOT / "data/backgrounds.json"
ZH_LOCALE = ROOT / "data/localization/zh_CN.json"
EN_LOCALE = ROOT / "data/localization/en.json"
MANIFEST_JSON = ROOT / "research/imports/emiko_lv1_2026-11-14.json"

EVENT_ID = "emiko_lv1_first_operation"
EXPECTED_MANUSCRIPT_SHA256 = "b1364ddf58d799bcdda710e774b72936c39c9dfad7fb608e86430ed865de694a"
CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\u3040-\u30ff\uf900-\ufaff]")

FORBIDDEN_ZH = ["腹腔镜", "气腹", "监视器", "戳卡", "麻醉医师", "麻醉科医生", "御堂抱臂站在半步之外", "关腹后最终清点"]
FORBIDDEN_EN = ["laparoscop", "pneumoperitoneum", "trocar", "anesthesiologist"]

checks = 0
failures: list[str] = []


def require(cond: bool, label: str) -> None:
    global checks
    checks += 1
    if not cond:
        failures.append(label)


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def reconstruct_manuscript(md_text: str) -> tuple[dict[str, list[tuple[str, str]]], dict[str, str]]:
    """Independently parse V2.2 manuscript into segmented (speaker_label, text) lists + choice labels."""
    sec2 = md_text.split("## 二、 完整中文 VN 剧本正文", 1)[1].split("> **【事件结束｜原子性结算】**", 1)[0]
    buckets: dict[str, list[tuple[str, str]]] = {
        "pre_b1": [],
        "b1_a": [],
        "b1_b": [],
        "b1_c": [],
        "b1_to_c1": [],
        "c1_a": [],
        "c1_b": [],
        "c1_c": [],
        "c1_to_e1": [],
        "e1_a": [],
        "e1_b": [],
        "e1_c": [],
        "post_e1": [],
    }
    choice_labels: dict[str, str] = {}
    cur_bucket = "pre_b1"
    cur_choice = ""
    in_header = False

    unbold = [
        ("头侧安静了半秒，本庄萌恵", "本庄萌恵"),
        ("话音落下的瞬间，她向器械台方向平伸出右手", "御堂江美子"),
        ("坂口隆司手里的拉钩稳稳没动", "坂口隆司"),
        ("头侧的本庄萌恵没忍住", "本庄萌恵"),
        ("布帘后沉默了一秒，传来患者", "患者"),
        ("坂口隆司挑了挑眉", "坂口隆司"),
        ("坂口隆司听出了这句冷话底下的意思", "坂口隆司"),
        ("御堂没有正面接茬", "御堂江美子"),
    ]

    for raw in sec2.splitlines():
        s = raw.strip()
        if s.startswith("### Scene "):
            in_header = True
            continue
        if in_header:
            if s == "---":
                in_header = False
            continue
        if not s or s == "---" or s.startswith("*选项说明"):
            continue
        m_ch = re.match(r"^\*\*【选择 \d+（Choice ([BCE]1)）：.+】\*\*$", s)
        if m_ch:
            cur_choice = m_ch.group(1).lower()
            continue
        m_opt = re.match(r"^- \*\*选项 ([ABC])(?:（[^）]+）)?：(.+)\*\*$", s)
        if m_opt:
            choice_labels[f"choice_em1_{cur_choice}_{m_opt.group(1).lower()}"] = m_opt.group(2)
            continue
        m_br = re.match(r"^#### 【选择选项 ([ABC]) 后的分支演出(?:（[^）]+）)?】$", s)
        if m_br:
            cur_bucket = f"{cur_choice}_{m_br.group(1).lower()}"
            continue
        if s.startswith("> **【分支汇合点"):
            cur_bucket = {"b1": "b1_to_c1", "c1": "c1_to_e1", "e1": "post_e1"}[cur_choice]
            continue

        m1 = re.match(r"^\*\*([^*]+)\*\*：(「.*」)$", s)
        if m1:
            buckets[cur_bucket].append((m1.group(1), m1.group(2)))
            continue
        m2 = re.match(r"^\*\*([^*]+)\*\*（(.+?)）：(「.*」)$", s)
        if m2:
            sp, act, q = m2.groups()
            buckets[cur_bucket].append(("旁白", f"{sp}（{act}）："))
            buckets[cur_bucket].append((sp, q))
            continue
        m3 = re.match(r"^([^「]+?)：(「[^「」]+」)$", s)
        if m3:
            pref, q = m3.groups()
            sp = next(lbl for k, lbl in unbold if pref.startswith(k))
            buckets[cur_bucket].append(("旁白", f"{pref}："))
            buckets[cur_bucket].append((sp, q))
            continue
        # Only inline Markdown bold markers (**...**) on narrator emphasis lines are stripped:
        buckets[cur_bucket].append(("旁白", s.replace("**", "")))

    return buckets, choice_labels


def main() -> int:
    require(MANUSCRIPT.is_file(), "V2.2 manuscript exists")
    require(sha256_of(MANUSCRIPT) == EXPECTED_MANUSCRIPT_SHA256, "V2.2 manuscript SHA-256 matches verbatim upload")
    require(EN_JSON.is_file(), "English translation JSON exists")
    require(MANIFEST_JSON.is_file(), "Import manifest exists")

    events = json.loads(EVENTS_JSON.read_text(encoding="utf-8"))
    by_id = {e["id"]: e for e in events}
    require(
        set(by_id.keys()) == {"emiko_office_denied", "emiko_intro_rumored_hands", "emiko_lv1_first_operation", "emiko_lv2_follow_my_lead"},
        "All 4 doc_emiko events preserved in events.json",
    )

    event = by_id[EVENT_ID]
    lv0 = by_id["emiko_intro_rumored_hands"]
    rel = json.loads(RELATIONSHIP_JSON.read_text(encoding="utf-8"))

    # Schema validation across all doc_emiko events
    schema = json.loads(SCHEMA_JSON.read_text(encoding="utf-8"))
    validator = Draft202012Validator({"$ref": "#/$defs/character_event", "$defs": schema["$defs"]})
    for eid, ev_obj in by_id.items():
        errs = list(validator.iter_errors(ev_obj))
        require(len(errs) == 0, f"Schema valid for {eid}: {[e.message for e in errs[:3]]}")

    # Gate & settlement checks (Section 一.1-3)
    require(event["actor_id"] == "doc_emiko", "actor_id == doc_emiko")
    require(event["title"] == "她的手术", "Chinese title == 她的手术")
    require(event["chapter"] == 1 and event["target_level"] == 1, "chapter == 1 and target_level == 1")
    require(event["category"] == "bond", "category == bond")
    require(event["location_id"] == "or" and event["trigger_mode"] == "location", "Workday OR location trigger")
    require(event["time_start"] == 540 and event["time_end"] == 1019, "09:00-16:59 OR window")
    require(event["minutes"] == 90, "minutes == 90")
    require(event["locks_saving"] is True, "locks_saving == True")
    require("auto_follow_up" not in lv0, "Lv0 does NOT force next-day jump into Lv1")
    require(
        "emiko_intro_complete" in lv0["nodes"][-1]["choices"][0]["flags"],
        "Lv0 @end sets emiko_intro_complete in addition to event completion history",
    )
    cond = event["conditions"]
    require(cond["required_events"] == ["emiko_intro_rumored_hands"], "Requires emiko_intro_rumored_hands")
    require(cond["days_after_required_events"] == 3, "3-day post-Lv0 cooldown")
    require(cond["min_familiarity"] == 0 and cond["min_affection"] == 0, "Zero Familiarity/Affection gate")
    require(
        cond["special_requirements"] == [{"type": "player_attribute", "attribute": "skill", "minimum": 75}],
        "Surgery >= 75 gate",
    )
    require(event["completion_familiarity_bonus"] == 10, "Fixed Familiarity +10 milestone bonus")
    require(event["benefit_id"] == "", "Lv1 does NOT unlock surgical team (deferred to Lv2)")
    require(
        event["completion_story_flags"] == ["emiko_lv1_complete", "emiko_postop_excitement_hint"],
        "completion_story_flags sets emiko_lv1_complete & emiko_postop_excitement_hint",
    )
    lv1_slot = next(s for s in rel["rank_slots"] if s["target_level"] == 1)
    require(
        lv1_slot["event_id"] == EVENT_ID and lv1_slot["min_familiarity"] == 0,
        "relationship.json rank_slot Lv1 aligned",
    )

    # Reconstruct manuscript and verify all 27 choice paths verbatim
    buckets, exp_choices = reconstruct_manuscript(MANUSCRIPT.read_text(encoding="utf-8"))
    nodes = event["nodes"]
    require(len(nodes) == 213, f"213 total nodes (got {len(nodes)})")
    node_map = {n["id"]: n for n in nodes}

    for ch_nid, prefix in [("em1_choice_b1", "b1"), ("em1_choice_c1", "c1"), ("em1_choice_e1", "e1")]:
        ch_node = node_map[ch_nid]
        require(ch_node["presentation"] == "choice" and ch_node["text"] == "", f"{ch_nid} choice presentation")
        require(len(ch_node["choices"]) == 3, f"{ch_nid} has 3 options")
        for idx, letter in enumerate(("a", "b", "c")):
            cid = f"choice_em1_{prefix}_{letter}"
            opt = ch_node["choices"][idx]
            require(opt["id"] == cid, f"{ch_nid} option {idx} id == {cid}")
            require(opt["label"] == exp_choices[cid], f"Verbatim label for {cid}")
            require(opt["effects"] == {"affection": 0, "familiarity": 0}, f"Zero stat delta on {cid}")
            require(opt["flags"] == [], f"Zero flag delta on {cid}")

    visited_all: set[str] = set()
    for b_pick, c_pick, e_pick in itertools.product(("a", "b", "c"), repeat=3):
        expected_seq = (
            buckets["pre_b1"]
            + buckets[f"b1_{b_pick}"]
            + buckets["b1_to_c1"]
            + buckets[f"c1_{c_pick}"]
            + buckets["c1_to_e1"]
            + buckets[f"e1_{e_pick}"]
            + buckets["post_e1"]
        )
        picks = {
            "em1_choice_b1": f"choice_em1_b1_{b_pick}",
            "em1_choice_c1": f"choice_em1_c1_{c_pick}",
            "em1_choice_e1": f"choice_em1_e1_{e_pick}",
        }
        cur = event["start"]
        actual_seq: list[tuple[str, str]] = []
        steps = 0
        while cur != "@end" and steps < 300:
            require(cur in node_map, f"Valid target {cur} on {b_pick}/{c_pick}/{e_pick}")
            visited_all.add(cur)
            nd = node_map[cur]
            if cur in picks:
                chosen = next(c for c in nd["choices"] if c["id"] == picks[cur])
            else:
                require(nd["presentation"] == "authored", f"{cur} authored presentation")
                actual_seq.append((nd["speaker_label"], nd["text"]))
                require(len(nd["choices"]) == 1, f"{cur} single continue")
                chosen = nd["choices"][0]
                require(chosen["effects"] == {"affection": 0, "familiarity": 0}, f"{cur} zero stat delta")
                if cur == "em1_210":
                    require(
                        chosen["flags"] == ["emiko_lv1_complete", "emiko_postop_excitement_hint"],
                        "em1_210 @end sets completion flags",
                    )
                else:
                    require(chosen["flags"] == [], f"{cur} zero intermediate flags")
            cur = chosen["next"]
            steps += 1
        require(cur == "@end", f"Path {b_pick}/{c_pick}/{e_pick} reaches @end")
        require(
            actual_seq == expected_seq,
            f"Path {b_pick}/{c_pick}/{e_pick} 100% verbatim match ({len(actual_seq)} vs {len(expected_seq)} beats)",
        )

    require(visited_all == set(node_map.keys()), "Zero unreachable orphan nodes across 27 paths")

    # Verify V2.2 4 final-review fixes & Scene F mask-removal staging
    require(
        "御堂退开半步，双手仍保持在身前的无菌区域，冷眼看着他的起手动作。" == node_map["em1_156"]["text"],
        "V2.2 Fix #2: sterile hand posture in Scene E Branch A",
    )
    require(
        "「术末最终清点——纱布、缝针、器械数目全部正确。」" == node_map["em1_170"]["text"],
        "V2.2 Fix #3: end-of-case final count phrasing in Scene E",
    )
    require(
        "「不用再往深处追。贴着胆囊颈这一侧，把要处理的两条结构重新确认一遍。」" == node_map["em1_099"]["text"],
        "V2.2 Fix #4: natural gallbladder neck dual-confirmation phrasing in Scene C",
    )
    for nid_num in range(186, 193):
        nd = node_map[f"em1_{nid_num:03d}"]
        require(
            nd.get("hide_portrait") is True and "event_portraits" not in nd,
            f"V2.2 Fix #1: em1_{nid_num:03d} hides unmasked scrubs before mask is untied",
        )
    require(
        node_map["em1_193"]["event_portraits"][0]["path"].endswith("doc_emiko/scrubs/warm.png"),
        "V2.2 Fix #1: em1_193 reveals unmasked scrubs/warm right after mask removal",
    )

    # Check zero forbidden terms & zero anonymous_unmet overrides
    for nd in nodes:
        require("anonymous_unmet" not in nd, f"{nd['id']} does not mask supporting cast names")
        for bad in FORBIDDEN_ZH:
            require(bad not in nd["text"], f"{nd['id']} free of '{bad}'")

    # Background & RGBA portrait technical validation (metadata/format/alpha only, per AGENTS.md)
    bg_map = {row["id"]: row["path"] for row in json.loads(BACKGROUNDS_JSON.read_text(encoding="utf-8"))}
    require(event["background_id"] in bg_map, "Event background_id registered")
    portrait_paths: set[str] = set()
    for nd in nodes:
        bg_id = nd["background_id"]
        require(bg_id in bg_map and (ROOT / bg_map[bg_id]).is_file(), f"{nd['id']} background {bg_id} exists")
        for p in nd.get("event_portraits", []):
            portrait_paths.add(p["path"])

    for rel_path in sorted(portrait_paths):
        full = ROOT / rel_path
        require(full.is_file(), f"Portrait exists: {rel_path}")
        with Image.open(full) as im:
            require(im.mode == "RGBA", f"Portrait RGBA mode: {rel_path} ({im.mode})")
            alpha_min, alpha_max = im.getchannel("A").getextrema()
            require(alpha_min == 0 and alpha_max > 200, f"Portrait transparent alpha channel: {rel_path}")

    # Bilingual localization audit
    zh_strings = json.loads(ZH_LOCALE.read_text(encoding="utf-8"))["strings"]
    en_strings = json.loads(EN_LOCALE.read_text(encoding="utf-8"))["strings"]
    prefix = f"collections.character_events.{EVENT_ID}."

    expected_keys = {
        f"{prefix}title",
        f"{prefix}teaser",
        f"{prefix}gallery.caption",
    }
    for nd in nodes:
        nid = nd["id"]
        if nd["text"]:
            expected_keys.add(f"{prefix}nodes.{nid}.text")
        expected_keys.add(f"{prefix}nodes.{nid}.speaker_label")
        for ch in nd["choices"]:
            expected_keys.add(f"{prefix}nodes.{nid}.choices.{ch['id']}.label")

    actual_zh_keys = {k for k in zh_strings if k.startswith(prefix)}
    actual_en_keys = {k for k in en_strings if k.startswith(prefix)}
    require(actual_zh_keys == expected_keys, f"Exact zh_CN key set ({len(actual_zh_keys)} == {len(expected_keys)})")
    require(actual_en_keys == expected_keys, f"Exact en key set ({len(actual_en_keys)} == {len(expected_keys)})")
    require(en_strings[f"{prefix}title"] == "Her Kind of Surgery", "English title preserved as 'Her Kind of Surgery'")

    for k in sorted(expected_keys):
        en_val = en_strings.get(k, "")
        require(bool(en_val.strip()), f"Non-empty English translation for {k}")
        require(not CJK_RE.search(en_val), f"Zero CJK characters in English {k}: {en_val[:60]!r}")
        low_en = en_val.lower()
        for bad_en in FORBIDDEN_EN:
            require(bad_en not in low_en, f"Zero '{bad_en}' in English {k}")

    if failures:
        print(f"FAIL: {len(failures)} failure(s) out of {checks} checks:")
        for item in failures[:30]:
            print(" -", item)
        return 1
    print(f"PASS: {checks} checks; 0 failure(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
