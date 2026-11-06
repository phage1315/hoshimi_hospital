"""Audit actual rendered portrait ownership; fails even if GUI traversal passed."""
import argparse,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('report',type=Path);args=p.parse_args()
data=json.loads(args.report.read_text());wrong=[];missing=[];untranslated=[]
for r in data['observations']:
 portraits=[v for v in r['visuals'] if v['name'] in ['CharacterEventPortrait','CharacterPortrait']]
 cgs=[v for v in r['visuals'] if v['name']=='CharacterEventCG']
 context={k:r[k] for k in ['event','locale','node','page','actor','speaker']}
 if r['actor'] not in ['player','narrator'] and not portraits and not cgs:missing.append(context)
 for v in portraits:
  if 'patient_chihaya_second_surgery_v1/' in v['path'] and r['actor']!='patient_chihaya':wrong.append(context|{'actual_path':v['path']})
 if r['english_source_fallback']:untranslated.append(context)
result={'status':'FAIL' if wrong or missing or untranslated else 'PASS','wrong_portraits':wrong,'missing_portraits':missing,'untranslated_pages':untranslated}
args.report.with_name('alignment_findings.json').write_text(json.dumps(result,ensure_ascii=False,indent=2))
print(json.dumps({'status':result['status'],'wrong_portrait_pages':len(wrong),'missing_portrait_pages':len(missing),'untranslated_pages':len(untranslated)}))
raise SystemExit(1 if result['status']=='FAIL' else 0)
