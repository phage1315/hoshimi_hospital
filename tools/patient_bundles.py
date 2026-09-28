"""Load patient-owned authoring bundles into the runtime collection shape."""
from copy import deepcopy
from pathlib import Path
import json


def read_json(path: Path):
    return json.loads(path.read_text())


def replace_tokens(value, tokens):
    if isinstance(value, dict):
        return {key: replace_tokens(child, tokens) for key, child in value.items()}
    if isinstance(value, list):
        return [replace_tokens(child, tokens) for child in value]
    if isinstance(value, str):
        for token, replacement in tokens.items():
            value = value.replace(token, replacement)
    return value


def apply_overrides(encounter, preop, bundle):
    encounter_data = bundle.get('encounter', {})
    encounter['title'] = encounter_data.get('title', encounter.get('title', ''))
    full_undress = encounter_data.get('full_undress', {})
    for stage in encounter.get('stages', []):
        if stage.get('id') != 'exam_undress_decision':
            continue
        stage['prompt'] = full_undress.get('prompt', stage.get('prompt', ''))
        responses = full_undress.get('responses', {})
        visual_pool_id = full_undress.get('visual_pool_id', '')
        for action in stage.get('actions', []):
            action_id = action.get('id', '')
            if action_id in responses:
                action['response'] = responses[action_id]
            if action_id in {'authoritative_full_undress', 'gentle_full_undress', 'threaten_full_undress'}:
                if visual_pool_id:
                    action['visual_pool_id'] = visual_pool_id
                else:
                    action.pop('visual_pool_id', None)
    preop_data = bundle.get('preop', {})
    preop['title'] = preop_data.get('title', preop.get('title', ''))
    preop['initial_anxiety'] = preop_data.get('initial_anxiety', preop.get('initial_anxiety', 0))
    preop['initial_interaction'] = deepcopy(preop_data.get('initial_interaction', preop.get('initial_interaction', {})))
    stage_prompts = preop_data.get('stage_prompts', {})
    incision_responses = preop_data.get('incision_responses', {})
    for stage in preop.get('stages', []):
        if stage.get('id') in stage_prompts:
            stage['prompt'] = stage_prompts[stage['id']]
        if stage.get('id') == 'incision_ready':
            for action in stage.get('actions', []):
                if action.get('id') in incision_responses:
                    action['response'] = incision_responses[action['id']]


def load_patient_bundles(data_root: Path, config: dict):
    index = read_json(data_root / config['index'])
    encounter_template = read_json(data_root / config['encounter_template'])
    preop_template = read_json(data_root / config['preop_template'])
    result = {
        'patients': [],
        'encounters': [],
        'preops': [],
        'examination_cg_pools': [],
        'ward_preparation_cg_pools': [],
    }
    bundles = []
    for relative_path in index:
        bundle = read_json(data_root / 'patients' / relative_path)
        bundles.append((relative_path, bundle))
        patient = deepcopy(bundle['patient'])
        patient_id = patient['id']
        short_id = patient_id.removeprefix('patient_')
        fallback = bundle.get('fallback', {})
        tokens = {
            '$PATIENT_ID': patient_id,
            '$PATIENT_NAME': patient['name'],
            '$VISIT_ID': 'visit_' + short_id,
            '$PREOP_ID': 'preop_' + short_id,
            '$FALLBACK_CASE_ID': fallback.get('case_id', patient.get('case_id', '')),
            '$FALLBACK_SURGERY_ID': fallback.get('surgery_id', ''),
        }
        encounter = replace_tokens(deepcopy(encounter_template), tokens)
        preop = replace_tokens(deepcopy(preop_template), tokens)
        apply_overrides(encounter, preop, bundle)
        result['patients'].append(patient)
        result['encounters'].append(encounter)
        result['preops'].append(preop)
        exclusive = bundle.get('exclusive_cg_pools', {})
        result['examination_cg_pools'].extend(deepcopy(exclusive.get('examination', [])))
        result['ward_preparation_cg_pools'].extend(deepcopy(exclusive.get('ward_preparation', [])))
    return result, bundles
