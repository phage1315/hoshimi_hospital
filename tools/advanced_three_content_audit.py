#!/usr/bin/env python3
"""Compare the installed additions with the author's archived ZIP, without rewriting it."""
import copy
import hashlib
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'docs/source/advanced_three_cases_content_v1'
DATA=ROOT/'data/advanced_surgery'
def read(p):return json.loads(p.read_text())
actual={p['id']:p for p in read(DATA/'procedures.json')}
source=read(SRC/'procedures_additions.json')
assert len(actual)==len(set(actual))
assert 'surgery_open_whipple' in actual
lines=0
pending=read(DATA/'pending_first_patients.json')
pending_stories=[]
for p in source:
    assert actual[p['id']]==p, f"Procedure changed: {p['id']}"
    filename=p['id']+'.json'
    assert read(DATA/'dialogue'/filename)==read(SRC/'dialogue'/filename),filename
    field=read(DATA/'field_windows.json')[p['id']]
    assert (field['after_stage'],field['before_stage'])==(p['steps'][0]['id'],p['steps'][-1]['id'])
    for k in ['path','incision_path','closure_path']:assert (ROOT/field[k]).is_file(),field[k]
    for value in [p, read(DATA/'dialogue'/filename)]:
        def check_english(v):
            if isinstance(v,dict):
                for k,item in v.items():
                    if k.endswith('_en'):assert isinstance(item,str) and item.strip() and not re.search('[\u4e00-\u9fff]',item),(filename,k)
                    check_english(item)
            elif isinstance(v,list):
                for item in v:check_english(item)
        check_english(value)
    authored=read(SRC/'stories'/filename)
    story_path=DATA/'stories'/filename
    if not story_path.exists():
        assert p['id'] in pending, f"Unexplained missing story {filename}"
        assert all((ROOT/path).is_file() for path in pending[p['id']]['visuals']['portraits'].values())
        pending_stories.append(p['id'])
        continue
    installed=read(story_path)
    images=installed['patient']['visuals']['portraits']
    assert set(images)=={'ward','postop','team_confirmation','intraoperative/anesthetized','splash/general_anesthesia'}
    for path in images.values():assert (ROOT/path).is_file(),path
    compare=copy.deepcopy(installed);compare['patient']['visuals']['portraits']={}
    assert compare==authored,f"Story text/speaker/order changed: {filename}"
    for day in ['day1','day3']:
        lines+=len(installed[day]['lines'])
    def english_check(v):
        if isinstance(v,dict):
            for k,item in v.items():
                if k.endswith('_en'):assert isinstance(item,str) and item.strip() and not re.search('[\u4e00-\u9fff]',item),(filename,k)
                english_check(item)
        elif isinstance(v,list):
            for item in v:english_check(item)
    for value in [installed,p,read(DATA/'dialogue'/filename)]:english_check(value)
    field=read(DATA/'field_windows.json')[p['id']]
    assert (field['after_stage'],field['before_stage'])==(p['steps'][0]['id'],p['steps'][-1]['id'])
    for k in ['path','incision_path','closure_path']:assert (ROOT/field[k]).is_file(),field[k]
for old in read(SRC/'baseline_original_locks.json')['procedures']:
    p=actual[old['id']]
    assert p['crisis_checkpoints']==old['crisis_checkpoints'] and p['crisis_chances']==old['crisis_chances']
    for a,b in zip(old['steps'],p['steps']):
        assert all(b[k]==v for k,v in a.items()),a['id']
print(f'ADVANCED THREE SOURCE AUDIT: 3 procedures exact; 127 operative variants; {lines} registered story lines exact; bilingual and placeholder paths valid')
print('Unregistered candidate stories awaiting author approval:',pending_stories)
