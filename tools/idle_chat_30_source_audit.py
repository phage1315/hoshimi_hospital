#!/usr/bin/env python3
"""Exact source, English coverage and independent rooftop contract."""
import json
import re
from pathlib import Path
from staff_bundles import load_staff_bundles
from staff_idle_chat_contract import staff_social_locations

ROOT = Path(__file__).resolve().parents[1]
source = (ROOT/'docs/source/HOSHIMI_LOCATION_IDLE_CHAT_30_CN_DRAFT_2026-10-14.md').read_text()
manifest = json.loads((ROOT/'data/manifest.json').read_text())
collections, _ = load_staff_bundles(ROOT/'data', manifest['staff_bundles'])
fixture = json.loads((ROOT/'tools/fixtures/idle_chat_30.json').read_text())
en = json.loads((ROOT/'data/localization/en.json').read_text())['strings']
expected = {}
for section in re.split(r'^## ', source, flags=re.M)[1:]:
    actor = re.search(r'`([a-z_]+)`', section)[1]
    for part in re.split(r'^### ', section, flags=re.M)[1:]:
        location = 'lounge' if part.startswith('休息室') else 'rooftop'
        lines = re.findall(r'^\d+\. (.+)$', part, re.M)
        assert len(lines) == 3
        expected[f'{location}_chat_{actor}'] = (actor, location, lines)
assert len(expected) == len(fixture) == 10
for event_id, (actor, location, lines) in expected.items():
    records = [e for e in collections['time_events'] if e['id'] == event_id]
    assert len(records) == 1
    row = records[0]
    assert row['actor_id'] == actor and row['location_id'] == location
    assert row['responses'] == lines, 'Chinese wording/order/punctuation: '+event_id
    assert row == next(e for e in fixture if e['id'] == event_id)
    assert row['minutes'] == 30 and row['repeatable'] and not row.get('effects')
    assert location in staff_social_locations(next(p for p in collections['staff'] if p['id'] == actor))
    for suffix in ['label', 'responses.0', 'responses.1', 'responses.2']:
        text = en.get(f'collections.time_events.{event_id}.{suffix}')
        assert text and not re.search(r'[\u3400-\u9fff]', text), 'Complete English '+event_id
assert len([p for p in collections['staff'] if 'rooftop' in staff_social_locations(p)]) == 20
assert 'rooftop' not in staff_social_locations(next(p for p in collections['staff'] if p['id'] == 'nurse_ishigami'))
print('IDLE CHAT 30 SOURCE AUDIT: 8 actors; 10 entries; 30 exact paragraphs; 40 English keys; 20 rooftop candidates; passed')
