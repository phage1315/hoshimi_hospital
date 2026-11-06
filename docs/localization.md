# 多语言框架

游戏以简体中文原文作为权威内容，但英文模式不允许以中文回退填补缺译。当前支持的语言代码为：

- `zh_CN`：简体中文；
- `en`：英文。

标题界面的语言按钮会把选择保存到 `user://settings.cfg`。切换语言时，内容会重新载入；已有游戏状态通过稳定的角色、事件、病例和术式 ID 恢复，因此语言选择不会写入或迁移存档。

## 翻译文件

翻译位于 `data/localization/<locale>.json`。英文文件结构为：

```json
{
  "locale": "en",
  "name": "English",
  "strings": {
    "ui.title.start": "Start Game    →",
    "collections.surgeries.surgery_appendix.name": "Open Appendectomy"
  }
}
```

所有活跃的正文和界面键都必须有非空英文译文。英文模式遇到缺译或中文残留时显示带键名的缺译标记，并记录错误；`tools/localization_audit.py` 将其视为发布阻断项。

## 数据键规则

JSON 内容无需增加双语字段。加载器依据稳定路径生成键：

```text
protagonist.<field>
dialogue.nodes.<node_id>.<field>
collections.<collection_id>.<record_id>.<field>
collections.character_events.<event_id>.nodes.<node_id>.text
```

数组元素有 `id` 时使用 `id`；没有 `id` 时使用数组下标。因此所有新事件节点和选项都应尽量保留稳定 ID。

GDScript 中尚未数据化的界面文字通过：

```gdscript
tx("ui.example.key", "中文回退")
```

解析。不要用翻译后的显示文字参与条件判断、存档或资源查找。

## 检查

无需第三方 Python 包的译文检查：

```bash
python3 tools/localization_audit.py
python3 tools/localization_strict_gate_test.py
python3 tools/staff_localization_test.py
```

审计会分别报告：

- 数据内容的活跃字段是否全部有英文译文；
- GDScript 已通过 `tx()` 接入的 UI 键及其英文覆盖率；
- 仍可能直接写在 UI 脚本中的中文字符串行数；
- 全部活跃正文和 UI 的中文原文与英文译文之间 `%s`、`%d`、`%02d`、`{line}` 等格式占位符是否一致；
- 英文译文中是否仍有中文字符。

审计还递归核对 `data/` 中直接存放的 `zh_CN`／`en` 文本对，以及高级手术资源的 `text`／`text_en` 等成对字段。标题、说话人、正文和选项都必须有真正的英文文本；将中文复制进英文栏同样会失败。
严格门槛测试用隔离临时文件注入缺译、中文残留和占位符错误，确认审计确实会拒绝这些缺口；不会改写项目内容或玩家存档。

安装 Godot 后可运行端到端加载测试：

```bash
godot --headless --path . --script tools/localization_test.gd
```

基础医疗循环还包含按病例与患者动态生成的问诊、病房准备、换装、麻醉和术中步骤。静态词条审计无法完整发现这些路径中的中文，因此修改相关模板或运行时生成逻辑后还应执行：

```bash
godot --headless --path . --script tools/localization_runtime_scan.gd
```

该检查会用英文内容实际构建全部患者问诊与术前会话，并递归检查最终显示数据。检查结果必须为 `RUNTIME ENGLISH SCAN: 0 Chinese leak(s)`。
随机病例的英文病史、症状、检查发现和鉴别诊断应逐病例翻译，运行时直接使用已本地化的病例模板；不得再用通用英文句子覆盖不同病例。

全库检查以当次 `tools/localization_audit.py` 输出的活跃字段和 UI 键数量为准；新增任何活跃中文内容时，必须同时提供英文，不能依靠中文回退通过审计。

角色包中有些台词以 `team_dialogue`、`procedure_group_team_dialogue`、`personal_nurse.dialogue` 和地点闲谈 `responses` 的语义键保存，普通字段审计无法自然识别。`tools/staff_localization_test.py` 会递归检查这些台词，要求每句中文原文都有非空、无中文残留且占位符一致的英文译文；当前检查覆盖 176 句。

31 个人物专属事件、20 个日常 micro event，以及大型特殊活动的长篇对白均已有英文。`tools/narrative_localization_test.py` 会强制检查人物事件、micro event、特殊事件定义和特殊事件节点中的全部中文正文、标题、公告、完成提示、画廊章节、说话人标签和选项；任何新增但未翻译的字段都会令测试失败。

新增或修改基础医疗循环数据后，应重新运行 `tools/seed_english_content.py` 与 `tools/seed_english_clinical.py`，再由人工校订生成的英文。新增或修改上述三类剧情时，应补充英文表并运行：

```bash
python3 tools/narrative_localization_test.py
python3 tools/patient_bundle_localization_test.py
```

后一项会递归检查所有患者包中的反应表、差分对白、术前阶段提示、切口反馈和专属 CG 文字，防止这些以动作 ID 为键的字段绕过普通正文审计。
它也要求 `{line}` 等占位符在中英文之间逐项对应；通用审计已对全库缺译和中文残留设为失败，患者专项检查继续验证反应表等语义键及占位符。

医护作为患者的对白保存在 `data/staff_patient_profiles.json` 的 `dialogue.zh_CN`／`dialogue.en`，不属于普通患者包。新增或开放 Lv5 医护患者时，还必须运行：

```bash
godot --headless --path . --script res://tools/staff_patient_lv5_readiness_test.gd
python3 tools/advanced_staff_patient_source_audit.py
```

Readiness 测试逐字段检查已注册医护患者的中英文对白结构、非空译文、中文残留与 `{procedure_name}` 等占位符，并验证至少有可用的邀请台词；高级手术的 24 人预置剧本另由原文审计核对。两项自动检查仍不能代替作者原稿逐句核对或可见窗口验收。
