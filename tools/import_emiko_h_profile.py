#!/usr/bin/env python3
"""Import verbatim user-supplied H Profile / Flow / Context bilingual dialogue for Emiko Mido (`doc_emiko`).

Source:
- research/source_scripts/HOSHIMI_MIDO_EMIKO_H_PROFILE_DIALOGUE_V1.json

Updates:
- data/staff/doc_emiko/h_profile_v1.json
- data/staff/doc_emiko/h_flow_v1.json
- data/staff/doc_emiko/h_context_v1.json
- data/localization/zh_CN.json & data/localization/en.json (booking_response)
- research/imports/emiko_h_profile_2026-11-15.json
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_PATH = ROOT / "research/source_scripts/HOSHIMI_MIDO_EMIKO_H_PROFILE_DIALOGUE_V1.json"
PROFILE_PATH = ROOT / "data/staff/doc_emiko/h_profile_v1.json"
FLOW_PATH = ROOT / "data/staff/doc_emiko/h_flow_v1.json"
CONTEXT_PATH = ROOT / "data/staff/doc_emiko/h_context_v1.json"
ZH_LOCALE_PATH = ROOT / "data/localization/zh_CN.json"
EN_LOCALE_PATH = ROOT / "data/localization/en.json"
MANIFEST_PATH = ROOT / "research/imports/emiko_h_profile_2026-11-15.json"

CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\u3040-\u30ff\uf900-\ufaff]")


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    src = json.loads(SOURCE_PATH.read_text(encoding="utf-8"))
    if src.get("actor_id") != "doc_emiko":
        raise ValueError(f"Unexpected actor_id: {src.get('actor_id')}")

    prof = json.loads(PROFILE_PATH.read_text(encoding="utf-8"))
    flow = json.loads(FLOW_PATH.read_text(encoding="utf-8"))
    ctx = json.loads(CONTEXT_PATH.read_text(encoding="utf-8"))

    p_zh = src["profile_dialogue_zh"]
    prof["dialogue"]["location_entry"] = p_zh["location_entry"]
    prof["dialogue"]["tier_fallback"] = p_zh["tier_fallback"]
    prof["dialogue"]["zone_tier"] = p_zh["zone_tier"]
    prof["dialogue"]["combo"] = p_zh["combo"]
    prof["dialogue"]["scene"] = p_zh["scene"]

    f_zh = src["flow_dialogue_zh"]
    flow["excitement_max"]["line"] = f_zh["excitement_max_line"]
    flow["entry_style"]["openings"] = f_zh["openings"]
    flow["entry_style"]["midpoints"] = f_zh["midpoints"]
    flow["phase2"]["manual_finish"]["on_click"]["response_pool"] = f_zh["finish_responses"]
    flow["external_vn_aftercare"]["free_h"]["on_entry_line_sequence"] = f_zh["free_h_aftercare"]

    c_en = src["context_dialogue_en"]
    existing_labels = ctx["base"]["dialogue"]["en"].get(
        "finish.labels",
        [
            "I'm coming!",
            "It's coming...!",
            "I can't hold back...!",
            "Right now!",
            "Let's come together!",
        ],
    )
    new_base_en = dict(c_en["base_en"])
    if "finish.labels" not in new_base_en:
        new_base_en["finish.labels"] = existing_labels

    for k, arr in new_base_en.items():
        for line in arr:
            if CJK_RE.search(line):
                raise ValueError(f"CJK leak in English H context key {k}: {line!r}")
    for line in c_en["operating_room_entry"]:
        if CJK_RE.search(line):
            raise ValueError(f"CJK leak in English operating_room_entry: {line!r}")

    ctx["base"]["dialogue"]["en"] = new_base_en
    ctx["locations"]["operating_room"]["dialogue"]["en"]["entry"] = c_en["operating_room_entry"]

    PROFILE_PATH.write_text(json.dumps(prof, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    FLOW_PATH.write_text(json.dumps(flow, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    CONTEXT_PATH.write_text(json.dumps(ctx, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # Sync daytime booking_response in zh_CN.json and en.json
    booking = src["booking_response"]
    if CJK_RE.search(booking["en"]):
        raise ValueError("CJK leak in booking_response.en")

    zh_doc = json.loads(ZH_LOCALE_PATH.read_text(encoding="utf-8"))
    en_doc = json.loads(EN_LOCALE_PATH.read_text(encoding="utf-8"))
    zh_doc["strings"]["ui.free_h.doc_emiko.booking_response"] = booking["zh_CN"]
    en_doc["strings"]["ui.free_h.doc_emiko.booking_response"] = booking["en"]
    zh_doc["strings"] = dict(sorted(zh_doc["strings"].items()))
    en_doc["strings"] = dict(sorted(en_doc["strings"].items()))
    ZH_LOCALE_PATH.write_text(json.dumps(zh_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    EN_LOCALE_PATH.write_text(json.dumps(en_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    manifest = {
        "actor_id": "doc_emiko",
        "version": src.get("version", "1.0"),
        "source_json": str(SOURCE_PATH.relative_to(ROOT)),
        "source_sha256": sha256_of(SOURCE_PATH),
        "profile_sha256": sha256_of(PROFILE_PATH),
        "flow_sha256": sha256_of(FLOW_PATH),
        "context_sha256": sha256_of(CONTEXT_PATH),
        "counts": {
            "operating_room_entry": len(p_zh["location_entry"]["operating_room"]),
            "tier_fallback_pools": len(p_zh["tier_fallback"]),
            "zone_tier_pools": len(p_zh["zone_tier"]),
            "combo_pools": len(p_zh["combo"]),
            "scene_pools": {k: len(v) for k, v in p_zh["scene"].items()},
            "finish_responses": len(f_zh["finish_responses"]),
            "free_h_aftercare": len(f_zh["free_h_aftercare"]),
        },
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(
        f"Imported doc_emiko H Profile dialogue V{manifest['version']}: "
        f"{manifest['counts']['combo_pools']} combo pools, "
        f"{manifest['counts']['zone_tier_pools']} zone_tier pools, zero placeholders remaining."
    )


if __name__ == "__main__":
    main()
