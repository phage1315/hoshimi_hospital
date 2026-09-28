# 新增随机患者完整流程

本文件是星见医院新增普通随机患者的执行清单。它汇总琪琪·安达露西亚与柳原理惠接入时发现的问题，覆盖资料准备、美术、患者数据、随机病例、门诊、术前、术中反应、自动检查和实机验收。

适用对象是会进入普通门诊轮换、随机疾病和手术流程的成年患者。只参与固定剧情的患者应使用 `cameo_patient`，不应照搬本流程。

## 一、开始前需要的角色资料

最低资料：

- 正式显示名及稳定英文 ID，例如 `patient_rie`。
- 明确的成年年龄。不得只写“成年”；应给出游戏内数字年龄。
- 3—5 张能确认脸型、眼睛、发型、体型和日常服装的参考图。
- 性格主轴、次要矛盾和压力下的反应方式。
- 是否保留原作职业、婚姻或家庭背景。
- 一张最适合作为门诊基础立绘的参考图。

可选资料：

- 已透明化的检查或特殊场景立绘。
- 医院服装、卧姿、闭眼或痛苦表情参考。
- 角色说话习惯、称呼方式、不能出现的表现。

原始参考图统一保存到：

```text
research/character_references/<patient_id>/
```

不要覆盖原始文件。AI 派生图和裁切图应进入 `assets`，来源图继续留在 `research`。

## 二、ID、目录与文件命名

患者 ID 使用小写蛇形命名并保持稳定：

```text
patient_<short_name>
```

推荐目录：

```text
assets/characters/<patient_id>_v1/<patient_id>/
├── outpatient/
│   └── neutral.png
├── ward/
│   ├── neutral.png
│   ├── smile.png
│   ├── brave.png
│   ├── worried.png
│   ├── afraid.png
│   └── crying.png
├── operating_table/
│   ├── awake.png
│   ├── tense.png
│   ├── afraid.png
│   └── anesthetized.png
├── splash/
│   └── general_anesthesia.png
└── examination/
    └── shy.png

assets/characters/intraoperative_portraits_v1/<patient_id>/
├── tense.png
├── pain.png
├── near_collapse.png
└── anesthetized.png
```

标准患者需要 **17 个状态映射和17张独立图片**。不要用术中麻醉头像代替全麻 splash。

## 三、美术素材矩阵

### 1. 门诊立绘

- 键：`outpatient/neutral`
- 推荐规格：1024×1536、RGBA、真实透明背景。
- 构图：头部至大腿中段的竖向人物切图，头顶和手部不能被裁掉。
- 作用：身份基准。后续所有素材优先以此图确认脸型、眼睛、发色和年龄感。

### 2. 病房立绘

必须提供：

```text
ward/neutral
ward/smile
ward/brave
ward/worried
ward/afraid
ward/crying
```

要求：

- 1024×1536、RGBA、四角透明。
- 六张使用完全一致的画布、人物大小、姿势、服装和位置。
- 穿不透明、端正的病员服。
- 差分只改变表情和极少量自然手部张力。
- 表情必须符合角色本人；不能给所有患者套同一张通用脸。

### 3. 手术台全景

必须提供：

```text
operating_table/awake
operating_table/tense
operating_table/afraid
operating_table/anesthetized
```

当前基准规格为1448×1086、不透明横图。生成时必须参考已有患者的 `operating_table/awake.png`，而不是自由构图。

统一要求：

- 从正上方俯视仰卧患者，手术台、枕头和设备透视保持一致。
- 必须看到从头到脚的手术台构图；不能生成站姿、坐姿或右侧半身立绘。
- 裸露肩膀和锁骨；胸部至膝下由不透明青绿色无菌单覆盖。
- 双臂自然放在身体两侧，腿和脚的位置与现有患者一致。
- 患者佩戴手术帽。侧发、后发和长发必须收入帽内；允许保留整齐、适量的标志性刘海，以维持自然感与辨识度。
- 医护人员仍执行完全收发规则；患者刘海例外不能套用到医生和护士。
- 四张差分只改变面部状态，不改变身体、铺单、器械、镜头和照明。

### 4. 术中反应头像

必须提供：

```text
intraoperative/tense
intraoperative/pain
intraoperative/near_collapse
intraoperative/anesthetized
```

当前基准规格为1448×1086、RGBA。构图为正面头、颈、锁骨和肩顶透明切图。

要求：

- 不包含枕头、手术台、衣服、无菌单、器械或背景。
- 四张保持完全相同的脸部大小、肩宽、帽子和裁切。
- `tense`：清醒、紧张但仍能配合。
- `pain`：无麻醉手术前中段，明确疼痛、含泪、面部紧绷，意识仍集中。
- `near_collapse`：无麻醉手术尾段，眼神失焦、泪痕、嘴角或眼睑抽搐、意识衰退；必须和 `pain` 一眼可区分。
- `anesthetized`：双眼闭合、眉眼和下颌完全放松。
- 每个状态都要保留角色本人的眼型、眉形、脸型和情绪方式。疼痛越强不等于换成另一张通用脸。

### 5. 全身麻醉 splash CG

- 键：`splash/general_anesthesia`
- 当前基准规格：1672×941、不透明横图。
- 必须是独立的全场景CG，不能复用透明 `intraoperative/anesthetized` 头像，也不能只提交枕上半身切图。
- 使用俯视或略带角度的手术台近景，包含枕头、手术室环境和设备边缘。
- 患者双眼闭合，鼻口覆盖透明麻醉面罩；面罩连接波纹呼吸管并延伸到画面外。
- 裸露肩膀和锁骨，胸部以下由不透明青绿色无菌单覆盖。
- 侧发和长发收入手术帽，保留适量标志性刘海。
- 画面不得透明，不得出现黑色或白色空背景。

### 6. 检查立绘

- 键：`examination/shy`
- 必须是透明 PNG。
- 若用户提供的文件已经透明，可以直接接入；但仍要在固定450×389立绘框内检查主体大小、裁切和位置。
- 原始画布横向或透明留白过多时，需要按人物边界裁切或重新排版，不能只因为“有 Alpha”就判定合格。
- 只在对应检查场景使用，不得误用为门诊或普通手术立绘。

## 四、推荐的图片制作顺序

按以下顺序可以减少身份漂移：

1. 从多张原始参考生成 `outpatient/neutral`，先确认身份。
2. 由门诊基础图生成 `ward/neutral`，只更换服装。
3. 以 `ward/neutral` 为唯一身份和构图基准生成五张病房表情。
4. 使用现有患者手术台图作为构图参考、门诊图作为身份参考，生成 `operating_table/awake`。
5. 从同一张 `awake` 生成 `tense`、`afraid`、`anesthetized`。
6. 使用现有术中透明头像作为构图参考、门诊图作为身份参考，生成 `intraoperative/tense`。
7. 从同一张 `tense` 逐步生成 `pain`、`near_collapse` 和 `anesthetized`。
8. 最后单独生成带面罩、呼吸管和完整手术室环境的全麻 splash。
9. 接入检查素材并在游戏固定立绘框内验收。

每一步先验收再继续批量生成。基础脸型错误时，不要拿错误图继续派生十几张差分。

## 五、ImageGen 提示词约束

### 身份保持

提示词必须明确列出：

- 年龄与成年身份。
- 发色、眼睛颜色、脸型和标志性五官。
- 哪张图是身份参考，哪张图只提供构图。
- 只允许改变服装、表情或指定局部。
- 禁止生成通用新脸、改变眼睛颜色或改变年龄感。

### 透明素材

必须同时写明：

```text
genuinely transparent background
no black backdrop
no scenery
no shadow rectangle
```

工具返回后仍需检查真实 Alpha。预览器显示黑色不一定代表不透明，文件属性和四角像素才是判断依据。

### 手术台与 splash

在提示词中明确区分：

- 手术台全景：完整身体和手术台，面罩不一定出现。
- 术中头像：透明头肩切图，没有场景。
- 全麻 splash：横向不透明场景，必须有麻醉面罩与呼吸管。

避免只写“麻醉图”；这会导致模型生成不符合任何一种现有槽位的半身卧姿图片。

## 六、患者数据包

复制一个现有目录为 `data/patients/<patient_id>/`，编辑其中唯一的 `patient.json`，然后把相对路径加入 `data/patients/index.json`。不要再建立独立 encounter 或 preop 副本。

数据包顶层包含：

```text
schema_version
patient
fallback
encounter.full_undress
preop.stage_prompts
preop.incision_responses
exclusive_cg_pools
```

其中 `patient` 的必填字段为：

```text
id
name
age
case_id
visuals
admission_status
voice_style
personality
traits
fear_profile
reaction_lines
reaction_variants
```

关键规则：

- `age` 必须为明确的成年数字年龄。
- `patient.case_id` 和 `fallback.case_id` 是回退病例，不代表患者被固定为该疾病。
- `fallback.surgery_id` 只在随机病例系统不可用时使用。
- 实际新游戏会从 `case_templates` 为每名患者随机分配病例；`encounter_for_case()` 重写问诊内容，`preop_definitions_for()` 再把病例的 `surgery_id` 绑定到术前手术。
- `voice_style` 只能是 `direct`、`reserved`、`bold`、`gentle`。
- `personality.primary + secondary` 的组合必须在患者池中唯一。
- `stress_response` 使用现有枚举：`becomes_quiet`、`seeks_reassurance`、`becomes_irritable`、`asks_for_details`。
- `traits` 和 `fear_profile` 数值范围均为0—100。
- `visuals.portraits` 填入前述17个完整键；路径从项目根目录开始，不加 `res://`。

loader 会从 `data/patients/templates/encounter.json` 与 `preop.json` 自动生成 `visit_<short_id>` 和 `preop_<short_id>`。患者专属的完全脱衣查体对白、术前阶段提示和旧下刀回应保存在数据包中，并覆盖共用模板。

## 七、患者专属反应文案

`reaction_lines` 必须完整包含以下27个键，不能缺少、重复或只复制另一名患者的内容：

```text
hospitalization_question
hospitalization_response
procedure_mismatch
explain_plan
brief_plan
last_reassure
choose_general
choose_epidural
choose_local
choose_none
induction_reassure
insist_without_anesthesia
assistant_stabilize_none
assistant_stabilize_local
assistant_stabilize_epidural
incise_epidural
incise_local
incise_none
contact_pause
contact_command
contact_continue
ongoing_narrate
ongoing_eye_contact
ongoing_silent
closure_reassure
closure_coach
closure_silent
```

`reaction_variants` 必须完整包含以下13组，每组写2—3条互不重复的台词：

```text
ward_enema
ward_enema_unnecessary
ward_skin_prep
ward_skin_prep_unnecessary
ward_surgical_cap
operative_positioning_awake
operative_positioning_none
urinary_catheterization_awake
urinary_catheterization_none
skin_disinfection_awake
skin_disinfection_none
incision_marking_awake
incision_marking_none
```

写作检查：

- 同一种医疗行为要体现这个角色独有的语言和心理防御方式。
- 括号内心声可以揭示矛盾，但不能和说出口的话完全重复。
- 无麻醉状态应明确拒绝或表达疼痛，不能把配合倾向写成默认同意。
- 日常人物背景可以进入心声，但不能压过当前医疗情境。
- 常规医疗场景不要自动写成色情互动。

## 八、门诊专属内容

门诊结构由共用 encounter 模板生成。数据包只填写 `encounter.full_undress`：

- `prompt`：提出完全脱衣查体后的患者反应；
- `responses`：放弃、权威说服、温柔说服与威胁四种回应；
- `visual_pool_id`：可选的患者专属检查 CG 池；没有专属图时留空。

疾病主诉、症状、检查、诊断和住院方案由随机 `case_templates` 在运行时写入生成后的门诊定义。

## 九、术前专属内容

术前结构由共用 preop 模板生成。数据包填写：

- `preop.stage_prompts`：以稳定 stage ID 为键的患者专属提示；
- `preop.incision_responses`：旧术前层仍会读取的麻醉分支下刀回应；
- `initial_anxiety` 与 `initial_interaction`：初始状态；
- `title`：回退标题。

稳定的准备动作、麻醉分支和手术流程只维护一份共用模板。新游戏仍会用随机病例的 `surgery_id` 覆盖回退术式。

## 十、验证器和测试队列

患者索引、验证器和通用患者队列均为数据驱动。新增患者无需修改验证器姓名表、门诊测试队列或术前测试队列。

`tools/portrait_test.gd` 已按患者集合动态计算图片数量，不需要再手改固定患者数；它会检查病房立绘 Alpha、透明四角、同状态尺寸和资源切换。

### 自动测试命令

```bash
../../work/venv/bin/python tools/validate_data.py
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tools/patient_bundle_test.gd
godot --headless --path . --script res://tools/smoke_test.gd
godot --headless --path . --script res://tools/portrait_test.gd
godot --headless --path . --script res://tools/clinic_test.gd -- /tmp/hoshimi-clinic-test.json
godot --headless --path . --script res://tools/preop_test.gd -- /tmp/hoshimi-preop-test.json
```

没有 Godot CLI 时，至少运行 `validate_data.py`，再由编辑器完成资源导入和实机测试。只有数据验证通过不代表立绘比例正确。

## 十一、实机验收路线

### 门诊和随机病例

1. 新开游戏或清空原型进度。
2. 轮换患者直到新患者出现。
3. 确认姓名、年龄和门诊立绘正确。
4. 记录本轮随机疾病。
5. 完成问诊，确认症状、检查、诊断和病历都来自该疾病模板，而不是复制来源患者的固定内容。
6. 收住院后确认术式与疾病绑定。

### 立绘浏览

1. 打开人物立绘页。
2. 逐一切换门诊、六张病房差分和四张手术台图。
3. 检查人物大小、位置、画布比例、透明边缘和表情切换跳动。
4. 检查检查立绘在450×389框中的实际大小。

### 麻醉路线

分别测试：

- 全身麻醉：应显示独立 `splash/general_anesthesia`，包含面罩、呼吸管和手术室背景；之后患者不出现导尿、消毒和下刀三类清醒角色CG。
- 硬膜外麻醉：患者保持清醒，术中能出现 `tense` 和对应术式反应。
- 局部麻醉：确认牵拉、刺痛及询问台词正常。
- 无麻醉：确认 `pain` 在前中段出现，最后两个手术步骤切换为明显不同的 `near_collapse`。

### 手术流程

1. 检查手术进行中不能返回医院导览。
2. 验证乳房、妇科盆腔、心脏、非心脏开胸和泌尿等不同术式会使用相应患者反应。
3. 确认手术完成后流程正常返回，不跳入无关人物事件。

## 十二、素材记录

每名患者新增一份：

```text
docs/<patient_id>_asset_record.md
```

至少记录：

- 显示名、ID、年龄和背景。
- 原始参考图位置。
- 角色身份特征和性格。
- 所有游戏素材目录。
- ImageGen 使用的模式、主要参考图和最终约束。
- 用户提供素材与生成素材的区别。
- 特殊素材只允许出现的场景。

## 十三、完成标准

以下项目全部满足后，患者才算接入完成：

- [ ] 成年年龄、姓名、ID和背景明确。
- [ ] 原始参考图已保存。
- [ ] 17个立绘／CG状态都有独立有效文件。
- [ ] 病房与术中切图具有真实 Alpha，画布四角透明。
- [ ] 手术台四张图构图、尺寸和身体位置一致。
- [ ] 患者刘海自然保留，侧发和长发收入手术帽。
- [ ] 全麻 splash 为带面罩和呼吸管的独立横向场景。
- [ ] `pain` 与 `near_collapse` 明显不同且仍像原角色。
- [ ] `patient.json` 数据包字段和17个图片键完整，并已加入 `patients/index.json`。
- [ ] 27条 `reaction_lines` 齐全且互不重复。
- [ ] 13组 `reaction_variants` 齐全，每组2—3条。
- [ ] 完全脱衣查体对白、术前阶段提示和回退数据完整。
- [ ] `patient_bundle_test.gd` 能生成对应 encounter 与 preop。
- [ ] `validate_data.py` 通过。
- [ ] Godot 导入、portrait、clinic、preop 和 smoke 测试通过，或已记录无法运行的环境限制。
- [ ] 实机完成至少一次随机疾病、全麻和无麻醉路线。

## 十四、琪琪与理惠接入时发现的典型错误

- 只做了麻醉头像，却忘记独立全麻 splash。
- 文件名叫 splash，实际却是透明卧床人物切图，没有面罩、呼吸管和手术室背景。
- 新患者手术台图采用不同的半身构图，无法与现有患者保持一致。
- 病房或手术人物图带矩形底色、错误 Alpha 或黑色拖影。
- `pain` 与 `near_collapse` 只是同一张通用脸的小修改，丢失角色辨识度。
- 长发完全露在手术帽外，或反过来把所有刘海抹掉导致患者不像本人。
- 只建立患者目录，却忘记加入 `patients/index.json`。
- 复制数据包后残留旧患者 ID、姓名或专属 CG 池 ID。
- 把回退 `case_id` 当成固定疾病，误以为患者不能随机分配病例。
- 使用 Alpha 文件就直接判定检查立绘合格，没有在游戏固定框中检查实际大小和位置。

以后新增患者应先复制本清单，在制作过程中逐项勾选，而不是等所有图片生成以后再统一修正。
