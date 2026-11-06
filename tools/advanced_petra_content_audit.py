#!/usr/bin/env python3
"""Compare Petra's generated Chinese lines, roles, and order with the author's draft."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data/advanced_surgery"
SRC = (ROOT / "docs/source_materials/petra/HOSHIMI_ADVANCED_PETRA_THORACOLUMBAR_KYPHOSIS_DESIGN_V1.md").read_text()
ID = "surgery_adv_posttraumatic_thoracolumbar_kyphosis_correction"


def read(path):
    return json.loads(path.read_text())


def bilingual(row):
    assert row["text_en"].strip() and not re.search(r"[\u3400-\u9fff]", row["text_en"]), row


story = read(DATA / "stories" / (ID + ".json"))
for number, chapter in [(4, "day1"), (6, "day3")]:
    block = SRC.split(f"## {number}. ", 1)[1].split("## ", 1)[0]
    original = re.findall(r"(?m)^\d{2}\. (旁白|坂口|佩特拉)：(.+)$", block)
    rows = story[chapter]["lines"]
    assert len(original) == len(rows)
    for (speaker, text), row in zip(original, rows):
        assert row["speaker"] == {"旁白": "narrator", "坂口": "PLAYER", "佩特拉": "patient"}[speaker]
        assert row["text"] == text
        bilingual(row)

dialogue = read(DATA / "dialogue_v2" / (ID + ".json"))
assert dialogue["schema_version"] == "advanced_day2_dialogue_v2"
section = SRC.split("## 5. Day 2", 1)[1].split("### 5.1", 1)[0]
original_stages = re.findall(r"(?ms)^### (T\d\d) .+?\n(.*?)(?=^### T\d\d |\Z)", section)
assert len(original_stages) == len(dialogue["stages"]) == 12
for stage, body in original_stages:
    for phase in ("before_action", "after_resolution"):
        original = re.findall(r"(?m)^\d\. \[([a-z_0-9]+)\]「(.+?)」$", body.split(f"**{phase}**", 1)[1].split("**", 1)[0])
        rows = dialogue["stages"][stage][phase]
        assert len(original) == len(rows) == 2
        for (role, text), row in zip(original, rows):
            assert (row["speaker_role"], row["text"]) == (role, text)
            bilingual(row)
failures = re.findall(r"(?m)^- (T\d\d) \[([a-z_0-9]+)\]「(.+?)」$", SRC.split("### 5.1", 1)[1].split("### 5.2", 1)[0])
assert len(failures) == 12
for stage, role, text in failures:
    assert any(row["speaker_role"] == role and row["text"] == text for row in dialogue["stages"][stage]["precision_failed"])
crisis = SRC.split("### 5.2", 1)[1].split("## 6.", 1)[0]
for stage, label in (("T07", "A"), ("T10", "B")):
    block = crisis.split(f"**Crisis {label}", 1)[1].split("**", 1)[1]
    block = block.split("**Crisis B" if label == "A" else "这些对白", 1)[0]
    original = re.findall(r"(?m)^- \[([a-z_0-9]+)\]「(.+?)」$", block)
    rows = dialogue["stages"][stage]["crisis"]
    assert len(original) == len(rows) == 3
    for (role, text), row in zip(original, rows):
        assert (row["speaker_role"], row["text"]) == (role, text)
        bilingual(row)

procedure = next(p for p in read(DATA / "procedures.json") if p["id"] == ID)
assert len(procedure["steps"]) == 12
assert sum(s["strategic_effects"]["elapsed_time"] for s in procedure["steps"]) == 480
assert sum(s["hp_base"] for s in procedure["steps"]) == 43
assert sum(s["kind"] == "P" for s in procedure["steps"]) == 6
assert sum(s["kind"] == "S" for s in procedure["steps"]) == 2
assert procedure["crisis_checkpoints"] == [7, 10]
for step in procedure["steps"]:
    for option in step.get("options", []):
        assert option["label"] in SRC and option["description"] in SRC
        assert option["label_en"].strip() and option["description_en"].strip()
manifest = next(r for r in read(DATA / "release_manifest.json") if r["procedure_id"] == ID)
assert manifest["release_order"] == 7 and manifest["runtime_ready"]
seed_paths = story["patient"]["visuals"]["seed_references"]
assert all((ROOT / path).is_file() for path in seed_paths.values())
portraits = story["patient"]["visuals"]["portraits"]
expected = {
    "ward": "assets/characters/advanced_petra_v1/ward.png",
    "postop": "assets/characters/advanced_petra_v1/postop.png",
    "team_confirmation": "assets/characters/advanced_petra_v1/team_confirmation.png",
    "intraoperative/anesthetized": "assets/characters/advanced_petra_v1/anesthesia.png",
    "splash/general_anesthesia": "assets/characters/advanced_petra_v1/anesthesia.png",
}
assert portraits == expected
assert all((ROOT / path).is_file() for path in portraits.values() if path)
assert not set(seed_paths.values()) & set(portraits.values()), "Seed references cannot replace scene art"
field = read(DATA / "field_windows.json")[ID]
assert field["after_stage"] == "T02" and field["before_stage"] == "T12"
assert {field[key] for key in ("path", "incision_path", "closure_path")} == {
    "assets/surgeries/advanced_fields_v1/petra_spinal_field.png",
    "assets/surgeries/advanced_fields_v1/petra_posterior_incision.png",
    "assets/surgeries/advanced_fields_v1/petra_spinal_closure.png",
}
assert all((ROOT / field[key]).is_file() for key in ("path", "incision_path", "closure_path"))
print("PETRA SOURCE AUDIT PASS: 47 story lines, 48 V2 stage lines, 12 failure lines, 6 crisis lines; Chinese roles/order exact; English present; seven scene assets mapped")
