"""Exact source dialogue, authored staging, reward and bilingual contract audit."""
import json,re
from pathlib import Path
R=Path(__file__).resolve().parents[1]
S=R/'research/character_references/misono_serika_2026-10-24'
def read(p):return json.loads(p.read_text())
source=(S/'HOSHIMI_MISONO_SERIKA_RADIOLOGY_D01_D15_CODEX_READY_V1.md').read_text()
rows=re.findall(r'^\*\*(D\d\d-\d\d)｜([^：]+)：\*\* (.+)$',source,re.M)
events=read(R/'data/staff/doc_serika/radiology_events.json')
spoken=[n for e in events for n in e['nodes'] if n['speaker'] in ['actor','player']]
assert len(events)==15 and len(rows)==len(spoken)==221
for (sid,speaker,text),node in zip(rows,spoken):
 assert node['id']==sid.lower().replace('-','_')
 assert node['text']==text and node['speaker_label']==speaker
 assert node['speaker']==('player' if speaker=='坂口隆司' else 'actor')
 assert node['actor_id']=='doc_serika'
locales={lang:read(R/f'data/localization/{lang}.json')['strings'] for lang in ['en','zh_CN']}
review={x['node_id']:x for x in read(S/'radiology_bilingual_review.json')}
portraits=read(R/'data/staff/doc_serika/profile.json')['visuals']['portraits']
for e in events:
 assert e['trigger_mode']=='interaction' and not e['auto_start'] and e['minutes']==60
 assert e['conditions']['required_events']==['serika_lv0_a','serika_lv0_b','serika_lv0_c','serika_lv0_d']
 assert e['category']=='contextual' and e['background_id']=='diagnostics'
 assert e['start']==e['nodes'][0]['id']
 for j,n in enumerate(e['nodes']):
  assert n['outfit']=='white_coat' and n['actor_id']=='doc_serika'
  assert n['outfit']+'/'+n['expression'] in portraits
  assert (R/portraits[n['outfit']+'/'+n['expression']]).is_file()
  c=n['choices'];assert len(c)==1 and not c[0]['flags']
  assert c[0]['effects']=={'affection':0,'familiarity':3 if j+1==len(e['nodes']) else 0}
  assert c[0]['next']==(e['nodes'][j+1]['id'] if j+1<len(e['nodes']) else '@end')
  if n['presentation']=='stage':
   assert n['auto_seconds']==0.35 and not n['text']
   continue
  pre=f"collections.character_events.{e['id']}.nodes.{n['id']}"
  assert locales['zh_CN'][pre+'.text']==n['text']==review[n['id']]['zh_CN']
  assert locales['en'][pre+'.text']==review[n['id']]['en']
  assert not re.search(r'[\u4e00-\u9fff]',locales['en'][pre+'.text'])
  assert locales['en'][pre+'.speaker_label']=={'旁白':'Narrator','坂口隆司':'Ryuji Sakaguchi','御園芹香':'Serika Misono'}[n['speaker_label']]
  if n['id'].endswith('open_text'):
   sid=n['id'].upper().replace('_','-')
   authored=re.search(r'^\*\*'+sid+r'｜.+?：\*\* 旁白：(.+)$',source,re.M).group(1)
   assert n['text']==authored
 assert e['nodes'][-1]['id'].endswith('_close') and e['nodes'][-1]['expression']=='neutral'
# Future milestones remain unauthored; this delivery cannot unlock them.
relation=read(R/'data/staff/doc_serika/relationship.json')
assert not any(e['category'] in ['bond','rank_up'] for e in events)
assert not any(x['id']=='serika_imaging_discussion' for x in read(R/'data/staff/doc_serika/time_events.json'))
print('PASS: 221 exact dialogue lines/speakers/order; 15 exact opening fallbacks; 253 bilingual text nodes; 2 timed expression beats; existing assets; final-only +3/60-minute contract.')
