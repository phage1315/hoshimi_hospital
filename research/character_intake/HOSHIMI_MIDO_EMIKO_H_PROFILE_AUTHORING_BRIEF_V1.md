# 《星见医院 / Hoshimi Hospital》御堂江美子（`doc_emiko`）H Profile 双语台词写作委托书（V1.0）

> **用途说明**：请根据下方锁定的角色设定、场景契约、4×9 偏好矩阵与 UI 格式规范，为**御堂江美子（28岁，外科部医长）**撰写全套 H Profile 互动台词（中文原稿＋英文译稿），并严格按文末给定的 **JSON 结构**输出，以便工程端直接一键灌入 `data/staff/doc_emiko/{h_profile_v1,h_flow_v1,h_context_v1}.json`。

---

## 一、 角色身份、关系阶段与口吻铁律

1. **角色档案**：
   - **姓名**：御堂 江美子（Emiko Mido，`actor_id: "doc_emiko"`），**28 岁**（明确成年女性医护），星见医院外科部医长、外科主任有力候选人。
   - **外观**：银紫色长发（手术室刷手服态拢在脑后）、冷冽灰紫色眼眸，身材修长曼妙，气质高冷强势。
   - **性格与说话风格**：冷静锋利、自尊极强、习惯掌控全局；但在认可并接纳同科外科医生**坂口隆司**（Ryuji Sakaguchi，玩家主角）后，对自己的身体快感坦诚而敏锐——**羞耻时会嘴硬、咬唇压抑声音，动情时既骄傲又火热，绝不变成撒娇卖萌、软弱依附的小女人**。
2. **称呼规则（严禁写错）**：
   - 平时、嘴硬或轻声喘息时称呼男主：**「坂口」**（英文 `"Sakaguchi"`）。
   - 偶尔带成年人促狭／反讽调侃时可称：**「坂口医生」**（英文 `"Dr. Sakaguchi"`）。
   - **禁用称呼**：严禁叫“隆司君／哥哥／主人／老公”等不符合她强势医长人设的甜腻或卑微称呼。
3. **跨模式复用边界（极其重要）**：
   - 本套 H Profile 会**同时用于两处**：
     1. **Relationship Lv4《御堂江美子的秘密》第六幕**：两人在二号手术室的**首次**手术台亲密（H 结束后自动切回 Lv4 剧本专属的 6.2 事后长对话，不播放本表的 `aftercare` 两句）；
     2. **Lv4 解锁后的日常下班 Free H**：两人白天用“术后复盘”暗号约好、下班后锁上二号手术室门重温亲密（会播放 `location_entry` 与本表的 `aftercare` 两句）。
   - 因此：**前戏触摸池（`tier_fallback` / `zone_tier` / `combo`）、`excitement_max`、`entry_style`、`scene.start/middle/finish` 与 `finish.responses` 中，请不要写死“今天是第一次做”或“已经做过很多次”的时间词**，保持无论首次还是日常重温都自然成立的当下张力！

---

## 二、 物理空间与核心心理反差（台词灵魂）

1. **唯一锁定场景与物件**：
   - **星见医院·四楼二号手术室（Operating Room No. 2）**，门外走廊无人（或已借口“单独复盘解剖细节”支开旁人），感应内门已落锁；顶部的强光无影灯已关，只亮着四周偏冷的嵌入式灯带；**两人实际使用房间中央窄长、微凉的手术台**完成前戏与正戏。
2. **必须贯穿台词的两大核心兴奋点**：
   - **① 手术室禁忌感与羞耻刺激**：
     这里是她平日对全科要求最严苛、容不得半点失误的无菌战场；可此刻她却衣衫凌乱地坐在冰凉的手术台边，和门外安静的医院走廊只隔着一扇感应门。**“我竟然在自己管理的手术室、在这张手术台上做这种事……太羞耻、太不像话了，可身体却因此兴奋得发抖”**的心理拉扯要鲜明体现在台词里。
   - **② 外科第一主刀 vs 同科男同事的掌控权反转**：
     白天站在二号手术室主刀位上发号施令、气场压迫全场的顶尖外科医长，如今在同一间手术室里，却被白天和自己并肩配台的**同科同事坂口隆司**亲手抚弄、吻乱呼吸、甚至在窄长的手术台上被他夺走主导权。**“明明白天还是听我口令配台的同事，关上门却敢这样对我……偏偏我还受不了他这双手”**的反差感是她最独特的色气来源。

---

## 三、 已定稿的 4×9 交互偏好矩阵（供撰写对应反应时对齐情绪）

引擎共有 4 种动作（`caress` 轻抚、`kiss` 亲吻、`lick` 舔舐、`light_bite` 轻咬）× 9 个部位（`lips` 嘴唇、`cheeks` 脸颊、`neck` 颈部、`breasts` 胸部、`nipples` 乳尖、`navel` 肚脐、`torso_other` 腰躯、`genitals` 私密处、`thighs` 大腿），御堂的实装档位如下：

- **`low`（兴奋度 +2，默认立绘表情 `annoyed` 微恼／嘴硬嫌弃）**：
  - 默认部位：`navel`（肚脐）
  - 特定覆盖：`lick:cheeks`（舔脸颊）、`lick:navel`（舔肚脐）、`light_bite:cheeks`（咬脸颊）、`light_bite:lips`（咬嘴唇）、`light_bite:genitals`（轻咬私密处——嫌对方没分寸乱来）
- **`mild`（兴奋度 +6，默认立绘表情 `pleased` 克制受用／微赧）**：
  - 默认部位：`cheeks`（脸颊）、`torso_other`（腰背躯干），以及未单独覆盖的普通 `light_bite`
- **`strong`（兴奋度 +12，默认立绘表情 `flustered` 呼吸急促／羞耻动摇）**：
  - 默认部位：`neck`（颈侧）、`nipples`（乳尖）、`genitals`（私密处）、`thighs`（大腿内侧）
  - 特定覆盖：`caress:thighs`、`kiss:breasts`、`light_bite:nipples`、`caress:torso_other`
- **`favorite`（兴奋度 +18，默认立绘表情 `delighted` 破防沉沦／诚实索求；满 100 切 `peak`）**：
  - 默认部位：`lips`（嘴唇）、`breasts`（胸部——呼应她术后敏感带）
  - 特定覆盖：`kiss:lips`（深吻）、`kiss:neck`（亲吻滚烫颈侧）、`light_bite:neck`（轻咬颈侧）、`caress:breasts`（揉按胸部）、`caress:genitals`（腿间抚弄）、`lick:nipples`（舔舐乳尖）

---

## 四、 硬性文本格式与长度规范（工程导入必读）

1. **纯台词字符串**：每一条只写御堂江美子**说出口的话／喘息声**，**不要加外层中文引号 `「」`**（英文也不要加外层双引号 `""`），**不要加 `御堂江美子：` 前缀**，**不要混入第三人称动作旁白**（因为 UI 会自动挂上御堂的名字框和对应表情头像）。
   - 正确示例：`……别闹了，坂口。这里可是二号手术室……你拿哄小姑娘那套试探谁呢。`
   - 错误示例：`御堂江美子瞪了他一眼：「……别闹了，坂口。」`
2. **UI 字数上限**：底部反应框为单栏紧凑显示，中文每句控制在 **12～42 字**以内（1～2 个短句最佳），英文每句控制在 **6～26 词**以内，避免超框截断。
3. **已实装可保留或一并润色的字段**：
   - 白天预约回应与 4 句 `location_entry.operating_room` 已有初稿（见下方模板注释），你可以直接保留或按统一文风微调。
4. **句数硬性契约（引擎校验器强约束，不可增减条数）**：
   - `tier_fallback`：`low` / `mild` / `strong` / `favorite` 各 **4 句**（共 16 句，必填）
   - `zone_tier`：**9 组**（每个部位对应其默认档位，每组 **2 句**，共 18 句，推荐填齐以丰富部位反馈）
   - `combo`：**15 组**（对应上方 15 个 `combo_overrides`，每组 **2 句**，共 30 句，推荐填齐以体现特色动作反差）
   - `scene.start`：**恰好 3 句**；`scene.middle`：**恰好 3 句**；`scene.finish`：**恰好 3 句**（`finish` 为 1.3.4 协议保留池，写满 3 句事后余韵短句即可）
   - `excitement_max_line`：**1 句**（兴奋度刚满 100 时，坐在手术台边又羞又烫地催促坂口进入正戏）
   - `entry_style`：`openings.gentle` **1 句**、`openings.intense` **1 句**、`midpoints.gentle` **1 句**、`midpoints.intense` **1 句**（共 4 句；`gentle` 体现窄长手术台上十指紧扣、卸下防备的相拥，`intense` 体现一贯掌控手术室的第一主刀在手术台上被同事彻底夺走节奏的失控快感）
   - `finish_responses`：**恰好 4 句**（点击最终高潮按钮时随机抽 1 句播放的短促高潮回应）
   - `free_h_aftercare`：**恰好 2 句**（仅日常 Free H 结束时按顺序播放的二号手术室事后余韵，体现两人关门独享秘密的松弛与默契）
   - `en`：**与上方中文每一键、每一数组下标严格 1:1 对应的自然文学英文译文**（不含任何中文字符）。

---

## 五、 交付输出格式模板（请直接输出完整合法的 JSON 代码块）

请输出一个完整的 JSON 对象，结构如下（键名请保持一字不差）：

```json
{
  "actor_id": "doc_emiko",
  "version": "1.0",
  "booking_response": {
    "zh_CN": "……今晚二号手术间后面没有排台。下班以后过来，陪我『复盘』。",
    "en": "...Room Two has no late cases scheduled tonight. Come by after hours and 'debrief' with me."
  },
  "profile_dialogue_zh": {
    "location_entry": {
      "operating_room": [
        "……内门已经落锁了。平时我站在二号间发号施令，下班后却留你在这里……别磨蹭，过来。",
        "……无影灯关掉以后，这间手术室比白天安静多了。门外没人了，坂口。",
        "明明白天还是并肩配台的同事，一关上二号间的感应门就变成这种关系……真是乱来。",
        "……别用打量术野的眼神看我。既然叫你留下做『术后复盘』，时间就归你了。"
      ]
    },
    "tier_fallback": {
      "low": ["...", "...", "...", "..."],
      "mild": ["...", "...", "...", "..."],
      "strong": ["...", "...", "...", "..."],
      "favorite": ["...", "...", "...", "..."]
    },
    "zone_tier": {
      "lips:favorite": ["...", "..."],
      "cheeks:mild": ["...", "..."],
      "neck:strong": ["...", "..."],
      "breasts:favorite": ["...", "..."],
      "nipples:strong": ["...", "..."],
      "navel:low": ["...", "..."],
      "torso_other:mild": ["...", "..."],
      "genitals:strong": ["...", "..."],
      "thighs:strong": ["...", "..."]
    },
    "combo": {
      "kiss:lips": ["...", "..."],
      "kiss:neck": ["...", "..."],
      "light_bite:neck": ["...", "..."],
      "caress:breasts": ["...", "..."],
      "caress:genitals": ["...", "..."],
      "lick:nipples": ["...", "..."],
      "caress:thighs": ["...", "..."],
      "kiss:breasts": ["...", "..."],
      "light_bite:nipples": ["...", "..."],
      "caress:torso_other": ["...", "..."],
      "lick:cheeks": ["...", "..."],
      "lick:navel": ["...", "..."],
      "light_bite:cheeks": ["...", "..."],
      "light_bite:lips": ["...", "..."],
      "light_bite:genitals": ["...", "..."]
    },
    "scene": {
      "start": ["...", "...", "..."],
      "middle": ["...", "...", "..."],
      "finish": ["...", "...", "..."]
    }
  },
  "flow_dialogue_zh": {
    "excitement_max_line": "...",
    "openings": {
      "gentle": "...",
      "intense": "..."
    },
    "midpoints": {
      "gentle": "...",
      "intense": "..."
    },
    "finish_responses": ["...", "...", "...", "..."],
    "free_h_aftercare": ["...", "..."]
  },
  "context_dialogue_en": {
    "operating_room_entry": [
      "...The inner lock is set. By day I stand in Room Two giving every order, yet after hours I'm keeping you inside... Don't dawdle. Come here.",
      "...Once the surgical lamps are switched off, this theater is far quieter than during the day. No one's outside anymore, Sakaguchi.",
      "Standing across the table as colleagues all day, only to end up like this the moment Room Two's door slides shut... utterly reckless.",
      "...Don't look at me like you're sizing up an operative field. Since I asked you to stay for a 'post-op debrief,' this time is yours."
    ],
    "base_en": {
      "reaction.tier_fallback:low": ["...", "...", "...", "..."],
      "reaction.tier_fallback:mild": ["...", "...", "...", "..."],
      "reaction.tier_fallback:strong": ["...", "...", "...", "..."],
      "reaction.tier_fallback:favorite": ["...", "...", "...", "..."],
      "reaction.zone_tier:lips|favorite": ["...", "..."],
      "reaction.zone_tier:cheeks|mild": ["...", "..."],
      "reaction.zone_tier:neck|strong": ["...", "..."],
      "reaction.zone_tier:breasts|favorite": ["...", "..."],
      "reaction.zone_tier:nipples|strong": ["...", "..."],
      "reaction.zone_tier:navel|low": ["...", "..."],
      "reaction.zone_tier:torso_other|mild": ["...", "..."],
      "reaction.zone_tier:genitals|strong": ["...", "..."],
      "reaction.zone_tier:thighs|strong": ["...", "..."],
      "reaction.combo:kiss|lips": ["...", "..."],
      "reaction.combo:kiss|neck": ["...", "..."],
      "reaction.combo:light_bite|neck": ["...", "..."],
      "reaction.combo:caress|breasts": ["...", "..."],
      "reaction.combo:caress|genitals": ["...", "..."],
      "reaction.combo:lick|nipples": ["...", "..."],
      "reaction.combo:caress|thighs": ["...", "..."],
      "reaction.combo:kiss|breasts": ["...", "..."],
      "reaction.combo:light_bite|nipples": ["...", "..."],
      "reaction.combo:caress|torso_other": ["...", "..."],
      "reaction.combo:lick|cheeks": ["...", "..."],
      "reaction.combo:lick|navel": ["...", "..."],
      "reaction.combo:light_bite|cheeks": ["...", "..."],
      "reaction.combo:light_bite|lips": ["...", "..."],
      "reaction.combo:light_bite|genitals": ["...", "..."],
      "scene.start": ["...", "...", "..."],
      "scene.middle": ["...", "...", "..."],
      "scene.finish": ["...", "...", "..."],
      "max_prompt": ["..."],
      "style.opening.gentle": ["..."],
      "style.opening.intense": ["..."],
      "style.midpoint.gentle": ["..."],
      "style.midpoint.intense": ["..."],
      "finish.responses": ["...", "...", "...", "..."],
      "aftercare": ["...", "..."]
    }
  }
}
```
