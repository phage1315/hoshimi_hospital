# 杉村 弘子（`nurse_hiroko`）通用短句语音包 v1

- 复用已认可 Voice ID：`voice_6af642b963888191a8598cef5c298f11`（见 `../voice.json`，未新建声线）。
- 生成引擎：OpenAI GPT-Live `gpt-live-1`，24kHz 单声道 16-bit WAV，仅修剪首尾静音，无变速／变调／后期滤波（手术口罩微闷感来自生成指令）。

| Clip ID | 台词 | 时长 | SHA256前12位 | API转写核对 |
| --- | --- | --- | --- | --- |
| `nurse_hiroko_ohayou` | 「おはようございます、坂口先生。」 | 2.78s | `ec685449f036` | 一致 |
| `nurse_hiroko_otsukaresama` | 「お疲れ様です、坂口先生。」 | 2.69s | `95540b878d11` | 一致 |
| `nurse_hiroko_neutral` | 「はい、わかりました。」 | 1.68s | `be88061c8383` | 一致 |
| `nurse_hiroko_smile` | 「えへへ、先生のお手伝いできて嬉しいです。」 | 4.10s | `35e5d03e87ae` | 一致 |
| `nurse_hiroko_serious` | 「看護の手順、しっかり確認しますね。」 | 3.13s | `f1e4b5d12355` | 一致 |
| `nurse_hiroko_worried` | 「あの、無理だけはしないでくださいね。」 | 2.78s | `72c5ea27f44d` | 一致 |
| `nurse_hiroko_tired` | 「ふう、少しだけ休憩しましょうか。」 | 3.58s | `12105aa60e4b` | 一致 |
| `nurse_hiroko_surprised` | 「わっ、びっくりしました。」 | 2.12s | `e69d26b92eac` | 一致 |
| `nurse_hiroko_timeout` | 「看護サイド、準備ばっちり整っています。」 | 3.68s | `29c7675bdf79` | 一致 |
| `nurse_hiroko_or_clear` | 「手元の準備も順調です、どうぞ続けてください。」 | 3.98s | `c0fa20889eb3` | 一致 |
| `nurse_hiroko_or_caution` | 「先生、待ってください、もう一度確認します。」 | 2.99s | `38bdf81f6037` | 一致 |
