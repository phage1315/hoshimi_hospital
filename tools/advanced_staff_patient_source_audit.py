from pathlib import Path
import json,re,hashlib,struct
from advanced_staff_patient_v23_source import source_actors
root=Path(__file__).resolve().parents[1]
data=json.loads((root/'data/advanced_surgery/staff_patient/stories.json').read_text())
checks=0
def check(ok,label):
 global checks
 checks+=1
 assert ok,label
def rows(s,english=False):
 out=[]
 for l in s.splitlines():
  l=l.strip()
  if (l.startswith('[') and l.endswith(']')) if english else (l.startswith('【') and l.endswith('】')):
   out.append(dict(speaker='narrator',text=l[1:-1]));continue
  m=re.match(r'(Sakaguchi|Sayaka|Serika|Staff Member): ["“](.*)["”]$',l) if english else re.match(r'(坂口|小夜香|芹香|医护)：[「](.*)」$',l)
  if m:out.append(dict(speaker='player' if m[1] in ['Sakaguchi','坂口'] else 'patient',text=m[2]))
 return out

check(data['version']=='2.3','Active V2.3')
check(data['ending']=={},'No old ending appended')
for language,filename in [(False,'author_cn.md'),(True,'author_en.md')]:
 src=(root/'docs/source/advanced_staff_patient_v2_3'/filename).read_text()
 def actual(items):return [(x['speaker'],x['text_en' if language else 'text']) for x in items]
 def expected(items):return [(x['speaker'],x['text'].replace('`<Current Procedure>`','〈本次术式〉')) for x in items]
 section=src.split('### Common Day 1 Consultation' if language else '### 共通 Day 1 会诊')[1].split('\n### ')[0]
 check(actual(data['common'])==expected([x for x in rows(section,language) if x['speaker']!='narrator']),'Common exact '+filename)
 section=src.split('**Short Night Version for Repeat Advanced Staff Surgeries' if language else '**重复高级 Staff 的夜间短版')[1].split('\n### ')[0]
 check(actual(data['repeat']['night']+data['repeat']['after'])==expected(rows(section,language)),'Repeat exact '+filename)
 for phase,zh,en in [('success','重复成功可用','Repeat Success Line'),('failure','重复未达目标可用','Repeat Target Not Met Line')]:
  pattern=en+r':\*\* "(.*?)"' if language else zh+r'：「(.*?)」'
  check(actual(data['repeat'][phase])==[('patient',re.search(pattern,section)[1])],phase+filename)
expected_actors=source_actors()
check(set(data['actors'])==set(expected_actors),'All 24 source actors preloaded')
for actor,expected_actor in expected_actors.items():
 check(data['actors'][actor]==expected_actor,'Exact bilingual source, speakers, phase order and title: '+actor)
allrows=data['common'][:]
for group in [*data['actors'].values(),data['repeat']]:
 for value in group.values():
  if isinstance(value,list):allrows+=value
for row in allrows:
 en=row.get('text_en','').replace('〈本次术式〉','PROCEDURE')
 check(bool(en.strip()) and not re.search(r'[\u3400-\u9fff]|TODO|PLACEHOLDER',en),'English missing/residual')
assets=json.loads((root/'data/advanced_surgery/staff_patient/assets.json').read_text())
# Preloaded stories do not grant eligibility; only registered patients must be ready.
profiles=json.loads((root/'data/staff_patient_profiles.json').read_text())
for actor in profiles:
 check(actor in data['actors'], 'Registered patient has advanced story: '+actor)
 check(actor in assets, 'Registered patient has pose manifest: '+actor)
 check(set(assets[actor])=={'abdominal','chest','lateral','prone'},'Four required poses: '+actor)
 for pose,item in assets[actor].items():
  content=(root/item['path']).read_bytes()
  check(content[:8]==b'\x89PNG\r\n\x1a\n','PNG '+actor+pose)
  check(hashlib.sha256(content).hexdigest()==item['sha256'],'Unedited asset '+actor+pose)
  w,h=struct.unpack('>II',content[16:24]);check(w>=1500 and h>=900,'HD pose '+actor+pose)
print(f'ADVANCED STAFF SOURCE / ASSETS: {checks} checks; 0 failures; {len(allrows)} bilingual lines')
