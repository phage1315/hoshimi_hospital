"""Compare current bilingual nodes with archived author delivery, allowing approved amendments only."""
import json
import re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
def read(path): return json.loads((ROOT / path).read_text())
def amend(text):
    changes = {'Takashi':'Ryuji','faintly蠕动ing':'faintly moving with peristalsis','soft,蠕动ing loops':'soft, peristaltic loops','thick脓 cavities':'thick pus-filled cavities','纯白连衣裙式护士服':'粉红色连衣裙式护士服','纯白护士裙':'粉红色护士裙','挺括的白色领口':'挺括的粉红色领口','半敞开的白色护士服':'半敞开的粉红色护士服','pure-white':'pink','crisp white collar':'crisp pink collar','half-open white nurse uniform':'half-open pink nurse uniform'}
    for old,new in changes.items(): text = text.replace(old,new)
    return text
roles = {'旁白':'narrator','坂口隆司':'player','朝仓美幸':'nurse_yui','朝倉美幸':'nurse_yui','武見妙':'doc_takemi','本庄萌恵':'nurse_moe','城宮明日香':'doc_asuka','浅上藤乃':'patient_fujino','女患者':'patient_generic'}
locales = {x:read(f'data/localization/{x}.json')['strings'] for x in ['zh_CN','en']}
checks = 0
for actor,level,folder,prefix in [('nurse_yui',4,'miyuki_lv4','N'),('doc_takemi',1,'takemi_lv1_lv2','L1_'),('doc_takemi',2,'takemi_lv1_lv2','L2_')]:
    event = read(f'data/staff/{actor}/lv{level}_events.json')[0]
    review = read(f'docs/source/{folder}/bilingual_review.json')
    rows = [x for x in review['cn'] if x['id'].startswith(prefix)]
    english = {x['id']:x for x in review['en']}
    assert [x['id'] for x in event['nodes']] == [x['id'].lower() for x in rows]
    for node,source in zip(event['nodes'],rows):
        assert node['text'] == amend(source['text']), node['id']
        who=roles[source['speaker']]
        assert node['speaker'] == (who if who in ['player','narrator'] else 'actor')
        if node['speaker']=='actor': assert node['actor_id']==who
        assert node['speaker_label']==source['speaker']
        for locale in locales:
            authored = source if locale=='zh_CN' else english[source['id']]
            key=f"collections.character_events.{event['id']}.nodes.{node['id']}"
            assert locales[locale][key+'.text']==amend(authored['text']), key
            assert locales[locale][key+'.speaker_label']==amend(authored['speaker']), key
            checks+=2
        checks+=4
    print(event['id'],len(rows),'nodes: exact text, speaker and order verified')
print(f'Source audit: {checks} checks, 0 failures')
