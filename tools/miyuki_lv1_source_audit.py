"""Exact audit of Asakura's approved compact V2 script; --candidate before registration."""
import json,re,sys
from pathlib import Path
R=Path(__file__).resolve().parents[1];b=R/'research/character_references/asakura_miyuki_2026-10-23/lv1'
def read(p):return json.loads(p.read_text())
source=re.findall(r'^\*\*(A1-\d+)｜([^：]+)：\*\*\s*(.+)$',(b/'source_cn.md').read_text(),re.M)
rv=read(b/'bilingual_review.json');eid='miyuki_lv1_not_that_kind_of_inexperienced'
candidate='--candidate' in sys.argv
e=read(b/'event_candidate.json') if candidate else next(e for e in read(R/'data/staff/nurse_yui/events.json') if e['id']==eid)
assert len(source)==len(rv)==len(e['nodes'])==44
for i,((nid,who,text),row,n) in enumerate(zip(source,rv,e['nodes'])):
 assert nid==row['id']
 assert n['id']==(nid if candidate else nid.lower().replace('-','_'))
 assert text==row['zh_CN']==n['text'] and who==row['speaker_zh_CN']==n['speaker_label']
 assert n['speaker']==('narrator' if who=='旁白' else 'player' if who=='坂口隆司' else 'actor')
 if who=='年轻护士':assert n['hide_portrait'] and 'actor_id' not in n
 else:assert n['actor_id']=='nurse_yui'
 assert n['outfit']=='uniform' and n['choices'][0]['effects']=={'affection':0,'familiarity':0} and not n['choices'][0]['flags']
 assert n['choices'][0]['next']==(e['nodes'][i+1]['id'] if i<43 else '@end')
 assert row['en'].strip() and not re.search(r'[\u3400-\u9fff]',row['en'])
 if not candidate:
  for locale in ['en','zh_CN']:
   loc=read(R/('data/localization/'+locale+'.json'))['strings'];prefix='collections.character_events.'+eid+'.nodes.'+n['id']
   assert loc[prefix+'.text']==row['en' if locale=='en' else 'zh_CN']
   assert loc[prefix+'.speaker_label']==row['speaker_en' if locale=='en' else 'speaker_zh_CN']
assert e['nodes'][9]['expression']=='serious' and e['nodes'][32]['expression']=='smile' and e['nodes'][43]['expression']=='smile'
assert not e['conditions']['required_events'] and not e['conditions']['special_requirements']
print('PASS: 44 exact V2 nodes, speakers, punctuation, ordering, bilingual text, NPC ownership, white uniform and expression changes'+(' (candidate)' if candidate else ' (registered)'))
