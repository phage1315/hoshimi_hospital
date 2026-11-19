# 御堂Lv5七张CG接入验收 — 2026-11-18

用户批准的7张CG已复制到 `assets/events/emiko_lv5_cg_v1/`，逐文件字节比较与批准源图一致。awake_blush/awake_trust采用裸肩v2，旧候选保留。cg_mapping覆盖45节点；corridor_lapel为画廊封面，show_on_complete=true。

## 内容与回归

- `python3 tools/import_emiko_lv5.py`：完成。移除CG演出/画廊字段后，导入前后事件JSON完全一致；中英localization、bundle、relationship亦与本轮前快照完全一致。
- `.venv/bin/python tools/emiko_lv5_source_audit.py`：28119 checks，0 failures。系统python缺Pillow的首次尝试失败，已使用项目venv重跑。
- `python3 tools/narrative_localization_test.py`：56512 checks，0 failures。
- `python3 tools/localization_audit.py`：93500 translations，全覆盖。
- Godot `--headless --script res://tools/emiko_lv5_test.gd`：32338 checks，0 failures；退出0，有ObjectDB退出清理警告。
- Godot `--headless --editor --import --quit`：7图导入，退出0；系统CA/沙箱editor_settings写入警告，不影响项目资源导入。

## 原生显示

使用 `tools/emiko_lv5_cg_preview.gd` 复用御堂原生驱动，隔离/private/tmp存档与偏好，仅设置内存前置。中英文分别以合成鼠标点击导览→主角办公室→结束工作日进入；其后跳至CG检查点并点击继续。此为原生渲染检查点，非完整剧情重玩或人工点击。

检查7图×2语言、实际纹理、无立绘叠加、2秒揭示后对白恢复、事件存档锁与非终场CG退出。14截图；抽看中文羞恼/英文终场，面部清晰且对白可读。首轮把@end作为节点导致脚本错误，已修正测试驱动（不改生产代码），首轮日志与截图保留。复验pass2：93 checks、0 failures、18次合成GUI点击、14截图，退出0；日志无ERROR/SCRIPT ERROR。原生窗口置前后完成。

未进行发行包验收，未全程重新点击剧情，未单独点击完成页奖励。本轮没有新增对白或改变解锁条件；无commit/push。

## 2026-11-18 交叉复查与接线修复（Antigravity）

- 复查确认 7 张 `1536×1024 RGB` CG、`.png.import`/`.ctex`、`assets_manifest.json` SHA-256、45 个连续节点进出场边界及画廊封面 `corridor_lapel.png` 均已正确落位。
- 发现并修复 3 处接线与回归细节：
  1. `em5_s6m_04`（原无立绘旁白节点带 `"hide_portrait": true`）挂入 `cg_path` 后触发 `tools/validate_data.py` 报错 `hidden-portrait node cannot also provide character art`：在 `tools/import_emiko_lv5.py` 的 `apply_cg_mapping()` 中移除冲突的 `hide_portrait`/`portrait_path` 并重跑导入，消除该校验错误；
  2. `tools/import_emiko_lv5.py` 内 `lv5_assets` 的 3 条旧 CG 占位字典同步更新为全部 7 条正式 `event_cg` 元数据，并在 `tools/emiko_lv5_source_audit.py` 新增 7 张 CG 规格、45 节点映射与无 `hide_portrait` 冲突断言（`28241 checks; 0 failure(s)`）；
  3. 启用 `show_on_complete: true` 后，终场 `@end` 会先进入 `character_event_reward`（`EventRewardCG` + `EventRewardContinue`）再进入 `character_event_complete`：同步更新 `tools/emiko_lv5_test.gd`（`32362 checks; 0 failure(s)`，含画廊 `GalleryEvent_emiko_lv5_hands_of_god` 解锁断言）与原生 `tools/emiko_lv5_cg_preview.gd`（补齐中英双语通关奖励卡片 `zh_CN_event_reward_card.png` / `en_event_reward_card.png` 截图及真实合成 GUI 点击 `EventRewardContinue` → `character_event_complete` → `ReturnMap`，共 `114 checks; 0 failures; 25 GUI clicks; 16 screenshots`）。
