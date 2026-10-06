#!/usr/bin/env python3
"""Translate every remaining authored Chinese field not yet present in en.json."""

from __future__ import annotations

import json
import re
from pathlib import Path

from translate_english_narrative import LOCALE, translate_batch
from collection_io import load_collection

ROOT = Path(__file__).resolve().parents[1]
HAN = re.compile(r"[\u3400-\u9fff]")
FIELDS = {
    "name", "family_name", "given_name", "professional_name", "title", "subtitle",
    "description", "label", "text", "prompt", "response", "teaser", "caption",
    "announcement", "location_label", "speaker_label", "specialty", "personality",
    "presenting_complaint", "diagnosis", "intake_notes", "result", "summary", "section",
    "correction",
}


def walk(value: object, path: str, out: list[tuple[str, str]], all_han_leaves: bool = False) -> None:
    if isinstance(value, dict):
        for field, child in value.items():
            child_path = f"{path}.{field}"
            if isinstance(child, str) and child.strip() and HAN.search(child) and (all_han_leaves or field in FIELDS):
                out.append((child_path, child))
            walk(child, child_path, out, all_han_leaves)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            identity = str(child.get("id", index)) if isinstance(child, dict) else str(index)
            if isinstance(child, str) and child.strip() and HAN.search(child) and all_han_leaves:
                out.append((f"{path}.{identity}", child))
            else:
                walk(child, f"{path}.{identity}", out, all_han_leaves)


def main() -> int:
    locale = json.loads(LOCALE.read_text(encoding="utf-8"))
    strings: dict[str, str] = locale["strings"]
    manifest = json.loads((ROOT / "data/manifest.json").read_text(encoding="utf-8"))
    pending: list[tuple[str, str]] = []
    for collection, relative in manifest["collections"].items():
        walk(load_collection(ROOT / "data" / relative), f"collections.{collection}", pending)
    patient_config = manifest["patient_bundles"]
    for template_name, key in (("encounter", "encounter_template"), ("preop", "preop_template")):
        walk(json.loads((ROOT / "data" / patient_config[key]).read_text(encoding="utf-8")), f"patient_templates.{template_name}", pending)
    for relative in json.loads((ROOT / "data" / patient_config["index"]).read_text(encoding="utf-8")):
        bundle = json.loads((ROOT / "data/patients" / relative).read_text(encoding="utf-8"))
        patient_id = str(bundle.get("patient", {}).get("id", Path(relative).parent.name))
        # Patient bundles store much of their visible prose in action-keyed
        # dictionaries (reaction_lines, stage_prompts, incision_responses)
        # rather than fields named `text` or `response`. Every Chinese string
        # leaf in a bundle is authored presentation content and must therefore
        # receive a stable translation key.
        walk(bundle, f"patient_bundles.{patient_id}", pending, True)
    pending = [(key, source) for key, source in pending if key not in strings]
    print(f"Translating {len(pending)} remaining authored fields")
    batches: list[list[tuple[str, str]]] = []
    current: list[tuple[str, str]] = []
    size = 0
    for item in pending:
        cost = len(item[1]) + 32
        if current and size + cost > 3000:
            batches.append(current)
            current, size = [], 0
        current.append(item)
        size += cost
    if current:
        batches.append(current)
    for index, batch in enumerate(batches, 1):
        strings.update(translate_batch(batch))
        print(f"Batch {index}/{len(batches)}: {len(batch)} fields")
    locale["strings"] = dict(sorted(strings.items()))
    LOCALE.write_text(json.dumps(locale, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
