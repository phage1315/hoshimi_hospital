#!/usr/bin/env python3
"""Deterministically import Miyama Kaori Lv1 V2.3 (`miyama_01_safety_pin`)."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts/HOSHIMI_KAORI_LV1_DING_V2_3.md"
TRANSLATIONS = ROOT / "research/translations/kaori_lv1_en.json"
SPECIAL_EVENTS = ROOT / "data/staff/doc_rei/special_events.json"
SPECIAL_EVENT_STEPS = ROOT / "data/staff/doc_rei/special_event_steps.json"
ASSETS_MANIFEST = ROOT / "data/staff/doc_rei/assets_manifest.json"
LOCALIZATION_ZH = ROOT / "data/localization/zh_CN.json"
LOCALIZATION_EN = ROOT / "data/localization/en.json"

EVENT_ID = "miyama_01_safety_pin"
STEP_ID = "miyama_01_safety_pin_main"
CG_OR_PALPATION = "assets/events/character_events/rei/lv1/cg_kita_or_palpation.png"
CG_SHAVING_PREP = "assets/events/character_events/rei/lv1/cg_kita_shaving_prep.png"
CG_DISINFECTION = "assets/events/character_events/rei/lv1/cg_kita_skin_disinfection.png"

ANNOUNCEMENT_ZH = (
    "深山接诊了一位捂着肚子赶排练的年轻乐队主唱。X光片上的尖锐安全别针影，把下午的急诊直接推进了手术室。"
)
ANNOUNCEMENT_EN = (
    "Miyama admits a young band vocalist clutching her stomach on the way to rehearsal. "
    "A sharp safety-pin shadow on her X-ray sends the afternoon straight into the operating room."
)

REI_PORTRAITS = {
    ("white_coat", "neutral"): "assets/characters/portrait_pack_v20/doc_rei/white_coat/neutral.png",
    ("white_coat", "smile"): "assets/characters/portrait_pack_v20/doc_rei/white_coat/smile.png",
    ("white_coat", "competitive_smile"): "assets/characters/portrait_pack_v20/doc_rei/white_coat/competitive_smile.png",
    ("white_coat", "serious"): "assets/characters/portrait_pack_v20/doc_rei/white_coat/serious.png",
    ("white_coat", "worried"): "assets/characters/portrait_pack_v20/doc_rei/white_coat/worried.png",
    ("white_coat", "surprised"): "assets/characters/portrait_pack_v20/doc_rei/white_coat/surprised.png",
    ("white_coat", "tired"): "assets/characters/portrait_pack_v20/doc_rei/white_coat/tired.png",
    ("scrubs", "neutral"): "assets/characters/portrait_pack_v2/doc_rei/scrubs/neutral.png",
    ("scrubs", "focused"): "assets/characters/portrait_pack_v5/doc_rei/scrubs/focused.png",
    ("scrubs", "worried"): "assets/characters/portrait_pack_v5/doc_rei/scrubs/worried.png",
    ("scrubs", "warm"): "assets/characters/portrait_pack_v5/doc_rei/scrubs/warm.png",
    ("sterile", "neutral"): "assets/characters/sterile_pack_v1/doc_rei/neutral.png",
    ("sterile", "focused"): "assets/characters/sterile_pack_v1/doc_rei/focused.png",
    ("sterile", "worried"): "assets/characters/sterile_pack_v1/doc_rei/worried.png",
    ("sterile", "warm"): "assets/characters/sterile_pack_v1/doc_rei/warm.png",
}

RIN_PORTRAITS = {
    ("scrubs", "neutral"): "assets/characters/portrait_pack_v3/nurse_rin/scrubs/neutral.png",
    ("scrubs", "focused"): "assets/characters/portrait_pack_v4/nurse_rin/scrubs/focused.png",
    ("scrubs", "worried"): "assets/characters/portrait_pack_v4/nurse_rin/scrubs/worried.png",
    ("scrubs", "warm"): "assets/characters/portrait_pack_v4/nurse_rin/scrubs/warm.png",
    ("sterile", "neutral"): "assets/characters/sterile_pack_v1/nurse_rin/neutral.png",
    ("sterile", "focused"): "assets/characters/sterile_pack_v1/nurse_rin/focused.png",
    ("sterile", "worried"): "assets/characters/sterile_pack_v1/nurse_rin/worried.png",
    ("sterile", "warm"): "assets/characters/sterile_pack_v1/nurse_rin/warm.png",
}

RUMI_PORTRAITS = {
    ("scrubs", "neutral"): "assets/characters/rumi_shiori_v1/nurse_iwasaki_rumi/scrubs/neutral.png",
    ("scrubs", "focused"): "assets/characters/rumi_shiori_v1/nurse_iwasaki_rumi/scrubs/focused.png",
    ("scrubs", "worried"): "assets/characters/rumi_shiori_v1/nurse_iwasaki_rumi/scrubs/worried.png",
    ("scrubs", "warm"): "assets/characters/rumi_shiori_v1/nurse_iwasaki_rumi/scrubs/warm.png",
}

ASUKA_PORTRAITS = {
    ("white_coat", "neutral"): "assets/characters/portrait_pack_v15/doc_asuka/white_coat/neutral.png",
    ("white_coat", "smile"): "assets/characters/portrait_pack_v15/doc_asuka/white_coat/neutral.png",
}

KITA_PORTRAITS = {
    ("casual", "smile"): "assets/characters/story_guest_kita_v1/casual/smile.png",
    ("casual", "shocked"): "assets/characters/story_guest_kita_v1/casual/shocked.png",
    ("ward", "pout"): "assets/characters/story_guest_kita_v1/ward/pout.png",
    ("ward", "smile"): "assets/characters/story_guest_kita_v1/ward/smile.png",
    ("operating_table", "tense"): "assets/characters/story_guest_kita_v1/operating_table/tense.png",
    ("operating_table", "panic"): "assets/characters/story_guest_kita_v1/operating_table/panic.png",
    ("intraoperative", "tense"): "assets/characters/story_guest_kita_v1/intraoperative/tense.png",
    ("intraoperative", "panic"): "assets/characters/story_guest_kita_v1/intraoperative/panic.png",
}

SPEAKER_ACTOR_MAP = {
    "旁白": ("narrator", None),
    "坂口隆司": ("player", None),
    "深山佳織": ("actor", "doc_rei"),
    "喜多郁代": ("actor", None),
    "喜多郁代（小声）": ("actor", None),
    "岩崎留美": ("actor", "nurse_iwasaki_rumi"),
    "中井美佳": ("actor", "nurse_rin"),
    "城宮明日香": ("actor", "doc_asuka"),
}

SPEAKER_EN_MAP = {
    "旁白": "Narrator",
    "坂口隆司": "Ryuji Sakaguchi",
    "深山佳織": "Kaori Miyama",
    "喜多郁代": "Ikuyo Kita",
    "喜多郁代（小声）": "Ikuyo Kita (quietly)",
    "岩崎留美": "Rumi Iwasaki",
    "中井美佳": "Mika Nakai",
    "城宮明日香": "Asuka Shiromiya",
}

NAME_SUBJECTS = [
    ("深山佳織", "深山佳織"),
    ("深山", "深山佳織"),
    ("坂口隆司", "坂口隆司"),
    ("坂口", "坂口隆司"),
    ("喜多郁代", "喜多郁代"),
    ("喜多", "喜多郁代"),
    ("岩崎留美", "岩崎留美"),
    ("留美", "岩崎留美"),
    ("中井美佳", "中井美佳"),
    ("城宮明日香", "城宮明日香"),
    ("明日香", "城宮明日香"),
]


def read_json(path: Path) -> object:
    with path.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def write_json(path: Path, data: object) -> None:
    with path.open("w", encoding="utf-8") as fh:
        json.dump(data, fh, ensure_ascii=False, indent=2)
        fh.write("\n")


def clean_markdown_emphasis(text: str) -> str:
    text = re.sub(r"\*\*(.+?)\*\*", r"\1", text)
    text = re.sub(r"\*(.+?)\*", r"\1", text)
    return text


def infer_speaker_from_prefix(prefix: str, prev_speaker: str) -> str:
    best_pos = 10**9
    best_canon = None
    for alias, canon in NAME_SUBJECTS:
        pos = prefix.find(alias)
        if pos != -1 and pos < best_pos:
            best_pos = pos
            best_canon = canon
    if best_canon is not None:
        return best_canon
    return prev_speaker if prev_speaker != "旁白" else "旁白"


def parse_beats() -> list[dict]:
    raw_lines = SOURCE.read_text(encoding="utf-8").splitlines()
    scene_num = 0
    in_visible_body = False
    branch = "main"
    in_cg = False
    last_dialogue_speaker = "旁白"
    beats: list[dict] = []

    known_speakers = set(SPEAKER_ACTOR_MAP.keys()) - {"旁白"}

    def push_beat(speaker_label: str, text: str) -> None:
        nonlocal last_dialogue_speaker
        cleaned = clean_markdown_emphasis(text.strip())
        if speaker_label != "旁白":
            last_dialogue_speaker = speaker_label
        beats.append(
            {
                "index": len(beats) + 1,
                "scene": scene_num,
                "branch": branch,
                "in_cg": in_cg,
                "speaker_label": speaker_label,
                "text": cleaned,
            }
        )

    for line in raw_lines:
        s = line.strip()
        if s.startswith("# 附：") or s.startswith("**【深山佳織 Relationship Lv1 事件《叮。》结束"):
            break
        if not s or s == "---":
            continue

        m_scene = re.match(r"^## 【Scene 0(\d)", s)
        if m_scene:
            scene_num = int(m_scene.group(1))
            in_visible_body = False
            branch = "main"
            in_cg = False
            continue

        if s == "**【玩家可见正文】**":
            in_visible_body = True
            continue
        if not in_visible_body:
            continue

        if s.startswith("**【触发专属 CG："):
            in_cg = True
            continue
        if s.startswith("**【固定剧情引导演出：") or re.match(r"^\*\*第[一二三]轮：.+\*\*$", s):
            continue

        if s.startswith("**【选择："):
            branch = "choice_meta"
            continue
        if branch == "choice_meta" and (s.startswith("*性质：") or s.startswith("- **选项")):
            continue

        if s in ("**【选项 A 分支】**", "**【选项 A 回应】**"):
            branch = "A"
            continue
        if s in ("**【选项 B 分支】**", "**【选项 B 回应】**"):
            branch = "B"
            continue
        if s == "**【选项 C 回应】**":
            branch = "C"
            continue
        if s in ("**【主线汇合】**", "**【最终汇合与结算】**"):
            branch = "main"
            continue

        # Standalone bold/plain quote line
        stripped_md = clean_markdown_emphasis(s)
        if stripped_md == "「叮。」":
            push_beat("旁白", "「叮。」")
            continue
        if stripped_md in ("「唔……！」", "「痛痛痛痛——！！」"):
            push_beat("喜多郁代", stripped_md)
            continue

        # Direct speaker line: 角色名：「...」
        m_direct = re.match(r"^([^：「]+?)：(「.+」)$", s)
        if m_direct and m_direct.group(1).strip() in known_speakers:
            push_beat(m_direct.group(1).strip(), m_direct.group(2).strip())
            continue

        # Mixed action + dialogue on one line: prefix：「...」
        m_mixed = re.match(r"^(.+?：)(「.+」)$", s)
        if m_mixed:
            prefix = m_mixed.group(1).strip()
            quote = m_mixed.group(2).strip()
            inferred = infer_speaker_from_prefix(prefix, last_dialogue_speaker)
            push_beat("旁白", prefix)
            push_beat(inferred, quote)
            continue

        push_beat("旁白", s)

    if len(beats) != 308:
        raise RuntimeError(f"Expected 308 beats from V2.3 manuscript, got {len(beats)}")
    return beats


def background_for_beat(idx: int) -> str:
    if 1 <= idx <= 42:
        return "exam_room"
    if 43 <= idx <= 47:
        return "hallway"
    if 48 <= idx <= 248:
        return "operating_room"
    if 249 <= idx <= 266:
        return "ward"
    return "hallway"


def rei_state_for_beat(idx: int) -> tuple[str, str]:
    if idx <= 42:
        if idx <= 17:
            return ("white_coat", "neutral")
        if idx in (18, 19, 24, 25, 28, 29, 31, 35, 40, 41):
            return ("white_coat", "serious")
        return ("white_coat", "neutral")
    if idx <= 187:
        if idx in (79, 80, 83, 84, 86, 87, 92, 93, 96, 97, 151, 152, 153, 154):
            return ("scrubs", "worried")
        if idx in (170, 171):
            return ("scrubs", "warm")
        return ("scrubs", "focused")
    if idx <= 248:
        if idx in (235, 236, 239, 240, 243, 244, 247, 248):
            return ("sterile", "warm")
        return ("sterile", "focused")
    # Post-op ward & evening hallway (249..308)
    if idx in (257, 258):
        return ("white_coat", "serious")
    if idx in (277, 278):
        return ("white_coat", "tired")
    if idx == 300:
        return ("white_coat", "surprised")
    if idx in (265, 266, 280, 292, 293, 296, 297, 304, 305, 306, 307):
        return ("white_coat", "smile")
    return ("white_coat", "neutral")


def kita_state_for_beat(idx: int) -> tuple[str, str]:
    if idx <= 15:
        return ("casual", "smile")
    if idx <= 42:
        return ("casual", "shocked")
    if idx <= 58:
        return ("ward", "pout")
    if idx <= 201:
        if idx in (
            80, 81, 82, 85, 88, 94, 95, 102, 103, 104, 105, 106, 108, 109,
            114, 115, 122, 123, 137, 138, 140, 141, 142, 143, 144, 145, 146,
            147, 148, 152, 172, 173, 176, 177, 178, 179, 180, 186, 187,
        ):
            return ("operating_table", "panic")
        return ("operating_table", "tense")
    if idx <= 248:
        if idx in (211, 212, 241, 242, 245, 246):
            return ("intraoperative", "panic")
        return ("intraoperative", "tense")
    if idx in (265, 266):
        return ("ward", "smile")
    return ("ward", "pout")


def rumi_state_for_beat(idx: int) -> tuple[str, str]:
    if idx in (43, 44, 45, 50, 51, 54, 55, 58):
        return ("scrubs", "warm")
    if idx in (65, 66, 140, 141, 148, 155, 156, 172, 173):
        return ("scrubs", "worried")
    return ("scrubs", "neutral")


def rin_state_for_beat(idx: int) -> tuple[str, str]:
    if idx <= 187:
        if idx in (67, 68, 181, 182):
            return ("scrubs", "focused")
        return ("scrubs", "neutral")
    if idx in (236, 240, 247, 248):
        return ("sterile", "warm")
    return ("sterile", "focused")


def event_portraits_for_beat(idx: int) -> list[dict] | None:
    # Pure establishing / sound-freeze / CG / walk-away beats without standing portraits
    if idx in (1, 62, 63, 64, 249, 281, 308) or (196 <= idx <= 201):
        return None

    rei_key = rei_state_for_beat(idx)
    kita_key = kita_state_for_beat(idx)
    rumi_key = rumi_state_for_beat(idx)
    rin_key = rin_state_for_beat(idx)

    # Scene 1 opening before Miyama speaks at lightbox (2..8): Kita solo
    if 2 <= idx <= 8:
        return [
            {
                "id": "story_guest_kita",
                "path": KITA_PORTRAITS[kita_key],
                "x": 960,
                "bottom": 550,
                "width": 360,
                "height": 465,
            }
        ]

    # Scene 1 & Scene 2 exam room (9..42): Kita + Kaori
    if 9 <= idx <= 42:
        return [
            {
                "id": "story_guest_kita",
                "path": KITA_PORTRAITS[kita_key],
                "x": 545,
                "bottom": 550,
                "width": 355,
                "height": 460,
            },
            {
                "id": "doc_rei",
                "path": REI_PORTRAITS[rei_key],
                "x": 985,
                "bottom": 540,
                "width": 410,
                "height": 500,
            },
        ]

    # Scene 2 hallway gurney transfer (43..47) & Scene 3 undressing dialogue (50..58): Rumi + Kita
    if (43 <= idx <= 47) or (50 <= idx <= 58):
        return [
            {
                "id": "nurse_iwasaki_rumi",
                "path": RUMI_PORTRAITS[rumi_key],
                "x": 465,
                "bottom": 540,
                "width": 375,
                "height": 480,
            },
            {
                "id": "story_guest_kita",
                "path": KITA_PORTRAITS[kita_key],
                "x": 945,
                "bottom": 550,
                "width": 355,
                "height": 460,
            },
        ]

    # Scene 3 OR entrance check (48..49): Mika + Kaori in scrubs
    if idx in (48, 49):
        return [
            {
                "id": "nurse_rin",
                "path": RIN_PORTRAITS[("scrubs", "focused")],
                "x": 465,
                "bottom": 540,
                "width": 395,
                "height": 490,
            },
            {
                "id": "doc_rei",
                "path": REI_PORTRAITS[("scrubs", "focused")],
                "x": 975,
                "bottom": 540,
                "width": 405,
                "height": 495,
            },
        ]

    # Scene 3 climbing table & pin discovery (59..68): Rumi + Kita (OR table) + Mika
    if 59 <= idx <= 68:
        return [
            {
                "id": "nurse_iwasaki_rumi",
                "path": RUMI_PORTRAITS[rumi_key],
                "x": 320,
                "bottom": 540,
                "width": 365,
                "height": 470,
            },
            {
                "id": "story_guest_kita",
                "path": KITA_PORTRAITS[kita_key],
                "x": 665,
                "bottom": 565,
                "width": 365,
                "height": 475,
            },
            {
                "id": "nurse_rin",
                "path": RIN_PORTRAITS[rin_key],
                "x": 1020,
                "bottom": 540,
                "width": 395,
                "height": 490,
            },
        ]

    # Scene 3 pin confrontation, Scene 4 palpation, Scene 5 choice & debate (69..180): Rumi + Kita + Kaori
    if 69 <= idx <= 180:
        return [
            {
                "id": "nurse_iwasaki_rumi",
                "path": RUMI_PORTRAITS[rumi_key],
                "x": 320,
                "bottom": 540,
                "width": 365,
                "height": 470,
            },
            {
                "id": "story_guest_kita",
                "path": KITA_PORTRAITS[kita_key],
                "x": 665,
                "bottom": 565,
                "width": 365,
                "height": 475,
            },
            {
                "id": "doc_rei",
                "path": REI_PORTRAITS[rei_key],
                "x": 1020,
                "bottom": 540,
                "width": 395,
                "height": 495,
            },
        ]

    # Scene 5 OR final confirmation & pre-draping spinal pinch test (181..195): Mika + Kita + Kaori
    if 181 <= idx <= 195:
        return [
            {
                "id": "nurse_rin",
                "path": RIN_PORTRAITS[rin_key],
                "x": 320,
                "bottom": 540,
                "width": 385,
                "height": 485,
            },
            {
                "id": "story_guest_kita",
                "path": KITA_PORTRAITS[kita_key],
                "x": 665,
                "bottom": 565,
                "width": 365,
                "height": 475,
            },
            {
                "id": "doc_rei",
                "path": REI_PORTRAITS[rei_key],
                "x": 1020,
                "bottom": 540,
                "width": 395,
                "height": 495,
            },
        ]

    # Post-draping & Scene 6 awake exploratory laparotomy (202..248):
    # Alternate between Kita's head-and-collarbone portrait behind the ether screen
    # (flush on the right side of the dialogue box, clear of the Continue button)
    # and the sterile-gowned surgical team (Mika + Kaori).
    if 202 <= idx <= 248:
        if idx in (202, 207, 208, 211, 212, 220, 221, 241, 242, 245, 246):
            return [
                {
                    "id": "story_guest_kita",
                    "path": KITA_PORTRAITS[kita_key],
                    "x": 955,
                    "bottom": 540,
                    "width": 350,
                    "height": 320,
                }
            ]
        return [
            {
                "id": "nurse_rin",
                "path": RIN_PORTRAITS[rin_key],
                "x": 455,
                "bottom": 540,
                "width": 390,
                "height": 490,
            },
            {
                "id": "doc_rei",
                "path": REI_PORTRAITS[rei_key],
                "x": 975,
                "bottom": 540,
                "width": 405,
                "height": 500,
            },
        ]

    # Scene 7 ward solo opening (250)
    if idx == 250:
        return [
            {
                "id": "story_guest_kita",
                "path": KITA_PORTRAITS[kita_key],
                "x": 950,
                "bottom": 550,
                "width": 360,
                "height": 465,
            }
        ]

    # Scene 7 post-op ward rounds (251..266): Kita + Kaori
    if 251 <= idx <= 266:
        return [
            {
                "id": "story_guest_kita",
                "path": KITA_PORTRAITS[kita_key],
                "x": 545,
                "bottom": 550,
                "width": 355,
                "height": 460,
            },
            {
                "id": "doc_rei",
                "path": REI_PORTRAITS[rei_key],
                "x": 985,
                "bottom": 540,
                "width": 410,
                "height": 500,
            },
        ]

    # Scene 7 hallway vending machine with Asuka (267..280): Asuka + Kaori
    if 267 <= idx <= 280:
        return [
            {
                "id": "doc_asuka",
                "path": ASUKA_PORTRAITS[("white_coat", "smile")],
                "x": 465,
                "bottom": 540,
                "width": 380,
                "height": 485,
            },
            {
                "id": "doc_rei",
                "path": REI_PORTRAITS[rei_key],
                "x": 975,
                "bottom": 540,
                "width": 410,
                "height": 500,
            },
        ]

    # Scene 7 dusk hallway partner talk with Sakaguchi (282..307): Kaori solo
    return [
        {
            "id": "doc_rei",
            "path": REI_PORTRAITS[rei_key],
            "x": 975,
            "bottom": 540,
            "width": 410,
            "height": 500,
        }
    ]


def choices_for_beat(idx: int) -> list[dict]:
    if idx == 157:
        return [
            {
                "id": "choice_1_a",
                "label": "「别针既然找到了，手术先取消，大家收拾吧。」",
                "next": "klv1_158",
                "requirements": [],
            },
            {
                "id": "choice_1_b",
                "label": "「别针在体外，反倒没法解释她最初的腹痛了。」",
                "next": "klv1_168",
                "requirements": [],
            },
        ]
    if idx in (167, 171):
        return [
            {
                "id": f"continue_{idx:03d}",
                "label": "继续",
                "next": "klv1_172",
                "requirements": [],
            }
        ]
    if idx == 293:
        return [
            {
                "id": "choice_2_a",
                "label": "「你有充分的临床理由，我当然会认真听。」",
                "next": "klv1_294",
                "requirements": [],
            },
            {
                "id": "choice_2_b",
                "label": "「下次触诊先别按那么重，患者都被你按懵了。」",
                "next": "klv1_298",
                "requirements": [],
            },
            {
                "id": "choice_2_c",
                "label": "「至少最后确认她健健康康的，不算坏结果。」",
                "next": "klv1_302",
                "requirements": [],
            },
        ]
    if idx in (297, 301, 305):
        return [
            {
                "id": f"continue_{idx:03d}",
                "label": "继续",
                "next": "klv1_306",
                "requirements": [],
            }
        ]
    if idx == 308:
        return [
            {
                "id": "finish_lv1",
                "label": "结束今天",
                "next": "@day_end",
                "requirements": [],
            }
        ]
    return [
        {
            "id": f"continue_{idx:03d}",
            "label": "继续",
            "next": f"klv1_{idx + 1:03d}",
            "requirements": [],
        }
    ]


def build_step(beats: list[dict]) -> dict:
    nodes: list[dict] = []
    for beat in beats:
        idx = beat["index"]
        nid = f"klv1_{idx:03d}"
        spk_label = beat["speaker_label"]
        role, actor_id = SPEAKER_ACTOR_MAP[spk_label]
        rei_outfit, rei_expr = rei_state_for_beat(idx)

        node: dict = {
            "id": nid,
            "presentation": "authored",
            "speaker": role,
            "speaker_label": spk_label,
            "text": beat["text"],
            "expression": rei_expr if actor_id == "doc_rei" else "neutral",
            "background_id": background_for_beat(idx),
        }
        if actor_id is not None:
            node["actor_id"] = actor_id
            if actor_id == "doc_rei":
                node["outfit"] = rei_outfit

        if 120 <= idx <= 151:
            node["cg_path"] = CG_OR_PALPATION
            node["cg_fit"] = "cover"
            node["hide_portrait"] = True
        elif idx == 188:
            node["cg_path"] = CG_SHAVING_PREP
            node["cg_fit"] = "cover"
            node["hide_portrait"] = True
        elif 196 <= idx <= 201:
            node["cg_path"] = CG_DISINFECTION
            node["cg_fit"] = "cover"
            node["hide_portrait"] = True
        else:
            portraits = event_portraits_for_beat(idx)
            if portraits is not None:
                node["event_portraits"] = portraits
            else:
                node["hide_portrait"] = True

        node["choices"] = choices_for_beat(idx)
        nodes.append(node)

    def clock_for_beat(idx: int) -> int:
        if idx <= 31:
            return 940
        if idx <= 42:
            return 950
        if idx <= 47:
            return 958
        if idx <= 84:
            return 965
        if idx <= 154:
            return 980
        if idx <= 187:
            return 988
        if idx <= 204:
            return 995
        if idx <= 248:
            return 1010
        if idx <= 266:
            return 1110
        if idx <= 280:
            return 1135
        return 1145

    scene_schedule = {f"klv1_{i:03d}": {"clock": clock_for_beat(i)} for i in range(1, 309)}

    return {
        "id": STEP_ID,
        "title": "叮。",
        "background_id": "exam_room",
        "start": "klv1_001",
        "scene_schedule": scene_schedule,
        "nodes": nodes,
    }


def update_special_events() -> None:
    events = read_json(SPECIAL_EVENTS)
    assert isinstance(events, list)
    found = False
    for ev in events:
        if ev.get("id") == EVENT_ID:
            found = True
            ev["title"] = "叮。"
            ev["announcement"] = ANNOUNCEMENT_ZH
            ev["completion_flags"] = [
                "miyama_01_safety_pin_completed",
                "relationship_doc_rei_lv1",
                "safety_pin_patient_safe",
                "miyama_negative_exploration_memory",
            ]
    if not found:
        raise KeyError(f"Could not find {EVENT_ID} in {SPECIAL_EVENTS}")
    write_json(SPECIAL_EVENTS, events)


def update_special_event_steps(new_step: dict) -> None:
    steps = read_json(SPECIAL_EVENT_STEPS)
    assert isinstance(steps, list)
    replaced = False
    for i, step in enumerate(steps):
        if step.get("id") == STEP_ID:
            steps[i] = new_step
            replaced = True
            break
    if not replaced:
        steps.append(new_step)
    write_json(SPECIAL_EVENT_STEPS, steps)


def update_assets_manifest() -> None:
    manifest = read_json(ASSETS_MANIFEST)
    assert isinstance(manifest, dict)
    assets = manifest.setdefault("assets", [])
    entries = [
        {
            "id": "cg_doc_rei_lv1_kita_or_palpation",
            "category": "character_event_cg",
            "path": CG_OR_PALPATION,
            "status": "runtime_connected",
            "runtime_connected": True,
            "trigger": None,
            "notes": "Kaori Lv1 (miyama_01_safety_pin) Scene 04 three-round OR table abdominal palpation CG.",
        },
        {
            "id": "cg_doc_rei_lv1_kita_shaving_prep",
            "category": "character_event_cg",
            "path": CG_SHAVING_PREP,
            "status": "runtime_connected",
            "runtime_connected": True,
            "trigger": None,
            "notes": "Kaori Lv1 (miyama_01_safety_pin) Scene 05 pre-incision pubic shaving and catheterization prep CG.",
        },
        {
            "id": "cg_doc_rei_lv1_kita_skin_disinfection",
            "category": "character_event_cg",
            "path": CG_DISINFECTION,
            "status": "runtime_connected",
            "runtime_connected": True,
            "trigger": None,
            "notes": "Kaori Lv1 (miyama_01_safety_pin) Scene 05 pre-incision povidone-iodine skin disinfection CG.",
        },
    ]
    for entry in entries:
        for i, item in enumerate(assets):
            if item.get("id") == entry["id"]:
                assets[i] = entry
                break
        else:
            assets.append(entry)
    write_json(ASSETS_MANIFEST, manifest)


def update_localization(step: dict) -> None:
    zh = read_json(LOCALIZATION_ZH)
    en = read_json(LOCALIZATION_EN)
    tr = read_json(TRANSLATIONS)
    assert isinstance(zh, dict) and isinstance(en, dict) and isinstance(tr, dict)

    zh_strings = zh["strings"]
    en_strings = en["strings"]

    ev_prefix = f"collections.special_events.{EVENT_ID}"
    step_prefix = f"collections.special_event_steps.{STEP_ID}"

    for target in (zh_strings, en_strings):
        for key in [
            k
            for k in target
            if k.startswith(ev_prefix + ".") or k.startswith(step_prefix + ".")
        ]:
            del target[key]

    zh_strings[f"{ev_prefix}.title"] = "叮。"
    zh_strings[f"{ev_prefix}.announcement"] = ANNOUNCEMENT_ZH
    zh_strings[f"{ev_prefix}.gallery_entry.title"] = "叮。"
    zh_strings[f"{ev_prefix}.gallery_entry.chapters.0"] = "完整回放"
    zh_strings[f"{step_prefix}.title"] = "叮。"

    en_strings[f"{ev_prefix}.title"] = "Ding."
    en_strings[f"{ev_prefix}.announcement"] = ANNOUNCEMENT_EN
    en_strings[f"{ev_prefix}.gallery_entry.title"] = "Ding."
    en_strings[f"{ev_prefix}.gallery_entry.chapters.0"] = "Full Replay"
    en_strings[f"{step_prefix}.title"] = "Ding."

    for node in step["nodes"]:
        nid = node["id"]
        if nid not in tr:
            raise KeyError(f"Missing English translation for beat {nid}")
        n_prefix = f"{step_prefix}.nodes.{nid}"
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
            elif cid == "finish_lv1":
                en_strings[c_key] = "End the day"
            else:
                if cid not in tr:
                    raise KeyError(f"Missing English translation for choice {cid}")
                en_strings[c_key] = tr[cid]

    write_json(LOCALIZATION_ZH, zh)
    write_json(LOCALIZATION_EN, en)


def main() -> None:
    beats = parse_beats()
    step = build_step(beats)
    update_special_events()
    update_special_event_steps(step)
    update_assets_manifest()
    update_localization(step)
    print(f"Imported {EVENT_ID} ({STEP_ID}) with {len(step['nodes'])} beats.")


if __name__ == "__main__":
    main()
