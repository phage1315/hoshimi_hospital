#!/usr/bin/env python3
"""Import Artoria Pendragon (`doc_artoria`) Relationship Lv4 milestone event:
《只是阿尔托莉雅》 (Just Artoria, ID: `artoria_lv4_just_artoria`, V1.1).

Strictly preserves the inline Chinese VN manuscript V1.1 verbatim in wording,
speaker attribution, punctuation, and order across all 27 choice paths,
applying ONLY the 2 explicit user-authorized outfit-word micro-adjustments
matching `taiga_casual_seed.png` and `irisviel_casual_seed.png`.
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EVENT_ID = "artoria_lv4_just_artoria"
ACTOR_ID = "doc_artoria"

MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_ARTORIA_LV4_JUST_ARTORIA_V1_1.md"
EN_TRANSLATION_PATH = ROOT / "research/translations/artoria_lv4_en.json"
EVENTS_PATH = ROOT / "data/staff/doc_artoria/lv4_events.json"
PROFILE_PATH = ROOT / "data/staff/doc_artoria/profile.json"
ASSETS_MANIFEST_PATH = ROOT / "data/staff/doc_artoria/assets_manifest.json"
BUNDLE_PATH = ROOT / "data/staff/doc_artoria/bundle.json"
RELATIONSHIP_PATH = ROOT / "data/staff/doc_artoria/relationship.json"
ZH_LOCALE_PATH = ROOT / "data/localization/zh_CN.json"
EN_LOCALE_PATH = ROOT / "data/localization/en.json"
IMPORT_MANIFEST_PATH = ROOT / "research/imports/artoria_lv4_2026-11-16.json"
CANDIDATE_MANIFEST_PATH = ROOT / "research/generated_candidates/artoria_lv4_v1/manifest.json"
CANDIDATE_PROMPTS_PATH = ROOT / "research/generated_candidates/artoria_lv4_v1/prompts.json"

CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")

# User-authorized outfit-word micro-adjustments (2026-11-16) aligning manuscript
# clothing descriptions with Codex's `taiga_casual_seed.png` & `irisviel_casual_seed.png`.
AUTHORIZED_OUTFIT_ADJUSTMENTS: dict[str, str] = {
    "等两人走近，大河先朝屋里喊了一声“代理师范盯着点，谁偷懒我回来加练二十下”，随后喜滋滋地迎下台阶，还特意拍了拍自己宽松的衬衫外套以示清白：": (
        "等两人走近，大河先朝屋里喊了一声“代理师范盯着点，谁偷懒我回来加练二十下”，随后喜滋滋地迎下台阶，还特意拍了拍自己宽松的开衫外套以示清白："
    ),
    "穿着浅色针织长衫的爱丽丝菲尔·冯·爱因兹贝伦正坐在敞轩边的软垫上晒着柔和的午后阳光。看见侍者引着两人走过木廊，她立刻微笑着迎起身来：": (
        "穿着深酒红色长袖上衣与白色长裙的爱丽丝菲尔·冯·爱因兹贝伦正坐在敞轩边的软垫上晒着柔和的午后阳光。看见侍者引着两人走过木廊，她立刻微笑着迎起身来："
    ),
}

CAST_PORTRAITS: dict[tuple[str, str], str] = {
    ("doc_artoria", "lv4_outing/neutral"): "assets/characters/artoria_lv4_v1/doc_artoria/lv4_outing/neutral.png",
    ("doc_artoria", "lv4_outing/smile"): "assets/characters/artoria_lv4_v1/doc_artoria/lv4_outing/smile.png",
    ("doc_artoria", "lv4_outing/sparkle"): "assets/characters/artoria_lv4_v1/doc_artoria/lv4_outing/sparkle.png",
    ("doc_artoria", "lv4_outing/shy"): "assets/characters/artoria_lv4_v1/doc_artoria/lv4_outing/shy.png",
    ("doc_artoria", "lv4_home/neutral"): "assets/characters/artoria_lv4_v1/doc_artoria/lv4_home/neutral.png",
    ("doc_artoria", "lv4_home/smile"): "assets/characters/artoria_lv4_v1/doc_artoria/lv4_home/smile.png",
    ("doc_artoria", "lv4_home/shy"): "assets/characters/artoria_lv4_v1/doc_artoria/lv4_home/shy.png",
    ("doc_artoria", "lv4_home/soft"): "assets/characters/artoria_lv4_v1/doc_artoria/lv4_home/soft.png",
    ("doc_artoria", "lv4_apron/serious_blush"): "assets/characters/artoria_lv4_v1/doc_artoria/lv4_apron/serious_blush.png",
    ("doc_artoria", "lv4_apron/embarrassed"): "assets/characters/artoria_lv4_v1/doc_artoria/lv4_apron/embarrassed.png",
    ("doc_artoria", "lv4_morning/neutral"): "assets/characters/artoria_lv4_v1/doc_artoria/lv4_morning/neutral.png",
    ("doc_artoria", "lv4_morning/sparkle"): "assets/characters/artoria_lv4_v1/doc_artoria/lv4_morning/sparkle.png",
    ("doc_artoria", "lv4_morning/serious"): "assets/characters/artoria_lv4_v1/doc_artoria/lv4_morning/serious.png",
    ("doc_artoria", "lv4_morning/smile"): "assets/characters/artoria_lv4_v1/doc_artoria/lv4_morning/smile.png",
    ("story_guest_taiga_fujimura", "casual/smile"): "assets/characters/artoria_lv4_v1/taiga_fujimura/casual/smile.png",
    ("story_guest_taiga_fujimura", "casual/laugh"): "assets/characters/artoria_lv4_v1/taiga_fujimura/casual/laugh.png",
    ("story_guest_taiga_fujimura", "casual/grateful"): "assets/characters/artoria_lv4_v1/taiga_fujimura/casual/grateful.png",
    ("story_guest_irisviel", "casual/smile"): "assets/characters/artoria_lv4_v1/irisviel/casual/smile.png",
    ("story_guest_irisviel", "casual/warm"): "assets/characters/artoria_lv4_v1/irisviel/casual/warm.png",
}

BACKGROUND_STRINGS: list[tuple[str, str, str, str]] = [
    ("artoria_lv4_station_clock_day", "车站南口·钟塔林荫街角", "Station South Exit · Clock Tower Avenue", "assets/backgrounds/artoria_lv4_v1/station_clock_day.png"),
    ("artoria_lv4_dojo_exterior_day", "藤村剑道场·门前外廊", "Fujimura Kendo Dojo · Front Veranda", "assets/backgrounds/artoria_lv4_v1/dojo_exterior_day.png"),
    ("artoria_lv4_takeyatei_teishoku_day", "街坊日式定食屋·竹叶亭", "Neighborhood Diner · Takeyatei", "assets/backgrounds/artoria_lv4_v1/takeyatei_teishoku_day.png"),
    ("artoria_lv4_garden_teahouse_day", "城郊静谧庭园茶室·敞轩雅座", "Suburban Garden Teahouse · Open Pavilion", "assets/backgrounds/artoria_lv4_v1/garden_teahouse_day.png"),
    ("artoria_lv4_riverside_sunset", "星见川河岸步道·傍晚", "Hoshimi River Promenade · Sunset", "assets/backgrounds/artoria_lv4_v1/riverside_sunset.png"),
    ("artoria_home_living_night", "阿尔托莉雅自宅·客厅（夜间）", "Artoria's Apartment · Living Room (Night)", "assets/backgrounds/artoria_lv4_v1/artoria_home_living_night.png"),
    ("artoria_home_bedroom_night", "阿尔托莉雅自宅·卧室（夜间）", "Artoria's Apartment · Bedroom (Night)", "assets/backgrounds/artoria_lv4_v1/artoria_home_bedroom_night.png"),
    ("artoria_home_kitchen_morning", "阿尔托莉雅自宅·厨房与窗边餐桌（清晨）", "Artoria's Apartment · Kitchen & Dining Table (Morning)", "assets/backgrounds/artoria_lv4_v1/artoria_home_kitchen_morning.png"),
]

SPEAKER_MAP = {
    "旁白": ("narrator", "doc_artoria", "旁白"),
    "阿尔托莉雅·潘德拉贡": ("actor", "doc_artoria", "阿尔托莉雅·潘德拉贡"),
    "坂口隆司": ("player", "doc_artoria", "坂口隆司"),
    "藤村大河": ("actor", "doc_artoria", "藤村大河"),
    "爱丽丝菲尔·冯·爱因兹贝伦": ("actor", "doc_artoria", "爱丽丝菲尔·冯·爱因兹贝伦"),
}

PURE_SPEAKERS = [
    "阿尔托莉雅·潘德拉贡",
    "坂口隆司",
    "藤村大河",
    "爱丽丝菲尔·冯·爱因兹贝伦",
]

MIXED_PREFIX_SPEAKERS: list[tuple[str, str]] = [
    ("坂口隆司", "坂口隆司"),
    ("他迎着", "坂口隆司"),
    ("他看着", "坂口隆司"),
    ("看着她", "坂口隆司"),
    ("对面的藤村大河", "藤村大河"),
    ("藤村大河", "藤村大河"),
    ("爱丽丝菲尔", "爱丽丝菲尔·冯·爱因兹贝伦"),
    ("阿尔托莉雅", "阿尔托莉雅·潘德拉贡"),
]


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def solo_artoria(key: str, x: int = 985) -> list[dict]:
    return [
        {
            "id": "doc_artoria",
            "path": CAST_PORTRAITS[("doc_artoria", key)],
            "x": x,
            "bottom": 556,
            "width": 320,
            "height": 480,
        }
    ]


def solo_guest(guest_id: str, guest_actor: str, key: str, x: int = 640) -> list[dict]:
    return [
        {
            "id": guest_id,
            "path": CAST_PORTRAITS[(guest_actor, key)],
            "x": x,
            "bottom": 556,
            "width": 320,
            "height": 480,
        }
    ]


def duo_guest_artoria(guest_id: str, guest_actor: str, guest_key: str, artoria_key: str) -> list[dict]:
    return [
        {
            "id": guest_id,
            "path": CAST_PORTRAITS[(guest_actor, guest_key)],
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


def stage_for_node(nid: str, sec: str) -> tuple[str, str, str, list[dict] | None]:
    """Return (background_id, outfit, expression, event_portraits_or_None)."""
    idx = int(nid.rsplit("_", 1)[1])

    # Act 1: Station clock-tower avenue (10:50 AM)
    if sec == "s1":
        bg = "artoria_lv4_station_clock_day"
        if idx in (1, 2):
            return (bg, "lv4_outing", "neutral", None)
        if idx == 3:
            return (bg, "lv4_outing", "neutral", solo_artoria("lv4_outing/neutral"))
        if idx in (4, 5, 6, 7):
            return (bg, "lv4_outing", "smile", solo_artoria("lv4_outing/smile"))
        if idx in (8, 9):
            return (bg, "lv4_outing", "shy", solo_artoria("lv4_outing/shy"))
        if idx in (10, 11, 12, 13, 14, 15):
            return (bg, "lv4_outing", "neutral", solo_artoria("lv4_outing/neutral"))
        if idx == 16:
            return (bg, "lv4_outing", "shy", solo_artoria("lv4_outing/shy"))
        return (bg, "lv4_outing", "smile", solo_artoria("lv4_outing/smile"))

    # Act 2: Fujimura Dojo exterior -> Takeyatei teishoku diner
    if sec == "s2":
        if idx == 1:
            return ("artoria_lv4_dojo_exterior_day", "lv4_outing", "neutral", None)
        if idx in (2, 3, 4, 5):
            return ("artoria_lv4_dojo_exterior_day", "lv4_outing", "smile", duo_guest_artoria("taiga_fujimura", "story_guest_taiga_fujimura", "casual/laugh", "lv4_outing/smile"))
        if idx in (6, 7):
            return ("artoria_lv4_dojo_exterior_day", "lv4_outing", "smile", duo_guest_artoria("taiga_fujimura", "story_guest_taiga_fujimura", "casual/smile", "lv4_outing/smile"))
        if idx in (8, 9):
            return ("artoria_lv4_dojo_exterior_day", "lv4_outing", "smile", duo_guest_artoria("taiga_fujimura", "story_guest_taiga_fujimura", "casual/laugh", "lv4_outing/smile"))
        bg = "artoria_lv4_takeyatei_teishoku_day"
        if idx == 10:
            return (bg, "lv4_outing", "neutral", None)
        if idx in (11, 12):
            return (bg, "lv4_outing", "neutral", duo_guest_artoria("taiga_fujimura", "story_guest_taiga_fujimura", "casual/laugh", "lv4_outing/neutral"))
        if idx in (13, 14):
            return (bg, "lv4_outing", "neutral", None)
        if idx in (15, 16, 17, 18, 19):
            return (bg, "lv4_outing", "sparkle", solo_artoria("lv4_outing/sparkle"))
        if idx in (20, 21):
            return (bg, "lv4_outing", "sparkle", duo_guest_artoria("taiga_fujimura", "story_guest_taiga_fujimura", "casual/laugh", "lv4_outing/sparkle"))
        return (bg, "lv4_outing", "shy", duo_guest_artoria("taiga_fujimura", "story_guest_taiga_fujimura", "casual/smile", "lv4_outing/shy"))

    if sec == "c1a":
        bg = "artoria_lv4_takeyatei_teishoku_day"
        if idx in (1, 2):
            return (bg, "lv4_outing", "shy", solo_artoria("lv4_outing/shy"))
        if idx in (3, 4):
            return (bg, "lv4_outing", "sparkle", solo_artoria("lv4_outing/sparkle"))
        return (bg, "lv4_outing", "shy", duo_guest_artoria("taiga_fujimura", "story_guest_taiga_fujimura", "casual/laugh", "lv4_outing/shy"))

    if sec == "c1b":
        bg = "artoria_lv4_takeyatei_teishoku_day"
        if idx in (1, 2, 3, 4):
            return (bg, "lv4_outing", "smile", duo_guest_artoria("taiga_fujimura", "story_guest_taiga_fujimura", "casual/laugh", "lv4_outing/smile"))
        return (bg, "lv4_outing", "shy", duo_guest_artoria("taiga_fujimura", "story_guest_taiga_fujimura", "casual/smile", "lv4_outing/shy"))

    if sec == "c1c":
        bg = "artoria_lv4_takeyatei_teishoku_day"
        if idx in (1, 2):
            return (bg, "lv4_outing", "sparkle", solo_artoria("lv4_outing/sparkle"))
        return (bg, "lv4_outing", "smile", solo_artoria("lv4_outing/smile"))

    if sec == "s2m":
        if idx <= 4:
            return ("artoria_lv4_takeyatei_teishoku_day", "lv4_outing", "neutral", duo_guest_artoria("taiga_fujimura", "story_guest_taiga_fujimura", "casual/grateful", "lv4_outing/neutral"))
        if idx in (5, 6):
            return ("artoria_lv4_takeyatei_teishoku_day", "lv4_outing", "smile", duo_guest_artoria("taiga_fujimura", "story_guest_taiga_fujimura", "casual/grateful", "lv4_outing/smile"))
        if idx in (7, 8):
            return ("artoria_lv4_dojo_exterior_day", "lv4_outing", "smile", solo_guest("taiga_fujimura", "story_guest_taiga_fujimura", "casual/laugh"))
        return ("artoria_lv4_station_clock_day", "lv4_outing", "shy", solo_artoria("lv4_outing/shy"))

    # Act 3: Suburban garden teahouse (Irisviel)
    if sec == "s3":
        bg = "artoria_lv4_garden_teahouse_day"
        if idx == 1:
            return (bg, "lv4_outing", "neutral", None)
        if idx in (2, 3):
            return (bg, "lv4_outing", "smile", solo_guest("irisviel", "story_guest_irisviel", "casual/smile"))
        if idx in (4, 5):
            return (bg, "lv4_outing", "smile", duo_guest_artoria("irisviel", "story_guest_irisviel", "casual/smile", "lv4_outing/smile"))
        if idx in (6, 7):
            return (bg, "lv4_outing", "smile", duo_guest_artoria("irisviel", "story_guest_irisviel", "casual/warm", "lv4_outing/smile"))
        if idx in (8, 9, 10, 11, 12, 13):
            return (bg, "lv4_outing", "smile", duo_guest_artoria("irisviel", "story_guest_irisviel", "casual/smile", "lv4_outing/smile"))
        if idx in (14, 15):
            return (bg, "lv4_outing", "neutral", None)
        if idx in (16, 17):
            return (bg, "lv4_outing", "neutral", duo_guest_artoria("irisviel", "story_guest_irisviel", "casual/warm", "lv4_outing/neutral"))
        if idx in (18, 19, 20):
            return (bg, "lv4_outing", "neutral", duo_guest_artoria("irisviel", "story_guest_irisviel", "casual/smile", "lv4_outing/neutral"))
        if idx in (21, 22):
            return (bg, "lv4_outing", "neutral", duo_guest_artoria("irisviel", "story_guest_irisviel", "casual/warm", "lv4_outing/neutral"))
        return (bg, "lv4_outing", "shy", duo_guest_artoria("irisviel", "story_guest_irisviel", "casual/warm", "lv4_outing/shy"))

    # Act 4: Sunset riverside promenade
    if sec == "s4":
        bg = "artoria_lv4_riverside_sunset"
        if idx in (1, 2, 3):
            return (bg, "lv4_outing", "neutral", None)
        if 4 <= idx <= 16:
            return (bg, "lv4_outing", "neutral", solo_artoria("lv4_outing/neutral"))
        return (bg, "lv4_outing", "shy", solo_artoria("lv4_outing/shy"))

    if sec in ("c2a", "c2b"):
        bg = "artoria_lv4_riverside_sunset"
        if idx in (1, 2):
            return (bg, "lv4_outing", "shy", solo_artoria("lv4_outing/shy"))
        return (bg, "lv4_outing", "smile", solo_artoria("lv4_outing/smile"))

    if sec == "c2c":
        return ("artoria_lv4_riverside_sunset", "lv4_outing", "shy", solo_artoria("lv4_outing/shy"))

    if sec == "s4m":
        bg = "artoria_lv4_riverside_sunset"
        if idx == 1:
            return (bg, "lv4_outing", "shy", None)
        if idx in (2, 3, 4, 5, 6, 7, 8):
            return (bg, "lv4_outing", "shy", solo_artoria("lv4_outing/shy"))
        return (bg, "lv4_outing", "smile", solo_artoria("lv4_outing/smile"))

    # Act 5.1: Artoria's apartment living room (long hair down)
    if sec == "s5_1":
        bg = "artoria_home_living_night"
        if idx in (1, 2):
            return (bg, "lv4_home", "neutral", None)
        if idx in (3, 4):
            return (bg, "lv4_home", "smile", solo_artoria("lv4_home/smile"))
        if idx in (5, 6, 7):
            return (bg, "lv4_home", "smile", solo_artoria("lv4_home/smile"))
        if idx in (8, 9, 10, 11, 12):
            return (bg, "lv4_home", "neutral", solo_artoria("lv4_home/neutral"))
        return (bg, "lv4_home", "shy", solo_artoria("lv4_home/shy"))

    # Act 5.2: Artoria's moonlit bedroom exclusive aftercare
    if sec == "s5_2":
        bg = "artoria_home_bedroom_night"
        if idx in (1, 2, 3):
            return (bg, "lv4_home", "soft", None)
        return (bg, "lv4_home", "soft", solo_artoria("lv4_home/soft"))

    # Act 6.1: Morning kitchen smoke alarm comedy -> breakfast tasting
    if sec == "s6_1":
        if idx <= 6:
            return ("artoria_home_bedroom_night", "lv4_apron", "serious_blush", None)
        bg = "artoria_home_kitchen_morning"
        if 7 <= idx <= 15:
            return (bg, "lv4_apron", "serious_blush", solo_artoria("lv4_apron/serious_blush"))
        if 16 <= idx <= 21:
            return (bg, "lv4_apron", "embarrassed", solo_artoria("lv4_apron/embarrassed"))
        if idx in (22, 23, 24):
            return (bg, "lv4_apron", "embarrassed", solo_artoria("lv4_apron/embarrassed"))
        if idx in (25, 26):
            return (bg, "lv4_morning", "neutral", None)
        if idx == 27:
            return (bg, "lv4_morning", "neutral", solo_artoria("lv4_morning/neutral"))
        if idx in (28, 29, 30, 31):
            return (bg, "lv4_morning", "sparkle", solo_artoria("lv4_morning/sparkle"))
        return (bg, "lv4_morning", "smile", solo_artoria("lv4_morning/smile"))

    # Act 6.2: Morning breakfast table reflection & promise
    if sec == "s6_2":
        bg = "artoria_home_kitchen_morning"
        if idx == 1:
            return (bg, "lv4_morning", "smile", None)
        if idx in (2, 3, 4, 5, 6, 7, 8):
            return (bg, "lv4_morning", "neutral", solo_artoria("lv4_morning/neutral"))
        return (bg, "lv4_morning", "serious", solo_artoria("lv4_morning/serious"))

    if sec == "c3a":
        bg = "artoria_home_kitchen_morning"
        if idx in (1, 2):
            return (bg, "lv4_morning", "serious", solo_artoria("lv4_morning/serious"))
        return (bg, "lv4_morning", "neutral", solo_artoria("lv4_morning/neutral"))

    if sec in ("c3b", "c3c"):
        bg = "artoria_home_kitchen_morning"
        if idx in (1, 2):
            return (bg, "lv4_morning", "neutral", solo_artoria("lv4_morning/neutral"))
        return (bg, "lv4_morning", "smile", solo_artoria("lv4_morning/smile"))

    if sec == "s6_2m":
        bg = "artoria_home_kitchen_morning"
        if idx in (1, 2, 3, 4, 5, 6, 7):
            return (bg, "lv4_morning", "neutral", solo_artoria("lv4_morning/neutral"))
        return (bg, "lv4_morning", "smile", solo_artoria("lv4_morning/smile"))

    raise ValueError(f"Unhandled node staging: {nid} ({sec})")


def parse_manuscript() -> tuple[list[dict], dict[str, str], int, int]:
    md = MANUSCRIPT_PATH.read_text(encoding="utf-8")
    body = md.split("## 二、 完整中文 VN 剧本正文", 1)[1].split(
        "**【阿尔托莉雅·潘德拉贡 Relationship Lv4《只是阿尔托莉雅》事件结束】**", 1
    )[0]

    sec = ""
    active = False
    cur_choice = ""
    counts: dict[str, int] = {}
    beats: list[dict] = []
    choices_zh: dict[str, str] = {}
    mixed_split_count = 0
    authorized_adj_count = 0

    def push(section: str, spk: str, txt: str) -> None:
        counts[section] = counts.get(section, 0) + 1
        nid = f"ar4_{section}_{counts[section]:02d}"
        role, aid, slabel = SPEAKER_MAP[spk]
        beats.append(
            {
                "id": nid,
                "sec": section,
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
        if s in AUTHORIZED_OUTFIT_ADJUSTMENTS:
            s = AUTHORIZED_OUTFIT_ADJUSTMENTS[s]
            authorized_adj_count += 1
        if s.startswith("### 【第一幕"):
            sec, active = "s1", False
            continue
        if s.startswith("### 【第二幕"):
            sec, active = "s2", False
            continue
        if s.startswith("### 【第三幕"):
            sec, active = "s3", False
            continue
        if s.startswith("### 【第四幕"):
            sec, active = "s4", False
            continue
        if s.startswith("### 【第五幕"):
            sec, active = "s5_1", False
            continue
        if s.startswith("#### 【5.2 "):
            sec, active = "s5_2", True
            continue
        if s.startswith("### 【第六幕"):
            continue
        if s.startswith("#### 6.1 "):
            sec, active = "s6_1", False
            continue
        if s.startswith("#### 6.2 "):
            sec, active = "s6_2", False
            continue
        if s == "**【玩家可见正文】**":
            active = True
            continue
        if s.startswith("*性质："):
            continue
        if s.startswith("> **【语义接入点"):
            active = False
            continue
        if s.startswith("> - "):
            continue
        m_ch = re.match(r"^\*\*【选择 (\d+)：.+】\*\*$", s)
        if m_ch:
            cur_choice = f"c{m_ch.group(1)}"
            active = False
            continue
        m_opt = re.match(r"^-\s*\*\*选项 ([ABC])：(.+)\*\*$", s)
        if m_opt:
            choices_zh[f"choice_ar4_{cur_choice}_{m_opt.group(1).lower()}"] = m_opt.group(2).strip()
            continue
        m_br = re.match(r"^#### 【分支 ([ABC])\b", s)
        if m_br:
            sec = f"{cur_choice}{m_br.group(1).lower()}"
            active = True
            continue
        if s.startswith("> **【主线汇合"):
            sec = {"c1": "s2m", "c2": "s4m", "c3": "s6_2m"}[cur_choice]
            active = True
            continue
        if not active:
            continue

        m_pure = re.match(r"^(" + "|".join(map(re.escape, PURE_SPEAKERS)) + r")：(「.*」)$", s)
        if m_pure:
            push(sec, m_pure.group(1), m_pure.group(2))
            continue

        if "：「" in s and s.endswith("」"):
            act, quote = s.split("：", 1)
            spk = next((target for pfx, target in MIXED_PREFIX_SPEAKERS if act.startswith(pfx)), None)
            if spk is None:
                raise ValueError(f"Unmapped mixed action+dialogue line: {s!r}")
            mixed_split_count += 1
            push(sec, "旁白", act + "：")
            push(sec, spk, quote)
            continue

        push(sec, "旁白", s)

    if authorized_adj_count != len(AUTHORIZED_OUTFIT_ADJUSTMENTS):
        raise ValueError(f"Expected {len(AUTHORIZED_OUTFIT_ADJUSTMENTS)} authorized outfit adjustments, applied {authorized_adj_count}")

    return beats, choices_zh, mixed_split_count, authorized_adj_count


def build_nodes(beats: list[dict], choices_zh: dict[str, str]) -> list[dict]:
    if len(beats) != 241:
        raise ValueError(f"Expected 241 beats, got {len(beats)}")

    by_sec: dict[str, list[dict]] = {}
    for b in beats:
        by_sec.setdefault(b["sec"], []).append(b)

    next_map: dict[str, str] = {}
    for sec, sec_beats in by_sec.items():
        for i in range(len(sec_beats) - 1):
            next_map[sec_beats[i]["id"]] = sec_beats[i + 1]["id"]

    next_map["ar4_s1_19"] = "ar4_s2_01"
    next_map["ar4_s2_23"] = "ar4_choice_c1"
    next_map["ar4_c1a_06"] = "ar4_s2m_01"
    next_map["ar4_c1b_06"] = "ar4_s2m_01"
    next_map["ar4_c1c_04"] = "ar4_s2m_01"
    next_map["ar4_s2m_09"] = "ar4_s3_01"
    next_map["ar4_s3_26"] = "ar4_s4_01"
    next_map["ar4_s4_19"] = "ar4_choice_c2"
    next_map["ar4_c2a_04"] = "ar4_s4m_01"
    next_map["ar4_c2b_04"] = "ar4_s4m_01"
    next_map["ar4_c2c_04"] = "ar4_s4m_01"
    next_map["ar4_s4m_09"] = "ar4_s5_1_01"
    next_map["ar4_s5_1_26"] = "ar4_s5_2_01"
    next_map["ar4_s5_2_13"] = "ar4_s6_1_01"
    next_map["ar4_s6_1_32"] = "ar4_s6_2_01"
    next_map["ar4_s6_2_12"] = "ar4_choice_c3"
    next_map["ar4_c3a_04"] = "ar4_s6_2m_01"
    next_map["ar4_c3b_04"] = "ar4_s6_2m_01"
    next_map["ar4_c3c_04"] = "ar4_s6_2m_01"
    next_map["ar4_s6_2m_13"] = "@end"

    choice_after: dict[str, dict] = {
        "ar4_s2_23": {
            "id": "ar4_choice_c1",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": ACTOR_ID,
            "text": "",
            "expression": "shy",
            "outfit": "lv4_outing",
            "background_id": "artoria_lv4_takeyatei_teishoku_day",
            "event_portraits": duo_guest_artoria("taiga_fujimura", "story_guest_taiga_fujimura", "casual/smile", "lv4_outing/shy"),
            "choices": [
                {
                    "id": "choice_ar4_c1_a",
                    "label": choices_zh["choice_ar4_c1_a"],
                    "next": "ar4_c1a_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar4_c1_b",
                    "label": choices_zh["choice_ar4_c1_b"],
                    "next": "ar4_c1b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar4_c1_c",
                    "label": choices_zh["choice_ar4_c1_c"],
                    "next": "ar4_c1c_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        "ar4_s4_19": {
            "id": "ar4_choice_c2",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": ACTOR_ID,
            "text": "",
            "expression": "shy",
            "outfit": "lv4_outing",
            "background_id": "artoria_lv4_riverside_sunset",
            "event_portraits": solo_artoria("lv4_outing/shy"),
            "choices": [
                {
                    "id": "choice_ar4_c2_a",
                    "label": choices_zh["choice_ar4_c2_a"],
                    "next": "ar4_c2a_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar4_c2_b",
                    "label": choices_zh["choice_ar4_c2_b"],
                    "next": "ar4_c2b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar4_c2_c",
                    "label": choices_zh["choice_ar4_c2_c"],
                    "next": "ar4_c2c_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        "ar4_s6_2_12": {
            "id": "ar4_choice_c3",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": ACTOR_ID,
            "text": "",
            "expression": "serious",
            "outfit": "lv4_morning",
            "background_id": "artoria_home_kitchen_morning",
            "event_portraits": solo_artoria("lv4_morning/serious"),
            "choices": [
                {
                    "id": "choice_ar4_c3_a",
                    "label": choices_zh["choice_ar4_c3_a"],
                    "next": "ar4_c3a_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar4_c3_b",
                    "label": choices_zh["choice_ar4_c3_b"],
                    "next": "ar4_c3b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar4_c3_c",
                    "label": choices_zh["choice_ar4_c3_c"],
                    "next": "ar4_c3c_01",
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
        if nid == "ar4_s5_1_26":
            node["action"] = "launch_artoria_lv4_h"
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
    outfits: list[str] = profile["visuals"]["outfits"]
    for outfit_id in ["lv4_outing", "lv4_home", "lv4_apron", "lv4_morning"]:
        if outfit_id not in outfits:
            outfits.append(outfit_id)
    portraits: dict[str, str] = profile["visuals"]["portraits"]
    for (actor, key), rel_path in CAST_PORTRAITS.items():
        if actor == ACTOR_ID:
            portraits[key] = rel_path
    # Ensure `neutral` fallback keys exist for every registered outfit
    portraits["lv4_apron/neutral"] = CAST_PORTRAITS[("doc_artoria", "lv4_apron/serious_blush")]
    write_json(PROFILE_PATH, profile)

    manifest = read_json(ASSETS_MANIFEST_PATH)
    existing_ids = {item["id"] for item in manifest.get("assets", [])}
    planned_cg_entry = {
        "id": "cg_doc_artoria_lv4_morning_kitchen_smoke",
        "category": "event_cg",
        "path": "assets/events/artoria_lv4_cg_v1/lv4_morning_kitchen_smoke.png",
        "status": "ready_for_later_integration",
        "runtime_connected": False,
        "trigger": EVENT_ID,
        "notes": "Placeholder slot for Codex CG integration via data/staff/doc_artoria/cg_mapping.json (Scene 6.1 smoky kitchen comedy CG ar4_s6_1_07..13).",
    }
    if planned_cg_entry["id"] not in existing_ids:
        manifest["assets"].append(planned_cg_entry)
        existing_ids.add(planned_cg_entry["id"])

    for (actor, key), rel_path in CAST_PORTRAITS.items():
        if actor != ACTOR_ID:
            continue
        aid = "portrait_doc_artoria_" + key.replace("/", "_")
        if aid not in existing_ids:
            manifest["assets"].append(
                {
                    "id": aid,
                    "category": "character_portrait",
                    "path": rel_path,
                    "status": "integrated",
                    "runtime_connected": True,
                    "trigger": EVENT_ID,
                    "notes": f"Artoria Lv4 ({key}) transparent RGBA portrait",
                }
            )
            existing_ids.add(aid)
    write_json(ASSETS_MANIFEST_PATH, manifest)

    bundle = read_json(BUNDLE_PATH)
    extras = bundle.setdefault("additional_character_event_files", [])
    if "lv4_events.json" not in extras:
        extras.append("lv4_events.json")
    write_json(BUNDLE_PATH, bundle)

    rel = read_json(RELATIONSHIP_PATH)
    slot4 = next(s for s in rel["rank_slots"] if s["target_level"] == 4)
    slot4["event_id"] = EVENT_ID
    slot4["content_status"] = "authored"
    slot4["benefit_id"] = "unlock_intimacy_events"
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

    # Backgrounds, UI H-placeholder, Free H, and wardrobe labels
    for bg_id, zh_lbl, en_lbl, _ in BACKGROUND_STRINGS:
        zh_strings[f"collections.backgrounds.{bg_id}.label"] = zh_lbl
        en_strings[f"collections.backgrounds.{bg_id}.label"] = en_lbl

    ui_pairs = {
        "ui.artoria_lv4.h_placeholder.title": (
            "阿尔托莉雅·潘德拉贡 · 首次自宅亲密（占位）",
            "Artoria Pendragon · First Apartment Intimacy (Placeholder)",
        ),
        "ui.artoria_lv4.h_placeholder.subtitle": (
            "阿尔托莉雅自宅 · 卧室",
            "Artoria's Apartment · Bedroom",
        ),
        "ui.artoria_lv4.h_placeholder.body": (
            "【开发占位 H Runner】\n地点：阿尔托莉雅·潘德拉贡私人住所（home）\n当前阿尔托莉雅的专属 H Profile 与自宅亲密差分尚待制作确认；点击下方按钮将完成首次亲密流程并衔接 5.2 夜间专属余韵与次日清晨早餐剧情（暂不提前结算 Lv4）。",
            "[Development H Runner Placeholder]\nLocation: Artoria Pendragon's Private Apartment (home)\nArtoria's dedicated H Profile and apartment intimacy CG set are pending production design; press below to complete the first intimacy sequence and proceed directly into Scene 5.2 nighttime aftercare and next-morning breakfast (without settling Lv4 early).",
        ),
        "ui.artoria_lv4.h_placeholder.continue": (
            "完成亲密流程并进入夜间余韵  ▷",
            "Complete Intimacy & Continue to Aftercare  ▷",
        ),
        "ui.free_h.location.doc_artoria_home": (
            "阿尔托莉雅自宅",
            "Artoria's Apartment",
        ),
        "ui.free_h.doc_artoria.booking_response": (
            "……今晚没有排班。下班以后，一起回我家坐坐吧。",
            "...I have no late shift scheduled tonight. After work, let's head back to my place together.",
        ),
        "ui.staff.outfit.lv4_outing": ("外出风衣", "Day-Off Trench Coat"),
        "ui.staff.outfit.lv4_home": ("自宅散发", "Home · Hair Down"),
        "ui.staff.outfit.lv4_apron": ("清晨围裙", "Morning Apron"),
        "ui.staff.outfit.lv4_morning": ("清晨居家", "Morning Loungewear"),
        "ui.staff.expression.sparkle": ("眼睛发亮", "Starry-Eyed"),
        "ui.staff.expression.serious_blush": ("端肃微红", "Earnest Blush"),
    }
    for k, (zh_val, en_val) in ui_pairs.items():
        zh_strings[k] = zh_val
        en_strings[k] = en_val

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


def write_candidate_provenance() -> None:
    cand_dir = CANDIDATE_MANIFEST_PATH.parent
    raw_files = sorted(p for p in cand_dir.glob("*_raw.jpg"))
    manifest = {
        "batch_id": "artoria_lv4_v1",
        "date": "2026-11-16",
        "event_id": EVENT_ID,
        "upstream_seeds": {
            "taiga_casual_seed": {
                "path": "research/generated_candidates/taiga_irisviel_casual_v1/taiga_casual_seed.png",
                "sha256": sha256_of(ROOT / "research/generated_candidates/taiga_irisviel_casual_v1/taiga_casual_seed.png"),
            },
            "irisviel_casual_seed": {
                "path": "research/generated_candidates/taiga_irisviel_casual_v1/irisviel_casual_seed.png",
                "sha256": sha256_of(ROOT / "research/generated_candidates/taiga_irisviel_casual_v1/irisviel_casual_seed.png"),
            },
        },
        "raw_candidates": [
            {"file": p.name, "bytes": p.stat().st_size, "sha256": sha256_of(p)}
            for p in raw_files
        ],
        "runtime_portraits": [
            {
                "actor": actor,
                "key": key,
                "path": rel_path,
                "sha256": sha256_of(ROOT / rel_path),
            }
            for (actor, key), rel_path in sorted(CAST_PORTRAITS.items())
        ],
        "runtime_backgrounds": [
            {
                "id": bg_id,
                "path": rel_path,
                "sha256": sha256_of(ROOT / rel_path),
            }
            for bg_id, _, _, rel_path in BACKGROUND_STRINGS
        ],
    }
    write_json(CANDIDATE_MANIFEST_PATH, manifest)
    prompts_doc = {
        "style_benchmark": "research/generated_candidates/emiko_cg_style_pilot_v1/lv3_private_notes.png",
        "identity_refs": [
            "assets/characters/portrait_pack_v16/doc_artoria/casual/neutral.png",
            "assets/characters/winter_casual_v1/doc_artoria/neutral.png",
            "research/generated_candidates/taiga_irisviel_casual_v1/taiga_casual_seed.png",
            "research/generated_candidates/taiga_irisviel_casual_v1/irisviel_casual_seed.png",
        ],
        "matting_tool": "tools/portrait_matting.py --model birefnet (offline ONNX BiRefNet-ToonOut)",
    }
    write_json(CANDIDATE_PROMPTS_PATH, prompts_doc)


def main() -> None:
    for (_, key), rel_path in CAST_PORTRAITS.items():
        full = ROOT / rel_path
        if not full.is_file():
            raise FileNotFoundError(f"Missing portrait for {key}: {full}")
    for bg_id, _, _, rel_path in BACKGROUND_STRINGS:
        full = ROOT / rel_path
        if not full.is_file():
            raise FileNotFoundError(f"Missing background for {bg_id}: {full}")

    beats, choices_zh, mixed_splits, adj_count = parse_manuscript()
    nodes = build_nodes(beats, choices_zh)
    en_data = read_json(EN_TRANSLATION_PATH)

    event_obj = {
        "id": EVENT_ID,
        "actor_id": ACTOR_ID,
        "title": "只是阿尔托莉雅",
        "chapter": 4,
        "location_id": "artoria_office",
        "trigger_mode": "sunday",
        "consumes_sunday": True,
        "date_location_id": "restaurant_bar",
        "background_id": "artoria_lv4_station_clock_day",
        "outfit": "lv4_outing",
        "completion_background_id": "artoria_home_kitchen_morning",
        "completion_outfit": "lv4_morning",
        "completion_expression": "smile",
        "hide_calendar_header": True,
        "minutes": 0,
        "completion_day_offset": 1,
        "completion_absolute_clock": 540,
        "teaser": "难得不用去医院听晨会交班的休息日，坂口隆司陪脱下白大褂的阿尔托莉雅赴大河与爱丽丝菲尔之约，并在傍晚河岸接受她回自宅过夜的主动邀请。",
        "time_start": 540,
        "time_end": 1320,
        "priority": 184,
        "category": "rank_up",
        "gallery": {
            "cg_id": "cg_artoria_lv4_just_artoria",
            "caption": "系着素白围裙握着锅铲、站在焦培根与冒烟吐司机前脸红汇报现场安全的阿尔托莉雅——以及晨光餐桌上终于彻底卸下所有紧绷的笑容。",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "max_day": 363,
            "min_affection": 0,
            "min_familiarity": 55,
            "required_events": [
                "artoria_lv3_not_a_solo_operation"
            ],
            "days_after_required_events": 3,
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "leadership",
                    "minimum": 85
                }
            ]
        },
        "locks_saving": True,
        "target_level": 4,
        "benefit_id": "unlock_intimacy_events",
        "completion_story_flags": [
            "artoria_lv4_complete"
        ],
        "start": "ar4_s1_01",
        "nodes": nodes,
    }

    update_staff_files()
    from artoria_cg_mapping import apply_cg_mapping
    apply_cg_mapping(event_obj)
    write_json(EVENTS_PATH, [event_obj])
    update_localization(event_obj, en_data)
    write_candidate_provenance()

    import_manifest = {
        "event_id": EVENT_ID,
        "actor_id": ACTOR_ID,
        "target_level": 4,
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
        "authorized_outfit_word_adjustments": adj_count,
        "story_guests": [
            {"id": "story_guest_taiga_fujimura", "name": "藤村大河", "random_pool": False, "surgery_queue": False},
            {"id": "story_guest_irisviel", "name": "爱丽丝菲尔·冯·爱因兹贝伦", "random_pool": False, "surgery_queue": False},
        ],
    }
    write_json(IMPORT_MANIFEST_PATH, import_manifest)
    print(
        f"Imported {EVENT_ID}: {len(beats)} beats, {len(nodes)} nodes, "
        f"{mixed_splits} mixed splits, {adj_count} authorized outfit adjustments."
    )


if __name__ == "__main__":
    main()
