import json,re
from pathlib import Path
from jsonschema import Draft202012Validator
R=Path(__file__).resolve().parents[1]
def read(p):return json.loads((R/p).read_text())
a,b=[json.loads(s) for s in re.findall(r'```json\s*(.*?)```',(R/'research/source_scripts/HOSHIMI_AIZAWA_MAKI_DOCTOR_DATA_AND_DIALOGUE_SCHEMA_V1_3.md').read_text(),re.S)]
d=a['sunday_date_data']['dialogue'];p=read('data/staff/doc_maki/date_profiles.json')[0];schema=read('data/schemas/content.schema.json');v=Draft202012Validator({'$ref':'#/$defs/date_profile','$defs':schema['$defs']});assert not list(v.iter_errors(p))
c=a['surgery_proficiency_and_team_dialogue']['mismatch_correction_limited']
assert read('data/staff/doc_maki/profile.json')['team_dialogue']['intraoperative_correction']==c['zh_CN']
for lang in ['zh_CN','en']:
 s=read(f'data/localization/{lang}.json')['strings'];prefix='collections.date_profiles.date_doc_maki.'
 assert s['collections.staff.doc_maki.team_dialogue.intraoperative_correction']==c[lang]
 assert s[prefix+'invite_rejection.text']==d['rejected'][lang]
 assert p['invite_rejection']['text']==d['rejected']['zh_CN']
 for k in ['accepted','satisfied']:
  assert s[prefix+'dialogue.'+k+'.text']==d[k][lang]
  assert p['dialogue'][k]['text']==d[k]['zh_CN']
 for i,(name,id) in enumerate({'大型书店':'bookstore','植物园温室':'botanical_garden'}.items()):
  assert s[prefix+'dialogue.favorites.'+id+'.text']==d['special_satisfied_venues'][name][lang]
  assert p['dialogue']['favorites'][i]['text']==d['special_satisfied_venues'][name]['zh_CN']
print('MAKI V1.3 SOURCE AUDIT: exact bilingual text and runtime date schema passed')
