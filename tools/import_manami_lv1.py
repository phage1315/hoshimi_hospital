#!/usr/bin/env python3
"""Deterministic import of the user-approved V2 text and staging (no prose rewriting)."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'docs/source/manami_lv1/HOSHIMI_IIMURA_MANAMI_LV1_SNEEZE_CODEX_HANDOFF_V2.md'
EVENT = 'manami_lv1_sneeze'
ACTOR = 'pharmacist_manami'
CG = {i: f'assets/events/manami_lv1_v1/cg0{i}_{name}.png' for i, name in enumerate(
    ['stretcher', 'outburst', 'pharmacy', 'recovered'], 1)}
ACTORS = {'七瀬恋': 'nurse_haru', '朝倉美幸': 'nurse_yui', '神宮寺成美': 'doc_aoi', '飯村真奈美': ACTOR}
NAMES = {'坂口隆司': 'Ryuji Sakaguchi', '七瀬恋': 'Ren Nanase', '朝倉美幸': 'Miyuki Asakura',
         '神宮寺成美': 'Narumi Jinguji', '飯村真奈美': 'Manami Iimura', '兰琪': 'Launch',
         '金发兰琪': 'Blond Launch', '陌生的女人声音': 'Unfamiliar Woman’s Voice', '女人声音': 'Woman’s Voice', '旁白': 'Narrator'}

def read(path):
    return json.loads(path.read_text(encoding='utf-8'))

def write(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

def rows():
    text = SOURCE.read_text(encoding='utf-8').split('## 第一幕｜', 1)[1].split('## C. Codex', 1)[0]
    result = []
    for line in text.splitlines():
        match = re.fullmatch(r'\*\*(L\d{3})｜(.+?)〔(.+?)〕\*\*：(.*)', line)
        if match:
            sid, speaker, intent, body = match.groups()
            result.append(dict(source_id=sid, speaker=speaker, intent=intent, text=body))
            continue
        match = re.fullmatch(r'【(S\d-A\d{2})｜([^】]+)】(.*)', line)
        if match:
            sid, intent, body = match.groups()
            result.append(dict(source_id=sid, speaker='旁白', intent=intent, text=body))
    assert len(result) == 243 and len({r['source_id'] for r in result}) == 243
    assert [r['source_id'] for r in result if r['source_id'].startswith('L')] == [f'L{i:03}' for i in range(1, 161)]
    return result

def internal(sid):
    return 'im1_' + sid.lower().replace('-', '_')

def english_speaker(who):
    base = who.split('（', 1)[0]
    suffix = ' (thinking)' if '心声' in who else ' (behind the door)' if '门内' in who else ''
    return NAMES[base] + suffix

def expression(actor, intent):
    if actor == 'launch':
        if '喷嚏' in intent or '鼻痒' in intent: return 'gold_sneeze'
        if '疑惑' in intent or '猜疑' in intent: return 'gold_confused'
        if any(s in intent for s in ['吼', '叫嚷', '暴躁', '暴怒', '激怒', '追赶']): return 'gold_shout'
        return 'gold_angry'
    if actor == ACTOR:
        if any(s in intent for s in ['专业', '果断', '自信']): return 'pharm_professional'
        if any(s in intent for s in ['思考', '审视', '认真', '日常困惑', '轻叹']): return 'pharm_thoughtful'
        if any(s in intent for s in ['大笑', '明朗', '忍俊']): return 'pharm_bright'
        if any(s in intent for s in ['狡黠', '调侃', '打趣', '玩笑']): return 'pharm_playful'
        if any(s in intent for s in ['后怕', '余悸', '疲惫', '紧张', '警告']): return 'worried'
        if any(s in intent for s in ['惊', '恐', '慌', '呆', '愕', '爆发', '生气', '瞪眼', '失控', '激动', '置信']): return 'pharm_surprised'
        return 'pharm_smile'
    if any(s in intent for s in ['微笑', '安抚', '亲切', '安慰']): return 'warm'
    if any(s in intent for s in ['严肃', '专业', '指挥', '部署', '镇定']): return 'focused'
    if any(s in intent for s in ['惊', '慌', '恐', '担', '不安', '困惑', '无言', '余悸', '失措']): return 'worried'
    return 'neutral'

def build():
    source_rows = rows()
    en = read(ROOT / 'tools/fixtures/manami_lv1_en.json')
    assert set(en) == {r['source_id'] for r in source_rows if r['text']}
    profiles = {a: read(ROOT / f'data/staff/{a}/profile.json') for a in ACTORS.values()}
    cast, expressions = [], {}
    background, cg, blue = 'or_entrance', '', False
    nodes, audit = [], []
    for r in source_rows:
        sid, who, intent = r['source_id'], r['speaker'], r['intent']
        # Explicit entrance/exit map: no NPC registration and no protagonist sprite.
        entrances = {'S2-A05':['nurse_haru'], 'S2-A06':['nurse_haru','nurse_yui'],
            'S2-A07':['nurse_haru','nurse_yui','doc_aoi'],
            'S2-A15':['launch','nurse_haru','nurse_yui','doc_aoi'],
            'S3-A06':['nurse_haru','nurse_yui','doc_aoi'],
            'S3-A07':[ACTOR], 'S4-A03':['launch',ACTOR],
            'S5-A07':['launch',ACTOR,'nurse_haru'], 'S5-A11':['nurse_haru',ACTOR],
            'L098':['nurse_haru','nurse_yui',ACTOR], 'S5-A13':['doc_aoi','nurse_haru',ACTOR],
            'S5-A15':['doc_aoi',ACTOR], 'L110':[ACTOR], 'S6-A01':[ACTOR], 'S6-A14':[]}
        if sid in entrances:
            cast = entrances[sid]
            for a in cast: expressions.setdefault(a, 'gold_angry' if a == 'launch' else 'pharm_smile' if a == ACTOR else 'worried')
        if sid == 'S2-A15': background = 'hallway'
        if sid == 'S3-A07': background = 'pharmacy'
        match = re.search(r'CG-0([1-4]) 显示', intent)
        if match: cg = CG[int(match.group(1))]
        if re.search(r'CG-0[1-4] 退出', intent): cg = ''
        if sid == 'S4-A17':
            blue = True
            expressions['launch'] = 'blue_confused'
        if sid in ['S5-A03','S5-A04']: expressions['launch'] = 'blue_shy'
        # Voice identity remains exactly as authored; art state is independent.
        actor = ACTORS.get(who.split('（', 1)[0], 'launch' if '兰琪' in who else '')
        if actor in cast and sid.startswith('L'):
            if actor == 'launch' and blue:
                expressions[actor] = 'blue_shy' if any(s in intent for s in ['羞','歉疚']) else 'blue_worried' if any(s in intent for s in ['不安','内疚']) else 'blue_confused' if any(s in intent for s in ['茫然','困惑','疑惑']) else 'blue_smile'
            else: expressions[actor] = expression(actor, intent)
        stage_expressions = {'S4-A06':(ACTOR,'pharm_thoughtful'), 'S4-A07':(ACTOR,'pharm_professional'),
            'S4-A15':('launch','gold_sneeze'), 'S6-A05':(ACTOR,'pharm_bright'),
            'S6-A06':(ACTOR,'pharm_thoughtful'), 'S6-A08':(ACTOR,'pharm_playful'),
            'S6-A09':(ACTOR,'pharm_smile'), 'S6-A10':(ACTOR,'pharm_bright'),
            'S6-A12':(ACTOR,'pharm_smile'), 'S6-A13':(ACTOR,'pharm_smile')}
        if sid in stage_expressions:
            a, expr = stage_expressions[sid]; expressions[a] = expr
        node = {'id':internal(sid), 'presentation':'authored' if r['text'] else 'stage',
            'speaker':'narrator' if who == '旁白' else 'player' if who.startswith('坂口') else 'actor',
            'speaker_label':who, 'text':r['text'], 'expression':'neutral', 'background_id':background,
            'event_portraits':[]}
        for i,a in enumerate(cast):
            expr = expressions[a]
            path = f'assets/characters/launch_event_v1/{expr}.png' if a == 'launch' else profiles[a]['visuals']['portraits'][('pharmacist' if a == ACTOR else 'scrubs') + '/' + expr]
            assert (ROOT / path).exists(), path
            width = 400 if len(cast) <= 2 else 310 if len(cast) == 3 else 275
            x = [920] if len(cast) == 1 else [460,970] if len(cast) == 2 else [280,660,1050] if len(cast) == 3 else [190,490,790,1090]
            # The approved Launch assets are shoulder busts, not standing
            # sprites: keep their crop edge above the VN continue button.
            node['event_portraits'].append({'id':a,'path':path,'x':x[i],'width':width,'height':310 if a == 'launch' else 400,'bottom':475 if a == 'launch' else 550})
        if cg: node.update(cg_path=cg, cg_fit='contain', event_portraits=[])
        if not r['text']: node['auto_seconds'] = 0.25
        if '黑屏' in intent:
            node.update(stage_effect='black', auto_seconds=0.8, event_portraits=[])
        elif '短暂停顿' in intent: node['auto_seconds'] = 0.65
        if sid in ['S2-A04','S2-A08','S4-A04','S4-A05','S4-A12']: node['stage_effect'] = 'shake'
        if sid == 'S4-A13': node['stage_effect'] = 'dust'
        if sid == 'S4-A17': node['stage_effect'] = 'flash'
        if sid == 'S1-A01': node.update(scene_caption='下午', auto_seconds=1.0)
        if sid == 'S6-A01': node.update(scene_caption='稍后', auto_seconds=1.0)
        nodes.append(node)
        audit.append({'source_id':sid,'node_id':node['id'],'intent':intent,'expressions':dict(expressions),
            'visible_actors':[p['id'] for p in node['event_portraits']], 'cg':cg})
    for i,n in enumerate(nodes):
        n['choices'] = [{'id':'continue_'+n['id'],'label':{'zh_CN':'继续  ▷','en':'Continue  ▷'},
            'next':nodes[i+1]['id'] if i+1<len(nodes) else '@end', 'effects':{'affection':0,'familiarity':0},'flags':[]}]
    event = {'id':EVENT,'actor_id':ACTOR,'title':'救命！打个喷嚏！','chapter':1,'target_level':1,
        'category':'bond','benefit_id':'','location_id':'or','trigger_mode':'location','background_id':'or_entrance',
        'outfit':'pharmacist','minutes':30,'teaser':'不过是一台小手术','time_start':540,'time_end':1020,
        'priority':100,'auto_start':False,'cinematic':True,'hide_completion_portrait':True,
        'gallery':{'cg_id':'cg_manami_lv1_sneeze','caption':'救命！打个喷嚏！','path':CG[3],'show_on_complete':False},
        'conditions':{'min_day':1,'min_affection':0,'min_familiarity':10,'required_events':['intro_pharmacist_manami'],'special_requirements':[]},
        'start':nodes[0]['id'],'nodes':nodes}
    return event, source_rows, en, audit

def main():
    event, source_rows, en, audit = build()
    path = ROOT / f'data/staff/{ACTOR}/events.json'
    events = read(path)
    events = [e for e in events if e['id'] != EVENT] + [event]
    write(path, events)
    path = ROOT / f'data/staff/{ACTOR}/relationship.json'
    relation = read(path)
    slot = next(s for s in relation['rank_slots'] if s['target_level'] == 1)
    assert slot['event_id'] in ['', EVENT], 'Existing Lv1 conflict'
    slot.update(event_id=EVENT, content_status='authored')
    write(path, relation)
    for locale in ['zh_CN','en']:
        path = ROOT / f'data/localization/{locale}.json'
        doc = read(path); strings = doc['strings']; prefix = f'collections.character_events.{EVENT}.'
        for key in list(strings):
            if key.startswith(prefix): del strings[key]
        for field, translation in [('title','Help! Sneeze!'),('teaser','Just a Minor Operation')]:
            strings[prefix+field] = translation if locale == 'en' else event[field]
        strings[prefix+'gallery.caption'] = 'Help! Sneeze!' if locale == 'en' else event['title']
        for r,n in zip(source_rows,event['nodes']):
            p = prefix+'nodes.'+n['id']
            if r['text']:
                strings[p+'.text'] = (('“'+en[r['source_id']]+'”') if r['source_id'].startswith('L') else en[r['source_id']]) if locale=='en' else n['text']
            strings[p+'.speaker_label'] = english_speaker(r['speaker']) if locale=='en' else r['speaker']
            if 'scene_caption' in n: strings[p+'.scene_caption'] = ('Afternoon' if n['scene_caption']=='下午' else 'Later') if locale=='en' else n['scene_caption']
        write(path,doc)
    write(ROOT/'docs/source/manami_lv1/node_mapping.json',audit)
    print('Imported 160 exact dialogue + 83 stage/action nodes, both locales, four CGs, existing Lv1 gate.')

if __name__ == '__main__':
    main()
