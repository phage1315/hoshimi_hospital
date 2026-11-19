# 御堂江美子患者美术（2026-11-17）

23/23项文件制作完成。用户确认9张基础图并授权14张差分。病房6态、术中4态已本地BiRefNet透明化；其余13张保留背景。

素材目录：`assets/characters/emiko_staff_patient_v1/doc_emiko/`。提示词见prompts.json、variants_prompts.json与correction.json；原始来源、尺寸、模式及SHA见runtime_manifest.json。普通仰卧全麻管路修正，旧候选保留previous/。

|槽位|尺寸|模式|
|---|---|---|
|ward/neutral|[1024, 1536]|RGBA|
|intraoperative/tense|[1448, 1086]|RGBA|
|operating_table/awake|[1448, 1086]|RGB|
|operating_table_lithotomy/awake|[1448, 1086]|RGB|
|splash/general_anesthesia|[1672, 941]|RGB|
|advanced/abdominal|[1672, 941]|RGB|
|advanced/chest|[1664, 960]|RGBA|
|advanced/lateral|[1672, 941]|RGB|
|advanced/prone|[1672, 941]|RGB|
|ward/smile|[1024, 1536]|RGBA|
|ward/brave|[1024, 1536]|RGBA|
|ward/worried|[1024, 1536]|RGBA|
|ward/afraid|[1024, 1536]|RGBA|
|ward/crying|[1024, 1536]|RGBA|
|intraoperative/pain|[1448, 1086]|RGBA|
|intraoperative/near_collapse|[1448, 1086]|RGBA|
|intraoperative/anesthetized|[1448, 1086]|RGBA|
|operating_table/tense|[1448, 1086]|RGB|
|operating_table/afraid|[1448, 1086]|RGB|
|operating_table/anesthetized|[1448, 1086]|RGB|
|operating_table_lithotomy/tense|[1448, 1086]|RGB|
|operating_table_lithotomy/afraid|[1448, 1086]|RGB|
|operating_table_lithotomy/anesthetized|[1448, 1086]|RGB|

## 实际验证

- 项目.venv/bin/python运行tools/portrait_matting.py共10次，全部退出0；10份JSON确认RGBA及透明顶角。逐张查看深/浅/医院底色及放大边缘QA。
- Pillow解码23/23；10张透明角检查通过；6张ward import开启mipmap。
- 本机Godot 4.5.1 headless editor import及mipmap重导入退出0；qa/emiko_texture_check.gd加载23/23纹理通过。完整日志见qa/。引擎有环境CA和editor_settings权限提示。
- 未修改profile、registry、患者对白或生产入口；未执行原生患者流程显示验收。作者额外交付槽不属于23项。

## 作者胸部图替换

用户指定附件原样复制至advanced/chest.png；SHA与附件一致，原SFW图保留于本候选目录advanced/chest.png。23项均解码及SHA复核通过；仅替换素材文件，现已接入角色患者图片映射。

## 美术接入（2026-11-17）

profile.json已新增19个患者立绘键及5组outfits，assets_manifest.json登记23项，高级assets.json登记4体位。胸部运行图沿用作者附件，SFW参考另存assets/references/advanced_staff_patient_sfw_v1/doc_emiko/chest.png。

当前患者台词、staff_patient_profiles档案与资格由作者后续补充；美术登记不开放患者流程。早先“未修改profile”的记录为制作阶段历史。
