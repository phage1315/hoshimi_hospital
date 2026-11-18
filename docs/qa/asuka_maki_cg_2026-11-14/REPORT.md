# 明日香／麻纪补充 CG 接入 — 2026-11-14

## 接线

以 `research/imports/asuka_maki_supplement_cg_mapping.json` 为准确映射：明日香 Lv1 术后称呼、Lv2 去镜版后腰系带与弘子样衣检查、Lv3 咖啡馆甜点与情绪特写、麻纪入职复盘笔记与黄昏排班表，共 7 张。

修改 `data/staff/doc_asuka/{events,lv2_events,lv3_events}.json`、`data/staff/doc_maki/lv0_events.json` 的 CG 字段及原有画廊空路径。Lv3 原穿衣镜 CG 与封面保留。旧系带图留档，正式引用使用 `asuka_lv2_gown_ties_v2.png`。

节点使用 contain，不裁切；每组首次出现先展示完整图 2 秒，再显示原对白。正常对白框会遮住下部道具，画廊可以完整查看。`godot/ui/app.gd` 从事件节点收集不重复 CG，保留原封面优先，增加上一张／下一张循环翻页；仍以事件完成条件解锁，不新增持久化状态。保留既有画廊标题、说明及 cg_id。

## 已执行验证

- 对本轮修改前 `/private/tmp/asuka_maki_cg_before/` 四份 JSON 作结构比较：除 CG 展示字段和画廊路径／完成展示设置外完全一致，文本、说话人、选项、顺序、业务字段不变。
- `.venv/bin/python tools/asuka_lv1_source_audit.py`：502 checks / 0 failures。
- `.venv/bin/python tools/asuka_lv2_source_audit.py`：3292 checks / 0 failures。
- `.venv/bin/python tools/asuka_lv3_source_audit.py`：3603 checks / 0 failures。
- `.venv/bin/python tools/maki_lv0_source_audit.py`：4221 checks / 0 failures。
- `python3 tools/narrative_localization_test.py`：49008 checks / 0 failures。
- `python3 tools/localization_audit.py`：正文覆盖 57371/57371，UI keys 803/803；**全局命令未通过**，既有 `voice_director.gd` 5 行中文硬编码。
- `.venv/bin/python tools/validate_data.py`：**全局未通过**，现有背景 label/name、事件 priority、ward CG image_fit、芹香隐藏立绘字段及武见时间窗等问题；输出无 Asuka/Maki 条目。本轮没有修改这些内容。
- Godot 4.5.1 headless editor import 完成资源导入；自包含安装目录的 editor_settings 写入受沙箱限制，报错已记录，随后原生实际加载验证。
- 原生运行 `--path . --log-file /private/tmp/supplement-cg-native-final.log --script res://tools/asuka_maki_cg_preview.gd`：**89 checks / 0 failures**。双语 7 个渲染检查点、图片实际 Texture2D 路径、无重叠角色立绘、画廊实际 GUI 注入点击及循环翻页。保存本目录双语截图；`*_reveal.png` 为完整 CG 展示，其他 PNG 为对白出现后。使用独立 `/private/tmp` 配置路径和内存事件状态，未使用玩家存档。
- `git diff --check` 通过。

## 验收边界

原生测试为指定节点渲染与画廊 GUI 自动输入检查，**不是从正式入口完整通关，也不是人工点击**；本轮未重跑事件业务全流程回归。既有其他 AI 未提交工作保留，未 commit/push。原文导入器未重跑；未来重导事件原稿时须保留／重新应用本映射的美术字段。
