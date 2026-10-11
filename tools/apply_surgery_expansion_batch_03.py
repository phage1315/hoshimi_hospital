"""Apply the approved Batch 03 surgery package to the canonical runtime data.

The authored stage prose is copied from the self-contained Codex-ready package.
The runtime uses ``transition_text`` for the existing intraoperative record path;
``operative_record`` is retained on each stage as the authored short record field
without changing the previously approved UI behavior.
"""

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "data/surgeries/surgeries.json"


def effects(**values):
    return {key: value for key, value in values.items() if value is not None}


def field(field_name, op, value):
    return {"field": field_name, "op": op, "value": value}


def any_condition(*conditions):
    return {"any": list(conditions)}


def all_condition(*conditions):
    return {"all": list(conditions)}


def condition_effect(condition, values):
    return {
        "when": condition,
        "strategic_effects": values,
        "response": "「请再确认一次。」",
        "response_role": "assistant_surgeon",
    }


def option(option_id, label, values, conditional=None):
    result = {
        "id": option_id,
        "label": label,
        "response": "「明白，继续。」",
        "response_role": "assistant_surgeon",
        "correct": True,
        "correction": "",
        "strategic_effects": values,
    }
    if conditional:
        result["conditional_effects"] = conditional
    return result


def stage(stage_id, title, stage_class, progress, prompt, record, filler,
          interlude, cues, options):
    kind = "confirm" if stage_class == "F" else "decision"
    return {
        "id": stage_id,
        "title": title,
        "kind": kind,
        "stage_kind": "fixed",
        "progress_delta": progress,
        "prompt": prompt,
        "operative_record": record,
        "transition_text": filler,
        "options": options,
        "awake_interlude": interlude,
        "patient_cues": cues,
    }


def correction(stage_id, title, prompt, record, filler, entry_condition,
               options, interlude, cues):
    result = stage(stage_id, title, "CONDITIONAL", 0, prompt, record, filler,
                   interlude, cues, options)
    result["stage_kind"] = "conditional_correction"
    result["entry_condition"] = entry_condition
    result["once_per_episode"] = True
    return result


def mastectomy_stages():
    flap = field("flap_recheck_required", "eq", True)
    return [
        stage(
            "mastectomy_incision", "切口与切除范围", "F", 11,
            "切口范围已经确认。开始全乳房切除。",
            "已按预定范围完成切口，进入皮瓣游离。",
            "切口范围确认以后，{scrub_name}递入切开和基础止血器械，{assistant_name}保持皮肤张力，让切口按照预定方向展开；{circulator_name}记录切除侧别与标本计划。乳房切除正式开始。",
            "operative_contact", ["incision", "exposure"], [
                option("mastectomy_confirm_incision", "确认切口范围，继续", effects(elapsed_time=8, bleeding=1, blood_loss=2)),
            ],
        ),
        stage(
            "mastectomy_superior_flap", "上方皮瓣游离", "S", 11,
            "上方皮瓣开始游离。你准备怎样推进？",
            "上方皮瓣已经建立，乳腺上缘进入更清楚的术野。",
            "上方皮瓣开始从乳腺组织表面逐步游离。{assistant_name}持续提供反向牵引，让皮瓣厚度和分离层次保持可见；{scrub_name}配合吸引与点状止血。暴露越清楚，越容易同时兼顾完整切除和皮瓣血供。",
            "strain_interaction", ["traction", "pressure"], [
                option("mastectomy_superior_careful", "充分展开上方皮瓣，保持分离层次清楚", effects(elapsed_time=20, visibility=10, bleeding=-2, blood_loss=4)),
                option("mastectomy_superior_standard", "按正常节奏完成上方皮瓣游离", effects(elapsed_time=16, visibility=3, bleeding=2, blood_loss=5)),
                option("mastectomy_superior_fast", "利用当前暴露快速完成上方皮瓣游离", effects(elapsed_time=12, visibility=-6, bleeding=6, blood_loss=8), [condition_effect(field("visibility", "lt", 78), effects(set_flags=["flap_recheck_required"]))]),
            ],
        ),
        stage(
            "mastectomy_inferolateral_flap", "下方与外侧皮瓣游离", "S", 11,
            "分离继续向下方和外侧推进。你准备怎样处理？",
            "下方与外侧皮瓣已经展开，乳房外侧轮廓进一步释放。",
            "分离继续向下方和外侧推进。{assistant_name}改变牵引方向，使乳下皱襞和外侧胸壁逐渐进入术野；{scrub_name}跟随术野准备吸引、止血和长柄分离器械。乳房外侧轮廓被越来越完整地从皮肤包被中释放出来。",
            "strain_interaction", ["traction", "pressure"], [
                option("mastectomy_inferolateral_careful", "沿清楚层次逐步完成下方和外侧游离", effects(elapsed_time=19, visibility=8, bleeding=-2, blood_loss=5)),
                option("mastectomy_inferolateral_standard", "按正常节奏完成下方和外侧游离", effects(elapsed_time=15, visibility=2, bleeding=3, blood_loss=6)),
                option("mastectomy_inferolateral_fast", "保持当前牵引快速完成主要游离", effects(elapsed_time=11, visibility=-5, bleeding=7, blood_loss=9), [condition_effect(any_condition(field("visibility", "lt", 76), field("bleeding", "gte", 16)), effects(set_flags=["flap_recheck_required"]))]),
            ],
        ),
        stage(
            "mastectomy_boundary_review", "周缘与腋尾范围确认", "L", 11,
            "进入胸壁深面分离以前，要把切除边界确认到什么程度？",
            "周缘与腋尾范围已经复核，可以进入胸壁深面分离。",
            "上下皮瓣已经建立，{assistant_name}重新拉开外侧术野，使胸骨旁、乳下缘以及腋尾方向能够同时确认；{scrub_name}暂时放慢器械节奏。进入胸壁分离以前，团队先确认需要切除的乳腺范围已经完整包含。",
            "ongoing_interaction", ["pressure", "exposure"], [
                option("mastectomy_boundary_complete", "完整确认四周边界和腋尾范围", effects(elapsed_time=12, visibility=6, bleeding=-1, blood_loss=2)),
                option("mastectomy_boundary_standard", "当前范围清楚，按计划继续", effects(elapsed_time=10, visibility=2, blood_loss=3)),
            ],
        ),
        stage(
            "mastectomy_chest_wall_dissection", "胸壁深面分离", "S", 11,
            "乳房周缘已游离。你准备怎样从胸壁完成深面分离？",
            "乳腺组织已从胸大肌筋膜与胸壁逐步分离。",
            "乳房周缘已经游离完成，下一步从深面把乳腺组织连同胸大肌筋膜逐步抬离胸壁。{assistant_name}保持标本向前上方牵引，{scrub_name}配合长段分离、吸引与止血；随着深面被释放，整块标本逐渐只剩外侧连接。",
            "strain_interaction", ["traction", "deep_manipulation"], [
                option("mastectomy_chest_wall_careful", "沿胸壁层次稳妥分离，持续保持深面清楚", effects(elapsed_time=22, visibility=7, bleeding=-5, blood_loss=7)),
                option("mastectomy_chest_wall_standard", "按正常节奏完成胸壁深面分离", effects(elapsed_time=18, visibility=2, bleeding=3, blood_loss=9)),
                option("mastectomy_chest_wall_fast", "减少中间复核，快速完成深面分离", effects(elapsed_time=13, visibility=-6, bleeding=9, blood_loss=13), [condition_effect(any_condition(field("visibility", "lt", 72), field("bleeding", "gte", 20)), effects(stability=-4, set_flags=["flap_recheck_required"]))]),
            ],
        ),
        stage(
            "mastectomy_lateral_release", "外侧释放与最终标本边界", "L", 11,
            "标本只剩外侧连接。你准备怎样完成最终释放？",
            "外侧连接已经处理，标本达到可完整取出的状态。",
            "深面分离接近完成以后，{assistant_name}重新显露乳房外侧与腋尾最后的连接区域；{scrub_name}准备完成最终释放。只要边界与止血状态一致，标本就可以完整离开术野。",
            "ongoing_interaction", ["traction", "deep_manipulation"], [
                option("mastectomy_lateral_complete", "再整理外侧边界后完成释放", effects(elapsed_time=11, visibility=4, bleeding=-2, blood_loss=2)),
                option("mastectomy_lateral_standard", "当前边界明确，直接完成切除", effects(elapsed_time=9, bleeding=1, blood_loss=3)),
            ],
        ),
        stage(
            "mastectomy_specimen_handoff", "标本取出与交接", "F", 11,
            "标本已经完全游离。确认取出并进入切除腔复核。",
            "乳房标本已完整取出并完成方向标记与送检交接。",
            "乳房标本完整离开胸壁。{scrub_name}按照主刀要求标记方向后把标本交给{circulator_name}完成外围核对和送检记录；{assistant_name}立即重新铺开皮瓣，让整个切除腔重新进入视野。",
            "progress_check", ["pressure"], [
                option("mastectomy_confirm_specimen", "确认取出标本，进入切除腔复核", effects(elapsed_time=6, blood_loss=2)),
            ],
        ),
        stage(
            "mastectomy_cavity_hemostasis", "切除腔止血与皮瓣贴合", "S", 11,
            "切除腔已经完全显露。关闭前你准备做到什么程度？",
            "切除腔止血与皮瓣贴合情况已经处理，准备判断是否需要返工。",
            "大范围切除腔完全显露以后，{assistant_name}依次抬起上、下皮瓣检查深面，{scrub_name}配合完成最后止血并准备引流与关闭材料。现在的重点不再是“切掉什么”，而是让两片皮瓣能够平整、安全地回到胸壁上。",
            "strain_interaction", ["traction", "deep_manipulation"], [
                option("mastectomy_cavity_careful", "完整检查皮瓣深面、止血和死腔后再关闭", effects(elapsed_time=22, visibility=6, bleeding=-14, blood_loss=4, clear_flags=["flap_recheck_required"])),
                option("mastectomy_cavity_standard", "按正常节奏完成止血、贴合和引流准备", effects(elapsed_time=18, visibility=2, bleeding=-8, blood_loss=6), [condition_effect(any_condition(field("visibility", "lt", 72), flap), effects(set_flags=["flap_recheck_required"]))]),
                option("mastectomy_cavity_fast", "减少中间调整，尽快完成皮瓣贴合", effects(elapsed_time=13, visibility=-3, bleeding=-3, blood_loss=8), [condition_effect(any_condition(field("bleeding", "gte", 18), flap), effects(set_flags=["flap_recheck_required"]))]),
            ],
        ),
        correction(
            "mastectomy_flap_correction", "皮瓣与切除腔重新显露",
            "当前皮瓣或切除腔仍有需要重新处理的问题。你准备怎样纠正？",
            "皮瓣与切除腔已完成追加处理，重新进入关闭评估。",
            "关闭前复核时，切除腔仍有一处需要重新处理。{assistant_name}再次掀开对应皮瓣，{scrub_name}准备吸引、止血和追加固定材料；{circulator_name}记录额外处理时间并补充耗材。",
            any_condition(field("visibility", "lt", 68), field("bleeding", "gte", 20), flap),
            [
                option("mastectomy_correction_complete", "重新显露皮瓣和切除腔，完成追加止血与固定", effects(elapsed_time=14, visibility=14, bleeding=-16, blood_loss=5, stability=1, clear_flags=["flap_recheck_required"])),
                option("mastectomy_correction_focus", "只处理最明显的问题，进入最终关闭准备", effects(elapsed_time=7, visibility=3, bleeding=-7, blood_loss=7, clear_flags=["flap_recheck_required"]), [condition_effect(field("bleeding", "gte", 28), effects(blood_loss=8, stability=-4, add_complications=[{"id": "residual_bleeding", "severity": "minor"}]))]),
            ],
            "ongoing_interaction", ["pressure", "deep_manipulation"],
        ),
        stage(
            "mastectomy_closure", "引流与皮肤关闭", "F", 12,
            "切除腔已经稳定。完成引流和皮肤关闭。",
            "引流与皮肤关闭完成，全乳房切除结束。",
            "切除腔确认稳定以后，{scrub_name}完成清点并递入引流和关闭材料，{assistant_name}协助让皮瓣自然贴回胸壁；{circulator_name}完成标本与术后转运记录。皮肤关闭后，这台手术结束。",
            "closure_interaction", ["closure"], [
                option("mastectomy_complete_closure", "完成引流与皮肤关闭，结束手术", effects(elapsed_time=12, blood_loss=2)),
            ],
        ),
    ]


def nephrectomy_stages():
    return [
        stage("nephrectomy_entry", "进入与后腹膜暴露", "F", 9,
              "患侧后腹膜区域已经进入术野。确认继续。",
              "已建立患侧后腹膜初始术野。",
              "切口进入以后，{assistant_name}把牵开方向转向患侧后腹膜，{scrub_name}递入深部牵开、吸引和基础止血器械；{circulator_name}调整灯光。肾区逐渐从腹腔内容物后方进入术野。",
              "operative_contact", ["incision", "exposure"], [option("nephrectomy_confirm_entry", "确认进入后腹膜，继续", effects(elapsed_time=8, bleeding=1, blood_loss=4))]),
        stage("nephrectomy_gerota_exposure", "建立 Gerota 筋膜区域暴露", "L", 9,
              "后腹膜工作空间开始建立。你准备怎样推进？",
              "Gerota 筋膜区域与肾周操作空间已建立。",
              "{assistant_name}将邻近肠管和腹膜内容物向内侧移开，使 Gerota 筋膜所在区域逐渐暴露；{scrub_name}保持长柄分离和吸引器械待用。只有先建立足够的后腹膜工作空间，后面的肾门处理才不会一直被周围组织遮挡。",
              "strain_interaction", ["traction", "pressure"], [
                  option("nephrectomy_gerota_careful", "先把后腹膜暴露做完整", effects(elapsed_time=11, visibility=9, bleeding=1, blood_loss=3)),
                  option("nephrectomy_gerota_standard", "当前空间足够，继续寻找关键结构", effects(elapsed_time=9, visibility=3, bleeding=2, blood_loss=4)),
              ]),
        stage("nephrectomy_landmarks", "输尿管与后腹膜方向确认", "L", 9,
              "进入肾门以前，要把后腹膜方向确认到什么程度？",
              "输尿管与进入肾门的解剖方向已经确认。",
              "后腹膜层次清楚以后，{assistant_name}维持肾下极与腰大肌区域暴露，{scrub_name}配合辨认输尿管和进入肾门所需的解剖方向。团队在真正碰血管以前先把路线对齐。",
              "ongoing_interaction", ["pressure", "deep_manipulation"], [
                  option("nephrectomy_landmarks_careful", "完整确认输尿管与肾门方向", effects(elapsed_time=9, visibility=7, blood_loss=2)),
                  option("nephrectomy_landmarks_standard", "当前解剖关系明确，直接继续", effects(elapsed_time=7, visibility=2, blood_loss=3)),
              ]),
        stage("nephrectomy_hilum_exposure", "肾门显露", "S", 9,
              "肾门开始进入视野。你准备怎样建立血管操作窗口？",
              "肾门窗口已经建立，肾动静脉进入可处理范围。",
              "{assistant_name}逐步把肾脏与周围脂肪组织向外侧和上方调整，肾门区域开始显露；{scrub_name}准备血管夹闭和追加止血器械。真正的技术压力从这里开始——后面的每一步都依赖肾门是否已经看得足够清楚。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("nephrectomy_hilum_careful", "充分打开肾门窗口，再进入血管阶段", effects(elapsed_time=17, visibility=12, bleeding=-2, blood_loss=5)),
                  option("nephrectomy_hilum_standard", "按正常节奏完成肾门显露", effects(elapsed_time=13, visibility=4, bleeding=3, blood_loss=8)),
                  option("nephrectomy_hilum_fast", "利用当前空间快速找到肾门", effects(elapsed_time=9, visibility=-7, bleeding=7, blood_loss=11), [condition_effect(field("visibility", "lt", 72), effects(bleeding=5, stability=-3))]),
              ]),
        stage("nephrectomy_renal_artery", "肾动脉控制", "S", 9,
              "肾动脉已经辨认。你准备怎样完成控制？",
              "肾动脉控制完成，准备进入静脉阶段。",
              "肾动脉被完整辨认以后，{assistant_name}维持肾门窗口，{scrub_name}连续提供血管控制器械。先稳定动脉端，能明显改变接下来静脉处理时的出血压力。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("nephrectomy_artery_careful", "分清血管关系后稳妥控制动脉", effects(elapsed_time=13, visibility=4, bleeding=-7, blood_loss=7)),
                  option("nephrectomy_artery_standard", "按标准节奏完成动脉控制", effects(elapsed_time=10, bleeding=2, blood_loss=10)),
                  option("nephrectomy_artery_fast", "减少中间复核，快速完成控制", effects(elapsed_time=7, visibility=-4, bleeding=9, blood_loss=15), [condition_effect(any_condition(field("visibility", "lt", 72), field("bleeding", "gte", 18)), effects(bleeding=6, blood_loss=8, stability=-5))]),
              ]),
        stage("nephrectomy_renal_vein", "肾静脉控制", "S", 9,
              "肾静脉及其邻近分支已经进入术野。你准备怎样处理？",
              "肾静脉控制完成，肾门血流阶段结束。",
              "动脉侧处理完成以后，{assistant_name}重新调整肾门深度，让肾静脉及其邻近分支能够被清楚观察；{scrub_name}准备静脉控制和备用止血材料。相比前一步，这里的容错更依赖稳定暴露。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("nephrectomy_vein_careful", "重新整理深部暴露后分步处理静脉", effects(elapsed_time=15, visibility=5, bleeding=-8, blood_loss=9)),
                  option("nephrectomy_vein_standard", "按标准节奏完成静脉控制", effects(elapsed_time=11, bleeding=4, blood_loss=14)),
                  option("nephrectomy_vein_fast", "依当前暴露快速完成静脉处理", effects(elapsed_time=8, visibility=-5, bleeding=12, blood_loss=20), [condition_effect(any_condition(field("visibility", "lt", 70), field("bleeding", "gte", 22)), effects(blood_loss=10, stability=-7))]),
              ]),
        stage("nephrectomy_mobilization", "肾脏与肾周包被游离", "S", 9,
              "肾门已经控制。你准备怎样完成肾脏整块游离？",
              "肾脏与肾周包被已从后腹膜床逐步释放。",
              "肾门血流已经受控，{assistant_name}开始改变整个肾脏的牵引方向，让后方、外侧和上下极附着依次进入术野；{scrub_name}配合长段游离与局部止血。肾脏连同周围包被逐渐从后腹膜床上被释放出来。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("nephrectomy_mobilization_careful", "按层次逐区游离并随时止血", effects(elapsed_time=20, visibility=7, bleeding=-5, blood_loss=9)),
                  option("nephrectomy_mobilization_standard", "按正常节奏完成整块游离", effects(elapsed_time=16, visibility=2, bleeding=4, blood_loss=12)),
                  option("nephrectomy_mobilization_fast", "保持牵引快速完成剩余游离", effects(elapsed_time=11, visibility=-5, bleeding=10, blood_loss=17)),
              ]),
        stage("nephrectomy_poles_ureter", "上下极、输尿管与肾上腺平面", "L", 9,
              "大部分肾脏已经游离。最后连接准备怎样处理？",
              "上下极、输尿管和保留肾上腺的平面已经完成处理。",
              "大部分肾脏已经游离，{assistant_name}依次显露下极输尿管和上极肾上腺平面；{scrub_name}准备完成剩余连接的处理。默认病例保留没有受累的肾上腺，只处理属于本次切除范围的组织。",
              "strain_interaction", ["traction", "pressure"], [
                  option("nephrectomy_poles_careful", "把上、下极关系整理清楚再完成释放", effects(elapsed_time=10, visibility=4, bleeding=-2, blood_loss=3)),
                  option("nephrectomy_poles_standard", "当前范围明确，完成最后连接", effects(elapsed_time=8, bleeding=1, blood_loss=4)),
              ]),
        stage("nephrectomy_specimen_handoff", "整块切除与标本交接", "F", 9,
              "最后的连接已经处理。确认取出标本并进入肾床复核。",
              "肾脏及周围标本已完整取出并完成交接。",
              "最后的连接被处理以后，肾脏和周围标本完整离开术野。{scrub_name}接收并标记标本，再交由{circulator_name}完成外围记录；{assistant_name}重新显露肾床和肾门残端。",
              "progress_check", ["pressure"], [option("nephrectomy_confirm_specimen", "确认取出标本，进入肾床复核", effects(elapsed_time=5, blood_loss=3))]),
        correction(
            "nephrectomy_bed_correction", "肾床重新显露与追加止血",
            "当前肾床仍不够干净。你准备怎样纠正？",
            "肾床已完成追加显露与止血处理。",
            "标本已经离开，但肾床当前仍不够干净。{assistant_name}重新建立深部暴露，{scrub_name}准备吸引和追加止血器械；{circulator_name}记录额外处理时间。",
            any_condition(field("visibility", "lt", 68), field("bleeding", "gte", 28)),
            [
                option("nephrectomy_correction_complete", "重新建立肾床暴露并完成追加止血", effects(elapsed_time=14, visibility=18, bleeding=-22, blood_loss=8, stability=2)),
                option("nephrectomy_correction_focus", "只控制最明显的出血点，留给最终复核", effects(elapsed_time=7, bleeding=-8, blood_loss=12), [condition_effect(field("bleeding", "gte", 35), effects(blood_loss=12, stability=-7, add_complications=[{"id": "active_field_bleeding", "severity": "minor"}]))]),
            ],
            "ongoing_interaction", ["pressure", "deep_manipulation"],
        ),
        stage("nephrectomy_final_review", "肾门残端与肾床最终复核", "S", 9,
              "关闭以前，你准备把肾床复核到什么程度？",
              "肾门残端、上极、下极和肾床止血状态已完成最终复核。",
              "肾床重新稳定暴露以后，{assistant_name}依次调整牵开角度，让肾门残端、上极和下极处理区域全部进入视野；{scrub_name}配合完成最后止血。关闭以前必须确认这里没有留下仍在继续恶化的问题。",
              "progress_check", ["pressure"], [
                  option("nephrectomy_final_complete", "完整复核肾门残端和整个肾床", effects(elapsed_time=13, visibility=5, bleeding=-18, blood_loss=4, stability=1)),
                  option("nephrectomy_final_focus", "重点检查高风险区域，稳定就关闭", effects(elapsed_time=10, bleeding=-10, blood_loss=5), [condition_effect(field("bleeding", "gte", 22), effects(blood_loss=9, stability=-5, add_complications=[{"id": "residual_bleeding", "severity": "minor"}]))]),
              ]),
        stage("nephrectomy_closure", "关闭", "F", 10,
              "后腹膜区域已经稳定。完成关闭。",
              "切口关闭完成，开腹肾切除结束。",
              "后腹膜区域确认稳定以后，{scrub_name}完成最终清点并递入关闭材料，{assistant_name}协助逐层关闭切口；{circulator_name}完成标本、失血和术后转运记录。",
              "closure_interaction", ["closure"], [option("nephrectomy_complete_closure", "完成关闭，结束手术", effects(elapsed_time=10, blood_loss=5))]),
    ]


def lobectomy_stages():
    air_leak = field("air_leak_recheck_required", "eq", True)
    return [
        stage("lobectomy_thoracotomy", "开胸与胸腔进入", "F", 8,
              "胸腔已经进入。确认建立目标肺叶术野。",
              "开胸完成，目标肺叶进入直视术野。",
              "开胸切口完成以后，{assistant_name}协助建立肋间暴露，{scrub_name}递入胸腔牵开、长柄吸引和血管器械；{circulator_name}重新调整灯光与设备位置。目标肺叶逐渐进入直视术野。",
              "operative_contact", ["incision", "exposure"], [option("lobectomy_confirm_thoracotomy", "确认胸腔进入，继续", effects(elapsed_time=15, bleeding=1, blood_loss=5))]),
        stage("lobectomy_pleural_exposure", "胸膜腔检查与粘连处理", "L", 8,
              "进入肺门以前，你准备怎样处理当前胸膜条件？",
              "胸膜腔与影响暴露的粘连已经评估并处理到可继续程度。",
              "{assistant_name}轻轻改变肺的位置，让胸膜腔、目标肺叶和可能存在的粘连逐步显露；{scrub_name}保持分离与吸引器械待用。真正进入肺门以前，团队先确认这台病例的胸腔条件。",
              "strain_interaction", ["traction", "pressure"], [
                  option("lobectomy_pleural_careful", "先处理影响暴露的胸膜粘连", effects(elapsed_time=13, visibility=10, bleeding=1, blood_loss=3)),
                  option("lobectomy_pleural_standard", "当前胸腔条件足够，按计划继续", effects(elapsed_time=10, visibility=3, bleeding=3, blood_loss=4)),
              ]),
        stage("lobectomy_fissure_mobilization", "叶间裂评估与肺叶游离", "S", 8,
              "目标肺叶活动度开始增加。你准备怎样建立叶间裂和肺门暴露？",
              "叶间裂与目标肺叶已经完成主要游离，肺门方向更清楚。",
              "目标肺叶被进一步抬起，叶间裂和肺门方向逐渐变得清楚。{assistant_name}持续调整牵拉，让肺实质和血管之间保持安全距离；{scrub_name}配合分离、吸引和局部止血。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("lobectomy_fissure_careful", "充分游离叶间裂并把肺门方向做清楚", effects(elapsed_time=23, visibility=11, bleeding=-2, blood_loss=6)),
                  option("lobectomy_fissure_standard", "按正常节奏完成肺叶游离", effects(elapsed_time=18, visibility=4, bleeding=3, blood_loss=7)),
                  option("lobectomy_fissure_fast", "利用当前牵引快速进入肺门", effects(elapsed_time=13, visibility=-7, bleeding=8, blood_loss=11)),
              ]),
        stage("lobectomy_hilum_orientation", "肺门定向与处理顺序确认", "L", 8,
              "肺门关系已经能够辨认。你准备确认到什么程度再进入血管阶段？",
              "肺门静脉、动脉分支和叶支气管的处理顺序已经确认。",
              "肺叶活动度已经足够，{assistant_name}重新摆正肺门，让静脉、肺动脉分支和支气管的大体关系能够同时确认；{scrub_name}准备血管与支气管处理器械。主刀在真正开始逐一切断以前先确定这台病例的顺序。",
              "ongoing_interaction", ["pressure", "deep_manipulation"], [
                  option("lobectomy_hilum_careful", "完整确认肺门关系和处理顺序", effects(elapsed_time=11, visibility=7, blood_loss=3)),
                  option("lobectomy_hilum_standard", "当前关系明确，进入血管阶段", effects(elapsed_time=9, visibility=2, blood_loss=4)),
              ]),
        stage("lobectomy_pulmonary_vein", "肺静脉控制", "S", 8,
              "肺静脉已经进入稳定视野。你准备怎样完成控制？",
              "目标肺叶的肺静脉控制完成。",
              "肺静脉进入稳定视野以后，{assistant_name}保持目标肺叶方向，避免肺门被牵扭；{scrub_name}准备血管控制器械。肺叶切除第一次进入真正的大血管阶段。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("lobectomy_vein_careful", "重新确认静脉关系后分步完成控制", effects(elapsed_time=22, visibility=4, bleeding=-6, blood_loss=11)),
                  option("lobectomy_vein_standard", "按标准节奏完成肺静脉控制", effects(elapsed_time=18, bleeding=3, blood_loss=15)),
                  option("lobectomy_vein_fast", "减少中间复核，快速完成控制", effects(elapsed_time=13, visibility=-4, bleeding=10, blood_loss=21), [condition_effect(field("visibility", "lt", 74), effects(stability=-4))]),
              ]),
        stage("lobectomy_pulmonary_artery", "肺动脉分支控制", "S", 8,
              "目标肺叶的肺动脉分支已经暴露。你准备怎样处理？",
              "目标肺叶肺动脉分支的主要控制已经完成。",
              "静脉侧完成以后，{assistant_name}改变肺叶角度，使供应目标肺叶的肺动脉分支逐一进入术野；{scrub_name}保持血管器械与备用止血材料连续可用。这是整台手术最不能在差术野下强行抢速度的阶段之一。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("lobectomy_artery_careful", "逐支确认并控制肺动脉分支", effects(elapsed_time=27, visibility=5, bleeding=-9, blood_loss=15)),
                  option("lobectomy_artery_standard", "按标准节奏完成动脉分支处理", effects(elapsed_time=22, bleeding=5, blood_loss=22)),
                  option("lobectomy_artery_fast", "按当前暴露快速完成主要分支控制", effects(elapsed_time=16, visibility=-7, bleeding=15, blood_loss=30), [condition_effect(any_condition(field("visibility", "lt", 72), field("bleeding", "gte", 24)), effects(blood_loss=12, stability=-8))]),
              ]),
        stage("lobectomy_bronchus", "叶支气管处理", "S", 8,
              "血管处理已经稳定。你准备怎样处理叶支气管？",
              "叶支气管已完成关闭与切断，准备处理最后的肺实质连接。",
              "血管处理稳定以后，目标肺叶已经主要由支气管和剩余肺实质连接。{assistant_name}让支气管走向保持清楚，{scrub_name}准备支气管关闭与切断器械。这里既决定肺叶能否顺利离开，也会影响后面的残端复核。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("lobectomy_bronchus_careful", "完整确认支气管关系并稳妥关闭切断", effects(elapsed_time=20, visibility=4, bleeding=-2, blood_loss=7)),
                  option("lobectomy_bronchus_standard", "按标准节奏完成支气管处理", effects(elapsed_time=16, blood_loss=10)),
                  option("lobectomy_bronchus_fast", "减少中间复核，尽快完成支气管切断", effects(elapsed_time=12, visibility=-4, blood_loss=12), [condition_effect(field("visibility", "lt", 76), effects(set_flags=["air_leak_recheck_required"]))]),
              ]),
        stage("lobectomy_fissure_completion", "叶间裂与肺实质完成分离", "S", 8,
              "目标肺叶只剩最后的肺实质连接。你准备怎样完成分离？",
              "叶间裂和剩余肺实质连接已完成分离。",
              "支气管处理完成以后，{assistant_name}沿最后剩余的叶间连接保持稳定牵引，{scrub_name}配合完成肺实质分离和局部止血。随着叶间裂完全分开，目标肺叶成为独立标本。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("lobectomy_fissure_complete", "分段完成肺实质分离并逐区检查", effects(elapsed_time=24, visibility=4, bleeding=-5, blood_loss=10)),
                  option("lobectomy_fissure_standard", "按标准节奏完成剩余分离", effects(elapsed_time=20, bleeding=4, blood_loss=14)),
                  option("lobectomy_fissure_fast", "快速完成剩余叶间连接", effects(elapsed_time=14, visibility=-4, bleeding=9, blood_loss=19, set_flags=["air_leak_recheck_required"]),),
              ]),
        stage("lobectomy_specimen_handoff", "肺叶取出与标本交接", "F", 8,
              "肺叶已经完全游离。确认取出并进入残端复核。",
              "目标肺叶已完整取出并完成标本交接。",
              "肺叶完整离开胸腔。{scrub_name}接收标本并按照要求标记方向，再交由{circulator_name}完成送检记录；{assistant_name}随即重新显露肺门残端和剩余肺组织。",
              "progress_check", ["pressure"], [option("lobectomy_confirm_specimen", "确认取出肺叶，进入残端复核", effects(elapsed_time=7, blood_loss=4))]),
        correction(
            "lobectomy_correction", "肺门或漏气区重新显露",
            "当前肺门或剩余肺表面仍有问题。你准备怎样纠正？",
            "肺门或漏气区域已完成追加处理，重新进入最终复核。",
            "标本已经取出，但肺门或剩余肺表面还有一处不能直接进入关闭。{assistant_name}重新建立对应区域的暴露，{scrub_name}准备追加止血、关闭和漏气处理材料；{circulator_name}记录额外处理时间。",
            any_condition(field("visibility", "lt", 68), field("bleeding", "gte", 28), air_leak),
            [
                option("lobectomy_correction_complete", "重新显露肺门和剩余肺表面，完成追加止血与漏气处理", effects(elapsed_time=16, visibility=16, bleeding=-20, blood_loss=8, stability=2, clear_flags=["air_leak_recheck_required"])),
                option("lobectomy_correction_focus", "只处理最明显的问题，进入最终复核", effects(elapsed_time=9, visibility=4, bleeding=-8, blood_loss=11, clear_flags=["air_leak_recheck_required"]), [condition_effect(field("bleeding", "gte", 36), effects(blood_loss=12, stability=-7, add_complications=[{"id": "active_field_bleeding", "severity": "minor"}]))]),
            ],
            "ongoing_interaction", ["pressure", "deep_manipulation"],
        ),
        stage("lobectomy_final_review", "支气管残端、血管与漏气最终复核", "S", 8,
              "胸腔关闭以前，你准备把肺门和剩余肺复核到什么程度？",
              "支气管残端、血管残端、剩余肺表面与漏气情况已完成最终复核。",
              "{assistant_name}依次显露支气管残端、血管残端和剩余肺表面，{scrub_name}配合完成最后止血和漏气检查。胸腔关闭以前，这里必须同时回答两个问题：还出不出血，以及还漏不漏气。",
              "progress_check", ["pressure"], [
                  option("lobectomy_final_complete", "完整复核支气管残端、血管残端和漏气情况", effects(elapsed_time=21, visibility=5, bleeding=-18, blood_loss=5, clear_flags=["air_leak_recheck_required"])),
                  option("lobectomy_final_focus", "重点复核高风险区域，稳定就进入膨肺", effects(elapsed_time=17, bleeding=-10, blood_loss=8), [condition_effect(air_leak, effects(elapsed_time=6, blood_loss=3, clear_flags=["air_leak_recheck_required"], add_complications=[{"id": "closure_rework", "severity": "minor"}]))]),
              ]),
        stage("lobectomy_reexpansion", "胸腔引流与剩余肺膨开", "L", 8,
              "关键残端已经稳定。你准备怎样完成引流和重新膨肺确认？",
              "胸腔引流位置与剩余肺膨开情况已经确认。",
              "关键残端确认稳定以后，{assistant_name}帮助剩余肺恢复自然位置，{scrub_name}准备胸腔引流材料；{circulator_name}配合麻醉侧完成重新膨肺阶段的记录。团队确认剩余肺能够正常展开，再准备关闭胸壁。",
              "ongoing_interaction", ["pressure", "position_discomfort"], [
                  option("lobectomy_reexpansion_complete", "完整确认剩余肺膨开和引流位置", effects(elapsed_time=12, visibility=3, blood_loss=2)),
                  option("lobectomy_reexpansion_standard", "当前状态稳定，按常规完成", effects(elapsed_time=10, blood_loss=3)),
              ]),
        stage("lobectomy_closure", "胸壁关闭", "F", 12,
              "胸腔状态已经稳定。完成胸壁关闭。",
              "胸壁关闭完成，开胸肺叶切除结束。",
              "胸腔状态确认以后，{scrub_name}完成最终清点并递入关闭材料，{assistant_name}协助逐层关闭胸壁；{circulator_name}完成标本、引流和术后转运记录。",
              "closure_interaction", ["closure"], [option("lobectomy_complete_closure", "完成胸壁关闭，结束手术", effects(elapsed_time=14, blood_loss=5))]),
    ]


def sigmoid_stages():
    recheck = field("anastomosis_recheck_required", "eq", True)
    return [
        stage("sigmoid_entry", "腹腔进入与左下腹暴露", "F", 8,
              "左下腹和盆腔入口已经进入术野。确认继续。",
              "已建立乙状结肠手术的初始左下腹术野。",
              "腹腔进入以后，{assistant_name}把牵开重点转向左下腹和盆腔入口，{scrub_name}整理结直肠手术需要的长柄分离、吸引和止血器械；{circulator_name}调整灯光。乙状结肠和病变区域逐渐进入术野。",
              "operative_contact", ["incision", "exposure"], [option("sigmoid_confirm_entry", "确认左下腹进入，继续", effects(elapsed_time=12, bleeding=1, blood_loss=5))]),
        stage("sigmoid_margin_review", "病变与切除边界确认", "L", 8,
              "真正开始游离以前，要把切除范围确认到什么程度？",
              "病变段及近、远端计划切除边界已经确认。",
              "{assistant_name}展开乙状结肠，使病变段以及预定保留的近端和远端肠管能够同时观察；{scrub_name}保持标记和分离器械待用。真正游离以前，团队先把切除范围重新对齐。",
              "ongoing_interaction", ["pressure", "exposure"], [
                  option("sigmoid_margin_careful", "完整复核病变位置和切除边界", effects(elapsed_time=11, visibility=7, blood_loss=3)),
                  option("sigmoid_margin_standard", "与术前计划一致，按当前范围继续", effects(elapsed_time=9, visibility=2, blood_loss=4)),
              ]),
        stage("sigmoid_lateral_mobilization", "乙状结肠与降结肠游离", "S", 8,
              "左侧结肠开始获得活动度。你准备怎样推进游离？",
              "乙状结肠与远端降结肠已完成主要外侧游离。",
              "{assistant_name}将乙状结肠向内侧牵引，使外侧附着逐渐进入术野；{scrub_name}配合长段分离、吸引和局部止血。随着游离向上推进，乙状结肠和远端降结肠获得越来越大的活动度。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("sigmoid_mobilization_careful", "沿清楚层次逐步游离并建立稳定活动度", effects(elapsed_time=23, visibility=11, bleeding=-3, blood_loss=7)),
                  option("sigmoid_mobilization_standard", "按正常节奏完成左侧结肠游离", effects(elapsed_time=18, visibility=4, bleeding=3, blood_loss=9)),
                  option("sigmoid_mobilization_fast", "保持当前牵引快速完成主要游离", effects(elapsed_time=13, visibility=-7, bleeding=8, blood_loss=13)),
              ]),
        stage("sigmoid_retroperitoneal_review", "后腹膜层次与输尿管保护", "L", 8,
              "进入系膜血管阶段以前，你准备怎样确认后腹膜关系？",
              "左侧输尿管与后腹膜保护层次已经确认。",
              "左侧结肠已经被部分抬离后腹膜。{assistant_name}维持结肠向内侧牵开，让输尿管和后腹膜层次能够重新确认；{scrub_name}暂时放慢器械节奏。进入系膜和血管处理以前，团队先把需要保护的结构留在清楚的一侧。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("sigmoid_retroperitoneal_careful", "完整确认输尿管和后腹膜层次", effects(elapsed_time=10, visibility=8, blood_loss=3)),
                  option("sigmoid_retroperitoneal_standard", "当前关系清楚，继续进入系膜处理", effects(elapsed_time=8, visibility=2, blood_loss=4)),
              ]),
        stage("sigmoid_mesenteric_control", "乙状结肠系膜与血管控制", "S", 8,
              "切除范围已经明确。你准备怎样处理系膜与血管？",
              "乙状结肠主要系膜与血管处理已经完成。",
              "切除范围明确以后，{assistant_name}抬起乙状结肠系膜，使主要血管处理区域进入术野；{scrub_name}连续准备血管控制、吸引和追加止血器械。病变肠段真正能够切掉以前，必须先把这片系膜处理稳定。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("sigmoid_mesenteric_careful", "逐段处理系膜并保持血管关系清楚", effects(elapsed_time=24, visibility=5, bleeding=-7, blood_loss=12)),
                  option("sigmoid_mesenteric_standard", "按正常节奏完成系膜和血管处理", effects(elapsed_time=20, bleeding=4, blood_loss=16)),
                  option("sigmoid_mesenteric_fast", "减少中间复核，快速完成主要系膜处理", effects(elapsed_time=14, visibility=-6, bleeding=12, blood_loss=23), [condition_effect(any_condition(field("visibility", "lt", 72), field("bleeding", "gte", 22)), effects(blood_loss=10, stability=-6))]),
              ]),
        stage("sigmoid_proximal_reach", "建立近端长度与必要的脾曲游离", "S", 8,
              "近端结肠需要能够无张力到达盆腔。你准备怎样建立足够长度？",
              "近端结肠已经获得重建所需的活动度与长度。",
              "系膜处理完成以后，{assistant_name}把预定保留的近端结肠带向盆腔，检查它能否在没有明显牵拉的情况下到达远端。需要时，游离继续向左上腹延伸，直到吻合需要的长度真正够用；{scrub_name}随术野切换准备长柄分离和止血器械。",
              "strain_interaction", ["traction", "pressure"], [
                  option("sigmoid_proximal_careful", "充分获得近端长度，确认可以无张力到达盆腔", effects(elapsed_time=25, visibility=7, bleeding=-2, blood_loss=8)),
                  option("sigmoid_proximal_standard", "按当前需要完成近端游离", effects(elapsed_time=20, visibility=3, bleeding=3, blood_loss=10)),
                  option("sigmoid_proximal_fast", "尽量保留现有游离范围，直接进入切断", effects(elapsed_time=14, visibility=-4, bleeding=5, blood_loss=12), [condition_effect(field("visibility", "lt", 76), effects(set_flags=["anastomosis_recheck_required"]))]),
              ]),
        stage("sigmoid_bowel_division", "近远端肠管切断", "L", 8,
              "两端边界已经进入术野。你准备怎样完成切断？",
              "近端结肠与远端肠管已按计划完成切断。",
              "近端活动度确认以后，{assistant_name}稳定预定的近端结肠和远端直乙交界区域，{scrub_name}准备完成肠管切断和残端保护。此前的边界与血供判断如果清楚，这一步应该相对直接。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("sigmoid_bowel_division_careful", "再确认两端边界后完成切断", effects(elapsed_time=11, visibility=3, blood_loss=4)),
                  option("sigmoid_bowel_division_standard", "按当前确认结果完成切断", effects(elapsed_time=9, blood_loss=5)),
              ]),
        stage("sigmoid_specimen_handoff", "标本取出与术野重整", "F", 8,
              "病变肠段已经切除。确认标本交接并转入重建。",
              "乙状结肠标本已取出并完成送检交接，术野转入重建阶段。",
              "乙状结肠标本完整离开术野。{scrub_name}接收并交由{circulator_name}完成标记和送检记录；{assistant_name}重新整理近端结肠与远端直肠残端。手术从切除阶段转入重建。",
              "progress_check", ["pressure"], [option("sigmoid_confirm_specimen", "确认标本交接完成，进入重建准备", effects(elapsed_time=6, blood_loss=3))]),
        stage("sigmoid_anastomosis_prep", "吻合前血供与张力准备", "S", 8,
              "两端肠管已经重新靠近。你准备怎样确认血供、方向与张力？",
              "两端肠管的血供、方向与张力已经完成吻合前评估。",
              "两端肠管重新被带到一起。{assistant_name}调整近端结肠方向，确认没有扭转，并检查它是否能够自然到达远端；{scrub_name}准备吻合材料。真正开始吻合以前，团队先确认血供和张力都足以支持新的连接。",
              "strain_interaction", ["traction", "pressure"], [
                  option("sigmoid_anastomosis_prep_careful", "重新整理两端，完整确认血供、方向和张力", effects(elapsed_time=22, visibility=7, bleeding=-3, blood_loss=5, clear_flags=["anastomosis_recheck_required"])),
                  option("sigmoid_anastomosis_prep_standard", "按正常条件进入吻合", effects(elapsed_time=18, visibility=2, blood_loss=7), [condition_effect(field("visibility", "lt", 74), effects(set_flags=["anastomosis_recheck_required"]))]),
                  option("sigmoid_anastomosis_prep_fast", "当前两端能够靠近，直接进入吻合", effects(elapsed_time=13, visibility=-4, blood_loss=8, set_flags=["anastomosis_recheck_required"])),
              ]),
        stage("sigmoid_anastomosis", "结直肠吻合", "S", 8,
              "吻合条件已经建立。你准备怎样完成结直肠吻合？",
              "近端结肠与远端已经完成主要吻合。",
              "两端条件确认以后，吻合正式开始。{assistant_name}持续保持近端结肠方向稳定，避免吻合过程中出现扭转或额外张力；{scrub_name}按照主刀节奏递入吻合与追加缝合材料。近端结肠和远端重新形成连续通路。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("sigmoid_anastomosis_careful", "反复确认对合和张力，稳妥完成吻合", effects(elapsed_time=27, visibility=5, bleeding=-3, blood_loss=6, clear_flags=["anastomosis_recheck_required"])),
                  option("sigmoid_anastomosis_standard", "按标准节奏完成吻合", effects(elapsed_time=22, bleeding=2, blood_loss=8), [condition_effect(any_condition(field("visibility", "lt", 72), recheck), effects(set_flags=["anastomosis_recheck_required"]))]),
                  option("sigmoid_anastomosis_fast", "减少中间调整，尽快完成吻合", effects(elapsed_time=16, visibility=-5, bleeding=5, blood_loss=11, set_flags=["anastomosis_recheck_required"])),
              ]),
        correction(
            "sigmoid_anastomosis_correction", "吻合区重新显露与修整",
            "当前吻合区仍有不能直接进入结束的问题。你准备怎样纠正？",
            "吻合区已完成追加修整和止血处理。",
            "吻合已经完成主体，但当前还有一处不能直接进入结束。{assistant_name}重新展开吻合区，{scrub_name}准备追加缝合、吸引和修整材料；{circulator_name}记录额外处理时间。",
            any_condition(field("visibility", "lt", 68), field("bleeding", "gte", 24), recheck),
            [
                option("sigmoid_correction_complete", "重新展开吻合区，完成必要修整和追加止血", effects(elapsed_time=16, visibility=14, bleeding=-16, blood_loss=7, stability=1, clear_flags=["anastomosis_recheck_required"])),
                option("sigmoid_correction_focus", "只处理最明显的问题，进入最终复核", effects(elapsed_time=9, visibility=4, bleeding=-7, blood_loss=9, clear_flags=["anastomosis_recheck_required"]), [condition_effect(field("bleeding", "gte", 32), effects(blood_loss=10, stability=-5, add_complications=[{"id": "closure_rework", "severity": "minor"}]))]),
            ],
            "ongoing_interaction", ["pressure", "deep_manipulation"],
        ),
        stage("sigmoid_final_review", "吻合完整性、止血与最终复核", "S", 8,
              "关闭腹壁以前，你准备把吻合和左侧腹腔复核到什么程度？",
              "吻合区、系膜处理区与左侧腹腔已完成最终复核。",
              "吻合完成以后，{assistant_name}依次显露吻合区、系膜处理区域和左侧腹腔，{scrub_name}配合完成最后止血和吻合完整性检查。关闭以前，团队确认切除和重建两部分都已经稳定。",
              "progress_check", ["pressure"], [
                  option("sigmoid_final_complete", "完整检查吻合、系膜处理区和左侧腹腔", effects(elapsed_time=22, visibility=5, bleeding=-15, blood_loss=5, clear_flags=["anastomosis_recheck_required"])),
                  option("sigmoid_final_focus", "重点复核吻合区，稳定就关闭", effects(elapsed_time=18, bleeding=-8, blood_loss=7), [condition_effect(recheck, effects(elapsed_time=6, blood_loss=4, clear_flags=["anastomosis_recheck_required"], add_complications=[{"id": "closure_rework", "severity": "minor"}]))]),
              ]),
        stage("sigmoid_closure", "腹壁关闭", "F", 12,
              "腹腔情况已经稳定。完成腹壁关闭。",
              "腹壁关闭完成，开腹乙状结肠切除结束。",
              "腹腔情况确认稳定以后，{scrub_name}完成最终清点并递入关闭材料，{assistant_name}协助逐层关闭腹壁；{circulator_name}完成标本、吻合和术后转运记录。",
              "closure_interaction", ["closure"], [option("sigmoid_complete_closure", "完成腹壁关闭，结束手术", effects(elapsed_time=12, blood_loss=5))]),
    ]


VARIANTS = {
    "surgery_total_mastectomy": [
        {"id": "standard", "weight": 75, "initial_visibility": 92, "player_hint": "乳腺与皮下、胸壁之间的层次比较清楚，预定皮瓣范围能够顺利展开。"},
        {"id": "fibrotic_flap_plane", "weight": 25, "initial_visibility": 76, "player_hint": "局部组织纤维化明显，皮瓣和乳腺之间的层次没有一次完整显现；后面的长段游离更依赖持续稳定的牵引。"},
    ],
    "surgery_open_nephrectomy": [
        {"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "患侧后腹膜关系较清楚，肾脏周围包被和肾门方向能够较容易建立。"},
        {"id": "bulky_perirenal_plane", "weight": 25, "initial_visibility": 73, "player_hint": "肾周组织厚、深部空间拥挤，肾门并不能直接进入清楚视野；后面的血管控制会更依赖前期暴露。"},
    ],
    "surgery_open_lung_lobectomy": [
        {"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "胸膜腔条件尚可，目标肺叶能够被较顺利地移动，肺门方向容易建立。"},
        {"id": "dense_pleural_adhesions", "weight": 25, "initial_visibility": 70, "player_hint": "胸膜粘连明显，目标肺叶活动受限，叶间裂和肺门方向都需要先通过额外游离才能真正看清。"},
    ],
    "surgery_open_sigmoid_colectomy": [
        {"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "左下腹和盆腔入口层次较清楚，乙状结肠能够被自然牵起，后腹膜方向容易确认。"},
        {"id": "dense_pelvic_adhesions", "weight": 25, "initial_visibility": 72, "player_hint": "乙状结肠在盆腔内粘连明显，后腹膜层次和远端活动度都受到限制；想要顺利重建，前面的游离不能太草率。"},
    ],
}


STAGE_BUILDERS = {
    "surgery_total_mastectomy": mastectomy_stages,
    "surgery_open_nephrectomy": nephrectomy_stages,
    "surgery_open_lung_lobectomy": lobectomy_stages,
    "surgery_open_sigmoid_colectomy": sigmoid_stages,
}


def main():
    data = json.loads(PATH.read_text())
    updated = set()
    for surgery in data:
        surgery_id = surgery.get("id")
        if surgery_id not in STAGE_BUILDERS:
            continue
        stages = STAGE_BUILDERS[surgery_id]()
        surgery["stages"] = stages
        surgery["case_variants"] = VARIANTS[surgery_id]
        surgery.setdefault("initial_state", {})["bleeding"] = 0
        surgery["fixed_stage_progress"] = [
            stage_item["progress_delta"]
            for stage_item in stages
            if stage_item["stage_kind"] != "conditional_correction"
        ]
        updated.add(surgery_id)
    expected = set(STAGE_BUILDERS)
    if updated != expected:
        raise SystemExit(f"Batch 03 target mismatch: expected {sorted(expected)}, got {sorted(updated)}")
    PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")


if __name__ == "__main__":
    main()
