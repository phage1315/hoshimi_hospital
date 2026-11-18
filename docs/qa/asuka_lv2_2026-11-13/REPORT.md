# 城宮明日香 Lv2《合适的人，合适的手术袍》实装与验收报告（2026-11-13）

## 1. 实装范围概览

- **原稿依据**：`research/source_scripts/HOSHIMI_ASUKA_LV2_RIGHT_PERSON_RIGHT_GOWN_V1_1.md`（V1.1 定稿，正文 214 拍 + 2 组双选 RP 分支共 4 个选项，100% 原字原句保留，零改写、零剧透字样）。
- **事件 ID 与关系门槛**：
  - 事件 ID：`asuka_lv2_right_person_right_gown`（登记于 `data/staff/doc_asuka/lv2_events.json`，通过 `data/staff/doc_asuka/bundle.json` 的 `additional_character_event_files` 加载，并在 `data/staff/doc_asuka/relationship.json` 挂载为 `target_level: 2, content_status: "authored"`）。
  - 触发门槛：`doc_asuka` 已相识（`met == true`）、当前 `level == 1`、`asuka_lv1_director_surgeon_postop` 已完成、`familiarity >= 25`、主角 `charm >= 25`、满足 3 日关系里程碑冷却、非休院工作日（周一至周六）、当前无进行中常规手术／术前准备／特殊事件阻塞，且医院时钟位于 **`12:00–16:00`（`720–960`）** 下午开放窗口，入口地点为 **`director_office`（院长室）**，结算耗时 **`125` 分钟**。
- **三幕舞台演出与立绘资源**：
  - **Scene A（三号样衣试穿讨论）**：会议室群像演出（`conference_room`），复用 `doc_asuka`（`white_coat`）、`doc_emiko`、`doc_artoria`、`doc_aoi` 既有立绘；通过 `event_portraits` 与 `speaker_label` 登场，不要求配角提前 `met == true`，亦不污染配角自身 `met` 状态。
  - **Scene B（新人外科医生相泽麻纪面试）**：直接复用 Codex 已定稿的 `doc_maki` 原作画风面试西装四表情透明立绘 `assets/characters/maki_original_style_v1/doc_maki/interview/{neutral,focused,worried,relieved}.png`（未改动 `data/staff/doc_maki/*` 任何文件，未重跑 `import_maki_staff.py`）；含 Choice B1（`al2_choice_b1`，`presentation: "choice"` 宽幅双按钮，零属性差 RP 分支）。
  - **Scene C（四号雾天蓝样衣试穿评审）**：新增生成并经本地离线 `BiRefNet-ToonOut` 抠图（`1024×1536` RGBA，开启 `mipmaps/generate=true`）注册的 3 张明日香无帽无口罩侧腰系带四号样衣立绘：
    - `assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/smile.png`
    - `assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/proud.png`
    - `assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/reluctant_cuff.png`
    并含 `nurse_hiroko` 尺码复核客串及 Choice C1（`al2_choice_c1`，零属性差 RP 分支）。
- **相泽麻纪延期约一个月报到契约（`godot/systems/asuka_lv2.gd`）**：
  - 完成本事件原子将 `doc_asuka` 升至 `Lv2`，写入稳定全局故事标记 `asuka_lv2_complete` 与 `maki_aizawa_offer_accepted`，并利用 `BoundarySave` v37 既有白名单字段 `character_completions[].completed_day` 持久记录面试录用日 `interview_day`（零新增存档字段、零内部节点状态持久化）。
  - 严格保持 `doc_maki` 的 `met == false` 且 `maki_lv0_onboarding` 未完成：事件结束后，麻纪**不会**进入 `known_staff_ids()`、常规手术助手池、高级转诊手术一助／二助池、周日约会列表或医院导览地图，直至未来约一个月后（`day >= interview_day + 30` 的首个开放工作日）独立实装并完成 `maki_lv0_onboarding`。

---

## 2. 实际执行的静态审计与引擎测试

| 检查项 | 执行命令 | 结果 |
|---|---|---|
| 原稿逐句、零剧透、四分支图与立绘／Mipmap 审计 | `.venv/bin/python tools/asuka_lv2_source_audit.py` | **PASS（`3292 checks; 0 failure(s)`）** |
| 相泽麻纪 V1.1 / V1.3 既有数据无回归审计 | `python3 tools/maki_source_audit.py` && `python3 tools/maki_v1_3_source_audit.py` | **PASS** |
| 全量叙事双语本地化测试 | `python3 tools/narrative_localization_test.py` | **PASS（`47994 checks; 0 failure(s)`）** |
| 医护独立台词双语测试 | `python3 tools/staff_localization_test.py` | **PASS（`1209/1209`）** |
| 本地化覆盖率审计 | `python3 tools/localization_audit.py` | 叙事 **`56355/56355`**、UI **`801/801`**（全仓仍因既有 `voice_director.gd` 5 行中文退出 1） |
| 数据结构与引用校验 | `.venv/bin/python tools/validate_data.py` | `doc_asuka` / `doc_maki` / `lv2_events` **0 错误**（全仓因既有其他角色积压项退出 1） |
| Godot 资源与 Mipmap 导入 | `/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot --headless --path . --log-file /private/tmp/hoshimi-asuka-lv2-import-2.log --editor --import --quit` | **PASS（退出 0）** |
| 明日香 Lv2 专项回归（门槛矩阵、配角 met 隔离、4 分支等价、麻纪全入口锁定、v37 存读档、中英 UI 与画廊回放） | `.../Godot --headless --path . --log-file /private/tmp/hoshimi-asuka-lv2-test-3.log --script res://tools/asuka_lv2_test.gd` | **PASS（`3697 checks, 0 failure(s)`）** |
| 相泽麻纪医生与约会／术中回应回归 | `.../Godot --headless --path . --log-file /private/tmp/hoshimi-maki-staff-retest.log --script res://tools/maki_staff_test.gd` | **PASS（`84 checks, 0 failures`）** |
| 明日香 Lv1 联动剧情回归 | `.../Godot --headless --path . --log-file /private/tmp/hoshimi-asuka-lv1-retest.log --script res://tools/asuka_lv1_test.gd` | **PASS（`1468 checks, 0 failure(s)`）** |
| v37 存档边界与语言切换回归 | `boundary_save_test.gd` / `event_rendering_save_boundary_test.gd` / `narrative_save_lock_test.gd` / `surgery_history_save_test.gd` / `localization_test.gd` | **全部 PASS（`1020/0`、`8223/0`、`6/0`、`1064/0`、`33/0`）** |
| 原生非 Headless `16:10` 窗口实机抓帧验收 | `.../Godot --path . --log-file /private/tmp/hoshimi-asuka-lv2-preview-2.log --script res://tools/asuka_lv2_preview_capture.gd` | **PASS（`71 checks, 0 failure(s)`，生成 `01`–`20` 共 20 张 `1152×720` 实机截图并逐张目检）** |

---

## 3. 原生窗口截图索引（同目录 `01`–`20`）

- **中文实机流程（`01`–`13`）**：
  - `01_zh_map_director_office_badge.png`：工作日下午医院导览「院长室」Lv2 事件可用提示。
  - `02_zh_scene_a_emiko_critique.png`：Scene A 绘美子吐槽三号样衣像直筒麻袋。
  - `03_zh_scene_a_narumi_collar_tease.png`：Scene A 鸣海调侃领口摩擦红印。
  - `04_zh_scene_b_maki_greeting.png`：Scene B 相泽麻纪面试西装 `neutral` 初登场自我介绍。
  - `05_zh_scene_b_maki_hemostasis_focused.png`：Scene B 相泽麻纪 `focused` 回答术中止血判断。
  - `06_zh_scene_b_maki_probed_worried.png`：Scene B 相泽麻纪 `worried` 坦言夜班节奏与术后手绘复盘（长句自动分页 `继续 ▷` 无裁切）。
  - `07_zh_scene_b_choice_b1.png`：Scene B 双选按钮 `al2_choice_b1`（`1100×54` 单行完整显示）。
  - `08_zh_scene_b_maki_offer_relieved.png`：Scene B 相泽麻纪 `relieved` 正式接受录用（约一个月后报到）。
  - `09_zh_scene_c_asuka_sample_gown_smile.png`：Scene C 明日香换上四号雾天蓝样衣 `sample_gown/smile`。
  - `10_zh_scene_c_choice_c1.png`：Scene C 双选按钮 `al2_choice_c1`。
  - `11_zh_scene_c_asuka_proud.png`：Scene C 明日香双手叉腰 `sample_gown/proud` 得意点评侧缝省道。
  - `12_zh_scene_c_hiroko_and_reluctant_cuff.png`：Scene C 宽子持软尺复核袖长 + 明日香 `sample_gown/reluctant_cuff` 不舍脱衣。
  - `13_zh_lv2_completion_card.png`：结算卡片（`关系提升至 Lv.2 / 耗时 125.0 分钟 / 现在是 15:40`）。
- **英文实机流程（`14`–`20`）**：
  - `14_en_scene_b_maki_greeting.png`、`15_en_scene_b_choice_b1.png`、`16_en_scene_b_maki_offer_relieved.png`、`17_en_scene_c_asuka_sample_gown_smile.png`、`18_en_scene_c_choice_c1.png`、`19_en_scene_c_hiroko_and_reluctant_cuff.png`、`20_en_lv2_completion_card.png`。

---

## 4. 未测范围与后续边界说明

1. 本轮原生窗口截图由 `tools/asuka_lv2_preview_capture.gd` 在真实 macOS 非 Headless 窗口渲染管线自动推进抓帧（`1152×720`，`16:10` 等比缩放），尚未进行人工鼠标逐拍点击游玩。
2. 相泽麻纪的正式入职事件 `maki_lv0_onboarding`（录用后约一个月报到、纯 VN 首台助手磨合演出并解锁 `met = true` 与助手池／周日约会）属后续独立剧本范围；`godot/systems/asuka_lv2.gd` 已预留 `onboarding_earliest_day()`、`onboarding_ready_workday()` 与 `ready_for_onboarding_event()` 供后续直接对接。
3. 全程仅使用内存与独立临时测试状态，未读写任何玩家存档槽位。
