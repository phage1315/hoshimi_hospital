#!/usr/bin/env python3
"""Import Artoria Pendragon (`doc_artoria`) Staff-as-Patient complete bilingual dialogue V1.1.

Reads:
- research/source_scripts/HOSHIMI_ARTORIA_STAFF_AS_PATIENT_DIALOGUES_CN_EN_V1_1.md

Writes / Updates (preserving all other registered heroines untouched):
- research/source_scripts/artoria_staff_patient_delivery_v1_1.json
- data/staff_patient_profiles.json (`doc_artoria`)
- data/staff_patient_mischief_dialogue.json (`doc_artoria`)
- research/imports/artoria_staff_patient_dialogue_2026-11-17.json
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_MD_PATH = ROOT / "research/source_scripts/HOSHIMI_ARTORIA_STAFF_AS_PATIENT_DIALOGUES_CN_EN_V1_1.md"
SOURCE_JSON_PATH = ROOT / "research/source_scripts/artoria_staff_patient_delivery_v1_1.json"
PROFILES_PATH = ROOT / "data/staff_patient_profiles.json"
MISCHIEF_PATH = ROOT / "data/staff_patient_mischief_dialogue.json"
SURGERIES_PATH = ROOT / "data/surgeries/surgeries.json"
INTERACTIONS_PATH = ROOT / "data/surgeries/patient_interactions.json"
IMPORT_MANIFEST_PATH = ROOT / "research/imports/artoria_staff_patient_dialogue_2026-11-17.json"

ACTOR_ID = "doc_artoria"

CATEGORY_SURGERIES: dict[str, list[str]] = {
    "ROUTINE": [
        "surgery_appendix",
        "surgery_breast_tumor",
        "surgery_open_cholecystectomy",
        "surgery_open_inguinal_hernia",
        "surgery_open_ventral_hernia",
        "surgery_open_splenectomy",
        "surgery_open_ovarian_cystectomy",
        "surgery_open_abdominal_myomectomy",
        "surgery_open_adrenalectomy",
    ],
    "MAJOR": [
        "surgery_cabg",
        "surgery_exploratory_laparotomy",
        "surgery_open_distal_gastrectomy",
        "surgery_open_right_hemicolectomy",
        "surgery_open_sigmoid_colectomy",
        "surgery_open_abdominoperineal_resection",
        "surgery_open_whipple",
        "surgery_open_major_liver_resection",
        "surgery_open_lung_lobectomy",
        "surgery_open_esophagectomy",
        "surgery_open_abdominal_aortic_aneurysm",
        "surgery_adv_artificial_heart_exchange",
        "surgery_open_distal_pancreatectomy",
        "surgery_open_partial_nephrectomy",
        "surgery_open_left_hemicolectomy",
        "surgery_open_low_anterior_resection",
    ],
    "HYSTERECTOMY": [
        "surgery_hysterectomy",
        "surgery_vaginal_hysterectomy",
    ],
    "MASTECTOMY": [
        "surgery_total_mastectomy",
    ],
    "ORGAN_REMOVAL": [
        "surgery_open_total_gastrectomy",
        "surgery_open_pneumonectomy",
        "surgery_open_radical_cystectomy",
        "surgery_open_nephrectomy",
    ],
}

RESERVED_REACTION_IDS = [
    "hospitalization_question",
    "hospitalization_response",
]

AGREEMENT_REQUIRED_POOLS = [
    "hysterectomy_signature_01",
    "ovarian_cystectomy_signature_01",
    "myomectomy_signature_01",
    "breast_tumor_signature_01",
    "mastectomy_signature_01",
    "cabg_signature_01",
    "pelvic_dignity_exposure_01",
    "pelvic_dignity_default_01",
    "breast_dignity_exposure_01",
    "breast_dignity_default_01",
    "breast_closure_fear_01",
]

CJK_RE = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, data) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def extract_json_from_md(md_text: str) -> dict:
    m = re.search(r"```json\s*\n(\{.*\})\s*\n```", md_text, flags=re.DOTALL)
    if not m:
        raise ValueError("Could not find ```json ... ``` block in source markdown")
    return json.loads(m.group(1))


def build_locale_dialogue(src_loc: dict, is_en: bool) -> dict:
    inv_by_cat: dict[str, list[str]] = src_loc["invitation_by_category"]
    inv_by_proc: dict[str, list[str]] = {}
    for cat, proc_ids in CATEGORY_SURGERIES.items():
        lines = inv_by_cat[cat]
        if not lines:
            raise ValueError(f"Empty invitation_by_category[{cat}]")
        for pid in proc_ids:
            inv_by_proc[pid] = list(lines)

    reaction_lines: dict[str, str] = dict(src_loc["reaction_lines"])
    reaction_speakers = {
        rk: "patient"
        for rk in reaction_lines
        if rk not in RESERVED_REACTION_IDS
    }

    out = {
        "address_context": dict(src_loc["address_context"]),
        "invitation_lines": list(src_loc["invitation_lines"]),
        "invitation_by_procedure": inv_by_proc,
        "ward_visit_opening": list(src_loc["ward_visit_opening"]),
        "stage_prompts": dict(src_loc["stage_prompts"]),
        "reaction_lines": reaction_lines,
        "reaction_speakers": reaction_speakers,
        "reaction_variants": {k: list(v) for k, v in src_loc["reaction_variants"].items()},
        "interaction_overrides": dict(src_loc["interaction_overrides"]),
    }

    if is_en:
        blob = json.dumps(out, ensure_ascii=False)
        m = CJK_RE.search(blob)
        if m:
            raise ValueError(f"CJK character found in English staff-patient dialogue: {m.group(0)}")

    return out


def main() -> None:
    md_text = SOURCE_MD_PATH.read_text(encoding="utf-8")
    payload = extract_json_from_md(md_text)
    if payload.get("actor_id") != ACTOR_ID:
        raise ValueError(f"Unexpected actor_id: {payload.get('actor_id')}")
    write_json(SOURCE_JSON_PATH, payload)

    # Verify 32-surgery coverage
    surgeries = read_json(SURGERIES_PATH)
    all_surg_ids = {s["id"] for s in surgeries}
    mapped_surg_ids = {pid for arr in CATEGORY_SURGERIES.values() for pid in arr}
    if all_surg_ids != mapped_surg_ids:
        raise ValueError(f"Surgery catalog mismatch: {all_surg_ids ^ mapped_surg_ids}")

    # Verify 50-pool & 118-action coverage against patient_interactions.json
    interactions_raw = read_json(INTERACTIONS_PATH)
    pools = interactions_raw if isinstance(interactions_raw, list) else interactions_raw["pools"]
    expected_pools = {
        p["id"]: [a["id"] for a in p.get("actions", p.get("options", []))]
        for p in pools
    }
    for loc in ("zh_CN", "en"):
        io = payload[loc]["interaction_overrides"]
        if set(io.keys()) != set(expected_pools.keys()):
            raise ValueError(f"{loc} interaction_overrides pool mismatch: {set(io.keys()) ^ set(expected_pools.keys())}")
        for pid, act_ids in expected_pools.items():
            if set(io[pid]["responses"].keys()) != set(act_ids):
                raise ValueError(f"{loc} pool {pid} action mismatch: {set(io[pid]['responses'].keys()) ^ set(act_ids)}")

    zh_dialogue = build_locale_dialogue(payload["zh_CN"], is_en=False)
    en_dialogue = build_locale_dialogue(payload["en"], is_en=True)

    profiles = read_json(PROFILES_PATH)
    profiles[ACTOR_ID] = {
        "required_completed_rank": 5,
        "unlock_flags": ["staff_as_patient_program_authorized"],
        "dialogue_status": "cn_en_full_v1_1_integrated",
        "dialogue_profile": payload.get("recommended_base_dialogue_profile", "calm_analytical_reassurance"),
        "personality": {
            "primary": "calm_cooperative",
            "secondary": "analytical",
            "stress_response": "seeks_reassurance",
        },
        "traits": {},
        "reserved_reaction_ids": RESERVED_REACTION_IDS,
        "portrait_aliases": {
            "examination/shy": "ward_preparation/shy",
        },
        "agreement_required_interaction_ids": AGREEMENT_REQUIRED_POOLS,
        "dialogue_source": str(SOURCE_MD_PATH.relative_to(ROOT)),
        "dialogue_source_sha256": sha256_of(SOURCE_MD_PATH),
        "dialogue": {
            "zh_CN": zh_dialogue,
            "en": en_dialogue,
        },
    }
    write_json(PROFILES_PATH, profiles)

    mischief = read_json(MISCHIEF_PATH)
    en_mischief_blob = json.dumps(payload["mischief_dialogue"]["en"], ensure_ascii=False)
    if CJK_RE.search(en_mischief_blob):
        raise ValueError("CJK character found in English mischief_dialogue")
    mischief[ACTOR_ID] = {
        "dialogue_source": str(SOURCE_MD_PATH.relative_to(ROOT)),
        "dialogue_source_sha256": sha256_of(SOURCE_MD_PATH),
        "dialogue": {
            "zh_CN": payload["mischief_dialogue"]["zh_CN"],
            "en": payload["mischief_dialogue"]["en"],
        },
    }
    write_json(MISCHIEF_PATH, mischief)

    action_total = sum(len(v) for v in expected_pools.values())
    import_manifest = {
        "actor_id": ACTOR_ID,
        "version": "V1.1",
        "source_markdown": str(SOURCE_MD_PATH.relative_to(ROOT)),
        "source_markdown_sha256": sha256_of(SOURCE_MD_PATH),
        "source_json": str(SOURCE_JSON_PATH.relative_to(ROOT)),
        "source_json_sha256": sha256_of(SOURCE_JSON_PATH),
        "profiles_sha256": sha256_of(PROFILES_PATH),
        "mischief_sha256": sha256_of(MISCHIEF_PATH),
        "counts": {
            "invitation_lines": len(zh_dialogue["invitation_lines"]),
            "invitation_by_procedure": len(zh_dialogue["invitation_by_procedure"]),
            "ward_visit_opening": len(zh_dialogue["ward_visit_opening"]),
            "stage_prompts": len(zh_dialogue["stage_prompts"]),
            "reaction_lines_total": len(zh_dialogue["reaction_lines"]),
            "reaction_lines_active": len(zh_dialogue["reaction_speakers"]),
            "reaction_variants_groups": len(zh_dialogue["reaction_variants"]),
            "reaction_variants_lines": sum(len(v) for v in zh_dialogue["reaction_variants"].values()),
            "interaction_override_pools": len(zh_dialogue["interaction_overrides"]),
            "interaction_override_actions": action_total,
            "mischief_variant_groups": len(payload["mischief_dialogue"]["zh_CN"]["reaction_variants"]),
            "mischief_team_nurses": list(payload["mischief_dialogue"]["zh_CN"]["team_overrides"].keys()),
        },
    }
    write_json(IMPORT_MANIFEST_PATH, import_manifest)
    print(
        f"Imported {ACTOR_ID} Staff-as-Patient V1.1: "
        f"28 reaction_lines, 13x2 reaction_variants, 50 pools ({action_total} actions), "
        f"9x2 mischief variants + 3x4 nurse team overrides."
    )


if __name__ == "__main__":
    main()
