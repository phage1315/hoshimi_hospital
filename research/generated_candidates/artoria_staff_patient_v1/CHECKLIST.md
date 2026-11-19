# Saber staff-as-patient 素材清单（2026-11-17）

23/23 素材已制作；基础图获用户确认，截石位获单独确认。当前仅完成美术文件，不代表患者流程已接入或开放。

运行素材目录：`assets/characters/artoria_staff_patient_v1/doc_artoria/`。

|槽位|格式|尺寸|
|---|---|---|
|`ward/neutral`|RGBA|1024×1536|
|`intraoperative/tense`|RGBA|1448×1086|
|`operating_table/awake`|RGB|1448×1086|
|`splash/general_anesthesia`|RGB|1672×941|
|`advanced/abdominal`|RGB|1672×941|
|`advanced/chest`|RGBA|1664×960|
|`advanced/lateral`|RGB|1672×941|
|`advanced/prone`|RGB|1672×941|
|`ward/smile`|RGBA|1024×1536|
|`ward/brave`|RGBA|1024×1536|
|`ward/worried`|RGBA|1024×1536|
|`ward/afraid`|RGBA|1024×1536|
|`ward/crying`|RGBA|1024×1536|
|`intraoperative/pain`|RGBA|1448×1086|
|`intraoperative/near_collapse`|RGBA|1448×1086|
|`intraoperative/anesthetized`|RGBA|1448×1086|
|`operating_table_lithotomy/awake`|RGB|1448×1086|
|`operating_table/tense`|RGB|1448×1086|
|`operating_table/afraid`|RGB|1448×1086|
|`operating_table/anesthetized`|RGB|1448×1086|
|`operating_table_lithotomy/tense`|RGB|1448×1086|
|`operating_table_lithotomy/afraid`|RGB|1448×1086|
|`operating_table_lithotomy/anesthetized`|RGB|1448×1086|

病房6态及术中4态经本地BiRefNet透明化，10份QA报告均RGBA、top_corners_transparent=true；深浅底及边缘检查完成。其余13张保留背景。全部PNG已解码及SHA校验。

胸部槽位使用用户附件原样复制，校验一致；原SFW候选保留在advanced/chest.png，不再作为运行素材。runtime_manifest.json记录最终来源、路径和SHA；variants_prompts.json记录差分提示词。

未修改患者registry、profile、业务资格或对白；未执行患者流程原生验收。ward_preparation/shy、h_neutral等作者交付项不属于此23项。

Godot 4.5.1 headless editor import及6张ward的mipmap重导入退出0；独立Texture2D加载检查23/23通过。环境出现CA及editor_settings写入权限提示，不影响上述资源加载。未进行原生显示或患者流程测试。日志和检查脚本保存在qa/。

## 已接入美术映射

19个普通患者图键已写入doc_artoria/profile.json；4高级体位已登记高级assets.json；23项资源专项0缺失。用户明确稍后自行接入患者档案和对白，本轮不改registry、不开放流程。验收报告见docs/qa/artoria_staff_patient_art_2026-11-17/README.md。
