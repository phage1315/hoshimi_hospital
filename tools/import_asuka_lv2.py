#!/usr/bin/env python3
"""Import Asuka Shiromiya (`doc_asuka`) Relationship Lv2:
《合适的人，合适的手术袍》 (The Right Person, the Right Gown).

Updates:
- data/staff/doc_asuka/bundle.json (registers additional_character_event_files: ["lv2_events.json"])
- data/staff/doc_asuka/profile.json (registers outfit "sample_gown" + 3 1024x1536 RGBA portraits)
- data/staff/doc_asuka/relationship.json (marks target_level 2 slot authored -> asuka_lv2_right_person_right_gown)
- data/staff/doc_asuka/lv2_events.json (single-session 3-scene VN, 216 nodes incl. 2 RP choice markers)
- data/localization/zh_CN.json & data/localization/en.json
- research/generated_candidates/asuka_lv2_portraits_v1/generation.json
- research/imports/asuka_lv2_2026-11-13.json
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_ASUKA_LV2_RIGHT_PERSON_RIGHT_GOWN_V1_1.md"
EN_TRANSLATION_PATH = ROOT / "research/translations/asuka_lv2_en.json"

EVENT_ID = "asuka_lv2_right_person_right_gown"

SAMPLE_GOWN_PATHS = {
    "sample_gown/neutral": "assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/smile.png",
    "sample_gown/smile": "assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/smile.png",
    "sample_gown/proud": "assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/proud.png",
    "sample_gown/reluctant_cuff": "assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/reluctant_cuff.png",
}

CAST_PORTRAITS = {
    ("doc_asuka", "white_coat/neutral"): "assets/characters/portrait_pack_v15/doc_asuka/white_coat/neutral.png",
    ("doc_asuka", "white_coat/worried"): "assets/characters/portrait_pack_v15/doc_asuka/white_coat/worried.png",
    ("doc_asuka", "sample_gown/smile"): "assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/smile.png",
    ("doc_asuka", "sample_gown/proud"): "assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/proud.png",
    ("doc_asuka", "sample_gown/reluctant_cuff"): "assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/reluctant_cuff.png",
    ("doc_emiko", "white_coat/neutral"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/neutral.png",
    ("doc_emiko", "white_coat/serious"): "assets/characters/portrait_pack_v14/doc_emiko/white_coat/serious.png",
    ("doc_artoria", "white_coat/neutral"): "assets/characters/portrait_pack_v16/doc_artoria/white_coat/neutral.png",
    ("doc_aoi", "white_coat/neutral"): "assets/characters/third_party_preview/c1058-neutral-ai.png",
    ("doc_aoi", "white_coat/serious"): "assets/characters/portrait_pack_v1/doc_aoi/white_coat/serious.png",
    ("doc_aoi", "white_coat/smile"): "assets/characters/third_party_preview/c1058-smile-ai.png",
    ("doc_maki", "interview/neutral"): "assets/characters/maki_original_style_v1/doc_maki/interview/neutral.png",
    ("doc_maki", "interview/focused"): "assets/characters/maki_original_style_v1/doc_maki/interview/focused.png",
    ("doc_maki", "interview/worried"): "assets/characters/maki_original_style_v1/doc_maki/interview/worried.png",
    ("doc_maki", "interview/relieved"): "assets/characters/maki_original_style_v1/doc_maki/interview/relieved.png",
    ("nurse_hiroko", "uniform/neutral"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/neutral.png",
    ("nurse_hiroko", "uniform/serious"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/serious.png",
    ("nurse_hiroko", "uniform/smile"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/smile.png",
    ("nurse_hiroko", "uniform/closed_eye_smile"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/closed_eye_smile.png",
}

SPEAKER_MAP = {
    "城宮明日香": ("actor", "doc_asuka", "城宮明日香"),
    "坂口隆司": ("player", "doc_asuka", "坂口隆司"),
    "御堂江美子": ("actor", "doc_emiko", "御堂江美子"),
    "阿尔托莉雅·潘德拉贡": ("actor", "doc_artoria", "阿尔托莉雅·潘德拉贡"),
    "神宮寺成美": ("actor", "doc_aoi", "神宮寺成美"),
    "相泽麻纪": ("actor", "doc_maki", "相泽麻纪"),
    "杉村弘子": ("actor", "nurse_hiroko", "杉村弘子"),
}

UNBOLD_PREFIX_SPEAKER = [
    ("坂口隆司", ("player", "doc_asuka", "坂口隆司")),
    ("御堂江美子", ("actor", "doc_emiko", "御堂江美子")),
    ("阿尔托莉雅", ("actor", "doc_artoria", "阿尔托莉雅·潘德拉贡")),
    ("神宮寺成美", ("actor", "doc_aoi", "神宮寺成美")),
    ("城宮明日香", ("actor", "doc_asuka", "城宮明日香")),
    ("明日香", ("actor", "doc_asuka", "城宮明日香")),
    ("她低头看了看袖口", ("actor", "doc_asuka", "城宮明日香")),
]


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def solo(actor_id: str, key: str) -> list[dict]:
    path = CAST_PORTRAITS[(actor_id, key)]
    return [
        {
            "id": actor_id,
            "path": path,
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


def stage_portraits_for_beat(num: int) -> tuple[str, str, list[dict] | None]:
    """Return (node_outfit, node_expression, event_portraits_or_None)."""
    # Scene A: 1..49
    if num in (1, 2, 3):
        return ("white_coat", "neutral", None)
    if 4 <= num <= 8:
        return ("white_coat", "neutral", solo("doc_asuka", "white_coat/neutral"))
    if num in (9, 10):
        return ("white_coat", "smile", duo("doc_aoi", "white_coat/smile", "doc_asuka", "white_coat/neutral"))
    if 11 <= num <= 13:
        return ("white_coat", "neutral", solo("doc_asuka", "white_coat/neutral"))
    if 14 <= num <= 20:
        return ("white_coat", "serious", duo("doc_emiko", "white_coat/serious", "doc_asuka", "white_coat/neutral"))
    if num == 21:
        return ("white_coat", "worried", duo("doc_emiko", "white_coat/serious", "doc_asuka", "white_coat/worried"))
    if 22 <= num <= 24:
        return ("white_coat", "serious", duo("doc_emiko", "white_coat/serious", "doc_asuka", "white_coat/worried"))
    if num == 25:
        return ("white_coat", "worried", solo("doc_asuka", "white_coat/worried"))
    if num == 26:
        return ("white_coat", "neutral", solo("doc_asuka", "white_coat/neutral"))
    if 27 <= num <= 35:
        return ("white_coat", "neutral", duo("doc_artoria", "white_coat/neutral", "doc_asuka", "white_coat/neutral"))
    if 36 <= num <= 39:
        return ("white_coat", "smile", duo("doc_aoi", "white_coat/smile", "doc_asuka", "white_coat/neutral"))
    if 40 <= num <= 49:
        return ("white_coat", "neutral", solo("doc_asuka", "white_coat/neutral"))

    # Scene B: 50..147
    if num in (50, 51):
        return ("white_coat", "neutral", solo("doc_asuka", "white_coat/neutral"))
    if 52 <= num <= 55:
        return ("interview", "neutral", solo("doc_maki", "interview/neutral"))
    if num in (56, 57):
        return ("white_coat", "neutral", duo("doc_asuka", "white_coat/neutral", "doc_maki", "interview/neutral"))
    if 58 <= num <= 61:
        return ("interview", "focused", duo("doc_asuka", "white_coat/neutral", "doc_maki", "interview/focused"))
    if 62 <= num <= 69:
        return ("white_coat", "serious", duo("doc_emiko", "white_coat/serious", "doc_maki", "interview/focused"))
    if num in (70, 71):
        return ("interview", "worried", duo("doc_emiko", "white_coat/neutral", "doc_maki", "interview/worried"))
    if 72 <= num <= 78:
        return ("white_coat", "neutral", duo("doc_artoria", "white_coat/neutral", "doc_maki", "interview/focused"))
    if 79 <= num <= 83:
        return ("white_coat", "serious", duo("doc_aoi", "white_coat/serious", "doc_maki", "interview/neutral"))
    if 84 <= num <= 87:
        return ("interview", "worried", duo("doc_aoi", "white_coat/serious", "doc_maki", "interview/worried"))
    if 88 <= num <= 90:
        return ("interview", "focused", duo("doc_aoi", "white_coat/neutral", "doc_maki", "interview/focused"))
    if num in (91, 92):
        return ("white_coat", "smile", duo("doc_aoi", "white_coat/smile", "doc_maki", "interview/focused"))
    if num in (93, 94):
        return ("white_coat", "neutral", solo("doc_asuka", "white_coat/neutral"))
    if num in (95, 96):
        return ("interview", "neutral", solo("doc_maki", "interview/neutral"))
    if num in (97, 98):
        return ("interview", "focused", solo("doc_maki", "interview/focused"))
    if num == 99:
        return ("interview", "relieved", solo("doc_maki", "interview/relieved"))
    if 100 <= num <= 103:
        return ("white_coat", "neutral", duo("doc_asuka", "white_coat/neutral", "doc_maki", "interview/neutral"))
    if 104 <= num <= 107:
        return ("interview", "focused", duo("doc_asuka", "white_coat/neutral", "doc_maki", "interview/focused"))
    if 108 <= num <= 111:
        return ("interview", "neutral", duo("doc_asuka", "white_coat/neutral", "doc_maki", "interview/neutral"))

    # Panel closed-door deliberation (Maki outside): 112..140
    if num == 112:
        return ("white_coat", "neutral", None)
    if num in (113, 114):
        return ("white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
    if num in (115, 116):
        return ("white_coat", "neutral", solo("doc_artoria", "white_coat/neutral"))
    if num in (117, 118):
        return ("white_coat", "smile", solo("doc_aoi", "white_coat/smile"))
    if num in (119, 120):
        return ("white_coat", "neutral", solo("doc_asuka", "white_coat/neutral"))
    if num in (121, 122):
        return ("white_coat", "neutral", solo("doc_asuka", "white_coat/neutral"))
    if num in (123, 124):
        return ("white_coat", "neutral", solo("doc_emiko", "white_coat/neutral"))
    if num in (125, 126):
        return ("white_coat", "neutral", solo("doc_artoria", "white_coat/neutral"))
    if num in (127, 128):
        return ("white_coat", "neutral", solo("doc_asuka", "white_coat/neutral"))
    if num in (129, 130):
        return ("white_coat", "smile", solo("doc_aoi", "white_coat/smile"))
    if num in (131, 132):
        return ("white_coat", "serious", solo("doc_emiko", "white_coat/serious"))
    if 133 <= num <= 137:
        return ("white_coat", "neutral", solo("doc_asuka", "white_coat/neutral"))
    if num == 138:
        return ("white_coat", "neutral", solo("doc_artoria", "white_coat/neutral"))
    if num in (139, 140):
        return ("white_coat", "neutral", solo("doc_emiko", "white_coat/neutral"))

    # Maki invited back in & accepts offer: 141..147
    if num in (141, 142):
        return ("white_coat", "neutral", duo("doc_asuka", "white_coat/neutral", "doc_maki", "interview/neutral"))
    if 143 <= num <= 147:
        return ("interview", "relieved", duo("doc_asuka", "white_coat/neutral", "doc_maki", "interview/relieved"))

    # Scene C: 148..214
    if num == 148:
        return ("white_coat", "neutral", None)
    if 149 <= num <= 152:
        return ("white_coat", "neutral", solo("doc_asuka", "white_coat/neutral"))
    if 153 <= num <= 165:
        return ("sample_gown", "smile", solo("doc_asuka", "sample_gown/smile"))
    if num in (166, 167):
        return ("sample_gown", "proud", solo("doc_asuka", "sample_gown/proud"))
    if num in (168, 169):
        return ("sample_gown", "smile", solo("doc_asuka", "sample_gown/smile"))
    if num in (170, 171):
        return ("sample_gown", "proud", solo("doc_asuka", "sample_gown/proud"))
    if 172 <= num <= 175:
        return ("sample_gown", "reluctant_cuff", solo("doc_asuka", "sample_gown/reluctant_cuff"))
    if 176 <= num <= 178:
        return ("sample_gown", "smile", solo("doc_asuka", "sample_gown/smile"))
    if 179 <= num <= 182:
        return ("sample_gown", "smile", duo("doc_asuka", "sample_gown/smile", "nurse_hiroko", "uniform/smile"))
    if 183 <= num <= 187:
        return ("uniform", "serious", duo("doc_asuka", "sample_gown/smile", "nurse_hiroko", "uniform/serious"))
    if 188 <= num <= 191:
        return ("sample_gown", "reluctant_cuff", duo("doc_asuka", "sample_gown/reluctant_cuff", "nurse_hiroko", "uniform/neutral"))
    if num in (192, 193):
        return ("sample_gown", "proud", duo("doc_asuka", "sample_gown/proud", "nurse_hiroko", "uniform/smile"))
    if 194 <= num <= 197:
        return ("uniform", "closed_eye_smile", duo("doc_asuka", "sample_gown/smile", "nurse_hiroko", "uniform/closed_eye_smile"))
    if num == 198:
        return ("white_coat", "neutral", None)
    if 199 <= num <= 213:
        return ("white_coat", "neutral", solo("doc_asuka", "white_coat/neutral"))
    if num == 214:
        return ("white_coat", "neutral", None)
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
        return n_idx, f"al2_{n_idx:03d}"

    for raw in lines[28:490]:
        s = raw.strip()
        if s.startswith("## Scene A"):
            in_scene_header = True
            scene = "A"
            section = "main"
            continue
        if s.startswith("## Scene B"):
            in_scene_header = True
            scene = "B"
            section = "main"
            continue
        if s.startswith("## Scene C"):
            in_scene_header = True
            scene = "C"
            section = "main"
            continue
        if in_scene_header:
            if s == "---":
                in_scene_header = False
            continue
        if not s or s == "---" or s.startswith("*选项说明"):
            continue
        if s.startswith("**【选择 1"):
            section = "choice_b1_prompt"
            continue
        if s.startswith("**【选择 2"):
            section = "choice_c1_prompt"
            continue
        if s.startswith("- **选项 A："):
            label = re.match(r"^- \*\*选项 A：(「.*」)\*\*$", s).group(1)
            key = "choice_al2_b1_a" if "b1" in section else "choice_al2_c1_a"
            choice_labels_zh[key] = label
            continue
        if s.startswith("- **选项 B："):
            label = re.match(r"^- \*\*选项 B：(「.*」)\*\*$", s).group(1)
            key = "choice_al2_b1_b" if "b1" in section else "choice_al2_c1_b"
            choice_labels_zh[key] = label
            continue
        if s == "**【选择选项 A 后的分支演出】**":
            section = "b1_a" if scene == "B" else "c1_a"
            continue
        if s == "**【选择选项 B 后的分支演出】**":
            section = "b1_b" if scene == "B" else "c1_b"
            continue
        if s.startswith("**【分支汇合点"):
            section = "main"
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
            beats.append((num1, nid1, scene, section, "narrator", "doc_asuka", "旁白", f"{sp}{act}："))
            num2, nid2 = next_id()
            beats.append((num2, nid2, scene, section, role, aid, slabel, q))
            continue

        m3 = re.match(r"^([^「]+?)：(「.*」)$", s)
        if m3:
            pref, q = m3.groups()
            matched = next(v for k, v in UNBOLD_PREFIX_SPEAKER if pref.startswith(k))
            role, aid, slabel = matched
            num1, nid1 = next_id()
            beats.append((num1, nid1, scene, section, "narrator", "doc_asuka", "旁白", f"{pref}："))
            num2, nid2 = next_id()
            beats.append((num2, nid2, scene, section, role, aid, slabel, q))
            continue

        num, nid = next_id()
        beats.append((num, nid, scene, section, "narrator", "doc_asuka", "旁白", s))

    assert len(beats) == 214, f"Expected 214 beats, got {len(beats)}"
    assert len(choice_labels_zh) == 4, f"Expected 4 choices, got {len(choice_labels_zh)}"
    return beats, choice_labels_zh


def build_nodes(beats: list[tuple], choice_labels_zh: dict[str, str]) -> list[dict]:
    # Explicit next-node overrides for branching & rejoins
    next_override = {
        "al2_120": "al2_choice_b1",
        "al2_126": "al2_133",  # End of B1-A -> hiring decision
        "al2_132": "al2_133",  # End of B1-B -> hiring decision
        "al2_163": "al2_choice_c1",
        "al2_167": "al2_172",  # End of C1-A -> scrub nurse realization
        "al2_171": "al2_172",  # End of C1-B -> scrub nurse realization
        "al2_214": "@end",
    }

    nodes: list[dict] = []
    for i, (num, nid, _scene, _section, role, aid, slabel, text_zh) in enumerate(beats):
        outfit, expr, portraits = stage_portraits_for_beat(num)
        is_last = nid == "al2_214"
        next_target = next_override.get(nid, beats[i + 1][1] if not is_last else "@end")
        choice_id = "finish_al2_214" if is_last else f"continue_{nid}"
        choice_label = "结束" if is_last else "继续"
        choice_effects = {"affection": 2, "familiarity": 0} if is_last else {"affection": 0, "familiarity": 0}
        choice_flags = (
            [
                "asuka_lv2_complete",
                "maki_aizawa_offer_accepted",
                "asuka_festival_gown_showcase_seed",
            ]
            if is_last
            else []
        )
        node: dict = {
            "id": nid,
            "presentation": "authored",
            "speaker": role,
            "actor_id": aid,
            "speaker_label": slabel,
            "text": text_zh,
            "expression": expr,
            "outfit": outfit,
            "background_id": "conference_room",
            "hide_portrait": portraits is None,
            "choices": [
                {
                    "id": choice_id,
                    "label": choice_label,
                    "next": next_target,
                    "effects": choice_effects,
                    "flags": choice_flags,
                }
            ],
        }
        if portraits is not None:
            node["event_portraits"] = portraits
        nodes.append(node)

        if nid == "al2_120":
            nodes.append(
                {
                    "id": "al2_choice_b1",
                    "presentation": "choice",
                    "speaker": "narrator",
                    "actor_id": "doc_asuka",
                    "text": "",
                    "expression": "neutral",
                    "outfit": "white_coat",
                    "background_id": "conference_room",
                    "hide_portrait": False,
                    "event_portraits": solo("doc_asuka", "white_coat/neutral"),
                    "choices": [
                        {
                            "id": "choice_al2_b1_a",
                            "label": choice_labels_zh["choice_al2_b1_a"],
                            "next": "al2_121",
                            "effects": {"affection": 0, "familiarity": 0},
                            "flags": [],
                        },
                        {
                            "id": "choice_al2_b1_b",
                            "label": choice_labels_zh["choice_al2_b1_b"],
                            "next": "al2_127",
                            "effects": {"affection": 0, "familiarity": 0},
                            "flags": [],
                        },
                    ],
                }
            )
        elif nid == "al2_163":
            nodes.append(
                {
                    "id": "al2_choice_c1",
                    "presentation": "choice",
                    "speaker": "narrator",
                    "actor_id": "doc_asuka",
                    "text": "",
                    "expression": "smile",
                    "outfit": "sample_gown",
                    "background_id": "conference_room",
                    "hide_portrait": False,
                    "event_portraits": solo("doc_asuka", "sample_gown/smile"),
                    "choices": [
                        {
                            "id": "choice_al2_c1_a",
                            "label": choice_labels_zh["choice_al2_c1_a"],
                            "next": "al2_164",
                            "effects": {"affection": 0, "familiarity": 0},
                            "flags": [],
                        },
                        {
                            "id": "choice_al2_c1_b",
                            "label": choice_labels_zh["choice_al2_c1_b"],
                            "next": "al2_168",
                            "effects": {"affection": 0, "familiarity": 0},
                            "flags": [],
                        },
                    ],
                }
            )

    assert len(nodes) == 216, f"Expected 216 nodes, got {len(nodes)}"
    return nodes


def main() -> None:
    for (_aid, _key), rel_path in CAST_PORTRAITS.items():
        full = ROOT / rel_path
        if not full.is_file():
            raise FileNotFoundError(f"Missing portrait file: {rel_path}")

    en_data = json.loads(EN_TRANSLATION_PATH.read_text(encoding="utf-8"))
    beats, choice_labels_zh = parse_manuscript()
    nodes = build_nodes(beats, choice_labels_zh)

    # 1. Update data/staff/doc_asuka/bundle.json
    bundle_path = ROOT / "data/staff/doc_asuka/bundle.json"
    bundle = json.loads(bundle_path.read_text(encoding="utf-8"))
    extra_files = list(bundle.get("additional_character_event_files", []))
    if "lv2_events.json" not in extra_files:
        extra_files.append("lv2_events.json")
    bundle["additional_character_event_files"] = extra_files
    bundle_path.write_text(json.dumps(bundle, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # 2. Update data/staff/doc_asuka/profile.json
    profile_path = ROOT / "data/staff/doc_asuka/profile.json"
    profile = json.loads(profile_path.read_text(encoding="utf-8"))
    outfits: list[str] = profile["visuals"]["outfits"]
    if "sample_gown" not in outfits:
        outfits.append("sample_gown")
    portraits: dict = profile["visuals"]["portraits"]
    for k, v in SAMPLE_GOWN_PATHS.items():
        portraits[k] = v
    profile_path.write_text(json.dumps(profile, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # 3. Update data/staff/doc_asuka/relationship.json
    rel_path = ROOT / "data/staff/doc_asuka/relationship.json"
    relationship = json.loads(rel_path.read_text(encoding="utf-8"))
    for slot in relationship.get("rank_slots", []):
        if slot.get("target_level") == 2:
            slot["event_id"] = EVENT_ID
            slot["content_status"] = "authored"
            slot["benefit_id"] = ""
            slot["min_familiarity"] = 25
            slot["cooldown_days"] = 3
            slot["special_requirements"] = [
                {
                    "type": "player_attribute",
                    "attribute": "charm",
                    "minimum": 25,
                }
            ]
    rel_path.write_text(json.dumps(relationship, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # 4. Write data/staff/doc_asuka/lv2_events.json
    title_zh = "合适的人，合适的手术袍"
    teaser_zh = "新人外科医生招聘面试开始前二十五分钟，城宮明日香拉着外科骨干试穿改良无菌袍样衣，随后主持相泽麻纪的五人评审面试，并在会后亲自试穿晴空雾蓝色样衣、请器械护士杉村弘子补齐实操把关。"
    caption_zh = "行政小会议室里，城宮明日香主持相泽麻纪的外科面试，并亲自试穿晴空雾蓝色的四号手术袍样衣。"

    event_def = {
        "id": EVENT_ID,
        "actor_id": "doc_asuka",
        "title": title_zh,
        "teaser": teaser_zh,
        "chapter": 2,
        "location_id": "director_office",
        "trigger_mode": "location",
        "background_id": "conference_room",
        "outfit": "white_coat",
        "minutes": 125,
        "time_start": 720,
        "time_end": 960,
        "priority": 140,
        "category": "rank_up",
        "target_level": 2,
        "benefit_id": "",
        "completion_story_flags": [
            "asuka_lv2_complete",
            "maki_aizawa_offer_accepted",
        ],
        "auto_start": True,
        "cinematic": True,
        "locks_saving": True,
        "gallery": {
            "cg_id": EVENT_ID,
            "caption": caption_zh,
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 25,
            "required_events": [
                "asuka_lv1_director_surgeon_postop",
            ],
            "days_after_required_events": 3,
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "charm",
                    "minimum": 25,
                }
            ],
        },
        "start": "al2_001",
        "nodes": nodes,
    }

    lv2_events_path = ROOT / "data/staff/doc_asuka/lv2_events.json"
    lv2_events_path.write_text(json.dumps([event_def], ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # 5. Update data/localization/zh_CN.json & en.json
    zh_path = ROOT / "data/localization/zh_CN.json"
    en_path = ROOT / "data/localization/en.json"
    zh_loc = json.loads(zh_path.read_text(encoding="utf-8"))
    en_loc = json.loads(en_path.read_text(encoding="utf-8"))
    zh_strings: dict = zh_loc["strings"]
    en_strings: dict = en_loc["strings"]

    prefix = f"collections.character_events.{EVENT_ID}"
    for d in (zh_strings, en_strings):
        stale = [k for k in d if k.startswith(prefix + ".")]
        for k in stale:
            del d[k]

    zh_strings[f"{prefix}.title"] = title_zh
    zh_strings[f"{prefix}.teaser"] = teaser_zh
    zh_strings[f"{prefix}.gallery.caption"] = caption_zh

    en_strings[f"{prefix}.title"] = en_data["title"]
    en_strings[f"{prefix}.teaser"] = en_data["teaser"]
    en_strings[f"{prefix}.gallery.caption"] = en_data["gallery_caption"]

    speakers_en: dict[str, str] = en_data["speakers"]
    nodes_en: dict[str, str] = en_data["nodes"]
    choices_en: dict[str, str] = en_data["choices"]

    for node in nodes:
        nid = node["id"]
        npref = f"{prefix}.nodes.{nid}"
        if node["presentation"] != "choice":
            zh_strings[f"{npref}.text"] = node["text"]
            zh_strings[f"{npref}.speaker_label"] = node["speaker_label"]
            if nid not in nodes_en:
                raise KeyError(f"Missing English translation for {nid}")
            en_strings[f"{npref}.text"] = nodes_en[nid]
            en_strings[f"{npref}.speaker_label"] = speakers_en[node["speaker_label"]]
        for ch in node["choices"]:
            cid = ch["id"]
            zh_strings[f"{npref}.choices.{cid}.label"] = ch["label"]
            if ch["label"] == "继续":
                en_strings[f"{npref}.choices.{cid}.label"] = "Continue"
            else:
                if cid not in choices_en:
                    raise KeyError(f"Missing English choice translation for {cid}")
                en_strings[f"{npref}.choices.{cid}.label"] = choices_en[cid]

    zh_path.write_text(json.dumps(zh_loc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    en_path.write_text(json.dumps(en_loc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # 6. Write candidate generation manifest & import record
    cand_dir = ROOT / "research/generated_candidates/asuka_lv2_portraits_v1"
    cand_dir.mkdir(parents=True, exist_ok=True)
    gen_manifest = {
        "schema_version": 1,
        "character_id": "doc_asuka",
        "event_id": EVENT_ID,
        "date": "2026-11-13",
        "outfit": "sample_gown",
        "approved_base_candidate": "asuka_sample_gown_v2_waist_tie_raw.jpg",
        "matting_pipeline": "tools/portrait_matting.py (offline BiRefNet-ToonOut, 1024x1536 RGBA cover)",
        "assets": {
            slot: {
                "runtime_path": path_str,
                "sha256": sha256_of(ROOT / path_str),
            }
            for slot, path_str in SAMPLE_GOWN_PATHS.items()
            if slot != "sample_gown/neutral"
        },
    }
    (cand_dir / "generation.json").write_text(json.dumps(gen_manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    import_record = {
        "schema_version": 1,
        "event_id": EVENT_ID,
        "actor_id": "doc_asuka",
        "maki_actor_id": "doc_maki",
        "date": "2026-11-13",
        "manuscript_path": str(MANUSCRIPT_PATH.relative_to(ROOT)),
        "manuscript_sha256": sha256_of(MANUSCRIPT_PATH),
        "translation_path": str(EN_TRANSLATION_PATH.relative_to(ROOT)),
        "translation_sha256": sha256_of(EN_TRANSLATION_PATH),
        "node_count": len(nodes),
        "authored_beat_count": len(beats),
        "choice_marker_count": 2,
        "sample_gown_portraits": gen_manifest["assets"],
        "maki_interview_portraits": {
            key: {
                "runtime_path": CAST_PORTRAITS[("doc_maki", key)],
                "sha256": sha256_of(ROOT / CAST_PORTRAITS[("doc_maki", key)]),
            }
            for key in ("interview/neutral", "interview/focused", "interview/worried", "interview/relieved")
        },
    }
    import_path = ROOT / "research/imports/asuka_lv2_2026-11-13.json"
    import_path.write_text(json.dumps(import_record, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Imported {EVENT_ID}: {len(nodes)} nodes ({len(beats)} beats + 2 choice markers).")


if __name__ == "__main__":
    main()
