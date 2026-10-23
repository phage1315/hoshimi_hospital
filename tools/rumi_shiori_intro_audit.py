"""Compare the implemented introduction against the archived user manuscript."""
import json
import re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'research/character_references/rumi_shiori_2026-10-21/joint_intro/HOSHIMI_IWASAKI_RUMI_YONEDA_SHIORI_LV0_JOINT_INTRO_CN_CODEX_READY.md'
event = json.loads((ROOT / 'data/staff/nurse_iwasaki_rumi/events.json').read_text())[0]
source = re.findall(r'### RS0-(\d{4})｜[^\n]+\n\n([^\n]+)', SOURCE.read_text())
assert len(source) == 35
actors = {'杉村弘子': 'nurse_hiroko', '岩崎留美': 'nurse_iwasaki_rumi', '米田栞': 'nurse_yoneda_shiori'}
for i, (number, line) in enumerate(source):
    who, text = line.split('：', 1)
    node = event['nodes'][i]
    assert node['id'] == 'rs0_' + number
    assert node['text'] == text, number
    role = 'narrator' if who == '旁白' else 'player' if who == '坂口隆司' else 'actor'
    assert node['speaker'] == role
    if role == 'actor':
        assert node['actor_id'] == actors[who] and node['speaker_label'] == who
    assert node['choices'][0]['next'] == ('@end' if i == 34 else 'rs0_' + f'{i+2:04d}')
for node, text in zip(event['nodes'][35:], ['这天上午，护士站里比平时热闹了一些。', '护士站里比平时热闹了一些。']):
    assert node['text'] == text and node['choices'][0]['next'] == 'rs0_0002'
assert len(event['nodes']) == 37
print('PASS: 35 original lines, speakers and order preserved; only 2 authorized opening variants added.')
