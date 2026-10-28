"""Check observed GUI page progression and rendered name/content controls."""
import json,collections
from pathlib import Path
Q=Path(__file__).resolve().parents[1]/'docs/qa/event_batch_next20_groups_2026-10-27'
groups=collections.defaultdict(list)
for log in ['pages.jsonl','variant_pages.jsonl','lv4_recheck_pages.jsonl','boundary_pages.jsonl','boundary_recheck_pages.jsonl','return_pages.jsonl']:
 for line in (Q/log).read_text().splitlines():
  try:r=json.loads(line)
  except json.JSONDecodeError:continue
  groups[r['event'],r['locale'],r['replay'],r['route'],log].append(r)
issues=[];checks=0
for key,rows in groups.items():
 for a,b in zip(rows,rows[1:]):
  checks+=1
  if a['node']==b['node']:
   if b['page']!=a['page']+1:issues.append({'event':key,'node':a['node'],'from':a['page'],'to':b['page'],'issue':'page_skip_or_repeat'})
  elif b['body'] and b['page']!=0:issues.append({'event':key,'node':b['node'],'page':b['page'],'issue':'node_not_started_at_page_zero'})
# Screen labels are actual controls; check stage captions against subtitles.
caption_checks=0
for rows in groups.values():
 for row in rows:
  labels=row.get('labels',[])
  for c in labels:
   if c.get('y')!=175:continue
   for other in labels:
    if other.get('y') not in [139,140,142,145]:continue
    caption_checks+=1
    if c['y']<other['y']+other['height'] and c['x']<other['x']+other['width'] and other['x']<c['x']+c['width']:issues.append({'event':row['event'],'node':row['node'],'locale':row['locale'],'issue':'scene_caption_overlaps_subtitle'})
r={'page_transition_checks':checks,'caption_geometry_checks':caption_checks,'issues':issues}
(Q/'page_audit.json').write_text(json.dumps(r,ensure_ascii=False,indent=2));print({k:(len(v) if k=='issues' else v) for k,v in r.items()})
