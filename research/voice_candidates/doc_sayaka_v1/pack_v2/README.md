# 南条小夜香 (`doc_sayaka`) `pack_v2` 人物语音审计扩充与剧情高光关键句归档

- **复用定稿 Voice ID**：`voice_6af56ca280988191ba228faa5add48c0`（[`../voice.json`](../voice.json)，零新建声线）
- **渲染入口**：`tools/voice_runner/hoshimi-voice run`（`gpt-live-1`，24kHz 单声道 16-bit PCM WAV）
- **涵盖内容（共 21 条）**：
  1. 修复 `pack_v1/neutral.wav` 尾部 3 秒气音残响缺陷（`5.72s` → `2.19s` 干净重录）；
  2. 补齐人设核心情绪槽位 `shy.wav`（10% 被打个措手不及的害羞）与 `teasing.wav`（20% 小恶魔逗弄）；
  3. 补齐系统互动槽位 `free_h_accept.wav`（自由 H 下班过夜邀约答应）及偏爱约会地点专属语音 `date_seaside.wav`、`date_trattoria.wav`；
  4. 接入 Intro → Lv1 → Lv2 → Lv3 → Lv4 → Lv4 回医院彩蛋 → Lv5 Part A/B 共 **15 句**高冲击力剧情关键台词（通过 `data/audio/event_voice_cues.json` 零侵入挂载，不改任何剧本 JSON）。

| Clip ID | 运行资源路径 | 绑定目标 | 日语台词 | 选用 Take | 时长 | 峰值 |
|---|---|---|---|---|---|---|
| `doc_sayaka_neutral` | `assets/audio/voice/doc_sayaka/neutral.wav` | `system_or_expression` | ええ、いいわよ。 | `take1` | 2.19s | -11.9 dBFS |
| `doc_sayaka_shy` | `assets/audio/voice/doc_sayaka/shy.wav` | `system_or_expression` | ……もう、急にそういうこと言わないでよ。 | `take1` | 3.16s | -11.5 dBFS |
| `doc_sayaka_teasing` | `assets/audio/voice/doc_sayaka/teasing.wav` | `system_or_expression` | ふふ……さっきから私のこと、見てたでしょう？ | `take1` | 3.94s | -9.4 dBFS |
| `doc_sayaka_free_h_accept` | `assets/audio/voice/doc_sayaka/free_h_accept.wav` | `system_or_expression` | いいわよ……じゃあ今夜、楽しみにしてるわね。 | `take1` | 3.73s | -10.2 dBFS |
| `doc_sayaka_date_seaside` | `assets/audio/voice/doc_sayaka/date_seaside.wav` | `system_or_expression` | 風が気持ちいいわね……ねえ、手、繋いでもいいでしょう？ | `take1` | 5.54s | -10.4 dBFS |
| `doc_sayaka_date_trattoria` | `assets/audio/voice/doc_sayaka/date_trattoria.wav` | `system_or_expression` | このお店、味も雰囲気も素敵ね。ふふ、さすが私の相手。 | `take1` | 4.63s | -7.7 dBFS |
| `doc_sayaka_ev_intro_send_first` | `assets/audio/voice/doc_sayaka/events/ev_intro_send_first.wav` | `sayaka_week1_phone_exchange/v2_174` | 先に送って。私が採点してあげるから。 | `take2` | 4.38s | -10.3 dBFS |
| `doc_sayaka_ev_lv1_split_bill` | `assets/audio/voice/doc_sayaka/events/ev_lv1_split_bill.wav` | `sayaka_lv1_first_date/v2_591` | ここは割り勘よ。 | `take1` | 1.58s | -17.7 dBFS |
| `doc_sayaka_ev_lv1_other_things` | `assets/audio/voice/doc_sayaka/events/ev_lv1_other_things.wav` | `sayaka_lv1_first_date/v2_611` | ほかのことは……また今度ね。 | `take3` | 3.18s | -13.8 dBFS |
| `doc_sayaka_ev_lv1_liked_person` | `assets/audio/voice/doc_sayaka/events/ev_lv1_liked_person.wav` | `sayaka_lv1_first_date/v2_647` | だって、好きな人から誘われるのって、悪くないもの。 | `take1` | 4.58s | -10.4 dBFS |
| `doc_sayaka_ev_lv2_good_boy` | `assets/audio/voice/doc_sayaka/events/ev_lv2_good_boy.wav` | `sayaka_lv2_working_hours/lv2_v2_119` | いい子ね。 | `take1` | 1.44s | -16.3 dBFS |
| `doc_sayaka_ev_lv2_watch_field` | `assets/audio/voice/doc_sayaka/events/ev_lv2_watch_field.wav` | `sayaka_lv2_working_hours/lv2_v2_457` | でも次のオペでは、ちゃんと術野を見てなさいよ。 | `take1` | 3.98s | -13.3 dBFS |
| `doc_sayaka_ev_lv3_approved` | `assets/audio/voice/doc_sayaka/events/ev_lv3_approved.wav` | `sayaka_lv3_relationship/lv3_v2_316` | 承認します。ふふ、これで十分正式でしょう？ | `take1` | 4.40s | -12.3 dBFS |
| `doc_sayaka_ev_lv3_kiss_forgot` | `assets/audio/voice/doc_sayaka/events/ev_lv3_kiss_forgot.wav` | `sayaka_lv3_relationship/lv3_v2_351` | ……手が早いんだから。何か言おうとしてたのに、全部飛んじゃったじゃない。 | `take1` | 6.66s | -10.1 dBFS |
| `doc_sayaka_ev_lv3_boyfriend_walk` | `assets/audio/voice/doc_sayaka/events/ev_lv3_boyfriend_walk.wav` | `sayaka_lv3_relationship/lv3_v2_359` | ……じゃあ、彼氏さん。今日は家まで送って。 | `take3` | 5.33s | -10.4 dBFS |
| `doc_sayaka_ev_lv4_morning_love` | `assets/audio/voice/doc_sayaka/events/ev_lv4_morning_love.wav` | `sayaka_lv4_hotel_date/s10_103` | 隠すことないでしょう？あなたが好きだし、昨夜のことも好きよ。 | `take1` | 5.58s | -12.4 dBFS |
| `doc_sayaka_ev_lv4_hospital_gaze` | `assets/audio/voice/doc_sayaka/events/ev_lv4_hospital_gaze.wav` | `sayaka_lv4_hospital_callback/callback_003` | 病院で、あの夜みたいな目で私を見ないでよ。 | `take1` | 4.18s | -12.5 dBFS |
| `doc_sayaka_ev_lv4_want_to_operate` | `assets/audio/voice/doc_sayaka/events/ev_lv4_want_to_operate.wav` | `sayaka_lv4_hospital_callback/callback_006` | オペしたそうな目よ。 | `take1` | 1.98s | -13.0 dBFS |
| `doc_sayaka_ev_lv5_nobody_here` | `assets/audio/voice/doc_sayaka/events/ev_lv5_nobody_here.wav` | `sayaka_lv5_part_a/sayaka_lv5_part_a_main/a01_0004` | せっかく仕事が終わったのに、残業なんて嫌よ。……今夜、ここには誰もいないわよね？ | `take1` | 7.34s | -7.3 dBFS |
| `doc_sayaka_ev_lv5_consent_signed` | `assets/audio/voice/doc_sayaka/events/ev_lv5_consent_signed.wav` | `sayaka_lv5_part_b/sayaka_lv5_part_b_main/b01_0007` | ええ、サインも済ませてあるわ。術式の欄だけ、あなたのために空けてあるの。 | `take1` | 6.62s | -9.9 dBFS |
| `doc_sayaka_ev_lv5_thank_you_surgery` | `assets/audio/voice/doc_sayaka/events/ev_lv5_thank_you_surgery.wav` | `sayaka_lv5_part_b/sayaka_lv5_part_b_main/b08_0047` | 昨日は、ちゃんと最後まで真剣に執刀してくれて、ありがとう。次の術式は、私にも選ばせてね。 | `take2` | 9.94s | -11.6 dBFS |
