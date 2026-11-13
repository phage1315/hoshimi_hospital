#!/usr/bin/env python3
"""Deterministic importer for Manami Iimura's canonical Relationship Lv2 event V1.1:
《和弘子一起吃饭》 (manami_lv2_dinner_with_hiroko).

Preserves the supplied Chinese manuscript verbatim, splits mixed stage-direction + quote
lines into narrator + speaker beats without altering any wording or punctuation, wires
the Scene 3 RP choice and Scene 4 / Scene 5 Hiroko relationship_level (Lv0-3 vs Lv4-5)
branches, maps multi-expression casual portraits for both Manami and Hiroko across all
205 beats, and syncs bilingual localization entries.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts/HOSHIMI_IIMURA_MANAMI_LV2_DINNER_WITH_HIROKO_V1_1.md"
OUTPUT = ROOT / "data/staff/pharmacist_manami/lv2_events.json"
BUNDLE = ROOT / "data/staff/pharmacist_manami/bundle.json"
RELATIONSHIP = ROOT / "data/staff/pharmacist_manami/relationship.json"
BACKGROUNDS = ROOT / "data/backgrounds.json"
TRANSLATIONS = ROOT / "research/translations/manami_lv2_en.json"
LOCALIZATION_ZH = ROOT / "data/localization/zh_CN.json"
LOCALIZATION_EN = ROOT / "data/localization/en.json"

EVENT_ID = "manami_lv2_dinner_with_hiroko"
PREFIX = "mlv2"

SPEAKERS = {
    "坂口隆司": ("player", "Ryuji Sakaguchi"),
    "飯村真奈美": ("pharmacist_manami", "Manami Iimura"),
    "杉村弘子": ("nurse_hiroko", "Hiroko Sugimura"),
    "杉村弘子＆坂口隆司": ("nurse_hiroko", "Hiroko Sugimura & Ryuji Sakaguchi"),
    "飯村真奈美＆杉村弘子": ("pharmacist_manami", "Manami Iimura & Hiroko Sugimura"),
}

SCENE_BACKGROUNDS = {
    1: "lobby",
    2: "manami_lv2_yakitori_izakaya",
    3: "manami_lv2_fruit_wine_bistro",
    4: "manami_lv2_oden_izakaya",
    5: "manami_lv2_oden_izakaya",
    6: "after_work_street_spring_night",
}

MANAMI_PORTRAITS = {
    "neutral": "assets/characters/spring_summer_casual_v1/pharmacist_manami/neutral.png",
    "smile": "assets/characters/spring_summer_casual_v1/pharmacist_manami/smile.png",
    "bright": "assets/characters/spring_summer_casual_v1/pharmacist_manami/bright.png",
    "playful": "assets/characters/spring_summer_casual_v1/pharmacist_manami/playful.png",
    "surprised": "assets/characters/spring_summer_casual_v1/pharmacist_manami/surprised.png",
    "thoughtful": "assets/characters/spring_summer_casual_v1/pharmacist_manami/thoughtful.png",
    "worried": "assets/characters/spring_summer_casual_v1/pharmacist_manami/worried.png",
}

HIROKO_PORTRAITS = {
    "calm": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/calm.png",
    "smile": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/smile.png",
    "closed_eye_smile": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/closed_eye_smile.png",
    "surprised": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/surprised.png",
    "worried": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/worried.png",
    "shy": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/casual/shy.png",
}

# Pure environment/transition beats where portraits are hidden
NO_PORTRAIT_BEATS = {
    1, 2, 3,          # Entering lobby before spotting Manami
    50, 51,           # Walking out of lobby and pushing open yakitori izakaya door
    78, 79,           # Walking through shopping alley into fruit-wine bistro
    112,              # Establishing shot of noren oden izakaya
    196, 197,         # Stepping out into the 10:30 PM night breeze
    205,              # Watching the two girls walk toward the station
}

# Beat-by-beat expression choreography:
# Beat 4..25: Manami solo in lobby (Hiroko not yet present)
# Beat 26..204 (except NO_PORTRAIT_BEATS): Both Manami and Hiroko on stage
BEAT_EXPRESSIONS: dict[int, tuple[str, str | None]] = {
    # Scene 1: Lobby - Manami waiting alone
    4: ("thoughtful", None),
    5: ("thoughtful", None),
    6: ("thoughtful", None),
    7: ("bright", None),
    8: ("bright", None),
    9: ("smile", None),
    10: ("neutral", None),
    11: ("neutral", None),
    12: ("worried", None),
    13: ("worried", None),
    14: ("worried", None),
    15: ("worried", None),
    16: ("worried", None),
    17: ("worried", None),
    18: ("thoughtful", None),
    19: ("thoughtful", None),
    20: ("thoughtful", None),
    21: ("thoughtful", None),
    22: ("smile", None),
    23: ("playful", None),
    24: ("playful", None),
    25: ("surprised", None),
    # Scene 1: Hiroko arrives out of breath
    26: ("surprised", "worried"),
    27: ("surprised", "worried"),
    28: ("smile", "surprised"),
    29: ("smile", "surprised"),
    30: ("smile", "worried"),
    31: ("smile", "worried"),
    32: ("playful", "worried"),
    33: ("playful", "worried"),
    34: ("playful", "shy"),
    35: ("playful", "shy"),
    36: ("bright", "calm"),
    37: ("bright", "smile"),
    38: ("smile", "smile"),
    39: ("smile", "closed_eye_smile"),
    40: ("playful", "calm"),
    41: ("playful", "calm"),
    42: ("smile", "calm"),
    43: ("bright", "smile"),
    44: ("bright", "smile"),
    45: ("smile", "smile"),
    46: ("smile", "smile"),
    47: ("smile", "smile"),
    48: ("smile", "smile"),
    49: ("bright", "closed_eye_smile"),
    # Scene 2: Charcoal Yakitori Izakaya
    52: ("smile", "calm"),
    53: ("bright", "smile"),
    54: ("bright", "smile"),
    55: ("bright", "closed_eye_smile"),
    56: ("smile", "calm"),
    57: ("smile", "surprised"),
    58: ("smile", "shy"),
    59: ("smile", "smile"),
    60: ("smile", "smile"),
    61: ("playful", "calm"),
    62: ("playful", "calm"),
    63: ("playful", "surprised"),
    64: ("playful", "surprised"),
    65: ("bright", "surprised"),
    66: ("smile", "closed_eye_smile"),
    67: ("surprised", "smile"),
    68: ("worried", "closed_eye_smile"),
    69: ("worried", "closed_eye_smile"),
    70: ("smile", "smile"),
    71: ("neutral", "calm"),
    72: ("bright", "calm"),
    73: ("bright", "surprised"),
    74: ("playful", "calm"),
    75: ("playful", "calm"),
    76: ("playful", "shy"),
    77: ("bright", "smile"),
    # Scene 3: Fruit-Wine Bistro
    80: ("bright", "calm"),
    81: ("bright", "smile"),
    82: ("playful", "calm"),
    83: ("playful", "calm"),
    84: ("smile", "smile"),
    85: ("smile", "closed_eye_smile"),
    86: ("playful", "smile"),
    87: ("playful", "shy"),
    88: ("smile", "shy"),
    89: ("surprised", "smile"),
    90: ("worried", "closed_eye_smile"),
    91: ("worried", "closed_eye_smile"),
    # Scene 3 Choice A
    92: ("worried", "smile"),
    93: ("worried", "smile"),
    94: ("worried", "smile"),
    95: ("worried", "smile"),
    96: ("thoughtful", "closed_eye_smile"),
    97: ("thoughtful", "closed_eye_smile"),
    # Scene 3 Choice B
    98: ("smile", "calm"),
    99: ("smile", "calm"),
    100: ("smile", "smile"),
    101: ("smile", "smile"),
    102: ("bright", "closed_eye_smile"),
    103: ("bright", "closed_eye_smile"),
    # Scene 3 Merge
    104: ("smile", "smile"),
    105: ("smile", "closed_eye_smile"),
    106: ("bright", "shy"),
    107: ("bright", "surprised"),
    108: ("playful", "shy"),
    109: ("playful", "shy"),
    110: ("bright", "shy"),
    111: ("bright", "smile"),
    # Scene 4: Noren Oden Izakaya
    113: ("neutral", "calm"),
    114: ("smile", "calm"),
    115: ("thoughtful", "calm"),
    116: ("thoughtful", "calm"),
    117: ("thoughtful", "surprised"),
    118: ("thoughtful", "calm"),
    119: ("bright", "calm"),
    120: ("bright", "smile"),
    121: ("worried", "calm"),
    122: ("worried", "calm"),
    123: ("playful", "surprised"),
    124: ("playful", "shy"),
    125: ("neutral", "calm"),
    126: ("surprised", "calm"),
    127: ("surprised", "surprised"),
    128: ("bright", "surprised"),
    129: ("surprised", "worried"),
    130: ("worried", "worried"),
    131: ("thoughtful", "worried"),
    132: ("neutral", "calm"),
    133: ("playful", "calm"),
    134: ("playful", "calm"),
    135: ("playful", "calm"),
    # Scene 4 Branch A (Hiroko Lv0-3)
    136: ("playful", "calm"),
    137: ("playful", "calm"),
    138: ("playful", "calm"),
    139: ("playful", "calm"),
    140: ("playful", "surprised"),
    141: ("playful", "shy"),
    142: ("surprised", "shy"),
    143: ("surprised", "shy"),
    144: ("bright", "shy"),
    145: ("bright", "smile"),
    146: ("playful", "smile"),
    147: ("playful", "smile"),
    148: ("bright", "closed_eye_smile"),
    149: ("bright", "closed_eye_smile"),
    # Scene 4 Branch B (Hiroko Lv4-5)
    150: ("playful", "calm"),
    151: ("playful", "surprised"),
    152: ("playful", "surprised"),
    153: ("playful", "shy"),
    154: ("neutral", "shy"),
    155: ("neutral", "shy"),
    156: ("surprised", "shy"),
    157: ("surprised", "surprised"),
    158: ("surprised", "surprised"),
    159: ("surprised", "shy"),
    160: ("surprised", "shy"),
    161: ("thoughtful", "shy"),
    162: ("thoughtful", "shy"),
    163: ("thoughtful", "surprised"),
    164: ("thoughtful", "shy"),
    165: ("playful", "worried"),
    166: ("playful", "worried"),
    167: ("surprised", "worried"),
    168: ("surprised", "worried"),
    169: ("surprised", "shy"),
    170: ("worried", "shy"),
    171: ("thoughtful", "calm"),
    172: ("thoughtful", "calm"),
    173: ("thoughtful", "shy"),
    174: ("smile", "smile"),
    175: ("smile", "smile"),
    # Scene 5: Merge & Climax
    176: ("smile", "smile"),
    177: ("smile", "smile"),
    178: ("bright", "surprised"),
    179: ("bright", "surprised"),
    # Scene 5 Lv0-3
    180: ("playful", "shy"),
    181: ("playful", "shy"),
    # Scene 5 Lv4-5
    182: ("playful", "surprised"),
    183: ("playful", "shy"),
    184: ("playful", "shy"),
    185: ("surprised", "shy"),
    186: ("playful", "calm"),
    187: ("playful", "calm"),
    # Scene 5 Final Merge
    188: ("playful", "smile"),
    189: ("bright", "smile"),
    190: ("playful", "smile"),
    191: ("playful", "smile"),
    192: ("bright", "smile"),
    193: ("bright", "closed_eye_smile"),
    194: ("bright", "closed_eye_smile"),
    195: ("smile", "closed_eye_smile"),
    # Scene 6: Epilogue Night Street
    198: ("smile", "calm"),
    199: ("bright", "smile"),
    200: ("smile", "smile"),
    201: ("smile", "smile"),
    202: ("smile", "smile"),
    203: ("playful", "smile"),
    204: ("bright", "closed_eye_smile"),
}

NEW_BACKGROUNDS = [
    {
        "id": "manami_lv2_yakitori_izakaya",
        "label": "炭火串烧居酒屋",
        "en_label": "Charcoal Yakitori Izakaya",
        "path": "assets/backgrounds/manami_lv2_v1/yakitori_izakaya.png",
    },
    {
        "id": "manami_lv2_fruit_wine_bistro",
        "label": "和风果酒小酒馆",
        "en_label": "Japanese Fruit-Wine Bistro",
        "path": "assets/backgrounds/manami_lv2_v1/fruit_wine_bistro.png",
    },
    {
        "id": "manami_lv2_oden_izakaya",
        "label": "暖帘关东煮居酒屋",
        "en_label": "Noren Oden Izakaya",
        "path": "assets/backgrounds/manami_lv2_v1/oden_izakaya.png",
    },
]

SKIP_EXACT = {
    "**【玩家可见正文】**",
    "---",
    "*(→ 分支 A 结束，直接进入【Scene 5 — 分支汇合与结尾】)*",
    "*(→ 分支 B 结束，直接进入【Scene 5 — 分支汇合与结尾】)*",
    "**【飯村真奈美 Relationship Lv2 事件结束｜结算：飯村真奈美 Relationship 等级提升至 Lv2】**",
}


def read_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def story_lines() -> list[str]:
    manuscript = SOURCE.read_text(encoding="utf-8")
    marker = "## 【第一幕：下班后等人】"
    body = marker + manuscript.split(marker, 1)[1].split("## 【Concept Lock 忠实性验收表】", 1)[0]
    return body.splitlines()


def parse_beats() -> list[dict]:
    nodes: list[dict] = []
    scene = 1
    mode = "main"
    last: dict[str, dict | None] = {
        "main": None,
        "choice_A": None,
        "choice_B": None,
        "hiroko_A": None,
        "hiroko_B": None,
        "s5_A": None,
        "s5_B": None,
    }
    choice_host: dict | None = None
    choice_labels: list[str] = []
    hiroko_branch_host: dict | None = None
    hiroko_branch_first: dict[str, str] = {}
    s5_branch_host: dict | None = None
    s5_branch_first: dict[str, str] = {}
    awaiting_choice_merge = False
    awaiting_hiroko_merge = False
    awaiting_s5_merge = False

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
        nonlocal awaiting_choice_merge, awaiting_hiroko_merge, awaiting_s5_merge
        actor_id, _ = SPEAKERS.get(speaker_name, ("pharmacist_manami", "Narrator"))
        idx = len(nodes) + 1
        node_id = f"{PREFIX}_{idx:03d}"
        background_id = SCENE_BACKGROUNDS[scene]
        speaker_kind = (
            "narrator"
            if speaker_name == "旁白"
            else ("player" if actor_id == "player" else "actor")
        )
        manami_expr, hiroko_expr = BEAT_EXPRESSIONS.get(idx, ("neutral", "calm"))
        active_actor_id = "pharmacist_manami" if speaker_kind in ("narrator", "player") else actor_id
        node_expr = hiroko_expr if (active_actor_id == "nurse_hiroko" and hiroko_expr) else manami_expr

        node: dict = {
            "id": node_id,
            "presentation": "authored",
            "speaker": speaker_kind,
            "actor_id": active_actor_id,
            "speaker_label": speaker_name,
            "text": text,
            "expression": node_expr,
            "outfit": "casual",
            "background_id": background_id,
            "hide_portrait": True,
            "choices": [],
        }
        if idx not in NO_PORTRAIT_BEATS:
            node["hide_portrait"] = False
            if hiroko_expr is None:
                node["event_portraits"] = [
                    {
                        "id": "pharmacist_manami",
                        "path": MANAMI_PORTRAITS[manami_expr],
                        "x": 1030,
                        "bottom": 540,
                        "width": 410,
                        "height": 500,
                    }
                ]
            else:
                node["event_portraits"] = [
                    {
                        "id": "pharmacist_manami",
                        "path": MANAMI_PORTRAITS[manami_expr],
                        "x": 460,
                        "bottom": 540,
                        "width": 410,
                        "height": 500,
                    },
                    {
                        "id": "nurse_hiroko",
                        "path": HIROKO_PORTRAITS[hiroko_expr],
                        "x": 970,
                        "bottom": 540,
                        "width": 410,
                        "height": 500,
                    },
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

        if mode in ("hiroko_A", "hiroko_B"):
            link(last[mode], node)
            last[mode] = node
            if mode not in hiroko_branch_first:
                hiroko_branch_first[mode] = node_id
            return

        if mode in ("s5_A", "s5_B"):
            link(last[mode], node)
            last[mode] = node
            if mode not in s5_branch_first:
                s5_branch_first[mode] = node_id
            return

        if awaiting_choice_merge:
            link(last["choice_A"], node)
            link(last["choice_B"], node)
            last["choice_A"] = last["choice_B"] = None
            awaiting_choice_merge = False
        elif awaiting_hiroko_merge:
            link(last["hiroko_A"], node)
            link(last["hiroko_B"], node)
            last["hiroko_A"] = last["hiroko_B"] = None
            awaiting_hiroko_merge = False
        elif awaiting_s5_merge:
            link(last["s5_A"], node)
            link(last["s5_B"], node)
            last["s5_A"] = last["s5_B"] = None
            awaiting_s5_merge = False
        else:
            link(last["main"], node)
        last["main"] = node

    for raw in story_lines():
        line = raw.strip()
        if not line or line in SKIP_EXACT:
            continue
        if line.startswith(">"):
            continue
        if re.fullmatch(r"## 【第[一二三四]幕：.+】", line):
            continue
        scene_match = re.fullmatch(r"### Scene (\d+) — .+?", line)
        if scene_match:
            scene_num = int(scene_match.group(1))
            if scene_num == 5 and mode == "hiroko_B":
                if hiroko_branch_host is None or "hiroko_A" not in hiroko_branch_first or "hiroko_B" not in hiroko_branch_first:
                    raise ValueError("Incomplete Scene 4 Hiroko branch before Scene 5")
                hiroko_branch_host["choices"] = [
                    {
                        "id": "continue_" + hiroko_branch_host["id"],
                        "label": "继续",
                        "next": hiroko_branch_first["hiroko_A"],
                        "next_if_relationship_level": {
                            "actor_id": "nurse_hiroko",
                            "minimum": 4,
                            "next": hiroko_branch_first["hiroko_B"],
                        },
                        "effects": {"affection": 0, "familiarity": 0},
                        "flags": [],
                    }
                ]
                last["main"] = None
                awaiting_hiroko_merge = True
            scene = scene_num
            mode = "main"
            continue
        if line == "**【尾声：散场与夜风】**":
            scene = 6
            continue
        if line.startswith(("**【场景】**", "**【时间】**", "**【在场角色】**", "**【服装状态】**", "*性质：")):
            continue
        if line.startswith("**【选择："):
            if last["main"] is None:
                raise ValueError("Choice has no host")
            choice_host = last["main"]
            last["main"] = None
            choice_labels = []
            mode = "choice"
            continue
        option_match = re.fullmatch(r"- \*\*选项 [AB]：(「.*」)\*\*", line)
        if option_match:
            choice_labels.append(option_match.group(1))
            if len(choice_labels) == 2 and choice_host is not None:
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
        if line == "**【选项 A 回应】**":
            mode, last["choice_A"] = "choice_A", None
            continue
        if line == "**【选项 B 回应】**":
            mode, last["choice_B"] = "choice_B", None
            continue
        if line == "**【主线汇合】**":
            mode, awaiting_choice_merge = "main", True
            continue
        if line.startswith("## 【关键分支："):
            hiroko_branch_host = last["main"]
            if hiroko_branch_host is None:
                raise ValueError("Scene 4 Hiroko branch has no host")
            continue
        if line.startswith("### 【分支 A："):
            mode, last["hiroko_A"] = "hiroko_A", None
            continue
        if line.startswith("### 【分支 B："):
            mode, last["hiroko_B"] = "hiroko_B", None
            continue
        if line.startswith("**【条件差分演出："):
            s5_branch_host = last["main"]
            if s5_branch_host is None:
                raise ValueError("Scene 5 conditional branch has no host")
            continue
        if line.startswith("- **【当杉村弘子为 Lv0–3"):
            mode, last["s5_A"] = "s5_A", None
            continue
        if line.startswith("- **【当杉村弘子为 Lv4–5"):
            mode, last["s5_B"] = "s5_B", None
            continue
        if line == "**【主线最终汇合】**":
            if s5_branch_host is None or "s5_A" not in s5_branch_first or "s5_B" not in s5_branch_first:
                raise ValueError("Incomplete Scene 5 conditional branch")
            s5_branch_host["choices"] = [
                {
                    "id": "continue_" + s5_branch_host["id"],
                    "label": "继续",
                    "next": s5_branch_first["s5_A"],
                    "next_if_relationship_level": {
                        "actor_id": "nurse_hiroko",
                        "minimum": 4,
                        "next": s5_branch_first["s5_B"],
                    },
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                }
            ]
            last["main"] = None
            mode = "main"
            awaiting_s5_merge = True
            continue

        exact = re.fullmatch(r"([^：]+)：(「.*」)", line)
        if exact and exact.group(1) in SPEAKERS:
            append(exact.group(1), exact.group(2))
            continue
        if exact:
            # Match longest speaker prefix first so dual speakers never mis-match
            inline_speaker = next(
                (name for name in sorted(SPEAKERS, key=len, reverse=True) if exact.group(1).startswith(name)),
                "",
            )
            if inline_speaker:
                append("旁白", exact.group(1) + "：")
                append(inline_speaker, exact.group(2))
                continue
        append("旁白", line)

    if (
        awaiting_choice_merge
        or awaiting_hiroko_merge
        or awaiting_s5_merge
        or any(last[k] is not None for k in ("choice_A", "choice_B", "hiroko_A", "hiroko_B", "s5_A", "s5_B"))
    ):
        raise ValueError("Unclosed branch in Manami Lv2 parser")
    if sum(1 for node in nodes if len(node["choices"]) == 2) != 1:
        raise ValueError("Expected exactly 1 two-option choice node in Manami Lv2")

    nodes[-1]["choices"] = [
        {
            "id": "finish_" + nodes[-1]["id"],
            "label": "结束",
            "next": "@end",
            "effects": {"affection": 0, "familiarity": 0},
            "flags": [],
        }
    ]
    return nodes


def register_backgrounds() -> None:
    bg_list: list[dict] = read_json(BACKGROUNDS)  # type: ignore[assignment]
    existing_ids = {entry.get("id") for entry in bg_list}
    for bg in NEW_BACKGROUNDS:
        if bg["id"] not in existing_ids:
            bg_list.append(
                {
                    "id": bg["id"],
                    "label": bg["label"],
                    "path": bg["path"],
                }
            )
    write_json(BACKGROUNDS, bg_list)


def main() -> None:
    beats = parse_beats()
    if not TRANSLATIONS.exists():
        template: dict[str, str] = {}
        for beat in beats:
            template[beat["id"]] = ""
            if len(beat["choices"]) == 2:
                for choice in beat["choices"]:
                    template[choice["id"]] = ""
        write_json(TRANSLATIONS, template)
        print(f"Wrote translation template with {len(beats)} beats to {TRANSLATIONS}")
        return

    translations: dict[str, str] = read_json(TRANSLATIONS)  # type: ignore[assignment]
    event = {
        "id": EVENT_ID,
        "actor_id": "pharmacist_manami",
        "title": "和弘子一起吃饭",
        "teaser": "傍晚的大厅里，真奈美正百无聊赖地等着弘子下班。",
        "chapter": 2,
        "location_id": "lobby",
        "trigger_mode": "after_work",
        "background_id": "lobby",
        "outfit": "casual",
        "minutes": 180,
        "time_start": 1020,
        "time_end": 1320,
        "priority": 115,
        "category": "rank_up",
        "target_level": 2,
        "benefit_id": "",
        "auto_start": True,
        "cinematic": True,
        "locks_saving": True,
        "hide_calendar_header": True,
        "hide_completion_portrait": True,
        "gallery": {
            "cg_id": EVENT_ID,
            "caption": "和弘子一起吃饭",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 25,
            "required_events": ["manami_lv1_sneeze"],
            "days_after_required_events": 3,
            "special_requirements": [
                {
                    "type": "staff_unlocked",
                    "actor_id": "nurse_hiroko",
                }
            ],
        },
        "start": beats[0]["id"],
        "nodes": beats,
    }
    write_json(OUTPUT, [event])

    bundle_doc: dict = read_json(BUNDLE)  # type: ignore[assignment]
    extra_files: list[str] = list(bundle_doc.get("additional_character_event_files", []))
    if "lv2_events.json" not in extra_files:
        extra_files.append("lv2_events.json")
    bundle_doc["additional_character_event_files"] = extra_files
    write_json(BUNDLE, bundle_doc)

    relation_doc: dict = read_json(RELATIONSHIP)  # type: ignore[assignment]
    for slot in relation_doc.get("rank_slots", []):
        if int(slot.get("target_level", 0)) == 2:
            slot["event_id"] = EVENT_ID
            slot["content_status"] = "authored"
            slot["special_requirements"] = [
                {
                    "type": "staff_unlocked",
                    "actor_id": "nurse_hiroko",
                }
            ]
    write_json(RELATIONSHIP, relation_doc)

    register_backgrounds()

    for locale, loc_path in [("zh_CN", LOCALIZATION_ZH), ("en", LOCALIZATION_EN)]:
        loc_doc: dict = read_json(loc_path)  # type: ignore[assignment]
        strings: dict[str, str] = loc_doc["strings"]
        for bg in NEW_BACKGROUNDS:
            bg_key = f"collections.backgrounds.{bg['id']}.label"
            strings[bg_key] = bg["en_label"] if locale == "en" else bg["label"]

        prefix = f"collections.character_events.{EVENT_ID}"
        for key in list(strings):
            if key.startswith(prefix + "."):
                del strings[key]

        if locale == "en":
            strings[prefix + ".title"] = "Dinner with Hiroko"
            strings[prefix + ".teaser"] = "In the evening lobby, Manami is waiting around for Hiroko to get off work."
            strings[prefix + ".gallery.caption"] = "Dinner with Hiroko"
        else:
            strings[prefix + ".title"] = event["title"]
            strings[prefix + ".teaser"] = event["teaser"]
            strings[prefix + ".gallery.caption"] = event["gallery"]["caption"]

        for beat in beats:
            stem = f"{prefix}.nodes.{beat['id']}"
            if locale == "en":
                english = str(translations.get(beat["id"], "")).strip()
                if not english:
                    raise ValueError(f"Missing English translation for {beat['id']}: {beat['text']}")
                strings[stem + ".text"] = english
                strings[stem + ".speaker_label"] = (
                    "Narrator" if beat["speaker_label"] == "旁白" else SPEAKERS[beat["speaker_label"]][1]
                )
            else:
                strings[stem + ".text"] = beat["text"]
                strings[stem + ".speaker_label"] = beat["speaker_label"]

            for choice in beat["choices"]:
                ckey = f"{stem}.choices.{choice['id']}.label"
                if len(beat["choices"]) == 2:
                    if locale == "en":
                        c_en = str(translations.get(choice["id"], "")).strip()
                        if not c_en:
                            raise ValueError(f"Missing English choice translation for {choice['id']}")
                        strings[ckey] = c_en
                    else:
                        strings[ckey] = choice["label"]
                else:
                    if locale == "en":
                        strings[ckey] = "Finish" if choice["next"] == "@end" else "Continue"
                    else:
                        strings[ckey] = choice["label"]

        write_json(loc_path, loc_doc)

    print(f"Imported {EVENT_ID}: {len(beats)} bilingual beats")


if __name__ == "__main__":
    main()
