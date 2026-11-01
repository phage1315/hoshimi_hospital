# 朝仓 Lv2《明天开刀的事》实装记录

2026-10-30。依据作者 Codex Ready V1；作者另行授权忠实英文翻译，并要求赖子素材改为种子图的 90 年代赛璐璐画风。中文 273 条正文、说话人、顺序、标点逐条保留。未编号制作说明不显示为对白。

## 现行入口与结算

- 正式相识朝仓（`nurse_yui`），实际完成 Lv1 `miyuki_lv1_not_that_kind_of_inexperienced`，当前 Lv1，Fam≥25，关系冷却≥3自然日。
- 非周六且次日没有调度器排定的强制特殊事件或日初人物事件，结束工作时播放前夜 A。手动结束与加班后延期日终均进入同一插入逻辑，位于下班同行与日终 splash 前。
- A：`miyuki_lv2_preop_evening`，197 节点，零耗时，不升级。A 已决定播放时将朝仓排除出当晚同行池，其他角色照常可选。A 完成后恢复原日终回调，保留同行与正常 splash。
- A 的事件级完成日期确定 B 的次日预约。B：`miyuki_lv2_preop_morning`，76 节点，于次日 09:00 强制开始，不重新检查 Fam／冷却／朝仓出勤；完成后一次性结算 240 分钟和 Lv2，淡出后 13:00 返回导览。
- 清晨五点半、七点等内容是正文里的蒙太奇，系统时钟不倒拨。A 也不改变当前已结算时钟；夜间病房是演出场景。
- 未创建实际患者 Bundle、手术预约、术式、Surgery Runner 或术后玩法；无 Surgery XP、团队经验、领导力、声望奖励。两幕分别开放回想，回想不结算。

## 存档边界

继续只允许医院导览／周日安全界面保存；没有新增日终或 VN 中途保存入口。持久化复用 `special_event_completion_counts`、`special_event_completion_days` 和已结算时间／关系事实，未保存节点、点击路径、舞台时钟或回调。未完成的一幕从上一个安全存档重播，不恢复其中途状态。安全边界读取 A 完成记录后，B 的预约仍有效。

已测试将完成事件的节点列表删除后读取安全存档，时间与关系不变；再次保存读取稳定，无重复升级或扣时。所有测试文件均写入 `/private/tmp`，未覆盖玩家存档。

## 人物与素材

| 原文说话人 | 实装对应 | 服装／演出 |
|---|---|---|
| 朝倉美幸 | `nurse_yui` | A 白色制服；B 帽口罩刷手服，温和／专注切换，B2-067 转专注 |
| 二階堂頼子 | `story_guest_yoriko`（节点内具名客串，不注册正式人员） | 病房：患者袍、眼镜、笔记本；B2-004 后：无眼镜、头发收入帽内、裸肩及锁骨，无菌巾不入镜 |
| 南条小夜香 | `doc_sayaka` | B2-026、B2-068 等短暂帽口罩刷手服 |
| 中井美佳 | `nurse_rin` | B2-045、B2-072 等器械护士无菌工作装 |
| 坂口隆司 | player | 玩家发言，保留原说话人 |
| 值班护士 | 具名画外发言 | 不借用其他正式医护立绘 |

赖子病房素材位于 `assets/characters/yoriko_story_v1/`，手术室素材现用 `assets/characters/yoriko_story_v2/`：

- `ward_neutral`、`ward_worried`、`ward_surprised`：1024×1536。
- `or_neutral`、`or_curious`、`or_worried`、`or_surprised`、`or_held_breath`：1536×1024。
- 均保留生成原文件的 RGBA 透明通道，以原作参考和既有患者风格重做；最初不符合画风的候选未接入。
- `assets/backgrounds/ward_night_v1/ward_night.png` 为原病房背景的夜景版本，仅新增资源，未覆盖日景。
- B2-075 仅原文“哧拉——。”，无切口图或额外临床说明；B2-076 使用屏息差分。没有另加音效，本稿明确允许纯文字落点。

## 数据与复核入口

- 原稿：`docs/source/miyuki_lv2/HOSHIMI_ASAKURA_MIYUKI_LV2_PREOP_HORROR_CN_CODEX_READY_V1.md`，与 Downloads 原件逐字节一致。SHA256：`3857cbb6fe85a23c4f73208a86986eec0a81893c0d37ac13726f52bf3d9dddbf`。
- 中英及人物映射复核：`docs/source/miyuki_lv2/bilingual_review.json`。
- 素材来源／校验和：`docs/source/miyuki_lv2/art_manifest.json`。
- 事件定义／正文：`data/events/special_events/miyuki_lv2.json`、`data/events/special_event_steps/miyuki_lv2.json`。
- 专用导入器：`tools/import_miyuki_lv2.py`，只更新本事件与朝仓 Lv2 槽位，不运行历史事件导入器。
- 调度：`godot/systems/miyuki_lv2.gd`；接入 GameState 的事件门槛、预约与同行过滤，以及 app 的手动／延期日终恢复回调。
- 具名纯剧情客串校验：显式 `story_guest_` 头像 ID + 作者说话人标签 + 对应本地贴图，无需建立实际患者。

## 验证结果

- `tools/miyuki_lv2_source_audit.py`：273 条中文逐句、说话人、节点顺序、标点及中英完整覆盖通过。
- `tools/narrative_localization_test.py`：27348 检查，0 失败。
- `tools/localization_audit.py`：通过；UI 英文键 752/752，无新增硬编码中文。
- Godot `tools/miyuki_lv2_test.gd`：无头／实际 macOS OpenGL 窗口均 14602 检查、0 失败。每轮逐节点播放中文及英文实时事件和回想，共1092节点；检查实际显示文本、说话人标签、精确立绘资源、残留图层、分页与存档锁定。
- 门槛覆盖 Fam24／25、Lv1 实际完成、冷却2／3天、周六、次日强制事件冲突；预约跨读档、门槛改变后仍续播；手动日终、加班日终、其他角色同行共存；完成时刻和升级幂等。
- `tools/after_work_walk_test.gd`：101 检查，0 失败。`tools/narrative_save_lock_test.gd`：6 检查，0 失败。
- 实机截图及报告：`docs/qa/miyuki_lv2/`。已查看夜间病房、好奇、屏息、朝仓专注等代表截图。
- 全库 `tools/validate_data.py` **未全绿**：286 条已有问题（特殊事件优先级超旧 schema、千早二次手术旧客串身份校验、访客／诗织地点及芹香Lv3日期地点等）。排除本事件初次接入时的客串检查后，与原有结果逐条一致；本事件无 schema 或资源校验报错。未为通过旧检查改动其他剧情。
- Godot 无头环境报告系统证书读取警告；编辑器资源导入完成后报告其工作区外 editor_settings 无写权限。游戏脚本及实际窗口测试均正常通过，未更改编辑器权限或玩家存档。

### 2026-10-30 手术室差分修订

按作者要求重制五张手术室差分：裸肩、锁骨可见，无菌巾不入镜，保留现有表情、手术帽和赛璐璐画风。画布仍为1536×1024 RGBA，舞台布局未变；旧版资源保留，病房三张原文件校验和不变。专用导入器与预览页同步切换到 v2，素材清单保留上一版来源与校验和。

作者随后要求缩小病房立绘：显示框由440×530调整为340×410（缩小约22.6%），底部对齐朝仓的550基线。病房三个表情及中英／回想共同使用；原图像素不变。

修订后重跑实际 Godot 窗口：中英实时及回想1092节点、14602检查、0失败；已对照 a2_002 朝仓与 a2_003 赖子截图确认病房显示比例，并检查 b2_076 裸肩差分透明显示。273条原文核对和两项本地化审计再次通过。
