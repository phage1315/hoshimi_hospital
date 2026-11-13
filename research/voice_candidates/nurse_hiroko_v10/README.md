# 杉村 弘子（`nurse_hiroko`）日语声线候选 v10

- 角色：杉村 弘子（`nurse_hiroko`）。声线设计方向：对标千早与年轻女护士的清脆俏丽少女高音（18岁级小巧声道高频泛音饱满、甜亮轻快、充满青春少女朝气）。
- OpenAI 原创 prompt voice：`voice_6af642b963888191a8598cef5c298f11`，真实 API 返回值见 `voice.json`。创建一次，确认通过后复用，不重复创建。
- AI 生成试听：`audition.wav`（时长 6.76s，中位基频 `F0=322.3Hz`，高频清晰度 `0.31`，峰值 `-12.4 dBFS`），台词「おはようございます、坂口先生。えへへ、今日も元気に一緒に頑張りましょうね。」；API 返回转写与请求逐字一致。原始 24kHz 单声道 16-bit PCM 流封装见 `audition_raw.wav`（及 `sample_take2/`）。试听仅修剪首尾静音，未调音高、变速或加滤波。
- `request.json` 保存声线创建请求；`sample_request.json` 保存 GPT-Live 会话配置；`sample_events.json` 保存非音频事件与最终用量；`sample_result.json` 保存校验和及状态。
- 状态：技术检查记录见 `sample_result.json`，**用户已确认采用 v10 作为杉村弘子基础声线；尚未接入游戏运行目录**。密钥仅从本机仓库外私有文件读取，未写入仓库。
