#!/usr/bin/env python3
"""Import this approved source only; never rerun older event importers."""
import json, re
from pathlib import Path
R = Path(__file__).resolve().parents[1]
SOURCE = R/'docs/source/mizuho_first_surgery/HOSHIMI_MIZUHO_FIRST_SURGERY_CODEX_READY_CN_V1.md'
PREFIX = 'mizuho_first_surgery_'
TITLE = '这有什么好怕的？'
TITLE_EN = "What's So Scary About It?"
ACTORS = {'瑞穗':'guest_mizuho','千早':'patient_chihaya','芹香':'doc_serika','阿库娅':'doc_aqua',
 '弘子':'nurse_hiroko','米田':'nurse_yoneda_shiori','朝仓':'nurse_yui','留美':'nurse_iwasaki_rumi'}
NAMES = {'旁白':'Narrator','坂口':'Ryuji Sakaguchi','瑞穗':'Mizuho Shite','千早':'Chihaya Kuramoto',
 '芹香':'Serika Misono','阿库娅':'Aqua Mizuki','弘子':'Hiroko Sugimura','米田':'Shiori Yoneda',
 '朝仓':'Miyuki Asakura','留美':'Rumi Iwasaki'}
DATE_ORIGINAL = '「恢复得不错嘛！那下周我们一起出院也没问题了。」'
DATE_APPROVED = '「恢复得不错嘛！那下下周一我们一起出院也没问题了。」'
INTRO = 'intro_rumi_shiori_hiroko_monday_0900'
def read(p): return json.loads((R/p).read_text())
def write(p,v): (R/p).write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
def rows():
 body=SOURCE.read_text().split('## 二、完整中文 VN 剧情正文',1)[1].split('## 三、',1)[0]
 out=[];scene='';counts={}
 for raw in body.splitlines():
  line=raw.strip();m=re.match(r'### 场景 ([ASBC]\d\d)',line)
  if m: scene=m[1].lower()
  if not line or line.startswith(('#','>')) or line=='---' or not scene: continue
  if line.startswith('【') and line.endswith('】'):who,text='旁白',line
  elif '：「' in line: who,text=line.split('：',1)
  else: raise ValueError(line)
  assert who.split('（')[0] in NAMES,who
  counts[scene]=counts.get(scene,0)+1
  out.append(dict(id=f'{scene}_{counts[scene]:03}',scene=scene,speaker=who,text=text))
 assert len(out)==1047
 return out

def build():
 source=rows();en={}
 for p in sorted((R/'tools/fixtures/mizuho_first_surgery_en').glob('*.txt')):
  for line in p.read_text().splitlines():
   if not line.strip():continue
   key,value=line.split('\t',1);assert key not in en,key;en[key]=value
 assert set(en)=={r['id'] for r in source},(len(en),set(r['id'] for r in source)-set(en))
 staging=read('tools/fixtures/mizuho_first_surgery_staging.json')
 strings=read('data/localization/en.json');ss=strings['strings'];steps=[];defs=[];review=[]
 for part in 'asbc':
  eid=PREFIX+part;step_id=eid+'_main';nodes=[]
  for r in [x for x in source if x['scene'][0]==part]:
   sid,who=r['id'],r['speaker'];base=who.split('（')[0];s=staging[sid];actor=ACTORS.get(base,'')
   text=DATE_APPROVED if r['text']==DATE_ORIGINAL else r['text']
   n=dict(id=sid,speaker='narrator' if base=='旁白' else 'player' if base=='坂口' else 'actor',
    speaker_label=who,text=text,presentation='authored',expression=s.get('expression','neutral'),
    background_id=s['background'],event_portraits=[],hide_portrait=not actor)
   if actor:
    n.update(actor_id=actor,outfit=s['outfit'])
    intra=s['outfit']=='intraoperative'
    n['event_portraits']=[dict(id=actor,path=s['path'],x=880,width=400,height=280 if intra else 410,bottom=485 if intra else 550)]
    assert (R/s['path']).is_file(),s['path']
   if s.get('cg_path'):
    assert (R/s['cg_path']).is_file(),s['cg_path']
    n.update(cg_path=s['cg_path'],cg_fit=s.get('cg_fit','contain'))
   key=f'collections.special_event_steps.{step_id}.nodes.{sid}'
   ss[key+'.text']=en[sid];ss[key+'.speaker_label']=NAMES[base]+(' (thinking)' if '心声' in who else '')
   ss[key+'.choices.continue.label']='Continue'
   if base in ['留美','米田']:
    n['unmet_variant']=dict(actor_id=actor,required_event_id=INTRO,speaker_label='手术室值班护士' if base=='留美' else '巡回护士')
    ss[key+'.unmet_variant.speaker_label']='OR Duty Nurse' if base=='留美' else 'Circulating Nurse'
   nodes.append(n);review.append(dict(source_id=sid,speaker_zh_CN=who,source_zh_CN=r['text'],zh_CN=text,en=en[sid]))
  for i,n in enumerate(nodes):n['choices']=[dict(id='continue',label='继续',next=nodes[i+1]['id'] if i+1<len(nodes) else '@day_end',requirements=[])]
  steps.append(dict(id=step_id,title=TITLE,background_id=nodes[0]['background_id'],start=nodes[0]['id'],nodes=nodes))
  ss[f'collections.special_event_steps.{step_id}.title']=TITLE_EN
  prior={'a':['chihaya_third_surgery_a','chihaya_third_surgery_b','chihaya_third_surgery_c'],'s':[PREFIX+'a'],'b':[PREFIX+'a',PREFIX+'s'],'c':[PREFIX+'b']}[part]
  flags=[eid+'_complete']+({'b':['mizuho_first_surgery_success'],'c':['mizuho_first_surgery_chain_complete']}.get(part,[]))
  d=dict(id=eid,title=TITLE,category='story_special_event',duration_days=1,consumes_full_day=False,
   settled_minutes=60 if part in 'ac' else 0,repeatable=False,developer_only=False,auto_schedule=part!='s',
   mandatory_auto_start=True,trigger_mode='after_work' if part=='s' else 'day_start',unlock_requirements=[],
   required_characters=[],prerequisite_events=prior,event_chain=[step_id],completion_flags=flags,
   gallery_unlock=True,gallery_entry=dict(id=eid,title=TITLE,chapters=['完整回放']),
   timing=dict(trigger_day=1,priority=620,final_week_allowed=True,sunday_start_allowed=False))
  defs.append(d)
  for suffix,value in [('title',TITLE_EN),('gallery_entry.title',TITLE_EN),('gallery_entry.chapters.0','Full replay')]:ss[f'collections.special_events.{eid}.{suffix}']=value
 write('data/events/special_event_steps/mizuho_first_surgery.json',steps)
 write('data/events/special_events/mizuho_first_surgery.json',defs)
 write('docs/source/mizuho_first_surgery/bilingual_review.json',review)
 write('data/localization/en.json',strings)
 for kind in ['special_events','special_event_steps']:
  path=f'data/events/{kind}/index.json';index=read(path)
  if 'mizuho_first_surgery.json' not in index['files']:index['files'].append('mizuho_first_surgery.json')
  write(path,index)
 print('Mizuho first surgery: 1047 authored nodes, four separate episodes, complete English.')
if __name__=='__main__':build()
