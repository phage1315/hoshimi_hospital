#!/usr/bin/env python3
"""Import Emiko Mido (`doc_emiko`) Relationship Lv3 milestone event:
《今天我主刀》 (Today, I Lead the Table, ID: `emiko_lv3_today_i_lead`, V1.1).

Updates:
- data/staff/doc_emiko/lv3_events.json
- data/localization/zh_CN.json & data/localization/en.json
- research/imports/emiko_lv3_2026-11-15.json
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_MIDO_EMIKO_LV3_TODAY_I_LEAD_V1_1.md"
EN_TRANSLATION_PATH = ROOT / "research/translations/emiko_lv3_en.json"
EVENTS_PATH = ROOT / "data/staff/doc_emiko/lv3_events.json"
ZH_LOCALE_PATH = ROOT / "data/localization/zh_CN.json"
EN_LOCALE_PATH = ROOT / "data/localization/en.json"
MANIFEST_PATH = ROOT / "research/imports/emiko_lv3_2026-11-15.json"

EVENT_ID = "emiko_lv3_today_i_lead"
BG_ID_SUSHI = "emiko_lv3_sushi_bar_night"
CABG_TEACHING_CHOICE_ID = "em3_cabg_teaching_complete"

CAST_PORTRAITS = {
    ("doc_emiko", "casual/neutral"): "assets/characters/spring_summer_casual_v1/doc_emiko/neutral.png",
    ("doc_emiko", "scrubs_masked/neutral"): "assets/characters/emiko_lv3_v1/doc_emiko/scrubs_masked/neutral.png",
    ("doc_emiko", "scrubs_masked/focused"): "assets/characters/emiko_lv3_v1/doc_emiko/scrubs_masked/focused.png",
    ("doc_emiko", "sterile/neutral"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/neutral.png",
    ("doc_emiko", "sterile/focused"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/focused.png",
    ("doc_emiko", "sterile/worried"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/worried.png",
    ("doc_emiko", "sterile/warm"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/warm.png",
    ("doc_emiko", "scrubs/neutral"): "assets/characters/portrait_pack_v14/doc_emiko/scrubs/neutral.png",
    ("doc_emiko", "scrubs/focused"): "assets/characters/portrait_pack_v14/doc_emiko/scrubs/focused.png",
    ("doc_emiko", "white_coat/neutral"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/neutral.png",
    ("doc_emiko", "white_coat/serious"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/serious.png",
    ("doc_emiko", "white_coat/smile"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/smile.png",
    ("doc_emiko", "white_coat/warm"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/warm.png",
    ("nurse_hiroko", "sterile/neutral"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/neutral.png",
    ("nurse_hiroko", "sterile/focused"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/focused.png",
    ("nurse_hiroko", "sterile/warm"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/warm.png",
    ("nurse_moe", "scrubs/neutral"): "assets/characters/moe_circulating_v1/neutral.png",
    ("story_guest_cabg_patient", "or_cap/panicked"): "assets/characters/emiko_lv3_v1/cabg_patient/or_cap/panicked.png",
    ("story_guest_cabg_patient", "or_cap/relieved"): "assets/characters/emiko_lv3_v1/cabg_patient/or_cap/relieved.png",
    ("story_guest_cabg_patient", "or_cap/mask_drowsy"): "assets/characters/emiko_lv3_v1/cabg_patient/or_cap/mask_drowsy.png",
}

SPEAKER_MAP = {
    "旁白": ("narrator", "doc_emiko", "旁白"),
    "御堂江美子": ("actor", "doc_emiko", "御堂江美子"),
    "坂口隆司": ("player", "doc_emiko", "坂口隆司"),
    "杉村弘子": ("actor", "nurse_hiroko", "杉村弘子"),
    "本庄萌恵": ("actor", "nurse_moe", "本庄萌恵"),
    "寿司店师傅": ("actor", "doc_emiko", "寿司店师傅"),
    "患者": ("actor", "doc_emiko", "患者"),
    "麻醉医生": ("actor", "doc_emiko", "麻醉医生"),
    "灌注师": ("actor", "doc_emiko", "灌注师"),
}

MIXED_PREFIX_SPEAKERS = [
    ("听见推门声，寿司店师傅", "寿司店师傅"),
    ("本庄萌恵", "本庄萌恵"),
    ("站在一旁的坂口隆司", "坂口隆司"),
    ("女患者", "患者"),
    ("杉村弘子", "杉村弘子"),
    ("坂口隆司", "坂口隆司"),
    ("御堂江美子", "御堂江美子"),
]

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


def solo_patient(patient_key: str) -> list[dict]:
    return [
        {
            "id": "story_guest_cabg_patient",
            "path": CAST_PORTRAITS[("story_guest_cabg_patient", patient_key)],
            "x": 965,
            "bottom": 556,
            "width": 456,
            "height": 342,
        }
    ]


def duo_with_patient(staff_actor: str, staff_key: str, patient_key: str) -> list[dict]:
    return [
        {
            "id": "story_guest_cabg_patient",
            "path": CAST_PORTRAITS[("story_guest_cabg_patient", patient_key)],
            "x": 875,
            "bottom": 556,
            "width": 384,
            "height": 288,
        },
        {
            "id": staff_actor,
            "path": CAST_PORTRAITS[(staff_actor, staff_key)],
            "x": 1135,
            "bottom": 556,
            "width": 288,
            "height": 432,
        },
    ]


def stage_for_node(nid: str, sec: str) -> tuple[str, str, str, list[dict] | None]:
    """Return (background_id, outfit, expression, event_portraits_or_None)."""
    idx = int(nid.rsplit("_", 1)[1])

    # Scene 1: Back-alley sushi bar counter at night
    if sec == "s1":
        if idx in (1, 2, 3, 6, 7, 14, 15, 29):
            return (BG_ID_SUSHI, "casual", "neutral", None)
        return (BG_ID_SUSHI, "casual", "neutral", solo("doc_emiko", "casual/neutral"))
    if sec in ("s", "o", "g", "c1a", "c1a_s", "c1a_og", "c1a_tail", "c1b", "c1c"):
        return (BG_ID_SUSHI, "casual", "neutral", solo("doc_emiko", "casual/neutral"))
    if sec == "s1r":
        if idx == 1:
            return (BG_ID_SUSHI, "casual", "neutral", None)
        return (BG_ID_SUSHI, "casual", "neutral", solo("doc_emiko", "casual/neutral"))

    # Scene 2: Pre-induction OR ("Today, I lead the table.")
    if sec == "s2":
        if idx in (1, 2):
            return ("operating_room", "scrubs_masked", "neutral", None)
        if idx == 3:
            return ("operating_room", "scrubs_masked", "neutral", solo_patient("or_cap/panicked"))
        if idx in (4, 5, 6):
            return ("operating_room", "scrubs_masked", "neutral", duo_with_patient("nurse_moe", "scrubs/neutral", "or_cap/panicked"))
        if 7 <= idx <= 11:
            return ("operating_room", "scrubs_masked", "neutral", duo_with_patient("doc_emiko", "scrubs_masked/neutral", "or_cap/panicked"))
        if 12 <= idx <= 16:
            return ("operating_room", "scrubs_masked", "focused", duo_with_patient("doc_emiko", "scrubs_masked/focused", "or_cap/panicked"))
        if idx in (17, 18):
            return ("operating_room", "scrubs_masked", "focused", duo_with_patient("doc_emiko", "scrubs_masked/focused", "or_cap/relieved"))
        if 19 <= idx <= 25:
            return ("operating_room", "scrubs_masked", "neutral", duo_with_patient("doc_emiko", "scrubs_masked/neutral", "or_cap/relieved"))
        if idx in (26, 27):
            return ("operating_room", "scrubs_masked", "focused", duo_with_patient("doc_emiko", "scrubs_masked/focused", "or_cap/relieved"))
        if idx == 28:
            return ("operating_room", "scrubs_masked", "focused", duo_with_patient("nurse_moe", "scrubs/neutral", "or_cap/relieved"))
        if idx == 29:
            return ("operating_room", "scrubs_masked", "focused", solo_patient("or_cap/relieved"))
        if idx == 30:
            return ("operating_room", "scrubs_masked", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "scrubs_masked/focused"))
        if idx == 31:
            return ("operating_room", "scrubs_masked", "neutral", solo_patient("or_cap/relieved"))
        if idx == 32:
            return ("operating_room", "scrubs_masked", "neutral", solo_patient("or_cap/mask_drowsy"))
        if idx == 33:
            return ("operating_room", "sterile", "neutral", duo("nurse_hiroko", "sterile/neutral", "doc_emiko", "sterile/neutral"))

    # Scene 3: CABG core on-pump anastomoses & shared rhythm
    if sec == "s3":
        if idx == 1:
            return ("operating_room", "sterile", "focused", None)
        if idx in (2, 6, 7, 27, 28):
            return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"))
        if idx in (15, 18, 21, 22, 23, 24):
            return ("operating_room", "sterile", "focused", None)
        if idx in (9, 10, 11, 12, 33, 34):
            return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
        return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
    if sec == "c2a":
        expr = "warm" if idx >= 3 else "focused"
        return ("operating_room", "sterile", expr, solo("doc_emiko", f"sterile/{expr}"))
    if sec == "c2b":
        expr = "warm" if idx >= 6 else "focused"
        return ("operating_room", "sterile", expr, solo("doc_emiko", f"sterile/{expr}"))
    if sec == "c2c":
        if idx in (1, 2):
            return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
        if idx == 3:
            return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/warm", "doc_emiko", "sterile/focused"))
        return ("operating_room", "sterile", "warm", solo("doc_emiko", "sterile/warm"))
    if sec == "s3r":
        if idx in (1, 2, 4):
            return ("operating_room", "sterile", "focused", solo("doc_emiko", "sterile/focused"))
        if idx in (3, 5, 6, 7, 9, 10):
            return ("operating_room", "sterile", "focused", None)
        if idx == 8:
            return ("operating_room", "sterile", "neutral", solo("nurse_moe", "scrubs/neutral"))
        if idx in (11, 12, 15):
            return ("operating_room", "sterile", "neutral", solo("doc_emiko", "sterile/neutral"))
        if idx in (13, 14):
            return ("operating_room", "sterile", "neutral", duo("nurse_hiroko", "sterile/neutral", "nurse_moe", "scrubs/neutral"))
        if idx == 16:
            return ("operating_room", "sterile", "warm", duo("nurse_hiroko", "sterile/warm", "doc_emiko", "sterile/neutral"))

    # Scene 4: Post-op OR & closed frosted doors
    if sec == "s4":
        if idx == 1:
            return ("operating_room", "scrubs", "neutral", None)
        if idx in (2, 3, 4, 14, 15, 16, 17):
            return ("operating_room", "scrubs", "neutral", solo("doc_emiko", "scrubs/neutral"))
        if 5 <= idx <= 13:
            return ("operating_room", "scrubs", "focused", solo("doc_emiko", "scrubs/focused"))
        if idx in (18, 19):
            return ("or_entrance", "scrubs", "neutral", None)

    # Scene 5: Half an hour later in the surgical doctors' office
    if sec == "s5":
        if idx in (1, 2, 3, 4):
            return ("shared_doctors_office", "white_coat", "neutral", None)
        if 16 <= idx <= 24:
            return ("shared_doctors_office", "white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
        return ("shared_doctors_office", "white_coat", "neutral", solo("doc_emiko", "white_coat/neutral"))

    # Scene 6: "No score today." & blue CABG notebook
    if sec == "s6":
        if idx in (10, 11, 12, 20, 21):
            return ("shared_doctors_office", "white_coat", "warm", solo("doc_emiko", "white_coat/warm"))
        if idx >= 22:
            return ("shared_doctors_office", "white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
        return ("shared_doctors_office", "white_coat", "neutral", solo("doc_emiko", "white_coat/neutral"))
    if sec == "c3a":
        expr = "warm" if idx >= 3 else "serious"
        return ("shared_doctors_office", "white_coat", expr, solo("doc_emiko", f"white_coat/{expr}"))
    if sec == "c3b":
        expr = "neutral" if idx >= 3 else "serious"
        return ("shared_doctors_office", "white_coat", expr, solo("doc_emiko", f"white_coat/{expr}"))
    if sec == "c3c":
        return ("shared_doctors_office", "white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
    if sec == "s6r":
        if idx in (1, 2):
            return ("shared_doctors_office", "white_coat", "smile", solo("doc_emiko", "white_coat/smile"))
        if idx in (3, 4, 5):
            return ("shared_doctors_office", "white_coat", "neutral", solo("doc_emiko", "white_coat/neutral"))
        return ("shared_doctors_office", "white_coat", "warm", solo("doc_emiko", "white_coat/warm"))

    raise ValueError(f"Unhandled node staging: {nid} ({sec})")


def parse_manuscript() -> tuple[list[dict], dict[str, str], int]:
    md = MANUSCRIPT_PATH.read_text(encoding="utf-8")
    sec2 = md.split("## 二、 完整中文 VN 剧本正文", 1)[1].split("**【御堂江美子 Relationship Lv3《今天我主刀》事件结束】**", 1)[0]

    section = ""
    in_meta = False
    counts: dict[str, int] = {}
    beats: list[dict] = []
    choices_zh: dict[str, str] = {}
    cur_choice = ""
    mixed_split_count = 0

    def push(sec: str, spk: str, txt: str) -> None:
        counts[sec] = counts.get(sec, 0) + 1
        nid = f"em3_{sec}_{counts[sec]:02d}"
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
        if not s or s == "---" or s.startswith("*性质：") or s.startswith("*(") or s.startswith("#### 3."):
            continue
        if s.startswith("#### 〈前置分支 S"):
            section = "s"
            continue
        if s.startswith("#### 〈前置分支 O"):
            section = "o"
            continue
        if s.startswith("#### 〈前置分支 G"):
            section = "g"
            continue
        m_ch = re.match(r"^\*\*【选择 (\d+)：.+】\*\*$", s)
        if m_ch:
            cur_choice = f"c{m_ch.group(1)}"
            continue
        m_opt = re.match(r"^- \*\*选项 ([ABC])：(.+)\*\*$", s)
        if m_opt:
            choices_zh[f"choice_em3_{cur_choice}_{m_opt.group(1).lower()}"] = m_opt.group(2)
            continue
        m_br = re.match(r"^#### 【分支 ([ABC]) — .+】$", s)
        if m_br:
            section = f"{cur_choice}{m_br.group(1).lower()}"
            continue
        if s.startswith("- **〈若前置为 S〉** "):
            rest = s.replace("- **〈若前置为 S〉** ", "", 1)
            m = re.match(r"^坂口隆司：(「.+」)$", rest)
            if not m:
                raise ValueError(f"Unexpected S line: {s}")
            push("c1a_s", "坂口隆司", m.group(1))
            continue
        if s.startswith("- **〈若前置为 O 或 G〉** "):
            rest = s.replace("- **〈若前置为 O 或 G〉** ", "", 1)
            m = re.match(r"^坂口隆司：(「.+」)$", rest)
            if not m:
                raise ValueError(f"Unexpected O/G line: {s}")
            push("c1a_og", "坂口隆司", m.group(1))
            continue
        if s.startswith("> **【主线汇合"):
            section = {"c1": "s1r", "c2": "s3r", "c3": "s6r"}[cur_choice]
            continue
        if section == "c1a" and counts.get("c1a_s"):
            section = "c1a_tail"

        m_pure = re.match(r"^(御堂江美子|坂口隆司|杉村弘子|本庄萌恵|寿司店师傅|患者|麻醉医生|灌注师)：(「.+」)$", s)
        if m_pure:
            txt = m_pure.group(2).replace("[最近非御堂一助医生]", "{recent_assistant_doctor}")
            push(section, m_pure.group(1), txt)
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

    return beats, choices_zh, mixed_split_count


def build_nodes(beats: list[dict], choices_zh: dict[str, str]) -> list[dict]:
    if len(beats) != 311:
        raise ValueError(f"Expected 311 beats, got {len(beats)}")

    by_sec: dict[str, list[dict]] = {}
    for b in beats:
        by_sec.setdefault(b["sec"], []).append(b)

    # Default sequential link inside each section, overridden at section boundaries.
    next_map: dict[str, str] = {}
    for sec, sec_beats in by_sec.items():
        for i in range(len(sec_beats) - 1):
            next_map[sec_beats[i]["id"]] = sec_beats[i + 1]["id"]

    # Cross-section transitions
    next_map["em3_s1_52"] = "em3_g_01"  # dynamically rewritten by emiko_lv3.gd to S / O / G
    next_map["em3_s_08"] = "em3_choice_c1"
    next_map["em3_o_08"] = "em3_choice_c1"
    next_map["em3_g_08"] = "em3_choice_c1"
    next_map["em3_c1a_04"] = "em3_c1a_og_01"  # dynamically rewritten by emiko_lv3.gd to S vs O/G
    next_map["em3_c1a_s_01"] = "em3_c1a_tail_01"
    next_map["em3_c1a_og_01"] = "em3_c1a_tail_01"
    next_map["em3_c1a_tail_02"] = "em3_s1r_01"
    next_map["em3_c1b_07"] = "em3_s1r_01"
    next_map["em3_c1c_07"] = "em3_s1r_01"
    next_map["em3_s1r_17"] = "em3_s2_01"
    next_map["em3_s2_33"] = "em3_s3_01"
    next_map["em3_s3_37"] = "em3_choice_c2"
    next_map["em3_c2a_05"] = "em3_s3r_01"
    next_map["em3_c2b_07"] = "em3_s3r_01"
    next_map["em3_c2c_05"] = "em3_s3r_01"
    next_map["em3_s3r_16"] = "em3_s4_01"
    next_map["em3_s4_19"] = "em3_s5_01"
    next_map["em3_s5_27"] = "em3_s6_01"
    next_map["em3_s6_28"] = "em3_choice_c3"
    next_map["em3_c3a_04"] = "em3_s6r_01"
    next_map["em3_c3b_04"] = "em3_s6r_01"
    next_map["em3_c3c_04"] = "em3_s6r_01"
    next_map["em3_s6r_07"] = "@end"

    choice_after: dict[str, dict] = {
        "em3_g_08": {
            "id": "em3_choice_c1",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": "doc_emiko",
            "text": "",
            "expression": "neutral",
            "outfit": "casual",
            "background_id": BG_ID_SUSHI,
            "event_portraits": solo("doc_emiko", "casual/neutral"),
            "choices": [
                {
                    "id": "choice_em3_c1_a",
                    "label": choices_zh["choice_em3_c1_a"],
                    "next": "em3_c1a_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em3_c1_b",
                    "label": choices_zh["choice_em3_c1_b"],
                    "next": "em3_c1b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em3_c1_c",
                    "label": choices_zh["choice_em3_c1_c"],
                    "next": "em3_c1c_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        "em3_s3_37": {
            "id": "em3_choice_c2",
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
                    "id": "choice_em3_c2_a",
                    "label": choices_zh["choice_em3_c2_a"],
                    "next": "em3_c2a_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em3_c2_b",
                    "label": choices_zh["choice_em3_c2_b"],
                    "next": "em3_c2b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em3_c2_c",
                    "label": choices_zh["choice_em3_c2_c"],
                    "next": "em3_c2c_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        "em3_s6_28": {
            "id": "em3_choice_c3",
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
                    "id": "choice_em3_c3_a",
                    "label": choices_zh["choice_em3_c3_a"],
                    "next": "em3_c3a_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em3_c3_b",
                    "label": choices_zh["choice_em3_c3_b"],
                    "next": "em3_c3b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em3_c3_c",
                    "label": choices_zh["choice_em3_c3_c"],
                    "next": "em3_c3c_01",
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
        cid = CABG_TEACHING_CHOICE_ID if nid == "em3_s3r_16" else f"continue_{nid}"
        end_flags = ["emiko_lv3_complete"] if nxt == "@end" else []
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
        if portraits is None:
            node["hide_portrait"] = True
        else:
            node["event_portraits"] = portraits
        choice_entry: dict = {
            "id": cid,
            "label": "继续",
            "next": nxt,
            "effects": {"affection": 0, "familiarity": 0},
            "flags": end_flags,
        }
        if nid == "em3_c1a_04":
            choice_entry["next_if_choice"] = {
                "choice_id": "continue_em3_s_08",
                "next": "em3_c1a_s_01",
            }
        node["choices"] = [choice_entry]
        nodes.append(node)
        if nid in choice_after:
            nodes.append(choice_after[nid])

    return nodes


def build_event(nodes: list[dict]) -> dict:
    return {
        "id": EVENT_ID,
        "actor_id": "doc_emiko",
        "title": "今天我主刀",
        "chapter": 3,
        "location_id": "shared_doctors_office",
        "trigger_mode": "after_work",
        "background_id": BG_ID_SUSHI,
        "outfit": "casual",
        "completion_background_id": "shared_doctors_office",
        "completion_outfit": "white_coat",
        "completion_expression": "warm",
        "hide_calendar_header": True,
        "minutes": 0,
        "completion_day_offset": 1,
        "completion_absolute_clock": 840,
        "teaser": "深夜寿司店吧台偶遇后，御堂江美子亲自点名坂口隆司担任次日清晨开胸心脏搭桥手术的第一助手。",
        "time_start": 960,
        "time_end": 1320,
        "priority": 185,
        "category": "rank_up",
        "gallery": {
            "cg_id": "cg_emiko_lv3_today_i_lead",
            "caption": "深夜寿司店吧台偶遇后的次日清晨，御堂江美子亲自点名坂口隆司担任开胸冠状动脉旁路移植术的第一助手，并在术后将私人搭桥手札推到他的面前。",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 40,
            "required_events": ["emiko_lv2_follow_my_lead"],
            "days_after_required_events": 3,
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "presence",
                    "minimum": 20,
                },
                {
                    "type": "staff_unlocked",
                    "actor_id": "doc_artoria",
                },
            ],
        },
        "auto_start": True,
        "locks_saving": True,
        "target_level": 3,
        "benefit_id": "",
        "completion_story_flags": [
            "emiko_lv3_complete",
            "emiko_cabg_teaching_complete",
        ],
        "start": "em3_s1_01",
        "nodes": nodes,
    }


def update_locales(event: dict, en_data: dict) -> tuple[int, int]:
    prefix = f"collections.character_events.{EVENT_ID}."
    bg_key = f"collections.backgrounds.{BG_ID_SUSHI}.label"

    zh_doc = json.loads(ZH_LOCALE_PATH.read_text(encoding="utf-8"))
    en_doc = json.loads(EN_LOCALE_PATH.read_text(encoding="utf-8"))
    zh_strings: dict[str, str] = zh_doc["strings"]
    en_strings: dict[str, str] = en_doc["strings"]

    for d in (zh_strings, en_strings):
        stale = [k for k in d if k.startswith(prefix)]
        for k in stale:
            del d[k]

    zh_new: dict[str, str] = {
        bg_key: "巷口小型寿司店·吧台",
        f"{prefix}title": event["title"],
        f"{prefix}teaser": event["teaser"],
        f"{prefix}gallery.caption": event["gallery"]["caption"],
    }
    en_new: dict[str, str] = {
        bg_key: en_data["background_label"],
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
            if cid.startswith("continue_") or cid == CABG_TEACHING_CHOICE_ID:
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

    beats, choices_zh, mixed_split_count = parse_manuscript()
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
        "choice_node_count": 3,
        "total_node_count": len(nodes),
        "localization_keys_written": {"zh_CN": zh_count, "en": en_count},
        "formatting_adjustments": [
            f"{mixed_split_count} mixed action+quote lines (`叙事动作前缀：「角色台词」`) split at `：` into adjacent verbatim narrator action beat + verbatim character dialogue beat so speaker nameplate displays accurately on spoken lines without adding or deleting any text.",
            "Stripped non-diegetic `- **选项 X：...**` and `- **〈若前置为 ...〉**` Markdown wrapper headers on interactive options and conditional Branch A lines.",
            "Mapped `[最近非御堂一助医生]` token in `em3_o_02` to `{recent_assistant_doctor}` placeholder for bilingual runtime substitution via `godot/systems/emiko_lv3.gd`.",
        ],
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Imported {EVENT_ID} V1.1: {len(nodes)} nodes ({len(beats)} beats + 3 choices); locales zh={zh_count}, en={en_count}.")


if __name__ == "__main__":
    main()
