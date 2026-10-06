# Hoshimi Hospital — 开腹阑尾切除 Gameplay Pilot
## `surgery_appendix` / Codex Implementation Spec

> **文件性质：Codex 可直接执行的试点实现规格**  
> **稳定文件名：** `HOSHIMI_APPENDIX_GAMEPLAY_PILOT.md`  
> **目标：** 在不推翻现有手术系统的前提下，把 `surgery_appendix` 从“确认 / 标准答案题”升级为第一台真正具有策略手感、团队反馈与患者互动的手术。  
> **本轮只做阑尾切除试点。不要推广到其他术式，直到试玩确认好玩。**

---

# 0. Codex 先读 / 先确认

在修改任何代码前，先搜索并确认当前运行时真正使用的手术数据源与执行逻辑。

至少搜索：

```text
surgery_appendix
surgeries.json
surgeries_expanded_v2.json
surgeries_expanded_v2_rebuilt.json
procedure_step_index
procedure_step_history
procedure_corrections
awake_interlude
patient_cues
success_condition
failure_condition
```

项目中可能同时存在多个历史 / 扩展版 surgery JSON。

**必须确认游戏运行时实际读取哪一个。**

禁止：

```text
同时修改多个平行 surgery 数据文件
为了“保险”复制一份新的 surgeries_v3.json
让 runtime 与设计文件出现两个 source of truth
```

正确做法：

> 只修改当前 runtime 真正使用的 canonical surgery 数据源，以及它依赖的 schema / runtime helper。

---

# 1. 这次试点要解决什么

当前阑尾切除的基本结构偏向：

```text
确认术野
→ 团队 flavor
→ 一道“正确答案”判断题
→ 完成
```

问题不是“步骤太少”本身，而是：

> 玩家几乎没有真正改变局面的决定。

这次试点的目标不是加入鼠标手术操作，也不是把阑尾切除做成 puzzle。

Hoshimi 的手术 Gameplay 原则：

> **不模拟玩家的手。**  
> **模拟主刀在术中的判断。**

技术动作本身由坂口完成。

玩家决定：

```text
现在要不要花时间改善暴露？
现在的术野够不够直接推进？
什么时候该稳一点？
什么时候可以抓住好窗口快速推进？
要不要让助手一起确认？
关闭前要不要多花时间复核？
```

---

# 2. 阑尾切除的 Gameplay Identity

本术式的试点定位：

> **简单、节奏快、允许果断推进，但前提是先把局面整理好。**

玩家应逐渐理解：

```text
准备条件
↓
创造好术野
↓
好窗口出现时快速推进
↓
如果前面把局面做坏，就需要花时间重新整理
```

重点：

> **Aggressive / 快速推进不是错误答案。**

如果 Visibility 好、Blood Loss 低：

> 快速推进应该是漂亮的选择。

如果 Visibility 已经很差：

> 同样的快速推进会让局面进一步恶化。

这台手术是未来 Strategy Layer 的最低难度教学样板。

---

# 3. 绝对兼容原则

本轮必须保留现有手术架构：

```text
surgery
├── id
├── name
├── duration_minutes
├── status
├── required_roles
├── initial_state
├── stages[]
├── success_condition
└── failure_condition
```

继续保留现有 stage kind：

```text
confirm
flavor
decision
```

继续保留线性流程：

```text
stages[0]
→ stages[1]
→ stages[2]
→ ...
```

继续保留并正常运行：

```text
procedure_step_index
procedure_step_history
procedure_corrections
awake_interlude
patient_cues
existing patient interaction system
existing anesthesia handling
existing team selection
existing surgery rewards / XP
existing success / failure handling
```

本轮**禁止**：

```text
新增 stage graph
新增 next_stage / goto
新增鼠标切割小游戏
新增随机并发症系统
新增 assistant stat check
新增患者永久属性
新增 bleeding 这一套新 global state
修改其他术式玩法
重写麻醉系统
重写患者互动系统
重做日历 / 时间系统
加入 Quick Surgery / Sweep（另一个任务）
```

---

# 4. 本轮最小 Schema 扩展

只允许给 surgery option 增加两个**可选字段**。

旧 option 没有这些字段时，行为必须 100% 保持不变。

## 4.1 `strategic_effects`

```json
{
  "strategic_effects": {
    "progress": 12,
    "elapsed_time": 8,
    "visibility": 15,
    "blood_loss": 0,
    "stability": 0
  }
}
```

本 pilot 只允许这些 key：

```text
progress
elapsed_time
visibility
blood_loss
stability
```

全部为 signed integer。

不允许本轮临时增加：

```text
bleeding
assistant_support
confidence
risk
```

原因：当前 active surgery state 已经有：

```text
stability
blood_loss
visibility
progress
elapsed_time
stress
```

Pilot 优先复用现有 state。

---

## 4.2 `conditional_effects[]`

允许某个 option 在当前状态满足条件时追加后果。

Schema：

```json
{
  "conditional_effects": [
    {
      "when": {
        "metric": "visibility",
        "operator": "<",
        "value": 75
      },
      "effects": {
        "visibility": -10,
        "blood_loss": 4
      },
      "response": "「等等——这里没有刚才看起来那么清楚。」",
      "response_role": "assistant_surgeon"
    }
  ]
}
```

Pilot 支持 operator：

```text
<
<=
>
>=
==
!=
```

每个 conditional entry 只判断**一个 metric**。

如果需要两个条件：

> 写两个 conditional entry。

不要为了本 pilot 增加复杂 boolean expression parser。

---

# 5. Runtime 执行顺序

玩家点击 option 后：

```text
1. 沿用现有 option selection / correct / correction 逻辑
2. 应用 strategic_effects
3. 依次检查 conditional_effects
4. 满足条件则追加 effects
5. 显示 conditional response（如果有）
6. Clamp 需要限制的 state
7. 沿用现有 awake_interlude / patient interaction
8. 沿用现有 procedure_step_history
9. 前进到下一个线性 stage
```

## 5.1 Clamp

```text
progress:   0–100
visibility: 0–100
stability:  0–100
blood_loss: >= 0
elapsed_time: >= 0
```

## 5.2 多个 conditional effect

如果多个条件成立：

> 全部生效。

例如：

```text
Visibility 太差
+
Blood Loss 已经偏高
```

可以同时得到两个代价。

这正是“坏状态累积”的预期效果。

---

# 6. `correct` 的使用原则

本 pilot 的策略选择**不是考试题**。

因此：

> 所有 Conservative / Standard / Fast / Ask Assistant 等合法策略选项，一律 `correct: true`。

不要因为玩家选择了风险较高的方案就：

```text
correct: false
```

否则又会退回：

> “猜标准答案”

而不是：

> “承担自己选择造成的局面”。

只有真正属于知识错误 / 无效操作的未来选项，才使用现有 `correct:false + correction`。

本阑尾 pilot 不需要这类选项。

---

# 7. 初始状态

保留：

```text
id: surgery_appendix
```

UI 名称如果当前 UI 已经采用新命名，则继续使用：

```text
开腹阑尾切除
```

推荐 initial state：

```json
{
  "stability": 100,
  "blood_loss": 0,
  "visibility": 60,
  "progress": 0,
  "elapsed_time": 0,
  "stress": 0
}
```

关键变化：

> **Visibility 不要从 100 开始。**

否则“改善暴露”没有任何 Gameplay 意义。

`duration_minutes` 保持当前设计值：

```text
60
```

注意：

> `duration_minutes` 是术式基准时长。  
> `elapsed_time` 是本台手术实际内部耗时。

本任务不要修改 calendar 对时间的使用方式。

---

# 8. 正式 Stage 设计

总计：

```text
9 stages
5 个 meaningful decision stages
4 个 confirm / transition stages
```

Progress 总和设计为恰好：

```text
100
```

---

# Stage 01 — 切开与进入

```yaml
id: abdominal_entry
title: 切开与进入
kind: confirm
```

Prompt：

> 切口完成，右下腹已经进入。团队等待坂口确认继续建立术野。

Option：

```text
[确认进入腹腔，继续]
```

Option data：

```json
{
  "id": "confirm_entry",
  "label": "确认进入腹腔，继续",
  "response": "「进入顺利，可以继续建立术野。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 8,
    "elapsed_time": 10,
    "visibility": 5
  }
}
```

Patient interaction：

```yaml
awake_interlude: operative_contact
patient_cues:
  - incision
  - pressure
```

目的：

> 建立“手术真的开始了”，不做知识考试。

---

# Stage 02 — 建立术野

```yaml
id: establish_exposure
title: 建立术野
kind: decision
```

此时大致：

```text
Visibility ≈ 65
```

Prompt：

> 回盲部区域已经可以观察，但暴露余量有限。接下来怎样建立术野？

## A — 标准暴露

```text
[按常规扩大暴露]
```

```json
{
  "id": "standard_exposure",
  "label": "按常规扩大暴露",
  "response": "「这样够了。右下腹的关系已经清楚很多。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 12,
    "elapsed_time": 8,
    "visibility": 15
  }
}
```

## B — 更充分暴露

```text
[再花一点时间，把术野做得更宽]
```

```json
{
  "id": "wide_exposure",
  "label": "再花一点时间，把术野做得更宽",
  "response": "「现在非常清楚。不过我们多花了一点时间。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 12,
    "elapsed_time": 12,
    "visibility": 25
  }
}
```

## C — 小暴露快速推进

```text
[现在已经能看见，先往下做]
```

```json
{
  "id": "minimal_exposure",
  "label": "现在已经能看见，先往下做",
  "response": "「可以，但余量不大。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 12,
    "elapsed_time": 5,
    "visibility": 5
  }
}
```

Patient interaction：

```yaml
awake_interlude: ongoing_interaction
patient_cues:
  - pressure
```

Gameplay 目的：

> 第一次告诉玩家：三项都是合法策略，没有“标准答案”。

---

# Stage 03 — 找到并确认目标

```yaml
id: identify_appendix
title: 找到阑尾
kind: decision
```

Prompt：

> 回盲部已经出现。现在需要找到并确认阑尾。

## A — 系统寻找

```text
[沿现有解剖关系逐步确认]
```

```json
{
  "id": "systematic_identification",
  "label": "沿现有解剖关系逐步确认",
  "response": "「确认到了。位置和周围关系都清楚。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 14,
    "elapsed_time": 6,
    "visibility": 5
  }
}
```

## B — 利用助手改善暴露

```text
[让助手调整牵拉，再确认]
```

```json
{
  "id": "assistant_retraction",
  "label": "让助手调整牵拉，再确认",
  "response": "「好，我来维持这里。现在看会容易很多。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 14,
    "elapsed_time": 7,
    "visibility": 12
  }
}
```

## C — 直接锁定目标

```text
[现在已经看得差不多，直接确认]
```

Base：

```json
{
  "id": "direct_identification",
  "label": "现在已经看得差不多，直接确认",
  "response": "「好，按你的判断继续。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 14,
    "elapsed_time": 4
  },
  "conditional_effects": [
    {
      "when": {
        "metric": "visibility",
        "operator": "<",
        "value": 75
      },
      "effects": {
        "visibility": -10,
        "blood_loss": 4
      },
      "response": "「等等——这里没有刚才看起来那么清楚。能继续，但现在反而把术野弄乱了。」",
      "response_role": "assistant_surgeon"
    }
  ]
}
```

Gameplay 目的：

```text
Stage 02 如果准备充分
→ C 是漂亮的快速选择

Stage 02 如果只做最小暴露
→ C 开始产生代价
```

这是本 pilot 最核心的机制验证之一。

Patient interaction：

```yaml
awake_interlude: ""
patient_cues: []
```

---

# Stage 04 — 游离阑尾

```yaml
id: mobilize_appendix
title: 游离阑尾
kind: confirm
```

Prompt：

> 阑尾已经被完整辨认，坂口与助手逐步完成周围组织的处理。

Option：

```text
[继续游离]
```

```json
{
  "id": "continue_mobilization",
  "label": "继续游离",
  "response": "「活动度出来了，可以进入下一步。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 10,
    "elapsed_time": 7,
    "visibility": -5
  }
}
```

Patient interaction：

```yaml
awake_interlude: strain_interaction
patient_cues:
  - traction
  - deep_manipulation
```

目的：

> 使用现有患者互动系统制造“患者还在台上”的存在感。

不要在这里硬编码专属患者对白。

---

# Stage 05 — 处理连接区域

```yaml
id: control_attachment
title: 处理连接区域
kind: decision
```

Prompt：

> 阑尾已经能够活动。接下来需要处理连接区域，目前术野仍然可以继续。

## A — 稳妥处理

```text
[放慢一点，逐步处理]
```

```json
{
  "id": "careful_control",
  "label": "放慢一点，逐步处理",
  "response": "「好，按这个节奏来。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 14,
    "elapsed_time": 8,
    "visibility": 2,
    "blood_loss": 2
  }
}
```

## B — 标准节奏

```text
[按标准节奏继续]
```

```json
{
  "id": "standard_control",
  "label": "按标准节奏继续",
  "response": "「明白，继续。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 14,
    "elapsed_time": 6,
    "blood_loss": 4
  }
}
```

## C — 快速推进

```text
[术野还可以，快速推进]
```

```json
{
  "id": "fast_control",
  "label": "术野还可以，快速推进",
  "response": "「好，跟你的节奏。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 14,
    "elapsed_time": 4,
    "blood_loss": 6
  },
  "conditional_effects": [
    {
      "when": {
        "metric": "visibility",
        "operator": "<",
        "value": 70
      },
      "effects": {
        "visibility": -8,
        "blood_loss": 6
      },
      "response": "「慢一点。现在已经不是刚才那个术野了。」",
      "response_role": "assistant_surgeon"
    }
  ]
}
```

Patient interaction：

```yaml
awake_interlude: ""
patient_cues:
  - traction
```

Gameplay 目的：

> 再次强化“快速不是错，但坏状态下继续快会累积代价”。

---

# Stage 06 — 不可逆步骤前确认

```yaml
id: irreversible_commitment
title: 关键步骤前确认
kind: decision
```

这是本台最重要的判断节点。

Prompt：

> 已经来到主要不可逆步骤前。坂口需要决定是否现在继续。

如果当前 surgery HUD 已经明显显示：

```text
Visibility
Blood Loss
Elapsed Time
```

不要再做新 UI。

如果当前 HUD 不够明显，则仅在本 stage 与 Stage 08 增加一行定性摘要：

```text
术野：非常清楚 / 尚可 / 较差
失血：很少 / 有一些 / 明显
用时：XX 分钟
```

建议显示规则：

```text
Visibility >= 80  → 非常清楚
Visibility 65–79  → 尚可
Visibility < 65   → 较差

Blood Loss <= 8   → 很少
Blood Loss 9–18   → 有一些
Blood Loss > 18   → 明显
```

不要显示：

```text
17.3% complication chance
```

## A — 现在继续

```text
[现在条件已经足够，继续]
```

```json
{
  "id": "commit_now",
  "label": "现在条件已经足够，继续",
  "response": "「明白，继续。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 18,
    "elapsed_time": 4
  },
  "conditional_effects": [
    {
      "when": {
        "metric": "visibility",
        "operator": "<",
        "value": 75
      },
      "effects": {
        "visibility": -8,
        "blood_loss": 5
      },
      "response": "「能做，但你是在一个并不漂亮的局面里硬推进。」",
      "response_role": "assistant_surgeon"
    },
    {
      "when": {
        "metric": "blood_loss",
        "operator": ">",
        "value": 15
      },
      "effects": {
        "stability": -5
      },
      "response": "「失血已经开始累积。继续可以，但代价在变大。」",
      "response_role": "assistant_surgeon"
    }
  ]
}
```

如果玩家前面做得好：

> A 应该是最漂亮、最快的选择。

## B — 重新整理术野

```text
[先重新整理术野]
```

```json
{
  "id": "reestablish_field",
  "label": "先重新整理术野",
  "response": "「好。现在重新把条件做干净。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 18,
    "elapsed_time": 8,
    "visibility": 12,
    "blood_loss": 1
  }
}
```

## C — 请助手复核

```text
[请助手一起复核当前条件]
```

```json
{
  "id": "assistant_recheck",
  "label": "请助手一起复核当前条件",
  "response": "「我也看清楚了。现在可以。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 18,
    "elapsed_time": 6,
    "visibility": 6,
    "blood_loss": 1
  }
}
```

Patient interaction：

```yaml
awake_interlude: progress_check
patient_cues:
  - deep_manipulation
```

如果患者清醒，现有 Patient Interaction 可以在这里插入：

```text
“现在做到哪里了？”
“是不是出了什么问题？”
```

处理仍走现有系统。

---

# Stage 07 — 完成主要处理

```yaml
id: specimen_complete
title: 主要处理完成
kind: confirm
```

Prompt：

> 主要处理完成，标本已经取出。团队开始重新检查术野。

Option：

```text
[继续检查术野]
```

```json
{
  "id": "continue_after_specimen",
  "label": "继续检查术野",
  "response": "「标本完成。现在看最后的术野。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 8,
    "elapsed_time": 6,
    "visibility": -5
  }
}
```

Patient interaction：

```yaml
awake_interlude: ""
patient_cues:
  - deep_manipulation
```

不要硬编码患者台词。

---

# Stage 08 — 关闭前复核

```yaml
id: final_review
title: 关闭前复核
kind: decision
```

Prompt：

> 阑尾已经切除。术野目前没有明显异常。关闭前准备怎样复核？

如果 HUD 不足，沿用 Stage 06 的定性摘要。

## A — 快速复核后关闭

```text
[情况很好，快速确认后关闭]
```

```json
{
  "id": "quick_final_review",
  "label": "情况很好，快速确认后关闭",
  "response": "「好，做最后确认。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 10,
    "elapsed_time": 4
  },
  "conditional_effects": [
    {
      "when": {
        "metric": "visibility",
        "operator": "<",
        "value": 70
      },
      "effects": {
        "stability": -5
      },
      "response": "「等一下。我觉得这里值得再看一眼。」",
      "response_role": "assistant_surgeon"
    },
    {
      "when": {
        "metric": "blood_loss",
        "operator": ">",
        "value": 18
      },
      "effects": {
        "stability": -5,
        "elapsed_time": 3
      },
      "response": "「失血比一开始多。先别把关闭做得太快。」",
      "response_role": "assistant_surgeon"
    }
  ]
}
```

## B — 完整复核

```text
[再仔细检查一遍]
```

```json
{
  "id": "full_final_review",
  "label": "再仔细检查一遍",
  "response": "「复核完成，没有遗漏。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 10,
    "elapsed_time": 7,
    "visibility": 10
  }
}
```

## C — 团队共同复核

```text
[让助手一起复核，再准备关闭]
```

```json
{
  "id": "team_final_review",
  "label": "让助手一起复核，再准备关闭",
  "response": "「我这边也确认完成。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 10,
    "elapsed_time": 5,
    "visibility": 5
  }
}
```

Patient interaction：

```yaml
awake_interlude: ""
patient_cues: []
```

Gameplay 目的：

> 如果前面状态漂亮，快速结束是奖励。  
> 如果前面把局面做坏，最后需要为此付时间 / stability 代价。

---

# Stage 09 — 关闭

```yaml
id: closure
title: 关闭切口
kind: confirm
```

Prompt：

> 最终检查完成，可以关闭切口。

Option：

```text
[完成手术]
```

```json
{
  "id": "complete_surgery",
  "label": "完成手术",
  "response": "「确认完成。手术结束。」",
  "response_role": "assistant_surgeon",
  "correct": true,
  "correction": "",
  "strategic_effects": {
    "progress": 6,
    "elapsed_time": 8
  }
}
```

Patient interaction：

```yaml
awake_interlude: closure_interaction
patient_cues:
  - closure
```

Progress 至此：

```text
100
```

继续使用现有：

```json
"success_condition": {
  "metric": "progress",
  "operator": ">=",
  "value": 100
},
"failure_condition": {
  "metric": "stability",
  "operator": "<=",
  "value": 0
}
```

不要改成新的胜负系统。

---

# 9. Progress 核对

固定 Progress：

```text
Stage 01   +8
Stage 02  +12
Stage 03  +14
Stage 04  +10
Stage 05  +14
Stage 06  +18
Stage 07   +8
Stage 08  +10
Stage 09   +6
----------------
Total     100
```

因此：

> 不需要新建 progress completion 逻辑。

---

# 10. 预期三种试玩路线

## 10.1 Balanced / 熟练路线

示例：

```text
Stage 02 A 标准暴露
Stage 03 A 系统确认
Stage 05 B 标准节奏
Stage 06 A 条件够好直接推进
Stage 08 A 快速复核
```

预期：

```text
约 60 min
Visibility 保持良好
Blood Loss 低
Stability 几乎不受影响
```

玩家感觉：

> “我不是因为选了保守答案才成功，而是因为前面把条件准备好了，所以后面可以快。”

---

## 10.2 Conservative / 稳妥路线

示例：

```text
Stage 02 B 更充分暴露
Stage 03 B 助手改善牵拉
Stage 05 A 稳妥处理
Stage 06 B 重新整理
Stage 08 B 完整复核
```

预期：

```text
约 70–75 min
Visibility 很高
Blood Loss 很低
Stability 维持漂亮
```

玩家感觉：

> “非常稳，但我为了这种稳多花了时间。”

---

## 10.3 Aggressive / 连续强推路线

示例：

```text
Stage 02 C 最小暴露
Stage 03 C 直接确认
Stage 05 C 快速推进
Stage 06 A 继续强推
Stage 08 A 快速关闭
```

预期：

```text
前半段很快
Visibility 越来越差
Blood Loss 开始累积
助手多次明确提醒
Stability 可能下降 5–15
仍然大概率完成手术
```

重点：

> 这不是“选错 → Game Over”。

而是：

> **玩家亲手把一台简单手术做得越来越难看。**

这符合 Hoshimi 的错误设计原则：

```text
坏选择
→ 局面恶化
→ 团队指出问题
→ 玩家仍有机会完成
```

---

# 11. 团队互动要求

本 pilot **不实现完整 Assistant Intelligence 系统**。

但助手必须至少在以下节点产生与当前局面相关的反馈：

```text
Stage 02
→ 评价暴露

Stage 03
→ 参与牵拉 / 对低 Visibility 直接推进作出提醒

Stage 05
→ 对坏术野下继续快速推进作出提醒

Stage 06
→ 不可逆步骤前参与复核 / 对不佳局面发出反馈

Stage 08
→ 关闭前共同复核 / 提醒不要过快收尾
```

避免所有对白都写成：

> 「确认，可以继续。」

目标：

> 玩家必须感觉助手看得见自己刚才做出的决定。

本 pilot 仍然只使用：

```text
response_role: assistant_surgeon
```

不要在这一轮加入：

```text
assistant observation stat
assistant intervention stat
assistant_support resource
```

---

# 12. 患者互动要求

不要为阑尾 pilot 新建另一套患者系统。

继续使用现有：

```text
fear
pain
dignity
cooperation
awake_interlude
patient_cues
procedure-specific interaction matching
```

重点 stage：

```text
Stage 01
operative_contact
incision / pressure

Stage 02
ongoing_interaction
pressure

Stage 04
strain_interaction
traction / deep_manipulation

Stage 06
progress_check
deep_manipulation

Stage 09
closure_interaction
closure
```

## 12.1 全麻

保持现有低互动逻辑。

本 pilot 不改变全麻规则。

## 12.2 清醒路线

患者可能在对应节点产生：

```text
“已经开始了吗？”
“刚才里面被拉了一下……”
“现在做到哪里了？”
“是不是快结束了？”
```

具体文本必须继续由现有 Patient Interaction / Procedure-Specific Dialogue 系统匹配。

不要把大量患者对白硬编码进 `surgery_appendix`。

---

# 13. UI 要求

本轮不要做大规模 UI 重构。

最低要求：

1. 玩家当前已有 surgery HUD 继续工作。
2. `Visibility / Blood Loss / Elapsed Time / Stability` 的变化必须能被玩家观察到。
3. 如果当前 HUD 不足以让玩家看懂 Stage 06 / 08 的局面，只增加**定性摘要**，不要新造复杂面板。
4. 不显示精确风险百分比。
5. 条件触发后的助手对白必须明显出现，不能只在后台改数字。

---

# 14. 本轮不要加入 RNG

Pilot 必须 deterministic：

```text
相同初始状态
+
相同选择
=
相同结果
```

原因：

> 现在测试的是“决策结构好不好玩”，不是 RNG 好不好玩。

未来阑尾 Gameplay 验证成功以后，再单独接：

```text
adhesion
anatomy_variation
inflamed tissue
exposure difficulty
```

等 case modifiers。

不要提前混进本轮。

---

# 15. 与其他术式的隔离

本轮必须做到：

```text
surgery_appendix
→ 使用 strategic_effects / conditional_effects

其他 24+ surgery
→ 没有这些字段时行为完全不变
```

如果 runtime 对 optional field 处理正确，则以后才能逐台推广。

本轮不要顺手：

```text
给胆囊也改一版
给乳房也改一版
批量自动生成 strategic_effects
```

先把阑尾试玩完成。

---

# 16. 自动化 / 单元测试要求

至少增加以下测试。

## Test A — Legacy surgery compatibility

选择任一未修改术式。

验证：

```text
没有 strategic_effects
没有 conditional_effects
→ runtime 与修改前一致
```

---

## Test B — Strategic effects application

在 `surgery_appendix` Stage 02 选择标准暴露。

验证：

```text
progress +12
elapsed_time +8
visibility +15
```

---

## Test C — Conditional effect not triggered

Stage 03 C 前：

```text
visibility >= 75
```

选择直接确认。

验证：

```text
不追加 blood_loss
不追加 visibility penalty
```

---

## Test D — Conditional effect triggered

Stage 03 C 前：

```text
visibility < 75
```

选择直接确认。

验证：

```text
blood_loss +4
visibility -10
显示 assistant warning
```

---

## Test E — Multiple conditional effects

Stage 06 A 前设定：

```text
visibility < 75
blood_loss > 15
```

验证两个 conditional entry 都生效。

---

## Test F — Clamp

构造：

```text
visibility 95 + 25
```

最终：

```text
visibility = 100
```

并验证：

```text
stability 不低于 0
progress 不高于 100
blood_loss 不低于 0
elapsed_time 不低于 0
```

---

## Test G — Progress completion

按任意合法路线完成 9 stages。

验证：

```text
progress == 100
existing success_condition 正常触发
```

---

## Test H — Patient interaction compatibility

分别测试：

```text
General anesthesia
Awake / non-general route
```

确认：

- 全麻没有被强制插入大量清醒患者对白；
- 清醒患者仍通过现有 `awake_interlude + patient_cues` 系统产生互动；
- 不出现 procedure group 错位对白。

---

# 17. 手工 Playtest 验收标准

实现完成后，不要立即推广。

至少人工完整跑：

```text
Balanced
Conservative
Aggressive
```

三条路线。

必须回答以下问题：

## 17.1 节奏

第一次完整玩：

> **现实时间约 5–8 分钟内能完成。**

患者互动会增加一些时间，但不应让普通阑尾拖成 15–20 分钟的点击劳动。

---

## 17.2 决策数量

必须至少有：

> **5 个真正会改变 Time / Visibility / Blood Loss / Stability 的 decision stage。**

但不应每一步都弹三选一。

---

## 17.3 玩家能否理解因果

玩家应能明显感觉：

> “我前面把术野整理好了，所以现在敢快。”

以及：

> “我连续强推，把术野做坏了。”

如果玩家只看到数字变化但不知道为什么：

> Pilot 未通过。

---

## 17.4 后果不能只有 Game Over

较差路线仍应大概率完成。

代价表现为：

```text
耗时增加
Visibility 下降
Blood Loss 增加
Stability 小幅下降
助手开始警告
```

不要让普通阑尾因为一次不理想选择突然死亡 / Game Over。

---

## 17.5 团队必须“看见玩家”

至少数次出现：

> 助手根据当前局面而不是固定脚本，对玩家刚才的选择作出合理反馈。

如果助手仍然全程只是：

> 「确认，可以继续。」

Pilot 未通过。

---

## 17.6 患者必须仍然存在

清醒患者路线至少要让玩家感觉：

> 患者不是一张背景 CG，而是在经历这台手术。

但不要为了满足互动指标每一步都插话。

---

## 17.7 Replay Value

第二次玩时，玩家应该自然产生：

> “这次我试试能不能做得更快。”

或：

> “上次我一路猛冲，这次看看稳一点有什么区别。”

如果三条路线体验完全一样，只是最后数字差几分：

> Pilot 未通过。

---

# 18. 成功标准

只有当阑尾 pilot 达到下面四点，才考虑把 Strategy Layer 推广到其他术式：

```text
1. 保留 Hoshimi 现有点选 / VN 操作方式
2. 不变成鼠标技术模拟
3. 不变成知识问答 / puzzle
4. 玩家能通过选择真正改变手术局面
```

最终目标体验：

> **“我不是在回答阑尾切除考试题。”**
>
> **“我是根据眼前这台手术的状态，决定现在该怎么做。”**

---

# 19. Pilot 完成后再讨论的下一步

本文件完成后先试玩。

不要直接批量扩展 50 个术式。

如果阑尾通过，下一批建议故意测试两种完全不同的 decision grammar：

```text
开腹胆囊切除
→ 结构确认 / 不可逆判断

大开腹探查
→ 搜索 / 排除 / 什么时候敢停止
```

目标是验证：

> **同一个线性点击式手术引擎，是否真的能够产生三种不同手感。**

如果三台都成立，再设计 `Gameplay Family` 并逐步推广到未来 50 个术式。

---

# END
