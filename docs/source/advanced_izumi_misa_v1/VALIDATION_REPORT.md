# 高级术式 #5／#6 内容数据静态校验

**校验日期：** 2026-11-01  
**结果：** `PASS`（仅 JSON 结构／内容自洽；尚非引擎实测）

## 校验范围

- `procedures_additions.json`、`art_manifest.json`：解析成功。
- `stories/` 两个 JSON、`dialogue/` 两个 JSON：解析成功。
- 两台 procedure ID 唯一、每台 12 个唯一 stage ID、6 个 P、2 个 S。
- `hp_base` 合计：伊兹米 **40**，美纱 **44**；全部阶段 `elapsed_time` 分别合计 **600**、**690** 分钟，与 `duration_minutes` 一致。
- 危机检查点均为合法 1-based 序号，且与概率条目数量一致：伊兹米 `6,9`，美纱 `5,9`。
- 每个 S 阶段有 2 个非空中英文选项、具体 `strategic_effects`。
- 每个阶段的 Day 2 `stage_entry` 具 2 条完整中英对白；每个 P 具 2 条 `acting_surgeon` 失败反馈，非 P 不包含失败反馈。
- Day 1/3 剧情只有当前 Story Loader 支持的 `patient` / `PLAYER` speaker；原稿动作在主交接规格中保留，但不强行改动现有 Story schema。
- 伊兹米 Day 1 / Day 3 成功分别 **18 / 10** 条人物对白；美纱 **15 / 7** 条。
- 术野三态的路径全部保持 `null`，`patient.visuals.portraits={}`；素材需求清单每台列 8 项，但不将建议文件名作为实际资源。

## 已知待测试／待确认

1. **没有**真实 Godot 工程执行、现有四台的 diff 对照、患者真实 ID 注册、实际医疗阶段 Runner 可玩性测试。
2. 未验证 HP/Precision/策略效果在真实生理机制下的玩家胜率。所有 `difficulty`、HP 与 `crisis_chances` 均为 P0 暂定。
3. `patient.id`、`runtime_case_id` 是根据上次内容包格式拟定值，Codex 应由游戏真实 registry 核对后使用。
4. 作者已于 2026-11-01 明确确认第六位名字是**美纱**，与最新高级转诊规则一致；姓名不再是阻塞项，但原作、全名与视觉锚点仍待核。
5. Day 3 失败必须复用当前 `dialogue/day3_failed.json` 四句团队对白；本包没有也不应增设个人失败故事。
6. 任何新增美术在实际文件存在、身份锚点与手术体位审核通过前不得配置 `runtime_ready=true`。

**交接结论：** 当前内容包可交给 Codex 做 registry/schema 审计与实装；不能宣称“已运行”“已平衡”或“已制作 CG”。
