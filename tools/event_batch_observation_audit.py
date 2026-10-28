"""Audit observed native UI pages against independent source ownership and asset config."""
import json,re,collections,os
from pathlib import Path
from staff_bundles import load_staff_bundles
R=Path(__file__).resolve().parents[1];Q=Path(os.environ.get('HOSHIMI_QA_DIR',str(R/'docs/qa/event_batch_first20_rows_2026-10-27')))
read=lambda p:json.loads(p.read_text())
c,_=load_staff_bundles(R/'data',{'index':'staff/index.json'})
events={e['id']:e for e in c['character_events']+c['special_events']};steps={e['id']:e for e in c['special_event_steps']};people={p['id']:p for p in c['staff']};en=read(R/'data/localization/en.json')['strings'];src=read(Q/'source_expectations.json');scope=read(Q/'scope.json')
nodes={eid:{n['id']:n for n in (e.get('nodes',[]) or [n for sid in e.get('event_chain',[]) for n in steps[sid]['nodes']])} for eid,e in events.items()}
obs=[]
for name in ['pages.jsonl','boundary_pages.jsonl','hiroko_recheck_pages.jsonl']:
 if not (Q/name).exists():continue
 for line in (Q/name).read_text().splitlines():
  try:
   item=json.loads(line);item['observation_log']=name;obs.append(item)
  except json.JSONDecodeError:pass
norm=lambda s:re.sub(r'\s+','',s)
who_actor={'深山佳織':'doc_rei','飯村真奈美':'pharmacist_manami','安琪':'nurse_ange','朝倉美幸':'nurse_yui','七瀬恋':'nurse_haru','神宮寺成美':'doc_aoi','弘子':'nurse_hiroko','城宮明日香':'doc_asuka','藤崎詩織':'doc_shiori'}
issues=[];checks=collections.Counter();seen=collections.defaultdict(set);sequence=collections.defaultdict(list)
for row in obs:
 eid=row['event'];nid=row['node'];loc=row['locale'];n=nodes[eid].get(nid,{})
 seen[eid,loc,row['replay']].add(nid);sequence[eid,loc,row['replay'],row['route'],row['observation_log']].append(nid)
 e=events[eid];special='event_chain' in e
 expected=src.get(eid,{}).get(nid)
 if expected and row['body']:
  who=expected['speaker'].split('｜')[0];body=row['body'].strip();name=None
  if eid=='miyama_02_manga_artist_wrong_patient':
   # Narrative sentences following a speaking turn are correctly narrator pages.
   if not body.startswith(('「','“')) and not (who=='片桐彩子' and n.get('speaker_label')=='片桐彩子' and '脑内' in n.get('text','')):continue
  if who in ['旁白','Narration']:name='Narrator' if loc=='en' else '旁白'
  elif who in ['坂口','坂口隆司']:name=en['protagonist.name'] if loc=='en' else '坂口隆司'
  elif who in who_actor:
   actor=who_actor[who];name=en.get('collections.staff.'+actor+'.name',people[actor]['name']) if loc=='en' else people[actor]['name']
   # Authored short names are valid identity variants, not a demand for full names.
   label=n.get('speaker_label','')
   if label and norm(label) in [norm(who),norm(people[actor]['name'])]:
    label_key=f'collections.character_events.{eid}.nodes.{nid}.speaker_label'
    if special:
     sid=next(s for s in e['event_chain'] if nid in {x['id'] for x in steps[s]['nodes']})
     label_key=f'collections.special_event_steps.{sid}.nodes.{nid}.speaker_label'
    name=en.get(label_key,label) if loc=='en' else label
   if n.get('anonymous_unmet'):name='Nurse' if loc=='en' else '护士'
  elif n.get('speaker_label'):
   name=en.get(f'collections.character_events.{eid}.nodes.{nid}.speaker_label',n['speaker_label']) if loc=='en' else n['speaker_label']
   if special:
    sid=next(s for s in e['event_chain'] if nid in {x['id'] for x in steps[s]['nodes']})
    name=en.get(f'collections.special_event_steps.{sid}.nodes.{nid}.speaker_label',n['speaker_label']) if loc=='en' else n['speaker_label']
  if name:
   checks['independent_source_name_pages']+=1
   if norm(name) not in [norm(x) for x in row['names']]:issues.append({'kind':'source_speaker_mismatch','event':eid,'node':nid,'locale':loc,'page':row['page'],'replay':row['replay'],'expected':name,'actual':row['names'],'body':row['body'],'source':expected['source']})
 # Configuration fidelity is distinct from source emotion correctness.
 cg=n.get('cg_path','');expected_paths=[];fallback=[]
 if cg:expected_paths.append('res://'+cg)
 if (not cg or n.get('cg_portrait_overlay')) and not n.get('hide_portrait'):
  if 'event_portraits' in n:expected_paths += ['res://'+p['path'] for p in n['event_portraits']]
  elif n.get('portrait_path'):expected_paths.append('res://'+n['portrait_path'])
  elif 'cast_actor_ids' not in n:
   aid=n.get('actor_id',e.get('actor_id',''));p=people.get(aid,{})
   if p:
    outfit=n.get('outfit',e.get('outfit',p['visuals']['default_outfit']));key=outfit+'/'+n.get('expression','neutral');path=p['visuals']['portraits'].get(key)
    if not path:
     fallback.append(key);path=p['visuals']['portraits'].get(outfit+'/neutral')
    if path:expected_paths.append('res://'+path)
 actual=[p['path'] for p in row['visuals']]
 checks['configured_visual_pages']+=1
 for path in expected_paths:
  if path not in actual:issues.append({'kind':'configured_texture_mismatch','event':eid,'node':nid,'locale':loc,'replay':row['replay'],'expected':path,'actual':actual})
 for key in fallback:issues.append({'kind':'expression_fallback','event':eid,'node':nid,'locale':loc,'expression':key})
# Keep unique evidence, not thousands of duplicate route reports.
unique={json.dumps({k:v for k,v in i.items() if k not in ['body','page']},sort_keys=True,ensure_ascii=False):i for i in issues}
coverage=[]
for r in scope:
 for loc in ['zh_CN','en']:
  for replay in [False,True]:
   allnodes=set(nodes[r['id']]);actual=seen[r['id'],loc,replay]
   coverage.append({'event':r['id'],'locale':loc,'replay':replay,'defined_nodes':len(allnodes),'observed_nodes':len(actual),'unobserved':sorted(allnodes-actual)})
for key,seq in sequence.items():
 eid,loc,replay,route,log=key
 for a,b in zip(seq,seq[1:]):
  if a==b:continue
  choices=nodes[eid][a].get('choices',[]);targets=[x.get('next') for x in choices]
  if b not in targets and not any(str(x).startswith('@') for x in targets):issues.append({'kind':'unexpected_graph_transition','event':eid,'locale':loc,'replay':replay,'from':a,'to':b,'configured_targets':targets})
report={'checks':dict(checks),'unique_issues':list(unique.values()),'coverage':coverage,'graph_transition_issues':[i for i in issues if i['kind']=='unexpected_graph_transition']}
(Q/'observation_audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
print('Observed pages',len(obs),'Checks',dict(checks),'Unique findings',collections.Counter(i['kind'] for i in unique.values()))
print('Graph transition findings',len(report['graph_transition_issues']))
