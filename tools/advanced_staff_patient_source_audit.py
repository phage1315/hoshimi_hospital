"""Exact CN line/speaker/order + active EN and four-pose asset contract."""
from pathlib import Path
import hashlib, json, re, struct
root=Path(__file__).resolve().parents[1]
src=(root/'docs/source/advanced_staff_patient_v1/author_v1_1.md').read_text()
data=json.loads((root/'data/advanced_surgery/staff_patient/stories.json').read_text())
checks=0
def check(ok,label):
 global checks
 checks+=1
 assert ok,label
def parsed(text,staging=True):
 rows=[]
 for raw in text.splitlines():
  stage=re.search(r'【(.*?)】',raw)
  if staging and stage: rows.append(('narrator',stage[1]))
  spoken=re.search(r'(坂口|医护|小夜香|芹香)：「(.*)」',raw)
  if spoken: rows.append(('player' if spoken[1]=='坂口' else 'patient',spoken[2]))
 return rows
def pairs(rows):return [(r['speaker'],r['text']) for r in rows]
check(pairs(data['common'])==parsed(src.split('### 2.2 ')[1].split('### 2.3 ')[0],False),'Common source')
for actor,number in [('doc_sayaka','3.1'),('doc_serika','3.2')]:
 section=src.split('### '+number+' ')[1].split('\n### ')[0]
 actor_data=data['actors'][actor]
 check(actor_data['title']==re.search('《(.*?)》',section)[1],actor+' title')
 chunks=re.split(r'\*\*Day [13] [^\n]+\*\*',section)[1:]
 for phase,chunk in zip(['consult','night','after','success','failure'],chunks):
  rows=actor_data[phase]+actor_data['dark'] if phase=='night' else actor_data[phase]
  check(pairs(rows)==parsed(chunk),actor+':'+phase+' exact words, order, speakers')
 check(len([r for r in actor_data['dark'] if r['speaker']!='narrator'])==8,actor+' eight dark lines before transition')
repeat=src.split('### 5.6 ')[1].split('### 5.7 ')[0]
check(pairs(sum([data['repeat'][k] for k in ['consult','night','after','success','failure']],[]))==parsed(repeat),'Repeat exact source')
check(data['ending']['text'] in src,'Common ending')
allrows=data['common']+[data['ending']]
for group in [*data['actors'].values(),data['repeat']]:
 for k,v in group.items():
  if isinstance(v,list) and not k.endswith('staging'):allrows+=v
for row in allrows:
 en=row.get('text_en','').replace('〈本次术式〉','PROCEDURE')
 check(bool(en.strip()) and not re.search(r'[\u3400-\u9fff]|TODO|PLACEHOLDER',en),'English: '+row['text'][:30])
assets=json.loads((root/'data/advanced_surgery/staff_patient/assets.json').read_text())
for actor in data['actors']:
 check(set(assets[actor])=={'abdominal','chest','lateral','prone'},'Four required poses: '+actor)
 for pose,item in assets[actor].items():
  content=(root/item['path']).read_bytes()
  check(content[:8]==b'\x89PNG\r\n\x1a\n','PNG '+actor+pose)
  check(hashlib.sha256(content).hexdigest()==item['sha256'],'Unedited asset '+actor+pose)
  w,h=struct.unpack('>II',content[16:24]);check(w>=1500 and h>=900,'HD pose '+actor+pose)
print(f'ADVANCED STAFF SOURCE / ASSETS: {checks} checks; 0 failures; {len(allrows)} bilingual lines')
