#!/usr/bin/env python3
"""Deterministic V1.6 extraction/audit. Emits apply_patch input; never writes files.

Default mode compares every imported line to the archived author source.
--emit-patch produces only the scoped data/localization changes for apply_patch.
Unused candidates and six complete v2 sets remain in the verbatim source archive.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'docs/sources/HOSHIMI_SAYAKA_STAFF_AS_PATIENT_DIALOGUE_DRAFT_V1_6_CN_EN.md'
PROFILE = ROOT / 'data/staff_patient_profiles.json'
REQUIRED_AGREEMENT = [
    'hysterectomy_signature_01', 'ovarian_cystectomy_signature_01',
    'myomectomy_signature_01', 'breast_tumor_signature_01',
    'mastectomy_signature_01', 'cabg_signature_01',
    'pelvic_dignity_exposure_01', 'pelvic_dignity_default_01',
    'breast_dignity_exposure_01', 'breast_dignity_default_01',
    'breast_closure_fear_01',
]


def section(text, start, end):
    return text.split(start, 1)[1].split(end, 1)[0]


def rows(text):
    return [[c.strip() for c in line.strip().strip('|').split('|')]
            for line in text.splitlines() if line.startswith('| `')]


def key(cell):
    return re.search(r'`([^`]+)`', cell)[1]


def build(text):
    pools = {p['id']: p for p in json.loads((ROOT / 'data/surgeries/patient_interactions.json').read_text())}
    surgery_ids = {s['id'] for s in json.loads((ROOT / 'data/surgeries/surgeries.json').read_text())}
    base_invites = rows(section(text, '### A1.', '### A1b.'))
    special = {key(r[0]).removeprefix('SAP-SAYAKA-INVITE-'): r[2:4]
               for r in rows(section(text, '### A1b.', '### A1c.'))}
    mapping = rows(section(text, '### A1c.', '### A2.'))
    assert len(mapping) == 32 and {key(r[0]) for r in mapping} == surgery_ids
    core = rows(section(text, '### B1.', '### B1a.'))
    variants = rows(section(text, '### B2.', '### B3.'))
    incisions = rows(section(text, '### B3.', '## C.'))
    vh = rows(section(text, '### B1a-VH.', '### B2.'))
    assert [key(r[0]) for r in vh] == ['field', 'bowel', 'bowel_answer', 'bladder', 'manipulator']
    question = next(r for r in rows(section(text, '### B1a.', '### B1a-VH.'))
                    if key(r[0]) == 'graphic_preop_question')
    c2 = section(text, '#### C2 正文', '#### C2 编剧备用')
    parts = re.split(r'^\*\*`([^`]+)`\*\*', c2, flags=re.M)
    table = rows(section(text, '#### 覆盖总表（全部 50 个）', '#### C2 正文'))
    assert len(table) == 50
    for row in table:
        pid = key(row[0])
        assert set(re.findall(r'`([^`]+)`', row[2])) == {a['id'] for a in pools[pid]['actions']}, pid
    dialogues = {}
    for index, locale in enumerate(['zh_CN', 'en']):
        d = {'invitation_lines': [r[index + 1] for r in base_invites],
             'invitation_by_procedure': {}, 'reaction_lines': {},
             'reaction_variants': {}, 'reaction_speakers': {},
             'stage_prompts': {}, 'interaction_overrides': {},
             'graphic_preop_by_procedure': {}, 'practice_labels': []}
        for row in mapping:
            category = row[3]
            d['invitation_by_procedure'][key(row[0])] = (
                list(d['invitation_lines']) if 'A1' in category else [special[category][index]])
        for row in core + incisions:
            rid = key(row[0])
            if rid == 'incise_general':
                continue  # This row is a silence instruction, not dialogue.
            d['reaction_lines'][rid] = row[index + 1]
            d['reaction_speakers'][rid] = 'patient'
        for row in variants:
            d['reaction_variants'].setdefault(key(row[0]), []).append(row[index + 2])
        assert len(d['reaction_variants']) == 11
        assert all(len(v) == 2 for v in d['reaction_variants'].values())
        # Remove the table's attribution label, not any authored spoken text.
        attribution = '南条小夜香：' if index == 0 else 'Sayaka: '
        assert question[index + 1].startswith(attribution)
        d['stage_prompts']['graphic_preop_question'] = question[index + 1][len(attribution):]
        d['graphic_preop_by_procedure']['surgery_vaginal_hysterectomy'] = {
            key(r[0]): {'speaker': 'patient' if key(r[0]) in ['bowel', 'bladder'] else 'explainer',
                        'text': r[index + 2]} for r in vh}
        for i in range(1, len(parts), 2):
            pid, body = parts[i:i + 2]
            sets = re.split(r'^\*\*v[12].*$', body, flags=re.M)[1:]
            if not sets:
                continue
            assert pid in pools
            # Import complete v1 only. v2 is archived, never independently randomized.
            v1 = sets[0]
            prompts = dict(re.findall(r'^- \*\*Prompt (CN|EN).*?\*\*\s*(.+)$', v1, re.M))
            responses = {key(r[0]): r[index + 2] for r in rows(v1)}
            assert set(responses) == {a['id'] for a in pools[pid]['actions']}, pid
            d['interaction_overrides'][pid] = {'prompt': prompts['CN' if index == 0 else 'EN'],
                                              'responses': responses}
        assert len(d['interaction_overrides']) == 39
        reward_section = section(text, '## F. 奖励提示', '## V1.6 追加接线')
        reward_rows = [l.strip('|').split('|') for l in reward_section.splitlines()
                       if l.startswith(('| 首次组合', '| 再次练习', '| 已熟练'))]
        d['practice_labels'] = [r[index + 1].strip() for r in reward_rows]
        assert len(d['practice_labels']) == 3
        if locale == 'en':
            assert not re.search(r'[\u3400-\u9fff]', json.dumps(d, ensure_ascii=False))
        dialogues[locale] = d
    return dialogues


def replacement_patch(path, before, after):
    if before == after:
        return ''
    return ('*** Update File: ' + str(path) + '\n@@\n'
            + ''.join('-' + line + '\n' for line in before.splitlines())
            + ''.join('+' + line + '\n' for line in after.splitlines()))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--emit-patch', action='store_true')
    args = parser.parse_args()
    text = SOURCE.read_text()
    expected = build(text)
    old = PROFILE.read_text()
    profiles = json.loads(old)
    profile = profiles['doc_sayaka']
    if not args.emit_patch:
        assert profile['dialogue'] == expected, 'Imported text differs from V1.6 source'
        assert profile['agreement_required_interaction_ids'] == REQUIRED_AGREEMENT
        assert profile['dialogue_source_sha256'] == hashlib.sha256(SOURCE.read_bytes()).hexdigest()
        print('SAYAKA V1.6 SOURCE AUDIT: CN/EN exact; 32 invitations; 39 active pools; '
              '11 fallback pools; 11 double variants; 5 scoped explanation nodes. PASS')
        return
    profile.update(dialogue=expected, dialogue_status='v1_6_integrated',
                   dialogue_source=str(SOURCE.relative_to(ROOT)),
                   dialogue_source_sha256=hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
                   agreement_required_interaction_ids=REQUIRED_AGREEMENT)
    patch = replacement_patch(PROFILE, old, json.dumps(profiles, ensure_ascii=False, indent=2) + '\n')
    interactions_path = ROOT / 'data/surgeries/patient_interactions.json'
    original = interactions_path.read_text()
    neutral = '引导她缓慢呼气并放松紧绷的部位'
    assert neutral in text
    changed = original.replace('"label": "提示她放松腹部并缓慢呼气"', '"label": "' + neutral + '"')
    patch += replacement_patch(interactions_path, original, changed)
    for locale in ['zh_CN', 'en']:
        path = ROOT / f'data/localization/{locale}.json'
        original = path.read_text()
        data = json.loads(original)
        # Existing locale files contain flat UI and authored-key maps.
        for container in [data] + [v for v in data.values() if isinstance(v, dict)]:
            for k in container:
                if k.endswith('strain_pain_traction_02.actions.coach_second_traction.label') and locale == 'zh_CN':
                    container[k] = neutral
        patch += replacement_patch(path, original, json.dumps(data, ensure_ascii=False, indent=2) + '\n')
    print('*** Begin Patch\n' + patch + '*** End Patch')


if __name__ == '__main__':
    main()
