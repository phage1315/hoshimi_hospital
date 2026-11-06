#!/usr/bin/env python3
"""Import user supplied Daydream Markdown without editing authored prose.

The importer only maps the existing node markers to the Daydream JSON contract.
It keeps the source text verbatim, records the source node id, and adds a
mechanical Continue edge between adjacent authored nodes.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOWNLOADS = Path("/Users/ningye/Downloads")
SOURCES = [
    (DOWNLOADS / "HOSHIMI_FANTASY_01_HIROKO_EMIKO_OR_V1.md", "FANTASY_HIROKO_EMIKO_OR_01", "dark", ["nurse_hiroko", "doc_emiko"]),
    (DOWNLOADS / "HOSHIMI_FANTASY_02_CHIHAYA_PREOP_OR_V1_2.md", "FANTASY_CHIHAYA_PREOP_OR_01", "intense", ["patient_chihaya"]),
    (DOWNLOADS / "HOSHIMI_FANTASY_03_MIZUHO_OR_SOLO_V1.md", "FANTASY_MIZUHO_OR_SOLO_01", "dark", ["guest_mizuho"]),
]

def catalog_metadata(cast: list[str]) -> dict:
    """Player-facing names; the current acquaintance rule supersedes draft gates."""
    translations = json.loads((ROOT / "data/localization/en.json").read_text(encoding="utf-8"))["strings"]
    names = {locale: [] for locale in ["zh_CN", "en"]}
    for actor in cast:
        profile = json.loads((ROOT / "data/staff" / actor / "profile.json").read_text(encoding="utf-8"))
        names["zh_CN"].append(profile["name"])
        names["en"].append(translations[f"collections.staff.{actor}.name"])
    return {
        "gate": {"met": cast},
        "cast": {"zh_CN": "、".join(names["zh_CN"]), "en": ", ".join(names["en"])},
        "tags": {"zh_CN": "办公室白日梦", "en": "Office daydream"},
        "unlock_hint": {"zh_CN": "与" + "、".join(names["zh_CN"]) + "相识即可解锁。", "en": "Unlocks after meeting " + " and ".join(names["en"]) + "."},
    }
NODE_RE = re.compile(r"^\*\*(F\d+_\d+)\*\*\s*$")
TAG_RE = re.compile(r"\[([A-Z_]+):\s*([^\]]+)\]")
SPEAKER_RE = re.compile(r"^`\[([A-Z_]+)\]`(?:\s+.*)?\s*$")
META_RE = re.compile(r"^\s*(event_id|title_cn|character|unlock_gate|time_cost|total_nodes):\s*(.+)$")
HEADING_RE = re.compile(r"^#{1,6}\s+")
SPEAKER_IDS = {
    "SAKAGUCHI": ("player", "坂口隆司"), "NARRATOR": ("narrator", "旁白"),
    "HIROKO": ("nurse_hiroko", "杉村弘子"), "EMIKO": ("doc_emiko", "御堂江美子"),
    "MANAMI": ("pharmacist_manami", "饭村真奈美"), "MIKA": ("nurse_rin", "中井美佳"),
    "CHIHAYA": ("patient_chihaya", "仓本千早"), "CHIZURU": ("nurse_ishigami", "石神千鹤"),
    "MIZUHO": ("guest_mizuho", "瑞穗"), "SAYAKA": ("doc_sayaka", "南条小夜香"),
}
BACKGROUND_MAP = {
    "player_office_evening": "player_office", "player_office_afternoon": "player_office",
    "player_office": "player_office", "player_office_fantasy": "player_office",
    "operating_room": "operating_room", "operating_room_bright": "operating_room",
    "operating_room_night": "operating_room",
    "single_ward_evening": "ward", "nurse_station_night": "nurses_station",
}
SPRITE_PATHS = {
    # Chihaya's supplied ward differential is the authored daydream sprite.
    ("patient_chihaya", "chihaya_pajamas_surprised"): "assets/characters/patient_chihaya_second_surgery_v1/ward/surprised.png",
    # The daydream asks for an ordinary Chizuru portrait; use her registered
    # uniform portrait rather than inventing a clipboard-specific asset.
    ("nurse_ishigami", "chizuru_serious_clipboard"): "assets/characters/portrait_pack_v22/nurse_ishigami/uniform/neutral.png",
    ("nurse_hiroko", "hiroko_normal"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/neutral.png",
    ("nurse_hiroko", "hiroko_smile_clipboard"): "assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/smile.png",
    ("doc_sayaka", "sayaka_smile_tease"): "assets/characters/portrait_pack_v19/doc_sayaka/white_coat/teasing.png",
    ("doc_sayaka", "sayaka_laugh"): "assets/characters/portrait_pack_v19/doc_sayaka/white_coat/smile.png",
}
CHIHAYA_EXPRESSION_PATHS = {
    # Before undressing, Chihaya is still in the supplied ward pajamas.
    "panic_blush": "assets/characters/patient_chihaya_second_surgery_v1/ward/afraid.png",
    # F02_011 finishes undressing and applies the surgical cap.  From F02_012
    # onward, both ward preparation and operating-room dialogue use Chihaya's
    # existing cap-on examination / intraoperative differential rather than
    # falling back to the pajama portraits.
    "flustered_shy": "assets/characters/patient_chihaya_second_surgery_v1/intraoperative/shy.png",
    "shocked_blush": "assets/characters/patient_chihaya_second_surgery_v1/intraoperative/surprised.png",
    "crying_blush": "assets/characters/patient_chihaya_second_surgery_v1/intraoperative/crying.png",
    "teary_flustered": "assets/characters/patient_chihaya_second_surgery_v1/intraoperative/crying.png",
    "panic_tears": "assets/characters/patient_chihaya_second_surgery_v1/intraoperative/tense.png",
    "stunned_blush": "assets/characters/patient_chihaya_second_surgery_v1/intraoperative/surprised.png",
    "peak_blush_angry": "assets/characters/patient_chihaya_second_surgery_v1/intraoperative/angry.png",
    "melted_tears": "assets/characters/patient_chihaya_second_surgery_v1/intraoperative/crying.png",
    "peak_scream": "assets/characters/patient_chihaya_second_surgery_v1/intraoperative/pain.png",
    "peak_tears": "assets/characters/patient_chihaya_second_surgery_v1/intraoperative/crying.png",
    "climax_tears": "assets/characters/patient_chihaya_second_surgery_v1/intraoperative/crying.png",
    "afterglow_dazed": "assets/characters/patient_chihaya_second_surgery_v1/intraoperative/tired.png",
}
MIZUHO_EXPRESSION_PATHS = {
    # Existing Mizuho OR variants are closest available states, not dedicated
    # files for every script-specific expression key.
    "flustered_pain": "pain",
    "shocked_blush": "surprised",
    "flustered_tears": "crying",
    "peak_blush": "shy",
    "panic_blush": "tense",
    "peak_scream": "pain",
    "crying_blush": "crying",
    "melted_tears": "crying",
    "peak_tears": "crying",
    "climax_tears": "crying",
    "afterglow_dazed": "tired",
}
EXPRESSION_PATHS = {
    "patient_chihaya": CHIHAYA_EXPRESSION_PATHS,
    "guest_mizuho": {
        key: "assets/characters/mizuho_story_v1/intraoperative/" + filename + ".png"
        for key, filename in MIZUHO_EXPRESSION_PATHS.items()
    },
}
OR_STAFF_OUTFITS = {
    "doc_emiko": "sterile",
    "pharmacist_manami": "sterile",
    "nurse_rin": "sterile",
}
HIROKO_OR_PORTRAIT = "assets/characters/relationship_patient_v1/nurse_hiroko/operating_patient/nervous.png"
HIROKO_OR_EXPRESSION_PATHS = {
    "panic_blush": "assets/characters/relationship_patient_v1/nurse_hiroko/operating_patient/panic.png",
    "羞愤_blush": "assets/characters/relationship_patient_v1/nurse_hiroko/operating_patient/indignant.png",
    "crying_blush": "assets/characters/relationship_patient_v1/nurse_hiroko/operating_patient/crying.png",
    "panic_tears": "assets/characters/relationship_patient_v1/nurse_hiroko/operating_patient/panic.png",
    "peak_blush_tears": "assets/characters/relationship_patient_v1/nurse_hiroko/operating_patient/panic.png",
    "terrified_blush": "assets/characters/relationship_patient_v1/nurse_hiroko/operating_patient/terrified.png",
    "pain_scream_blush": "assets/characters/relationship_patient_v1/nurse_hiroko/operating_patient/pain_scream.png",
    "crying_shame": "assets/characters/relationship_patient_v1/nurse_hiroko/operating_patient/overwhelmed.png",
    "peak_tears_shame": "assets/characters/relationship_patient_v1/nurse_hiroko/operating_patient/overwhelmed.png",
}
CG_PATHS = {
    "mizuho_or_laparotomy_open": "assets/events/daydream_v1/mizuho_or_laparotomy_open.png",
}
NODE_CG_CUES = {
    ("FANTASY_HIROKO_EMIKO_OR_01", "F01_013"): {
        "cg_key": "hiroko_forced_into_or",
        "cg_path": "assets/events/daydream_v1/hiroko_forced_into_or.png",
        "cg_fit": "contain",
    },
    ("FANTASY_HIROKO_EMIKO_OR_01", "F01_042"): {
        "cg_key": "hiroko_or_laparotomy_open",
        "cg_path": "assets/events/daydream_v1/hiroko_or_laparotomy_open.png",
        "cg_fit": "contain",
    },
    ("FANTASY_CHIHAYA_PREOP_OR_01", "F02_032"): {
        "cg_key": "chihaya_or_after_penetration",
        "cg_path": "assets/events/daydream_v1/chihaya_or_after_penetration.png",
        "cg_fit": "contain",
    },
}

def parse(path: Path, event_id: str, level: str, cast: list[str]) -> dict:
    lines = path.read_text(encoding="utf-8").splitlines()
    meta: dict[str, str] = {}
    for line in lines[:30]:
        match = META_RE.match(line)
        if match:
            meta[match.group(1)] = match.group(2).strip()
    title = meta.get("title_cn", event_id)
    starts = [i for i, line in enumerate(lines) if NODE_RE.match(line)]
    nodes = []
    current_background = "player_office"
    for pos, start in enumerate(starts):
        end = starts[pos + 1] if pos + 1 < len(starts) else len(lines)
        node_id = NODE_RE.match(lines[start]).group(1)
        body = lines[start + 1:end]
        while body and not body[0].strip(): body.pop(0)
        tags: dict[str, str] = {}
        speaker = "narrator"
        speaker_label = "旁白"
        text_lines: list[str] = []
        for line in body:
            for tag, value in TAG_RE.findall(line):
                tags[tag.lower()] = value.strip()
            # Directive-only lines are node metadata, not visible dialogue.
            # Keep authored prose verbatim while preventing [BG]/[SPRITE]/...
            # markers from being rendered in the VN text box.
            visible_line = re.sub(r"`?\[[A-Z_]+:\s*[^\]]+\]`?", "", line).strip()
            match = SPEAKER_RE.match(line.strip())
            if match:
                speaker, speaker_label = SPEAKER_IDS.get(match.group(1), ("narrator", match.group(1)))
                continue
            if line.strip() == "[END OF EVENT]":
                continue
            if line.startswith("`") and line.endswith("`"):
                continue
            # Markdown act headings separate authored nodes; they are not VN lines.
            if HEADING_RE.match(visible_line):
                continue
            if visible_line and not visible_line.startswith("---"):
                text_lines.append(visible_line)
        text = "\n".join(text_lines).strip()
        next_id = NODE_RE.match(lines[starts[pos + 1]]).group(1) if pos + 1 < len(starts) else "@end"
        node: dict = {
            "id": node_id, "source_node_id": node_id, "actor_id": speaker,
            "speaker_label": {"zh_CN": speaker_label, "en": speaker_label},
            "text": {"zh_CN": text, "en": text},
            "choices": [{"id": "continue" if next_id != "@end" else "end", "label": {"zh_CN": "继续" if next_id != "@end" else "结束", "en": "Continue" if next_id != "@end" else "End"}, "next": next_id}],
        }
        if "bg" in tags: current_background = BACKGROUND_MAP.get(tags["bg"], "player_office")
        node["background_id"] = current_background
        if "expr" in tags: node["expression"] = tags["expr"]
        if "sprite" in tags: node["sprite_key"] = tags["sprite"]
        if (speaker, tags.get("sprite")) in SPRITE_PATHS:
            node["portrait_path"] = SPRITE_PATHS[(speaker, tags["sprite"])]
        if tags.get("expr") in EXPRESSION_PATHS.get(speaker, {}):
            node["portrait_path"] = EXPRESSION_PATHS[speaker][tags["expr"]]
        if current_background == "operating_room":
            if speaker == "nurse_hiroko":
                node["portrait_path"] = HIROKO_OR_EXPRESSION_PATHS.get(tags.get("expr", ""), HIROKO_OR_PORTRAIT)
            elif speaker in OR_STAFF_OUTFITS:
                node["outfit"] = OR_STAFF_OUTFITS[speaker]
        # Chihaya's cap-on examination / OR assets are landscape dialogue
        # avatars.  Align their bottom edge with the top of the VN dialogue
        # frame instead of leaving them suspended at the standing-portrait Y.
        if any(part in str(node.get("portrait_path", "")) for part in [
            "/patient_chihaya_second_surgery_v1/intraoperative/",
            "/mizuho_story_v1/intraoperative/",
        ]):
            node["portrait_y"] = 272.0
        if "cg" in tags:
            node["cg_key"] = tags["cg"]
            if tags["cg"] in CG_PATHS:
                node["cg_path"] = CG_PATHS[tags["cg"]]
                node["cg_fit"] = "contain"
        if "bgm" in tags: node["bgm_key"] = tags["bgm"]
        if "sfx" in tags: node["sfx_key"] = tags["sfx"]
        if "transition" in tags: node["transition_key"] = tags["transition"]
        if (event_id, node_id) in NODE_CG_CUES:
            node.update(NODE_CG_CUES[(event_id, node_id)])
        nodes.append(node)
    return {
        "id": event_id, "source_file": path.name, "source_status": "imported_verbatim",
        "title": {"zh_CN": title, "en": title}, **catalog_metadata(cast),
        "level": level, "actor_id": cast[0], "start": nodes[0]["id"], "minutes": 0, "nodes": nodes,
    }

def main() -> None:
    events = [parse(*source) for source in SOURCES]
    target = ROOT / "data/daydreams/index.json"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps({"version": 1, "events": events}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("Imported %d Daydream events" % len(events))
    for event in events: print(event["id"], len(event["nodes"]))

if __name__ == "__main__": main()
