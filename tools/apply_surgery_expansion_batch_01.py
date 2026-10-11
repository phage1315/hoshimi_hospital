"""Apply the authored Batch 01 surgery data to the canonical runtime file.

This is intentionally a data migration for the four existing procedure IDs;
it does not add a second surgery runner or alter the Common Surgery V2 schema.
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


def stage(stage_id, title, progress, kind, interlude, cues, options,
          transition=None):
    return {
        "id": stage_id,
        "title": title,
        "kind": kind,
        "stage_kind": "fixed",
        "progress_delta": progress,
        "transition_text": transition if transition is not None else title + "。",
        "prompt": "确认完成当前阶段。" if kind == "confirm" else "选择下一步处理方式。",
        "options": options,
        "awake_interlude": interlude,
        "patient_cues": cues,
    }


def correction(stage_id, title, entry_condition, options, interlude, cues):
    result = stage(stage_id, title, 0, "decision", interlude, cues, options)
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


def batch_stages():
    low_visibility_75 = field_condition("visibility", "lt", 75)
    bleeding_15 = field_condition("bleeding", "gte", 15)
    bleeding_20 = field_condition("bleeding", "gte", 20)

    hernia = [
        stage("ventral_01_entry", "切口与腹壁进入", 11, "confirm", "operative_contact", ["incision", "exposure"], [
            option("ventral_confirm_entry", "确认进入腹壁缺损区域，继续", effects(elapsed_time=12, bleeding=1, blood_loss=4)),
        ], "{assistant_name}维持切口两侧暴露，{scrub_name}依次递入切开、止血和牵开所需器械；{circulator_name}调整灯光并记录手术开始时间。逐层进入以后，腹壁缺损以及覆盖其上的疝囊开始进入术野。"),
        stage("ventral_02_exposure", "显露疝囊与缺损边缘", 11, "decision", "ongoing_interaction", ["pressure", "exposure"], [
            option("ventral_complete_exposure", "先把缺损边缘完整显露清楚", effects(elapsed_time=18, visibility=12, bleeding=1, blood_loss=5)),
            option("ventral_current_exposure", "按目前显露直接继续", effects(elapsed_time=14, visibility=4, bleeding=3, blood_loss=5)),
        ]),
        stage("ventral_03_reduction", "松解粘连并还纳疝内容", 11, "decision", "strain_interaction", ["traction", "deep_manipulation"], [
            option("ventral_safe_reduction", "逐步松解粘连，确认清楚后再还纳", effects(elapsed_time=28, visibility=10, bleeding=-3, blood_loss=8)),
            option("ventral_standard_reduction", "边分离边完成还纳", effects(elapsed_time=20, visibility=3, bleeding=5, blood_loss=10)),
            option("ventral_fast_reduction", "优先快速完成还纳", effects(elapsed_time=14, visibility=-6, bleeding=10, blood_loss=14), [condition_effect(any_condition(low_visibility_75, bleeding_15), effects(bleeding=6, blood_loss=8, stability=-5))]),
        ]),
        stage("ventral_04_defect", "评估腹壁缺损与组织条件", 11, "decision", "ongoing_interaction", ["pressure", "exposure"], [
            option("ventral_complete_defect_review", "完整检查缺损边缘、范围与张力条件", effects(elapsed_time=15, visibility=6, bleeding=-2, blood_loss=4)),
            option("ventral_focus_defect_review", "重点确认后进入修补", effects(elapsed_time=12, visibility=2, blood_loss=5)),
        ]),
        stage("ventral_05_plane", "建立修补平面", 11, "decision", "strain_interaction", ["traction", "pressure"], [
            option("ventral_safe_plane", "充分建立修补平面以后再继续", effects(elapsed_time=24, visibility=10, bleeding=-2, blood_loss=7)),
            option("ventral_standard_plane", "按标准范围建立修补平面", effects(elapsed_time=18, visibility=3, bleeding=2, blood_loss=8)),
            option("ventral_fast_plane", "在当前暴露下直接推进修补", effects(elapsed_time=13, visibility=-6, bleeding=5, blood_loss=10), [condition_effect(all_condition(field_condition("visibility", "lt", 72)), effects(set_flags=["repair_recheck_required"]))]),
        ]),
        stage("ventral_06_closure", "关闭腹壁缺损", 11, "decision", "strain_interaction", ["pressure", "deep_manipulation"], [
            option("ventral_tension_closure", "逐步调整张力后完成筋膜关闭", effects(elapsed_time=26, visibility=3, bleeding=-3, blood_loss=8)),
            option("ventral_standard_closure", "按当前条件标准完成关闭", effects(elapsed_time=20, bleeding=2, blood_loss=9)),
            option("ventral_fast_closure", "压缩调整步骤，快速完成缺损关闭", effects(elapsed_time=15, visibility=-4, bleeding=5, blood_loss=11), [condition_effect(any_condition(field_condition("visibility", "lt", 75), field_condition("repair_recheck_required", "eq", True)), effects(stability=-3, set_flags=["repair_recheck_required"]))]),
        ]),
        stage("ventral_07_mesh", "补片铺设与固定", 11, "decision", "strain_interaction", ["pressure", "traction"], [
            option("ventral_safe_mesh", "完整展开补片并逐区确认覆盖与固定", effects(elapsed_time=34, visibility=3, bleeding=-2, blood_loss=7)),
            option("ventral_standard_mesh", "按正常范围完成铺设和固定", effects(elapsed_time=28, bleeding=1, blood_loss=8)),
            option("ventral_fast_mesh", "减少中间调整，尽快完成固定", effects(elapsed_time=20, visibility=-5, bleeding=4, blood_loss=10), [condition_effect(all_condition(field_condition("visibility", "lt", 75)), effects(set_flags=["repair_recheck_required"]))]),
        ]),
        correction("ventral_correction", "修补区重整 / 追加止血", any_condition(field_condition("visibility", "lt", 70), field_condition("bleeding", "gte", 24), field_condition("repair_recheck_required", "eq", True)), [
            option("ventral_correction_repair", "重新显露修补区，完成必要返工并追加止血", effects(elapsed_time=16, visibility=18, bleeding=-18, blood_loss=7, stability=2, clear_flags=["repair_recheck_required"])),
            option("ventral_correction_defer", "只做最低限度整理，把剩余问题留到最终复核", effects(elapsed_time=7, bleeding=6, blood_loss=10, stability=-4), [condition_effect(all_condition(field_condition("bleeding", "gte", 32)), effects(blood_loss=12, stability=-6, add_complications=[{"id": "active_field_bleeding", "severity": "minor"}]))]),
        ], "ongoing_interaction", ["pressure", "exposure"]),
        stage("ventral_08_review", "修补与止血最终复核", 11, "decision", "progress_check", ["pressure"], [
            option("ventral_complete_review", "完整复核修补区并完成止血", effects(elapsed_time=16, visibility=5, bleeding=-15, blood_loss=5, clear_flags=["repair_recheck_required"])),
            option("ventral_focus_review", "做重点复核，状态可接受就关闭", effects(elapsed_time=12, bleeding=-8, blood_loss=5), [condition_effect(all_condition(field_condition("repair_recheck_required", "eq", True)), effects(elapsed_time=6, blood_loss=3, clear_flags=["repair_recheck_required"], add_complications=[{"id": "closure_rework", "severity": "minor"}]))]),
        ]),
        stage("ventral_09_closure", "腹壁关闭", 12, "confirm", "closure_interaction", ["closure"], [
            option("ventral_complete_closure", "完成关闭，结束手术", effects(elapsed_time=14, blood_loss=3)),
        ]),
    ]

    breast = [
        stage("breast_01_entry", "切口与病灶区域进入", 12, "confirm", "operative_contact", ["incision", "exposure"], [
            option("breast_confirm_entry", "确认进入病灶区域，继续", effects(elapsed_time=12, bleeding=1, blood_loss=2)),
        ]),
        stage("breast_02_exposure", "显露并确认病灶位置", 12, "decision", "dignity_interaction", ["exposure", "pressure"], [
            option("breast_complete_exposure", "重新完整确认病灶和术前标记的对应位置", effects(elapsed_time=15, visibility=10, blood_loss=3)),
            option("breast_current_exposure", "按已有定位直接进入范围确认", effects(elapsed_time=12, visibility=4, bleeding=1, blood_loss=3)),
        ]),
        stage("breast_03_margin", "确定切除范围", 12, "decision", "dignity_interaction", ["exposure", "pressure"], [
            option("breast_safe_margin", "充分确认边界后再建立切除范围", effects(elapsed_time=22, visibility=8, bleeding=-1, blood_loss=3)),
            option("breast_standard_margin", "按术前计划和当前术野确定范围", effects(elapsed_time=18, visibility=3, blood_loss=4)),
            option("breast_fast_margin", "依当前可见边界直接确定范围", effects(elapsed_time=13, visibility=-6, bleeding=2, blood_loss=5), [condition_effect(all_condition(field_condition("visibility", "lt", 78)), effects(set_flags=["margin_recheck_required"]))]),
        ]),
        stage("breast_04_excision", "完成肿瘤切除", 12, "decision", "strain_interaction", ["pressure", "traction"], [
            option("breast_safe_excision", "沿计划边界推进，并持续整理切除平面", effects(elapsed_time=31, visibility=4, bleeding=-3, blood_loss=8)),
            option("breast_standard_excision", "保持正常节奏完整切除标本", effects(elapsed_time=25, bleeding=3, blood_loss=10)),
            option("breast_fast_excision", "优先完成标本切除，再集中复核切除腔", effects(elapsed_time=19, visibility=-5, bleeding=7, blood_loss=13), [condition_effect(all_condition(field_condition("visibility", "lt", 75)), effects(set_flags=["margin_recheck_required"]))]),
        ]),
        stage("breast_05_specimen", "标本方向标记与交接", 13, "confirm", "ongoing_interaction", ["exposure"], [
            option("breast_confirm_specimen", "确认标本完成标记并交接，继续", effects(elapsed_time=8, blood_loss=1)),
        ], "{scrub_name}按照当前实际人物分配完成标本方向标记并将标本交给 {circulator_name} 完成外围记录和送检；{assistant_name}继续保持切除腔暴露。"),
        stage("breast_06_review", "切除腔与切缘复核", 13, "decision", "dignity_interaction", ["exposure", "pressure"], [
            option("breast_complete_review", "完整检查各方向切除腔与可疑区域", effects(elapsed_time=22, visibility=5, bleeding=-4, blood_loss=3)),
            option("breast_focus_review", "重点复核可疑方向，确认整体可以接受", effects(elapsed_time=18, visibility=2, bleeding=-2, blood_loss=4), [condition_effect(all_condition(field_condition("visibility", "lt", 70)), effects(set_flags=["margin_recheck_required"]))]),
            option("breast_short_review", "当前表现良好，缩短复核直接准备结束", effects(elapsed_time=12, visibility=-3, bleeding=1, blood_loss=4), [condition_effect(all_condition(field_condition("visibility", "lt", 82)), effects(set_flags=["margin_recheck_required"]))]),
        ]),
        correction("breast_correction", "定向切缘追加处理 / 切除腔重整", any_condition(field_condition("margin_recheck_required", "eq", True), field_condition("visibility", "lt", 68), field_condition("bleeding", "gte", 16)), [
            option("breast_correction_clean", "重新显露对应方向，完成定向追加处理和止血", effects(elapsed_time=12, visibility=8, bleeding=-8, blood_loss=4, clear_flags=["margin_recheck_required"])),
            option("breast_correction_minimal", "做最小限度追加处理，尽快转入复位", effects(elapsed_time=7, visibility=1, bleeding=3, blood_loss=7, clear_flags=["margin_recheck_required"])),
        ], "ongoing_interaction", ["pressure", "exposure"]),
        stage("breast_07_reposition", "止血与乳腺组织复位", 13, "decision", "progress_check", ["pressure", "exposure"], [
            option("breast_safe_reposition", "仔细完成切除腔止血并调整组织复位", effects(elapsed_time=18, bleeding=-8, blood_loss=3)),
            option("breast_standard_reposition", "按常规完成复位并进入关闭", effects(elapsed_time=15, bleeding=-4, blood_loss=4), [condition_effect(all_condition(field_condition("bleeding", "gte", 18)), effects(elapsed_time=5, blood_loss=5, add_complications=[{"id": "residual_bleeding", "severity": "minor"}]))]),
        ]),
        stage("breast_08_closure", "皮肤关闭", 13, "confirm", "closure_interaction", ["closure"], [
            option("breast_complete_closure", "完成关闭，结束手术", effects(elapsed_time=12, blood_loss=2)),
        ]),
    ]

    ovarian = [
        stage("ovarian_01_entry", "开腹并建立盆腔术野", 11, "confirm", "operative_contact", ["incision", "exposure"], [
            option("ovarian_confirm_entry", "确认进入盆腔术野，继续", effects(elapsed_time=10, bleeding=1, blood_loss=3)),
        ]),
        stage("ovarian_02_relation", "确认患侧卵巢与囊肿关系", 11, "decision", "dignity_interaction", ["exposure", "pressure"], [
            option("ovarian_complete_relation", "完整检查囊肿边界和可保留卵巢组织", effects(elapsed_time=12, visibility=10, bleeding=1, blood_loss=4)),
            option("ovarian_current_relation", "确认主要关系后继续", effects(elapsed_time=10, visibility=4, bleeding=2, blood_loss=4)),
        ]),
        stage("ovarian_03_mobilize", "游离卵巢与周围粘连", 11, "decision", "strain_interaction", ["traction", "pressure"], [
            option("ovarian_safe_mobilize", "逐层松解粘连，让卵巢充分活动", effects(elapsed_time=20, visibility=10, bleeding=-2, blood_loss=6)),
            option("ovarian_standard_mobilize", "按正常节奏完成游离", effects(elapsed_time=15, visibility=3, bleeding=4, blood_loss=7)),
            option("ovarian_fast_mobilize", "加快分离，尽快把卵巢带入可操作位置", effects(elapsed_time=11, visibility=-5, bleeding=8, blood_loss=10), [condition_effect(any_condition(low_visibility_75, bleeding_15), effects(blood_loss=6, stability=-4))]),
        ]),
        stage("ovarian_04_cortex", "切开卵巢皮质并寻找分离面", 11, "decision", "strain_interaction", ["pressure", "deep_manipulation"], [
            option("ovarian_find_plane", "先仔细找到清楚的囊壁分离层次", effects(elapsed_time=12, visibility=8, bleeding=1, blood_loss=4)),
            option("ovarian_current_plane", "按当前可见层次直接进入剥离", effects(elapsed_time=10, visibility=2, bleeding=3, blood_loss=4)),
        ]),
        stage("ovarian_05_stripping", "剥离囊壁", 11, "decision", "strain_interaction", ["traction", "deep_manipulation"], [
            option("ovarian_safe_stripping", "沿分离面缓慢完整剥离囊壁", effects(elapsed_time=23, visibility=5, bleeding=-3, blood_loss=7)),
            option("ovarian_standard_stripping", "保持稳定节奏继续剥离", effects(elapsed_time=18, bleeding=4, blood_loss=8)),
            option("ovarian_fast_stripping", "增加牵拉，尽快完成主要囊壁剥离", effects(elapsed_time=14, visibility=-6, bleeding=8, blood_loss=11), [condition_effect(all_condition(field_condition("visibility", "lt", 75)), effects(bleeding=3, set_flags=["cystectomy_recheck_required"]))]),
        ]),
        stage("ovarian_06_deep", "完成囊肿深部剥离", 11, "decision", "strain_interaction", ["traction", "deep_manipulation"], [
            option("ovarian_safe_deep", "放轻牵拉，重新确认深部分离面再完成剥离", effects(elapsed_time=21, visibility=4, bleeding=-4, blood_loss=7)),
            option("ovarian_standard_deep", "按当前层次标准完成深部剥离", effects(elapsed_time=16, bleeding=4, blood_loss=8)),
            option("ovarian_fast_deep", "直接加快深部处理，尽快取出囊肿", effects(elapsed_time=12, visibility=-5, bleeding=9, blood_loss=12), [condition_effect(any_condition(field_condition("visibility", "lt", 72), field_condition("bleeding", "gte", 20)), effects(stability=-4, set_flags=["cystectomy_recheck_required"]))]),
        ]),
        stage("ovarian_07_hemostasis", "囊肿床止血", 11, "decision", "strain_interaction", ["pressure", "deep_manipulation"], [
            option("ovarian_complete_hemostasis", "逐点检查囊肿床并完成充分止血", effects(elapsed_time=20, visibility=3, bleeding=-15, blood_loss=6)),
            option("ovarian_standard_hemostasis", "按标准节奏处理主要渗血点", effects(elapsed_time=16, bleeding=-8, blood_loss=8)),
            option("ovarian_fast_hemostasis", "控制明显出血后直接准备重建", effects(elapsed_time=11, bleeding=-3, blood_loss=10), [condition_effect(all_condition(field_condition("bleeding", "gte", 20)), effects(stability=-5))]),
        ]),
        correction("ovarian_correction", "囊肿床重新整理", any_condition(field_condition("visibility", "lt", 70), field_condition("bleeding", "gte", 22), field_condition("cystectomy_recheck_required", "eq", True)), [
            option("ovarian_correction_repair", "重新展开囊肿床，完成追加止血和必要整理", effects(elapsed_time=12, visibility=15, bleeding=-18, blood_loss=5, stability=2, clear_flags=["cystectomy_recheck_required"])),
            option("ovarian_correction_focus", "做针对性处理后直接进入重建", effects(elapsed_time=6, visibility=4, bleeding=-8, blood_loss=6, clear_flags=["cystectomy_recheck_required"]), [condition_effect(all_condition(field_condition("bleeding", "gte", 30)), effects(blood_loss=8, stability=-6, add_complications=[{"id": "active_field_bleeding", "severity": "minor"}]))]),
        ], "ongoing_interaction", ["pressure", "deep_manipulation"]),
        stage("ovarian_08_reconstruction", "卵巢重建与盆腔复核", 11, "decision", "progress_check", ["pressure"], [
            option("ovarian_complete_reconstruction", "完整重建剩余卵巢组织并复核盆腔", effects(elapsed_time=14, bleeding=-10, blood_loss=4, clear_flags=["cystectomy_recheck_required"])),
            option("ovarian_standard_reconstruction", "按标准重建后结束主要处理", effects(elapsed_time=12, bleeding=-5, blood_loss=5), [condition_effect(all_condition(field_condition("bleeding", "gte", 18)), effects(blood_loss=6, add_complications=[{"id": "residual_bleeding", "severity": "minor"}]))]),
        ]),
        stage("ovarian_09_closure", "腹壁关闭", 12, "confirm", "closure_interaction", ["closure"], [
            option("ovarian_complete_closure", "完成关闭，结束手术", effects(elapsed_time=13, blood_loss=3)),
        ]),
    ]

    myomectomy = [
        stage("myomectomy_01_entry", "开腹并建立盆腔术野", 10, "confirm", "operative_contact", ["incision", "exposure"], [
            option("myomectomy_confirm_entry", "确认进入盆腔术野，继续", effects(elapsed_time=12, bleeding=1, blood_loss=5)),
        ]),
        stage("myomectomy_02_localize", "确认肌瘤位置与子宫状态", 10, "decision", "dignity_interaction", ["exposure", "pressure"], [
            option("myomectomy_complete_localize", "完整确认肌瘤位置、深度与切口方向", effects(elapsed_time=12, visibility=8, blood_loss=5)),
            option("myomectomy_current_localize", "确认主要位置后按术前计划继续", effects(elapsed_time=10, visibility=3, bleeding=1, blood_loss=5)),
        ]),
        stage("myomectomy_03_hemostatic_prep", "建立切开前止血条件", 10, "decision", "ongoing_interaction", ["pressure", "deep_manipulation"], [
            option("myomectomy_safe_prep", "先充分建立局部止血条件再切开", effects(elapsed_time=20, visibility=3, bleeding=-8, blood_loss=6)),
            option("myomectomy_standard_prep", "按正常准备完成止血布置", effects(elapsed_time=16, bleeding=-3, blood_loss=8)),
            option("myomectomy_fast_prep", "减少准备，直接进入子宫切口", effects(elapsed_time=11, bleeding=3, blood_loss=10), [condition_effect(all_condition(field_condition("visibility", "lt", 75)), effects(bleeding=5, blood_loss=5))]),
        ]),
        stage("myomectomy_04_incision", "子宫切口与进入肌瘤层次", 10, "decision", "strain_interaction", ["pressure", "deep_manipulation"], [
            option("myomectomy_safe_incision", "控制渗血，逐步进入直到肌瘤层次清楚", effects(elapsed_time=22, visibility=5, bleeding=2, blood_loss=12)),
            option("myomectomy_standard_incision", "按计划切开并进入肌瘤表面", effects(elapsed_time=18, bleeding=6, blood_loss=15)),
            option("myomectomy_fast_incision", "加快切开，尽快显露肌瘤", effects(elapsed_time=13, visibility=-5, bleeding=12, blood_loss=20), [condition_effect(any_condition(field_condition("bleeding", "gte", 20), field_condition("visibility", "lt", 70)), effects(blood_loss=8, stability=-5))]),
        ]),
        stage("myomectomy_05_capsule", "确认肌瘤假包膜 / 分离面", 10, "decision", "strain_interaction", ["pressure", "deep_manipulation"], [
            option("myomectomy_find_capsule", "重新确认肌瘤与正常肌层之间的分离面", effects(elapsed_time=12, visibility=8, bleeding=-2, blood_loss=6)),
            option("myomectomy_current_capsule", "按当前层次继续剔除", effects(elapsed_time=10, visibility=2, bleeding=1, blood_loss=7)),
        ]),
        stage("myomectomy_06_enucleation", "剔除肌瘤", 10, "decision", "strain_interaction", ["traction", "deep_manipulation"], [
            option("myomectomy_safe_enucleation", "沿分离面逐步剔除，保持层次清楚", effects(elapsed_time=26, visibility=5, bleeding=3, blood_loss=16)),
            option("myomectomy_standard_enucleation", "保持稳定牵拉与反牵拉完成剔除", effects(elapsed_time=20, bleeding=10, blood_loss=20)),
            option("myomectomy_fast_enucleation", "增加推进速度，尽快把肌瘤从肌层中剔出", effects(elapsed_time=15, visibility=-6, bleeding=16, blood_loss=28), [condition_effect(any_condition(field_condition("visibility", "lt", 72), field_condition("bleeding", "gte", 25)), effects(blood_loss=10, stability=-7))]),
        ]),
        stage("myomectomy_07_bed_hemostasis", "肌瘤床检查与止血", 10, "decision", "strain_interaction", ["pressure", "deep_manipulation"], [
            option("myomectomy_complete_bed_hemostasis", "完整检查肌瘤床并逐点完成止血", effects(elapsed_time=22, visibility=3, bleeding=-18, blood_loss=12)),
            option("myomectomy_standard_bed_hemostasis", "按正常节奏控制主要出血点", effects(elapsed_time=18, bleeding=-10, blood_loss=20)),
            option("myomectomy_fast_bed_hemostasis", "控制最明显的出血后直接开始重建", effects(elapsed_time=12, bleeding=-4, blood_loss=25), [condition_effect(all_condition(field_condition("bleeding", "gte", 30)), effects(stability=-6))]),
        ]),
        stage("myomectomy_08_repair", "子宫肌层分层重建", 10, "decision", "strain_interaction", ["pressure", "traction"], [
            option("myomectomy_safe_repair", "逐层关闭深部空隙，完整重建子宫壁", effects(elapsed_time=30, visibility=3, bleeding=-10, blood_loss=10)),
            option("myomectomy_standard_repair", "按正常层次完成肌层重建", effects(elapsed_time=22, bleeding=-5, blood_loss=15)),
            option("myomectomy_fast_repair", "压缩中间复核，尽快完成重建", effects(elapsed_time=16, visibility=-5, bleeding=2, blood_loss=20), [condition_effect(any_condition(field_condition("visibility", "lt", 75), field_condition("bleeding", "gte", 22)), effects(set_flags=["uterine_repair_recheck_required"]))]),
        ]),
        correction("myomectomy_correction", "子宫修补重整", any_condition(field_condition("visibility", "lt", 70), field_condition("bleeding", "gte", 28), field_condition("uterine_repair_recheck_required", "eq", True)), [
            option("myomectomy_correction_repair", "重新显露修补区，完成追加止血和分层返工", effects(elapsed_time=16, visibility=15, bleeding=-18, blood_loss=8, stability=2, clear_flags=["uterine_repair_recheck_required"])),
            option("myomectomy_correction_focus", "只处理最需要调整的区域，尽快进入最终复核", effects(elapsed_time=9, visibility=5, bleeding=-10, blood_loss=10, clear_flags=["uterine_repair_recheck_required"]), [condition_effect(all_condition(field_condition("bleeding", "gte", 35)), effects(blood_loss=10, stability=-6, add_complications=[{"id": "closure_rework", "severity": "minor"}]))]),
        ], "ongoing_interaction", ["pressure", "deep_manipulation"]),
        stage("myomectomy_09_review", "子宫表面与盆腔最终复核", 10, "decision", "progress_check", ["pressure"], [
            option("myomectomy_complete_review", "完整复核修补线、止血和盆腔状态", effects(elapsed_time=12, visibility=4, bleeding=-12, blood_loss=5, clear_flags=["uterine_repair_recheck_required"])),
            option("myomectomy_focus_review", "重点确认后准备关闭腹壁", effects(elapsed_time=10, bleeding=-6, blood_loss=8), [condition_effect(all_condition(field_condition("bleeding", "gte", 24)), effects(blood_loss=10, stability=-5, add_complications=[{"id": "residual_bleeding", "severity": "minor"}]))]),
        ]),
        stage("myomectomy_10_closure", "腹壁关闭", 10, "confirm", "closure_interaction", ["closure"], [
            option("myomectomy_complete_closure", "完成关闭，结束手术", effects(elapsed_time=14, blood_loss=5)),
        ]),
    ]
    return {
        "surgery_open_ventral_hernia": hernia,
        "surgery_breast_tumor": breast,
        "surgery_open_ovarian_cystectomy": ovarian,
        "surgery_open_abdominal_myomectomy": myomectomy,
    }


def main():
    data = json.loads(PATH.read_text())
    stage_map = batch_stages()
    variants = {
        "surgery_open_ventral_hernia": [
            {"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "腹壁缺损显露以后，疝囊与周围腹壁层次比较清楚，当前修补条件尚可。"},
            {"id": "dense_adhesions", "weight": 25, "initial_visibility": 70, "player_hint": "疝囊和周围组织粘连明显，缺损边缘也没有一次完全展开；后续分离和还纳会更依赖稳定的暴露。"},
        ],
        "surgery_breast_tumor": [
            {"id": "standard", "weight": 75, "initial_visibility": 92, "player_hint": "病灶位置和术前标记能够较清楚地对应，预定切除区域容易重新确认。"},
            {"id": "indistinct_margin", "weight": 25, "initial_visibility": 76, "player_hint": "病灶与周围乳腺组织的边界没有想象中清楚，单靠表面观察很难立即确定最令人放心的切除范围。"},
        ],
        "surgery_open_ovarian_cystectomy": [
            {"id": "standard", "weight": 75, "initial_visibility": 90, "player_hint": "患侧卵巢能够顺利带入术野，囊肿轮廓和可保留卵巢组织较容易辨认。"},
            {"id": "adherent_cyst", "weight": 25, "initial_visibility": 72, "player_hint": "囊肿与周围组织粘连较明显，卵巢活动度受限，真正的分离层次需要更耐心地建立。"},
        ],
        "surgery_open_abdominal_myomectomy": [
            {"id": "standard", "weight": 75, "initial_visibility": 88, "player_hint": "肌瘤轮廓能够较清楚地从子宫表面和触感上定位，预定切口方向明确。"},
            {"id": "deep_intramural", "weight": 25, "initial_visibility": 70, "player_hint": "肌瘤位置偏深，表面轮廓并不突出；切开以后才更容易确认真正的分离层次。"},
        ],
    }
    for surgery in data:
        surgery_id = surgery.get("id")
        if surgery_id not in stage_map:
            continue
        surgery["stages"] = stage_map[surgery_id]
        surgery["case_variants"] = variants[surgery_id]
        surgery.setdefault("initial_state", {})["bleeding"] = 0
        surgery["fixed_stage_progress"] = [
            step["progress_delta"]
            for step in surgery["stages"]
            if step["stage_kind"] != "conditional_correction"
        ]
        if surgery_id == "surgery_open_abdominal_myomectomy":
            surgery["name"] = "开腹子宫肌瘤剔除"
    PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")


if __name__ == "__main__":
    main()
