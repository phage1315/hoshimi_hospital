# Hoshimi Hospital／星见医院 — 相澤麻紀（`doc_maki`）医生数据与角色台词 Schema 交付稿 V1.3

**版本：** Authoring Package V1.3（补齐周日约会 Sunday Date 地点偏好与 1+1+1+2 全套中英双语台词，并附秋季备选地点台词；完整保留 V1.2 全部已修订内容）  
**状态：** V1.3 修订完成 / 待审阅（`lv0.scenes` 继续留空 `[]`，全部 JSON 严格可解析且对齐 `dialogue_delivery.schema.json`）  
**对应角色：** 相澤 麻紀 / 相泽麻纪 / Maki Aizawa（`doc_maki`，21岁，普通外科医师）  
**参考基准：**  
- `HOSHIMI_AIZAWA_MAKI_CHARACTER_BIBLE.md`（2026-11-13）  
- `HOSHIMI_SHIROMIYA_ASUKA_LV2_SUITABLE_PERSON_SUITABLE_GOWN_V1_1.md`（正式面试稿）  
- `HOSHIMI_SUNDAY_DATE_CHARACTER_VENUE_PREFERENCES.md`（周日约会地点池与四类对白规范）  
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
| **手术资格与熟练度配置** | 普通及高级手术助手编组可用；初期无独立主刀资格 | Assistant eligible (routine & advanced); primary surgeon disabled; `surgery_proficiency="limited"`（含配套操作不符纠正回应） | 完成 Lv0 入职后沿用现有助手编组规则，不设麻纪专属高级助手禁令 |
| **院内常驻地点配置** | 休息室固定在场 ＋ 天台随机遇见（均着白大褂） | `lounge` (fixed, `white_coat`) + `rooftop` (random encounter, `white_coat`) | 完成 Lv0 入职后开放；具体随机机制由工程处理 |
| **周日约会（Sunday Date）配置** | 首选：**大型书店 ＋ 植物园温室**（双全年；另附**红叶古寺〔秋〕**备选） | 需完成 Lv0 入职 ＋ `Familiarity >= 10`；建议基础接受率 `Lv0:60% → Lv2:80% → Lv3:92% → Lv4:100%` | 全程匹配现有 `casual` 私服立绘（零新增美术负担）；与折川皐月的社交恐惧型害羞严格区分 |
| **`surgery`（手术操作）** | **48** | `48` | 已完成外科基础轮转、懂常规入路与解剖，尚不足以独立主刀（低于明日香当前手术能力 66） |
| **`diagnostics`（诊断评估）** | **65** | `65` | 前院管床、术前评估与术后次日引流复核功底扎实 |
| **`teamwork`（团队配合）** | **72** | `72` | 六维最高项；守纪律、配合认真，发现安全风险敢于主动出声通报 |
| **`patient_care`（患者照护）** | **68** | `68` | 重视围术期观察与患者安全底线 |
| **`instrument_handling`（器械与暴露）** | **56** | `56` | 具备二助拉钩与术后手绘复盘积累，尚需在一助位继续打磨持续稳定性 |
| **`calmness`（临场镇定）** | **45** | `45` | 当前核心短板；受既往参与术后迟发出血抢救经历影响，高压下偶有短暂停顿，留足成长空间 |

---

### 1.2 手术编队、术中配合、操作不符纠正（`limited` 熟练度必需）与首次助手 CG 文案速览

| 槽位路径／功能语义 | 中文正文（`zh_CN`） | 英文译文（`en`） | 适用范围与立绘建议 |
| :--- | :--- | :--- | :--- |
| **`team_dialogue.assignment`**<br>*(编队选中回应 · 单字符串)* | 麻纪迅速将术前资料的页角对齐，认真抬头看向坂口：「患者的基础指标和手术入路我已经预习过了。今天助手的位置，请多指教，坂口医生。」 | Maki neatly aligns the corners of the preoperative chart and looks up earnestly at Sakaguchi. "I have reviewed the patient's baseline findings and the planned approach. I'll do my best assisting you today, Dr. Sakaguchi." | 通用编队选中（`white_coat/focused`） |
| **`team_dialogue.intraoperative`**<br>*(默认通用术中回应 · 写入主 Schema)* | 「这边的视野已经按您的要求稳住了，坂口医生。我正盯着您的操作节奏，下一步需要调整配合角度的话，请随时告诉我。」 | "I have the field steady on this side as requested, Dr. Sakaguchi. I'm following your pace closely—please let me know right away if you need me to adjust my angle for the next step." | **全术式／全阶段通用**（不预设出血、特定解剖结构或异常；`sterile/focused`） |
| **`limited` 熟练度 · 发现操作不符时的纠正回应**<br>*(映射运行时 `profile.json` 对应纠正槽位)* | 「请稍等一下，坂口医生——这一步操作好像和当前的手术步骤对不上。为安全起见，我们先停下来重新确认一下再继续，可以吗？」 | "Please hold on a moment, Dr. Sakaguchi—that action doesn't seem to match the current step of the procedure. To be safe, could we pause and double-check our step before continuing?" | **`surgery_proficiency="limited"` 专用纠正槽**（全术式／全阶段通用；礼貌克制但不含糊退缩；`sterile/worried` 或 `sterile/focused`） |
| **`intraoperative` 情境专用候选**<br>*(保留备用 · 不覆盖通用槽)* | 「牵开角度已经稳住了，坂口医生。深面这一层的筋膜间隙比预想的要薄一点，边缘有细小渗血，需要先确认止血再往下分吗？」 | "I have the retraction angle steady, Dr. Sakaguchi. The fascial plane down here looks slightly thinner than expected, with minor oozing along the edge—shall we secure hemostasis before dissecting further?" | **情境专用保留候选**（适用于软组织分层／渗血确认情境；`sterile/focused`） |
| **`first_assignment_cg.title`** | 第一助手的确认 | First Assistant Ready | `assets/events/maki_first_assistant_v1/assistant_confirmation.png` |
| **`first_assignment_cg.caption`** | 无影灯下，穿戴好全套无菌手术袍的相泽麻纪隔着外科口罩认真迎上主刀的视线，确认术前准备就绪。 | Beneath the operating lights, Maki Aizawa—gowned and gloved in full sterile attire—meets the lead surgeon's gaze steadily above her mask to confirm readiness. | 同上（手术室内麻纪面向主角的主观视角） |

---

### 1.3 常驻日常闲谈（`idle_chats`：不限时版本 · 休息室固定 3 条 ＋ 天台随机 3 条）

#### A. 医护休息室（`location_id: "lounge"` ｜ 固定在场 · `white_coat` ｜ 标签：「和相泽医生聊聊近况」 / `"Chat with Dr. Aizawa"`）
- **回应 1（手绘术野笔记与拉钩复盘 · 不限时日常习惯）：**  
  - `zh_CN`：麻纪正坐在休息室圆桌边，用细头钢笔在随身笔记本上整理手绘的术野解剖简图。「啊，坂口医生。我习惯趁着休息空当，把之前跟台时记下的拉钩角度和暴露层次重新梳理一遍——比如深部结扎的时候，拉钩要是再往外侧让开五度，主刀的视野应该会更敞亮吧？等之后查房核对引流情况的时候，我也会再对照印证一下的。」  
  - `en`：Maki sits at the round table in the lounge, organizing hand-drawn surgical field sketches in her pocket notebook with a fine-tipped pen. "Ah, Dr. Sakaguchi. Whenever I have a spare moment, I like to go back over the retractor angles and exposure layers from previous cases—for instance, angling five degrees further laterally during deep ligation should give the lead surgeon a clearer view, right? I always cross-check my notes against the drain findings on subsequent rounds too."
- **回应 2（前院文书流水线 vs 星见实操带教 · 无时段限定）：**  
  - `zh_CN`：麻纪把一摞整理整齐的术后观察表收进文件夹，端起温茶轻轻舒了一口气。「以前在原来的大医院，平时大部分时间我都只是坐在电脑前，机械地抄写十几床的常规病程。来到星见以后，前辈们真的愿意在台边告诉我每一钳为什么要那样下……虽然每次刷手前心跳还是有点快，但这种真正作为外科医生在学习的感觉，真的很踏实。」  
  - `en`：Maki tucks a neatly stacked set of postoperative charts into her folder and takes a quiet sip of warm tea. "Back at my old hospital, I spent most of my days just sitting at a terminal, mechanically typing up routine progress notes for a dozen beds. Here at Hoshimi, my seniors actually explain why each clamp goes where it does right at the table... My heart still races a little before scrubbing in, but finally learning as a real surgeon feels deeply reassuring."
- **回应 3（研读解剖变异与主动预警准备）：**  
  - `zh_CN`：麻纪合上手边的《开放手术局部解剖图谱》，自然地扶了一下深色方框眼镜。「坂口医生也来休息吗？我刚在对照两套不同入路的血管变异分支。总觉得光是背熟正常走行还不够，要是哪天在台上遇到不典型的分支，至少得做到第一时间认出来、及时向主刀报告才行。」  
  - `en`：Maki closes the Atlas of Open Surgical Anatomy beside her and briefly adjusts her dark-framed glasses. "Taking a break too, Dr. Sakaguchi? I was just comparing vascular anatomical variants across two different approaches. Memorizing standard textbook anatomy alone doesn't feel like enough—if an atypical branch ever shows up in the field, I want to be able to recognize it right away and report it to the lead surgeon."

#### B. 医院天台（`location_id: "rooftop"` ｜ 随机遇见 · `white_coat` ｜ 标签：「在天台和相泽医生吹风」 / `"Chat with Dr. Aizawa on the rooftop"`）
- **回应 1（吹风平复手指紧绷 · 无时段限定）：**  
  - `zh_CN`：麻纪站在天台栏杆旁，迎着微风慢慢做了一次深呼吸，随后低头看了看自己摊开的双手。「坂口医生。每次跟完需要长时间保持牵引的手术，我的手指偶尔还是会因为绷得太久有一点点发僵……所以我喜欢趁空当上来吹两分钟风、把呼吸放慢下来，之后再去病房换药或者做检查，手就稳多了。」  
  - `en`：Standing by the rooftop railing, Maki takes a slow, deep breath against the breeze before looking down at her open palms. "Dr. Sakaguchi. Whenever I finish a case that requires holding retraction for a long stretch, my fingers still get a little stiff from the tension... That's why I like coming up here for a couple of minutes to catch the breeze and slow my breathing—my hands feel much steadier for ward dressings and exams afterward."
- **回应 2（对星见“热闹社团表象＋上台绝对专业”的感慨）：**  
  - `zh_CN`：麻纪望着楼下中庭，脸上带着一丝忍俊不禁的温和笑意。「刚来报到的时候，看大家在休息室里热热闹闹地开玩笑，我还担心自己这么拘谨会不会融不进去。结果一进手术间，不管是哪位医生还是年轻护士，眼神一下子就全变了……星见真是一所不可思议的医院呢。」  
  - `en`：Maki looks down toward the courtyard with a gentle, faintly amused smile. "When I first reported for duty and saw everyone joking so livelily in the lounge, I worried someone as reserved as me might not fit in. Yet the moment we step into the operating room, every doctor and young nurse switches into complete focus... Hoshimi really is a remarkable hospital."
- **回应 3（脚踏实地的进阶心态 · 无时段限定）：**  
  - `zh_CN`：天台的风吹起麻纪双肩前的低束长发，她将吹乱的发丝轻轻别好，目光清亮而认真。「以前总觉得『独当一面』是很遥远又吓人的词。不过最近跟在坂口医生和各位前辈身边看久了，我也慢慢明白——不用急着一步登天，先把眼前每一台助手的视野和止血配合做到九十分，路自然就走稳了。」  
  - `en`：The rooftop breeze stirs the low twin ties of Maki's hair over her shoulders; she tucks a loose strand neatly back, her gaze clear and earnest. "'Standing on one's own' used to sound so distant and intimidating to me. Watching you and the other senior surgeons up close lately, though, I've come to realize there's no need to rush—if I can bring my exposure and hemostasis support as an assistant up to solid marks one case at a time, the path forward will steady itself."

---

### 1.4 【V1.3 新增】周日约会（Sunday Date）地点偏好与四类双语台词

> **对齐规范**：严格遵循 `HOSHIMI_SUNDAY_DATE_CHARACTER_VENUE_PREFERENCES.md` 的四类五句结构（接受 ×1、拒绝 ×1、普通满意 ×1、特别满意·地点一 ×1、特别满意·地点二 ×1）。  
> - **开放条件与接受率提案**：完成独立 Lv0 入职事件正式相识 ＋ `Familiarity >= 10`（未达标时点选仅播放拒绝台词、不消耗周日行动）；建议基础接受率：`Lv0: 60% → Lv2: 80% → Lv3: 92% → Lv4: 100%`（最终以全局接受率表核对为准）。  
> - **首选双全年偏好组合**：**大型书店** ＋ **植物园温室**（同步附赠 **红叶古寺〔秋〕** 季节限定备选句，若工程希望与折川皐月的双地点完全错开，可直接启用红叶古寺替换植物园温室）。  
> - **声线区分**：完全区别于折川皐月的“恐男低头型害羞”，聚焦麻纪“年轻外科医的职业认真小反差 ＋ 从带教上下级紧绷感中自然松弛下来”的特质；全程直接匹配已就绪的 `casual` 私服立绘组。

| 响应类别／偏好地点 | 中文台词（`zh_CN`） | 英文译文（`en`） | 推荐立绘键 |
| :--- | :--- | :--- | :---: |
| **接受约会**<br>*(Accepted)* | 「周日吗？那天我没有排班……如果是和坂口医生一起出去走走的话，我很乐意。时间定好了请随时告诉我。」 | "Sunday? I'm off duty that day... If it's going out for a walk with you, Dr. Sakaguchi, I'd really like that. Please let me know once you've decided on a time." | `casual/neutral`（或邀约时 `white_coat/smile`） |
| **拒绝约会**<br>*(Rejected)* | 「真不好意思，坂口医生，这个周日我已经定下别的安排了……下次如果方便的话，还能再约我吗？」 | "I'm really sorry, Dr. Sakaguchi—I already have other plans lined up for this Sunday... Would you mind asking me again another time?" | `casual/worried`（或邀约时 `white_coat/worried`） |
| **约会满意**<br>*(Satisfied · 其余常规地点)* | 「今天好像一次都没有聊到排班和病历呢。出门前我还担心在医院外面不知道该和您聊什么，结果不知不觉就彻底放松下来了……谢谢您今天约我出来，坂口医生。」 | "I don't think we talked about duty rosters or patient charts even once today. Before heading out, I worried I wouldn't know what to say to you outside the hospital, yet I ended up relaxing completely before I knew it... Thank you for inviting me out today, Dr. Sakaguchi." | `casual/neutral` |
| **特别满意 · 地点一：大型书店**〔全年〕<br>*(Special Satisfied 1)* | 「明明说好今天出来放松的，结果路过文具架和医学专柜的时候，还是没忍住挑了两本画图用的方格笔记本……不过，能和坂口医生一起安安静静逛书店，真的比我一个人查资料开心多了。」 | "Even though we agreed today was for relaxing, I still couldn't resist picking up two grid notebooks for sketching when we passed the stationery aisle and the medical section... Still, browsing a bookstore quietly with you is so much nicer than looking up references on my own." | `casual/neutral` |
| **特别满意 · 地点二：植物园温室**〔全年 · 默认首选〕<br>*(Special Satisfied 2)* | 「温室里暖融融的，连平时在手术室冷气里绷惯了的手指都觉得舒展开了。刚才那株热带植物叶片的脉络走向好精致……能和您这样并肩慢慢看，感觉整个人都松了一口气。」 | "It's so warm inside the conservatory—even my fingers, so used to tensing up in the chilly operating room, feel completely relaxed now. The vein patterns on those tropical leaves earlier were so intricate... Walking side by side and taking our time like this really let me breathe easy." | `casual/neutral` |
| **【可选替换】特别满意 · 红叶古寺〔秋〕**<br>*(Seasonal Swap Candidate)* | 「古寺石阶上的红叶真安静啊……平时在医院里总忍不住把神经绷得紧紧的，像这样听着风声和坂口医生并肩走一会儿，心里觉得特别踏实。」 | "The autumn leaves along the temple stone steps are so peaceful... At the hospital I'm always winding my nerves up tight without meaning to, so walking quietly beside you and listening to the wind like this makes me feel truly grounded." | `casual/neutral` |

---

## 二、 更新后的医生档案草案（`profile_draft.json` V1.3 · 可解析 JSON）

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
  "surgery_proficiency_and_team_dialogue": {
    "surgery_proficiency": "limited",
    "assignment": {
      "zh_CN": "麻纪迅速将术前资料的页角对齐，认真抬头看向坂口：「患者的基础指标和手术入路我已经预习过了。今天助手的位置，请多指教，坂口医生。」",
      "en": "Maki neatly aligns the corners of the preoperative chart and looks up earnestly at Sakaguchi. \"I have reviewed the patient's baseline findings and the planned approach. I'll do my best assisting you today, Dr. Sakaguchi.\""
    },
    "intraoperative": {
      "zh_CN": "「这边的视野已经按您的要求稳住了，坂口医生。我正盯着您的操作节奏，下一步需要调整配合角度的话，请随时告诉我。」",
      "en": "\"I have the field steady on this side as requested, Dr. Sakaguchi. I'm following your pace closely—please let me know right away if you need me to adjust my angle for the next step.\""
    },
    "mismatch_correction_limited": {
      "zh_CN": "「请稍等一下，坂口医生——这一步操作好像和当前的手术步骤对不上。为安全起见，我们先停下来重新确认一下再继续，可以吗？」",
      "en": "\"Please hold on a moment, Dr. Sakaguchi—that action doesn't seem to match the current step of the procedure. To be safe, could we pause and double-check our step before continuing?\"",
      "mapping_note": "对应 limited 手术熟练度接入校验要求的『发现操作不符时的纠正回应』；请 Codex 按 data/schemas/content.schema.json 真实字段名映射写入运行版 profile.json 与本地化表（建议配用 sterile/worried 或 sterile/focused 立绘）。"
    },
    "situational_intraoperative_candidate": {
      "zh_CN": "「牵开角度已经稳住了，坂口医生。深面这一层的筋膜间隙比预想的要薄一点，边缘有细小渗血，需要先确认止血再往下分吗？」",
      "en": "\"I have the retraction angle steady, Dr. Sakaguchi. The fascial plane down here looks slightly thinner than expected, with minor oozing along the edge—shall we secure hemostasis before dissecting further?\"",
      "usage_note": "保留为软组织分层／细小渗血情境专用候选；默认通用槽使用不预设特定结构与出血的通用回应。"
    }
  },
  "sunday_date_data": {
    "eligibility_rule": "完成独立 Lv0 入职事件（met=true）且 familiarity >= 10 时允许触发随机接受判定；熟悉度未满 10 时点击仅播放 rejected 台词且不消耗周日行动。",
    "proposed_base_acceptance_rate": {
      "lv0_to_lv1": 0.60,
      "lv2": 0.80,
      "lv3": 0.92,
      "lv4_plus": 1.00,
      "note": "提案基准值，工程接入时优先对齐项目统一 Sunday Date 概率曲线。"
    },
    "preferred_venues_primary": [
      "大型书店",
      "植物园温室"
    ],
    "preferred_venue_seasonal_swap_option": "红叶古寺〔秋〕（可选替换『植物园温室』，如需避免与折川皐月双地点完全重合时使用）",
    "outfit_in_date": "casual",
    "dialogue": {
      "accepted": {
        "zh_CN": "「周日吗？那天我没有排班……如果是和坂口医生一起出去走走的话，我很乐意。时间定好了请随时告诉我。」",
        "en": "\"Sunday? I'm off duty that day... If it's going out for a walk with you, Dr. Sakaguchi, I'd really like that. Please let me know once you've decided on a time.\"",
        "portrait_hint": "casual/neutral"
      },
      "rejected": {
        "zh_CN": "「真不好意思，坂口医生，这个周日我已经定下别的安排了……下次如果方便的话，还能再约我吗？」",
        "en": "\"I'm really sorry, Dr. Sakaguchi—I already have other plans lined up for this Sunday... Would you mind asking me again another time?\"",
        "portrait_hint": "casual/worried"
      },
      "satisfied": {
        "zh_CN": "「今天好像一次都没有聊到排班和病历呢。出门前我还担心在医院外面不知道该和您聊什么，结果不知不觉就彻底放松下来了……谢谢您今天约我出来，坂口医生。」",
        "en": "\"I don't think we talked about duty rosters or patient charts even once today. Before heading out, I worried I wouldn't know what to say to you outside the hospital, yet I ended up relaxing completely before I knew it... Thank you for inviting me out today, Dr. Sakaguchi.\"",
        "portrait_hint": "casual/neutral"
      },
      "special_satisfied_venues": {
        "大型书店": {
          "season": "all_year",
          "zh_CN": "「明明说好今天出来放松的，结果路过文具架和医学专柜的时候，还是没忍住挑了两本画图用的方格笔记本……不过，能和坂口医生一起安安静静逛书店，真的比我一个人查资料开心多了。」",
          "en": "\"Even though we agreed today was for relaxing, I still couldn't resist picking up two grid notebooks for sketching when we passed the stationery aisle and the medical section... Still, browsing a bookstore quietly with you is so much nicer than looking up references on my own.\"",
          "portrait_hint": "casual/neutral"
        },
        "植物园温室": {
          "season": "all_year",
          "zh_CN": "「温室里暖融融的，连平时在手术室冷气里绷惯了的手指都觉得舒展开了。刚才那株热带植物叶片的脉络走向好精致……能和您这样并肩慢慢看，感觉整个人都松了一口气。」",
          "en": "\"It's so warm inside the conservatory—even my fingers, so used to tensing up in the chilly operating room, feel completely relaxed now. The vein patterns on those tropical leaves earlier were so intricate... Walking side by side and taking our time like this really let me breathe easy.\"",
          "portrait_hint": "casual/neutral"
        }
      },
      "optional_seasonal_swap_venue": {
        "红叶古寺〔秋〕": {
          "season": "autumn",
          "zh_CN": "「古寺石阶上的红叶真安静啊……平时在医院里总忍不住把神经绷得紧紧的，像这样听着风声和坂口医生并肩走一会儿，心里觉得特别踏实。」",
          "en": "\"The autumn leaves along the temple stone steps are so peaceful... At the hospital I'm always winding my nerves up tight without meaning to, so walking quietly beside you and listening to the wind like this makes me feel truly grounded.\"",
          "portrait_hint": "casual/neutral"
        }
      }
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
    "未完成独立 Lv0 入职事件前，不开放院内常驻在场、手术助手编组与周日约会名单可见性。",
    "完成 Lv0 入职后沿用现有普通及高级手术助手编组规则，初期不授予独立主刀资格。"
  ]
}
```

---

## 三、 角色台词与元信息交付包（严格兼容 `dialogue_delivery.schema.json` · 可解析 JSON）

> **Schema 校验说明**：由于随附的 `dialogue_delivery.schema.json` 顶层与 `team_dialogue` 均设有 `"additionalProperties": false`，为确保下方 JSON 100% 通过作者交付 Schema 校验而不报错，`limited` 熟练度纠正回应与 V1.3 新增的 `sunday_date_data`（周日约会地点偏好及全套双语台词）均已结构化写入上方 **第二节 `profile_draft.json`**，并在下方 `author_notes` 完整备案，供 Codex 映射至工程实际 `profile.json` 与周日约会配置表。

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
      "完成本事件后，开放休息室固定在场与天台随机遇见（均着白大褂）、开放周日约会名单可见性（需满足 Familiarity >= 10 方可进入随机接受判定），并可参加普通和高级手术的助手编组；初期仍不开放独立主刀资格。"
    ],
    "open_questions": [
      "独立入职事件《排班表上的名字》按当前指示暂留空数组，待后续提供或确认分场要求后再补写正文。",
      "中文 UI 说话人标签（speaker_labels.doc_maki.zh_CN）最终采用『相澤麻紀』还是『相泽麻纪』可由工程统一对齐。"
    ]
  },
  "asset_requests": [],
  "author_notes": [
    "【V1.3 新增 · 周日约会 Sunday Date 配置与双语台词】首选特别偏好地点为『大型书店』＋『植物园温室』（双全年可用；另提供『红叶古寺〔秋〕』季节备选句），完整 1+1+1+2 中英双语台词、接受率提案（Lv0:60%→Lv2:80%→Lv3:92%→Lv4:100%）与 casual 立绘映射见本文第 1.4 节与 profile_draft.json 的 sunday_date_data 字段。",
    "【V1.2 新增 · limited 熟练度操作不符纠正回应】zh_CN: 「请稍等一下，坂口医生——这一步操作好像和当前的手术步骤对不上。为安全起见，我们先停下来重新确认一下再继续，可以吗？」 | en: \"Please hold on a moment, Dr. Sakaguchi—that action doesn't seem to match the current step of the procedure. To be safe, could we pause and double-check our step before continuing?\"",
    "攻略定位已确认：相泽麻纪为可攻略角色（Lv0–Lv5 剧情待制作），初始 affection=0、familiarity=0、level=0、route='colleague'（表示初始同事状态，非不可攻略）。",
    "手术资格已确认：Lv0 完成后可参与普通和高级手术助手编组（无专属禁令），初期不开放独立主刀；surgery_proficiency='limited'。",
    "常驻配置已确认：Lv0 完成后开放 lounge 固定在场与 rooftop 随机遇见，两处均使用 white_coat 立绘。"
  ]
}
```

---

## 四、 Revision Log

### V1.2 → V1.3（补齐周日约会 Sunday Date 地点偏好与全套双语台词）
1. **锁定周日约会地点偏好与触发门槛**：
   - 首选双全年特别偏好地点设为 **大型书店**（呼应手绘术野笔记与挑方格本的职业小反差）＋ **植物园温室**（温暖环境舒展手术室久握拉钩的紧绷手指、观察叶脉走向的理科生温柔感），并额外附赠 **红叶古寺〔秋〕** 季节限定特别满意台词作为可选替换方案；
   - 对齐 `HOSHIMI_SUNDAY_DATE_CHARACTER_VENUE_PREFERENCES.md` 通用规则：完成独立 Lv0 入职事件正式相识且 `Familiarity >= 10` 后可尝试周日约会，附基础接受率提案（`60% / 80% / 92% / 100%`）。
2. **补齐 1+1+1+2 全套中英双语约会台词与 `casual` 立绘映射**：
   - 完整编写 `accepted`（接受）、`rejected`（拒绝）、`satisfied`（常规满意）及两处专属 `special_satisfied`（特别满意）中英双语文本，全程直接复用 `ready_assets.json` 已就绪的 `casual/neutral` 与 `casual/worried` 立绘，并与折川皐月的社交恐惧型台词作出鲜明性格区分。

### V1.1 → V1.2（前序修订归档）
1. 新增 `limited` 手术熟练度要求的「发现操作不符时的纠正回应」（中英双语，全术式／全阶段通用）。

### V1.0 → V1.1（前序修订归档）
1. 明确可攻略定位（`romanceable: true`）与初始关系值（`affection=0, familiarity=0, level=0, route="colleague"`）；确认普通及高级手术助手编组资格；锁定休息室固定与天台随机在场；补齐通用术中回应、不限时闲谈及英文档案文本。
