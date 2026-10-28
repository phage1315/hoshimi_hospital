#!/usr/bin/env python3
"""Exact approved CN source + reviewed EN + explicit cast presentation.

This importer owns only third-surgery content and its localization keys. It
never invokes the obsolete importers or writes player progress.
"""
import json, re
from pathlib import Path
R = Path(__file__).resolve().parents[1]
SOURCE = R/'docs/source/chihaya_third_surgery/HOSHIMI_CHIHAYA_THIRD_SURGERY_CODEX_READY_CN_V1.md'
PREFIX = 'chihaya_third_surgery_'
TITLE = '这次真的不会有第四次了吧？'
TITLE_EN = "There Really Won't Be a Fourth Time... Right?"
NOTE = '具体置管节段、药物和给药参数留待医学审稿。'
INTRO = 'intro_rumi_shiori_hiroko_monday_0900'
ACTORS = {'千早':'patient_chihaya','瑞穗':'guest_mizuho','芹香':'doc_serika',
 '阿库娅':'doc_aqua','明日香':'doc_asuka','七濑恋':'nurse_haru',
 '留美':'nurse_iwasaki_rumi','安琪':'nurse_ange','弘子':'nurse_hiroko'}
NAMES = {'旁白':'Narrator','坂口':'Ryuji Sakaguchi','千早':'Chihaya Kuramoto',
 '瑞穗':'Mizuho Shite','芹香':'Serika Misono','阿库娅':'Aqua Mizuki',
 '明日香':'Asuka Shiromiya','七濑恋':'Ren Nanase','留美':'Rumi Iwasaki',
 '安琪':'Anji Tonegawa','弘子':'Hiroko Sugimura'}
def read(p): return json.loads((R/p).read_text())
def write(p,v): (R/p).write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
def rows():
 body=SOURCE.read_text().split('## 二、完整中文 VN 剧本',1)[1].split('## 三、医学审稿',1)[0].split('\n',1)[1]
 out=[];scene='';counts={}
 for line in body.splitlines():
  line=line.strip()
  m=re.match(r'### 场景 ([ABC]\d\d)',line)
  if m: scene=m[1].lower()
  if not line or line.startswith('#') or line=='---': continue
  if line.startswith('【开发条件说明') or line.startswith('【阶段 '): continue
  m=re.fullmatch(r'([^：]+)：(「.*」)',line)
  if line.startswith('【') and line.endswith('】'): who,text='旁白',line
  elif m: who,text=m.groups()
  else: raise ValueError(line)
  counts[scene]=counts.get(scene,0)+1
  out.append(dict(id=f'{scene}_{counts[scene]:03}',scene=scene,speaker=who,text=text))
 return out

def stage(row):
 """Authored presentation by scene and exact transitions, never dialogue keywords."""
 sid,scene,who=row['id'],row['scene'],row['speaker'].split('（')[0]
 bg={'a01':'ward','a02':'diagnostics','a03':'ward','a04':'hallway','a05':'director_office',
 'b01':'ward','b02':'operating_room','b03':'operating_room','b04':'operating_room',
 'b05':'operating_room','b06':'operating_room','c01':'ward','c02':'ward'}[scene]
 if sid=='a01_026': bg='diagnostics'
 if scene=='a04' and sid>='a04_012': bg='clinic'
 if scene=='b01' and sid>='b01_012': bg='or_entrance'
 if scene=='b01' and sid>='b01_024': bg='operating_room'
 if sid=='b01_039' or (scene=='b06' and sid>='b06_020'): bg='or_entrance'
 actor=ACTORS.get(who,'');style='';outfit='';expression='neutral'
 if who=='千早':
  outfit='ward' if scene.startswith('a') else 'intraoperative' if scene.startswith('b') else 'postop'
  expression='worried' if outfit=='ward' else 'tense' if outfit=='intraoperative' else 'relieved'
 elif who=='瑞穗': outfit,expression='casual','smile'
 elif who=='芹香': outfit,expression=('white_coat','focused') if scene=='a02' else ('scrubs','focused')
 elif who=='阿库娅':
  outfit='white_coat' if not scene.startswith('b') else 'scrubs' if sid<'b02_035' else 'sterile'
  expression='serious' if outfit=='white_coat' else 'focused'
 elif who=='明日香': outfit='director_suit'
 elif who=='七濑恋': outfit,expression=('scrubs' if sid<'b02_035' else 'sterile'),'warm'
 elif who=='留美': outfit,expression='scrubs','warm'
 elif who in ['安琪','弘子']: outfit,expression='uniform','smile'
 # Specific expressive beats, all using that actor's existing assets.
 overrides={
 'a01_011':'surprised','a01_013':'angry','a01_017':'tired','a01_019':'crying','a01_024':'worried',
 'a03_006':'surprised','a03_007':'tired','a03_009':'crying','a03_010':'afraid','a03_015':'surprised',
 'a03_017':'brave','a03_018':'smile','a03_022':'smile','a03_026':'tired','a03_028':'brave',
 'a03_030':'afraid','a03_031':'joyful','a03_032':'angry','a03_034':'brave',
 'a04_005':'happy','a04_008':'worried','a04_009':'teasing','a04_014':'happy','a04_016':'happy',
 'a05_003':'happy','a05_008':'teasing','a05_011':'worried','a05_015':'annoyed',
 'a05_017':'surprised','a05_019':'serious','a05_022':'serious','a05_024':'teasing',
 'a05_026':'happy','a05_027':'smile','a05_030':'shy','a05_032':'worried','a05_034':'shy','a05_036':'happy',
 'b01_004':'tired','b01_006':'surprised','b01_011':'angry','b01_023':'tense','b01_025':'relieved',
 'b01_033':'surprised','b01_035':'angry','b01_038':'tired',
 'b02_004':'excited','b02_005':'angry','b02_007':'surprised','b02_008':'joyful','b02_009':'shy',
 'b02_012':'relieved','b02_017':'angry','b02_019':'tense','b02_022':'relieved','b02_024':'tired',
 'b02_026':'angry','b02_027':'joyful','b02_029':'surprised','b02_031':'surprised',
 'b02_034':'angry','b02_036':'tired','b02_039':'tense','b02_041':'tense','b02_050':'crying',
 'b03_009':'tense','b03_010':'neutral','b03_011':'surprised',
 'b04_018':'surprised','b04_019':'focused','b04_020':'crying','b04_021':'surprised',
 'b04_024':'crying','b04_030':'surprised','b04_032':'relieved','b04_039':'surprised',
 'b04_041':'angry','b04_045':'worried','b04_046':'tense','b04_047':'focused',
 'b04_048':'crying','b04_053':'tense','b04_055':'relieved','b04_060':'tense','b04_062':'surprised',
 'b04_063':'warm','b04_064':'relieved',
 'b05_003':'shy','b05_005':'relieved','b05_007':'tense','b05_009':'crying','b05_011':'neutral',
 'b05_013':'neutral','b05_014':'relieved','b05_016':'talking','b05_017':'relieved',
 'b05_019':'surprised','b05_021':'relieved','b05_022':'talking','b05_023':'surprised',
 'b05_025':'relieved','b05_027':'shy','b05_028':'neutral','b05_029':'talking',
 'b05_030':'surprised','b05_032':'relieved','b05_033':'talking','b05_035':'talking',
 'b05_036':'relieved','b05_037':'talking','b05_038':'surprised','b05_039':'neutral',
 'b05_040':'surprised','b05_041':'talking','b05_042':'relieved','b05_045':'relieved',
 'b05_046':'talking','b05_047':'relieved','b05_048':'talking','b05_049':'relieved',
 'b05_050':'talking','b05_051':'relieved','b05_052':'neutral','b05_054':'surprised',
 'b05_057':'neutral','b05_059':'talking','b05_060':'surprised','b05_061':'talking',
 'b05_062':'surprised','b05_064':'talking','b05_065':'surprised','b05_066':'talking',
 'b05_067':'surprised','b05_068':'talking','b05_069':'relieved','b05_070':'talking',
 'b05_071':'surprised','b05_072':'talking','b05_074':'relieved','b05_075':'neutral',
 'b05_077':'worried','b05_079':'worried','b05_086':'neutral','b05_087':'relieved',
 'b05_088':'neutral','b05_089':'relieved','b05_090':'neutral','b05_091':'relieved',
 'b06_002':'surprised','b06_004':'angry','b06_005':'joyful','b06_008':'tired',
 'b06_010':'crying','b06_011':'neutral','b06_012':'tired','b06_013':'neutral','b06_017':'relieved',
 'b06_022':'neutral','b06_025':'neutral',
 'c01_003':'smile','c01_005':'pain','c01_011':'relieved','c01_013':'tired',
 'c01_014':'joyful','c01_015':'angry','c01_021':'smile','c01_023':'shy',
 'c01_025':'shy','c01_027':'smile','c01_028':'closed_eye_smile','c01_029':'smile',
 'c01_031':'angry','c01_033':'smile','c01_036':'smile','c01_038':'smile',
 'c01_040':'smile','c01_041':'surprised','c01_043':'smile','c01_044':'smile',
 'c01_045':'surprised','c01_047':'shy','c01_049':'smile','c01_051':'smile','c01_052':'joyful',
 'c02_002':'smile','c02_003':'joyful','c02_004':'angry','c02_006':'angry','c02_009':'smile'}
 expression=overrides.get(sid,expression)
 # Approved masked scrubs preserve the nonsterile observer outfit. This
 # explicit node map does not alter white-coat or other event appearances.
 if actor=='doc_serika' and scene.startswith('b'):
  expression=read('tools/fixtures/chihaya_third_serika_masked.json')[sid]
 if actor:
  style=f'{outfit}/{expression}'
  if actor=='patient_chihaya': path=f'assets/characters/patient_chihaya_second_surgery_v1/{style}.png'
  elif actor=='guest_mizuho': path=f'assets/characters/mizuho_story_v1/{style}.png'
  else: path=read(f'data/staff/{actor}/profile.json')['visuals']['portraits'][style]
  assert (R/path).is_file(),(sid,path)
 else: path=''
 return dict(background=bg,actor_id=actor,style=style,path=path)

def build():
 source=rows();en=read('tools/fixtures/chihaya_third_surgery_en.json')
 approved_cgs=read('tools/fixtures/chihaya_third_surgery_cgs.json')
 assert len(source)==487 and set(en)=={r['id'] for r in source}
 strings=read('data/localization/en.json');ss=strings['strings'];steps=[];review=[]
 staging={}
 for part in 'abc':
  nodes=[];step_id=PREFIX+part+'_main'
  for r in [x for x in source if x['scene'][0]==part]:
   if r['id']=='a03_019':continue
   sid,who=r['id'],r['speaker'];base=who.split('（')[0];s=stage(r);staging[sid]=s
   text=r['text'].replace(NOTE,'') if sid=='a03_033' else r['text']
   # Markdown bold is source formatting, not literal VN text.
   if sid=='a05_028':text=text.replace('**','')
   label=base if sid=='a03_018' else who
   n=dict(id=sid,speaker='narrator' if base=='旁白' else 'player' if base=='坂口' else 'actor',
    speaker_label=label,text=text,presentation='authored',expression=s['style'].split('/')[-1] if s['style'] else 'neutral',
    background_id=s['background'],event_portraits=[],hide_portrait=not s['actor_id'])
   if s['actor_id']:
    n['actor_id']=s['actor_id'];n['outfit']=s['style'].split('/')[0]
    intra=n['outfit']=='intraoperative'
    n['event_portraits']=[dict(id=s['actor_id'],path=s['path'],x=880,width=400,height=280 if intra else 410,bottom=485 if intra else 550)]
   key=f'collections.special_event_steps.{step_id}.nodes.{sid}'
   ss[key+'.text']=en[sid]
   ss[key+'.speaker_label']=NAMES[base]+(' (thinking)' if '心声' in who else ' (quietly)' if '小声' in who else ' (laughing)' if '（笑）' in who else '')
   ss[key+'.choices.continue.label']='Continue'
   if base=='留美' or sid=='a03_018':
    n['unmet_variant']=dict(actor_id='nurse_iwasaki_rumi',required_event_id=INTRO)
    if sid=='a03_018':
     n['unmet_variant']['text']=next(x['text'] for x in source if x['id']=='a03_019')
     ss[key+'.unmet_variant.text']=en['a03_019']
    else:
     n['unmet_variant']['speaker_label']='手术室值班护士'+('（笑）' if '（笑）' in who else '')
     ss[key+'.unmet_variant.speaker_label']='OR Duty Nurse'+(' (laughing)' if '（笑）' in who else '')
   n.update(approved_cgs.get(sid,{}))
   nodes.append(n)
  for i,n in enumerate(nodes):n['choices']=[dict(id='continue',label='继续',next=nodes[i+1]['id'] if i+1<len(nodes) else '@day_end',requirements=[])]
  steps.append(dict(id=step_id,title=TITLE,background_id=nodes[0]['background_id'],start=nodes[0]['id'],nodes=nodes))
  ss[f'collections.special_event_steps.{step_id}.title']=TITLE_EN
 for r in source:review.append(dict(source_id=r['id'],speaker_zh_CN=r['speaker'],zh_CN=r['text'],en=en[r['id']]))
 write('data/events/special_event_steps/chihaya_third_surgery.json',steps)
 write('tools/fixtures/chihaya_third_surgery_staging.json',staging)
 write('docs/source/chihaya_third_surgery/bilingual_review.json',review)
 write('data/localization/en.json',strings)
 print('Third surgery: 487 source paragraphs, 486 sequential nodes; one mutually exclusive variant; complete English.')
if __name__=='__main__':build()
