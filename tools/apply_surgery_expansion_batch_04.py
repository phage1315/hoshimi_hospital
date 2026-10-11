"""Apply the approved Batch 04 surgery package to canonical runtime data.

The Codex-ready markdown is the source of truth for stage prose, option labels,
strategic effects, patient hooks, and case variants.  This importer keeps the
conversion reviewable while preserving the existing Surgery V2 JSON shape.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = Path("/Users/ningye/Downloads/HOSHIMI_SURGERY_EXPANSION_BATCH_04_CODEX_READY_CATALOG_COMPLETE.md")
TARGET = ROOT / "data/surgeries/surgeries.json"

ROLES = ["primary_surgeon", "assistant_surgeon", "scrub_nurse", "circulating_nurse"]
GENERIC_RESPONSE = "「明白，继续。」"
GENERIC_CONDITIONAL_RESPONSE = "「请再确认一次。」"

CATALOG = {
    "surgery_vaginal_hysterectomy": {
        "name": "经阴道子宫全切除",
        "procedure_group": "female_pelvic",
        "diagnosis_reaction_site_group": "gynecology_pelvic",
        "positioning": {
            "primary_position": "lithotomy",
            "presentation_group": "lithotomy",
            "variant": "low_dorsal_lithotomy",
            "access_tags": ["pelvic", "perineal", "vaginal_assistance"],
        },
        "duration_minutes": 120,
        "base_difficulty": 70,
        "recommended_surgery": 65,
        "training_ceiling": 84,
        "palpation_profile": "gynecology_pelvic",
        "anesthesia_target_regions": ["genital"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "宫颈暴露以后，子宫下降条件尚可，阴道入路能够按正常节奏逐步向上推进。"},
            {"id": "limited_descent", "weight": 25, "initial_visibility": 72, "player_hint": "子宫下降度较差，穹隆和深部蒂部并不能一次进入清楚视野；后续每一组结构都更依赖稳定牵引和逐步暴露。"},
        ],
        "fixed_progress": [10] * 10,
        "expected_time": 120,
        "expected_blood_loss": 60,
    },
    "surgery_open_distal_pancreatectomy": {
        "name": "开腹胰体尾切除",
        "procedure_group": "general_abdominal",
        "diagnosis_reaction_site_group": "abdominal",
        "positioning": {
            "primary_position": "supine",
            "presentation_group": "standard_torso",
            "variant": "standard_supine",
            "access_tags": ["abdominal"],
        },
        "duration_minutes": 180,
        "base_difficulty": 76,
        "recommended_surgery": 72,
        "training_ceiling": 89,
        "palpation_profile": "abdominal",
        "anesthesia_target_regions": ["abdomen"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "胰体尾与脾血管之间的层次较清楚，保留脾脏的解剖条件看起来不错。"},
            {"id": "adherent_splenic_vessel_plane", "weight": 25, "initial_visibility": 70, "player_hint": "胰体尾与脾血管之间粘连紧密，尤其静脉侧分离层次不够干净；保脾仍然可行，但会明显依赖术野和耐心。"},
        ],
        "fixed_progress": [9] * 10 + [10],
        "expected_time": 180,
        "expected_blood_loss": 90,
    },
    "surgery_open_partial_nephrectomy": {
        "name": "开腹部分肾切除",
        "procedure_group": "urologic",
        "diagnosis_reaction_site_group": "abdominal",
        # The approved compatibility decision deliberately maps the authored
        # lateral/flank operation to the current supine runtime positioning.
        "positioning": {
            "primary_position": "supine",
            "presentation_group": "standard_torso",
            "variant": "standard_supine",
            "access_tags": ["flank"],
        },
        "duration_minutes": 150,
        "base_difficulty": 80,
        "recommended_surgery": 76,
        "training_ceiling": 91,
        "palpation_profile": "abdominal",
        "anesthesia_target_regions": ["abdomen"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "肿瘤轮廓较容易与正常肾实质区分，深部方向和计划切除线能够较快建立。"},
            {"id": "deep_hilar_tumor", "weight": 25, "initial_visibility": 72, "player_hint": "肿瘤位置偏深并接近肾门侧，表面轮廓只反映了部分范围；真正的深部边界要在切除过程中才能完全确认。"},
        ],
        "fixed_progress": [8] * 11 + [12],
        "expected_time": 150,
        "expected_blood_loss": 70,
    },
    "surgery_open_adrenalectomy": {
        "name": "开腹肾上腺切除",
        "procedure_group": "urologic",
        "diagnosis_reaction_site_group": "abdominal",
        # See the approved compatibility decision above: filler may describe
        # side-up positioning, while the current runtime renders supine.
        "positioning": {
            "primary_position": "supine",
            "presentation_group": "standard_torso",
            "variant": "standard_supine",
            "access_tags": ["flank"],
        },
        "duration_minutes": 120,
        "base_difficulty": 74,
        "recommended_surgery": 70,
        "training_ceiling": 88,
        "palpation_profile": "abdominal",
        "anesthesia_target_regions": ["abdomen"],
        "variants": [
            {"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "肾上腺和周围主要结构的关系较清楚，中央静脉方向能够逐步建立。"},
            {"id": "hypervascular_deep_plane", "weight": 25, "initial_visibility": 72, "player_hint": "肾上腺位置深、周围小血管丰富，中央静脉方向受到组织遮挡；如果暴露不足就强行推进，出血会很快破坏术野。"},
        ],
        "fixed_progress": [10] * 10,
        "expected_time": 120,
        "expected_blood_loss": 60,
    },
}


def scalar(value: str):
    value = value.strip()
    if not value:
        return None
    if value.startswith('"') and value.endswith('"'):
        return json.loads(value)
    if value.startswith("'") and value.endswith("'"):
        return value[1:-1].replace("''", "'")
    if value in {"true", "True"}:
        return True
    if value in {"false", "False"}:
        return False
    if re.fullmatch(r"[+-]?\d+", value):
        return int(value)
    if re.fullmatch(r"[+-]?\d+\.\d+", value):
        return float(value)
    return value


def split_key_value(text: str) -> tuple[str, str]:
    if ":" not in text:
        raise ValueError(f"Invalid YAML-like line: {text}")
    key, value = text.split(":", 1)
    return key.strip(), value.strip()


def parse_yaml_like(raw: str):
    rows = []
    for line in raw.splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        rows.append((len(line) - len(line.lstrip(" ")), line.strip()))

    def parse_block(index: int, indent: int):
        if index >= len(rows) or rows[index][0] < indent:
            return {}, index
        is_list = rows[index][0] == indent and rows[index][1].startswith("-")
        if is_list:
            result = []
            while index < len(rows) and rows[index][0] == indent and rows[index][1].startswith("-"):
                content = rows[index][1][1:].strip()
                if not content:
                    child_indent = rows[index + 1][0] if index + 1 < len(rows) else indent + 2
                    child, index = parse_block(index + 1, child_indent)
                    result.append(child)
                    continue
                if ":" not in content:
                    result.append(scalar(content))
                    index += 1
                    continue
                key, value = split_key_value(content)
                item = {}
                index += 1
                if value:
                    item[key] = scalar(value)
                elif index < len(rows) and rows[index][0] > indent:
                    child, index = parse_block(index, rows[index][0])
                    item[key] = child
                else:
                    item[key] = {}
                if index < len(rows) and rows[index][0] > indent and not rows[index][1].startswith("-"):
                    child, index = parse_block(index, rows[index][0])
                    if isinstance(child, dict):
                        item.update(child)
                result.append(item)
            return result, index

        result = {}
        while index < len(rows) and rows[index][0] == indent and not rows[index][1].startswith("-"):
            key, value = split_key_value(rows[index][1])
            index += 1
            if value:
                result[key] = scalar(value)
            elif index < len(rows) and rows[index][0] > indent:
                child, index = parse_block(index, rows[index][0])
                result[key] = child
            else:
                result[key] = {}
        return result, index

    return parse_block(0, rows[0][0])[0] if rows else {}


def code_blocks(text: str, language: str = "yaml"):
    return [match.group(1) for match in re.finditer(rf"```{language}\n(.*?)\n```", text, re.S)]


def parse_serialization(source: str) -> dict[str, dict]:
    part = source.split("# PART III", 1)[1]
    result = {}
    procedure_matches = list(re.finditer(r"^## (surgery_[a-z0-9_]+)$", part, re.M))
    for p_index, procedure_match in enumerate(procedure_matches):
        end = procedure_matches[p_index + 1].start() if p_index + 1 < len(procedure_matches) else len(part)
        block = part[procedure_match.end():end]
        for stage_match in re.finditer(r"^### `([^`]+)`\n\n```yaml\n(.*?)\n```", block, re.M | re.S):
            metadata = parse_yaml_like(stage_match.group(2))
            result[metadata["stage_id"]] = metadata
    return result


def parse_hook_maps(source: str) -> dict[str, list[dict]]:
    part = source.split("# PART II", 1)[1].split("# PART III", 1)[0]
    result = {}
    procedure_matches = list(re.finditer(r"^# \d+\. .*? — Final Balance$", part, re.M))
    for p_index, procedure_match in enumerate(procedure_matches):
        end = procedure_matches[p_index + 1].start() if p_index + 1 < len(procedure_matches) else len(part)
        block = part[procedure_match.end():end]
        procedure_id_match = re.search(r"procedure_id:\s*(surgery_[a-z0-9_]+)", block)
        if not procedure_id_match:
            continue
        procedure_id = procedure_id_match.group(1)
        table_match = re.search(r"### Patient Hook Map\n\n(.*?)(?:\n\nSuggested tags:)", block, re.S)
        if not table_match:
            raise ValueError(f"Missing Patient Hook Map for {procedure_id}")
        rows = []
        for line in table_match.group(1).splitlines():
            if not line.startswith("|") or line.startswith("|---") or line.startswith("| Stage"):
                continue
            cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
            if len(cells) != 4:
                continue
            stage_label, stage_class, interlude, cues = cells
            rows.append({
                "stage_label": stage_label,
                "class": stage_class,
                "awake_interlude": interlude.strip("`").strip(),
                "patient_cues": [cue.strip().strip("`").strip() for cue in cues.split(",")],
            })
        result[procedure_id] = rows
    return result


def parse_balance(source: str) -> dict[str, dict[str, list]]:
    part = source.split("# PART II", 1)[1].split("# PART III", 1)[0]
    result = {}
    procedure_matches = list(re.finditer(r"^# \d+\. .*? — Final Balance$", part, re.M))
    for p_index, procedure_match in enumerate(procedure_matches):
        end = procedure_matches[p_index + 1].start() if p_index + 1 < len(procedure_matches) else len(part)
        block = part[procedure_match.end():end]
        procedure_id_match = re.search(r"procedure_id:\s*(surgery_[a-z0-9_]+)", block)
        if not procedure_id_match:
            continue
        procedure_id = procedure_id_match.group(1)
        stage_matches = list(re.finditer(r"^## (?:Stage \d+ — |Conditional Correction — )`([^`]+)`(?: \[[^]]+\])?$", block, re.M))
        stages = {}
        for s_index, stage_match in enumerate(stage_matches):
            stage_end = stage_matches[s_index + 1].start() if s_index + 1 < len(stage_matches) else len(block)
            stage_block = block[stage_match.end():stage_end]
            # Calibration notes and later balance commentary may contain bold
            # phrases that are not player-facing options.  Only parse the
            # option portion of each stage.
            option_block = re.split(r"\n### Standard-route calibration\b", stage_block, maxsplit=1)[0]
            labels = list(re.finditer(r"^>?\s*(?:[ABC] )?\*\*(.+?)\*\*$", option_block, re.M))
            options = []
            for label_index, label_match in enumerate(labels):
                label = label_match.group(1).strip()
                option_end = labels[label_index + 1].start() if label_index + 1 < len(labels) else len(option_block)
                option_text = option_block[label_match.end():option_end]
                blocks = code_blocks(option_text)
                if not blocks:
                    raise ValueError(f"Missing effects block for {procedure_id}/{stage_match.group(1)}/{label}")
                parsed = parse_yaml_like(blocks[0])
                options.append({"label": label, **parsed})
            if not options:
                raise ValueError(f"Missing options for {procedure_id}/{stage_match.group(1)}")
            entry_condition = None
            entry_match = re.search(r"Entry:\n\n```text\n(.*?)\n```", stage_block, re.S)
            if entry_match:
                conditions = []
                for expression in re.split(r"\s+OR\s+", entry_match.group(1).strip()):
                    match = re.fullmatch(r"([a-z_]+)\s*(<|<=|>=|>|==|=)\s*(true|false|\d+)", expression.strip())
                    if not match:
                        raise ValueError(f"Unsupported correction condition: {expression}")
                    op = {"<": "lt", "<=": "lte", ">": "gt", ">=": "gte", "==": "eq", "=": "eq"}[match.group(2)]
                    value = match.group(3)
                    conditions.append({"field": match.group(1), "op": op, "value": value == "true" if value in {"true", "false"} else int(value)})
                entry_condition = {"any": conditions}
            stages[stage_match.group(1)] = {"options": options, "entry_condition": entry_condition}
        result[procedure_id] = stages
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
    for conditional in source.get("conditional_effects", []):
        conditional["response"] = GENERIC_CONDITIONAL_RESPONSE
        conditional["response_role"] = "assistant_surgeon"
    if source.get("conditional_effects"):
        option["conditional_effects"] = source["conditional_effects"]
    return option


def build_stages(procedure_id: str, source: str) -> list[dict]:
    serialization = parse_serialization(source)
    balance = parse_balance(source)[procedure_id]
    hooks = parse_hook_maps(source)[procedure_id]
    fixed_ids = [stage_id for stage_id in serialization if stage_id in balance and balance[stage_id]["entry_condition"] is None]
    # Preserve the authored serialization order rather than dictionary order.
    procedure_part = source.split("# PART III", 1)[1]
    procedure_block = procedure_part.split(f"## {procedure_id}\n", 1)[1]
    procedure_block = procedure_block.split("\n## ", 1)[0]
    ordered_ids = [match.group(1) for match in re.finditer(r"^### `([^`]+)`", procedure_block, re.M)]
    hook_index = 0
    stages = []
    progress = CATALOG[procedure_id]["fixed_progress"]
    fixed_index = 0
    for stage_id in ordered_ids:
        metadata = serialization[stage_id]
        balance_stage = balance[stage_id]
        is_correction = balance_stage["entry_condition"] is not None
        if is_correction:
            hook = next(row for row in hooks if row["stage_label"].lower() == "correction")
            stage_kind = "conditional_correction"
            progress_delta = 0
        else:
            hook = hooks[hook_index]
            hook_index += 1
            stage_kind = "fixed"
            progress_delta = progress[fixed_index]
            fixed_index += 1
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
    if fixed_index != len(progress) or hook_index != len([row for row in hooks if row["stage_label"].lower() != "correction"]):
        raise ValueError(f"Stage/progress/hook mismatch for {procedure_id}")
    return stages


def make_catalog_record(procedure_id: str, stages: list[dict]) -> dict:
    metadata = CATALOG[procedure_id]
    return {
        "id": procedure_id,
        "name": metadata["name"],
        "duration_minutes": metadata["duration_minutes"],
        "status": "ready",
        "required_roles": ROLES,
        "initial_state": {
            "stability": 100,
            "blood_loss": 0,
            "visibility": 90,
            "progress": 0,
            "elapsed_time": 0,
            "stress": 0,
            "bleeding": 0,
        },
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
        "fixed_stage_progress": metadata["fixed_progress"],
    }


def main() -> int:
    source_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_SOURCE
    source = source_path.read_text(encoding="utf-8")
    data = json.loads(TARGET.read_text(encoding="utf-8"))
    records = {row["id"]: row for row in data}
    for procedure_id in CATALOG:
        records[procedure_id] = make_catalog_record(procedure_id, build_stages(procedure_id, source))
    ordered = []
    seen = set()
    for row in data:
        if row["id"] == "surgery_vaginal_hysterectomy":
            ordered.append(records[row["id"]])
            seen.add(row["id"])
        elif row["id"] not in CATALOG:
            ordered.append(row)
            seen.add(row["id"])
    for procedure_id in CATALOG:
        if procedure_id not in seen:
            ordered.append(records[procedure_id])
    TARGET.write_text(json.dumps(ordered, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    for procedure_id in CATALOG:
        record = records[procedure_id]
        print(f"{procedure_id}: {len(record['stages'])} stages, {sum(record['fixed_stage_progress'])}% fixed progress")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
