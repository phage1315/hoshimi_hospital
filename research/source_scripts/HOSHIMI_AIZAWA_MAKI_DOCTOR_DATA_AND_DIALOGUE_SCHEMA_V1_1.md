# Hoshimi Hospital／星见医院 — 相澤麻紀（`doc_maki`）医生数据与角色台词 Schema 交付稿 V1.1

**版本：** Authoring Package V1.1（定点修订版：明确可攻略初始定位、普通与高级手术助手资格、常驻与随机地点配置、新增通用术中回应、不限时闲谈及英文档案补齐）  
**状态：** V1.1 修订完成 / 待审阅（`lv0.scenes` 继续留空 `[]`，全部 JSON 严格可解析且对齐 `dialogue_delivery.schema.json`）  
**对应角色：** 相澤 麻紀 / 相泽麻纪 / Maki Aizawa（`doc_maki`，21岁，普通外科医师）  
**参考基准：**  
- `HOSHIMI_AIZAWA_MAKI_CHARACTER_BIBLE.md`（2026-11-13）  
- `HOSHIMI_SHIROMIYA_ASUKA_LV2_SUITABLE_PERSON_SUITABLE_GOWN_V1_1.md`（正式面试稿）  
- `writing/WRITER_HANDOFF.md`、`writing/dialogue_delivery.schema.json`、`profile_draft.json`、`ready_assets.json`  

---

## 一、 人工审阅速览表（数值、档案与台词可读版）

### 1.1 已确认基础档案与六维能力（中英双语对照）

| 字段 | 中文内容（`zh_CN`） | 英文内容（`en`） / 确认值 | 设计与连续性说明 |
| :--- | :--- | :--- | :--- |
| **Actor ID** | `doc_maki` | `doc_maki` | 稳定角色标识 |
| **姓名** | 相澤 麻紀（简：相泽麻纪） | Maki Aizawa | 保持既有显示姓名与本地化对照 |
| **年龄** | 21 岁（成年） | `21` (`adult: true`) | 比 23 岁的明日香与深山小 2 岁，同所女子医大晚两届 |
| **专科（`specialty`）** | 普通外科 | General Surgery | 已补齐档案显示英文 |
| **职级（`rank`）** | 年轻外科医师／初期接受带教 | Junior Surgeon / Supervised Surgical Trainee | 已补齐档案显示英文 |
| **性格（`personality`）** | 礼貌拘谨、有责任感、有主见；对风险敏感，专业讨论清楚具体，重视术野复盘。 | Polite and reserved, yet responsible and principled; risk-conscious, clear and concrete in clinical discussions, and diligent about reviewing operative fields. | 已补齐档案显示英文 |
| **外貌（`appearance`）** | 灰橄榄调浅棕长发、双肩前低束发、深色方框眼镜；以原作 ASS_03 种子图为身份锚点。 | Ash-olive light brown long hair tied low over both shoulders, dark rectangular-framed glasses; anchored to the original ASS_03 portrait reference. | 已补齐档案显示英文 |
| **说话方式（`dialogue_style`）** | 礼貌、克制、具体；专业说明不口头禅式结巴。 | Polite, composed, and specific; delivers clinical explanations clearly without habitual stuttering. | 已补齐档案显示英文 |
| **攻略定位与关系初值** | 可攻略角色（`Lv0–Lv5` 剧情待完成） | `romanceable: true`；初始 `affection=0`, `familiarity=0`, `level=0`, `route="colleague"` | `colleague` 表示初始同事关系，非不可攻略或永久友情线；暂不补写进阶门槛或亲密条件 |
| **手术资格与熟练度建议** | 普通及高级手术助手编组可用；初期无独立主刀资格 | Assistant eligible (routine & advanced); primary surgeon disabled; `surgery_proficiency="limited"`（建议值，未宣称已批准） | 完成 Lv0 入职后沿用现有助手编组规则，不设麻纪专属高级助手禁令 |
| **院内常驻地点配置** | 休息室固定在场 ＋ 天台随机遇见（均着白大褂） | `lounge` (fixed, `white_coat`) + `rooftop` (random encounter, `white_coat`) | 完成 Lv0 入职后开放；具体随机机制由工程处理 |
| **`surgery`（手术操作）** | **48** | `48` | 已完成外科基础轮转、懂常规入路与解剖，尚不足以独立主刀（低于明日香当前手术能力 66） |
| **`diagnostics`（诊断评估）** | **65** | `65` | 前院管床、术前评估与术后次日引流复核功底扎实 |
| **`teamwork`（团队配合）** | **72** | `72` | 六维最高项；守纪律、配合认真，发现安全风险敢于主动出声通报 |
| **`patient_care`（患者照护）** | **68** | `68` | 重视围术期观察与患者安全底线 |
| **`instrument_handling`（器械与暴露）** | **56** | `56` | 具备二助拉钩与术后手绘复盘积累，尚需在一助位继续打磨持续稳定性 |
| **`calmness`（临场镇定）** | **45** | `45` | 当前核心短板；受既往参与术后迟发出血抢救经历影响，高压下偶有短暂停顿，留足成长空间 |

---

### 1.2 手术编队、术中配合（通用＋情境候选）与首次助手 CG 文案速览

| 槽位路径 | 中文正文（`zh_CN`） | 英文译文（`en`） | 适用范围与立绘建议 |
| :--- | :--- | :--- | :--- |
| **`team_dialogue.assignment`**<br>*(编队选中回应 · 单字符串)* | 麻纪迅速将术前资料的页角对齐，认真抬头看向坂口：「患者的基础指标和手术入路我已经预习过了。今天助手的位置，请多指教，坂口医生。」 | Maki neatly aligns the corners of the preoperative chart and looks up earnestly at Sakaguchi. "I have reviewed the patient's baseline findings and the planned approach. I'll do my best assisting you today, Dr. Sakaguchi." | 通用编队选中（`white_coat/focused`） |
| **`team_dialogue.intraoperative`**<br>*(默认通用术中回应 · 写入主 Schema)* | 「这边的视野已经按您的要求稳住了，坂口医生。我正盯着您的操作节奏，下一步需要调整配合角度的话，请随时告诉我。」 | "I have the field steady on this side as requested, Dr. Sakaguchi. I'm following your pace closely—please let me know right away if you need me to adjust my angle for the next step." | **全术式／全阶段通用**（不预设出血、特定解剖结构或异常；`sterile/focused`） |
| **`intraoperative` 情境专用候选**<br>*(保留备用 · 不覆盖通用槽)* | 「牵开角度已经稳住了，坂口医生。深面这一层的筋膜间隙比预想的要薄一点，边缘有细小渗血，需要先确认止血再往下分吗？」 | "I have the retraction angle steady, Dr. Sakaguchi. The fascial plane down here looks slightly thinner than expected, with minor oozing along the edge—shall we secure hemostasis before dissecting further?" | **情境专用保留候选**（适用于软组织分层／渗血确认情境；`sterile/focused`） |
| **`first_assignment_cg.title`** | 第一助手的确认 | First Assistant Ready | `assets/events/maki_first_assistant_v1/assistant_confirmation.png` |
| **`first_assignment_cg.caption`** | 无影灯下，穿戴好全套无菌手术袍的相泽麻纪隔着外科口罩认真迎上主刀的视线，确认术前准备就绪。 | Beneath the operating lights, Maki Aizawa—gowned and gloved in full sterile attire—meets the lead surgeon's gaze steadily above her mask to confirm readiness. | 同上（手术室内麻纪面向主角的主观视角） |

---

### 1.3 常驻日常闲谈（`idle_chats`：不限时版本 · 休息室固定 3 条 ＋ 天台随机 3 条）

#### A. 医护休息室（`location_id: "lounge"` ｜ 固定在场 · `white_coat` ｜ 标签：「和相泽医生聊聊近况」 / `"Chat with Dr. Aizawa"`）
- **回应 1（手绘术野笔记与拉钩复盘 · 已改为不限时日常习惯）：**  
  - `zh_CN`：麻纪正坐在休息室圆桌边，用细头钢笔在随身笔记本上整理手绘的术野解剖简图。「啊，坂口医生。我习惯趁着休息空当，把之前跟台时记下的拉钩角度和暴露层次重新梳理一遍——比如深部结扎的时候，拉钩要是再往外侧让开五度，主刀的视野应该会更敞亮吧？等之后查房核对引流情况的时候，我也会再对照印证一下的。」  
  - `en`：Maki sits at the round table in the lounge, organizing hand-drawn surgical field sketches in her pocket notebook with a fine-tipped pen. "Ah, Dr. Sakaguchi. Whenever I have a spare moment, I like to go back over the retractor angles and exposure layers from previous cases—for instance, angling five degrees further laterally during deep ligation should give the lead surgeon a clearer view, right? I always cross-check my notes against the drain findings on subsequent rounds too."
- **回应 2（前院文书流水线 vs 星见实操带教 · 已消除下午时段限定）：**  
  - `zh_CN`：麻纪把一摞整理整齐的术后观察表收进文件夹，端起温茶轻轻舒了一口气。「以前在原来的大医院，平时大部分时间我都只是坐在电脑前，机械地抄写十几床的常规病程。来到星见以后，前辈们真的愿意在台边告诉我每一钳为什么要那样下……虽然每次刷手前心跳还是有点快，但这种真正作为外科医生在学习的感觉，真的很踏实。」  
  - `en`：Maki tucks a neatly stacked set of postoperative charts into her folder and takes a quiet sip of warm tea. "Back at my old hospital, I spent most of my days just sitting at a terminal, mechanically typing up routine progress notes for a dozen beds. Here at Hoshimi, my seniors actually explain why each clamp goes where it does right at the table... My heart still races a little before scrubbing in, but finally learning as a real surgeon feels deeply reassuring."
- **回应 3（研读解剖变异与主动预警准备 · 原样保留）：**  
  - `zh_CN`：麻纪合上手边的《开放手术局部解剖图谱》，自然地扶了一下深色方框眼镜。「坂口医生也来休息吗？我刚在对照两套不同入路的血管变异分支。总觉得光是背熟正常走行还不够，要是哪天在台上遇到不典型的分支，至少得做到第一时间认出来、及时向主刀报告才行。」  
  - `en`：Maki closes the Atlas of Open Surgical Anatomy beside her and briefly adjusts her dark-framed glasses. "Taking a break too, Dr. Sakaguchi? I was just comparing vascular anatomical variants across two different approaches. Memorizing standard textbook anatomy alone doesn't feel like enough—if an atypical branch ever shows up in the field, I want to be able to recognize it right away and report it to the lead surgeon."

#### B. 医院天台（`location_id: "rooftop"` ｜ 随机遇见 · `white_coat` ｜ 标签：「在天台和相泽医生吹风」 / `"Chat with Dr. Aizawa on the rooftop"`）
- **回应 1（吹风平复手指紧绷 · 已消除刚下台及下午时段前提）：**  
  - `zh_CN`：麻纪站在天台栏杆旁，迎着微风慢慢做了一次深呼吸，随后低头看了看自己摊开的双手。「坂口医生。每次跟完需要长时间保持牵引的手术，我的手指偶尔还是会因为绷得太久有一点点发僵……所以我喜欢趁空当上来吹两分钟风、把呼吸放慢下来，之后再去病房换药或者做检查，手就稳多了。」  
  - `en`：Standing by the rooftop railing, Maki takes a slow, deep breath against the breeze before looking down at her open palms. "Dr. Sakaguchi. Whenever I finish a case that requires holding retraction for a long stretch, my fingers still get a little stiff from the tension... That's why I like coming up here for a couple of minutes to catch the breeze and slow my breathing—my hands feel much steadier for ward dressings and exams afterward."
- **回应 2（对星见“热闹社团表象＋上台绝对专业”的感慨 · 原样保留）：**  
  - `zh_CN`：麻纪望着楼下中庭，脸上带着一丝忍俊不禁的温和笑意。「刚来报到的时候，看大家在休息室里热热闹闹地开玩笑，我还担心自己这么拘谨会不会融不进去。结果一进手术间，不管是哪位医生还是年轻护士，眼神一下子就全变了……星见真是一所不可思议的医院呢。」  
  - `en`：Maki looks down toward the courtyard with a gentle, faintly amused smile. "When I first reported for duty and saw everyone joking so livelily in the lounge, I worried someone as reserved as me might not fit in. Yet the moment we step into the operating room, every doctor and young nurse switches into complete focus... Hoshimi really is a remarkable hospital."
- **回应 3（脚踏实地的进阶心态 · 已消除傍晚晚风前提）：**  
  - `zh_CN`：天台的风吹起麻纪双肩前的低束长发，她将吹乱的发丝轻轻别好，目光清亮而认真。「以前总觉得『独当一面』是很遥远又吓人的词。不过最近跟在坂口医生和各位前辈身边看久了，我也慢慢明白——不用急着一步登天，先把眼前每一台助手的视野和止血配合做到九十分，路自然就走稳了。」  
  - `en`：The rooftop breeze stirs the low twin ties of Maki's hair over her shoulders; she tucks a loose strand neatly back, her gaze clear and earnest. "'Standing on one's own' used to sound so distant and intimidating to me. Watching you and the other senior surgeons up close lately, though, I've come to realize there's no need to rush—if I can bring my exposure and hemostasis support as an assistant up to solid marks one case at a time, the path forward will steady itself."

---

## 二、 更新后的医生档案草案（`profile_draft.json` V1.1 · 可解析 JSON）

```json
{
  "status": "authoring_draft_not_loadable_staff_profile",
  "proposed_id": "doc_maki",
  "source": "HOSHIMI_AIZAWA_MAKI_CHARACTER_BIBLE.md",
  "confirmed": {
    "name": "相澤 麻紀",
    "name_zh_simplified": "相泽麻纪",
    "name_en": "Maki Aizawa",
    "adult": true,
    "profession": "doctor",
    "gender": "female",
    "team_category": "doctor",
    "specialty": "普通外科",
    "specialty_en": "General Surgery",
    "rank": "年轻外科医师／初期接受带教",
    "rank_en": "Junior Surgeon / Supervised Surgical Trainee",
    "personality": "礼貌拘谨、有责任感、有主见；对风险敏感，专业讨论清楚具体，重视术野复盘。",
    "personality_en": "Polite and reserved, yet responsible and principled; risk-conscious, clear and concrete in clinical discussions, and diligent about reviewing operative fields.",
    "appearance": "灰橄榄调浅棕长发、双肩前低束发、深色方框眼镜；以原作 ASS_03 种子图为身份锚点。",
    "appearance_en": "Ash-olive light brown long hair tied low over both shoulders, dark rectangular-framed glasses; anchored to the original ASS_03 portrait reference.",
    "dialogue_style": "礼貌、克制、具体；专业说明不口头禅式结巴。",
    "dialogue_style_en": "Polite, composed, and specific; delivers clinical explanations clearly without habitual stuttering.",
    "initial_role_after_onboarding": "assistant_surgeon",
    "surgery_eligibility": "完成 Lv0 入职后可参加普通手术和高级手术的助手编组（沿用现有规则，不设麻纪专属的高级助手禁令）；初期仍不开放独立主刀资格。",
    "mentor": "player",
    "prior_rescue_outcome": "患者获救；不能认定事故由她造成",
    "university_relation": "与明日香、深山同校，毕业晚两届；私人熟悉程度待定",
    "age": 21,
    "age_basis": "用户指定比深山与明日香小2岁；两者当前profile均23岁（2026-11-13核对）",
    "skills": {
      "surgery": 48,
      "diagnostics": 65,
      "teamwork": 72,
      "patient_care": 68,
      "instrument_handling": 56,
      "calmness": 45
    },
    "skills_basis": "用户已确认维持 48/65/72/68/56/45（其中 surgery=48 低于明日香当前手术能力 66，符合初期不独立主刀定位）",
    "romanceable": true,
    "romance_positioning_note": "明确为可攻略角色，Lv0–Lv5 剧情尚未完成；暂不补写恋爱事件、进阶门槛或亲密解锁条件。",
    "relationship_initial_values": {
      "affection": 0,
      "familiarity": 0,
      "level": 0,
      "route": "colleague"
    },
    "route_semantics_note": "route=\"colleague\" 仅表示初始同事关系，不是不可攻略或永久友情路线。",
    "presence": {
      "unlocked_after_lv0": true,
      "lounge": {
        "mode": "fixed_presence",
        "outfit": "white_coat"
      },
      "rooftop": {
        "mode": "random_encounter",
        "outfit": "white_coat"
      },
      "note": "完成 Lv0 入职后开放；具体随机在场机制由工程按现有系统处理，不新增精确排班承诺。"
    }
  },
  "recommendations_pending_approval": {
    "surgery_proficiency": "limited",
    "surgery_proficiency_note": "仍作为建议列出，不宣称已经正式批准。",
    "situational_intraoperative_candidate": {
      "zh_CN": "「牵开角度已经稳住了，坂口医生。深面这一层的筋膜间隙比预想的要薄一点，边缘有细小渗血，需要先确认止血再往下分吗？」",
      "en": "\"I have the retraction angle steady, Dr. Sakaguchi. The fascial plane down here looks slightly thinner than expected, with minor oozing along the edge—shall we secure hemostasis before dissecting further?\"",
      "usage_note": "保留为软组织分层／细小渗血情境专用候选；默认通用槽使用不预设特定结构与出血的通用回应。"
    }
  },
  "pending": {
    "birthday": null,
    "height_cm": null,
    "lv0_to_lv5_scripts_and_gates": null
  },
  "notes": [
    "null 只用于制作资料标记未定项，禁止直接原样导入运行 Schema。",
    "生日、身高不是当前 staff Schema 的必需字段，不凭想象硬填。",
    "未完成独立 Lv0 入职事件前，不开放院内常驻在场与手术助手编组。",
    "完成 Lv0 入职后沿用现有普通及高级手术助手编组规则，初期不授予独立主刀资格。"
  ]
}
```

---

## 三、 角色台词与元信息交付包（严格兼容 `dialogue_delivery.schema.json` · 可解析 JSON）

```json
{
  "format_version": "maki_author_delivery_v1",
  "status": "draft",
  "actor_id": "doc_maki",
  "speaker_labels": {
    "doc_maki": {
      "zh_CN": "相澤麻紀",
      "en": "Maki Aizawa"
    },
    "player": {
      "zh_CN": "坂口隆司",
      "en": "Ryuji Sakaguchi"
    },
    "narrator": {
      "zh_CN": "旁白",
      "en": "Narrator"
    }
  },
  "team_dialogue": {
    "assignment": {
      "zh_CN": "麻纪迅速将术前资料的页角对齐，认真抬头看向坂口：「患者的基础指标和手术入路我已经预习过了。今天助手的位置，请多指教，坂口医生。」",
      "en": "Maki neatly aligns the corners of the preoperative chart and looks up earnestly at Sakaguchi. \"I have reviewed the patient's baseline findings and the planned approach. I'll do my best assisting you today, Dr. Sakaguchi.\""
    },
    "intraoperative": {
      "zh_CN": "「这边的视野已经按您的要求稳住了，坂口医生。我正盯着您的操作节奏，下一步需要调整配合角度的话，请随时告诉我。」",
      "en": "\"I have the field steady on this side as requested, Dr. Sakaguchi. I'm following your pace closely—please let me know right away if you need me to adjust my angle for the next step.\""
    }
  },
  "idle_chats": [
    {
      "id": "maki_lounge_chat",
      "location_id": "lounge",
      "label": {
        "zh_CN": "和相泽医生聊聊近况",
        "en": "Chat with Dr. Aizawa"
      },
      "responses": [
        {
          "zh_CN": "麻纪正坐在休息室圆桌边，用细头钢笔在随身笔记本上整理手绘的术野解剖简图。「啊，坂口医生。我习惯趁着休息空当，把之前跟台时记下的拉钩角度和暴露层次重新梳理一遍——比如深部结扎的时候，拉钩要是再往外侧让开五度，主刀的视野应该会更敞亮吧？等之后查房核对引流情况的时候，我也会再对照印证一下的。」",
          "en": "Maki sits at the round table in the lounge, organizing hand-drawn surgical field sketches in her pocket notebook with a fine-tipped pen. \"Ah, Dr. Sakaguchi. Whenever I have a spare moment, I like to go back over the retractor angles and exposure layers from previous cases—for instance, angling five degrees further laterally during deep ligation should give the lead surgeon a clearer view, right? I always cross-check my notes against the drain findings on subsequent rounds too.\""
        },
        {
          "zh_CN": "麻纪把一摞整理整齐的术后观察表收进文件夹，端起温茶轻轻舒了一口气。「以前在原来的大医院，平时大部分时间我都只是坐在电脑前，机械地抄写十几床的常规病程。来到星见以后，前辈们真的愿意在台边告诉我每一钳为什么要那样下……虽然每次刷手前心跳还是有点快，但这种真正作为外科医生在学习的感觉，真的很踏实。」",
          "en": "Maki tucks a neatly stacked set of postoperative charts into her folder and takes a quiet sip of warm tea. \"Back at my old hospital, I spent most of my days just sitting at a terminal, mechanically typing up routine progress notes for a dozen beds. Here at Hoshimi, my seniors actually explain why each clamp goes where it does right at the table... My heart still races a little before scrubbing in, but finally learning as a real surgeon feels deeply reassuring.\""
        },
        {
          "zh_CN": "麻纪合上手边的《开放手术局部解剖图谱》，自然地扶了一下深色方框眼镜。「坂口医生也来休息吗？我刚在对照两套不同入路的血管变异分支。总觉得光是背熟正常走行还不够，要是哪天在台上遇到不典型的分支，至少得做到第一时间认出来、及时向主刀报告才行。」",
          "en": "Maki closes the Atlas of Open Surgical Anatomy beside her and briefly adjusts her dark-framed glasses. \"Taking a break too, Dr. Sakaguchi? I was just comparing vascular anatomical variants across two different approaches. Memorizing standard textbook anatomy alone doesn't feel like enough—if an atypical branch ever shows up in the field, I want to be able to recognize it right away and report it to the lead surgeon.\""
        }
      ]
    },
    {
      "id": "maki_rooftop_chat",
      "location_id": "rooftop",
      "label": {
        "zh_CN": "在天台和相泽医生吹风",
        "en": "Chat with Dr. Aizawa on the rooftop"
      },
      "responses": [
        {
          "zh_CN": "麻纪站在天台栏杆旁，迎着微风慢慢做了一次深呼吸，随后低头看了看自己摊开的双手。「坂口医生。每次跟完需要长时间保持牵引的手术，我的手指偶尔还是会因为绷得太久有一点点发僵……所以我喜欢趁空当上来吹两分钟风、把呼吸放慢下来，之后再去病房换药或者做检查，手就稳多了。」",
          "en": "Standing by the rooftop railing, Maki takes a slow, deep breath against the breeze before looking down at her open palms. \"Dr. Sakaguchi. Whenever I finish a case that requires holding retraction for a long stretch, my fingers still get a little stiff from the tension... That's why I like coming up here for a couple of minutes to catch the breeze and slow my breathing—my hands feel much steadier for ward dressings and exams afterward.\""
        },
        {
          "zh_CN": "麻纪望着楼下中庭，脸上带着一丝忍俊不禁的温和笑意。「刚来报到的时候，看大家在休息室里热热闹闹地开玩笑，我还担心自己这么拘谨会不会融不进去。结果一进手术间，不管是哪位医生还是年轻护士，眼神一下子就全变了……星见真是一所不可思议的医院呢。」",
          "en": "Maki looks down toward the courtyard with a gentle, faintly amused smile. \"When I first reported for duty and saw everyone joking so livelily in the lounge, I worried someone as reserved as me might not fit in. Yet the moment we step into the operating room, every doctor and young nurse switches into complete focus... Hoshimi really is a remarkable hospital.\""
        },
        {
          "zh_CN": "天台的风吹起麻纪双肩前的低束长发，她将吹乱的发丝轻轻别好，目光清亮而认真。「以前总觉得『独当一面』是很遥远又吓人的词。不过最近跟在坂口医生和各位前辈身边看久了，我也慢慢明白——不用急着一步登天，先把眼前每一台助手的视野和止血配合做到九十分，路自然就走稳了。」",
          "en": "The rooftop breeze stirs the low twin ties of Maki's hair over her shoulders; she tucks a loose strand neatly back, her gaze clear and earnest. \"'Standing on one's own' used to sound so distant and intimidating to me. Watching you and the other senior surgeons up close lately, though, I've come to realize there's no need to rush—if I can bring my exposure and hemostasis support as an assistant up to solid marks one case at a time, the path forward will steady itself.\""
        }
      ]
    }
  ],
  "first_assignment_cg": {
    "title": {
      "zh_CN": "第一助手的确认",
      "en": "First Assistant Ready"
    },
    "caption": {
      "zh_CN": "无影灯下，穿戴好全套无菌手术袍的相泽麻纪隔着外科口罩认真迎上主刀的视线，确认术前准备就绪。",
      "en": "Beneath the operating lights, Maki Aizawa—gowned and gloved in full sterile attire—meets the lead surgeon's gaze steadily above her mask to confirm readiness."
    }
  },
  "lv0": {
    "title": {
      "zh_CN": "排班表上的名字",
      "en": "A Name on the Roster"
    },
    "announcement": {
      "zh_CN": "新聘普通外科医师相泽麻纪今天正式来院报到了。",
      "en": "Newly appointed general surgeon Dr. Maki Aizawa has reported for duty today."
    },
    "completion_hint": {
      "zh_CN": "相泽麻纪已完成入职带教手术，正式加入医院常驻排班与手术助手编组名单。",
      "en": "Maki Aizawa has completed her onboarding surgery and joined the regular hospital roster and surgical assistant pool."
    },
    "gallery_title": {
      "zh_CN": "排班表上的名字",
      "en": "A Name on the Roster"
    },
    "duration_minutes_proposal": 30,
    "start_scene": null,
    "scenes": [],
    "completion_facts_in_words": [
      "在城宮明日香 Lv2 面试录用约 30 天后的首个可用工作日触发本独立入职事件。",
      "完成本事件后，开放休息室固定在场与天台随机遇见（均着白大褂），并可参加普通和高级手术的助手编组（沿用现有规则，不设麻纪专属高级助手禁令）；初期仍不开放独立主刀资格。"
    ],
    "open_questions": [
      "独立入职事件《排班表上的名字》按当前指示暂留空数组，待后续提供或确认分场要求后再补写正文。",
      "中文 UI 说话人标签（speaker_labels.doc_maki.zh_CN）最终采用『相澤麻紀』还是『相泽麻纪』可由工程统一对齐。"
    ]
  },
  "asset_requests": [],
  "author_notes": [
    "攻略定位已确认：相泽麻纪为可攻略角色（Lv0–Lv5 剧情待制作），初始 affection=0、familiarity=0、level=0、route='colleague'（表示初始同事状态，非不可攻略）。",
    "手术资格已确认：Lv0 完成后可参与普通和高级手术助手编组（无专属禁令），初期不开放独立主刀；surgery_proficiency='limited' 作为建议保留。",
    "常驻配置已确认：Lv0 完成后开放 lounge 固定在场与 rooftop 随机遇见，两处均使用 white_coat 立绘。",
    "team_dialogue.intraoperative 已填入跨术式通用配合回应；原 V1『牵开角度已经稳住了……深面这一层的筋膜间隙比预想的要薄一点，边缘有细小渗血，需要先确认止血再往下分吗？』完整保留为情境专用候选（见上方速览表与 profile_draft.json）。",
    "idle_chats 休息室第 1、2 条与天台第 1、3 条已改为无时段与刚下台前提的日常版本；休息室第 3 条与天台第 2 条原样保留。"
  ]
}
```

---

## 四、 Revision Log（V1.0 → V1.1 定点修改清单）

1. **明确可攻略定位与初始关系值**：明确标注麻纪为可攻略角色（`romanceable: true`，`Lv0–Lv5` 剧情待完成），初始关系设为 `affection=0`、`familiarity=0`、`level=0`、`route="colleague"`（说明 `colleague` 仅代表初始同事阶段，而非不可攻略或永久友情线），未擅自补写进阶门槛或亲密条件。
2. **修正手术助手编组资格**：明确完成 Lv0 入职后即可参加**普通和高级手术的助手编组**（沿用现有规则，取消麻纪专属的高级助手限制表述），初期仍不开放独立主刀资格。
3. **锁定常驻与随机遇见地点**：更新为完成 Lv0 入职后开放**休息室（`lounge`）固定在场**与**天台（`rooftop`）随机遇见**，两处均穿白大褂（`white_coat`），具体随机机制交由工程现有逻辑处理。
4. **新增全术式通用术中回应并保留原情境候选**：在 `team_dialogue.intraoperative` 中填入不预设出血、特定解剖结构或异常发现的中英双语通用配合台词；原 V1 的“筋膜较薄、边缘细小渗血”双语台词完整保留在速览表与 `profile_draft.json` 中作为情境专用候选。
5. **定点改为不限时闲谈版本**：仅针对休息室第 1、2 条与天台第 1、3 条消除了“刚和坂口做完手术”“明天早查房”“当前是下午／傍晚晚风”等时间前提，同步更新英文译文；休息室第 3 条与天台第 2 条保持一字未动。
6. **修正明日香手术数值参照并补齐英文档案文本**：将文中提及的明日香手术能力参照修正为现行数值 **66**；维持麻纪六维 `48 / 65 / 72 / 68 / 56 / 45` 不变；补齐专科、职级、性格、外貌及说话方式的英文显示文本；将 `surgery_proficiency="limited"` 作为待批建议单独列出。
