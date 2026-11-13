# 深山 佳織（`doc_rei`）通用短句语音包 v1

- 复用已认可 Voice ID：`voice_6af5fe3ab56881918658ffb98e70df05`（见 `../voice.json`，未新建声线）。
- 生成引擎：OpenAI GPT-Live `gpt-live-1`，24kHz 单声道 16-bit WAV，仅修剪首尾静音，无变速／变调／后期滤波（手术口罩微闷感来自生成指令）。

| Clip ID | 台词 | 时长 | SHA256前12位 | API转写核对 |
| --- | --- | --- | --- | --- |
| `doc_rei_ohayou` | 「おはようございます、先生。」 | 2.14s | `0f28ca59a077` | 一致 |
| `doc_rei_otsukaresama` | 「お疲れ様です、坂口先生。」 | 2.58s | `3716eeba9bda` | 一致 |
| `doc_rei_neutral` | 「ええ、了解です。」 | 1.48s | `4d9b8df803e7` | 一致 |
| `doc_rei_smile` | 「ふふ、悪くない判断ですね。」 | 3.16s | `c46b6759dd6e` | 一致 |
| `doc_rei_serious` | 「集中しましょう、ここからが本番です。」 | 3.02s | `c7822a8d7326` | 一致 |
| `doc_rei_worried` | 「少し数値が気になりますね。」 | 2.57s | `3d813d0616a7` | 一致 |
| `doc_rei_tired` | 「ふう、さすがに少し疲れましたね。」 | 3.38s | `439132b2d779` | 一致 |
| `doc_rei_surprised` | 「えっ、本当ですか。」 | 1.72s | `299db305bbd4` | 一致 |
| `doc_rei_timeout` | 「助手位置、準備完了です。」 | 2.38s | `329904cb771c` | 一致 |
| `doc_rei_or_clear` | 「視野は良好です、このまま進めましょう。」 | 4.17s | `dcd3badabb3c` | 一致 |
| `doc_rei_or_caution` | 「待ってください、もう一度確認しましょう。」 | 3.13s | `28ce1a226d3e` | 一致 |
