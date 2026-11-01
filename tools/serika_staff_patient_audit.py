#!/usr/bin/env python3
"""Audit approved source -> staff overrides and bilingual callback, without imports."""
import hashlib
import json
import re
from pathlib import Path
from jsonschema import Draft202012Validator
ROOT = Path(__file__).resolve().parents[1]
def read(p): return json.loads((ROOT / p).read_text())
def check(ok, message):
    global checks
    checks += 1
    if not ok: failures.append(message)
checks = 0
failures = []
prefix = 'docs/sources/serika_staff_patient/'
cn = read(prefix + 'locked_cn.json')
en = read(prefix + 'approved_en.json')
profile = read('data/staff_patient_profiles.json')['doc_serika']
s = (ROOT / profile['dialogue_source']).read_text()
check(hashlib.sha256((ROOT/profile['dialogue_source']).read_bytes()).hexdigest() == profile['dialogue_source_sha256'], 'Source checksum')
lines, variants, invites = {}, {}, []
for line in s.splitlines():
    if not line.startswith('|'): continue
    cells = [c.strip().replace('**', '') for c in line.strip('|').split('|')]
    if len(cells) == 2 and cells[0].startswith('A1') and cells[1].startswith('「'): invites.append(cells)
    if len(cells) == 2 and re.fullmatch('`[a-z_]+`', cells[0]) and cells[1].startswith('「'): lines[cells[0].strip('`')] = cells[1]
    if len(cells) == 3 and re.fullmatch('`[a-z_]+`', cells[0]) and cells[1] in ['1','2']: variants.setdefault(cells[0].strip('`'), []).append(cells[2])
check(len(lines)==28 and len(variants)==13 and all(len(v)==2 for v in variants.values()) and len(invites)==8, 'Exact source counts')
check(lines==cn['reaction_lines'] and variants==cn['reaction_variants'] and invites==cn['invitations'], 'Extracted source unchanged')
source_cb = (ROOT/prefix/'HOSHIMI_MISONO_SERIKA_FIRST_STAFF_SURGERY_CALLBACK_CN_CODEX_READY_V1.md').read_text()
cb = [{'number':int(m[1]), 'speaker':m[2], 'text':m[3]} for m in re.finditer(r'\*\*【CB-SER-(\d{3})｜([^】]+)】\*\*\s*\n([^\n]+)',source_cb)]
check(cb==cn['callback'] and len(cb)==40, 'Callback locked records')
event = read('data/staff/doc_serika/staff_surgery_callback.json')[0]
schema=read('data/schemas/content.schema.json')
validator=Draft202012Validator({'$ref':'#/$defs/character_event', '$defs':schema['$defs']})
for error in validator.iter_errors(event): failures.append(str(error))
backgrounds=read('data/backgrounds.json')
check(any(b['id']==event['background_id'] for b in backgrounds), 'Registered background')
portraits=read('data/staff/doc_serika/profile.json')['visuals']['portraits']
for locale,data in [('zh_CN',cn),('en',en)]:
    d=profile['dialogue'][locale]
    check(d['reaction_lines']==data['reaction_lines'] and d['reaction_variants']==data['reaction_variants'],locale+' exact overrides')
    check(not d.get('interaction_overrides') and not d.get('stage_prompts'), 'No unapproved C1/C2/C3 material')
    opening = read(prefix + 'ward_visit_opening_2026-10-31.json')[locale]
    check(d.get('ward_visit_opening') == opening and len(opening) == 9, locale + ' exact approved ward entrance and speakers')
    check(len(d['invitation_lines'])==3 and len(d['invitation_by_procedure'])==32, 'Invitation coverage')
    tokens=re.compile(r'\{[a-z_]+\}')
    def leaves(v):
        if isinstance(v, str): yield v
        elif isinstance(v, dict):
            for x in v.values(): yield from leaves(x)
        elif isinstance(v, list):
            for x in v: yield from leaves(x)
    if locale=='en':
        for line in leaves(d): check(bool(line.strip()) and not re.search(r'[\u3400-\u9fff]',line), 'Nonblank English without Chinese residue')
    strings=read(f'data/localization/{locale}.json')['strings']
    for i,node in enumerate(event['nodes']):
        original=cb[i]
        check(node['id']==f'cb_{i+1:03}', 'Ordered source ID')
        expected_role='narrator' if original['text'].startswith('【舞台】') else 'player' if original['speaker']=='坂口' else 'actor'
        check(node['speaker']==expected_role, 'Speaker preserved '+node['id'])
        check(node['choices'][0]['next']==('@end' if i==39 else f'cb_{i+2:03}'), 'Single ordered route')
        check(node['choices'][0]['effects']=={'affection':0,'familiarity':0} and not node['choices'][0]['flags'], 'No new reward')
        if i==39:
            check(node['presentation']=='stage' and node['text']=='', '040 control-only')
            continue
        check(node['text']==original['text'].removeprefix('【舞台】'), 'Verbatim Chinese '+node['id'])
        key=f"collections.character_events.{event['id']}.nodes.{node['id']}.text"
        check(strings[key]==(node['text'] if locale=='zh_CN' else en['callback'][i]), 'Bilingual node '+node['id'])
        portrait=portraits.get(node['outfit']+'/'+node['expression'],'')
        check(bool(portrait) and (ROOT/portrait).is_file(), 'Existing actor portrait '+node['id'])
check(event['minutes']==15 and event['category']=='contextual', '15-minute non-rank callback')
check(profile['required_completed_rank']==5, 'Real Lv5 gate')
check(profile['portrait_aliases']=={'examination/shy':'ward_preparation/shy'}, 'Patient-only ward preparation alias')
check(portraits.get('ward_preparation/shy','').startswith('assets/characters/relationship_patient_v1/doc_serika/'), 'Own ward preparation asset, not borrowed')
print(f'SERIKA SOURCE AUDIT: {checks} checks; {len(failures)} failure(s)')
for failure in failures: print(failure)
raise SystemExit(bool(failures))
