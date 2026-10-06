#!/usr/bin/env python3
"""Fill deterministic English translations for the core playable loop.

The script only writes stable localization keys. Chinese JSON remains the
canonical authored source and can continue to evolve independently.
"""
from __future__ import annotations
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
EN_PATH=ROOT/'data/localization/en.json'
locale=json.loads(EN_PATH.read_text(encoding='utf-8'))
strings:dict[str,str]=locale['strings']

def put(key:str,value:str)->None:
    if value.strip(): strings[key]=value

def put_many(prefix:str, values:dict[str,str], field:str='label')->None:
    for identity,value in values.items(): put(f'{prefix}.{identity}.{field}',value)

# Protagonist office keepsakes.
put('protagonist.office_items.mentor_recommendation_letter.label', "Mentor's Recommendation Letter")
put('protagonist.office_items.mentor_recommendation_letter.description', "A letter your mentor wrote to Hoshimi Hospital. At the time, you did not understand why he had recommended this place in particular.")

# Opening sequence. Stable node IDs keep these lines independent from ordering.
intro={
'aoi_first_impression': "The person assigned to meet Ryuji Sakaguchi is already waiting by the window. She holds a chart against her chest, her white coat immaculate. When she sees him, her gaze first settles on his name badge, and only then does a faint smile appear. It is less a rehearsed welcome than the manner of a senior doctor accustomed to observing before she speaks.",
'aoi_welcome': "Good morning. Dr. Sakaguchi, correct? I'm Narumi Jinguji from General Surgery. I'll show you around today.",
'aoi_advice': "I've read your résumé, Dr. Sakaguchi. But a résumé only says what you have done before. Starting today, we'll see how you judge a situation and how you speak in front of a patient. If you're unsure, ask. You don't need to force yourself to look like a seasoned doctor.",
'aoi_question': "Your first day in an unfamiliar hospital—are you nervous?",
'aoi_honest': "It's normal to be nervous. The real danger is being too tense to hear anyone else while pretending you know everything. Just stay as you are now.",
'aoi_composed': "Good. The pace here can accelerate without warning, though. Keep up when you can, and speak up when you cannot. Saying something in time is also part of a doctor's judgment.",
'haru_arrival': "As she finishes speaking, light but measured footsteps approach from the other end of the corridor. A nurse carrying neatly arranged outpatient files stops before them, nods first to Dr. Jinguji, then turns to Sakaguchi.",
'haru_intro': "It's nice to meet you. I'm Ren Nanase. I mainly handle surgical nursing and today's coordination. Your outpatient files are ready. If you cannot find someone later, come to the nurses' station first. You can usually find me there.",
'haru_first_impression': "She keeps her eyes on Sakaguchi as she speaks. Her voice is gentle, but the movement with which she hands him the files is crisp and efficient. Colored tabs line the pages, and even the ward and operating-room locations he has not yet asked about are marked with brief notes.",
'haru_invite': "We have a little time before the first patient's appointment. Let's stop by the nurses' station and meet today's team. Then I'll take you to the examination room.",
'station_walk': "Sakaguchi follows Ren Nanase. She walks half a step ahead at a slower pace, pointing out the medication room, the ward passage, and the doors leading to the surgical area. The ringing phones and tapping keyboards of the nurses' station grow clearer.",
'station_haru': "This is the nurses' station. The morning team is small today, so the names should be easy to remember—Senior Nurse Nakai, and Asakura.",
'rin_intro': "Mika Nakai. I mainly handle ward care. I'll verify inpatient preparation, handoff, and postoperative observations with you. When you need help from the ward, say exactly what you need. No need to talk around it.",
'rin_impression': "Nurse Nakai turns to the next page of her handoff sheet. Her tone is almost stern in its brevity, yet she has already written an extension number beside Sakaguchi's name. She seems like someone who prepares everything one step ahead.",
'yui_intro': "I'm Miyuki Asakura, and I'm supporting the clinic today! I've worked in nursing for several years, but this is my first day at Hoshimi, so I'll confirm the hospital's procedures from the beginning. You can leave blood draws, test arrangements, and patient transport to me. Oh—if I ask too many questions, don't take it to mean I can't do the job.",
'yui_impression': "Nurse Asakura laughs before anyone else can. Her Hoshimi badge is brand new, but the notes in her pocket already sort the hospital's equipment models and handoff sequence into neat categories. Her energy briefly lightens the busy station.",
'station_close': "For your first day, remembering the three of us is enough. There will be more staff on future shifts, but you have met everyone you will need in the clinic and ward today. Come on—I'll show you your examination room.",
'sayaka_hallway_collision': "Soon after they leave the nurses' station, a figure rounds the corner and stops short. Sakaguchi checks his step just in time; their shoulders miss each other by inches. Several health-management forms slip from her arms.",
'sayaka_intro': "“That was close. Are you hurt?”\nShe crouches to gather the papers, then looks up at the new badge on Sakaguchi's chest.\n“Dr. Ryuji Sakaguchi? I'm Sayaka Nanjo. General practice, health management—and whenever another department suddenly needs a doctor, I may get dropped in there too.”",
'sayaka_generalist': "“Does that count as introducing your department?”",
'sayaka_boundary': "“Call it a Hoshimi specialty.”\nShe slides the last page into her folder, her smile carrying the calm of someone who knows exactly what she is saying.\n“You can ask me for ordinary assistance or cross-department coverage. If something is beyond me, I'll say so myself. Being able to admit what you cannot do is also part of being a doctor.”",
'sayaka_tease': "“And you've been staring at me because you're trying to remember a new colleague's face, right?”\nBefore Sakaguchi can answer, she has already stepped aside to clear the corridor.\n“Let's record your answer as ‘yes’ for now. Don't be late on your first day, Dr. Sakaguchi.”",
'clinic_walk': "Ren Nanase opens the door at the end of the corridor. Charts, a stethoscope, and newly delivered test forms are arranged neatly on the desk. Beyond the door comes the muted conversation of waiting patients. Only now does the reality of a first day about to begin truly settle in.",
'clinic_handover': "This is your examination room, Dr. Sakaguchi. The first patient has arrived, and I'll be nearby to assist. When you're ready, we can begin.",
}
for node,text in intro.items(): put(f'dialogue.nodes.{node}.text',text)
put('dialogue.nodes.aoi_question.choices.0.label','Honestly, a little.')
put('dialogue.nodes.aoi_question.choices.1.label',"I'll get up to speed as quickly as I can.")

put_many('collections.backgrounds',{
'lobby':'Hospital Lobby','hallway':'Main Corridor','clinic':'Outpatient Examination Room','ward':'Inpatient Ward','nurses_station':"Nurses' Station",'exam_room':'Examination Room','diagnostics':'Diagnostic Imaging','staff_lounge':'Staff Lounge','changing':'Operating-Room Changing Area','scrub_area':'Surgical Scrub Area','operating_room':'Operating Room','operating_team_01':'Operating Team I','operating_team_02':'Operating Team II','operating_team_03':'Operating Team III','operating_team_04':'Operating Team IV','operating_team_05':'Operating Team V','operating_team_06':'Operating Team VI','rooftop':'Hospital Rooftop','surgery_director_office':"Director of Surgery's Office",'hospital_night':'Hospital at Night','pharmacy':'Hospital Pharmacy','gynecology_exam_room':'Gynecology Examination Room','director_office':"Hospital Director's Office",'emiko_office':"Chief Surgeon Mido's Office",'artoria_office':"Deputy Chief Pendragon's Office",'player_office':"Sakaguchi's Office",'new_operating_room':'New Operating Room','italian_trattoria':'Warm Italian Trattoria'})

locations={
'clinic':('OUTPATIENT','The first patient is waiting. Select a patient to begin the consultation or continue the previous case.'),
'ward':('WARD','Visit admitted patients, explain their surgical plans, and assemble the team.'),
'station':("NURSES’ STATION",'Today’s roster is ready. Handoffs and team events take place here.'),
'exam':('EXAMINATION','The first case’s examination sequence is integrated into the outpatient consultation.'),
'imaging':('DIAGNOSTICS','Laboratory and imaging results for the first case can be reviewed in the outpatient chart.'),
'or':('OPERATING ROOM','After completing ward preparation, continue here with changing and the preoperative confirmation.'),
'lounge':('STAFF LOUNGE','On-duty colleagues rest here. After meeting them, you may encounter someone visiting the lounge at midday.'),
'rooftop':('ROOFTOP','Wind crosses the city from the distant mountains. Quiet private conversations and relationship events can take place here.'),
'emiko_office':('CHIEF SURGEON · MIDO','Chief Surgeon Emiko Mido handles cases, rosters, and departmental business in this office. Visitors without an appointment usually need to explain themselves to the nurse outside.'),
'artoria_office':('PENDRAGON OFFICE','Deputy Chief Artoria Pendragon handles surgical schedules, case plans, and team assignments here. The scheduling board is always updated through the final operation of the day.'),
'surgery_director_office':('SURGICAL DIRECTOR','The office is currently vacant. A future director of surgery will manage the department and trigger personal conversations here.'),
'pharmacy':('PHARMACY','Prescriptions, dispensing, and medication checks are completed here. Manami Iimura is organizing today’s medication records behind the counter.'),
'gynecology_exam':('GYNECOLOGY','A private examination room with a powered gynecologic table and ultrasound system. Gynecology chief Aqua Mizushiro often sees patients here—and occasionally tests new equipment before reading the manual.'),
'director_office':('HOSPITAL DIRECTOR',"The director's door is usually closed. No one seems to be inside right now."),
'player_office':('YOUR OFFICE','An office the hospital has temporarily lent Sakaguchi. The desk is still bare, but cases, relationships, and the memories of this year will gradually leave their mark here.'),
}
for identity,(subtitle,desc) in locations.items():
 put(f'collections.locations.{identity}.subtitle',subtitle); put(f'collections.locations.{identity}.description',desc)

people={'doc_aoi':'Narumi Jinguji','doc_rei':'Kaori Miyama','nurse_haru':'Ren Nanase','nurse_rin':'Mika Nakai','nurse_yui':'Miyuki Asakura','nurse_ange':'Ange Tonegawa','nurse_hiroko':'Hiroko Sugimura','nurse_moe':'Moe Honjo','doc_sayaka':'Sayaka Nanjo','pharmacist_manami':'Manami Iimura','visiting_maya':'Maya Ibuki','visiting_futaba':'Futaba Sakura'}
time_labels={
'lounge_chat_doc_aoi':'Chat with Narumi Jinguji','lounge_chat_doc_rei':'Chat with Kaori Miyama','lounge_chat_nurse_haru':'Chat with Ren Nanase','lounge_chat_nurse_rin':'Chat with Mika Nakai','lounge_chat_nurse_yui':'Chat with Miyuki Asakura','rooftop_pause':'Spend Some Time in the Wind','rooftop_chat_doc_aoi':'Talk with Narumi Jinguji','rooftop_chat_doc_rei':'Talk with Kaori Miyama','rooftop_chat_nurse_haru':'Talk with Ren Nanase','rooftop_chat_nurse_rin':'Talk with Mika Nakai','rooftop_chat_nurse_yui':'Talk with Miyuki Asakura','director_office_check':'Check the Office Schedule','clinic_chat_doc_aoi':'Talk with Narumi Jinguji','exam_chat_doc_rei':'Talk with Kaori Miyama','or_chat_nurse_haru':'Talk with Ren Nanase','ward_chat_nurse_rin':'Talk with Mika Nakai','station_chat_nurse_rin':'Talk with Mika Nakai','clinic_chat_nurse_yui':'Talk with Miyuki Asakura','station_chat_nurse_yui':'Talk with Miyuki Asakura','pharmacy_chat_manami':'Talk with Manami Iimura','or_chat_nurse_ange':'Talk with Ange Tonegawa','ward_chat_nurse_hiroko':'Talk with Hiroko Sugimura','clinic_chat_nurse_hiroko':'Talk with Hiroko Sugimura','clinic_chat_nurse_moe':'Talk with Moe Honjo','or_chat_nurse_moe':'Talk with Moe Honjo','clinic_chat_doc_sayaka':'Talk with Sayaka Nanjo','lounge_chat_doc_sayaka':'Chat with Sayaka Nanjo','rooftop_chat_doc_sayaka':'Spend Some Time in the Wind with Sayaka Nanjo','imaging_chat_visiting_maya':'Review Monitoring Data with Maya Ibuki','lounge_chat_visiting_maya':'Take a Break with Maya Ibuki','imaging_chat_visiting_futaba':'Discuss Psychophysiological Data with Futaba Sakura','lounge_chat_visiting_futaba':'Get Something to Eat with Futaba Sakura'}
put_many('collections.time_events',time_labels)
put('collections.cases.case_abdomen.title','First Chart: Abdominal Pain')
put('collections.cases.case_followup.title','Second Chart: Breast Mass')
put('collections.relationship_activity_placeholders.operating_room_patient_play.description','At Lv.4, each staff member may unlock an intimate event and operating-room patient roleplay through her personal story. Romance and physical intimacy are not mutually exclusive routes; roleplay does not involve real examinations, preparation, or surgery.')
put('collections.relationship_activity_placeholders.clinical_practice_patient.description','At Lv.5, each staff member may enter the examination, preoperative, and surgical workflow as an actual patient through her personal story. The specific procedure, consent process, branches, and ending remain open for later design.')

special={
'framework_single_day_test':('Framework Test · Single-Day Event','Single-Day Event Test',''),
'framework_three_day_test':('Framework Test · Three-Day Event','Three-Day Event Test',''),
'or_acceptance_training_01':('New Operating Room Opening Day','New Operating Room Opening Day','Asuka marked today on the hospital-wide schedule several days ago: acceptance inspection and team training for the new operating room. Every device, procedure, and role must be checked again before formal opening.'),
'miyama_02_manga_artist_wrong_patient':('Research Gone Too Far','Research Gone Too Far','For the first time, Miyama has invited Sakaguchi to serve as first assistant on a teaching case involving the stomach. Starting at nine, this operation will occupy the entire day.'),}
for i,(title,gallery,announcement) in special.items():
 put(f'collections.special_events.{i}.title',title); put(f'collections.special_events.{i}.gallery_entry.title',gallery)
 if announcement: put(f'collections.special_events.{i}.announcement',announcement)

condition={
'nausea.label':'Nausea','nausea.actions.treat_nausea_personally.label':'Pause, reassure her personally, and adjust her position','nausea.actions.treat_nausea_personally.response':'“...That is better. Thank you for stopping first.”','nausea.actions.delegate_nausea_assistant.label':'Ask the assistant surgeon to stabilize the patient and explain the situation','nausea.actions.delegate_nausea_assistant.response':'“I will maintain her position and explain what is happening. Slow your breathing; we will settle the nausea first.”','nausea.actions.delegate_nausea_circulating.label':'Ask the circulating nurse to prepare suction and a cool towel and reassure her','nausea.actions.delegate_nausea_circulating.response':'“Suction and a cool towel are ready. I am right here—breathe slowly, and do not force yourself to speak.”','nausea.actions.ignore_nausea.label':'Maintain the current pace and do not intervene yet','nausea.actions.ignore_nausea.response':'“Ugh... the nausea has not stopped... I cannot hold it much longer...”',
'drowsiness.label':'Drowsiness','drowsiness.actions.treat_drowsiness_personally.label':'Call to her personally and reassess consciousness and command following','drowsiness.actions.treat_drowsiness_personally.response':'“I can hear you... please keep telling me what comes next.”','drowsiness.actions.delegate_drowsiness_assistant.label':'Ask the assistant surgeon to keep calling to her and repeat instructions','drowsiness.actions.delegate_drowsiness_assistant.response':'“Look at me and stay awake. I will tell you, one sentence at a time, how far we have progressed.”','drowsiness.actions.delegate_drowsiness_circulating.label':'Ask the circulating nurse to continue observation and verbal stimulation','drowsiness.actions.delegate_drowsiness_circulating.response':'“I will keep watching her responses. Listen to my voice and slowly tell me your name and where you are.”','drowsiness.actions.ignore_drowsiness.label':'Continue the operation without interrupting the current task','drowsiness.actions.ignore_drowsiness.response':'The patient’s gaze drifts again, and she gives no answer to the last instruction.'}
for suffix,value in condition.items(): put('collections.temporary_conditions.'+suffix,value)

exam={
'blood_draw':('Blood Test','The nurse completes the blood draw and sends the sample to the laboratory.'),'abdominal_ultrasound':('Abdominal Ultrasound','The probe moves slowly as the image on the monitor changes.'),'ct_scan':('CT Scan','The table moves into the gantry and image acquisition begins.'),'mri_scan':('MRI Scan','After confirming hearing protection and positioning, the MRI scan is ready to begin.'),'endoscopy_preparation':('Endoscopy Preparation','The staff explain the procedure again and help the patient into position.'),'gynecology_preparation':('Gynecologic Examination Preparation','Before the examination begins, the doctor explains each step and confirms that the patient is ready.')}
for i,(label,caption) in exam.items(): put(f'collections.examination_cg_pools.{i}.label',label);put(f'collections.examination_cg_pools.{i}.caption',caption)
for i,value in {'breast_progress_generic':'Breast surgery proceeds under tense concentration...','thoracic_progress_generic':'The open-chest operation proceeds under tense concentration...','cardiac_progress_generic':'The cardiac operation proceeds under tense concentration...','abdominal_progress_generic':'The open abdominal operation proceeds under tense concentration...','pelvic_progress_generic':'The pelvic operation proceeds under tense concentration...'}.items(): put(f'collections.surgery_cg_pools.{i}.caption',value)
ward={'ward_enema_generic':('Ward Preparation · Enema','Following the ward preparation protocol, Dr. Sakaguchi personally completes the enema.'),'ward_skin_prep_generic':('Ward Preparation · Lower-Abdominal and Perineal Skin Preparation','She struggles to hold the position while Dr. Sakaguchi completes the lower-abdominal and perineal skin preparation.'),'ward_surgical_cap_generic':('Ward Preparation · Surgical Cap','Dr. Sakaguchi carefully gathers her hair into the surgical cap; the stretcher is already waiting beside the bed.')}
for i,(label,caption) in ward.items(): put(f'collections.ward_preparation_cg_pools.{i}.label',label);put(f'collections.ward_preparation_cg_pools.{i}.caption',caption)

# Case-pool names and investigations use stable IDs rather than source wording.
template_titles={
'template_appendicitis':'Acute Appendicitis','template_breast_tumor':'Localized Breast Mass','template_hysterectomy':'Symptomatic Uterine Fibroids','template_cabg':'Multivessel Coronary Artery Disease','template_exploratory_laparotomy':'Acute Abdomen of Uncertain Cause','template_open_cholecystectomy':'Acute Cholecystitis','template_inguinal_hernia':'Inguinal Hernia','template_ventral_hernia':'Incisional Ventral Hernia','template_distal_gastrectomy':'Malignant Antral Tumor','template_total_gastrectomy':'Proximal Gastric Malignancy','template_right_hemicolectomy':'Right-Sided Colon Cancer','template_sigmoid_colectomy':'Sigmoid Colon Malignancy','template_abdominoperineal_resection':'Low Rectal Cancer','template_whipple':'Pancreatic Head Malignancy','template_liver_resection':'Localized Hepatocellular Carcinoma','template_splenectomy':'Localized Splenic Mass','template_ovarian_cystectomy':'Symptomatic Ovarian Cyst','template_abdominal_myomectomy':'Uterine-Preserving Treatment for Symptomatic Fibroids','template_total_mastectomy':'Multifocal Breast Cancer','template_lung_lobectomy':'Localized Lung Cancer','template_pneumonectomy':'Central Lung Cancer','template_esophagectomy':'Thoracic Esophageal Cancer','template_radical_cystectomy':'Muscle-Invasive Bladder Cancer','template_nephrectomy':'Localized Renal Cell Carcinoma','template_abdominal_aortic_aneurysm':'Abdominal Aortic Aneurysm'}
test_names={'cbc':'Complete Blood Count','abdominal_ultrasound':'Abdominal Ultrasound','abdominal_ct':'Abdominal CT','mammography':'Diagnostic Mammography','breast_ultrasound':'Breast Ultrasound','core_biopsy':'Core-Needle Biopsy','pelvic_ultrasound':'Pelvic Ultrasound','pelvic_mri':'Pelvic MRI','ecg':'Electrocardiogram','echocardiogram':'Echocardiogram','coronary_angiography':'Coronary Angiography','lactate':'Serum Lactate','liver_panel':'Hepatobiliary Chemistry Panel','groin_ultrasound':'Groin Ultrasound','gastroscopy':'Upper Endoscopy','biopsy':'Endoscopic Biopsy','staging_ct':'Staging CT','fecal_occult_blood':'Fecal Occult Blood Test','colonoscopy':'Colonoscopy','rectoscopy':'Proctoscopy','pancreas_ct':'Contrast-Enhanced Pancreatic CT','endoscopic_ultrasound':'Endoscopic Ultrasound','liver_mri':'Contrast-Enhanced Liver MRI','tumor_marker':'Alpha-Fetoprotein','chest_abdomen_ct':'Chest and Abdominal CT','blood_count':'Blood Cell Count','pet_ct':'PET-CT','tumor_markers':'Gynecologic Tumor Markers','breast_mri':'Breast MRI','sentinel_node':'Axillary Lymph-Node Assessment','chest_ct':'Contrast-Enhanced Chest CT','bronchoscopy_biopsy':'Bronchoscopy and Biopsy','pulmonary_function':'Pulmonary Function Tests','urinalysis':'Urinalysis','cystoscopy':'Cystoscopy','turbt_pathology':'Transurethral Resection Pathology','renal_ct':'Contrast-Enhanced Renal CT','renal_function':'Renal Function Tests','cta':'Aortic CT Angiography'}
case_rows=json.loads((ROOT/'data/cases/surgery_case_templates.json').read_text(encoding='utf-8'))
for row in case_rows:
 rid=row['id']; put(f'collections.case_templates.{rid}.title',template_titles[rid])
 for test in row.get('tests',[]): put(f'collections.case_templates.{rid}.tests.{test["id"]}.label',test_names.get(test['id'],test['id'].replace('_',' ').title()))
put('collections.case_templates.template_exploratory_laparotomy.rare_variants.symptom_inconsistency_external_motive.description','The reported symptoms remain inconsistent with objective findings and an external motive may be present. This conclusion cannot be established from a single interview alone.')
put('collections.case_templates.template_exploratory_laparotomy.rare_variants.symptom_inconsistency_external_motive.decision_options.stop_and_reassess.label','Stop the operation and reassess')
put('collections.case_templates.template_exploratory_laparotomy.rare_variants.symptom_inconsistency_external_motive.decision_options.explain_and_confirm.label','Explain the indication, confirm consent, and continue')
put('collections.case_templates.template_exploratory_laparotomy.rare_variants.symptom_inconsistency_external_motive.decision_options.frighten_with_worst_case.label','Use the worst-case outcome to pressure her into continuing')

# Surgical flow has the same four-stage grammar for every procedure. Translate
# each stable stage and option while retaining the localized procedure name.
surgeries=json.loads((ROOT/'data/surgeries/surgeries.json').read_text(encoding='utf-8'))
for surgery in surgeries:
 sid=surgery['id']; base=f'collections.surgeries.{sid}'; proc=strings.get(base+'.name',surgery['name'])
 for stage in surgery.get('stages',[]):
  stid=stage['id']; sp=f'{base}.stages.{stid}'
  titles={'exposure':'Operative Field Confirmation','team_exchange':'Team Coordination','key_decision':'Key Decision','completion_check':'Stage Complete'}
  prompts={'exposure':f'The operative field for {proc} has been exposed. Confirm the target anatomy and the planned field.', 'team_exchange':'Before the critical step begins, how will Dr. Sakaguchi confirm the team’s pace?', 'key_decision':f'Before the key step of {proc}, which confirmation takes priority?', 'completion_check':f'The key step of {proc} is complete and the field has been reviewed. The team awaits Dr. Sakaguchi’s final confirmation.'}
  put(sp+'.title',titles.get(stid,stid.replace('_',' ').title())); put(sp+'.prompt',prompts.get(stid,'Confirm the current surgical stage.'))
  for option in stage.get('options',[]):
   oid=option['id']; op=f'{sp}.options.{oid}'
   labels={'confirm_exposure':'Confirm the field and continue','ask_assistant':'Ask the assistant to restate the current progress','check_instruments':'Confirm instrument readiness','check_monitoring':'Confirm monitoring and documentation','confirm_anatomy':'Confirm the target anatomy and adjacent structures','rush_by_appearance':'Proceed on an incomplete visual impression','delegate_decision':'Leave the surgical decision to another role','confirm_completion':'Confirm completion of the key step'}
   responses={'confirm_exposure':'“The field is clear. The target anatomy and operative plan are confirmed; we can continue.”','ask_assistant':'“The target anatomy and operative plan are confirmed. I will maintain exposure and call out each critical point.”','check_instruments':'“The instruments for the next stage are arranged in order and the count is correct.”','check_monitoring':'“The monitoring trend is stable. Intake, output, and all critical times have been recorded.”','confirm_anatomy':'“Confirmed. The key anatomy and next step match the preoperative plan.”','confirm_completion':'“Review complete. Nothing has been missed; we can prepare to close.”'}
   put(op+'.label',labels.get(oid,'Confirm the planned step'))
   if option.get('response'): put(op+'.response',responses.get(oid,'“Confirmed. We can continue according to plan.”'))
   if option.get('correction'):
    correction='“Pause. That rationale is not sufficient for the next step; confirm the target anatomy and operative plan together first.”' if '依据不足' in option['correction'] else '“The lead surgeon must make that decision from the operative field. Verify the anatomy and surgical plan first.”'
    put(op+'.correction',correction)

# First-role CG rewards: exact role titles plus concise character-specific captions.
role_titles={'assistant_surgeon':'Assistant Surgeon · First Assignment','scrub_nurse':'Scrub Nurse · First Assignment','circulating_nurse':'Circulating Nurse · First Assignment','ward_nurse':'Preoperative Ward Care · First Assignment'}
role_captions={'assistant_surgeon':'She confirms her position and enters the assistant’s side of the field, ready to match the lead surgeon’s rhythm.','scrub_nurse':'She completes the count, arranges the instruments, and takes her place at the sterile table.','circulating_nurse':'She checks monitoring, records, and supplies, keeping firm control of everything beyond the sterile field.','ward_nurse':'She prepares the bed, clothing, and transport supplies, then waits for the patient to arrive.'}
rows=json.loads((ROOT/'data/events/staff_role_cg_rewards.json').read_text(encoding='utf-8'))
for row in rows:
 rid=row['id']; role=row['role_id']; put(f'collections.staff_role_cg_rewards.{rid}.title',role_titles[role]); put(f'collections.staff_role_cg_rewards.{rid}.caption',role_captions[role])



# Day-one staff introductions shown immediately after the prologue.
day_one_events={
'intro_doc_rei':{
 'title':'Meet Kaori Miyama in the Examination Room','teaser':'Kaori Miyama looks up from the test results.','gallery.caption':'Meet Kaori Miyama in the Examination Room',
 'nodes.opening.text':'Kaori Miyama looks up from the test results and studies Sakaguchi from his name badge to his face.\n“New here?”\nShe drops the report onto the desk.\n“Just so we are clear, the emergency department has no time to wait while you arrange every word.”',
 'nodes.opening.choices.formal.label':'Introduce yourself formally','nodes.opening.choices.plain.label':'State your purpose briefly',
 'nodes.reply_0.text':'“Kaori Miyama, Emergency Medicine.”\nHer handshake is quick, and so is her release.\n“If you are uncertain, give me all the facts first. Do not test my patience with ‘I think.’”','nodes.reply_0.choices.end_0.label':'End the conversation',
 'nodes.reply_1.text':'“Fine. At least you know how to get to the point.”\nShe picks the report up again.\n“Things move fast here. When something actually happens, call me directly. Do not stand outside the door being polite three times.”','nodes.reply_1.choices.end_1.label':'End the conversation'},
'intro_nurse_rin':{
 'title':"Meet Mika Nakai at the Nurses' Station",'teaser':'Mika Nakai sets down the handoff sheet and nods to Sakaguchi.','gallery.caption':"Meet Mika Nakai at the Nurses' Station",
 'nodes.opening.text':'Mika Nakai sets down the handoff sheet and looks Sakaguchi over.\n“A new doctor?”\nHer smile is impeccably professional.\n“I hope you are the kind who reads handoffs, not the kind who reads only lab values.”','nodes.opening.choices.ward.label':'Ask about ward work','nodes.opening.choices.greet.label':'Make a point of remembering her name',
 'nodes.reply_0.text':'“What the ward notices first usually is not a ‘major problem.’ It is the little thing that simply feels wrong.”\nShe taps the handoff sheet.\n“If you are willing to listen, I am willing to tell you.”','nodes.reply_0.choices.end_0.label':'End the conversation',
 'nodes.reply_1.text':'“Remembering names matters.”\nShe smiles.\n“But if you are still calling me ‘Nurse Nakai’ in two days, I may start wondering whether you are deliberately keeping your distance.”','nodes.reply_1.choices.end_1.label':'End the conversation'},
'intro_nurse_yui':{
 'title':"Meet Miyuki Asakura at the Nurses' Station",'teaser':'New to Hoshimi, Miyuki Asakura arrives at the station with carefully organized workflow notes.','gallery.caption':"Meet Miyuki Asakura at the Nurses' Station",
 'nodes.opening.text':'Miyuki Asakura approaches quickly with a clipboard and stops neatly in front of Sakaguchi.\n“Hello, I am Miyuki Asakura. Starting today, I will mainly support the outpatient clinic.”\nShe straightens her badge and smiles.\n“This is not my first day in nursing, but it is my first at Hoshimi. I will verify every procedure from the beginning.”','nodes.opening.choices.friendly.label':'Respond warmly','nodes.opening.choices.work.label':'Ask about today’s clinic schedule',
 'nodes.reply_0.text':'“Thank you. I should warn you that I may ask for very fine details—equipment models, handoff order, departmental habits.”\nShe taps the clipboard lightly.\n“It is not that I cannot do the work. I do not want to let habits from my last hospital make decisions for Hoshimi. After all, I am the newcomer here.”','nodes.reply_0.choices.end_0.label':'End the conversation',
 'nodes.reply_1.text':'She immediately opens the clipboard to a page she has already tabbed.\n“Today’s list, last-minute changes, and the emergency contact order are all here. There are two places where I still want to confirm Hoshimi’s notation.”\nHer fingertip rests on the handoff column.\n“You do not need to worry about basic nursing or patient transport. What I need to learn is how this hospital connects each piece of work.”','nodes.reply_1.choices.end_1.label':'End the conversation'},
}
for event_id, entries in day_one_events.items():
 for suffix,value in entries.items(): put(f'collections.character_events.{event_id}.{suffix}',value)


# Sayaka's complete acquaintance and Lv.1 chain.
sayaka_events={
'sayaka_week1_phone_exchange':{
 'title':'Give Me Your Number','teaser':'After delivering the papers, Sayaka takes two steps toward the door—then stops.','gallery.caption':'Give Me Your Number',
 'nodes.work_done.text':'Sayaka reaches the office door with the consultation form.\n\n“Here. What you asked for.”\n\nSakaguchi takes it. “Thanks.”\n\nShe taps the last page with her pen.\n\n“Do not thank me yet. Sign here.”\n\n“You sound like a debt collector.”\n\nShe laughs. “Then pay up.”','nodes.work_done.choices.phone_turn.label':'Sign it and hand it back',
 'nodes.does_not_leave.text':'Once Sakaguchi signs, she checks it, takes two steps away, then comes back.\n\n“Right. Give me your phone.”\n\n“My phone?”\n\nShe holds out her hand.\n\n“Your number.”\n\n“I have no use for the phone itself.”','nodes.does_not_leave.choices.phone_direct.label':'For work?',
 'nodes.direct_reply.text':'She looks down and opens his contacts.\n\n“Half for work.”\n\n“And the other half?”\n\nShe looks up at him.\n\n“I will tell you later.”\n\nSakaguchi reads out his number.','nodes.direct_reply.choices.exchange_number.label':'Wait while she enters the number',
 'nodes.saved_name.text':'A few seconds later, Sakaguchi’s phone vibrates.\n\nSayaka Nanjo: This is Nanjo.\n\n“I know.”\n\n“Your contacts do not.”\n\nShe leans closer to see him save the entry.\n\n“Hey, wait. You are not actually saving me as ‘Dr. Nanjo,’ are you?”\n\n“That looks like a hospital mailing list.”\n\n“What should I use, then?”\n\n“Sayaka,” she blurts out.\n\nTheir eyes meet. She looks slightly away first and laughs at herself.\n\n“...Do not really change it yet. We are not that close.”','nodes.saved_name.choices.phone_tail_a.label':'You get embarrassed too?','nodes.saved_name.choices.phone_tail_b.label':'So I can contact you only for work?','nodes.saved_name.choices.phone_tail_c.label':'Can I message you at two in the morning?',
 'nodes.tail_a.text':'She looks straight back at him.\n\n“Give me a break.”\n\nShe slips the phone into her coat pocket.\n\n“Do not send anything strange in the middle of the night.”\n\n“What counts as strange?”\n\nAt the door, she turns back.\n\n“Send it first. I will judge.”','nodes.tail_a.choices.phone_end_a.label':'Save her number',
 'nodes.tail_b.text':'She blinks once.\n\n“I did not say that.”\n\n“If you want to know whether you can contact me outside work—why not try it?”\n\nShe is the first to laugh.','nodes.tail_b.choices.phone_end_b.label':'Save the contact',
 'nodes.tail_c.text':'“Do not send boring messages at two in the morning.”\n\n“What counts as boring?”\n\nShe looks at him.\n\n“Send it first. I will decide after I receive it.”','nodes.tail_c.choices.phone_end_c.label':'Put the phone away'},
'sayaka_lv1_first_date':{
 'title':'So, Does This Count as a Date?','teaser':'On his first Sunday, Sakaguchi sends Sayaka a message.','gallery.caption':'So, Does This Count as a Date?','location_label':'Italian Trattoria',
 'nodes.invite.text':'Sunday.\n\nSakaguchi: Free today? Want to get dinner?\n\nHer answer comes quickly.\n\nSayaka: Sure.\n\nA few seconds later, another message arrives.\n\nSayaka: Huh, you picked me on your very first Sunday?\n\nSakaguchi: It is just dinner.\n\nSayaka: “Just” is the most suspicious word in that sentence.\n\nSayaka: Fine. Send me the address.','nodes.invite.choices.go_trattoria.label':'Go to the Italian restaurant you arranged',
 'nodes.arrival.text':'Sayaka is already waiting outside when Sakaguchi arrives.\n\n“You got here before me.”\n\nShe checks her phone.\n\n“By two minutes. Do not make it sound as though I have been waiting here like a devoted wife.”\n\nShe looks through the window at the warm lights and small tables for two.\n\n“You chose well.”\n\n“How so?”\n\nShe points inside.\n\n“This place makes misunderstandings very easy.”\n\n“What misunderstanding?”\n\nHer smile is effortless.\n\n“That you asked me on a date.”','nodes.arrival.choices.sit_down.label':'Go inside and sit down',
 'nodes.outside_coat.text':'She opens the menu.\n\n“It is refreshing to see you outside the hospital.”\n\n“What is different?”\n\nShe studies him seriously for two seconds.\n\n“No white coat.”\n\n“You are not wearing one either.”\n\nShe glances down at her clothes.\n\n“Disappointed?”','nodes.outside_coat.choices.outfit_miss_coat.label':'A little','nodes.outside_coat.choices.outfit_pretty.label':'You look good like this too','nodes.outside_coat.choices.outfit_same.label':'I am still adjusting',
 'nodes.coat_reply.text':'She raises an eyebrow.\n\n“Oh?”\n\n“The white coat suits you.”\n\nHer mouth curves upward.\n\n“You only noticed now?”\n\n“Your powers of observation need work, Dr. Sakaguchi.”','nodes.coat_reply.choices.coat_continue.label':'Talk about the weekend',
 'nodes.pretty_reply.text':'She is about to return to the menu when her hand stops.\n\n“...Why are you so sweet today?”\n\n“It is the truth.”\n\nShe glances at him and lowers her eyes again.\n\n“Fine. You win this one.”','nodes.pretty_reply.choices.pretty_continue.label':'Talk about the weekend',
 'nodes.same_reply.text':'She laughs.\n\n“Take your time. There will be other chances.”\n\nShe realizes how suggestive that sounded and presses her lips together.\n\n“...I meant Sundays.”\n\n“I did not say anything.”\n\nShe glares at him.\n\n“Quiet.”','nodes.same_reply.choices.same_continue.label':'Talk about the weekend',
 'nodes.men_too_few.text':'“Is this how you usually spend weekends?”\n\n“Dinner, shopping, a drink.”\n\nShe spears a small bite of food.\n\n“If a man asks me out, it depends on the man.”\n\n“That direct?”\n\n“Why pretend I do not like men?”\n\nShe looks at him.\n\n“But I do not come out for everyone who asks.”\n\n“So I passed the screening today?”\n\nShe smiles.\n\n“So far.”','nodes.men_too_few.choices.like_men.label':'So I passed the screening?',
 'nodes.added_value.text':'She smiles.\n\n“So far.”','nodes.added_value.choices.meal_nearly_done.label':'Finish dinner',
 'nodes.what_is_this.text':'As dinner nears its end, she turns her glass with one fingertip and suddenly looks up.\n\n“Let me ask you something.”\n\n“Mm?”\n\nShe does not circle around it.\n\n“This thing today—”\n\n“Does it count as a date?”','nodes.what_is_this.choices.date_direct.label':'Of course it does','nodes.what_is_this.choices.date_tease.label':'Do you want it to?','nodes.what_is_this.choices.date_only_meal.label':'It is just dinner',
 'nodes.direct_date_reply.text':'She visibly freezes for half a beat.\n\n“...That direct?”\n\n“What else would it be?”\n\nShe smiles.\n\n“Fine. I like that answer.”','nodes.direct_date_reply.choices.direct_to_bill.label':'Wait for the check',
 'nodes.teasing_date_reply.text':'She barely hesitates.\n\n“I do.”\n\nThen Sakaguchi’s gaze makes her slightly self-conscious.\n\n“What?”\n\n“You answered quickly.”\n\nShe clears her throat.\n\n“I already came out with you. Why pretend?”\n\n“So what about you?”\n\n“Then today counts.”\n\nShe nods.\n\n“Good.”','nodes.teasing_date_reply.choices.tease_to_bill.label':'Wait for the check',
 'nodes.only_meal_reply.text':'“Oh.”\n\nShe calmly eats the final bite and looks up.\n\n“Then I will try harder next time.”\n\n“Try harder at what?”\n\nShe smiles.\n\n“Making it feel more like a date.”','nodes.only_meal_reply.choices.only_meal_end.label':'Finish the meal',
 'nodes.bill.text':'The server sets down the check. Sakaguchi reaches for it, but Sayaka already has her card out.\n\n“We split it.”\n\n“I will pay.”\n\nShe shakes her head.\n\n“No.”\n\nBefore he can speak, she raises a hand.\n\n“Hey, do not invent a whole story.”\n\n“I am not drawing a line or saying we are ‘just friends.’”\n\nShe puts her card on the table.\n\n“This is simply how I date.”','nodes.bill.choices.ask_aa.label':'A principle?',
 'nodes.aa_reply.text':'She nods.\n\n“Mm.”\n\nAfter a pause, she winks at Sakaguchi.\n\n“We each pay our own money.”\n\n“As for anything else... we can discuss it later.”\n\n“Did you do that on purpose?”\n\nHer delighted smile answers first.\n\n“Of course.”','nodes.aa_reply.choices.leave_restaurant.label':'Walk together after dinner',
 'nodes.walk_home.text':'After dinner, they walk together for a while. Before they part, Sayaka stops.\n\n“Today was nice.”\n\n“Only nice?”\n\nShe looks at him. “What score were you hoping for?”\n\n“At least another time?”\n\nAt last, her smile turns almost sweet.\n\n“Of course. Why else would I have said ‘later’?”\n\nShe takes two steps, then looks back.\n\n“You ask me again next time.”\n\n“Why?”\n\nShe thinks about it.\n\n“Because being asked by someone I like feels pretty good.”\n\nShe grows a little embarrassed the instant she says it and quickly adds:\n\n“All right, do not get smug.”','nodes.walk_home.choices.date_success_end.label':'Say goodbye'},
'sayaka_lv1_monday_callback':{
 'title':'After the White Coat Goes Back On','teaser':'On the first workday after their date, Sayaka stops Sakaguchi in the corridor.','gallery.caption':'After the White Coat Goes Back On',
 'nodes.morning.text':'The first workday after their date.\n\nThey greet each other in the corridor as usual.\n\n“Morning.”\n\n“Morning.”\n\nAfter they pass, Sayaka suddenly steps back.\n\n“Hey.”','nodes.morning.choices.callback_ask.label':'What is it?',
 'nodes.callback_reply.text':'She looks Sakaguchi over.\n\n“So you can still look at me.”\n\n“Why would I not?”\n\nShe laughs.\n\n“Nothing. Some men know exactly what to say on the weekend, then put on a white coat Monday morning and pretend they have never met you.”\n\n“So I pass?”\n\nShe nods once.\n\n“So far.”\n\nThen she turns and goes back to work.','nodes.callback_reply.choices.callback_end.label':'Start today’s work'},
}
for event_id, entries in sayaka_events.items():
 for suffix,value in entries.items(): put(f'collections.character_events.{event_id}.{suffix}',value)

# Awake-surgery patient prompts. Prompts retain each clinical context; action
# labels are derived from stable intent IDs so newly edited Chinese wording does
# not silently detach the English branch.
interaction_prompts={
'contact_pain_incision_01':'“Doctor... I felt that just now. Has the operation started?”',
'contact_default_01':'“Doctor... has the operation already started?”',
'progress_fear_default_01':'“Doctor... how far along are you? Has something gone wrong?”',
'progress_default_01':'“Doctor, about how far along are we now?”',
'strain_pain_default_01':'“Wait... that felt awful inside, as though something were pulling on me.”',
'strain_default_01':'“Doctor... I just felt something pulling inside. What was that?”',
'dignity_low_exposure_01':'“I know this is surgery... but being left exposed like this is still very difficult.”',
'dignity_default_01':'“Doctor... does this area really need to stay exposed the whole time?”',
'ongoing_fear_default_01':'“Doctor, everyone suddenly went quiet... is everything still going well?”',
'ongoing_default_01':'“Doctor... I am still listening. Is there anything you need me to do?”',
'closure_default_01':'“Doctor... are we nearly finished?”',
'abdominal_strain_pain_01':'“Doctor... it felt as though something pulled inside my abdomen. What are you working on now?”',
'pelvic_dignity_exposure_01':'“Doctor... are you operating in my pelvis now? I know this is surgery, but I still feel embarrassed.”',
'pelvic_dignity_default_01':'“Doctor... have you reached the pelvic part of the operation?”',
'breast_dignity_exposure_01':'“Does it have to remain exposed like this? The area being removed has not grown larger, has it?”',
'breast_dignity_default_01':'“Doctor... are you working on the planned breast excision now?”',
'cardiac_progress_fear_01':'“Doctor... have you reached my heart now? Why did everyone suddenly go quiet?”',
'cardiac_progress_default_01':'“Doctor... have you reached the cardiac part of the operation?”',
'contact_pain_incision_02':'“Ah... I can feel the incision clearly. Doctor, are you still listening to me?”',
'contact_fear_incision_01':'“Did you really make the incision? Not being able to see makes it even more frightening...”',
'progress_fear_fatigue_01':'“Has it been a long time? Why is it not over... is this more complicated than expected?”',
'progress_fear_fatigue_02':'“Doctor, I am losing all sense of time... how far are we from the end?”',
'strain_pain_traction_02':'“Something pulled inside again... this time the ache is deeper than before.”',
'strain_pain_pressure_01':'“There has been pressure here the whole time... it is not a sharp pain, but it keeps getting worse.”',
'dignity_low_exposure_02':'“I know this is surgery, but being exposed like this for so long... it is still very difficult.”',
'dignity_cooperation_exposure_01':'“I will cooperate... but could everyone please stop looking at me the whole time?”',
'ongoing_fear_fatigue_01':'“Doctor, when all of you go quiet, my thoughts run away from me... is the operation still going well?”',
'ongoing_fear_fatigue_02':'“I do not think I can bear this long silence much longer... can you tell me what comes next?”',
'ongoing_pain_position_01':'“This position hurts more and more; my shoulders and back are stiff... may I move a little?”',
'closure_fear_closure_01':'“Are you suturing now? Does that mean it is really almost over?”',
'closure_fear_closure_02':'“Do not suddenly stop talking... tell me, have you finished the work inside?”',
'closure_pain_closure_01':'“I can feel the pulling even while you suture... how much longer?”',
'abdominal_ongoing_pressure_01':'“There is a heavy pressure deep in my abdomen... are you working somewhere very deep now?”',
'pelvic_ongoing_position_01':'“My back and legs have held this position too long... I am afraid I will suddenly tense up.”',
'breast_closure_fear_01':'“Are you already closing... what will I look like when I wake up?”',
'urologic_strain_pressure_01':'“My flank feels swollen and pulled from inside... it is hard not to tense up.”',
'thoracic_progress_fatigue_01':'“My chest has been fixed in place and I am getting so tired... are we past the hardest part?”',
'thoracic_ongoing_position_01':'“My shoulder and back are going numb in this position... I do not dare move, but it really hurts.”',
'cardiac_ongoing_fatigue_01':'“I know you are working on my heart... the quieter it gets, the harder it is to control my fear.”',
'vascular_progress_deep_01':'“The feeling deep in my abdomen suddenly changed... have you reached the blood vessel?”',
'vascular_ongoing_pressure_01':'“The pressure inside has not let up... I cannot tell whether this is pain or fear anymore.”',
'hysterectomy_signature_01':'“Doctor... confirm it once more. Is the area you are treating exactly what you promised before surgery?”',
'ovarian_cystectomy_signature_01':'“You are still preserving as much normal tissue as possible, right? I have been worried about that.”',
'myomectomy_signature_01':'“You are still treating only the fibroids, right? You will not change the operation without telling me?”',
'breast_tumor_signature_01':'“The area being removed is still the one you marked for me before surgery, right?”',
'mastectomy_signature_01':'“I know I consented... but now that it is happening, it still feels as though I am losing part of my body.”',
'cabg_signature_01':'“Are you creating the new path for blood flow now? I heard you mention the anastomosis...”',
}
phrase_overrides={
'explain':'Explain','brief':'Give a brief update about','confirm':'Confirm','reassure':'Reassure her about','answer':'Explain','ask':'Ask','check':'Check','continue':'Continue and ask for','silent':'Ask quietly for','dismiss':'Dismiss her concern and demand','pause':'Pause to address','coach':'Guide her through','push_through':'Ask her to endure','restore':'Restore','protect':'Protect','ignore':'Ignore','maintain':'Maintain','mark':'Give her','encourage':'Encourage her about','relieve':'Pause and relieve','reduce':'Reduce','acknowledge':'Acknowledge','limit':'Limit','preview':'Explain','adjust':'Adjust','pace':'Match','support':'Recheck support for','separate':'Help distinguish','orient':'Orient her to','steady':'Steady her with','reduce_exposure_again':'Restore the drapes over nonessential areas','acknowledge_exposure_again':'Acknowledge her discomfort and explain the necessary field','brief_privacy_confirmation':'Confirm that the team is focused only on the necessary field','limit_observers':'Confirm that only essential staff and exposure remain'}
def intent_label(action_id:str)->str:
 words=action_id.split('_')
 # Stable IDs are written as concise English intents; make them readable and
 # then smooth the most common clinical verbs.
 raw=' '.join(words)
 for source,target in sorted(phrase_overrides.items(), key=lambda item:-len(item[0])):
  if raw.startswith(source.replace('_',' ')):
   tail=raw[len(source.replace('_',' ')):].strip().replace('ongoing','current progress').replace('strain','traction discomfort').replace('closure','closure phase').replace('scope','operative scope').replace('milestone','milestone').replace('contact','the start of surgery')
   return (target + (' '+tail if tail else '')).strip()[0].upper()+(target + (' '+tail if tail else '')).strip()[1:]
 return raw.capitalize()
interactions=json.loads((ROOT/'data/surgeries/patient_interactions.json').read_text(encoding='utf-8'))
for row in interactions:
 rid=row['id']; base=f'collections.patient_interactions.{rid}'
 put(base+'.prompt',interaction_prompts[rid])
 for action in row.get('actions',[]):
  aid=action['id']; ap=f'{base}.actions.{aid}'
  put(ap+'.label',intent_label(aid))
  effects=action.get('effects',{})
  harmful=int(effects.get('fear',0))>0 or int(effects.get('dignity',0))<0 or int(effects.get('cooperation',0))<0
  strongly_helpful=int(effects.get('fear',0))<=-8 or int(effects.get('dignity',0))>=8 or int(effects.get('pain',0))<=-8
  response='“...All right. I will try not to move.”' if harmful else ('“Thank you for explaining. I feel better, and I will keep cooperating.”' if strongly_helpful else '“I understand... please continue.”')
  put(ap+'.response',response)

# Developer-only framework event text is localized too, so English test runs do
# not unexpectedly fall back while exercising the scheduler.
framework_steps={
'framework_single_day_main':('Single-Day Event Test',{'opening':('This is a single-day activity used to verify the generic special-event framework.',{'continue':'Continue'}),'closing':("The event's main sequence is complete, and today's schedule ends with it.",{'finish':'End the day'})}),
'framework_three_day_1':('Three-Day Event Test · Day One',{'main':('Day one: preparation.',{'day_1_done':'Complete day one'})}),
'framework_three_day_2':('Three-Day Event Test · Day Two',{'main':('Day two: main activity.',{'day_2_done':'Complete day two'})}),
'framework_three_day_3':('Three-Day Event Test · Day Three',{'main':('Day three: wrap-up.',{'day_3_done':'Complete day three'})}),}
for step_id,(title,nodes) in framework_steps.items():
 base=f'collections.special_event_steps.{step_id}'; put(base+'.title',title)
 for node_id,(text,choices) in nodes.items():
  put(f'{base}.nodes.{node_id}.text',text)
  for choice_id,label in choices.items(): put(f'{base}.nodes.{node_id}.choices.{choice_id}.label',label)


locale['strings']=dict(sorted(strings.items()))
EN_PATH.write_text(json.dumps(locale,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'Wrote {len(strings)} English strings to {EN_PATH.relative_to(ROOT)}')
