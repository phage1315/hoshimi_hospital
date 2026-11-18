"""Preserve approved Artoria CG assignments on manuscript re-import."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def apply_cg_mapping(event):
    mappings = json.loads((ROOT / 'data/staff/doc_artoria/cg_mapping.json').read_text())
    mapping = mappings.get(event['id'])
    if not mapping:
        return
    nodes = {node['id']: node for node in event['nodes']}
    for scene in mapping.get('scenes', []):
        if not (ROOT / scene['path']).is_file():
            raise FileNotFoundError(scene['path'])
        for node_id in scene['nodes']:
            nodes[node_id].update(cg_path=scene['path'], cg_fit='contain', cg_dialogue_delay_seconds=2.0)
    cover = mapping.get('cover', '')
    if cover:
        if not (ROOT / cover).is_file():
            raise FileNotFoundError(cover)
        event['gallery']['path'] = cover
        event['gallery']['show_on_complete'] = True
