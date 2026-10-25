#!/usr/bin/env python3
"""Exact authoring/provenance audit; never normalizes dialogue punctuation."""
import json, pathlib, hashlib, zipfile
R=pathlib.Path(__file__).resolve().parents[1]
ref=R/'research/character_references/takemi_tae_2026-10-23'
def read(p):return json.loads(p.read_text())
author=read(next(ref.glob('*DIALOGUE_AUTHORING*.json')))
expected={}
def walk(value,path=''):
    if isinstance(value,list) and value and isinstance(value[0],dict) and 'zh_CN' in value[0]:expected[path]=value
    elif isinstance(value,dict):
        for key,child in value.items():walk(child,(path+'.' if path else '')+key)
walk(author)
profile=read(R/'data/staff/doc_takemi/profile.json')
assert profile['authored_dialogue']==expected, 'Dialogue changed, reordered, omitted or added'
assert sum(map(len,expected.values()))==60
for lines in expected.values():
    for pair in lines:assert all(isinstance(pair[x],str) and pair[x].strip() for x in ['zh_CN','en'])
with zipfile.ZipFile(next(ref.glob('*.zip'))) as z:
    for n in z.namelist():
        if '/' not in n:assert (ref/n).read_bytes()==z.read(n)
for asset in read(R/'data/staff/doc_takemi/assets_manifest.json')['assets']:
    assert hashlib.sha256((R/asset['target']).read_bytes()).hexdigest()==asset['sha256']
relation=read(R/'data/staff/doc_takemi/relationship.json')
assert relation['met'] is False and relation['level']==0 and relation['familiarity']==0
assert all(not x['event_id'] and not x['benefit_id'] for x in relation['rank_slots'])
assert len(read(R/'data/staff/doc_takemi/events.json'))==6
asset_count = len(read(R/'data/staff/doc_takemi/assets_manifest.json')['assets'])
print(f'TAKEMI SOURCE AUDIT: 60 exact bilingual pairs; {asset_count} asset hashes; source ZIP unchanged; no early unlock')

import re
source=(ref/'HOSHIMI_TAKEMI_TAE_LV0_CODEX_HANDOFF_V2.md').read_text()
rows=[(m[1].lower().replace('-', '_'),m[2],m[3]) for m in re.finditer(r'^\*\*(T[1-6]-(?:A)?\d+)｜(.+?)：\*\*\s*(.+)$',source,re.M)]
events=read(R/'data/staff/doc_takemi/events.json')
nodes=[n for e in events for n in e['nodes']]
assert len(rows)==len(nodes)==170
for (id,speaker,text),node in zip(rows,nodes):
    assert node['id']==id and node['text']==text, id
    assert node['speaker_label']==speaker or speaker.startswith('陌生女医') and node['speaker_label']=='陌生女医', id
assert [e['minutes'] for e in events]==[5,10,10,20,10,20]
for event in events:
    for i,node in enumerate(event['nodes']):
        assert node['choices'][0]['next']==(event['nodes'][i+1]['id'] if i+1<len(event['nodes']) else '@end')
        if node.get('cg_path'):assert (R/node['cg_path']).is_file()
print('TAKEMI LV0 SOURCE AUDIT: all 170 lines, speakers, punctuation and order match; 6 approved durations')
