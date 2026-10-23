# 杉村弘子立绘修正

按用户确认的高清基础稿统一脸颊斜线、五官和赛璐璐画风。

- 制服 7 张：neutral、smile、closed_eye_smile、serious、surprised、tired、worried。
- 刷手服与无菌手术服各 4 张：neutral、focused、warm、worried。帽内收纳头发，口罩上方露出的脸颊保留轻描线条。
- 春季与秋冬常服各 1 张。
- 术中头像 1 张，使用包裹头发的帽型。
- 共 18 张已接入 profile；一般立绘使用独立 hiroko_cheek_revision_v1 目录。HUD 依照 schema 固定路径替换，旧图保存至 research/character_references/nurse_hiroko/cheek_line_revision/intraoperative_avatar_before.png。
- 所有生成提示词及源路径保存在 research/character_references/nurse_hiroko/cheek_line_revision/batch_manifest.json。
- operating_patient/nervous 未修改：图像服务返回 moderation_blocked / sexual；保留原始文件和引用。

检查：18 张均含透明通道；各套表情画布一致；validate_data.py 803 条通过。未修改剧情文本或角色数值。

Godot 专项运行检查：弘子全部 19 个 portrait key（含保留的患者状态图）加载、透明通道和 show_staff 切换通过。全局 portrait_test.gd 在第 43 行旧表情按钮断言遇到空节点，未通过；本次未修改该通用测试或 UI。
