#!/usr/bin/env python3
"""Build Miyuki Lv5 event data from the approved, numbered CN/EN manuscripts."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CN = ROOT / "research/source_scripts/HOSHIMI_ASAKURA_MIYUKI_LV5_MY_TURN_ON_THE_TABLE_CN_CODEX_READY_V4.md"
EN = ROOT / "research/translations/miyuki_lv5_en_working.md"
OUT = ROOT / "data/staff/nurse_yui/lv5_events.json"
LOC = ROOT / "data/localization/en.json"
CHOICES = {
    "030": [("A", "朝倉，你不是说今天准备了安抚方案吗？", "Asakura, didn't you say you had a way to reassure her today?", "031A"),
            ("B", "现在后悔加麻醉还不算丢人，相模大野小姐。", "It's no disgrace to change your mind about anesthesia now, Miss Sagamiono.", "031B")],
    "108": [("A", "不怕我真把腕带扣紧了？", "Aren't you afraid I'll really tighten the wrist straps?", "109A"),
            ("B", "今天怎么突然想通要换位置了？", "What made you decide to switch places today?", "109B")],
    "143": [("A", "真上了手术台，到时候求饶可没用。", "Once you're really on the operating table, begging for mercy won't help.", "144A"),
            ("B", "这不是闹着玩的，之后我们按正式流程好好商量术式。", "This isn't a game. We'll discuss the procedure properly through the formal process later.", "144B")],
}
SPEAKERS = {
    "朝倉美幸": ("nurse_yui", "Miyuki Asakura"),
    "相模大野千惠": ("chie", "Chie Sagamiono"),
    "坂口隆司": ("player", "Ryuji Sakaguchi"),
    "石神千鹤": ("nurse_ishigami", "Chizuru Ishigami"),
    "年轻护士": ("young_nurse", "Young Nurse"),
}
EN_LABELS = {v[1] for v in SPEAKERS.values()} | {"Sagamiono Chie", "Asakura Miyuki", "Ishigami Chizuru"}
CHIE = "assets/characters/patient_sagamiono_chie_lv5_v1"
PART_A_CG_RANGES = (
    (2, 5, "assets/events/character_events/miyuki/lv5_story/cg/chie_or_arrival_v1.png"),
    (34, 45, "assets/events/character_events/miyuki/lv5_story/cg/chie_preincision_controller_reveal_sfw_v1.png"),
    (46, 46, "assets/events/character_events/miyuki/lv5_story/cg/chie_controller_handoff_splash_sfw_v1.png"),
    (55, 56, "assets/events/character_events/miyuki/lv5_story/cg/chie_first_incision_closeup_v1.png"),
    (58, 67, "assets/events/character_events/miyuki/lv5_story/cg/chie_open_abdomen_endurance_sfw_v1.png"),
    (70, 72, "assets/events/character_events/miyuki/lv5_story/cg/chie_postop_controller_recovery_sfw_v3.png"),
)
PART_B_CG_RANGES = (
    (91, 95, "assets/events/character_events/miyuki/lv5_story/cg/miyuki_b1_or_door_invitation_sfw_v1.png"),
    (102, 108, "assets/events/character_events/miyuki/lv5_story/cg/miyuki_b2_patient_view_demonstration_sfw_v1.png"),
    (109, 126, "assets/events/character_events/miyuki/lv5_story/cg/miyuki_b3_surgical_lamp_confession_sfw_v1.png"),
    (131, 145, "assets/events/character_events/miyuki/lv5_story/cg/miyuki_b5_true_surgery_request_sfw_v1.png"),
    (146, 149, "assets/events/character_events/miyuki/lv5_story/cg/miyuki_b6_departure_promise_sfw_v1.png"),
)
MIXED_ACTORS = {
    "025": "nurse_yui", "032B": "chie", "033B": "nurse_yui",
    "127": "nurse_yui", "141": "player", "143": "nurse_yui",
    "145A": "nurse_yui", "145B": "nurse_yui", "149": "nurse_yui",
    "165": "nurse_yui", "168": "nurse_yui", "169": "player",
}


def part_a_cg(nid):
    number = int(nid[:3])
    for start, end, path in PART_A_CG_RANGES:
        if start <= number <= end:
            return path
    return ""


def part_b_cg(nid):
    number = int(nid[:3])
    for start, end, path in PART_B_CG_RANGES:
        if start <= number <= end:
            return path
    return ""


def nodes(path):
    raw = path.read_text()
    pattern = r"(?ms)^\*\*\[([0-9]{3}[AB]?)\]\*\*\s*\n(.*?)(?=^\*\*\[[0-9]{3}[AB]?\]\*\*|^#{1,4} |^---\s*$|^> |\Z)"
    result = {}
    for nid, body in re.findall(pattern, raw):
        body = body.strip()
        if not body:
            raise ValueError(f"Blank {nid} in {path}")
        result[nid] = body
    return result


def split_speaker(cn, en, nid):
    for label, (actor, english) in SPEAKERS.items():
        if cn.startswith(label + "：\n"):
            cn = cn[len(label) + 2:]
            en_lines = en.split("\n", 1)
            if len(en_lines) != 2 or en_lines[0].removesuffix(":") not in EN_LABELS:
                raise ValueError(f"English speaker mismatch at {nid}: {en_lines[0]}")
            return actor, label, english, cn, en_lines[1]
    return "narrator", "旁白", "Narrator", cn, en


def fragments(cn_source, en_source, nid):
    actor, label, label_en, cn, en = split_speaker(cn_source, en_source, nid)
    if nid not in MIXED_ACTORS:
        return [(actor, label, label_en, cn, en)]
    quote_actor = MIXED_ACTORS[nid]
    quote_label = next(k for k, v in SPEAKERS.items() if v[0] == quote_actor)
    quote_label_en = SPEAKERS[quote_label][1]
    left, right = cn.find("「"), cn.rfind("」") + 1
    en_left, en_right = en.find('"'), en.rfind('"') + 1
    if min(left, en_left) < 0 or right <= left or en_right <= en_left or en.count('"') != 2:
        raise ValueError("Cannot split mixed narrator/actor line at " + nid)
    result = []
    if cn[:left].strip() or en[:en_left].strip():
        result.append(("narrator", "旁白", "Narrator", cn[:left].strip(), en[:en_left].strip()))
    result.append((quote_actor, quote_label, quote_label_en, cn[left:right], en[en_left:en_right]))
    if cn[right:].strip() or en[en_right:].strip():
        result.append(("narrator", "旁白", "Narrator", cn[right:].strip(), en[en_right:].strip()))
    return result


def main():
    cn_nodes, en_nodes = nodes(CN), nodes(EN)
    if len(cn_nodes) != 177 or list(cn_nodes) != list(en_nodes):
        raise ValueError("CN/EN node alignment mismatch")
    loc = json.loads(LOC.read_text())
    strings = loc["strings"]
    for key in list(strings):
        if key.startswith("collections.character_events.miyuki_lv5_"):
            del strings[key]
    events = []
    specs = [
        ("miyuki_lv5_chie_operation", "相模大野千惠的四小时无麻醉大考验", "Chie Sagamiono's Four-Hour Ordeal Without Anesthesia", "001", "081", "day_start", "operating_room", 300, "contextual", 90),
        ("miyuki_lv5_my_turn_on_the_table", "换我躺一次", "My Turn on the Table", "082", "149", "after_work", "operating_room", 0, "rank_up", 120),
        ("miyuki_lv5_capable_do_more", "能者多劳", "The Capable Do More", "150", "169", "location", "nurses_station", 0, "contextual", 100),
    ]
    ids = list(cn_nodes)
    for eid, title, title_en, start, end, trigger, bg, minutes, category, priority in specs:
        part_ids = ids[ids.index(start):ids.index(end) + 1]
        event = {
            "id": eid, "actor_id": "nurse_yui", "title": title, "teaser": title,
            "chapter": 5, "location_id": "station" if trigger != "day_start" else "or",
            "trigger_mode": trigger, "background_id": bg, "outfit": "sterile" if start == "001" else "uniform",
            "minutes": minutes, "time_start": 540 if trigger != "after_work" else 1020,
            "time_end": 540 if trigger == "day_start" else (1320 if trigger == "after_work" else 1020),
            "priority": priority, "category": category, "auto_start": trigger != "location",
            "target_level": 5, "benefit_id": "unlock_clinical_practice_patient" if category == "rank_up" else "",
            "chain_followup": category == "rank_up", "cinematic": True,
            "conditions": {"min_day": 1, "min_affection": 0, "min_familiarity": 0,
                "required_events": [] if start == "001" else (["miyuki_lv5_chie_operation"] if start == "082" else ["miyuki_lv5_my_turn_on_the_table"]),
                "days_after_required_events": 0 if start == "001" else 1,
                "special_requirements": ([{"type": "story_flag", "flag": "staff_as_patient_program_authorized"}] if start == "001" else
                    [{"type": "story_flag", "flag": "asakura_lv5_part_b_pending"}] if start == "082" else
                    [{"type": "story_flag", "flag": "asakura_lv5_epilogue_pending"}])},
            "start": "n" + start.lower(), "nodes": []
        }
        prefix = f"collections.character_events.{eid}"
        strings[prefix + ".title"] = title_en
        strings[prefix + ".teaser"] = title_en
        for i, nid in enumerate(part_ids):
            pieces = fragments(cn_nodes[nid], en_nodes[nid], nid)
            scene_bg = "or_entrance" if start == "082" and int(nid[:3]) <= 94 else bg
            next_id = "@end" if nid == end else "n" + part_ids[i + 1].lower()
            if nid.endswith("A") or nid.endswith("B"):
                if nid[:3] in ("033", "111", "145"):
                    next_id = "n" + {"033": "034", "111": "112", "145": "146"}[nid[:3]]
            for piece_index, (actor, label, label_en, cn, en) in enumerate(pieces):
                node_id = "n" + nid.lower() + ("_s" + str(piece_index + 1) if piece_index else "")
                piece_next = "n" + nid.lower() + "_s" + str(piece_index + 2) if piece_index < len(pieces) - 1 else next_id
                node = {"id": node_id, "presentation": "authored",
                    "speaker": "narrator" if actor == "narrator" else ("player" if actor == "player" else "actor"),
                    "actor_id": actor if actor not in ("narrator", "chie", "young_nurse") else "nurse_yui",
                    "text": cn, "speaker_label": label, "background_id": scene_bg,
                    "outfit": "sterile" if start == "001" else "uniform",
                    "expression": "neutral", "choices": []}
                if actor in ("narrator", "player"):
                    node["hide_portrait"] = True
                elif actor == "chie":
                    node["portrait_path"] = CHIE + ("/intraoperative/pain.png" if 33 <= int(nid[:3]) <= 72 else "/intraoperative/tense.png")
                elif actor == "young_nurse":
                    node["young_nurse_cast"] = True
                elif actor == "nurse_yui":
                    node["expression"] = "warm" if start == "001" else "neutral"
                if start == "001":
                    cg_path = part_a_cg(nid)
                    if cg_path:
                        node["cg_path"] = cg_path
                        node["cg_fit"] = "cover"
                elif start == "082":
                    cg_path = part_b_cg(nid)
                    if cg_path:
                        node["cg_path"] = cg_path
                        node["cg_fit"] = "cover"
                if nid in CHOICES and piece_index == len(pieces) - 1:
                    for suffix, cn_label, en_label, target in CHOICES[nid]:
                        cid = "choose_" + nid.lower() + suffix.lower()
                        node["choices"].append({"id": cid, "label": cn_label, "next": "n" + target.lower(),
                            "effects": {"affection": 0, "familiarity": 0}, "flags": []})
                        strings[f"{prefix}.nodes.{node_id}.choices.{cid}.label"] = en_label
                else:
                    cid = "continue_" + node_id
                    node["choices"].append({"id": cid, "label": "继续", "next": piece_next,
                        "effects": {"affection": 0, "familiarity": 0}, "flags": []})
                    strings[f"{prefix}.nodes.{node_id}.choices.{cid}.label"] = "Continue"
                event["nodes"].append(node)
                strings[f"{prefix}.nodes.{node_id}.text"] = en
                strings[f"{prefix}.nodes.{node_id}.speaker_label"] = label_en
        events.append(event)
    OUT.write_text(json.dumps(events, ensure_ascii=False, indent=2) + "\n")
    LOC.write_text(json.dumps(loc, ensure_ascii=False, indent=2) + "\n")
    print("Imported", [len(x["nodes"]) for x in events], "CN/EN nodes")


if __name__ == "__main__":
    main()
