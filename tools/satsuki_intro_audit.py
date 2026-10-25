"""Verify the supplied Lv0 text and its localized runtime mapping."""
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
b=ROOT/'research/character_references/orikawa_satsuki_2026-10-22/lv0'
s=(b/'source_cn.md').read_text().split('## 三、正式 VN 剧本')[1].split('## 四、')[0]
rows=re.findall(r'^\*\*(旁白|折川皐月|杉村弘子|坂口隆司)：\*\*(.+)$',s,re.M)
en=(b/'translation_en.txt').read_text().splitlines()
e=json.loads((ROOT/'data/staff/nurse_satsuki/events.json').read_text())[0]
loc={l:json.loads((ROOT/f'data/localization/{l}.json').read_text())['strings'] for l in ['en','zh_CN']}
assert len(rows)==len(en)==len(e['nodes'])==40
for i,((who,t),eng,n) in enumerate(zip(rows,en,e['nodes'])):
 if who=='旁白':t=t[1:-1]
 assert n['text']==t and n['speaker_label']==who
 assert n['speaker']==('narrator' if who=='旁白' else 'player' if who=='坂口隆司' else 'actor')
 if who in ['折川皐月','杉村弘子']:assert n['actor_id']=={'折川皐月':'nurse_satsuki','杉村弘子':'nurse_hiroko'}[who]
 prefix=f"collections.character_events.{e['id']}.nodes.{n['id']}"
 assert loc['zh_CN'][prefix+'.text']==t and loc['en'][prefix+'.text']==eng
 assert n['choices'][0]['next']==(e['nodes'][i+1]['id'] if i<39 else '@end')
 assert n['choices'][0]['effects']=={'affection':0,'familiarity':0}
assert e['nodes'][-1]['text']=='「诶？？？？？」'
assert e['minutes']==20 and e['conditions']['min_day']==8
print('PASS: 40 CN/EN nodes; exact dialogue, speakers, order; only specified narrator delimiters removed; final punchline unchanged')
