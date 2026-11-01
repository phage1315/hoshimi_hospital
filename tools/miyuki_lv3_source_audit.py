"""Independent source/table + registered bilingual/staging audit."""
import json,re
from pathlib import Path
R=Path(__file__).resolve().parents[1]
def read(p):return json.loads((R/p).read_text())
src=next((R/'docs/source/miyuki_lv3').glob('HOSHIMI*.md')).read_text()
source=re.findall(r'^\*\*([AB]3-\d{3})｜([^：]+)：\*\*\s*(.+)$',src,re.M)
variants={m[0]:m[1:] for m in re.findall(r'^\| A3-(\d{3}) \| (.*?) \| (.*?) \|$',src,re.M)}
review={(r['event_id'],r['id']):r for r in read('docs/source/miyuki_lv3/bilingual_review.json')}
strings={l:read('data/localization/'+l+'.json')['strings'] for l in ['zh_CN','en']}
events=[e for e in read('data/staff/nurse_yui/events.json') if e['id'].startswith('miyuki_lv3_')]
assert len(events)==3
checks=0
for e in events:
 a='locker_room' in e['id'];kariya=e['id'].endswith('kariya');rows=source[:82] if a else source[82:]
 assert len(e['nodes'])==len(rows)
 for i,((nid,who,cn),n) in enumerate(zip(rows,e['nodes']),1):
  if a and nid[-3:] in variants:
   override=variants[nid[-3:]][0 if kariya else 1]
   if override!='沿用正文':cn=override
  if who=='年轻护士':who='狩谷惠' if kariya else '米田栞'
  assert n['id']==nid.lower().replace('-','_') and n['text']==cn and n['speaker_label']==who,(nid,who)
  assert len(n['choices'])==1 and n['choices'][0]['effects']=={'affection':0,'familiarity':0} and not n['choices'][0]['flags']
  assert n['choices'][0]['next']==(e['nodes'][i]['id'] if i<len(rows) else '@end')
  row=review[e['id'],n['id']]
  for locale in strings:
   prefix='collections.character_events.'+e['id']+'.nodes.'+n['id']
   assert strings[locale][prefix+'.text']==row[locale]
   assert strings[locale][prefix+'.speaker_label']==row['speaker_'+locale]
  assert not re.search(r'[\u3400-\u9fff]',row['en']) and row['en'].strip()
  portraits=n['event_portraits']
  for p in portraits:assert (R/p['path']).exists()
  if a:
   trainee='nurse_kariya_megumi' if kariya else 'nurse_yoneda_shiori'
   assert {p['id'] for p in portraits}=={'nurse_yui',trainee}
   assert n['actor_id']==(trainee if who in ['狩谷惠','米田栞'] else 'nurse_yui')
   if i in [12,19]:assert n['speaker_label']=='朝仓美幸'
   if 13<=i<68:assert 'uncapped' in portraits[0]['path']
   if 41<=i<68:assert 'uncapped' in portraits[1]['path']
   if 68<=i<76:assert 'capped' in portraits[0]['path'] and 'uncapped' not in portraits[0]['path']
   if i>=68:assert 'capped' in portraits[1]['path'] and 'uncapped' not in portraits[1]['path']
  else:
   assert bool(portraits)==(i>=34)
   if portraits:assert all('casual' in p['path'] and p['id']=='nurse_yui' for p in portraits)
  checks+=1
assert len(source)==328 and len(review)==410
print(f'PASS: {checks} nodes (82 Kariya + 82 Shiori + 246 date); verbatim source/table, speakers, order, EN coverage, costumes, telephone staging.')
