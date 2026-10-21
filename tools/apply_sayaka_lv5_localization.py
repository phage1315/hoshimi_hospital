#!/usr/bin/env python3
"""Merge the reviewed Sayaka Lv5 English node translations into en.json."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TRANSLATION_PATH = ROOT / "tools/sayaka_lv5_en_text.json"
EN_PATH = ROOT / "data/localization/en.json"
STEP_PATH = ROOT / "data/events/special_event_steps/sayaka_lv5.json"
EVENT_FILES = [
    ROOT / "data/events/special_events/sayaka_lv5_part_a.json",
    ROOT / "data/events/special_events/sayaka_lv5_part_b.json",
    ROOT / "data/events/special_events/sayaka_lv5_part_c.json",
]

SPEAKERS = {
    "旁白": "Narrator",
    "南条小夜香": "Sayaka Nanjo",
    "坂口隆司": "Dr. Sakaguchi",
    "深山佳織": "Kaori Miyama",
    "杉村弘子": "Hiroko Sugimura",
    "本庄萌恵": "Moe Honjo",
    "城宮明日香": "Asuka Shiromiya",
    "城宮明日香（门内）": "Asuka Shiromiya (from behind the door)",
}
CHOICES = {"继续": "Continue", "今晚去看看。": "Let's see tonight.", "改天吧。": "Maybe another time."}

translations = json.loads(TRANSLATION_PATH.read_text(encoding="utf-8"))
english = json.loads(EN_PATH.read_text(encoding="utf-8"))
strings = english["strings"]
steps = json.loads(STEP_PATH.read_text(encoding="utf-8"))
events = [json.loads(path.read_text(encoding="utf-8"))[0] for path in EVENT_FILES]

titles = {
    "sayaka_lv5_part_a": "Is Anyone Here Tonight?",
    "sayaka_lv5_part_b": "Then Operate on Me",
    "sayaka_lv5_part_c": "The Director's Approval",
}
for event in events:
    event_id = event["id"]
    title = titles[event_id]
    strings[f"collections.special_events.{event_id}.title"] = title
    strings[f"collections.special_events.{event_id}.gallery_entry.title"] = title
    strings[f"collections.special_events.{event_id}.gallery_entry.chapters.0"] = "Full Replay"
    strings[f"collections.special_events.{event_id}.completion_hint"] = title + " — event complete."

for step in steps:
    step_id = step["id"]
    strings[f"collections.special_event_steps.{step_id}.title"] = titles[step_id.removesuffix("_main")]
    for node in step["nodes"]:
        prefix = f"collections.special_event_steps.{step_id}.nodes.{node['id']}"
        speaker = node.get("speaker_label", "")
        if speaker in SPEAKERS:
            strings[f"{prefix}.speaker_label"] = SPEAKERS[speaker]
        if node["id"] in translations:
            strings[f"{prefix}.text"] = translations[node["id"]]
        for choice in node.get("choices", []):
            label = choice.get("label", "")
            if label in CHOICES:
                strings[f"{prefix}.choices.{choice['id']}.label"] = CHOICES[label]

EN_PATH.write_text(json.dumps(english, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Merged {len(translations)} reviewed node translations; authored nodes: {sum(len(s['nodes']) for s in steps)}")
