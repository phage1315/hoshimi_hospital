"""Load isolated staff bundles into the runtime collection shape."""
import json
from pathlib import Path


ARRAY_PARTS = {
    'character_events': 'character_events',
    'special_events': 'special_events',
    'special_event_steps': 'special_event_steps',
    'date_profiles': 'date_profiles',
    'role_rewards': 'staff_role_cg_rewards',
    'time_events': 'time_events',
    'micro_events': 'micro_events',
}


def load_staff_bundles(data_root: Path, config: dict):
    index_path = data_root / config['index']
    index = json.loads(index_path.read_text())
    if not isinstance(index, list):
        raise ValueError(f'Invalid staff bundle index: {index_path}')
    collections = {
        'staff': [],
        'relationships': [],
        'character_events': [],
        'special_events': [],
        'special_event_steps': [],
        'date_profiles': [],
        'staff_role_cg_rewards': [],
        'time_events': [],
        'micro_events': [],
    }
    bundles = []
    seen = set()
    for relative_path in index:
        bundle_path = index_path.parent / relative_path
        bundle = json.loads(bundle_path.read_text())
        bundle_id = bundle.get('id', '')
        if bundle.get('schema_version') != 1 or not bundle_id or bundle_id in seen:
            raise ValueError(f'Invalid or duplicate staff bundle: {bundle_path}')
        seen.add(bundle_id)
        bundle_dir = bundle_path.parent
        profile = json.loads((bundle_dir / bundle['profile']).read_text())
        relationship = json.loads((bundle_dir / bundle['relationship']).read_text())
        if profile.get('id') != bundle_id:
            raise ValueError(f'Staff profile id mismatch: {bundle_path}')
        if relationship.get('target_id') != bundle_id:
            raise ValueError(f'Staff relationship id mismatch: {bundle_path}')
        collections['staff'].append(profile)
        collections['relationships'].append(relationship)
        for part_key, collection_key in ARRAY_PARTS.items():
            if part_key not in bundle:
                continue
            rows = json.loads((bundle_dir / bundle[part_key]).read_text())
            if not isinstance(rows, list):
                raise ValueError(f'Staff bundle part must be an array: {bundle_dir / bundle[part_key]}')
            collections[collection_key].extend(rows)
        bundles.append((relative_path, bundle))
    return collections, bundles
