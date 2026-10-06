"""Schema + cross-reference checks. Run from any directory."""
import json
import re
from datetime import date
from pathlib import Path
from jsonschema import Draft202012Validator
from patient_bundles import load_patient_bundles
ROOT = Path(__file__).resolve().parents[1]
def read(path):
    return json.loads((ROOT / 'data' / path).read_text())
def read_collection(path):
    source = read(path)
    if isinstance(source, list):
        return source
    if not isinstance(source, dict) or not isinstance(source.get('files'), list):
        raise ValueError(f'Invalid collection or collection index: {path}')
    base = Path(path).parent
    rows = []
    for relative in source['files']:
        part = read(str(base / relative))
        if not isinstance(part, list):
            raise ValueError(f'Collection shard must be an array: {base / relative}')
        rows.extend(part)
    return rows
schema = read('schemas/content.schema.json')
manifest = read('manifest.json')
errors = []
collections = {}
def check(condition, message):
    if not condition: errors.append(message)

GAME_START_DATE = date(2025, 4, 1)
GAME_END_DATE = date(2026, 3, 31)

def game_day_for_iso(value):
    try:
        parsed = date.fromisoformat(value)
    except (TypeError, ValueError):
        return -1
    if parsed < GAME_START_DATE or parsed > GAME_END_DATE:
        return -1
    return (parsed - GAME_START_DATE).days + 1

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
check(protagonist.get('name') == '坂口隆司', 'Canonical protagonist name must be 坂口隆司')
check(protagonist.get('family_name') == '坂口', 'Canonical protagonist family name must be 坂口')
check(protagonist.get('given_name') == '隆司', 'Canonical protagonist given name must be 隆司')
check(protagonist.get('professional_name') == '坂口医生', 'Canonical professional address must be 坂口医生')
career_background = protagonist.get('career_background', {})
check(career_background.get('overseas_training_completed') is True,
      'Protagonist background must record completed overseas training')
check(career_background.get('distinguished_resume') is True,
      'Protagonist background must record the distinguished resume')
check(career_background.get('arrival_reason') == 'mentor_recommendation',
      'Protagonist must arrive through the former mentor recommendation')
check(career_background.get('contract_months') == 12,
      'Protagonist initial contract must be exactly one year')
check(career_background.get('initial_intent') == 'temporary_return_base',
      'Protagonist must initially regard Hoshimi as a temporary return base')
office_items = {item.get('id'): item for item in protagonist.get('office_items', [])}
mentor_letter = office_items.get('mentor_recommendation_letter', {})
check('office_has_mentor_letter' in protagonist.get('office_flags', []),
      'Initial office must contain the mentor-letter flag')
check(mentor_letter.get('flag') == 'office_has_mentor_letter',
      'Mentor recommendation letter must use its reserved office flag')
kind = dict(staff='staff', patients='patient', cameo_patients='cameo_patient', first_surgery_diagnosis_reactions='first_surgery_diagnosis_reaction', relationships='relationship', relationship_activity_placeholders='relationship_activity_placeholder', cases='case', case_templates='case_template', advanced_referral_cases='advanced_referral_case', surgeries='surgery', patient_interactions='patient_interaction', temporary_conditions='temporary_condition', palpation_profiles='palpation_profile', teams='team', backgrounds='background', time_events='time_event', character_events='character_event', special_events='special_event', special_event_steps='special_event_step', date_profiles='date_profile', date_locations='date_location', staff_role_cg_rewards='staff_role_cg_reward', micro_events='micro_event', surgery_team_dialogue_profiles='surgery_team_dialogue_profile', examination_cg_pools='examination_cg_pool', surgery_cg_pools='surgery_cg_pool', ward_preparation_cg_pools='ward_preparation_cg_pool', locations='location', encounters='encounter', preops='preop')
for key, path in manifest['collections'].items():
    rows = read_collection(path)
    collections[key] = rows
    validator = Draft202012Validator({'$ref': '#/$defs/' + kind[key], '$defs': schema['$defs']})
    for index, row in enumerate(rows):
        errors.extend(f'{key}[{index}] {e.json_path}: {e.message}' for e in validator.iter_errors(row))
    if key != 'relationships':
        ids = [r.get('id') for r in rows]
        check(len(ids) == len(set(ids)), f'Duplicate id in {key}')

required_palpation_profiles = {'generic', 'abdominal', 'breast', 'gynecology_pelvic', 'thoracic_cardiac'}
palpation_profile_ids = {row.get('id') for row in collections.get('palpation_profiles', [])}
check(required_palpation_profiles.issubset(palpation_profile_ids),
      'Palpation profiles must define generic, abdominal, breast, gynecology_pelvic and thoracic_cardiac')
for surgery in collections.get('surgeries', []):
    check(surgery.get('palpation_profile') in palpation_profile_ids,
          f"Surgery {surgery.get('id')} references an unknown palpation profile")
    expected_anesthesia_targets = {
        'abdominal': ['abdomen'],
        'thoracic_cardiac': ['chest'],
        'breast': ['breast'],
        'gynecology_pelvic': ['genital'],
    }.get(surgery.get('palpation_profile'))
    if expected_anesthesia_targets is not None:
        check(surgery.get('anesthesia_target_regions') == expected_anesthesia_targets,
              f"Surgery {surgery.get('id')} has the wrong anesthesia target regions")

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
    check(isinstance(bundle.get('diagnosis_reactions'), list), prefix + 'missing patient-owned diagnosis reactions')
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
collections['first_surgery_diagnosis_reactions'].extend(patient_collections['first_surgery_diagnosis_reactions'])
diagnosis_validator = Draft202012Validator({'$ref': '#/$defs/first_surgery_diagnosis_reaction', '$defs': schema['$defs']})
for index, row in enumerate(patient_collections['first_surgery_diagnosis_reactions']):
    errors.extend(f'first_surgery_diagnosis_reactions patient bundle [{index}] {e.json_path}: {e.message}' for e in diagnosis_validator.iter_errors(row))
diagnosis_ids = [row.get('id') for row in collections['first_surgery_diagnosis_reactions']]
check(len(diagnosis_ids) == len(set(diagnosis_ids)), 'Duplicate id after merging patient-owned diagnosis reactions')
by = {key: {r['id']: r for r in rows} for key, rows in collections.items() if key != 'relationships'}

diagnosis_reaction_counts = {}
for reaction in collections['first_surgery_diagnosis_reactions']:
    check(reaction['event_type'] == 'first_surgery_diagnosis_shock',
          reaction['id'] + ': wrong diagnosis reaction event type')
    if not reaction.get('patient_id'):
        group = reaction['site_group']
        diagnosis_reaction_counts[group] = diagnosis_reaction_counts.get(group, 0) + 1
check(diagnosis_reaction_counts == {
    'breast': 4,
    'abdominal': 5,
    'gynecology_pelvic': 6,
    'thoracic_cardiac': 5,
    'generic': 2,
}, 'First-surgery diagnosis reaction pool must contain the authored 22 variants')
owned_diagnosis_groups = {}
for reaction in collections['first_surgery_diagnosis_reactions']:
    if reaction.get('patient_id'):
        owned_diagnosis_groups.setdefault(reaction['patient_id'], set()).add(reaction['site_group'])
required_diagnosis_groups = {'breast', 'abdominal', 'gynecology_pelvic', 'thoracic_cardiac', 'generic'}
for patient in patient_collections['patients']:
    check(owned_diagnosis_groups.get(patient['id'], set()) == required_diagnosis_groups,
          patient['id'] + ': patient bundle must own one first-surgery reaction for every site group')

date_location_ids = set(by['date_locations'])
for profile in collections['date_profiles']:
    prefix = profile['id'] + ': '
    check(profile['staff_id'] in by['staff'], prefix + 'unknown date-profile staff member')
    check(set(profile['preferred_locations']) <= date_location_ids, prefix + 'unknown preferred date location')
    check(set(profile['disliked_locations']) <= date_location_ids, prefix + 'unknown disliked date location')
    if profile.get('first_date_event_id'):
        check(profile['first_date_event_id'] in by['character_events'], prefix + 'unknown first-date character event')
for location in collections['date_locations']:
    if location['asset_status'] == 'ready':
        check(bool(location['background_id']) and location['background_id'] in by['backgrounds'],
              location['id'] + ': ready date location needs a known background')
        check(bool(location['preview_path']) and (ROOT / location['preview_path']).is_file(),
              location['id'] + ': ready date location preview is missing')

role_reward_pairs = set()
role_reward_categories = {
    'assistant_surgeon': 'doctor',
    'scrub_nurse': 'nurse',
    'circulating_nurse': 'nurse',
    'ward_nurse': 'nurse',
}
for reward in collections['staff_role_cg_rewards']:
    prefix = reward['id'] + ': '
    actor = by['staff'].get(reward['staff_id'])
    check(bool(actor), prefix + 'unknown staff member')
    if actor:
        check(actor.get('team_category', actor.get('profession')) == role_reward_categories[reward['role_id']],
              prefix + 'staff member is not qualified for the rewarded role')
    pair = (reward['staff_id'], reward['role_id'])
    check(pair not in role_reward_pairs, prefix + 'duplicate staff/role reward')
    role_reward_pairs.add(pair)
    check((ROOT / reward['path']).is_file(), prefix + 'CG file missing')

# Older characters can remain on the explicit backlog while their missing art is
# produced. Every newly added female doctor/nurse is rejected by validation if
# her complete mandatory role-CG set is absent.
legacy_role_cg_backlog = {
    'doc_asuka', 'doc_artoria', 'visiting_maya',
    'visiting_futaba', 'doc_sakura_anesthesiology',
    'nurse_ishigami', 'nurse_satsuki',
}
for actor in collections['staff']:
    if actor.get('gender') != 'female' or actor['id'] in legacy_role_cg_backlog:
        continue
    category = actor.get('team_category', actor.get('profession'))
    if category == 'doctor' and 'assistant_surgeon' in actor.get('surgical_roles', []):
        check((actor['id'], 'assistant_surgeon') in role_reward_pairs,
              actor['id'] + ': female doctor is missing mandatory assistant-surgeon CG')
    if category == 'nurse':
        for role_id in ('scrub_nurse', 'circulating_nurse', 'ward_nurse'):
            check((actor['id'], role_id) in role_reward_pairs,
                  actor['id'] + ': female nurse is missing mandatory ' + role_id + ' CG')

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
        special_event = by['special_events'].get(event_id, {})
        check(bool(event) or bool(special_event), prefix + 'unknown bond/rank event ' + event_id)
        if event:
            check(event.get('actor_id') == relation['target_id'], prefix + event_id + ': event actor mismatch')
            expected_category = 'bond' if slot['target_level'] == 1 else 'rank_up'
            check(event.get('category') == expected_category, prefix + event_id + ': wrong event category')
            check(event.get('target_level') == slot['target_level'], prefix + event_id + ': target level mismatch')
        elif special_event:
            reward = next((entry for entry in special_event.get('relationship_rewards', [])
                           if entry.get('actor_id') == relation['target_id']), {})
            check(reward.get('target_level') == slot['target_level'],
                  prefix + event_id + ': special-event relationship reward mismatch')

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
    exclusion_flag = ('exclude_adult_intimacy' if placeholder['id'] == 'operating_room_patient_play'
                      else 'exclude_clinical_practice_patient')
    adult_route_staff = {actor_id for actor_id, actor in by['staff'].items()
                         if not ({'professional_friendship_only', 'relationship_progression_locked', exclusion_flag}
                                 & set(actor.get('flags', [])))}
    check(set(placeholder['eligible_staff_ids']) == adult_route_staff,
          prefix + 'must apply to every eligible medical staff member')
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
    actor = by['staff'][relation['target_id']]
    if {'professional_friendship_only', 'relationship_progression_locked'} & set(actor.get('flags', [])):
        check(not slots[4]['event_id'] and not slots[4]['benefit_id'] and
              not slots[5]['event_id'] and not slots[5]['benefit_id'],
              relation['target_id'] + ': professional friendship must end at Lv3')
    elif 'exclude_adult_intimacy' in actor.get('flags', []) or 'exclude_clinical_practice_patient' in actor.get('flags', []):
        check(not slots[4]['benefit_id'] and not slots[5]['benefit_id'],
              relation['target_id'] + ': excluded route must not grant generic Lv4/Lv5 benefits')
    else:
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
    'doc_asuka': '城宮 明日香',
    'doc_artoria': '阿尔托莉雅·潘德拉贡',
    'doc_shiori': '藤崎 詩織',
    'doc_aqua': '水城 阿库娅',
    'doc_sayaka': '南条 小夜香',
    'visiting_maya': '伊吹 摩耶',
    'visiting_futaba': '佐仓 双叶',
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

nakai = by['staff'].get('nurse_rin', {})
nakai_flags = set(nakai.get('flags', []))
check({'hidden_past_suspicious', 'past_truth_never_confirmed', 'past_disclosure_locked_at_lv5',
       'current_hoshimi_patient_safe', 'normal_group_participation'} <= nakai_flags,
      'nurse_rin: canonical hidden-past boundaries are incomplete')
check(nakai.get('rank') == '资深病房护士' and '围术期交接' in nakai.get('specialty', ''),
      'nurse_rin: senior ward/handoff role is missing')
check(bool(nakai.get('characterization', {}).get('relationship_arc')) and
      bool(nakai.get('team_dialogue', {}).get('stabilize')),
      'nurse_rin: characterization or professional team dialogue is incomplete')

maya = by['staff'].get('visiting_maya', {})
maya_relation = next((relation for relation in collections['relationships']
                      if relation['target_id'] == 'visiting_maya'), {})
maya_intro = by['character_events'].get('intro_visiting_maya_waveform_error', {})
check(maya.get('age') == 29 and maya.get('profession') == 'doctor' and
      maya.get('skills') == {'surgery': 28, 'diagnostics': 62, 'teamwork': 82,
                             'patient_care': 58, 'instrument_handling': 91, 'calmness': 76},
      'visiting_maya: visiting-research profile or authored skills changed')
check(maya.get('surgical_roles') == ['assistant_surgeon'] and
      maya.get('surgery_proficiency') == 'novice' and
      {'visiting_research_physician', 'non_core_roster', 'relationship_progression_locked',
       'no_romance_route', 'no_adult_route'} <= set(maya.get('flags', [])),
      'visiting_maya: special-assistant or route boundaries are incomplete')
check(maya.get('presence') == {'fixed_locations': ['imaging', 'or'],
                               'random_locations': ['lounge', 'exam']},
      'visiting_maya: hospital presence changed')
check(not maya_relation.get('met', True) and maya_relation.get('level') == 0 and
      maya_relation.get('route') == 'colleague' and
      'relationship_progression_locked' in maya_relation.get('flags', []),
      'visiting_maya: acquaintance-only relationship state is invalid')
check(maya_intro.get('category') == 'introduction' and maya_intro.get('location_id') == 'imaging' and
      maya_intro.get('conditions', {}).get('min_day') == 60 and
      maya_intro.get('conditions', {}).get('special_requirements') == [{
          'type': 'career_progress_any', 'minimum_completed_surgeries': 8, 'minimum_reputation': 20}],
      'visiting_maya: midgame waveform introduction gate is invalid')
for portrait_key in ['white_coat/neutral', 'scrubs/neutral', 'sterile/neutral']:
    portrait_path = maya.get('visuals', {}).get('portraits', {}).get(portrait_key, '')
    check(bool(portrait_path) and (ROOT / portrait_path).is_file() and
          png_has_alpha_channel(ROOT / portrait_path),
          'visiting_maya: missing transparent half-body portrait ' + portrait_key)

futaba = by['staff'].get('visiting_futaba', {})
futaba_relation = next((relation for relation in collections['relationships']
                        if relation['target_id'] == 'visiting_futaba'), {})
futaba_intro = by['character_events'].get('intro_visiting_futaba_body_does_not_believe', {})
check(futaba.get('age') == 26 and futaba.get('profession') == 'doctor' and
      futaba.get('skills') == {'surgery': 34, 'diagnostics': 91, 'teamwork': 76,
                               'patient_care': 74, 'instrument_handling': 70, 'calmness': 68},
      'visiting_futaba: visiting physician-scientist profile or authored skills changed')
check(futaba.get('surgical_roles') == ['assistant_surgeon'] and
      futaba.get('surgery_proficiency') == 'novice' and
      {'visiting_physician_scientist', 'visiting_researchers', 'arrived_with_maya',
       'relationship_progression_locked', 'no_romance_route', 'no_adult_route'} <= set(futaba.get('flags', [])),
      'visiting_futaba: assistant or guest-route boundaries are incomplete')
check(futaba.get('presence') == {'fixed_locations': ['imaging'],
                                 'random_locations': ['lounge', 'exam']},
      'visiting_futaba: hospital presence changed')
check(not futaba_relation.get('met', True) and futaba_relation.get('level') == 0 and
      futaba_relation.get('route') == 'colleague' and
      'relationship_progression_locked' in futaba_relation.get('flags', []),
      'visiting_futaba: acquaintance-only relationship state is invalid')
check(futaba_intro.get('category') == 'introduction' and
      futaba_intro.get('location_id') == 'imaging' and
      futaba_intro.get('conditions', {}).get('min_day') == 60 and
      futaba_intro.get('conditions', {}).get('required_events') == ['intro_visiting_maya_waveform_error'],
      'visiting_futaba: joint-researcher introduction gate is invalid')
for portrait_key in ['white_coat/neutral', 'scrubs/neutral', 'sterile/neutral']:
    portrait_path = futaba.get('visuals', {}).get('portraits', {}).get(portrait_key, '')
    check(bool(portrait_path) and (ROOT / portrait_path).is_file() and
          png_has_alpha_channel(ROOT / portrait_path),
          'visiting_futaba: missing transparent half-body portrait ' + portrait_key)

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
        requirement_type = requirement.get('type')
        check(requirement_type in {'player_attribute', 'career_progress_any', 'completed_surgeries', 'completed_surgeries_in_group', 'story_flag', 'special_event_completed', 'relationship_level'},
              event['id'] + ': unknown special requirement type')
        if requirement_type == 'player_attribute':
            check(requirement.get('attribute') in {'skill', 'leadership', 'charm', 'reputation', 'presence'},
                  event['id'] + ': unknown player attribute requirement')
        elif requirement_type == 'career_progress_any':
            check(isinstance(requirement.get('minimum_completed_surgeries'), int) and
                  isinstance(requirement.get('minimum_reputation'), int),
                  event['id'] + ': invalid career progress requirement')
        elif requirement_type == 'completed_surgeries':
            check(isinstance(requirement.get('minimum'), int) and requirement.get('minimum') >= 0,
                  event['id'] + ': invalid completed-surgeries requirement')
        elif requirement_type == 'completed_surgeries_in_group':
            check(requirement.get('procedure_group') in {surgery['procedure_group'] for surgery in collections['surgeries']} and
                  isinstance(requirement.get('minimum'), int) and requirement.get('minimum') >= 0,
                  event['id'] + ': invalid procedure-group surgery requirement')
        elif requirement_type == 'relationship_level':
            check(isinstance(requirement.get('level'), int) and 0 <= requirement.get('level') <= 5,
                  event['id'] + ': invalid relationship-level requirement')
        elif requirement_type == 'special_event_completed':
            check(requirement.get('event_id') in by['special_events'],
                  event['id'] + ': unknown special-event requirement')
    follow_up = event.get('auto_follow_up')
    if follow_up:
        check(follow_up['event_id'] in by['character_events'], event['id'] + ': unknown automatic follow-up event')
special_event_flags = set()
for event in collections['special_events']:
    prefix = event['id'] + ': '
    check(event['duration_days'] == len(event['event_chain']), prefix + 'duration_days must match event_chain length')
    check(isinstance(event['consumes_full_day'], bool), prefix + 'consumes_full_day must be boolean')
    if not event['consumes_full_day']:
        check(event['duration_days'] == 1, prefix + 'zero-time special events must use one event-chain chapter')
    trigger_mode = event.get('trigger_mode', 'day_start')
    check(trigger_mode in {'day_start', 'location'}, prefix + 'invalid trigger_mode')
    if trigger_mode == 'location':
        check(event.get('location_id') in by['locations'], prefix + 'unknown location trigger')
    else:
        check(not event.get('location_id'), prefix + 'day_start event must not define location_id')
    timing = event.get('timing', {'trigger_day': 1, 'priority': 0, 'final_week_allowed': False})
    trigger_day = timing.get('trigger_day', game_day_for_iso(timing.get('trigger_date')))
    check(trigger_day >= 1, prefix + 'trigger_date is outside the playable year')
    scheduled_end = trigger_day + event['duration_days'] - 1
    check(scheduled_end <= 365, prefix + 'scheduled duration exceeds the one-year game limit')
    if not timing['final_week_allowed']:
        check(scheduled_end < 359, prefix + 'ordinary event occupies the reserved final week')
    gallery_entry = event.get('gallery_entry')
    if event['gallery_unlock']:
        check(isinstance(gallery_entry, dict), prefix + 'gallery-enabled event needs gallery_entry')
        if isinstance(gallery_entry, dict):
            check(gallery_entry['id'] == event['id'], prefix + 'gallery entry id mismatch')
            check(len(gallery_entry['chapters']) == len(event['event_chain']), prefix + 'gallery chapters must match event chain')
    check(set(event['event_chain']) <= set(by['special_event_steps']), prefix + 'unknown special-event step')
    for actor_id in event['required_characters']:
        check(actor_id == 'PLAYER' or actor_id in by['staff'], prefix + 'unknown required character ' + actor_id)
    for reward in event.get('relationship_rewards', []):
        check(reward['actor_id'] in by['staff'], prefix + 'unknown relationship reward actor')
        check(1 <= reward['target_level'] <= 5, prefix + 'invalid relationship reward level')
    for prerequisite in event['prerequisite_events']:
        check(prerequisite in by['character_events'] or prerequisite in by['special_events'], prefix + 'unknown prerequisite event ' + prerequisite)
    for flag in event['completion_flags']:
        check(flag not in special_event_flags, prefix + 'completion flag reused by another special event')
        special_event_flags.add(flag)
    for requirement in event['unlock_requirements']:
        kind_name = requirement['type']
        if 'actor_id' in requirement:
            check(requirement['actor_id'] in by['staff'], prefix + 'unknown requirement actor')
        if kind_name in {'character_event_completed', 'days_after_character_event'}:
            check(requirement['event_id'] in by['character_events'], prefix + 'unknown character-event requirement')
        if kind_name == 'days_after_character_event':
            check(isinstance(requirement.get('days'), int) and requirement['days'] >= 0,
                  prefix + 'invalid character-event delay')
        if kind_name == 'special_event_completed':
            check(requirement['event_id'] in by['special_events'], prefix + 'unknown special-event requirement')
        if kind_name == 'completed_surgeries_in_group':
            check(requirement['procedure_group'] in {s['procedure_group'] for s in collections['surgeries']}, prefix + 'unknown procedure group')
        if kind_name in {'day_number', 'month_number'} and 'maximum' in requirement:
            check(requirement.get('minimum', 1) <= requirement['maximum'], prefix + 'invalid calendar range')
        if kind_name == 'calendar_date':
            check(game_day_for_iso(requirement['date']) >= 1, prefix + 'calendar_date is outside the playable year')
        if kind_name == 'calendar_range':
            first = game_day_for_iso(requirement['start_date'])
            last = game_day_for_iso(requirement['end_date'])
            check(first >= 1 and last >= first, prefix + 'invalid fixed calendar range')

for step in collections['special_event_steps']:
    prefix = step['id'] + ': '
    check(step['background_id'] in by['backgrounds'], prefix + 'unknown background')
    nodes = {node['id']: node for node in step['nodes']}
    check(len(nodes) == len(step['nodes']) and step['start'] in nodes, prefix + 'invalid node graph')
    reachable, pending = set(), [step['start']]
    while pending:
        node_id = pending.pop()
        if node_id in reachable or node_id not in nodes:
            continue
        reachable.add(node_id)
        for choice in nodes[node_id]['choices']:
            destination = choice['next']
            check(destination == '@day_end' or destination in nodes, prefix + node_id + ': unknown destination ' + destination)
            if destination != '@day_end':
                pending.append(destination)
        fallback = nodes[node_id].get('fallback_next')
        if fallback:
            check(fallback in nodes, prefix + node_id + ': unknown conditional fallback ' + fallback)
            pending.append(fallback)
    check(reachable == set(nodes), prefix + 'unreachable nodes')
    check(any(choice['next'] == '@day_end' for node in step['nodes'] for choice in node['choices']), prefix + 'no day ending')
    for node in step['nodes']:
        if node.get('background_id'):
            check(node['background_id'] in by['backgrounds'], prefix + node['id'] + ': unknown node background')
        check(not node.get('requirements') or bool(node.get('fallback_next')),
              prefix + node['id'] + ': conditional node needs fallback_next')
        actor_id = node.get('actor_id', '')
        if node['speaker'] == 'actor':
            check(actor_id in by['staff'], prefix + node['id'] + ': actor speaker needs a known actor_id')
        if actor_id:
            check(actor_id in by['staff'], prefix + node['id'] + ': unknown visual actor')
            actor = by['staff'].get(actor_id, {})
            outfit = node.get('outfit', actor.get('visuals', {}).get('default_outfit', ''))
            if not node.get('hide_portrait') and not node.get('cg_path') and not node.get('portrait_path'):
                check(outfit + '/' + node['expression'] in actor.get('visuals', {}).get('portraits', {}), prefix + node['id'] + ': missing actor portrait')
        if node.get('cg_path') or node.get('portrait_path'):
            path = node.get('cg_path') or node.get('portrait_path')
            check((ROOT / path).is_file(), prefix + node['id'] + ': visual asset missing')

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
for surgery_id, surgery in by['surgeries'].items():
    if surgery.get('status') == 'placeholder' or surgery.get('catalog_visibility') == 'advanced_referral':
        continue
    check(generic_progress_counts.get(surgery_id, 0) == 1,
          f'{surgery_id}: expected exactly one generic progress surgery CG pool')
known_preparation_cg_actions = {
    'ward_enema', 'ward_enema_unnecessary',
    'ward_skin_prep', 'ward_skin_prep_unnecessary',
    'ward_surgical_cap',
    'urinary_catheterization', 'skin_disinfection', 'ack_disinfection', 'request_scalpel',
}
for pool in collections['ward_preparation_cg_pools']:
    prefix = pool['id'] + ': '
    check(set(pool['action_ids']) <= known_preparation_cg_actions, prefix + 'unknown preparation CG action id')
    check(set(pool['patient_ids']) <= set(by['patients']), prefix + 'unknown patient id')
    check(set(pool.get('procedure_groups', [])) <= {surgery['procedure_group'] for surgery in collections['surgeries']},
          prefix + 'unknown procedure group')
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
    check(patient['age'] >= 18, prefix + 'ordinary surgery-pool patients must be adults')
    override_id = patient.get('first_surgery_diagnosis_shock_override_id', '')
    check(not override_id or override_id in by['first_surgery_diagnosis_reactions'],
          prefix + 'unknown first-surgery diagnosis shock override')
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
            check(option.get('effects', {}).get('presence', 0) > 0, prefix + option['id'] + ': coerced option must raise clinical presence')
            check(len(option.get('staff_intervention_hooks', [])) > 0, prefix + option['id'] + ': coerced option needs staff intervention hooks')
selectable_surgeries = {surgery['id'] for surgery in collections['surgeries']
                        if surgery.get('status') != 'placeholder' and surgery.get('catalog_visibility', 'standard') != 'advanced_referral'}
check(template_surgeries == selectable_surgeries, 'Selectable surgery template coverage is incomplete')
for person in collections['staff']:
    check(person['visuals']['default_outfit'] in person['visuals']['outfits'], 'Unknown default outfit')
    for key, path in person['visuals']['portraits'].items():
        check((ROOT / path).is_file(), 'Portrait asset missing: ' + path)
    avatar = person['visuals'].get('intraoperative_avatar', {})
    avatar_prefix = person['id'] + ': intraoperative HUD avatar '
    check(avatar.get('portrait_key') == 'intraoperative_avatar/neutral',
          avatar_prefix + 'must use the shared portrait key')
    expected_avatar_path = f"assets/characters/intraoperative_staff_avatars_v1/{person['id']}/neutral.png"
    check(avatar.get('target_path') == expected_avatar_path,
          avatar_prefix + 'target path does not match the staff ID')
    check(avatar.get('required_for') == ['operative_field_hud'],
          avatar_prefix + 'must remain assigned to the operative-field HUD')
    if avatar.get('status') == 'ready':
        registered_path = person['visuals']['portraits'].get('intraoperative_avatar/neutral', '')
        check(registered_path == expected_avatar_path,
              avatar_prefix + 'ready status requires the target path in visuals.portraits')
        check((ROOT / registered_path).is_file() and png_has_alpha_channel(ROOT / registered_path),
              avatar_prefix + 'ready asset must be an RGBA/gray-alpha PNG')
    else:
        check(avatar.get('status') == 'needed', avatar_prefix + 'has an unknown production status')
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

asuka = by['staff'].get('doc_asuka', {})
asuka_relation = next((relation for relation in collections['relationships']
                       if relation['target_id'] == 'doc_asuka'), {})
check(asuka.get('rank') == '医院院长／外科医生' and not asuka_relation.get('met', True),
      'doc_asuka: must be the hidden hospital director until her introduction')
check(asuka.get('skills', {}).get('diagnostics', 0) > asuka.get('skills', {}).get('surgery', 100) and
      asuka.get('skills', {}).get('teamwork', 0) > asuka.get('skills', {}).get('surgery', 100),
      'doc_asuka: theory and teamwork must exceed independent-surgery experience')
for portrait_key in ['white_coat/neutral', 'director_suit/neutral', 'casual/neutral',
                     'scrubs/neutral', 'sterile/neutral', 'operating_patient/nervous']:
    check(portrait_key in asuka.get('visuals', {}).get('portraits', {}),
          'doc_asuka: missing portrait ' + portrait_key)
asuka_scrub = by['character_events'].get('asuka_scrub_sink_encounter', {})
asuka_hint = by['character_events'].get('asuka_adjacent_operation_reveal', {})
asuka_intro = by['character_events'].get('intro_doc_asuka_director_office', {})
check(asuka_scrub.get('preop_stage_id') == 'changing' and
      asuka_scrub.get('preop_required_flags') == ['hands_ready'],
      'doc_asuka: first encounter must start only after hand scrubbing')
check(asuka_scrub.get('conditions', {}).get('special_requirements') == [{
          'type': 'career_progress_any', 'minimum_completed_surgeries': 2, 'minimum_reputation': 5}],
      'doc_asuka: first encounter needs two surgeries or reputation 5')
check(asuka_hint.get('preop_stage_id') == 'surgery_result' and
      asuka_hint.get('conditions', {}).get('required_events') == ['asuka_scrub_sink_encounter'],
      'doc_asuka: identity hint must follow a completed surgery')
check(asuka_intro.get('location_id') == 'director_office' and
      asuka_intro.get('conditions', {}).get('required_events') == ['asuka_adjacent_operation_reveal'] and
      asuka_intro.get('conditions', {}).get('days_after_required_events') == 1,
      'doc_asuka: identity reveal must occur in the director office on the next day')

artoria = by['staff'].get('doc_artoria', {})
artoria_relation = next((relation for relation in collections['relationships']
                         if relation['target_id'] == 'doc_artoria'), {})
check(artoria.get('rank') == '外科副部长／外科主任候选' and
      artoria.get('surgery_proficiency') == 'expert' and not artoria_relation.get('met', True),
      'doc_artoria: must begin as the unknown expert deputy surgery chief')
check(artoria.get('skills', {}).get('teamwork') == 98 and
      artoria.get('skills', {}).get('surgery') == 91 and
      artoria.get('skills', {}).get('calmness') == 96,
      'doc_artoria: authored surgery, teamwork and composure values changed')
check({'deputy_chief_of_surgery', 'surgery_director_candidate', 'team_leadership_specialist'} <=
      set(artoria.get('flags', [])),
      'doc_artoria: leadership and director-candidate flags are required')
check('team_unlock_requires_lv1' in artoria.get('flags', []),
      'doc_artoria: routine surgical-team eligibility must wait for Lv1')
for portrait_key in ['white_coat/neutral', 'casual/neutral', 'scrubs/neutral', 'sterile/neutral']:
    portrait_path = artoria.get('visuals', {}).get('portraits', {}).get(portrait_key, '')
    check(bool(portrait_path) and (ROOT / portrait_path).is_file(),
          'doc_artoria: missing half-body portrait ' + portrait_key)
artoria_intro = by['character_events'].get('intro_doc_artoria_deputy_office', {})
artoria_lv1 = by['character_events'].get('artoria_lv1_right_position', {})
artoria_referral = by['character_events'].get('asuka_mentions_artoria_rival', {})
artoria_slots = {slot['target_level']: slot for slot in artoria_relation.get('rank_slots', [])}
check('artoria_office' in by['locations'] and 'artoria_office' in by['backgrounds'] and
      artoria.get('presence', {}).get('fixed_locations') == ['or', 'artoria_office'],
      'doc_artoria: dedicated deputy-chief office or fixed presence is missing')
check(by['locations'].get('artoria_office', {}).get('name') == '副部长办公室',
      'doc_artoria: office map label must remain compact')
check(artoria_referral.get('actor_id') == 'doc_asuka' and
      artoria_referral.get('location_id') == 'director_office' and
      artoria_referral.get('conditions', {}).get('required_events') ==
      ['intro_doc_asuka_director_office', 'emiko_intro_rumored_hands'],
      'doc_artoria: Asuka referral must wait until both Asuka and Emiko are known')
check(artoria_intro.get('location_id') == 'artoria_office' and
      artoria_intro.get('category') == 'introduction' and
      artoria_intro.get('conditions', {}).get('required_events') == ['asuka_mentions_artoria_rival'] and
      artoria_intro.get('conditions', {}).get('special_requirements') == [],
      'doc_artoria: office introduction must follow Asuka naming Emiko\'s rival')
check(artoria_lv1.get('location_id') == 'artoria_office' and
      artoria_lv1.get('category') == 'bond' and
      artoria_lv1.get('conditions', {}).get('required_events') == ['intro_doc_artoria_deputy_office'] and
      artoria_slots.get(1, {}).get('event_id') == 'artoria_lv1_right_position' and
      artoria_slots.get(1, {}).get('benefit_id') == 'unlock_artoria_surgical_team',
      'doc_artoria: former allocation introduction must be the linked Lv1 team-unlock event')
check(artoria_lv1.get('gallery', {}).get('path') ==
      'assets/events/character_events/artoria/right_position.png' and
      artoria_lv1.get('gallery', {}).get('show_on_complete') is True,
      'doc_artoria: Lv1 allocation reward CG is not configured')

shiori = by['staff'].get('doc_shiori', {})
shiori_relation = next((relation for relation in collections['relationships']
                        if relation['target_id'] == 'doc_shiori'), {})
shiori_intro = by['character_events'].get('intro_doc_shiori_whole_patient', {})
shiori_ward_intro = by['character_events'].get('intro_doc_shiori_whole_patient_ward', {})
check(shiori.get('age') == 25 and shiori.get('profession') == 'doctor' and
      shiori.get('specialty') == '综合内科／総合内科' and
      shiori.get('surgery_proficiency') == 'limited' and
      shiori.get('surgical_roles') == ['assistant_surgeon'],
      'doc_shiori: must remain a limited internal-medicine assistant, not a primary surgeon')
check(shiori.get('skills') == {
          'surgery': 54, 'diagnostics': 92, 'teamwork': 89,
          'patient_care': 92, 'instrument_handling': 64, 'calmness': 90},
      'doc_shiori: authored skill values changed')
check(shiori.get('presence', {}).get('fixed_locations') == ['clinic', 'ward'] and
      shiori.get('presence', {}).get('random_locations') == ['lounge', 'rooftop'],
      'doc_shiori: clinic, ward and lunch presence are not configured')
check(not shiori_relation.get('met', True) and
      {key: shiori_relation.get(key) for key in ['affection', 'familiarity']} ==
      {'affection': 2, 'familiarity': 0} and
      'trust' not in shiori_relation and 'respect' not in shiori_relation,
      'doc_shiori: initial unknown Lv0 relationship values changed')
for portrait_key in ['white_coat/neutral', 'casual/neutral', 'scrubs/neutral', 'sterile/neutral']:
    portrait_path = shiori.get('visuals', {}).get('portraits', {}).get(portrait_key, '')
    check(bool(portrait_path) and (ROOT / portrait_path).is_file(),
          'doc_shiori: missing half-body portrait ' + portrait_key)
check(shiori_intro.get('category') == 'introduction' and
      shiori_intro.get('location_id') == 'clinic' and
      shiori_intro.get('conditions', {}).get('min_day') == 1 and
      shiori_intro.get('conditions', {}).get('required_events') == [] and
      shiori_intro.get('conditions', {}).get('special_requirements') ==
      [{'type': 'completed_surgeries', 'minimum': 3}],
      'doc_shiori: three-surgery clinic introduction gate is not configured')
check(shiori_ward_intro.get('category') == 'introduction' and
      shiori_ward_intro.get('location_id') == 'ward' and
      shiori_ward_intro.get('conditions', {}).get('min_day') == 1 and
      shiori_ward_intro.get('conditions', {}).get('special_requirements') ==
      [{'type': 'completed_surgeries', 'minimum': 3}],
      'doc_shiori: three-surgery ward introduction gate is not configured')

aqua = by['staff'].get('doc_aqua', {})
aqua_relation = next((relation for relation in collections['relationships']
                      if relation['target_id'] == 'doc_aqua'), {})
aqua_intro = by['character_events'].get('aqua_intro_exam_chair', {})
aqua_lv1 = by['character_events'].get('aqua_lv1_gyne_obsession', {})
aqua_slots = {slot['target_level']: slot for slot in aqua_relation.get('rank_slots', [])}
check(aqua.get('profession') == 'doctor' and
      aqua.get('specialty') == '妇科' and
      aqua.get('rank') == '妇科主任' and
      aqua.get('surgery_proficiency') == 'expert' and
      aqua.get('surgical_roles') == ['primary_surgeon', 'assistant_surgeon'],
      'doc_aqua: gynecology-director surgical profile changed')
check(aqua.get('skills') == {
          'surgery': 95, 'diagnostics': 96, 'teamwork': 82,
          'patient_care': 87, 'instrument_handling': 94, 'calmness': 90},
      'doc_aqua: authored skill values changed')
check(aqua.get('presence', {}).get('fixed_locations') == ['gynecology_exam', 'clinic'] and
      aqua.get('presence', {}).get('random_locations') == ['or', 'lounge'],
      'doc_aqua: clinic and gynecology presence are not configured')
check(not aqua_relation.get('met', True) and aqua_relation.get('level') == 0,
      'doc_aqua: must begin unknown at Lv0')
for portrait_key in ([f'{outfit}/{expression}'
                      for outfit in ['white_coat', 'scrubs', 'sterile']
                      for expression in ['neutral', 'joyful', 'troubled', 'terrified',
                                         'excited', 'depressed', 'blank']] +
                     ['operating_patient/nervous']):
    portrait_path = aqua.get('visuals', {}).get('portraits', {}).get(portrait_key, '')
    check(bool(portrait_path) and (ROOT / portrait_path).is_file(),
          'doc_aqua: missing portrait ' + portrait_key)
check(aqua_intro.get('category') == 'introduction' and
      aqua_intro.get('location_id') == 'gynecology_exam' and
      aqua_intro.get('conditions', {}).get('special_requirements') == [
          {'type': 'completed_surgeries_in_group', 'procedure_group': 'female_pelvic', 'minimum': 1}],
      'doc_aqua: introduction must require one completed gynecology surgery')
check(aqua_lv1.get('category') == 'bond' and
      aqua_lv1.get('conditions', {}).get('required_events') == ['aqua_intro_exam_chair'] and
      aqua_lv1.get('conditions', {}).get('special_requirements') == [
          {'type': 'completed_surgeries_in_group', 'procedure_group': 'female_pelvic', 'minimum': 5}] and
      aqua_slots.get(1, {}).get('event_id') == 'aqua_lv1_gyne_obsession' and
      aqua_slots.get(1, {}).get('benefit_id') == 'unlock_aqua_surgical_team',
      'doc_aqua: Lv1 gate or team-unlock link is not configured')

inexperienced_nurse_response_ids = {'assignment_scrub_nurse', 'assignment_circulating_nurse'}
for prep in collections['preops']:
    inexperienced_nurse_response_ids.update(
        action['id'] for stage in prep['stages'] for action in stage['actions']
        if action.get('response_role') in {'scrub_nurse', 'circulating_nurse'})
for surgery in collections['surgeries']:
    if surgery.get('catalog_visibility') == 'advanced_referral':
        continue
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
    trigger_mode = event['trigger_mode']
    preop_stage_id = event.get('preop_stage_id', '')
    if preop_stage_id:
        check(any(any(stage['id'] == preop_stage_id for stage in prep['stages']) for prep in collections['preops']),
              prefix + 'unknown preoperative stage trigger')
    check(trigger_mode != 'preop_stage' or bool(preop_stage_id), prefix + 'preop-stage trigger needs preop_stage_id')
    check(trigger_mode != 'sunday' or event.get('consumes_sunday') is True, prefix + 'Sunday trigger must consume Sunday')
    check(not event.get('consumes_sunday') or trigger_mode == 'sunday', prefix + 'consumes_sunday requires Sunday trigger mode')
    check(event['time_start'] < event['time_end'], prefix + 'invalid time window')
    if event.get('mandatory'):
        check('max_day' in event['conditions'] and event['conditions']['max_day'] >= event['conditions']['min_day'],
              prefix + 'mandatory event needs a valid day window')
    if event.get('consumes_sunday'):
        check(event.get('date_location_id') in date_location_ids, prefix + 'Sunday event needs a known date location')
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
            for related in choice.get('related_effects', []):
                check(related.get('actor_id') in by['staff'], prefix + 'unknown related-effect actor')
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
ayako = by['cameo_patients'].get('guest_ayako', {})
check(ayako.get('canonical_name') == '片桐彩子' and
      ayako.get('public_name') == '来院漫画家' and ayako.get('age') == 25,
      'guest_ayako: canonical external-visitor identity is incomplete')
check(ayako.get('debut_event_id') == 'miyama_02_manga_artist_wrong_patient' and
      ayako.get('identity_revealed_by_default') is False,
      'guest_ayako: planned Rei Lv2 debut interface changed')
for key in {
    'casual_neutral',
    'casual_shocked',
    'patient_gown_neutral',
    'patient_gown_puzzled',
    'patient_gown_happy',
    'operating_table_nervous',
    'operating_table_drowsy',
    'operating_table_composed',
    'operating_table_happy',
    'operating_table_annoyed',
    'ward_postop',
    'nurse_visit',
}:
    path = ROOT / ayako.get('visuals', {}).get(key, '')
    check(path.is_file(), 'guest_ayako: missing visual ' + key)
    check(png_has_alpha_channel(path), 'guest_ayako: ' + key + ' must be a transparent portrait')
ayako_lookalike = by['cameo_patients'].get('patient_ayako_lookalike', {})
check(ayako_lookalike.get('public_name') == '逃跑女患者' and
      ayako_lookalike.get('debut_event_id') == 'miyama_02_manga_artist_wrong_patient' and
      ayako_lookalike.get('identity_revealed_by_default') is False,
      'patient_ayako_lookalike: mistaken-surgery interface is incomplete')
lookalike_path = ROOT / ayako_lookalike.get('visuals', {}).get('patient_gown_fleeing', '')
check(lookalike_path.is_file(), 'patient_ayako_lookalike: fleeing portrait missing')
check(png_has_alpha_channel(lookalike_path),
      'patient_ayako_lookalike: fleeing portrait must be transparent')
miyama_ayako = by['special_events'].get('miyama_02_manga_artist_wrong_patient', {})
check(miyama_ayako.get('required_characters') == ['PLAYER', 'doc_rei', 'doc_shiori', 'doc_asuka'] and
      miyama_ayako.get('unlock_requirements') == [
          {'type': 'day_number', 'minimum': 5},
          {'type': 'relationship_level', 'actor_id': 'doc_rei', 'minimum': 1},
          {'type': 'relationship_level', 'actor_id': 'doc_shiori', 'minimum': 1}] and
      miyama_ayako.get('prerequisite_events') == ['miyama_01_safety_pin'],
      'miyama_02: formal Lv1 prerequisites are incomplete')
check(miyama_ayako.get('auto_schedule') is True and
      miyama_ayako.get('duration_days') == 1 and
      miyama_ayako.get('timing', {}).get('sunday_start_allowed') is False,
      'miyama_02: must be a mandatory 09:00 one-day event that defers on Sunday')
check(miyama_ayako.get('relationship_rewards') == [{
          'actor_id': 'doc_rei', 'target_level': 2,
          'benefit_id': '', 'allow_level_skip': False}],
      'miyama_02: formal sequential promotion to Miyama Lv2 is missing')
required_miyama_flags = {
    'miyama_02_manga_artist_wrong_patient_completed', 'relationship_doc_rei_lv2',
    'guest_ayako_met', 'ayako_wrong_surgery_survived', 'ayako_appendectomy_completed',
    'ayako_surgical_field_photo_owned', 'true_gastric_patient_fled_or',
    'true_gastric_patient_found_safe', 'true_gastric_patient_surgery_rescheduled',
    'patient_id_protocol_reviewed', 'origin_of_patient_disguise_unresolved',
    'shiori_knows_ayako_incident', 'ayako_shiori_reconnected'}
check(required_miyama_flags <= set(miyama_ayako.get('completion_flags', [])),
      'miyama_02: authored completion flags are incomplete')
miyama_step = by['special_event_steps'].get('miyama_02_manga_artist_wrong_patient_main', {})
check(len(miyama_step.get('nodes', [])) >= 500 and
      miyama_step.get('start') == 'lv1_callback' and
      all(any(node.get('id') == node_id for node in miyama_step.get('nodes', []))
          for node_id in ['s01_001', 's34_001', 'lv2_asuka_private', 'lv2_doctor']),
      'miyama_02: complete V8 sequence or new relationship bridges are missing')

miyama_lv1 = by['special_events'].get('miyama_01_safety_pin', {})
miyama_lv1_step = by['special_event_steps'].get('miyama_01_safety_pin_main', {})
check(miyama_lv1.get('prerequisite_events') == ['intro_doc_rei'] and
      miyama_lv1.get('relationship_rewards') == [{
          'actor_id': 'doc_rei', 'target_level': 1,
          'benefit_id': '', 'allow_level_skip': False}],
      'miyama_01: introduction prerequisite or Lv1 reward is incomplete')
check(any(node.get('id') == 'palpation_placeholder' and len(node.get('choices', [])) == 1
          for node in miyama_lv1_step.get('nodes', [])),
      'miyama_01: one-click OR-table palpation placeholder is missing')

miyama_lv3 = by['special_events'].get('miyama_03_or_god', {})
miyama_lv3_step = by['special_event_steps'].get('miyama_03_or_god_main', {})
check(miyama_lv3.get('prerequisite_events') == ['miyama_02_manga_artist_wrong_patient'] and
      miyama_lv3.get('relationship_rewards') == [{
          'actor_id': 'doc_rei', 'target_level': 3,
          'benefit_id': '', 'allow_level_skip': False}],
      'miyama_03: Lv2 prerequisite or sequential Lv3 reward is incomplete')
check(all(any(node.get('id') == node_id for node in miyama_lv3_step.get('nodes', []))
          for node_id in ['moe', 'ange', 'release', 'gown', 'cg', 'rank3']),
      'miyama_03: Honjo restraint, Tonegawa report, or surgery transition is missing')
for path in [
        'assets/events/character_events/rei/ayako/cg_01_lucky.png',
        'assets/events/character_events/rei/ayako/cg_02_patient_disguise.png',
        'assets/events/character_events/rei/ayako/cg_03_or_table.png',
        'assets/events/character_events/rei/ayako/cg_05_firsthand_notes.png',
        'assets/events/character_events/rei/ayako/cg_03a_first_incision_pre.png',
        'assets/events/character_events/rei/ayako/cg_03b_first_incision_after.png',
        'assets/events/character_events/rei/ayako/cg_04_lesion_missing.png']:
    check((ROOT / path).is_file(), 'miyama_02: missing CG asset ' + path)
rei_slots = {slot['target_level']: slot for slot in
             next(relation for relation in collections['relationships']
                  if relation['target_id'] == 'doc_rei').get('rank_slots', [])}
check(rei_slots.get(2, {}).get('event_id') == 'miyama_02_manga_artist_wrong_patient',
      'doc_rei: Lv2 slot must link to the Ayako special event')
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
    expected_diagnosis_group = {
        'breast': 'breast',
        'general_abdominal': 'abdominal',
        'urologic': 'abdominal',
        'vascular': 'abdominal',
        'female_pelvic': 'gynecology_pelvic',
        'thoracic': 'thoracic_cardiac',
        'cardiac': 'thoracic_cardiac',
    }.get(surgery['procedure_group'], 'generic')
    check(surgery['diagnosis_reaction_site_group'] == expected_diagnosis_group,
          prefix + 'diagnosis reaction site group does not match procedure group')
    ids = [s['id'] for s in surgery['stages']]
    check(len(ids) == len(set(ids)), prefix + 'duplicate surgery-flow stage id')
    check(bool(ids) or surgery.get('status') == 'placeholder', prefix + 'selectable surgery requires narrative stages')
    check(0 <= surgery['recommended_surgery'] <= surgery['base_difficulty'] <= 100,
          prefix + 'invalid difficulty or recommendation')
    check(surgery['training_ceiling'] >= surgery['recommended_surgery'], prefix + 'training ceiling below recommendation')
    option_ids = set()
    for stage in surgery['stages']:
        options = stage['options']
        tutorial_safe = surgery.get('catalog_visibility') == 'advanced_referral'
        check((1 <= len(options) <= 4) if tutorial_safe else len(options) == (1 if stage['kind'] == 'confirm' else 3),
              prefix + stage['id'] + ': wrong option count')
        for option in options:
            check(option['id'] not in option_ids, prefix + 'duplicate surgery-flow option id')
            option_ids.add(option['id'])
        strategic_stage = any('strategic_effects' in option or 'conditional_effects' in option for option in options)
        if strategic_stage:
            check(all(option['correct'] for option in options), prefix + stage['id'] + ': strategic options must all be valid choices')
            check(all('strategic_effects' in option for option in options), prefix + stage['id'] + ': strategic choice is missing its base effects')
        elif stage['kind'] == 'decision' and not tutorial_safe:
            check(sum(bool(option['correct']) for option in options) == 1, prefix + stage['id'] + ': decision requires exactly one correct option')
            check(all(option['correct'] or bool(option['correction']) for option in options), prefix + stage['id'] + ': wrong option requires assistant correction')
        else:
            check(all(option['correct'] for option in options), prefix + stage['id'] + ': non-decision options must be consequence-free')
expected_starting_procedures = {
    'surgery_appendix', 'surgery_open_cholecystectomy', 'surgery_open_inguinal_hernia',
    'surgery_open_ventral_hernia', 'surgery_breast_tumor', 'surgery_open_distal_gastrectomy',
    'surgery_open_splenectomy', 'surgery_open_ovarian_cystectomy', 'surgery_open_abdominal_myomectomy',
}
check({s['id'] for s in collections['surgeries'] if s['unlocked_at_start']} == expected_starting_procedures,
      'Starting procedure set must contain the authored nine operations')
vaginal_hysterectomy = by['surgeries'].get('surgery_vaginal_hysterectomy', {})
check(vaginal_hysterectomy.get('name') == '经阴道子宫全切除' and
      vaginal_hysterectomy.get('status') == 'placeholder' and
      not vaginal_hysterectomy.get('unlocked_at_start') and
      not vaginal_hysterectomy.get('stages'),
      'Vaginal hysterectomy must remain a locked non-selectable placeholder')
interaction_themes = {
    'operative_contact', 'progress_check', 'strain_interaction',
    'dignity_interaction', 'ongoing_interaction', 'closure_interaction',
}
generic_fallback_themes = set()
interaction_group_scopes = set()
interaction_surgery_scopes = set()
interaction_cues = set()
for interaction in collections['patient_interactions']:
    prefix = interaction['id'] + ': '
    check(not (interaction['procedure_groups'] and interaction['surgery_ids']),
          prefix + 'procedure_groups and surgery_ids are mutually exclusive')
    check(set(interaction['surgery_ids']) <= set(by['surgeries']), prefix + 'unknown surgery id')
    action_ids = [action['id'] for action in interaction['actions']]
    check(len(action_ids) == len(set(action_ids)), prefix + 'duplicate patient interaction action id')
    check(all(action['condition_effect'] is None for action in interaction['actions']),
          prefix + 'ordinary patient interactions cannot modify temporary conditions')
    interaction_group_scopes.update(interaction['procedure_groups'])
    interaction_surgery_scopes.update(interaction['surgery_ids'])
    interaction_cues.update(interaction['cues'])
    for action in interaction['actions']:
        if action['delegate_role']:
            check(action['response_speaker'] == 'staff',
                  prefix + action['id'] + ': delegated response must be spoken by staff')
    if not interaction['procedure_groups'] and not interaction['surgery_ids'] and not interaction['states'] and not interaction['cues']:
        generic_fallback_themes.add(interaction['theme'])
check(generic_fallback_themes == interaction_themes,
      'Patient interaction generic fallbacks must cover every awake theme')
procedure_groups = {surgery['procedure_group'] for surgery in collections['surgeries']}
check(interaction_group_scopes == procedure_groups,
      'Patient interaction procedure-group pools must cover every procedure group')
required_signature_surgeries = {
    'surgery_hysterectomy', 'surgery_open_ovarian_cystectomy',
    'surgery_open_abdominal_myomectomy', 'surgery_breast_tumor',
    'surgery_total_mastectomy', 'surgery_cabg',
}
check(required_signature_surgeries <= interaction_surgery_scopes,
      'Phase 1C signature interactions are missing required representative surgeries')
important_interaction_combinations = {
    ('operative_contact', 'pain', 'incision'),
    ('progress_check', 'fear', 'fatigue'),
    ('strain_interaction', 'pain', 'traction'),
    ('dignity_interaction', 'dignity', 'exposure'),
    ('ongoing_interaction', 'fear', 'fatigue'),
    ('closure_interaction', 'fear', 'closure'),
}
for theme, state, cue in important_interaction_combinations:
    variant_count = sum(
        interaction['theme'] == theme and state in interaction['states'] and cue in interaction['cues']
        for interaction in collections['patient_interactions']
    )
    check(variant_count >= 2,
          f'Phase 1C requires at least two variants for {theme} + {state} + {cue}')
used_patient_cues = {
    cue for surgery in collections['surgeries'] for stage in surgery['stages']
    for cue in stage.get('patient_cues', [])
}
check(interaction_cues <= used_patient_cues,
      'Patient interaction cues must be exercised by at least one surgery stage')
long_surgery_ongoing_ids = {
    'surgery_hysterectomy', 'surgery_cabg', 'surgery_exploratory_laparotomy',
    'surgery_open_total_gastrectomy', 'surgery_open_abdominoperineal_resection',
    'surgery_open_whipple', 'surgery_open_major_liver_resection',
    'surgery_open_pneumonectomy', 'surgery_open_esophagectomy',
    'surgery_open_radical_cystectomy', 'surgery_open_abdominal_aortic_aneurysm',
}
for surgery_id in long_surgery_ongoing_ids:
    surgery = by['surgeries'].get(surgery_id, {})
    check(any(stage.get('awake_interlude') == 'ongoing_interaction' for stage in surgery.get('stages', [])),
          surgery_id + ': long surgery requires an ongoing patient interaction marker')
condition_cues = set()
for condition in collections['temporary_conditions']:
    prefix = condition['id'] + ': '
    condition_cues.add(condition['trigger_cue'])
    action_ids = [action['id'] for action in condition['actions']]
    check(len(action_ids) == len(set(action_ids)), prefix + 'duplicate temporary-condition action id')
    check({action['delegate_role'] for action in condition['actions']} == {'', 'assistant_surgeon', 'circulating_nurse'},
          prefix + 'actions must include player, assistant-surgeon and circulating-nurse handling')
    check(sum(not action['delegate_role'] for action in condition['actions']) == 2,
          prefix + 'actions must include one personal response and one ignore response')
    for action in condition['actions']:
        check(action['condition_effect'] is not None,
              prefix + action['id'] + ': temporary-condition action requires a condition effect')
        if action['delegate_role']:
            check(action['response_speaker'] == 'staff',
                  prefix + action['id'] + ': delegated response must be spoken by staff')
check(condition_cues == {'nausea', 'drowsiness'},
      'Temporary conditions must define nausea and drowsiness exactly once')
used_condition_cues = {
    cue for surgery in collections['surgeries'] for stage in surgery['stages']
    for cue in stage.get('patient_cues', []) if cue in condition_cues
}
check(used_condition_cues == condition_cues,
      'Every temporary-condition cue must be used by at least one surgery stage')
story = read(manifest['dialogue'])
validator = Draft202012Validator({'$ref':'#/$defs/dialogue', '$defs':schema['$defs']})
errors.extend(e.message for e in validator.iter_errors(story))
nodes = {n['id']:n for n in story['nodes']}
check(len(nodes) == len(story['nodes']), 'Duplicate dialogue node')
check(story['start'] in nodes, 'Unknown dialogue start')
for node in nodes.values():
    check(node['speaker'] in {'narrator', 'player'} or node['speaker'] in by['staff'], 'Unknown speaker')
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
        check(stage['speaker'] in by['staff'] or stage['speaker'] in {'outpatient_support', encounter['patient_id']}, prefix + 'unknown speaker')
        check(stage['background_id'] in by['backgrounds'], prefix + 'unknown background')
        check(len(stage['actions']) <= 4, prefix + 'UI supports at most four actions per stage')
        for action in stage['actions']:
            check(action['id'] not in action_ids, prefix + 'duplicate action')
            action_ids.add(action['id'])
            check(action['speaker'] in by['staff'] or action['speaker'] in {'outpatient_support', encounter['patient_id']}, prefix + 'unknown response speaker')
            check(action['next'] is None or action['next'] in stages, prefix + 'unknown next stage')
            if action.get('consent_state') == 'coerced':
                check(action.get('presence_delta', 0) > 0, prefix + action['id'] + ': coerced clinic action must raise clinical presence')
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
            check(bundle['speaker'] in by['staff'] or bundle['speaker'] in {'outpatient_support', encounter['patient_id']}, prefix + 'unknown bundle speaker')
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
