#!/usr/bin/env python3
"""Check source paragraphs, speakers, order, English and actual art references."""
import json
from collections import Counter
from import_chihaya_second_surgery import ROOT, PREFIX, rows, read

source = rows()
steps = read('data/events/special_event_steps/chihaya_second_surgery.json')
nodes = [n for s in steps for n in s['nodes']]
assert len(nodes) == len(source) == 703
for original, node in zip(source, nodes):
    assert (original['id'], original['speaker'], original['text']) == (node['id'], node['speaker_label'], node['text']), original['id']
    for portrait in node['event_portraits']:
        assert (ROOT / portrait['path']).is_file(), portrait
        assert 'ward/' not in portrait['path'] if node['id'].startswith(('b2_', 'b3_', 'b4_', 'b5_', 'b6_')) else True
    assert not node.get('cg_path') and not node.get('requirements')
for step in steps:
    for i, node in enumerate(step['nodes']):
        assert len(node['choices']) == 1
        assert node['choices'][0]['next'] == (step['nodes'][i+1]['id'] if i+1 < len(step['nodes']) else '@day_end')
for event, minutes in zip(read('data/events/special_events/chihaya_second_surgery.json'), [120,300,60]):
    assert event['settled_minutes'] == minutes and not event['consumes_full_day']
    assert not event.get('relationship_rewards') and not event.get('completion_effects')
    assert event['mandatory_auto_start']
assert not any('匿名' in n['speaker_label'] or '值班护士' in n['speaker_label'] for n in nodes)
cameos = {p['id']:p for p in read('data/patients/cameo_patients.json')}
assert cameos['patient_chihaya']['age'] == cameos['guest_mizuho']['age'] == 18
assert not (ROOT/'data/staff/guest_mizuho').exists()
print('CHIHAYA SOURCE AUDIT:', dict(Counter(r['id'][0] for r in source)), '703 exact paragraphs; speakers, order, assets, age and no-runner/no-reward contract PASS')
