# 南条 小夜香（`doc_sayaka`）日语声线候选 v1

- 角色：南条 小夜香（`doc_sayaka`）。用户指定方向：明艳带着懒洋洋撒娇感（二十五岁上下成年女性，中音区丰润蜜感、语速微慢松弛、句尾元音柔和拖长带气音撒娇尾韵）。
- OpenAI 原创 prompt voice：`voice_6af56ca280988191ba228faa5add48c0`，真实 API 返回值见 `voice.json`。创建一次，确认通过后复用，不重复创建。
- AI 生成试听：`audition.wav`（时长 6.78s），台词「おはよう、先生。なんだか今日、ちょっと甘やかしてほしい気分かも。」；API 返回转写与请求逐字一致。原始 24kHz 单声道 16-bit PCM 流封装见 `audition_raw.wav`（及 `sample_take1/`）。试听仅修剪尾部静音，未调音高、变速或加滤波。
- `request.json` 保存声线创建请求；`sample_request.json` 保存 GPT-Live 会话配置；`sample_events.json` 保存非音频事件与最终用量；`sample_result.json` 保存校验和及状态。
- 状态：技术检查通过，**主观音色待用户试听确认；尚未接入游戏运行目录**。密钥仅从本机仓库外私有文件读取，未写入仓库。
