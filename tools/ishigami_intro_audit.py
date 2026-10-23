"""Audit original Chinese prose, speakers, order, and authorized translation."""
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
b=ROOT/'research/character_references/ishigami_chizuru_2026-10-22/lv0'
s=(b/'source_cn.md').read_text().split('## 2. 完整 VN 剧本')[1].split('## 3.')[0]
rows=[l for l in s.splitlines() if l.strip() and not l.startswith(('#','**场景','---','【事件结束】'))]
eng=(b/'translation_en.txt').read_text().splitlines()
e=json.loads((ROOT/'data/staff/nurse_ishigami/events.json').read_text())[0]
loc={l:json.loads((ROOT/f'data/localization/{l}.json').read_text())['strings'] for l in ['en','zh_CN']}
actors={'石神':'nurse_ishigami','恋':'nurse_haru'}
assert len(rows)==len(eng)==66 and len(e['nodes'])==64
index=0
for j,n in enumerate(e['nodes']):
 m=re.match(r'\*\*(.+?)：\*\*(.*)',rows[index]);who,text=m.groups() if m else ('旁白',rows[index])
 english=eng[index]
 if index in [11,64]:
  text+='\n\n'+rows[index+1];english+='\n\n'+eng[index+1];index+=1
 index+=1
 assert n['text']==text and n['speaker_label']==who
 if who in actors:assert n['actor_id']==actors[who]
 assert n['speaker']==('player' if who=='坂口' else 'narrator' if who=='旁白' else 'actor')
 prefix=f"collections.character_events.{e['id']}.nodes.{n['id']}"
 assert loc['en'][prefix+'.text']==english and loc['zh_CN'][prefix+'.text']==text
 assert n['choices'][0]['next']==(e['nodes'][j+1]['id'] if j<63 else '@end')
 assert n['choices'][0]['effects']=={'affection':0,'familiarity':0}
 if who=='恋':assert j<9
assert index==66 and e['minutes']==20 and e['conditions']['min_day']==8
print('PASS: 66 original paragraphs in 64 nodes; no text or speaker changes; two consecutive narration pairs joined with blank lines; complete English')
