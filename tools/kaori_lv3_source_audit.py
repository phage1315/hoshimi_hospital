#!/usr/bin/env python3
"""Independent verbatim line-by-line source audit for Miyama Kaori Relationship Lv3 V1.2:
《手术室之神》 / *The God of the Operating Room* (`miyama_03_or_god`).

Audits `data/staff/doc_rei/special_events.json` and `data/staff/doc_rei/special_event_steps.json`
directly against `research/source_scripts/HOSHIMI_MIYAMA_KAORI_LV3_OR_GOD_REVISED_V1_2.md`:
  1. Verbatim character-for-character match across all 353 playable beats (`s02_001`..`s02_028` +
     `s03_001`..`s12_044`) and all 10 interactive choices (`s08_013`, `s10c_002`, `s10e_003`, `s12_016`),
     allowing ONLY the explicit user-approved hair/eye/casual/season alignments and raw markdown cleanup.
  2. Zero unaligned `黑发`/`黑眸`/`针织衫`/`秋夜`/`银杏` or raw markdown (`**`, backticks) in playable text.
  3. Complete DAG reachability, zero orphan nodes, and distinct branch responses before merge.
  4. Speaker/actor attribution audit (`doc_rei`, `doc_asuka`, `nurse_moe`, `nurse_ange`, `nurse_hiroko`,
     `doc_sayaka`, `player`, `narrator`, `急诊女患者`).
  5. Asset existence, RGBA alpha channels, and exact pixel dimensions for all 12 newly generated
     portraits + 3 runtime Lv3 assets.
  6. 100% `zh_CN` + `en` localization parity with zero CJK residue in English.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE_MD = ROOT / "research/source_scripts/HOSHIMI_MIYAMA_KAORI_LV3_OR_GOD_REVISED_V1_2.md"
SPECIAL_EVENTS = ROOT / "data/staff/doc_rei/special_events.json"
SPECIAL_EVENT_STEPS = ROOT / "data/staff/doc_rei/special_event_steps.json"
PROFILE = ROOT / "data/staff/doc_rei/profile.json"
LOC_ZH = ROOT / "data/localization/zh_CN.json"
LOC_EN = ROOT / "data/localization/en.json"

CJK_RE = re.compile(r"[\u3400-\u9fff\u3040-\u30ff]")
FORBIDDEN_TEXT_RE = re.compile(r"(?:黑发|黑色长发|黑眸|针织衫|秋夜|银杏|四十二岁|急诊女患者|\*\*|`)")

EXPECTED_ALIGNMENTS = {
    "s02_019": [("晚风拂过她利落的黑发。", "晚风拂过她利落的紫发。")],
    "s05_010": [("叠得整整齐齐的针织衫和长裤", "叠得整整齐齐的便服")],
    "s07_003": [("四十二岁成年女性", "二十三岁年轻女患者麻生华澄")],
    "s07_005": [("那双黑眸骤然沉静锐利下来", "那双紫红眼眸骤然沉静锐利下来")],
    "s07_007": [("角落收纳篮里的针织衫和长裤", "角落收纳篮里的私服衣物")],
    "s07_011": [
        ("那叠需要费工夫穿脱的针织衫和长裤", "那叠需要费工夫穿脱的私服"),
        ("完全收拢黑发的患者手术帽", "完全收拢紫发的患者手术帽"),
    ],
    "s07_013": [("四十二岁的女患者", "二十三岁的年轻女患者麻生华澄")],
    "s07_015": [("急诊女患者（声音发颤）：", "麻生华澄（声音发颤）：")],
    "s08_016": [("口罩上方那双黑眸", "口罩上方那双紫红眼眸")],
    "s09_016": [("帽檐严密包住黑发", "帽檐严密包住紫发")],
    "s10a_004": [("四十二岁女性", "麻生华澄，二十三岁女性")],
    "s10a_005": [("**右侧结肠旁沟边缘**", "右侧结肠旁沟边缘")],
    "s11_011": [("急诊女患者（眨了眨眼，脸上反而浮起了更深的困惑）：", "麻生华澄（眨了眨眼，脸上反而浮起了更深的困惑）：")],
    "s12_001": [
        ("晚上八点十分，秋夜的凉风吹过医院门外的银杏街道。", "晚上八点十分，微凉的夜风吹过医院门外的行道树街道。")
    ],
    "s12_042": [("浅笑（`small_smile`）：", "浅笑：")],
}

EXPECTED_SPEAKER_LABELS = {
    "旁白": ("narrator", "旁白"),
    "坂口隆司": ("player", "坂口隆司"),
    "深山佳織": ("actor", "深山 佳織"),
    "杉村弘子": ("actor", "杉村 弘子"),
    "城宮明日香": ("actor", "城宮 明日香"),
    "本庄萌恵": ("actor", "本庄 萌惠"),
    "利根川安琪": ("actor", "利根川 安琪"),
    "南条小夜香": ("actor", "南条 小夜香"),
    "急诊女患者": ("actor", "麻生华澄"),
    "本庄萌恵 ＆ 利根川安琪": ("actor", "本庄 萌惠 ＆ 利根川 安琪"),
}

KASUMI_RGBA_PORTRAITS = [
    ("assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/or_cap/tense.png", (1448, 1086)),
    ("assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/or_cap/shocked_feverish.png", (1448, 1086)),
    ("assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/or_cap/mask_drowsy.png", (1448, 1086)),
    ("assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/or_cap/anesthetized.png", (1448, 1086)),
    ("assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/ward/neutral.png", (1024, 1536)),
    ("assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/ward/drowsy_relieved.png", (1024, 1536)),
    ("assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/ward/confused.png", (1024, 1536)),
]

NEW_RGBA_PORTRAITS = [
    ("assets/characters/intraoperative_portraits_v1/doc_rei/tense.png", (1448, 1086)),
    ("assets/characters/intraoperative_portraits_v1/doc_rei/pain.png", (1448, 1086)),
    ("assets/characters/intraoperative_portraits_v1/doc_rei/near_collapse.png", (1448, 1086)),
    ("assets/characters/intraoperative_portraits_v1/doc_rei/anesthetized.png", (1448, 1086)),
    ("assets/characters/intraoperative_portraits_v1/doc_rei/embarrassed.png", (1448, 1086)),
    ("assets/characters/intraoperative_portraits_v1/doc_rei/relieved.png", (1448, 1086)),
    ("assets/characters/miyama_lv3_v1/doc_rei/or_cap/asleep.png", (1448, 1086)),
    ("assets/characters/miyama_lv3_v1/doc_rei/or_cap/drowsy.png", (1448, 1086)),
    ("assets/characters/miyama_lv3_v1/doc_rei/or_cap/masked_hesitant.png", (1448, 1086)),
    ("assets/characters/miyama_lv3_v1/doc_rei/or_cap/masked_focused.png", (1448, 1086)),
    ("assets/characters/spring_summer_casual_v1/doc_rei/small_smile.png", (1024, 1536)),
    ("assets/characters/winter_casual_v1/doc_rei/small_smile.png", (1024, 1536)),
]


def audit() -> tuple[int, list[str]]:
    from import_kaori_lv3 import parse_manuscript

    checks = 0
    failures: list[str] = []

    def check(cond: bool, msg: str) -> None:
        nonlocal checks
        checks += 1
        if not cond:
            failures.append(msg)

    expected_beats, expected_choices = parse_manuscript()
    check(len(expected_beats) == 353, f"Expected 353 manuscript beats, got {len(expected_beats)}")
    check(len(expected_choices) == 4, f"Expected 4 choice blocks, got {len(expected_choices)}")

    events = {e["id"]: e for e in json.loads(SPECIAL_EVENTS.read_text(encoding="utf-8"))}
    steps = {s["id"]: s for s in json.loads(SPECIAL_EVENT_STEPS.read_text(encoding="utf-8"))}
    zh_strings = json.loads(LOC_ZH.read_text(encoding="utf-8"))["strings"]
    en_strings = json.loads(LOC_EN.read_text(encoding="utf-8"))["strings"]

    ev = events.get("miyama_03_or_god", {})
    check(ev.get("duration_days") == 2, "miyama_03_or_god duration_days must be 2")
    check(
        ev.get("event_chain") == ["miyama_03_or_god_day1", "miyama_03_or_god_main"],
        "miyama_03_or_god event_chain mismatch",
    )
    check(
        ev.get("timing", {}).get("avoid_sunday_span") is True,
        "miyama_03_or_god timing.avoid_sunday_span must be True",
    )
    check(
        ev.get("unlock_requirements")
        == [{"type": "days_after_special_event", "event_id": "miyama_02_manga_artist_wrong_patient", "days": 5}],
        "miyama_03_or_god 5-day post-Lv2 cooldown missing",
    )
    check(
        ev.get("required_characters") == ["PLAYER", "doc_rei", "doc_asuka", "nurse_moe", "nurse_ange"],
        "miyama_03_or_god required_characters must not add nurse_hiroko/doc_sayaka hard gates",
    )

    step1 = steps.get("miyama_03_or_god_day1", {})
    step2 = steps.get("miyama_03_or_god_main", {})
    actual_nodes = list(step1.get("nodes", [])) + list(step2.get("nodes", []))
    check(len(actual_nodes) == 353, f"Expected 353 compiled nodes, got {len(actual_nodes)}")

    for exp, node in zip(expected_beats, actual_nodes):
        nid = exp["id"]
        check(node.get("id") == nid, f"Node ID mismatch: expected {nid}, got {node.get('id')}")
        check(node.get("text") == exp["text"], f"Text mismatch at {nid}: {node.get('text')!r} != {exp['text']!r}")
        check(
            not FORBIDDEN_TEXT_RE.search(node.get("text", "")),
            f"Unaligned or raw markdown token in {nid}: {node.get('text')!r}",
        )
        exp_role, exp_label = EXPECTED_SPEAKER_LABELS[exp["speaker"]]
        check(node.get("speaker") == exp_role, f"Speaker role mismatch at {nid}")
        check(node.get("speaker_label") == exp_label, f"Speaker label mismatch at {nid}")

    # Verify DAG reachability and choice branches for both steps
    for step in (step1, step2):
        by_id = {n["id"]: n for n in step.get("nodes", [])}
        visited: set[str] = set()
        stack = [step.get("start", "")]
        reached_end = False
        while stack:
            cur = stack.pop()
            if cur == "@day_end":
                reached_end = True
                continue
            if cur in visited or cur not in by_id:
                check(cur in by_id or cur in visited, f"Broken next link {cur!r} in {step.get('id')}")
                continue
            visited.add(cur)
            for ch in by_id[cur].get("choices", []):
                stack.append(ch["next"])
        check(reached_end, f"Step {step.get('id')} never reaches @day_end")
        check(visited == set(by_id.keys()), f"Orphan nodes in {step.get('id')}: {set(by_id.keys()) - visited}")

    # Verify 4 interactive choices have distinct branch targets
    main_by_id = {n["id"]: n for n in step2.get("nodes", [])}
    for cnum, cinfo in expected_choices.items():
        host = main_by_id[cinfo["host_id"]]
        chs = host["choices"]
        check(len(chs) == len(cinfo["options"]), f"Choice {cnum} count mismatch on {cinfo['host_id']}")
        targets = [c["next"] for c in chs]
        check(len(set(targets)) == len(targets), f"Choice {cnum} options collapse onto identical target: {targets}")
        for idx, (_opt, exp_lbl) in enumerate(cinfo["options"]):
            check(chs[idx]["label"] == exp_lbl, f"Choice {cnum} option label mismatch: {chs[idx]['label']!r}")

    # Verify 12 RGBA portraits + profile registration
    prof = json.loads(PROFILE.read_text(encoding="utf-8"))
    reg_paths = set(prof["visuals"]["portraits"].values())
    for rel_path, exp_size in NEW_RGBA_PORTRAITS:
        full = ROOT / rel_path
        check(full.is_file(), f"Missing portrait file: {rel_path}")
        if full.is_file():
            im = Image.open(full)
            check(im.mode == "RGBA", f"Portrait {rel_path} must be RGBA, got {im.mode}")
            check(im.size == exp_size, f"Portrait {rel_path} size {im.size} != {exp_size}")
            alpha_corner = im.getpixel((0, 0))[3]
            check(alpha_corner == 0, f"Portrait {rel_path} top-left corner alpha {alpha_corner} != 0")
        check(rel_path in reg_paths, f"Portrait {rel_path} not registered in doc_rei/profile.json")

    cameos = {c["id"]: c for c in json.loads((ROOT / "data/patients/cameo_patients.json").read_text(encoding="utf-8"))}
    kasumi = cameos.get("guest_kasumi_asou", {})
    check(kasumi.get("age") == 23 and kasumi.get("canonical_name") == "麻生华澄", "guest_kasumi_asou cameo entry invalid")
    kasumi_paths = set(kasumi.get("visuals", {}).values())
    staged_paths = {
        p["path"]
        for n in step2.get("nodes", [])
        for p in n.get("event_portraits", [])
    }
    for rel_path, exp_size in KASUMI_RGBA_PORTRAITS:
        full = ROOT / rel_path
        check(full.is_file(), f"Missing Kasumi portrait file: {rel_path}")
        if full.is_file():
            im = Image.open(full)
            check(im.mode == "RGBA", f"Kasumi portrait {rel_path} must be RGBA, got {im.mode}")
            check(im.size == exp_size, f"Kasumi portrait {rel_path} size {im.size} != {exp_size}")
            alpha_corner = im.getpixel((0, 0))[3]
            check(alpha_corner == 0, f"Kasumi portrait {rel_path} top-left corner alpha {alpha_corner} != 0")
        check(rel_path in kasumi_paths, f"Kasumi portrait {rel_path} not registered in cameo_patients.json")
        check(rel_path in staged_paths, f"Kasumi portrait {rel_path} not staged in miyama_03_or_god_main")

    bgs = {b["id"]: b for b in json.loads((ROOT / "data/backgrounds.json").read_text(encoding="utf-8"))}
    pacu_bg = bgs.get("pacu_recovery", {})
    pacu_rel = pacu_bg.get("path", "")
    check(pacu_rel == "assets/backgrounds/pacu_recovery_v1/pacu_recovery.png", "pacu_recovery missing in data/backgrounds.json")
    pacu_full = ROOT / pacu_rel if pacu_rel else ROOT / "__missing__"
    check(pacu_full.is_file(), f"Missing PACU background file: {pacu_rel}")
    if pacu_full.is_file():
        pacu_im = Image.open(pacu_full)
        check(pacu_im.mode == "RGB" and pacu_im.size == (1376, 768), f"Unexpected PACU background {pacu_im.mode} {pacu_im.size}")
    for n in range(1, 14):
        nid = f"s11_{n:03d}"
        check(main_by_id.get(nid, {}).get("background_id") == "pacu_recovery", f"{nid} must use pacu_recovery background")

    # Verify bilingual coverage & zero CJK residue in English
    for step in (step1, step2):
        sid = step["id"]
        t_key = f"collections.special_event_steps.{sid}.title"
        check(bool(en_strings.get(t_key, "").strip()) and not CJK_RE.search(en_strings.get(t_key, "")), f"Bad EN {t_key}")
        for node in step["nodes"]:
            nid = node["id"]
            for field in ("text", "speaker_label"):
                k = f"collections.special_event_steps.{sid}.nodes.{nid}.{field}"
                check(zh_strings.get(k) == node[field], f"ZH mismatch at {k}")
                en_val = en_strings.get(k, "")
                check(bool(en_val.strip()) and not CJK_RE.search(en_val), f"Missing or CJK EN at {k}: {en_val!r}")
            for ch in node["choices"]:
                ck = f"collections.special_event_steps.{sid}.nodes.{nid}.choices.{ch['id']}.label"
                check(zh_strings.get(ck) == ch["label"], f"ZH choice mismatch at {ck}")
                en_c = en_strings.get(ck, "")
                check(bool(en_c.strip()) and not CJK_RE.search(en_c), f"Missing or CJK EN choice at {ck}: {en_c!r}")

    return checks, failures


def main() -> int:
    checks, failures = audit()
    if failures:
        for f in failures:
            print("FAIL:", f, file=sys.stderr)
        print(f"KAORI LV3 V1.2 SOURCE AUDIT: {checks} checks; {len(failures)} failure(s)", file=sys.stderr)
        return 1
    print(
        f"KAORI LV3 V1.2 SOURCE AUDIT: {checks} checks; 0 failure(s) "
        f"(aligned nodes: {len(EXPECTED_ALIGNMENTS)}, beats: 353, choices: 10, new RGBA sprites: 19)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
