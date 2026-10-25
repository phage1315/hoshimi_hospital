"""Verify Saeko authoring, translations, exact Lv0 mapping and asset provenance."""
import json,re,hashlib
from pathlib import Path
R=Path(__file__).resolve().parents[1]
def read(p):return json.loads((R/p).read_text())
b='research/character_references/hikami_saeko_2026-10-22/'
d='data/staff/nurse_hikami_saeko/'
a=read(b+'authoring_v1/HOSHIMI_HIKAMI_SAEKO_DIALOGUE_AUTHORING_V1.json')
p=read(d+'profile.json');t=read(d+'time_events.json');e=read(d+'events.json')[0]
loc={l:read('data/localization/'+l+'.json')['strings'] for l in ['en','zh_CN']}
def strings(o):
 if isinstance(o,str):yield o
 elif isinstance(o,dict):
  for v in o.values():yield from strings(v)
 elif isinstance(o,list):
  for v in o:yield from strings(v)
def pairs(o):
 if isinstance(o,dict):
  if isinstance(o.get('zh_CN'),str) and isinstance(o.get('en'),str):yield o['zh_CN'],o['en']
  for v in o.values():yield from pairs(v)
 elif isinstance(o,list):
  for v in o:yield from pairs(v)
cn=set(strings([p,t]));en=set(v for k,v in loc['en'].items() if 'nurse_hikami_saeko' in k)
ps=list(pairs(a))+list(zip(a['preop_graphic_wrapper']['zh_CN'].values(),a['preop_graphic_wrapper']['en'].values()))
for zh,eng in ps:assert zh in cn and eng in en,(zh,eng)
source=(R/b/'authoring_v1/HOSHIMI_HIKAMI_SAEKO_LV0_CODEX_READY_V1.md').read_text().split('## 二、全文与顺序')[1].split('## 三、')[0]
rows=re.findall(r'^\*\*(旁白|弘子|冴子|坂口)：\*\*\s*(.+)$',source,re.M)
review=read(b+'authoring_v1/lv0_bilingual_review.json');assert len(rows)==len(e['nodes'])==len(review)==28
for i,((who,zh),n,rv) in enumerate(zip(rows,e['nodes'],review)):
 assert n['text']==zh==rv['zh_CN'] and n['speaker_label']==who==rv['speaker_zh_CN']
 assert n['speaker']==('actor' if who in ['弘子','冴子'] else 'player' if who=='坂口' else 'narrator')
 if who in ['弘子','冴子']:assert n['actor_id']=={'弘子':'nurse_hiroko','冴子':'nurse_hikami_saeko'}[who]
 prefix='collections.character_events.'+e['id']+'.nodes.'+n['id']
 assert loc['zh_CN'][prefix+'.text']==zh and loc['en'][prefix+'.text']==rv['en']
 assert n['choices'][0]['next']==(e['nodes'][i+1]['id'] if i<27 else '@end')
 assert n['choices'][0]['effects']=={'affection':0,'familiarity':0}
 assert not n['choices'][0]['flags']
assert e['minutes']==15 and e['category']=='introduction'
assert p['skills']==read(b+'user_confirmed_data.json')['skills'] and p['familiarity_rules']['base']==1.2
r=read(d+'relationship.json');assert not r['met'] and r['level']==0 and all(s['content_status']=='planned' for s in r['rank_slots'])
assets=read(d+'assets_manifest.json')['sources'];assert len(assets)==19
for asset in assets:
 assert hashlib.sha256((R/asset['source']).read_bytes()).hexdigest()==asset['sha256']==hashlib.sha256((R/asset['target']).read_bytes()).hexdigest()
print(f'PASS: {len(ps)} bilingual dialogue pairs; 28 exact CN/EN VN nodes with speakers/order/punctuation; 19 unchanged art files; confirmed stats, future ranks planned.')
