"""Import approved Maki V1.1 base staff data; does not author events."""
from pathlib import Path
import json,re,hashlib,sys,shutil
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'research/source_scripts/HOSHIMI_AIZAWA_MAKI_DOCTOR_DATA_AND_DIALOGUE_SCHEMA_V1_1.md'
def write(path,value):
 path.parent.mkdir(parents=True,exist_ok=True);path.write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n')
def build():
 profile_source,dialogue=[json.loads(x) for x in re.findall(r'```json\s*(.*?)```',SOURCE.read_text(),re.S)]
 c=profile_source['confirmed'];p=ROOT/'data/staff/doc_maki';ready=json.loads((ROOT/'research/character_intake/doc_maki/ready_assets.json').read_text())
 profile={k:c[k] for k in ['name','age','profession','specialty','rank','personality','appearance','skills','dialogue_style','gender','team_category']}
 profile.update(id='doc_maki',surgical_roles=['assistant_surgeon'],allowed_team_roles=['assistant_surgeon'],surgery_proficiency='limited',staff_unlock_event='maki_lv0_onboarding',flags=[],event_history=[],presence={'fixed_locations':['lounge'],'random_locations':[],'rooftop_enabled':True},familiarity_rules={'base':1.0},visuals={'color':'929071','default_outfit':'white_coat','outfits':['casual','interview','white_coat','sterile'],'portraits':ready['portraits']},team_dialogue={k:v['zh_CN'] for k,v in dialogue['team_dialogue'].items()},authored_dialogue={'surgical_assistant_dialogue.offer_accept':[dialogue['team_dialogue']['assignment']],'surgical_assistant_dialogue.routine_assist':[dialogue['team_dialogue']['intraoperative']]})
 profile['visuals']['intraoperative_avatar']={'portrait_key':'intraoperative_avatar/neutral','target_path':'assets/characters/intraoperative_staff_avatars_v1/doc_maki/neutral.png','required_for':['operative_field_hud'],'status':'needed'}
 avatar=profile['visuals']['intraoperative_avatar']
 if (ROOT/avatar['target_path']).is_file():
  avatar['status']='ready';profile['visuals']['portraits'][avatar['portrait_key']]=avatar['target_path']
 rel={'source_id':'player','target_id':'doc_maki',**c['relationship_initial_values'],'flags':[],'event_history':[],'met':False,'rank_history':[],'unlocked_benefits':[],'rank_slots':[{'target_level':i,'event_id':'','content_status':'planned','benefit_id':{4:'unlock_intimacy_events',5:'unlock_clinical_practice_patient'}.get(i,''),'min_familiarity':0,'cooldown_days':3,'special_requirements':[]} for i in range(1,6)]}
 chats=[{'id':r['id'],'location_id':r['location_id'],'label':r['label']['zh_CN'],'actor_id':'doc_maki','responses':[x['zh_CN'] for x in r['responses']],'minutes':30,'repeatable':True} for r in dialogue['idle_chats']]
 cg={'id':'role_cg_doc_maki_assistant_surgeon','staff_id':'doc_maki','role_id':'assistant_surgeon','title':dialogue['first_assignment_cg']['title']['zh_CN'],'caption':dialogue['first_assignment_cg']['caption']['zh_CN'],'path':'assets/events/staff_surgery_v1/doc_maki/assistant_confirmation.png'}
 target=ROOT/cg['path'];target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/ready['first_assignment_cg'],target)
 placeholders_path=ROOT/'data/relationships/relationship_activity_placeholders.json'
 placeholders=json.loads(placeholders_path.read_text())
 for row in placeholders:
  if 'doc_maki' not in row['eligible_staff_ids']:row['eligible_staff_ids'].append('doc_maki')
 write(placeholders_path,placeholders)
 bundle={'schema_version':1,'id':'doc_maki','profile':'profile.json','relationship':'relationship.json','character_events':'events.json','time_events':'time_events.json','role_rewards':'role_rewards.json'}
 for name,data in [('profile.json',profile),('relationship.json',rel),('time_events.json',chats),('role_rewards.json',[cg]),('bundle.json',bundle)]:write(p/name,data)
 if not (p/'events.json').exists():write(p/'events.json',[])
 index_path=ROOT/'data/staff/index.json';index=json.loads(index_path.read_text());entry='doc_maki/bundle.json'
 if entry not in index:index.append(entry)
 write(index_path,index)
 for lang in ['zh_CN','en']:
  path=ROOT/f'data/localization/{lang}.json';locale=json.loads(path.read_text());strings=locale['strings']
  for field in ['name','specialty','rank','personality','appearance','dialogue_style']:
   strings[f'collections.staff.doc_maki.{field}']=c[field] if lang=='zh_CN' else c['name_en' if field=='name' else field+'_en']
  for field,value in dialogue['team_dialogue'].items():strings[f'collections.staff.doc_maki.team_dialogue.{field}']=value[lang]
  for row in dialogue['idle_chats']:
   prefix='collections.time_events.'+row['id'];strings[prefix+'.label']=row['label'][lang]
   for i,t in enumerate(row['responses']):strings[f'{prefix}.responses.{i}']=t[lang]
  for field in ['title','caption']:strings[f'collections.staff_role_cg_rewards.{cg["id"]}.{field}']=dialogue['first_assignment_cg'][field][lang]
  write(path,locale)
 write(ROOT/'research/imports/maki_staff_v1_1.json',{'source':str(SOURCE.relative_to(ROOT)),'source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'actor_id':'doc_maki','unlock_event':'maki_lv0_onboarding','scope':'base staff only; no authored Lv0–Lv5 events','proficiency_mapping':'limited adopted as implementation choice from supplied recommendation','rank_slots':'planned with unspecified familiarity, standard 3-day cooldown and inactive Lv4/Lv5 benefit placeholders; no authored events','inactive_content':['Lv0 metadata retained in source only','situational intraoperative candidate retained in source only'],'dialogue_changes':[]})
if __name__=='__main__':build()
