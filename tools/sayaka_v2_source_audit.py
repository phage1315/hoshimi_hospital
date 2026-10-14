#!/usr/bin/env python3
"""Verbatim Chinese/speaker/order audit against the user-approved source.

The seven explicitly listed substitutions are authorized time-consistency edits.
Optional ambient SMS are not part of this implementation.
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs/source/sayaka_week1_lv1_v2_approved.md"
TIME_EDITS = {
    62: "工作日早晨。坂口刚把手里的病例放下，小夜香拿着一份会诊单敲了敲开着的门。",
    66: "「谢了。我一早在两个科室都看见你了，怎么又到这里来了？」",
    80: "「这份结束了。你今天应该还有别的，不过我今天不替你算。」",
    257: "星期日。没有普通门诊和择期手术安排。坂口打开之前存好的联系人。",
    265: "「诶，你这个星期天就点我？」",
    684: "「现在可是工作时间。约会时又没有人说以后医院里不办正事了。」",
    686: "「那上次说的下次呢？」",
}
events = json.loads((ROOT / "data/staff/doc_sayaka/events.json").read_text())[:3]
english = json.loads((ROOT / "data/localization/en.json").read_text())["strings"]
lines = {}
for number, line in enumerate(SOURCE.read_text().splitlines(), 1):
    match = re.match(r"^(旁白|南条小夜香|坂口隆司|短信｜南条小夜香|短信｜坂口隆司)：(.+)$", line)
    if match and (number < 200 or number > 240):
        lines[number] = (match[1], TIME_EDITS.get(number, match[2]))
lines[192] = ("旁白", "已获得：南条小夜香的联系方式")
checks = 0


def check(value, message):
    global checks
    checks += 1
    assert value, message


for event in events:
    for node in event["nodes"]:
        number = int(node["id"].removeprefix("v2_"))
        owner, text = lines[number]
        role = "player" if "坂口" in owner else "actor" if "小夜香" in owner else "narrator"
        check(node["text"] == text, f"Chinese fidelity: {number}")
        check(node["speaker"] == role, f"Speaker fidelity: {number}")
        check(node["presentation"] == ("sms" if owner.startswith("短信") else "authored"), f"Message routing: {number}")
        key = f'collections.character_events.{event["id"]}.nodes.{node["id"]}.text'
        check(bool(english.get(key)) and not re.search(r"[\u3400-\u9fff]", english[key]), key)
        check(all(c["label"] == "继续  ▷" for c in node["choices"]) or len(node["choices"]) == 3, f"No fake story choices: {number}")
check({int(n["id"][3:]) for e in events for n in e["nodes"]} == set(lines), "No missing or invented beats")


def route(event, picks):
    nodes = {n["id"]: n for n in event["nodes"]}
    result, current = [], event["start"]
    while current != "@end":
        check(current not in result, "No cycles")
        result.append(current)
        node = nodes[current]
        choice = next((c for c in node["choices"] if c["id"] in picks), node["choices"][0])
        current = choice["next"]
    return [int(n[3:]) for n in result]


def authored_range(start, end):
    return sorted(n for n in lines if start <= n <= end)


for branch, start in zip(["phone_tail_a", "phone_tail_b", "phone_tail_c"], [144, 154, 164]):
    expected = authored_range(62, 134) + authored_range(start, start + 6) + authored_range(174, 192)
    check(route(events[0], [branch]) == expected, "Phone branch order: " + branch)
for clothing, bounds in zip(["outfit_miss_coat", "outfit_pretty", "outfit_same"], [(335, 341), (345, 355), (359, 369)]):
    for answer, answer_bounds in zip(["date_direct", "date_tease", "date_only_meal"], [(507, 517), (521, 537), (541, 577)]):
        expected = authored_range(257, 325) + authored_range(*bounds) + authored_range(373, 497) + authored_range(*answer_bounds) + authored_range(589, 655)
        check(route(events[1], [clothing, answer]) == expected, "Date branch order: " + clothing + "/" + answer)
        check(expected.count(471) == 1 and expected.count(473) == 1, "Screening exchange occurs once")
check(route(events[2], []) == authored_range(676, 696), "Callback order")
check(not any("retry_if_flags" in e for e in events), "No retry event configuration")
check(not any("sayaka_first_date_retry_pending" in c.get("flags", []) for e in events for n in e["nodes"] for c in n["choices"]), "No retry branch effects")
print(f"SAYAKA V2 SOURCE AUDIT: {checks} checks; 0 failures; 230 beats, 7 authorized time edits")
