# 职业气场与罕见病例复核：2026-10-27

## 用户最终规则

- 阶段净累计上限：门诊±3、术前±2、术中±5；总职业气场仍为−200～200。
- 细致解释、回应患者感受、额外照顾偏温柔（负值）；简短告知、强调配合偏强势（正值）。按具体行为判断，不根据对白字数自动推断。
- 显示“温柔+／++”“强势+／++”；无麻醉最终开台显示“强势+++”，原始增量+5。提示框说明准确数值与阶段上限；不是保证每次都获得全额变化。
- 无麻醉选择与坚持准备本身不重复加分；`start_none_surgery`最终开台一次+5归入术中。随后按阶段原始净合计裁限，关照可以抵消强势；已经超出上限的原始累计须先抵消超出部分。声望规则未改。
- 技术操作与必经解释保持0；不会因诊断正确、下刀、选择某种麻醉或委派护士本身自动增加气场。

## 已接入范围

门诊6项；术前模板18项（其中旧固定术中桥接选项只做兼容，常规手术使用动态互动）；3项额外照顾在实际执行时结算，勾选／取消不结算。动态术中50组106项已逐项标定，其中103项非零、3项中性；恶心／嗜睡8项；运行时尊严／配合中断6项；额外不必要准备2项、忽略硬膜外覆盖警告1项、无麻醉最终开台1项。可见按钮与勾选项统一从实际数据读取提示，中英文均覆盖。

新气场账目按门诊／术前／术中聚合为数值记录，不保存导致数值变化的选择ID、标签或逐步路径。存档格式不变；已经结算的历史气场与时间不按新上限重算。当前会话的原始净值、节点和复核分支仅留内存。

## 大开腹探查变体

- 基线原稿来自`data/cases/surgery_case_templates.json`，所有旧正文与三条原始分支均保留。`runtime_options`只开放用户指定的两项；第二项气场+2，第一项0；trust忽略。
- 普通患者完成门诊收住院后，首次进入术前会话抽8%。先显示原始复核旁白，再分开呈现原始引号内患者抗拒和引号后的旁白；选择后医生说原始dialogue，随后旁白显示原始outcome，再回到ward_visit。仅拆显示话轮，未改字句、归属或顺序。
- 原稿无该片段独立耗时定义，本次继续按钮不额外计时；原有门诊、准备与手术耗时仍按原定义执行。
- 拒绝手术／回家分支未开放。护士反对、医生质疑、术后对质仅保留原模板钩子，不生成未授权对白；本次没有新增持久分支状态或触发后续事件。
- 英文补齐复核、患者抗拒、两条医生回应及结果；原保留分支的英文也补齐。复核节点在语言切换时从当前语言重建显示，不重放效果。

## 验证

- `tools/clinical_presence_source_test.py`：2,936条原有字符串、顺序、说话人和ID不变；核对两项效果及8%概率。
- `tools/clinical_presence_test.gd`：headless 6,772项0失败；原生窗口6,780项0失败、8张截图。覆盖所有动态互动和提示、直接生成的中断选项、额外照顾两种执行路径、阶段正负上限、无麻醉一次+5、重复点击、双语复核分支直至实际手术完成、跨语言内存恢复、完整门诊自然入口、禁止中途存档、删除变体定义后旧结果可读、时间与数值不变、隔离文件回存。
- `boundary_save_test.gd`：912项0失败；`surgery_temporary_condition_reconnect_test.gd`：918项0失败。
- `graphic_preop_explanation_test.gd`：418项0失败；原3条旧断言要求术前可保存，本次仅迁移为全程禁存档与空持久快照。没有放宽边界。
- `outpatient_history_dialogue_test.gd`：944项0失败；原夹具比较两次独立随机菜单的完整快照而失败，本次只把对照夹具的诊断菜单随机化关闭，不改正式游戏的随机排列。
- 叙事本地化：18,781项0失败；英文UI749/749，localization_audit通过。
- 全量`validate_data.py`仍有既有失败；用修改前HEAD数据在内存中替换读取后跑同一校验，报错日志逐字节相同。涉及旧cameo路径schema、千早事件优先级／角色引用、访客及医护出没、芹香约会地点等；不宣称全库校验通过。
- headless保留现有macOS CA提示。初次原生窗口在沙箱内退出，授权运行的原生窗口测试正常；没有覆盖玩家存档，没有提交／推送／发布。

证据：[测试日志与截图](qa/clinical_presence_2026-10-27/)。原生测试为程序驱动，非人工逐操作游玩。截图抽查中文门诊、英文病例复核：标识与选项完整；英文正文仍沿用既有可在词中换行的排版，本次未调整全局对白排版。

## 数据清单（原始增量，仍受阶段上限限制）

### 门诊

| 组／阶段 | 选项 | 气场 |
| --- | --- | ---: |
| `reception` | 先安抚她 | -1 |
| `exam` | 请患者稍微解开衣物 | -1 |
| `exam_undress_decision` | 放弃完全脱衣查体 | -1 |
| `exam_undress_decision` | 权威说服 | +1 |
| `exam_undress_decision` | 温柔说服 | -1 |
| `exam_undress_decision` | 威胁 | +1 |

### 术前模板及旧兼容选项

| 组／阶段 | 选项 | 气场 |
| --- | --- | ---: |
| `ward_visit` | 详细说明，留时间提问 | -1 |
| `ward_visit` | 简短告知安排 | +1 |
| `graphic_preop_question` | 简短而适当地回答 | -1 |
| `graphic_preop_question` | 绘声绘色地回答 | +1 |
| `operating_room` | 再安抚她一句 | -1 |
| `procedure_mismatch` | 无视患者，仍按错误术式继续 | +2 |
| `general_induction` | 回应她并说明接下来会睡着 | -1 |
| `general_induction` | 简短示意后开始诱导 | +1 |
| `surgery_start_none` | 暂停，重新选择麻醉 | -1 |
| `operative_contact` | 暂停并确认她的感受 | -2 |
| `operative_contact` | 提醒她保持不动 | +1 |
| `operative_contact` | 不打断操作，继续推进 | +2 |
| `ongoing_interaction` | 持续说明进度 | -1 |
| `ongoing_interaction` | 保持目光回应她 | -1 |
| `ongoing_interaction` | 只专注于操作 | +1 |
| `closure_interaction` | 告诉她最困难的部分结束了 | -1 |
| `closure_interaction` | 请她再配合最后片刻 | +1 |
| `closure_interaction` | 沉默完成收尾 | +1 |

### 动态术中互动

| 组／阶段 | 选项 | 气场 |
| --- | --- | ---: |
| `contact_pain_incision_01` | 说明手术已经开始并提醒她保持呼吸 | -1 |
| `contact_pain_incision_01` | 简短告诉她一切按计划进行 | +1 |
| `contact_pain_incision_01` | 要求她继续配合 | +1 |
| `contact_no_anesthesia_incision_01` | 回应她，放慢动作并引导呼吸 | -1 |
| `contact_no_anesthesia_incision_01` | 要求她忍耐并继续手术 | +2 |
| `contact_no_anesthesia_incision_02` | 短暂停手，确认她仍能配合 | -2 |
| `contact_no_anesthesia_incision_02` | 继续当前操作 | +2 |
| `contact_no_anesthesia_incision_03` | 明确拒绝追加麻醉，让团队放慢动作 | +0 |
| `contact_no_anesthesia_incision_03` | 明确拒绝追加麻醉并继续手术 | +2 |
| `contact_default_01` | 确认已经开始并说明情况稳定 | -1 |
| `contact_default_01` | 简短确认已经开始 | +1 |
| `contact_default_01` | 让她安静配合 | +1 |
| `progress_fear_default_01` | 说明当前进度仍符合计划 | -1 |
| `progress_fear_default_01` | 告诉她手术仍在继续 | +1 |
| `progress_fear_default_01` | 要求她不要分心 | +2 |
| `progress_default_01` | 向她说明当前阶段 | -1 |
| `progress_default_01` | 告诉她仍按计划进行 | +1 |
| `strain_pain_default_01` | 暂停片刻并说明刚才的感觉 | -2 |
| `strain_pain_default_01` | 引导她呼吸并继续 | -1 |
| `strain_pain_default_01` | 要求她坚持 | +1 |
| `strain_default_01` | 解释这是当前步骤带来的牵拉感 | -1 |
| `strain_default_01` | 告诉她感觉会很快过去 | +1 |
| `dignity_low_exposure_01` | 确认只保留必要术野并重新遮盖 | -1 |
| `dignity_low_exposure_01` | 解释当前暴露范围的必要性 | -1 |
| `dignity_low_exposure_01` | 要求她不要在意 | +2 |
| `dignity_default_01` | 确认遮盖并说明只暴露必要区域 | -1 |
| `dignity_default_01` | 说明当前步骤很快结束 | +1 |
| `ongoing_fear_default_01` | 说明手术仍按计划进行 | -1 |
| `ongoing_fear_default_01` | 简短回答一切正常 | +1 |
| `ongoing_default_01` | 给出简短而明确的配合指示 | +1 |
| `ongoing_default_01` | 告诉她保持现在这样即可 | +0 |
| `closure_default_01` | 告诉她主要步骤已经完成 | -1 |
| `closure_default_01` | 告诉她正在完成最后检查 | +1 |
| `abdominal_strain_pain_01` | 说明正在完成腹腔内的当前步骤 | -1 |
| `abdominal_strain_pain_01` | 让她慢慢呼吸并坚持片刻 | -1 |
| `pelvic_dignity_exposure_01` | 说明当前阶段并确认保护非必要暴露 | -1 |
| `pelvic_dignity_exposure_01` | 确认正在按术前计划进行 | +1 |
| `pelvic_dignity_default_01` | 说明当前步骤和术前计划一致 | -1 |
| `pelvic_dignity_default_01` | 确认手术仍按计划进行 | +1 |
| `breast_dignity_exposure_01` | 确认范围仍与术前计划一致并保护遮盖 | -1 |
| `breast_dignity_exposure_01` | 确认仍在预定范围内 | +1 |
| `breast_dignity_default_01` | 说明当前阶段仍符合术前计划 | -1 |
| `breast_dignity_default_01` | 确认仍按原计划进行 | +1 |
| `cardiac_progress_fear_01` | 说明当前进度并确认团队仍按计划操作 | -1 |
| `cardiac_progress_fear_01` | 确认仍按计划进行 | +1 |
| `cardiac_progress_default_01` | 说明当前手术阶段 | -1 |
| `cardiac_progress_default_01` | 确认手术仍按计划进行 | +1 |
| `contact_pain_incision_02` | 回应她并确认目前仍按计划进行 | -1 |
| `contact_pain_incision_02` | 简短确认后继续 | +1 |
| `contact_fear_incision_01` | 告诉她刚刚完成了哪一步 | -1 |
| `contact_fear_incision_01` | 让她听着你的声音保持呼吸 | -1 |
| `contact_fear_incision_01` | 要求她不要继续追问 | +2 |
| `progress_fear_fatigue_01` | 说明目前阶段和剩余进度 | -1 |
| `progress_fear_fatigue_01` | 确认手术仍按计划进行 | +1 |
| `progress_fear_fatigue_02` | 给她一个清楚的阶段标记 | -1 |
| `progress_fear_fatigue_02` | 告诉她已经完成了重要部分 | -1 |
| `strain_pain_traction_02` | 暂缓牵拉，让她重新放松 | -2 |
| `strain_pain_traction_02` | 引导她缓慢呼气并放松紧绷的部位 | -1 |
| `strain_pain_pressure_01` | 暂停并重新调整持续压力 | -2 |
| `strain_pain_pressure_01` | 说明这段压力感还会持续片刻 | -1 |
| `dignity_low_exposure_02` | 让团队收拢无关区域的覆盖 | -1 |
| `dignity_low_exposure_02` | 承认她的不适并说明当前必要范围 | -1 |
| `dignity_cooperation_exposure_01` | 确认只保留必要人员与术野 | -1 |
| `dignity_cooperation_exposure_01` | 确认团队只关注必要区域 | -1 |
| `ongoing_fear_fatigue_01` | 在操作间隙给出简短进度 | -1 |
| `ongoing_fear_fatigue_01` | 告诉她情况稳定 | +1 |
| `ongoing_fear_fatigue_02` | 说明下一个阶段性目标 | -1 |
| `ongoing_fear_fatigue_02` | 告诉她正在接近下一个节点 | +0 |
| `ongoing_pain_position_01` | 让巡回护士检查支撑和受压点 | -1 |
| `ongoing_pain_position_01` | 说明不能自行移动并指导小幅放松 | -1 |
| `closure_fear_closure_01` | 确认已进入关闭阶段 | -1 |
| `closure_fear_closure_01` | 告诉她正在完成最后处理 | +1 |
| `closure_fear_closure_02` | 说明主要步骤完成，正在逐项复核 | -1 |
| `closure_fear_closure_02` | 确认正在收尾 | +1 |
| `closure_pain_closure_01` | 短暂停顿并处理她的疼痛 | -2 |
| `closure_pain_closure_01` | 配合呼吸节奏继续关闭 | -1 |
| `abdominal_ongoing_pressure_01` | 说明正在完成腹腔内的重要阶段 | -1 |
| `abdominal_ongoing_pressure_01` | 确认压力感与当前步骤相符 | +1 |
| `pelvic_ongoing_position_01` | 让巡回护士重新检查支撑点 | -1 |
| `pelvic_ongoing_position_01` | 指导她分段放松腰腿 | -1 |
| `breast_closure_fear_01` | 说明手术范围已按术前计划完成 | -1 |
| `breast_closure_fear_01` | 确认正在按计划收尾 | +1 |
| `urologic_strain_pressure_01` | 暂停片刻并让她调整呼吸 | -2 |
| `urologic_strain_pressure_01` | 说明深部牵拉感来自当前阶段 | -1 |
| `thoracic_progress_fatigue_01` | 说明胸腔手术目前所处阶段 | -1 |
| `thoracic_progress_fatigue_01` | 确认关键阶段正按计划推进 | +1 |
| `thoracic_ongoing_position_01` | 让巡回护士复核肩背支撑 | -1 |
| `thoracic_ongoing_position_01` | 说明固定必要性并指导局部放松 | -1 |
| `cardiac_ongoing_fatigue_01` | 持续用简短信息维持她的方向感 | -1 |
| `cardiac_ongoing_fatigue_01` | 确认团队仍按计划推进 | +1 |
| `vascular_progress_deep_01` | 说明已进入计划中的关键阶段 | -1 |
| `vascular_progress_deep_01` | 确认当前变化符合预期 | +1 |
| `vascular_ongoing_pressure_01` | 帮助她辨认感觉并说明当前进度 | -1 |
| `vascular_ongoing_pressure_01` | 确认团队正在密切观察 | +1 |
| `hysterectomy_signature_01` | 逐项确认当前范围与术前同意一致 | -1 |
| `hysterectomy_signature_01` | 确认没有超出既定范围 | +1 |
| `ovarian_cystectomy_signature_01` | 说明当前仍按术前器官保留计划进行 | -1 |
| `ovarian_cystectomy_signature_01` | 确认仍以保留正常组织为目标 | +1 |
| `myomectomy_signature_01` | 明确确认当前没有改变术式 | -1 |
| `myomectomy_signature_01` | 确认仍按原计划处理 | +1 |
| `breast_tumor_signature_01` | 重新确认切除范围与术前标记一致 | -1 |
| `breast_tumor_signature_01` | 确认仍在既定边界内 | +1 |
| `mastectomy_signature_01` | 承认她的失落并确认手术范围 | -1 |
| `mastectomy_signature_01` | 确认团队将严格按同意范围完成 | +1 |
| `cabg_signature_01` | 用简短语言说明已进入计划中的重建阶段 | -1 |
| `cabg_signature_01` | 确认正在完成预定的关键步骤 | +1 |

### 临时状况

| 组／阶段 | 选项 | 气场 |
| --- | --- | ---: |
| `nausea` | 暂停操作，亲自安抚并调整体位 | -2 |
| `nausea` | 让助手医生稳定患者并说明情况 | -1 |
| `nausea` | 让巡回护士准备吸引、冷巾并安抚 | -1 |
| `nausea` | 维持当前节奏，暂不处理 | +2 |
| `drowsiness` | 亲自呼唤并重新确认意识与指令 | -2 |
| `drowsiness` | 让助手医生持续呼唤并复述指令 | -1 |
| `drowsiness` | 让巡回护士持续观察并保持言语刺激 | -1 |
| `drowsiness` | 继续手术，不打断当前操作 | +2 |

