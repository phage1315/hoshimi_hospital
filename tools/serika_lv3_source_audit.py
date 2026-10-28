"""208 immutable author entries: one menu option, 207 VN nodes, two end notices."""
import hashlib,json,re
from pathlib import Path
R=Path(__file__).resolve().parents[1];S=R/'docs/source/serika_lv3'
def read(p):return json.loads(p.read_text())
record=read(S/'preflight.json');src=R/record['source'];assert hashlib.sha256(src.read_bytes()).hexdigest()==record['source_sha256']
rows=re.findall(r'^\*\*(S\d+-\d+)｜([^：]+)：\*\*(.*)$',src.read_text(),re.M)
review=read(S/'lv3_bilingual_review.json');e=read(R/'data/staff/doc_serika/lv3_events.json')[0];strings=read(R/'data/localization/en.json')['strings'];assert len(rows)==len(review)==208 and len(e['nodes'])==207
assert rows[0]==('S01-01','周日选项','「独自去走走」')
assert strings['ui.serika.lv3.walk_alone']==review[0]['en'][1:-1]
for i,((sid,who,text),rv) in enumerate(zip(rows,review)):
 assert rv['source_id']==sid and rv['speaker_zh_CN']==who and rv['zh_CN']==text
 if i==0:continue
 n=e['nodes'][i-1];key=f"collections.character_events.{e['id']}.nodes.{n['id']}"
 assert n['id']==sid.lower().replace('-','_') and n['speaker_label']==who and n['text']==text
 assert n['speaker']==('player' if who=='坂口隆司' else 'actor' if who=='御園芹香' else 'narrator')
 assert strings[key+'.text']==rv['en'] and strings[key+'.speaker_label']==rv['speaker_en']
 assert not re.search(r'[\u3400-\u9fff]',rv['en'])
 assert len(n['choices'])==1 and n['choices'][0]['effects']=={'affection':0,'familiarity':0} and not n['choices'][0]['flags']
 assert n['choices'][0]['next']==(e['nodes'][i]['id'] if i<207 else '@end')
 assert all(p['id']=='doc_serika' and (R/p['path']).is_file() and '/casual_winter/' in p['path'] for p in n['event_portraits'])
 assert not any(k in n for k in ['sound_path','video_path'])
assert '【御園芹香 Relationship Lv3 达成】' in src.read_text() and '【解锁：芹香的正常周日约会】' in src.read_text()
assert e['consumes_sunday'] and e['minutes']==0 and e['category']=='rank_up' and e['target_level']==3
slot=read(R/'data/staff/doc_serika/relationship.json')['rank_slots'][2];assert slot['event_id']==e['id'] and slot['min_familiarity']==40 and slot['special_requirements']==record['confirmed_gate_decision']['special_requirements']
assert 'const PREREQUISITES_CONNECTED := true' in (R/'godot/systems/serika_lv3.gd').read_text()
for art in read(R/'research/imports/serika_lv3_backgrounds.json'):
 assert hashlib.sha256((R/art['target']).read_bytes()).hexdigest()==art['sha256']
cg=read(R/'research/imports/serika_lv3_cgs_2026-10-27.json')
expected={}
for art in cg['images']:
 assert hashlib.sha256((R/art['source']).read_bytes()).hexdigest()==art['sha256']==hashlib.sha256((R/art['target']).read_bytes()).hexdigest()
 for node_id in art['node_ids']:expected[node_id]=art['target']
assert len(cg['images'])==3 and len(expected)==18
assert {n['id']:n['cg_path'] for n in e['nodes'] if n.get('cg_path')}==expected
assert all(n['cg_fit']=='cover' and not n.get('cg_portrait_overlay',False) for n in e['nodes'] if n.get('cg_path'))
assert e['gallery']['path']==cg['gallery_cover'] and not e['gallery']['show_on_complete']
print('SERIKA LV3 AUDIT: 208 source entries exact; 207 VN nodes + menu option; full English; 3 backgrounds + 3 approved CGs / 18 nodes; no dialogue/order/speaker edits; entry configuration enabled; full Mizuho prerequisite retained.')
