"""Read-only independent source/screen comparison for the first-20-row QA batch."""
import json,re,sys,hashlib
from pathlib import Path
R=Path(__file__).resolve().parents[1]; Q=R/'docs/qa/event_batch_first20_rows_2026-10-27'
read=lambda p:json.loads(Path(p).read_text())
source_map={}; findings=[]; provenance=[]
def remember(eid,nid,text,who,path,expression=None):
 source_map.setdefault(eid,{})[nid]={'text':text,'speaker':who,'source':str(path),'expression':expression}
def source(path):
 p=Path(path);p=p if p.is_absolute() else R/p
 provenance.append({'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()});return p.read_text()
p='docs/source/lv0_introductions/HOSHIMI_MIYAMA_KAORI_LV0_INTRO_WHITECOAT_SHARP_CN_REVIEW.md'
s=source(p)
for nid,who,block in re.findall(r'【事件节点 (M0-\d{4}[AB]?)｜([^】]+)】\s*\n(.*?)(?=\n\s*【事件节点|\n\s*【分支汇合|\n\s*【事件结束|\n\s*---)',s,re.S):
 line=next((x.strip() for x in block.splitlines() if x.strip()),'');text=re.sub(r'^(?:旁白|深山佳織|坂口隆司(?:（心想）|·内心独白)?|手术室护士)：\s*','',line)
 if text.startswith('「') and text.endswith('」'):text=text[1:-1]
 remember('intro_doc_rei',nid.lower().replace('-','_'),text,who,p)
p='docs/source/lv0_introductions/HOSHIMI_IIMURA_MANAMI_LV0_PHARMACY_INTRO_CN_REVIEW.md';s=source(p)
for num,meta,block in re.findall(r'【演出节点 IM0-(\d{4})｜([^】]+)】\s*\n(.*?)(?=\n\s*(?:【演出节点|【立绘切换|【事件结束|---)|\Z)',s,re.S):
 line=next(x.strip() for x in block.splitlines() if x.strip());who,text=line.split('：',1)
 if who!='旁白' and text.startswith('「') and text.endswith('」'):text=text[1:-1]
 expr=re.search(r'(?:当前饭村|本句表情)=(pharm_[a-z]+)',meta).group(1)
 remember('intro_pharmacist_manami','im0_'+num,text,who,p,expr)
p='research/character_references/asakura_miyuki_2026-10-23/lv1/source_cn.md';s=source(p)
for nid,who,text in re.findall(r'^\*\*(A1-\d+)｜([^：]+)：\*\*\s*(.+)$',s,re.M):remember('miyuki_lv1_not_that_kind_of_inexperienced',nid.lower().replace('-','_'),text,who,p)
from import_manami_lv1 import rows,internal,SOURCE
source(SOURCE)
for row in rows():remember('manami_lv1_sneeze',internal(row['source_id']),row['text'],row['speaker'],str(SOURCE))
p='docs/design/HOSHIMI_TONEGAWA_ANGE_RELATIONSHIP_IMPLEMENTATION_V1.md';s=source(p);s=s.split('## 4. 事件完整正文',1)[1].split('## 5.',1)[0]
# Match complete approved lines, keeping speech ownership independent of runtime fields.
ange_lines={}
for line in s.splitlines():
 line=line.strip()
 m=re.match(r'^([^：]+)：[“「](.*)[”」]$',line)
 if m:ange_lines.setdefault(m[2],set()).add(m[1])
 elif line and not line.startswith(('#','**','-','```','>')):ange_lines.setdefault(line,set()).add('旁白')
for e in read(R/'data/staff/nurse_ange/events.json'):
 if not e['id'].startswith('ange_lv'):continue
 for n in e['nodes']:
  text=n['text'];key=text[1:-1] if text.startswith('「') and text.endswith('」') else text
  owners=ange_lines.get(key,set())
  if len(owners)==1:remember(e['id'],n['id'],text,next(iter(owners)),p)
p='docs/design/HOSHIMI_MIYAMA_LV2_AYAKO_EVENT_DIALOGUE_DRAFT_V8.md';s=source(p)
for scene,block in re.findall(r'^# \d+\. Scene (\d+) [^\n]*\n(.*?)(?=^# \d+\. Scene |\Z)',s,re.M|re.S):
 for number,beat in re.findall(r'^### (\d+)\s*\n(.*?)(?=^### \d+\s*\n|\Z)',block,re.M|re.S):
  m=re.search(r'^\*\*([^*]+)\*\*',beat,re.M)
  if not m:continue
  who=m[1];lines=[x[2:] for x in beat.splitlines() if x.startswith('> ')]
  if lines:remember('miyama_02_manga_artist_wrong_patient',f's{int(scene):02}_{int(number):03}','\n'.join(lines),who,p)
# Keep the other located design documents indexed; incomplete source mapping is not a pass.
for p in ['docs/design/HOSHIMI_MIYAMA_LV1_SAFETY_PIN_EVENT.md','docs/design/HOSHIMI_MIYAMA_LV1_LV3_CODEX_HANDOFF.md','docs/design/HIROKO_RELATIONSHIP_LV1_OR_EVENT.md','docs/design/SHIROIMIYA_ASUKA_EVENT_DESIGN.md','docs/design/HOSHIMI_ARTORIA_DOCTOR_CHARACTER_V1.md','docs/design/HOSHIMI_FUJISAKI_SHIORI_CHARACTER_V1.md','docs/design/HOSHIMI_AQUA_COMPLETE_BASE_INTRO_LV1_SURGERY_V2.md','/Users/ningye/Downloads/MIDO_EMIKO_RELATIONSHIP_EVENTS_LV0_LV2.md','/Users/ningye/Downloads/HOSHIMI_ARTORIA_INTRO_OFFICE_LV1_DESIGN_V1.md']:source(p)
(Q/'source_expectations.json').write_text(json.dumps(source_map,ensure_ascii=False,indent=2));(Q/'source_provenance.json').write_text(json.dumps(provenance,ensure_ascii=False,indent=2))
# Compare first four events' text and roles exactly; other mapped lines retain independent ownership.
for r in read(Q/'scope.json'):
 e=next(x for x in read(R/r['file']) if x['id']==r['id'])
 for n in e.get('nodes',[]):
  expected=source_map.get(r['id'],{}).get(n['id'])
  if not expected:continue
  if n['text']!=expected['text']:findings.append({'event':r['id'],'node':n['id'],'kind':'source_text_difference','expected':expected['text'],'actual':n['text']})
  if expected['expression'] and n.get('expression')!=expected['expression']:findings.append({'event':r['id'],'node':n['id'],'kind':'expression_source_difference'})
print('Independent source mapped nodes:',{k:len(v) for k,v in source_map.items()})
print('Exact mapped text/expression differences:',len(findings))
(Q/'source_findings.json').write_text(json.dumps(findings,ensure_ascii=False,indent=2))
