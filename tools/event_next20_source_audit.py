"""Independent source mapping; production data is read only."""
import json,re,io,contextlib,hashlib
from pathlib import Path
from staff_bundles import load_staff_bundles
R=Path(__file__).resolve().parents[1];Q=R/'docs/qa/event_batch_next20_groups_2026-10-27'
read=lambda p:json.loads(Path(p).read_text())
c,_=load_staff_bundles(R/'data',{'index':'staff/index.json'});events={e['id']:e for e in c['character_events']};steps={e['id']:e for e in c['special_event_steps']}
for p in (R/'data/events/special_event_steps').glob('*.json'):
 d=read(p)
 if isinstance(d,list):
  for e in d:
   if isinstance(e,dict) and 'nodes' in e:steps[e['id']]=e
scope=read(Q/'scope.json');sources={};mapping={};audit_results=[]
def remember(eid,nid,who,text,p,expression=None):
 p=Path(p);p=p if p.is_absolute() else R/p
 sources[str(p)]=hashlib.sha256(p.read_bytes()).hexdigest()
 mapping.setdefault(eid,{})[nid]={'speaker':who,'text':text,'source':str(p),'expression':expression}
def audit(name):
 p=R/'tools'/name;ns={'__file__':str(p),'__name__':'qa_source'};buf=io.StringIO();err=''
 try:
  with contextlib.redirect_stdout(buf):exec(compile(p.read_text(),str(p),'exec'),ns)
 except Exception as ex:err=f'{type(ex).__name__}: {ex}'
 audit_results.append({'script':name,'error':err,'stdout':buf.getvalue()});return ns
v=audit('sayaka_v2_source_audit.py')
for e in v['events']:
 for n in e['nodes']:
  who,t=v['lines'][int(n['id'][3:])];remember(e['id'],n['id'],who.split('｜')[-1],t,v['SOURCE'])
for name in ['sayaka_lv2_source_audit.py','sayaka_lv3_source_audit.py']:
 v=audit(name);e=v['event'];p=R/('docs/source/sayaka_lv2_pacing_v2_draft.md' if 'lv2' in name else 'docs/source/sayaka_lv3_pacing_v2_draft.md')
 for n in e['nodes']:
  nid=n['id']
  number=next((i for i in v['lines'] if v['nid'](i)==nid),None)
  if nid.startswith('scene_01_'):number=62
  if nid=='lv3_v2_94_haru':number=94
  if number is not None:
   who,t=v['lines'][number];remember(e['id'],nid,who,t,p)
v=audit('sayaka_lv4_event_test.py');p=v['SOURCE'];roles={'actor':'南条小夜香','player':'坂口隆司','narrator':'旁白'}
chunks=[('## 2. Scene 01','## 3. Scene 02'),('## 3. Scene 02','## 4. Scene 03'),('## 4. Scene 03','### Scene 04-A'),('### Scene 04-A','### Scene 04-B'),('### Scene 04-B','### Scene 04-C'),('### Scene 04-C','## 5. Scene 05'),('## 5. Scene 05','## 6. Scene 06'),('## 6. Scene 06','## 7. Scene 07'),('## 8. Scene 08','## 9. Scene 09'),('## 9. Scene 09','## 10. Scene 10'),('## 10. Scene 10','## 11. Scene 11')]
for eid,expected in [('sayaka_lv4_hotel_date',[r for a,b in chunks for r in v['source_lines'](a,b)]),('sayaka_lv4_hospital_callback',v['source_lines']('## 12. Scene 12','## 13. 美术资产交接'))]:
 for n,(who,t) in zip(events[eid]['nodes'],expected):remember(eid,n['id'],roles[who],t,p)
v=audit('sayaka_lv5_source_test.py');seen=set()
for m in v['authored']:
 sid,metadata,body=m.groups();key=sid.lower().replace('-','_');nid=key+'_tail01' if key in seen else key;seen.add(key);who,t=body.split('：',1)
 p='docs/sources/HOSHIMI_SAYAKA_LV5_A02_A03_V3_2_USER_AS_IS_PATCH.md' if key.startswith(('a02_','a03_')) else 'docs/sources/HOSHIMI_NANJOU_SAYAKA_LV5_V3_FULL_CN_REVIEW.md'
 remember('sayaka_lv5_part_'+key[0],nid,who,t,p)
for name in ['satsuki_intro_audit.py','ishigami_intro_audit.py','megumi_intro_audit.py','rumi_shiori_intro_audit.py','saeko_authoring_audit.py','serika_source_audit.py','serika_radiology_source_audit.py']:
 v=audit(name)
 if name=='satsuki_intro_audit.py':
  for n,(who,t) in zip(v['e']['nodes'],v['rows']):remember(v['e']['id'],n['id'],who,t[1:-1] if who=='旁白' else t,v['b']/'source_cn.md')
 elif name in ['ishigami_intro_audit.py','megumi_intro_audit.py']:
  i=0;p=(v['b'] if 'b' in v else v['base'])/'source_cn.md'
  for n in v['e']['nodes']:
   m=re.match(r'\*\*(.+?)：\*\*(.*)',v['rows'][i]);who,t=m.groups() if m else ('旁白',v['rows'][i]);i+=1
   if name=='ishigami_intro_audit.py' and i in [12,65]:t+='\n\n'+v['rows'][i];i+=1
   remember(v['e']['id'],n['id'],who,t,p)
 elif name=='rumi_shiori_intro_audit.py':
  for num,line in v['source']:
   who,t=line.split('：',1);remember(v['event']['id'],'rs0_'+num,who,t,v['SOURCE'])
 elif name=='saeko_authoring_audit.py':
  for n,(who,t) in zip(v['e']['nodes'],v['rows']):remember(v['e']['id'],n['id'],who,t,R/v['b']/'authoring_v1/HOSHIMI_HIKAMI_SAEKO_LV0_CODEX_READY_V1.md')
 elif name=='serika_source_audit.py':
  for sid,who,t in v['rows']:remember('serika_lv0_'+sid[0].lower(),sid.lower().replace('-','_'),who,t,v['S']/'HOSHIMI_MISONO_SERIKA_LV0_FOUR_STAGE_CN_CODEX_READY_V1.md')
 else:
  p=v['S']/'HOSHIMI_MISONO_SERIKA_RADIOLOGY_D01_D15_CODEX_READY_V1.md'
  for sid,who,t in v['rows']:remember('serika_radiology_'+sid[:3].lower(),sid.lower().replace('-','_'),who,t,p)
  for sid,who,t in re.findall(r'^\*\*(D\d\d-OPEN-TEXT)｜([^：]+)：\*\* 旁白：(.+)$',v['source'],re.M):remember('serika_radiology_'+sid[:3].lower(),sid.lower().replace('-','_'),'旁白',t,p)
v=audit('itsumi_intro_audit.py')
for sid,stage,who,expr,line in v['cn']:
 e=next(e for e in v['events'] if any(n['id']==sid.lower().replace('-','_') for n in e['nodes']))
 t='「你说的那位后辈，在吗？」' if sid=='ITS-F-004' else line.split('：',1)[1]
 remember(e['id'],sid.lower().replace('-','_'),who,t,R/'research/character_references/sonoda_itsumi_2026-10-21/lv0/author_script.md',expr)
p=R/'docs/design/HOSHIMI_SATSUKI_LV3_WRONG_PATIENT_APPENDectomy_V3_FORMATTED.md';raw=p.read_text()
for scene,block in re.findall(r'^# \d+\. (SCENE \d+|END BEAT)\n(.*?)(?=^# \d+\.|\Z)',raw,re.M|re.S):
 sn=23 if scene=='END BEAT' else int(scene.split()[-1])
 for bn,who,body in re.findall(r'^### (\d+)\s*\n\s*\*\*([^*]+)\*\*\s*\n(.*?)(?=^### |\Z)',block,re.M|re.S):
  lines=[re.sub(r'^>\s?','',x).strip() for x in body.strip().splitlines() if x.strip() and x.strip()!='---']
  t='\n'.join(lines)
  remember('satsuki_lv3_wrong_patient_appendectomy',f's{sn:02}_{int(bn):03}','旁白' if who=='Narration' else who,t,p)
findings=[]
for row in scope:
 e=events.get(row['id'])
 if e is None:
  e=next(x for x in read(R/row['file']) if x['id']==row['id']);ns=[n for sid in e['event_chain'] for n in steps[sid]['nodes']]
 else:ns=e['nodes']
 for n in ns:
  ex=mapping.get(row['id'],{}).get(n['id'])
  if ex:
   text=n['text'].get('zh_CN') if isinstance(n['text'],dict) else n['text']
   if text!=ex['text']:findings.append({'event':row['id'],'node':n['id'],'expected':ex['text'],'actual':text,'source':ex['source']})
(Q/'source_expectations.json').write_text(json.dumps(mapping,ensure_ascii=False,indent=2));(Q/'source_findings.json').write_text(json.dumps(findings,ensure_ascii=False,indent=2));(Q/'source_provenance.json').write_text(json.dumps(sources,ensure_ascii=False,indent=2));(Q/'source_audits.json').write_text(json.dumps(audit_results,ensure_ascii=False,indent=2));print('Mapped',sum(map(len,mapping.values())),'nodes;',len(findings),'text differences');print(json.dumps(findings,ensure_ascii=False,indent=2)[:3500])
