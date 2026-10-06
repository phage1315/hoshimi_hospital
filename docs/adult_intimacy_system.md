# 成人亲密互动底层模块

本模块承接 `docs/design/HOSHIMI_H_SYSTEM_V0_1.md`，当前只实现可复用的资料契约、会话状态、解锁和存档底层。角色专属内容与正式界面将在每名角色提供素材和台词后逐一接入。

## 已确认边界

- 所有可攻略角色都已是成年人；员工 Schema 本身要求 `age >= 18`，不再增加重复的 `adult` 布尔值。
- 可重复入口表达为向角色询问“下班后是否可以亲密相处”。互动不会发生在工作时间；完成后默认结束当天并推进到下一可用日。
- 未来夜班系统可另加时间规则，当前模块不预留虚构的夜班状态。
- 本模块与手术台触诊完全独立，不读取身体热点、患者恐惧／痛苦／尊严、麻醉状态或临床流程。
- 前戏只使用文字选择、角色表情和 0–100 兴奋度；不会显示患者触诊躯干图。
- 当前没有任何生产角色配置 `h_profile`，因此不会出现新的可玩入口。

## 员工资料 `h_profile`

`h_profile` 是 doctor / nurse 共用 staff 记录上的可选字段。未填写等同于该角色尚未实装，不能用空白资料生成入口。

必需资料：

- `enabled`: 实装后固定为 `true`。
- `initiative`: `proactive`、`responsive` 或 `switch`；可用 `initiative_overrides` 按地点或服装覆盖。
- `fallback_h_cg`: 默认 CG 的稳定 ID 和资源路径。
- `base_locations` / `base_outfits`: 首次解锁后开放的地点和服装。
- `outfit_portraits`: 每套服装在文字互动阶段使用的角色立绘。
- `opening_lines`: 每个支持地点的开场对白。
- `foreplay_preferences`: `touch`、`kiss`、`lick` 各自的偏好等级。
- `action_reactions`: 三种动作的通用短反应池。
- `initiative_event`: 单次会话只触发一次的主动权提议、阈值与两种回应。
- `position_lines`: `top`、`bottom`、`rear`、`69` 的过渡文字。
- `after_lines`: CG 后的 1–5 行收束文字。

可选资料：

- `target_preferences`: face / neck / chest / waist / thigh / intimate 的角色偏好修正。
- `target_reactions`: 指定目标的专属反应，存在时覆盖动作通用池。
- `special_cgs`: 按地点和服装解锁的特殊 CG；姿势不会自动选择不同 CG。

## 运行时规则

`AdultIntimacySession` 管理 `foreplay → initiative → position → cg → after → completed`。动作基础增长由角色资料决定，目标偏好再修正，单次增长限制为 10–25，兴奋度限制在 0–100。主动事件达到资料阈值后触发一次；玩家可以顺从建议或保留主动权。

CG 按以下优先级解析：人物里程碑事件显式覆盖、已解锁且同时匹配地点／服装的特殊 CG、只匹配其中一项的特殊 CG、默认 CG。姿势只改变文字，不扩张 CG 素材数量。

`GameState` 保存：

- 每名角色是否开放可重复入口；
- 已解锁地点、服装和特殊 CG；
- 正在进行的会话阶段、兴奋度、主动事件、历史和已解析 CG；
- 从人物事件进入里程碑互动时的返回模式。

可重复会话只有在角色已相识、具有有效 `h_profile`、里程碑已解锁、医院当天开放且没有其他活动占用时才可开始。里程碑会话由人物事件显式调用，可使用事件专属 CG。

## 每名角色的接入清单

1. 确认首次亲密事件的 gate、事件节点和完成后开放可重复互动的时点。
2. 提供默认地点、默认服装以及可选解锁组合。
3. 提供各服装的文字阶段透明立绘。
4. 提供三种动作的反应池；如需要，再提供六个目标的专属反应。
5. 指定三种动作和可选目标偏好等级。
6. 提供一次主动权事件及玩家顺从／拒绝后的短回应。
7. 提供四种姿势的文字过渡和 1–5 行事后对白。
8. 提供至少一张默认 CG；特殊地点／服装 CG 可以后追加。
9. 提供中英文文本；所有普通节点仍遵守单个对话框高度限制。
10. 完成人物专属测试：gate、首次事件、可重复入口、解锁组合、存读档和一天消耗。

## 当前代码入口

- `godot/systems/adult_intimacy_session.gd`: 无界面的会话状态机。
- `godot/systems/game_state.gd`: 解锁、启动、结束、跨事件返回和存读档。
- `data/schemas/content.schema.json`: staff 的可选 `h_profile` 数据契约。
- `tools/adult_intimacy_system_test.gd`: 合成角色资料覆盖的底层回归测试。

正式 HUD 暂不绑定到普通角色。第一个角色资料完成时再接 UI，可以直接用真实立绘、双语文案与首次事件验证布局，避免空壳界面形成第二套内容格式。
