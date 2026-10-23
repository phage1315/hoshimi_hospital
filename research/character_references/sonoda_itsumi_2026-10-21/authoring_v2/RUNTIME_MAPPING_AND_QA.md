# 薗田愛実 — Codex 数据接线与验收说明

## 1. Authoring package, not runtime schema
当前 Library 只有 `staff_minimal_requirements(2).md` 指向真实 `data/schemas/content.schema.json`、`tools/staff_bundles.py`。后者实际内容未提供到本包。本包 JSON 所用 `_artifact_status`、`*_candidate` 等是**编剧层标记**，不能直接假装是引擎合法字段；必须逐字段映射。

## 2. 与留美／栞 V3 一致的文件结构
`profile.json`＋`relationship.json`＋`bundle.json`；独立 `dialogue_authoring.json` 与 `time_events_authoring.json`；导入前使用实际 `data/staff/index.json` 检查 `nurse_sonoda_itsumi` 是否冲突。不要误建一个同名角色。

## 3. 数值签核
`age=20` 是**用户已确认值**；六项 `skills`、`familiarity_gain_multiplier=1.0` 仍是**待用户审定的建议值**，不能写入已锁定设定文档时忽略状态。最终必须满足年龄整数（>=18）及技能 0–100。

## 4. 角色出场／团队／专属护士
- 外科、病房、护士站是日常工作内容；候选地点 ID `station / ward / lounge / rooftop`，实际 ID 和时间窗须核实。
- 若没有自然 OR idle，仍需允许把她主动选为器械或巡回护士；她进入手术室时显示正确工作服、HUD、岗位回应。
- 有护士职业资格、正式相识后，可被设为专属护士（**石神例外不适用於本角色**）。正确／错误诊断差分只在玩家已提交病名后发言；不能让 nurse hint 误导或提前告知病名。
- 所有医护开放休息室、天台及普通下班同行；不得把其误接入周日 Romance 日期 Gate。

## 5. Crisis and preop
- 从真实 runtime 读取 `crisis_flavor_id`（8类）＋ severity（普通/严重）＋ attempt（1/2/3），映射 `dialogue_authoring.json#crisis_attempt_callout`。
- **only current circulating nurse** calls out monitor symptoms; do not reroll crisis type when retry dialogue changes. No large hemorrhage, standalone diagnosis, success-rate hints, or extra status penalty.
- `profile.json#preop_graphic_wrapper` 含四句中文 `open/insert_a/insert_b/close`；`dialogue_authoring.json#preop_graphic_wrapper` 含完整 CN/EN。不要把它们替代医学说明正文或写成术式特异操作。

## 6. Intro status
`event_design/itsumi_lv0_candidate_cn_en.json` 是可审阅的完整中英文相识候选。**用户尚未确认触发时刻和正文**，因此不能直接把 `bundle.entry` 标作已可玩。正式事件完成时才把 `met=true` 并保持 Lv0。避免与留美／栞周一 9:00 双人初见互相覆盖。

## 7. Time events
`time_events_authoring.json` 四个 location_blocks，每组 3 段独立文字，非逐段播放的三幕剧情；必备休息室和天台；station、ward 只是额外备选。如 time_events 现有 schema 不支持这两类，不扩展引擎，按审核标成 supplementary/unwired。

## 8. 本轮 QA 结果与 Codex 待办
- 本轮验证 JSON **语法/文件引用/键数/中英覆盖/文案占位符**；不宣称实际 schema、Godot 或资源存在。
- 对照 live `content.schema.json`、staff index、staff bundle loader 适配，并执行 `tools/validate_data.py`、`tools/staff_localization_test.py`、`tools/narrative_localization_test.py`、`tools/localization_audit.py`。
- 追加实际 art: 制服、两季常服、刷手服、无菌手术服、术中 HUD 头像、器械／巡回／病房三类护士岗位CG。必须由用户原作图片作为绘图身份锚点；未交付素材不能填 ready。
- 编队及时间回归测试：器械／巡回都可选，无自然 OR spawn 也不影响；48 条危机三次递进覆盖；正确错误诊断反馈；四段术前说明；休息室/天台各3段、下班同行；不触发未编写的 Lv1–Lv5。
- 审核 `IN2_Sonoda_Itsumi_profile.md` 体现的原作关系，不把原作坂口晃的不当行为迁移给本作坂口隆司。

## 9. 年龄与全员表同步（2026-10-21）

- `profile.json.age = 20`，属于已确认的星见 AU 设定。
- 其他职员（特别是弘子 22、石神 30、皐月 20、真奈美 23）的年龄，以包内 `HOSHIMI_CHARACTER_AGES_USER_CONFIRMED_2026-10-21.md` 为权威对照；不要用旧资料覆盖。
- 年龄引用不新增游戏人物，也不自动改已有工程代码。
