# 朝仓 Lv3《下午三点的早安》接入记录（2026-10-30）

## 当前状态

**内容、中英文、演出、A正式自动入口、B周日邀请及结算已完成。已按用户确认接通狩谷日期规则，并修正朝仓刷手服发型及本事件立绘尺寸；完整原生实机与最终素材显示复测通过。**

2026-10-30复核更正：狩谷的日期早已确定，并非缺少实习结束日期。已实装Lv0台词明确6月1日开始、为期半年、12月1日结束评审；原作者包还登记最后常规实习日11月30日。运行初见入口为min_day=62（6月1日起），可因前置或占用而顺延。真正未实装的是12月1日评审剧情及留院／离院结算；占位设计明确禁止自动改变在职身份，Lv3也仅是留用邀请资格，不等于自动转正。依据：`data/staff/nurse_kariya_megumi/events.json`、`research/character_references/kariya_megumi_2026-10-22/authoring_v2/data/staff/nurse_kariya_megumi/relationship.json`和同包`event_design/KARIYA_MEGUMI_DEC_01_INTERNSHIP_END_PLACEHOLDER.json`。

作者已确认本事件选人规则：狩谷已相识且处于开局当年6月1日至11月30日时使用狩谷，否则米田兜底；12月1日起不自动让狩谷离职，不变更其他岗位资格。`miyuki_lv3.gd::selected_prelude()` 已接通。演员进入A时固定，之后不会半场重新选择。测试已新增5月31日、6月1日、11月30日、12月1日和次年1月1日的相识／未相识组合，以及真实地图／地点自动入口、忙碌阻挡和不改变医护相识状态。

## 内容及映射

- 原稿完整归档：`docs/source/miyuki_lv3/HOSHIMI_ASAKURA_MIYUKI_LV3_AFTERNOON_GOOD_MORNING_CN_CODEX_READY_V1.md`。
- 共同正文 A82+B246=328；A15处覆盖按原稿表格。存为两个82节的A事件，单次只播放其中一个，不叠加两列。
- A狩谷：`miyuki_lv3_locker_room_kariya`；A米田：`miyuki_lv3_locker_room_shiori`。
- B：`miyuki_lv3_afternoon_good_morning`；主角关系actor `nurse_yui`；配角 `nurse_kariya_megumi`／`nurse_yoneda_shiori`。
- 数据写入 `data/staff/nurse_yui/events.json`；局部导入器 `tools/import_miyuki_lv3.py` 只更新这三个事件、新背景、本事件本地化和Lv3槽位，不重跑其他事件导入。
- 中文逐字保留。唯一条件替换来自原稿15行表格；A012/019仍归朝仓。名字牌将槽位“年轻护士”绑定为具体角色；旁白中的自然称谓保留。无新增选择、补写对白或改变顺序。英文稿及双语审核表在 `tools/fixtures/miyuki_lv3_en/` 和 `docs/source/miyuki_lv3/bilingual_review.json`。

## 触发和结果

A检查：真实 `miyuki_lv2_preop_morning` 完成、朝仓相识且Lv2、Fam40、`outpatient_forced_undress`≥5、正常3自然日冷却、芹香 `staff_is_met("doc_serika")`。Lv0相识即可，不要Lv1，不增时间、周几或Surgery条件。安全自动调用点位于 `show_map()`／`show_location()`；手术、门诊、其他VN、术前、同行及日终排他操作期间不得抢占。满足条件后按上述日期规则自动开始。

A结束只记录完成日期和事件级事实，零耗时、不升关系、不相识米田、不生成患者或手术。待续由A完成且B未完成推导。已完成的A事件ID保留本次演员，画廊不会随未来离职改变阵容。

B检查A完成后的更晚周日、当日活动未用、芹香相识。既有周日邀请朝仓时优先选B替代普通约会；不再次检查A的Fam／互动计数／冷却。缺芹香时入口不消耗周日，保持待续。其他角色约会／跳过周日不结算B。

仅B246之后经既有关系接口结算Lv3；现有 `familiarity_rules` 随真实Lv3完成变为×0.75。经 `complete_sunday_activity("miyuki_lv3_date", ...)` 只登记一次周日活动，推进周一09:00；非普通date奖励路径，无额外Fam、Charm、约会计数、手术经验、恋人、H或患者资格。

## 存档边界

继续只允许医院导览／周日安全边界保存。原稿“中途恢复”与项目规则冲突，因此未实现；中断重载从上次安全存档重播。A/B完成事实和既有已结算日期、关系、时间保留；没有新增持久节点、路径、台词进度或临时演出状态。仅内存会话有游标。已完成A的两种稳定事件ID属于事件级角色版本，不是选项路径。

## 素材与演出

- 新增午后广场：`assets/backgrounds/miyuki_lv3_v1/plaza.png`（1672×941）。复用更衣区、走廊、咖啡小餐厅、傍晚河边步道。
- `assets/characters/miyuki_lv3_v1/`：12张实际引用的SFW差分（1024×1536、RGBA），包括三人的无帽口罩刷手服、戴帽无口罩、朝仓冷静带教／两位新人抱怨，以及朝仓私服道歉、平静认真、调皮伸手。另保留两张修订前戴帽候选，不被运行数据引用。
- 朝仓A013开始无帽刷手服，新人A041换装；A068两人戴帽，A076朝仓才换为既有带口罩刷手服。帽下耳朵／发尾修订已完成。未生成换装裸露画面。
- B001–033朝仓只有电话画外发言，不显示任何朝仓立绘；坂口沿用项目第一人称主角表现。B034起私服带包，B056餐厅，B142河边，B185起认真谈话，B217后恢复活泼。牵手按原编号旁白与伸手姿态呈现，没有另加CG或正文。
- 图片生成来源、参考和完整prompt：`assets/candidates/miyuki_lv3_2026_10_30/manifest.json`。原始生成文件保留；未改用户既有原图。

## 已执行验证

- `python3 tools/miyuki_lv3_source_audit.py`：410个实际数据节点（82+82+246）的原文／覆盖表、说话人、顺序、英文、换装／电话显示检查通过。
- 原生Godot4.5.1、OpenGL Compatibility，中文+英文、A两版本+B、各自实机与画廊回放，共2624节点、27456检查、0失败；实际Viewport鼠标事件推进，未仅调用Continue回调。
- 同一测试覆盖Fam39/40、计数4/5、Lv1阻挡、真实Lv2、芹香未相识／Lv0、冷却、忙碌阻挡、未来周日选择B、未相识芹香不消费、A不发奖励、B仅最后节点升Lv3、周一09:00、×0.75、无临床Runner、回想不结算。
- 安全存档不含内部状态，移除剧本节点后仍恢复完成事实，重复存读不重复奖励／变更时间。使用 `/private/tmp/` 独立测试文件，玩家槽位未触及。
- `python3 tools/narrative_localization_test.py`：28585检查、0失败。
- `python3 tools/localization_audit.py`：UI754/754英文齐全、无硬编码中文候选；全库已有313个非本事件的英文fallback字段仍在，不能称全库100%翻译。
- 证据：`docs/qa/miyuki_lv3/native.json`、`headless.json`及对应中英截图。初轮headless测试的测试弹窗未关闭导致窗口错误，已修正测试清理并重跑。此次原生复测曾出现单次点击未推进：合成鼠标按下／松开改为同帧发送，避免跨帧指针移动取消点击后，严格逐节点完整测试通过；未改生产对白推进逻辑。最终原生日志无错误。
- 全局数据校验存在此前已记录的问题；本次不据此改无关内容或放宽保存规则。未提交、推送、发布、改玩家存档。

## 2026-10-30 后续显示修正与最终验证

- 作者指出朝仓无帽刷手服发型不符合常服；以既有`spring_summer_casual_v1/nurse_yui/neutral.png`为发型参考，通过内置imagegen修正普通及认真表情，落盘`miyuki_uncapped_hair_v2.png`、`miyuki_uncapped_focused_hair_v2.png`。保留旧图，不裁切素材；prompt及来源见候选manifest。
- 本事件原先所有人物使用300×420显示框，朝仓的不同画幅导致大小不一致。仅调整本事件朝仓的演出参数：护士服／既有口罩刷手服420×500、底边620；无帽刷手服350×525、底边655；戴帽350×525、底边645；约会私服420×630、底边750。其他人物及通用渲染器不变。
- 正式入口日期／相识边界及两演员完整中英实机＋回想：27456检查，2624节点，0失败（`native.json`；无头同样通过）。
- 最后认真表情接入后另运行原生`tools/miyuki_lv3_visual_test.gd`，32个中英文换装／表情检查点0失败，实际纹理和显示尺寸检查通过，截图经人工视觉核对；此脚本使用内存显示检查点，不把它当作真实流程触发证据，真实入口由上述完整测试验证。报告`visual.json`。
- 最后重跑原文audit410节点、叙事本地化28585检查0失败及全局本地化审计，结果与上节一致；不因界面中文通过而跳过英文。
