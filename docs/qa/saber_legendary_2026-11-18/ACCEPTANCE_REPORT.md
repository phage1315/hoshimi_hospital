# 阿尔托莉雅（Saber）传奇术式《这一次，交给你》全链路实装验收报告（久宇舞弥 12 图新版素材刷新版）

- **验收日期**：2026-11-18（已按久宇舞弥 12 张新版患者素材全量重抓实机截图）
- **目标术式稳定 ID**：`surgery_master_whipple_vascular_reconstruction`
- **中英文术式名称**：复杂胰十二指肠切除联合门肠静脉重建 ／ *Complex Pancreaticoduodenectomy with PV/SMV Reconstruction*
- **中英文剧情标题**：《这一次，交给你》 ／ *This Time, I Entrust It to You*
- **一助与首通专属患者**：阿尔托莉雅·潘德拉贡（`doc_artoria`） ／ 久宇舞弥（`patient_maiya_hisau` / *Maiya Hisau*）
- **原稿依据**：
  - [HOSHIMI_SABER_LEGENDARY_MAIYA_THREE_DAY_VN_V1_1.md](../../../research/source_scripts/HOSHIMI_SABER_LEGENDARY_MAIYA_THREE_DAY_VN_V1_1.md)（SHA-256 `cecfcc04f600...`）
  - [HOSHIMI_SABER_LEGENDARY_MAIYA_SURGICAL_DESIGN_V1_1.md](../../../research/source_scripts/HOSHIMI_SABER_LEGENDARY_MAIYA_SURGICAL_DESIGN_V1_1.md)（SHA-256 `2b22238d15db...`）
- **验收目录**：`docs/qa/saber_legendary_2026-11-18/`（含 [engine.log](engine.log) 与 `native_prod/*.png` 共 64 张 `1280×800` 原生实机截图）
- **总体结论**：**通过（PASS）** —— 原稿逐字一致性与 13 项素材审计（`2,098/2,098`）、中英本地化审计（`57,229` + `93,500` 项 `0` 失败）、Headless 专项与回归测试、以及 macOS Metal 原生可见窗口中英双语全链路 GUI 验收（`1,989 checks; 0 failures; 782 GUI clicks; 64 screenshots`）全部 `0` 失败通过。

---

## 一、新版 12 图久宇舞弥患者运行槽位核验摘要

| 槽位键 | 正式资源路径 | 实机出现位置 |
|---|---|---|
| `casual/neutral` | `assets/characters/maiya_hisau_legendary_v1/casual/neutral.png` | Day 1 Scene A 外科门诊初诊（`A02`、`A25`） |
| `ward` / `ward/neutral` | `assets/characters/maiya_hisau_legendary_v1/ward/neutral.png` | 团队编组病例卡、Day 1 Scene D 病房开场（`D03`） |
| `ward/serious` | `assets/characters/maiya_hisau_legendary_v1/ward/serious.png` | Day 1 Scene D 病房认真差分（`D12`） |
| `ward/relieved` | `assets/characters/maiya_hisau_legendary_v1/ward/relieved.png` | Day 1 Scene D 病房释然差分（`D22`） |
| `transfer` | `assets/characters/maiya_hisau_legendary_v1/transfer.png` | Day 2 Scene E 手术室双门外裸肩平车转运（`E03`） |
| `or_cap/calm` | `assets/characters/maiya_hisau_legendary_v1/or_cap/calm.png` | Day 2 Scene F 手术台诱导前手术帽裸肩头像（`F05`） |
| `anesthesia` / `splash/general_anesthesia` | `assets/characters/maiya_hisau_legendary_v1/anesthesia.png` | Day 2 `F13` 诱导场景＆独立全麻诱导完成弹窗（`anesthesia_splash`） |
| `intraoperative/anesthetized` | `assets/characters/maiya_hisau_legendary_v1/intraoperative/anesthetized.png` | Day 2 患者麻醉就位页右侧独立术中全麻头像（`patient_ready`） |
| `team_confirmation` | `assets/characters/maiya_hisau_legendary_v1/team_confirmation.png` | Day 2 患者就位页＆7 岗位核对页中央腹部仰卧手术体位图（`patient_ready`、`team_confirm`） |
| `postop/tired` | `assets/characters/maiya_hisau_legendary_v1/postop/tired.png` | Day 3 Scene G 清晨病房苏醒疲倦差分（`G03`） |
| `postop` / `postop/neutral` | `assets/characters/maiya_hisau_legendary_v1/postop/neutral.png` | Day 3 Scene G 病房平静吸氧立绘（`G08`、`G29`） |
| `postop/relieved` | `assets/characters/maiya_hisau_legendary_v1/postop/relieved.png` | Day 3 Scene G 病房释然收束立绘（`G33`） |

---

## 二、新版素材原生窗口实机截图巡检（精选内嵌图集）

### 1. 高级转诊病例板与首通团队编组（新版 `ward/neutral` 病例卡）

![中文高级转诊病例板](native_prod/zh_CN_board.png)

![中文首通团队编组页（阿尔托莉雅固定一助 + 久宇舞弥新版 ward/neutral）](native_prod/zh_CN_team.png)

![英文首通团队编组页](native_prod/en_team.png)

---

### 2. Day 1 门诊常服与病房三表情（`casual/neutral` + `ward/neutral` · `serious` · `relieved`）

![中文 Day 1 门诊初诊（A02 新版久宇舞弥 casual/neutral）](native_prod/zh_CN_day1_A02.png)

![中文 Day 1 门诊即时选择 A-C1（A25 双选项）](native_prod/zh_CN_day1_A25.png)

![中文 Day 1 病房开场（D03 新版久宇舞弥 ward/neutral）](native_prod/zh_CN_day1_D03.png)

![中文 Day 1 病房认真差分（D12 新版 ward/serious）](native_prod/zh_CN_day1_D12.png)

![中文 Day 1 病房释然差分（D22 新版 ward/relieved）](native_prod/zh_CN_day1_D22.png)

![英文 Day 1 外科办公室即时选择 C-C2（C26 三选项）](native_prod/en_day1_C26.png)

---

### 3. Day 2 裸肩转运、清醒手术帽头像、独立全麻弹窗与腹部仰卧体位核对页

![中文 Day 2 手术室门外裸肩平车核对（E03 新版 transfer.png）](native_prod/zh_CN_day2_E03.png)

![中文 Day 2 手术台诱导前清醒头像（F05 新版 or_cap/calm.png）](native_prod/zh_CN_day2_F05.png)

![中文 Day 2 诱导前阿尔托莉雅口罩手术帽立绘（F11 scrubs_masked/neutral）](native_prod/zh_CN_day2_F11.png)

![中文 Day 2 麻醉诱导面罩场景（F13 新版 anesthesia.png）](native_prod/zh_CN_day2_F13.png)

![中文独立全麻诱导完成弹窗（anesthesia_splash.png）](native_prod/zh_CN_anesthesia_splash.png)

![中文患者麻醉就位页（中央独立腹部体位 team_confirmation.png + 右侧独立全麻头像 intraoperative/anesthetized.png）](native_prod/zh_CN_patient_ready.png)

![中文 7 岗位核对页（中央腹部体位 team_confirmation.png + 阿尔托莉雅无菌衣确认）](native_prod/zh_CN_team_confirm.png)

![英文患者麻醉就位页（en_patient_ready.png）](native_prod/en_patient_ready.png)

---

### 4. Day 2 大手术室 18 阶段实战、术野切换与一助 `ASxx_S_PRE` 对白

![英文 WH01 切皮术野与 Saber 开台辅助台词（AS01_S_PRE）](native_prod/en_WH01_saber_pre.png)

![中文 WH02 腹腔探查与主术野窗口（saber_whipple_vascular.jpg）](native_prod/zh_CN_WH02.png)

![中文 WH05 策略节点 S1：SMA 动脉优先入路选择](native_prod/zh_CN_WH05.png)

![英文 WH11 高精度血管阻断前 Saber 一助报告（AS11_S_PRE）](native_prod/en_WH11_saber_pre.png)

![中文 WH12 最高精度节点（难度 98）：自体静脉间置重建门肠静脉](native_prod/zh_CN_WH12.png)

![中文 WH18 关腹术野（whipple_closure.png）](native_prod/zh_CN_WH18.png)

![中文 18 阶段完成总结面板](native_prod/zh_CN_terminal.png)

---

### 5. Day 3 术后病房新版三表情（`postop/tired` · `neutral` · `relieved`）、复盘室与走廊尾声

![中文 Day 3 清晨病房苏醒（G03 新版 postop/tired.png）](native_prod/zh_CN_day3_G03.png)

![中文 Day 3 病房平静吸氧立绘（G08 新版 postop/neutral.png）](native_prod/zh_CN_day3_G08.png)

![中文 Day 3 病房即时选择 G-C3（G29）](native_prod/zh_CN_day3_G29.png)

![中文 Day 3 病房释然收束立绘（G33 新版 postop/relieved.png）](native_prod/zh_CN_day3_G33.png)

![英文 Day 3 病房释然收束立绘（en_day3_G33.png）](native_prod/en_day3_G33.png)

![英文 Day 3 外科复盘室即时选择 H-C4（H30）](native_prod/en_day3_H30.png)

![中文 Day 3 黄昏走廊尾声（I14）](native_prod/zh_CN_day3_I14.png)

![英文最终结算摘要页](native_prod/en_settled.png)

---

## 三、全量 64 张双语原生实机截图链接索引（`native_prod/`）

| 阶段／节点 | 中文实机截图 (`zh_CN`) | 英文实机截图 (`en`) |
|---|---|---|
| 1. 高级转诊病例板 | [zh_CN_board.png](native_prod/zh_CN_board.png) | [en_board.png](native_prod/en_board.png) |
| 2. 首通团队编组页 | [zh_CN_team.png](native_prod/zh_CN_team.png) | [en_team.png](native_prod/en_team.png) |
| 3. Day 1 `A02` 门诊初诊（`casual/neutral`） | [zh_CN_day1_A02.png](native_prod/zh_CN_day1_A02.png) | [en_day1_A02.png](native_prod/en_day1_A02.png) |
| 4. Day 1 `A25` 即时选项 `A-C1` | [zh_CN_day1_A25.png](native_prod/zh_CN_day1_A25.png) | [en_day1_A25.png](native_prod/en_day1_A25.png) |
| 5. Day 1 `B08` 会议室影像评估 | [zh_CN_day1_B08.png](native_prod/zh_CN_day1_B08.png) | [en_day1_B08.png](native_prod/en_day1_B08.png) |
| 6. Day 1 `C26` 即时选项 `C-C2` | [zh_CN_day1_C26.png](native_prod/zh_CN_day1_C26.png) | [en_day1_C26.png](native_prod/en_day1_C26.png) |
| 7. Day 1 `D03` 病房 `ward/neutral` | [zh_CN_day1_D03.png](native_prod/zh_CN_day1_D03.png) | [en_day1_D03.png](native_prod/en_day1_D03.png) |
| 8. Day 1 `D12` 病房 `ward/serious` | [zh_CN_day1_D12.png](native_prod/zh_CN_day1_D12.png) | [en_day1_D12.png](native_prod/en_day1_D12.png) |
| 9. Day 1 `D22` 病房 `ward/relieved` | [zh_CN_day1_D22.png](native_prod/zh_CN_day1_D22.png) | [en_day1_D22.png](native_prod/en_day1_D22.png) |
| 10. Day 2 `E03` 手术室门外 `transfer.png` | [zh_CN_day2_E03.png](native_prod/zh_CN_day2_E03.png) | [en_day2_E03.png](native_prod/en_day2_E03.png) |
| 11. Day 2 `F05` 诱导前 `or_cap/calm.png` | [zh_CN_day2_F05.png](native_prod/zh_CN_day2_F05.png) | [en_day2_F05.png](native_prod/en_day2_F05.png) |
| 12. Day 2 `F11` 阿尔托莉雅口罩洗手衣 | [zh_CN_day2_F11.png](native_prod/zh_CN_day2_F11.png) | [en_day2_F11.png](native_prod/en_day2_F11.png) |
| 13. Day 2 `F13` 麻醉面罩 `anesthesia.png` | [zh_CN_day2_F13.png](native_prod/zh_CN_day2_F13.png) | [en_day2_F13.png](native_prod/en_day2_F13.png) |
| 14. Day 2 全麻诱导完成弹窗 | [zh_CN_anesthesia_splash.png](native_prod/zh_CN_anesthesia_splash.png) | [en_anesthesia_splash.png](native_prod/en_anesthesia_splash.png) |
| 15. Day 2 患者麻醉就位页 `patient_ready` | [zh_CN_patient_ready.png](native_prod/zh_CN_patient_ready.png) | [en_patient_ready.png](native_prod/en_patient_ready.png) |
| 16. Day 2 团队体位核对页 `team_confirm` | [zh_CN_team_confirm.png](native_prod/zh_CN_team_confirm.png) | [en_team_confirm.png](native_prod/en_team_confirm.png) |
| 17. 术中 `WH01` 切皮 Saber PRE | [zh_CN_WH01_saber_pre.png](native_prod/zh_CN_WH01_saber_pre.png) | [en_WH01_saber_pre.png](native_prod/en_WH01_saber_pre.png) |
| 18. 术中 `WH01` 切皮行动面板 | [zh_CN_WH01.png](native_prod/zh_CN_WH01.png) | [en_WH01.png](native_prod/en_WH01.png) |
| 19. 术中 `WH02` 主术野探查 | [zh_CN_WH02.png](native_prod/zh_CN_WH02.png) | [en_WH02.png](native_prod/en_WH02.png) |
| 20. 术中 `WH05` 策略节点 `S1` | [zh_CN_WH05.png](native_prod/zh_CN_WH05.png) | [en_WH05.png](native_prod/en_WH05.png) |
| 21. 术中 `WH11` 血管阻断 Saber PRE | [zh_CN_WH11_saber_pre.png](native_prod/zh_CN_WH11_saber_pre.png) | [en_WH11_saber_pre.png](native_prod/en_WH11_saber_pre.png) |
| 22. 术中 `WH12` 自体静脉重建 | [zh_CN_WH12.png](native_prod/zh_CN_WH12.png) | [en_WH12.png](native_prod/en_WH12.png) |
| 23. 术中 `WH17` 策略节点 `S3` | [zh_CN_WH17.png](native_prod/zh_CN_WH17.png) | [en_WH17.png](native_prod/en_WH17.png) |
| 24. 术中 `WH18` 关腹术野 | [zh_CN_WH18.png](native_prod/zh_CN_WH18.png) | [en_WH18.png](native_prod/en_WH18.png) |
| 25. 术中 18 阶段完成总结 | [zh_CN_terminal.png](native_prod/zh_CN_terminal.png) | [en_terminal.png](native_prod/en_terminal.png) |
| 26. Day 3 `G03` 清晨病房 `postop/tired` | [zh_CN_day3_G03.png](native_prod/zh_CN_day3_G03.png) | [en_day3_G03.png](native_prod/en_day3_G03.png) |
| 27. Day 3 `G08` 病房 `postop/neutral` | [zh_CN_day3_G08.png](native_prod/zh_CN_day3_G08.png) | [en_day3_G08.png](native_prod/en_day3_G08.png) |
| 28. Day 3 `G29` 即时选项 `G-C3` | [zh_CN_day3_G29.png](native_prod/zh_CN_day3_G29.png) | [en_day3_G29.png](native_prod/en_day3_G29.png) |
| 29. Day 3 `G33` 病房 `postop/relieved` | [zh_CN_day3_G33.png](native_prod/zh_CN_day3_G33.png) | [en_day3_G33.png](native_prod/en_day3_G33.png) |
| 30. Day 3 `H30` 即时选项 `H-C4` | [zh_CN_day3_H30.png](native_prod/zh_CN_day3_H30.png) | [en_day3_H30.png](native_prod/en_day3_H30.png) |
| 31. Day 3 `I14` 黄昏走廊尾声 | [zh_CN_day3_I14.png](native_prod/zh_CN_day3_I14.png) | [en_day3_I14.png](native_prod/en_day3_I14.png) |
| 32. Day 3 最终结算摘要页 | [zh_CN_settled.png](native_prod/zh_CN_settled.png) | [en_settled.png](native_prod/en_settled.png) |
