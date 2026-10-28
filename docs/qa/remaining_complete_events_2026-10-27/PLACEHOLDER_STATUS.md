# 占位内容与本轮范围

2026-10-27，main/f95636a 加现有工作区。下表依据现行 relationship.json 的 rank_slots.content_status=planned；不按节点数量短或背景名含 placeholder 就判整事件占位。

| 角色 | 尚未制作升级剧情的等级 |
|---|---|
| 神宮寺 成美 | Lv1, Lv2, Lv3, Lv4, Lv5 |
| 深山 佳織 | Lv4, Lv5 |
| 七瀬 恋 | Lv1, Lv2, Lv3, Lv4, Lv5 |
| 中井 美佳 | Lv1, Lv2, Lv3, Lv4, Lv5 |
| 朝倉 美幸 | Lv2, Lv3, Lv4, Lv5 |
| 飯村 真奈美 | Lv2, Lv3, Lv4, Lv5 |
| 杉村 弘子 | Lv2, Lv3, Lv4, Lv5 |
| 本庄 萌惠 | Lv1, Lv2, Lv3, Lv4, Lv5 |
| 御堂 江美子 | Lv3, Lv4, Lv5 |
| 城宮 明日香 | Lv1, Lv2, Lv3, Lv4, Lv5 |
| 阿尔托莉雅·潘德拉贡 | Lv2, Lv3, Lv4, Lv5 |
| 藤崎 詩織 | Lv1, Lv2, Lv3, Lv4, Lv5 |
| 水城 阿库娅 | Lv2, Lv3, Lv4, Lv5 |
| 遥凑 | Lv1, Lv2, Lv3, Lv4, Lv5 |
| 石神 千鹤 | Lv1, Lv2, Lv3, Lv4, Lv5 |
| 折川 皐月 | Lv4, Lv5 |
| 岩崎留美 | Lv1, Lv2, Lv3, Lv4, Lv5 |
| 米田栞 | Lv1, Lv2, Lv3, Lv4, Lv5 |
| 薗田愛実 | Lv1, Lv2, Lv3, Lv4, Lv5 |
| 狩谷惠 | Lv1, Lv2, Lv3, Lv4, Lv5 |
| 氷上冴子 | Lv1, Lv2, Lv3, Lv4, Lv5 |
| 御園芹香 | Lv4, Lv5 |

共 22 位角色、94 个 planned 升级槽位；这些槽位不是 94 个已注册可播放事件。已有初识或其他旁支不因此排除。

另有真夜、双叶、麻醉科樱花、武见各 Lv1–Lv5 共 20 个 `unavailable` 槽位：现行设定未开放，不称为待补剧情 placeholder。武见现有 Lv0 六段、真夜/双叶初识仍属于可测试内容。

## 其他排除与区别

- framework_single_day_test、framework_three_day_test：developer_only 的框架验证事件，排除正式剧情验收。
- 深山 Lv3《手术室之神》：原稿完整性已报告缺口，待用户补全；不是 planned 占位槽位，本轮不重复测试未补全内容。
- 深山 Lv1《叮。》的 `palpation_placeholder` 已按用户后续授权接入受限触诊界面（2026-10-27）：仅手部、腹部固定无法解释、乳房／阴部复用既有羞耻回应。内部节点 ID 与归档原文保留，但运行时不再显示旧的“后续制作”说明。记录见 `../takemi_miyama_palpation_2026-10-27/REPORT.md`。
- 安琪 Lv5 的授权 flag 门槛属于尚未开放条件，不等同于 placeholder。
- 背景资源名 after_work_street_placeholder 不作为整个事件未完成的判断依据。

## 本轮待复验的已注册剧情事件

以下 17 个条目有剧情数据且未标记为 planned/placeholder；是否完整符合最终原稿仍需审计，不预先宣布完整验收通过。

- 请把我的名字划掉 `serika_lv1_cross_out_my_name`
- 落下半拍 `serika_lv3_half_beat`
- 不准拿刀的医生 `takemi_lv0_t1`
- 报废的手术台 `takemi_lv0_t2`
- 手术室的幽灵 `takemi_lv0_t3`
- 地下室里的一扇门 `takemi_lv0_t4`
- 生体解剖 `takemi_lv0_t5`
- 第三台 `takemi_lv0_t6`
- 新手术室启用日 `or_acceptance_training_01`
- 本人就在这里 `advanced_referral_tutorial_chisato`
- 从今天起，独立看诊 `probation_completion_personal_nurse`
- 说好这次不跑的 `chihaya_second_surgery_a`
- 说好这次不跑的 `chihaya_second_surgery_b`
- 说好这次不跑的 `chihaya_second_surgery_c`
- 这次真的不会有第四次了吧？ `chihaya_third_surgery_a`
- 这次真的不会有第四次了吧？ `chihaya_third_surgery_b`
- 这次真的不会有第四次了吧？ `chihaya_third_surgery_c`

## 后续入口配置更新

用户确认仅打开芹香 Lv3 入口配置，仍保留瑞穗完整链条件。现行配置为启用，但尚无生产事件写入瑞穗完整链完成事实，所以当前自然游玩仍不能触发。见 [本轮修复报告](../followup_event_fixes_2026-10-27/REPORT.md)。
