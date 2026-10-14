#!/usr/bin/env python3
"""Lv3 source fidelity and all six routes; choices replace approved spoken answers."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ID = 'sayaka_lv3_relationship'
event = next(e for e in json.loads((ROOT/'data/staff/doc_sayaka/events.json').read_text()) if e['id'] == ID)
old = json.loads((ROOT/'tools/fixtures/sayaka_lv3_v1_event.json').read_text())
en = json.loads((ROOT/'data/localization/en.json').read_text())['strings']
source = (ROOT/'docs/source/sayaka_lv3_pacing_v2_draft.md').read_text().splitlines()
lines = {}
for number, line in enumerate(source, 1):
    match = re.match(r'^(旁白|南条小夜香|坂口隆司|七瀬恋|杉村弘子|普通护士)：(.+)$', line)
    if match and number not in [294, 308]:
        lines[number] = match.groups()
checks = 0

def check(ok, message):
    global checks
    checks += 1
    assert ok, message

def nid(n):
    return {281:'scene_05', 389:'scene_12'}.get(n, f'lv3_v2_{n}')

def seq(a, b):
    return [nid(n) for n in lines if a <= n <= b]

nodes = {n['id']:n for n in event['nodes']}
expected_ids = {nid(n) for n in lines if n != 62} | {'scene_01_haru','scene_01_hiroko','scene_01_fallback','lv3_v2_94_haru'}
check(set(nodes) == expected_ids, 'No missing/invented nodes')
check({k:v for k,v in event.items() if k != 'nodes'} == {k:v for k,v in old.items() if k != 'nodes'}, 'All gates/time/metadata unchanged')
original = {c['id']:c for n in old['nodes'] for c in n['choices']}
for node_id, node in nodes.items():
    number = 62 if node_id.startswith('scene_01_') else 94 if node_id == 'lv3_v2_94_haru' else 281 if node_id == 'scene_05' else 389 if node_id == 'scene_12' else int(node_id.rsplit('_',1)[1])
    speaker, text = lines[number]
    check(node['text'] == text, f'Exact text/punctuation {node_id}')
    check(node['speaker'] == {'旁白':'narrator','坂口隆司':'player','普通护士':'narrator'}.get(speaker,'actor'), f'Speaker {node_id}')
    if speaker in ['七瀬恋','杉村弘子']:
        check(node['actor_id'] == ('nurse_haru' if speaker == '七瀬恋' else 'nurse_hiroko'), 'Named nurse identity')
        check(node['speaker_label'].replace(' ','') == speaker and node['outfit'] == 'uniform', 'Nurse label/outfit')
    elif speaker == '普通护士':
        check(node['speaker_label'] == speaker and node['hide_portrait'] and 'actor_id' not in node, 'Safe generic nurse; no invented actor')
    else:
        check('actor_id' not in node and 'speaker_label' not in node, 'No nurse leaking into Sayaka/player/narration')
        check(node['outfit'] == ('white_coat' if number < 193 else 'casual'), 'Work-to-casual transition')
    check(node['presentation'] == 'authored' and not node.get('allow_dialogue_scroll'), 'Explicit paginated VN turn')
    check(node['background_id'] == ('hallway' if number < 224 else 'italian_trattoria' if number < 267 else 'hospital_night'), 'Scene transition')
    check(bool(node.get('seasonal_street')) == (number >= 267), 'Night street only after restaurant')
    prefix = f'collections.character_events.{ID}.nodes.{node_id}'
    check(bool(en.get(prefix+'.text')) and not re.search(r'[\u3400-\u9fff]', en[prefix+'.text']), 'English text')
    if 'speaker_label' in node:
        check(bool(en.get(prefix+'.speaker_label')), 'English nurse name')
    for choice in node['choices']:
        check(choice['effects'] == {'affection':0,'familiarity':0}, 'No numeric rewards')
        check(choice['flags'] == (original['finish_lv3']['flags'] if choice['id'] == 'finish_lv3' else []), 'Only final flags')
        check(bool(en.get(prefix+'.choices.'+choice['id']+'.label')), 'English choice')
        if node_id == 'scene_05':
            check({k:v for k,v in choice.items() if k != 'next'} == {k:v for k,v in original[choice['id']].items() if k != 'next'}, 'Exact approved original answer')
        else:
            check(len(node['choices']) == 1 and choice['label'] == '继续  ▷', 'Ordinary continuation, not extra decision')

for nurse, handover, start, end in [('haru',68,100,106),('hiroko',72,110,116),('fallback',76,120,126)]:
    for answer, a, b in [('answer_a',296,302),('answer_b',310,316)]:
        node_id = 'scene_01_'+nurse
        visited, history = [], []
        while node_id != '@end':
            check(node_id not in visited, 'No cycle')
            visited.append(node_id)
            node = nodes[node_id]
            choice = next((c for c in node['choices'] if c['id'] == answer), node['choices'][0])
            branch = choice.get('next_if_choice', {})
            node_id = branch['next'] if branch.get('choice_id') in history else choice['next']
            history.append(choice['id'])
        expected = ['scene_01_'+nurse, nid(handover)] + seq(82,92) + ['lv3_v2_94_haru' if nurse == 'haru' else nid(94)]
        expected += seq(start,end) + seq(138,162) + (seq(166,176) if nurse == 'haru' else [])
        expected += seq(193,281) + seq(a,b) + seq(322,389)
        check(visited == expected, f'Exact branch order: {nurse}/{answer}')
        check(history.count('finish_lv3') == 1 and visited.count(nid(347)) == 1, 'One kiss/completion')
        check(visited.count(nid(138)) == 1, 'Shared core only once')
        print(f'LV3 SOURCE ROUTE {nurse}/{answer}: {len(visited)} turns')
for field in ['title','teaser','gallery.caption']:
    check(bool(en.get(f'collections.character_events.{ID}.{field}')), 'English metadata '+field)
print(f'SAYAKA LV3 SOURCE AUDIT: {checks} checks; 0 failures; {len(lines)} source beats; {len(nodes)} nodes; 6 routes')
