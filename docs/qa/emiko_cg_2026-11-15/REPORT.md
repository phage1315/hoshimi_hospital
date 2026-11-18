# 江美子 Lv1–3 CG 接入（2026-11-15）

## 范围

7 张图片、105 个视觉节点。修改 `data/staff/doc_emiko/events.json` 与 `lv3_events.json` 的 CG 展示字段及三个事件 gallery.path；准确映射见 `research/imports/emiko_lv1_3_cg_mapping.json`。

- Lv1 em1_193–204：摘口罩后的眼神与余韵，离室前恢复原演出。
- Lv2 em2_238–246：签名递记录夹与下一台邀请，在插回钢笔／走开前结束 CG。
- Lv3 em3_s1_35–50：寿司店平静交谈；em3_s1_51–52 与 S/O/G 历史适配、Choice 1 回应节点：微妙在意差分。
- Lv3 em3_s2_12–18：床边安抚，使用修正后的上下系带与空口袋图片；em3_s2_19 后恢复患者及医生立绘，保留患者三态麻醉演出。
- Lv3 em3_s4_18–19：离室关门。
- Lv3 em3_s6_10–20：推来私人手札及同行讨论。

每组新图首次出现完整展示两秒，再恢复原对白；contain 保留完整画面。画廊封面为 Lv1 摘口罩、Lv2 记录夹、Lv3 手札，复用已有自动收集 CG 的多图翻页 UI。保留所有原画廊标题及说明，不改解锁、数值与存档。

## 实际验证

- 与 `/private/tmp/emiko_cg_before/` 两份修改前 JSON 做结构比较，排除 CG 展示／hide_portrait 与图片路径字段后完全相同；未改正文、说话人、选项、次序和业务逻辑。
- `.venv/bin/python tools/emiko_lv1_source_audit.py`：31274 checks / 0 failures。
- `.venv/bin/python tools/emiko_lv2_source_audit.py`：37641 checks / 0 failures。
- `.venv/bin/python tools/emiko_lv3_source_audit.py`：24231 checks / 0 failures。
- `python3 tools/narrative_localization_test.py`：51427 checks / 0 failures。
- `python3 tools/localization_audit.py`：59791/59791 叙事覆盖、803/803 UI keys；全局退出 1，既有 voice_director.gd 五行中文硬编码。
- `.venv/bin/python tools/validate_data.py`：全局既有其他内容错误仍在，输出无 emiko 错误。未改无关内容。
- Godot headless editor import 完成图片导入；自包含安装目录 editor_settings 写入受沙箱限制，后续以原生实际加载检查。
- 原生 `tools/emiko_cg_preview.gd`：**113 checks / 0 failures，退出 0**；隔离临时配置与内存事件，双语各七个渲染检查点，检查实际纹理路径、CG 无重复立绘、画廊收集及 GUI 注入下一张／循环翻页；截图保存在本目录。使用原生窗口，不是完整正式入口通关，也不是人工点击。

## 边界

未改生成原图，床边安抚使用用户认可的修订版；未改导入器，不重跑剧本导入。未来重导原稿需保留或重新应用映射的 CG 字段。没有测试导出包或重新执行整个剧情业务流程；未 commit/push。
