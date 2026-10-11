"""Apply the approved Batch 06 surgery package to Surgery V2 data."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

from apply_surgery_expansion_batch_04 import parse_yaml_like


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = Path("/Users/ningye/Downloads/HOSHIMI_SURGERY_EXPANSION_BATCH_06_CODEX_READY.md")
TARGET = ROOT / "data/surgeries/surgeries.json"

ROLES = ["primary_surgeon", "assistant_surgeon", "scrub_nurse", "circulating_nurse"]
GENERIC_RESPONSE = "「明白，继续。」"
GENERIC_CONDITIONAL_RESPONSE = "「请再确认一次。」"
GENERIC_CONFIRM_LABEL = "确认完成当前阶段"

CATALOG = {
    "surgery_exploratory_laparotomy": {
        "name": "大开腹探查",
        "procedure_group": "general_abdominal",
        "diagnosis_reaction_site_group": "abdominal",
        "positioning": {"primary_position": "supine", "presentation_group": "standard_torso", "variant": "standard_supine", "access_tags": ["abdominal"]},
        "duration_minutes": 480,
        "base_difficulty": 82,
        "recommended_surgery": 78,
        "training_ceiling": 92,
        "palpation_profile": "abdominal",
        "anesthesia_target_regions": ["abdomen"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90},
            {"id": "adhesive_obscured_abdomen", "weight": 25, "initial_visibility": 68, "player_hint": "腹腔内既往粘连和组织遮挡明显，多个区域不能一次完整展开。真正的难点不是“打开腹腔”，而是保证系统探查不会因为术野差而漏掉区域。"},
        ],
        "fixed_stage_progress": [10] * 10,
    },
    "surgery_open_pneumonectomy": {
        "name": "开胸全肺切除",
        "procedure_group": "thoracic",
        "diagnosis_reaction_site_group": "thoracic_cardiac",
        "positioning": {"primary_position": "supine", "presentation_group": "standard_torso", "variant": "standard_supine", "access_tags": ["thoracic"]},
        "duration_minutes": 240,
        "base_difficulty": 88,
        "recommended_surgery": 84,
        "training_ceiling": 96,
        "palpation_profile": "thoracic_cardiac",
        "anesthesia_target_regions": ["chest"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90},
            {"id": "dense_hilar_fibrosis", "weight": 25, "initial_visibility": 68, "player_hint": "肺门周围纤维化和粘连明显，主血管与主支气管的界限不够干净。全肺切除仍可进行，但肺门暴露质量会明显影响风险。"},
        ],
        "fixed_stage_progress": [10] * 10,
    },
    "surgery_open_esophagectomy": {
        "name": "开胸食管切除",
        "procedure_group": "thoracic",
        "diagnosis_reaction_site_group": "thoracic_cardiac",
        "positioning": {"primary_position": "supine", "presentation_group": "standard_torso", "variant": "standard_supine", "access_tags": ["abdominal", "thoracic"]},
        "duration_minutes": 360,
        "base_difficulty": 94,
        "recommended_surgery": 90,
        "training_ceiling": 99,
        "palpation_profile": "thoracic_cardiac",
        "anesthesia_target_regions": ["abdomen", "chest"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90},
            {"id": "dense_mediastinal_plane", "weight": 25, "initial_visibility": 68, "player_hint": "胸段食管周围组织层次偏紧，纵隔游离和胃管上提路径都更依赖清楚暴露；如果前后两个阶段衔接不好，重建会变得很狼狈。"},
        ],
        "fixed_stage_progress": [7] * 12 + [16],
    },
    "surgery_open_radical_cystectomy": {
        "name": "开腹膀胱全切除",
        "procedure_group": "urologic",
        "diagnosis_reaction_site_group": "abdominal",
        "positioning": {"primary_position": "supine", "presentation_group": "standard_torso", "variant": "standard_supine", "access_tags": ["abdominal", "pelvic"]},
        "duration_minutes": 300,
        "base_difficulty": 87,
        "recommended_surgery": 83,
        "training_ceiling": 96,
        "palpation_profile": "abdominal",
        "anesthesia_target_regions": ["abdomen"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90},
            {"id": "fibrotic_narrow_pelvis", "weight": 25, "initial_visibility": 68, "player_hint": "盆腔深部空间狭窄并伴明显纤维化，输尿管、膀胱侧蒂和尿道方向都更难同时看清；切除和尿路重建都会更依赖暴露。"},
        ],
        "fixed_stage_progress": [8] * 11 + [12],
    },
}

EXPECTED_BASELINES = {
    "surgery_exploratory_laparotomy": {"expected_time": 480, "expected_blood_loss": 135},
    "surgery_open_pneumonectomy": {"expected_time": 240, "expected_blood_loss": 120},
    "surgery_open_esophagectomy": {"expected_time": 360, "expected_blood_loss": 135},
    "surgery_open_radical_cystectomy": {"expected_time": 300, "expected_blood_loss": 120},
}

PART_II_HEADINGS = {
    "surgery_exploratory_laparotomy": "# 9. Exploratory Laparotomy — Final Effects",
    "surgery_open_pneumonectomy": "# 10. Pneumonectomy — Final Effects",
    "surgery_open_esophagectomy": "# 11. Esophagectomy — Final Effects",
    "surgery_open_radical_cystectomy": "# 12. Radical Cystectomy — Final Effects",
}


def section_after_heading(text: str, heading: str, next_heading: str | None) -> str:
    start = text.index(heading) + len(heading)
    end = text.index(next_heading, start) if next_heading else len(text)
    return text[start:end]


def parse_serialization(source: str) -> dict[str, dict]:
    part = source.split("# PART III", 1)[1]
    matches = list(re.finditer(r"^## (surgery_[a-z0-9_]+)$", part, re.M))
    result: dict[str, dict] = {}
    for index, procedure_match in enumerate(matches):
        end = matches[index + 1].start() if index + 1 < len(matches) else len(part)
        block = part[procedure_match.end():end]
        for stage_match in re.finditer(r"^### `([^`]+)`\n\n```yaml\n(.*?)\n```", block, re.M | re.S):
            metadata = parse_yaml_like(stage_match.group(2))
            result[metadata["stage_id"]] = metadata
    return result


def parse_condition(raw: str) -> dict:
    conditions = []
    for expression in re.split(r"\s+OR\s+", raw.strip()):
        match = re.fullmatch(r"([a-z_]+)\s*(<|<=|>=|>|==|=)\s*(true|false|\d+)", expression.strip())
        if not match:
            raise ValueError(f"Unsupported correction condition: {expression}")
        op = {"<": "lt", "<=": "lte", ">": "gt", ">=": "gte", "==": "eq", "=": "eq"}[match.group(2)]
        value = match.group(3)
        conditions.append({"field": match.group(1), "op": op, "value": value == "true" if value in {"true", "false"} else int(value)})
    return {"any": conditions}


def parse_hooks(block: str) -> list[dict]:
    marker = re.search(r"^Patient Hook Map:\s*$", block, re.M)
    if not marker:
        raise ValueError("Missing Patient Hook Map")
    result = []
    for line in block[marker.end():].splitlines():
        if not line.startswith("|") or line.startswith("|---") or line.startswith("| Stage"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) != 3:
            continue
        stage_label, interlude, cues = cells
        result.append({
            "stage_label": stage_label.strip("`").strip(),
            "awake_interlude": interlude.strip("`").strip(),
            "patient_cues": [cue.strip().strip("`").strip() for cue in cues.split(",")],
        })
    return result


def parse_balance(source: str) -> dict[str, dict]:
    part = source.split("# PART II", 1)[1].split("# PART III", 1)[0]
    result: dict[str, dict] = {}
    ordered_ids = list(CATALOG)
    for index, procedure_id in enumerate(ordered_ids):
        heading = PART_II_HEADINGS[procedure_id]
        next_heading = PART_II_HEADINGS[ordered_ids[index + 1]] if index + 1 < len(ordered_ids) else None
        block = section_after_heading(part, heading, next_heading)
        stage_matches = list(re.finditer(r"^## (?:\d+|Correction) `([^`]+)`", block, re.M))
        stages: dict[str, dict] = {}
        for stage_index, stage_match in enumerate(stage_matches):
            stage_id = stage_match.group(1)
            stage_end = stage_matches[stage_index + 1].start() if stage_index + 1 < len(stage_matches) else len(block)
            stage_block = block[stage_match.end():stage_end]
            is_correction = stage_match.group(0).startswith("## Correction")
            action_match = re.search(r"Only action:\s*\*\*(.+?)\*\*", stage_block)
            if action_match:
                option_sources = [(action_match.group(1).strip(), stage_block[action_match.end():])]
            else:
                labels = list(re.finditer(r"^[ABC] \*\*(.+?)\*\*", stage_block, re.M))
                option_sources = []
                for option_index, label_match in enumerate(labels):
                    option_end = labels[option_index + 1].start() if option_index + 1 < len(labels) else len(stage_block)
                    option_sources.append((label_match.group(1).strip(), stage_block[label_match.end():option_end]))
            options = []
            if not option_sources:
                blocks = re.findall(r"```yaml\n(.*?)\n```", stage_block, re.S)
                if not blocks:
                    raise ValueError(f"Missing options/effects for {procedure_id}/{stage_id}")
                options.append({"label": GENERIC_CONFIRM_LABEL, **parse_yaml_like(blocks[0])})
            else:
                for label, option_text in option_sources:
                    blocks = re.findall(r"```yaml\n(.*?)\n```", option_text, re.S)
                    if not blocks:
                        raise ValueError(f"Missing effects block for {procedure_id}/{stage_id}/{label}")
                    options.append({"label": label, **parse_yaml_like(blocks[0])})
            entry_condition = None
            entry_match = re.search(r"Entry:\n```text\n(.*?)\n```", stage_block, re.S)
            if entry_match:
                entry_condition = parse_condition(entry_match.group(1))
            stages[stage_id] = {"options": options, "entry_condition": entry_condition, "is_correction": is_correction}
        result[procedure_id] = {"stages": stages, "hooks": parse_hooks(block)}
    return result


def make_option(stage_id: str, index: int, source: dict) -> dict:
    option = {
        "id": f"{stage_id}_{chr(ord('a') + index)}",
        "label": source["label"],
        "response": GENERIC_RESPONSE,
        "response_role": "assistant_surgeon",
        "correct": True,
        "correction": "",
        "strategic_effects": source.get("strategic_effects", {}),
    }
    conditional_effects = []
    for conditional in source.get("conditional_effects", []):
        conditional = dict(conditional)
        conditional["response"] = GENERIC_CONDITIONAL_RESPONSE
        conditional["response_role"] = "assistant_surgeon"
        conditional_effects.append(conditional)
    if conditional_effects:
        option["conditional_effects"] = conditional_effects
    return option


def build_stages(procedure_id: str, source: str) -> list[dict]:
    serialization = parse_serialization(source)
    balance = parse_balance(source)[procedure_id]
    procedure_part = source.split("# PART III", 1)[1]
    procedure_match = re.search(rf"^## {re.escape(procedure_id)}$", procedure_part, re.M)
    procedure_block = procedure_part[procedure_match.end():]
    next_heading = re.search(r"^## ", procedure_block, re.M)
    if next_heading:
        procedure_block = procedure_block[:next_heading.start()]
    ordered_ids = re.findall(r"^### `([^`]+)`", procedure_block, re.M)
    hook_rows = balance["hooks"]
    fixed_hooks = [row for row in hook_rows if row["stage_label"].lower() != "correction"]
    fixed_index = 0
    progress = CATALOG[procedure_id]["fixed_stage_progress"]
    progress_index = 0
    stages = []
    for stage_id in ordered_ids:
        metadata = serialization[stage_id]
        balance_stage = balance["stages"][stage_id]
        is_correction = balance_stage["entry_condition"] is not None
        if is_correction:
            hook = next(row for row in hook_rows if row["stage_label"].lower() == "correction")
            stage_kind = "conditional_correction"
            progress_delta = 0
        else:
            hook = fixed_hooks[fixed_index]
            fixed_index += 1
            stage_kind = "fixed"
            progress_delta = progress[progress_index]
            progress_index += 1
        stages.append({
            "id": stage_id,
            "title": metadata["title"],
            "kind": "confirm" if metadata["class"] == "F" else "decision",
            "stage_kind": stage_kind,
            "progress_delta": progress_delta,
            "prompt": metadata["prompt"],
            "operative_record": metadata["operative_record"],
            "transition_text": metadata["transition_text"],
            "options": [make_option(stage_id, index, option) for index, option in enumerate(balance_stage["options"])],
            "awake_interlude": hook["awake_interlude"],
            "patient_cues": hook["patient_cues"],
            **({"entry_condition": balance_stage["entry_condition"], "once_per_episode": True} if is_correction else {}),
        })
    if progress_index != len(progress) or fixed_index != len(fixed_hooks):
        raise ValueError(f"Stage/progress/hook mismatch for {procedure_id}")
    return stages


def make_record(procedure_id: str, stages: list[dict]) -> dict:
    metadata = CATALOG[procedure_id]
    return {
        "id": procedure_id,
        "name": metadata["name"],
        "duration_minutes": metadata["duration_minutes"],
        "status": "ready",
        "required_roles": ROLES,
        "initial_state": {"stability": 100, "blood_loss": 0, "visibility": 90, "progress": 0, "elapsed_time": 0, "stress": 0, "bleeding": 0},
        "stages": stages,
        "success_condition": {"metric": "progress", "operator": ">=", "value": 100},
        "failure_condition": {"metric": "stability", "operator": "<=", "value": 0},
        "procedure_group": metadata["procedure_group"],
        "diagnosis_reaction_site_group": metadata["diagnosis_reaction_site_group"],
        "palpation_profile": metadata["palpation_profile"],
        "positioning": metadata["positioning"],
        "base_difficulty": metadata["base_difficulty"],
        "recommended_surgery": metadata["recommended_surgery"],
        "training_ceiling": metadata["training_ceiling"],
        "unlocked_at_start": False,
        "anesthesia_target_regions": metadata["anesthesia_target_regions"],
        "case_variants": metadata["variants"],
        "fixed_stage_progress": metadata["fixed_stage_progress"],
    }


def main() -> int:
    source_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_SOURCE
    source = source_path.read_text(encoding="utf-8")
    data = json.loads(TARGET.read_text(encoding="utf-8"))
    records = {row["id"]: row for row in data}
    existing_ids = {row["id"] for row in data}
    missing = [procedure_id for procedure_id in CATALOG if procedure_id not in existing_ids]
    if missing:
        raise ValueError(f"Batch 06 requires in-place catalog records; missing: {missing}")
    for procedure_id in CATALOG:
        records[procedure_id] = make_record(procedure_id, build_stages(procedure_id, source))
    ordered = [records[row["id"]] if row["id"] in CATALOG else row for row in data]
    TARGET.write_text(json.dumps(ordered, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    for procedure_id in CATALOG:
        record = records[procedure_id]
        fixed = [stage for stage in record["stages"] if stage.get("stage_kind") != "conditional_correction"]
        print(f"{procedure_id}: {len(fixed)} fixed + {len(record['stages']) - len(fixed)} correction, progress {sum(record['fixed_stage_progress'])}%")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
