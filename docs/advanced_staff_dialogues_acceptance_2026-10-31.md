# 高级手术医护补稿与本庄巡回立绘验收

日期：2026-10-31。

## 接入范围

- 原稿：`source/advanced_staff_dialogues_v1/HOSHIMI_ADVANCED_SURGERY_STAFF_TIMEOUT_TERMINAL_DIALOGUES_CN_V1.md`。
- `data/advanced_surgery/dialogue/staff_confirmations.json` 登记 13 条作者原文：11 条岗位 Time-out 确认，以及樱花成功／失败终末对白；同步忠实英文。
- 仅适用于 Whipple、盆壁肿瘤切除、袖式肺叶切除、Ebstein Cone 四台高级术式。Day 1 分配旁白不替换为 Time-out 台词，普通手术不使用此补稿表。
- 按角色、岗位、触发点解析；已有术式专属岗位确认保留优先级。

## 本庄萌惠巡回立绘

- 原因：没有登记正常巡回刷手服身体立绘；原回退链跳过已有无菌服身体立绘，可能选到头部头像。
- 已修复回退顺序：优先可用手术室身体立绘，最后才使用头像。
- 新增 `assets/characters/moe_circulating_v1/neutral.png`，1024×1536 RGBA，登记为 `nurse_moe` 的 `scrubs/neutral`。
- 按用户修订，采用贴合短发的小型系带帽；保留绿色刘海、眼镜、口罩与短袖刷手服。器械岗位保留原无菌服，旧事件专用近景资源保留。
- 生成参考、完整提示词及校验和记录在 `research/imports/nurse_moe_circulating_2026-10-31.json`。

## 验证

- `python3 tools/advanced_staff_dialogue_audit.py`：13/13 中文原文、绑定和顺序一致，英文完整，四术式范围正确。
- `python3 tools/narrative_localization_test.py`：29,678 项，0 失败。
- `python3 tools/localization_audit.py`：45,650 翻译条目；UI 754/754；UI 硬编码中文候选 0。
- Godot 4.5.1 原生窗口运行 `tools/advanced_review_regression_test.gd -- --native`：6,554 项，0 失败。
- 覆盖中英 Time-out、各候选岗位的对白和资源、樱花成功／失败对白、正文非空、Day 1 输入推进、Day 3 制服、返场返回病例板及会话隔离。
- 实际 Whipple 团队以本庄担当主巡回，在 Time-out 核对新立绘及作者对白；截图 `/tmp/advanced_three_zh_CN_moe_circulating.png`、`/tmp/advanced_three_en_moe_circulating.png`。
- 增加本庄巡回资源路径断言及缺少刷手服时优先无菌服身体立绘的回归，避免重新落到头像。

## 未通过的全库检查

`python3 tools/validate_data.py` 仍有本次范围外错误，包括 special event priority 超 schema 上限、病房准备 CG 的 image_fit 字段未获 schema 接受、其他事件重复选项 ID 等。完整输出在 `/tmp/advanced-staff-validate.log`。该全库检查不能记为通过；没有为本次素材导入扩大修改范围。本庄相关检查未报错。

未提交、推送或更改玩家存档。
