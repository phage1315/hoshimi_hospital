# 米田 栞（`nurse_yoneda_shiori`）日语声线候选 v1

- 角色：米田 栞（`nurse_yoneda_shiori`）。声线设计方向：娇小纤细的依恋系纯真少女音（18岁病房护士，音色清甜轻巧如小鸟、柔和澄澈、带试探与亲近依赖感）。
- OpenAI 原创 prompt voice：`voice_6af5fdebf7148191a9dd731fabb91bbc`，真实 API 返回值见 `voice.json`。创建一次，确认通过后复用，不重复创建。
- AI 生成试听：`audition.wav`（时长 5.67s），台词「おはようございます、先生。あの、今日もそばでお手伝いしてもいいですか?」；API 返回转写与请求逐字一致。原始 24kHz 单声道 16-bit PCM 流封装见 `audition_raw.wav`（及 `sample_take3/`）。试听仅修剪尾部静音，未调音高、变速或加滤波。
- `request.json` 保存声线创建请求；`sample_request.json` 保存 GPT-Live 会话配置；`sample_events.json` 保存非音频事件与最终用量；`sample_result.json` 保存校验和及状态。
- 状态：技术检查记录见 `sample_result.json`，**主观音色待用户试听确认；尚未接入游戏运行目录**。密钥仅从本机仓库外私有文件读取，未写入仓库。
