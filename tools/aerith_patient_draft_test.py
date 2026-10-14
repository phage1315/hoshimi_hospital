#!/usr/bin/env python3
"""Validate Aerith's registered v2 bundle (legacy command name retained)."""
import hashlib
import ast
import json
import re
from copy import deepcopy
from pathlib import Path
from unittest.mock import patch

from jsonschema import Draft202012Validator, RefResolver
import patient_bundles
from patient_bundle_localization_test import walk

ROOT = Path(__file__).resolve().parents[1]


def read(relative):
    return json.loads((ROOT / relative).read_text())


def parse_dialogue(text):
    lines = dict(re.findall(r'^\| `([^`]+)` \| (.+?) \|$', text, re.M))
    variants = {key: re.findall(r'^「.*」$', body, re.M)
                for key, body in re.findall(r'^### `([^`]+)`\n(.*?)(?=^### |\Z)', text, re.M | re.S)}
    return dict(reaction_lines=lines, reaction_variants=variants)


def main():
    record = read('research/imports/patient_aerith_2026-10-09.json')
    registration = read('research/imports/patient_aerith_registered_v2.json')
    bundle = read(registration['bundle_path'])
    source_bundle = ROOT / registration['source_bundle']
    assert hashlib.sha256(source_bundle.read_bytes()).hexdigest() == registration['source_sha256']
    assert (ROOT / registration['bundle_path']).read_bytes() == source_bundle.read_bytes(), 'Preserve v2 verbatim'
    assert bundle == read(registration['source_bundle'])
    patient = bundle['patient']
    source = ROOT / record['source_profile']
    assert hashlib.sha256(source.read_bytes()).hexdigest() == record['source_profile_sha256']
    text = source.read_text()
    generic = parse_dialogue(text.split('# 2. New Generic Profile')[1].split('# 3. Aerith-Specific Overrides')[0])
    individual = parse_dialogue(text.split('# 3. Aerith-Specific Overrides')[1].split('# 4. Personality Consistency Rules')[0])
    profiles = read('data/patients/dialogue_profiles.json')['profiles']
    profile = profiles['playful_defiant_detail']
    for field in generic:
        assert profile[field] == generic[field], field
        assert patient[field] == individual[field], field
    assert [len(generic['reaction_lines']), len(generic['reaction_variants']), len(individual['reaction_lines']), len(individual['reaction_variants'])] == [27, 13, 7, 4]
    assert not any(word in json.dumps(generic, ensure_ascii=False) for word in ['宝条', '神罗', '爱丽丝', 'Hojo', 'Shinra', 'Aerith'])
    merged = deepcopy(patient)
    patient_bundles.merge_dialogue_profile(merged, profiles, patient['id'])
    for field in generic:
        assert merged[field] == generic[field] | individual[field]
    en = read('data/localization/en.json')['strings']
    failures = []
    walk(profile, 'patient_dialogue_profiles.playful_defiant_detail', en, failures)
    walk(bundle, 'patient_bundles.patient_aerith', en, failures)
    assert not failures, failures
    assert len(registration['english_keys_added']) == 62
    for key in registration['english_keys_added']:
        assert en[key].strip() and not re.search(r'[\u3400-\u9fff]|\b(?:TODO|TBD)\b', en[key]), key
    for key in ['complaint', 'primary', 'secondary']:
        source_line = patient['outpatient_lines'][key]
        english_line = en['patient_bundles.patient_aerith.patient.outpatient_lines.' + key]
        assert source_line.count('{line}') == english_line.count('{line}') == 1
        assert not source_line.startswith('「')
    named_en = read('research/imports/patient_aerith_dialogue_en.json')['individual']
    for field, value in individual.items():
        assert set(named_en[field]) == set(value)
        assert not re.search(r'[\u3400-\u9fff]', json.dumps(named_en[field], ensure_ascii=False))
        if field == 'reaction_variants':
            assert all(len(named_en[field][key]) == len(value[key]) for key in value)
    audit = read('research/imports/patient_aerith_portrait_audit.json')
    ann = read('data/patients/patient_ann/patient.json')['patient']['visuals']['portraits']
    assert set(patient['visuals']['portraits']) == set(ann) == set(audit['assets'])
    for key, path in patient['visuals']['portraits'].items():
        assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == audit['assets'][key]['sha256'], key
    assert [len(bundle['exclusive_cg_pools'][k]) for k in ['examination', 'ward_preparation', 'surgery']] == [1, 4, 0]
    assert not bundle['diagnosis_reactions']
    assert bundle['fallback'] == record['bundle_draft']['fallback']
    for field in ['traits', 'fear_profile', 'case_id', 'personality', 'visuals']:
        assert patient[field] == record['bundle_draft']['patient'][field], field
    assert bundle['exclusive_cg_pools'] == record['bundle_draft']['exclusive_cg_pools']
    index = read('data/patients/index.json')
    assert index.count('patient_aerith/patient.json') == 1
    config = read('data/manifest.json')['patient_bundles']
    original_read = patient_bundles.read_json
    all_collections, _ = patient_bundles.load_patient_bundles(ROOT / 'data', config)
    collections = {
        'patients': [p for p in all_collections['patients'] if p['id'] == patient['id']],
        'encounters': [p for p in all_collections['encounters'] if p['id'] == 'visit_aerith'],
        'preops': [p for p in all_collections['preops'] if p['id'] == 'preop_aerith'],
    }
    assert all(len(rows) == 1 for rows in collections.values())
    for kind in ['examination', 'ward_preparation', 'surgery']:
        collection = kind + '_cg_pools'
        owned_ids = {p['id'] for p in bundle['exclusive_cg_pools'][kind]}
        collections[collection] = [p for p in all_collections[collection] if p['id'] in owned_ids]
        assert len({p['id'] for p in all_collections[collection]}) == len(all_collections[collection])
    assert collections['patients'][0]['reaction_lines'] == merged['reaction_lines']
    assert collections['encounters'][0]['id'] == 'visit_aerith'
    assert collections['preops'][0]['id'] == 'preop_aerith'
    assert collections['preops'][0]['patient_id'] == 'patient_aerith'
    cg_import = read(record['cg_import'])
    assert cg_import['asset_count'] == len(cg_import['assets']) == 5
    assert len({asset['sha256'] for asset in cg_import['assets']}) == 5
    for asset in cg_import['assets']:
        assert hashlib.sha256((ROOT / asset['destination']).read_bytes()).hexdigest() == asset['sha256']
        if Path(asset['source']).exists():
            assert Path(asset['source']).read_bytes() == (ROOT / asset['destination']).read_bytes()
    exclusive = bundle['exclusive_cg_pools']
    for kind, collection in [('examination', 'examination_cg_pools'), ('ward_preparation', 'ward_preparation_cg_pools')]:
        assert collections[collection] == exclusive[kind]
        failures = []
        walk(exclusive[kind], f'patient_bundles.patient_aerith.exclusive_cg_pools.{kind}', cg_import['localization_en'], failures)
        assert not failures, failures
    decision = next(s for s in collections['encounters'][0]['stages'] if s['id'] == 'exam_undress_decision')
    for action in decision['actions']:
        assert action['response'] == bundle['encounter']['full_undress']['responses'][action['id']]
        if action['id'] == 'abandon_full_undress':
            assert not action.get('visual_pool_id')
        elif action['id'] in ['authoritative_full_undress', 'gentle_full_undress', 'threaten_full_undress']:
            assert action['visual_pool_id'] == exclusive['examination'][0]['id']
    # Static mirror of app.gd ward_preparation_cg_pool_for; not a Godot runtime test.
    def resolve(action, patient_id, group):
        candidates = [p for p in exclusive['ward_preparation']
                      if action in p['action_ids'] and patient_id in p['patient_ids']
                      and (not p.get('procedure_groups') or group in p['procedure_groups'])]
        return max(candidates, key=lambda p: p['priority'] + 10000) if candidates else {}
    for pool in exclusive['ward_preparation']:
        assert pool['patient_ids'] == ['patient_aerith'] and pool['priority'] == 100
        assert pool['presentation'] == 'fullscreen'
        for action in pool['action_ids']:
            assert resolve(action, 'patient_aerith', 'general_abdominal')['id'] == pool['id']
            assert not resolve(action, 'patient_ann', 'general_abdominal')
    for action in ['ack_disinfection', 'incise_epidural', 'incise_local', 'incise_none', 'incise_general']:
        assert not resolve(action, 'patient_aerith', 'breast')
        assert not resolve(action, 'patient_aerith', 'cardiac')
        assert not resolve(action, 'patient_aerith', 'general_abdominal')
    assert resolve('request_scalpel', 'patient_aerith', 'general_abdominal')['id'] == 'incision_patient_aerith'
    assert resolve('request_scalpel', 'patient_aerith', 'female_pelvic')['id'] == 'incision_patient_aerith'
    assert not resolve('request_scalpel', 'patient_aerith', 'breast')
    assert not resolve('request_scalpel', 'patient_aerith', 'cardiac')
    validator_ast = ast.parse((ROOT / 'tools/validate_data.py').read_text())
    known_actions = next(ast.literal_eval(n.value) for n in validator_ast.body
                         if isinstance(n, ast.Assign) and any(isinstance(t, ast.Name) and t.id == 'known_preparation_cg_actions' for t in n.targets))
    assert all(set(p['action_ids']) <= known_actions for p in exclusive['ward_preparation'])
    template_actions = {a['id'] for s in read('data/patients/templates/preop.json')['stages'] for a in s.get('actions', [])}
    assert {'incise_epidural', 'incise_local', 'incise_none'} <= template_actions
    assert len(bundle['preop']['stage_prompts']) == 25
    assert all(stage.get('prompt', '').strip() for stage in collections['preops'][0]['stages'])
    for stage in collections['preops'][0]['stages']:
        if stage['id'] in bundle['preop']['stage_prompts']:
            assert stage['prompt'] == bundle['preop']['stage_prompts'][stage['id']]
    schema_path = ROOT / 'data/schemas/patient_bundle.schema.json'
    schema = read('data/schemas/patient_bundle.schema.json')
    content = read('data/schemas/content.schema.json')
    resolver = RefResolver(schema_path.as_uri(), schema, store={content['$id']: content, schema['$id']: schema})
    errors = list(Draft202012Validator(schema, resolver=resolver).iter_errors(bundle))
    assert not errors, [(e.json_path, e.message) for e in errors]

    # Mirror localization.gd's tree keys and content_loader.gd's localization order.
    # This exercises the Python loader, not the Godot runtime.
    def localize(value, key):
        if isinstance(value, dict):
            return {k: localize(v, key + '.' + k) for k, v in value.items()}
        if isinstance(value, list):
            return [localize(v, key + '.' + str(v.get('id', i) if isinstance(v, dict) else i))
                    for i, v in enumerate(value)]
        return en.get(key, value) if isinstance(value, str) else value

    def english_read(path):
        value = original_read(path)
        if path == ROOT / 'data' / config['dialogue_profiles']:
            value['profiles'] = {k: localize(v, 'patient_dialogue_profiles.' + k)
                                 for k, v in value['profiles'].items()}
        elif path == ROOT / 'data' / config['encounter_template']:
            value = localize(value, 'patient_templates.encounter')
        elif path == ROOT / 'data' / config['preop_template']:
            value = localize(value, 'patient_templates.preop')
        elif path.name == 'patient.json':
            value = localize(value, 'patient_bundles.' + value['patient']['id'])
        return value

    with patch.object(patient_bundles, 'read_json', side_effect=english_read):
        english, _ = patient_bundles.load_patient_bundles(ROOT / 'data', config)
    for collection, record_id in [('patients', 'patient_aerith'), ('encounters', 'visit_aerith'), ('preops', 'preop_aerith')]:
        localized = next(p for p in english[collection] if p['id'] == record_id)
        assert not re.search(r'[\u3400-\u9fff]', json.dumps(localized, ensure_ascii=False)), collection
    localized_patient = next(p for p in english['patients'] if p['id'] == 'patient_aerith')
    for field in ['reaction_lines', 'reaction_variants']:
        expected = localize(profile[field], 'patient_dialogue_profiles.playful_defiant_detail.' + field)
        expected.update(named_en[field])
        assert localized_patient[field] == expected
    for kind in ['examination', 'ward_preparation']:
        owned_ids = {p['id'] for p in bundle['exclusive_cg_pools'][kind]}
        localized_pools = [p for p in english[kind + '_cg_pools'] if p['id'] in owned_ids]
        assert localized_pools == localize(bundle['exclusive_cg_pools'][kind], 'patient_bundles.patient_aerith.exclusive_cg_pools.' + kind)
        assert not re.search(r'[\u3400-\u9fff]', json.dumps(localized_pools, ensure_ascii=False))
    print('AERITH REGISTERED V2: schema, verbatim source, single registration, 27/13 inheritance, 25 stage prompts, 21 portraits + 5 CGs, 62 English entries and bilingual Python loading passed.')
    print('Godot runtime/Texture2D/UI crop not tested; pool resolver checks are static.')


if __name__ == '__main__':
    main()
