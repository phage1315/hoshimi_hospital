# 朝仓 Lv4、医护大手术 V2.3、武见妙 Lv1/Lv2 接入状态

## 已接入

- 朝仓 Lv4 `miyuki_lv4_inspection`：105 个节点、双语、两组选项、下班后触发、统一结算 120 分钟；保留既有五次术前准备计数要求。粉红护士服普通段已配置六种表情差分，私密段落头像及背景保持原有接入，完成后结算 Lv4 与亲密事件资格。
- 武见妙 Lv1 `ev_doc_takemi_lv1_vivisection_frog`：44 个节点，双语及选项接入；通用女患者的 2 个发言节点已分别映射羞耻咬牙与剧痛哭喊的专属术中头像。
- 武见妙 Lv2 `ev_doc_takemi_lv2_fujino_laparotomy`：112 个节点，双语及选项接入；浅上藤乃 30 个发言节点已映射门诊、术中和术后共 9 张专属差分。
- 上述三个事件已加入事件测试中心；测试入口使用内存测试条件，不修改玩家存档。
- 医护高级手术 V2.3：24 人双语原稿均已预置（本轮补入其余 22 人），实际正式患者仍仅小夜香／芹香；旧尾声不再重复附加，保留 100%／50%／0% 经验递减与全程禁止存档规则。其余角色档案及素材缺口见 materials_pending.md。

## 朝仓 Free H 的实际状态

Profile、Flow、Context 及双语数据已登记，Lv4 完成后的关系资格已接通。Registry／Context 已切换为 `ready`；真实完成 `miyuki_lv4_inspection` 且取得既有亲密资格后，角色页面显示正式预约按钮，不靠等级数字绕过完成事实。

作者要求的图片素材现已齐全：`body_map.png` 实际尺寸为 1024×1520；`scene_cg.png` 与 `aftercare_cg.png` 均为用户指定的 1520×1024 原图；六种透明头像 `neutral/annoyed/pleased/flustered/delighted/peak` 已接入。V2 的 neutral 与 peak 为用户指定的 1408×1152 原图，annoyed／pleased／flustered／delighted 以这两个固定端点重新制作，并按 low／mild／strong／favorite／MAX 的 Runner 强度定义区分。最初 neutral 原图仍保留为未引用备份。

九区热区已按 1024×1520 最终底图标定为 14 个归一化多边形；嘴唇、乳头、外阴、肚脐等小区按 Runner 既有优先级覆盖大区，背景漏点与 TextureRect 实际输入路由均已验证。六态与两张 CG 已完成正式 Runner 中英文可见窗口验收，因此朝仓 Free H 已正式开放。

后续地点调整：Free H 的内部地点键仍为 `clinic`，演出背景改用同一间星见医院诊疗室的夜景 `miyuki_hospital_clinic_night`；预约地点中英文显示为“星见医院诊疗室”／“Hoshimi Hospital Consultation Room”。朝仓专属预约回应采用用户指定原句“今晚呀，不如就去你的诊疗室嘛，想当一下你的患者 ❤️”，并补英文版本。Lv4 一次性剧情仍使用原医疗主题包厢；Free H 的原有开场对白未改变。

夜景演出期间右上角显示 22:00；这是朝仓 Free H 的演出时钟，不改动当日下班结算。结束后仍按原规则进入次日 09:00。

## 其他素材缺口

武见妙 Lv1 通用女患者与 Lv2 浅上藤乃的专属差分均已接入，正文和说话人未改；两组患者立绘已在中英文原生窗口的主线与备选分支中逐一验收，未出现缺失资源。朝仓 Free H 本轮已完成独立中英文原生窗口验收。

## 验证

- `tools/miyuki_takemi_current_events_test.gd`：本轮无头回归为 8726 项检查、0 失败；覆盖中英文、选项组合、节点推进、完成结算、存档边界、测试入口，并确认 Lv1 通用女患者 2 个、藤乃 30 个发言节点均创建实际立绘控件。
- `tools/miyuki_free_h_bodymap_test.gd`：89 项检查、0 失败；覆盖九区 14 多边形、归一化范围、代表点、背景漏点、小区优先级、实际 TextureRect 输入与完整资源包。
- `tools/miyuki_free_h_test.gd`：305 项检查、0 失败；覆盖中英文反应池、六表情可达、MAX 一次、二阶段、手动结束、事后两句和真实 Lv4 完成门槛。
- `tools/miyuki_free_h_e2e_test.gd`：地点调整后可见 macOS 窗口 363 项检查、258 个 `Window.push_input` 鼠标事件、0 失败；中文温柔与英文强烈分支各从人员页正式预约跑至次日医院导览，核对了预约回应的双语地点名及实际诊疗室背景，未写测试或玩家存档。32 张截图与结果 JSON 位于 `docs/qa/miyuki_free_h_native_2026_11_02/`。
- 本轮夜景与预约回应修改后：同一原生窗口驱动 361 项检查、258 个 `Window.push_input` 鼠标事件、0 失败；中文温柔与英文强烈分支均从正式人员页预约到次日医院导览。夜景、原句和英译截图、日志与结果位于 `docs/qa/miyuki_free_h_night_native_2026_11_02/`；未写玩家或测试存档。`tools/miyuki_free_h_test.gd` 305/0、`tools/miyuki_free_h_bodymap_test.gd` 89/0、`tools/free_h_scheduling_test.gd` 108/0；叙事本地化 30631/0，UI 硬编码中文候选 0。
- 22:00 演出时钟复测：同一可见原生窗口中英文正式入口至次日医院导览 369 项检查、258 个鼠标输入事件、0 失败；核对入场及事后均为 22:00、内部结算时钟未改、次日 09:00 恢复，且未写存档。截图、日志与结果位于 `docs/qa/miyuki_free_h_2200_native_2026_11_02/`；同轮无头回归 `miyuki_free_h_test.gd` 305/0、`free_h_scheduling_test.gd` 108/0。
- 武见 Lv1／Lv2 本轮原生窗口复测：从标题开发者工具的现有事件测试中心进入，中英文各跑首选与备选四条组合，共 8 条完整路径、10383 项检查、0 失败；两篇分别覆盖全部 44／112 个节点，患者差分截图和结果见 `docs/qa/takemi_lv12_native_2026_11_02_all_branches/REPORT.md`。修正了测试中心因前置历史耗时导致 Lv2 起点显示 12:00，以及多次测试后返回地点空缺的问题；剧情内容、正式解锁门槛与存档边界未改。同轮无头回归 8742/0。
- `tools/miyuki_takemi_source_audit.py`：2088 项检查、0 失败，核对归档双语审阅数据与运行数据的正文、说话人、顺序。
- `tools/advanced_staff_patient_source_audit.py`：1069 项检查、0 失败；1004 条双语文本。
- `tools/narrative_localization_test.py`：30631 项检查、0 失败。
- `tools/localization_audit.py`：47311 条翻译，UI 硬编码中文候选 0。
- `git diff --check` 通过。

未覆盖所有角色、所有术式的逐台人工回归；没有提交、推送或改写玩家存档。
