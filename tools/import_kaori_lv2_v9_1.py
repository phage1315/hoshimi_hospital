#!/usr/bin/env python3
"""Deterministically apply V9.1 revisions to Miyama Kaori Lv2 (`miyama_02_manga_artist_wrong_patient`)."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts/HOSHIMI_KAORI_LV2_OVER_RESEARCHED_V9_1.md"
TRANSLATIONS = ROOT / "research/translations/kaori_lv2_v9_1_en.json"
SPECIAL_EVENTS = ROOT / "data/staff/doc_rei/special_events.json"
SPECIAL_EVENT_STEPS = ROOT / "data/staff/doc_rei/special_event_steps.json"
LOCALIZATION_ZH = ROOT / "data/localization/zh_CN.json"
LOCALIZATION_EN = ROOT / "data/localization/en.json"

EVENT_ID = "miyama_02_manga_artist_wrong_patient"
STEP_ID = "miyama_02_manga_artist_wrong_patient_main"

REI_PORTRAITS = {
    ("white_coat", "neutral"): "assets/characters/portrait_pack_v20/doc_rei/white_coat/neutral.png",
    ("white_coat", "smile"): "assets/characters/portrait_pack_v20/doc_rei/white_coat/smile.png",
    ("white_coat", "serious"): "assets/characters/portrait_pack_v20/doc_rei/white_coat/serious.png",
    ("white_coat", "worried"): "assets/characters/portrait_pack_v20/doc_rei/white_coat/worried.png",
    ("white_coat", "tired"): "assets/characters/portrait_pack_v20/doc_rei/white_coat/tired.png",
}

ASUKA_PORTRAITS = {
    ("director_suit", "neutral"): "assets/characters/portrait_pack_v15/doc_asuka/director_suit/neutral.png",
    ("director_suit", "smile"): "assets/characters/portrait_pack_v15/doc_asuka/director_suit/neutral.png",
}

SPEAKER_EN_MAP = {
    "旁白": "Narrator",
    "坂口隆司": "Ryuji Sakaguchi",
    "坂口": "Sakaguchi",
    "深山佳織": "Kaori Miyama",
    "深山": "Miyama",
    "城宮明日香": "Asuka Shiromiya",
    "明日香": "Asuka",
    "片桐彩子": "Ayako Katagiri",
    "藤崎詩織": "Shiori Fujisaki",
    "藤崎": "Fujisaki",
    "七瀬恋": "Ren Nanase",
    "朝倉美幸": "Miyuki Asakura",
}

SCENE_SCHEDULE = {
    "s01": {"clock": 540},
    "s02": {"clock": 600},
    "s03": {"clock": 620},
    "s04": {"clock": 630},
    "s05": {"clock": 645},
    "s06": {"clock": 650},
    "s07": {"clock": 660},
    "s08": {"clock": 665},
    "s09": {"clock": 675},
    "s10": {"clock": 682},
    "s11": {"clock": 688},
    "s12": {"clock": 690},
    "s13": {"clock": 705},
    "s14": {"clock": 720},
    "s15": {"clock": 735},
    "s16": {"clock": 745},
    "s17": {"clock": 748},
    "s18": {"clock": 750},
    "s19": {"clock": 755},
    "s20": {"clock": 765},
    "s21": {"clock": 780},
    "s22": {"clock": 795},
    "s23": {"clock": 825},
    "s24": {"clock": 960},
    "s25": {"clock": 985},
    "s25b": {"clock": 1005},
    "s26": {"clock": 1050},
    "s27": {"clock": 1065},
    "s28": {"clock": 1080},
    "s29": {"clock": 1090},
    "s30": {"clock": 1110},
    "s31": {"clock": 1140},
    "s32": {"clock": 1150},
    "s33": {"clock": 1155},
    "s34": {"clock": 1155},
}


def read_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, data: object) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def parse_scene_beats_from_source() -> dict[str, dict[int, str]]:
    """Extract clean verbatim beat text blocks for modified/added scenes from V9.1 source."""
    md = SOURCE.read_text(encoding="utf-8")
    sections = re.split(r"(?m)^(# \d+(?:\.\d+)?\.?\s+[^\n]+)\n", md)
    parsed: dict[str, dict[int, str]] = {}
    for idx in range(1, len(sections), 2):
        header = sections[idx].strip()
        body = sections[idx + 1]
        m_sc = re.search(r"Scene (\d+B?)", header)
        if not m_sc:
            continue
        sid = "s" + m_sc.group(1).lower()
        body_main = re.split(r"(?m)^##\s+", body)[0]
        beats = re.split(r"(?m)^###\s+(\d+)\s*\n", body_main)
        beat_dict: dict[int, str] = {}
        for j in range(1, len(beats), 2):
            bnum = int(beats[j])
            raw = re.sub(r"(?m)\n---\s*$", "", beats[j + 1].strip()).strip()
            lines: list[str] = []
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
                        continue
                    if re.match(r"^\*\*[^*]+\*\*(\s*—\s*`[^`]+`)?$", s):
                        continue
                    if re.match(r"^(深山佳織|深山|坂口隆司|坂口|城宮明日香|明日香|片桐彩子|彩子|藤崎詩織|藤崎|系统)[：:]$", s):
                        if s.startswith("系统"):
                            lines.append("系统：")
                        continue
                    if s.startswith("> "):
                        s = s[2:].strip()
                    s = re.sub(r"\*\*([^*]+)\*\*", r"\1", s)
                lines.append(s)
            beat_dict[bnum] = "\n\n".join(lines)
        parsed[sid] = beat_dict
    return parsed


def make_continue_choice(nid: str, next_id: str, label: str = "继续") -> list[dict]:
    return [
        {
            "id": f"continue_{nid}",
            "label": label,
            "next": next_id,
            "requirements": [],
        }
    ]


def rei_solo_portrait(expr: str) -> list[dict]:
    return [
        {
            "id": "doc_rei",
            "path": REI_PORTRAITS[("white_coat", expr)],
            "x": 985,
            "bottom": 695,
            "width": 485,
            "height": 555,
        }
    ]


def asuka_rei_pair_portraits(asuka_expr: str, rei_expr: str) -> list[dict]:
    return [
        {
            "id": "doc_asuka",
            "path": ASUKA_PORTRAITS[("director_suit", asuka_expr)],
            "x": 805,
            "bottom": 610,
            "width": 305,
            "height": 445,
        },
        {
            "id": "doc_rei",
            "path": REI_PORTRAITS[("white_coat", rei_expr)],
            "x": 1065,
            "bottom": 698,
            "width": 490,
            "height": 555,
        },
    ]


def build_scene_01(beats: dict[int, str]) -> list[dict]:
    assert len(beats) == 23, f"Expected 23 beats in Scene 01, got {len(beats)}"
    specs: list[tuple[int, str, str, str | None, str]] = [
        (1, "narrator", "旁白", None, "neutral"),
        (2, "actor", "深山佳織", "doc_rei", "neutral"),
        (3, "player", "坂口隆司", None, "neutral"),
        (4, "actor", "深山佳織", "doc_rei", "neutral"),
        (5, "narrator", "旁白", None, "neutral"),
        (6, "actor", "深山佳織", "doc_rei", "neutral"),
        (7, "player", "坂口隆司", None, "neutral"),
        (8, "narrator", "旁白", None, "neutral"),
        (9, "actor", "深山佳織", "doc_rei", "serious"),
        (10, "player", "坂口隆司", None, "serious"),
        (11, "actor", "深山佳織", "doc_rei", "neutral"),
        (12, "player", "坂口隆司", None, "neutral"),
        (13, "narrator", "旁白", None, "neutral"),
        (14, "player", "坂口隆司", None, "neutral"),
        (15, "narrator", "旁白", None, "serious"),
        (16, "actor", "深山佳織", "doc_rei", "serious"),
        (17, "actor", "深山佳織", "doc_rei", "serious"),
        (18, "player", "坂口隆司", None, "serious"),
        (19, "narrator", "旁白", None, "smile"),
        (20, "actor", "深山佳織", "doc_rei", "smile"),
        (21, "player", "坂口隆司", None, "smile"),
        (22, "actor", "深山佳織", "doc_rei", "neutral"),
        (23, "narrator", "旁白", None, "neutral"),
    ]
    nodes: list[dict] = []
    for idx, role, spk_label, actor_id, rei_expr in specs:
        nid = f"s01_{idx:03d}"
        next_id = f"s01_{idx + 1:03d}" if idx < 23 else "s02_001"
        node: dict = {
            "id": nid,
            "presentation": "authored",
            "speaker": role,
            "speaker_label": spk_label,
            "text": beats[idx],
            "expression": rei_expr if actor_id == "doc_rei" else "neutral",
            "background_id": "exam_room",
        }
        if actor_id is not None:
            node["actor_id"] = actor_id
            node["outfit"] = "white_coat"
        if idx < 23:
            node["event_portraits"] = rei_solo_portrait(rei_expr)
        else:
            node["hide_portrait"] = True
        node["choices"] = make_continue_choice(nid, next_id)
        nodes.append(node)
    return nodes


def build_scene_25_tail(beats: dict[int, str]) -> list[dict]:
    assert len(beats) == 17, f"Expected 17 beats in Scene 25, got {len(beats)}"
    nodes: list[dict] = []
    for idx, role, spk_label, actor_id, next_id in [
        (15, "actor", "城宮明日香", "doc_asuka", "s25_016"),
        (16, "actor", "城宮明日香", "doc_asuka", "s25_017"),
        (17, "narrator", "旁白", None, "s25b_001"),
    ]:
        nid = f"s25_{idx:03d}"
        node: dict = {
            "id": nid,
            "speaker": role,
            "speaker_label": spk_label,
            "text": beats[idx],
            "expression": "neutral",
            "background_id": "conference_room",
            "choices": make_continue_choice(nid, next_id),
        }
        if actor_id is not None:
            node["actor_id"] = actor_id
            node["outfit"] = "director_suit"
        else:
            node["hide_portrait"] = True
        nodes.append(node)
    return nodes


def build_scene_25b(beats: dict[int, str]) -> list[dict]:
    assert len(beats) == 22, f"Expected 22 beats in Scene 25B, got {len(beats)}"
    specs: list[tuple[int, str, str, str | None, str, str]] = [
        (1, "narrator", "旁白", None, "neutral", "tired"),
        (2, "narrator", "旁白", None, "neutral", "tired"),
        (3, "actor", "城宮明日香", "doc_asuka", "neutral", "tired"),
        (4, "narrator", "旁白", None, "neutral", "tired"),
        (5, "actor", "深山佳織", "doc_rei", "neutral", "tired"),
        (6, "actor", "城宮明日香", "doc_asuka", "neutral", "tired"),
        (7, "narrator", "旁白", None, "neutral", "tired"),
        (8, "actor", "深山佳織", "doc_rei", "neutral", "tired"),
        (9, "narrator", "旁白", None, "neutral", "worried"),
        (10, "actor", "深山佳織", "doc_rei", "neutral", "worried"),
        (11, "actor", "城宮明日香", "doc_asuka", "neutral", "worried"),
        (12, "actor", "深山佳織", "doc_rei", "neutral", "worried"),
        (13, "narrator", "旁白", None, "smile", "worried"),
        (14, "actor", "城宮明日香", "doc_asuka", "smile", "worried"),
        (15, "narrator", "旁白", None, "smile", "neutral"),
        (16, "actor", "深山佳織", "doc_rei", "smile", "neutral"),
        (17, "narrator", "旁白", None, "neutral", "neutral"),
        (18, "actor", "城宮明日香", "doc_asuka", "neutral", "neutral"),
        (19, "narrator", "旁白", None, "neutral", "serious"),
        (20, "actor", "深山佳織", "doc_rei", "neutral", "serious"),
        (21, "narrator", "旁白", None, "smile", "neutral"),
        (22, "actor", "城宮明日香", "doc_asuka", "smile", "neutral"),
    ]
    nodes: list[dict] = []
    for idx, role, spk_label, actor_id, asuka_expr, rei_expr in specs:
        nid = f"s25b_{idx:03d}"
        next_id = f"s25b_{idx + 1:03d}" if idx < 22 else "s26_001"
        expr = rei_expr if actor_id == "doc_rei" else (asuka_expr if actor_id == "doc_asuka" else "neutral")
        node: dict = {
            "id": nid,
            "presentation": "authored",
            "speaker": role,
            "speaker_label": spk_label,
            "text": beats[idx],
            "expression": expr,
            "background_id": "conference_room",
            "event_portraits": asuka_rei_pair_portraits(asuka_expr, rei_expr),
            "choices": make_continue_choice(nid, next_id),
        }
        if actor_id is not None:
            node["actor_id"] = actor_id
            node["outfit"] = "white_coat" if actor_id == "doc_rei" else "director_suit"
        nodes.append(node)
    return nodes


def build_scene_32(beats: dict[int, str]) -> list[dict]:
    assert len(beats) == 20, f"Expected 20 beats in Scene 32, got {len(beats)}"
    specs: list[tuple[int, str, str, str | None, str]] = [
        (1, "player", "坂口隆司", None, "neutral"),
        (2, "actor", "深山", "doc_rei", "neutral"),
        (3, "player", "坂口隆司", None, "neutral"),
        (4, "narrator", "旁白", None, "neutral"),
        (5, "actor", "深山佳織", "doc_rei", "smile"),
        (6, "player", "坂口隆司", None, "smile"),
        (7, "narrator", "旁白", None, "neutral"),
        (8, "narrator", "旁白", None, "smile"),
        (9, "actor", "深山佳織", "doc_rei", "smile"),
        (10, "narrator", "旁白", None, "tired"),
        (11, "narrator", "旁白", None, "serious"),
        (12, "actor", "深山佳織", "doc_rei", "serious"),
        (13, "actor", "深山佳織", "doc_rei", "serious"),
        (14, "actor", "深山佳織", "doc_rei", "tired"),
        (15, "narrator", "旁白", None, "tired"),
        (16, "actor", "深山佳織", "doc_rei", "worried"),
        (17, "player", "坂口隆司", None, "worried"),
        (18, "narrator", "旁白", None, "serious"),
        (19, "actor", "深山佳織", "doc_rei", "smile"),
        (20, "narrator", "旁白", None, "neutral"),
    ]
    nodes: list[dict] = []
    for idx, role, spk_label, actor_id, rei_expr in specs:
        nid = f"s32_{idx:03d}"
        next_id = f"s32_{idx + 1:03d}" if idx < 20 else "s33_001"
        node: dict = {
            "id": nid,
            "presentation": "authored",
            "speaker": role,
            "speaker_label": spk_label,
            "text": beats[idx],
            "expression": rei_expr if actor_id == "doc_rei" else "neutral",
            "background_id": "hospital_night",
            "choices": make_continue_choice(nid, next_id),
        }
        if actor_id is not None:
            node["actor_id"] = actor_id
            node["outfit"] = "white_coat"
        if idx < 20:
            node["event_portraits"] = rei_solo_portrait(rei_expr)
        else:
            node["hide_portrait"] = True
        nodes.append(node)
    return nodes


def update_step(source_beats: dict[str, dict[int, str]]) -> dict:
    steps = read_json(SPECIAL_EVENT_STEPS)
    assert isinstance(steps, list)
    step = next(s for s in steps if s.get("id") == STEP_ID)

    obsolete_ids = {"lv1_callback", "lv2_asuka_private", "lv2_pattern", "lv2_doctor"}
    kept_middle_and_tail: list[dict] = []
    for node in step["nodes"]:
        nid = node["id"]
        if nid in obsolete_ids:
            continue
        if nid.startswith("s01_") or nid.startswith("s25b_") or nid.startswith("s32_"):
            continue
        if nid in ("s25_015", "s25_016", "s25_017"):
            continue
        kept_middle_and_tail.append(node)

    by_id = {n["id"]: n for n in kept_middle_and_tail}

    # Apply targeted single-beat V8 -> V9.1 updates
    by_id["s08_023"]["text"] = source_beats["s08"][23]
    by_id["s09_001"]["text"] = source_beats["s09"][1]
    by_id["s24_006"]["text"] = source_beats["s24"][6]
    by_id["s26_014"]["text"] = source_beats["s26"][14]
    by_id["s28_009"]["text"] = source_beats["s28"][9]

    for nid in ("s26_012", "s26_014", "s26_017"):
        by_id[nid]["speaker_label"] = "片桐彩子"
        by_id[nid]["portrait_path"] = "assets/events/character_events/rei/ayako/ward_postop.png"
        by_id[nid]["portrait_scale"] = 1.0
        by_id[nid].pop("hide_portrait", None)

    # Align Scene 24 & Scene 25 background & Asuka/Kaori portrait scale per V9.1
    for nid, node in by_id.items():
        if nid.startswith("s24_") or nid.startswith("s25_"):
            node["background_id"] = "conference_room"
            if node.get("actor_id") == "doc_asuka":
                node["outfit"] = "director_suit"
            elif node.get("actor_id") == "doc_rei" and node.get("outfit", "white_coat") == "white_coat":
                node["event_portraits"] = rei_solo_portrait(node.get("expression", "neutral"))
        if nid in ("s24_003", "s24_004", "s24_005", "s24_006", "s24_007", "s24_008"):
            node["speaker"] = "actor"
            node["speaker_label"] = "城宮明日香"
            node["actor_id"] = "doc_asuka"
            node["outfit"] = "director_suit"
            node.pop("hide_portrait", None)

    # Link s25_014 -> s25_015 and s34_001 -> @day_end
    by_id["s25_014"]["choices"] = make_continue_choice("s25_014", "s25_015")
    by_id["s34_001"]["choices"] = make_continue_choice("s34_001", "@day_end", label="结束今天")

    s01_nodes = build_scene_01(source_beats["s01"])
    s25_tail_nodes = build_scene_25_tail(source_beats["s25"])
    s25b_nodes = build_scene_25b(source_beats["s25b"])
    s32_nodes = build_scene_32(source_beats["s32"])

    rebuilt_nodes: list[dict] = []
    rebuilt_nodes.extend(s01_nodes)
    for node in kept_middle_and_tail:
        nid = node["id"]
        if nid == "s26_001":
            rebuilt_nodes.extend(s25_tail_nodes)
            rebuilt_nodes.extend(s25b_nodes)
        elif nid == "s33_001":
            rebuilt_nodes.extend(s32_nodes)
        rebuilt_nodes.append(node)

    step["start"] = "s01_001"
    step["scene_schedule"] = SCENE_SCHEDULE
    step["nodes"] = rebuilt_nodes

    write_json(SPECIAL_EVENT_STEPS, steps)
    return step


def update_localization(step: dict) -> None:
    zh = read_json(LOCALIZATION_ZH)
    en = read_json(LOCALIZATION_EN)
    tr = read_json(TRANSLATIONS)
    assert isinstance(zh, dict) and isinstance(en, dict) and isinstance(tr, dict)

    zh_strings: dict[str, str] = zh["strings"]
    en_strings: dict[str, str] = en["strings"]

    ev_prefix = f"collections.special_events.{EVENT_ID}"
    step_prefix = f"collections.special_event_steps.{STEP_ID}"

    # Remove obsolete bridge node localization keys
    obsolete_prefixes = tuple(
        f"{step_prefix}.nodes.{oid}."
        for oid in ("lv1_callback", "lv2_asuka_private", "lv2_pattern", "lv2_doctor")
    )
    for target in (zh_strings, en_strings):
        for k in [key for key in target if key.startswith(obsolete_prefixes)]:
            del target[k]

    en_strings[f"{ev_prefix}.announcement"] = tr["announcement"]

    tr_nodes: dict[str, str] = tr["nodes"]
    for node in step["nodes"]:
        nid = node["id"]
        n_prefix = f"{step_prefix}.nodes.{nid}"
        zh_strings[f"{n_prefix}.text"] = node["text"]
        if node.get("speaker_label"):
            zh_strings[f"{n_prefix}.speaker_label"] = node["speaker_label"]
            en_strings[f"{n_prefix}.speaker_label"] = SPEAKER_EN_MAP.get(
                node["speaker_label"], en_strings.get(f"{n_prefix}.speaker_label", node["speaker_label"])
            )

        if nid in tr_nodes:
            en_strings[f"{n_prefix}.text"] = tr_nodes[nid]

        for choice in node.get("choices", []):
            cid = choice["id"]
            c_key = f"{n_prefix}.choices.{cid}.label"
            zh_strings[c_key] = choice["label"]
            if choice["label"] == "结束今天":
                en_strings[c_key] = "End the day"
            elif choice["label"] == "继续":
                en_strings[c_key] = "Continue"

    # Clean up legacy machine-translated proper-noun typos across untouched Lv2 EN strings
    for k, v in list(en_strings.items()):
        if not k.startswith(step_prefix + "."):
            continue
        cleaned = v.replace("SakaguchiLongji", "Ryuji Sakaguchi").replace("Shenshan", "Miyama")
        if cleaned != v:
            en_strings[k] = cleaned

    write_json(LOCALIZATION_ZH, zh)
    write_json(LOCALIZATION_EN, en)


def main() -> None:
    source_beats = parse_scene_beats_from_source()
    step = update_step(source_beats)
    update_localization(step)
    print(f"Updated {EVENT_ID} ({STEP_ID}) to V9.1 with {len(step['nodes'])} nodes.")


if __name__ == "__main__":
    main()
