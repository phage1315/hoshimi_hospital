#!/usr/bin/env python3
"""Approved Lv2 fidelity, graph, reward and localization audit.

The source is an unchanged copy of the draft. User-approved exceptions:
179/193/209 are spoken by the original choices, not repeated as dialogue;
435 is shortened to the approved eyebrow narration. Ambient is excluded.
"""
import json
import re
from pathlib import Path
from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[1]
event = next(e for e in json.loads((ROOT / 'data/staff/doc_sayaka/events.json').read_text())
             if e['id'] == 'sayaka_lv2_working_hours')
old = json.loads((ROOT / 'tools/fixtures/sayaka_lv2_v1_event.json').read_text())
english = json.loads((ROOT / 'data/localization/en.json').read_text())['strings']
source = (ROOT / 'docs/source/sayaka_lv2_pacing_v2_draft.md').read_text().splitlines()
checks = 0

def check(ok, message):
    global checks
    checks += 1
    assert ok, message

def nid(number):
    return {161: 'white_coat', 463: 'ending'}.get(number, f'lv2_v2_{number}')

lines = {}
for number, line in enumerate(source, 1):
    match = re.match(r'^(旁白|南条小夜香|坂口隆司)：(.+)$', line)
    if match and number <= 463 and number not in [179, 193, 209]:
        speaker, text = match.groups()
        lines[number] = (speaker, '她笑着轻轻挑了一下眉。' if number == 435 else text)
nodes = {n['id']: n for n in event['nodes']}
check(set(nodes) == {nid(n) for n in lines}, 'No missing/invented main-event beats or Ambient')
check({k:v for k,v in event.items() if k not in ['start', 'nodes']} ==
      {k:v for k,v in old.items() if k not in ['start', 'nodes']}, 'Metadata/gates/CG/35 minutes unchanged')
old_choices = {c['id']:c for n in old['nodes'] for c in n['choices']}
for number, (speaker, text) in lines.items():
    node = nodes[nid(number)]
    check(node['text'] == text, f'Exact Chinese including punctuation: {number}')
    check(node['speaker'] == {'旁白':'narrator', '南条小夜香':'actor', '坂口隆司':'player'}[speaker], f'Speaker: {number}')
    check(node['presentation'] == 'authored', f'Explicit authored rendering: {number}')
    key = f"collections.character_events.{event['id']}.nodes.{node['id']}"
    check(bool(english.get(key+'.text')) and not re.search(r'[\u3400-\u9fff]', english[key+'.text']), f'English: {number}')
    for choice in node['choices']:
        check(bool(english.get(key+'.choices.'+choice['id']+'.label')), 'English choice label')
        if node['id'] == 'white_coat':
            check({k:v for k,v in choice.items() if k != 'next'} ==
                  {k:v for k,v in old_choices[choice['id']].items() if k != 'next'}, 'Original appearance choice')
        else:
            check(len(node['choices']) == 1 and choice['label'] == '继续  ▷', 'No fake story choices')
        if choice['id'] in old_choices:
            check(choice['effects'] == old_choices[choice['id']]['effects'] and
                  choice['flags'] == old_choices[choice['id']]['flags'], 'Original reward/flags')
        else:
            check(choice['effects'] == {'affection':0, 'familiarity':0} and not choice['flags'], 'No invented reward')

def ranges(a, b):
    return [nid(n) for n in lines if a <= n <= b]

for branch, bounds in [('lv2_coat', (181,187)), ('lv2_sexy',(195,203)), ('lv2_scrubs',(211,219))]:
    visited, history, flags = [], [], []
    totals = {'affection':0, 'familiarity':0}
    current = event['start']
    while current != '@end':
        check(current not in visited, 'No cycles')
        visited.append(current)
        node = nodes[current]
        choice = next((c for c in node['choices'] if c['id'] == branch), node['choices'][0])
        conditional = choice.get('next_if_choice', {})
        current = conditional['next'] if conditional.get('choice_id') in history else choice['next']
        history.append(choice['id'])
        flags += choice['flags']
        for key in totals: totals[key] += choice['effects'][key]
    expected = ranges(65,161) + ranges(*bounds) + ranges(232,416)
    expected += ranges(429,435) if branch == 'lv2_scrubs' else ranges(441,451)
    expected += ranges(457,463)
    check(visited == expected, 'Exact branch order: '+branch)
    check(totals == {'affection':5 if branch == 'lv2_sexy' else 4, 'familiarity':9}, 'Original total effects')
    check(history.count('lv2_complete') == 1, 'One completion')
    for choice_id in ['ask_staying','ask_faking','ask_return','ask_other_reason','statistics','walk_to_door']:
        check(history.count(choice_id) == 1, 'Once-only original progress reward: '+choice_id)
    check(sum(nodes[n]['text'].count('脸遮一半还看得出来？') for n in visited) == 1, 'No repeated mask exchange')
    check(all(flags.count(f) == 1 for f in old_choices['lv2_complete']['flags']), 'Original completion flags once')

schema = json.loads((ROOT / 'data/schemas/content.schema.json').read_text())
validator = Draft202012Validator({'$ref':'#/$defs/character_event_choice', '$defs':schema['$defs']})
sample = dict(nodes[nid(416)]['choices'][0])
check(validator.is_valid(sample), 'Conditional choice schema')
for bad in [None, {}, {'next':'ending'}, {'choice_id':'lv2_scrubs'}, {'choice_id':1,'next':'ending'}, {'choice_id':'lv2_scrubs','next':'ending','flag':True}]:
    check(not validator.is_valid(dict(sample, next_if_choice=bad)), 'Reject malformed conditional route')
print(f'SAYAKA LV2 SOURCE AUDIT: {checks} checks; 0 failures; {len(lines)} explicit beats; 3 routes')
