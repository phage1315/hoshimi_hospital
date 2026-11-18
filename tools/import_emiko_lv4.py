#!/usr/bin/env python3
"""Import Emiko Mido (`doc_emiko`) Relationship Lv4 milestone event:
《御堂江美子的秘密》 (Emiko Mido's Secret, ID: `emiko_lv4_emikos_secret`, V1.1).

Updates:
- data/staff/doc_emiko/lv4_events.json
- data/localization/zh_CN.json & data/localization/en.json
- research/imports/emiko_lv4_2026-11-15.json
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_MIDO_EMIKO_LV4_EMIKOS_SECRET_V1_1.md"
EN_TRANSLATION_PATH = ROOT / "research/translations/emiko_lv4_en.json"
EVENTS_PATH = ROOT / "data/staff/doc_emiko/lv4_events.json"
ZH_LOCALE_PATH = ROOT / "data/localization/zh_CN.json"
EN_LOCALE_PATH = ROOT / "data/localization/en.json"
MANIFEST_PATH = ROOT / "research/imports/emiko_lv4_2026-11-15.json"

EVENT_ID = "emiko_lv4_emikos_secret"
ACTION_H_PLACEHOLDER = "launch_emiko_lv4_h"
H_HANDOFF_NODE_ID = "em4_s6_1_24"
SCENE1_CG_IMMERSED = "assets/events/emiko_lv4_cg_v1/lv4_or_secret_immersed.png"
SCENE1_CG_STARTLED = "assets/events/emiko_lv4_cg_v1/lv4_or_secret_startled.png"
SCENE1_CG_IMMERSED_NODES = {f"em4_s1_{i:02d}" for i in range(9, 16)}
SCENE1_CG_STARTLED_NODES = {f"em4_s1_{i:02d}" for i in range(16, 19)}

CAST_PORTRAITS = {
    ("doc_emiko", "white_coat/neutral"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/neutral.png",
    ("doc_emiko", "white_coat/smile"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/smile.png",
    ("doc_emiko", "white_coat/serious"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/serious.png",
    ("doc_emiko", "white_coat/surprised"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/surprised.png",
    ("doc_emiko", "white_coat/worried"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/worried.png",
    ("doc_emiko", "white_coat/warm"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/warm.png",
    ("doc_emiko", "scrubs/neutral"): "assets/characters/portrait_pack_v14/doc_emiko/scrubs/neutral.png",
    ("doc_emiko", "scrubs/focused"): "assets/characters/portrait_pack_v14/doc_emiko/scrubs/focused.png",
    ("doc_emiko", "scrubs/worried"): "assets/characters/portrait_pack_v14/doc_emiko/scrubs/worried.png",
    ("doc_emiko", "scrubs/warm"): "assets/characters/portrait_pack_v14/doc_emiko/scrubs/warm.png",
    ("doc_emiko", "sterile/neutral"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/neutral.png",
    ("doc_emiko", "sterile/focused"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/focused.png",
    ("doc_emiko", "sterile/worried"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/worried.png",
    ("doc_emiko", "sterile/warm"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/warm.png",
    ("nurse_hiroko", "sterile/neutral"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/neutral.png",
    ("nurse_hiroko", "sterile/focused"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/focused.png",
    ("nurse_hiroko", "sterile/warm"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/warm.png",
    ("nurse_ange", "scrubs/neutral"): "assets/characters/portrait_pack_v11/nurse_ange/scrubs/neutral.png",
    ("nurse_ange", "scrubs/focused"): "assets/characters/portrait_pack_v11/nurse_ange/scrubs/focused.png",
    ("nurse_ange", "scrubs/warm"): "assets/characters/portrait_pack_v11/nurse_ange/scrubs/warm.png",
    ("patient_sakurai_mayumi", "intraoperative/tense"): "assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/intraoperative/tense.png",
}

SPEAKER_MAP = {
    "旁白": ("narrator", "doc_emiko", "旁白"),
    "御堂江美子": ("actor", "doc_emiko", "御堂江美子"),
    "坂口隆司": ("player", "doc_emiko", "坂口隆司"),
    "杉村弘子": ("actor", "nurse_hiroko", "杉村弘子"),
    "利根川安琪": ("actor", "nurse_ange", "利根川安琪"),
    "樱井真弓": ("actor", "doc_emiko", "樱井真弓"),
}

MIXED_PREFIX_SPEAKERS = [
    ("对侧配合跟线剪线的坂口隆司", "坂口隆司"),
    ("坂口隆司", "坂口隆司"),
    ("御堂江美子", "御堂江美子"),
    ("头侧的利根川安琪", "利根川安琪"),
    ("利根川安琪", "利根川安琪"),
    ("听见双人清点的口令声，躺在头架布帘后一直忍着没吭声的二十七岁女警樱井真弓", "樱井真弓"),
    ("樱井真弓", "樱井真弓"),
]

UI_STRINGS_ZH = {
    "ui.emiko_lv4.h_placeholder.title": "御堂江美子 · 首次手术台亲密（占位）",
    "ui.emiko_lv4.h_placeholder.subtitle": "四楼二号手术室 · 手术台",
    "ui.emiko_lv4.h_placeholder.body": "【开发占位 H Runner】\n地点：星见医院·四楼二号手术室（手术台）\n当前御堂江美子的专属 H Profile 与互动差分尚待制作确认；点击下方按钮将完成首次手术台亲密流程并衔接第 6.2 幕事后对话。",
    "ui.emiko_lv4.h_placeholder.continue": "完成亲密流程并进入事后对话  ▷",
    "ui.free_h.location.doc_emiko_or": "四楼手术室",
    "ui.free_h.doc_emiko.booking_response": "……今晚二号手术间后面没有排台。下班以后过来，陪我『复盘』。",
}

UI_STRINGS_EN = {
    "ui.emiko_lv4.h_placeholder.title": "Emiko Mido · First Operating-Table Intimacy (Placeholder)",
    "ui.emiko_lv4.h_placeholder.subtitle": "Fourth Floor · Operating Room No. 2 · Operating Table",
    "ui.emiko_lv4.h_placeholder.body": "[Development H Runner Placeholder]\nLocation: Hoshimi Hospital · 4F Operating Room No. 2 (Operating Table)\nEmiko Mido's dedicated H Profile and interactive CG set are pending production design; press below to complete the first intimacy sequence and proceed directly into Scene 6.2 aftercare.",
    "ui.emiko_lv4.h_placeholder.continue": "Complete Intimacy & Continue to Aftercare  ▷",
    "ui.free_h.location.doc_emiko_or": "4F Operating Room",
    "ui.free_h.doc_emiko.booking_response": "...Room Two has no late cases scheduled tonight. Come by after hours and 'debrief' with me.",
}

CJK_RE = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")


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


def duo_with_patient(staff_actor: str, staff_key: str) -> list[dict]:
    return [
        {
            "id": "patient_sakurai_mayumi",
            "path": CAST_PORTRAITS[("patient_sakurai_mayumi", "intraoperative/tense")],
            "x": 875,
            "bottom": 528,
            "width": 384,
            "height": 288,
        },
        {
            "id": staff_actor,
            "path": CAST_PORTRAITS[(staff_actor, staff_key)],
            "x": 1135,
            "bottom": 532,
            "width": 288,
            "height": 432,
        },
    ]


def stage_for_node(nid: str, sec: str) -> tuple[str, str, str, list[dict] | None]:
    """Return (background_id, outfit, expression, event_portraits_or_None)."""
    idx = int(nid.rsplit("_", 1)[1])

    # Scene 1: Outside OR No. 2 -> empty OR No. 2 (reserved for Scene 1 NSFW CG) -> outside OR No. 2
    if sec == "s1":
        if 1 <= idx <= 7:
            return ("or_entrance", "white_coat", "neutral", None)
        if 8 <= idx <= 22:
            return ("operating_room", "scrubs", "worried", None)
        return ("or_entrance", "white_coat", "neutral", None)

    # Scene 2: Two-to-three-day brief distance montage (morning conference -> 2F hallway -> 4F OR whiteboard -> ward)
    if sec == "s2":
        if idx == 1:
            return ("shared_doctors_office", "white_coat", "neutral", None)
        if idx == 2:
            return ("shared_doctors_office", "white_coat", "neutral", solo("doc_emiko", "white_coat/neutral"))
        if idx == 3:
            return ("hallway", "white_coat", "serious", None)
        if 4 <= idx <= 7:
            return ("hallway", "white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
        if idx == 8:
            return ("hallway", "white_coat", "serious", None)
        if 9 <= idx <= 11:
            return ("or_entrance", "white_coat", "neutral", solo("doc_emiko", "white_coat/neutral"))
        if 12 <= idx <= 16:
            return ("or_entrance", "white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
        if idx == 17:
            return ("or_entrance", "white_coat", "serious", None)
        if idx == 18:
            return ("ward", "white_coat", "serious", None)
        if idx == 19:
            return ("ward", "white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
        return ("ward", "white_coat", "serious", None)

    # Scene 3: Evening confrontation in the surgical doctors' office ("Are you an idiot?")
    if sec == "s3":
        if idx in (1, 2):
            return ("shared_doctors_office", "white_coat", "serious", None)
        return ("shared_doctors_office", "white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
    if sec in ("c1a", "c1b", "c1c"):
        expr = "surprised" if idx >= 3 else "serious"
        return ("shared_doctors_office", "white_coat", expr, solo("doc_emiko", f"white_coat/{expr}"))
    if sec == "s3r":
        if 1 <= idx <= 6:
            return ("shared_doctors_office", "white_coat", "surprised", solo("doc_emiko", "white_coat/surprised"))
        if 7 <= idx <= 10:
            return ("shared_doctors_office", "white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
        if 11 <= idx <= 15:
            return ("shared_doctors_office", "white_coat", "worried", solo("doc_emiko", "white_coat/worried"))
        if 16 <= idx <= 26:
            return ("shared_doctors_office", "white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
        return ("shared_doctors_office", "white_coat", "worried", solo("doc_emiko", "white_coat/worried"))

    # Scene 4: Candid confession of her postoperative excitement & mutual acceptance
    if sec == "s4":
        if 1 <= idx <= 5:
            return ("shared_doctors_office", "white_coat", "neutral", solo("doc_emiko", "white_coat/neutral"))
        if 6 <= idx <= 12:
            return ("shared_doctors_office", "white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
        return ("shared_doctors_office", "white_coat", "worried", solo("doc_emiko", "white_coat/worried"))
    if sec == "c2a":
        if idx in (1, 2):
            return ("shared_doctors_office", "white_coat", "worried", solo("doc_emiko", "white_coat/worried"))
        if idx in (3, 4):
            return ("shared_doctors_office", "white_coat", "surprised", solo("doc_emiko", "white_coat/surprised"))
        return ("shared_doctors_office", "white_coat", "warm", solo("doc_emiko", "white_coat/warm"))
    if sec == "c2b":
        if idx in (1, 2):
            return ("shared_doctors_office", "white_coat", "worried", solo("doc_emiko", "white_coat/worried"))
        if 3 <= idx <= 6:
            return ("shared_doctors_office", "white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
        return ("shared_doctors_office", "white_coat", "warm", solo("doc_emiko", "white_coat/warm"))
    if sec == "c2c":
        expr = "warm" if idx >= 3 else "worried"
        return ("shared_doctors_office", "white_coat", expr, solo("doc_emiko", f"white_coat/{expr}"))
    if sec == "s4r":
        if 1 <= idx <= 4:
            return ("shared_doctors_office", "white_coat", "neutral", solo("doc_emiko", "white_coat/neutral"))
        if 5 <= idx <= 9:
            return ("shared_doctors_office", "white_coat", "warm", solo("doc_emiko", "white_coat/warm"))
        return ("shared_doctors_office", "white_coat", "smile", solo("doc_emiko", "white_coat/smile"))

    # Scene 5: Open cholecystectomy closing (Mayumi Sakurai, Hiroko, Ange) -> "You don't need to leave first today." -> Ange outside OR
    if sec == "s5":
        if idx == 1:
            return ("operating_room", "sterile", "focused", None)
        if idx == 2:
            return ("operating_room", "sterile", "warm", solo("doc_emiko", "sterile/warm"))
        if idx in (3, 4):
            return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
        if idx == 5:
            return ("operating_room", "sterile", "focused", duo("nurse_ange", "scrubs/focused", "doc_emiko", "sterile/focused"))
        if idx in (6, 7):
            return ("operating_room", "sterile", "focused", duo_with_patient("doc_emiko", "sterile/focused"))
        if 8 <= idx <= 11:
            return ("operating_room", "sterile", "warm", duo_with_patient("doc_emiko", "sterile/warm"))
        if idx in (12, 13):
            return ("operating_room", "sterile", "warm", duo_with_patient("nurse_ange", "scrubs/warm"))
        if idx in (14, 15):
            return ("operating_room", "sterile", "warm", duo_with_patient("doc_emiko", "sterile/warm"))
        if idx in (16, 17):
            return ("operating_room", "sterile", "warm", duo("nurse_hiroko", "sterile/warm", "doc_emiko", "sterile/warm"))
        if idx == 18:
            return ("operating_room", "sterile", "warm", duo("nurse_ange", "scrubs/warm", "nurse_hiroko", "sterile/warm"))
        if idx == 19:
            return ("operating_room", "scrubs", "neutral", None)
        if 20 <= idx <= 25:
            return ("operating_room", "scrubs", "focused", solo("doc_emiko", "scrubs/focused"))
        if 26 <= idx <= 28:
            return ("operating_room", "scrubs", "worried", solo("doc_emiko", "scrubs/worried"))
        if 29 <= idx <= 37:
            return ("operating_room", "scrubs", "warm", solo("doc_emiko", "scrubs/warm"))
        if idx in (38, 39):
            return ("operating_room", "scrubs", "worried", solo("doc_emiko", "scrubs/worried"))
        if 40 <= idx <= 47:
            return ("or_entrance", "scrubs", "neutral", solo("nurse_ange", "scrubs/neutral"))
        if idx in (48, 49):
            return ("or_entrance", "scrubs", "warm", solo("nurse_ange", "scrubs/warm"))
        if idx == 50:
            return ("or_entrance", "scrubs", "neutral", None)
        if idx in (51, 52):
            return ("operating_room", "scrubs", "neutral", None)
        return ("operating_room", "scrubs", "warm", solo("doc_emiko", "scrubs/warm"))

    # Scene 6.1: Pre-H banter in OR No. 2 ("An operating table really is a bed—just a little narrow.")
    if sec == "s6_1":
        if idx == 1:
            return ("operating_room", "scrubs", "neutral", None)
        if 2 <= idx <= 6:
            return ("operating_room", "scrubs", "worried", solo("doc_emiko", "scrubs/worried"))
        if 7 <= idx <= 10:
            return ("operating_room", "scrubs", "warm", solo("doc_emiko", "scrubs/warm"))
        if 11 <= idx <= 13:
            return ("operating_room", "scrubs", "neutral", solo("doc_emiko", "scrubs/neutral"))
        if idx in (14, 15):
            return ("operating_room", "scrubs", "worried", solo("doc_emiko", "scrubs/worried"))
        if 16 <= idx <= 18:
            return ("operating_room", "scrubs", "warm", solo("doc_emiko", "scrubs/warm"))
        if idx in (19, 20):
            return ("operating_room", "scrubs", "focused", solo("doc_emiko", "scrubs/focused"))
        return ("operating_room", "scrubs", "warm", solo("doc_emiko", "scrubs/warm"))

    # Scene 6.2: Exclusive aftercare & unyielding Chief of Surgery rivalry
    if sec == "s6_2":
        if idx in (1, 2):
            return ("operating_room", "scrubs", "warm", None)
        if 3 <= idx <= 16:
            return ("operating_room", "scrubs", "warm", solo("doc_emiko", "scrubs/warm"))
        if idx in (17, 18):
            return ("operating_room", "scrubs", "neutral", solo("doc_emiko", "scrubs/neutral"))
        if idx == 19:
            return ("operating_room", "scrubs", "neutral", None)
        if 20 <= idx <= 27:
            return ("operating_room", "scrubs", "focused", solo("doc_emiko", "scrubs/focused"))
        if 28 <= idx <= 32:
            return ("operating_room", "scrubs", "warm", solo("doc_emiko", "scrubs/warm"))
        return ("or_entrance", "scrubs", "warm", None)

    raise ValueError(f"Unhandled node staging: {nid} ({sec})")


def parse_manuscript() -> tuple[list[dict], dict[str, str], int, int]:
    md = MANUSCRIPT_PATH.read_text(encoding="utf-8")
    sec2 = md.split("## 二、 完整中文 VN 剧本正文", 1)[1].split("**【御堂江美子 Relationship Lv4《御堂江美子的秘密》事件结束】**", 1)[0]

    section = ""
    in_meta = False
    counts: dict[str, int] = {}
    beats: list[dict] = []
    choices_zh: dict[str, str] = {}
    cur_choice = ""
    mixed_split_count = 0
    bold_strip_count = 0

    def push(sec: str, spk: str, txt: str) -> None:
        counts[sec] = counts.get(sec, 0) + 1
        nid = f"em4_{sec}_{counts[sec]:02d}"
        role, aid, slabel = SPEAKER_MAP[spk]
        beats.append(
            {
                "id": nid,
                "sec": sec,
                "role": role,
                "actor_id": aid,
                "speaker_label": slabel,
                "text": txt,
            }
        )

    for raw in sec2.splitlines():
        s = raw.strip()
        if s.startswith("### 【第一幕"):
            section = "s1"
            in_meta = True
            continue
        if s.startswith("### 【第二幕"):
            section = "s2"
            in_meta = True
            continue
        if s.startswith("### 【第三幕"):
            section = "s3"
            in_meta = True
            continue
        if s.startswith("### 【第四幕"):
            section = "s4"
            in_meta = True
            continue
        if s.startswith("### 【第五幕"):
            section = "s5"
            in_meta = True
            continue
        if s.startswith("### 【第六幕"):
            section = "s6"
            in_meta = True
            continue
        if in_meta:
            if s == "**【玩家可见正文】**":
                in_meta = False
            continue
        if s.startswith("#### 6.1"):
            section = "s6_1"
            continue
        if s.startswith("#### 6.2"):
            section = "s6_2"
            continue
        if s.startswith("> **【语义接入点") or s.startswith("> - "):
            continue
        if not s or s == "---" or s.startswith("*性质："):
            continue
        m_ch = re.match(r"^\*\*【选择 (\d+)：.+】\*\*$", s)
        if m_ch:
            cur_choice = f"c{m_ch.group(1)}"
            continue
        m_opt = re.match(r"^- \*\*选项 ([ABC])：(.+)\*\*$", s)
        if m_opt:
            choices_zh[f"choice_em4_{cur_choice}_{m_opt.group(1).lower()}"] = m_opt.group(2)
            continue
        m_br = re.match(r"^#### 【分支 ([ABC]) — .+】$", s)
        if m_br:
            section = f"{cur_choice}{m_br.group(1).lower()}"
            continue
        if s.startswith("> **【主线汇合"):
            section = {"c1": "s3r", "c2": "s4r"}[cur_choice]
            continue

        # Strip non-diegetic Markdown `**` emphasis markers so Godot Label does not display literal asterisks.
        if "**" in s:
            bold_strip_count += s.count("**") // 2
            s = s.replace("**", "")

        m_pure = re.match(r"^(御堂江美子|坂口隆司|杉村弘子|利根川安琪|樱井真弓)：(「.+」)$", s)
        if m_pure:
            push(section, m_pure.group(1), m_pure.group(2))
            continue
        if "：「" in s:
            act, quote = s.split("：", 1)
            spk = None
            for pfx, target in MIXED_PREFIX_SPEAKERS:
                if act.startswith(pfx):
                    spk = target
                    break
            if spk is None:
                raise ValueError(f"Unmapped mixed action+dialogue line: {s!r}")
            mixed_split_count += 1
            push(section, "旁白", act + "：")
            push(section, spk, quote)
            continue
        push(section, "旁白", s)

    return beats, choices_zh, mixed_split_count, bold_strip_count


def build_nodes(beats: list[dict], choices_zh: dict[str, str]) -> list[dict]:
    if len(beats) != 267:
        raise ValueError(f"Expected 267 beats, got {len(beats)}")

    by_sec: dict[str, list[dict]] = {}
    for b in beats:
        by_sec.setdefault(b["sec"], []).append(b)

    next_map: dict[str, str] = {}
    for _sec, sec_beats in by_sec.items():
        for i in range(len(sec_beats) - 1):
            next_map[sec_beats[i]["id"]] = sec_beats[i + 1]["id"]

    # Cross-section transitions
    next_map["em4_s1_25"] = "em4_s2_01"
    next_map["em4_s2_23"] = "em4_s3_01"
    next_map["em4_s3_19"] = "em4_choice_c1"
    next_map["em4_c1a_04"] = "em4_s3r_01"
    next_map["em4_c1b_04"] = "em4_s3r_01"
    next_map["em4_c1c_04"] = "em4_s3r_01"
    next_map["em4_s3r_29"] = "em4_s4_01"
    next_map["em4_s4_16"] = "em4_choice_c2"
    next_map["em4_c2a_05"] = "em4_s4r_01"
    next_map["em4_c2b_07"] = "em4_s4r_01"
    next_map["em4_c2c_04"] = "em4_s4r_01"
    next_map["em4_s4r_13"] = "em4_s5_01"
    next_map["em4_s5_56"] = "em4_s6_1_01"
    next_map["em4_s6_1_24"] = "em4_s6_2_01"
    next_map["em4_s6_2_34"] = "@end"

    choice_after: dict[str, dict] = {
        "em4_s3_19": {
            "id": "em4_choice_c1",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": "doc_emiko",
            "text": "",
            "expression": "serious",
            "outfit": "white_coat",
            "background_id": "shared_doctors_office",
            "event_portraits": solo("doc_emiko", "white_coat/serious"),
            "choices": [
                {
                    "id": "choice_em4_c1_a",
                    "label": choices_zh["choice_em4_c1_a"],
                    "next": "em4_c1a_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em4_c1_b",
                    "label": choices_zh["choice_em4_c1_b"],
                    "next": "em4_c1b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em4_c1_c",
                    "label": choices_zh["choice_em4_c1_c"],
                    "next": "em4_c1c_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        "em4_s4_16": {
            "id": "em4_choice_c2",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": "doc_emiko",
            "text": "",
            "expression": "worried",
            "outfit": "white_coat",
            "background_id": "shared_doctors_office",
            "event_portraits": solo("doc_emiko", "white_coat/worried"),
            "choices": [
                {
                    "id": "choice_em4_c2_a",
                    "label": choices_zh["choice_em4_c2_a"],
                    "next": "em4_c2a_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em4_c2_b",
                    "label": choices_zh["choice_em4_c2_b"],
                    "next": "em4_c2b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em4_c2_c",
                    "label": choices_zh["choice_em4_c2_c"],
                    "next": "em4_c2c_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
    }

    nodes: list[dict] = []
    for b in beats:
        nid = b["id"]
        bg_id, outfit, expr, portraits = stage_for_node(nid, b["sec"])
        nxt = next_map[nid]
        cid = f"continue_{nid}"
        end_flags = ["emiko_lv4_complete"] if nxt == "@end" else []
        node: dict = {
            "id": nid,
            "presentation": "authored",
            "speaker": b["role"],
            "speaker_label": b["speaker_label"],
            "actor_id": b["actor_id"],
            "text": b["text"],
            "expression": expr,
            "outfit": outfit,
            "background_id": bg_id,
        }
        if nid in SCENE1_CG_IMMERSED_NODES:
            node["cg_path"] = SCENE1_CG_IMMERSED
            node["cg_fit"] = "contain"
            node["cg_dialogue_delay_seconds"] = 2.0
        elif nid in SCENE1_CG_STARTLED_NODES:
            node["cg_path"] = SCENE1_CG_STARTLED
            node["cg_fit"] = "contain"
            node["cg_dialogue_delay_seconds"] = 2.0
        elif portraits is None:
            node["hide_portrait"] = True
        else:
            node["event_portraits"] = portraits
        if nid == H_HANDOFF_NODE_ID:
            node["action"] = ACTION_H_PLACEHOLDER
        node["choices"] = [
            {
                "id": cid,
                "label": "继续",
                "next": nxt,
                "effects": {"affection": 0, "familiarity": 0},
                "flags": end_flags,
            }
        ]
        nodes.append(node)
        if nid in choice_after:
            nodes.append(choice_after[nid])

    return nodes


def build_event(nodes: list[dict]) -> dict:
    return {
        "id": EVENT_ID,
        "actor_id": "doc_emiko",
        "title": "御堂江美子的秘密",
        "chapter": 4,
        "location_id": "or",
        "trigger_mode": "after_work",
        "background_id": "or_entrance",
        "outfit": "white_coat",
        "completion_background_id": "or_entrance",
        "completion_outfit": "scrubs",
        "completion_expression": "warm",
        "hide_calendar_header": True,
        "minutes": 0,
        "completion_day_offset": 1,
        "completion_absolute_clock": 540,
        "teaser": "意外撞破御堂江美子留在空手术室里的私密习惯后，坂口隆司拒绝借此在外科主任竞争中占她便宜，也第一次被她留在了关上门的二号手术室里。",
        "time_start": 960,
        "time_end": 1320,
        "priority": 186,
        "category": "rank_up",
        "gallery": {
            "cg_id": "cg_emiko_lv4_emikos_secret",
            "caption": "拒绝拿御堂江美子的秘密充当外科主任竞争筹码后，坂口隆司在下一次同台开腹手术结束后被她留在了二号手术室里——在手术台上分享秘密，也在门外继续堂堂正正争高下。",
            "path": SCENE1_CG_IMMERSED,
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "max_day": 363,
            "min_affection": 0,
            "min_familiarity": 55,
            "required_events": ["emiko_lv3_today_i_lead"],
            "days_after_required_events": 3,
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "presence",
                    "minimum": 30,
                }
            ],
        },
        "auto_start": True,
        "locks_saving": True,
        "target_level": 4,
        "benefit_id": "unlock_intimacy_events",
        "completion_story_flags": [
            "emiko_lv4_complete",
        ],
        "start": "em4_s1_01",
        "nodes": nodes,
    }


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
        **UI_STRINGS_ZH,
        f"{prefix}title": event["title"],
        f"{prefix}teaser": event["teaser"],
        f"{prefix}gallery.caption": event["gallery"]["caption"],
    }
    en_new: dict[str, str] = {
        **UI_STRINGS_EN,
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

    for k, v in en_new.items():
        if CJK_RE.search(v):
            raise ValueError(f"CJK characters leaked into English locale key {k}: {v!r}")

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

    beats, choices_zh, mixed_split_count, bold_strip_count = parse_manuscript()
    en_data = json.loads(EN_TRANSLATION_PATH.read_text(encoding="utf-8"))

    beat_ids = {b["id"] for b in beats}
    if set(en_data["nodes"].keys()) != beat_ids:
        missing = sorted(beat_ids - set(en_data["nodes"].keys()))
        extra = sorted(set(en_data["nodes"].keys()) - beat_ids)
        raise ValueError(f"EN node mismatch: missing={missing}, extra={extra}")
    if set(en_data["choices"].keys()) != set(choices_zh.keys()):
        raise ValueError("EN choice keys mismatch")

    nodes = build_nodes(beats, choices_zh)
    new_event = build_event(nodes)
    EVENTS_PATH.write_text(json.dumps([new_event], ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    zh_count, en_count = update_locales(new_event, en_data)

    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    manifest = {
        "event_id": EVENT_ID,
        "actor_id": "doc_emiko",
        "title_zh": new_event["title"],
        "title_en": en_data["title"],
        "version": "V1.1",
        "source_manuscript": str(MANUSCRIPT_PATH.relative_to(ROOT)),
        "source_manuscript_sha256": sha256_of(MANUSCRIPT_PATH),
        "en_translation": str(EN_TRANSLATION_PATH.relative_to(ROOT)),
        "en_translation_sha256": sha256_of(EN_TRANSLATION_PATH),
        "authored_beat_count": len(beats),
        "choice_node_count": 2,
        "total_node_count": len(nodes),
        "h_runner_handoff_node": H_HANDOFF_NODE_ID,
        "h_runner_action": ACTION_H_PLACEHOLDER,
        "localization_keys_written": {"zh_CN": zh_count, "en": en_count},
        "formatting_adjustments": [
            f"{mixed_split_count} mixed action+quote lines (`叙事动作前缀：「角色台词」`) split at `：` into adjacent verbatim narrator action beat + verbatim character dialogue beat so speaker nameplate displays accurately on spoken lines without adding or deleting any text.",
            f"Stripped {bold_strip_count} Markdown `**` emphasis pairs on `em4_s1_11` and `em4_s1_12` so Godot Label does not display literal `**` asterisks while keeping 100% of characters verbatim.",
            "Stripped non-diegetic `- **选项 X：...**` Markdown wrapper headers on the 6 interactive choice labels.",
        ],
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Imported {EVENT_ID} V1.1: {len(nodes)} nodes ({len(beats)} beats + 2 choices); locales zh={zh_count}, en={en_count}.")


if __name__ == "__main__":
    main()
