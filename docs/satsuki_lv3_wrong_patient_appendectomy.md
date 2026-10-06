# 折川皐月 Lv3：《我送错了人》

实现来源：[`docs/design/HOSHIMI_SATSUKI_LV3_WRONG_PATIENT_APPENDectomy_V3_FORMATTED.md`](design/HOSHIMI_SATSUKI_LV3_WRONG_PATIENT_APPENDectomy_V3_FORMATTED.md)。

运行时事件 ID 为 `satsuki_lv3_wrong_patient_appendectomy`，脚本 ID 为 `satsuki_lv3_wrong_patient_appendectomy_main`。原稿 22 个主场景与一个尾声共导入 785 个作者 beat；同一 beat 的内部段落保留在同一数据节点，由既有对话分页器确保内容不超过对话框高度。

## Gate 与结果

事件要求折川皐月关系 Lv2、熟悉度 45、Lv2 事件及手术室轮转旗标完成，并在 Lv2 后冷却三个游戏日。完成后：

- 关系提升至 Lv3，按统一表增加 12 熟悉度；
- 写入浪漫意识、允许坂口近距离靠近、完整身份核对特质；
- 解锁普通周日约会利益与 Lv4 gate 检查旗标；
- 开放完整事件回放。

剧情事件采用原子执行规则：进入后直至离开结尾场景均不能手动存档。

## 当前素材状态

御统百合香已作为 22 岁成年 cameo 患者登记。视觉基准保留原作的深蓝紫长发、厚刘海、外翘鬓发、蓝绿色大眼和经典赛璐璐动画风格；病房、术前担架、手术台麻醉诱导、恢复室与刷手服观察者共 25 张差分已经完成，171 个百合香对白节点已接入。折川皐月的刷手服、事故后护士服表情、病房患者、术前担架、清醒手术台和术后病床素材已经完成并接入。担架、手术台与病床组遵循 `patient_dialogue_portrait_framing.md` 的紧构图准则；事件不再隐藏两位主要角色的对应状态立绘。

用户提供的百合香灌肠 CG 已组成三阶段：`s02_024` 以病号服侧卧的 SFW 准备镜头表现她看到导管后笑容僵住，`s02_035` 与 `s02_043` 再从导管送入时的羞耻忍耐切换到缓慢灌入后的明显不适。用户提供的百合香手术室错误交接 CG 已绑定 Scene 07 的 `s07_008`，以腕带、床号、病历和接收护士的核对动作表现“资料全部吻合，但没有重新建立患者身份”的核心失误。百合香麻醉面罩 CG 已绑定 Scene 08 的 `s08_003`。用户提供的弘子为皐月完成完整术前备皮 CG 已绑定 Scene 15 的 `s15_009`。该段采用星见院内流程：皐月先脱去患者服和内衣，全裸完成下腹至会阴备皮，再戴手术帽、由覆盖单从肩下盖至脚部并转上担架。

后续素材清单：

- 原稿候选 CG：Yurika Pre-op、No-glasses Satsuki、Sakaguchi Close、Awake Appendectomy。Wrong Handoff 已完成并接入。

## 验证

`tools/satsuki_lv3_event_test.gd` 覆盖 gate、785 个节点完整遍历、关键场景、关系奖励、完成旗标、存档锁和英文无中文回退。
