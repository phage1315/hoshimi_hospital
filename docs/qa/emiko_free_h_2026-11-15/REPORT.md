# 御堂江美子（`doc_emiko`）H Profile 1.3 / 里程碑 H Runner / 手术室 Free H 生产就绪验收报告（2026-11-15）

## 1. 资源完整性与 SHA-256 核验

- `assets/h/doc_emiko/body_map.png`：`1024×1536` RGBA，SHA-256 `54bac0dd3f04d2d225d240a8bb8e38d98ea7fdea568b31e941b7ceb41c6135a4`
- `assets/h/doc_emiko/scene_cg.png`（来自 `_staging/00041-654548775.png` 原样复制）：`1536×1024` RGBA，SHA-256 `33855b309a85d13e7fe6a98a9259e812a7bd0c7b8b14b016c68c1e8c9d76267b`
- `assets/h/doc_emiko/aftercare_cg.png`（来自 `_staging/00035-1477984867.png` 原样复制）：`1536×1024` RGBA，SHA-256 `2696d019fc40c67b88c61d50c555f4941812a06f68326786fbde5f577878c8b3`
- `assets/h/doc_emiko/portrait_{neutral,annoyed,pleased,flustered,delighted,peak}.png`：全部存在且真透明 RGBA，通过 `docs/skills/hoshimi-h-profile/scripts/inventory.py` 校验 `errors: []`、`hotspot_regions: 9`、`hotspot_polygons: 14`。

## 2. 双模式运行与生产门控验证

- **Lv4 里程碑模式（`emiko_lv4_emikos_secret` 第 6.1 幕 `em4_s6_1_24` `launch_emiko_lv4_h`）**：
  - `begin_emiko_lv4_first_h()` 自动加载 `FreeHRegistry.load_bundle("doc_emiko", locale)` 并以 `milestone` 模式启动交互式 H Runner：跳过日常随机入场词，使用纯御堂 6 句 Phase 2 序列（已为小夜香专属 3 句插播补上 `actor_id == "doc_sayaka"` 守卫），手动完成高潮后跳过通用 2 句 Free H 事后词，无缝衔回 `em4_s6_2_01..34` 首次专属事后剧情。
- **日常可重复 Free H 模式（四楼手术室 `21:00` 演出时钟）**：
  - 仅在同时满足完成 `emiko_lv4_emikos_secret`、`emiko_lv4_complete`、`level >= 4` 与 `unlock_intimacy_events` 后开放；白天人物界面点击 `FreeHBooking` 直接锁定四楼手术室并展示中英双语回应，下班 `16:00` 触发 `21:00` 手术室 Free H（不改动已结算工作日时钟），全流程禁止存档，结束后经跨日界面回到次日 `09:00` 安全边界且零污染持久数值／旗标。

## 3. 执行命令与结果

- `.venv/bin/python tools/emiko_h_profile_source_audit.py` → `244 checks; 0 failure(s)`
- `.venv/bin/python tools/emiko_lv4_source_audit.py` → `2327 checks; 0 failure(s)`
- `python3 tools/narrative_localization_test.py` → `52239 checks; 0 failure(s)`
- `tools/emiko_h_profile_test.gd`（Headless）→ `307 checks; 0 failure(s)`
- `tools/emiko_free_h_bodymap_test.gd`（Headless）→ `94 checks; 0 failure(s)`
- `tools/free_h_scheduling_test.gd`（Headless）→ `109 checks; 0 failures`
- `tools/emiko_lv4_test.gd`（Headless）→ `5489 checks, 0 failure(s)`
- `tools/emiko_free_h_e2e_test.gd`（原生 `1280×800` Metal 窗口 `Window.push_input`，共 246 次真实 GUI 鼠标事件，`zh_CN` + `en`）→ `390 checks; 0 failures`（26 张窗口截图与 `results.json` 存于本目录）
- `tools/emiko_lv4_preview_capture.gd`（原生 `1280×800` Metal 窗口）→ `118 checks; 0 failure(s)`
- `tools/boundary_save_test.gd` → `1020 checks; 0 failures`；`tools/narrative_save_lock_test.gd` → `6 checks; 0 failure(s)`；`tools/localization_test.gd` → `33 checks; 0 failure(s)`

## 4. 未测范围

- 本次为自动化脚本与原生窗口 `Window.push_input` 驱动验证，尚未由真人在打包发行版上手工游玩。所有测试均使用内存或 `/private/tmp/` 临时路径并已清理，未读写玩家真实存档。
