#!/usr/bin/env python3
"""Independent source/speaker/order/localization audit of Serika's fixed Lv4."""
import hashlib,json,re
from pathlib import Path
R=Path(__file__).resolve().parents[1]
source=R/'docs/source/serika_lv4/HOSHIMI_MISONO_SERIKA_LV4_STAY_CODEX_CN_V1.md'
raw=source.read_text();matches=list(re.finditer(r'^\*\*(S\d{2}-(?:H\d{2}|\d{3}))【([^】]+)】\*\*\s*(.+)$',raw,re.M))
step=json.loads((R/'data/events/special_event_steps/serika_lv4.json').read_text())[0]
ss=json.loads((R/'data/localization/en.json').read_text())['strings']
assert len(matches)==len(step['nodes'])==547
for i,(m,n) in enumerate(zip(matches,step['nodes'])):
 assert n['id']==m[1].lower().replace('-','_')
 assert n['speaker_label']==m[2] and n['text']==m[3].replace('**',''),n['id']
 assert n['choices'][0]['next']==(step['nodes'][i+1]['id'] if i<546 else '@day_end')
 assert len(n['choices'])==1 and not n.get('requirements') and not n['choices'][0].get('effects')
 assert n['presentation']=='authored'
 prefix=f"collections.special_event_steps.{step['id']}.nodes.{n['id']}"
 for suffix in ['text','speaker_label','choices.continue.label']:
  text=ss[prefix+'.'+suffix];assert text.strip() and not re.search('[\u3400-\u9fff]',text)
 for portrait in n['event_portraits']:assert portrait['id']==n['actor_id'] and (R/portrait['path']).is_file()
 assert n['id'] in step['scene_schedule']
from jsonschema import Draft202012Validator
schema=json.loads((R/'data/schemas/content.schema.json').read_text())
for kind,records in [('special_event_step',[step]),('special_event',json.loads((R/'data/events/special_events/serika_lv4.json').read_text())),('background',[b for b in json.loads((R/'data/backgrounds.json').read_text()) if b['id'].startswith('serika_home_')])]:
 for record in records:
  errors=list(Draft202012Validator({'$ref':'#/$defs/'+kind,'$defs':schema['$defs']}).iter_errors(record))
  assert not errors,[(e.json_path,e.message) for e in errors]
# Living-room CG must end before the bedroom transition; preserve all authored text.
embrace_ids={f's06_{i:03}' for i in range(41,84)}
assert {n['id'] for n in step['nodes'] if n.get('cg_path','').endswith('cg01_living_embrace.png')}==embrace_ids
for n in step['nodes']:
 if n['id'] in embrace_ids:
  assert (R/n['cg_path']).is_file() and n['cg_fit']=='contain'
  assert n['hide_portrait'] and not n['event_portraits']
h=[n for n in step['nodes'] if n['id'].startswith('s06_h')]
assert len(h)==44 and h[-1]['exit_blackout_seconds']==1
assert h[30]['choices'][0]['next']=='s06_h32'
print('SERIKA LV4 SOURCE AUDIT: 547/547 CN text, speakers, sequence; 547 complete English nodes; H44 intact.')
print('Source SHA256:',hashlib.sha256(source.read_bytes()).hexdigest())
