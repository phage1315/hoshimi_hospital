#!/usr/bin/env python3
"""Import verbatim user-supplied H Profile / Flow / Context bilingual dialogue for Artoria Pendragon (`doc_artoria`).

Source:
- research/source_scripts/artoria_h_profile_source_v1.json

Emits / Updates:
- data/staff/doc_artoria/h_profile_v1.json
- data/staff/doc_artoria/h_flow_v1.json
- data/staff/doc_artoria/h_context_v1.json
- data/localization/zh_CN.json & data/localization/en.json (booking_response)
- research/imports/artoria_h_profile_2026-11-16.json
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_PATH = ROOT / "research/source_scripts/artoria_h_profile_source_v1.json"
PROFILE_PATH = ROOT / "data/staff/doc_artoria/h_profile_v1.json"
FLOW_PATH = ROOT / "data/staff/doc_artoria/h_flow_v1.json"
CONTEXT_PATH = ROOT / "data/staff/doc_artoria/h_context_v1.json"
ZH_LOCALE_PATH = ROOT / "data/localization/zh_CN.json"
EN_LOCALE_PATH = ROOT / "data/localization/en.json"
MANIFEST_PATH = ROOT / "research/imports/artoria_h_profile_2026-11-16.json"

CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\u3040-\u30ff\uf900-\ufaff]")


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    src = json.loads(SOURCE_PATH.read_text(encoding="utf-8"))
    if src.get("actor_id") != "doc_artoria":
        raise ValueError(f"Unexpected actor_id: {src.get('actor_id')}")

    p_zh = src["profile_dialogue_zh"]
    prof = {
        "schema_version": "1.3",
        "actor_id": "doc_artoria",
        "adult_confirmed": bool(src.get("adult_confirmed", True)),
        "assets": {
            "body_map_image": "res://assets/h/doc_artoria/body_map.png",
            "body_map_regions": "res://data/h/doc_artoria/h_bodymap.json",
            "portrait_expressions": {
                "neutral": "res://assets/h/doc_artoria/portrait_neutral.png",
                "annoyed": "res://assets/h/doc_artoria/portrait_annoyed.png",
                "pleased": "res://assets/h/doc_artoria/portrait_pleased.png",
                "flustered": "res://assets/h/doc_artoria/portrait_flustered.png",
                "delighted": "res://assets/h/doc_artoria/portrait_delighted.png",
                "peak": "res://assets/h/doc_artoria/portrait_peak.png",
            },
            "scene_cg": "res://assets/h/doc_artoria/scene_cg.png",
            "aftercare_cg": "res://assets/h/doc_artoria/aftercare_cg.png",
        },
        "preferences": src["preferences"],
        "dialogue": {
            "tier_fallback": p_zh["tier_fallback"],
            "zone_tier": p_zh["zone_tier"],
            "action_tier": {},
            "combo": p_zh["combo"],
            "location_entry": p_zh["location_entry"],
            "scene": p_zh["scene"],
        },
    }

    f_zh = src["flow_dialogue_zh"]
    flow = {
        "patch_version": "1.3.4",
        "actor_id": "doc_artoria",
        "profile_schema_version": "1.3",
        "scope": "artoria_h_phase2_manual_finish_character_content",
        "preferred_free_h_location": "home",
        "excitement_max": {
            "trigger": {
                "excitement_gte": 100,
            },
            "line": f_zh["excitement_max_line"],
            "show_only_once_per_h_session": True,
            "can_continue_phase1_interactions": True,
            "no_auto_advance": True,
            "choices": [
                {"id": "gentle", "label": "温柔进入"},
                {"id": "intense", "label": "粗暴进入"},
            ],
        },
        "entry_style": {
            "scope": "current_h_session_only",
            "affects": [
                "phase2_opening_line",
                "phase2_midpoint_line",
            ],
            "does_not_affect": [
                "excitement",
                "preferences",
                "h_result",
                "relationship_result",
                "aftercare_result",
                "scene_cg",
                "surgery_system",
            ],
            "both_choices_require_mutual_consent": True,
            "openings": f_zh["openings"],
            "midpoints": f_zh["midpoints"],
        },
        "phase2": {
            "fixed_cg_asset_ref": "assets.scene_cg",
            "no_position_selector": True,
            "no_new_meter": True,
            "no_failure_or_rating": True,
            "no_dialogue_choices_inside_phase2": True,
            "playback": [
                {
                    "kind": "style_line",
                    "ref": "entry_style.openings",
                },
                {
                    "kind": "profile_scene_pool",
                    "ref": "dialogue.scene.start",
                    "draw": 2,
                    "without_replacement": True,
                },
                {
                    "kind": "style_line",
                    "ref": "entry_style.midpoints",
                },
                {
                    "kind": "profile_scene_pool",
                    "ref": "dialogue.scene.middle",
                    "draw": 2,
                    "without_replacement": True,
                },
                {
                    "kind": "wait_for_player_finish",
                    "action_id": "h_finish",
                    "do_not_auto_complete": True,
                },
            ],
            "completion": {
                "trigger": "after_h_finish_reaction_acknowledged",
                "set_result": "h_event_completed",
                "value": True,
                "handoff": "external_vn_aftercare",
                "one_shot": True,
                "no_other_exit_from_normal_phase2_playback": True,
            },
            "manual_finish": {
                "button_action_id": "h_finish",
                "button_label_source": "h_finish_button_labels.V1_3_4.json",
                "button_label_selection": "uniform_random_1_of_5_at_phase2_enter",
                "button_label_stable_for_session": True,
                "button_shown_only_after_initial_playback": True,
                "button_shown_until_clicked": True,
                "on_click": {
                    "one_shot": True,
                    "disable_button_immediately": True,
                    "prevent_other_phase2_lines_after_click": True,
                    "choose_one_response_uniformly": True,
                    "response_pool": f_zh["finish_responses"],
                    "selection_independent_of_button_label": True,
                    "play_selected_response_once": True,
                    "wait_until_response_advanced": True,
                    "then": "phase2.completion",
                },
                "legacy_scene_finish_pool": {
                    "source": "doc_artoria.h_profile.dialogue.scene.finish",
                    "behavior": "preserve_in_profile_but_do_not_play_in_V1_3_4",
                    "reason": "prevent duplicate finish text",
                },
            },
        },
        "external_vn_aftercare": {
            "owner": "normal_vn_event_flow",
            "scene_image_ref": "assets.aftercare_cg",
            "free_h": {
                "on_entry_line_sequence": f_zh["free_h_aftercare"],
            },
            "relationship_milestone": {
                "behavior": "return_to_authored_event_aftercare",
                "no_auto_injection_of_generic_free_h_lines": True,
                "do_not_modify_lv4_event_script": True,
            },
        },
    }

    c_en = src["context_dialogue_en"]
    new_base_en = dict(c_en["base_en"])
    if "finish.labels" not in new_base_en:
        new_base_en["finish.labels"] = [
            "I'm coming!",
            "It's coming...!",
            "I can't hold back...!",
            "Right now!",
            "Let's come together!",
        ]

    for k, arr in new_base_en.items():
        for line in arr:
            if CJK_RE.search(line):
                raise ValueError(f"CJK leak in English H context key {k}: {line!r}")
    for line in c_en["home_entry"]:
        if CJK_RE.search(line):
            raise ValueError(f"CJK leak in English home_entry: {line!r}")

    ctx = {
        "schema_version": "1.0",
        "actor_id": "doc_artoria",
        "entry_random_one": True,
        "content_status": "ready",
        "layout_status": "final_hotspots_calibrated",
        "base": {
            "assets": {
                "body_map": {
                    "path": "res://assets/h/doc_artoria/body_map.png",
                    "layout_id": "doc_artoria_home_bodymap_v1",
                    "width": 682,
                    "height": 1024,
                },
                "h_stage": {
                    "path": "res://assets/h/doc_artoria/scene_cg.png",
                },
                "after_cg": {
                    "path": "res://assets/h/doc_artoria/aftercare_cg.png",
                },
                "background": {
                    "id": "artoria_home_bedroom_night",
                },
            },
            "dialogue": {
                "en": new_base_en,
            },
        },
        "locations": {
            "home": {
                "dialogue": {
                    "en": {
                        "entry": c_en["home_entry"],
                    },
                },
            },
        },
        "events": {},
    }

    PROFILE_PATH.write_text(json.dumps(prof, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    FLOW_PATH.write_text(json.dumps(flow, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    CONTEXT_PATH.write_text(json.dumps(ctx, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    booking = src["booking_response"]
    if CJK_RE.search(booking["en"]):
        raise ValueError("CJK leak in booking_response.en")

    zh_doc = json.loads(ZH_LOCALE_PATH.read_text(encoding="utf-8"))
    en_doc = json.loads(EN_LOCALE_PATH.read_text(encoding="utf-8"))
    zh_doc["strings"]["ui.free_h.doc_artoria.booking_response"] = booking["zh_CN"]
    en_doc["strings"]["ui.free_h.doc_artoria.booking_response"] = booking["en"]
    zh_doc["strings"] = dict(sorted(zh_doc["strings"].items()))
    en_doc["strings"] = dict(sorted(en_doc["strings"].items()))
    ZH_LOCALE_PATH.write_text(json.dumps(zh_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    EN_LOCALE_PATH.write_text(json.dumps(en_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    manifest = {
        "actor_id": "doc_artoria",
        "version": src.get("version", "1.0"),
        "source_json": str(SOURCE_PATH.relative_to(ROOT)),
        "source_sha256": sha256_of(SOURCE_PATH),
        "profile_sha256": sha256_of(PROFILE_PATH),
        "flow_sha256": sha256_of(FLOW_PATH),
        "context_sha256": sha256_of(CONTEXT_PATH),
        "assets": {
            "body_map_sha256": sha256_of(ROOT / "assets/h/doc_artoria/body_map.png"),
            "scene_cg_sha256": sha256_of(ROOT / "assets/h/doc_artoria/scene_cg.png"),
            "aftercare_cg_sha256": sha256_of(ROOT / "assets/h/doc_artoria/aftercare_cg.png"),
            "portraits_sha256": {
                expr: sha256_of(ROOT / f"assets/h/doc_artoria/portrait_{expr}.png")
                for expr in ("neutral", "annoyed", "pleased", "flustered", "delighted", "peak")
            },
        },
        "counts": {
            "home_entry": len(p_zh["location_entry"]["home"]),
            "tier_fallback_pools": len(p_zh["tier_fallback"]),
            "zone_tier_pools": len(p_zh["zone_tier"]),
            "combo_pools": len(p_zh["combo"]),
            "scene_pools": {k: len(v) for k, v in p_zh["scene"].items()},
            "finish_responses": len(f_zh["finish_responses"]),
            "free_h_aftercare": len(f_zh["free_h_aftercare"]),
        },
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(
        f"Imported doc_artoria H Profile dialogue V{manifest['version']}: "
        f"{manifest['counts']['combo_pools']} combo pools, "
        f"{manifest['counts']['zone_tier_pools']} zone_tier pools, zero placeholders."
    )


if __name__ == "__main__":
    main()
