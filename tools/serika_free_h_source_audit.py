#!/usr/bin/env python3
"""Audit supplied Serika profile/flow bytes, English pools and unchanged CGs."""
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'docs/source/serika_free_h_v1_1'
HAN = re.compile(r'[\u3400-\u9fff]')

def audit():
    failures = []
    checked = 0
    def check(condition, message):
        nonlocal checked
        checked += 1
        if not condition:
            failures.append(message)
    def read(path):
        return json.loads(path.read_text())
    for source, runtime in [('doc_serika.h_profile.json', 'h_profile_v1_1.json'), ('doc_serika.h_flow.json', 'h_flow_v1_1.json')]:
        check((SOURCE/source).read_bytes() == (ROOT/'data/staff/doc_serika'/runtime).read_bytes(), 'Authored source changed: '+source)
    p = read(SOURCE/'doc_serika.h_profile.json')
    f = read(SOURCE/'doc_serika.h_flow.json')
    c = read(ROOT/'data/staff/doc_serika/h_context_v1_1.json')
    review = {row['source']: row for row in read(SOURCE/'bilingual_review.json')}
    pools = {}
    for section, values in p['dialogue'].items():
        for key, lines in values.items():
            if section == 'location_entry':
                translated = c['locations'][key]['dialogue']['en']['entry']
            else:
                target = 'scene.'+key if section == 'scene' else 'reaction.'+section+':'+key.replace(':', '|')
                translated = c['base']['dialogue']['en'][target]
            pools['profile.dialogue.'+section+'.'+key] = (lines, translated)
    explicit = {
        'max_prompt': [f['excitement_max']['line']],
        'style.opening.gentle': [f['entry_style']['openings']['gentle']],
        'style.opening.intense': [f['entry_style']['openings']['intense']],
        'style.midpoint.gentle': [f['entry_style']['midpoints']['gentle']],
        'style.midpoint.intense': [f['entry_style']['midpoints']['intense']],
        'finish.responses': f['phase2']['manual_finish']['on_click']['response_pool'],
        'aftercare': f['external_vn_aftercare']['free_h']['on_entry_line_sequence'],
        'finish.labels': read(ROOT/'data/h_finish_button_labels_v1_3_4.json')['label_variants'],
    }
    for key, lines in explicit.items():
        pools[key] = (lines, c['base']['dialogue']['en'][key])
    count = 0
    for key, (original, translated) in pools.items():
        check(len(original) == len(translated), 'Pool count: '+key)
        for i, (cn, en) in enumerate(zip(original, translated)):
            identity = key+'.'+str(i)
            check(bool(en.strip()) and not HAN.search(en) and not re.search(r'\b(TODO|TBD|placeholder)\b', en), 'English missing/invalid: '+identity)
            check(review.get(identity) == {'source': identity, 'zh_CN': cn, 'en': en}, 'Bilingual review mismatch: '+identity)
            count += 1
    check(count == len(review) == 86, 'Expected 86 translated source lines, including global labels')
    for item in read(SOURCE/'import_manifest.json')['files']:
        path = ROOT/item['destination'] if 'destination' in item else SOURCE/item['source']
        check(hashlib.sha256(path.read_bytes()).hexdigest() == item['sha256'], 'Source/asset bytes changed: '+str(path))
    check(c['entry_random_one'] and c['events'] == {}, 'Free-entry policy or milestone separation')
    check(c['base']['assets']['background']['id'] == 'serika_home_bedroom_night', 'Serika home background')
    return checked, count, failures

if __name__ == '__main__':
    checks, lines, failures = audit()
    for failure in failures: print(failure)
    print(f'SERIKA FREE H SOURCE/EN: {checks} checks; {lines} bilingual lines; {len(failures)} failures')
    raise SystemExit(bool(failures))
