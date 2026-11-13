# 米田 栞（`nurse_yoneda_shiori`）日语声线候选 v2

- 角色：米田 栞（`nurse_yoneda_shiori`）。声线设计方向：甜软娇小的妹妹系高音少女声线（18岁153cm粉发双辫护士，高挑纤细如糖果般清甜的娇小少女女高音、带亲昵依赖与软萌感）。
- OpenAI 原创 prompt voice：`voice_6af61c247c848191892d55aaa0b6a05e`，真实 API 返回值见 `voice.json`。创建一次，确认通过后复用，不重复创建。
- AI 生成试听：`audition.wav`（时长 6.86s），台词「おはようございます、先生。えへへ、今日も先生のそばでお手伝いさせてくださいね。」；API 返回转写与请求逐字一致。原始 24kHz 单声道 16-bit PCM 流封装见 `audition_raw.wav`（及 `sample_take1/`）。试听仅修剪尾部静音，未调音高、变速或加滤波。
- `request.json` 保存声线创建请求；`sample_request.json` 保存 GPT-Live 会话配置；`sample_events.json` 保存非音频事件与最终用量；`sample_result.json` 保存校验和及状态。
- 状态：技术检查记录见 `sample_result.json`，**主观音色待用户试听确认；尚未接入游戏运行目录**。密钥仅从本机仓库外私有文件读取，未写入仓库。
