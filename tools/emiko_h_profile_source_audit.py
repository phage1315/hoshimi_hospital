#!/usr/bin/env python3
"""Verbatim source-to-runtime parity, zero-placeholder, and bilingual key alignment audit
for Emiko Mido (`doc_emiko`) H Profile V1 (`h_profile_v1.json`, `h_flow_v1.json`, `h_context_v1.json`).
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_PATH = ROOT / "research/source_scripts/HOSHIMI_MIDO_EMIKO_H_PROFILE_DIALOGUE_V1.json"
PROFILE_PATH = ROOT / "data/staff/doc_emiko/h_profile_v1.json"
FLOW_PATH = ROOT / "data/staff/doc_emiko/h_flow_v1.json"
CONTEXT_PATH = ROOT / "data/staff/doc_emiko/h_context_v1.json"
ZH_LOCALE_PATH = ROOT / "data/localization/zh_CN.json"
EN_LOCALE_PATH = ROOT / "data/localization/en.json"

ACTIONS = ("caress", "kiss", "lick", "light_bite")
ZONES = ("lips", "cheeks", "neck", "breasts", "nipples", "navel", "torso_other", "genitals", "thighs")
CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\u3040-\u30ff\uf900-\ufaff]")

checks = 0
failures: list[str] = []


def require(cond: bool, msg: str) -> None:
    global checks
    checks += 1
    if not cond:
        failures.append(msg)


def main() -> int:
    for p in (SOURCE_PATH, PROFILE_PATH, FLOW_PATH, CONTEXT_PATH, ZH_LOCALE_PATH, EN_LOCALE_PATH):
        require(p.is_file(), f"File exists: {p.relative_to(ROOT)}")
    if failures:
        print("FATAL:", failures)
        return 1

    src = json.loads(SOURCE_PATH.read_text(encoding="utf-8"))
    prof = json.loads(PROFILE_PATH.read_text(encoding="utf-8"))
    flow = json.loads(FLOW_PATH.read_text(encoding="utf-8"))
    ctx = json.loads(CONTEXT_PATH.read_text(encoding="utf-8"))
    zh_loc = json.loads(ZH_LOCALE_PATH.read_text(encoding="utf-8"))["strings"]
    en_loc = json.loads(EN_LOCALE_PATH.read_text(encoding="utf-8"))["strings"]

    # 1. Zero placeholder residue across all runtime files
    for p in (PROFILE_PATH, FLOW_PATH, CONTEXT_PATH):
        raw_txt = p.read_text(encoding="utf-8")
        require("PENDING_AUTHOR_TEXT" not in raw_txt, f"Zero placeholder tokens in {p.name}")

    # 2. 100% verbatim match against source JSON
    p_zh = src["profile_dialogue_zh"]
    f_zh = src["flow_dialogue_zh"]
    c_en = src["context_dialogue_en"]

    require(prof["dialogue"]["location_entry"] == p_zh["location_entry"], "Verbatim location_entry match")
    require(prof["dialogue"]["tier_fallback"] == p_zh["tier_fallback"], "Verbatim tier_fallback match")
    require(prof["dialogue"]["zone_tier"] == p_zh["zone_tier"], "Verbatim zone_tier match")
    require(prof["dialogue"]["combo"] == p_zh["combo"], "Verbatim combo match")
    require(prof["dialogue"]["scene"] == p_zh["scene"], "Verbatim scene pools match")

    require(flow["excitement_max"]["line"] == f_zh["excitement_max_line"], "Verbatim excitement_max.line match")
    require(flow["entry_style"]["openings"] == f_zh["openings"], "Verbatim openings match")
    require(flow["entry_style"]["midpoints"] == f_zh["midpoints"], "Verbatim midpoints match")
    require(flow["phase2"]["manual_finish"]["on_click"]["response_pool"] == f_zh["finish_responses"], "Verbatim finish_responses match")
    require(flow["external_vn_aftercare"]["free_h"]["on_entry_line_sequence"] == f_zh["free_h_aftercare"], "Verbatim free_h_aftercare match")

    require(zh_loc.get("ui.free_h.doc_emiko.booking_response") == src["booking_response"]["zh_CN"], "zh_CN booking_response matches source")
    require(en_loc.get("ui.free_h.doc_emiko.booking_response") == src["booking_response"]["en"], "en booking_response matches source")

    # 3. Complete 36 (4x9) combo coverage & 1:1 zh/en array length parity
    base_en = ctx["base"]["dialogue"]["en"]
    for a in ACTIONS:
        for z in ZONES:
            zh_k = f"{a}:{z}"
            en_k = f"reaction.combo:{a}|{z}"
            require(zh_k in prof["dialogue"]["combo"] and len(prof["dialogue"]["combo"][zh_k]) == 2, f"ZH combo {zh_k} has 2 lines")
            require(en_k in base_en and base_en[en_k] == c_en["base_en"][en_k] and len(base_en[en_k]) == 2, f"EN combo {en_k} matches source with 2 lines")

    for z_key, z_arr in prof["dialogue"]["zone_tier"].items():
        en_k = "reaction.zone_tier:" + z_key.replace(":", "|")
        require(en_k in base_en and len(base_en[en_k]) == len(z_arr), f"ZH/EN parity on {en_k}")

    for t in ("low", "mild", "strong", "favorite"):
        en_k = f"reaction.tier_fallback:{t}"
        require(len(prof["dialogue"]["tier_fallback"][t]) == 4 and len(base_en[en_k]) == 4, f"ZH/EN 4-line parity on {en_k}")

    for s in ("start", "middle", "finish"):
        require(len(prof["dialogue"]["scene"][s]) == 3 and len(base_en[f"scene.{s}"]) == 3, f"ZH/EN 3-line parity on scene.{s}")

    require(len(base_en["max_prompt"]) == 1, "EN max_prompt has 1 line")
    require(len(base_en["finish.responses"]) == 4, "EN finish.responses has 4 lines")
    require(len(base_en["aftercare"]) == 2, "EN aftercare has 2 lines")
    require(
        ctx["locations"]["operating_room"]["dialogue"]["en"]["entry"] == c_en["operating_room_entry"]
        and len(c_en["operating_room_entry"]) == 4,
        "EN operating_room entry matches source (4 lines)",
    )

    for k, arr in base_en.items():
        for line in arr:
            require(not CJK_RE.search(line), f"Zero CJK in EN key {k}")

    print(f"EMIKO H PROFILE SOURCE AUDIT: {checks} checks; {len(failures)} failure(s)")
    if failures:
        for f in failures:
            print("  FAIL:", f)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
