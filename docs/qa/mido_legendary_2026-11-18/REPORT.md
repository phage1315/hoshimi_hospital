# 御堂传奇术式 V1.2 · 实装与验收（2026-11-18）

状态：用户已确认全麻手术台图，已原样接入三个槽位并启用生产 registry。下方预览记录属于确认前历史，最终正式验收记录见文末。

## 范围

稳定 ID `surgery_master_aortic_root_ascending_replacement`，显式 LEGENDARY_STORY 注册，不占普通高级术式的月度放出／FIFO。完成高级教程、5 种普通高级首通及真实御堂 Lv5 后可接；首通御堂第一助手与原 14 日冷却均生效。首通成功后进入同一个周一两例有放回抽取池，使用普通患者与普通术中对白。

17 阶段、8 P、3 S，基础645分钟／54 HP。真实生理危机由现有 physiology 处理，非原稿已废弃固定概率；`crisis_chances` 的 0.12 仅用于原有 HP-only 编组估算，不能视为实战危机概率或全流程通关率。初始 base_difficulty 99、training_ceiling 100，奖励走原 advanced 结算，无独立存档内部状态。

用户修订：只用一张主要术野，切皮与关闭复用胸部图；深山佳织心血管、明日香和相泽麻纪腹部专科，专科内两次援助，保持真实技能；常服不接入，Day1 使用病房立绘。

## 原文与资源

冻结原稿 `research/source_scripts/HOSHIMI_MIDO_LEGENDARY_MURAKAMI_AI_V1_2.md`，三章32/5/15句。所有中英台词、说话人、顺序及选项由导入器保留；括号舞台说明不作为显示旁白。逐行立绘元数据不修改文本。新增通用 story renderer 的行级 portrait 覆盖，转运全景加宽展示。

作者术野按字节原样复制至 `assets/surgery/fields/mido_aortic_root.png`，校验相等。病房／术后基础及各两表情经本地 BiRefNet 透明化，1024×1536 RGBA，透明顶角通过，已查看三种底色与放大边缘；转运图保留完整背景。素材 SHA 与来源在 `assets/characters/murakami_ai_legendary_v1/manifest.json`。未使用常服候选。

## 数值回归

实际 Session / physiology，128固定种子，每组御堂＋深山佳织、计划分派、失败自救、危机暂停稳定，A/B表示三个战略节点全部选A/全部选B。统计为该策略和样本的结果，不是通关保证。

| 主刀技能 | 全A成功 | 全B成功 |
|---|---:|---:|
| 80 | 9/128 | 9/128 |
| 90 | 63/128 | 70/128 |
| 100 | 123/128 | 126/128 |

完整逐节点精密概率、队伍技能、平均耗时与危机见 `balance.json`。耗时均值包含提前终止案例。768次模拟均终止。

## 已执行验证

- `python3 tools/mido_legendary_source_audit.py`：637/0（包括资源SHA与原文UI合同）。
- `python3 tools/narrative_localization_test.py`：56745/0；`python3 tools/localization_audit.py`：93500条覆盖。
- headless：advanced_surgery 6454/0；advanced_referral 17/0；advanced_operative_dialogue 4902/0；advanced_referral_rules_v2 409/0；boundary_save 1020/0；narrative_save_lock 6/0；surgery_history_save 1082/0；save_store 19/0；localization 33/0；smoke 0失败。
- `tools/mido_legendary_test.gd` 最终172/0，包含首通失败锁定／返场失败保留通关与实际耗时；资源开放后启用额外周一池断言再跑。
- 导入退出0。headless 有系统 CA 证书提示，editor import 有沙箱 editor_settings 写入提示；不计作游戏脚本通过的证据。
- `.venv/bin/python tools/validate_data.py` 全局失败：既存 serika Lv5 hidden-portrait/CG 冲突及 Takemi 时间窗等；完整输出已保留 `/private/tmp/mido-validation.txt`。不改其他角色来掩盖全局失败。

## 未完成／边界

原生隔离预览 `native_preview_c/`：674 checks、0 failures、373 次合成 GUI 点击、38 张截图，中英三章52句与17阶段完整推进、成功Day3结算后正文。界面实际使用作者术野和6张透明立绘；已抽查中英术野、紧张／微笑立绘、转运、编组截图。编组选择与日历前置用内存夹具，其后操作为GUI输入。当前为 DEV content_preview，跳过未确认全麻图，不能代替生产入口或全麻资源验收。驱动早期沙箱134、语言API错误已保留，最终预览退出0且日志无ERROR。尚未验收发行包、Windows EXE或物理键鼠；不碰玩家存档，不自动 commit/push。旧 V1 operative regression 显式选择 V1 适配器并处理现有跨日转场；教程测试补齐实际已结算事实，未降低生产门槛。

最终UI复验 `native_preview_e/`：664 checks、0 failures、363次GUI点击、38截图，退出0，日志无ERROR；包含完整原稿术式名、病例标题、首通确认和结算提示。最终smoke-c退出0且无脚本错误。两轮点击数差异来自生理随机危机与救援路径；均完整到Day3成功正文。

最终结算可读性修复复验 `native_preview_f/`：682 checks、0 failures、379 次GUI点击、38截图；退出0、日志无ERROR。已打开英文结算截图确认病房暗底与提示文字对比正常。source audit 637/0、narrative localization 56745/0 与 diff --check 再次通过。全麻图仍待确认，生产未开放。


## 用户确认后的最终正式验收

用户确认全麻图“采用并接入”。`anesthesia.png` 原样复制，三个真实slot均指向该图，保留完整背景，1448×1086 RGB，SHA已登记。`legendary_registry.runtime_ready=true`；procedure status 改为 implemented，初值标记为已完成768次真实生理模拟，不表示已由真人长期平衡测试。

- 生产模式原生 `production_b/`：**682 checks、0 failures、371次合成GUI点击、38截图**，退出0且日志无ERROR。通过真实production gate／病例按钮、Day1全32句、真实队伍预约、Day2全5句、全麻过场按钮、患者就绪和7岗位确认、17阶段完整操作、Day3真实奖励结算与15句成功正文，中文与英文各一遍。已查看中文正式病例板／全麻／结算与英文术野／术后截图。无 DEV content_preview 或数值fixture旁路。
- 隔离内存注入教程、5种既往普通首通、御堂Lv5及队伍选择，主刀技能100；用固定种子稳定检查真实Runner，日历夹具在保留已结算time_log的前提下精确移到预约日09:00。不是从新游戏自然培养到解锁，也不是物理键鼠测试。`production_a`夹具叠加接诊60分钟导致10:00被生产时限拒绝，已修正夹具，未放宽游戏门槛。
- 专项headless `mido_legendary_test.gd` **179/0**，包括资源就绪、真实关系门槛、冷却、失败锁定、返场保留通关、两槽周一有放回抽样、周一当日完成延至下周及失败不入池、结算幂等与安全边界往返。
- 最终原文／素材audit **638/0**；narrative localization **56745/0**；localization audit **93500全覆盖**；导入退出0，无脚本编译错误；`git diff --check`通过。全局validate_data既存错误与未测发行包限制仍如上。

最终状态：本术式已可通过正式高级转诊的传奇术式栏目按门槛接诊。无本次未确认美术资源；未commit/push，未碰玩家存档。
