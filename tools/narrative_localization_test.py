#!/usr/bin/env python3
"""Require complete English coverage for narrative packs and dating dialogue."""

from __future__ import annotations

import json
import re
from pathlib import Path
from collection_io import load_collection
from staff_bundles import load_staff_bundles

ROOT = Path(__file__).resolve().parents[1]
ENGLISH = json.loads((ROOT / "data/localization/en.json").read_text(encoding="utf-8"))["strings"]
TARGETS = {
    "temporary_conditions": ROOT / "data/surgeries/temporary_conditions.json",
    "time_events": None,  # Staff idle-chat bundles, not unrelated solo activities.
    "date_profiles": None,
    "case_templates": ROOT / "data/cases/surgery_case_templates.json",
    "character_events": ROOT / "data/events/character_events/index.json",
    "micro_events": ROOT / "data/events/micro_events.json",
    "special_events": ROOT / "data/events/special_events/index.json",
    "special_event_steps": ROOT / "data/events/special_event_steps/index.json",
}
FIELDS = {
    "name", "family_name", "given_name", "professional_name", "title", "subtitle",
    "description", "label", "text", "prompt", "response", "teaser", "caption",
    "announcement", "location_label", "speaker_label", "scene_caption", "specialty", "personality",
    "presenting_complaint", "diagnosis", "intake_notes", "result", "summary", "section", "chapters",
    "correction", "responses", "reveal_text", "exploratory_surgery_reaction", "treatment_reaction", "safe_resolution", "dialogue", "outcome",
}
HAN = re.compile(r"[\u3400-\u9fff]")
FORMAT = re.compile(r"%(?:0?\d+)?[sdif]")


def walk(value: object, path: str, rows: list[tuple[str, str]]) -> None:
    if isinstance(value, dict):
        if isinstance(value.get("zh_CN"), str) and isinstance(value.get("en"), str):
            source = value["zh_CN"]
            translated = value["en"]
            if source.strip() and (not translated.strip() or HAN.search(translated)):
                rows.append((path, "[invalid inline English]"))
            return
        for field, child in value.items():
            child_path = f"{path}.{field}"
            condition_prompt = path.startswith("collections.temporary_conditions.") and path.endswith(".prompts")
            if (field in FIELDS or condition_prompt) and isinstance(child, str) and child.strip():
                rows.append((child_path, child))
            walk(child, child_path, rows)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            identity = str(child.get("id", index)) if isinstance(child, dict) else str(index)
            if isinstance(child, str) and path.rsplit(".", 1)[-1] in FIELDS and child.strip():
                rows.append((f"{path}.{identity}", child))
            walk(child, f"{path}.{identity}", rows)


def main() -> int:
    failures: list[str] = []
    checked = 0
    from megumin_source_audit import audit as audit_megumin
    npc_checks, npc_failures = audit_megumin()
    checked += npc_checks
    failures.extend(npc_failures)
    manifest = json.loads((ROOT / "data/manifest.json").read_text(encoding="utf-8"))
    staff_collections, _bundles = load_staff_bundles(ROOT / "data", manifest["staff_bundles"])
    for collection, path in {**TARGETS, "staff": None}.items():
        rows: list[tuple[str, str]] = []
        authored = (load_collection(path) if path is not None else []) + staff_collections.get(collection, [])
        if collection == "staff":
            for person in authored:
                for action_id, line in person.get("personal_nurse", {}).get("diagnosis_corrections", {}).items():
                    rows.append((f"collections.staff.{person['id']}.personal_nurse.diagnosis_corrections.{action_id}", line))
        else:
            walk(authored, f"collections.{collection}", rows)
        for key, source in rows:
            if source == "[invalid inline English]":
                failures.append(f"invalid inline English: {key}")
                continue
            # Already-English authored labels such as "Lucky!" need no locale entry.
            if not HAN.search(source):
                continue
            checked += 1
            translated = ENGLISH.get(key, "")
            if not translated.strip():
                failures.append(f"missing: {key}")
            elif HAN.search(translated):
                failures.append(f"Chinese remains: {key}")
            elif FORMAT.findall(source) != FORMAT.findall(translated):
                failures.append(f"placeholder mismatch: {key}")
    advanced_dialogue_paths = list((ROOT / "data/advanced_surgery/dialogue").glob("*.json"))
    advanced_dialogue_paths += list((ROOT / "data/advanced_surgery/dialogue_v2").glob("*.json"))
    for path in sorted(advanced_dialogue_paths):
        pack = json.loads(path.read_text(encoding="utf-8"))
        if isinstance(pack, dict) and pack.get("schema_version") == "advanced_staff_dialogues_v1":
            lines = [{**row, "id": f"{row['character_id']}:{row['trigger']}:{row['role']}"} for row in pack["lines"]]
        else:
            lines = pack if isinstance(pack, list) else [row for stage in pack["stages"].values() for group in stage.values() for row in group]
        for row in lines:
            checked += 1
            text = row.get("text_en", "")
            if not text.strip() or HAN.search(text) or FORMAT.findall(row["text"]) != FORMAT.findall(text):
                failures.append(f"invalid advanced dialogue English: {path.name}/{row['id']}")
    for path in sorted((ROOT / "data/advanced_surgery/advanced_or_ambient").glob("*.json")):
        pack = json.loads(path.read_text(encoding="utf-8"))
        for variants in pack.get("variants", {}).values():
            for variant in variants:
                for row in variant["lines"]:
                    checked += 1
                    translated = row.get("text_en", "")
                    if not translated.strip() or HAN.search(translated) or FORMAT.findall(row["text"]) != FORMAT.findall(translated):
                        failures.append(f"invalid advanced ambient English: {path.name}/{row['id']}")
    for path in sorted((ROOT / "data/advanced_surgery/stories").glob("*.json")):
        pack = json.loads(path.read_text(encoding="utf-8"))
        pairs = [(pack["patient"][key], pack["patient"].get(key + "_en", "")) for key in ("name", "diagnosis")]
        for chapter in ("day1", "day3"):
            pairs.append((pack[chapter]["title"], pack[chapter].get("title_en", "")))
            pairs.extend((row["text"], row.get("text_en", "")) for row in pack[chapter]["lines"])
        for source, translated in pairs:
            checked += 1
            if not translated.strip() or HAN.search(translated) or FORMAT.findall(source) != FORMAT.findall(translated):
                failures.append(f"invalid advanced first-case English: {path.name}/{source}")
    for procedure in json.loads((ROOT / "data/advanced_surgery/procedures.json").read_text(encoding="utf-8")):
        for stage in procedure["steps"]:
            for option in stage.get("options", []):
                for field in ("label", "description"):
                    checked += 1
                    source = option.get(field, "")
                    translated = option.get(field + "_en", "")
                    if not source.strip() or not translated.strip() or HAN.search(translated) or FORMAT.findall(source) != FORMAT.findall(translated):
                        failures.append(f"invalid advanced strategy English: {procedure['id']}/{stage['id']}/{option['id']}/{field}")
    if failures:
        print("\n".join(failures))
        print(f"NARRATIVE LOCALIZATION: {checked} checks; {len(failures)} failure(s)")
        return 1
    print(f"NARRATIVE LOCALIZATION: {checked} checks; 0 failure(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
