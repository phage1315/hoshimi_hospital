# 神宫寺成美（doc_aoi）通用情绪与手术语音补全包 v1

- 复用已登记原创 Voice ID：`voice_6af55eeacd408191b54e9993e95cc0ce`（见上级目录 `voice.json`，未创建新声线）。
- `*_take1/` 为标准无网沙箱预检记录（未发起真实联网请求、零费用）；`*_take2/` 为联网 GPT-Live（`gpt-live-1`）正式生成记录，9 条全部一次性通过技术检查（`session_finalized: true`、返回转写与请求台词逐字一致、24 kHz 单声道 16-bit PCM WAV）。
- 每条保留原始 `raw.wav`、`request.json`、`events.json`、`result.json`；成品 `<slug>.wav` 仅保守裁剪尾部（及过长首部）静音，不裁进轻声辅音或呼吸，无变速、变调或后期滤波（`or_clear` 与 `or_caution` 的轻微手术口罩闷感来自生成指令）。

## 清单

| 槽位 | 台词 | 时长（秒） | SHA256 | 用途 |
| --- | --- | --- | --- | --- |
| `otsukaresama` | お疲れ様です、坂口先生。 | 2.96 | `6bef6f31da440449842b9d6d4e782f0aefeb3accf96179c9bbe3a6b3e4734215` | 日常问候／下班同行偶遇 |
| `neutral` | ええ、そうね。 | 1.47 | `af5642f3eb0def04afaef63fad4d0f33dc80a315c2bd5a07c000c0be02ef7133` | 平静应答／片刻闲谈 |
| `smile` | ふふ、悪くないわね。 | 2.09 | `03227e562e1b37f1ac8789c0ab14f3de835fbfe9bfc8d3c2f508b5a4b746a306` | 温和微笑／同行答应／周日约会 |
| `serious` | 焦らないで、順番にいきましょう。 | 3.14 | `eb20d0fdaafe9b01b71376dd16552750f8a4d689649bf526adffddef108eba04` | 认真专注／冷静提醒 |
| `worried` | 少し気をつけた方がいいわね。 | 2.29 | `5a79950ecf9e9c1803116407448a35f9f0bcd86d4dfc0987121864d36e76099c` | 担忧提醒 |
| `tired` | はぁ、やれやれね。 | 2.03 | `024f3763eff4a51e2c4bfa538aef039f0790ad75f6792eb8fcce8edb832fb030` | 疲惫轻叹／邀约婉拒 |
| `surprised` | あら、意外ね。 | 1.31 | `38f2511e8370d57a33b5bbb9e37f25b5720866c3d2a3838961238a3f1b1db141` | 克制微讶 |
| `or_clear` | 視野はクリアよ、続けましょう。 | 2.70 | `17d9820f3e273fe0f41229ffc41ae633c325c3dc443194bef48c7864021f610c` | 术中术野清晰确认／危机解除 |
| `or_caution` | 待って、もう一度確認しましょう。 | 2.56 | `e44700e33f9693bee5d514c9c3390f6bae05f8c02810155b725432ea7fadfd01` | 术中第一助手纠错拦截／生理危机报警 |
