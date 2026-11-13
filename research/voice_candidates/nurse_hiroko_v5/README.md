# 杉村 弘子（`nurse_hiroko`）日语声线候选 v5

- 角色：杉村 弘子（`nurse_hiroko`）。声线设计方向：清亮透澈的开阔系少女高音（22岁病房护士，去除甜腻气音雾感，锁定明亮通透、清脆开阔如晴空清泉般的少女女高音，自然鲜活不发闷）。
- OpenAI 原创 prompt voice：`voice_6af6333852888191a633d358cdd53f76`，真实 API 返回值见 `voice.json`。创建一次，确认通过后复用，不重复创建。
- AI 生成试听：`audition.wav`（时长 7.06s），台词「おはようございます、坂口先生。今朝もすごくいいお天気ですね。今日も一緒に頑張りましょうね。」；API 返回转写与请求逐字一致。原始 24kHz 单声道 16-bit PCM 流封装见 `audition_raw.wav`（及 `sample_take2/`）。试听仅修剪尾部静音，未调音高、变速或加滤波。
- `request.json` 保存声线创建请求；`sample_request.json` 保存 GPT-Live 会话配置；`sample_events.json` 保存非音频事件与最终用量；`sample_result.json` 保存校验和及状态。
- 状态：技术检查记录见 `sample_result.json`，**主观音色待用户试听确认；尚未接入游戏运行目录**。密钥仅从本机仓库外私有文件读取，未写入仓库。
