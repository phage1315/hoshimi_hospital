"""Verify Megumi supplied dialogue and approved art are imported unchanged."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text())
base='research/character_references/kariya_megumi_2026-10-22/'
a=read(base+'authoring_v2/data/staff/nurse_kariya_megumi/dialogue_authoring.json')
p=read('data/staff/nurse_kariya_megumi/profile.json')
t=read('data/staff/nurse_kariya_megumi/time_events.json')
en=read('data/localization/en.json')['strings']
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
cn=set(strings([p,t]));eng=set(v for k,v in en.items() if 'nurse_kariya_megumi' in k)
rows=list(pairs(a))+list(zip(a['preop_graphic_wrapper']['zh_CN'].values(),a['preop_graphic_wrapper']['en'].values()))
for zh,e in rows:assert zh in cn and e in eng,(zh,e)

r=read('data/staff/nurse_kariya_megumi/relationship.json')
assert not r['met'] and r['level']==0
assert all(s['content_status']=='planned' for s in r['rank_slots'])
assert [s['min_familiarity'] for s in r['rank_slots'][:3]] == [10,25,40]
assert read('data/staff/nurse_kariya_megumi/bundle.json')['character_events']=='events.json'
assert p['familiarity_rules']['base']==1.1
assert p['skills']==dict(surgery=6,diagnostics=39,teamwork=49,patient_care=55,instrument_handling=26,calmness=18)
import hashlib
assets=read('data/staff/nurse_kariya_megumi/assets_manifest.json')['sources']
assert len(assets)==19
for asset in assets:
 source=ROOT/'research/character_references/kariya_megumi_2026-10-22/generated'/asset['source'].split('/generated/')[1]
 assert hashlib.sha256(source.read_bytes()).hexdigest()==asset['sha256']
 assert hashlib.sha256((ROOT/asset['target']).read_bytes()).hexdigest()==asset['sha256']
print(f'PASS: {len(rows)} supplied CN/EN pairs verbatim; {len(assets)} approved art files unchanged; confirmed stats; initially unmet; Lv0 registered')
