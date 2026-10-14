#!/usr/bin/env python3
"""Focused patient-data bundle/loader check; intentionally does not require art."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from patient_bundles import load_patient_bundles


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("patient_id", help="Exact internal ID, e.g. patient_example")
    args = parser.parse_args()

    manifest = json.loads((ROOT / "data/manifest.json").read_text(encoding="utf-8"))
    collections, bundles = load_patient_bundles(ROOT / "data", manifest["patient_bundles"])
    indexed = [bundle for _, bundle in bundles if bundle.get("patient", {}).get("id") == args.patient_id]
    patients = [row for row in collections["patients"] if row.get("id") == args.patient_id]
    encounters = [row for row in collections["encounters"] if row.get("patient_id") == args.patient_id]
    preops = [row for row in collections["preops"] if row.get("patient_id") == args.patient_id]
    failures: list[str] = []

    if len(indexed) != 1:
        failures.append(f"expected exactly one indexed bundle, found {len(indexed)}")
    if len(patients) != 1:
        failures.append(f"expected exactly one loaded patient, found {len(patients)}")

    short_id = args.patient_id.removeprefix("patient_")
    expected_encounter_id = f"visit_{short_id}"
    expected_preop_id = f"preop_{short_id}"
    if len(encounters) != 1 or encounters[0].get("id") != expected_encounter_id:
        failures.append(f"expected generated encounter {expected_encounter_id}, got {[x.get('id') for x in encounters]}")
    if len(preops) != 1 or preops[0].get("id") != expected_preop_id:
        failures.append(f"expected generated preop {expected_preop_id}, got {[x.get('id') for x in preops]}")
    if len(preops) == 1:
        if preops[0].get("encounter_id") != expected_encounter_id:
            failures.append("generated preop points to the wrong encounter")
        stage_ids = [stage.get("id") for stage in preops[0].get("stages", [])]
        if not stage_ids or len(stage_ids) != len(set(stage_ids)):
            failures.append("generated preop stages are empty or contain duplicate IDs")
        if any(not str(stage.get("prompt", "")).strip() for stage in preops[0].get("stages", [])):
            failures.append("generated preop contains a stage without a prompt")
    if len(encounters) == 1:
        stage_ids = [stage.get("id") for stage in encounters[0].get("stages", [])]
        if not stage_ids or len(stage_ids) != len(set(stage_ids)):
            failures.append("generated encounter stages are empty or contain duplicate IDs")

    if len(patients) == 1:
        patient = patients[0]
        if not patient.get("dialogue_profile"):
            failures.append("loaded patient has no dialogue profile ID")
        if not isinstance(patient.get("reaction_lines"), dict) or not patient["reaction_lines"]:
            failures.append("dialogue profile did not resolve reaction lines")
        if not isinstance(patient.get("reaction_variants"), dict) or not patient["reaction_variants"]:
            failures.append("dialogue profile did not resolve reaction variants")

    if failures:
        print(f"PATIENT DATA IMPORT: {args.patient_id}: {len(failures)} failure(s)", file=sys.stderr)
        print("\n".join(f"- {failure}" for failure in failures), file=sys.stderr)
        return 1

    print(
        f"PATIENT DATA IMPORT: {args.patient_id}: bundle unique; profile merged; "
        f"generated {expected_encounter_id} + {expected_preop_id}; no image requirement"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
