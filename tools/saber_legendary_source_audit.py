#!/usr/bin/env python3
"""Independent verbatim line-by-line & numerical auditor for Saber Legendary Surgery V1.1."""
from __future__ import annotations
import hashlib
import json
import re
from pathlib import Path
from import_saber_legendary import ROOT, DATA, ID, SURG_SRC, VN_SRC, build

proc, story, dialogues, registry_entry, ui_map = build()
surg_raw = SURG_SRC.read_text(encoding="utf-8")
vn_raw = VN_SRC.read_text(encoding="utf-8")
checks = 0


def check(ok: bool, msg: str):
    global checks
    checks += 1
    if not ok:
        raise AssertionError(msg)


# 1. Procedure definition & V1.1 Concept Lock numbers
all_procs = json.loads((DATA / "legendary_procedures.json").read_text(encoding="utf-8"))
actual_proc = next((p for p in all_procs if p["id"] == ID), None)
check(actual_proc is not None, "Missing procedure in legendary_procedures.json")
check(actual_proc == proc, "Runtime procedure differs from declared V1.1 importer output")
check(len(actual_proc["steps"]) == 18, "Must have exactly 18 stages")
kinds = [s["kind"] for s in actual_proc["steps"]]
check(
    kinds.count("F") == 4 and kinds.count("L") == 3 and kinds.count("S") == 3 and kinds.count("P") == 8,
    f"Stage kind breakdown must be F4/L3/S3/P8, got {kinds}",
)
check(sum(s["hp_base"] for s in actual_proc["steps"]) == 54, "Total base HP must be 54")
check(sum(s["strategic_effects"]["elapsed_time"] for s in actual_proc["steps"]) == 729, "Total base time must be 729")
check(actual_proc["crisis_checkpoints"] == [8, 12, 17], "Crisis checkpoints must be [8, 12, 17]")
check(sum(len(s.get("conditional_effects", [])) for s in actual_proc["steps"]) == 7, "Must have 7 conditional_effects")
check(
    actual_proc["base_difficulty"] == 99
    and actual_proc["training_ceiling"] == 100
    and actual_proc["reward_tier"] == "advanced"
    and actual_proc["dialogue_after_rescue"] is True,
    "Top-level calibration mismatch",
)

# Check every S-option CN/EN text is verbatim in SURG_SRC
for step in actual_proc["steps"]:
    check(step["name"] in surg_raw and step["name_en"] in surg_raw, f"Stage title not verbatim: {step['id']}")
    for opt in step.get("options", []):
        for k in ("label", "label_en", "description", "description_en"):
            check(opt[k] in surg_raw, f"Strategy text not verbatim: {opt['id']}.{k}")
        check(not re.search(r"[\u4e00-\u9fff]", opt["label_en"]), f"Chinese leak in {opt['id']}.label_en")
        check(not re.search(r"[\u4e00-\u9fff]", opt["description_en"]), f"Chinese leak in {opt['id']}.description_en")

# 2. Three-Day VN verbatim line-by-line + choice audit (`A01..I18` = 266 lines + 4 choices)
runtime_story = json.loads((DATA / "stories" / f"{ID}.json").read_text(encoding="utf-8"))
check(runtime_story == story, "Runtime story JSON differs from declared V1.1 importer output")
check(runtime_story["patient"]["id"] == "patient_maiya_hisau", "Patient ID must be patient_maiya_hisau")

expected_vn_bullets = re.findall(
    r"^- \*\*([A-I]\d+(?:_EX\d+|[ABC])?)｜([^*]+)\*\*｜CN(「.*?」)｜EN\s*(“.*?”)\s*$", vn_raw, re.M
)
check(len(expected_vn_bullets) == 266, f"Expected 266 author VN lines, found {len(expected_vn_bullets)}")

flat_runtime_lines = (
    runtime_story["day1"]["lines"] + runtime_story["day2"]["lines"] + runtime_story["day3"]["lines"]
)
check(len(flat_runtime_lines) == 266, f"Runtime total VN lines mismatch: {len(flat_runtime_lines)}")

speaker_backmap = {
    "narrator": "旁白",
    "PLAYER": "坂口隆司",
    "patient": "久宇舞弥",
    "doc_artoria": "阿尔托莉雅",
    "ward_nurse": "病房护士",
    "anesthesiologist": "麻醉医师",
}
for (exp_id, exp_who, exp_cn, exp_en), row in zip(expected_vn_bullets, flat_runtime_lines):
    check(row["id"] == exp_id, f"VN line order/ID mismatch: expected {exp_id}, got {row['id']}")
    check(speaker_backmap[row["speaker"]] == exp_who.strip(), f"Speaker mismatch on {exp_id}")
    check(row["text"] == exp_cn, f"Verbatim CN mismatch on {exp_id}")
    check(row["text_en"] == exp_en, f"Verbatim EN mismatch on {exp_id}")
    check(not re.search(r"[\u4e00-\u9fff]", row["text_en"]), f"Chinese leak in {exp_id} EN")

choice_lines = [r for r in flat_runtime_lines if "choices" in r]
check([r["id"] for r in choice_lines] == ["A25", "C26", "G29", "H30"], "Choice anchor IDs mismatch")
for r in choice_lines:
    for c in r["choices"]:
        check(c["label"] in vn_raw and c["label_en"] in vn_raw, f"Choice text not verbatim: {c['id']}")
        check(not re.search(r"[\u4e00-\u9fff]", c["label_en"]), f"Chinese leak in {c['id']} EN")

# 3. Operative Dialogue (`dialogue_teaching` & `dialogue_v2`) verbatim & §4.2 order audit
for mode, folder, prefix in [("teaching", "dialogue_teaching", "_S_"), ("standard", "dialogue_v2", "_G_")]:
    ddata = json.loads((DATA / folder / f"{ID}.json").read_text(encoding="utf-8"))
    check(ddata == dialogues[mode], f"Runtime {mode} dialogue differs from importer")
    for sid, groups in ddata["stages"].items():
        ba = groups["before_action"]
        ar = groups["after_resolution"]
        check(len(ba) == 3, f"{sid} before_action must have 3 lines")
        if sid in ("WH01", "WH18"):
            check(ba[1]["speaker_role"] == "lead_surgeon" and ba[2]["id"].startswith("AS"), f"{sid} §4.2 order mismatch")
        else:
            check(ba[0]["speaker_role"] == "lead_surgeon" and ba[1]["id"].startswith("AS"), f"{sid} §4.2 order mismatch")
        for grp_name, rows in groups.items():
            for row in rows:
                check(row["text"] in surg_raw, f"{mode}/{row['id']} CN not verbatim in SURG_SRC")
                check(row["text_en"] in surg_raw, f"{mode}/{row['id']} EN not verbatim in SURG_SRC")
                check(not re.search(r"[\u4e00-\u9fff]", row["text_en"]), f"Chinese leak in {row['id']}")
                if row["id"].startswith("AS"):
                    check(prefix in row["id"], f"Cross-branch contamination on {mode}/{row['id']}")

# 4. Registry UI strings & Asset SHA-256 verification
reg_entries = json.loads((DATA / "legendary_registry.json").read_text(encoding="utf-8"))
saber_reg = next((r for r in reg_entries if r["procedure_id"] == ID), None)
check(saber_reg is not None and saber_reg["mentor"] == "doc_artoria", "Registry entry missing/wrong mentor")
for k, pair in saber_reg["ui_text"].items():
    check(pair[0] in surg_raw and pair[1] in surg_raw, f"Registry UI {k} not verbatim in SURG_SRC")
    check(not re.search(r"[\u4e00-\u9fff]", pair[1]), f"Chinese leak in registry UI {k}")

asset_manifest = json.loads((ROOT / "assets/characters/maiya_hisau_legendary_v1/manifest.json").read_text(encoding="utf-8"))
check(len(asset_manifest["assets"]) == 13, "Expected 12 patient assets plus 1 operative field in manifest")
for row in asset_manifest["assets"]:
    p = ROOT / row["path"]
    check(p.exists(), f"Missing runtime asset {p}")
    check(hashlib.sha256(p.read_bytes()).hexdigest() == row["sha256"], f"SHA mismatch on {p}")

print(f"SABER SOURCE AUDIT: {checks} checks; 0 failures")
