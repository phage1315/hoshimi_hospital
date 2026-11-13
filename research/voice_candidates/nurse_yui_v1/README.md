# 朝倉 美幸（`nurse_yui`）日语声线候选 v1

- 角色：朝倉 美幸（`nurse_yui`）。用户指定方向：带小恶魔感的明艳女声（二十岁出头成年女性，中高音区明亮华丽有弹性、节奏轻快清脆、尾音俏皮微扬）。
- OpenAI 原创 prompt voice：`voice_6af56c8135488191aa4da5d142aa91d0`，真实 API 返回值见 `voice.json`。创建一次，确认通过后复用，不重复创建。
- AI 生成试听：`audition.wav`（时长 5.32s），台词「おはようございます、先生。ふふ、今日も楽しみですね。」；API 返回转写与请求逐字一致。原始 24kHz 单声道 16-bit PCM 流封装见 `audition_raw.wav`（及 `sample_take1/`）。试听仅修剪尾部静音，未调音高、变速或加滤波。
- `request.json` 保存声线创建请求；`sample_request.json` 保存 GPT-Live 会话配置；`sample_events.json` 保存非音频事件与最终用量；`sample_result.json` 保存校验和及状态。
- 状态：技术检查通过，**主观音色待用户试听确认；尚未接入游戏运行目录**。密钥仅从本机仓库外私有文件读取，未写入仓库。
