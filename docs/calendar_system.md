# 固定公历系统

游戏年度固定为 **2025-04-01 至 2026-03-31**，共 365 个可玩日。`DAY 1` 是 2025-04-01（周二），`DAY 365` 是 2026-03-31（周二）；2026-04-01 留作合同到期与尾声日期。

日历由 `godot/systems/fixed_calendar.gd` 统一计算。界面仍显示 `DAY N` 便于核对进度，同时显示公历日期、星期和时间。日期完全由游戏日推导，不单独保存。

## 医院工作日

- 周一至周五：普通工作日，门诊、择期手术、病房与自由行动正常开放。
- 周六：有限工作日。当前原型保留主要玩法入口，后续可按科室配置人员与项目。
- 周日、日本法定节假日、12 月 29 日至 1 月 3 日：普通门诊和新的择期手术准备休止；病房、急诊、值班与允许在休诊日发生的特殊活动继续运行。
- 已经开始的门诊病例仍可打开，以免跨日后卡住流程。

## 固定日期事件

特殊活动可继续使用游戏日：

```json
"timing": {"trigger_day": 268, "priority": 100, "final_week_allowed": false}
```

也可直接写固定日期，两者二选一：

```json
"timing": {"trigger_date": "2025-12-24", "priority": 100, "final_week_allowed": false}
```

`unlock_requirements` 和特殊活动选项支持：

- `calendar_date`：指定单日，例如 `{"type":"calendar_date","date":"2026-02-14"}`
- `calendar_range`：闭区间，例如圣诞周
- `weekday`：`mon` 至 `sun` 的任意组合
- `day_type`：`weekday`、`saturday`、`sunday`、`public_holiday`、`hospital_holiday`

固定日期仍受特殊活动优先级、连续天数和最终周规则约束。普通活动不能占用第 359–365 日；明确标记 `final_week_allowed` 的结局活动除外。
