# 现行数据契约

基线：2026-10-29，芹香独立六头像 + 共用Runner。执行时以现行代码为准。所有下列路径均相对用户仓库，`res://`是Godot资源前缀。

## 权威实现与文件

| 用途 | 读取位置 |
|---|---|
| 注册／可用性 | `godot/systems/free_h_registry.gd`、`game_state.gd`的free_h_unlocked/can_book_free_h |
| 原稿→运行数据 | `godot/systems/h_profile_v1_content.gd`的normalize/normalize_flow |
| 点击、反应、阶段 | `godot/systems/h_profile_v1_session.gd` |
| 语境与图片坐标 | `godot/systems/scene_content_context.gd` |
| 实际显示与离院 | `godot/ui/app.gd`中_h_profile_expression_texture、_begin_h_profile_session、_try_free_h_departure等 |
| 最新范例 | `data/staff/doc_serika/h_profile_v1_1.json`、`h_flow_v1_1.json`、`h_context_v1_1.json`；`data/h/doc_serika/h_bodymap.json` |
| 旧角色兼容范例 | 小夜香Profile1.3、Flow1.3.2、独立finish sidecar及专用表情图集，不直接套到新角色 |

新角色常用交付路径（文件名版本可按作者包调整，不强制v1_1）：

```text
docs/source/<actor>_h_<version>/    用户原件、双语审阅、导入SHA256清单
data/staff/<actor>/h_profile_<version>.json
data/staff/<actor>/h_flow_<version>.json
data/staff/<actor>/h_context_<version>.json
data/h/<actor>/h_bodymap.json
assets/h/<actor>/body_map.png
assets/h/<actor>/portrait_<expression>.png  六张
assets/h/<actor>/scene_cg.png
assets/h/<actor>/aftercare_cg.png
docs/qa/<actor>_h/                检查日志、截图、验收结果
```

## 1. 原稿Profile

模板：[h_profile.template.json](../assets/h_profile.template.json)。`schema_version`必须是字符串`"1.3"`；根字段：actor_id、adult_confirmed、assets、preferences、dialogue。

- `adult_confirmed`只在项目身份事实明确后填true，空白模板保留null。
- assets包含body_map_image、body_map_regions、portrait_expressions六ID、scene_cg、aftercare_cg。路径通常为`res://...`。现行adapter对新人物的底图实际取Context；Registry热区实际取注册bodymap路径，三者必须一致，不只修改Profile外观字段。
- preferences：zone_defaults必须列齐九区；action_overrides和combo_overrides可以为空字典。档位为low/mild/strong/favorite。
- 动作ID：`caress`, `kiss`, `lick`, `light_bite`。
- 区域ID：`lips`, `cheeks`, `neck`, `breasts`, `nipples`, `navel`, `torso_other`, `genitals`, `thighs`。这是接口枚举，不是要求助手编写具体内容。
- 偏好优先级：动作×区域组合覆盖 > 动作覆盖 > 区域默认 > mild回退。组合原稿键为`action:zone`，由adapter转换结构；不能把规范化数据再作为原稿传给normalize。
- dialogue包含tier_fallback、zone_tier、action_tier、combo、location_entry、scene。反应池可用字符串数组；现行Session也接受`{"line":"作者原句","expression":"已有表情ID"}`项。使用对象时审计须核对文本和显式表情，不能沿用只认识字符串的旧审计。
- 反应选择：combo > zone_tier > action_tier > tier_fallback。当前普通反应以history.size取模选池，不是每次随机；不要未经授权改成随机。
- scene的start/middle/finish每池恰好3句；1.3.4保留finish池，但阶段不自动播放它。
- 四个tier_fallback均须有有效文本以保证全组合覆盖。现行宽松valid_setup不能代替全文可达性检查。

**旧Schema陷阱**：`data/schemas/h_profile_v1.schema.json`描述旧的数值schema1结构，字段与现行1.3原稿不同，甚至不能完整覆盖normalize返回的扩展字段。不能直接用它判定新原稿有效或强迫新增未开放地点。实际判定采用normalize + Registry + Session +专属文本审计。

## 2. Flow

模板：[h_flow.template.json](../assets/h_flow.template.json)。`patch_version="1.3.4"`，actor_id须与Profile一致；技术协议保留模板所列布尔约束和播放结构，作者只填写对应正文和已确认标签。

- MAX阈值100，只提示一次，允许继续互动，无自动进入下一阶段。
- style仅有gentle/intense，两者各一开场和一中点；现行不改变偏好、结果、永久关系或CG。
- 阶段二：style开场1句→start池无放回抽2句→style中点1句→middle池无放回抽2句→等待手动完成，共6句初始播放。
- `phase2.manual_finish.on_click.response_pool`恰4句；共享结束标签5种在阶段进入时抽1次并保持稳定；完成回应独立抽取、只执行一次，必须等玩家推进确认。
- 完成后`external_vn_aftercare.free_h.on_entry_line_sequence`恰2句；按顺序走完才结算离院。
- 复用`data/h_finish_button_labels_v1_3_4.json`；`button_label_source`是元数据，真正读取文件由Registry的finish_labels指定。
- 新角色1.3.4可令注册finish_actor为空字符串，回应内嵌在Flow；不要再强制加一份互相矛盾的sidecar。
- 小夜香固定事件的专用回调仍有actor/event逻辑；不能声称新人物填一个event_id即可复用完整里程碑回调。

## 3. Context与英文

模板：[h_context.template.json](../assets/h_context.template.json)。`schema_version="1.0"`，actor_id一致。

- `base.assets.body_map`须有path、角色专属layout_id、真实width/height；stage和after_cg可按Profile默认，显式填写时保持一致。
- `base.assets.background.id`必须在`data/backgrounds.json`有实际文件。不要用文件路径替代背景ID。
- `entry_random_one`按作者决定。`locations.<实际地点>.dialogue.en.entry`保存英文入场数组。
- 正式重复内容的events保持空；Registry会移除事件语境，不能靠这里给重复流程塞入一次性正文。
- 对白语境优先级是event→location→base；同一层先尝试完整候选key，再移到下一层。覆盖池是原子替换，不逐句拼接。资产只走location→base，不用event层。

英文key映射：

| 原稿字段 | Context英文池键 |
|---|---|
| tier_fallback.low等 | `reaction.tier_fallback:low`等 |
| zone_tier的`zone:tier` | `reaction.zone_tier:zone\|tier` |
| action_tier的`action:tier` | `reaction.action_tier:action\|tier` |
| combo的`action:zone` | `reaction.combo:action\|zone` |
| scene.start/middle/finish | `scene.start` / `scene.middle` / `scene.finish` |
| MAX | `max_prompt` |
| style开场 | `style.opening.gentle` / `style.opening.intense` |
| style中点 | `style.midpoint.gentle` / `style.midpoint.intense` |
| 手动完成回应 | `finish.responses` |
| 全局结束标签 | `finish.labels`（沿用已批准译文） |
| 事后两句 | `aftercare` |
| 入场 | locations下的`entry` |

上表反斜线仅为Markdown转义；真实JSON键用单个`|`。base.dialogue.en及location英文数组与对应中文按位置同序，单句也是长度1的数组。另补全`data/localization/en.json`里的角色名、地点名、背景名、预约回应。当前style按钮英文由共用UI提供；用户更改中文标签语义时须同步核对英文按钮，不能只改Flow。

## 4. 热区

模板：[h_bodymap.template.json](../assets/h_bodymap.template.json)，故意不提供任何假坐标。最终遵守`data/schemas/h_bodymap_v1.schema.json`：schema_version数值1、status draft/final、base_image无res前缀、真实宽高、coordinate_space normalized_uv_0_1、九区hotspots。

每区值为多边形列表，每个多边形至少3个`[u,v]`点。按最终图逐区标定，`u=x/width`、`v=y/height`。不使用显示框坐标直接除原图尺寸；先按contain求实际图片矩形，排除letterbox，再归一化。优先级以Session.HOTSPOT_PRIORITY为准，检查精细区域覆盖大区域时的命中。

九个逻辑区不等于九个多边形；双侧可分多个。十四个多边形只是芹香实例，不是新角色要求。

## 5. Registry与资格

`free_h_registry.gd`的角色条目需要：content_status、location_id、可选fixed_location、地点名及翻译键、邀请回应及翻译键、completion_kind、completion_event、completion_flag、adapter、profile/flow/finish_labels/finish_actor/bodymap/context路径。新人物使用`authored_v1_3`。

- completion_kind为special_event时读取特殊事件完成事实；普通角色事件走现有character_event路径。使用仓库真实ID。
- formal资格还要求已相识、项目成人身份、无不适用身份锁、既有unlock_intimacy_events资格；预约还检查在场、工作日、安全边界和已知剧情冲突。
- 资产缺失、英文缺失、前置不存在或流程未验收时不设ready。已提供但未复制也算未接好。
- 缺图期明确登记pending_assets；补齐后通过检查才设ready，不永久遗留素材锁。
- 当前存档的预约业务事实为workday、actor_id；没有把选中地点、台词进度或反应历史一起序列化的授权。

## 模板使用约定

`assets/*.template.json`是可解析但故意不符合运行就绪条件的填写稿。`__ACTOR_ID__`、`__LOCATION_ID__`、null与空字符串均须由真实资料替换；不得拿这些占位跑正式事件。输出草稿放候选/工作目录，源包另存，完成后才接实际引用。
