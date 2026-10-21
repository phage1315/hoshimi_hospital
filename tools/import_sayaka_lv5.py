#!/usr/bin/env python3
"""Import the authored Sayaka Lv5 script into the existing special-event data model.

The Markdown remains the canonical Chinese source. This is a mechanical adapter:
it extracts only player-visible node text and authored branch text, while
discarding editor-only staging directions.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "docs/sources/HOSHIMI_NANJOU_SAYAKA_LV5_V3_FULL_CN_REVIEW.md"
EVENT_IDS = {
    "A": "sayaka_lv5_part_a",
    "B": "sayaka_lv5_part_b",
    "C": "sayaka_lv5_part_c",
}
ACTORS = {
    "南条小夜香": ("doc_sayaka", "南条小夜香"),
    "坂口隆司": ("player", "坂口隆司"),
    "深山佳織": ("doc_rei", "深山佳織"),
    "杉村弘子": ("nurse_hiroko", "杉村弘子"),
    "本庄萌恵": ("nurse_moe", "本庄萌恵"),
    "城宮明日香": ("doc_asuka", "城宮明日香"),
    "城宮明日香（门内）": ("doc_asuka", "城宮明日香（门内）"),
}
CG_PATHS = {
    "CG_A_SAYAKA_OR_ROLEPLAY_AFTERGLOW": "assets/events/character_events/sayaka/lv5_story/CG_SAYAKA_PART_A.png",
    "CG_B_SAYAKA_SURGERY_TEAM_POV_SFW": "assets/events/character_events/sayaka/lv5_story/CG_A_SAYAKA_SURGERY_POV_SFW.png",
    "CG_C_ASUKA_OFFICE_MEETING_SFW": "assets/events/character_events/sayaka/lv5_story/CG_C_ASUKA_OFFICE_MEETING_SFW.png",
}
CAP_PATHS = {
    "cap_neutral": "base",
    "cap_smile": "smile",
    "cap_mischief": "mischief",
    "cap_blush": "blush",
    "cap_roleplay_fear": "roleplay_fear",
    "cap_real_fear": "real_fear",
    "cap_exhausted": "exhausted",
    "cap_pain_shout": "pain_shout",
    "cap_pain_endure": "pain_endure",
    "cap_soft": "soft",
    "cap_relieved": "relieved",
}


def dump(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def background_for(place: str) -> str:
    if "走廊" in place or "工作区" in place:
        return "hallway"
    if "院长办公室" in place:
        return "director_office"
    if "坂口办公室" in place:
        return "player_office"
    if "病房" in place:
        return "ward"
    return "operating_room"


def node_id_for(source_id: str) -> str:
    return re.sub(r"[^a-z0-9_]+", "_", source_id.lower()).strip("_")


def sayaka_visual(expression: str) -> dict:
    if expression == "portrait_hidden_hair_down":
        return {"actor_id": "doc_sayaka", "hide_portrait": True}
    if expression in CAP_PATHS:
        return {
            "actor_id": "doc_sayaka",
            "portrait_path": f"assets/characters/relationship_patient_v1/doc_sayaka/lv5_operating_table/{CAP_PATHS[expression]}.png",
            "portrait_right": 1150,
            "portrait_y": 175,
            "portrait_scale": 0.82,
        }
    mood = expression.removeprefix("work_")
    outfit = "white_coat"
    outfit_map = {"mischief": "teasing", "blush": "shy", "smile": "smile", "neutral": "neutral", "serious": "serious", "uneasy": "shy", "relief": "smile"}
    return {"actor_id": "doc_sayaka", "outfit": outfit, "expression": outfit_map.get(mood, "neutral")}


def actor_visual(actor_id: str, expression: str) -> dict:
    if "不出立绘" in expression:
        return {"actor_id": actor_id, "hide_portrait": True}
    if actor_id == "doc_sayaka":
        return sayaka_visual(expression)
    if actor_id == "player":
        return {"hide_portrait": True}
    if actor_id == "doc_asuka":
        outfit = "white_coat"
        mood_map = {"asuka_bright": "warm", "asuka_curious": "smile", "asuka_decisive": "worried"}
        return {"actor_id": actor_id, "outfit": outfit, "expression": mood_map.get(expression, "neutral")}
    if actor_id == "nurse_hiroko":
        outfit = "uniform"
        mood_map = {"nurse_concerned": "worried", "nurse_nervous": "worried", "nurse_professional": "serious", "nurse_relief": "smile", "nurse_small_smile": "smile", "nurse_smile": "smile", "or_scrub_nurse_masked": "focused", "or_circulating_scrubs_masked": "focused"}
        if expression.startswith("or_"):
            outfit = "sterile"
        return {"actor_id": actor_id, "outfit": outfit, "expression": mood_map.get(expression, "neutral")}
    if actor_id == "nurse_moe":
        outfit = "uniform"
        mood_map = {"nurse_concerned": "worried", "nurse_nervous": "worried", "nurse_professional": "serious", "nurse_relief": "smile", "nurse_small_smile": "smile", "nurse_smile": "smile", "or_circulating_scrubs_masked": "focused"}
        if expression.startswith("or_"):
            outfit = "sterile"
        return {"actor_id": actor_id, "outfit": outfit, "expression": mood_map.get(expression, "neutral")}
    if actor_id == "doc_rei":
        mood_map = {"work_alarmed": "worried", "work_dry_humor": "smile", "work_serious": "serious", "work_thoughtful": "serious", "or_scrubs_masked_presterile": "focused", "or_surgeon_gown_masked": "focused"}
        outfit = "sterile" if expression.startswith("or_") else "white_coat"
        return {"actor_id": actor_id, "outfit": outfit, "expression": mood_map.get(expression, "neutral")}
    return {"actor_id": actor_id, "outfit": "white_coat", "expression": "neutral"}


def parse_nodes(text: str) -> tuple[list[dict], dict[str, str]]:
    node_pattern = re.compile(r"^【演出节点 ([A-Z]\d\d-(?:[A-Z0-9]+-)?\d{3,4})｜([^】]+)】\s*\n([^\n]+)", re.MULTILINE)
    nodes: list[dict] = []
    raw_nodes: dict[str, str] = {}
    scene_place = re.search(r"【场景状态 [A-Z]\d\d】地点：([^；\n]+)", text)
    current_background = background_for(scene_place.group(1).strip()) if scene_place else "hallway"
    for match in node_pattern.finditer(text):
        source_id, metadata, body = match.groups()
        runtime_id = node_id_for(source_id)
        meta: dict[str, str] = {}
        for part in metadata.split("｜"):
            if "=" in part:
                key, value = part.split("=", 1)
                meta[key] = value
        if meta.get("地点"):
            current_background = background_for(meta["地点"])
        body = body.strip()
        speaker_match = re.match(r"^([^：:]+)[：:](.*)$", body)
        if speaker_match:
            source_speaker, visible_text = speaker_match.groups()
        else:
            source_speaker, visible_text = "旁白", body
        actor_id, speaker_label = ACTORS.get(source_speaker, ("", source_speaker))
        sayaka_expression = meta.get("当前小夜香", "work_neutral").split("｜", 1)[0]
        actor_expression = meta.get("本句立绘/表情", sayaka_expression)
        node = {
            "id": runtime_id,
            "speaker": "actor" if actor_id and actor_id != "player" else ("player" if actor_id == "player" else "narrator"),
            "speaker_label": speaker_label,
            "text": visible_text.strip(),
            "expression": "neutral",
            "background_id": current_background,
            "hide_portrait": False,
            "choices": [{"id": runtime_id + "_next", "label": "继续", "next": "", "requirements": []}],
        }
        if actor_id:
            if actor_id == "player" and (sayaka_expression.startswith("cap_") or sayaka_expression.startswith("work_")):
                node.update(sayaka_visual(sayaka_expression))
            else:
                node.update(actor_visual(actor_id, actor_expression))
                if actor_id not in ["doc_sayaka", "player"]:
                    secondary = sayaka_visual(sayaka_expression)
                    if secondary.get("portrait_path"):
                        node["secondary_portrait_path"] = secondary["portrait_path"]
                        node["secondary_portrait_right"] = 645
                        node["secondary_portrait_y"] = 245
                        node["secondary_portrait_scale"] = 0.62
                    elif secondary.get("actor_id") == "doc_sayaka":
                        node["secondary_actor_id"] = "doc_sayaka"
                        node["secondary_outfit"] = secondary.get("outfit", "white_coat")
                        node["secondary_expression"] = secondary.get("expression", "neutral")
        elif sayaka_expression.startswith(("cap_", "work_", "portrait_hidden_")):
            node.update(sayaka_visual(sayaka_expression))
        cg_name = meta.get("当前CG", "")
        if cg_name:
            node["cg_path"] = CG_PATHS[cg_name]
            node["cg_fit"] = "cover"
        nodes.append(node)
        raw_nodes[source_id] = visible_text.strip()
    return nodes, raw_nodes


def add_choice_branch(nodes: list[dict], source: str) -> None:
    marker = re.search(r"【选择节点 A01-CHOICE[^】]*】([\s\S]*?)(?=\n---|\n## A02\.)", source)
    if not marker or not nodes:
        raise ValueError("Could not find the exact A01 authored choices")
    choices = []
    branch_nodes = []
    for option, speaker1, line1, speaker2, line2, target in re.findall(
        r"- \*\*「([^」]+)。」\*\* → ([^：]+)：([^　\n]+)\s*\n\s*([^：]+)：([^\n]+)→ (进入 A02|返回正常工作日结束入口)",
        marker.group(1),
    ):
        is_accept = target == "进入 A02"
        first_id = "a01_accept_sakaguchi" if is_accept else "a01_decline_sakaguchi"
        second_id = "a01_accept_sayaka" if is_accept else "a01_decline_sayaka"
        choices.append({"id": "accept" if is_accept else "decline", "label": option + "。", "next": first_id, "requirements": []})
        next_id = "a02_0001" if is_accept else "@cancel"
        branch_nodes.extend([
            {"id": first_id, "speaker": "player", "speaker_label": speaker1.strip(), "hide_portrait": True, "expression": "neutral", "text": line1.strip(), "background_id": "hallway", "choices": [{"id": first_id + "_next", "label": "继续", "next": second_id, "requirements": []}]},
            {"id": second_id, "speaker": "actor", "actor_id": "doc_sayaka", "speaker_label": speaker2.strip(), "outfit": "white_coat", "expression": "teasing" if is_accept else "smile", "text": line2.split("→")[0].strip(), "background_id": "hallway", "choices": [{"id": second_id + "_next", "label": "继续", "next": next_id, "requirements": []}]},
        ])
    if len(choices) != 2:
        raise ValueError("Expected the two authored A01 choices and their four dialogue lines")
    nodes[-1]["choices"] = choices
    last_a01 = len(nodes)
    nodes[last_a01:last_a01] = branch_nodes


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    sections = list(re.finditer(r"^## ([ABC])(\d\d)\. ([^\n]+)", source, re.MULTILINE))
    scene_nodes: dict[str, list[dict]] = {}
    all_ids: set[str] = set()
    for index, header in enumerate(sections):
        section_end = sections[index + 1].start() if index + 1 < len(sections) else source.find("## 4. 结算与演出 QA", header.end())
        if section_end < 0:
            section_end = len(source)
        block = source[header.start():section_end]
        nodes, _ = parse_nodes(block)
        if not nodes:
            raise ValueError(f"No authored player-visible nodes parsed for {header.group(1)}{header.group(2)}")
        if any(node["id"] in all_ids for node in nodes):
            raise ValueError("Duplicate authored node ID")
        all_ids.update(node["id"] for node in nodes)
        scene_nodes[header.group(1) + header.group(2)] = nodes
    if len(sections) != 16 or len(all_ids) != 636:
        raise ValueError(f"Source audit failed: found {len(sections)} scenes and {len(all_ids)} authored nodes (expected 16/636 for V3)")

    a_section_start = source.index("【选择节点 A01-CHOICE")
    a_section_end = source.index("## A02.", a_section_start)
    add_choice_branch(scene_nodes["A01"], source[a_section_start:a_section_end])
    # The source-authored branches precede A02 in playback order.
    a_nodes = scene_nodes["A01"] + sum((scene_nodes[key] for key in ["A02", "A03", "A04"]), [])
    b_nodes = sum((scene_nodes[key] for key in [f"B{i:02d}" for i in range(1, 9)]), [])
    c_nodes = sum((scene_nodes[key] for key in [f"C{i:02d}" for i in range(1, 5)]), [])

    def connect(nodes: list[dict], ending: str = "@day_end") -> list[dict]:
        for left, right in zip(nodes, nodes[1:]):
            choices = left.get("choices", [])
            if len(choices) == 1 and choices[0]["next"] == "":
                choices[0]["next"] = right["id"]
        if nodes[-1].get("choices", [{}])[0].get("next", "") == "":
            nodes[-1]["choices"][0]["next"] = ending
        return nodes

    connect(a_nodes)
    connect(b_nodes)
    connect(c_nodes)
    # V3 updates only authored nodes. Keep the tested event gates, rewards,
    # registration and scene clocks; never rebuild unrelated runtime metadata.
    step_file = ROOT / "data/events/special_event_steps/sayaka_lv5.json"
    steps = json.loads(step_file.read_text(encoding="utf-8"))
    for step, nodes in zip(steps, [a_nodes, b_nodes, c_nodes]):
        assert step["id"] == EVENT_IDS[nodes[0]["id"][0].upper()] + "_main"
        step["nodes"] = nodes
    next(n for n in a_nodes if n["id"] == "a03_h_0001")["exit_blackout_seconds"] = 1.0
    # User's later direction overrides the draft's old C02 CG cue.
    c_opening = next(n for n in c_nodes if n["id"] == "c02_0001")
    c_later = next(n for n in c_nodes if n["id"] == "c03_0038")
    for key in ["cg_path", "cg_fit"]:
        c_later[key] = c_opening.pop(key)
    dump(step_file, steps)
    print(f"Refreshed V3: 16 scenes / {len(all_ids)} source nodes plus 4 branch lines; A={len(a_nodes)}, B={len(b_nodes)}, C={len(c_nodes)}")


if __name__ == "__main__":
    main()
