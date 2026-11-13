# 南条小夜香 (`doc_sayaka`) `pack_v3_h_poc` — H Runner 专属语音包 POC 归档

- **复用定稿 Voice ID**：`voice_6af56ca280988191ba228faa5add48c0`（[`../voice.json`](../voice.json)，零新建声线）
- **渲染入口**：`tools/voice_runner/hoshimi-voice run`（`gpt-live-1`，24kHz 单声道 16-bit PCM WAV）
- **演绎策略**：采用戏剧化呼吸感、怕痒倒抽气、突如其来的惊呼与情绪过载颤音（惊叫系戏剧演绎），20/20 条均一次性通过 `session_finalized: true` 与逐字转写校验。

| Clip ID | 运行资源路径 | 日语台词 | 选用 Take | 时长 | 峰值 |
|---|---|---|---|---|---|
| `doc_sayaka_h_entry_1` | `assets/audio/voice/doc_sayaka/h/h_entry_1.wav` | ……ん、鍵は閉めた? こっちに来て。 | `take1` | 8.25s | -7.7 dBFS |
| `doc_sayaka_h_entry_2` | `assets/audio/voice/doc_sayaka/h/h_entry_2.wav` | ふふ……どうしてあなたの方が緊張してるの? | `take2` | 4.45s | -14.5 dBFS |
| `doc_sayaka_h_tier_low_1` | `assets/audio/voice/doc_sayaka/h/h_tier_low_1.wav` | もう……からかってばかりなんだから。 | `take1` | 2.50s | -15.6 dBFS |
| `doc_sayaka_h_tier_low_2` | `assets/audio/voice/doc_sayaka/h/h_tier_low_2.wav` | ひゃっ……ち、違うわよ、くすぐったいだけ……！ | `take2` | 3.30s | -11.8 dBFS |
| `doc_sayaka_h_tier_mild_1` | `assets/audio/voice/doc_sayaka/h/h_tier_mild_1.wav` | んっ……そう、そのままゆっくりね…… | `take1` | 4.00s | -14.0 dBFS |
| `doc_sayaka_h_tier_mild_2` | `assets/audio/voice/doc_sayaka/h/h_tier_mild_2.wav` | ふふ……ほんと、甘やかすのが上手ね…… | `take1` | 4.00s | -9.5 dBFS |
| `doc_sayaka_h_tier_strong_1` | `assets/audio/voice/doc_sayaka/h/h_tier_strong_1.wav` | あっ……だ、だめ、急にびっくりするじゃない……！ | `take1` | 3.50s | -8.7 dBFS |
| `doc_sayaka_h_tier_strong_2` | `assets/audio/voice/doc_sayaka/h/h_tier_strong_2.wav` | はあっ……見ないでよ……顔、赤くなってるでしょう…… | `take1` | 4.40s | -9.1 dBFS |
| `doc_sayaka_h_tier_favorite_1` | `assets/audio/voice/doc_sayaka/h/h_tier_favorite_1.wav` | ああっ……ま、待って……今なに言おうとしたか、忘れちゃったじゃない…… | `take1` | 5.30s | -8.5 dBFS |
| `doc_sayaka_h_tier_favorite_2` | `assets/audio/voice/doc_sayaka/h/h_tier_favorite_2.wav` | んっ……ああっ、またそれ……ほんと、ずるいわ…… | `take1` | 4.30s | -5.7 dBFS |
| `doc_sayaka_h_max_prompt` | `assets/audio/voice/doc_sayaka/h/h_max_prompt.wav` | ああっ……もう、焦らさないで……こっちに来て、もっと近くに…… | `take1` | 5.90s | -14.4 dBFS |
| `doc_sayaka_h_open_gentle` | `assets/audio/voice/doc_sayaka/h/h_open_gentle.wav` | んっ……そう、そのままでいいわ……もう少し、近くに行かせて…… | `take1` | 7.20s | -13.8 dBFS |
| `doc_sayaka_h_open_intense` | `assets/audio/voice/doc_sayaka/h/h_open_intense.wav` | きゃあっ……あ、あなたってほんとせっかちね……いじわる…… | `take2` | 4.40s | -9.6 dBFS |
| `doc_sayaka_h_lv4_doctor_ok` | `assets/audio/voice/doc_sayaka/h/h_lv4_doctor_ok.wav` | 私、医者なのよ? 必要な準備くらい、とっくに済ませてあるわ。私がそうしたいんだから、余計な心配しないで。 | `take2` | 10.55s | -11.3 dBFS |
| `doc_sayaka_h_stage_mid_1` | `assets/audio/voice/doc_sayaka/h/h_stage_mid_1.wav` | あっ……ゆ、ゆっくりね……んっ、私はここにいるから…… | `take1` | 5.50s | -12.0 dBFS |
| `doc_sayaka_h_stage_near_1` | `assets/audio/voice/doc_sayaka/h/h_stage_near_1.wav` | はあっ……も、もっと強く抱きしめて……離さないでっ……！ | `take1` | 5.65s | -11.3 dBFS |
| `doc_sayaka_h_finish_1` | `assets/audio/voice/doc_sayaka/h/h_finish_1.wav` | きゃあっ……ま、待って……ああっ……！ | `take2` | 2.30s | -9.1 dBFS |
| `doc_sayaka_h_finish_2` | `assets/audio/voice/doc_sayaka/h/h_finish_2.wav` | ああっ……す、すごい……頭が、真っ白になるっ……！ | `take2` | 4.25s | -8.3 dBFS |
| `doc_sayaka_h_aftercare_1` | `assets/audio/voice/doc_sayaka/h/h_aftercare_1.wav` | はぁ……すごく、幸せ……ねえ、もう少しだけ抱きしめていてくれる? | `take1` | 6.95s | -10.5 dBFS |
| `doc_sayaka_h_aftercare_2` | `assets/audio/voice/doc_sayaka/h/h_aftercare_2.wav` | だめ、動かないで……このまま、もう少しだけ寄りかからせて…… | `take1` | 5.10s | -11.2 dBFS |
