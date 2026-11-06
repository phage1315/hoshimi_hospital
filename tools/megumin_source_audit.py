#!/usr/bin/env python3
"""Audit each delivered source beat and inline English, separately from runtime rendering."""
import json,re
from pathlib import Path
from import_megumin import extract,SRC,ROOT,HALLOWEEN_SOURCE,HALLOWEEN_ID

def audit():
 failures=[];checks=0
 source=extract();actual=json.loads((ROOT/'data/npcs/megumin/catalog.json').read_text())['entries']
 def check(ok,note):
  nonlocal checks
  checks+=1
  if not ok:failures.append('megumin: '+note)
 check(len(source)==len(actual)==102,'102 entries')
 for src,dst in zip(source,actual):
  check(src['content_id']==dst['content_id'],'entry order')
  check(len(src['beats'])==len(dst['beats']),src['content_id']+' beat count')
  for a,b in zip(src['beats'],dst['beats']):
   check(a['text']==b['text']['zh_CN'] and a['speaker']==b['speaker_label']['zh_CN'] and a['source_raw']==b['source_raw'] and a['gate']==b['gate'],a['id']+' source fidelity')
   for field in ['text','speaker_label']:
    zh,en=b[field]['zh_CN'],b[field]['en']
    check(not zh or bool(en.strip()) and not re.search(r'[\u3400-\u9fff]',en),a['id']+' '+field+' English')
   check(a.get('choice_labels',[])==[c['zh_CN'] for c in b.get('choice_labels',[])],a['id']+' exact choices')
   for c in b.get('choice_labels',[]):check(bool(c['en'].strip()),a['id']+' choice English')
   # The exact source line is independently required to exist in the supplied manuscript.
   check(a['source_raw'] in HALLOWEEN_SOURCE.read_text() or any(a['source_raw'] in (SRC/name).read_text() for name in ['02_INTRO_SCRIPT_CN.md','03_MICRO_EVENTS_CN.md','04_AMBIENT_BARKS_CN.md']),a['id']+' manuscript provenance')
  check(bool(dst['title']['en'].strip()),src['content_id']+' title English')
 # No source item is silently dropped from eligibility data.
 ids={e['content_id'] for e in actual}
 manifest=json.loads((SRC/'05_EVENT_MANIFEST.json').read_text())
 check({e['content_id'] for e in manifest['events']}==ids-{'megumin_intro_front_desk',HALLOWEEN_ID},'manifest coverage')
 return checks,failures
if __name__=='__main__':
 n,f=audit();print(f'MEGUMIN SOURCE: {n} checks; {len(f)} failures');print('\n'.join(f));raise SystemExit(bool(f))
