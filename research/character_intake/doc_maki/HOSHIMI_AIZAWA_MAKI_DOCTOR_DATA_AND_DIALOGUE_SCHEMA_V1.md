# Hoshimi Hospital／星见医院 — 相澤麻紀（`doc_maki`）医生数据与角色台词 Schema 交付稿 V1.0

**版本：** Authoring Package V1.0（已锁定六维数值 ＋ 已填完除 Lv0 正文外的全部台词与元信息 Schema）  
**状态：** 初稿待审阅（`lv0.scenes` 按指示暂留空数组 `[]`，其余台词与中英本地化均已填齐并严格对齐 `dialogue_delivery.schema.json`）  
**对应角色：** 相澤 麻紀 / 相泽麻纪 / Maki Aizawa（`doc_maki`，21岁，普通外科医师）  
**参考基准：**  
- `HOSHIMI_AIZAWA_MAKI_CHARACTER_BIBLE.md`（2026-11-13）  
- `HOSHIMI_SHIROMIYA_ASUKA_LV2_SUITABLE_PERSON_SUITABLE_GOWN_V1_1.md`（正式面试稿）  
- `writing/WRITER_HANDOFF.md`、`writing/dialogue_delivery.schema.json`、`profile_draft.json`、`ready_assets.json`  

---

## 一、 人工审阅速览表（数值与台词可读版）

### 1.1 已确认基础档案与六维能力（`profile` 核心数据）

| 字段 | 确认值 | 设计与连续性说明 |
| :--- | :---: | :--- |
| **Actor ID** | `doc_maki` | 稳定角色标识 |
| **姓名（显示／简／英）** | 相澤 麻紀 ／ 相泽麻纪 ／ Maki Aizawa | 见文末待确认项：UI 姓名栏统一用繁体日式汉字或简体 |
| **年龄** | **21 岁**（成年） | 用户已确认：比 23 岁的明日香与深山小 2 岁，同所女子医大晚两届 |
| **专科与初期定位** | 普通外科 · 受训年轻外科医师 | 明日香 Lv2 面试录用，约 1 个月后完成独立 Lv0 入职事件方才入池；初期仅开放**普通手术助手位（`assistant_surgeon`）**，主要带教为坂口隆司，无独立主刀或高级手术权限 |
| **`surgery`（手术操作）** | **48**（已确认保留原值） | 已完成外科基础轮转、懂常规入路与解剖，但尚不足以独立主刀（低于明日香 55–60 线） |
| **`diagnostics`（诊断评估）** | **65**（已确认保留原值） | 前院管床、术前评估与术后次日引流复核功底扎实 |
| **`teamwork`（团队配合）** | **72**（已确认保留原值） | 六维最高项；守纪律、配合认真，发现安全风险敢于主动出声通报 |
| **`patient_care`（患者照护）** | **68**（已确认保留原值） | 重视围术期观察与患者安全底线 |
| **`instrument_handling`（器械与暴露）** | **56**（已确认保留原值） | 具备二助拉钩与术后手绘复盘积累，尚需在一助位继续打磨持续稳定性 |
| **`calmness`（临场镇定）** | **45**（已确认保留原值） | 当前核心短板；受既往参与术后迟发出血抢救经历影响，高压下偶有短暂停顿，留足成长空间 |

---

### 1.2 手术编队、术中配合与首次助手 CG 文案速览

| 槽位路径 | 中文正文（`zh_CN`） | 英文译文（`en`） | 对应立绘／资产建议 |
| :--- | :--- | :--- | :--- |
| **`team_dialogue.assignment`**<br>*(编队选中回应 · 单字符串)* | 麻纪迅速将术前资料的页角对齐，认真抬头看向坂口：「患者的基础指标和手术入路我已经预习过了。今天助手的位置，请多指教，坂口医生。」 | Maki neatly aligns the corners of the preoperative chart and looks up earnestly at Sakaguchi. "I have reviewed the patient's baseline findings and the planned approach. I'll do my best assisting you today, Dr. Sakaguchi." | `white_coat/focused` |
| **`team_dialogue.intraoperative`**<br>*(术中通用配合 · 不绑病种)* | 「牵开角度已经稳住了，坂口医生。深面这一层的筋膜间隙比预想的要薄一点，边缘有细小渗血，需要先确认止血再往下分吗？」 | "I have the retraction angle steady, Dr. Sakaguchi. The fascial plane down here looks slightly thinner than expected, with minor oozing along the edge—shall we secure hemostasis before dissecting further?" | `sterile/focused` |
| **`first_assignment_cg.title`** | 第一助手的确认 | First Assistant Ready | `assets/events/maki_first_assistant_v1/assistant_confirmation.png` |
| **`first_assignment_cg.caption`** | 无影灯下，穿戴好全套无菌手术袍的相泽麻纪隔着外科口罩认真迎上主刀的视线，确认术前准备就绪。 | Beneath the operating lights, Maki Aizawa—gowned and gloved in full sterile attire—meets the lead surgeon's gaze steadily above her mask to confirm readiness. | 同上（手术室内麻纪面向主角的主观视角） |

---

### 1.3 常驻日常闲谈（`idle_chats`：休息室 3 条 ＋ 天台 3 条）

#### A. 医护休息室（`location_id: "lounge"` ｜ 交互标签：「和相泽医生聊聊近况」 / `"Chat with Dr. Aizawa"`）
- **回应 1（手绘术野笔记与拉钩复盘）：**  
  - `zh_CN`：麻纪正坐在休息室圆桌边，用细头钢笔在随身笔记本上勾勒刚下台的局部解剖层次。「啊，坂口医生。趁着刚才手上的感觉还没散，我想把第二层牵开时的拉钩角度记下来——刚才如果再往外侧让开五度，您的结扎视野应该会更敞亮吧？明天早查房核对引流液的时候，我会再印证一下的。」  
  - `en`：Maki sits at the round table in the lounge, sketching the anatomical layers from her last case into a pocket notebook with a fine-tipped pen. "Ah, Dr. Sakaguchi. While the tactile memory is still fresh, I wanted to note down the retractor angle during the second-layer exposure—if I had angled five degrees further laterally, you would have had a clearer view for ligation, right? I'll cross-check it against the drain output during morning rounds tomorrow."
- **回应 2（前院文书流水线 vs 星见实操带教）：**  
  - `zh_CN`：麻纪把一摞整理整齐的术后观察表收进文件夹，端起温茶轻轻舒了一口气。「以前在原来的大医院，下午这个时候我通常还在电脑前机械地抄写十几床的常规病程。来到星见以后，前辈们真的愿意在台边告诉我每一钳为什么要那样下……虽然每次刷手前心跳还是有点快，但这种真正作为外科医生在学习的感觉，真的很踏实。」  
  - `en`：Maki tucks a neatly stacked set of postoperative charts into her folder and takes a quiet sip of warm tea. "Back at my old hospital, I'd usually still be at a terminal at this hour, mechanically typing up routine progress notes for a dozen beds. Here at Hoshimi, my seniors actually explain why each clamp goes where it does right at the table... My heart still races a little before scrubbing in, but finally learning as a real surgeon feels deeply reassuring."
- **回应 3（研读解剖变异与主动预警准备）：**  
  - `zh_CN`：麻纪合上手边的《开放手术局部解剖图谱》，自然地扶了一下深色方框眼镜。「坂口医生也来休息吗？我刚在对照两套不同入路的血管变异分支。总觉得光是背熟正常走行还不够，要是哪天在台上遇到不典型的分支，至少得做到第一时间认出来、及时向主刀报告才行。」  
  - `en`：Maki closes the Atlas of Open Surgical Anatomy beside her and briefly adjusts her dark-framed glasses. "Taking a break too, Dr. Sakaguchi? I was just comparing vascular anatomical variants across two different approaches. Memorizing standard textbook anatomy alone doesn't feel like enough—if an atypical branch ever shows up in the field, I want to be able to recognize it right away and report it to the lead surgeon."

#### B. 医院天台（`location_id: "rooftop"` ｜ 交互标签：「在天台和相泽医生吹风」 / `"Chat with Dr. Aizawa on the rooftop"`）
- **回应 1（下台后吹风平复手指紧绷）：**  
  - `zh_CN`：麻纪站在天台栏杆旁，迎着微风慢慢做了一次深呼吸，随后低头看了看自己摊开的双手。「坂口医生。刚从手术室出来的时候，手指偶尔还是会因为绷得太久有一点点发僵……上来吹两分钟凉风，把呼吸放慢下来，下午再去病房换药的时候手就稳多了。」  
  - `en`：Standing by the rooftop railing, Maki takes a slow, deep breath against the breeze before looking down at her open palms. "Dr. Sakaguchi. Right after stepping out of the OR, my fingers still get a little stiff from holding tension for so long... Catching the cool air up here for a couple of minutes slows my breathing down, so my hands are much steadier for afternoon dressing changes."
- **回应 2（对星见“热闹社团表象＋上台绝对专业”的感慨）：**  
  - `zh_CN`：麻纪望着楼下中庭，脸上带着一丝忍俊不禁的温和笑意。「刚来报到的时候，看大家在休息室里热热闹闹地开玩笑，我还担心自己这么拘谨会不会融不进去。结果一进手术间，不管是哪位医生还是年轻护士，眼神一下子就全变了……星见真是一所不可思议的医院呢。」  
  - `en`：Maki looks down toward the courtyard with a gentle, faintly amused smile. "When I first reported for duty and saw everyone joking so livelily in the lounge, I worried someone as reserved as me might not fit in. Yet the moment we step into the operating room, every doctor and young nurse switches into complete focus... Hoshimi really is a remarkable hospital."
- **回应 3（脚踏实地的进阶心态）：**  
  - `zh_CN`：晚风吹起麻纪双肩前的低束长发，她将吹乱的发丝轻轻别好，目光清亮而认真。「以前总觉得『独当一面』是很遥远又吓人的词。不过最近跟在坂口医生和各位前辈身边看久了，我也慢慢明白——不用急着一步登天，先把今天每一台助手的视野和止血配合做到九十分，路自然就走稳了。」  
  - `en`：The breeze stirs the low twin ties of Maki's hair over her shoulders; she tucks a loose strand neatly back, her gaze clear and earnest. "'Standing on one's own' used to sound so distant and intimidating to me. Watching you and the other senior surgeons up close lately, though, I've come to realize there's no need to rush—if I can bring my exposure and hemostasis support as an assistant up to solid marks one case at a time, the path forward will steady itself."

---

## 二、 更新后的医生档案草案（`profile_draft.json` V1.1）

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
    "rank": "年轻外科医师／初期接受带教",
    "personality": "礼貌拘谨、有责任感、有主见；对风险敏感，专业讨论清楚具体，重视术野复盘。",
    "appearance": "灰橄榄调浅棕长发、双肩前低束发、深色方框眼镜；以原作 ASS_03 种子图为身份锚点。",
    "dialogue_style": "礼貌、克制、具体；专业说明不口头禅式结巴。",
    "initial_role_after_onboarding": "assistant_surgeon",
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
    "skills_basis": "2026-11-13 用户确认原封保留初始建议六维数值（48/65/72/68/56/45）"
  },
  "proposed_runtime_semantics": {
    "status": "authoring_proposal_pending_user_and_codex_check",
    "unlock_flow": {
      "interview_event": "城宮明日香 Lv2《合适的人，合适的手术袍》（当场接受录用邀请并记录面试日期，暂不入池）",
      "onboarding_delay_days": 30,
      "onboarding_event": "相澤麻紀 Lv0《排班表上的名字》（完成后正式激活常驻排班与普通手术助手资格）"
    },
    "rank_slots_semantics": {
      "routine_surgery_assistant": true,
      "routine_surgery_primary_surgeon": false,
      "advanced_referral_primary_surgeon": false
    },
    "presence_locations_proposal": [
      {
        "location_id": "lounge",
        "outfit": "white_coat",
        "note": "工作日主力常驻点，匹配术后手绘笔记与翻阅图谱习惯，直接使用现有 white_coat 立绘"
      },
      {
        "location_id": "rooftop",
        "outfit": "white_coat",
        "note": "午休／下台间隙轮换点，匹配吹风平复呼吸习惯，无需调用缺失的 scrubs 立绘"
      }
    ],
    "team_dialogue_preview": {
      "assignment": "麻纪迅速将术前资料的页角对齐，认真抬头看向坂口：「患者的基础指标和手术入路我已经预习过了。今天助手的位置，请多指教，坂口医生。」",
      "intraoperative": "「牵开角度已经稳住了，坂口医生。深面这一层的筋膜间隙比预想的要薄一点，边缘有细小渗血，需要先确认止血再往下分吗？」"
    },
    "relationship_initial_values": {
      "met_before_lv0": false,
      "met_after_lv0": true,
      "relationship_level": 0,
      "familiarity": 0
    }
  },
  "pending": {
    "birthday": null,
    "height_cm": null,
    "surgery_proficiency": null,
    "romance_route": null,
    "relationship_lv1_to_lv5_gates": null
  },
  "notes": [
    "null 只用于制作资料标记未定项，禁止直接原样导入运行 Schema；Codex 须对照 data/schemas/content.schema.json 映射真实运行字段。",
    "生日、身高不是当前 staff Schema 的必需字段，不凭想象硬填。",
    "未完成独立 Lv0 入职事件前，严禁提前将 doc_maki 暴露在日常地图或手术编队列表中。",
    "初期无独立主刀或高级手术主刀授权；是否开放恋爱路线与 Lv1-Lv5 Gate 待用户后续单独决定。"
  ]
}
```

---

## 三、 角色台词与元信息交付包（严格兼容 `dialogue_delivery.schema.json`）

> **校验说明**：以下 JSON 严格遵循 `maki_author_delivery_v1` Schema 定义（无多余未声明字段、所有必填键齐全、ID 正则合规、`idle_chats` 每组满 3 条双语回应）；因 `lv0` 正文按指示暂缓编写，`status` 设为 `"draft"`，`lv0.start_scene` 设为 `null`，`lv0.scenes` 设为 `[]`（符合 Schema `minItems: 0` 约束）。

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
      "zh_CN": "「牵开角度已经稳住了，坂口医生。深面这一层的筋膜间隙比预想的要薄一点，边缘有细小渗血，需要先确认止血再往下分吗？」",
      "en": "\"I have the retraction angle steady, Dr. Sakaguchi. The fascial plane down here looks slightly thinner than expected, with minor oozing along the edge—shall we secure hemostasis before dissecting further?\""
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
          "zh_CN": "麻纪正坐在休息室圆桌边，用细头钢笔在随身笔记本上勾勒刚下台的局部解剖层次。「啊，坂口医生。趁着刚才手上的感觉还没散，我想把第二层牵开时的拉钩角度记下来——刚才如果再往外侧让开五度，您的结扎视野应该会更敞亮吧？明天早查房核对引流液的时候，我会再印证一下的。」",
          "en": "Maki sits at the round table in the lounge, sketching the anatomical layers from her last case into a pocket notebook with a fine-tipped pen. \"Ah, Dr. Sakaguchi. While the tactile memory is still fresh, I wanted to note down the retractor angle during the second-layer exposure—if I had angled five degrees further laterally, you would have had a clearer view for ligation, right? I'll cross-check it against the drain output during morning rounds tomorrow.\""
        },
        {
          "zh_CN": "麻纪把一摞整理整齐的术后观察表收进文件夹，端起温茶轻轻舒了一口气。「以前在原来的大医院，下午这个时候我通常还在电脑前机械地抄写十几床的常规病程。来到星见以后，前辈们真的愿意在台边告诉我每一钳为什么要那样下……虽然每次刷手前心跳还是有点快，但这种真正作为外科医生在学习的感觉，真的很踏实。」",
          "en": "Maki tucks a neatly stacked set of postoperative charts into her folder and takes a quiet sip of warm tea. \"Back at my old hospital, I'd usually still be at a terminal at this hour, mechanically typing up routine progress notes for a dozen beds. Here at Hoshimi, my seniors actually explain why each clamp goes where it does right at the table... My heart still races a little before scrubbing in, but finally learning as a real surgeon feels deeply reassuring.\""
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
          "zh_CN": "麻纪站在天台栏杆旁，迎着微风慢慢做了一次深呼吸，随后低头看了看自己摊开的双手。「坂口医生。刚从手术室出来的时候，手指偶尔还是会因为绷得太久有一点点发僵……上来吹两分钟凉风，把呼吸放慢下来，下午再去病房换药的时候手就稳多了。」",
          "en": "Standing by the rooftop railing, Maki takes a slow, deep breath against the breeze before looking down at her open palms. \"Dr. Sakaguchi. Right after stepping out of the OR, my fingers still get a little stiff from holding tension for so long... Catching the cool air up here for a couple of minutes slows my breathing down, so my hands are much steadier for afternoon dressing changes.\""
        },
        {
          "zh_CN": "麻纪望着楼下中庭，脸上带着一丝忍俊不禁的温和笑意。「刚来报到的时候，看大家在休息室里热热闹闹地开玩笑，我还担心自己这么拘谨会不会融不进去。结果一进手术间，不管是哪位医生还是年轻护士，眼神一下子就全变了……星见真是一所不可思议的医院呢。」",
          "en": "Maki looks down toward the courtyard with a gentle, faintly amused smile. \"When I first reported for duty and saw everyone joking so livelily in the lounge, I worried someone as reserved as me might not fit in. Yet the moment we step into the operating room, every doctor and young nurse switches into complete focus... Hoshimi really is a remarkable hospital.\""
        },
        {
          "zh_CN": "晚风吹起麻纪双肩前的低束长发，她将吹乱的发丝轻轻别好，目光清亮而认真。「以前总觉得『独当一面』是很遥远又吓人的词。不过最近跟在坂口医生和各位前辈身边看久了，我也慢慢明白——不用急着一步登天，先把今天每一台助手的视野和止血配合做到九十分，路自然就走稳了。」",
          "en": "The breeze stirs the low twin ties of Maki's hair over her shoulders; she tucks a loose strand neatly back, her gaze clear and earnest. \"'Standing on one's own' used to sound so distant and intimidating to me. Watching you and the other senior surgeons up close lately, though, I've come to realize there's no need to rush—if I can bring my exposure and hemostasis support as an assistant up to solid marks one case at a time, the path forward will steady itself.\""
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
      "zh_CN": "相泽麻纪已完成入职带教手术，正式加入医院常驻排班与普通手术助手名单。",
      "en": "Maki Aizawa has completed her onboarding surgery and joined the regular hospital roster and routine surgical assistant pool."
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
      "完成本事件后，正式开放相泽麻纪的院内常驻日常互动与普通手术可选助手资格；不授予独立主刀资格或高级手术主刀权限。"
    ],
    "open_questions": [
      "独立入职事件《排班表上的名字》按作者当前指示暂缓编写正文；后续动笔前请确认是否提供 HOSHIMI_AIZAWA_MAKI_LV0_ONBOARDING_VN_WRITING_BRIEF.md 原文，或直接按 Character Bible §5.2 已锁定契约展开。",
      "中文 UI 说话人标签（speaker_labels.doc_maki.zh_CN）最终采用保留日式汉字的『相澤麻紀』还是简体『相泽麻纪』。",
      "常驻闲谈地点是否正式锁定为模板建议的 lounge（休息室）与 rooftop（天台）两处。",
      "除常驻助手与日常闲谈外，后续是否开放『下班同行（After-work Walk）』、周日约会或独立 Relationship Lv1–Lv5 路线。"
    ]
  },
  "asset_requests": [],
  "author_notes": [
    "六维能力值已按作者 2026-11-13 指示原封保留 48/65/72/68/56/45。",
    "team_dialogue、idle_chats（休息室3条＋天台3条）、first_assignment_cg 及 lv0 外围元信息均已同步填妥中英双语文本。",
    "所有日常与编队演出均严格匹配 ready_assets.json 现有的 white_coat 与 sterile 立绘及 assistant_confirmation.png，零强制新增美术依赖；推眼镜动作全套仅在休息室第3条自然出现一次。"
  ]
}
```
