# 阿尔托莉雅·潘德拉贡（`doc_artoria`）日语声线候选 v1

- 角色：阿尔托莉雅·潘德拉贡（`doc_artoria`）。声线设计方向：澄澈凛然的骑士型正气女声（28岁外科副部长，中高音区纯净挺拔、端正庄重、气息沉稳有力而诚挚坚定）。
- OpenAI 原创 prompt voice：`voice_6af60fb85ba48191b620c1cc5932552e`，真实 API 返回值见 `voice.json`。创建一次，确认通过后复用，不重复创建。
- AI 生成试听：`audition.wav`（时长 7.18s），台词「おはようございます、坂口先生。本日の手術計画、共に最善を尽くしましょう。」；API 返回转写与请求逐字一致。原始 24kHz 单声道 16-bit PCM 流封装见 `audition_raw.wav`（及 `sample_take1/`）。试听仅修剪尾部静音，未调音高、变速或加滤波。
- `request.json` 保存声线创建请求；`sample_request.json` 保存 GPT-Live 会话配置；`sample_events.json` 保存非音频事件与最终用量；`sample_result.json` 保存校验和及状态。
- 状态：技术检查记录见 `sample_result.json`，**主观音色待用户试听确认；尚未接入游戏运行目录**。密钥仅从本机仓库外私有文件读取，未写入仓库。
