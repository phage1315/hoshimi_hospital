# 御堂江美子传奇术式传授剧情《把心脏交还给跑道》独立交叉验收报告（村上愛 12 图新版素材刷新版）

- **验收日期**：2026-11-18（已按村上愛 12 张新版患者素材全量重抓实机截图）
- **目标术式稳定 ID**：`surgery_master_aortic_root_ascending_replacement`
- **中英文术式名称**：保留主动脉瓣的主动脉根部再植入（David 术式）＋升主动脉人工血管置换 ／ *Valve-Sparing Aortic Root Reimplantation (David Procedure) and Ascending Aortic Graft Replacement*
- **中英文剧情标题**：《把心脏交还给跑道》 ／ *Back to the Starting Line*
- **导师与首通专属患者**：御堂江美子（`doc_emiko`） ／ 村上愛（`patient_murakami_ai` / *Ai Murakami*）
- **原稿依据**：[HOSHIMI_MIDO_LEGENDARY_MURAKAMI_AI_V1_2.md](../../../research/source_scripts/HOSHIMI_MIDO_LEGENDARY_MURAKAMI_AI_V1_2.md)
- **本轮独立验收目录**：`docs/qa/mido_legendary_acceptance_2026-11-18/`（含 [engine.log](engine.log) 与 `native_prod/*.png` 共 52 张实机截图，其中本轮重跑更新 48 张双语帧）
- **总体结论**：**通过（PASS）** —— 静态原文与本地化对账（`642 checks; 0 failures`）、13 项正式运行美术技术校验（12 张患者素材＋原主术野）、Headless 逻辑／存档／跨事件联动回归、以及 macOS Metal 可见原生窗口中英双语正式生产入口全流程合成 GUI 验收（`736 checks; 0 failures; 373 GUI clicks; 48 screenshots`）全部 `0` 失败通过。

---

## 一、新版 12 图村上愛患者运行槽位核验摘要

| 槽位键 | 正式资源路径 | 实机出现位置 |
|---|---|---|
| `ward` / `ward/neutral` | `assets/characters/murakami_ai_legendary_v1/ward/neutral.png` | Day 1 诊室开场（`day1_0`）与团队编组病例卡 |
| `ward/serious` | `assets/characters/murakami_ai_legendary_v1/ward/serious.png` | Day 1 诊室认真询问差分（`day1_21`） |
| `ward/nervous` | `assets/characters/murakami_ai_legendary_v1/ward/nervous.png` | Day 1 诊室听说心脏停搏时的紧张差分（`day1_16`） |
| `transfer` | `assets/characters/murakami_ai_legendary_v1/transfer.png` | Day 2 手术室双门前裸肩平车转运场景（`day2_0`） |
| `splash/general_anesthesia` | `assets/characters/murakami_ai_legendary_v1/anesthesia.png` | Day 2 独立全麻诱导完成弹窗（`_anesthesia`） |
| `intraoperative/anesthetized` | `assets/characters/murakami_ai_legendary_v1/intraoperative/anesthetized.png` | Day 2 患者麻醉就位页右侧独立术中全麻头像（`_patient_ready`） |
| `team_confirmation` | `assets/characters/murakami_ai_legendary_v1/team_confirmation.png` | Day 2 患者就位页＆7 岗位核对页中央手术台仰卧体位图（`_patient_ready`、`_team_confirm`） |
| `postop/pain` | `assets/characters/murakami_ai_legendary_v1/postop/pain.png` | Day 3 术后病房苏醒疼痛差分（`day3_0`） |
| `postop` / `postop/neutral` | `assets/characters/murakami_ai_legendary_v1/postop/neutral.png` | Day 3 术后病房平静吸氧立绘（`day3_4`） |
| `postop/smile` | `assets/characters/murakami_ai_legendary_v1/postop/smile.png` | Day 3 术后病房微笑差分（`day3_11`） |

---

## 二、新版素材原生窗口实机截图巡检（全量截图位于 `native_prod/`）

### 1. 正式高级转诊病例板与首通团队编组（新版 `ward/neutral` 病例卡）

![中文正式高级转诊病例板](native_prod/zh_CN_board.png)

![中文首通手术团队编组（御堂固定第一助手 + 村上愛新版 ward/neutral）](native_prod/zh_CN_team.png)

![英文首通手术团队编组](native_prod/en_team.png)

---

### 2. Day 1 诊察室剧情：村上愛新版病房三表情（`neutral` / `serious` / `nervous`）与御堂解说

![Day 1 开场初诊（村上愛新版 ward/neutral）](native_prod/zh_CN_day1_0.png)

![Day 1 御堂解说 5.3 cm 主动脉根部影像](native_prod/zh_CN_day1_4.png)

![Day 1 听说心脏停搏时的紧张差分（村上愛新版 ward/nervous）](native_prod/zh_CN_day1_16.png)

![Day 1 术前认真确认方案差分（村上愛新版 ward/serious）](native_prod/zh_CN_day1_21.png)

---

### 3. Day 2 手术室门前转运、独立全麻弹窗、独立全麻头像与仰卧手术体位核对页

- 现已彻底拆分 `splash/general_anesthesia`（`anesthesia.png`）、`intraoperative/anesthetized`（`intraoperative/anesthetized.png`）与 `team_confirmation`（`team_confirmation.png`）三个独立运行槽位。

![中文 Day 2 手术室门前裸肩平车转运（新版 transfer.png）](native_prod/zh_CN_day2_0.png)

![中文 Day 2 手术室门前御堂洗手衣回应（scrubs/neutral）](native_prod/zh_CN_day2_4.png)

![中文独立全麻诱导完成弹窗（新版 anesthesia.png）](native_prod/zh_CN_anesthesia.png)

![中文患者麻醉就位页（中央 team_confirmation.png + 右侧独立 intraoperative/anesthetized.png）](native_prod/zh_CN_patient_ready.png)

![中文 7 岗位核对页（中央 team_confirmation.png + 御堂无菌手术衣确认）](native_prod/zh_CN_team_confirm.png)

![英文患者麻醉就位页（team_confirmation.png + intraoperative/anesthetized.png）](native_prod/en_patient_ready.png)

---

### 4. Day 2 大手术室 17 阶段术野与御堂 `MIDO_TEACHING` 传授对白

![MR04 御堂术中传授提问（MIDO_TEACHING）](native_prod/zh_CN_MR04_mido_teaching.png)

![MR05 主动脉阻断与心肌保护（主术野 mido_aortic_root.png）](native_prod/zh_CN_MR05.png)

![MR10 御堂术中传授点拨（英文 MIDO_TEACHING）](native_prod/en_MR10_mido_teaching.png)

![MR17 关胸结束与手术完成总结面板](native_prod/zh_CN_terminal.png)

---

### 5. Day 3 术后病房新版三表情（`postop/pain` / `neutral` / `smile`）与结算页

![中文 Day 3 术后病房苏醒（村上愛新版 postop/pain）](native_prod/zh_CN_day3_0.png)

![中文 Day 3 术后病房平静吸氧立绘（村上愛新版 postop/neutral）](native_prod/zh_CN_day3_4.png)

![中文 Day 3 御堂术后康复叮嘱](native_prod/zh_CN_day3_5.png)

![英文 Day 3 术后微笑立绘（村上愛新版 postop/smile）](native_prod/en_day3_11.png)

![中文最终结算摘要页](native_prod/zh_CN_settled.png)

---

## 三、全量双语原生实机截图链接索引（`native_prod/`）

| 阶段／节点 | 中文 (`zh_CN`) | 英文 (`en`) |
|---|---|---|
| 1. 高级转诊病例板 | [zh_CN_board.png](native_prod/zh_CN_board.png) | [en_board.png](native_prod/en_board.png) |
| 2. 首通团队编组页 | [zh_CN_team.png](native_prod/zh_CN_team.png) | [en_team.png](native_prod/en_team.png) |
| 3. Day 1 `0` `ward/neutral` | [zh_CN_day1_0.png](native_prod/zh_CN_day1_0.png) | [en_day1_0.png](native_prod/en_day1_0.png) |
| 4. Day 1 `4` 御堂影像解说 | [zh_CN_day1_4.png](native_prod/zh_CN_day1_4.png) | [en_day1_4.png](native_prod/en_day1_4.png) |
| 5. Day 1 `16` `ward/nervous` | [zh_CN_day1_16.png](native_prod/zh_CN_day1_16.png) | [en_day1_16.png](native_prod/en_day1_16.png) |
| 6. Day 1 `21` `ward/serious` | [zh_CN_day1_21.png](native_prod/zh_CN_day1_21.png) | [en_day1_21.png](native_prod/en_day1_21.png) |
| 7. Day 2 `0` `transfer.png` | [zh_CN_day2_0.png](native_prod/zh_CN_day2_0.png) | [en_day2_0.png](native_prod/en_day2_0.png) |
| 8. Day 2 `4` 御堂洗手衣 | [zh_CN_day2_4.png](native_prod/zh_CN_day2_4.png) | [en_day2_4.png](native_prod/en_day2_4.png) |
| 9. Day 2 全麻诱导弹窗 `anesthesia.png` | [zh_CN_anesthesia.png](native_prod/zh_CN_anesthesia.png) | [en_anesthesia.png](native_prod/en_anesthesia.png) |
| 10. Day 2 麻醉就位页 `patient_ready` | [zh_CN_patient_ready.png](native_prod/zh_CN_patient_ready.png) | [en_patient_ready.png](native_prod/en_patient_ready.png) |
| 11. Day 2 团队体位核对页 `team_confirm` | [zh_CN_team_confirm.png](native_prod/zh_CN_team_confirm.png) | [en_team_confirm.png](native_prod/en_team_confirm.png) |
| 12. 术中 `MR01` / `MR03` / `MR04` 教学 | [zh_CN_MR01.png](native_prod/zh_CN_MR01.png) / [zh_CN_MR04_mido_teaching.png](native_prod/zh_CN_MR04_mido_teaching.png) | [en_MR01.png](native_prod/en_MR01.png) / [en_MR04_mido_teaching.png](native_prod/en_MR04_mido_teaching.png) |
| 13. 术中 `MR05` / `MR10` / `MR10` 教学 | [zh_CN_MR05.png](native_prod/zh_CN_MR05.png) / [zh_CN_MR10_mido_teaching.png](native_prod/zh_CN_MR10_mido_teaching.png) | [en_MR05.png](native_prod/en_MR05.png) / [en_MR10_mido_teaching.png](native_prod/en_MR10_mido_teaching.png) |
| 14. 术中 `MR17` 与终态总结 | [zh_CN_MR17.png](native_prod/zh_CN_MR17.png) / [zh_CN_terminal.png](native_prod/zh_CN_terminal.png) | [en_MR17.png](native_prod/en_MR17.png) / [en_terminal.png](native_prod/en_terminal.png) |
| 15. Day 3 `0` `postop/pain` | [zh_CN_day3_0.png](native_prod/zh_CN_day3_0.png) | [en_day3_0.png](native_prod/en_day3_0.png) |
| 16. Day 3 `4` `postop/neutral` | [zh_CN_day3_4.png](native_prod/zh_CN_day3_4.png) | [en_day3_4.png](native_prod/en_day3_4.png) |
| 17. Day 3 `5` 御堂康复叮嘱 | [zh_CN_day3_5.png](native_prod/zh_CN_day3_5.png) | [en_day3_5.png](native_prod/en_day3_5.png) |
| 18. Day 3 `11` `postop/smile` | [zh_CN_day3_11.png](native_prod/zh_CN_day3_11.png) | [en_day3_11.png](native_prod/en_day3_11.png) |
| 19. Day 3 最终结算摘要页 | [zh_CN_settled.png](native_prod/zh_CN_settled.png) | [en_settled.png](native_prod/en_settled.png) |
