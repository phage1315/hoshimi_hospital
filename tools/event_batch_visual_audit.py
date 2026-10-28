"""Technical comparison of observed paths/geometry only; never edits user images."""
from event_batch_observation_audit import *
import struct
backgrounds={x['id']:x['path'] for x in read(R/'data/backgrounds.json')}
for x in read(R/'data/patients/cameo_patients.json'):people[x['id']]=x
visual_issues=[];total=0
size_cache={}
def size(path):
 if path not in size_cache:
  raw=(R/path).read_bytes()[:24];size_cache[path]=struct.unpack('>II',raw[16:24]) if raw[:8]==b'\x89PNG\r\n\x1a\n' else None
 return size_cache[path]
def portrait(aid,outfit,expression):
 p=people.get(aid,{}).get('visuals',{});o=outfit or p.get('default_outfit','white_coat');paths=p.get('portraits',{});return paths.get(o+'/'+expression,paths.get(o+'/neutral'))
for row in obs:
 e=events[row['event']];n=nodes[e['id']][row['node']];special='event_chain' in e;expected={};geometry={};actual={x['widget']:x for x in row['visuals']};cg=n.get('cg_path')
 bg=n.get('background_id',e.get('background_id'))
 if special:bg=n.get('background_id',next(steps[s]['background_id'] for s in e['event_chain'] if row['node'] in {x['id'] for x in steps[s]['nodes']}))
 if backgrounds.get(bg):expected['SceneBackground']=backgrounds[bg]
 if cg:expected['CharacterEventCG']=cg
 if (not cg or n.get('cg_portrait_overlay')) and not n.get('hide_portrait'):
  if 'event_portraits' in n:
   for p in n['event_portraits']:
    key='EventPortrait_'+p['id'];expected[key]=p['path'];w=p.get('width',390);h=p.get('height',390);geometry[key]=(p['x']-w/2,p.get('bottom',550)-h,w,h)
  elif 'cast_actor_ids' in n:
   for i,aid in enumerate(n['cast_actor_ids']):
    key='EventCast_'+aid;expected[key]=portrait(aid,None,n.get('expression','neutral') if aid==n.get('actor_id') else 'neutral');count=len(n['cast_actor_ids']);geometry[key]=(900+(i-(count-1)/2)*170,180,170,300) if row['replay'] else (490+(i-(count-1)/2)*320,145,300,400)
  elif n.get('portrait_path'):
   path=n['portrait_path'];key='CharacterEventPortrait';expected[key]=path;dims=size(path)
   if dims:
    w,h=dims;scale=min(320/w,460/h)*n.get('portrait_scale',1);w*=scale;h*=scale;geometry[key]=(n.get('portrait_right',1230)-w,n.get('portrait_y',170),w,h)
  else:
   aid=n.get('actor_id',e.get('actor_id','')) if not special else n.get('actor_id','');path=portrait(aid,n.get('outfit',e.get('outfit') if not special else None),n.get('expression','neutral'))
   if path:expected['CharacterPortrait']=path;geometry['CharacterPortrait']=(760,165,450,500)
 if special and not (cg or n.get('portrait_path') or 'event_portraits' in n):
  if n.get('secondary_portrait_path'):expected['SpecialEventSecondaryPortrait']=n['secondary_portrait_path']
  elif n.get('secondary_actor_id'):expected['SpecialEventSecondaryPortrait']=portrait(n['secondary_actor_id'],n.get('secondary_outfit'),n.get('secondary_expression','neutral'));geometry['SpecialEventSecondaryPortrait']=(400,230,260,365)
 total+=1
 for key,path in expected.items():
  if path and actual.get(key,{}).get('path')!='res://'+path:visual_issues.append({'event':e['id'],'node':n['id'],'locale':row['locale'],'replay':row['replay'],'kind':'path','widget':key,'expected':path,'actual':actual.get(key)})
 for key,rect in geometry.items():
  if key not in actual:continue
  a=actual[key];rect_actual=[a[k] for k in ['x','y','width','height']]
  if any(abs(x-y)>6 for x,y in zip(rect,rect_actual)):visual_issues.append({'event':e['id'],'node':n['id'],'locale':row['locale'],'replay':row['replay'],'kind':'geometry','widget':key,'expected':rect,'actual':rect_actual})
 for key in actual:
  if key in ['CharacterPortrait','CharacterEventPortrait','SpecialEventSecondaryPortrait'] or key.startswith(('EventPortrait_','EventCast_')):
   if key not in expected:visual_issues.append({'event':e['id'],'node':n['id'],'locale':row['locale'],'replay':row['replay'],'kind':'unexpected_portrait','widget':key})
unique={json.dumps(x,sort_keys=True):x for x in visual_issues}
(Q/'visual_audit.json').write_text(json.dumps({'page_checks':total,'issues':list(unique.values())},ensure_ascii=False,indent=2));print('Visual geometry/path checks',total,'unique findings',len(unique))
