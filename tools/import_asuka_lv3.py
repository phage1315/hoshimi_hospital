#!/usr/bin/env python3
"""Import Asuka Shiromiya (`doc_asuka`) Relationship Lv3:
《本院长不接受反驳哦》 (No Objections Allowed from This Director).

Updates:
- data/backgrounds.json (registers 2 new 1376x768 backgrounds for Lv3)
- data/staff/doc_asuka/bundle.json (registers lv3_events.json alongside lv2_events.json)
- data/staff/doc_asuka/profile.json (registers outfits "date_cardigan" + "vintage_cream_gown" and 8 1024x1536 RGBA portraits)
- data/staff/doc_asuka/relationship.json (marks target_level 3 slot authored -> asuka_lv3_no_objections)
- data/staff/doc_asuka/lv3_events.json (Sunday Date invite VN, 177 nodes with A-1 / A-2 opening variants + mirror CG)
- data/localization/zh_CN.json & data/localization/en.json
- research/generated_candidates/asuka_lv3_v1/generation.json
- research/imports/asuka_lv3_2026-11-14.json
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_ASUKA_LV3_NO_OBJECTIONS_V1_1.md"
EN_TRANSLATION_PATH = ROOT / "research/translations/asuka_lv3_en.json"

EVENT_ID = "asuka_lv3_no_objections"
CG_PATH = "assets/events/asuka_lv3_v1/vintage_cream_gown_mirror.png"

NEW_BACKGROUNDS = [
    {
        "id": "asuka_lv3_cafe_exterior_day",
        "label": "街角咖啡馆门前",
        "path": "assets/backgrounds/asuka_lv3_v1/cafe_exterior_day.png",
    },
    {
        "id": "asuka_lv3_archive_room_afternoon",
        "label": "后院旧馆二楼·院史资料室",
        "path": "assets/backgrounds/asuka_lv3_v1/hospital_archive_room_afternoon.png",
    },
]

NEW_PORTRAITS = {
    "date_cardigan/neutral": "assets/characters/asuka_lv3_v1/doc_asuka/date_cardigan/smile.png",
    "date_cardigan/smile": "assets/characters/asuka_lv3_v1/doc_asuka/date_cardigan/smile.png",
    "date_cardigan/playful": "assets/characters/asuka_lv3_v1/doc_asuka/date_cardigan/playful.png",
    "date_cardigan/nostalgic": "assets/characters/asuka_lv3_v1/doc_asuka/date_cardigan/nostalgic.png",
    "date_cardigan/laugh": "assets/characters/asuka_lv3_v1/doc_asuka/date_cardigan/laugh.png",
    "date_cardigan/shy": "assets/characters/asuka_lv3_v1/doc_asuka/date_cardigan/shy.png",
    "vintage_cream_gown/neutral": "assets/characters/asuka_lv3_v1/doc_asuka/vintage_cream_gown/expectant.png",
    "vintage_cream_gown/expectant": "assets/characters/asuka_lv3_v1/doc_asuka/vintage_cream_gown/expectant.png",
    "vintage_cream_gown/shy_earnest": "assets/characters/asuka_lv3_v1/doc_asuka/vintage_cream_gown/shy_earnest.png",
    "vintage_cream_gown/blushing_happy": "assets/characters/asuka_lv3_v1/doc_asuka/vintage_cream_gown/blushing_happy.png",
}

SPEAKER_MAP = {
    "城宮明日香": ("actor", "doc_asuka", "城宮明日香"),
    "坂口隆司": ("player", "doc_asuka", "坂口隆司"),
}

UNBOLD_PREFIX_SPEAKER = [
    ("她一边说", ("actor", "doc_asuka", "城宮明日香")),
    ("坂口隆司仔细看了一眼", ("player", "doc_asuka", "坂口隆司")),
    ("空气安静了半秒，坂口隆司实在没绷住", ("player", "doc_asuka", "坂口隆司")),
    ("坂口隆司微微一怔", ("player", "doc_asuka", "坂口隆司")),
]


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def solo_asuka(key: str) -> list[dict]:
    path = NEW_PORTRAITS[key]
    return [
        {
            "id": "doc_asuka",
            "path": path,
            "x": 985,
            "bottom": 556,
            "width": 320,
            "height": 480,
        }
    ]


def parse_manuscript() -> dict[str, list[dict]]:
    """Parse V1.1 manuscript into sections: intro, a1, a2, body."""
    raw_lines = MANUSCRIPT_PATH.read_text(encoding="utf-8").splitlines()
    start_idx = next(i for i, line in enumerate(raw_lines) if line.startswith("### Scene A｜"))
    end_idx = next(i for i, line in enumerate(raw_lines) if line.startswith("> **【事件结束｜原子性结算】**"))

    sections: dict[str, list[dict]] = {"intro": [], "a1": [], "a2": [], "body": []}
    mode = "intro"
    current_scene = "Scene A"

    def append_beats(target: list[dict], line: str) -> None:
        # Clean ONLY the 2 explicitly documented non-diegetic / markdown items:
        # 1) Scene C staging note: （仅在身前展示比划，并未换穿）
        # 2) Scene D markdown bold asterisks: **奶白色** -> 奶白色
        cleaned = line.replace("（仅在身前展示比划，并未换穿）", "")
        cleaned = cleaned.replace("**奶白色**", "奶白色")

        m_bold = re.match(r"^\*\*(.+?)\*\*（(.+?)）：(「.+」)$", cleaned)
        if m_bold:
            spk, stage_dir, quote = m_bold.groups()
            role, actor_id, spk_label = SPEAKER_MAP[spk]
            target.append(
                {
                    "scene": current_scene,
                    "speaker": "narrator",
                    "actor_id": "doc_asuka",
                    "speaker_label": "旁白",
                    "text": f"{spk}（{stage_dir}）：",
                }
            )
            target.append(
                {
                    "scene": current_scene,
                    "speaker": role,
                    "actor_id": actor_id,
                    "speaker_label": spk_label,
                    "text": quote,
                }
            )
            return

        m_direct = re.match(r"^\*\*(.+?)\*\*：(「.+」)$", cleaned)
        if m_direct:
            spk, quote = m_direct.groups()
            role, actor_id, spk_label = SPEAKER_MAP[spk]
            target.append(
                {
                    "scene": current_scene,
                    "speaker": role,
                    "actor_id": actor_id,
                    "speaker_label": spk_label,
                    "text": quote,
                }
            )
            return

        m_unbold = re.match(r"^(.+?)：(「[^「」]*」)$", cleaned)
        if m_unbold:
            prefix, quote = m_unbold.groups()
            matched_speaker = None
            for pfx, spk_tuple in UNBOLD_PREFIX_SPEAKER:
                if prefix.startswith(pfx):
                    matched_speaker = spk_tuple
                    break
            if matched_speaker is not None:
                role, actor_id, spk_label = matched_speaker
                target.append(
                    {
                        "scene": current_scene,
                        "speaker": "narrator",
                        "actor_id": "doc_asuka",
                        "speaker_label": "旁白",
                        "text": f"{prefix}：",
                    }
                )
                target.append(
                    {
                        "scene": current_scene,
                        "speaker": role,
                        "actor_id": actor_id,
                        "speaker_label": spk_label,
                        "text": quote,
                    }
                )
                return

        target.append(
            {
                "scene": current_scene,
                "speaker": "narrator",
                "actor_id": "doc_asuka",
                "speaker_label": "旁白",
                "text": cleaned,
            }
        )

    in_meta_list = False
    for raw in raw_lines[start_idx:end_idx]:
        s = raw.strip()
        if not s or s == "---":
            in_meta_list = False
            continue
        if s.startswith("### Scene "):
            current_scene = s.split("｜")[0].replace("### ", "").strip()
            in_meta_list = False
            continue
        if s.startswith("**【"):
            in_meta_list = True
            continue
        if in_meta_list and s.startswith("- "):
            continue
        in_meta_list = False

        if s.startswith("#### 【分支 A-1"):
            mode = "a1"
            continue
        if s.startswith("#### 【分支 A-2"):
            mode = "a2"
            continue
        if s.startswith("> **【分支汇合点】**"):
            mode = "body"
            continue
        if s.startswith("> **【"):
            # Skip non-diegetic stage markers (> **【开场条件分支...】**, > **【触发核心专属 CG...】**)
            continue

        append_beats(sections[mode], s)

    assert len(sections["intro"]) == 3, f"Expected 3 intro beats, got {len(sections['intro'])}"
    assert len(sections["a1"]) == 8, f"Expected 8 A-1 beats, got {len(sections['a1'])}"
    assert len(sections["a2"]) == 8, f"Expected 8 A-2 beats, got {len(sections['a2'])}"
    assert len(sections["body"]) == 155, f"Expected 155 body beats, got {len(sections['body'])}"
    return sections


def visual_spec_for_node(nid: str) -> dict:
    """Return visual staging dict for a given node id."""
    if nid in ("al3_a1_001", "al3_a1_002", "al3_a2_001", "al3_a2_002"):
        return {
            "background_id": "asuka_lv3_cafe_exterior_day",
            "outfit": "date_cardigan",
            "expression": "smile",
            "hide_portrait": True,
            "sunday_clock": 840,
        }
    if nid in ("al3_a1_003", "al3_a2_003"):
        return {
            "background_id": "asuka_lv3_cafe_exterior_day",
            "outfit": "date_cardigan",
            "expression": "smile",
            "hide_portrait": False,
            "event_portraits": solo_asuka("date_cardigan/smile"),
            "sunday_clock": 840,
        }
    if nid.startswith("al3_a1_"):
        idx = int(nid.split("_")[-1])
        expr = "playful" if 4 <= idx <= 8 else "smile"
        return {
            "background_id": "asuka_lv3_cafe_exterior_day",
            "outfit": "date_cardigan",
            "expression": expr,
            "hide_portrait": False,
            "event_portraits": solo_asuka(f"date_cardigan/{expr}"),
            "sunday_clock": 840,
        }
    if nid.startswith("al3_a2_"):
        idx = int(nid.split("_")[-1])
        expr = "smile" if 4 <= idx <= 7 else "laugh"
        return {
            "background_id": "asuka_lv3_cafe_exterior_day",
            "outfit": "date_cardigan",
            "expression": expr,
            "hide_portrait": False,
            "event_portraits": solo_asuka(f"date_cardigan/{expr}"),
            "sunday_clock": 840,
        }

    num = int(nid.split("_")[-1])

    # Scene A merge (al3_012..al3_017)
    if 12 <= num <= 17:
        if num == 16:
            expr = "shy"
        elif num == 17:
            expr = "smile"
        else:
            expr = "playful"
        return {
            "background_id": "asuka_lv3_cafe_exterior_day",
            "outfit": "date_cardigan",
            "expression": expr,
            "hide_portrait": False,
            "event_portraits": solo_asuka(f"date_cardigan/{expr}"),
            "sunday_clock": 845,
        }

    # Scene B interior cafe (al3_018..al3_039)
    if num == 18:
        return {
            "background_id": "date_cafe",
            "outfit": "date_cardigan",
            "expression": "smile",
            "hide_portrait": True,
            "sunday_clock": 850,
        }
    if 19 <= num <= 39:
        if 19 <= num <= 22:
            expr = "nostalgic"
        elif 23 <= num <= 24:
            expr = "playful"
        elif 25 <= num <= 31:
            expr = "smile"
        elif 32 <= num <= 37:
            expr = "playful"
        else:
            expr = "laugh"
        return {
            "background_id": "date_cafe",
            "outfit": "date_cardigan",
            "expression": expr,
            "hide_portrait": False,
            "event_portraits": solo_asuka(f"date_cardigan/{expr}"),
            "sunday_clock": 870,
        }

    # Scene B exterior cafe steps (al3_040..al3_048)
    if 40 <= num <= 48:
        expr = "shy" if 40 <= num <= 42 else "laugh"
        return {
            "background_id": "asuka_lv3_cafe_exterior_day",
            "outfit": "date_cardigan",
            "expression": expr,
            "hide_portrait": False,
            "event_portraits": solo_asuka(f"date_cardigan/{expr}"),
            "sunday_clock": 895,
        }

    # Scene C–E archive room (al3_049..al3_120) + Scene F pre-change (al3_121..al3_132)
    if 49 <= num <= 51 or 128 <= num <= 132 or num == 156:
        clock = 915 if num <= 51 else (955 if num <= 132 else 975)
        return {
            "background_id": "asuka_lv3_archive_room_afternoon",
            "outfit": "date_cardigan",
            "expression": "smile",
            "hide_portrait": True,
            "sunday_clock": clock,
        }

    if 52 <= num <= 127:
        if num in (53, 54) or 57 <= num <= 62:
            expr = "playful"
        elif 69 <= num <= 73:
            expr = "nostalgic"
        elif 79 <= num <= 83:
            expr = "nostalgic"
        elif 87 <= num <= 94:
            expr = "playful"
        elif 95 <= num <= 97 or num in (102, 103) or num in (110, 111):
            expr = "laugh"
        elif 106 <= num <= 109 or 123 <= num <= 126:
            expr = "shy"
        elif 112 <= num <= 114 or num in (121, 122):
            expr = "nostalgic"
        elif 115 <= num <= 119 or num == 127:
            expr = "playful"
        else:
            expr = "smile"
        clock = 920 if num <= 73 else (930 if num <= 85 else (940 if num <= 120 else 955))
        return {
            "background_id": "asuka_lv3_archive_room_afternoon",
            "outfit": "date_cardigan",
            "expression": expr,
            "hide_portrait": False,
            "event_portraits": solo_asuka(f"date_cardigan/{expr}"),
            "sunday_clock": clock,
        }

    # Scene F full-screen Mirror CG (al3_133..al3_139)
    if 133 <= num <= 139:
        return {
            "background_id": "asuka_lv3_archive_room_afternoon",
            "outfit": "vintage_cream_gown",
            "expression": "expectant",
            "hide_portrait": False,
            "cg_path": CG_PATH,
            "cg_fit": "cover",
            "sunday_clock": 960,
        }

    # Scene F vintage cream gown standing portraits (al3_140..al3_155)
    if 140 <= num <= 155:
        if 140 <= num <= 141:
            expr = "expectant"
        elif 142 <= num <= 149:
            expr = "shy_earnest"
        else:
            expr = "blushing_happy"
        return {
            "background_id": "asuka_lv3_archive_room_afternoon",
            "outfit": "vintage_cream_gown",
            "expression": expr,
            "hide_portrait": False,
            "event_portraits": solo_asuka(f"vintage_cream_gown/{expr}"),
            "sunday_clock": 965,
        }

    # Scene G dusk courtyard (al3_157..al3_166)
    if num in (157, 166):
        return {
            "background_id": "hospital_courtyard_evening",
            "outfit": "date_cardigan",
            "expression": "smile",
            "hide_portrait": True,
            "sunday_clock": 1005,
        }
    if 158 <= num <= 165:
        if 158 <= num <= 160:
            expr = "smile"
        elif 161 <= num <= 162:
            expr = "playful"
        else:
            expr = "laugh"
        return {
            "background_id": "hospital_courtyard_evening",
            "outfit": "date_cardigan",
            "expression": expr,
            "hide_portrait": False,
            "event_portraits": solo_asuka(f"date_cardigan/{expr}"),
            "sunday_clock": 1005,
        }

    raise ValueError(f"Unhandled node id: {nid}")


def build_nodes(sections: dict[str, list[dict]]) -> list[dict]:
    nodes: list[dict] = []

    def make_node(nid: str, beat: dict, next_id: str) -> dict:
        vis = visual_spec_for_node(nid)
        node: dict = {
            "id": nid,
            "presentation": "authored",
            "speaker": beat["speaker"],
            "actor_id": beat["actor_id"],
            "speaker_label": beat["speaker_label"],
            "text": beat["text"],
            "background_id": vis["background_id"],
            "outfit": vis["outfit"],
            "expression": vis["expression"],
            "hide_portrait": vis["hide_portrait"],
            "sunday_clock": vis["sunday_clock"],
            "choices": [
                {
                    "id": f"c_{nid}",
                    "label": "继续",
                    "next": next_id,
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                }
            ],
        }
        if "cg_path" in vis:
            node["cg_path"] = vis["cg_path"]
            node["cg_fit"] = vis["cg_fit"]
        elif "event_portraits" in vis:
            node["event_portraits"] = vis["event_portraits"]
        return node

    # Branch A-1: al3_a1_001 .. al3_a1_011 -> al3_012
    a1_seq = sections["intro"] + sections["a1"]
    for i, beat in enumerate(a1_seq, start=1):
        nid = f"al3_a1_{i:03d}"
        nxt = f"al3_a1_{i + 1:03d}" if i < len(a1_seq) else "al3_012"
        nodes.append(make_node(nid, beat, nxt))

    # Branch A-2: al3_a2_001 .. al3_a2_011 -> al3_012
    a2_seq = sections["intro"] + sections["a2"]
    for i, beat in enumerate(a2_seq, start=1):
        nid = f"al3_a2_{i:03d}"
        nxt = f"al3_a2_{i + 1:03d}" if i < len(a2_seq) else "al3_012"
        nodes.append(make_node(nid, beat, nxt))

    # Shared body: al3_012 .. al3_166 -> @end
    body_seq = sections["body"]
    for offset, beat in enumerate(body_seq):
        idx = 12 + offset
        nid = f"al3_{idx:03d}"
        nxt = f"al3_{idx + 1:03d}" if offset + 1 < len(body_seq) else "@end"
        nodes.append(make_node(nid, beat, nxt))

    assert len(nodes) == 177, f"Expected 177 total nodes, got {len(nodes)}"
    return nodes


def build_event(nodes: list[dict]) -> dict:
    return {
        "id": EVENT_ID,
        "actor_id": "doc_asuka",
        "title": "本院长不接受反驳哦",
        "teaser": "晴朗的周日午后，换上浅杏色针织开衫的明日香与坂口在街角咖啡馆相约，随后又神秘地邀他回一趟星见医院后院旧馆二楼的院史资料室，展示自己最珍视的私藏……",
        "chapter": 3,
        "location_id": "director_office",
        "background_id": "asuka_lv3_cafe_exterior_day",
        "outfit": "date_cardigan",
        "trigger_mode": "sunday",
        "consumes_sunday": True,
        "date_location_id": "cafe",
        "minutes": 0,
        "time_start": 540,
        "time_end": 1439,
        "priority": 200,
        "category": "rank_up",
        "target_level": 3,
        "benefit_id": "",
        "auto_start": False,
        "cinematic": True,
        "locks_saving": True,
        "hide_calendar_header": True,
        "completion_story_flags": ["asuka_lv3_complete"],
        "gallery": {
            "cg_id": "cg_asuka_lv3_vintage_cream_gown_mirror",
            "caption": "在旧馆二楼院史资料室四点钟的暖金斜阳下，换上 1970 年代奶白色厚棉布手术袍站在穿衣镜旁的明日香。",
            "path": CG_PATH,
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 40,
            "required_events": [
                "asuka_lv2_right_person_right_gown",
            ],
            "days_after_required_events": 3,
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "charm",
                    "minimum": 50,
                }
            ],
        },
        "start": "al3_a1_001",
        "opening_variants": {
            "first_sunday_date": "al3_a1_001",
            "prior_sunday_date": "al3_a2_001",
        },
        "nodes": nodes,
    }


def update_backgrounds() -> None:
    bg_path = ROOT / "data/backgrounds.json"
    bgs = json.loads(bg_path.read_text(encoding="utf-8"))
    by_id = {row["id"]: i for i, row in enumerate(bgs)}
    for entry in NEW_BACKGROUNDS:
        if entry["id"] in by_id:
            bgs[by_id[entry["id"]]] = entry
        else:
            bgs.append(entry)
    bg_path.write_text(json.dumps(bgs, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def update_asuka_bundle_profile_relationship() -> None:
    bundle_path = ROOT / "data/staff/doc_asuka/bundle.json"
    bundle = json.loads(bundle_path.read_text(encoding="utf-8"))
    extra = list(bundle.get("additional_character_event_files", []))
    for fname in ("lv2_events.json", "lv3_events.json"):
        if fname not in extra:
            extra.append(fname)
    bundle["additional_character_event_files"] = extra
    bundle_path.write_text(json.dumps(bundle, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    profile_path = ROOT / "data/staff/doc_asuka/profile.json"
    profile = json.loads(profile_path.read_text(encoding="utf-8"))
    outfits = profile["visuals"]["outfits"]
    for outfit_name in ("date_cardigan", "vintage_cream_gown"):
        if outfit_name not in outfits:
            outfits.append(outfit_name)
    for k, v in NEW_PORTRAITS.items():
        profile["visuals"]["portraits"][k] = v
    profile_path.write_text(json.dumps(profile, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    rel_path = ROOT / "data/staff/doc_asuka/relationship.json"
    rel = json.loads(rel_path.read_text(encoding="utf-8"))
    for slot in rel["rank_slots"]:
        if slot.get("target_level") == 3:
            slot["event_id"] = EVENT_ID
            slot["content_status"] = "authored"
            slot["benefit_id"] = ""
            slot["min_familiarity"] = 40
            slot["cooldown_days"] = 3
            slot["special_requirements"] = [
                {
                    "type": "player_attribute",
                    "attribute": "charm",
                    "minimum": 50,
                }
            ]
    rel_path.write_text(json.dumps(rel, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def update_localization(event: dict) -> None:
    en_data = json.loads(EN_TRANSLATION_PATH.read_text(encoding="utf-8"))
    assert en_data["event_id"] == EVENT_ID
    en_nodes: dict[str, str] = en_data["nodes"]
    en_speakers: dict[str, str] = en_data["speaker_labels"]
    en_bgs: dict[str, str] = en_data["backgrounds"]

    node_ids = {n["id"] for n in event["nodes"]}
    missing_en = sorted(node_ids - set(en_nodes.keys()))
    extra_en = sorted(set(en_nodes.keys()) - node_ids)
    assert not missing_en and not extra_en, f"EN node mismatch: missing={missing_en}, extra={extra_en}"

    zh_path = ROOT / "data/localization/zh_CN.json"
    en_path = ROOT / "data/localization/en.json"
    zh_json = json.loads(zh_path.read_text(encoding="utf-8"))
    en_json = json.loads(en_path.read_text(encoding="utf-8"))
    zh_strings = zh_json["strings"]
    en_strings = en_json["strings"]

    # Clean up any prior keys for this event first
    prefix = f"collections.character_events.{EVENT_ID}."
    for store in (zh_strings, en_strings):
        stale = [k for k in store if k.startswith(prefix)]
        for k in stale:
            del store[k]

    zh_strings[f"{prefix}title"] = event["title"]
    en_strings[f"{prefix}title"] = en_data["title"]
    zh_strings[f"{prefix}teaser"] = event["teaser"]
    en_strings[f"{prefix}teaser"] = en_data["teaser"]
    zh_strings[f"{prefix}gallery.caption"] = event["gallery"]["caption"]
    en_strings[f"{prefix}gallery.caption"] = en_data["gallery_caption"]

    for bg in NEW_BACKGROUNDS:
        bg_key = f"collections.backgrounds.{bg['id']}.label"
        zh_strings[bg_key] = bg["label"]
        en_strings[bg_key] = en_bgs[bg["id"]]

    zh_strings["ui.asuka.lv3.complete"] = "【城宮明日香 Relationship Lv3 达成】"
    en_strings["ui.asuka.lv3.complete"] = en_data["ui_complete"]

    for node in event["nodes"]:
        nid = node["id"]
        npfx = f"{prefix}nodes.{nid}."
        zh_strings[f"{npfx}text"] = node["text"]
        en_strings[f"{npfx}text"] = en_nodes[nid]

        spk_label = node.get("speaker_label", "")
        if spk_label:
            zh_strings[f"{npfx}speaker_label"] = spk_label
            en_strings[f"{npfx}speaker_label"] = en_speakers[spk_label]

        for ch in node["choices"]:
            cid = ch["id"]
            zh_strings[f"{npfx}choices.{cid}.label"] = ch["label"]
            en_strings[f"{npfx}choices.{cid}.label"] = "Continue"

    zh_path.write_text(json.dumps(zh_json, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    en_path.write_text(json.dumps(en_json, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def write_provenance(event: dict) -> None:
    cand_dir = ROOT / "research/generated_candidates/asuka_lv3_v1"
    raw_files = sorted(cand_dir.glob("*_raw.png"))
    runtime_portraits = sorted({v for v in NEW_PORTRAITS.values()})
    runtime_bgs = [bg["path"] for bg in NEW_BACKGROUNDS]

    gen_manifest = {
        "schema_version": 1,
        "pack_id": "asuka_lv3_v1",
        "actor_id": "doc_asuka",
        "event_id": EVENT_ID,
        "date": "2026-11-14",
        "identity_seeds": [
            "assets/characters/portrait_pack_v15/doc_asuka/white_coat/neutral.png",
            "assets/characters/spring_summer_casual_v1/doc_asuka/neutral.png",
            "assets/characters/asuka_lv1_v1/doc_asuka/scrubs/masked_smile.png",
        ],
        "matting_tool": "tools/portrait_matting.py (ZhengPeng7/BiRefNet-ToonOut offline local cache, --target-size 1024x1536 --resize-mode cover)",
        "raw_candidates": {
            p.name: sha256_of(p) for p in raw_files
        },
        "runtime_portraits": {
            rel: sha256_of(ROOT / rel) for rel in runtime_portraits
        },
        "runtime_cg": {
            CG_PATH: sha256_of(ROOT / CG_PATH),
        },
        "runtime_backgrounds": {
            rel: sha256_of(ROOT / rel) for rel in runtime_bgs
        },
    }
    (cand_dir / "generation.json").write_text(
        json.dumps(gen_manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    import_record = {
        "schema_version": 1,
        "import_id": "asuka_lv3_2026-11-14",
        "actor_id": "doc_asuka",
        "event_id": EVENT_ID,
        "target_level": 3,
        "manuscript_path": str(MANUSCRIPT_PATH.relative_to(ROOT)),
        "manuscript_sha256": sha256_of(MANUSCRIPT_PATH),
        "en_translation_path": str(EN_TRANSLATION_PATH.relative_to(ROOT)),
        "en_translation_sha256": sha256_of(EN_TRANSLATION_PATH),
        "output_event_file": "data/staff/doc_asuka/lv3_events.json",
        "node_count": len(event["nodes"]),
        "opening_variants": event["opening_variants"],
        "documented_text_alignments": [
            {
                "node_id": "al3_067",
                "reason": "Removed non-diegetic authorial art-staging parenthetical note so it is not rendered inside player-facing VN prose.",
                "original_substring": "（仅在身前展示比划，并未换穿）",
                "rendered_substring": "",
            },
            {
                "node_id": "al3_075",
                "reason": "Stripped Markdown bold asterisks around 奶白色 because Godot Label renders raw asterisks literally.",
                "original_substring": "**奶白色**",
                "rendered_substring": "奶白色",
            },
        ],
        "assets": gen_manifest["runtime_portraits"] | gen_manifest["runtime_cg"] | gen_manifest["runtime_backgrounds"],
    }
    import_path = ROOT / "research/imports/asuka_lv3_2026-11-14.json"
    import_path.write_text(json.dumps(import_record, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    sections = parse_manuscript()
    nodes = build_nodes(sections)
    event = build_event(nodes)

    lv3_events_path = ROOT / "data/staff/doc_asuka/lv3_events.json"
    lv3_events_path.write_text(json.dumps([event], ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    update_backgrounds()
    update_asuka_bundle_profile_relationship()
    update_localization(event)
    write_provenance(event)

    print(
        f"IMPORTED {EVENT_ID}: {len(nodes)} nodes "
        f"(A-1={len(sections['intro']) + len(sections['a1'])}, "
        f"A-2={len(sections['intro']) + len(sections['a2'])}, "
        f"shared_body={len(sections['body'])})"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
