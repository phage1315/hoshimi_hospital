
## 差分与待导入成品
- 基础图获用户确认。内置image_gen成功11张差分（病房5、术中3、仰卧3）；截石位tense/afraid/anesthetized三项均moderation_blocked(input/other)，保留缺口，不用基础图冒充差分。详见variants_prompts.json。
- prepared/nurse_hiroko中20PNG：9基础+11差分，10病房/术中立绘本地BiRefNet透明化，台面/CG背景保留。
- 实际验证：qa/verify.py精确20项集合、PNG解码/尺寸/SHA、10立绘透明上角通过；10张深浅底及放大边缘检查通过。prepared_manifest.json归档。
- 用户要求回头与明日香一起导入，本次未复制assets、未配置mipmap或运行映射、未做Godot导入/原生显示。导入时病房6张须开启mipmap。

## 作者胸部图指定（2026-11-17）
- 附件原样归档author_supplied/chest.png并替换prepared/nurse_hiroko/advanced/chest.png；原SFW版保留sfw_reference/advanced/chest.png，生成原始候选不变。来源、尺寸及SHA见author_supplied/manifest.json。
- 字节一致性、PNG解码与qa/verify.py通过；现有20/23体位与表情槽位，仍缺截石位紧张、害怕、麻醉3项。本次胸图替换不增加槽位。额外NSFW专属素材不计入此23项，未作齐全声明。
- 仅待导入成品更新，未接入运行数据；仍按用户要求与明日香后续统一导入，无Godot/原生验收。

## 作者补齐截石位三差分（2026-11-17）
- 附件映射：1=anesthetized、2=tense、3=afraid；均原样归档并复制到prepared。
- 三张均为1472×1088 RGBA，附件归档与prepared逐字节一致，PNG解码及SHA登记通过。
- 标准矩阵由20/23更新为23/23；本报告只证明待导入素材齐全，不代表运行映射或原生流程已完成。
