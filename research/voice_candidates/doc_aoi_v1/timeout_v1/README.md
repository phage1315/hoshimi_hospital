# 成美手术 timeout 试听 v1

复用成美已认可的 Voice ID `voice_6af55eeacd408191b54e9993e95cc0ce`，未创建新声线。

- 用户示例：第一助手已就位；本次生成日语「第一助手、準備できています。」。
- 演绎：成熟磁性、稳重的第一助手，在手术timeout中确认准备；生成指令要求轻微手术口罩闷感，保留清晰度。未加后期滤波，效果待用户试听认可。
- AI生成；服务返回转写与请求台词一致，会话正常关闭。24kHz单声道16bit WAV；试听仅修剪前后静音，原始输出另存timeout_raw.wav。
- sample_request.json保存指令与voice ID，sample_events.json保存非音频事件和最终用量，sample_result.json保存验证与校验和。
- 未接入游戏，未修改既有剧情对白；未将密钥写入文件。
