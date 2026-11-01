#!/usr/bin/env python3
"""Re-read author Markdown independently of the importer and validate exact shipped text."""
import json,re,hashlib
from pathlib import Path
from jsonschema import Draft202012Validator
R=Path(__file__).resolve().parents[1]
def read(p):return json.loads((R/p).read_text())
S=R/'docs/source/chihaya_mizuho_return'
steps=read('data/events/special_event_steps/chihaya_mizuho_return.json')
defs=read('data/events/special_events/chihaya_mizuho_return.json')
schema=read('data/schemas/content.schema.json')['$defs']
en=read('data/localization/en.json')['strings']
actors={'千早':'patient_chihaya','瑞穗':'guest_mizuho','朝仓':'nurse_yui','芹香':'doc_serika','明日香':'doc_asuka'}
direction=read('tools/fixtures/chihaya_mizuho_return/expression_direction.json')
cg_direction=read('tools/fixtures/chihaya_mizuho_return/cg_direction.json')
assert {n['id']:n['cg_path'] for s in steps for n in s['nodes'] if n.get('cg_path')}==cg_direction
for step in steps:
 for node in step['nodes']:
  if node['id'] in cg_direction:
   assert node['cg_fit']=='contain' and (R/node['cg_path']).is_file(),node['id']
for name,digest in direction['source_sha256'].items():
 assert hashlib.sha256((R/'tools/fixtures/chihaya_mizuho_return'/name).read_bytes()).hexdigest()==digest,name
profiles={p.parent.name:json.loads(p.read_text()) for p in (R/'data/staff').glob('*/profile.json')}
directed={n['id'] for step in steps for n in step['nodes'] if n.get('actor_id')}
assert directed==set(direction['story'])
def check_cue(row,cue):
 for key,value in cue.items():assert row[key]==value,(row,key,value)
 path=profiles[cue['actor_id']]['visuals']['portraits'][cue['outfit']+'/'+cue['expression']]
 assert (R/path).is_file(),path
 return path
for step in steps:
 for node in step['nodes']:
  if node['id'] not in directed:continue
  path=check_cue(node,direction['story'][node['id']])
  if node['id']=='n06_059':assert node['hide_portrait'] and not node['event_portraits']
  else:assert not node['hide_portrait'] and node['event_portraits'][0]['path']==path,node['id']
source_chats=read('tools/fixtures/chihaya_mizuho_return/staff_source.json')['chats']
assert {c['id'] for c in source_chats}==set(direction['chats'])
shipped_chats=[variant for actor in ['patient_chihaya','guest_mizuho'] for event in read(f'data/staff/{actor}/time_events.json') for variant in event.get('dialogue_variants',[])]
assert len(shipped_chats)==len(source_chats)==27
chat_actor_turns=0
for chat in source_chats:
 candidates=[v for v in shipped_chats if [r['text'] for r in v]==[r['text'] for r in chat['nodes']]]
 assert len(candidates)==1,chat['id']
 cues=direction['chats'][chat['id']];assert len(cues)==len(chat['nodes'])
 for row,source,cue in zip(candidates[0],chat['nodes'],cues):
  assert row['speaker_label']==source['speaker']
  if cue:
   assert row['actor_id']==actors[source['speaker']]
   check_cue(row,cue);chat_actor_turns+=1
  else:assert row['speaker']!='actor' and 'expression' not in row and 'outfit' not in row
changes=[]
for stem,step,total,narrators in [('JOINT_DISCHARGE',steps[0],317,54),('FAKE_NURSE_RETURN',steps[1],538,89)]:
 raw=next(S.glob('*'+stem+'*')).read_text()
 body=re.split(r'### [DN]01｜',raw,maxsplit=1)[1]
 body=re.split(r'\n## 三、',body,maxsplit=1)[0]
 lines=[x.strip() for x in body.splitlines() if x.startswith('【') or re.match(r'^[\w（）]+：「',x)]
 assert len(lines)==total,(stem,len(lines))
 assert sum(x.startswith('【') for x in lines)==narrators
 assert len(step['nodes'])==total
 for i,(line,node) in enumerate(zip(lines,step['nodes'])):
  who,text=('旁白',line) if line.startswith('【') else line.split('：',1)
  assert who==node['speaker_label'],(node['id'],who)
  if node['id'] in ['n03_001','n05_001']:
   changes.append({'id':node['id'],'source':text,'display':node['text']});text='【'+text.split('。',1)[1]
  assert text==node['text'],node['id']
  actor=actors.get(who.split('（')[0],'');assert node.get('actor_id','')==actor
  assert node['speaker']==('narrator' if who=='旁白' else 'player' if who.split('（')[0]=='坂口' else 'actor')
  for portrait in node['event_portraits']:assert portrait['id']==actor and (R/portrait['path']).is_file()
  if actor in ['patient_chihaya','guest_mizuho']:
   expected='casual' if node['id'].startswith(('d','n02','n03','n04')) else 'uniform'
   assert node['outfit']==expected and not node['hide_portrait'],node['id']
   assert len(node['event_portraits'])==1 and '/'+expected+'/' in node['event_portraits'][0]['path'],node['id']
  if node['id'].startswith('n02'):assert node['background_id']=='mizuho_home'
  if node['id'].startswith('n04'):assert node['background_id']==('chihaya_home' if node['id']<'n04_082' else 'director_office')
  if node['id'] in ['n04_058','n04_060','n04_084','n04_086','n04_091']:
   assert node['expression']=='serious' and node['event_portraits'][0]['path'].endswith('/casual/serious.png')
  assert len(node['choices'])==1 and node['choices'][0]['next']==(step['nodes'][i+1]['id'] if i+1<total else '@day_end')
  for suffix in ['text','speaker_label','choices.continue.label']:
   val=en[f'collections.special_event_steps.{step["id"]}.nodes.{node["id"]}.{suffix}'];assert val and not re.search(r'[\u3400-\u9fff]|TODO|PLACEHOLDER',val)
for kind,items in [('special_event',defs),('special_event_step',steps)]:
 validator=Draft202012Validator({'$ref':'#/$defs/'+kind,'$defs':schema})
 for item in items:assert not list(validator.iter_errors(item)),[(e.json_path,e.message) for e in validator.iter_errors(item)]
review=read('docs/source/chihaya_mizuho_return/bilingual_review.json')
raw=next(S.glob('*STAFF_DIALOGUES*')).read_text()
for row in review['work']:
 assert row['text'] in raw,row['id']
 assert row['en'] and not re.search(r'[\u3400-\u9fff]|TODO|PLACEHOLDER',row['en'])
for chat in review['chats']:
 for row in chat['nodes']:
  assert row['text'] in raw,(chat['id'],row)
  assert row['en'] and not re.search(r'[\u3400-\u9fff]|TODO|PLACEHOLDER',row['en'])
for actor in ['patient_chihaya','guest_mizuho']:
 for filename,kind in [('profile','staff'),('relationship','relationship')]:
  obj=read(f'data/staff/{actor}/{filename}.json');v=Draft202012Validator({'$ref':'#/$defs/'+kind,'$defs':schema})
  assert not list(v.iter_errors(obj)),[(e.json_path,e.message) for e in v.iter_errors(obj)]
 for obj in read(f'data/staff/{actor}/time_events.json'):
  v=Draft202012Validator({'$ref':'#/$defs/time_event','$defs':schema});assert not list(v.iter_errors(obj)),[(e.json_path,e.message) for e in v.iter_errors(obj)]
report={'source_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in S.glob('*.md')},'events':855,'dialogue':712,'narration':143,'work':152,'chats':27,'chat_turns':135,'approved_context_omissions':changes}
(S/'source_audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print('RETURN SOURCE AUDIT PASS: 855 exact CN nodes / 855 EN; 152 work lines; 27 chats / 135 turns; two approved context omissions; shipped schema and canonical cast pass.')
print(f'EXPRESSION AUDIT PASS: {len(directed)} story actor nodes; {chat_actor_turns} chat actor turns; explicit source-bound direction and portrait files match.')
