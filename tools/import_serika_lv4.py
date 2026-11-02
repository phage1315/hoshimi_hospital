#!/usr/bin/env python3
"""Scoped importer for the approved Lv4 script. Never touches other event data."""
import json,re
from pathlib import Path
R=Path(__file__).resolve().parents[1]
ID='serika_lv4_stay';STEP=ID+'_main'
def read(p):return json.loads((R/p).read_text())
def write(p,x):(R/p).write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n')
ACTORS={'御園芹香':'doc_serika','朝仓美幸':'nurse_yui','朝仓美幸（电话）':'nurse_yui','利根川安琪':'nurse_ange','薗田愛実':'nurse_sonoda_itsumi','岩崎留美':'nurse_iwasaki_rumi','米田栞':'nurse_yoneda_shiori','折川皐月':'nurse_satsuki'}
NAMES={'旁白':'Narrator','坂口隆司':'Ryuji Sakaguchi','御園芹香':'Serika Misono','堀内奈奈美':'Nanami Horiuchi','朝仓美幸':'Miyuki Asakura','朝仓美幸（电话）':'Miyuki Asakura (phone)','利根川安琪':'Ange Tonegawa','薗田愛実':'Itsumi Sonoda','岩崎留美':'Rumi Iwasaki','米田栞':'Shiori Yoneda','折川皐月':'Satsuki Orikawa'}
# Explicit scene directions, in source order (H is deliberately not lexically sorted).
CUES={
's01_001':(0,1380,'staff_lounge'),
's02_001':(0,1400,'exam_room'),'s02_036':(1,10,'exam_room'),
's03_001':(1,30,'operating_room'),'s03_030':(1,75,'operating_room'),'s03_058':(1,120,'operating_room'),'s03_080':(1,210,'operating_room'),
's04_001':(1,460,'hallway'),'s04_037':(1,510,'changing'),'s04_038':(1,520,'lobby'),'s04_041':(1,550,'after_work_street_placeholder'),
's05_001':(2,600,'hallway'),'s05_007':(2,600,'ward'),'s05_052':(2,620,'hallway'),'s05_053':(2,840,'ward'),'s05_088':(2,870,'hallway'),
's06_001':(2,1140,'hospital_night'),'s06_014':(2,1155,'after_work_street_summer_night'),'s06_027':(2,1170,'serika_home_living_placeholder'),'s06_084':(2,1260,'serika_home_bedroom_placeholder'),'s06_h01':(2,1380,'serika_home_bedroom_placeholder'),'s06_091':(2,1410,'serika_home_bedroom_placeholder'),
's07_001':(3,450,'serika_home_bedroom_placeholder'),'s07_002':(3,455,'serika_home_living_placeholder'),'s07_057':(3,510,'serika_home_living_placeholder'),'s07_058':(3,540,'serika_home_living_placeholder')}
def staging(row):
 sid=row['id'];scene=sid[:3];part=sid[4:];i=int(part.lstrip('h'));actor=ACTORS.get(row['speaker'],'');outfit='uniform';expression='focused';visible=bool(actor) and '电话' not in row['speaker']
 if actor=='doc_serika':
  outfit='white_coat';expression='talking'
  if scene=='s01':expression='soft_smile' if 12<=i<=20 else 'worried' if i<12 else 'focused'
  if scene=='s02':expression='focused' if i<21 else 'surprised' if i<=35 else 'worried'
  if scene=='s03':
   outfit='scrubs' if i<9 or i>=81 else 'sterile';expression=('masked_focused' if i<9 else 'masked_hesitant') if outfit=='scrubs' else 'focused'
   if outfit=='sterile' and 40<=i<=52:expression='worried'
  if scene=='s04':outfit='white_coat' if i<37 else 'casual';expression='sad' if i<34 else 'soft_smile'
  if scene=='s05':expression='sad' if i<88 else 'worried'
  if scene=='s06':
   outfit='casual';expression='sad' if i<57 else 'shy'
   if not part.startswith('h') and i in [59,60,61,62,76,77]:expression='soft_smile'
   if (part.startswith('h') and i>=9) or (not part.startswith('h') and i>=91):visible=False
  if scene=='s07':outfit='casual';expression='sad' if 16<=i<=29 else 'shy' if 34<=i<=43 else 'soft_smile'
 elif scene=='s03':outfit='sterile' if actor in ['nurse_sonoda_itsumi','nurse_iwasaki_rumi'] else 'scrubs';expression='focused'
 elif actor=='nurse_yui':expression='worried' if scene=='s05' and i<88 else 'neutral'
 elif actor=='nurse_ange':expression='worried'
 path=''
 if visible:
  portraits=read(f'data/staff/{actor}/profile.json')['visuals']['portraits']
  key=next((f'{outfit}/{e}' for e in [expression,'focused','serious','neutral'] if f'{outfit}/{e}' in portraits),None)
  assert key,(actor,outfit)
  expression=key.split('/')[1];path=portraits[key];assert (R/path).is_file(),path
 return actor,outfit,expression,visible,path

def build():
 source=(R/'docs/source/serika_lv4/HOSHIMI_MISONO_SERIKA_LV4_STAY_CODEX_CN_V1.md').read_text()
 rows=[dict(source_id=m[1],id=m[1].lower().replace('-','_'),speaker=m[2],text=m[3].replace('**','')) for m in re.finditer(r'^\*\*(S\d{2}-(?:H\d{2}|\d{3}))【([^】]+)】\*\*\s*(.+)$',source,re.M)]
 assert len(rows)==547 and len({r['id'] for r in rows})==547
 en={}
 for p in sorted((R/'tools/fixtures/serika_lv4_en').glob('*.txt')):
  batch=[r for r in rows if r['id'].startswith(p.stem+'_')];lines=p.read_text().splitlines();assert len(batch)==len(lines),(p,len(batch),len(lines))
  en.update({r['id']:line for r,line in zip(batch,lines)})
 assert set(en)=={r['id'] for r in rows}
 strings=read('data/localization/en.json');ss=strings['strings'];nodes=[];schedule={};review=[]
 cue=None
 for r in rows:
  sid=r['id'];cue=CUES.get(sid,cue);actor,outfit,exp,visible,path=staging(r)
  n=dict(id=sid,speaker='narrator' if r['speaker']=='旁白' else 'player' if r['speaker']=='坂口隆司' else 'actor',speaker_label=r['speaker'],text=r['text'],presentation='authored',expression=exp,background_id=cue[2],hide_portrait=not visible,event_portraits=[])
  if actor:n.update(actor_id=actor,outfit=outfit)
  if visible:n['event_portraits']=[dict(id=actor,path=path,x=880,width=400,height=410,bottom=550)]
  # User-provided event CGs. Keep them in the scoped importer so a future
  # rebuild preserves the authored H-section and aftercare image spans.
  if sid.startswith('s06_') and sid[4:].isdigit() and 41 <= int(sid[4:]) <= 83:
   n.update(cg_path='assets/events/serika_lv4_v1/cg01_living_embrace.png',cg_fit='contain',cg_dialogue_delay_seconds=0.7,hide_portrait=True,event_portraits=[])
   visible=False
  elif sid.startswith('s06_h') and 26 <= int(sid.removeprefix('s06_h')) <= 44:
   n.update(cg_path='assets/events/serika_lv4_v1/cg02_bedroom_intimacy.png',cg_fit='contain',cg_dialogue_delay_seconds=0.7)
  elif sid.startswith('s06_') and sid[4:].isdigit() and 91 <= int(sid[4:]) <= 113:
   n.update(cg_path='assets/events/serika_lv4_v1/cg03_aftercare.png',cg_fit='contain',cg_dialogue_delay_seconds=0.7)
  if sid=='s06_h44':n['exit_blackout_seconds']=1.0
  schedule[sid]=dict(day_offset=cue[0],clock=cue[1]);nodes.append(n)
  for suffix,value in [('text',en[sid]),('speaker_label',NAMES[r['speaker']]),('choices.continue.label','Continue')]:ss[f'collections.special_event_steps.{STEP}.nodes.{sid}.{suffix}']=value
  review_row={**r,'en':en[sid],'actor_id':actor,'portrait_path':path if visible else '', 'background_id':cue[2],'day_offset':cue[0],'clock':cue[1]}
  if 'cg_path' in n:review_row.update(cg_path=n['cg_path'],cg_fit=n['cg_fit'])
  review.append(review_row)
 for i,n in enumerate(nodes):n['choices']=[dict(id='continue',label='继续',next=nodes[i+1]['id'] if i+1<len(nodes) else '@day_end',requirements=[])]
 step=dict(id=STEP,title='留下来',background_id='staff_lounge',start=nodes[0]['id'],scene_schedule=schedule,nodes=nodes)
 definition=dict(id=ID,title='留下来',category='story_special_event',duration_days=1,consumes_full_day=False,settled_minutes=0,repeatable=False,developer_only=False,auto_schedule=False,mandatory_auto_start=True,trigger_mode='after_work',unlock_requirements=[],required_characters=['doc_serika','nurse_yui'],prerequisite_events=['serika_lv3_half_beat'],event_chain=[STEP],completion_flags=[],gallery_unlock=True,gallery_entry=dict(id=ID,title='留下来',chapters=['完整回放']),timing=dict(trigger_day=1,priority=500,final_week_allowed=False,sunday_start_allowed=True,time_start=960,time_end=1379),relationship_rewards=[dict(actor_id='doc_serika',target_level=4,benefit_id='unlock_intimacy_events',award_event_familiarity=False,allow_level_skip=False)],announcement='下班后连续演出至第三天后的09:00；期间无法进行普通活动或保存。',completion_hint='御園芹香 Lv4 达成，恋人关系成立，熟悉度成长倍率恢复为1.00。')
 for suffix,value in [('title','Stay'),('gallery_entry.title','Stay'),('gallery_entry.chapters.0','Full replay'),('announcement','A continuous story after work, ending three mornings later at 09:00. Ordinary activities and saving are unavailable during the event.'),('completion_hint','Serika Misono Lv4 reached. You are now a couple; familiarity growth is now 1.00.')]:ss[f'collections.special_events.{ID}.{suffix}']=value
 ss[f'collections.special_event_steps.{STEP}.title']='Stay'
 ss['ui.serika_lv4.complete_time']='Continuous story complete / Now %s %s'
 ss['ui.serika_lv4.category']='Character story'
 ss['ui.serika_lv4.span']='Tonight at 23:00 → three mornings later at 09:00'
 write('data/events/special_events/serika_lv4.json',[definition]);write('data/events/special_event_steps/serika_lv4.json',[step]);write('docs/source/serika_lv4/bilingual_review.json',review)
 for kind in ['special_events','special_event_steps']:
  p=f'data/events/{kind}/index.json';index=read(p)
  if 'serika_lv4.json' not in index['files']:index['files'].append('serika_lv4.json')
  write(p,index)
 backgrounds=read('data/backgrounds.json')
 for bid,ref,title in [('serika_home_living_placeholder','mizuho_home','芹香家客厅（临时背景）'),('serika_home_bedroom_placeholder','date_hotel','芹香家卧室（临时背景）')]:
  if not any(x['id']==bid for x in backgrounds):
   original=next(x for x in backgrounds if x['id']==ref).copy();original.update(id=bid,label=title);backgrounds.append(original)
  next(x for x in backgrounds if x['id']==bid).pop('name',None)
  next(x for x in backgrounds if x['id']==bid)['label']=title
  ss.pop(f'collections.backgrounds.{bid}.name',None)
  ss[f'collections.backgrounds.{bid}.label']='Serika’s living room (temporary background)' if 'living' in bid else 'Serika’s bedroom (temporary background)'
 write('data/backgrounds.json',backgrounds)
 rel=read('data/staff/doc_serika/relationship.json')
 slot=next(s for s in rel['rank_slots'] if s['target_level']==4);slot.update(event_id=ID,content_status='authored')
 write('data/staff/doc_serika/relationship.json',rel);write('data/localization/en.json',strings)
 print('Serika Lv4: 547 bilingual nodes, single atomic event; existing relation gates retained.')
if __name__=='__main__':build()
