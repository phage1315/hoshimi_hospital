# 自由预约与离院接入 V1.1

实施日期：2026-10-16。依据用户批准的 `HOSHIMI_FREE_H_SCHEDULING_V1_1_CODEX_HANDOFF.md`。

## 玩家入口

正式完成小夜香 Lv4 后，在工作日医院里找到实际在场的小夜香，打开人物页面，选择“约今晚下班后一起过夜”。地点固定为酒店，没有地点菜单。办公室的下班按钮附近显示当晚约定，并可取消。照常完成医疗工作后，手动或自动合法下班进入既有互动流程。

目前只注册 `doc_sayaka × hotel`。御堂及其他人物没有开放入口。

## 实际接口

- `godot/systems/free_h_registry.gd`：显式角色注册、唯一地点、完成事件/标记、当前实际 Profile 文件及适配器、资源和热点布局验证。`load_bundle` 创建普通上下文，清空 event overlays，不提供里程碑回调。当前适配器复用已有 `h_profile_v1_content.gd`。
- `godot/systems/game_state.gd`：`free_h_booking = {workday, actor_id}` 是可存档的普通状态；`active_free_h_departure` 是不存档的离院占用。`can_book_free_h` 核查真实在场、正式完成事件、解锁 benefit、成人与角色路线、当天工作/剧情状态及资源。等级本身不能解锁。
- `book_free_h` 以旧角色 ID 做确认后的比较替换；同角色重复选择幂等；`cancel_free_h_booking` 无费用/奖励。旧存档缺字段为空，无效/过期预约不补约。
- `current_workday` 使用待离院工作日锚点；午夜不清约。强制多日跳转后过期预约清除。
- `claim_free_h_departure` 在既有医疗锁、剧情优先级之后取得唯一离院控制权，保存可见工作日/实际时间。`can_save_progress` 全程禁止保存；存档只包含预约，不包含互动会话。
- `finish_free_h_departure` 清理预约、占用和 pending departure，并推进到预约工作日的次日 09:00。自动加班已经预留次日时，不再加一天；第二次完成调用无效。
- `godot/ui/app.gd`：`request_free_h_booking` 提供确认；`_try_free_h_departure` 是手动/自动路径共同入口，位于所有随机同行抽选之前。入口预检失效则取消并提示，再走原离院流程；实际启动后的异常也释放占用并恢复离院流程。
- `godot/ui/staff_view.gd` 与 `player_office_view.gd`：角色入口、日程提示和取消。

既有随机同行概率、选人、冷却与奖励公式未改动。有有效预约时整个同行入口被绕过，GameState 层也阻止误抽。周一回调在离院时到期则先播，取消冲突预约；白天已经独立播完的回调不阻止晚间预约。其他独占离院事件亦优先，自动加班离院的事件判断使用原工作日。

## 一次性剧情与重复会话隔离

`h_profile_run_kind` 区分 `test / milestone / free`。正式自由入口使用注册层返回的新会话和空 event ID；Lv4 仍走原事件入口及原事件完成逻辑。共用已试玩的 UI/Session，不接入旧 `adult_intimacy_session.gd`。

自由流程没有首次事件插入对白、专属事后段落、清晨或关系结算；完成通用事后两句后才结束工作日。原 Lv4 的专属覆盖、事件续播、周一回调与关系提升仍归 Lv4 事件所有。

**地点开场说明：** 指南 §7.1 规定已有地点开场时沿用。当前试玩版本原本顺序播放两句酒店开场，本次原样保留，每个会话只进入这段一次。验收表 T19 的“随机一句”没有覆盖这一已有行为；本次未改变已批准台词或其顺序。

未来角色需要明确注册唯一地点、自己的已批准资源与适配器、正式完成标记。当前适配器仍是小夜香专用，不能把她的数据路径改名当成其他人的 Profile。预约、离院和返回机制可以共用，不需要复制首次事件。

## 验证

使用本地 Godot `4.5.1.stable.official.f62fdbde1`，以 headless 引擎实际实例化场景、点击/调用 UI 控件及运行会话。未进行本轮人工窗口视觉验收。

| 检查 | 结果 |
| --- | --- |
| `tools/free_h_scheduling_test.gd` | PASS：108 项；中英文生产入口、磁盘存读档、自动/手动/午夜、冲突、资源负例、幂等、永久数值快照，以及完整原 Lv4 单分支往返 |
| `tools/h_profile_v1_ui_test.gd` | PASS：54 项；原互动 UI、开场、结束、通用事后、旧 Lv4 立绘布局 |
| `tools/h_profile_v1_system_test.gd` | PASS：61 项；原会话行为 |
| `tools/after_work_walk_test.gd` | PASS：101 项；原普通/深夜同行及医疗锁 |
| `tools/narrative_save_lock_test.gd` | PASS：6 项；原剧情禁存档 |
| `tools/character_event_test.gd` | PASS：180 项；原人物事件。修正陈旧的“总计必须为41”断言，改查已注册新事件；原退役事件检查保留 |
| `tools/sayaka_lv4_event_test.py` | PASS：主事件95句、回调12句，与批准原文核对顺序和说话人 |
| `tools/narrative_localization_test.py` | PASS：8130 项 |
| `tools/localization_audit.py` | PASS：715/715 UI 英文键；已纳入审计的剧情字段15491/15491；UI 中文候选0 |
| `tools/validate_data.py` | PASS：746 records |
| Godot `app.gd --check-only`、`git diff --check` | PASS |

旧 UI 测试有5个从动态对象返回值推断类型的编译错误，补上 Dictionary 类型后才能运行，并将其 Profile 路径改为实际使用的 `_1_3_2.json`。

Godot headless 启动会输出 macOS 系统证书读取错误（`get_system_ca_certificates`），各独立原有测试也会出现；没有影响本地测试执行。调度的“预约后解锁失效”负例会有一条预期取消警告。最初测试脚本未关闭系统提示窗造成的窗口互斥报错已通过模拟关闭提示窗消除。

**英文范围：** 新增预约、改约、取消、地点提示与标题均有英文。英文运行路径已走到日终；已有 Profile 大部分对白仍使用原先中文回退（上下文只含已有局部英文覆盖），本次未扩译这些内容。全局剧情审计不覆盖这套独立 Profile 的所有文本池，因此不能将其通过解释为完整互动对白已英文化。

### 对交接表的覆盖

| 项目 | 状态与范围 |
| --- | --- |
| T01–T05 | PASS：真实解锁、未相识/不在场/剧情占用/禁用角色、没有二次熟悉度门槛 |
| T06 | PASS（受控夹具）：用另一预约角色 ID 验证确认前保留、确认后原子替换；未虚构第二个正式可玩角色 |
| T07–T10 | PASS：幂等、取消、实际磁盘存读、旧档默认空 |
| T11–T12 | PASS：16:00正式离院、医疗锁、无随机同行及冷却/奖励变动 |
| T13 | PASS（跨午夜边界）：模拟手术耗时至00:30，原工作日履约，次日只推进一次；未单独重走23:30画面 |
| T14 | PASS：既有普通/深夜同行101项回归 |
| T15 | PASS：预约前可知冲突；预约后出现的手动/自动独占剧情；周一回调 |
| T16 | PASS：打开办公室/人物页不会提交离院；未单独人工测试所有导航手势 |
| T17–T18 | PASS：重复手动/自动请求、固定注册地点、无多地点菜单 |
| T19 | PASS（沿用已有行为）：酒店两句按顺序只播一次，见上面的规格解释 |
| T20–T21 | PASS：既有61项系统与54项UI回归；调度另验证手动结束边界 |
| T22–T26 | PASS：普通事后、永久数值不变、事后前不清约、一次日终、存档锁 |
| T27 | PASS：缺图、缺地点开场、热点布局不匹配返回错误；生产资格调用相同验证器 |
| T28 | BLOCKED／未来范围：御堂尚未注册，不开放入口；未制作其内容 |
| T29 | PASS：原Lv4完整单分支演出→原互动→专属后续→关系/次日结算；静态审计覆盖所有剧本节点 |
| T30 | PASS：相邻合法工作日再次可预约，没有新增冷却 |

## 运行命令

以下 `<Godot>` 为本地可执行文件路径；显式日志路径避免受限环境访问用户日志目录。

```sh
<Godot> --headless --log-file /tmp/hoshimi-free-h-scheduling.log --path . --script res://tools/free_h_scheduling_test.gd
<Godot> --headless --log-file /tmp/hoshimi-free-h-ui.log --path . --script res://tools/h_profile_v1_ui_test.gd
python3 tools/sayaka_lv4_event_test.py
python3 tools/narrative_localization_test.py
python3 tools/localization_audit.py
```

没有改写 Profile、Flow、结束反应、Lv4 剧本或美术资源，没有创建发布包。
