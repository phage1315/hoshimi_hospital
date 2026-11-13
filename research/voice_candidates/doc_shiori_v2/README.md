# 藤崎 詩織（`doc_shiori`）日语声线候选 v2

- 角色：藤崎 詩織（`doc_shiori`）。声线设计方向：高辨识度的丝绒微气音清雅才女声线（25岁综合内科医，柔润丝滑的微气音铃音质感、富音乐感的优雅起伏与含蓄好胜笑意尾韵）。
- OpenAI 原创 prompt voice：`voice_6af61a0d40c4819192761ee5920d9611`，真实 API 返回值见 `voice.json`。创建一次，确认通过后复用，不重复创建。
- AI 生成试听：`audition.wav`（时长 7.53s），台词「おはようございます、坂口先生。ふふ、今朝は私の方が少し早かったみたいですね。」；API 返回转写与请求逐字一致。原始 24kHz 单声道 16-bit PCM 流封装见 `audition_raw.wav`（及 `sample_take1/`）。试听仅修剪尾部静音，未调音高、变速或加滤波。
- `request.json` 保存声线创建请求；`sample_request.json` 保存 GPT-Live 会话配置；`sample_events.json` 保存非音频事件与最终用量；`sample_result.json` 保存校验和及状态。
- 状态：技术检查记录见 `sample_result.json`，**主观音色待用户试听确认；尚未接入游戏运行目录**。密钥仅从本机仓库外私有文件读取，未写入仓库。
