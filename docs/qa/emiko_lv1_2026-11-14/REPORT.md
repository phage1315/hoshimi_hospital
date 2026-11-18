# 御堂江美子 Lv1《她的手术》V2.2 原生窗口渲染与双语回归验收报告（2026-11-14）

## 1. 验收范围
- 事件 ID：`emiko_lv1_first_operation`（`data/staff/doc_emiko/events.json`）
- 原稿版本：`research/source_scripts/HOSHIMI_MIDO_EMIKO_LV1_HER_SURGERY_V2_2.md`（SHA-256: `b1364ddf58d799bcdda710e774b72936c39c9dfad7fb608e86430ed865de694a`）
- 节点与分支结构：共 213 个节点（210 个 `presentation: "authored"` 正文拍 `em1_001..em1_210` + 3 个 `presentation: "choice"` 宽幅交互节点 `em1_choice_b1`、`em1_choice_c1`、`em1_choice_e1`），$3 \times 3 \times 3 = 27$ 条分支路径零孤儿节点，全部汇合至 `em1_210 -> @end` 原子性结算。
- 运行门槛与结算边界：
  - `required_events: ["emiko_intro_rumored_hands"]`（严格检查持久事件完成记录，单纯 `met == true` 不得解锁）+ `days_after_required_events: 3` + 坂口 `Surgery >= 75`（`skill >= 75`）+ `min_familiarity: 0`；
  - 工作日 `or` 手术室时间窗 `09:00–16:59`（`time_start: 540, time_end: 1019`），耗时 `minutes: 90`，播放期 `locks_saving: true`；
  - 纯固定 VN 演出：不调用常规 Surgery Runner、不递增 `completed_surgeries_total`、不要求也不改变 `nurse_hiroko`／`nurse_moe` 的 `met` 或关系等级；
  - 首次完成原子性结算：`doc_emiko` 升至 `Lv1`、发放固定 `Familiarity +10`（`completion_familiarity_bonus: 10`，不乘 `×0.5` 倍率，不重复发放）、写入 `emiko_lv1_complete` 与 `emiko_postop_excitement_hint`、保持常规手术团队编组资格锁定至 `Lv2`（`emiko_lv2_follow_my_lead`）。

## 2. 实际执行验证与结果
- 逐句原稿、V2.2 专项修正与双语审计：
  - `.venv/bin/python tools/emiko_lv1_source_audit.py` → **PASS（`31274 checks; 0 failure(s)`）**
  - `.venv/bin/python tools/emiko_lv0_source_audit.py` → **PASS（`1178 checks; 0 failure(s)`）**
  - `.venv/bin/python tools/narrative_localization_test.py` → **PASS（`49739 checks; 0 failure(s)`）**
  - `.venv/bin/python tools/staff_localization_test.py` → **PASS（`1209/1209`）**
  - `.venv/bin/python tools/localization_audit.py` → 叙事覆盖 **`58102/58102`**、UI 键 **`803/803`**（全仓仍因既有 `voice_director.gd` 5 行中文退出 1）
  - `.venv/bin/python tools/validate_data.py` → `doc_emiko` 相关报错 **`0`**（全仓仍因既有其他历史项退出 1）
- Headless Godot 专项与关联回归：
  - `tools/emiko_lv1_test.gd` → **PASS（`1433 checks, 0 failure(s)`，覆盖 `met` 与持久完成记录区分、Surgery 74/75 Gate、27 路核心三组分支零属性差原子结算、弘子／萌恵未相识零副作用、UI 中英全流程零中文残留、BoundarySave v37 零内部节点泄漏及旧档兼容）**
  - `tools/emiko_early_gate_test.gd` → **PASS（`234 checks; 0 failure(s)`）**
  - `tools/emiko_lv0_test.gd` → **PASS（`2776 checks; 0 failure(s)`）**
  - `tools/emiko_introduction_reentry_test.gd` → **PASS（`102 checks; 0 failures`）**
  - `tools/boundary_save_test.gd` → **PASS（`1020 checks; 0 failures`）**
  - `tools/narrative_save_lock_test.gd` → **PASS（`6 checks; 0 failure(s)`）**
  - `tools/localization_test.gd` → **PASS（`33 checks; 0 failure(s)`）**
- 原生非 Headless 窗口渲染抓帧：
  - `tools/emiko_lv1_preview_capture.gd` → **PASS（`82 checks; 0 failure(s)`，共生成 25 张中英文窗口渲染截图 `01`–`25`）**
  - 截图覆盖：医院导览手术室故事徽章（`01`）、Scene A 开台前 `sterile` 立绘与「迟到三十秒。」／患者安抚／「我负责把手术做好。」（`02`–`05`）、Scene B 宽幅三选一与弘子弯眼（`06`–`07`）、Scene C 停手制止／宽幅三选一／V2.2 修正 #4 双人交叉核对（`08`–`10`）、Scene D 局麻插曲「……有意思。」与「非常喜欢。」（`11`–`12`）、Scene E 宽幅三选一／V2.2 修正 #2 无菌手套动作／V2.2 修正 #3 关腹前后两次清点／「八十五分。」（`13`–`16`）、Scene F V2.2 修正 #1 摘口罩前 `hide_portrait` 与摘下口罩后 `scrubs/warm` 亮眼特写及走廊窗前余温（`17`–`19`）、中文结算卡（`20`）以及英文关键节点与结算卡（`21`–`25`）。
  - 说明：本次原生截图为脚本自动驱动真实窗口渲染抓帧，尚未执行人工鼠标逐拍手动点击游玩。
