#!/usr/bin/env python3
"""Import Artoria Pendragon (`doc_artoria`) Relationship Lv3 milestone event:
《不是一个人的手术》 (Not a One-Person Operation, ID: `artoria_lv3_not_a_solo_operation`, V1.1).

Updates:
- data/staff/doc_artoria/profile.json
- data/staff/doc_artoria/assets_manifest.json
- data/staff/doc_artoria/bundle.json
- data/staff/doc_artoria/relationship.json
- data/staff/doc_artoria/lv3_events.json
- data/localization/zh_CN.json & data/localization/en.json
- research/imports/artoria_lv3_2026-11-16.json
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_ARTORIA_LV3_NOT_A_SOLO_OPERATION_V1_1.md"
EN_TRANSLATION_PATH = ROOT / "research/translations/artoria_lv3_en.json"
STAFF_DIR = ROOT / "data/staff/doc_artoria"
PROFILE_PATH = STAFF_DIR / "profile.json"
ASSETS_MANIFEST_PATH = STAFF_DIR / "assets_manifest.json"
BUNDLE_PATH = STAFF_DIR / "bundle.json"
RELATIONSHIP_PATH = STAFF_DIR / "relationship.json"
EVENTS_PATH = STAFF_DIR / "lv3_events.json"
ZH_LOCALE_PATH = ROOT / "data/localization/zh_CN.json"
EN_LOCALE_PATH = ROOT / "data/localization/en.json"
IMPORT_MANIFEST_PATH = ROOT / "research/imports/artoria_lv3_2026-11-16.json"

EVENT_ID = "artoria_lv3_not_a_solo_operation"
ACTOR_ID = "doc_artoria"

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
    ("nurse_moe", "uniform/startled"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/startled.png",
    ("nurse_moe", "uniform/laugh"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/laugh.png",
    ("nurse_moe", "uniform/warm"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/warm.png",
    ("nurse_moe", "uniform/cheerful"): "assets/characters/portrait_pack_v13/nurse_moe/uniform/cheerful.png",
    ("nurse_moe", "scrubs/neutral"): "assets/characters/moe_circulating_v1/neutral.png",
    ("nurse_ange", "uniform/neutral"): "assets/characters/portrait_pack_v11/nurse_ange/uniform/neutral.png",
    ("nurse_ange", "uniform/smile"): "assets/characters/portrait_pack_v11/nurse_ange/uniform/smile.png",
    ("nurse_ange", "uniform/serious"): "assets/characters/portrait_pack_v11/nurse_ange/uniform/serious.png",
    ("nurse_ange", "uniform/surprised"): "assets/characters/portrait_pack_v11/nurse_ange/uniform/surprised.png",
    ("nurse_ange", "scrubs/neutral"): "assets/characters/portrait_pack_v11/nurse_ange/scrubs/neutral.png",
    ("nurse_ange", "scrubs/focused"): "assets/characters/portrait_pack_v11/nurse_ange/scrubs/focused.png",
    ("nurse_ange", "scrubs/warm"): "assets/characters/portrait_pack_v11/nurse_ange/scrubs/warm.png",
    ("nurse_hiroko", "uniform/neutral"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/neutral.png",
    ("nurse_hiroko", "uniform/serious"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/serious.png",
    ("nurse_hiroko", "uniform/smile"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/smile.png",
    ("nurse_hiroko", "uniform/closed_eye_smile"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/closed_eye_smile.png",
    ("nurse_hiroko", "uniform/worried"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/worried.png",
    ("nurse_hiroko", "sterile/neutral"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/neutral.png",
    ("nurse_hiroko", "sterile/focused"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/focused.png",
    ("nurse_hiroko", "sterile/warm"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/warm.png",
    ("story_guest_irisviel", "ward/smile"): "assets/characters/artoria_lv3_v1/irisviel/ward/smile.png",
    ("story_guest_irisviel", "ward/relieved"): "assets/characters/artoria_lv3_v1/irisviel/ward/relieved.png",
    ("story_guest_irisviel", "or_cap/calm"): "assets/characters/artoria_lv3_v1/irisviel/or_cap/calm.png",
    ("story_guest_irisviel", "or_cap/smile"): "assets/characters/artoria_lv3_v1/irisviel/or_cap/smile.png",
    ("story_guest_irisviel", "or_cap/drowsy"): "assets/characters/artoria_lv3_v1/irisviel/or_cap/drowsy.png",
}

SPEAKER_MAP = {
    "旁白": ("narrator", "doc_artoria", "旁白"),
    "阿尔托莉雅·潘德拉贡": ("actor", "doc_artoria", "阿尔托莉雅·潘德拉贡"),
    "坂口隆司": ("player", "doc_artoria", "坂口隆司"),
    "本庄萌恵": ("actor", "nurse_moe", "本庄萌恵"),
    "利根川安琪": ("actor", "nurse_ange", "利根川安琪"),
    "杉村弘子": ("actor", "nurse_hiroko", "杉村弘子"),
    "本庄萌恵・利根川安琪": ("actor", "nurse_moe", "本庄萌恵・利根川安琪"),
    "爱丽丝菲尔·冯·爱因兹贝伦": ("actor", "doc_artoria", "爱丽丝菲尔·冯·爱因兹贝伦"),
}

PURE_SPEAKERS = [
    "阿尔托莉雅·潘德拉贡",
    "坂口隆司",
    "本庄萌恵",
    "利根川安琪",
    "杉村弘子",
    "爱丽丝菲尔·冯·爱因兹贝伦",
]

MIXED_PREFIX_SPEAKERS = [
    ("本庄萌恵与利根川安琪对视一眼", "本庄萌恵・利根川安琪"),
    ("这一次，本庄萌恵", "本庄萌恵"),
    ("一直最怕在长辈面前大声说话的本庄萌恵", "本庄萌恵"),
    ("正在倒热水的杉村弘子", "杉村弘子"),
    ("就在这时，坂口隆司", "坂口隆司"),
    ("一旁的坂口隆司", "坂口隆司"),
    ("站在旁边的坂口隆司", "坂口隆司"),
    ("一直站在她身侧半步之遥的坂口隆司", "坂口隆司"),
    ("旁边的利根川安琪", "利根川安琪"),
    ("爱丽丝菲尔", "爱丽丝菲尔·冯·爱因兹贝伦"),
    ("阿尔托莉雅", "阿尔托莉雅·潘德拉贡"),
    ("坂口隆司", "坂口隆司"),
    ("本庄萌恵", "本庄萌恵"),
    ("利根川安琪", "利根川安琪"),
    ("杉村弘子", "杉村弘子"),
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


def ward_irisviel_and_staff(iri_key: str, staff_actor: str, staff_key: str) -> list[dict]:
    return [
        {
            "id": "irisviel",
            "path": CAST_PORTRAITS[("story_guest_irisviel", iri_key)],
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


def or_irisviel_with_staff(iri_key: str, staff_actor: str, staff_key: str) -> list[dict]:
    return [
        {
            "id": "irisviel",
            "path": CAST_PORTRAITS[("story_guest_irisviel", iri_key)],
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

    # Scene 1: 4F surgical nurses' lounge
    if sec == "s1":
        if idx in (1, 2):
            return ("staff_lounge", "white_coat", "neutral", None)
        return ("staff_lounge", "white_coat", "neutral", duo_staff("nurse_moe", "uniform/warm", "nurse_hiroko", "uniform/smile"))
    if sec in ("s1_em3a", "s1_em3b"):
        return ("staff_lounge", "white_coat", "neutral", duo_staff("nurse_moe", "uniform/surprised", "nurse_hiroko", "uniform/smile"))
    if sec == "s1m":
        if idx <= 5:
            return ("staff_lounge", "white_coat", "neutral", duo_staff("nurse_moe", "uniform/surprised", "nurse_ange", "uniform/smile"))
        if idx in (6, 7):
            return ("staff_lounge", "white_coat", "neutral", duo_staff("nurse_hiroko", "uniform/smile", "nurse_ange", "uniform/neutral"))
        if idx in (8, 9, 10, 11):
            return ("staff_lounge", "white_coat", "neutral", duo_staff("nurse_moe", "uniform/neutral", "nurse_hiroko", "uniform/smile"))
        if idx in (12, 13):
            return ("staff_lounge", "white_coat", "neutral", duo_staff("nurse_moe", "uniform/startled", "nurse_ange", "uniform/smile"))
        return ("staff_lounge", "white_coat", "neutral", duo_staff("nurse_hiroko", "uniform/smile", "nurse_ange", "uniform/smile"))
    if sec in ("c1a_1", "c1a_2"):
        return ("staff_lounge", "white_coat", "neutral", duo_staff("nurse_hiroko", "uniform/smile", "nurse_ange", "uniform/smile"))
    if sec == "c1b":
        return ("staff_lounge", "white_coat", "neutral", duo_staff("nurse_moe", "uniform/warm", "nurse_hiroko", "uniform/smile"))
    if sec == "c1c":
        return ("staff_lounge", "white_coat", "neutral", duo_staff("nurse_hiroko", "uniform/smile", "nurse_ange", "uniform/smile"))
    if sec == "s1r":
        if idx in (1, 2):
            return ("staff_lounge", "white_coat", "neutral", duo_staff("nurse_moe", "uniform/neutral", "nurse_hiroko", "uniform/smile"))
        return ("staff_lounge", "white_coat", "neutral", solo_staff("nurse_moe", "uniform/worried"))

    # Scene 2: 3F surgical nurses' station discussion counter
    if sec == "s2":
        if idx == 1:
            return ("nurses_station", "white_coat", "neutral", solo_staff("doc_artoria", "white_coat/neutral"))
        if idx in (2, 3):
            return ("nurses_station", "white_coat", "smile", duo_staff("nurse_moe", "uniform/shy", "doc_artoria", "white_coat/smile"))
        if 4 <= idx <= 13:
            moe_expr = "shy" if idx <= 8 else ("cheerful" if idx in (9, 10) else "worried")
            return ("nurses_station", "white_coat", "neutral", duo_staff("nurse_moe", f"uniform/{moe_expr}", "doc_artoria", "white_coat/neutral"))
        if idx in (14, 15, 16, 17, 18, 19, 20, 21):
            return ("nurses_station", "white_coat", "neutral", duo_staff("nurse_moe", "uniform/neutral", "doc_artoria", "white_coat/neutral"))
        if idx in (22, 23):
            return ("nurses_station", "white_coat", "smile", duo_staff("nurse_moe", "uniform/cheerful", "doc_artoria", "white_coat/smile"))
        if idx in (24, 25):
            return ("nurses_station", "white_coat", "smile", duo_staff("nurse_moe", "uniform/smile", "nurse_hiroko", "uniform/smile"))
        if 26 <= idx <= 32:
            ange_expr = "smile" if idx >= 28 else "serious"
            art_expr = "smile" if idx in (31, 32) else "neutral"
            return ("nurses_station", "white_coat", art_expr, duo_staff("nurse_ange", f"uniform/{ange_expr}", "doc_artoria", f"white_coat/{art_expr}"))
        if 33 <= idx <= 39:
            ange_expr = "surprised" if idx >= 35 else "smile"
            return ("nurses_station", "white_coat", "neutral", duo_staff("nurse_ange", f"uniform/{ange_expr}", "doc_artoria", "white_coat/neutral"))
        if idx in (40, 41):
            return ("nurses_station", "white_coat", "neutral", duo_staff("nurse_ange", "uniform/serious", "doc_artoria", "white_coat/neutral"))
        if idx in (42, 43, 44, 45):
            return ("nurses_station", "white_coat", "neutral", solo_staff("doc_artoria", "white_coat/neutral"))
        return ("nurses_station", "white_coat", "smile", solo_staff("doc_artoria", "white_coat/smile"))

    # Scene 3.1: Pre-op briefing, Irisviel reunion, Sakaguchi's thoracic epidural
    if sec == "s3_1":
        if idx in (1, 2):
            return ("or_entrance", "scrubs_masked", "focused", duo_staff("nurse_hiroko", "sterile/focused", "doc_artoria", "scrubs_masked/focused"))
        if idx == 3:
            return ("operating_room", "scrubs_masked", "neutral", None)
        if 4 <= idx <= 14:
            iri_expr = "smile" if idx in (4, 5, 11, 12) else "calm"
            return ("operating_room", "scrubs_masked", "neutral", or_irisviel_with_staff(f"or_cap/{iri_expr}", "doc_artoria", "scrubs_masked/neutral"))
        if idx in (15, 16):
            return ("operating_room", "scrubs_masked", "focused", or_irisviel_with_staff("or_cap/calm", "doc_artoria", "scrubs_masked/focused"))
        if 17 <= idx <= 24:
            iri_expr = "smile" if idx >= 23 else "calm"
            return ("operating_room", "scrubs_masked", "neutral", or_irisviel_with_staff(f"or_cap/{iri_expr}", "nurse_moe", "scrubs/neutral"))
        if 25 <= idx <= 28:
            return ("operating_room", "scrubs_masked", "focused", or_irisviel_with_staff("or_cap/calm", "nurse_moe", "scrubs/neutral"))
        if idx == 29:
            return ("operating_room", "scrubs_masked", "neutral", or_irisviel_with_staff("or_cap/drowsy", "nurse_moe", "scrubs/neutral"))
        return ("operating_room", "sterile", "neutral", duo_staff("nurse_hiroko", "sterile/warm", "doc_artoria", "sterile/neutral"))

    # Scene 3.2: Open distal gastrectomy, gastroduodenal artery scar adhesion, team relay
    if sec == "s3_2":
        if idx in (1, 2):
            return ("operating_room", "sterile", "focused", None)
        if idx in (3, 11, 12, 15, 16):
            return ("operating_room", "sterile", "focused", duo_staff("nurse_hiroko", "sterile/focused", "doc_artoria", "sterile/focused"))
        if idx in (18, 19, 20):
            return ("operating_room", "sterile", "focused", duo_staff("nurse_moe", "scrubs/neutral", "doc_artoria", "sterile/focused"))
        return ("operating_room", "sterile", "focused", solo_staff("doc_artoria", "sterile/focused", x=1020))
    if sec in ("c2a", "c2b", "c2c"):
        if sec == "c2a" and idx == 2:
            return ("operating_room", "sterile", "focused", duo_staff("nurse_hiroko", "sterile/focused", "doc_artoria", "sterile/focused"))
        return ("operating_room", "sterile", "focused", solo_staff("doc_artoria", "sterile/focused", x=1020))
    if sec == "s3_2r":
        if idx in (1, 2):
            return ("operating_room", "sterile", "focused", None)
        if 3 <= idx <= 10:
            return ("operating_room", "sterile", "focused", duo_staff("nurse_moe", "scrubs/neutral", "doc_artoria", "sterile/focused"))
        if 11 <= idx <= 17:
            return ("operating_room", "sterile", "focused", duo_staff("nurse_moe", "scrubs/neutral", "doc_artoria", "sterile/focused"))
        if idx in (18, 19):
            return ("operating_room", "sterile", "focused", duo_staff("nurse_moe", "scrubs/neutral", "nurse_ange", "scrubs/focused"))
        if idx == 20:
            return ("operating_room", "sterile", "focused", duo_staff("nurse_hiroko", "sterile/focused", "doc_artoria", "sterile/focused"))
        if idx in (21, 22, 23):
            return ("operating_room", "sterile", "neutral", duo_staff("nurse_moe", "scrubs/neutral", "doc_artoria", "sterile/neutral"))
        if 24 <= idx <= 27:
            return ("operating_room", "sterile", "focused", solo_staff("doc_artoria", "sterile/focused"))
        if idx in (28, 29):
            return ("operating_room", "sterile", "neutral", duo_staff("nurse_hiroko", "sterile/warm", "nurse_moe", "scrubs/neutral"))
        return ("operating_room", "sterile", "neutral", duo_staff("nurse_hiroko", "sterile/warm", "doc_artoria", "sterile/neutral"))

    # Scene 4: Post-op observation ward & 4F OR outer prep corridor
    if sec == "s4":
        if idx == 1:
            return ("ward", "white_coat", "neutral", None)
        if 2 <= idx <= 5:
            return ("ward", "white_coat", "smile", ward_irisviel_and_staff("ward/relieved", "doc_artoria", "white_coat/smile"))
        if idx in (6, 7):
            return ("ward", "white_coat", "smile", ward_irisviel_and_staff("ward/smile", "doc_artoria", "white_coat/smile"))
        if idx in (8, 9):
            return ("ward", "white_coat", "smile", duo_staff("nurse_moe", "uniform/shy", "nurse_ange", "uniform/smile"))
        if idx == 10:
            return ("or_entrance", "white_coat", "neutral", None)
        if idx in (11, 12):
            return ("or_entrance", "white_coat", "neutral", duo_staff("nurse_hiroko", "uniform/smile", "doc_artoria", "white_coat/neutral"))
        if 13 <= idx <= 20:
            moe_expr = "shy" if idx in (15, 16) else ("surprised" if idx == 14 else "neutral")
            art_expr = "smile" if idx in (17, 18) else "neutral"
            return ("or_entrance", "white_coat", art_expr, duo_staff("nurse_moe", f"uniform/{moe_expr}", "doc_artoria", f"white_coat/{art_expr}"))
        if idx in (21, 22):
            return ("or_entrance", "white_coat", "smile", duo_staff("nurse_moe", "uniform/cheerful", "doc_artoria", "white_coat/smile"))
        if idx in (23, 24):
            return ("or_entrance", "white_coat", "smile", duo_staff("nurse_moe", "uniform/smile", "nurse_ange", "uniform/smile"))
        return ("or_entrance", "white_coat", "smile", duo_staff("nurse_hiroko", "uniform/closed_eye_smile", "doc_artoria", "white_coat/smile"))

    # Scene 5: Break area beside surgical doctors' office — "A leader also serves the team" & empty-stomach dizziness
    if sec == "s5":
        if idx == 1:
            return ("staff_lounge", "white_coat", "neutral", None)
        if idx in (2, 3, 4):
            return ("staff_lounge", "white_coat", "neutral", duo_staff("nurse_moe", "uniform/warm", "doc_artoria", "white_coat/neutral"))
        if 5 <= idx <= 8:
            return ("staff_lounge", "white_coat", "smile", duo_staff("nurse_moe", "uniform/warm", "doc_artoria", "white_coat/smile"))
        if idx == 9:
            return ("staff_lounge", "white_coat", "smile", duo_staff("nurse_ange", "uniform/serious", "doc_artoria", "white_coat/smile"))
        if idx in (10, 11, 12):
            return ("staff_lounge", "white_coat", "neutral", solo_staff("doc_artoria", "white_coat/neutral"))
        if idx in (13, 14, 15):
            return ("staff_lounge", "white_coat", "shy", solo_staff("doc_artoria", "white_coat/shy"))
        if idx in (16, 17):
            return ("staff_lounge", "white_coat", "shy", duo_staff("nurse_moe", "uniform/startled", "doc_artoria", "white_coat/shy"))
        if idx in (18, 19, 20):
            return ("staff_lounge", "white_coat", "embarrassed", solo_staff("doc_artoria", "white_coat/embarrassed"))
        if idx in (21, 22, 23):
            return ("staff_lounge", "white_coat", "embarrassed", duo_staff("nurse_hiroko", "uniform/serious", "doc_artoria", "white_coat/embarrassed"))
        if idx in (24, 25):
            return ("staff_lounge", "white_coat", "embarrassed", duo_staff("nurse_ange", "uniform/surprised", "doc_artoria", "white_coat/embarrassed"))
        if 26 <= idx <= 35:
            return ("staff_lounge", "white_coat", "embarrassed", solo_staff("doc_artoria", "white_coat/embarrassed", x=1020))
        if 36 <= idx <= 39:
            return ("staff_lounge", "white_coat", "shy", duo_staff("nurse_moe", "uniform/shy", "doc_artoria", "white_coat/shy"))
        if idx == 40:
            return ("staff_lounge", "white_coat", "shy", solo_staff("doc_artoria", "white_coat/shy", x=1020))
        if idx in (41, 42):
            return ("staff_lounge", "white_coat", "shy", duo_staff("nurse_hiroko", "uniform/smile", "doc_artoria", "white_coat/shy"))
        if idx in (43, 44):
            return ("staff_lounge", "white_coat", "shy", duo_staff("nurse_ange", "uniform/smile", "doc_artoria", "white_coat/shy"))
        return ("staff_lounge", "white_coat", "shy", solo_staff("doc_artoria", "white_coat/shy", x=1020))

    if sec in ("c3a", "c3b"):
        expr = "smile" if idx >= 3 else "shy"
        return ("staff_lounge", "white_coat", expr, solo_staff("doc_artoria", f"white_coat/{expr}", x=1020))
    if sec == "c3c":
        if idx == 3:
            return ("staff_lounge", "white_coat", "embarrassed", duo_staff("nurse_hiroko", "uniform/closed_eye_smile", "nurse_moe", "uniform/laugh"))
        return ("staff_lounge", "white_coat", "embarrassed", solo_staff("doc_artoria", "white_coat/embarrassed", x=1020))
    if sec == "s5r":
        if idx == 1:
            return ("staff_lounge", "white_coat", "shy", duo_staff("nurse_ange", "uniform/smile", "doc_artoria", "white_coat/shy"))
        if idx in (2, 3, 4):
            return ("staff_lounge", "white_coat", "neutral", solo_staff("doc_artoria", "white_coat/neutral", x=1020))
        if idx in (5, 6):
            return ("staff_lounge", "white_coat", "smile", duo_staff("nurse_moe", "uniform/cheerful", "doc_artoria", "white_coat/smile"))
        if idx in (7, 8):
            return ("staff_lounge", "white_coat", "smile", solo_staff("doc_artoria", "white_coat/smile", x=1020))
        if idx in (9, 10, 11):
            return ("staff_lounge", "white_coat", "embarrassed", solo_staff("doc_artoria", "white_coat/embarrassed", x=1020))
        if idx in (12, 13):
            return ("staff_lounge", "white_coat", "embarrassed", duo_staff("nurse_ange", "uniform/surprised", "doc_artoria", "white_coat/embarrassed"))
        if idx in (14, 15):
            return ("staff_lounge", "white_coat", "embarrassed", solo_staff("doc_artoria", "white_coat/embarrassed", x=1020))
        if idx == 16:
            return ("staff_lounge", "white_coat", "smile", duo_staff("nurse_moe", "uniform/laugh", "nurse_hiroko", "uniform/closed_eye_smile"))
        if idx in (17, 18, 19, 23):
            return ("staff_lounge", "white_coat", "smile", solo_staff("doc_artoria", "white_coat/smile", x=1020))
        return ("staff_lounge", "white_coat", "neutral", None)

    raise ValueError(f"Unhandled node staging: {nid} ({sec})")


def parse_manuscript() -> tuple[list[dict], dict[str, str], int, int]:
    md = MANUSCRIPT_PATH.read_text(encoding="utf-8")
    body = md.split("## 二、 完整中文 VN 剧本正文", 1)[1].split(
        "**【阿尔托莉雅·潘德拉贡 Relationship Lv3《不是一个人的手术》事件结束】**", 1
    )[0]

    sec = ""
    active = False
    cur_choice = ""
    counts: dict[str, int] = {}
    beats: list[dict] = []
    choices_zh: dict[str, str] = {}
    mixed_split_count = 0
    italic_strip_count = 0

    def push(section: str, spk: str, txt: str) -> None:
        counts[section] = counts.get(section, 0) + 1
        nid = f"ar3_{section}_{counts[section]:02d}"
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
        if s.startswith("### 【第一幕"):
            sec = "s1"
            active = False
            continue
        if s.startswith("### 【第二幕"):
            sec = "s2"
            active = False
            continue
        if s.startswith("### 【第三幕"):
            continue
        if s.startswith("#### 3.1 "):
            sec = "s3_1"
            active = False
            continue
        if s.startswith("#### 3.2 "):
            sec = "s3_2"
            active = False
            continue
        if s.startswith("### 【第四幕"):
            sec = "s4"
            active = False
            continue
        if s.startswith("### 【第五幕"):
            sec = "s5"
            active = False
            continue
        if s == "**【玩家可见正文】**":
            active = True
            continue
        if s.startswith("*(") or s.startswith("*性质："):
            continue
        if s.startswith("#### 〈条件分支 A"):
            sec = "s1_em3a"
            active = True
            continue
        if s.startswith("#### 〈条件分支 B"):
            sec = "s1_em3b"
            active = True
            continue
        if s.startswith("> **【第一幕公共主线汇合】**"):
            sec = "s1m"
            active = True
            continue
        m_ch = re.match(r"^\*\*【选择 (\d+)：.+】\*\*$", s)
        if m_ch:
            cur_choice = f"c{m_ch.group(1)}"
            active = False
            continue
        m_opt = re.match(r"^- \*\*选项 ([ABC])：(.+)\*\*$", s)
        if m_opt:
            choices_zh[f"choice_ar3_{cur_choice}_{m_opt.group(1).lower()}"] = m_opt.group(2)
            continue
        m_br = re.match(r"^#### 【分支 ([ABC])\b", s)
        if m_br:
            sec = f"{cur_choice}{m_br.group(1).lower()}"
            active = True
            continue
        if s.startswith("- **〈子分支 A-1"):
            sec = "c1a_1"
            active = True
            continue
        if s.startswith("- **〈子分支 A-2"):
            sec = "c1a_2"
            active = True
            continue
        if s.startswith("> **【主线汇合"):
            sec = {"c1": "s1r", "c2": "s3_2r", "c3": "s5r"}[cur_choice]
            active = True
            continue
        if not active:
            continue

        m_pure = re.match(r"^(" + "|".join(map(re.escape, PURE_SPEAKERS)) + r")：(「.*」)$", s)
        if m_pure:
            push(sec, m_pure.group(1), m_pure.group(2))
            continue

        if "：「" in s:
            act, quote = s.split("：", 1)
            spk = next((target for pfx, target in MIXED_PREFIX_SPEAKERS if act.startswith(pfx)), None)
            if spk is None:
                raise ValueError(f"Unmapped mixed action+dialogue line: {s!r}")
            mixed_split_count += 1
            push(sec, "旁白", act + "：")
            push(sec, spk, quote)
            continue

        if "*" in s:
            italic_strip_count += 1
            s = s.replace("*", "")
        push(sec, "旁白", s)

    return beats, choices_zh, mixed_split_count, italic_strip_count


def build_nodes(beats: list[dict], choices_zh: dict[str, str]) -> list[dict]:
    if len(beats) != 294:
        raise ValueError(f"Expected 294 beats, got {len(beats)}")

    by_sec: dict[str, list[dict]] = {}
    for b in beats:
        by_sec.setdefault(b["sec"], []).append(b)

    next_map: dict[str, str] = {}
    for sec, sec_beats in by_sec.items():
        for i in range(len(sec_beats) - 1):
            next_map[sec_beats[i]["id"]] = sec_beats[i + 1]["id"]

    # Cross-section transitions & default static targets (dynamically overridden by ArtoriaLv3.cast_definition)
    next_map["ar3_s1_03"] = "ar3_s1_em3b_01"  # default B; rewritten to ar3_s1_em3a_01 when Emiko Lv3 done
    next_map["ar3_s1_em3a_04"] = "ar3_s1m_01"
    next_map["ar3_s1_em3b_04"] = "ar3_s1m_01"
    next_map["ar3_s1m_16"] = "ar3_choice_c1"
    next_map["ar3_c1a_1_06"] = "ar3_s1r_01"
    next_map["ar3_c1a_2_06"] = "ar3_s1r_01"
    next_map["ar3_c1b_04"] = "ar3_s1r_01"
    next_map["ar3_c1c_04"] = "ar3_s1r_01"
    next_map["ar3_s1r_04"] = "ar3_s2_01"
    next_map["ar3_s2_47"] = "ar3_s3_1_01"
    next_map["ar3_s3_1_30"] = "ar3_s3_2_01"
    next_map["ar3_s3_2_20"] = "ar3_choice_c2"
    next_map["ar3_c2a_03"] = "ar3_s3_2r_01"
    next_map["ar3_c2b_03"] = "ar3_s3_2r_01"
    next_map["ar3_c2c_03"] = "ar3_s3_2r_01"
    next_map["ar3_s3_2r_30"] = "ar3_s4_01"
    next_map["ar3_s4_26"] = "ar3_s5_01"
    next_map["ar3_s5_45"] = "ar3_choice_c3"
    next_map["ar3_c3a_04"] = "ar3_s5r_01"
    next_map["ar3_c3b_04"] = "ar3_s5r_01"
    next_map["ar3_c3c_05"] = "ar3_s5r_01"
    next_map["ar3_s5r_23"] = "@end"

    choice_after: dict[str, dict] = {
        "ar3_s1m_16": {
            "id": "ar3_choice_c1",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": ACTOR_ID,
            "text": "",
            "expression": "neutral",
            "outfit": "white_coat",
            "background_id": "staff_lounge",
            "event_portraits": solo_staff("nurse_ange", "uniform/smile", x=1020),
            "choices": [
                {
                    "id": "choice_ar3_c1_a",
                    "label": choices_zh["choice_ar3_c1_a"],
                    "next": "ar3_c1a_2_01",  # default A-2; rewritten to ar3_c1a_1_01 when Emiko Lv1 done
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar3_c1_b",
                    "label": choices_zh["choice_ar3_c1_b"],
                    "next": "ar3_c1b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar3_c1_c",
                    "label": choices_zh["choice_ar3_c1_c"],
                    "next": "ar3_c1c_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        "ar3_s3_2_20": {
            "id": "ar3_choice_c2",
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
                    "id": "choice_ar3_c2_a",
                    "label": choices_zh["choice_ar3_c2_a"],
                    "next": "ar3_c2a_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar3_c2_b",
                    "label": choices_zh["choice_ar3_c2_b"],
                    "next": "ar3_c2b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar3_c2_c",
                    "label": choices_zh["choice_ar3_c2_c"],
                    "next": "ar3_c2c_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        "ar3_s5_45": {
            "id": "ar3_choice_c3",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": ACTOR_ID,
            "text": "",
            "expression": "shy",
            "outfit": "white_coat",
            "background_id": "staff_lounge",
            "event_portraits": solo_staff("doc_artoria", "white_coat/shy", x=1020),
            "choices": [
                {
                    "id": "choice_ar3_c3_a",
                    "label": choices_zh["choice_ar3_c3_a"],
                    "next": "ar3_c3a_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar3_c3_b",
                    "label": choices_zh["choice_ar3_c3_b"],
                    "next": "ar3_c3b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_ar3_c3_c",
                    "label": choices_zh["choice_ar3_c3_c"],
                    "next": "ar3_c3c_01",
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
    profile["visuals"]["portraits"]["white_coat/shy"] = "assets/characters/artoria_lv3_v1/doc_artoria/white_coat/shy.png"
    write_json(PROFILE_PATH, profile)

    manifest = read_json(ASSETS_MANIFEST_PATH)
    existing_ids = {item["id"] for item in manifest.get("assets", [])}
    aid = "portrait_doc_artoria_white_coat_shy"
    if aid not in existing_ids:
        manifest["assets"].append(
            {
                "id": aid,
                "category": "character_portrait",
                "path": "assets/characters/artoria_lv3_v1/doc_artoria/white_coat/shy.png",
                "status": "integrated",
                "runtime_connected": True,
                "trigger": EVENT_ID,
                "notes": "Artoria Lv3 caught-off-guard sheepish blush portrait (Scene 5 sofa scene)",
            }
        )
    write_json(ASSETS_MANIFEST_PATH, manifest)

    bundle = read_json(BUNDLE_PATH)
    extras = bundle.setdefault("additional_character_event_files", [])
    if "lv3_events.json" not in extras:
        extras.append("lv3_events.json")
    write_json(BUNDLE_PATH, bundle)

    rel = read_json(RELATIONSHIP_PATH)
    slot3 = next(s for s in rel["rank_slots"] if s["target_level"] == 3)
    slot3["event_id"] = EVENT_ID
    slot3["content_status"] = "authored"
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

    beats, choices_zh, mixed_splits, italic_strips = parse_manuscript()
    nodes = build_nodes(beats, choices_zh)
    en_data = read_json(EN_TRANSLATION_PATH)

    event_obj = {
        "id": EVENT_ID,
        "actor_id": ACTOR_ID,
        "title": "不是一个人的手术",
        "chapter": 3,
        "location_id": "lounge",
        "trigger_mode": "after_work",
        "background_id": "staff_lounge",
        "outfit": "white_coat",
        "completion_background_id": "staff_lounge",
        "completion_outfit": "white_coat",
        "completion_expression": "smile",
        "hide_calendar_header": True,
        "minutes": 0,
        "completion_day_offset": 1,
        "completion_absolute_clock": 900,
        "teaser": "在一台为故人爱丽丝菲尔实施的开腹远端胃大部切除术中，坂口隆司亲眼见证阿尔托莉雅如何让整间手术室拧成一支敢于发声的队伍——直到她自己饿得晃了神。",
        "time_start": 960,
        "time_end": 1320,
        "priority": 183,
        "category": "rank_up",
        "gallery": {
            "cg_id": "cg_artoria_lv3_not_a_solo_operation",
            "caption": "在爱丽丝菲尔的开腹远端胃大部切除术台上，本庄萌恵、利根川安琪与杉村弘子围绕阿尔托莉雅咬合成一支真正的团队——并在术后反过来把饿到头晕的副部长按在了休息室沙发上。",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "max_day": 363,
            "min_affection": 0,
            "min_familiarity": 40,
            "required_events": [
                "artoria_lv2_what_remains"
            ],
            "days_after_required_events": 3,
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "leadership",
                    "minimum": 80
                }
            ]
        },
        "auto_start": True,
        "locks_saving": True,
        "target_level": 3,
        "benefit_id": "",
        "completion_story_flags": [
            "artoria_lv3_complete"
        ],
        "start": "ar3_s1_01",
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
        "target_level": 3,
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
        "story_guest": {
            "id": "story_guest_irisviel",
            "name": "爱丽丝菲尔·冯·爱因兹贝伦",
            "random_pool": False,
            "surgery_queue": False,
        },
    }
    write_json(IMPORT_MANIFEST_PATH, import_manifest)
    print(
        f"Imported {EVENT_ID}: {len(beats)} beats, {len(nodes)} nodes, "
        f"{mixed_splits} mixed splits, {italic_strips} italic strip(s)."
    )


if __name__ == "__main__":
    main()
