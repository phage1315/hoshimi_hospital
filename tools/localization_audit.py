#!/usr/bin/env python3
"""Dependency-free checks for Hoshimi locale files.

This intentionally permits incomplete locales: untranslated keys use authored
Chinese at runtime. It rejects malformed or blank translations and reports the
current translated-string count so coverage can grow in reviewable batches.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOCALE_DIR = ROOT / "data" / "localization"
KEY = re.compile(r"^[A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)+$")
PLACEHOLDER = re.compile(r"%(?:0?\d+)?[sdif]")
TX_CALL = re.compile(r'(?:app\.)?tx\("(?P<key>[^"]+)",\s*"(?P<fallback>(?:\\.|[^"\\])*)"')
CHINESE_LITERAL = re.compile(r'"(?:\\.|[^"\\])*[\u3400-\u9fff](?:\\.|[^"\\])*"')
TRANSLATABLE_FIELDS = {
    "name", "family_name", "given_name", "professional_name", "title", "subtitle", "description",
    "label", "text", "prompt", "response", "teaser", "caption",
    "announcement", "completion_hint", "location_label", "speaker_label", "specialty", "personality",
    "presenting_complaint", "diagnosis", "intake_notes", "result", "summary", "section", "correction",
}


def read_collection(relative_path: str) -> list[object]:
    path = ROOT / "data" / relative_path
    source = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(source, list):
        return source
    rows: list[object] = []
    for shard in source.get("files", []):
        rows.extend(json.loads((path.parent / shard).read_text(encoding="utf-8")))
    return rows


def collect_keys(value: object, path: str, result: set[str]) -> None:
    if isinstance(value, dict):
        for field, child in value.items():
            child_path = f"{path}.{field}"
            if isinstance(child, str) and child.strip() and field in TRANSLATABLE_FIELDS:
                result.add(child_path)
            collect_keys(child, child_path, result)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            identity = str(index)
            if isinstance(child, dict) and child.get("id"):
                identity = str(child["id"])
            collect_keys(child, f"{path}.{identity}", result)


def collect_han_leaf_keys(value: object, path: str, result: set[str]) -> None:
    """Collect patient prose stored under semantic map keys rather than fields."""
    if isinstance(value, dict):
        for field, child in value.items():
            collect_han_leaf_keys(child, f"{path}.{field}", result)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            identity = str(child.get("id", index)) if isinstance(child, dict) else str(index)
            collect_han_leaf_keys(child, f"{path}.{identity}", result)
    elif isinstance(value, str) and value.strip() and re.search(r"[\u3400-\u9fff]", value):
        result.add(path)


def authored_keys() -> set[str]:
    manifest = json.loads((ROOT / "data" / "manifest.json").read_text(encoding="utf-8"))
    result: set[str] = set()
    protagonist = json.loads((ROOT / "data" / manifest["protagonist"]).read_text(encoding="utf-8"))
    collect_keys(protagonist, "protagonist", result)
    dialogue = json.loads((ROOT / "data" / manifest["dialogue"]).read_text(encoding="utf-8"))
    collect_keys(dialogue, "dialogue", result)
    for collection, relative_path in manifest["collections"].items():
        rows = read_collection(relative_path)
        collect_keys(rows, f"collections.{collection}", result)
    patient_config = manifest.get("patient_bundles", {})
    encounter_template = json.loads((ROOT / "data" / patient_config["encounter_template"]).read_text(encoding="utf-8"))
    preop_template = json.loads((ROOT / "data" / patient_config["preop_template"]).read_text(encoding="utf-8"))
    collect_keys(encounter_template, "patient_templates.encounter", result)
    collect_keys(preop_template, "patient_templates.preop", result)
    bundle_index = json.loads((ROOT / "data" / patient_config["index"]).read_text(encoding="utf-8"))
    for relative_path in bundle_index:
        bundle = json.loads((ROOT / "data/patients" / relative_path).read_text(encoding="utf-8"))
        patient_id = str(bundle.get("patient", {}).get("id", Path(relative_path).parent.name))
        collect_keys(bundle, f"patient_bundles.{patient_id}", result)
        collect_han_leaf_keys(bundle, f"patient_bundles.{patient_id}", result)
    return result


def ui_sources() -> list[Path]:
    return sorted((ROOT / "godot" / "ui").glob("*.gd"))


def ui_fallbacks() -> dict[str, str]:
    result: dict[str, str] = {}
    for path in ui_sources():
        source = path.read_text(encoding="utf-8")
        for match in TX_CALL.finditer(source):
            result.setdefault(match.group("key"), match.group("fallback"))
    return result


def hardcoded_ui_candidates() -> dict[str, int]:
    result: dict[str, int] = {}
    for path in ui_sources():
        count = 0
        for line in path.read_text(encoding="utf-8").splitlines():
            stripped = line.lstrip()
            if stripped.startswith("#") or "tx(" in line or "localization-fallback-map" in line or "localization-invariant" in line:
                continue
            if CHINESE_LITERAL.search(line):
                count += 1
        if count:
            result[path.name] = count
    return result


def main() -> int:
    failures: list[str] = []
    total = 0
    source_keys = authored_keys()
    ui_keys = ui_fallbacks()
    english_ui_coverage = 0
    for path in sorted(LOCALE_DIR.glob("*.json")):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            failures.append(f"{path.name}: {exc}")
            continue
        if data.get("locale") != path.stem:
            failures.append(f"{path.name}: locale must match the filename")
        strings = data.get("strings")
        if not isinstance(strings, dict):
            failures.append(f"{path.name}: strings must be an object")
            continue
        for key, value in strings.items():
            if not isinstance(key, str) or not KEY.fullmatch(key):
                failures.append(f"{path.name}: invalid key {key!r}")
            if not isinstance(value, str) or not value.strip():
                failures.append(f"{path.name}: blank or non-string translation for {key!r}")
            # Shared patient templates also carry translations for deliberately
            # blank prompts and staff-keyed response maps that are populated at
            # runtime; their exact keys therefore do not all appear as authored
            # translatable scalar fields during the static walk.
            virtual_runtime_key = isinstance(key, str) and key.startswith("patient_templates.")
            if isinstance(key, str) and not key.startswith("ui.") and not virtual_runtime_key and key not in source_keys:
                failures.append(f"{path.name}: key does not resolve to active authored content: {key}")
            if path.stem != "zh_CN" and isinstance(key, str) and key in ui_keys and isinstance(value, str):
                expected = PLACEHOLDER.findall(ui_keys[key])
                actual = PLACEHOLDER.findall(value)
                if expected != actual:
                    failures.append(f"{path.name}: placeholder mismatch for {key}: {expected} != {actual}")
        total += len(strings)
        if path.stem == "zh_CN":
            print(f"{path.stem}: source fallback ({len(source_keys)} active authored text fields)")
        else:
            translated_authored = len(source_keys.intersection(strings))
            english_ui_coverage = len(set(ui_keys).intersection(strings)) if path.stem == "en" else english_ui_coverage
            print(f"{path.stem}: {len(strings)} translations; authored coverage {translated_authored}/{len(source_keys)}")
    print(f"UI: {english_ui_coverage}/{len(ui_keys)} referenced English keys translated")
    candidates = hardcoded_ui_candidates()
    print(f"UI hard-coded Chinese candidates: {sum(candidates.values())} lines ({', '.join(f'{name}: {count}' for name, count in candidates.items()) or 'none'})")

    if english_ui_coverage != len(ui_keys):
        failures.append(f"en.json: UI coverage is {english_ui_coverage}/{len(ui_keys)}")
    if candidates:
        failures.append("UI scripts still contain unwrapped Chinese string literals")
    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    print(f"LOCALIZATION AUDIT: {total} translations; source-language fallback enabled")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
