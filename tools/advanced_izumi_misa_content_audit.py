#!/usr/bin/env python3
"""Audit the released Izumi/Misa content against the archived author package."""
import json, re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'docs/source/advanced_izumi_misa_v1'
DATA = ROOT / 'data/advanced_surgery'
def read(p): return json.loads(p.read_text())
source = read(SRC / 'procedures_additions.json')
actual = read(DATA / 'procedures.json')
assert len(actual) == len({p['id'] for p in actual})
procedures = {p['id']: p for p in actual}
manifest = {r['procedure_id']: r for r in read(DATA / 'release_manifest.json')}
fields = read(DATA / 'field_windows.json')
md = (SRC / 'HOSHIMI_ADVANCED_IZUMI_MISA_CODEX_READY_V1.md').read_text()
counts = {'narration': 0, 'speech': 0, 'operative': 0}
def bilingual(v):
    if isinstance(v, dict):
        for k, item in v.items():
            if k.endswith('_en'):
                assert isinstance(item, str) and item.strip() and not re.search('[\u4e00-\u9fff]', item), (k, item)
            bilingual(item)
    elif isinstance(v, list):
        for item in v: bilingual(item)
for i, p in enumerate(source):
    pid = p['id']; filename = pid + '.json'
    assert procedures[pid] == p, pid
    assert manifest[pid]['runtime_ready'], 'Author-supplied unique artwork completes release requirements'
    assert (DATA / 'dialogue' / filename).read_bytes() == (SRC / 'dialogue' / filename).read_bytes()
    dialogue = read(DATA / 'dialogue' / filename)
    counts['operative'] += sum(len(lines) for groups in dialogue['stages'].values() for lines in groups.values())
    original = read(SRC / 'stories' / filename)
    story = read(DATA / 'stories' / filename)
    for phase, section in [('day1', '2'), ('day3', '4')]:
        block = md.split(f'### {i+1}.{section} ')[1].split('### ')[0]
        rows = re.findall(r'^\d+\. ([^：]+)：(.*)$', block, re.M)
        assert len(rows) == len(story[phase]['lines'])
        assert {k:v for k,v in story[phase].items() if k!='lines'} == {k:v for k,v in original[phase].items() if k!='lines'}
        speech = []
        for (speaker, text), row in zip(rows, story[phase]['lines']):
            assert row['text'] == text
            assert row['speaker'] == {'旁白':'narrator', '坂口':'PLAYER'}.get(speaker, 'patient')
            counts['narration' if speaker == '旁白' else 'speech'] += 1
            if speaker != '旁白': speech.append(row)
        assert speech == original[phase]['lines'], 'Existing bilingual speech must remain exact'
    patient = story['patient'].copy(); patient['visuals'] = original['patient']['visuals']
    expected = original['patient'].copy()
    if i == 1:
        expected['diagnosis'] = expected['diagnosis'].removesuffix('完整角色来源待核。')
        expected['diagnosis_en'] = expected['diagnosis_en'].removesuffix(' Full character identity pending confirmation.')
    assert patient == expected
    for path in story['patient']['visuals']['portraits'].values(): assert (ROOT / path).is_file(), path
    field = fields[pid]
    assert field['path'].endswith(['complex_abdominal_reconstruction_field.png', 'descending_thoracic_aortic_field.png'][i])
    assert (ROOT / field['path']).read_bytes().startswith(b'\x89PNG\r\n\x1a\n')
    assert (field['after_stage'], field['before_stage']) == (p['steps'][0]['id'],p['steps'][-1]['id'])
    template = fields['surgery_open_whipple' if i == 0 else 'surgery_adv_sleeve_lobectomy']
    for key in ['incision_path','closure_path']:
        assert field[key] == template[key] and (ROOT / field[key]).is_file()
    for item in [story,p,dialogue]: bilingual(item)
profiles = read(DATA / 'replay_case_profiles.json')
assert profiles[source[1]['id']]['case_subtype'] == 'descending_thoracic_aneurysm_intercostal_reattachment'
assert profiles[source[0]['id']]['diagnosis'] == source[0]['patient_notice']
bilingual(profiles)
assert counts == {'narration':11,'speech':50,'operative':72}, counts
print('IZUMI/MISA SOURCE AUDIT PASS:', counts, '; both entries ready with unique field artwork')
