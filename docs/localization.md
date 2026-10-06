# 多语言框架

游戏以简体中文原文作为权威内容和缺失翻译时的回退文本。当前支持的语言代码为：

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

没有英文条目的键自动显示中文原文。空译文不作为有效回退，不应提交。

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
```

审计会分别报告：

- 数据内容中已翻译字段的数量；
- GDScript 已通过 `tx()` 接入的 UI 键及其英文覆盖率；
- 仍可能直接写在 UI 脚本中的中文字符串行数；
- 中文回退与英文译文之间 `%s`、`%d`、`%02d` 等格式占位符是否一致。

安装 Godot 后可运行端到端加载测试：

```bash
godot --headless --path . --script tools/localization_test.gd
```

基础医疗循环还包含按病例与患者动态生成的问诊、病房准备、换装、麻醉和术中步骤。静态词条审计无法完整发现这些路径中的中文，因此修改相关模板或运行时生成逻辑后还应执行：

```bash
godot --headless --path . --script tools/localization_runtime_scan.gd
```

该检查会用英文内容实际构建全部患者问诊与术前会话，并递归检查最终显示数据。检查结果必须为 `RUNTIME ENGLISH SCAN: 0 Chinese leak(s)`。

目前英文文件包含 5,055 条译文，完整覆盖 4,524 个已登记正文／数据字段及 Godot UI 脚本中的 442 个界面键，并覆盖序章、地点说明、普通病例池、问诊主流程、检查名称、病房准备、换装与刷手、麻醉选择、全部术式流程、清醒手术患者互动、临时状况、岗位首次担当奖励、术前／术中 CG 说明及开发验证事件。17 名现有医护的姓名、专科和人物简介也已有英文。

31 个人物专属事件、20 个日常 micro event，以及《新手术室启用日》《取材过头了》两项大型特殊活动的长篇对白均已有英文。`tools/narrative_localization_test.py` 会强制检查这三类内容中的全部中文正文、标题、提示和选项；任何新增但未翻译的字段都会令测试失败。

新增或修改基础医疗循环数据后，应重新运行 `tools/seed_english_content.py` 与 `tools/seed_english_clinical.py`，再由人工校订生成的英文。新增或修改上述三类剧情时，应补充英文表并运行：

```bash
python3 tools/narrative_localization_test.py
python3 tools/patient_bundle_localization_test.py
```

后一项会递归检查所有患者包中的反应表、差分对白、术前阶段提示、切口反馈和专属 CG 文字，防止这些以动作 ID 为键的字段绕过普通正文审计。
