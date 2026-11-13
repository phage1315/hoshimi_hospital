# API 依据与故障处理

核对日期：2026-11-11。官方资料：

- [Custom voices](https://developers.openai.com/api/docs/guides/custom-voices)
- [GPT-Live WebSockets](https://developers.openai.com/api/docs/guides/voice-websockets?api=live)
- [会话及开场讲话](https://developers.openai.com/api/docs/guides/live-conversations)

此路径是从描述生成原创声线：POST `/v1/audio/voices`，保存返回ID；再用GPT-Live输出。不能将这种ID直接交给Speech或Realtime接口。录音定制属于另一条需要参考录音与同意录音的工作流，本skill没有实现。

脚本采用本项目实测过的WebSocket传输；官方也推荐WebRTC，可在目标环境确有需要时适配，但不要为短句试听引入浏览器麦克风权限。连接使用Bearer认证，第一条事件为session.start，收到session.started后再发送指令与静音音频。

故障判断：

- 沙箱DNS失败：按当前工具权限规则请求联网执行，不要求用户重复提供key。
- 403：检查所选API、账号权限与握手，不把它自动归因于Pro或模型资格。项目首次Python默认Origin握手曾403，服务器客户端`suppress_origin=True`后成功；脚本沿用该配置，不禁用TLS。
- 创建超时：可能已创建，停止自动重试并核对账号声线列表。已有成功的voice.json立即复用。
- 模型改写／重复台词或保持沉默：Live不是保证逐字输出的离线渲染器。比较完整转写，保留失败take；不要只拿请求文本充当返回转写。
- 输出持续包含静音：正常会话流可能持续输出静音，不能等待不存在的audio.done事件来判断完成。活动时间到达就关闭，保存最终用量；成品裁静音与原始流分开。
- 缺失session.closed：音频可能可听，但最终用量未确认，脚本返回失败，交付时准确描述。

创建与实际配音的费用规则、账户访问能力应以执行当日官方资料和账号返回为准。此skill不承诺Pro自带API额度，也不替用户领取或配置账单。
