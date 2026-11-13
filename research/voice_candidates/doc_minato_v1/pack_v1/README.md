# 遥 湊（`doc_minato`）通用短句语音包 v1

- 复用已认可 Voice ID：`voice_6af5fe7e72f48191b6d66e9aebda8f5a`（见 `../voice.json`，未新建声线）。
- 生成引擎：OpenAI GPT-Live `gpt-live-1`，24kHz 单声道 16-bit WAV，仅修剪首尾静音，无变速／变调／后期滤波（手术口罩微闷感来自生成指令）。

| Clip ID | 台词 | 时长 | SHA256前12位 | API转写核对 |
| --- | --- | --- | --- | --- |
| `doc_minato_ohayou` | 「おはよう、坂口先生。」 | 2.24s | `888593f8ca6b` | 一致 |
| `doc_minato_otsukaresama` | 「お疲れ様、坂口先生。一息つくかい。」 | 4.47s | `b31f3d32c954` | 一致 |
| `doc_minato_neutral` | 「うん、それでいこうか。」 | 0.95s | `bba4bda0aaef` | 一致 |
| `doc_minato_smile` | 「はは、いい調子じゃないか。」 | 2.13s | `0fe6e683b15a` | 一致 |
| `doc_minato_serious` | 「よし、ここからは手元だけに集中しよう。」 | 3.66s | `95c82e3b718b` | 一致 |
| `doc_minato_worried` | 「少し様子が気になるね、無理は禁物だよ。」 | 3.78s | `1718f60af9f1` | 转写「 少し様子が気になるね、無理は禁物だよ。」 |
| `doc_minato_tired` | 「ふう、さすがに肩が凝ったねえ。」 | 2.69s | `1de2d025082d` | 一致 |
| `doc_minato_surprised` | 「おや、それは驚いたね。」 | 2.46s | `5a6173d01f69` | 一致 |
| `doc_minato_timeout` | 「助手席、いつでもいけるよ。」 | 3.10s | `2048b9032f2a` | 一致 |
| `doc_minato_or_clear` | 「いい視野だよ、そのまま進めて大丈夫。」 | 3.45s | `9afb7d1dd78d` | 一致 |
| `doc_minato_or_caution` | 「待った、一拍置いて確認しよう。」 | 2.87s | `c9e6f7a4091f` | 一致 |
