#!/usr/bin/env python3
"""Import only verified, existing Staff-as-Patient dialogue hooks."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "research/source_scripts/HOSHIMI_ASAKURA_MIYUKI_STAFF_AS_PATIENT_DIALOGUES_CN_EN_V1.md"
TARGET = ROOT / "data/staff_patient_profiles.json"
POOLS = ROOT / "data/surgeries/patient_interactions.json"


def table(section):
    return [re.findall(r"(?<!\\)\|", line) and [x.strip() for x in line.strip().strip("|").split("|")] for line in section.splitlines() if line.startswith("| ")]


def pair(line):
    match = re.search(r"CN：(.*?) EN: (.*)$", line)
    if not match:
        raise ValueError("Unpaired CN/EN line: " + line)
    return match.group(1), match.group(2)


def main():
    source = SOURCE.read_text()
    original = json.loads(TARGET.read_text())
    pools = {p["id"]: p for p in json.loads(POOLS.read_text())}
    dialogue = {"zh_CN": {}, "en": {}}
    a = source.split("### A. ", 1)[1].split("### B1.", 1)[0]
    invitation = [r for r in table(a) if len(r) >= 4 and r[0].startswith("`A1-0")]
    if len(invitation) != 3:
        raise ValueError("Expected 3 ordinary invitation lines")
    for locale, col in (("zh_CN", 1), ("en", 2)):
        dialogue[locale]["invitation_lines"] = [r[col] for r in invitation]
        dialogue[locale]["invitation_by_procedure"] = {}
    # These exact surgery IDs are named by the author; no name-derived category guessing.
    special = {
        "A1b-HYSTERECTOMY": ["surgery_hysterectomy", "surgery_vaginal_hysterectomy"],
        "A1b-MASTECTOMY": ["surgery_total_mastectomy"],
    }
    for r in table(a):
        slot = r[0].split("`")[1] if "`" in r[0] else ""
        if slot in special:
            for surgery_id in special[slot]:
                for locale, col in (("zh_CN", 1), ("en", 2)):
                    dialogue[locale]["invitation_by_procedure"][surgery_id] = [r[col]]
    b1 = source.split("### B1. ", 1)[1].split("### B2. ", 1)[0]
    reactions = [r for r in table(b1) if len(r) >= 3 and "`" in r[0]]
    if len(reactions) != 28:
        raise ValueError(f"Expected 28 reactions, got {len(reactions)}")
    for locale, col in (("zh_CN", 1), ("en", 2)):
        dialogue[locale]["reaction_lines"] = {r[0].strip("*`"): r[col].strip("*") for r in reactions}
        dialogue[locale]["reaction_speakers"] = {r[0].strip("*`"): "patient" for r in reactions if not r[0].strip("*`").startswith("hospitalization_")}
    b2 = source.split("### B2. ", 1)[1].split("### B1a. ", 1)[0]
    variants = [r for r in table(b2) if len(r) >= 4 and r[0].startswith("`")]
    if len(variants) != 26:
        raise ValueError(f"Expected 26 variants, got {len(variants)}")
    for locale, col in (("zh_CN", 2), ("en", 3)):
        grouped = {}
        for r in variants:
            grouped.setdefault(r[0].strip("`"), []).append(r[col])
        if len(grouped) != 13 or any(len(v) != 2 for v in grouped.values()):
            raise ValueError("13x2 variant alignment failed")
        dialogue[locale]["reaction_variants"] = grouped
    c2 = source.split("### C2. ", 1)[1].split("### C2-v2. ", 1)[0]
    matched = list(re.finditer(r"(?ms)^\*\*`([^`]+)`([^\n]*)\n(.*?)(?=^\*\*`|^#### |\Z)", c2))
    if len(matched) != 50:
        raise ValueError(f"Expected 50 pools, got {len(matched)}")
    for locale in dialogue:
        dialogue[locale]["interaction_overrides"] = {}
    custom_count = 0
    action_count = 0
    for m in matched:
        pool_id, status, body = m.groups()
        if pool_id not in pools:
            raise ValueError("Unknown pool " + pool_id)
        lines = [x for x in body.splitlines() if x.startswith("- `P`") or x.startswith("- `R:")]
        if len(lines) != len(pools[pool_id]["actions"]) + 1:
            raise ValueError("Action count mismatch in " + pool_id)
        if pool_id == "strain_pain_traction_02":
            # The source's reservation was for an abdomen-only action label in
            # an unrestricted pool. The current shared action is neutral.
            current_label = next(a["label"] for a in pools[pool_id]["actions"] if a["id"] == "coach_second_traction")
            if "腹部" in current_label:
                raise ValueError("Second traction action is still abdomen-specific")
        elif "RESERVE" in status or "FALLBACK" in status:
            continue
        prompt_zh, prompt_en = pair(lines[0])
        responses = {"zh_CN": {}, "en": {}}
        for line in lines[1:]:
            action_id = line.split("`", 2)[1].removeprefix("R:")
            zh, en = pair(line)
            responses["zh_CN"][action_id] = zh
            responses["en"][action_id] = en
        expected = {a["id"] for a in pools[pool_id]["actions"]}
        if set(responses["zh_CN"]) != expected:
            raise ValueError("Action ID mismatch in " + pool_id)
        dialogue["zh_CN"]["interaction_overrides"][pool_id] = {"prompt": prompt_zh, "responses": responses["zh_CN"]}
        dialogue["en"]["interaction_overrides"][pool_id] = {"prompt": prompt_en, "responses": responses["en"]}
        custom_count += 1
        action_count += len(expected)
    if custom_count != 50 or action_count != 106:
        raise ValueError(f"Expected 50 pools/106 actions, got {custom_count}/{action_count}")
    b1a = source.split("### B1a. ", 1)[1].split("### C2. ", 1)[0]
    detailed = [r for r in table(b1a) if len(r) >= 4 and r[0].startswith("患者主动提出详细说明")]
    if len(detailed) != 1:
        raise ValueError("Detailed preop question missing")
    for locale, col in (("zh_CN", 1), ("en", 2)):
        dialogue[locale]["stage_prompts"] = {"graphic_preop_question": detailed[0][col]}
    original["nurse_yui"] = {
        "required_completed_rank": 5,
        "unlock_flags": ["staff_as_patient_program_authorized"],
        "dialogue_status": "cn_en_core_integrated_reserves_documented",
        "dialogue_profile": "strong_front_expressive_irritable",
        "reserved_reaction_ids": ["hospitalization_question", "hospitalization_response"],
        "portrait_aliases": {"examination/shy": "ward_preparation/shy"},
        "agreement_required_interaction_ids": [
            "hysterectomy_signature_01", "ovarian_cystectomy_signature_01", "myomectomy_signature_01",
            "breast_tumor_signature_01", "mastectomy_signature_01", "cabg_signature_01",
            "pelvic_dignity_exposure_01", "pelvic_dignity_default_01", "breast_dignity_exposure_01",
            "breast_dignity_default_01", "breast_closure_fear_01"],
        "dialogue_source": str(SOURCE.relative_to(ROOT)),
        "dialogue": dialogue,
    }
    TARGET.write_text(json.dumps(original, ensure_ascii=False, indent=2) + "\n")
    print(f"Miyuki: {len(reactions)} reactions, 13x2 variants, {custom_count} pools, {action_count} actions")


if __name__ == "__main__":
    main()
