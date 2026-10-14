#!/usr/bin/env python3
"""Exercise idle-chat schema and cross-file rules without editing game data."""
import copy
import json
from pathlib import Path

from jsonschema import Draft202012Validator
from staff_bundles import load_staff_bundles
from staff_idle_chat_contract import staff_idle_chat_errors, staff_social_locations

ROOT = Path(__file__).resolve().parents[1]


def main():
    schema = json.loads((ROOT / 'data/schemas/content.schema.json').read_text())
    Draft202012Validator.check_schema(schema)
    validator = Draft202012Validator({'$ref': '#/$defs/time_event', '$defs': schema['$defs']})
    manifest = json.loads((ROOT / 'data/manifest.json').read_text())
    collections, bundles = load_staff_bundles(ROOT / 'data', manifest['staff_bundles'])
    profiles = {p['id']: p for p in collections['staff']}
    failures = []
    checks = 0

    def expect(condition, label):
        nonlocal checks
        checks += 1
        if not condition:
            failures.append(label)

    for relative, bundle in bundles:
        folder = (ROOT / 'data' / manifest['staff_bundles']['index']).parent / Path(relative).parent
        events = json.loads((folder / bundle['time_events']).read_text()) if bundle.get('time_events') else []
        profile = profiles[bundle['id']]
        expect(not staff_idle_chat_errors(profile, bundle, events), bundle['id'] + ': authored coverage')
        required = staff_social_locations(profile)
        if required:
            unregistered = dict(bundle)
            unregistered.pop('time_events', None)
            expect(bool(staff_idle_chat_errors(profile, unregistered, [])), bundle['id'] + ': unregistered file rejected')
            expect(bool(staff_idle_chat_errors(profile, unregistered, events)), bundle['id'] + ': rows do not replace registration')
        for location in required:
            missing = [e for e in events if e['location_id'] != location]
            expect(bool(staff_idle_chat_errors(profile, bundle, missing)), bundle['id'] + ': missing ' + location)
            wrong_owner = copy.deepcopy(events)
            for event in wrong_owner:
                if event['location_id'] == location:
                    event['actor_id'] = 'some_other_staff'
            expect(bool(staff_idle_chat_errors(profile, bundle, wrong_owner)), bundle['id'] + ': borrowed speaker rejected')
        for event in events:
            expect(validator.is_valid(event), event['id'] + ': authored schema')
            mutations = [('label', ''), ('label', '　 '), ('minutes', 10), ('repeatable', False),
                         ('effects', {'charm': 1}), ('effects', {'familiarity': 1}),
                         ('responses', []), ('responses', None), ('responses', 'text')]
            for bad in ('', '  ', '\t\n', '　', None, 1, []):
                mutations.append(('responses', [bad] + event['responses'][1:]))
            mutations.append(('responses', [event['responses'][0]] * 3))
            if event['location_id'] in {'lounge', 'rooftop'}:
                mutations.extend([('responses', event['responses'][:1]), ('responses', event['responses'][:2])])
            for field, value in mutations:
                broken = copy.deepcopy(event)
                broken[field] = value
                expect(not validator.is_valid(broken), event['id'] + ': reject ' + field + repr(value))
            for field in ('actor_id', 'responses', 'minutes', 'repeatable', 'location_id', 'label'):
                broken = dict(event)
                del broken[field]
                expect(not validator.is_valid(broken), event['id'] + ': missing ' + field)
            extended = copy.deepcopy(event)
            extended['responses'].append('Schema-only independent fourth response')
            extended['effects'] = {}
            expect(validator.is_valid(extended), event['id'] + ': more responses and empty effects allowed')

    base = copy.deepcopy(profiles['doc_asuka'])
    sample = copy.deepcopy(next(e for e in collections['time_events'] if e['actor_id'] == 'doc_asuka' and e['location_id'] == 'lounge'))
    registered = {'time_events': 'time_events.json'}
    base['presence'] = {'fixed_locations': ['lounge'], 'random_locations': [], 'rooftop_enabled': False}
    expect(not staff_idle_chat_errors(base, registered, [sample]), 'fixed social location supported')
    expect(bool(staff_idle_chat_errors(base, registered, [])), 'fixed location requires chat too')
    base['presence'] = {'fixed_locations': ['clinic'], 'random_locations': [], 'rooftop_enabled': False}
    expect(bool(staff_idle_chat_errors(base, registered, [sample])), 'unconfigured social location rejected')
    expect(not staff_idle_chat_errors(base, {}, []), 'non-social staff not forced to invent social presence')
    del base['presence']['rooftop_enabled']
    expect(bool(staff_idle_chat_errors(base, {}, [])), 'default rooftop eligibility requires dialogue even without random locations')
    roof_sample = copy.deepcopy(sample)
    roof_sample['location_id'] = 'rooftop'
    expect(not staff_idle_chat_errors(base, registered, [roof_sample]), 'independent rooftop chat accepted')
    base['presence']['rooftop_enabled'] = False
    expect(bool(staff_idle_chat_errors(base, registered, [roof_sample])), 'explicit rooftop exclusion rejects unreachable chat')
    for event in json.loads((ROOT / 'data/time_events.json').read_text()):
        expect(validator.is_valid(event), event['id'] + ': existing solo action unchanged')
    print('\n'.join(failures)) if failures else None
    print(f'STAFF IDLE CHAT SCHEMA: {checks} checks; {len(failures)} failure(s)')
    return bool(failures)


if __name__ == '__main__':
    raise SystemExit(main())
