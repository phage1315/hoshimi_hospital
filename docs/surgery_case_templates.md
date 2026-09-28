# 术式病例模板

`data/cases/surgery_case_templates.json` 为25种术式各准备一条问诊模板。新游戏会为每名普通患者随机抽取不同模板，将 `history`、`symptoms`、`examination_findings`、`tests`、`diagnosis` 和目标术式装入通用门诊及术前流程。姓名、年龄、性格与立绘属于患者身份，本次疾病属于就诊记录。

抽取结果保存在存档的 `patient_cases` 字段中，因此读档不会改变当前患者的症状、诊断或目标术式。当前音羽響子、二ノ宮紗智子、高卷杏和奥寺美纪四名患者在首次队列中不会抽到相同模板；全部人选处理完毕后，角色可以再次出现，但不会与最近两名重复，并会改抽一个不同于自己上次的病例模板。

每条模板包含1–5项症状、患者口述、查体结果、1–4项鉴别诊断和至少一项检查。检查结果使用适合 VN 阅读的短句，不代表现实诊疗建议。乳腺与心脏条目的检查结构参考美国国家癌症研究所和美国国立心肺血液研究所的公开资料；急腹症条目参考 Merck Manual 的阑尾炎资料。

病例数据刻意区分“患者说的话”和“病历里的医学语言”。`presenting_complaint` 与 `history` 必须写成患者能够直接说出口的第一人称日常用语；`symptoms`、`examination_findings`、`tests` 与 `diagnosis` 则保留专业词汇，供按钮标签、检查结果和病历记录使用。患者资料中的 `voice_style` 会在运行时加入轻微的措辞差异：音羽響子直率、二ノ宮紗智子含蓄、高卷杏爽朗、奥寺美纪温和。语气修饰只改变说法，不改变病例线索。

术式流程中的 `decision` 节点不会因为一次错误选择而自动完成。错误答案先触发助手纠正；玩家确认纠正内容后返回同一个步骤重新选择，步骤编号保持不变。只有正确答案才会推进到患者回应或下一项操作。错误和随后重选都会写入 `procedure_step_history`，便于未来接入事故、突发情况或教学统计。

大开腹探查模板另外包含一个 8% 的游戏内罕见变体：只有在重复问诊、复查、客观检查和知情同意确认后才揭示症状资料不一致。患者惊恐时有三条路线：终止并重新评估、充分解释后取得知情同意、用最坏预期迫使患者屈从。第三条路线可以继续手术，但记录为 `coerced`，同时降低信任、尊严和医生善恶值，并留下护士制止、医生质疑及术后伦理冲突的事件钩子。这个概率是游戏内容参数，不代表现实中的患病率或“装病”判断依据。罕见变体的逐次抽取尚未接入运行时；接入后其 ID 也应随病例保存，避免读档或刷新时重复抽取。

参考资料：

- [NCI：乳腺癌症状](https://www.cancer.gov/types/breast/symptoms)
- [NCI：乳腺癌诊断](https://www.cancer.gov/types/breast/diagnosis)
- [NHLBI：冠状动脉旁路移植术](https://www.nhlbi.nih.gov/health/coronary-artery-bypass-grafting)
- [Merck Manual：阑尾炎](https://www.merckmanuals.com/professional/gastrointestinal-disorders/acute-abdomen-and-surgical-gastroenterology/appendicitis)
