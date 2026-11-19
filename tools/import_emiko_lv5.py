#!/usr/bin/env python3
"""Import Emiko Mido (`doc_emiko`) Relationship Lv5 milestone event:
《神的双手》 (Hands of God, ID: `emiko_lv5_hands_of_god`, V1.0).

Updates:
- data/staff/doc_emiko/assets_manifest.json (preserves existing entries; registers 4 Haruko/Naomi RGBA sprites + 3 CG placeholders)
- data/staff/doc_emiko/cg_mapping.json (preserves any approved CG paths; records planned Codex CG placeholders)
- data/staff/doc_emiko/bundle.json (registers `lv5_events.json`)
- data/staff/doc_emiko/relationship.json (`target_level: 5` -> `"event_id": "emiko_lv5_hands_of_god"`, `"content_status": "authored"`)
- data/staff/doc_emiko/lv5_events.json
- data/localization/zh_CN.json & data/localization/en.json
- research/imports/emiko_lv5_2026-11-17.json
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_MIDO_EMIKO_LV5_HANDS_OF_GOD_V1_0.md"
EN_TRANSLATION_PATH = ROOT / "research/translations/emiko_lv5_en.json"
STAFF_DIR = ROOT / "data/staff/doc_emiko"
ASSETS_MANIFEST_PATH = STAFF_DIR / "assets_manifest.json"
CG_MAPPING_PATH = STAFF_DIR / "cg_mapping.json"
BUNDLE_PATH = STAFF_DIR / "bundle.json"
RELATIONSHIP_PATH = STAFF_DIR / "relationship.json"
EVENTS_PATH = STAFF_DIR / "lv5_events.json"
ZH_LOCALE_PATH = ROOT / "data/localization/zh_CN.json"
EN_LOCALE_PATH = ROOT / "data/localization/en.json"
IMPORT_MANIFEST_PATH = ROOT / "research/imports/emiko_lv5_2026-11-17.json"

EVENT_ID = "emiko_lv5_hands_of_god"
ACTOR_ID = "doc_emiko"

USER_SUPPLIED_PATIENT_SOURCES = {
    "haruko_ward": {
        "source": "/Users/ningye/.codex/generated_images/01a1d2cc-6056-71b0-babe-e7acb7d9f78d/exec-0fcc3e3f-a6af-444a-b36c-bf9426e7e6f2.png",
        "repo_seed": "research/generated_candidates/haruko_naomi_patient_seed_v2/haruko_ward_seed.png",
        "runtime_path": "assets/characters/emiko_lv5_v1/haruko_takase/ward/neutral.png",
        "size": [1024, 1536],
    },
    "haruko_or": {
        "source": "/Users/ningye/.codex/generated_images/01a1d2cc-6056-71b0-babe-e7acb7d9f78d/exec-7fc47f97-ae59-4869-b197-3d48d2db06ad.png",
        "repo_seed": "research/generated_candidates/haruko_naomi_patient_seed_v2/haruko_intraoperative_seed.png",
        "runtime_path": "assets/characters/emiko_lv5_v1/haruko_takase/or_cap/calm.png",
        "size": [1448, 1086],
    },
    "naomi_ward": {
        "source": "/Users/ningye/.codex/generated_images/01a1d2cc-6056-71b0-babe-e7acb7d9f78d/exec-dd71fe11-4b7b-4b00-9c05-9584171b5bf8.png",
        "repo_seed": "research/generated_candidates/haruko_naomi_patient_seed_v2/naomi_ward_seed.png",
        "runtime_path": "assets/characters/emiko_lv5_v1/naomi_miyahara/ward/neutral.png",
        "size": [1024, 1536],
    },
    "naomi_or": {
        "source": "/Users/ningye/.codex/generated_images/01a1d2cc-6056-71b0-babe-e7acb7d9f78d/exec-6c4f33c3-106d-4f84-9151-74fd243065d9.png",
        "repo_seed": "research/generated_candidates/haruko_naomi_patient_seed_v2/naomi_intraoperative_seed.png",
        "runtime_path": "assets/characters/emiko_lv5_v1/naomi_miyahara/or_cap/calm.png",
        "size": [1448, 1086],
    },
}

CAST_PORTRAITS = {
    ("doc_emiko", "white_coat/neutral"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/neutral.png",
    ("doc_emiko", "white_coat/smile"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/smile.png",
    ("doc_emiko", "white_coat/serious"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/serious.png",
    ("doc_emiko", "white_coat/surprised"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/surprised.png",
    ("doc_emiko", "white_coat/worried"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/worried.png",
    ("doc_emiko", "white_coat/warm"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/warm.png",
    ("doc_emiko", "scrubs/neutral"): "assets/characters/portrait_pack_v14/doc_emiko/scrubs/neutral.png",
    ("doc_emiko", "scrubs/focused"): "assets/characters/portrait_pack_v14/doc_emiko/scrubs/focused.png",
    ("doc_emiko", "scrubs_masked/focused"): "assets/characters/emiko_lv3_v1/doc_emiko/scrubs_masked/focused.png",
    ("doc_emiko", "sterile/neutral"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/neutral.png",
    ("doc_emiko", "sterile/focused"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/focused.png",
    ("doc_emiko", "sterile/warm"): "assets/characters/portrait_pack_v14/doc_emiko/sterile/warm.png",
    ("doc_emiko", "ward/neutral"): "assets/characters/emiko_staff_patient_v1/doc_emiko/ward/neutral.png",
    ("doc_emiko", "ward/brave"): "assets/characters/emiko_staff_patient_v1/doc_emiko/ward/brave.png",
    ("doc_emiko", "ward/worried"): "assets/characters/emiko_staff_patient_v1/doc_emiko/ward/worried.png",
    ("doc_emiko", "intraoperative/tense"): "assets/characters/emiko_staff_patient_v1/doc_emiko/intraoperative/tense.png",
    ("doc_emiko", "intraoperative/pain"): "assets/characters/emiko_staff_patient_v1/doc_emiko/intraoperative/pain.png",
    ("doc_rei", "scrubs/neutral"): "assets/characters/portrait_pack_v2/doc_rei/scrubs/neutral.png",
    ("doc_rei", "scrubs/focused"): "assets/characters/portrait_pack_v5/doc_rei/scrubs/focused.png",
    ("doc_rei", "scrubs/worried"): "assets/characters/portrait_pack_v5/doc_rei/scrubs/worried.png",
    ("doc_rei", "sterile/neutral"): "assets/characters/sterile_pack_v1/doc_rei/neutral.png",
    ("doc_rei", "sterile/focused"): "assets/characters/sterile_pack_v1/doc_rei/focused.png",
    ("doc_rei", "sterile/worried"): "assets/characters/sterile_pack_v1/doc_rei/worried.png",
    ("doc_rei", "sterile/warm"): "assets/characters/sterile_pack_v1/doc_rei/warm.png",
    ("nurse_hiroko", "scrubs/neutral"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/scrubs/neutral.png",
    ("nurse_hiroko", "scrubs/focused"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/scrubs/focused.png",
    ("nurse_hiroko", "scrubs/warm"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/scrubs/warm.png",
    ("nurse_hiroko", "sterile/neutral"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/neutral.png",
    ("nurse_hiroko", "sterile/focused"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/focused.png",
    ("nurse_hiroko", "sterile/warm"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/warm.png",
    ("nurse_sonoda_itsumi", "scrubs/neutral"): "assets/characters/sonoda_itsumi_v1/nurse_sonoda_itsumi/scrubs/neutral.png",
    ("nurse_sonoda_itsumi", "scrubs/focused"): "assets/characters/sonoda_itsumi_v1/nurse_sonoda_itsumi/scrubs/focused.png",
    ("nurse_sonoda_itsumi", "scrubs/warm"): "assets/characters/sonoda_itsumi_v1/nurse_sonoda_itsumi/scrubs/warm.png",
    ("nurse_sonoda_itsumi", "scrubs/worried"): "assets/characters/sonoda_itsumi_v1/nurse_sonoda_itsumi/scrubs/worried.png",
    ("doc_asuka", "scrubs/masked_bright"): "assets/characters/asuka_lv1_v1/doc_asuka/scrubs/masked_bright.png",
    ("doc_asuka", "scrubs/masked_smile"): "assets/characters/asuka_lv1_v1/doc_asuka/scrubs/masked_smile.png",
    ("story_guest_haruko_takase", "casual/neutral"): "assets/characters/emiko_lv5_v1/haruko_takase/casual/neutral.png",
    ("story_guest_haruko_takase", "casual/smile"): "assets/characters/emiko_lv5_v1/haruko_takase/casual/smile.png",
    ("story_guest_haruko_takase", "casual/afraid"): "assets/characters/emiko_lv5_v1/haruko_takase/casual/afraid.png",
    ("story_guest_haruko_takase", "ward/neutral"): "assets/characters/emiko_lv5_v1/haruko_takase/ward/neutral.png",
    ("story_guest_haruko_takase", "ward/smile"): "assets/characters/emiko_lv5_v1/haruko_takase/ward/smile.png",
    ("story_guest_haruko_takase", "ward/shy"): "assets/characters/emiko_lv5_v1/haruko_takase/ward/shy.png",
    ("story_guest_haruko_takase", "ward/pain"): "assets/characters/emiko_lv5_v1/haruko_takase/ward/pain.png",
    ("story_guest_haruko_takase", "or_cap/calm"): "assets/characters/emiko_lv5_v1/haruko_takase/or_cap/calm.png",
    ("story_guest_haruko_takase", "or_cap/afraid"): "assets/characters/emiko_lv5_v1/haruko_takase/or_cap/afraid.png",
    ("story_guest_naomi_miyahara", "ward/neutral"): "assets/characters/emiko_lv5_v1/naomi_miyahara/ward/neutral.png",
    ("story_guest_naomi_miyahara", "ward/smile"): "assets/characters/emiko_lv5_v1/naomi_miyahara/ward/smile.png",
    ("story_guest_naomi_miyahara", "or_cap/calm"): "assets/characters/emiko_lv5_v1/naomi_miyahara/or_cap/calm.png",
    ("story_guest_naomi_miyahara", "or_cap/smile"): "assets/characters/emiko_lv5_v1/naomi_miyahara/or_cap/smile.png",
}

SPEAKER_MAP = {
    "旁白": ("narrator", "doc_emiko", "旁白"),
    "御堂江美子": ("actor", "doc_emiko", "御堂江美子"),
    "坂口隆司": ("player", "doc_emiko", "坂口隆司"),
    "高瀬晴子": ("actor", "doc_emiko", "高瀬晴子"),
    "宮原奈緒美": ("actor", "doc_emiko", "宮原奈緒美"),
    "城宮明日香": ("actor", "doc_asuka", "城宮明日香"),
    "深山佳織": ("actor", "doc_rei", "深山佳織"),
    "杉村弘子": ("actor", "nurse_hiroko", "杉村弘子"),
    "薗田愛実": ("actor", "nurse_sonoda_itsumi", "薗田愛実"),
    "值班麻醉医师": ("actor", "doc_emiko", "值班麻醉医师"),
    "受者组麻醉医师": ("actor", "doc_emiko", "受者组麻醉医师"),
    "供者组资深助手": ("actor", "doc_emiko", "供者组资深助手"),
    "一号室通报（对讲音）": ("actor", "doc_emiko", "一号室通报（对讲音）"),
    "杉村弘子 ＆ 薗田愛実 ＆ 深山佳織": ("actor", "nurse_hiroko", "杉村弘子 ＆ 薗田愛実 ＆ 深山佳織"),
}

PROSE_MIXED_SPEAKERS = [
    ("杉村弘子", "杉村弘子"),
    ("值班麻醉医师", "值班麻醉医师"),
    ("晴子", "高瀬晴子"),
    ("高瀬晴子", "高瀬晴子"),
    ("坂口隆司", "坂口隆司"),
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


def sprite(actor_id: str, key: str, x: int = 985, bottom: int = 556, width: int = 320, height: int = 480) -> dict:
    return {
        "id": actor_id,
        "path": CAST_PORTRAITS[(actor_id, key)],
        "x": x,
        "bottom": bottom,
        "width": width,
        "height": height,
    }


def solo_staff(actor_id: str, key: str, x: int = 1000) -> list[dict]:
    w, h = (380, 445) if actor_id == "doc_rei" else (320, 480)
    return [sprite(actor_id, key, x=x, bottom=556, width=w, height=h)]


def duo_staff(left_actor: str, left_key: str, right_actor: str, right_key: str) -> list[dict]:
    lw, lh = (355, 420) if left_actor == "doc_rei" else (300, 450)
    rw, rh = (355, 420) if right_actor == "doc_rei" else (300, 450)
    return [
        sprite(left_actor, left_key, x=800, bottom=556, width=lw, height=lh),
        sprite(right_actor, right_key, x=1090, bottom=556, width=rw, height=rh),
    ]


def or_patient_with_staff(patient_actor: str, patient_key: str, staff_actor: str, staff_key: str) -> list[dict]:
    sw, sh = (355, 420) if staff_actor == "doc_rei" else (320, 480)
    return [
        sprite(patient_actor, patient_key, x=450, bottom=495, width=400, height=300),
        sprite(staff_actor, staff_key, x=995, bottom=556, width=sw, height=sh),
    ]


def clinic_haruko_and_emiko(haruko_expr: str, emiko_expr: str) -> list[dict]:
    return [
        sprite("story_guest_haruko_takase", f"casual/{haruko_expr}", x=455, bottom=556, width=310, height=465),
        sprite("doc_emiko", f"white_coat/{emiko_expr}", x=1000, bottom=556, width=320, height=480),
    ]


def duo_or_patients(naomi_expr: str = "calm", haruko_expr: str = "calm") -> list[dict]:
    return [
        sprite("story_guest_naomi_miyahara", f"or_cap/{naomi_expr}", x=450, bottom=500, width=390, height=292),
        sprite("story_guest_haruko_takase", f"or_cap/{haruko_expr}", x=965, bottom=500, width=390, height=292),
    ]


def duo_ward_patients(naomi_expr: str = "neutral", haruko_expr: str = "neutral") -> list[dict]:
    return [
        sprite("story_guest_naomi_miyahara", f"ward/{naomi_expr}", x=465, bottom=556, width=310, height=465),
        sprite("story_guest_haruko_takase", f"ward/{haruko_expr}", x=980, bottom=556, width=310, height=465),
    ]


def ward_patient_and_emiko(patient_actor: str, patient_expr: str, emiko_expr: str) -> list[dict]:
    return [
        sprite(patient_actor, f"ward/{patient_expr}", x=455, bottom=556, width=310, height=465),
        sprite("doc_emiko", f"white_coat/{emiko_expr}", x=1000, bottom=556, width=320, height=480),
    ]


def stage_for_node(nid: str, sec: str) -> tuple[str, str, str, list[dict] | None, str]:
    """Return (background_id, outfit, expression, event_portraits_or_None, stage_effect)."""
    idx = int(nid.rsplit("_", 1)[1])

    # Act 1.1: Chief Surgeon's Office (`emiko_office`)
    if sec == "s1_1":
        if idx == 1:
            return ("emiko_office", "white_coat", "serious", None, "")
        expr = "smile" if idx == 11 else "serious"
        return ("emiko_office", "white_coat", expr, solo_staff("doc_emiko", f"white_coat/{expr}"), "")

    # Act 1.2: Six months ago outpatient consultation flashback (`clinic`)
    if sec == "s1_2":
        if idx in (1, 2):
            return ("clinic", "white_coat", "neutral", clinic_haruko_and_emiko("smile", "neutral"), "")
        if idx in (3, 4):
            h_expr = "smile" if idx == 3 else "neutral"
            return ("clinic", "white_coat", "serious", clinic_haruko_and_emiko(h_expr, "serious"), "")
        if 5 <= idx <= 9:
            return ("clinic", "white_coat", "serious", clinic_haruko_and_emiko("afraid", "serious"), "")
        if idx in (10, 11):
            return ("clinic", "white_coat", "neutral", solo_staff("doc_emiko", "white_coat/neutral"), "")
        return ("clinic", "white_coat", "neutral", clinic_haruko_and_emiko("neutral", "neutral"), "")

    # Act 1.3 + Choice 1 + Merge (`emiko_office`)
    if sec == "s1_3":
        expr = "warm" if idx == 2 else "serious"
        return ("emiko_office", "white_coat", expr, solo_staff("doc_emiko", f"white_coat/{expr}"), "")
    if sec == "c1a":
        expr = "warm" if idx == 4 else "serious"
        return ("emiko_office", "white_coat", expr, solo_staff("doc_emiko", f"white_coat/{expr}"), "")
    if sec == "c1b":
        expr = "smile" if idx in (3, 4) else "serious"
        return ("emiko_office", "white_coat", expr, solo_staff("doc_emiko", f"white_coat/{expr}"), "")
    if sec == "s1m":
        expr = "worried" if idx == 7 else ("serious" if idx in (3, 8) else "neutral")
        return ("emiko_office", "white_coat", expr, solo_staff("doc_emiko", f"white_coat/{expr}"), "")

    # Act 2: Operating Room 1 — Emiko as conscious patient (`operating_room` -> `pacu_recovery`)
    if sec == "s2":
        if idx == 1:
            return ("operating_room", "scrubs", "neutral", None, "")
        if idx in (2, 3, 4):
            return ("operating_room", "scrubs", "neutral", duo_staff("nurse_sonoda_itsumi", "scrubs/worried", "doc_rei", "scrubs/neutral"), "")
        if idx in (5, 6):
            return ("operating_room", "scrubs", "neutral", duo_staff("nurse_hiroko", "scrubs/focused", "doc_rei", "scrubs/focused"), "")
        if idx in (7, 8, 9, 10, 11, 12, 13):
            w_expr = "brave" if idx in (11, 13) else "neutral"
            return ("operating_room", "ward", w_expr, solo_staff("doc_emiko", f"ward/{w_expr}"), "")
        if idx in (14, 15):
            return ("operating_room", "ward", "brave", duo_staff("nurse_sonoda_itsumi", "scrubs/worried", "doc_rei", "scrubs/worried"), "")
        if idx in (16, 17, 18):
            w_expr = "worried" if idx == 17 else "brave"
            return ("operating_room", "ward", w_expr, solo_staff("doc_emiko", f"ward/{w_expr}"), "")
        if idx in (19, 20):
            return ("operating_room", "ward", "neutral", duo_staff("nurse_hiroko", "scrubs/focused", "doc_emiko", "ward/neutral"), "")
        if 21 <= idx <= 37:
            staff_actor = "nurse_sonoda_itsumi" if idx in (23, 24, 25, 26, 27) else "nurse_hiroko"
            staff_key = "scrubs/worried" if staff_actor == "nurse_sonoda_itsumi" else "scrubs/focused"
            return ("operating_room", "intraoperative", "tense", or_patient_with_staff("doc_emiko", "intraoperative/tense", staff_actor, staff_key), "")
        if 38 <= idx <= 43:
            return ("operating_room", "intraoperative", "tense", or_patient_with_staff("doc_emiko", "intraoperative/tense", "nurse_hiroko", "sterile/focused"), "")
        if 44 <= idx <= 58:
            fx = "shake" if idx == 44 else ""
            staff_actor = "nurse_sonoda_itsumi" if idx == 56 else "nurse_hiroko"
            staff_key = "scrubs/worried" if staff_actor == "nurse_sonoda_itsumi" else ("sterile/warm" if idx in (56, 57, 58) else "sterile/focused")
            return ("operating_room", "intraoperative", "pain", or_patient_with_staff("doc_emiko", "intraoperative/pain", staff_actor, staff_key), fx)
        return ("operating_room", "intraoperative", "tense", or_patient_with_staff("doc_emiko", "intraoperative/tense", "doc_rei", "sterile/focused"), "")

    if sec in ("c2a", "c2b"):
        return ("operating_room", "intraoperative", "tense", or_patient_with_staff("doc_emiko", "intraoperative/tense", "doc_rei", "sterile/focused"), "")

    if sec == "s2m":
        if 1 <= idx <= 9:
            rei_key = "sterile/warm" if idx == 6 else "sterile/focused"
            staff_actor = "nurse_hiroko" if idx in (8, 9) else "doc_rei"
            staff_key = "sterile/focused" if staff_actor == "nurse_hiroko" else rei_key
            return ("operating_room", "intraoperative", "tense", or_patient_with_staff("doc_emiko", "intraoperative/tense", staff_actor, staff_key), "")
        if idx in (10, 11, 12):
            return ("pacu_recovery", "intraoperative", "tense", or_patient_with_staff("doc_emiko", "intraoperative/tense", "nurse_hiroko", "scrubs/warm"), "")
        em_key = "intraoperative/pain" if idx == 14 else "intraoperative/tense"
        return ("pacu_recovery", "intraoperative", "tense", [sprite("doc_emiko", em_key, x=960, bottom=505, width=420, height=315)], "")

    # Act 3: Next morning dark humor & IDEA-034 hook (`emiko_office`)
    if sec == "s3":
        if idx in (2, 4, 5):
            expr = "worried"
        elif idx in (10, 11, 18, 19, 20):
            expr = "serious"
        elif idx in (14, 15, 16):
            expr = "smile"
        elif idx in (21, 22, 23):
            expr = "surprised"
        else:
            expr = "warm" if idx in (24, 25, 26) else "neutral"
        return ("emiko_office", "white_coat", expr, solo_staff("doc_emiko", f"white_coat/{expr}"), "")

    # Act 4.1: Surgical transfer corridor fork (`or_entrance`)
    if sec == "s4_1":
        if idx in (1, 11):
            return ("or_entrance", "sterile", "focused", None, "")
        naomi_expr = "smile" if idx >= 7 else "calm"
        return ("or_entrance", "sterile", "focused", duo_or_patients(naomi_expr, "calm"), "")

    # Act 4.2: Operating Room 1 — Donor Haruko & Emiko (`operating_room`)
    if sec == "s4_2":
        em_expr = "warm" if idx >= 6 else "focused"
        haruko_expr = "afraid" if idx <= 8 else "calm"
        return ("operating_room", "sterile", em_expr, or_patient_with_staff("story_guest_haruko_takase", f"or_cap/{haruko_expr}", "doc_emiko", f"sterile/{em_expr}"), "")

    # Act 4.3: Operating Room 2 — Recipient Naomi, Sakaguchi, Miyama, Hiroko, Sonoda, Asuka (`new_operating_room`)
    if sec == "s4_3":
        if idx == 1:
            return ("new_operating_room", "sterile", "focused", None, "")
        if 2 <= idx <= 5:
            naomi_expr = "smile" if idx in (4, 5) else "calm"
            return ("new_operating_room", "sterile", "focused", or_patient_with_staff("story_guest_naomi_miyahara", f"or_cap/{naomi_expr}", "doc_rei", "sterile/focused"), "")
        if idx in (6, 7):
            return ("new_operating_room", "sterile", "focused", duo_staff("nurse_sonoda_itsumi", "scrubs/focused", "doc_rei", "sterile/focused"), "")
        if 8 <= idx <= 11:
            return ("new_operating_room", "sterile", "focused", duo_staff("nurse_hiroko", "sterile/focused", "doc_rei", "sterile/focused"), "")
        if 12 <= idx <= 19:
            asuka_key = "scrubs/masked_smile" if idx in (14, 19) else "scrubs/masked_bright"
            return ("new_operating_room", "sterile", "focused", duo_staff("doc_asuka", asuka_key, "doc_rei", "sterile/focused"), "")
        return ("new_operating_room", "sterile", "focused", duo_staff("nurse_hiroko", "sterile/focused", "doc_rei", "sterile/focused"), "")

    # Act 5.1: OR 1 Donor remnant check & handoff (`operating_room`)
    if sec == "s5_1":
        return ("operating_room", "sterile", "focused", solo_staff("doc_emiko", "sterile/focused"), "")

    # Act 5.2 + Choice 3 + Merge: Scrub bay -> OR 2 Recipient core vascular & biliary reconstruction
    if sec == "s5_2":
        if idx == 1:
            return ("new_operating_room", "sterile", "focused", duo_staff("nurse_hiroko", "sterile/focused", "doc_rei", "sterile/focused"), "")
        if idx in (2, 3, 4, 5):
            return ("scrub_area", "scrubs_masked", "focused", solo_staff("doc_emiko", "scrubs_masked/focused"), "")
        if idx in (6, 7, 8, 9, 10, 11, 12, 13):
            return ("new_operating_room", "sterile", "focused", duo_staff("nurse_hiroko", "sterile/focused", "doc_emiko", "sterile/focused"), "")
        if idx == 14:
            return ("new_operating_room", "sterile", "focused", duo_staff("nurse_sonoda_itsumi", "scrubs/warm", "doc_emiko", "sterile/focused"), "")
        rei_key = "sterile/worried" if idx in (16, 17, 18) else "sterile/focused"
        return ("new_operating_room", "sterile", "focused", duo_staff("doc_rei", rei_key, "doc_emiko", "sterile/focused"), "")

    if sec in ("c3a", "c3b"):
        return ("new_operating_room", "sterile", "focused", duo_staff("doc_rei", "sterile/focused", "doc_emiko", "sterile/focused"), "")

    if sec == "s5m":
        if idx in (1, 2, 3, 4):
            return ("new_operating_room", "sterile", "focused", duo_staff("doc_rei", "sterile/focused", "doc_emiko", "sterile/focused"), "")
        if idx in (5, 6, 7, 8):
            return ("new_operating_room", "sterile", "focused", duo_staff("doc_asuka", "scrubs/masked_smile", "doc_emiko", "sterile/focused"), "")
        if 9 <= idx <= 14:
            em_expr = "warm" if idx in (13, 14) else "focused"
            return ("new_operating_room", "sterile", em_expr, solo_staff("doc_emiko", f"sterile/{em_expr}"), "")
        if idx in (15, 16, 17):
            return ("new_operating_room", "sterile", "warm", duo_staff("doc_asuka", "scrubs/masked_smile", "doc_emiko", "sterile/warm"), "")
        return ("new_operating_room", "sterile", "warm", duo_staff("nurse_hiroko", "sterile/warm", "doc_emiko", "sterile/warm"), "")

    # Act 6.1: Postoperative recovery ward joint bedside callback (`ward`)
    if sec == "s6_1":
        if idx == 1:
            return ("ward", "white_coat", "neutral", None, "")
        if idx in (2, 3):
            return ("ward", "white_coat", "neutral", duo_ward_patients("neutral", "neutral"), "")
        if idx in (4, 5):
            fx = "shake" if idx == 4 else ""
            return ("ward", "white_coat", "neutral", duo_ward_patients("neutral", "pain"), fx)
        if idx == 6:
            return ("ward", "white_coat", "neutral", duo_ward_patients("neutral", "shy"), "")
        if idx in (7, 8):
            return ("ward", "white_coat", "neutral", duo_ward_patients("smile", "shy"), "")
        if idx in (9, 10):
            return ("ward", "white_coat", "neutral", duo_ward_patients("smile", "smile"), "")
        if idx in (11, 12):
            return ("ward", "white_coat", "neutral", solo_staff("doc_emiko", "white_coat/neutral"), "")
        if 13 <= idx <= 16:
            naomi_expr = "smile" if idx in (15, 16) else "neutral"
            return ("ward", "white_coat", "neutral", ward_patient_and_emiko("story_guest_naomi_miyahara", naomi_expr, "neutral"), "")
        if 17 <= idx <= 20:
            em_expr = "serious" if idx == 20 else "neutral"
            return ("ward", "white_coat", em_expr, ward_patient_and_emiko("story_guest_haruko_takase", "neutral", em_expr), "")
        if idx in (21, 22, 23):
            em_expr = "warm" if idx == 22 else "neutral"
            return ("ward", "white_coat", em_expr, ward_patient_and_emiko("story_guest_haruko_takase", "shy", em_expr), "")
        if idx in (24, 25):
            em_expr = "serious" if idx == 25 else "neutral"
            return ("ward", "white_coat", em_expr, ward_patient_and_emiko("story_guest_haruko_takase", "pain", em_expr), "")
        if idx in (26, 27, 28, 29):
            em_expr = "warm" if idx == 29 else "neutral"
            return ("ward", "white_coat", em_expr, ward_patient_and_emiko("story_guest_haruko_takase", "shy", em_expr), "")
        if idx in (30, 31):
            return ("ward", "white_coat", "warm", ward_patient_and_emiko("story_guest_haruko_takase", "smile", "warm"), "")
        if 32 <= idx <= 35:
            return ("ward", "white_coat", "warm", duo_ward_patients("smile", "smile"), "")
        return ("ward", "white_coat", "warm", solo_staff("doc_emiko", "white_coat/warm"), "")

    # Act 6.2 + Choice 4 + Epilogue: Sunset surgical corridor (`artoria_lv5_or_corridor_evening`)
    if sec == "s6_2":
        if idx == 1:
            return ("artoria_lv5_or_corridor_evening", "white_coat", "neutral", None, "")
        if idx in (6, 7, 8, 9, 10, 11, 12):
            expr = "serious"
        elif idx in (13, 14, 15):
            expr = "warm"
        else:
            expr = "neutral"
        return ("artoria_lv5_or_corridor_evening", "white_coat", expr, solo_staff("doc_emiko", f"white_coat/{expr}"), "")

    if sec == "c4a":
        return ("artoria_lv5_or_corridor_evening", "white_coat", "serious", solo_staff("doc_emiko", "white_coat/serious"), "")
    if sec == "c4b":
        return ("artoria_lv5_or_corridor_evening", "white_coat", "smile", solo_staff("doc_emiko", "white_coat/smile"), "")
    if sec == "s6m":
        if idx == 4:
            return ("artoria_lv5_or_corridor_evening", "white_coat", "warm", None, "")
        expr = "warm" if idx in (1, 3) else "serious"
        return ("artoria_lv5_or_corridor_evening", "white_coat", expr, solo_staff("doc_emiko", f"white_coat/{expr}"), "")

    raise ValueError(f"Unhandled node staging: {nid} ({sec})")


def parse_manuscript() -> tuple[list[dict], dict[str, str], list[dict], list[dict], list[dict]]:
    md = MANUSCRIPT_PATH.read_text(encoding="utf-8")
    body = md.split("## 一、 完整中文 VN 剧本正文（第一至六幕）\n", 1)[1].split("\n## 二、 附表 1：六幕 Scene / Beat 索引表", 1)[0]

    sec = ""
    cur_choice = ""
    counts: dict[str, int] = {}
    beats: list[dict] = []
    choices_zh: dict[str, str] = {}
    mixed_splits: list[dict] = []
    italic_strips: list[dict] = []
    bold_strips: list[dict] = []

    def add_beat(s: str, speaker_key: str, text: str) -> str:
        counts[s] = counts.get(s, 0) + 1
        nid = f"em5_{s}_{counts[s]:02d}"
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
            sec = "s1_1"
            continue
        if line == "【简短回忆切入：半年前·外科门诊咨询室】":
            sec = "s1_2"
            continue
        if line == "【回忆结束：回到外科医长办公室】":
            sec = "s1_3"
            continue
        if line.startswith("**【选择 1"):
            cur_choice = "c1"
            continue
        if line.startswith("### 第二幕"):
            sec = "s2"
            continue
        if line.startswith("**【选择 2"):
            cur_choice = "c2"
            continue
        if line.startswith("### 第三幕"):
            sec = "s3"
            continue
        if line.startswith("### 第四幕"):
            sec = "s4_1"
            continue
        if line == "【镜头切入：一号手术室（供者侧）】":
            sec = "s4_2"
            continue
        if line == "【镜头切入：二号手术室（受者侧）】":
            sec = "s4_3"
            continue
        if line.startswith("### 第五幕"):
            sec = "s5_1"
            continue
        if line == "【一号手术室·短暂切入】":
            sec = "s5_1"
            continue
        if line == "【回到二号手术室：受者侧核心重建】":
            sec = "s5_2"
            continue
        if line.startswith("**【选择 3"):
            cur_choice = "c3"
            continue
        if line.startswith("### 第六幕"):
            sec = "s6_1"
            continue
        if line.startswith("走出病房轻轻掩上门"):
            sec = "s6_2"
        if line.startswith("**【选择 4"):
            cur_choice = "c4"
            continue

        if (
            line.startswith("**【场景】**")
            or line.startswith("**【时间】**")
            or line.startswith("**【在场角色】**")
            or line.startswith("**【服装与可视状态】**")
            or line.startswith("- **分流走廊：**")
            or line.startswith("- **一号手术室")
            or line.startswith("- **二号手术室")
            or line.startswith("- 开场时坂口")
            or line.startswith("- 随后御堂褪去")
            or line.startswith("*选项说明：")
            or line.startswith("> **【剧本终场结算锚点")
            or line.startswith("> - ")
        ):
            continue

        m_branch = BRANCH_HDR_RE.match(line)
        if m_branch:
            sec = f"{cur_choice}{m_branch.group(1).lower()}"
            continue

        m_opt = BULLET_CHOICE_RE.match(line)
        if m_opt:
            opt = m_opt.group(1).lower()
            choices_zh[f"choice_em5_{cur_choice}_{opt}"] = m_opt.group(2).strip()
            continue

        if line == "> **【分支汇合点】**":
            sec = {"c1": "s1m", "c2": "s2m", "c3": "s5m"}[cur_choice]
            continue
        if line == "> **【终场汇合与收束】**":
            sec = "s6m"
            continue

        if line.startswith("### ") or line.startswith("#### ") or line.startswith(">"):
            raise ValueError(f"Unhandled structural line: {line}")

        mb = BOLD_LINE_RE.match(line)
        if mb:
            raw_spk, stage_dir, quote = mb.group(1).strip(), mb.group(2).strip(), mb.group(3).strip()
            text = f"{stage_dir}{quote}" if stage_dir else quote
            add_beat(sec, raw_spk, text)
            continue

        if line.startswith("*") and line.endswith("*") and not line.startswith("**"):
            stripped = line[1:-1].strip()
            nid = add_beat(sec, "旁白", stripped)
            italic_strips.append({"node_id": nid, "original": line, "rendered": stripped})
            continue

        if "**" in line:
            original_line = line
            line = line.replace("**", "")
            nid_preview = f"em5_{sec}_{counts.get(sec, 0) + 1:02d}"
            bold_strips.append({"node_id": nid_preview, "original": original_line, "rendered": line})

        if "：「" in line and line.endswith("」"):
            act, quote = line.split("：「", 1)
            quote = "「" + quote
            matched_spk = next((norm for tok, norm in PROSE_MIXED_SPEAKERS if tok in act), None)
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

    return beats, choices_zh, mixed_splits, italic_strips, bold_strips


def build_nodes(beats: list[dict], choices_zh: dict[str, str]) -> list[dict]:
    by_sec: dict[str, list[dict]] = {}
    for b in beats:
        by_sec.setdefault(b["sec"], []).append(b)

    next_map: dict[str, str] = {}

    def link_linear(sec_name: str, tail_target: str) -> None:
        arr = by_sec[sec_name]
        for i, b in enumerate(arr):
            next_map[b["id"]] = arr[i + 1]["id"] if i + 1 < len(arr) else tail_target

    link_linear("s1_1", by_sec["s1_2"][0]["id"])
    link_linear("s1_2", by_sec["s1_3"][0]["id"])
    link_linear("s1_3", "em5_choice_c1")
    link_linear("c1a", by_sec["s1m"][0]["id"])
    link_linear("c1b", by_sec["s1m"][0]["id"])
    link_linear("s1m", by_sec["s2"][0]["id"])
    link_linear("s2", "em5_choice_c2")
    link_linear("c2a", by_sec["s2m"][0]["id"])
    link_linear("c2b", by_sec["s2m"][0]["id"])
    link_linear("s2m", by_sec["s3"][0]["id"])
    link_linear("s3", by_sec["s4_1"][0]["id"])
    link_linear("s4_1", by_sec["s4_2"][0]["id"])
    link_linear("s4_2", by_sec["s4_3"][0]["id"])
    link_linear("s4_3", by_sec["s5_1"][0]["id"])
    link_linear("s5_1", by_sec["s5_2"][0]["id"])
    link_linear("s5_2", "em5_choice_c3")
    link_linear("c3a", by_sec["s5m"][0]["id"])
    link_linear("c3b", by_sec["s5m"][0]["id"])
    link_linear("s5m", by_sec["s6_1"][0]["id"])
    link_linear("s6_1", by_sec["s6_2"][0]["id"])
    link_linear("s6_2", "em5_choice_c4")
    link_linear("c4a", by_sec["s6m"][0]["id"])
    link_linear("c4b", by_sec["s6m"][0]["id"])
    link_linear("s6m", "@end")

    choice_after = {
        by_sec["s1_3"][-1]["id"]: {
            "id": "em5_choice_c1",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": ACTOR_ID,
            "text": "",
            "expression": "serious",
            "outfit": "white_coat",
            "background_id": "emiko_office",
            "event_portraits": solo_staff("doc_emiko", "white_coat/serious"),
            "choices": [
                {
                    "id": "choice_em5_c1_a",
                    "label": choices_zh["choice_em5_c1_a"],
                    "next": by_sec["c1a"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em5_c1_b",
                    "label": choices_zh["choice_em5_c1_b"],
                    "next": by_sec["c1b"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        by_sec["s2"][-1]["id"]: {
            "id": "em5_choice_c2",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": ACTOR_ID,
            "text": "",
            "expression": "tense",
            "outfit": "intraoperative",
            "background_id": "operating_room",
            "event_portraits": or_patient_with_staff("doc_emiko", "intraoperative/tense", "doc_rei", "sterile/focused"),
            "choices": [
                {
                    "id": "choice_em5_c2_a",
                    "label": choices_zh["choice_em5_c2_a"],
                    "next": by_sec["c2a"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em5_c2_b",
                    "label": choices_zh["choice_em5_c2_b"],
                    "next": by_sec["c2b"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        by_sec["s5_2"][-1]["id"]: {
            "id": "em5_choice_c3",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": ACTOR_ID,
            "text": "",
            "expression": "focused",
            "outfit": "sterile",
            "background_id": "new_operating_room",
            "event_portraits": duo_staff("doc_rei", "sterile/focused", "doc_emiko", "sterile/focused"),
            "choices": [
                {
                    "id": "choice_em5_c3_a",
                    "label": choices_zh["choice_em5_c3_a"],
                    "next": by_sec["c3a"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em5_c3_b",
                    "label": choices_zh["choice_em5_c3_b"],
                    "next": by_sec["c3b"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
        by_sec["s6_2"][-1]["id"]: {
            "id": "em5_choice_c4",
            "presentation": "choice",
            "speaker": "narrator",
            "speaker_label": "旁白",
            "actor_id": ACTOR_ID,
            "text": "",
            "expression": "warm",
            "outfit": "white_coat",
            "background_id": "artoria_lv5_or_corridor_evening",
            "event_portraits": solo_staff("doc_emiko", "white_coat/warm"),
            "choices": [
                {
                    "id": "choice_em5_c4_a",
                    "label": choices_zh["choice_em5_c4_a"],
                    "next": by_sec["c4a"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em5_c4_b",
                    "label": choices_zh["choice_em5_c4_b"],
                    "next": by_sec["c4b"][0]["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ],
        },
    }

    nodes: list[dict] = []
    for b in beats:
        nid = b["id"]
        bg, outfit, expr, portraits, fx = stage_for_node(nid, b["sec"])
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
        if fx:
            node["stage_effect"] = fx
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


def apply_cg_mapping(event: dict) -> None:
    if not CG_MAPPING_PATH.is_file():
        return
    mappings = read_json(CG_MAPPING_PATH)
    mapping = mappings.get(event["id"])
    if not mapping:
        return
    nodes_by_id = {node["id"]: node for node in event["nodes"]}
    for scene in mapping.get("scenes", []):
        if not (ROOT / scene["path"]).is_file():
            raise FileNotFoundError(scene["path"])
        for node_id in scene["nodes"]:
            target_node = nodes_by_id[node_id]
            target_node.pop("hide_portrait", None)
            target_node.pop("portrait_path", None)
            target_node.update(
                cg_path=scene["path"],
                cg_fit="contain",
                cg_dialogue_delay_seconds=2.0,
            )
    cover = mapping.get("cover", "")
    if cover:
        if not (ROOT / cover).is_file():
            raise FileNotFoundError(cover)
        event["gallery"]["path"] = cover
        event["gallery"]["show_on_complete"] = True


def update_staff_files() -> None:
    manifest = read_json(ASSETS_MANIFEST_PATH)
    existing_ids = {item["id"] for item in manifest.get("assets", [])}
    lv5_assets = [
        {
            "id": "portrait_story_guest_haruko_takase_casual_neutral",
            "category": "guest_patient_portrait",
            "path": "assets/characters/emiko_lv5_v1/haruko_takase/casual/neutral.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Haruko Takase casual hoodie neutral RGBA portrait (offline BiRefNet-ToonOut matting from approved haruko_casual_seed.png; Act 1 clinic flashback)",
        },
        {
            "id": "portrait_story_guest_haruko_takase_casual_smile",
            "category": "guest_patient_portrait",
            "path": "assets/characters/emiko_lv5_v1/haruko_takase/casual/smile.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Haruko Takase casual hoodie bright smile RGBA portrait (derived from haruko_casual_seed.png; Act 1 clinic flashback)",
        },
        {
            "id": "portrait_story_guest_haruko_takase_casual_afraid",
            "category": "guest_patient_portrait",
            "path": "assets/characters/emiko_lv5_v1/haruko_takase/casual/afraid.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Haruko Takase casual hoodie startled afraid RGBA portrait (derived from haruko_casual_seed.png; Act 1 clinic flashback)",
        },
        {
            "id": "portrait_story_guest_haruko_takase_ward_neutral",
            "category": "guest_patient_portrait",
            "path": "assets/characters/emiko_lv5_v1/haruko_takase/ward/neutral.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Haruko Takase (22yo living liver donor) ward gown RGBA portrait (offline BiRefNet-ToonOut matting from user-approved haruko_ward_seed.png; story guest only, excluded from random pools)",
        },
        {
            "id": "portrait_story_guest_haruko_takase_ward_smile",
            "category": "guest_patient_portrait",
            "path": "assets/characters/emiko_lv5_v1/haruko_takase/ward/smile.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Haruko Takase ward gown bright relieved smile RGBA portrait (derived from haruko_ward_seed.png; Act 6 joint ward round)",
        },
        {
            "id": "portrait_story_guest_haruko_takase_ward_shy",
            "category": "guest_patient_portrait",
            "path": "assets/characters/emiko_lv5_v1/haruko_takase/ward/shy.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Haruko Takase ward gown bashful crimson blush RGBA portrait (derived from haruko_ward_seed.png; Act 6 joint ward round)",
        },
        {
            "id": "portrait_story_guest_haruko_takase_ward_pain",
            "category": "guest_patient_portrait",
            "path": "assets/characters/emiko_lv5_v1/haruko_takase/ward/pain.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Haruko Takase ward gown postoperative incisional wince RGBA portrait (derived from haruko_ward_seed.png; Act 6 joint ward round)",
        },
        {
            "id": "portrait_story_guest_haruko_takase_or_cap_calm",
            "category": "guest_patient_portrait",
            "path": "assets/characters/emiko_lv5_v1/haruko_takase/or_cap/calm.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Haruko Takase surgical cap RGBA bust (offline BiRefNet-ToonOut matting from user-approved haruko_intraoperative_seed.png; story guest only, excluded from random pools)",
        },
        {
            "id": "portrait_story_guest_haruko_takase_or_cap_afraid",
            "category": "guest_patient_portrait",
            "path": "assets/characters/emiko_lv5_v1/haruko_takase/or_cap/afraid.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Haruko Takase surgical cap anxious preoperative fear RGBA bust (derived from haruko_intraoperative_seed.png; Act 4 OR 1)",
        },
        {
            "id": "portrait_story_guest_naomi_miyahara_ward_neutral",
            "category": "guest_patient_portrait",
            "path": "assets/characters/emiko_lv5_v1/naomi_miyahara/ward/neutral.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Naomi Miyahara (22yo living-donor liver transplant recipient) ward gown RGBA portrait (offline BiRefNet-ToonOut matting from user-approved naomi_ward_seed.png; story guest only, excluded from random pools)",
        },
        {
            "id": "portrait_story_guest_naomi_miyahara_ward_smile",
            "category": "guest_patient_portrait",
            "path": "assets/characters/emiko_lv5_v1/naomi_miyahara/ward/smile.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Naomi Miyahara ward gown warm relieved smile RGBA portrait (derived from naomi_ward_seed.png; Act 6 joint ward round)",
        },
        {
            "id": "portrait_story_guest_naomi_miyahara_or_cap_calm",
            "category": "guest_patient_portrait",
            "path": "assets/characters/emiko_lv5_v1/naomi_miyahara/or_cap/calm.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Naomi Miyahara surgical cap RGBA bust (offline BiRefNet-ToonOut matting from user-approved naomi_intraoperative_seed.png; story guest only, excluded from random pools)",
        },
        {
            "id": "portrait_story_guest_naomi_miyahara_or_cap_smile",
            "category": "guest_patient_portrait",
            "path": "assets/characters/emiko_lv5_v1/naomi_miyahara/or_cap/smile.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "Naomi Miyahara surgical cap serene warm smile RGBA bust (derived from naomi_intraoperative_seed.png; Act 4 OR corridor & OR 2)",
        },
        {
            "id": "cg_doc_emiko_lv5_corridor_lapel_epilogue",
            "category": "event_cg",
            "path": "assets/events/emiko_lv5_cg_v1/corridor_lapel.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "User-approved CG; patient closeups use bare-shoulder v2.",
            "sha256": "227cb3f1fc2034453621ed2f48b9e1ebdebf6d666546cff53b270258416898c2",
        },
        {
            "id": "cg_doc_emiko_lv5_awake_table_blush",
            "category": "event_cg",
            "path": "assets/events/emiko_lv5_cg_v1/awake_blush.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "User-approved CG; patient closeups use bare-shoulder v2.",
            "sha256": "6145153e134e0322bc27279956f0a49a7bf14c846a6791c55d1b185b9052d7bb",
        },
        {
            "id": "cg_doc_emiko_lv5_hepatic_artery_anastomosis",
            "category": "event_cg",
            "path": "assets/events/emiko_lv5_cg_v1/anastomosis_inspection.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "User-approved CG; patient closeups use bare-shoulder v2.",
            "sha256": "10171db6a4cd1dbc63c239b8f016a4acbabba360a0beb89dca0973e0f8285787",
        },
        {
            "id": "cg_doc_emiko_lv5_awake_trust",
            "category": "event_cg",
            "path": "assets/events/emiko_lv5_cg_v1/awake_trust.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "User-approved CG; patient closeups use bare-shoulder v2.",
            "sha256": "7bd0e72404f007fb19b3a9e52849df10ae50ae57c050564aa0984091b1ec7727",
        },
        {
            "id": "cg_doc_emiko_lv5_haruko_reassurance",
            "category": "event_cg",
            "path": "assets/events/emiko_lv5_cg_v1/haruko_reassurance.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "User-approved CG; patient closeups use bare-shoulder v2.",
            "sha256": "ccce6be23b5692b62e52f0d0619341b5ceaddb1de93641aef1380ed8d8a6e6cd",
        },
        {
            "id": "cg_doc_emiko_lv5_two_stretchers",
            "category": "event_cg",
            "path": "assets/events/emiko_lv5_cg_v1/two_stretchers.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "User-approved CG; patient closeups use bare-shoulder v2.",
            "sha256": "1ca5fd4d39f49207f40570cce2c694b6d4817c2de3276aa65b874c1afb081d88",
        },
        {
            "id": "cg_doc_emiko_lv5_recovery_seaside_promise",
            "category": "event_cg",
            "path": "assets/events/emiko_lv5_cg_v1/recovery_seaside_promise.png",
            "status": "integrated",
            "runtime_connected": True,
            "trigger": EVENT_ID,
            "notes": "User-approved CG; patient closeups use bare-shoulder v2.",
            "sha256": "035eaaff8baec66645e5371742e76222504f11d674ba0c0358dc0a921991b55b",
        },
    ]
    by_id = {item["id"]: item for item in manifest.get("assets", [])}
    for item in lv5_assets:
        if item["id"] not in existing_ids:
            manifest["assets"].append(item)
            existing_ids.add(item["id"])
        elif by_id[item["id"]].get("status") == "pending_codex_illustration":
            by_id[item["id"]].clear()
            by_id[item["id"]].update(item)
    write_json(ASSETS_MANIFEST_PATH, manifest)

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


def update_localization(event_obj: dict, en_data: dict) -> dict[str, int]:
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

    zh_count = 3
    en_count = 3
    for node in event_obj["nodes"]:
        nid = node["id"]
        np = f"{prefix}nodes.{nid}."
        if node["text"]:
            zh_strings[np + "text"] = node["text"]
            en_txt = nodes_en[nid]
            if CJK_RE.search(en_txt):
                raise ValueError(f"CJK character found in English translation for {nid}: {en_txt}")
            en_strings[np + "text"] = en_txt
            zh_count += 1
            en_count += 1
        zh_strings[np + "speaker_label"] = node["speaker_label"]
        en_strings[np + "speaker_label"] = speakers_en[node["speaker_label"]]
        zh_count += 1
        en_count += 1
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
            zh_count += 1
            en_count += 1

    write_json(ZH_LOCALE_PATH, zh)
    write_json(EN_LOCALE_PATH, en)
    return {"zh_CN": zh_count, "en": en_count}


def main() -> None:
    for (_, key), rel_path in CAST_PORTRAITS.items():
        full = ROOT / rel_path
        if not full.is_file():
            raise FileNotFoundError(f"Missing portrait for {key}: {full}")

    beats, choices_zh, mixed_splits, italic_strips, bold_strips = parse_manuscript()
    nodes = build_nodes(beats, choices_zh)
    en_data = read_json(EN_TRANSLATION_PATH)

    event_obj = {
        "id": EVENT_ID,
        "actor_id": ACTOR_ID,
        "title": "神的双手",
        "chapter": 5,
        "location_id": "emiko_office",
        "trigger_mode": "after_work",
        "background_id": "emiko_office",
        "outfit": "white_coat",
        "completion_background_id": "artoria_lv5_or_corridor_evening",
        "completion_outfit": "white_coat",
        "completion_expression": "warm",
        "hide_calendar_header": True,
        "minutes": 0,
        "completion_day_offset": 1,
        "completion_absolute_clock": 540,
        "teaser": "跟进整整半年的大学挚友高瀬晴子与宮原奈緒美双手术室同步活体肝移植开台前夕，御堂江美子第一次摘下医长胸牌清醒躺上坂口隆司的手术台——两双手各自守住一间手术室，也改写了外科主任之争的终点。",
        "time_start": 960,
        "time_end": 1320,
        "priority": 187,
        "category": "rank_up",
        "gallery": {
            "cg_id": "cg_emiko_lv5_hands_of_god",
            "caption": "在清醒硬膜外麻醉下亲身将肝门解剖判断权交给坂口隆司、又各自镇守一号与二号手术室圆满完成高瀬晴子与宮原奈緒美的活体右半肝移植后，御堂江美子在夕阳斜照的外科走廊主动放下主任之争，选择继续以医长之刃与他并肩。",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "max_day": 363,
            "min_affection": 0,
            "min_familiarity": 75,
            "required_events": [
                "emiko_lv4_emikos_secret"
            ],
            "days_after_required_events": 3,
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "skill",
                    "minimum": 90
                }
            ],
        },
        "auto_start": True,
        "locks_saving": True,
        "target_level": 5,
        "benefit_id": "unlock_clinical_practice_patient",
        "completion_story_flags": [
            "emiko_lv5_complete"
        ],
        "start": "em5_s1_1_01",
        "nodes": nodes,
    }

    update_staff_files()
    apply_cg_mapping(event_obj)
    write_json(EVENTS_PATH, [event_obj])
    loc_counts = update_localization(event_obj, en_data)

    patient_asset_records = {}
    for slot_key, meta in USER_SUPPLIED_PATIENT_SOURCES.items():
        runtime_full = ROOT / meta["runtime_path"]
        seed_full = ROOT / meta["repo_seed"]
        patient_asset_records[slot_key] = {
            "user_source_path": meta["source"],
            "repo_seed_path": meta["repo_seed"],
            "repo_seed_sha256": sha256_of(seed_full) if seed_full.is_file() else "",
            "runtime_path": meta["runtime_path"],
            "runtime_sha256": sha256_of(runtime_full),
            "size": meta["size"],
            "mode": "RGBA",
        }

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
        "localization_keys_written": loc_counts,
        "mixed_action_quote_splits": mixed_splits,
        "markdown_italic_syntax_strips": italic_strips,
        "markdown_bold_syntax_strips": bold_strips,
        "patient_assets": patient_asset_records,
        "story_guests_excluded_from_random_pools": [
            "haruko_takase",
            "naomi_miyahara",
        ],
        "chief_competition_contract": "Zero extra chief-competition boolean flags written; downstream Chief-of-Surgery arc checks existing Emiko Lv5 / Gate clear state only.",
    }
    write_json(IMPORT_MANIFEST_PATH, import_manifest)
    print(
        f"Imported {EVENT_ID}: {len(beats)} beats, {len(nodes)} nodes, "
        f"{len(mixed_splits)} mixed splits, {len(italic_strips)} italic strip(s), "
        f"{len(bold_strips)} bold strip(s)."
    )


if __name__ == "__main__":
    main()
