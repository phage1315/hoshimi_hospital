#!/usr/bin/env python3
"""Deterministic importer for Shiori Fujisaki's canonical Relationship Lv1 event V1.2:
《藤崎医生的烦恼》 (shiori_lv1_doctors_worry).

Preserves the supplied Chinese manuscript verbatim, maps every authorial expression cue
(`【藤崎詩織：...】`) to Shiori's subtle Way-A white_coat expressions, registers `lv1_events.json`
in `data/staff/doc_shiori/bundle.json` and `relationship.json` (`target_level: 1`), and syncs
bilingual `zh_CN` / `en` localization entries.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts/HOSHIMI_SHIORI_LV1_DOCTORS_WORRY_V1_2.md"
OUTPUT = ROOT / "data/staff/doc_shiori/lv1_events.json"
BUNDLE = ROOT / "data/staff/doc_shiori/bundle.json"
RELATIONSHIP = ROOT / "data/staff/doc_shiori/relationship.json"
TRANSLATIONS = ROOT / "research/translations/shiori_lv1_en.json"
LOCALIZATION_ZH = ROOT / "data/localization/zh_CN.json"
LOCALIZATION_EN = ROOT / "data/localization/en.json"

EVENT_ID = "shiori_lv1_doctors_worry"
PREFIX = "slv1"

SPEAKERS = {
    "坂口隆司": ("player", "Ryuji Sakaguchi"),
    "藤崎詩織": ("doc_shiori", "Shiori Fujisaki"),
}

SHIORI_PORTRAITS = {
    "neutral": "assets/characters/portrait_pack_v17/doc_shiori/white_coat/neutral.png",
    "wry_smile": "assets/characters/portrait_pack_v17/doc_shiori/white_coat/wry_smile.png",
    "gentle_smile": "assets/characters/portrait_pack_v17/doc_shiori/white_coat/gentle_smile.png",
    "shy_reproach": "assets/characters/portrait_pack_v17/doc_shiori/white_coat/shy_reproach.png",
    "professional": "assets/characters/portrait_pack_v17/doc_shiori/white_coat/professional.png",
    "pensive": "assets/characters/portrait_pack_v17/doc_shiori/white_coat/pensive.png",
}

# Exact mapping of all 23 authorial `【藤崎詩織：...】` cues in V1.2 manuscript
CUE_TO_EXPRESSION = {
    "无奈又有些想笑的表情": "wry_smile",
    "微怔回神 → 温和微笑": "neutral",
    "略微不好意思": "shy_reproach",
    "无奈轻叹": "pensive",
    "忍俊不禁": "wry_smile",
    "略带嗔怪的温柔笑意": "shy_reproach",
    "舒展微笑": "gentle_smile",
    "平静 → 淡淡的无奈": "pensive",
    "从容自信的职业神态": "professional",
    "浅笑": "neutral",
    "略微柔和感慨": "pensive",
    "轻微自嘲但温和": "wry_smile",
    "微讶抬眼 → 真心舒展的浅笑": "gentle_smile",
    "知性专注": "professional",
    "柔和怀念": "neutral",
    "明朗温和的微笑": "gentle_smile",
    "无奈又怀念的浅笑": "wry_smile",
    "微微摇头，带着几分未消的感慨": "pensive",
    "眼睛微亮 → 含笑颔首": "gentle_smile",
    "微讶 → 略微不好意思": "shy_reproach",
    "好奇微怔": "professional",
    "微愣半秒 → 柔和放松的笑容": "neutral",
    "温暖明朗的微笑": "gentle_smile",
}


def read_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def story_lines() -> list[str]:
    manuscript = SOURCE.read_text(encoding="utf-8")
    start_marker = "## S1｜诊察券背面的签名请求"
    end_marker = "**【事件结束｜结算：藤崎詩織 Relationship 等级提升至 Lv1】**"
    if start_marker not in manuscript or end_marker not in manuscript:
        raise ValueError("Expected start/end markers not found in Shiori Lv1 manuscript")
    body = start_marker + manuscript.split(start_marker, 1)[1].split(end_marker, 1)[0]
    return body.splitlines()


def parse_beats() -> list[dict]:
    nodes: list[dict] = []
    current_expr = "wry_smile"
    seen_cues: list[str] = []

    def append(speaker_name: str, text: str, expr: str) -> None:
        idx = len(nodes) + 1
        node_id = f"{PREFIX}_{idx:03d}"
        actor_id, _ = SPEAKERS.get(speaker_name, ("doc_shiori", "Narrator"))
        speaker_kind = (
            "narrator"
            if speaker_name == "旁白"
            else ("player" if actor_id == "player" else "actor")
        )
        node: dict = {
            "id": node_id,
            "presentation": "authored",
            "speaker": speaker_kind,
            "actor_id": "doc_shiori",
            "speaker_label": speaker_name,
            "text": text,
            "expression": expr,
            "outfit": "white_coat",
            "background_id": "staff_lounge",
            "hide_portrait": False,
            "choices": [],
        }
        nodes.append(node)

    for raw in story_lines():
        line = raw.strip()
        if not line or line == "---":
            continue
        if line.startswith("## S"):
            continue
        if line.startswith("**【场景】**") or line.startswith("**【时间】**") or line.startswith("**【服装】**"):
            continue

        # Narrator / stage cue block wrapped in *(...)*
        if line.startswith("*(") and line.endswith(")*"):
            inner = line[2:-2].strip()
            cue_match = re.match(r"^【藤崎詩織：([^】]+)】(.*)$", inner)
            if cue_match:
                cue = cue_match.group(1).strip()
                if cue not in CUE_TO_EXPRESSION:
                    raise ValueError(f"Unmapped Shiori expression cue: {cue!r}")
                current_expr = CUE_TO_EXPRESSION[cue]
                seen_cues.append(cue)
                rest = cue_match.group(2).strip()
                if rest:
                    append("旁白", rest, current_expr)
                continue
            if "【" in inner or "】" in inner:
                raise ValueError(f"Unexpected bracketed tag in narrator line: {line}")
            append("旁白", inner, current_expr)
            continue

        # Dialogue line **说话人**：「...」
        dlg_match = re.fullmatch(r"\*\*([^*]+)\*\*：(「.*」)", line)
        if dlg_match:
            spk = dlg_match.group(1).strip()
            quote = dlg_match.group(2).strip()
            if spk not in SPEAKERS:
                raise ValueError(f"Unknown speaker in Shiori Lv1 manuscript: {spk!r}")
            append(spk, quote, current_expr)
            continue

        raise ValueError(f"Unparsed line in Shiori Lv1 manuscript: {line!r}")

    if len(seen_cues) != len(CUE_TO_EXPRESSION):
        missing = set(CUE_TO_EXPRESSION) - set(seen_cues)
        if missing:
            raise ValueError(f"Unused expression cues in CUE_TO_EXPRESSION: {sorted(missing)}")

    if len(nodes) < 50:
        raise ValueError(f"Unexpectedly few beats parsed: {len(nodes)}")

    # Hide portrait on Beat 1 (Ryuji pushing open lounge door before focusing on Shiori's expression)
    # and on the final beat (after Shiori pushes open the door and walks out into the corridor)
    no_portrait_indices = {1, len(nodes)}
    for idx, node in enumerate(nodes, start=1):
        if idx in no_portrait_indices:
            node["hide_portrait"] = True
        else:
            node["hide_portrait"] = False
            node["event_portraits"] = [
                {
                    "id": "doc_shiori",
                    "path": SHIORI_PORTRAITS[node["expression"]],
                    "x": 985,
                    "bottom": 540,
                    "width": 410,
                    "height": 500,
                }
            ]

    for i in range(len(nodes) - 1):
        nodes[i]["choices"] = [
            {
                "id": "continue_" + nodes[i]["id"],
                "label": "继续",
                "next": nodes[i + 1]["id"],
                "effects": {"affection": 0, "familiarity": 0},
                "flags": [],
            }
        ]

    nodes[-1]["choices"] = [
        {
            "id": "finish_" + nodes[-1]["id"],
            "label": "结束",
            "next": "@end",
            "effects": {"affection": 2, "familiarity": 2},
            "flags": ["shiori_lv1_himoo_mentioned"],
        }
    ]
    return nodes


def main() -> None:
    beats = parse_beats()
    if not TRANSLATIONS.exists():
        template: dict[str, str] = {beat["id"]: beat["text"] for beat in beats}
        write_json(TRANSLATIONS, template)
        print(f"Wrote ZH reference template with {len(beats)} beats to {TRANSLATIONS} — replace with EN!")
        return

    translations: dict[str, str] = read_json(TRANSLATIONS)  # type: ignore[assignment]
    event = {
        "id": EVENT_ID,
        "actor_id": "doc_shiori",
        "title": "藤崎医生的烦恼",
        "teaser": "午后门诊刚告一段落，职员休息室靠窗的小圆桌旁，藤崎詩織正捧着热红茶露出一丝微妙的哭笑不得。",
        "chapter": 1,
        "location_id": "lounge",
        "trigger_mode": "location",
        "background_id": "staff_lounge",
        "outfit": "white_coat",
        "minutes": 15,
        "time_start": 540,
        "time_end": 1020,
        "priority": 92,
        "category": "bond",
        "target_level": 1,
        "benefit_id": "",
        "auto_start": False,
        "cinematic": True,
        "locks_saving": True,
        "hide_calendar_header": False,
        "hide_completion_portrait": False,
        "gallery": {
            "cg_id": EVENT_ID,
            "caption": "在午后休息室听藤崎詩織聊起门诊的插曲与旧同学。",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 10,
            "required_events": [],
            "special_requirements": [],
        },
        "start": beats[0]["id"],
        "nodes": beats,
    }
    write_json(OUTPUT, [event])

    bundle_doc: dict = read_json(BUNDLE)  # type: ignore[assignment]
    extra_files: list[str] = list(bundle_doc.get("additional_character_event_files", []))
    if "lv1_events.json" not in extra_files:
        extra_files.append("lv1_events.json")
    bundle_doc["additional_character_event_files"] = extra_files
    write_json(BUNDLE, bundle_doc)

    relation_doc: dict = read_json(RELATIONSHIP)  # type: ignore[assignment]
    for slot in relation_doc.get("rank_slots", []):
        if int(slot.get("target_level", 0)) == 1:
            slot["event_id"] = EVENT_ID
            slot["content_status"] = "authored"
    write_json(RELATIONSHIP, relation_doc)

    for locale, loc_path in [("zh_CN", LOCALIZATION_ZH), ("en", LOCALIZATION_EN)]:
        loc_doc: dict = read_json(loc_path)  # type: ignore[assignment]
        strings: dict[str, str] = loc_doc["strings"]

        prefix = f"collections.character_events.{EVENT_ID}"
        for key in list(strings):
            if key.startswith(prefix + "."):
                del strings[key]

        if locale == "en":
            strings[prefix + ".title"] = "Dr. Fujisaki's Troubles"
            strings[prefix + ".teaser"] = (
                "Afternoon clinic hours have just wrapped up. At a small window table in the staff lounge, "
                "Shiori Fujisaki cradles a cup of hot black tea with a faint, wry smile."
            )
            strings[prefix + ".gallery.caption"] = (
                "Listening to Shiori Fujisaki talk about clinic anecdotes and an old classmate in the afternoon lounge."
            )
        else:
            strings[prefix + ".title"] = event["title"]
            strings[prefix + ".teaser"] = event["teaser"]
            strings[prefix + ".gallery.caption"] = event["gallery"]["caption"]

        for beat in beats:
            stem = f"{prefix}.nodes.{beat['id']}"
            if locale == "en":
                english = str(translations.get(beat["id"], "")).strip()
                if not english:
                    raise ValueError(f"Missing English translation for {beat['id']}: {beat['text']}")
                strings[stem + ".text"] = english
                strings[stem + ".speaker_label"] = (
                    "Narrator" if beat["speaker_label"] == "旁白" else SPEAKERS[beat["speaker_label"]][1]
                )
            else:
                strings[stem + ".text"] = beat["text"]
                strings[stem + ".speaker_label"] = beat["speaker_label"]

            for choice in beat["choices"]:
                ckey = f"{stem}.choices.{choice['id']}.label"
                if locale == "en":
                    strings[ckey] = "Finish" if choice["next"] == "@end" else "Continue"
                else:
                    strings[ckey] = choice["label"]

        write_json(loc_path, loc_doc)

    print(f"Imported {EVENT_ID}: {len(beats)} bilingual beats")


if __name__ == "__main__":
    main()
