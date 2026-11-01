#!/usr/bin/env python3
"""Freeze all original clinical prose, speakers, IDs and ordering before numeric edits."""
import hashlib
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def strings(value, path=''):
    if isinstance(value, str):
        return [(path, value)]
    if isinstance(value, list):
        return [row for i, child in enumerate(value) for row in strings(child, path + '.' + str(i))]
    if isinstance(value, dict):
        return [row for key, child in sorted(value.items()) if key != 'runtime_options' for row in strings(child, path + '.' + key)]
    return []

fixture = json.loads((ROOT / 'tools/fixtures/clinical_presence_source.json').read_text())
checks = 0
for file, expected in fixture['source_string_sha256'].items():
    data = json.loads((ROOT / file).read_text())
    rows = strings(data)
    actual = hashlib.sha256(json.dumps(rows, ensure_ascii=False).encode()).hexdigest()
    assert actual == expected, f'Unapproved source text, speaker, ID or ordering change: {file}'
    checks += len(rows)
variant = next(v for v in json.loads((ROOT / 'data/cases/surgery_case_templates.json').read_text()) if v['id'] == 'template_exploratory_laparotomy')['rare_variants'][0]
assert variant['runtime_options'] == ['explain_and_confirm', 'frighten_with_worst_case']
assert variant['probability'] == .08
for option in variant['decision_options']:
    if option['id'] in variant['runtime_options']:
        expected = (5, 0, 0) if option['id'] == 'explain_and_confirm' else (35, -15, 2)
        assert tuple(option['effects'].get(k, 0) for k in ('fear', 'dignity', 'presence')) == expected
print(f'CLINICAL SOURCE AUDIT: {checks} original strings preserved; 0 failures')
