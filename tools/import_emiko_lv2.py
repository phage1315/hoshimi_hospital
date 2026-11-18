#!/usr/bin/env python3
"""Import Emiko Mido (`doc_emiko`) Relationship Lv2 milestone event:
《这一次听你的》 (This Time, I'll Follow Your Lead, ID: `emiko_lv2_follow_my_lead`, V2.1).

Updates:
- data/staff/doc_emiko/events.json (replaces `emiko_lv2_follow_my_lead` only; leaves Lv0 refusal, Lv0 V1.2, and Lv1 V2.2 untouched)
- data/localization/zh_CN.json & data/localization/en.json (purges legacy 14-node keys and writes V2.1 bilingual keys)
- research/imports/emiko_lv2_2026-11-14.json
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_MIDO_EMIKO_LV2_FOLLOW_MY_LEAD_V2_1.md"
EN_TRANSLATION_PATH = ROOT / "research/translations/emiko_lv2_en.json"
EVENTS_PATH = ROOT / "data/staff/doc_emiko/events.json"
ZH_LOCALE_PATH = ROOT / "data/localization/zh_CN.json"
EN_LOCALE_PATH = ROOT / "data/localization/en.json"
MANIFEST_PATH = ROOT / "research/imports/emiko_lv2_2026-11-14.json"

EVENT_ID = "emiko_lv2_follow_my_lead"

CAST_PORTRAITS = {
    ("doc_emiko", "sterile/neutral"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/neutral.png",
    ("doc_emiko", "sterile/focused"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/focused.png",
    ("doc_emiko", "sterile/worried"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/worried.png",
    ("doc_emiko", "sterile/warm"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/warm.png",
    ("doc_emiko", "white_coat/neutral"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/neutral.png",
    ("doc_emiko", "white_coat/serious"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/serious.png",
    ("nurse_hiroko", "sterile/neutral"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/neutral.png",
    ("nurse_hiroko", "sterile/focused"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/focused.png",
    ("nurse_hiroko", "sterile/warm"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/warm.png",
    ("nurse_moe", "scrubs/neutral"): "assets/characters/moe_circulating_v1/neutral.png",
}

SPEAKER_MAP = {
    "旁白": ("narrator", "doc_emiko", "旁白"),
    "御堂江美子": ("actor", "doc_emiko", "御堂江美子"),
    "坂口隆司": ("player", "doc_emiko", "坂口隆司"),
    "杉村弘子": ("actor", "nurse_hiroko", "杉村弘子"),
    "本庄萌恵": ("actor", "nurse_moe", "本庄萌恵"),
    "患者": ("actor", "doc_emiko", "患者"),
}

MIXED_PREFIX_SPEAKERS = [
    ("杉村弘子", "杉村弘子"),
    ("坂口隆司", "坂口隆司"),
    ("御堂江美子", "御堂江美子"),
    ("本庄萌恵", "本庄萌恵"),
    ("布帘后的女患者", "患者"),
    ("平车推经台旁时，女患者", "患者"),
]


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def solo(actor_id: str, key: str) -> list[dict]:
    return [
        {
            "id": actor_id,
            "path": CAST_PORTRAITS[(actor_id, key)],
            "x": 985,
            "bottom": 556,
            "width": 320,
            "height": 480,
        }
    ]


def duo(left_actor: str, left_key: str, right_actor: str, right_key: str) -> list[dict]:
    return [
        {
            "id": left_actor,
            "path": CAST_PORTRAITS[(left_actor, left_key)],
            "x": 805,
            "bottom": 556,
            "width": 300,
            "height": 450,
        },
        {
            "id": right_actor,
            "path": CAST_PORTRAITS[(right_actor, right_key)],
            "x": 1085,
            "bottom": 556,
            "width": 300,
            "height": 450,
        },
    ]


def stage_for_beat(num: int) -> tuple[str, str, str, list[dict] | None]:
    """Return (background_id, outfit, expression, event_portraits_or_None)."""
    # Scene A: Swapped Roster Positions & Pre-incision Time-out (em2_001..em2_028)
    if num in (1, 2):
        return ("operating_room", "sterile", "neutral", None)
    if num == 3:
        return ("operating_room", "sterile", "neutral", solo("nurse_hiroko", "sterile/neutral"))
    if num == 4:
        return ("operating_room", "sterile", "neutral", duo("nurse_hiroko", "sterile/warm", "nurse_moe", "scrubs/neutral"))
    if 5 <= num <= 17:
        expr = "focused" if num in (10, 12, 14, 15, 16, 17) else "neutral"
        return ("operating_room", "sterile", expr, solo("doc_emiko", f"sterile/{expr}"))
    if num == 18:
        return ("operating_room", "sterile", "neutral", duo("nurse_hiroko", "sterile/warm", "doc_emiko", "sterile/focused"))
    if num in (19, 20):
        return ("operating_room", "sterile", "neutral", solo("nurse_moe", "scrubs/neutral"))
    if 21 <= num <= 25:
        return ("operating_room", "sterile", "neutral", duo("nurse_moe", "scrubs/neutral", "doc_emiko", "sterile/neutral"))
    if 26 <= num <= 28:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))

    # Scene B: Faster Hands & Choice 1 (em2_029..em2_065)
    if num in (29, 30):
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num == 31:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    if 32 <= num <= 38:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num == 39:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    # B1-A (40..46)
    if num in (40, 41):
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num in (42, 43):
        return ("operating_room", "sterile", "worried", solo("doc_emiko", "sterile/worried"))
    if num in (44, 45):
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num == 46:
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    # B1-B (47..54)
    if 47 <= num <= 52:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num in (53, 54):
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    # B1-C (55..61)
    if 55 <= num <= 59:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num in (60, 61):
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    # Rejoin B1 (62..65)
    if 62 <= num <= 65:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))

    # Scene C: Mesenteric Division & Bowel Resection (em2_066..em2_086)
    if num == 66:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 67 <= num <= 72:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    if 73 <= num <= 77:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 78 <= num <= 81:
        return ("operating_room", "sterile", "neutral", duo("nurse_hiroko", "sterile/neutral", "doc_emiko", "sterile/focused"))
    if num in (82, 83):
        return ("operating_room", "sterile", "warm", duo("nurse_hiroko", "sterile/warm", "doc_emiko", "sterile/neutral"))
    if 84 <= num <= 86:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))

    # Scene D: Pre-anastomotic Verification Divergence, Choice 2 & Hand-sewn Anastomosis (em2_087..em2_153)
    if 87 <= num <= 92:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num == 93:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    if 94 <= num <= 97:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 98 <= num <= 101:
        return ("operating_room", "sterile", "worried", solo("doc_emiko", "sterile/worried"))
    # D2-A (102..108)
    if 102 <= num <= 106:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num in (107, 108):
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    # D2-B (109..119)
    if num in (109, 110):
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 111 <= num <= 112:
        return ("operating_room", "sterile", "worried", solo("doc_emiko", "sterile/worried"))
    if 113 <= num <= 117:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num in (118, 119):
        return ("operating_room", "sterile", "warm", solo("doc_emiko", "sterile/warm"))
    # D2-C (120..131)
    if num in (120, 121):
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    if num in (122, 123):
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/neutral"))
    if 124 <= num <= 129:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num in (130, 131):
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    # Rejoin D2 (132..153)
    if 132 <= num <= 141:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 142 <= num <= 145:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    if 146 <= num <= 150:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 151 <= num <= 153:
        return ("operating_room", "sterile", "warm", solo("doc_emiko", "sterile/warm"))

    # Scene E: Witness Behind the Drape (em2_154..em2_182)
    if num == 154:
        return ("operating_room", "sterile", "neutral", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/neutral"))
    if 155 <= num <= 161:
        return ("operating_room", "sterile", "neutral", solo("nurse_moe", "scrubs/neutral"))
    if 162 <= num <= 170:
        return ("operating_room", "sterile", "neutral", duo("nurse_moe", "scrubs/neutral", "doc_emiko", "sterile/neutral"))
    if num in (171, 172):
        return ("operating_room", "sterile", "neutral", solo("nurse_moe", "scrubs/neutral"))
    if num in (173, 174):
        return ("operating_room", "sterile", "warm", duo("nurse_hiroko", "sterile/warm", "doc_emiko", "sterile/neutral"))
    if num in (175, 176):
        return ("operating_room", "sterile", "warm", duo("nurse_moe", "scrubs/neutral", "doc_emiko", "sterile/warm"))
    if 177 <= num <= 182:
        expr = "warm" if num in (180, 181) else "neutral"
        return ("operating_room", "sterile", expr, solo("doc_emiko", f"sterile/{expr}"))

    # Scene F: Eighty-Eight Points & Choice 3 (em2_183..em2_233)
    if num in (183, 184):
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num in (185, 186):
        return ("operating_room", "sterile", "neutral", duo("nurse_hiroko", "sterile/focused", "nurse_moe", "scrubs/neutral"))
    if num == 187:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 188 <= num <= 190:
        return ("operating_room", "sterile", "neutral", duo("nurse_hiroko", "sterile/focused", "nurse_moe", "scrubs/neutral"))
    if 191 <= num <= 195:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 196 <= num <= 201:
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    if 202 <= num <= 204:
        return ("operating_room", "sterile", "warm", solo("doc_emiko", "sterile/warm"))
    # F3-A (205..211)
    if 205 <= num <= 211:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    # F3-B (212..217)
    if 212 <= num <= 215:
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    if num in (216, 217):
        return ("operating_room", "sterile", "warm", solo("doc_emiko", "sterile/warm"))
    # F3-C (218..225)
    if 218 <= num <= 224:
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    if num == 225:
        return ("operating_room", "sterile", "warm", solo("doc_emiko", "sterile/warm"))
    # Rejoin F3: Doffing sterile gowns, gurney transfer & exiting OR (226..233)
    # Per Section 3 Codex note: transition after removing outer sterile gowns (while caps/masks remain on) uses narration/circulating nurse without unmasked scrubs portrait.
    if num == 226:
        return ("operating_room", "sterile", "neutral", None)
    if 227 <= num <= 230:
        return ("operating_room", "sterile", "neutral", solo("nurse_moe", "scrubs/neutral"))
    if 231 <= num <= 233:
        return ("operating_room", "sterile", "neutral", None)

    # Scene G: Outside the 4F Surgical Suite Corridor in Everyday White Coats (em2_234..em2_254)
    # Strictly composed/matter-of-fact (white_coat/neutral & serious; zero post-op excitement expressions per prohibition).
    if num == 234:
        return ("or_entrance", "white_coat", "neutral", None)
    if 235 <= num <= 237:
        return ("or_entrance", "white_coat", "neutral", solo("doc_emiko", "white_coat/neutral"))
    if num == 238:
        return ("or_entrance", "white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
    if 239 <= num <= 246:
        return ("or_entrance", "white_coat", "neutral", solo("doc_emiko", "white_coat/neutral"))
    if 247 <= num <= 251:
        return ("or_entrance", "white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
    if 252 <= num <= 254:
        return ("or_entrance", "white_coat", "neutral", None)

    raise ValueError(f"Unhandled beat {num}")


def parse_manuscript() -> tuple[list[tuple], dict[str, str]]:
    """Return (beats, choice_labels_zh)."""
    md = MANUSCRIPT_PATH.read_text(encoding="utf-8")
    sec2 = md.split("## 二、 完整中文 VN 剧本正文", 1)[1].split("**【御堂江美子 Relationship Lv2 事件结束】**", 1)[0]

    scene = ""
    section = "main"
    in_meta = False
    cur_choice = ""
    beats: list[tuple] = []
    choice_labels_zh: dict[str, str] = {}

    def add_beat(spk_name: str, text: str) -> None:
        role, aid, slabel = SPEAKER_MAP[spk_name]
        num = len(beats) + 1
        beats.append((num, f"em2_{num:03d}", scene, section, role, aid, slabel, text))

    for raw in sec2.splitlines():
        s = raw.strip()
        if s.startswith("### 【Scene "):
            scene = s.split("Scene ")[1][0]
            section = "main"
            in_meta = True
            continue
        if in_meta:
            if s == "**【玩家可见正文】**":
                in_meta = False
            continue
        if not s or s == "---" or s.startswith("*性质："):
            continue
        m_ch = re.match(r"^\*\*【选择 (\d+)：.+】\*\*$", s)
        if m_ch:
            cur_choice = {"1": "b1", "2": "d2", "3": "f3"}[m_ch.group(1)]
            section = f"choice_{cur_choice}"
            continue
        m_opt = re.match(r"^- \*\*选项 ([ABC])：(.+)\*\*$", s)
        if m_opt:
            cid = f"choice_em2_{cur_choice}_{m_opt.group(1).lower()}"
            choice_labels_zh[cid] = m_opt.group(2)
            continue
        m_br = re.match(r"^#### 【分支 ([ABC]) — .+】$", s)
        if m_br:
            section = f"{cur_choice}_{m_br.group(1).lower()}"
            continue
        if s.startswith("> **【主线汇合"):
            section = f"rejoin_{cur_choice}"
            continue

        m_pure = re.match(r"^(御堂江美子|坂口隆司|杉村弘子|本庄萌恵|患者)：(「.+」)$", s)
        if m_pure:
            add_beat(m_pure.group(1), m_pure.group(2))
            continue

        if "：「" in s:
            act, quote = s.split("：", 1)
            spk = None
            for prefix, target in MIXED_PREFIX_SPEAKERS:
                if act.startswith(prefix):
                    spk = target
                    break
            if spk is None:
                raise ValueError(f"Unmapped mixed action+dialogue line: {s!r}")
            add_beat("旁白", act + "：")
            add_beat(spk, quote)
            continue

        add_beat("旁白", s)

    return beats, choice_labels_zh


def build_nodes(beats: list[tuple], choice_labels_zh: dict[str, str]) -> list[dict]:
    if len(beats) != 254:
        raise ValueError(f"Expected 254 beats, got {len(beats)}")

    next_override = {
        39: "em2_choice_b1",
        46: "em2_062",
        54: "em2_062",
        61: "em2_062",
        101: "em2_choice_d2",
        108: "em2_132",
        119: "em2_132",
        131: "em2_132",
        204: "em2_choice_f3",
        211: "em2_226",
        217: "em2_226",
        225: "em2_226",
        254: "@end",
    }

    choice_nodes = {
        39: {
            "id": "em2_choice_b1",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": "doc_emiko",
            "text": "",
            "expression": "focused",
            "outfit": "sterile",
            "background_id": "operating_room",
            "event_portraits": duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"),
            "choices": [
                {
                    "id": "choice_em2_b1_a",
                    "label": choice_labels_zh["choice_em2_b1_a"],
                    "next": "em2_040",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em2_b1_b",
                    "label": choice_labels_zh["choice_em2_b1_b"],
                    "next": "em2_047",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em2_b1_c",
                    "label": choice_labels_zh["choice_em2_b1_c"],
                    "next": "em2_055",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        101: {
            "id": "em2_choice_d2",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": "doc_emiko",
            "text": "",
            "expression": "worried",
            "outfit": "sterile",
            "background_id": "operating_room",
            "event_portraits": solo("doc_emiko", "sterile/worried"),
            "choices": [
                {
                    "id": "choice_em2_d2_a",
                    "label": choice_labels_zh["choice_em2_d2_a"],
                    "next": "em2_102",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em2_d2_b",
                    "label": choice_labels_zh["choice_em2_d2_b"],
                    "next": "em2_109",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em2_d2_c",
                    "label": choice_labels_zh["choice_em2_d2_c"],
                    "next": "em2_120",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        204: {
            "id": "em2_choice_f3",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": "doc_emiko",
            "text": "",
            "expression": "warm",
            "outfit": "sterile",
            "background_id": "operating_room",
            "event_portraits": solo("doc_emiko", "sterile/warm"),
            "choices": [
                {
                    "id": "choice_em2_f3_a",
                    "label": choice_labels_zh["choice_em2_f3_a"],
                    "next": "em2_205",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em2_f3_b",
                    "label": choice_labels_zh["choice_em2_f3_b"],
                    "next": "em2_212",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em2_f3_c",
                    "label": choice_labels_zh["choice_em2_f3_c"],
                    "next": "em2_218",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
    }

    nodes: list[dict] = []
    for num, nid, _scene, _sec, role, aid, slabel, text in beats:
        bg_id, outfit, expr, portraits = stage_for_beat(num)
        nxt = next_override.get(num, f"em2_{num + 1:03d}")
        end_flags = ["emiko_lv2_complete", "emiko_reliable_surgical_partner"] if nxt == "@end" else []
        node: dict = {
            "id": nid,
            "presentation": "authored",
            "speaker": role,
            "speaker_label": slabel,
            "actor_id": aid,
            "text": text,
            "expression": expr,
            "outfit": outfit,
            "background_id": bg_id,
        }
        if portraits is None:
            node["hide_portrait"] = True
        else:
            node["event_portraits"] = portraits
        node["choices"] = [
            {
                "id": f"continue_{nid}",
                "label": "继续",
                "next": nxt,
                "effects": {"affection": 0, "familiarity": 0},
                "flags": end_flags,
            }
        ]
        nodes.append(node)
        if num in choice_nodes:
            nodes.append(choice_nodes[num])

    return nodes


def build_event(nodes: list[dict]) -> dict:
    return {
        "id": EVENT_ID,
        "actor_id": "doc_emiko",
        "title": "这一次听你的",
        "chapter": 2,
        "location_id": "or",
        "trigger_mode": "location",
        "background_id": "operating_room",
        "outfit": "white_coat",
        "minutes": 100,
        "teaser": "这一次，排班表上的主刀是坂口，第一助手是御堂。",
        "time_start": 540,
        "time_end": 1019,
        "priority": 180,
        "category": "rank_up",
        "gallery": {
            "cg_id": "cg_emiko_lv2_follow_my_lead",
            "caption": "这一次听你的",
            "path": "",
            "show_on_complete": false_bool(),
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 0,
            "required_events": ["emiko_lv1_first_operation"],
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "skill",
                    "minimum": 80,
                }
            ],
            "days_after_required_events": 3,
        },
        "auto_start": False,
        "target_level": 2,
        "benefit_id": "unlock_emiko_surgical_team",
        "completion_familiarity_bonus": 10,
        "completion_story_flags": [
            "emiko_lv2_complete",
            "emiko_reliable_surgical_partner",
        ],
        "locks_saving": True,
        "start": "em2_001",
        "nodes": nodes,
    }


def false_bool() -> bool:
    return False


def update_locales(event: dict, en_data: dict) -> tuple[int, int]:
    prefix = f"collections.character_events.{EVENT_ID}."
    zh_doc = json.loads(ZH_LOCALE_PATH.read_text(encoding="utf-8"))
    en_doc = json.loads(EN_LOCALE_PATH.read_text(encoding="utf-8"))
    zh_strings: dict[str, str] = zh_doc["strings"]
    en_strings: dict[str, str] = en_doc["strings"]

    for d in (zh_strings, en_strings):
        stale = [k for k in d if k.startswith(prefix)]
        for k in stale:
            del d[k]

    zh_new: dict[str, str] = {
        f"{prefix}title": event["title"],
        f"{prefix}teaser": event["teaser"],
        f"{prefix}gallery.caption": event["gallery"]["caption"],
    }
    en_new: dict[str, str] = {
        f"{prefix}title": en_data["title"],
        f"{prefix}teaser": en_data["teaser"],
        f"{prefix}gallery.caption": en_data["gallery_caption"],
    }

    speakers_en = en_data["speakers"]
    choices_en = en_data["choices"]
    nodes_en = en_data["nodes"]

    for node in event["nodes"]:
        nid = node["id"]
        slabel_zh = node["speaker_label"]
        zh_new[f"{prefix}nodes.{nid}.speaker_label"] = slabel_zh
        en_new[f"{prefix}nodes.{nid}.speaker_label"] = speakers_en[slabel_zh]

        if node["text"]:
            zh_new[f"{prefix}nodes.{nid}.text"] = node["text"]
            en_new[f"{prefix}nodes.{nid}.text"] = nodes_en[nid]

        for ch in node["choices"]:
            cid = ch["id"]
            zh_new[f"{prefix}nodes.{nid}.choices.{cid}.label"] = ch["label"]
            if cid.startswith("continue_"):
                en_new[f"{prefix}nodes.{nid}.choices.{cid}.label"] = "Continue"
            else:
                en_new[f"{prefix}nodes.{nid}.choices.{cid}.label"] = choices_en[cid]

    zh_strings.update(zh_new)
    en_strings.update(en_new)
    zh_doc["strings"] = dict(sorted(zh_strings.items()))
    en_doc["strings"] = dict(sorted(en_strings.items()))

    ZH_LOCALE_PATH.write_text(json.dumps(zh_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    EN_LOCALE_PATH.write_text(json.dumps(en_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return len(zh_new), len(en_new)


def main() -> None:
    for (_actor_id, _key), rel_path in CAST_PORTRAITS.items():
        full = ROOT / rel_path
        if not full.is_file():
            raise FileNotFoundError(f"Missing portrait asset: {rel_path}")

    beats, choice_labels_zh = parse_manuscript()
    en_data = json.loads(EN_TRANSLATION_PATH.read_text(encoding="utf-8"))
    if set(en_data["nodes"].keys()) != {b[1] for b in beats}:
        missing = {b[1] for b in beats} - set(en_data["nodes"].keys())
        extra = set(en_data["nodes"].keys()) - {b[1] for b in beats}
        raise ValueError(f"EN node mismatch: missing={sorted(missing)}, extra={sorted(extra)}")
    if set(en_data["choices"].keys()) != set(choice_labels_zh.keys()):
        raise ValueError("EN choice keys mismatch")

    nodes = build_nodes(beats, choice_labels_zh)
    new_event = build_event(nodes)

    events = json.loads(EVENTS_PATH.read_text(encoding="utf-8"))
    replaced = False
    for i, ev in enumerate(events):
        if ev.get("id") == EVENT_ID:
            events[i] = new_event
            replaced = True
            break
    if not replaced:
        raise RuntimeError(f"Did not find {EVENT_ID} in {EVENTS_PATH}")
    EVENTS_PATH.write_text(json.dumps(events, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    zh_count, en_count = update_locales(new_event, en_data)

    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    manifest = {
        "event_id": EVENT_ID,
        "actor_id": "doc_emiko",
        "title_zh": new_event["title"],
        "title_en": en_data["title"],
        "version": "V2.1",
        "source_manuscript": str(MANUSCRIPT_PATH.relative_to(ROOT)),
        "source_manuscript_sha256": sha256_of(MANUSCRIPT_PATH),
        "en_translation": str(EN_TRANSLATION_PATH.relative_to(ROOT)),
        "en_translation_sha256": sha256_of(EN_TRANSLATION_PATH),
        "authored_beat_count": len(beats),
        "choice_node_count": 3,
        "total_node_count": len(nodes),
        "localization_keys_written": {"zh_CN": zh_count, "en": en_count},
        "formatting_adjustments": [
            "23 mixed action+quote lines (`叙事动作前缀：「角色台词」`) split at `：` into adjacent verbatim narrator action beat + verbatim character dialogue beat so speaker nameplate displays accurately on spoken lines without adding or deleting any text.",
            "Stripped non-diegetic `- **选项 X：...**` Markdown wrapper headers on the 9 interactive options.",
        ],
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Imported {EVENT_ID} V2.1: {len(nodes)} nodes ({len(beats)} beats + 3 choices); locales zh={zh_count}, en={en_count}.")


if __name__ == "__main__":
    main()
