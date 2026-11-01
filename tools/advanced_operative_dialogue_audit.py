#!/usr/bin/env python3
"""Exact author-text/role/order audit, bilingual data schema and gameplay invariants."""
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text())
source=(ROOT/'docs/source/advanced_day2_dialogue_v1/HOSHIMI_ADVANCED_DAY2_OPERATIVE_DIALOGUE_CODEX_READY_V1.md').read_text()
original=json.loads(re.search(r'```json\n(.*?)\n```',source,re.S).group(1))
pack=read('data/advanced_surgery/dialogue/surgery_open_whipple.json')
plain=json.loads(json.dumps(pack))
count=0
for groups in plain['stages'].values():
 for rows in groups.values():
  for row in rows:
   en=row.pop('text_en');assert en.strip() and not re.search(r'[\u3400-\u9fff]',en)
   count+=1
legacy_subset={**plain,'stages':{key:plain['stages'][key] for key in original['stages']}}
assert legacy_subset==original,'Changed original sample text, speaker, ordering or identifiers'
complete=read('docs/source/whipple_advanced_content_v1/data/whipple_day2_dialogue.json')
assert plain==complete,'Changed authorized complete Whipple text, speaker, ordering or identifiers'
failure=read('data/advanced_surgery/dialogue/day3_failed.json')
authored=re.search(r'```text\n坂口：(.*?)\n```',source,re.S).group(0).splitlines()[1:-1]
assert [x['text'] for x in failure]==[x.split('：',1)[1] for x in authored]
assert [x['speaker_role'] for x in failure]==['lead_surgeon','assistant_1','assistant_2','lead_surgeon']
for row in failure:assert row['text_en'].strip() and not re.search(r'[\u3400-\u9fff]',row['text_en'])
assert set(pack['stages'])=={f'W{i:02d}' for i in range(1,14)},'All authorized stages required'
print(f'ADVANCED DIALOGUE SOURCE: {count+len(failure)} original lines exact; English and roles complete; all 13 stages covered.')
