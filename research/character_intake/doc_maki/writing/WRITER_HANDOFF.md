# 相澤麻紀台词／Lv0 作者交付规范

将本文件、`dialogue_delivery.schema.json`、`dialogue_delivery.template.json` 和上级目录 Character Bible 一并交给写作 LLM。本包是作者交付契约，不是游戏运行 JSON；无需写 Godot 代码或系统 flag。原稿中的 ID 仅供编辑和分支导航，绝不用于保存剧情播放进度。

## 事实优先级与创作范围

用户最新决定：麻纪21岁，比深山和明日香小2岁；覆盖 Bible 中“精确年龄未定”。其他设定按 Bible。六维建议48/65/72/68/56/45仍未审定，不能写作已定游戏参数。

麻纪已有外科基础，礼貌拘谨但在专业问题上有主见。曾参与术后迟发出血抢救，患者获救，不能写成她造成事故。面试已见过坂口；被录用约一个月后报到，完成独立Lv0才进常驻互动和普通助手池。入职手术是纯VN，无普通手术Runner、随机危机或评分。大学学妹身份在下班前向坂口披露。不可自创Lv1–Lv5门槛、恋爱资格、主刀权限或患者路线。

Bible中的对白示例不是最终台词。独立Lv0 Writing Brief尚未取得；其未知内容列入open_questions，不能假装已读。已有明日香Lv2面试稿不属于重写范围。

## 首批交付清单

| 项目 | 数量与用途 | 运行映射 |
|---|---|---|
| team_dialogue.assignment | 1条，可含简短动作与直接引语；编队选中时回应 | profile.team_dialogue.assignment（字符串） |
| team_dialogue.intraoperative | 1条，通用配合／观察回应，不绑定特定病种 | profile.team_dialogue.intraoperative（字符串） |
| idle_chats | 每个最终选定交流地点至少3条互相独立回应 | time_events：label、responses；现行闲谈30分钟、repeatable=true、无effects |
| first_assignment_cg | 标题、图注各1条，简短，不引入新事件 | role_rewards的title/caption；具体展示由现有流程处理 |
| lv0 | 完整逐句正文、说话人、演出、明确连接与结尾 | 工程选择现有事件接口后逐句转换 |
| 元信息 | 事件标题、公告、完成提示、画廊标题、说话人标签、所有选项 | 同步中文原文与英文译文 |

模板给出lounge和rooftop两组作为建议，并不批准在场日程。如果最终选其他地点，先明确地点及资源匹配。工作回应不是随机台词池，不要把数组直接塞进profile。额外按暴露／止血／缝合分段的台词可作为未来需求提出，本轮不是必填。

## 填写规则

- `format_version`和`actor_id`保持不变。`status=ready_for_review`只表示作者交稿，不表示用户审批或游戏可用。
- 文本对象均为`{"zh_CN": "中文原文", "en": "英文译文"}`。草稿缺口用null，不填“待补”、空字符串或伪造译文。可先交中文；最终实装前必须补齐英文。
- 一条node是一位说话人的一段正文。`kind=dialogue`使用明确角色ID；旁白用`narrator`，不要把人物对白挪到旁白。正文中保留最终标点和引号。
- `speaker_labels`列出所有实际出场说话人。现有ID包括player、doc_maki、doc_asuka、doc_rei、doc_emiko、doc_artoria、doc_aoi、nurse_hiroko；新增身份先在open_questions说明，不能假造已注册角色。
- `portrait_key`指麻纪当前显示的服装／表情，不等于当前说话人。无麻纪立绘时为null；其他角色站位与服装在stage_note注明，工程按实际资源核对。
- `stage_note`仅演出说明，不显示为旁白。`kind=stage`可不含正文。音乐、CG、背景或道具新需求写入asset_requests，不能宣称资源已存在。
- 无选项节点使用`choices=[]`和`next`；下一节点可以跨场景引用。事件最后一节点`next=null`。每场`start`必须存在，`start_scene`指向首场。
- 选择节点`next=null`，每个choice填写id、label、next；目标必须存在，分支必须能回归或到明确结尾。`outcome_note`仅说明叙事差别，不填写数值奖励／程序flag。
- `duration_minutes_proposal`为建议，不作为已定排期；完成事实用自然语言表达，工程按安全边界结算。不要增加事件中途存档。
- 建议每页中文以约40–100字为主，长段拆节点；这只是写作建议，不是引擎硬限制。不得为满足字数自动压缩已批准原文。

## 可用麻纪立绘键

| 服装 | 表情 |
|---|---|
| casual | neutral（基础为轻微笑意）、focused、worried |
| interview | neutral、focused（讲话）、worried、relieved |
| white_coat | neutral、smile、focused（讲话）、worried |
| sterile | neutral、focused、worried；口罩遮住口鼻，只改变眼神眉毛 |

四套均1024×1536透明半身／至髋立绘。当前没有独立scrubs刷手服、笔记本持握姿势或新CG；需要时列asset_requests，不以不匹配的键掩盖缺图。首次助手CG为手术室内麻纪面对主角的主观视角，主角不入镜。

## 作者自检与工程接收

1. JSON通过随附schema；所有node／scene／choice ID在各自范围内不重复，next目标存在，没有断路和意外循环。
2. 有正文的节点必须有中文；英文覆盖程度如实列出。检查说话人、标点、顺序及分支，元信息不能漏翻。
3. 与Bible及用户最新决定无冲突；未定项保留疑问，不私自补成已批准事实。
4. 同时交可读剧本版本供用户审核。工程只转换已批准文本并逐句audit；模板通过不等于剧情通过或生产注册。

工程来源：`data/staff/doc_emiko/profile.json`、`time_events.json`、`events.json`、`data/schemas/content.schema.json`。不要求写作LLM照搬其他角色台词。JSON Schema只校验形状；图连接、文风、资源存在性和中英完整性需要另行检查。
