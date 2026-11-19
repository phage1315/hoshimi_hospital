from pathlib import Path
from PIL import Image
import json,hashlib
r=Path('research/generated_candidates/hiroko_staff_patient_v1');o=r/'prepared/nurse_hiroko';records=[]
expected={g+'/'+e for g,es in {'ward':['neutral','smile','brave','worried','afraid','crying'],'intraoperative':['tense','pain','near_collapse','anesthetized'],'operating_table':['awake','tense','afraid','anesthetized'],'operating_table_lithotomy':['awake','tense','afraid','anesthetized'],'splash':['general_anesthesia'],'advanced':['abdominal','chest','lateral','prone']}.items() for e in es}
for p in sorted(o.glob('*/*.png')):
 im=Image.open(p);im.load();key=str(p.relative_to(o).with_suffix(''))
 if p.parent.name in ('ward','intraoperative'):
  assert im.mode=='RGBA'
  for x in [0,im.width-8]:assert im.getchannel('A').crop((x,0,x+8,8)).getextrema()==(0,0)
 records.append(dict(key=key,path=str(p),size=list(im.size),mode=im.mode,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
assert {i['key'] for i in records}==expected
(r/'prepared_manifest.json').write_text(json.dumps(records,indent=2)+'\n')
print('23 prepared PNG decoded and hashed; exact slot set verified; 10 transparent portraits')
