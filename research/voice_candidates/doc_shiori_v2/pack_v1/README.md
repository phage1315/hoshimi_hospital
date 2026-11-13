# 藤崎 詩織（`doc_shiori`）通用短句语音包 v1

- 复用已认可 Voice ID：`voice_6af61a0d40c4819192761ee5920d9611`（见 `../voice.json`，未新建声线）。
- 生成引擎：OpenAI GPT-Live `gpt-live-1`，24kHz 单声道 16-bit WAV，仅修剪首尾静音，无变速／变调／后期滤波（手术口罩微闷感来自生成指令）。

| Clip ID | 台词 | 时长 | SHA256前12位 | API转写核对 |
| --- | --- | --- | --- | --- |
| `doc_shiori_ohayou` | 「おはようございます、坂口先生。」 | 3.06s | `1be0e5ddd729` | 一致 |
| `doc_shiori_otsukaresama` | 「お疲れ様です、坂口先生。」 | 2.74s | `a0d873dd85d0` | 一致 |
| `doc_shiori_neutral` | 「ええ、それでいいと思います。」 | 2.86s | `7e0f7650c656` | 一致 |
| `doc_shiori_smile` | 「ふふ、今日は息が合っていますね。」 | 3.34s | `594e6d1dbfbe` | 一致 |
| `doc_shiori_serious` | 「順序立てて整理していきましょう。」 | 2.71s | `eaf663252594` | 一致 |
| `doc_shiori_worried` | 「少し気がかりな所見がありますね。」 | 2.94s | `586e150a29cc` | 一致 |
| `doc_shiori_tired` | 「ふう、少しお茶でも淹れましょうか。」 | 3.38s | `39968bbd1287` | 一致 |
| `doc_shiori_surprised` | 「あら、それは意外ですね。」 | 2.29s | `51976fb82db7` | 一致 |
| `doc_shiori_timeout` | 「助手側、準備は整っています。」 | 2.79s | `b1808c74cf31` | 一致 |
| `doc_shiori_or_clear` | 「状態は安定しています、続けましょう。」 | 3.11s | `e0815b223c5e` | 一致 |
| `doc_shiori_or_caution` | 「待って、もう一度だけ確認させてください。」 | 2.98s | `1a0614d08ba5` | 一致 |
