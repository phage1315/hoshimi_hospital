# 剩余已注册剧情事件：中英文原生复验

2026-10-27；main / f95636a22b16c7d2dfd99e9956e32c90b3dba21e 加既有工作区。本轮只新增 QA 工具与记录，未修改游戏代码、剧情、译文、素材或生产开关；未提交、推送、发布或覆盖玩家存档。

## 范围与占位分类

[占位状态清单](PLACEHOLDER_STATUS.md)：22 位角色共 94 个 planned 升级槽位，另 4 位角色共 20 个 unavailable 槽位。它们不是额外的已注册可播放事件。2 个 developer_only 框架事件不列入剧情测试。剩余 17 个已注册剧情条目全部纳入本轮；有数据不预先代表符合最终原稿。

## 运行覆盖

- 17 个事件条目、2077 个步骤内定义节点，中英文正文/回想均已原生运行。千束两天均有名为 opening 的节点，因此按事件去重 ID 为 2076；两个 opening 的不同正文在四种模式中均有实际页面记录。
- 先跑完整主路径，再对分支使用明确标注的隔离起点推进到汇合；不是穷举所有先前选择的笛卡尔组合。最终 160 次多选项分支检查（新手术室 6 个选项＋千束 34 个选项，各乘两语言和正文/回想）均完成到汇合。分支核查脚本不直接调用跳转方法推进，使用鼠标、空格、回车；完整路线还覆盖实际自动播放按钮。
- [覆盖数据](COVERAGE.json)、[完整路线](content_final/runtime_results.json)、[最终分支](branches_final/runtime_results.json)。native_recheck 保留先完成的中文路线；content_final 为后续续测。supplemental 是中间补核，最终分支结论以 branches_final 为准。
- [入口结果](native_recheck/remaining_entry_corrected_results.json)、[抢占后的合法历史前置补测](native_recheck/remaining_entry_precedence_results.json)、[武见 T6 真实术后返回 GUI](native_recheck/takemi_clinical_final_results.json)。正式入口使用完整生产注册表，前置为隔离内存已结算事实，不代表从新游戏自然养成。芹香 Lv3 入口未接通；千早第三次 B/C 为连续内部转场，专项三日流程验证。

## 三项结论

1. **事件流：已完成中英正文、回想主路径与分支运行覆盖。** 正式入口和内容播放分别记录。武见六段门槛与稳定事实专项 1571 项无失败；芹香 Lv1 修正过时测试后 2949 项无失败；千早第二次原生身份专项 7719 项无失败；第三次原生连续三日专项 17869 项无失败、987 页。转正系统专项通过。高级转诊、转正及新手术室补充结算检查见 boundary_logic_results.json；其新手术室广泛夹具的两项失败已隔离，最小前置 boundary_minimal_results.json 为 364 项无失败。无玩家存档参与。
2. **显示交互：已测容器、资源加载、翻页及输入未确认新的阻断缺陷。** 保留 actual 控件姓名、纹理精确路径、区域、位置及文字的逐页观测，截图共 328 张。CG 遮挡普通立绘或对白框覆盖 CG 属既定表现。确认副标题总天数显示小数的 P3；不以画面截图数量代表整体验收。
3. **说话人与立绘：已核对运行配置对应及具名/未相识变体；不能宣称原稿情绪与演出要求全部签核。** 原稿审计覆盖武见170句、芹香Lv1的85节点、Lv3的208原稿条目（207 VN节点＋菜单选项）、千早第二次703段和第三次487原稿行（486 VN节点）。实际姓名告警已单独按身份规则复核。发现千束 opening 英文与现行中文不一致，英文内容验收不通过。

## 原稿与静态验证

- 武见：research/character_references/takemi_tae_2026-10-23/HOSHIMI_TAKEMI_TAE_LV0_CODEX_HANDOFF_V2.md。
- 芹香：docs/source/serika_lv1、docs/source/serika_lv3 内用户稿、修订决定及双语 review。
- 千早：docs/source/chihaya_second_surgery 的留美修订原稿与记录、docs/source/chihaya_third_surgery 原稿及解析记录。对应本轮五份 *source.log 均通过。
- 千束：docs/design/HOSHIMI_ADVANCED_REFERRAL_TUTORIAL_CHISATO_V1.md，结合 docs/audits/chisato_script_fidelity_audit_2026-10-03.md 已明确修订；旧报告只用于确认依据，本轮运行另做。
- 新手术室依据 docs/or_acceptance_training_event.md 当前规则；专属护士依据 docs/source/HOSHIMI_PERSONAL_NURSE_SYSTEM_V1.md 和 docs/HOSHIMI_PERSONAL_NURSE_SYSTEM_CURRENT.md 的已记录差异。
- 本轮 narrative_localization_test.py：18431 检查、0 失败；localization_audit.py 已运行。静态检查能证明译文存在，不能排除开场译文未同步问题。

## 尚未完整覆盖

新手术室与转正缺少独立逐句最终对白签核依据；千束全文语义及全部原稿情绪/演出要求仍需逐句终审。已有专项原稿审计不替代所有镜头的人工情绪判断。此次没有把任一事件新标为“全部条件完整验收通过”。此前两批的未核事项和 P2 仍有效。深山 Lv3 原稿缺段未补全，本轮没有重测或自行补写。

详细问题、预期行为及测试脚本修正见 [问题单](ISSUES.md)。全部运行日志、逐页记录和截图在本目录；不是可恢复的会话快照。
