#!/usr/bin/env python3
import json,re,hashlib
from pathlib import Path
R=Path(__file__).resolve().parents[1]
src=R/'docs/source/miyuki_lv2/HOSHIMI_ASAKURA_MIYUKI_LV2_PREOP_HORROR_CN_CODEX_READY_V1.md'
rows=re.findall(r'^\*\*([AB]2-\d{3})｜([^：]+)：\*\*\s*(.+)$',src.read_text(),re.M)
steps=json.loads((R/'data/events/special_event_steps/miyuki_lv2.json').read_text());nodes=[n for st in steps for n in st['nodes']]
assert len(rows)==len(nodes)==273
actors={'朝倉美幸':'nurse_yui','南条小夜香':'doc_sayaka','中井美佳':'nurse_rin'}
loc=json.loads((R/'data/localization/en.json').read_text())['strings']
for (sid,speaker,text),n in zip(rows,nodes):
 assert n['id']==sid.lower().replace('-','_') and n['speaker_label']==speaker and n['text']==text,sid
 assert n.get('actor_id','')==actors.get(speaker,''),sid
 assert n['speaker']==('narrator' if speaker=='旁白' else 'player' if speaker=='坂口隆司' else 'actor'),sid
 assert not n.get('cg_path')
 for p in n['event_portraits']:assert (R/p['path']).is_file()
 if speaker=='二階堂頼子':assert len(n['event_portraits'])==1 and n['event_portraits'][0]['id']=='story_guest_yoriko'
for st,count in zip(steps,[197,76]):
 assert len(st['nodes'])==count
 for i,n in enumerate(st['nodes']):
  assert n['choices']==[dict(id='continue',label='继续',next=st['nodes'][i+1]['id'] if i+1<count else '@day_end',requirements=[])]
  key=f'collections.special_event_steps.{st["id"]}.nodes.{n["id"]}.'
  for suffix in ['text','speaker_label','choices.continue.label']:
   assert loc.get(key+suffix) and not re.search(r'[\u4e00-\u9fff]|TODO|PLACEHOLDER',loc[key+suffix]),key+suffix
assert nodes[-2]['text']=='哧拉——。' and nodes[-1]['text']=='「呜呃……」'
assert nodes[-1]['event_portraits'][0]['path'].endswith('or_held_breath.png')
assert next(n for n in nodes if n['id']=='b2_067')['event_portraits'][0]['path'].endswith('scrubs/focused.png')
for name in ['a','b']:
 st=steps[0 if name=='a' else 1];lines=(R/f'tools/fixtures/miyuki_lv2_en/{name}.txt').read_text().splitlines()
 assert lines==[loc[f'collections.special_event_steps.{st["id"]}.nodes.{n["id"]}.text'] for n in st['nodes']]
print('Miyuki Lv2 source audit PASS: 273 verbatim nodes, speakers/order/punctuation, both languages, portrait resources and finale.')
print('Source SHA256:',hashlib.sha256(src.read_bytes()).hexdigest())
