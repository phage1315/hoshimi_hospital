#!/usr/bin/env python3
"""Deterministic importer for Shiori Fujisaki's canonical Relationship Lv2 event V1.0:
《唱片店里的藤崎诗织》 (shiori_lv2_record_shop).

Preserves the supplied Chinese manuscript verbatim (zero wording, punctuation, speaker,
or order changes), wires all 3 authored two-option RP choices and merge points, maps
Shiori's navy-headband white coat (`white_coat_navy`), off-duty trench coat + burgundy
velvet headband (`casual_coat`), and guest inpatient Yuko Asahina (`asahina_yuko/ward`)
across Scenes 1–6, registers the 2 new backgrounds in `data/backgrounds.json`, updates
`doc_shiori/bundle.json` and `relationship.json` (`target_level: 2`), and syncs
bilingual `zh_CN` / `en` localization entries.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts/HOSHIMI_SHIORI_LV2_RECORD_SHOP_V1_0.md"
OUTPUT = ROOT / "data/staff/doc_shiori/lv2_events.json"
BUNDLE = ROOT / "data/staff/doc_shiori/bundle.json"
RELATIONSHIP = ROOT / "data/staff/doc_shiori/relationship.json"
BACKGROUNDS = ROOT / "data/backgrounds.json"
TRANSLATIONS = ROOT / "research/translations/shiori_lv2_en.json"
LOCALIZATION_ZH = ROOT / "data/localization/zh_CN.json"
LOCALIZATION_EN = ROOT / "data/localization/en.json"

EVENT_ID = "shiori_lv2_record_shop"
PREFIX = "slv2"
CG_ROOT = "assets/events/shiori_lv2_v1"


def apply_cg_staging(nodes: list[dict]) -> None:
    """Approved SFW CGs; preserve authored dialogue and fallback portrait staging."""
    for node in nodes:
        beat = int(node["id"].rsplit("_", 1)[1])
        filename = ""
        if 162 <= beat <= 171:
            filename = "record_sharing.png"
        elif 188 <= beat <= 206:
            filename = "headband_pensive.png"
        elif 207 <= beat <= 208:
            filename = "headband_relieved.png"
        if filename:
            node["cg_path"] = f"{CG_ROOT}/{filename}"
            node["cg_fit"] = "cover"
            node["cg_portrait_overlay"] = False

SPEAKERS = {
    "坂口隆司": ("player", "Ryuji Sakaguchi"),
    "藤崎詩織": ("doc_shiori", "Shiori Fujisaki"),
    "朝日奈夕子": ("story_guest_asahina_yuko", "Yuko Asahina"),
    "唱片店店员": ("narrator", "Record Shop Clerk"),
}

SPEAKER_EN_MAP = {
    "旁白": "Narrator",
    "坂口隆司": "Ryuji Sakaguchi",
    "藤崎詩織": "Shiori Fujisaki",
    "朝日奈夕子": "Yuko Asahina",
    "唱片店店员": "Record Shop Clerk",
}

SHIORI_WHITE_COAT_NAVY = {
    "gentle_smile": "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/gentle_smile.png",
    "surprised": "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/surprised.png",
    "wry_smile": "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/wry_smile.png",
    "professional": "assets/characters/shiori_lv2_v1/doc_shiori/white_coat_navy/professional.png",
}

SHIORI_CASUAL_COAT = {
    "gentle_smile": "assets/characters/shiori_lv2_v1/doc_shiori/casual_coat/gentle_smile.png",
    "enthusiastic": "assets/characters/shiori_lv2_v1/doc_shiori/casual_coat/enthusiastic.png",
    "slightly_embarrassed": "assets/characters/shiori_lv2_v1/doc_shiori/casual_coat/slightly_embarrassed.png",
    "pensive_shy": "assets/characters/shiori_lv2_v1/doc_shiori/casual_coat/pensive_shy.png",
    "relieved_blush": "assets/characters/shiori_lv2_v1/doc_shiori/casual_coat/relieved_blush.png",
}

YUKO_WARD = {
    "cheerful_tease": "assets/characters/story_patients/asahina_yuko/ward/cheerful_tease.png",
    "sigh_troubled": "assets/characters/story_patients/asahina_yuko/ward/sigh_troubled.png",
    "shocked_panic": "assets/characters/story_patients/asahina_yuko/ward/shocked_panic.png",
    "nervous_blush": "assets/characters/story_patients/asahina_yuko/ward/nervous_blush.png",
    "relieved": "assets/characters/story_patients/asahina_yuko/ward/relieved.png",
}

NEW_BACKGROUNDS = [
    {
        "id": "shiori_lv2_classical_record_shop",
        "label": "榆树侧街·古典音乐唱片店",
        "en_label": "Elm Side Street · Classical Record Shop",
        "path": "assets/backgrounds/shiori_lv2_v1/classical_record_shop.png",
    },
    {
        "id": "shiori_lv2_station_plaza_night",
        "label": "车站前广场分岔口·夜",
        "en_label": "Station Plaza Fork · Night",
        "path": "assets/backgrounds/shiori_lv2_v1/station_plaza_night.png",
    },
]


def read_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def story_lines() -> list[str]:
    manuscript = SOURCE.read_text(encoding="utf-8")
    start_marker = "## Scene 1｜意想不到的住院患者"
    end_marker = "**【事件结束｜结算：藤崎詩織 Relationship 等级提升至 Lv2】**"
    if start_marker not in manuscript or end_marker not in manuscript:
        raise ValueError("Expected start/end markers not found in Shiori Lv2 manuscript")
    body = start_marker + manuscript.split(start_marker, 1)[1].split(end_marker, 1)[0]
    return body.splitlines()


def staging_for_beat(scene_no: int, scene_beat: int, branch_mode: str, spk: str, text: str) -> tuple[str, str, list[dict]]:
    """Returns (background_id, node_outfit_for_schema, event_portraits)."""
    # Scene 1: Ward afternoon (Yuko inpatient + Shiori white_coat_navy)
    if scene_no == 1:
        bg = "ward"
        outfit = "white_coat"
        if scene_beat == 1:
            return bg, outfit, []
        if scene_beat <= 5:
            # Yuko solo on bed sighing over phone camera before Shiori enters
            return bg, outfit, [
                {
                    "id": "story_guest_asahina_yuko",
                    "path": YUKO_WARD["sigh_troubled"],
                    "x": 985,
                    "bottom": 540,
                    "width": 410,
                    "height": 500,
                }
            ]
        # Shiori enters at scene_beat == 6
        if scene_beat in (6, 7):
            yuko_expr, shiori_expr = "sigh_troubled", "professional"
        elif 8 <= scene_beat <= 13:
            yuko_expr, shiori_expr = "shocked_panic", "surprised"
        elif 14 <= scene_beat <= 17:
            yuko_expr, shiori_expr = "cheerful_tease", "wry_smile"
        elif 18 <= scene_beat <= 21:
            yuko_expr = "cheerful_tease"
            shiori_expr = "gentle_smile" if scene_beat >= 20 else "wry_smile"
        elif 22 <= scene_beat <= 29:
            yuko_expr = "cheerful_tease" if scene_beat == 29 else "sigh_troubled"
            shiori_expr = "professional"
        elif 30 <= scene_beat <= 35:
            yuko_expr, shiori_expr = "sigh_troubled", "professional"
        elif 36 <= scene_beat <= 40:
            yuko_expr, shiori_expr = "shocked_panic", "professional"
        else:
            yuko_expr, shiori_expr = "shocked_panic", "wry_smile"

        return bg, outfit, [
            {
                "id": "story_guest_asahina_yuko",
                "path": YUKO_WARD[yuko_expr],
                "x": 460,
                "bottom": 540,
                "width": 400,
                "height": 495,
            },
            {
                "id": "doc_shiori",
                "path": SHIORI_WHITE_COAT_NAVY[shiori_expr],
                "x": 970,
                "bottom": 540,
                "width": 410,
                "height": 500,
            },
        ]

    # Scene 2: Ward joint consultation (Ryuji + Yuko + Shiori)
    if scene_no == 2:
        bg = "ward"
        outfit = "white_coat"
        if text.startswith("藤崎詩織最后确认了一眼床头监护记录"):
            return bg, outfit, []

        if branch_mode == "A":
            yuko_expr, shiori_expr = "cheerful_tease", "wry_smile"
        elif branch_mode == "B":
            yuko_expr, shiori_expr = "cheerful_tease", "gentle_smile"
        elif scene_beat >= 58:
            # Post-choice merge farewell in ward (slv2_113..115)
            yuko_expr, shiori_expr = "relieved", "gentle_smile"
        elif scene_beat <= 6:
            yuko_expr, shiori_expr = "nervous_blush", "gentle_smile"
        elif 7 <= scene_beat <= 10:
            yuko_expr, shiori_expr = "cheerful_tease", "wry_smile"
        elif 11 <= scene_beat <= 14:
            yuko_expr, shiori_expr = "nervous_blush", "wry_smile"
        elif 15 <= scene_beat <= 21:
            yuko_expr = "sigh_troubled"
            shiori_expr = "gentle_smile" if scene_beat in (20, 21) else "professional"
        elif 22 <= scene_beat <= 28:
            yuko_expr, shiori_expr = "nervous_blush", "wry_smile"
        elif 29 <= scene_beat <= 44:
            yuko_expr = "sigh_troubled" if scene_beat in (34, 35) else "nervous_blush"
            shiori_expr = "professional"
        elif scene_beat in (45, 46):
            # "所以……我今天不用开刀？" (slv2_088..089)
            yuko_expr, shiori_expr = "nervous_blush", "gentle_smile"
        elif 47 <= scene_beat <= 50:
            # "目前不需要..." -> "太好了……" (slv2_090..093)
            yuko_expr, shiori_expr = "relieved", "gentle_smile"
        elif 51 <= scene_beat <= 55:
            # "不过，接下来还有几项检查。" -> "……我就知道没这么容易结束。" -> no sweet drinks (slv2_094..098)
            yuko_expr, shiori_expr = "sigh_troubled", "gentle_smile"
        else:
            # Teasing Shiori right at Choice 1 (slv2_099..100)
            yuko_expr, shiori_expr = "cheerful_tease", "wry_smile"

        return bg, outfit, [
            {
                "id": "story_guest_asahina_yuko",
                "path": YUKO_WARD[yuko_expr],
                "x": 460,
                "bottom": 540,
                "width": 400,
                "height": 495,
            },
            {
                "id": "doc_shiori",
                "path": SHIORI_WHITE_COAT_NAVY[shiori_expr],
                "x": 970,
                "bottom": 540,
                "width": 410,
                "height": 500,
            },
        ]

    # Scene 3: Evening hospital ground-floor hallway invite
    if scene_no == 3:
        bg = "hallway"
        outfit = "white_coat"
        if scene_beat == 1:
            return bg, outfit, []
        if scene_beat == 8:
            shiori_expr = "professional"
        elif scene_beat == 12:
            shiori_expr = "surprised"
        elif scene_beat == 13:
            shiori_expr = "wry_smile"
        else:
            shiori_expr = "gentle_smile"
        return bg, outfit, [
            {
                "id": "doc_shiori",
                "path": SHIORI_WHITE_COAT_NAVY[shiori_expr],
                "x": 985,
                "bottom": 540,
                "width": 410,
                "height": 500,
            }
        ]

    # Scene 4: Hospital exit -> Elm side street -> Classical record shop
    if scene_no == 4:
        outfit = "casual"
        if scene_beat <= 3:
            return "hospital_courtyard_evening", outfit, [
                {
                    "id": "doc_shiori",
                    "path": SHIORI_CASUAL_COAT["gentle_smile"],
                    "x": 985,
                    "bottom": 540,
                    "width": 410,
                    "height": 500,
                }
            ]
        if scene_beat in (4, 5):
            return "serika_lv3_street_evening", outfit, []
        bg = "shiori_lv2_classical_record_shop"
        if scene_beat in (6, 7, 8):
            return bg, outfit, []

        if branch_mode == "A":
            shiori_expr = "enthusiastic" if spk == "藤崎詩織" or "欣喜" in text else "slightly_embarrassed"
        elif branch_mode == "B":
            shiori_expr = "relieved_blush" if spk == "藤崎詩織" or "脸颊微温" in text else "slightly_embarrassed"
        elif scene_beat >= 35:
            # Post-choice merge at shop counter (slv2_182..186)
            shiori_expr = "enthusiastic" if spk == "藤崎詩織" else "gentle_smile"
        elif 9 <= scene_beat <= 19:
            shiori_expr = "gentle_smile"
        elif 20 <= scene_beat <= 31:
            # Comparing Chopin Piano Concerto No. 1 versions with sparkling eyes (slv2_160..170)
            shiori_expr = "enthusiastic"
        else:
            # Realizing she leaned closer & talked non-stop (slv2_171..173, Choice 2 host)
            shiori_expr = "slightly_embarrassed"

        return bg, outfit, [
            {
                "id": "doc_shiori",
                "path": SHIORI_CASUAL_COAT[shiori_expr],
                "x": 985,
                "bottom": 540,
                "width": 410,
                "height": 500,
            }
        ]

    # Scene 5: Glass display case & burgundy velvet headband
    if scene_no == 5:
        bg = "shiori_lv2_classical_record_shop"
        outfit = "casual"
        if scene_beat <= 4:
            shiori_expr = "gentle_smile"
        elif 5 <= scene_beat <= 9:
            shiori_expr = "slightly_embarrassed"
        elif 10 <= scene_beat <= 18:
            shiori_expr = "pensive_shy"
        else:
            shiori_expr = "relieved_blush"
        return bg, outfit, [
            {
                "id": "doc_shiori",
                "path": SHIORI_CASUAL_COAT[shiori_expr],
                "x": 985,
                "bottom": 540,
                "width": 410,
                "height": 500,
            }
        ]

    # Scene 6: Station plaza fork farewell at night
    bg = "shiori_lv2_station_plaza_night"
    outfit = "casual"
    if scene_beat in (1, 2) or text.startswith("藤崎詩織抱着怀里的唱片纸袋转过身"):
        return bg, outfit, []
    if branch_mode == "A":
        shiori_expr = "enthusiastic" if spk == "藤崎詩織" or "月牙" in text else "relieved_blush"
    elif branch_mode == "B":
        shiori_expr = "gentle_smile" if spk == "藤崎詩織" or "笑意" in text else "relieved_blush"
    elif scene_beat <= 5:
        shiori_expr = "slightly_embarrassed"
    elif scene_beat in (6, 7):
        shiori_expr = "gentle_smile"
    elif scene_beat in (8, 9):
        shiori_expr = "pensive_shy"
    elif scene_beat == 10:
        shiori_expr = "relieved_blush"
    else:
        shiori_expr = "gentle_smile"
    return bg, outfit, [
        {
            "id": "doc_shiori",
            "path": SHIORI_CASUAL_COAT[shiori_expr],
            "x": 985,
            "bottom": 540,
            "width": 410,
            "height": 500,
        }
    ]


def parse_beats() -> list[dict]:
    nodes: list[dict] = []
    scene_no = 0
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

    def append(speaker_name: str, text: str) -> None:
        nonlocal awaiting_merge, scene_beat
        idx = len(nodes) + 1
        node_id = f"{PREFIX}_{idx:03d}"
        if mode == "main":
            scene_beat += 1

        bg_id, node_outfit, portraits = staging_for_beat(scene_no, scene_beat, mode, speaker_name, text)
        raw_actor_id, _ = SPEAKERS.get(speaker_name, ("doc_shiori", "Narrator"))
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
            return

        if awaiting_merge:
            connect(last["A"], node)
            connect(last["B"], node)
            last["A"] = None
            last["B"] = None
            awaiting_merge = False
        else:
            connect(last["main"], node)
        last["main"] = node

    for raw in story_lines():
        line = raw.strip()
        if not line:
            continue
        if line == "---":
            in_costume_header = False
            continue
        if line == "# 下半部分：古典音乐唱片店":
            continue

        m_scene = re.match(r"^## Scene ([1-6])｜", line)
        if m_scene:
            scene_no = int(m_scene.group(1))
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

        if re.match(r"^\*\*【选择 [123]：.+】\*\*$", line):
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
                raise ValueError(f"Unknown speaker in Shiori Lv2 manuscript: {spk!r}")
            append(spk, quote)
            continue

        if line.startswith(("#", "**", "- ", "*")):
            raise ValueError(f"Unexpected markdown/directive line in Shiori Lv2 manuscript: {line!r}")

        append("旁白", line)

    if awaiting_merge or last["A"] is not None or last["B"] is not None:
        raise ValueError("Unclosed branch in Shiori Lv2 manuscript")
    if sum(1 for n in nodes if len(n["choices"]) == 2) != 3:
        raise ValueError("Expected exactly 3 two-option RP choices")

    nodes[-1]["choices"] = [
        {
            "id": "finish_" + nodes[-1]["id"],
            "label": "结束",
            "next": "@end",
            "effects": {"affection": 3, "familiarity": 3},
            "flags": [
                "shiori_lv2_complete",
                "shiori_asahina_yuko_consulted",
                "shiori_classical_records_shared",
            ],
        }
    ]
    apply_cg_staging(nodes)
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
    beats = parse_beats()
    register_backgrounds()

    event = {
        "id": EVENT_ID,
        "actor_id": "doc_shiori",
        "completion_story_flags": [
            "shiori_lv2_complete",
            "shiori_asahina_yuko_consulted",
            "shiori_classical_records_shared",
        ],
        "title": "唱片店里的藤崎诗织",
        "teaser": "工作日下午的三楼内科观察病房里，藤崎詩織迎来了一位意想不到的高中旧同学患者；会诊与交班收尾后，傍晚榆树侧街的古典音乐唱片店正亮着暖黄的灯。",
        "chapter": 2,
        "location_id": "ward",
        "trigger_mode": "location",
        "background_id": "ward",
        "outfit": "white_coat",
        "minutes": 15,
        "time_start": 720,
        "time_end": 1020,
        "priority": 112,
        "category": "rank_up",
        "target_level": 2,
        "benefit_id": "",
        "auto_start": False,
        "cinematic": True,
        "locks_saving": True,
        "hide_calendar_header": True,
        "hide_completion_portrait": False,
        "completion_day_offset": 1,
        "completion_absolute_clock": 540,
        "gallery": {
            "cg_id": EVENT_ID,
            "caption": "午后病房的内外科联合会诊，以及傍晚榆树侧街古典音乐唱片店里的私人时光。",
            "path": f"{CG_ROOT}/record_sharing.png",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 25,
            "required_events": ["shiori_lv1_doctors_worry"],
            "days_after_required_events": 3,
            "special_requirements": [],
        },
        "start": beats[0]["id"],
        "nodes": beats,
    }
    write_json(OUTPUT, [event])

    bundle_doc: dict = read_json(BUNDLE)  # type: ignore[assignment]
    extra_files: list[str] = list(bundle_doc.get("additional_character_event_files", []))
    if "lv2_events.json" not in extra_files:
        extra_files.append("lv2_events.json")
        bundle_doc["additional_character_event_files"] = extra_files
        write_json(BUNDLE, bundle_doc)

    rel_doc: dict = read_json(RELATIONSHIP)  # type: ignore[assignment]
    for slot in rel_doc.get("rank_slots", []):
        if int(slot.get("target_level", -1)) == 2:
            slot["event_id"] = EVENT_ID
            slot["content_status"] = "authored"
            slot["benefit_id"] = ""
            slot["min_familiarity"] = 25
            slot["cooldown_days"] = 3
            slot["special_requirements"] = []
    write_json(RELATIONSHIP, rel_doc)

    if not TRANSLATIONS.exists():
        dump = {
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
                for b in beats
            ]
        }
        Path("/private/tmp/shiori_lv2_zh_beats.json").write_text(
            json.dumps(dump, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        print(f"Parsed {len(beats)} verbatim beats; wrote ZH dump to /private/tmp/shiori_lv2_zh_beats.json")
        return

    translations: dict = read_json(TRANSLATIONS)  # type: ignore[assignment]
    en_nodes: dict[str, str] = translations["nodes"]
    en_choices: dict[str, str] = translations["choices"]

    zh_doc: dict = read_json(LOCALIZATION_ZH)  # type: ignore[assignment]
    en_doc: dict = read_json(LOCALIZATION_EN)  # type: ignore[assignment]
    zh_strings: dict[str, str] = zh_doc["strings"]
    en_strings: dict[str, str] = en_doc["strings"]

    prefix_event = f"collections.character_events.{EVENT_ID}"
    for target in (zh_strings, en_strings):
        stale = [k for k in target if k.startswith(prefix_event + ".")]
        for k in stale:
            del target[k]

    for bg in NEW_BACKGROUNDS:
        bg_key = f"collections.backgrounds.{bg['id']}.label"
        zh_strings[bg_key] = bg["label"]
        en_strings[bg_key] = bg["en_label"]

    zh_strings[f"{prefix_event}.title"] = event["title"]
    zh_strings[f"{prefix_event}.teaser"] = event["teaser"]
    zh_strings[f"{prefix_event}.gallery.caption"] = event["gallery"]["caption"]

    en_strings[f"{prefix_event}.title"] = str(translations["title"])
    en_strings[f"{prefix_event}.teaser"] = str(translations["teaser"])
    en_strings[f"{prefix_event}.gallery.caption"] = str(translations["gallery_caption"])

    for node in beats:
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
    print(f"Imported {EVENT_ID}: {len(beats)} beats, 3 two-option RP choices, zh_CN + en synced.")


if __name__ == "__main__":
    main()
