#!/usr/bin/env python3
"""Compare all 13 supplied lines and bindings to the archived author manuscript."""
import json, re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
source = ROOT / 'docs/source/advanced_staff_dialogues_v1/HOSHIMI_ADVANCED_SURGERY_STAFF_TIMEOUT_TERMINAL_DIALOGUES_CN_V1.md'
pack = json.loads((ROOT / 'data/advanced_surgery/dialogue/staff_confirmations.json').read_text())
expected = []
for line in source.read_text().splitlines():
    if line.startswith('| `'):
        cells = [c.strip().strip('`') for c in line.strip('|').split('|')]
        if cells[2] == 'timeout':
            expected.append(dict(character_id=cells[0], trigger=cells[2], role=cells[3], text=cells[4]))
for actor, trigger, role, text in re.findall(r'character_id: (\w+)\ntrigger: (\w+)\nrole: (\w+)\ntext_zh: "(.*?)"', source.read_text()):
    expected.append(dict(character_id=actor, trigger=trigger, role=role, text=text))
assert len(expected) == 13
assert pack['schema_version'] == 'advanced_staff_dialogues_v1'
assert pack['procedure_ids'] == re.findall(r'^\d\. `(surgery_\w+)`', source.read_text(), re.M)
actual = []
for row in pack['lines']:
    assert set(row) == {'character_id','trigger','role','text','text_en'}
    assert row['text_en'].strip() and not re.search(r'[\u3400-\u9fff]|TODO|PLACEHOLDER', row['text_en'])
    actual.append({k:v for k,v in row.items() if k != 'text_en'})
assert actual == expected, 'Changed Chinese text, punctuation, speaker, role, trigger or ordering'
assert len({(r['character_id'],r['trigger'],r['role']) for r in actual}) == 13
print('ADVANCED STAFF DIALOGUE: 13/13 author lines and bindings exact; English complete; four procedures scoped.')
