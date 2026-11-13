# 神宫寺成美日语声线候选 v1

- 角色：神宫寺成美（doc_aoi）。用户指定三十岁出头、成熟女性、磁性、稳重而带些许轻佻。
- OpenAI 原创 prompt voice：`voice_6af55eeacd408191b54e9993e95cc0ce`，真实 API 返回值见 voice.json。创建一次，后续复用，不重复创建。
- AI 生成试听：`ohayou.wav`，台词「おはようございます。」；API 返回转写与请求一致。原始 PCM 流封装见 ohayou_raw.wav。试听只修剪前后静音，保留原音频与所有服务端事件；未调音高或变速。
- request.json 保存声线描述；sample_request.json 保存 GPT-Live 会话配置；sample_events.json 保存原始非音频事件及用量；sample_result.json 保存格式、修剪范围、校验和及状态。
- 语音身份及试听成功生成，音色主观验收待用户试听；尚未接入游戏对白，也未修改剧情或存档。
- API key 仅从仓库外私有文件读取，未写入资源或记录。首次沙箱 DNS 不可用；经授权联网创建成功。首次 WebSocket 带默认 Origin 返回403，服务器连接 suppress_origin=True 后成功。不能据首次403认定账户无权限。
- 本轮仅使用用户授权的声线描述和一句问候语，未上传项目原稿、图片或既有音频。
- 技术依据：https://developers.openai.com/api/docs/guides/custom-voices 、https://developers.openai.com/api/docs/guides/voice-websockets?api=live 。
