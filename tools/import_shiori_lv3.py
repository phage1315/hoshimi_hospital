#!/usr/bin/env python3
"""Deterministic importer for Fujisaki Shiori (`doc_shiori`) Relationship Lv3 V1.1:
《夕子的手术与那晚的归途》 (Two-Volume Arc: `Lv2 -> Lv3`):
- Volume 1 (`shiori_lv3_part_a_yuko_surgery`): 《朝日奈夕子的手术》 (Scene A1–A7 + mid-event handoff
  into `surgery_appendix` Runner at Scene A6; settles `shiori_lv3_part_a_completed` at 16:00 Day+1
  without promoting Relationship Lv3 prematurely).
- Volume 2 (`shiori_lv3_part_b_dinner_walk`): 《四人晚餐与那晚的归途》 (Scene B1–B6; 4-person dinner
  with Yuko Asahina & Megumi Mikihara, night walk, and apartment-entrance goodnight; atomically
  promotes `doc_shiori` Relationship `Lv2 -> Lv3` at Scene B6).

Strictly preserves every Chinese sentence, stage direction, speaker attribution, punctuation mark,
and choice label from the supplied V1.1 manuscripts verbatim. Registers the 2 new Lv3 backgrounds,
stages all 28 newly generated character/guest/patient portraits plus OR nursing sprites, provides
automatic `cg_path` hooks for `Scene A4` & `Scene A5` once Yuko's two NSFW CGs are placed on disk,
wires `lv3_events.json` into `doc_shiori/bundle.json` and `relationship.json`, and syncs full
`zh_CN` + `en` localization entries.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_PART_A = ROOT / "research/source_scripts/HOSHIMI_SHIORI_LV3_PART_A_YUKO_SURGERY_V1_1.md"
SOURCE_PART_B = ROOT / "research/source_scripts/HOSHIMI_SHIORI_LV3_PART_B_DINNER_WALK_V1_1.md"
OUTPUT = ROOT / "data/staff/doc_shiori/lv3_events.json"
BUNDLE = ROOT / "data/staff/doc_shiori/bundle.json"
RELATIONSHIP = ROOT / "data/staff/doc_shiori/relationship.json"
BACKGROUNDS = ROOT / "data/backgrounds.json"
TRANSLATIONS = ROOT / "research/translations/shiori_lv3_en.json"
LOCALIZATION_ZH = ROOT / "data/localization/zh_CN.json"
LOCALIZATION_EN = ROOT / "data/localization/en.json"

PART_A_ID = "shiori_lv3_part_a_yuko_surgery"
PART_B_ID = "shiori_lv3_part_b_dinner_walk"
PREFIX_A = "slv3a"
PREFIX_B = "slv3b"

SPEAKERS = {
    "旁白": ("doc_shiori", "Narrator"),
    "坂口隆司": ("player", "Ryuji Sakaguchi"),
    "藤崎詩織": ("doc_shiori", "Shiori Fujisaki"),
    "朝日奈夕子": ("doc_shiori", "Yuko Asahina"),
    "杉村弘子": ("nurse_hiroko", "Hiroko Sugimura"),
    "米田栞": ("nurse_yoneda_shiori", "Shiori Yoneda"),
    "美樹原愛": ("doc_shiori", "Megumi Mikihara"),
}

SPEAKER_EN_MAP = {zh: en for zh, (_, en) in SPEAKERS.items()}

SHIORI_WHITE_COAT_NAVY = {
    "gentle_smile": "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/gentle_smile.png",
    "surprised": "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/surprised.png",
    "wry_smile": "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/wry_smile.png",
    "professional": "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/professional.png",
    "serious_frown": "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/serious_frown.png",
    "slightly_embarrassed": "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/slightly_embarrassed.png",
}

SHIORI_SCRUBS_MASKED = {
    "neutral": "assets/characters/shiori_lv3_v1/doc_shiori/scrubs_masked/neutral.png",
    "gentle_smile": "assets/characters/shiori_lv3_v1/doc_shiori/scrubs_masked/gentle_smile.png",
    "focused": "assets/characters/shiori_lv3_v1/doc_shiori/scrubs_masked/focused.png",
    "mask_ear_cheek_blush": "assets/characters/shiori_lv3_v1/doc_shiori/scrubs_masked/mask_ear_cheek_blush.png",
}

SHIORI_STERILE = "assets/characters/portrait_pack_v17/doc_shiori/sterile/neutral.png"

SHIORI_CASUAL_DINNER = {
    "gentle_smile": "assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/gentle_smile.png",
    "polite_hurried": "assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/polite_hurried.png",
    "soft_laugh": "assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/soft_laugh.png",
    "flustered_blush": "assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/flustered_blush.png",
    "nostalgic_gentle": "assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/nostalgic_gentle.png",
    "hesitant_gaze_up": "assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/hesitant_gaze_up.png",
    "soft_goodnight_smile": "assets/characters/shiori_lv3_v1/doc_shiori/casual_dinner/soft_goodnight_smile.png",
}

YUKO_CASUAL = {
    "energetic_grin": "assets/characters/story_patients/asahina_yuko/casual/energetic_grin.png",
    "nervous_sweat": "assets/characters/story_patients/asahina_yuko/casual/nervous_sweat.png",
    "dramatic_sigh": "assets/characters/story_patients/asahina_yuko/casual/dramatic_sigh.png",
    "playful_tease": "assets/characters/story_patients/asahina_yuko/casual/playful_tease.png",
    "wink_signal": "assets/characters/story_patients/asahina_yuko/casual/wink_signal.png",
}

YUKO_OR_CAP = {
    "nervous_sweat": "assets/characters/story_patients/asahina_yuko/or_cap/nervous_sweat.png",
    "embarrassed_blush": "assets/characters/story_patients/asahina_yuko/or_cap/embarrassed_blush.png",
    "shocked_panic": "assets/characters/story_patients/asahina_yuko/or_cap/shocked_panic.png",
    "startled_yelp": "assets/characters/story_patients/asahina_yuko/or_cap/startled_yelp.png",
    "curious_awake": "assets/characters/story_patients/asahina_yuko/or_cap/curious_awake.png",
    "relieved_warm_smile": "assets/characters/story_patients/asahina_yuko/or_cap/relieved_warm_smile.png",
}

YUKO_WARD = {
    "cheerful_tease": "assets/characters/story_patients/asahina_yuko/ward/cheerful_tease.png",
    "sigh_troubled": "assets/characters/story_patients/asahina_yuko/ward/sigh_troubled.png",
    "shocked_panic": "assets/characters/story_patients/asahina_yuko/ward/shocked_panic.png",
    "nervous_blush": "assets/characters/story_patients/asahina_yuko/ward/nervous_blush.png",
    "relieved": "assets/characters/story_patients/asahina_yuko/ward/relieved.png",
}

MEGUMI_CASUAL = {
    "warm_relaxed_smile": "assets/characters/story_guests/mikihara_megumi/casual/warm_relaxed_smile.png",
    "shy_blush_bow": "assets/characters/story_guests/mikihara_megumi/casual/shy_blush_bow.png",
    "surprised_curious": "assets/characters/story_guests/mikihara_megumi/casual/surprised_curious.png",
    "flustered_coop_nod": "assets/characters/story_guests/mikihara_megumi/casual/flustered_coop_nod.png",
}

HIROKO_OR = {
    "scrubs_neutral": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/scrubs/neutral.png",
    "scrubs_warm": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/scrubs/warm.png",
    "sterile_focused": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/focused.png",
    "sterile_warm": "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/warm.png",
}

YONEDA_OR = {
    "scrubs_neutral": "assets/characters/rumi_shiori_v1/nurse_yoneda_shiori/scrubs/neutral.png",
    "scrubs_focused": "assets/characters/rumi_shiori_v1/nurse_yoneda_shiori/scrubs/focused.png",
    "sterile_focused": "assets/characters/rumi_shiori_v1/nurse_yoneda_shiori/sterile/focused.png",
}

NEW_BACKGROUNDS = [
    {
        "id": "shiori_lv3_trattoria_exterior_evening",
        "label": "商业街西口·街角木炉小餐馆门前",
        "en_label": "West Shopping Arcade · Wood-Fired Trattoria Exterior",
        "path": "assets/backgrounds/shiori_lv3_v1/trattoria_exterior_evening.png",
    },
    {
        "id": "shiori_lv3_apartment_entrance_night",
        "label": "藤崎诗织公寓楼下·门廊前",
        "en_label": "Shiori Fujisaki's Apartment · Entrance Porch",
        "path": "assets/backgrounds/shiori_lv3_v1/apartment_entrance_night.png",
    },
]

CG_ROOT = "assets/events/shiori_lv3_v1"
CG_WINDOWS_PART_A = [
    (f"{CG_ROOT}/yuko_spinal_lateral.png", 108, 128),
    (f"{CG_ROOT}/yuko_supine_sensory_test.png", 132, 148),
]


CG_WINDOWS_PART_B = [
    (f"{CG_ROOT}/dinner_toast_pov_v2.png", 60, 61),
    (f"{CG_ROOT}/apartment_hesitant.png", 169, 172),
    (f"{CG_ROOT}/apartment_goodnight.png", 173, 177),
]


def read_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, payload: object) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def infer_inline_speaker(prefix: str) -> str:
    for key, canonical in (
        ("旁边的藤崎詩織", "藤崎詩織"),
        ("藤崎詩織", "藤崎詩織"),
        ("诗织口罩", "藤崎詩織"),
        ("坂口隆司", "坂口隆司"),
        ("还没等大家分主次落座，朝日奈夕子", "朝日奈夕子"),
        ("朝日奈夕子", "朝日奈夕子"),
        ("夕子猛地", "朝日奈夕子"),
        ("美樹原愛", "美樹原愛"),
    ):
        if prefix.startswith(key):
            return canonical
    raise ValueError(f"Ambiguous inline speaker prefix: {prefix!r}")


def portrait_standing(actor_id: str, path: str, x: int, width: int = 410, height: int = 500) -> dict:
    return {
        "id": actor_id,
        "path": path,
        "x": x,
        "bottom": 540,
        "width": width,
        "height": height,
    }


def portrait_or_cap(path: str, x: int, width: int = 430, height: int = 322) -> dict:
    return {
        "id": "story_guest_asahina_yuko",
        "path": path,
        "x": x,
        "bottom": 540,
        "width": width,
        "height": height,
    }


def staging_part_a(scene: str, sb: int, mode: str, spk: str, text: str) -> tuple[str, str, list[dict]]:
    # Scene A1: Internal Medicine outpatient clinic follow-up
    if scene == "A1":
        bg, outfit = "clinic", "white_coat"
        if sb == 1:
            return bg, outfit, []
        if sb <= 5:
            yuko_e, shiori_e = "energetic_grin", "gentle_smile"
        elif sb <= 8:
            yuko_e, shiori_e = "nervous_sweat", "gentle_smile"
        elif sb <= 17:
            yuko_e = "energetic_grin" if sb <= 11 else "nervous_sweat"
            shiori_e = "serious_frown"
        elif sb <= 23:
            yuko_e, shiori_e = "nervous_sweat", "professional"
        else:
            yuko_e, shiori_e = "dramatic_sigh", "professional"
        return bg, outfit, [
            portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL[yuko_e], 460, 400, 495),
            portrait_standing("doc_shiori", SHIORI_WHITE_COAT_NAVY[shiori_e], 970),
        ]

    # Scene A2: Joint internal-surgical consult & Shiori's private request
    if scene == "A2":
        bg, outfit = "clinic", "white_coat"
        if sb == 1:
            return bg, outfit, []
        if mode == "A":
            yuko_e, shiori_e = "dramatic_sigh", "professional"
            return bg, outfit, [
                portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL[yuko_e], 460, 400, 495),
                portrait_standing("doc_shiori", SHIORI_WHITE_COAT_NAVY[shiori_e], 970),
            ]
        if mode == "B":
            yuko_e = "dramatic_sigh"
            shiori_e = "gentle_smile" if spk == "藤崎詩織" or "轻笑" in text else "wry_smile"
            return bg, outfit, [
                portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL[yuko_e], 460, 400, 495),
                portrait_standing("doc_shiori", SHIORI_WHITE_COAT_NAVY[shiori_e], 970),
            ]
        # After Yuko leaves at sb >= 25, only Shiori and Ryuji remain in the clinic
        if sb >= 25:
            if sb in (25, 26):
                return bg, outfit, []
            if sb in (27, 28, 30, 31, 33, 38):
                shiori_e = "slightly_embarrassed"
            elif sb in (32, 39):
                shiori_e = "professional"
            else:
                shiori_e = "gentle_smile"
            return bg, outfit, [
                portrait_standing("doc_shiori", SHIORI_WHITE_COAT_NAVY[shiori_e], 975),
            ]
        if sb <= 11:
            yuko_e, shiori_e = "nervous_sweat", "professional"
        elif sb <= 13:
            yuko_e, shiori_e = "nervous_sweat", "gentle_smile"
        elif sb <= 17:
            yuko_e, shiori_e = "energetic_grin", "gentle_smile"
        else:
            yuko_e, shiori_e = "nervous_sweat", "professional"
        return bg, outfit, [
            portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL[yuko_e], 460, 400, 495),
            portrait_standing("doc_shiori", SHIORI_WHITE_COAT_NAVY[shiori_e], 970),
        ]

    # Scene A3: Operating room prep (Yuko in OR cap, Shiori + Hiroko + Yoneda in scrubs)
    if scene == "A3":
        bg, outfit = "operating_room", "scrubs"
        if sb == 1:
            return bg, outfit, []
        if sb in (2, 3):
            return bg, outfit, [
                portrait_standing("nurse_yoneda_shiori", YONEDA_OR["scrubs_neutral"], 300, 370, 460),
                portrait_or_cap(YUKO_OR_CAP["embarrassed_blush"], 645),
                portrait_standing("nurse_hiroko", HIROKO_OR["scrubs_neutral"], 990, 375, 465),
            ]
        if sb in (4, 5):
            return bg, outfit, [
                portrait_or_cap(YUKO_OR_CAP["nervous_sweat"], 470, 440, 330),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["neutral"], 970),
            ]
        if 6 <= sb <= 13:
            shiori_e = "gentle_smile" if sb >= 9 else "neutral"
            return bg, outfit, [
                portrait_or_cap(YUKO_OR_CAP["nervous_sweat"], 470, 440, 330),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED[shiori_e], 970),
            ]
        if sb in (14, 15):
            return bg, outfit, [
                portrait_standing("nurse_yoneda_shiori", YONEDA_OR["scrubs_focused"], 300, 370, 460),
                portrait_or_cap(YUKO_OR_CAP["nervous_sweat"], 645),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["neutral"], 990, 380, 470),
            ]
        if 16 <= sb <= 22:
            shiori_e = "mask_ear_cheek_blush" if sb >= 20 else "neutral"
            return bg, outfit, [
                portrait_or_cap(YUKO_OR_CAP["shocked_panic"], 470, 440, 330),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED[shiori_e], 970),
            ]
        return bg, outfit, [
            portrait_standing("nurse_hiroko", HIROKO_OR["scrubs_warm"], 300, 375, 465),
            portrait_or_cap(YUKO_OR_CAP["shocked_panic"], 645),
            portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["mask_ear_cheek_blush"], 990, 380, 470),
        ]

    # Scene A4: Lateral decubitus spinal anesthesia
    if scene == "A4":
        bg, outfit = "operating_room", "scrubs"
        if sb == 1:
            return bg, outfit, []
        if 2 <= sb <= 12:
            shiori_e = "focused" if sb >= 11 else "neutral"
            yuko_e = "startled_yelp" if sb == 6 else "embarrassed_blush"
            return bg, outfit, [
                portrait_or_cap(YUKO_OR_CAP[yuko_e], 470, 440, 330),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED[shiori_e], 970),
            ]
        if 13 <= sb <= 16:
            return bg, outfit, [
                portrait_or_cap(YUKO_OR_CAP["startled_yelp"], 470, 440, 330),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["focused"], 970),
            ]
        if sb in (17, 18):
            return bg, outfit, [
                portrait_or_cap(YUKO_OR_CAP["embarrassed_blush"], 470, 440, 330),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["focused"], 970),
            ]
        if 19 <= sb <= 25:
            return bg, outfit, [
                portrait_or_cap(YUKO_OR_CAP["nervous_sweat"], 470, 440, 330),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["focused"], 970),
            ]
        return bg, outfit, [
            portrait_or_cap(YUKO_OR_CAP["nervous_sweat"], 470, 440, 330),
            portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["gentle_smile"], 970),
        ]

    # Scene A5: Supine sensory block test & Yuko's compliment -> Shiori ear/cheek blush + 22°C
    if scene == "A5":
        bg, outfit = "operating_room", "scrubs"
        if sb in (1, 2, 3):
            return bg, outfit, [
                portrait_standing("nurse_yoneda_shiori", YONEDA_OR["scrubs_focused"], 300, 370, 460),
                portrait_or_cap(YUKO_OR_CAP["embarrassed_blush"], 645),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["focused"], 990, 380, 470),
            ]
        if 4 <= sb <= 8:
            shiori_e = "mask_ear_cheek_blush" if sb >= 7 else "focused"
            return bg, outfit, [
                portrait_or_cap(YUKO_OR_CAP["embarrassed_blush"], 470, 440, 330),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED[shiori_e], 970),
            ]
        if 9 <= sb <= 14:
            return bg, outfit, [
                portrait_or_cap(YUKO_OR_CAP["nervous_sweat"], 470, 440, 330),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["mask_ear_cheek_blush"], 970),
            ]
        if 15 <= sb <= 19:
            if sb == 19:
                return bg, outfit, [
                    portrait_standing("nurse_hiroko", HIROKO_OR["scrubs_warm"], 300, 375, 465),
                    portrait_or_cap(YUKO_OR_CAP["curious_awake"], 645),
                    portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["focused"], 990, 380, 470),
                ]
            return bg, outfit, [
                portrait_or_cap(YUKO_OR_CAP["curious_awake"], 470, 440, 330),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["focused"], 970),
            ]
        if 20 <= sb <= 25:
            shiori_e = "mask_ear_cheek_blush" if sb >= 24 else "gentle_smile"
            return bg, outfit, [
                portrait_or_cap(YUKO_OR_CAP["relieved_warm_smile"], 470, 440, 330),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED[shiori_e], 970),
            ]
        if 26 <= sb <= 30:
            return bg, outfit, [
                portrait_or_cap(YUKO_OR_CAP["curious_awake"], 470, 440, 330),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["mask_ear_cheek_blush"], 970),
            ]
        if sb in (31, 32, 33):
            return bg, outfit, [
                portrait_standing("nurse_hiroko", HIROKO_OR["scrubs_warm"], 290, 370, 460),
                portrait_standing("nurse_yoneda_shiori", YONEDA_OR["scrubs_neutral"], 635, 365, 455),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["mask_ear_cheek_blush"], 990, 380, 470),
            ]
        return bg, outfit, []

    # Scene A6: Pre-Runner sterile timeout (sb 1..12) + Post-Runner closure (sb 13..22)
    if scene == "A6":
        bg, outfit = "operating_room", "sterile"
        if sb in (1, 2, 13, 14):
            return bg, outfit, []
        if 3 <= sb <= 8:
            return bg, outfit, [
                portrait_standing("nurse_hiroko", HIROKO_OR["sterile_focused"], 290, 370, 460),
                portrait_standing("nurse_yoneda_shiori", YONEDA_OR["scrubs_focused"], 635, 365, 455),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["focused"], 990, 380, 470),
            ]
        if 9 <= sb <= 12:
            return bg, outfit, [
                portrait_standing("nurse_hiroko", HIROKO_OR["sterile_focused"], 290, 370, 460),
                portrait_or_cap(YUKO_OR_CAP["nervous_sweat"], 640),
                portrait_standing("doc_shiori", SHIORI_STERILE, 990, 380, 470),
            ]
        if 15 <= sb <= 18:
            shiori_e = "gentle_smile" if sb >= 16 else "focused"
            return bg, outfit, [
                portrait_standing("nurse_hiroko", HIROKO_OR["sterile_warm"], 450, 390, 480),
                portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED[shiori_e], 975),
            ]
        yuko_e = "relieved_warm_smile" if sb >= 21 else "curious_awake"
        return bg, outfit, [
            portrait_or_cap(YUKO_OR_CAP[yuko_e], 470, 440, 330),
            portrait_standing("doc_shiori", SHIORI_SCRUBS_MASKED["gentle_smile"], 970),
        ]

    # Scene A7: Afternoon postoperative ward rounds
    bg, outfit = "ward", "white_coat"
    if sb in (1, 22):
        return bg, outfit, []
    if 2 <= sb <= 5:
        yuko_e, shiori_e = "relieved", "gentle_smile"
    elif 6 <= sb <= 13:
        yuko_e = "cheerful_tease" if sb in (6, 9, 12) else "sigh_troubled"
        shiori_e = "surprised" if sb in (7, 8) else "professional"
    elif sb in (14, 15):
        yuko_e, shiori_e = "cheerful_tease", "slightly_embarrassed"
    elif sb in (16, 17):
        yuko_e = "cheerful_tease" if sb == 16 else "relieved"
        shiori_e = "wry_smile"
    else:
        yuko_e, shiori_e = "relieved", "gentle_smile"
    return bg, outfit, [
        portrait_standing("story_guest_asahina_yuko", YUKO_WARD[yuko_e], 460, 400, 495),
        portrait_standing("doc_shiori", SHIORI_WHITE_COAT_NAVY[shiori_e], 970),
    ]


def staging_part_b(scene: str, sb: int, mode: str, spk: str, text: str) -> tuple[str, str, list[dict]]:
    # Scene B1: Outpatient suture removal & dinner invitation
    if scene == "B1":
        bg, outfit = "clinic", "white_coat"
        if sb in (1, 2):
            return bg, outfit, []
        if mode in ("A", "B"):
            return bg, outfit, [
                portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL["energetic_grin"], 460, 400, 495),
                portrait_standing("doc_shiori", SHIORI_WHITE_COAT_NAVY["gentle_smile"], 970),
            ]
        if sb == 26:
            return bg, outfit, [
                portrait_standing("doc_shiori", SHIORI_WHITE_COAT_NAVY["gentle_smile"], 975),
            ]
        if 3 <= sb <= 9:
            yuko_e, shiori_e = "energetic_grin", "gentle_smile"
        elif 10 <= sb <= 13:
            yuko_e = "nervous_sweat"
            shiori_e = "wry_smile" if sb == 12 else "gentle_smile"
        elif 14 <= sb <= 19:
            yuko_e, shiori_e = "energetic_grin", "gentle_smile"
        else:
            yuko_e = "energetic_grin"
            shiori_e = "professional" if sb in (20, 21, 22) else "gentle_smile"
        return bg, outfit, [
            portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL[yuko_e], 460, 400, 495),
            portrait_standing("doc_shiori", SHIORI_WHITE_COAT_NAVY[shiori_e], 970),
        ]

    # Scene B2: Evening exterior of the wood-fired trattoria (4-person meet-up)
    if scene == "B2":
        bg, outfit = "shiori_lv3_trattoria_exterior_evening", "casual"
        if sb in (1, 2):
            return bg, outfit, []
        if 3 <= sb <= 6:
            shiori_e = "polite_hurried" if sb >= 4 else "gentle_smile"
            return bg, outfit, [
                portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL["energetic_grin"], 285, 370, 460),
                portrait_standing("story_guest_mikihara_megumi", MEGUMI_CASUAL["warm_relaxed_smile"], 635, 370, 460),
                portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER[shiori_e], 990, 385, 475),
            ]
        if 7 <= sb <= 10:
            shiori_e = "gentle_smile" if sb >= 9 else "polite_hurried"
            return bg, outfit, [
                portrait_standing("story_guest_mikihara_megumi", MEGUMI_CASUAL["shy_blush_bow"], 465, 395, 490),
                portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER[shiori_e], 975),
            ]
        if 11 <= sb <= 14:
            shiori_e = "flustered_blush" if sb >= 12 else "gentle_smile"
            return bg, outfit, [
                portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL["playful_tease"], 460, 400, 495),
                portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER[shiori_e], 970),
            ]
        return bg, outfit, [
            portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL["energetic_grin"], 460, 400, 495),
            portrait_standing("story_guest_mikihara_megumi", MEGUMI_CASUAL["warm_relaxed_smile"], 960, 395, 490),
        ]

    # Scene B3: Four-person dinner inside the Italian trattoria
    if scene == "B3":
        bg, outfit = "italian_trattoria", "casual"
        if sb in (1, 7):
            return bg, outfit, []
        if mode in ("A", "B"):
            return bg, outfit, [
                portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL["playful_tease"], 285, 370, 460),
                portrait_standing("story_guest_mikihara_megumi", MEGUMI_CASUAL["surprised_curious"], 635, 370, 460),
                portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER["flustered_blush"], 990, 385, 475),
            ]
        if 2 <= sb <= 6:
            return bg, outfit, [
                portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL["energetic_grin"], 285, 370, 460),
                portrait_standing("story_guest_mikihara_megumi", MEGUMI_CASUAL["warm_relaxed_smile"], 635, 370, 460),
                portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER["gentle_smile"], 990, 385, 475),
            ]
        if 8 <= sb <= 12:
            megumi_e = "warm_relaxed_smile" if sb >= 11 else "shy_blush_bow"
            return bg, outfit, [
                portrait_standing("story_guest_mikihara_megumi", MEGUMI_CASUAL[megumi_e], 465, 395, 490),
                portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER["gentle_smile"], 975),
            ]
        if 13 <= sb <= 20:
            yuko_e = "playful_tease" if sb >= 16 else "energetic_grin"
            return bg, outfit, [
                portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL[yuko_e], 285, 370, 460),
                portrait_standing("story_guest_mikihara_megumi", MEGUMI_CASUAL["warm_relaxed_smile"], 635, 370, 460),
                portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER["soft_laugh"], 990, 385, 475),
            ]
        if 21 <= sb <= 26:
            megumi_e = "surprised_curious" if sb >= 24 else "warm_relaxed_smile"
            return bg, outfit, [
                portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL["playful_tease"], 285, 370, 460),
                portrait_standing("story_guest_mikihara_megumi", MEGUMI_CASUAL[megumi_e], 635, 370, 460),
                portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER["flustered_blush"], 990, 385, 475),
            ]
        return bg, outfit, [
            portrait_standing("story_guest_mikihara_megumi", MEGUMI_CASUAL["warm_relaxed_smile"], 465, 395, 490),
            portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER["gentle_smile"], 975),
        ]

    # Scene B4: Outside the trattoria at night -> Yuko's wink & Megumi's Mont Blanc excuse
    if scene == "B4":
        bg, outfit = "shiori_lv3_trattoria_exterior_evening", "casual"
        if sb in (1, 2, 20):
            return bg, outfit, []
        if 3 <= sb <= 5:
            return bg, outfit, [
                portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL["energetic_grin"], 285, 370, 460),
                portrait_standing("story_guest_mikihara_megumi", MEGUMI_CASUAL["warm_relaxed_smile"], 635, 370, 460),
                portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER["gentle_smile"], 990, 385, 475),
            ]
        if 6 <= sb <= 9:
            return bg, outfit, [
                portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL["wink_signal"], 460, 400, 495),
                portrait_standing("story_guest_mikihara_megumi", MEGUMI_CASUAL["shy_blush_bow"], 960, 395, 490),
            ]
        if 10 <= sb <= 15:
            shiori_e = "polite_hurried" if sb >= 12 else "gentle_smile"
            return bg, outfit, [
                portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL["wink_signal"], 285, 370, 460),
                portrait_standing("story_guest_mikihara_megumi", MEGUMI_CASUAL["flustered_coop_nod"], 635, 370, 460),
                portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER[shiori_e], 990, 385, 475),
            ]
        if 16 <= sb <= 19:
            return bg, outfit, [
                portrait_standing("story_guest_asahina_yuko", YUKO_CASUAL["wink_signal"], 285, 370, 460),
                portrait_standing("story_guest_mikihara_megumi", MEGUMI_CASUAL["shy_blush_bow"], 635, 370, 460),
                portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER["polite_hurried"], 990, 385, 475),
            ]
        if 21 <= sb <= 25:
            return bg, outfit, [
                portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER["flustered_blush"], 975),
            ]
        return bg, outfit, [
            portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER["gentle_smile"], 975),
        ]

    # Scene B5: Quiet tree-lined night walk together (seasonal night street)
    if scene == "B5":
        bg, outfit = "after_work_street_autumn_night", "casual"
        if sb in (1, 2, 24):
            return bg, outfit, []
        if mode == "A":
            shiori_e = "soft_laugh" if sb and (spk == "藤崎詩織" or "笑了一声" in text) else "gentle_smile"
            return bg, outfit, [portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER[shiori_e], 975)]
        if mode == "B":
            shiori_e = "flustered_blush" if (spk == "藤崎詩織" or "耳根" in text) else "gentle_smile"
            return bg, outfit, [portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER[shiori_e], 975)]
        if sb in (3, 4, 5, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23):
            shiori_e = "nostalgic_gentle"
        else:
            shiori_e = "gentle_smile"
        return bg, outfit, [portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER[shiori_e], 975)]

    # Scene B6: Shiori's apartment entrance porch at night (linear, hesitant gaze up -> goodnight)
    bg, outfit = "shiori_lv3_apartment_entrance_night", "casual"
    if sb in (7, 22):
        return bg, outfit, []
    if sb <= 6:
        shiori_e = "gentle_smile"
    elif 8 <= sb <= 16:
        shiori_e = "hesitant_gaze_up"
    else:
        shiori_e = "soft_goodnight_smile"
    return bg, outfit, [portrait_standing("doc_shiori", SHIORI_CASUAL_DINNER[shiori_e], 975)]


def apply_cg_staging_part_a(nodes: list[dict]) -> None:
    """Auto-attach Yuko's Scene A4 & Scene A5 CGs whenever those files are placed on disk."""
    by_num = {int(n["id"].split("_")[-1]): n for n in nodes}
    for rel_path, start_idx, end_idx in CG_WINDOWS_PART_A:
        if not (ROOT / rel_path).is_file():
            continue
        for idx in range(start_idx, end_idx + 1):
            node = by_num.get(idx)
            if node is None:
                continue
            node["cg_path"] = rel_path
            node["cg_fit"] = "cover"
            node["cg_dialogue_delay_seconds"] = 1.0
            node["hide_portrait"] = False
            node.pop("event_portraits", None)


def apply_cg_staging_part_b(nodes: list[dict]) -> None:
    """Apply approved Part B CGs without changing authored text or flow."""
    for node in nodes:
        idx = int(node["id"].split("_")[-1])
        for rel_path, start, end in CG_WINDOWS_PART_B:
            if start <= idx <= end:
                if not (ROOT / rel_path).is_file():
                    raise FileNotFoundError(rel_path)
                node.update(cg_path=rel_path, cg_fit="cover",
                            cg_dialogue_delay_seconds=1.0, hide_portrait=False)
                node.pop("event_portraits", None)


def parse_manuscript(
    source_path: Path,
    start_marker: str,
    end_marker: str,
    scene_regex: str,
    prefix_id: str,
    staging_fn,
    expected_choices: int,
    completion_flags: list[str],
    completion_effects: dict[str, int],
    seasonal_scenes: set[str],
) -> list[dict]:
    md_text = source_path.read_text(encoding="utf-8")
    body = start_marker + md_text.split(start_marker, 1)[1].split(end_marker, 1)[0]

    nodes: list[dict] = []
    scene = ""
    scene_beat = 0
    in_costume_header = False
    mode = "main"
    last: dict[str, dict | None] = {"main": None, "A": None, "B": None}
    choice_host: dict | None = None
    choice_labels: list[str] = []
    awaiting_merge = False

    def connect(previous: dict | None, current: dict) -> None:
        if previous is not None and not previous["choices"]:
            previous["choices"] = [
                {
                    "id": "continue_" + previous["id"],
                    "label": "继续",
                    "next": current["id"],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                }
            ]

    def append(speaker_name: str, text: str) -> dict:
        nonlocal awaiting_merge, scene_beat
        idx = len(nodes) + 1
        node_id = f"{prefix_id}_{idx:03d}"
        if mode == "main":
            scene_beat += 1

        bg_id, node_outfit, portraits = staging_fn(scene, scene_beat, mode, speaker_name, text)
        raw_actor_id, _ = SPEAKERS[speaker_name]
        if speaker_name == "旁白":
            speaker_kind = "narrator"
        elif raw_actor_id == "player":
            speaker_kind = "player"
        else:
            speaker_kind = "actor"

        node: dict = {
            "id": node_id,
            "presentation": "authored",
            "speaker": speaker_kind,
            "actor_id": "doc_shiori",
            "speaker_label": speaker_name,
            "text": text,
            "expression": "neutral",
            "outfit": node_outfit,
            "background_id": bg_id,
            "hide_portrait": len(portraits) == 0,
            "choices": [],
        }
        if scene in seasonal_scenes:
            node["seasonal_street"] = True
        if portraits:
            node["event_portraits"] = portraits
        nodes.append(node)

        if mode in ("A", "B"):
            connect(last[mode], node)
            last[mode] = node
            slot = 0 if mode == "A" else 1
            if choice_host is None or len(choice_host["choices"]) != 2:
                raise ValueError(f"Choice branch without host at {node_id}")
            if not choice_host["choices"][slot]["next"]:
                choice_host["choices"][slot]["next"] = node_id
            return node

        if awaiting_merge:
            connect(last["A"], node)
            connect(last["B"], node)
            last["A"] = None
            last["B"] = None
            awaiting_merge = False
        else:
            connect(last["main"], node)
        last["main"] = node
        return node

    for raw in body.splitlines():
        line = raw.strip()
        if not line:
            continue
        if line == "---":
            in_costume_header = False
            continue

        m_scene = re.match(scene_regex, line)
        if m_scene:
            scene = m_scene.group(1)
            scene_beat = 0
            in_costume_header = False
            mode = "main"
            continue

        if line.startswith(("**【场景】**", "**【时间】**", "**【在场角色】**")):
            continue
        if line.startswith("**【服装与状态】**"):
            in_costume_header = True
            continue
        if in_costume_header and line.startswith("- "):
            continue
        if line in (
            "**【切入普通 Surgery Runner 前的短过场（玩家可见）】**",
            "**【普通 Surgery Runner 顺利完成后的收尾短过场（玩家可见）】**",
        ) or line.startswith("> **【==="):
            continue

        if re.match(r"^\*\*【选择 \d+（Choice [AB]\d+）：.+】\*\*$", line):
            if last["main"] is None:
                raise ValueError(f"Choice block without visible host: {line}")
            choice_host = last["main"]
            last["main"] = None
            choice_labels = []
            mode = "choice"
            continue

        if line.startswith("*选项说明：") and line.endswith("*"):
            continue

        m_opt = re.match(r"^- \*\*选项 ([AB])：(「.+」)\*\*$", line)
        if m_opt:
            if choice_host is None:
                raise ValueError(f"Option line without choice host: {line}")
            choice_labels.append(m_opt.group(2))
            if len(choice_labels) == 2:
                choice_host["choices"] = [
                    {
                        "id": f"choice_{choice_host['id']}_{suffix}",
                        "label": lbl,
                        "next": "",
                        "effects": {"affection": 0, "familiarity": 0},
                        "flags": [],
                    }
                    for suffix, lbl in zip(("a", "b"), choice_labels)
                ]
            continue

        if line == "**【选择选项 A 后的分支演出】**":
            mode, last["A"] = "A", None
            continue
        if line == "**【选择选项 B 后的分支演出】**":
            mode, last["B"] = "B", None
            continue
        if re.match(r"^\*\*【分支汇合点：.+】\*\*$", line):
            mode = "main"
            awaiting_merge = True
            continue

        m_dlg = re.fullmatch(r"\*\*([^*]+)\*\*：(「.+」)", line)
        if m_dlg:
            spk = m_dlg.group(1).strip()
            quote = m_dlg.group(2).strip()
            if spk not in SPEAKERS:
                raise ValueError(f"Unknown speaker {spk!r}")
            node = append(spk, quote)
            if prefix_id == PREFIX_A and scene == "A6" and spk == "杉村弘子" and quote == "「是，圆刃刀。」":
                node["action"] = "launch_shiori_lv3_yuko_surgery"
            continue

        m_paren = re.fullmatch(r"\*\*([^*]+)\*\*（([^）]+)）：(「.+」)", line)
        if m_paren:
            spk = m_paren.group(1).strip()
            act = m_paren.group(2).strip()
            quote = m_paren.group(3).strip()
            if spk not in SPEAKERS:
                raise ValueError(f"Unknown speaker {spk!r}")
            append("旁白", f"{spk}（{act}）：")
            append(spk, quote)
            continue

        m_mix = re.match(r"^(.+?)：(「[^「」]+」)$", line)
        if m_mix:
            pref, quote = m_mix.group(1), m_mix.group(2)
            spk = infer_inline_speaker(pref)
            append("旁白", pref + "：")
            append(spk, quote)
            continue

        if line.startswith(("#", "**", "- ", "*")):
            raise ValueError(f"Unexpected directive/markdown line in {source_path.name}: {line!r}")

        append("旁白", line)

    if awaiting_merge or last["A"] is not None or last["B"] is not None:
        raise ValueError(f"Unclosed branch in {source_path.name}")
    if sum(1 for n in nodes if len(n["choices"]) == 2) != expected_choices:
        raise ValueError(f"Expected {expected_choices} two-option choices in {source_path.name}")

    nodes[-1]["choices"] = [
        {
            "id": "finish_" + nodes[-1]["id"],
            "label": "结束",
            "next": "@end",
            "effects": completion_effects,
            "flags": list(completion_flags),
        }
    ]
    return nodes


def register_backgrounds() -> None:
    bgs: list[dict] = read_json(BACKGROUNDS)  # type: ignore[assignment]
    by_id = {str(item.get("id", "")): item for item in bgs}
    changed = False
    for entry in NEW_BACKGROUNDS:
        existing = by_id.get(entry["id"])
        record = {"id": entry["id"], "label": entry["label"], "path": entry["path"]}
        if existing is None:
            bgs.append(record)
            changed = True
        elif existing != record:
            existing.clear()
            existing.update(record)
            changed = True
    if changed:
        write_json(BACKGROUNDS, bgs)


def main() -> None:
    nodes_a = parse_manuscript(
        source_path=SOURCE_PART_A,
        start_marker="## Scene A1｜四周后的回诊——诗织的眉头",
        end_marker="**【Part A 结束｜登记",
        scene_regex=r"^## Scene (A[1-7])｜",
        prefix_id=PREFIX_A,
        staging_fn=staging_part_a,
        expected_choices=1,
        completion_flags=["shiori_lv3_part_a_completed"],
        completion_effects={"affection": 2, "familiarity": 2},
        seasonal_scenes=set(),
    )
    if sum(1 for n in nodes_a if n.get("action") == "launch_shiori_lv3_yuko_surgery") != 1:
        raise ValueError("Missing launch_shiori_lv3_yuko_surgery handoff action on Scene A6")
    apply_cg_staging_part_a(nodes_a)

    nodes_b = parse_manuscript(
        source_path=SOURCE_PART_B,
        start_marker="## Scene B1｜夕子出院复诊：主动发出的答谢邀请",
        end_marker="**【事件结束｜原子性结算：",
        scene_regex=r"^## Scene (B[1-6])｜",
        prefix_id=PREFIX_B,
        staging_fn=staging_part_b,
        expected_choices=3,
        completion_flags=["shiori_lv3_complete", "shiori_lv3_dinner_walk_completed"],
        completion_effects={"affection": 3, "familiarity": 3},
        seasonal_scenes={"B5"},
    )

    apply_cg_staging_part_b(nodes_b)

    register_backgrounds()

    part_a_gallery_path = (
        f"{CG_ROOT}/yuko_spinal_lateral.png"
        if (ROOT / f"{CG_ROOT}/yuko_spinal_lateral.png").is_file()
        else ""
    )

    lv3_requirements = [
        {"type": "player_attribute", "attribute": "skill", "minimum": 65},
        {"type": "player_attribute", "attribute": "charm", "minimum": 30},
    ]

    event_a = {
        "id": PART_A_ID,
        "actor_id": "doc_shiori",
        "completion_story_flags": ["shiori_lv3_part_a_completed"],
        "title": "朝日奈夕子的手术",
        "teaser": "出院四周后回内科复查靶向超声的朝日奈夕子，被藤崎詩織锁定了嵌在阑尾根部的成形粪石；次日清晨的手术台上，你将与担任第一助手的诗织联手完成这台清醒腰麻阑尾切除术。",
        "chapter": 3,
        "location_id": "clinic",
        "trigger_mode": "location",
        "background_id": "clinic",
        "outfit": "white_coat",
        "minutes": 0,
        "time_start": 900,
        "time_end": 1020,
        "priority": 114,
        "category": "contextual",
        "target_level": 3,
        "benefit_id": "",
        "auto_start": False,
        "cinematic": True,
        "locks_saving": True,
        "hide_calendar_header": True,
        "hide_completion_portrait": False,
        "completion_day_offset": 1,
        "completion_absolute_clock": 960,
        "gallery": {
            "cg_id": PART_A_ID,
            "caption": "靶向超声锁定阑尾粪石后的联合评估、腰麻平面测试与默契十足的开腹阑尾切除术。",
            "path": part_a_gallery_path,
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 40,
            "required_events": ["shiori_lv2_record_shop"],
            "days_after_required_events": 28,
            "special_requirements": lv3_requirements,
        },
        "start": nodes_a[0]["id"],
        "nodes": nodes_a,
    }

    event_b = {
        "id": PART_B_ID,
        "actor_id": "doc_shiori",
        "completion_story_flags": [
            "shiori_lv3_complete",
            "shiori_lv3_dinner_walk_completed",
        ],
        "title": "四人晚餐与那晚的归途",
        "teaser": "顺利康复回院拆线的朝日奈夕子向你和藤崎詩織发出了木炉小餐馆的答谢邀约；两天后的傍晚，商业街西口暖黄的壁灯下还多了一位害羞温柔的高中老友美樹原愛。",
        "chapter": 4,
        "location_id": "clinic",
        "trigger_mode": "location",
        "background_id": "clinic",
        "outfit": "white_coat",
        "minutes": 0,
        "time_start": 960,
        "time_end": 1020,
        "priority": 115,
        "category": "rank_up",
        "chain_followup": True,
        "target_level": 3,
        "benefit_id": "",
        "auto_start": False,
        "cinematic": True,
        "locks_saving": True,
        "hide_calendar_header": True,
        "hide_completion_portrait": False,
        "consumes_sunday": False,
        "completion_day_offset": 3,
        "completion_absolute_clock": 540,
        "gallery": {
            "cg_id": PART_B_ID,
            "caption": "木炉小餐馆里的四人欢声笑语、安静林荫道上的并肩夜行，以及公寓门廊橘光下的那句晚安。",
            "path": f"{CG_ROOT}/apartment_goodnight.png",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 40,
            "required_events": [PART_A_ID],
            "days_after_required_events": 6,
            "special_requirements": lv3_requirements,
        },
        "start": nodes_b[0]["id"],
        "nodes": nodes_b,
    }

    write_json(OUTPUT, [event_a, event_b])

    bundle_doc: dict = read_json(BUNDLE)  # type: ignore[assignment]
    extra_files: list[str] = list(bundle_doc.get("additional_character_event_files", []))
    if "lv3_events.json" not in extra_files:
        extra_files.append("lv3_events.json")
        bundle_doc["additional_character_event_files"] = extra_files
        write_json(BUNDLE, bundle_doc)

    rel_doc: dict = read_json(RELATIONSHIP)  # type: ignore[assignment]
    for slot in rel_doc.get("rank_slots", []):
        if int(slot.get("target_level", -1)) == 3:
            slot["event_id"] = PART_B_ID
            slot["content_status"] = "authored"
            slot["benefit_id"] = ""
            slot["min_familiarity"] = 40
            slot["cooldown_days"] = 3
            slot["special_requirements"] = lv3_requirements
    write_json(RELATIONSHIP, rel_doc)

    if not TRANSLATIONS.exists():
        dump = {}
        for key_name, ev in (("part_a", event_a), ("part_b", event_b)):
            dump[key_name] = {
                "id": ev["id"],
                "title": ev["title"],
                "teaser": ev["teaser"],
                "gallery_caption": ev["gallery"]["caption"],
                "beats": [
                    {
                        "id": b["id"],
                        "speaker": b["speaker_label"],
                        "text": b["text"],
                        "choices": [
                            {"id": c["id"], "label": c["label"]}
                            for c in b["choices"]
                            if len(b["choices"]) == 2
                        ],
                    }
                    for b in ev["nodes"]
                ],
            }
        Path("/private/tmp/shiori_lv3_zh_beats.json").write_text(
            json.dumps(dump, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        print(
            f"Parsed Part A ({len(nodes_a)} beats) + Part B ({len(nodes_b)} beats); "
            "wrote ZH dump to /private/tmp/shiori_lv3_zh_beats.json"
        )
        return

    translations: dict = read_json(TRANSLATIONS)  # type: ignore[assignment]
    zh_doc: dict = read_json(LOCALIZATION_ZH)  # type: ignore[assignment]
    en_doc: dict = read_json(LOCALIZATION_EN)  # type: ignore[assignment]
    zh_strings: dict[str, str] = zh_doc["strings"]
    en_strings: dict[str, str] = en_doc["strings"]

    zh_strings["ui.crisis.story_retry"] = "重新进行本台手术  →"
    en_strings["ui.crisis.story_retry"] = "Retry This Operation  →"

    for bg in NEW_BACKGROUNDS:
        bg_key = f"collections.backgrounds.{bg['id']}.label"
        zh_strings[bg_key] = bg["label"]
        en_strings[bg_key] = bg["en_label"]

    for section_key, ev in (("part_a", event_a), ("part_b", event_b)):
        ev_id = ev["id"]
        tr_sec: dict = translations[section_key]
        en_nodes: dict[str, str] = tr_sec["nodes"]
        en_choices: dict[str, str] = tr_sec["choices"]

        prefix_event = f"collections.character_events.{ev_id}"
        for target in (zh_strings, en_strings):
            stale = [k for k in target if k.startswith(prefix_event + ".")]
            for k in stale:
                del target[k]

        zh_strings[f"{prefix_event}.title"] = ev["title"]
        zh_strings[f"{prefix_event}.teaser"] = ev["teaser"]
        zh_strings[f"{prefix_event}.gallery.caption"] = ev["gallery"]["caption"]

        en_strings[f"{prefix_event}.title"] = str(tr_sec["title"])
        en_strings[f"{prefix_event}.teaser"] = str(tr_sec["teaser"])
        en_strings[f"{prefix_event}.gallery.caption"] = str(tr_sec["gallery_caption"])

        for node in ev["nodes"]:
            nid = node["id"]
            if nid not in en_nodes or not str(en_nodes[nid]).strip():
                raise ValueError(f"Missing English translation for beat {nid}")
            spk_zh = node["speaker_label"]
            if spk_zh not in SPEAKER_EN_MAP:
                raise ValueError(f"Unmapped speaker_label for EN: {spk_zh!r}")

            zh_strings[f"{prefix_event}.nodes.{nid}.text"] = node["text"]
            zh_strings[f"{prefix_event}.nodes.{nid}.speaker_label"] = spk_zh
            en_strings[f"{prefix_event}.nodes.{nid}.text"] = str(en_nodes[nid])
            en_strings[f"{prefix_event}.nodes.{nid}.speaker_label"] = SPEAKER_EN_MAP[spk_zh]

            for ch in node["choices"]:
                cid = ch["id"]
                clabel = ch["label"]
                zh_strings[f"{prefix_event}.nodes.{nid}.choices.{cid}.label"] = clabel
                if clabel == "继续":
                    en_strings[f"{prefix_event}.nodes.{nid}.choices.{cid}.label"] = "Continue"
                elif clabel == "结束":
                    en_strings[f"{prefix_event}.nodes.{nid}.choices.{cid}.label"] = "Finish"
                else:
                    if cid not in en_choices or not str(en_choices[cid]).strip():
                        raise ValueError(f"Missing English choice translation for {cid}")
                    en_strings[f"{prefix_event}.nodes.{nid}.choices.{cid}.label"] = str(en_choices[cid])

    write_json(LOCALIZATION_ZH, zh_doc)
    write_json(LOCALIZATION_EN, en_doc)
    print(
        f"Imported {PART_A_ID} ({len(nodes_a)} beats) + {PART_B_ID} ({len(nodes_b)} beats), "
        "zh_CN + en synced."
    )


if __name__ == "__main__":
    main()
