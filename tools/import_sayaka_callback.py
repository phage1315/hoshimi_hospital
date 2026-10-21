#!/usr/bin/env python3
"""Mechanically import the locked Chinese Sayaka callback script."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.home() / "Downloads/HOSHIMI_STAFF_AS_PATIENT_APPENDIX_CALLBACK_CODEX_READY_CN_V1.md"
OUT_STEPS = ROOT / "data/events/special_event_steps/sayaka_staff_as_patient_callback.json"
EVENTS_DIR = ROOT / "data/events/special_events"

SCENES = {
    "01": ("sayaka_staff_patient_callback_01", "sayaka_staff_patient_callback_01_main", "不见的伤口", "The Disappearing Wound", "hallway"),
    "02": ("sayaka_staff_patient_callback_02", "sayaka_staff_patient_callback_02_main", "长回来的阑尾", "The Appendix That Grew Back", "player_office"),
    "03": ("sayaka_staff_patient_callback_03", "sayaka_staff_patient_callback_03_main", "院长的新发现", "The Director's New Discovery", "lobby"),
}
SPEAKERS = {
    "旁白": ("narrator", "旁白"),
    "坂口隆司": ("player", "坂口隆司"),
    "南条小夜香": ("actor", "南条小夜香"),
    "城宮明日香": ("actor", "城宮明日香"),
    "杉村弘子": ("actor", "杉村弘子"),
}
EN_TEXTS = {
    "01": [
        "At nine in the morning, Sakaguchi runs into Sayaka in the corridor as she checks the ward records.",
        "Good morning, Sayaka.",
        "Good morning, Dr. Sakaguchi! Let's both do our best today!",
        "...You're certainly full of energy.",
        "Hm? What's wrong?",
        "By the way, that appendectomy last week... Are you really feeling no effects at all now?",
        "Oh, that? I'm completely fine! The very next day, I couldn't even see the incision anymore!",
        "...The next day?",
        "That's right! Not even a scar. You're pretty good at this, you know!",
        "W-wait. That was an open appendectomy! There were so many layers of tissue beneath the skin!",
        "I know. Sakaguchi, you performed the operation yourself, so why are you asking me to explain it?",
        "...That's not the point.",
        "Sakaguchi thinks for a moment.",
        "Sayaka, are you free today?",
        "I am... Why? Are you asking me out?",
        "No. Could you get an abdominal ultrasound in Imaging later?",
        "An ultrasound? Why?",
        "I want to see how things have healed inside. I can't see a wound on the outside, but I'm still not at ease.",
        "Sure! Hehe, since Dr. Sakaguchi is so worried about me, of course I'll cooperate!",
        "...All right. Thanks.",
        "I'll head over once I'm done with what I'm doing. I'll come find you after the scan!",
        "Sayaka waves with a smile, then turns to leave.",
        "Sakaguchi watches her go, momentarily lost in thought.",
        "...The scar was gone by the very next day? What kind of recovery rate is that...?",
        "That afternoon, Sayaka has the abdominal ultrasound as planned.",
    ],
    "02": [
        "At nine in the morning, Sakaguchi has been staring at yesterday's abdominal ultrasound report at his desk for quite some time.",
        "A knock at the door.",
        "Sakaguchi, I'm coming in!",
        "Good morning! How did yesterday's scan turn out? Has everything healed beautifully?",
        "...Sayaka.",
        "Hm?",
        "I want to confirm something with you first.",
        "What is it? You sound so serious.",
        "About that operation last time... We did remove your appendix, right?",
        "Of course! Didn't you write the operative report yourself? You put me through quite a lot!",
        "The specimen we removed was sent to pathology, too.",
        "Right. And?",
        "...Then can you explain why yesterday's ultrasound showed your perfectly healthy appendix again?",
        "...Huh?",
        "Sayaka walks over to Sakaguchi and bends down to peer at the computer screen.",
        "Oh! It really is there!",
        "Wow, that healed really well!",
        "This is a little beyond 'healed really well,' isn't it?!",
        "Oh, Sakaguchi, why are you making such a fuss?",
        "Sayaka! We removed it with our own hands! And now it's back, perfectly healthy, as if it had never been operated on! That makes no sense!",
        "Hehe, why are you still hung up on that? Didn't I tell you already?",
        "This is anime logic! Anime logic! Don't take it so seriously!",
        "...I'm starting to wonder whether I'm even a doctor.",
        "Oh, don't worry. There's nothing wrong with your surgical skills. You really did remove my appendix that day—I saw it with my own eyes!",
        "Sayaka puffs her cheeks a little.",
        "But don't get the wrong idea! Sure, my appendix grew back, but having you operate on me that day really hurt! Don't tease me for crying out so loudly again!",
        "...I wasn't teasing you.",
        "You definitely laughed to yourself!",
        "Sakaguchi silently looks back at the report.",
        "...So you're saying you could even have another appendectomy?",
        "Hey! Why are you suddenly thinking along those lines?!",
        "No, I just want to make sure... If even an appendix can grow back, then in theory, could other operations also...?",
        "Oh, of course they could! I told you, this is anime logic!",
        "Sayaka suddenly smiles as if a thought has occurred to her.",
        "Although, if I can, next time I'd like to try a different procedure!",
        "...You're already thinking about the next one?",
        "Hehe, it's a rare opportunity!",
        "She remembers the last operation, and her smile suddenly turns a little strained.",
        "But next time... please be gentler, or maybe give me some anesthesia?",
        "But preferably not general anesthesia. I don't want to fall asleep and miss everything.",
        "...I need a moment to process this.",
    ],
    "03": [
        "At nine in the morning, Sakaguchi has just entered the hospital lobby when he sees Asuka making her rounds.",
        "Oh, Dr. Sakaguchi! Good morning! Let's do our best today, too!",
        "Good morning, Director. Oh, right—there's something I've been meaning to tell you.",
        "Hm? What is it?",
        "It's about that appendectomy we performed on Dr. Nanjo without approval from the hospital administration.",
        "Oh, that! What about it? She recovered well, didn't she? I see Sayaka coming to work in great spirits every day!",
        "...Director, this isn't a question of whether she recovered well.",
        "Huh?",
        "I just looked at her abdominal ultrasound. Her appendix... has grown back.",
        "Oh my?",
        "And it looks completely normal, as if she'd never had surgery! I'm certain we removed it that day, and the pathology specimen—",
        "Wow! Isn't that convenient!",
        "...Convenient?",
        "Yes! Doesn't that make the surgical practice we discussed even more worthwhile?",
        "Think about it. If even a removed organ can recover, young doctors will have more chances to practice all kinds of procedures!",
        "Director, I don't think that's the issue here...",
        "Asuka continues speaking, brimming with enthusiasm.",
        "Hehe, our hospital has so many young, healthy doctors and nurses! If everyone helps each other practice, our surgical skills will improve in no time!",
        "...How have you already started thinking about the next operation, too?",
        "Hm? Isn't that a good thing? To train excellent young doctors, of course we should create more opportunities for everyone to practice!",
        "For a moment, Sakaguchi doesn't know how to respond.",
        "Just then, Hiroko Sugimura passes by them carrying a ward document.",
        "Oh, Director. Good morning.",
        "Hiroko gives a small bow and is about to continue on her way.",
        "Oh, Hiroko! Good morning!",
        "Asuka suddenly remembers something and turns to look at Hiroko.",
        "You see, Dr. Sakaguchi? Nurse Sugimura is always so energetic, and she looks especially healthy, too!",
        "She seems like a perfect fit!",
        "Asuka turns and winks at Sakaguchi with a knowing smile.",
        "...?",
        "Director? What do you mean... a perfect fit for what?",
        "D-Director! Please don't...!",
    ],
}


def write_json(path: Path, value: object) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def actor_visual(focus: str, mood: str) -> dict:
    if focus == "坂口隆司":
        return {"hide_portrait": True}
    if focus == "南条小夜香":
        expression = {
            "work_smile": "smile",
            "work_happy": "happy",
            "work_mischief": "teasing",
            "work_surprised": "neutral",
            "work_blush": "shy",
        }.get(mood, "neutral")
        return {"actor_id": "doc_sayaka", "outfit": "white_coat", "expression": expression}
    if focus == "城宮明日香":
        expression = "warm" if mood in {"asuka_bright_smile", "asuka_intrigued", "asuka_smile"} else "neutral"
        return {"actor_id": "doc_asuka", "outfit": "white_coat", "expression": expression}
    if focus == "杉村弘子":
        expression = "worried" if mood == "nurse_confused" else "smile"
        return {"actor_id": "nurse_hiroko", "outfit": "uniform", "expression": expression}
    raise ValueError(f"Unknown focal character: {focus}")


def parse_scene(source: str, scene_number: str) -> list[dict]:
    prefix = f"SAP{scene_number}-"
    pattern = re.compile(rf"^【演出节点 ({prefix}\d{{4}})｜([^】]+)】\s*\n([^\n]+)", re.MULTILINE)
    nodes: list[dict] = []
    for match in pattern.finditer(source):
        source_id, metadata, body = match.groups()
        node_id = source_id.lower().replace("-", "_")
        meta = dict(part.split("=", 1) for part in metadata.split("｜") if "=" in part)
        location = meta["地点"]
        expected_background = {"医院走廊": "hallway", "医生办公室": "player_office", "医院一楼大堂": "lobby"}.get(location)
        if not expected_background:
            raise ValueError(f"Unmapped location {location!r} at {source_id}")
        focus_spec = meta.get("当前焦点", "")
        if ":" not in focus_spec:
            raise ValueError(f"Missing focal actor/expression at {source_id}")
        focus, mood = focus_spec.split(":", 1)
        speaker_match = re.match(r"^([^：:]+)[：:](.*)$", body.strip())
        source_speaker, text = speaker_match.groups() if speaker_match else ("旁白", body.strip())
        if source_speaker not in SPEAKERS:
            raise ValueError(f"Unmapped speaker {source_speaker!r} at {source_id}")
        speaker, label = SPEAKERS[source_speaker]
        node = {
            "id": node_id,
            "speaker": speaker,
            "speaker_label": label,
            "text": text.strip(),
            "background_id": expected_background,
            "choices": [{"id": f"{node_id}_next", "label": "继续", "next": "", "requirements": []}],
        }
        visual = actor_visual(focus, mood)
        node["expression"] = str(visual.get("expression", "neutral"))
        node.update(visual)
        nodes.append(node)
    return nodes


def make_event(number: str, node_count: int) -> dict:
    event_id, step_id, title, english_title, _background = SCENES[number]
    event: dict = {
        "id": event_id,
        "title": title,
        "category": "character_special_event",
        "duration_days": 1,
        "consumes_full_day": False,
        "repeatable": False,
        "developer_only": False,
        "auto_schedule": True,
        "trigger_mode": "day_start",
        "unlock_requirements": [],
        "required_characters": [],
        "prerequisite_events": [],
        "event_chain": [step_id],
        "completion_flags": [],
        "gallery_unlock": False,
        "timing": {
            "trigger_day": 1,
            "priority": 205,
            "final_week_allowed": True,
            "sunday_start_allowed": number == "02",
            "exact_day_start_only": True,
        },
    }
    if number == "01":
        event["unlock_requirements"] = [
            {"type": "special_event_completed", "event_id": "sayaka_lv5_part_c"},
            # Part B's real operation is at night on its start day; the engine
            # records the full-day event's completion on the next morning.
            # Six date boundaries from that completion date equals seven days
            # from the operation date.
            {"type": "days_after_special_event", "event_id": "sayaka_lv5_part_b", "days": 6},
            {"type": "day_type", "values": ["weekday", "saturday"]},
        ]
        event["prerequisite_events"] = ["sayaka_lv5_part_c"]
        event["completion_flags"] = ["sayaka_staff_patient_callback_01_complete", "sayaka_staff_patient_callback_ultrasound_complete"]
    elif number == "02":
        event["unlock_requirements"] = [{"type": "days_after_special_event", "event_id": SCENES["01"][0], "days": 1}]
        event["prerequisite_events"] = [SCENES["01"][0]]
        event["completion_flags"] = ["sayaka_staff_patient_callback_02_complete"]
    else:
        event["unlock_requirements"] = [
            {"type": "days_after_special_event", "event_id": SCENES["02"][0], "days": 1},
            {"type": "day_type", "values": ["weekday", "saturday"]},
        ]
        event["prerequisite_events"] = [SCENES["02"][0]]
        event["completion_flags"] = ["sayaka_staff_patient_callback_03_complete", "sayaka_staff_patient_callback_complete"]
    return event


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    all_nodes: list[dict] = []
    step_records: list[dict] = []
    events: list[dict] = []
    for number, (_event_id, step_id, title, _english, background) in SCENES.items():
        nodes = parse_scene(source, number)
        expected = {"01": 25, "02": 41, "03": 32}[number]
        if len(nodes) != expected:
            raise ValueError(f"SAP{number} node count is {len(nodes)}; expected {expected}")
        if len(EN_TEXTS[number]) != expected:
            raise ValueError(f"SAP{number} English node count is {len(EN_TEXTS[number])}; expected {expected}")
        for left, right in zip(nodes, nodes[1:]):
            left["choices"][0]["next"] = right["id"]
        nodes[-1]["choices"][0]["next"] = "@day_end"
        step_records.append({"id": step_id, "title": title, "background_id": background, "start": nodes[0]["id"], "nodes": nodes})
        all_nodes.extend(nodes)
        events.append(make_event(number, len(nodes)))
    if len({node["id"] for node in all_nodes}) != 98:
        raise ValueError("Callback node IDs are not unique")
    write_json(OUT_STEPS, step_records)
    for event in events:
        write_json(EVENTS_DIR / f"{event['id']}.json", [event])
    english_path = ROOT / "data/localization/en.json"
    english_data = json.loads(english_path.read_text(encoding="utf-8"))
    strings: dict[str, str] = english_data["strings"]
    for number, (event_id, step_id, _title, english_title, _background) in SCENES.items():
        strings[f"collections.special_events.{event_id}.title"] = english_title
        strings[f"collections.special_event_steps.{step_id}.title"] = english_title
        for index, node in enumerate(parse_scene(source, number), start=1):
            node_id = str(node["id"])
            speaker = str(node["speaker_label"])
            english_speaker = {
                "旁白": "Narrator",
                "坂口隆司": "Dr. Sakaguchi",
                "南条小夜香": "Sayaka Nanjo",
                "城宮明日香": "Asuka Shiromiya",
                "杉村弘子": "Hiroko Sugimura",
            }[speaker]
            base = f"collections.special_event_steps.{step_id}.nodes.{node_id}"
            strings[f"{base}.speaker_label"] = english_speaker
            strings[f"{base}.text"] = EN_TEXTS[number][index - 1]
            strings[f"{base}.choices.{node_id}_next.label"] = "Continue"
    write_json(english_path, english_data)
    print("Imported exact player-visible source nodes: SAP01=25, SAP02=41, SAP03=32 (98 total).")


if __name__ == "__main__":
    main()
