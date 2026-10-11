"""Apply the approved Batch 02 surgery data to the canonical runtime file.

This replaces the old four-stage placeholders for the four Batch 02 procedures
with the authored 9/12-stage Surgery V2 definitions.  It deliberately changes
only the four procedure records and keeps the existing runner/schema intact.
"""

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "data/surgeries/surgeries.json"


def effects(**values):
    return {key: value for key, value in values.items() if value is not None}


def condition_effect(condition, values, response="「请再确认一次。」"):
    return {
        "when": condition,
        "strategic_effects": values,
        "response": response,
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


def stage(stage_id, title, progress, kind, filler, interlude, cues, options):
    return {
        "id": stage_id,
        "title": title,
        "kind": kind,
        "stage_kind": "fixed",
        "progress_delta": progress,
        "transition_text": filler,
        "prompt": "确认完成当前阶段。" if kind == "confirm" else "选择下一步处理方式。",
        "options": options,
        "awake_interlude": interlude,
        "patient_cues": cues,
    }


def correction(stage_id, title, entry_condition, filler, interlude, cues, options):
    result = stage(stage_id, title, 0, "decision", filler, interlude, cues, options)
    result["stage_kind"] = "conditional_correction"
    result["entry_condition"] = entry_condition
    result["once_per_episode"] = True
    return result


def any_condition(*items):
    return {"any": list(items)}


def all_condition(*items):
    return {"all": list(items)}


def field_condition(field, op, value):
    return {"field": field, "op": op, "value": value}


def fixed_stage_progress(stages):
    return [step["progress_delta"] for step in stages if step["stage_kind"] != "conditional_correction"]


def splenectomy_stages():
    low_visibility_75 = field_condition("visibility", "lt", 75)
    bleeding_18 = field_condition("bleeding", "gte", 18)
    bleeding_22 = field_condition("bleeding", "gte", 22)
    bleeding_26 = field_condition("bleeding", "gte", 26)
    bleeding_36 = field_condition("bleeding", "gte", 36)
    return [
        stage("splenectomy_01_entry", "腹腔进入 / 左上腹进入", 11, "confirm",
              "腹腔进入以后，{assistant_name}把牵开方向转向左上腹，{scrub_name}按顺序递入牵开、吸引和基础止血器械；{circulator_name}调整灯光并记录进入主要手术阶段的时间。脾脏所在区域逐渐进入术野。",
              "operative_contact", ["incision", "exposure"], [
                  option("splenectomy_confirm_entry", "确认左上腹已经进入，继续", effects(elapsed_time=12, bleeding=1, blood_loss=4)),
              ]),
        stage("splenectomy_02_exposure", "建立脾脏暴露 / 确认周围关系", 11, "decision",
              "{assistant_name}逐步调整胃、结肠和脾脏周围的牵开，使脾下极和外侧轮廓能够更完整地观察；{scrub_name}保持吸引与纱布待用，{circulator_name}根据术野重新调整灯光。团队先确认脾脏大小、活动度以及与周围组织的关系。",
              "ongoing_interaction", ["pressure", "exposure"], [
                  option("splenectomy_complete_exposure", "先把左上腹暴露做完整，再开始游离", effects(elapsed_time=16, visibility=12, bleeding=1, blood_loss=5)),
                  option("splenectomy_current_exposure", "当前暴露足够，直接进入脾脏游离", effects(elapsed_time=13, visibility=4, bleeding=2, blood_loss=6)),
              ]),
        stage("splenectomy_03_inferolateral_mobilization", "游离下方 / 外侧附着", 11, "decision",
              "脾下极和外侧附着已经进入操作范围。{assistant_name}控制脾脏方向，让组织张力保持稳定；{scrub_name}随着分离进度递入吸引、纱布和止血器械。附着逐渐松开以后，脾脏开始获得更大的活动度。",
              "strain_interaction", ["traction", "pressure"], [
                  option("splenectomy_careful_mobilization", "沿层次逐步松解附着，始终保持边界清楚", effects(elapsed_time=20, visibility=10, bleeding=-2, blood_loss=7)),
                  option("splenectomy_standard_mobilization", "按正常节奏完成下方和外侧游离", effects(elapsed_time=16, visibility=3, bleeding=4, blood_loss=9)),
                  option("splenectomy_fast_mobilization", "在当前暴露下加快游离", effects(elapsed_time=12, visibility=-5, bleeding=9, blood_loss=13), [condition_effect(all_condition(low_visibility_75), effects(bleeding=5, blood_loss=5, stability=-4))]),
              ]),
        stage("splenectomy_04_gastrosplenic_control", "胃脾 / 短胃血管处理", 11, "decision",
              "随着脾脏能够向内侧移动，胃与脾脏之间的附着和短胃血管进入清楚视野。{assistant_name}维持胃壁和脾脏之间的距离，{scrub_name}准备逐段控制血管所需器械；{circulator_name}保持备用止血材料随时可用。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("splenectomy_careful_gastrosplenic", "逐段控制短胃血管并保持胃壁与脾脏关系清楚", effects(elapsed_time=21, visibility=6, bleeding=-6, blood_loss=8)),
                  option("splenectomy_standard_gastrosplenic", "按正常节奏完成胃脾侧血管处理", effects(elapsed_time=17, visibility=2, bleeding=4, blood_loss=11)),
                  option("splenectomy_fast_gastrosplenic", "减少中间复核，尽快处理胃脾侧附着", effects(elapsed_time=12, visibility=-6, bleeding=10, blood_loss=16), [condition_effect(any_condition(field_condition("visibility", "lt", 75), bleeding_18), effects(bleeding=6, blood_loss=7, stability=-5))]),
              ]),
        stage("splenectomy_05_posterosuperior_mobilization", "游离后方 / 上方附着", 11, "decision",
              "前方和下方附着已经逐渐解除，{assistant_name}轻轻改变脾脏方向，使后方和上方剩余附着进入术野；{scrub_name}配合完成最后一轮分离和局部止血。完成以后，脾门能够更加直接地进入视野。",
              "strain_interaction", ["traction", "pressure"], [
                  option("splenectomy_complete_posterosuperior", "继续整理后方附着，把脾门暴露做清楚", effects(elapsed_time=14, visibility=8, bleeding=-2, blood_loss=5)),
                  option("splenectomy_current_posterosuperior", "现有活动度已经足够，直接准备处理脾门", effects(elapsed_time=11, visibility=3, bleeding=1, blood_loss=6)),
              ]),
        stage("splenectomy_06_hilar_control", "脾门显露与控制", 11, "decision",
              "脾脏已经具有足够活动度。{assistant_name}把脾门维持在稳定位置，同时避免过度牵拉邻近组织；{scrub_name}准备血管控制与追加止血所需器械。真正决定这台手术能否平稳进入结束阶段的脾门处理开始了。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("splenectomy_careful_hilar", "重新确认脾门关系，分步完成血管控制", effects(elapsed_time=24, visibility=5, bleeding=-10, blood_loss=9)),
                  option("splenectomy_standard_hilar", "按正常节奏完成脾门控制", effects(elapsed_time=19, bleeding=4, blood_loss=13)),
                  option("splenectomy_fast_hilar", "减少中间调整，快速完成脾门处理", effects(elapsed_time=13, visibility=-8, bleeding=13, blood_loss=20), [condition_effect(any_condition(field_condition("visibility", "lt", 72), bleeding_22), effects(bleeding=5, blood_loss=10, stability=-7))]),
              ]),
        stage("splenectomy_07_specimen_handoff", "脾脏取出 / 标本交接", 11, "confirm",
              "脾门控制完成以后，剩余附着被确认已经解除，脾脏离开术野。{scrub_name}接收标本并交由 {circulator_name} 完成外围标记与送检记录；{assistant_name}则立刻重新显露脾床，为最终复核做准备。",
              "ongoing_interaction", ["pressure"], [
                  option("splenectomy_confirm_specimen", "确认标本离开术野，进入脾床复核", effects(elapsed_time=7, blood_loss=3)),
              ]),
        correction("splenectomy_correction", "脾床重新显露 / 追加止血",
                   any_condition(field_condition("visibility", "lt", 70), bleeding_26),
                   "脾脏虽然已经取出，但当前脾床仍然不够干净。{assistant_name}重新把左上腹深部显露出来，{scrub_name}准备吸引、纱布和追加止血器械；{circulator_name}记录额外处理时间并补充耗材。",
                   "ongoing_interaction", ["pressure", "deep_manipulation"], [
                       option("splenectomy_correction_clean", "重新显露脾床，把持续出血和术野问题处理干净", effects(elapsed_time=16, visibility=18, bleeding=-20, blood_loss=8, stability=3)),
                       option("splenectomy_correction_minimal", "只做最低限度止血，把剩余问题留给最终复核", effects(elapsed_time=8, visibility=5, bleeding=-8, blood_loss=11, stability=-2), [condition_effect(all_condition(bleeding_36), effects(blood_loss=12, stability=-6, add_complications=[{"id": "active_splenic_bed_bleeding", "severity": "minor"}]))]),
                   ]),
        stage("splenectomy_08_final_review", "脾床 / 邻近结构 / 止血最终复核", 11, "decision",
              "脾床完整暴露以后，{assistant_name}逐步改变牵开角度，让脾门残端和邻近区域都进入视野；{scrub_name}配合完成最后的吸引与止血。团队在关闭以前确认这里没有留下仍需处理的问题。",
              "progress_check", ["pressure"], [
                  option("splenectomy_complete_review", "完整复核脾床和邻近区域后再关闭", effects(elapsed_time=15, visibility=5, bleeding=-18, blood_loss=5, stability=2)),
                  option("splenectomy_focus_review", "重点检查当前风险区域，状态可接受就结束", effects(elapsed_time=11, bleeding=-10, blood_loss=6), [condition_effect(all_condition(field_condition("bleeding", "gte", 22)), effects(blood_loss=10, stability=-6, add_complications=[{"id": "residual_splenic_bed_bleeding", "severity": "minor"}]))]),
              ]),
        stage("splenectomy_09_closure", "腹壁关闭", 12, "confirm",
              "左上腹情况确认稳定以后，{scrub_name}完成最终清点并递入关闭器材，{assistant_name}协助逐层关闭腹壁；{circulator_name}完成手术记录并准备患者转运。",
              "closure_interaction", ["closure"], [
                  option("splenectomy_complete_closure", "完成关闭，结束手术", effects(elapsed_time=11, blood_loss=3)),
              ]),
    ]


def distal_gastrectomy_stages():
    low_visibility_72 = field_condition("visibility", "lt", 72)
    low_visibility_75 = field_condition("visibility", "lt", 75)
    bleeding_20 = field_condition("bleeding", "gte", 20)
    bleeding_24 = field_condition("bleeding", "gte", 24)
    bleeding_28 = field_condition("bleeding", "gte", 28)
    bleeding_36 = field_condition("bleeding", "gte", 36)
    recheck = field_condition("reconstruction_recheck_required", "eq", True)
    return [
        stage("gastrectomy_01_entry", "上腹部进入 / 初始暴露", 8, "confirm",
              "腹腔进入以后，{assistant_name}把牵开重点转向上腹部，{scrub_name}整理胃部手术阶段需要的吸引、牵开和止血器械；{circulator_name}重新调整灯光。远端胃和周围区域逐渐进入术野。",
              "operative_contact", ["incision", "exposure"], [option("gastrectomy_confirm_entry", "确认上腹部已经进入，继续", effects(elapsed_time=12, bleeding=1, blood_loss=5))]),
        stage("gastrectomy_02_boundaries", "确认病变与切除边界", 8, "decision",
              "{assistant_name}调整胃的位置，让病变区域、远端胃和预计保留的胃体能够同时观察；{scrub_name}保持标记和分离器械待用。真正开始游离以前，团队重新确认切除范围和后续重建需要留下的条件。",
              "ongoing_interaction", ["pressure", "exposure"], [
                  option("gastrectomy_complete_boundaries", "完整复核病变位置和计划切除边界", effects(elapsed_time=15, visibility=10, bleeding=1, blood_loss=5)),
                  option("gastrectomy_current_boundaries", "术前计划与当前术野一致，按当前范围继续", effects(elapsed_time=12, visibility=4, bleeding=2, blood_loss=6)),
              ]),
        stage("gastrectomy_03_greater_curvature", "大弯侧 / 下方附着游离", 8, "decision",
              "切除范围确定以后，{assistant_name}沿大弯侧维持稳定牵拉，{scrub_name}配合逐段分离、吸引和止血。随着胃大弯侧附着逐渐松开，远端胃获得更大的活动度。",
              "strain_interaction", ["traction", "pressure"], [
                  option("gastrectomy_careful_greater_curvature", "沿清楚层次逐步完成大弯侧游离", effects(elapsed_time=20, visibility=10, bleeding=-2, blood_loss=7)),
                  option("gastrectomy_standard_greater_curvature", "按正常节奏完成大弯侧游离", effects(elapsed_time=16, visibility=3, bleeding=4, blood_loss=10)),
                  option("gastrectomy_fast_greater_curvature", "在当前暴露下加快大弯侧分离", effects(elapsed_time=12, visibility=-5, bleeding=9, blood_loss=14), [condition_effect(all_condition(field_condition("visibility", "lt", 75)), effects(bleeding=5, blood_loss=5, stability=-3))]),
              ]),
        stage("gastrectomy_04_distal_mobilization", "远端胃 / 十二指肠侧游离", 8, "decision",
              "远端胃已经能够被进一步抬起，幽门和十二指肠侧关系逐渐清楚。{assistant_name}保持胃和邻近组织之间的张力，{scrub_name}准备下一阶段的分离与止血器械；{circulator_name}保持重建材料和备用耗材可随时取得。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("gastrectomy_careful_distal", "先把幽门与十二指肠侧关系充分游离清楚", effects(elapsed_time=20, visibility=8, bleeding=-2, blood_loss=8)),
                  option("gastrectomy_standard_distal", "按正常节奏完成远端侧游离", effects(elapsed_time=16, visibility=2, bleeding=4, blood_loss=10)),
                  option("gastrectomy_fast_distal", "减少中间调整，尽快获得远端活动度", effects(elapsed_time=12, visibility=-6, bleeding=10, blood_loss=15), [condition_effect(all_condition(low_visibility_72), effects(bleeding=6, blood_loss=6, stability=-4))]),
              ]),
        stage("gastrectomy_05_lesser_curvature", "小弯侧 / 血管控制", 8, "decision",
              "胃小弯侧和主要供血处理区域进入术野以后，{assistant_name}重新安排牵拉，使血管与胃壁关系保持清楚；{scrub_name}连续提供血管控制和止血器械。切除真正开始以前，需要先把这一侧控制稳定。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("gastrectomy_careful_vascular", "分段确认并完成小弯侧血管控制", effects(elapsed_time=23, visibility=5, bleeding=-8, blood_loss=10)),
                  option("gastrectomy_standard_vascular", "按正常节奏完成主要血管控制", effects(elapsed_time=18, bleeding=4, blood_loss=14)),
                  option("gastrectomy_fast_vascular", "减少中间复核，加快血管处理", effects(elapsed_time=13, visibility=-6, bleeding=12, blood_loss=20), [condition_effect(any_condition(field_condition("visibility", "lt", 75), bleeding_20), effects(bleeding=5, blood_loss=8, stability=-6))]),
              ]),
        stage("gastrectomy_06_distal_division", "远端边界 / 十二指肠侧切断", 8, "decision",
              "远端侧已经具备切断条件。{assistant_name}维持胃和十二指肠方向稳定，{scrub_name}准备完成远端切断与残端处理所需器械。此前的游离和血管控制是否充分，会直接影响这一阶段是否从容。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("gastrectomy_confirm_distal_division", "再确认远端边界与周围关系后完成切断", effects(elapsed_time=13, visibility=4, bleeding=-2, blood_loss=6)),
                  option("gastrectomy_standard_distal_division", "按当前确认结果完成远端切断", effects(elapsed_time=10, bleeding=2, blood_loss=7)),
              ]),
        stage("gastrectomy_07_proximal_resection", "近端胃切断 / 完成切除", 8, "decision",
              "远端侧已经完成处理，{assistant_name}重新展开预定的近端胃切除线，{scrub_name}准备完成胃体切断和标本分离。切除线一旦完成，远端胃就会作为完整标本离开术野。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("gastrectomy_careful_proximal", "重新确认近端切除线，再完整完成切除", effects(elapsed_time=19, visibility=5, bleeding=-5, blood_loss=8)),
                  option("gastrectomy_standard_proximal", "按计划切除线完成胃体切断", effects(elapsed_time=15, bleeding=3, blood_loss=10)),
                  option("gastrectomy_fast_proximal", "按当前暴露尽快完成近端切断", effects(elapsed_time=11, visibility=-5, bleeding=8, blood_loss=15), [condition_effect(all_condition(low_visibility_72), effects(bleeding=4, blood_loss=5, stability=-3))]),
              ]),
        stage("gastrectomy_08_specimen_handoff", "标本交接 / 重整术野", 8, "confirm",
              "远端胃离开术野以后，{scrub_name}接收标本并交由 {circulator_name} 完成外围标记和送检记录。{assistant_name}重新整理残胃和肠道位置，手术从“切除”正式转入“重建”。",
              "ongoing_interaction", ["pressure"], [option("gastrectomy_confirm_specimen", "确认标本交接完成，进入重建准备", effects(elapsed_time=6, blood_loss=3))]),
        stage("gastrectomy_09_reconstruction_prep", "重建准备 / 张力与位置确认", 8, "decision",
              "重建开始以前，{assistant_name}把残胃和预定吻合的消化道重新带入自然位置，确认两端能够在不过度牵拉的情况下靠近；{scrub_name}准备吻合和缝合材料。团队先把“能不能顺畅接上”确认清楚，再真正建立新的通路。",
              "strain_interaction", ["traction", "pressure"], [
                  option("gastrectomy_complete_reconstruction_prep", "完整调整残胃和肠段位置，确认长度与张力", effects(elapsed_time=16, visibility=8, bleeding=-2, blood_loss=4)),
                  option("gastrectomy_current_reconstruction_prep", "当前条件合适，按计划进入吻合", effects(elapsed_time=13, visibility=3, bleeding=1, blood_loss=5), [condition_effect(all_condition(low_visibility_72), effects(set_flags=["reconstruction_recheck_required"]))]),
              ]),
        stage("gastrectomy_10_anastomosis", "建立重建吻合", 8, "decision",
              "两端位置确定以后，重建正式开始。{assistant_name}持续保持残胃和肠段方向稳定，避免吻合过程中出现扭转或过度张力；{scrub_name}按照坂口的节奏递入吻合与关闭材料。新的消化道连续性逐渐建立起来。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("gastrectomy_careful_anastomosis", "分步确认对合与张力，稳妥完成重建", effects(elapsed_time=30, visibility=4, bleeding=-6, blood_loss=7, clear_flags=["reconstruction_recheck_required"])),
                  option("gastrectomy_standard_anastomosis", "按正常节奏完成吻合", effects(elapsed_time=24, bleeding=2, blood_loss=9)),
                  option("gastrectomy_fast_anastomosis", "减少中间调整，尽快完成重建", effects(elapsed_time=17, visibility=-7, bleeding=7, blood_loss=13), [condition_effect(any_condition(field_condition("visibility", "lt", 75), bleeding_24, recheck), effects(stability=-3, set_flags=["reconstruction_recheck_required"]))]),
              ]),
        correction("gastrectomy_correction", "吻合区重新显露 / 修整",
                   any_condition(field_condition("visibility", "lt", 70), bleeding_28, recheck),
                   "重建已经完成主体，但当前吻合区仍有一处不能让人完全放心。{assistant_name}重新显露整个吻合区域，{scrub_name}准备追加缝合、止血和修整材料；{circulator_name}记录返工时间并补充耗材。",
                   "ongoing_interaction", ["pressure", "deep_manipulation"], [
                       option("gastrectomy_correction_complete", "重新完整显露吻合区，完成必要修整和止血", effects(elapsed_time=20, visibility=15, bleeding=-18, blood_loss=8, stability=2, clear_flags=["reconstruction_recheck_required"])),
                       option("gastrectomy_correction_focus", "只修整最需要处理的位置，尽快进入最终复核", effects(elapsed_time=11, visibility=5, bleeding=-8, blood_loss=10, clear_flags=["reconstruction_recheck_required"]), [condition_effect(all_condition(bleeding_36), effects(blood_loss=10, stability=-6, add_complications=[{"id": "reconstruction_rework", "severity": "minor"}]))]),
                   ]),
        stage("gastrectomy_11_final_review", "吻合 / 切除床 / 止血最终复核", 8, "decision",
              "重建完成以后，{assistant_name}依次显露吻合区和原切除区域，{scrub_name}配合完成最后止血和必要的追加处理。关闭以前，团队要确认切除与重建两半都已经稳定结束。",
              "progress_check", ["pressure"], [
                  option("gastrectomy_complete_review", "完整复核吻合区和原切除区域后再关闭", effects(elapsed_time=20, visibility=4, bleeding=-16, blood_loss=7, stability=2, clear_flags=["reconstruction_recheck_required"])),
                  option("gastrectomy_focus_review", "重点复核，状态可接受就进入关闭", effects(elapsed_time=15, bleeding=-8, blood_loss=8), [condition_effect(any_condition(recheck, field_condition("bleeding", "gte", 24)), effects(elapsed_time=7, blood_loss=8, stability=-5, clear_flags=["reconstruction_recheck_required"], add_complications=[{"id": "reconstruction_rework", "severity": "minor"}]))]),
              ]),
        stage("gastrectomy_12_closure", "腹壁关闭", 12, "confirm",
              "上腹部情况确认稳定以后，{scrub_name}完成最终清点并递入关闭器材，{assistant_name}协助逐层关闭腹壁；{circulator_name}完成标本、重建方式和手术时间记录，并准备患者转运。",
              "closure_interaction", ["closure"], [option("gastrectomy_complete_closure", "完成关闭，结束手术", effects(elapsed_time=15, blood_loss=4))]),
    ]


def hysterectomy_stages():
    low_visibility_68 = field_condition("visibility", "lt", 68)
    low_visibility_72 = field_condition("visibility", "lt", 72)
    low_visibility_75 = field_condition("visibility", "lt", 75)
    bleeding_18 = field_condition("bleeding", "gte", 18)
    bleeding_22 = field_condition("bleeding", "gte", 22)
    bleeding_24 = field_condition("bleeding", "gte", 24)
    bleeding_26 = field_condition("bleeding", "gte", 26)
    bleeding_30 = field_condition("bleeding", "gte", 30)
    bleeding_38 = field_condition("bleeding", "gte", 38)
    recheck = field_condition("cuff_recheck_required", "eq", True)
    return [
        stage("hysterectomy_01_entry", "开腹 / 建立盆腔术野", 8, "confirm",
              "腹腔进入以后，{assistant_name}把牵开重点转向盆腔，{scrub_name}整理妇科手术阶段需要的牵开、分离和止血器械；{circulator_name}调整灯光并记录进入主要阶段的时间。子宫和双侧附件逐渐进入术野。",
              "operative_contact", ["incision", "exposure"], [option("hysterectomy_confirm_entry", "确认盆腔已经进入，继续", effects(elapsed_time=16, bleeding=1, blood_loss=6))]),
        stage("hysterectomy_02_pelvic_inspection", "检查子宫 / 附件 / 粘连与活动度", 8, "decision",
              "{assistant_name}调整子宫位置，让子宫体、附件和盆腔侧壁都能被观察；{scrub_name}保持分离器械待用。团队先确认子宫大小、活动度以及有没有会影响后续路线的粘连。",
              "dignity_interaction", ["exposure", "pressure"], [
                  option("hysterectomy_complete_inspection", "完整检查盆腔关系并先整理妨碍暴露的部分", effects(elapsed_time=20, visibility=12, bleeding=1, blood_loss=6)),
                  option("hysterectomy_current_inspection", "当前关系清楚，按计划直接进入子宫游离", effects(elapsed_time=16, visibility=4, bleeding=2, blood_loss=8)),
              ]),
        stage("hysterectomy_03_ligament_access", "圆韧带 / 阔韧带入路", 8, "decision",
              "子宫已经能够被稳定牵引。{assistant_name}维持一侧盆腔暴露，{scrub_name}配合打开进入阔韧带区域的操作层次；完成后，后续膀胱分离和血管处理需要的空间逐渐建立起来。",
              "dignity_interaction", ["exposure", "traction"], [
                  option("hysterectomy_complete_ligament_access", "先把两侧层次充分打开，再向深部推进", effects(elapsed_time=18, visibility=8, bleeding=1, blood_loss=6)),
                  option("hysterectomy_current_ligament_access", "按当前暴露进入下一阶段", effects(elapsed_time=14, visibility=3, bleeding=2, blood_loss=8)),
              ]),
        stage("hysterectomy_04_bladder_mobilization", "膀胱下推 / 宫颈前方游离", 8, "decision",
              "下段子宫和宫颈前方进入术野以后，{assistant_name}保持子宫向上牵引，让膀胱和宫颈之间的层次逐渐显现；{scrub_name}配合精细分离和局部止血。只有膀胱真正离开预定切除区域，后面的操作才有足够空间。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("hysterectomy_careful_bladder", "沿清楚层次逐步下推膀胱，充分显露下段子宫", effects(elapsed_time=26, visibility=10, bleeding=-2, blood_loss=8)),
                  option("hysterectomy_standard_bladder", "按正常节奏完成膀胱游离", effects(elapsed_time=22, visibility=3, bleeding=4, blood_loss=12)),
                  option("hysterectomy_fast_bladder", "在当前层次下加快膀胱游离", effects(elapsed_time=16, visibility=-6, bleeding=9, blood_loss=17), [condition_effect(all_condition(low_visibility_75), effects(bleeding=5, blood_loss=5, stability=-4))]),
              ]),
        stage("hysterectomy_05_adnexal_pedicles", "保留卵巢的附件侧蒂处理", 8, "decision",
              "膀胱已经向下移开，{assistant_name}依次显露子宫上方与附件连接区域；{scrub_name}准备血管控制和止血材料。因为这台手术默认保留卵巢，团队需要在切断子宫侧连接的同时，把保留侧组织关系维持清楚。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("hysterectomy_careful_adnexal", "逐侧确认保留结构并分步完成蒂部控制", effects(elapsed_time=26, visibility=8, bleeding=-5, blood_loss=10)),
                  option("hysterectomy_standard_adnexal", "按正常节奏完成两侧子宫侧附件蒂处理", effects(elapsed_time=22, visibility=2, bleeding=4, blood_loss=15)),
                  option("hysterectomy_fast_adnexal", "减少中间调整，快速完成两侧处理", effects(elapsed_time=16, visibility=-6, bleeding=11, blood_loss=21), [condition_effect(any_condition(low_visibility_75, bleeding_18), effects(bleeding=5, blood_loss=8, stability=-5))]),
              ]),
        stage("hysterectomy_06_ureter_vessels", "输尿管走行确认 / 子宫血管准备", 8, "decision",
              "进入子宫血管处理以前，{assistant_name}重新调整侧壁暴露，使输尿管走行和子宫血管区域能够同时确认；{scrub_name}保持血管控制器械待用。这个阶段本身不追求速度，而是把下一步需要的关系重新对齐。",
              "dignity_interaction", ["exposure", "pressure"], [
                  option("hysterectomy_complete_ureter_review", "完整确认盆腔侧壁关系，再进入子宫血管处理", effects(elapsed_time=20, visibility=8, bleeding=-2, blood_loss=5)),
                  option("hysterectomy_current_ureter_review", "当前关系明确，按计划进入血管控制", effects(elapsed_time=16, visibility=3, bleeding=1, blood_loss=6)),
              ]),
        stage("hysterectomy_07_uterine_vessels", "子宫血管控制", 8, "decision",
              "子宫血管已经进入清楚视野。{assistant_name}稳定子宫和侧壁之间的张力，{scrub_name}连续提供血管控制与追加止血器械；{circulator_name}保持备用材料随时可取得。真正的大出血压力集中在这一阶段。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("hysterectomy_careful_vessels", "逐侧确认并完整控制子宫血管", effects(elapsed_time=32, visibility=5, bleeding=-10, blood_loss=16)),
                  option("hysterectomy_standard_vessels", "按正常节奏完成双侧血管控制", effects(elapsed_time=26, bleeding=5, blood_loss=22)),
                  option("hysterectomy_fast_vessels", "减少中间复核，加快完成血管处理", effects(elapsed_time=18, visibility=-7, bleeding=14, blood_loss=30), [condition_effect(any_condition(low_visibility_75, field_condition("bleeding", "gte", 24)), effects(bleeding=6, blood_loss=12, stability=-8))]),
              ]),
        stage("hysterectomy_08_support_structures", "主韧带 / 骶韧带支持结构处理", 8, "decision",
              "血管控制稳定以后，子宫已经明显失去侧方固定。{assistant_name}继续向上牵引子宫，使宫颈周围支持组织依次进入操作范围；{scrub_name}配合分离、止血和结扎。完成这一阶段后，子宫只剩最后的下方连接需要处理。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("hysterectomy_careful_support", "保持宫颈周围层次清楚，逐步处理支持结构", effects(elapsed_time=26, visibility=5, bleeding=-6, blood_loss=12)),
                  option("hysterectomy_standard_support", "按正常节奏完成宫颈周围支持结构处理", effects(elapsed_time=22, bleeding=4, blood_loss=16)),
                  option("hysterectomy_fast_support", "加快完成支持结构处理", effects(elapsed_time=16, visibility=-5, bleeding=10, blood_loss=22), [condition_effect(all_condition(low_visibility_72), effects(bleeding=5, blood_loss=6, stability=-4))]),
              ]),
        stage("hysterectomy_09_removal", "完成环周切开 / 取出子宫", 8, "confirm",
              "宫颈周围已经完全进入可处理范围。完成最后的环周切开以后，子宫从盆腔中取出。{scrub_name}接收标本并交由 {circulator_name} 完成外围标记和送检记录；{assistant_name}立即重新显露阴道残端和盆腔底部。",
              "dignity_interaction", ["exposure", "deep_manipulation"], [option("hysterectomy_confirm_removal", "确认子宫已经取出，进入阴道残端关闭", effects(elapsed_time=10, blood_loss=5))]),
        stage("hysterectomy_10_cuff_closure", "阴道残端关闭 / 盆腔支持恢复", 8, "decision",
              "子宫已经离开术野，接下来要把开放的阴道残端重新关闭并恢复稳定。{assistant_name}控制两侧组织张力，{scrub_name}连续递入缝线和止血材料；随着关闭推进，盆腔底部逐渐恢复完整。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("hysterectomy_careful_cuff", "控制张力，分步完成残端关闭并充分复核", effects(elapsed_time=30, visibility=4, bleeding=-10, blood_loss=8, clear_flags=["cuff_recheck_required"])),
                  option("hysterectomy_standard_cuff", "按正常节奏完成阴道残端关闭", effects(elapsed_time=24, bleeding=-4, blood_loss=10), [condition_effect(all_condition(low_visibility_68), effects(set_flags=["cuff_recheck_required"]))]),
                  option("hysterectomy_fast_cuff", "压缩中间复核，尽快完成残端关闭", effects(elapsed_time=17, visibility=-6, bleeding=3, blood_loss=15), [condition_effect(any_condition(low_visibility_75, field_condition("bleeding", "gte", 22)), effects(stability=-3, set_flags=["cuff_recheck_required"]))]),
              ]),
        correction("hysterectomy_correction", "阴道残端 / 盆腔重新显露与追加止血",
                   any_condition(field_condition("visibility", "lt", 70), bleeding_30, recheck),
                   "阴道残端已经完成主要关闭，但当前盆腔情况还不够理想。{assistant_name}重新显露残端和两侧血管处理区域，{scrub_name}准备追加缝合、吸引和止血器械；{circulator_name}记录返工时间并补充耗材。",
                   "ongoing_interaction", ["pressure", "exposure", "deep_manipulation"], [
                       option("hysterectomy_correction_complete", "重新完整显露残端和两侧处理区，完成追加止血与返工", effects(elapsed_time=20, visibility=15, bleeding=-18, blood_loss=8, stability=2, clear_flags=["cuff_recheck_required"])),
                       option("hysterectomy_correction_focus", "只处理最需要调整的位置，尽快进入最终盆腔复核", effects(elapsed_time=11, visibility=5, bleeding=-10, blood_loss=12, clear_flags=["cuff_recheck_required"]), [condition_effect(all_condition(bleeding_38), effects(blood_loss=10, stability=-6, add_complications=[{"id": "cuff_rework", "severity": "minor"}]))]),
                   ]),
        stage("hysterectomy_11_final_review", "盆腔 / 泌尿结构 / 止血最终复核", 8, "decision",
              "主要切除与关闭都已经完成。{assistant_name}依次改变牵开角度，让阴道残端、两侧盆腔以及先前处理过的区域重新进入视野；{scrub_name}配合完成冲洗和最后止血。关闭腹壁以前，团队确认盆腔整体稳定。",
              "progress_check", ["pressure"], [
                  option("hysterectomy_complete_review", "完整复核阴道残端、两侧盆腔和止血状态", effects(elapsed_time=22, visibility=5, bleeding=-18, blood_loss=8, stability=2, clear_flags=["cuff_recheck_required"])),
                  option("hysterectomy_focus_review", "重点复核当前风险区域，状态可接受就关闭腹壁", effects(elapsed_time=17, bleeding=-9, blood_loss=9), [condition_effect(any_condition(recheck, bleeding_26), effects(elapsed_time=7, blood_loss=8, stability=-5, clear_flags=["cuff_recheck_required"], add_complications=[{"id": "cuff_rework", "severity": "minor"}]))]),
              ]),
        stage("hysterectomy_12_closure", "腹壁关闭", 12, "confirm",
              "盆腔确认稳定以后，{scrub_name}完成最终清点并递入关闭器材，{assistant_name}协助逐层关闭腹壁；{circulator_name}完成标本、手术时间和术后转运记录。",
              "closure_interaction", ["closure"], [option("hysterectomy_complete_closure", "完成关闭，结束手术", effects(elapsed_time=18, blood_loss=5))]),
    ]


def hemicolectomy_stages():
    low_visibility_72 = field_condition("visibility", "lt", 72)
    low_visibility_75 = field_condition("visibility", "lt", 75)
    low_visibility_80 = field_condition("visibility", "lt", 80)
    bleeding_20 = field_condition("bleeding", "gte", 20)
    bleeding_24 = field_condition("bleeding", "gte", 24)
    bleeding_28 = field_condition("bleeding", "gte", 28)
    bleeding_36 = field_condition("bleeding", "gte", 36)
    recheck = field_condition("anastomosis_recheck_required", "eq", True)
    return [
        stage("hemicolectomy_01_entry", "腹腔进入 / 右侧结肠暴露", 8, "confirm",
              "腹腔进入以后，{assistant_name}把牵开重点转向右侧腹腔，{scrub_name}整理结肠手术阶段需要的牵开、分离和止血器械；{circulator_name}重新调整灯光。盲肠、升结肠和病变所在区域逐渐进入术野。",
              "operative_contact", ["incision", "exposure"], [option("hemicolectomy_confirm_entry", "确认右侧结肠已经进入，继续", effects(elapsed_time=12, bleeding=1, blood_loss=5))]),
        stage("hemicolectomy_02_boundaries", "确认病变与切除肠段边界", 8, "decision",
              "{assistant_name}调整右侧结肠的位置，让病变段以及预定保留的近端、远端肠段都能被观察；{scrub_name}保持标记和分离器械待用。真正开始游离以前，团队先把切除范围重新确认清楚。",
              "ongoing_interaction", ["pressure", "exposure"], [
                  option("hemicolectomy_complete_boundaries", "完整复核病变位置和近远端切除边界", effects(elapsed_time=15, visibility=10, bleeding=1, blood_loss=5)),
                  option("hemicolectomy_current_boundaries", "与术前计划一致，按当前范围继续", effects(elapsed_time=12, visibility=4, bleeding=2, blood_loss=6)),
              ]),
        stage("hemicolectomy_03_lateral_mobilization", "右侧结肠外侧游离", 8, "decision",
              "右侧结肠开始从腹壁和后方组织上被逐步游离。{assistant_name}向内侧维持稳定牵拉，让外侧分离层次保持可见；{scrub_name}配合吸引、分离和局部止血。随着游离向上推进，右侧结肠获得越来越大的活动度。",
              "strain_interaction", ["traction", "pressure"], [
                  option("hemicolectomy_careful_lateral", "沿层次逐步游离，保持后方平面清楚", effects(elapsed_time=20, visibility=10, bleeding=-2, blood_loss=7)),
                  option("hemicolectomy_standard_lateral", "按正常节奏完成外侧游离", effects(elapsed_time=16, visibility=3, bleeding=4, blood_loss=10)),
                  option("hemicolectomy_fast_lateral", "在当前暴露下加快外侧游离", effects(elapsed_time=12, visibility=-5, bleeding=9, blood_loss=14), [condition_effect(all_condition(low_visibility_75), effects(bleeding=5, blood_loss=5, stability=-3))]),
              ]),
        stage("hemicolectomy_04_hepatic_flexure", "肝曲 / 近端横结肠侧游离", 8, "decision",
              "游离继续向肝曲推进。{assistant_name}重新安排胃、结肠和肝下区域的牵开，使肝曲逐渐放松；{scrub_name}配合完成上方附着的分离和止血。完成以后，右半结肠可以更自然地向内侧移动。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("hemicolectomy_careful_hepatic_flexure", "先充分显露肝曲，再逐步完成上方游离", effects(elapsed_time=20, visibility=8, bleeding=-2, blood_loss=8)),
                  option("hemicolectomy_standard_hepatic_flexure", "按正常节奏完成肝曲游离", effects(elapsed_time=16, visibility=2, bleeding=4, blood_loss=10)),
                  option("hemicolectomy_fast_hepatic_flexure", "减少中间调整，加快完成肝曲游离", effects(elapsed_time=12, visibility=-6, bleeding=10, blood_loss=15), [condition_effect(all_condition(low_visibility_72), effects(bleeding=6, blood_loss=6, stability=-4))]),
              ]),
        stage("hemicolectomy_05_retroperitoneal_plane", "后方平面 / 保护结构确认", 8, "decision",
              "右半结肠已经具备较好活动度。{assistant_name}保持结肠向内侧牵开，让后方组织层次重新进入视野；{scrub_name}暂时放慢器械节奏。进入系膜和血管处理以前，团队先确认后方需要保护的结构已经清楚避开。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("hemicolectomy_complete_retroperitoneal", "完整确认后方层次与需要保护的结构，再进入系膜处理", effects(elapsed_time=14, visibility=8, bleeding=-2, blood_loss=5)),
                  option("hemicolectomy_current_retroperitoneal", "当前层次清楚，按计划进入系膜处理", effects(elapsed_time=11, visibility=3, bleeding=1, blood_loss=6)),
              ]),
        stage("hemicolectomy_06_mesenteric_control", "右半结肠系膜 / 血管蒂控制", 8, "decision",
              "切除范围已经完全明确，{assistant_name}抬起右半结肠系膜，使主要血管处理区域进入术野；{scrub_name}连续准备血管控制、吸引和追加止血器械。切除真正开始以前，必须先把这一段肠管的系膜和血供处理稳定。",
              "strain_interaction", ["traction", "deep_manipulation"], [
                  option("hemicolectomy_careful_mesenteric", "分段完成系膜和血管控制，保持切除范围清楚", effects(elapsed_time=24, visibility=5, bleeding=-8, blood_loss=10)),
                  option("hemicolectomy_standard_mesenteric", "按正常节奏完成系膜与主要血管控制", effects(elapsed_time=20, bleeding=4, blood_loss=16)),
                  option("hemicolectomy_fast_mesenteric", "减少中间复核，加快完成系膜处理", effects(elapsed_time=14, visibility=-6, bleeding=12, blood_loss=23), [condition_effect(any_condition(low_visibility_75, bleeding_20), effects(bleeding=5, blood_loss=8, stability=-6))]),
              ]),
        stage("hemicolectomy_07_bowel_division", "按计划边界切断肠管", 8, "decision",
              "系膜处理完成以后，预定的近端回肠和远端结肠切断位置重新进入视野。{assistant_name}保持两端肠管方向稳定，{scrub_name}准备完成切断和残端保护所需器械。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("hemicolectomy_confirm_bowel_division", "重新确认两端边界后完成切断", effects(elapsed_time=13, visibility=4, bleeding=-2, blood_loss=6)),
                  option("hemicolectomy_standard_bowel_division", "按当前确认结果完成切断", effects(elapsed_time=10, bleeding=2, blood_loss=7)),
              ]),
        stage("hemicolectomy_08_specimen_handoff", "标本取出 / 重整术野", 8, "confirm",
              "右半结肠标本完整离开术野。{scrub_name}接收标本并交给 {circulator_name} 完成外围标记和送检记录；{assistant_name}重新整理回肠和剩余结肠的位置。手术从“切除”转入“重建肠道连续性”。",
              "ongoing_interaction", ["pressure"], [option("hemicolectomy_confirm_specimen", "确认标本取出完成，进入吻合前准备", effects(elapsed_time=6, blood_loss=3))]),
        stage("hemicolectomy_09_anastomosis_prep", "准备回肠 / 结肠两端，确认灌注与张力", 8, "decision",
              "两端肠管被重新带到一起。{assistant_name}调整回肠和结肠方向，确认它们能够自然靠近而没有明显扭转或过度张力；{scrub_name}准备吻合材料。真正开始吻合以前，团队先判断当前条件是不是足够稳定。",
              "strain_interaction", ["traction", "pressure"], [
                  option("hemicolectomy_careful_anastomosis_prep", "充分调整两端位置，完整确认灌注、方向和张力", effects(elapsed_time=20, visibility=8, bleeding=-2, blood_loss=5, clear_flags=["anastomosis_recheck_required"])),
                  option("hemicolectomy_standard_anastomosis_prep", "按正常条件完成吻合前准备", effects(elapsed_time=16, visibility=3, bleeding=1, blood_loss=6), [condition_effect(all_condition(low_visibility_72), effects(set_flags=["anastomosis_recheck_required"]))]),
                  option("hemicolectomy_fast_anastomosis_prep", "减少位置调整，按当前条件直接进入吻合", effects(elapsed_time=12, visibility=-5, bleeding=4, blood_loss=8), [condition_effect(any_condition(low_visibility_80, bleeding_20), effects(set_flags=["anastomosis_recheck_required"]))]),
              ]),
        stage("hemicolectomy_10_anastomosis", "建立回肠结肠吻合", 8, "decision",
              "两端位置确认以后，吻合正式开始。{assistant_name}持续维持肠管方向和张力，{scrub_name}按照坂口的节奏递入吻合、关闭和追加缝合材料。原本分开的回肠和结肠逐渐重新形成连续通路。",
              "strain_interaction", ["pressure", "deep_manipulation"], [
                  option("hemicolectomy_careful_anastomosis", "反复确认对合与方向，稳妥完成吻合", effects(elapsed_time=30, visibility=4, bleeding=-6, blood_loss=7, clear_flags=["anastomosis_recheck_required"])),
                  option("hemicolectomy_standard_anastomosis", "按正常节奏完成吻合", effects(elapsed_time=24, bleeding=2, blood_loss=9)),
                  option("hemicolectomy_fast_anastomosis", "减少中间调整，尽快完成吻合", effects(elapsed_time=17, visibility=-7, bleeding=7, blood_loss=13), [condition_effect(any_condition(field_condition("visibility", "lt", 75), bleeding_24, recheck), effects(stability=-3, set_flags=["anastomosis_recheck_required"]))]),
              ]),
        correction("hemicolectomy_correction", "吻合区重新显露 / 修整",
                   any_condition(field_condition("visibility", "lt", 70), bleeding_28, recheck),
                   "吻合已经完成主体，但当前有一处还不能让人完全放心。{assistant_name}重新展开吻合区域，{scrub_name}准备追加缝合、吸引和止血材料；{circulator_name}记录额外处理时间并补充耗材。",
                   "ongoing_interaction", ["pressure", "deep_manipulation"], [
                       option("hemicolectomy_correction_complete", "重新完整显露吻合区，完成必要修整和止血", effects(elapsed_time=20, visibility=15, bleeding=-16, blood_loss=8, stability=2, clear_flags=["anastomosis_recheck_required"])),
                       option("hemicolectomy_correction_focus", "只处理最需要调整的位置，尽快进入最终复核", effects(elapsed_time=11, visibility=5, bleeding=-8, blood_loss=10, clear_flags=["anastomosis_recheck_required"]), [condition_effect(all_condition(bleeding_36), effects(blood_loss=10, stability=-6, add_complications=[{"id": "anastomosis_rework", "severity": "minor"}]))]),
                   ]),
        stage("hemicolectomy_11_final_review", "吻合 / 止血 / 全术野最终复核", 8, "decision",
              "重建完成以后，{assistant_name}依次改变牵开方向，让吻合区、系膜处理区域和右侧腹腔重新进入视野；{scrub_name}配合完成冲洗和最后止血。关闭以前，团队确认切除和重建两部分都已经稳定。",
              "progress_check", ["pressure"], [
                  option("hemicolectomy_complete_review", "完整复核吻合区、系膜区和右侧腹腔后再关闭", effects(elapsed_time=20, visibility=4, bleeding=-16, blood_loss=7, stability=2, clear_flags=["anastomosis_recheck_required"])),
                  option("hemicolectomy_focus_review", "重点复核当前风险区域，状态可接受就关闭", effects(elapsed_time=15, bleeding=-8, blood_loss=8), [condition_effect(any_condition(recheck, field_condition("bleeding", "gte", 24)), effects(elapsed_time=7, blood_loss=8, stability=-5, clear_flags=["anastomosis_recheck_required"], add_complications=[{"id": "anastomosis_rework", "severity": "minor"}]))]),
              ]),
        stage("hemicolectomy_12_closure", "腹壁关闭", 12, "confirm",
              "腹腔情况确认稳定以后，{scrub_name}完成最终清点并递入关闭器材，{assistant_name}协助逐层关闭腹壁；{circulator_name}完成标本、吻合和手术时间记录并准备患者转运。",
              "closure_interaction", ["closure"], [option("hemicolectomy_complete_closure", "完成关闭，结束手术", effects(elapsed_time=14, blood_loss=4))]),
    ]


def main():
    data = json.loads(PATH.read_text())
    stage_map = {
        "surgery_open_splenectomy": splenectomy_stages(),
        "surgery_open_distal_gastrectomy": distal_gastrectomy_stages(),
        "surgery_hysterectomy": hysterectomy_stages(),
        "surgery_open_right_hemicolectomy": hemicolectomy_stages(),
    }
    variants = {
        "surgery_open_splenectomy": [
            {"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "左上腹暴露以后，脾脏与周围组织的关系比较清楚，当前活动度也尚可。"},
            {"id": "dense_perisplenic_adhesions", "weight": 25, "initial_visibility": 72, "player_hint": "脾脏周围附着比预期更紧，外侧和胃脾之间的层次显得拥挤，真正进入脾门以前需要更多整理。"},
        ],
        "surgery_open_distal_gastrectomy": [
            {"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "上腹部暴露以后，远端胃和周围组织关系比较清楚，计划切除范围能够顺利进入术野。"},
            {"id": "dense_perigastric_adhesions", "weight": 25, "initial_visibility": 72, "player_hint": "远端胃周围附着比预期更紧，幽门侧和大弯区域的活动度受到限制，后面的游离会更依赖稳定暴露。"},
        ],
        "surgery_hysterectomy": [
            {"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "盆腔暴露以后，子宫和双侧附件关系较清楚，子宫活动度也足以按计划开始游离。"},
            {"id": "adhesive_pelvis", "weight": 25, "initial_visibility": 70, "player_hint": "盆腔内粘连明显，子宫活动度受限，膀胱侧和盆腔侧壁的层次都比普通病例更拥挤。"},
        ],
        "surgery_open_right_hemicolectomy": [
            {"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "右侧结肠暴露顺利，升结肠、肝曲和预计切除范围能够比较清楚地进入术野。"},
            {"id": "difficult_hepatic_flexure", "weight": 25, "initial_visibility": 72, "player_hint": "肝曲位置偏高而且周围附着较紧，右半结肠虽然已经显露，但向上游离时的空间明显比普通病例有限。"},
        ],
    }
    for surgery in data:
        surgery_id = surgery.get("id")
        if surgery_id not in stage_map:
            continue
        stages = stage_map[surgery_id]
        surgery["stages"] = stages
        surgery["case_variants"] = variants[surgery_id]
        surgery.setdefault("initial_state", {})["bleeding"] = 0
        surgery["fixed_stage_progress"] = fixed_stage_progress(stages)
    PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")


if __name__ == "__main__":
    main()
