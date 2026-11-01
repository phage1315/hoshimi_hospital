#!/usr/bin/env python3
"""Build the approved discharge/return sources, keeping all other content intact."""
import json, re, copy
from pathlib import Path
R=Path(__file__).resolve().parents[1]
F=R/'tools/fixtures/chihaya_mizuho_return'
D='chihaya_mizuho_joint_discharge';N='chihaya_mizuho_nurse_return'
ACT={'千早':'patient_chihaya','瑞穗':'guest_mizuho','朝仓':'nurse_yui','芹香':'doc_serika','明日香':'doc_asuka'}
NAMES={'千早':'Chihaya Kuramoto','瑞穗':'Mizuho Shite','朝仓':'Miyuki Asakura','芹香':'Serika Misono','明日香':'Asuka Shiromiya','坂口':'Ryuji Sakaguchi','旁白':'Narrator'}
def read(p):return json.loads((R/p).read_text())
def write(p,v):
 p=R/p;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
def lines(name):return (F/name).read_text().splitlines()
def build():
 src=read('tools/fixtures/chihaya_mizuho_return/source_rows.json');staffsrc=read('tools/fixtures/chihaya_mizuho_return/staff_source.json')
 direction=read('tools/fixtures/chihaya_mizuho_return/expression_direction.json')
 cg_direction=read('tools/fixtures/chihaya_mizuho_return/cg_direction.json')
 en=read('data/localization/en.json');ss=en['strings'];steps=[];defs=[];audit=[]
 profiles={p.parent.name:json.loads(p.read_text()) for p in (R/'data/staff').glob('*/profile.json')}
 def node(r,english,background,outfit):
  who=r['speaker'];base=who.split('（')[0];actor=ACT.get(base,'');txt=r['text']
  if r['id'] in ['n03_001','n05_001']:txt='【'+txt.split('。',1)[1]
  x=dict(id=r['id'],speaker='narrator' if base=='旁白' else 'player' if base=='坂口' else 'actor',speaker_label=who,text=txt,presentation='authored',expression='neutral',background_id=background,event_portraits=[],hide_portrait=True)
  if actor:
   cue=direction['story'][r['id']];assert cue['actor_id']==actor
   if actor in ['guest_mizuho','patient_chihaya']:assert cue['outfit']==outfit
   x.update(cue)
   portrait=profiles[actor]['visuals']['portraits'][cue['outfit']+'/'+cue['expression']]
   assert (R/portrait).is_file();x['hide_portrait']=False;x['event_portraits']=[dict(id=actor,path=portrait,x=880,width=400,height=410,bottom=550)]
  return x
 for part,eid,title,titleen,minutes,filename in [('d',D,'一起出院','Leaving Together',60,'discharge_en.txt'),('n',N,'怎么又在医院？','Back at the Hospital Again?',120,'return_en.txt')]:
  translations=lines(filename);assert len(translations)==len(src[part]);nodes=[];stepid=eid+'_main'
  for r,english in zip(src[part],translations):
   scene=r['scene'];background={'d01':'ward','d02':'hallway','d03':'diagnostics','d04':'nurses_station','n01':'hallway','n02':'mizuho_home','n03':'director_office','n04':'chihaya_home','n05':'changing','n06':'hallway'}[scene]
   if scene=='d04' and r['id']>='d04_021':background='lobby'
   if scene=='n04' and r['id']>='n04_082':background='director_office'
   if scene=='n05' and r['id']>='n05_026':background='hallway'
   outfit='casual' if part=='d' or scene in ['n02','n03','n04'] else 'uniform'
   x=node(r,english,background,outfit)
   if r['id'] in cg_direction:
    assert (R/cg_direction[r['id']]).is_file()
    x.update(cg_path=cg_direction[r['id']],cg_fit='contain')
   if r['id']=='n06_059':x['hide_portrait']=True;x['event_portraits']=[]
   k=f'collections.special_event_steps.{stepid}.nodes.{x["id"]}'
   ss[k+'.text']=english;ss[k+'.speaker_label']=NAMES[r['speaker'].split('（')[0]]+(' (thinking)' if '心声' in r['speaker'] else '');ss[k+'.choices.continue.label']='Continue'
   nodes.append(x);audit.append(dict(id=x['id'],source=r['text'],text=x['text'],speaker=r['speaker'],en=english))
  for i,x in enumerate(nodes):x['choices']=[dict(id='continue',label='继续',next=nodes[i+1]['id'] if i+1<len(nodes) else '@day_end',requirements=[])]
  steps.append(dict(id=stepid,title=title,background_id=nodes[0]['background_id'],start=nodes[0]['id'],nodes=nodes));ss[f'collections.special_event_steps.{stepid}.title']=titleen
  prerequisites=['chihaya_third_surgery_'+p for p in 'abc']+['mizuho_first_surgery_'+p for p in 'asbc'] if part=='d' else [D]
  d=dict(id=eid,title=title,category='story_special_event',duration_days=1,consumes_full_day=False,settled_minutes=minutes,repeatable=False,developer_only=False,auto_schedule=True,mandatory_auto_start=True,trigger_mode='day_start',unlock_requirements=[],required_characters=[],prerequisite_events=prerequisites,event_chain=[stepid],completion_flags=[eid+'_complete'],gallery_unlock=True,gallery_entry=dict(id=eid,title=title,chapters=['完整回放']),timing=dict(trigger_day=1,priority=620,final_week_allowed=True,sunday_start_allowed=False))
  defs.append(d)
  for key,value in [('title',titleen),('gallery_entry.title',titleen),('gallery_entry.chapters.0','Full replay')]:ss[f'collections.special_events.{eid}.{key}']=value
 write('data/events/special_events/chihaya_mizuho_return.json',defs);write('data/events/special_event_steps/chihaya_mizuho_return.json',steps)
 for kind in ['special_events','special_event_steps']:
  path=f'data/events/{kind}/index.json';idx=read(path)
  if 'chihaya_mizuho_return.json' not in idx['files']:idx['files'].append('chihaya_mizuho_return.json')
  write(path,idx)
 work=staffsrc['work'];worken=lines('work_en.txt');assert len(work)==len(worken)==152
 for r,e in zip(work,worken):r['en']=e
 chat_en=iter(lines('chats_en.txt'))
 for chat in staffsrc['chats']:
  for r in chat['nodes']:r['en']=next(chat_en)
 assert next(chat_en,None) is None
 for short,actor,zh in [('CHI','patient_chihaya','千早'),('MIZ','guest_mizuho','瑞穗')]:
  p=copy.deepcopy(profiles['nurse_iwasaki_rumi']);p={k:v for k,v in p.items() if k in ['id','name','age','gender','profession','team_category','skills','surgery_proficiency','surgical_roles','specialty','rank','personality','appearance','dialogue_style','flags','event_history','presence','team_dialogue','familiarity_rules']}
  skill=[0,0,8,8,4,7] if short=='CHI' else [0,0,7,6,3,5]
  p.update(id=actor,name='仓本千早' if short=='CHI' else '支手瑞穗',age=18,skills=dict(zip(['surgery','diagnostics','teamwork','patient_care','instrument_handling','calmness'],skill)),surgery_proficiency='novice',surgical_roles=['circulating_nurse'],allowed_team_roles=['ward_nurse','circulating_nurse'],staff_unlock_event=N,specialty='病房准备／非无菌巡回',rank='临时护理辅助人员',personality='小心、认真，能理解患者的恐惧' if short=='CHI' else '外向、爽快，愿意承认不懂并向前辈求助',appearance='沿用仓本千早本人形象' if short=='CHI' else '沿用支手瑞穗本人形象',dialogue_style='认真而亲近' if short=='CHI' else '明快而直接',flags=['introduction_pending','exclude_adult_intimacy','exclude_clinical_practice_patient','after_work_disabled'],event_history=[],familiarity_rules=dict(base=1.8,operations=[]),personal_nurse=dict(eligible=False,dialogue=dict(next_test_hint=[],insufficient_evidence=[],sufficient_evidence=[],chatter=[])),team_dialogue=dict(assignment='',intraoperative=''))
  portraits={}
  if short=='CHI':portraits={f'scrubs/{k}':f'assets/characters/chihaya_scrubs_v1/{v}.png' for k,v in [('neutral','standing'),('warm','warm'),('worried','worried')]}
  else:portraits={f'casual/{p.stem}':str(p.relative_to(R)) for p in (R/'assets/characters/mizuho_story_v1/casual').glob('*.png')}
  p['visuals']=dict(color='b4c4c4',default_outfit='uniform',outfits=['uniform','scrubs','casual'],portraits=portraits,offscreen_outfits=['uniform','casual'] if short=='CHI' else ['uniform','scrubs'],intraoperative_avatar=dict(status='needed',portrait_key='intraoperative_avatar/neutral',target_path=f'assets/characters/intraoperative_staff_avatars_v1/{actor}/neutral.png',required_for=['operative_field_hud']))
  generated=R/'assets/characters/chihaya_mizuho_nurses_v1'/actor
  for image in generated.glob('*/*.png'):p['visuals']['portraits'][image.parent.name+'/'+image.stem]=str(image.relative_to(R))
  p['visuals']['offscreen_outfits']=[o for o in p['visuals']['outfits'] if o+'/neutral' not in p['visuals']['portraits']]
  if 'intraoperative_avatar/neutral' in p['visuals']['portraits']:
   p['visuals']['portraits']['intraoperative_avatar/neutral']=f'assets/characters/intraoperative_staff_avatars_v1/{actor}/neutral.png'
   p['visuals']['intraoperative_avatar']['status']='ready'
   p['visuals']['intraoperative_avatar']['target_path']=p['visuals']['portraits']['intraoperative_avatar/neutral']
  scoped={r['id']:r for r in work if r['id'].startswith(short)}
  p['authored_dialogue']={'work.'+k[len(short)+1:].replace("-", "_"):[{'zh_CN':r['text'],'en':r['en']}] for k,r in scoped.items() if '-CR-' not in k}
  p['team_assignment_replies']={role:scoped[short+'-'+key]['text'] for role,key in [('ward_nurse','WD-01'),('circulating_nurse','OR-01')]}
  for role,key in [('ward_nurse','WD-01'),('circulating_nurse','OR-01')]:ss[f'collections.staff.{actor}.team_assignment_replies.{role}']=scoped[short+'-'+key]['en']
  p['post_operation_replies']=[scoped[f'{short}-END-0{i}']['text'] for i in range(1,4)]
  for i in range(3):ss[f'collections.staff.{actor}.post_operation_replies.{i}']=scoped[f'{short}-END-0{i+1}']['en']
  p['crisis_callouts']={}
  for flavor in ['hypotension','hypertension','tachycardia','bradycardia','arrhythmia','desaturation','respiratory_instability','generic_instability']:
   v=dict(id='standard',tone='character',weight=1)
   for severity,key in [('normal','attempt_lines'),('severe','severe_attempt_lines')]:
    v[key]=[scoped[f'{short}-CR-{flavor}-{severity}-{i}']['text'] for i in range(1,4)]
    for i in range(3):ss[f'collections.staff.{actor}.crisis_callouts.{flavor}.standard.{key}.{i}']=scoped[f'{short}-CR-{flavor}-{severity}-{i+1}']['en']
   p['crisis_callouts'][flavor]=[v]
  for key,value in dict(name=NAMES[zh],specialty='Ward preparation / nonsterile circulating support',rank='Temporary nursing support staff',personality='Careful and conscientious; understands patients\' fears.' if short=='CHI' else 'Outgoing and direct; admits uncertainty and asks experienced colleagues for help.',appearance='Chihaya Kuramoto\'s established appearance' if short=='CHI' else 'Mizuho Shite\'s established appearance',dialogue_style='Earnest and friendly' if short=='CHI' else 'Bright and direct').items():ss[f'collections.staff.{actor}.{key}']=value
  rel=read('data/staff/nurse_iwasaki_rumi/relationship.json');rel.update(target_id=actor,flags=['introduction_pending','sunday_date_disabled','hotel_disabled','staff_as_patient_disabled'],level=0,familiarity=0,met=False)
  for slot in rel['rank_slots']:
   lv=slot['target_level'];slot.update(min_familiarity=(75 if short=='CHI' else 50 if lv==4 else 90) if lv>=4 else 0,cooldown_days=0 if short=='MIZ' and lv==4 else 3)
   if lv==5 and short=='MIZ':slot['special_requirements']=[dict(type='story_flag',flag='chihaya_lv5_staff_patient_surgery_complete',value=True)]
  events=[]
  def add_chat(eventid,location,selected,paired=False):
   ev=dict(id=eventid,actor_id=actor,location_id=location,label='和'+p['name']+'闲谈' if not paired else '和千早、瑞穗闲谈',responses=[c['nodes'][0]['text'] for c in selected],minutes=30,repeatable=True,dialogue_variants=[])
   if paired:ev['required_actor_ids']=['patient_chihaya','guest_mizuho']
   ss[f'collections.time_events.{eventid}.label']='Chat with '+NAMES[zh] if not paired else 'Chat with Chihaya and Mizuho'
   for i,c in enumerate(selected):
    ns=[];ss[f'collections.time_events.{eventid}.responses.{i}']=c['nodes'][0]['en']
    for j,r in enumerate(c['nodes']):
     who=r['speaker'];ns.append(dict(speaker='player' if who=='坂口' else 'narrator' if who=='旁白' else 'actor',actor_id=ACT.get(who,''),speaker_label=who,text=r['text']))
     cue=direction['chats'][c['id']][j]
     if cue:
      assert cue['actor_id']==ns[-1]['actor_id'];ns[-1].update(cue)
     key=f'collections.time_events.{eventid}.dialogue_variants.{i}.{j}';ss[key+'.text']=r['en'];ss[key+'.speaker_label']=NAMES[who]
    ev['dialogue_variants'].append(ns)
   events.append(ev)
  for code,location in [('NS-IDLE','station'),('WARD-IDLE','ward'),('BREAK','lounge'),('ROOF','rooftop')]:add_chat('idle_'+actor+'_'+location,location,[c for c in staffsrc['chats'] if c['id'].startswith(short+'-'+code+'-')])
  if short=='CHI':
   for code,loc in [('NS','station'),('WARD','ward'),('BREAK','lounge')]:add_chat('pair_chihaya_mizuho_'+loc,loc,[c for c in staffsrc['chats'] if c['id'].startswith('PAIR-'+code+'-')],True)
  eid='work_chat_'+actor+'_nurse_station';events.append(dict(id=eid,actor_id=actor,location_id='station',label='护士站工作',responses=[scoped[f'{short}-NS-0{i}']['text'] for i in range(1,7)],minutes=30,repeatable=True));ss[f'collections.time_events.{eid}.label']='Nurses\' station work'
  for i in range(6):ss[f'collections.time_events.{eid}.responses.{i}']=scoped[f'{short}-NS-0{i+1}']['en']
  base='data/staff/'+actor+'/'
  write(base+'profile.json',p);write(base+'relationship.json',rel);write(base+'time_events.json',events)
  write(base+'bundle.json',dict(schema_version=1,id=actor,profile='profile.json',relationship='relationship.json',time_events='time_events.json'))
  idx=read('data/staff/index.json')
  if actor+'/bundle.json' not in idx:idx.append(actor+'/bundle.json')
  write('data/staff/index.json',idx)
 write('data/localization/en.json',en)
 write('docs/source/chihaya_mizuho_return/bilingual_review.json',dict(events=audit,work=work,chats=staffsrc['chats']))
 print('Built 855 story nodes, 152 work lines, 27 complete chats (135 turns), two gated staff profiles.')
if __name__=='__main__':build()
