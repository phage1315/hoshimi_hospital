#!/usr/bin/env python3
"""Verify every imported Lv5 line and branch against the numbered manuscripts."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import import_miyuki_lv5 as imp

cn = imp.nodes(imp.CN)
en = imp.nodes(imp.EN)
events = json.loads(imp.OUT.read_text())
strings = json.loads(imp.LOC.read_text())["strings"]
seen = []
failures = []
for event in events:
    prefix = "collections.character_events." + event["id"]
    for node in event["nodes"]:
        nid = node["id"][1:].split("_s")[0].upper()
        piece_index = int(node["id"].split("_s")[1]) - 1 if "_s" in node["id"] else 0
        if piece_index == 0:
            seen.append(nid)
        actor, label, label_en, cn_body, en_body = imp.fragments(cn[nid], en[nid], nid)[piece_index]
        if node["text"] != cn_body:
            failures.append(nid + " Chinese source drift")
        if node["speaker_label"] != label:
            failures.append(nid + " Chinese speaker drift")
        if strings.get(prefix + ".nodes." + node["id"] + ".text") != en_body:
            failures.append(nid + " English source drift")
        if strings.get(prefix + ".nodes." + node["id"] + ".speaker_label") != label_en:
            failures.append(nid + " English speaker drift")
        if len(node["choices"]) != (2 if nid in imp.CHOICES and piece_index == len(imp.fragments(cn[nid], en[nid], nid)) - 1 else 1):
            failures.append(nid + " choice count drift")
        if nid in imp.CHOICES and piece_index == len(imp.fragments(cn[nid], en[nid], nid)) - 1:
            expected = imp.CHOICES[nid]
            for choice, (suffix, cn_label, en_label, target) in zip(node["choices"], expected):
                if choice.get("label") != cn_label or choice.get("next") != "n" + target.lower():
                    failures.append(nid + suffix + " Chinese choice/target drift")
                loc_key = prefix + ".nodes." + node["id"] + ".choices." + choice["id"] + ".label"
                if strings.get(loc_key) != en_label:
                    failures.append(nid + suffix + " English choice drift")
if seen != list(cn) or seen != list(en):
    failures.append("node order drift")
expected_runtime_pages = {
    "miyuki_lv5_chie_operation": 87,
    "miyuki_lv5_my_turn_on_the_table": 83,
    "miyuki_lv5_capable_do_more": 23,
}
for event in events:
    if len(event.get("nodes", [])) != expected_runtime_pages[event["id"]]:
        failures.append(event["id"] + " runtime page count drift")
    if event["id"] == "miyuki_lv5_my_turn_on_the_table":
        for node in event.get("nodes", []):
            nid = str(node.get("id", ""))[1:].split("_s")[0].upper()
            expected_cg = imp.part_b_cg(nid)
            if node.get("cg_path", "") != expected_cg:
                failures.append(str(node.get("id", "")) + " Part B CG mapping drift")
            if expected_cg and not (ROOT / expected_cg).is_file():
                failures.append(str(node.get("id", "")) + " Part B CG file missing")
print("MIYUKI LV5 SOURCE AUDIT:", len(seen), "ordered bilingual nodes;", len(failures), "failures")
for failure in failures:
    print(failure)
raise SystemExit(bool(failures))
