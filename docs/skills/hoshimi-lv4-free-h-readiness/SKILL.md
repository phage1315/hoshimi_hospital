---
name: hoshimi-lv4-free-h-readiness
description: 核对《星见医院》某位医护开启 Lv4 自由 H 的固定剧情、解锁数据、双语 H Profile／Flow 对白和图片缺口；区分作者素材与可生成的 SFW 素材，并按确认清单接入验收。
---

# Lv4 自由 H：逐角色开通核验

用于用户询问“某位医护 Lv4 后能否开放自由 H、还缺什么、哪些 SFW 可以帮做”时。盘点与制作是两步：先查项目真实内容，给出具体缺口和可确认的 SFW 清单；用户确认生成范围与参考图发送授权后才生成。只要求清单时保持只读。详细 Profile schema 与 Runner 接入可继续使用现有 `hoshimi-h-profile` skill；本 skill 专注 **Lv4 固定剧情至自由 H 生产资格的完整门槛**。

## 现行事实优先

确认项目含 `project.godot`，读 `AGENTS.md`／`agents.md` 和 `git status --short`。确定角色 ID 后，检查 `data/staff/<id>/profile.json`、`relationship.json`、Lv4 事件原稿／运行数据、`godot/systems/free_h_registry.gd`、`game_state.gd` 的 `free_h_unlocked()` 与 `can_book_free_h()`，以及角色现有 H Profile／Flow／Context／热区文件、资产目录和导入登记。已提供的文件不得因旧清单写“缺失”而重复索要；区分已提供、已入库、已映射、Godot 可加载、原生窗口已显示。年龄事实取项目数据，不凭 SFW 外观判断。

## 开放条件与内容

- **Lv4 固定剧情**：最终原稿、稳定事件 ID、完整节点和选项、说话人／顺序／标点、前置、分支及完成结算；中文和英文标题、正文、姓名、选项、完成提示、画廊文字。`relationship.json` 的 Lv4 槽指向已实装事件。真实 `character_event_done` 或 `special_event_done`、完成 flag（若注册表要求）及 `unlock_intimacy_events` 权益必须在正式流程结算；数值 Lv4 不能代替完成事实。
- **生产注册**：`free_h_registry.gd` 中该角色 `content_status=ready`、单个真实 `location_id`、显示名、邀请回应及双语键、完成事件种类／ID／flag、adapter 和 Profile/Flow/Context/热区路径正确。地点背景在 `data/backgrounds.json` 注册并可加载；预约日、出勤及其他事件冲突遵循共享排程。
- **H 数据与对白**：角色自己的 Profile、Flow、Context 与中英文本覆盖正式入口、地点入场、四档通用反应（low/mild/strong/favorite）、两种 style 开场／中点、scene.start/middle/finish、MAX 提示、手动完成回应、事后两句；更具体的区域／动作覆盖若作者未提供可按现有回退机制视作可选。实际字段与数量以现行 `h_profile_v1_content.gd`、`h_profile_v1_session.gd` 和该角色原稿为准，不拿芹香的句数硬套。原稿缺句应列缺口，不补写；英文只在已有译文或用户授权翻译时处理。
- **九区互动**：`body_map` 实际像素尺寸与 H Context、热区 JSON 一致；九区各有可点多边形，含缩放／留边坐标测试。偏好档位与覆盖属于角色设定，不能从性格猜。运行时对白、选择与阶段状态不写存档。

## 图像盘点与分工

作者指定的四类基础图片：`body_map`、第二阶段 `scene_cg`、`aftercare_cg`、六头像中的 `portrait_neutral`。核对每项是否已有可复用的**本角色**文件；纯本地导入按用户映射原样复制，不主动打开图像作内容评价。其余头像 `annoyed/pleased/flustered/delighted/peak` 逐项检查是否独立存在、与 neutral 同构图、透明且已映射。若目标图属于可处理的 SFW 素材，才列入“Codex 可制作”确认清单；若属作者交付的私密图，列为作者素材。不能以 neutral 回退冒充六态齐全。

可由 Codex 制作的 **SFW 候选**通常是已指定地点的背景、时间差分、非私密转场／UI 画面，以及用户明确要求且可处理的着装人物差分。是否必需以当前 Lv4 事件与自由 H 实际引用为准；无引用列可选。清单每行给出槽位、已有参考、目标构图、输出路径和状态。用户确认清单且授权把参考图发送给生成服务后，才调用 `imagegen`。不把作者基础图擅自替换成生成图；生成不等于接入，接入不等于视觉验收。

## 用现有工具判缺并验收

优先用现有 `hoshimi-h-profile/scripts/inventory.py` 对 Profile／Context／bodymap 枚举路径、尺寸和摘要；阅读 `hoshimi-h-profile/references/author-inputs.md` 和 `integration-qa.md` 获取现行详细槽位。运行 `free_h_registry.gd` 的 `load_bundle(actor_id, locale)` 或该角色专项测试，记录具体错误；当前 `content_status` 未 ready 时，应先在**隔离测试**检查数据而不临时改生产注册。复用项目的 `tools/free_h_scheduling_test.gd`、相关角色 `*_free_h_test.gd` 和 `*_free_h_bodymap_test.gd`，必要时新增最小逐角色检查，不以别人的测试证明本角色通过。

剧情文本改动后运行 `python3 tools/narrative_localization_test.py` 与 `python3 tools/localization_audit.py`，另做原稿逐句中英 audit。随后用 `hoshimi-native-playtest` 的隔离存档方法，实测真实人物菜单→预约→下班转场→地点入场→九区／两种 style→事后→安全界面；检查六头像、背景、CG、文字溢出、键鼠和返回。headless 通过只叫自动回归，不叫窗口验收。测试绝不覆盖玩家存档，不为测试开放事件中保存。

## 交付格式

按 **Lv4 剧情／解锁与预约／Profile 与 Flow／双语对白／九区数据／作者图片／可生成 SFW／原生验收** 输出逐项状态、路径和真实缺口。状态用“未提供、已提供待导入、已映射不可加载、可加载待窗口验收、已验收”。给用户一张单独的 SFW 制作确认清单；只有用户确认后才开始生成。正式 `ready` 需真实 Lv4 完成事实、内容、资源和预约至事后窗口路径均通过，不以文档更新替代代码和测试。
