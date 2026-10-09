import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "data/surgeries/surgeries.json"


def effects(**kwargs):
    return {key: value for key, value in kwargs.items() if value is not None}


def option(option_id, label, values, response="「明白，继续。」", conditional=None):
    item = {
        "id": option_id,
        "label": label,
        "response": response,
        "response_role": "assistant_surgeon",
        "correct": True,
        "correction": "",
        "strategic_effects": values,
    }
    if conditional:
        item["conditional_effects"] = conditional
    return item


def condition_effect(condition, values, response=""):
    result = {"when": condition, "strategic_effects": values}
    if response:
        result["response"] = response
        result["response_role"] = "assistant_surgeon"
    return result


def stage(stage_id, title, kind, progress, transition, prompt, options,
          interlude="", cues=None, stage_kind="fixed", entry_condition=None):
    result = {
        "id": stage_id,
        "title": title,
        "kind": kind,
        "stage_kind": stage_kind,
        "progress_delta": progress,
        "transition_text": transition,
        "prompt": prompt,
        "options": options,
        "awake_interlude": interlude,
        "patient_cues": cues or [],
    }
    if entry_condition is not None:
        result["entry_condition"] = entry_condition
        result["once_per_episode"] = True
    return result


def correction(stage_id, title, prompt, entry_condition, options, transition):
    return stage(stage_id, title, "decision", 0, transition, prompt, options,
                 "ongoing_interaction", ["pressure", "deep_manipulation"],
                 "conditional_correction", entry_condition)


def pilot_stages():
    low_visibility = lambda value: {"all": [{"field": "visibility", "op": "lt", "value": value}]}
    any_bad = lambda visibility, bleeding: {"any": [
        {"field": "visibility", "op": "lt", "value": visibility},
        {"field": "bleeding", "op": "gte", "value": bleeding},
    ]}
    return {
        "surgery_appendix": [
            stage("appendix_01_entry", "切口与腹壁进入", "confirm", 11,
                  "切口开始后，器械护士按顺序递入进入腹壁所需器械，助手医生维持切口暴露，巡回护士在无菌区外确认灯光、吸引与记录。皮肤、皮下和腹壁层次依次进入。",
                  "腹壁层次已经进入，团队等待坂口医生确认继续。",
                  [option("appendix_confirm_entry", "确认进入腹壁，继续", effects(elapsed_time=6, bleeding=1, blood_loss=2))],
                  "operative_contact", ["incision", "exposure"]),
            stage("appendix_02_exposure", "腹膜进入与建立右下腹术野", "decision", 11,
                  "腹膜进入后，助手逐步调整牵开，回盲部区域开始进入视野。",
                  "接下来怎样建立右下腹术野？", [
                      option("appendix_wide_exposure", "先调整牵开，把右下腹术野做清楚", effects(elapsed_time=7, visibility=10, bleeding=1, blood_loss=3)),
                      option("appendix_current_exposure", "按当前暴露继续进入", effects(elapsed_time=5, visibility=3, bleeding=2, blood_loss=4)),
                  ], "ongoing_interaction", ["pressure", "exposure"]),
            stage("appendix_03_identify", "寻找盲肠并定位阑尾", "decision", 11,
                  "回盲部已经显露，团队沿解剖关系寻找阑尾。",
                  "怎样确认阑尾的位置？", [
                      option("appendix_systematic_identification", "沿盲肠关系逐步定位阑尾", effects(elapsed_time=7, visibility=8, bleeding=1, blood_loss=3)),
                      option("appendix_direct_identification", "按当前术野直接寻找阑尾", effects(elapsed_time=5, visibility=-2, bleeding=3, blood_loss=4), conditional=[condition_effect(low_visibility(75), effects(visibility=-5), "「这里没有刚才看起来那么清楚。」")]),
                  ], "strain_interaction", ["traction", "pressure"]),
            stage("appendix_04_mobilize", "游离并充分显露阑尾", "decision", 11,
                  "阑尾已经找到，助手维持牵开，周围层次逐步分开。",
                  "怎样继续游离并显露阑尾？", [
                      option("appendix_full_mobilization", "先把阑尾游离并充分提出，再继续", effects(elapsed_time=10, visibility=10, bleeding=-2, blood_loss=4)),
                      option("appendix_progressive_mobilization", "维持当前暴露，边游离边向系膜推进", effects(elapsed_time=8, visibility=3, bleeding=3, blood_loss=5), conditional=[condition_effect(low_visibility(75), effects(bleeding=4, stability=-3), "「术野偏窄，继续时要更谨慎。」")]),
                  ], "strain_interaction", ["traction", "pressure"]),
            stage("appendix_05_mesappendix", "处理阑尾系膜与供血", "decision", 11,
                  "阑尾已经充分显露，接下来进入系膜与供血处理。",
                  "选择处理节奏。", [
                      option("appendix_mesowell", "稳妥处理：分段控制系膜，边处理边维持清楚术野", effects(elapsed_time=12, visibility=5, bleeding=-5, blood_loss=5)),
                      option("appendix_mesostandard", "标准推进：按正常节奏处理系膜与供血", effects(elapsed_time=9, bleeding=3, blood_loss=6)),
                      option("appendix_mesofast", "快速推进：加快系膜处理，尽快进入根部", effects(elapsed_time=6, visibility=-5, bleeding=9, blood_loss=9), conditional=[condition_effect(any_bad(75, 15), effects(bleeding=6, blood_loss=6, stability=-5), "「现在的术野不适合再快。」")]),
                  ], "strain_interaction", ["traction", "deep_manipulation"]),
            stage("appendix_06_base", "处理阑尾根部", "decision", 11,
                  "系膜与供血已经处理，团队转向阑尾根部。",
                  "怎样完成根部控制？", [
                      option("appendix_recheck_base", "重新确认根部关系，再完成控制", effects(elapsed_time=9, visibility=3, bleeding=-2, blood_loss=4)),
                      option("appendix_direct_base", "按当前术野直接完成根部处理", effects(elapsed_time=7, bleeding=2, blood_loss=5), conditional=[condition_effect(any_bad(70, 20), effects(bleeding=5, blood_loss=5, stability=-4), "「根部关系还需要再看清一点。」")]),
                  ], "strain_interaction", ["pressure", "deep_manipulation"]),
            stage("appendix_07_resection", "切除阑尾与完成残端处理", "decision", 11,
                  "阑尾根部处理完成，标本即将离开术野。",
                  "切除后怎样进入最终复核？", [
                      option("appendix_clean_stump", "完成切除后先整理残端与周围术野", effects(elapsed_time=5, bleeding=-2, blood_loss=2)),
                      option("appendix_direct_review", "完成切除后直接进入最终复核", effects(elapsed_time=4, bleeding=1, blood_loss=3)),
                  ], "strain_interaction", ["pressure", "deep_manipulation"]),
            correction("appendix_correction", "术野纠正", "当前术野需要先处理，再进入最终复核。", any_bad(70, 18), [
                option("appendix_correction_repair", "重新建立暴露并完成追加止血", effects(elapsed_time=10, visibility=20, bleeding=-20, blood_loss=6, stability=3)),
                option("appendix_correction_defer", "维持当前局面，留到最终复核处理", effects(elapsed_time=4, bleeding=7, blood_loss=10, stability=-5), conditional=[condition_effect({"all": [{"field": "bleeding", "op": "gte", "value": 30}]}, effects(blood_loss=15, stability=-10, add_complications=[{"id": "active_field_bleeding", "severity": "minor"}]), "「先别再拖了。」")]),
            ], "主要处理已经完成，但术野还需要一次纠正。"),
            stage("appendix_08_review", "最终复核与止血", "decision", 11,
                  "阑尾已经切除，器械护士完成标本核对，团队开始检查残端与周围术野。",
                  "怎样完成关闭前复核？", [
                      option("appendix_complete_review", "完整复核残端、周围组织与止血状态", effects(elapsed_time=7, visibility=5, bleeding=-15, blood_loss=3, stability=2)),
                      option("appendix_focus_review", "做重点复核，状态可接受就关闭", effects(elapsed_time=5, bleeding=-8, blood_loss=4), conditional=[condition_effect({"all": [{"field": "bleeding", "op": "gte", "value": 20}]}, effects(blood_loss=10, stability=-8, add_complications=[{"id": "residual_bleeding", "severity": "minor"}]), "「这里还留着一点渗血。」")]),
                  ], "progress_check", ["pressure"]),
            stage("appendix_09_closure", "关闭", "confirm", 12,
                  "最终复核完成，器械护士开始最终清点，助手协助逐层关闭。",
                  "关闭切口，结束手术。",
                  [option("appendix_complete_closure", "完成关闭，结束手术", effects(elapsed_time=8, blood_loss=2))],
                  "closure_interaction", ["closure"]),
        ],
        "surgery_open_cholecystectomy": [
            stage("chole_01_entry", "右上腹切口与腹腔进入", "confirm", 10, "切口开始后，团队依次完成腹壁进入、吸引与术野建立。", "团队等待进入确认。", [option("chole_confirm_entry", "完成进入，建立初始术野", effects(elapsed_time=10, bleeding=1, blood_loss=5))], "operative_contact", ["incision", "exposure"]),
            stage("chole_02_exposure", "建立右上腹暴露与牵开", "decision", 10, "右上腹切口已经进入，助手开始调整牵开。", "怎样建立稳定暴露？", [option("chole_wide_exposure", "先充分调整牵开，建立稳定暴露", effects(elapsed_time=18, visibility=15, bleeding=2, blood_loss=5)), option("chole_current_exposure", "按当前暴露进入下一步", effects(elapsed_time=15, visibility=5, bleeding=4, blood_loss=6))], "ongoing_interaction", ["pressure", "exposure"]),
            stage("chole_03_triangle", "显露胆囊及胆囊三角区域", "decision", 10, "胆囊进入术野，团队继续向胆囊颈部与周围区域靠近。", "怎样显露关键区域？", [option("chole_clear_neck", "先把胆囊颈部与周围关系显露清楚", effects(elapsed_time=16, visibility=12, bleeding=2, blood_loss=6)), option("chole_direct_triangle", "按现有暴露直接开始关键区域解剖", effects(elapsed_time=12, visibility=3, bleeding=5, blood_loss=7), conditional=[condition_effect(low_visibility(75), effects(visibility=-6, bleeding=4), "「关键区域还没有完全打开。」")])], "strain_interaction", ["traction", "deep_manipulation"]),
            stage("chole_04_anatomy", "解剖并确认关键结构", "decision", 10, "胆囊三角区域已经显露，接下来必须确认关键结构关系。", "选择解剖节奏。", [option("chole_anatomy_slow", "稳妥处理：继续解剖，直到关键结构关系非常清楚", effects(elapsed_time=22, visibility=10, bleeding=-2, blood_loss=7)), option("chole_anatomy_standard", "标准推进：确认结构关系达到可安全推进程度", effects(elapsed_time=18, visibility=3, bleeding=3, blood_loss=8)), option("chole_anatomy_fast", "快速推进：依当前关系直接进入控制阶段", effects(elapsed_time=13, visibility=-8, bleeding=10, blood_loss=12), conditional=[condition_effect(low_visibility(75), effects(bleeding=6, blood_loss=8, stability=-6), "「这里的关系还不够清楚。」")])], "strain_interaction", ["traction", "deep_manipulation"]),
            stage("chole_05_cystic_duct", "控制胆囊管", "decision", 10, "关键结构已经确认，团队开始控制胆囊管。", "怎样完成控制？", [option("chole_duct_recheck", "再确认一次管道关系后完成控制", effects(elapsed_time=10, bleeding=-2, blood_loss=5)), option("chole_duct_direct", "按当前确认结果直接完成控制", effects(elapsed_time=8, bleeding=2, blood_loss=6))], "ongoing_interaction", ["pressure"]),
            stage("chole_06_cystic_artery", "控制胆囊动脉", "decision", 10, "胆囊管已经控制，团队转向供血结构。", "怎样完成动脉控制？", [option("chole_artery_recheck", "保持暴露，确认供血结构后完成控制", effects(elapsed_time=10, bleeding=-4, blood_loss=5)), option("chole_artery_direct", "按当前术野直接完成控制", effects(elapsed_time=8, bleeding=3, blood_loss=6))], "ongoing_interaction", ["pressure"]),
            stage("chole_07_liver_bed", "从肝床分离胆囊", "decision", 10, "胆囊管与动脉已经处理，接下来从肝床分离胆囊。", "怎样完成肝床分离？", [option("chole_segmented_dissection", "分段分离并随时控制胆囊床渗血", effects(elapsed_time=24, visibility=8, bleeding=-8, blood_loss=12)), option("chole_standard_dissection", "按正常节奏完成肝床分离", effects(elapsed_time=22, bleeding=5, blood_loss=15), conditional=[condition_effect(low_visibility(70), effects(bleeding=7, blood_loss=8, stability=-5), "「肝床的视野变窄了。」")])], "strain_interaction", ["traction", "deep_manipulation"]),
            correction("chole_correction", "胆囊床纠正", "胆囊已经从肝床分离，但当前术野需要先处理，再进入最终检查。", any_bad(70, 24), [option("chole_correction_repair", "先清理胆囊床并完成追加止血", effects(elapsed_time=14, visibility=20, bleeding=-20, blood_loss=7, stability=3)), option("chole_correction_defer", "继续推进，留到最终复核一起处理", effects(elapsed_time=6, bleeding=7, blood_loss=15, stability=-8), conditional=[condition_effect({"all": [{"field": "bleeding", "op": "gte", "value": 35}]}, effects(blood_loss=18, stability=-10, add_complications=[{"id": "gallbladder_bed_bleeding", "severity": "minor"}]), "「胆囊床的出血不能再拖。」")])], "主要分离已经完成，但胆囊床还需要一次纠正。"),
            stage("chole_08_specimen", "胆囊取出与重新整理术野", "confirm", 10, "胆囊离开术野，器械护士接收标本，助手重新建立胆囊床暴露。", "团队等待标本确认。", [option("chole_confirm_specimen", "确认标本离开术野，进入最终复核", effects(elapsed_time=7, blood_loss=3))], "ongoing_interaction", ["pressure"]),
            stage("chole_09_review", "胆囊床最终检查、止血与胆漏复核", "decision", 10, "胆囊床重新显露，团队开始进行关闭前检查。", "怎样完成最终复核？", [option("chole_complete_review", "完整检查胆囊床与关键区域，再进入关闭", effects(elapsed_time=14, visibility=5, bleeding=-20, blood_loss=5, stability=2)), option("chole_focus_review", "做重点复核，状态可接受就关闭", effects(elapsed_time=10, bleeding=-10, blood_loss=6), conditional=[condition_effect({"all": [{"field": "bleeding", "op": "gte", "value": 20}]}, effects(blood_loss=12, stability=-8, add_complications=[{"id": "residual_bed_bleeding", "severity": "minor"}]), "「胆囊床还需要再看一眼。」")])], "progress_check", ["pressure", "closure"]),
            stage("chole_10_closure", "关闭", "confirm", 10, "最终复核完成，器械护士开始最终清点，助手协助逐层关闭。", "关闭切口，结束手术。", [option("chole_complete_closure", "完成关闭，结束手术", effects(elapsed_time=10, blood_loss=8))], "closure_interaction", ["closure"]),
        ],
        "surgery_open_inguinal_hernia": [
            stage("hernia_01_entry", "腹股沟切口与皮下进入", "confirm", 11, "切口开始后，团队完成皮下进入并逐层建立术野。", "团队等待进入确认。", [option("hernia_confirm_entry", "完成切口与皮下进入", effects(elapsed_time=8, bleeding=1, blood_loss=2))], "operative_contact", ["incision", "exposure"]),
            stage("hernia_02_canal", "打开腹外斜肌腱膜与进入腹股沟管", "decision", 11, "皮下层次已经进入，团队开始打开腹外斜肌腱膜。", "怎样进入腹股沟管？", [option("hernia_wide_canal", "先把腹股沟管入口充分显露", effects(elapsed_time=12, visibility=10, bleeding=1, blood_loss=3)), option("hernia_current_canal", "按当前暴露继续进入", effects(elapsed_time=10, visibility=4, bleeding=2, blood_loss=4))], "ongoing_interaction", ["pressure", "exposure"]),
            stage("hernia_03_identify", "辨认局部结构与疝类型", "decision", 11, "腹股沟管已经打开，团队沿局部解剖关系辨认疝囊与缺损方向。", "怎样确认局部结构？", [option("hernia_complete_identification", "先完整辨认局部结构与缺损方向", effects(elapsed_time=12, visibility=8, bleeding=1, blood_loss=3)), option("hernia_direct_sac", "确认主要关系后直接开始寻找疝囊", effects(elapsed_time=10, visibility=2, bleeding=2, blood_loss=4))], "strain_interaction", ["traction", "pressure"]),
            stage("hernia_04_sac", "辨认并分离疝囊", "decision", 11, "疝囊已经定位，团队开始沿层次进行分离。", "怎样完成疝囊分离？", [option("hernia_layered_sac", "沿层次逐步分离，保持关系清楚", effects(elapsed_time=16, visibility=10, bleeding=1, blood_loss=4)), option("hernia_standard_sac", "按正常节奏完成疝囊分离", effects(elapsed_time=13, visibility=3, bleeding=4, blood_loss=6), conditional=[condition_effect(low_visibility(75), effects(visibility=-5, bleeding=4), "「这里的层次还不够干净。」")])], "strain_interaction", ["traction", "deep_manipulation"]),
            stage("hernia_05_reduction", "处理疝囊与还纳疝内容", "decision", 11, "疝囊已经分离，团队开始处理疝内容与还纳。", "怎样处理疝囊与内容？", [option("hernia_organized_reduction", "先把疝囊与内容处理整齐，再继续", effects(elapsed_time=13, visibility=5, bleeding=-2, blood_loss=3)), option("hernia_standard_reduction", "按正常节奏完成处理与还纳", effects(elapsed_time=10, bleeding=2, blood_loss=4))], "strain_interaction", ["traction", "deep_manipulation"]),
            stage("hernia_06_defect", "评估缺损与修补条件", "decision", 11, "疝内容已经还纳，团队开始确认缺损边界与修补条件。", "怎样确认修补边界？", [option("hernia_recheck_defect", "重新整理暴露，完整确认修补边界", effects(elapsed_time=15, visibility=8, bleeding=-2, blood_loss=3)), option("hernia_current_defect", "按当前暴露确认修补范围", effects(elapsed_time=12, visibility=2, blood_loss=4), conditional=[condition_effect({"all": [{"field": "visibility", "op": "lt", "value": 72}]}, effects(set_flags=["repair_recheck_required"]), "「修补边界需要留一个复核标记。」")])], "strain_interaction", ["traction", "pressure"]),
            stage("hernia_07_repair", "完成后壁与补片修补", "decision", 11, "缺损范围已经确认，接下来完成后壁与补片修补。", "选择修补节奏。", [option("hernia_repair_slow", "稳妥处理：控制张力，逐步完成并反复确认修补", effects(elapsed_time=18, visibility=5, bleeding=-3, blood_loss=4)), option("hernia_repair_standard", "标准推进：按正常节奏完成修补", effects(elapsed_time=14, bleeding=1, blood_loss=5)), option("hernia_repair_fast", "快速推进：减少中间复核，尽快完成修补", effects(elapsed_time=10, visibility=-6, bleeding=5, blood_loss=7), conditional=[condition_effect({"any": [{"field": "visibility", "op": "lt", "value": 75}, {"field": "repair_recheck_required", "op": "eq", "value": True}]}, effects(stability=-4, set_flags=["repair_recheck_required"]), "「修补完成了，但复核标记还在。」")])], "strain_interaction", ["traction", "deep_manipulation"]),
            correction("hernia_correction", "修补区返工与复核", "修补区需要一次额外显露或返工，再进入最终复核。", {"any": [{"field": "visibility", "op": "lt", "value": 70}, {"field": "bleeding", "op": "gte", "value": 16}, {"field": "repair_recheck_required", "op": "eq", "value": True}]}, [option("hernia_correction_repair", "重新显露修补区，处理渗血并完成必要返工", effects(elapsed_time=12, visibility=15, bleeding=-12, blood_loss=4, stability=2, clear_flags=["repair_recheck_required"])), option("hernia_correction_defer", "维持当前结果，留给最终复核处理", effects(elapsed_time=5, bleeding=5, blood_loss=6, stability=-4))], "主要修补已经完成，但修补区还需要一次纠正。"),
            stage("hernia_08_review", "修补区与止血最终复核", "decision", 11, "修补区重新显露，团队开始完成关闭前复核。", "怎样完成最终复核？", [option("hernia_complete_review", "完整复核修补区并完成止血", effects(elapsed_time=9, visibility=5, bleeding=-12, blood_loss=3, clear_flags=["repair_recheck_required"])), option("hernia_focus_review", "做针对性复核，状态可接受就关闭", effects(elapsed_time=7, bleeding=-6, blood_loss=4), conditional=[condition_effect({"all": [{"field": "repair_recheck_required", "op": "eq", "value": True}]}, effects(elapsed_time=5, add_complications=[{"id": "closure_rework", "severity": "minor"}]), "「这里还留着一个需要返工的点。」")])], "progress_check", ["pressure"]),
            stage("hernia_09_closure", "关闭", "confirm", 12, "最终复核完成，器械护士开始最终清点，助手协助逐层关闭。", "关闭切口，结束手术。", [option("hernia_complete_closure", "完成关闭，结束手术", effects(elapsed_time=6, blood_loss=2))], "closure_interaction", ["closure"]),
        ],
    }


def main():
    data = json.loads(PATH.read_text())
    stages_by_id = pilot_stages()
    variants = {
        "surgery_appendix": [{"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "进入腹腔后，回盲部位置比较直接，当前暴露尚可。"}, {"id": "difficult_exposure", "weight": 25, "initial_visibility": 70, "player_hint": "进入腹腔后，回盲部位置偏深。牵开以后，阑尾区域仍没有完全进入清楚视野。"}],
        "surgery_open_cholecystectomy": [{"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "右上腹暴露顺利，胆囊和周围结构能够比较清楚地进入术野。"}, {"id": "inflamed_exposure", "weight": 25, "initial_visibility": 70, "player_hint": "胆囊周围组织明显充血、水肿，关键区域显得拥挤，辨认结构需要更多耐心。"}],
        "surgery_open_inguinal_hernia": [{"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "腹股沟管暴露以后，疝囊与周围组织的关系比较清楚。"}, {"id": "adherent_sac", "weight": 25, "initial_visibility": 72, "player_hint": "疝囊和周围组织粘连得更紧，分离层次没有平常那么干净。"}],
    }
    for surgery in data:
        surgery_id = surgery.get("id")
        if surgery_id not in stages_by_id:
            continue
        surgery["stages"] = stages_by_id[surgery_id]
        surgery["case_variants"] = variants[surgery_id]
        surgery.setdefault("initial_state", {})["bleeding"] = 0
        surgery["initial_state"]["visibility"] = 90
        surgery["fixed_stage_progress"] = [step["progress_delta"] for step in surgery["stages"] if step["stage_kind"] != "conditional_correction"]
    PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")


if __name__ == "__main__":
    main()
