# 阿尔托莉雅·潘德拉贡（`doc_artoria`）Lv4《只是阿尔托莉雅》（V1.1）验收报告

- **日期**：2026-11-16
- **事件 ID**：`artoria_lv4_just_artoria`（`target_level: 4`，`benefit_id: "unlock_intimacy_events"`）
- **原稿归档**：`research/source_scripts/HOSHIMI_ARTORIA_LV4_JUST_ARTORIA_V1_1.md`
- **英文译稿**：`research/translations/artoria_lv4_en.json`（`"Just Artoria"`，241 个节拍节点 + 9 个选项全量覆盖，0 CJK 残留，0 `Saber`／`Maiya` 内部代号泄露）

## 一、逐句台词 Audit 与获授权微调披露

运行 `.venv/bin/python tools/artoria_lv4_source_audit.py` 对全部 `3 × 3 × 3 = 27` 条选项路径逐句比对 V1.1 原稿，结果 **`24929 checks; 0 failure(s)`**：

1. **2 处用户明确授权的服装词微调（对齐 Codex 常服种子图）**：
   - 第二幕 `ar4_s2_04`：`还特意拍了拍自己宽松的衬衫外套以示清白：` → `还特意拍了拍自己宽松的开衫外套以示清白：`（对齐 `taiga_casual_seed.png` 青绿开衫）；
   - 第三幕 `ar4_s3_02`：`穿着浅色针织长衫的爱丽丝菲尔·冯·爱因兹贝伦` → `穿着深酒红色长袖上衣与白色长裙的爱丽丝菲尔·冯·爱因兹贝伦`（对齐 `irisviel_casual_seed.png` 酒红上衣与白裙）。
2. **32 处 `动作／神态前缀：「角色台词」` 结构性拆分为相邻两节点**：前节点保留原旁白与原冒号 `：`，后节点保留原说话人与引号台词，字词与标点零增删。
3. **非玩家可见工程块过滤**：原稿规格说明、幕标题与第五幕 `> **【语义接入点：调用阿尔托莉雅首次 H（H Runner）】**` 工程块仅用于配置 `ar4_s5_1_26` 的 `action = "launch_artoria_lv4_h"`，不进入玩家可见对白。

## 二、美术资源与占位配置

- **19 张 `1024×1536` 透明 RGBA 立绘（本地 `BiRefNet-ToonOut` 离线抠图，`mipmaps/generate=true`）**：
  - 阿尔托莉雅 Lv4 四套专属着装（14 张）：`lv4_outing/{neutral,smile,sparkle,shy}`、`lv4_home/{neutral,smile,shy,soft}`、`lv4_apron/{serious_blush,embarrassed}`、`lv4_morning/{neutral,sparkle,serious,smile}`（档案衣柜在 `artoria_lv4_complete` 前隐藏防剧透，解锁后开放浏览）；
  - 藤村大河院外常服（3 张）：`taiga_fujimura/casual/{smile,laugh,grateful}`；
  - 爱丽丝菲尔院外常服（2 张）：`irisviel/casual/{smile,warm}`。
- **8 张 `1376×768` 专属场景背景（`assets/backgrounds/artoria_lv4_v1/`）**：车站钟塔街角、藤村剑道场门前外廊、竹叶亭定食屋、城郊庭园茶室、星见川傍晚河岸步道、阿尔托莉雅自宅客厅（夜）、自宅卧室（夜，兼供后续自宅 Free H 复用）、自宅开放式厨房与窗边餐桌（晨）。
- **H Runner Placeholder 与 Free H 预注册**：
  - `ar4_s5_1_26` 优先读取 `FreeHRegistry.load_bundle("doc_artoria", locale)`（正式素材就位后自动切换），当前进入禁存档 `artoria_lv4_h_placeholder`，点击继续无缝进入 `ar4_s5_2_01` 夜间专属余韵与第六幕清晨厨房早餐，不提前结算 Lv4；
  - `godot/systems/free_h_registry.gd` 登记 `doc_artoria`（唯一固定地点 `home` / `"阿尔托莉雅自宅"`，`content_status: "pending_assets"`），医护档案页安全显示禁用态 `"亲密事件已解锁 · 素材待补"`。
- **CG Placeholder（供后续 Codex 制作接入）**：
  - 在 `data/staff/doc_artoria/cg_mapping.json` 的 `artoria_lv4_just_artoria.planned_placeholders_for_codex` 与 `assets_manifest.json` 预登记第 6.1 幕清晨厨房冒烟轻喜剧 CG（`ar4_s6_1_07..13`）及可选定食屋／客厅构图节点区间。

## 三、实际执行验证

- `.venv/bin/python tools/artoria_lv4_source_audit.py` → `24929 checks; 0 failure(s)`
- `python3 tools/narrative_localization_test.py` → `54962 checks; 0 failure(s)`
- `python3 tools/localization_audit.py` → `90366 translations; UI 845/845; 0 hard-coded Chinese candidates`
- `python3 tools/staff_localization_test.py` → `1209 isolated staff dialogue lines translated`
- `.venv/bin/python tools/validate_data.py`（过滤 `artoria|taiga|irisviel|ar2_|ar3_|ar4_`）→ `0` 报错
- Headless：`artoria_lv4_test.gd`（`6044/0`）、`free_h_scheduling_test.gd`（`110/0`）、`artoria_lv3_test.gd`（`8236/0`）、`relationship_gate_matrix_test.gd`（`66/0`）、`boundary_save_test.gd`（`1020/0`）、`narrative_save_lock_test.gd`（`6/0`）、`localization_test.gd`（`33/0`）、`smoke_test.gd`（`0` 失败）
- 原生 `1280×800` Metal 窗口合成 GUI 通关：`artoria_lv4_preview_capture.gd` → `5651 checks; 0 failure(s); 1228 GUI clicks; 40 screenshots`（截图位于本目录 `01_*.png`–`40_*.png`）

## 四、未测与待补范围

- 阿尔托莉雅专属 H Profile／自宅 H CG、第六幕清晨厨房事件 CG（已留 Codex 映射占位）及角色语音 WAV 尚未制作；
- 尚未执行人工物理键鼠手点、自动播放逐拍计时与 Windows 导出包重打包；未触碰真实玩家存档槽位。
