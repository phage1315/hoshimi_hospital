"""Audit the approved CDEF script verbatim against runtime CN/EN nodes."""
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
s=(ROOT/'research/character_references/sonoda_itsumi_2026-10-21/lv0/author_script.md').read_text()
cn=re.findall(r'\*\*【事件节点 (ITS-([CDEF])-\d+)｜发言者=([^｜】]+)(?:｜表情语义=([^】]+))?】\*\*\n([^\n]+)',s)
en={m[0]:(m[1],m[2]) for m in re.findall(r'^\| `(ITS-[CDEF]-\d+)` \| ([^|]+?) \| (.+?) \|$',s,re.M)}
events=json.loads((ROOT/'data/staff/nurse_sonoda_itsumi/events.json').read_text())
locales={l:json.loads((ROOT/f'data/localization/{l}.json').read_text())['strings'] for l in ['en','zh_CN']}
assert len(cn)==len(en)==87
assert len(events)==4
for stage,event in zip('CDEF',events):
 rows=[r for r in cn if r[1]==stage]
 assert len(event['nodes'])==len(rows)
 for row,node in zip(rows,event['nodes']):
  src,_,speaker,_,line=row
  expected='「你说的那位后辈，在吗？」' if src=='ITS-F-004' else line.split('：',1)[1]
  assert node['id']==src.lower().replace('-','_')
  assert node['text']==expected and node['speaker_label']==speaker,src
  prefix=f"collections.character_events.{event['id']}.nodes.{node['id']}"
  assert locales['zh_CN'][prefix+'.text']==expected
  assert locales['en'][prefix+'.text']==en[src][1],src
  assert locales['en'][prefix+'.speaker_label']==en[src][0].replace(' (Itsumi, unnamed)',''),src
  assert node['choices'][0]['effects']=={'affection':0,'familiarity':0}
  if stage=='F':assert node['outfit']=='uniform'
print('PASS: 87 CN/EN nodes, speakers and order; only approved F004 wording changed; F ordinary uniform')
