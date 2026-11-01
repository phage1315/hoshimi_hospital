# v37安全边界存档

`version: 37`、`content_version: 1`、`save_format: boundary_facts_v1`。

## 文件内容

`godot/systems/boundary_save.gd` 使用字段白名单，不调用会话快照接口。

- `elapsed_minutes`：权威的累计已结算分钟。旧有加班／故事推进／诊疗归档数值保留；恢复时派生内存账本差额，之后的新行动继续增时。
- `clinical_visits`：本次住院、病历、诊断、失误数、已支付分钟和属性账目。
- `surgery_outcomes`：已完成／中止的实际术式、团队、分钟和属性账目。尚未完成的旧术前仅保留已支付成本，不延续选人／麻醉／技术步骤。
- `character_completions`：事件ID、完成日期、actor_id、实际耗时。`micro_completions`：事件ID、触发日期、actor_id。没有node／choice／page。
- `relationship_state`：相识、级别、路线、好感／熟悉度、flags、事件／晋级历史、已解锁收益；不包含当前内容中的rank_slots等定义。
- 手术次数／质量结果／经验／技能／奖励账目、全局flags、特殊事件完成次数／日期、持久解锁、病例分配、队列、预约等业务事实。手术质量历史剔除随机选择日志、种子及病例变体等内部诊断信息。
- `_slot_metadata`：槽位展示元数据。新档读档以 `elapsed_minutes` 为准，不依赖元数据推算时间。

事件和诊疗流程进行中，`snapshot()` 返回空字典，SaveStore拒绝写入。UI仅在医院导览与周日安排提供保存。已完成但未退出结果页也要先结束演出。内存语言切换另用 `runtime_memory_only_v1`，不能导入成玩家存档。

## 高级转诊事实（2026-10-30）

可选全局字段`advanced_referral_facts`由`advanced_referral_facts.gd`逐层白名单验证。内容限定为术式首通／永久失败、助手可再出勤日期、每周病例板、已接受病例的稳定ID／患者ID／七人团队／三个预约日期／已支付接诊分钟、已结算手术结果，以及完成病例的日期／耗时／已发奖励。旧v37缺此字段按空事实恢复。

高级病例板、手术与复盘页不允许保存。返回导览／周日边界才可写预约或结果；绝不写HP、节点／步骤、判定随机数、临时变体、动作记录、助手使用次数、待援救或危机状态。运行退出后从前一安全存档进入，不能恢复手术中途。临时复盘数值不因读档而重算或伪造。

本轮测试覆盖已预约／已完成手术／已复盘的读写、时间数值稳定、奖励不重复、拒绝额外内部字段。详见[高级手术记录](advanced_surgery_prototype_2026-10-30.md)。

## v36迁移

导入不执行旧动作，不依赖旧node／stage／choice存在。人物事件只读取明确的完成事实；未完成的演出不恢复。住院状态保留，读档后从当前安全入口进入下一流程。

旧档没有存下各次自由行动／人物事件的实际耗时，不能据新剧本补算。v36需要有效 `_slot_metadata.day` 与 `clock`（日内09:00–16:59账本时间），按项目480分钟工作日换算总时钟。旧历史单项耗时记为 `null`；未知不等于零分钟，其已消耗时间已包含在总时钟中。原time_log的起始时间保留为历史记录，不因重叠重新排序或增加／扣除时间。

以下情况不自动“修复”：可靠日期／时钟缺失、元数据处于无法确认的加班日期、持久数值或业务引用损坏，以及v35及更早仅有动作日志的格式。明确提示人工核对，原档和当前进度不变。对未记录的已结算结果不能凭空补全。

这次提供的 `/Users/ningye/Downloads/clinic_slot_1.json` 可以直接导入，无需六处手工节点／时间戳修补。原档和 `recovered_saves/2026-10-23/clinic_slot_1.json` 均未覆盖。读取本身不升级磁盘文件；下次由玩家明确保存时才写出v37。

## 回归

使用项目提供的Godot执行文件，配合 `--headless --path . --log-file /tmp/<独立日志名>`：

```text
--script tools/boundary_save_test.gd -- /Users/ningye/Downloads/clinic_slot_1.json
--script tools/save_recovery_verify.gd -- /Users/ningye/Downloads/clinic_slot_1.json recovered_saves/2026-10-23/clinic_slot_1.json /tmp/<尚不存在的回存文件>.json
--script tools/character_event_test.gd
--script tools/special_event_framework_test.gd
--script tools/narrative_save_lock_test.gd
--script tools/patient_recycle_clock_test.gd
--script tools/save_store_test.gd -- /tmp/<隔离槽位文件>.json
```

专项覆盖中英、原始问题档／已修复副本、未知节点、删改剧本及耗时、退役事件、完成事实／数值／时间稳定、真实文件再存再读、读档后转诊与继续行动、住院安全入口、非法时钟原子拒绝、禁止演出中保存及内存通道隔离。

`special_event_framework_test.gd` 原跨日中途恢复期望现按用户明确的新契约改为禁止保存；三天连续推进、奖励、画廊及完成后回读仍完整测试，没有删除跨日流程覆盖。

## 2026-10-30：医护首次真实手术完成日

新增可选业务字段 `staff_patient_first_completion_days`：角色 ID → 首次实际完成日整数。仅真实手术完成出口登记，和约定术式的 XP／训练次数分离；中止不登记，后续完成不覆盖。旧档没有此字段时为空，不推断旧日期。Callback 看过状态与实际15分钟仍由 `character_completions` 保存，无新 pending／节点／路径字段。专项测试验证删改回调节点和定义耗时后，完成日期、已结算时间和结果不变。
