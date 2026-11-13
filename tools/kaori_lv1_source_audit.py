#!/usr/bin/env python3
"""Line-by-line verbatim audit for Miyama Kaori Lv1 V2.3 (`miyama_01_safety_pin`)."""

from __future__ import annotations

import json
import re
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import import_kaori_lv1 as importer  # noqa: E402

CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")


def check_png_rgba(path: Path, expect_alpha_transparency: bool) -> tuple[int, int, int]:
    data = path.read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", f"Not a valid PNG: {path}"
    w, h, bit_depth, color_type = struct.unpack(">IIBB", data[16:26])
    if expect_alpha_transparency:
        assert color_type == 6, f"Expected RGBA PNG (color_type=6) for {path}, got {color_type}"
    return w, h, color_type


def main() -> None:
    checks = 0

    def expect(cond: bool, msg: str) -> None:
        nonlocal checks
        checks += 1
        if not cond:
            raise AssertionError(msg)

    expected_beats = importer.parse_beats()
    expect(len(expected_beats) == 308, f"Expected 308 beats, got {len(expected_beats)}")

    special_events = json.loads((ROOT / "data/staff/doc_rei/special_events.json").read_text(encoding="utf-8"))
    ev = next((e for e in special_events if e.get("id") == "miyama_01_safety_pin"), None)
    expect(ev is not None, "Missing miyama_01_safety_pin in special_events.json")
    expect("or_table_palpation_unlocked" not in ev.get("completion_flags", []), "Legacy or_table_palpation_unlocked must be removed")
    for flag in (
        "miyama_01_safety_pin_completed",
        "relationship_doc_rei_lv1",
        "safety_pin_patient_safe",
        "miyama_negative_exploration_memory",
    ):
        expect(flag in ev.get("completion_flags", []), f"Missing completion flag {flag}")
    expect(
        ev.get("completion_effects", {}).get("unlock_procedures") == ["surgery_exploratory_laparotomy"],
        "Completion must unlock surgery_exploratory_laparotomy",
    )
    expect(
        "nurse_iwasaki_rumi" not in ev.get("required_characters", []),
        "nurse_iwasaki_rumi must not be added as an extra prerequisite gate",
    )

    steps = json.loads((ROOT / "data/staff/doc_rei/special_event_steps.json").read_text(encoding="utf-8"))
    step = next((s for s in steps if s.get("id") == "miyama_01_safety_pin_main"), None)
    expect(step is not None, "Missing miyama_01_safety_pin_main in special_event_steps.json")

    nodes = step["nodes"]
    expect(len(nodes) == 308, f"Expected 308 runtime nodes, got {len(nodes)}")

    zh = json.loads((ROOT / "data/localization/zh_CN.json").read_text(encoding="utf-8"))["strings"]
    en = json.loads((ROOT / "data/localization/en.json").read_text(encoding="utf-8"))["strings"]

    for beat, node in zip(expected_beats, nodes):
        idx = beat["index"]
        nid = f"klv1_{idx:03d}"
        expect(node["id"] == nid, f"Node ID mismatch at {idx}: {node['id']}")
        expect(node["text"] == beat["text"], f"Verbatim text mismatch at {nid}")
        expect(node["speaker_label"] == beat["speaker_label"], f"Speaker mismatch at {nid}")
        expect("unmet_variant" not in node, f"{nid} should display speaker name directly without unmet_variant")

        k_text = f"collections.special_event_steps.miyama_01_safety_pin_main.nodes.{nid}.text"
        k_spk = f"collections.special_event_steps.miyama_01_safety_pin_main.nodes.{nid}.speaker_label"
        expect(zh.get(k_text) == beat["text"], f"ZH localization mismatch at {nid}")
        expect(zh.get(k_spk) == beat["speaker_label"], f"ZH speaker localization mismatch at {nid}")
        en_text = en.get(k_text, "")
        en_spk = en.get(k_spk, "")
        expect(bool(en_text) and not CJK_RE.search(en_text), f"EN localization missing or contains CJK at {nid}")
        expect(bool(en_spk) and not CJK_RE.search(en_spk), f"EN speaker missing or contains CJK at {nid}")

        if 120 <= idx <= 151:
            expect(
                node.get("cg_path") == "assets/events/character_events/rei/lv1/cg_kita_or_palpation.png",
                f"Expected Kita palpation CG on {nid}",
            )
            expect(node.get("hide_portrait") is True, f"Expected hide_portrait on CG beat {nid}")
        elif idx == 188:
            expect(
                node.get("cg_path") == "assets/events/character_events/rei/lv1/cg_kita_shaving_prep.png",
                f"Expected Kita shaving CG on {nid}",
            )
            expect(node.get("hide_portrait") is True, f"Expected hide_portrait on CG beat {nid}")
        elif 196 <= idx <= 201:
            expect(
                node.get("cg_path") == "assets/events/character_events/rei/lv1/cg_kita_skin_disinfection.png",
                f"Expected Kita disinfection CG on {nid}",
            )
            expect(node.get("hide_portrait") is True, f"Expected hide_portrait on CG beat {nid}")
        else:
            expect("cg_path" not in node, f"Unexpected CG on {nid}")

    by_id = {n["id"]: n for n in nodes}
    c1 = by_id["klv1_157"]["choices"]
    expect(
        [(c["id"], c["label"], c["next"]) for c in c1]
        == [
            ("choice_1_a", "「别针既然找到了，手术先取消，大家收拾吧。」", "klv1_158"),
            ("choice_1_b", "「别针在体外，反倒没法解释她最初的腹痛了。」", "klv1_168"),
        ],
        "Choice 1 mismatch on klv1_157",
    )
    expect(by_id["klv1_167"]["choices"][0]["next"] == "klv1_172", "Branch 1A merge mismatch")
    expect(by_id["klv1_171"]["choices"][0]["next"] == "klv1_172", "Branch 1B merge mismatch")

    c2 = by_id["klv1_293"]["choices"]
    expect(
        [(c["id"], c["label"], c["next"]) for c in c2]
        == [
            ("choice_2_a", "「你有充分的临床理由，我当然会认真听。」", "klv1_294"),
            ("choice_2_b", "「下次触诊先别按那么重，患者都被你按懵了。」", "klv1_298"),
            ("choice_2_c", "「至少最后确认她健健康康的，不算坏结果。」", "klv1_302"),
        ],
        "Choice 2 mismatch on klv1_293",
    )
    expect(by_id["klv1_297"]["choices"][0]["next"] == "klv1_306", "Branch 2A merge mismatch")
    expect(by_id["klv1_301"]["choices"][0]["next"] == "klv1_306", "Branch 2B merge mismatch")
    expect(by_id["klv1_305"]["choices"][0]["next"] == "klv1_306", "Branch 2C merge mismatch")
    expect(by_id["klv1_308"]["choices"][0]["next"] == "@day_end", "Final beat must end with @day_end")

    for rel_p in (
        "assets/characters/story_guest_kita_v1/casual/smile.png",
        "assets/characters/story_guest_kita_v1/casual/shocked.png",
        "assets/characters/story_guest_kita_v1/ward/pout.png",
        "assets/characters/story_guest_kita_v1/ward/smile.png",
        "assets/characters/story_guest_kita_v1/operating_table/tense.png",
        "assets/characters/story_guest_kita_v1/operating_table/panic.png",
    ):
        w, h, _ = check_png_rgba(ROOT / rel_p, expect_alpha_transparency=True)
        expect((w, h) == (1024, 1536), f"Expected 1024x1536 portrait for {rel_p}, got {w}x{h}")

    for rel_p in (
        "assets/characters/story_guest_kita_v1/intraoperative/tense.png",
        "assets/characters/story_guest_kita_v1/intraoperative/panic.png",
    ):
        iw, ih, _ = check_png_rgba(ROOT / rel_p, expect_alpha_transparency=True)
        expect(iw == 740 and ih == 680, f"Expected 740x680 head-shoulder portrait for {rel_p}, got {iw}x{ih}")

    palp_w, palp_h, _ = check_png_rgba(
        ROOT / "assets/events/character_events/rei/lv1/cg_kita_or_palpation.png",
        expect_alpha_transparency=False,
    )
    expect(palp_w >= 1024 and palp_h >= 680, f"Expected landscape palpation CG, got {palp_w}x{palp_h}")

    shave_w, shave_h, _ = check_png_rgba(
        ROOT / "assets/events/character_events/rei/lv1/cg_kita_shaving_prep.png",
        expect_alpha_transparency=False,
    )
    expect(shave_w >= 1024 and shave_h >= 680, f"Expected landscape shaving CG, got {shave_w}x{shave_h}")
    expect(
        by_id["klv1_188"].get("cg_path") == "assets/events/character_events/rei/lv1/cg_kita_shaving_prep.png",
        "Expected shaving CG bound to klv1_188",
    )

    cg_w, cg_h, _ = check_png_rgba(
        ROOT / "assets/events/character_events/rei/lv1/cg_kita_skin_disinfection.png",
        expect_alpha_transparency=False,
    )
    expect(cg_w >= 1024 and cg_h >= 680, f"Expected landscape disinfection CG, got {cg_w}x{cg_h}")

    print(f"KAORI LV1 V2.3 SOURCE AUDIT: {checks} checks; 0 failure(s)")


if __name__ == "__main__":
    main()
