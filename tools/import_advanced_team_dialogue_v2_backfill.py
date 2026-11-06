#!/usr/bin/env python3
"""Import the author's six V2 overlays without changing the existing V1 files."""
import argparse
import json
import re
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ARCHIVE = ROOT / "docs/source_materials/advanced_team_dialogue_v2_backfill_v1/author_package.zip"
DATA = ROOT / "data/advanced_surgery"
OUT = DATA / "dialogue_v2"
PREFIX = "HOSHIMI_ADVANCED_TEAM_DIALOGUE_V2_BACKFILL_V1/"
IDS = (
    "surgery_open_whipple",
    "surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction",
    "surgery_adv_sleeve_lobectomy",
    "surgery_adv_ebstein_cone_reconstruction",
    "surgery_adv_complex_abdominal_reconstruction",
    "surgery_adv_open_descending_thoracic_aortic_replacement",
)
ROLES = {
    "assistant_1", "assistant_2", "scrub_primary", "scrub_secondary",
    "circulating_primary", "circulating_secondary", "anesthesia", "lead_surgeon", "system",
}


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def build(archive: zipfile.ZipFile, procedure_id: str, procedure: dict) -> dict:
    source = json.loads(archive.read(PREFIX + "dialogue_v2/" + procedure_id + ".json"))
    authored = archive.read(PREFIX + "authored/" + procedure_id + ".psv").decode("utf-8")
    old = read_json(DATA / "dialogue" / (procedure_id + ".json"))
    assert old["schema_version"] == "advanced_day2_dialogue_v1", procedure_id
    assert source["schema_version"] == "advanced_day2_dialogue_v2_proposed"
    assert source["procedure_id"] == procedure_id
    assert list(source["stages"]) == [step["id"] for step in procedure["steps"]], procedure_id
    source_rows = []
    line_ids = set()
    for stage_id, groups in source["stages"].items():
        assert set(groups) == {"before_action", "after_resolution"}, stage_id
        before, after = groups["before_action"], groups["after_resolution"]
        assert 2 <= len(before) <= 3 and 1 <= len(after) <= 2 and 3 <= len(before) + len(after) <= 5
        for phase in ("before_action", "after_resolution"):
            for row in groups[phase]:
                assert set(row) == {"id", "speaker_role", "text", "text_en"}
                assert row["id"] not in line_ids and row["speaker_role"] in ROLES
                assert row["text"].strip() and row["text_en"].strip()
                assert not re.search(r"[\u3400-\u9fff]", row["text_en"])
                line_ids.add(row["id"])
                source_rows.append((stage_id, phase, row["speaker_role"], row["text"], row["text_en"]))
    author_rows = [tuple(line.split("|")) for line in authored.splitlines() if line and not line.startswith("#")]
    assert all(len(row) == 5 for row in author_rows)
    assert source_rows == author_rows, procedure_id
    assert sum("precision_failed" in group for group in old["stages"].values()) == sum(step["kind"] == "P" for step in procedure["steps"])
    source["schema_version"] = "advanced_day2_dialogue_v2"
    return source


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="verify the checked-in overlays without writing")
    args = parser.parse_args()
    procedures = {row["id"]: row for row in read_json(DATA / "procedures.json")}
    total_stages = total_lines = 0
    with zipfile.ZipFile(ARCHIVE) as archive:
        assert all(name.startswith(PREFIX) and ".." not in Path(name).parts for name in archive.namelist())
        for procedure_id in IDS:
            result = build(archive, procedure_id, procedures[procedure_id])
            total_stages += len(result["stages"])
            total_lines += sum(len(rows) for groups in result["stages"].values() for rows in groups.values())
            dest = OUT / (procedure_id + ".json")
            if args.check:
                assert read_json(dest) == result, dest
            else:
                OUT.mkdir(parents=True, exist_ok=True)
                dest.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    assert (total_stages, total_lines) == (73, 292)
    print(f"ADVANCED V2 BACKFILL {'AUDIT' if args.check else 'IMPORT'} PASS: 6 procedures, {total_stages} stages, {total_lines} bilingual lines; V1 files untouched")


if __name__ == "__main__":
    main()
