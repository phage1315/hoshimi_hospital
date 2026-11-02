# 朝仓 Lv4、医护大手术 V2.3、武见妙 Lv1/Lv2 接入状态

## 已接入

- 朝仓 Lv4 `miyuki_lv4_inspection`：105 个节点、双语、两组选项、下班后触发、统一结算 120 分钟；保留既有五次术前准备计数要求。已配置粉红护士服、私密段落头像及背景，完成后结算 Lv4 与亲密事件资格。
- 武见妙 Lv1 `ev_doc_takemi_lv1_vivisection_frog`：44 个节点，双语及选项接入。
- 武见妙 Lv2 `ev_doc_takemi_lv2_fujino_laparotomy`：112 个节点，双语及选项接入。
- 上述三个事件已加入事件测试中心；测试入口使用内存测试条件，不修改玩家存档。
- 医护高级手术 V2.3：24 人双语原稿均已预置（本轮补入其余 22 人），实际正式患者仍仅小夜香／芹香；旧尾声不再重复附加，保留 100%／50%／0% 经验递减与全程禁止存档规则。其余角色档案及素材缺口见 materials_pending.md。

## 朝仓 Free H 的实际状态

Profile、Flow、Context 及双语数据已登记，Lv4 完成后的关系资格已接通。角色页面显示“亲密事件已解锁 · 素材待补”。实际预约尚未开放，不能视为可完整游玩的 H Runner。

作者仍需提供以下 8 张素材：

- 触摸底图 `body_map.png`；当前规格提案为 1024×1536，须拿到最终图后校准热区。
- 第二阶段图 `scene_cg.png`。
- 事后图 `aftercare_cg.png`。
- 五张透明头像：`portrait_annoyed.png`、`portrait_pleased.png`、`portrait_flustered.png`、`portrait_delighted.png`、`portrait_peak.png`。

`portrait_neutral.png` 已接入。缺图期间不借用其他角色图片，不虚构热区或将资源状态标为 ready。

## 其他素材缺口

武见妙剧情中的浅上藤乃及通用女患者尚缺对应立绘，目前相关节点不显示患者立绘；正文和说话人保留。朝仓新增立绘仍可进一步做美术验收，本轮运行测试不等同于最终美术质量确认。

## 验证

- `tools/miyuki_takemi_current_events_test.gd`：无头及图形模式均为 8662 项检查、0 失败；覆盖中英文、选项组合、节点推进、完成结算、存档边界和测试入口。
- `tools/miyuki_takemi_source_audit.py`：2088 项检查、0 失败，核对归档双语审阅数据与运行数据的正文、说话人、顺序。
- `tools/advanced_staff_patient_source_audit.py`：1069 项检查、0 失败；1004 条双语文本。
- `tools/narrative_localization_test.py`：30631 项检查、0 失败。
- `tools/localization_audit.py`：47271 条翻译，UI 硬编码中文候选 0。
- `git diff --check` 通过。

未覆盖所有角色、所有术式的逐台人工回归；没有提交、推送或改写玩家存档。
