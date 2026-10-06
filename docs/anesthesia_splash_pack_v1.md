# 全身麻醉 Splash CG 包 v1

2026-09-24 使用内置 imagegen 为现有四名成年患者生成全身麻醉诱导事件插画：音羽響子、二ノ宮紗智子、高卷杏和奥寺美纪各一张。

资源路径为 `assets/events/anesthesia_v1/<patient_id>/general.png`。患者的 `visuals.portraits` 通过 `splash/general_anesthesia` 键引用对应图片。

画面采用统一的16:9俯视头肩构图：患者闭眼平躺，透明麻醉面罩覆盖口鼻并连接呼吸管，肩膀与锁骨可见，胸部以下由不透明无菌单完整遮盖。图片不包含手术切口、血液、针具、文字或界面元素。

玩家在全麻诱导阶段选择回应后，系统先进入“开始手术”页面，再在页面上方显示居中的 splash 插画。背景保留并暗化，玩家点击“确认监护，开始手术”后关闭插画，继续索要手术刀。

柳原理惠另外配置 `splash/general_anesthesia_pre_induction`。玩家选择全身麻醉后，系统先显示她仍睁眼、面罩刚覆上口鼻的“诱导开始”CG；关闭后进入安抚回应，再显示原有闭眼的“诱导完成”CG。其他患者没有该键时直接进入原有安抚流程。

患者可以另外配置 `splash/epidural_anesthesia`。配置后，玩家选择硬膜外麻醉便会显示对应的患者专属 CG，关闭后继续体位摆放；没有该键的患者直接继续原流程。局部麻醉和未麻醉分支不触发麻醉 splash。当前二ノ宮紗智子使用 `assets/events/anesthesia_v1/patient_emi/epidural.png`。
