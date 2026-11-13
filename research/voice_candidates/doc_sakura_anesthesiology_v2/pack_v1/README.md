# 樱花（`doc_sakura_anesthesiology`）通用短句语音包 v1

- 复用已认可 Voice ID：`voice_6af619d1ed5481919081e4f0593203f2`（见 `../voice.json`，未新建声线）。
- 生成引擎：OpenAI GPT-Live `gpt-live-1`，24kHz 单声道 16-bit WAV，仅修剪首尾静音，无变速／变调／后期滤波（手术口罩微闷感来自生成指令）。

| Clip ID | 台词 | 时长 | SHA256前12位 | API转写核对 |
| --- | --- | --- | --- | --- |
| `doc_sakura_anesthesiology_ohayou` | 「おはようございます、坂口先生。」 | 2.87s | `fbe08bf886ce` | 一致 |
| `doc_sakura_anesthesiology_otsukaresama` | 「お疲れ様です、坂口先生。」 | 2.86s | `9cee12f78cc4` | 一致 |
| `doc_sakura_anesthesiology_neutral` | 「ええ、問題ありません。」 | 1.78s | `d47ebd173f89` | 一致 |
| `doc_sakura_anesthesiology_smile` | 「ふっ、悪くない手際ですね。」 | 2.33s | `cef076d79c88` | 一致 |
| `doc_sakura_anesthesiology_serious` | 「全身管理は任せなさい、基準は守ります。」 | 3.78s | `c9e677e0e42f` | 一致 |
| `doc_sakura_anesthesiology_worried` | 「バイタルの変動に注意してください。」 | 2.70s | `6173f981ea19` | 一致 |
| `doc_sakura_anesthesiology_tired` | 「ふう、今日の麻酔記録を締めますね。」 | 3.53s | `8c320c3cee2e` | 一致 |
| `doc_sakura_anesthesiology_surprised` | 「ほう、珍しいこともありますね。」 | 2.87s | `16701abcba3b` | 一致 |
| `doc_sakura_anesthesiology_timeout` | 「麻酔と全身管理、準備完了しています。」 | 3.97s | `c01ff9625188` | 一致 |
| `doc_sakura_anesthesiology_or_clear` | 「バイタルは安定しています、続けてください。」 | 3.77s | `858837b5c848` | 一致 |
| `doc_sakura_anesthesiology_or_caution` | 「待ってください、循環動態を確認します。」 | 3.12s | `e36cd0237063` | 一致 |
