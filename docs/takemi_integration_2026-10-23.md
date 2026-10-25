# 武見妙基础医护与工作对白接入（2026-10-23）

> 后续状态：Lv0 六段现已接入，原文与门槛、CG和最新测试见 [Lv0接入报告](takemi_lv0_integration_2026-10-23.md)。下文保留基础注册阶段的记录；其中“等待Lv0”现已完成。

本次按 STAFF_DIALOGUE_ONLY V1 范围完成，actor ID 为 `doc_takemi`。角色初始未相识、Lv0、熟悉度0；不出现于普通地图或邀请池。未创建 Lv0 剧本、触发计数、阶段旗标或地下室入口。等待作者另行提供正式相识事件后再开放。

## 资料与权限

| 能力 | 武見（用户已确认） | 御堂现有值 |
|---|---:|---:|
| 手术 | 94 | 94 |
| 诊断 | 90 | 88 |
| 协作 | 73 | 82 |
| 照护 | 60 | 66 |
| 器械 | 93 | 93 |
| 冷静 | 95 | 95 |

年龄保留 `null`、成年字段 `true`、展示 `??`，没有编造具体年龄。界面支持未知年龄，已有医护年龄不变。熟悉度倍率采用项目默认 ×1.0。

岗位仅 `assistant_surgeon`，实际邀请仍要求正式相识。主刀权限拒绝，不能占用护士岗位。测试中的 `meet_staff` 只作用于测试实例，不写玩家存档。关系升级使用现有 `relationship_progression_locked` 暂停；五个结构槽位均 unavailable、无事件、无门槛、无奖励。强制 schema 所需约会记录为 `can_date=false`，其技术字段不构成未来剧情门槛；后续包应重新配置。

## 文本与运行入口

全部60组中英对白逐字保存在 `data/staff/doc_takemi/profile.json` 的 `authored_dialogue`。运行时使用现有 inline bilingual 本地化机制；没有翻译或改写用户原文。角色名、专业、简介及常规团队字段登记在 `data/localization/en.json` 和 `zh_CN.json`。

| 原文池 | 当前映射 |
|---|---|
| offer_accept（3） | 医生助手受邀 |
| before_incision（3） | 助手术前确认 |
| routine_assist（4） | 医生助手常规术中回应 |
| patient_responding_awake（3） | 清醒患者的助手稳定动作 |
| crisis_observation（4） | 现有医生助手纠错入口；不替换护士危机播报 |
| anesthesia_selected（8） | 实际麻醉选择后的零耗时回应页 |
| after_success（6） | 术后结果页，按实际麻醉状态区分 |
| after_abort_or_failure（2） | 补救失败、中止手术反馈 |
| normal_primary_surgeon_blocked（2） | 原文已登记；当前界面没有医生主刀邀请入口，权限层直接拒绝，待未来入口引用 |
| 地下室／休息室／手术室／天台日常（17） | 已加载，保持未开放；地下室尚无正式地图ID，地点候选原文保存在 integration_decisions.json，不发明调度权重 |
| 同事交流（8） | 已加载，待 Lv0 和日常入口定稿；未擅设熟悉度门槛或下班邀约 |

现有患者专属团队对白仍优先于普通医护池。没有增加剧情旁白、选项或转场；回应页“继续术前准备”仅为界面按钮。

选择局部、硬膜外或全身麻醉使用 bored；无麻醉在玩家最终确认后使用 pleased，临时选择后反悔不会先触发无麻醉反应。每台最多一次，后续改选不重复。确认回应后恢复基础表情，危机和结算不保留态度表情。响应不改变能力、协作、危机、声望、熟悉度或耗时，原无麻醉后果保持原样。

## 美术

使用内置 image_gen，正式复制入工程共35张，其中33张立绘、1张术中HUD头像、1张助手CG。全部保留铆钉项圈，白大褂保持雪白。

| 服装目录（assets/characters/takemi_tae_v1/） | 张数 | 表情键 |
|---|---:|---|
| white_coat | 10 | neutral、talking、soft_smile、wry_smile、angry、sad、surprised、worried、shy、focused |
| sterile | 7 | neutral、pleased、bored、focused、stern、worried、surprised |
| casual | 8 | neutral、talking、soft_smile、wry_smile、surprised、sad、worried、shy |
| casual_winter | 8 | 同春夏常服 |

春夏常服依据用户原作建模：黑色短皮夹克、青蓝蜘蛛网纹裙、破洞黑袜；秋冬为毛领深色夹克、红裙、黑袜与手套。统一半身至裙下沿构图。常服已登记，约会仍等待正式剧情开放。

术中头像位于 `assets/characters/intraoperative_staff_avatars_v1/doc_takemi/neutral.png`，助手CG位于 `assets/events/staff_surgery_v1/doc_takemi/assistant_confirmation.png`。`sterile/focused`现为独立资源；三套露面服装的`smile`作为`soft_smile`别名，不计作额外图片。

生成提示词与来源：`research/character_references/takemi_tae_2026-10-23/expression_expansion_generation.json`（新增29张），此前基础素材见同目录`art_generation.json`和`art_revision_white_choker.json`。文件尺寸和哈希见`data/staff/doc_takemi/assets_manifest.json`。原种子保留未改。

## 验证

- `takemi_source_audit.py`：60组中英原文完全一致，35张资产哈希一致，源包未修改。
- `validate_data.py`：865条记录通过。
- `narrative_localization_test.py`：12014项、0失败。
- `localization_audit.py`：735/735英文UI键、无新增硬编码中文。
- Godot `takemi_registration_test.gd`：628项、0失败，覆盖中英加载、未相识隐藏、权限、四种选择、反应一次性、实际显示纹理、退出复位、数值对照、无反应中存档及持久文件无演出内部字段。
- Godot `boundary_save_test.gd`：900项、0失败。未扩大存档边界；新增反应状态只存在运行时内存快照中，不进入持久格式。

普通日常池、主刀拒绝池的未开放状态和泛用危机入口限制已在上表明确列出；不将这些待未来剧情的内容宣称为已能在正常游戏中触发。

补充回归限制：旧 `preop_test.gd` 自身有第1150行动态类型推断错误；临时标注类型后又在既有 nausea 测试第165–181行中断。本次未将该旧套件记为通过，临时类型修改已撤回。武見专项504项和存档900项独立通过。

美术修订提示词见 `research/character_references/takemi_tae_2026-10-23/art_revision_white_choker.json`，由内置 image_gen 完成；旧版完整保留在同目录 `art_before_user_revision/`，正式路径已换为修订版。

表情扩展验证：35张资源哈希通过，865条数据验证通过，Godot专项628项、0失败（含全部新立绘纹理和透明通道）。日志：`docs/qa/takemi_registration/expression_expansion_runtime.log`。编辑器导入完成；环境另有系统证书与工程外编辑器偏好保存提示，不影响本次资源加载验证。
