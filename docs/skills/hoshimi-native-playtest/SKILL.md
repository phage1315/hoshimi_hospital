---
name: hoshimi-native-playtest
description: 对《星见医院》Godot 项目执行可见原生窗口剧情实机测试，复用现有测试驱动、隔离内存前置、GUI 输入和渲染截图；用于事件／白日梦／角色剧情的播放、立绘、交互与返回验收，并明确区分静态审计、headless 回归及原生显示结果。
---

# 星见医院原生窗口实机测试

## 已验证的执行路径

项目：`/Users/ningye/Documents/Codex/2026-09-20/wo/outputs/hoshimi-hospital`

Godot：`/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot`

先核实路径，用户提供的新路径优先。不要因 PATH 中没有 godot 就要求安装或宣称无法运行。

核心方法：通过 exec_command 启动**不带 --headless** 的 Godot 测试驱动；驱动实例化真实主场景，在可见窗口中通过 `root.push_input()` 操作 GUI，并在实际绘制后保存截图。准确称为“原生窗口、合成 GUI 输入测试”；不能声称是人工点击或 OS 级键鼠测试。

CUA 适合人工式操作及补充观察，但不是执行这种原生测试的前提。macOS 编辑器和游戏可能共用 `org.godotengine.godot`，CUA 会反复选中编辑器或超时；出现这种情况不要重复点击同一无效按钮、反复启动游戏或要求用户重装。改用已有原生测试驱动。用户明确要求 OS 级键鼠操作时，另行报告该部分限制；不得拿合成输入冒充。

## 读取与复用

1. 阅读项目 `agents.md`／`AGENTS.md`、`docs/native_event_test_runbook.md`，检查 Git 状态并保留已有改动。既有 QA 报告是方法参考，不代表当前代码验证结果。
2. 搜索 `tools/` 下专项测试，先审查后复用，避免另建平行测试系统。已验证参考：
   - `tools/miyuki_lv3_retest.gd`：原生鼠标／空格／回车／自动播放、逐句审计和截图。
   - `tools/miyuki_lv3_return_test.gd`：隔离检查点的退出／完成返回补测；不能当完整通关证据。
   - `tools/chihaya_daydream_native_test.gd`：办公室白日梦真实按钮入口、两种 locale 各 46 节点、结束／重复进入／中途退出。
   - `tools/daydream_mode_test.gd`：逻辑回归，不能替代原生显示验收。
3. 仅在现有驱动不能覆盖目标时，增加最小专项测试。审计相关原稿时保留用户文本，不重跑导入器或改写剧情来让测试通过。

## 隔离前置与入口

- 在 `root.add_child(app)` **之前**给 `app.saves.path` 指定一个未使用的隔离临时路径，避免启动读取玩家槽位。不要从玩家存档提取前置，也不覆盖玩家文件。
- 用内存配置目标事件实际要求的业务事实，不修改生产解锁规则。阅读目标 gate 和相关 staff membership 条件，不能复制其他角色的日期／等级。
- 千早白日梦已知前置例：`patient_chihaya` 已认识、Lv4，且 `chihaya_mizuho_nurse_return` 已完成；`staff_is_met()` 还检查返院事件，仅设 `met=true` 和 Lv4 不足以通过。以当前代码为准。
- 准备后先断言 gate；不满足就修正夹具，不继续产生大量下游假失败。
- 通过真实按钮／地图地点调度／周日邀请进入，说明调用了哪些入口。直接 `show_player_office()` 后点白日梦应报告为“隔离前置下办公室入口”，不称“标题测试中心已验证”或“新游戏自然解锁已验证”。
- 存档边界仍只有医院导览／周日安全界面。测试结果是不可用于恢复的 QA 观察，不写事件会话快照、重放路径或中途存档。完成事实、时间与奖励按项目存档契约验收。

## 启动和进程管理

先检查已有 Godot 进程。保留用户编辑器；仅管理自己启动且能够明确识别的测试进程，不使用全局 killall。已有驱动正在跑时先读取其 session，不再启动重复实例。

为每轮运行创建新的 QA 输出目录及父目录 `.gdignore`，保留失败记录。示例（将 `<本轮QA绝对目录>` 替换为新建目录）：

```sh
/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot \
  --path /Users/ningye/Documents/Codex/2026-09-20/wo/outputs/hoshimi-hospital \
  --script res://tools/chihaya_daydream_native_test.gd \
  --log-file <本轮QA绝对目录>/engine.log \
  -- --out=<本轮QA绝对目录>
```

朝仓 Lv3 换用 `tools/miyuki_lv3_retest.gd`，并传 `--review=<项目绝对路径>/docs/source/miyuki_lv3/bilingual_review.json`；不要把这个审阅文件用到千早等其他事件。

macOS GUI 启动需要工具的 `sandbox_permissions=require_escalated` 时按审批流程执行。沙箱内退出 134 或首次启动失败不能直接推断项目不可运行。尊重拒绝，不换工具绕过权限。

exec 返回 `session_id` 表示仍在运行，使用 `write_stdin` 读取直到退出；短时轮询，持续给用户进度。提示用户不要点击正在自动推进的测试窗口。进程活着／渲染线程运行／引擎标题输出都不等于测试通过。

## GUI 输入和证据

- 驱动断言 `DisplayServer.get_name() != "headless"`。加载真实 `res://godot/scenes/main.tscn`，不以模拟 UI 代替。
- 鼠标：取实际可见启用按钮的全局中心，发送 MouseMotion，再同帧发送 MouseButton 按下／释放，随后等待帧。滚动列表先确保条目可见。
- 空格／回车：处理按钮焦点，发送 Key 按下／释放并等待帧。逐次断言仅推进一页／一个节点，避免漏句或双跳。
- 完整播放不得使用 `pressed.emit`、直接改 `node_id`、直接 `session.apply()` 或跳至终点代替 GUI 输入。已有此类脚本仅作逻辑／显示检查点，并另补实际输入路径。
- 自动播放须点真实开关、等待真实计时器并确认推进，再关闭；未测就写未测，不能从“显示了自动播放按钮”推断通过。
- 检查实际 Label／RichTextLabel 姓名、正文、分页、溢出，TextureRect 实际资源路径、背景、旁白的立绘清空、比例与遮挡。不要猜节点名称：例如 `vn_dialogue_box()` 的姓名 Label 未必命名为 `DaydreamDialogueSpeaker`。
- 等待 `RenderingServer.frame_post_draw` 后执行 `root.get_texture().get_image().save_png(...)`，确认成功并打开实际截图抽查。不能只读取配置／JSON 推断视觉正确。
- 独立原稿用于逐句文本、说话人与顺序审计；运行数据与显示一致只证明渲染保真，不证明导入忠实。
- 中文和英文分别运行。英文模式能加载或通用本地化测试通过，不代表英文正文已翻译；原文回退／占位符须明确报告。
- “资源映射加载成功”和“姿态、服装、表情符合原稿”分别判断。多个表情键复用同一病房图不能说成存在对应数量的独立术中差分。缺失 CG／音效按实际覆盖登记。

## 回归、包内测试与交付

先运行与本次改动相关的 headless 回归；剧情改动按项目规则运行 `python3 tools/narrative_localization_test.py`、`python3 tools/localization_audit.py`。将它们单独报告，不称实机验收。已有结果必须标明时间／是否本轮重跑。

导出包验收遵循项目 runbook 的包内流程：新临时 ZIP，等待导出进程退出 0 后再打开（savepack DONE 不代表 ZIP 压缩完成），提取实际 PCK 到不含源码／素材的隔离目录，以同一外部测试驱动运行 `--main-pack <PCK>`，此运行也不得带 --headless。导出构建步骤可 headless。比较本地／PCK 的观察和截图。若驱动继承项目 `res://tools/...`，先检查其依赖是否存在于实际 PCK，缺失时调整可移植测试驱动，不把源码加入隔离目录掩盖问题。

发行包另遵循 `docs/export_validation.md` 和 `tools/export_release_checked.py`。macOS 上运行 Windows 导出 PCK 只验证包内逻辑／资源，不能称 Windows EXE／字体／驱动已验收。只做本地窗口测试时明确列出包内测试未完成，不因使用本 skill 自动扩大为发布任务。

交付分为 A 静态／原文／双语审计，B headless 回归，C 原生窗口实际路径与截图，D 未测分支和缺失素材。记录退出码、计数、日志错误、输入种类及范围；给出当前报告和截图路径。历史编辑器错误与本次独立日志区分；失败的夹具调试轮次保留且不算通过。只有运行结果、日志和截图共同支持的范围才标为通过。
