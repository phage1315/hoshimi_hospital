"""Compare every runtime line and speaker with the supplied Chinese script."""
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
base=ROOT/'research/character_references/kariya_megumi_2026-10-22/lv0'
s=(base/'source_cn.md').read_text().split('## 2. 完整执行剧本')[1].split('## 3.')[0]
rows=[l for l in s.splitlines() if l.strip() and not l.startswith(('#','**开始','**进入','---','【事件结束】'))]
en=(base/'translation_en.txt').read_text().splitlines()
e=json.loads((ROOT/'data/staff/nurse_kariya_megumi/events.json').read_text())[0]
locales={l:json.loads((ROOT/f'data/localization/{l}.json').read_text())['strings'] for l in ['en','zh_CN']}
actors={'石神':'nurse_ishigami','惠':'nurse_kariya_megumi','弘子':'nurse_hiroko','安琪':'nurse_ange'}
assert len(rows)==len(en)==len(e['nodes'])==111
for i,(line,n,english) in enumerate(zip(rows,e['nodes'],en)):
 m=re.match(r'\*\*(.+?)：\*\*(.*)',line)
 who,text=m.groups() if m else ('旁白',line)
 assert n['text']==text and n['speaker_label']==who
 if who in actors:assert n['actor_id']==actors[who]
 assert n['speaker']==('player' if who=='坂口' else 'narrator' if who=='旁白' else 'actor')
 prefix=f"collections.character_events.{e['id']}.nodes.{n['id']}"
 assert locales['zh_CN'][prefix+'.text']==text and locales['en'][prefix+'.text']==english
 assert n['choices'][0]['effects']=={'affection':0,'familiarity':0}
 assert n['choices'][0]['next']==(e['nodes'][i+1]['id'] if i<110 else '@end')
 if i>=103:assert n['hide_portrait']
assert e['introduction_actor_ids']==['nurse_kariya_megumi']
assert e['minutes']==30 and e['conditions']['min_day']==62 and e['time_start']==540
print('PASS: 111 CN lines, speakers, punctuation and order unchanged; full EN translation; offscreen exit; only Megumi introduced')
