#!/usr/bin/env python3
"""Compare every imported Sunday dating line with the user's preserved source."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ACTORS = ['doc_asuka','doc_aoi','doc_rei','doc_emiko','doc_artoria','doc_shiori','doc_aqua','doc_sayaka','doc_minato','nurse_haru','nurse_rin','nurse_yui','nurse_ange','nurse_hiroko','nurse_moe','nurse_satsuki','pharmacist_manami','doc_sakura_anesthesiology','nurse_ishigami','visiting_futaba','visiting_maya']
CLOSED = {'nurse_ange','doc_sakura_anesthesiology','nurse_ishigami','visiting_futaba','visiting_maya'}
source = (ROOT / 'docs/source/HOSHIMI_SUNDAY_DATE_CHARACTER_VENUE_PREFERENCES.md').read_text()
blocks = [b for b in re.split(r'^### ', source, flags=re.M) if re.search(r'^- \*\*接受约会：', b, re.M)]
assert len(blocks) == len(ACTORS)
checks = 0
for actor, block in zip(ACTORS, blocks):
    profile = json.loads((ROOT / 'data/staff' / actor / 'date_profiles.json').read_text())[0]
    quoted = re.findall(r'^- \*\*(?:接受约会|拒绝约会|约会满意|特别满意 — .+?)：\*\* .+?：(「.*」)$', block, re.M)
    assert len(quoted) == 5, actor
    assert profile['invite_rejection']['text'] == quoted[1], actor
    checks += 1
    if actor in CLOSED:
        assert not profile['can_date'] and 'dialogue' not in profile, actor
        continue
    dialogue = profile['dialogue']
    actual = [dialogue['accepted']['text'], dialogue['satisfied']['text']] + [f['text'] for f in dialogue['favorites']]
    assert actual == [quoted[0], *quoted[2:]], actor
    assert [f['id'] for f in dialogue['favorites']] == profile['preferred_locations'], actor
    checks += len(actual)
print(f'SUNDAY SOURCE AUDIT: {checks}/85 exact Chinese lines; 5 closed profiles remain refusal-only')
