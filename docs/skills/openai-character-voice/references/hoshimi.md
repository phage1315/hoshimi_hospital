# 《星见医院》当前接入事实

先读项目AGENTS.md和docs/HANDOFF.md，检查git status与相关diff；不覆盖其他agent的工作。仓库内`docs/skills/openai-character-voice/`为本skill可移植源，本机个人目录保存安装副本。

- 声线登记：`docs/character_voice_ids.md`。
- 成美稳定角色ID：`doc_aoi`；已认可真实声线：`voice_6af55eeacd408191b54e9993e95cc0ce`。
- 创建凭据（非密钥）：`research/voice_candidates/doc_aoi_v1/voice.json`；原描述`request.json`。
- 日语早安试听：同目录`ohayou.wav`；timeout：`timeout_v1/timeout.wav`。
- 正式资源：`assets/audio/voice/doc_aoi/{ohayou,timeout}.wav`；原样导入清单`research/imports/voice_doc_aoi_2026-11-11.json`。
- 早安绑定`introduction/aoi_welcome`，并非Lv1事件；timeout在共用普通手术`team_confirmations`中成美担任`assistant_surgeon`且确认成功后播放。
- 播放器：`godot/ui/voice_director.gd`，由`godot/ui/app.gd`同步；中英字幕原文不变，使用同一日语语音。仅运行内存去重，禁止向玩家存档写播放进度。
- 此用户本机私有key路径为`~/.config/hoshimi/openai-api-key`；只在本机存在且已获授权时使用。文件不随skill打包，不要求用户在聊天粘贴密钥。
- **固定前缀自动放行入口（推荐统一使用）**：仓库内提供固定可执行入口 `tools/voice_runner/hoshimi-voice`（含 `.gdignore`，自动调用仓库 `.venv/bin/python` 内的 `websocket-client` 并默认在进程内读取 `~/.config/hoshimi/openai-api-key`）。先在沙盒内准备好任务清单 JSON（如 `/private/tmp/hoshimi_voice_job.json`），联网执行时只单独运行固定前缀命令 `tools/voice_runner/hoshimi-voice run /private/tmp/hoshimi_voice_job.json`（不套 `python3 <临时脚本>`、`PYTHONPATH=`、`&&` 或 `$VAR`），这样用户在 Antigravity／IDE 点一次 Always Allow 后即可前缀匹配自动放行后续声线／语音包任务。详见 `tools/voice_runner/README.md`，工作区技能同步镜像于 `.agents/skills/openai-character-voice/SKILL.md`。
- 新增生成素材通常保存在`research/voice_candidates/<角色版本>/<take>/`。用户认可或指定接入后才复制到assets运行目录，保留来源／校验和，更新声线表和交接。
- 运行时修改需按范围执行`tools/voice_integration_test.gd`、`tools/bgm_integration_test.gd`，以及剧情规则要求的`tools/narrative_localization_test.py`和`tools/localization_audit.py`。Godot使用独立`/private/tmp`日志与隔离测试存档，不访问玩家槽位；原生听音和headless分别报告。

另一个账号／项目可能无权使用该ID；此处记录不代表跨账号可移植授权。ID与音频文件可以登记共享，API访问仍由对应账号权限决定。
