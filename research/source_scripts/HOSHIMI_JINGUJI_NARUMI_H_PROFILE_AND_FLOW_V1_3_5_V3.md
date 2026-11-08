# Hoshimi Hospital — 神宮寺成美（`doc_aoi`）H Profile ＆ Phase 2 Flow ＆ 36组合人工语义 QA 档案（V3 终审定稿版）

**版本：** Profile 文件版本 `V1.3.5`（`schema_version: "1.3"`）/ Phase 2 Flow `patch_version: "1.3.4"`  
**状态：** V3 终审定稿版（完成动作对齐、回退池无状态化、泛躯干热区解耦及成美专属狡黠声线优化）  
**适用角色：** 神宮寺成美（`doc_aoi`，27岁，外科医生）  
**常驻自由亲密地点（工程交接配置）：** 仅开放 `hotel`（精品酒店；此项为自由 H 入口解锁配置说明，不侵入 Profile JSON 顶层字段）  

---

## 一、 V2 → V3 审稿定点修订总览

1. **【P1-1 修复】修正 `dialogue.combo["lick:nipples"]` 的动作错配（`ACTION_ALIGNMENT`）**：
   - 将第二条候选句中的「别吸得那么重」修正为纯舔舐动作下的强烈感官反馈：**「哈啊……っ、隆司……舌尖再那样打转……真的受不了了……！」**，不假定未执行的吸吮动作。
2. **【P1-2 修复】消除两处 `zone_tier` 共享回退池的时间与深度假设（`STATE_ALIGNMENT` & `POOL_REACHABILITY`）**：
   - **`zone_tier["nipples:strong"]`**：将第一条中的「一开始就欺负最敏感的尖端」修改为**「啊……っ、嗯！专挑最敏感的尖端欺负，真不客气呢……」**，去除仅适用于开场的阶段假设。
   - **`zone_tier["genitals:favorite"]`**：将第一条中暗示深入结合的「最深处都被你弄得乱七八糟了」修改为**「啊……っ、嗯啊！隆司……那里被你弄得一塌糊涂了……！」**，确保任何可达动作回退至此池时均自然成立。
3. **【P2 修复】拓宽 `torso_other`（泛躯干区）的部位描述适应面（`ZONE_ALIGNMENT`）**：
   - 移除了 `zone_tier["torso_other:*"]` 与 `combo["*:torso_other"]` 中限定「肩头」「肩背」「腰侧」等狭窄位置的词汇，改为适用于整个躯干（腰、背、肩、肋侧）的通用触感与温度反馈，兼容任意多边形热区覆盖范围。
4. **【P2 优化】去套话化并强化成美在 `low` / `mild` 档位的狡黠与掌控感（`VOICE`）**：
   - 清理了原先重复出现的「坏心眼」「太犯规」「拿你没办法」「太温柔了」等泛化套话。
   - 在 `low` 与 `mild` 档位融入成美特有的机敏调侃与欲擒故纵的掌控欲（如点破对方在比耐性、试探呼吸、慢悠悠逗她会遭她反客为主），而在 `strong` 与 `favorite` 档位保持纯粹、短促的即时感官失守反应。

---

## 二、 `doc_aoi.h_profile.V1_3_5.json`（严格兼容 Schema `1.3`）

```json
{
  "schema_version": "1.3",
  "actor_id": "doc_aoi",
  "adult_confirmed": true,
  "assets": {
    "body_map_image": "res://assets/h/doc_aoi/body_map.png",
    "body_map_regions": "res://data/h/doc_aoi/h_bodymap.json",
    "portrait_expressions": {
      "neutral": "res://assets/h/doc_aoi/portrait_neutral.png",
      "annoyed": "res://assets/h/doc_aoi/portrait_annoyed.png",
      "pleased": "res://assets/h/doc_aoi/portrait_pleased.png",
      "flustered": "res://assets/h/doc_aoi/portrait_flustered.png",
      "delighted": "res://assets/h/doc_aoi/portrait_delighted.png",
      "peak": "res://assets/h/doc_aoi/portrait_peak.png"
    },
    "scene_cg": "res://assets/h/doc_aoi/scene_cg.png",
    "aftercare_cg": "res://assets/h/doc_aoi/aftercare_cg.png"
  },
  "preferences": {
    "zone_defaults": {
      "lips": "favorite",
      "cheeks": "mild",
      "neck": "strong",
      "breasts": "strong",
      "nipples": "favorite",
      "navel": "low",
      "torso_other": "mild",
      "genitals": "favorite",
      "thighs": "strong"
    },
    "action_overrides": {},
    "combo_overrides": {
      "caress:lips": "mild",
      "lick:lips": "strong",
      "light_bite:lips": "strong",
      "lick:cheeks": "low",
      "light_bite:cheeks": "low",
      "caress:neck": "mild",
      "light_bite:neck": "favorite",
      "lick:breasts": "mild",
      "caress:nipples": "strong",
      "kiss:nipples": "strong",
      "caress:navel": "mild",
      "kiss:navel": "mild",
      "lick:torso_other": "low",
      "kiss:genitals": "strong",
      "light_bite:genitals": "low",
      "light_bite:thighs": "favorite"
    }
  },
  "dialogue": {
    "tier_fallback": {
      "low": [
        "呵……这种程度，可还不够让我乱了呼吸哦。",
        "唔……稍微有点痒呢，换个方式试试？",
        "是在故意试探我的耐性吗，隆司？",
        "再这么慢吞吞地兜圈子，我可要反过来捉弄你了哦。"
      ],
      "mild": [
        "嗯……挺舒服的，你可以再放开一点哦。",
        "呼……你的温度传过来了，让人怪安心的。",
        "呵……这么有耐心，是想先把我哄放松吗？",
        "唔……节奏不错，不过我知道你不止这点本事吧？"
      ],
      "strong": [
        "嗯……っ、哈啊……就是那里，呼吸都要乱掉了……",
        "啊……っ、真狡猾，专挑我没法保持冷静的地方……",
        "唔……っ、身体越来越热了……隆司，再近一点……",
        "哈啊……っ、别停……刚才那一下，很有感觉呢……"
      ],
      "favorite": [
        "啊……っ、嗯……！隆司，再多一点……别停下来……",
        "哈啊……っ、连指尖都在发麻了……真是栽在你手里了……",
        "嗯啊……っ、不行……那里太敏感了，快要受不了了……！",
        "啊……っ、哈啊……再这样下去，我可没法装从容了……！"
      ]
    },
    "zone_tier": {
      "lips:mild": [
        "嗯……只是这样碰碰嘴唇，可不够打发我哦。",
        "唔……唇瓣痒痒的，不打算更进一步吗？"
      ],
      "lips:strong": [
        "唔……っ、嘴唇又麻又烫……真会勾人呢，隆司。",
        "哈啊……っ、连呼吸都被你缠住了……"
      ],
      "lips:favorite": [
        "唔嗯……っ、哈啊……还要，隆司……别离开我的唇……",
        "嗯……っ、怎么都觉得不够……再近一点……"
      ],
      "cheeks:low": [
        "呵……在脸颊上恶作剧，你今晚几岁呀？",
        "想看我失态的话，逗这儿可没什么用哦。"
      ],
      "cheeks:mild": [
        "嗯……脸颊很烫对不对？还不是因为你。",
        "呵……这样碰我的脸，是想让我先心软吗？"
      ],
      "neck:mild": [
        "嗯……脖子和锁骨那边，稍微有点敏感呢。",
        "呼……呼吸一下子就乱了半拍。"
      ],
      "neck:strong": [
        "嗯……っ、哈啊……颈侧烫得让人浑身发软……",
        "啊……っ、离耳朵太近了……连喘息声都藏不住了……"
      ],
      "neck:favorite": [
        "啊……っ、嗯……！偏偏挑脖颈最敏感的地方……真被你拿捏住了……",
        "哈啊……っ、隆司……弄在那里，我真的没法设防了……"
      ],
      "breasts:mild": [
        "嗯……故意只在外围打转，是在跟我比耐性吗？",
        "呼……你是在故意吊我的胃口吧，隆司？"
      ],
      "breasts:strong": [
        "嗯……っ、哈啊……胸口满满涨涨的，心跳都藏不住了……",
        "啊……っ、被你这样对待，呼吸都变得好沉……"
      ],
      "nipples:strong": [
        "啊……っ、嗯！专挑最敏感的尖端欺负，真不客气呢……",
        "唔……っ、哈啊……那里已经彻底起反应了……"
      ],
      "nipples:favorite": [
        "啊……っ、嗯啊！不行……尖端又热又麻，脑子都要空白了……！",
        "哈啊……っ、隆司……别停……那里快要受不了了……！"
      ],
      "navel:low": [
        "噗……肚脐周围很怕痒的，别逗那里呀。",
        "唔……哈哈，隆司，腰腹那边真的怕痒啦。"
      ],
      "navel:mild": [
        "嗯……小腹都跟着微微绷紧了呢。",
        "呼……再往下一点，才是你真正想去的地方吧？"
      ],
      "torso_other:low": [
        "嗯……这儿有点怕痒呢，换个地方试试？",
        "呵……在这边慢吞吞地晃，是在找我的弱点吗？"
      ],
      "torso_other:mild": [
        "嗯……贴上来的温度，让人怪安心的。",
        "呼……紧绷的身体，一下子就放松下来了呢。"
      ],
      "genitals:low": [
        "嘶……っ！等一下，隆司，那里太娇嫩了，可经不起这样折腾……",
        "唔……那里不行的，换个温柔一点的方式疼我嘛。"
      ],
      "genitals:strong": [
        "啊……っ、哈啊……最私密的地方……太羞人了……",
        "嗯啊……っ、那里被你弄得……腰完全使不上力气了……"
      ],
      "genitals:favorite": [
        "啊……っ、嗯啊！隆司……那里被你弄得一塌糊涂了……！",
        "哈啊……っ、不行……那里已经彻底湿透了……快给我……！"
      ],
      "thighs:strong": [
        "嗯……っ、大腿内侧的皮肤很薄的……腿都快合不拢了……",
        "哈啊……っ、离那个地方只有一寸了……你真会折磨人……"
      ],
      "thighs:favorite": [
        "啊……っ、唔！大腿根突然传来一阵麻意，整条脊椎都软了……！",
        "嗯啊……っ、隆司……连腿根都被你弄得直发抖了……"
      ]
    },
    "action_tier": {},
    "combo": {
      "caress:lips": [
        "嗯……光用手指碰一下，就想打发我了？",
        "唔……指尖温温的……不直接吻上来吗？"
      ],
      "kiss:lips": [
        "唔嗯……っ、哈啊……再深一点，隆司……",
        "嗯……っ、别退开……再让我尝一会儿……"
      ],
      "lick:lips": [
        "唔……っ、这样一点点舔过去……真会吊人胃口……",
        "哈啊……嘴唇都麻了……快吻进来呀……"
      ],
      "light_bite:lips": [
        "嗯……っ、嘶……连嘴唇都要咬住不放吗……",
        "呼……っ、咬得这么突然，是想堵住我调侃你的话吗……"
      ],
      "caress:cheeks": [
        "嗯……手心好热……脸都要被你捂烫了。",
        "呵……用这种眼神摸我的脸，是想让我先心软吗？"
      ],
      "kiss:cheeks": [
        "嗯……只是亲脸颊？……今晚这么守规矩呀。",
        "呵……故意亲在旁边，是想让我自己偏过头找你吗？"
      ],
      "lick:cheeks": [
        "哎呀……好痒，脸都要被你弄湿了。",
        "呵……拿这种恶作剧试探我，我可不会轻易上当哦。"
      ],
      "light_bite:cheeks": [
        "唔……咬脸颊做什么呀，真是的。",
        "呵……想看我失态的话，咬这儿可没什么用哦。"
      ],
      "caress:neck": [
        "嗯……手指顺着脖子滑下去……有点酥麻呢。",
        "呼……手指停在锁骨那边，是在观察我的呼吸吗？"
      ],
      "kiss:neck": [
        "嗯……っ、哈啊……连耳后都发烫了……",
        "啊……っ、被你这样一路亲下来，力气都要没了……"
      ],
      "lick:neck": [
        "啊……っ、湿热热的……起了一身战栗呢……",
        "嗯……っ、别在颈窝那边停着……太痒太麻了……"
      ],
      "light_bite:neck": [
        "啊……っ、嗯……！被你咬住那里，真的没法嘴硬了……",
        "哈啊……っ、隆司……连后背都跟着一阵发麻……"
      ],
      "caress:breasts": [
        "嗯……っ、手心烫得惊人……呼吸都慢不下来了……",
        "哈啊……っ、再稍微用点力气，也没关系哦……"
      ],
      "kiss:breasts": [
        "唔……っ、连胸口都贴着你的热气……",
        "啊……っ、隆司……心跳有多快，被你发现了呢……"
      ],
      "lick:breasts": [
        "嗯……故意只在外围打转，是在跟我比耐性吗？",
        "呼……痒得人心慌……别再绕圈子了，隆司。"
      ],
      "light_bite:breasts": [
        "啊……っ、又酸又麻的……你还真是不客气……",
        "嗯……っ、要真留下印子，今晚可饶不了你……"
      ],
      "caress:nipples": [
        "啊……っ、别用指尖那样捻……身体在抖了……",
        "唔……っ、哈啊……那里已经彻底硬起来了……"
      ],
      "kiss:nipples": [
        "嗯啊……っ、嘴唇一贴上来，胸口就一阵发麻……",
        "哈啊……っ、越是这样轻柔地碰，身体反而越绷紧了……"
      ],
      "lick:nipples": [
        "啊……っ、嗯啊！不行……被那样舔，整个人都软了……！",
        "哈啊……っ、隆司……舌尖再那样打转……真的受不了了……！"
      ],
      "light_bite:nipples": [
        "啊……っ、唔！齿尖磨过去的瞬间，脑子都空白了……！",
        "嗯啊……っ、又疼又麻……隆司，我真要被你逼疯了……！"
      ],
      "caress:navel": [
        "嗯……小腹被你摸得热热的……",
        "呼……再往下一点，才是你真正想去的地方吧？"
      ],
      "kiss:navel": [
        "唔……呼吸喷在小腹上，肚子都跟着绷紧了呢。",
        "呵……慢条斯理地往下亲，你是算准了我会心急吗？"
      ],
      "lick:navel": [
        "噗……那里很怕痒的，别用舌尖逗我呀。",
        "唔……哈哈，隆司，真的有点痒啦。"
      ],
      "light_bite:navel": [
        "哎呀……咬肚子除了痒可没别的效果哦。",
        "嘶……你再这么慢悠悠地逗我，一会儿我可要反客为主了。"
      ],
      "caress:torso_other": [
        "嗯……手掌贴着皮肤滑过去，还挺舒服的。",
        "呵……这么耐心地顺着摸，是想先把我哄放松吗？"
      ],
      "kiss:torso_other": [
        "嗯……温温热热的吻，让人心里发软呢。",
        "呵……连这种地方都亲得这么认真，你还真是细心。"
      ],
      "lick:torso_other": [
        "嗯……舌尖滑过去太痒了，换个地方嘛。",
        "呵……在无关紧要的地方兜圈子，可不像你的作风哦。"
      ],
      "light_bite:torso_other": [
        "唔……牙齿轻轻磕上来，稍微有点刺麻呢。",
        "呼……倒是不疼，就是冷不防被你带乱了呼吸。"
      ],
      "caress:genitals": [
        "啊……っ、嗯啊！手指太厉害了……隆司，抱紧我……！",
        "哈啊……っ、别那样反复摩挲……腰已经彻底软了……！"
      ],
      "kiss:genitals": [
        "啊……っ、哈啊……热气全扑在那里……太羞人了……",
        "嗯啊……っ、被你亲在那种地方，连脚趾都蜷起来了……"
      ],
      "lick:genitals": [
        "啊……っ、嗯啊！舌头太深了……那里一直在发颤……！",
        "哈啊……っ、不行……连声音都压不住了……隆司……！"
      ],
      "light_bite:genitals": [
        "嘶……っ！等一下，那里太娇嫩了，可经不起咬哦……",
        "唔……别用牙齿捉弄那里，换个温柔点的方式嘛。"
      ],
      "caress:thighs": [
        "嗯……っ、大腿内侧被你摸得直发烫……腿都快合不拢了……",
        "哈啊……っ、就差一寸了……是在等我自己开口求你吗？"
      ],
      "kiss:thighs": [
        "唔……っ、顺着腿根一路往上亲，心都要提到嗓子眼了……",
        "啊……っ、别光在旁边徘徊了，隆司……"
      ],
      "lick:thighs": [
        "嗯啊……っ、大腿根被舔得半边身子都酥了……",
        "哈啊……っ、隆司……腿一直在抖呢……"
      ],
      "light_bite:thighs": [
        "啊……っ、唔！咬在大腿内侧……整条脊椎都麻了……！",
        "嗯啊……っ、隆司……偏要在腿根最隐秘的地方留印子吗……"
      ]
    },
    "location_entry": {
      "hotel": [
        "门锁好了……今晚剩下的时间，你打算怎么陪我，隆司？",
        "一进房间眼神就变了呢。过来吧，不用跟我客气。"
      ],
      "home": [
        "难得来我房间……要是表现得太规矩，我可不依哦。",
        "茶还没泡呢……不过看你的样子，大概也没心思喝茶吧？"
      ],
      "ward": [
        "嘘……外面的走廊随时有人经过，可别让我发出太大的声音哦。",
        "既然偷偷把门锁上了……那就快一点过来吧，隆司。"
      ],
      "operating_room": [
        "把这里当成私会的地方，要是被明日香发现了可没法交代呢……",
        "明明是最熟悉的手术室，只剩我们两个人的时候，气氛还真是奇妙呢。"
      ]
    },
    "scene": {
      "start": [
        "嗯……っ、哈啊……进来了……被你一下子填满，脑子都转不动了……",
        "啊……っ、好烫……隆司，抱紧我……今晚不用管什么分寸了……",
        "唔嗯……っ、贴得这么深，连彼此的心跳都撞在一起了呢……"
      ],
      "middle": [
        "啊……っ、嗯啊！就是那里……隆司，再深一点……节奏全被你打乱了……！",
        "哈啊……っ、不行……最里面一阵阵发麻……看着我，隆司，只准看着我……！",
        "唔啊……っ、呼吸完全跟不上了……你认真起来，真让人招架不住……！"
      ],
      "finish": [
        "啊……っ、哈啊——！到极限了……隆司，一起……！",
        "嗯啊……っ、唔——！脑子里一片空白了……抱紧我……！",
        "哈啊……っ、不行了……再抱紧我一点，隆司……"
      ]
    }
  }
}
```

---

## 三、 `doc_aoi.h_flow.V1_3_4.json`（严格兼容 Patch `1.3.4`）

```json
{
  "patch_version": "1.3.4",
  "actor_id": "doc_aoi",
  "profile_schema_version": "1.3",
  "scope": "aoi_h_phase2_manual_finish_minimal_patch",
  "excitement_max": {
    "trigger": {
      "excitement_gte": 100
    },
    "line": "哈啊……っ、隆司，已经够久了……别再吊着我了，快进来，好吗？",
    "show_only_once_per_h_session": true,
    "can_continue_phase1_interactions": true,
    "no_auto_advance": true,
    "choices": [
      {
        "id": "gentle",
        "label": "温柔进入"
      },
      {
        "id": "intense",
        "label": "粗暴进入"
      }
    ]
  },
  "entry_style": {
    "scope": "current_h_session_only",
    "affects": [
      "phase2_opening_line",
      "phase2_midpoint_line"
    ],
    "does_not_affect": [
      "excitement",
      "preferences",
      "h_result",
      "relationship_result",
      "aftercare_result",
      "scene_cg",
      "surgery_system"
    ],
    "both_choices_require_mutual_consent": true,
    "openings": {
      "gentle": "嗯……っ、哈啊……慢慢贴合进来了……你的温度，清晰得让人发抖呢……",
      "intense": "啊……っ、唔！一下子就顶到最深处了……！哈啊……原来你也忍到极限了吗……"
    },
    "midpoints": {
      "gentle": "啊……っ、嗯……明明动作这么慢，却每一下都磨在最敏感的地方……再贴紧我一点，隆司……",
      "intense": "啊……っ、嗯啊！太快了，隆司……！连喘气的空隙都不给我留了吗……！"
    }
  },
  "phase2": {
    "fixed_cg_asset_ref": "assets.scene_cg",
    "no_position_selector": true,
    "no_new_meter": true,
    "no_failure_or_rating": true,
    "no_dialogue_choices_inside_phase2": true,
    "playback": [
      {
        "kind": "style_line",
        "ref": "entry_style.openings"
      },
      {
        "kind": "profile_scene_pool",
        "ref": "dialogue.scene.start",
        "draw": 2,
        "without_replacement": true
      },
      {
        "kind": "style_line",
        "ref": "entry_style.midpoints"
      },
      {
        "kind": "profile_scene_pool",
        "ref": "dialogue.scene.middle",
        "draw": 2,
        "without_replacement": true
      },
      {
        "kind": "wait_for_player_finish",
        "action_id": "h_finish",
        "do_not_auto_complete": true
      }
    ],
    "completion": {
      "trigger": "after_h_finish_reaction_acknowledged",
      "set_result": "h_event_completed",
      "value": true,
      "handoff": "external_vn_aftercare",
      "one_shot": true,
      "no_other_exit_from_normal_phase2_playback": true
    },
    "manual_finish": {
      "button_action_id": "h_finish",
      "button_label_source": "h_finish_button_labels.V1_3_4.json",
      "button_label_selection": "uniform_random_1_of_5_at_phase2_enter",
      "button_label_stable_for_session": true,
      "button_shown_only_after_initial_playback": true,
      "button_shown_until_clicked": true,
      "on_click": {
        "one_shot": true,
        "disable_button_immediately": true,
        "prevent_other_phase2_lines_after_click": true,
        "choose_one_response_uniformly": true,
        "response_pool": [
          "啊……っ、哈啊——！感觉到你在最深处全给我了……隆司，抱紧我……！",
          "嗯啊……っ、唔——！一起到了……连指尖都使不上力气了……！",
          "啊……っ、太烫了……最里面被你满满地占有了……哈啊……隆司……！",
          "唔啊……っ、哈啊——！眼前白成一片了……今晚真是彻底败给你了呢……"
        ],
        "selection_independent_of_button_label": true,
        "play_selected_response_once": true,
        "wait_until_response_advanced": true,
        "then": "phase2.completion"
      },
      "legacy_scene_finish_pool": {
        "source": "doc_aoi.h_profile.dialogue.scene.finish",
        "behavior": "preserve_in_profile_but_do_not_play_in_V1_3_4",
        "reason": "prevent old auto-finish / extra lines from appearing before or after the new single final response"
      }
    }
  },
  "external_vn_aftercare": {
    "owner": "normal_vn_event_flow",
    "scene_image_ref": "assets.aftercare_cg",
    "free_h": {
      "on_entry_line_sequence": [
        "哈……先别急着动……让我这样靠着你再缓一会儿。",
        "刚才还想逗你两句的，现在连动手指的力气都没了……再抱紧我一点，隆司。"
      ]
    },
    "relationship_milestone": {
      "behavior": "return_to_authored_event_aftercare",
      "no_auto_injection_of_generic_free_h_lines": true,
      "do_not_modify_lv4_event_script": true
    }
  }
}
```

---

## 四、 36 组动作×热区可达性与人工语义 QA 审查报告（V3）

### 1. 总体 QA 状态
- **总体结论**：`PASS`（Schema 契约、36 组专属池与底层共享回退池均通过逐句人工审读）
- **36 组动作×热区覆盖率**：`36 / 36`（100%）
- **实际可达候选句总数**：`72` 条（36 组均命中 `dialogue.combo`；同时全部 `21` 组 `zone_tier` 候选池共 `42` 句及 `4` 组 `tier_fallback` 候选池共 `16` 句均已逐句完成跨动作、无时间假设及泛躯干位置兼容性验证）
- **待修问题计数**：`P0 = 0`，`P1 = 0`，`P2 = 0`

### 2. 36 组真实调用展开与逐句人工审读表

| # | Action | Zone | 解析 Tier | 实际命中源 (`source_key`) | 候选句 1 & 候选句 2（完整文本） | 人工语义 QA 判定 |
| :-: | :--- | :--- | :---: | :--- | :--- | :---: |
| 01 | `caress` | `lips` | `mild` | `dialogue.combo["caress:lips"]` | ① 嗯……光用手指碰一下，就想打发我了？<br>② 唔……指尖温温的……不直接吻上来吗？ | **PASS**（短促感官，贴合指触嘴唇与主动引导） |
| 02 | `kiss` | `lips` | `favorite` | `dialogue.combo["kiss:lips"]` | ① 唔嗯……っ、哈啊……再深一点，隆司……<br>② 嗯……っ、别退开……再让我尝一会儿…… | **PASS**（深吻高张力，无多余修饰） |
| 03 | `lick` | `lips` | `strong` | `dialogue.combo["lick:lips"]` | ① 唔……っ、这样一点点舔过去……真会吊人胃口……<br>② 哈啊……嘴唇都麻了……快吻进来呀…… | **PASS**（舔唇即时反应自然） |
| 04 | `light_bite` | `lips` | `strong` | `dialogue.combo["light_bite:lips"]` | ① 嗯……っ、嘶……连嘴唇都要咬住不放吗……<br>② 呼……っ、咬得这么突然，是想堵住我调侃你的话吗…… | **PASS**（去除“坏心眼”套话，体现成美机敏反问） |
| 05 | `caress` | `cheeks` | `mild` | `dialogue.combo["caress:cheeks"]` | ① 嗯……手心好热……脸都要被你捂烫了。<br>② 呵……用这种眼神摸我的脸，是想让我先心软吗？ | **PASS**（去除“拿你没办法”套话，保留成熟洞察） |
| 06 | `kiss` | `cheeks` | `mild` | `dialogue.combo["kiss:cheeks"]` | ① 嗯……只是亲脸颊？……今晚这么守规矩呀。<br>② 呵……故意亲在旁边，是想让我自己偏过头找你吗？ | **PASS**（展现成美欲擒故纵的主动感） |
| 07 | `lick` | `cheeks` | `low` | `dialogue.combo["lick:cheeks"]` | ① 哎呀……好痒，脸都要被你弄湿了。<br>② 呵……拿这种恶作剧试探我，我可不会轻易上当哦。 | **PASS**（低偏好机敏调侃，贴合人设） |
| 08 | `light_bite` | `cheeks` | `low` | `dialogue.combo["light_bite:cheeks"]` | ① 唔……咬脸颊做什么呀，真是的。<br>② 呵……想看我失态的话，咬这儿可没什么用哦。 | **PASS**（低偏好从容掌控感） |
| 09 | `caress` | `neck` | `mild` | `dialogue.combo["caress:neck"]` | ① 嗯……手指顺着脖子滑下去……有点酥麻呢。<br>② 呼……手指停在锁骨那边，是在观察我的呼吸吗？ | **PASS**（不带医生术语，保留敏锐反问） |
| 10 | `kiss` | `neck` | `strong` | `dialogue.combo["kiss:neck"]` | ① 嗯……っ、哈啊……连耳后都发烫了……<br>② 啊……っ、被你这样一路亲下来，力气都要没了…… | **PASS**（亲吻颈侧高感官反馈） |
| 11 | `lick` | `neck` | `strong` | `dialogue.combo["lick:neck"]` | ① 啊……っ、湿热热的……起了一身战栗呢……<br>② 嗯……っ、别在颈窝那边停着……太痒太麻了…… | **PASS**（舔舐颈窝感官直接） |
| 12 | `light_bite` | `neck` | `favorite` | `dialogue.combo["light_bite:neck"]` | ① 啊……っ、嗯……！被你咬住那里，真的没法嘴硬了……<br>② 哈啊……っ、隆司……连后背都跟着一阵发麻…… | **PASS**（最高偏好短促失守） |
| 13 | `caress` | `breasts` | `strong` | `dialogue.combo["caress:breasts"]` | ① 嗯……っ、手心烫得惊人……呼吸都慢不下来了……<br>② 哈啊……っ、再稍微用点力气，也没关系哦…… | **PASS**（高偏好感官与主动邀约） |
| 14 | `kiss` | `breasts` | `strong` | `dialogue.combo["kiss:breasts"]` | ① 唔……っ、连胸口都贴着你的热气……<br>② 啊……っ、隆司……心跳有多快，被你发现了呢…… | **PASS**（短促亲昵） |
| 15 | `lick` | `breasts` | `mild` | `dialogue.combo["lick:breasts"]` | ① 嗯……故意只在外围打转，是在跟我比耐性吗？<br>② 呼……痒得人心慌……别再绕圈子了，隆司。 | **PASS**（去除“坏心眼”，突出成美式调侃） |
| 16 | `light_bite` | `breasts` | `strong` | `dialogue.combo["light_bite:breasts"]` | ① 啊……っ、又酸又麻的……你还真是不客气……<br>② 嗯……っ、要真留下印子，今晚可饶不了你…… | **PASS**（成熟反撩语气自然） |
| 17 | `caress` | `nipples` | `strong` | `dialogue.combo["caress:nipples"]` | ① 啊……っ、别用指尖那样捻……身体在抖了……<br>② 唔……っ、哈啊……那里已经彻底硬起来了…… | **PASS**（指尖触碰高感官反馈） |
| 18 | `kiss` | `nipples` | `strong` | `dialogue.combo["kiss:nipples"]` | ① 嗯啊……っ、嘴唇一贴上来，胸口就一阵发麻……<br>② 哈啊……っ、越是这样轻柔地碰，身体反而越绷紧了…… | **PASS**（去除“太温柔了”套话，感官更具体） |
| 19 | `lick` | `nipples` | `favorite` | `dialogue.combo["lick:nipples"]` | ① 啊……っ、嗯啊！不行……被那样舔，整个人都软了……！<br>② 哈啊……っ、隆司……舌尖再那样打转……真的受不了了……！ | **PASS**（P1-1 已修复：严格对应舔舐动作，无吸吮假设） |
| 20 | `light_bite` | `nipples` | `favorite` | `dialogue.combo["light_bite:nipples"]` | ① 啊……っ、唔！齿尖磨过去的瞬间，脑子都空白了……！<br>② 嗯啊……っ、又疼又麻……隆司，我真要被你逼疯了……！ | **PASS**（去除“太犯规”套话，感官冲击更强） |
| 21 | `caress` | `navel` | `mild` | `dialogue.combo["caress:navel"]` | ① 嗯……小腹被你摸得热热的……<br>② 呼……再往下一点，才是你真正想去的地方吧？ | **PASS**（简洁且具成美引导感） |
| 22 | `kiss` | `navel` | `mild` | `dialogue.combo["kiss:navel"]` | ① 唔……呼吸喷在小腹上，肚子都跟着绷紧了呢。<br>② 呵……慢条斯理地往下亲，你是算准了我会心急吗？ | **PASS**（体现成美特有的敏锐调侃） |
| 23 | `lick` | `navel` | `low` | `dialogue.combo["lick:navel"]` | ① 噗……那里很怕痒的，别用舌尖逗我呀。<br>② 唔……哈哈，隆司，真的有点痒啦。 | **PASS**（低偏好怕痒反应自然） |
| 24 | `light_bite` | `navel` | `low` | `dialogue.combo["light_bite:navel"]` | ① 哎呀……咬肚子除了痒可没别的效果哦。<br>② 嘶……你再这么慢悠悠地逗我，一会儿我可要反客为主了。 | **PASS**（展现成美的掌控欲与反客为主警告） |
| 25 | `caress` | `torso_other` | `mild` | `dialogue.combo["caress:torso_other"]` | ① 嗯……手掌贴着皮肤滑过去，还挺舒服的。<br>② 呵……这么耐心地顺着摸，是想先把我哄放松吗？ | **PASS**（P2 已修复：不限定肩背，兼顾成美声线） |
| 26 | `kiss` | `torso_other` | `mild` | `dialogue.combo["kiss:torso_other"]` | ① 嗯……温温热热的吻，让人心里发软呢。<br>② 呵……连这种地方都亲得这么认真，你还真是细心。 | **PASS**（P2 已修复：不限定肩背，适配泛躯干热区） |
| 27 | `lick` | `torso_other` | `low` | `dialogue.combo["lick:torso_other"]` | ① 嗯……舌尖滑过去太痒了，换个地方嘛。<br>② 呵……在无关紧要的地方兜圈子，可不像你的作风哦。 | **PASS**（P2 已修复：不限定腰肩，增加成美式激将） |
| 28 | `light_bite` | `torso_other` | `mild` | `dialogue.combo["light_bite:torso_other"]` | ① 唔……牙齿轻轻磕上来，稍微有点刺麻呢。<br>② 呼……倒是不疼，就是冷不防被你带乱了呼吸。 | **PASS**（P2 已修复：不限定肩头，适配泛躯干热区） |
| 29 | `caress` | `genitals` | `favorite` | `dialogue.combo["caress:genitals"]` | ① 啊……っ、嗯啊！手指太厉害了……隆司，抱紧我……！<br>② 哈啊……っ、别那样反复摩挲……腰已经彻底软了……！ | **PASS**（短促直接，高感官反馈） |
| 30 | `kiss` | `genitals` | `strong` | `dialogue.combo["kiss:genitals"]` | ① 啊……っ、哈啊……热气全扑在那里……太羞人了……<br>② 嗯啊……っ、被你亲在那种地方，连脚趾都蜷起来了…… | **PASS**（感官细节准确） |
| 31 | `lick` | `genitals` | `favorite` | `dialogue.combo["lick:genitals"]` | ① 啊……っ、嗯啊！舌头太深了……那里一直在发颤……！<br>② 哈啊……っ、不行……连声音都压不住了……隆司……！ | **PASS**（最高偏好喘息节奏自然） |
| 32 | `light_bite` | `genitals` | `low` | `dialogue.combo["light_bite:genitals"]` | ① 嘶……っ！等一下，那里太娇嫩了，可经不起咬哦……<br>② 唔……别用牙齿捉弄那里，换个温柔点的方式嘛。 | **PASS**（核心区轻度制止引导） |
| 33 | `caress` | `thighs` | `strong` | `dialogue.combo["caress:thighs"]` | ① 嗯……っ、大腿内侧被你摸得直发烫……腿都快合不拢了……<br>② 哈啊……っ、就差一寸了……是在等我自己开口求你吗？ | **PASS**（抚摸大腿内侧高张力） |
| 34 | `kiss` | `thighs` | `strong` | `dialogue.combo["kiss:thighs"]` | ① 唔……っ、顺着腿根一路往上亲，心都要提到嗓子眼了……<br>② 啊……っ、别光在旁边徘徊了，隆司…… | **PASS**（亲吻大腿内侧期待感） |
| 35 | `lick` | `thighs` | `strong` | `dialogue.combo["lick:thighs"]` | ① 嗯啊……っ、大腿根被舔得半边身子都酥了……<br>② 哈啊……っ、隆司……腿一直在抖呢…… | **PASS**（短促感官反馈） |
| 36 | `light_bite` | `thighs` | `favorite` | `dialogue.combo["light_bite:thighs"]` | ① 啊……っ、唔！咬在大腿内侧……整条脊椎都麻了……！<br>② 嗯啊……っ、隆司……偏要在腿根最隐秘的地方留印子吗…… | **PASS**（去除“坏心眼”，保留私密留痕张力） |

---

## 五、 工程交接与 Codex 运行时核对清单（`NEEDS_CODEX_RUNTIME_CHECK`）

1. **常驻自由 H 地点配置（非 Profile JSON 内置字段）**：
   - 成美在完成个人 Lv4《下班以后》后开放自由 H，常驻地点仅启用 **`hotel`**（精品酒店）。该配置在游戏的自由 H 调度／地点解锁表中设置，不向 `doc_aoi.h_profile.json` 注入非标顶层字段。
2. **首次 Lv4 事件与自由 H Aftercare 分流**：
   - **Lv4 首次酒店亲密**：若在固定 VN 剧本内完成，直接走《下班以后》Scene 2 事后温存对白；若通过 `launch_h_system(partner=doc_aoi, context=aoi_lv4_first_h)` 调用 H Runner，则由 `doc_aoi.h_flow.V1_3_4.json` 中的 `external_vn_aftercare.relationship_milestone` 规则直接交还给 Lv4 剧本专属 Aftercare（`no_auto_injection_of_generic_free_h_lines: true`）。
   - **日常自由 H（Free H）**：在点击全局随机 `h_finish` 按钮并播放 1 句 `manual_finish.on_click.response_pool` 后，由 `phase2.completion` 交接给 `external_vn_aftercare.free_h.on_entry_line_sequence` 播放通用事后温存台词。
3. **资源路径与热区核验（`NEEDS_CODEX_RUNTIME_CHECK`）**：
   - `assets` 下的 `res://assets/h/doc_aoi/...` 与 `res://data/h/doc_aoi/h_bodymap.json` 路径严格沿用小夜香基线命名规范，交由 Codex 在 Godot 仓库中核对实际贴图导入与多边形热区坐标绑定。
