# 杉村 弘子（`nurse_hiroko`）日语声线候选 v3

- 角色：杉村 弘子（`nurse_hiroko`）。声线设计方向：兼具自然真人呼吸感与鲜明清甜少女音的温柔护士声线（22岁病房护士，在保留v2自然鲜活质感的基础上提亮至320–350Hz甜美高音少女区，轻盈清甜而温柔体贴）。
- OpenAI 原创 prompt voice：`voice_6af62fb436788191a6e852067f704641`，真实 API 返回值见 `voice.json`。创建一次，确认通过后复用，不重复创建。
- AI 生成试听：`audition.wav`（时长 7.29s），台词「おはようございます、坂口先生。えへへ、今日もいいお天気ですね。無理せず一緒に頑張りましょうね。」；API 返回转写与请求逐字一致。原始 24kHz 单声道 16-bit PCM 流封装见 `audition_raw.wav`（及 `sample_take2/`）。试听仅修剪尾部静音，未调音高、变速或加滤波。
- `request.json` 保存声线创建请求；`sample_request.json` 保存 GPT-Live 会话配置；`sample_events.json` 保存非音频事件与最终用量；`sample_result.json` 保存校验和及状态。
- 状态：技术检查记录见 `sample_result.json`，**主观音色待用户试听确认；尚未接入游戏运行目录**。密钥仅从本机仓库外私有文件读取，未写入仓库。
