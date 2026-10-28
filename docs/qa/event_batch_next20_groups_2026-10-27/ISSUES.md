# 本批问题单

版本：2026-10-27，main/f95636a 加既有工作区。以下保留发现时的复现记录；两项 P1 已经后续授权修复，P2 未修改。

## P1-01 石神初识文字被裁切（已修复复验）

修复后中英文正文/回想通过，见 [修复报告](../p1_fixes_and_40_screens_2026-10-27/REPORT.md)。以下为修复前证据。

- 事件 `intro_ishigami_nurse_manager`：`ishi0_011` 中文正文、英文正文/回想；`ishi0_064` 英文正文/回想。
- 预期：每页完整可读，过长文字分页后才能进入下一节点。
- 实际：正文内容高度128，容器98且无滚动；英文回想内容高度210，容器180。末行不完整，继续按钮仍可直接推进。屏幕截图已人工检查，不是CG遮挡问题。
- 复现：启动事件，到指定节点；中英文分别播放。定位截图脚本仅用于复现显示，不作为正式路线证明；全流程日志也有相同错误。
- 证据：[英文正文](variant_en_intro_ishigami_nurse_manager_repro_ishi0_011_main_p0.png)、[英文回想](variant_en_intro_ishigami_nurse_manager_repro_ishi0_011_replay_p0.png)、[第二处英文正文](variant_en_intro_ishigami_nurse_manager_repro_ishi0_064_main_p0.png)、[日志](reproduction_final.log)。
- 最小修复建议：让分页计算纳入显式换行、空行和实际字体排版高度，并按正文/回想各自容器验证；保留文字、标点和说话人，不通过删句或压缩原稿修复。

## P1-02 遥凑初识缺少10台手术门槛（已修复复验）

修复后中英文 0/9/10 台真实周日 GUI 入口通过，见 [修复报告](../p1_fixes_and_40_screens_2026-10-27/REPORT.md)。以下为修复前证据。

- 事件 `minato_intro_sunday_cholecystectomy`，真实周日“去医院看看”入口。
- 独立依据：`docs/design/HOSHIMI_HARUKA_MINATO_CHARACTER_BIBLE_UPDATED.md` 第8节，要求 `completed_surgeries_total >= 10` 后armed，再等周日。
- 实际：0台、9台、10台三组隔离状态，在第6日周日09:00点击医院按钮均触发；中英文一致。生产定义只要求周日，未找到执行10台门槛的游戏逻辑。未找到取消该门槛的后续修订。
- 证据：[六组结果](minato_gate_results.json)、[中文0台](zh_CN_minato_intro_sunday_cholecystectomy_gate_0_surgeries.png)、[英文9台](en_minato_intro_sunday_cholecystectomy_gate_9_surgeries.png)。
- 最小修复建议：按现行原稿在统一资格判断加入完成手术数下限，保留周日及既有优先级；增加0/9/10边界与达到10台当天不抢占的回归。若另有明确取消门槛的用户修订，应以该修订重新分类。

## P2-01 正文与回想未共用街景/时间演出规则

- 例：`sayaka_lv1_first_date / v2_623`，中文、英文均复现；Lv3/Lv4的 `seasonal_street` 节点同样存在实现差异。
- 正文调用季节夜景选择器；回想直接使用节点/事件默认背景。例中正文为春夜街景，回想为普通白天/傍晚街景。回想也未呈现该节点的18:00演出时钟。
- 证据：[中文正文](variant_zh_CN_sayaka_lv1_first_date_repro_v2_623_main_p0.png)、[中文回想](variant_zh_CN_sayaka_lv1_first_date_repro_v2_623_replay_p0.png)、[观测](reproduction_pages.jsonl)。
- 最小修复建议：回想复用纯显示的背景/演出时钟解析；不推进世界时间，不依赖持久化内部节点状态。

## P2-02 短信及普通回想版式与正文不同

- 例：`sayaka_lv1_first_date / v2_259` 正文为短信发件人卡片，回想为普通角色对白。部分普通事件回想保留旧的无底板正文布局，与正文底部对白框不同。姓名归属本身未因此变成另一人。
- 证据：[中文短信](variant_zh_CN_sayaka_lv1_first_date_repro_v2_259_main_p0.png)、[中文回想](variant_zh_CN_sayaka_lv1_first_date_repro_v2_259_replay_p0.png)，英文同名 `variant_en_...` 截图。
- 最小修复建议：在不改变剧情和输入推进的前提下，回想复用对应presentation的显示出口。若不同回想版式属于明确设计，应记录例外，不把本次不一致隐去。
- Lv4专用互动的正文已覆盖温柔/激烈路径及返回；回想不启动该互动，而直接继续VN。是否需要在回想重现互动及其专用对白，仍需设计口径，不能记为完整演出一致。

## P2-03 小夜香Lv5英文未同步用户中文修订

- 用户本轮已确认 `a03_0072`、`a03_h_0001_ins01`、`a03_h_0001_ins06`、`a04_0016` 为本人修订，**中文不构成缺陷**。见 [确认记录](USER_REVISION_CONFIRMATION.md)。
- 英文仍使用旧稿：`a03_0072` 是 “special date” 而非中文现行手术含义；`a03_h_0001_ins06` 未包含新增语义；`a04_0016` 仍包含中文已删除的看手术帽动作。`a03_h_0001_ins01` 的旧译部位表述也应一起核对。
- 证据：`data/localization/en.json` 中 `collections.special_event_steps.sayaka_lv5_part_a_main.nodes.<节点>.text`；`pages.jsonl` 有实际英文正文/回想加载记录。
- 最小修复建议：只同步四个指定节点的英文，保留用户确认的中文，随后重跑英文正文和回想。静态本地化测试只能证明有译文，不能证明译文已跟随修订。

## 测试脚本问题与未归因记录（不算上述游戏缺陷）

- 通用脚本误将Lv4进入专用互动、Lv5A合法拒绝判为停滞；后续专用GUI脚本覆盖并通过。
- 专用互动结束淡入层仍在时过早点击，影响后续连续测试。加入等待后，Lv4三分支×两语言×正文/回想12路线无错误；受影响结算18路线重测完成。
- 英文按钮经排版后不能依赖完整字符串匹配；改用实际控件位置，画廊58个可用语言组合和下一日返回补测成功。
- 初始画廊脚本访问禁用回调画廊，产生模态提示遮挡后续按钮；最终脚本按生产可用性区分，保留原日志。
- `tools/sayaka_callback_event_test.gd` 调用不存在的 `finish()` 导致解析失败。本轮仅将其改为SceneTree `quit()`并复验：21检查0失败。这是本轮唯一既有文件的测试代码修正。
- 小夜香旧V2/Lv2/Lv3测试仍引用旧存档字段，出现脚本错误；不能因进程退出0就宣布通过，未放宽v37边界适配旧测试。
- 遥凑旧测试只走一个分支，却要求另两条互斥分支也出现；本轮GUI已覆盖三分支。双叶旧测试固定26岁而现行档案25岁，属于过时断言，人物资料以项目现行为准。
- 皐月Lv2旧测试把邀请接受率断言为固定35%，现行配置还有熟悉度加成；没有据此修改规则。
- 惠中文首轮 `meg0_029` 出现一次输入未推进，后续完整中文/英文GUI结算路线未重现。保留首次截图和日志；不武断归因于游戏或硬件。
