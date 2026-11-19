from pathlib import Path
import json,hashlib
from PIL import Image
r=Path('research/generated_candidates/asuka_staff_patient_v1');o=Path('assets/characters/asuka_staff_patient_v1/doc_asuka');q=r/'qa'
records=[]
for p in sorted(o.glob('*/*.png')):
 im=Image.open(p);im.load();key=str(p.relative_to(o).with_suffix(''))
 if p.parent.name in ('ward','intraoperative'):
  assert im.mode=='RGBA';assert im.getchannel('A').crop((0,0,8,8)).getextrema()==(0,0)
 records.append(dict(key=key,path=str(p),size=list(im.size),mode=im.mode,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
assert len(records)==23
assert (o/'advanced/chest.png').read_bytes()==(r/'author_supplied/chest.png').read_bytes()
(r/'runtime_manifest.json').write_text(json.dumps(records,indent=2)+'\n')
paths=['res://'+x['path'] for x in records]
(q/'texture_check.gd').write_text('extends SceneTree\nfunc _initialize():\n\tvar paths = '+json.dumps(paths)+'\n\tfor path in paths:\n\t\tvar tex = load(path) as Texture2D\n\t\tif tex == null or tex.get_width() <= 0:\n\t\t\tquit(1)\n\t\t\treturn\n\tprint("ASUKA_TEXTURES_OK: ", paths.size())\n\tquit(0)\n')
print('23 decoded; 10 transparent portraits; author chest bytes preserved')
