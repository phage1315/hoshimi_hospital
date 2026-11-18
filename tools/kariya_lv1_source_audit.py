"""Audit the authored manuscript against the runtime text without importing or rewriting it."""
from pathlib import Path
import json,re,hashlib
root=Path(__file__).resolve().parents[1]
src=root/'research/source_scripts/HOSHIMI_KARIYA_MEGUMI_LV1_BUTCHER_SHOP_GIRL_V1_0.md'
event=json.loads((root/'data/staff/nurse_kariya_megumi/lv1_events.json').read_text())[0]
lines=[];active=False
for line in src.read_text().splitlines():
 s=line.strip()
 if s.startswith('## B.'):break
 if s.startswith('### 【第') or s.startswith('**【选择 1'):active=False;continue
 if s=='**【玩家可见正文】**' or s.startswith('#### 【分支 ') or s=='> **【主线汇合】**':active=True;continue
 if not active or not s or s=='---' or s.startswith('*(【') or s.startswith('**【狩谷惠 Relationship'):continue
 lines.append(re.sub(r'^(狩谷惠|绀野真琴|杉村弘子|坂口隆司)：','',s))
actual=''.join(n['text'] for n in event['nodes'])
assert actual==''.join(lines),'Source prose changed, missing, added or reordered'
choice=next(n for n in event['nodes'] if n['id']=='km1_choice')
expected=re.findall(r'- \*\*选项 [ABC]：(「.*」)\*\*',src.read_text())
assert [c['label'] for c in choice['choices']]==expected
nodes={n['id']:n for n in event['nodes']};assert len(nodes)==133
for n in nodes.values():
 for c in n['choices']:
  assert c['next']=='@end' or c['next'] in nodes
  assert c['effects']=={'affection':0,'familiarity':0} and not c['flags']
 for a in n.get('event_portraits',[]):assert (root/a['path']).is_file(),a['path']
 if n.get('cg_path'):assert (root/n['cg_path']).is_file()
assert nodes['km1_083']['speaker_label']=='狩谷惠'
assert nodes['km1_062']['speaker_label']=='狩谷惠'
assert '现在连手术室的器械台都没资格站上去' in nodes['km1_062']['text']
assert '八点四十五分' in nodes['km1_001']['text']
for branch in ['a','b','c']:
 cur=event['start'];seen=set()
 while cur!='@end':
  assert cur not in seen;seen.add(cur)
  n=nodes[cur];c=next(c for c in n['choices'] if c['id']=='km1_reply_'+branch) if cur=='km1_choice' else n['choices'][0]
  cur=c['next']
 assert 'km1_115' in seen and 'km1_132' in seen
 assert len(seen)==(125 if branch=='a' else 124)
manifest=json.loads((root/'research/imports/kariya_lv1_2026-11-16.json').read_text())
assert manifest['source_sha256']==hashlib.sha256(src.read_bytes()).hexdigest()
original=Path('/Users/ningye/Downloads/HOSHIMI_KARIYA_MEGUMI_LV1_BUTCHER_SHOP_GIRL_V1_0.md')
if original.exists():assert src.read_bytes()==original.read_bytes()
print('KARIYA LV1 SOURCE AUDIT: exact manuscript prose/choices, 133 nodes, 3 closed branches, assets and zero choice rewards PASS')
