#!/usr/bin/env python3
"""Deterministic importer for Hiroko Sugimura's canonical V1.2 manuscript:
1. Relationship Lv3 Rank-Up Event: 《另一家医院的灯光》 (hiroko_lv3_another_hospital_lights)
2. Independent Summer Bonus Event: 《夏夜的烟花》 (hiroko_summer_fireworks) with Lv3 / Lv4+ relationship differentials.

Preserves the supplied Chinese manuscript verbatim, splits mixed stage-direction + quote
lines into narrator + speaker beats without altering any wording or punctuation, wires
the Scene B RP choice and the Summer Fireworks Lv3 / Lv4+ opening_variants tracks, maps
multi-expression uniform, casual, and yukata portraits across all beats, registers the 4
dedicated backgrounds and 6 yukata portraits, and syncs bilingual localization entries.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts/HOSHIMI_SUGIMURA_HIROKO_LV3_AND_SUMMER_FIREWORKS_V1_2.md"
OUTPUT = ROOT / "data/staff/nurse_hiroko/lv3_events.json"
BUNDLE = ROOT / "data/staff/nurse_hiroko/bundle.json"
PROFILE = ROOT / "data/staff/nurse_hiroko/profile.json"
RELATIONSHIP = ROOT / "data/staff/nurse_hiroko/relationship.json"
BACKGROUNDS = ROOT / "data/backgrounds.json"
TRANSLATIONS = ROOT / "research/translations/hiroko_lv3_en.json"
LOCALIZATION_ZH = ROOT / "data/localization/zh_CN.json"
LOCALIZATION_EN = ROOT / "data/localization/en.json"

LV3_EVENT_ID = "hiroko_lv3_another_hospital_lights"
SUMMER_EVENT_ID = "hiroko_summer_fireworks"

SPEAKERS = {
    "坂口隆司": ("player", "Ryuji Sakaguchi"),
    "杉村弘子": ("nurse_hiroko", "Hiroko Sugimura"),
}

HIROKO_UNIFORM_PORTRAITS = {
    "neutral": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/neutral.png",
    "smile": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/smile.png",
    "closed_eye_smile": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/closed_eye_smile.png",
    "surprised": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/surprised.png",
    "worried": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/worried.png",
    "serious": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/serious.png",
    "tired": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/tired.png",
}

HIROKO_CASUAL_PORTRAITS = {
    "neutral": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/neutral.png",
    "calm": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/calm.png",
    "smile": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/smile.png",
    "closed_eye_smile": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/closed_eye_smile.png",
    "surprised": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/surprised.png",
    "worried": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/worried.png",
    "shy": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/shy.png",
    "pout": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/pout.png",
    "playful": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/playful.png",
}

HIROKO_YUKATA_PORTRAITS = {
    "neutral": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/yukata/neutral.png",
    "smile": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/yukata/smile.png",
    "closed_eye_smile": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/yukata/closed_eye_smile.png",
    "shy": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/yukata/shy.png",
    "surprised": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/yukata/surprised.png",
    "playful": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/yukata/playful.png",
}

LV3_NO_PORTRAIT_BEATS = {
    1,          # Quiet surgical corridor establishing shot
    11,         # Changing clothes and walking out of staff corridor
    27,         # Evening street sunset shadows establishing shot
    58,         # Municipal hospital inpatient lobby establishing shot
    67,         # Ryuji waiting on the lounge bench for half an hour while Hiroko is upstairs
    79,         # Night falling over the hospital windows outside
    104, 105,   # Walking along the street to the train station corner
    118,        # Watching Hiroko walk up the stairs to the platform
}

LV3_EXPRESSIONS: dict[int, tuple[str, str]] = {
    # Scene A1: Instrument prep room (uniform)
    2: ("uniform", "neutral"),
    3: ("uniform", "neutral"),
    4: ("uniform", "neutral"),
    5: ("uniform", "smile"),
    6: ("uniform", "smile"),
    7: ("uniform", "closed_eye_smile"),
    8: ("uniform", "smile"),
    9: ("uniform", "smile"),
    10: ("uniform", "smile"),
    # Scene A2: Hallway outside locker room (casual)
    12: ("casual", "neutral"),
    13: ("casual", "neutral"),
    14: ("casual", "neutral"),
    15: ("casual", "neutral"),
    16: ("casual", "surprised"),
    17: ("casual", "surprised"),
    18: ("casual", "worried"),
    19: ("casual", "worried"),
    20: ("casual", "worried"),
    21: ("casual", "calm"),
    22: ("casual", "shy"),
    23: ("casual", "shy"),
    24: ("casual", "smile"),
    25: ("casual", "smile"),
    26: ("casual", "closed_eye_smile"),
    # Scene B: Evening walkway & bus stop (casual)
    28: ("casual", "neutral"),
    29: ("casual", "neutral"),
    30: ("casual", "neutral"),
    31: ("casual", "shy"),
    32: ("casual", "shy"),
    33: ("casual", "calm"),
    34: ("casual", "calm"),
    35: ("casual", "calm"),
    36: ("casual", "calm"),
    37: ("casual", "calm"),
    38: ("casual", "calm"),
    39: ("casual", "calm"),
    40: ("casual", "worried"),
    41: ("casual", "neutral"),
    42: ("casual", "neutral"),
    43: ("casual", "neutral"),
    44: ("casual", "smile"),
    45: ("casual", "worried"),
    46: ("casual", "worried"),
    47: ("casual", "calm"),
    48: ("casual", "calm"),
    # Option A
    49: ("casual", "surprised"),
    50: ("casual", "surprised"),
    51: ("casual", "playful"),
    52: ("casual", "closed_eye_smile"),
    # Option B
    53: ("casual", "calm"),
    54: ("casual", "calm"),
    55: ("casual", "smile"),
    56: ("casual", "smile"),
    # Merge
    57: ("casual", "calm"),
    # Scene C: Municipal general hospital waiting area (casual)
    59: ("casual", "neutral"),
    60: ("casual", "neutral"),
    61: ("casual", "surprised"),
    62: ("casual", "worried"),
    63: ("casual", "worried"),
    64: ("casual", "calm"),
    65: ("casual", "smile"),
    66: ("casual", "smile"),
    # Scene C2: Hiroko returns from visiting her mother
    68: ("casual", "smile"),
    69: ("casual", "smile"),
    70: ("casual", "smile"),
    71: ("casual", "closed_eye_smile"),
    72: ("casual", "closed_eye_smile"),
    73: ("casual", "smile"),
    74: ("casual", "playful"),
    75: ("casual", "smile"),
    76: ("casual", "smile"),
    77: ("casual", "shy"),
    78: ("casual", "shy"),
    # Scene D: Pocket park bench at night (casual)
    80: ("casual", "calm"),
    81: ("casual", "calm"),
    82: ("casual", "calm"),
    83: ("casual", "calm"),
    84: ("casual", "calm"),
    85: ("casual", "neutral"),
    86: ("casual", "worried"),
    87: ("casual", "calm"),
    88: ("casual", "calm"),
    89: ("casual", "calm"),
    90: ("casual", "calm"),
    91: ("casual", "shy"),
    92: ("casual", "shy"),
    93: ("casual", "shy"),
    94: ("casual", "surprised"),
    95: ("casual", "surprised"),
    96: ("casual", "calm"),
    97: ("casual", "smile"),
    98: ("casual", "closed_eye_smile"),
    99: ("casual", "playful"),
    100: ("casual", "playful"),
    101: ("casual", "smile"),
    102: ("casual", "closed_eye_smile"),
    103: ("casual", "closed_eye_smile"),
    # Scene E: Station street corner at night (casual)
    106: ("casual", "calm"),
    107: ("casual", "smile"),
    108: ("casual", "smile"),
    109: ("casual", "calm"),
    110: ("casual", "shy"),
    111: ("casual", "shy"),
    112: ("casual", "smile"),
    113: ("casual", "shy"),
    114: ("casual", "smile"),
    115: ("casual", "smile"),
    116: ("casual", "closed_eye_smile"),
    117: ("casual", "closed_eye_smile"),
}

SUMMER_NO_PORTRAIT_LV3 = {1, 2, 3, 14, 54, 55, 56, 57, 58, 59, 60, 70, 82}
SUMMER_NO_PORTRAIT_LV4 = {1, 2, 3, 14, 53, 54, 55, 56, 57, 58, 59, 72, 84}

SUMMER_EXPRESSIONS_LV3: dict[int, str] = {
    4: "smile",
    5: "smile",
    6: "neutral",
    7: "shy",
    8: "playful",
    9: "playful",
    10: "smile",
    11: "shy",
    12: "shy",
    13: "playful",
    15: "smile",
    16: "smile",
    17: "smile",
    18: "surprised",
    19: "closed_eye_smile",
    20: "closed_eye_smile",
    21: "smile",
    22: "smile",
    23: "smile",
    24: "closed_eye_smile",
    25: "playful",
    26: "playful",
    27: "playful",
    28: "playful",
    29: "closed_eye_smile",
    # Option A (30..33)
    30: "smile",
    31: "smile",
    32: "playful",
    33: "closed_eye_smile",
    # Option B (34..37)
    34: "surprised",
    35: "surprised",
    36: "shy",
    37: "smile",
    # Merge & Scene F3..F5 (38..82)
    38: "smile",
    39: "neutral",
    40: "surprised",
    41: "surprised",
    42: "surprised",
    43: "shy",
    44: "shy",
    45: "shy",
    46: "shy",
    47: "shy",
    48: "surprised",
    49: "surprised",
    50: "playful",
    51: "playful",
    52: "smile",
    53: "smile",
    61: "neutral",
    62: "neutral",
    63: "neutral",
    64: "smile",
    65: "smile",
    66: "smile",
    67: "smile",
    68: "surprised",
    69: "shy",
    71: "smile",
    72: "playful",
    73: "playful",
    74: "smile",
    75: "smile",
    76: "playful",
    77: "playful",
    78: "smile",
    79: "shy",
    80: "shy",
    81: "closed_eye_smile",
}

SUMMER_EXPRESSIONS_LV4: dict[int, str] = {
    4: "smile",
    5: "smile",
    6: "neutral",
    7: "shy",
    8: "playful",
    9: "playful",
    10: "smile",
    11: "smile",
    12: "closed_eye_smile",
    13: "playful",
    15: "smile",
    16: "smile",
    17: "smile",
    18: "surprised",
    19: "closed_eye_smile",
    20: "closed_eye_smile",
    21: "smile",
    22: "smile",
    23: "smile",
    24: "closed_eye_smile",
    25: "playful",
    26: "playful",
    27: "playful",
    28: "playful",
    29: "closed_eye_smile",
    # Option A (30..33)
    30: "smile",
    31: "smile",
    32: "playful",
    33: "closed_eye_smile",
    # Option B (34..37)
    34: "surprised",
    35: "surprised",
    36: "shy",
    37: "smile",
    # Merge & Scene F3..F5 (38..84)
    38: "smile",
    39: "neutral",
    40: "surprised",
    41: "surprised",
    42: "neutral",
    43: "smile",
    44: "playful",
    45: "playful",
    46: "smile",
    47: "smile",
    48: "playful",
    49: "playful",
    50: "smile",
    51: "smile",
    52: "closed_eye_smile",
    60: "neutral",
    61: "neutral",
    62: "neutral",
    63: "smile",
    64: "smile",
    65: "smile",
    66: "smile",
    67: "closed_eye_smile",
    68: "smile",
    69: "smile",
    70: "closed_eye_smile",
    71: "closed_eye_smile",
    73: "smile",
    74: "playful",
    75: "playful",
    76: "smile",
    77: "smile",
    78: "playful",
    79: "playful",
    80: "smile",
    81: "shy",
    82: "shy",
    83: "playful",
}

NEW_BACKGROUNDS = [
    {
        "id": "hiroko_lv3_municipal_hospital_waiting",
        "label": "邻区综合医院·住院部公共等候区",
        "en_label": "Municipal General Hospital Inpatient Waiting Area",
        "path": "assets/backgrounds/hiroko_lv3_v1/municipal_hospital_waiting.png",
    },
    {
        "id": "hiroko_lv3_hospital_park_bench_night",
        "label": "医院外街心小公园·路灯长椅",
        "en_label": "Hospital Pocket Park Bench at Night",
        "path": "assets/backgrounds/hiroko_lv3_v1/hospital_park_bench_night.png",
    },
    {
        "id": "hiroko_summer_festival_stalls",
        "label": "河岸夏日祭典·灯笼参道与屋台夜市",
        "en_label": "Riverside Summer Festival Lantern Approach & Stalls",
        "path": "assets/backgrounds/hiroko_lv3_v1/summer_festival_stalls.png",
    },
    {
        "id": "hiroko_summer_riverbank_fireworks",
        "label": "河岸烟花大会·草坡观赏区",
        "en_label": "Riverside Fireworks Embankment Slope",
        "path": "assets/backgrounds/hiroko_lv3_v1/summer_riverbank_fireworks.png",
    },
]


def read_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def parse_lv3_event() -> list[dict]:
    manuscript = SOURCE.read_text(encoding="utf-8")
    ev1_text = "## 【Scene A" + manuscript.split("## 【Scene A", 1)[1].split("# 事件二：", 1)[0]

    skip_exact = {
        "**【玩家可见正文】**",
        "---",
        "**【杉村弘子 Relationship Lv3 事件结束｜结算：杉村弘子 Relationship 等级提升至 Lv3】**",
    }

    nodes: list[dict] = []
    scene = "A"
    part = 1
    mode = "main"
    last: dict[str, dict | None] = {"main": None, "choice_A": None, "choice_B": None}
    choice_host: dict | None = None
    choice_labels: list[str] = []
    awaiting_choice_merge = False

    scene_bg_map = {
        ("A", 1): "scrub_area",
        ("A", 2): "hallway",
        ("B", 1): "after_work_street_spring",
        ("C", 1): "hiroko_lv3_municipal_hospital_waiting",
        ("C", 2): "hiroko_lv3_municipal_hospital_waiting",
        ("D", 1): "hiroko_lv3_hospital_park_bench_night",
        ("E", 1): "after_work_street_spring_night",
    }

    def make_continue(target_id: str) -> dict:
        return {
            "id": "",
            "label": "继续",
            "next": target_id,
            "effects": {"affection": 0, "familiarity": 0},
            "flags": [],
        }

    def link(previous: dict | None, current: dict) -> None:
        if previous is not None and not previous["choices"]:
            c = make_continue(current["id"])
            c["id"] = "continue_" + previous["id"]
            previous["choices"] = [c]

    def append(speaker_name: str, text: str) -> None:
        nonlocal awaiting_choice_merge
        actor_id, _ = SPEAKERS.get(speaker_name, ("nurse_hiroko", "Narrator"))
        idx = len(nodes) + 1
        node_id = f"hlv3_{idx:03d}"
        background_id = scene_bg_map[(scene, part)]
        speaker_kind = (
            "narrator"
            if speaker_name == "旁白"
            else ("player" if actor_id == "player" else "actor")
        )
        outfit, expr = LV3_EXPRESSIONS.get(idx, ("casual", "neutral"))

        node: dict = {
            "id": node_id,
            "presentation": "authored",
            "speaker": speaker_kind,
            "actor_id": "nurse_hiroko",
            "speaker_label": speaker_name,
            "text": text,
            "expression": expr,
            "outfit": outfit,
            "background_id": background_id,
            "hide_portrait": True,
            "choices": [],
        }
        if scene in ("B", "E"):
            node["seasonal_street"] = True
        if idx not in LV3_NO_PORTRAIT_BEATS:
            node["hide_portrait"] = False
            portrait_path = (
                HIROKO_UNIFORM_PORTRAITS[expr]
                if outfit == "uniform"
                else HIROKO_CASUAL_PORTRAITS[expr]
            )
            node["event_portraits"] = [
                {
                    "id": "nurse_hiroko",
                    "path": portrait_path,
                    "x": 985,
                    "bottom": 540,
                    "width": 410,
                    "height": 500,
                }
            ]
        nodes.append(node)

        if mode in ("choice_A", "choice_B"):
            link(last[mode], node)
            last[mode] = node
            slot = 0 if mode == "choice_A" else 1
            if choice_host is None or len(choice_host["choices"]) != 2:
                raise ValueError(f"Choice branch without host at {node_id}")
            if not choice_host["choices"][slot]["next"]:
                choice_host["choices"][slot]["next"] = node_id
            return

        if awaiting_choice_merge:
            link(last["choice_A"], node)
            link(last["choice_B"], node)
            last["choice_A"] = None
            last["choice_B"] = None
            awaiting_choice_merge = False
        else:
            link(last["main"], node)
        last["main"] = node

    for raw_line in ev1_text.splitlines():
        line = raw_line.strip()
        if not line or line in skip_exact or line.startswith("*性质："):
            continue
        if line.startswith("## 【Scene "):
            scene = re.match(r"^## 【Scene ([A-E])", line).group(1)
            part = 1
            continue
        if any(
            line.startswith(p)
            for p in ("**【场景】**", "**【时间】**", "**【在场角色】**", "**【服装状态】**")
        ):
            continue
        if scene == "A" and line.startswith("十分钟后，坂口隆司换好常服走出医生通道"):
            part = 2
        if scene == "C" and line.startswith("在公共休息区的长椅上坐了大约半个小时后"):
            part = 2
        if line.startswith("**【选择："):
            choice_host = last["main"]
            choice_labels = []
            continue
        if line.startswith("- **选项 "):
            m_opt = re.match(r"^- \*\*选项 [AB]：(「.+」)\*\*$", line)
            if not m_opt or choice_host is None:
                raise ValueError(f"Malformed option line: {line}")
            choice_labels.append(m_opt.group(1))
            if len(choice_labels) == 2:
                choice_host["choices"] = [
                    {
                        "id": f"choice_{choice_host['id']}_{i + 1}",
                        "label": label,
                        "next": "",
                        "effects": {"affection": 0, "familiarity": 0},
                        "flags": [],
                    }
                    for i, label in enumerate(choice_labels)
                ]
            continue
        if line == "**【选项 A 回应】**":
            mode = "choice_A"
            continue
        if line == "**【选项 B 回应】**":
            mode = "choice_B"
            continue
        if line == "**【主线汇合】**":
            mode = "main"
            awaiting_choice_merge = True
            continue

        m_direct = re.match(r"^(坂口隆司|杉村弘子)：(「.+」)$", line)
        if m_direct:
            append(m_direct.group(1), m_direct.group(2))
            continue

        m_mixed = re.match(r"^(.+?)：(「.+」)$", line)
        if m_mixed:
            prefix, quote = m_mixed.group(1), m_mixed.group(2)
            speaker = "坂口隆司" if prefix.startswith(("坂口", "他")) else "杉村弘子"
            append("旁白", prefix + "：")
            append(speaker, quote)
            continue

        append("旁白", line)

    if not nodes:
        raise ValueError("No beats parsed for Event 1")

    nodes[-1]["choices"] = [
        {
            "id": "finish_hiroko_lv3",
            "label": "目送弘子走上月台台阶",
            "next": "@end",
            "effects": {"affection": 0, "familiarity": 0},
            "flags": [
                "hiroko_lv3_complete",
                "hiroko_boundary_trust_established",
                "hiroko_mother_hospital_visited",
            ],
        }
    ]
    return nodes


def parse_summer_track(target_branch: str) -> list[dict]:
    manuscript = SOURCE.read_text(encoding="utf-8")
    ev2_text = (
        "## 【Scene F1"
        + manuscript.split("## 【Scene F1", 1)[1].split("# 附：Concept Lock", 1)[0]
    )

    skip_exact = {
        "**【玩家可见正文】**",
        "**【条件差分问候：根据杉村弘子当前 Relationship 等级微调称呼】**",
        "**【条件差分演出 F1：根据杉村弘子当前 Relationship 等级微调反应】**",
        "**【条件差分演出 F4：烟花下的距离变化】**",
        "**【条件差分对白 F5-A：根据关系状态微调称呼】**",
        "**【条件差分收尾 F5-B：根据关系状态微调告别】**",
        "*(→ 分支 A 结束，汇合至【Scene F4 — 烟花升空】)*",
        "*(→ 分支 B 结束，汇合至【Scene F4 — 烟花升空】)*",
        "**【杉村弘子 夏季特别事件《夏夜的烟花》结束｜注：本事件为独立季节性 Bonus Event，不改变当前 Relationship 等级】**",
    }

    scene = "F1"
    active_branch = "both"
    mode = "main"
    last: dict[str, dict | None] = {"main": None, "choice_A": None, "choice_B": None}
    choice_host: dict | None = None
    choice_labels: list[str] = []
    awaiting_choice_merge = False
    nodes: list[dict] = []
    no_portrait_set = SUMMER_NO_PORTRAIT_LV3 if target_branch == "lv3" else SUMMER_NO_PORTRAIT_LV4
    expr_map = SUMMER_EXPRESSIONS_LV3 if target_branch == "lv3" else SUMMER_EXPRESSIONS_LV4

    scene_bg_map = {
        "F1": "hiroko_summer_festival_stalls",
        "F2": "hiroko_summer_festival_stalls",
        "F3": "hiroko_summer_festival_stalls",
        "F4": "hiroko_summer_riverbank_fireworks",
        "F5": "hiroko_summer_festival_stalls",
    }

    def link(previous: dict | None, current: dict) -> None:
        if previous is not None and not previous["choices"]:
            previous["choices"] = [
                {
                    "id": f"continue_{previous['id']}",
                    "label": "继续",
                    "next": current["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                }
            ]

    def append(speaker_name: str, text: str) -> None:
        nonlocal awaiting_choice_merge
        actor_id, _ = SPEAKERS.get(speaker_name, ("nurse_hiroko", "Narrator"))
        idx = len(nodes) + 1
        node_id = f"hsf_{target_branch}_{idx:03d}"
        background_id = scene_bg_map[scene]
        speaker_kind = (
            "narrator"
            if speaker_name == "旁白"
            else ("player" if actor_id == "player" else "actor")
        )
        expr = expr_map.get(idx, "neutral")

        node: dict = {
            "id": node_id,
            "presentation": "authored",
            "speaker": speaker_kind,
            "actor_id": "nurse_hiroko",
            "speaker_label": speaker_name,
            "text": text,
            "expression": expr,
            "outfit": "yukata",
            "background_id": background_id,
            "hide_portrait": True,
            "choices": [],
        }
        if idx not in no_portrait_set:
            node["hide_portrait"] = False
            node["event_portraits"] = [
                {
                    "id": "nurse_hiroko",
                    "path": HIROKO_YUKATA_PORTRAITS[expr],
                    "x": 985,
                    "bottom": 540,
                    "width": 410,
                    "height": 500,
                }
            ]
        nodes.append(node)

        if mode in ("choice_A", "choice_B"):
            link(last[mode], node)
            last[mode] = node
            slot = 0 if mode == "choice_A" else 1
            if choice_host is None or len(choice_host["choices"]) != 2:
                raise ValueError(f"Choice branch without host at {node_id}")
            if not choice_host["choices"][slot]["next"]:
                choice_host["choices"][slot]["next"] = node_id
            return

        if awaiting_choice_merge:
            link(last["choice_A"], node)
            link(last["choice_B"], node)
            last["choice_A"] = None
            last["choice_B"] = None
            awaiting_choice_merge = False
        else:
            link(last["main"], node)
        last["main"] = node

    for raw_line in ev2_text.splitlines():
        line = raw_line.strip()
        if not line or line in skip_exact or line.startswith("> ") or line.startswith("*性质："):
            continue
        if line == "---":
            active_branch = "both"
            continue
        if line.startswith("## 【Scene "):
            scene = re.match(r"^## 【Scene (F\d)", line).group(1)
            active_branch = "both"
            continue
        if any(
            line.startswith(p)
            for p in (
                "**【场景】**",
                "**【时间】**",
                "**【在场角色】**",
                "**【服装状态】**",
                "**【可选关键 CG",
            )
        ):
            continue
        if line.startswith("**【选择："):
            choice_host = last["main"]
            choice_labels = []
            continue
        if line.startswith("- **选项 "):
            m_opt = re.match(r"^- \*\*选项 [AB]：(「.+」)\*\*$", line)
            if not m_opt or choice_host is None:
                raise ValueError(f"Malformed option line in summer event: {line}")
            choice_labels.append(m_opt.group(1))
            if len(choice_labels) == 2:
                choice_host["choices"] = [
                    {
                        "id": f"choice_{choice_host['id']}_{i + 1}",
                        "label": label,
                        "next": "",
                        "effects": {"affection": 0, "familiarity": 0},
                        "flags": [],
                    }
                    for i, label in enumerate(choice_labels)
                ]
            continue
        if line == "**【选项 A 回应】**":
            mode = "choice_A"
            continue
        if line == "**【选项 B 回应】**":
            mode = "choice_B"
            continue
        if line == "**【主线汇合】**":
            mode = "main"
            awaiting_choice_merge = True
            continue
        m_inline_lv3 = re.match(r"^- \*\*【当杉村弘子为 Lv3】\*\* (.+)$", line)
        if m_inline_lv3:
            active_branch = "both"
            if target_branch == "lv3":
                line = m_inline_lv3.group(1).strip()
            else:
                continue
        m_inline_lv4 = re.match(r"^- \*\*【当杉村弘子为 Lv4\+】\*\* (.+)$", line)
        if m_inline_lv4:
            active_branch = "both"
            if target_branch == "lv4":
                line = m_inline_lv4.group(1).strip()
            else:
                continue
        if line in (
            "- **【当杉村弘子为 Lv3（暧昧／恋人未满）】**",
            "### 【分支 A：杉村弘子 Relationship Lv3（仍未成为恋人）】",
        ):
            active_branch = "lv3"
            continue
        if line in (
            "- **【当杉村弘子为 Lv4+（已是恋人）】**",
            "### 【分支 B：杉村弘子 Relationship Lv4 或更高（已经是恋人）】",
        ):
            active_branch = "lv4"
            continue
        if active_branch not in ("both", target_branch):
            continue

        m_direct = re.match(r"^(坂口隆司|杉村弘子)：(「.+」)$", line)
        if m_direct:
            append(m_direct.group(1), m_direct.group(2))
            continue

        m_mixed = re.match(r"^(.+?)：(「.+」)$", line)
        if m_mixed:
            prefix, quote = m_mixed.group(1), m_mixed.group(2)
            speaker = "坂口隆司" if prefix.startswith(("坂口", "他")) else "杉村弘子"
            append("旁白", prefix + "：")
            append(speaker, quote)
            continue

        append("旁白", line)

    if not nodes:
        raise ValueError(f"No beats parsed for summer track {target_branch}")

    end_label = (
        "目送穿浴衣的弘子走上车站台阶"
        if target_branch == "lv3"
        else "与弘子并肩牵手走进车站的灯火"
    )
    nodes[-1]["choices"] = [
        {
            "id": f"finish_hiroko_summer_fireworks_{target_branch}",
            "label": end_label,
            "next": "@end",
            "effects": {"affection": 0, "familiarity": 0},
            "flags": [
                "hiroko_summer_fireworks_complete",
                f"hiroko_summer_fireworks_{target_branch}_seen",
            ],
        }
    ]
    return nodes


def build_lv3_event(nodes: list[dict]) -> dict:
    return {
        "id": LV3_EVENT_ID,
        "actor_id": "nurse_hiroko",
        "title": "另一家医院的灯光",
        "teaser": "准时下班经过走廊时，你偶遇了手里多拎着一只装有保温杯与园艺画册的浅绿色纸袋的弘子。",
        "chapter": 3,
        "location_id": "or",
        "trigger_mode": "after_work",
        "background_id": "scrub_area",
        "outfit": "casual",
        "minutes": 120,
        "time_start": 960,
        "time_end": 1320,
        "priority": 120,
        "category": "rank_up",
        "target_level": 3,
        "benefit_id": "",
        "auto_start": True,
        "cinematic": True,
        "locks_saving": True,
        "hide_calendar_header": True,
        "hide_completion_portrait": True,
        "completion_story_flags": [
            "hiroko_lv3_complete",
            "hiroko_boundary_trust_established",
        ],
        "gallery": {
            "cg_id": LV3_EVENT_ID,
            "caption": "另一家医院的灯光",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 40,
            "required_events": ["hiroko_lv2_on_time_off_work"],
            "days_after_required_events": 3,
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "presence",
                    "minimum": -999,
                    "maximum": -30,
                }
            ],
        },
        "start": nodes[0]["id"],
        "nodes": nodes,
    }


def build_summer_event(nodes_lv3: list[dict], nodes_lv4: list[dict]) -> dict:
    all_nodes = nodes_lv3 + nodes_lv4
    return {
        "id": SUMMER_EVENT_ID,
        "actor_id": "nurse_hiroko",
        "title": "夏夜的烟花",
        "teaser": "盛夏没有夜班的傍晚，弘子身着一袭淡绀色朝颜花浴衣，邀请你一同前往一年一度的河岸夏日烟花大会。",
        "chapter": 3,
        "location_id": "ward",
        "trigger_mode": "sunday",
        "consumes_sunday": True,
        "date_location_id": "riverside_park",
        "background_id": "hiroko_summer_festival_stalls",
        "outfit": "yukata",
        "minutes": 120,
        "time_start": 540,
        "time_end": 1320,
        "priority": 125,
        "category": "contextual",
        "target_level": 3,
        "benefit_id": "",
        "auto_start": True,
        "cinematic": True,
        "locks_saving": True,
        "hide_calendar_header": True,
        "hide_completion_portrait": True,
        "completion_story_flags": ["hiroko_summer_fireworks_complete"],
        "gallery": {
            "cg_id": SUMMER_EVENT_ID,
            "caption": "夏夜的烟花",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 40,
            "required_events": [LV3_EVENT_ID],
            "days_after_required_events": 0,
            "special_requirements": [
                {
                    "type": "month_number",
                    "minimum": 6,
                    "maximum": 8,
                },
                {
                    "type": "relationship_level",
                    "actor_id": "nurse_hiroko",
                    "minimum": 3,
                    "maximum": 5,
                },
            ],
        },
        "start": nodes_lv3[0]["id"],
        "opening_variants": {
            "lv3": nodes_lv3[0]["id"],
            "lv4": nodes_lv4[0]["id"],
        },
        "nodes": all_nodes,
    }


def update_profile() -> None:
    profile = read_json(PROFILE)
    assert isinstance(profile, dict)
    outfits = list(profile["visuals"]["outfits"])
    if "yukata" not in outfits:
        outfits.append("yukata")
    profile["visuals"]["outfits"] = outfits
    portraits = profile["visuals"]["portraits"]
    for expr, path in HIROKO_YUKATA_PORTRAITS.items():
        portraits[f"yukata/{expr}"] = path
    write_json(PROFILE, profile)


def update_bundle() -> None:
    bundle = read_json(BUNDLE)
    assert isinstance(bundle, dict)
    extra = list(bundle.get("additional_character_event_files", []))
    if "lv3_events.json" not in extra:
        extra.append("lv3_events.json")
    bundle["additional_character_event_files"] = extra
    write_json(BUNDLE, bundle)


def update_relationship() -> None:
    rel = read_json(RELATIONSHIP)
    assert isinstance(rel, dict)
    for slot in rel.get("rank_slots", []):
        if int(slot.get("target_level", 0)) == 3:
            slot["event_id"] = LV3_EVENT_ID
            slot["content_status"] = "authored"
            slot["benefit_id"] = ""
            slot["special_requirements"] = [
                {
                    "type": "player_attribute",
                    "attribute": "presence",
                    "minimum": -999,
                    "maximum": -30,
                }
            ]
            slot["min_familiarity"] = 40
            slot["cooldown_days"] = 3
    write_json(RELATIONSHIP, rel)


def update_backgrounds() -> None:
    bgs = read_json(BACKGROUNDS)
    assert isinstance(bgs, list)
    by_id = {item.get("id"): item for item in bgs if isinstance(item, dict)}
    for nb in NEW_BACKGROUNDS:
        entry = {"id": nb["id"], "label": nb["label"], "path": nb["path"]}
        if nb["id"] in by_id:
            by_id[nb["id"]].update(entry)
        else:
            bgs.append(entry)
    write_json(BACKGROUNDS, bgs)


def update_localization(events: list[dict]) -> None:
    zh = read_json(LOCALIZATION_ZH)
    en = read_json(LOCALIZATION_EN)
    tr_all = read_json(TRANSLATIONS)
    assert isinstance(zh, dict) and isinstance(en, dict) and isinstance(tr_all, dict)

    zh_strings = zh["strings"]
    en_strings = en["strings"]

    speaker_en_map = {
        "旁白": "Narrator",
        "坂口隆司": "Ryuji Sakaguchi",
        "杉村弘子": "Hiroko Sugimura",
    }

    for event in events:
        ev_id = event["id"]
        tr = tr_all[ev_id]
        prefix = f"collections.character_events.{ev_id}"

        for target in (zh_strings, en_strings):
            for key in [k for k in target if k.startswith(prefix + ".")]:
                del target[key]

        zh_strings[f"{prefix}.title"] = event["title"]
        zh_strings[f"{prefix}.teaser"] = event["teaser"]
        zh_strings[f"{prefix}.gallery.caption"] = event["gallery"]["caption"]

        en_strings[f"{prefix}.title"] = tr["title"]
        en_strings[f"{prefix}.teaser"] = tr["teaser"]
        en_strings[f"{prefix}.gallery.caption"] = tr["title"]

        node_translations: dict[str, str] = tr["nodes"]
        choice_translations: dict[str, str] = tr["choices"]

        for node in event["nodes"]:
            nid = node["id"]
            if nid not in node_translations:
                raise KeyError(f"Missing English translation for beat {ev_id}:{nid}")
            n_prefix = f"{prefix}.nodes.{nid}"
            zh_strings[f"{n_prefix}.text"] = node["text"]
            zh_strings[f"{n_prefix}.speaker_label"] = node["speaker_label"]
            en_strings[f"{n_prefix}.text"] = node_translations[nid]
            en_strings[f"{n_prefix}.speaker_label"] = speaker_en_map[node["speaker_label"]]

            for choice in node["choices"]:
                cid = choice["id"]
                c_key = f"{n_prefix}.choices.{cid}.label"
                zh_strings[c_key] = choice["label"]
                if cid.startswith("continue_"):
                    en_strings[c_key] = "Continue"
                else:
                    if cid not in choice_translations:
                        raise KeyError(f"Missing English translation for choice {ev_id}:{cid}")
                    en_strings[c_key] = choice_translations[cid]

    for nb in NEW_BACKGROUNDS:
        bg_key = f"collections.backgrounds.{nb['id']}.label"
        zh_strings[bg_key] = nb["label"]
        en_strings[bg_key] = nb["en_label"]

    write_json(LOCALIZATION_ZH, zh)
    write_json(LOCALIZATION_EN, en)


def main() -> None:
    lv3_nodes = parse_lv3_event()
    summer_lv3_nodes = parse_summer_track("lv3")
    summer_lv4_nodes = parse_summer_track("lv4")

    ev_lv3 = build_lv3_event(lv3_nodes)
    ev_summer = build_summer_event(summer_lv3_nodes, summer_lv4_nodes)

    events = [ev_lv3, ev_summer]
    write_json(OUTPUT, events)
    update_profile()
    update_bundle()
    update_relationship()
    update_backgrounds()
    update_localization(events)
    print(
        f"Imported {LV3_EVENT_ID} ({len(lv3_nodes)} beats) and "
        f"{SUMMER_EVENT_ID} ({len(summer_lv3_nodes)} Lv3 beats + {len(summer_lv4_nodes)} Lv4+ beats)."
    )


if __name__ == "__main__":
    main()
