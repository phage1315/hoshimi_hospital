"""Compare imported dialogue with the untouched V2 authoring archive and user supplement."""
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'research/character_references/rumi_shiori_2026-10-21/data_audit_v2'

def leaves(value):
    if isinstance(value, dict):
        for v in value.values(): yield from leaves(v)
    elif isinstance(value, list):
        for v in value: yield from leaves(v)
    elif isinstance(value, str): yield value

def bilingual(value):
    if isinstance(value, dict):
        if 'zh_CN' in value and 'en' in value:
            yield value
        else:
            for v in value.values(): yield from bilingual(v)
    elif isinstance(value, list):
        for v in value: yield from bilingual(v)

def main():
    english = json.loads((ROOT / 'data/localization/en.json').read_text())['strings']
    wrappers = json.loads((BASE / 'preop_graphic_wrapper_user_source.json').read_text())
    count = 0
    for actor in wrappers:
        folder = ROOT / 'data/staff' / actor
        profile = json.loads((folder / 'profile.json').read_text())
        events = json.loads((folder / 'time_events.json').read_text())
        source = json.loads((BASE / 'source/data/staff' / actor / 'dialogue_authoring.json').read_text())
        imported = set(leaves(profile)) | set(leaves(events))
        event_ids = {e['id'] for e in events}
        translated = {value for key, value in english.items() if key.startswith(f'collections.staff.{actor}.') or any(key.startswith(f'collections.time_events.{eid}.') for eid in event_ids)}
        for row in bilingual(source):
            assert row['zh_CN'] in imported, (actor, 'Chinese text missing/changed', row['zh_CN'])
            assert row['en'] in translated, (actor, 'English text missing/changed', row['en'])
            count += 1
        assert profile['preop_graphic_wrapper'] == wrappers[actor], 'User supplement changed'
        relation = json.loads((folder / 'relationship.json').read_text())
        assert not relation['met'] and relation['level'] == 0
        assert all(s['content_status'] == 'planned' and not s['event_id'] for s in relation['rank_slots'])
    print(f'RUMI SHIORI DIALOGUE AUDIT: {count} bilingual entries and 8 user-supplied lines preserved; introduction pending.')

if __name__ == '__main__': main()
