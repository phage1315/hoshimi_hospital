#!/usr/bin/env python3
"""Deterministic importer for Hiroko Sugimura's canonical Relationship Lv2 event V1.2:
《难得准时下班》 (hiroko_lv2_on_time_off_work).

Preserves the supplied Chinese manuscript verbatim, splits mixed stage-direction + quote
lines into narrator + speaker beats without altering any wording or punctuation, wires
the Scene 3 RP choice, maps multi-expression scrubs & casual portraits across all 169
beats, registers the 2 dedicated backgrounds and 2 new casual expressions, and syncs
bilingual localization entries.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts/HOSHIMI_SUGIMURA_HIROKO_LV2_ON_TIME_OFF_WORK_V1_2.md"
OUTPUT = ROOT / "data/staff/nurse_hiroko/lv2_events.json"
BUNDLE = ROOT / "data/staff/nurse_hiroko/bundle.json"
PROFILE = ROOT / "data/staff/nurse_hiroko/profile.json"
RELATIONSHIP = ROOT / "data/staff/nurse_hiroko/relationship.json"
BACKGROUNDS = ROOT / "data/backgrounds.json"
TRANSLATIONS = ROOT / "research/translations/hiroko_lv2_en.json"
LOCALIZATION_ZH = ROOT / "data/localization/zh_CN.json"
LOCALIZATION_EN = ROOT / "data/localization/en.json"

EVENT_ID = "hiroko_lv2_on_time_off_work"
PREFIX = "hlv2"

SPEAKERS = {
    "坂口隆司": ("player", "Ryuji Sakaguchi"),
    "杉村弘子": ("nurse_hiroko", "Hiroko Sugimura"),
    "病房护士": ("narrator", "Ward Nurse"),
    "店主": ("narrator", "Shopkeeper"),
    "摊位店员": ("narrator", "Booth Attendant"),
}

SCENE_BACKGROUNDS = {
    1: "operating_room",
    2: "nurses_station",
    3: "hiroko_lv2_yoshoku_sweet_cafe",
    4: "hiroko_lv2_shopping_street_fukubiki",
    5: "after_work_street_spring_night",
}

HIROKO_SCRUBS_PORTRAITS = {
    "neutral": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/scrubs/neutral.png",
    "warm": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/scrubs/warm.png",
    "focused": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/scrubs/focused.png",
    "worried": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/scrubs/worried.png",
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

CG_SMILE_PATH = "assets/events/character_events/hiroko/hiroko_lv2_fukubiki_keychain_smile.png"
CG_POUT_PATH = "assets/events/character_events/hiroko/hiroko_lv2_fukubiki_keychain_pout.png"
CG_SMILE_BEATS = {131, 132, 133, 134, 135}
CG_POUT_BEATS = {136, 137, 138, 139, 140}

# Pure environment/transition beats where portraits are hidden
NO_PORTRAIT_BEATS = {
    1,              # OR overhead lighting establishing shot
    41, 42, 43,     # Changing into casual clothes and walking toward nurses' station
    70, 71, 72,     # Evening shopping street and Yoshoku dinner table food spread
    96, 97,         # Shopping street plaza Fukubiki booth and white cat cushion on top shelf
    145, 146,       # Night breeze along the walkway to the station street corner
    169,            # Watching Hiroko walk into the bright station lights
}

# Beat-by-beat expression choreography (outfit, expression)
BEAT_EXPRESSIONS: dict[int, tuple[str, str]] = {
    # Scene 1: Operating Room (scrubs)
    2: ("scrubs", "neutral"),
    3: ("scrubs", "neutral"),
    4: ("scrubs", "neutral"),
    5: ("scrubs", "neutral"),
    6: ("scrubs", "neutral"),
    7: ("scrubs", "warm"),
    8: ("scrubs", "warm"),
    9: ("scrubs", "neutral"),
    10: ("scrubs", "neutral"),
    11: ("scrubs", "neutral"),
    12: ("scrubs", "neutral"),
    13: ("scrubs", "neutral"),
    14: ("scrubs", "neutral"),
    15: ("scrubs", "warm"),
    16: ("scrubs", "warm"),
    17: ("scrubs", "neutral"),
    18: ("scrubs", "neutral"),
    19: ("scrubs", "neutral"),
    20: ("scrubs", "neutral"),
    21: ("scrubs", "neutral"),
    22: ("scrubs", "neutral"),
    23: ("scrubs", "neutral"),
    24: ("scrubs", "focused"),
    25: ("scrubs", "focused"),
    26: ("scrubs", "focused"),
    27: ("scrubs", "focused"),
    28: ("scrubs", "focused"),
    29: ("scrubs", "focused"),
    30: ("scrubs", "focused"),
    31: ("scrubs", "focused"),
    32: ("scrubs", "neutral"),
    33: ("scrubs", "neutral"),
    34: ("scrubs", "neutral"),
    35: ("scrubs", "worried"),
    36: ("scrubs", "worried"),
    37: ("scrubs", "neutral"),
    38: ("scrubs", "neutral"),
    39: ("scrubs", "warm"),
    40: ("scrubs", "warm"),
    # Scene 2: Nurses' Station (casual)
    44: ("casual", "worried"),
    45: ("casual", "worried"),
    46: ("casual", "worried"),
    47: ("casual", "surprised"),
    48: ("casual", "surprised"),
    49: ("casual", "shy"),
    50: ("casual", "shy"),
    51: ("casual", "shy"),
    52: ("casual", "shy"),
    53: ("casual", "shy"),
    54: ("casual", "playful"),
    55: ("casual", "playful"),
    56: ("casual", "smile"),
    57: ("casual", "smile"),
    58: ("casual", "smile"),
    59: ("casual", "smile"),
    60: ("casual", "shy"),
    61: ("casual", "shy"),
    62: ("casual", "calm"),
    63: ("casual", "calm"),
    64: ("casual", "smile"),
    65: ("casual", "smile"),
    66: ("casual", "smile"),
    67: ("casual", "smile"),
    68: ("casual", "closed_eye_smile"),
    69: ("casual", "closed_eye_smile"),
    # Scene 3: Yoshoku & Sweet Bistro (casual)
    73: ("casual", "closed_eye_smile"),
    74: ("casual", "closed_eye_smile"),
    75: ("casual", "smile"),
    76: ("casual", "smile"),
    77: ("casual", "smile"),
    78: ("casual", "smile"),
    79: ("casual", "calm"),
    80: ("casual", "smile"),
    81: ("casual", "calm"),
    82: ("casual", "playful"),
    83: ("casual", "playful"),
    # Scene 3 Choice A
    84: ("casual", "smile"),
    85: ("casual", "smile"),
    86: ("casual", "closed_eye_smile"),
    87: ("casual", "closed_eye_smile"),
    # Scene 3 Choice B
    88: ("casual", "smile"),
    89: ("casual", "smile"),
    90: ("casual", "playful"),
    91: ("casual", "playful"),
    # Scene 3 Merge
    92: ("casual", "smile"),
    93: ("casual", "neutral"),
    94: ("casual", "surprised"),
    95: ("casual", "smile"),
    # Scene 4: Fukubiki Lottery Booth (casual)
    98: ("casual", "surprised"),
    99: ("casual", "smile"),
    100: ("casual", "smile"),
    101: ("casual", "smile"),
    102: ("casual", "smile"),
    103: ("casual", "closed_eye_smile"),
    104: ("casual", "neutral"),
    105: ("casual", "neutral"),
    106: ("casual", "surprised"),
    107: ("casual", "surprised"),
    108: ("casual", "surprised"),
    109: ("casual", "worried"),
    110: ("casual", "worried"),
    111: ("casual", "worried"),
    112: ("casual", "surprised"),
    113: ("casual", "surprised"),
    114: ("casual", "surprised"),
    115: ("casual", "calm"),
    116: ("casual", "calm"),
    117: ("casual", "calm"),
    118: ("casual", "calm"),
    119: ("casual", "calm"),
    120: ("casual", "pout"),
    121: ("casual", "pout"),
    122: ("casual", "pout"),
    123: ("casual", "pout"),
    124: ("casual", "playful"),
    125: ("casual", "playful"),
    126: ("casual", "calm"),
    127: ("casual", "surprised"),
    128: ("casual", "surprised"),
    129: ("casual", "surprised"),
    130: ("casual", "surprised"),
    131: ("casual", "smile"),
    132: ("casual", "smile"),
    133: ("casual", "closed_eye_smile"),
    134: ("casual", "smile"),
    135: ("casual", "smile"),
    136: ("casual", "surprised"),
    137: ("casual", "pout"),
    138: ("casual", "pout"),
    139: ("casual", "pout"),
    140: ("casual", "pout"),
    141: ("casual", "shy"),
    142: ("casual", "shy"),
    143: ("casual", "smile"),
    144: ("casual", "smile"),
    # Scene 5: Station Street Corner at Night (casual)
    147: ("casual", "smile"),
    148: ("casual", "smile"),
    149: ("casual", "smile"),
    150: ("casual", "shy"),
    151: ("casual", "shy"),
    152: ("casual", "calm"),
    153: ("casual", "calm"),
    154: ("casual", "playful"),
    155: ("casual", "playful"),
    156: ("casual", "playful"),
    157: ("casual", "closed_eye_smile"),
    158: ("casual", "closed_eye_smile"),
    159: ("casual", "calm"),
    160: ("casual", "shy"),
    161: ("casual", "shy"),
    162: ("casual", "smile"),
    163: ("casual", "smile"),
    164: ("casual", "playful"),
    165: ("casual", "playful"),
    166: ("casual", "playful"),
    167: ("casual", "closed_eye_smile"),
    168: ("casual", "closed_eye_smile"),
}

NEW_BACKGROUNDS = [
    {
        "id": "hiroko_lv2_yoshoku_sweet_cafe",
        "label": "商店街·和风洋食与甘味小馆",
        "en_label": "Shopping Arcade Yoshoku & Sweet Bistro",
        "path": "assets/backgrounds/hiroko_lv2_v1/yoshoku_sweet_cafe.png",
    },
    {
        "id": "hiroko_lv2_shopping_street_fukubiki",
        "label": "商店街·福引抽奖摊位",
        "en_label": "Shopping Arcade Fukubiki Lottery Booth",
        "path": "assets/backgrounds/hiroko_lv2_v1/shopping_street_fukubiki.png",
    },
]

SKIP_EXACT = {
    "**【玩家可见正文】**",
    "---",
    "**【杉村弘子 Relationship Lv2 事件结束｜结算：杉村弘子 Relationship 等级提升至 Lv2】**",
}


def read_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def story_lines() -> list[str]:
    manuscript = SOURCE.read_text(encoding="utf-8")
    marker = "## 【第一阶段：医院里的默契（约 35%）】"
    body = marker + manuscript.split(marker, 1)[1].split("## 【Concept Lock 忠实性核对表】", 1)[0]
    return body.splitlines()


def parse_beats() -> list[dict]:
    nodes: list[dict] = []
    scene = 1
    mode = "main"
    last: dict[str, dict | None] = {
        "main": None,
        "choice_A": None,
        "choice_B": None,
    }
    choice_host: dict | None = None
    choice_labels: list[str] = []
    awaiting_choice_merge = False

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
        node_id = f"{PREFIX}_{idx:03d}"
        background_id = SCENE_BACKGROUNDS[scene]
        speaker_kind = (
            "narrator"
            if speaker_name in ("旁白", "病房护士", "店主", "摊位店员")
            else ("player" if actor_id == "player" else "actor")
        )
        outfit, expr = BEAT_EXPRESSIONS.get(idx, ("casual", "neutral"))

        node: dict = {
            "id": node_id,
            "presentation": "authored",
            "speaker": speaker_kind,
            "actor_id": "nurse_hiroko",
            "speaker_label": speaker_name,
            "text": text,
            "expression": expr if outfit == "casual" else "neutral",
            "outfit": outfit,
            "background_id": background_id,
            "hide_portrait": True,
            "choices": [],
        }
        if scene == 5:
            node["seasonal_street"] = True
        if idx in CG_SMILE_BEATS:
            node["hide_portrait"] = False
            node["cg_path"] = CG_SMILE_PATH
            node["cg_fit"] = "cover"
        elif idx in CG_POUT_BEATS:
            node["hide_portrait"] = False
            node["cg_path"] = CG_POUT_PATH
            node["cg_fit"] = "cover"
        elif idx not in NO_PORTRAIT_BEATS:
            node["hide_portrait"] = False
            portrait_path = (
                HIROKO_SCRUBS_PORTRAITS[expr]
                if outfit == "scrubs"
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

    for raw_line in story_lines():
        line = raw_line.strip()
        if not line or line in SKIP_EXACT:
            continue
        if line.startswith("## ") or line.startswith("*性质："):
            continue
        if line.startswith("### Scene "):
            scene = int(re.match(r"^### Scene (\d+)", line).group(1))
            continue
        if (
            line.startswith("**【场景】**")
            or line.startswith("**【时间】**")
            or line.startswith("**【在场角色】**")
            or line.startswith("**【服装状态】**")
        ):
            continue
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

        m_direct = re.match(r"^([^：「]+)：(「.+」)$", line)
        if m_direct and m_direct.group(1) in SPEAKERS:
            append(m_direct.group(1), m_direct.group(2))
            continue

        m_mixed = re.match(r"^(.+?)：(「.+」)$", line)
        if m_mixed:
            prefix = m_mixed.group(1)
            quote = m_mixed.group(2)
            speaker = "旁白"
            if prefix.startswith(("坂口", "他转向", "他转过头")):
                speaker = "坂口隆司"
            elif prefix.startswith(("杉村弘子", "等病房护士离开后，弘子", "她用公筷", "她不甘心地")):
                speaker = "杉村弘子"
            elif prefix.startswith("摊位店员"):
                speaker = "摊位店员"
            else:
                raise ValueError(f"Unmapped mixed speaker prefix: {prefix}")
            append("旁白", prefix + "：")
            append(speaker, quote)
            continue

        append("旁白", line)

    if not nodes:
        raise ValueError("No beats parsed from source script")

    nodes[-1]["choices"] = [
        {
            "id": "finish_hiroko_lv2",
            "label": "目送弘子走进车站",
            "next": "@end",
            "effects": {"affection": 0, "familiarity": 0},
            "flags": [
                "hiroko_lv2_complete",
                "hiroko_on_time_dinner_shared",
                "hiroko_white_cat_keychain_won",
            ],
        }
    ]
    return nodes


def build_event(nodes: list[dict]) -> dict:
    return {
        "id": EVENT_ID,
        "actor_id": "nurse_hiroko",
        "title": "难得准时下班",
        "teaser": "下午最后一台手术顺利结束，弘子在护士站前认真研究着商店街的美食地图。",
        "chapter": 2,
        "location_id": "or",
        "trigger_mode": "after_work",
        "background_id": "operating_room",
        "outfit": "casual",
        "minutes": 230,
        "time_start": 960,
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
            "caption": "难得准时下班",
            "path": CG_SMILE_PATH,
            "show_on_complete": True,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 25,
            "required_events": ["hiroko_lv1_worth_it"],
            "days_after_required_events": 3,
            "special_requirements": [],
        },
        "start": nodes[0]["id"],
        "nodes": nodes,
    }


def update_profile() -> None:
    profile = read_json(PROFILE)
    assert isinstance(profile, dict)
    portraits = profile["visuals"]["portraits"]
    for expr, path in HIROKO_CASUAL_PORTRAITS.items():
        portraits[f"casual/{expr}"] = path
    write_json(PROFILE, profile)


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
            slot["benefit_id"] = ""
            slot["special_requirements"] = []
            slot["min_familiarity"] = 25
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

    en_strings[f"{prefix}.title"] = tr["title"]
    en_strings[f"{prefix}.teaser"] = tr["teaser"]
    en_strings[f"{prefix}.gallery.caption"] = tr["title"]

    speaker_en_map = {
        "旁白": "Narrator",
        "坂口隆司": "Ryuji Sakaguchi",
        "杉村弘子": "Hiroko Sugimura",
        "病房护士": "Ward Nurse",
        "店主": "Shopkeeper",
        "摊位店员": "Booth Attendant",
    }

    node_translations: dict[str, str] = tr["nodes"]
    choice_translations: dict[str, str] = tr["choices"]

    for node in event["nodes"]:
        nid = node["id"]
        if nid not in node_translations:
            raise KeyError(f"Missing English translation for beat {nid}")
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
                    raise KeyError(f"Missing English translation for choice {cid}")
                en_strings[c_key] = choice_translations[cid]

    for nb in NEW_BACKGROUNDS:
        bg_key = f"collections.backgrounds.{nb['id']}.label"
        zh_strings[bg_key] = nb["label"]
        en_strings[bg_key] = nb["en_label"]

    write_json(LOCALIZATION_ZH, zh)
    write_json(LOCALIZATION_EN, en)


def main() -> None:
    nodes = parse_beats()
    event = build_event(nodes)
    write_json(OUTPUT, [event])
    update_profile()
    update_bundle()
    update_relationship()
    update_backgrounds()
    update_localization(event)
    print(f"Imported {EVENT_ID} with {len(nodes)} beats.")


if __name__ == "__main__":
    main()
