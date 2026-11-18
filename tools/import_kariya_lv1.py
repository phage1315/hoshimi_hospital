from pathlib import Path
import re,json
p=Path('research/source_scripts/HOSHIMI_KARIYA_MEGUMI_LV1_BUTCHER_SHOP_GIRL_V1_0.md')
rows=[]; labels={}; scene=0; active=False; branch='main'; flash=False
names={'狩谷惠':('actor','nurse_kariya_megumi'),'绀野真琴':('actor','nurse_kariya_megumi'),'杉村弘子':('actor','nurse_hiroko'),'坂口隆司':('player','nurse_kariya_megumi')}
def add(t,sp='旁白'):
 rows.append(dict(id=f'km1_{len(rows)+1:03}',scene=scene,branch=branch,flash=flash,speaker_label=sp,speaker=names.get(sp,('narrator','nurse_kariya_megumi'))[0],actor_id=names.get(sp,('narrator','nurse_kariya_megumi'))[1],text=t))
for line in p.read_text().splitlines():
 s=line.strip()
 if s.startswith('## B.'):break
 if s.startswith('### 【第'):scene+=1;active=False;branch='main';continue
 if s=='**【玩家可见正文】**':active=True;continue
 if s.startswith('**【选择 1'):active=False;continue
 m=re.match(r'- \*\*选项 ([ABC])：(「.*」)\*\*',s)
 if m:labels[m[1]]=m[2];continue
 if s.startswith('#### 【分支 '):branch=s.split('分支 ')[1][0];active=True;continue
 if s=='> **【主线汇合】**':branch='join';active=True;continue
 if s.startswith('*(【极短闪回'):flash=True;continue
 if s.startswith('*(【闪回结束'):flash=False;continue
 if not active or not s or s=='---' or s.startswith('**【狩谷惠 Relationship'):continue
 # Keep exact strings. Explicit role prefixes are labels; action+quote splits retain every character.
 m=re.match(r'^(狩谷惠|绀野真琴|杉村弘子|坂口隆司)：(「.*」)$',s)
 if m:add(m[2],m[1]);continue
 m=re.match(r'^(.*?：)(「.*」)$',s)
 if m:
  pref,quote=m.groups();sp=next((n for n in names if pref.startswith(n)),None)
  if pref.startswith('薄毯底下'):sp='绀野真琴'
  if sp:add(pref);add(quote,sp);continue
 add(s, '狩谷惠' if s == '「噗——」' else '旁白')
# Runtime import: retain original paragraphs and punctuation; split explicit speech from action prefixes.
import hashlib,shutil
ROOT=Path(__file__).resolve().parents[1]
EVENT='kariya_lv1_butcher_shop_girl'; ACTOR='nurse_kariya_megumi'
CG='assets/events/kariya_lv1_v1/butcher_misunderstanding.png'
def read(path):return json.loads(Path(path).read_text())
def write(path,data):Path(path).write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
def art(who,key,x):
 if who=='makoto':path=f'assets/characters/kariya_lv1_v1/makoto/{key}.png';w,h=400,300
 elif who=='megumi':
  path=f'assets/characters/kariya_lv1_v1/megumi/{key}.png' if key in ['surprised','flustered'] else f'assets/characters/kariya_megumi_v1/nurse_kariya_megumi/uniform/{key}.png';w,h=320,480
 else:raise ValueError('Unknown portrait owner: '+who)
 return {'id':who,'path':path,'x':x,'bottom':480 if who=='makoto' else 556,'width':w,'height':h}
# Locate the registered visual mapping without assuming a top-level property name.
hp=read('data/staff/nurse_hiroko/profile.json')
def find_portraits(o):
 if isinstance(o,dict):
  if 'portraits' in o:return o['portraits']
  for v in o.values():
   r=find_portraits(v)
   if r:return r
 return None
hiroko_portraits=find_portraits(hp)
def hiroko(key,x=985):return {'id':'nurse_hiroko','path':hiroko_portraits[key],'x':x,'bottom':556,'width':320,'height':480}
def stage(n):
 if 34<=n<=36:return {'background_id':'narrative_black','hide_portrait':True}
 if n==132:return {'background_id':'narrative_black','hide_portrait':True}
 bg='ward' if n<=95 or n in [115,116] else ('hallway' if n<120 else 'or_entrance')
 if 48<=n<=52:return {'background_id':bg,'cg_path':CG,'cg_fit':'contain','cg_dialogue_delay_seconds':2.0}
 mood='blank' if 21<=n<=33 else ('panic' if 48<=n<=69 or n>=130 else ('embarrassed' if 85<=n<=94 or n>=116 else 'neutral'))
 mk=art('makoto',mood,440)
 mg='smile' if 26<=n<=47 or 104<=n<=128 else ('surprised' if n==53 else ('flustered' if 54<=n<=69 or n==129 else ('serious' if 70<=n<=80 else 'worried')))
 if n<=15: portraits=[mk,hiroko('uniform/smile')]
 elif n<=25:portraits=[mk]
 elif 96<=n<=114:portraits=[art('megumi',mg,985)]
 elif 121<=n<=124:portraits=[mk,hiroko('scrubs/warm')]
 else:portraits=[mk,art('megumi',mg,985)]
 return {'background_id':bg,'event_portraits':portraits}
nodes=[]
for i,r in enumerate(rows):
 n=i+1;nxt=f'km1_{n+1:03}' if n<132 else '@end'
 if n==101:nxt='km1_choice'
 if n in [106,110,114]:nxt='km1_115'
 node={k:r[k] for k in ['id','speaker','speaker_label','actor_id','text']}
 node.update(presentation='authored',outfit='uniform',expression='neutral',**stage(n))
 node['choices']=[{'id':'continue_'+r['id'],'label':'继续','next':nxt,'effects':{'affection':0,'familiarity':0},'flags':[]}]
 nodes.append(node)
 if n==101:nodes.append({'id':'km1_choice','presentation':'choice','speaker':'narrator','speaker_label':'旁白','actor_id':ACTOR,'text':'','outfit':'uniform','expression':'worried',**stage(101),'choices':[{'id':'km1_reply_'+k.lower(),'label':v,'next':{'A':'km1_102','B':'km1_107','C':'km1_111'}[k],'effects':{'affection':0,'familiarity':0},'flags':[]} for k,v in labels.items()]})
event={'id':EVENT,'actor_id':ACTOR,'title':'昨天卖肉的姑娘','chapter':1,'location_id':'ward','trigger_mode':'location','background_id':'ward','outfit':'uniform','minutes':30,'time_start':540,'time_end':719,'priority':150,'category':'bond','auto_start':True,'target_level':1,'benefit_id':'','cinematic':True,'locks_saving':True,'hide_calendar_header':True,'teaser':'术前病房转运误会与惠的 Lv1 沟通成长','gallery':{'cg_id':EVENT,'caption':'昨天卖肉的姑娘','path':CG,'show_on_complete':False},'conditions':{'min_day':62,'min_affection':0,'min_familiarity':10,'required_events':['intro_kariya_megumi_june'],'special_requirements':[{'type':'calendar_range','start_date':'2025-06-01','end_date':'2025-11-30'},{'type':'day_type','values':['weekday']}]},'start':'km1_001','nodes':nodes}
folder=Path('data/staff')/ACTOR
write(folder/'lv1_events.json',[event])
b=read(folder/'bundle.json');extras=b.setdefault('additional_character_event_files',[])
if 'lv1_events.json' not in extras:extras.append('lv1_events.json')
write(folder/'bundle.json',b)
r=read(folder/'relationship.json');slot=next(s for s in r['rank_slots'] if s['target_level']==1);slot.update(event_id=EVENT,content_status='authored');write(folder/'relationship.json',r)
profile=read(folder/'profile.json');portraits=find_portraits(profile)
for expr in ['surprised','flustered']:portraits['uniform/'+expr]=f'assets/characters/kariya_lv1_v1/megumi/{expr}.png'
write(folder/'profile.json',profile)
en={ 'km1_'+line.split('|',1)[0]:line.split('|',1)[1] for line in Path('research/translations/kariya_lv1_en.txt').read_text().splitlines() if line.strip()}
assert len(en)==132
speaker_en={'旁白':'Narrator','狩谷惠':'Megumi Kariya','绀野真琴':'Makoto Konno','杉村弘子':'Hiroko Sugimura','坂口隆司':'Takashi Sakaguchi'}
choice_en={'A':"“Relax. There isn't a deduction on the assessment form for 'being mistaken for a pig butcher.'”",'B':'“You caught yourself and clearly explained your duties to her. That was well handled.”','C':'“Why deduct points for honest work after hours? You handled the situation steadily in the end.”'}
for lang in ['zh_CN','en']:
 loc=read(f'data/localization/{lang}.json');strings=loc['strings'];prefix='collections.character_events.'+EVENT+'.'
 for k in list(strings):
  if k.startswith(prefix):del strings[k]
 fields={'title':event['title'],'teaser':event['teaser'],'gallery.caption':event['gallery']['caption']}
 if lang=='en':fields={'title':"Yesterday's Meat-Shop Girl",'teaser':"A preoperative transport misunderstanding becomes Megumi's first lesson in communication.",'gallery.caption':"Yesterday's Meat-Shop Girl"}
 for k,v in fields.items():strings[prefix+k]=v
 for node in nodes:
  np=prefix+'nodes.'+node['id']+'.'
  if node['text']:strings[np+'text']=node['text'] if lang=='zh_CN' else en[node['id']]
  strings[np+'speaker_label']=node['speaker_label'] if lang=='zh_CN' else speaker_en[node['speaker_label']]
  for c in node['choices']:strings[np+'choices.'+c['id']+'.label']=c['label'] if lang=='zh_CN' else ('Continue' if c['id'].startswith('continue_') else choice_en[c['id'][-1].upper()])
 write(f'data/localization/{lang}.json',loc)
Path(CG).parent.mkdir(parents=True,exist_ok=True)
shutil.copy2('research/imports/kariya_lv1_user_cg_2026-11-16/source.png',CG)
manifest={'event_id':EVENT,'source':str(p),'source_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'translation':'research/translations/kariya_lv1_en.txt','rows':rows,'choices':labels,'story_guest':{'id':'story_guest_konno_makoto','name':'绀野真琴','age':22,'random_pool':False,'surgery_queue':False},'decisions':['Narrative 08:45 retained; runtime begins 09:00 or later, costs 30 minutes','Scrub-nurse story qualification does not restrict gameplay assignment','Three branches have no numerical or flag differences','No Hiroko relationship requirement or reward']}
write('research/imports/kariya_lv1_2026-11-16.json',manifest)
print('Imported',len(nodes),'nodes; 3 branches; bilingual strings')
