# 高级转诊池 V2 实装与验收

2026-11-01。依据作者《Advanced Referral 解锁、展示队列与返场规则 V1》及本轮“请实装”授权。本次完成规则、正式入口、奖励链验证和双语显示；不等于规划中的23台高级术式全部完成。原稿位于 `docs/source/advanced_referral_unlock_replay_rules_v1/`，工程发现见同日 preflight 文档。

## 正式行为

- 千束教学最终成功结算后才激活。保存实际第三天完成日，不使用随后自动推进到的第四天；单独的旧解锁 flag 不足以提前开放。
- 下一个游戏日历月起，每月1日、15日增加一个发布资格。日期推进、读取与病例板均使用同一幂等同步入口；跨月、跨年、2月和跳过日期按固定日历补算。
- 新病例最多三格，稳定 FIFO。只有首次 Day3 成功或失败结算释放位置。已排程、只打开编组或中断手术不释放。
- 周一从周一开始前已首通的普通高级术式独立、有放回、等概率抽取两例；无首通则零例。即使只有一台首通，也生成两个不同病例ID。同周不补抽、不换患者，跨周保留已接受预约。
- 首次失败锁定；返场失败保留首通。Advanced 全部手动三阶段，公共扫荡服务同样拒绝高级术式。普通 Surgery 规则、HP、Precision、生理、危机与原有14日助手冷却未修改。
- 冷却显示中文／英文角色姓名。正式板显示三格；DEV 独立测试明确标为全部实装内容预览，可以直接测试四台，不代表正式解锁进度。

## 固定发布清单

`data/advanced_surgery/release_manifest.json` 是独立、显式且以后只能追加的发布顺序。前四项采用本次核验的真实 registry 顺序固定，之后不再随 registry 数组重排。

| 顺序 | Procedure ID | 首通患者／可运行性 |
|---|---|---|
| 1 | surgery_open_whipple | 山内樱良，可运行 |
| 2 | surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction | 佐仓濑津美，可运行 |
| 3 | surgery_adv_sleeve_lobectomy | 里见菜穗子，可运行 |
| 4 | surgery_adv_ebstein_cone_reconstruction | 秋庭里香，可运行 |
| 5 | surgery_adv_complex_abdominal_reconstruction | 伊兹米，预留，runtime_ready=false |
| 6 | surgery_adv_open_descending_thoracic_aortic_replacement | 美纱，预留ID，runtime_ready=false |

未 ready 项保留日期资格并阻塞其后的 FIFO，不越过它替换其他患者或术式。美纱没有覆盖既有开胸开腹主动脉瘤术。

## 奖励落地

正式 Day3 结算继续调用 `advanced_settlement.gd` 的现有 resolver，写入真实 Surgery XP、Leadership XP、医护训练 credits、团队熟悉度、共同手术次数及声望；既有代码已具备该链，本次接通新版病例生命周期并验证，没有另造奖励算法。

| 测试初始声望 | 成功声望增量 | 测试 Surgery XP | 测试 Leadership XP |
|---:|---:|---:|---:|
| 300 | 40 | 528 | 8 |
| 480 | 20 | 528 | 8 |
| 590 | 10 | 528 | 8 |
| 600 | 0 | 528 | 8 |

528／8是主刀88级、测试团队与Whipple的实际结果，不是所有术式固定奖励。首次／返场成功均结算；失败不发成功奖励；DEV不改变正式成长。已完成病例ID保证重复 settle 拒绝，保存已结算数值，读取不再发奖。

## 特殊剧情接口

- `ADVANCED_TUTORIAL`、`ADVANCED_REGULAR`、`ADVANCED_QUEST_KAORI`、`LEGENDARY_STORY` 分开计数。教学、薰、传奇不进入普通板和周常。
- 薰前置为5种不同普通首通；第二／三台接诊不早于前一台真实成功 Day2+30，且前一台须已成功结算。只提供 Gate 和日期检查，不自动触发或编造剧情。
- Ray前置为10种不同的普通＋薰首通。重复、教学、传奇、未知ID不计入。目前只有4台可运行，薰与Ray专属内容仍未制作；不会伪造解锁。

## 存档合同与迁移

在现有 `advanced_referral_facts` 上升到 version=2，主存档仍使用安全边界契约；没有另存一套系统进度。

新增：`activated_day`、`unlocked`（已发放资格ID）、`new_board`（最多3个术式ID）、`clear_days`（首次成功结算日）、`successful_operation_days`（实际成功手术日）。候补由固定manifest、资格、已展示／已结算事实派生。保留原有 `procedures/cooldowns/week/replays/appointment/outcome/completed`。周常病例使用 `id/procedure_id/patient_id/replay/case_seed`，seed只标识业务病例，不保存术中随机状态或医学操作过程。

V1迁移保留成功／失败、旧周常、预约、冷却、结果和奖励。可靠的千束完成日用于补算资格，旧 completed 的实际日期用于首次首通日。已预约的旧第四台可继续，不撤销。缺少可靠激活日期或首通日期时显示中英提示：保留进度，缺日期的术式不参与新周常抽取，不拿当前日期猜历史。

JSON数值可能读取为浮点型；版本验证接受值为1／2的整数数值，其他字段白名单不放宽。读取不写玩家磁盘存档。

**原稿T08的断点措辞遵循项目边界：医院导览／周日才可保存；中途退出只能从已有安全存档恢复预约并重新进入安全入口，不恢复技术节点、HP、选择路径、危机RNG或对白进度。** 原教学测试中途保存期待已修正为禁止保存，继续验证内存中完整演出。

## 验收证据

使用Godot 4.5.1。所有自动测试使用独立内存世界和/tmp日志；实机指原生窗口自动驱动，不冒充手工逐句点击。

| 测试 | 本次结果 |
|---|---|
| advanced_referral_rules_v2_test.gd | 413 checks，0失败；日历、FIFO、周常、迁移、JSON往返、幂等、三日排程、真实Runner与安全边界 |
| advanced_referral_tutorial_test.gd | 467 checks，0失败；实际完整教学、第三天结算日期与首批三台 |
| advanced_reward_cooldown_test.gd | 92 checks，0失败；真实奖励、软硬上限、训练、重复结算／保存读取及中英姓名 |
| advanced_referral_board_v2_test.gd（原生窗口） | 14 checks，0失败；正式三新＋二返场与中英姓名 |
| advanced_review_regression_test.gd --native | 6554 checks，0失败；四台中英文演出、Day1/3输入、说话人与立绘、成功／失败和返场 |
| narrative_localization_test.py | 29678 checks，0失败 |
| localization_audit.py | 退出0；引用UI英文754/754，无硬编码中文候选；全项目作者文本覆盖38105/38436，未宣称无关旧内容翻译全部补齐 |

规则测试含随机运行路径，断言总数可随路径小幅变化。主要对应原稿T01–T23；T08按上面的安全存档约束验证。T22额外覆盖3月30日无法排程但资格保留。Ray十种门槛尚无足够正式内容供真实玩家达成，本次验证分类与排除规则，不宣称其剧情可游玩。

日志：`/tmp/advanced_v2_rules.log`、`advanced_v2_tutorial.log`、`advanced_v2_reward.log`、`advanced_v2_native.log`、`advanced_v2_formal_native.log`。正式板截图：`/tmp/advanced_board_v2_zh_CN.png`、`/tmp/advanced_board_v2_en.png`。

## 被替换的旧位置与剩余生产项

- `advanced_referral.gd`：全量新病例／旧1–3去重周常／通用唯一计数改用规则服务。
- `advanced_referral_facts.gd`、`game_state.gd`：V2白名单、迁移、日历同步和最终教学Gate；公共 `procedure_sweep_unlocked` 阻止高级扫荡，普通路径保留。
- `advanced_referral_view.gd`、`ui_text.json`：分区与姓名；删旧Quick提示。
- `advanced_surgery_test.gd`、`advanced_referral_tutorial_test.gd`：更新一台首通只抽一例、单flag开池和术中保存等旧断言。
- 当前接口文档、原型说明、内容清单、呈现说明及save_boundary_v37同步标注本轮现行规则；归档原稿不改写。

仍待制作：第5伊兹米、第6美纱及其余普通高级术式；薰三连与四传奇专属内容；随机患者额外俯视美术；术式级双评价。没有新增剧情对白或修改既有医护能力，没有提交／推送／发布，没有覆盖玩家存档。原有芹香Lv4/Lv5未提交内容保持。
