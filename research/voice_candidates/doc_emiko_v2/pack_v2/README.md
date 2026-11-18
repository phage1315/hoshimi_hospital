# 御堂 江美子 (`doc_emiko`) `pack_v2` — Lv0–Lv4 事件高光关键句与 H Runner 专属全套语音包归档

- **复用定稿 Voice ID**：`voice_6af619a5457c8191956e57ae510364fb`（[`../voice.json`](../voice.json)，零新建声线）
- **渲染入口**：`tools/voice_runner/hoshimi-voice run`（`gpt-live-1`，24kHz 单声道 16-bit PCM WAV，仅修剪首尾静音，无变速／变调／后期滤波）
- **涵盖内容（共 41 条）**：
  1. 补齐自由 H 白天手术室邀约答应语音 `free_h_accept.wav`（1 条）；
  2. 接入 Lv0《传闻中的手》→ Lv1《她的手术》→ Lv2《这一次听你的》→ Lv3《今天我主刀》→ Lv4《御堂江美子的秘密》共 **15 句** CG／剧情关键转折台词（通过 `data/audio/event_voice_cues.json` 零侵入挂载，不改任何剧本 JSON）；
  3. 完整覆盖御堂手术室 H Runner（同时驱动 Lv4 第六幕首次手术台 H 与日常可重复四楼手术室 Free H）全部 **25 条**专属语音（入场 2 条、前戏四档各 2 条、满兴奋提示 1 条、`gentle`/`intense` 开场 2 条、二阶段递进 6 条、四向高潮完成全开喉尖叫 4 条、日常事后 2 条）。

| Clip ID | 运行资源路径 | 绑定目标 | 日语台词 | 选用 Take | 时长 | 中位 F0 | 峰值 |
|---|---|---|---|---|---|---|---|
| `doc_emiko_ev_lv0_test_hands` | `assets/audio/voice/doc_emiko/events/ev_lv0_test_hands.wav` | `emiko_intro_rumored_hands/em0_040` | 噂のその手が、覚える価値のあるものかどうか……オペ台で見せてもらうわ。 | `take1` | 7.27s | 193.4Hz | -2.9 dBFS |
| `doc_emiko_ev_lv1_like_surgery` | `assets/audio/voice/doc_emiko/events/ev_lv1_like_surgery.wav` | `emiko_lv1_first_operation/em1_202` | ……私はただ、オペが好きなだけよ。 | `take1` | 2.70s | 205.1Hz | -7.6 dBFS |
| `doc_emiko_ev_lv1_not_wasted` | `assets/audio/voice/doc_emiko/events/ev_lv1_not_wasted.wav` | `emiko_lv1_first_operation/em1_204` | もう行っていいわ、坂口先生。今日の第一助手……時間の無駄ではなかったわね。 | `take1` | 6.77s | 228.5Hz | -4.4 dBFS |
| `doc_emiko_ev_lv2_roster_open` | `assets/audio/voice/doc_emiko/events/ev_lv2_roster_open.wav` | `emiko_lv2_follow_my_lead/em2_244` | これからの予定表……私の名前を、わざわざ避けなくていいわ。 | `take1` | 5.44s | 240.2Hz | -1.9 dBFS |
| `doc_emiko_ev_lv2_your_limit` | `assets/audio/voice/doc_emiko/events/ev_lv2_your_limit.wav` | `emiko_lv2_follow_my_lead/em2_251` | 勘違いしないで。今日があなたの限界かどうか、確かめたいだけよ。 | `take1` | 5.90s | 216.8Hz | -4.6 dBFS |
| `doc_emiko_ev_lv3_dont_expect_yield` | `assets/audio/voice/doc_emiko/events/ev_lv3_dont_expect_yield.wav` | `emiko_lv3_today_i_lead/em3_s6r_02` | 当然よ。手加減なんて期待しないことね。 | `take1` | 3.00s | 281.2Hz | -2.5 dBFS |
| `doc_emiko_ev_lv3_private_notes` | `assets/audio/voice/doc_emiko/events/ev_lv3_private_notes.wav` | `emiko_lv3_today_i_lead/em3_s6_11` | もう、試験を受けに来たわけじゃないでしょう? | `take1` | 3.28s | 210.9Hz | -7.9 dBFS |
| `doc_emiko_ev_lv3_sushi_qualified` | `assets/audio/voice/doc_emiko/events/ev_lv3_sushi_qualified.wav` | `emiko_lv3_today_i_lead/em3_s1_44` | 隠すことじゃないわ。外科部長の座には興味があるし、争う資格もある。 | `take1` | 5.63s | 193.4Hz | -6.5 dBFS |
| `doc_emiko_ev_lv3_today_i_lead` | `assets/audio/voice/doc_emiko/events/ev_lv3_today_i_lead.wav` | `emiko_lv3_today_i_lead/em3_s2_16` | 今日は私が執刀する。あなたは絶対に死なせないわ。 | `take1` | 4.68s | 246.1Hz | -4.8 dBFS |
| `doc_emiko_ev_lv4_care_to_try` | `assets/audio/voice/doc_emiko/events/ev_lv4_care_to_try.wav` | `emiko_lv4_emikos_secret/em4_s6_1_22` | 外の時間はあなたが借りてきたんでしょう、坂口先生。……こっちに来て、試してみる? | `take1` | 7.41s | 205.1Hz | -3.9 dBFS |
| `doc_emiko_ev_lv4_dont_leave` | `assets/audio/voice/doc_emiko/events/ev_lv4_dont_leave.wav` | `emiko_lv4_emikos_secret/em4_s5_30` | 今日は、先に帰らなくていいわ。 | `take2` | 2.51s | 234.4Hz | -8.7 dBFS |
| `doc_emiko_ev_lv4_get_out` | `assets/audio/voice/doc_emiko/events/ev_lv4_get_out.wav` | `emiko_lv4_emikos_secret/em4_s1_20` | ……出て行って！！ | `take1` | 1.06s | 363.3Hz | -8.9 dBFS |
| `doc_emiko_ev_lv4_never_yield_chief` | `assets/audio/voice/doc_emiko/events/ev_lv4_never_yield_chief.wav` | `emiko_lv4_emikos_secret/em4_s6_2_26` | でも、こうして抱き合うのと仕事は別よ。外科部長の座は、一歩たりとも譲らないわ。 | `take1` | 6.85s | 210.9Hz | -3.2 dBFS |
| `doc_emiko_ev_lv4_secret_breath` | `assets/audio/voice/doc_emiko/events/ev_lv4_secret_breath.wav` | `emiko_lv4_emikos_secret/em4_s1_13` | はあっ……んっ……くっ、ああっ……！ | `take1` | 5.02s | 246.1Hz | -12.3 dBFS |
| `doc_emiko_ev_lv4_thank_you` | `assets/audio/voice/doc_emiko/events/ev_lv4_thank_you.wav` | `emiko_lv4_emikos_secret/em4_s3r_15` | ……ありがとう。 | `take1` | 1.03s | 193.4Hz | -13.0 dBFS |
| `doc_emiko_free_h_accept` | `assets/audio/voice/doc_emiko/free_h_accept.wav` | `free_h_response (doc_emiko)` | ……今夜、第二オペ室は空いてるわ。仕事が終わったら来て。振り返りに付き合ってもらうから。 | `take1` | 8.29s | 240.2Hz | -1.9 dBFS |
| `doc_emiko_h_aftercare_1` | `assets/audio/voice/doc_emiko/h/h_aftercare_1.wav` | `h_runner.doc_emiko (h_aftercare_1)` | はぁ……まったく、オペ台の上でここまで乱れるなんて……あなたのせいよ。 | `take2` | 5.99s | 216.8Hz | -4.1 dBFS |
| `doc_emiko_h_aftercare_2` | `assets/audio/voice/doc_emiko/h/h_aftercare_2.wav` | `h_runner.doc_emiko (h_aftercare_2)` | ……もう少しだけ、このままでいなさい。明日のオペでは、絶対に負けないから。 | `take1` | 6.44s | 222.7Hz | -6.4 dBFS |
| `doc_emiko_h_entry_1` | `assets/audio/voice/doc_emiko/h/h_entry_1.wav` | `h_runner.doc_emiko (h_entry_1)` | ……鍵は閉めたわ。いつも執刀しているこのオペ室で、こんなこと……こっちに来なさい。 | `take1` | 6.85s | 234.4Hz | -5.8 dBFS |
| `doc_emiko_h_entry_2` | `assets/audio/voice/doc_emiko/h/h_entry_2.wav` | `h_runner.doc_emiko (h_entry_2)` | ……術野を見るみたいな目で見ないで。呼んだのは私よ……好きにしなさい。 | `take1` | 7.18s | 187.5Hz | -2.3 dBFS |
| `doc_emiko_h_finish_1` | `assets/audio/voice/doc_emiko/h/h_finish_1.wav` | `h_runner.doc_emiko (h_finish_1)` | きゃあああああっ！！ ああああっ！！ | `take1` | 3.49s | 375.0Hz | -3.1 dBFS |
| `doc_emiko_h_finish_2` | `assets/audio/voice/doc_emiko/h/h_finish_2.wav` | `h_runner.doc_emiko (h_finish_2)` | あああああっ！！ ま、待ってえええっ！！ | `take1` | 4.43s | 375.0Hz | -9.0 dBFS |
| `doc_emiko_h_finish_3` | `assets/audio/voice/doc_emiko/h/h_finish_3.wav` | `h_runner.doc_emiko (h_finish_3)` | ひゃあああああっ！！ あ、頭が真っ白になるううっ！！ | `take1` | 5.92s | 293.0Hz | -3.8 dBFS |
| `doc_emiko_h_finish_4` | `assets/audio/voice/doc_emiko/h/h_finish_4.wav` | `h_runner.doc_emiko (h_finish_4)` | あああああっ！！ あ、あついいいっ……あああっ！！ | `take1` | 5.67s | 410.2Hz | -1.6 dBFS |
| `doc_emiko_h_max_prompt` | `assets/audio/voice/doc_emiko/h/h_max_prompt.wav` | `h_runner.doc_emiko (h_max_prompt)` | はあっ……もう、じらさないで……このオペ台の上で、早く……来て……！ | `take1` | 6.49s | 246.1Hz | -0.2 dBFS |
| `doc_emiko_h_mid_intense` | `assets/audio/voice/doc_emiko/h/h_mid_intense.wav` | `h_runner.doc_emiko (h_mid_intense)` | ああああっ！！ は、激しすぎるわっ……息が、できないっ！！ | `take1` | 5.32s | 281.2Hz | -2.8 dBFS |
| `doc_emiko_h_open_gentle` | `assets/audio/voice/doc_emiko/h/h_open_gentle.wav` | `h_runner.doc_emiko (h_open_gentle)` | んっ……ああっ……ゆっくり、来なさい……ちゃんと、受け止めるから…… | `take1` | 7.18s | 222.7Hz | -5.0 dBFS |
| `doc_emiko_h_open_intense` | `assets/audio/voice/doc_emiko/h/h_open_intense.wav` | `h_runner.doc_emiko (h_open_intense)` | きゃああっ！！ い、いきなりなんて……っ、オペ台が揺れるじゃないっ！！ | `take1` | 5.13s | 351.6Hz | -2.9 dBFS |
| `doc_emiko_h_stage_build_1` | `assets/audio/voice/doc_emiko/h/h_stage_build_1.wav` | `h_runner.doc_emiko (h_stage_build_1)` | やあああっ！！ も、もう抑えられないっ……声が、響いてしまうっ！！ | `take1` | 7.03s | 328.1Hz | -2.7 dBFS |
| `doc_emiko_h_stage_mid_1` | `assets/audio/voice/doc_emiko/h/h_stage_mid_1.wav` | `h_runner.doc_emiko (h_stage_mid_1)` | はあっ……あっ……すごく熱い……頭の中まで、溶けそうよ…… | `take2` | 6.50s | 328.1Hz | -2.2 dBFS |
| `doc_emiko_h_stage_near_1` | `assets/audio/voice/doc_emiko/h/h_stage_near_1.wav` | `h_runner.doc_emiko (h_stage_near_1)` | きゃあああっ！！ は、離さないでっ……このまま、最後まで来てっ！！ | `take1` | 5.85s | 386.7Hz | -0.2 dBFS |
| `doc_emiko_h_stage_start_1` | `assets/audio/voice/doc_emiko/h/h_stage_start_1.wav` | `h_runner.doc_emiko (h_stage_start_1)` | ああっ！！ いつも私が仕切っているオペ室で、こんな格好っ……！ | `take1` | 5.40s | 252.0Hz | -1.8 dBFS |
| `doc_emiko_h_stage_start_2` | `assets/audio/voice/doc_emiko/h/h_stage_start_2.wav` | `h_runner.doc_emiko (h_stage_start_2)` | んっ……だ、だめっ……同僚のあなたに、こんなに乱されるなんてっ……！ | `take2` | 6.63s | 304.7Hz | -2.2 dBFS |
| `doc_emiko_h_tier_favorite_1` | `assets/audio/voice/doc_emiko/h/h_tier_favorite_1.wav` | `h_runner.doc_emiko (h_tier_favorite_1)` | ひゃあっ！！ だ、だめっ……そこばかり責めないでっ……！ | `take2` | 4.58s | 275.4Hz | -1.8 dBFS |
| `doc_emiko_h_tier_favorite_2` | `assets/audio/voice/doc_emiko/h/h_tier_favorite_2.wav` | `h_runner.doc_emiko (h_tier_favorite_2)` | ああっ！！ くっ、いつもの私なら、こんな声っ……！ | `take1` | 5.30s | 257.8Hz | -10.4 dBFS |
| `doc_emiko_h_tier_low_1` | `assets/audio/voice/doc_emiko/h/h_tier_low_1.wav` | `h_runner.doc_emiko (h_tier_low_1)` | ……っ、どこを触っているの。ふざけないで。 | `take1` | 2.72s | 246.1Hz | -3.3 dBFS |
| `doc_emiko_h_tier_low_2` | `assets/audio/voice/doc_emiko/h/h_tier_low_2.wav` | `h_runner.doc_emiko (h_tier_low_2)` | くっ……試すような真似はよしなさい……！ | `take1` | 4.03s | 210.9Hz | -2.9 dBFS |
| `doc_emiko_h_tier_mild_1` | `assets/audio/voice/doc_emiko/h/h_tier_mild_1.wav` | `h_runner.doc_emiko (h_tier_mild_1)` | んっ……はぁ……手先だけは、相変わらず器用ね…… | `take1` | 4.52s | 216.8Hz | -5.8 dBFS |
| `doc_emiko_h_tier_mild_2` | `assets/audio/voice/doc_emiko/h/h_tier_mild_2.wav` | `h_runner.doc_emiko (h_tier_mild_2)` | ふっ……ん……オペ室なのに、声が漏れるじゃない…… | `take1` | 3.95s | 216.8Hz | -4.9 dBFS |
| `doc_emiko_h_tier_strong_1` | `assets/audio/voice/doc_emiko/h/h_tier_strong_1.wav` | `h_runner.doc_emiko (h_tier_strong_1)` | あっ……ま、待ちなさい……そんなところ、急にっ……！ | `take1` | 3.85s | 269.5Hz | -4.2 dBFS |
| `doc_emiko_h_tier_strong_2` | `assets/audio/voice/doc_emiko/h/h_tier_strong_2.wav` | `h_runner.doc_emiko (h_tier_strong_2)` | はあっ……見ないで……こんな顔、同僚に見られるなんて……っ！ | `take1` | 6.03s | 275.4Hz | -2.3 dBFS |
