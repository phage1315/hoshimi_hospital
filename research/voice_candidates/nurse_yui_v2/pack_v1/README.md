# 朝倉 美幸（`nurse_yui`）通用短句语音包 v1

- 复用已认可 Voice ID：`voice_6af5fdc3dcc88191808a8aa8deb47256`（见 `../voice.json`，未新建声线）。
- 生成引擎：OpenAI GPT-Live `gpt-live-1`，24kHz 单声道 16-bit WAV，仅修剪首尾静音，无变速／变调／后期滤波（手术口罩微闷感来自生成指令）。

| Clip ID | 台词 | 时长 | SHA256前12位 | API转写核对 |
| --- | --- | --- | --- | --- |
| `nurse_yui_ohayou` | 「おはようございます、坂口先生。」 | 2.64s | `a723fdc937eb` | 一致 |
| `nurse_yui_otsukaresama` | 「お疲れ様です、先生。頑張りましたね。」 | 3.10s | `efd15bed7a39` | 一致 |
| `nurse_yui_neutral` | 「はい、了解ですよ。」 | 2.04s | `743607c3d358` | 一致 |
| `nurse_yui_smile` | 「ふふ、先生のことちゃんと見てますからね。」 | 4.25s | `6abb9c9c6c0a` | 一致 |
| `nurse_yui_serious` | 「手順と確認、きっちり合わせますね。」 | 2.66s | `486c7802f5af` | 一致 |
| `nurse_yui_worried` | 「あれ、ちょっと様子が心配ですね。」 | 2.85s | `821b2ccc4c28` | 一致 |
| `nurse_yui_tired` | 「ふう、さすがに足がパンパンですね。」 | 3.41s | `0fb228353aca` | 一致 |
| `nurse_yui_surprised` | 「えっ、ちょっと予想外ですよ。」 | 2.58s | `c91532fb9360` | 一致 |
| `nurse_yui_timeout` | 「看護ポジション、いつでもいけますよ。」 | 3.13s | `5581f9219483` | 一致 |
| `nurse_yui_or_clear` | 「手元の連携はばっちりです、続けてください。」 | 3.52s | `82abab59bf14` | 一致 |
| `nurse_yui_or_caution` | 「先生、ちょっと待ってください、確認します。」 | 3.00s | `cb63b77ebabb` | 一致 |
