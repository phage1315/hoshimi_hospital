# 2026-10-01 回归检查记录

## 本次目标已通过

- Godot 4.5.1 主场景无头启动：退出码 0。
- `localization_test.gd`：24/24。
- `advanced_referral_test.gd`：11/11。
- `special_event_framework_test.gd`：98/98。
- `character_event_test.gd`：170/170（同步小夜香 Lv2 后的 31 个事件）。
- `sayaka_lv1_event_test.gd`：67/67。
- `surgery_progression_test.gd`：14/14。
- `relationship_system_test.gd`：24/24。
- `sunday_system_test.gd`：17/17。
- `save_store_test.gd`：19/19。
- `miyama_ayako_event_test.gd`：534/534。
- `patient_bundle_test.gd`：488/488。
- `player_office_test.gd`：17/17。
- `aqua_character_test.gd`：37/37。
- `calendar_system_test.gd`：30/30。
- `gigi_enema_test.gd`：11/11；`gigi_nude_portrait_test.gd`：5/5。
- JSON 全量解析、Python 工具语法检查、英文键审计均通过。

以上合计 1,566 项断言通过。

## 英文化审计

- UI：442/442 键有英文；UI 脚本中文直写候选为 0。
- 英文表：5,055 条。
- 当前审计范围内的剧情／数据字段：4,524/4,524 已翻译。
- `localization_test.gd`：24/24。
- `localization_runtime_scan.gd`：实际构建所有患者的问诊及术前会话后，基础医疗循环中文残留 0。
- `narrative_localization_test.py`：人物专属事件、日常 micro event 和两项大型特殊活动共 2,259 个中文剧情字段全部具有英文，0 项失败。
- `patient_bundle_localization_test.py`：患者专属反应表、术前阶段提示、切口反馈与专属 CG 文字共 580 个英文条目，0 项失败。
- 本轮补齐问诊、病房准备、换装与刷手、麻醉选择、术中动态准备、患者状态／反馈，以及上述三类长篇剧情内容。

## 尚未恢复为绿色的旧测试

下列检查在完整回归中仍失败，内容与本次本地化／高级转诊改动无直接依赖，但不能视作全量测试通过：

- `clinic_test.gd`：仍按旧的聊天解锁、旧门诊分钟数与旧可选路径断言。
- `micro_event_test.gd`：UI 测试未先满足当前 micro event 触发条件。
- `maya_character_test.gd`、`futaba_character_test.gd`：旧的精确资料／专属术中对白断言与现有数据不一致。
- `portrait_test.gd`：4 个旧表情按钮断言和 4 张既有患者图的画布尺寸断言失败。
- `preop_test.gd`：仍按旧术式目录、角色对白和旧手术流程推进方式断言，需单独按当前系统重写测试夹具。

## 环境说明

Godot 在 macOS 无头模式会打印读取系统 CA 证书的环境警告；主场景和上述测试仍正常退出。`tools/validate_data.py` 的完整 JSON Schema 步骤需要 `jsonschema==4.23.0`，当前 Python 环境未安装且本次未联网安装；已改用 Godot 内容加载测试、全 JSON 解析和现有跨引用回归覆盖本次数据改动。

## 高级转诊教学事件追加验证

- 《本人就在这里》扩充为 81 个运行节点；中英文文本同步。
- `advanced_referral_tutorial_test.gd`：62/62，覆盖三日流程、八阶段手术、术中存档恢复和完成奖励。
- `advanced_referral_test.gd`：11/11。
- `special_event_framework_test.gd`：98/98。
- `localization_test.gd`：24/24。
- `character_event_test.gd`：170/170。
- `save_store_test.gd`：19/19。
- `localization_audit.py`：5,270 个英文条目，UI 447/447，脚本中文直写候选 0。
- `narrative_localization_test.py`：2,457 项，0 失败。
- `patient_bundle_localization_test.py`：580 项，0 失败。
- 跨引用/领域验证：378 条记录通过。

另修复石神千鹤初始关系的存档兼容问题：未开放的职业信任路线仍以 `colleague` 作为运行时 route，并由锁定旗标阻止关系升级。
