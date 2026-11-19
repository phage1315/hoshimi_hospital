# 城宫明日香患者基础美术（2026-11-17）

9张基础候选已制作，待用户确认后制作14张表情差分并透明化。人物参考现有白大褂，病房服装沿用Lv2浅蓝样衣设计；不覆盖原样衣资源。

|槽位|尺寸|
|---|---|
|ward/neutral|[1024, 1536]|
|intraoperative/tense|[1448, 1086]|
|operating_table/awake|[1448, 1086]|
|operating_table_lithotomy/awake|[1448, 1086]|
|splash/general_anesthesia|[1672, 941]|
|advanced/abdominal|[1672, 941]|
|advanced/chest|[1672, 941]|
|advanced/lateral|[1672, 941]|
|advanced/prone|[1672, 941]|

逐张查看输出；Pillow解码9/9，尺寸/模式/SHA与来源归档。当前均RGB，未透明化、未接入患者映射、未运行Godot或原生显示测试。

## 用户修订 v2

病房改浅绿色短袖患者袍（此前沿用的是手术袍）；仰卧身体缩短；全麻过场露肩；俯卧调整头身比/肩宽并露出背部、肩、双臂。四图已生成并解码，旧版保留previous_v1；待用户确认。截石位裸肩修改被工具moderation_blocked/other拒绝，无具体原因，仍保留原图且未完成此项。其他四图用户基本认可。未生成差分、未透明化或接入。

## 2026-11-17 第三轮修订
- 开胸图采用作者附件原样复制，原生成图保留 previous_v2/advanced/chest.png；附件仅本地处理。
- 普通仰卧俯视图按用户确认恢复 previous_v1 初版；修改版留存 previous_v2。
- 背部俯卧从头重画；截石位裸肩此次生成成功，两图待审美确认。来源与提示词见 revisions_v3.json。
- 9图解码/SHA核对通过；尚无差分、透明化与运行映射。

## 2026-11-17 差分制作结果
- 用户已批准基础图；内置image_gen成功12/14新增差分。提示词、来源和错误见variants_prompts.json。
- 截石位tense/afraid被工具moderation_blocked拒绝，input/other，无具体原因；两项缺失，无占位替代。
- assets/characters/asuka_staff_patient_v1/doc_asuka/现有21 PNG；10立绘离线BiRefNet去背景，6病房mipmap开启，作者胸图原样保留。
- qa/verify.py：21解码/校验和、10透明上角通过；10张深浅底与放大边缘目视检查完成。Godot headless editor import、mipmap重导入、texture_check.gd加载21/21通过。日志仍有环境CA/editor_settings权限提示。
- 尚未映射角色profile/患者流程，未做原生显示验收，未改对白/资格。

## 2026-11-17 作者补齐截石位两态
- 附件1→operating_table_lithotomy/tense，附件2→afraid；原样复制至候选及assets/characters/asuka_staff_patient_v1/doc_asuka，同步author_supplied归档及来源SHA。未上传或修改图片。
- 标准23槽位集合完整；23PNG解码、SHA、作者附件字节一致；Godot headless import及Texture2D加载23/23通过。日志complete_import.log/complete_textures.log；仍有环境CA/editor_settings提示。原SFW胸图留存previous_v2/advanced/chest.png，当前胸图使用此前指定作者版。
- 本批素材文件齐全；尚未接角色患者映射，未验收原生患者流程；不代表对白、资格或全部剧情专用素材齐全。

## 用户指定待办
明日香23项美术已准备、已做资源导入检查，但尚未接入患者数据和流程映射；按用户要求与杉村弘子素材留待之后一起导入。

## 2026-11-17 美术数据接入完成
- 23项已登记到角色profile、assets_manifest及高级手术四体位映射；作者胸图的SFW参考已复制到assets/references。
- Godot资源检查23/23、0缺失；与弘子共同接入的验证见docs/qa/asuka_hiroko_staff_patient_art_2026-11-17/REPORT.md。
- 未新增staff_patient_profile、对白或解锁，仍不是可预约患者；缺作者数据staff_patient_profile及h_neutral。
