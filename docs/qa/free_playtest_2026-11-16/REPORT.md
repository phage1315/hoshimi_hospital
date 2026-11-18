# 《星见医院》自由游玩与全模块 Bug / UX 深度巡检报告（2026-11-16）

## 1. 测试范围、方法与边界声明

- **执行性质**：只读实机游玩、故障复现与全量 UI／系统／数据交叉巡检。**未修改任何游戏业务代码、剧本或本地化数据；未读取或写入任何玩家真实存档槽位**（所有运行均在 `root.add_child(app)` 前将 `app.saves.path` 与 `app.title_preferences_path` 指向独立临时路径）。
- **证据分级**（遵循 `docs/skills/hoshimi-native-playtest/SKILL.md`）：
  1. **C 级 · 原生窗口实机游玩与复现**：macOS `1280×800` Metal 可见窗口（非 `--headless`），加载真实 `res://godot/scenes/main.tscn`，通过 `root.push_input()` 合成真实 GUI 鼠标移动／点击与键盘输入（非人工 OS 级手点），累计跑通 5 轮专项游玩驱动（覆盖标题与声明、38 步序章、首日 18 地点探索、多台全麻／局麻／清醒互动／术中危机／一键扫荡／患者转诊完整闭环、周日外出约会与医院串门、节假日门诊、全 31 名医护档案与关系展开面板、专属护士、高级转诊病例板与 7 人编组、事件鉴赏、白日梦、惠惠前台，以及 `zh_CN` / `en` 双语切换），保存 16 张 SFW 实机证据截图于本目录。
  2. **B 级 · Headless 引擎回归抽检**：
     - `tools/boundary_save_test.gd` → `1020 checks; 0 failures`
     - `tools/asuka_lv1_test.gd` → `1468 checks; 0 failure(s)`
     - `tools/asuka_lv2_test.gd` → `3695 checks; 0 failure(s)`
     - `tools/asuka_lv3_test.gd` → `2273 checks; 0 failure(s)`
     - `tools/maki_lv0_test.gd` → `3838 checks; 0 failure(s)`
     - `tools/kaori_lv3_test.gd` → `3738 checks; 0 failure(s)`
     - `tools/relationship_gate_matrix_test.gd` → `66 checks; 5 failure(s)`（见下文 B2-12 分析）
     - `tools/smoke_test.gd` → `15 failure(s)`（旧硬编码断言过期，见下文 B2-12）
  3. **A 级 · 静态本地化与 Schema 数据审计**：
     - `python3 tools/narrative_localization_test.py` → `52239 checks; 0 failure(s)`
     - `python3 tools/localization_audit.py` → `84482 translations; all active authored and UI keys translated`
     - `python3 tools/staff_localization_test.py` → `1209 isolated staff dialogue lines translated`
     - `python3 tools/patient_bundle_localization_test.py` → `6052 English entries; 0 failure(s)`
     - `.venv/bin/python tools/validate_data.py` → 退出码 `1`（共 `1733` 行告警，已归并为 8 类具体数据/Schema 差异）。

---

## 2. P0 / 高优阻断、严重内容泄漏与软锁死 Bug

### P0-1. 医护个人档案页服装下拉框无门槛泄漏 Lv5 手术态与成人全裸立绘，且英文满屏报 `[MISSING TRANSLATION]`
- **代码位置**：`godot/ui/staff_view.gd:3-10, 35-40, 92-133`
- **实机表现与危害**：
  1. **严重内容与剧透泄漏**：`StaffView.render()` 直接遍历 `person.visuals.portraits` 的全部前缀塞入 `StaffOutfitPicker`，未过滤内部技术键，也未校验 `staff_patient_unlocked(id)` 或亲密解锁状态。玩家在 **Day 1（Lv.0 刚相识）** 打开同事档案点击“服装”，即可直接预览：
     - 深山佳织（`doc_rei`）的 **`adult_nude`（成人全裸立绘）**；
     - 朝仓美幸（`nurse_yui`）、御园芹香（`doc_serika`）、折川皐月（`nurse_satsuki`）等人的 `operating_table`、`operating_table_lithotomy`（截石位手术台）、`ward_preparation`、`or_table_awake` 等 Lv.5 医护患者专属立绘；
     - 全员的 `intraoperative_avatar`（术中 HUD 半身小头像被放大到 `470×500`）与 `operating_patient`。
  2. **双语显示崩坏**：`staff_view.gd` 仅映射了 6 种服装与 8 种表情；全库 31 名角色实际存在 **91 处未映射服装项（25 种服装键）与 89 种表情键**：
     - **中文模式（`zh_CN`）**：下拉框直接裸露 `casual_winter`、`intraoperative_avatar`、`director_suit`、`pharm_thoughtful` 等内部 snake_case ID；
     - **英文模式（`en`）**：因键名以 `ui.` 开头触发 `localization.gd` 缺键显式报错，下拉框与右下角直接渲染 **`[MISSING TRANSLATION: ui.staff.outfit.casual_winter]`**（见证据图 `16_en_staff_outfit_missing_translation.png`）。

### P0-2. 跨 `17:00` 加班双时钟分裂导致「顶栏周一 00:20 vs 门诊称周日休诊」软锁死与存档污染（完整复现 `bug_backlog.md` 槽位 4 悬案）
- **代码位置**：`godot/systems/game_state.gd:350-375, 2156-2171, 3901-3920, 4188-4193`；`godot/ui/app.gd:383-395, 1945-1952, 3385-3496, 5819-5854`
- **精确根因与实机复现（见证据图 `14_slot4_monday_0020_sunday_clinic_repro.png`）**：
  1. 当工作日行动跨过 `17:00` 触发 `settle_overtime()` 时，账本 `elapsed_minutes` 立即钳制到**下一自然日 `09:00`**（例如周六加班后，`game.day_number()` 立刻变为周日，`is_sunday()` 为 `true`），同时在内存挂起 `pending_day_exit_workday`（周六）与 `pending_day_exit_clock`。
  2. 只要通过以下任一路径返回大地图而未清理 `pending_day_exit_workday`：
     - **路径 A（下班角色事件漏清）**：`show_day_transition`（`app.gd:5842`）在 `clear_pending_departure_context()`（`5849` 行）之前启动 `_start_exclusive_departure_event()`。事件结束进入 `choose_character_event` 时，`before_day`（`3385` 行）已是次日，结算后 `game.day_number() > before_day`（`3487` 行）为 **`false`**，且通用分支漏调 `clear_pending_departure_context()`，直接跳过跨日界面回到大地图；
     - **路径 B（接诊/术前中途跨 `17:00` 返回导览）**：`15:55` 接诊患者后耗时跨过 `17:00`（未点收治/转诊），点左上角 `← 医院导览`，`day_transition_deferred()` 拦截所有跨日结算；
     - **路径 C（压线事件提前 `return`）**：`manami_lv1_sneeze` 等 5 个在 `app.gd:3461-3468` 提前 `return` 的事件，或周六 `16:00` 芹香影像科读片讨论（`app.gd:3443-3446`）恰好跨入 `17:00`。
  3. **软锁死与污染后果**：
     - 因 `awaiting_departure == true`，`show_map()`（`app.gd:1948`）**跳过周日菜单**把玩家困在平日导览；去办公室点下班又因 `is_hospital_closed_day() == true` 报错 *“休息日请使用星期日安排结束当天”*，两边死锁；
     - 此后每次办公室行动/闲谈只累加 `pending_day_exit_clock`，当累加跨过 `2880` 分钟（48h）时，顶栏 `CalendarHeader` 进位显示 **`周一 00:20`**，而点进门诊读取 `day_number()` 提示 **`今日为周日，普通门诊休诊`**；
     - `can_save_progress()`（`game_state.gd:350`）未拦截 `pending_day_exit_workday > 0`，玩家可在此时看白日梦并存档（存档写入账本值 `周日 09:00`），与此前玩家上传的 `clinic_slot_4.json` 现场完全一致。
  4. **附带衍生 Bug（周五/周六加班吞下班事件）**：`next_after_work_character_event()`（`game_state.gd:2162`）调用 `character_event_available()` 时使用的是已跨日后的 `day_number()` 而非 `current_workday()`——导致周五加班跨 `17:00` 时按“周六”判星期（吞掉 `emiko_lv4`、`ren_lv1` 等周一至周五限定事件），周六加班跨 `17:00` 时按“周日”判星期。

### P0-3. 南条小夜香首周换号事件（`sayaka_week1_phone_exchange`）过期即全档永久死锁整条个人线
- **代码位置**：`data/staff/doc_sayaka/events.json`（`min_day: 2, max_day: 5`）、`godot/ui/app.gd:1963-1971`
- **复现推导**：`sayaka_lv1_first_date` 硬性要求前置 `sayaka_week1_phone_exchange`，而后者仅限 **Day 2–Day 5** 早晨 `day_start` 触发。一旦这 4 个早晨被 `awaiting_departure`（见 P0-2）或更高优先级早晨事件挤占跳过，Day 6 起该事件永久不可触发；但办公室进度 UI 因 `relationship.json` 未列此事件，会永远误报 *“条件已满足；等待合适的时间与地点”*。

### P0-4. 手术台触诊／麻醉测试界面打开「设置」或「读档」弹窗时鼠标指针彻底消失
- **代码位置**：`godot/ui/preop_view.gd:503-506`、`godot/ui/app.gd:365, 5366`
- **实机表现**：`or_table_palpation` 将系统硬件光标设为 `Input.MOUSE_MODE_HIDDEN`，改用主 Viewport 内的 `TextureRect` 绘制器械光标。点击顶部 `设置` 或底部 `读档` 弹出原生 `Window` 模态框时，模态框层级高于 `TextureRect`，而硬件鼠标仍处于隐藏态，导致弹窗内完全看不见鼠标指针。

### P0-5. 标题画面「医院导览」直通按钮无条件跳过序章破坏初始人脉；正式人物页暴露 `事件测试 →`
- **代码位置**：`godot/ui/title_view.gd:42-47`（`TitleDirectory`）、`godot/ui/staff_view.gd:134-135`
- **实机验证**：
  1. 全新启动游戏在标题页点击第 4 个主按钮「医院导览」（无 `OS.is_debug_build()` 保护、无存档存在校验），会直接跳过整个《春日序章》进入 Day 1 地图，导致序章中本应自动相识的 `doc_aoi`、`nurse_haru` 等前辈全部处于 **`met = false`（未相识）** 异常状态；
  2. `doc_aoi` 与 `nurse_haru` 的个人页右上角无条件渲染 `事件测试 →`（见证据图 `01_staff_profile_raw_keys_and_debug_btn.png`），且 `show_character_events()` 等多个测试入口函数内部缺少 `if not OS.is_debug_build(): return` 二次守卫。

### P0-6. 法定节假日门诊页面两行休诊文本物理重叠成乱码，且周日医院顶栏按钮重叠
- **代码位置**：`godot/ui/app.gd:2652` vs `2689`；`godot/ui/app.gd:2008` vs `2010`
- **实机表现**：
  1. **节假日门诊文字碰撞**（见证据图 `11_holiday_clinic_label_collision_zh.png`、`12_holiday_clinic_label_collision_en.png`）：在昭和之日（Day 29，周二）等所有平日法定节假日进入「02 门诊诊室」，`Vector2(65, 405)` 的 `休诊日没有普通候诊患者。` 与 `Vector2(60, 420)` 的 `今日为昭和之日，普通门诊休诊……` 仅差 `15px` 直接叠印在一起（中英文均重叠），且上方 `y = 196` 仍显示相矛盾的 `首位患者已经候诊。`；
  2. **周日医院顶栏按钮重叠**（见证据图 `08_sunday_hospital_header_button_overlap.png`）：周日选择「去医院看看」后，顶栏 `医生属性`（`x = 865..1055`）与 `返回周日安排`（`x = 1045..1220`）横向物理重叠 `10px`。

### P0-7. 设置菜单完全缺失「角色语音音量／静音」控制，BGM 静音后语音与切皮音效仍全音量外放
- **代码位置**：`godot/ui/title_view.gd:121-157`、`godot/ui/voice_director.gd:281-319`、`godot/ui/app.gd:5567`
- **表现**：设置弹窗仅有全屏、自动播放速度与 BGM 音量滑条。全库 417 条角色语音（含日常、剧情与 H Runner 全程语音，增益补偿最高 `+16.5 dB`）走独立 `"Voice"` 总线且无任何音量配置接口；未麻醉切皮视频音效直走 `"Master"` 总线 `0.0 dB`——玩家把 BGM 拉到 0 仍会全音量播放人声。

---

## 3. P1 / 中优功能、双语本地化与 UI 布局 Bug

1. **医护个人页中文模式技能栏显示英文键名**（`godot/ui/staff_view.gd:19-20`，见图 `01`）：
   - `localization.gd` 在 `zh_CN` 下不加载 `zh_CN.json` 而直接使用代码 `fallback`；`staff_view.gd` 传入英文 `skill_id` 作 `fallback`，导致中文界面显示 `surgery 88.0 / teamwork 86.0 / calmness 90.0`。
2. **全项目 23 处 JSON `float` 未转 `int` 导致界面显示 `.0` 小数尾巴**（见图 `01`、`02`、`07`、`09`）：
   - **年龄（6 处）**：`staff_view.gd:43`（`27.0岁`）、`app.gd:2634, 2788`（地点医护行 `23.0岁`）、`clinic_view.gd:11`（门诊副标题 `22.0岁`）、`player_office_view.gd:447`（病例档案 `23.0岁`）、`app.gd:4566`（患者立绘页）、`app.gd:5196`（转诊页 `24.0岁`）；
   - **分钟/天数/章节（11 处）**：`clinic_view.gd:62, 64`（`2.0 分钟`）、`preop_view.gd:235, 243`（`3.0 分钟`、`0 / 2.0`）、`app.gd:2647, 2722, 2820, 2835, 3038`（闲谈/休息 `30.0 分钟` / `15.0 min`）、`player_office_view.gd:523`（职业行动 `60.0分钟`）、`app.gd:2417`（读档后时间记录）、`app.gd:3082, 3162, 3172, 3574`（`第1.0章`、`Lv.2.0`）、`app.gd:3923, 4132, 4290`（`共 3.0 天`）；
   - **技能/熟悉度/门槛/高级转诊（6 处）**：`staff_view.gd:20`、`preop_view.gd:276`（`推荐技术 30.0`）、`app.gd:2132, 2465, 3092` 与 `player_office_view.gd:120`（`熟悉度 0.0`）、`player_office_view.gd:242, 264-268`（`Lv1.0`、`5.0`）、`player_profile_text.gd:31, 33`（读档后声望记录 `+2.0`）、`advanced_referral_view.gd:191, 223, 423`（读档后冷却与排期天数 `16.0`）。
3. **多处中英混排、漏译与硬编码标点**：
   - **英文漏中文/缺键**：转诊页 `app.gd:5196` 硬编码 `"%s · %s岁　/　%s"` 在英文模式漏出中文 `岁`（见图 `07_en_referral_chinese_leak_and_float.png`）；特殊活动 4 种分类（`story_special_event`、`hospital_training`、`career_milestone`、`advanced_referral_tutorial`）在 `en.json` 缺键导致英文列表与鉴赏页渲染 `[MISSING TRANSLATION: ui.special_event.category.*]`（`app.gd:3674, 4289`）；病历 `【...】`（`clinic_view.gd:120`）、关系最近事件 `《...》`（`player_office_view.gd:325`）及术中/结算说话人拼接硬编码中文全角冒号 `：`；
   - **中文漏英文**：门诊低训练收益提示回退为英文 `⚠ Low training value`（`app.gd:2678`）；小夜香 Free H 预约地点在中文模式显示英文 `hotel`（`今晚去hotel？`，`app.gd:1406, 1471`）；抽屉闲谈按钮显示 `min`（`app.gd:2820, 2835`）；特殊事件内高级手术标题回退英文 `ADVANCED SURGERY`（`app.gd:3987-3999`）。
4. **专属护士界面（`player_office_view.gd:98-129`）三处异常**（见图 `09`、`10`）：
   - 未指定专属护士时，`resolve_outpatient_support_actor()` 默认回退外科医生 `doc_aoi`，导致专属护士页顶部显示 **`当前：神宮寺 成美`（`Current: Narumi Jinguji`）**；
   - 中文按钮宽度不足，`利根川 安琪 · Lv0 · 熟悉度 0.0 · 指定` 被截断为 **`指`**；
   - 英文说明文字折 3 行后与第 1 排护士头像/按钮直接重叠，且多枚按钮内数字被截断（`Familiarity 0.` / `Familiarity`）。
5. **手术室医护长立绘名牌被底部对话框遮盖吞没**（`godot/ui/preop_view.gd:182-183, 454`，见图 `06`）：
   - 当 `tall_staff_portrait == true`（切皮前手术室阶段，或关闭右上角术野 HUD 的全屏术野模式）时，医护姓名与岗位标签放在 `y = 600`，随后底部对话框面板建在 `y = 558..700`（`alpha = 0.96`），把名牌直接压在面板底下变成残影。
6. **多处 `1280×800` 固定坐标碰撞与无滚动条溢出风险**：
   - 英文手术台触诊/麻醉测试页左侧说明文字（`preop_view.gd:525-530`）折 6 行延伸至 `y ≈ 303`，压住 `Tools` 标题（`y = 235`）与第 1 个工具按钮（`y = 270`），且力度按钮 `Standard` 被拆行截断；
   - 术前组队 `OptionButton`（`preop_view.gd:886`）未设 `fit_to_longest_item = false`，长英文条目会向右撑过 `x = 760` 撞上立绘；
   - 同事关系详情页重复前缀 `下一等级 Lv1：下一等级：熟悉度 0 / 10`（英文 `Next Level Lv.1: Next level: ...`，`player_office_view.gd:158, 356`，见图 `03`）。
7. **高级手术弹窗与键盘穿透、长日志撑破屏幕及语法细节**：
   - `advanced_referral_view.gd:360, 521` 将弹窗挂在 `host.page` 而非 `app` 下，导致 `app.dialogue_modal_open()` 返回 `false`：打开“对白记录”弹窗时按 `Space/Enter` 会穿透推进底层手术，后台自动播放（硬编码 `1.35s`，忽略全局速度档位）也不会暂停；且 `show_operative_log` 直接把全场历史塞进无滚动条 `AcceptDialog`，中后段会撑出 `800px` 屏幕外；
   - 英文 7 人组队助手卡显示单复数语法错误 `Up to 1 uses`（见图 `13`），多专科标签助手卡第二行存在裁切。
8. **全屏 CG 顶部隐形「设置」误触与非 `Window` 弹层键盘穿透**：
   - 全屏 CG（`MOUSE_FILTER_IGNORE`）遮盖顶栏期间，`Rect2(690, 18, 100, 32)` 的 `PageSettings` 仍响应点击；
   - `WardPreparationSplash`、`AnesthesiaSplash`、`FreeHLocationPicker` 等 `Control` 遮罩未拦截 `Space/Enter` 焦点；对白自动播放期间开关设置弹窗后会在 `0~0.2s` 内秒跳当前未读完台词；对白中修改设置里的自动播放速度后底栏档位名不刷新。
9. **按钮禁用态与“当前选中态”视觉反转 + 原生灰按钮混排**（见图 `04`）：
   - `app.button_at()` 未配 `disabled` StyleBoxFlat；白日梦等级筛选（`daydream_view.gd:63`）、专属护士当前项、患者立绘表情项均用 `disabled = true` 表达“当前选中”，导致**当前选中项边框消失像坏掉，未选中项反而高亮**；
   - 术式列表非推荐项、一键扫荡、高级转诊病例板（`advanced_referral_view.gd:63`）、白日梦条目等直接 `Button.new()` 未套深青主题，呈突兀原生灰皮；`show_advanced_referral_node`（`app.gd:4020`）中的「保存」按钮漏设 `disabled = true`。
10. **普通门诊转诊未校验外科接诊资格**（`godot/systems/game_state.gd:4407`、`godot/ui/app.gd:5212`）：
    - 仅判断 `profession == "doctor"`，认识麻醉医樱花（`doc_sakura_anesthesiology`）、放射医芹香（`doc_serika`）、地下室研究员武见妙（`doc_takemi`）或访问学者摩耶／双叶后，可把阑尾炎／胃癌患者直接转给她们接手主治。
11. **周日院内串门越界**：
    - `serika_radiology.gd` 未检查 `is_sunday()` / `is_hospital_closed_day()`，周日去医院影像科仍有 70% 概率刷出芹香并可读片；周日院内累计闲谈满 480 分钟会误触发平日「下班回家」同行演出并漏记 `sunday_history`。
12. **数据 Schema 告警（1,733 行）与过期测试基线**：
    - **有实际运行时影响的 1 项**：`data/backgrounds.json` 第 77 项（`miyuki_private_clinic`）误将 `"label"` 写成 `"name"`，导致 `app.gd:3178` 切背景时无法读取 `"医疗主题包厢"` 而保留旧地点名；
    - **其余数据/Schema 差异**：美幸 Lv3 重复 `choice.id`（407 处）、武见妙 Lv1/Lv2 `time_start == time_end == 540` 与 `minutes > 120`、芹香 Lv5 22 节点 `hide_portrait` 与图片路径并存、千早二期特殊事件 `priority: 10000` 与访客节点声明、新增 `scene_tint` / `image_fit` / `multiplier` / `completion_*` 等运行字段尚未同步写入 `data/schemas/content.schema.json`，以及 `relationship_activity_placeholders.json` 未补入新角色 `doc_maki`；
    - **过期测试脚本**：`tools/smoke_test.gd` 仍硬编码断言旧版 15 个医院地点；`tools/relationship_gate_matrix_test.gd` 构造 `GameState` 时漏传 `date_profiles`/`date_locations` 导致周日约会断言失败、直接改 `person.skills` 未走 `staff_skill_levels`、以及 `doc_aqua` Lv1 门槛（`0` vs `10`）预期未同步。

---

## 4. 流程顺畅度与玩家视角 UX Feedback（按改动性价比排序）

### UX-1.【高杠杆】门诊标题提前“开卷剧透”最终诊断与术式方案
- **体验痛点**：除 `局限性乳腺肿块` 等极少数模板外，绝大多数病例模板（如 `胃窦部恶性肿瘤`、`右半结肠癌`、`小型局限性肾肿瘤（保肾切除）`）在门诊候诊列表和接诊左上角 34 号大标题上**直接写出了最终病理诊断甚至术式括号提示**（见图 `02_outpatient_diagnosis_spoiler_and_floats.png`），让问诊→查体→检查→初步诊断变成了“照抄左上角标题”。
- **建议**：在 `visit` 完成诊断阶段前，候诊栏与接诊主标题统一显示**主诉／症状名**（如“上腹隐痛与早饱”、“右下腹转移性疼痛”），完成初步诊断后再翻转为正式病名。

### UX-2.【高杠杆】手术室「选择术式」列表未置顶当前适应证与已解锁术式
- **体验痛点**：确认团队进入手术室后，`← 医院导览` 已锁定不可离开；但 `320px` 高的 `ProcedureList` 按原始 JSON 顺序排列，前两行之后紧跟着一整排 `🔒` 未解锁高难术式，把当前患者的已解锁适应证（如 `★ 远端胃大部切除`）埋在深色细滚动条下方（见图 `06_surgery_select_recommended_buried_and_label_hidden.png`），新手极易误以为“对应术式没解锁、被卡死在手术室”。
- **建议**：将术式列表固定排序为 **`★ 当前患者适应证` → 其他已解锁术式 → `🔒` 未解锁术式**（或入场自动 `ensure_control_visible` 聚焦推荐项）。

### UX-3.【核心数值节奏】第 3 名门诊患者起直接放开难度 `68–95` 大手术，早期挫败感与经验惩罚倒挂
- **体验痛点**：`random_patient_cases()` 仅保护前 **2** 名患者从初始解锁池抽取；从第 **3** 名患者（仍在 Day 1–2，主角技术仅 `50`）起，除 4 个教学门禁术式外的全部 18 个高难术式（含难度 `82` 耗时 8 小时的大开腹探查、难度 `93` 腹主动脉瘤、难度 `94` 食管切除、难度 `95` Whipple）直接按权重进入门诊，**每名患者有 33.3% 概率抽到难度 `68–95` 大手术**。而 `surgery_learning_efficiency` 对越级 `>30` 的手术将经验倍率砍到 **`0.20x`**，且会提前自动解锁本属于佳织 Lv1 剧情奖励的 `开腹探查术`。
- **建议**：按主角当前手术技巧分段解锁随机门诊池（例如只抽取 `recommended_surgery <= player_skill + 15` 的模板），或对越级过高的候诊病例在门诊直接给出醒目的“超纲建议转诊”引导并给予合理转诊交接反馈。

### UX-4.【当前阶段最关键】角色关系进度的“黑盒卡点”与“未实装等级诱导白刷”
- **体验痛点**：
  1. **未实装等级诱导白刷**：对 `visiting_maya`、`doc_sakura_anesthesiology` 等无路线角色，以及已实装到 Lv3/Lv4、下一档为 `planned` 的大量角色，办公室进度页先提示玩家去刷熟悉度和高额属性（如魅力 100、技巧 90），等玩家辛辛苦苦刷满后才变成 *“条件已满足；后续事件尚未开放”*；
  2. **已实装等级黑盒卡死**：`relationship_slot_progress()` 不检查事件级 `required_characters`、双人共享门槛、窄时间窗（`shift_remaining()` 暗中把 `13:00–17:00` 截断为 `13:00–15:00`）或专属模块条件（如皐月 Lv2 暗中卡在技术 70 才能见到的阿尔托莉雅、芹香 Lv3 必须周日点“独自去走走”、明日香 Lv1 必须手动组队不扫荡、诗织 Lv3 真实冷却 28 天但 UI 写 3 天）；同时 `staff_view.gd` 对所有 Lv0→Lv1 角色和 `special_events` 升阶角色漏显示 *“· 关系可以进一步加深”*；
  3. **养成肝度极端值**：药剂师真奈美（`pharmacist_manami`）初始手术技能仅 `5`，Lv5 要求其自身手术技能 `>= 60`，按当前每台助手训练点折算需带药剂师上台 **约 180～220 台手术**，远超 365 天正常周目容量。
- **建议**：在 `player_office_view.gd:151` 最顶部优先判断 `not event_authored` 直接提示 **“当前版本已达开放上限（后续剧情制作中）”**；在“条件已满足”时附带一行轻度非剧透线索（如“可在工作日上午前往妇科诊室看看”／“需先结识更多院内同事”）。

### UX-5.【高级手术体验】7 人组队下拉框盲选专科标签 & 看一眼病例即锁返回
- **体验痛点**：
  1. 在高级转诊病例板点击某个首发病例想看一眼需要什么配置时，立刻进入 Day 1 剧情并禁用右上角 `返回医院导览`，必须看完或跳过整段剧情到组队页才能点左下角退回；
  2. 7 人组队面板右侧提示需要匹配 6 个精细节点的专科标签（如 `[血管操作]`、`[重建]`），但左侧第一／第二助手的下拉菜单**只显示人名，不显示手术数值和专科标签**，玩家只能一个个点选试错。
- **建议**：在助手 `OptionButton` 条目中直接展示 `姓名 · 手术 XX [专科标签]`，并在首发剧情前允许安全退回病例板。

### UX-6.【首日心流】Day 1 导览 18 宫格剧透未出场人物 + 门诊缺“候诊中”引导角标
- **体验痛点**：序章刚结束进入 Day 1 09:00，导览直接铺满 18 个地点并写出 `12 御堂外科医长办公室`、`13 副部长办公室 / PENDRAGON OFFICE`（提前剧透中后期关键人物姓氏）；同时御堂室亮着红点引导新手进去吃闭门羹，而真正需要推进主循环的 `02 门诊诊室` 没有任何“有患者候诊”的视觉标记。
- **建议**：未相识前隐藏专属人物姓氏（如仅称“外科医长室”、“外科副部长室”）；为有候诊患者的 `02 门诊诊室` 与有待术患者的 `03 住院病房` 增加清晰的青色／金色工作角标，与粉红色剧情红点区分。

### UX-7.【回想与鉴赏】「事件鉴赏」缺少分类筛选，已解锁内容被淹没
- **体验痛点**：当前「事件鉴赏」将所有未解锁 `？？？` 与已解锁角色事件、特殊活动、48 张岗位 CG 混排在同一个长列表里，打开首屏全是无边框暗色 `？？？ 未解锁`，成就感与查找效率偏低。
- **建议**：增加 `全部 / 人物剧情 / 特殊活动 / 岗位CG` 分类页签及 `仅显示已解锁` 勾选框。

### UX-8.【操作与整洁度细节】
- **办公室职业行动**：5 个按钮里 4 个写着 `无属性变化`（耗时 60～120 分钟），建议要么赋予微小的确定性收益（如少量手术经验／医护熟悉度／声望进度），要么精简为一个清晰的「在办公室休息／整理至 16:00 下班」快捷按钮；
- **快捷键与设置集中度**：建议在顶栏「设置」弹窗中补齐**语音音量滑条**、**语言切换**以及办公室桌面的「术中危机开关／术野 UI 模式」；为过场视频与 H Runner 补齐 `Space / Enter` 键推进支持；清理正式画面常驻的 `场景占位` 与 `开发原型 0.5 · 本地美术占位` 文案；
- **英文导览排版**：统一底栏 5 个按钮字号（适度加宽按钮或减小水平内边距），并在英文模式下隐藏与主标题同义的全大写英文副标题（避免 `07 Operating Room / OPERATING ROOM` 重复）。
