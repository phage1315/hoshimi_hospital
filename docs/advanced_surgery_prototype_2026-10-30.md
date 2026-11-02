# 高级手术三病例原型：2026-10-30

状态：三台独立可玩切片和正式进度接口已接入；不是完整的二十台高级术式，也不是正式患者／剧情／美术验收。基于用户授权的1–3阶段完成本轮开发。没有提交、推送或修改玩家存档；接手前工作区已有大量未提交内容，均保留。

## 测试入口

标题页 → **DEBUG事件测试中心 → 高级手术 · 三台独立测试**（列表第一项）。不需要培养属性或完成教程。

1. 选 Whipple、盆壁肿瘤切除（髂血管重建）或开胸袖式肺叶切除。
2. 现行默认使用实装医护编队，主刀测试技巧88，助手和护士使用真实能力。可逐岗位改选；选人时显示该人物立绘与原有岗位台词。四档模拟阵容仅保留在数值QA中。
3. 确认排程，点击“测试：前进至预约日期”，开始 Day 2。
4. 手术开始只显示一次现有全麻splash，随后七名医护确认岗位；F/L阶段继续，Whipple的S阶段各提供两个确定性策略选项，另外两台S阶段仍为标准方案占位，P阶段选主刀或两位助手。主刀失败后可自行纠正或请求一次援救；灰色助手按钮的提示说明限制。
5. 完成手术日，Day 3确认结算。首次失败永久锁定；返场失败不撤销首通。
6. 回到病例板，点击“测试：前进至下周一，刷新返场”。退出独立测试后重新进入可以重置本轮演示。

测试日期、主刀技巧88和结果全在独立内存中；默认Dev编组现已采用真实医护能力并验证岗位与14天冷却，测试中开放已实装人物供选。正式入口另检查真实可出勤资格。四档数值fixture仅在QA显式启用，不会冒充角色。默认Dev与正式入口均采用现有生理危机系统；只有显式数值fixture采用旧HP-only模型。Whipple逐阶段数值及验收见[生理接入记录](advanced_whipple_physiology_2026-10-30.md)。2026-10-30后续患者／演出接入见[演出记录](advanced_surgery_presentation_2026-10-30.md)。

也可用 Godot 启动 `tools/advanced_surgery_playtest.gd`，直接打开独立病例板；添加 `-- --en` 为英文。该脚本把整个测试应用的存档路径设到 `/tmp/hoshimi_advanced_manual_<PID>.json`，不读写玩家存档。

## 接入范围

| 术式ID | 阶段数 | P数 | 基础HP成本 |
|---|---:|---:|---:|
| surgery_open_whipple | 13 | 6 | 41 |
| surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction | 12 | 6 | 41 |
| surgery_adv_sleeve_lobectomy | 11 | 5 | 36 |

- 数据在 `data/advanced_surgery/`。普通术式表保持原状，已有Whipple不重复追加；独立Runner按同一稳定ID读取高级定义。
- HP100、概率范围8%–98.5%、护士概率支持上限5pp、一次解剖变体、两名助手独立额度、一次援救、危机成本及HP归零终止均已实现。预览随机流与运行随机流分离。
- 正式医院导览有“高级转诊”入口；未达 Surgery80／Reputation250／既有教程标记时显示锁定说明，不能接受病例。没有新增大手术次数门槛。
- Day1从实际时钟增加60分钟；D2预定09:00开始，占用480分钟工作窗口；D3增加60分钟。日历用现有营业日规则，周日／既有固定剧情锁定期和预约冲突时不接受。已预约的手术／复盘日拦截普通行动及冲突事件；错过开始时间或人员资格变化可重新排程，不重复收取接诊时间。
- 首次失败锁定、首通集合、每周一2个有放回独立抽选的已通关普通术式病例返场、独立占位患者ID、同周不重抽均已实现。刷新不删活跃预约。
- 参与Day2的两名助手立即进入14日历天高级助手冷却；普通手术与剧情不受此冷却影响。
- 复盘复用既有Surgery XP、Leadership、医护训练、团队熟悉度、声望及手术次数接口。明确传Advanced档，避免95+难度误走Legendary档；声望基础40、软上限480／硬上限600。失败沿用现有失败路径，不另发训练奖励或声望。
- 5／10种唯一首通只设置宫园薰／Ray前置flag。本轮仅3种，正常游玩不会达到；未制作相应Quest。

## 工程接口与医护映射

| 业务 | 实际接入位置 |
|---|---|
| 既有内容源 | `godot/scripts/content_loader.gd`及其现有staff／surgery集合；没有另建正式医护库 |
| 高级病例与排程 | `godot/systems/advanced_referral.gd`，调用GameState日历、`advanced_referral_timing_status()`、Free H及朝仓Lv2预约日期 |
| 独立概率／执行 | `advanced_surgery_model.gd`、`advanced_surgery_session.gd` |
| 生理／危机 | `advanced_physiology.gd`薄适配，继承`preop_session.gd`，调用既有战略效果、危机触发与抢救解析；不改普通手术判定 |
| 奖励 | `advanced_settlement.gd`调用`game_state.gd`既有奖励函数；新增可选显式参数，旧调用默认行为保留 |
| 持久化 | `advanced_referral_facts.gd`严格白名单 → `boundary_save.gd`；由GameState统一读写 |
| 界面 | `godot/ui/advanced_referral_view.gd`，入口在`app.gd`；中英文文本在`data/advanced_surgery/ui_text.json` |

| 岗位 | 正式权限／技能 |
|---|---|
| 主刀 | 玩家当前Surgery |
| 第一／第二助手 | `assistant_surgeon`许可，真实`skills.surgery`，预定D2冷却已结束 |
| 主／副器械 | `scrub_nurse`许可，真实`skills.instrument_handling` |
| 主／副巡回 | `circulating_nurse`许可，真实`skills.teamwork` |
| 麻醉医生 | 现有`anesthesiologist`标记，全麻；不加入六人Leadership均值 |

七个岗位不得重复；复用 `staff_can_join_surgery_team()` 与角色岗位白名单。`specialties.json`暂为空：没有擅自把测试御堂型97／Saber型94写入真人物。正式助手目前均只能介入一次；未来作者在独立映射表确认专科／万能专家后才开放对应第二次。

## 存档边界与原稿差异

原稿要求存手术中途进度，与现行agents.md冲突；按已确认的接入计划，以现行安全边界为准。高级病例板、手术和复盘页都不提供保存，只有回到医院导览／周日边界才能保存。

新增`advanced_referral_facts`只包含术式首通／失败、人员冷却日期、本周返场、已接受病例与团队／日期、已结算手术结果以及复盘奖励事实。旧v37无该字段可读。禁止HP、stage ID、index、动作序列、助手额度、术中随机种子、临时演出变体、危机与援救状态进入持久文件；违规字段拒绝读取且不改变当前世界。结果日志中的HP等只在当前内存显示，读档后不补造。

Day2退出进程只能从此前安全存档重新开始，不能续接中途节点。已完成Day2且处于安全导览时可保存结果事实，D3不重演手术。复盘清空预约并登记稳定病例ID，一次性结算；时间保存实际累计数值，不按当前步骤数重算。

## 验证证据

- `tools/advanced_surgery_source_audit.py`：996检查通过。逐项核对36个阶段、中文原名、数值、12组fixture、两句坂口原文、中英文占位和格式参数；12组GDS委托计划与Python完全相同。
- `tools/advanced_surgery_test.gd`：6,443检查通过。涵盖概率、重复操作、援救成败、HP立即失败、首次锁定／返场保留、冷却边界、预约冲突／改期、独立预览RNG、安全存档与奖励幂等、未来5／10阈值。
- `--balance`：12组各25,000次Godot HP-only模拟；Python原稿另跑48组各25,000次。planned最大偏差0.69个百分点，小于原稿3个百分点容差。报告在本目录下`qa/advanced_surgery_2026_10_30/`；这不是正式全生理系统胜率。
- 原生Godot中英文各完成三病例，正式入口另完成真实危机界面与复盘；原生401检查0失败、最终headless410检查0失败。按钮事件自动驱动实际场景，截图检查了病例板、精细操作与危机页，无横向溢出。不是人工逐按钮鼠标测试。
- 既有安全存档974检查、普通手术pilot921检查、高级转诊旧规则16检查全部通过。
- 强制本地化测试29,350检查通过，UI英文754/754，硬编码中文候选0。新增双语bundle由专项审计覆盖。
- 发现既有非本任务失败：`surgery_progression_test.gd`的无麻醉声望旧断言（40检查中1失败），用本轮修改前GameState和BoundarySave副本复现相同失败。`validate_data.py`仍报告原有事件priority／立绘尺寸／选项ID等问题；本次未放宽schema或改动这些既有内容，因此不宣称全项目验证全部通过。

## 尚未完成的正式内容

1. 三例正式专属病例、完整VN／CG；目前按用户授权借用随机池三位患者的既有头像和全麻splash，未改写其普通病例。
2. Whipple的13阶段生理数据和W04/W11双选项已按后续授权补齐并测试，标记P0_TUNING_PENDING_GAMEPLAY_APPROVAL；其余两台仍缺专属S策略与生理效果数据。
3. 正式医护专科／万能专家映射、训练上限签字及返场权重；目前采用明确的测试／回退规则。
4. Surgical Quality／Patient Experience的高级术式适配：显示待补，绝不根据HP授予S/A评级。
5. Quick Advanced按V2正式取消；教程、宫园薰和Ray新剧情不在本轮范围。

## 2026-11-01 当前覆盖规则

本文件前文保留原型阶段历史。四台现已运行，正式池采用三格FIFO、次月1／15发布、周一固定两例有放回返场、无高级扫荡。第5／6内容尚未ready。V2业务病例可保存case_seed，不保存术中RNG；奖励使用原resolver。详见[2026-11-01 V2实装与验收](advanced_referral_rules_v2_implementation_2026-11-01.md)。
