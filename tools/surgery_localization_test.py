#!/usr/bin/env python3
"""Surgical English is complete only when real, distinct options survive loading.

Checks both stages and flow_steps: the runtime supports both representations.
Generic fallback prose must never conceal missing authored translations.
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HAN = re.compile(r"[\u3400-\u9fff]")
FORMAT = re.compile(r"%(?:[-+0-9.]*[sdif]|%)|\{[A-Za-z_][A-Za-z0-9_]*\}")


def leaves(value, key):
    if isinstance(value, dict):
        for name, child in value.items():
            yield from leaves(child, f"{key}.{name}")
    elif isinstance(value, list):
        for index, child in enumerate(value):
            identity = child.get("id", index) if isinstance(child, dict) else index
            yield from leaves(child, f"{key}.{identity}")
    elif isinstance(value, str):
        yield key, value


def main():
    strings = json.loads((ROOT / "data/localization/en.json").read_text())["strings"]
    surgeries = json.loads((ROOT / "data/surgeries/surgeries.json").read_text())
    barks = json.loads((ROOT / "data/surgeries/awake_special_barks.json").read_text())
    rows = list(leaves(surgeries, "collections.surgeries"))
    for record in barks:
        rows.extend(leaves(record["variants"], f"collections.awake_special_barks.{record['id']}.variants"))
    failures = []
    checked = 0
    for key, source in rows:
        if not HAN.search(source):
            continue
        checked += 1
        translated = strings.get(key, "")
        if not translated.strip():
            failures.append(f"missing: {key}")
        elif HAN.search(translated):
            failures.append(f"Chinese remains: {key}")
        elif FORMAT.findall(source) != FORMAT.findall(translated):
            failures.append(f"placeholder mismatch: {key}")
        elif translated == "Proceed with the selected approach" or translated.startswith("The surgical team proceeds with the "):
            failures.append(f"generic substitute: {key}")
    for procedure in surgeries:
        for field in ("stages", "flow_steps"):
            for step in procedure.get(field, []):
                labels = {}
                for option in step.get("options", []):
                    key = f"collections.surgeries.{procedure['id']}.{field}.{step['id']}.options.{option['id']}.label"
                    source = option.get("label", "")
                    label = strings.get(key, source)
                    if label in labels and labels[label] != source:
                        failures.append(f"distinct options collapsed: {key}")
                    labels[label] = source
    for failure in failures:
        print(failure)
    print(f"SURGERY LOCALIZATION: {checked} checks; {len(failures)} failure(s)")
    return bool(failures)


if __name__ == "__main__":
    raise SystemExit(main())
