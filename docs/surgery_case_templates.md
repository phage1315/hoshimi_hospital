# 术式病例模板

`data/cases/surgery_case_templates.json` 为25种术式各准备一条问诊模板。新游戏会为每名普通患者随机抽取不同模板，将 `history`、`symptoms`、`examination_findings`、`tests`、`diagnosis` 和目标术式装入通用门诊及术前流程。姓名、年龄、性格与立绘属于患者身份，本次疾病属于就诊记录。

抽取结果保存在存档的 `patient_cases` 字段中，因此读档不会改变当前患者的症状、诊断或目标术式。当前音羽響子、二ノ宮紗智子、高卷杏和奥寺美纪四名患者在首次队列中不会抽到相同模板；全部人选处理完毕后，角色可以再次出现，但不会与最近两名重复，并会改抽一个不同于自己上次的病例模板。

每条模板包含1–5项症状、患者口述、查体结果、1–4项鉴别诊断和至少一项检查。检查结果使用适合 VN 阅读的短句，不代表现实诊疗建议。乳腺与心脏条目的检查结构参考美国国家癌症研究所和美国国立心肺血液研究所的公开资料；急腹症条目参考 Merck Manual 的阑尾炎资料。

病例数据刻意区分“患者说的话”和“病历里的医学语言”。`presenting_complaint` 与 `history` 必须写成患者能够直接说出口的第一人称日常用语；`symptoms`、`examination_findings`、`tests` 与 `diagnosis` 则保留专业词汇，供按钮标签、检查结果和病历记录使用。患者资料中的 `voice_style` 会在运行时加入轻微的措辞差异：音羽響子直率、二ノ宮紗智子含蓄、高卷杏爽朗、奥寺美纪温和。语气修饰只改变说法，不改变病例线索。

术式流程中的 `decision` 节点不会因为一次错误选择而自动完成。错误答案先触发助手纠正；玩家确认纠正内容后返回同一个步骤重新选择，步骤编号保持不变。只有正确答案才会推进到患者回应或下一项操作。错误和随后重选都会写入 `procedure_step_history`，便于未来接入事故、突发情况或教学统计。

## 大开腹探查罕见变体：2026-10-27 当前实现

装病／外部动机变体已接入。普通患者完成门诊、收住院后，首次进入术前流程按原配置8%抽取一次；复核以原稿旁白演出，不新增重复检查按钮。随后逐段显示患者抗拒、复核旁白、两个选择、主角回应和结果，最后返回原有病房准备流程。

本次用户只开放“解释必要性并确认后继续”（恐惧+5、尊严0、气场0）及“用最坏预期迫使她继续”（恐惧+35、尊严−15、气场+2）。旧trust字段不应用。原始“终止手术并重新评估”正文保留，但不在`runtime_options`中，不开放离院或中止出口；三个医护后续钩子仍为待制作定义，不代表已实装后续事件。

该变体概率是游戏内容参数。同一运行会话重绘、再次进入或切换语言不重抽、不重结算；抽取仅发生在当前安全入口开始新术前会话时。存档遵守v37安全边界，不写变体播放节点、选项、对白或抽取进度，也不沿用旧文档建议的“把变体内部ID随病例保存”。旧`reveal_after`列表保留为设计来源，不作为新的可持久化步骤契约。详情及测试见[职业气场与病例复核实装记录](clinical_presence_2026-10-27.md)。

参考资料：

- [NCI：乳腺癌症状](https://www.cancer.gov/types/breast/symptoms)
- [NCI：乳腺癌诊断](https://www.cancer.gov/types/breast/diagnosis)
- [NHLBI：冠状动脉旁路移植术](https://www.nhlbi.nih.gov/health/coronary-artery-bypass-grafting)
- [Merck Manual：阑尾炎](https://www.merckmanuals.com/professional/gastrointestinal-disorders/acute-abdomen-and-surgical-gastroenterology/appendicitis)
