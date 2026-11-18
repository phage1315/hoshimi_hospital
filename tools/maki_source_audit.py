"""Compare imported Maki text with the author package, without rewriting it."""
import json,re,hashlib
from pathlib import Path
R=Path(__file__).resolve().parents[1]
def read(p):return json.loads((R/p).read_text())
source=R/'research/source_scripts/HOSHIMI_AIZAWA_MAKI_DOCTOR_DATA_AND_DIALOGUE_SCHEMA_V1_1.md'
profile,dialogue=[json.loads(s) for s in re.findall(r'```json\s*(.*?)```',source.read_text(),re.S)]
p=read('data/staff/doc_maki/profile.json')
assert all(p[k]==v for k,v in profile['confirmed'].items() if k in p and k != "presence")
for lang in ['zh_CN','en']:
 strings=read(f'data/localization/{lang}.json')['strings']
 for key,value in dialogue['team_dialogue'].items():
  assert strings[f'collections.staff.doc_maki.team_dialogue.{key}']==value[lang]
  assert p['team_dialogue'][key]==value['zh_CN']
 for row in dialogue['idle_chats']:
  actual=next(x for x in read('data/staff/doc_maki/time_events.json') if x['id']==row['id'])
  assert actual['responses']==[x['zh_CN'] for x in row['responses']]
  assert strings[f"collections.time_events.{row['id']}.label"]==row['label'][lang]
  for i,value in enumerate(row['responses']):assert strings[f"collections.time_events.{row['id']}.responses.{i}"]==value[lang]
 for key in ['title','caption']:
  assert strings[f'collections.staff_role_cg_rewards.role_cg_doc_maki_assistant_surgeon.{key}']==dialogue['first_assignment_cg'][key][lang]
assert read('research/imports/maki_staff_v1_1.json')['source_sha256']==hashlib.sha256(source.read_bytes()).hexdigest()
assert read('data/staff/doc_maki/events.json')==[]
assert (R/'assets/events/maki_first_assistant_v1/assistant_confirmation.png').read_bytes()==(R/'assets/events/staff_surgery_v1/doc_maki/assistant_confirmation.png').read_bytes()
print('MAKI SOURCE AUDIT: exact profile/dialogue/localization/source/CG checks passed; no events authored')
