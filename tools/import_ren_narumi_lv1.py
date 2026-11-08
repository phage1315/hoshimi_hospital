#!/usr/bin/env python3
"""Import the revised Ren V2.2 and Narumi V2.1 fixed-VN manuscripts."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts"
LEGACY_TRANSLATIONS = ROOT / "research/translations/ren_narumi_lv1_v1_1_zh_en.json"
REVISED_TRANSLATIONS = ROOT / "research/translations/ren_narumi_lv1_revised_overrides_en.json"
LOCALIZATION = ROOT / "data/localization/en.json"

EVENTS = (
    {
        "id": "ren_lv1_night_ward_1", "actor": "nurse_haru",
        "source": "HOSHIMI_NANASE_REN_LV1_YAKIN_BYOUTOU_1_V2_2.md",
        "output": "data/staff/nurse_haru/lv1_events.json", "title": "夜勤病栋（1）",
        "title_en": "Night Shift Ward (1)", "prefix": "ren1", "location": "station",
        "trigger": "after_work", "time_start": 960, "time_end": 1019, "minutes": 100,
        "backgrounds": ("nurses_station", "nurses_station", "ward_night", "nurses_station", "nurses_station"),
        "outfits": ("uniform",) * 5,
        "speaker_ids": {"七瀬恋": "nurse_haru", "坂口隆司": "player", "患者": "patient_generic"},
        "speaker_en": {"七瀬恋": "Ren Nanase", "坂口隆司": "Ryuji Sakaguchi", "患者": "Patient"},
        "choice_en": (
            "Then I may really need you to remind the doctor to eat on time.",
            "Don't worry. I always take care of my own personal affairs.",
            "Then please go and bring the doctor back.",
            "I'm lucky to have a partner who dares to point out the surgeon's mistakes.",
        ),
    },
    {
        "id": "narumi_lv1_beyond_the_resume", "actor": "doc_aoi",
        "source": "HOSHIMI_JINGUJI_NARUMI_LV1_RIREKI_NO_SOTO_V2_1.md",
        "output": "data/staff/doc_aoi/lv1_events.json", "title": "履历之外",
        "title_en": "Beyond the Résumé", "prefix": "nar1", "location": "shared_doctors_office",
        "trigger": "location", "time_start": 780, "time_end": 1020, "minutes": 120,
        "backgrounds": ("shared_doctors_office", "shared_doctors_office", "operating_room", "shared_doctors_office"),
        "outfits": ("white_coat", "white_coat", "sterile", "white_coat"),
        "speaker_ids": {"神宮寺成美": "doc_aoi", "坂口隆司": "player", "巡回护士": "circulating_nurse"},
        "speaker_en": {"神宮寺成美": "Narumi Jinguji", "坂口隆司": "Ryuji Sakaguchi", "巡回护士": "Circulating Nurse"},
        "choice_en": (
            "If a senior colleague is testing me personally, I'll have to show you what I can really do.",
            "It sounds as though today's first assistant is stricter than the operation itself.",
            "Then I'll give Dr. Jinguji an evaluation too—you are an excellent first assistant, but you must also be a formidable lead surgeon.",
            "Now that I've passed the first assessment, how about you operate next time and let me match your rhythm?",
        ),
    },
)

SKIP_MARKERS = {"【两人离开病房】", "【成美离开】", "**【手术进行中】**", "**【稍后】**"}


def _story_lines(spec: dict) -> list[str]:
    manuscript = (SOURCE / spec["source"]).read_text(encoding="utf-8")
    marker = "## 【Scene 1"
    if marker not in manuscript or "## 【Codex实现说明】" not in manuscript:
        raise ValueError(f"Missing revised story boundaries: {spec['source']}")
    return (marker + manuscript.split(marker, 1)[1].split("## 【Codex实现说明】", 1)[0]).splitlines()


def source_beats(spec: dict) -> list[dict]:
    """Parse exact visible text and wire the two authored A/B branches."""
    nodes: list[dict] = []
    scene = 1
    mode = "main"
    last: dict[str, dict | None] = {"main": None, "A": None, "B": None}
    choice_host: dict | None = None
    choice_labels: list[str] = []
    choice_count = 0
    awaiting_merge = False

    def visual_node(speaker: str, text: str) -> dict:
        node = {
            "id": f"{spec['prefix']}_{len(nodes) + 1:03d}", "presentation": "authored",
            "speaker": "narrator" if speaker == "旁白" else ("player" if speaker == "坂口隆司" else "actor"),
            "actor_id": spec["speaker_ids"].get(speaker, spec["actor"]), "speaker_label": speaker,
            "text": text, "expression": "neutral", "outfit": spec["outfits"][scene - 1],
            "background_id": spec["backgrounds"][scene - 1],
            "scene_tint": "#40536d" if spec["id"] == "ren_lv1_night_ward_1" and spec["backgrounds"][scene - 1] == "nurses_station" else "",
            "hide_portrait": speaker not in spec["speaker_ids"] or speaker == "坂口隆司" or spec["speaker_ids"].get(speaker) != spec["actor"],
            "choices": [],
        }
        nodes.append(node)
        return node

    def connect(previous: dict | None, current: dict) -> None:
        if previous is not None and not previous["choices"]:
            previous["choices"] = [{"id": "continue_" + previous["id"], "label": "继续", "next": current["id"],
                                    "effects": {"affection": 0, "familiarity": 0}, "flags": []}]

    def append(speaker: str, text: str) -> None:
        nonlocal awaiting_merge
        node = visual_node(speaker, text)
        if mode in ("A", "B"):
            connect(last[mode], node)
            last[mode] = node
            slot = 0 if mode == "A" else 1
            if choice_host is None or len(choice_host["choices"]) != 2:
                raise ValueError(f"Branch without two choices: {spec['source']} {node['id']}")
            if not choice_host["choices"][slot]["next"]:
                choice_host["choices"][slot]["next"] = node["id"]
        else:
            if awaiting_merge:
                connect(last["A"], node)
                connect(last["B"], node)
                last["A"] = None
                last["B"] = None
                awaiting_merge = False
            else:
                connect(last["main"], node)
            last["main"] = node

    for raw in _story_lines(spec):
        line = raw.strip()
        if not line or line == "---":
            continue
        heading = re.fullmatch(r"## 【Scene (\d+) — .+】", line)
        if heading:
            scene = int(heading.group(1))
            mode = "main"
            continue
        if scene > len(spec["backgrounds"]):
            raise ValueError(f"Missing scene art mapping: {spec['source']} scene {scene}")
        if line.startswith(("**【场景】**", "**【时间】**", "**【在场角色】**", "**【服装状态】**")):
            continue
        if line == "**【玩家可见正文】**" or line in SKIP_MARKERS:
            continue
        if re.fullmatch(r"\*\*【.+ Relationship Lv1 事件结束】\*\*", line):
            continue
        if line.startswith("**【选择："):
            if last["main"] is None:
                raise ValueError(f"Choice has no host: {spec['source']}")
            choice_host = last["main"]
            last["main"] = None
            choice_labels = []
            mode = "choice"
            continue
        if line.startswith("*性质："):
            continue
        option = re.fullmatch(r"- \*\*选项 [AB]：(「.*」)\*\*", line)
        if option:
            choice_labels.append(option.group(1)[1:-1])
            if len(choice_labels) == 2:
                if choice_host is None:
                    raise ValueError(f"Choice labels without host: {spec['source']}")
                choice_host["choices"] = [
                    {"id": f"choice_{choice_host['id']}_a", "label": choice_labels[0], "next": "", "effects": {"affection": 0, "familiarity": 0}, "flags": []},
                    {"id": f"choice_{choice_host['id']}_b", "label": choice_labels[1], "next": "", "effects": {"affection": 0, "familiarity": 0}, "flags": []},
                ]
                choice_count += 1
            continue
        if line == "**【分支 A】**":
            mode = "A"
            last["A"] = None
            continue
        if line == "**【分支 B】**":
            mode = "B"
            last["B"] = None
            continue
        if line == "**【主线汇合】**":
            mode = "main"
            awaiting_merge = True
            continue

        match = re.fullmatch(r"([^：]+)：(「.*」)", line)
        if match and match.group(1) in spec["speaker_ids"]:
            append(match.group(1), match.group(2))
            continue
        if match:
            speaker = next((name for name in spec["speaker_ids"] if match.group(1).startswith(name)), "")
            if speaker:
                append("旁白", match.group(1) + "：")
                append(speaker, match.group(2))
                continue
        append("旁白", line)

    if awaiting_merge or last["A"] is not None or last["B"] is not None:
        raise ValueError(f"Unclosed authored branch: {spec['source']}")
    if choice_count != 2 or any(len(node["choices"]) == 2 and any(not choice["next"] for choice in node["choices"]) for node in nodes):
        raise ValueError(f"Expected two complete A/B choices: {spec['source']}")
    if not nodes:
        raise ValueError(f"No story beats: {spec['source']}")
    final = nodes[-1]
    if final["choices"]:
        raise ValueError(f"Unexpected final choices: {spec['source']}")
    final["choices"] = [{"id": "finish_" + final["id"], "label": "结束", "next": "@end",
                         "effects": {"affection": 0, "familiarity": 0}, "flags": []}]
    return nodes


def main() -> None:
    legacy_translations: dict = json.loads(LEGACY_TRANSLATIONS.read_text(encoding="utf-8"))
    revised_translations: dict = json.loads(REVISED_TRANSLATIONS.read_text(encoding="utf-8"))
    localized: dict = json.loads(LOCALIZATION.read_text(encoding="utf-8"))
    strings: dict = localized["strings"]
    for spec in EVENTS:
        beats = source_beats(spec)
        legacy = legacy_translations.get(spec["id"], {})
        revised = revised_translations.get(spec["id"], {})
        translated = [revised.get(beat["text"], legacy.get(beat["text"], "")) for beat in beats]
        if any(not isinstance(line, str) or not line.strip() for line in translated):
            missing = [beat["text"] for beat, line in zip(beats, translated) if not isinstance(line, str) or not line.strip()]
            raise ValueError(f"English line alignment: {spec['id']} missing {missing}")
        event = {
            "id": spec["id"], "actor_id": spec["actor"], "title": spec["title"], "teaser": spec["title"],
            "chapter": 1, "location_id": spec["location"], "trigger_mode": spec["trigger"],
            "background_id": spec["backgrounds"][0], "outfit": spec["outfits"][0], "minutes": spec["minutes"],
            "time_start": spec["time_start"], "time_end": spec["time_end"], "priority": 95,
            "category": "bond", "target_level": 1, "benefit_id": "", "cinematic": True,
            "auto_start": spec["trigger"] == "after_work", "hide_calendar_header": spec["id"] == "ren_lv1_night_ward_1",
            "gallery": {"cg_id": spec["id"], "caption": spec["title"], "path": "", "show_on_complete": False},
            "conditions": {"min_day": 1, "min_affection": 0, "min_familiarity": 10, "required_events": [],
                           "special_requirements": [], "days_after_required_events": 0},
            "start": beats[0]["id"], "nodes": beats,
        }
        (ROOT / spec["output"]).write_text(json.dumps([event], ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        prefix = f"collections.character_events.{spec['id']}"
        for key in list(strings):
            if key.startswith(prefix + "."):
                del strings[key]
        strings[prefix + ".title"] = spec["title_en"]
        strings[prefix + ".teaser"] = spec["title_en"]
        strings[prefix + ".gallery.caption"] = spec["title_en"]
        choice_en_index = 0
        for beat, english in zip(beats, translated):
            stem = prefix + ".nodes." + beat["id"]
            strings[stem + ".text"] = english
            chinese_label = beat["speaker_label"]
            strings[stem + ".speaker_label"] = "Narrator" if chinese_label == "旁白" else spec["speaker_en"][chinese_label]
            for choice in beat["choices"]:
                if len(beat["choices"]) == 2:
                    label_en = spec["choice_en"][choice_en_index]
                    choice_en_index += 1
                else:
                    label_en = "Finish" if choice["next"] == "@end" else "Continue"
                strings[stem + ".choices." + choice["id"] + ".label"] = label_en
        if choice_en_index != 4:
            raise ValueError(f"English choice alignment: {spec['id']} {choice_en_index}/4")
        print(spec["id"], len(beats), "source beats")
    LOCALIZATION.write_text(json.dumps(localized, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
