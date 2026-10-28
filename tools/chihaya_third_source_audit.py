#!/usr/bin/env python3
"""Source integrity, all localized fields, actor identity, schedule metadata."""
import hashlib,json,re
from pathlib import Path
from jsonschema import Draft202012Validator
from import_chihaya_third_surgery import rows, SOURCE, NOTE, ACTORS, INTRO
R=Path(__file__).resolve().parents[1]
def read(p):return json.loads((R/p).read_text())
src=rows();record=read('docs/source/chihaya_third_surgery/preflight.json')
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest()==record['sha256']
assert src==read('docs/source/chihaya_third_surgery/parsed_source.json')
assert len(src)==487
steps=read('data/events/special_event_steps/chihaya_third_surgery.json');defs=read('data/events/special_events/chihaya_third_surgery.json')
ss=read('data/localization/en.json')['strings'];en=read('tools/fixtures/chihaya_third_surgery_en.json');schema=read('data/schemas/content.schema.json')
for kind,items in [('special_event',defs),('special_event_step',steps)]:
 v=Draft202012Validator({'$ref':'#/$defs/'+kind,'$defs':schema['$defs']})
 for x in items:assert not list(v.iter_errors(x)),[(e.json_path,e.message) for e in v.iter_errors(x)]
actual=[n for step in steps for n in step['nodes']];expected=[r for r in src if r['id']!='a03_019'];assert len(actual)==len(expected)==486
masked=read('tools/fixtures/chihaya_third_serika_masked.json')
art=read('research/imports/serika_masked_scrubs_2026-10-27.json')
portraits=read('data/staff/doc_serika/profile.json')['visuals']['portraits']
approved_cgs=read('tools/fixtures/chihaya_third_surgery_cgs.json')
cg_record=read('research/imports/chihaya_third_surgery_cgs_2026-10-27.json')
assert len(approved_cgs)==45 and len(cg_record['images'])==5
for image in cg_record['images']:
 assert hashlib.sha256((R/image['target']).read_bytes()).hexdigest()==image['sha256']
 for sid in image['nodes']:assert approved_cgs[sid]=={'cg_path':image['target'],'cg_fit':'contain'}
assert set(approved_cgs)=={n['id'] for n in actual if n.get('cg_path')}
assert len(masked)==48 and len(art['images'])==4
assert set(masked.values())=={'masked_focused','masked_warm','masked_hesitant','masked_tense'}
assert art['node_expressions']==masked
for image in art['images']:
 assert hashlib.sha256((R/image['target']).read_bytes()).hexdigest()==image['sha256']
 assert portraits[image['portrait_key']]==image['target']
 assert image['width']==1024 and image['height']==1536 and image['png_color_type']==6
for n,r in zip(actual,expected):
 text=r['text'].replace(NOTE,'') if r['id']=='a03_033' else r['text']
 if r['id']=='a05_028':text=text.replace('**','')
 assert n['id']==r['id'] and n['text']==text
 base=r['speaker'].split('（')[0];actor=ACTORS.get(base,'')
 assert n['speaker_label']==('千早' if r['id']=='a03_018' else r['speaker'])
 assert n['speaker']==('narrator' if base=='旁白' else 'player' if base=='坂口' else 'actor')
 assert n.get('actor_id','')==actor
 assert len(n['event_portraits'])==(1 if actor else 0)
 for p in n['event_portraits']:assert p['id']==actor and (R/p['path']).is_file()
 if actor=='doc_serika':assert n['outfit']==('white_coat' if r['scene']=='a02' else 'scrubs')
 if n['id'] in masked:
  assert actor=='doc_serika' and n['expression']==masked[n['id']]
  assert n['event_portraits'][0]['path']==portraits['scrubs/'+masked[n['id']]]
 if actor=='nurse_haru':assert n['outfit']==('scrubs' if n['id']<'b02_035' else 'sterile')
 if actor=='nurse_iwasaki_rumi':assert n['outfit']=='scrubs' and n['unmet_variant']['required_event_id']==INTRO
 assert {k:n[k] for k in ['cg_path','cg_fit'] if k in n}==approved_cgs.get(n['id'],{})
 assert not n.get('requirements') and len(n['choices'])==1
 key=f"collections.special_event_steps.chihaya_third_surgery_{r['id'][0]}_main.nodes.{n['id']}"
 assert ss[key+'.text']==en[r['id']] and not re.search(r'[\u3400-\u9fff]',en[r['id']])
 assert ss[key+'.speaker_label'] and ss[key+'.choices.continue.label']=='Continue'
 for field in n.get('unmet_variant',{}):
  if field in ['text','speaker_label']:assert ss[key+'.unmet_variant.'+field] and not re.search(r'[\u3400-\u9fff]',ss[key+'.unmet_variant.'+field])
branch=next(n for n in actual if n['id']=='a03_018')
assert branch['unmet_variant']['text']==next(r['text'] for r in src if r['id']=='a03_019')
assert branch['actor_id']=='patient_chihaya'
for i,step in enumerate(steps):
 for j,n in enumerate(step['nodes']):assert n['choices'][0]['next']==(step['nodes'][j+1]['id'] if j+1<len(step['nodes']) else '@day_end')
 assert defs[i]['settled_minutes']==[120,360,60][i]
 assert defs[i]['auto_schedule']==(i==0)
 assert defs[i].get('relationship_rewards',[])==([] if i!=1 else [{'actor_id':'doc_serika','target_level':2,'benefit_id':'','award_event_familiarity':False,'allow_level_skip':False}])
slot=read('data/staff/doc_serika/relationship.json')['rank_slots'];assert slot[1]['event_id']==defs[1]['id'] and slot[1]['special_requirements'][0]['minimum']==60 and slot[1]['min_familiarity']==25 and slot[1]['cooldown_days']==3
assert not slot[2]['special_requirements'] and slot[2]['min_familiarity']==40 and slot[2]['cooldown_days']==3
assert len([n for n in actual if n['id'].startswith('c') and n.get('actor_id')=='doc_serika'])==0
assert next(n for n in actual if n['id']=='b05_084')['speaker']=='player'
print('CHIHAYA THIRD AUDIT: 487 exact source rows / 486 VN nodes; complete EN; one mutual exclusion; approved developer-note exclusion and bold rendering; canonical actors/outfits; schema clean; Lv2 60 / Lv3 no skill gate.')
