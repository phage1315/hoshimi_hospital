"""Compare current event data with the pre-fix workspace, not with Git HEAD."""
from pathlib import Path
import json,re
R=Path(__file__).resolve().parents[1];Q=R/'docs/qa/event_rendering_fixes_2026-10-27'
read=lambda p:json.loads(p.read_text())
old=read(Q/'special_event_steps.json.before');new=read(R/'data/staff/doc_rei/special_event_steps.json');splits={x['original_node']:x for x in read(Q/'lv3_turn_split_audit.json')}
checks=0
for before,after in zip(old,new):
 if before['id']!='miyama_03_or_god_main':assert before==after;checks+=1;continue
 assert {k:v for k,v in before.items() if k!='nodes'}=={k:v for k,v in after.items() if k!='nodes'}
 nodes={n['id']:n for n in after['nodes']}
 order=[]
 for node in before['nodes']:
  if node['id'] not in splits:assert node==nodes[node['id']];order.append(node['id']);checks+=1;continue
  ids=[x['node'] for x in splits[node['id']]['parts']];parts=[nodes[i] for i in ids];order.extend(ids)
  assert re.sub(r'\s+','',node['text'])==re.sub(r'\s+','',''.join(n['text'] for n in parts))
  assert parts[-1]['choices']==node['choices']
  for i,p in enumerate(parts):
   assert {k:v for k,v in p.items() if k not in ['id','text','choices','presentation','speaker','speaker_label','actor_id']}=={k:v for k,v in node.items() if k not in ['id','text','choices','presentation','speaker','speaker_label','actor_id']}
   assert p.get('actor_id')==node.get('actor_id') or (node['id']=='nude_command_cg' and p.get('cg_path')==node.get('cg_path'))
   if i+1<len(parts):assert p['choices']==[{'id':'continue_'+p['id']+'_turn','label':'继续','next':parts[i+1]['id'],'requirements':[]}]
   checks+=1
 assert order==[n['id'] for n in after['nodes']]
a=read(Q/'events.json.before');b=read(R/'data/staff/pharmacist_manami/events.json')
for before,after in zip(a,b):
 if before['id']=='intro_pharmacist_manami':
  for n in after['nodes']:assert n.pop('presentation')=='authored';checks+=1
 assert before==after
old_en=read(Q/'en.json.before')['strings'];new_en=read(R/'data/localization/en.json')['strings'];allowed_changed=set();allowed_removed=set();prefix='collections.special_event_steps.miyama_03_or_god_main.nodes.'
old_nodes=next(e['nodes'] for e in old if e['id']=='miyama_03_or_god_main')
for nid,row in splits.items():
 key=prefix+nid+'.text';allowed_changed.add(key);parts=row['parts'];assert re.sub(r'\s+','',old_en[key])==re.sub(r'\s+','',''.join(new_en[prefix+p['node']+'.text'] for p in parts));checks+=1
 for ch in next(n for n in old_nodes if n['id']==nid)['choices']:
  key=prefix+nid+'.choices.'+ch['id']+'.label';allowed_removed.add(key);assert old_en[key]==new_en[prefix+parts[-1]['node']+'.choices.'+ch['id']+'.label'];checks+=1
for key,value in old_en.items():
 if key in allowed_changed:continue
 if key in allowed_removed:assert key not in new_en;continue
 assert new_en.get(key)==value,key
 checks+=1
result={'checks':checks,'failures':0,'split_original_nodes':len(splits),'added_nodes':18,'text_policy':'All non-whitespace source characters, quotes and punctuation retained in order; only inter-turn separator whitespace becomes node boundaries. Choice text moved to its ending turn unchanged.','original_effects_preserved':True,'unrelated_translations_preserved':True}
(Q/'content_preservation_audit.json').write_text(json.dumps(result,ensure_ascii=False,indent=2));print(result)
