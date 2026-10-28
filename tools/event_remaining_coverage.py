import json,sys,collections
from pathlib import Path
from staff_bundles import load_staff_bundles
R=Path(__file__).resolve().parents[1];Q=R/'docs/qa/remaining_complete_events_2026-10-27'
read=lambda p:json.loads(p.read_text())
c,_=load_staff_bundles(R/'data',{'index':'staff/index.json'});events={x['id']:x for x in c['character_events']+c['special_events']};steps={x['id']:x for x in c['special_event_steps']}
for kind in ['special_events','special_event_steps']:
 p=R/'data/events'/kind
 for f in read(p/'index.json')['files']:
  for e in read(p/f):(events if kind=='special_events' else steps)[e['id']]=e
scope=read(Q/'scope.json');seen=collections.defaultdict(set);issues=[];pages=0
for folder in ['native_recheck','content_final','supplemental','branches_final']:
 p=Q/folder/'pages.jsonl'
 if p.exists():
  for l in p.read_text().splitlines():
   if not l.strip():continue
   try:r=json.loads(l)
   except json.JSONDecodeError:continue
   seen[r['event'],r['locale'],r['replay']].add(r['node']);pages+=1
 p=Q/folder/'native.log'
 if p.exists():
  for l in p.read_text().splitlines():
   if l.startswith('QA_ISSUE '):issues.append(json.loads(l[9:]))
rows=[]
for r in scope:
 e=events[r['id']];nodes=e.get('nodes',[]) or [n for sid in e['event_chain'] for n in steps[sid]['nodes']];ids={n['id'] for n in nodes}
 modes=[]
 for locale in ['zh_CN','en']:
  for replay in [False,True]:
   observed=seen[r['id'],locale,replay];modes.append({'locale':locale,'replay':replay,'observed':len(observed&ids),'missing':sorted(ids-observed)})
 rows.append({**r,'defined_nodes':len(nodes),'unique_node_ids':len(ids),'modes':modes})
out={'events':len(rows),'defined_nodes':sum(r['defined_nodes'] for r in rows),'page_observations':pages,'issues':issues,'coverage':rows}
(Q/'COVERAGE.json').write_text(json.dumps(out,ensure_ascii=False,indent=2))
print('events',len(rows),'defined nodes',out['defined_nodes'],'pages',pages,'issue kinds',dict(collections.Counter(i['kind'] for i in issues)))
for r in rows:
 print(r['id'],str(r['defined_nodes']),','.join(str(m['observed']) for m in r['modes']))
