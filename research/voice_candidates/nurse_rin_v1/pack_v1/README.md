# 中井 美佳（`nurse_rin`）通用短句语音包 v1

- 复用已认可 Voice ID：`voice_6af5fe286fd48191814c726a7d11fe4e`（见 `../voice.json`，未新建声线）。
- 生成引擎：OpenAI GPT-Live `gpt-live-1`，24kHz 单声道 16-bit WAV，仅修剪首尾静音，无变速／变调／后期滤波（手术口罩微闷感来自生成指令）。

| Clip ID | 台词 | 时长 | SHA256前12位 | API转写核对 |
| --- | --- | --- | --- | --- |
| `nurse_rin_ohayou` | 「おはようございます、坂口先生。」 | 2.78s | `287f9c615959` | 一致 |
| `nurse_rin_otsukaresama` | 「お疲れ様です、坂口先生。」 | 2.58s | `f46a184e226f` | 一致 |
| `nurse_rin_neutral` | 「ええ、わかりました。」 | 1.54s | `856e9afb2697` | 一致 |
| `nurse_rin_smile` | 「ふふ、頼りにしていますよ、先生。」 | 3.13s | `08b7585d751b` | 一致 |
| `nurse_rin_serious` | 「段取りどおり、落ち着いて進めましょう。」 | 2.73s | `28fbed84f38c` | 一致 |
| `nurse_rin_worried` | 「少し気になるところがありますね。」 | 2.36s | `40f5935c0f7c` | 一致 |
| `nurse_rin_tired` | 「ふう、一息ついたら次へいきましょうか。」 | 3.41s | `c31d0dc1e3c1` | 一致 |
| `nurse_rin_surprised` | 「あら、そうだったんですね。」 | 1.93s | `30deeba78ea5` | 一致 |
| `nurse_rin_timeout` | 「看護側、準備も確認も済んでいます。」 | 3.18s | `e756c1a4f555` | 一致 |
| `nurse_rin_or_clear` | 「器械も記録も問題ありません、どうぞ。」 | 3.16s | `56d97f0e7e5c` | 一致 |
| `nurse_rin_or_caution` | 「先生、一度手を止めて確認しましょう。」 | 3.58s | `60a20034710c` | 一致 |
