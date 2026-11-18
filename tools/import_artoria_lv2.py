#!/usr/bin/env python3
"""Import Artoria Pendragon (`doc_artoria`) Relationship Lv2 milestone event:
《留下来的部分》 (The Part That Remains, ID: `artoria_lv2_what_remains`, V1.0).

Updates:
- data/staff/doc_artoria/profile.json
- data/staff/doc_artoria/assets_manifest.json
- data/staff/doc_artoria/bundle.json
- data/staff/doc_artoria/relationship.json
- data/staff/doc_artoria/lv2_events.json
- data/localization/zh_CN.json & data/localization/en.json
- research/imports/artoria_lv2_2026-11-16.json
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_ARTORIA_LV2_THE_PART_THAT_REMAINS_V1_0.md"
EN_TRANSLATION_PATH = ROOT / "research/translations/artoria_lv2_en.json"
STAFF_DIR = ROOT / "data/staff/doc_artoria"
PROFILE_PATH = STAFF_DIR / "profile.json"
ASSETS_MANIFEST_PATH = STAFF_DIR / "assets_manifest.json"
BUNDLE_PATH = STAFF_DIR / "bundle.json"
RELATIONSHIP_PATH = STAFF_DIR / "relationship.json"
EVENTS_PATH = STAFF_DIR / "lv2_events.json"
ZH_LOCALE_PATH = ROOT / "data/localization/zh_CN.json"
EN_LOCALE_PATH = ROOT / "data/localization/en.json"
IMPORT_MANIFEST_PATH = ROOT / "research/imports/artoria_lv2_2026-11-16.json"

EVENT_ID = "artoria_lv2_what_remains"
ACTOR_ID = "doc_artoria"

CAST_PORTRAITS = {
    ("doc_artoria", "white_coat/neutral"): "assets/characters/portrait_pack_v16/doc_artoria/white_coat/neutral.png",
    ("doc_artoria", "white_coat/serious"): "assets/characters/portrait_pack_v16/doc_artoria/white_coat/neutral.png",
    ("doc_artoria", "white_coat/smile"): "assets/characters/artoria_lv2_v1/doc_artoria/white_coat/smile.png",
    ("doc_artoria", "white_coat/warm"): "assets/characters/artoria_lv2_v1/doc_artoria/white_coat/smile.png",
    ("doc_artoria", "white_coat/embarrassed"): "assets/characters/artoria_lv2_v1/doc_artoria/white_coat/embarrassed.png",
    ("doc_artoria", "scrubs_masked/neutral"): "assets/characters/artoria_lv2_v1/doc_artoria/scrubs_masked/neutral.png",
    ("doc_artoria", "scrubs_masked/focused"): "assets/characters/artoria_lv2_v1/doc_artoria/scrubs_masked/focused.png",
    ("doc_artoria", "sterile/neutral"): "assets/characters/portrait_pack_v16/doc_artoria/sterile/neutral.png",
    ("doc_artoria", "sterile/focused"): "assets/characters/portrait_pack_v16/doc_artoria/sterile/neutral.png",
    ("nurse_yui", "sterile/neutral"): "assets/characters/sterile_pack_v1/nurse_yui/neutral.png",
    ("nurse_yui", "sterile/focused"): "assets/characters/sterile_pack_v1/nurse_yui/focused.png",
    ("nurse_yui", "sterile/warm"): "assets/characters/sterile_pack_v1/nurse_yui/warm.png",
    ("nurse_ange", "scrubs/neutral"): "assets/characters/portrait_pack_v11/nurse_ange/scrubs/neutral.png",
    ("nurse_ange", "scrubs/focused"): "assets/characters/portrait_pack_v11/nurse_ange/scrubs/focused.png",
    ("nurse_ange", "scrubs/warm"): "assets/characters/portrait_pack_v11/nurse_ange/scrubs/warm.png",
    ("story_guest_taiga_fujimura", "ward/laugh"): "assets/characters/artoria_lv2_v1/taiga_fujimura/ward/laugh.png",
    ("story_guest_taiga_fujimura", "ward/worried"): "assets/characters/artoria_lv2_v1/taiga_fujimura/ward/worried.png",
    ("story_guest_taiga_fujimura", "ward/smile"): "assets/characters/artoria_lv2_v1/taiga_fujimura/ward/smile.png",
    ("story_guest_taiga_fujimura", "or_cap/tense"): "assets/characters/artoria_lv2_v1/taiga_fujimura/or_cap/tense.png",
    ("story_guest_taiga_fujimura", "or_cap/drowsy"): "assets/characters/artoria_lv2_v1/taiga_fujimura/or_cap/drowsy.png",
    ("story_guest_taiga_fujimura", "or_cap/relieved"): "assets/characters/artoria_lv2_v1/taiga_fujimura/or_cap/relieved.png",
}

SPEAKER_MAP = {
    "旁白": ("narrator", "doc_artoria", "旁白"),
    "阿尔托莉雅·潘德拉贡": ("actor", "doc_artoria", "阿尔托莉雅·潘德拉贡"),
    "坂口隆司": ("player", "doc_artoria", "坂口隆司"),
    "藤村大河": ("actor", "doc_artoria", "藤村大河"),
    "朝倉美幸": ("actor", "nurse_yui", "朝倉美幸"),
    "利根川安琪": ("actor", "nurse_ange", "利根川安琪"),
}

# Ordered most-specific first so multi-character action prefixes attribute speech to the actual speaker.
MIXED_PREFIX_SPEAKERS = [
    ("利根川安琪立刻俯身轻声转达，头架布帘后传来藤村大河", "藤村大河"),
    ("头架布帘撤开时，刚从浅睡中睁开眼睛的藤村大河", "藤村大河"),
    ("站在床前的利根川安琪", "利根川安琪"),
    ("利根川安琪", "利根川安琪"),
    ("朝倉美幸", "朝倉美幸"),
    ("藤村大河", "藤村大河"),
    ("阿尔托莉雅", "阿尔托莉雅·潘德拉贡"),
    ("坂口隆司", "坂口隆司"),
]

CJK_RE = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, payload) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def solo_staff(actor_id: str, key: str, x: int = 985) -> list[dict]:
    return [
        {
            "id": actor_id,
            "path": CAST_PORTRAITS[(actor_id, key)],
            "x": x,
            "bottom": 556,
            "width": 320,
            "height": 480,
        }
    ]


def duo_staff(left_actor: str, left_key: str, right_actor: str, right_key: str) -> list[dict]:
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


def ward_taiga_solo(taiga_key: str) -> list[dict]:
    return [
        {
            "id": "taiga_fujimura",
            "path": CAST_PORTRAITS[("story_guest_taiga_fujimura", taiga_key)],
            "x": 440,
            "bottom": 556,
            "width": 320,
            "height": 480,
        }
    ]


def ward_taiga_and_artoria(taiga_key: str, artoria_key: str) -> list[dict]:
    return [
        {
            "id": "taiga_fujimura",
            "path": CAST_PORTRAITS[("story_guest_taiga_fujimura", taiga_key)],
            "x": 440,
            "bottom": 556,
            "width": 320,
            "height": 480,
        },
        {
            "id": "doc_artoria",
            "path": CAST_PORTRAITS[("doc_artoria", artoria_key)],
            "x": 985,
            "bottom": 556,
            "width": 320,
            "height": 480,
        },
    ]


def or_taiga_solo(taiga_key: str) -> list[dict]:
    return [
        {
            "id": "taiga_fujimura",
            "path": CAST_PORTRAITS[("story_guest_taiga_fujimura", taiga_key)],
            "x": 640,
            "bottom": 480,
            "width": 400,
            "height": 300,
        }
    ]


def or_taiga_with_staff(taiga_key: str, staff_actor: str, staff_key: str) -> list[dict]:
    return [
        {
            "id": "taiga_fujimura",
            "path": CAST_PORTRAITS[("story_guest_taiga_fujimura", taiga_key)],
            "x": 440,
            "bottom": 480,
            "width": 400,
            "height": 300,
        },
        {
            "id": staff_actor,
            "path": CAST_PORTRAITS[(staff_actor, staff_key)],
            "x": 985,
            "bottom": 556,
            "width": 320,
            "height": 480,
        },
    ]


def stage_for_node(nid: str, sec: str) -> tuple[str, str, str, list[dict] | None]:
    """Return (background_id, outfit, expression, event_portraits_or_None)."""
    idx = int(nid.rsplit("_", 1)[1])

    # Scene 1: 3F surgical single ward (Taiga preoperative visit)
    if sec == "s1":
        if idx == 1:
            return ("ward", "white_coat", "neutral", None)
        if idx in (2, 3):
            return ("ward", "white_coat", "neutral", ward_taiga_solo("ward/laugh"))
        if 4 <= idx <= 9:
            return ("ward", "white_coat", "neutral", ward_taiga_and_artoria("ward/laugh", "white_coat/neutral"))
        if idx in (10, 11):
            return ("ward", "white_coat", "neutral", ward_taiga_and_artoria("ward/smile", "white_coat/neutral"))
        if 12 <= idx <= 27:
            return ("ward", "white_coat", "neutral", ward_taiga_and_artoria("ward/worried", "white_coat/neutral"))
        if idx in (28, 29):
            return ("ward", "white_coat", "neutral", ward_taiga_and_artoria("ward/smile", "white_coat/neutral"))
        if idx in (30, 31):
            return ("ward", "white_coat", "smile", ward_taiga_and_artoria("ward/smile", "white_coat/smile"))
        return ("ward", "white_coat", "neutral", None)

    # Scene 2: Surgical doctors' office lightbox review
    if sec == "s2":
        if idx == 1:
            return ("shared_doctors_office", "white_coat", "neutral", None)
        return ("shared_doctors_office", "white_coat", "neutral", solo_staff("doc_artoria", "white_coat/neutral", x=1020))
    if sec == "c1a":
        expr = "smile" if idx >= 3 else "neutral"
        return ("shared_doctors_office", "white_coat", expr, solo_staff("doc_artoria", f"white_coat/{expr}", x=1020))
    if sec in ("c1b", "c1c"):
        return ("shared_doctors_office", "white_coat", "neutral", solo_staff("doc_artoria", "white_coat/neutral", x=1020))
    if sec == "s2r":
        expr = "smile" if idx in (6, 7) else "neutral"
        return ("shared_doctors_office", "white_coat", expr, solo_staff("doc_artoria", f"white_coat/{expr}", x=1020))

    # Scene 3: OR No. 1 — Epidural blockade (`scrubs_masked`) -> Scrub & gown -> Open left hepatectomy (`sterile`)
    if sec == "s3":
        if idx in (1, 2):
            return ("operating_room", "scrubs_masked", "neutral", None)
        if idx in (3, 4):
            return ("operating_room", "scrubs_masked", "neutral", or_taiga_solo("or_cap/tense"))
        if idx in (5, 6):
            return ("operating_room", "scrubs_masked", "neutral", or_taiga_with_staff("or_cap/tense", "nurse_ange", "scrubs/warm"))
        if idx in (7, 8):
            return ("operating_room", "scrubs_masked", "focused", or_taiga_with_staff("or_cap/tense", "doc_artoria", "scrubs_masked/focused"))
        if idx in (9, 10, 11):
            return ("operating_room", "scrubs_masked", "focused", or_taiga_with_staff("or_cap/relieved", "doc_artoria", "scrubs_masked/focused"))
        if 12 <= idx <= 15:
            return ("operating_room", "scrubs_masked", "neutral", or_taiga_with_staff("or_cap/relieved", "doc_artoria", "scrubs_masked/neutral"))
        if idx == 16:
            return ("operating_room", "scrubs_masked", "neutral", None)
        if idx == 17:
            return ("operating_room", "sterile", "neutral", duo_staff("nurse_yui", "sterile/warm", "nurse_ange", "scrubs/neutral"))
        if idx in (18, 19):
            return ("operating_room", "sterile", "focused", duo_staff("nurse_ange", "scrubs/focused", "doc_artoria", "sterile/focused"))
        if idx in (20, 21):
            return ("operating_room", "sterile", "focused", duo_staff("nurse_yui", "sterile/focused", "doc_artoria", "sterile/focused"))
        if 22 <= idx <= 25:
            return ("operating_room", "sterile", "focused", solo_staff("doc_artoria", "sterile/focused"))
        if idx == 26:
            return ("operating_room", "sterile", "neutral", duo_staff("nurse_ange", "scrubs/focused", "doc_artoria", "sterile/neutral"))
        if idx in (27, 28, 29):
            return ("operating_room", "sterile", "neutral", or_taiga_with_staff("or_cap/drowsy", "nurse_ange", "scrubs/warm"))
        if idx in (32, 33):
            return ("operating_room", "sterile", "focused", duo_staff("nurse_yui", "sterile/focused", "doc_artoria", "sterile/focused"))
        if idx == 34:
            return ("operating_room", "sterile", "focused", duo_staff("nurse_yui", "sterile/focused", "nurse_ange", "scrubs/focused"))
        if idx == 42:
            return ("operating_room", "sterile", "focused", duo_staff("nurse_yui", "sterile/warm", "doc_artoria", "sterile/focused"))
        return ("operating_room", "sterile", "focused", solo_staff("doc_artoria", "sterile/focused"))

    # Scene 4: Intraoperative ultrasound check & deep MHV tributary preservation
    if sec == "s4":
        if idx in (2, 3):
            return ("operating_room", "sterile", "focused", or_taiga_with_staff("or_cap/drowsy", "nurse_ange", "scrubs/focused"))
        if idx in (6, 7):
            return ("operating_room", "sterile", "focused", duo_staff("nurse_yui", "sterile/focused", "doc_artoria", "sterile/focused"))
        return ("operating_room", "sterile", "focused", solo_staff("doc_artoria", "sterile/focused", x=1020))
    if sec in ("c2a", "c2b"):
        return ("operating_room", "sterile", "focused", solo_staff("doc_artoria", "sterile/focused", x=1020))
    if sec == "c2c":
        if idx in (3, 4):
            return ("operating_room", "sterile", "focused", duo_staff("nurse_yui", "sterile/focused", "doc_artoria", "sterile/focused"))
        return ("operating_room", "sterile", "focused", solo_staff("doc_artoria", "sterile/focused", x=1020))
    if sec == "s4r":
        if idx in (4, 6):
            return ("operating_room", "sterile", "focused", duo_staff("nurse_yui", "sterile/focused", "doc_artoria", "sterile/focused"))
        if idx in (9, 10, 11):
            return ("operating_room", "sterile", "neutral", duo_staff("nurse_yui", "sterile/warm", "nurse_ange", "scrubs/warm"))
        if idx in (12, 13):
            return ("operating_room", "sterile", "neutral", or_taiga_with_staff("or_cap/drowsy", "nurse_ange", "scrubs/warm"))
        if idx in (14, 15):
            return ("operating_room", "sterile", "neutral", or_taiga_with_staff("or_cap/relieved", "doc_artoria", "sterile/neutral"))
        if idx in (16, 17):
            return ("operating_room", "sterile", "neutral", or_taiga_with_staff("or_cap/relieved", "doc_artoria", "sterile/neutral"))
        return ("operating_room", "sterile", "focused", solo_staff("doc_artoria", "sterile/focused"))

    # Scene 5: Postoperative review, liver resection teaching handout, and skipped lunch
    if sec == "s5":
        if idx == 1:
            return ("shared_doctors_office", "white_coat", "neutral", None)
        if idx in (13, 14, 15, 18, 19):
            return ("shared_doctors_office", "white_coat", "smile", solo_staff("doc_artoria", "white_coat/smile", x=1020))
        if idx >= 29:
            return ("shared_doctors_office", "white_coat", "embarrassed", solo_staff("doc_artoria", "white_coat/embarrassed", x=1020))
        return ("shared_doctors_office", "white_coat", "neutral", solo_staff("doc_artoria", "white_coat/neutral", x=1020))
    if sec == "c3a":
        expr = "embarrassed" if idx >= 3 else "neutral"
        return ("shared_doctors_office", "white_coat", expr, solo_staff("doc_artoria", f"white_coat/{expr}", x=1020))
    if sec == "c3b":
        if idx == 3:
            return ("shared_doctors_office", "white_coat", "smile", solo_staff("doc_artoria", "white_coat/smile", x=1020))
        if idx >= 4:
            return ("shared_doctors_office", "white_coat", "embarrassed", solo_staff("doc_artoria", "white_coat/embarrassed", x=1020))
        return ("shared_doctors_office", "white_coat", "neutral", solo_staff("doc_artoria", "white_coat/neutral", x=1020))
    if sec == "c3c":
        expr = "embarrassed" if idx >= 3 else "neutral"
        return ("shared_doctors_office", "white_coat", expr, solo_staff("doc_artoria", f"white_coat/{expr}", x=1020))
    if sec == "s5r":
        if idx == 1:
            return ("shared_doctors_office", "white_coat", "neutral", solo_staff("doc_artoria", "white_coat/neutral", x=1020))
        return ("shared_doctors_office", "white_coat", "smile", None)

    raise ValueError(f"Unhandled node staging: {nid} ({sec})")


def parse_manuscript() -> tuple[list[dict], dict[str, str], int, int]:
    md = MANUSCRIPT_PATH.read_text(encoding="utf-8")
    body = md.split("## 二、 完整中文 VN 剧本正文", 1)[1].split(
        "**【阿尔托莉雅·潘德拉贡 Relationship Lv2《留下来的部分》事件结束】**", 1
    )[0]

    section = ""
    active = False
    cur_choice = ""
    counts: dict[str, int] = {}
    beats: list[dict] = []
    choices_zh: dict[str, str] = {}
    mixed_split_count = 0
    bold_strip_count = 0

    def push(sec: str, spk: str, txt: str) -> None:
        counts[sec] = counts.get(sec, 0) + 1
        nid = f"ar2_{sec}_{counts[sec]:02d}"
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

    for raw in body.splitlines():
        s = raw.strip()
        if not s or s == "---":
            continue
        if s.startswith("### 【第一幕"):
            section = "s1"
            active = False
            continue
        if s.startswith("### 【第二幕"):
            section = "s2"
            active = False
            continue
        if s.startswith("### 【第三幕"):
            section = "s3"
            active = False
            continue
        if s.startswith("### 【第四幕"):
            section = "s4"
            active = False
            continue
        if s.startswith("### 【第五幕"):
            section = "s5"
            active = False
            continue
        if s == "**【玩家可见正文】**":
            active = True
            continue
        m_ch = re.match(r"^\*\*【选择 (\d+)：.+】\*\*$", s)
        if m_ch:
            cur_choice = f"c{m_ch.group(1)}"
            active = False
            continue
        m_opt = re.match(r"^- \*\*选项 ([ABC])：(.+)\*\*$", s)
        if m_opt:
            choices_zh[f"choice_ar2_{cur_choice}_{m_opt.group(1).lower()}"] = m_opt.group(2)
            continue
        m_br = re.match(r"^#### 【分支 ([ABC])\b", s)
        if m_br:
            section = f"{cur_choice}{m_br.group(1).lower()}"
            active = True
            continue
        if s.startswith("> **【主线汇合"):
            section = {"c1": "s2r", "c2": "s4r", "c3": "s5r"}[cur_choice]
            active = True
            continue
        if not active or s.startswith("*(【设计锚点提示】"):
            continue

        m_pure = re.match(r"^(阿尔托莉雅·潘德拉贡|坂口隆司|藤村大河|朝倉美幸|利根川安琪)：(「.*」)$", s)
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

        if "**" in s:
            bold_strip_count += 1
            s = s.replace("**", "")
        push(section, "旁白", s)

    return beats, choices_zh, mixed_split_count, bold_strip_count


def build_nodes(beats: list[dict], choices_zh: dict[str, str]) -> list[dict]:
    if len(beats) != 224:
        raise ValueError(f"Expected 224 beats, got {len(beats)}")

    by_sec: dict[str, list[dict]] = {}
    for b in beats:
        by_sec.setdefault(b["sec"], []).append(b)

    next_map: dict[str, str] = {}
    for sec, sec_beats in by_sec.items():
        for i in range(len(sec_beats) - 1):
            next_map[sec_beats[i]["id"]] = sec_beats[i + 1]["id"]

    # Section & choice routing
    next_map["ar2_s1_33"] = "ar2_s2_01"
    next_map["ar2_s2_19"] = "ar2_choice_c1"
    next_map["ar2_c1a_04"] = "ar2_s2r_01"
    next_map["ar2_c1b_04"] = "ar2_s2r_01"
    next_map["ar2_c1c_04"] = "ar2_s2r_01"
    next_map["ar2_s2r_09"] = "ar2_s3_01"
    next_map["ar2_s3_48"] = "ar2_s4_01"
    next_map["ar2_s4_21"] = "ar2_choice_c2"
    next_map["ar2_c2a_04"] = "ar2_s4r_01"
    next_map["ar2_c2b_04"] = "ar2_s4r_01"
    next_map["ar2_c2c_05"] = "ar2_s4r_01"
    next_map["ar2_s4r_17"] = "ar2_s5_01"
    next_map["ar2_s5_32"] = "ar2_choice_c3"
    next_map["ar2_c3a_06"] = "ar2_s5r_01"
    next_map["ar2_c3b_06"] = "ar2_s5r_01"
    next_map["ar2_c3c_04"] = "ar2_s5r_01"
    next_map["ar2_s5r_04"] = "@end"

    choice_after: dict[str, dict] = {
        "ar2_s2_19": {
            "id": "ar2_choice_c1",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": ACTOR_ID,
            "text": "",
            "expression": "neutral",
            "outfit": "white_coat",
            "background_id": "shared_doctors_office",
            "event_portraits": solo_staff("doc_artoria", "white_coat/neutral", x=1020),
            "choices": [
                {
                    "id": "choice_ar2_c1_a",
                    "label": choices_zh["choice_ar2_c1_a"],
                    "next": "ar2_c1a_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar2_c1_b",
                    "label": choices_zh["choice_ar2_c1_b"],
                    "next": "ar2_c1b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar2_c1_c",
                    "label": choices_zh["choice_ar2_c1_c"],
                    "next": "ar2_c1c_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        "ar2_s4_21": {
            "id": "ar2_choice_c2",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": ACTOR_ID,
            "text": "",
            "expression": "focused",
            "outfit": "sterile",
            "background_id": "operating_room",
            "event_portraits": solo_staff("doc_artoria", "sterile/focused", x=1020),
            "choices": [
                {
                    "id": "choice_ar2_c2_a",
                    "label": choices_zh["choice_ar2_c2_a"],
                    "next": "ar2_c2a_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar2_c2_b",
                    "label": choices_zh["choice_ar2_c2_b"],
                    "next": "ar2_c2b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar2_c2_c",
                    "label": choices_zh["choice_ar2_c2_c"],
                    "next": "ar2_c2c_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        "ar2_s5_32": {
            "id": "ar2_choice_c3",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": ACTOR_ID,
            "text": "",
            "expression": "embarrassed",
            "outfit": "white_coat",
            "background_id": "shared_doctors_office",
            "event_portraits": solo_staff("doc_artoria", "white_coat/embarrassed", x=1020),
            "choices": [
                {
                    "id": "choice_ar2_c3_a",
                    "label": choices_zh["choice_ar2_c3_a"],
                    "next": "ar2_c3a_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar2_c3_b",
                    "label": choices_zh["choice_ar2_c3_b"],
                    "next": "ar2_c3b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar2_c3_c",
                    "label": choices_zh["choice_ar2_c3_c"],
                    "next": "ar2_c3c_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
    }

    nodes: list[dict] = []
    for b in beats:
        nid = b["id"]
        bg, outfit, expr, portraits = stage_for_node(nid, b["sec"])
        node: dict = {
            "id": nid,
            "presentation": "authored",
            "speaker": b["role"],
            "speaker_label": b["speaker_label"],
            "actor_id": b["actor_id"],
            "text": b["text"],
            "expression": expr,
            "outfit": outfit,
            "background_id": bg,
        }
        if portraits is None:
            node["hide_portrait"] = True
        else:
            node["event_portraits"] = portraits
        node["choices"] = [
            {
                "id": f"continue_{nid}",
                "label": "继续",
                "next": next_map[nid],
                "effects": {"affection": 0, "familiarity": 0},
                "flags": [],
            }
        ]
        nodes.append(node)
        if nid in choice_after:
            nodes.append(choice_after[nid])

    return nodes


def update_staff_files() -> None:
    profile = read_json(PROFILE_PATH)
    outfits: list = profile["visuals"]["outfits"]
    if "scrubs_masked" not in outfits:
        scrubs_idx = outfits.index("scrubs") + 1 if "scrubs" in outfits else len(outfits)
        outfits.insert(scrubs_idx, "scrubs_masked")
    portraits: dict = profile["visuals"]["portraits"]
    portraits["white_coat/smile"] = "assets/characters/artoria_lv2_v1/doc_artoria/white_coat/smile.png"
    portraits["white_coat/warm"] = "assets/characters/artoria_lv2_v1/doc_artoria/white_coat/smile.png"
    portraits["white_coat/embarrassed"] = "assets/characters/artoria_lv2_v1/doc_artoria/white_coat/embarrassed.png"
    portraits["scrubs_masked/neutral"] = "assets/characters/artoria_lv2_v1/doc_artoria/scrubs_masked/neutral.png"
    portraits["scrubs_masked/focused"] = "assets/characters/artoria_lv2_v1/doc_artoria/scrubs_masked/focused.png"
    write_json(PROFILE_PATH, profile)

    manifest = read_json(ASSETS_MANIFEST_PATH)
    existing_ids = {item["id"] for item in manifest.get("assets", [])}
    new_assets = [
        ("portrait_doc_artoria_white_coat_smile", "assets/characters/artoria_lv2_v1/doc_artoria/white_coat/smile.png", "Artoria Lv2 gentle dignified smile portrait"),
        ("portrait_doc_artoria_white_coat_embarrassed", "assets/characters/artoria_lv2_v1/doc_artoria/white_coat/embarrassed.png", "Artoria Lv2 deadpan blush portrait (skipped-lunch scene)"),
        ("portrait_doc_artoria_scrubs_masked_neutral", "assets/characters/artoria_lv2_v1/doc_artoria/scrubs_masked/neutral.png", "Artoria Lv2 pre-gown epidural anesthesia attire (tie-on mask + sterile gloves)"),
        ("portrait_doc_artoria_scrubs_masked_focused", "assets/characters/artoria_lv2_v1/doc_artoria/scrubs_masked/focused.png", "Artoria Lv2 pre-gown epidural anesthesia focused variant"),
    ]
    for aid, apath, notes in new_assets:
        if aid not in existing_ids:
            manifest["assets"].append(
                {
                    "id": aid,
                    "category": "character_portrait",
                    "path": apath,
                    "status": "integrated",
                    "runtime_connected": True,
                    "trigger": EVENT_ID,
                    "notes": notes,
                }
            )
    write_json(ASSETS_MANIFEST_PATH, manifest)

    bundle = read_json(BUNDLE_PATH)
    extras = bundle.setdefault("additional_character_event_files", [])
    if "lv2_events.json" not in extras:
        extras.append("lv2_events.json")
    write_json(BUNDLE_PATH, bundle)

    rel = read_json(RELATIONSHIP_PATH)
    slot2 = next(s for s in rel["rank_slots"] if s["target_level"] == 2)
    slot2["event_id"] = EVENT_ID
    slot2["content_status"] = "authored"
    write_json(RELATIONSHIP_PATH, rel)


def update_localization(event_obj: dict, en_data: dict) -> None:
    zh = read_json(ZH_LOCALE_PATH)
    en = read_json(EN_LOCALE_PATH)
    zh_strings: dict = zh["strings"]
    en_strings: dict = en["strings"]
    prefix = f"collections.character_events.{EVENT_ID}."

    for store in (zh_strings, en_strings):
        for k in [key for key in store if key.startswith(prefix)]:
            del store[k]

    zh_strings[prefix + "title"] = event_obj["title"]
    zh_strings[prefix + "teaser"] = event_obj["teaser"]
    zh_strings[prefix + "gallery.caption"] = event_obj["gallery"]["caption"]

    en_strings[prefix + "title"] = en_data["title"]
    en_strings[prefix + "teaser"] = en_data["teaser"]
    en_strings[prefix + "gallery.caption"] = en_data["gallery_caption"]

    speakers_en = en_data["speakers"]
    nodes_en = en_data["nodes"]
    choices_en = en_data["choices"]

    for node in event_obj["nodes"]:
        nid = node["id"]
        np = f"{prefix}nodes.{nid}."
        if node["text"]:
            zh_strings[np + "text"] = node["text"]
            en_txt = nodes_en[nid]
            if CJK_RE.search(en_txt):
                raise ValueError(f"CJK character found in English translation for {nid}: {en_txt}")
            en_strings[np + "text"] = en_txt
        zh_strings[np + "speaker_label"] = node["speaker_label"]
        en_strings[np + "speaker_label"] = speakers_en[node["speaker_label"]]
        for ch in node["choices"]:
            cid = ch["id"]
            zh_strings[f"{np}choices.{cid}.label"] = ch["label"]
            if cid.startswith("continue_"):
                en_strings[f"{np}choices.{cid}.label"] = "Continue"
            else:
                en_lbl = choices_en[cid]
                if CJK_RE.search(en_lbl):
                    raise ValueError(f"CJK character found in English choice {cid}: {en_lbl}")
                en_strings[f"{np}choices.{cid}.label"] = en_lbl

    write_json(ZH_LOCALE_PATH, zh)
    write_json(EN_LOCALE_PATH, en)


def main() -> None:
    for (_, key), rel_path in CAST_PORTRAITS.items():
        full = ROOT / rel_path
        if not full.is_file():
            raise FileNotFoundError(f"Missing portrait for {key}: {full}")

    beats, choices_zh, mixed_splits, bold_strips = parse_manuscript()
    nodes = build_nodes(beats, choices_zh)
    en_data = read_json(EN_TRANSLATION_PATH)

    event_obj = {
        "id": EVENT_ID,
        "actor_id": ACTOR_ID,
        "title": "留下来的部分",
        "chapter": 2,
        "location_id": "shared_doctors_office",
        "trigger_mode": "after_work",
        "background_id": "ward",
        "outfit": "white_coat",
        "completion_background_id": "shared_doctors_office",
        "completion_outfit": "white_coat",
        "completion_expression": "smile",
        "hide_calendar_header": True,
        "minutes": 0,
        "completion_day_offset": 1,
        "completion_absolute_clock": 840,
        "teaser": "担任择期开腹左半肝切除术第一助手，近距离见证阿尔托莉雅·潘德拉贡的肝胆外科刀锋与手术哲学。",
        "time_start": 960,
        "time_end": 1320,
        "priority": 182,
        "category": "rank_up",
        "gallery": {
            "cg_id": "cg_artoria_lv2_what_remains",
            "caption": "在择期开腹左半肝切除术的无影灯下，坂口隆司亲眼见证了阿尔托莉雅守护「留下来的部分」的顶尖刀法与医者信念。",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "max_day": 363,
            "min_affection": 0,
            "min_familiarity": 25,
            "required_events": [
                "artoria_lv1_right_position"
            ],
            "days_after_required_events": 3,
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "leadership",
                    "minimum": 70
                }
            ]
        },
        "auto_start": True,
        "locks_saving": True,
        "target_level": 2,
        "benefit_id": "",
        "completion_story_flags": [
            "artoria_lv2_complete",
            "artoria_major_liver_resection_teaching_complete"
        ],
        "start": "ar2_s1_01",
        "nodes": nodes,
    }

    update_staff_files()
    from artoria_cg_mapping import apply_cg_mapping
    apply_cg_mapping(event_obj)
    write_json(EVENTS_PATH, [event_obj])
    update_localization(event_obj, en_data)

    import_manifest = {
        "event_id": EVENT_ID,
        "actor_id": ACTOR_ID,
        "target_level": 2,
        "unlocked_procedure_id": "surgery_open_major_liver_resection",
        "source_manuscript": str(MANUSCRIPT_PATH.relative_to(ROOT)),
        "source_sha256": sha256_of(MANUSCRIPT_PATH),
        "en_translation": str(EN_TRANSLATION_PATH.relative_to(ROOT)),
        "en_translation_sha256": sha256_of(EN_TRANSLATION_PATH),
        "events_file": str(EVENTS_PATH.relative_to(ROOT)),
        "events_sha256": sha256_of(EVENTS_PATH),
        "beat_count": len(beats),
        "node_count": len(nodes),
        "choice_count": len(choices_zh),
        "mixed_action_quote_splits": mixed_splits,
        "markdown_bold_syntax_strips": bold_strips,
        "story_guest": {
            "id": "story_guest_taiga_fujimura",
            "name": "藤村大河",
            "age": 25,
            "random_pool": False,
            "surgery_queue": False,
        },
        "runtime_portraits": {
            f"{a}:{k}": {"path": p, "sha256": sha256_of(ROOT / p)}
            for (a, k), p in sorted(CAST_PORTRAITS.items())
        },
    }
    write_json(IMPORT_MANIFEST_PATH, import_manifest)
    print(
        f"Imported {EVENT_ID}: {len(beats)} beats, {len(nodes)} nodes, "
        f"{mixed_splits} mixed splits, {bold_strips} bold strip(s)."
    )


if __name__ == "__main__":
    main()
