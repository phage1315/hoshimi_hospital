"""Schema + cross-reference checks. Run from any directory."""
import json
import re
from pathlib import Path
from jsonschema import Draft202012Validator
from patient_bundles import load_patient_bundles
ROOT = Path(__file__).resolve().parents[1]
def read(path):
    return json.loads((ROOT / 'data' / path).read_text())
schema = read('schemas/content.schema.json')
manifest = read('manifest.json')
errors = []
collections = {}
def check(condition, message):
    if not condition: errors.append(message)

def png_has_alpha_channel(path):
    """Detect RGBA/gray-alpha PNGs without adding an image-library dependency."""
    try:
        data = path.read_bytes()
    except OSError:
        return False
    return len(data) > 25 and data[:8] == b'\x89PNG\r\n\x1a\n' and data[25] in {4, 6}
check(manifest['schema_version'] == 1, 'Unsupported manifest version')
protagonist = read(manifest['protagonist'])
protagonist_validator = Draft202012Validator({'$ref': '#/$defs/protagonist', '$defs': schema['$defs']})
errors.extend(f'protagonist {e.json_path}: {e.message}' for e in protagonist_validator.iter_errors(protagonist))
check(protagonist.get('name') == '本多繁邦', 'Canonical protagonist name must be 本多繁邦')
kind = dict(staff='staff', patients='patient', cameo_patients='cameo_patient', relationships='relationship', relationship_activity_placeholders='relationship_activity_placeholder', cases='case', case_templates='case_template', surgeries='surgery', patient_interactions='patient_interaction', teams='team', backgrounds='background', time_events='time_event', character_events='character_event', micro_events='micro_event', surgery_team_dialogue_profiles='surgery_team_dialogue_profile', examination_cg_pools='examination_cg_pool', surgery_cg_pools='surgery_cg_pool', ward_preparation_cg_pools='ward_preparation_cg_pool', locations='location', encounters='encounter', preops='preop')
for key, path in manifest['collections'].items():
    rows = read(path)
    collections[key] = rows
    validator = Draft202012Validator({'$ref': '#/$defs/' + kind[key], '$defs': schema['$defs']})
    for index, row in enumerate(rows):
        errors.extend(f'{key}[{index}] {e.json_path}: {e.message}' for e in validator.iter_errors(row))
    if key != 'relationships':
        ids = [r.get('id') for r in rows]
        check(len(ids) == len(set(ids)), f'Duplicate id in {key}')

patient_collections, patient_bundles = load_patient_bundles(ROOT / 'data', manifest['patient_bundles'])
for relative_path, bundle in patient_bundles:
    prefix = relative_path + ': '
    check(bundle.get('schema_version') == 1, prefix + 'unsupported patient bundle schema')
    check(isinstance(bundle.get('patient'), dict), prefix + 'missing patient record')
    check(isinstance(bundle.get('fallback'), dict), prefix + 'missing fallback data')
    check(isinstance(bundle.get('encounter', {}).get('full_undress'), dict), prefix + 'missing full-undress dialogue')
    full_undress = bundle.get('encounter', {}).get('full_undress', {})
    check(set(full_undress.get('responses', {})) == {
        'abandon_full_undress', 'authoritative_full_undress',
        'gentle_full_undress', 'threaten_full_undress'},
        prefix + 'full-undress responses are incomplete')
    check(isinstance(bundle.get('preop', {}).get('stage_prompts'), dict), prefix + 'missing preop prompts')
for key in ['patients', 'encounters', 'preops']:
    rows = patient_collections[key]
    collections[key] = rows
    validator = Draft202012Validator({'$ref': '#/$defs/' + kind[key], '$defs': schema['$defs']})
    for index, row in enumerate(rows):
        errors.extend(f'{key}[{index}] {e.json_path}: {e.message}' for e in validator.iter_errors(row))
    ids = [row.get('id') for row in rows]
    check(len(ids) == len(set(ids)), f'Duplicate id in generated {key}')
for key in ['examination_cg_pools', 'ward_preparation_cg_pools']:
    collections[key].extend(patient_collections[key])
    ids = [row.get('id') for row in collections[key]]
    check(len(ids) == len(set(ids)), f'Duplicate id after merging patient-owned {key}')
    validator = Draft202012Validator({'$ref': '#/$defs/' + kind[key], '$defs': schema['$defs']})
    for index, row in enumerate(patient_collections[key]):
        errors.extend(f'{key} patient bundle [{index}] {e.json_path}: {e.message}' for e in validator.iter_errors(row))
by = {key: {r['id']: r for r in rows} for key, rows in collections.items() if key != 'relationships'}

for relation in collections['relationships']:
    prefix = relation['target_id'] + ': '
    slots = relation['rank_slots']
    check({slot['target_level'] for slot in slots} == set(range(1, 6)),
          prefix + 'relationship slots must cover Lv.1 through Lv.5 exactly once')
    for slot in slots:
        event_id = slot['event_id']
        if not event_id:
            continue
        event = by['character_events'].get(event_id, {})
        check(bool(event), prefix + 'unknown bond/rank event ' + event_id)
        check(event.get('actor_id') == relation['target_id'], prefix + event_id + ': event actor mismatch')
        expected_category = 'bond' if slot['target_level'] == 1 else 'rank_up'
        check(event.get('category') == expected_category, prefix + event_id + ': wrong event category')
        check(event.get('target_level') == slot['target_level'], prefix + event_id + ': target level mismatch')

activity_placeholders = by['relationship_activity_placeholders']
patient_play = activity_placeholders.get('operating_room_patient_play', {})
clinical_practice = activity_placeholders.get('clinical_practice_patient', {})
check(patient_play.get('unlock_level') == 4 and
      patient_play.get('real_procedure') is False and patient_play.get('workflow') == [],
      'Lv4 operating-room patient play placeholder is invalid')
check(clinical_practice.get('unlock_level') == 5 and
      clinical_practice.get('real_procedure') is True and
      clinical_practice.get('workflow') == ['examination', 'preparation', 'surgery'],
      'Lv5 clinical-practice patient placeholder is invalid')
for placeholder in collections['relationship_activity_placeholders']:
    prefix = placeholder['id'] + ': '
    check(placeholder['location_id'] in by['locations'], prefix + 'unknown location')
    check(set(placeholder['eligible_staff_ids']) == set(by['staff']),
          prefix + 'must apply to every medical staff member')
    check(set(placeholder['portrait_ready_staff_ids']) <= set(placeholder['eligible_staff_ids']),
          prefix + 'portrait-ready staff must be eligible')
    check(placeholder['implemented'] is False, prefix + 'placeholder must not be active yet')
    for actor_id in placeholder['portrait_ready_staff_ids']:
        actor = by['staff'][actor_id]
        portrait_key = placeholder['portrait_outfit'] + '/nervous'
        check(placeholder['portrait_outfit'] in actor['visuals']['outfits'],
              prefix + actor_id + ': missing patient outfit')
        check(portrait_key in actor['visuals']['portraits'],
              prefix + actor_id + ': missing patient portrait')
        check((ROOT / actor['visuals']['portraits'].get(portrait_key, '')).is_file(),
              prefix + actor_id + ': patient portrait file missing')

for relation in collections['relationships']:
    slots = {slot['target_level']: slot for slot in relation['rank_slots']}
    check(slots[4]['benefit_id'] == 'unlock_intimacy_events',
          relation['target_id'] + ': Lv4 intimacy-event benefit placeholder missing')
    check(slots[5]['benefit_id'] == 'unlock_clinical_practice_patient',
          relation['target_id'] + ': Lv5 clinical-practice benefit placeholder missing')

# Display names deliberately follow the VNDB source characters while stable IDs
# keep saves, event references, and code links compatible.
source_names = {
    'doc_aoi': '神宮寺 成美',
    'doc_rei': '深山 佳織',
    'doc_emiko': '御堂 江美子',
    'nurse_haru': '七瀬 恋',
    'nurse_rin': '中井 美佳',
    'nurse_yui': '朝倉 美幸',
    'nurse_ange': '利根川 安琪',
    'nurse_hiroko': '杉村 弘子',
    'nurse_moe': '本庄 萌惠',
    'pharmacist_manami': '飯村 真奈美',
}
for person_id, source_name in source_names.items():
    group = 'staff' if person_id in by['staff'] else 'patients'
    check(by[group].get(person_id, {}).get('name') == source_name,
          f'{person_id}: display name must match source character {source_name}')

def text_values(value):
    if isinstance(value, dict):
        for child in value.values():
            yield from text_values(child)
    elif isinstance(value, list):
        for child in value:
            yield from text_values(child)
    elif isinstance(value, str):
        yield value

# Prose may now refer to the named male protagonist in third person. A global
# masculine-pronoun ban cannot distinguish him from a misgendered character, so
# character pronouns are reviewed in authored context instead of guessed here.
for event in collections['micro_events']:
    prefix = event['id'] + ': '
    check(event['actor_id'] in by['staff'], prefix + 'unknown actor')
    check(event['location_id'] in by['locations'], prefix + 'unknown location')
    actor = by['staff'].get(event['actor_id'], {})
    portraits = actor.get('visuals', {}).get('portraits', {})
    check(f"{event['outfit']}/{event['expression']}" in portraits, prefix + 'opening portrait missing')
    for choice in event['choices']:
        check(f"{event['outfit']}/{choice['expression']}" in portraits, prefix + choice['id'] + ': response portrait missing')
    choice_ids = [choice['id'] for choice in event['choices']]
    check(len(choice_ids) == len(set(choice_ids)), prefix + 'duplicate choice')
    check(len(event['choices']) == 3, prefix + 'micro event should have three choices')
    adult_tone = event.get('adult_tone')
    if adult_tone:
        check(not adult_tone['patients_sexualized'], prefix + 'staff micro events must not sexualize patients')
    check(isinstance(event.get('opening_lines'), list) and len(event.get('opening_lines', [])) >= 3,
          prefix + 'micro event should have at least three opening lines')
    check(isinstance(event.get('closing_lines'), list) and len(event.get('closing_lines', [])) >= 2,
          prefix + 'micro event should have at least two closing lines')
    for line in event.get('opening_lines', []) + event.get('closing_lines', []):
        check(line.get('speaker') in {'actor', 'player', 'narrator'}, prefix + 'unknown dialogue speaker')
        check(bool(line.get('text')), prefix + 'empty dialogue line')
        if line.get('speaker') == 'actor' and line.get('expression'):
            check(f"{event['outfit']}/{line['expression']}" in portraits, prefix + 'dialogue portrait missing')
for event in collections['character_events']:
    requirements = event.get('conditions', {}).get('special_requirements')
    check(isinstance(requirements, list), event['id'] + ': special requirement placeholder missing')
    for requirement in requirements or []:
        check(requirement.get('type') == 'player_attribute', event['id'] + ': unknown special requirement type')
        check(requirement.get('attribute') in {'skill', 'ethics', 'charisma', 'intimidation', 'reputation'},
              event['id'] + ': unknown player attribute requirement')
    follow_up = event.get('auto_follow_up')
    if follow_up:
        check(follow_up['event_id'] in by['character_events'], event['id'] + ': unknown automatic follow-up event')
for background in collections['backgrounds']:
    check((ROOT / background['path']).is_file(), 'Background asset missing: ' + background['path'])
known_test_ids = {test['id'] for template in collections['case_templates'] for test in template['tests']}
mapped_test_ids = set()
for pool in collections['examination_cg_pools']:
    prefix = pool['id'] + ': '
    check(not (set(pool['test_ids']) & mapped_test_ids), prefix + 'test is mapped to more than one CG pool')
    mapped_test_ids.update(pool['test_ids'])
    check(set(pool['test_ids']) <= known_test_ids, prefix + 'unknown test id')
    check(set(pool['surgery_ids']) <= set(by['surgeries']), prefix + 'unknown surgery id')
    for path in pool['paths']:
        check((ROOT / path).is_file(), prefix + 'CG asset missing: ' + path)
for pool in collections['surgery_cg_pools']:
    prefix = pool['id'] + ': '
    check(set(pool['surgery_ids']) <= set(by['surgeries']), prefix + 'unknown surgery id')
    check(set(pool['patient_ids']) <= set(by['patients']), prefix + 'unknown patient id')
    for path in pool['paths']:
        check((ROOT / path).is_file(), prefix + 'surgery CG asset missing: ' + path)
generic_progress_counts = {}
for pool in collections['surgery_cg_pools']:
    if pool['stage'] != 'progress' or pool['patient_ids']:
        continue
    for surgery_id in pool['surgery_ids']:
        generic_progress_counts[surgery_id] = generic_progress_counts.get(surgery_id, 0) + 1
for surgery_id in by['surgeries']:
    check(generic_progress_counts.get(surgery_id, 0) == 1,
          f'{surgery_id}: expected exactly one generic progress surgery CG pool')
known_preparation_cg_actions = {
    'ward_enema', 'ward_enema_unnecessary',
    'ward_skin_prep', 'ward_skin_prep_unnecessary',
    'ward_surgical_cap',
    'urinary_catheterization', 'skin_disinfection', 'request_scalpel',
}
for pool in collections['ward_preparation_cg_pools']:
    prefix = pool['id'] + ': '
    check(set(pool['action_ids']) <= known_preparation_cg_actions, prefix + 'unknown preparation CG action id')
    check(set(pool['patient_ids']) <= set(by['patients']), prefix + 'unknown patient id')
    for path in pool['paths']:
        check((ROOT / path).is_file(), prefix + 'preparation CG asset missing: ' + path)
required_patient_reactions = {
    'hospitalization_question', 'hospitalization_response',
    'procedure_mismatch', 'explain_plan', 'brief_plan', 'last_reassure',
    'choose_general', 'choose_epidural', 'choose_local', 'choose_none',
    'induction_reassure', 'insist_without_anesthesia',
    'assistant_stabilize_none', 'assistant_stabilize_local', 'assistant_stabilize_epidural',
    'incise_epidural',
    'incise_local', 'incise_none', 'contact_pause', 'contact_command',
    'contact_continue', 'ongoing_narrate', 'ongoing_eye_contact',
    'ongoing_silent', 'closure_reassure', 'closure_coach', 'closure_silent'
}
required_preparation_reaction_variants = {
	'ward_enema', 'ward_enema_unnecessary',
	'ward_skin_prep', 'ward_skin_prep_unnecessary',
	'ward_surgical_cap',
    'operative_positioning_awake', 'operative_positioning_none',
    'urinary_catheterization_awake', 'urinary_catheterization_none',
    'skin_disinfection_awake', 'skin_disinfection_none',
    'incision_marking_awake', 'incision_marking_none',
}
personality_pairs = set()
for patient in collections['patients']:
    prefix = patient['id'] + ': '
    check(patient['case_id'] in by['cases'], prefix + 'unknown patient case')
    portraits = patient['visuals']['portraits']
    for expression in ('tense', 'pain', 'near_collapse', 'anesthetized'):
        portrait_key = 'intraoperative/' + expression
        check(portrait_key in portraits, prefix + 'missing intraoperative portrait ' + expression)
        if portrait_key in portraits:
            check((ROOT / portraits[portrait_key]).is_file(), prefix + 'intraoperative portrait asset missing: ' + portraits[portrait_key])
    profile = patient['personality']
    personality_pair = (profile['primary'], profile['secondary'])
    check(personality_pair not in personality_pairs, prefix + 'duplicate primary/secondary personality pair')
    personality_pairs.add(personality_pair)
    check(set(patient['reaction_lines']) == required_patient_reactions, prefix + 'incomplete reaction-line coverage')
    check(len(set(patient['reaction_lines'].values())) == len(patient['reaction_lines']), prefix + 'duplicate reaction lines within patient')
    variants = patient['reaction_variants']
    check(set(variants) == required_preparation_reaction_variants, prefix + 'incomplete preparation reaction variants')
    check(all(2 <= len(lines) <= 3 and len(lines) == len(set(lines)) for lines in variants.values()), prefix + 'preparation variants must contain 2-3 unique lines')
    all_variant_lines = [line for lines in variants.values() for line in lines]
    check(len(all_variant_lines) == len(set(all_variant_lines)), prefix + 'duplicate preparation reaction variant within patient')
for case in collections['cases']:
    check(case['surgery_id'] is None or case['surgery_id'] in by['surgeries'], 'Unknown case surgery')
template_surgeries = set()
for template in collections['case_templates']:
    prefix = template['id'] + ': '
    check(template['surgery_id'] in by['surgeries'], prefix + 'unknown surgery')
    check(template['surgery_id'] not in template_surgeries, prefix + 'duplicate surgery template')
    template_surgeries.add(template['surgery_id'])
    check(1 <= len(template['symptoms']) <= 5, prefix + 'symptom count must be 1-5')
    check(len({test['id'] for test in template['tests']}) == len(template['tests']), prefix + 'duplicate diagnostic test')
    variant_ids = [variant['id'] for variant in template.get('rare_variants', [])]
    check(len(variant_ids) == len(set(variant_ids)), prefix + 'duplicate rare variant')
    check(sum(float(variant['probability']) for variant in template.get('rare_variants', [])) <= 1.0, prefix + 'rare variant probability exceeds 1')
    for variant in template.get('rare_variants', []):
        option_ids = [option['id'] for option in variant.get('decision_options', [])]
        check(len(option_ids) >= 2, prefix + variant['id'] + ': at least two decision options required')
        check(len(option_ids) == len(set(option_ids)), prefix + variant['id'] + ': duplicate decision option')
        check(any(option.get('requires_consent') for option in variant.get('decision_options', [])), prefix + variant['id'] + ': continuation must require consent')
        coerced_options = [option for option in variant.get('decision_options', []) if option.get('consent_state') == 'coerced']
        for option in coerced_options:
            check(option.get('effects', {}).get('ethics', 0) < 0, prefix + option['id'] + ': coerced option must reduce ethics')
            check(option.get('effects', {}).get('intimidation', 0) > 0, prefix + option['id'] + ': coerced option must raise intimidation')
            check(len(option.get('staff_intervention_hooks', [])) > 0, prefix + option['id'] + ': coerced option needs staff intervention hooks')
check(template_surgeries == set(by['surgeries']), 'Surgery template coverage is incomplete')
for person in collections['staff']:
    check(person['visuals']['default_outfit'] in person['visuals']['outfits'], 'Unknown default outfit')
    for key, path in person['visuals']['portraits'].items():
        check((ROOT / path).is_file(), 'Portrait asset missing: ' + path)
    if person['surgery_proficiency'] in {'novice', 'limited'} and person['team_category'] == 'doctor':
        authored = person.get('team_dialogue', {})
        for dialogue_key in {'assignment', 'intraoperative', 'intraoperative_correction'}:
            check(bool(authored.get(dialogue_key)), person['id'] + ': inexperienced doctor requires personal ' + dialogue_key + ' dialogue')

ange = by['staff'].get('nurse_ange', {})
check(bool(ange.get('characterization')), 'nurse_ange: structured characterization is required')
check(ange.get('surgery_proficiency') == 'expert', 'nurse_ange: must remain an expert surgical nurse')
ange_skills = ange.get('skills', {})
check(ange_skills.get('instrument_handling', 0) > ange_skills.get('calmness', 100),
      'nurse_ange: technical skill must exceed stress composure to preserve her defining contrast')
ange_intro = by['character_events'].get('intro_nurse_ange', {})
check(ange_intro.get('category') == 'introduction' and ange_intro.get('location_id') == 'station',
      'nurse_ange: acquaintance must be a nurse-station introduction')
check(ange_intro.get('conditions', {}).get('min_day') == 2 and ange_intro.get('auto_start') is True,
      'nurse_ange: acquaintance must auto-start at the nurse station from day two')
check('or' in ange.get('presence', {}).get('fixed_locations', []),
      'nurse_ange: must have a permanent operating-room post after introduction')
check(any(event.get('id') == 'or_chat_nurse_ange' and event.get('location_id') == 'or'
          for event in collections['time_events']),
      'nurse_ange: operating-room small talk is missing')

hiroko = by['staff'].get('nurse_hiroko', {})
check(hiroko.get('surgery_proficiency') == 'trained',
      'nurse_hiroko: must be a trained all-round ward and surgical nurse')
check('best_friend_pharmacist_manami' in hiroko.get('flags', []),
      'nurse_hiroko: friendship with pharmacist_manami must remain explicit')
check('ward' in hiroko.get('presence', {}).get('fixed_locations', []) and
      {'clinic', 'ward'} <= set(hiroko.get('presence', {}).get('random_locations', [])),
      'nurse_hiroko: must rotate between her ward post and outpatient duty after introduction')
hiroko_escape = by['character_events'].get('hiroko_patient_escape', {})
check(hiroko_escape.get('gallery', {}).get('show_on_complete') is False,
      'nurse_hiroko: escape CG must not replay after the conversation ends')
check(hiroko_escape.get('category') == 'contextual' and hiroko_escape.get('location_id') == 'or',
      'nurse_hiroko: patient escape must be an operating-room contextual event')
check(hiroko_escape.get('allow_unmet_actor') is True and hiroko_escape.get('auto_start') is True,
      'nurse_hiroko: patient escape must auto-start before formal acquaintance')
hiroko_intro = by['character_events'].get('intro_nurse_hiroko', {})
check(hiroko_intro.get('category') == 'introduction' and hiroko_intro.get('location_id') == 'station',
      'nurse_hiroko: formal acquaintance must occur at the nurse station')
check('hiroko_patient_escape' in hiroko_intro.get('conditions', {}).get('required_events', []),
      'nurse_hiroko: formal acquaintance must follow the operating-room incident')
check(hiroko_intro.get('conditions', {}).get('days_after_required_events') == 1,
      'nurse_hiroko: nurse-station introduction must wait until the day after the incident')
check(any(event.get('id') == 'ward_chat_nurse_hiroko' for event in collections['time_events']) and
      any(event.get('id') == 'clinic_chat_nurse_hiroko' for event in collections['time_events']),
      'nurse_hiroko: ward and outpatient small talk are required')
for portrait_key in ['uniform/neutral', 'uniform/smile', 'uniform/worried',
                     'scrubs/neutral', 'scrubs/focused', 'scrubs/warm', 'scrubs/worried',
                     'sterile/neutral', 'sterile/focused', 'sterile/warm', 'sterile/worried']:
    check(portrait_key in hiroko.get('visuals', {}).get('portraits', {}),
          'nurse_hiroko: missing portrait ' + portrait_key)

moe = by['staff'].get('nurse_moe', {})
check(moe.get('surgery_proficiency') == 'novice' and moe.get('specialty') == '门诊护理／手术室支援',
      'nurse_moe: must remain a new outpatient nurse with limited operating-room experience')
check('severe_myopia' in moe.get('flags', []),
      'nurse_moe: severe myopia must remain explicit')
moe_changing = by['character_events'].get('moe_wrong_changing_room', {})
check(moe_changing.get('category') == 'contextual' and moe_changing.get('location_id') == 'or',
      'nurse_moe: first encounter must occur in the operating-room changing room')
check(moe_changing.get('allow_unmet_actor') is True and moe_changing.get('auto_start') is True,
      'nurse_moe: changing-room encounter must auto-start before formal acquaintance')
check(moe_changing.get('preop_stage_id') == 'changing',
      'nurse_moe: changing-room encounter must trigger on entry to the preoperative changing stage')
check(moe_changing.get('conditions', {}).get('min_day') == 2,
      'nurse_moe: changing-room encounter must remain unavailable on day one')
moe_nude_nodes = [node for node in moe_changing.get('nodes', [])
                  if node.get('portrait_path', '').endswith('/changing_shy.png')]
moe_scrubs_nodes = [node for node in moe_changing.get('nodes', [])
                    if node.get('portrait_path', '').endswith('/scrubs_neutral.png')]
check(bool(moe_nude_nodes) and all(float(node.get('portrait_scale', 1)) >= 1.3 and
                                   float(node.get('portrait_right', 1280)) <= 1220 and
                                   float(node.get('portrait_y', 999)) <= 60 for node in moe_nude_nodes),
      'nurse_moe: changing portrait must use its normalized enlarged event layout')
check(bool(moe_scrubs_nodes) and all(float(node.get('portrait_right', 1280)) <= 1150 and
                                     float(node.get('portrait_y', 999)) <= 145 for node in moe_scrubs_nodes),
      'nurse_moe: scrubs portrait must use its normalized left-shifted event layout')
moe_intro = by['character_events'].get('intro_nurse_moe', {})
check(moe_intro.get('category') == 'introduction' and moe_intro.get('location_id') == 'station',
      'nurse_moe: formal acquaintance must occur at the nurse station')
check('moe_wrong_changing_room' in moe_intro.get('conditions', {}).get('required_events', []),
      'nurse_moe: formal acquaintance must follow the changing-room encounter')
check(moe_intro.get('conditions', {}).get('days_after_required_events') == 1,
      'nurse_moe: nurse-station introduction must wait until the day after the changing-room encounter')
check(moe.get('visuals', {}).get('portraits', {}).get('operating_patient/nervous') ==
      moe.get('visuals', {}).get('portraits', {}).get('changing/shy'),
      'nurse_moe: changing portrait must also be registered for future Lv4 operating-room patient play')
check('sterile' in moe.get('visuals', {}).get('outfits', []),
      'nurse_moe: ordinary operating-room appearances must support sterile clothing')
check('scrubs/neutral' not in moe.get('visuals', {}).get('portraits', {}),
      'nurse_moe: short-sleeve scrubs must remain exclusive to the changing-room event')
check(any(event.get('id') == 'clinic_chat_nurse_moe' for event in collections['time_events']) and
      any(event.get('id') == 'or_chat_nurse_moe' for event in collections['time_events']),
      'nurse_moe: outpatient and occasional operating-room small talk are required')
for portrait_key in ['uniform/neutral', 'uniform/smile', 'uniform/surprised', 'uniform/worried',
                     'uniform/shy', 'uniform/startled', 'uniform/laugh', 'uniform/embarrassed',
                     'uniform/warm', 'uniform/cheerful', 'changing/shy', 'sterile/neutral',
                     'sterile/focused', 'sterile/worried',
                     'operating_patient/nervous']:
    check(portrait_key in moe.get('visuals', {}).get('portraits', {}),
          'nurse_moe: missing portrait ' + portrait_key)

emiko = by['staff'].get('doc_emiko', {})
check(emiko.get('rank') == '外科部医长／外科主任候选' and emiko.get('surgery_proficiency') == 'expert',
      'doc_emiko: must remain an expert surgical department chief and director candidate')
check({'surgery_department_chief', 'surgery_director_candidate'} <= set(emiko.get('flags', [])),
      'doc_emiko: leadership status flags are required')
check(emiko.get('skills', {}).get('surgery', 0) >= 90 and emiko.get('skills', {}).get('calmness', 0) >= 90,
      'doc_emiko: elite surgical ability and composure must remain explicit')
for portrait_key in ['white_coat/neutral', 'white_coat/smile', 'white_coat/serious',
                     'white_coat/surprised', 'white_coat/worried', 'white_coat/warm',
                     'scrubs/neutral', 'scrubs/focused', 'scrubs/worried', 'scrubs/warm',
                     'sterile/neutral', 'sterile/focused', 'sterile/worried', 'sterile/warm',
                     'operating_patient/nervous']:
    check(portrait_key in emiko.get('visuals', {}).get('portraits', {}),
          'doc_emiko: missing portrait ' + portrait_key)
emiko_relation = by['relationships'].get('doc_emiko', {}) if 'relationships' in by else next(
    (relation for relation in collections['relationships'] if relation['target_id'] == 'doc_emiko'), {})
check(not emiko_relation.get('met', True), 'doc_emiko: must remain unknown until her skill-gated introduction')
emiko_slots = {slot['target_level']: slot for slot in emiko_relation.get('rank_slots', [])}
check(emiko_slots.get(1, {}).get('event_id') == 'emiko_lv1_first_operation' and
      emiko_slots.get(2, {}).get('event_id') == 'emiko_lv2_follow_my_lead',
      'doc_emiko: Lv1 and Lv2 event slots are not linked')
check('emiko_office' in by['locations'] and 'emiko_office' in emiko.get('presence', {}).get('fixed_locations', []),
      'doc_emiko: personal office location or fixed presence is missing')
emiko_intro = by['character_events'].get('emiko_intro_rumored_hands', {})
emiko_lv1 = by['character_events'].get('emiko_lv1_first_operation', {})
emiko_lv2 = by['character_events'].get('emiko_lv2_follow_my_lead', {})
check(emiko_intro.get('conditions', {}).get('special_requirements') ==
      [{'type': 'player_attribute', 'attribute': 'skill', 'minimum': 56}],
      'doc_emiko: introduction must require player skill 56')
check(emiko_intro.get('auto_follow_up') ==
      {'event_id': 'emiko_lv1_first_operation', 'day_offset': 1, 'absolute_clock': 780},
      'doc_emiko: introduction must schedule Lv1 for the next day at 13:00')
check(emiko_lv1.get('conditions', {}).get('days_after_required_events') == 1,
      'doc_emiko: Lv1 must occur on the day after the introduction')
check(emiko_lv2.get('conditions', {}).get('days_after_required_events') == 7 and
      emiko_lv2.get('conditions', {}).get('special_requirements') ==
      [{'type': 'player_attribute', 'attribute': 'skill', 'minimum': 70}],
      'doc_emiko: Lv2 must require skill 70 and a seven-day gap')

inexperienced_nurse_response_ids = {'assignment_scrub_nurse', 'assignment_circulating_nurse'}
for prep in collections['preops']:
    inexperienced_nurse_response_ids.update(
        action['id'] for stage in prep['stages'] for action in stage['actions']
        if action.get('response_role') in {'scrub_nurse', 'circulating_nurse'})
for surgery in collections['surgeries']:
    inexperienced_nurse_response_ids.update(
        option['id'] for stage in surgery['stages'] for option in stage['options']
        if option.get('response_role') in {'scrub_nurse', 'circulating_nurse'})
for profile in collections['surgery_team_dialogue_profiles']:
    check(set(profile['responses']) == inexperienced_nurse_response_ids,
          profile['id'] + ': incomplete inexperienced-nurse surgery node coverage')
for person in collections['staff']:
    if person['profession'] != 'nurse' or person['surgery_proficiency'] not in {'novice', 'limited'}:
        continue
    matching_profiles = [profile for profile in collections['surgery_team_dialogue_profiles']
                         if profile['profession'] == 'nurse' and person['surgery_proficiency'] in profile['proficiencies']]
    check(len(matching_profiles) == 1, person['id'] + ': expected exactly one inexperienced-nurse dialogue profile')
for location in collections['locations']:
    check(all(s in by['staff'] for s in location['staff_ids']), 'Unknown location staff')
    check(location['background_id'] in by['backgrounds'], 'Unknown location background')
for event in collections['time_events']:
    check(event['location_id'] in by['locations'], 'Unknown time-event location')
    check(event['actor_id'] is None or event['actor_id'] in by['staff'], 'Unknown time-event actor')
    check(len(event['responses']) == len(set(event['responses'])), 'Duplicate time-event response')
    if event['actor_id'] is not None and event['actor_id'] in by['staff']:
        actor = by['staff'][event['actor_id']]
        portraits = actor['visuals']['portraits']
        if event['location_id'] == 'or':
            chat_outfit = 'scrubs' if 'scrubs/neutral' in portraits else 'sterile'
        else:
            chat_outfit = actor['visuals']['default_outfit']
        check(f'{chat_outfit}/neutral' in portraits,
              event['id'] + ': missing location-appropriate small-talk portrait ' + chat_outfit + '/neutral')
for event in collections['character_events']:
    prefix = event['id'] + ': '
    check(event['actor_id'] in by['staff'], prefix + 'unknown actor')
    check(event['location_id'] in by['locations'], prefix + 'unknown location')
    check(event['background_id'] in by['backgrounds'], prefix + 'unknown background')
    check(event['outfit'] in by['staff'].get(event['actor_id'], {}).get('visuals', {}).get('outfits', []), prefix + 'unknown outfit')
    preop_stage_id = event.get('preop_stage_id', '')
    if preop_stage_id:
        check(any(any(stage['id'] == preop_stage_id for stage in prep['stages']) for prep in collections['preops']),
              prefix + 'unknown preoperative stage trigger')
    check(event['time_start'] < event['time_end'], prefix + 'invalid time window')
    if event['gallery']['path']:
        check((ROOT / event['gallery']['path']).is_file(), prefix + 'gallery CG missing')
    portraits = by['staff'].get(event['actor_id'], {}).get('visuals', {}).get('portraits', {})
    for node in event['nodes']:
        cg_path = node.get('cg_path', '')
        portrait_path = node.get('portrait_path', '')
        hide_portrait = node.get('hide_portrait', False)
        check(not (hide_portrait and (cg_path or portrait_path)),
              prefix + node['id'] + ': hidden-portrait node cannot also provide character art')
        check(not (cg_path and portrait_path), prefix + node['id'] + ': node cannot be both CG and portrait')
        if hide_portrait:
            pass
        elif cg_path:
            check((ROOT / cg_path).is_file(), prefix + node['id'] + ': node CG missing')
            check(node.get('cg_fit') in {'cover', 'contain'}, prefix + node['id'] + ': node CG fit missing')
        elif portrait_path:
            check((ROOT / portrait_path).is_file(), prefix + node['id'] + ': node portrait missing')
            check(png_has_alpha_channel(ROOT / portrait_path),
                  prefix + node['id'] + ': node portrait must be a transparent PNG, not an opaque splash image')
        else:
            check(event['outfit'] + '/' + node['expression'] in portraits, prefix + 'missing expression portrait ' + node['expression'])
    nodes = {node['id']: node for node in event['nodes']}
    check(len(nodes) == len(event['nodes']) and event['start'] in nodes, prefix + 'invalid nodes')
    choice_ids = set()
    reachable, pending = set(), [event['start']]
    while pending:
        node_id = pending.pop()
        if node_id in reachable or node_id not in nodes: continue
        reachable.add(node_id)
        for choice in nodes[node_id]['choices']:
            check(choice['id'] not in choice_ids, prefix + 'duplicate choice id')
            choice_ids.add(choice['id'])
            check(choice['next'] == '@end' or choice['next'] in nodes, prefix + 'unknown choice target')
            if choice['next'] != '@end': pending.append(choice['next'])
    check(reachable == set(nodes), prefix + 'unreachable node')
    check(any(choice['next'] == '@end' for node in event['nodes'] for choice in node['choices']), prefix + 'missing ending')
event_ids = set(by['character_events'])
for event in collections['character_events']:
    check(set(event['conditions']['required_events']) <= event_ids, event['id'] + ': unknown prerequisite event')
    check(not event.get('allow_unmet_actor', False) or event['category'] == 'contextual',
          event['id'] + ': only contextual scenes may run before acquaintance')

chihaya = by['cameo_patients'].get('patient_chihaya', {})
check(chihaya.get('canonical_name') == '仓本千早' and chihaya.get('public_name') == '女患者',
      'patient_chihaya: hidden and canonical identities are required')
check(chihaya.get('identity_revealed_by_default') is False,
      'patient_chihaya: identity must stay hidden until a future reveal event')
check(chihaya.get('debut_event_id') == 'hiroko_patient_escape',
      'patient_chihaya: debut event mismatch')
for path in chihaya.get('visuals', {}).values():
    check((ROOT / path).is_file(), 'patient_chihaya: missing visual ' + path)
for key in {'shy', 'restrained'}:
    path = ROOT / chihaya.get('visuals', {}).get(key, '')
    check(png_has_alpha_channel(path), 'patient_chihaya: ' + key + ' must be a transparent portrait')
check('仓本千早' not in '\n'.join(text_values(by['character_events'].get('hiroko_patient_escape', {}))),
      'patient_chihaya: debut event must not reveal her name')
relations = set()
for relation in collections['relationships']:
    pair = (relation['source_id'], relation['target_id'])
    check(pair not in relations, 'Duplicate relationship')
    relations.add(pair)
    check(all(p == 'player' or p in by['staff'] for p in pair), 'Unknown relationship participant')
for team in collections['teams']:
    check(team['surgery_id'] in by['surgeries'], 'Unknown team surgery')
    members = team['members']
    check(len(set(members.values())) == len(members), 'Team member assigned twice')
    for role, person in members.items():
        check(person in by['staff'] and role in by['staff'][person]['surgical_roles'], 'Invalid team role')
    surgery = by['surgeries'].get(team['surgery_id'], {})
    check(set(surgery.get('required_roles', [])) <= set(members), 'Missing required role')
for surgery in collections['surgeries']:
    prefix = surgery['id'] + ': '
    ids = [s['id'] for s in surgery['stages']]
    check(len(ids) == len(set(ids)), prefix + 'duplicate surgery-flow stage id')
    check(bool(ids), prefix + 'surgery requires narrative stages')
    option_ids = set()
    for stage in surgery['stages']:
        options = stage['options']
        check(len(options) == (1 if stage['kind'] == 'confirm' else 3), prefix + stage['id'] + ': wrong option count')
        for option in options:
            check(option['id'] not in option_ids, prefix + 'duplicate surgery-flow option id')
            option_ids.add(option['id'])
        if stage['kind'] == 'decision':
            check(sum(bool(option['correct']) for option in options) == 1, prefix + stage['id'] + ': decision requires exactly one correct option')
            check(all(option['correct'] or bool(option['correction']) for option in options), prefix + stage['id'] + ': wrong option requires assistant correction')
        else:
            check(all(option['correct'] for option in options), prefix + stage['id'] + ': non-decision options must be consequence-free')
interaction_themes = {
    'operative_contact', 'progress_check', 'strain_interaction',
    'dignity_interaction', 'ongoing_interaction', 'closure_interaction',
}
generic_fallback_themes = set()
for interaction in collections['patient_interactions']:
    prefix = interaction['id'] + ': '
    check(not (interaction['procedure_groups'] and interaction['surgery_ids']),
          prefix + 'procedure_groups and surgery_ids are mutually exclusive')
    check(set(interaction['surgery_ids']) <= set(by['surgeries']), prefix + 'unknown surgery id')
    action_ids = [action['id'] for action in interaction['actions']]
    check(len(action_ids) == len(set(action_ids)), prefix + 'duplicate patient interaction action id')
    check(all(not action['delegate_role'] for action in interaction['actions']),
          prefix + 'delegated actions belong to milestone 1B')
    if not interaction['procedure_groups'] and not interaction['surgery_ids'] and not interaction['states'] and not interaction['cues']:
        generic_fallback_themes.add(interaction['theme'])
check(generic_fallback_themes == interaction_themes,
      'Patient interaction generic fallbacks must cover every awake theme')
story = read(manifest['dialogue'])
validator = Draft202012Validator({'$ref':'#/$defs/dialogue', '$defs':schema['$defs']})
errors.extend(e.message for e in validator.iter_errors(story))
nodes = {n['id']:n for n in story['nodes']}
check(len(nodes) == len(story['nodes']), 'Duplicate dialogue node')
check(story['start'] in nodes, 'Unknown dialogue start')
for node in nodes.values():
    check(node['speaker'] == 'narrator' or node['speaker'] in by['staff'], 'Unknown speaker')
    check(node['background_id'] in by['backgrounds'], 'Unknown dialogue background')
    if node['speaker'] in by['staff']:
        actor = by['staff'][node['speaker']]
        outfit = actor['visuals']['default_outfit']
        expression = node.get('expression', 'neutral')
        check(f'{outfit}/{expression}' in actor['visuals']['portraits'],
              f"{node['id']}: missing prologue portrait {outfit}/{expression}")
    check(('next' in node) != ('choices' in node), 'Node requires either next or choices')
    targets = [c['target'] for c in node['choices']] if 'choices' in node else [node.get('next')]
    for target in targets:
        if target.startswith('@location:'):
            check(target.removeprefix('@location:') in by['locations'], 'Unknown dialogue location target')
        else:
            check(target == '@map' or target in nodes, 'Unknown dialogue target')
reachable = set()
def visit(key):
    if key.startswith('@') or key in reachable or key not in nodes: return
    reachable.add(key)
    node = nodes[key]
    for target in ([c['target'] for c in node['choices']] if 'choices' in node else [node.get('next')]): visit(target)
visit(story['start'])
check(reachable == set(nodes), 'Unreachable dialogue node')

for encounter in collections['encounters']:
    prefix = encounter['id'] + ': '
    check(encounter['case_id'] in by['cases'], prefix + 'unknown case')
    check(encounter['patient_id'] in by['patients'], prefix + 'unknown patient')
    patient = by['patients'].get(encounter['patient_id'], {})
    check(patient.get('case_id') == encounter['case_id'], prefix + 'case/patient mismatch')
    stages = {s['id']: s for s in encounter['stages']}
    check(len(stages) == len(encounter['stages']), prefix + 'duplicate stage')
    check(encounter['start'] in stages and encounter['completion'] in stages, prefix + 'invalid endpoints')
    action_ids, note_ids = set(), set()
    for stage in stages.values():
        check(stage['speaker'] in by['staff'] or stage['speaker'] == encounter['patient_id'], prefix + 'unknown speaker')
        check(stage['background_id'] in by['backgrounds'], prefix + 'unknown background')
        check(len(stage['actions']) <= 4, prefix + 'UI supports at most four actions per stage')
        for action in stage['actions']:
            check(action['id'] not in action_ids, prefix + 'duplicate action')
            action_ids.add(action['id'])
            check(action['speaker'] in by['staff'] or action['speaker'] == encounter['patient_id'], prefix + 'unknown response speaker')
            check(action['next'] is None or action['next'] in stages, prefix + 'unknown next stage')
            if action.get('consent_state') == 'coerced':
                check(action.get('player_effects', {}).get('ethics', 0) < 0, prefix + action['id'] + ': coerced clinic action must reduce ethics')
                check(action.get('player_effects', {}).get('intimidation', 0) > 0, prefix + action['id'] + ': coerced clinic action must raise intimidation')
            for note in action['notes']:
                check(note['id'] not in note_ids, prefix + 'duplicate note')
                note_ids.add(note['id'])
    for stage in stages.values():
        for action in stage['actions']:
            check(set(action['requires']) <= note_ids, prefix + 'unknown prerequisite')
    for stage in stages.values():
        grouped = set()
        bundle_ids = set()
        actions = {a['id']: a for a in stage['actions']}
        for bundle in stage.get('bundles', []):
            check(bundle['id'] not in action_ids | bundle_ids, prefix + 'duplicate bundle id')
            bundle_ids.add(bundle['id'])
            check(bundle['speaker'] in by['staff'] or bundle['speaker'] == encounter['patient_id'], prefix + 'unknown bundle speaker')
            for key in bundle['actions']:
                check(key in actions and key not in grouped, prefix + 'invalid grouped action')
                grouped.add(key)
                if key in actions:
                    check(actions[key]['next'] is None and not actions[key]['requires'], prefix + 'bundle members must be independent, non-transition actions')
        check(len(stage['actions']) - len(grouped) + len(bundle_ids) <= 4, prefix + 'too many visible choices')
    # Explore all reachable combinations, including optional/incorrect choices.
    # This catches authored gates that can never unlock or trap the player.
    start = (encounter['start'], frozenset(), frozenset())
    pending, seen, reached = [start], set(), set()
    while pending:
        state = pending.pop()
        if state in seen: continue
        seen.add(state)
        stage_id, done, facts = state
        reached.add(stage_id)
        if stage_id not in stages: continue
        if stage_id == encounter['completion']:
            check(not stages[stage_id]['actions'], prefix + 'completion stage must be terminal')
            continue
        available = [a for a in stages[stage_id]['actions'] if a['id'] not in done and set(a['requires']) <= facts]
        check(bool(available), prefix + 'deadlocked stage ' + stage_id)
        for a in available:
            pending.append((a['next'] or stage_id, done | {a['id']}, facts | {n['id'] for n in a['notes']}))
    check(reached == set(stages), prefix + 'unreachable stage')


for prep in collections['preops']:
    prefix = prep['id'] + ': '
    check(prep['encounter_id'] in by['encounters'], prefix + 'unknown admission encounter')
    check(prep['surgery_id'] in by['surgeries'], prefix + 'unknown surgery')
    check(prep['patient_id'] == by['encounters'].get(prep['encounter_id'], {}).get('patient_id'), prefix + 'patient mismatch')
    stages = {st['id']: st for st in prep['stages']}
    check(len(stages) == len(prep['stages']), prefix + 'duplicate stage')
    check(prep['start'] in stages and prep['completion'] in stages, prefix + 'missing endpoints')
    roles = prep['roles'] + [prep['ward_role']]
    check(len({role['id'] for role in roles}) == len(roles), prefix + 'duplicate role')
    check(len(prep['roles']) == 3 and len(prep['preparations']) <= 3, prefix + 'prototype layout limit')
    check(len({p['id'] for p in prep['preparations']}) == len(prep['preparations']), prefix + 'duplicate preparation')
    # Verify a full unique assignment exists; not just one candidate per role.
    def assignable(index, used):
        if index == len(roles): return True
        role = roles[index]
        return any(person['id'] not in used and person['profession'] == role['profession']
            and (not role['qualification'] or role['qualification'] in person['surgical_roles'])
            and assignable(index + 1, used | {person['id']}) for person in collections['staff'])
    check(assignable(0, set()), prefix + 'cannot staff all roles uniquely')
    role_ids = {role['id'] for role in roles}
    action_ids, all_flags = set(), set()
    for stage in stages.values():
        check(stage['background_id'] in by['backgrounds'], prefix + 'unknown background')
        check(stage.get('next') is None or stage['next'] in stages, prefix + 'invalid stage transition')
        limit = 4 if stage['kind'] == 'interaction' else 3
        check(len(stage['actions']) <= limit, prefix + 'too many stage actions')
        for action in stage['actions']:
            check(action['id'] not in action_ids, prefix + 'duplicate action id')
            action_ids.add(action['id'])
            all_flags.update(action['flags'])
            check(action.get('response_role', '') == '' or action['response_role'] in role_ids, prefix + 'unknown response role')
            check(set(action.get('response_by_staff', {})) <= set(by['staff']), prefix + 'unknown character response')
            check(action['next'] is None or action['next'] in stages, prefix + 'invalid transition')
            check(not action['execute_preparation'] or stage['kind'] == 'preparation', prefix + 'execution outside preparation stage')
            effects = action.get('effects', {})
            check(set(effects) <= {'fear', 'pain', 'dignity', 'cooperation'}, prefix + 'unknown interaction metric')
            check(all(isinstance(value, int) for value in effects.values()), prefix + 'invalid interaction effect')
            check(not action.get('anesthesia') or stage['kind'] == 'interaction', prefix + 'anesthesia outside interaction')
    for stage in stages.values():
        for action in stage['actions']:
            check(set(action['requires']) <= all_flags, prefix + 'unknown required flag')
    pending, seen, reachable = [(prep['start'], frozenset(), frozenset())], set(), set()
    while pending:
        state = pending.pop()
        if state in seen: continue
        seen.add(state)
        stage_id, done, flags = state
        if stage_id not in stages: continue
        reachable.add(stage_id)
        if stage_id == prep['completion']:
            check(not stages[stage_id]['actions'], prefix + 'nonterminal completion')
            continue
        if stages[stage_id]['kind'] == 'surgery_select':
            check(bool(stages[stage_id].get('next')), prefix + 'surgery selection requires next stage')
            pending.append((stages[stage_id].get('next'), done, flags | {'surgery_success'}))
            if 'procedure_mismatch' in stages:
                pending.append(('procedure_mismatch', done, flags | {'wrong_procedure_selected'}))
            continue
        if stages[stage_id]['kind'] == 'surgery_flow':
            check(bool(stages[stage_id].get('next')), prefix + 'surgery flow requires next stage')
            pending.append((stages[stage_id].get('next'), done, flags | {'procedure_flow_complete', 'interaction_complete'}))
            for interlude in ['operative_contact', 'ongoing_interaction', 'closure_interaction']:
                if interlude in stages:
                    reachable.add(interlude)
            continue
        available = [a for a in stages[stage_id]['actions'] if a['id'] not in done and set(a['requires']) <= flags]
        check(bool(available), prefix + 'deadlocked actions at ' + stage_id)
        for a in available:
            pending.append((a['next'] or stage_id, done | {a['id']}, flags | set(a['flags'])))
    check(reachable == set(stages), prefix + 'unreachable stage')

if errors:
    raise SystemExit('\n'.join(errors))
print(f'PASS: {sum(len(r) for r in collections.values())} records, schemas, references, roles, dialogue and encounter graphs')
