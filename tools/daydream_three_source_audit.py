"""Read-only author text audit and cross-character portrait regression check."""
import argparse,hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('--out',type=Path,default=ROOT/'docs/qa/daydream_three_alignment_2026-11-02')
args=parser.parse_args()
OUT=args.out
ACTORS={'NARRATOR':('narrator','旁白'),'SAKAGUCHI':('player','坂口隆司'),'HIROKO':('nurse_hiroko','杉村弘子'),'EMIKO':('doc_emiko','御堂江美子'),'MANAMI':('pharmacist_manami','饭村真奈美'),'MIKA':('nurse_rin','中井美佳'),'CHIHAYA':('patient_chihaya','仓本千早'),'CHIZURU':('nurse_ishigami','石神千鹤'),'MIZUHO':('guest_mizuho','瑞穗'),'SAYAKA':('doc_sayaka','南条小夜香')}
report={'sources':[],'text_mismatches':[],'markup_leaks':[],'wrong_character_paths':[],'unresolved_staging':[],'english_fallback_nodes':[]}
for e in json.loads((ROOT/'data/daydreams/index.json').read_text())['events']:
 path=Path('/Users/ningye/Downloads')/e['source_file']; raw=path.read_text()
 sections=re.split(r'^\*\*(F\d+_\d+)\*\*\s*$',raw,flags=re.M)
 ids=sections[1::2];blocks=sections[2::2]
 if ids!=[n['id'] for n in e['nodes']]:report['text_mismatches'].append({'event':e['id'],'field':'node_order'})
 for nid,block,n in zip(ids,blocks,e['nodes']):
  key=re.search(r'^`\[([A-Z_]+)\]`',block,re.M)
  expected=ACTORS[key[1]] if key else ('narrator','旁白')
  text=[]
  for line in block.splitlines():
   s=line.strip()
   if not s or s.startswith('---') or re.match(r'^#{1,6}\s+',s) or s=='[END OF EVENT]' or (s.startswith('`') and s.endswith('`')):continue
   s=re.sub(r'`?\[[A-Z_]+:\s*[^\]]+\]`?','',s).strip()
   if s:text.append(s)
  for field,a,b in [('text','\n'.join(text),n['text']['zh_CN']),('actor',expected[0],n['actor_id']),('speaker',expected[1],n['speaker_label']['zh_CN'])]:
   if a!=b:report['text_mismatches'].append({'event':e['id'],'node':nid,'field':field})
  if any(re.match(r'^#{1,6}\s+',line) for line in n['text']['zh_CN'].splitlines()):report['markup_leaks'].append({'event':e['id'],'node':nid})
  portrait=n.get('portrait_path','')
  if n['actor_id'] not in ['player','narrator'] and not portrait:
   profile=json.loads((ROOT/'data/staff'/n['actor_id']/'profile.json').read_text())
   visuals=profile['visuals'];outfit=n.get('outfit',visuals.get('default_outfit',''))
   expression=n.get('expression','neutral')
   portrait=visuals['portraits'].get(outfit+'/'+expression,visuals['portraits'].get(outfit+'/neutral',''))
  if 'patient_chihaya_second_surgery_v1/' in portrait and n['actor_id']!='patient_chihaya':report['wrong_character_paths'].append({'event':e['id'],'node':nid,'actor':n['actor_id'],'path':portrait})
  if n['actor_id'] not in ['player','narrator'] and (not portrait or not (ROOT/portrait).is_file()):report['unresolved_staging'].append({'event':e['id'],'node':nid,'actor':n['actor_id'],'sprite':n.get('sprite_key'),'expression':n.get('expression'),'outfit':n.get('outfit','default'),'path':portrait})
  if n['text']['en']==n['text']['zh_CN']:report['english_fallback_nodes'].append(nid)
 report['sources'].append({'event':e['id'],'file':str(path),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'nodes':len(ids)})
OUT.mkdir(parents=True,exist_ok=True)
(OUT/'source_audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
print(json.dumps({k:len(v) for k,v in report.items()},ensure_ascii=False))
raise SystemExit(1 if report['text_mismatches'] or report['markup_leaks'] or report['wrong_character_paths'] or report['unresolved_staging'] else 0)
