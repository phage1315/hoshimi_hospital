#!/usr/bin/env python3
"""Static integration checks for Sayaka's authored Lv4 hotel event."""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path("/Users/ningye/Downloads/HOSHIMI_NANJOU_SAYAKA_LV4_CODEX_READY_CN_V2_2.md")
EVENTS_PATH = ROOT / "data/staff/doc_sayaka/lv4_event.json"
GAME_STATE_PATH = ROOT / "godot/systems/game_state.gd"
APP_PATH = ROOT / "godot/ui/app.gd"


def source_lines(start: str, end: str) -> list[tuple[str, str]]:
    lines = SOURCE.read_text(encoding="utf-8").splitlines()
    start_index = next(i for i, line in enumerate(lines) if line.startswith(start))
    end_index = next(i for i, line in enumerate(lines[start_index + 1 :], start_index + 1) if line.startswith(end))
    result = []
    for raw in lines[start_index:end_index]:
        line = raw.rstrip()
        matches = list(re.finditer(r"\*\*(南条小夜香|坂口隆司)\*\*：「(.*?)」", line))
        if matches:
            result.extend(
                ("actor" if match.group(1) == "南条小夜香" else "player", match.group(2))
                for match in matches
            )
        else:
            match = re.match(r"【旁白】(.*)$", line)
            if match:
                result.append(("narrator", match.group(1)))
    return result


def main() -> int:
    definitions = json.loads(EVENTS_PATH.read_text(encoding="utf-8"))
    by_id = {event["id"]: event for event in definitions}
    main_event = by_id["sayaka_lv4_hotel_date"]
    callback = by_id["sayaka_lv4_hospital_callback"]
    beats = main_event["script"]
    nodes = {node["id"]: node for node in beats}
    errors = []

    expected = []
    for start, end in [
        ("## 2. Scene 01", "## 3. Scene 02"),
        ("## 3. Scene 02", "## 4. Scene 03"),
        ("## 4. Scene 03", "### Scene 04-A"),
        ("### Scene 04-A", "### Scene 04-B"),
        ("### Scene 04-B", "### Scene 04-C"),
        ("### Scene 04-C", "## 5. Scene 05"),
        ("## 5. Scene 05", "## 6. Scene 06"),
        ("## 6. Scene 06", "## 7. Scene 07"),
        ("## 8. Scene 08", "## 9. Scene 09"),
        ("## 9. Scene 09", "## 10. Scene 10"),
        ("## 10. Scene 10", "## 11. Scene 11"),
    ]:
        expected.extend(source_lines(start, end))
    actual = [(node["speaker"], node["text"]["zh_CN"]) for node in beats]
    if actual != expected:
        errors.append(f"main-event authored text/speaker/order mismatch ({len(actual)} nodes vs {len(expected)} source lines)")
    expected_callback = source_lines(
        "## 12. Scene 12", "## 13. 美术资产交接"
    )
    actual_callback = [
        (node["speaker"], node["text"]["zh_CN"]) for node in callback["script"]
    ]
    if actual_callback != expected_callback:
        errors.append(
            "Monday-callback authored text/speaker/order mismatch "
            f"({len(actual_callback)} nodes vs {len(expected_callback)} source lines)"
        )
    if any(not node["text"].get("en", "").strip() for node in beats + callback["script"]):
        errors.append("main or callback contains a missing English line")
    for node in beats + callback["script"]:
        for choice in node.get("choices", []):
            if choice["next"] != "@end" and choice["next"] not in nodes:
                errors.append(f"choice {node['id']}/{choice['id']} points to missing node {choice['next']}")
    common_choices = [choice["next"] for node in beats for choice in node.get("choices", []) if choice["id"] in {"sayaka_lv4_direct", "sayaka_lv4_drink", "sayaka_lv4_rest"}]
    if set(common_choices) != {"s04a_start", "s04b_start", "s04c_start"}:
        errors.append("three Sunday-date tone branches are not wired")
    positions = {node["id"]: index for index, node in enumerate(beats)}
    for branch in ("s04a_start", "s04b_start", "s04c_start"):
        cursor = branch
        visited = set()
        while cursor != "s05_hotel" and cursor in nodes and cursor not in visited:
            visited.add(cursor)
            current = nodes[cursor]
            if current.get("next"):
                cursor = current["next"]
            else:
                cursor = beats[positions[cursor] + 1]["id"] if positions[cursor] + 1 < len(beats) else ""
        if cursor != "s05_hotel":
            errors.append(f"branch {branch} does not converge on the hotel scene")
    if not any(node.get("action") == "launch_sayaka_lv4_h" for node in beats):
        errors.append("hotel scene does not hand off to the existing H flow")
    if main_event.get("trigger_mode") != "sunday" or not main_event.get("consumes_sunday") or main_event["conditions"].get("min_familiarity") != 55:
        errors.append("Sunday entry/gate differs from the approved Lv4 contract")
    if main_event["conditions"].get("days_after_required_events") != 3 or "sayaka_lv3_relationship" not in main_event["conditions"].get("required_events", []):
        errors.append("Lv3 completion delay prerequisite is missing")
    if callback.get("mandatory") or callback.get("trigger_mode") != "location":
        errors.append("Monday callback must be started only by the safe map/end-of-workday hooks")
    game_state = GAME_STATE_PATH.read_text(encoding="utf-8")
    app_source = APP_PATH.read_text(encoding="utf-8")
    if "str(calendar_date(for_day).weekday_id) != \"mon\"" not in game_state or "absolute_clock >= 12 * 60" not in game_state:
        errors.append("callback is not gated to Monday noon or later")
    if "for_day > target_day" not in game_state or "settle_sayaka_lv4_callback(true)" not in game_state:
        errors.append("a callback missed on Monday is not expired/skipped")
    if "begin_sayaka_lv4_callback(game.day_number(), game.current_absolute_clock())" not in app_source:
        errors.append("safe return-to-hospital-map callback hook is missing")
    if "begin_sayaka_lv4_callback(workday, departure_clock" not in app_source:
        errors.append("pre-departure/end-of-workday callback hook is missing")
    if "sayaka_lv4_french_fusion_restaurant" not in {
        node.get("background_id") for node in beats
    }:
        errors.append("new French-Japanese fusion restaurant background is not used")
    arrival = nodes.get("s05_hotel", {})
    if arrival.get("background_id") != "date_shopping_street" or not arrival.get("seasonal_street"):
        errors.append("the hotel branch does not first land on the seasonal street arrival narration")
    if not any(node.get("background_id") == "date_jazz_bar" for node in beats):
        errors.append("Scene 04-B does not reuse the existing jazz-bar background")
    if any("bar" == node.get("background_id") for node in beats):
        errors.append("event references missing generic bar background instead of date_jazz_bar")
    if not (ROOT / "assets/events/character_events/sayaka/lv4_hotel_pre_kiss_v2.png").is_file():
        errors.append("pre-H CG asset is missing")
    if not (ROOT / "assets/events/character_events/sayaka/lv4_aftercare_rest_v3.png").is_file():
        errors.append("separate LV4 aftercare CG v3 is missing")
    if not (ROOT / "assets/events/character_events/sayaka/lv4_monday_mirror_makeup_v1.png").is_file():
        errors.append("Monday makeup CG asset is missing")
    app_source = APP_PATH.read_text(encoding="utf-8")
    if "portrait.size = Vector2(450, 500) * portrait_scale" not in app_source or "540.0 - portrait.size.y" not in app_source:
        errors.append("aftercare portrait does not honor its scale or align above the VN dialogue frame")
    if 'elif phase in ["h_stage", "h_finish_response", "after_cg"]:' not in app_source or '"Sayaka Nanjou"' not in app_source:
        errors.append("non-script H-stage/finish/aftercare dialogue does not identify Sayaka as the speaker")
    context_overrides = json.loads((ROOT / "data/staff/doc_sayaka/h_context_overrides_v1.json").read_text(encoding="utf-8"))
    midpoint_en = context_overrides.get("base", {}).get("dialogue", {}).get("en", {}).get("style.midpoint.intense", [])
    if not midpoint_en or midpoint_en[0] != "Ah... hah... you... you really know how to wear me out...":
        errors.append("the revised intense midpoint line is missing its English version")
    aftercare_ids = ["s08_087", "s08_088", "s08_089", "s08_090", "s08_091", "s08_092", "s08_093", "s09_094"]
    for node_id in aftercare_ids:
        node = nodes.get(node_id, {})
        if node.get("cg_path") != "assets/events/character_events/sayaka/lv4_aftercare_rest_v3.png":
            errors.append(f"aftercare CG is not retained at {node_id}")
        if node.get("outfit") != "h_aftercare" or not node.get("cg_portrait_overlay"):
            errors.append(f"bare-shoulder aftercare portrait is not configured at {node_id}")
        if node.get("portrait_scale") != 0.5:
            errors.append(f"aftercare portrait is not scaled down at {node_id}")
    if errors:
        print("SAYAKA LV4 EVENT: FAIL")
        print("\n".join(f"- {error}" for error in errors))
        return 1
    print(f"SAYAKA LV4 EVENT: PASS ({len(beats)} main lines, {len(callback['script'])} callback lines, source order/speakers/routes/assets verified)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
