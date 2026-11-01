#!/usr/bin/env python3
"""Rebuild only the approved Miyuki Lv2 story and its localization."""
import json,re
from pathlib import Path
R=Path(__file__).resolve().parents[1]
SOURCE='docs/source/miyuki_lv2/HOSHIMI_ASAKURA_MIYUKI_LV2_PREOP_HORROR_CN_CODEX_READY_V1.md'
A='miyuki_lv2_preop_evening';B='miyuki_lv2_preop_morning'
ACTORS={'朝倉美幸':'nurse_yui','南条小夜香':'doc_sayaka','中井美佳':'nurse_rin'}
NAMES={'旁白':'Narrator','坂口隆司':'Ryuji Sakaguchi','朝倉美幸':'Miyuki Asakura','二階堂頼子':'Yoriko Nikaido','南条小夜香':'Sayaka Nanjo','中井美佳':'Mika Nakai','值班护士':'Duty nurse'}
def read(p):return json.loads((R/p).read_text())
def write(p,x):(R/p).write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n')
def portrait(actor,outfit,expression):
 return dict(id=actor,path=read(f'data/staff/{actor}/profile.json')['visuals']['portraits'][f'{outfit}/{expression}'],x=880,width=400,height=410,bottom=550)
def staging(part,i,speaker):
 actor=ACTORS.get(speaker,'');exp='neutral';outfit='uniform';visuals=[]
 if actor=='nurse_yui':
  outfit='uniform' if part=='a' else 'scrubs'
  exp='smile' if part=='a' else 'warm'
  if part=='a' and i in [4,14,93,154,164]:exp='neutral'
  if part=='a' and i in [23,37,48,83,85,117,123,143]:exp='serious'
  if part=='b' and i>=67:exp='focused'
 elif actor=='doc_sayaka':outfit='scrubs';exp='focused'
 elif actor=='nurse_rin':outfit='sterile';exp='focused'
 if actor:visuals=[portrait(actor,outfit,exp)]
 elif speaker=='二階堂頼子':
  if part=='a' or i<=3:
   outfit='ward';exp='surprised' if i in [9,20,24,30,32,34,36,44,51,55,69,75,90,94,96,98,102,112,124,136,148,158,168,176,186] else 'worried' if i>=29 or part=='b' else 'neutral'
  else:
   outfit='or';exp='curious' if 20<=i<=24 or 30<=i<=33 or 49<=i<=58 else 'worried' if i in [14,27,35,37,39,61,64,66] else 'neutral'
   if i==74:exp='surprised'
   if i==76:exp='held_breath'
  art_version='v2' if outfit=='or' else 'v1'
  path=f'assets/characters/yoriko_story_{art_version}/{outfit}_{exp}.png'
  visuals=[dict(id='story_guest_yoriko',path=path,x=820 if outfit=='or' else 880,width=460 if outfit=='or' else 340,height=370 if outfit=='or' else 410,bottom=550)]
 # Explicit silent reaction shots, without changing narrator speaker ownership.
 elif speaker=='旁白':
  if part=='a' and i in [1,18,78,91]:visuals=[portrait('nurse_yui','uniform','smile' if i in [18,78] else 'neutral')]
  if part=='b' and i in [10,59,62,67]:visuals=[portrait('nurse_yui','scrubs','focused' if i==67 else 'warm')]
  if part=='b' and i==25:visuals=[portrait('doc_sayaka','scrubs','focused')]
  if part=='b' and i in [43,73]:visuals=[portrait('nurse_rin','sterile','focused')]
 for v in visuals:assert (R/v['path']).is_file(),v
 return actor,outfit,exp,visuals

def build():
 rows=[dict(source_id=m[1],id=m[1].lower().replace('-','_'),speaker=m[2],text=m[3]) for m in re.finditer(r'^\*\*([AB]2-\d{3})｜([^：]+)：\*\*\s*(.+)$',(R/SOURCE).read_text(),re.M)]
 assert len(rows)==273
 loc=read('data/localization/en.json');strings=loc['strings'];defs=[];steps=[];review=[]
 for part,eid,title,title_en,count in [('a',A,'明天由你主演',"Tomorrow, You're the Star",197),('b',B,'怎么已经到九点了？！','How Is It Nine Already?!',76)]:
  batch=[r for r in rows if r['id'].startswith(part)];en=(R/f'tools/fixtures/miyuki_lv2_en/{part}.txt').read_text().splitlines();assert len(batch)==len(en)==count
  stepid=eid+'_main';nodes=[]
  for i,(r,english) in enumerate(zip(batch,en),1):
   assert r['id']==f'{part}2_{i:03}'
   actor,outfit,exp,visuals=staging(part,i,r['speaker'])
   bg='ward_night' if part=='a' else 'ward' if i<=5 else 'hallway' if i<=9 else 'operating_room'
   n=dict(id=r['id'],speaker='narrator' if r['speaker']=='旁白' else 'player' if r['speaker']=='坂口隆司' else 'actor',speaker_label=r['speaker'],text=r['text'],presentation='authored',expression=exp,background_id=bg,hide_portrait=not visuals,event_portraits=visuals)
   if actor:n.update(actor_id=actor,outfit=outfit)
   n['choices']=[dict(id='continue',label='继续',next=f'{part}2_{i+1:03}' if i<count else '@day_end',requirements=[])]
   if part=='b' and i==76:n['exit_blackout_seconds']=0.5
   nodes.append(n)
   for suffix,value in [('text',english),('speaker_label',NAMES[r['speaker']]),('choices.continue.label','Continue')]:strings[f'collections.special_event_steps.{stepid}.nodes.{r["id"]}.{suffix}']=value
   review.append({**r,'en':english,'actor_id':actor,'outfit':outfit,'expression':exp,'event_portraits':visuals})
  steps.append(dict(id=stepid,title=title,background_id=nodes[0]['background_id'],start=nodes[0]['id'],nodes=nodes))
  d=dict(id=eid,title='明天开刀的事',category='story_special_event',duration_days=1,consumes_full_day=False,settled_minutes=0 if part=='a' else 240,repeatable=False,developer_only=False,auto_schedule=part=='b',mandatory_auto_start=True,trigger_mode='after_work' if part=='a' else 'day_start',unlock_requirements=[],required_characters=[],prerequisite_events=[] if part=='a' else [A],event_chain=[stepid],completion_flags=[],gallery_unlock=True,gallery_entry=dict(id=eid,title=title,chapters=['完整回放']),timing=dict(trigger_day=1,priority=700,final_week_allowed=True,sunday_start_allowed=False))
  if part=='b':d['relationship_rewards']=[dict(actor_id='nurse_yui',target_level=2,benefit_id='',award_event_familiarity=False,allow_level_skip=False)]
  defs.append(d)
  for suffix,value in [('title',"About Tomorrow's Operation"),('gallery_entry.title',title_en),('gallery_entry.chapters.0','Full replay')]:strings[f'collections.special_events.{eid}.{suffix}']=value
  strings[f'collections.special_event_steps.{stepid}.title']=title_en
 write('data/events/special_events/miyuki_lv2.json',defs);write('data/events/special_event_steps/miyuki_lv2.json',steps)
 write('docs/source/miyuki_lv2/bilingual_review.json',review)
 for kind in ['special_events','special_event_steps']:
  p=f'data/events/{kind}/index.json';idx=read(p)
  if 'miyuki_lv2.json' not in idx['files']:idx['files'].append('miyuki_lv2.json')
  write(p,idx)
 rel=read('data/staff/nurse_yui/relationship.json');next(s for s in rel['rank_slots'] if s['target_level']==2).update(event_id=B,content_status='authored');write('data/staff/nurse_yui/relationship.json',rel)
 write('data/localization/en.json',loc)
 print('Miyuki Lv2: 197 + 76 source-exact bilingual nodes; eight Yoriko sprites.')
if __name__=='__main__':build()
