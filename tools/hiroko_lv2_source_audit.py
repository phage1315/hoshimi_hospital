#!/usr/bin/env python3
"""Strict source fidelity, Concept Lock, V1.2 revision log, bilingual localization,
and portrait/background audit for Hiroko Sugimura's Relationship Lv2 event V1.2:
《难得准时下班》 (hiroko_lv2_on_time_off_work).
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import import_hiroko_lv2 as imp

failures: list[str] = []


def require(ok: bool, message: str) -> None:
    if not ok:
        failures.append(message)


expected = imp.parse_beats()
events = json.loads(imp.OUTPUT.read_text(encoding="utf-8"))
require(len(events) == 1, "lv2_events.json must contain exactly one event")
event = events[0] if events else {}
actual = event.get("nodes", [])

require(len(expected) == 169, f"canonical parser beat count drift: {len(expected)}")
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
        "outfit",
        "background_id",
        "hide_portrait",
        "cg_path",
        "cg_fit",
        "event_portraits",
        "choices",
    ]:
        require(node.get(field) == source.get(field), f"{source['id']} source drift in {field}")
    require("**" not in str(node.get("text", "")), f"{source['id']} leaked Markdown emphasis")

# Verify Scene 4 CG windows & gallery reward
require((ROOT / imp.CG_SMILE_PATH).is_file(), f"missing smile CG on disk: {imp.CG_SMILE_PATH}")
require((ROOT / imp.CG_POUT_PATH).is_file(), f"missing pout CG on disk: {imp.CG_POUT_PATH}")
gallery = event.get("gallery", {})
require(
    gallery.get("path") == imp.CG_SMILE_PATH and gallery.get("show_on_complete") is True,
    f"gallery reward mismatch: {gallery}",
)
for node in actual:
    idx = int(str(node["id"]).split("_")[1])
    if idx in imp.CG_SMILE_BEATS:
        require(
            node.get("cg_path") == imp.CG_SMILE_PATH
            and node.get("cg_fit") == "cover"
            and node.get("hide_portrait") is False
            and not node.get("event_portraits"),
            f"{node['id']} smile CG node contract mismatch",
        )
    elif idx in imp.CG_POUT_BEATS:
        require(
            node.get("cg_path") == imp.CG_POUT_PATH
            and node.get("cg_fit") == "cover"
            and node.get("hide_portrait") is False
            and not node.get("event_portraits"),
            f"{node['id']} pout CG node contract mismatch",
        )
    else:
        require(not node.get("cg_path"), f"{node['id']} unexpected cg_path outside CG window")

# Verify scrubs & casual expression variety for Hiroko
hiroko_profile = json.loads((ROOT / "data/staff/nurse_hiroko/profile.json").read_text(encoding="utf-8"))
used_paths: set[str] = set()
for node in actual:
    for ep in node.get("event_portraits", []):
        p = str(ep.get("path", ""))
        require((ROOT / p).is_file(), f"{node['id']} missing portrait file on disk: {p}")
        if ep.get("id") == "nurse_hiroko":
            used_paths.add(p)

for expr, path in imp.HIROKO_SCRUBS_PORTRAITS.items():
    require(
        hiroko_profile["visuals"]["portraits"].get(f"scrubs/{expr}") == path,
        f"Hiroko profile missing scrubs/{expr} -> {path}",
    )
    require((ROOT / path).is_file(), f"Hiroko scrubs/{expr} missing on disk: {path}")

for expr, path in imp.HIROKO_CASUAL_PORTRAITS.items():
    require(
        hiroko_profile["visuals"]["portraits"].get(f"casual/{expr}") == path,
        f"Hiroko profile missing casual/{expr} -> {path}",
    )
    require((ROOT / path).is_file(), f"Hiroko casual/{expr} missing on disk: {path}")

require(
    len(used_paths) == 13,
    f"Hiroko should use all 4 scrubs + 9 casual = 13 expressions in Lv2 event, found {len(used_paths)}",
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
require(reachable == set(by_id), f"unreachable nodes: {sorted(set(by_id) - reachable)}")

# Verify choice structure
require(
    sum(len(node.get("choices", [])) == 2 for node in actual) == 1,
    "expected exactly one 2-option RP choice node in Scene 3",
)

# Verify all 9 Concept Lock items and 3 V1.2 Revision items verbatim
texts = [str(node.get("text", "")) for node in actual]

bg_sequence: list[str] = []
for node in actual:
    bg = str(node.get("background_id", ""))
    if not bg_sequence or bg_sequence[-1] != bg:
        bg_sequence.append(bg)
require(
    bg_sequence
    == [
        "operating_room",
        "nurses_station",
        "hiroko_lv2_yoshoku_sweet_cafe",
        "hiroko_lv2_shopping_street_fukubiki",
        "after_work_street_spring_night",
    ],
    f"Concept Lock #01 background progression drift: {bg_sequence}",
)
require(
    any("只要再跟病房确认一下禁食情况与麻醉等准备条件，单纯性腹股沟斜疝修补在今晚临时加台，从医疗上倒是具有可行性" in t for t in texts),
    "Concept Lock #02 / V1.2 Rev #3 missing: Ryuji's medical feasibility check",
)
require(
    any("而且今晚夜班原本就有一名护士轮休，在岗的夜班护士人手非常紧" in t for t in texts)
    and any("不仅要动用今晚唯一的急诊备用器械包和备用手术间" in t for t in texts),
    "Concept Lock #02 missing: Hiroko's night-shift staffing & emergency reserve reasoning",
)
require(
    any("对于已经办妥住院手续的患者，院内制度上原本就允许根据实际情况将手术安排到晚间甚至深夜。" in t for t in texts)
    and not any("四点以后不再接收新入院患者" in t for t in texts),
    "V1.2 Rev #2 missing: natural hospital policy narration",
)
require(
    any("那我去把最后的交接记录确认一下，今天我们居然真的能五点准时下班了呢。" in t for t in texts)
    and not any("把这批器械送去消毒室" in t for t in texts),
    "V1.2 Rev #1 missing: fixed instrument vs handover log line at end of Scene 1",
)
require(
    any("你怎么连我接下来要问什么都知道？" in t for t in texts)
    and any("呵呵。保密。" in t for t in texts)
    and any("刚才在病房护士面前直接反驳您的提议，可能说得有点太直了" in t for t in texts),
    "Concept Lock #03 missing: verbatim reference dialogue & apology",
)
require(
    any("折页上根本不是什么医疗表格，而是满满当当的铜锣烧、蛋包饭与季节限定圣代照片。" in t for t in texts),
    "Concept Lock #04 missing: studying food brochure at nurses' station",
)
require(
    any("坂口医生今天难得也准时下班，如果晚上没有别的安排……要不要一起去试试看？" in t for t in texts),
    "Concept Lock #05 missing: Hiroko's spontaneous dinner invitation",
)
require(
    any("医生平时自己在家的时候，该不会都是用速食咖喱或者便利店便当随便打发晚饭吧？" in t for t in texts),
    "Concept Lock #06 missing: Hiroko teasing Ryuji at the Yoshoku bistro",
)
require(
    any("讨厌！医生真是不懂浪漫！" in t for t in texts),
    "Concept Lock #07 missing: Fukubiki lottery complaint line",
)
require(
    any("呵呵。夸奖哦。" in t for t in texts)
    and any("听着怎么不像？" in t for t in texts)
    and any("真的啦。" in t for t in texts)
    and any("不过，下次可不一定有这么好的机会哦？" in t for t in texts)
    and any("呵呵。开玩笑的。明天见！" in t for t in texts),
    "Concept Lock #08 missing: verbatim station parting lines",
)

# Verify registration & conditions (Concept Lock #09: no Manami Lv2 dependency, no season lock)
bundle = json.loads(imp.BUNDLE.read_text(encoding="utf-8"))
require(
    bundle.get("character_events") == "events.json"
    and "lv2_events.json" in bundle.get("additional_character_event_files", []),
    "nurse_hiroko/bundle.json missing lv2_events.json in additional_character_event_files",
)
rel = json.loads(imp.RELATIONSHIP.read_text(encoding="utf-8"))
slot2 = next((s for s in rel.get("rank_slots", []) if int(s.get("target_level", 0)) == 2), {})
require(
    slot2.get("event_id") == imp.EVENT_ID and slot2.get("content_status") == "authored",
    f"nurse_hiroko/relationship.json Lv2 slot not authored: {slot2}",
)
require(
    slot2.get("special_requirements") == []
    and event.get("conditions", {}).get("special_requirements") == []
    and event.get("conditions", {}).get("required_events") == ["hiroko_lv1_worth_it"],
    "Concept Lock #09 violation: Hiroko Lv2 must only require hiroko_lv1_worth_it without Manami or seasonal locks",
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
prefix = f"collections.character_events.{imp.EVENT_ID}"
for key in [f"{prefix}.title", f"{prefix}.teaser", f"{prefix}.gallery.caption"]:
    require(bool(zh.get(key)) and bool(en.get(key)), f"missing localization key {key}")
    require(not cjk_re.search(en.get(key, "")), f"CJK residue in English key {key}")

for node in actual:
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
    f"Hiroko Lv2 source audit passed: {len(actual)} beats, "
    f"{len(used_paths)} expressions (4 scrubs + 9 casual), 2 new backgrounds, 0 failures."
)
