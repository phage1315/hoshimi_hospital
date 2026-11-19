#!/usr/bin/env python3
"""Exhaustive verbatim source-to-runtime audit for Artoria Pendragon (`doc_artoria`)
Staff-as-Patient V1.1 dialogue (`data/staff_patient_profiles.json` & `data/staff_patient_mischief_dialogue.json`).
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_MD = ROOT / "research/source_scripts/HOSHIMI_ARTORIA_STAFF_AS_PATIENT_DIALOGUES_CN_EN_V1_1.md"
PROFILES = ROOT / "data/staff_patient_profiles.json"
MISCHIEF = ROOT / "data/staff_patient_mischief_dialogue.json"
SURGERIES = ROOT / "data/surgeries/surgeries.json"
INTERACTIONS = ROOT / "data/surgeries/patient_interactions.json"

CJK_RE = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")
PLACEHOLDER_RE = re.compile(r"\{[A-Za-z_][A-Za-z0-9_]*\}")
FORBIDDEN = ("Saber", "saber", "Maiya", "久宇舞弥", "卫宫切嗣", "切嗣", "远坂时臣", "间桐雁夜", "在星见的规则里", "一旦切下就无法回头")


class Audit:
    def __init__(self) -> None:
        self.checks = 0
        self.failures: list[str] = []

    def expect(self, cond: bool, msg: str) -> None:
        self.checks += 1
        if not cond:
            self.failures.append(msg)


def main() -> int:
    audit = Audit()
    md = SOURCE_MD.read_text(encoding="utf-8")
    m = re.search(r"```json\s*\n(\{.*\})\s*\n```", md, flags=re.DOTALL)
    audit.expect(m is not None, "source markdown contains JSON block")
    src = json.loads(m.group(1))

    profiles = json.loads(PROFILES.read_text(encoding="utf-8"))
    mischief = json.loads(MISCHIEF.read_text(encoding="utf-8"))

    # Ensure existing heroines remain registered
    for other in ("doc_sayaka", "doc_serika", "nurse_yui"):
        audit.expect(other in profiles, f"{other} preserved in staff_patient_profiles.json")
        audit.expect(other in mischief, f"{other} preserved in staff_patient_mischief_dialogue.json")

    audit.expect("doc_artoria" in profiles and "doc_artoria" in mischief, "doc_artoria registered in both files")
    prof = profiles["doc_artoria"]
    m_art = mischief["doc_artoria"]

    audit.expect(prof["required_completed_rank"] == 5, "required_completed_rank == 5")
    audit.expect(prof["unlock_flags"] == ["staff_as_patient_program_authorized"], "unlock_flags match")
    audit.expect(prof["dialogue_profile"] == "calm_analytical_reassurance", "dialogue_profile matches")

    surgeries = [s["id"] for s in json.loads(SURGERIES.read_text(encoding="utf-8"))]
    interactions_raw = json.loads(INTERACTIONS.read_text(encoding="utf-8"))
    pools = interactions_raw if isinstance(interactions_raw, list) else interactions_raw["pools"]

    for loc in ("zh_CN", "en"):
        s_loc = src[loc]
        d_loc = prof["dialogue"][loc]

        audit.expect(d_loc["address_context"] == s_loc["address_context"], f"{loc}: address_context verbatim")
        audit.expect(d_loc["invitation_lines"] == s_loc["invitation_lines"], f"{loc}: invitation_lines verbatim")
        audit.expect(d_loc["ward_visit_opening"] == s_loc["ward_visit_opening"], f"{loc}: ward_visit_opening verbatim")
        audit.expect(d_loc["stage_prompts"] == s_loc["stage_prompts"], f"{loc}: stage_prompts verbatim")
        audit.expect(d_loc["reaction_lines"] == s_loc["reaction_lines"], f"{loc}: 28 reaction_lines verbatim")
        audit.expect(d_loc["reaction_variants"] == s_loc["reaction_variants"], f"{loc}: 13x2 reaction_variants verbatim")
        audit.expect(d_loc["interaction_overrides"] == s_loc["interaction_overrides"], f"{loc}: 50 interaction_overrides verbatim")

        # Every surgery has an invitation_by_procedure line from one of the 5 authored categories
        cat_lines = {tuple(v): k for k, v in s_loc["invitation_by_category"].items()}
        audit.expect(set(d_loc["invitation_by_procedure"].keys()) == set(surgeries), f"{loc}: all 32 surgeries covered")
        for sid, lines in d_loc["invitation_by_procedure"].items():
            audit.expect(tuple(lines) in cat_lines, f"{loc}: {sid} uses verbatim category line")

        # Mischief verbatim check
        audit.expect(m_art["dialogue"][loc] == src["mischief_dialogue"][loc], f"{loc}: mischief_dialogue verbatim")

        # Check every string for forbidden tokens, CJK in en, and placeholder parity
        blob = json.dumps(d_loc, ensure_ascii=False) + json.dumps(m_art["dialogue"][loc], ensure_ascii=False)
        for bad in FORBIDDEN:
            audit.expect(bad not in blob, f"{loc}: forbidden token '{bad}' absent")
        if loc == "en":
            audit.expect(CJK_RE.search(blob) is None, "en: zero CJK characters across profile + mischief")

    # Placeholder parity across zh_CN and en
    zh_d = prof["dialogue"]["zh_CN"]
    en_d = prof["dialogue"]["en"]
    for i in range(len(zh_d["invitation_lines"])):
        audit.expect(
            PLACEHOLDER_RE.findall(zh_d["invitation_lines"][i]) == PLACEHOLDER_RE.findall(en_d["invitation_lines"][i]),
            f"invitation_lines[{i}] placeholder parity",
        )
    for sid in surgeries:
        audit.expect(
            PLACEHOLDER_RE.findall(zh_d["invitation_by_procedure"][sid][0]) == PLACEHOLDER_RE.findall(en_d["invitation_by_procedure"][sid][0]),
            f"invitation_by_procedure[{sid}] placeholder parity",
        )

    # Pool / action completeness
    audit.expect(len(pools) == 50, "50 pools in catalog")
    for p in pools:
        pid = p["id"]
        for loc in ("zh_CN", "en"):
            entry = prof["dialogue"][loc]["interaction_overrides"][pid]
            audit.expect(bool(entry["prompt"].strip()), f"{loc} {pid}: non-empty prompt")
            for act in p.get("actions", p.get("options", [])):
                aid = act["id"]
                audit.expect(bool(entry["responses"][aid].strip()), f"{loc} {pid}.{aid}: non-empty response")

    if audit.failures:
        for f in audit.failures[:30]:
            print("FAIL:", f, file=sys.stderr)
        print(f"ARTORIA STAFF PATIENT AUDIT FAILED: {audit.checks} checks; {len(audit.failures)} failure(s)", file=sys.stderr)
        return 1

    print(f"ARTORIA STAFF PATIENT AUDIT PASSED: {audit.checks} checks; 0 failure(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
