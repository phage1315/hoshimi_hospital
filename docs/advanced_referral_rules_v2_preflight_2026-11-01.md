# 高级转诊池 V2 实装预检

历史预检记录。后续已实装，现行状态见[2026-11-01 V2实装与验收](advanced_referral_rules_v2_implementation_2026-11-01.md)；下文“尚未执行”仅表示预检时点。

依据：`docs/source/advanced_referral_unlock_replay_rules_v1/HOSHIMI_ADVANCED_REFERRAL_UNLOCK_REPLAY_RULES_CODEX_READY_CN_V1.md`。

状态：**可实装；本记录是开工发现与接入方案，不是 V2 已完成证明。** 本轮已修复冷却姓名显示，并新增／运行正式奖励及显示回归测试。没有更改池子、排程、奖励算法或玩家存档。检查时分支 `main`，HEAD `a5b4afbd`；保留已有芹香 Lv4/Lv5 未提交改动。

## 1. 运行中的四台与固定发布顺序

真实 registry 是 `data/advanced_surgery/procedures.json`，由 `godot/systems/advanced_surgery_model.gd` 读取。每台已经有实际 stages、首通剧情、术中对白与图片绑定。首通剧情路径为 `data/advanced_surgery/stories/<procedure_id>.json`。

| 拟固定 release_order | 实际 procedure_id | 首通患者 |
|---|---|---|
| 1 | `surgery_open_whipple` | 山内樱良 / `patient_yamauchi_sakura` |
| 2 | `surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction` | 佐仓濑津美 / `patient_sakura_setsumi` |
| 3 | `surgery_adv_sleeve_lobectomy` | 里见菜穗子 / `patient_satomi_nahoko_adult` |
| 4 | `surgery_adv_ebstein_cone_reconstruction` | 秋庭里香 / `patient_akiba_rika_adult` |
| 5（预留） | `surgery_adv_complex_abdominal_reconstruction` | 伊兹米·柯蒂斯；没有运行数据 |
| 6（预留 ID） | `surgery_adv_open_descending_thoracic_aortic_replacement` | 美纱；没有运行数据 |

排序决定采用本次核验的真实 registry 数组顺序，下一步写成独立显式 release manifest 后固定；不把数组顺序作为长期规则。故事包 `source_case_id` 中袖式／Cone 的历史编号与当前 registry 不同，不用历史编号改换患者或重排发布。第 5、6 项在实际 `data` JSON 内未检索到定义，不能展示可点击病例。美纱不覆盖 `surgery_adv_open_taaa_repair`。

## 2. 实际代码接点与缺口

| 项目 | 当前实现 | V2 接入工作 |
|---|---|---|
| 教学 Gate | `game_state.gd::advanced_referral_system_unlocked()` 检查 `advanced_referral_random_cases_enabled`；千束末句选项和事件最终完成 flags 设置它 | 以最终完成事实／结算为激活入口，记录一次激活日期，不能因只进入 Day 1 激活 |
| 完成日期 | `special_event_completion_days["advanced_referral_tutorial_chisato"]`；通用 special event 完成路径记录 | 使用已结算日期；检查日末自动推进与最终 Gate 的一致性。旧档若缺可靠日期须单独报告，不猜测 |
| 病例板 | `advanced_referral.gd::board()` 遍历所有 `Model.catalog()`，目前四台一起显示 | manifest + 时间资格 + 最多三格的稳定 FIFO；首次成功／失败最终结算才释放 |
| 月度发放 | 尚无 | 复用 `fixed_calendar.gd`；下一个日历月起每月 1/15，补算跨日且幂等 |
| 周常 | `advanced_referral.gd::refresh()` 每周抽 1–3 种不重复术式 | 固定两次有放回抽取，实例 ID 需含独立序号；保持当周患者／病例稳定 |
| 周中首通 | 依赖首次打开 Board 刷新；没有周一时点首通资格快照 | 由日期推进处理，并在 UI 补算；必须按周一已有首通事实抽选，不能周二临时补发 |
| 排程／互斥 | `schedule/accept/rebook/start_operation/finish_operation/settle` 已有三日排程、固定剧情避让、单预约、助手冷却 | 沿用；周一刷新不删除 active appointment |
| 保存 | `advanced_referral_facts.gd` V1 严格白名单；`game_state.gd` snapshot/restore | 升级同一 facts，不另建 runner 存档；保留旧结果、奖励、预约、耗时 |
| 特殊 Gate | 当前直接数所有 `procedures` 内 `CLEARED`，5/10 写 flag | 按类别分别统计；薰只计普通 5，Ray 普通＋薰 10；教学／传奇／返场重复不计 |
| 薰间隔 | 未接入专属三台 30 日系统条件 | 只做 Gate／实际手术日业务事实与间隔接口，不编造薰内容 |

当前 game calendar 为 2025-04-01 起的一年周目，已有 `date_for_day` / `day_for_iso` 和星期定义；不能拿现实日期或简单 30 天月份代替。日期推进不能仅依赖玩家打开 Board。

### Quick 入口

Advanced Board 当前没有可点击 Quick 按钮，只有说明文案；独立 Advanced controller 没有 Quick 执行函数。

但公共 `game_state.gd::procedure_sweep_unlocked()` 在已解锁且有完成计数后，会允许三台普通质量门槛术式之外的 ID；不能据此声称 Advanced 已有完整服务端禁用。V2 需在 Advanced 类型上阻断公共扫荡入口与执行路径，保留普通 Surgery 原有判断、数值及奖励。移除 Advanced 页面 Quick 说明文案，不用修改术中对白。

## 3. 奖励不是待创建的空接口

`advanced_referral.gd::settle()` 正式成功分支已经调用 `advanced_settlement.gd`，后者调用现有：

- `award_surgery_xp`：手术难度、主刀等级、团队学习倍率、术式训练上限。
- `award_leadership_xp(..., "advanced")`：基础 8，叠加既有团队倍率与等级上限。
- `train_surgery_team(..., "advanced")`：高级训练 credits，既有岗位映射／能力上限。
- `award_surgery_reputation`：Advanced 基础 +40，480 起减半，600 硬上限。
- 共同手术次数、团队熟悉度及已完成手术总数／术式次数。

独立测试 `dev=true` 刻意不调用真实奖励 resolver，不影响正式玩家成长；不能为了让测试画面有数值而污染玩家数据。

本次新增 `tools/advanced_reward_cooldown_test.gd`，使用独立内存 GameState 和模拟的已完成手术结果，检查**真实结算方法**，不是重新计算一套预计奖励。Whipple、主刀 88、测试团队的实际结果：

| 初始声望 | 成功声望奖励 | 手术经验 | 领导经验 |
|---:|---:|---:|---:|
| 300 | +40 | +528 | +8 |
| 480 | +20 | +528 | +8 |
| 590 | +10 | +528 | +8 |
| 600 | 0 | +528 | +8 |

528 与 8 是本测试配置结果，非所有高级手术的固定发放值。首通与返场成功均发放；失败不发成功奖励；返场失败保留 CLEARED。测试覆盖训练 credits 变化、重复 settle 不再发奖、安全边界 snapshot/restore 不再发奖、独立测试隔离。**V2 改动仍需再次覆盖这一组测试及完整手术流程。**

## 4. 持久化接入方案与不可采用的段落

在既有 facts V2 中增加最小业务事实：激活日、已发放资格、最多三项新病例展示队列、周常批次标识／已抽病例。候补可由显式 manifest、资格和已展示／已完成集合有序派生；避免同时保存两套互相矛盾的进度。周常保存实际 case ID、procedure ID、patient ID、必要变体与病例生成 seed；该 seed 仅用于业务病例身份，不能保存术中 RNG、操作日志或续演数据。

第 5／6 项到时间而未 ready 时保留资格，阻塞后续 FIFO，不用其他术式替补。

旧档迁移保留 completed、procedures、cooldowns、appointment、outcome 和已有周常病例；以可靠的千束完成日补算资格。对于旧的第四台已预约／已完成等情况，不撤销既有业务事实。无法恢复激活日期或发现旧 Quick 活动状态时，先列出实际受影响记录及方案，不能凭当前日期替代历史日期。

**原稿 §3/T08 的“恢复会话或安全 checkpoint／不重抽技术节点”不能解释为术中保存。** 按项目最高存档规则，Day 2 中断后载入原有医院／周日安全边界，恢复预约业务事实并从安全入口重新进入手术；不保存 HP、步骤、选项、危机 RNG 或对白位置。没有合法存档点时不能承诺断点续演。此处以用户既定存档边界为准，不需另行开放保存。

## 5. 本轮已完成与后续验收

已完成：

- `advanced_referral_view.gd` 冷却文本始终调用 `actor_name`，独立测试不再显示 `doc_emiko`／`doc_artoria`。
- Godot 4.5.1 headless 运行 `tools/advanced_reward_cooldown_test.gd`：**92 checks，0 failures**；包含中英文实际 UI Label 检查。
- 原稿逐字归档；本发现报告。

尚未执行：V2 manifest、月度／三格／每周两例算法、类别 Gate、迁移、Quick 服务阻断，以及本稿 T01–T23 和对应实机验收。不能把本次奖励专项／姓名显示测试表述为整套 V2 已完成。

后续应同步替换：

- `advanced_referral.gd` 旧 board/refresh/通用首通计数逻辑。
- `advanced_referral_facts.gd` 及 `game_state.gd` 的 facts 验证／迁移接口。
- `advanced_referral_view.gd` 的旧 Quick 提示与病例区显示。
- `tools/advanced_surgery_test.gd` 中“只有一种已通关就只抽一例”等旧周常断言；`advanced_review_regression_test.gd` 等直接假设四台首发的 fixture 需改用明确开发入口，不绕过正式门槛。
- 高级术式当前实现说明、素材清单和存档边界说明中的旧刷新／发布规则。

伊兹米、美纱、其余普通高级术式与薰／传奇专属内容不在此次规则接入中杜撰；随机患者额外美术为 Deferred。
