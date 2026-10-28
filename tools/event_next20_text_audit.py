"""Check observed pages reconstruct the configured text; independent source audit stays separate."""
from event_next20_observation_audit import *
groups=collections.defaultdict(list)
for row in obs:
 groups[row['event'],row['node'],row['locale'],row['replay'],row['route'],row['observation_log']].append(row)
findings=[];passed=set();failed={}
for key,rows in groups.items():
 eid,nid,loc,replay,route,log=key;n=nodes[eid][nid];e=events[eid]
 if n.get('presentation')=='stage':continue
 text=n.get('text','');text=text.get(loc,text.get('zh_CN','')) if isinstance(text,dict) else text
 if loc=='en':
  prefix=f'collections.character_events.{eid}.nodes.{nid}.text'
  if 'event_chain' in e:
   sid=next(s for s in e['event_chain'] if nid in {n['id'] for n in steps[s]['nodes']});prefix=f'collections.special_event_steps.{sid}.nodes.{nid}.text'
  text=en.get(prefix,text)
 bypage={r['page']:r['body'] for r in rows};actual=''.join(bypage[x] for x in sorted(bypage))
 k=(eid,nid,loc,replay)
 if norm(actual)==norm(text):passed.add(k)
 else:failed[k]={'event':eid,'node':nid,'locale':loc,'replay':replay,'presentation':n.get('presentation','legacy'),'expected':text,'observed':actual,'source':'configuration, not independent authoring source'}
findings=[v for k,v in failed.items() if k not in passed]
(Q/'text_audit.json').write_text(json.dumps({'verified_node_modes':len(passed),'findings':findings},ensure_ascii=False,indent=2))
print('Configured text reconstruction',len(passed),'findings',len(findings),collections.Counter(x['presentation'] for x in findings))
