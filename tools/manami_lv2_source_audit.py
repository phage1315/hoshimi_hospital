#!/usr/bin/env python3
"""Strict source fidelity, Concept Lock, bilingual localization, and registration audit
for Manami Iimura's Relationship Lv2 event V1.1: 《和弘子一起吃饭》 (manami_lv2_dinner_with_hiroko).
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import import_manami_lv2 as imp

failures: list[str] = []


def require(ok: bool, message: str) -> None:
    if not ok:
        failures.append(message)


expected = imp.parse_beats()
events = json.loads(imp.OUTPUT.read_text(encoding="utf-8"))
require(len(events) == 1, "lv2_events.json must contain exactly one event")
event = events[0] if events else {}
actual = event.get("nodes", [])

require(len(expected) == 205, f"canonical parser beat count drift: {len(expected)}")
require(len(actual) == len(expected), f"runtime node count drift: {len(actual)}/{len(expected)}")

for index, source in enumerate(expected):
    if index >= len(actual):
        break
    node = actual[index]
    for field in [
        "id",
        "speaker",
        "actor_id",
        "speaker_label",
        "text",
        "expression",
        "background_id",
        "hide_portrait",
        "event_portraits",
        "choices",
    ]:
        require(node.get(field) == source.get(field), f"{source['id']} source drift in {field}")
    require("**" not in str(node.get("text", "")), f"{source['id']} leaked Markdown emphasis")

# Verify casual expression variety for both Manami and Hiroko
manami_profile = json.loads((ROOT / "data/staff/pharmacist_manami/profile.json").read_text(encoding="utf-8"))
hiroko_profile = json.loads((ROOT / "data/staff/nurse_hiroko/profile.json").read_text(encoding="utf-8"))
manami_used_paths: set[str] = set()
hiroko_used_paths: set[str] = set()
for node in actual:
    for ep in node.get("event_portraits", []):
        p = str(ep.get("path", ""))
        require((ROOT / p).is_file(), f"{node['id']} missing portrait file on disk: {p}")
        if ep.get("id") == "pharmacist_manami":
            manami_used_paths.add(p)
        elif ep.get("id") == "nurse_hiroko":
            hiroko_used_paths.add(p)

for expr, path in imp.MANAMI_PORTRAITS.items():
    require(
        manami_profile["visuals"]["portraits"].get(f"casual/{expr}") == path,
        f"Manami profile missing casual/{expr} -> {path}",
    )
    require((ROOT / path).is_file(), f"Manami casual/{expr} missing on disk: {path}")
require(
    len(manami_used_paths) >= 7,
    f"Manami should use all 7 casual expressions in Lv2 event, found {len(manami_used_paths)}",
)

for expr, path in imp.HIROKO_PORTRAITS.items():
    require(
        hiroko_profile["visuals"]["portraits"].get(f"casual/{expr}") == path,
        f"Hiroko profile missing casual/{expr} -> {path}",
    )
    require((ROOT / path).is_file(), f"Hiroko casual/{expr} missing on disk: {path}")
require(
    len(hiroko_used_paths) >= 6,
    f"Hiroko should use all 6 casual expressions in Lv2 event, found {len(hiroko_used_paths)}",
)

# Graph reachability
by_id = {str(node.get("id", "")): node for node in actual}
reachable: set[str] = set()
pending = [str(event.get("start", ""))]
while pending:
    node_id = pending.pop()
    if node_id == "@end" or node_id in reachable:
        continue
    reachable.add(node_id)
    node = by_id.get(node_id)
    if node is None:
        failures.append(f"unresolved node target {node_id}")
        continue
    for choice in node.get("choices", []):
        pending.append(str(choice.get("next", "")))
        conditional = choice.get("next_if_relationship_level", {})
        if conditional:
            pending.append(str(conditional.get("next", "")))
require(reachable == set(by_id), f"unreachable nodes: {sorted(set(by_id) - reachable)}")

# Verify choice & conditional branch structure
require(
    sum(len(node.get("choices", [])) == 2 for node in actual) == 1,
    "expected exactly one 2-option RP choice node in Scene 3",
)
conditionals = [
    (node["id"], choice["next_if_relationship_level"])
    for node in actual
    for choice in node.get("choices", [])
    if choice.get("next_if_relationship_level")
]
require(
    conditionals
    == [
        ("mlv2_135", {"actor_id": "nurse_hiroko", "minimum": 4, "next": "mlv2_150"}),
        ("mlv2_179", {"actor_id": "nurse_hiroko", "minimum": 4, "next": "mlv2_182"}),
    ],
    f"Hiroko Lv4 conditional branch drift: {conditionals}",
)

# Verify all 13 Concept Lock items verbatim
texts = [str(node.get("text", "")) for node in actual]
require(
    any("五点半！" in t and "整整一个小时了！" in t for t in texts),
    "Concept Lock #01 missing: waiting a full hour from 5:30 to 6:30",
)
require(
    any("今天下午最后一台手术撤台比预计晚了一点" in t and "交班就花了太多时间" in t for t in texts),
    "Concept Lock #02 missing: Hiroko handover delay explanation",
)
require(
    any("既然刚好在大厅碰上了，干脆跟我们两个一起去吃饭吧！" in t for t in texts),
    "Concept Lock #03 missing: Manami inviting Ryuji to join dinner",
)
bg_sequence: list[str] = []
for node in actual:
    bg = str(node.get("background_id", ""))
    if not bg_sequence or bg_sequence[-1] != bg:
        bg_sequence.append(bg)
require(
    bg_sequence
    == [
        "lobby",
        "manami_lv2_yakitori_izakaya",
        "manami_lv2_fruit_wine_bistro",
        "manami_lv2_oden_izakaya",
        "after_work_street_spring_night",
    ],
    f"Concept Lock #04 background progression drift: {bg_sequence}",
)
require(
    "「啊，你说以前的男朋友呀？那个早就分手啦！过去的事就不用提了，我现在可是彻彻底底的单身贵族哦！」" in texts,
    "Concept Lock #05 missing: Manami's exact single status line",
)
require(
    "「不过，真奈美你这么一说……我看院长、深山医生、御堂医长她们，好像也都是单身呢！」" in texts
    and "「对对！太奇怪了吧！我们医院这么多美女医护，怎么全都是单身啊？」" in texts,
    "Concept Lock #06 missing: Hiroko and Manami's locked lines on hospital single beauties",
)
require(
    any("两双亮晶晶的眼睛直勾勾地盯住了坐在对面的坂口隆司" in t for t in texts)
    and any("握着酒杯的后背顿时冒出了一层冷汗" in t for t in texts),
    "Concept Lock #07 missing: both staring at Ryuji while he sweats",
)
require(
    texts.count("「讨厌！你不也是！」") == 3,
    "Concept Lock #08/#11 missing: Hiroko's exact retort '「讨厌！你不也是！」' in Branch A and both Scene 5 continuations",
)
require(
    "「诶？诶诶诶！你这是什么表情？！」" in texts
    and any("刚才那杯温清酒后劲太足了，酒喝多了才会脸红的！" in t for t in texts),
    "Concept Lock #09 missing: Branch B suspicion and warm sake excuse",
)
require(
    any("你刚才不是一直喊着要吃这家的招牌白萝卜吗？" in t for t in texts)
    and any("快吃点热乎的萝卜垫垫肚子" in t for t in texts),
    "Concept Lock #10 missing: Ryuji and Hiroko changing subject with oden daikon",
)
require(
    "「……我应该没说错吧，弘子？」" in texts
    and "「怎么绕了一圈，又回到这个话题上了。」" in texts,
    "Concept Lock #11 missing: Scene 5 Lv4-5 continuation lines",
)
require(
    by_id["mlv2_193"]["speaker_label"] == "飯村真奈美＆杉村弘子"
    and by_id["mlv2_193"]["text"] == "「总之你要努力就对了！」",
    "Concept Lock #12 missing: unison closing climax line",
)

# System & boundary checks (Concept Lock #13)
require(not event.get("completion_story_flags"), "event must not add unapproved permanent story flags")
require(
    all(not choice.get("flags") for node in actual for choice in node.get("choices", [])),
    "choices must not set permanent flags",
)
require(
    all(
        choice.get("effects") == {"affection": 0, "familiarity": 0}
        for node in actual
        for choice in node.get("choices", [])
    ),
    "choices must not alter affection/familiarity inside the event",
)
require(event.get("trigger_mode") == "after_work", "trigger_mode must be after_work")
require(not event.get("consumes_sunday", False), "event must not consume Sunday or count as a solo Sunday date")
require(event.get("locks_saving") is True, "event must lock saving while in progress")
require(event.get("category") == "rank_up" and event.get("target_level") == 2, "event must settle Manami Lv2")
conditions = event.get("conditions", {})
require(conditions.get("required_events") == ["manami_lv1_sneeze"], "prerequisite event must be manami_lv1_sneeze")
require(conditions.get("min_familiarity") == 25, "min_familiarity must be 25")
require(
    conditions.get("special_requirements") == [{"type": "staff_unlocked", "actor_id": "nurse_hiroko"}],
    "special_requirements must only check nurse_hiroko met (staff_unlocked)",
)

# Bundle, relationship, and background asset verification
bundle = json.loads(imp.BUNDLE.read_text(encoding="utf-8"))
require(
    "lv2_events.json" in bundle.get("additional_character_event_files", []),
    "lv2_events.json not registered in pharmacist_manami/bundle.json",
)
relation = json.loads(imp.RELATIONSHIP.read_text(encoding="utf-8"))
lv2_slots = [s for s in relation.get("rank_slots", []) if s.get("target_level") == 2]
require(
    len(lv2_slots) == 1
    and lv2_slots[0].get("event_id") == imp.EVENT_ID
    and lv2_slots[0].get("content_status") == "authored",
    "pharmacist_manami relationship.json Lv2 slot not authored",
)

backgrounds = {entry["id"]: entry for entry in json.loads(imp.BACKGROUNDS.read_text(encoding="utf-8"))}
for bg in imp.NEW_BACKGROUNDS:
    require(bg["id"] in backgrounds, f"background {bg['id']} missing from data/backgrounds.json")
    require((ROOT / bg["path"]).is_file(), f"background asset missing on disk: {bg['path']}")

# Localization check
en_strings = json.loads(imp.LOCALIZATION_EN.read_text(encoding="utf-8"))["strings"]
zh_strings = json.loads(imp.LOCALIZATION_ZH.read_text(encoding="utf-8"))["strings"]
prefix = f"collections.character_events.{imp.EVENT_ID}"
cjk = re.compile(r"[\u3400-\u9fff]")

for suffix in ["title", "teaser", "gallery.caption"]:
    en_val = str(en_strings.get(f"{prefix}.{suffix}", ""))
    zh_val = str(zh_strings.get(f"{prefix}.{suffix}", ""))
    require(bool(en_val) and not cjk.search(en_val), f"English {suffix} missing or contains CJK")
    require(bool(zh_val), f"Chinese {suffix} missing")

for node in actual:
    stem = f"{prefix}.nodes.{node['id']}"
    for suffix in ["text", "speaker_label"]:
        en_val = str(en_strings.get(f"{stem}.{suffix}", ""))
        zh_val = str(zh_strings.get(f"{stem}.{suffix}", ""))
        require(bool(en_val) and not cjk.search(en_val), f"{node['id']} English {suffix} missing or contains CJK")
        require(zh_val == str(node.get(suffix, "")), f"{node['id']} Chinese {suffix} mismatch")
    for choice in node.get("choices", []):
        ckey = f"{stem}.choices.{choice['id']}.label"
        en_val = str(en_strings.get(ckey, ""))
        zh_val = str(zh_strings.get(ckey, ""))
        require(bool(en_val) and not cjk.search(en_val), f"{node['id']} choice {choice['id']} English missing/CJK")
        require(zh_val == str(choice.get("label", "")), f"{node['id']} choice {choice['id']} Chinese mismatch")

print(f"MANAMI LV2 SOURCE AUDIT: {len(actual)} bilingual beats; 13/13 Concept Locks verified; {len(failures)} failures")
for failure in failures:
    print("FAIL:", failure)
raise SystemExit(bool(failures))
