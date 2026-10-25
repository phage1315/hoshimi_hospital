"""Audit imported Serika text against the immutable authoring package and art hashes."""
import hashlib,json,re
from pathlib import Path
R=Path(__file__).resolve().parents[1]
S=R/'research/character_references/misono_serika_2026-10-23/authoring_v1_1'
D=R/'data/staff/doc_serika'
def read(p):return json.loads(p.read_text())
source=(S/'HOSHIMI_MISONO_SERIKA_LV0_FOUR_STAGE_CN_CODEX_READY_V1.md').read_text()
rows=re.findall(r'^\*\*([ABCD]-\d+)｜([^：]+)：\*\* (.+)$',source,re.M)
events=read(D/'events.json');nodes=[n for e in events for n in e['nodes']];review=read(S/'lv0_bilingual_review.json')
assert len(rows)==len(nodes)==len(review)==63
locales={l:read(R/f'data/localization/{l}.json')['strings'] for l in ['en','zh_CN']}
for (sid,speaker,text),n,rv in zip(rows,nodes,review):
 assert n['text']==rv['zh_CN']==text and n['speaker_label']==rv['speaker_zh_CN']==speaker
 assert n['speaker']==('player' if speaker=='坂口隆司' else 'actor' if speaker in ['御園芹香','朝倉美幸'] else 'narrator')
 if speaker=='御園芹香':assert n['actor_id']=='doc_serika'
 if speaker=='朝倉美幸':assert n['actor_id']=='nurse_yui'
 pre=f"collections.character_events.serika_lv0_{sid[0].lower()}.nodes.{n['id']}"
 assert locales['en'][pre+'.text']==rv['en'] and locales['zh_CN'][pre+'.text']==text
for e in events:
 assert e['minutes']==0
 for i,n in enumerate(e['nodes']):
  c=n['choices'];assert len(c)==1 and c[0]['effects']=={'affection':0,'familiarity':0} and not c[0]['flags']
  assert c[0]['next']==(e['nodes'][i+1]['id'] if i+1<len(e['nodes']) else '@end')
assert [e['category'] for e in events]==['contextual']*3+['introduction']
p=read(D/'profile.json');assert p['skills']==read(S/'user_confirmed_data.json')['skills'] and p['age']==25
intake=(S/'HOSHIMI_MISONO_SERIKA_STAFF_INTAKE_CN_EN_V1_REVIEW.md').read_text()
work=re.findall(r'^\| (选为助手|上台确认|正常手术配合|提醒术野|患者紧张时|手术完成) \| (.+?) \| (.+?) \|$',intake,re.M)
for label,cn,en in work:
 assert cn in list(p['team_dialogue'].values())+p['post_operation_replies']
 assert en in locales['en'].values()
idle=re.findall(r'\d\. \*\*御園芹香：\*\*(.+?)  \n   \*\*EN:\*\* (.+)',intake)
times=read(D/'time_events.json')
assert times[0]['responses']==[x[0] for x in idle]
assert len(times)==1 and times[0]['id']=='serika_imaging_chat'
for a in read(D/'assets_manifest.json')['sources']:
 assert hashlib.sha256((R/a['source']).read_bytes()).hexdigest()==a['sha256']==hashlib.sha256((R/a['target']).read_bytes()).hexdigest()
assert len(read(D/'assets_manifest.json')['sources'])==38
print('PASS: 63 exact VN lines/speakers/order; six work lines, three idle responses; retired random discussion removed; 38 unchanged assets; confirmed skills.')
