# 杉村 弘子（`nurse_hiroko`）日语声线候选 v7

- 角色：杉村 弘子（`nurse_hiroko`）。声线设计方向：清亮透澈的银铃系少女高音（22岁病房护士，彻底剔除poise/soft等压暗词根，锁定高挑清脆、晶莹响亮如晴空银铃般的清透少女声线）。
- OpenAI 原创 prompt voice：`voice_6af634a11ea8819181987e8d4f9a5125`，真实 API 返回值见 `voice.json`。创建一次，确认通过后复用，不重复创建。
- AI 生成试听：`audition.wav`（时长 8.15s），台词「おはようございます、坂口先生。今朝もすごくいいお天気ですね。今日も一緒に頑張りましょうね。」；API 返回转写与请求逐字一致。原始 24kHz 单声道 16-bit PCM 流封装见 `audition_raw.wav`（及 `sample_take2/`）。试听仅修剪尾部静音，未调音高、变速或加滤波。
- `request.json` 保存声线创建请求；`sample_request.json` 保存 GPT-Live 会话配置；`sample_events.json` 保存非音频事件与最终用量；`sample_result.json` 保存校验和及状态。
- 状态：技术检查记录见 `sample_result.json`，**主观音色待用户试听确认；尚未接入游戏运行目录**。密钥仅从本机仓库外私有文件读取，未写入仓库。
