# 伊兹米／美纱高级术式内容接入

状态：数据、患者素材与两张作者提供的专属术野已接入；两项 `runtime_ready=true`，已开放 DEV 试玩。正式病例板按发布序号 5／6 及现有进度规则开放，不跳过前置。此前“等待专属术野后开放”的条件现已满足。

## 原稿与授权

原始包归档于 `docs/source/advanced_izumi_misa_v1/`，保留作者 Markdown、JSON 等原文件。按用户确认执行：

- 补回 Markdown 中存在而 JSON 遗漏的 11 条动作旁白，并忠实翻译英文。
- 从美纱玩家诊断中移出“完整角色来源待核。”制作备注；稳定患者 ID 不改名，源文件仍保留备注。
- 美纱随机返场仅采用需要重接重要肋间动脉分支的降胸主动脉瘤亚型，保持 M08 流程及对白。
- 专属术野未到位前不以 placeholder 开放试玩。

原有 50 条 Day 1／Day 3 对白中英文、说话人与顺序保持不变。新增旁白后共 61 行：伊兹米 Day 1 22 行、Day 3 13 行；美纱 Day 1 17 行、Day 3 9 行。两台共 72 条术中对白直接采用作者数据。

## 内容与入口

| 项目 | 伊兹米 | 美纱 |
| --- | --- | --- |
| 术式 ID | surgery_adv_complex_abdominal_reconstruction | surgery_adv_open_descending_thoracic_aortic_replacement |
| 发布序号 | 5 | 6 |
| 阶段 | I01–I12 | M01–M12 |
| Precision／Strategy | 6／2 | 6／2 |
| 数据耗时 | 600 分钟 | 690 分钟 |
| 基础 HP 消耗／难度 | 40／97 | 44／98 |
| 切皮／缝合复用 | 已批准腹部素材 | 已批准侧卧开胸素材 |
| 专属术野 | complex_abdominal_reconstruction_field.png | descending_thoracic_aortic_field.png |

术式原始数据逐字段保留，继续标记 `P0_TUNING_PENDING_GAMEPLAY_APPROVAL`。使用现有 Advanced Session、生理效果和危机接口，不另建普通 Surgery 流程。

每人 ward、postop、anesthesia、team_confirmation 四张已批准 PNG 通过 story.patient 接入；全麻图同时用于头像和 splash。pending 条目移除。新增两台的岗位确认对白适用范围，原有 13 条确认正文不改写。

正式与 DEV 病例板均按 release manifest 过滤，手术开始入口再次检查。返场适用条件由 `replay_case_profiles.json` 驱动；美纱病例记录使用稳定业务字段 `case_subtype=descending_thoracic_aneurysm_intercostal_reattachment`，不是技术节点或随机难度。缺少／不匹配亚型的返场不得进入该流程。返场不会借用首通人物剧情或专属患者图。

## 专属术野交付

两张图片均为 1280×1024 PNG，原样复制至 `assets/surgeries/advanced_fields_v1/`，不裁剪、不转换。既有显示控件保持比例；首阶段使用切皮图，中间阶段使用专属术野，末阶段使用缝合图，全麻过场与岗位确认阶段不显示术野。

- 伊兹米：作者附件 `codex-clipboard-cf2fd753-04cd-4cbf-ac91-48dd0b390acc.png` → `complex_abdominal_reconstruction_field.png`，SHA-256：`7615342f43dfb7bd853551b17388b84f7de38b92b5730491c635698be0c9224f`。
- 美纱：作者附件 `codex-clipboard-7817bcec-cbc4-45f9-933a-f4c5feedceb7.png` → `descending_thoracic_aortic_field.png`，SHA-256：`c91c2fedceadcfc5ee113ad53cb59fede957610fabd1aa9efa5f8740426b65d9`。

本轮仅接入术野、开放已批准入口及更新回归测试；不修改剧情、生理平衡、普通 Surgery 或玩家存档。

## 验证

- `python3 tools/advanced_izumi_misa_content_audit.py`：通过；逐句核对 Markdown 的中文、说话人和顺序，原有 50 条双语对白及 72 条术中对白保持一致，11 条英文旁白完整。
- `python3 tools/advanced_staff_dialogue_audit.py`：13 条确认正文原样保留，适用范围覆盖 6 台。
- `python3 tools/advanced_three_content_audit.py`：此前三台内容回归通过。
- `python3 tools/narrative_localization_test.py`：29,835 检查，0 失败。
- `python3 tools/localization_audit.py`：通过。项目全局仍有既存 fallback，不能据此声称全部项目英文已人工完成；本轮新增剧情双语完整。
- Godot 4.5.1 `tools/advanced_izumi_misa_test.gd`：974 检查，0 失败。覆盖两种 Strategy、真实编组、完整生理阶段至成功／失败、助手额度、HP 终止、双语 Day 1／Day 3 UI 原文与患者纹理绑定、术中说话人、正式进度门槛／DEV 入口开放及三阶段术野加载、返场亚型，以及完整安全边界存档接口反复回读。
- `tools/advanced_referral_rules_v2_test.gd`：417 检查，0 失败。
- `tools/advanced_surgery_ui_test.gd`：headless 825 检查、原生窗口 831 检查，均为 0 失败。中英文遍历六台已开放术式；新增两台使用真实医护编组，覆盖全麻、岗位确认、操作、危机及结算。

Godot 使用独立 `/tmp` 日志和临时测试存档路径，未写玩家存档。分别运行 headless 与原生窗口 UI 自动测试；引擎既存 macOS 证书警告不影响结果。原生测试报告为 `/tmp/hoshimi_advanced_ui_native.json`。

已完成真实 Godot 会话及有窗口 UI 自动流程验证，尚未进行人工逐画面完整试玩；不代表全部患者和返场组合均已遍历。每台 8 个种子的流程冒烟结果不作为成功率估计或平衡批准。
