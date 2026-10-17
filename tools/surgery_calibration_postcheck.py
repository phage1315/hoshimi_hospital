#!/usr/bin/env python3
"""Read-only exact-delta check for the approved V2 calibration.

Requires the untouched turn-start source snapshot, real Godot exports before
and after numeric application, and the original reviewed V2 archive. Re-runs
the old-value gate, then proves the complete data equals precisely two restored
conditions plus the unchanged 817 numeric changes. No files are written.
"""
import argparse
from collections import Counter
from copy import deepcopy
import hashlib
import json
from pathlib import Path

from surgery_calibration_audit import audit, ROOT

RESTORED = {
    "lhc_rework_b": "surgery_open_left_hemicolectomy",
    "lar_rework_b": "surgery_open_low_anterior_resection",
}
CONDITION = {
    "when": {"field": "bleeding", "op": "gte", "value": 32},
    "strategic_effects": {
        "blood_loss": 10, "stability": -5,
        "add_complications": [{"id": "closure_rework", "severity": "minor"}],
    },
}


def option(procedures, pid, sid, oid):
    stages = [s for s in procedures[pid]["stages"] if s["id"] == sid]
    assert len(stages) == 1, (pid, sid)
    options = [o for o in stages[0]["options"] if o["id"] == oid]
    assert len(options) == 1, (pid, sid, oid)
    return options[0]


def patch(procedures, rows):
    seen = set()
    for row in rows:
        key = tuple(row[k] for k in (
            "canonical_procedure_id", "runtime_stage_id", "runtime_option_id",
            "runtime_branch", "field"))
        assert key not in seen, ("Duplicate patch target", key)
        seen.add(key)
        target = option(procedures, *key[:3])
        effects = (target["strategic_effects"] if key[3] == "main" else
                   target["conditional_effects"][int(key[3].rsplit("_", 1)[1])]["strategic_effects"])
        assert effects[key[4]] == row["old"], ("Old value mismatch", key)
        assert row["new"] != row["old"], ("No-op patch", key)
        effects[key[4]] = row["new"]
    assert len(seen) == 817


def check(archive, source_before, runtime_before, runtime_after):
    report, rows = audit(archive, runtime_before)
    assert report["status"] == "VERIFIED" and len(rows) == 817, report
    ledger_path = ROOT / "docs/qa/calibration_20261014_v2_applied_patch.json"
    ledger = json.loads(ledger_path.read_text())
    assert ledger["archive_sha256"] == report["archive_sha256"]
    assert ledger["columns"] == ["procedure_id", "stage_id", "option_id", "branch", "field", "old", "new"]
    assert ledger["rows"] == [[r[k] for k in (
        "canonical_procedure_id", "runtime_stage_id", "runtime_option_id",
        "runtime_branch", "field", "old", "new")] for r in rows], "Applied ledger differs from original V2 intents"
    original = json.loads(source_before.read_text())
    expected = deepcopy(original)
    by_id = {p["id"]: p for p in expected}
    for oid, pid in RESTORED.items():
        target = option(by_id, pid, oid[:-2], oid)
        assert "conditional_effects" not in target
        target["conditional_effects"] = [deepcopy(CONDITION)]
    patch(by_id, rows)
    source_path = ROOT / "data/surgeries/surgeries.json"
    current = json.loads(source_path.read_text())
    assert current == expected, "Source differs from two restorations + exactly 817 authorized fields"
    # Compare whole real-loader records as well, not only source JSON numbers.
    loaded_expected = json.loads(runtime_before.read_text())
    patch(loaded_expected["procedures"], rows)
    loaded_actual = json.loads(runtime_after.read_text())
    assert loaded_actual == loaded_expected, "Godot loader output differs from exact candidate"
    untouched = [p["id"] for p, q in zip(original, current) if p == q]
    for pid in ["surgery_appendix", "surgery_open_abdominal_myomectomy", "surgery_cabg"]:
        assert pid in untouched, ("Pilot unexpectedly changed", pid)
    original_by_id = {p["id"]: p for p in original}
    conditions = {}
    for pid, sid, oid in [
        ("surgery_open_abdominoperineal_resection", "apr_rework", "apr_rework_b"),
        (RESTORED["lhc_rework_b"], "lhc_rework", "lhc_rework_b"),
        (RESTORED["lar_rework_b"], "lar_rework", "lar_rework_b"),
    ]:
        branches = option(by_id, pid, sid, oid)["conditional_effects"]
        assert len(branches) == 1
        if oid == "apr_rework_b":
            assert branches == option(original_by_id, pid, sid, oid)["conditional_effects"]
        else:
            assert branches == [CONDITION]
        conditions[oid] = branches
    report.update({
        "status": "APPLIED_AND_EXACTLY_VERIFIED", "numeric_patch_applied": True,
        "source_before_sha256": hashlib.sha256(source_before.read_bytes()).hexdigest(),
        "source_after_sha256": hashlib.sha256(source_path.read_bytes()).hexdigest(),
        "runtime_after_sha256": hashlib.sha256(runtime_after.read_bytes()).hexdigest(),
        "applied_ledger_sha256": hashlib.sha256(ledger_path.read_bytes()).hexdigest(),
        "full_source_and_loader_equality": True,
        "numeric_fields_changed": 817, "conditional_blocks_restored": 2,
        "unchanged_procedures": untouched,
        "patch_counts_by_procedure": dict(sorted(Counter(r["canonical_procedure_id"] for r in rows).items())),
        "patch_counts_by_field": dict(sorted(Counter(r["field"] for r in rows).items())),
        "protected_conditional_effects": conditions,
    })
    return report


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ["archive", "source-before", "runtime-before", "runtime-after"]:
        parser.add_argument("--" + name, required=True, type=Path)
    args = parser.parse_args()
    print(json.dumps(check(args.archive, args.source_before, args.runtime_before,
                           args.runtime_after), ensure_ascii=False, indent=2))
