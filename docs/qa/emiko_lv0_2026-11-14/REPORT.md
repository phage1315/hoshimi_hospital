# 御堂江美子 Lv0《传闻中的手》V1.2 原生窗口渲染与双语回归验收报告（2026-11-14）

## 1. 验收范围
- 事件 ID：`emiko_intro_rumored_hands`（`data/staff/doc_emiko/events.json`）
- 原稿版本：`research/source_scripts/HOSHIMI_MIDO_EMIKO_LV0_RUMORED_HANDS_V1_2.md`（SHA-256: `479d4b22ba55d59c29895683572a9a6617f1186b624c231cd1bab1fc2fd5a294`）
- 运行门槛保留：`intro_doc_asuka_director_office` + 坂口 `Surgery >= 70`（`skill >= 70`）；已移除旧版 `auto_follow_up`。
- UI 解锁提示修复：`ui.unlock.emiko` 与 `ui.unlock.artoria_emiko`（`app.gd`、`zh_CN.json`、`en.json`）由旧版 `56` 更新为 `70`，且未完成明日香院长室相识时优先提示先推进明日香剧情。

## 2. 实际执行验证与结果
- 逐句原稿与双语审计：`.venv/bin/python tools/emiko_lv0_source_audit.py` → **PASS（`1178 checks; 0 failure(s)`，100% 逐字一致，0 改动）**
- 叙事本地化：`.venv/bin/python tools/narrative_localization_test.py` → **PASS（`49131 checks; 0 failure(s)`）**
- 医护本地化：`.venv/bin/python tools/staff_localization_test.py` → **PASS（`1209/1209`）**
- Headless 专项与关联回归：
  - `tools/emiko_lv0_test.gd` → **PASS（`2776 checks; 0 failure(s)`）**
  - `tools/emiko_early_gate_test.gd` → **PASS（`234 checks; 0 failure(s)`）**
  - `tools/emiko_introduction_reentry_test.gd` → **PASS（`102 checks; 0 failures`）**
  - `tools/boundary_save_test.gd` → **PASS（`1020 checks; 0 failures`）**
  - `tools/narrative_save_lock_test.gd` → **PASS（`6 checks; 0 failure(s)`）**
  - `tools/localization_test.gd` → **PASS（`33 checks; 0 failure(s)`）**
- 原生非 Headless `1280×800` 窗口渲染抓帧：
  - `tools/emiko_lv0_preview_capture.gd` → **PASS（`36 checks; 0 failure(s)`，12 张中英文窗口截图 `01`–`15` 已生成并核对）**
  - 说明：本次原生截图为脚本自动驱动真实窗口渲染抓帧，尚未执行人工鼠标逐拍手动点击游玩。
