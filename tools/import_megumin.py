#!/usr/bin/env python3
"""Lossless source mapping; explicit branch metadata, never rewrite Chinese prose."""
import json,re,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'research/character_references/npc_megumin/implementation_v2_2026_11_05'
HALLOWEEN_SOURCE=ROOT/'research/character_references/npc_megumin/halloween_v1/source.md'
HALLOWEEN_ID='megumin_halloween_original_mage_reveal'
EN=ROOT/'research/translations/megumin_en.json'
CAST={'惠惠':'npc_megumin','坂口隆司':'player','水城阿库娅':'doc_aqua','城宮明日香':'doc_asuka','深山佳織':'doc_rei','遥凑':'doc_minato','石神千鹤':'nurse_ishigami','飯村真奈美':'pharmacist_manami','本庄萌恵':'nurse_moe','折川皐月':'nurse_satsuki','南条小夜香':'doc_sayaka','御堂江美子':'doc_emiko','阿尔托莉雅':'doc_artoria','七瀬恋':'nurse_haru','神宮寺成美':'doc_aoi','狩谷惠':'nurse_kariya_megumi','武見妙':'doc_takemi','氷上冴子':'nurse_hikami_saeko','女访客':'visitor','旁白':'narrator'}
NAMES={'惠惠':'Megumin','坂口隆司':'Ryuji Sakaguchi','水城阿库娅':'Aqua Mizuki','城宮明日香':'Asuka Shiromiya','深山佳織':'Kaori Miyama','遥凑':'Minato Haruka','石神千鹤':'Chizuru Ishigami','飯村真奈美':'Manami Iimura','本庄萌恵':'Moe Honjo','折川皐月':'Satsuki Orikawa','南条小夜香':'Sayaka Nanjo','御堂江美子':'Emiko Mido','阿尔托莉雅':'Artoria Pendragon','七瀬恋':'Ren Nanase','神宮寺成美':'Narumi Jinguji','狩谷惠':'Megumi Kariya','武見妙':'Tae Takemi','氷上冴子':'Saeko Hikami','女访客':'Female Visitor','旁白':'Narrator'}
def beat(raw,gate=''):
 text=raw.strip();speaker='旁白'
 m=re.match(r'^\*\*([^*：]+)(：)?\*\*(.*)$',text)
 if m:
  speaker=m[1];text=m[3]
  if text.startswith('：'):text=text[1:]
 elif text.startswith('*') and text.endswith('*'):text=text[1:-1]
 if speaker not in CAST:raise ValueError(speaker)
 return {'speaker':speaker,'actor_id':CAST[speaker],'text':text,'gate':gate,'source_raw':raw}
def extract():
 result=[];manifest=json.loads((SRC/'05_EVENT_MANIFEST.json').read_text());by={e['content_id']:e for e in manifest['events']}
 for name in ['03_MICRO_EVENTS_CN.md','04_AMBIENT_BARKS_CN.md']:
  text=(SRC/name).read_text()
  sections=re.split(r'(?m)^### (megumin_[rmsl]\d\d) \| ([^\n]+)\n',text)
  for i in range(1,len(sections),3):
   id,title,section=sections[i:i+3];body=section.split('【玩家可见正文】',1)[1];rows=[];gate=''
   for raw in body.splitlines():
    line=raw.strip()
    if not line or line=='---' or line.startswith('## '):continue
    if line.startswith('【条件分支（'):
     gate='takemi_public' if '条件分支版' in line else '!takemi_public';continue
    if line.startswith('【条件：'):
     gate='aqua_present' if '水城' in line else 'ren_present';continue
    if line.startswith('【否则：'):gate='!ren_present';continue
    if line.startswith('【两个分支'):gate='';continue
    rows.append(beat(line,gate))
   entry=dict(by[id]);entry.update(title=title.split(' — ',1)[1],beats=rows);result.append(entry)
 # Intro branches are explicit, authored; the response choice is the only player choice.
 text=(SRC/'02_INTRO_SCRIPT_CN.md').read_text();text=text.split('## Scene 01',1)[1].split('## Event End',1)[0]
 rows=[];gate='';part=0;choice_labels=[]
 for raw in text.splitlines():
  line=raw.strip()
  if not line:continue
  if line.startswith('## Scene '):part=int(line.split('Scene ')[1][0]);gate='';continue
  if line.startswith('【场景】') or line=='【玩家可见正文】' or line.startswith('— '):continue
  if line.startswith('【再次见面差分'):part=1;continue
  if line.startswith('【阿库娅出场分支'):part=2;continue
  if line.startswith('**A —'):gate='cameo_seen' if part==1 else 'aqua_present';continue
  if line.startswith('**B —'):gate='!cameo_seen' if part==1 else '!aqua_present';continue
  if line.startswith('【选择：'):gate='';continue
  if line.startswith('- **选项 '):choice_labels.append(re.search('「.*」',line)[0]);continue
  if line=='【A 分支正文】':
   rows.append({'speaker':'旁白','actor_id':'narrator','text':'','gate':'','source_raw':line,'choice_labels':choice_labels});gate='choice_a';continue
  if line=='【B 分支正文】':gate='choice_b';continue
  if line=='【A／B 在这里汇合】':gate='';continue
  if line.startswith('【'):raise ValueError('unmapped instruction '+line)
  if line.startswith(' —') or '导诊使徒'==line:continue
  rows.append(beat(line,gate))
 result.insert(0,{'content_id':'megumin_intro_front_desk','title':'前台接待员惠惠','kind':'intro','beats':rows})
 # Authorized addendum: retain every visible action and line; exclude branch directions.
 text=HALLOWEEN_SOURCE.read_text().split('### 3.1 完整 VN 正文',1)[1].split('### 3.2',1)[0]
 rows=[];gate=''
 for raw in text.splitlines():
  line=raw.strip()
  if line.startswith('#### 分支A'):gate='aqua_present'
  elif line.startswith('#### 分支B'):gate='!aqua_present'
  elif line.startswith('#### 分支汇合'):gate=''
  elif line.startswith('【以下进入'):continue
  elif line.startswith(('【','**')):rows.append(beat(line,gate))
 result.append({'content_id':HALLOWEEN_ID,'title':'万圣节','kind':'calendar_costume_reveal','annual_group':'halloween_costume_reveal','beats':rows})
 for e in result:
  for i,b in enumerate(e['beats']):
   if e['content_id']=='megumin_m26':b['text']=b['text'].replace('今天是一年一度的万圣节前夕','万圣节期间')
   b['id']=f'{e["content_id"]}_{i:03d}'
   school=e['kind']=='afterwork_micro' or e['content_id'] in ['megumin_l17','megumin_l18','megumin_l19','megumin_l20']
   mood='neutral';t=b['text']
   if b['actor_id']=='npc_megumin':
    if any(w in t for w in ['哼哼','制霸','战果','守护','重要职责','必胜']):mood='confident' if school else 'proud'
    elif any(w in t for w in ['怪谈','秘密','幽灵','传言','听说','传说']):mood='thoughtful' if school else 'suspicious'
    elif any(w in t for w in ['呜哇','失算','石、石神','坂、坂口','……诶']):mood='nervous' if school else 'flustered'
    elif any(w in t for w in ['出发','先走','交接','再见','挥手']):mood='goodbye' if school else 'welcoming'
    elif any(w in t for w in ['欢迎','谢谢','高兴','笑']):mood='neutral' if school else 'welcoming'
    elif any(w in t for w in ['决定','大学','数学','判断','执照','护理']):mood='thoughtful' if school else 'serious'
   b['portrait']=('school_' if school else 'reception_')+mood
   if e['content_id']=='megumin_m27':b['portrait']='school_winter'
   if e['content_id']=='megumin_r25' and i>=2:b['portrait']='school_nervous'
   if e['content_id']=='megumin_m07' and i==4:b['portrait']='school_goodbye'
   if e['content_id']=='megumin_intro_front_desk' and b['actor_id']=='npc_megumin' and '哼哼' in t:b['portrait']='reception_proud' 
   if e['content_id']==HALLOWEEN_ID:
    mood='neutral'
    if i in [2,3,4,6,9,12,14,17]:mood='proud'
    if i in [7,8,10,19,20,23,24,25,26]:mood='flustered'
    if i>=27:mood='happy'
    b['portrait']='halloween_original_mage_'+mood
 return result

def main():
 entries=extract();english=json.loads(EN.read_text()) if EN.exists() else {}
 pending={}
 for e in entries:
  id=e['content_id'];pending[id+'.title']=e['title'];e['title']={'zh_CN':e['title'],'en':english.get(id+'.title','')}
  for b in e['beats']:
   key=b['id'];pending[key]=b['text'];b['text']={'zh_CN':b['text'],'en':english.get(key,'')}
   b['speaker_label']={'zh_CN':b.pop('speaker'),'en':''};b['speaker_label']['en']=NAMES[b['speaker_label']['zh_CN']]
   for i,label in enumerate(b.get('choice_labels',[])):pending[key+f'.choice{i}']=label
   if 'choice_labels' in b:b['choice_labels']=[{'zh_CN':v,'en':english.get(key+f'.choice{i}','')} for i,v in enumerate(b['choice_labels'])]
 out=ROOT/'data/npcs/megumin/catalog.json';out.parent.mkdir(parents=True,exist_ok=True)
 out.write_text(json.dumps({'actor_id':'npc_megumin','cast':CAST,'entries':entries},ensure_ascii=False,indent=2)+'\n')
 (ROOT/'research/translations/megumin_source.json').write_text(json.dumps(pending,ensure_ascii=False,indent=2)+'\n')
 print(len(entries),'events;',len(pending),'translation keys;',sum(bool(v) and not english.get(k) for k,v in pending.items()),'missing')
if __name__=='__main__':main()
