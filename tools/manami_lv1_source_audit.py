#!/usr/bin/env python3
"""Source fidelity, explicit image mapping, localization and stage boundaries."""
import hashlib
from import_manami_lv1 import ROOT, SOURCE, EVENT, ACTOR, CG, read, rows, internal, english_speaker

source = rows()
event = next(e for e in read(ROOT/f'data/staff/{ACTOR}/events.json') if e['id']==EVENT)
assert len(event['nodes']) == len(source) == 243
locales = {loc:read(ROOT/f'data/localization/{loc}.json')['strings'] for loc in ['zh_CN','en']}
english = read(ROOT/'tools/fixtures/manami_lv1_en.json')
by_id = {r['source_id']: n for r,n in zip(source,event['nodes'])}
for i,(r,n) in enumerate(zip(source,event['nodes'])):
    assert n['id']==internal(r['source_id']) and n['text']==r['text'], r['source_id']
    assert n['speaker_label']==r['speaker']
    assert n['speaker']==('narrator' if r['speaker']=='旁白' else 'player' if r['speaker'].startswith('坂口') else 'actor')
    assert n['choices']==[{'id':'continue_'+n['id'],'label':{'zh_CN':'继续  ▷','en':'Continue  ▷'},
        'next':event['nodes'][i+1]['id'] if i+1<len(source) else '@end',
        'effects':{'affection':0,'familiarity':0},'flags':[]}]
    prefix=f'collections.character_events.{EVENT}.nodes.{n["id"]}'
    if r['text']:
        assert locales['zh_CN'][prefix+'.text']==r['text']
        assert locales['en'][prefix+'.text']==('“'+english[r['source_id']]+'”' if r['source_id'].startswith('L') else english[r['source_id']])
    else:
        assert n['presentation']=='stage' and n['auto_seconds']>0 and prefix+'.text' not in locales['en']
    assert locales['en'][prefix+'.speaker_label']==english_speaker(r['speaker'])
    portraits=n['event_portraits']
    assert all((ROOT/p['path']).is_file() for p in portraits)
    assert len({p['id'] for p in portraits})==len(portraits)
    assert all(p['id'] not in ['player','protagonist'] for p in portraits)
    if n.get('cg_path'): assert not portraits and n['cg_fit']=='contain'

cg_runs=[]; previous=''
for n in event['nodes']:
    cg=n.get('cg_path','')
    if cg and cg!=previous: cg_runs.append(cg)
    previous=cg
assert cg_runs==list(CG.values())
for last,exit_node in [('L015','S1-A06'),('L043','S2-A15'),('L075','S4-A10'),('L095','S5-A10')]:
    assert by_id[last].get('cg_path') and not by_id[exit_node].get('cg_path')
assert not by_id['L071'].get('cg_path') and by_id['S4-A08']['cg_path']==CG[3]
assert not by_id['S4-A11'].get('cg_path') and not by_id['S5-A11'].get('cg_path')
for i in range(18,27): assert not by_id[f'L{i:03}']['event_portraits']
for r,n in zip(source,event['nodes']):
    if source.index(r)>=next(i for i,x in enumerate(source) if x['source_id']=='S5-A11'):
        assert all(p['id']!='launch' for p in n['event_portraits'])
assert any('gold_sneeze' in p['path'] for p in by_id['L080']['event_portraits'])
assert any('blue_confused' in p['path'] for p in by_id['S4-A17']['event_portraits'])
assert by_id['S4-A17']['stage_effect']=='flash'
assert by_id['S6-A17']['stage_effect']=='black' and by_id['S6-A17']['choices'][0]['next']=='@end'
assert event['minutes']==30 and event['target_level']==1 and event['benefit_id']==''
assert event['conditions']['required_events']==['intro_pharmacist_manami']
assert event['conditions']['min_familiarity']==10 and not event['conditions']['special_requirements']
assert not event['gallery']['show_on_complete']
original=__import__('pathlib').Path('/Users/ningye/Downloads/HOSHIMI_IIMURA_MANAMI_LV1_SNEEZE_CODEX_HANDOFF_V2.md')
if original.exists(): assert SOURCE.read_bytes()==original.read_bytes()
ids=['daf7dcac-e66a-4e35-ae5b-782a15e2d524','8c9743c8-13b5-41c4-a1ce-55143a10c0b1','a409ee3a-6e13-4758-bf66-0720a9665679','25f3125a-186c-4dc2-9ab4-67bbb0b9d8a2']
for i,uid in enumerate(ids,1):
    original=__import__('pathlib').Path(f'/var/folders/t6/9dg502qd74vdq35hjs973jf40000gn/T/codex-clipboard-{uid}.png')
    if original.exists(): assert hashlib.sha256(original.read_bytes()).digest()==hashlib.sha256((ROOT/CG[i]).read_bytes()).digest()
print('PASS: 243 source nodes, exact Chinese/speakers/order, English, four byte-identical CGs, state/expression boundaries, 30-minute Lv1 gate.')
