#!/usr/bin/env python3
"""Import the canonical Narumi/Ren shared Lv2 V2.2 fixed VN."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts/HOSHIMI_JINGUJI_NARUMI_NANASE_REN_SHARED_LV2_SHOMEISHO_V2_4.md"
LEGACY_SOURCE = ROOT / "research/source_scripts/HOSHIMI_JINGUJI_NARUMI_NANASE_REN_SHARED_LV2_SHOMEISHO_V2_2.md"
OUTPUT = ROOT / "data/staff/doc_aoi/shared_lv2_events.json"
TRANSLATIONS = ROOT / "research/translations/narumi_ren_shared_lv2_en.json"
LOCALIZATION = ROOT / "data/localization/en.json"
EVENT_ID = "narumi_ren_shared_lv2_sign_here"
PREFIX = "nr2"

SPEAKERS = {
    "前台接待员": ("receptionist", "Receptionist"),
    "霜月美佳": ("shimotsuki_mika", "Mika Shimotsuki"),
    "神宮寺成美": ("doc_aoi", "Narumi Jinguji"),
    "七瀬恋": ("nurse_haru", "Ren Nanase"),
    "坂口隆司": ("player", "Ryuji Sakaguchi"),
    "值班护士": ("duty_nurse", "Duty Nurse"),
    "城宮明日香": ("doc_asuka", "Asuka Jogu"),
}

SCENE_ART = {
    1: ("lobby", "white_coat"),
    2: ("conference_room", "white_coat"),
    3: ("conference_room", "white_coat"),
    4: ("or_entrance", "scrubs"),
    5: ("operating_room", "sterile"),
    6: ("or_entrance", "white_coat"),
    7: ("exam_room", "white_coat"),
    8: ("director_office", "white_coat"),
    9: ("director_office", "white_coat"),
}

PORTRAITS = {
    ("shimotsuki_mika", "business_neutral"): "assets/events/character_events/narumi_ren/shared_lv2/shimotsuki_mika_business_half_neutral.png",
    ("shimotsuki_mika", "business_confident"): "assets/events/character_events/narumi_ren/shared_lv2/shimotsuki_mika_business_half_confident.png",
    ("shimotsuki_mika", "business_forced"): "assets/events/character_events/narumi_ren/shared_lv2/shimotsuki_mika_business_half_forced.png",
    ("shimotsuki_mika", "business_angry"): "assets/events/character_events/narumi_ren/shared_lv2/shimotsuki_mika_business_half_angry.png",
    ("shimotsuki_mika", "business_guarded"): "assets/events/character_events/narumi_ren/shared_lv2/shimotsuki_mika_business_half_guarded.png",
    ("shimotsuki_mika", "patient_anxious"): "assets/events/character_events/narumi_ren/shared_lv2/shimotsuki_mika_or_anxious.png",
    ("shimotsuki_mika", "patient_angry"): "assets/events/character_events/narumi_ren/shared_lv2/shimotsuki_mika_or_angry.png",
    ("shimotsuki_mika", "patient_terrified"): "assets/events/character_events/narumi_ren/shared_lv2/shimotsuki_mika_or_terrified.png",
    ("shimotsuki_mika", "patient_crying"): "assets/events/character_events/narumi_ren/shared_lv2/shimotsuki_mika_or_crying.png",
    ("shimotsuki_mika", "patient_exhausted"): "assets/events/character_events/narumi_ren/shared_lv2/shimotsuki_mika_or_exhausted.png",
    ("doc_aoi", "white_coat"): "assets/characters/portrait_pack_v1/doc_aoi/white_coat/serious.png",
    ("doc_aoi", "scrubs"): "assets/characters/portrait_pack_v1/doc_aoi/scrubs/neutral.png",
    ("doc_aoi", "sterile"): "assets/characters/sterile_pack_v1/doc_aoi/neutral.png",
    ("nurse_haru", "uniform"): "assets/characters/nurse_haru_refresh_v1/uniform/serious.png",
    ("nurse_haru", "scrubs"): "assets/characters/portrait_pack_v1/nurse_haru/scrubs/neutral.png",
    ("doc_asuka", "white_coat"): "assets/characters/portrait_pack_v15/doc_asuka/white_coat/neutral.png",
}

MIKA_EXPRESSIONS = {
    "business_confident": {"nr2_034"},
    "business_forced": {"nr2_052", "nr2_056", "nr2_060", "nr2_066"},
    "business_angry": {"nr2_070", "nr2_073", "nr2_080", "nr2_086", "nr2_088"},
    "business_guarded": {"nr2_201", "nr2_205", "nr2_209", "nr2_211", "nr2_216", "nr2_218", "nr2_222", "nr2_225"},
    "patient_angry": {"nr2_103", "nr2_111", "nr2_113", "nr2_118"},
    "patient_terrified": {"nr2_127", "nr2_141"},
    "patient_crying": {"nr2_136", "nr2_149", "nr2_152", "nr2_155", "nr2_157", "nr2_174"},
    "patient_exhausted": {"nr2_167", "nr2_171"},
}

SKIP_EXACT = {
    "**【玩家可见正文】**", "---",
    "**【神宮寺成美 × 七瀬恋 共享 Relationship Lv2 事件结束】**",
}

ENGLISH_OVERRIDES = {
    "Although what they did in the operating room yesterday did cross a line, you saw Narumi put the knife away, heard her say she had never intended to cut the patient open, and even steered passersby away for them. They must be very grateful to you.":
        "「虽然她们昨天在手术室里的做法确实越了界，但你看见成美已经收刀，也听见她说自己本来就没打算切开患者，还替她们挡开了路过的人。她们心里一定很感激。」",
}
# Written source-first below for readability; reversed once when building the map.
ENGLISH_OVERRIDES_BY_CN = {cn: en for en, cn in ENGLISH_OVERRIDES.items()}
ENGLISH_OVERRIDES_BY_CN.update({
    "城宮明日香神色微敛，认真地摇了摇头：":
        "Asuka's expression tightened, and she shook her head seriously:",
    "「不过，成美昨天可不是因为慌乱才失去理智的。她非常清楚自己在做什么，也是深思熟虑后主动选了这种手段。我能理解她们的处境，但星见医院绝不能成为她用来对付旧敌的工具。」":
        "“Still, Narumi did not lose her head in a panic yesterday. She knew exactly what she was doing and deliberately chose that method after careful consideration. I can understand their circumstances, but Hoshimi Hospital can never become a tool she uses against old enemies.”",
    "「在征得成美和恋同意的前提下，我今天找你来，是想正式给你透个底。成美和恋以前都在比良坂竜二掌控的医院工作过，后来与他彻底决裂。尤其是成美，她和比良坂之间有一笔非常复杂的旧账。具体发生过什么，我想还是应该由她自己告诉你。当年她们离开那里、在医学界遭到比良坂打压的时候，是我把她们招进了星见。」":
        "“After obtaining Narumi and Ren's consent, I called you here today to formally bring you into the loop. Both of them once worked at a hospital under Ryuji Hirasaka's control, but later broke with him completely. Narumi in particular has a very complicated history with Hirasaka. I think what happened should be for her to tell you herself. When they left and Hirasaka suppressed them throughout the medical field, I was the one who brought them to Hoshimi.”",
    "神宮寺成美微微一怔，眼底那层紧绷的防备悄然融化，嘴角重新浮现出平日里那抹温婉而知性的笑意。":
        "Narumi froze for a moment. The guarded tension in her eyes quietly melted away, and her usual warm, intelligent smile returned to her lips.",
})


def story_lines(source: Path = SOURCE) -> list[str]:
    manuscript = source.read_text(encoding="utf-8")
    marker = "## 【Scene 1"
    return (marker + manuscript.split(marker, 1)[1].split("## 【Codex实现说明】", 1)[0]).splitlines()


def clean_visible(line: str) -> str:
    # Markdown emphasis is manuscript markup, not player-visible dialogue.
    return line.replace("**", "")


def mika_expression(node_id: str, scene: int) -> str:
    for expression, node_ids in MIKA_EXPRESSIONS.items():
        if node_id in node_ids:
            return expression
    return "business_neutral" if scene in (1, 2, 3, 7) else "patient_anxious"


def portrait_for(actor_id: str, scene: int, node_id: str) -> str:
    if actor_id == "shimotsuki_mika":
        return PORTRAITS.get((actor_id, mika_expression(node_id, scene)), "")
    if actor_id == "doc_aoi":
        outfit = "sterile" if scene == 5 else ("scrubs" if scene == 4 else "white_coat")
        return PORTRAITS.get((actor_id, outfit), "")
    if actor_id == "nurse_haru":
        outfit = "scrubs" if scene in (4, 5) else "uniform"
        return PORTRAITS.get((actor_id, outfit), "")
    if actor_id == "doc_asuka":
        return PORTRAITS.get((actor_id, "white_coat"), "")
    return ""


def parse_beats(source: Path = SOURCE) -> list[dict]:
    nodes: list[dict] = []
    scene = 1
    mode = "main"
    last: dict[str, dict | None] = {"main": None, "A": None, "B": None}
    choice_host: dict | None = None
    choice_labels: list[str] = []
    awaiting_merge = False
    active_background = SCENE_ART[scene][0]

    def connect(previous: dict | None, current: dict) -> None:
        if previous is not None and not previous["choices"]:
            previous["choices"] = [{"id": "continue_" + previous["id"], "label": "继续", "next": current["id"],
                                    "effects": {"affection": 0, "familiarity": 0}, "flags": []}]

    def append(speaker: str, text: str) -> None:
        nonlocal awaiting_merge
        actor_id, _ = SPEAKERS.get(speaker, ("doc_aoi", "Narrator"))
        _, primary_outfit = SCENE_ART[scene]
        actor_outfit = primary_outfit
        if actor_id == "nurse_haru":
            actor_outfit = "scrubs" if scene in (4, 5) else "uniform"
        elif actor_id == "doc_asuka":
            actor_outfit = "white_coat"
        elif actor_id == "shimotsuki_mika":
            actor_outfit = "business" if scene in (1, 2, 3, 7) else "patient"
        node_id = f"{PREFIX}_{len(nodes) + 1:03d}"
        expression = mika_expression(node_id, scene) if actor_id == "shimotsuki_mika" else "neutral"
        node = {
            "id": node_id, "presentation": "authored",
            "speaker": "narrator" if speaker == "旁白" else ("player" if actor_id == "player" else "actor"),
            "actor_id": actor_id, "speaker_label": speaker, "text": clean_visible(text),
            "expression": expression, "outfit": actor_outfit, "background_id": active_background,
            "hide_portrait": True, "choices": [],
        }
        path = "" if speaker == "旁白" else portrait_for(actor_id, scene, node_id)
        if path:
            node["hide_portrait"] = False
            # CharacterStage interprets `bottom` as the visible artwork edge.
            # Keep every half-body portrait flush with the VN dialogue frame.
            node["event_portraits"] = [{"id": actor_id, "path": path, "x": 1030, "bottom": 540, "width": 410, "height": 500}]
        nodes.append(node)
        if mode in ("A", "B"):
            connect(last[mode], node)
            last[mode] = node
            slot = 0 if mode == "A" else 1
            if choice_host is None or len(choice_host["choices"]) != 2:
                raise ValueError(f"Branch without choice at {node['id']}")
            if not choice_host["choices"][slot]["next"]:
                choice_host["choices"][slot]["next"] = node["id"]
        else:
            if awaiting_merge:
                connect(last["A"], node)
                connect(last["B"], node)
                last["A"] = last["B"] = None
                awaiting_merge = False
            else:
                connect(last["main"], node)
            last["main"] = node

    for raw in story_lines(source):
        line = raw.strip()
        if not line or line in SKIP_EXACT:
            continue
        heading = re.fullmatch(r"## 【Scene (\d+) — .+】", line)
        if heading:
            scene = int(heading.group(1))
            mode = "main"
            active_background = SCENE_ART[scene][0]
            continue
        if line.startswith(("**【场景】**", "**【时间】**", "**【在场角色】**", "**【服装状态】**")):
            continue
        if line.startswith("**【选择："):
            if last["main"] is None:
                raise ValueError("Choice has no visible host")
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
        if scene == 1 and line.startswith("成美脚步未停"):
            active_background = "nurses_station"
        elif scene == 9 and line.startswith("坂口隆司起身道别"):
            active_background = "hallway"
        match = re.fullmatch(r"([^：]+)：(「.*」)", line)
        if match and match.group(1) in SPEAKERS:
            append(match.group(1), match.group(2))
        elif match:
            # Preserve mixed action/dialogue paragraphs exactly while keeping the
            # quoted words assigned to their actual speaker.
            mixed_speaker = next((name for name in SPEAKERS if match.group(1).startswith(name)), "")
            if mixed_speaker:
                append("旁白", match.group(1) + "：")
                append(mixed_speaker, match.group(2))
            else:
                append("旁白", line)
        else:
            append("旁白", line)

    if awaiting_merge or last["A"] is not None or last["B"] is not None:
        raise ValueError("Unclosed branch")
    if sum(1 for node in nodes if len(node["choices"]) == 2) != 2:
        raise ValueError("Expected exactly two authored choices")
    nodes[-1]["choices"] = [{"id": "finish_" + nodes[-1]["id"], "label": "结束", "next": "@end",
                              "effects": {"affection": 0, "familiarity": 0}, "flags": []}]
    return nodes


def main() -> None:
    beats = parse_beats()
    event = {
        "id": EVENT_ID, "actor_id": "doc_aoi", "relationship_actor_ids": ["doc_aoi", "nurse_haru"],
        "completion_story_flags": ["narumi_ren_hirasaka_informed", "narumi_ren_shared_lv2_complete"],
        "title": "请在这里签字", "teaser": "一名借着器械目录而来的女推销员，似乎知道得太多了。",
        "chapter": 2, "location_id": "lobby", "trigger_mode": "location", "background_id": "lobby",
        "outfit": "white_coat", "minutes": 10, "time_start": 870, "time_end": 900, "priority": 110,
        "category": "rank_up", "target_level": 2, "benefit_id": "", "cinematic": True,
        "locks_saving": True, "hide_calendar_header": True, "hide_completion_portrait": True,
        "completion_day_offset": 1, "completion_absolute_clock": 540,
        "gallery": {"cg_id": EVENT_ID, "caption": "请在这里签字", "path": "", "show_on_complete": False},
        "conditions": {"min_day": 1, "min_affection": 0, "min_familiarity": 25,
                       "required_events": ["narumi_lv1_beyond_the_resume", "ren_lv1_night_ward_1"],
                       "days_after_required_events": 3, "special_requirements": []},
        "start": beats[0]["id"], "nodes": beats,
    }
    OUTPUT.write_text(json.dumps([event], ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if not TRANSLATIONS.exists():
        print(f"wrote {len(beats)} source beats; English file not present yet")
        for beat in beats:
            print(beat["id"], beat["speaker_label"], beat["text"].replace("\n", " "))
        return
    legacy_translations = json.loads(TRANSLATIONS.read_text(encoding="utf-8"))
    legacy_beats = parse_beats(LEGACY_SOURCE)
    legacy_occurrences: dict[tuple[str, str], int] = {}
    legacy_lookup: dict[tuple[str, str, int], str] = {}
    choice_lookup: dict[str, str] = {}
    for beat in legacy_beats:
        pair = (beat["speaker_label"], beat["text"])
        occurrence = legacy_occurrences.get(pair, 0)
        legacy_occurrences[pair] = occurrence + 1
        legacy_lookup[(pair[0], pair[1], occurrence)] = str(legacy_translations.get(beat["id"], "")).strip()
        if len(beat["choices"]) == 2:
            for choice in beat["choices"]:
                choice_lookup[choice["label"]] = str(legacy_translations.get(choice["id"], "")).strip()
    current_occurrences: dict[tuple[str, str], int] = {}
    localized = json.loads(LOCALIZATION.read_text(encoding="utf-8"))
    strings = localized["strings"]
    prefix = f"collections.character_events.{EVENT_ID}"
    for key in list(strings):
        if key.startswith(prefix + "."):
            del strings[key]
    strings[prefix + ".title"] = "Please Sign Here"
    strings[prefix + ".teaser"] = "A saleswoman carrying an instrument catalogue seems to know far too much."
    strings[prefix + ".gallery.caption"] = "Please Sign Here"
    strings["ui.character_event.shared_rank_up"] = "Both relationships rose to Lv.%s"
    for beat in beats:
        pair = (beat["speaker_label"], beat["text"])
        occurrence = current_occurrences.get(pair, 0)
        current_occurrences[pair] = occurrence + 1
        english = ENGLISH_OVERRIDES_BY_CN.get(beat["text"], legacy_lookup.get((pair[0], pair[1], occurrence), ""))
        if not english:
            raise ValueError(f"Missing English translation: {beat['id']} {beat['text']}")
        stem = f"{prefix}.nodes.{beat['id']}"
        strings[stem + ".text"] = english
        strings[stem + ".speaker_label"] = "Narrator" if beat["speaker_label"] == "旁白" else SPEAKERS[beat["speaker_label"]][1]
        for choice in beat["choices"]:
            choice_key = stem + ".choices." + choice["id"] + ".label"
            if len(beat["choices"]) == 2:
                strings[choice_key] = choice_lookup.get(choice["label"], "")
                if not strings[choice_key]:
                    raise ValueError(f"Missing English choice: {choice['id']}")
            else:
                strings[choice_key] = "Finish" if choice["next"] == "@end" else "Continue"
    LOCALIZATION.write_text(json.dumps(localized, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"imported {EVENT_ID}: {len(beats)} beats")


if __name__ == "__main__":
    main()
