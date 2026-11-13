---
name: openai-character-voice
description: 使用 OpenAI 创建原创角色 Voice ID、复用已登记声线生成对白试听，并保存音频、来源与验收记录。适用于角色少量配音及声线一致性管理；不用于音乐生成或既有录音的声音克隆。
---

# OpenAI 角色语音

为角色创建可复用的原创声线，或用已有 Voice ID 生成指定台词。入口与脚本不依赖 Codex 专属工具；其他 agent 可直接读取本文件并用 Python 执行。仓库内此目录为可移植源；个人 Skills 目录为安装副本，维护时保持一致。

## 开始时

- 先读取目标仓库的协作规则和角色声线登记表；《星见医院》见 `docs/character_voice_ids.md`。查真实 API 返回的 `voice.json`，同一角色默认复用已认可 ID，不因每句台词重新创建。
- 区分“生成试听”“建立新声线”“游戏接入”。用户要求调用 OpenAI 生成指定台词已授权发送该台词与声线描述，不需要再次索取相同许可；仅整理文档或本地导入不授权云端生成。只发送完成该次任务所需的描述与台词，不上传整个剧本或图片。
- 使用声学特征描述原创成人声线；不要把“磁性、成熟、轻佻”等方向擅自换成模仿某位声优。角色原文按用户给定内容保留；“比如／翻成日语”允许在该范围拟句，不授权修改项目字幕。
- 接口会变化。执行前核对[官方接口与排障说明](references/api.md)中的官方链接；本技能记录的是 2026-11-11 已实测路径，不能据此承诺未来账号权限、费用或模型不变。
- 如环境提供 API-key 专用工具，先按其流程使用；否则在进程内读取 `OPENAI_API_KEY` 或用户已配置的私有 key 文件。不要显示密钥、打印环境、把密钥写入脚本／仓库，或把密钥放在命令行参数中。脚本的 `--key-file` 只接收文件路径。

## 执行

使用附带的 [scripts/voice.py](scripts/voice.py)。`--help` 不联网；`--dry-run` 不读取密钥、不联网，写出待审阅请求。每次输出目录必须全新，防止覆盖或误重试。不要为“验证 skill”调用收费接口，离线测试用 [scripts/test_voice.py](scripts/test_voice.py)。

Python 3.9+；render 额外需要 `websocket-client`。在当前环境已有虚拟环境中使用，或按环境规则新建虚拟环境并安装依赖；不要依赖旧聊天中的 `/private/tmp` 包目录。

```sh
python3 -m venv /private/tmp/character-voice-venv
/private/tmp/character-voice-venv/bin/python -m pip install websocket-client
```

路径按当前系统调整。在 skill 目录运行以下示例；项目路径用调用者的实际路径，勿照搬另一台机器的用户名。

### 新声线（仅明确需要时）

将成人声线的语言、音高、音色、质感与节奏写入 `voice-prompt.txt`。先确认登记表中没有可复用条目，再调用一次：

```sh
python scripts/voice.py create --name 'Character Japanese v1' \
  --prompt-file /path/to/voice-prompt.txt --out /path/to/new-voice-v1 \
  --key-file /path/to/private-api-key
```

保存 `voice.json` 的真实 ID；创建响应没有试听音频。网络超时可能发生在服务端已创建之后，不自动重试；先用账号的声线列表／Playground核对结果，再决定是否重发。HTTP认证／额度错误也不盲重试，不能编造 ID 或悄悄换预设声线。

### 使用已登记声线生成台词

将确切台词写入 UTF-8文本文件。复用 `voice.json` 的原描述，单次演绎要求放在 `--direction`。默认日语，可用 `--language` 显式指定。

```sh
python scripts/voice.py render --voice-json /path/to/voice.json \
  --text-file /path/to/line.txt --language Japanese \
  --direction 'Calm surgical timeout confirmation, subtle surgical-mask muffling, fully intelligible. No music or background noise.' \
  --seconds 15 --out /path/to/new-take \
  --key-file /path/to/private-api-key
```

脚本只连接官方API，使用 GPT-Live，发送按实时速率推进的静音输入、收集输出，截止后主动关闭；保留 `session.closed` 用量。`--seconds`为会话活动窗口而非成品长度，短句默认15秒，允许5–60秒；长段分句或调整窗口，不无限等待。保持用户指定模型，用 `--model` 显式传入且先核实兼容性。

## 验收和交付

- 输出：`request.json`、创建时的 `voice.json`，或渲染时的 `raw.wav`、`events.json`、`result.json`。失败保留已有证据，返回非零退出码，不覆盖旧 take。无最终关闭事件时，用量标为未确认。
- API转写与确切台词相同、非静音、格式可加载、会话正常关闭，是技术验收；转写不能证明真实发音完全准确，更不能证明磁性、口罩感或演绎符合要求。向用户提供AI生成试听，区分技术检查与人工听音认可。
- 默认保留原始24kHz单声道16bit WAV。若为试听或接入裁前后静音，另存成品并记录范围、校验和；不要裁进轻声辅音，保留原始音频与来源。后期滤波、变速或变调必须在授权范围内并明确记录，不能把“要求口罩感”写成“已人工听音确认”。
- 台词不符、被截断、API出错或只有静音时，不标记成功。先检查原因；需要重录时新建 take目录、复用原ID，限制尝试次数，持续失败时报告具体障碍。不得无限付费重试。
- 追加角色登记表：稳定角色ID、声线ID、版本、描述来源、语言、试听、认可状态；不要覆盖旧版本。已授权游戏接入才复制到运行素材、绑定节点并验证，不改作者原台词或存档契约。
- 《星见医院》的既有路径和验收入口见 [references/hoshimi.md](references/hoshimi.md)。其他项目不必读取该文件。
