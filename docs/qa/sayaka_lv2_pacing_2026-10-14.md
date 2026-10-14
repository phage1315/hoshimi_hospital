# 小夜香 Lv2《工作时间》对白节奏稿验收

日期：2026-10-14。只处理用户本次批准的Lv2主事件，不重建项目，不提交／推送，不覆盖原有未提交修改。

## 原文与授权边界

- 原稿逐字副本：`docs/source/sayaka_lv2_pacing_v2_draft.md`，来自用户附件 `HOSHIMI_SAYAKA_LV2_WORKING_HOURS_V2_PACING_REVISED_DRAFT.md`。副本保留草稿标题／状态以便核对；本次聊天中的明确批准是实装授权。
- 全部主事件共146个显式话轮，中文逐句／说话人／顺序／标点由 `tools/sayaka_lv2_source_audit.py` 核对。
- 授权例外1：原稿179、193、209行的坂口服装评价已经由原三选项表达，不再作为单独话轮重播。C保留原选项“其实手术服也很好看”，不改为正文版本“其实你穿手术服也很好看。”；A/B亦保留原按钮标点、不额外口播。
- 授权例外2：435行玩家可见旁白缩为“她笑着轻轻挑了一下眉。”，删除原句后半段编写说明。这是用户明确批准的局部调整。
- 无其他中文改写；“刚才在门诊和病房之间来回跑了好几趟”等时间措辞按本稿原样保留，不顺带调整上班入口。
- Scene 11的两段可选Ambient及Scene 12的Lv3说明不进入主事件，不新增内容／触发／预约。
- 英文对应146段正文、148个选项／继续标签及标题／teaser／画廊标题，共297条Lv2键；替换旧Lv2英文键，不修改其他事件英文。

## 接线、效果与兼容

- 复用现有 `CharacterEventSession`、`presentation: authored` 和 `app.gd` 的逐话轮分页、姓名栏、继续／自动播放；不建立第二套VN。
- 三个服装choice ID／中文label／effects／flags不变。门口的可选 `next_if_choice` 根据本事件是否已选 `lv2_scrubs` 路由10A，否则10B，统一进入10C。schema约束字段，数据校验验证choice引用与两条目标边，运行器拒绝无效目标且不先写入选择历史。
- 将原 `ask_staying`、`ask_faking`、`ask_return`、`ask_other_reason`、`statistics`、`walk_to_door`、`lv2_complete` 的效果逐项保留于对应正常继续操作；无新增奖励。A/C合计好感+4、熟悉度+9；B好感+5、熟悉度+9（未触及全局100上限时）。最终flags、benefit及升级各结算一次。
- 元数据与旧事件夹具逐项比较一致（仅start/nodes变更）：入口、地点、背景、服装、35分钟、CG、Gate与前置均保留。熟悉度25实际由关系槽位校验；周一回调后3天条件保持。全局禁存档生效，未改变旧 `locks_saving` 字段或存档制度。
- 保留 `white_coat` 选择入口和 `ending` 终点ID，扩展既有 `sayaka_v2_completed_state` 的Lv2已完成终点映射。v35日志型／v36状态型旧完成存档保留时间、关系、原奖励及完成记录；不重放旧选项、不重复领奖、不让完成事件重新可触发。没有增加活动事件恢复。
- 本轮前后分别计算非Lv2事件对象、非Lv2英文键映射的规范化SHA-256，结果相同。源PNG／导入设置及角色配置不改。

## 实际测试

### 静态

- `python3 tools/sayaka_lv2_source_audit.py`：1,466项，0失败；精确中文、归属、三条顺序、唯一服装选择、结尾问答一次、元数据／原奖励及条件路由schema正负例。
- `python3 tools/sayaka_v2_source_audit.py`：2,509项，0失败；旧Phone／Lv1／Callback正文不变。
- `python3 tools/validate_data.py`：733条通过。
- `python3 tools/narrative_localization_test.py`：7,850项，0失败。
- `python3 tools/localization_audit.py`：16,753条翻译；英文UI键702/702。全项目authored coverage报告15,155/15,228并允许既有源语言回退，此数值不等于全项目所有文本都已翻译；Lv2的297条英文键完整，专项运行验证无中文残留。

### Godot headless

- `tools/sayaka_lv2_pacing_test.gd`：7,920项，0失败。中文／英文×服装A/B/C完整UI按钮路线（分别132／133／131话轮）、每页文字及高度、姓名栏、白大褂表情资源、一次35分钟、阶段禁存档、末尾唯一完成／Lv2／CG、原奖励与flags、Gate24/25／缺前置／冷却、当前完成存档及旧v35/v36三路线兼容、错误目标不改会话。
- `tools/sayaka_lv1_event_test.gd`：258项，0失败，覆盖Phone→Lv1→Callback→Lv2及Lv3入口。
- `tools/sayaka_v2_test.gd`：7,802项，0失败。
- `tools/character_event_test.gd`：177项，0失败。
- `tools/narrative_save_lock_test.gd`：6项，0失败。
- `tools/dialogue_playback_test.gd`：11项，0失败；退出保留其既有ObjectDB清理警告。
- 初版新专项出现801条失败，全部来自测试夹具：普通立绘实际名为 `CharacterPortrait`，不是专属事件图的 `CharacterEventPortrait`（795次）；`set_test_time`只设置自由时间账本，需扣除前置夹具事件耗时才能从09:00开始（6次）。更正测试定位与夹具后全量重跑0失败，未为通过测试改变游戏时钟／立绘逻辑。
- Headless保留环境既有macOS CA提示，无本次脚本解析／运行错误。

### 原生窗口（程序驱动，非人工完整游玩）

- 初次沙箱内窗口启动退出134且无日志；经允许启动独立窗口后，使用同一专项加 `-- --visual`，7,950项、0失败，包括中英文全部三路线和30张截图。
- 截图存于 `/private/tmp/hoshimi_lv2_<locale>_<branch>_<node>.png`。已目视抽查英文服装三选项、中文10A短旁白、英文保健室长对白和英文10B口罩问答，姓名栏／断行正常，抽查画面没有出框。
- 使用内存数据；没有读写玩家存档槽或切换持久化语言设置。

## 剩余范围

本次主事件实装及英文验收完成。两段Ambient未接入；Lv3文本未改；既有特殊事件5项跨日活动会话恢复分歧及其他历史测试问题不在本次范围，未删除测试、未擅改设计，也未声称全项目测试全部通过。玩家主观节奏仍可继续试玩反馈。
