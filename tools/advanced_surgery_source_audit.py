#!/usr/bin/env python3
"""Audit the standalone Advanced data against the archived author POC."""
import importlib.util
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'docs/source/advanced_surgery_v1'
DATA = ROOT / 'data/advanced_surgery'
spec = importlib.util.spec_from_file_location('advanced_author', SOURCE / 'hoshimi_advanced_surgery_balance_sim.py')
author = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = author
spec.loader.exec_module(author)
checks = 0

def check(ok, message):
    global checks
    checks += 1
    if not ok:
        raise AssertionError(message)

def read(path):
    return json.loads(path.read_text())

def en(value, label):
    check(isinstance(value, str) and bool(value.strip()), label + ': missing English')
    check(not re.search(r'[\u4e00-\u9fff]', value), label + ': Chinese remains')

procedures = read(DATA / 'procedures.json')
fixtures = read(DATA / 'test_fixtures.json')
check(len({p['id'] for p in procedures}) == len(procedures), 'Unique procedure IDs')
# This audit owns the original three POC baselines; later authored additions
# have separate source audits and must not invalidate or skip these locks.
by_id = {p['id']: p for p in procedures}
for i, case in enumerate(author.CASES):
    check(case.code in by_id, 'Original prototype retained')
    actual = by_id[case.code]
    check(actual['id'] == case.code and actual['name'] == case.name, 'Procedure identity and Chinese title')
    check(actual['duration_minutes'] == 480 and actual['reward_tier'] == 'advanced', 'Full-day window and explicit Advanced tier')
    en(actual['name_en'], case.code)
    en(actual['patient_notice_en'], case.code)
    check(actual['crisis_checkpoints'] == list(case.crisis_checkpoints), 'Checkpoints')
    check(actual['crisis_chances'] == list(case.crisis_chances), 'POC crisis probabilities')
    check(len(actual['steps']) == len(case.steps), 'Stage count')
    check(len(set(s['id'] for s in actual['steps'])) == len(case.steps), 'Unique stage IDs')
    check(sum(s['kind'] == 'P' for s in actual['steps']) == [6, 6, 5][i], 'Precision count')
    for step, data in zip(case.steps, actual['steps']):
        for src, dst in [('code','id'),('name','name'),('kind','kind'),('hp','hp_base'),('difficulty','difficulty'),('tag','specialty_tag'),('fail_hp','hp_failed_extra')]:
            check(getattr(step, src) == data[dst], case.code + '/' + step.code + '/' + dst)
        en(data['name_en'], step.code)
    teams = author.make_teams(case)
    check(len(fixtures[case.code]) == len(teams), 'Four fixture teams')
    for team, data in zip(teams, fixtures[case.code]):
        for key in ['name','player','primary_scrub','secondary_scrub','primary_circ','secondary_circ']:
            check(getattr(team, key) == data[key], 'Fixture ' + key)
        en(data['name_en'], team.name)
        for surgeon, actor in zip([team.first,team.second], data['assistants']):
            for key in ['name','skill','universal_expert']:
                check(getattr(surgeon, key) == actor[key], 'Assistant fixture ' + key)
            check(list(surgeon.specialties) == actor['specialties'], 'Fixture specialties')
            en(actor['name_en'], surgeon.name)

strings = read(DATA / 'ui_text.json')
for key, pair in strings.items():
    check(isinstance(pair,list) and len(pair) == 2 and bool(pair[0]), key + ': bilingual pair')
    en(pair[1], key)
    check(re.findall(r'%(?:s|d|f|%)',pair[0]) == re.findall(r'%(?:s|d|f|%)',pair[1]), key + ': interpolation parity')
source_text = (SOURCE / 'HOSHIMI_ADVANCED_SURGERY_STANDALONE_CODEX_READY_V1.md').read_text()
for key in ['intro','line1','line2']:
    check(strings[key][0] in source_text, 'Authored text verbatim: ' + key)
view_text = (ROOT / 'godot/ui/advanced_referral_view.gd').read_text()
for key in re.findall(r'tr_key\("([^"\n]+)"\)', view_text):
    if key != 'roles.': check(key in strings, 'UI key: ' + key)
# Optional generated baseline reports: no Monte Carlo work during normal audit.
qa = ROOT / 'docs/qa/advanced_surgery_2026_10_30'
report_path = qa / 'godot_balance.json'
if report_path.exists():
    godot = read(report_path)
    python = [r for r in read(qa / 'python_balance.json')['results'] if r['policy'] == 'planned']
    for row, baseline in zip(godot, python):
        case = next(c for c in author.CASES if c.code == row['procedure_id'])
        team = author.make_teams(case)[row['fixture']]
        check(row['plan'] == list(author.planned_assignment(case.code,team)), 'Godot and Python delegation plans match')
        check(abs(row['rate'] - baseline['clear_rate']) <= .03, 'HP-only completion within 3 percentage points')
print(f'ADVANCED SOURCE + LOCALIZATION: {checks} checks; 0 failures')
