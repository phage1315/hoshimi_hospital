#!/usr/bin/env python3
"""Import the two V1.1 literary manuscripts as exact, fixed VN beats."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts"
TRANSLATIONS = ROOT / "research/translations/ren_narumi_lv1_en.json"
LOCALIZATION = ROOT / "data/localization/en.json"
EVENTS = (
    {
        "id": "ren_lv1_night_ward_1",
        "actor": "nurse_haru",
        "source": "HOSHIMI_NANASE_REN_LV1_YAKIN_BYOUTOU_1_V1_1.md",
        "output": "data/staff/nurse_haru/lv1_events.json",
        "title": "夜勤病栋（1）",
        "title_en": "Night Shift Ward (1)",
        "prefix": "ren1",
        "location": "station",
        "trigger": "after_work",
        "time_start": 960,
        "time_end": 1019,
        "minutes": 100,
        "backgrounds": ("nurses_station", "nurses_station", "ward_night", "nurses_station", "nurses_station"),
        "outfits": ("uniform",) * 5,
        "speaker_ids": {"恋": "nurse_haru", "坂口": "player", "患者": "patient_generic"},
        "speaker_en": {"恋": "Ren Nanase", "坂口": "Ryuji Sakaguchi", "患者": "Patient"},
    },
    {
        "id": "narumi_lv1_beyond_the_resume",
        "actor": "doc_aoi",
        "source": "HOSHIMI_JINGUJI_NARUMI_LV1_RIREKI_NO_SOTO_V1_1.md",
        "output": "data/staff/doc_aoi/lv1_events.json",
        "title": "履历之外",
        "title_en": "Beyond the Résumé",
        "prefix": "nar1",
        "location": "shared_doctors_office",
        "trigger": "location",
        "time_start": 780,
        "time_end": 1020,
        "minutes": 120,
        "backgrounds": ("shared_doctors_office", "shared_doctors_office", "operating_room", "shared_doctors_office"),
        "outfits": ("white_coat", "white_coat", "sterile", "white_coat"),
        "speaker_ids": {"成美": "doc_aoi", "坂口": "player", "巡回护士": "circulating_nurse"},
        "speaker_en": {"成美": "Narumi Jinguji", "坂口": "Ryuji Sakaguchi", "巡回护士": "Circulating Nurse"},
    },
)


def source_beats(spec: dict) -> list[dict]:
    manuscript = (SOURCE / spec["source"]).read_text(encoding="utf-8")
    story = "## Scene 1" + manuscript.split("## Scene 1", 1)[1].split("## Revision Log", 1)[0]
    beats: list[dict] = []
    scene = 1
    for raw in story.splitlines():
        line = raw.strip()
        if not line:
            continue
        heading = re.fullmatch(r"## Scene (\d+) — (.+)", line)
        if heading:
            scene = int(heading.group(1))
            continue
        if line.startswith("**【") and line.endswith("】**"):
            line = line[2:-2]
        match = re.match(r"^([^：]+)：(「.*」)$", line)
        speaker = match.group(1) if match else "旁白"
        if match and speaker not in spec["speaker_ids"]:
            raise ValueError(f"Unknown speaker in {spec['source']}: {speaker}")
        if scene > len(spec["backgrounds"]):
            raise ValueError(f"Missing scene art mapping: {spec['source']} scene {scene}")
        beats.append({
            "id": f"{spec['prefix']}_{len(beats) + 1:03d}",
            "presentation": "authored",
            "speaker": "narrator" if speaker == "旁白" else ("player" if speaker == "坂口" else "actor"),
            "actor_id": spec["speaker_ids"].get(speaker, spec["actor"]),
            "speaker_label": speaker,
            "text": line if not match else match.group(2),
            "expression": "neutral",
            "outfit": spec["outfits"][scene - 1],
            "background_id": spec["backgrounds"][scene - 1],
            "scene_tint": "#40536d" if spec["id"] == "ren_lv1_night_ward_1" and spec["backgrounds"][scene - 1] == "nurses_station" else "",
            "hide_portrait": speaker not in spec["speaker_ids"] or speaker == "坂口" or spec["speaker_ids"].get(speaker) != spec["actor"],
        })
    if not beats:
        raise ValueError(f"No story beats: {spec['source']}")
    return beats


def main() -> None:
    translations: dict = json.loads(TRANSLATIONS.read_text(encoding="utf-8"))
    localized: dict = json.loads(LOCALIZATION.read_text(encoding="utf-8"))
    strings: dict = localized["strings"]
    for spec in EVENTS:
        beats = source_beats(spec)
        translated = translations.get(spec["id"], [])
        if len(translated) != len(beats) or any(not isinstance(line, str) or not line.strip() for line in translated):
            raise ValueError(f"English line alignment: {spec['id']} {len(translated)}/{len(beats)}")
        for index, beat in enumerate(beats):
            choice_id = ("finish_" if index + 1 == len(beats) else "continue_") + beat["id"]
            beat["choices"] = [{
                "id": choice_id, "label": "结束" if index + 1 == len(beats) else "继续",
                "next": "@end" if index + 1 == len(beats) else beats[index + 1]["id"],
                "effects": {"affection": 0, "familiarity": 0}, "flags": [],
            }]
        event = {
            "id": spec["id"], "actor_id": spec["actor"], "title": spec["title"],
            "teaser": spec["title"], "chapter": 1, "location_id": spec["location"],
            "trigger_mode": spec["trigger"], "background_id": spec["backgrounds"][0],
            "outfit": spec["outfits"][0], "minutes": spec["minutes"],
            "time_start": spec["time_start"], "time_end": spec["time_end"],
            "priority": 95, "category": "bond", "target_level": 1,
            "benefit_id": "", "cinematic": True, "auto_start": spec["trigger"] == "after_work",
            # The night-shift manuscript carries its own 22:40 and 00:20 scene
            # captions. The compressed workday ledger must not contradict them.
            "hide_calendar_header": spec["id"] == "ren_lv1_night_ward_1",
            "gallery": {"cg_id": spec["id"], "caption": spec["title"], "path": "", "show_on_complete": False},
            "conditions": {"min_day": 1, "min_affection": 0, "min_familiarity": 10,
                           "required_events": [], "special_requirements": [], "days_after_required_events": 0},
            "start": beats[0]["id"], "nodes": beats,
        }
        out = ROOT / spec["output"]
        out.write_text(json.dumps([event], ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        prefix = f"collections.character_events.{spec['id']}"
        for key in list(strings):
            if key.startswith(prefix + "."):
                del strings[key]
        strings[prefix + ".title"] = spec["title_en"]
        strings[prefix + ".teaser"] = spec["title_en"]
        strings[prefix + ".gallery.caption"] = spec["title_en"]
        for beat, english in zip(beats, translated):
            stem = prefix + ".nodes." + beat["id"]
            strings[stem + ".text"] = english
            chinese_label = beat["speaker_label"]
            strings[stem + ".speaker_label"] = ("Narrator" if chinese_label == "旁白" else spec["speaker_en"][chinese_label])
            choice = beat["choices"][0]
            strings[stem + ".choices." + choice["id"] + ".label"] = "Finish" if choice["next"] == "@end" else "Continue"
        print(spec["id"], len(beats), "source beats")
    LOCALIZATION.write_text(json.dumps(localized, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
