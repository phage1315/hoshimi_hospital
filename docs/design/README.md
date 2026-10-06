# Design Documents

> **Writing authority:** [`HOSHIMI_PROJECT_WRITING_RULE_MEDICAL_NO_SELF_CENSORSHIP.md`](HOSHIMI_PROJECT_WRITING_RULE_MEDICAL_NO_SELF_CENSORSHIP.md) is the project’s highest-priority medical narrative and dialogue guide, subordinate only to platform rules. Read it before generating, translating, splitting, or editing story dialogue.

导入日期：2026-09-26。

本目录保存用户提供并纳入项目的设计资料。导入时保留原文；用户之后明确调整的正式设定（例如角色姓名）会同步到仓库副本，并重新登记校验值。其中的开发建议、写作规则和示例属于项目设计资料，不是自动执行脚本。具体实现仍以用户当次请求、当前代码结构和项目验证结果为准。

## 当前第一版：医院沙箱

当前开发以自由、有趣、可扩展、荒诞、成人向的医院生活模拟沙箱为唯一主方向。医院日常本身构成游戏循环，不加入必须推进的沉重悬疑主线。

当前版本的设计依据按以下顺序使用：

1. `HOSHIMI_PROJECT_WRITING_RULE_MEDICAL_NO_SELF_CENSORSHIP.md`：项目医疗剧情与对白的最高优先级写作规范；除平台规则外，禁止擅自淡化、跳过或含混处理作者明确要求的临床过程与反应。
2. `HOSHIMI_HOSPITAL_TONE_WORLDVIEW_FESTIVAL_GUIDE.md`：最高层世界观与情绪规范；定义“青春社团感”、高戏剧性低致死性、专业底线、失败转化为内容、成人反差、医院祭及一年期归属感。
3. `HOSPITAL_SANDBOX_DESIGN.md`：沙箱产品定位、循环、属性、角色、患者、手术、关系、结局与内容包架构。
4. `HOSPITAL_SANDBOX_DIALOGUE_GUIDE.md`：角色语气、关系阶段差异、手术室和患者对白的写作标准。
5. `HOSPITAL_SANDBOX_MEDICAL_FLIRT_GUIDE.md`：成年角色之间、随关系阶段变化的医疗身份调情规范。

第一版优先级是：稳定探索与时间循环、数据驱动的角色／患者／病例、关系发展、可重复手术、职业养成、多轴结算，以及能够持续添加的新内容包。单周目不要求收集全部内容。

人物专属设计另见 `SHIROIMIYA_ASUKA_EVENT_DESIGN.md`。城宮明日香当前已实现 Lv0 三段相识链；其院长身份只在第三段院长室事件中正式公开，Lv1–Lv5 仍保留为后续人物内容。

主角个人据点设计见 `PLAYER_OFFICE_SYSTEM_DESIGN.md`。当前已实现第一阶段：地图地点、独立背景、同事关系、患者病例、主角状态、职业履历、事件／CG鉴赏、时间记录与五项可选职业行动。论文、学会、装饰成长、年末收拾／续约和更完整的共同手术长期统计保留为后续阶段；现有第一版不会为这些未来功能创建重复属性。

序章职业背景补充见 `PROLOGUE_ONE_YEAR_CONTRACT_BACKGROUND.md`。当前实现明确主角结束海外研修、因旧导师推荐而来到星见，并以一年合同把这里视为暂时落脚点；导师动机及年末去留仍留给后续事件。

成人内容只涉及明确成年角色，并按关系、语气强度和事件条件分层。系统设计应允许内容分级或内容包切换；基础循环和人物关系不能依赖单一成人事件才能成立。

## 未来独立版本：CORE 叙事型医疗 VN

`CORE_VN_STORY_BIBLE.md` 保存已经确定的未来强剧情医学伦理悬疑方案。它与当前沙箱版共享“医院”题材，但不是当前版本的隐藏主线，也不应渗入当前随机患者、自由日程或关系系统。

未来启动 CORE 版本时，应建立独立的实现范围、信息分层、人物认知地图和 Reveal Ledger。Story Bible 中的上帝视角真相只能作为作者资料，不能自动成为角色或玩家知识。

## 原文校验值（SHA-256）

- `HOSPITAL_SANDBOX_DESIGN.md`：`49b8ec1ce85fe4c2dd7a12f9af41a00bc57219d59bfde7e61e7595e4ac943473`
- `HOSPITAL_SANDBOX_DIALOGUE_GUIDE.md`：`edc6f59b4fa63aec0f550a28437d97b5d7874a5d675e3a1ec66b8f7c750c698d`
- `CORE_VN_STORY_BIBLE.md`：`ef44f6d65231414f27678a820a7b758cf24a0b281249287486a5f9f0b874334a`
- `HOSPITAL_SANDBOX_MEDICAL_FLIRT_GUIDE.md`：`15714007c4cbda964d753f098254c0340d22838846cfcb66f3d6c5a4a157942b`
- `PLAYER_OFFICE_SYSTEM_DESIGN.md`：`333866a68f8d743d5a1795cbe3b27545ba4f471b871fbe05923dd30fe293a51f`
- `PROLOGUE_ONE_YEAR_CONTRACT_BACKGROUND.md`：`f6355e40eef6fd0a48ff596b55ce4177a0f4cd956493ef0e25f2dafa6db8f4f0`
- `HOSHIMI_HOSPITAL_TONE_WORLDVIEW_FESTIVAL_GUIDE.md`：`feadd4154741e3b4782da61cd1f3e0491b792cd520f28215353450cb66c25b94`

- `HOSHIMI_ARTORIA_DOCTOR_CHARACTER_V1.md`：阿尔托莉雅·潘德拉贡的医生定位、御堂竞争关系、领导型玩法、初见事件与未来关系路线设计。
- `HOSHIMI_NIGHT_SHIFT_NURSES_CHARACTER_INTEGRATION_V1.md`：神宮寺成美与七瀬恋的第二人生背景、职业定位、共同旧史及当前写作边界；项目注记明确旧四章 Lv1 已退役。
- `HOSHIMI_INGOKU_BYOTO_CHARACTER_INTEGRATION_V1.md`：朝倉美幸“新到星见而非护理新人”的职业基准；御園芹香部分仅作未来参考，本次未创建角色。
- `HOSHIMI_IBUKI_MAYA_VISITING_RESEARCHER_V1_2.md`：伊吹摩耶的访问研究医定位、生理监测与医疗仪器生态位及特殊助手规则；依据用户后续确认，当前关系实现只到相识 Lv0。
- `HOSHIMI_FUTABA_SAKURA_VISITING_PHYSICIAN_SCIENTIST_V1.md`：成年佐仓双叶的访问医师科学家定位、心身相互作用研究、与摩耶的联合访问关系及不可攻略边界。
- `HOSHIMI_ISHIGAMI_CHIZURU_CHARACTER_BIBLE.md`：石神千鹤的全院看護部長定位、职业信任路线、护理资源管理权限、高级转诊／公开教学手术护理指挥接口及当前不可攻略边界；相识事件接入口等待用户后续提供。
- `HOSHIMI_MIYAMA_KAORI_CHARACTER_BIBLE.md`：深山佳織的人物基准；运行时统一采用二代官设紫发身份。
- `HOSHIMI_MIYAMA_LV1_SAFETY_PIN_EVENT.md`：深山 Lv1《叮。》的病例与关系事件设计；手术台触诊暂用一键占位。
- `HOSHIMI_MIYAMA_LV1_LV3_CODEX_HANDOFF.md`：深山 Lv1／Lv3 事件交接稿；Lv3 正式裸穿手术服 CG 等待用户后续替换占位图。
- [通用特殊事件框架 v0.1](HOSHIMI_SPECIAL_EVENT_FRAMEWORK_V0_1.md)
- [手术失败与术中危机系统 v0.1](HOSHIMI_SURGERY_FAILURE_AND_CRISIS_SYSTEM_V0_1_2026-10-04.md)：普通手术以单一生理危机入口、三次补救和安全中止构成低致死性的成败系统；当前实现说明见 [术中危机系统实现](../surgery_crisis_system.md)。
- [手术台触诊术式相关性与提前下刀 v0.1](HOSHIMI_OR_PALPATION_RELEVANCE_AND_PREMATURE_INCISION_CODEX_V0_1_2026-10-04.md)：在保留现有点击与通用反应的基础上，增加腹部、乳房、妇科盆腔、开胸／心脏四种数据驱动相关性，以及一次性有效发现和独立的提前下刀流程。
- [可选触诊与麻醉感觉测试 v0.1](HOSHIMI_OPTIONAL_PALPATION_AND_ANESTHESIA_SENSORY_TEST_CODEX_V0_1_2026-10-04.md)：让术前触诊可以无惩罚跳过，并为局麻／硬膜外增加共用身体热点的可选手、针和手术刀感觉测试；覆盖结果由术式目标区域确定。
- [成人亲密互动系统 v0.1](HOSHIMI_H_SYSTEM_V0_1.md)：成年可攻略角色的文字前戏、兴奋度、主动权、地点／服装和 CG 选择设计；当前底层实现及逐角色资料清单见 [成人亲密互动底层模块](../adult_intimacy_system.md)。
- [术野 HUD 医护头像素材清单](../intraoperative_staff_avatar_checklist.md)：定义全体医护共用的紧凑头肩头像规格、数据键、回退规则和制作进度。

- `HOSHIMI_APPENDIX_GAMEPLAY_PILOT.md` — 阑尾切除术策略层 pilot：在既有线性手术流程上增加局部状态、基础效果与条件效果；已在 `surgery_appendix` 实装。

- `HOSHIMI_SURGERY_FAILURE_AND_CRISIS_SYSTEM_V0_1_2026-10-04.md`：`e6a2fe8265511b8d7def585219e5ae3edfdf294e4f31cb47dfd0920e6f3a0706`
- `HOSHIMI_OR_PALPATION_RELEVANCE_AND_PREMATURE_INCISION_CODEX_V0_1_2026-10-04.md`：`8bb550d9c6f054112c0a26847536f74471e877f76c9c495f5ae5324d3cf66355`
- `HOSHIMI_OPTIONAL_PALPATION_AND_ANESTHESIA_SENSORY_TEST_CODEX_V0_1_2026-10-04.md`：`2bcbc0a484d20d4be461549c62526dce35f295c0f5572f491d6106a2d595e3f1`
- `HOSHIMI_SATSUKI_LV1_REAL_PATIENT_TEST_V1.md`：`fbf7ee3ebd744c8dd1392493c7fc7c6261d0ddd2ae2444184171a565e70c2bf4`
- `HOSHIMI_ORIKAWA_SATSUKI_LV2_PATIENT_TRANSPORT_EVENT.md`：`cba24a512b86bea266a7c2ba54e50ad1c0d23ff7f8fb2e890270db888c76fff4`
- `HOSHIMI_H_SYSTEM_V0_1.md`：`c18268c1e96fabdd57ebf218a10b3046dc1017a6ce266a9baa783b7db39c2c0d`
- `HOSHIMI_PROJECT_WRITING_RULE_MEDICAL_NO_SELF_CENSORSHIP.md`：`bb6c60951f08e2ee52d0546365fdb1dcb8d300361f5dfdc7ed2d16021e663513`
- `HOSHIMI_SATSUKI_LV3_WRONG_PATIENT_APPENDectomy_V3_FORMATTED.md`：`3b8b209cdf17b03986fdb50a2f325797fabad4d84705bb5ca17b7b1a1ed37d59`

- `HOSHIMI_SATSUKI_LV1_REAL_PATIENT_TEST_V1.md`：折川皐月 Lv1《真人测试》正式事件稿；运行时实现与可选 CG 缺口见 `../satsuki_lv1_real_patient_test.md`。
- `HOSHIMI_ORIKAWA_SATSUKI_LV2_PATIENT_TRANSPORT_EVENT.md`：折川皐月 Lv2《陪我去一次》正式事件稿；运行时实现、固定患者资料与素材缺口见 `../satsuki_lv2_patient_transport.md`。