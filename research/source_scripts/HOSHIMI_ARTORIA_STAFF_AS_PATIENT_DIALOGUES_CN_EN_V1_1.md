# 阿尔托莉雅·潘德拉贡（`doc_artoria`）Staff-as-Patient 完整双语对白包 V1.1

## V1.0 → V1.1 修订说明
1. **【P1-1｜消除世界观矛盾与 Meta 表述】**
   - `invitation_by_category.ORGAN_REMOVAL[0]`：删去「一旦切下就无法回头」，保留对重大脏器切除的分量感与郑重托付（中英同步）。
   - `interaction_overrides.hysterectomy_signature_01.responses.confirm_hysterectomy_scope`：删去「在星见的规则里」的作者视角 Meta 台词，改为对术后康复、术前约定与坂口医术的信任（中英同步）。
2. **【P1-2｜通用对白去部位化（适配乳腺、胸心、盆腔及腹部全部术式）】**
   - `reaction_lines.closure_reassure`：将「逐层关腹和缝合」改为通用的「逐层关闭切口和缝合」。
   - `reaction_lines.closure_coach`：将「配合关腹放松腹壁」改为通用的「配合缝合放松肌肉张力」（中英同步）。
   - `interaction_overrides.closure_default_01.responses.confirm_closure`：将「关腹缝合／closing the cavity」改为通用的「逐层关闭切口／closing the incision layer by layer」。
   - `interaction_overrides.pelvic_dignity_default_01.responses.answer_pelvic_progress`：将「分离完宫旁与盆底侧韧带」改为覆盖整个 `female_pelvic` 类别的「推进到盆腔深部的关键分离步骤」（中英同步）。
   - `interaction_overrides.closure_fear_closure_01`（`prompt` 及 `confirm_closure_phase`）：移除默认每台手术都有引流管与关腔的假设，改为通用的「深层组织缝合前核查创面与止血」（中英同步）。
   - `interaction_overrides.strain_pain_default_01`（`coach_strain` 及 `push_through_strain`）：移除通用深部牵拉池中「顶着胸口」与「深部血管」的特定部位指向，改为通用的「深部牵拉坠胀感」与「深部术野显露」（中英同步）。
   - 顺带清理 `reaction_variants.skin_disinfection_awake[0]` 与 `incision_marking_none[1]` 中的「肚子／肋缘／小腹」字样，改为全术式通用的身体反应。
3. **【P1-3｜移除对杉村弘子在场的固定假定，并将 `incision_ready` 改为直接发话】**
   - `reaction_lines.incision_ready`：移除外层内心独白括号与「弘子」指名，改为清醒患者听见器械护士递送圆刀声时直接说出口的紧张反应（中英同步）。
   - `interaction_overrides.closure_default_01.prompt`：将「刚刚听见弘子开始第一遍清点」改为通用的「刚刚听见护士们开始第一遍清点」（中英同步）。

---

## 完整交付 JSON（`hoshimi_staff_patient_delivery_v1`）

```json
{
  "schema_version": "hoshimi_staff_patient_delivery_v1",
  "actor_id": "doc_artoria",
  "recommended_base_dialogue_profile": "calm_analytical_reassurance",
  "zh_CN": {
    "address_context": {
      "surgeon_name": "坂口医生"
    },
    "invitation_lines": [
      "「{procedure_name}吗……好，我答应你，坂口君。既然那天在走廊外说过要当个听话的患者，今天我就把主刀的位置彻底交给你了。」",
      "「……选了{procedure_name}啊。流程和解剖层次我都清楚，不过真正换我躺上去，大概还是会比想象中紧张吧。请多关照了，坂口君。」",
      "「好。排班表我已经替自己空出来了——关于{procedure_name}的术前说明，可不准因为我是外科副部长就偷工减料哦，坂口君。」"
    ],
    "invitation_by_category": {
      "ROUTINE": [
        "「{procedure_name}吗？平时在台上带年轻医生做过不少次，没想到今天轮到自己躺上去体验标准流程了……我会老老实实配合你的，坂口君。」"
      ],
      "MAJOR": [
        "「竟然选了{procedure_name}这样的大台……深部游离和血管保护的难度我比谁都清楚。但既然主刀是你，坂口君，我愿意把身体毫无保留地托付给你。」"
      ],
      "HYSTERECTOMY": [
        "「{procedure_name}……这可不是能轻松当作日常训练来看待的术式呢。不过，我已经深思熟虑过了——如果是坂口君执刀，我接受这份决定。」"
      ],
      "MASTECTOMY": [
        "「{procedure_name}啊……要说心里完全没有动摇是骗人的。但站在你面前的不是副部长，而是完全信任你的阿尔托莉雅。按你的判断去做吧，坂口君。」"
      ],
      "ORGAN_REMOVAL": [
        "「{procedure_name}……这是分量极重的重要脏器切除手术呢。我的身体与接下来的整台手术，就全都交到你手里了，坂口君。」"
      ]
    },
    "ward_visit_opening": [
      {
        "speaker": "narrator",
        "text": "推开单人病房的门，平日里总是身披笔挺白大褂的阿尔托莉雅已经换上了浅蓝色的住院病号服，正端正地坐在床沿，将换下的衣物叠得方方正正。"
      },
      {
        "speaker": "patient",
        "text": "「你来了，坂口君。明明这间病房我查房时走过无数回，可一旦脱下白大褂坐到病床上，连空气闻起来都变得不一样了呢。」"
      },
      {
        "speaker": "player",
        "text": "「副部长大人现在还来得及反悔哦？待会儿进了手术室，我可就真的拿你当普通患者严格要求了。」"
      },
      {
        "speaker": "patient",
        "text": "「我才不会临阵脱逃呢。从现在起没有外科副部长，只有你的患者阿尔托莉雅——请按正式流程开始术前准备吧，坂口医生。」"
      }
    ],
    "stage_prompts": {
      "graphic_preop_question": "「坂口医生，在你开始讲解之前，我想以患者身份确认三件事——今天计划的解剖游离边界在哪里、术中需要我如何配合呼吸与体位，以及术后引流管的留置方案是什么？」"
    },
    "reaction_lines": {
      "hospitalization_question": "「在患者姓名栏里看到『阿尔托莉雅·潘德拉贡』这几个字，感觉比签十份高危手术同意书还要奇妙……坂口医生，我的入院手续都核对无误了吗？」",
      "hospitalization_response": "「明白。医局和排班表的事我已经全部交接妥当了，住院期间我不会插手任何科务，专心做一名合格的患者。」",
      "procedure_mismatch": "「……请等一下，坂口医生。器械台刚才备好的包和体位要求，跟我们在病房约定的术式不一致——作为主刀，请你先把临时变更方案的医学理由向我解释清楚。」",
      "explain_plan": "「即便我熟悉外科教材上的每一个步骤，今天躺在这里的人也是我。坂口医生，请不要因为我的职务而省略细节，像对待其他患者一样把手术方案完整告诉我吧。」",
      "brief_plan": "「……很精炼的说明呢。差点就习惯性地想替你补充解剖层次的注意事项了……咳，我已经明白大致方向了，听你安排，坂口医生。」",
      "last_reassure": "「嗯，我的心跳已经平复下来了。不管是接下来的刀锋还是漫长的缝合，我都交给坂口医生和大家了。」",
      "choose_general": "「全身麻醉吗……也好，这样我就彻底没法隔着布帘偷听你们的器械声、更没法违规指挥了。等我再睁开眼睛的时候，希望第一眼就能看到你，坂口医生。」",
      "choose_epidural": "「硬膜外阻滞啊……平时我总是在别人背后穿刺置管的那个人，轮到自己清醒着感受下半身一点点变得麻木沉重，还真有些微妙的不安呢。请多关照，坂口医生。」",
      "choose_local": "「局部浸润麻醉……也就是说表皮的锐痛会被阻断，但深部筋膜的牵拉和器械触感我都会清清楚楚地感觉到对吧？……我做好心理准备了，坂口医生。」",
      "choose_none": "「……不采用任何麻醉吗？坂口医生，身为外科医生，我比谁都清楚这意味着怎样直接的创伤与痛楚……但既然这是我们共同确认的决定，我绝不会在台上退缩的。」",
      "induction_reassure": "「面罩里的氧气很温和……眼皮已经开始发沉了……坂口医生，还有大家，接下来就拜托你们了……」",
      "insist_without_anesthesia": "「不需要再追加麻药了，坂口医生。我的手指已经握紧床沿了……不管有多痛，我都会咬紧牙关忍住，请直接按计划开始吧！」",
      "assistant_stabilize_none": "「唔……！抱、抱歉，没有麻醉的情况下身体还是会本能地绷紧发抖……谢谢你按住我的肩膀，这样感觉踏实多了。」",
      "assistant_stabilize_local": "「谢谢你帮我扶稳体位……局麻下还是能感觉到台面的震动，有人在肩侧托着会更容易集中精神配合。」",
      "assistant_stabilize_epidural": "「劳烦你了……阻滞平面上来之后，腰腿完全使不上力气，连稳住重心都要靠大家帮忙，稍微有点难为情呢。」",
      "incision_ready": "「……刚才那声脆响，是器械护士把圆刀递到你手里的声音吧，坂口医生。明明平时在台上听过无数次，可感觉到刀尖悬在自己皮肤正上方的时候，心跳还是快得藏不住……请、请下刀吧。」",
      "incise_epidural": "「嗯……！没有尖锐的痛感，但刀刃划开皮肤和皮下组织的紧绷震动，还是清清楚楚地传过来了……坂口医生的起刀很稳，请继续。」",
      "incise_local": "「嘶……っ！表皮不痛，但切到深层筋膜的时候还是有一阵发酸发胀的钝痛……没、没关系，呼吸还能稳住，请继续推进吧，坂口医生。」",
      "incise_none": "「唔啊……っ！哈、哈啊……好烫、像被烧红的剑刃直接剖开一样……っ！不、不用停，坂口医生……我能撑住，别让我的防卫性肌紧张耽误你的层次……！」",
      "contact_pause": "「哈啊……哈啊……谢谢你，坂口医生。稍微停下这几秒钟让我把气喘匀，冷汗就没那么厉害了……」",
      "contact_command": "「……是！对不起，我不乱动了……我跟着你的口令慢慢呼气，请继续操作，坂口医生！」",
      "contact_continue": "「……我已经把呼吸调整好了，坂口医生。不用顾虑我，请继续往下做吧。」",
      "ongoing_narrate": "「听着你报出解剖层次的声音，哪怕看不见术野，我也能在脑海里拼出你手下的画面……很稳健的节奏，听到你这么说我就放心了。」",
      "ongoing_eye_contact": "「隔着无菌布帘看到你的眼睛……刚才攒在胸口的那点慌乱一下子就安静下来了。我没事的，坂口医生。」",
      "ongoing_silent": "「……坂口医生？台上好一会儿只有持针器和止血钳碰撞的声音……是深部游离遇到粘连了吗？如果方便的话，跟我说句话好不好……」",
      "closure_reassure": "「终于到逐层关闭切口和缝合的阶段了吗……呼……听见这句，紧绷了半天的脊背总算敢真正贴回手术台面上了。」",
      "closure_coach": "「嗯……吸气……再慢慢呼气……配合缝合放松肌肉张力的要领我还记得，只是体力有点见底了……我会乖乖跟着你的节奏的。」",
      "closure_silent": "「哈啊……眼皮好重，连手指都快没力气动了……坂口医生……还剩最后几针皮内缝合对吗……我就在这里安静等你收尾……」"
    },
    "reaction_variants": {
      "ward_enema": [
        "「术前肠道清洁的重要性我当然明白……只是平时都是我给患者开医嘱，轮到自己提起病号服侧躺下来接受灌肠，哪怕面对的是熟悉的护士，耳根还是忍不住发烫啊……」",
        "「唔……温热的液体推进来的时候，下腹那种不断膨胀的坠胀感实在让人很难维持平时的端庄……请、请让我抓着床栏再坚持五分钟，我一定严格按标准排空……」"
      ],
      "ward_enema_unnecessary": [
        "「今天的术式不涉及下消化道与盆腔深部显露，按指南确实不需要常规灌肠……咳，我纯粹是从循证医学角度赞同你的决定，绝对不是暗自松了一口气哦，坂口医生。」",
        "「省去术前灌肠了吗？既然不影响无菌视野与肠管减压，能少受一道罪，作为患者我还是坦率向你说声谢谢吧，坂口医生。」"
      ],
      "ward_skin_prep": [
        "「备皮刀贴在皮肤上沙沙移动的触感，比想象中还要痒、还要让人害羞呢……平时在台上只觉得术野干净理所当然，自己躺着才体会到患者有多不自在。」",
        "「请放心按标准范围刮干净吧。为了杜绝术后切口感染，毛发清理绝不能马虎——我闭上眼睛不看就是了，唔……」"
      ],
      "ward_skin_prep_unnecessary": [
        "「那个……坂口医生，以今天的切口路径来说，刚才备皮剃除的范围是不是稍微超出无菌规范要求的边界了……？虽、虽然听凭你处置，但也请稍微顾及一下我的体面呀。」",
        "「连那里也要一并备皮吗……？明明不是主切口经过的区域……唔，既然你坚持是为了扩大无菌备用的安全余量，那我就乖乖躺好不动了。」"
      ],
      "ward_surgical_cap": [
        "「平时进手术室前戴无纺布帽是为了握起手术刀战斗；今天把盘发全都塞进这顶蓝色患者帽里，却像是在提醒自己——接下来我只能把一切交给别人了呢。」",
        "「额前的碎发也都收进帽子里了。看着镜子里这副不施粉黛、只穿病号服和手术帽的样子，总算真切地有了『我是今天的手术患者』的实感。」"
      ],
      "operative_positioning_awake": [
        "「手术台比隔着手术袍站在旁边时感觉要硬得多、也凉得多呢……双臂外展固定在托手架上之后，就真的连半寸都没法自己挪动了啊。」",
        "「体位垫的角度很合适，腰背都有支撑。只是这样毫无防备地平躺在无影灯正下方，哪怕心里完全信任你们，呼吸还是会不自觉地变浅呢。」"
      ],
      "operative_positioning_none": [
        "「在没有任何麻醉保护的状态下直接固定四肢和躯干吗……唔，束缚带扣紧手腕的那一刻，后背的汗毛一下子全都立起来了……我会努力控制自己不在台上挣扎的。」",
        "「身体已经按你的要求摆正了，坂口医生。一想到接下来所有的切开与牵拉都要在这张台面上清醒着硬扛过去，指尖就忍不住把托手架抓紧了……」"
      ],
      "urinary_catheterization_awake": [
        "「唔……っ！留置导尿是监测术中肾灌注和防止膀胱过度充盈的必要措施，这些道理我都懂……可当着坂口医生和大家的面分开双腿插管，那种酸涩的异物感还是羞人得要命啊……」",
        "「哈啊……水囊注水固定的胀感传过来了……明明自己给别人下过无数次导尿医嘱，亲身躺在台上看着引流袋挂到床边，才明白患者需要鼓起多大的勇气……」"
      ],
      "urinary_catheterization_none": [
        "「呀……唔っ！没、没有任何麻药遮蔽的时候，导尿管滑进尿道黏膜的每一寸摩擦都清晰得可怕……！对、对不起，坂口医生，我不是故意夹紧腿的，我马上放松呼吸……」",
        "「嘶……哈啊……既敏感又带着一阵阵想排尿的酸胀刺痛……原来完全清醒着插导尿管是这种滋味……唔，引流通畅就好，请继续下一步吧……」"
      ],
      "skin_disinfection_awake": [
        "「唔……浸满碘伏的纱布球刚碰到皮肤的时候，还是冷得让我轻轻颤了一下。从切口中心一圈圈向外涂刷的手法很标准……连我自己都挑不出半点毛病呢。」",
        "「微凉的消毒液在皮肤上慢慢挥发，整个视野都被消毒水的气味包围了。每刷完一遍，离真正落刀就更近一步……我的心跳声，没吵到你们吧？」"
      ],
      "skin_disinfection_none": [
        "「啊……好凉……！没有麻药缓冲，冰凉的碘伏刷在紧绷的皮肤上，简直像是在提前预告接下来刀刃划过的轨迹一样……坂口医生，我的手心全都是汗了……」",
        "「一圈、两圈、三圈……消毒范围越涂越广，我的呼吸就跟着越来越急……明明知道这只是消毒纱布，身体却已经在本能地畏惧接下来的真刀锋了……」"
      ],
      "incision_marking_awake": [
        "「记号笔尖划过皮肤的微痒触感很清晰……从起笔到收尾的长度和走向来看，坂口医生把解剖暴露和切口美观平衡得很好呢。」",
        "「在自己的身体上被画下紫色的手术切口线……那道墨迹停留的地方，马上就要变成真正的刀口了。我闭上眼深呼吸，你随时可以铺巾开台，坂口医生。」"
      ],
      "incision_marking_none": [
        "「唔……！记号笔刚碰到皮肤的那一瞬间，我还以为手术刀已经落下来了，吓得差点屏住呼吸……原来只是划线吗……让坂口医生见笑了。」",
        "「笔尖沿着预定切口一寸寸滑过去，明明一点都不痛，可一想到下一秒沿着这条线划开的将是锋利的圆刀，全身的肌肉就忍不住一阵阵发紧……」"
      ]
    },
    "interaction_overrides": {
      "contact_pain_incision_01": {
        "prompt": "「唔……っ！坂口医生……刀刃切下去的那股灼痛比我想象中还要直接……我的呼吸是不是有点乱了？」",
        "responses": {
          "explain_contact": "「呼……哈啊……原来已经顺利切过真皮层了吗。谢谢你提醒我，坂口医生，我会把气慢慢吐出来，绝不绷紧肌肉妨碍你的层次。」",
          "brief_contact": "「……明白，既然一切按计划推进，那这点痛楚我完全可以忍受。请继续吧，坂口医生。」",
          "continue_contact": "「是……！对不起，我不分心了，手已经抓稳托手架了，请你继续往下游离吧。」"
        }
      },
      "contact_no_anesthesia_incision_01": {
        "prompt": "「啊……唔っ！哈啊、哈啊……没有任何麻药遮蔽，活生生被手术刀划开血肉的感觉……原来这么剧烈……っ！」",
        "responses": {
          "steady_unanesthetized_contact_01": "「哈啊……嗯……跟着你的声音吸气、再呼气……谢谢你放慢了运刀的速度，坂口医生……我已经抓稳床沿了，可以继续了……」",
          "continue_unanesthetized_contact_01": "「唔……っ！我明白，开台切皮最忌讳半途停顿……我咬紧牙关忍住，坂口医生，别管我的发抖，直接切到位吧……！」"
        }
      },
      "contact_no_anesthesia_incision_02": {
        "prompt": "「嘶……っ！电凝镊点在鲜活创面上的刺痛和拉钩撑开切口的感觉混在一起……坂口医生，我的冷汗是不是把头侧的垫单都弄湿了……？」",
        "responses": {
          "steady_unanesthetized_contact_02": "「哈啊……谢谢你停下这几秒让我喘口气……明明自己当主刀时觉得止血和撑开只是再普通不过的动作，躺在这里才明白需要多大的毅力去扛……」",
          "continue_unanesthetized_contact_02": "「嗯……っ！不用替我停手，坂口医生！我的背还贴在手术台上，只要你手里的刀稳，我就绝不会乱动半分！」"
        }
      },
      "contact_no_anesthesia_incision_03": {
        "prompt": "「呜……哈啊……坂口医生……深层筋膜被直接剪开的时候，整具身体都在本能地发颤……我们真的……就这样一直不用麻药做到底吗……？」",
        "responses": {
          "steady_unanesthetized_contact_03": "「……嗯，你说得对，既然开台前已经下定决心不用麻醉，现在更不能半途而废。谢谢你愿意放缓一点剥离的力道……我缓过来了，坂口医生。」",
          "continue_unanesthetized_contact_03": "「……是！刚才那句只是身体本能的软弱而已……我已经重新把呼吸稳住了，请按原定无麻醉方案继续推进吧，坂口医生！」"
        }
      },
      "contact_default_01": {
        "prompt": "「坂口医生，我已经感觉到器械贴上切口边缘的触感了……现在是已经正式进入皮下分离阶段了吗？」",
        "responses": {
          "reassure_start": "「听到你确认生命体征和切口状态都很平稳，我悬着的心就落回原处了。刚才差点又习惯性地想问出血量了呢……请继续吧。」",
          "brief_start": "「明白。听你说话的语气这么笃定，我就知道起刀非常顺利。」",
          "silent_start": "「……抱歉，说好了今天在台上做个安静听话的患者的。我闭上嘴专心配合呼吸，坂口医生。」"
        }
      },
      "contact_pain_incision_02": {
        "prompt": "「唔……拉钩往两侧牵开切口边缘的时候，深处又传来一阵酸胀的刺痛……坂口医生，现在的显露宽度够用了吗？」",
        "responses": {
          "acknowledge_second_contact": "「原来已经在固定切口牵开器了啊……呼，知道这一步是按计划必须承受的张力，忍耐起来就容易多了。谢谢你，坂口医生。」",
          "brief_second_contact": "「好……既然都在计划之内，我会继续保持躯干放松的，请往下做吧。」"
        }
      },
      "contact_fear_incision_01": {
        "prompt": "「隔着这道无菌布帘看不见你的手，只能听见止血钳清脆的咬合声……坂口医生，刚才那一下，是处理完表浅血管了吗？」",
        "responses": {
          "orient_fearful_contact": "「原来如此……听你把刚完成的步骤点清楚，脑海里未知的空白一下子就被填上了。果然躺在这张台上，最需要的就是主刀的这句话呢。」",
          "steady_fearful_contact": "「嗯……我不去胡乱猜测器械声了，只专心听坂口医生的声音、跟着你的节奏呼吸……」",
          "dismiss_fearful_contact": "「……对不起，是我又犯了外科医生的老毛病，总想搞清楚台上的每一步。我不追问了，全都交给你，坂口医生。」"
        }
      },
      "progress_fear_default_01": {
        "prompt": "「坂口医生……无影灯照在布帘上的光影好像一直没变，我已经有点分不清过去多久了……现在的进度还顺利吗？」",
        "responses": {
          "explain_progress": "「每一层都按术前预估的时间节点在走吗……太好了。躺在台面这一侧，时间感真的会比握着手术刀时漫长好几倍呢。」",
          "brief_progress": "「嗯，只要知道你还在稳步推进，我就不会胡思乱想了。辛苦你了，坂口医生。」",
          "dismiss_progress": "「……明白，主刀专注深部操作的时候确实不该被打扰。我会安静调整呼吸的，坂口医生。」"
        }
      },
      "progress_default_01": {
        "prompt": "「刚才听见更换长柄器械和温盐水纱布的声音了……坂口医生，我们现在是推进到哪个解剖阶段了？」",
        "responses": {
          "answer_progress": "「果然和我想的差不多呢。你的解剖层次向来很干净，知道已经走到这一步，我就彻底安心了。」",
          "brief_answer_progress": "「一切按计划进行就好。那我就继续乖乖当好不添乱的患者了，坂口医生。」"
        }
      },
      "progress_fear_fatigue_01": {
        "prompt": "「哈啊……保持同一个固定姿势躺了这么久，后背和肩膀都开始发僵发沉了……坂口医生，离核心步骤完成还有多远……？」",
        "responses": {
          "explain_fatigue_progress": "「已经完成一大半了吗……呼，听你把剩下的步骤清清楚楚列出来，感觉身体里又重新攒起一点力气了。谢谢你，坂口医生。」",
          "brief_fatigue_progress": "「嗯……既然还在既定轨道上，那这点疲惫不算什么。我还撑得住，坂口医生。」"
        }
      },
      "progress_fear_fatigue_02": {
        "prompt": "「呼吸好像越来越费力，连听你们交接器械的声音都有点飘忽了……坂口医生，我们现在过了最难的那道关口了吗……？」",
        "responses": {
          "mark_fatigue_milestone": "「太好了……听到你给出这么明确的阶段节点，就像在长途行军里看到了路标一样让人安心……我会坚持到最后的。」",
          "encourage_fatigue_progress": "「最关键的部分已经平安跨过去了吗……呼……听你这么说，紧绷的神经总算能稍微喘一口气了。拜托你继续收尾了，坂口医生。」"
        }
      },
      "cardiac_progress_fear_01": {
        "prompt": "「胸骨被撑开器顶开的感觉好沉重……连自己的心跳都像直接暴露在空气里一样……坂口医生，心包和血管那边一切正常吗？」",
        "responses": {
          "explain_cardiac_progress": "「呼……听你清楚报出心脏表面的显露情况和血流动力学指标，那种胸腔被打开的本能恐惧就消退多了。不愧是你，坂口医生。」",
          "brief_cardiac_progress": "「嗯……只要你的手在胸腔里还是稳的，我就把自己的每一次心跳都安心交给你。」"
        }
      },
      "cardiac_progress_default_01": {
        "prompt": "「坂口医生，刚才感觉到胸腔深处有一阵极其精细的牵引感……现在是已经进入心脏核心操作阶段了吗？」",
        "responses": {
          "answer_cardiac_progress": "「果然已经到最精密的阶段了啊。我连大气都不敢乱喘一口，一定把呼吸幅度控制到最平稳，全力配合你。」",
          "brief_cardiac_answer": "「明白。按计划推进就好，我会保持绝对安静的，坂口医生。」"
        }
      },
      "thoracic_progress_fatigue_01": {
        "prompt": "「哈啊……单侧胸腔开放的状态下，每次吸气都觉得比平时沉重好多……坂口医生，胸腔里的游离进展到哪一步了……？」",
        "responses": {
          "explain_thoracic_progress": "「原来肺门和纵隔侧的处理已经接近尾声了……知道具体的解剖进度，胸口那种透不过气的慌乱就减轻多了。谢谢你，坂口医生。」",
          "brief_thoracic_progress": "「好……既然一切顺利，我就继续配合浅慢呼吸，绝不让纵隔摆动干扰你的视野。」"
        }
      },
      "vascular_progress_deep_01": {
        "prompt": "「刚才那一下深部压迫感……是无损伤血管阻断钳夹闭主干血管了吗，坂口医生？现在的阻断计时和远端灌注还好吗？」",
        "responses": {
          "explain_vascular_milestone": "「阻断位置精准、吻合时间也在安全窗内吗……呼，明明躺在这里的是我自己，听到这么漂亮的血管外科控制还是忍不住想替你喝彩呢。」",
          "brief_vascular_milestone": "「明白，有你在盯阻断时间，我不做多余的操心了，请专心完成血管吻合吧。」"
        }
      },
      "cabg_signature_01": {
        "prompt": "「坂口医生……我能感觉到胸腔正中央有极其细微的缝线牵动……现在是正在做冠状动脉桥血管的精细吻合吗？」",
        "responses": {
          "explain_cabg_milestone": "「靶血管显露良好、桥血管吻合口血流通畅吗……？在自己跳动或受控的心脏上完成这一步，光是听你说出来，胸口都涌起一股难以言喻的震撼与安心。」",
          "brief_cabg_milestone": "「嗯……最关键的冠脉搭桥正按计划走就好。我会连呼吸都放得最轻，绝不晃动胸廓半分。」"
        }
      },
      "strain_pain_default_01": {
        "prompt": "「唔……っ！坂口医生，深部拉钩往外侧牵引的时候，里面有一股又酸又坠的钝痛直往脊背上窜……！」",
        "responses": {
          "pause_strain": "「哈啊……哈啊……谢谢你稍微松了一点拉钩的张力并告诉我原因……深部组织的牵涉痛果然骗不了人，缓这两秒钟好受多了。」",
          "coach_strain": "「嗯……吸气……慢慢呼气……跟着你的节奏把紧绷的躯干放松下来，那股深部传来的牵拉坠胀感确实没那么尖锐了。」",
          "push_through_strain": "「……是！我知道这一步如果不拉开足够的张力，深部术野反而更难安全显露……我咬牙忍住，请不要减小显露幅度，坂口医生！」"
        }
      },
      "strain_default_01": {
        "prompt": "「嗯……刚才深处传来一阵明显的拉扯感，连带着呼吸都跟着紧了一下……坂口医生，这是在游离深层韧带吗？」",
        "responses": {
          "explain_strain": "「果然是深部韧带和筋膜间隙的牵引反射……听你亲口证实了来源，身体就不会本能地去抵抗那股拉力了。」",
          "brief_strain": "「好，知道这阵牵拉很快就能过去，我就安心闭上眼忍耐一会儿。」"
        }
      },
      "abdominal_strain_pain_01": {
        "prompt": "「唔啊……っ！右上腹和胃口深处像被人攥住往外扯一样发酸发闷，连额头都开始冒冷汗了……坂口医生……！」",
        "responses": {
          "explain_abdominal_strain": "「哈啊……原来是牵拉腹膜后和肠系膜根部引起的迷走神经反射吗……平时在台上总叮嘱患者别紧张，轮到自己亲身尝到这种翻江倒海的酸胀，才明白有多难熬……」",
          "coach_abdominal_strain": "「嗯……我听你的，不屏气、不鼓肚子……哈啊……把腹壁一点点放软，绝不让肠管往你的刀口上涌……」"
        }
      },
      "strain_pain_traction_02": {
        "prompt": "「嘶……っ！第二次往深处加力牵开的时候，酸痛感比刚才还要深……坂口医生，我的手指都快把托手架抓白了……」",
        "responses": {
          "pause_second_traction": "「呼……哈啊……谢谢你让我缓一口气……坂口君……啊，不对，坂口医生……刚才那一下真的差点让我叫出声来，现在可以继续了。」",
          "coach_second_traction": "「好……我跟着你的口令深呼吸……只要能帮你把深部解剖平面完完整整露出来，这点牵拉痛我一定扛到底。」"
        }
      },
      "strain_pain_pressure_01": {
        "prompt": "「唔……有一股沉甸甸的压迫感直接顶在脏器深面，像是整只手和纱布垫都压了上来一样……呼吸有点发闷，坂口医生……」",
        "responses": {
          "relieve_pressure": "「哈啊……压迫感轻多了！谢谢你及时调整了垫纱和手下支点的角度，胸口一下子就顺畅了。」",
          "explain_pressure": "「原来是为了压迫止血和隔开周围脏器必须维持的力度吗……明白了，既然是保护性操作，我会主动适应这份重量的。」"
        }
      },
      "urologic_strain_pressure_01": {
        "prompt": "「唔……っ！后腰和侧腹深处传来一阵好强烈的酸胀感，还连着膀胱方向一阵阵发紧……坂口医生，这是在游离肾蒂还是输尿管周围？」",
        "responses": {
          "pause_urologic_strain": "「哈啊……谢谢你暂停了半拍。腹膜后泌尿系的牵拉感果然直通腰背深处……我已经调整好体位支撑了，请继续吧。」",
          "explain_urologic_strain": "「原来是分离肾周筋膜与输尿管通路时的正常反射……听你解释清楚，我就不会误以为是导尿管堵住了。请继续操作吧，坂口医生。」"
        }
      },
      "dignity_low_exposure_01": {
        "prompt": "「那个……坂口医生，无菌单刚才往两侧掀开的时候，我能感觉到微凉的空气直接拂在皮肤上……现在的暴露范围，是不是有点太大了……？」",
        "responses": {
          "restore_cover": "「谢谢你替我把切口外围的温热折巾重新掖好……明明大家都是每天泡在手术室里的同事，可真轮到自己赤裸着躺在无影灯下，还是会难为情得耳根发烫呢。」",
          "explain_exposure": "「……是为了留出足够的无菌操作与引流穿刺余量吗？站在外科医生的立场上我完全理解……我闭上眼不去想大家的视线就是了。」",
          "ignore_exposure": "「呜……话是这么说没错，在手术台上确实不该计较个人的羞耻心……我、我尽量把注意力集中回呼吸上，坂口医生。」"
        }
      },
      "dignity_default_01": {
        "prompt": "「虽说穿戴无菌单前我已经做好了心理准备……但清晰感觉到这么多双熟悉的眼睛正聚焦在自己敞开的身体部位上，心跳还是控制不住地变快了呢……」",
        "responses": {
          "protect_dignity": "「听到你特意确认除了必要术野之外都已经严密遮盖，我心里踏实多了……谢谢你的体贴，坂口医生。」",
          "brief_dignity": "「嗯，既然这一步显露很快就能结束，那我就端正心态，当一名专注配合的合格患者吧。」"
        }
      },
      "dignity_low_exposure_02": {
        "prompt": "「坂口医生……随着刚才体位和铺巾的二次调整，我感觉原本盖住身体侧面的布单又往下滑开了一点……这、这样真的没关系吗？」",
        "responses": {
          "reduce_exposure_again": "「呼……谢谢你立刻让护士帮我把侧面的无菌单重新拢好固定。哪怕在台上要服从主刀的一切安排，能被你这样护着体面，还是让人很高兴呢。」",
          "acknowledge_exposure_again": "「原来是配合当前入路角度不得不敞开的区域吗……好吧，既然是坂口医生深思熟虑后的医疗需要，我不会再扭捏抗议了。」"
        }
      },
      "dignity_cooperation_exposure_01": {
        "prompt": "「坂口医生……手术间里来回走动的脚步声听起来好清晰……现在站在台边的，都是这台手术必需的本组人员对吗？」",
        "responses": {
          "limit_observers": "「谢谢你特意清场，只留下核心配合团队。虽说作为医生早就看惯了手术台，可当被注视的人变成自己时，少一双无关的眼睛还是让我松了一大口气。」",
          "brief_privacy_confirmation": "「……嗯，你说得对，大家盯着看的只是无菌术野与解剖标志。我会收起多余的羞怯，专心配合你的，坂口医生。」"
        }
      },
      "pelvic_dignity_exposure_01": {
        "prompt": "「那个……坂口医生，下腹和耻骨上方的无菌巾压得这么低，连平时最私密的地方都好像完全敞开在灯光下了……脸颊实在烫得厉害……」",
        "responses": {
          "explain_pelvic_stage": "「为了充分显露盆腔深部间隙、保护输尿管与膀胱反折，确实必须留出这样的视野呢……道理我都明白，只是被你亲手操作那里，心跳还是很难平复下来。」",
          "brief_pelvic_stage": "「好……既然是盆腔操作必不可少的步骤，我会闭上眼睛调整呼吸，不去想下身暴露的事了。」"
        }
      },
      "pelvic_dignity_default_01": {
        "prompt": "「坂口医生，我能感觉到长柄器械正在盆腔最深处游离……连带着下面最深的地方都有一股微妙的牵坠感……现在进展到哪一步了？」",
        "responses": {
          "answer_pelvic_progress": "「原来已经顺利推进到盆腔深部的关键分离步骤了……听着你用这么沉稳的语气报出我身体深处的进展，既觉得害羞，又莫名地感到安心呢。」",
          "brief_pelvic_progress": "「嗯，盆腔深部的视野本来就窄，我不打扰你专心操作了，坂口医生。」"
        }
      },
      "breast_dignity_exposure_01": {
        "prompt": "「坂口医生……胸前的无菌洞巾一铺开，只有那边完完全全露在无影灯和大家的视线正中央……平时只有私下才会让你碰到的地方，现在却在手术台上……」",
        "responses": {
          "confirm_breast_scope": "「咳……谢谢你一本正经地确认铺巾边界。我也知道现在是严肃的乳腺外科操作，可一想到握着刀柄仔仔细细端详那里的人是你，耳根还是忍不住发麻。」",
          "brief_breast_scope": "「……明白。在手术室里那里就只是需要处理的术野而已，我会端正心态配合你的，坂口医生。」"
        }
      },
      "breast_dignity_default_01": {
        "prompt": "「胸口上方能清楚感觉到拉钩牵开腺体组织与电刀游离的细微震动……坂口医生，现在的层次剥离还顺利吗？」",
        "responses": {
          "answer_breast_stage": "「腺体后间隙与胸大肌筋膜平面都很清晰吗……呼，不愧是你。只要你的手稳稳托在那里，我就不觉得害怕了。」",
          "brief_breast_stage": "「好，知道胸前的剥离一切按计划进行，我就继续保持平稳的浅呼吸了。」"
        }
      },
      "hysterectomy_signature_01": {
        "prompt": "「坂口医生……刚才深处那一下扎实的钳夹与结扎感……是已经在离断子宫血管和主韧带了吗？一想到它真的要从我身体里被完整摘除，心口还是轻轻颤了一下……」",
        "responses": {
          "confirm_hysterectomy_scope": "「嗯……完全按照我们术前约定的范围在稳步离断就好。即便清楚术后身体终会康复，但在此刻把作为女性这么重要的器官交到你刀下，大概也只有面对我最信任的你，我才做得出来吧。」",
          "brief_hysterectomy_scope": "「好……既然主韧带和血管蒂处理得干净利落，请继续按计划完成摘除吧，坂口医生。」"
        }
      },
      "ovarian_cystectomy_signature_01": {
        "prompt": "「下腹侧方传来一阵好精细的剥离触感……坂口医生，你现在正在沿着囊壁和正常卵巢皮质之间的平面一点点剔除吗？」",
        "responses": {
          "confirm_ovarian_preservation": "「正常卵巢组织和血供都完好保留下来了吗……太好了。那种薄如蝉翼的剥离面最考验主刀的手感，交给你果然是最正确的决定，坂口医生。」",
          "brief_ovarian_preservation": "「嗯，听到保留工作一切顺利，我悬着的心就彻底放下了。」"
        }
      },
      "myomectomy_signature_01": {
        "prompt": "「坂口医生，我感觉到子宫肌层深处有一股被旋切牵引的紧绷感……现在是正在把瘤体从假包膜里完整剥出来吗？」",
        "responses": {
          "confirm_myomectomy_scope": "「瘤腔边界清楚、周围正常肌层也保护得很好吗……呼，接下来缝合关闭瘤腔的时候也请放心收紧吧，我撑得住。」",
          "brief_myomectomy_scope": "「明白。按预定范围剔除干净就好，辛苦你了，坂口医生。」"
        }
      },
      "breast_tumor_signature_01": {
        "prompt": "「胸前传来一阵小巧而精准的牵拉感……坂口医生，已经触及并完整游离出那个乳腺肿块了吗？」",
        "responses": {
          "confirm_breast_tumor_scope": "「既保证了包膜完整切缘干净，又尽量兼顾了周围腺体的形态吗……谢谢你，坂口医生，连这种细微处都替我想得这么周全。」",
          "brief_breast_tumor_scope": "「好，按原定局部切除方案顺利拿下来就好，请继续止血收尾吧。」"
        }
      },
      "mastectomy_signature_01": {
        "prompt": "「坂口医生……当整片乳腺组织从胸壁筋膜上被彻底剥离抬起的那一瞬间，胸口忽然有一种说不出的空落感……虽然不后悔，但手指还是有点发抖……」",
        "responses": {
          "acknowledge_mastectomy_loss": "「……谢谢你没有用轻巧的话敷衍我，而是认真接住了我此刻的心情。正因为执刀拿走它的人是你，这份沉甸甸的失落才变成了我能够坦然承受的信任。」",
          "confirm_mastectomy_plan": "「嗯……切除范围与筋膜平面完全符合术前计划就最好不过了。我已经缓过神来了，请继续完成创面止血吧，坂口医生。」"
        }
      },
      "ongoing_fear_default_01": {
        "prompt": "「坂口医生……在布帘后面躺久了，四周安静得只能听见监护仪的滴答声和自己的呼吸……可以稍微跟我说句话吗？」",
        "responses": {
          "reassure_ongoing": "「呼……只要听见你平稳的声音从布帘那头传过来，那种独自躺在孤岛上的错觉一下子就散开了。谢谢你，坂口医生。」",
          "brief_ongoing": "「嗯，哪怕只是简短的一句确认，也足够让我定下心来了。」"
        }
      },
      "ongoing_default_01": {
        "prompt": "「手术已经进入中后段了吧，坂口医生？我现在保持的呼吸深度和躯干放松度，还方便你在深部操作吗？」",
        "responses": {
          "coach_ongoing": "「明白，我把吸气再放浅半拍。身为外科医生，哪怕躺在患者的位置上，我也想拿个配合满分的评价呢。」",
          "reassure_ongoing_default": "「听到你夸我配合得好，比平时在晨会上受表扬还要开心一点……请继续专心手术吧，坂口医生。」"
        }
      },
      "ongoing_fear_fatigue_01": {
        "prompt": "「哈啊……身体里的力气好像正一点点被漫长的手术抽空，连维持清醒都需要集中精神了……坂口医生，能再告诉我一声现在的进展吗？」",
        "responses": {
          "maintain_running_update": "「谢谢你耐心地把每一步进展报给我听……只要脑海里还能跟着你的声音走，我就不会让自己陷入昏沉和慌乱。」",
          "brief_running_update": "「嗯……知道一切还在稳稳推进，我就能再咬牙坚持一会儿。」"
        }
      },
      "ongoing_fear_fatigue_02": {
        "prompt": "「肩膀和脖子酸得厉害，汗水顺着鬓角滑进手术帽里了……坂口医生，离这台手术的下一个节点还有多久……？」",
        "responses": {
          "preview_next_milestone": "「做完手头这组吻合与止血就进入收尾了吗……好，有了这个明确的目标，我一定稳稳撑到那一刻。」",
          "encourage_next_milestone": "「谢谢你的鼓励，坂口医生……被你这么一说，我又怎么好意思在自己的团队面前喊累呢。」"
        }
      },
      "ongoing_pain_position_01": {
        "prompt": "「唔……固定在手术台上的手腕和腰背压久了，连着切口深处的酸痛一起阵阵发麻……坂口医生，我不敢乱动，但身体有点僵住了……」",
        "responses": {
          "adjust_pressure_points": "「呼……谢谢你让巡回护士帮我微调了软垫的角度。腰背的压迫一松开，连切口那边的钝痛都好受多了。」",
          "coach_position_stillness": "「明白……现在正是深部精细操作的关键时刻，绝对不能挪动体位。我试着通过深呼吸放松肩背肌肉，请放心继续。」"
        }
      },
      "abdominal_ongoing_pressure_01": {
        "prompt": "「坂口医生，腹腔里塞入温盐水垫纱和拉钩持续牵开的感觉好胀……总觉得肚子里被填得满满当当的，连膈肌往上顶都有点明显……」",
        "responses": {
          "explain_abdominal_pressure": "「果然是为了挡开小肠襻、保持深部术野干净而放置的隔垫吗……知道不是腹腔内出血膨胀，我就彻底放心了。」",
          "brief_abdominal_pressure": "「好，再忍耐一下这阵腹胀感就是了，我会保持腹壁松弛的。」"
        }
      },
      "pelvic_ongoing_position_01": {
        "prompt": "「维持这个头低脚高又分开下肢的盆腔体位这么久，血液往头顶涌的感觉和腰骶部的酸坠混在一起……坂口医生，体位还需要保持很久吗？」",
        "responses": {
          "support_pelvic_position": "「谢谢你让人加固了肩托和膝窝软垫……耻骨和腰骶那边的拉扯感缓和多了，我可以继续配合。」",
          "coach_pelvic_position": "「嗯……为了把盆腔脏器自然往头侧移开，这个倾斜度是必需的。我会把呼吸放慢，适应它。」"
        }
      },
      "thoracic_ongoing_position_01": {
        "prompt": "「侧卧折刀位压在肋骨下面的感觉越来越沉了，撑开的肋间也在一抽一抽地发酸……坂口医生，我的上身没有往前倾吧？」",
        "responses": {
          "check_thoracic_support": "「腋垫和骨盆固定带都重新确认过了吗……好，有你们在旁边托着，我就不怕因为疲惫而走位了。」",
          "coach_thoracic_stillness": "「明白，开胸状态下哪怕偏一厘米都会影响长柄器械的角度。我一定稳住脊背，坂口医生。」"
        }
      },
      "cardiac_ongoing_fatigue_01": {
        "prompt": "「哈啊……胸腔敞开着经历了这么久的精细操作，感觉全身的热量都消耗得差不多了……坂口医生，心脏那边的核心步骤快结束了吗……？」",
        "responses": {
          "reassure_cardiac_ongoing": "「主要吻合与止血都已经确认妥当、马上准备放置心包引流了吗……呼，听见这句话，真的有种重获新生的实感呢。」",
          "brief_cardiac_ongoing": "「嗯……最艰难的时刻已经过去了。我会稳住心神，陪你走到关胸的最后一刻。」"
        }
      },
      "vascular_ongoing_pressure_01": {
        "prompt": "「坂口医生，深部血管松开阻断钳之后，我好像能感觉到一股温热的搏动重新冲过吻合口，紧接着又是纱布压迫的沉重感……这都是正常的吧？」",
        "responses": {
          "separate_vascular_sensations": "「原来温热的冲击是远端恢复通畅的血流，而压迫感只是你在用温盐水纱布做吻合口针眼轻压止血……听你拆解得这么清楚，我悬着的心就彻底放下了。」",
          "brief_vascular_pressure": "「好，只要吻合口通畅无漏血，这点压迫感我完全能忍受。」"
        }
      },
      "closure_default_01": {
        "prompt": "「刚刚听见护士们开始第一遍清点纱布和缝针的报数声了……坂口医生，我们已经正式进入逐层缝合阶段了吗？」",
        "responses": {
          "confirm_closure": "「真的是开始逐层关闭切口了……呼，平时自己在台上听到清点无误只觉得是例行公事，今天躺在布帘后面听见，简直像天籁一样呢。」",
          "brief_closure": "「嗯，辛苦你了，坂口医生。最后这几层缝合，我也会乖乖躺好配合到最后一针的。」"
        }
      },
      "closure_fear_closure_01": {
        "prompt": "「坂口医生……在逐层缝合深层组织之前，创面里的止血和最终核查都已经彻底确认过了对吗……？到了最后关头，我反而有点患得患失起来了……」",
        "responses": {
          "confirm_closure_phase": "「温盐水冲洗清亮、深部止血和创面状态都确认过两遍了吗……对不起，明明最相信你的医术，临到缝合还是忍不住多问了一句。现在我可以安心闭上眼了。」",
          "brief_closure_phase": "「……嗯，有你这句话就够了。我不胡思乱想了，安心等你缝完。」"
        }
      },
      "closure_fear_closure_02": {
        "prompt": "「器械清点的声音一遍接一遍……坂口医生，最后的闭合检查都顺利通过了吗？没有遗漏任何隐患吧？」",
        "responses": {
          "explain_final_checks": "「三遍器械纱布清点完全相符，解剖复位与张力也都核验完毕……谢谢你把完整的闭环报给我听，这下哪怕是再挑剔的外科副部长也能一百分安心了。」",
          "confirm_final_checks": "「太好了……听到全部确认无误，我浑身紧绷的力气总算能彻底卸下来了。」"
        }
      },
      "closure_pain_closure_01": {
        "prompt": "「唔……っ！持针器带着粗缝线穿过深层筋膜收紧打结的时候，切口每一针都扯得好酸好痛……到了最后体力见底的时候，痛觉反而变得更敏锐了……」",
        "responses": {
          "pause_closure_discomfort": "「哈啊……哈啊……谢谢你在打完这一结后停了两秒……筋膜层缝合的张力果然骗不了人，我已经把气喘匀了，请缝下一针吧，坂口医生。」",
          "pace_closure_breathing": "「嗯……你进针的时候我吸气，拉线收紧打结的时候我慢慢呼气……好，就这样一针一针合上吧。」"
        }
      },
      "breast_closure_fear_01": {
        "prompt": "「坂口医生，胸前皮肤正在做最后的皮内缝合对吗……？虽然不好意思问出口，但切口对合得……还整齐吗？」",
        "responses": {
          "answer_breast_closure": "「皮缘对合平整、张力均匀，还用了最细的无损伤美容缝线吗……呼，哪怕平时再怎么装作不在意，听到你把我的身体照顾得这么细致，心里还是泛起一阵甜甜的暖意呢。谢谢你，坂口医生。」",
          "brief_breast_closure": "「……嗯，只要是你亲手缝合的切口，无论是什么样子我都完全信任。」"
        }
      }
    }
  },
  "en": {
    "address_context": {
      "surgeon_name": "Dr. Sakaguchi"
    },
    "invitation_lines": [
      "\"{procedure_name}... Very well, I accept, Sakaguchi-kun. Since I promised out in the corridor that day to be an obedient patient, today I leave the primary surgeon's place entirely in your hands.\"",
      "\"...So you chose {procedure_name}. I know the steps and anatomical planes by heart, yet lying on the table myself will surely make me more nervous than I expect. Please take good care of me, Sakaguchi-kun.\"",
      "\"Alright. I have already cleared my own shift schedule--just don't cut corners on the preoperative explanation for {procedure_name} simply because I am the Deputy Chief of Surgery, Sakaguchi-kun.\""
    ],
    "invitation_by_category": {
      "ROUTINE": [
        "\"{procedure_name}? I have guided junior surgeons through it many times at the table, yet I never imagined experiencing the standard protocol from the patient's side myself... I will cooperate dutifully, Sakaguchi-kun.\""
      ],
      "MAJOR": [
        "\"To think you selected a major operation like {procedure_name}... I know better than anyone how demanding the deep dissection and vascular protection will be. Still, with you as primary surgeon, Sakaguchi-kun, I entrust my body to you without reservation.\""
      ],
      "HYSTERECTOMY": [
        "\"{procedure_name}... That is certainly not a procedure one can take lightly as mere routine practice. Even so, I have thought it through--if you are the one holding the scalpel, Sakaguchi-kun, I accept this decision.\""
      ],
      "MASTECTOMY": [
        "\"{procedure_name}... It would be a lie to say my heart is completely unshaken. Yet standing before you now is not the Deputy Chief, only Artoria who trusts you completely. Proceed according to your judgment, Sakaguchi-kun.\""
      ],
      "ORGAN_REMOVAL": [
        "\"{procedure_name}... That is a major organ resection of immense weight. I place my body and the entire operation ahead completely in your hands, Sakaguchi-kun.\""
      ]
    },
    "ward_visit_opening": [
      {
        "speaker": "narrator",
        "text": "When the door to the private ward opens, Artoria--who normally wears a crisp white coat--has already changed into a pale blue hospital gown, sitting upright on the edge of the bed with her folded clothes neatly stacked beside her."
      },
      {
        "speaker": "patient",
        "text": "\"You are here, Sakaguchi-kun. I have walked into this ward countless times on rounds, yet once I take off my white coat and sit on the hospital bed, even the air feels completely different.\""
      },
      {
        "speaker": "player",
        "text": "\"It is not too late for the Deputy Chief to back out, you know? Once we step into the operating room, I really will treat you strictly as an ordinary patient.\""
      },
      {
        "speaker": "patient",
        "text": "\"I would never retreat at the last moment. From now on, there is no Deputy Chief of Surgery here, only your patient Artoria--please begin the preoperative preparations according to formal protocol, Dr. Sakaguchi.\""
      }
    ],
    "stage_prompts": {
      "graphic_preop_question": "\"Dr. Sakaguchi, before you begin the briefing, I would like to confirm three things as your patient--what are the planned boundaries of anatomical dissection today, how do you need me to coordinate my breathing and posture during the procedure, and what is the plan for postoperative drainage?\""
    },
    "reaction_lines": {
      "hospitalization_question": "\"Seeing 'Artoria Pendragon' written in the patient column feels stranger than signing ten high-risk surgical consent forms... Dr. Sakaguchi, are all my admission papers in order?\"",
      "hospitalization_response": "\"Understood. I have handed over all department duties and shift schedules, and I will not interfere with any staff matters while admitted. I will focus entirely on being a proper patient.\"",
      "procedure_mismatch": "\"...Please wait a moment, Dr. Sakaguchi. The instrument tray and positioning setup do not match the procedure we agreed upon in the ward--as primary surgeon, please explain the clinical reason for changing the plan first.\"",
      "explain_plan": "\"Even if I know every step in the surgical textbook, I am the one lying on the table today. Please do not omit details on account of my title, Dr. Sakaguchi--explain the surgical plan to me in full just as you would for any other patient.\"",
      "brief_plan": "\"...That was a very concise explanation. I nearly slipped into my old habit of adding anatomical precautions for you... Ahem, I understand the general plan and will follow your lead, Dr. Sakaguchi.\"",
      "last_reassure": "\"Yes, my pulse has steadied now. Both the scalpel ahead and the long closure to come--I leave everything to you and the team, Dr. Sakaguchi.\"",
      "choose_general": "\"General anesthesia... Perhaps that is for the best, so I cannot eavesdrop on the instruments behind the drape or issue unauthorized orders. When I open my eyes again, I hope yours is the first face I see, Dr. Sakaguchi.\"",
      "choose_epidural": "\"Epidural blockade... I am usually the one placing the catheter behind the patient's back. Feeling my own lower body grow numb and heavy while remaining wide awake makes me unexpectedly uneasy. Please take care of me, Dr. Sakaguchi.\"",
      "choose_local": "\"Local infiltration anesthesia... That means superficial sharp pain will be blocked, but I will clearly feel every deep fascial traction and instrument movement, right? ...I am mentally prepared, Dr. Sakaguchi.\"",
      "choose_none": "\"...Without any anesthesia at all? Dr. Sakaguchi, as a surgeon I know better than anyone what kind of raw trauma and pain that entails... Yet since we made this decision together, I will not flinch on the table.\"",
      "induction_reassure": "\"The oxygen inside the mask feels gentle... My eyelids are already growing heavy... Dr. Sakaguchi, everyone, I am in your hands...\"",
      "insist_without_anesthesia": "\"There is no need to add anesthesia, Dr. Sakaguchi. My fingers are gripping the edge of the table... No matter how intense the pain, I will clench my teeth and endure it, so please proceed as planned!\"",
      "assistant_stabilize_none": "\"Ugh...! F-forgive me, without anesthesia my body still tenses and trembles by reflex... Thank you for steadying my shoulders, that helps me feel much more grounded.\"",
      "assistant_stabilize_local": "\"Thank you for helping stabilize my posture... Under local anesthesia I can still feel the vibrations across the table, so having support by my shoulder makes it easier to stay focused.\"",
      "assistant_stabilize_epidural": "\"Thank you for the trouble... Now that the epidural level has set in, I have no strength in my waist or legs at all. Having to rely on everyone just to keep my balance is a little embarrassing.\"",
      "incision_ready": "\"...That crisp metallic sound just now was the scrub nurse placing the scalpel into your hand, wasn't it, Dr. Sakaguchi? I have heard it countless times at the table, yet feeling the blade hover right above my own skin makes my heart race... P-please make the incision.\"",
      "incise_epidural": "\"Mm...! There is no sharp pain, yet the taut vibration of the blade parting skin and subcutaneous tissue still travels clearly through me... Your first stroke is very steady, Dr. Sakaguchi. Please continue.\"",
      "incise_local": "\"Tch... ah! The epidermis does not hurt, but cutting into the deeper fascia brings a dull, aching pull... I-it is fine, my breathing is steady, please keep advancing, Dr. Sakaguchi.\"",
      "incise_none": "\"Ngh... ah! Haa, haa... It burns, as if a searing blade just split me open directly...! D-do not stop, Dr. Sakaguchi... I can hold on, do not let my muscle guarding slow down your dissection planes...!\"",
      "contact_pause": "\"Haa... haa... Thank you, Dr. Sakaguchi. Giving me just these few seconds to catch my breath eases the cold sweat so much...\"",
      "contact_command": "\"...Yes! Forgive me, I will hold completely still... I will follow your count and exhale slowly, please continue, Dr. Sakaguchi!\"",
      "contact_continue": "\"...I have steadied my breathing now, Dr. Sakaguchi. Do not worry about me--please continue the dissection.\"",
      "ongoing_narrate": "\"Hearing you call out the anatomical planes lets me picture the field in my mind even behind the drape... Your rhythm is rock-solid. Hearing your voice puts me at ease.\"",
      "ongoing_eye_contact": "\"Meeting your eyes past the sterile drape... all that tension knotted in my chest quieted down in an instant. I am alright, Dr. Sakaguchi.\"",
      "ongoing_silent": "\"...Dr. Sakaguchi? For a long while now there has only been the clinking of needle holders and hemostats... Did you run into dense adhesions deep down? If you can spare a breath, please say a word to me...\"",
      "closure_reassure": "\"Have we finally reached layer-by-layer closure and suturing...? Phew... Hearing that, my back can finally relax against the operating table after staying rigid for so long.\"",
      "closure_coach": "\"Mm... inhale... and slowly exhale... I still remember the rule about relaxing muscle tension during closure, though my stamina is nearly spent... I will follow your rhythm dutifully.\"",
      "closure_silent": "\"Haa... My eyelids feel so heavy, I barely have the strength to move my fingers... Dr. Sakaguchi... only a few subcuticular stitches left, right...? I will wait quietly right here until you finish...\""
    },
    "reaction_variants": {
      "ward_enema": [
        "\"Of course I understand the importance of preoperative bowel preparation... Yet I am usually the one writing the orders. Having to lift my gown and lie on my side for an enema myself--even with a familiar nurse--still makes my ears burn...\"",
        "\"Mm... As the warm fluid flows in, this mounting pressure and cramping in my lower abdomen makes it terribly hard to keep my usual composure... P-please let me grip the bed rail and hold on for five more minutes, I will evacuate strictly according to protocol...\""
      ],
      "ward_enema_unnecessary": [
        "\"Today's procedure does not involve the lower gastrointestinal tract or deep pelvic exposure, so skipping routine enema is indeed consistent with guidelines... Ahem, I am merely agreeing on evidence-based grounds, not breathing a secret sigh of relief, Dr. Sakaguchi.\"",
        "\"Skipping the preoperative enema? Since it will not compromise the sterile field or bowel decompression, as a patient I will honestly thank you for sparing me one ordeal, Dr. Sakaguchi.\""
      ],
      "ward_skin_prep": [
        "\"The rustling touch of the prep razor gliding across my skin is both more ticklish and far more embarrassing than I imagined... Standing at the table I took a clean surgical field for granted, yet lying here myself shows me how exposed a patient feels.\"",
        "\"Please shave the entire standard boundary cleanly. To prevent postoperative surgical site infection, hair removal must never be half-hearted--I will simply keep my eyes closed, mm...\""
      ],
      "ward_skin_prep_unnecessary": [
        "\"Um... Dr. Sakaguchi, given today's incision pathway, does the area being shaved right now not extend somewhat beyond the required sterile boundary...? E-even though I placed myself in your hands, please spare a thought for my dignity.\"",
        "\"Must that area be shaved as well...? That is clearly outside the primary incision path... Mm, if you insist it is for an extra margin of sterile safety, I will lie still and comply.\""
      ],
      "ward_surgical_cap": [
        "\"Normally, putting on a disposable cap before entering the OR means taking up the scalpel for battle; tucking all my braided hair into this blue patient cap today feels like a quiet reminder that I must surrender everything to others now.\"",
        "\"Even the stray hairs along my forehead are tucked inside the cap. Seeing myself in the mirror wearing only a hospital gown and surgical cap without a trace of makeup finally makes it sink in that I am today's surgical patient.\""
      ],
      "operative_positioning_awake": [
        "\"The operating table feels much harder and colder than when I stand beside it in a sterile gown... Once both arms are extended and strapped to the armboards, I truly cannot shift even half an inch on my own.\"",
        "\"The angle of the positioning pads fits well and supports my lower back. Still, lying flat and defenseless directly beneath the shadowless lamp makes my breathing turn shallow despite my complete trust in all of you.\""
      ],
      "operative_positioning_none": [
        "\"Securing my limbs and torso directly to the table without any anesthetic protection at all... Ugh, the moment the straps tightened around my wrists, every hair down my spine stood on end... I will do my utmost not to thrash on the table.\"",
        "\"My posture is aligned as you asked, Dr. Sakaguchi. Just thinking that I must endure every incision and retraction wide awake on this pad makes my fingertips clench the armboards tightly...\""
      ],
      "urinary_catheterization_awake": [
        "\"Ngh...! I know perfectly well that an indwelling catheter is essential to monitor renal perfusion and prevent bladder distension... Yet parting my legs to be catheterized in front of Dr. Sakaguchi and my own staff is still mortifying beyond words...\"",
        "\"Haa... I can feel the dull pressure of the balloon inflating inside my bladder... I have ordered catheterization for countless patients, yet lying here watching the drainage bag hung by the rail shows me how much courage it takes...\""
      ],
      "urinary_catheterization_none": [
        "\"Ah... ngh! W-without any anesthetic numbing, every inch of the catheter sliding against the urethral mucosa feels terrifyingly vivid...! F-forgive me, Dr. Sakaguchi, I did not mean to tense my thighs, I will relax my breathing right now...\"",
        "\"Tch... haa... It stings with a sharp, aching urge to void... So this is what unanesthetized catheterization feels like... Mm, as long as drainage is clear, please proceed to the next step...\""
      ],
      "skin_disinfection_awake": [
        "\"Mm... When the povidone-iodine sponge first touched my skin, the chill still made me flinch slightly. Your spiral strokes outward from the incision center are textbook-perfect... Even I could not find a single flaw.\"",
        "\"The cool antiseptic slowly evaporates across my skin, filling the air with its sharp scent. Every pass of the sponge brings the actual blade one step closer... Can you hear my heartbeat from over there?\""
      ],
      "skin_disinfection_none": [
        "\"Ah... so cold...! Without anesthesia to dull my nerves, the icy iodine brushing over my taut skin feels like a preview of the scalpel's path... Dr. Sakaguchi, my palms are completely drenched in sweat...\"",
        "\"One pass, two passes, three passes... The wider the antiseptic spreads, the faster my breath catches... I know it is only a sponge, yet my body is already bracing in primal fear of the live blade...\""
      ],
      "incision_marking_awake": [
        "\"The faint tickle of the skin marker gliding across my skin is crystal clear... Judging from the length and trajectory of your stroke, Dr. Sakaguchi, you have balanced anatomical exposure and cosmetic closure admirably.\"",
        "\"Having a purple surgical incision line drawn across my own body... Where that ink rests will become a real wound in moments. I will close my eyes and breathe deeply--you may drape and begin whenever ready, Dr. Sakaguchi.\""
      ],
      "incision_marking_none": [
        "\"Ngh...! The instant the marker tip touched my skin, I thought the scalpel had already come down and nearly held my breath... So it was only the skin marker... I must look terribly jumpy to you, Dr. Sakaguchi.\"",
        "\"As the marker tip traces inch by inch along the planned incision path, it does not hurt at all, yet knowing that a sharp blade will follow this exact line next makes my muscles clench involuntarily...\""
      ]
    },
    "interaction_overrides": {
      "contact_pain_incision_01": {
        "prompt": "\"Ngh...! Dr. Sakaguchi... The searing pain of the blade cutting in is even more direct than I braced myself for... Has my breathing turned uneven?\"",
        "responses": {
          "explain_contact": "\"Phew... haa... So you have already passed cleanly through the dermis. Thank you for reminding me, Dr. Sakaguchi--I will exhale slowly and keep my muscles from tensing against your plane.\"",
          "brief_contact": "\"...Understood. As long as everything is proceeding according to plan, I can endure this level of pain without issue. Please continue, Dr. Sakaguchi.\"",
          "continue_contact": "\"Yes...! Forgive me, I will stay focused. My hands are gripping the armboards steadily--please continue the dissection.\""
        }
      },
      "contact_no_anesthesia_incision_01": {
        "prompt": "\"Ah... ngh! Haa, haa... With no anesthesia at all to veil it, feeling live flesh parted directly by the scalpel... is this intense...!\"",
        "responses": {
          "steady_unanesthetized_contact_01": "\"Haa... mm... Inhale to your voice, and exhale... Thank you for slowing the pace of your blade, Dr. Sakaguchi... I have a firm grip on the table rail now, you may continue...\"",
          "continue_unanesthetized_contact_01": "\"Ngh...! I understand--hesitating mid-incision is the worst thing a surgeon can do... I will clench my teeth and bear it, Dr. Sakaguchi. Ignore my trembling and cut cleanly to the target depth...!\""
        }
      },
      "contact_no_anesthesia_incision_02": {
        "prompt": "\"Tch...! The sharp sting of the electrocautery tip against raw tissue mixed with the retractors pulling the wound apart... Dr. Sakaguchi, has my cold sweat soaked through the head pad already...?\"",
        "responses": {
          "steady_unanesthetized_contact_02": "\"Haa... Thank you for pausing those few seconds to let me catch my breath... When I stand as primary surgeon, hemostasis and retraction feel routine, yet lying here myself shows me what sheer willpower it takes to endure...\"",
          "continue_unanesthetized_contact_02": "\"Mm...! Do not stop on my account, Dr. Sakaguchi! My back is flat against the operating table--as long as your scalpel is steady, I will not budge a fraction of an inch!\""
        }
      },
      "contact_no_anesthesia_incision_03": {
        "prompt": "\"Ugh... haa... Dr. Sakaguchi... When the deep fascia is cut directly with scissors, my entire body shudders by instinct... Are we truly... going all the way to the end without anesthesia...?\"",
        "responses": {
          "steady_unanesthetized_contact_03": "\"...Mm, you are right. Since we resolved to proceed without anesthesia before starting, we must not falter halfway. Thank you for easing the traction slightly... I have steadied myself now, Dr. Sakaguchi.\"",
          "continue_unanesthetized_contact_03": "\"...Yes! That was only a fleeting moment of bodily weakness speaking... I have regained control of my breathing. Please continue with the unanesthetized plan, Dr. Sakaguchi!\""
        }
      },
      "contact_default_01": {
        "prompt": "\"Dr. Sakaguchi, I can feel the instruments resting against the edge of the incision... Have you officially entered the subcutaneous dissection phase?\"",
        "responses": {
          "reassure_start": "\"Hearing you confirm that both my vitals and the incision plane are stable puts my mind completely at ease. I nearly asked for the estimated blood loss out of sheer habit... Please continue.\"",
          "brief_start": "\"Understood. Just hearing the certainty in your voice tells me the initial incision went smoothly.\"",
          "silent_start": "\"...Forgive me, I promised to be a quiet and obedient patient on the table today. I will keep silent and focus on my breathing, Dr. Sakaguchi.\""
        }
      },
      "contact_pain_incision_02": {
        "prompt": "\"Ngh... As the retractors draw the edges of the incision apart, a deep, aching sting radiates inward... Dr. Sakaguchi, is the current exposure wide enough?\"",
        "responses": {
          "acknowledge_second_contact": "\"So you are setting the self-retaining retractor in place... Phew, knowing that this tension is a planned and necessary step makes it much easier to bear. Thank you, Dr. Sakaguchi.\"",
          "brief_second_contact": "\"Alright... Since it is all going according to plan, I will keep my torso relaxed. Please proceed.\""
        }
      },
      "contact_fear_incision_01": {
        "prompt": "\"With the sterile drape blocking my view, all I can hear is the crisp click of hemostats locking... Dr. Sakaguchi, was that sound just now the ligation of the superficial vessels?\"",
        "responses": {
          "orient_fearful_contact": "\"I see... Hearing you name the exact step you just completed fills in the blank behind the drape right away. Lying on this side of the table, the primary surgeon's voice truly is the best reassurance.\"",
          "steady_fearful_contact": "\"Mm... I will stop trying to guess every instrument sound and simply focus on your voice and my breathing rhythm...\"",
          "dismiss_fearful_contact": "\"...Forgive me, my old surgeon's habit of wanting to track every step on the table slipped out again. I will stop asking and leave everything to you, Dr. Sakaguchi.\""
        }
      },
      "progress_fear_default_01": {
        "prompt": "\"Dr. Sakaguchi... The shadow of the operating lamp against the drape has barely shifted, and I have lost track of how much time has passed... Is the procedure progressing smoothly?\"",
        "responses": {
          "explain_progress": "\"Every layer is advancing right on schedule... What a relief. Lying on the surface of the table makes time feel several times longer than when holding the scalpel.\"",
          "brief_progress": "\"Mm, as long as I know you are advancing steadily, I will not let my thoughts wander. Thank you for your hard work, Dr. Sakaguchi.\"",
          "dismiss_progress": "\"...Understood. A primary surgeon focusing on deep dissection should not be distracted. I will regulate my breathing quietly, Dr. Sakaguchi.\""
        }
      },
      "progress_default_01": {
        "prompt": "\"I just heard the exchange of long-handled instruments and warm saline laparotomy pads... Dr. Sakaguchi, which anatomical stage have we reached now?\"",
        "responses": {
          "answer_progress": "\"Just where I estimated we would be. Your anatomical planes are always so clean--knowing we have reached this point sets my heart completely at rest.\"",
          "brief_answer_progress": "\"As long as everything is on schedule, that is all I need to hear. I will keep playing my part as a cooperative patient, Dr. Sakaguchi.\""
        }
      },
      "progress_fear_fatigue_01": {
        "prompt": "\"Haa... Holding the exact same fixed posture on the table for so long has left my back and shoulders stiff and heavy... Dr. Sakaguchi, how much further until the core step is complete...?\"",
        "responses": {
          "explain_fatigue_progress": "\"More than halfway through already...? Phew, hearing you lay out the remaining steps so clearly gives me a fresh second wind. Thank you, Dr. Sakaguchi.\"",
          "brief_fatigue_progress": "\"Mm... Since we are right on track, this bit of fatigue is nothing. I can still hold on, Dr. Sakaguchi.\""
        }
      },
      "progress_fear_fatigue_02": {
        "prompt": "\"Every breath feels heavier now, and even the sound of instruments being passed feels a little distant... Dr. Sakaguchi, have we passed the most critical hurdle yet...?\"",
        "responses": {
          "mark_fatigue_milestone": "\"Thank goodness... Hearing you mark such a clear milestone feels like spotting a signpost on a long march... I will see this through to the very end.\"",
          "encourage_fatigue_progress": "\"So the most demanding part is safely behind us... Phew... Hearing that finally lets my taut nerves breathe a little easier. I leave the remainder to you, Dr. Sakaguchi.\""
        }
      },
      "cardiac_progress_fear_01": {
        "prompt": "\"The pressure of the sternal retractor holding my chest open feels so heavy... as if my own heartbeat is laid bare to the air... Dr. Sakaguchi, are the pericardium and great vessels alright?\"",
        "responses": {
          "explain_cardiac_progress": "\"Phew... Hearing you report the cardiac exposure and hemodynamic stability so clearly calms the primal dread of having my chest opened. I expected nothing less of you, Dr. Sakaguchi.\"",
          "brief_cardiac_progress": "\"Mm... As long as your hands inside my chest remain steady, I entrust every beat of my heart to you.\""
        }
      },
      "cardiac_progress_default_01": {
        "prompt": "\"Dr. Sakaguchi, I just felt an exquisitely fine traction deep within my mediastinum... Have you entered the core cardiac phase now?\"",
        "responses": {
          "answer_cardiac_progress": "\"So we have reached the most delicate stage after all. I will not dare take a single abrupt breath--I will keep my respiratory excursion as steady as possible to support you.\"",
          "brief_cardiac_answer": "\"Understood. Proceeding according to plan is what matters most. I will remain completely still, Dr. Sakaguchi.\""
        }
      },
      "thoracic_progress_fatigue_01": {
        "prompt": "\"Haa... With one side of my thorax open, every inhalation feels so much heavier than usual... Dr. Sakaguchi, how far along is the intrathoracic dissection...?\"",
        "responses": {
          "explain_thoracic_progress": "\"So the hilar and mediastinal dissection is nearly complete... Knowing the exact anatomical progress eases that suffocating panic in my chest so much. Thank you, Dr. Sakaguchi.\"",
          "brief_thoracic_progress": "\"Alright... Since everything is going smoothly, I will keep breathing shallowly and evenly so mediastinal shift never disturbs your field.\""
        }
      },
      "vascular_progress_deep_01": {
        "prompt": "\"That deep, firm pressure just now... Did the atraumatic vascular clamp just occlude the main vessel, Dr. Sakaguchi? Are the clamp time and distal perfusion holding steady?\"",
        "responses": {
          "explain_vascular_milestone": "\"Clean clamp placement and well within the safe ischemia window... Phew, even though I am the patient on the table, hearing such textbook vascular control makes me want to applaud you.\"",
          "brief_vascular_milestone": "\"Understood. With you watching the clamp clock, I will set aside unnecessary worries--please focus entirely on the vascular anastomosis.\""
        }
      },
      "cabg_signature_01": {
        "prompt": "\"Dr. Sakaguchi... I can sense the finest suture tension right in the center of my chest... Are you performing the coronary artery bypass graft anastomosis right now?\"",
        "responses": {
          "explain_cabg_milestone": "\"Good target vessel exposure and brisk graft flow...? Having this performed on my own heart while hearing you confirm it fills my chest with an indescribable mix of awe and relief.\"",
          "brief_cabg_milestone": "\"Mm... Knowing the critical coronary anastomosis is right on schedule is enough. I will keep my breathing whisper-soft so my chest wall does not move a hair.\""
        }
      },
      "strain_pain_default_01": {
        "prompt": "\"Ngh...! Dr. Sakaguchi, when the deep retractor pulls outward, a heavy, aching pain shoots straight up into my spine...!\"",
        "responses": {
          "pause_strain": "\"Haa... haa... Thank you for easing the retractor tension slightly and explaining the cause... Deep tissue referred pain truly cannot be reasoned away, and those two seconds helped immensely.\"",
          "coach_strain": "\"Mm... inhale... and slowly exhale... Following your rhythm to relax my rigid torso really does dull that heavy pulling sensation from deep inside.\"",
          "push_through_strain": "\"...Yes! I know that without sufficient retraction, the deep surgical field cannot be exposed safely... I will grit my teeth and endure it, so please do not reduce your exposure, Dr. Sakaguchi!\""
        }
      },
      "strain_default_01": {
        "prompt": "\"Mm... I just felt a distinct tugging deep inside that made my breath catch... Dr. Sakaguchi, are you mobilizing the deep ligaments right now?\"",
        "responses": {
          "explain_strain": "\"So it really is the traction reflex from the deep ligaments and fascial planes... Hearing you confirm the source keeps my body from instinctively fighting the pull.\"",
          "brief_strain": "\"Alright. Knowing this traction will pass shortly lets me close my eyes and bear with it calmly.\""
        }
      },
      "abdominal_strain_pain_01": {
        "prompt": "\"Ugh... ah! Deep in my upper abdomen and epigastrium, it feels as though my organs are being gripped and pulled outward--cold sweat is breaking out across my forehead... Dr. Sakaguchi...!\"",
        "responses": {
          "explain_abdominal_strain": "\"Haa... So it is the vagal reflex from traction on the retroperitoneum and mesenteric root... I have told countless patients at the table not to tense up, yet tasting this churning visceral ache myself shows me just how grueling it is...\"",
          "coach_abdominal_strain": "\"Mm... I am listening--do not hold my breath, do not bear down... Haa... I will let my abdominal wall soften bit by bit so the bowel never pushes into your field...\""
        }
      },
      "strain_pain_traction_02": {
        "prompt": "\"Tch...! When the second deep retraction pulls harder, the aching pull cuts even deeper than before... Dr. Sakaguchi, my knuckles are turning white on the armboards...\"",
        "responses": {
          "pause_second_traction": "\"Phew... haa... Thank you for letting me catch my breath... Sakaguchi-kun... ah, no, Dr. Sakaguchi... That pull just now nearly made me cry out, but I am ready to continue now.\"",
          "coach_second_traction": "\"Alright... I will breathe deeply to your count... As long as it helps you expose the deep anatomical plane cleanly, I will endure this traction to the end.\""
        }
      },
      "strain_pain_pressure_01": {
        "prompt": "\"Ngh... There is a heavy, crushing pressure resting directly against my deep organs, as if a whole hand and laparotomy pad are pressing down... My chest feels tight, Dr. Sakaguchi...\"",
        "responses": {
          "relieve_pressure": "\"Haa... That pressure eased so much! Thank you for adjusting the angle of the packing pad and fulcrum--I can breathe freely again.\"",
          "explain_pressure": "\"So that downward pressure is necessary to tamponade oozing and shield adjacent organs... Understood. Since it is a protective maneuver, I will adapt to the weight.\""
        }
      },
      "urologic_strain_pressure_01": {
        "prompt": "\"Ngh...! A fierce, aching pressure is radiating deep through my flank and lower back, pulling all the way down toward my bladder... Dr. Sakaguchi, are you dissecting around the renal pedicle or ureter?\"",
        "responses": {
          "pause_urologic_strain": "\"Haa... Thank you for pausing half a beat. Retroperitoneal urologic traction really does travel straight into the deep lumbar nerves... I have steadied my posture now, please continue.\"",
          "explain_urologic_strain": "\"So it is the normal reflex from mobilizing Gerota's fascia and the ureteral pathway... Hearing your explanation keeps me from worrying that the urinary catheter is obstructed. Please proceed, Dr. Sakaguchi.\""
        }
      },
      "dignity_low_exposure_01": {
        "prompt": "\"Um... Dr. Sakaguchi, when the sterile drapes were folded back just now, I felt cool air brushing directly across my bare skin... Is the current exposure not a little wider than necessary...?\"",
        "responses": {
          "restore_cover": "\"Thank you for tucking the warm sterile towels back around the periphery of the field... Even though everyone here is a colleague I work with every day, lying bare under the operating lamp still makes my ears burn with embarrassment.\"",
          "explain_exposure": "\"...It is to leave sufficient sterile margin for manipulation and drain placement, is it? Speaking as a surgeon, I cannot fault that logic... I will simply close my eyes and try not to think about everyone watching.\"",
          "ignore_exposure": "\"Ugh... You have a point--on the operating table, personal modesty must give way to the procedure... I-I will redirect my focus back to my breathing, Dr. Sakaguchi.\""
        }
      },
      "dignity_default_01": {
        "prompt": "\"Even though I braced myself before the drapes were laid... clearly feeling so many familiar eyes focused on the exposed part of my body still makes my pulse race uncontrollably...\"",
        "responses": {
          "protect_dignity": "\"Hearing you personally confirm that everything outside the essential surgical field is securely draped puts my heart much more at ease... Thank you for your consideration, Dr. Sakaguchi.\"",
          "brief_dignity": "\"Mm, since this exposure step will be over shortly, I will compose myself and focus on being a cooperative patient.\""
        }
      },
      "dignity_low_exposure_02": {
        "prompt": "\"Dr. Sakaguchi... With that second adjustment of my posture and the drapes, I felt the cloth covering my side slip down a bit further... I-is it truly necessary to leave this much uncovered?\"",
        "responses": {
          "reduce_exposure_again": "\"Phew... Thank you for having the nurse immediately re-secure the lateral drape for me. Even though I must obey the primary surgeon on the table, having you protect my dignity like this makes me truly grateful.\"",
          "acknowledge_exposure_again": "\"So this angle of exposure is unavoidable for your current approach... Very well. Since it is a clinical necessity judged by Dr. Sakaguchi, I will not protest any further.\""
        }
      },
      "dignity_cooperation_exposure_01": {
        "prompt": "\"Dr. Sakaguchi... The footsteps moving around the operating room sound so distinct... Everyone standing by the table right now is essential surgical staff for this case, right?\"",
        "responses": {
          "limit_observers": "\"Thank you for clearing the room and keeping only the core team. Even though I am used to the operating table as a surgeon, having fewer eyes on me when I am the one lying bare is a tremendous relief.\"",
          "brief_privacy_confirmation": "\"...Mm, you are right. Everyone is focused strictly on the sterile field and anatomical landmarks. I will set aside my self-consciousness and cooperate, Dr. Sakaguchi.\""
        }
      },
      "pelvic_dignity_exposure_01": {
        "prompt": "\"Um... Dr. Sakaguchi, with the lower drape secured so low across my lower abdomen and pubis, even my most private area feels completely laid bare under the lamp... My cheeks are burning terribly...\"",
        "responses": {
          "explain_pelvic_stage": "\"To properly expose the deep pelvic spaces and protect the ureters and bladder reflection, this field truly is necessary... I understand the clinical logic, yet having you operate on me down there still makes my heart race.\"",
          "brief_pelvic_stage": "\"Alright... Since it is an indispensable part of the pelvic procedure, I will close my eyes, steady my breathing, and stop dwelling on how exposed I am.\""
        }
      },
      "pelvic_dignity_default_01": {
        "prompt": "\"Dr. Sakaguchi, I can feel the long-handled instruments dissecting deep within my pelvis... bringing a subtle, aching pull all the way down there... Which stage have we reached now?\"",
        "responses": {
          "answer_pelvic_progress": "\"So you have already reached the key deep pelvic dissection step... Hearing you report the progress deep inside me in such a calm voice makes me feel both shy and strangely reassured.\"",
          "brief_pelvic_progress": "\"Mm, the deep pelvic field is narrow enough as it is--I will not distract you from your work, Dr. Sakaguchi.\""
        }
      },
      "breast_dignity_exposure_01": {
        "prompt": "\"Dr. Sakaguchi... Once the fenestrated drape opened across my chest, that side was left completely bare under the shadowless lamp... A place I would normally only let you touch in private is right at the center of the operating table...\"",
        "responses": {
          "confirm_breast_scope": "\"Ahem... Thank you for confirming the draping margin so earnestly. I know this is a formal breast procedure, yet knowing that you are the one holding the scalpel and looking so closely right there still makes my ears tingle.\"",
          "brief_breast_scope": "\"...Understood. In the operating room, that area is simply the surgical field. I will compose myself and cooperate properly, Dr. Sakaguchi.\""
        }
      },
      "breast_dignity_default_01": {
        "prompt": "\"Across my chest, I can clearly feel the retractors drawing back the glandular tissue and the fine vibration of the cautery... Dr. Sakaguchi, is the plane dissection proceeding smoothly?\"",
        "responses": {
          "answer_breast_stage": "\"The retromammary space and pectoralis fascia plane are both clean and distinct...? Phew, just as I expected of you. As long as your hands are resting steadily there, my fear fades away.\"",
          "brief_breast_stage": "\"Alright. Knowing the dissection across my chest is right on schedule, I will keep my breathing shallow and even.\""
        }
      },
      "hysterectomy_signature_01": {
        "prompt": "\"Dr. Sakaguchi... That firm clamping and ligation deep inside just now... Are you dividing the uterine vessels and cardinal ligaments already? Knowing that my uterus is truly about to be removed still makes my heart tremble slightly...\"",
        "responses": {
          "confirm_hysterectomy_scope": "\"Mm... Proceeding steadily within the exact scope we agreed upon is all I ask. Even knowing my body will recover in time, placing such an intimate part of myself as a woman beneath your blade is something I could only ever entrust to you.\"",
          "brief_hysterectomy_scope": "\"Alright... Since the cardinal ligaments and vascular pedicles are secured cleanly, please complete the resection as planned, Dr. Sakaguchi.\""
        }
      },
      "ovarian_cystectomy_signature_01": {
        "prompt": "\"There is such a delicate peeling sensation low on my side... Dr. Sakaguchi, are you enucleating the cyst along the cleavage plane between the cyst wall and healthy ovarian cortex right now?\"",
        "responses": {
          "confirm_ovarian_preservation": "\"Both the healthy ovarian parenchyma and blood supply are preserved intact...? Wonderful. That paper-thin cleavage plane tests a surgeon's touch more than anything--entrusting it to you was truly the right choice, Dr. Sakaguchi.\"",
          "brief_ovarian_preservation": "\"Mm, hearing that the preservation is going smoothly takes a great weight off my mind.\""
        }
      },
      "myomectomy_signature_01": {
        "prompt": "\"Dr. Sakaguchi, I can feel a taut traction deep within the myometrium... Are you shelling the fibroid out from its pseudocapsule right now?\"",
        "responses": {
          "confirm_myomectomy_scope": "\"A clean pseudocapsule plane and well-protected surrounding myometrium...? Phew, when you suture the uterine bed closed next, please tie the knots firmly--I can handle the tension.\"",
          "brief_myomectomy_scope": "\"Understood. Removing it cleanly within the planned boundary is what matters most. Thank you for your hard work, Dr. Sakaguchi.\""
        }
      },
      "breast_tumor_signature_01": {
        "prompt": "\"There is a focused, precise traction across my breast... Dr. Sakaguchi, have you reached and circumscribed the breast mass already?\"",
        "responses": {
          "confirm_breast_tumor_scope": "\"Clean margins around an intact capsule while preserving the surrounding glandular contour as much as possible...? Thank you, Dr. Sakaguchi, for being so thoughtful even down to those details.\"",
          "brief_breast_tumor_scope": "\"Alright. Knowing the local excision went cleanly as planned is enough--please proceed with hemostasis and closure.\""
        }
      },
      "mastectomy_signature_01": {
        "prompt": "\"Dr. Sakaguchi... The instant the entire breast tissue was lifted free from the pectoral fascia, a sudden, indescribable emptiness washed over my chest... I do not regret this, yet my fingers are trembling slightly...\"",
        "responses": {
          "acknowledge_mastectomy_loss": "\"...Thank you for not brushing my feelings aside with easy platitudes, and for truly understanding what this moment means to me. Because it was your hands that took it away, this heavy sense of loss becomes a bond of trust I can bear with pride.\"",
          "confirm_mastectomy_plan": "\"Mm... Knowing the resection margins and fascial plane match our preoperative plan is the best reassurance. I have steadied myself now--please proceed with hemostasis, Dr. Sakaguchi.\""
        }
      },
      "ongoing_fear_default_01": {
        "prompt": "\"Dr. Sakaguchi... Lying behind the drape for so long, the room feels so quiet except for the monitor beeps and my own breathing... Could you spare a word for me?\"",
        "responses": {
          "reassure_ongoing": "\"Phew... Just hearing your steady voice carry across the drape dispels that lonely feeling of lying on an island by myself. Thank you, Dr. Sakaguchi.\"",
          "brief_ongoing": "\"Mm, even a brief word of confirmation is more than enough to settle my heart.\""
        }
      },
      "ongoing_default_01": {
        "prompt": "\"We must be well into the middle or latter half of the operation now, Dr. Sakaguchi. Are my breathing depth and muscle relaxation still giving you a clear deep field?\"",
        "responses": {
          "coach_ongoing": "\"Understood, I will make my inhalations half a beat shallower. Even when lying in the patient's place, the surgeon in me still wants full marks for cooperation.\"",
          "reassure_ongoing_default": "\"Hearing you praise my cooperation makes me even happier than being commended at morning rounds... Please keep focusing on the field, Dr. Sakaguchi.\""
        }
      },
      "ongoing_fear_fatigue_01": {
        "prompt": "\"Haa... It feels as though the long operation is slowly draining the strength from my limbs, and even staying focused takes effort now... Dr. Sakaguchi, could you tell me where we stand?\"",
        "responses": {
          "maintain_running_update": "\"Thank you for patiently walking me through each step... As long as my mind can follow the sound of your voice, I will not let myself slip into haze or panic.\"",
          "brief_running_update": "\"Mm... Knowing that everything is advancing steadily gives me the strength to grit my teeth a while longer.\""
        }
      },
      "ongoing_fear_fatigue_02": {
        "prompt": "\"My neck and shoulders ache terribly, and sweat is trickling down my temples into my surgical cap... Dr. Sakaguchi, how much longer until the next milestone...?\"",
        "responses": {
          "preview_next_milestone": "\"Once this set of anastomoses and hemostasis is finished, we move to closure...? Alright, with that clear target in sight, I will hold steady until we get there.\"",
          "encourage_next_milestone": "\"Thank you for the encouragement, Dr. Sakaguchi... When you put it like that, how could I possibly complain in front of my own surgical team?\""
        }
      },
      "ongoing_pain_position_01": {
        "prompt": "\"Ngh... Having my wrists and lower back strapped in the same position for so long is making them ache and tingle right along with the deep wound... Dr. Sakaguchi, I dare not shift, but my body is cramping...\"",
        "responses": {
          "adjust_pressure_points": "\"Phew... Thank you for having the circulating nurse adjust the padding angle under me. Easing that pressure on my lower back makes even the dull ache at the incision much more bearable.\"",
          "coach_position_stillness": "\"Understood... This is a critical moment for deep dissection, so my posture must not shift. I will use slow breathing to relax my back muscles--please continue without worry.\""
        }
      },
      "abdominal_ongoing_pressure_01": {
        "prompt": "\"Dr. Sakaguchi, the warm laparotomy pads packed inside my abdomen and the continuous retraction feel so full... It feels as if my belly is packed tight and pressing upward against my diaphragm...\"",
        "responses": {
          "explain_abdominal_pressure": "\"So those are the packing pads holding the small bowel loops away to keep the deep field clear... Knowing it is not intra-abdominal bleeding or distension sets my mind completely at ease.\"",
          "brief_abdominal_pressure": "\"Alright, I will bear with this sense of fullness a little longer and keep my abdominal wall relaxed.\""
        }
      },
      "pelvic_ongoing_position_01": {
        "prompt": "\"Staying in this steep Trendelenburg position with my legs parted for so long has blood rushing to my head while my lumbosacral spine aches... Dr. Sakaguchi, must this tilt be maintained much longer?\"",
        "responses": {
          "support_pelvic_position": "\"Thank you for reinforcing the shoulder braces and knee padding... That pulling strain across my pelvis and lower back feels much gentler now. I can keep going.\"",
          "coach_pelvic_position": "\"Mm... To let gravity draw the pelvic viscera cephalad, this tilt angle is essential. I will slow my breathing and adapt to it.\""
        }
      },
      "thoracic_ongoing_position_01": {
        "prompt": "\"The pressure of the lateral jackknife position under my ribs feels heavier by the minute, and the spread intercostal space is throbbing... Dr. Sakaguchi, is my upper torso leaning forward at all?\"",
        "responses": {
          "check_thoracic_support": "\"The axillary roll and pelvic straps have all been double-checked...? Good. With everyone supporting my posture, I do not have to worry about drifting out of alignment from fatigue.\"",
          "coach_thoracic_stillness": "\"Understood. When the chest is open, shifting even a centimeter changes the angle for long-handled instruments. I will keep my spine rock-steady, Dr. Sakaguchi.\""
        }
      },
      "cardiac_ongoing_fatigue_01": {
        "prompt": "\"Haa... Having my chest open through such a long, delicate procedure feels like it has spent nearly all the warmth in my body... Dr. Sakaguchi, is the core cardiac work nearly finished...?\"",
        "responses": {
          "reassure_cardiac_ongoing": "\"The main anastomoses and hemostasis are verified, and you are preparing to place the pericardial drains...? Phew, hearing those words truly feels like being given a second lease on life.\"",
          "brief_cardiac_ongoing": "\"Mm... The hardest stretch is behind us now. I will keep my spirit steady and stay with you all the way through sternal closure.\""
        }
      },
      "vascular_ongoing_pressure_01": {
        "prompt": "\"Dr. Sakaguchi, after the deep vascular clamp was released, I felt a warm pulse surge through the anastomosis, followed right away by the heavy pressure of gauze packing... Is everything holding well?\"",
        "responses": {
          "separate_vascular_sensations": "\"So that warm surge was distal perfusion returning, and the pressure is simply warm saline gauze tamponading needle-hole oozing... Hearing you break it down so clearly lifts the weight right off my chest.\"",
          "brief_vascular_pressure": "\"Alright. As long as the anastomosis is patent with no active leak, I can gladly endure this packing pressure.\""
        }
      },
      "closure_default_01": {
        "prompt": "\"I just heard the nurses begin the first sponge and needle count... Dr. Sakaguchi, have we officially entered layer-by-layer closure?\"",
        "responses": {
          "confirm_closure": "\"We really are closing the incision layer by layer now... Phew, when I stand as primary surgeon, hearing a correct count feels routine, yet lying behind the drape today, it sounds like music to my ears.\"",
          "brief_closure": "\"Mm, thank you for your tireless work, Dr. Sakaguchi. Through these final layers of suturing, I will lie still and cooperate down to the very last stitch.\""
        }
      },
      "closure_fear_closure_01": {
        "prompt": "\"Dr. Sakaguchi... Before you suture the deep tissue layers, have hemostasis and all final wound checks been thoroughly verified...? Now that we are at the final stretch, I find myself feeling strangely anxious...\"",
        "responses": {
          "confirm_closure_phase": "\"Clear saline irrigation and double-checked deep hemostasis and wound edges...? Forgive me--even though I trust your surgical skill above all else, lying here at closure made me ask one extra question. Now I can close my eyes in peace.\"",
          "brief_closure_phase": "\"...Mm, your word is all I need. I will stop overthinking and wait quietly as you suture.\""
        }
      },
      "closure_fear_closure_02": {
        "prompt": "\"I hear the instrument and sponge counts being called out one after another... Dr. Sakaguchi, have all the final closure checks passed without issue?\"",
        "responses": {
          "explain_final_checks": "\"All three counts of instruments, needles, and sponges match completely, and anatomical alignment and fascial tension are verified... Thank you for reporting the full checklist to me. Even the most demanding Deputy Chief of Surgery can rest one hundred percent assured now.\"",
          "confirm_final_checks": "\"Thank goodness... Hearing that everything is accounted for finally lets all the tension drain from my body.\""
        }
      },
      "closure_pain_closure_01": {
        "prompt": "\"Ngh...! Every time the needle holder drives that heavy suture through the deep fascia and pulls the knot tight, a sharp, aching tug shoots through the wound... Now that my stamina is spent, every stitch feels even sharper...\"",
        "responses": {
          "pause_closure_discomfort": "\"Haa... haa... Thank you for pausing two seconds after tying that knot... Fascial closure tension truly is unforgiving, but I have caught my breath now. Please place the next stitch, Dr. Sakaguchi.\"",
          "pace_closure_breathing": "\"Mm... I inhale as you drive the needle through, and exhale slowly as you draw the suture tight and tie... Alright, let us close the wound stitch by stitch together.\""
        }
      },
      "breast_closure_fear_01": {
        "prompt": "\"Dr. Sakaguchi, you are placing the final subcuticular sutures across my chest now, right...? It feels a little embarrassing to ask, but... are the skin edges coming together neatly?\"",
        "responses": {
          "answer_breast_closure": "\"Even skin apposition, balanced tension, and the finest atraumatic cosmetic suture...? Phew, no matter how composed I try to act, hearing how tenderly you are caring for my body fills my chest with a warm sweetness. Thank you, Dr. Sakaguchi.\"",
          "brief_breast_closure": "\"...Mm, as long as it is a wound closed by your own hands, I trust the result completely.\""
        }
      }
    }
  },
  "mischief_dialogue": {
    "zh_CN": {
      "reaction_variants": {
        "operative_positioning_unnecessary_lithotomy": [
          "「等、等一下，坂口医生……今天的手术入路明明不需要摆截石位吧？！把双腿架在支腿架上向两侧分开什么的……哪怕在场的都是自己的下属，这个姿势也实在太羞人了……！」",
          "「坂口医生，你确定这是为了方便术中导尿和会阴区无菌管理才摆的体位吗……？这、这样整个人毫无遮挡地朝向台尾，连脚踝都被固定住，我根本不知道该往哪里看才好了……」"
        ],
        "manual_catheter_press_bladder": [
          "「呀……唔っ！坂口医生，插完导尿管之后不用亲手按压耻骨上方排空也可以的……！手掌按下来的瞬间，残余的尿液不受控制地顺着管子涌出去的感觉……全都传到脑子里了……っ！」",
          "「唔啊……别、别再往下压小腹了……明明知道只是确认导尿管引流通畅，可被你按着膀胱一点点挤空的时候，身体还是羞耻得直发抖……」"
        ],
        "excessive_disinfection_breasts": [
          "「唔……っ！坂口医生，今天的术野消毒边界，是不是往上扩得太过了……？冰凉的碘伏纱布擦过乳晕和胸口前端的时候，身体会不受控制地轻轻战栗啊……」",
          "「连胸前最敏感的尖端都要反复涂刷两遍吗……？我、我知道无菌原则宁宽勿窄，可当着大家的面被擦得湿淋淋地挺立起来，实在太难为情了……」"
        ],
        "excessive_disinfection_perineum": [
          "「啊……唔っ！那、那里不是只有在盆腔或会阴入路时才需要重点涂刷的区域吗……？冰冷的消毒棉球直接拭过软肉褶皱的时候，腰都差点软掉了……坂口医生……！」",
          "「哈啊……连大腿根和最私密的缝隙都被碘伏浸透了……明明是严肃的术前消毒，可被你的器械夹着棉球一下下擦过那里，我的耳根已经烫得快要烧起来了……」"
        ],
        "skip_sterile_draping": [
          "「……坂口医生？！不铺设无菌洞巾、就这样让我浑身赤裸地直接暴露在无影灯下开刀吗？！虽、虽然全身都已经刷过碘伏了，可一点遮挡都没有的话，大家的视线……唔……！」",
          "「平时我在台上最强调标准铺巾，没想到轮到自己躺上来，竟然会被省略掉所有遮羞的布单……既然我已经答应在台上完全服从主刀，那我就闭上眼，任凭你处置吧……」"
        ],
        "slow_incision_trace": [
          "「唔……坂口医生，你的记号笔和指腹沿着预定切口线滑得太慢了……一寸一寸摩挲着刚刚消毒完的皮肤，像是在确认待会儿从哪里把我的身体剖开一样，心跳快得要停不下来了……」",
          "「哈啊……笔尖每停顿一下，我肚皮上的肌肉就跟着轻轻抽紧一下……坂口医生，求你别再用这种磨人的速度描摹切口了，一鼓作气画完吧……」"
        ],
        "incision_public_lecture": [
          "「坂口医生……！拿我赤裸的胸腹体表标志当场给年轻医护做切口解剖教学什么的……听到大家随着你的指点一起低头端详我的皮肤，身为副部长的威严都要荡然无存了……」",
          "「『注意观察肋弓角、腹白线与皮纹走向』……平时都是我指着教材说这句话，今天自己却成了躺在台上的活体示范标本……只、只要对大家的成长有帮助，我就忍着羞耻不乱动……」"
        ],
        "postop_bare_sponge_wipe": [
          "「呼……哈啊……刚缝合完就把无菌单全部掀开、直接用温盐水纱布替我擦洗全身吗……？温热的湿纱布拭过还带着干涸碘伏与冷汗的胸口和小腹，又痒又让人使不上力气……」",
          "「唔……谢谢你亲手帮我把皮肤上的血迹和消毒液擦干净，坂口医生……只是刚经历完一整台手术，现在连指尖都软绵绵的，被你这样寸寸擦拭着赤裸的身体，实在有点招架不住呢……」"
        ],
        "postop_bare_full_inspection": [
          "「坂口医生……切口敷料不是已经贴好了吗，为什么还要从锁骨、胸前一直到小腹和双腿做全身体表复查呀……？在这么亮的灯光下被你从头到脚看个遍，比刚才挨刀还要让人脸红……」",
          "「确认全身皮肤有无压红、电刀灼伤与导尿管固定状态……道理确实完全合乎术后护理规范，可迎着你这么专注的目光一丝不挂地躺着，我还是会害羞得想抓紧床单呀，坂口医生。」"
        ]
      },
      "team_overrides": {
        "nurse_hiroko": {
          "nurse_verify_catheter_drainage": "「引流袋内见清亮尿液流出，导尿管球囊固定稳妥。——阿尔托莉雅医生，请放轻松，我们大家都只盯着医疗指标，不会乱看的。」",
          "ack_disinfection_drying": "「扩大消毒区域的碘伏薄膜已经自然待干完毕。阿尔托莉雅医生连当患者配合准备的时候都这么端正，真让人佩服呢。」",
          "ack_incision_nurse_commentary": "「切口体表定位非常清晰。坂口医生，圆刀和双极电凝都已经备在手边，随时可以下刀。」",
          "ack_postop_nurse_commentary": "「全身皮肤温盐水清洁与受压点复查全部完成，无压疮及灼伤。我这就替副部长盖上加温毛毯。」"
        },
        "nurse_ange": {
          "nurse_verify_catheter_drainage": "「报告坂口医生，导尿管引流完全通畅，残余尿已排空！那、那个，阿尔托莉雅医生，您的呼吸很平稳，请不用觉得难为情！」",
          "ack_disinfection_drying": "「全范围碘伏涂刷已满规定时间，无菌边界核查满分！我、我的视线一直严格停留在标准无菌区内，请副部长放心！」",
          "ack_incision_nurse_commentary": "「坂口医生刚才结合阿尔托莉雅医生体表标志讲解的切口层次，我已经全部记在脑子里了！器械核对无误，随时可以切皮！」",
          "ack_postop_nurse_commentary": "「术后体表擦洗与引流管固定核查完毕！阿尔托莉雅医生今天在台上真的太坚强了，请好好休息！」"
        },
        "nurse_moe": {
          "nurse_verify_catheter_drainage": "「引、引流很顺畅，尿袋已经挂好固定了……阿尔托莉雅医生，您抓着托手架的手心里全是汗，我帮您把额角的汗擦一擦吧……」",
          "ack_disinfection_drying": "「消毒液已经干透了……那个，要是觉得空调风吹在身上太凉的话，阿尔托莉雅医生随时眨眨眼告诉我哦。」",
          "ack_incision_nurse_commentary": "「看到记号笔在阿尔托莉雅医生身上画线，连我都跟着紧张得屏住呼吸了……坂口医生，监护仪数值一切稳定！」",
          "ack_postop_nurse_commentary": "「温盐水纱布已经把身上的碘伏都擦干净了，切口也贴得整整齐齐的……阿尔托莉雅医生，辛苦您了，我马上帮您把被单盖好！」"
        }
      }
    },
    "en": {
      "reaction_variants": {
        "operative_positioning_unnecessary_lithotomy": [
          "\"W-wait a moment, Dr. Sakaguchi... Today's surgical approach does not require the lithotomy position, does it?! Having my legs raised in stirrups and parted wide like this... even in front of my own staff, this posture is far too mortifying...!\"",
          "\"Dr. Sakaguchi, are you certain this positioning is strictly for intraoperative catheter access and perineal sterile management...? L-lying completely uncovered facing the foot of the table with my ankles strapped leaves me nowhere to rest my eyes...\""
        ],
        "manual_catheter_press_bladder": [
          "\"Ah... ngh! Dr. Sakaguchi, there is no need to manually press above my pubis to empty my bladder after placing the catheter...! The instant your palm pressed down, feeling the residual urine forced out through the tube... sent a shiver straight to my head...!\"",
          "\"Ugh... p-please do not press down on my lower abdomen any harder... I know it is only to verify catheter patency, yet having you press my bladder empty bit by bit makes my whole body tremble with shame...\""
        ],
        "excessive_disinfection_breasts": [
          "\"Mm...! Dr. Sakaguchi, has the upper boundary of today's skin prep not been extended a little too far...? When the cold iodine sponge brushes across my areolae and chest, my body shivers against my will...\"",
          "\"Must even the most sensitive tips of my breasts be swabbed twice over...? I-I know sterile margins err on the side of caution, yet having them brushed wet and stiffening in front of everyone is terribly embarrassing...\""
        ],
        "excessive_disinfection_perineum": [
          "\"Ah... ngh! I-is that area not normally reserved for pelvic or perineal approaches...? Having the icy antiseptic sponge wipe directly across those delicate folds nearly made my waist give out... Dr. Sakaguchi...!\"",
          "\"Haa... Even my inner thighs and most private crease are soaked in povidone-iodine now... I know this is formal preoperative disinfection, yet feeling your sponge forceps stroke across there has my ears burning like fire...\""
        ],
        "skip_sterile_draping": [
          "\"...Dr. Sakaguchi?! Are you truly going to operate without laying sterile drapes, leaving me completely bare under the shadowless lamp?! E-even if my whole body has been prepped with iodine, having no cover at all in front of everyone's eyes... ngh...!\"",
          "\"When I stand as primary surgeon, I always insist on strict draping, yet now that I am on the table myself, every last cloth covering my modesty has been omitted... Since I promised to obey the primary surgeon completely, I will close my eyes and place myself at your mercy...\""
        ],
        "slow_incision_trace": [
          "\"Mm... Dr. Sakaguchi, your marker tip and fingertips are gliding far too slowly along the planned incision line... Tracing inch by inch over my freshly prepped skin as if deciding where to open me up makes my heart race out of control...\"",
          "\"Haa... Every time the marker tip pauses, the muscles across my abdomen twitch tightly in response... Dr. Sakaguchi, please do not tease the incision line at such a deliberate pace--draw it in one clean stroke...\""
        ],
        "incision_public_lecture": [
          "\"Dr. Sakaguchi...! Using my bare chest and abdomen as a live teaching aid to lecture the junior staff on incision landmarks... Hearing everyone lean in to study my skin at your pointer leaves my dignity as Deputy Chief in tatters...\"",
          "\"'Note the costal angle, linea alba, and Langer's lines'... I am usually the one pointing at the textbook to say those words, yet today I am the live specimen lying bare on the table... A-as long as it helps everyone learn, I will endure the embarrassment and hold still...\""
        ],
        "postop_bare_sponge_wipe": [
          "\"Phew... haa... Removing all the sterile drapes right after suturing to wipe down my entire body with warm saline gauze...? Feeling the warm wet sponge glide over my chest and abdomen while my stamina is spent feels both ticklish and overwhelming...\"",
          "\"Mm... Thank you for personally wiping the blood and dried iodine from my skin, Dr. Sakaguchi... Having just come through an entire operation, I barely have strength in my fingertips, so being wiped down inch by inch while completely bare leaves me helpless...\""
        ],
        "postop_bare_full_inspection": [
          "\"Dr. Sakaguchi... The wound dressing is already in place, so why must you conduct a full-body surface inspection from my collarbones and breasts all the way down to my abdomen and thighs...? Being examined from head to toe under such bright lights makes me blush harder than the incision itself...\"",
          "\"Checking for pressure erythema, cautery marks, and catheter fixation... The clinical rationale truly follows postoperative nursing standards, yet lying stark naked under your focused gaze still makes me want to clutch the bedsheet, Dr. Sakaguchi.\""
        ]
      },
      "team_overrides": {
        "nurse_hiroko": {
          "nurse_verify_catheter_drainage": "\"Clear urine return confirmed in the drainage bag, and the catheter balloon is securely seated. --Dr. Artoria, please relax; all of us are looking strictly at the clinical indicators.\"",
          "ack_disinfection_drying": "\"The povidone-iodine film across the extended prep field has dried completely. Even as a patient undergoing preparation, Dr. Artoria's composure is truly admirable.\"",
          "ack_incision_nurse_commentary": "\"The surface landmarks for the incision are clearly defined. Dr. Sakaguchi, both the scalpel and bipolar forceps are ready at your hand whenever you wish to begin.\"",
          "ack_postop_nurse_commentary": "\"Full-body warm saline cleansing and pressure-point inspection are complete with no erythema or burns. I will cover the Deputy Chief with a warmed blanket right away.\""
        },
        "nurse_ange": {
          "nurse_verify_catheter_drainage": "\"Reporting to Dr. Sakaguchi: urinary catheter drainage is completely patent and residual urine is emptied! U-um, Dr. Artoria, your breathing is very steady, so please do not feel embarrassed!\"",
          "ack_disinfection_drying": "\"Full-field povidone-iodine prep has reached the required drying time, and sterile boundaries are verified! M-my eyes have remained strictly within the designated sterile zone, Dr. Artoria!\"",
          "ack_incision_nurse_commentary": "\"I have committed every word of Dr. Sakaguchi's landmark demonstration on Dr. Artoria's skin to memory! Instrument count verified--ready for skin incision at any time!\"",
          "ack_postop_nurse_commentary": "\"Postoperative skin cleansing and drain fixation check complete! Dr. Artoria was truly incredible on the table today--please rest well!\""
        },
        "nurse_moe": {
          "nurse_verify_catheter_drainage": "\"D-drainage is flowing smoothly, and the collection bag is hung and secured... Dr. Artoria, your palms gripping the armboards are covered in sweat--let me wipe your forehead for you...\"",
          "ack_disinfection_drying": "\"The antiseptic solution has dried completely... Um, if the operating room air feels too chilly against your skin, just blink and let me know anytime, Dr. Artoria.\"",
          "ack_incision_nurse_commentary": "\"Watching the marker line drawn across Dr. Artoria's skin made even me hold my breath in nervous anticipation... Dr. Sakaguchi, all monitor vitals are completely stable!\"",
          "ack_postop_nurse_commentary": "\"The warm saline gauze has wiped away all the iodine, and the dressing is applied neatly... Thank you for your endurance today, Dr. Artoria--I will pull the warm sheet over you right now!\""
        }
      }
    }
  }
}
```
