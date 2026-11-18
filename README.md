# 星见医院 · 春日序章 (Hoshimi Hospital: Spring Prologue)

日式 2D 医院生活模拟 × Visual Novel × 成人向角色关系沙箱。

基于 **Godot 4.5.1 标准版（GDScript）** 构建，支持 **简体中文（`zh_CN`）与英文（`en`）双语实时切换**。本作以 **365 天医院日常与人物羁绊**本身作为核心体验（表面像热闹的青春社团，走上手术台则是严谨可靠的 1995–2005 年代日式围术期医院）；独立归档的医学伦理悬疑企划 *CORE* 不作为本作的隐藏主线。

> *注：`project.godot` 中的内部应用版本号仍保留早期标记 `0.1.0`，实际工程已演进至包含 31 名医护／关系角色、普通与 7 席位高级手术、Lv1–Lv5 角色长篇剧情、全员日语短语音、白日梦鉴赏及 v37 安全边界存档的完整沙箱架构。*

---

## 核心特性

### 1. 门诊、住院与双层手术系统
- **门诊接诊（`EncounterSession`）**：基于 **36 个随机患者包**、**8 名剧情客串患者**与 **31 套术式病例模板**生成接诊流程，涵盖问诊、查体、辅助检查、诊断／鉴别诊断、医患沟通、收治住院与同科转诊。
- **术前准备与普通手术（`PreopSession`，32 种术式）**：病房探视、护理准备、手术团队编成（需先在院内结识对应医护）、更衣刷手、麻醉与术式确认、术前触诊、分步术野操作、术中生理危机处理、助手／器械／巡回三岗位纠错及术后成长结算。
- **7 席位高级手术与跨日转诊（`data/advanced_surgery/`，7 台大型术式）**：独立生理与排程模型，支持第一／第二助手、主／副器械护士、主／副巡回护士与麻醉科医生的 **7 人完整手术室点名（Timeout）**、病例板评估、跨日排期与专项剧情联动。
- **医护作为患者（Lv5 `StaffPatientRegistry`）**：独立于随机门诊池的医护患者流程，在复用通用临床／术前管线的同时保留专属角色定制台词与称呼上下文（如普通患者称「医生」、亲近医护按关系称呼名字）。
- **主角五维成长**：随临床与剧情推进结算技术（Skill）、领导力（Leadership）、魅力（Charm）、声望（Reputation）与临床气场（Clinical Presence），逐步解锁高阶术式与关键剧情门禁。

### 2. 人物羁绊、医院日常与多线演出
- **31 个医护／关系角色分包（`data/staff/`）**：覆盖外科、内科、妇科、麻醉科、放射科、药剂科、门诊／病房／手术室护理团队及访问研究医。
- **相识与五阶羁绊分离**：首次结识（`met`）与 `Lv1–Lv5` 羁绊等级独立判断；熟悉度（`0–100`）、隐藏好感、属性门槛与冷却天数共同驱动作者编写的个人章节、跨日特殊事件与日常微事件，不靠刷熟悉度自动满级。
- **丰富的院内外日程（19 个院内／街区地点 + 17 个周日约会地点）**：包含分时段在场调度、工作间隙闲谈、**专属护士（Personal Nurse）**、**下班同行（After-Work Walk）**、**周日普通约会**与**周日全天长篇角色事件**。
- **鉴赏与回想系统**：内置**事件与 CG 鉴赏回想**（零耗时、不重复结算属性或奖励）以及独立的**白日梦模式（`data/daydreams/`）**。
- **亲密事件与日常预约（`FreeHRegistry` + `HProfileSession` V1.3.4）**：支持 Lv4 里程碑亲密演出无缝衔接剧情余韵，以及满足前置条件后的日间邀约与下班赴约（每位开放角色绑定唯一固定地点、归一化多边形部位热区、6 档表情差分、双进入风格、手动冲刺与事后演出）。

### 3. 双语本地化、早年 PC VN 赛璐璐美术与日语语音
- **中英双语全覆盖**：`data/localization/zh_CN.json` 与 `en.json` 覆盖超过 **90,000 条**文本（含全部活跃剧情节点、说话人、选项与 UI 词条），支持运行时无损切换语言。
- **视觉规格**：`1280×800` 逻辑画布（默认窗口 `1152×720`），采用 2000 年代初日式 PC 视觉小说赛璐璐上色风格，配备多服装／多表情透明立绘（含术中刷手服、无菌手术衣与系带口罩差分）、**103 张场景背景**及角色专属事件 CG。
- **BGM 与 31 角色日语语音系统**：独立 `BGM` 与 `Voice` 音频总线；本地集成全员 31 位角色共 **470 条** 24 kHz 日语语音（涵盖分时段问候、档案表情、普通 3 席／高级 7 席手术 Timeout、术中危机与推进反馈、关键剧情节点及 H Runner 全流程），具备三档活跃语音 RMS 动态响度均衡（`data/audio/voice_gain_trim.json`）、`-0.5 dBFS` 硬件防爆音限幅器与 `-9.5 dB` BGM 平滑自动闪避（Ducking）。

### 4. 安全边界事实存档（v37 `boundary_facts_v1`）
- **8 个独立手动槽位 + 原子写入**（`godot/systems/boundary_save.gd`、`save_store.gd`）。
- **严格安全边界限制**：仅允许在**医院导览界面**与**周日菜单界面**存档；门诊、术前、手术中、剧情事件与亲密演出期间严格锁定存档。
- **纯业务事实持久化**：存档只写入已结算的日历分钟、数值、关系等级、稳定全局旗标、已完成事件 ID 与跨日预约等业务事实，**绝不持久化任何剧本内部节点 ID、对白页码或临时会话状态**——即使后续增删对白或重排演出节点，旧档依然稳定可读。详见 [v37 存档边界契约](docs/save_boundary_v37.md)。

---

## 快速启动

### 环境要求
- **Godot Engine 4.5.1 标准版**（GDScript，`GL Compatibility` 渲染器，无需 .NET 版）。
- 玩家直接运行游戏**不需要**安装 Python（Python 仅用于开发期数据校验、导入与本地化审计脚本）。

### 运行方式
1. 打开 Godot 4.5.1 项目管理器，导入仓库根目录下的 [`project.godot`](project.godot)。
2. 按 `F5` 运行主工程（入口场景为 `res://godot/scenes/main.tscn`）。
3. 或通过命令行直接启动：
   ```sh
   # macOS 示例（请替换为本机 Godot 可执行文件路径）
   /Applications/Godot.app/Contents/MacOS/Godot --path /path/to/hoshimi-hospital
   ```

---

## 仓库目录结构

```text
project.godot                 Godot 4.5.1 工程配置（res:// 根目录，1280×800 逻辑画布）
AGENTS.md                     项目最高优先级协作规范、存档红线、剧情原文与本地化门禁
data/                         只读 JSON 游戏内容与 Schema（运行时深拷贝，不回写进度）
  manifest.json               内容总索引
  schemas/                    JSON Schema Draft 2020-12 校验定义
  staff/<id>/                 31 个角色独立内容包（profile/relationship/events/h_* 等）
  patients/                   36 个随机患者包、客串患者、门诊／术前共用模板与性格对白
  cases/ & surgeries/         病例模板、32 种普通术式、触诊与清醒患者术中互动池
  advanced_surgery/           7 席位高级手术术式、专科、排程与术中对白数据
  events/ & daydreams/        全局事件索引、约会地点与白日梦目录
  audio/                      事件／H Runner 语音映射（event_voice_cues.json）与响度均衡表
  localization/               中英双语词典（zh_CN.json / en.json）
assets/                       运行美术与音频资源（characters / backgrounds / events / h / audio）
godot/                        GDScript 引擎运行代码
  scenes/                     主场景入口（main.tscn）
  scripts/                    ContentLoader 只读分包加载与合并
  systems/                    GameState、各流程 Session、Registry、高级手术模型与 v37 BoundarySave
  ui/                         页面编排（app.gd）、角色舞台（character_stage.gd）、BGM 与语音导演
docs/                         架构、上下文、设计规范、QA 报告与可移植工作流文档
  CONTEXT.md                  项目全局上下文与模块地图
  HANDOFF.md                  跨 AI 工具实时交接记录
  design/                     世界观、1995–2005 围术期规范、角色门禁矩阵与设计文档
  skills/                     立绘抠图、CG 方向、角色配音与原生窗口验收工作流说明
research/                     作者剧本原稿（source_scripts）、英文译稿（translations）与候选归档
tools/                        Schema 校验、双语审计、剧本导入器、语音执行器及 Godot 自动化测试集
```

---

## 开发与校验命令

在仓库根目录执行。**注意：任何会读写存档的测试脚本必须传入独立的 `/private/tmp/...` 临时路径，严禁指向或覆盖玩家真实存档目录。**

### 1. Python 静态数据与双语本地化审计
```sh
python3 -m venv .venv
.venv/bin/pip install -r tools/requirements.txt

# JSON Schema 与跨文件引用校验
.venv/bin/python tools/validate_data.py

# 叙事文本与全局 UI 中英双语完整性审计（新增／修改剧情必跑）
python3 tools/narrative_localization_test.py
python3 tools/localization_audit.py
python3 tools/staff_localization_test.py
python3 tools/patient_bundle_localization_test.py
```

### 2. Godot 导入与核心 Headless 回归测试
```sh
# 扫描并导入新增美术／音频资源
godot --headless --path . --log-file /private/tmp/hoshimi-import.log --editor --import --quit

# 基础冒烟与运行时双语加载测试
godot --headless --path . --log-file /private/tmp/hoshimi-smoke.log --script res://tools/smoke_test.gd
godot --headless --path . --log-file /private/tmp/hoshimi-loc.log --script res://tools/localization_test.gd

# v37 安全边界存档与事件禁存锁测试
godot --headless --path . --log-file /private/tmp/hoshimi-bsave.log --script res://tools/boundary_save_test.gd
godot --headless --path . --log-file /private/tmp/hoshimi-savelock.log --script res://tools/narrative_save_lock_test.gd
godot --headless --path . --log-file /private/tmp/hoshimi-store.log --script res://tools/save_store_test.gd -- /private/tmp/hoshimi-save-store-test.json

# 关系门禁、手术推进、高级手术、Free H 预约与语音集成测试
godot --headless --path . --log-file /private/tmp/hoshimi-rel.log --script res://tools/relationship_system_test.gd
godot --headless --path . --log-file /private/tmp/hoshimi-surg.log --script res://tools/surgery_progression_test.gd
godot --headless --path . --log-file /private/tmp/hoshimi-adv.log --script res://tools/advanced_surgery_test.gd
godot --headless --path . --log-file /private/tmp/hoshimi-freeh.log --script res://tools/free_h_scheduling_test.gd
godot --headless --path . --log-file /private/tmp/hoshimi-voice.log --script res://tools/voice_integration_test.gd
```

---

## 扩展与协作文档导航

- **协作规则与红线**：[AGENTS.md](AGENTS.md)
- **项目上下文与角色索引**：[docs/CONTEXT.md](docs/CONTEXT.md)
- **最新开发交接记录**：[docs/HANDOFF.md](docs/HANDOFF.md)
- **v37 安全边界存档契约**：[docs/save_boundary_v37.md](docs/save_boundary_v37.md)
- **多语言本地化架构**：[docs/localization.md](docs/localization.md)
- **角色声线与语音登记表**：[docs/character_voice_ids.md](docs/character_voice_ids.md)
- **新增随机患者指南**：[docs/adding_random_patient.md](docs/adding_random_patient.md)
- **立绘／CG／配音／原生实机验收工作流**：[docs/skills/README.md](docs/skills/README.md)
