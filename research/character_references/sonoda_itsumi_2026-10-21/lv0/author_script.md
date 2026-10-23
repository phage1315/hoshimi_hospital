# 星见医院｜薗田愛実 Lv0 多阶段相遇（C／D／E／F）
## 完整中文 VN 演出正文＋英文翻译｜Codex-Ready Writer Script｜2026-10-22

> **性质：** 正式完整脚本的**待作者审阅稿**，已具备逐句接入和翻译文本；不表示作者已批准全部台词，也不表示 Godot 已实装。
> **优先级：** 本文件取代旧 `itsumi_lv0_candidate_cn_en.json`（旧单场16节点候选），并填补 `HOSHIMI_SONODA_ITSUMI_LV0_CAMEO_CHAIN_DESIGN_2026-10-21.md` 中 C／D／E／F 仅有策划的空缺。旧策划关于门槛、客串与独立性继续有效。
> **参考规范：** `WRITING_GPT_CODEX_SCRIPT_GUIDELINES.md`；`HOSHIMI_INNAI_NURSE_ENSEMBLE_CHARACTER_BIBLE.md` §6；`HOSHIMI_INNAI_ANGEL_CALL_PROFILE_SCAN_SOURCE_ADDENDUM_2026-10-22.md` p037。

## 0. 事件定义、演员与演出锁（非玩家可见）

- **身份：** 薗田愛実，已确认的星见 AU 年龄 **20 岁**，外科年轻护士；弘子为 22 岁，既是护理学校前辈，也是本路线的介绍人。姓名必须使用「薗田愛実」，不能与其他护士混淆。
- **共同核心：** C/D 两场玩家遇见的「手术室值班护士」就是同一名愛実；她戴**完全遮发遮耳的手术帽＋正确系带口罩**，因此玩家当场看不清脸。F 才以完整露脸、**不戴帽不戴口罩**的白色护士制服正式认识。
- **发言者／显示名：** 在 C、D 所有台词中，实际演员始终是薗田愛実，但对话框显示「手术室值班护士」，**不是** `generic_nurse`；F 在弘子点名介绍后对话框显示「薗田愛実」。`met` 仍要等 F 结束时才写入，F 内暂时显示实名不能提前改状态。
- **场景：** C/D 是既有手术区**术后走廊**，不是手术室内或病房；E 是普通术后走廊遇见弘子；F 是正常护士站。背景资源和 sprite expression 的具体 ID 由 Codex 对照工程注册表映射，不凭作者备注造路径。
- **服装：** C/D 愛実为刷手服＋完全遮发遮耳帽＋系带式口罩；E 弘子用当时适用的正常工作服（实际出现于走廊，不强制为本事件另外换装）；F 爱实、弘子为日常护士制服。严禁在 F 因回忆 C/D 而将当前立绘跳回戴口罩状态；回忆只由对白与旁白表达。
- **节点说明：** `ITS-C-001` 之类仅是本稿**演出校对标号**，不是新引擎 API 或业务 flag。方括号中的表达、表情和场景转折给实现者，玩家只看到「旁白」正文和对白，不出现技术标号。无选项、无自动翻页假选项、无 H/关系数值奖惩。
- **事件状态：** C、D、E 只是匿名或未正式见面的剧情片段，不能让愛実提前出现在已认识列表。F 是唯一的 Lv0 正式相识与 `met` 写入点。四段从开始到结束都禁用事件中存档，沿用通用事件锁。

### 0.1 触发与结算（工程映射语义，不是代码字段名）

| 阶段 | 触发与顺序 | 正常完成的唯一结果 |
|---|---|---|
| C：第5台后：走廊转角 | 累计完成手术 ≥5；本段未播；合法术后手术区走廊；同一场景没有优先级更高的强制剧情。 | 记录本段已看过；不设置愛実已相识，不改变其熟悉度。 |
| D：第10台后：器械盘 | 累计完成手术 ≥10；C 已播；本段未播；合法术后手术区走廊。 | 记录本段已看过；不设置愛実已相识，不改变其熟悉度。 |
| E：第15台后：弘子的邀请 | 累计完成手术 ≥15；C、D 已播；已正式认识弘子（不要求弘子 Lv1）；本段未播；合法术后走廊。 | 记录邀请已发生；护士站正式介绍进入待触发状态；愛実仍未相识。 |
| F：护士站正式相识 | E 已完成；主动访问护士站；愛実尚未正式相识；未处在其他不可打断的事件中。 | 完整看完本段后才登记愛実已正式相识（Relationship Lv0）；完成一次性 Lv0 事件；不增加奖励、不提前进入 Lv1。 |

**错过事件的处理：** C/D/E 使用现有累计“完成正式手术”统计与 `>=` 门槛。只要条件已满足，合法术后时机未来仍可触发；同一次术后最多播放 C/D/E 中**一段**，绝不能因为累计已达 15 就连续播完前三段。E 若因弘子尚未相识而错过当时机遇，正式相识弘子后仍保留待触发，不增加新的手术数要求。F 只在 E 完成后由玩家**主动进入护士站**触发。

**既有客串不构成条件：** A 明日香《隔壁那台》、B 深山《先把事实说全》以及 G 遥凑 Lv2 中的客串均完全独立。A/B 已有正文不在这里重写或改台词。G 只对其**指定手术室值班护士槽位**做动态署名：未正式认识愛実显示「手术室值班护士」，已完成 F 显示「薗田愛実」，演员与口罩立绘始终不变。不要改动遥凑 Lv2 Gate、夜班护士或患者事故责任。

## 1. 正式中文 VN 演出正文

### C｜第5台后：走廊转角

【场景：手术部术后走廊｜演员：坂口隆司、手术室值班护士（实为薗田愛実）｜护士状态：刷手服／全遮发手术帽／系带口罩；不展示姓名】

**【事件节点 ITS-C-001｜发言者=旁白】**
旁白：手术结束后，坂口走出手术室，沿着手术部走廊向更衣区走去。

**【事件节点 ITS-C-002｜发言者=旁白】**
旁白：走廊另一头，一名年轻护士抱着交接资料快步走来。她戴着完全遮住头发和耳朵的手术帽，系带口罩遮住了大半张脸。

**【事件节点 ITS-C-003｜发言者=旁白】**
旁白：两人在转角处同时绕开一辆停放的推车，肩膀轻轻碰在了一起。护士急忙停住脚步，先扶稳手里的资料。

**【事件节点 ITS-C-004｜发言者=手术室值班护士｜表情语义=surprised】**
手术室值班护士：「啊！对不起！您没事吧？」

**【事件节点 ITS-C-005｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「没事。你呢？」

**【事件节点 ITS-C-006｜发言者=手术室值班护士｜表情语义=apologetic】**
手术室值班护士：「我也没事。刚才拐弯太急了，真不好意思！」

**【事件节点 ITS-C-007｜发言者=旁白】**
旁白：她向坂口点头致歉，又低头看了一眼夹在资料最上面的手术安排表。

**【事件节点 ITS-C-008｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「赶下一台？」

**【事件节点 ITS-C-009｜发言者=手术室值班护士｜表情语义=bright】**
手术室值班护士：「是！那边已经在等我了。不好意思，我先走啦！」

**【事件节点 ITS-C-010｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「路上小心。」

**【事件节点 ITS-C-011｜发言者=手术室值班护士｜表情语义=bright】**
手术室值班护士：「知道啦！谢谢您！」

**【事件节点 ITS-C-012｜发言者=旁白】**
旁白：年轻护士朝他轻轻挥手，便快步走向另一间手术室。

**【事件节点 ITS-C-013｜发言者=旁白】**
旁白：坂口望了眼她离开的方向，随后继续朝更衣区走去。

**【C 正常结算】** 记录本段已看过；不设置愛実已相识，不改变其熟悉度。

---

### D｜第10台后：器械盘

【场景：手术部术后走廊｜演员：坂口隆司、手术室值班护士（实为薗田愛実）｜护士状态：刷手服／全遮发手术帽／系带口罩；道具：术后器械车、落地器械、清点记录】

**【事件节点 ITS-D-001｜发言者=旁白】**
旁白：又一台手术结束。坂口走到手术部走廊时，前方一名戴着手术帽和系带口罩的年轻护士正在推送术后器械车。

**【事件节点 ITS-D-002｜发言者=旁白】**
旁白：推车拐过转角时，上层一只没有放稳的器械盘突然滑向边缘。

**【事件节点 ITS-D-003｜发言者=旁白】**
旁白：哐啷一声，器械盘落到地上，几件器械散在走廊里。

**【事件节点 ITS-D-004｜发言者=手术室值班护士｜表情语义=shocked】**
手术室值班护士：「呀！」

**【事件节点 ITS-D-005｜发言者=旁白】**
旁白：护士立即停下推车，稳住车身，先确认周围没人被砸到。

**【事件节点 ITS-D-006｜发言者=坂口隆司｜表情语义=concerned】**
坂口隆司：「没砸到脚吧？」

**【事件节点 ITS-D-007｜发言者=手术室值班护士｜表情语义=embarrassed】**
手术室值班护士：「没有，我没受伤。是我转弯的时候没把盘子放稳……」

**【事件节点 ITS-D-008｜发言者=手术室值班护士｜表情语义=serious】**
手术室值班护士：「糟糕……这下又得重新核对一遍了。」

**【事件节点 ITS-D-009｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「我帮你吧。」

**【事件节点 ITS-D-010｜发言者=手术室值班护士｜表情语义=relieved】**
手术室值班护士：「真的？太感谢了！我刚才还在想，一个人得收拾到什么时候呢。」

**【事件节点 ITS-D-011｜发言者=手术室值班护士｜表情语义=professional】**
手术室值班护士：「不过这是刚用过的器械，您先别直接碰散落的那些。能帮我扶住推车吗？」

**【事件节点 ITS-D-012｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「好。旁边这只空盘要挪开吗？」

**【事件节点 ITS-D-013｜发言者=手术室值班护士｜表情语义=professional】**
手术室值班护士：「麻烦您放到车旁边。掉到地上的器械要单独记录，再按规定回收处理。」

**【事件节点 ITS-D-014｜发言者=旁白】**
旁白：坂口扶稳推车，把备用空盘放到一旁。护士戴好防护手套，按规定收集落地的术后器械，并对照清单逐项核对。

**【事件节点 ITS-D-015｜发言者=旁白】**
旁白：她核对完最后一件器械，在清单上做了标记。

**【事件节点 ITS-D-016｜发言者=手术室值班护士｜表情语义=relieved】**
手术室值班护士：「……数量对上了。太好了，没有少。」

**【事件节点 ITS-D-017｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「这种时候还能核对得这么仔细，不错。」

**【事件节点 ITS-D-018｜发言者=手术室值班护士｜表情语义=earnest】**
手术室值班护士：「出了错，就更得把后面的事做好嘛。」

**【事件节点 ITS-D-019｜发言者=旁白】**
旁白：她抬起头，眼角又有了方才那股明快的笑意。

**【事件节点 ITS-D-020｜发言者=手术室值班护士｜表情语义=bright】**
手术室值班护士：「谢谢您！这次真是帮了大忙。」

**【事件节点 ITS-D-021｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「下次转弯慢一点。」

**【事件节点 ITS-D-022｜发言者=手术室值班护士｜表情语义=bright】**
手术室值班护士：「是！我记住了！啊，负责回收的同事还在等着，我得先走啦！」

**【事件节点 ITS-D-023｜发言者=旁白】**
旁白：她把器械车重新推稳，朝坂口点头致谢，沿着走廊离开。

**【D 正常结算】** 记录本段已看过；不设置愛実已相识，不改变其熟悉度。

---

### E｜第15台后：弘子的邀请

【场景：术后走廊｜演员：坂口隆司、杉村弘子｜不展示薗田愛実本人，不提前揭示她的名字】

**【事件节点 ITS-E-001｜发言者=旁白】**
旁白：手术结束后，坂口从手术区出来，在走廊遇见了拿着交接文件的杉村弘子。

**【事件节点 ITS-E-002｜发言者=杉村弘子｜表情语义=smile】**
杉村弘子：「坂口医生，您最近手术真不少呢。」

**【事件节点 ITS-E-003｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「是啊，忙得连休息的时间都不太有了。」

**【事件节点 ITS-E-004｜发言者=杉村弘子｜表情语义=gentle】**
杉村弘子：「呵呵，其实有件事想拜托您。」

**【事件节点 ITS-E-005｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「什么事？」

**【事件节点 ITS-E-006｜发言者=杉村弘子｜表情语义=gentle】**
杉村弘子：「我有个以前护理学校的后辈，最近一直跟我打听您。」

**【事件节点 ITS-E-007｜发言者=坂口隆司｜表情语义=surprised】**
坂口隆司：「打听我？」

**【事件节点 ITS-E-008｜发言者=杉村弘子｜表情语义=smile】**
杉村弘子：「她听说您最近在手术室很活跃，一直想找机会正式认识您。」

**【事件节点 ITS-E-009｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「是哪位护士？」

**【事件节点 ITS-E-010｜发言者=杉村弘子｜表情语义=gentle】**
杉村弘子：「外科的。她说在手术区遇见过您几次，还说您帮过她的忙。」

**【事件节点 ITS-E-011｜发言者=坂口隆司｜表情语义=thinking】**
坂口隆司：「帮过忙……好像有点印象。」

**【事件节点 ITS-E-012｜发言者=杉村弘子｜表情语义=gentle】**
杉村弘子：「她一直想亲自向您道谢，可每回遇见都忙着赶下一件事。」

**【事件节点 ITS-E-013｜发言者=杉村弘子｜表情语义=smile】**
杉村弘子：「您有空的时候，去护士站见见她吧。」

**【事件节点 ITS-E-014｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「当然。既然是弘子小姐的后辈，我也想认识。」

**【事件节点 ITS-E-015｜发言者=杉村弘子｜表情语义=smile】**
杉村弘子：「谢谢。她知道以后，一定会很高兴的。」

**【事件节点 ITS-E-016｜发言者=旁白】**
旁白：弘子微笑着收起文件，继续去处理交接。坂口记下了她的邀请。

**【E 正常结算】** 记录邀请已发生；护士站正式介绍进入待触发状态；愛実仍未相识。

---

### F｜护士站正式相识

【场景：护士站｜演员：坂口隆司、杉村弘子、薗田愛実｜爱实状态：白色日常护士制服、完整露发露脸、绝无口罩／手术帽】

**【事件节点 ITS-F-001｜发言者=旁白】**
旁白：坂口走进护士站。弘子站在工作台旁，正和一名年轻护士核对病房交接记录。

**【事件节点 ITS-F-002｜发言者=旁白】**
旁白：那名护士穿着整齐的白色工作制服，没有戴手术帽和口罩。红色的头发露在外面，笑起来十分明朗。

**【事件节点 ITS-F-003｜发言者=杉村弘子｜表情语义=smile】**
杉村弘子：「啊，坂口医生。您真的来了。」

**【事件节点 ITS-F-004｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「前几天说的那位后辈，在吗？」

**【事件节点 ITS-F-005｜发言者=杉村弘子｜表情语义=smile】**
杉村弘子：「在呀，就在这里。」

**【事件节点 ITS-F-006｜发言者=旁白】**
旁白：听见弘子的声音，年轻护士放下笔，转过身来。

**【事件节点 ITS-F-007｜发言者=杉村弘子｜表情语义=gentle】**
杉村弘子：「这位是薗田愛実，外科护士。以前在护理学校时，是我的后辈。」

**【事件节点 ITS-F-008｜发言者=薗田愛実｜表情语义=bright】**
薗田愛実：「您好！我是薗田愛実。终于能正式跟您打招呼了！」

**【事件节点 ITS-F-009｜发言者=旁白】**
旁白：愛実笑着微微鞠躬。坂口看着她，一时没把这张满是笑意的脸和走廊里的某个人联系起来。

**【事件节点 ITS-F-010｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「坂口隆司。请多指教。」

**【事件节点 ITS-F-011｜发言者=坂口隆司｜表情语义=thinking】**
坂口隆司：「不过……我们以前是不是在哪里见过？」

**【事件节点 ITS-F-012｜发言者=薗田愛実｜表情语义=playful】**
薗田愛実：「诶，坂口医生，您真的不记得我啦？」

**【事件节点 ITS-F-013｜发言者=坂口隆司｜表情语义=surprised】**
坂口隆司：「……我们以前见过？」

**【事件节点 ITS-F-014｜发言者=薗田愛実｜表情语义=bright】**
薗田愛実：「见过呀！之前在手术区走廊，我拐弯太急，差点撞到您。」

**【事件节点 ITS-F-015｜发言者=旁白】**
旁白：她抬起双手，做了个匆忙刹住脚步的动作。

**【事件节点 ITS-F-016｜发言者=坂口隆司｜表情语义=surprised】**
坂口隆司：「啊，原来是你！」

**【事件节点 ITS-F-017｜发言者=薗田愛実｜表情语义=bright】**
薗田愛実：「还有后来那次！我推着器械车，把盘子弄掉了，您帮我扶住车，还替我挪开了空盘。」

**【事件节点 ITS-F-018｜发言者=坂口隆司｜表情语义=surprised】**
坂口隆司：「……那也是你？」

**【事件节点 ITS-F-019｜发言者=薗田愛実｜表情语义=bashful】**
薗田愛実：「嘿嘿，都是我。不好意思，让您记住的好像净是些丢脸的事。」

**【事件节点 ITS-F-020｜发言者=旁白】**
旁白：坂口看着她露出的红发，又想起那两次隔着手术帽和口罩望过来的眼睛。

**【事件节点 ITS-F-021｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「难怪没认出来。那两次你把帽子和口罩都戴得严严实实的。」

**【事件节点 ITS-F-022｜发言者=薗田愛実｜表情语义=playful】**
薗田愛実：「当然啦！手术区可不能顶着这一头头发跑来跑去嘛。」

**【事件节点 ITS-F-023｜发言者=杉村弘子｜表情语义=gentle】**
杉村弘子：「她跟我提过器械盘的事。事后的清点和交接，她都认真处理好了。」

**【事件节点 ITS-F-024｜发言者=薗田愛実｜表情语义=embarrassed】**
薗田愛実：「弘子前辈……连这个也要跟坂口医生说呀？」

**【事件节点 ITS-F-025｜发言者=杉村弘子｜表情语义=smile】**
杉村弘子：「不是你自己先说的吗？」

**【事件节点 ITS-F-026｜发言者=旁白】**
旁白：愛実眨了眨眼，随即忍不住笑出声来。

**【事件节点 ITS-F-027｜发言者=薗田愛実｜表情语义=bright】**
薗田愛実：「啊哈哈，倒也是。」

**【事件节点 ITS-F-028｜发言者=薗田愛実｜表情语义=earnest】**
薗田愛実：「不过，那天您肯停下来帮忙，我真的很高兴。一直没能好好说一句谢谢。」

**【事件节点 ITS-F-029｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「举手之劳。后面的器械处理，你自己也做得很好。」

**【事件节点 ITS-F-030｜发言者=薗田愛実｜表情语义=smile】**
薗田愛実：「谢谢！听您这么说，我放心多了。」

**【事件节点 ITS-F-031｜发言者=杉村弘子｜表情语义=smile】**
杉村弘子：「那现在总算可以正式认识了吧？」

**【事件节点 ITS-F-032｜发言者=薗田愛実｜表情语义=bright】**
薗田愛実：「是！坂口医生，以后有机会一起上台的话，请多多关照！病房那边需要帮忙，也可以随时叫我。」

**【事件节点 ITS-F-033｜发言者=坂口隆司｜表情语义=normal】**
坂口隆司：「好。以后合作愉快，薗田护士。」

**【事件节点 ITS-F-034｜发言者=薗田愛実｜表情语义=bright】**
薗田愛実：「我也是！今天终于不是在走廊里匆匆打招呼了。」

**【事件节点 ITS-F-035｜发言者=旁白】**
旁白：打印机发出轻响，新一页交接记录送了出来。愛実转身将文件整理好，又朝坂口笑着点了点头。

**【F 正常结算】** 完整看完本段后才登记愛実已正式相识（Relationship Lv0）；完成一次性 Lv0 事件；不增加奖励、不提前进入 Lv1。


## 2. EN localization（逐节点对照；技术 node ID 与中文脚本逐一对应）

> 本节仅为**翻译资源**，不得在中文模式连着再播放一次；英语 speaker label 和现有 localization 键由 Codex 根据真实注册表映射。译文中的动作、姓名、演出次序均与中文节点一一对应。

### C｜第5台后：走廊转角

| 节点 | 说话人（逻辑） | English text |
|---|---|---|
| `ITS-C-001` | Narrator | After the operation, Sakaguchi leaves the operating room and heads along the surgical corridor toward the changing area. |
| `ITS-C-002` | Narrator | At the other end of the corridor, a young nurse approaches quickly with handover papers in her arms. A surgical cap covers all her hair and ears, and a tied surgical mask hides most of her face. |
| `ITS-C-003` | Narrator | They both step around a parked cart at the corner and lightly bump shoulders. The nurse stops at once and steadies the papers in her arms. |
| `ITS-C-004` | OR Duty Nurse (Itsumi, unnamed) | “Oh! I’m so sorry! Are you all right?” |
| `ITS-C-005` | Sakaguchi Ryuji | “I’m fine. How about you?” |
| `ITS-C-006` | OR Duty Nurse (Itsumi, unnamed) | “I’m fine, too. I took that corner too fast. I’m really sorry!” |
| `ITS-C-007` | Narrator | She bows her head in apology, then glances at the surgery schedule clipped to the top of her papers. |
| `ITS-C-008` | Sakaguchi Ryuji | “Heading to your next operation?” |
| `ITS-C-009` | OR Duty Nurse (Itsumi, unnamed) | “Yes! They’re waiting for me over there. Sorry again—I’d better go!” |
| `ITS-C-010` | Sakaguchi Ryuji | “Watch your step.” |
| `ITS-C-011` | OR Duty Nurse (Itsumi, unnamed) | “I will! Thank you!” |
| `ITS-C-012` | Narrator | The young nurse gives him a quick wave and hurries toward another operating room. |
| `ITS-C-013` | Narrator | Sakaguchi glances after her, then continues toward the changing area. |

### D｜第10台后：器械盘

| 节点 | 说话人（逻辑） | English text |
|---|---|---|
| `ITS-D-001` | Narrator | Another operation has finished. As Sakaguchi enters the surgical corridor, a young nurse in a surgical cap and tied mask is wheeling a cart of used surgical instruments ahead of him. |
| `ITS-D-002` | Narrator | As the cart rounds a corner, an instrument tray that was not sitting securely on the upper shelf suddenly slides toward the edge. |
| `ITS-D-003` | Narrator | With a clatter, the tray hits the floor and several instruments scatter across the corridor. |
| `ITS-D-004` | OR Duty Nurse (Itsumi, unnamed) | “Ah!” |
| `ITS-D-005` | Narrator | The nurse stops the cart at once, steadies it, and checks that nobody nearby was struck. |
| `ITS-D-006` | Sakaguchi Ryuji | “Nothing hit your foot, did it?” |
| `ITS-D-007` | OR Duty Nurse (Itsumi, unnamed) | “No, I’m not hurt. I didn’t make sure the tray was secure before turning…” |
| `ITS-D-008` | OR Duty Nurse (Itsumi, unnamed) | “Oh no… Now I’ll have to check everything again.” |
| `ITS-D-009` | Sakaguchi Ryuji | “Let me help you.” |
| `ITS-D-010` | OR Duty Nurse (Itsumi, unnamed) | “Really? Thank you so much! I was just wondering how long it would take to sort all this out alone.” |
| `ITS-D-011` | OR Duty Nurse (Itsumi, unnamed) | “But these instruments have just been used, so please don’t touch the ones on the floor. Could you hold the cart steady for me?” |
| `ITS-D-012` | Sakaguchi Ryuji | “Sure. Should I move this empty tray out of the way?” |
| `ITS-D-013` | OR Duty Nurse (Itsumi, unnamed) | “Please set it beside the cart. I need to record the instruments that fell and send them through the proper collection process.” |
| `ITS-D-014` | Narrator | Sakaguchi steadies the cart and sets the spare empty tray aside. The nurse puts on protective gloves, collects the used instruments according to procedure, and checks each item against the list. |
| `ITS-D-015` | Narrator | She checks the last instrument and marks it off on her list. |
| `ITS-D-016` | OR Duty Nurse (Itsumi, unnamed) | “…The count matches. Thank goodness—nothing’s missing.” |
| `ITS-D-017` | Sakaguchi Ryuji | “You kept the count thorough even after that scare. Nice work.” |
| `ITS-D-018` | OR Duty Nurse (Itsumi, unnamed) | “When you make a mistake, you’ve got to handle everything afterward properly.” |
| `ITS-D-019` | Narrator | She looks up, and the bright smile returns to her eyes. |
| `ITS-D-020` | OR Duty Nurse (Itsumi, unnamed) | “Thank you! You really saved me a lot of trouble.” |
| `ITS-D-021` | Sakaguchi Ryuji | “Take the next corner a little more slowly.” |
| `ITS-D-022` | OR Duty Nurse (Itsumi, unnamed) | “Yes! I’ll remember! Oh—the collection team is still waiting. I’d better get going!” |
| `ITS-D-023` | Narrator | She gets the instrument cart rolling steadily again, gives Sakaguchi a grateful nod, and heads down the corridor. |

### E｜第15台后：弘子的邀请

| 节点 | 说话人（逻辑） | English text |
|---|---|---|
| `ITS-E-001` | Narrator | After an operation, Sakaguchi leaves the surgical area and meets Sugimura Hiroko in the corridor, carrying handover documents. |
| `ITS-E-002` | Sugimura Hiroko | “Dr. Sakaguchi, you’ve certainly been doing a lot of surgery lately.” |
| `ITS-E-003` | Sakaguchi Ryuji | “I have. I’ve barely had time to take a break.” |
| `ITS-E-004` | Sugimura Hiroko | “Hehe. Actually, there’s something I wanted to ask you.” |
| `ITS-E-005` | Sakaguchi Ryuji | “What is it?” |
| `ITS-E-006` | Sugimura Hiroko | “A junior of mine from nursing school has been asking me about you lately.” |
| `ITS-E-007` | Sakaguchi Ryuji | “About me?” |
| `ITS-E-008` | Sugimura Hiroko | “She’s heard how active you’ve been in the operating rooms, and she’s wanted a chance to meet you properly.” |
| `ITS-E-009` | Sakaguchi Ryuji | “Which nurse is she?” |
| `ITS-E-010` | Sugimura Hiroko | “She works in surgery. She says she’s run into you in the surgical area a few times, and that you helped her out.” |
| `ITS-E-011` | Sakaguchi Ryuji | “Helped her out… That does ring a bell.” |
| `ITS-E-012` | Sugimura Hiroko | “She’s been wanting to thank you herself, but every time she sees you, she’s rushing off to the next task.” |
| `ITS-E-013` | Sugimura Hiroko | “When you have a moment, would you stop by the nurses’ station to meet her?” |
| `ITS-E-014` | Sakaguchi Ryuji | “Of course. I’d like to meet your junior, too.” |
| `ITS-E-015` | Sugimura Hiroko | “Thank you. I’m sure she’ll be delighted.” |
| `ITS-E-016` | Narrator | Hiroko smiles, gathers up her documents, and continues with the handover. Sakaguchi keeps her invitation in mind. |

### F｜护士站正式相识

| 节点 | 说话人（逻辑） | English text |
|---|---|---|
| `ITS-F-001` | Narrator | Sakaguchi enters the nurses’ station. Hiroko stands beside the work counter, checking ward handover records with a young nurse. |
| `ITS-F-002` | Narrator | The nurse wears a neat white uniform, with no surgical cap or mask. Her red hair is uncovered, and she has a bright, open smile. |
| `ITS-F-003` | Sugimura Hiroko | “Oh, Dr. Sakaguchi. You really came.” |
| `ITS-F-004` | Sakaguchi Ryuji | “Is that junior nurse you mentioned here?” |
| `ITS-F-005` | Sugimura Hiroko | “She is—right here.” |
| `ITS-F-006` | Narrator | Hearing Hiroko, the young nurse sets down her pen and turns around. |
| `ITS-F-007` | Sugimura Hiroko | “This is Sonoda Itsumi, a surgical nurse. She was my junior back in nursing school.” |
| `ITS-F-008` | Sonoda Itsumi | “Hello! I’m Sonoda Itsumi. I finally get to say hello properly!” |
| `ITS-F-009` | Narrator | Itsumi bows slightly with a smile. For a moment, Sakaguchi cannot connect this cheerful face with anyone he has seen in the corridors. |
| `ITS-F-010` | Sakaguchi Ryuji | “Sakaguchi Ryuji. It’s nice to meet you.” |
| `ITS-F-011` | Sakaguchi Ryuji | “Although… have we met somewhere before?” |
| `ITS-F-012` | Sonoda Itsumi | “Huh? Dr. Sakaguchi, you really don’t remember me?” |
| `ITS-F-013` | Sakaguchi Ryuji | “…We’ve met before?” |
| `ITS-F-014` | Sonoda Itsumi | “We have! In the surgical corridor, I took a corner too quickly and almost ran into you.” |
| `ITS-F-015` | Narrator | She raises both hands and mimics skidding to a hurried stop. |
| `ITS-F-016` | Sakaguchi Ryuji | “Oh, that was you!” |
| `ITS-F-017` | Sonoda Itsumi | “And that other time, later on! I was pushing an instrument cart and dropped a tray. You held the cart steady and moved the empty tray for me.” |
| `ITS-F-018` | Sakaguchi Ryuji | “…That was you, too?” |
| `ITS-F-019` | Sonoda Itsumi | “Hehe, both times. Sorry—it seems the only things I’ve given you to remember are embarrassing moments.” |
| `ITS-F-020` | Narrator | Sakaguchi looks at her uncovered red hair and remembers the eyes that looked at him from above a surgical mask on those two occasions. |
| `ITS-F-021` | Sakaguchi Ryuji | “No wonder I didn’t recognize you. Both times, your cap and mask covered you completely.” |
| `ITS-F-022` | Sonoda Itsumi | “Of course! I can’t exactly run around the surgical area with all this hair out!” |
| `ITS-F-023` | Sugimura Hiroko | “She told me about the instrument tray. She made sure the recount and handover were done properly afterward.” |
| `ITS-F-024` | Sonoda Itsumi | “Hiroko-senpai… Did you have to tell Dr. Sakaguchi that part, too?” |
| `ITS-F-025` | Sugimura Hiroko | “Weren’t you the one who brought it up?” |
| `ITS-F-026` | Narrator | Itsumi blinks, then breaks into laughter. |
| `ITS-F-027` | Sonoda Itsumi | “Ahaha, I suppose I did.” |
| `ITS-F-028` | Sonoda Itsumi | “But I really was happy that you stopped to help that day. I never got to thank you properly.” |
| `ITS-F-029` | Sakaguchi Ryuji | “It was no trouble. You handled the follow-up with those instruments well yourself.” |
| `ITS-F-030` | Sonoda Itsumi | “Thank you! That means a lot coming from you.” |
| `ITS-F-031` | Sugimura Hiroko | “Now can you two finally get properly acquainted?” |
| `ITS-F-032` | Sonoda Itsumi | “Yes! Dr. Sakaguchi, I hope we get to work together in surgery sometime! And if you need help on the ward, please feel free to call me.” |
| `ITS-F-033` | Sakaguchi Ryuji | “Of course. I look forward to working with you, Nurse Sonoda.” |
| `ITS-F-034` | Sonoda Itsumi | “Me too! At least today we finally got to talk without rushing past each other in a corridor.” |
| `ITS-F-035` | Narrator | The printer hums and delivers another handover sheet. Itsumi turns to sort the paperwork, then gives Sakaguchi one more cheerful smile and nod. |

## 3. Codex 接线清单与错误预防

1. **角色绑定**：C/D/G 指向唯一已注册愛実 actor，勿复制匿名 NPC；F 的实名显示可由**事件局部** speaker label 控制，但关系层 `met` 直到 F 最末成功播放才改变。
2. **既有素材**：使用原作锚点授权生成的正式立绘；C/D 的全遮发手术帽与系带口罩、F 的裸露头发白护士服必须是确实可用的不同素材。没有素材时报告缺口，不用默认 AI 脸或自动脱口罩代替。
3. **既有事件**：A 明日香护士长→值班护士（愛実演员）、B 深山报告护士→愛実（保留 M0-0043～M0-0049 原句）、G 遥凑 Lv2 指定值班护士的动态称谓，均不占用 C/D/E/F 次数，也不互设 Gate。
4. **叙事连续性**：F 回忆按 **C（走廊相撞）→D（器械盘落地）** 先后提及；此前策划示例中的「上次／上上次」顺序不可靠，本稿已统一为「之前……还有后来那次」，不要回退。
5. **医学与道具**：D 的术后器械已有污染风险，坂口只**扶推车／移动空盘**，愛実穿防护手套按流程收集并复点；不得让散落器械重新作为无菌器械使用。事件不改变手术质量、血量或任何 OR Gameplay。
6. **出场安排**：C/D/E 在正常“手术后”合法钩子排队；同一术后仅推进一段。别抢占其他已有强制术后事件，确保旧事件优先完成后下一次合法入口仍可推进。
7. **姓名泄露**：C/D 的对话框、自动日志、CG caption、立绘资源说明等玩家可见处不能展示「薗田愛実」；E 弘子只说后辈/外科护士。F 弘子介绍后才能在玩家可见部分显示实名。G 使用当时 `met` 判断姓名。
8. **年龄与数值**：愛実20岁、弘子22岁是已确认；六项专业能力、熟悉度倍率仍按现有 V2 数据审核状态，不因剧情自动批准拟议值。C/D/E 无额外奖励；F 只正式相识 Lv0。
9. **对照QA**：逐节点核对中文/英文 speaker、标点、顺序、旁白可见性、演出状态、演出完毕 flag 写入与中断回滚；C/D 与初见前遮名、F 正式相识、A/B/G 的独立时序都实际试玩。
10. **原作与AU**：不将原作男友正弘在星见的状态定案，也不加入未授权恋爱、Lv1、H 或患者手术事件；让愛実的活泼与专业能力在工作里同时成立。

### 3.1 代表性测试组合

| 测试情形 | 期待结果 |
|---|---|
| 已完成手术 >=15，尚未看 C | 下次术后只播 C；再下一合法术后播 D；再下一合法术后，弘子已认识则 E |
| 已达>=15且 C/D 已看，但弘子未正式相识 | E 挂起；认识弘子后在后续合法术后显示，不再要求刷更高次数 |
| E 已播放但还未主动到护士站 | 愛実仍未相识；F 不在术后自动播放；护士站访问触发 F |
| A/B/G 在 C/D/E 之前/之后触发 | 保持各自事件可用性，不改变愛実旗标，也不改变 C/D/E/F 门槛 |
| G 在 F 前播放 | 愛実口罩立绘，显示「手术室值班护士」；遥凑 Lv2 正常完成 |
| G 在 F 后播放 | 愛実口罩立绘，显示「薗田愛実」；遥凑 Lv2 正常完成 |
| F 已开始但被异常终止/读档 | 不得出现两人状态错置；爱实未标记已认识，或按完整事务结算恢复 |

**稿件统计：** C 13 节点；D 23 节点；E 16 节点；F 35 节点；共 87 节点。中文与英文均逐句齐全。

