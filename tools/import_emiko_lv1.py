#!/usr/bin/env python3
"""Import Emiko Mido (`doc_emiko`) Relationship Lv1 milestone event:
《她的手术》 (Her Kind of Surgery, ID: `emiko_lv1_first_operation`, V2.2).

Updates:
- data/staff/doc_emiko/events.json (replaces `emiko_lv1_first_operation` only; leaves Lv0 refusal, Lv0 V1.2, and Lv2 untouched)
- data/localization/zh_CN.json & data/localization/en.json (purges legacy 14-node keys and writes V2.2 bilingual keys)
- research/imports/emiko_lv1_2026-11-14.json
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_MIDO_EMIKO_LV1_HER_SURGERY_V2_2.md"
EN_TRANSLATION_PATH = ROOT / "research/translations/emiko_lv1_en.json"
EVENTS_PATH = ROOT / "data/staff/doc_emiko/events.json"
ZH_LOCALE_PATH = ROOT / "data/localization/zh_CN.json"
EN_LOCALE_PATH = ROOT / "data/localization/en.json"
MANIFEST_PATH = ROOT / "research/imports/emiko_lv1_2026-11-14.json"

EVENT_ID = "emiko_lv1_first_operation"

CAST_PORTRAITS = {
    ("doc_emiko", "sterile/neutral"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/neutral.png",
    ("doc_emiko", "sterile/focused"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/focused.png",
    ("doc_emiko", "sterile/worried"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/worried.png",
    ("doc_emiko", "sterile/warm"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/warm.png",
    ("doc_emiko", "scrubs/neutral"): "assets/characters/portrait_pack_v14/doc_emiko/scrubs/neutral.png",
    ("doc_emiko", "scrubs/focused"): "assets/characters/portrait_pack_v14/doc_emiko/scrubs/focused.png",
    ("doc_emiko", "scrubs/warm"): "assets/characters/portrait_pack_v14/doc_emiko/scrubs/warm.png",
    ("nurse_hiroko", "sterile/neutral"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/neutral.png",
    ("nurse_hiroko", "sterile/focused"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/focused.png",
    ("nurse_hiroko", "sterile/warm"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/warm.png",
    ("nurse_moe", "scrubs/neutral"): "assets/characters/moe_circulating_v1/neutral.png",
}

SPEAKER_MAP = {
    "御堂江美子": ("actor", "doc_emiko", "御堂江美子"),
    "坂口隆司": ("player", "doc_emiko", "坂口隆司"),
    "杉村弘子": ("actor", "nurse_hiroko", "杉村弘子"),
    "本庄萌恵": ("actor", "nurse_moe", "本庄萌恵"),
    "患者": ("actor", "doc_emiko", "患者"),
}

UNBOLD_PREFIX_SPEAKER = [
    ("头侧安静了半秒，本庄萌恵", ("actor", "nurse_moe", "本庄萌恵")),
    ("话音落下的瞬间，她向器械台方向平伸出右手", ("actor", "doc_emiko", "御堂江美子")),
    ("坂口隆司手里的拉钩稳稳没动", ("player", "doc_emiko", "坂口隆司")),
    ("头侧的本庄萌恵没忍住", ("actor", "nurse_moe", "本庄萌恵")),
    ("布帘后沉默了一秒，传来患者", ("actor", "doc_emiko", "患者")),
    ("坂口隆司挑了挑眉", ("player", "doc_emiko", "坂口隆司")),
    ("坂口隆司听出了这句冷话底下的意思", ("player", "doc_emiko", "坂口隆司")),
    ("御堂没有正面接茬", ("actor", "doc_emiko", "御堂江美子")),
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
    # Scene A: Preop & Entering OR #1 (em1_001..em1_044)
    if num in (1, 2):
        return ("or_entrance", "sterile", "neutral", None)
    if num in (3, 4):
        return ("operating_room", "sterile", "focused", None)
    if num == 5:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/neutral", "doc_emiko", "sterile/focused"))
    if num in (6, 7):
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num == 8:
        return ("operating_room", "sterile", "neutral", duo("nurse_hiroko", "sterile/warm", "nurse_moe", "scrubs/neutral"))
    if 9 <= num <= 11:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num in (12, 13):
        return ("operating_room", "sterile", "neutral", solo("nurse_moe", "scrubs/neutral"))
    if 14 <= num <= 17:
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    if num in (18, 19):
        return ("operating_room", "sterile", "neutral", duo("nurse_moe", "scrubs/neutral", "doc_emiko", "sterile/neutral"))
    if 20 <= num <= 23:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 24 <= num <= 27:
        return ("operating_room", "sterile", "neutral", duo("nurse_moe", "scrubs/neutral", "doc_emiko", "sterile/neutral"))
    if 28 <= num <= 31:
        return ("operating_room", "sterile", "neutral", solo("nurse_moe", "scrubs/neutral"))
    if num == 32:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num == 33:
        return ("operating_room", "sterile", "neutral", duo("nurse_moe", "scrubs/neutral", "doc_emiko", "sterile/focused"))
    if 34 <= num <= 41:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 42 <= num <= 44:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))

    # Scene B: Mido's Tempo & Choice B1 (em1_045..em1_062)
    if 45 <= num <= 47:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num == 48:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    if 49 <= num <= 51:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    # B1-A (52..54)
    if num == 52:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    if num in (53, 54):
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    # B1-B (55..57)
    if num == 55:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    if num in (56, 57):
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    # B1-C (58..60)
    if num in (58, 59):
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num == 60:
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    # Rejoin B1 (61..62)
    if num == 61:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num == 62:
        return ("operating_room", "sterile", "warm", duo("nurse_hiroko", "sterile/warm", "doc_emiko", "sterile/focused"))

    # Scene C: Gallbladder Neck Exposure, Choice C1 & Synchrony (em1_063..em1_114)
    if 63 <= num <= 66:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 67 <= num <= 69:
        return ("operating_room", "sterile", "worried", solo("doc_emiko", "sterile/worried"))
    if 70 <= num <= 76:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    # C1-A (77..82)
    if 77 <= num <= 80:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num == 81:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    if num == 82:
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    # C1-B (83..88)
    if num in (83, 84):
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num in (85, 86):
        return ("operating_room", "sterile", "neutral", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/neutral"))
    if num == 87:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num == 88:
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    # C1-C (89..94)
    if num in (89, 90):
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num in (91, 92):
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    if num == 93:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num == 94:
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    # Rejoin C1 (95..114)
    if 95 <= num <= 100:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num in (101, 102):
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    if 103 <= num <= 107:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num == 108:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    if num == 109:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 110 <= num <= 113:
        return ("operating_room", "sterile", "warm", solo("doc_emiko", "sterile/warm"))
    if num == 114:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))

    # Scene D: Conscious Patient Interlude & "Very Much" (em1_115..em1_150)
    if 115 <= num <= 120:
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    if 121 <= num <= 123:
        return ("operating_room", "sterile", "neutral", solo("nurse_moe", "scrubs/neutral"))
    if 124 <= num <= 127:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 128 <= num <= 130:
        return ("operating_room", "sterile", "neutral", solo("nurse_moe", "scrubs/neutral"))
    if num in (131, 132):
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 133 <= num <= 135:
        return ("operating_room", "sterile", "warm", solo("doc_emiko", "sterile/warm"))
    if num == 136:
        return ("operating_room", "sterile", "neutral", duo("nurse_moe", "scrubs/neutral", "nurse_hiroko", "sterile/warm"))
    if 137 <= num <= 141:
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    if num == 142:
        return ("operating_room", "sterile", "neutral", solo("nurse_moe", "scrubs/neutral"))
    if num == 143:
        return ("operating_room", "sterile", "warm", duo("nurse_hiroko", "sterile/neutral", "doc_emiko", "sterile/warm"))
    if 144 <= num <= 146:
        return ("operating_room", "sterile", "warm", solo("doc_emiko", "sterile/warm"))
    if 147 <= num <= 150:
        return ("operating_room", "sterile", "neutral", duo("nurse_moe", "scrubs/neutral", "doc_emiko", "sterile/neutral"))

    # Scene E: Closing, Dual Counts & "85 Points" (em1_151..em1_184)
    if 151 <= num <= 154:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    # E1-A (155..157)
    if num == 155:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    if num == 156:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num == 157:
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    # E1-B (158..161)
    if 158 <= num <= 161:
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    # E1-C (162..164)
    if 162 <= num <= 164:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    # Rejoin E1 (165..184)
    if num == 165:
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
    if num in (166, 167):
        return ("operating_room", "sterile", "neutral", duo("nurse_hiroko", "sterile/focused", "nurse_moe", "scrubs/neutral"))
    if num == 168:
        return ("operating_room", "sterile", "warm", duo("nurse_hiroko", "sterile/warm", "doc_emiko", "sterile/focused"))
    if num == 169:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if num in (170, 171):
        return ("operating_room", "sterile", "neutral", duo("nurse_hiroko", "sterile/focused", "nurse_moe", "scrubs/neutral"))
    if num == 172:
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if 173 <= num <= 178:
        return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
    if 179 <= num <= 181:
        return ("operating_room", "sterile", "warm", solo("doc_emiko", "sterile/warm"))
    if 182 <= num <= 184:
        return ("operating_room", "sterile", "neutral", duo("nurse_moe", "scrubs/neutral", "doc_emiko", "sterile/focused"))

    # Scene F: Post-op — Lingering Heat (em1_185..em1_210)
    if num == 185:
        return ("operating_room", "scrubs", "neutral", duo("nurse_moe", "scrubs/neutral", "nurse_hiroko", "sterile/warm"))
    if 186 <= num <= 192:
        # Quiet OR while Mido still has her surgical mask tied on at the recording desk before untying it at em1_192
        return ("operating_room", "scrubs", "neutral", None)
    if 193 <= num <= 195:
        # Mask untied and removed; she turns her profile toward the lingering shadowless lamp glow
        return ("operating_room", "scrubs", "warm", solo("doc_emiko", "scrubs/warm"))
    if 196 <= num <= 198:
        return ("operating_room", "scrubs", "focused", solo("doc_emiko", "scrubs/focused"))
    if 199 <= num <= 202:
        return ("operating_room", "scrubs", "warm", solo("doc_emiko", "scrubs/warm"))
    if num == 203:
        return ("operating_room", "scrubs", "focused", solo("doc_emiko", "scrubs/focused"))
    if num in (204, 205):
        return ("operating_room", "scrubs", "neutral", solo("doc_emiko", "scrubs/neutral"))
    if num == 206:
        return ("operating_room", "scrubs", "warm", solo("doc_emiko", "scrubs/warm"))
    if 207 <= num <= 210:
        return ("or_entrance", "scrubs", "neutral", None)

    raise ValueError(f"Unhandled beat {num}")


def parse_manuscript() -> tuple[list[tuple], dict[str, str]]:
    """Return (beats, choice_labels_zh)."""
    md = MANUSCRIPT_PATH.read_text(encoding="utf-8")
    sec2 = md.split("## 二、 完整中文 VN 剧本正文", 1)[1].split("> **【事件结束｜原子性结算】**", 1)[0]

    scene = ""
    section = "main"
    in_header = False
    beats: list[tuple] = []
    choice_labels_zh: dict[str, str] = {}
    cur_choice = ""

    def add_beat(role: str, aid: str, slabel: str, text: str) -> None:
        num = len(beats) + 1
        beats.append((num, f"em1_{num:03d}", scene, section, role, aid, slabel, text))

    for raw in sec2.splitlines():
        s = raw.strip()
        if s.startswith("### Scene "):
            scene = s.split("Scene ")[1][0]
            section = "main"
            in_header = True
            continue
        if in_header:
            if s == "---":
                in_header = False
            continue
        if not s or s == "---" or s.startswith("*选项说明"):
            continue
        m_ch = re.match(r"^\*\*【选择 \d+（Choice ([BCE]1)）：.+】\*\*$", s)
        if m_ch:
            cur_choice = m_ch.group(1).lower()
            continue
        m_opt = re.match(r"^- \*\*选项 ([ABC])(?:（[^）]+）)?：(.+)\*\*$", s)
        if m_opt:
            letter = m_opt.group(1).lower()
            choice_labels_zh[f"choice_em1_{cur_choice}_{letter}"] = m_opt.group(2)
            continue
        m_br = re.match(r"^#### 【选择选项 ([ABC]) 后的分支演出(?:（[^）]+）)?】$", s)
        if m_br:
            section = f"{cur_choice}_{m_br.group(1).lower()}"
            continue
        if s.startswith("> **【分支汇合点"):
            section = f"rejoin_{cur_choice}"
            continue

        m1 = re.match(r"^\*\*([^*]+)\*\*：(「.*」)$", s)
        if m1:
            sp, q = m1.groups()
            role, aid, slabel = SPEAKER_MAP[sp]
            add_beat(role, aid, slabel, q)
            continue

        m2 = re.match(r"^\*\*([^*]+)\*\*（(.+?)）：(「.*」)$", s)
        if m2:
            sp, act, q = m2.groups()
            role, aid, slabel = SPEAKER_MAP[sp]
            add_beat("narrator", "doc_emiko", "旁白", f"{sp}（{act}）：")
            add_beat(role, aid, slabel, q)
            continue

        m3 = re.match(r"^([^「]+?)：(「[^「」]+」)$", s)
        if m3:
            pref, q = m3.groups()
            matched = next((v for k, v in UNBOLD_PREFIX_SPEAKER if pref.startswith(k)), None)
            if matched is None:
                raise ValueError(f"Unmatched quote prefix: {s!r}")
            role, aid, slabel = matched
            add_beat("narrator", "doc_emiko", "旁白", f"{pref}：")
            add_beat(role, aid, slabel, q)
            continue

        clean_s = s.replace("**", "")
        if "**" in clean_s or clean_s.startswith(("#", ">", "- ")):
            raise ValueError(f"Unexpected manuscript line: {s!r}")
        add_beat("narrator", "doc_emiko", "旁白", clean_s)

    assert len(beats) == 210, f"Expected 210 beats, got {len(beats)}"
    assert len(choice_labels_zh) == 9, f"Expected 9 choice options, got {len(choice_labels_zh)}"
    return beats, choice_labels_zh


def build_nodes(beats: list[tuple], choice_labels_zh: dict[str, str]) -> list[dict]:
    next_override = {
        "em1_051": "em1_choice_b1",
        "em1_054": "em1_061",  # End of B1-A -> rejoin B1
        "em1_057": "em1_061",  # End of B1-B -> rejoin B1
        "em1_060": "em1_061",  # End of B1-C -> rejoin B1
        "em1_076": "em1_choice_c1",
        "em1_082": "em1_095",  # End of C1-A -> rejoin C1
        "em1_088": "em1_095",  # End of C1-B -> rejoin C1
        "em1_094": "em1_095",  # End of C1-C -> rejoin C1
        "em1_154": "em1_choice_e1",
        "em1_157": "em1_165",  # End of E1-A -> rejoin E1
        "em1_161": "em1_165",  # End of E1-B -> rejoin E1
        "em1_164": "em1_165",  # End of E1-C -> rejoin E1
        "em1_210": "@end",
    }

    choice_inserts = {
        "em1_051": (
            "em1_choice_b1",
            [
                ("choice_em1_b1_a", "em1_052"),
                ("choice_em1_b1_b", "em1_055"),
                ("choice_em1_b1_c", "em1_058"),
            ],
        ),
        "em1_076": (
            "em1_choice_c1",
            [
                ("choice_em1_c1_a", "em1_077"),
                ("choice_em1_c1_b", "em1_083"),
                ("choice_em1_c1_c", "em1_089"),
            ],
        ),
        "em1_154": (
            "em1_choice_e1",
            [
                ("choice_em1_e1_a", "em1_155"),
                ("choice_em1_e1_b", "em1_158"),
                ("choice_em1_e1_c", "em1_162"),
            ],
        ),
    }

    nodes: list[dict] = []
    for idx, (num, nid, _scene, _section, role, aid, slabel, text) in enumerate(beats):
        bg_id, outfit, expr, portraits = stage_for_beat(num)
        nxt = next_override.get(nid)
        if nxt is None:
            nxt = beats[idx + 1][1]

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
                "flags": ["emiko_lv1_complete", "emiko_postop_excitement_hint"] if nid == "em1_210" else [],
            }
        ]
        nodes.append(node)

        if nid in choice_inserts:
            ch_nid, opt_specs = choice_inserts[nid]
            nodes.append(
                {
                    "id": ch_nid,
                    "presentation": "choice",
                    "speaker": "narrator",
                    "speaker_label": "旁白",
                    "actor_id": "doc_emiko",
                    "text": "",
                    "expression": "focused",
                    "outfit": "sterile",
                    "background_id": "operating_room",
                    "event_portraits": solo("doc_emiko", "sterile/focused"),
                    "choices": [
                        {
                            "id": opt_id,
                            "label": choice_labels_zh[opt_id],
                            "next": opt_next,
                            "effects": {"affection": 0, "familiarity": 0},
                            "flags": [],
                        }
                        for opt_id, opt_next in opt_specs
                    ],
                }
            )
    return nodes


def build_event(nodes: list[dict]) -> dict:
    return {
        "id": EVENT_ID,
        "actor_id": "doc_emiko",
        "title": "她的手术",
        "chapter": 1,
        "location_id": "or",
        "trigger_mode": "location",
        "background_id": "operating_room",
        "outfit": "sterile",
        "minutes": 90,
        "teaser": "御堂已经在手术台边等待第一助手。",
        "time_start": 540,
        "time_end": 1019,
        "priority": 200,
        "category": "bond",
        "auto_start": True,
        "target_level": 1,
        "benefit_id": "",
        "completion_familiarity_bonus": 10,
        "locks_saving": True,
        "completion_story_flags": [
            "emiko_lv1_complete",
            "emiko_postop_excitement_hint",
        ],
        "gallery": {
            "cg_id": "cg_emiko_lv1_first_operation",
            "caption": "她的手术",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 0,
            "required_events": [
                "emiko_intro_rumored_hands",
            ],
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "skill",
                    "minimum": 75,
                }
            ],
            "days_after_required_events": 3,
        },
        "start": "em1_001",
        "nodes": nodes,
    }


def update_localization(event: dict, en_data: dict) -> tuple[int, int]:
    zh_doc = json.loads(ZH_LOCALE_PATH.read_text(encoding="utf-8"))
    en_doc = json.loads(EN_LOCALE_PATH.read_text(encoding="utf-8"))
    zh_strings: dict[str, str] = zh_doc["strings"]
    en_strings: dict[str, str] = en_doc["strings"]

    prefix = f"collections.character_events.{EVENT_ID}."
    for store in (zh_strings, en_strings):
        for stale_key in [k for k in store if k.startswith(prefix)]:
            del store[stale_key]

    zh_added = 0
    en_added = 0

    def put(rel_key: str, zh_val: str, en_val: str) -> None:
        nonlocal zh_added, en_added
        full_key = prefix + rel_key
        zh_strings[full_key] = zh_val
        en_strings[full_key] = en_val
        zh_added += 1
        en_added += 1

    put("title", event["title"], en_data["title"])
    put("teaser", event["teaser"], en_data["teaser"])
    put("gallery.caption", event["gallery"]["caption"], en_data["gallery_caption"])

    speakers_en = en_data["speakers"]
    choices_en = en_data["choices"]
    nodes_en = en_data["nodes"]
    cont_en = en_data["continue_label"]

    for node in event["nodes"]:
        nid = node["id"]
        if node["text"]:
            put(f"nodes.{nid}.text", node["text"], nodes_en[nid])
        zh_sp = node["speaker_label"]
        put(f"nodes.{nid}.speaker_label", zh_sp, speakers_en[zh_sp])
        for ch in node["choices"]:
            cid = ch["id"]
            en_lbl = cont_en if cid.startswith("continue_") else choices_en[cid]
            put(f"nodes.{nid}.choices.{cid}.label", ch["label"], en_lbl)

    ZH_LOCALE_PATH.write_text(json.dumps(zh_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    EN_LOCALE_PATH.write_text(json.dumps(en_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return zh_added, en_added


def main() -> None:
    en_data = json.loads(EN_TRANSLATION_PATH.read_text(encoding="utf-8"))
    beats, choice_labels_zh = parse_manuscript()
    nodes = build_nodes(beats, choice_labels_zh)
    new_event = build_event(nodes)

    events_list = json.loads(EVENTS_PATH.read_text(encoding="utf-8"))
    replaced = False
    for idx, ev in enumerate(events_list):
        if ev.get("id") == EVENT_ID:
            events_list[idx] = new_event
            replaced = True
            break
    if not replaced:
        raise RuntimeError(f"Could not find {EVENT_ID} in {EVENTS_PATH}")
    EVENTS_PATH.write_text(json.dumps(events_list, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    zh_count, en_count = update_localization(new_event, en_data)

    manifest = {
        "event_id": EVENT_ID,
        "actor_id": "doc_emiko",
        "version": "V2.2",
        "imported_on": "2026-11-14",
        "source_manuscript": str(MANUSCRIPT_PATH.relative_to(ROOT)),
        "source_manuscript_sha256": sha256_of(MANUSCRIPT_PATH),
        "english_translation": str(EN_TRANSLATION_PATH.relative_to(ROOT)),
        "english_translation_sha256": sha256_of(EN_TRANSLATION_PATH),
        "output_event_file": "data/staff/doc_emiko/events.json",
        "authored_beat_count": len(beats),
        "total_node_count": len(nodes),
        "choice_nodes": ["em1_choice_b1", "em1_choice_c1", "em1_choice_e1"],
        "localization_keys_written": {"zh_CN": zh_count, "en": en_count},
        "reused_cast_portraits": {
            f"{aid}:{key}": {
                "path": path,
                "sha256": sha256_of(ROOT / path),
            }
            for (aid, key), path in sorted(CAST_PORTRAITS.items())
        },
        "gate_and_settlement": {
            "required_events": ["emiko_intro_rumored_hands"],
            "days_after_required_events": 3,
            "player_skill_minimum": 75,
            "min_familiarity": 0,
            "target_level": 1,
            "completion_familiarity_bonus": 10,
            "benefit_id": "",
            "completion_flags": ["emiko_lv1_complete", "emiko_postop_excitement_hint"],
            "surgical_team_remains_locked_until_lv2": True,
            "locks_saving": True,
        },
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Imported {EVENT_ID} V2.2: {len(nodes)} nodes ({len(beats)} beats + 3 choices), {zh_count} zh_CN keys, {en_count} en keys.")


if __name__ == "__main__":
    main()
