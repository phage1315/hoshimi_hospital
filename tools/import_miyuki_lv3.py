#!/usr/bin/env python3
"""Scoped, idempotent Lv3 importer; source text and approved A cast table only."""
import json,re
from pathlib import Path
R=Path(__file__).resolve().parents[1]
S=R/'docs/source/miyuki_lv3'
def read(p):return json.loads((R/p).read_text())
def write(p,v):
 p=R/p;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
src=next(S.glob('HOSHIMI*.md')).read_text()
rows=re.findall(r'^\*\*([AB]3-\d{3})｜([^：]+)：\*\*\s*(.+)$',src,re.M)
assert len(rows)==328
variants={m[0]:m[1:] for m in re.findall(r'^\| A3-(\d{3}) \| (.*?) \| (.*?) \|$',src,re.M)}
assert len(variants)==15
ve=read('tools/fixtures/miyuki_lv3_en/variants.json')
english=(R/'tools/fixtures/miyuki_lv3_en/a.txt').read_text().splitlines()+(R/'tools/fixtures/miyuki_lv3_en/b.txt').read_text().splitlines()
assert len(english)==328
NAMES={'旁白':'Narrator','朝仓美幸':'Miyuki Asakura','坂口隆司':'Takashi Sakaguchi','狩谷惠':'Megumi Kariya','米田栞':'Shiori Yoneda'}
BASE='assets/characters/miyuki_lv3_v1/'
def portrait(actor,path,x=640):
 assert (R/path).exists(),path
 if actor=='nurse_yui':
  # Source framings differ: preserve images and tune only this event's stage.
  if 'casual' in path:width,height,bottom=420,630,750
  elif 'miyuki_uncapped' in path:width,height,bottom=350,525,655
  elif 'miyuki_capped' in path:width,height,bottom=350,525,645
  else:width,height,bottom=420,500,620
  return dict(id=actor,path=path,x=x,bottom=bottom,width=width,height=height)
 return dict(id=actor,path=path,x=x,bottom=550,width=300,height=420)
def uniform(cast,expr):
 if cast=='miyuki':
  if expr=='neutral':return 'assets/characters/portrait_pack_v2/nurse_yui/uniform/neutral.png'
  return f'assets/characters/portrait_pack_v4/nurse_yui/uniform/{expr}.png'
 actor='nurse_kariya_megumi' if cast=='megumi' else 'nurse_yoneda_shiori'
 folder='kariya_megumi_v1' if cast=='megumi' else 'rumi_shiori_v1'
 return f'assets/characters/{folder}/{actor}/uniform/{expr}.png'
def stage_a(i,cast,who):
 actor='nurse_kariya_megumi' if cast=='megumi' else 'nurse_yoneda_shiori'
 speaking=actor if who in ['狩谷惠','米田栞'] else 'nurse_yui'
 if i<13:my=uniform('miyuki','smile' if i in [3,5,7] else 'neutral')
 elif i<68:my=BASE+('miyuki_uncapped_focused_hair_v2.png' if i in list(range(47,64))+[38] else 'miyuki_uncapped_hair_v2.png')
 elif i<76:my=BASE+'miyuki_capped_fixed.png'
 else:my='assets/characters/portrait_pack_v4/nurse_yui/scrubs/warm.png'
 if i<41:
  expr='worried' if i in [8,14,16,18,20,22,24,25,27,29,33,35,37,39] else 'smile' if i in [6] else 'neutral'
  other=uniform(cast,expr)
 elif i<68:other=BASE+cast+('_uncapped_worried.png' if i<=56 else '_uncapped.png')
 else:other=BASE+cast+('_capped_fixed.png' if cast=='megumi' else '_capped.png')
 # Source clothing changes are narrated, with no undressing illustration.
 people=[portrait('nurse_yui',my,465),portrait(actor,other,815)]
 return people,speaking,('hallway' if i>=76 else 'changing')
def stage_b(i):
 path=BASE+('miyuki_casual_apologetic.png' if i<49 else 'miyuki_casual_serious.png' if 84<=i<=114 or 185<=i<=216 else 'miyuki_casual_playful.png')
 bg='miyuki_date_plaza' if i<56 else 'date_cafe' if i<142 else 'minato_riverside_walk'
 return ([] if i<34 else [portrait('nurse_yui',path)]),'nurse_yui',bg
out=[];review=[]
for branch in ['kariya','shiori','date']:
 a=branch!='date';cast='megumi' if branch=='kariya' else 'shiori'
 eid='miyuki_lv3_locker_room_'+branch if a else 'miyuki_lv3_afternoon_good_morning'
 title='更衣室里的老手' if a else '下午三点的早安'
 title_en='The Veteran in the Changing Room' if a else 'Good Morning at Three in the Afternoon'
 e=dict(id=eid,actor_id='nurse_yui',title=title,chapter=3,location_id='lounge',trigger_mode='interaction' if a else 'sunday',background_id='changing' if a else 'miyuki_date_plaza',outfit='uniform' if a else 'casual',minutes=0,teaser=title,time_start=0,time_end=1440,priority=200,category='contextual' if a else 'rank_up',auto_start=a,target_level=2 if a else 3,benefit_id='',gallery=dict(cg_id='cg_'+eid,caption=title,path=''),conditions=dict(min_day=1,min_affection=0,min_familiarity=0,required_events=[],special_requirements=[]),start='a3_001' if a else 'b3_001',nodes=[],locks_saving=True,chain_followup=True)
 if not a:e['consumes_sunday']=True
 selected=list(zip(rows[:82],english[:82])) if a else list(zip(rows[82:],english[82:]))
 for k,((nid,who,cn),en) in enumerate(selected):
  i=k+1
  if a:
   if nid[-3:] in variants:
    column=0 if branch=='kariya' else 1
    override=variants[nid[-3:]][column]
    if override!='沿用正文':cn=override;en=ve[nid[-3:]][column]
   if who=='年轻护士':who='狩谷惠' if branch=='kariya' else '米田栞'
   portraits,visual,bg=stage_a(i,cast,who)
  else:portraits,visual,bg=stage_b(i)
  nodeid=nid.lower().replace('-','_')
  n=dict(id=nodeid,speaker='narrator' if who=='旁白' else 'player' if who=='坂口隆司' else 'actor',speaker_label=who,text=cn,expression='neutral',actor_id=visual,background_id=bg,outfit='uniform' if a and i<13 else 'scrubs' if a else 'casual',presentation='authored',hide_portrait=not portraits,event_portraits=portraits,choices=[dict(id='continue',label='继续',next=selected[k+1][0][0].lower().replace('-','_') if k+1<len(selected) else '@end',effects=dict(affection=0,familiarity=0),flags=[])])
  e['nodes'].append(n)
  review.append(dict(event_id=eid,id=nodeid,source_id=nid,speaker_zh_CN=who,speaker_en=NAMES[who],zh_CN=cn,en=en))
 e['_title_en']=title_en
 out.append(e)
for locale in ['zh_CN','en']:
 p='data/localization/'+locale+'.json';loc=read(p);strings=loc['strings']
 for e in out:
  pre='collections.character_events.'+e['id']
  for field in ['title','teaser','gallery.caption']:strings[pre+'.'+field]=e['_title_en'] if locale=='en' else e['title']
 for row in review:
  pfx='collections.character_events.'+row['event_id']+'.nodes.'+row['id']
  strings[pfx+'.text']=row['en' if locale=='en' else 'zh_CN']
  strings[pfx+'.speaker_label']=row['speaker_en' if locale=='en' else 'speaker_zh_CN']
  strings[pfx+'.choices.continue.label']='Continue' if locale=='en' else '继续'
 strings['collections.backgrounds.miyuki_date_plaza.label']='Afternoon Plaza' if locale=='en' else '午后广场'
 strings['ui.miyuki.lv3.complete']='Miyuki Asakura: Relationship Lv3 reached.' if locale=='en' else '朝仓美幸 Relationship Lv3 达成。'
 strings['ui.miyuki.lv3.serika_unmet']='Meet Serika Misono before continuing this date. Your Sunday activity has not been used.' if locale=='en' else '正式认识御园芹香后才能继续这段约会；本次周日行动尚未消耗。'
 write('data/localization/'+locale+'.json',loc)
for e in out:del e['_title_en']
p='data/staff/nurse_yui/events.json';existing=read(p);ids={e['id'] for e in out};write(p,[e for e in existing if e['id'] not in ids]+out)
write('docs/source/miyuki_lv3/bilingual_review.json',review)
p='data/backgrounds.json';bgs=read(p);bgs=[b for b in bgs if b['id']!='miyuki_date_plaza'];bgs.append(dict(id='miyuki_date_plaza',label='午后广场',path='assets/backgrounds/miyuki_lv3_v1/plaza.png'));write(p,bgs)
p='data/staff/nurse_yui/relationship.json';rel=read(p);slot=next(s for s in rel['rank_slots'] if s['target_level']==3);slot.update(event_id='miyuki_lv3_afternoon_good_morning',content_status='authored');write(p,rel)
print('Imported 82+82 cast variants and 246 date nodes; bilingual fields registered.')
