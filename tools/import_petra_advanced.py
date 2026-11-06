#!/usr/bin/env python3
"""Build Petra's advanced procedure from the preserved, verbatim Chinese design."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data/advanced_surgery"
SOURCE = ROOT / "docs/source_materials/petra/HOSHIMI_ADVANCED_PETRA_THORACOLUMBAR_KYPHOSIS_DESIGN_V1.md"
ID = "surgery_adv_posttraumatic_thoracolumbar_kyphosis_correction"
raw = SOURCE.read_text()


def read(path):
    return json.loads(path.read_text())


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n")


def lines(block):
    return [line.strip() for line in block.strip().splitlines() if line.strip()]


DAY1_EN = lines("""
In the advanced referral clinic, Petra places a stack of imaging reports on the desk and pulls out the top sheet. She rises steadily, only briefly touching the chair back before sitting again.
“Ms. Petra. This visit isn't about the prosthetics themselves, is it?”
“No. They've already helped me a great deal. I just don't want to stop every time I've walked a while because my back hurts.”
“This is an old fracture in the thoracolumbar spine from several years ago. It healed, but left a fixed kyphotic angle near the twelfth thoracic vertebra.”
“Back then everyone was busy getting me out of the rubble. Honestly, I never thought another part of me would start complaining years later.”
“The alignment around the fracture changed. To stay balanced, you now have to keep compensating with other muscles. The images and symptoms show that it's affecting daily life.”
“I know. Standing for a while is fine, but walking far hurts. I used to tell myself that being able to walk again was already enough.”
“We can discuss corrective surgery. The goal isn't a prettier X-ray; it's to improve pain and trunk stability.”
“How extensive would the surgery be?”
“It needs a fairly long incision along your back and exposure across several thoracolumbar levels. We'll place fixation screws first, protect the nerves, then remove part of the severely deformed vertebral structure.”
“...Wait. You mean actually cut out part of a vertebra?”
“Yes. A fusion device and rods will rebuild the missing support. We won't force your back straight; we'll correct it through bone resection and gradual realignment.”
“I thought I'd already been through the most troublesome treatment. Apparently there's another item on the list.”
“The greatest risks are during vertebral resection, nerve protection, and final correction. We'll assign two surgical assistants, expand the instrument and circulating teams, and monitor nerve function throughout.”
“You're really going to put all of that into my back while I'm asleep?”
“You'll have general anesthesia throughout. You won't need to cooperate while awake. After you wake, we'll assess nerve function and the wound step by step.”
“That sounds more complicated than replacing parts on a mobile suit. ...Sorry, that might be a bad comparison.”
“There's a little resemblance. But human nerves and blood supply demand particular care.”
“I thought you'd say there was no resemblance at all.”
Petra manages a faint smile and turns back to the first page of the imaging report.
“What happens if I don't have it?”
“This isn't an emergency, but endurance alone won't correct the pain or imbalance. We can weigh continued conservative treatment against surgery using your symptoms and imaging.”
“...Then let's do it. When I travel again, I want to think about where I'm going, not how much farther I have to walk.”
“I'll go through the procedure and risks with you again, item by item. Sign the consent form after you've heard them.”
“All right. But once you've set a date, I need to tell Lauda first.”
“Will he come with you?”
“He will. He's probably more nervous than I am. This time I'd at least like to keep him from pacing the corridor all day.”
Petra studies the long name of the operation on the consent form, listens carefully to the additional explanation, confirms it, and signs.
“All right. The rest is in your hands.”
The scene shifts to this case's specialty risk notice and Grand OR team assignment. Day 2 has not begun, and no intraoperative story is inserted here.
""")

DAY3_EN = lines("""
In the ward, Petra opens her eyes, looks at the ceiling, then searches for familiar things at her bedside.
“...Is it over?”
“It's over. The correction and fixation are complete. We still need to watch your nerve function, wound, and recovery.”
“Such a big operation, and I don't know a thing about what happened during it.”
“That's general anesthesia. For you it feels like waking from sleep; the surgical team has already worked through the morning and afternoon.”
“That doesn't sound fair. You all worked the whole day, and my job was just to sleep.”
“You still have rehabilitation ahead. We can't do that part for you.”
“...Right. I have plenty of experience with that.”
She starts to change position, then stops. Sakaguchi reminds her not to twist on her own yet and adjusts the cushions.
“I know I shouldn't move around right after surgery. I just wanted to make sure my body was really here when I woke up.”
“The early checks are encouraging. But recovery will take time to assess; we can't draw a final conclusion today.”
“Mm. You've done the hardest part. I'll practice properly from here on.”
“Lauda is waiting for news. He can come in when the ward allows visitors.”
“...Please tell him I'm awake first. Otherwise he'll pace the corridor until he wears a hole in the floor.”
Petra glances down at the blanket covering her and smiles, tired but relieved.
“When I can really walk a long way, I'll stop counting the hospital as a travel destination.”
Proceed to the existing Advanced Surgery Day 3 success results.
""")

# Ordered by stage; each pair is before_action followed by after_resolution.
TEAM_EN = [block.split("|") for block in """
The thoracolumbar markings and images match. Let's confirm positioning and pressure points first.|General anesthesia is established. I'm rechecking the monitoring baseline in the remaining muscle groups and will report during repositioning.|The chest and abdominal supports are correctly placed. We can prepare the operative site.|The imaging equipment, spare supports, and implant list have all been checked.
The bony landmarks have shifted around the old fracture. Reconfirm localization at every level we expose.|Cautery, periosteal elevator, and deep retractors.|Both paraspinal muscle groups are retracted as planned. We still need to protect the segmental vessels on the right.|The navigation screen is positioned; call for more imaging whenever you need it.
The pedicle angles here aren't entirely normal. Confirm the entry point before the probe goes anywhere near the canal.|Pedicle probe and ball-tip probe. The next screw size is on the right sterile table.|I'll keep the lateral exposure steady. We also need to verify the adjacent anchors one by one.|The spare screws and locking caps have been counted. We can switch to decompression instruments next.
Before osteotomy, we need to see the constraints around the nerves. This is also the time to settle the temporary fixation plan.|There's enough room on the left; if we widen exposure, recheck traction on the other side.|Proceed with the chosen alternating-side sequence. Before exchanging fixation, confirm the other side is still bearing load.|Temporary rod, rod holder, and locking caps are ready.
The old scar is tightly attached. Find a real dissection plane before advancing.|Kerrison rongeur and fine neural dissector.|I'll move the suction tip outside the bone surface so it doesn't touch the dura.|Neuromonitoring will continue. Tell me before the next traction or osteotomy step.
Before we actually remove the vertebral body, the remaining spine must always have reliable fixation on one side.|The temporary rod length and locking parts are checked; a spare size is close by.|I'll hold the opposite anchor. I won't release this support during the next step.|The newly used implant specifications are recorded, and a spare rod has been brought into the room.
Work inside the diseased vertebral body first. Leave the posterior wall by the dura until exposure is sufficient for separation.|High-speed drill and rongeur. Hemostatic materials are at hand.|The temporary support remains in place. Recheck by the posterior wall for loose bone fragments.|I'll watch bleeding and perfusion closely during this step. Call me if anything needs adjusting.
We have space from the resection, but correction doesn't mean pulling the two ends together with force.|Recheck the upper and lower endplates. Anterior support height will determine whether the rods seat properly.|Restore alignment in stages toward the agreed target. Establish support first, then work on the posterior connection.|The alternative cage sizes and bone graft are on the sterile table.
See the support surface clearly. The cage must not press onto an unreliable endplate edge.|Cage inserter, trials, and prepared bone graft.|I'll keep the neural side protected. Check again that the device isn't touching tissue it shouldn't.|The backup sizes are checked; implant identifiers will go into the operation record.
Seat the rod in the anchors one segment at a time. After each small correction, check the nerves and fixation.|Rod holder, reducer, and locking caps. The next length is ready too.|We need to rebalance tension on both sides, not just look at the midline.|I'm reviewing the neuromonitoring after correction. I'll report any change at once.
Finally, recheck every anchor, rod, and space around the nerves; don't judge only by the corrected shape.|Torque-limiting driver, bone graft, and irrigation.|Both fusion beds are prepared. Check every possible bleeding point once more before closure.|The actual implant models and counts are recorded. We're preparing the final sponge and instrument count.
Recheck deep hemostasis and drain position. Let's close this back incision safely.|Closure sutures, subcutaneous instruments, and final count sheet are ready.|Instruments, needles, and sponges have been reconciled, and the postoperative handoff is ready.|I'll arrange repositioning and recovery monitoring. The priorities for neurological assessment have been handed over.
""".strip().splitlines()]

FAIL_EN = lines("""
The channel direction isn't reliable. Don't force it. Recheck the medial pedicle boundary.
Here's the spare probe. Hold the screw for now.
The dural edge has been pulled. Ease the retractor and find the plane again.
Don't dissect this part blindly. Identify the lateral side of the nerve again.
The posterior wall hasn't been cleared well enough. Secure temporary stability before refining the bone edge.
I've switched to hemostatic materials and a finer rongeur.
The cage contact surface isn't right. Back it out a little; don't force it in.
The endplate load is uneven. Recheck the size and angle.
Tension rose too quickly on that step. Pause correction and check monitoring.
I'm checking whether the change comes from blood pressure, anesthesia, or a real nerve signal.
This anchor failed its check. It needs correction before closure.
The spare locking part and torque limiter are here.
""")

CRISIS_EN = {
    "T07": lines("""
Suction has increased sharply. I'll fully expose the bleeding point first.
Bipolar cautery, electrocautery, and hemostatic materials.
I'm managing the circulatory change. Hold this step steady for now.
"""),
    "T10": lines("""
Monitoring shows a change that needs review. Pause further correction.
Maintain the current support. Check whether traction or bony pressure caused it.
I'll keep the field exposed until the monitoring team confirms the findings.
"""),
}

STAGE_NAMES = [
    ("T01", "全麻俯卧定位与神经监测基线", "Prone Positioning and Neuromonitoring Baseline", "F", 35, 2, 0, 0),
    ("T02", "胸腰段后路暴露", "Posterior Thoracolumbar Exposure", "L", 50, 3, 0, 0),
    ("T03", "椎弓根螺钉锚点建立", "Pedicle Screw Anchor Placement", "P", 55, 4, 86, 7),
    ("T04", "截骨前保护与暂时固定策略", "Neural Protection and Temporary Fixation Strategy", "S", 10, 2, 0, 0),
    ("T05", "椎板减压及硬膜神经保护", "Laminectomy and Dural-Neural Release", "P", 55, 4, 91, 9),
    ("T06", "临时连接棒稳定", "Temporary Rod Stabilization", "L", 20, 3, 0, 0),
    ("T07", "T12 病变椎体切除", "T12 Vertebral Column Resection", "P", 85, 6, 98, 13),
    ("T08", "前柱支撑与矫形幅度规划", "Anterior Support and Correction Plan", "S", 10, 2, 0, 0),
    ("T09", "前柱融合笼植入", "Anterior Column Cage Reconstruction", "P", 50, 5, 94, 10),
    ("T10", "渐进式后凸矫正与连接棒复位", "Gradual Kyphosis Reduction and Rod Seating", "P", 50, 6, 97, 12),
    ("T11", "最终固定、植骨及完整性复查", "Final Fixation, Grafting and Integrity Check", "P", 35, 4, 89, 8),
    ("T12", "止血、清点及分层关闭", "Hemostasis, Counts and Layered Closure", "F", 25, 2, 0, 0),
]

def parse_story(chapter, count):
    section = raw.split(f"## {chapter}. ", 1)[1].split("## ", 1)[0]
    found = re.findall(r"(?m)^\d{2}\. (旁白|坂口|佩特拉)：(.+)$", section)
    assert len(found) == count, (chapter, len(found))
    return found


def story_rows(chapter, english):
    found = parse_story(chapter, len(english))
    role = {"旁白": "narrator", "坂口": "PLAYER", "佩特拉": "patient"}
    return [{"speaker": role[s], "text": t, "text_en": en} for (s, t), en in zip(found, english)]


def parse_team():
    section = raw.split("## 5. Day 2", 1)[1].split("### 5.1", 1)[0]
    result = {}
    for stage, body in re.findall(r"(?ms)^### (T\d\d) .+?\n(.*?)(?=^### T\d\d |\Z)", section):
        groups = {}
        for phase in ("before_action", "after_resolution"):
            block = body.split(f"**{phase}**", 1)[1].split("**", 1)[0]
            groups[phase] = re.findall(r"(?m)^\d\. \[([a-z_0-9]+)\]「(.+?)」$", block)
            assert len(groups[phase]) == 2, (stage, phase)
        result[stage] = groups
    assert len(result) == 12, len(result)
    return result


def main():
    assert len(DAY1_EN) == 30 and len(DAY3_EN) == 17
    assert len(TEAM_EN) == 12 and all(len(row) == 4 for row in TEAM_EN)
    assert len(FAIL_EN) == 12
    procedures = [p for p in read(DATA / "procedures.json") if p["id"] != ID]
    steps = []
    for stage, zh, en, kind, minutes, hp, difficulty, failed_hp in STAGE_NAMES:
        tag = "neural" if stage in ("T05", "T07", "T10") else "reconstruction" if kind == "P" else ""
        effects = {"elapsed_time": minutes, "visibility": -3 if kind == "P" else 3 if kind == "L" else 0,
                   "bleeding": 2 if stage in ("T02", "T07") else -2 if stage == "T12" else 0,
                   "blood_loss": 7 if stage == "T07" else 3 if kind == "P" else 1,
                   "stability": -2 if stage in ("T07", "T10") else 0}
        step = {"id": stage, "name": zh, "name_en": en, "kind": kind, "hp_base": hp,
                "difficulty": difficulty, "specialty_tag": tag, "hp_failed_extra": failed_hp,
                "strategic_effects": effects, "physio_stress": "high" if stage in ("T07", "T09", "T10") else "medium"}
        if stage in ("T04", "T08"):
            step["options"] = strategy_options(stage)
        steps.append(step)
    procedures.append({"id": ID, "name": "复杂创伤后胸腰椎后凸矫正、椎体切除及内固定融合术",
        "name_en": "Complex Post-traumatic Thoracolumbar Kyphosis Correction with Posterior Vertebral Column Resection and Instrumented Fusion",
        "duration_minutes": 480, "base_difficulty": 98, "training_ceiling": 100, "reward_tier": "advanced", "status": "draft_pending_assets_and_balance",
        "patient_notice": "随机返场病例：陈旧胸腰椎骨折后固定性后凸，拟行后路椎体切除、前柱支撑与内固定融合。",
        "patient_notice_en": "Repeat case: fixed kyphosis following an old thoracolumbar fracture, planned for posterior vertebral column resection, anterior column support and instrumented fusion.",
        "steps": steps, "crisis_checkpoints": [7, 10], "crisis_chances": [0.25, 0.23],
        "physiology_tuning_status": "P0_TUNING_PENDING_GAMEPLAY_APPROVAL",
        "failure_condition": {"metric": "stability", "operator": "<=", "value": 0},
        "success_condition": {"metric": "progress", "operator": ">=", "value": 100}})
    write(DATA / "procedures.json", procedures)
    manifest = [row for row in read(DATA / "release_manifest.json") if row["procedure_id"] != ID]
    assert max(r["release_order"] for r in manifest) == 6
    manifest.append({"release_order": 7, "procedure_id": ID, "category": "ADVANCED_REGULAR", "runtime_ready": True})
    write(DATA / "release_manifest.json", manifest)
    replay = read(DATA / "replay_case_profiles.json")
    replay[ID] = {"diagnosis": "随机返场病例：陈旧胸腰椎压缩骨折后固定性后凸及矢状面失衡，拟行后路椎体切除重建与内固定融合。",
                  "diagnosis_en": "Repeat case: fixed kyphosis and sagittal imbalance after an old thoracolumbar compression fracture, planned for posterior vertebral column resection and instrumented fusion."}
    write(DATA / "replay_case_profiles.json", replay)
    seed = "assets/characters/advanced_petra_v1/seeds/"
    patient = {"id": "patient_petra_itta_adult", "name": "佩特拉·伊塔", "name_en": "Petra Itta", "setting": "adult_medical_AU",
               "diagnosis": "成年医疗 AU：陈旧 T12 创伤后固定性后凸、机械性腰背痛与姿势负担；拟行后路椎体切除、前柱支撑及内固定融合。",
               "diagnosis_en": "Adult medical AU: fixed post-traumatic kyphosis around T12 with mechanical back pain and postural burden; posterior vertebral column resection, anterior support and instrumented fusion are planned.",
               "visuals": {"portraits": {"ward": "assets/characters/advanced_petra_v1/ward.png", "postop": "assets/characters/advanced_petra_v1/postop.png", "team_confirmation": "assets/characters/advanced_petra_v1/team_confirmation.png", "intraoperative/anesthetized": "assets/characters/advanced_petra_v1/anesthesia.png", "splash/general_anesthesia": "assets/characters/advanced_petra_v1/anesthesia.png"},
                           "seed_references": {"bust": seed + "bust.png", "full_body": seed + "full_body.png", "scene": seed + "scene_reference.png"}}}
    story = {"procedure_id": ID, "source_case_id": "ADV-FIRST-07", "runtime_case_id": "advanced_first_" + ID, "patient": patient,
             "day1": {"title": "已经修过一次的身体", "title_en": "A Body Repaired Once Before", "background": "clinic", "portrait": "ward", "lines": story_rows(4, DAY1_EN)},
             "day3": {"title": "这次我会慢慢走", "title_en": "This Time I'll Walk Slowly", "background": "ward", "portrait": "postop", "lines": story_rows(6, DAY3_EN)}}
    write(DATA / "stories" / (ID + ".json"), story)
    dialogue = {"schema_version": "advanced_day2_dialogue_v2", "procedure_id": ID, "stages": {}}
    parsed = parse_team()
    failures = re.findall(r"(?m)^- (T\d\d) \[([a-z_0-9]+)\]「(.+?)」$", raw.split("### 5.1", 1)[1].split("### 5.2", 1)[0])
    assert len(failures) == 12
    for index, (stage, *_rest) in enumerate(STAGE_NAMES):
        groups = {}
        for phase, offsets in (("before_action", (0, 1)), ("after_resolution", (2, 3))):
            groups[phase] = [{"id": f"{stage}_{'B' if phase == 'before_action' else 'A'}{j+1}",
                              "speaker_role": role, "text": zh, "text_en": TEAM_EN[index][offset]}
                             for j, ((role, zh), offset) in enumerate(zip(parsed[stage][phase], offsets))]
        if STAGE_NAMES[index][3] == "P":
            matching = [(role, zh, FAIL_EN[i]) for i, (sid, role, zh) in enumerate(failures) if sid == stage]
            assert len(matching) == 2
            groups["precision_failed"] = [{"id": f"{stage}_F{j+1}", "speaker_role": role, "text": zh, "text_en": en}
                                           for j, (role, zh, en) in enumerate(matching)]
        if stage in CRISIS_EN:
            crisis_source = raw.split("### 5.2", 1)[1].split("## 6.", 1)[0]
            crisis_block = crisis_source.split("**Crisis A" if stage == "T07" else "**Crisis B", 1)[1].split("**", 1)[1]
            crisis_block = crisis_block.split("**Crisis B" if stage == "T07" else "这些对白", 1)[0]
            crisis_lines = re.findall(r"(?m)^- \[([a-z_0-9]+)\]「(.+?)」$", crisis_block)
            assert len(crisis_lines) == 3, stage
            groups["crisis"] = [{"id": f"{stage}_C{j+1}", "speaker_role": role, "text": zh, "text_en": CRISIS_EN[stage][j]}
                                for j, (role, zh) in enumerate(crisis_lines)]
        dialogue["stages"][stage] = groups
    write(DATA / "dialogue_v2" / (ID + ".json"), dialogue)


def strategy_options(stage):
    if stage == "T04":
        return [
            {"id": "staged", "label": "分侧固定与充分神经释放", "label_en": "Alternate fixation sides with thorough neural release",
             "description": "按计划先稳定一侧、分段释放后交换临时棒；更多显露和操作时间，降低后续突发失稳风险。", "description_en": "Stabilize one side first, release in stages, then exchange the temporary rod. More exposure and time reduce the risk of sudden loss of stability.",
             "strategic_effects": {"elapsed_time": 10, "visibility": 10, "stability": 3}},
            {"id": "limited", "label": "有限暴露下顺序交换临时棒", "label_en": "Exchange temporary rods in sequence with limited exposure",
             "description": "在当前影像认可范围内减少额外暴露，节省时间，但需要更仔细地监视临时支撑与后续操作区；语义效果：elapsed_time 较少、下一阶段 visibility 可能较低。不是“省掉安全固定直接截骨”。", "description_en": "Reduce additional exposure within the imaging-approved area to save time, while monitoring temporary support and the next operative area more closely. This does not omit safe fixation before osteotomy.",
             "strategic_effects": {"visibility": -3, "stability": 1}},
        ]
    return [
        {"id": "staged", "label": "分段复位、逐次核对", "label_en": "Correct in stages with repeated checks",
         "description": "按术前矫形目标逐步恢复前柱支撑和后方排列，复核更多；增加时间，减少一次性牵拉负担。", "description_en": "Restore anterior support and posterior alignment toward the preoperative correction target in stages, with more checks and time to reduce one-step traction.",
         "strategic_effects": {"elapsed_time": 10, "visibility": 8, "stability": 3}},
        {"id": "focused", "label": "集中完成计划内复位", "label_en": "Complete the planned correction in a focused sequence",
         "description": "在已确认支撑充分的前提下减少棒的反复调整，减少耗时，但操作更依赖精确对合，后续 Stability/Visibility 的压力较高。", "description_en": "With adequate support confirmed, reduce repeated rod adjustments and time, at the cost of greater dependence on precise alignment and later stability and visibility.",
         "strategic_effects": {"visibility": -3, "stability": -1}},
    ]


if __name__ == "__main__":
    main()
