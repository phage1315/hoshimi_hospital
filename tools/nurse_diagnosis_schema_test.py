#!/usr/bin/env python3
"""Check the personal-nurse dialogue contract with in-memory invalid profiles."""

import copy
import json
from pathlib import Path

from jsonschema import Draft202012Validator
from staff_bundles import load_staff_bundles

ROOT = Path(__file__).resolve().parents[1]
ACTIONS = ("diagnose_gastro", "diagnose_observe")


def main() -> int:
    schema = json.loads((ROOT / "data/schemas/content.schema.json").read_text())
    Draft202012Validator.check_schema(schema)
    validator = Draft202012Validator({"$ref": "#/$defs/staff", "$defs": schema["$defs"]})
    manifest = json.loads((ROOT / "data/manifest.json").read_text())
    collections, _ = load_staff_bundles(ROOT / "data", manifest["staff_bundles"])
    checks = 0
    failures = []

    def expect(profile, valid, label):
        nonlocal checks
        checks += 1
        errors = list(validator.iter_errors(profile))
        if (not errors) != valid:
            failures.append(f"{label}: expected valid={valid}; " + "; ".join(e.message for e in errors))

    eligible_count = 0
    for profile in collections["staff"]:
        actor = profile["id"]
        expect(profile, True, actor + " authored profile")
        personal = profile.get("personal_nurse", {})
        eligible = profile["profession"] == "nurse" and personal.get("eligible") is True
        if not eligible:
            without = copy.deepcopy(profile)
            without.get("personal_nurse", {}).pop("diagnosis_corrections", None)
            expect(without, True, actor + " does not need nurse corrections")
            continue
        eligible_count += 1
        without = copy.deepcopy(profile)
        del without["personal_nurse"]["diagnosis_corrections"]
        expect(without, False, actor + " missing map")
        # Disabling the feature legitimately removes the requirement in data;
        # importers must not do this to evade an approved feature's missing prose.
        without["personal_nurse"]["eligible"] = False
        expect(without, True, actor + " feature disabled")
        for value in ({}, None, [], "not a map"):
            broken = copy.deepcopy(profile)
            broken["personal_nurse"]["diagnosis_corrections"] = value
            expect(broken, False, actor + " invalid map " + repr(value))
        for action in ACTIONS:
            missing = copy.deepcopy(profile)
            del missing["personal_nurse"]["diagnosis_corrections"][action]
            expect(missing, False, actor + " missing " + action)
            for value in ("", "   ", "\t\n", "\u3000", None, [], 1):
                broken = copy.deepcopy(profile)
                broken["personal_nurse"]["diagnosis_corrections"][action] = value
                expect(broken, False, actor + "/" + action + " invalid value " + repr(value))
        extra = copy.deepcopy(profile)
        extra["personal_nurse"]["diagnosis_corrections"]["错误诊断A"] = "unexpected key"
        expect(extra, False, actor + " translated/unknown technical key")
        incomplete_disabled = copy.deepcopy(profile)
        incomplete_disabled["personal_nurse"]["eligible"] = False
        incomplete_disabled["personal_nurse"]["diagnosis_corrections"] = {ACTIONS[0]: "one line"}
        expect(incomplete_disabled, False, actor + " optional map must still be complete")
    if not eligible_count:
        failures.append("No eligible personal nurses covered")
    print("\n".join(failures)) if failures else None
    print(f"NURSE DIAGNOSIS SCHEMA: {checks} checks; {eligible_count} eligible nurses; {len(failures)} failure(s)")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
