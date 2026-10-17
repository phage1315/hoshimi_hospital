#!/usr/bin/env python3
"""Read-only V2 identity/old-value gate; never applies a numeric patch.

Export first with tools/surgery_calibration_export.gd, then pass --runtime and
the user's original --archive. A nonzero exit blocks numeric implementation.
The reviewed crosswalk is checked against the archive and actual loader output;
no array index or design short ID is used to locate a runtime option.
"""
import argparse
import csv
import hashlib
import io
import json
from pathlib import Path
import zipfile

from calibration_semantics import verify

ROOT = Path(__file__).resolve().parents[1]
CROSSWALK = ROOT / "docs/qa/calibration_20261014_v2_identity.json"
PREFIX = "HOSHIMI_27_PROCEDURE_CALIBRATION/"


def audit(archive, runtime_path):
    crosswalk = json.loads(CROSSWALK.read_text())
    if hashlib.sha256(archive.read_bytes()).hexdigest() != crosswalk["source_zip_sha256"]:
        raise ValueError("Archive is not the reviewed V2; establish a new crosswalk first")
    with zipfile.ZipFile(archive) as z:
        def read(name):
            return json.loads(z.read(PREFIX + name).decode("utf-8-sig"))
        intents = read("identity_repair/CODEX_PATCH_817_WITH_SEMANTIC_ANCHORS.json")
        hints = {x["design_option_key"]: x for x in read("identity_repair/DESIGN_OPTION_HINTS.json")}
        classes = list(csv.DictReader(io.StringIO(z.read(PREFIX + "identity_repair/EXPECTED_FLS_CLASS_ALL_30_DESIGN.csv").decode("utf-8-sig"))))
    runtime = json.loads(runtime_path.read_text())
    if runtime.get("source") != "ContentLoader.load_all(zh_CN)":
        raise ValueError("Expected real Chinese ContentLoader export")
    target_keys = {f"{p['procedure_id']}/{p['stage_index']}/{p['option']}" for p in intents}
    targets = [x for x in crosswalk["options"] if x["design_option_key"] in target_keys]
    issues, verified = verify(intents, hints, targets, runtime)
    class_by_key = {r["design_procedure_alias"] + "/" + r["design_stage_index_0based"]: r for r in classes}
    seen = set()
    counts = {"F": 0, "L": 0, "S": 0}
    double_s = []
    for row in crosswalk["stages"]:
        key = row["design_stage_key"]
        declared = class_by_key[key]
        risk = "L" if declared["author_declared_class"] == "Conditional" else declared["author_declared_class"]
        pid, sid = row["canonical_procedure_id"], row["runtime_stage_id"]
        if (pid, sid) in seen:
            issues.append(f"Duplicate stage mapping: {pid}/{sid}")
        seen.add((pid, sid))
        candidates = [s for s in runtime["procedures"][pid]["stages"] if s["id"] == sid]
        if len(candidates) != 1:
            issues.append(f"Missing/ambiguous stage: {pid}/{sid}")
            continue
        stage = candidates[0]
        if stage.get("risk_class") != risk or row["risk_class"] != risk:
            issues.append(f"Wrong authored risk class: {pid}/{sid}, expected {risk}")
        if stage["title"] != row["runtime_title"] or [o["id"] for o in stage["options"]] != row["runtime_option_ids"]:
            issues.append(f"Stage title/options drift: {pid}/{sid}")
        if len(stage["options"]) != int(declared["option_count"]):
            issues.append(f"Design option count drift: {key}")
        if (stage.get("stage_kind") == "conditional_correction") != (declared["author_declared_class"] == "Conditional"):
            issues.append(f"Correction kind drift: {key}")
        counts[risk] += 1
        if risk == "S" and len(stage["options"]) == 2:
            double_s.append(pid + "/" + sid)
    actual = {(pid, s["id"]) for pid in {r["canonical_procedure_id"] for r in classes} for s in runtime["procedures"][pid]["stages"]}
    if seen != actual or len(seen) != 358 or len(double_s) != 17:
        issues.append("Incomplete 358-stage / 17-double-S classification coverage")
    option_by_key = {x["design_option_key"]: x for x in crosswalk["options"]}
    scalar_pass = 0
    for p in intents:
        key = f"{p['procedure_id']}/{p['stage_index']}/{p['option']}"
        row = option_by_key[key]
        stage = next(s for s in runtime["procedures"][row["canonical_procedure_id"]]["stages"] if s["id"] == row["runtime_stage_id"])
        option = next(o for o in stage["options"] if o["id"] == row["runtime_option_id"])
        effects = option["strategic_effects"] if p["branch"] == "main" else option["conditional_effects"][int(p["branch"].rsplit("_", 1)[-1])]["strategic_effects"]
        scalar_pass += effects.get(p["field"]) == p["old"]
    # Verify all source option identities, including ones with no patch target.
    for row in crosswalk["options"]:
        pid = row["canonical_procedure_id"]
        stage = next(s for s in runtime["procedures"][pid]["stages"] if s["id"] == row["runtime_stage_id"])
        option = next(o for o in stage["options"] if o["id"] == row["runtime_option_id"])
        if option["label"] != row["runtime_choice_text"] or option.get("correct") is not True:
            issues.append(f"Option identity drift: {row['design_option_key']}")
    report = {
        "status": "BLOCKED" if issues else "VERIFIED",
        "archive_sha256": crosswalk["source_zip_sha256"],
        "runtime_export_sha256": hashlib.sha256(runtime_path.read_bytes()).hexdigest(),
        "scalar_old_values_matched": scalar_pass,
        "fully_verified_patch_rows": len(verified),
        "mapped_stages": len(seen), "mapped_options": len(crosswalk["options"]),
        "class_counts": counts, "double_option_S": double_s, "issues": issues,
        "numeric_patch_applied": False,
    }
    return report, verified if not issues else []


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", required=True, type=Path)
    parser.add_argument("--runtime", required=True, type=Path)
    args = parser.parse_args()
    report, _ = audit(args.archive, args.runtime)
    print(json.dumps(report, ensure_ascii=False, indent=2))
    raise SystemExit(2 if report["issues"] else 0)
