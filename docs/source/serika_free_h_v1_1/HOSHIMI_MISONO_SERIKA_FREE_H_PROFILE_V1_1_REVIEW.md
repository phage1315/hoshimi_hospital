# Hoshimi Hospital／星见医院

## 御園芹香 — Lv4 后 Free H Runner Profile／Flow V1.1（中文审阅与 Codex 交接）

**状态：** 人物对白 V1.1 改写候选，36/36 可达反应池完成写作端静态核查；**待作者最终审定人物口吻，未在真实 Godot 运行。** 旧《V1 REVIEW》中的人物语气 `PASS_WITH_NOTES` 结论已撤回，本稿取代其对当前对白质量的判断。

**交付文件：**

1. `doc_serika.h_profile.json`：覆盖 4 动作 × 9 热区的即时反应；仅改写 `dialogue`，没有修改偏好或资源路径。
2. `doc_serika.h_flow.json`：仅改写 MAX、两种风格的 Phase 2 台词、Finish 反应及 Aftercare；完整保留获准的 V1.3.4 流程结构。

这里的 **V1.1 是人物文本修订号**，不是引擎 schema 或 Phase 2 patch 版本号：`profile.schema_version` 仍是 `1.3`，`flow.patch_version` 仍是 `1.3.4`。为避免破坏现有系统，请勿因文件内容修订号升级而擅自改动上述接口字段。

---

### 1. 本轮改写理由与人物尺度

V1 的主要问题并非缺少不同部位的台词，而是过分完整、过分自信、似乎站在高位点评坂口技巧。实际的芹香是 **25 岁、有自我决定能力、平日严谨克制、亲近时会不由自主羞赧** 的医生。Lv4 确认恋人后，她能够主动接受亲密关系；但处于成年恋人的前戏与亲密互动之中，讲话自然比工作时少，语句也不再完整。

本轮改写遵循以下规则：

1. **短促感官反应优先。** 即时反应以呼吸、惊讶、细小请求、断句与未说完的话为主。70 条 Profile 文本中，最长 **19 字符**，平均约 **10.5 字符**（按字符串长度统计，含标点）。
2. **不做技巧考评。** 删除「这招」「得意一小会儿」「不是我偏好的那一种」等不符合人物姿态的表达；「喜欢」可以说，但不必像问诊记录一样汇报心情。
3. **不是每句句首加省略号。** 感受首先反映在语序、停顿、呼吸、重复与吞没的后半句。正面邀请与突然害羞可以同时发生；她既不应被写成老练的御姐，也不应幼态化为完全没有主见的人。
4. **偏好档位与时间阶段分开。** `low/mild/strong/favorite` 表示**某动作、某热区的反应程度**，不表示互动已经到了高潮。由 `scene.start → scene.middle → h_finish → aftercare` 体现从克制到忘记组织语言，再到事后安静依恋的时间变化。
5. **`low` 不是一条隐藏的拒绝路线。** 较低偏好可表现为不习惯、意外或想换一种方式；若未来设计明确的撤回同意、停止要求，应由独立交互机制处理，不能让 H Runner 把清晰拒绝当普通分数反馈。
6. **口吻连续性。** 通用池 Lv4 后即可使用，允许「坂口君」，不提前使用 Lv5 才自然出现的「龙司」；不得重播潮崎、奈奈美、警方、父亲、朝仓等 Lv4/Lv5 一次性剧情。

除了 `location_entry.home` 与 Aftercare 需要支撑日常对话，Phase 1 和 Phase 2 均不承担长段解释或文学抒情任务。声音、立绘与 CG 可以共同表现节奏，但静音状态下文本本身仍须能读通。

### 2. 地点与自由 H 解锁保持不变

- Lv4《留下来》的 S07-058 完整结束，才解锁普通 Free H。**Lv4 固定 H 场景不调用这份普通 Runner 数据。**
- 每名角色只有一个固定 Free H 地点：芹香的地点是 **芹香自己家**，不是坂口家。日间成功预约的既定回应保持原文：**御園芹香：「那今晚去我家吧。」** 这句属于全局邀请入口，不放进 `location_entry.home`。
- 全局预约仍按照 Free H Scheduling V1.1：一日最多一人，可确认覆盖，下班履约，跨午夜时也按当天主动下班结算；不添加挑选地点、额外数值门槛、费用、冷却或永久奖励。
- Runner 到达芹香家后，才随机播 **一条** `location_entry.home`。四条兼顾家务招呼与私人空间内的轻微羞涩，能够重复使用，不写成「第一次进我家」。
- `hotel/ward/operating_room` 为与标准 Profile 结构对齐的**兼容短句**，不代表开放对应地点。

### 3. 保持原样的偏好与可达池覆盖

本次只是修复人物声线，**没有动 `preferences` 中任何 tier、action override 或 combo override**。它们仍属于待作者确认的 V1 偏好提案。

文本命中优先级：`combo > zone_tier > action_tier > tier_fallback`。

| 热区 | `caress` | `kiss` | `lick` | `light_bite` |
|---|---|---|---|---|
| `lips` | favorite／区域 | favorite／组合 | favorite／区域 | mild／组合 |
| `cheeks` | favorite／组合 | strong／区域 | low／组合 | low／兜底 |
| `neck` | favorite／组合 | favorite／组合 | strong／区域 | mild／组合 |
| `breasts` | strong／区域 | strong／区域 | strong／区域 | low／兜底 |
| `nipples` | strong／区域 | strong／区域 | strong／区域 | low／兜底 |
| `navel` | mild／区域 | mild／区域 | mild／区域 | low／兜底 |
| `torso_other` | strong／组合 | mild／区域 | mild／区域 | low／兜底 |
| `genitals` | strong／区域 | strong／区域 | strong／区域 | low／组合 |
| `thighs` | strong／组合 | mild／区域 | mild／区域 | low／兜底 |

写作端静态 QA：

| 项目 | V1.1 结果 |
|---|---|
| 4×9 动作/热区路径 | **36/36** 命中至少一个合法文本池 |
| 实际可达独立池 | **20**（10 combo、9 zone_tier、1 low fallback） |
| `combo_overrides` | **10/10** 均有对应 `dialogue.combo`，无孤儿组合 |
| `zone_tier` | **9/9** 均有实际调用来源 |
| 即时反应候选 | **42** 条独立可达文本；因共享回退池，跨 36 路径展开共 **84** 次候选 |
| Profile 全部对白 | **70** 条；本轮未出现重复原文 |
| 旧错误口吻 | 搜索无「这招」「得意一小会儿」「我现在很放松」等旧句 |
| 称呼 | 未提前出现「龙司」 |

**按真实命中池的语义抽检：** 面颊、颈部、亲吻等 `favorite` 主要表现想更接近；轻咬唇颈的 `mild` 表现短促惊讶；`low` 回退池与较不习惯的组合不说成技巧评语；`breasts/nipples/genitals` 区域主要使用简短呼吸与未完成句，不借机进行长篇叙述。**不因表中存在这些热区而增加新的动作描写或场景机制。**

### 4. Phase 2 与 Aftercare 核对

完全保留已获准的 Phase 2 V1.3.4 行为：

1. MAX 仅提示一次，`excitement >= 100` 后可以继续 Phase 1，不自动跳 Phase 2。
2. 玩家仍在 `gentle` / `intense` 二选一；按钮标签「温柔进入」「粗暴进入」与原有双方同意前提不变。风格选择**只影响两处台词**，不会改动偏好、评分、CG、结算或手术系统。
3. Phase 2 顺序仍为：风格开场一句 → `scene.start` 无放回抽两句 → 风格中段一句 → `scene.middle` 无放回抽两句 → 等待手动 `h_finish`。
4. Finish 按钮使用现有全局五标签、进场随机且本次 H 内固定；点击后独立随机播放一条芹香的四句完成反应，等待确认后进入正常 Free H Aftercare；不重复播放旧 `dialogue.scene.finish`。
5. 正常 Free H Aftercare 改为短促的拥抱请求与感受呼吸的余韵。**关系里程碑**仍交还原作者固定事件的 Aftercare，绝不注入通用 Free H 文本。

V1.1 的情绪递进不是「从不愿意到被说服」，而是「明明自己愿意靠近 → 私下仍害羞 → 亲密中一时说不出完整的话 → 事后恢复安静，却不急着松开」。这与 Lv4 已确定的恋人身份一致。

### 5. Codex 交接中仍需核验的真实项目事项

- `doc_serika` 仅为目前文件中的 Actor ID 候选：检查现有 staff/H registry，**不要重复创建芹香**；如正式 ID 不同，Profile 和 Flow 必须同步适配。
- `res://assets/h/doc_serika/...` 及 `res://data/h/doc_serika/h_bodymap.json` 是占位路径。体图、九区域、各表情立绘、Phase 2 CG、Aftercare CG 都未由写作端证实存在；**不要伪造 UV 几何**。
- 旧 H 系统曾将 `home` 固定解释为坂口家。进入本 Runner 时应按 `(actor_id, location_id)` 匹配芹香家背景/显示名，优先复用 Lv4 的合法场景资源；不得给芹香开放多地点选择。
- 与小夜香已批准 `schema 1.3` Profile／`Phase2 1.3.4` Flow 的真实 Godot 解析器逐字段核对。`h_finish_button_labels.V1_3_4.json` 及外部 VN Aftercare 分流需运行验证。
- 不修改芹香 Lv4 主事件脚本，不混入 Lv5 司法和 Staff-as-Patient 许可，也不添加 Free H 对 Relationship 等永久属性的结算。

**V1.1 当前结论：** 写作端结构覆盖与可达动作/区域语义检查通过；本轮已针对 V1 三条 P1 语气问题作系统性重写。**作者尚未批准具体台词，真实运行与资源检查未完成，不能标注为已实装。**
