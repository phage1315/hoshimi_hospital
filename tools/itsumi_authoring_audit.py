"""Verify imported Itsumi dialogue verbatim and scope existing cameo edits."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text())
base='research/character_references/sonoda_itsumi_2026-10-21/'
a=read(base+'authoring_v2/data/staff/nurse_sonoda_itsumi/dialogue_authoring.json')
p=read('data/staff/nurse_sonoda_itsumi/profile.json')
t=read('data/staff/nurse_sonoda_itsumi/time_events.json')
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
cn=set(strings([p,t]));eng=set(v for k,v in en.items() if 'nurse_sonoda_itsumi' in k)
rows=list(pairs(a))+list(zip(a['preop_graphic_wrapper']['zh_CN'].values(),a['preop_graphic_wrapper']['en'].values()))
for zh,e in rows:assert zh in cn and e in eng,(zh,e)
# Only authorized title substitutions and visual actor wiring in A and B.
for actor in ['doc_asuka','doc_rei']:
 before=read(base+'cameo_design/'+actor+'_events_before.json');after=read('data/staff/'+actor+'/events.json')
 for e in before:
  if e['id']=='asuka_adjacent_operation_reveal':
   def replace(o):
    if isinstance(o,str):return o.replace('手术室护士长','手术室值班护士').replace('护士长','值班护士')
    if isinstance(o,list):return [replace(v) for v in o]
    if isinstance(o,dict):return {k:replace(v) for k,v in o.items()}
    return o
   e.update(replace(e))
   for n in e['nodes']:
    if n['id'] in ['answer','office_note']:n.update(actor_id='nurse_sonoda_itsumi',outfit='scrubs',hide_portrait=False)
  if actor=='doc_rei':
   for n in e['nodes']:
    if n['id'] in ['m0_0043','m0_0046','m0_0048']:n.update(actor_id='nurse_sonoda_itsumi',outfit='scrubs',hide_portrait=False)
 assert before==after,actor+' unauthorized narrative change'
r=read('data/staff/nurse_sonoda_itsumi/relationship.json')
assert not r['met'] and r['level']==0 and all(s['content_status']=='planned' for s in r['rank_slots'])
assert read('data/staff/nurse_sonoda_itsumi/bundle.json')['character_events'] == 'events.json'
print(f'PASS: {len(rows)} supplied CN/EN pairs verbatim; A/B scoped edits; initially unmet; approved CDEF registered')
