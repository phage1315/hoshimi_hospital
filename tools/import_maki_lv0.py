#!/usr/bin/env python3
"""Import Maki Aizawa (`doc_maki`) Relationship Lv0 standalone onboarding event:
《排班表上的名字》 (A Name on the OR Roster, ID: `maki_lv0_onboarding`).

Updates:
- data/staff/doc_maki/bundle.json (registers additional_character_event_files: ["lv0_events.json"])
- data/staff/doc_maki/lv0_events.json (single-session 5-scene VN, 159 nodes incl. 1 RP choice marker)
- data/localization/zh_CN.json & data/localization/en.json
- research/imports/maki_lv0_2026-11-13.json

Deliberately leaves `data/staff/doc_maki/{events,profile,relationship,date_profiles,time_events,role_rewards}.json`
untouched to preserve 100% compatibility with Codex's `maki_source_audit.py` and `maki_v1_3_source_audit.py`.
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_AIZAWA_MAKI_LV0_NAME_ON_ROSTER_V1_1.md"
EN_TRANSLATION_PATH = ROOT / "research/translations/maki_lv0_en.json"

EVENT_ID = "maki_lv0_onboarding"

CAST_PORTRAITS = {
    ("doc_maki", "white_coat/neutral"): "assets/characters/maki_original_style_v1/doc_maki/white_coat/neutral.png",
    ("doc_maki", "white_coat/focused"): "assets/characters/maki_original_style_v1/doc_maki/white_coat/focused.png",
    ("doc_maki", "white_coat/worried"): "assets/characters/maki_original_style_v1/doc_maki/white_coat/worried.png",
    ("doc_maki", "white_coat/smile"): "assets/characters/maki_original_style_v1/doc_maki/white_coat/smile.png",
    ("doc_maki", "sterile/neutral"): "assets/characters/maki_original_style_v1/doc_maki/sterile/neutral.png",
    ("doc_maki", "sterile/focused"): "assets/characters/maki_original_style_v1/doc_maki/sterile/focused.png",
    ("doc_maki", "sterile/worried"): "assets/characters/maki_original_style_v1/doc_maki/sterile/worried.png",
    ("doc_maki", "casual/neutral"): "assets/characters/maki_original_style_v1/doc_maki/casual/neutral.png",
    ("doc_maki", "casual/focused"): "assets/characters/maki_original_style_v1/doc_maki/casual/focused.png",
    ("doc_maki", "casual/worried"): "assets/characters/maki_original_style_v1/doc_maki/casual/worried.png",
    ("doc_asuka", "white_coat/neutral"): "assets/characters/portrait_pack_v15/doc_asuka/white_coat/neutral.png",
    ("nurse_hiroko", "scrubs/warm"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/scrubs/warm.png",
    ("nurse_hiroko", "sterile/neutral"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/neutral.png",
    ("nurse_hiroko", "sterile/focused"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/focused.png",
    ("nurse_hiroko", "sterile/warm"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/warm.png",
}

SPEAKER_MAP = {
    "相泽麻纪": ("actor", "doc_maki", "相泽麻纪"),
    "坂口隆司": ("player", "doc_maki", "坂口隆司"),
    "城宮明日香": ("actor", "doc_asuka", "城宮明日香"),
    "杉村弘子": ("actor", "nurse_hiroko", "杉村弘子"),
}

UNBOLD_PREFIX_SPEAKER = [
    ("伴随着轻快的脚步声", ("actor", "doc_maki", "相泽麻纪")),
    ("坂口隆司", ("player", "doc_maki", "坂口隆司")),
    ("相泽麻纪", ("actor", "doc_maki", "相泽麻纪")),
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
    # Scene A: Surgical Doctors' Office (mk0_001..mk0_026)
    if num in (1, 2):
        return ("shared_doctors_office", "white_coat", "neutral", None)
    if 3 <= num <= 5:
        return ("shared_doctors_office", "white_coat", "worried", solo("doc_maki", "white_coat/worried"))
    if num in (6, 7):
        return ("shared_doctors_office", "white_coat", "neutral", solo("doc_maki", "white_coat/neutral"))
    if num in (8, 9):
        return ("shared_doctors_office", "white_coat", "smile", solo("doc_maki", "white_coat/smile"))
    if num in (10, 11):
        return ("shared_doctors_office", "white_coat", "neutral", solo("doc_maki", "white_coat/neutral"))
    if 12 <= num <= 18:
        return ("shared_doctors_office", "white_coat", "neutral", duo("doc_asuka", "white_coat/neutral", "doc_maki", "white_coat/neutral"))
    if num in (19, 20):
        return ("shared_doctors_office", "white_coat", "focused", duo("doc_asuka", "white_coat/neutral", "doc_maki", "white_coat/focused"))
    if num in (21, 22):
        return ("shared_doctors_office", "white_coat", "neutral", duo("doc_asuka", "white_coat/neutral", "doc_maki", "white_coat/neutral"))
    if 23 <= num <= 25:
        return ("shared_doctors_office", "white_coat", "focused", solo("doc_maki", "white_coat/focused"))
    if num == 26:
        return ("shared_doctors_office", "white_coat", "smile", solo("doc_maki", "white_coat/smile"))

    # Scene B: OR Prep Workstation -> Scrub Area (mk0_027..mk0_051)
    if num == 27:
        return ("or_entrance", "white_coat", "neutral", None)
    if 28 <= num <= 33:
        return ("or_entrance", "white_coat", "focused", solo("doc_maki", "white_coat/focused"))
    if 34 <= num <= 38:
        return ("or_entrance", "white_coat", "worried", solo("doc_maki", "white_coat/worried"))
    if 39 <= num <= 41:
        return ("or_entrance", "white_coat", "focused", solo("doc_maki", "white_coat/focused"))
    if 42 <= num <= 44:
        return ("or_entrance", "white_coat", "neutral", duo("nurse_hiroko", "scrubs/warm", "doc_maki", "white_coat/neutral"))
    if 45 <= num <= 47:
        return ("or_entrance", "white_coat", "smile", duo("nurse_hiroko", "scrubs/warm", "doc_maki", "white_coat/smile"))
    if num in (48, 49):
        return ("or_entrance", "white_coat", "neutral", solo("doc_maki", "white_coat/neutral"))
    if num == 50:
        return ("or_entrance", "white_coat", "smile", solo("doc_maki", "white_coat/smile"))
    if num == 51:
        # Transition narration at the sensor scrub sinks before sterile gowning (per Manuscript 4.2)
        return ("scrub_area", "sterile", "focused", None)

    # Scene C: Operating Room #2 — Pure Fixed VN Collaboration (mk0_052..mk0_092)
    if num == 52:
        return ("operating_room", "sterile", "focused", None)
    if num == 53:
        return ("operating_room", "sterile", "focused", solo("doc_maki", "sterile/focused"))
    if num in (54, 55):
        return ("operating_room", "sterile", "focused", duo("nurse_hiroko", "sterile/focused", "doc_maki", "sterile/focused"))
    if 56 <= num <= 60:
        return ("operating_room", "sterile", "focused", solo("doc_maki", "sterile/focused"))
    if 61 <= num <= 66:
        return ("operating_room", "sterile", "worried", solo("doc_maki", "sterile/worried"))
    if 67 <= num <= 69:
        return ("operating_room", "sterile", "focused", solo("doc_maki", "sterile/focused"))
    if 70 <= num <= 73:
        return ("operating_room", "sterile", "neutral", solo("doc_maki", "sterile/neutral"))
    if 74 <= num <= 82:
        return ("operating_room", "sterile", "focused", solo("doc_maki", "sterile/focused"))
    if 83 <= num <= 85:
        return ("operating_room", "sterile", "neutral", duo("nurse_hiroko", "sterile/warm", "doc_maki", "sterile/neutral"))
    if 86 <= num <= 89:
        return ("operating_room", "sterile", "focused", solo("doc_maki", "sterile/focused"))
    if num in (90, 91):
        return ("operating_room", "sterile", "neutral", duo("nurse_hiroko", "sterile/neutral", "doc_maki", "sterile/neutral"))
    if num == 92:
        return ("operating_room", "sterile", "neutral", None)

    # Scene D: Post-op Staff Lounge & Grid Notebook Review (mk0_093..mk0_125)
    if num == 93:
        return ("staff_lounge", "white_coat", "neutral", None)
    if num in (94, 95):
        return ("staff_lounge", "white_coat", "focused", solo("doc_maki", "white_coat/focused"))
    if 96 <= num <= 98:
        return ("staff_lounge", "white_coat", "neutral", solo("doc_maki", "white_coat/neutral"))
    if num in (99, 100):
        return ("staff_lounge", "white_coat", "worried", solo("doc_maki", "white_coat/worried"))
    if 101 <= num <= 111:
        return ("staff_lounge", "white_coat", "focused", solo("doc_maki", "white_coat/focused"))
    if num in (112, 113):
        return ("staff_lounge", "white_coat", "worried", solo("doc_maki", "white_coat/worried"))
    # Branch D1-A
    if num in (114, 115):
        return ("staff_lounge", "white_coat", "focused", solo("doc_maki", "white_coat/focused"))
    if num in (116, 117):
        return ("staff_lounge", "white_coat", "smile", solo("doc_maki", "white_coat/smile"))
    # Branch D1-B
    if num in (118, 119):
        return ("staff_lounge", "white_coat", "neutral", solo("doc_maki", "white_coat/neutral"))
    if num in (120, 121):
        return ("staff_lounge", "white_coat", "smile", solo("doc_maki", "white_coat/smile"))
    # Rejoin
    if 122 <= num <= 124:
        return ("staff_lounge", "white_coat", "neutral", solo("doc_maki", "white_coat/neutral"))
    if num == 125:
        return ("staff_lounge", "white_coat", "smile", solo("doc_maki", "white_coat/smile"))

    # Scene E: 17:50 Sunset Corridor & Tomorrow's Updated Roster (mk0_126..mk0_158)
    if num in (126, 127):
        return ("hallway", "casual", "neutral", None)
    if num in (128, 129):
        return ("hallway", "casual", "worried", solo("doc_maki", "casual/worried"))
    if 130 <= num <= 133:
        return ("hallway", "casual", "neutral", solo("doc_maki", "casual/neutral"))
    if num in (134, 135):
        return ("hallway", "casual", "focused", solo("doc_maki", "casual/focused"))
    if 136 <= num <= 139:
        return ("hallway", "casual", "neutral", solo("doc_maki", "casual/neutral"))
    if num in (140, 141):
        return ("hallway", "casual", "worried", solo("doc_maki", "casual/worried"))
    if 142 <= num <= 145:
        return ("hallway", "casual", "focused", solo("doc_maki", "casual/focused"))
    if 146 <= num <= 157:
        return ("hallway", "casual", "neutral", solo("doc_maki", "casual/neutral"))
    if num == 158:
        return ("hallway", "casual", "neutral", None)
    raise ValueError(f"Unhandled beat {num}")


def parse_manuscript() -> tuple[list[tuple], dict[str, str]]:
    lines = MANUSCRIPT_PATH.read_text(encoding="utf-8").splitlines()
    in_scene_header = False
    scene = ""
    section = "main"
    beats: list[tuple] = []
    choice_labels_zh: dict[str, str] = {}
    n_idx = 0

    def next_id() -> tuple[int, str]:
        nonlocal n_idx
        n_idx += 1
        return n_idx, f"mk0_{n_idx:03d}"

    i = 37
    while i < 408:
        raw = lines[i]
        s = raw.strip()
        i += 1
        if s.startswith("### Scene "):
            scene = s.split("Scene ")[1][0]
            in_scene_header = True
            section = "main"
            continue
        if in_scene_header:
            if s == "---":
                in_scene_header = False
            continue
        if not s or s == "---" or s.startswith("*选项说明") or s.startswith("> "):
            continue
        if s.startswith("**【选择 1"):
            section = "choice_d1_prompt"
            continue
        if s.startswith("- **选项 A："):
            choice_labels_zh["choice_mk0_d1_a"] = re.match(r"^- \*\*选项 A：(「.*」)\*\*$", s).group(1)
            continue
        if s.startswith("- **选项 B："):
            choice_labels_zh["choice_mk0_d1_b"] = re.match(r"^- \*\*选项 B：(「.*」)\*\*$", s).group(1)
            continue
        if s == "**【选择选项 A 后的分支演出】**":
            section = "d1_a"
            continue
        if s == "**【选择选项 B 后的分支演出】**":
            section = "d1_b"
            continue
        if s.startswith("**【分支汇合点"):
            section = "main"
            continue

        if s == "主刀：坂口隆司。" and i < 408 and lines[i].strip() == "第一助手：相泽麻纪。":
            s2 = lines[i].strip()
            i += 1
            num, nid = next_id()
            beats.append((num, nid, scene, section, "narrator", "doc_maki", "旁白", f"{s}\n{s2}"))
            continue

        if s == "「看来人事科手脚挺快嘛，白大褂尺码很合身哦！」":
            num, nid = next_id()
            beats.append((num, nid, scene, section, "actor", "doc_asuka", "城宮明日香", s))
            continue

        m1 = re.match(r"^\*\*([^*]+)\*\*：(「.*」)$", s)
        if m1:
            sp, q = m1.groups()
            role, aid, slabel = SPEAKER_MAP[sp]
            num, nid = next_id()
            beats.append((num, nid, scene, section, role, aid, slabel, q))
            continue

        m2 = re.match(r"^\*\*([^*]+)\*\*(.+?)：(「.*」)$", s)
        if m2:
            sp, act, q = m2.groups()
            role, aid, slabel = SPEAKER_MAP[sp]
            num1, nid1 = next_id()
            beats.append((num1, nid1, scene, section, "narrator", "doc_maki", "旁白", f"{sp}{act}："))
            num2, nid2 = next_id()
            beats.append((num2, nid2, scene, section, role, aid, slabel, q))
            continue

        m3 = re.match(r"^([^「]+?)：(「.*」)$", s)
        if m3:
            pref, q = m3.groups()
            matched = next(v for k, v in UNBOLD_PREFIX_SPEAKER if pref.startswith(k))
            role, aid, slabel = matched
            num1, nid1 = next_id()
            beats.append((num1, nid1, scene, section, "narrator", "doc_maki", "旁白", f"{pref}："))
            num2, nid2 = next_id()
            beats.append((num2, nid2, scene, section, role, aid, slabel, q))
            continue

        clean_s = s.replace("**", "")
        num, nid = next_id()
        beats.append((num, nid, scene, section, "narrator", "doc_maki", "旁白", clean_s))

    assert len(beats) == 158, f"Expected 158 beats, got {len(beats)}"
    assert len(choice_labels_zh) == 2, f"Expected 2 choices, got {len(choice_labels_zh)}"
    return beats, choice_labels_zh


def build_nodes(beats: list[tuple], choice_labels_zh: dict[str, str]) -> list[dict]:
    next_override = {
        "mk0_113": "mk0_choice_d1",
        "mk0_117": "mk0_122",  # End of D1-A -> rejoin
        "mk0_121": "mk0_122",  # End of D1-B -> rejoin
        "mk0_158": "@end",
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
                "flags": [],
            }
        ]
        nodes.append(node)

        if nid == "mk0_113":
            nodes.append(
                {
                    "id": "mk0_choice_d1",
                    "presentation": "choice",
                    "speaker": "narrator",
                    "speaker_label": "旁白",
                    "actor_id": "doc_maki",
                    "text": "",
                    "expression": "worried",
                    "outfit": "white_coat",
                    "background_id": "staff_lounge",
                    "event_portraits": solo("doc_maki", "white_coat/worried"),
                    "choices": [
                        {
                            "id": "choice_mk0_d1_a",
                            "label": choice_labels_zh["choice_mk0_d1_a"],
                            "next": "mk0_114",
                            "effects": {"affection": 0, "familiarity": 0},
                            "flags": [],
                        },
                        {
                            "id": "choice_mk0_d1_b",
                            "label": choice_labels_zh["choice_mk0_d1_b"],
                            "next": "mk0_118",
                            "effects": {"affection": 0, "familiarity": 0},
                            "flags": [],
                        },
                    ],
                }
            )

    assert len(nodes) == 159, f"Expected 159 nodes, got {len(nodes)}"
    return nodes


def build_event(nodes: list[dict]) -> dict:
    return {
        "id": EVENT_ID,
        "actor_id": "doc_maki",
        "introduction_actor_ids": [
            "doc_maki",
        ],
        "completion_story_flags": [
            "maki_lv0_complete",
            "maki_aizawa_onboarded",
        ],
        "title": "排班表上的名字",
        "teaser": "获聘约一个月后，新报到的普通外科医师相泽麻纪在上班第一天便站上了坂口隆司主刀的二号手术室第一助手位置。",
        "chapter": 0,
        "location_id": "shared_doctors_office",
        "trigger_mode": "day_start",
        "background_id": "shared_doctors_office",
        "outfit": "white_coat",
        "minutes": 0,
        "time_start": 540,
        "time_end": 719,
        "priority": 120,
        "category": "introduction",
        "target_level": 1,
        "benefit_id": "",
        "auto_start": True,
        "cinematic": True,
        "locks_saving": True,
        "hide_calendar_header": True,
        "hide_completion_portrait": False,
        "completion_day_offset": 1,
        "completion_absolute_clock": 540,
        "completion_display_clock": 1070,
        "gallery": {
            "cg_id": EVENT_ID,
            "caption": "从清晨外科办公室的排班白板、首台第一助手腹股沟疝修补术，到午间手绘术野笔记与黄昏走廊上的明日排班。",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 0,
            "required_events": [
                "asuka_lv2_right_person_right_gown",
            ],
            "special_requirements": [],
        },
        "start": "mk0_001",
        "nodes": nodes,
    }


def update_bundle() -> None:
    bundle_path = ROOT / "data/staff/doc_maki/bundle.json"
    bundle = json.loads(bundle_path.read_text(encoding="utf-8"))
    extra = list(bundle.get("additional_character_event_files", []))
    if "lv0_events.json" not in extra:
        extra.append("lv0_events.json")
    bundle["additional_character_event_files"] = extra
    bundle_path.write_text(json.dumps(bundle, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def update_localization(event: dict, en_data: dict) -> tuple[int, int]:
    zh_path = ROOT / "data/localization/zh_CN.json"
    en_path = ROOT / "data/localization/en.json"
    zh_doc = json.loads(zh_path.read_text(encoding="utf-8"))
    en_doc = json.loads(en_path.read_text(encoding="utf-8"))
    zh_strings: dict[str, str] = zh_doc["strings"]
    en_strings: dict[str, str] = en_doc["strings"]

    prefix = f"collections.character_events.{EVENT_ID}"
    for store in (zh_strings, en_strings):
        stale = [k for k in store if k.startswith(prefix + ".")]
        for k in stale:
            del store[k]

    zh_added = 0
    en_added = 0

    def put(rel_key: str, zh_val: str, en_val: str) -> None:
        nonlocal zh_added, en_added
        full_key = f"{prefix}.{rel_key}"
        zh_strings[full_key] = zh_val
        en_strings[full_key] = en_val
        zh_added += 1
        en_added += 1

    put("title", event["title"], en_data["title"])
    put("teaser", event["teaser"], en_data["teaser"])
    put("gallery.caption", event["gallery"]["caption"], en_data["gallery_caption"])

    zh_strings["ui.event.workday_continues_next_day"] = "这段剧情持续至当日结束。现在是 %s"
    en_strings["ui.event.workday_continues_next_day"] = "This story continued through the end of the day. It is now %s"

    speaker_en_map = en_data["speaker_labels"]
    choice_en_map = en_data["choices"]
    node_en_map = en_data["nodes"]

    for node in event["nodes"]:
        nid = node["id"]
        zh_text = node["text"]
        if zh_text:
            put(f"nodes.{nid}.text", zh_text, node_en_map[nid])
        zh_sp = node["speaker_label"]
        put(f"nodes.{nid}.speaker_label", zh_sp, speaker_en_map[zh_sp])
        for ch in node["choices"]:
            cid = ch["id"]
            zh_lbl = ch["label"]
            if cid.startswith("continue_"):
                en_lbl = choice_en_map["continue"]
            else:
                en_lbl = choice_en_map[cid]
            put(f"nodes.{nid}.choices.{cid}.label", zh_lbl, en_lbl)

    zh_path.write_text(json.dumps(zh_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    en_path.write_text(json.dumps(en_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return zh_added, en_added


def write_import_manifest(zh_count: int, en_count: int) -> None:
    manifest_path = ROOT / "research/imports/maki_lv0_2026-11-13.json"
    manifest = {
        "event_id": EVENT_ID,
        "actor_id": "doc_maki",
        "imported_on": "2026-11-13",
        "source_manuscript": str(MANUSCRIPT_PATH.relative_to(ROOT)),
        "source_manuscript_sha256": sha256_of(MANUSCRIPT_PATH),
        "english_translation": str(EN_TRANSLATION_PATH.relative_to(ROOT)),
        "english_translation_sha256": sha256_of(EN_TRANSLATION_PATH),
        "output_event_file": "data/staff/doc_maki/lv0_events.json",
        "authored_beat_count": 158,
        "total_node_count": 159,
        "rp_choice_nodes": ["mk0_choice_d1"],
        "localization_keys_written": {"zh_CN": zh_count, "en": en_count},
        "reused_cast_portraits": {
            f"{aid}:{key}": {
                "path": path,
                "sha256": sha256_of(ROOT / path),
            }
            for (aid, key), path in sorted(CAST_PORTRAITS.items())
        },
        "onboarding_contract": {
            "prerequisite_event_id": "asuka_lv2_right_person_right_gown",
            "offer_flag": "maki_aizawa_offer_accepted",
            "minimum_delay_days": 30,
            "calendar_month_delay": 1,
            "trigger_mode": "day_start",
            "pure_vn_surgery": True,
            "unlocks_on_completion_only": True,
        },
    }
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    en_data = json.loads(EN_TRANSLATION_PATH.read_text(encoding="utf-8"))
    beats, choice_labels_zh = parse_manuscript()
    nodes = build_nodes(beats, choice_labels_zh)
    event = build_event(nodes)

    out_path = ROOT / "data/staff/doc_maki/lv0_events.json"
    out_path.write_text(json.dumps([event], ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    update_bundle()
    zh_count, en_count = update_localization(event, en_data)
    write_import_manifest(zh_count, en_count)
    print(f"Imported {EVENT_ID}: {len(nodes)} nodes, {zh_count} zh_CN keys, {en_count} en keys.")


if __name__ == "__main__":
    main()
