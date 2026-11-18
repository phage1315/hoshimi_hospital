# 御堂江美子 Lv2《这一次听你的》V2.1 原生窗口渲染与双语回归验收报告（2026-11-14）

## 1. 验收范围
- 事件 ID：`emiko_lv2_follow_my_lead`（`data/staff/doc_emiko/events.json`）
- 原稿版本：`research/source_scripts/HOSHIMI_MIDO_EMIKO_LV2_FOLLOW_MY_LEAD_V2_1.md`（SHA-256: `f972a30e2401dd836fd7275417bd4d0c489b928f8a14fcac6eb59d614dc7f660`）
- 节点与分支结构：共 257 个节点（254 个 `presentation: "authored"` 正文拍 `em2_001..em2_254` + 3 个 `presentation: "choice"` 宽幅交互节点 `em2_choice_b1`、`em2_choice_d2`、`em2_choice_f3`），$3 \times 3 \times 3 = 27$ 条分支路径零孤儿节点，全部汇合至 `em2_254 -> @end` 原子性结算。
- 运行门槛与结算边界：
  - `required_events: ["emiko_lv1_first_operation"]`（仅检查 Lv1 持久事件完成记录，不重复手写相识检查，不要求普通同台手术计数）+ `days_after_required_events: 3` + 坂口 `Surgery >= 80`（`skill >= 80`）+ `min_familiarity: 0`；
  - 工作日 `or` 手术室时间窗 `09:00–16:59`（`time_start: 540, time_end: 1019`），耗时 `minutes: 100`，播放期 `locks_saving: true`；
  - 纯固定 VN 演出（约 40 岁清醒女患者择期开腹小肠节段切除＋手工端端吻合）：不调用常规 Surgery Runner、不新增常规可重复术式或提前开放 Lv3 CABG、不递增 `completed_surgeries_total`、不要求也不改变 `nurse_hiroko`／`nurse_moe` 的 `met` 或关系等级；
  - 首次完成原子性结算（仅在 `Scene G` 末拍 `em2_254 -> @end` 生效，事件开场及中途绝不提前解锁）：`doc_emiko` 升至 `Lv2`、发放固定 `Familiarity +10`（`completion_familiarity_bonus: 10`，不乘 `×0.5` 倍率，不重复发放）、写入 `emiko_lv2_complete` 与 `emiko_reliable_surgical_partner`（零额外兴奋伏笔或未注册隐藏属性）、正式发放 `unlock_emiko_surgical_team` 解锁常规／高级手术团队编组资格。

## 2. 实际执行验证与结果
- 逐句原稿、V2.1 定点修订与双语审计：
  - `.venv/bin/python tools/emiko_lv2_source_audit.py` → **PASS（`37641 checks; 0 failure(s)`）**
  - `.venv/bin/python tools/emiko_lv1_source_audit.py` → **PASS（`31274 checks; 0 failure(s)`）**
  - `.venv/bin/python tools/emiko_lv0_source_audit.py` → **PASS（`1178 checks; 0 failure(s)`）**
  - `.venv/bin/python tools/narrative_localization_test.py` → **PASS（`50479 checks; 0 failure(s)`）**
  - `.venv/bin/python tools/staff_localization_test.py` → **PASS（`1209/1209`）**
  - `.venv/bin/python tools/localization_audit.py` → 叙事覆盖 **`58842/58842`**、UI 键 **`803/803`**（全仓仍因既有 `voice_director.gd` 5 行中文退出 1）
  - `.venv/bin/python tools/validate_data.py` → `doc_emiko` 相关报错 **`0`**（全仓仍因既有其他历史项退出 1）
- Headless Godot 专项与关联回归：
  - `tools/emiko_lv2_test.gd` → **PASS（`1625 checks, 0 failure(s)`，覆盖 Lv1 完成记录门禁、零普通同台手术依赖、Surgery 79/80 与 3 日冷却、中途未提前解锁编组、三组分支零属性差原子结算、弘子／萌恵未相识零副作用、Scene G 走廊白大褂切换、UI 中英全流程零中文残留、普通手术团队候选开放、BoundarySave v37 零内部节点泄漏及旧档兼容）**
  - `tools/emiko_early_gate_test.gd` → **PASS（`234 checks; 0 failure(s)`）**
  - `tools/emiko_introduction_reentry_test.gd` → **PASS（`102 checks; 0 failures`）**
  - `tools/emiko_lv1_test.gd` → **PASS（`1433 checks, 0 failure(s)`）**
  - `tools/emiko_lv0_test.gd` → **PASS（`2776 checks; 0 failure(s)`）**
  - `tools/boundary_save_test.gd` → **PASS（`1020 checks; 0 failures`）**
  - `tools/narrative_save_lock_test.gd` → **PASS（`6 checks; 0 failure(s)`）**
  - `tools/localization_test.gd` → **PASS（`33 checks; 0 failure(s)`）**
- 原生非 Headless 窗口渲染抓帧：
  - `tools/emiko_lv2_preview_capture.gd` → **PASS（`93 checks; 0 failure(s)`，共生成 28 张中英文窗口渲染截图 `01`–`28`）**
  - 截图覆盖：医院导览手术室故事徽章（`01`）、Scene A 穿袍戴套／「主刀是你。」／「如果指令值得听。」／萌恵术前核对／清醒患者回应（`02`–`06`）、Scene B 提前掀开系膜与宽幅三选一（`07`–`08`）、Scene C 弘子调侃备垫（`09`）、Scene D V2.1 P0 吻合前复核方式分歧／宽幅三选一／V2.1 P1-2 对系膜缘斜修建议／「够。」（`10`–`13`）、Scene E「没有吵架。那是正常的术中方案讨论。」与「稳定军心」（`14`–`15`）、Scene F 关腹前双人清点／「八十八分。」／宽幅三选一／V2.1 P1-4 扣十二分理由（`16`–`19`）、Scene G 手术部外走廊切换日常白大褂（`white_coat/neutral` & `serious`）与「下一台什么时候？」／「今天是不是你的极限。」（`20`–`22`）、中文结算卡（`23`）以及英文关键节点与结算卡（`24`–`28`）。
  - 说明：本次原生截图为脚本自动驱动真实窗口渲染抓帧，尚未执行人工鼠标逐拍手动点击游玩。
