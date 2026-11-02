# Hoshimi Hospital — Advanced Regular #5 / #6 内容包 V1

**交接日期：** 2026-11-01  
**状态：** 编剧及 JSON 数据就绪；**未与游戏仓库合并、未做 Godot 运行时测试、美术未提供**。数值处于 P0 balancing。  
**适用范围：** 两台非传奇 Advanced Regular 首发转诊病例及其术式的通用返场。

## 1. 文件用途

| 文件 | 用途 |
|---|---|
| `procedures_additions.json` | 两个 `procedure` 对象，拟合并进现有 `data/advanced_surgery/procedures.json`；每台 12 阶段、6 P、2 S，含中英文名称、技术难度、HP、战略变量、两组 S 方案、两个危机检查点。 |
| `stories/surgery_adv_complex_abdominal_reconstruction.json` | 伊兹米·柯蒂斯（Izumi Curtis）Day 1 首发与 Day 3 **成功**故事；对话适配当前 `patient` / `PLAYER` story speaker 约束。 |
| `stories/surgery_adv_open_descending_thoracic_aortic_replacement.json` | 美纱（Misa）Day 1 首发与 Day 3 **成功**故事；完整身份待作者核准。 |
| `dialogue/*.json` | 两台术式逐阶段 Day 2 专业对白，每阶段 2 个 entry 备选；每个 P 阶段 2 个失败反馈备选。患者全麻，不产生患者意识对白。 |
| `art_manifest.json` | 图像需求清单。全部未提供图片的实际路径为 `null`；其中 `suggested_file` **仅供绘制时参考**。 |
| 包外 `HOSHIMI_ADVANCED_IZUMI_MISA_CODEX_READY_V1.md` | 人物、医学边界、阶段提示、解锁/结算/验收条件的完整人类可读规格。 |

## 2. 首发身份和不可擅改事项

| 顺序 | `procedure_id` | 患者 | 备注 |
|---|---|---|---|
| `release_order=5` | `surgery_adv_complex_abdominal_reconstruction` | **伊兹米·柯蒂斯** | 《钢之炼金术师》成年 AU；已失去器官不再生；保留丈夫席格，不可攻略。 |
| `release_order=6` | `surgery_adv_open_descending_thoracic_aortic_replacement` | **美纱** | 新获批的胸降主动脉开放置换术。**姓名已获作者确认**；`procedure_id` 为拟注册值；患者原作、全名、Character Bible 仍待核。 |

**2026-11-01 作者确认：第六位确实是「美纱」，不是「美织」。** 与最新高级转诊解锁规则一致；**姓名争议已经解除**。角色原作、全名与视觉锚点仍未在本包证实，不得据此擅自编造身份背景。

`source_case_id` 的 `ADV-FIRST-05`/`ADV-FIRST-06`、`runtime_case_id` 和 `patient.id` 均沿用旧内容包字段结构创建**候选字符串**。Codex 必须与本地实际 Case Registry 核对，必要时通过真实注册方法改名，不能假定这些 ID 已存在。

## 3. 接入流程

1. 先审计已经实装的四台 Advanced 及现有 JSON schema、Stage Runner、Grand OR、Referral Unlock/Replay、Story/Dialogue Loader、素材路径和 Save 逻辑；保留既有四台数据不变。
2. 将本包两项 procedure 录入现有 `data/advanced_surgery/procedures.json`。字段形态以可运行的既有病例为准；检验不会与原有 procedure ID 碰撞。更新专家标签映射时不得让护士担任外科 P 代打。
3. 将各自 `stories` 与 `dialogue` JSON 放入和现有四台相同的资源加载目录。Day 1/Day 3 中的 `PLAYER` 在显示时按既有机制映射到坂口。`stories.day3` **只有成功台词**。
4. 高级新病例 FIFO：已存在的 1–4 不动；#5 伊兹米、#6 美纱。按解锁规则到相应月份 1 日或 15 日发放新资格。若 #5 或 #6 `runtime_ready=false`，应**阻塞显示且不跨越该序位**，不得创建空白病例。
5. Day 1 接受与 Grand OR 编组、Day 2 正常全麻 Runner、Day 3 结算继续复用已有流程。**失败时仅调用现有 `dialogue/day3_failed.json` 的四句团队对白，绝不能另为伊兹米/美纱播放个人失败剧情。**
6. 周一从已首通 Advanced Regular 池中有放回抽取两个**独立**随机患者实例；允许重复术式、不重复首发人物剧情；**Advanced 不支持 Quick**。
7. 人物素材缺失时不要将 `suggested_file` 注册为真正的路径。实际美术资源存在并经过作者确认后，才设置 `field_windows` 与人物视觉绑定；按作者的最终角色锚点生成图，不使用 AI 临时外貌推断代替。
8. 第一台实际失败进入 `FAILED_LOCKED`、成功 `CLEARED`；首通结算必须在 Day 3 幂等写入，绝不因重载或重复点击发奖多次。

## 4. 术式区别

- **伊兹米**：存在因人体炼成而真正缺失的器官；手术为“安全松解症状相关黏连 + 维护侧支血供 + 保留器官的局部重建”，无凭空器官再生。手术叙事固定六个 P；别将其变成肿瘤根治切除或无目的广泛松解。
- **美纱**：左开胸、右侧卧、胸段**降主动脉**开放置换；左心旁路/远端灌注、人工血管近远端吻合、特定重要肋间分支重接。本案不是胸腹主动脉瘤 (TAAA) 重建；肋间重接为首发病例特定变体，不能无条件套用到所有返场患者。
- 两台均为**全麻**。手术台对话由主刀、助手、器械/巡回护士和麻醉团队提供，病人不在术中开口。

## 5. 当前阶段数据摘要

| 检验值 | 伊兹米 | 美纱 |
|---|---:|---:|
| 阶段总数 | 12 | 12 |
| `P` / `S` 数 | 6 / 2 | 6 / 2 |
| 起始 HP | 100 | 100 |
| `hp_base` 总和 | 40 | 44 |
| `duration_minutes` / 阶段分钟和 | 600 / 600 | 690 / 690 |
| 1-based `crisis_checkpoints` | 6, 9 | 5, 9 |
| `crisis_chances`（仅按已有 resolver 使用） | 0.26, 0.20 | 0.29, 0.23 |
| `physiology_tuning_status` | `P0_TUNING_PENDING_GAMEPLAY_APPROVAL` | 同左 |

`crisis_chances` 是 P0 估计值，不代表真实医学风险；若新版 Runner 依据实时生理变量解决危机，则不额外掷独立随机数。S 的每组两个选项都是游戏内**合理策略取舍**，不是“显然错误的诱饵按钮”，但需试玩调节风险、时间、视野效果。

**持久化严格限制：** 高级转诊稳定存档只写病例、预约、结果等事实。**不新增 stage/HP/seed/助手已用次数/剧情游标/选择路径**到该存档；术中进度沿用现有 Runner 会话，不另造存档协议。

## 6. 上线之前的停止条件

- 尚无用户认可的伊兹米/美纱美术、术野三态；`art_manifest` 并不代表资源存在。
- 美纱的**姓名已确认**；原作锚点及全名尚未核对，第六台 `procedure_id` 仍需核对真实 Registry。
- `difficulty`、HP、战略变量、危机概率尚未跑真实 Godot 玩家流程；仅为 P0 值。
- 尚未执行游戏仓库的实际一周两次返场、月度序位解锁、14 天助手冷却、Day 3 成败幂等、存档读写的回归测试。

因此**内容交付 ≠ `runtime_ready=true`**。Codex 实装时请明确报告所有 blocker，勿自行取消阻塞。
