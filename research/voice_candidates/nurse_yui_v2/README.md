# 朝倉 美幸（`nurse_yui`）日语声线候选 v2

- 角色：朝倉 美幸（`nurse_yui`）。声线设计方向：带小恶魔感的青春少女明艳声线（23岁年轻护士，音区清脆甜亮、声线轻盈灵动不显熟龄、尾音俏皮微扬）。
- OpenAI 原创 prompt voice：`voice_6af5fdc3dcc88191808a8aa8deb47256`，真实 API 返回值见 `voice.json`。创建一次，确认通过后复用，不重复创建。
- AI 生成试听：`audition.wav`（时长 4.77s），台词「おはようございます、先生。ふふ、今日もよろしくお願いしますね。」；API 返回转写与请求逐字一致。原始 24kHz 单声道 16-bit PCM 流封装见 `audition_raw.wav`（及 `sample_take1/`）。试听仅修剪尾部静音，未调音高、变速或加滤波。
- `request.json` 保存声线创建请求；`sample_request.json` 保存 GPT-Live 会话配置；`sample_events.json` 保存非音频事件与最终用量；`sample_result.json` 保存校验和及状态。
- 状态：技术检查记录见 `sample_result.json`，**主观音色待用户试听确认；尚未接入游戏运行目录**。密钥仅从本机仓库外私有文件读取，未写入仓库。
