#!/usr/bin/env python3
"""Import the approved 23-slot staff-patient art for Asuka and Hiroko.

This importer only connects the art data layer. It deliberately does not add
staff_patient_profiles entries or unlock either actor without authored
bilingual patient dialogue.
"""

from __future__ import annotations

import hashlib
import json
import shutil
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
GROUPS = {
    "ward": ["neutral", "smile", "brave", "worried", "afraid", "crying"],
    "intraoperative": ["tense", "pain", "near_collapse", "anesthetized"],
    "operating_table": ["awake", "tense", "afraid", "anesthetized"],
    "operating_table_lithotomy": ["awake", "tense", "afraid", "anesthetized"],
    "splash": ["general_anesthesia"],
    "advanced": ["abdominal", "chest", "lateral", "prone"],
}
PORTRAIT_GROUPS = {
    key: values for key, values in GROUPS.items() if key != "advanced"
}
OUTFITS = [
    "ward",
    "intraoperative",
    "operating_table",
    "operating_table_lithotomy",
    "splash",
]
ACTORS = {
    "doc_asuka": {
        "source": ROOT / "assets/characters/asuka_staff_patient_v1/doc_asuka",
        "runtime": ROOT / "assets/characters/asuka_staff_patient_v1/doc_asuka",
        "runtime_prefix": "assets/characters/asuka_staff_patient_v1/doc_asuka",
        "sfw_chest": ROOT / "research/generated_candidates/asuka_staff_patient_v1/previous_v2/advanced/chest.png",
        "sfw_reference": ROOT / "assets/references/advanced_staff_patient_sfw_v1/doc_asuka/chest.png",
        "advanced_sources": {
            "abdominal": "research/generated_candidates/asuka_staff_patient_v1/advanced/abdominal.png",
            "chest": "research/generated_candidates/asuka_staff_patient_v1/author_supplied/chest.png",
            "lateral": "research/generated_candidates/asuka_staff_patient_v1/advanced/lateral.png",
            "prone": "research/generated_candidates/asuka_staff_patient_v1/advanced/prone.png",
        },
    },
    "nurse_hiroko": {
        "source": ROOT / "research/generated_candidates/hiroko_staff_patient_v1/prepared/nurse_hiroko",
        "runtime": ROOT / "assets/characters/hiroko_staff_patient_v1/nurse_hiroko",
        "runtime_prefix": "assets/characters/hiroko_staff_patient_v1/nurse_hiroko",
        "sfw_chest": ROOT / "research/generated_candidates/hiroko_staff_patient_v1/sfw_reference/advanced/chest.png",
        "sfw_reference": ROOT / "assets/references/advanced_staff_patient_sfw_v1/nurse_hiroko/chest.png",
        "advanced_sources": {
            "abdominal": "research/generated_candidates/hiroko_staff_patient_v1/advanced/abdominal.png",
            "chest": "research/generated_candidates/hiroko_staff_patient_v1/author_supplied/chest.png",
            "lateral": "research/generated_candidates/hiroko_staff_patient_v1/advanced/lateral.png",
            "prone": "research/generated_candidates/hiroko_staff_patient_v1/advanced/prone.png",
        },
    },
}


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value) -> None:
    path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def expected_keys() -> set[str]:
    return {
        f"{group}/{expression}"
        for group, expressions in GROUPS.items()
        for expression in expressions
    }


def png_keys(root: Path) -> set[str]:
    return {
        str(path.relative_to(root).with_suffix(""))
        for path in root.glob("*/*.png")
    }


def copy_actor_art(actor_id: str, config: dict) -> list[dict]:
    source: Path = config["source"]
    runtime: Path = config["runtime"]
    expected = expected_keys()
    actual = png_keys(source)
    if actual != expected:
        raise RuntimeError(
            f"{actor_id} source set mismatch: missing={sorted(expected - actual)}, "
            f"extra={sorted(actual - expected)}"
        )
    if source != runtime:
        for key in sorted(expected):
            source_path = source / f"{key}.png"
            target_path = runtime / f"{key}.png"
            target_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source_path, target_path)
    runtime_actual = png_keys(runtime)
    if runtime_actual != expected:
        raise RuntimeError(
            f"{actor_id} runtime set mismatch: "
            f"missing={sorted(expected - runtime_actual)}, "
            f"extra={sorted(runtime_actual - expected)}"
        )

    sfw_reference: Path = config["sfw_reference"]
    sfw_reference.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(config["sfw_chest"], sfw_reference)

    records = []
    for key in sorted(expected):
        path = runtime / f"{key}.png"
        records.append(
            {
                "key": key,
                "path": f"{config['runtime_prefix']}/{key}.png",
                "sha256": sha256(path),
            }
        )
    return records


def update_profile(actor_id: str, config: dict) -> None:
    path = ROOT / f"data/staff/{actor_id}/profile.json"
    data = load_json(path)
    visuals = data.setdefault("visuals", {})
    outfits = visuals.setdefault("outfits", [])
    for outfit in OUTFITS:
        if outfit not in outfits:
            outfits.append(outfit)
    portraits = visuals.setdefault("portraits", {})
    for group, expressions in PORTRAIT_GROUPS.items():
        for expression in expressions:
            key = f"{group}/{expression}"
            portraits[key] = f"{config['runtime_prefix']}/{key}.png"
    write_json(path, data)


def update_asset_manifest(actor_id: str, config: dict, records: list[dict]) -> None:
    path = ROOT / f"data/staff/{actor_id}/assets_manifest.json"
    data = load_json(path)
    prefix = f"patient_{actor_id}_"
    assets = [
        entry
        for entry in data.get("assets", [])
        if not str(entry.get("id", "")).startswith(prefix)
    ]
    for record in records:
        key = record["key"]
        assets.append(
            {
                "id": prefix + key.replace("/", "_"),
                "category": "staff_patient_art",
                "path": record["path"],
                "status": "mapped",
                "runtime_connected": True,
                "trigger": None,
                "notes": (
                    "Mapped patient art only; patient admission remains locked "
                    "pending authored bilingual patient profile."
                ),
            }
        )
    data["assets"] = assets
    write_json(path, data)


def update_advanced_assets(imported: dict[str, list[dict]]) -> None:
    path = ROOT / "data/advanced_surgery/staff_patient/assets.json"
    data = load_json(path)
    for actor_id, config in ACTORS.items():
        runtime_hashes = {row["key"]: row["sha256"] for row in imported[actor_id]}
        poses = {}
        for pose in GROUPS["advanced"]:
            entry = {
                "path": f"{config['runtime_prefix']}/advanced/{pose}.png",
                "source": config["advanced_sources"][pose],
                "sha256": runtime_hashes[f"advanced/{pose}"],
            }
            if pose == "chest":
                entry["sfw_reference"] = str(
                    config["sfw_reference"].relative_to(ROOT)
                )
            poses[pose] = entry
        data[actor_id] = poses
    write_json(path, data)


def write_import_record(imported: dict[str, list[dict]]) -> None:
    path = ROOT / "research/imports/asuka_hiroko_staff_patient_art_2026-11-17.json"
    write_json(
        path,
        {
            "schema_version": 1,
            "scope": "staff_patient_art_data_only",
            "actors": imported,
            "patient_profiles_added": False,
            "dialogue_added": False,
            "production_unlock_changed": False,
            "notes": (
                "The 23-slot art matrix, staff profile portrait mappings, asset "
                "manifests, and advanced pose registry are connected. Admission "
                "remains locked until authored bilingual patient data is supplied."
            ),
        },
    )


def main() -> None:
    imported: dict[str, list[dict]] = {}
    for actor_id, config in ACTORS.items():
        records = copy_actor_art(actor_id, config)
        update_profile(actor_id, config)
        update_asset_manifest(actor_id, config, records)
        imported[actor_id] = records
    update_advanced_assets(imported)
    write_import_record(imported)
    print("Imported art data for doc_asuka and nurse_hiroko: 23/23 each")
    print("Patient profiles/dialogue/unlocks unchanged")


if __name__ == "__main__":
    main()
