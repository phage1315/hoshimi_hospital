# 杉村弘子患者美术

- 现行身份参考：hiroko_cheek_revision_v1/nurse_hiroko/uniform/neutral.png；项目年龄22。
- 已生成9基础候选：ward/neutral、intraoperative/tense、operating_table/awake、operating_table_lithotomy/awake、splash/general_anesthesia、advanced/abdominal/chest/lateral/prone。
- 9PNG逐张查看、解码与SHA归档完成。提示词prompts.json，来源sources.json，文件manifest.json。
- 待用户确认基础图，再做14差分与10立绘本地透明化。当前并非23项完成。
- 用户要求之后与明日香一起接入；本轮仅候选，未复制运行目录/映射患者数据，无Godot或原生显示验收。
- 明日香23项文件已齐，已资源加载验证，但患者profile/高级映射尚未导入，不能误记已完成流程接入。

## 俯视角修订
截石位按用户反馈改为高位俯视、平躺台面，旧图保留previous_v1；angle_revision.json记录生成。advanced/chest被用户询问用途，已解释当前图缺乏胸部手术识别度，未擅自替换，待进一步方向。

## 短台与胸部新版
截石位去掉臀部以下延长台面，铺巾由短台边缘下垂；胸部新增纵向胸骨区域开窗铺巾版。两图待确认，旧图previous_table_chest留存，提示词/来源见table_chest_revision.json；解码和SHA更新通过。仍未运行接入。

## 差分与待导入成品
- 基础图获用户确认。内置image_gen成功11张差分（病房5、术中3、仰卧3）；截石位tense/afraid/anesthetized三项均moderation_blocked(input/other)，保留缺口，不用基础图冒充差分。详见variants_prompts.json。
- prepared/nurse_hiroko中20PNG：9基础+11差分，10病房/术中立绘本地BiRefNet透明化，台面/CG背景保留。
- 实际验证：qa/verify.py精确20项集合、PNG解码/尺寸/SHA、10立绘透明上角通过；10张深浅底及放大边缘检查通过。prepared_manifest.json归档。
- 用户要求回头与明日香一起导入，本次未复制assets、未配置mipmap或运行映射、未做Godot导入/原生显示。导入时病房6张须开启mipmap。

## 作者胸部图指定（2026-11-17）
- 附件原样归档author_supplied/chest.png并替换prepared/nurse_hiroko/advanced/chest.png；原SFW版保留sfw_reference/advanced/chest.png，生成原始候选不变。来源、尺寸及SHA见author_supplied/manifest.json。
- 字节一致性、PNG解码与qa/verify.py通过；现有20/23体位与表情槽位，仍缺截石位紧张、害怕、麻醉3项。本次胸图替换不增加槽位。额外NSFW专属素材不计入此23项，未作齐全声明。
- 仅待导入成品更新，未接入运行数据；仍按用户要求与明日香后续统一导入，无Godot/原生验收。

## 截石位差分重试（2026-11-17）
按用户要求，内置image_gen分别重试tense/afraid/anesthetized，三项均返回moderation_blocked（input/other），没有生成文件；完整提示词与错误保存在lithotomy_retry.json。原素材未改，仍20/23，待统一导入。

## 截石位麻醉连续五次重试（2026-11-17）
按用户明确要求，针对anesthetized以同一已确认SFW底图连续实际提交五次等价的临床麻醉差分请求。五次均返回moderation_blocked（input/other），没有生成文件；完整提示词、请求ID和原始错误保存在lithotomy_anesthetized_retry_5.json。原素材未改，仍20/23。

## 作者补齐截石位三差分（2026-11-17）
- 用户指定附件1为麻醉、附件2为紧张、附件3为惊恐；原样归档并填入operating_table_lithotomy/{anesthetized,tense,afraid}.png。
- 三张均为1472×1088 RGBA，归档与prepared字节一致；来源与SHA见author_supplied/lithotomy_manifest.json。
- 标准患者美术现已补齐23/23。仍按用户此前安排留在待导入区，未接运行映射或Godot流程。

## 2026-11-17 美术数据接入完成
- prepared中的23项已原样复制到assets/characters/hiroko_staff_patient_v1/nurse_hiroko，并登记角色profile、assets_manifest及高级手术四体位映射。
- 6张病房立绘启用mipmap；作者胸图的SFW参考已复制到assets/references。Godot资源检查23/23、0缺失。
- 未新增staff_patient_profile、对白或解锁，仍不是可预约患者；缺作者数据staff_patient_profile及h_neutral。
