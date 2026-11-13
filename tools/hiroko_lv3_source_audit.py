#!/usr/bin/env python3
"""Strict source fidelity, Concept Lock, V1.2 revision log, bilingual localization,
and portrait/background audit for Hiroko Sugimura's V1.2 manuscript:
1. Relationship Lv3 Rank-Up Event: 《另一家医院的灯光》 (hiroko_lv3_another_hospital_lights)
2. Independent Summer Bonus Event: 《夏夜的烟花》 (hiroko_summer_fireworks)
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import import_hiroko_lv3 as imp

failures: list[str] = []


def require(ok: bool, message: str) -> None:
    if not ok:
        failures.append(message)


expected_lv3 = imp.parse_lv3_event()
expected_summer_lv3 = imp.parse_summer_track("lv3")
expected_summer_lv4 = imp.parse_summer_track("lv4")
expected_summer = expected_summer_lv3 + expected_summer_lv4

events = json.loads(imp.OUTPUT.read_text(encoding="utf-8"))
require(len(events) == 2, f"lv3_events.json must contain 2 events, found {len(events)}")
by_event_id = {ev.get("id"): ev for ev in events if isinstance(ev, dict)}
ev_lv3 = by_event_id.get(imp.LV3_EVENT_ID, {})
ev_summer = by_event_id.get(imp.SUMMER_EVENT_ID, {})

actual_lv3 = ev_lv3.get("nodes", [])
actual_summer = ev_summer.get("nodes", [])

require(len(expected_lv3) == 118, f"Lv3 canonical parser beat count drift: {len(expected_lv3)}")
require(len(actual_lv3) == len(expected_lv3), f"Lv3 runtime node count drift: {len(actual_lv3)}/{len(expected_lv3)}")
require(len(expected_summer_lv3) == 82, f"Summer Lv3 canonical beat count drift: {len(expected_summer_lv3)}")
require(len(expected_summer_lv4) == 84, f"Summer Lv4+ canonical beat count drift: {len(expected_summer_lv4)}")
require(len(actual_summer) == len(expected_summer), f"Summer runtime node count drift: {len(actual_summer)}/{len(expected_summer)}")

for expected_nodes, actual_nodes in ((expected_lv3, actual_lv3), (expected_summer, actual_summer)):
    for index, source in enumerate(expected_nodes):
        if index >= len(actual_nodes):
            break
        node = actual_nodes[index]
        for field in [
            "id",
            "speaker",
            "actor_id",
            "speaker_label",
            "text",
            "expression",
            "outfit",
            "background_id",
            "hide_portrait",
            "event_portraits",
            "choices",
        ]:
            require(node.get(field) == source.get(field), f"{source['id']} source drift in {field}")
        require("**" not in str(node.get("text", "")), f"{source['id']} leaked Markdown emphasis")

# Verify portraits & expressions
hiroko_profile = json.loads((ROOT / "data/staff/nurse_hiroko/profile.json").read_text(encoding="utf-8"))
require("yukata" in hiroko_profile["visuals"]["outfits"], "nurse_hiroko profile missing yukata in outfits")

used_lv3_paths: set[str] = set()
for node in actual_lv3:
    for ep in node.get("event_portraits", []):
        p = str(ep.get("path", ""))
        require((ROOT / p).is_file(), f"{node['id']} missing portrait file on disk: {p}")
        used_lv3_paths.add(p)

used_summer_paths: set[str] = set()
for node in actual_summer:
    for ep in node.get("event_portraits", []):
        p = str(ep.get("path", ""))
        require((ROOT / p).is_file(), f"{node['id']} missing portrait file on disk: {p}")
        used_summer_paths.add(p)

for expr, path in imp.HIROKO_YUKATA_PORTRAITS.items():
    require(
        hiroko_profile["visuals"]["portraits"].get(f"yukata/{expr}") == path,
        f"Hiroko profile missing yukata/{expr} -> {path}",
    )
    require((ROOT / path).is_file(), f"Hiroko yukata/{expr} missing on disk: {path}")

require(
    len(used_lv3_paths) >= 10,
    f"Lv3 event should use at least 10 uniform/casual portrait variants, found {len(used_lv3_paths)}",
)
require(
    len(used_summer_paths) == 6,
    f"Summer fireworks event should use all 6 yukata expressions, found {len(used_summer_paths)}",
)

# Graph reachability for both events
for ev in (ev_lv3, ev_summer):
    ev_id = str(ev.get("id", ""))
    by_id = {str(node.get("id", "")): node for node in ev.get("nodes", [])}
    reachable: set[str] = set()
    pending = [str(ev.get("start", "")), *[str(v) for v in ev.get("opening_variants", {}).values()]]
    while pending:
        node_id = pending.pop()
        if node_id == "@end" or node_id in reachable:
            continue
        reachable.add(node_id)
        node = by_id.get(node_id)
        if node is None:
            failures.append(f"{ev_id}: unresolved node target {node_id}")
            continue
        for choice in node.get("choices", []):
            pending.append(str(choice.get("next", "")))
    require(reachable == set(by_id), f"{ev_id} unreachable nodes: {sorted(set(by_id) - reachable)}")

# Verify all 11 Concept Lock items and V1.2 Revision item verbatim
lv3_texts = [str(n.get("text", "")) for n in actual_lv3]
summer_lv3_texts = [str(n.get("text", "")) for n in actual_summer if str(n.get("id", "")).startswith("hsf_lv3_")]
summer_lv4_texts = [str(n.get("text", "")) for n in actual_summer if str(n.get("id", "")).startswith("hsf_lv4_")]

# Concept Lock #1: Lv3 5-scene progression (no seasonal lock)
lv3_bgs: list[str] = []
for n in actual_lv3:
    bg = str(n.get("background_id", ""))
    if not lv3_bgs or lv3_bgs[-1] != bg:
        lv3_bgs.append(bg)
require(
    lv3_bgs
    == [
        "scrub_area",
        "hallway",
        "after_work_street_spring",
        "hiroko_lv3_municipal_hospital_waiting",
        "hiroko_lv3_hospital_park_bench_night",
        "after_work_street_spring_night",
    ],
    f"Concept Lock #01 Lv3 background progression drift: {lv3_bgs}",
)
# Concept Lock #2: Hiroko proactively invites Ryuji to walk part of the way
require(
    any("坂口医生现在如果直接去车站的话，要不要陪我顺路走一段？" in t for t in lv3_texts),
    "Concept Lock #02 missing: Hiroko proactively inviting Ryuji to walk together",
)
# Concept Lock #3: Hiroko states she is visiting her hospitalized mother
require(
    any("不是去见朋友啦……是去看我妈妈。她现在住在这边的医院。" in t for t in lv3_texts)
    and any("我很小的时候，爸爸就因为生病去世了。" in t for t in lv3_texts),
    "Concept Lock #03 missing: verbatim mother hospitalization & family background lines",
)
# Concept Lock #4: Ryuji waits in the public waiting area; mother is offscreen; gardening book & tangerine details
require(
    any("我就先在这边的休息区等你吧。你们母女俩好好聊聊天，不用急着下来。" in t for t in lv3_texts)
    and any("那本园艺画册她一拿到手就翻个不停，还指着里面的绣球花说等出院了要在阳台上种两盆。" in t for t in lv3_texts)
    and any("刚才在病房里被妈妈分了一半她留着的蜜柑，肚子倒是不算太饿。" in t for t in lv3_texts),
    "Concept Lock #04 missing: public waiting area boundary & mother-daughter details",
)
# Concept Lock #5: Park bench explanation of why she keeps family matters separate from Hoshimi OR work
require(
    any("我希望医生们把重要手术交给我的时候，是因为相信『杉村弘子的专业能力』" in t for t in lv3_texts)
    and any("……对不起，坂口医生。我是不是突然讲了太多和工作无关的事？" in t for t in lv3_texts)
    and any("不过医生，明天要是因为这件事，在手术室对我格外客气，我可是会困扰的哦。" in t for t in lv3_texts),
    "Concept Lock #05 missing: park bench professional pride & boundary trust lines",
)
# Concept Lock #6: Ending settles on trust (not premature confession) and unlocks Lv3 + boundary trust flag
require(
    any("只是看着医生的脸，忽然觉得这件事如果是告诉坂口医生的话，一定没关系。" in t for t in lv3_texts)
    and set(ev_lv3.get("completion_story_flags", [])) >= {"hiroko_lv3_complete", "hiroko_boundary_trust_established"},
    "Concept Lock #06 missing: closing trust line or completion_story_flags",
)

# Concept Lock #7 & V1.2 Rev #1: Summer Festival independent bonus event + V1.2 ramune & bamboo fan sequence
for track_name, track_texts in (("lv3", summer_lv3_texts), ("lv4", summer_lv4_texts)):
    require(
        any("屋台老板递来两瓶挂着水珠的玻璃瓶弹珠汽水，还笑呵呵地附送了一把印着花火图案的祭典竹团扇。" in t for t in track_texts)
        and any("坂口接过汽水，顺手替弘子用力按下瓶口的玻璃珠。" in t for t in track_texts)
        and any("随着「啵」的一声轻响，清凉的气泡翻涌上来。弘子开心地接过竹团扇和汽水瓶，喝了一小口，满足地眯起眼睛：" in t for t in track_texts),
        f"Concept Lock #07 / V1.2 Rev #1 missing in {track_name} track: ramune & bamboo fan sequence",
    )
    # Concept Lock #8: Yukata meeting line
    require(
        any("怎么一声不吭地盯着我看呀……坂口医生不会以为我下班以后也只能穿护士服吧？" in t for t in track_texts),
        f"Concept Lock #08 missing in {track_name} track: yukata teasing line",
    )
    # Scene F2 lightweight RP choice (stall tour vs geta walking pace)
    require(
        any("「那接下来的屋台巡礼，就全听杉村向导安排了。」" in t for t in track_texts)
        and any("「呵呵，很有觉悟嘛！那我们先去前面那家排队最长的章鱼烧，等看完烟花回来，还要再去尝尝裹了脆糖衣的苹果糖才行！」" in t for t in track_texts)
        and any("「带路归带路，你今天穿着木屐，步子慢一点也没关系。」" in t for t in track_texts)
        and any("「……明明是我想拉着你到处逛，结果反倒又被你照顾了呢。嗯，那我们就慢慢走过去吧。」" in t for t in track_texts),
        f"Scene F2 RP choice lines missing in {track_name} track",
    )

# Concept Lock #9: Crowd hand-holding differential (Lv3 vs Lv4+)
require(
    any("坂口医生，让您久等了吗？" in t for t in summer_lv3_texts)
    and any("……既然是坂口医生主动牵住的，那等会儿要是走丢了，可全都是主刀医生的责任哦。" in t for t in summer_lv3_texts),
    "Concept Lock #09 missing in Lv3 track: sleeve tug & primary surgeon's responsibility line",
)
require(
    any("隆司，让你久等了吗？" in t for t in summer_lv4_texts)
    and any("呵呵，人这么多，要是不把男朋友牵紧一点，万一被挤丢了可怎么办呀？" in t for t in summer_lv4_texts)
    and any("明明是隆司自己在人群里不够主动，居然还倒打一耙怪起我来了。" in t for t in summer_lv4_texts),
    "Concept Lock #09 missing in Lv4+ track: intertwined fingers & boyfriend teasing lines",
)

# Concept Lock #10: Fireworks climax line & distance differential
for track_name, track_texts in (("lv3", summer_lv3_texts), ("lv4", summer_lv4_texts)):
    require(
        any("……今年能来，真好。" in t for t in track_texts),
        f"Concept Lock #10 missing in {track_name} track: fireworks climax line",
    )
require(
    any("没有多余的言语，弘子只是将还与他相牵的手指轻轻收紧了一下，随后略带羞赧地弯起嘴角，重新仰起头望向夜空。" in t for t in summer_lv3_texts),
    "Concept Lock #10 missing in Lv3 track: silent finger squeeze under fireworks",
)
require(
    any("以后有机会，再一起看吧，隆司。" in t for t in summer_lv4_texts)
    and any("嗯，只要你想看，以后我们再一起来。" in t for t in summer_lv4_texts),
    "Concept Lock #10 missing in Lv4+ track: shoulder lean & future promise under fireworks",
)

# Concept Lock #11: Closing differential & contextual non-rank-changing contract
require(
    any("怎么样，坂口医生？刚才倒数第三发那朵蓝紫色的绣球花烟花，是不是超漂亮？" in t for t in summer_lv3_texts)
    and any("今天谢谢医生陪我来看烟花，我真的非常开心。回去的路上请小心，我们医院见！" in t for t in summer_lv3_texts),
    "Concept Lock #11 missing in Lv3 track: closing farewell",
)
require(
    any("怎么样，隆司？刚才倒数第三发那朵蓝紫色的绣球花烟花，是不是超漂亮？" in t for t in summer_lv4_texts)
    and any("没想到我们的『坂口医生』私底下这么会说好听的话，今晚的表现给你打满分。" in t for t in summer_lv4_texts),
    "Concept Lock #11 missing in Lv4+ track: closing farewell",
)
require(
    ev_summer.get("category") == "contextual"
    and ev_summer.get("trigger_mode") == "sunday"
    and ev_summer.get("consumes_sunday") is True
    and ev_summer.get("date_location_id") == "riverside_park"
    and ev_summer.get("opening_variants") == {"lv3": "hsf_lv3_001", "lv4": "hsf_lv4_001"},
    f"Summer fireworks event contract mismatch: {ev_summer.get('category')} / {ev_summer.get('trigger_mode')} / {ev_summer.get('opening_variants')}",
)

# Verify registration & conditions (including user-mandated presence <= -30 on Lv3)
bundle = json.loads(imp.BUNDLE.read_text(encoding="utf-8"))
require(
    "lv3_events.json" in bundle.get("additional_character_event_files", []),
    "nurse_hiroko/bundle.json missing lv3_events.json in additional_character_event_files",
)
rel = json.loads(imp.RELATIONSHIP.read_text(encoding="utf-8"))
slot3 = next((s for s in rel.get("rank_slots", []) if int(s.get("target_level", 0)) == 3), {})
expected_presence_req = [{"type": "player_attribute", "attribute": "presence", "minimum": -999, "maximum": -30}]
require(
    slot3.get("event_id") == imp.LV3_EVENT_ID
    and slot3.get("content_status") == "authored"
    and slot3.get("min_familiarity") == 40
    and slot3.get("special_requirements") == expected_presence_req,
    f"nurse_hiroko/relationship.json Lv3 slot mismatch: {slot3}",
)
require(
    ev_lv3.get("conditions", {}).get("special_requirements") == expected_presence_req
    and ev_lv3.get("conditions", {}).get("required_events") == ["hiroko_lv2_on_time_off_work"],
    "hiroko_lv3_another_hospital_lights conditions must retain presence <= -30 and require hiroko_lv2_on_time_off_work",
)

# Verify backgrounds exist on disk
bgs = json.loads(imp.BACKGROUNDS.read_text(encoding="utf-8"))
bg_by_id = {b.get("id"): b for b in bgs if isinstance(b, dict)}
for nb in imp.NEW_BACKGROUNDS:
    require(nb["id"] in bg_by_id, f"missing background {nb['id']} in backgrounds.json")
    require((ROOT / nb["path"]).is_file(), f"missing background asset on disk: {nb['path']}")

# Verify bilingual localization completeness and zero CJK residue in English
zh = json.loads(imp.LOCALIZATION_ZH.read_text(encoding="utf-8"))["strings"]
en = json.loads(imp.LOCALIZATION_EN.read_text(encoding="utf-8"))["strings"]
cjk_re = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")

for ev in (ev_lv3, ev_summer):
    ev_id = ev["id"]
    prefix = f"collections.character_events.{ev_id}"
    for key in [f"{prefix}.title", f"{prefix}.teaser", f"{prefix}.gallery.caption"]:
        require(bool(zh.get(key)) and bool(en.get(key)), f"missing localization key {key}")
        require(not cjk_re.search(en.get(key, "")), f"CJK residue in English key {key}")
    for node in ev["nodes"]:
        nid = node["id"]
        for suffix in ("text", "speaker_label"):
            k = f"{prefix}.nodes.{nid}.{suffix}"
            require(bool(zh.get(k)) and bool(en.get(k)), f"missing node localization {k}")
            require(not cjk_re.search(en.get(k, "")), f"CJK residue in {k}: {en.get(k)}")
        for choice in node.get("choices", []):
            cid = choice["id"]
            ck = f"{prefix}.nodes.{nid}.choices.{cid}.label"
            require(bool(zh.get(ck)) and bool(en.get(ck)), f"missing choice localization {ck}")
            require(not cjk_re.search(en.get(ck, "")), f"CJK residue in {ck}: {en.get(ck)}")

if failures:
    for item in failures:
        print("FAIL:", item, file=sys.stderr)
    sys.exit(1)

print(
    f"Hiroko Lv3 & Summer Fireworks source audit passed: "
    f"Lv3={len(actual_lv3)} beats ({len(used_lv3_paths)} expressions), "
    f"Summer={len(actual_summer)} beats ({len(used_summer_paths)} yukata expressions), "
    f"4 new backgrounds, 0 failures."
)
