# 城宮明日香 Lv1《院长也是外科医生》实装与原生窗口验收报告（2026-11-13）

## 1. 验收范围与交付内容

- **目标角色与等级**：城宮明日香（`doc_asuka`）Relationship `Lv0` → `Lv1` 升阶事件《院长也是外科医生》（*The Director Is Also a Surgeon*）
- **原稿依据**：`research/source_scripts/HOSHIMI_ASUKA_LV1_DIRECTOR_IS_ALSO_A_SURGEON_V1.md`
- **三段式常规手术耦合结构**：
  1. **Scene 1（术前更衣／刷手间，`asuka_lv1_director_surgeon_preop`）**：12 拍线性演出，背景 `scrub_area`，在常规手术工作日选定 `doc_asuka` 为第一助手（`assistant_surgeon`）并进入 `preop_stage_id: "changing"`（`preop_required_flags: ["hands_ready"]`，`priority: 180`）时自动触发；触发后开启当台手术 Lv1 关联态。
  2. **Scene 2（常规手术实战 Runner）**：当台手术 100% 屏蔽术中生理危机（`disable_intraop_crisis = true`），并按暴露／止血／缝合阶段注入 3 句原稿专属一助短台词（`01_exposure`、`02_hemostasis`、`03_closure`，中英双语）。
  3. **Scene 3（术后走廊收尾，`asuka_lv1_director_surgeon_postop`）**：28 拍线性演出（无伪分支），背景 `or_entrance`，于常规手术结算后 `post_surgery_return`（`priority: 220`，含周六下午手术跨过 17:00 加班结算边界）自动触发，原子完成 `doc_asuka` `Lv0` → `Lv1` 升阶并展示关系里程碑完成卡。
- **扫荡保护与中断回滚**：
  - 当 `doc_asuka` 为一助且满足 Lv1 触发条件（或当前手术已进入 Lv1 流程）时，`preparation` 与 `procedure_select` 两阶段的「一键扫荡」按钮自动禁用并展示中英双语原因提示，状态层 `GameState.sweep_active_surgery()` 同步拦截；升至 `Lv1` 后下一台手术自动恢复扫荡可用。
  - 若手术在 Scene 3 完成前中止，或读档恢复时检测到孤立的 `asuka_lv1_director_surgeon_preop` 完成记录，`AsukaLv1.on_surgery_aborted()` / `AsukaLv1.sanitize_after_restore()` 自动回滚前置事件完成态，保持 `Lv0`，下次选她做一助可完整重走。
  - `BoundarySave` v37 持久存档白名单零新增内部演出字段，事件中途禁止存档。
- **新增 7 张 `1024×1536` RGBA 刷手服透明立绘**（`assets/characters/asuka_lv1_v1/doc_asuka/scrubs/`，均开启 `mipmaps/generate=true`）：
  - `masked_bright.png`、`masked_smile.png`
  - `cap_smile.png`、`cap_critique.png`、`cap_shy.png`
  - `hair_down_smile.png`（同时映射 `scrubs/smile` 默认键）、`hair_down_wave.png`

---

## 2. 原稿逐句台词 Audit 与用户授权改动核对

运行 `.venv/bin/python tools/asuka_lv1_source_audit.py`：**`502 checks; 0 failure(s)`**。

除用户明确授权的 **方案 1A（允许工作日全天任意常规手术触发，仅最小化泛化 3 处早间字眼）** 外，其余所有节点对白、旁白、说话人归属、标点与术中 3 句短台词均与原稿 100% 逐字一致：

| 节点 ID | 原稿文本 | 授权泛化后实装文本 | 英文译文 |
|---|---|---|---|
| `al1a_003` | `早上好，隆司医生。今天这台，我来做你的一助。` | `辛苦了，隆司医生。今天这台，我来做你的一助。` | `Good work so far, Dr. Ryuji. For this case today, I'll be scrubbing in as your first assistant.` |
| `al1a_008` | `本来早上是有两个行政会的，不过我看今天的排台表有空档，就把会推到下午了。` | `本来这会儿是有两个行政会的，不过我看今天的排台表有空档，就把会错开了。` | `Originally I had two administrative meetings scheduled around now, so when I saw an opening on today's OR board, I moved them out of the way.` |
| `al1b_028` | `院长迈着轻快的步子朝行政楼的方向走去。手术室外走廊重归上午的安静，但主角看着自己刚刚洗净的双手，总觉得那位笑眯眯的年轻院长，比之前任何时候都要真实得多。` | `院长迈着轻快的步子朝行政楼的方向走去。手术室外走廊重归安静，但主角看着自己刚刚洗净的双手，总觉得那位笑眯眯的年轻院长，比之前任何时候都要真实得多。` | `The director walks briskly away toward the administration wing. Quiet settles back over the corridor outside the OR, and as Ryuji looks down at his freshly washed hands, that smiling young director feels far more real to him than ever before.` |

---

## 3. 执行的检查命令与结果

1. **原稿逐字与全天泛化审计**：
   - `.venv/bin/python tools/asuka_lv1_source_audit.py` → **`ASUKA LV1 SOURCE AUDIT: 502 checks; 0 failure(s) (3/3 user-approved time generalizations verified)`**
2. **叙事与医护本地化检查**：
   - `python3 tools/narrative_localization_test.py` → **`NARRATIVE LOCALIZATION: 47332 checks; 0 failure(s)`**
   - `python3 tools/staff_localization_test.py` → **`STAFF LOCALIZATION TEST: 1200 isolated staff dialogue lines translated`**
   - `python3 tools/localization_audit.py` → **`en: 56631 translations; authored coverage 55682/55682; UI: 801/801`**（全仓库仍因既有 `voice_director.gd` 5 处硬编码中文候选退出码为 `1`，本次新增内容 `0` 缺漏）
   - `.venv/bin/python tools/validate_data.py` → `doc_asuka` 与 `asuka_lv1` 相关检查 **`0` 错误**（全仓库因既有 `serika`/`miyuki`/`takemi`/`backgrounds[77]` 历史积压项退出码为 `1`）
3. **Godot 资源导入与专项／回归测试（独立日志与内存／临时路径，零触碰玩家槽位）**：
   - `/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot --headless --path . --log-file /private/tmp/hoshimi-asuka-lv1-reimport.log --editor --import --quit` → **PASS (`exit 0`)**
   - `/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot --headless --path . --log-file /private/tmp/hoshimi-asuka-lv1-test-final.log --script res://tools/asuka_lv1_test.gd` → **`ASUKA LV1 TEST: 1458 checks, 0 failure(s)` (`exit 0`)**（覆盖：上午常规触发、下午 14:30 触发、周六 16:15 跨 17:00 加班结算触发 Scene 3、一助非明日香不触发、扫荡按钮双阶段禁用与升 Lv1 后恢复、术中 0 生理危机与 3 句专属台词、术中中止回滚重走、v37 `BoundarySave` 孤立前置态清洗与完成后读档幂等、中英双语全节点非空且无中文残留）
   - `tools/boundary_save_test.gd` → **`BOUNDARY SAVE: 998 checks; 0 failures` (`exit 0`)**
   - `tools/event_rendering_save_boundary_test.gd` → **`EVENT RENDERING SAVE BOUNDARY 8203 checks; 0 failures; no files written` (`exit 0`)**
   - `tools/narrative_save_lock_test.gd` → **`NARRATIVE SAVE LOCK: 6 checks; 0 failure(s)` (`exit 0`)**
   - `tools/surgery_history_save_test.gd` → **`SURGERY HISTORY SAVE: 1044 checks; 0 failures` (`exit 0`)**
   - `tools/localization_test.gd` → **`LOCALIZATION: 33 checks; 0 failure(s)` (`exit 0`)**
4. **原生非 Headless `1280×800` 窗口自动演练与实机截图验收**：
   - `/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot --path . --log-file /private/tmp/hoshimi-asuka-lv1-native.log --script res://tools/asuka_lv1_preview_capture.gd` → **`ASUKA LV1 PREVIEW CAPTURE: 133 checks; 0 failure(s)` (`exit 0`)**

---

## 4. 原生窗口 18 张截图清单与目检结论

同目录生成的 18 张 `1280×800` 实机截图（均已抽检核实无黑边／白边残留、无顶栏遮挡、无文本框溢出、事件中存档按钮隐藏）：

- **中文全流程（`zh_CN`）**：
  - `01_zh_preop_sweep_disabled.png` — 术前编组／术式界面「一键扫荡」按钮灰显禁用与原因提示
  - `02_zh_scene1_masked_smile.png` — Scene 1 `scrub_area`：`scrubs/masked_smile`
  - `03_zh_scene1_masked_bright.png` — Scene 1 `scrub_area`：`scrubs/masked_bright`
  - `04_zh_intraop_01_exposure.png` — Scene 2 手术室暴露阶段一助台词 `01_exposure`
  - `05_zh_intraop_03_closure.png` — Scene 2 手术室缝合阶段一助台词 `03_closure`
  - `06_zh_scene3_cap_smile.png` — Scene 3 `or_entrance`：`scrubs/cap_smile`
  - `07_zh_scene3_cap_critique.png` — Scene 3 `or_entrance`：`scrubs/cap_critique`
  - `08_zh_scene3_cap_shy.png` — Scene 3 `or_entrance`：`scrubs/cap_shy`
  - `09_zh_scene3_hair_down_smile.png` — Scene 3 `or_entrance`：`scrubs/hair_down_smile`
  - `10_zh_scene3_hair_down_wave.png` — Scene 3 `or_entrance`：`scrubs/hair_down_wave`
  - `11_zh_lv1_completion_card.png` — 中文 `Lv.1` 关系推进完成卡
- **英文全流程（`en`）**：
  - `12_en_preop_sweep_disabled.png` — 英文术前「Quick Sweep」禁用态
  - `13_en_scene1_masked_bright.png` — 英文 Scene 1 `scrubs/masked_bright`
  - `14_en_intraop_01_exposure.png` — 英文 Scene 2 一助台词 `01_exposure`
  - `15_en_scene3_cap_critique.png` — 英文 Scene 3 `scrubs/cap_critique`
  - `16_en_scene3_cap_shy.png` — 英文 Scene 3 `scrubs/cap_shy`
  - `17_en_scene3_hair_down_wave.png` — 英文 Scene 3 `scrubs/hair_down_wave`
  - `18_en_lv1_completion_card.png` — 英文 `Lv.1` 关系推进完成卡

---

## 5. 未测范围说明

- 本轮原生窗口验收由自动化脚本 `tools/asuka_lv1_preview_capture.gd` 驱动真实 `app.tscn` 渲染并截取窗口帧，尚未进行真人鼠标逐句手动点击通关。
- 全仓库既有遗留项（`voice_director.gd` 5 处未包裹中文、`validate_data.py` 其他角色历史 schema 项）不在本任务修改范围内，保持原状未改动。
