"""Compare the approved source, runtime CN, English review, and staged assets."""
import hashlib,json,re
from pathlib import Path
R=Path(__file__).resolve().parents[1]
S=R/'docs/source/serika_lv1'
def read(p):return json.loads(p.read_text())
p=S/'HOSHIMI_MISONO_SERIKA_LV1_PLEASE_CROSS_OUT_MY_NAME_CODEX_READY_V1.md'
assert hashlib.sha256(p.read_bytes()).hexdigest()==read(S/'user_decisions_2026-10-26.json')['sha256']
rows=re.findall(r'^\*\*(S\d+-\d+)｜([^：]+)：\*\*(.*)$',p.read_text(),re.M)
e=read(R/'data/staff/doc_serika/lv1_events.json')[0]
review=read(S/'lv1_bilingual_review.json');en=read(R/'data/localization/en.json')['strings']
assert len(rows)==len(e['nodes'])==len(review)==85
assert [sum(s.startswith(f'S0{i}') for s,_,_ in rows) for i in range(1,4)]==[20,29,36]
for i,((sid,speaker,text),n,rv) in enumerate(zip(rows,e['nodes'],review)):
 assert n['id']==sid.lower().replace('-','_') and n['text']==text==rv['zh_CN']
 assert n['speaker_label']==speaker==rv['speaker_zh_CN']
 assert n['speaker']==('player' if speaker=='坂口隆司' else 'actor' if speaker in ['御園芹香','南条小夜香'] else 'narrator')
 pre=f"collections.character_events.{e['id']}.nodes.{n['id']}"
 assert en[pre+'.text']==rv['en'] and en[pre+'.speaker_label']==rv['speaker_en']
 assert not re.search(r'[\u3400-\u9fff]',rv['en'])
 assert n['background_id']==('shared_doctors_office' if sid.startswith('S02') else 'diagnostics')
 assert [p['id'] for p in n['event_portraits']]==(['doc_serika','doc_sayaka'] if sid.startswith('S02') else ['doc_serika'])
 for art in n['event_portraits']:assert (R/art['path']).is_file()
 c=n['choices'];assert len(c)==1 and c[0]['effects']=={'affection':0,'familiarity':0} and c[0]['flags']==[]
 assert c[0]['next']==(e['nodes'][i+1]['id'] if i<84 else '@end')
assert e['minutes']==30 and e['conditions']['min_familiarity']==10
assert read(R/'data/staff/doc_serika/relationship.json')['rank_slots'][0]['event_id']==e['id']
cg=read(R/'research/imports/serika_lv1_cg_2026-10-26.json')
assert [n['id'] for n in e['nodes'] if n.get('cg_path')]==cg['node_ids']==['s01_17','s01_18','s01_19','s01_20']
assert e['gallery']['path']==cg['target']
assert hashlib.sha256((R/cg['source']).read_bytes()).hexdigest()==cg['sha256']==hashlib.sha256((R/cg['target']).read_bytes()).hexdigest()
assert all(n['cg_path']==cg['target'] and n['cg_fit']=='cover' for n in e['nodes'] if n.get('cg_path'))
print('SERIKA LV1 SOURCE AUDIT: 85 exact Chinese nodes, speakers, order and punctuation; 85 English counterparts; 3 scenes; existing assets; one final 30-minute settlement.')
