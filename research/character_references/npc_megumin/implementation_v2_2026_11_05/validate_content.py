#!/usr/bin/env python3
"""Static acceptance checks for Hoshimi Megumin content handoff V2.

Does not require or claim access to any Godot project. Run with Python 3.9+.
"""
from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent
MANIFEST = ROOT / "05_EVENT_MANIFEST.json"
MICRO = ROOT / "03_MICRO_EVENTS_CN.md"
BARKS = ROOT / "04_AMBIENT_BARKS_CN.md"
INTRO = ROOT / "02_INTRO_SCRIPT_CN.md"


def demand(check: bool, message: str) -> None:
    if not check:
        raise AssertionError(message)


def main() -> None:
    data = json.loads(MANIFEST.read_text(encoding="utf-8"))
    events = data["events"]
    ids = [entry["content_id"] for entry in events]
    source_ids = [entry["source_id"] for entry in events]
    demand(len(events) == 100, "Manifest must have exactly 100 records.")
    demand(len(set(ids)) == 100 and len(set(source_ids)) == 100, "Duplicate IDs.")
    demand(data["totals"] == {
        "regular_micro": 48,
        "calendar_micro": 22,
        "ambient_barks": 30,
        "total_content_items": 100,
    }, "Unexpected content totals.")
    trigger = data["intro_trigger"]
    demand(trigger["mode"] == "auto_on_scheduled_workday_09" and
           trigger["no_first_click_fallback"] and
           trigger["completed_only_after_full_vn"], "Intro must be auto-scheduled.")
    demand(trigger["first_due"] == "first_monday_09_after_aqua_completion" and
           trigger["on_conflict"] == "next_active_workday_09_until_success",
           "Intro scheduling or conflict retry changed.")
    demand(data["afterwork_reward_policy"] ==
           "zero_stats_zero_affection_zero_relationship_zero_date",
           "No stats or relationship rewards allowed for escort.")

    source_counts = Counter(identifier[0] for identifier in source_ids)
    demand(source_counts == {"R": 28, "M": 30, "S": 12, "L": 30},
           f"Missing source materials: {source_counts}.")

    kinds = Counter(item["kind"] for item in events)
    demand(kinds == {
        "daily_micro": 45,
        "calendar_micro": 20,
        "afterwork_micro": 5,
        "ambient_bark": 30,
    }, f"Unexpected playback layers: {kinds}.")

    micro_text = MICRO.read_text(encoding="utf-8")
    bark_text = BARKS.read_text(encoding="utf-8")
    intro_text = INTRO.read_text(encoding="utf-8")
    headings = re.findall(r"(?m)^### (megumin_[rmsl]\d\d) \| ", micro_text + "\n" + bark_text)
    demand(len(headings) == 100 and set(headings) == set(ids),
           "Every Manifest ID must appear once as a content heading.")
    for item in events:
        demand(item["no_stats_or_relation_rewards"] and item["minor_non_romance_only"],
               f"Boundaries not set for {item['content_id']}.")
        demand(item["required_cast_canonical_names"] is not None,
               f"Missing cast declaration for {item['content_id']}.")
        demand(item["content_file"] in ("03_MICRO_EVENTS_CN.md", "04_AMBIENT_BARKS_CN.md"),
               f"Bad prose source for {item['content_id']}.")
        if item["required_cast_canonical_names"]:
            demand(item.get("required_cast_formal_intros_complete") is True and
                   item.get("required_cast_available_in_scene") is True,
                   f"Cross-cast formal-meeting gate missing for {item['content_id']}.")
        if item["optional_cast_canonical_names"]:
            demand(item.get("optional_cast_formal_intros_complete_to_show_lines") is True,
                   f"Optional cross-cast formal-meeting gate missing for {item['content_id']}.")

    keys = {item["source_id"]: item for item in events}
    demand(keys["M07"]["repeat_policy"] == "once_game", "JK first sight must be once.")
    demand(keys["M19"]["required_cast_canonical_names"] ==
           ["七瀬恋", "神宮寺成美"], "M19 actor names are wrong.")
    demand(keys["M12"]["required_cast_canonical_names"] == ["遥凑"],
           "M12 cast gate missing.")
    demand(keys["R22"]["required_cast_canonical_names"] == ["武見妙"],
           "Takemi reveal gate missing.")
    demand(keys["M25"]["window"] == {"semantic": "hospital_festival_preparation"} and
           keys["S08"]["window"] == {"semantic": "hospital_festival_active"},
           "Hospital festival must not have invented fixed dates.")
    for entry in ("R25", "M19", "M22", "M27", "L17", "L18", "L19", "L20"):
        demand(keys[entry].get("requires_first_school_uniform_reveal") is True,
               f"JK reveal ordering missing for {entry}.")
    for group in (
        ("M23", "S04"), ("M26", "S07"),
        ("M28", "S10"), ("M29", "S11"),
    ):
        demand(keys[group[0]]["annual_group"] == keys[group[1]]["annual_group"],
               f"Holiday group not deduplicated: {group}.")

    for source, text in ((MICRO, micro_text), (BARKS, bark_text)):
        content_sections = re.split(r"(?m)^### megumin_", text)[1:]
        demand(bool(content_sections), f"Empty script: {source}.")
        for section in content_sections:
            demand("【玩家可见正文】" in section, f"Missing content marker in {source}.")
            body = section.split("【玩家可见正文】", 1)[1]
            demand("**惠惠" in body, f"Missing primary speaker in {source}.")
            demand("**触发：**" not in body, f"Developer note leaked into {source}.")
    demand("## Scene 01" in intro_text and "## Scene 03" in intro_text,
           "Merged introduction scenes missing.")
    demand("【A／B 在这里汇合】" in intro_text, "Intro branch merge missing.")
    demand("met_haru" not in micro_text and "met_aoi" not in micro_text,
           "Obsolete source draft flags leaked into user content.")

    print("OK: 100 unique items = 45 daytime + 20 calendar + 5 afterwork + 30 barks.")
    print("OK: all 3 scene intro, 70 microevents and 30 barks found.")
    print("OK: source groups, cast-gating, dates, reveal order, and metadata boundaries.")
    print("OK: Aqua-gated Monday 09:00 intro with daily retries; escort rewards disabled.")
    print("NOTE: Godot API mapping, runtime scheduling and art registration require repo tests.")


if __name__ == "__main__":
    main()
