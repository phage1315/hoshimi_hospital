# 城宮明日香 Lv3《本院长不接受反驳哦》实装与验收报告（2026-11-14）

## 1. 实装范围概览

- **原稿依据**：`research/source_scripts/HOSHIMI_ASUKA_LV3_NO_OBJECTIONS_V1_1.md`（V1.1 定稿，单次体验 166 拍，全图含 Scene A 双开场变体共 177 个节点，双语覆盖，家族暗线与 Lv4 防剧透红线 100% 守住）。
- **逐句原稿审计与两处必要非剧情格式清理（按 `AGENTS.md` 明示报告）**：
  1. `al3_067`（Scene C 原稿第 201 行）：去除作者给美术／演出的非角色可见括号批注 `（仅在身前展示比划，并未换穿）`，避免舞台制作提示直接显示在对白框正文中；
  2. `al3_075`（Scene D 原稿第 227 行）：去除 Markdown 粗体星号 `**奶白色**` → `奶白色`（Godot 普通 `Label` 会把原始 `*` 字面渲染在画面上）。
  - 除上述两处纯非剧情／Markdown 格式标记外，全篇对白、旁白、说话人归属、标点与节拍顺序 100% 原字原句保留，零补写、零删减、零死亡字眼（`病逝`、`遗物`、`遗照`、`葬礼`、`在天之灵` 均为 0）、零 Lv4 剧透（`继父`、`再婚` 均为 0）。
- **事件 ID、周日邀约触发与双开场自动分流**：
  - 事件 ID：`asuka_lv3_no_objections`（登记于 `data/staff/doc_asuka/lv3_events.json`，通过 `data/staff/doc_asuka/bundle.json` 的 `additional_character_event_files` 加载，并在 `data/staff/doc_asuka/relationship.json` 挂载为 `target_level: 3, content_status: "authored"`）。
  - 触发门槛：仅在周日「邀请某人外出」（`sunday_invites`）主动选择 `doc_asuka` 时触发（绝不在工作日或周日院长室地点触发）；要求 `met == true`、`level == 2`、已完成 `asuka_lv2_right_person_right_gown`、`familiarity >= 40`、主角 `charm >= 50`、满足 3 日关系里程碑冷却；**无月份锁**，且**不依赖 `maki_lv0_onboarding`**（麻纪入职前后均可正常触发）。满足条件时自动在周日候选前 5 名置顶并显示故事事件徽章，点击邀请直接进入 Lv3 专属剧情（跳过普通约会婉拒随机数）。
  - Scene A 双开场兼容（`godot/systems/asuka_lv3.gd`）：读取既有持久边界事实 `completed_sunday_dates` / `sunday_history`（零新增存档字段），从未与明日香完成过普通周日约会时走 `A-1`（`al3_a1_001..011`），已有普通周日约会记录时走 `A-2`（`al3_a2_001..011`），并于 `al3_012` 无缝合流。
  - 原子结算与零双重奖励：播放期间全程锁定存档（`locks_saving: true`）、隐藏顶部时钟栏（`hide_calendar_header: true`）；抵达 `@end` 原子升至 `Lv3`、写入 `asuka_lv3_complete`，并通过独立周日台账项 `"asuka_lv3_date"` 消耗当次周日推进至周一 `09:00`，**不重复发放普通周日约会的熟悉度、`魅力 +1` 或 `completed_sunday_dates` 计数**；完成后后续周日恢复普通约会流程。
- **新增美术资源（8 张 `1024×1536` RGBA 透明立绘 + 1 张全屏试穿 CG + 2 张专属背景）**：
  - 周日约会针织开衫私服（`date_cardigan`）：`assets/characters/asuka_lv3_v1/doc_asuka/date_cardigan/{smile,playful,nostalgic,laugh,shy}.png`（经本地离线 `BiRefNet-ToonOut` 抠图，四角全透明，`.import` 开启 `mipmaps/generate=true`）。
  - 1970 年代风格奶白色厚棉布手术袍＋全包发圆顶布帽＋双系带厚布口罩（`vintage_cream_gown`）：`assets/characters/asuka_lv3_v1/doc_asuka/vintage_cream_gown/{expectant,shy_earnest,blushing_happy}.png`（`1024×1536` RGBA，开启 `mipmaps/generate=true`）。
  - Scene F 全身穿衣镜试穿专属全屏 CG：`assets/events/asuka_lv3_v1/vintage_cream_gown_mirror.png`（`1376×768`，登记画廊 `cg_asuka_lv3_vintage_cream_gown_mirror`）。
  - 专属场景背景：`assets/backgrounds/asuka_lv3_v1/cafe_exterior_day.png`（`asuka_lv3_cafe_exterior_day`）与 `assets/backgrounds/asuka_lv3_v1/hospital_archive_room_afternoon.png`（`asuka_lv3_archive_room_afternoon`），并复用 `date_cafe` 与 `hospital_courtyard_evening`。

---

## 2. 实际执行的静态审计与引擎测试

| 检查项 | 执行命令 | 结果 |
|---|---|---|
| 原稿逐句、双开场、零剧透与美术／Mipmap 审计 | `.venv/bin/python tools/asuka_lv3_source_audit.py` | **PASS（`3603 checks; 0 failure(s)`）** |
| 既有明日香 Lv1／Lv2 与麻纪 Lv0 原稿审计回归 | `.venv/bin/python tools/asuka_lv2_source_audit.py && .venv/bin/python tools/asuka_lv1_source_audit.py && .venv/bin/python tools/maki_lv0_source_audit.py` | **全部 PASS（`3292/0`、`502/0`、`4221/0`）** |
| 全量叙事双语本地化测试 | `.venv/bin/python tools/narrative_localization_test.py` | **PASS（`49008 checks; 0 failure(s)`）** |
| 医护独立台词双语测试 | `.venv/bin/python tools/staff_localization_test.py` | **PASS（`1209/1209`）** |
| 本地化覆盖率审计 | `.venv/bin/python tools/localization_audit.py` | 叙事 **`57371/57371`**、UI **`803/803`**（全仓仍因既有 `voice_director.gd` 5 行中文退出 1） |
| 数据结构与引用校验 | `.venv/bin/python tools/validate_data.py` | `doc_asuka` / `lv3_events` / 新增立绘背景 CG **0 错误**（全仓因既有其他角色积压项退出 1） |
| Godot 资源与 Mipmap 导入 | `/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot --headless --path . --log-file /private/tmp/hoshimi-asuka-lv3-uid-import2.log --editor --import --quit` | **PASS（退出 0）** |
| 明日香 Lv3 专项回归（门槛矩阵、麻纪独立性、周日置顶、A-1/A-2 分流、零双重奖励、v37 存读档与重构韧性、中英 UI、后续普通约会回退、画廊回放） | `.../Godot --headless --path . --log-file /private/tmp/hoshimi-asuka-lv3-test3.log --script res://tools/asuka_lv3_test.gd` | **PASS（`2275 checks, 0 failure(s)`）** |
| 关联角色与存档回归套件 | `asuka_lv2_test.gd` / `asuka_lv1_test.gd` / `maki_lv0_test.gd` / `maki_staff_test.gd` / `boundary_save_test.gd` / `event_rendering_save_boundary_test.gd` / `narrative_save_lock_test.gd` / `surgery_history_save_test.gd` / `localization_test.gd` | **全部 PASS（`3697/0`、`1468/0`、`3840/0`、`84/0`、`1020/0`、`8223/0`、`6/0`、`1064/0`、`33/0`）** |
| 原生非 Headless `1280×800` 窗口实机抓帧验收 | `.../Godot --path . --resolution 1280x800 --log-file /private/tmp/hoshimi-asuka-lv3-native-qa2.log --script res://tools/asuka_lv3_preview_capture.gd` | **PASS（`67 checks, 0 failure(s)`，生成 `01`–`20` 共 20 张 `1280×800` 实机截图并逐项目检）** |

---

## 3. 原生窗口截图索引（同目录 `01`–`20`）

- **中文实机流程（`01`–`16`，走 `A-1` 首次周日约会分支）**：
  - `01_zh_sunday_invites_story_badge.png`：周日外出邀请列表，明日香置顶并带故事事件圆点徽章。
  - `02_zh_scene_a1_cafe_exterior_playful.png`：Scene A-1 街角咖啡馆门前 `date_cardigan/playful`。
  - `03_zh_scene_a_merge_shy.png`：Scene A 合流处被夸穿搭耳廓微红 `date_cardigan/shy`。
  - `04_zh_scene_b_cafe_dessert_nostalgic.png`：Scene B 店内纠结和栗蒙布朗与无花果挞 `date_cardigan/nostalgic`。
  - `05_zh_scene_b_cafe_hobby_secret.png`：Scene B 分享大学起私藏绝版手术服的秘密爱好 `date_cardigan/playful`。
  - `06_zh_scene_b_return_to_hospital_laugh.png`：Scene B 店外大笑解释周日第二站去后院旧馆二楼 `date_cardigan/laugh`。
  - `07_zh_scene_c_archive_room_smile.png`：Scene C 进入后院旧馆二楼·院史资料室 `date_cardigan/smile`。
  - `08_zh_scene_c_scrub_dress_nostalgic.png`：Scene C 展示浅青灰旧式手术裙并感叹「美学退步」`date_cardigan/nostalgic`。
  - `09_zh_scene_e_no_objections_playful.png`：Scene E 标题金句「本院长不接受反驳哦！」`date_cardigan/playful`。
  - `10_zh_scene_e_first_gown_hot_shy.png`：Scene E 初次上台穿老式厚棉布袍反差吐槽「……有点热。」`date_cardigan/shy`。
  - `11_zh_scene_f_mirror_cg_reveal.png`：Scene F 全屏专属 CG `vintage_cream_gown_mirror.png`（穿衣镜斜前方暖金斜阳试穿）。
  - `12_zh_scene_f_gown_shy_earnest.png`：Scene F 奶白旧袍立绘 `vintage_cream_gown/shy_earnest` 捏袖口追问「我问的是，穿着它的我，好不好看？」。
  - `13_zh_scene_f_gown_blushing_happy.png`：Scene F 奶白旧袍立绘 `vintage_cream_gown/blushing_happy` 弯起月牙眼「……那么，这个意见，本院长就接受了。」。
  - `14_zh_scene_g_dusk_courtyard.png`：Scene G 傍晚庭院连廊道别 `date_cardigan/playful`。
  - `15_zh_sunday_complete_lv3.png`：周日结束结算页 `【城宮明日香 Relationship Lv3 达成】`（推进至周一 `09:00`）。
  - `16_zh_gallery_cg_unlocked.png`：事件鉴赏画廊解锁预览与题注。
- **英文实机流程（`17`–`20`，走 `A-2` 已有普通约会记录分支）**：
  - `17_en_scene_a2_prior_date_opening.png`、`18_en_scene_e_no_objections.png`、`19_en_scene_f_mirror_cg.png`、`20_en_sunday_complete_lv3.png`。

---

## 4. 未测范围与后续边界说明

1. 本轮原生窗口截图由 `tools/asuka_lv3_preview_capture.gd` 在真实 macOS 非 Headless `1280×800` 窗口渲染管线自动推进抓帧，尚未进行人工鼠标逐拍手动点击游玩。
2. 城宮明日香的 `Relationship Lv4`（揭晓母亲健在再婚移居海外与正式确立恋爱关系）及 `Lv5` 属后续独立剧本内容。
3. 全程仅使用内存与 `/private/tmp/` 独立临时测试路径，未读写任何真实玩家存档槽位。
