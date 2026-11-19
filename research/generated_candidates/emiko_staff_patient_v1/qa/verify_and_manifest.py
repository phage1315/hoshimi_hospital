from pathlib import Path
import json, shutil, hashlib
from PIL import Image
r=Path('research/generated_candidates/emiko_staff_patient_v1')
out=Path('assets/characters/emiko_staff_patient_v1/doc_emiko')
qa=r/'qa'
c=json.loads((r/'correction.json').read_text())
# Historical production helper: do not overwrite later author replacements.
assert not (r/'author_supplied').exists(), 'Use current runtime_manifest.json for verification; author replacements exist.'
shutil.copy2(c['source'],out/'operating_table/anesthetized.png')
base=json.loads((r/'manifest.json').read_text())
base['status']='base_approved_by_user'
(r/'manifest.json').write_text(json.dumps(base,ensure_ascii=False,indent=2)+'\n')
sources={x['key']:x['source'] for x in base['images']}
sources.update({x['key']:x['source'] for x in json.loads((r/'variant_sources.json').read_text())})
sources['operating_table/anesthetized']=c['source']
records=[]
assert len(list(out.glob('*/*.png')))==23
for key,source in sources.items():
 p=out/(key+'.png')
 with Image.open(p) as im:
  im.load()
  if key.split('/')[0] in ('ward','intraoperative'):
   assert im.mode=='RGBA'
   assert im.getchannel('A').crop((0,0,8,8)).getextrema()==(0,0)
   assert im.getchannel('A').crop((im.width-8,0,im.width,8)).getextrema()==(0,0)
  records.append(dict(key=key,path=str(p),source=source,size=list(im.size),mode=im.mode,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
(r/'runtime_manifest.json').write_text(json.dumps(records,ensure_ascii=False,indent=2)+'\n')
for log in qa.glob('ward_*.log'):
 pass
for log in list(qa.glob('ward_*.log'))+list(qa.glob('intraoperative_*.log')):
 report=json.loads(next(x for x in log.read_text().splitlines() if x.startswith('{')))
 assert report['top_corners_transparent']
 log.with_suffix('.json').write_text(json.dumps(report,indent=2)+'\n')
paths=['res://'+x['path'] for x in records]
script='extends SceneTree\nfunc _initialize():\n\tvar paths = '+json.dumps(paths)+'\n\tfor path in paths:\n\t\tvar tex = load(path) as Texture2D\n\t\tif tex == null or tex.get_width() <= 0:\n\t\t\tpush_error(path)\n\t\t\tquit(1)\n\t\t\treturn\n\tprint("EMIKO_PATIENT_TEXTURES_OK: ", paths.size())\n\tquit(0)\n'
(qa/'emiko_texture_check.gd').write_text(script)
print('23 decoded; 10 RGBA transparent corner checks passed')
