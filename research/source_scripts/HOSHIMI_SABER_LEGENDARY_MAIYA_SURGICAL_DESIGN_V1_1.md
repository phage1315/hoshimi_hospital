# Hoshimi Hospital — Saber Legendary Surgery
## 《这一次，交给你》／久宇舞弥／18-Stage Surgical Design V1.1 — Concept Lock

**状态：用户已批准 Concept Lock／V1.1 数值经 Codex 大规模模拟及 Godot Headless 交叉核查；非已实装或医学审校完成声明。**  
**目标：**完整交付传奇术式的 18 阶段、数值与生理配置、双语阶段对白、专属助手差分、三日 VN 接线及工程验收契约。三日完整正文另见配套 V1.1 VN 定稿，不以本文件的剧情纲要代替。  
**对应术式 ID：**surgery_master_whipple_vascular_reconstruction  
**分类：**LEGENDARY_STORY（须显式注册；现有自动识别前缀并不覆盖 surgery_master_）

**对应正式剧本：**HOSHIMI_SABER_LEGENDARY_MAIYA_THREE_DAY_VN_V1_1.md。其 A–I 全部中英双语正文与四个即时选择已经审校通过；除用户明确授权外，不改写其可见文本。  
**数值审查基准：**SABER_LEGENDARY_V1_1_BALANCE_REVIEW(1).md；本文收录经复核的最终交付数值，不要求 Codex 再次自行设计。  
**版本变更：**V1.1 从原 V1.0 的 58 HP 校准至 54 HP，三处 S 策略增益校准，最终危机移至 WH17 后，增加全部 18 行生理配置与 7 条条件效果；改用 V2 周一双槽有放回返场规则，锁定失败状态，并确定术野视频参考。

---

## 0. 固定设定与策划边界

| 项 | 设定 |
|---|---|
| 指导医生 | 阿尔托莉雅·潘德拉贡／Saber |
| 患者 | 久宇舞弥（Maiya Hisau），成年女性 |
| 首次主刀 | 坂口；Saber 固定第一助手 |
| 手术中文名 | 复杂胰十二指肠切除术（Whipple）联合门静脉／肠系膜上静脉节段切除与移植物间置重建 |
| 英文名 | Complex Pancreaticoduodenectomy (Whipple Procedure) with Segmental Portal–Superior Mesenteric Vein Resection and Interposition Graft Reconstruction |
| 病例 | 胰头约 6 cm 实性假乳头状肿瘤（SPN），邻近并累及 PV/SMV 汇合附近的静脉段；讨论后决定整块切除及静脉重建 |
| 血管重建方案 | **Type IV：节段切除 + 自体静脉移植物间置**；预计缺损约 4–5 cm，不做简单侧壁修补或强拉端端吻合 |
| 麻醉与切口 | 全身麻醉，传统开腹；术野贯穿 18 阶段使用**同一张静态图** |
| 结构 | F4 / L3 / S3 / P8，合计 18 阶段 |
| 锁定基础耗时／HP | **729 min / 54 HP**（不含策略、精密失误、技能差过载与危机） |
| 危机检查点 | **WH08、WH12、WH17** 后各 1 个；crisis_checkpoints = [8, 12, 17]，使用现有 resolver |
| 三个策略节点 | WH05、WH10、WH17，各二选一 |
| 顶层参数 | base_difficulty = 99；training_ceiling = 100；reward_tier = advanced；dialogue_after_rescue = true |

### 0.1 医学构造假设（必须在剧本中自洽）

- 采用预先取得、可用的**自体静脉移植物**。取材由并行团队准备，不在 18 阶段中插入额外的玩家操作。具体供区及合理性须由医学审校核准，不暗写为凭空出现。
- 本例的肿瘤累及 PV/SMV 的一小段静脉壁与周围界面；术前影像已确定 **SMA 等主要动脉无需切除／重建**。
- 本例暂定：术前血管重建图与探查均证实**脾静脉汇入口可连同近端血管袖保留**，有效引流不受本次节段切除破坏，因此不另设脾静脉再吻合。此为**本虚构病例有待医学审校的个体解剖前提**，绝不代表 Type IV 一律无需处理脾静脉；若审核认为切除边界不可能同时满足这些条件，应向用户提交重建方案变更请求，不能静默省去处理步骤。
- 将肿瘤及受累静脉段整块取出后，立即完成移植物测量、两端吻合与复灌；不在静脉阻断期间安排长篇 VN、教学演讲或不相干流程。
- 胰肠、胆肠、胃肠重建均作为后续独立操作。背景世界观约束：无永久不可逆的角色伤害，但不弱化手术技术难度与当下风险。

### 0.2 角色与故事功能

**Saber：**这不是「她终于承认坂口比她强」，也不是「学习团队合作」的重复课程。她本就具备出色的肝胆胰技术和成熟的手术统筹能力。这台手术体现她愿意把自己最重视的一项完整技术交到坂口手上，并作为高水平第一助手与他共同承担结果。  
**舞弥：**习惯在他人前面处理危险、习惯把自己的需要排在最后。作为患者，她不必突然变得软弱或多话；真正的转折是她能平静接受这一次的保护来自别人。  
**坂口：**主刀责任真实属于玩家。技术传授体现为高质量助手反馈，而不是让 Saber 替玩家做关键操作。  
**承接：**以 Saber Lv5《我的位置》clear 为既有 Relationship Gate；不另造主任竞争、退出、支持等语义 flag。舞弥的个人剧情不反向改写 Saber 原本已锁的 Lv3 伊莉雅／Lv5 葵相关剧情。

### 0.3 Runner 和持久状态

1. 首次传奇剧情入口需已有 Advanced 解锁、Saber Lv5 clear 及传奇术式正常资格。当前 Legendary 公共规则包含已完成普通高级手术数至少 5 台（required_regular_clears = 5）；**这是既存公共条件，不再叠加独立新 Gate**。
2. FIRST_STORY：固定 Saber 第一助手；第二助手照现行高级手术团队选人规则。REPLAY：第一、第二助手均按现有选人规则，不强迫 Saber 回队。
3. 首次成功：按现行 Runner **Day3 先原子结算为 CLEARED、发放奖励及返场资格，再播放成功专属 G–I**；奖励只写一次。首次 Day2 失败：Day3 原子结算为 **FAILED_LOCKED**，仅播放公共失败模板，不能正式再挑战；安全存档读取属于现有存档行为。返场失败时仍保留 **CLEARED**，不重播首次成功剧情；不加三次精密失败直接中止。
4. 精密阶段失败后：若本次直接成功，或精密失败但助手救援成功，都播放正常 POST；若救援失败而本台尚未终止，跳过成功型 POST 继续；危机尚未结算时暂停 POST；终止时不播放。
5. 同一运行会话内 Day2 短过场不重放。读取术前安全存档重新开始时正常重播，**不持久化过场游标**。
6. 术中只允许工程内存快照测试；玩家持久存档在现有安全边界验证时间、数值、奖励，不保存阶段、策略或术中进度。
7. 返场严格使用现行 **Advanced Referral V2**：每周一双槽、独立有放回抽取已符合返场资格的普通 Advanced 与传奇术式，且首次本周一才结算的病例不在当天抽取池；**绝不引入旧版 FIFO**。是否存在其他冷却规则由当前 V2 引擎判定，不把 V1.0 的 14 天冷却硬编码回来。类别是 LEGENDARY_STORY，不改变普通 Advanced 的全局参数、危机公式或其他术式数据。

---

## 1. WH01–WH18 手术阶段

**数据口径：**下表时间、HP、八个 Precision 难度与失败附加 HP 已通过 V1.1 数值审查，作为本术式的**锁定交付值**；不改公共 Precision / Rescue 公式。HP 栏不包含技能差过载税、S 策略额外 1 HP、随机精密失误和危机损失。stress 仅定义 low／medium／high 供危机 resolver 使用，不直接扣 Stability；真正的四维生理增量见 §1.1。

| ID | kind | 阶段标题／英文 | min | HP | P 难度 | P 失败附加 HP | specialty_tag | stress |
|---|---|---|---:|---:|---:|---:|---|
| WH01 | F | 手术核对与开腹／Time-out and Open Abdominal Entry | 20 | 1 | — | — | hepatopancreatobiliary | low (0) |
| WH02 | L | 探查与扩展 Kocher 游离／Exploration and Extended Kocher Mobilization | 35 | 2 | — | — | hepatopancreatobiliary | low (1) |
| WH03 | L | 肝十二指肠韧带与胆道暴露／Hepatoduodenal Ligament and Biliary Exposure | 38 | 2 | — | — | hepatopancreatobiliary | medium (2) |
| WH04 | L | 网膜囊与门肠静脉暴露／Lesser Sac and Portomesenteric Venous Exposure | 38 | 2 | — | — | vascular | medium (2) |
| WH05 | S | 切除界面与血管预控策略／Resection Plane and Vascular Readiness Strategy | 30 | 2 | — | — | vascular | medium (3) |
| WH06 | P | PV/SMV 精细游离及血管预控／Precise PV/SMV Dissection and Vascular Control | 50 | 4 | 92 | 14 | vascular | high (4) |
| WH07 | F | 胆道与胃肠断端准备／Biliary and Gastrointestinal Division Preparation | 37 | **1** | — | — | hepatopancreatobiliary | medium (3) |
| WH08 | P | 胰颈离断与钩突精细解剖／Pancreatic Neck Division and Uncinate Dissection | 55 | 5 | 95 | 15 | microdissection | high (4) |
| WH09 | P | 肿瘤及受累静脉段整块切除／En Bloc Tumor and Venous Segment Resection | 60 | 5 | 97 | 17 | vascular | high (5) |
| WH10 | S | 间置移植物测量与路径策略／Interposition Graft Sizing and Route Strategy | 32 | 2 | — | — | vascular | high (4) |
| WH11 | P | SMV—移植物尾端吻合／SMV-to-Graft Caudal Anastomosis | 43 | 5 | 97 | 17 | vascular | high (5) |
| WH12 | P | 移植物—PV 头端吻合与复灌／Graft-to-PV Cranial Anastomosis and Reperfusion | 45 | **5** | 98 | 18 | vascular | high (5) |
| WH13 | F | 消化道重建交接与断端保护／Reconstruction Handoff and Stump Protection | 25 | **1** | — | — | reconstruction | medium (3) |
| WH14 | P | 胰肠吻合／Pancreaticojejunostomy | 55 | 5 | 96 | 16 | reconstruction | high (4) |
| WH15 | P | 胆肠吻合／Hepaticojejunostomy | 50 | 4 | 93 | 14 | reconstruction | medium (3) |
| WH16 | P | 胃肠吻合／Gastrojejunostomy | 48 | 4 | 91 | 12 | reconstruction | medium (3) |
| WH17 | S | 移植物血流与三吻合口最终核对／Graft Flow and Multi-Anastomosis Final Assessment | 37 | **2** | — | — | reconstruction | medium (3) |
| WH18 | F | 清点、引流与腹壁关闭／Counts, Drain Placement, and Abdominal Closure | 31 | 2 | — | — | hepatopancreatobiliary | medium (2) |

**节点逻辑：**WH06 建立安全控制；WH08 完成钩突周围剥离；WH09 整块切除；WH10–WH12 连续完成静脉间置与复灌（WH11 结束**还没有**恢复门静脉血流）；WH14/15/16 分别完成胰、胆、胃肠重建。各阶段均使用同一静态术野，文本承担阶段变化。

**总和验收：**18 阶段基础耗时 **729 min**、基础 HP **54**；全部选 B 时策略增量 0，全部选 A 时额外 +41 min、+3 HP，即不计危机与精密意外的 **770 min / 57 HP**。Skill 90 自操全部 P 节点还会按公共公式产生 +8 HP 确定性过载消耗，变异局 WH02 再额外 -4 HP；这些都不属于 54 HP 的阶段基础合计。

### 1.1 已批准的 18 阶段生理效果与 7 条条件效果

**来源：**经 Codex V1.1 60,000 次／组模拟、Godot Headless 交叉校验，并用无变异／无危机的 BBB、BBA 两条 18/18 阶段确定性轨迹重新复核。此表与上表同属本术式完整数值定义，**必须随 procedure 一起落地**；不能只导入 54 HP 而遗失条件效果。基本值依序应用，条件判定于该阶段基础效果之后、S 选项效果之前；S 策略效果再一次应用。所有字段使用现有生理状态与 clamp 规则。

| 阶段 | 基础 Stability | 基础 Visibility | 基础 Bleeding | 基础 Blood Loss | 条件效果（在该阶段基础效果后判定） |
|---|---:|---:|---:|---:|---|
| WH01 | 0 | -4 | +1 | +2 | — |
| WH02 | -2 | -5 | +2 | +3 | — |
| WH03 | -3 | -8 | +2 | +4 | — |
| WH04 | -3 | -9 | +2 | +5 | — |
| WH05 | -2 | 0 | 0 | +1 | — |
| WH06 | -5 | -6 | +3 | +7 | Visibility < 75 → Stability -4, Bleeding +1, Blood Loss +4 |
| WH07 | -2 | +2 | -1 | +3 | — |
| WH08 | -7 | -6 | +3 | +9 | Visibility < 74 → Stability -5, Bleeding +1, Blood Loss +5；之后检查 WH_C1 |
| WH09 | -8 | -5 | +3 | +10 | Visibility < 68 → Stability -4, Blood Loss +5 |
| WH10 | -2 | +2 | -2 | +2 | — |
| WH11 | -7 | -4 | +2 | +8 | Visibility < 73 → Stability -4, Bleeding +1, Blood Loss +5 |
| WH12 | -8 | -4 | +3 | +10 | Bleeding ≥ 19 → Stability -5, Blood Loss +6；之后检查 WH_C2 |
| WH13 | +2 | +5 | -3 | +2 | — |
| WH14 | -6 | -5 | +2 | +6 | Visibility < 61 → Stability -4, Bleeding +1, Blood Loss +4 |
| WH15 | -5 | -3 | +1 | +5 | — |
| WH16 | -5 | -3 | +1 | +4 | — |
| WH17 | -2 | +4 | -2 | +2 | —；结算 S 选项后检查 WH_C3 |
| WH18 | +1 | +4 | -3 | +1 | Bleeding ≥ 16 → Stability -4, Blood Loss +4 |

**精确阈值说明：**BBB 与 BBA 在无变异、无危机的 WH16 末同为 Stability 11、Bleeding 23；WH17 结算后分别为 (10, 21) 与 (14, 19)；WH18 基础效果后 Bleeding 分别为 **18** 与 **16**，二者**均触发** WH18 的 Bleeding ≥ 16 条件罚。BBA 的额外价值主要在 WH17 之后的 WH_C3：Stability 14 可承受一次 -12 的危重危机处理失误而不立即归零，BBB 的 10 则不能。**不得误写成 BBA 可以避免关腹条件惩罚。**

**机制约束：**Visibility / Bleeding 不直接修改 Precision 成功率或危机触发率，而是通过上述 conditional_effects 影响后续 Stability、Bleeding、Blood Loss。公共生理公式、全局风险概率、奖励倍率不修改。高级／传奇当前没有按术后 S/A/B/C/F 质量评级增减奖励的路径；策略分钟数仍需真实显示和记账，但不可编造额外的时间评分惩罚。

---

## 2. 三个 S 阶段：玩家明确选择

所有选项均为真实合理的「标准处理」与「加强确认」之间的取舍。不能出现以危险捷径节省时间的角色价值暗示。所有额外 HP 都是**策略成本**，不得冒充 Precision 或危机损失。增量相对上表 stage base 单次应用。

### WH05：切除界面与血管预控策略

| | 选项 A | 选项 B |
|---|---|---|
| 中文 | 分段扩展暴露与血管预控 | 标准暴露与关键点确认 |
| English | Staged Exposure and Vascular Control | Standard Exposure and Key Checks |
| 说明 CN | 在完成标准术前影像核对后，沿待切除静脉段两端继续分段暴露，逐段验证预控位置，减少最深处分离时的盲区。 | 完成充分标准暴露，按术前标记确认上下游血管控制点，避免无必要的额外分离。 |
| Description EN | After standard imaging review, extend exposure in stages along both ends of the planned venous resection and confirm control sites to reduce blind dissection. | Complete standard exposure and confirm proximal and distal control sites against the preoperative map without unnecessary additional dissection. |
| 附加成本 | +12 min；+1 HP | +0 min；+0 HP |
| 额外效果 | **Visibility +10** | Visibility +1 |

### WH10：间置移植物测量与路径策略

| | 选项 A | 选项 B |
|---|---|---|
| 中文 | 加强移植物试置及无张力复核 | 标准测量与方向标记 |
| English | Extended Graft Fit and Tension Assessment | Standard Graft Sizing and Orientation |
| 说明 CN | 两端间距测量后，再次模拟移植物走行、吻合角度和张力，增加操作时间以换取更明确的视野。 | 以已测量的缺损长度、走行和标记为依据，完成常规尺寸及方向确认，迅速进入吻合。 |
| Description EN | Reassess the graft route, alignment, and freedom from tension after measuring the defect, using more operative time for a clearer working field. | Confirm standard graft length, course, and orientation from the measured defect and proceed directly to anastomosis. |
| 附加成本 | +14 min；+1 HP | +0 min；+0 HP |
| 额外效果 | **Visibility +8；Bleeding −2** | Visibility +1 |

### WH17：血流与三吻合口最终核对

| | 选项 A | 选项 B |
|---|---|---|
| 中文 | 扩展血流及三吻合口复核 | 标准血流及吻合复核 |
| English | Extended Flow and Anastomosis Review | Standard Flow and Anastomosis Review |
| 说明 CN | 标准核对完成后，额外复查移植物血流与三处消化道吻合口的局部情况，增加时间和团队操作负担。 | 完成常规移植物通畅性与三处吻合口核对，未见异常即进入关闭准备。 |
| Description EN | After standard checks, extend the review of graft flow and all three digestive anastomoses at the cost of additional time and team effort. | Complete the required checks of graft patency and all three anastomoses, then prepare for closure if no concern remains. |
| 附加成本 | +15 min；+1 HP | +0 min；+0 HP |
| 额外效果 | **Stability +5；Bleeding −2** | Stability +1 |

所有未明确列出的策略增量为零。上述增益已通过 V1.1 数值审查，不能在导入时自行改回 V1.0 数字；效果字段映射现有合法生理属性，不改变游戏公式。A 均额外消耗 1 HP，分别增加 12／14／15 min；B 均没有额外 HP 或时间。**Skill 90／91 的总体固定策略胜率以 BBB 为优，Skill 100 的 ABB 略优，这是经接受的资源取舍，不要求 A/B 各组合等概率胜利。**

### 危机检查点

| 检查点 | 位置 | 风险主题（剧情提示，并非锁定危机类型） |
|---|---|---|
| WH_C1 | WH08 精密阶段结束后 | 深部解剖与血管邻近操作后的综合状况 |
| WH_C2 | WH12 重建复灌后 | 移植物通畅、循环与复灌后的综合状况 |
| WH_C3 | **WH17 最终血流／三吻合口核对及策略结算后** | 最后复核窗口的出血、循环与稳定性评估；危机完全处理后才播成功 POST，随后进入 WH18 关腹 |

**概率与代价：**完全调用当前生理状态、团队与随机值驱动的危机 resolver；不承诺固定百分比或固定 HP。若旧草稿出现 18%／27%／20%、9／12／10 HP，只作为平衡参考，不进 runtime。

---

## 3. 全阶段通用对白（每阶段 2 PRE + 1 POST）

**字段约定：**每行均按「唯一 ID｜speaker_role｜CN｜EN」。全局角色位置用运行时 roster 绑定，不凭空指定台词说话者。PRE 为进入阶段前的短对白；POST 为阶段成功或救援成功后的确认。S 阶段 POST 只确认该阶段计划完成，**不暗示策略 A/B 中任一分支被选**。在危机结算前暂停 POST。

### WH01：核对、开腹
- **WH01_PRE01｜circulating_primary**｜CN「患者久宇舞弥，术式与影像核对完毕。静脉重建材料已确认。」｜EN “Patient: Maiya Hisau. Procedure and imaging verified. Venous reconstruction material confirmed.”
- **WH01_PRE02｜lead_surgeon**｜CN「今天不是单纯切除。切除边界和重建路线，一开始就要在同一张图上。」｜EN “This is more than a resection. We need the resection margins and reconstruction route on the same map from the start.”
- **WH01_POST01｜scrub_primary**｜CN「开腹完成，牵开器固定。术野可以展开。」｜EN “Abdominal entry complete. Retractors secured. The field is ready.”

### WH02：探查与 Kocher 游离
- **WH02_PRE01｜lead_surgeon**｜CN「先做系统探查，再充分游离十二指肠。我要看到实际病灶关系。」｜EN “Systematic exploration first, then adequate duodenal mobilization. I want the actual relationships in view.”
- **WH02_PRE02｜assistant_2**｜CN「影像所见和目前触及的界面基本一致。深部还有一段需要暴露。」｜EN “The visible planes broadly match the imaging. We still need to expose the deeper portion.”
- **WH02_POST01｜scrub_secondary**｜CN「Kocher 游离完成，后方界面已开放。」｜EN “Kocher mobilization complete. The posterior plane is exposed.”

### WH03：胆道暴露
- **WH03_PRE01｜lead_surgeon**｜CN「确认肝门结构。胆道、动脉和静脉的关系不能靠印象判断。」｜EN “Identify the hilar anatomy. We cannot rely on assumptions about the bile duct, artery, or vein.”
- **WH03_PRE02｜scrub_primary**｜CN「细分离器械和血管带备妥。」｜EN “Fine dissection instruments and vessel loops are ready.”
- **WH03_POST01｜assistant_2**｜CN「胆道及邻近血管关系已经分清，下一步可以打开网膜囊。」｜EN “The biliary and adjacent vascular anatomy is defined. We can proceed to the lesser sac.”

### WH04：门肠静脉暴露
- **WH04_PRE01｜lead_surgeon**｜CN「沿胰颈后方找到静脉轴，先核对上下游，再谈切除长度。」｜EN “Identify the venous axis behind the pancreatic neck. Confirm both ends before deciding the resection length.”
- **WH04_PRE02｜circulating_secondary**｜CN「术前血管重建图已调到对照位置。」｜EN “The preoperative vascular reconstruction map is on display for comparison.”
- **WH04_POST01｜assistant_2**｜CN「PV/SMV 两端可辨，预定间置段的位置清楚了。」｜EN “Both ends of the PV/SMV segment are identifiable. The planned interposition site is clear.”

### WH05：预控策略
- **WH05_PRE01｜lead_surgeon**｜CN「现在决定暴露到什么程度。之后进入深处分离，就不能频繁换计划。」｜EN “We decide the extent of exposure now. Once deep dissection begins, frequent changes of plan are costly.”
- **WH05_PRE02｜scrub_primary**｜CN「标准血管预控和扩展暴露两套器械都备好了。」｜EN “Both standard vascular-control and extended-exposure instruments are ready.”
- **WH05_POST01｜circulating_primary**｜CN「血管控制计划确认，策略记录完成。」｜EN “The vascular-control plan is confirmed and recorded.”

### WH06：血管精细游离
- **WH06_PRE01｜lead_surgeon**｜CN「这段静脉必须分离得足够清楚，但多剥一毫米也没有价值。」｜EN “We need a fully defined venous segment, but an extra millimeter of needless dissection gains us nothing.”
- **WH06_PRE02｜scrub_primary**｜CN「无损伤血管夹、细线与冲洗准备完毕。」｜EN “Atraumatic clamps, fine sutures, and irrigation are ready.”
- **WH06_POST01｜assistant_2**｜CN「静脉预控稳定，切除段已能独立辨认。」｜EN “Venous control is stable, and the planned resection segment is clearly defined.”

### WH07：消化道与胆道断端准备
- **WH07_PRE01｜lead_surgeon**｜CN「先规划每个断端。切掉之后，重建不能留下靠猜的位置。」｜EN “Plan each division point now. Once the specimen is out, reconstruction must not depend on guesswork.”
- **WH07_PRE02｜scrub_secondary**｜CN「断端标记、保护材料和标本袋已备齐。」｜EN “Stump markers, protective materials, and the specimen bag are ready.”
- **WH07_POST01｜scrub_primary**｜CN「胆道和胃肠断端已按计划准备，可以进入深部切除。」｜EN “Biliary and gastrointestinal division points are prepared as planned. Deep resection can proceed.”

### WH08：胰颈与钩突
- **WH08_PRE01｜lead_surgeon**｜CN「胰颈之后是钩突。贴近血管的这一层，视野比速度重要。」｜EN “After the pancreatic neck comes the uncinate process. At the vascular interface, vision matters more than speed.”
- **WH08_PRE02｜anesthesia**｜CN「循环参数可维持，目前允许继续精细分离。」｜EN “Hemodynamics remain supportable. Fine dissection can continue.”
- **WH08_POST01｜assistant_2**｜CN「胰颈及钩突界面完成，肿瘤连同静脉受累段已具备整块切除条件。」｜EN “The pancreatic neck and uncinate plane are complete. The tumor and involved vein are ready for en bloc resection.”

### WH09：整块切除
- **WH09_PRE01｜lead_surgeon**｜CN「按既定边界一并取出，不能为了省一步而拆开病灶与静脉界面。」｜EN “Remove the specimen within the planned boundaries. We cannot split the tumor from the venous interface merely to save a step.”
- **WH09_PRE02｜anesthesia**｜CN「血管阻断窗口已经开始。请明确报告预计恢复血流的时间。」｜EN “The vascular-clamp window has begun. Please keep us informed of the expected time to reperfusion.”
- **WH09_POST01｜scrub_primary**｜CN「整块标本已移出。两端静脉断口保护完成，立即转入重建。」｜EN “The en bloc specimen is out. Both venous ends are protected. Moving immediately to reconstruction.”

### WH10：移植物试置
- **WH10_PRE01｜lead_surgeon**｜CN「缺损已经确定。确认长度、方向、张力，吻合时才有余地。」｜EN “Now the defect is defined. Confirm length, orientation, and tension so we have room to work during anastomosis.”
- **WH10_PRE02｜scrub_secondary**｜CN「移植物与方向标记已送入无菌台。」｜EN “The graft and orientation marks are on the sterile field.”
- **WH10_POST01｜scrub_primary**｜CN「移植物尺寸与走行确认完毕，可开始尾端吻合。」｜EN “Graft dimensions and course confirmed. Ready for the caudal anastomosis.”

### WH11：尾端吻合
- **WH11_PRE01｜lead_surgeon**｜CN「先处理 SMV 端。缝合视线要始终看得到后壁。」｜EN “We start at the SMV end. Keep the posterior wall continuously visible during suturing.”
- **WH11_PRE02｜scrub_primary**｜CN「血管缝线、放大镜视野和持续湿润已经准备好。」｜EN “Vascular sutures, magnified view, and continuous moistening are ready.”
- **WH11_POST01｜assistant_2**｜CN「尾端吻合完成。头端仍待完成，门静脉血流尚未恢复。」｜EN “The caudal anastomosis is complete. The cranial end remains open; portal flow has not yet been restored.”

### WH12：头端吻合与复灌
- **WH12_PRE01｜lead_surgeon**｜CN「最后一圈之前再看轴向。复灌以后，再纠正扭曲就迟了。」｜EN “Check the graft axis before the final stitches. Correcting a twist after reperfusion would be too late.”
- **WH12_PRE02｜anesthesia**｜CN「准备配合放夹与循环监测。请提前报复灌时点。」｜EN “Ready to coordinate clamp release and hemodynamic monitoring. Call out before reperfusion.”
- **WH12_POST01｜assistant_2**｜CN「头端吻合与逐步复灌完成，移植物走行及血流已初步确认。」｜EN “The cranial anastomosis and controlled reperfusion are complete. Graft course and flow have passed the initial check.”

### WH13：交接与断端保护
- **WH13_PRE01｜lead_surgeon**｜CN「血流恢复不是终点。现在回到三个消化道重建断端。」｜EN “Restoring flow is not the finish line. We now return to the three digestive reconstruction sites.”
- **WH13_PRE02｜scrub_secondary**｜CN「胰管、胆管和空肠断端保护完整，重建器械已更新。」｜EN “Pancreatic, biliary, and jejunal ends remain protected. Reconstruction instruments are set.”
- **WH13_POST01｜circulating_primary**｜CN「静脉段阶段已交接，消化道重建准备完成。」｜EN “The venous phase is handed over. Digestive reconstruction is ready.”

### WH14：胰肠吻合
- **WH14_PRE01｜lead_surgeon**｜CN「先看胰管口径和断面质量。这个吻合允许慢，不允许含糊。」｜EN “Assess the duct diameter and cut-surface quality first. We can be slow here, but we cannot be imprecise.”
- **WH14_PRE02｜scrub_primary**｜CN「胰管定位和精细缝合器械就位。」｜EN “Duct alignment and fine anastomotic instruments are in place.”
- **WH14_POST01｜assistant_2**｜CN「胰肠吻合完成，局部张力和吻合口形态已检查。」｜EN “Pancreaticojejunostomy is complete. Local tension and anastomotic geometry have been checked.”

### WH15：胆肠吻合
- **WH15_PRE01｜lead_surgeon**｜CN「确认胆管壁与肠管方向。不要让前一个吻合牵扯这里的角度。」｜EN “Check the bile duct wall and bowel orientation. The previous anastomosis must not distort this one.”
- **WH15_PRE02｜scrub_secondary**｜CN「吻合口周围清洁，细线和冲洗备妥。」｜EN “The site is clean. Fine sutures and irrigation are ready.”
- **WH15_POST01｜scrub_primary**｜CN「胆肠吻合完成，管腔通畅及张力检查通过。」｜EN “Hepaticojejunostomy is complete. Patency and tension checks passed.”

### WH16：胃肠吻合
- **WH16_PRE01｜lead_surgeon**｜CN「重建的最后一处。确认肠袢没有扭转，再决定吻合位置。」｜EN “The last reconstruction. Confirm that the bowel limb has no twist before choosing the anastomotic site.”
- **WH16_PRE02｜assistant_2**｜CN「输入与输出肠袢方向已重新核对。」｜EN “The afferent and efferent limbs have been rechecked for orientation.”
- **WH16_POST01｜scrub_primary**｜CN「胃肠吻合完成。三处消化道重建均已建立。」｜EN “Gastrojejunostomy is complete. All three digestive anastomoses are in place.”

### WH17：最终复核策略
- **WH17_PRE01｜lead_surgeon**｜CN「现在按计划逐项核对血流和吻合口。不能因为离结束很近就省略确认。」｜EN “Now we check flow and every anastomosis against the plan. Being close to the finish is no reason to skip verification.”
- **WH17_PRE02｜anesthesia**｜CN「全程循环记录已汇总，等待最后的复核结果。」｜EN “The hemodynamic record is consolidated. Awaiting the final review.”
- **WH17_POST01｜circulating_primary**｜CN「最终复核记录完毕，允许进入清点与关闭流程。」｜EN “Final verification documented. Cleared for counts and closure.”

### WH18：清点与关闭
- **WH18_PRE01｜scrub_primary**｜CN「器械和纱布清点开始。引流与关闭材料齐备。」｜EN “Instrument and sponge counts are beginning. Drains and closure materials are ready.”
- **WH18_PRE02｜lead_surgeon**｜CN「确认所有记录一致，再关腹。」｜EN “Match every record before abdominal closure.”
- **WH18_POST01｜circulating_secondary**｜CN「最终清点一致，腹壁关闭完成。手术记录进入结算。」｜EN “Final counts reconcile. Abdominal closure is complete. The case is ready for settlement.”

---

## 4. 第一助手对白：首次 Saber 专属／返场通用

**分流契约：**下列文本采用 speaker_role = assistant_1。FIRST_STORY 强制选用 SABER 支线，角色显示由系统绑定 Saber；REPLAY **只使用 GENERIC 支线**，即使玩家恰好又选 Saber，也不能重放传授、交托或个人关系对白。普通版不是低水平助手，而是合格手术团队的实务协作。每阶段至少 1 条，关键阶段另有短 POST。若未解决精密失败与危机，不播放成功 POST。

| 阶段 | FIRST_STORY：Saber（CN / EN） | REPLAY：通用助手（CN / EN） |
|---|---|---|
| WH01 | **AS01_S_PRE**「坂口君，今天由你掌握整个节奏。我在这里接住你的每一个决定。」／“Sakaguchi, you set the pace of this entire operation. I am here to support each decision you make.” | **AS01_G_PRE**「第一助手就位。需要调整牵引或视角，直接告诉我。」／“First assistant in position. Tell me whenever you need traction or a change of view.” |
| WH02 | **AS02_S_PRE**「影像告诉我们应该看到什么；真正的游离，仍要由术野回答。」／“Imaging tells us what we expect to see. The field itself must answer what can actually be mobilized.” | **AS02_G_PRE**「后方界面由我协助牵开，主刀可以集中探查。」／“I will maintain posterior exposure so the lead surgeon can focus on exploration.” |
| WH03 | **AS03_S_PRE**「先辨明每条结构，再安排动作。这个顺序，我从不妥协。」／“Identify every structure before planning each move. I never compromise on that order.” | **AS03_G_PRE**「肝门区牵引稳定，解剖层次清楚。」／“Hilar retraction is stable. The anatomy is well defined.” |
| WH04 | **AS04_S_PRE**「看清上下游。等走到必须阻断的那一步，你会感谢现在花的时间。」／“Define both ends. When clamping becomes necessary, you will be glad you spent the time now.” | **AS04_G_PRE**「静脉两端的暴露角度已经调整。」／“Exposure has been adjusted at both ends of the vein.” |
| WH05 | **AS05_S_PRE**「两种策略都能成立。你选哪一个，我便按那个方案配合。」／“Both strategies are valid. Whichever you choose, I will work to that plan.” | **AS05_G_PRE**「预控器械可以配合标准或扩展暴露，请主刀选择。」／“Control instruments are ready for either standard or extended exposure. Your choice.” |
| WH06 | **AS06_S_PRE**「我来维持近端视野。你只需告诉我，哪一层还不够清楚。」／“I will maintain the proximal view. Tell me which layer still needs clarification.” | **AS06_G_PRE**「近端控制与对侧牵引就位，主刀可开始精细分离。」／“Proximal control and contralateral traction are ready. Fine dissection may begin.” |
| WH07 | **AS07_S_PRE**「每个断端都是之后的责任。标记做好，后面的手术会顺得多。」／“Every divided end becomes a responsibility later. Good marking makes the reconstruction far more orderly.” | **AS07_G_PRE**「断端方向已标记，重建顺序已核对。」／“Stump orientation is marked and reconstruction order checked.” |
| WH08 | **AS08_S_PRE**「这一层最容易让人急躁。坂口君，宁可停住，也不要猜下一刀。」／“This is where impatience becomes dangerous. Sakaguchi, pause if needed; never guess at the next cut.” | **AS08_G_PRE**「钩突深部已有清晰牵引，关键血管在视野内。」／“The deep uncinate plane is under clear traction, with the key vessels visible.” |
| WH09 | **AS09_S_PRE**「舞弥不会听见我们的讨论了。但我们约定过，要把完整的选择带到这一刻。」／“Maiya cannot hear this discussion now. But we agreed to bring a complete plan to this moment.” | **AS09_G_PRE**「标本边界与血管夹位置再次确认，准备整块切除。」／“Specimen margins and clamp positions reconfirmed. Ready for en bloc resection.” |
| WH10 | **AS10_S_PRE**「我替你托住移植物。长度、方向和张力，由你来作最后判断。」／“I will hold the graft for you. The final judgment on length, orientation, and tension is yours.” | **AS10_G_PRE**「移植物支持到位，可以核对两端距离。」／“The graft is supported and ready for end-to-end measurements.” |
| WH11 | **AS11_S_PRE**「我给你稳定的后壁视野。第一针怎么落，由你决定。」／“I will keep the posterior wall steady and visible. You decide where the first stitch goes.” | **AS11_G_PRE**「SMV 端已摆正，后壁可以连续观察。」／“The SMV end is aligned. The posterior wall remains visible.” |
| WH12 | **AS12_S_PRE**「这一步以后，血流将重新经过我们共同建立的通道。准备好了就告诉我。」／“After this step, flow will return through the channel we have built together. Tell me when you are ready.” | **AS12_G_PRE**「头端张力、轴向与放夹顺序已经核对。」／“Cranial tension, axis, and clamp-release sequence are verified.” |
| WH13 | **AS13_S_PRE**「最紧张的一段过去了。接下来不要急着松一口气——我们还有三处吻合。」／“The most tense phase is behind us. Not time to relax—we still have three anastomoses.” | **AS13_G_PRE**「静脉重建区保持保护，准备转向消化道断端。」／“The venous reconstruction remains protected as we turn to the digestive stumps.” |
| WH14 | **AS14_S_PRE**「胰管很细，也足够决定一台大手术的后半程。让我把牵引调轻一些。」／“The pancreatic duct is small, yet it can determine the second half of a major operation. I will ease the traction.” | **AS14_G_PRE**「胰管与空肠壁已对位，可以开始精细吻合。」／“The pancreatic duct and jejunal wall are aligned for fine anastomosis.” |
| WH15 | **AS15_S_PRE**「新的肠袢方向要再看一遍。正确的针脚，也需要正确的角度。」／“Check the new bowel-limb orientation once more. Even the right stitch needs the right angle.” | **AS15_G_PRE**「胆管与肠袢位置稳定，吻合视野清楚。」／“The bile duct and bowel limb are stable, with a clear anastomotic field.” |
| WH16 | **AS16_S_PRE**「最后一个吻合口，我们也按第一个的标准来做。」／“We will hold the last anastomosis to the same standard as the first.” | **AS16_G_PRE**「肠袢扭转检查完成，下一吻合位已标定。」／“The bowel limb has been checked for twisting; the anastomotic site is marked.” |
| WH17 | **AS17_S_PRE**「我知道你已想看见结束了。但现在，该由记录和术野证明我们做对了。」／“I know you want to see the finish. Now the record and the field must prove that the work is sound.” | **AS17_G_PRE**「最终复核清单在手，血流与三处吻合口逐项核对。」／“Final checklist ready. Reviewing graft flow and all three anastomoses item by item.” |
| WH18 | **AS18_S_PRE**「最后一针也由你完成。今天这台手术，应该完整地属于你的记录。」／“The final stitch is yours as well. This operation should be complete in your own record.” | **AS18_G_PRE**「清点一致后可以关闭，我配合主刀完成收尾。」／“We can close once counts agree. I will assist the lead surgeon through the finish.” |

### 4.1 六个关键阶段的第一助手 POST 差分

| 阶段 | FIRST_STORY：Saber（CN / EN） | REPLAY：通用助手（CN / EN） |
|---|---|---|
| WH06 | **AS06_S_POST**「分离干净，而且预控始终在手。很好。」／“Clean dissection, with control maintained throughout. Well done.” | **AS06_G_POST**「血管预控核对完成。」／“Vascular control verified.” |
| WH09 | **AS09_S_POST**「标本完整取出了。下一段，我们接着做。」／“The specimen is out intact. Let us continue to the next phase.” | **AS09_G_POST**「标本交接完成，准备重建。」／“Specimen handed off. Preparing reconstruction.” |
| WH11 | **AS11_S_POST**「尾端吻合可靠。继续保持这个针距。」／“The caudal anastomosis is sound. Keep that suture spacing.” | **AS11_G_POST**「尾端完成，转向头端。」／“Caudal end complete. Moving to the cranial end.” |
| WH12 | **AS12_S_POST**「血流恢复了。坂口君，先把这个结果确认下来。」／“Flow has returned. Sakaguchi, let us verify this result before moving on.” | **AS12_G_POST**「复灌后初步血流检查通过。」／“Initial flow check passed after reperfusion.” |
| WH14 | **AS14_S_POST**「胰肠吻合完成。你没有让整台手术的重量压乱这一处细节。」／“Pancreaticojejunostomy complete. You did not let the weight of the whole operation compromise this detail.” | **AS14_G_POST**「吻合口形态复核完成。」／“Anastomotic geometry verified.” |
| WH17 | **AS17_S_POST**「全部复核结束。现在，我可以安心把最后的步骤也交给你。」／“All checks are complete. I can entrust the final steps to you with confidence.” | **AS17_G_POST**「最终复核通过，准备关闭。」／“Final review passed. Preparing closure.” |

**审稿警戒：**Saber 在这里并非「评分员」或「把自己置于主刀之上」。她作为熟练第一助手给出专业、有温度但简练的协作回应；真正的人物关系落点留给 Day3。

### 4.2 Codex 阶段对白组装顺序（已批准）

1. **WH02–WH17** 的 before_action 固定为：[WHxx_PRE01（坂口 lead_surgeon）→ ASxx_S_PRE（首次 Saber，或 ASxx_G_PRE 返场）→ WHxx_PRE02（相应团队角色）]。
2. **WH01 与 WH18** 的主刀台词位于 PRE02，因此固定为：[WHxx_PRE01（核对／清点团队）→ WHxx_PRE02（坂口主刀）→ ASxx_S_PRE／ASxx_G_PRE（第一助手回应）]，不能把 Saber 的回应硬塞在主刀发言前。
3. after_resolution：先播原 WHxx_POST01，再按对应阶段额外追加 ASxx_S_POST／ASxx_G_POST（仅 WH06、09、11、12、14、17），均只在正常成功或救援成功后播放。发生危机时，**先完整解决危机，再播放该阶段成功 POST**；手术终止则不播。
4. 任一阶段的 PRE 为恰好 3 句；POST 为 1–2 句，总计 4–5 句，符合现有 Advanced Operative Dialogue 校验器。P_FAIL 的单句反馈只能在实际首次 Precision 判定失败时触发，不影响 rescue 机制与助手配额。

---

## 5. 八个 P 阶段的专属精密失败回应

以下文本只在该阶段 **Precision 初次判定失败**时出现。之后由现有助手救援和手术继续／终止机制接管。它们不预告救援是否成功，不与通用失败模板抢触发，也不应被解读成不可逆损伤。

| 阶段 | 角色 | CN | EN |
|---|---|---|---|
| WH06 — P_FAIL | assistant_1 | 「等一下，静脉外膜的层次偏了。先停住，重建视野。」 | “Hold. We have drifted off the venous adventitial plane. Pause and restore the view.” |
| WH08 — P_FAIL | assistant_2 | 「钩突深部的分离点没有完全显露，继续会失去参照。」 | “The deep uncinate dissection point is not fully exposed. Continuing would cost us our reference.” |
| WH09 — P_FAIL | assistant_1 | 「整块切除的静脉边界没对齐。先核对夹持位置。」 | “The venous boundary of the en bloc resection is misaligned. Recheck the clamp positions.” |
| WH11 — P_FAIL | assistant_1 | 「尾端吻合的后壁针距不均，先检查再继续。」 | “The caudal posterior-wall suture spacing is uneven. Check it before proceeding.” |
| WH12 — P_FAIL | assistant_2 | 「头端吻合的轴向不够理想。复灌前必须重新确认。」 | “The cranial anastomosis is not aligned well enough. We must reassess it before reperfusion.” |
| WH14 — P_FAIL | assistant_1 | 「胰管与肠壁的对位偏了，不能直接把这一针收紧。」 | “The pancreatic duct and jejunal wall are slightly misaligned. Do not tighten that stitch yet.” |
| WH15 — P_FAIL | assistant_2 | 「胆肠吻合的边缘张力不一致，先把牵引调回来。」 | “Tension along the hepaticojejunostomy edge is uneven. Readjust the traction first.” |
| WH16 — P_FAIL | assistant_1 | 「胃肠吻合口的方向出现偏差。先确认肠袢没有旋转。」 | “The gastrojejunostomy orientation has shifted. Check the bowel limb for rotation.” |

### 5.1 危机对白与 POST 的组合

- 危机具体类型由现有 resolver 产生。若危机种类不确定，不预写「大出血」「休克」等必然发生的台词；由公共类型映射给出演出。
- 可使用不指向特定危机的短台词：**CRISIS_GENERIC_PRE｜anesthesia**：CN「参数有变化，先确认原因和可用余量。」／EN “The parameters are changing. Identify the cause and our remaining margin first.”
- **CRISIS_GENERIC_CLEAR｜anesthesia**：CN「这一轮处理完成，重新评估后可继续。」／EN “That response is complete. We may continue after reassessment.”
- 以上是可选辅助的**通用短句**。若现有危机演出已经覆盖，应避免重复播报；不为本术式新增自定义概率、固定 HP 或额外危机状态。

---

## 6. FIRST_STORY 三日剧情功能概述（正式逐句剧本已经完成）

**正文权威性：**此节保留设计阶段的人物功能与叙事意图，**不再作为待写剧本任务，也不能替代已通过的 HOSHIMI_SABER_LEGENDARY_MAIYA_THREE_DAY_VN_V1_1.md**。若此处历史示例与 VN A–I 逐句定稿存在措辞、场景或顺序差异，一律以已通过的 VN 正文为准；不得借示例擅自增加对白。Day2 不插长 VN。剧情与医疗责任严肃相待，允许日常黑色幽默，但不拿舞弥的身体风险当玩笑。

### Day1／A：久宇舞弥来院——「我已经安排好时间」

**地点：门诊咨询室／时间：白天。**舞弥坐得端正，表情平稳，资料整理得近乎像一份任务清单。她关心的是需要请多久假、复诊次数、能否独自离院，而非为自己的命运发表感想。坂口询问她当下身体症状和生活安排，她几乎本能地把「别给人添麻烦」放进每个答复。

角色功能：
- 舞弥的能力与习惯通过有条理的问答表现，不写成失神的「悲情弱者」。
- 坂口把讨论拉回她本人的诊疗选择：她不需要替所有人规划手术后如何运转。
- 历史构思示例：「如果医院需要我自己准备交接文档，我今晚就能交。」坂口：「这次只有我们给你写交接。」（**仅供理解人物功能；不加入已批准 VN**）

### Day1／B：病例说明——「不止切掉肿瘤」

**地点：影像讨论室。**坂口、Saber、舞弥三人在场。Saber 解释约 6 cm 的胰头病灶与 PV/SMV 静脉段的特殊关系：不宜尝试「勉强剥离干净」的简单方案；此次计划联合静脉节段切除和移植物间置重建。明确说明手术主要重建步骤、全麻、耗时、可能的围手术期风险与现有医疗评估。

这段要写出：
1. 舞弥先问自己能否选择「只切肿瘤」，从操作量上理解问题；她提出问题是理性，不是害怕。
2. Saber 不炫技，她告诉舞弥「完整切除」与「恢复静脉连续性」是同一台手术的不可分割目标。
3. 坂口负责最后的解释和同意讨论，不让 Saber 代替主刀承诺结果。舞弥在理解信息后明确做出手术决定，医疗同意是可见过程。
4. 术前并非靠影像就宣称病理已 100% 确诊，可使用「倾向 SPN」并在 Day3 病理安排中保留后续确认。
5. 已批准的正式 VN 在 B22–B23_EX02 明确解释延期观察、病灶可能进展与小范围剥离为何不足以替代计划术式；**B36–B37 才是正式同意书签署动作**。不得删去补充告知或误引为 Day1 D 的签署。

### Day1／C：Saber 的交托——「这是我会做的手术」

**地点：外科副部长办公室兼术前讨论区；舞弥不在。**Saber 把详细术前规划交给坂口，明确自己在这项肝胆胰与血管重建的技术领域有经验，却主动坚持坂口担任主刀、她作为第一助手。她不会讲「我总是一个人承担一切」之类已经过时的自我总结。两人争论的是**复杂手术该如何使每个阶段可验证、可交接、可回顾**。

主题锚点示范：
- Saber：「我会将需要知道的一切告诉你。至于下一步，你必须亲自判断。」
- 坂口：「你真的放心？」
- Saber：「不。我会认真担心。那不妨碍我信任你。」  

这是信任专业搭档的成熟姿态；不写为恋爱升阶，不新增独立关系变量。

### Day1／D：最后确认——「名字写在那一栏」

**地点：术前准备办公区或病房。**舞弥看见手术排班上的主刀是坂口，Saber 为第一助手。她问一句非常实际的问题，例如血管重建中的替代方案是否已有准备。坂口确认团队已经安排好。舞弥轻轻点头，第一次把一件复杂的事情交由其他人规划，而不要求自己参与每个细节。

**时间边界：**Day1 结束于术前计划锁定。**转运床、手术帽、进入手术室与全麻诱导全部放在 Day2**，避免人物前一晚已经躺到手术室门口。

### Day2／短场景 1：转运床

**地点：病房→手术室通道。**舞弥被推往手术室，医护核对腕带与手术信息，坂口和 Saber 穿好手术服在手术室等候。舞弥注意到自己这次不能先一步进入「任务现场」替大家确认所有路径。这一轻微不适可通过一两句干净的对白表现，不做长篇内心独白。

### Day2／短场景 2：全麻过场

**地点：手术室。**麻醉团队做常规术前核对、监测和全麻诱导。舞弥最后确认自己能做的准备已经完成；画面转入麻醉后的无反应状态，再进入 18 阶段 Runner。Day2 人物演出最多为上述两个短场景和阶段对白；在 WH09–WH12 的血管阻断重建窗口**绝不插长故事**。

### Day3／首次成功——「这一次，交给你」

**开始顺序：先完成成功原子结算／奖励，再播放剧情**。场景在术后病房与 Saber/坂口的短谈之间切换，具体节奏由正式编剧调整：

1. 舞弥醒来，关心自己的术后安排；她先想确认有没有留下需要别人接手的「工作」。医护解释恢复计划，她听完后才放松下来，没必要痛哭。
2. 坂口向她准确说明手术完成情况，**不声称一夜之间病理结果全部确定**。舞弥对 Saber 说：「你在场就够了。」也可以让她先对坂口道谢，之后自然看向 Saber。
3. 两名医生单独复盘。Saber 不需要给坂口一张象征性的「合格证」；她真实谈一次术中的细节，然后承认把这一项能力交出去以后，团队得到的并非一个替代者，而是另一个可以共同担责的人。
4. 最后以平实的交接而非宣誓收束：正式剧本 I05 已使用「如果下次你主刀的病例需要我……给我留个第一助手的位置」，按 I06–I18 接续；**不再生成替代结尾**。

**Day3 禁忌：**不再争夺主任头衔；不新增「Saber 支持坂口做主任」flag；不为舞弥凭空补 Fate/Zero 死亡、复活或牺牲情节；不把复杂医疗即时完成写成永不需要随访。

### 失败与返场

- FIRST_STORY 术中失败：使用公共 Advanced 失败模板及规定的失败锁定／重开路径，不播放任何 Day3 成功专属尾声。
- REPLAY：不播放 Day1–Day3 的首次三日剧情；只保留已有返场形式、阶段对白、通用助手支线与现有手术结算反馈。此处无额外 Saber 亲密剧情。

---

## 7. 非剧情 UI 文本（中英对照）

| Key 建议 | 简体中文 | English |
|---|---|---|
| procedure_name | 复杂胰十二指肠切除联合门肠静脉重建 | Complex Pancreaticoduodenectomy with PV/SMV Reconstruction |
| procedure_full_name | 复杂胰十二指肠切除术（Whipple）联合门静脉／肠系膜上静脉节段切除与移植物间置重建 | Complex Pancreaticoduodenectomy (Whipple Procedure) with Segmental Portal–Superior Mesenteric Vein Resection and Interposition Graft Reconstruction |
| patient_name | 久宇舞弥 | Maiya Hisau |
| diagnosis_short | 胰头实性假乳头状肿瘤（倾向）伴 PV/SMV 静脉受累 | Suspected solid pseudopapillary neoplasm of the pancreatic head with PV/SMV involvement |
| case_description | 胰头约 6 cm 肿瘤，拟行整块切除，并以间置静脉移植物重建受累 PV/SMV 节段。 | Approximately 6 cm pancreatic-head tumor requiring planned en bloc resection and interposition venous-graft reconstruction of the involved PV/SMV segment. |
| entry_title | 传奇术式：这一次，交给你 | Legendary Procedure: This Time, I Entrust It to You |
| entry_locked_relationship | 需要完成阿尔托莉雅 Lv5 关系剧情。 | Complete Artoria's Lv5 relationship event. |
| entry_locked_advanced | 需要解锁高级手术系统。 | Unlock Advanced Surgery first. |
| entry_locked_schedule | 当前不满足手术排程条件。 | Current surgery scheduling requirements are not met. |
| first_story_start | 开始首次传奇病例（第一助手：阿尔托莉雅） | Begin the legendary first case (First Assistant: Artoria) |
| first_story_clear | 久宇舞弥的传奇手术已完成；该术式现可进入返场池。 | Maiya Hisau's legendary operation is complete; the procedure is now eligible for the replay pool. |
| replay_label | 传奇术式返场：门肠静脉重建 Whipple | Legendary Replay: PV/SMV Reconstruction Whipple |
| stage_complete | 当前操作完成。 | Current step completed. |

**翻译授权建议：**允许 Codex 忠实翻译遗漏的非剧情 UI、制作必要的锁定说明和短操作提示；**不得自行编写角色剧情或扩写人物对白**。中文已编写的台词和对应英文成对保留。章节标题只供策划文档，除非 UI 需要显示，不得随意生成字幕；括号内导演指示不应误当角色台词。

---

## 8. 美术资产清单与静态术野规范

### 8.1 本术式独有素材

| 素材 | 使用位置 | 交付预期 | 资源 Gate |
|---|---|---|---|
| 舞弥原作身份锚点／种子图 | 所有新绘制角色立绘参考 | **用户已有种子图；当前文档未附入文件**，正式出图须重新确认原始附件并实际作为参考输入 | 必须 |
| 舞弥常服立绘及冷静／略疲惫／释然等表情 | Day1 A/B | 可复用已有合格立绘；否则新绘 | 必须 |
| 舞弥病房／术后立绘及相应表情 | Day1 D、Day3 | 可复用但需核对服装与情境；否则新绘 | 必须 |
| Day2 转运床画面 | Day2 短过场 | 合格通用过场可复用；若有舞弥可见面部则核对身份锚点 | 必须 |
| Day2 全麻过场 | Day2 短过场 | 现有通用演出可复用；如显示舞弥面容需角色图 | 必须 |
| Saber 医生／手术服立绘及必要表情 | Day1、Day2、Day3 | 优先复用现有正式素材 | 必须 |
| **开腹 Whipple + PV/SMV 手术术野** | WH01–WH18 | **仅 1 张静态主术野图，全阶段复用**；已选定视频参考，正式适配／授权图尚待交付与验收 | 必须 |

### 8.2 静态术野的美术目标

**已锁定的视觉参考（非直接授权素材）：**用户指定采用本次检索的第一条视频 **[Portal Vein/Superior Mesenteric Vein Reconstruction after En Bloc Resection for Pancreatic Cancer — MCC Gastrointestinal Oncology Video Library](https://www.youtube.com/watch?v=Y5pwONeRWIM)** 作为手术窗口、牵开器、器械与开放血管重建环境的主要美术锚点。**视频的具体重建手法不能仅凭标题认定为本剧情的 Type IV 间置自体静脉移植物**；成品术野如需描绘两端 graft 吻合，应以已锁定 Type IV 结构另做准确适配，不能偷换成直接端端吻合或把源视频截图直接当作可发行素材。

1. 视觉主体为**上腹部开放术野，胰头／胰颈邻近门静脉—肠系膜上静脉轴**。牵开器、手术器械和周围组织关系合理；不能误用胸主动脉、心脏或腹主动脉根部的画面。
2. 最好选一幅具有**正在操作中的代表性瞬间**的术野。静态图不追踪 WH01 与 WH18 的即时解剖变化，因此画面应避免太多只有「切除前」或「缝合后」才成立的大型特征；若最终选了突出移植物的画面，须承认这是该手术的统一主题插画，不假装 18 阶段每张画面都实时成立。
3. 技术描述中的两端静脉吻合、胰肠吻合、胆肠吻合和胃肠吻合**都由阶段文本表达**。此版本**不制作切皮／主要术野／关闭三图**，也**不制作单独血管根部重建或冠脉钮吻合差分**（后者属于上一台主动脉手术范畴，不能挪用）。
4. 可以在术野之上使用公共游戏已有的箭头、阶段标题、风险指示或短动画；但不得将此理解为要开发解剖层动态系统。
5. 图片来源的医学参考必须记录来源和使用权判断；本方案不等于允许直接把 YouTube 手术视频截图作为可发行素材。

### 8.3 建议的现行术野窗口接线（以仓库真实路径为准）

- 唯一主术野：assets/surgery/fields/saber_whipple_vascular.png（正式成品验收后使用；如仓库使用不同文件名，以已导入真实资产为准）。
- 在现行 data/advanced_surgery/field_windows.json 登记本术式：after_stage = WH01，before_stage = WH18；incision_path 与 closure_path 可以复用项目现有的合法开腹／关腹公共资源。它们是 **field window 的进入／退出呈现**，不意味着为 18 阶段制作 3 张不同的主术野。
- 其他已接入术式的术野、开闭窗口、缩放、热点与图层不受影响。若当前 field_windows schema 对此配置要求不同，按现行接口接线并报告差异，不改游戏核心绘制系统。

**正式开放前：**以上必须资源齐全并通过人物身份、年龄感、比例、医疗部位、画面比例及权利审核；缺图期间可以开展游戏逻辑与占位图开发，但不得将占位资产视为验收合格。

---

## 9. Codex 实装授权与不可改动项

### 9.1 允许工程完成的工作

**明确授权：**Codex 参照当前 Advanced／Legendary 仓库 schema，**逐字段实装本 V1.1 已锁定的完整数值表**；不再重新设计基础 HP、生理增量、七条条件效果、S 收益或第三危机位置。授权范围仅限本术式数据、必要的分类／展示／术野登记、首通患者 ID 的通用解析缺陷修复，以及对应测试。不得改动其他术式数值、通用生理与危机 resolver、公共 Precision 算法、奖励公式或手术排班规则。

必须忠实接线和验证：

- **base_difficulty、training_ceiling、reward_tier、dialogue_after_rescue**：分别为 **99／100／advanced／true**，使用既有合法字段／枚举；不得硬编码模拟奖励 XP 为固定值。
- **各阶段的基础生理作用**：完整录入 §1.1 的 Stability／Visibility／Bleeding／Blood Loss 四维表和 **7 条 conditional_effects**；每阶段基础作用、条件罚与 S 选项按公共 resolver 顺序计算。
- **各阶段 stage base HP、time、P 难度与失败附加 HP**：严格按 §1 与 §1.1 录入，基础 54 HP／729 min，八个 P 难度与失败代价保持不变。若现有 schema 与设计字段存在真正矛盾，提交准确差异，**不得自行改数值**。
- **三处 S 策略**：实现中英双语选项名称、说明和增量，选择后在该阶段按现有策略接口生效**恰好一次**。
- **三处危机检查点**：固定于索引 [8, 12, 17]，依次位于 WH08／WH12／WH17 结算后；调用现有动态概率、HP 代价和团队修正；不得将文档早先的参考百分比写成强制概率。
- **八个 P 失败回应单句解析器**、教学／返场对白分流、固定首次 Saber 第一助手、三人剧情显示、策略额外 HP 扣费和返场资格：这些属于已授权的工程实现，不要求编剧回填额外字段。
- **类别注册**：为 surgery_master_whipple_vascular_reconstruction 显式指定 LEGENDARY_STORY；如果现有通用分类机制需要扩展，只处理本台注册入口，不把其他 surgery_master_ 自动转换为 Legendary。
- **专科和展示注册**：按现行 abdominal 专科域接入本术式，展示组为 general_abdominal；不能擅改明日香 Surgery 66、Saber Surgery 91、御堂 Surgery 94 等员工属性。
- **首通患者 ID 核查**：旧版 advanced_referral.gd 首通传奇看板将 patient_id 固定为 patient_murakami_ai。复核报告标注此项已先行修复；**实装时先核对当前仓库 diff**，若已动态解析则只做村上愛／久宇舞弥回归测试，若仍硬编码则仅以现有 FirstStory.patient(record, false) 的真实返回结构修复，避免引入不存在的字段。
- **现行结算与抽取**：首次失败 Day3 → FAILED_LOCKED；首次成功 Day3 → CLEARED 并进入符合条件的 V2 周一返场池；返场失败保留 CLEARED；复用原子结算与公共失败模板，不新增额外剧情状态。
- **数据文件分离**：遵循项目现行 procedures_additions / stories / dialogue / art_manifest；字段与 ID 映射以真实仓库 schema 为准，不强行导入本文的 Markdown 栏名。

### 9.2 对工程不授权的工作

1. 不改任何已锁定的 Saber Lv3/Lv4/Lv5 剧情、关系称呼或 Chief 相关 Gate。
2. 不添加新的「Saber 退出／支持坂口／信任状态」等语义 flag。后续只按已有关系 Lv5 clear 判断。
3. 不改写舞弥病理、性格、手术方式、血管重建 Type IV 与静态术野策略；涉及医学可行性矛盾必须提出审稿意见供用户定案。
4. 不新增跨关卡系统，例如切换动态术野、多个手术室摄像头、三次 Precision 失败自动终止、永久手术阶段存档等。
5. 不补写新人物剧情对白。非剧情提示若缺英文，可由工程忠实翻译；**完整三日 VN 已定稿为 V1.1 配套文档**，实施时只接线不得改写。

---

## 10. 实装验收计划

### 10.1 结构与流程

| 验收 ID | 检查条件 | 合格标准 |
|---|---|---|
| SAB-L01 | 注册类别 | 本 ID 可被传奇入口识别，其他 Advanced 术式分类不变 |
| SAB-L02 | 事件 Gate | Saber Lv5 clear + Advanced 基线资格触发；不要求新主任 flag |
| SAB-L03 | 阶段结构 | 正好 WH01–WH18，F4/L3/S3/P8，顺序无跳号、无额外虚构阶段 |
| SAB-L04 | 初次选人 | Saber 第一助手固定，第二助手可按现有规则选择 |
| SAB-L05 | 返场选人 | 第一助手不固定；返场即使选 Saber 仍走 GENERIC，对话不重放教学 |
| SAB-L06 | 静态术野 | WH01–WH18 使用唯一对应术野资源，没有阶段差分或跨手术误引用 |
| SAB-L07 | Day2 短场景 | 只有转运／全麻短过场；同一运行会话只播放一次 |
| SAB-L08 | 读取安全存档 | 重新开本台正常重播 Day2 过场；无持久化游标或阶段进度 |
| SAB-L09 | Day3 原子结算 | 先提交完成、奖励、返场资格，再播放第一次成功剧情；多次进入不重复发奖 |
| SAB-L10 | 失败流程 | 首次失败 Day3 原子结算 FAILED_LOCKED 并播放公共失败模板；返场失败保留 CLEARED；均不播放首次成功尾声 |
| SAB-L11 | 转诊与排班 | 沿用现行 V2 周一双槽有放回返场池和公共不可 Quick 约束；**不使用旧 FIFO／额外 14 天硬编码** |
| SAB-L12 | 首通患者 | 久宇舞弥病例在首通看板与结算记录使用 patient_maiya_hisau；村上愛原病例不被误改，patient_id 由既有公共动态解析路径获取 |
| SAB-L13 | 已批准 VN | FIRST_STORY Day1 A–D、Day2 E–F、首次成功 Day3 G–I 逐句照 V1.1 VN 文件；返场不重播；四个分支无持久副作用 |

### 10.2 数值、对白与危机

| 验收 ID | 检查条件 | 合格标准 |
|---|---|---|
| SAB-B01 | 18 阶段时间 HP | 锁定基础总计 **729 min／54 HP**；A 策略总附加 +41 min／+3 HP，技能过载与危机另外结算 |
| SAB-B02 | 策略 | WH05/10/17 选 A/B 均单次生效，额外 HP 与时间正确记账，未选增量绝不生效 |
| SAB-B03 | 生理配置 | 18 阶段按 §1.1 全部四维生理字段，恰好 7 条条件效果；stress 分级与独立生理增量不混用 |
| SAB-B04 | 精密判定 | WH06/08/09/11/12/14/15/16 采用公共 Precision；不添加三次失败直接终止 |
| SAB-B05 | 救援 POST | 直接成功与救援成功走正常 POST；救援失败尚可继续时跳过；终止不播 |
| SAB-B06 | 危机 | 恰好 [8, 12, 17] 三检查点，使用现有生理驱动 resolver；WH17 先结算 S 策略再进行 WH_C3，危机完成前 POST 不提前触发 |
| SAB-B07 | 双语 | 18 阶段每组 2 PRE+1 POST、8 P_FAIL、3×2 策略说明均有 CN/EN |
| SAB-B08 | 助手差分 | 18 组 FIRST_STORY SABER 与 18 组 REPLAY GENERIC，另 6 组 POST 差分正确互斥 |
| SAB-B09 | 对白身份 | assistant_1 绑定实际人物；GENERIC 路径不得用 Saber 私人称呼或交托剧情 |
| SAB-B10 | 数值回归 | 按已通过的 V1.1 模拟口径检查 Skill 90／91／100、变异局、两次 Saber 救援共享配额、A/B 的一次性资源结算、无危机 BBB／BBA 全 18 节点 Godot 对账 |
| SAB-B11 | 条件阈值 | BBB/BBA 在 WH18 的 Bleeding 分别为 18／16，均触发 ≥16 条件惩罚；BBA 的末段优势来自 WH17 更高 Stability，而非消除该惩罚 |
| SAB-B12 | 助手插句 | WH02–WH17 为主刀 PRE01 → 一助 PRE → PRE02；WH01／WH18 为 PRE01 → 主刀 PRE02 → 一助 PRE；六阶段助手 POST 先待危机解决 |

### 10.3 单张术野与素材验收

- 已选定 §8.2 的第一条手术视频作为**视觉参考**；目前尚**未收到用于发行的最终术野图**，不可将视频原帧或之前大血管主动脉手术图冒充这台胰头术野。
- 人物素材若暂未到位，可以进入占位式工程联调；首次正式开放前须完成资源验收。
- 本术式的唯一术野图以高质量的上腹部手术窗口为准；不触发任何随 WH 阶段推进的贴图切换。

---

## 11. 医学核查参考（策划用，非临床操作指南）

以下均为原始临床病例、手术技术或研究文章，说明「SPN 累及 PV/SMV 时可能需要联合切除」和「Type IV 使用间置移植物」具有医学先例。**本稿的舞弥个体血管解剖、肿瘤大小、时长和 HP 都是游戏原创配置，并非任何单一真实病例的复刻**。

1. [A Unique Presentation of Solid Pseudopapillary Neoplasm of the Pancreas Requiring Pancreaticoduodenectomy...](https://pmc.ncbi.nlm.nih.gov/articles/PMC11290407/) — SPN 头部病灶与门静脉密切粘连，曾需联合血管切除和重建。
2. [Solid pseudopapillary neoplasm of the pancreas causing obstructive jaundice: Case report](https://pmc.ncbi.nlm.nih.gov/articles/PMC11636209/) — 病例讨论 Whipple 联合 PV/SMV 血管切除及重建。
3. [Segmental portal/superior mesenteric vein resection and reconstruction with the iliac vein after pancreatoduodenectomy](https://pmc.ncbi.nlm.nih.gov/articles/PMC5536759/) — 自体静脉段间置及 Type IV 分类的原始手术研究。
4. [Classification and techniques of en bloc venous reconstruction for pancreaticoduodenectomy](https://pmc.ncbi.nlm.nih.gov/articles/PMC5061022/) — 门肠静脉区域血管解剖、分区与重建术式选择。
5. [Severe morbidity following pancreatectomy with vascular reconstruction: impact of intraoperative vascular events and grafted venous reconstructions](https://pmc.ncbi.nlm.nih.gov/articles/PMC12746273/) — 包含以颈内静脉移植物重建 SPN 患者静脉及脾静脉再吻合的真实先例；提醒舞弥本例的**保留脾静脉回流前提需要明确**。

---

## 12. 提交正式 Codex Bundle 前的剩余工作

**此 V1.1 Concept Lock 已具备：**固定病理与 Type IV 方案、18 阶段全部精度／HP／时间／四维生理／条件效果、三个策略、三个危机位置、54 条阶段通用双语短对白、36 条助手双轨 PRE、12 条助手双轨 POST、8 条精密失败回应、独立已批准的三日双语 VN 正文、现行 V2 结算与返场契约、指定术野视频参考、UI 双语和工程验收清单。数值已获 Codex 与 Godot 校准，无需重新提出 V1.0 的未完成数值任务。

**剩余工程／素材工作：**

1. 按已批准文档制作 procedure_additions、story、operative dialogue、art manifest 并与现有 schema 核对；不得改写可见角色对白。
2. 舞弥的正式身份立绘、Day2 转运／全麻过场与**唯一静态胰头／门肠静脉术野**资源接入与艺术审核；当前只有被选定的视频参考，不等于已经有授权可用的最终 PNG。
3. 复核脾静脉汇入口近端血管袖与最终自体静脉移植物来源的**医学解剖前提**（NEEDS_MEDICAL_QA）；如有实质冲突，须征求用户同意，不能静默修改病例与 VN。
4. 验证当前 patient_id 动态解析修复是否已经写入仓库；完成首次成功／首次失败／返场成功／返场失败与 V2 周一双槽的回归测试。

**下一步：Codex 按本 V1.1 与三日 VN V1.1 直接实装，在已批准资料上做字段适配和联调。本文是完整的策划／验收规格，而非直接可运行的 JSON Bundle。**
