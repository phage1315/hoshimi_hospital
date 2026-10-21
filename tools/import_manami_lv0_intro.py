#!/usr/bin/env python3
"""Import Manami Iimura's approved Lv0 pharmacy introduction and localization."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path("/Users/ningye/Downloads/HOSHIMI_IIMURA_MANAMI_LV0_PHARMACY_INTRO_CN_REVIEW.md")
EVENTS = ROOT / "data/staff/pharmacist_manami/events.json"
PROFILE = ROOT / "data/staff/pharmacist_manami/profile.json"
EVENT_ID = "intro_pharmacist_manami"
PREFIX = f"collections.character_events.{EVENT_ID}."

ENGLISH = {
    "0001": "Behind the pharmacy window, a young woman is checking the medication register. She looks up and notices an unfamiliar male doctor at the entrance.",
    "0002": "She is striking, with a bright, natural smile.",
    "0003": "Oh, a new face! You must be a doctor who just joined the hospital, right?",
    "0004": "That's right. I'm Ryuji Sakaguchi, from surgery. I came by today to get acquainted with the pharmacy department.",
    "0005": "Welcome, welcome! I'm Manami Iimura, the pharmacist. I look forward to working with you!",
    "0006": "Likewise. It's nice to meet you.",
    "0007": "She speaks brightly, and her smile is lovely. Sakaguchi only meant to stop by and say hello, but her warmth makes him want to keep talking.",
    "0008": "Ms. Iimura, is the pharmacy department usually busy? Is the workload hard?",
    "0009": "Hehe, are you asking because you care about me, or are you checking whether our pharmacy slows down your surgery department?",
    "0010": "The first one, of course. I'm new here, so I want to learn more about my colleagues' work.",
    "0011": "I see. Dr. Sakaguchi is quite thoughtful, then.",
    "0012": "Actually, we're a little different from an ordinary hospital's outpatient pharmacy. We don't dispense all that many prescriptions directly to outpatients. Most of our work is for inpatients, major treatments, and surgeries.",
    "0013": "Sounds like I'll be asking you for help pretty often, then.",
    "0014": "You bet. Preoperative medication, anesthesia-related drugs, things needed during surgery, and pain relief afterward... Once surgery gets busy, we don't get a moment's rest over here.",
    "0015": "She smiles and points to the register in front of the service window.",
    "0016": "But let me make one thing clear. You're in charge of operating, and I'm in charge of stopping you when you operate way out of line.",
    "0017": "...Operating on a patient, or writing a prescription?",
    "0018": "Hehe, both!",
    "0019": "By the way, your surgery department's anesthesia arrangements are pretty interesting.",
    "0020": "How so?",
    "0021": "General anesthesia, local anesthesia, sometimes no anesthesia at all... In the end, it feels like the surgeon-in-charge decides everything with a single word.",
    "0022": "...Is that a problem?",
    "0023": "Hehe, not really. It's just that when you surgeons make a decision, our pharmacy often ends up rushing around to keep up.",
    "0024": "She pauses, then gives him a slightly sly smile.",
    "0025": "But I am curious. For the same surgery, how different is the experience for a patient who's awake versus asleep?",
    "0026": "Actually, I've been researching pain relief lately, too.",
    "0027": "A new drug?",
    "0028": "It's too early for that; I'm only exploring a few research directions. Especially when a patient stays awake, I wonder if there's a way to make the whole process less unpleasant.",
    "0029": "That sounds well worth studying.",
    "0030": "Right? I think so, too!",
    "0031": "She looks genuinely pleased.",
    "0032": "Maybe one day I really will be able to help with one of your surgeries, Dr. Sakaguchi!",
    "0033": "Then maybe sometime, if there's an opportunity, I could invite you to come see the operating room.",
    "0034": "Huh? The operating room?",
    "0035": "She freezes for a moment, then sticks out her tongue with a sheepish grin.",
    "0036": "Oh, I'd rather have the nurses come here to pick up their medications. The operating room... I'm not quite brave enough to go in there yet.",
    "0037": "So there are things Ms. Iimura isn't good at, after all.",
    "0038": "Of course! I became a pharmacist specifically so I wouldn't have to stand beside an operating table all day!",
    "0039": "She laughs and waves her hand.",
    "0040": "So, I'll leave the surgery to you, Dr. Sakaguchi, and the medication to me!",
}


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    marker = re.compile(
        r"【演出节点 IM0-(\d{4})｜([^】]+)】\s*\n(.*?)(?=\n\s*(?:【演出节点|【立绘切换|【事件结束|---)|\Z)",
        re.S,
    )
    matches = marker.findall(source)
    if len(matches) != 40 or set(ENGLISH) != {row[0] for row in matches}:
        raise ValueError(f"Expected 40 authored beats with translations; parsed {len(matches)}")

    profile = read_json(PROFILE)
    portraits = profile["visuals"]["portraits"]
    expressions = {"smile", "playful", "professional", "thoughtful", "bright", "surprised"}
    for expression in expressions:
        key = f"pharmacist/pharm_{expression}"
        path = f"assets/characters/portrait_pack_v10/pharmacist_manami/pharmacist/pharm_{expression}.png"
        if not (ROOT / path).is_file():
            raise FileNotFoundError(path)
        portraits[key] = path

    nodes = []
    for index, (number, meta, block) in enumerate(matches):
        line = next((item.strip() for item in block.splitlines() if item.strip()), "")
        prefix = re.match(r"^(旁白|飯村真奈美|坂口隆司)：\s*", line)
        if prefix is None:
            raise ValueError(f"Cannot parse source line IM0-{number}: {line}")
        role = prefix.group(1)
        text = line[prefix.end():]
        if role != "旁白" and text.startswith("「") and text.endswith("」"):
            text = text[1:-1]
        expression_match = re.search(r"(?:当前饭村|本句表情)=(pharm_[a-z]+)", meta)
        if expression_match is None:
            raise ValueError(f"Missing authored expression at IM0-{number}")
        node_id = f"im0_{number}"
        speaker = {"旁白": "narrator", "坂口隆司": "player", "飯村真奈美": "actor"}[role]
        node = {
            "id": node_id,
            "speaker": speaker,
            "actor_id": "pharmacist_manami",
            "outfit": "pharmacist",
            "expression": expression_match.group(1),
            "text": text,
            "choices": [{
                "id": f"continue_{node_id}" if index < len(matches) - 1 else f"finish_{node_id}",
                "label": "继续  ▷" if index < len(matches) - 1 else "结束  ▷",
                "next": f"im0_{int(number) + 1:04d}" if index < len(matches) - 1 else "@end",
                "effects": {"affection": 0, "familiarity": 0},
                "flags": ["met_pharmacist_manami"] if index == len(matches) - 1 else [],
            }],
        }
        nodes.append(node)

    event_list = read_json(EVENTS)
    event = next(row for row in event_list if row.get("id") == EVENT_ID)
    event.update({
        "title": "第一次走进药房",
        "target_level": 1,
        "teaser": "药房窗口后，一名年轻女性正在核对药品登记。",
        "start": "im0_0001",
        "nodes": nodes,
    })
    event["gallery"]["caption"] = "第一次走进药房"

    EVENTS.write_text(json.dumps(event_list, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    PROFILE.write_text(json.dumps(profile, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    for locale, is_english in (("en", True), ("zh_CN", False)):
        path = ROOT / f"data/localization/{locale}.json"
        document = read_json(path)
        strings = document.setdefault("strings", {})
        for key in [key for key in strings if key.startswith(PREFIX + "nodes.")]:
            del strings[key]
        title = "First Visit to the Pharmacy" if is_english else "第一次走进药房"
        strings[PREFIX + "title"] = title
        strings[PREFIX + "teaser"] = (
            "A young woman behind the pharmacy window is checking the medication register."
            if is_english else "药房窗口后，一名年轻女性正在核对药品登记。"
        )
        strings[PREFIX + "gallery.caption"] = title
        for (number, _meta, _block), node in zip(matches, nodes, strict=True):
            strings[f"{PREFIX}nodes.{node['id']}.text"] = ENGLISH[number] if is_english else node["text"]
            choice = node["choices"][0]
            strings[f"{PREFIX}nodes.{node['id']}.choices.{choice['id']}.label"] = (
                ("Continue  ▷" if number != "0040" else "Finish  ▷")
                if is_english else choice["label"]
            )
        path.write_text(json.dumps(document, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print("Imported 40 original dialogue beats, six mapped expressions, and bilingual localization.")


if __name__ == "__main__":
    main()
