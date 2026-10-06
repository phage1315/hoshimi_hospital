# Hoshimi Hospital — 手术 UI 名称与初始解锁术式 V0.1

> **状态：设计定义稿**
>
> **用途：**
> 1. 把现有 25 个术式改成更容易让一般玩家理解的 UI 名称；
> 2. 定义坂口隆司在游戏开始时已经掌握的 9 个术式；
> 3. 明确现阶段不加入腹腔镜术式；
> 4. 增加“经阴道子宫全切除”作为未来占位术式（placeholder）。
>
> **原则：**
> - UI 优先使用普通玩家一眼能懂的名称；
> - 不需要额外显示学术全称；
> - `开腹 / 开胸 / 经阴道` 这类入路前缀可以保留，因为它们直观地告诉玩家“从哪里做”；
> - 内部 ID 可以暂时维持现有 ID，以减少已有内容和存档/引用的改动；后续如做 schema 整理，再统一迁移；
> - 现阶段不计划加入腹腔镜术式，Hoshimi 的手术表现继续以开放式手术为主。

---

# 1. 现有 25 个术式的 UI 名称修改表

| 现有 ID | 旧名称 | 建议 UI 名称 | 初始状态 |
|---|---|---|---|
| `surgery_appendix` | 阑尾切除术 | **开腹阑尾切除** | **初始解锁** |
| `surgery_breast_tumor` | 乳腺肿瘤切除术 | **乳房肿瘤切除** | **初始解锁** |
| `surgery_hysterectomy` | 子宫切除术 | **开腹子宫全切除** | 锁定 |
| `surgery_cabg` | 心脏搭桥术 | **开胸心脏搭桥** | 锁定 |
| `surgery_exploratory_laparotomy` | 大开腹探查术 | **大开腹探查** | 锁定 |
| `surgery_open_cholecystectomy` | 开腹胆囊切除术 | **开腹胆囊切除** | **初始解锁** |
| `surgery_open_inguinal_hernia` | 开放式腹股沟疝修补术 | **腹股沟疝修补** | **初始解锁** |
| `surgery_open_ventral_hernia` | 开放式腹壁疝修补术 | **腹壁疝修补** | **初始解锁** |
| `surgery_open_distal_gastrectomy` | 开腹远端胃切除术 | **开腹部分胃切除** | **初始解锁** |
| `surgery_open_total_gastrectomy` | 开腹全胃切除术 | **开腹全胃切除** | 锁定 |
| `surgery_open_right_hemicolectomy` | 开腹右半结肠切除术 | **开腹右半结肠切除** | 锁定 |
| `surgery_open_sigmoid_colectomy` | 开腹乙状结肠切除术 | **开腹乙状结肠切除** | 锁定 |
| `surgery_open_abdominoperineal_resection` | 开放式腹会阴联合直肠切除术 | **开腹直肠切除（含肛门）** | 锁定 |
| `surgery_open_whipple` | 开放式胰十二指肠切除术 | **开腹胰十二指肠切除** | 锁定 |
| `surgery_open_major_liver_resection` | 开腹肝叶切除术 | **开腹肝叶切除** | 锁定 |
| `surgery_open_splenectomy` | 开腹脾切除术 | **开腹脾切除** | **初始解锁** |
| `surgery_open_ovarian_cystectomy` | 开腹卵巢囊肿切除术 | **开腹卵巢囊肿切除** | **初始解锁** |
| `surgery_open_abdominal_myomectomy` | 开腹子宫肌瘤剔除术 | **开腹子宫肌瘤切除** | **初始解锁** |
| `surgery_total_mastectomy` | 全乳房切除术 | **全乳房切除** | 锁定 |
| `surgery_open_lung_lobectomy` | 开胸肺叶切除术 | **开胸肺叶切除** | 锁定 |
| `surgery_open_pneumonectomy` | 开胸全肺切除术 | **开胸全肺切除** | 锁定 |
| `surgery_open_esophagectomy` | 开放式食管切除术 | **开胸食管切除** | 锁定 |
| `surgery_open_radical_cystectomy` | 开放式根治性膀胱切除术 | **开腹膀胱全切除** | 锁定 |
| `surgery_open_nephrectomy` | 开放式肾切除术 | **开腹肾切除** | 锁定 |
| `surgery_open_abdominal_aortic_aneurysm` | 开放式腹主动脉瘤修复术 | **开腹主动脉瘤修补** | 锁定 |

---

# 2. 新增占位术式：经阴道子宫全切除

建议新增：

```yaml
id: surgery_vaginal_hysterectomy
ui_name: 经阴道子宫全切除
procedure_group: female_pelvic
status: placeholder
unlocked_at_start: false
```

## 当前明确状态

> **Placeholder。**

目前：

```text
没有定义正式手术步骤
没有完成 surgery stages
没有对应专属患者互动流程
没有正式解锁事件
```

因此第一版中：

```text
可以在术式总览 / 图鉴中显示为灰色
但不可选择
也不进入随机病例池
```

以后正式设计时，再补：

```text
手术步骤
难度
推荐 Surgery
training ceiling
患者互动 cue
First Exposure 解锁事件
Staff-as-Patient 训练逻辑
```

---

# 3. 初始解锁术式：正式定义为 9 个

坂口隆司在游戏开始时已经掌握：

```text
1. 开腹阑尾切除
2. 开腹胆囊切除
3. 腹股沟疝修补
4. 腹壁疝修补
5. 乳房肿瘤切除
6. 开腹部分胃切除
7. 开腹脾切除
8. 开腹卵巢囊肿切除
9. 开腹子宫肌瘤切除
```

对应 ID：

```yaml
starting_unlocked_procedures:
  - surgery_appendix
  - surgery_open_cholecystectomy
  - surgery_open_inguinal_hernia
  - surgery_open_ventral_hernia
  - surgery_breast_tumor
  - surgery_open_distal_gastrectomy
  - surgery_open_splenectomy
  - surgery_open_ovarian_cystectomy
  - surgery_open_abdominal_myomectomy
```

---

# 4. 为什么是这 9 个

这 9 个共同表达：

> **坂口不是新手，但游戏开始时也远没有掌握 Hoshimi 全部大型术式。**

结构大致是：

```text
基础 / 常见普通外科
- 开腹阑尾切除
- 开腹胆囊切除
- 腹股沟疝修补
- 腹壁疝修补

跨领域基础
- 乳房肿瘤切除

中等以上腹部手术
- 开腹部分胃切除
- 开腹脾切除

女性盆腔基础术式
- 开腹卵巢囊肿切除
- 开腹子宫肌瘤切除
```

因此开局就有：

```text
普通外科
乳房
妇科
中型腹部手术
```

几种不同体验。

同时仍然保留大量灰色术式，让玩家产生明确的职业成长目标。

---

# 5. 开腹子宫全切除：不作为初始术式

当前明确：

```text
surgery_hysterectomy
UI 名称：开腹子宫全切除
初始：LOCKED
```

推荐把它作为：

> **Aqua 带坂口完成的一次重要妇科助手 / 教学事件。**

事件完成后：

```text
开腹子宫全切除 UNLOCKED
First Exposure Surgery XP：高
Aqua Team Bond / Familiarity：增加
```

叙事效果：

> 玩家第一次明显体验到：
>
> **“跟某个角色上刀，不只是角色剧情，也会真正扩展自己的术式库。”**

Aqua 的事件可以同时承担一定黑色幽默：

> 术式解锁了；
>
> Surgery XP 拿了很多；
>
> 坂口也受到相当大的“精神伤害”。

这里的“精神伤害”主要建议作为剧情与对白效果，不必强制做长期数值 debuff。

---

# 6. 初始锁定的高吸引力术式

以下术式开局应当在 UI 中可见但灰色：

```text
开腹子宫全切除
经阴道子宫全切除（Placeholder）
开胸心脏搭桥
大开腹探查
开腹全胃切除
开腹右半结肠切除
开腹乙状结肠切除
开腹直肠切除（含肛门）
开腹胰十二指肠切除
开腹肝叶切除
全乳房切除
开胸肺叶切除
开胸全肺切除
开胸食管切除
开腹膀胱全切除
开腹肾切除
开腹主动脉瘤修补
```

目的不是让玩家觉得：

> “我什么都不会。”

而是：

> **“原来以后可以开这么多种刀，只是现在还没有学到。”**

---

# 7. 关于腹腔镜术式

当前设计明确：

> **现阶段不加入腹腔镜术式。**

Hoshimi 的手术视觉与玩法继续以：

```text
开放式手术
开腹
开胸
经阴道
```

为主要方向。

原因不是技术限制，而是项目风格选择：

> **开放式手术更符合 Hoshimi 当前希望强化的视觉、患者互动与手术室临场感。**

因此未来扩展到约 45–50 个术式时：

```text
优先扩展不同器官 / 不同开放式术式
而不是把现有术式大量复制成腹腔镜版本
```

---

# 8. UI 命名规则

以后新增术式统一遵守：

### 推荐

```text
开腹部分胃切除
开胸肺叶切除
经阴道子宫全切除
心脏瓣膜置换
乳房肿瘤切除
```

### 避免

```text
开放式远端胃大部切除术
经腹全子宫切除术
开放式腹会阴联合直肠切除术
冠状动脉旁路移植术
```

设计目标：

> **医学上不至于错，但第一优先级是普通玩家看得懂。**

---

# 9. 当前最终定义

```yaml
procedure_count_current_implemented: 25
procedure_count_with_placeholder: 26

laparoscopic_procedures_planned: false

starting_unlocked_count: 9

starting_unlocked:
  - 开腹阑尾切除
  - 开腹胆囊切除
  - 腹股沟疝修补
  - 腹壁疝修补
  - 乳房肿瘤切除
  - 开腹部分胃切除
  - 开腹脾切除
  - 开腹卵巢囊肿切除
  - 开腹子宫肌瘤切除

special_locked:
  开腹子宫全切除:
    suggested_unlock: Aqua assistant / teaching event

placeholder:
  经阴道子宫全切除:
    steps_defined: false
    selectable: false
    random_case_enabled: false
```

