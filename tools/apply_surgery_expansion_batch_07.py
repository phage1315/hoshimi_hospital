"""Apply the approved Batch 07 colorectal surgery package to canonical data."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

from apply_surgery_expansion_batch_04 import parse_yaml_like


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = Path("/Users/ningye/Downloads/HOSHIMI_SURGERY_EXPANSION_BATCH_07_CODEX_READY.md")
TARGET = ROOT / "data/surgeries/surgeries.json"

ROLES = ["primary_surgeon", "assistant_surgeon", "scrub_nurse", "circulating_nurse"]
GENERIC_RESPONSE = "「明白，继续。」"
GENERIC_CONDITIONAL_RESPONSE = "「请再确认一次。」"
GENERIC_CONFIRM_LABEL = "确认完成当前阶段"

CATALOG = {
    "surgery_open_abdominoperineal_resection": {
        "name": "开腹直肠切除（含肛门）",
        "procedure_group": "general_abdominal",
        "diagnosis_reaction_site_group": "abdominal",
        "positioning": {"primary_position": "lithotomy", "presentation_group": "lithotomy", "variant": "low_dorsal_lithotomy", "access_tags": ["abdominal", "pelvic", "perineal", "perineal_optional"]},
        "duration_minutes": 300,
        "base_difficulty": 84,
        "recommended_surgery": 80,
        "training_ceiling": 93,
        "palpation_profile": "gynecology_pelvic",
        "anesthesia_target_regions": ["abdomen", "genital"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90},
            {"id": "deep_low_rectal_plane", "weight": 25, "initial_visibility": 68, "player_hint": "病变位置很低，深部盆腔和会阴连接平面都偏紧。腹部阶段仍可按计划推进，但越接近盆底，术野越依赖稳定牵引和逐层分离。"},
        ],
        "fixed_stage_progress": [7] * 13 + [9],
    },
    "surgery_open_left_hemicolectomy": {
        "name": "开腹左半结肠切除",
        "procedure_group": "general_abdominal",
        "diagnosis_reaction_site_group": "abdominal",
        "positioning": {"primary_position": "supine", "presentation_group": "standard_torso", "variant": "standard_supine", "access_tags": ["abdominal"]},
        "duration_minutes": 180,
        "base_difficulty": 72,
        "recommended_surgery": 68,
        "training_ceiling": 86,
        "palpation_profile": "abdominal",
        "anesthesia_target_regions": ["abdomen"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90},
            {"id": "fixed_high_splenic_flexure", "weight": 25, "initial_visibility": 72, "player_hint": "左结肠和脾曲活动度差，近端横结肠向下牵拉也不理想。切除范围本身没有改变，但获得足够长度和无张力吻合会更依赖完整游离。"},
        ],
        "fixed_stage_progress": [8] * 11 + [12],
    },
    "surgery_open_low_anterior_resection": {
        "name": "开腹低位直肠前切除",
        "procedure_group": "general_abdominal",
        "diagnosis_reaction_site_group": "abdominal",
        "positioning": {"primary_position": "lithotomy", "presentation_group": "lithotomy", "variant": "low_dorsal_lithotomy", "access_tags": ["abdominal", "pelvic", "perineal_optional"]},
        "duration_minutes": 240,
        "base_difficulty": 82,
        "recommended_surgery": 78,
        "training_ceiling": 92,
        "palpation_profile": "gynecology_pelvic",
        "anesthesia_target_regions": ["abdomen", "genital"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90},
            {"id": "narrow_deep_pelvis", "weight": 25, "initial_visibility": 68, "player_hint": "盆腔深而狭窄，直肠远端和前外侧平面都不容易一次看清。保肛仍然可行，但 TME 和低位吻合会更依赖耐心与暴露。"},
        ],
        "fixed_stage_progress": [7] * 12 + [16],
    },
}

PART_II_HEADINGS = {
    "surgery_open_abdominoperineal_resection": "# 开腹直肠切除（含肛门） — Final Balance",
    "surgery_open_left_hemicolectomy": "# 开腹左半结肠切除 — Final Balance",
    "surgery_open_low_anterior_resection": "# 开腹低位直肠前切除 — Final Balance",
}


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


def section_after_heading(text: str, heading: str, next_heading: str | None) -> str:
    start = text.index(heading) + len(heading)
    end = text.index(next_heading, start) if next_heading else len(text)
    return text[start:end]


def parse_serialization(source: str) -> dict[str, dict]:
    part = source.split("# PART III", 1)[1]
    procedures = list(re.finditer(r"^# `([^`]+)`\s*$", part, re.M))
    result: dict[str, dict] = {}
    for index, procedure_match in enumerate(procedures):
        procedure_id = procedure_match.group(1)
        end = procedures[index + 1].start() if index + 1 < len(procedures) else len(part)
        block = part[procedure_match.end():end]
        for stage_match in re.finditer(r"^## `([^`]+)`\s*\n```yaml\s*\n(.*?)\n```", block, re.M | re.S):
            metadata = parse_yaml_like(stage_match.group(2))
            result[metadata["stage_id"]] = metadata
    return result


def parse_hooks(block: str) -> list[dict]:
    marker = re.search(r"^## Patient Hook Map\s*$", block, re.M)
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
        next_heading = PART_II_HEADINGS[ordered_ids[index + 1]] if index + 1 < len(ordered_ids) else None
        block = section_after_heading(part, PART_II_HEADINGS[procedure_id], next_heading)
        stage_matches = list(re.finditer(r"^### `([^`]+)`\s*\[([^]]+)\]", block, re.M))
        stages: dict[str, dict] = {}
        for stage_index, stage_match in enumerate(stage_matches):
            stage_id = stage_match.group(1)
            stage_end = stage_matches[stage_index + 1].start() if stage_index + 1 < len(stage_matches) else len(block)
            stage_block = block[stage_match.end():stage_end]
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
            for label, option_text in option_sources:
                blocks = re.findall(r"```yaml\s*\n(.*?)\n\s*```", option_text, re.S)
                if not blocks:
                    raise ValueError(f"Missing effects block for {procedure_id}/{stage_id}/{label}")
                options.append({"label": label, **parse_yaml_like(blocks[0])})
            if not options:
                raise ValueError(f"Missing options/effects for {procedure_id}/{stage_id}")
            entry_condition = None
            entry_match = re.search(r"Entry(?: condition)?:\s*\n+```text\s*\n(.*?)\n\s*```", stage_block, re.S)
            if entry_match:
                entry_condition = parse_condition(entry_match.group(1))
            stages[stage_id] = {"options": options, "entry_condition": entry_condition}
            if procedure_id == "surgery_open_abdominoperineal_resection" and stage_id == "apr_rework":
                # The package expresses this explicit conditional in prose rather
                # than another YAML block; preserve it as the existing runtime
                # conditional_effects shape.
                for option in options:
                    if option["label"].startswith("只处理最明显"):
                        option["conditional_effects"] = [{
                            "when": {"all": [{"field": "bleeding", "op": "gte", "value": 38}]},
                            "strategic_effects": {
                                "blood_loss": 12,
                                "stability": -6,
                                "add_complications": [{"id": "residual_bleeding", "severity": "minor"}],
                            },
                        }]
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
    procedure_match = re.search(rf"^# `{re.escape(procedure_id)}`\s*$", procedure_part, re.M)
    if not procedure_match:
        raise ValueError(f"Missing serialization section for {procedure_id}")
    procedure_block = procedure_part[procedure_match.end():]
    next_heading = re.search(r"^# `", procedure_block, re.M)
    if next_heading:
        procedure_block = procedure_block[:next_heading.start()]
    ordered_ids = re.findall(r"^## `([^`]+)`", procedure_block, re.M)
    hook_rows = balance["hooks"]
    correction_ids = {stage_id for stage_id, stage in balance["stages"].items() if stage["entry_condition"] is not None}
    fixed_hooks = [row for row in hook_rows if row["stage_label"] not in correction_ids]
    fixed_index = 0
    progress_index = 0
    stages = []
    progress = CATALOG[procedure_id]["fixed_stage_progress"]
    for stage_id in ordered_ids:
        if stage_id not in serialization or stage_id not in balance["stages"]:
            raise ValueError(f"Unmapped stage {procedure_id}/{stage_id}")
        metadata = serialization[stage_id]
        balance_stage = balance["stages"][stage_id]
        is_correction = balance_stage["entry_condition"] is not None
        if is_correction:
            hook = next(row for row in hook_rows if row["stage_label"] == stage_id)
            stage_kind = "conditional_correction"
            progress_delta = 0
        else:
            hook = fixed_hooks[fixed_index]
            fixed_index += 1
            stage_kind = "fixed"
            progress_delta = progress[progress_index]
            progress_index += 1
        stage = {
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
        }
        if is_correction:
            stage["entry_condition"] = balance_stage["entry_condition"]
            stage["once_per_episode"] = True
        stages.append(stage)
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
    for procedure_id in CATALOG:
        records[procedure_id] = make_record(procedure_id, build_stages(procedure_id, source))
    seen = set()
    ordered = []
    for row in data:
        if row["id"] in seen:
            raise ValueError(f"Duplicate catalog ID: {row['id']}")
        seen.add(row["id"])
        ordered.append(records.get(row["id"], row))
    for procedure_id in CATALOG:
        if procedure_id not in seen:
            ordered.append(records[procedure_id])
    TARGET.write_text(json.dumps(ordered, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    for procedure_id in CATALOG:
        record = records[procedure_id]
        fixed = [stage for stage in record["stages"] if stage.get("stage_kind") != "conditional_correction"]
        print(f"{procedure_id}: {len(fixed)} fixed + {len(record['stages']) - len(fixed)} correction, progress {sum(record['fixed_stage_progress'])}%")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
