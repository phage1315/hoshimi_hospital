# 倉本 千早（`patient_chihaya`）通用短句语音包 v1

- 复用已认可 Voice ID：`voice_6af61a45c8148191bacd0b7cf01ad2d1`（见 `../voice.json`，未新建声线）。
- 生成引擎：OpenAI GPT-Live `gpt-live-1`，24kHz 单声道 16-bit WAV，仅修剪首尾静音，无变速／变调／后期滤波（手术口罩微闷感来自生成指令）。

| Clip ID | 台词 | 时长 | SHA256前12位 | API转写核对 |
| --- | --- | --- | --- | --- |
| `patient_chihaya_ohayou` | 「おはようございます、坂口先生。」 | 2.99s | `74b4bb4e58f1` | 一致 |
| `patient_chihaya_otsukaresama` | 「お疲れ様です、坂口先生。」 | 3.05s | `24c2b44538d2` | 一致 |
| `patient_chihaya_neutral` | 「はい、わかりました。」 | 2.07s | `4f5db28fe263` | 一致 |
| `patient_chihaya_smile` | 「えへへ、先生のお手伝い頑張りますね。」 | 3.60s | `4edd0aaa02e5` | 一致 |
| `patient_chihaya_serious` | 「患者さんのために、しっかり確認しますね。」 | 3.62s | `52581168f9f0` | 一致 |
| `patient_chihaya_worried` | 「あの、大丈夫でしょうか、少し心配です。」 | 3.35s | `bf4ad0b20c72` | 一致 |
| `patient_chihaya_tired` | 「ふう、少しだけ深呼吸しますね。」 | 2.69s | `18e73ef2fa10` | 一致 |
| `patient_chihaya_surprised` | 「わあっ、ほんとですか。」 | 1.96s | `2e4639404420` | 一致 |
| `patient_chihaya_timeout` | 「外回りの準備、しっかり整っています。」 | 3.85s | `46e01305a91e` | 一致 |
| `patient_chihaya_or_clear` | 「連絡も物品も大丈夫です、続けてください。」 | 4.08s | `97f662fbcaed` | 一致 |
| `patient_chihaya_or_caution` | 「先生、待ってください、確認させてください。」 | 3.15s | `47d6e574a860` | 一致 |
