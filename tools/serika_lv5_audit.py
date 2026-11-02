#!/usr/bin/env python3
"""Exact source, bilingual records, schema, resources and all eight choice paths."""
import itertools,json,re
from pathlib import Path
from jsonschema import Draft202012Validator
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text())
checks=0;failures=[]
def check(ok,msg):
 global checks
 checks+=1
 if not ok:failures.append(msg)
cn=read('docs/sources/serika_lv5/locked_cn.json');en=read('docs/sources/serika_lv5/approved_en.json')
src=(ROOT/'docs/sources/serika_lv5/HOSHIMI_MISONO_SERIKA_LV5_LAY_DOWN_BURDEN_CN_CODEX_READY_V1.md').read_text()
parsed=[dict(id=m[1],speaker=m[2],text=m[3].strip()) for m in re.finditer(r'\*\*(S\d\d-\d{3}(?:[AB]-[12])?)【([^】]+)】\*\*([^\n]*)',src)]
check(parsed==cn,'Source lock unchanged')
e=read('data/staff/doc_serika/lv5_events.json')[0];nodes={n['id']:n for n in e['nodes']}
s=read('data/schemas/content.schema.json');v=Draft202012Validator({'$ref':'#/$defs/character_event','$defs':s['$defs']})
for err in v.iter_errors(e):check(False,'Schema '+str(err))
check(len(cn)==214 and len(nodes)==214 and len(en)==211,'214 records / 211 prose')
check(e['minutes']==60 and e['category']=='rank_up' and e['target_level']==5,'Only Lv5 and 60 minutes')
bgs={b['id'] for b in read('data/backgrounds.json')}
portraits=read('data/staff/doc_serika/profile.json')['visuals']['portraits']
for row,n in zip(cn,e['nodes']):
 check(n['id']==row['id'].lower().replace('-','_') and n['text']==row['text'],'Source ID/text '+row['id'])
 if row['text']:
  role='player' if row['speaker']=='坂口隆司' else 'narrator' if row['speaker']=='旁白' else 'actor'
  check(n['speaker']==role and n['speaker_label']==row['speaker'],'Speaker '+row['id'])
  check(n['actor_id']==('nurse_yui' if row['speaker']=='朝仓美幸' else 'doc_serika'),'Actor '+row['id'])
 else:check(n['presentation']=='choice' and 'speaker_label' not in n and len(n['choices'])==2,'Choice-only no dev prose')
 check(n['background_id'] in bgs,'Background '+n['id'])
 expected_cg=''
 for scene,first,last,filename in [('s02',37,44,'cg01_courtyard_call.png'),('s03',44,55,'cg02_cafe_reconciliation.png'),('s04',71,72,'cg03_night_walk.png')]:
  if n['id'].startswith(scene+'_') and n['id'][4:].isdigit() and first<=int(n['id'][4:])<=last:expected_cg='assets/events/serika_lv5_v1/'+filename
 check(n.get('cg_path','')==expected_cg,'Exact CG range '+n['id'])
 if expected_cg:
  check((ROOT/expected_cg).is_file() and n.get('cg_fit')=='contain' and n.get('hide_portrait') is True,'CG resource, aspect ratio and portrait suppression '+n['id'])
 paths=[x['path'] for x in n['event_portraits']] if 'event_portraits' in n else [portraits[n['outfit']+'/'+n['expression']]]
 for p in paths:check((ROOT/p).is_file(),'Resource '+p)
 if n['id'].startswith('s03'):
  check({x['id'] for x in n['event_portraits']}=={'doc_serika','nurse_yui'} and n['speaker']!='player','Cafe cast')
 for c in n['choices']:check(c['effects']=={'affection':0,'familiarity':0} and c['flags']==[] and set(c)=={'id','label','next','effects','flags'},'No branch side effects')
 for locale in ['zh_CN','en']:
  strings=read(f'data/localization/{locale}.json')['strings'];p=f'collections.character_events.{e["id"]}.nodes.{n["id"]}'
  if row['text']:
   check(strings.get(p+'.text')==(row['text'] if locale=='zh_CN' else en[row['id']]),'Localized source '+locale+row['id'])
   check(bool(strings.get(p+'.speaker_label')),'Localized speaker')
  for c in n['choices']:check(bool(strings.get(p+'.choices.'+c['id']+'.label')),'Localized choice')
  if locale=='en':
   for key,value in strings.items():
    if key.startswith(p+'.'):check(not re.search('[\u3400-\u9fff]',value),'EN residue '+key)
for route in itertools.product([0,1],repeat=3):
 current=e['start'];seen=[];choice=0;prose=0
 while current!='@end':
  check(current not in seen,'Cycle');seen.append(current);n=nodes[current]
  if n['presentation']=='choice':idx=route[choice];choice+=1
  else:idx=0;prose+=1
  current=n['choices'][idx]['next']
 check(prose==205 and choice==3 and len(seen)==208,'205 prose plus three controls')
 check(seen[-1]=='s04_072','Final row unique settlement')
print(f'SERIKA LV5 AUDIT: {checks} checks, {len(failures)} failures')
for failure in failures:print(failure)
raise SystemExit(bool(failures))
