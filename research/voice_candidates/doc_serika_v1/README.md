# 御園 芹香（`doc_serika`）日语声线候选 v1

- 角色：御園 芹香（`doc_serika`）。用户指定方向：故意带冷感但实则偏少女清透的声线（二十五岁上下成年女性，本音纤细清透偏高具年轻纯粹感，演绎上刻意压平语调保持疏离戒备）。
- OpenAI 原创 prompt voice：`voice_6af56cc1bee08191ba00ac51cd0a142f`，真实 API 返回值见 `voice.json`。创建一次，确认通过后复用，不重复创建。
- AI 生成试听：`audition.wav`（时长 5.18s），台词「おはようございます、坂口先生。用件があるなら、手短にお願いします。」；API 返回转写与请求逐字一致。原始 24kHz 单声道 16-bit PCM 流封装见 `audition_raw.wav`（及 `sample_take1/`）。试听仅修剪尾部静音，未调音高、变速或加滤波。
- `request.json` 保存声线创建请求；`sample_request.json` 保存 GPT-Live 会话配置；`sample_events.json` 保存非音频事件与最终用量；`sample_result.json` 保存校验和及状态。
- 状态：技术检查通过，**主观音色待用户试听确认；尚未接入游戏运行目录**。密钥仅从本机仓库外私有文件读取，未写入仓库。
