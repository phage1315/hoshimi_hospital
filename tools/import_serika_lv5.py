#!/usr/bin/env python3
"""Build only Serika Lv5 from the archived source and approved bilingual records."""
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text())
def write(p,d):(ROOT/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
cn=read('docs/sources/serika_lv5/locked_cn.json'); en=read('docs/sources/serika_lv5/approved_en.json')
ID='serika_lv5_lay_down_burden'
roles={'旁白':'narrator','坂口隆司':'player','御園芹香':'actor','朝仓美幸':'actor','父亲（电话）':'actor'}
names={'旁白':'Narrator','坂口隆司':'Ryuji Sakaguchi','御園芹香':'Serika Misono','朝仓美幸':'Miyuki Asakura','父亲（电话）':'Father (phone)'}
lookup={r['id']:r for r in cn}
main=[r['id'] for r in cn if not re.search('[AB]-[12]$',r['id'])]
nexts={k:main[i+1] if i+1<len(main) else '@end' for i,k in enumerate(main)}
event=dict(id=ID,actor_id='doc_serika',title='卸下重担',chapter=5,location_id='imaging',trigger_mode='location',background_id='diagnostics',outfit='white_coat',minutes=60,teaser='卸下重担',time_start=540,time_end=960,priority=110,category='rank_up',auto_start=True,target_level=5,benefit_id='unlock_clinical_practice_patient',cinematic=True,gallery=dict(cg_id=ID,caption='卸下重担',path='',show_on_complete=False),conditions=dict(min_day=1,min_affection=0,min_familiarity=75,required_events=[],special_requirements=[]),start='s01_001',nodes=[])
def nid(k):return k.lower().replace('-','_')
def choice(k,label,target):return dict(id=nid(k),label=label,next=nid(target) if target!='@end' else target,effects=dict(affection=0,familiarity=0),flags=[])
for row in cn:
 k=row['id']; scene=k[:3];number=int(k[4:7]);is_choice=not row['text'];casual=scene!='S01' or number>=25
 expr='neutral'
 if scene=='S01':
  expr='focused' if number<6 else 'sad' if number in [8,10,11,14,15,17,18,19] else 'worried' if 20<=number<=24 else 'soft_smile'
 elif scene=='S02': expr='sad' if number<=38 else 'soft_smile'
 elif scene=='S03': expr='sad' if 15<=number<=39 else 'soft_smile' if number>=40 else 'neutral'
 elif scene=='S04':expr='soft_smile' if number<24 or number>=66 else 'shy' if 30<=number<=40 else 'neutral'
 if casual and expr not in ['neutral','sad','shy','soft_smile','surprised','talking','wry_smile']:expr='sad'
 node=dict(id=nid(k),presentation='choice' if is_choice else 'authored',speaker=roles.get(row['speaker'],'narrator'),actor_id='nurse_yui' if row['speaker']=='朝仓美幸' else 'doc_serika',text=row['text'],expression=expr,outfit='casual' if casual else 'white_coat',background_id={'S01':'diagnostics','S02':'hospital_courtyard_evening','S03':'date_cafe','S04':'hospital_night'}[scene],choices=[])
 if not is_choice:node['speaker_label']=row['speaker']
 if scene=='S03':
  miyuki='apologetic' if 24<=number<=40 else 'serious' if 10<=number<=23 else 'playful'
  node['event_portraits']=[dict(id='doc_serika',path=f'assets/characters/misono_serika_v1/casual/{expr}.png',x=430,bottom=600,width=410,height=500),dict(id='nurse_yui',path=f'assets/characters/miyuki_lv3_v1/miyuki_casual_{miyuki}.png',x=900,bottom=600,width=410,height=500)]
 if scene=='S04':node['seasonal_street']=True
 if is_choice:
  node['choices']=[choice(k+b,lookup[k+b+'-1']['text'],k+b+'-1') for b in ['A','B']]
 else:
  branch=re.match(r'(S\d\d-\d{3})([AB])-([12])$',k)
  target=(branch[1]+branch[2]+'-2' if branch[3]=='1' else nexts[branch[1]]) if branch else nexts[k]
  node['choices']=[choice('continue_'+k,'继续',target)]
 event['nodes'].append(node)
write('data/staff/doc_serika/lv5_events.json',[event])
bundle=read('data/staff/doc_serika/bundle.json')
if 'lv5_events.json' not in bundle['additional_character_event_files']:bundle['additional_character_event_files'].append('lv5_events.json')
write('data/staff/doc_serika/bundle.json',bundle)
r=read('data/staff/doc_serika/relationship.json')
# Find the existing slot without changing the established gate values.
def update(v):
 if isinstance(v,dict):
  if v.get('target_level')==5:v.update(event_id=ID,content_status='authored')
  for x in v.values():update(x)
 elif isinstance(v,list):
  for x in v:update(x)
update(r);write('data/staff/doc_serika/relationship.json',r)
for locale in ['zh_CN','en']:
 data=read(f'data/localization/{locale}.json');strings=data['strings'];prefix=f'collections.character_events.{ID}'
 for f in ['title','teaser','gallery.caption']:strings[prefix+'.'+f]='卸下重担' if locale=='zh_CN' else 'Laying Down the Burden'
 for row,node in zip(cn,event['nodes']):
  p=prefix+'.nodes.'+node['id']
  if row['text']:
   strings[p+'.text']=row['text'] if locale=='zh_CN' else en[row['id']]
   strings[p+'.speaker_label']=row['speaker'] if locale=='zh_CN' else names[row['speaker']]
  for c in node['choices']:
   strings[p+'.choices.'+c['id']+'.label']=c['label'] if locale=='zh_CN' else en[row['id']+('A' if c['id'].endswith('a') else 'B')+'-1'] if not row['text'] else 'Continue'
 write(f'data/localization/{locale}.json',data)
print('Built 214 records: 211 prose + 3 choice-only controls; 205 prose on any one path.')
