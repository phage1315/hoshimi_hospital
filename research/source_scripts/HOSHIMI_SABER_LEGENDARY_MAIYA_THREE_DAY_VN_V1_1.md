# Hoshimi Hospital／星见医院
## Saber 传奇术式《这一次，交给你》——三日 VN 正式定稿 V1.1（Concept Lock）

**稿件性质：**已获用户审校通过的 FIRST_STORY 三日**完整双语剧情正文**及 Codex 接线规范；不是直接运行代码。  
**患者：**久宇舞弥（Maiya Hisau，成年女性）  
**传授医生：**阿尔托莉雅·潘德拉贡（Saber）  
**玩家主角／主刀：**坂口隆司  
**术式：**复杂胰十二指肠切除术（Whipple）联合 PV/SMV 节段切除及 Type IV 自体静脉移植物间置重建  
**关联关卡：**HOSHIMI_SABER_LEGENDARY_MAIYA_SURGICAL_DESIGN_V1_1.md（WH01–WH18 阶段对白、54 HP、V1.1 三策略、18 阶段生理／七条件效果、危机位置、失败／返场契约均以该设计文档为准）  
**对外英文标题：**This Time, I Entrust It to You

**锁定规则：**A–I 正式中英台词与四个即时选项沿用已通过的 V1.0 校对稿，逐句不做剧情改写。本 V1.1 仅同步数值设计的版本链接、Runner 触发、已确认的 V2 返场与状态接线、正式术野参考和附录状态说明。若技术接线与文字有矛盾，先报告用户，不自动润色或删改剧情正文。

---

## 0. 演出与接线规则

1. 仅在 **Saber Relationship Lv5《我的位置》已 clear + Advanced Surgery 已解锁 + 现有传奇排程条件满足**之后，进入独立 FIRST_STORY。当前公共传奇准入包括至少五台普通高级手术完成数，这不是本篇新建 Gate。**不接在 Lv5 当天自动连播**，不新增主任／支持相关语义 flag。
2. 三日制沿用现有 Runner。Day1 读取本稿 A–D；Day2 读取 E–F 后进入 WH01–WH18；Day3 只在手术**首次成功、原子结算为 CLEARED 且奖励／返场资格已提交**后读取 G–I。首次 Day2 手术失败，在 Day3 原子结算为 **FAILED_LOCKED**，只播公共失败模板，绝不播放 G–I。返场失败保留 CLEARED。
3. 首通 Saber 固定第一助手；第二助手及其他医护由现有系统选择。本稿 Day2 不固定第二助手身份；术中实际阶段台词、Saber 传授与返场通用助手对白调用**既有设计文档**，不得重复插入本稿中的人物长对白。
4. 返场按现行 **Advanced Referral V2 周一双槽、有放回抽取池**进行；不调用旧 FIFO／自行添加 14 天固定冷却。**本稿 A–I 只在首次故事播放**；返场只走通用高级手术入口和通用阶段对白，即便玩家选择 Saber 为第一助手，也不重播这次的交托与私人回顾。
5. **所有 CN／EN 均是玩家可见的正式正文或选择按钮。**每条均有稳定的剧本节点名，便于 Codex 对应，不代表强制使用同名运行时字段。**【演出指示｜非显示】**仅指导背景、角色立绘、表情、音乐、黑屏与手术 Runner 接口，不进入文字框。场景内部标题亦为制作标注，不作为游戏章节标题显示。
6. 任何玩家选择仅影响即时角色反应，**不改数值、Relationship、主任结果、其他 Gate 或持久 Flag**。所有分支都有明确汇合节点。
7. 医学信息限定为舞弥本病例的术前工作诊断：胰头约 6 cm 肿物，影像及既有检查倾向 SPN，邻近 PV/SMV 受累；计划 Whipple 联合 Type IV 间置移植物重建。**术后 Day3 不宣称最终病理已出**。技术步骤不在 VN 里替代阶段系统。
8. 舞弥与 Saber 均不得写成无能、崩溃或依靠坂口拯救自尊；Saber 曾在 Lv5 困境中体现成熟领导判断，本篇是专业技术上的进一步信任，不重启那场主任选择题。Saber 本人的 Staff-as-Patient 保留为独立未来事件。
9. **美术：**手术 Runner 只使用**单张静态胰头／PV/SMV 术野**，无需各阶段切换；已确定手术视频视觉参考见设计 V1.1 §8.2，但不等于授权原始截图作发行素材。本稿额外需求仅为已有角色立绘、病房、阅片室、办公室、转运走廊、手术室与麻醉短过场。
10. **无强制月份、季节或绝对日期 Gate。**Day1–Day3 只以术前一天／手术日／术后首个稳定探视日表达时间；若 Runner 的 Day3 固定在次日，使用其正常节点。
11. **英文称呼口径：**本稿英文以 `Dr. Sakaguchi` 对应公事场合的「坂口医生」，以 `Sakaguchi` 对应较亲近语境的「坂口君」。这是英文省略日语敬称的统一译法；C14、I12 不单独加入 `-kun`，不改变中文私人称呼。

---

## Day 1｜术前日

### A. 已经安排好的时间 / A Schedule Already Made

**【演出指示｜非显示】**  
地点：星见医院外科门诊咨询室。时间：工作日上午。  
画面：明亮但不强调季节的普通门诊背景。坂口穿白大褂坐于电脑和纸质病例旁；舞弥身穿简洁的深色常服，头发整齐，神情平静。她自己带来整理好的工作日历与诊疗资料。背景音为门诊区遥远的脚步和翻页声；无特殊 CG。

- **A01｜旁白**｜CN「门诊咨询室的门被轻轻叩响。坂口刚说了声『请进』，来人便已经把预约单平整地放在桌角。」｜EN “A soft knock came at the consultation-room door. By the time Sakaguchi said, ‘Come in,’ the visitor had already laid her appointment slip neatly at the corner of the desk.”
- **A02｜久宇舞弥**｜CN「久宇舞弥。九点的复诊预约。我提前到了六分钟。」｜EN “Maiya Hisau. Nine o’clock follow-up appointment. I’m six minutes early.”
- **A03｜坂口隆司**｜CN「时间正好。请坐。」｜EN “Right on time. Please, have a seat.”
- **A04｜旁白**｜CN「舞弥坐下，膝上放着一个薄薄的资料夹。透明封套里，从影像报告到用药记录，全部按照日期排列。」｜EN “Maiya sat with a slim folder on her lap. Inside its clear sleeves, everything from imaging reports to medication records was arranged by date.”
- **A05｜坂口隆司**｜CN「资料整理得很完整。今天我主要想听听你自己的情况。最近有没有新的不适？」｜EN “This is a thorough set of records. Today I’d also like to hear how you’ve been. Any new symptoms?”
- **A06｜久宇舞弥**｜CN「饭后偶尔会不舒服。没有剧烈疼痛。食量比以前小一点，不过还可以正常工作。」｜EN “Some discomfort after meals. No severe pain. My appetite is a little smaller, but I can still work normally.”
- **A07｜坂口隆司**｜CN「体重呢？」｜EN “And your weight?”
- **A08｜久宇舞弥**｜CN「近一段时间有下降，数字写在第三页。每天早上同一时间测量。」｜EN “It has gone down recently. The figures are on page three, taken at the same time each morning.”
- **A09｜旁白**｜CN「坂口翻到第三页。那张表格不仅记了体重，还写着进食时间、腹部不适的持续分钟数，以及她当时是否正在工作。」｜EN “Sakaguchi turned to page three. The table recorded not just her weight, but meal times, how many minutes each episode of abdominal discomfort lasted, and whether she had been working.”
- **A10｜坂口隆司**｜CN「你把自己观察得很仔细。」｜EN “You’ve been observing yourself very carefully.”
- **A11｜久宇舞弥**｜CN「有记录的话，别人接手会快一点。」｜EN “Records make it easier for someone else to take over.”
- **A12｜坂口隆司**｜CN「接手什么？」｜EN “Take over what?”
- **A13｜久宇舞弥**｜CN「需要有人处理的事情。工作、家里的安排，或者病历。」｜EN “Anything that needs handling. Work, things at home, or the medical record.”
- **A14｜旁白**｜CN「她说得理所当然，仿佛这三样只是在同一份清单上相邻的栏目。」｜EN “She said it as though all three belonged to adjacent columns on the same checklist.”
- **A15｜坂口隆司**｜CN「医院的部分由我们接手。你带来的记录很有帮助，但你不必把自己的手术也组织成一项工作任务。」｜EN “We’ll take over the hospital part. Your records help, but you don’t need to organize your own operation like another work assignment.”
- **A16｜久宇舞弥**｜CN「我明白。我只是想尽量减少不必要的等待。」｜EN “Understood. I just want to minimize unnecessary waiting.”
- **A17｜坂口隆司**｜CN「我相信你能做到。不过在医院，有时等候本身就是治疗的一部分。」｜EN “I’m sure you can. But in a hospital, waiting is sometimes part of the treatment.”
- **A18｜久宇舞弥**｜CN「这点比我想的难控制。」｜EN “That is harder to control than I expected.”
- **A19｜旁白**｜CN「坂口合上那份工作日历，把影像报告抽到最上面。舞弥的目光跟着移动，仍然安静得几乎没有表情。」｜EN “Sakaguchi closed the work calendar and moved the imaging report to the top. Maiya followed the motion with her eyes, her expression almost entirely composed.”
- **A20｜坂口隆司**｜CN「这次复查的影像，和先前的检查结果合在一起看，需要认真讨论手术。阿尔托莉雅医生稍后也会参加。」｜EN “Taken together with the earlier studies, your new images warrant a serious surgical discussion. Dr. Artoria will join us shortly.”
- **A21｜久宇舞弥**｜CN「两名外科医生一起说明？」｜EN “Two surgeons for the explanation?”
- **A22｜坂口隆司**｜CN「这台手术涉及的结构比较复杂。我们希望你能听到完整方案，再决定下一步。」｜EN “The structures involved make this a complex operation. We want you to hear the full plan before you decide what comes next.”
- **A23｜久宇舞弥**｜CN「那么，我把后面的时间全部空出来。」｜EN “Then I’ll clear the rest of my schedule.”
- **A24｜坂口隆司**｜CN「今天只需要先听完、问清楚。不用在十分钟内做完所有决定。」｜EN “Today, you only need to listen and ask your questions. You don’t have to make every decision in ten minutes.”
- **A25｜久宇舞弥**｜CN「……这个安排，我试着接受。」｜EN “…I’ll try to accept that arrangement.”

**【选择 A-C1｜仅角色扮演；无数值／Gate／Flag 影响】**  
玩家可见选择：
- A「先把最关心的问题问出来就好。」／“Start with the question that matters most to you.”
- B「我会陪你把时间表重新排好。」／“I’ll help you rearrange your schedule.”

**【分支 A】**
- **A26A｜坂口隆司**｜CN「先把最关心的问题问出来就好。别按报告页码的顺序来。」｜EN “Start with the question that matters most. You don’t have to follow the page numbers.”
- **A27A｜久宇舞弥**｜CN「我可以先问手术会持续多久吗？」｜EN “Then may I ask how long the operation will take?”
- **A28A｜坂口隆司**｜CN「当然。这正是我们待会儿要仔细解释的部分。」｜EN “Of course. That’s exactly what we’re going to explain.”

**【分支 B】**
- **A26B｜坂口隆司**｜CN「我会陪你把时间表重新排好。术前、手术和恢复期，各有需要留出的时间。」｜EN “I’ll help you rearrange it. Preparation, surgery, and recovery each need time of their own.”
- **A27B｜久宇舞弥**｜CN「谢谢。那我先不用把出院日期写死。」｜EN “Thank you. Then I won’t fix a discharge date just yet.”
- **A28B｜坂口隆司**｜CN「对。让恢复情况决定日期。」｜EN “Exactly. Let your recovery determine the date.”

**【A-C1 汇合 → A29】**
- **A29｜旁白**｜CN「舞弥取下工作日历最上面那张便利贴，折了两下，放回资料夹。她的动作没有丝毫慌乱，却终于不再继续核对下一条日程。」｜EN “Maiya removed the top sticky note from her calendar, folded it twice, and returned it to the folder. Her hands were steady. For once, she did not immediately check the next item.”
- **A30｜坂口隆司**｜CN「我们去阅片室吧。阿尔托莉雅医生应该已经到了。」｜EN “Let’s go to the imaging room. Dr. Artoria should be there by now.”

---

### B. 不只是切除 / More Than a Resection

**【演出指示｜非显示】**  
地点：外科影像讨论室。时间：同日上午，门诊结束后。  
画面：大屏幕上依次显示腹部增强 CT/MRI 的示意（可用项目已有医学影像 UI，若没有则使用无个人信息的抽象示意，不强制新增影像 CG）。阿尔托莉雅和坂口着白大褂，舞弥仍穿常服，三人坐于桌边。演出需让舞弥能看见图片，不把她安排在医生身后。

- **B01｜旁白**｜CN「阅片室的光线比门诊暗了一些。大屏幕上，胰头附近的病灶轮廓被标注出来，旁边是一段彼此相连的蓝色静脉影像。」｜EN “The imaging room was slightly dimmer than the clinic. The lesion near the pancreatic head was marked on the screen, beside a connected stretch of venous anatomy shown in blue.”
- **B02｜阿尔托莉雅**｜CN「舞弥，辛苦你过来了。我是阿尔托莉雅·潘德拉贡，今天和坂口医生一起向你说明手术计划。」｜EN “Maiya, thank you for coming. I’m Artoria Pendragon. Dr. Sakaguchi and I will explain the proposed operation together.”
- **B03｜久宇舞弥**｜CN「我听坂口医生说过。请开始吧。」｜EN “Dr. Sakaguchi told me. Please go ahead.”
- **B04｜坂口隆司**｜CN「影像显示胰头有一处约六厘米的肿物。结合检查，我们首先考虑实性假乳头状肿瘤，但最终性质仍需病理确认。」｜EN “The imaging shows a mass of roughly six centimeters in the pancreatic head. The findings favor a solid pseudopapillary neoplasm, though the final diagnosis will depend on pathology.”
- **B05｜久宇舞弥**｜CN「目前不能完全确定，是吗？」｜EN “So it isn’t fully confirmed yet?”
- **B06｜坂口隆司**｜CN「对。我们不会把倾向性判断说成已经拿到的病理结果。」｜EN “Correct. We won’t present a working diagnosis as a final pathology result.”
- **B07｜旁白**｜CN「阿尔托莉雅走到屏幕旁，指尖停在病灶后侧的静脉走行附近。她没有立刻谈切口，而是先让舞弥看清两端正常的血管位置。」｜EN “Artoria moved beside the screen and pointed near the vein running behind the lesion. Rather than beginning with the incision, she first showed Maiya the normal vessel above and below it.”
- **B08｜阿尔托莉雅**｜CN「真正让这台手术复杂的，不只是肿瘤大小。你看这里——病灶与门静脉、肠系膜上静脉相连的一段关系非常紧密。」｜EN “The size is not the only difficulty. Look here—the lesion is closely involved with a segment along the portal and superior mesenteric venous axis.”
- **B09｜久宇舞弥**｜CN「如果把肿瘤从血管表面剥离出来，会不会简单一些？」｜EN “Would it be simpler to separate the tumor from the surface of the vein?”
- **B10｜阿尔托莉雅**｜CN「这是我们首先评估过的可能。但目前的边界让我们无法有把握地做到安全、完整的分离。」｜EN “That was one of the first possibilities we assessed. But these planes do not give us enough confidence in a safe, complete separation.”
- **B11｜阿尔托莉雅**｜CN「勉强沿着不清楚的界面剥离，可能使切除不完整，也可能损伤需要保留的血管壁。所以我们拟定的方案更大。」｜EN “Forcing the dissection along an uncertain plane could compromise completeness or damage the vessel wall we need to preserve. That is why our proposed operation is more extensive.”
- **B12｜坂口隆司**｜CN「胰头及相连的十二指肠等结构，需要按胰十二指肠切除术的原则处理。受累的静脉段也计划一并切除。」｜EN “We would remove the pancreatic head and associated structures according to the principles of pancreaticoduodenectomy, including the involved venous segment.”
- **B13｜久宇舞弥**｜CN「那段血管切掉以后呢？」｜EN “What happens after that segment of vein is removed?”
- **B14｜旁白**｜CN「她的声音仍然平稳。只是原本放在膝上的双手收拢，指尖压住了资料夹的硬边。」｜EN “Her voice remained even. Only her hands changed, closing over the rigid edge of the folder on her lap.”
- **B15｜阿尔托莉雅**｜CN「我们会用预先准备好的静脉移植物，把两端重新连接起来。它不是手术结束时额外补做的一步，而是整台切除方案的一部分。」｜EN “We would use a prepared venous graft to reconnect the two ends. It isn’t an optional repair added at the finish; it’s part of the resection plan itself.”
- **B16｜久宇舞弥**｜CN「也就是说，先切除，再把血流通道重新建立。」｜EN “So you remove the involved segment, then reconstruct the route for blood flow.”
- **B17｜阿尔托莉雅**｜CN「准确地说，切除前就会建立好控制条件，移植物与重建路线也要先确认。真正的阻断时间里，我们不会浪费任何一步。」｜EN “More precisely, we establish vascular control and plan the graft route before resection. During the actual clamping interval, we cannot waste a step.”
- **B18｜坂口隆司**｜CN「血管恢复以后，还要完成胰肠、胆肠和胃肠重建。手术时间长，术后也需要严密监测。」｜EN “Once venous flow has been restored, we still have to reconstruct the pancreatic, biliary, and gastric connections. It is a long operation, followed by close monitoring.”
- **B19｜久宇舞弥**｜CN「主要风险是什么？」｜EN “What are the main risks?”
- **B20｜坂口隆司**｜CN「术中出血、血管重建后的血流问题、吻合口相关并发症，以及术后的感染和恢复延迟。我们会逐项准备和监测，但不能向你保证零风险。」｜EN “Bleeding, problems with flow after vascular reconstruction, anastomotic complications, infection, and delayed recovery. We prepare and monitor for them, but we cannot promise zero risk.”
- **B21｜旁白**｜CN「舞弥没有打断他。她听完以后，低头看了一眼自己的日历，却没有翻开。」｜EN “Maiya did not interrupt. When he finished, she glanced at her calendar but did not open it.”
- **B22｜久宇舞弥**｜CN「如果我暂时不做手术，你们也会把这个选择和可能的后果讲清楚吧？」｜EN “If I decide not to have the operation yet, you would explain that option and its possible consequences too?”
- **B23｜坂口隆司**｜CN「会。你有权知道目前的判断、其他选择，以及推迟处理意味着什么。我们不会替你跳过这部分。」｜EN “Yes. You have a right to know our assessment, the alternatives, and what postponement may mean. We won’t skip that discussion.”
- **B23_EX01｜坂口隆司**｜CN「如果暂缓手术，我们会继续复查影像、观察症状。但病灶可能继续增大，与附近静脉的关系也可能变得更复杂。将来如果仍需切除，手术未必会比现在容易。」｜EN “If you postpone surgery, we would continue imaging follow-up and monitor your symptoms. But the mass could grow and involve the nearby veins more extensively. If resection is still needed later, the operation may be more complicated than it is now.”
- **B23_EX02｜阿尔托莉雅**｜CN「至于刚才讨论的较小范围切除，也就是尝试把病灶从血管表面分离，目前无法有把握地保证安全、完整切除。因此我们不把它作为等价的替代方案。」｜EN “As for the more limited resection we discussed—trying to separate the mass from the vessel—we cannot be confident it would achieve a safe, complete removal in this case. We therefore do not consider it an equivalent alternative.”
- **B24｜阿尔托莉雅**｜CN「但就现有资料而言，我们建议进行计划中的完整切除。不是因为这台手术值得挑战，而是因为我们认为这是对你更合适的治疗路线。」｜EN “With the information we have, we recommend the planned complete resection. Not because the operation is an impressive challenge, but because we believe it is the more appropriate treatment for you.”
- **B25｜久宇舞弥**｜CN「那就按你们建议的方案继续准备。」｜EN “Then let’s proceed with preparation for the operation you recommend.”
- **B26｜坂口隆司**｜CN「我再确认一次：不是因为你不想麻烦别人，也不是因为我们把日程排好了。是你自己理解之后的决定？」｜EN “I want to confirm once more: not because you don’t want to inconvenience anyone, and not because we’ve already made a schedule. This is your own decision after understanding the plan?”
- **B27｜久宇舞弥**｜CN「是。我想处理这个病灶。也知道手术不是一项能够完全按表执行的任务。」｜EN “Yes. I want the lesion treated. And I understand that surgery is not a task that can be executed entirely by schedule.”
- **B28｜旁白**｜CN「阿尔托莉雅取过手术说明书，把涉及静脉重建和术后监测的几页重新翻给她看。舞弥一页页读过去，遇到不明白的地方便停下来提问。」｜EN “Artoria handed her the surgical information sheets and turned again to the pages on venous reconstruction and postoperative monitoring. Maiya read through them, pausing whenever she needed clarification.”
- **B29｜久宇舞弥**｜CN「最后一个问题。谁来主刀？」｜EN “One last question. Who will lead the operation?”
- **B30｜坂口隆司**｜CN「我。」｜EN “I will.”
- **B31｜久宇舞弥**｜CN「阿尔托莉雅医生呢？」｜EN “And Dr. Artoria?”
- **B32｜阿尔托莉雅**｜CN「我担任第一助手。最需要两人密切配合的阶段，我会一直在台边。」｜EN “I will be the first assistant. I’ll be at the table through the phases that demand the closest coordination.”
- **B33｜旁白**｜CN「舞弥先看向坂口，又看向阿尔托莉雅。两人没有谁急着替对方补充一句保证。」｜EN “Maiya looked first at Sakaguchi, then at Artoria. Neither hurried to add a promise on the other’s behalf.”
- **B34｜久宇舞弥**｜CN「明白了。请把最后的手术计划和需要我完成的术前事项交给我。」｜EN “Understood. Please give me the final plan and whatever I need to complete before surgery.”
- **B35｜坂口隆司**｜CN「术前事项会交给你。至于手术本身的工作，轮到我们完成了。」｜EN “We’ll give you the preparation checklist. The work of the operation itself is ours to do.”
- **B36｜久宇舞弥**｜CN「我已经看完，也问清楚了。请把同意书给我。」｜EN “I’ve read everything and asked my questions. Please give me the consent form.”
- **B37｜旁白**｜CN「坂口最后一次确认手术范围与同意内容，舞弥逐页核对后签下自己的名字。她把笔盖扣好，将文件交还给他。」｜EN “Sakaguchi confirmed the scope of surgery and the consent details one last time. Maiya checked each page before signing her name, capped the pen, and handed the documents back.”
- **B38｜坂口隆司**｜CN「收到了。接下来我们会按计划完成术前准备，有任何新的疑问都可以直接问。」｜EN “Received. We’ll continue with the planned preparation. If any new questions come up, please ask.”

**【演出指示｜非显示】**  
舞弥在充分阅读与询问后完成正式同意流程，**B36–B37 已给出玩家可见的签署动作**；具体电子签署 UI 如有则可使用已有系统演出，不得额外要求她在后续同一剧情中重复签署。画面结束于三人共同核对计划，非舞弥入手术室。

---

### C. 两名外科医生 / Two Surgeons

**【演出指示｜非显示】**  
地点：星见医院外科副部长办公室兼术前讨论区。时间：同日下午。  
画面：舞弥已离场。阿尔托莉雅与坂口仍穿白大褂，桌上是本例纸质解剖示意、血管重建方案和手术排程。办公室门关闭，属于两人私下交流，可沿用既定私人称呼「阿尔托莉雅／坂口君」。这不是恋爱新事件，不使用亲密 CG。

- **C01｜旁白**｜CN「从阅片室回到办公室时，阿尔托莉雅没有立刻坐下。她先把桌上的两份图重新并排摆正：左边是切除前的静脉走行，右边是间置移植物完成后的预定路线。」｜EN “Back in the office, Artoria did not sit immediately. She straightened two diagrams side by side: the venous anatomy before resection, and the proposed route after graft reconstruction.”
- **C02｜阿尔托莉雅**｜CN「影像上最值得留意的不是肿瘤的圆形轮廓，而是这段被它压迫、牵扯的静脉。图上很短，到了术野里未必好处理。」｜EN “What matters most on these images is not the round outline of the tumor, but the vein it compresses and draws against itself. The segment looks short on a scan. In the field, it may not be straightforward.”
- **C03｜坂口隆司**｜CN「我们预计缺损四到五厘米。强行拉近两端，不见得比间置移植物省事。」｜EN “We expect a defect of about four to five centimeters. Pulling the ends together would not necessarily be simpler than interposition.”
- **C04｜阿尔托莉雅**｜CN「而且不能拿血管张力去换表面上的简洁。你看这里，脾静脉回流必须作为整张规划的一部分保留下来。」｜EN “And we cannot trade vascular tension for superficial simplicity. Look here: preserving splenic venous drainage must remain part of the entire plan.”
- **C05｜坂口隆司**｜CN「术前的解剖判断支持保留近端血管袖，但要在实际暴露后再次确认。」｜EN “The preoperative anatomy supports preserving the proximal venous cuff, but we need to confirm it after exposure.”
- **C06｜阿尔托莉雅**｜CN「没错。若探查结果与图纸冲突，首先要重新评估，不能让手术为了迎合一张漂亮的示意图继续走下去。」｜EN “Exactly. If the field contradicts the drawing, we reassess first. We do not force the operation to conform to an attractive diagram.”
- **C07｜旁白**｜CN「坂口把另一份器械清单推过来。列表的后半部分密密麻麻，血管吻合之后还排着胰肠、胆肠和胃肠三处重建。」｜EN “Sakaguchi slid over another instrument list. The second half was crowded: after the vascular anastomoses came the pancreatic, biliary, and gastric reconstructions.”
- **C08｜坂口隆司**｜CN「这台手术真正难的，是把每一段都做得足够稳。完成重建血流以后，还要有精神处理后面三处吻合。」｜EN “The difficulty is keeping every phase steady. After restoring flow, we still need the concentration to complete three more anastomoses.”
- **C09｜阿尔托莉雅**｜CN「所以我们不应把全部精力赌在某一个看起来最壮观的步骤上。」｜EN “Which is why we cannot spend all our concentration on the single step that looks most dramatic.”
- **C10｜坂口隆司**｜CN「听上去，你似乎已经准备好让我听一场很长的术前考试了。」｜EN “That sounds as if you have a very long preoperative examination prepared for me.”
- **C11｜阿尔托莉雅**｜CN「如果你希望，我可以从第一张图考到最后一根缝线。」｜EN “If you wish, I can examine you from the first image all the way to the last suture.”
- **C12｜坂口隆司**｜CN「……我收回刚才的话。」｜EN “…I withdraw the suggestion.”
- **C13｜旁白**｜CN「阿尔托莉雅忍不住笑了一下，随即把重建计划翻到关键的一页。她的指尖落下，神情也重新认真起来。」｜EN “Artoria let out a brief laugh, then turned to the crucial page of the reconstruction plan. Her fingertip settled on the drawing, and her expression grew serious again.”
- **C14｜阿尔托莉雅**｜CN「坂口君，这项手术的难度，你和我都清楚。我可以自己主刀，也有信心把它完成。」｜EN “Sakaguchi, we both understand the difficulty of this operation. I could lead it myself, and I have confidence that I could complete it.”
- **C15｜坂口隆司**｜CN「我知道。正因为如此，我才想确认：你真的决定坐第一助手的位置？」｜EN “I know. That’s exactly why I want to ask: have you truly decided to take the first assistant’s position?”
- **C16｜阿尔托莉雅**｜CN「是。我不是为了证明自己能退后一步。手术台上的位置，本来就应该由这台手术需要什么来决定。」｜EN “Yes. Not to prove that I can step back. Positions at the table should be determined by what the operation needs.”
- **C17｜阿尔托莉雅**｜CN「这次，我希望你完整地做一次主刀。从第一份计划到最后一次确认，所有关键判断都由你负责。」｜EN “This time, I want you to lead a complete case. From the first plan to the final verification, the key judgments will be yours.”
- **C18｜坂口隆司**｜CN「听起来不像一份轻松的礼物。」｜EN “That doesn’t sound like an easy gift.”
- **C19｜阿尔托莉雅**｜CN「它也不是礼物。这是一台真实的手术。」｜EN “Nor is it a gift. It is a real operation.”
- **C20｜旁白**｜CN「她把写有第一助手职责的那页排程表翻给坂口看，自己的姓名端正地列在主刀下方。那里没有任何附注，也没有象征性的箭头。」｜EN “She turned the staffing sheet toward him. Her name sat neatly beneath his in the first assistant’s position. There was no special note, no symbolic arrow.”
- **C21｜阿尔托莉雅**｜CN「我会将需要知道的一切告诉你。至于下一步，你必须亲自判断。」｜EN “I will tell you everything you need to know. But your next move must be your own judgment.”
- **C22｜坂口隆司**｜CN「如果我想改动你最熟悉的操作顺序呢？」｜EN “What if I want to change a sequence you know better than anyone?”
- **C23｜阿尔托莉雅**｜CN「只要理由充分，符合安全要求，我就会配合。若我看到危险，也会直接说出来。」｜EN “If your reasoning is sound and the safety conditions are met, I will support it. If I see a danger, I will say so directly.”
- **C24｜坂口隆司**｜CN「即使那会让你在所有人面前反驳我？」｜EN “Even if it means challenging me in front of the entire team?”
- **C25｜阿尔托莉雅**｜CN「尤其在那种时候。真正好的第一助手，不该为了保护主刀的面子让患者承担风险。」｜EN “Especially then. A good first assistant must never put a patient at risk to protect a lead surgeon’s pride.”
- **C26｜旁白**｜CN「坂口点头。他知道她说的不是客套话；过去并肩工作时，阿尔托莉雅从来不会把准确的信息藏在温柔的语气后面。」｜EN “Sakaguchi nodded. He knew it was no courtesy. In their earlier operations, Artoria had never hidden accurate information behind a gentle tone.”

**【选择 C-C2｜仅角色扮演；无数值／Gate／Flag 影响】**  
玩家可见选择：
- A「那就请你把最严格的标准也带上台。」／“Then bring your strictest standards to the table.”
- B「这样一来，我可能会比平时更依赖你的意见。」／“Then I may rely on your judgment even more than usual.”
- C「你真的放心把整台手术交给我？」／“Are you truly comfortable entrusting the whole operation to me?”

**【分支 A】**
- **C27A｜坂口隆司**｜CN「那就请你把最严格的标准也带上台。我不想要因为我们关系亲近而放宽的那一种。」｜EN “Then bring your strictest standards to the table. I don’t want a gentler version because we’re close.”
- **C28A｜阿尔托莉雅**｜CN「本来也没有那一种。你要小心，我很擅长记住别人说过的话。」｜EN “There was never such a version. Be careful—I am very good at remembering what people say.”

**【分支 B】**
- **C27B｜坂口隆司**｜CN「这样一来，我可能会比平时更依赖你的意见。」｜EN “Then I may rely on your judgment even more than usual.”
- **C28B｜阿尔托莉雅**｜CN「依赖不是问题。只要别把自己的判断也交给我保管。」｜EN “Relying on me is not a problem. Just don’t hand over custody of your judgment as well.”

**【分支 C】**
- **C27C｜坂口隆司**｜CN「你真的放心把整台手术交给我？」｜EN “Are you truly comfortable entrusting the whole operation to me?”
- **C28C｜阿尔托莉雅**｜CN「不。我会认真担心。那不妨碍我信任你。」｜EN “No. I will worry about it seriously. That does not prevent me from trusting you.”

**【C-C2 汇合 → C29】**
- **C29｜坂口隆司**｜CN「好。术前影像、移植物、血管控制和重建的顺序，我们再一起过一遍。」｜EN “All right. Let’s go through the images, graft preparation, vascular control, and reconstruction sequence once more.”
- **C30｜阿尔托莉雅**｜CN「正合我意。」｜EN “Just what I was hoping for.”
- **C31｜旁白**｜CN「两人并肩坐下。桌面上的图纸被逐页翻开，一处接着一处的风险点被认真讨论，谁也没有因为熟悉彼此就省略问答。」｜EN “They sat side by side. Page after page of diagrams was opened, and one risk point after another was discussed. Familiarity with each other spared neither of them a single necessary question.”
- **C32｜旁白**｜CN「等最后一页核对结束，天色已经渐暗。阿尔托莉雅在排程表的第一助手栏签下自己的名字，随后将笔递给坂口。」｜EN “By the time they finished the last page, the light outside had begun to fade. Artoria signed the first assistant’s line on the staffing sheet and handed the pen to Sakaguchi.”
- **C33｜阿尔托莉雅**｜CN「明天我在你右手边。你可以放心要求我做任何第一助手应该完成的事。」｜EN “Tomorrow I’ll be at your right hand. Ask me for anything a first assistant should do.”
- **C34｜坂口隆司**｜CN「那我会认真使用这份信任。」｜EN “Then I’ll take that trust seriously.”

---

### D. 名字写在那一栏 / The Name on the Schedule

**【演出指示｜非显示】**  
地点：外科术前病房。时间：同日傍晚。  
画面：舞弥已经按入院流程更换宽松病号服，坐在病床上，仍未被转上手术床；她的鞋摆在床边，头发未戴手术帽。可见病房护士在周围完成例行记录，桌旁有随身资料夹。坂口与阿尔托莉雅仍穿白大褂。结束后以病房灯光淡出 Day1；**转运床及麻醉全部留在 Day2**。

- **D01｜旁白**｜CN「病房窗外的天色暗了一些。舞弥已经换好病号服，坐在床沿，正把手里的一张便签重新折平。」｜EN “The daylight beyond the ward window had softened. Maiya, now in a hospital gown, sat on the edge of the bed smoothing a folded note.”
- **D02｜病房护士**｜CN「久宇小姐，明天的术前准备已经安排好了。今晚按医嘱休息，之后由我们再来核对。」｜EN “Ms. Hisau, tomorrow’s preoperative preparation is scheduled. Please rest tonight as instructed. We’ll return for the next checks.”
- **D03｜久宇舞弥**｜CN「我已经把可能需要的联系方式写好了。谢谢。」｜EN “I’ve written down the contact numbers you might need. Thank you.”
- **D04｜病房护士**｜CN「放在床头就行。今天不用再替我们值班了。」｜EN “You can leave them by the bed. You don’t have to take a shift for us today.”
- **D05｜旁白**｜CN「护士带着记录夹离开。舞弥看着关上的门，像是认真考虑了一下『不用值班』这件事究竟该怎样执行。」｜EN “The nurse left with the chart. Maiya watched the door close, as if seriously considering how one was supposed to carry out the instruction ‘do not take a shift.’”
- **D06｜坂口隆司**｜CN「适应得怎么样？」｜EN “How are you settling in?”
- **D07｜久宇舞弥**｜CN「这里的规定很明确。比我以为的容易遵守。」｜EN “The rules here are clear. Easier to follow than I expected.”
- **D08｜阿尔托莉雅**｜CN「看起来你已经把病房的交接也整理好了。」｜EN “It appears you’ve already organized the ward handover too.”
- **D09｜久宇舞弥**｜CN「只有一页。没有必要写更多。」｜EN “Only one page. There was no need for more.”
- **D10｜坂口隆司**｜CN「很大的进步。」｜EN “Considerable progress.”
- **D11｜旁白**｜CN「舞弥看了他一眼，嘴角非常轻地动了一下。她把床头那份手术排程表拿过来，指向上面的一行。」｜EN “Maiya glanced at him, the faintest motion at the corner of her mouth. She picked up the operation schedule and pointed to one line.”
- **D12｜久宇舞弥**｜CN「主刀是坂口医生，第一助手是阿尔托莉雅医生。我记住了。」｜EN “Lead surgeon: Dr. Sakaguchi. First assistant: Dr. Artoria. I’ve memorized it.”
- **D13｜阿尔托莉雅**｜CN「你不需要背这份表。」｜EN “You don’t need to memorize the sheet.”
- **D14｜久宇舞弥**｜CN「这只是习惯。」｜EN “It’s a habit.”
- **D15｜久宇舞弥**｜CN「还有一件事。静脉重建的移植物和需要的替代器械，都已经确认了吗？」｜EN “One more thing. Have the venous graft and the necessary backup instruments been confirmed?”
- **D16｜坂口隆司**｜CN「准备计划已经核查，明天入室前还会按手术流程再确认一次。手术中的技术判断，由我和阿尔托莉雅医生负责。」｜EN “The preparation plan has been checked, and we’ll verify it again before entering the operating room. Dr. Artoria and I will handle the technical decisions during surgery.”
- **D17｜久宇舞弥**｜CN「明白。我不再替你们做第二份清单。」｜EN “Understood. I won’t make a second checklist for you.”
- **D18｜阿尔托莉雅**｜CN「我们会把每一项真正需要确认的事情都确认好。你今晚要做的，是让自己休息。」｜EN “We will verify everything that truly needs verification. Your task tonight is to rest.”
- **D19｜久宇舞弥**｜CN「这项任务的验收标准是什么？」｜EN “What are the acceptance criteria for that task?”
- **D20｜坂口隆司**｜CN「至少不要再把病床当办公室。」｜EN “For a start, don’t turn the hospital bed into an office.”
- **D21｜旁白**｜CN「舞弥低头看向膝上的资料夹，沉默了两秒，然后把它收进床头抽屉。」｜EN “Maiya looked down at the folder on her lap. After two seconds of silence, she placed it in the bedside drawer.”
- **D22｜久宇舞弥**｜CN「这样呢？」｜EN “How about now?”
- **D23｜坂口隆司**｜CN「合格。」｜EN “Pass.”
- **D24｜旁白**｜CN「阿尔托莉雅忍着笑，替她把水杯移到更容易够到的位置。舞弥轻声道谢，没有再伸手拿出那份日程。」｜EN “Artoria suppressed a smile and moved Maiya’s water cup within easy reach. Maiya thanked her quietly and did not reach for her schedule again.”
- **D25｜久宇舞弥**｜CN「明天……我会照你们说的做。」｜EN “Tomorrow… I’ll do as you ask.”
- **D26｜阿尔托莉雅**｜CN「嗯。晚安，舞弥。」｜EN “All right. Good night, Maiya.”
- **D27｜坂口隆司**｜CN「明天见。」｜EN “See you tomorrow.”
- **D28｜旁白**｜CN「房门合拢后，病房恢复了安静。舞弥伸手关上床头灯，黑暗里只剩下监护区远处很轻的脚步声。」｜EN “The room grew quiet after the door closed. Maiya switched off the bedside lamp. In the dark, only faint footsteps from the distant nursing area remained.”

**【Day1 结束｜非显示】**  
手术方案与已完成的正式同意流程作为 Day1 的剧情事实；该事实不要求另造独立永久 Flag。按既有三日 Runner 推进到 Day2。**不得在此处播放转运床、手术帽、麻醉药或进入手术室画面。**

---

## Day 2｜手术日

### E. 不用在最前面 / Not at the Front This Time

**【演出指示｜非显示】**  
地点：外科病房→四楼手术部接收区。时间：手术日清晨。  
画面：舞弥已穿病号服，戴完全收拢头发的手术帽，仰卧在转运床上，薄毯覆盖躯干和双腿，手臂自然放在毯外或身侧。两名非具名护士按流程推床，面对面核对信息。若无专属转运床 CG，则复用合格的通用过场；不能把 Day1 病房立绘直接当成已经上台的场景。整段只是一小段短过场。

- **E01｜旁白**｜CN「第二天清晨，病房门口停着一张转运床。舞弥戴上手术帽，躺好后把双手平放在毯子边缘。」｜EN “Early the next morning, a transfer stretcher waited outside the ward room. Maiya put on a surgical cap, lay back, and rested both hands along the edge of the blanket.”
- **E02｜病房护士**｜CN「请再说一次你的姓名和今天接受的手术。」｜EN “Please tell me your name and the operation you’re having today.”
- **E03｜久宇舞弥**｜CN「久宇舞弥。胰十二指肠切除，合并门肠静脉重建。」｜EN “Maiya Hisau. Pancreaticoduodenectomy with portomesenteric venous reconstruction.”
- **E04｜病房护士**｜CN「核对正确。我们出发了。」｜EN “Confirmed. We’re moving now.”
- **E05｜旁白**｜CN「转运床轻轻动起来。舞弥望着天花板的灯，一盏接着一盏从视线里滑过。」｜EN “The stretcher started moving. Maiya watched the ceiling lights pass above her, one after another.”
- **E06｜久宇舞弥**｜CN「我以前总是先确认路线。」｜EN “I usually check the route first.”
- **E07｜病房护士**｜CN「今天你只要躺稳，转弯我们会提前告诉你。」｜EN “Today, you only need to stay comfortable. We’ll warn you before each turn.”
- **E08｜久宇舞弥**｜CN「……好。」｜EN “…All right.”
- **E09｜旁白**｜CN「在通往手术部的最后一个转角，舞弥的手指略微收紧。护士推床的动作始终平稳，没有催促，也没有让她自己去记下一条指令。」｜EN “At the final turn into the surgical area, Maiya’s fingers tightened slightly. The nurse kept the stretcher steady, neither rushing nor asking her to remember the next instruction.”
- **E10｜病房护士**｜CN「到接收区了。下一组同事会继续陪着你。」｜EN “We’re at the receiving area. The next team will stay with you.”
- **E11｜久宇舞弥**｜CN「谢谢。」｜EN “Thank you.”

---

### F. 麻醉前的最后一句话 / The Last Words Before Anesthesia

**【演出指示｜非显示】**  
地点：四楼手术室，手术台。时间：紧接转运交接之后。  
画面：舞弥已由医护协助从转运床转移至水平手术台，帽子完全遮盖头发，病号服按现行术前标准处理，身体由毯和无菌准备材料遮盖；麻醉团队站头侧，先完成监测与核对。坂口和阿尔托莉雅穿刷手服、手术帽与口罩出现在术前核对视野，**此时不假装两人已经穿无菌手术袍触碰非无菌患者**。此场不显示实际手术切口或动态术野。

- **F01｜旁白**｜CN「手术室的灯亮得很均匀。舞弥平躺在手术台上，手术帽边缘压住额前的碎发，护士正在为她接上监测装置。」｜EN “The operating-room lights were even and bright. Maiya lay flat on the table, the edge of her surgical cap holding back stray hair as the nurse attached monitoring devices.”
- **F02｜麻醉医师**｜CN「久宇小姐，我们再确认一次过敏史、禁食情况和今天的麻醉方案。之后会先给你吸氧，再由静脉给入全麻药物。」｜EN “Ms. Hisau, we’ll confirm your allergies, fasting status, and anesthetic plan once more. Then we’ll give you oxygen before administering the general anesthetic through your IV.”
- **F03｜久宇舞弥**｜CN「明白。」｜EN “Understood.”
- **F04｜旁白**｜CN「她转动眼睛，看见坂口和阿尔托莉雅站在手术台另一侧。两人已经戴好帽子和口罩，熟悉的面孔只剩下眼睛可辨。」｜EN “She shifted her gaze and saw Sakaguchi and Artoria on the other side of the table. Caps and masks covered their faces, leaving only their eyes familiar.”
- **F05｜久宇舞弥**｜CN「坂口医生。」｜EN “Dr. Sakaguchi.”
- **F06｜坂口隆司**｜CN「我在。」｜EN “I’m here.”
- **F07｜久宇舞弥**｜CN「如果我睡着以后，手术步骤和你们预计的不完全一样……」｜EN “If, after I’m asleep, the operation doesn’t follow your plan exactly…”
- **F08｜坂口隆司**｜CN「我们会按已经向你说明并取得同意的范围处理，遇到新的情况先评估安全与必要性。你不需要在麻醉前替我们预演所有变化。」｜EN “We’ll act within the scope we explained and you consented to, reassessing safety and necessity if circumstances change. You don’t have to rehearse every possibility for us before anesthesia.”
- **F09｜旁白**｜CN「舞弥看了他一会儿，似乎还想再核对一句，最后却慢慢松开了原本抓住毯角的手。」｜EN “Maiya looked at him for a moment, as if another question were waiting. Instead, she gradually released her grip on the blanket.”
- **F10｜久宇舞弥**｜CN「……交给你们。」｜EN “…I’ll leave it to you.”
- **F11｜阿尔托莉雅**｜CN「我们接住了。接下来，好好睡一觉。」｜EN “We have it from here. Now, get some rest.”
- **F12｜麻醉医师**｜CN「我会一直在你头侧监测。现在开始给药。」｜EN “I’ll be here monitoring you the entire time. We’re starting the medication now.”
- **F13｜旁白**｜CN「氧气面罩轻轻贴近。药物从静脉缓慢进入，舞弥的视线停在无影灯边缘，声音与光线一点点远去。」｜EN “The oxygen mask settled gently into place. As the medication entered through the IV, Maiya’s gaze rested at the edge of the surgical light. Sounds and light slowly receded.”
- **F14｜旁白**｜CN「她闭上了眼睛，再没有回应手术室里的谈话。」｜EN “She closed her eyes and gave no further response to the voices in the room.”

**【Day2 → Surgery Runner 接口｜非显示】**

- 麻醉医师完成全麻诱导与后续气道处理，术前准备由公共系统承接；舞弥在手术阶段**不出现清醒对白**。
- 画面淡出短过场，加载**唯一静态胰头／PV/SMV 术野**；主刀坂口、第一助手 Saber、第二助手及护士团队按既有高级手术编组进入。
- 从 **WH01** 开始按手术设计 **V1.1** 顺序运行至 **WH18**。18 阶段通用双语台词、Saber 第一助手专属台词、P 失败回应、三策略与三个危机检查点（WH08、WH12、**WH17 后**）均由手术数据单独驱动，**不复制到本 VN 文本**。
- 任何普通成功、助手救援成功、仍可继续的失败及终止判定，完全执行既有 Runner；**不增加 Day2 中途长剧情**。
- **首次手术失败：**由 Runner 于 Day3 原子结算为 FAILED_LOCKED，播放项目公共失败模板；不进入 Day3 G–I。**首次成功：**由 Runner 在 Day3 安全边界原子结算为 CLEARED、提交奖励和返场资格，再进入 Day3 G。**返场失败：**保留 CLEARED，不播本稿 A–I。

---

## Day 3｜首次成功后

### G. 谁来写交接记录 / Who Writes the Handover

**【演出指示｜非显示】**  
地点：星见医院外科术后监护病房。时间：手术次日、舞弥已苏醒且适合简短交流的探视时段。  
画面：舞弥卧床休息，头发未戴手术帽，换成术后病房服；腹部伤口被恰当敷料和病房被单遮盖，必要监测和引流由画面留出合理空间，不做未获素材授权的裸露特写。她有术后倦意、声音略轻，但意识清楚。病房护士先在场，坂口与阿尔托莉雅白大褂入室。**不表现患者立即下床、随意进食或出院。**  
**先决条件：**手术首次成功及其奖励、返场资格已在安全边界原子结算完成；本场不再次发放任何奖励。

- **G01｜旁白**｜CN「监护病房里，设备的声音规律而轻。舞弥已经醒来，半靠着枕背，望着床边记录板上刚更新的一行数字。」｜EN “The monitors in the recovery ward kept a quiet, regular rhythm. Maiya was awake, resting against a raised pillow as she studied a newly updated line of figures on the bedside chart.”
- **G02｜病房护士**｜CN「久宇小姐，醒来以后感觉怎么样？现在可以简短说话，想休息就告诉我。」｜EN “Ms. Hisau, how are you feeling now that you’re awake? You can speak briefly, but tell me if you need to rest.”
- **G03｜久宇舞弥**｜CN「有点累。腹部不舒服，不过还能忍受。」｜EN “Tired. My abdomen is uncomfortable, but manageable.”
- **G04｜病房护士**｜CN「有疼痛或不适请直接说，我们会评估处理。你不需要靠忍耐来证明恢复得好。」｜EN “Please tell us about pain or discomfort so we can assess and treat it. You don’t have to prove you’re recovering well by enduring it.”
- **G05｜久宇舞弥**｜CN「……我记住了。」｜EN “…I’ll remember that.”
- **G06｜旁白**｜CN「门被轻轻推开。坂口和阿尔托莉雅走到床边，先听护士交接监测记录，确认舞弥可以接受简短查房，才把注意力转向她。」｜EN “The door opened gently. Sakaguchi and Artoria approached, first receiving the nurse’s monitoring report and confirming Maiya was ready for a brief review before turning to her.”
- **G07｜坂口隆司**｜CN「舞弥，早上好。现在精神怎么样？」｜EN “Good morning, Maiya. How are you feeling?”
- **G08｜久宇舞弥**｜CN「早上好。看来我真的睡过了一整台手术。」｜EN “Good morning. It seems I really did sleep through an entire operation.”
- **G09｜阿尔托莉雅**｜CN「是的。你昨天非常认真地完成了最重要的一项工作。」｜EN “You did. And yesterday you carried out a very important task.”
- **G10｜久宇舞弥**｜CN「保持昏睡？」｜EN “Remaining unconscious?”
- **G11｜阿尔托莉雅**｜CN「让麻醉团队把你安全地带过那段时间。」｜EN “Allowing the anesthesia team to carry you safely through it.”
- **G12｜旁白**｜CN「舞弥抬眼看着她，似乎认真分辨了一下这算不算夸奖。阿尔托莉雅的神情却十分坦然。」｜EN “Maiya looked up, apparently deciding whether that was a compliment. Artoria’s expression remained entirely sincere.”
- **G13｜久宇舞弥**｜CN「手术……完成了吗？」｜EN “The operation… is finished?”
- **G14｜坂口隆司**｜CN「完成了。我们按计划切除了病灶及受累静脉段，建立了移植物通道，也完成了消化道重建。」｜EN “Yes. We removed the lesion and the involved venous segment as planned, established the graft connection, and completed the digestive reconstruction.”
- **G15｜久宇舞弥**｜CN「血管呢？」｜EN “And the vein?”
- **G16｜坂口隆司**｜CN「重建后已恢复血流，术中检查结果符合继续完成手术的条件。现在仍需要按术后计划严密观察。」｜EN “Flow was restored after reconstruction, and the intraoperative checks allowed us to proceed safely. We still need close postoperative surveillance.”
- **G17｜久宇舞弥**｜CN「病理结果？」｜EN “Pathology?”
- **G18｜坂口隆司**｜CN「正式结果还没出来。我们不会在报告前替它下最后结论。」｜EN “The final report isn’t back yet. We won’t make the final call before it arrives.”
- **G19｜旁白**｜CN「舞弥闭了闭眼，缓缓呼出一口气。她的指尖离开被单边缘，没有再去寻找床旁那块记录板。」｜EN “Maiya closed her eyes briefly and let out a slow breath. Her fingers relaxed from the edge of the blanket, and she did not look back toward the bedside chart.”
- **G20｜久宇舞弥**｜CN「那么，接下来我应该做什么？」｜EN “Then what should I do next?”
- **G21｜坂口隆司**｜CN「先恢复。疼痛、活动、进食和引流情况都需要由团队评估后逐步安排。」｜EN “Recover first. We’ll assess pain, mobility, eating, and drainage before advancing each part of the plan.”
- **G22｜久宇舞弥**｜CN「我可以自己记录吗？」｜EN “May I keep the records myself?”
- **G23｜病房护士**｜CN「你当然可以问，也可以了解每一项。但记录板上已经有一整队人替你写。」｜EN “You can certainly ask questions and follow everything. But there’s already an entire team writing the chart for you.”
- **G24｜久宇舞弥**｜CN「……一整队人。」｜EN “…An entire team.”
- **G25｜旁白**｜CN「她安静了一会儿，随后把目光从记录板移开，落在站在床边的两名医生身上。」｜EN “She fell silent for a moment, then let her eyes leave the chart and settle on the two doctors beside her.”
- **G26｜久宇舞弥**｜CN「昨天，阿尔托莉雅医生一直在台边？」｜EN “Dr. Artoria was at the table the entire time yesterday?”
- **G27｜阿尔托莉雅**｜CN「我一直在第一助手的位置。坂口医生带领了整台手术，团队的每一位同事也完成了自己的部分。」｜EN “I remained in the first assistant’s position. Dr. Sakaguchi led the operation, and every member of the team completed their part.”
- **G28｜久宇舞弥**｜CN「我想我明白了。」｜EN “I think I understand.”
- **G29｜旁白**｜CN「舞弥看向坂口，轻轻点头。那动作仍旧克制，却比术前任何一张签署完毕的表格都更像是她自己的回答。」｜EN “Maiya turned to Sakaguchi and nodded lightly. The gesture was restrained, yet it felt more like her own answer than any completed form from before the operation.”

**【选择 G-C3｜仅角色扮演；无数值／Gate／Flag 影响】**  
玩家可见选择：
- A「你已经做得很好。现在可以让我们接手。」／“You’ve done your part well. You can let us take over now.”
- B「要不要听听我们接下来的恢复计划？」／“Would you like to hear the next steps in your recovery plan?”

**【分支 A】**
- **G30A｜坂口隆司**｜CN「你已经做得很好。现在可以让我们接手，不必比我们更早知道每一项结果。」｜EN “You’ve done your part well. You can let us take over. You don’t have to learn every result before we do.”
- **G31A｜久宇舞弥**｜CN「这恐怕要花一点时间适应。不过……我会试试。」｜EN “That may take some getting used to. But… I’ll try.”

**【分支 B】**
- **G30B｜坂口隆司**｜CN「要不要听听我们接下来的恢复计划？你可以知道所有重要环节，不必自己执行每一项。」｜EN “Would you like to hear the recovery plan? You can understand every important step without carrying out all of them yourself.”
- **G31B｜久宇舞弥**｜CN「请说。知道有人负责，和必须自己负责，是两回事。」｜EN “Please. Knowing someone is responsible is different from having to be responsible myself.”

**【G-C3 汇合 → G32】**
- **G32｜阿尔托莉雅**｜CN「舞弥，先把眼睛闭一会儿吧。这里有人替你看着记录。」｜EN “Maiya, close your eyes for a little while. Someone here is watching the chart for you.”
- **G33｜久宇舞弥**｜CN「……这一次，我相信。」｜EN “…This time, I believe you.”
- **G34｜旁白**｜CN「她的手慢慢松开，平放在被单上。阿尔托莉雅替她把被角整理好。舞弥没有再抬头核对墙上的钟，任由病房安静下来。」｜EN “Her hand relaxed against the blanket. Artoria straightened its edge. Maiya did not look up to check the wall clock again, allowing the room to grow quiet.”
- **G35｜病房护士**｜CN「下一项监测时间到了。两位医生，剩下的交给我吧。」｜EN “It’s time for the next monitoring check. Doctors, I’ll take it from here.”
- **G36｜坂口隆司**｜CN「辛苦了。」｜EN “Thank you.”
- **G37｜旁白**｜CN「两名医生离开前，舞弥睁开眼睛，朝他们轻轻点了一下头。随后她重新闭眼，病房护士在床边继续记录。」｜EN “Before the doctors left, Maiya opened her eyes and gave them a small nod. Then she closed them again as the nurse resumed the bedside charting.”

---

### H. 没有人替你做的判断 / Decisions That Remain Yours

**【演出指示｜非显示】**  
地点：外科医局旁的小型术后复盘室。时间：Day3 病房查房后。  
画面：桌上摆着手术记录、复盘图和空白的后续医嘱确认单。坂口和阿尔托莉雅穿白大褂，手术帽、口罩、无菌袍均已脱下。室内没有他人，可以使用既定私人称呼。此场内容**不修改术中评分或结果**；对 WH09–WH12 的引用属于必经技术阶段，不假定玩家走了特定策略、发生了某种危机或遭遇精密失败。

- **H01｜旁白**｜CN「复盘室里只有两个人。阿尔托莉雅把厚厚的手术记录放在桌上，第一页已经被她用细小的书签标出几处关键阶段。」｜EN “There were only two people in the review room. Artoria laid the thick operative record on the table, with small tabs marking several important phases.”
- **H02｜坂口隆司**｜CN「我以为你会先让我回去睡一觉。」｜EN “I thought you were going to send me home to sleep first.”
- **H03｜阿尔托莉雅**｜CN「我本来是这么打算的。可是你刚才看着病房记录，已经在心里复盘第三遍了吧？」｜EN “That was my plan. But you were already reviewing the case for the third time while looking at her chart, weren’t you?”
- **H04｜坂口隆司**｜CN「……有那么明显？」｜EN “…Was it that obvious?”
- **H05｜阿尔托莉雅**｜CN「非常明显。」｜EN “Very.”
- **H06｜旁白**｜CN「她打开记录，没有先谈手术总时长，也没有先看结算评价。笔尖落在血管切除与移植物重建之间那一段。」｜EN “She opened the record without beginning with the total duration or the final evaluation. Her pen settled on the interval between venous resection and graft reconstruction.”
- **H07｜阿尔托莉雅**｜CN「这里。我想先听你的判断。为什么当时一定要在继续下一步前，再确认一次静脉轴向？」｜EN “Here. I want to hear your reasoning first. Why did you insist on checking the venous axis again before proceeding?”
- **H08｜坂口隆司**｜CN「因为一旦复灌，位置就不再只是纸上和视野里的问题。通畅、张力和走行都需要在那个节点重新核对。」｜EN “Because after reperfusion, the position is no longer just a matter of the plan and the view. Patency, tension, and course all have to be checked at that point.”
- **H09｜阿尔托莉雅**｜CN「正是这样。你先确认了能否安全继续，而不是被『终于快恢复血流了』的感觉催着向前。」｜EN “Exactly. You checked whether it was safe to proceed instead of being hurried along by the feeling that flow was almost restored.”
- **H10｜坂口隆司**｜CN「但那段还是很紧张。时间越久，我越能感觉到每个人在等这个确认。」｜EN “It was still tense. The longer it took, the more I could feel everyone waiting for that confirmation.”
- **H11｜阿尔托莉雅**｜CN「那不是坏事。压力不会因为你不看它就消失。关键是你有没有让它代替判断。」｜EN “That isn’t a bad thing. Pressure does not disappear because you refuse to look at it. What matters is whether you let it make the decision for you.”
- **H12｜旁白**｜CN「坂口低头看着那页记录。后面还有胰肠、胆肠、胃肠三处吻合，以及漫长的最终核对。」｜EN “Sakaguchi looked down at the record. Beyond that point lay three digestive anastomoses and a long final verification.”
- **H13｜坂口隆司**｜CN「血管复灌以后，我有一瞬间确实想松口气。可后面还有那么多工作。」｜EN “After reperfusion, I did want to relax for a moment. But there was still so much work ahead.”
- **H14｜阿尔托莉雅**｜CN「所以这台手术才不能只用『血管接好了』来概括。每一个阶段都要完整；你和我都知道，手术不会因为最醒目的难点过去就自动结束。」｜EN “That is why ‘we reconnected the vein’ cannot summarize this operation. Every phase must be complete. We both know a case does not end merely because its most conspicuous difficulty is behind us.”
- **H15｜坂口隆司**｜CN「第一次完整主刀这种规模的重建，我更清楚为什么你要求每一步都要能被团队验证。」｜EN “Leading a reconstruction of this scale from start to finish made me understand even more clearly why you insist that every step must be verifiable by the team.”
- **H16｜阿尔托莉雅**｜CN「那是为了患者。也是为了我们自己。一个人再有经验，也不该让整台手术只存在于自己的脑子里。」｜EN “It is for the patient. And for us. However experienced someone may be, an entire operation should never exist only inside one person’s head.”
- **H17｜坂口隆司**｜CN「你今天还会说『我来做会更快』吗？」｜EN “Would you still say, ‘It would be faster if I did it myself’?”
- **H18｜阿尔托莉雅**｜CN「在某些步骤上？也许会。」｜EN “For certain steps? Perhaps.”
- **H19｜旁白**｜CN「她回答得很坦然，反倒让坂口抬头笑了。」｜EN “She answered without hesitation, making Sakaguchi look up with a smile.”
- **H20｜阿尔托莉雅**｜CN「我们都还有比对方做得更熟练的事。那不是什么需要回避的事实。可今天，我在第一助手的位置上看得很清楚——你知道什么时候该继续，什么时候需要停下来听别人说话。」｜EN “Each of us still has things we do more fluently than the other. There is no reason to deny that. But from the first assistant’s position today, I could see clearly that you knew when to proceed and when to stop and listen.”
- **H21｜坂口隆司**｜CN「你在台边补充的意见，救了我很多次思考的时间。」｜EN “Your observations at the table saved me a great deal of time thinking through the next move.”
- **H22｜阿尔托莉雅**｜CN「那就是第一助手应该做的事。」｜EN “That is what a first assistant should do.”
- **H23｜坂口隆司**｜CN「你把这样一台手术交给我，不会觉得少了什么吗？」｜EN “Entrusting an operation like this to me—doesn’t it feel as if you’ve given something up?”
- **H24｜阿尔托莉雅**｜CN「少了什么？」｜EN “Given up what?”
- **H25｜坂口隆司**｜CN「比如说，原本完全属于你的技术。」｜EN “Something that used to be entirely your technique.”
- **H26｜旁白**｜CN「阿尔托莉雅没有立即回答。她把那份手术记录合上，指尖在封面上轻轻停了一下。」｜EN “Artoria did not answer immediately. She closed the operative record and rested her fingertips on its cover for a moment.”
- **H27｜阿尔托莉雅**｜CN「技术从来不会因为别人学会了，就从原来的人身上消失。」｜EN “A skill never disappears from its original owner because someone else has learned it.”
- **H28｜阿尔托莉雅**｜CN「我依然能做这台手术。你现在也能把完整的责任接起来。对星见医院而言，这是多了一双可靠的手，而不是少了一位主刀。」｜EN “I can still perform this operation. Now you can carry its full responsibility too. For Hoshimi, that means one more dependable pair of hands—not one fewer surgeon.”
- **H29｜坂口隆司**｜CN「听上去，你对这次的结果还算满意。」｜EN “That sounds as if you’re fairly satisfied with how this went.”
- **H30｜阿尔托莉雅**｜CN「我对舞弥现在的恢复情况感到欣慰。至于这份记录，我们以后还有许多地方值得继续讨论。」｜EN “I am relieved by Maiya’s current recovery. As for this record, there will be plenty for us to keep discussing.”

**【选择 H-C4｜仅角色扮演；无数值／Gate／Flag 影响】**  
玩家可见选择：
- A「你还真是不肯给我一个轻松的结业评语。」／“You really won’t give me an easy graduation verdict.”
- B「以后轮到你主刀，我也会这样认真做第一助手。」／“When you lead the next case, I’ll be just as thorough as your first assistant.”
- C「最值得记下来的，是今天所有人都在各自的位置上。」／“What’s most worth remembering is that everyone held their own position today.”

**【分支 A】**
- **H31A｜坂口隆司**｜CN「你还真是不肯给我一个轻松的结业评语。」｜EN “You really won’t give me an easy graduation verdict.”
- **H32A｜阿尔托莉雅**｜CN「你从来不是我的学生。这台也不是毕业考试。若你想要表扬，我可以另外写一份。」｜EN “You were never my student, and this was never a graduation examination. If you want praise, I can write you a separate note.”
- **H33A｜坂口隆司**｜CN「那还是留着写病历吧。」｜EN “Better save the paper for the medical record.”

**【分支 B】**
- **H31B｜坂口隆司**｜CN「以后轮到你主刀，我也会这样认真做第一助手。」｜EN “When you lead the next case, I’ll be just as thorough as your first assistant.”
- **H32B｜阿尔托莉雅**｜CN「当然。我若在台上有看漏的地方，也需要你直接指出来。」｜EN “Of course. If I overlook something while leading, I need you to say so directly.”
- **H33B｜坂口隆司**｜CN「一言为定。」｜EN “Agreed.”

**【分支 C】**
- **H31C｜坂口隆司**｜CN「最值得记下来的，是今天所有人都在各自的位置上。」｜EN “What’s most worth remembering is that everyone held their own position today.”
- **H32C｜阿尔托莉雅**｜CN「嗯。有人切开，有人牵开，有人监测，有人检查。今天每个岗位都没有缺席。」｜EN “Yes. Someone dissected, someone provided exposure, someone monitored, someone checked. Every role was present today.”
- **H33C｜坂口隆司**｜CN「也包括愿意把主刀位交出来的那个人。」｜EN “Including the person willing to let someone else lead.”
- **H34C｜阿尔托莉雅**｜CN「也包括真正接下那个位置的人。」｜EN “And the person who truly accepted that position.”

**【H-C4 汇合 → H35】**
- **H35｜旁白**｜CN「阿尔托莉雅把记录重新打开，把两人下一次需要复核的问题写在纸页边缘。没有奖章，没有夸张的仪式，只有几个具体得不能再具体的临床问题。」｜EN “Artoria reopened the record and noted the questions they still needed to review. No medal, no elaborate ceremony—only a handful of very concrete clinical questions.”
- **H36｜阿尔托莉雅**｜CN「走吧。再待下去，今晚我们恐怕又会讨论到半夜。」｜EN “Come on. If we stay, we’ll be discussing this until midnight again.”
- **H37｜坂口隆司**｜CN「你刚才明明已经准备好下一轮考试了。」｜EN “You had the next examination prepared already.”
- **H38｜阿尔托莉雅**｜CN「是复盘，不是考试。」｜EN “It’s a review, not an examination.”
- **H39｜坂口隆司**｜CN「我先把这句话记下来。」｜EN “I’ll make a note of that.”

---

### I. 今天的排程 / Today's Roster

**【演出指示｜非显示】**  
地点：外科医局旁的小型休息区与走廊饮水机。时间：Day3 复盘结束后。  
画面：与 Saber Lv5《我的位置》的手术室观察窗终场**完全不同的构图**：没有隔窗看训练团队，没有职务与主任谈话；这里是普通值班区域，墙上有下一周的手术排班板。两人仍穿白大褂，各自拿着纸杯，附近没有其他人在场，可以低声使用私人称呼。情绪克制、明朗、带一点自然的调侃。

- **I01｜旁白**｜CN「离开复盘室后，阿尔托莉雅在走廊饮水机旁停下，接了两杯水。坂口伸手接过其中一杯时，瞥见墙边刚更新的手术排班板。」｜EN “After leaving the review room, Artoria stopped at the corridor water dispenser and filled two cups. As Sakaguchi accepted one, he noticed the newly updated surgery roster on the wall.”
- **I02｜坂口隆司**｜CN「下周还有好几台大手术。你今天说的话，要不要当成以后把复杂病例都交给我的正式通知？」｜EN “There are several major operations next week. Should I take what you said today as official notice that all the difficult cases will be handed to me from now on?”
- **I03｜阿尔托莉雅**｜CN「当然不行。我还没有打算放弃自己喜欢的手术。」｜EN “Of course not. I have no intention of giving up the operations I love.”
- **I04｜坂口隆司**｜CN「那我放心了。」｜EN “That’s a relief.”
- **I05｜阿尔托莉雅**｜CN「不过，如果下次你主刀的病例需要我，而排班又允许……给我留个第一助手的位置。」｜EN “But if your next case needs me, and the roster allows it… save me a place as first assistant.”
- **I06｜坂口隆司**｜CN「我会认真考虑。不过我们也有很多优秀的同事，不一定每次都轮到你。」｜EN “I’ll consider it carefully. Though we have many excellent colleagues, so it won’t necessarily be your turn every time.”
- **I07｜阿尔托莉雅**｜CN「这才是正确的答案。」｜EN “That is the right answer.”
- **I08｜旁白**｜CN「她把水杯举到唇边，像终于结束了一场普通的术后会议。走廊另一端，有护士推着空转运床经过，车轮的声音很快远去。」｜EN “She raised the paper cup to her lips, as though an ordinary postoperative meeting had finally concluded. Far down the corridor, a nurse pushed an empty transfer stretcher past, its wheels fading into the distance.”
- **I09｜坂口隆司**｜CN「舞弥的事情，之后还需要我们一起盯着。」｜EN “We’ll still need to follow Maiya’s recovery together.”
- **I10｜阿尔托莉雅**｜CN「嗯。她正在学着把记录交给别人，我们却不能因此忘了继续做好记录。」｜EN “Yes. She’s learning to leave the chart in other people’s hands. That is all the more reason for us to keep it properly.”
- **I11｜坂口隆司**｜CN「放心。我已经准备好下一份交接表了。」｜EN “Don’t worry. I’ve already prepared the next handover sheet.”
- **I12｜阿尔托莉雅**｜CN「坂口君。」｜EN “Sakaguchi.”
- **I13｜坂口隆司**｜CN「嗯？」｜EN “Yes?”
- **I14｜阿尔托莉雅**｜CN「今天的交接，你做得很好。」｜EN “You handled today’s handover well.”
- **I15｜旁白**｜CN「坂口低头看了看手里的纸杯，还没来得及回答，阿尔托莉雅已经朝医局走去。她没有回头催促，只在门口略微放慢脚步，等他跟上来。」｜EN “Sakaguchi glanced down at his paper cup. Before he could answer, Artoria was already walking toward the medical office. She did not turn to hurry him, but slowed a little at the doorway until he caught up.”
- **I16｜坂口隆司**｜CN「阿尔托莉雅，等等。我还真有一份下周的排班要和你确认。」｜EN “Artoria, wait. I actually do have next week’s roster to go over with you.”
- **I17｜阿尔托莉雅**｜CN「那就走吧。我们还有工作。」｜EN “Then let’s go. We still have work to do.”
- **I18｜旁白**｜CN「两个人并肩走进明亮的医局。新一天的手术排程正等着他们，而这一次，桌上多了一份由坂口主刀完成的复杂重建记录。」｜EN “They entered the brightly lit office side by side. The next day’s surgical schedule was waiting, and among the records on the desk was a complex reconstruction now completed under Sakaguchi’s lead.”

**【FIRST_STORY END｜非显示】**  
本稿播放完毕仅完成「首次成功专属剧情已观看」的现有剧情收束流程。**严禁再次发放任何 Surgery XP、声望、奖励、Relationship 增量或返场资格**；这些事实此前已经由 Runner 原子结算。无新增 Saber 主任退出／支持坂口 flag；不自动预约 Staff-as-Patient。

---

## 附录 A｜完整分支与入口表

| 节点 | 前置／来源 | 播放内容 | 汇合或去向 | 持久状态 |
|---|---|---|---|---|
| FIRST_STORY Day1 | Saber Lv5 clear、Advanced 已解锁及公共传奇资格 | A01–A30 → B01–B38（B23 后顺序插入 B23_EX01、B23_EX02，非分支）→ C01–C34 → D01–D28 | 公共 Runner 推进 Day2 | 仅公共正常状态 |
| A-C1 | A25 后 | A26A–A28A 或 A26B–A28B | A29 | 无 |
| C-C2 | C26 后 | C27A–C28A / C27B–C28B / C27C–C28C | C29 | 无 |
| FIRST_STORY Day2 | Day1 已按 Runner 完成 | E01–E11 → F01–F14 → WH01–WH18 | Runner 决定手术成功／失败 | 不新增过场游标 |
| FIRST_STORY 成功 | WH18 后公共成功 | **先原子结算**，然后 G01–G37 → H01–H39 → I01–I18 | 首次故事结束、术式可返场 | 奖励与完成事实仅公共 Runner 写一次 |
| G-C3 | G29 后 | G30A–G31A 或 G30B–G31B | G32 | 无 |
| H-C4 | H30 后 | H31A–H33A / H31B–H33B / H31C–H34C | H35 | 无 |
| FIRST_STORY 失败 | 任一手术节点致失败 | 公共 Advanced 失败模板 | Day3 原子结算 **FAILED_LOCKED** | 不播放 G–I、不写成功；不会自动获得再次首通资格 |
| REPLAY | 首通已成功且满足 V2 周一双槽有放回返场资格 | 通用返场＋WH 阶段对白；一助走 GENERIC，即使选到 Saber | 公共结算；返场失败仍 **CLEARED** | 不播放本稿 A–I |

**注意：**B23 后的 B23_EX01/B23_EX02 是正式知情讨论的必要正文；**B36–B37** 的正式签署确认是本场医疗叙事的一部分，不是额外创建的独立 Gate。Day2 病人全麻后无主动对白。WH02–WH17 的一助 PRE 插在主刀 PRE01 后；WH01／WH18 的一助 PRE 放在主刀 PRE02 后；成功 POST 必须等待当前节点危机（包括 WH17 后 WH_C3）解除。其他优先级均以设计 V1.1 与当前 resolver 为准。

---

## 附录 B｜术式稿 Concept Lock 覆盖台账

| ID | 已确定要求 | 本稿对应 | 状态 |
|---|---|---|---|
| CL-MAI-01 | 患者固定为成年久宇舞弥；不输入原作年龄与悲剧宿命 | 全文 | PASS |
| CL-MAI-02 | 舞弥克制、专业、习惯先替别人承担，逐渐愿意接受照顾 | A、D、E、F、G | PASS |
| CL-MAI-03 | SPN 工作诊断、约 6 cm、PV/SMV 受累、Whipple＋Type IV | B、C、G；术中由关卡规格 | PASS |
| CL-MAI-04 | 术前理解与同意是真实可见的选择 | B、F | PASS，需素材配合 |
| CL-MAI-05 | Saber 是优秀的肝胆胰外科医生；主动把主刀完整责任交给坂口 | C、H | PASS |
| CL-MAI-06 | 首通 Saber 固定第一助手，回放助手自由选择 | B、C、附录 A；关卡规格 | PASS |
| CL-MAI-07 | 承接 Saber Lv5，不重演主任争夺、退选或额外角色升阶 | C、H、I | PASS |
| CL-MAI-08 | Day1 结束于术前计划，不提前转运或麻醉 | D | PASS |
| CL-MAI-09 | Day2 仅转运＋全麻短过场，然后实际操作 18 阶段 | E、F | PASS |
| CL-MAI-10 | 一张静态术野，不因 WH 阶段改变画面 | 0、F 接口 | PASS |
| CL-MAI-11 | Day3 先原子结算后成功专属剧情；失败统一模板 | 0、F 接口、G–I | PASS |
| CL-MAI-12 | 角色扮演选择只改变即时回应，不产生新 Gate／数值 | A-C1、C-C2、G-C3、H-C4 | PASS |
| CL-MAI-13 | 首通成功进入传奇返场池，返场不重播本剧本 | 0、附录 A | PASS |
| CL-MAI-14 | 术后病理与恢复过程保持合理时间感，不一日内全部康复 | G、I | PASS |
| CL-MAI-15 | 所有显示文本逐项提供英文；导演指示不误判为显示文字 | A–I + 0 | PASS |
| CL-MAI-16 | 脾静脉汇入口近端血管袖保留的个体解剖可行性 | 关卡设计 V1.1 的 0.1；C04–C06 | **NEEDS_MEDICAL_QA** |
| CL-MAI-17 | 角色立绘、术前／转运／病房演出素材与静态术野验收 | 各幕演出指示；关卡设计 V1.1 Art Manifest；视频视觉参考已选，最终资源仍待验收 | **NEEDS_ART_QA** |

## 附录 C｜编剧复核与交付边界

**本稿已锁定：**完整 Day1 A–D、Day2 E–F、Day3 G–I 的中文与英文正文、四个仅即时分支、具体角色出场与离场动作、麻醉前后状态区分、手术 Runner 交接、失败／成功／返场分流。已纳入 B23 后对延期及局部切除替代方案的简短说明，保留 B36–B37 正式签署与私人称呼的中英对应。**本次 V1.1 更新未改写任何 A–I 可见台词或四个选择按钮。**

**本稿没有做：**
- 不把本文误当为已导入的 Godot 运行文件；V1.1 已锁定数值在关联关卡设计中，不在 VN 重复定义。
- 不重写已完成的 18 阶段 PRE／POST、S 策略、P 失败对白。
- 不宣称临床用的脾静脉回流个体解剖假设已经通过医学审核。
- 不宣称当前病例、舞弥立绘、过场、唯一手术术野已实际接入游戏。

**文字口径：**手术技术术语和 Stage ID 以术式设计 **V1.1** 为准。人物与剧情正文已经通过用户审校，属于 **V1.1 Concept Lock**；如项目显示名字段出现真实接口矛盾，须先报告，不允许 Codex 在实装时临时润色人物对白。医学解剖可行性与最终美术资源的专项验收仍分别标记为 NEEDS_MEDICAL_QA、NEEDS_ART_QA，不能因为文字定稿而自动宣称它们也通过。
