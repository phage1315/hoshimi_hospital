#!/usr/bin/env python3
"""Extract Narumi's supplied H Profile/Flow and build the bilingual context.

The two authored JSON blocks are copied without editorial changes.  English
text lives only in the context override so the Chinese manuscript stays the
canonical source.  The registration remains pending until all declared art and
the calibrated body map exist.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOWNLOAD = Path("/Users/ningye/Downloads/HOSHIMI_JINGUJI_NARUMI_H_PROFILE_AND_FLOW_V1_3_5_V3.md")
SOURCE = ROOT / "research/source_scripts/HOSHIMI_JINGUJI_NARUMI_H_PROFILE_AND_FLOW_V1_3_5_V3.md"
PROFILE = ROOT / "data/staff/doc_aoi/h_profile_v1_3_5.json"
FLOW = ROOT / "data/staff/doc_aoi/h_flow_v1_3_4.json"
CONTEXT = ROOT / "data/staff/doc_aoi/h_context_v1.json"
TRANSLATIONS = ROOT / "research/translations/narumi_h_en.json"


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def extract() -> tuple[dict, dict]:
    source = DOWNLOAD if DOWNLOAD.exists() else SOURCE
    manuscript = source.read_text(encoding="utf-8")
    SOURCE.parent.mkdir(parents=True, exist_ok=True)
    SOURCE.write_text(manuscript, encoding="utf-8")
    blocks = re.findall(r"```json\s*\n(.*?)\n```", manuscript, flags=re.S)
    if len(blocks) != 2:
        raise ValueError(f"Expected exactly two JSON blocks, found {len(blocks)}")
    profile, flow = (json.loads(block) for block in blocks)
    if profile.get("schema_version") != "1.3" or profile.get("actor_id") != "doc_aoi":
        raise ValueError("Unexpected profile identity/schema")
    if flow.get("patch_version") != "1.3.4" or flow.get("actor_id") != "doc_aoi":
        raise ValueError("Unexpected flow identity/schema")
    write_json(PROFILE, profile)
    write_json(FLOW, flow)
    return profile, flow


def expected_translation_keys(profile: dict) -> dict[str, int]:
    result: dict[str, int] = {}
    dialogue = profile["dialogue"]
    for section in ("tier_fallback", "zone_tier", "combo"):
        for raw_key, pool in dialogue[section].items():
            prefix = "reaction." + section + ":"
            key = prefix + (raw_key.replace(":", "|") if section != "tier_fallback" else raw_key)
            result[key] = len(pool)
    for key, pool in dialogue["scene"].items():
        result["scene." + key] = len(pool)
    return result


def build_context(profile: dict, flow: dict) -> dict:
    translated = read_json(TRANSLATIONS)
    dialogue = translated.get("dialogue", {})
    expected = expected_translation_keys(profile)
    for key, count in expected.items():
        value = dialogue.get(key)
        if not isinstance(value, list) or len(value) != count or any(not str(line).strip() for line in value):
            raise ValueError(f"Missing English pool {key}: expected {count}")
    for key in ["max_prompt", "style.opening.gentle", "style.opening.intense", "style.midpoint.gentle", "style.midpoint.intense"]:
        value = dialogue.get(key)
        if not isinstance(value, list) or len(value) != 1 or not str(value[0]).strip():
            raise ValueError(f"Missing English singleton {key}")
    for key, count in [("finish.responses", 4), ("aftercare", 2), ("finish.labels", 5)]:
        value = dialogue.get(key)
        if not isinstance(value, list) or len(value) != count or any(not str(line).strip() for line in value):
            raise ValueError(f"Missing English pool {key}: expected {count}")
    locations = {}
    for location_id, pool in profile["dialogue"]["location_entry"].items():
        english = translated.get("locations", {}).get(location_id)
        if not isinstance(english, list) or len(english) != len(pool) or any(not str(line).strip() for line in english):
            raise ValueError(f"Missing English location pool {location_id}")
        locations[location_id] = {"dialogue": {"en": {"entry": english}}}
    return {
        "schema_version": "1.0",
        "actor_id": "doc_aoi",
        "entry_random_one": True,
        "content_status": "ready",
        "base": {
            "dialogue": {"en": dialogue},
            "assets": {
                "body_map": {
                    "path": profile["assets"]["body_map_image"],
                    "layout_id": "doc_aoi_front_bodymap_v1",
                    "width": 1024,
                    "height": 1536,
                },
                "background": {"id": "date_hotel"},
            },
        },
        "locations": locations,
        "events": {},
        "layout_status": "final_hotspots_calibrated",
    }


def main() -> None:
    profile, flow = extract()
    if not TRANSLATIONS.exists():
        template = {
            "dialogue": {key: [""] * count for key, count in expected_translation_keys(profile).items()},
            "locations": {key: [""] * len(value) for key, value in profile["dialogue"]["location_entry"].items()},
        }
        template["dialogue"].update({
            "max_prompt": [""],
            "style.opening.gentle": [""],
            "style.opening.intense": [""],
            "style.midpoint.gentle": [""],
            "style.midpoint.intense": [""],
            "finish.responses": [""] * 4,
            "aftercare": [""] * 2,
            "finish.labels": [""] * 5,
        })
        write_json(TRANSLATIONS, template)
        print(f"extracted profile/flow; wrote English template with {len(template['dialogue'])} pools")
        return
    write_json(CONTEXT, build_context(profile, flow))
    print("imported bilingual Narumi H Profile/Flow/Context (pending assets)")


if __name__ == "__main__":
    main()
