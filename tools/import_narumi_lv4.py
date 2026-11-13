#!/usr/bin/env python3
"""Import Narumi Jinguji's canonical personal Lv4 V1.3 event.

The importer preserves the supplied Chinese manuscript, separates inline stage
directions from spoken quotations, and requires an explicit English entry for
every visible node and authored choice.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOWNLOAD = Path("/Users/ningye/Downloads/HOSHIMI_JINGUJI_NARUMI_LV4_AFTER_WORK_V1_3.md")
SOURCE = ROOT / "research/source_scripts/HOSHIMI_JINGUJI_NARUMI_LV4_AFTER_WORK_V1_3.md"
OUTPUT = ROOT / "data/staff/doc_aoi/lv4_events.json"
TRANSLATIONS = ROOT / "research/translations/narumi_lv4_en.json"
LOCALIZATION = ROOT / "data/localization/en.json"
EVENT_ID = "narumi_lv4_after_work"
PREFIX = "nar4"
CG_PATH = "assets/events/character_events/narumi_ren/narumi_lv4_rooftop_coffee.png"
CG_NODE_IDS = {f"nar4_{number:03d}" for number in range(119, 131)}

SPEAKERS = {
    "坂口隆司": ("player", "Ryuji Sakaguchi"),
    "神宮寺成美": ("doc_aoi", "Narumi Jinguji"),
}

SCENE_ART = {
    1: ("date_jazz_bar", "casual"),
    2: ("date_hotel", "casual"),
    3: ("narumi_office", "white_coat"),
    4: ("rooftop", "white_coat"),
}

PORTRAITS = {
    "white_coat": "assets/characters/portrait_pack_v1/doc_aoi/white_coat/serious.png",
}


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def manuscript_text() -> str:
    source = DOWNLOAD if DOWNLOAD.exists() else SOURCE
    manuscript = source.read_text(encoding="utf-8")
    SOURCE.parent.mkdir(parents=True, exist_ok=True)
    SOURCE.write_text(manuscript, encoding="utf-8")
    return manuscript


def story_lines() -> list[str]:
    manuscript = manuscript_text()
    marker = "## 【Scene 1"
    return (marker + manuscript.split(marker, 1)[1].split("## Revision Log", 1)[0]).splitlines()


def parse_beats() -> list[dict]:
    nodes: list[dict] = []
    scene = 1
    mode = "main"
    last: dict[str, dict | None] = {"main": None, "A": None, "B": None, "C1": None, "C2": None}
    choice_host: dict | None = None
    choice_labels: list[str] = []
    conditional_host: dict | None = None
    awaiting_merge = False
    awaiting_conditional_merge = False

    def link(previous: dict | None, current: dict) -> None:
        if previous is not None and not previous["choices"]:
            previous["choices"] = [{
                "id": "continue_" + previous["id"],
                "label": "继续",
                "next": current["id"],
                "effects": {"affection": 0, "familiarity": 0},
                "flags": [],
            }]

    def append(speaker_name: str, text: str) -> None:
        nonlocal awaiting_merge, awaiting_conditional_merge
        actor_id = SPEAKERS.get(speaker_name, ("", "Narrator"))[0]
        node_id = f"{PREFIX}_{len(nodes) + 1:03d}"
        background_id, outfit = SCENE_ART[scene]
        node = {
            "id": node_id,
            "presentation": "authored",
            "speaker": "narrator" if speaker_name == "旁白" else ("player" if actor_id == "player" else "actor"),
            "actor_id": actor_id,
            "speaker_label": speaker_name,
            "text": text.replace("**", ""),
            "expression": "serious" if outfit == "white_coat" else "neutral",
            "outfit": outfit,
            "background_id": background_id,
            "hide_portrait": True,
            "choices": [],
        }
        if actor_id == "doc_aoi" and outfit == "white_coat":
            node["hide_portrait"] = False
            node["event_portraits"] = [{
                "id": actor_id,
                "path": PORTRAITS[outfit],
                "x": 1030,
                "bottom": 540,
                "width": 410,
                "height": 500,
            }]
        nodes.append(node)
        if mode in ("A", "B"):
            link(last[mode], node)
            last[mode] = node
            slot = 0 if mode == "A" else 1
            if choice_host is None or len(choice_host["choices"]) != 2:
                raise ValueError(f"Branch without choice at {node_id}")
            if not choice_host["choices"][slot]["next"]:
                choice_host["choices"][slot]["next"] = node_id
            return
        if mode in ("C1", "C2"):
            link(last[mode], node)
            last[mode] = node
            return
        if awaiting_conditional_merge:
            link(last["C1"], node)
            link(last["C2"], node)
            last["C1"] = last["C2"] = None
            awaiting_conditional_merge = False
        elif awaiting_merge:
            link(last["A"], node)
            link(last["B"], node)
            last["A"] = last["B"] = None
            awaiting_merge = False
        else:
            link(last["main"], node)
        last["main"] = node

    for raw in story_lines():
        line = raw.strip()
        if not line:
            continue
        heading = re.fullmatch(r"## 【Scene (\d+) — .+】", line)
        if heading:
            scene = int(heading.group(1))
            mode = "main"
            continue
        if line.startswith(("**【场景】**", "**【时间】**", "**【在场角色】**", "**【服装状态】**", "*性质：")):
            continue
        if line in {"**【玩家可见正文】**", "**【酒店客房内】**", "**【事后温存】**", "**【神宮寺成美 个人 Relationship Lv4 事件结束】**"}:
            continue
        if line.startswith("**【条件分支："):
            conditional_host = last["main"]
            if conditional_host is None:
                raise ValueError("Conditional branch has no host")
            mode = "conditional"
            continue
        if line.startswith("- **【状态 1："):
            mode, last["C1"] = "C1", None
            continue
        if line.startswith("- **【状态 2："):
            mode, last["C2"] = "C2", None
            continue
        if line == "---" and mode == "C2":
            if conditional_host is None or last["C1"] is None or last["C2"] is None:
                raise ValueError("Incomplete relationship-state branch")
            conditional_host["choices"] = [{
                "id": "continue_" + conditional_host["id"],
                "label": "继续",
                "next": last["C1"]["id"],
                "next_if_relationship_level": {
                    "actor_id": "nurse_haru",
                    "minimum": 4,
                    "next": last["C2"]["id"],
                },
                "effects": {"affection": 0, "familiarity": 0},
                "flags": [],
            }]
            last["main"] = None
            mode = "main"
            awaiting_conditional_merge = True
            continue
        if line == "---":
            continue
        if line.startswith("**【选择："):
            if last["main"] is None:
                raise ValueError("Choice has no host")
            choice_host = last["main"]
            last["main"] = None
            choice_labels = []
            mode = "choice"
            continue
        option = re.fullmatch(r"- \*\*选项 [AB]：(.*)\*\*", line)
        if option:
            choice_labels.append(option.group(1))
            if len(choice_labels) == 2:
                choice_host["choices"] = [
                    {"id": f"choice_{choice_host['id']}_a", "label": choice_labels[0], "next": "", "effects": {"affection": 0, "familiarity": 0}, "flags": []},
                    {"id": f"choice_{choice_host['id']}_b", "label": choice_labels[1], "next": "", "effects": {"affection": 0, "familiarity": 0}, "flags": []},
                ]
            continue
        if line == "**【分支 A】**":
            mode, last["A"] = "A", None
            continue
        if line == "**【分支 B】**":
            mode, last["B"] = "B", None
            continue
        if line == "**【主线汇合】**":
            mode, awaiting_merge = "main", True
            continue

        exact = re.fullmatch(r"([^：]+)：(「.*」)", line)
        if exact and exact.group(1) in SPEAKERS:
            append(exact.group(1), exact.group(2))
            continue
        if exact:
            inline_speaker = next((name for name in SPEAKERS if exact.group(1).startswith(name)), "")
            if inline_speaker:
                stage = exact.group(1)[len(inline_speaker):]
                if stage:
                    append("旁白", inline_speaker + stage)
                append(inline_speaker, exact.group(2))
                continue
        append("旁白", line)

    if awaiting_merge or awaiting_conditional_merge or any(last[key] is not None for key in ("A", "B", "C1", "C2")):
        raise ValueError("Unclosed branch")
    if sum(1 for node in nodes if len(node["choices"]) == 2) != 2:
        raise ValueError("Expected exactly two authored choices")
    nodes[-1]["choices"] = [{
        "id": "finish_" + nodes[-1]["id"],
        "label": "结束",
        "next": "@end",
        "effects": {"affection": 0, "familiarity": 0},
        "flags": [],
    }]
    return nodes


def main() -> None:
    beats = parse_beats()
    available_node_ids = {str(beat["id"]) for beat in beats}
    if not CG_NODE_IDS.issubset(available_node_ids):
        raise ValueError(f"CG window drifted from source beats: {sorted(CG_NODE_IDS - available_node_ids)}")
    for beat in beats:
        if str(beat["id"]) in CG_NODE_IDS:
            beat["cg_path"] = CG_PATH
            beat["cg_fit"] = "cover"
            # Full-screen CG rendering suppresses portraits before the regular
            # portrait branch; keep this false to satisfy the event art schema.
            beat["hide_portrait"] = False
    if not TRANSLATIONS.exists():
        template: dict[str, str] = {beat["id"]: "" for beat in beats}
        for beat in beats:
            for choice in beat["choices"]:
                if len(beat["choices"]) == 2:
                    template[choice["id"]] = ""
        write_json(TRANSLATIONS, template)
        print(f"wrote translation template: {len(beats)} beats")
        return

    translations = read_json(TRANSLATIONS)
    event = {
        "id": EVENT_ID,
        "actor_id": "doc_aoi",
        "completion_story_flags": ["narumi_lv4_complete"],
        "title": "下班以后",
        "teaser": "褪去白大褂后的成年人狩猎与真情",
        "chapter": 4,
        "location_id": "shared_doctors_office",
        "trigger_mode": "sunday",
        "consumes_sunday": True,
        "date_location_id": "jazz_bar",
        "background_id": "date_jazz_bar",
        "outfit": "casual",
        "minutes": 0,
        "time_start": 1140,
        "time_end": 1200,
        "priority": 125,
        "category": "rank_up",
        "target_level": 4,
        "benefit_id": "unlock_intimacy_events",
        "cinematic": True,
        "locks_saving": True,
        "hide_calendar_header": True,
        "hide_completion_portrait": True,
        "completion_day_offset": 1,
        "completion_absolute_clock": 780,
        "completion_display_clock": 780,
        "gallery": {"cg_id": EVENT_ID, "caption": "下班以后", "path": CG_PATH, "show_on_complete": True},
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 55,
            "required_events": ["narumi_ren_shared_lv3_settled_accounts"],
            "days_after_required_events": 3,
            "special_requirements": [
                {"type": "player_attribute", "attribute": "skill", "minimum": 65},
                {"type": "player_attribute", "attribute": "leadership", "minimum": 50},
                {"type": "player_attribute", "attribute": "presence", "minimum": 15},
                {
                    "type": "progress_counter",
                    "actor_id": "doc_aoi",
                    "counter_id": "completed_sunday_dates",
                    "minimum": 1,
                },
            ],
        },
        "start": beats[0]["id"],
        "nodes": beats,
    }
    write_json(OUTPUT, [event])

    localized = read_json(LOCALIZATION)
    strings = localized["strings"]
    prefix = f"collections.character_events.{EVENT_ID}"
    for key in list(strings):
        if key.startswith(prefix + "."):
            del strings[key]
    strings[prefix + ".title"] = "After Work"
    strings[prefix + ".teaser"] = "An adult pursuit—and genuine affection—after the white coat comes off."
    strings[prefix + ".gallery.caption"] = "After Work"
    for beat in beats:
        english = str(translations.get(beat["id"], "")).strip()
        if not english:
            raise ValueError(f"Missing English translation: {beat['id']} {beat['text']}")
        stem = f"{prefix}.nodes.{beat['id']}"
        strings[stem + ".text"] = english
        strings[stem + ".speaker_label"] = "Narrator" if beat["speaker_label"] == "旁白" else SPEAKERS[beat["speaker_label"]][1]
        for choice in beat["choices"]:
            key = stem + ".choices." + choice["id"] + ".label"
            if len(beat["choices"]) == 2:
                translated = str(translations.get(choice["id"], "")).strip()
                if not translated:
                    raise ValueError(f"Missing English choice: {choice['id']}")
                strings[key] = translated
            else:
                strings[key] = "Finish" if choice["next"] == "@end" else "Continue"
    write_json(LOCALIZATION, localized)
    print(f"imported {EVENT_ID}: {len(beats)} bilingual beats")


if __name__ == "__main__":
    main()
