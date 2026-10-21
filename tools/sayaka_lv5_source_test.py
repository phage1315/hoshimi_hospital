#!/usr/bin/env python3
"""Independent exact-text audit of the V3 base plus the V3.2 A02/A03 patch."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
source = (ROOT / "docs/sources/HOSHIMI_NANJOU_SAYAKA_LV5_V3_FULL_CN_REVIEW.md").read_text()
patch = (ROOT / "docs/sources/HOSHIMI_SAYAKA_LV5_A02_A03_V3_2_USER_AS_IS_PATCH.md").read_text()
steps = json.loads((ROOT / "data/events/special_event_steps/sayaka_lv5.json").read_text())
english = json.loads((ROOT / "tools/sayaka_lv5_en_text.json").read_text())
locale = json.loads((ROOT / "data/localization/en.json").read_text())["strings"]
nodes = {n["id"]: n for step in steps for n in step["nodes"]}
checks = 0


def expect(condition, message):
    global checks
    checks += 1
    assert condition, message


# Deliberately accept every authored marker, not just the importer's ID regex:
# mixed H/V2 node numbering must not silently disappear.
marker = r"^【(?:新增)?演出节点 ([^｜]+)｜([^】]+)】\s*\n([^\n]+)"
base_authored = list(re.finditer(marker, source, re.M))
patch_authored = list(re.finditer(marker, patch, re.M))
base_authored = [m for m in base_authored if not m.group(1).startswith(("A02-", "A03-"))]
patch_authored = [m for m in patch_authored if m.group(1).startswith(("A02-", "A03-"))]
authored = [m for m in base_authored if m.group(1).startswith("A01-")]
authored += [m for m in patch_authored if m.group(1).startswith("A02-")]
authored += [m for m in patch_authored if m.group(1).startswith("A03-")]
authored += [m for m in base_authored if m.group(1).startswith(("A04-", "B", "C"))]
expect(len(authored) == 598, "V3 base plus V3.2 patch authored node count")
expect(len(nodes) == 602, "598 authored lines plus four branch replies")
caps = {"neutral": "base", "smile": "smile", "mischief": "mischief", "blush": "blush",
        "roleplay_fear": "roleplay_fear", "real_fear": "real_fear", "exhausted": "exhausted",
        "pain_shout": "pain_shout", "pain_endure": "pain_endure", "soft": "soft", "relieved": "relieved"}
expected_by_part = {part: [] for part in "abc"}
seen_ids = set()
for match in authored:
    source_id, metadata, body = match.groups()
    key = source_id.lower().replace("-", "_")
    if key in seen_ids:
        key += "_tail01"
    seen_ids.add(source_id.lower().replace("-", "_"))
    expected_by_part[key[0]].append(key)
    expect(key in nodes, f"Missing source node {source_id}")
    node = nodes[key]
    speaker, text = body.split("：", 1)
    expect(node["text"] == text, f"Text/punctuation changed at {key}")
    expect(node["speaker_label"] == speaker, f"Speaker changed at {key}")
    role = "narrator" if speaker == "旁白" else "player" if speaker == "坂口隆司" else "actor"
    expect(node["speaker"] == role, f"Speaker role changed at {key}")
    meta = dict(x.split("=", 1) for x in metadata.split("｜") if "=" in x)
    mood = meta.get("当前小夜香", "")
    if mood.startswith("cap_") and not node.get("cg_path"):
        path_key = "portrait_path" if speaker in ["旁白", "南条小夜香", "坂口隆司"] else "secondary_portrait_path"
        expect(node.get(path_key, "").endswith("/" + caps[mood[4:]] + ".png"), f"Wrong cap expression at {key}")
    if mood == "portrait_hidden_hair_down":
        expect(node.get("hide_portrait") is True and "portrait_path" not in node, f"Cap/dressed image still visible at {key}")
    if "不出立绘" in meta.get("本句立绘/表情", ""):
        expect(node.get("hide_portrait") is True, f"Offscreen actor visible at {key}")

for step in steps:
    part = step["nodes"][0]["id"][0]
    source_ids = expected_by_part[part]
    actual_ids = [n["id"] for n in step["nodes"] if n["id"] in set(source_ids)]
    expect(actual_ids == source_ids, f"Authored order changed in {part}")
    for i, key in enumerate(source_ids):
        if key == "a01_0014":
            continue
        destination = source_ids[i + 1] if i + 1 < len(source_ids) else "@day_end"
        expect(nodes[key]["choices"][0]["next"] == destination, f"Incorrect next node at {key}")
    for node in step["nodes"]:
        prefix = f"collections.special_event_steps.{step['id']}.nodes.{node['id']}"
        expect(english.get(node["id"]) == locale.get(prefix + ".text"), f"English map not synced: {node['id']}")
        expect(bool(english.get(node["id"])) and not re.search(r"[\u3400-\u9fff]", english[node["id"]]), f"Missing English: {node['id']}")
        for field in ["portrait_path", "secondary_portrait_path", "cg_path"]:
            if field in node:
                expect((ROOT / node[field]).is_file(), f"Missing resource {node[field]}")

branch_block = source.split("【选择节点 A01-CHOICE", 1)[1].split("## A02.", 1)[0]
branches = re.findall(r'- \*\*「([^」]+)」\*\* → ([^：]+)：([^\n]+)\n\s*([^：]+)：([^\n]+)→', branch_block)
expect(len(branches) == 2, "Two authored branches")
for branch, choice in zip(branches, nodes["a01_0014"]["choices"]):
    label, speaker1, line1, speaker2, line2 = branch
    expect(choice["label"] == label, "Choice punctuation must match source")
    first = nodes[choice["next"]]
    second = nodes[first["choices"][0]["next"]]
    expect((first["speaker_label"], first["text"]) == (speaker1.strip(), line1.strip()), "First branch reply")
    expect((second["speaker_label"], second["text"]) == (speaker2.strip(), line2.strip()), "Second branch reply")

expect(nodes["a03_h_0001_ins06"]["exit_blackout_seconds"] == 1.0, "One-second blackout after final authored A03 line")
expect([n["id"] for n in nodes.values() if n.get("cg_path")] == ["a04_0001", "b04_0001", "c03_0038"], "Exactly three CG cues at approved positions")
expect(nodes["c01_0001"]["background_id"] == "hallway" and nodes["c04_0001"]["background_id"] == "hallway", "Office-exterior scenes must remain in corridor")
print(f"SAYAKA LV5 V3.2 SOURCE AUDIT: {checks} checks; 0 failures")
