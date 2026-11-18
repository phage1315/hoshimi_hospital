# 阿尔托莉雅·潘德拉贡 (`doc_artoria`) `pack_v2` — Lv0–Lv4 事件高光关键句与自宅 H Runner 全套语音包归档

- **复用定稿 Voice ID**：`voice_6af60fb85ba48191b620c1cc5932552e`（[`../voice.json`](../voice.json)，零新建声线）
- **渲染入口**：`tools/voice_runner/hoshimi-voice run`（`gpt-live-1`，24kHz 单声道 16-bit PCM WAV，仅修剪首尾静音，无变速／变调／后期滤波）
- **涵盖内容（共 53 条）**：
  1. 人物档案与周日约会／自宅邀约补全（4 条）：`shy.wav`（覆盖 `shy`/`embarrassed`/`serious_blush` 细粒度微赧槽位）、`date_restaurant.wav`、`date_ski.wav`（两处周日偏好约会满意结算）、`free_h_accept.wav`（日间自宅红茶邀约答应）；
  2. Lv0 初识 → Lv1《谁站在哪个位置》→ Lv2《留下来的部分》→ Lv3《不是一个人的手术》→ Lv4《只是阿尔托莉雅》关键剧情转折与全部阿尔托莉雅发声 CG 节点（22 条，通过 `data/audio/event_voice_cues.json` 零侵入挂载，不改剧本 JSON）；
  3. 自宅 H Runner 全流程（27 条，同时驱动 Lv4 第五幕首次自宅 H 与日常可重复自宅 Free H）：4 句自宅进场词 1:1 全覆盖（`h_entry_1..4`）、前戏四档各 2 条、满兴奋提示 1 条、`gentle`/`intense` 开场与中段、二阶段递进、四向高潮完成全开喉尖叫 4 条（`h_finish_1..4`）及日常事后 2 条。

| Clip ID | 运行资源路径 | 绑定目标 | 日语台词 | 选用 Take | 时长 | 中位 F0 | 峰值 |
|---|---|---|---|---|---|---|---|
| `doc_artoria_shy` | `assets/audio/voice/doc_artoria/shy.wav` | `staff_expression:shy` | ……べ、別に照れているわけではありません。少し不意を突かれただけです。 | `take1` | 5.68s | 219.7Hz | -11.1 dBFS |
| `doc_artoria_date_restaurant` | `assets/audio/voice/doc_artoria/date_restaurant.wav` | `favorite_date:doc_artoria/restaurant_bar` | とても口に合いました。時間に追われず、温かい料理を味わえるのは……贅沢なことですね。 | `take1` | 8.32s | 234.4Hz | -9.7 dBFS |
| `doc_artoria_date_ski` | `assets/audio/voice/doc_artoria/date_ski.wav` | `favorite_date:doc_artoria/winter_ski_resort` | 下までの競争ですか? 受けて立ちます。安全確認を終えたら、手加減は期待しないでくださいね。 | `take1` | 8.02s | 216.8Hz | -12.9 dBFS |
| `doc_artoria_free_h_accept` | `assets/audio/voice/doc_artoria/free_h_accept.wav` | `free_h_response:doc_artoria` | ……今夜は当直はありません。仕事の後、もしよければ私の家へ来てください、坂口先生……紅茶を淹れて待っています。 | `take1` | 12.10s | 210.9Hz | -11.5 dBFS |
| `doc_artoria_ev_lv0_greeting` | `assets/audio/voice/doc_artoria/events/ev_lv0_greeting.wav` | `intro_doc_artoria_deputy_office/formal_greeting` | 坂口隆司先生、星見病院へようこそ。私はアルトリア・ペンドラゴン、外科副部長です。 | `take1` | 7.88s | 222.7Hz | -12.4 dBFS |
| `doc_artoria_ev_lv0_judgment` | `assets/audio/voice/doc_artoria/events/ev_lv0_judgment.wav` | `intro_doc_artoria_deputy_office/welcome` | 結構です。その時は、あなたの判断を率直に聞かせてください、坂口先生。 | `take1` | 7.66s | 234.4Hz | -11.5 dBFS |
| `doc_artoria_ev_lv1_work_together` | `assets/audio/voice/doc_artoria/events/ev_lv1_work_together.wav` | `artoria_lv1_right_position/leadership_question` | 腕のいい医師は大勢います。私が知りたいのは、彼らがあなたと共に働きたいと思えるかどうかです。 | `take2` | 9.57s | 234.4Hz | -10.3 dBFS |
| `doc_artoria_ev_lv1_responsibility` | `assets/audio/voice/doc_artoria/events/ev_lv1_responsibility.wav` | `artoria_lv1_right_position/introduction` | 結果の責任は、配置を決めた者が負います。坂口先生、これからもあなたの判断を見せてください。 | `take1` | 7.81s | 228.5Hz | -14.3 dBFS |
| `doc_artoria_ev_lv2_what_remains` | `assets/audio/voice/doc_artoria/events/ev_lv2_what_remains.wav` | `artoria_lv2_what_remains/ar2_s1_22` | 残される部分もまた、この手術で必ず守り抜くべきものなのです。 | `take2` | 5.64s | 246.1Hz | -8.6 dBFS |
| `doc_artoria_ev_lv2_route_goal` | `assets/audio/voice/doc_artoria/events/ev_lv2_route_goal.wav` | `artoria_lv2_what_remains/ar2_s4_20` | 進路は調整できても、手術の目標は変えられません。 | `take2` | 4.60s | 222.7Hz | -14.1 dBFS |
| `doc_artoria_ev_lv2_reliable_partner` | `assets/audio/voice/doc_artoria/events/ev_lv2_reliable_partner.wav` | `artoria_lv2_what_remains/ar2_s5_19` | お互い様です。あなたのように頼もしい相棒が向かいにいてくれると、執刀医もずっと心強いですよ。 | `take1` | 9.05s | 275.4Hz | -12.4 dBFS |
| `doc_artoria_ev_lv2_no_contradiction` | `assets/audio/voice/doc_artoria/events/ev_lv2_no_contradiction.wav` | `artoria_lv2_what_remains/ar2_s5_31` | ……その二つは、別段矛盾しません。 | `take1` | 3.44s | 228.5Hz | -19.4 dBFS |
| `doc_artoria_ev_lv3_trusted_companions` | `assets/audio/voice/doc_artoria/events/ev_lv3_trusted_companions.wav` | `artoria_lv3_not_a_solo_operation/ar3_s3_1_14` | ええ。彼女たちは皆、私が心から信頼している仲間です。 | `take1` | 4.64s | 240.2Hz | -12.5 dBFS |
| `doc_artoria_ev_lv3_moe_key_catch` | `assets/audio/voice/doc_artoria/events/ev_lv3_moe_key_catch.wav` | `artoria_lv3_not_a_solo_operation/ar3_s3_2r_15` | 確認しました、萌恵、重要な気づきです！ 一旦進めるのを止め、出血点を確実に縫合止血します！ | `take1` | 8.18s | 287.1Hz | -9.5 dBFS |
| `doc_artoria_ev_lv3_leader_serves` | `assets/audio/voice/doc_artoria/events/ev_lv3_leader_serves.wav` | `artoria_lv3_not_a_solo_operation/ar3_s5_07` | 導く者とは、仲間に仕える者でもあります。皆が安心して力を尽くせる場を守ることこそ、私の務めです。 | `take1` | 9.77s | 205.1Hz | -13.1 dBFS |
| `doc_artoria_ev_lv3_dizzy_apology` | `assets/audio/voice/doc_artoria/events/ev_lv3_dizzy_apology.wav` | `artoria_lv3_not_a_solo_operation/ar3_s5_19` | ……失礼しました。大丈夫です、坂口先生……立ち上がった拍子に、少し目眩がしただけですから…… | `take1` | 14.24s | 216.8Hz | -11.1 dBFS |
| `doc_artoria_ev_lv3_extra_sandwich` | `assets/audio/voice/doc_artoria/events/ev_lv3_extra_sandwich.wav` | `artoria_lv3_not_a_solo_operation/ar3_s5r_10` | ……あの、アンジェ。もし売店にまだ残っていたら……先ほどのメンチカツサンドを、もう一つお願いできますか? | `take2` | 8.49s | 228.5Hz | -12.2 dBFS |
| `doc_artoria_ev_lv4_croquette_courtesy` | `assets/audio/voice/doc_artoria/events/ev_lv4_croquette_courtesy.wav` | `artoria_lv4_just_artoria/ar4_s2_23` | ……火加減も絶妙で、本当に美味しいです。心を込めた料理を真剣に味わうのは、料理人への礼儀ですから。 | `take1` | 11.96s | 216.8Hz | -12.5 dBFS |
| `doc_artoria_ev_lv4_dont_end_today` | `assets/audio/voice/doc_artoria/events/ev_lv4_dont_end_today.wav` | `artoria_lv4_just_artoria/ar4_s4_19` | まだ、この角であなたとお別れしたくありません。……今日が、こんなに早く終わってほしくないのです。 | `take1` | 13.05s | 228.5Hz | -12.9 dBFS |
| `doc_artoria_ev_lv4_come_home` | `assets/audio/voice/doc_artoria/events/ev_lv4_come_home.wav` | `artoria_lv4_just_artoria/ar4_s4m_06` | 特別なもてなしはできませんが……もしよろしければ、今夜……私の家へいらっしゃいませんか? | `take1` | 8.17s | 269.5Hz | -12.7 dBFS |
| `doc_artoria_ev_lv4_just_artoria` | `assets/audio/voice/doc_artoria/events/ev_lv4_just_artoria.wav` | `artoria_lv4_just_artoria/ar4_s5_1_14` | 今夜ここにいるのは、外科副部長などではありません……ただの、アルトリアです。 | `take2` | 8.08s | 234.4Hz | -10.8 dBFS |
| `doc_artoria_ev_lv4_call_sakaguchi_kun` | `assets/audio/voice/doc_artoria/events/ev_lv4_call_sakaguchi_kun.wav` | `artoria_lv4_just_artoria/ar4_s5_1_16` | ですから、ここにいる時は……先生ではなく、坂口くんとお呼びしてもいいですか? | `take2` | 7.27s | 210.9Hz | -10.4 dBFS |
| `doc_artoria_ev_lv4_closer_tonight` | `assets/audio/voice/doc_artoria/events/ev_lv4_closer_tonight.wav` | `artoria_lv4_just_artoria/ar4_s5_1_23` | あなたと一緒にいるのが好きだから……今夜は、坂口くんともっと近くで触れ合いたいのです。 | `take1` | 8.05s | 263.7Hz | -9.4 dBFS |
| `doc_artoria_ev_lv4_goodnight` | `assets/audio/voice/doc_artoria/events/ev_lv4_goodnight.wav` | `artoria_lv4_just_artoria/ar4_s5_2_11` | 今夜は目覚ましをかけなくて大丈夫です……おやすみなさい、坂口くん。 | `take1` | 6.24s | 210.9Hz | -15.0 dBFS |
| `doc_artoria_ev_lv4_kitchen_safe` | `assets/audio/voice/doc_artoria/events/ev_lv4_kitchen_safe.wav` | `artoria_lv4_just_artoria/ar4_s6_1_13` | ……おはようございます、坂口くん。起こしてしまいましたか? 火元と電源はすべて切りました。現場は完全に安全です。 | `take2` | 15.68s | 228.5Hz | -11.4 dBFS |
| `doc_artoria_ev_lv4_savor_breakfast` | `assets/audio/voice/doc_artoria/events/ev_lv4_savor_breakfast.wav` | `artoria_lv4_just_artoria/ar4_s6_2m_09` | ……ええ。少なくとも今朝だけは、他のことは忘れて、坂口くんが作ってくれた朝食をゆっくり味わいたいです。 | `take2` | 9.55s | 210.9Hz | -11.7 dBFS |
| `doc_artoria_h_entry_1` | `assets/audio/voice/doc_artoria/h/h_entry_1.wav` | `h_runner.doc_artoria:entry[0]` | ……鍵はかけました。この扉の向こうに副部長はいません……こちらへ座ってください、坂口くん。 | `take2` | 9.26s | 252.0Hz | -11.5 dBFS |
| `doc_artoria_h_entry_2` | `assets/audio/voice/doc_artoria/h/h_entry_2.wav` | `h_runner.doc_artoria:entry[1]` | 紅茶が淹れたてですよ。ただ……その目を見ると、先に別のことをしたいみたいですね、坂口くん。 | `take2` | 8.41s | 269.5Hz | -11.5 dBFS |
| `doc_artoria_h_entry_3` | `assets/audio/voice/doc_artoria/h/h_entry_3.wav` | `h_runner.doc_artoria:entry[2]` | ……リボンを解くと、構えまで一緒にほどける気がします。今夜もよろしくお願いしますね、坂口くん。 | `take2` | 6.09s | 216.8Hz | -11.3 dBFS |
| `doc_artoria_h_entry_4` | `assets/audio/voice/doc_artoria/h/h_entry_4.wav` | `h_runner.doc_artoria:entry[3]` | 病院で一日中働いたあと、ここであなたに寄り添う時だけ、心が本当に静かになります。 | `take1` | 7.56s | 210.9Hz | -14.8 dBFS |
| `doc_artoria_h_tier_low_1` | `assets/audio/voice/doc_artoria/h/h_tier_low_1.wav` | `h_runner.doc_artoria:low[0]` | ……坂口くん、そんな触れ方では少しくすぐったくて、どう応えればいいか困ってしまいます。 | `take1` | 6.95s | 228.5Hz | -14.4 dBFS |
| `doc_artoria_h_tier_low_2` | `assets/audio/voice/doc_artoria/h/h_tier_low_2.wav` | `h_runner.doc_artoria:low[1]` | んっ……からかうおつもりなら、少しだけ手加減してくださいね、坂口くん。 | `take1` | 6.08s | 228.5Hz | -12.8 dBFS |
| `doc_artoria_h_tier_mild_1` | `assets/audio/voice/doc_artoria/h/h_tier_mild_1.wav` | `h_runner.doc_artoria:mild[0]` | ……ん。とても優しい温度で、張り詰めていた肩の力が少しずつ抜けていきます。 | `take2` | 8.96s | 240.2Hz | -11.0 dBFS |
| `doc_artoria_h_tier_mild_2` | `assets/audio/voice/doc_artoria/h/h_tier_mild_2.wav` | `h_runner.doc_artoria:mild[1]` | そんなに丁寧に触れられると……なんだか照れてしまいますね、坂口くん。 | `take1` | 6.62s | 205.1Hz | -9.2 dBFS |
| `doc_artoria_h_tier_strong_1` | `assets/audio/voice/doc_artoria/h/h_tier_strong_1.wav` | `h_runner.doc_artoria:strong[0]` | んっ……はあっ、坂口くん……息が一気に乱れてしまって、少し待ってください……！ | `take1` | 7.63s | 252.0Hz | -9.0 dBFS |
| `doc_artoria_h_tier_strong_2` | `assets/audio/voice/doc_artoria/h/h_tier_strong_2.wav` | `h_runner.doc_artoria:strong[1]` | はあっ……そんなにじっと顔を見ないでください……今の表情は、きっとすごく乱れています……！ | `take1` | 7.45s | 293.0Hz | -10.8 dBFS |
| `doc_artoria_h_tier_favorite_1` | `assets/audio/voice/doc_artoria/h/h_tier_favorite_1.wav` | `h_runner.doc_artoria:favorite[0]` | はあっ……ああっ！ 坂口くんにそこを触れられると、考える力までなくなってしまいますっ……！ | `take2` | 7.19s | 275.4Hz | -12.2 dBFS |
| `doc_artoria_h_tier_favorite_2` | `assets/audio/voice/doc_artoria/h/h_tier_favorite_2.wav` | `h_runner.doc_artoria:favorite[1]` | んああっ！！ ず、ずるいです……あなたにだけは、どうしても防備を残せませんっ……！ | `take1` | 9.81s | 339.8Hz | -11.8 dBFS |
| `doc_artoria_h_max_prompt` | `assets/audio/voice/doc_artoria/h/h_max_prompt.wav` | `h_runner.doc_artoria:max_prompt` | はあっ……坂口くん……私はもう大丈夫です。今夜は遠慮なんていりませんから……どうか、抱いてください。 | `take1` | 9.45s | 246.1Hz | -12.8 dBFS |
| `doc_artoria_h_open_gentle` | `assets/audio/voice/doc_artoria/h/h_open_gentle.wav` | `h_runner.doc_artoria:openings.gentle` | んっ……指を絡めた温もりがとても安心します……この部屋では、すべてを坂口くんに委ねられます…… | `take1` | 8.88s | 210.9Hz | -13.0 dBFS |
| `doc_artoria_h_open_intense` | `assets/audio/voice/doc_artoria/h/h_open_intense.wav` | `h_runner.doc_artoria:openings.intense` | あああっ！！ い、いきなりこんなに深く抱きしめられて……普段の抑えが、全部ほどけてしまいますっ！！ | `take1` | 12.03s | 316.4Hz | -12.8 dBFS |
| `doc_artoria_h_stage_start_1` | `assets/audio/voice/doc_artoria/h/h_stage_start_1.wav` | `h_runner.doc_artoria:stage_start[0]` | んっ……はあっ……ほどいた髪が枕に広がって……もっと強く抱きしめてください、坂口くん…… | `take1` | 7.64s | 228.5Hz | -12.5 dBFS |
| `doc_artoria_h_stage_start_2` | `assets/audio/voice/doc_artoria/h/h_stage_start_2.wav` | `h_runner.doc_artoria:stage_start[1]` | はあっ……役目も何も忘れて、ただのアルトリアとしてあなたに抱かれるなんて……不思議な気持ちです…… | `take1` | 8.14s | 222.7Hz | -13.4 dBFS |
| `doc_artoria_h_stage_mid_1` | `assets/audio/voice/doc_artoria/h/h_stage_mid_1.wav` | `h_runner.doc_artoria:midpoints.gentle` | はあっ……坂口くん……言葉はいりませんから、このまま少しの隙間もないくらい、強く抱きしめていて…… | `take1` | 9.00s | 298.8Hz | -12.3 dBFS |
| `doc_artoria_h_mid_intense` | `assets/audio/voice/doc_artoria/h/h_mid_intense.wav` | `h_runner.doc_artoria:midpoints.intense` | ああああっ！！ ふ、深すぎます、坂口くんっ……あなたの波にさらわれて、もう力が入りませんっ！！ | `take1` | 9.87s | 334.0Hz | -9.8 dBFS |
| `doc_artoria_h_stage_build_1` | `assets/audio/voice/doc_artoria/h/h_stage_build_1.wav` | `h_runner.doc_artoria:stage_build` | やあああっ！！ も、もう声を抑えられませんっ……背中を強く掴んでもいいですか、坂口くんっ！！ | `take1` | 9.85s | 316.4Hz | -7.3 dBFS |
| `doc_artoria_h_stage_near_1` | `assets/audio/voice/doc_artoria/h/h_stage_near_1.wav` | `h_runner.doc_artoria:stage_near` | きゃあああっ！！ わ、私の目を見ていてください、坂口くんっ……今のあなたを、はっきり焼き付けたいからっ！！ | `take1` | 5.35s | 354.5Hz | -12.3 dBFS |
| `doc_artoria_h_finish_1` | `assets/audio/voice/doc_artoria/h/h_finish_1.wav` | `h_runner.doc_artoria:finish[0]` | あああああっ！！ 坂口くんっ……一緒に……あああっ！！ | `take1` | 4.89s | 334.0Hz | -5.5 dBFS |
| `doc_artoria_h_finish_2` | `assets/audio/voice/doc_artoria/h/h_finish_2.wav` | `h_runner.doc_artoria:finish[1]` | はああああっ！！ も、もうだめっ……頭が真っ白に……抱きしめて、坂口くんっ！！ | `take2` | 9.79s | 345.7Hz | -9.2 dBFS |
| `doc_artoria_h_finish_3` | `assets/audio/voice/doc_artoria/h/h_finish_3.wav` | `h_runner.doc_artoria:finish[2]` | きゃあああああっ！！ む、胸の奥まで熱くて震えるっ……あああっ！！ | `take1` | 6.19s | 351.6Hz | -11.0 dBFS |
| `doc_artoria_h_finish_4` | `assets/audio/voice/doc_artoria/h/h_finish_4.wav` | `h_runner.doc_artoria:finish[3]` | あああああっ！！ て、手を握っていて、坂口くんっ……もう支えられないっ！！ | `take1` | 6.16s | 351.6Hz | -9.3 dBFS |
| `doc_artoria_h_aftercare_1` | `assets/audio/voice/doc_artoria/h/h_aftercare_1.wav` | `h_runner.doc_artoria:aftercare[0]` | ……ふぅ。坂口くんにこうして抱きしめられると、全身の力が抜けたみたいです……でも、心はとても穏やかです。 | `take1` | 11.08s | 240.2Hz | -11.3 dBFS |
| `doc_artoria_h_aftercare_2` | `assets/audio/voice/doc_artoria/h/h_aftercare_2.wav` | `h_runner.doc_artoria:aftercare[1]` | 少し休んだら、紅茶を淹れて夜食でも作りませんか? ……こほん、消費した分を補うのは正当なことです。 | `take1` | 9.00s | 234.4Hz | -12.1 dBFS |
