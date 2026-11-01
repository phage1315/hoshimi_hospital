# Hoshimi Hospital — 高级术式另外三台非美术内容包 V1

**作者交付日期**：2026-10-31  
**参照版本**：用户上传的 `advanced_surgery.zip`（内含当时可运行的 `procedures.json`、Whipple Day2/Day1/Day3 样板及旧三台原型）。  
**设计依据**：`advanced_surgery_content_checklist_v1.md`（已批准作者/工程交付清单）。  
**本包状态**：**内容与暂定数值齐备，图片未交付，未实机安装或试玩平衡。** **里见菜穗子的首通身份与剧情仍为候选稿，等待作者最终确认。**

## 交付内容

| ID | 保留/新增 | 阶段 | Precision | Day2中文+英文变体 | 首通 Day1/Day3 |
|---|---|---:|---:|---|---|
| `surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction` | 旧原型补全 | 12 | 6 | 完整 | 佐仓濑津美（成年AU） |
| `surgery_adv_sleeve_lobectomy` | 旧原型补全 | 11 | 5 | 完整 | **里见菜穗子（成年AU，候选待确认）** |
| `surgery_adv_ebstein_cone_reconstruction` | **独立新增** | 13 | 6 | 完整 | 秋庭里香（成年AU） |

- `procedures_additions.json`：三项完整术式对象；两台旧原型必须**按 ID 更新**，Cone 按新 ID 添加。**绝不可将数组整体覆盖原有 `procedures.json`，尤其不能删除/替换 `surgery_open_whipple`。**
- `baseline_original_locks.json`：从当前上传原型提取的 HP/Precision/危机检查点保留字段。随包的本地验收无需访问原 ZIP，实机合并仍须对照真实仓库。
- `dialogue/*.json`：每节点 2–3 条 `stage_entry` 双语技术对白；每个 P 节点 2 条 `precision_failed`。运行时只抽 1 条阶段入场，不是所有变体连读。
- `stories/*.json`：独立首通患者、双语 Day1/Day3 成功短篇；只使用 `patient` 和 `PLAYER`。
- `STORY_REVIEW_CN.md`：剧情文本便于作者审稿。
- `art_manifest.json`：未交付美术的占位**槽位/建议文件名**，其中所有真正路径为 `null`。
- `tools/validate_advanced_content.mjs`：独立本地数据审计脚本（非 Godot 集成测试）。

## 工程接入顺序与约束

1. 将当前实际仓库的 `data/advanced_surgery/procedures.json` 与本包 `procedures_additions.json` 按 `id` 比对：盆壁、肺原型更新数值和选项，Cone 新增；不修改 Whipple。若仓库版本发生变化或原型已有用户编辑，先报告差异，不应无条件覆盖。
2. 核对并接入三份 `dialogue/<procedure_id>.json`。沿用 `advanced_day2_dialogue_v1` 合法字段与角色岗位绑定；不得把姓名写进术中对白，且无全麻患者术中对白。
3. 盆壁、Cone 的首通 `stories` 可作为作者待审正文接入。**肺部菜穗子仅是推荐候选**：如未得到作者最终确认，保留故事文件作为可审阅草稿，不登记为正式首通患者；肺手术的玩法和对白不依赖该决定。
4. 所有 `patient.visuals.portraits` 目前均为 `{}`。不要把 `art_manifest` 中的建议文件名直接注册到运行时，也不要借用 Whipple/樱良的具名患者照片。拿到真实素材后，再填对应患者的 `ward/postop/team_confirmation/intraoperative/anesthetized/splash/general_anesthesia` 映射。
5. 主要术野统一需 `incision_path/path/closure_path` 三个槽位；`after_stage`、`before_stage` 分别是各术式的首末节点。真实术野图未到前不要装入 `field_windows.json`，可继续走现有安全 fallback；严禁把建议路径当作已存在。
6. 在运行模式使用原有 Advanced Session + 普通 physiology resolver：阶段 `strategic_effects`、`conditional_effects`、Strategy 选项增量应各结算一次。正式生理危机只由一个 resolver 触发，`crisis_chances` 保留给隔离 HP-only 预估/模拟；不能叠加两次抽危机。
7. 保留所有旧盆壁、肺原型的 `kind/hp_base/difficulty/specialty_tag/hp_failed_extra/crisis_checkpoints/crisis_chances`；**不得顺手重平衡 HP/Precision**。新增 Cone 参数为 P0 首版。Precision 操作失败不要另加临时生理减值。
8. 数值全部标记 `P0_TUNING_PENDING_GAMEPLAY_APPROVAL`，属于为了使失血/术野/稳定度动起来的测试数据，而非医学测量或完成平衡的参数。每台阶段 `elapsed_time` 基础总和等于各自 `duration_minutes` 回退值；Strategy 的额外 10 分钟只加一次。Day 2 生理时间不能重复扣日历 Day 2 的固定天数。
9. `advanced_referral_facts.gd` 仍只存稳定病例/排程/结果事实；独立手术 Session 的术中暂态存取按既有授权接口处理，不能把临时阶段/HP等塞入稳定事实记录。
10. 失败 Day3 继续调用既有 `dialogue/day3_failed.json` 四句 + 失败结算，不生成患者个人失败悲剧。成功只在**首次通关**触发对应 Day3；返场随机患者不带首次故事。**Quick Advanced 尚未开放。**

## 剧情医学设定及原作定位

**佐仓濑津美**：从《Narcissu》成年（22岁）形象出发。盆壁局限性复杂病灶及髂血管重建属于明确 AU 疾病，与原作诊断不能混淆；对白强调安静、克制、对“外面的路”重新产生期待。

**秋庭里香**：原作《仰望半月的夜空》早期以 17 岁少女登场；这里**明确采用成年AU，建议23岁**。原作心脏瓣膜疾病仅用作人物关联，不宣称其原作已被诊断为 Ebstein 畸形。Cone 重建剧情是 AU 的先天瓣膜异常，语气保留挑剔、强硬和难以坦率道谢的个性。**C09 先进行瓣叶对合精修，C10 再关闭右心房**，以免先关闭后又在内部调整瓣叶的顺序错误。

**里见菜穗子**：取《起风了》**成年后**的形象，候选稿。原作罹患肺结核；本包设定结核已治疗控制，但遗留局限性支气管瘢痕性狭窄和受损肺叶，因此可讨论袖式切除。由于现有原型 **T09 必须包含肺动脉重建**，另假定罕见的肺门血管周围严重纤维化及肺动脉分支累及。这是**特殊 AU 病例的文学/游戏化医学条件**，并非说结核常规需要双袖式重建，更不能把切肺说成治疗仍活动的结核。与其他两台一样保留当前 T09、HP/Precision/危机顺序。

**玩梗范围锁**：此前约定的“谢谢屏幕外的人／星见医院魔法”仅保留给首通前三名樱良、濑津美、里香。菜穗子的候选 Day3 以画画和窗外的风收尾，不复制第四次同类笑话。

医学考据供工程/作者复核：
- 肺结核后气道狭窄及胸外科干预：https://pmc.ncbi.nlm.nih.gov/articles/PMC8194432/
- 支气管和肺动脉联合重建概述：https://pmc.ncbi.nlm.nih.gov/articles/PMC4775260/
- 肺叶袖式切除适应证综述：https://pmc.ncbi.nlm.nih.gov/articles/PMC10852206/
- 成人 Ebstein Cone 重建系列：https://pmc.ncbi.nlm.nih.gov/articles/PMC7553823/
- Cone 手术步骤说明：https://pmc.ncbi.nlm.nih.gov/articles/PMC8305696/

## 不能宣布完成的项目

- 所有患者立绘、全麻图、编组确认图、三阶段术野美术均缺席。
- 肺部首通患者的授权仍待确认；若不选菜穗子，只替换肺部 `stories` 和美术，不改其 Stage/Day2 对白。
- 临床合理性与每一步玩法数值尚须内容审稿和试玩调整。当前 ZIP 没有完整 Godot 项目，**未执行游戏编组、物理指标、日期或 UI 的集成测试**。
- 当前实包只见到 Whipple、盆壁、袖式肺叶三项原型；本包新增 Cone 后为四项数据。**“高级术式池计划 21 台”不等于剩余17台已在此版本实现**。

## Codex 验收建议

- 先运行 `node tools/validate_advanced_content.mjs`（本包根目录）。
- 按清单运行当前 Godot `advanced_surgery_test.gd`、`advanced_operative_dialogue_test.gd`、`advanced_team_ui_test.gd`，增加三台术式单独试验；中文/英文均验证。
- 将双语 Story 与岗位的技术对白放进实机一次。检查 S 选项效果、不重复扣时间、P 失败 HP 扣除且不额外扣生理、单一危机入口及结算/返场 gating。
- 核对重要差异：C09/C10 顺序；原型自带的胸部 T09 血管重建未删；盆壁特有 `neural`、`pelvic`，胸部 `thoracic`、`airway` 专长标签即使当前无专科医生登记，也不得擅自发明或静默改成 `vascular`。
- 如果故事加载器要求已有图像映射或不支持无图首通，请报告实现缺口；**不要为了“跑通”自动用错误角色图顶替**。

**作者授权范围**：这份交付中英文为本轮创作版本；可按清单进行技术接入和测试。修改原文/角色选择、重大难度/时间平衡、改造普通 Surgery、编造新医疗机制、引入 NSFW 资产须另经作者确认。
