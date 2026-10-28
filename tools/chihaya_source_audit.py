#!/usr/bin/env python3
"""Check source paragraphs, speakers, order, English and actual art references."""
import json
import hashlib
from collections import Counter
from import_chihaya_second_surgery import ROOT, PREFIX, rows, read

source = rows()
revision = read('docs/source/chihaya_second_surgery/rumi_revision_record.json')
assert hashlib.sha256((ROOT/revision['source']).read_bytes()).hexdigest() == revision['source_sha256']
variants = read('tools/fixtures/chihaya_second_surgery_unmet_variants.json')
english = read('tools/fixtures/chihaya_second_surgery_en.json')
strings = read('data/localization/en.json')['strings']
approved_cgs = read('tools/fixtures/chihaya_second_surgery_cgs.json')
steps = read('data/events/special_event_steps/chihaya_second_surgery.json')
nodes = [n for s in steps for n in s['nodes']]
assert len(nodes) == len(source) == 703
for original, node in zip(source, nodes):
    assert (original['id'], original['speaker'], original['text']) == (node['id'], node['speaker_label'], node['text']), original['id']
    for portrait in node['event_portraits']:
        assert (ROOT / portrait['path']).is_file(), portrait
        assert 'ward/' not in portrait['path'] if node['id'].startswith(('b2_', 'b3_', 'b4_', 'b5_', 'b6_')) else True
    assert not node.get('requirements')
    assert node.get('unmet_variant', {}) == variants.get(node['id'], {})
    assert node.get('actor_id') != 'nurse_sonoda_itsumi'
    assert all(p['id'] != 'nurse_sonoda_itsumi' and 'sonoda_itsumi' not in p['path'] for p in node['event_portraits'])
    assert '爱实' not in node['text'] and '爱实' not in node['speaker_label']
    key = f"collections.special_event_steps.chihaya_second_surgery_{node['id'][0]}_main.nodes.{node['id']}"
    assert strings[key+'.text'] == english[node['id']]
    if node['speaker_label'] == '岩崎留美':
        assert node['actor_id'] == 'nurse_iwasaki_rumi'
        assert strings[key+'.speaker_label'] == 'Rumi Iwasaki'
        assert node['unmet_variant']['speaker_label'] == '手术室值班护士'
        assert strings[key+'.unmet_variant.speaker_label'] == 'OR Duty Nurse'
    if node['id'] in ['b4_045', 'b4_058']:
        assert '留美' not in node['unmet_variant']['text']
        assert 'Rumi' not in strings[key+'.unmet_variant.text']
    expected_cg = approved_cgs.get(node['id'], {})
    assert node.get('cg_path', '') == expected_cg.get('cg_path', ''), node['id']
    if expected_cg:
        assert node.get('cg_fit') == expected_cg['cg_fit']
        assert (ROOT / expected_cg['cg_path']).is_file()
for step in steps:
    for i, node in enumerate(step['nodes']):
        assert len(node['choices']) == 1
        assert node['choices'][0]['next'] == (step['nodes'][i+1]['id'] if i+1 < len(step['nodes']) else '@day_end')
for event, minutes in zip(read('data/events/special_events/chihaya_second_surgery.json'), [120,300,60]):
    assert event['settled_minutes'] == minutes and not event['consumes_full_day']
    assert not event.get('relationship_rewards') and not event.get('completion_effects')
    assert event['mandatory_auto_start']
assert len(variants) == 33 and sum(n['speaker_label'] == '岩崎留美' for n in nodes) == 31
assert sum(n['text'] != d['before']['text'] for d in revision['changes'] for n in nodes if n['id'] == d['id']) == 49
assert variants['b4_045']['text'] == '「准备得不错嘛。辛苦啦。」'
assert variants['b4_058']['text'] == '「……监护继续拜托你。」'
for change in revision['changes']:
    assert english[change['id']] == change['english']
cameos = {p['id']:p for p in read('data/patients/cameo_patients.json')}
assert cameos['patient_chihaya']['age'] == cameos['guest_mizuho']['age'] == 18
assert not (ROOT/'data/staff/guest_mizuho').exists()
print('CHIHAYA SOURCE AUDIT:', dict(Counter(r['id'][0] for r in source)), '703 exact paragraphs; speakers, order, assets, age and no-runner/no-reward contract PASS')
