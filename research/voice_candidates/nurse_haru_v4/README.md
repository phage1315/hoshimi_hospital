# 七瀬 恋（`nurse_haru`）日语声线候选 v4

- 角色：七瀬 恋（`nurse_haru`）。声线设计方向：清甜可人的高音少女声线（21岁年轻护士，采用实测稳定落在320–350Hz少女甜区的高音女高音描述，晶莹清甜、声线纤巧轻盈、带温柔盈盈笑意）。
- OpenAI 原创 prompt voice：`voice_6af61bf99f2c8191b97b1062370ca368`，真实 API 返回值见 `voice.json`。创建一次，确认通过后复用，不重复创建。
- AI 生成试听：`audition.wav`（时长 5.94s），台词「おはようございます、坂口先生。えへへ、今日も一日よろしくお願いしますね。」；API 返回转写与请求逐字一致。原始 24kHz 单声道 16-bit PCM 流封装见 `audition_raw.wav`（及 `sample_take1/`）。试听仅修剪尾部静音，未调音高、变速或加滤波。
- `request.json` 保存声线创建请求；`sample_request.json` 保存 GPT-Live 会话配置；`sample_events.json` 保存非音频事件与最终用量；`sample_result.json` 保存校验和及状态。
- 状态：技术检查记录见 `sample_result.json`，**主观音色待用户试听确认；尚未接入游戏运行目录**。密钥仅从本机仓库外私有文件读取，未写入仓库。
