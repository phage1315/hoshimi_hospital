#!/usr/bin/env python3
"""Lossless, deterministic import of the approved three-day fixed VN.

Chinese is read only from the archived source. Presentation and English are
separate, reviewable inputs; no keyword-based rewriting or runtime surgery.
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'docs/source/chihaya_second_surgery/HOSHIMI_CHIHAYA_SECOND_SURGERY_CODEX_READY_V1_RUMI_REVISION.md'
PREFIX = 'chihaya_second_surgery_'
ART = 'assets/characters/patient_chihaya_second_surgery_v1'
MIZUHO = 'assets/characters/mizuho_story_v1'
ACTORS = {'阿库娅': 'doc_aqua', '七濑恋': 'nurse_haru',
          '岩崎留美': 'nurse_iwasaki_rumi', '利根川安琪': 'nurse_ange'}
NAMES = {'旁白': 'Narrator', '坂口': 'Ryuji Sakaguchi', '千早': 'Chihaya Kuramoto',
         '瑞穗': 'Mizuho Shite', '阿库娅': 'Aqua Mizuki', '七濑恋': 'Ren Nanase',
         '岩崎留美': 'Rumi Iwasaki', '利根川安琪': 'Ange Tonegawa'}

def read(path):
    return json.loads((ROOT / path).read_text())

def write(path, value):
    (ROOT / path).write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n')

def rows():
    body = SOURCE.read_text().split('## 二、完整玩家可见剧本（按阶段原序播放）', 1)[1].split('## 非玩家可见：', 1)[0]
    section, counts, result = '', {}, []
    sections = {'## 第一幕': 'a1', '## 第二幕': 'a2', '### 3-A': 'b1', '### 3-B': 'b2',
                '### 3-C': 'b3', '### 3-D': 'b4', '### 3-E': 'b5', '### 3-F': 'b6',
                '## 第四幕': 'c1', '### 尾声': 'c2'}
    for line in body.splitlines():
        line = line.strip()
        for heading, key in sections.items():
            if line.startswith(heading):
                section = key
        if not line or line.startswith('#') or line == '---':
            continue
        if line == '**【事件结束】**':
            line = '【事件结束】'
        match = re.fullmatch(r'([^：]+)：(「.*」)', line)
        if line.startswith('【') and line.endswith('】'):
            who, text = '旁白', line
        elif match:
            who, text = match.groups()
        else:
            raise ValueError(f'Unparsed source: {line}')
        counts[section] = counts.get(section, 0) + 1
        result.append(dict(id=f'{section}_{counts[section]:03}', speaker=who, text=text, section=section))
    return result

def build():
    source = rows()
    translations = read('tools/fixtures/chihaya_second_surgery_en.json')
    staging = read('tools/fixtures/chihaya_second_surgery_staging.json')
    approved_cgs = read('tools/fixtures/chihaya_second_surgery_cgs.json')
    unmet_variants = read('tools/fixtures/chihaya_second_surgery_unmet_variants.json')
    assert set(translations) == {r['id'] for r in source}, 'English must cover every source paragraph'
    profiles = {a: read(f'data/staff/{a}/profile.json') for a in ACTORS.values()}
    state = {}
    all_nodes = []
    for r in source:
        sid, who, text = r['id'], r['speaker'], r['text']
        if sid in staging:
            state.update(staging[sid])
        base = who.split('（')[0]
        assert base in NAMES, who
        node = dict(id=sid, speaker='narrator' if base == '旁白' else 'player' if base == '坂口' else 'actor',
                    speaker_label=who, text=text, expression='neutral',
                    background_id=state['background'], event_portraits=[])
        # Independent cast layout, including cameos which are not staff unlocks.
        cast = state.get('cast', [])
        for i, person in enumerate(cast):
            style = state[person]
            if person == 'chihaya':
                path = f'{ART}/{style}.png'
            elif person == 'mizuho':
                path = f'{MIZUHO}/{style}.png'
            else:
                path = profiles[person]['visuals']['portraits'][style]
            assert (ROOT / path).is_file(), path
            x = [950] if len(cast) == 1 else [480, 980] if len(cast) == 2 else [290, 670, 1050]
            node['event_portraits'].append(dict(id=person, path=path, x=x[i], width=350,
                height=270 if style.startswith('intraoperative/') else 400,
                bottom=475 if style.startswith('intraoperative/') else 550))
        if base in ACTORS:
            node['actor_id'] = ACTORS[base]
        # A present-but-empty cast must still reach CharacterStage's renderer.
        node['hide_portrait'] = not cast
        node.update(approved_cgs.get(sid, {}))
        if sid in unmet_variants:
            node['unmet_variant'] = unmet_variants[sid]
        all_nodes.append(node)
    definitions, steps = [], []
    en = read('data/localization/en.json')
    strings = en['strings']
    strings['ui.special_event.partial_day_complete'] = 'Duration: %s minutes / Now %s %s'
    for part, minutes in [('a', 120), ('b', 300), ('c', 60)]:
        eid = PREFIX + part
        step_id = eid + '_main'
        title = '说好这次不跑的'
        nodes = [n for n in all_nodes if n['id'].startswith(part)]
        for i, n in enumerate(nodes):
            n['choices'] = [dict(id='continue', label='继续', next=nodes[i+1]['id'] if i+1 < len(nodes) else '@day_end', requirements=[])]
            key = f'collections.special_event_steps.{step_id}.nodes.{n["id"]}'
            strings[key + '.text'] = translations[n['id']]
            who = n['speaker_label']
            name = NAMES[who.split('（')[0]]
            strings[key + '.speaker_label'] = name + (' (thinking)' if '心声' in who else ' (quietly)' if '压低声音' in who else '')
            strings[key + '.choices.continue.label'] = 'Continue'
        flags = [eid + '_complete']
        if part == 'a': flags += ['chihaya_identity_revealed']
        if part == 'b': flags += ['chihaya_second_surgery_success']
        if part == 'c': flags += ['chihaya_second_surgery_complete', 'mizuho_identity_revealed', 'met_mizuho_story']
        definitions.append(dict(id=eid, title=title, category='story_special_event', duration_days=1,
            consumes_full_day=False, settled_minutes=minutes, repeatable=False, developer_only=False,
            auto_schedule=True, mandatory_auto_start=True, trigger_mode='day_start',
            unlock_requirements=[], required_characters=[], prerequisite_events=[], event_chain=[step_id],
            completion_flags=flags, gallery_unlock=True,
            gallery_entry=dict(id=eid, title=title, chapters=['完整回放']),
            timing=dict(trigger_date='2025-05-19', priority=600 if part == 'a' else 10000,
                        final_week_allowed=True, sunday_start_allowed=True)))
        steps.append(dict(id=step_id, title=title, background_id=nodes[0]['background_id'], start=nodes[0]['id'], nodes=nodes))
        for key in [f'collections.special_events.{eid}.title', f'collections.special_events.{eid}.gallery_entry.title',
                    f'collections.special_event_steps.{step_id}.title']:
            strings[key] = "You Promised Not to Run This Time"
        strings[f'collections.special_events.{eid}.gallery_entry.chapters.0'] = 'Full Replay'
    write('data/events/special_events/chihaya_second_surgery.json', definitions)
    write('data/events/special_event_steps/chihaya_second_surgery.json', steps)
    for folder in ['special_events', 'special_event_steps']:
        path = f'data/events/{folder}/index.json'
        index = read(path)
        if 'chihaya_second_surgery.json' not in index['files']:
            index['files'].append('chihaya_second_surgery.json')
        write(path, index)
    write('data/localization/en.json', en)
    print(f'Imported {len(source)} exact source paragraphs across A/B/C; English complete.')

if __name__ == '__main__':
    import sys
    if '--list' in sys.argv:
        for r in rows():
            print(r['id'], r['speaker'], r['text'])
    else:
        build()
