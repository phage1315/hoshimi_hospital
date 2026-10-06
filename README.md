# 星见医院 · 春日序章

日式 2D 医院生活模拟 × Visual Novel × 成人向角色关系沙箱，中文开发原型。当前对外试玩版本为 **v0.1.0**（内部功能里程碑 0.7：医护人物事件）。第一版专注自由、可扩展和高重复游玩的医院沙箱；未来的 CORE 医学伦理悬疑 VN 已独立保存，不作为当前隐藏主线。当前包含问诊、住院、术前至手术结算，以及长期医护角色的首批个人事件。

## 启动

1. 使用标准版 Godot **4.5.1**（GDScript，不需要 .NET）。
2. 在项目管理器导入本目录的 `project.godot`。
3. 按 F6 运行当前主场景，或 F5 运行工程。
4. 点击「开始游戏」阅读短篇入职对话，选择分支后进入医院导览。也可直接从标题页进入导览。
5. 医院导览 → 门诊诊室，接诊本轮随机排到的患者；也可选择一名医生将她转诊并切换到下一位。
6. 「基础问诊」「基础查体」会一次整理必要线索；选择检查、判断诊断、沟通并收住院。
7. 病历默认收起，点击右下角查看；诊断时自动展开，可滚动阅读。底部支持保存、读档。
8. 住院病房 → 探视 / 继续术前安排：说明安排、组队、指派护士、选择准备项目。
9. 护士执行准备 → 更衣 → 刷手 → 进入手术室 → 选择术式与麻醉 → 命令开台、递刀、固定切口 → 下刀与术中互动 → 缝合结算与手术 CG。
10. 在门诊或术前页面都可使用 8 个独立位置保存／读档，原单槽存档自动保留在位置 1。
11. 人物事件会按日期、时段、地点、关系值与前置章节自然出现在医院场景中；人物档案里的「事件测试」可无副作用检查全部分支。
12. 医院导览底部的「事件鉴赏」收录正式完成的事件，可以回想分支，并预留专属CG槽位。

命令行：`godot --path /你的路径/hoshimi-hospital`。

界面使用 macOS 的苹方字体；其他平台需要系统提供中文字体。当前包含七名角色的第三方本地占位素材；出处及状态见 docs/asset_sources.md。无音频依赖。

## 已实现

- 标题页、5 个对话节点、2 个分支选项、7 个导航地点。
- 2 位女医生、3 位成年护士、4 位成年患者的 JSON 占位档案。
- 四名患者具有稳定的主／副性格、压力反应、八项特质与四类恐惧倾向；宣布住院手术、病房、麻醉、下刀和术中互动使用人物专属对白，但不改变医疗结果。
- 新游戏随机排列患者顺序；本轮顺序和转诊记录随存档保存。尚未住院的当前患者可转诊给一名医生并切换到下一位。
- 人物档案和静态关系初值展示；可替换的几何背景、两位人物图片及其余角色剪影。
- 内容加载、JSON Schema、跨文件引用和岗位校验。
- 首位患者：接诊、问诊、查体、检查、诊断反馈、沟通及住院交接。
- 人物立绘配底部短对白，检查结果用简短提示；病历按需展开，只显示已获得线索。
- 基础问诊、查体合并操作；重复操作不重复计时，0.3 存档仍可继续。
- 可选额外检查消耗时间；错误诊断有反馈，允许修正。
- 8 槽手动存档，显示游戏日期、当前候诊患者、完成手术数与保存时间，并恢复病例、病历、关系、事件和日历状态。
- 术前团队：主刀固定玩家，三位手术同事和一位独立病房护士。
- 最多两项额外照顾、患者情绪、人物回应、更衣／刷手及入室条件。
- 病床、更衣区、手术台患者的原生二维占位画面；下刀后从6张女性手术团队CG中稳定随机一张作为全屏背景，读档保持不变。
- 25种术式可结算排班耗时并标记成功；其中新增20种开放式躯干手术，具体操作仍未开放。
- 25条术式病例模板：每条包含患者口述、1–5项症状、查体、相应检查、诊断和鉴别诊断，可供后续随机患者与问诊流程生成。
- 跨越17:00的手术在当晚完成，次日仍从09:00开始；日期切换显示医院夜景转场。
- 神宮寺成美与七瀬恋各4章人物事件，共8个短篇、24个首层选择分支；选择会改变隐藏好感、熟悉度和剧情记忆旗标。
- 七瀬恋与朝倉美幸各10个日常微事件，共20个事件、60个轻选择；已接入看诊后、手术后和地点访问调度。每篇保留一个选择点，并以逐句推进的多轮对话铺垫和收束。
- 人物事件支持前置章节、日期与关系条件，进行中和已完成分支均可存读档。
- 八个事件已配置医院时段与地点情境入口；事件节点按情绪转折切换真实存在的立绘差分。
- 事件鉴赏按完成记录解锁，回想不消耗时间或重复改变关系；CG图片路径可后续逐项填充。
- 医护关系 v1：认识与正式羁绊分离、独立的 Lv1 建立事件、熟悉度驱动的 Lv2–Lv5、隐藏好感倾向、每人五个羁绊／升级槽、固定岗位与午休随机在场、无关系收益的闲谈，以及“认识后才能组队”的手术候选规则。
- 飯村真奈美保留药剂师职业显示，但按医生团队类别参与组队；经验不足者仍可受邀，并在组队与术中使用警告和差异对白。

## 目录

```text
project.godot          Godot 工程入口（资源根目录）
data/                 与引擎独立的 JSON 内容
  schemas/            JSON Schema Draft 2020-12
  characters/ patients/ relationships/ cases/
  surgeries/ teams/ dialogue/ encounters/ preop/ events/
assets/               后续美术、音频、动画
godot/               引擎代码（见下方，不含内容定义）
  scenes/             主场景入口
  scripts/            JSON 加载器
  systems/            对话、病例会话、游戏进度及存读档
  ui/                 界面和占位图形
docs/                架构、美术、数据与手术设计
  design/             沙箱正式规格、对白规范与未来 CORE Story Bible
tools/               内容校验、引擎冒烟测试
research/vndb/       研究资料预留，与游戏内容分离
```

## 验证

```sh
python3 tools/localization_audit.py
python3 tools/dialogue_layout_audit.py
python3 -m venv .venv
.venv/bin/pip install -r tools/requirements.txt
.venv/bin/python tools/validate_data.py
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tools/smoke_test.gd
godot --headless --path . --script res://tools/localization_test.gd
# 测试文件路径必须是独立临时路径，会覆盖该文件；不要指向实际玩家存档。
godot --headless --path . --script res://tools/clinic_test.gd -- /tmp/hoshimi-clinic-test.json
godot --headless --path . --script res://tools/save_store_test.gd -- /tmp/hoshimi-save-store-test.json
godot --headless --path . --script res://tools/test_save_generator_test.gd
godot --headless --path . --script res://tools/preop_test.gd -- /tmp/hoshimi-preop-test.json
godot --headless --path . --script res://tools/surgery_crisis_test.gd
godot --headless --path . --script res://tools/or_table_palpation_test.gd
godot --headless --path . --script res://tools/surgery_progression_test.gd
godot --headless --path . --script res://tools/surgery_phase1c_test.gd
godot --headless --path . --script res://tools/character_event_test.gd
godot --headless --path . --script res://tools/ange_relationship_test.gd
godot --headless --path . --script res://tools/micro_event_test.gd
godot --headless --path . --script res://tools/relationship_system_test.gd
godot --headless --path . --script res://tools/personal_nurse_system_test.gd
godot --headless --path . --script res://tools/adult_intimacy_system_test.gd
godot --headless --path . --script res://tools/maya_character_test.gd
godot --headless --path . --script res://tools/futaba_character_test.gd
godot --headless --path . --script res://tools/text_overflow_test.gd
```

内容校验使用独立 Python 工具；玩家运行游戏不需要 Python。

## 限制与下一步

首个病例使用简化的剧情线索与固定报告，无真实医学操作或个体化治疗建议。检查在本原型中即时返回报告，并累计院内时间；不需要现实等待。患者仍为文字占位，背景仍为通用走廊。

存档覆盖门诊、术前和人物事件进度，不保存入职对话的逐句位置、地点页位置或 UI 滚动位置；没有自动存档。新游戏只清空当前内存进度，已有文件在再次保存时才被替换。8 个手动位置互不覆盖。

已有一段接在术前确认后的手术室互动骨架，包含四种麻醉状态、无麻醉时的一次反悔机会、护士递刀、助手固定切口、下刀反应、恐惧／痛苦／尊严／配合四项反馈、患者性格对白与表情切换，以及缝合后的 CG 与结果结算。现有 25 种术式均有数据驱动的术野确认、团队交流、关键判断和完成复核；错误判断会由助手纠正。清醒患者互动池现有 47 条内容，覆盖六种有效主题、七个术式类别、六台代表性术式的一次性专属互动，以及恶心和嗜睡临时状态；同优先级对白按确定顺序防重复轮换。患者性格目前只改变既有反应文字和视觉表达，不改变数值与手术结果。它目前不包含具体手术执行器、术后关系变化或失败结局。

互动树与扩展方式见 [手术室互动骨架](docs/surgery_interaction_skeleton.md)。下一里程碑为三台 7／12／17–18 步代表性术式垂直切片。

详细玩法与存档约定见 [门诊里程碑](docs/clinic_milestone.md)。

术前玩法与当前范围见 [术前里程碑](docs/preop_milestone.md)；美术需求见 [术前素材清单](docs/preop_art_requests.md)。
