# 御堂江美子（`doc_emiko`）Relationship Lv5《神的双手》（V1.0）验收报告

- **日期**：2026-11-17
- **事件 ID**：`emiko_lv5_hands_of_god`
- **归档原稿**：`research/source_scripts/HOSHIMI_MIDO_EMIKO_LV5_HANDS_OF_GOD_V1_0.md`
- **英文译稿**：`research/translations/emiko_lv5_en.json`（标题：`"Hands of God"`）
- **导入清单**：`research/imports/emiko_lv5_2026-11-17.json`

---

## A. 静态审计、逐句原文对账与中英双语覆盖

1. **原文逐句对账（`.venv/bin/python tools/emiko_lv5_source_audit.py`）**
   - 结果：`EMIKO LV5 SOURCE AUDIT: 28119 checks; 0 failure(s)`
   - 穷举全部 `2 × 2 × 2 × 2 = 16` 条选项路径（共 317 个正文节拍节点 ＋ 4 个 `"presentation": "choice"` 选项节点 ＝ 321 节点），验证正文、说话人归属、标点与顺序 100% 与 `V1_0.md` 一致。
   - 仅含维持 VN 节点与 Godot `Label` 正常渲染所必需的 3 类纯技术语法处理（全部登记于 `research/imports/emiko_lv5_2026-11-17.json`）：
     - 5 处叙事动作混排句（`动作前缀：「角色台词」`）按冒号拆分为相邻旁白节点＋角色对白节点（零增删字符）；
     - 4 处非剧情内联 Markdown 粗体星号（`**一周**`、`**「一号手术室」**`、`**城宮明日香**`、`**肝动脉吻合**`）去除外层 `**`；
     - 1 处外层斜体语法（`*（明日香院长……）*`）去除首尾 `*`。
2. **中英本地化门槛**
   - `python3 tools/narrative_localization_test.py`：`56512 checks; 0 failure(s)`
   - `python3 tools/localization_audit.py`：`93500 translations; authored coverage 64903/64903; UI 845/845; 0 hard-coded Chinese candidates`
   - `python3 tools/staff_localization_test.py`：`1209 isolated staff dialogue lines translated`
   - `.venv/bin/python tools/validate_data.py`（过滤 `doc_emiko|emiko_lv5|haruko|naomi|em5_`）：`0` 报错（全库仍含其他角色既有内容校验项，未宣称全库清零）。
3. **高瀬晴子与宮原奈緒美全套 13 张透明立绘（方案 B）与隔离核验**
   - 基础种子离线抠图（5 张，本地 `tools/portrait_matting.py` `birefnet-toonout-fp16.onnx` `--resize-mode keep`）＋ 整图衍生表情差分（8 张，归档于 `research/generated_candidates/emiko_lv5_portraits_v1/` 后经本地 `BiRefNet-ToonOut` 透明化），全部 `RGBA` 顶角透明并开启 `mipmaps/generate=true`：
     - 高瀬晴子常服（Act 1 门诊回忆）：`casual/{neutral,smile,afraid}.png`（`1024×1536` RGBA）
     - 高瀬晴子病号服（Act 6 联合查房）：`ward/{neutral,smile,shy,pain}.png`（`1024×1536` RGBA）
     - 高瀬晴子手术帽（Act 4 走廊＆一号室）：`or_cap/{calm,afraid}.png`（`1448×1086` RGBA）
     - 宮原奈緒美病号服（Act 6 联合查房）：`ward/{neutral,smile}.png`（`1024×1536` RGBA）
     - 宮原奈緒美手术帽（Act 4 走廊＆二号室）：`or_cap/{calm,smile}.png`（`1448×1086` RGBA）
   - `haruko_takase` 与 `naomi_miyahara` 仅作为本事件剧情患者出场，完全隔离于 `data/patients/` 随机门诊池与 `data/surgeries/` 队列之外。

---

## B. Godot 4.5.1 Headless 专项与存档边界回归

运行二进制：`/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot`（全部使用 `/private/tmp/` 独立日志与临时存档路径，零触碰玩家槽位）：

| 脚本 | 结果 | 覆盖重点 |
|---|---|---|
| `--headless --editor --import --quit` | 退出码 `0` | 4 张患者透明 PNG 导入及 `mipmaps/generate=true` 重导入 |
| `tools/emiko_lv5_test.gd` | `32338 checks; 0 failure(s)` | 熟悉度 `74/75`、技术 `89/90`、冷却 `2/3` 天、`staff_as_patient_program_authorized` 开关、周六／周日／`Day 364–365`／住院患者／高级转诊冲突拦截；中英双语 16 路径全遍历；`Day T+1 09:00` 原子升至 Lv5；零声望增减、零配角熟悉度漂移、零新增主任竞争布尔键；`doc_emiko` 在 `staff_patient_profiles.json` 建档前 `staff_patient_unlocked("doc_emiko") == false`；v37 `BoundarySave` 零内部节点泄漏与内部节点改名读档兼容 |
| `tools/emiko_lv4_test.gd` | `5491 checks; 0 failure(s)` | 前置 Lv4 回归无退化 |
| `tools/relationship_gate_matrix_test.gd` | `66 checks; 0 failure(s)` | 全院关系门槛矩阵回归 |
| `tools/staff_patient_lv5_readiness_test.gd` | `1420 checks; 0 failures` | Lv5 医护患者就绪度回归 |
| `tools/boundary_save_test.gd` | `1020 checks; 0 failures` | v37 安全边界存档纯净性 |
| `tools/narrative_save_lock_test.gd` | `6 checks; 0 failure(s)` | 剧情进行中禁止存档锁验证 |
| `tools/localization_test.gd` | `33 checks; 0 failure(s)` | 运行时双语切换 |
| `tools/smoke_test.gd` | `0 failure(s)` | 全院基础冒烟 |

*（注：旧 `tools/relationship_system_test.gd` 仍含 pre-v37 历史 `relationship_state` 字典键假设导致脚本报错，属既有陈旧测试，未擅改该旧脚本。）*

---

## C. 原生窗口合成 GUI 实机点击与截图验收

- 命令：
  ```sh
  /Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot \
    --path . \
    --log-file docs/qa/emiko_lv5_2026-11-17/engine.log \
    --script res://tools/emiko_lv5_preview_capture.gd
  ```
- 渲染环境：`OpenGL API 4.1 Metal - 88.1 - Compatibility - Using Device: Apple - Apple M2`（可见原生窗口 `1280×800` 逻辑画布／`1152×720` 窗口输出，**合成 GUI 鼠标事件 `root.push_input`，非物理人工点击**）。
- 结果：`EMIKO LV5 NATIVE PREVIEW: 8011 checks; 0 failure(s); 1537 GUI clicks; 41 screenshots`，`engine.log` **0 报错、0 警告**。
- 实际覆盖路径：由医院导览真实点击 `Location_player_office` → `OfficeEndWorkday`（`结束工作，今天下班 →` / `End Workday`）触发下班事件进入 `emiko_lv5_hands_of_god`，逐句点击走完中文 `a-a-a-a`、`b-b-b-b` 与英文 `a-a-a-a`、`b-b-b-b` 四轮完整六幕流程，目视抽查确认晴子常服微笑／害怕、一号室手术帽泛泪、病房扯痛／大红脸／欣喜微笑及奈绪美手术帽／病房微笑全部正常显示，英文界面零 CJK 残留，`Day T+1 09:00` 结算页及返回可存档医院导览地图均通过。

---

## D. 覆盖边界与后续可选扩展项

1. **事件 CG 预留位**：已在 `data/staff/doc_emiko/cg_mapping.json` 预留 3 处推荐 CG 节点区间（Act 6 傍晚走廊理平领口封面、Act 2 布帘后红脸、Act 5 显微肝动脉吻合验看），后续填入路径重跑 `python3 tools/import_emiko_lv5.py` 即可自动挂载并启用完成奖励页。
2. **医护作为患者临床对白**：`doc_emiko` 的 23 项患者美术已就绪，待后续补充 `data/staff_patient_profiles.json` 双语患者档案后即可正式开放日常预约。
3. **未测范围**：未进行物理人工键鼠手点与 Windows/macOS 导出包（PCK）重打包测试。
