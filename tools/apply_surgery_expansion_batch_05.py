"""Apply the approved Batch 05 surgery package to Surgery V2 data.

The markdown package is authoritative for stage prose, option labels/effects,
technical flags, variants, hooks, and balance baselines.  This importer maps
those fields into the existing runtime schema without adding a parallel runner.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

from apply_surgery_expansion_batch_04 import parse_yaml_like


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = Path("/Users/ningye/Downloads/HOSHIMI_SURGERY_EXPANSION_BATCH_05_CODEX_READY (1).md")
TARGET = ROOT / "data/surgeries/surgeries.json"

ROLES = ["primary_surgeon", "assistant_surgeon", "scrub_nurse", "circulating_nurse"]
GENERIC_RESPONSE = "「明白，继续。」"
GENERIC_CONDITIONAL_RESPONSE = "「请再确认一次。」"
GENERIC_CONFIRM_LABEL = "确认完成当前阶段"

CATALOG = {
    "surgery_cabg": {
        "name": "开胸心脏搭桥",
        "procedure_group": "cardiac",
        "diagnosis_reaction_site_group": "thoracic_cardiac",
        "positioning": {"primary_position": "supine", "presentation_group": "standard_torso", "variant": "supine_arms_tucked", "access_tags": ["median_sternotomy"]},
        "duration_minutes": 360,
        "base_difficulty": 92,
        "recommended_surgery": 88,
        "training_ceiling": 99,
        "palpation_profile": "thoracic_cardiac",
        "anesthesia_target_regions": ["chest"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90},
            {"id": "small_diffuse_coronary_targets", "weight": 25, "initial_visibility": 70, "player_hint": "冠脉靶点偏细，而且病变分布较弥散。计划仍然可行，但每一处远端吻合都更依赖稳定暴露和耐心。"},
        ],
        "fixed_stage_progress": [8] * 11 + [12],
    },
    "surgery_open_total_gastrectomy": {
        "name": "开腹全胃切除",
        "procedure_group": "general_abdominal",
        "diagnosis_reaction_site_group": "abdominal",
        "positioning": {"primary_position": "supine", "presentation_group": "standard_torso", "variant": "standard_supine", "access_tags": ["abdominal"]},
        "duration_minutes": 240,
        "base_difficulty": 78,
        "recommended_surgery": 74,
        "training_ceiling": 90,
        "palpation_profile": "abdominal",
        "anesthesia_target_regions": ["abdomen"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90},
            {"id": "dense_upper_abdominal_adhesions", "weight": 25, "initial_visibility": 70, "player_hint": "上腹粘连明显，胃后方、脾门侧和贲门区域都不够干净；全胃切除仍可按计划进行，但切除和重建会更依赖前期暴露。"},
        ],
        "fixed_stage_progress": [7] * 12 + [16],
    },
    "surgery_open_major_liver_resection": {
        "name": "开腹肝叶切除",
        "procedure_group": "general_abdominal",
        "diagnosis_reaction_site_group": "abdominal",
        "positioning": {"primary_position": "supine", "presentation_group": "standard_torso", "variant": "standard_supine", "access_tags": ["abdominal"]},
        "duration_minutes": 300,
        "base_difficulty": 90,
        "recommended_surgery": 87,
        "training_ceiling": 98,
        "palpation_profile": "abdominal",
        "anesthesia_target_regions": ["abdomen"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90},
            {"id": "friable_hypervascular_parenchyma", "weight": 25, "initial_visibility": 70, "player_hint": "目标肝叶组织偏脆、血供丰富，断肝面很容易被持续渗血遮住；如果只抢速度，深部结构会迅速失去清晰度。"},
        ],
        "fixed_stage_progress": [8] * 11 + [12],
    },
    "surgery_open_abdominal_aortic_aneurysm": {
        "name": "开腹主动脉瘤修补",
        "procedure_group": "vascular",
        "diagnosis_reaction_site_group": "abdominal",
        "positioning": {"primary_position": "supine", "presentation_group": "standard_torso", "variant": "standard_supine", "access_tags": ["abdominal"]},
        "duration_minutes": 240,
        "base_difficulty": 93,
        "recommended_surgery": 90,
        "training_ceiling": 99,
        "palpation_profile": "abdominal",
        "anesthesia_target_regions": ["abdomen"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90},
            {"id": "short_calcified_neck", "weight": 25, "initial_visibility": 70, "player_hint": "近端瘤颈偏短并伴明显钙化，可靠夹闭和近端吻合空间都更有限；重建仍可进行，但近端控制必须更谨慎。"},
        ],
        "fixed_stage_progress": [9] * 10 + [10],
    },
}

EXPECTED_BASELINES = {
    "surgery_cabg": {"expected_time": 360, "expected_blood_loss": 210},
    "surgery_open_total_gastrectomy": {"expected_time": 240, "expected_blood_loss": 120},
    "surgery_open_major_liver_resection": {"expected_time": 300, "expected_blood_loss": 180},
    "surgery_open_abdominal_aortic_aneurysm": {"expected_time": 240, "expected_blood_loss": 170},
}


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
    marker = re.search(r"(?:^### Patient Hook Map$|^Patient hooks:$)", block, re.M)
    if not marker:
        raise ValueError("Missing patient hook map")
    table_end = re.search(r"\n\nTags:", block[marker.end():], re.S)
    table = block[marker.end(): marker.end() + table_end.start() if table_end else len(block)]
    result = []
    for line in table.splitlines():
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


def parse_balance(source: str) -> dict[str, dict[str, dict]]:
    part = source.split("# PART II", 1)[1].split("# PART III", 1)[0]
    matches = list(re.finditer(r"^# \d+\. .*? — `(surgery_[a-z0-9_]+)`$", part, re.M))
    result: dict[str, dict[str, dict]] = {}
    for index, procedure_match in enumerate(matches):
        procedure_id = procedure_match.group(1)
        end = matches[index + 1].start() if index + 1 < len(matches) else len(part)
        block = part[procedure_match.end():end]
        stage_matches = list(re.finditer(r"^(?:### )?(?:\d+|Correction) `([^`]+)`", block, re.M))
        stages: dict[str, dict] = {}
        for stage_index, stage_match in enumerate(stage_matches):
            stage_id = stage_match.group(1)
            stage_end = stage_matches[stage_index + 1].start() if stage_index + 1 < len(stage_matches) else len(block)
            stage_block = block[stage_match.end():stage_end]
            is_correction = stage_match.group(0).startswith("Correction")
            options: list[dict] = []

            action_match = re.search(r"Only action:\s*\*\*(.+?)\*\*", stage_block)
            if action_match:
                option_sources = [(action_match.group(1).strip(), stage_block[action_match.end():])]
            else:
                labels = list(re.finditer(r"^[ABC] \*\*(.+?)\*\*", stage_block, re.M))
                option_sources = []
                for option_index, label_match in enumerate(labels):
                    option_end = labels[option_index + 1].start() if option_index + 1 < len(labels) else len(stage_block)
                    option_sources.append((label_match.group(1).strip(), stage_block[label_match.end():option_end]))
            if not option_sources:
                blocks = re.findall(r"```yaml\n(.*?)\n```", stage_block, re.S)
                if not blocks:
                    raise ValueError(f"Missing effects block for {procedure_id}/{stage_id}")
                options = [{"label": GENERIC_CONFIRM_LABEL, **parse_yaml_like(blocks[0])}]
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
    stages = []
    progress = CATALOG[procedure_id]["fixed_stage_progress"]
    progress_index = 0
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
    ordered = [records[row["id"]] if row["id"] in CATALOG else row for row in data]
    missing = [procedure_id for procedure_id in CATALOG if procedure_id not in {row["id"] for row in data}]
    if missing:
        raise ValueError(f"Batch 05 requires in-place catalog records; missing: {missing}")
    TARGET.write_text(json.dumps(ordered, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    for procedure_id in CATALOG:
        record = records[procedure_id]
        fixed = [stage for stage in record["stages"] if stage.get("stage_kind") != "conditional_correction"]
        print(f"{procedure_id}: {len(fixed)} fixed + {len(record['stages']) - len(fixed)} correction, progress {sum(record['fixed_stage_progress'])}%")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
