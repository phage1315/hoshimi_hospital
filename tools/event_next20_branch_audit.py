from event_next20_observation_audit import *
observed=collections.defaultdict(set)
for (eid,loc,replay,route,log),seq in sequence.items():
 for a,b in zip(seq,seq[1:]):
  if a!=b:observed[eid,loc,replay].add((a,b))
coverage=[]
for row in scope:
 eid=row['id'];edges=set()
 for n in nodes[eid].values():
  for c in n.get('choices',[]):
   if not c.get('next','').startswith('@'):edges.add((n['id'],c['next']))
   if c.get('next_if_choice'):edges.add((n['id'],c['next_if_choice']['next']))
 for loc in ['zh_CN','en']:
  for replay in [False,True]:coverage.append({'event':eid,'locale':loc,'replay':replay,'defined_edges':len(edges),'observed_edges':len(edges & observed[eid,loc,replay]),'unobserved_edges':sorted(edges-observed[eid,loc,replay])})
(Q/'branch_audit.json').write_text(json.dumps(coverage,ensure_ascii=False,indent=2))
print('Unobserved graph edges',sum(len(x['unobserved_edges']) for x in coverage))
