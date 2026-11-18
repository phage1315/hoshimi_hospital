#!/usr/bin/env python3
"""Independent verbatim manuscript, schema, 27-path graph, localization, and asset audit
for Emiko Mido (`doc_emiko`) Relationship Lv2 event:
《这一次听你的》 / *This Time, I'll Follow Your Lead* (`emiko_lv2_follow_my_lead`, V2.1).
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
MANUSCRIPT = ROOT / "research/source_scripts/HOSHIMI_MIDO_EMIKO_LV2_FOLLOW_MY_LEAD_V2_1.md"
EN_JSON = ROOT / "research/translations/emiko_lv2_en.json"
EVENTS_JSON = ROOT / "data/staff/doc_emiko/events.json"
RELATIONSHIP_JSON = ROOT / "data/staff/doc_emiko/relationship.json"
SCHEMA_JSON = ROOT / "data/schemas/content.schema.json"
BACKGROUNDS_JSON = ROOT / "data/backgrounds.json"
ZH_LOCALE = ROOT / "data/localization/zh_CN.json"
EN_LOCALE = ROOT / "data/localization/en.json"
MANIFEST_JSON = ROOT / "research/imports/emiko_lv2_2026-11-14.json"

EVENT_ID = "emiko_lv2_follow_my_lead"
EXPECTED_MANUSCRIPT_SHA256 = "f972a30e2401dd836fd7275417bd4d0c489b928f8a14fcac6eb59d614dc7f660"
CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\u3040-\u30ff\uf900-\ufaff]")

# V2.1 prohibited / superseded terms (period setting + V2.0 -> V2.1 revision log)
FORBIDDEN_ZH = [
    "腹腔镜",
    "气腹",
    "直线切割",
    "闭合器",
    "机械吻合器",
    "麻醉医师",
    "麻醉科医生",
    "宽四分之一",
    "斜修两毫米",
    "松半格肠钳",
    "零张力",
    "彻底杜绝术后内疝",
    "至少一周后",
]
FORBIDDEN_EN = [
    "laparoscop",
    "pneumoperitoneum",
    "linear stapler",
    "gia stapler",
    "anesthesiologist",
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


def reconstruct_manuscript(md_text: str) -> tuple[dict[str, list[tuple[str, str]]], dict[str, str]]:
    """Independently parse V2.1 manuscript into segmented (speaker_label, text) lists + choice labels."""
    sec2 = md_text.split("## 二、 完整中文 VN 剧本正文", 1)[1].split("**【御堂江美子 Relationship Lv2 事件结束】**", 1)[0]
    buckets: dict[str, list[tuple[str, str]]] = {
        "pre_b1": [],
        "b1_a": [],
        "b1_b": [],
        "b1_c": [],
        "b1_to_d2": [],
        "d2_a": [],
        "d2_b": [],
        "d2_c": [],
        "d2_to_f3": [],
        "f3_a": [],
        "f3_b": [],
        "f3_c": [],
        "post_f3": [],
    }
    choice_labels: dict[str, str] = {}
    cur_bucket = "pre_b1"
    cur_choice = ""
    in_meta = False

    mixed_prefixes = [
        ("杉村弘子", "杉村弘子"),
        ("坂口隆司", "坂口隆司"),
        ("御堂江美子", "御堂江美子"),
        ("本庄萌恵", "本庄萌恵"),
        ("布帘后的女患者", "患者"),
        ("平车推经台旁时，女患者", "患者"),
    ]

    for raw in sec2.splitlines():
        s = raw.strip()
        if s.startswith("### 【Scene "):
            in_meta = True
            continue
        if in_meta:
            if s == "**【玩家可见正文】**":
                in_meta = False
            continue
        if not s or s == "---" or s.startswith("*性质："):
            continue
        m_ch = re.match(r"^\*\*【选择 (\d+)：.+】\*\*$", s)
        if m_ch:
            cur_choice = {"1": "b1", "2": "d2", "3": "f3"}[m_ch.group(1)]
            continue
        m_opt = re.match(r"^- \*\*选项 ([ABC])：(.+)\*\*$", s)
        if m_opt:
            choice_labels[f"choice_em2_{cur_choice}_{m_opt.group(1).lower()}"] = m_opt.group(2)
            continue
        m_br = re.match(r"^#### 【分支 ([ABC]) — .+】$", s)
        if m_br:
            cur_bucket = f"{cur_choice}_{m_br.group(1).lower()}"
            continue
        if s.startswith("> **【主线汇合"):
            cur_bucket = {"b1": "b1_to_d2", "d2": "d2_to_f3", "f3": "post_f3"}[cur_choice]
            continue

        m_pure = re.match(r"^(御堂江美子|坂口隆司|杉村弘子|本庄萌恵|患者)：(「.+」)$", s)
        if m_pure:
            buckets[cur_bucket].append((m_pure.group(1), m_pure.group(2)))
            continue

        if "：「" in s:
            pref, q = s.split("：", 1)
            sp = next(lbl for k, lbl in mixed_prefixes if pref.startswith(k))
            buckets[cur_bucket].append(("旁白", f"{pref}："))
            buckets[cur_bucket].append((sp, q))
            continue

        buckets[cur_bucket].append(("旁白", s))

    return buckets, choice_labels


def main() -> int:
    require(MANUSCRIPT.is_file(), "V2.1 manuscript exists")
    require(sha256_of(MANUSCRIPT) == EXPECTED_MANUSCRIPT_SHA256, "V2.1 manuscript SHA-256 matches verbatim upload")
    require(EN_JSON.is_file(), "English translation JSON exists")
    require(MANIFEST_JSON.is_file(), "Import manifest exists")

    events = json.loads(EVENTS_JSON.read_text(encoding="utf-8"))
    by_id = {e["id"]: e for e in events}
    require(
        set(by_id.keys()) == {"emiko_office_denied", "emiko_intro_rumored_hands", "emiko_lv1_first_operation", "emiko_lv2_follow_my_lead"},
        "All 4 doc_emiko events preserved in events.json",
    )

    event = by_id[EVENT_ID]
    rel = json.loads(RELATIONSHIP_JSON.read_text(encoding="utf-8"))

    # Schema validation across all doc_emiko events
    schema = json.loads(SCHEMA_JSON.read_text(encoding="utf-8"))
    validator = Draft202012Validator({"$ref": "#/$defs/character_event", "$defs": schema["$defs"]})
    for eid, ev_obj in by_id.items():
        errs = list(validator.iter_errors(ev_obj))
        require(len(errs) == 0, f"Schema valid for {eid}: {[e.message for e in errs[:3]]}")

    # Gate & settlement checks (Section 一.1-3 & Section 三)
    require(event["actor_id"] == "doc_emiko", "actor_id == doc_emiko")
    require(event["title"] == "这一次听你的", "Chinese title == 这一次听你的")
    require(event["chapter"] == 2 and event["target_level"] == 2, "chapter == 2 and target_level == 2")
    require(event["category"] == "rank_up", "category == rank_up")
    require(event["location_id"] == "or" and event["trigger_mode"] == "location", "Workday OR location trigger")
    require(event["time_start"] == 540 and event["time_end"] == 1019, "09:00-16:59 OR window")
    require(event["minutes"] == 100, "minutes == 100")
    require(event["locks_saving"] is True, "locks_saving == True")
    cond = event["conditions"]
    require(cond["required_events"] == ["emiko_lv1_first_operation"], "Requires ONLY emiko_lv1_first_operation")
    require(cond["days_after_required_events"] == 3, "3-day post-Lv1 cooldown")
    require(cond["min_familiarity"] == 0 and cond["min_affection"] == 0, "Zero Familiarity/Affection gate")
    require(
        cond["special_requirements"] == [{"type": "player_attribute", "attribute": "skill", "minimum": 80}],
        "Surgery >= 80 gate (no ordinary co-surgery requirement)",
    )
    require(event["completion_familiarity_bonus"] == 10, "Fixed Familiarity +10 milestone bonus")
    require(event["benefit_id"] == "unlock_emiko_surgical_team", "Lv2 unlocks surgical team at completion")
    require(
        event["completion_story_flags"] == ["emiko_lv2_complete", "emiko_reliable_surgical_partner"],
        "completion_story_flags sets emiko_lv2_complete & emiko_reliable_surgical_partner (no excitement hint)",
    )
    lv2_slot = next(s for s in rel["rank_slots"] if s["target_level"] == 2)
    require(
        lv2_slot["event_id"] == EVENT_ID
        and lv2_slot["min_familiarity"] == 0
        and lv2_slot["benefit_id"] == "unlock_emiko_surgical_team",
        "relationship.json rank_slot Lv2 aligned",
    )

    # Reconstruct manuscript and verify all 27 choice paths verbatim
    buckets, exp_choices = reconstruct_manuscript(MANUSCRIPT.read_text(encoding="utf-8"))
    nodes = event["nodes"]
    require(len(nodes) == 257, f"257 total nodes (got {len(nodes)})")
    node_map = {n["id"]: n for n in nodes}

    for ch_nid, prefix in [("em2_choice_b1", "b1"), ("em2_choice_d2", "d2"), ("em2_choice_f3", "f3")]:
        ch_node = node_map[ch_nid]
        require(ch_node["presentation"] == "choice" and ch_node["text"] == "", f"{ch_nid} choice presentation")
        require(len(ch_node["choices"]) == 3, f"{ch_nid} has 3 options")
        for idx, letter in enumerate(("a", "b", "c")):
            cid = f"choice_em2_{prefix}_{letter}"
            opt = ch_node["choices"][idx]
            require(opt["id"] == cid, f"{ch_nid} option {idx} id == {cid}")
            require(opt["label"] == exp_choices[cid], f"Verbatim label for {cid}")
            require(opt["effects"] == {"affection": 0, "familiarity": 0}, f"Zero stat delta on {cid}")
            require(opt["flags"] == [], f"Zero flag delta on {cid}")

    visited_all: set[str] = set()
    for b_pick, d_pick, f_pick in itertools.product(("a", "b", "c"), repeat=3):
        expected_seq = (
            buckets["pre_b1"]
            + buckets[f"b1_{b_pick}"]
            + buckets["b1_to_d2"]
            + buckets[f"d2_{d_pick}"]
            + buckets["d2_to_f3"]
            + buckets[f"f3_{f_pick}"]
            + buckets["post_f3"]
        )
        picks = {
            "em2_choice_b1": f"choice_em2_b1_{b_pick}",
            "em2_choice_d2": f"choice_em2_d2_{d_pick}",
            "em2_choice_f3": f"choice_em2_f3_{f_pick}",
        }
        cur = event["start"]
        actual_seq: list[tuple[str, str]] = []
        steps = 0
        while cur != "@end" and steps < 350:
            require(cur in node_map, f"Valid target {cur} on {b_pick}/{d_pick}/{f_pick}")
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
                if cur == "em2_254":
                    require(
                        chosen["flags"] == ["emiko_lv2_complete", "emiko_reliable_surgical_partner"],
                        "em2_254 @end sets completion flags",
                    )
                else:
                    require(chosen["flags"] == [], f"{cur} zero intermediate flags")
            cur = chosen["next"]
            steps += 1
        require(cur == "@end", f"Path {b_pick}/{d_pick}/{f_pick} reaches @end")
        require(
            actual_seq == expected_seq,
            f"Path {b_pick}/{d_pick}/{f_pick} 100% verbatim match ({len(actual_seq)} vs {len(expected_seq)} beats)",
        )

    require(visited_all == set(node_map.keys()), "Zero unreachable orphan nodes across 27 paths")

    # Verify V2.1 key revisions & Scene F/G visual/prohibition boundaries
    require("无菌温生理盐水湿润的小纱布球" in node_map["em2_085"]["text"], "V2.1 P1-3a: sterile warm saline spongelet wipe in Scene C")
    require(
        "两人都清楚吻合前必须完成血供、方向与张力复核" in node_map["em2_101"]["text"],
        "V2.1 P0: Scene D mutual commitment to safety verification",
    )
    require(
        "把较细这一端的对系膜缘往斜向适当修整敞开一点" in node_map["em2_136"]["text"],
        "V2.1 P1-2: natural bevel-trim suggestion without awkward fractions/millimeters",
    )
    require(
        "你没有提前跟第一助手交底你习惯的探查和复核顺序" in node_map["em2_208"]["text"],
        "V2.1 P1-4: Choice 3A pre-incision briefing reason for -12 margin",
    )
    require("八十八分。" in node_map["em2_198"]["text"], "88-point score preserved")
    require("下一台什么时候？" in node_map["em2_240"]["text"], "Scene G signature line preserved")

    # Scene G must switch to corridor + everyday white_coat (neutral/serious only; zero scrubs/blush/warm excitement)
    for num in range(234, 255):
        nd = node_map[f"em2_{num:03d}"]
        require(nd["background_id"] == "or_entrance", f"em2_{num:03d} Scene G uses corridor background")
        require(nd["outfit"] == "white_coat", f"em2_{num:03d} Scene G uses white_coat")
        require(nd["expression"] in ("neutral", "serious"), f"em2_{num:03d} Scene G composed expression ({nd['expression']})")
        for p in nd.get("event_portraits", []):
            require("white_coat/" in p["path"], f"em2_{num:03d} portrait uses white_coat")

    # Zero unmasked doc_emiko scrubs portraits anywhere in Lv2
    for nd in nodes:
        require("anonymous_unmet" not in nd, f"{nd['id']} does not mask supporting cast names")
        for p in nd.get("event_portraits", []):
            require("doc_emiko/scrubs/" not in p["path"], f"{nd['id']} avoids unmasked doc_emiko scrubs in OR")
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
    require(
        en_strings[f"{prefix}title"] == "This Time, I'll Follow Your Lead",
        "English title preserved as \"This Time, I'll Follow Your Lead\"",
    )

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
