#!/usr/bin/env python3
"""Deterministic importer for Aqua Mizuki's canonical Relationship Lv2 event V2.3:
《你要不要学？》 (aqua_lv2_want_to_learn).

Preserves the supplied Chinese manuscript verbatim, splits mixed stage-direction + quote
lines into narrator + speaker beats without altering any wording or punctuation, wires
the 3 authored two-option RP choices (Scene A, Scene E, Scene F), maps multi-character
and multi-expression portraits for Aqua, Moe, and Serena across all 314 beats, reuses the
pelvic surgical field CGs during Scene F laparotomy, updates doc_aqua's bundle.json and
relationship.json (Lv2 rank slot), and syncs bilingual localization entries.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts/HOSHIMI_AQUA_LV2_WANT_TO_LEARN_V2_3.md"
OUTPUT = ROOT / "data/staff/doc_aqua/lv2_events.json"
BUNDLE = ROOT / "data/staff/doc_aqua/bundle.json"
RELATIONSHIP = ROOT / "data/staff/doc_aqua/relationship.json"
TRANSLATIONS = ROOT / "research/translations/aqua_lv2_en.json"
LOCALIZATION_ZH = ROOT / "data/localization/zh_CN.json"
LOCALIZATION_EN = ROOT / "data/localization/en.json"

EVENT_ID = "aqua_lv2_want_to_learn"
PREFIX = "aqlv2"

SPEAKERS = {
    "坂口隆司": ("player", "Ryuji Sakaguchi"),
    "水城阿库娅": ("doc_aqua", "Aqua Mizuki"),
    "赛蕾娜": ("story_guest_serena", "Serena"),
    "本庄萌恵": ("nurse_moe", "Moe Honjo"),
    "妇科护士": ("narrator", "Gynecology Nurse"),
    "护士 A": ("narrator", "Nurse A"),
    "护士 B": ("narrator", "Nurse B"),
}

SPEAKER_EN_MAP = {
    "旁白": "Narrator",
    "坂口隆司": "Ryuji Sakaguchi",
    "水城阿库娅": "Aqua Mizuki",
    "赛蕾娜": "Serena",
    "本庄萌恵": "Moe Honjo",
    "妇科护士": "Gynecology Nurse",
    "护士 A": "Nurse A",
    "护士 B": "Nurse B",
}

AQUA_PORTRAITS = {
    ("white_coat", "neutral"): "assets/characters/portrait_pack_v18/doc_aqua/white_coat/neutral.png",
    ("white_coat", "joyful"): "assets/characters/portrait_pack_v18/doc_aqua/white_coat/joyful.png",
    ("white_coat", "excited"): "assets/characters/portrait_pack_v18/doc_aqua/white_coat/excited.png",
    ("white_coat", "troubled"): "assets/characters/portrait_pack_v18/doc_aqua/white_coat/troubled.png",
    ("white_coat", "blank"): "assets/characters/portrait_pack_v18/doc_aqua/white_coat/blank.png",
    ("scrubs", "neutral"): "assets/characters/portrait_pack_v18/doc_aqua/scrubs/neutral.png",
    ("scrubs", "warm"): "assets/characters/portrait_pack_v18/doc_aqua/scrubs/joyful.png",
    ("scrubs", "focused"): "assets/characters/portrait_pack_v18/doc_aqua/scrubs/neutral.png",
    ("scrubs", "worried"): "assets/characters/portrait_pack_v18/doc_aqua/scrubs/troubled.png",
    ("sterile", "neutral"): "assets/characters/portrait_pack_v18/doc_aqua/sterile/neutral.png",
    ("sterile", "warm"): "assets/characters/portrait_pack_v18/doc_aqua/sterile/joyful.png",
    ("sterile", "focused"): "assets/characters/portrait_pack_v18/doc_aqua/sterile/neutral.png",
    ("sterile", "worried"): "assets/characters/portrait_pack_v18/doc_aqua/sterile/troubled.png",
}

MOE_PORTRAITS = {
    ("uniform", "neutral"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/neutral.png",
    ("uniform", "smile"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/smile.png",
    ("uniform", "shy"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/shy.png",
    ("uniform", "surprised"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/surprised.png",
    ("uniform", "worried"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/worried.png",
    ("uniform", "serious"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/neutral.png",
    ("scrubs", "neutral"): "assets/characters/moe_circulating_v1/neutral.png",
    ("scrubs", "warm"): "assets/characters/moe_circulating_v1/neutral.png",
    ("scrubs", "focused"): "assets/characters/moe_circulating_v1/neutral.png",
    ("scrubs", "worried"): "assets/characters/moe_circulating_v1/neutral.png",
    ("sterile", "neutral"): "assets/characters/portrait_pack_v13/nurse_moe/sterile/neutral.png",
    ("sterile", "warm"): "assets/characters/portrait_pack_v13/nurse_moe/sterile/neutral.png",
    ("sterile", "focused"): "assets/characters/portrait_pack_v13/nurse_moe/sterile/neutral.png",
    ("sterile", "worried"): "assets/characters/portrait_pack_v13/nurse_moe/sterile/neutral.png",
}

SERENA_PORTRAITS = {
    "ward_neutral": "assets/characters/story_guest_serena_v1/ward/neutral.png",
    "ward_flustered": "assets/characters/story_guest_serena_v1/ward/flustered.png",
    "or_tense": "assets/characters/story_guest_serena_v1/operating_table/tense.png",
    "or_pain": "assets/characters/story_guest_serena_v1/operating_table/pain.png",
}

CG_FIELD_01 = "assets/events/character_events/aqua/aqua_lv2_open_pelvic_field.png"
CG_FIELD_02 = "assets/events/character_events/aqua/aqua_lv2_open_pelvic_field_02.png"
CG_FIELD_01_BEATS = {221, 222, 223}
CG_FIELD_02_BEATS = set(range(254, 265))

NO_PORTRAIT_BEATS = {
    1,    # Establishing shot outside gynecology exam room
    93,   # Next afternoon preop prep room establishing shot
    277,  # Postop Day 2 morning sunlight on ward windowsill
}

SKIP_EXACT = {
    "**【玩家可见正文】**",
    "---",
    "**【水城阿库娅 Relationship Lv2 事件结束】**",
}


def read_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def story_lines() -> list[str]:
    manuscript = SOURCE.read_text(encoding="utf-8")
    marker = "## 【Scene A"
    body = marker + manuscript.split(marker, 1)[1].split("# 附：全篇 Concept Lock", 1)[0]
    return body.splitlines()


def infer_mixed_speaker(prefix: str) -> str:
    for name in SPEAKERS:
        if prefix.startswith(name):
            return name
    if "本庄萌恵" in prefix:
        return "本庄萌恵"
    return ""


def background_for_beat(idx: int) -> str:
    if 1 <= idx <= 31:
        return "gynecology_exam_room"
    if 32 <= idx <= 45:
        return "hallway"
    if 46 <= idx <= 57:
        return "gynecology_exam_room"
    if 58 <= idx <= 92:
        return "ward"
    if 93 <= idx <= 101:
        return "exam_room"
    if 102 <= idx <= 276:
        return "operating_room"
    if 277 <= idx <= 298:
        return "ward"
    return "hallway"


def aqua_state_for_beat(idx: int, text: str) -> tuple[str, str]:
    if idx <= 92 or idx >= 277:
        outfit = "white_coat"
        if idx in (2, 3, 4, 5, 7, 8, 9, 10, 11, 21, 22, 23, 24, 52, 53, 54, 55, 75, 76, 86, 87, 306, 307, 311, 312, 313, 314):
            return outfit, "excited"
        if idx in (12, 13, 19, 20, 26, 27, 28, 30, 31, 56, 57, 62, 63, 73, 74, 80, 81, 279, 280, 286, 287, 296, 297, 303, 304, 308, 309, 310):
            return outfit, "joyful"
        if idx in (15, 16, 17, 18, 36, 37, 46, 47):
            return outfit, "blank"
        if idx in (38, 39, 48, 49):
            return outfit, "troubled"
        return outfit, "neutral"
    if 93 <= idx <= 121:
        outfit = "scrubs"
        if idx in (102, 103, 104, 105, 116, 117):
            return outfit, "warm"
        return outfit, "focused"
    outfit = "sterile"
    if idx in (131, 132, 135, 136, 137, 138, 143, 144, 147, 148, 151, 152, 162, 163, 168, 169, 172, 178, 179, 199, 200, 208, 209, 243, 244, 247, 248, 251, 252, 267, 268, 272, 273, 274):
        return outfit, "warm"
    if idx in (193, 194):
        return outfit, "worried"
    return outfit, "focused"


def moe_state_for_beat(idx: int) -> tuple[str, str]:
    if 58 <= idx <= 92:
        outfit = "uniform"
        if idx in (60, 61, 68, 69):
            return outfit, "serious"
        if idx in (77, 78, 79, 82, 83):
            return outfit, "shy"
        return outfit, "neutral"
    if 102 <= idx <= 121:
        outfit = "scrubs"
        if idx in (106, 107, 108, 114, 115):
            return outfit, "worried"
        return outfit, "focused"
    if 122 <= idx <= 276:
        outfit = "sterile"
        if idx in (155, 175, 176, 177, 212, 213, 269, 270):
            return outfit, "worried"
        if idx in (224, 225, 275, 276):
            return outfit, "warm"
        return outfit, "focused"
    outfit = "uniform"
    if idx in (281, 282, 300, 301, 302):
        return outfit, "shy"
    if idx in (294, 295, 298, 304):
        return outfit, "smile"
    return outfit, "neutral"


def serena_state_for_beat(idx: int) -> str:
    if 60 <= idx <= 75:
        return "ward_neutral"
    if 76 <= idx <= 101:
        return "ward_flustered"
    if 110 <= idx <= 276:
        if idx in set(range(140, 145)) | set(range(153, 182)) | set(range(201, 206)) | set(range(234, 242)) | set(range(254, 262)):
            return "or_pain"
        return "or_tense"
    if 278 <= idx <= 293:
        return "ward_flustered"
    return "ward_neutral"


def build_event_portraits(idx: int, aqua_outfit: str, aqua_expr: str) -> list[dict]:
    if idx in NO_PORTRAIT_BEATS:
        return []
    aqua_path = AQUA_PORTRAITS[(aqua_outfit, aqua_expr)]

    # Scene A & B: Aqua solo
    if 2 <= idx <= 57:
        return [
            {
                "id": "doc_aqua",
                "path": aqua_path,
                "x": 985,
                "bottom": 540,
                "width": 410,
                "height": 500,
            }
        ]

    # Scene C entry (58-59): Moe + Aqua in ward
    if idx in (58, 59):
        moe_outfit, moe_expr = moe_state_for_beat(idx)
        return [
            {
                "id": "nurse_moe",
                "path": MOE_PORTRAITS[(moe_outfit, moe_expr)],
                "x": 460,
                "bottom": 540,
                "width": 400,
                "height": 495,
            },
            {
                "id": "doc_aqua",
                "path": aqua_path,
                "x": 970,
                "bottom": 540,
                "width": 410,
                "height": 500,
            },
        ]

    # Scene C bedside (60-92): Moe + Serena (ward) + Aqua
    if 60 <= idx <= 92:
        moe_outfit, moe_expr = moe_state_for_beat(idx)
        serena_state = serena_state_for_beat(idx)
        return [
            {
                "id": "nurse_moe",
                "path": MOE_PORTRAITS[(moe_outfit, moe_expr)],
                "x": 335,
                "bottom": 540,
                "width": 380,
                "height": 480,
            },
            {
                "id": "story_guest_serena",
                "path": SERENA_PORTRAITS[serena_state],
                "x": 680,
                "bottom": 540,
                "width": 330,
                "height": 430,
            },
            {
                "id": "doc_aqua",
                "path": aqua_path,
                "x": 1025,
                "bottom": 540,
                "width": 395,
                "height": 495,
            },
        ]

    # Scene D preop prep room (94-101): Serena solo in ward gown
    if 94 <= idx <= 101:
        serena_state = serena_state_for_beat(idx)
        return [
            {
                "id": "story_guest_serena",
                "path": SERENA_PORTRAITS[serena_state],
                "x": 985,
                "bottom": 540,
                "width": 345,
                "height": 445,
            }
        ]

    # Scene D OR instrument check (102-109) & scrubbing transition (121): Moe + Aqua in scrubs
    if (102 <= idx <= 109) or idx == 121:
        moe_outfit, moe_expr = moe_state_for_beat(idx)
        return [
            {
                "id": "nurse_moe",
                "path": MOE_PORTRAITS[(moe_outfit, moe_expr)],
                "x": 460,
                "bottom": 540,
                "width": 400,
                "height": 495,
            },
            {
                "id": "doc_aqua",
                "path": aqua_path,
                "x": 970,
                "bottom": 540,
                "width": 410,
                "height": 500,
            },
        ]

    # Scene D transfer (110-120) & Scene E pre-incision manipulator teaching (122-217):
    # Moe + Serena (operating_table) + Aqua
    if (110 <= idx <= 120) or (122 <= idx <= 217):
        moe_outfit, moe_expr = moe_state_for_beat(idx)
        serena_state = serena_state_for_beat(idx)
        return [
            {
                "id": "nurse_moe",
                "path": MOE_PORTRAITS[(moe_outfit, moe_expr)],
                "x": 325,
                "bottom": 540,
                "width": 370,
                "height": 475,
            },
            {
                "id": "story_guest_serena",
                "path": SERENA_PORTRAITS[serena_state],
                "x": 675,
                "bottom": 540,
                "width": 325,
                "height": 425,
            },
            {
                "id": "doc_aqua",
                "path": aqua_path,
                "x": 1030,
                "bottom": 540,
                "width": 380,
                "height": 485,
            },
        ]

    # Scene F surgical field CG beats (221-223 & 254-264): flanking Moe + Aqua around inset CG
    if idx in CG_FIELD_01_BEATS or idx in CG_FIELD_02_BEATS:
        moe_outfit, moe_expr = moe_state_for_beat(idx)
        return [
            {
                "id": "nurse_moe",
                "path": MOE_PORTRAITS[(moe_outfit, moe_expr)],
                "x": 200,
                "bottom": 540,
                "width": 340,
                "height": 445,
            },
            {
                "id": "doc_aqua",
                "path": aqua_path,
                "x": 1085,
                "bottom": 540,
                "width": 340,
                "height": 445,
            },
        ]

    # Scene F traction response beats (234-241): Moe + Serena (operating_table/pain) + Aqua
    if 234 <= idx <= 241:
        moe_outfit, moe_expr = moe_state_for_beat(idx)
        serena_state = serena_state_for_beat(idx)
        return [
            {
                "id": "nurse_moe",
                "path": MOE_PORTRAITS[(moe_outfit, moe_expr)],
                "x": 325,
                "bottom": 540,
                "width": 370,
                "height": 475,
            },
            {
                "id": "story_guest_serena",
                "path": SERENA_PORTRAITS[serena_state],
                "x": 675,
                "bottom": 540,
                "width": 325,
                "height": 425,
            },
            {
                "id": "doc_aqua",
                "path": aqua_path,
                "x": 1030,
                "bottom": 540,
                "width": 380,
                "height": 485,
            },
        ]

    # Remaining Scene F laparotomy beats (218-220, 224-233, 242-253, 265-276): Moe + Aqua in sterile
    if 218 <= idx <= 276:
        moe_outfit, moe_expr = moe_state_for_beat(idx)
        return [
            {
                "id": "nurse_moe",
                "path": MOE_PORTRAITS[(moe_outfit, moe_expr)],
                "x": 460,
                "bottom": 540,
                "width": 400,
                "height": 495,
            },
            {
                "id": "doc_aqua",
                "path": aqua_path,
                "x": 970,
                "bottom": 540,
                "width": 410,
                "height": 500,
            },
        ]

    # Scene G postop ward rounds (278-298): Moe + Serena (ward) + Aqua
    if 278 <= idx <= 298:
        moe_outfit, moe_expr = moe_state_for_beat(idx)
        serena_state = serena_state_for_beat(idx)
        return [
            {
                "id": "nurse_moe",
                "path": MOE_PORTRAITS[(moe_outfit, moe_expr)],
                "x": 335,
                "bottom": 540,
                "width": 380,
                "height": 480,
            },
            {
                "id": "story_guest_serena",
                "path": SERENA_PORTRAITS[serena_state],
                "x": 680,
                "bottom": 540,
                "width": 330,
                "height": 430,
            },
            {
                "id": "doc_aqua",
                "path": aqua_path,
                "x": 1025,
                "bottom": 540,
                "width": 395,
                "height": 495,
            },
        ]

    # Scene G hallway with Moe (299-304): Moe + Aqua
    if 299 <= idx <= 304:
        moe_outfit, moe_expr = moe_state_for_beat(idx)
        return [
            {
                "id": "nurse_moe",
                "path": MOE_PORTRAITS[(moe_outfit, moe_expr)],
                "x": 460,
                "bottom": 540,
                "width": 400,
                "height": 495,
            },
            {
                "id": "doc_aqua",
                "path": aqua_path,
                "x": 970,
                "bottom": 540,
                "width": 410,
                "height": 500,
            },
        ]

    # Scene G hallway closing solo (305-314): Aqua solo
    return [
        {
            "id": "doc_aqua",
            "path": aqua_path,
            "x": 985,
            "bottom": 540,
            "width": 410,
            "height": 500,
        }
    ]


def parse_beats() -> list[dict]:
    nodes: list[dict] = []
    mode = "main"
    last: dict[str, dict | None] = {
        "main": None,
        "A": None,
        "B": None,
    }
    choice_host: dict | None = None
    choice_labels: list[str] = []
    awaiting_merge = False

    def connect(previous: dict | None, current: dict) -> None:
        if previous is not None and not previous["choices"]:
            previous["choices"] = [
                {
                    "id": "continue_" + previous["id"],
                    "label": "继续",
                    "next": current["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                }
            ]

    def append(speaker_name: str, text: str) -> None:
        nonlocal awaiting_merge
        raw_actor_id, _ = SPEAKERS.get(speaker_name, ("doc_aqua", "Narrator"))
        idx = len(nodes) + 1
        node_id = f"{PREFIX}_{idx:03d}"
        background_id = background_for_beat(idx)
        aqua_outfit, aqua_expr = aqua_state_for_beat(idx, text)

        if speaker_name == "旁白":
            speaker_kind = "narrator"
            active_actor_id = "doc_aqua"
            node_outfit = aqua_outfit
            node_expr = aqua_expr if aqua_outfit == "white_coat" else "neutral"
        elif raw_actor_id == "player":
            speaker_kind = "player"
            active_actor_id = "doc_aqua"
            node_outfit = aqua_outfit
            node_expr = aqua_expr if aqua_outfit == "white_coat" else "neutral"
        elif raw_actor_id == "nurse_moe":
            speaker_kind = "actor"
            active_actor_id = "nurse_moe"
            moe_outfit, moe_expr = moe_state_for_beat(idx)
            node_outfit = moe_outfit
            node_expr = moe_expr
        else:
            speaker_kind = "actor"
            active_actor_id = "doc_aqua"
            node_outfit = aqua_outfit
            node_expr = aqua_expr if aqua_outfit == "white_coat" else "neutral"

        portraits = build_event_portraits(idx, aqua_outfit, aqua_expr)
        node: dict = {
            "id": node_id,
            "presentation": "authored",
            "speaker": speaker_kind,
            "actor_id": active_actor_id,
            "speaker_label": speaker_name,
            "text": text,
            "expression": node_expr,
            "outfit": node_outfit,
            "background_id": background_id,
            "hide_portrait": len(portraits) == 0,
            "choices": [],
        }
        if idx in CG_FIELD_01_BEATS:
            node["cg_path"] = CG_FIELD_01
            node["cg_fit"] = "inset"
            node["cg_portrait_overlay"] = True
        elif idx in CG_FIELD_02_BEATS:
            node["cg_path"] = CG_FIELD_02
            node["cg_fit"] = "inset"
            node["cg_portrait_overlay"] = True
        if portraits:
            node["event_portraits"] = portraits

        nodes.append(node)

        if mode in ("A", "B"):
            connect(last[mode], node)
            last[mode] = node
            slot = 0 if mode == "A" else 1
            if choice_host is None or len(choice_host["choices"]) != 2:
                raise ValueError(f"Choice branch without host at {node_id}")
            if not choice_host["choices"][slot]["next"]:
                choice_host["choices"][slot]["next"] = node_id
            return

        if awaiting_merge:
            connect(last["A"], node)
            connect(last["B"], node)
            last["A"] = None
            last["B"] = None
            awaiting_merge = False
        else:
            connect(last["main"], node)
        last["main"] = node

    for raw in story_lines():
        line = raw.strip()
        if not line or line in SKIP_EXACT:
            continue
        if line.startswith("## 【Scene "):
            mode = "main"
            continue
        if line.startswith(
            (
                "**【场景】**",
                "**【时间】**",
                "**【在场角色】**",
                "**【服装状态】**",
                "**【优先演出 CG 提示",
                "**【演出与资源说明】**",
                "**【水城阿库娅 Relationship Lv2 事件结束",
            )
        ):
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
        m_opt = re.fullmatch(r"- \*\*选项 [AB]：(.+)\*\*", line)
        if m_opt:
            label = m_opt.group(1).strip()
            if label.startswith("「") and label.endswith("」"):
                label = label[1:-1]
            choice_labels.append(label)
            if len(choice_labels) == 2:
                choice_host["choices"] = [
                    {
                        "id": f"choice_{choice_host['id']}_a",
                        "label": choice_labels[0],
                        "next": "",
                        "effects": {"affection": 0, "familiarity": 0},
                        "flags": [],
                    },
                    {
                        "id": f"choice_{choice_host['id']}_b",
                        "label": choice_labels[1],
                        "next": "",
                        "effects": {"affection": 0, "familiarity": 0},
                        "flags": [],
                    },
                ]
            continue
        if line in ("**【分支 A】**", "**【选项 A 回应】**"):
            mode, last["A"] = "A", None
            continue
        if line in ("**【分支 B】**", "**【选项 B 回应】**"):
            mode, last["B"] = "B", None
            continue
        if line == "**【主线汇合】**":
            mode, awaiting_merge = "main", True
            continue

        m_quote = re.fullmatch(r"([^：]+)：(「.+」)", line)
        if m_quote and m_quote.group(1) in SPEAKERS:
            append(m_quote.group(1), m_quote.group(2))
            continue
        if m_quote:
            mixed = infer_mixed_speaker(m_quote.group(1))
            if mixed:
                append("旁白", m_quote.group(1) + "：")
                append(mixed, m_quote.group(2))
            else:
                append("旁白", line)
            continue

        append("旁白", line)

    if awaiting_merge or last["A"] is not None or last["B"] is not None:
        raise ValueError("Unclosed branch in manuscript")
    if len(nodes) != 314:
        raise ValueError(f"Expected 314 beats, got {len(nodes)}")
    if sum(1 for n in nodes if len(n["choices"]) == 2) != 3:
        raise ValueError("Expected exactly 3 two-option choices")

    nodes[-1]["choices"] = [
        {
            "id": "finish_" + nodes[-1]["id"],
            "label": "结束",
            "next": "@end",
            "effects": {"affection": 0, "familiarity": 0},
            "flags": [
                "aqua_hysterectomy_teaching_complete",
                "aqua_manipulator_teaching_complete",
            ],
        }
    ]
    return nodes


def build_event(nodes: list[dict]) -> dict:
    return {
        "id": EVENT_ID,
        "actor_id": "doc_aqua",
        "title": "你要不要学？",
        "teaser": "完成第十台妇科手术后，水城阿库娅在妇科检查室门口满眼期待地拦住了坂口，主动提议带教开放式全子宫切除术与术前举宫器配合。",
        "chapter": 2,
        "location_id": "gynecology_exam",
        "trigger_mode": "location",
        "background_id": "gynecology_exam_room",
        "outfit": "white_coat",
        "minutes": 120,
        "time_start": 540,
        "time_end": 1020,
        "priority": 115,
        "category": "rank_up",
        "target_level": 2,
        "benefit_id": "unlock_hysterectomy_and_manipulator",
        "completion_story_flags": [
            "aqua_hysterectomy_teaching_complete",
            "aqua_manipulator_teaching_complete",
        ],
        "auto_start": True,
        "cinematic": True,
        "locks_saving": True,
        "hide_completion_portrait": True,
        "gallery": {
            "cg_id": EVENT_ID,
            "caption": "你要不要学？",
            "path": CG_FIELD_02,
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 25,
            "required_events": ["aqua_lv1_gyne_obsession"],
            "days_after_required_events": 3,
            "special_requirements": [
                {
                    "type": "progress_counter",
                    "actor_id": "global",
                    "counter_id": "gynecology_case_count",
                    "minimum": 10,
                },
                {
                    "type": "player_attribute",
                    "attribute": "skill",
                    "minimum": 60,
                },
            ],
        },
        "start": nodes[0]["id"],
        "nodes": nodes,
    }


def update_bundle() -> None:
    bundle = read_json(BUNDLE)
    assert isinstance(bundle, dict)
    bundle["character_events"] = "events.json"
    extra = list(bundle.get("additional_character_event_files", []))
    if "lv2_events.json" not in extra:
        extra.append("lv2_events.json")
    bundle["additional_character_event_files"] = extra
    write_json(BUNDLE, bundle)


def update_relationship() -> None:
    rel = read_json(RELATIONSHIP)
    assert isinstance(rel, dict)
    for slot in rel.get("rank_slots", []):
        if int(slot.get("target_level", 0)) == 2:
            slot["event_id"] = EVENT_ID
            slot["content_status"] = "authored"
            slot["benefit_id"] = "unlock_hysterectomy_and_manipulator"
            slot["min_familiarity"] = 25
            slot["cooldown_days"] = 3
            slot["special_requirements"] = [
                {
                    "type": "progress_counter",
                    "actor_id": "global",
                    "counter_id": "gynecology_case_count",
                    "minimum": 10,
                },
                {
                    "type": "player_attribute",
                    "attribute": "skill",
                    "minimum": 60,
                },
            ]
    write_json(RELATIONSHIP, rel)


def update_localization(event: dict) -> None:
    zh = read_json(LOCALIZATION_ZH)
    en = read_json(LOCALIZATION_EN)
    tr = read_json(TRANSLATIONS)
    assert isinstance(zh, dict) and isinstance(en, dict) and isinstance(tr, dict)

    zh_strings = zh["strings"]
    en_strings = en["strings"]
    prefix = f"collections.character_events.{EVENT_ID}"

    for target in (zh_strings, en_strings):
        for key in [k for k in target if k.startswith(prefix + ".")]:
            del target[key]

    zh_strings[f"{prefix}.title"] = event["title"]
    zh_strings[f"{prefix}.teaser"] = event["teaser"]
    zh_strings[f"{prefix}.gallery.caption"] = event["gallery"]["caption"]

    en_strings[f"{prefix}.title"] = "Do You Want to Learn?"
    en_strings[f"{prefix}.teaser"] = (
        "After your tenth gynecological surgery, Aqua Mizuki intercepts you outside the "
        "gynecology exam room with sparkling eyes, eager to mentor you in an Open Total "
        "Abdominal Hysterectomy with pre-incision uterine manipulator assistance."
    )
    en_strings[f"{prefix}.gallery.caption"] = "Do You Want to Learn?"

    for node in event["nodes"]:
        nid = node["id"]
        if nid not in tr:
            raise KeyError(f"Missing English translation for beat {nid}")
        n_prefix = f"{prefix}.nodes.{nid}"
        zh_strings[f"{n_prefix}.text"] = node["text"]
        zh_strings[f"{n_prefix}.speaker_label"] = node["speaker_label"]
        en_strings[f"{n_prefix}.text"] = tr[nid]
        en_strings[f"{n_prefix}.speaker_label"] = SPEAKER_EN_MAP[node["speaker_label"]]

        for choice in node["choices"]:
            cid = choice["id"]
            c_key = f"{n_prefix}.choices.{cid}.label"
            zh_strings[c_key] = choice["label"]
            if cid.startswith("continue_"):
                en_strings[c_key] = "Continue"
            elif cid.startswith("finish_"):
                en_strings[c_key] = "Finish"
            else:
                if cid not in tr:
                    raise KeyError(f"Missing English translation for choice {cid}")
                en_strings[c_key] = tr[cid]

    write_json(LOCALIZATION_ZH, zh)
    write_json(LOCALIZATION_EN, en)


def main() -> None:
    nodes = parse_beats()
    event = build_event(nodes)
    write_json(OUTPUT, [event])
    update_bundle()
    update_relationship()
    update_localization(event)
    print(f"Imported {EVENT_ID} with {len(nodes)} beats.")


if __name__ == "__main__":
    main()
