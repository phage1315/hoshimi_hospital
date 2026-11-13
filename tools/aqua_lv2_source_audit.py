#!/usr/bin/env python3
"""Verbatim source, Concept Lock, V2.3 revision log, localization, and asset audit
for Aqua Mizuki Relationship Lv2 event: 《你要不要学？》 (aqua_lv2_want_to_learn).
"""
from __future__ import annotations

import json
import re
import struct
from pathlib import Path

from import_aqua_lv2 import EVENT_ID, parse_beats

ROOT = Path(__file__).resolve().parents[1]
EVENT_FILE = ROOT / "data/staff/doc_aqua/lv2_events.json"
BUNDLE_FILE = ROOT / "data/staff/doc_aqua/bundle.json"
REL_FILE = ROOT / "data/staff/doc_aqua/relationship.json"
LOC_ZH_FILE = ROOT / "data/localization/zh_CN.json"
LOC_EN_FILE = ROOT / "data/localization/en.json"

CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")


def read_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def png_is_rgba(path: Path) -> bool:
    if not path.is_file():
        return False
    data = path.read_bytes()
    return len(data) > 26 and data[:8] == b"\x89PNG\r\n\x1a\n" and data[25] == 6


def png_dimensions(path: Path) -> tuple[int, int]:
    data = path.read_bytes()
    w, h = struct.unpack(">II", data[16:24])
    return int(w), int(h)


def main() -> None:
    expected_nodes = parse_beats()
    events = read_json(EVENT_FILE)
    assert isinstance(events, list) and len(events) == 1, "Expected 1 event in lv2_events.json"
    event = events[0]
    assert event["id"] == EVENT_ID
    assert event["actor_id"] == "doc_aqua"
    assert event["title"] == "你要不要学？"
    assert event["category"] == "rank_up"
    assert event["target_level"] == 2
    assert event["benefit_id"] == "unlock_hysterectomy_and_manipulator"
    assert set(event["completion_story_flags"]) == {
        "aqua_hysterectomy_teaching_complete",
        "aqua_manipulator_teaching_complete",
    }

    # Verify bundle registration
    bundle = read_json(BUNDLE_FILE)
    assert isinstance(bundle, dict)
    assert "lv2_events.json" in bundle.get("additional_character_event_files", [])

    # Verify relationship.json Lv2 slot
    rel = read_json(REL_FILE)
    assert isinstance(rel, dict)
    lv2_slots = [s for s in rel.get("rank_slots", []) if int(s.get("target_level", 0)) == 2]
    assert len(lv2_slots) == 1
    lv2_slot = lv2_slots[0]
    assert lv2_slot["event_id"] == EVENT_ID
    assert lv2_slot["content_status"] == "authored"
    assert lv2_slot["benefit_id"] == "unlock_hysterectomy_and_manipulator"
    assert lv2_slot["min_familiarity"] == 25
    assert lv2_slot["cooldown_days"] == 3
    # Ensure self-blocking aqua_hysterectomy_teaching_complete is NOT a prerequisite on Lv2 slot
    for req in lv2_slot.get("special_requirements", []):
        assert req.get("flag") != "aqua_hysterectomy_teaching_complete"

    actual_nodes = event["nodes"]
    assert len(actual_nodes) == 314, f"Expected 314 beats, got {len(actual_nodes)}"

    # 1. Beat-by-beat verbatim comparison against manuscript parser
    for idx, (exp, act) in enumerate(zip(expected_nodes, actual_nodes), 1):
        assert exp["id"] == act["id"], f"Node ID mismatch at {idx}: {exp['id']} != {act['id']}"
        assert exp["speaker_label"] == act["speaker_label"], (
            f"Speaker mismatch at {act['id']}: {exp['speaker_label']} != {act['speaker_label']}"
        )
        assert exp["text"] == act["text"], (
            f"Verbatim text mismatch at {act['id']}:\nEXP: {exp['text']}\nACT: {act['text']}"
        )
        assert len(exp["choices"]) == len(act["choices"]), f"Choice count mismatch at {act['id']}"
        for c_exp, c_act in zip(exp["choices"], act["choices"]):
            assert c_exp["id"] == c_act["id"]
            assert c_exp["label"] == c_act["label"]
            assert c_exp["next"] == c_act["next"]

    # 2. Verify the 3 two-option choices and their branch merges
    by_id = {n["id"]: n for n in actual_nodes}
    assert [c["id"] for c in by_id["aqlv2_009"]["choices"]] == [
        "choice_aqlv2_009_a",
        "choice_aqlv2_009_b",
    ]
    assert by_id["aqlv2_009"]["choices"][0]["next"] == "aqlv2_010"
    assert by_id["aqlv2_009"]["choices"][1]["next"] == "aqlv2_014"
    assert by_id["aqlv2_013"]["choices"][0]["next"] == "aqlv2_019"
    assert by_id["aqlv2_018"]["choices"][0]["next"] == "aqlv2_019"

    assert [c["id"] for c in by_id["aqlv2_190"]["choices"]] == [
        "choice_aqlv2_190_a",
        "choice_aqlv2_190_b",
    ]
    assert by_id["aqlv2_190"]["choices"][0]["next"] == "aqlv2_191"
    assert by_id["aqlv2_190"]["choices"][1]["next"] == "aqlv2_197"
    assert by_id["aqlv2_196"]["choices"][0]["next"] == "aqlv2_201"
    assert by_id["aqlv2_200"]["choices"][0]["next"] == "aqlv2_201"

    assert [c["id"] for c in by_id["aqlv2_245"]["choices"]] == [
        "choice_aqlv2_245_a",
        "choice_aqlv2_245_b",
    ]
    assert by_id["aqlv2_245"]["choices"][0]["next"] == "aqlv2_246"
    assert by_id["aqlv2_245"]["choices"][1]["next"] == "aqlv2_250"
    assert by_id["aqlv2_249"]["choices"][0]["next"] == "aqlv2_254"
    assert by_id["aqlv2_253"]["choices"][0]["next"] == "aqlv2_254"

    # 3. Verify Concept Lock & V2.3 Revision Log items across combined corpus
    corpus = "\n".join(n["text"] for n in actual_nodes)
    required_phrases = [
        "开腹子宫全切除术",
        "举宫器",
        "给坂口演示一下怎么用齿钳夹宫颈、怎么把举宫器插到底往上顶高测试盆底张力",
        "赛蕾娜",
        "二十七岁",
        "弥漫性子宫腺肌症合并四颗平滑肌瘤",
        "保留双侧健康卵巢",
        "外面做腹腔镜的时候才常常用到举宫器，在我们普通的开腹子宫全切除术里，其实并不是每台都非放它不可",
        "本庄萌恵",
        "先拿带钩的齿钳咬住那里，再把那么长的铁杆插到底往上顶着摇晃……这、这也太吓人了，光看着都觉得好疼啊",
        "硬膜外麻醉",
        "两毫米",
        "这还只是妇科进阶的第一步哦",
    ]
    for phrase in required_phrases:
        assert phrase in corpus, f"Missing required Concept Lock / V2.3 phrase: {phrase}"

    # 4. Verify Serena portrait assets & all staged portraits/CGs
    serena_ward_neutral = ROOT / "assets/characters/story_guest_serena_v1/ward/neutral.png"
    serena_ward_flustered = ROOT / "assets/characters/story_guest_serena_v1/ward/flustered.png"
    serena_or_tense = ROOT / "assets/characters/story_guest_serena_v1/operating_table/tense.png"
    serena_or_pain = ROOT / "assets/characters/story_guest_serena_v1/operating_table/pain.png"
    for p, expected_size in [
        (serena_ward_neutral, (1024, 1536)),
        (serena_ward_flustered, (1024, 1536)),
        (serena_or_tense, (1024, 1536)),
        (serena_or_pain, (1024, 1536)),
    ]:
        assert png_is_rgba(p), f"Serena portrait missing or not RGBA: {p}"
        assert png_dimensions(p) == expected_size, (
            f"Serena portrait size mismatch for {p}: {png_dimensions(p)} != {expected_size}"
        )

    for node in actual_nodes:
        if node.get("cg_path"):
            cg_file = ROOT / node["cg_path"]
            assert cg_file.is_file(), f"Missing CG file at {node['id']}: {cg_file}"
        for item in node.get("event_portraits", []):
            p_file = ROOT / item["path"]
            assert png_is_rgba(p_file), f"Missing or non-RGBA staged portrait at {node['id']}: {p_file}"

    # 5. Verify bilingual localization completeness and zero CJK in English
    zh_strings = read_json(LOC_ZH_FILE)["strings"]
    en_strings = read_json(LOC_EN_FILE)["strings"]
    prefix = f"collections.character_events.{EVENT_ID}"
    for key_suffix in ("title", "teaser", "gallery.caption"):
        full_key = f"{prefix}.{key_suffix}"
        assert full_key in zh_strings and full_key in en_strings, f"Missing key {full_key}"
        assert not CJK_RE.search(en_strings[full_key]), f"CJK found in EN key {full_key}"

    for node in actual_nodes:
        nid = node["id"]
        t_key = f"{prefix}.nodes.{nid}.text"
        s_key = f"{prefix}.nodes.{nid}.speaker_label"
        assert zh_strings.get(t_key) == node["text"], f"ZH text mismatch at {nid}"
        assert zh_strings.get(s_key) == node["speaker_label"], f"ZH speaker mismatch at {nid}"
        assert t_key in en_strings and en_strings[t_key].strip(), f"Missing EN text at {nid}"
        assert s_key in en_strings and en_strings[s_key].strip(), f"Missing EN speaker at {nid}"
        assert not CJK_RE.search(en_strings[t_key]), f"CJK residue in EN text at {nid}: {en_strings[t_key]}"
        assert not CJK_RE.search(en_strings[s_key]), f"CJK residue in EN speaker at {nid}: {en_strings[s_key]}"
        for choice in node["choices"]:
            cid = choice["id"]
            c_key = f"{prefix}.nodes.{nid}.choices.{cid}.label"
            assert zh_strings.get(c_key) == choice["label"], f"ZH choice mismatch at {cid}"
            assert c_key in en_strings and en_strings[c_key].strip(), f"Missing EN choice at {cid}"
            assert not CJK_RE.search(en_strings[c_key]), f"CJK residue in EN choice at {cid}"

    print(
        "AQUA LV2 SOURCE AUDIT PASSED: 314/314 verbatim beats, 3/3 choices, "
        "13/13 Concept Lock & V2.3 markers, 4/4 Serena RGBA portraits, 100% EN coverage."
    )


if __name__ == "__main__":
    main()
