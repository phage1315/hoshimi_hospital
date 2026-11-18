# 相澤麻紀：新人外科医生接入资料包

建立：2026-11-13。当前为制作资料，未登记生产角色、未新增事件或改变排班。建议稳定 ID：`doc_maki`（当前未发现同名登记）。

## 已建立的资料

- [Character Bible 原文](HOSHIMI_AIZAWA_MAKI_CHARACTER_BIBLE.md)：用户文件逐字复制，保留已定／建议／待定区分。
- [基础档案草案](profile_draft.json)：已定身份及能力边界；未定数值明确为 null。这不是可直接加载的 profile。
- [美术制作表](asset_plan.json)：面试服、白大褂、刷手服、无菌服及医护术中头像；表情组合为建议。
- [来源与 SHA-256](source_manifest.json)：两张用户种子图与 Bible 均原样归档，未裁切、抠图、重绘或上传。
- [原作单人参考](references/seed_ass03_single.png)、[原作表情参考](references/seed_ass03_sheet.png)。

## 当前项目证据

仓库已存在面试正式审阅稿 [明日香 Lv2 V1.1](../../source_scripts/HOSHIMI_ASUKA_LV2_RIGHT_PERSON_RIGHT_GOWN_V1_1.md)。Bible 引用的标题文件名与仓库实际文件名不同，保留原文，通过此处做路径对应。

已有[面试服原始候选图](../../generated_candidates/asuka_lv2_portraits_v1/maki_interview_suit_base_raw.jpg)，仅确认文件存在，不宣称已批准、透明化或生产接入。当前未找到麻纪 `data/staff` 正式档案。Bible 引用的独立 Lv0 Writing Brief 未在仓库及 Downloads 文件名检索中找到；Lv0 正式逐句正文也未取得。

## 最小接入所需资料

| 类别 | 现状 | 后续动作 |
|---|---|---|
| 身份、职业、性格、经历、同事关系、视觉锚点 | Bible 已提供 | 以原文为基线，已有事实不需重填 |
| 精确年龄 | 21岁；用户指定比两位23岁学姐小2岁 | 已记录于档案；Bible 原始附件保留不改 |
| 六项能力 | 未定 | 确定 surgery、diagnostics、teamwork、patient_care、instrument_handling、calmness；工程录入前审定 |
| 熟练度与岗位 | 已定入职后普通手术助手；熟练度枚举未定 | 只配 assistant_surgeon，不默认独立主刀或高级手术资格 |
| 院内在场 | 入职事件完成后开放；具体地点未定 | 建议医生办公室／病房为工作场景，休息室为交流场景；最终地点和日程待定 |
| 关系初始值 | 未定 | 确定初始 affection/familiarity 与 met 的结算点；Lv1–Lv5 可暂不制作，不照搬其他人的门槛 |
| 面试与入职 | 面试原稿已有；Lv0 只有设计契约 | 提供 Lv0 Writing Brief 与正式剧本；明确工作日触发时段、耗时和完成事实 |
| 普通工作文本 | 尚无批准文本 | 编队回应、术中回应，以及所选在场地点需要的日常聊天；另行授权写作或提供原文 |
| 游戏立绘 | 两张种子图、面试服候选 | 按美术表制作／确认；原始种子图始终参与身份校准 |
| 英文 | 档案英文名已整理，其余尚未制作 | 正式接入同步翻译档案、事件、提示、选项、画廊和工作文本 |

生日、身高、私人生活、可攻略路线、患者身份、语音、专属 CG 都不是新人医生首批接入必需条件。无需为补齐表格硬填。

## 时间线与可用性契约

1. 明日香 Lv2：面试、接受录用、记录实际面试日期。不能在这一步加入常驻排班或助手池。
2. 约 30 天后，在合适工作日启动麻纪独立 Lv0《排班表上的名字》。准确日程规则待正式稿。
3. Lv0 中第一助手身份属于固定 VN 演出；不调用普通手术 Runner、随机危机、手术评分或额外手术结算。
4. Lv0 完成后才开放日常互动、在场和普通助手岗位。面试已经认识她，不能把报到演成双方首次见面。
5. Lv1–Lv5、私人关系、独立主刀权限均未定。

## 工程接线清单（待资料完备后执行）

- 加载链：`data/manifest.json` → `data/staff/index.json` → `data/staff/doc_maki/bundle.json` → profile / relationship / 必要事件分片；实现见 `godot/scripts/content_loader.gd:load_staff_bundles`。
- profile 当前必需字段见 `data/schemas/content.schema.json` 的 staff 定义，不能把本资料包带 null 的草案直接搬入。正式生成 profile、relationship、bundle 后再注册 index。
- `role_rewards`、`date_profiles` 等为按功能需要选用的分片；不必复制另一位医生整包，也不必为不存在的约会／患者路线填占位图或台词。
- 现有 `GameState.staff_is_met` 读取 `staff_unlock_event`，但当前检查的是 `special_event_done`。若 Lv0 采用 character event，必须核对完成事实类型并正确接线，不能只填字符串就宣称门槛生效。
- 编队走 `GameState.staff_can_join_surgery_team`；在场走 presence resolver。面试后、到期前、Lv0 未完成时分别验证不可入池。避免面试时简单设置 met 而提前开放。
- 延期依据实际面试日期与稳定完成事实；仅在安全边界持久化必要事实，不存 VN 节点、步骤、选项路径或播放进度。
- 原稿及译稿与运行 JSON 分开；Bible 的语义示例不是批准的对白，不能当正式事件文本导入。

## 正式实装验收（本轮未执行）

内容验证、staff 本地化、narrative_localization_test、localization_audit；逐句原稿 audit；独立临时存档检查面试／延迟／入职资格、重复播放不重复奖励、读档保持日期与权限；普通助手选择；中英文原生窗口立绘、头像及文本显示。若触及存档事实需另跑对应边界回归。

## 本轮实际检查

三份附件复制 SHA-256 一致；资料 JSON 可解析；相对链接存在；git diff 空白检查。未修改运行数据或代码，因此未执行 Godot、剧情本地化或生产解锁测试。不声称新人已可用。

## 2026-11-13 美术与数值更新

用户否定旧面试服画风。新[四套基础立绘及首次助手CG](../../generated_candidates/maki_original_style_v1/generation.json)均以两张原作种子图生成，等待基础图确认，未透明化／接入。常服、面试服、白大褂、无菌手术服各一张；无单独刷手服。建议六维 48/65/72/68/56/45（顺序见 profile_draft），尚未审定。

## 台词交付与已批准美术

本轮用户批准四套基础立绘，授权差分和透明化。写作LLM可使用[交付说明](writing/WRITER_HANDOFF.md)、[JSON Schema](writing/dialogue_delivery.schema.json)、[空白模板](writing/dialogue_delivery.template.json)，或下载[maki_writer_packet_v1.zip](maki_writer_packet_v1.zip)。仅作者交付格式，不直接加载运行。
