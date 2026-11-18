"""Targeted V1.3 import; preserve existing profile, assets and events."""
import json,re
from pathlib import Path
R=Path(__file__).resolve().parents[1]
def read(p):return json.loads((R/p).read_text())
def write(p,v):(R/p).write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
a,b=[json.loads(s) for s in re.findall(r'```json\s*(.*?)```',(R/'research/source_scripts/HOSHIMI_AIZAWA_MAKI_DOCTOR_DATA_AND_DIALOGUE_SCHEMA_V1_3.md').read_text(),re.S)]
correction=a['surgery_proficiency_and_team_dialogue']['mismatch_correction_limited']
p=read('data/staff/doc_maki/profile.json');p['team_dialogue']['intraoperative_correction']=correction['zh_CN'];write('data/staff/doc_maki/profile.json',p)
d=a['sunday_date_data']['dialogue'];venues={'大型书店':'bookstore','植物园温室':'botanical_garden'}
profile={'id':'date_doc_maki','staff_id':'doc_maki','can_date':True,'minimum_level':0,'minimum_familiarity':10,'casual_outfit':'casual','preferred_locations':list(venues.values()),'disliked_locations':[], 'hotel_unlock_level':4,'always_accept':False,'familiarity_acceptance_bonus':False,'acceptance_chance_by_level':{'0':60,'2':80,'3':92,'4':100},'invite_rejection':{'text':d['rejected']['zh_CN']},'dialogue':{'accepted':{'text':d['accepted']['zh_CN']},'satisfied':{'text':d['satisfied']['zh_CN']},'favorites':[{'id':v,'text':d['special_satisfied_venues'][k]['zh_CN']} for k,v in venues.items()]}}
write('data/staff/doc_maki/date_profiles.json',[profile]);bundle=read('data/staff/doc_maki/bundle.json');bundle['date_profiles']='date_profiles.json';write('data/staff/doc_maki/bundle.json',bundle)
for lang in ['zh_CN','en']:
 p=f'data/localization/{lang}.json';loc=read(p);s=loc['strings'];s['collections.staff.doc_maki.team_dialogue.intraoperative_correction']=correction[lang];prefix='collections.date_profiles.date_doc_maki.'
 s[prefix+'invite_rejection.text']=d['rejected'][lang]
 for k in ['accepted','satisfied']:s[prefix+'dialogue.'+k+'.text']=d[k][lang]
 for k,v in venues.items():s[prefix+'dialogue.favorites.'+v+'.text']=d['special_satisfied_venues'][k][lang]
 write(p,loc)
