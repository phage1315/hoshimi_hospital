#!/usr/bin/env python3
"""Import Artoria Pendragon (`doc_artoria`) Relationship Lv5 milestone event:
《我的位置》 (My Place, ID: `artoria_lv5_my_position`, V1.1).

Updates:
- data/backgrounds.json (registers `artoria_lv5_or_corridor_evening`)
- data/staff/doc_artoria/assets_manifest.json (preserves existing Lv2-Lv4 CGs & H assets)
- data/staff/doc_artoria/cg_mapping.json (preserves Lv2-Lv4 CGs; records Lv5 Codex CG placeholders)
- data/staff/doc_artoria/bundle.json
- data/staff/doc_artoria/relationship.json (`target_level: 5` -> `"authored"`)
- data/staff/doc_artoria/lv5_events.json
- data/localization/zh_CN.json & data/localization/en.json
- research/imports/artoria_lv5_2026-11-17.json
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_ARTORIA_LV5_MY_POSITION_V1_1.md"
EN_TRANSLATION_PATH = ROOT / "research/translations/artoria_lv5_en.json"
BACKGROUNDS_PATH = ROOT / "data/backgrounds.json"
STAFF_DIR = ROOT / "data/staff/doc_artoria"
ASSETS_MANIFEST_PATH = STAFF_DIR / "assets_manifest.json"
CG_MAPPING_PATH = STAFF_DIR / "cg_mapping.json"
BUNDLE_PATH = STAFF_DIR / "bundle.json"
RELATIONSHIP_PATH = STAFF_DIR / "relationship.json"
EVENTS_PATH = STAFF_DIR / "lv5_events.json"
ZH_LOCALE_PATH = ROOT / "data/localization/zh_CN.json"
EN_LOCALE_PATH = ROOT / "data/localization/en.json"
IMPORT_MANIFEST_PATH = ROOT / "research/imports/artoria_lv5_2026-11-17.json"

EVENT_ID = "artoria_lv5_my_position"
ACTOR_ID = "doc_artoria"

BACKGROUND_ENTRY = (
    "artoria_lv5_or_corridor_evening",
    "四楼手术部·观察窗外走廊（傍晚）",
    "4F Surgical Suite · Observation Window Corridor (Evening)",
    "assets/backgrounds/artoria_lv5_v1/or_corridor_evening.png",
)

CAST_PORTRAITS = {
    ("doc_artoria", "white_coat/neutral"): "assets/characters/portrait_pack_v16/doc_artoria/white_coat/neutral.png",
    ("doc_artoria", "white_coat/smile"): "assets/characters/artoria_lv2_v1/doc_artoria/white_coat/smile.png",
    ("doc_artoria", "white_coat/embarrassed"): "assets/characters/artoria_lv2_v1/doc_artoria/white_coat/embarrassed.png",
    ("doc_artoria", "white_coat/shy"): "assets/characters/artoria_lv3_v1/doc_artoria/white_coat/shy.png",
    ("doc_artoria", "scrubs_masked/neutral"): "assets/characters/artoria_lv2_v1/doc_artoria/scrubs_masked/neutral.png",
    ("doc_artoria", "scrubs_masked/focused"): "assets/characters/artoria_lv2_v1/doc_artoria/scrubs_masked/focused.png",
    ("doc_artoria", "sterile/neutral"): "assets/characters/portrait_pack_v16/doc_artoria/sterile/neutral.png",
    ("doc_artoria", "sterile/focused"): "assets/characters/portrait_pack_v16/doc_artoria/sterile/neutral.png",
    ("nurse_moe", "uniform/neutral"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/neutral.png",
    ("nurse_moe", "uniform/smile"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/smile.png",
    ("nurse_moe", "uniform/surprised"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/surprised.png",
    ("nurse_moe", "uniform/worried"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/worried.png",
    ("nurse_moe", "uniform/shy"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/shy.png",
    ("nurse_moe", "scrubs/neutral"): "assets/characters/moe_circulating_v1/neutral.png",
    ("nurse_ange", "uniform/neutral"): "assets/characters/portrait_pack_v11/nurse_ange/uniform/neutral.png",
    ("nurse_ange", "uniform/smile"): "assets/characters/portrait_pack_v11/nurse_ange/uniform/smile.png",
    ("nurse_ange", "uniform/serious"): "assets/characters/portrait_pack_v11/nurse_ange/uniform/serious.png",
    ("nurse_ange", "uniform/surprised"): "assets/characters/portrait_pack_v11/nurse_ange/uniform/surprised.png",
    ("nurse_ange", "uniform/tired"): "assets/characters/portrait_pack_v11/nurse_ange/uniform/tired.png",
    ("nurse_ange", "uniform/worried"): "assets/characters/portrait_pack_v11/nurse_ange/uniform/worried.png",
    ("nurse_ange", "scrubs/neutral"): "assets/characters/portrait_pack_v11/nurse_ange/scrubs/neutral.png",
    ("nurse_ange", "scrubs/focused"): "assets/characters/portrait_pack_v11/nurse_ange/scrubs/focused.png",
    ("nurse_ange", "scrubs/warm"): "assets/characters/portrait_pack_v11/nurse_ange/scrubs/warm.png",
    ("nurse_hiroko", "uniform/neutral"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/neutral.png",
    ("nurse_hiroko", "uniform/serious"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/serious.png",
    ("nurse_hiroko", "uniform/smile"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/smile.png",
    ("nurse_hiroko", "sterile/neutral"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/neutral.png",
    ("nurse_hiroko", "sterile/focused"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/focused.png",
    ("nurse_hiroko", "sterile/warm"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/warm.png",
    ("story_guest_aoi_tohsaka", "ward/neutral"): "assets/characters/artoria_lv5_v1/aoi_tohsaka/ward/neutral.png",
    ("story_guest_aoi_tohsaka", "ward/smile"): "assets/characters/artoria_lv5_v1/aoi_tohsaka/ward/smile.png",
    ("story_guest_aoi_tohsaka", "or_cap/calm"): "assets/characters/artoria_lv5_v1/aoi_tohsaka/or_cap/calm.png",
    ("story_guest_aoi_tohsaka", "or_cap/smile"): "assets/characters/artoria_lv5_v1/aoi_tohsaka/or_cap/smile.png",
}

SPEAKER_MAP = {
    "旁白": ("narrator", "doc_artoria", "旁白"),
    "阿尔托莉雅·潘德拉贡": ("actor", "doc_artoria", "阿尔托莉雅·潘德拉贡"),
    "坂口隆司": ("player", "doc_artoria", "坂口隆司"),
    "杉村弘子": ("actor", "nurse_hiroko", "杉村弘子"),
    "本庄萌恵": ("actor", "nurse_moe", "本庄萌恵"),
    "利根川安琪": ("actor", "nurse_ange", "利根川安琪"),
    "远坂葵": ("actor", "doc_artoria", "远坂葵"),
    "杉村弘子 ＆ 本庄萌恵 ＆ 利根川安琪": ("actor", "nurse_hiroko", "杉村弘子 ＆ 本庄萌恵 ＆ 利根川安琪"),
    "全员": ("actor", "nurse_hiroko", "全员"),
}

BOLD_SPEAKER_NORM = {
    "阿尔托莉雅": "阿尔托莉雅·潘德拉贡",
    "阿尔托莉雅·潘德拉贡": "阿尔托莉雅·潘德拉贡",
    "坂口隆司": "坂口隆司",
    "杉村弘子": "杉村弘子",
    "本庄萌恵": "本庄萌恵",
    "利根川安琪": "利根川安琪",
    "远坂葵": "远坂葵",
    "杉村弘子 ＆ 本庄萌恵 ＆ 利根川安琪": "杉村弘子 ＆ 本庄萌恵 ＆ 利根川安琪",
    "全员": "全员",
}

PROSE_MIXED_SPEAKERS = [
    ("坂口隆司", "坂口隆司"),
    ("阿尔托莉雅", "阿尔托莉雅·潘德拉贡"),
    ("本庄萌恵", "本庄萌恵"),
    ("利根川安琪", "利根川安琪"),
    ("杉村弘子", "杉村弘子"),
    ("远坂葵", "远坂葵"),
]

CODEX_CG_PLACEHOLDERS = [
    {
        "placeholder_id": "cg_doc_artoria_lv5_observation_window_epilogue",
        "priority": "high_recommended_cover",
        "recommended_cover": True,
        "scene": "Act 6 — Evening 4F surgical observation-window corridor epilogue",
        "nodes": ["ar5_s6_05", "ar5_s6_06", "ar5_s6_07", "ar5_s6_08"],
        "visual_brief": "Evening 4F surgical corridor outside wide double-paned glass observation window; inside the warm-lit OR prep area, Hiroko, Moe, and Anji review tomorrow's suture checklist together; in the corridor foreground, Artoria in white coat pauses and turns gently toward Sakaguchi with deep trust and playful warmth ('……也许下次，我也该试试了。不是站在手术台边，而是躺在上面').",
    },
    {
        "placeholder_id": "cg_doc_artoria_lv5_hepp_couinaud_anastomosis",
        "priority": "high",
        "recommended_cover": False,
        "scene": "Act 4 — Intraoperative Hepp-Couinaud left hepatic duct spatulation & 6-0 hepaticojejunostomy",
        "nodes": ["ar5_s4m_06", "ar5_s4m_07", "ar5_s4m_08", "ar5_s4m_09", "ar5_s4m_10", "ar5_s4m_11"],
        "visual_brief": "Operating Room One under shadowless lamps; Artoria in sterile surgical gown, cap, and mask guiding a micro-needle holder with hair-fine 6-0 suture across the spatulated left hepatic duct while Sakaguchi holds steady deep retraction and Hiroko stands ready at the Mayo stand.",
    },
    {
        "placeholder_id": "cg_doc_artoria_lv5_ange_mentorship_folder",
        "priority": "optional",
        "recommended_cover": False,
        "scene": "Act 5.1 — Outer OR supply room mentorship plan handoff to Anji Tonegawa",
        "nodes": ["ar5_s5_1_15", "ar5_s5_1_16", "ar5_s5_1_17", "ar5_s5_1_18", "ar5_s5_1_19", "ar5_s5_1_20", "ar5_s5_1_21", "ar5_s5_1_22"],
        "visual_brief": "Afternoon outer OR supply room; Artoria in white coat handing a neatly handwritten perioperative risk-verification coordinator training folder into red-rimmed Anji Tonegawa's hands.",
    },
]

CJK_RE = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")
BOLD_LINE_RE = re.compile(r"^\*\*([^*]+)\*\*([^\n：]*?)：(「.*」)$")
BULLET_CHOICE_RE = re.compile(r"^-\s*\*\*选项\s*([ABC])[：:]\s*(「.*」)\*\*$")
BRANCH_HDR_RE = re.compile(r"^####\s*【选择选项\s*([ABC])\s*后的分支演出】$")


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, data) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


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


def ward_aoi_and_staff(aoi_key: str, staff_actor: str, staff_key: str) -> list[dict]:
    return [
        {
            "id": "aoi_tohsaka",
            "path": CAST_PORTRAITS[("story_guest_aoi_tohsaka", aoi_key)],
            "x": 440,
            "bottom": 556,
            "width": 320,
            "height": 480,
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


def or_aoi_with_staff(aoi_key: str, staff_actor: str, staff_key: str) -> list[dict]:
    return [
        {
            "id": "aoi_tohsaka",
            "path": CAST_PORTRAITS[("story_guest_aoi_tohsaka", aoi_key)],
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

    # Act 1: Surgical doctors' office (`shared_doctors_office`)
    if sec == "s1":
        if idx == 1:
            return ("shared_doctors_office", "white_coat", "neutral", None)
        if idx in (2, 3, 4):
            return (
                "shared_doctors_office",
                "white_coat",
                "neutral",
                duo_staff("nurse_moe", "uniform/neutral", "nurse_ange", "uniform/serious"),
            )
        if idx == 5:
            return (
                "shared_doctors_office",
                "white_coat",
                "smile",
                duo_staff("nurse_moe", "uniform/smile", "doc_artoria", "white_coat/smile"),
            )
        if idx == 6:
            return (
                "shared_doctors_office",
                "white_coat",
                "neutral",
                duo_staff("nurse_ange", "uniform/smile", "doc_artoria", "white_coat/neutral"),
            )
        if idx == 7:
            return (
                "shared_doctors_office",
                "white_coat",
                "neutral",
                duo_staff("nurse_moe", "uniform/shy", "doc_artoria", "white_coat/neutral"),
            )
        if idx == 8:
            return ("shared_doctors_office", "white_coat", "neutral", solo_staff("doc_artoria", "white_coat/neutral"))
        if 9 <= idx <= 17:
            hiroko_expr = "serious" if idx in (9, 10, 17) else "neutral"
            return (
                "shared_doctors_office",
                "white_coat",
                "neutral",
                duo_staff("nurse_hiroko", f"uniform/{hiroko_expr}", "doc_artoria", "white_coat/neutral"),
            )
        if idx == 18:
            return ("shared_doctors_office", "white_coat", "neutral", solo_staff("nurse_hiroko", "uniform/neutral"))
        return ("shared_doctors_office", "white_coat", "neutral", solo_staff("doc_artoria", "white_coat/neutral", x=1020))

    # Act 2.1: Deputy Chief's office (`artoria_office`)
    if sec == "s2":
        return ("artoria_office", "white_coat", "neutral", solo_staff("doc_artoria", "white_coat/neutral", x=1020))
    if sec in ("c1a", "c1b", "c1c"):
        expr = "smile" if idx >= 2 else "neutral"
        return ("artoria_office", "white_coat", expr, solo_staff("doc_artoria", f"white_coat/{expr}", x=1020))
    if sec == "s2m":
        return ("artoria_office", "white_coat", "neutral", solo_staff("doc_artoria", "white_coat/neutral", x=1020))

    # Act 2.2: Consultation room beside surgical nurses' station (`nurses_station`)
    if sec == "s2_2":
        if idx in (1, 2):
            return (
                "nurses_station",
                "white_coat",
                "neutral",
                duo_staff("nurse_hiroko", "uniform/serious", "doc_artoria", "white_coat/neutral"),
            )
        if idx in (3, 4):
            return (
                "nurses_station",
                "white_coat",
                "neutral",
                duo_staff("nurse_moe", "uniform/surprised", "nurse_ange", "uniform/surprised"),
            )
        if idx in (5, 6):
            return (
                "nurses_station",
                "white_coat",
                "neutral",
                duo_staff("nurse_moe", "uniform/worried", "nurse_ange", "uniform/worried"),
            )
        if idx in (7, 8):
            return (
                "nurses_station",
                "white_coat",
                "neutral",
                duo_staff("nurse_moe", "uniform/shy", "nurse_ange", "uniform/worried"),
            )
        if idx in (9, 10, 11):
            return (
                "nurses_station",
                "white_coat",
                "neutral",
                duo_staff("nurse_ange", "uniform/worried", "doc_artoria", "white_coat/neutral"),
            )
        if idx in (12, 13):
            return (
                "nurses_station",
                "white_coat",
                "neutral",
                duo_staff("nurse_ange", "uniform/serious", "doc_artoria", "white_coat/neutral"),
            )
        if idx == 14:
            return (
                "nurses_station",
                "white_coat",
                "neutral",
                duo_staff("nurse_hiroko", "uniform/serious", "doc_artoria", "white_coat/neutral"),
            )
        return (
            "nurses_station",
            "white_coat",
            "neutral",
            duo_staff("nurse_moe", "uniform/neutral", "nurse_ange", "uniform/serious"),
        )

    # Act 3.1: Surgical private ward room (`ward`) with Aoi Tohsaka
    if sec == "s3_1":
        if idx == 1:
            return ("ward", "white_coat", "neutral", None)
        if idx in (2, 3, 6):
            return ("ward", "white_coat", "neutral", ward_aoi_and_staff("ward/neutral", "doc_artoria", "white_coat/neutral"))
        if idx == 4:
            return ("ward", "white_coat", "smile", ward_aoi_and_staff("ward/neutral", "doc_artoria", "white_coat/smile"))
        if idx in (5, 7):
            return ("ward", "white_coat", "neutral", ward_aoi_and_staff("ward/smile", "doc_artoria", "white_coat/neutral"))
        return ("ward", "white_coat", "smile", ward_aoi_and_staff("ward/smile", "doc_artoria", "white_coat/smile"))

    # Act 3.2: 4F OR 1 pre-incision epidural & time-out (`operating_room`)
    if sec == "s3_2":
        if idx == 1:
            return ("operating_room", "scrubs_masked", "focused", None)
        if idx == 2:
            return (
                "operating_room",
                "scrubs_masked",
                "focused",
                or_aoi_with_staff("or_cap/calm", "doc_artoria", "scrubs_masked/focused"),
            )
        if idx == 3:
            return (
                "operating_room",
                "sterile",
                "neutral",
                duo_staff("nurse_hiroko", "sterile/focused", "doc_artoria", "sterile/neutral"),
            )
        if idx == 4:
            return (
                "operating_room",
                "sterile",
                "neutral",
                duo_staff("nurse_ange", "scrubs/focused", "doc_artoria", "sterile/neutral"),
            )
        if idx in (5, 6):
            return (
                "operating_room",
                "sterile",
                "neutral",
                or_aoi_with_staff("or_cap/calm", "nurse_moe", "scrubs/neutral"),
            )
        if idx in (7, 8, 9, 10):
            return (
                "operating_room",
                "sterile",
                "focused",
                duo_staff("nurse_hiroko", "sterile/focused", "doc_artoria", "sterile/focused"),
            )
        if idx in (11, 12):
            return (
                "operating_room",
                "sterile",
                "neutral",
                or_aoi_with_staff("or_cap/smile", "doc_artoria", "sterile/neutral"),
            )
        return (
            "operating_room",
            "sterile",
            "focused",
            duo_staff("nurse_hiroko", "sterile/focused", "doc_artoria", "sterile/focused"),
        )

    # Act 4: Intraoperative Bismuth II scar assessment & Hepp-Couinaud reconstruction (`operating_room`)
    if sec == "s4":
        if idx in (1, 2):
            return ("operating_room", "sterile", "focused", solo_staff("doc_artoria", "sterile/focused", x=1020))
        if idx in (3, 4, 5):
            aoi_expr = "calm" if idx == 3 else "smile"
            return (
                "operating_room",
                "sterile",
                "neutral",
                or_aoi_with_staff(f"or_cap/{aoi_expr}", "nurse_moe", "scrubs/neutral"),
            )
        if idx in (6, 7, 8):
            return (
                "operating_room",
                "sterile",
                "focused",
                duo_staff("nurse_hiroko", "sterile/focused", "doc_artoria", "sterile/focused"),
            )
        if 9 <= idx <= 14:
            return ("operating_room", "sterile", "focused", solo_staff("doc_artoria", "sterile/focused", x=1020))
        if idx in (15, 16):
            return (
                "operating_room",
                "sterile",
                "focused",
                duo_staff("nurse_moe", "scrubs/neutral", "doc_artoria", "sterile/focused"),
            )
        return (
            "operating_room",
            "sterile",
            "focused",
            duo_staff("nurse_ange", "scrubs/focused", "nurse_hiroko", "sterile/focused"),
        )

    if sec in ("c2a", "c2b"):
        return ("operating_room", "sterile", "focused", solo_staff("doc_artoria", "sterile/focused", x=1020))

    if sec == "s4m":
        if idx in (1, 2, 3):
            return ("operating_room", "sterile", "focused", solo_staff("doc_artoria", "sterile/focused", x=1020))
        if idx in (4, 5):
            return (
                "operating_room",
                "sterile",
                "focused",
                duo_staff("nurse_hiroko", "sterile/focused", "nurse_ange", "scrubs/focused"),
            )
        if 6 <= idx <= 13:
            return (
                "operating_room",
                "sterile",
                "focused",
                duo_staff("nurse_hiroko", "sterile/focused", "doc_artoria", "sterile/focused"),
            )
        if idx == 14:
            return (
                "operating_room",
                "sterile",
                "neutral",
                duo_staff("nurse_hiroko", "sterile/warm", "doc_artoria", "sterile/neutral"),
            )
        return (
            "operating_room",
            "sterile",
            "neutral",
            or_aoi_with_staff("or_cap/smile", "doc_artoria", "sterile/neutral"),
        )

    # Act 5.1: Outer OR supply room with Anji Tonegawa (`or_holding`)
    if sec == "s5_1":
        if idx == 1:
            return ("or_holding", "white_coat", "neutral", None)
        if idx in (2, 3):
            return (
                "or_holding",
                "white_coat",
                "neutral",
                duo_staff("nurse_ange", "uniform/tired", "doc_artoria", "white_coat/neutral"),
            )
        if 4 <= idx <= 14:
            return (
                "or_holding",
                "white_coat",
                "neutral",
                duo_staff("nurse_ange", "uniform/worried", "doc_artoria", "white_coat/neutral"),
            )
        if idx in (15, 16, 17):
            return (
                "or_holding",
                "white_coat",
                "smile",
                duo_staff("nurse_ange", "uniform/surprised", "doc_artoria", "white_coat/smile"),
            )
        if idx in (18, 19, 20):
            return (
                "or_holding",
                "white_coat",
                "smile",
                duo_staff("nurse_ange", "uniform/worried", "doc_artoria", "white_coat/smile"),
            )
        if idx in (21, 22):
            return (
                "or_holding",
                "white_coat",
                "smile",
                duo_staff("nurse_ange", "uniform/smile", "doc_artoria", "white_coat/smile"),
            )
        return ("or_holding", "white_coat", "smile", solo_staff("doc_artoria", "white_coat/smile", x=1020))

    # Act 5.2: Private tea inside Deputy Chief's office (`artoria_office`)
    if sec == "s5_2":
        if idx == 1:
            return ("artoria_office", "white_coat", "neutral", None)
        if idx in (2, 3, 4):
            return ("artoria_office", "white_coat", "smile", solo_staff("doc_artoria", "white_coat/smile", x=1020))
        if 5 <= idx <= 9:
            return ("artoria_office", "white_coat", "neutral", solo_staff("doc_artoria", "white_coat/neutral", x=1020))
        return ("artoria_office", "white_coat", "smile", solo_staff("doc_artoria", "white_coat/smile", x=1020))

    # Act 6: Evening 4F surgical observation-window corridor (`artoria_lv5_or_corridor_evening`)
    if sec == "s6":
        if idx <= 4:
            return ("artoria_lv5_or_corridor_evening", "white_coat", "neutral", None)
        if idx in (5, 6):
            return (
                "artoria_lv5_or_corridor_evening",
                "white_coat",
                "neutral",
                solo_staff("doc_artoria", "white_coat/neutral", x=1020),
            )
        return (
            "artoria_lv5_or_corridor_evening",
            "white_coat",
            "smile",
            solo_staff("doc_artoria", "white_coat/smile", x=1020),
        )

    if sec == "c3a":
        return (
            "artoria_lv5_or_corridor_evening",
            "white_coat",
            "smile",
            solo_staff("doc_artoria", "white_coat/smile", x=1020),
        )
    if sec == "c3b":
        expr = "shy" if idx >= 2 else "smile"
        return (
            "artoria_lv5_or_corridor_evening",
            "white_coat",
            expr,
            solo_staff("doc_artoria", f"white_coat/{expr}", x=1020),
        )
    if sec == "c3c":
        return (
            "artoria_lv5_or_corridor_evening",
            "white_coat",
            "smile",
            solo_staff("doc_artoria", "white_coat/smile", x=1020),
        )
    if sec == "s6m":
        if idx == 1:
            return ("artoria_lv5_or_corridor_evening", "white_coat", "smile", None)
        return (
            "artoria_lv5_or_corridor_evening",
            "white_coat",
            "smile",
            solo_staff("doc_artoria", "white_coat/smile", x=1020),
        )

    raise ValueError(f"Unhandled node staging: {nid} ({sec})")


def parse_manuscript() -> tuple[list[dict], dict[str, str], list[dict], list[dict]]:
    md = MANUSCRIPT_PATH.read_text(encoding="utf-8")
    body = "### 第一幕" + md.split("### 第一幕", 1)[1]

    sec = ""
    cur_choice = ""
    counts: dict[str, int] = {}
    beats: list[dict] = []
    choices_zh: dict[str, str] = {}
    mixed_splits: list[dict] = []
    italic_strips: list[dict] = []

    def add_beat(s: str, speaker_key: str, text: str) -> str:
        counts[s] = counts.get(s, 0) + 1
        nid = f"ar5_{s}_{counts[s]:02d}"
        role, actor_id, speaker_label = SPEAKER_MAP[speaker_key]
        beats.append(
            {
                "id": nid,
                "sec": s,
                "role": role,
                "actor_id": actor_id,
                "speaker_label": speaker_label,
                "text": text,
            }
        )
        return nid

    for raw in body.splitlines():
        line = raw.strip()
        if not line or line == "---":
            continue
        if line.startswith("### 第一幕"):
            sec = "s1"
            continue
        if line.startswith("### 第二幕"):
            sec = "s2"
            continue
        if line.startswith("**【选择 1"):
            cur_choice = "c1"
            continue
        if line == "【小转场：外科护士站旁讨论间】":
            sec = "s2_2"
            continue
        if line.startswith("### 第三幕"):
            sec = "s3_1"
            continue
        if line == "【转场：四楼一号手术室】":
            sec = "s3_2"
            continue
        if line.startswith("### 第四幕"):
            sec = "s4"
            continue
        if line.startswith("**【选择 2"):
            cur_choice = "c2"
            continue
        if line.startswith("### 第五幕"):
            sec = "s5_1"
            continue
        if line == "【小转场：外科副部长办公室】":
            sec = "s5_2"
            continue
        if line.startswith("### 第六幕"):
            sec = "s6"
            continue
        if line.startswith("**【选择 3"):
            cur_choice = "c3"
            continue

        m_branch = BRANCH_HDR_RE.match(line)
        if m_branch:
            sec = f"{cur_choice}{m_branch.group(1).lower()}"
            continue

        m_opt = BULLET_CHOICE_RE.match(line)
        if m_opt:
            opt = m_opt.group(1).lower()
            choices_zh[f"choice_ar5_{cur_choice}_{opt}"] = m_opt.group(2).strip()
            continue

        if line == "> **【分支汇合点】**":
            sec = {"c1": "s2m", "c2": "s4m"}[cur_choice]
            continue
        if line == "> **【终场汇合与收束】**":
            sec = "s6m"
            continue

        if line.startswith("### ") or line.startswith("#### ") or line.startswith(">"):
            raise ValueError(f"Unhandled structural line: {line}")

        mb = BOLD_LINE_RE.match(line)
        if mb:
            raw_spk, stage_dir, quote = mb.group(1).strip(), mb.group(2).strip(), mb.group(3).strip()
            spk_key = BOLD_SPEAKER_NORM[raw_spk]
            text = f"{stage_dir}{quote}" if stage_dir else quote
            add_beat(sec, spk_key, text)
            continue

        if line.startswith("*") and line.endswith("*") and not line.startswith("**"):
            stripped = line[1:-1].strip()
            nid = add_beat(sec, "旁白", stripped)
            italic_strips.append({"node_id": nid, "original": line, "rendered": stripped})
            continue

        if "：「" in line and line.endswith("」"):
            act, quote = line.split("：「", 1)
            quote = "「" + quote
            matched_spk = None
            for token, norm_spk in PROSE_MIXED_SPEAKERS:
                if token in act:
                    matched_spk = norm_spk
                    break
            if matched_spk is None:
                raise ValueError(f"Cannot infer speaker for mixed line: {line}")
            nid1 = add_beat(sec, "旁白", act + "：")
            nid2 = add_beat(sec, matched_spk, quote)
            mixed_splits.append(
                {
                    "original": line,
                    "narrator_node": nid1,
                    "dialogue_node": nid2,
                    "speaker": matched_spk,
                }
            )
            continue

        add_beat(sec, "旁白", line)

    return beats, choices_zh, mixed_splits, italic_strips


def build_nodes(beats: list[dict], choices_zh: dict[str, str]) -> list[dict]:
    by_sec: dict[str, list[dict]] = {}
    for b in beats:
        by_sec.setdefault(b["sec"], []).append(b)

    next_map: dict[str, str] = {}

    def link_linear(sec_name: str, tail_target: str) -> None:
        arr = by_sec[sec_name]
        for i, b in enumerate(arr):
            next_map[b["id"]] = arr[i + 1]["id"] if i + 1 < len(arr) else tail_target

    link_linear("s1", by_sec["s2"][0]["id"])
    link_linear("s2", "ar5_choice_c1")
    link_linear("c1a", by_sec["s2m"][0]["id"])
    link_linear("c1b", by_sec["s2m"][0]["id"])
    link_linear("c1c", by_sec["s2m"][0]["id"])
    link_linear("s2m", by_sec["s2_2"][0]["id"])
    link_linear("s2_2", by_sec["s3_1"][0]["id"])
    link_linear("s3_1", by_sec["s3_2"][0]["id"])
    link_linear("s3_2", by_sec["s4"][0]["id"])
    link_linear("s4", "ar5_choice_c2")
    link_linear("c2a", by_sec["s4m"][0]["id"])
    link_linear("c2b", by_sec["s4m"][0]["id"])
    link_linear("s4m", by_sec["s5_1"][0]["id"])
    link_linear("s5_1", by_sec["s5_2"][0]["id"])
    link_linear("s5_2", by_sec["s6"][0]["id"])
    link_linear("s6", "ar5_choice_c3")
    link_linear("c3a", by_sec["s6m"][0]["id"])
    link_linear("c3b", by_sec["s6m"][0]["id"])
    link_linear("c3c", by_sec["s6m"][0]["id"])
    link_linear("s6m", "@end")

    choice_after = {
        by_sec["s2"][-1]["id"]: {
            "id": "ar5_choice_c1",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": ACTOR_ID,
            "text": "",
            "expression": "neutral",
            "outfit": "white_coat",
            "background_id": "artoria_office",
            "event_portraits": solo_staff("doc_artoria", "white_coat/neutral", x=1020),
            "choices": [
                {
                    "id": "choice_ar5_c1_a",
                    "label": choices_zh["choice_ar5_c1_a"],
                    "next": by_sec["c1a"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar5_c1_b",
                    "label": choices_zh["choice_ar5_c1_b"],
                    "next": by_sec["c1b"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar5_c1_c",
                    "label": choices_zh["choice_ar5_c1_c"],
                    "next": by_sec["c1c"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        by_sec["s4"][-1]["id"]: {
            "id": "ar5_choice_c2",
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
                    "id": "choice_ar5_c2_a",
                    "label": choices_zh["choice_ar5_c2_a"],
                    "next": by_sec["c2a"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar5_c2_b",
                    "label": choices_zh["choice_ar5_c2_b"],
                    "next": by_sec["c2b"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        by_sec["s6"][-1]["id"]: {
            "id": "ar5_choice_c3",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": ACTOR_ID,
            "text": "",
            "expression": "smile",
            "outfit": "white_coat",
            "background_id": "artoria_lv5_or_corridor_evening",
            "event_portraits": solo_staff("doc_artoria", "white_coat/smile", x=1020),
            "choices": [
                {
                    "id": "choice_ar5_c3_a",
                    "label": choices_zh["choice_ar5_c3_a"],
                    "next": by_sec["c3a"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar5_c3_b",
                    "label": choices_zh["choice_ar5_c3_b"],
                    "next": by_sec["c3b"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar5_c3_c",
                    "label": choices_zh["choice_ar5_c3_c"],
                    "next": by_sec["c3c"][0]["id"],
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


def update_backgrounds_and_staff_files() -> None:
    bg_id, bg_zh, _bg_en, bg_path = BACKGROUND_ENTRY
    if not (ROOT / bg_path).is_file():
        raise FileNotFoundError(f"Missing background PNG: {ROOT / bg_path}")
    bgs = read_json(BACKGROUNDS_PATH)
    by_id = {item["id"]: item for item in bgs}
    if bg_id in by_id:
        by_id[bg_id]["label"] = bg_zh
        by_id[bg_id]["path"] = bg_path
    else:
        bgs.append({"id": bg_id, "label": bg_zh, "path": bg_path})
    write_json(BACKGROUNDS_PATH, bgs)

    manifest = read_json(ASSETS_MANIFEST_PATH)
    existing_ids = {item["id"] for item in manifest.get("assets", [])}
    lv5_assets = [
        {
            "id": "portrait_story_guest_aoi_tohsaka_ward_neutral",
            "category": "guest_patient_portrait",
            "path": "assets/characters/artoria_lv5_v1/aoi_tohsaka/ward/neutral.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Aoi Tohsaka ward gown neutral RGBA portrait (derived from Codex aoi_patient_seed_v1/ward_seed.png; story guest only)",
        },
        {
            "id": "portrait_story_guest_aoi_tohsaka_ward_smile",
            "category": "guest_patient_portrait",
            "path": "assets/characters/artoria_lv5_v1/aoi_tohsaka/ward/smile.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Aoi Tohsaka ward gown gentle smile RGBA portrait (derived from Codex aoi_patient_seed_v1/ward_seed.png; story guest only)",
        },
        {
            "id": "portrait_story_guest_aoi_tohsaka_or_cap_calm",
            "category": "guest_patient_portrait",
            "path": "assets/characters/artoria_lv5_v1/aoi_tohsaka/or_cap/calm.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Aoi Tohsaka intraoperative OR cap calm RGBA bust (derived from Codex aoi_patient_seed_v1/intraoperative_seed.png; story guest only)",
        },
        {
            "id": "portrait_story_guest_aoi_tohsaka_or_cap_smile",
            "category": "guest_patient_portrait",
            "path": "assets/characters/artoria_lv5_v1/aoi_tohsaka/or_cap/smile.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Aoi Tohsaka intraoperative OR cap relieved smile RGBA bust (derived from Codex aoi_patient_seed_v1/intraoperative_seed.png; story guest only)",
        },
        {
            "id": "bg_artoria_lv5_or_corridor_evening",
            "category": "event_background",
            "path": bg_path,
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Evening 4F surgical corridor with wide double-paned glass observation window into lit OR prep room (Act 6)",
        },
        {
            "id": "cg_doc_artoria_lv5_observation_window_epilogue",
            "category": "event_cg_placeholder",
            "path": "",
            "status": "pending_codex_illustration",
            "runtime_connected": False,
            "trigger": EVENT_ID,
            "notes": "Placeholder reserved for Codex: Act 6 evening OR corridor observation window epilogue (nodes ar5_s6_05..ar5_s6_08; recommended gallery cover)",
        },
        {
            "id": "cg_doc_artoria_lv5_hepp_couinaud_anastomosis",
            "category": "event_cg_placeholder",
            "path": "",
            "status": "pending_codex_illustration",
            "runtime_connected": False,
            "trigger": EVENT_ID,
            "notes": "Placeholder reserved for Codex: Act 4 Hepp-Couinaud left hepatic duct spatulation & 6-0 hepaticojejunostomy close-up (nodes ar5_s4m_06..ar5_s4m_11)",
        },
        {
            "id": "cg_doc_artoria_lv5_ange_mentorship_folder",
            "category": "event_cg_placeholder",
            "path": "",
            "status": "pending_codex_illustration",
            "runtime_connected": False,
            "trigger": EVENT_ID,
            "notes": "Optional placeholder reserved for Codex: Act 5.1 handing perioperative risk-verification coordinator plan folder to Anji Tonegawa (nodes ar5_s5_1_15..ar5_s5_1_22)",
        },
    ]
    for item in lv5_assets:
        if item["id"] not in existing_ids:
            manifest["assets"].append(item)
            existing_ids.add(item["id"])
    write_json(ASSETS_MANIFEST_PATH, manifest)

    cg_mappings = read_json(CG_MAPPING_PATH)
    existing_lv5_cg = cg_mappings.get(EVENT_ID, {})
    cg_mappings[EVENT_ID] = {
        "cover": existing_lv5_cg.get("cover", ""),
        "scenes": existing_lv5_cg.get("scenes", []),
        "planned_placeholders_for_codex": CODEX_CG_PLACEHOLDERS,
    }
    write_json(CG_MAPPING_PATH, cg_mappings)

    bundle = read_json(BUNDLE_PATH)
    extras = bundle.setdefault("additional_character_event_files", [])
    if "lv5_events.json" not in extras:
        extras.append("lv5_events.json")
    write_json(BUNDLE_PATH, bundle)

    rel = read_json(RELATIONSHIP_PATH)
    slot5 = next(s for s in rel["rank_slots"] if s["target_level"] == 5)
    slot5["event_id"] = EVENT_ID
    slot5["content_status"] = "authored"
    slot5["benefit_id"] = "unlock_clinical_practice_patient"
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

    bg_id, bg_zh, bg_en, _ = BACKGROUND_ENTRY
    zh_strings[f"collections.backgrounds.{bg_id}.label"] = bg_zh
    en_strings[f"collections.backgrounds.{bg_id}.label"] = bg_en

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

    beats, choices_zh, mixed_splits, italic_strips = parse_manuscript()
    nodes = build_nodes(beats, choices_zh)
    en_data = read_json(EN_TRANSLATION_PATH)

    event_obj = {
        "id": EVENT_ID,
        "actor_id": ACTOR_ID,
        "title": "我的位置",
        "chapter": 5,
        "location_id": "artoria_office",
        "trigger_mode": "location",
        "background_id": "shared_doctors_office",
        "outfit": "white_coat",
        "completion_background_id": "artoria_lv5_or_corridor_evening",
        "completion_outfit": "white_coat",
        "completion_expression": "smile",
        "hide_calendar_header": True,
        "minutes": 0,
        "completion_day_offset": 2,
        "completion_absolute_clock": 540,
        "teaser": "面对本季度唯一一席器械带教名额的取舍与远坂葵女士的高风险开放胆道重建术，坂口隆司与阿尔托莉雅共同签下决定、接住留下的失落，也让她在手术室观察窗外看清了属于自己的位置。",
        "time_start": 540,
        "time_end": 720,
        "priority": 185,
        "category": "rank_up",
        "gallery": {
            "cg_id": "cg_artoria_lv5_my_position",
            "caption": "在远坂葵的开放肝管空肠吻合术与利根川安琪的坦诚追问落定之后，阿尔托莉雅在四楼手术部观察窗外驻足回望那支亲手护育成型的团队，第一次笑着想象将自己也交到这张手术台上。",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "max_day": 362,
            "min_affection": 0,
            "min_familiarity": 75,
            "required_events": [
                "artoria_lv4_just_artoria"
            ],
            "days_after_required_events": 3,
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "leadership",
                    "minimum": 90
                },
                {
                    "type": "player_attribute",
                    "attribute": "skill",
                    "minimum": 80
                }
            ]
        },
        "auto_start": False,
        "locks_saving": True,
        "target_level": 5,
        "benefit_id": "unlock_clinical_practice_patient",
        "completion_story_flags": [
            "artoria_lv5_complete"
        ],
        "start": "ar5_s1_01",
        "nodes": nodes,
    }

    update_backgrounds_and_staff_files()
    from artoria_cg_mapping import apply_cg_mapping
    apply_cg_mapping(event_obj)
    write_json(EVENTS_PATH, [event_obj])
    update_localization(event_obj, en_data)

    import_manifest = {
        "event_id": EVENT_ID,
        "actor_id": ACTOR_ID,
        "target_level": 5,
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
        "markdown_italic_syntax_strips": italic_strips,
        "codex_cg_placeholders": CODEX_CG_PLACEHOLDERS,
        "story_guest": {
            "id": "story_guest_aoi_tohsaka",
            "name": "远坂葵",
            "source_seeds_dir": "research/generated_candidates/aoi_patient_seed_v1",
            "random_pool": False,
            "surgery_queue": False,
        },
    }
    write_json(IMPORT_MANIFEST_PATH, import_manifest)
    print(
        f"Imported {EVENT_ID}: {len(beats)} beats, {len(nodes)} nodes, "
        f"{len(mixed_splits)} mixed splits, {len(italic_strips)} italic strip(s)."
    )


if __name__ == "__main__":
    main()
