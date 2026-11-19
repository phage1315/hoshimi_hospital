#!/usr/bin/env python3
"""Compare every runtime story/dialogue/strategy against the frozen author source."""
import json,re,hashlib
from import_mido_legendary import ROOT,DATA,ID,SOURCE,build
proc,story,dialogues=build()
checks=0
def check(ok,msg):
 global checks
 checks+=1
 assert ok,msg
actual=json.loads((DATA/'legendary_procedures.json').read_text())[0]
check(actual==proc,'Procedure differs from declared importer data')
runtime=json.loads((DATA/'stories'/f'{ID}.json').read_text())
for phase in ['day1','day2','day3']:
 check(runtime[phase]==story[phase],phase)
 for row in runtime[phase]['lines']:
  check(row['speaker'] in ['patient','PLAYER','doc_emiko'],'speaker')
  check(bool(row['text_en']) and not re.search('[\u4e00-\u9fff]',row['text_en']),'English')
for mode,directory in [('standard','dialogue_v2'),('teaching','dialogue_teaching')]:
 data=json.loads((DATA/directory/f'{ID}.json').read_text())
 check(data==dialogues[mode],mode+' verbatim import')
 for stage in data['stages'].values():
  for group in stage.values():
   for row in group:
    check(row['text'] in SOURCE.read_text(),row['id']+' original CN')
    check(row['text_en'] in SOURCE.read_text(),row['id']+' original EN')
    check(not re.search('[\u4e00-\u9fff]',row['text_en']),row['id']+' English')
check(sum(s['hp_base'] for s in proc['steps'])==54,'HP')
check(sum(s['strategic_effects']['elapsed_time'] for s in proc['steps'])==645,'time')
ui=json.loads((DATA/'ui_text.json').read_text())
for key,value in ui.items():
 if key.startswith('legendary_') and key!='legendary_pool':
  for text in value: check(text.replace('%d','{remaining}') in SOURCE.read_text(),key+' authored UI')
for key in ['title','title_en']: check(runtime[key] in SOURCE.read_text(),'Exact episode title')
for key in ['name','name_en']: check(actual[key] in SOURCE.read_text(),'Exact procedure name')
manifest=json.loads((ROOT/'assets/characters/murakami_ai_legendary_v1/manifest.json').read_text())
for row in manifest['assets']:
 path=ROOT/row['path'];check(path.exists() and hashlib.sha256(path.read_bytes()).hexdigest()==row['sha256'],'Asset SHA: '+row['path'])
check('casual' not in runtime['patient']['visuals']['portraits'],'No casual runtime slot')
print(f'MIDO SOURCE AUDIT: {checks} checks; 0 failures')
