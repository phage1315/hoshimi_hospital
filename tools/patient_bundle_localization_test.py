#!/usr/bin/env python3
"""Verify every visible Chinese leaf in a patient bundle resolves in English."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HAN = re.compile(r"[\u3400-\u9fff]")
sys.path.insert(0, str(ROOT / "tools"))
import patient_bundles


def walk(value: object, path: str, strings: dict[str, str], failures: list[str]) -> None:
    if isinstance(value, dict):
        for field, child in value.items():
            walk(child, f"{path}.{field}", strings, failures)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            identity = str(child.get("id", index)) if isinstance(child, dict) else str(index)
            walk(child, f"{path}.{identity}", strings, failures)
    elif isinstance(value, str) and HAN.search(value):
        translated = strings.get(path, value)
        if HAN.search(translated):
            failures.append(path)


def main() -> int:
    strings = json.loads((ROOT / "data/localization/en.json").read_text(encoding="utf-8"))["strings"]
    index = json.loads((ROOT / "data/patients/index.json").read_text(encoding="utf-8"))
    failures: list[str] = []
    checks = 0
    profiles = json.loads((ROOT / "data/patients/dialogue_profiles.json").read_text(encoding="utf-8"))["profiles"]
    for profile_id, profile in profiles.items():
        prefix = f"patient_dialogue_profiles.{profile_id}"
        walk(profile, prefix, strings, failures)
        checks += sum(1 for key in strings if key.startswith(prefix + "."))
    for relative in index:
        bundle = json.loads((ROOT / "data/patients" / relative).read_text(encoding="utf-8"))
        patient_id = str(bundle["patient"]["id"])
        before = len(failures)
        walk(bundle, f"patient_bundles.{patient_id}", strings, failures)
        checks += sum(
            1 for key in strings
            if key.startswith(f"patient_bundles.{patient_id}.")
        )
        if len(failures) != before:
            print(f"{patient_id}: {len(failures) - before} unresolved field(s)")
    manifest = json.loads((ROOT / "data/manifest.json").read_text(encoding="utf-8"))
    collections, bundles = patient_bundles.load_patient_bundles(ROOT / "data", manifest["patient_bundles"])
    iwai_bundle = next(bundle for _, bundle in bundles if bundle["patient"]["id"] == "patient_iwai_yoshimi")
    iwai_encounter = next(encounter for encounter in collections["encounters"] if encounter["patient_id"] == "patient_iwai_yoshimi")
    full_undress_pool = "full_undress_basic_exam_patient_iwai_yoshimi"
    assert iwai_bundle["encounter"]["full_undress"]["visual_pool_id"] == full_undress_pool
    for stage in iwai_encounter["stages"]:
        if stage["id"] == "exam_undress_decision":
            mapped = {
                action["id"] for action in stage["actions"]
                if action.get("visual_pool_id") == full_undress_pool
            }
            assert mapped == {"authoritative_full_undress", "gentle_full_undress", "threaten_full_undress"}
    expected_pools = {
        "ward_skin_prep_patient_iwai_yoshimi": {"ward_skin_prep", "ward_skin_prep_unnecessary"},
        "operative_positioning_patient_iwai_yoshimi": {"operative_positioning"},
        "urinary_catheterization_patient_iwai_yoshimi": {"urinary_catheterization"},
        "incision_ready_patient_iwai_yoshimi": {"request_scalpel"},
    }
    iwai_pools = {
        pool["id"]: pool for pool in collections["ward_preparation_cg_pools"]
        if "patient_iwai_yoshimi" in pool.get("patient_ids", [])
    }
    assert set(iwai_pools) == set(expected_pools)
    preop_runtime = (ROOT / "godot/systems/preop_session.gd").read_text(encoding="utf-8")
    preop_template = json.loads((ROOT / "data/patients/templates/preop.json").read_text(encoding="utf-8"))
    template_actions = {
        action["id"] for stage in preop_template["stages"] for action in stage.get("actions", [])
    }
    for pool_id, action_ids in expected_pools.items():
        pool = iwai_pools[pool_id]
        assert set(pool["action_ids"]) == action_ids
        assert all(
            action_id in template_actions or f'"id": "{action_id}"' in preop_runtime
            for action_id in action_ids
        ), pool_id
        assert pool["paths"] and all((ROOT / path).is_file() for path in pool["paths"])
        for field in ("label", "caption"):
            key = f"patient_bundles.patient_iwai_yoshimi.exclusive_cg_pools.ward_preparation.{pool_id}.{field}"
            assert key in strings and strings[key].strip() and not HAN.search(strings[key]), key
    examination_pool = next(pool for pool in collections["examination_cg_pools"] if pool["id"] == full_undress_pool)
    assert examination_pool["paths"] and all((ROOT / path).is_file() for path in examination_pool["paths"])
    for field in ("label", "caption"):
        key = f"patient_bundles.patient_iwai_yoshimi.exclusive_cg_pools.examination.{full_undress_pool}.{field}"
        assert key in strings and strings[key].strip() and not HAN.search(strings[key]), key
    expected_cg_inventory = {
        "patient_kocho_shinobu": {
            "examination": "full_undress_basic_exam_patient_kocho_shinobu",
            "ward_preparation": {
                "ward_enema_patient_kocho_shinobu": {"ward_enema"},
                "ward_surgical_cap_patient_kocho_shinobu": {"ward_surgical_cap"},
                "sterile_draping_patient_kocho_shinobu": {"ack_disinfection"},
                "urinary_catheterization_patient_kocho_shinobu": {"urinary_catheterization"},
                "incision_patient_kocho_shinobu": {"request_scalpel"},
            },
        },
        "patient_iwai_yoshimi": {
            "examination": "full_undress_basic_exam_patient_iwai_yoshimi",
            "ward_preparation": expected_pools,
        },
        "patient_comoli_harcourt": {
            "examination": "full_undress_basic_exam_patient_comoli_harcourt",
            "ward_preparation": {},
        },
        "patient_shimizu_iraiza": {
            "examination": "full_undress_basic_exam_patient_shimizu_iraiza",
            "ward_preparation": {
                "ward_skin_prep_patient_shimizu_iraiza": {"ward_skin_prep", "ward_skin_prep_unnecessary"},
                "ward_enema_patient_shimizu_iraiza": {"ward_enema", "ward_enema_unnecessary"},
                "stretcher_transfer_patient_shimizu_iraiza": {"complete_manual_ward_preparation"},
                "urinary_catheterization_patient_shimizu_iraiza": {"urinary_catheterization"},
                "sterile_draping_patient_shimizu_iraiza": {"ack_disinfection"},
                "incision_ready_patient_shimizu_iraiza": {"request_scalpel"},
            },
        },
        "patient_yuko_asou": {
            "examination": "full_undress_basic_exam_patient_yuko_asou",
            "ward_preparation": {
                "ward_skin_prep_patient_yuko_asou": {"ward_skin_prep", "ward_skin_prep_unnecessary"},
                "ward_enema_patient_yuko_asou": {"ward_enema", "ward_enema_unnecessary"},
                "ward_surgical_cap_patient_yuko_asou": {"ward_surgical_cap"},
                "stretcher_transfer_patient_yuko_asou": {"complete_manual_ward_preparation"},
                "urinary_catheterization_patient_yuko_asou": {"urinary_catheterization"},
                "skin_disinfection_patient_yuko_asou": {"skin_disinfection"},
                "sterile_draping_patient_yuko_asou": {"ack_disinfection"},
                "incision_ready_patient_yuko_asou": {"request_scalpel"},
            },
        },
    }
    bundles_by_id = {bundle["patient"]["id"]: bundle for _, bundle in bundles}
    runtime_encounters = {encounter["patient_id"]: encounter for encounter in collections["encounters"]}
    for patient_id, expected in expected_cg_inventory.items():
        bundle = bundles_by_id[patient_id]
        pool_id = expected["examination"]
        assert bundle["encounter"]["full_undress"]["visual_pool_id"] == pool_id
        examination = next(pool for pool in collections["examination_cg_pools"] if pool["id"] == pool_id)
        assert examination["paths"] and all((ROOT / path).is_file() for path in examination["paths"])
        exam_stage = next(stage for stage in runtime_encounters[patient_id]["stages"] if stage["id"] == "exam_undress_decision")
        completed_choices = {"authoritative_full_undress", "gentle_full_undress", "threaten_full_undress"}
        assert {
            action["id"] for action in exam_stage["actions"]
            if action.get("visual_pool_id") == pool_id
        } == completed_choices
        assert all(
            not action.get("visual_pool_id")
            for action in exam_stage["actions"] if action["id"] == "abandon_full_undress"
        )
        for field in ("label", "caption"):
            key = f"patient_bundles.{patient_id}.exclusive_cg_pools.examination.{pool_id}.{field}"
            assert key in strings and strings[key].strip() and not HAN.search(strings[key]), key
        ward_pools = {
            pool["id"]: pool for pool in collections["ward_preparation_cg_pools"]
            if patient_id in pool.get("patient_ids", [])
        }
        assert set(ward_pools) == set(expected["ward_preparation"]), patient_id
        for ward_id, action_ids in expected["ward_preparation"].items():
            pool = ward_pools[ward_id]
            assert set(pool["action_ids"]) == action_ids, ward_id
            assert pool["paths"] and all((ROOT / path).is_file() for path in pool["paths"]), ward_id
            assert all(
                action_id in template_actions or f'"id": "{action_id}"' in preop_runtime
                for action_id in action_ids
            ), ward_id
            for field in ("label", "caption"):
                key = f"patient_bundles.{patient_id}.exclusive_cg_pools.ward_preparation.{ward_id}.{field}"
                assert key in strings and strings[key].strip() and not HAN.search(strings[key]), key
        checks += 3 + 2 * len(expected["ward_preparation"])
    # Sweep every patient bundle, not only the patients imported in this batch.
    # This catches the exact failure mode where art exists but the runtime pool ID is blank/unresolved.
    global_examination = json.loads((ROOT / "data/examination_cg_pools.json").read_text(encoding="utf-8"))
    examination_by_id = {
        pool["id"]: pool for pool in [*global_examination, *collections["examination_cg_pools"]]
    }
    known_legacy_unresolved = {"patient_ann", "patient_sora"}
    for _, bundle in bundles:
        patient_id = bundle["patient"]["id"]
        visual_pool_id = bundle.get("encounter", {}).get("full_undress", {}).get("visual_pool_id", "")
        if visual_pool_id:
            if visual_pool_id not in examination_by_id:
                # These two pre-bundle legacy entries use a retired generic ID.
                # Keep them visible as a known legacy gap; do not let this exception
                # mask a new unresolved trigger on an imported patient.
                assert patient_id in known_legacy_unresolved, (patient_id, visual_pool_id)
        for pool in bundle.get("exclusive_cg_pools", {}).get("examination", []):
            assert pool["id"] in examination_by_id
            assert pool.get("paths") and all((ROOT / path).is_file() for path in pool["paths"]), pool["id"]
            assert pool["id"] == visual_pool_id, (patient_id, pool["id"], visual_pool_id)
            for field in ("label", "caption"):
                key = f"patient_bundles.{patient_id}.exclusive_cg_pools.examination.{pool['id']}.{field}"
                assert key in strings and strings[key].strip() and not HAN.search(strings[key]), key
        for pool in bundle.get("exclusive_cg_pools", {}).get("ward_preparation", []):
            assert patient_id in pool.get("patient_ids", []), (patient_id, pool.get("id"))
            assert pool.get("action_ids") and pool.get("paths")
            assert all((ROOT / path).is_file() for path in pool["paths"]), pool["id"]
            assert all(
                action_id in template_actions or f'"id": "{action_id}"' in preop_runtime
                for action_id in pool["action_ids"]
            ), pool["id"]
            for field in ("label", "caption"):
                key = f"patient_bundles.{patient_id}.exclusive_cg_pools.ward_preparation.{pool['id']}.{field}"
                assert key in strings and strings[key].strip() and not HAN.search(strings[key]), key
        checks += 1 + len(bundle.get("exclusive_cg_pools", {}).get("examination", [])) + len(bundle.get("exclusive_cg_pools", {}).get("ward_preparation", []))
    print(f"PATIENT BUNDLE LOCALIZATION: {checks} English entries; {len(failures)} failure(s)")
    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
