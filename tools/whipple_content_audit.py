"""Exact source/role/order audit for the authored Whipple package."""
from pathlib import Path
import json,re,hashlib
ROOT=Path(__file__).resolve().parents[1]
src=ROOT/'docs/source/whipple_advanced_content_v1'
a=json.loads((src/'data/whipple_day2_dialogue.json').read_text())
b=json.loads((ROOT/'data/advanced_surgery/dialogue/surgery_open_whipple.json').read_text())
stripped=json.loads(json.dumps(b))
for groups in stripped['stages'].values():
 for rows in groups.values():
  for row in rows: row.pop('text_en')
assert a==stripped,'Operative source/roles/order changed'
assert len(b['stages'])==13
assert sum(len(x['stage_entry']) for x in b['stages'].values())==30
assert sum(len(x.get('precision_failed',[])) for x in b['stages'].values())==12
story=json.loads((ROOT/'data/advanced_surgery/stories/surgery_open_whipple.json').read_text())
raw=(src/'scripts/whipple_first_patient_day1_day3.md').read_text()
for phase,start,end in [('day1','## `DAY1_FIRST_PATIENT`','## `PRE_INDUCTION'),('day3','## `DAY3_FIRST_CLEAR_SUCCESS`','## 已废弃')]:
 lines=re.findall(r'\*\*(樱良|坂口)：\*\*「([^\n]*)」',raw.split(start)[1].split(end)[0])
 assert [(r['speaker'],r['text']) for r in story[phase]['lines']]==[('patient' if s=='樱良' else 'PLAYER','「'+t+'」') for s,t in lines],phase
for path in story['patient']['visuals']['portraits'].values():assert (ROOT/path).is_file(),path
for row in [r for x in b['stages'].values() for v in x.values() for r in v]+story['day1']['lines']+story['day3']['lines']:
 assert row['text_en'].strip() and not re.search('[\u4e00-\u9fff]',row['text_en'])
print('WHIPPLE SOURCE AUDIT: 42 operative + 24 story lines, exact Chinese/roles/order; English and assets present')
