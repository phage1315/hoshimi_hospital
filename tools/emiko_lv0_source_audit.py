#!/usr/bin/env python3
"""Verbatim manuscript, schema, graph, portrait, UI hint, and bilingual localization audit
for Emiko Mido (`doc_emiko`) Lv0 formal introduction event:
《传闻中的手》 (`emiko_intro_rumored_hands`, V1.2).
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path

from jsonschema import Draft202012Validator
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import import_emiko_lv0 as imp  # noqa: E402

MANUSCRIPT = ROOT / "research/source_scripts/HOSHIMI_MIDO_EMIKO_LV0_RUMORED_HANDS_V1_2.md"
EN_JSON = ROOT / "research/translations/emiko_lv0_en.json"
EVENTS_JSON = ROOT / "data/staff/doc_emiko/events.json"
PROFILE_JSON = ROOT / "data/staff/doc_emiko/profile.json"
SCHEMA_JSON = ROOT / "data/schemas/content.schema.json"
BACKGROUNDS_JSON = ROOT / "data/backgrounds.json"
ZH_LOCALE = ROOT / "data/localization/zh_CN.json"
EN_LOCALE = ROOT / "data/localization/en.json"
APP_GD = ROOT / "godot/ui/app.gd"
IMPORT_MANIFEST = ROOT / "research/imports/emiko_lv0_2026-11-14.json"

CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\u3040-\u30ff]")

checks = 0
failures: list[str] = []


def require(cond: bool, label: str) -> None:
    global checks
    checks += 1
    if not cond:
        failures.append(label)


def main() -> int:
    require(MANUSCRIPT.is_file(), "Manuscript V1.2 exists")
    require(EN_JSON.is_file(), "English translation JSON exists")
    require(EVENTS_JSON.is_file(), "doc_emiko/events.json exists")
    require(IMPORT_MANIFEST.is_file(), "Import manifest exists")

    events = {e["id"]: e for e in json.loads(EVENTS_JSON.read_text(encoding="utf-8"))}
    require("emiko_office_denied" in events, "emiko_office_denied preserved")
    require("emiko_intro_rumored_hands" in events, "emiko_intro_rumored_hands exists")
    require("emiko_lv1_first_operation" in events, "emiko_lv1_first_operation preserved")
    require("emiko_lv2_follow_my_lead" in events, "emiko_lv2_follow_my_lead preserved")

    event = events["emiko_intro_rumored_hands"]

    # JSON Schema validation
    schema = json.loads(SCHEMA_JSON.read_text(encoding="utf-8"))
    validator = Draft202012Validator({"$ref": "#/$defs/character_event", "$defs": schema["$defs"]})
    schema_errors = list(validator.iter_errors(event))
    require(len(schema_errors) == 0, f"JSON Schema valid ({[e.message for e in schema_errors[:3]]})")

    # Contract & Gate checks
    require(event["actor_id"] == "doc_emiko", "Actor ID is doc_emiko")
    require(event["title"] == "传闻中的手", "Title verbatim match")
    require(event["category"] == "introduction", "Category is introduction")
    require(event["location_id"] == "emiko_office", "Location ID is emiko_office")
    require(event["background_id"] == "emiko_office", "Background ID is emiko_office")
    require(event["outfit"] == "white_coat", "Outfit is white_coat")
    require(event.get("locks_saving") is True, "locks_saving is True")
    require("auto_follow_up" not in event, "Legacy auto_follow_up removed")
    require(event.get("benefit_id", "") == "", "No surgical team unlock at Lv0")
    require(
        event["conditions"]["required_events"] == ["intro_doc_asuka_director_office"]
        and event["conditions"]["special_requirements"]
        == [{"type": "player_attribute", "attribute": "skill", "minimum": 70}],
        "Gate preserves Asuka introduction + Surgery >= 70",
    )

    # Verbatim line-by-line manuscript audit (zero unauthorized alterations)
    beats, choice_labels_zh = imp.parse_manuscript()
    require(len(beats) == 45, f"Expected 45 authored beats from V1.2 manuscript, got {len(beats)}")
    nodes = event["nodes"]
    require(len(nodes) == 45, f"Expected 45 event nodes, got {len(nodes)}")
    node_map = {n["id"]: n for n in nodes}

    for nid, (exp_role, exp_label, exp_text) in beats.items():
        require(nid in node_map, f"Node {nid} present")
        if nid not in node_map:
            continue
        nd = node_map[nid]
        require(nd.get("presentation") == "authored", f"{nid}: presentation == authored")
        require(nd.get("speaker") == exp_role, f"{nid}: speaker role {nd.get('speaker')} == {exp_role}")
        require(nd.get("speaker_label") == exp_label, f"{nid}: speaker_label {nd.get('speaker_label')} == {exp_label}")
        require(nd.get("text") == exp_text, f"{nid}: verbatim text match\n  got: {nd.get('text')!r}\n  exp: {exp_text!r}")

    # Choice 31 audit on em0_030
    ch_node = node_map["em0_030"]
    require(len(ch_node["choices"]) == 3, "em0_030 has 3 options from Beat 31")
    expected_opts = [
        ("choice_em0_face", "「脸？」", "em0_a_01"),
        ("choice_em0_resume", "「履历？」", "em0_b_01"),
        ("choice_em0_table", "「看他敢不敢上台？」", "em0_c_01"),
    ]
    for idx, (cid, clabel, cnext) in enumerate(expected_opts):
        opt = ch_node["choices"][idx]
        require(opt["id"] == cid, f"Option {idx} ID == {cid}")
        require(opt["label"] == clabel and opt["label"] == choice_labels_zh[cid], f"Option {cid} verbatim label == {clabel}")
        require(opt["next"] == cnext, f"Option {cid} next == {cnext}")
        require(opt["effects"] == {"affection": 0, "familiarity": 0}, f"Option {cid} zero stat delta")
        require(opt["flags"] == [], f"Option {cid} zero branch flag divergence")

    # Graph reachability across all 3 choice branches
    visited_all: set[str] = set()
    expected_branch_lens = {
        "choice_em0_face": 42,    # 30 + 3 + 9
        "choice_em0_resume": 40,  # 30 + 1 + 9
        "choice_em0_table": 41,   # 30 + 2 + 9
    }
    for pick, exp_len in expected_branch_lens.items():
        cur = event["start"]
        path: list[str] = []
        steps = 0
        while cur != "@end" and steps < 100:
            require(cur in node_map, f"Valid node target {cur} on {pick}")
            path.append(cur)
            visited_all.add(cur)
            nd = node_map[cur]
            if cur == "em0_030":
                chosen = next(c for c in nd["choices"] if c["id"] == pick)
            else:
                require(len(nd["choices"]) == 1, f"Single continue choice on {cur}")
                chosen = nd["choices"][0]
                require(chosen["effects"] == {"affection": 0, "familiarity": 0}, f"Zero stat delta on {cur}")
                expected_flags = ["emiko_intro_complete"] if cur == "em0_040" else []
                require(chosen["flags"] == expected_flags, f"Expected flags {expected_flags} on {cur}")
            cur = chosen["next"]
            steps += 1
        require(cur == "@end", f"Branch {pick} reaches @end")
        require(len(path) == exp_len, f"Branch {pick} path length {len(path)} == {exp_len}")
        require("em0_032" in path and path[-1] == "em0_040", f"Branch {pick} converges at em0_032..em0_040")
    require(visited_all == set(node_map.keys()), "Zero unreachable orphan nodes")

    # Portrait & Background checks
    profile = json.loads(PROFILE_JSON.read_text(encoding="utf-8"))
    portraits = profile["visuals"]["portraits"]
    bg_ids = {row["id"]: row["path"] for row in json.loads(BACKGROUNDS_JSON.read_text(encoding="utf-8"))}
    require("emiko_office" in bg_ids and (ROOT / bg_ids["emiko_office"]).is_file(), "emiko_office background exists")
    for nd in nodes:
        if not nd.get("hide_portrait", False):
            pkey = f"white_coat/{nd['expression']}"
            require(pkey in portraits, f"{nd['id']}: portrait key {pkey} registered in doc_emiko profile")
            if pkey in portraits:
                pfile = ROOT / portraits[pkey]
                require(pfile.is_file(), f"{nd['id']}: portrait file exists {pfile}")
                if pfile.is_file():
                    with Image.open(pfile) as im:
                        require(im.mode == "RGBA", f"{pkey}: RGBA mode")

    # Bilingual localization & UI hint audit
    zh_strings = json.loads(ZH_LOCALE.read_text(encoding="utf-8"))["strings"]
    en_strings = json.loads(EN_LOCALE.read_text(encoding="utf-8"))["strings"]
    prefix = "collections.character_events.emiko_intro_rumored_hands"

    for mkey in ("title", "teaser", "gallery.caption"):
        fk = f"{prefix}.{mkey}"
        require(bool(zh_strings.get(fk)), f"zh_CN {fk} non-empty")
        require(bool(en_strings.get(fk)) and not CJK_RE.search(en_strings[fk]), f"en {fk} non-empty & zero-CJK")

    for nd in nodes:
        nid = nd["id"]
        tk = f"{prefix}.nodes.{nid}.text"
        sk = f"{prefix}.nodes.{nid}.speaker_label"
        require(zh_strings.get(tk) == nd["text"], f"zh_CN {tk} matches node text")
        require(bool(en_strings.get(tk)) and not CJK_RE.search(en_strings[tk]), f"en {tk} non-empty & zero-CJK")
        require(zh_strings.get(sk) == nd["speaker_label"], f"zh_CN {sk} matches speaker_label")
        require(bool(en_strings.get(sk)) and not CJK_RE.search(en_strings[sk]), f"en {sk} non-empty & zero-CJK")
        for ch in nd["choices"]:
            ck = f"{prefix}.nodes.{nid}.choices.{ch['id']}.label"
            require(zh_strings.get(ck) == ch["label"], f"zh_CN {ck} matches choice label")
            require(bool(en_strings.get(ck)) and not CJK_RE.search(en_strings[ck]), f"en {ck} non-empty & zero-CJK")

    # Ensure stale old keys from pre-V1.2 are purged
    for old_nid in ("opening", "assessment", "face_reply", "resume_reply", "table_reply", "invitation"):
        require(
            f"{prefix}.nodes.{old_nid}.text" not in zh_strings
            and f"{prefix}.nodes.{old_nid}.text" not in en_strings,
            f"Purged stale pre-V1.2 locale key {old_nid}",
        )

    # Verify UI unlock hints updated from 56 -> 70 in zh_CN, en, and app.gd
    app_gd_txt = APP_GD.read_text(encoding="utf-8")
    require("达到 56" not in app_gd_txt and "提升至 56" not in app_gd_txt, "app.gd purged Surgery 56 hint")
    require("达到 70" in app_gd_txt and "提升至 70" in app_gd_txt, "app.gd has Surgery 70 hint")
    require("70" in zh_strings.get("ui.unlock.emiko", "") and "56" not in zh_strings.get("ui.unlock.emiko", ""), "zh_CN ui.unlock.emiko == 70")
    require("70" in zh_strings.get("ui.unlock.artoria_emiko", "") and "56" not in zh_strings.get("ui.unlock.artoria_emiko", ""), "zh_CN ui.unlock.artoria_emiko == 70")
    require("70" in en_strings.get("ui.unlock.emiko", "") and "56" not in en_strings.get("ui.unlock.emiko", ""), "en ui.unlock.emiko == 70")
    require("70" in en_strings.get("ui.unlock.artoria_emiko", "") and "56" not in en_strings.get("ui.unlock.artoria_emiko", ""), "en ui.unlock.artoria_emiko == 70")

    manifest = json.loads(IMPORT_MANIFEST.read_text(encoding="utf-8"))
    require(
        manifest["source_manuscript_sha256"] == hashlib.sha256(MANUSCRIPT.read_bytes()).hexdigest(),
        "Manifest manuscript SHA-256 matches",
    )

    if failures:
        for f in failures:
            print("FAIL:", f, file=sys.stderr)
        print(f"EMIKO LV0 SOURCE AUDIT FAILED: {checks} checks; {len(failures)} failure(s).", file=sys.stderr)
        return 1

    print(f"EMIKO LV0 SOURCE AUDIT PASS: {checks} checks; 0 failure(s) (100% verbatim V1.2 match).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
