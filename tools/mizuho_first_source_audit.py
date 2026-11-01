#!/usr/bin/env python3
"""Independent verbatim, cast, resources, schema and bilingual coverage audit."""
import hashlib,json,re
from pathlib import Path
from jsonschema import Draft202012Validator
R=Path(__file__).resolve().parents[1]
def read(p):return json.loads((R/p).read_text())
src=read('docs/source/mizuho_first_surgery/parsed_source.json')
record=read('docs/source/mizuho_first_surgery/preflight.json')
raw=R/'docs/source/mizuho_first_surgery/HOSHIMI_MIZUHO_FIRST_SURGERY_CODEX_READY_CN_V1.md'
assert hashlib.sha256(raw.read_bytes()).hexdigest()==record['sha256']
body=raw.read_text().split('## 二、完整中文 VN 剧情正文',1)[1].split('## 三、',1)[0]
lines=[x.strip() for x in body.splitlines() if x.startswith('【') or '：「' in x]
assert len(lines)==len(src)==1047
assert sum(r['speaker']=='旁白' for r in src)==162
assert lines==[r['text'] if r['speaker']=='旁白' else r['speaker']+'：'+r['text'] for r in src]
defs=read('data/events/special_events/mizuho_first_surgery.json');steps=read('data/events/special_event_steps/mizuho_first_surgery.json')
nodes=[n for s in steps for n in s['nodes']];assert len(nodes)==1047
actors={'瑞穗':'guest_mizuho','千早':'patient_chihaya','芹香':'doc_serika','阿库娅':'doc_aqua','弘子':'nurse_hiroko','米田':'nurse_yoneda_shiori','朝仓':'nurse_yui','留美':'nurse_iwasaki_rumi'}
en=read('data/localization/en.json')['strings'];schema=read('data/schemas/content.schema.json')['$defs'];changes=[]
approved_cgs={}
approved_fits={}
for manifest in sorted((R/'research/imports').glob('mizuho_first_surgery_cg*_approved_*.json')):
 cg=json.loads(manifest.read_text())
 assert hashlib.sha256((R/cg['destination']).read_bytes()).hexdigest()==cg['sha256']
 for node_id in cg['nodes']:
  assert node_id not in approved_cgs
  approved_cgs[node_id]=cg['destination']
  approved_fits[node_id]=cg.get('cg_fit','contain')
staging=read('tools/fixtures/mizuho_first_surgery_staging.json')
for kind,items in [('special_event',defs),('special_event_step',steps)]:
 v=Draft202012Validator({'$ref':'#/$defs/'+kind,'$defs':schema})
 for item in items:assert not list(v.iter_errors(item)),[(e.json_path,e.message) for e in v.iter_errors(item)]
for n,r in zip(nodes,src):
 assert n['id']==r['id'] and n['speaker_label']==r['speaker']
 if n['text']!=r['text']:changes.append((r['id'],r['text'],n['text']))
 who=r['speaker'].split('（')[0];actor=actors.get(who,'')
 assert n['speaker']==('narrator' if who=='旁白' else 'player' if who=='坂口' else 'actor')
 assert n.get('actor_id','')==actor and len(n['event_portraits'])==bool(actor)
 for p in n['event_portraits']:assert p['id']==actor and (R/p['path']).is_file()
 assert not n.get('effects') and len(n['choices'])==1
 if n['id'] in approved_cgs:
  assert n.get('cg_path')==approved_cgs[n['id']] and n.get('cg_fit')==approved_fits[n['id']]
  assert staging[n['id']]['cg_path']==approved_cgs[n['id']]
 else:assert not n.get('cg_path'),n['id']
 key=f"collections.special_event_steps.mizuho_first_surgery_{n['id'][0]}_main.nodes.{n['id']}"
 for suffix in ['text','speaker_label','choices.continue.label']:
  assert en.get(key+'.'+suffix) and not re.search(r'[\u3400-\u9fff]',en[key+'.'+suffix])
 scene=r['scene']
 if actor=='patient_chihaya' and scene.startswith('b') and scene!='b01':assert n['outfit']=='scrubs' and '/chihaya_scrubs_v1/' in n['event_portraits'][0]['path']
 if actor=='nurse_iwasaki_rumi':assert n['outfit']==('uniform' if scene=='b01' else 'scrubs') and scene in ['b01','b05']
 if actor=='nurse_yoneda_shiori' and scene.startswith('b'):assert n['outfit']=='scrubs'
 if actor=='doc_serika':assert n['outfit']==('white_coat' if scene[0] in 'ac' else 'scrubs' if scene=='b03' else 'sterile')
 if actor=='nurse_hiroko' and scene.startswith('b'):assert n['outfit']==('scrubs' if scene in ['b02','b03'] else 'sterile')
 if actor=='doc_aqua' and scene.startswith('b'):assert n['outfit']=='sterile'
 if n['id']>='c02_011':assert actor in ['','guest_mizuho','patient_chihaya']
assert changes==[('a02_012',record['approved_revisions'][0]['source'],record['approved_revisions'][0]['replacement'])]
for step,d in zip(steps,defs):
 assert d['consumes_full_day']==False and not d.get('completion_effects') and not d.get('relationship_rewards')
 for i,n in enumerate(step['nodes']):assert n['choices'][0]['next']==(step['nodes'][i+1]['id'] if i+1<len(step['nodes']) else '@day_end')
 assert ('mizuho_first_surgery_chain_complete' in d['completion_flags'])==(d['id'].endswith('_c'))
 for suffix in ['title','gallery_entry.title','gallery_entry.chapters.0']:assert en.get('collections.special_events.'+d['id']+'.'+suffix)
art=read('research/imports/chihaya_scrubs_2026-10-28.json')
for asset in art['images']:assert hashlib.sha256((R/asset['path']).read_bytes()).hexdigest()==asset['sha256'] and asset['mode']=='RGBA' and asset['alpha_extrema'][0]==0
print('MIZUHO SOURCE AUDIT: 885 dialogue + 162 narration; one approved date correction; exact speakers/order; 1047 EN texts; all outfit/identity/path/schema checks passed.')
