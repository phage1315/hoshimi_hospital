#!/usr/bin/env python3
"""Import the canonical Narumi/Ren shared Lv3 V2.3 fixed VN."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts/HOSHIMI_JINGUJI_NARUMI_NANASE_REN_SHARED_LV3_RYOU_SEI_V2_3.md"
OUTPUT = ROOT / "data/staff/doc_aoi/shared_lv3_events.json"
TRANSLATIONS = ROOT / "research/translations/narumi_ren_shared_lv3_en.json"
LOCALIZATION = ROOT / "data/localization/en.json"
EVENT_ID = "narumi_ren_shared_lv3_settled_accounts"
PREFIX = "nr3"
CG_PATH = "assets/events/character_events/narumi_ren/narumi_ren_shared_lv3_strategy_alliance.png"
CG_NODE_IDS = {f"nr3_{number:03d}" for number in range(387, 393)}
OR_CG_PATH = "assets/events/character_events/narumi_ren/narumi_ren_shared_lv3_yayoi_awake_or.png"
OR_CG_NODE_IDS = {f"nr3_{number:03d}" for number in range(184, 190)}
PELVIC_CG_PATH = "assets/events/character_events/narumi_ren/narumi_ren_shared_lv3_yayoi_pelvic_field.png"
PELVIC_CG_NODE_IDS = {f"nr3_{number:03d}" for number in range(192, 209)}
PRESERVATION_CG_PATH = "assets/events/character_events/narumi_ren/narumi_ren_shared_lv3_yayoi_ovary_preserved.png"
PRESERVATION_CG_NODE_IDS = {f"nr3_{number:03d}" for number in range(209, 218)}

SPEAKERS = {
    "坂口隆司": ("player", "Ryuji Sakaguchi"),
    "神宮寺成美": ("doc_aoi", "Narumi Jinguji"),
    "七瀬恋": ("nurse_haru", "Ren Nanase"),
    "六合塚弥生": ("kunizuka_yayoi", "Yayoi Kunizuka"),
    "城宮明日香": ("doc_asuka", "Asuka Jogu"),
    "中井美佳": ("nurse_rin", "Mika Nakai"),
    "水城阿库娅": ("doc_aqua", "Aqua Mizuki"),
    "深山佳織": ("doc_rei", "Kaori Miyama"),
    "比良坂竜二": ("hirasaka_ryuji", "Ryuji Hirasaka"),
}

SCENE_ART = {
    1: ("exam_room", "white_coat"),
    2: ("shared_doctors_office", "white_coat"),
    3: ("director_office", "white_coat"),
    4: ("ward_night", "uniform"),
    5: ("exam_room", "white_coat"),
    6: ("operating_room", "sterile"),
    7: ("ward", "white_coat"),
    8: ("director_office", "white_coat"),
    9: ("director_office", "white_coat"),
    10: ("director_office", "white_coat"),
    11: ("director_office", "white_coat"),
    12: ("director_office", "white_coat"),
    13: ("director_office", "white_coat"),
    14: ("hallway", "white_coat"),
    15: ("shared_doctors_office", "white_coat"),
}

PORTRAITS = {
    ("kunizuka_yayoi", "casual_neutral"): "assets/characters/story_guest_yayoi_v1/casual/neutral.png",
    ("kunizuka_yayoi", "casual_guarded"): "assets/characters/story_guest_yayoi_v1/casual/guarded.png",
    ("kunizuka_yayoi", "ward_neutral"): "assets/characters/story_guest_yayoi_v1/ward/neutral.png",
    ("kunizuka_yayoi", "ward_worried"): "assets/characters/story_guest_yayoi_v1/ward/worried.png",
    ("kunizuka_yayoi", "ward_postop_tired"): "assets/characters/story_guest_yayoi_v1/ward/postop_tired.png",
    ("kunizuka_yayoi", "or_tense"): "assets/characters/story_guest_yayoi_v1/operating_table/tense.png",
    ("kunizuka_yayoi", "or_pain"): "assets/characters/story_guest_yayoi_v1/operating_table/pain.png",
    ("kunizuka_yayoi", "or_exhausted"): "assets/characters/story_guest_yayoi_v1/operating_table/exhausted.png",
    ("doc_aoi", "white_coat"): "assets/characters/portrait_pack_v1/doc_aoi/white_coat/serious.png",
    ("doc_aoi", "sterile"): "assets/characters/sterile_pack_v1/doc_aoi/neutral.png",
    ("nurse_haru", "uniform"): "assets/characters/portrait_pack_v1/nurse_haru/uniform/serious.png",
    ("nurse_haru", "sterile"): "assets/characters/sterile_pack_v1/nurse_haru/neutral.png",
    ("doc_asuka", "white_coat"): "assets/characters/portrait_pack_v15/doc_asuka/white_coat/neutral.png",
    ("doc_aqua", "white_coat"): "assets/characters/portrait_pack_v18/doc_aqua/white_coat/neutral.png",
    ("doc_rei", "white_coat"): "assets/characters/portrait_pack_v20/doc_rei/white_coat/neutral.png",
    ("nurse_rin", "sterile"): "assets/characters/sterile_pack_v1/nurse_rin/neutral.png",
}

SKIP_EXACT = {
    "**【玩家可见正文】**", "---",
    "**【神宮寺成美 × 七瀬恋 共享 Relationship Lv3 事件结束】**",
}


def story_lines() -> list[str]:
    manuscript = SOURCE.read_text(encoding="utf-8")
    marker = "## 【Scene 1"
    return (marker + manuscript.split(marker, 1)[1].split("## 【Codex实现说明】", 1)[0]).splitlines()


def clean_visible(line: str) -> str:
    return line.replace("**", "")


def yayoi_expression(scene: int, node_number: int, text: str) -> str:
    if scene in (1, 14):
        return "casual_guarded" if scene == 1 and node_number < 35 else "casual_neutral"
    if scene in (4, 5):
        return "ward_worried" if any(token in text for token in ("担心", "怕", "紧张", "比良坂", "疑惑")) else "ward_neutral"
    if scene == 6:
        if node_number >= 218:
            return "or_exhausted"
        if node_number >= 197 or any(token in text for token in ("牵拉", "坠胀", "屏", "湿润")):
            return "or_pain"
        return "or_tense"
    if scene == 7:
        return "ward_postop_tired"
    return "ward_neutral"


def portrait_for(actor_id: str, scene: int, node_number: int, text: str) -> tuple[str, str]:
    if actor_id == "kunizuka_yayoi":
        expression = yayoi_expression(scene, node_number, text)
        return PORTRAITS.get((actor_id, expression), ""), expression
    if actor_id == "doc_aoi":
        outfit = "sterile" if scene == 6 else "white_coat"
    elif actor_id == "nurse_haru":
        outfit = "sterile" if scene == 6 else "uniform"
    elif actor_id == "nurse_rin":
        outfit = "sterile"
    elif actor_id in ("doc_asuka", "doc_aqua", "doc_rei"):
        outfit = "white_coat"
    else:
        return "", "neutral"
    return PORTRAITS.get((actor_id, outfit), ""), "neutral"


def parse_beats() -> list[dict]:
    nodes: list[dict] = []
    scene = 1
    mode = "main"
    last: dict[str, dict | None] = {"main": None, "A": None, "B": None}
    choice_host: dict | None = None
    choice_labels: list[str] = []
    awaiting_merge = False
    active_background = SCENE_ART[scene][0]

    def connect(previous: dict | None, current: dict) -> None:
        if previous is not None and not previous["choices"]:
            previous["choices"] = [{
                "id": "continue_" + previous["id"], "label": "继续", "next": current["id"],
                "effects": {"affection": 0, "familiarity": 0}, "flags": [],
            }]

    def append(speaker: str, text: str) -> None:
        nonlocal awaiting_merge
        actor_id, _ = SPEAKERS.get(speaker, ("doc_aoi", "Narrator"))
        node_number = len(nodes) + 1
        node_id = f"{PREFIX}_{node_number:03d}"
        path, expression = portrait_for(actor_id, scene, node_number, text)
        if actor_id == "kunizuka_yayoi":
            outfit = "casual" if scene in (1, 14) else ("operating_patient" if scene == 6 else "patient_gown")
        elif actor_id in ("doc_aoi", "nurse_haru", "nurse_rin") and scene == 6:
            outfit = "sterile"
        elif actor_id == "nurse_haru":
            outfit = "uniform"
        else:
            outfit = SCENE_ART[scene][1]
        node = {
            "id": node_id,
            "presentation": "authored",
            "speaker": "narrator" if speaker == "旁白" else ("player" if actor_id == "player" else "actor"),
            "actor_id": actor_id,
            "speaker_label": speaker,
            "text": clean_visible(text),
            "expression": expression,
            "outfit": outfit,
            "background_id": active_background,
            "hide_portrait": True,
            "choices": [],
        }
        if path and speaker != "旁白":
            node["hide_portrait"] = False
            node["event_portraits"] = [{
                "id": actor_id, "path": path, "x": 1030, "bottom": 540,
                "width": 410, "height": 500,
            }]
        nodes.append(node)
        if mode in ("A", "B"):
            connect(last[mode], node)
            last[mode] = node
            slot = 0 if mode == "A" else 1
            if choice_host is None or len(choice_host["choices"]) != 2:
                raise ValueError(f"Branch without choice at {node_id}")
            if not choice_host["choices"][slot]["next"]:
                choice_host["choices"][slot]["next"] = node_id
        else:
            if awaiting_merge:
                connect(last["A"], node)
                connect(last["B"], node)
                last["A"] = last["B"] = None
                awaiting_merge = False
            else:
                connect(last["main"], node)
            last["main"] = node

    for raw in story_lines():
        line = raw.strip()
        if not line or line in SKIP_EXACT:
            continue
        heading = re.fullmatch(r"## 【Scene (\d+) — .+】", line)
        if heading:
            scene = int(heading.group(1))
            mode = "main"
            active_background = SCENE_ART[scene][0]
            continue
        if line.startswith(("**【场景】**", "**【时间】**", "**【在场角色】**", "**【服装状态】**")):
            continue
        if line.startswith("**【选择："):
            if last["main"] is None:
                raise ValueError("Choice has no visible host")
            choice_host = last["main"]
            last["main"] = None
            choice_labels = []
            mode = "choice"
            continue
        if line.startswith("*性质："):
            continue
        option = re.fullmatch(r"- \*\*选项 [AB]：(「.*」)\*\*", line)
        if option:
            choice_labels.append(option.group(1)[1:-1])
            if len(choice_labels) == 2:
                choice_host["choices"] = [
                    {"id": f"choice_{choice_host['id']}_a", "label": choice_labels[0], "next": "", "effects": {"affection": 0, "familiarity": 0}, "flags": []},
                    {"id": f"choice_{choice_host['id']}_b", "label": choice_labels[1], "next": "", "effects": {"affection": 0, "familiarity": 0}, "flags": []},
                ]
            continue
        if line == "**【分支 A】**":
            mode, last["A"] = "A", None
            continue
        if line == "**【分支 B】**":
            mode, last["B"] = "B", None
            continue
        if line == "**【主线汇合】**":
            mode, awaiting_merge = "main", True
            continue
        match = re.fullmatch(r"([^：]+)：(「.*」)", line)
        if match and match.group(1) in SPEAKERS:
            append(match.group(1), match.group(2))
        elif match:
            mixed_speaker = next((name for name in SPEAKERS if match.group(1).startswith(name)), "")
            if mixed_speaker:
                append("旁白", match.group(1) + "：")
                append(mixed_speaker, match.group(2))
            else:
                append("旁白", line)
        else:
            append("旁白", line)

    if awaiting_merge or last["A"] is not None or last["B"] is not None:
        raise ValueError("Unclosed branch")
    available_node_ids = {str(node["id"]) for node in nodes}
    required_cg_nodes = CG_NODE_IDS | OR_CG_NODE_IDS | PELVIC_CG_NODE_IDS | PRESERVATION_CG_NODE_IDS
    if not required_cg_nodes.issubset(available_node_ids):
        raise ValueError(f"CG window drifted from source beats: {sorted(required_cg_nodes - available_node_ids)}")
    for node in nodes:
        node_id = str(node["id"])
        if node_id in CG_NODE_IDS:
            node["cg_path"] = CG_PATH
            node["cg_fit"] = "cover"
            # Full-screen CG rendering returns before the portrait branch.
            node["hide_portrait"] = False
        elif node_id in OR_CG_NODE_IDS:
            node["cg_path"] = OR_CG_PATH
            node["cg_fit"] = "cover"
            node["hide_portrait"] = False
        elif node_id in PELVIC_CG_NODE_IDS:
            node["cg_path"] = PELVIC_CG_PATH
            # Keep the supplied 3:2 frame and corner face splash fully visible.
            node["cg_fit"] = "contain"
            node["hide_portrait"] = False
        elif node_id in PRESERVATION_CG_NODE_IDS:
            node["cg_path"] = PRESERVATION_CG_PATH
            node["cg_fit"] = "cover"
            node["hide_portrait"] = False
    if sum(1 for node in nodes if len(node["choices"]) == 2) != 3:
        raise ValueError("Expected exactly three authored choices")
    nodes[-1]["choices"] = [{
        "id": "finish_" + nodes[-1]["id"], "label": "结束", "next": "@end",
        "effects": {"affection": 0, "familiarity": 0}, "flags": [],
    }]
    return nodes


def main() -> None:
    beats = parse_beats()
    event = {
        "id": EVENT_ID,
        "actor_id": "doc_aoi",
        "relationship_actor_ids": ["doc_aoi", "nurse_haru"],
        "completion_story_flags": ["narumi_ren_shared_lv3_complete", "hirasaka_investigation_ended"],
        "title": "两清",
        "teaser": "第二封介绍信把真正的患者送到了星见，也把成美与恋的旧账推到了必须结清的一天。",
        "chapter": 3,
        "location_id": "exam",
        "trigger_mode": "location",
        "background_id": "exam_room",
        "outfit": "white_coat",
        "minutes": 10,
        "time_start": 540,
        "time_end": 1080,
        "priority": 115,
        "category": "rank_up",
        "target_level": 3,
        "benefit_id": "",
        "cinematic": True,
        "locks_saving": True,
        "hide_calendar_header": True,
        "hide_completion_portrait": True,
        "completion_day_offset": 7,
        "completion_absolute_clock": 1019,
        "completion_display_clock": 1080,
        "gallery": {"cg_id": EVENT_ID, "caption": "两清", "path": CG_PATH, "show_on_complete": True},
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 40,
            "required_events": ["narumi_ren_shared_lv2_sign_here"],
            "days_after_required_events": 3,
            "special_requirements": [{"type": "player_attribute", "attribute": "skill", "minimum": 60}],
        },
        "start": beats[0]["id"],
        "nodes": beats,
    }
    OUTPUT.write_text(json.dumps([event], ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if not TRANSLATIONS.exists():
        pending = {beat["id"]: "" for beat in beats}
        for beat in beats:
            if len(beat["choices"]) == 2:
                for choice in beat["choices"]:
                    pending[choice["id"]] = ""
        TRANSLATIONS.write_text(json.dumps(pending, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"wrote {len(beats)} source beats and translation template")
        return
    translations = json.loads(TRANSLATIONS.read_text(encoding="utf-8"))
    localized = json.loads(LOCALIZATION.read_text(encoding="utf-8"))
    strings = localized["strings"]
    prefix = f"collections.character_events.{EVENT_ID}"
    for key in list(strings):
        if key.startswith(prefix + "."):
            del strings[key]
    strings[prefix + ".title"] = "Settled Accounts"
    strings[prefix + ".teaser"] = "A second referral brings a real patient to Hoshimi—and forces Narumi and Ren to settle their past for good."
    strings[prefix + ".gallery.caption"] = "Settled Accounts"
    for beat in beats:
        english = str(translations.get(beat["id"], "")).strip()
        if not english:
            raise ValueError(f"Missing English translation: {beat['id']} {beat['text']}")
        stem = f"{prefix}.nodes.{beat['id']}"
        strings[stem + ".text"] = english
        strings[stem + ".speaker_label"] = "Narrator" if beat["speaker_label"] == "旁白" else SPEAKERS[beat["speaker_label"]][1]
        for choice in beat["choices"]:
            key = stem + ".choices." + choice["id"] + ".label"
            if len(beat["choices"]) == 2:
                translated = str(translations.get(choice["id"], "")).strip()
                if not translated:
                    raise ValueError(f"Missing English choice: {choice['id']}")
                strings[key] = translated
            else:
                strings[key] = "Finish" if choice["next"] == "@end" else "Continue"
    LOCALIZATION.write_text(json.dumps(localized, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"imported {EVENT_ID}: {len(beats)} beats")


if __name__ == "__main__":
    main()
