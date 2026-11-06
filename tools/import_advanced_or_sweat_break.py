#!/usr/bin/env python3
"""Import the author's locked V1.1 sweat-break dialogue without rewriting it."""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs/source_materials/advanced_or_sweat_break_v1/author_v1_1.md"
TARGET = ROOT / "data/advanced_surgery/advanced_or_ambient/sweat_break_v1.json"
ROLES = {
    "LEAD": "lead_surgeon", "ASSIST1": "assistant_1", "ASSIST2": "assistant_2",
    "SCRUB1": "scrub_primary", "SCRUB2": "scrub_secondary",
}
SPEAKERS = {
    "主刀": "lead_surgeon", "第一助手": "assistant_1", "第二助手": "assistant_2",
    "第一器械": "scrub_primary", "第二器械": "scrub_secondary", "巡回": "circulating_wiper",
}
THRESHOLDS = {
    "lead_surgeon": [120, 300, 480, 600], "assistant_1": [150, 360, 510, 660],
    "assistant_2": [180, 420, 540, 630], "scrub_primary": [210, 450],
    "scrub_secondary": [270, 570],
}


def build() -> dict:
    source = SOURCE.read_text(encoding="utf-8")
    chinese = source.split("## 3. 中文对白变体", 1)[1].split("## 4.", 1)[0]
    english = source.split("## 6. 英文逐句对照", 1)[1].split("## 7.", 1)[0]
    translated = {}
    for row in english.splitlines():
        match = re.fullmatch(r"\| `([A-Z]+\d?_\d\d)` \| (.*?) \| (.*?) \| (.*?) \|", row)
        if match:
            translated[match[1]] = [line for line in match.groups()[1:] if line != "—"]
    variants = {role: [] for role in THRESHOLDS}
    chunks = re.split(r"\*\*([A-Z]+\d?_\d\d)｜[^\n]*\*\*", chinese)
    for index in range(1, len(chunks), 2):
        variant_id, body = chunks[index:index + 2]
        prefix = variant_id.rsplit("_", 1)[0]
        role = ROLES[prefix]
        zh_lines = re.findall(r"^\d+\. \[([^]]+)\]「([^\n]*)」$", body, re.M)
        en_lines = translated.pop(variant_id)
        assert len(zh_lines) == len(en_lines) and 2 <= len(zh_lines) <= 3, variant_id
        variants[role].append({
            "id": variant_id,
            "lines": [
                {"id": f"{variant_id}_{number:02d}", "speaker_role": SPEAKERS[speaker],
                 "text": zh, "text_en": en}
                for number, ((speaker, zh), en) in enumerate(zip(zh_lines, en_lines), 1)
            ],
        })
    assert not translated, translated
    assert all(len(rows) == 4 for rows in variants.values()), {role: len(rows) for role, rows in variants.items()}
    assert sum(map(len, THRESHOLDS.values())) == 16
    return {
        "schema_version": "advanced_or_ambient_sweat_v1",
        "event_probability": 0.30,
        "max_groups_per_stage_transition": 1,
        "thresholds_minutes": THRESHOLDS,
        "variants": variants,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    content = json.dumps(build(), ensure_ascii=False, indent=2) + "\n"
    if args.check:
        assert TARGET.read_text(encoding="utf-8") == content, "Sweat-break JSON differs from author source"
    else:
        TARGET.parent.mkdir(parents=True, exist_ok=True)
        TARGET.write_text(content, encoding="utf-8")
    data = build()
    print(f"Sweat break source matched: {sum(map(len, data['thresholds_minutes'].values()))} thresholds, "
          f"{sum(map(len, data['variants'].values()))} bilingual variants, "
          f"{sum(len(v['lines']) for rows in data['variants'].values() for v in rows)} lines")
