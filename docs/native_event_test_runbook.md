# Godot 原生窗口事件测试：启动交接

本说明记录2026-11-02朝仓Lv3实际使用的方法。先读agents.md及待测事件原稿／当前规则，检查Git状态；不要把既有报告当作当前验证。不要重跑剧情导入器，也不要读取玩家存档构造前置。

## 执行文件

本项目已安装可直接使用的Godot4.5.1：

`/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot`

无需用户另行安装Godot或用编辑器点运行。用exec_command启动，下列原生测试命令**不带--headless**。macOS沙箱内可能以134退出；本轮通过工具的sandbox_permissions=require_escalated启动成功。这是本地GUI执行权限，不是游戏或测试缺失，不应据首次沙箱失败宣称无法实机测试。按工具审批结果处理，不擅自绕过拒绝。

## 朝仓Lv3可直接复跑

在项目根目录执行。输出使用新的QA目录，保留旧证据：

```sh
mkdir -p docs/qa/miyuki_lv3_new_run/local
 touch docs/qa/miyuki_lv3_new_run/.gdignore
/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot \
  --path /Users/ningye/Documents/Codex/2026-09-20/wo/outputs/hoshimi-hospital \
  --script /Users/ningye/Documents/Codex/2026-09-20/wo/outputs/hoshimi-hospital/tools/miyuki_lv3_retest.gd \
  --log-file /Users/ningye/Documents/Codex/2026-09-20/wo/outputs/hoshimi-hospital/docs/qa/miyuki_lv3_new_run/local_engine.log \
  -- \
  --out=/Users/ningye/Documents/Codex/2026-09-20/wo/outputs/hoshimi-hospital/docs/qa/miyuki_lv3_new_run/local \
  --review=/Users/ningye/Documents/Codex/2026-09-20/wo/outputs/hoshimi-hospital/docs/source/miyuki_lv3/bilingual_review.json
```

原生窗口会自动打开并逐句推进，需要数分钟。工具短时返回session_id不代表完成，继续用write_stdin读取进程结果。不要中途点击测试窗口干扰合成输入。检查进程退出码、native.json、日志中的ERROR／SCRIPT ERROR以及截图，不能只看窗口启动成功。

补测退出／完成返回：相同Godot启动方式，script换为tools/miyuki_lv3_return_test.gd，传新的--out绝对目录即可，不需要--review。

## 脚本实际做什么

1. extends SceneTree，加载真实res://godot/scenes/main.tscn。在加入树之前把app.saves.path设成未使用的独立临时路径，避免启动读取玩家槽位。
2. 用隔离内存配置事件所需前置，不改生产数据或开关。通过真实地图／地点调度及周日邀请调用进入；这叫“隔离前置下验证正式入口”，不等于从新游戏自然解锁路线。
3. 通过root.push_input(InputEventMouseMotion/InputEventMouseButton/InputEventKey,true)分发真实GUI输入。鼠标按下／松开同帧发送，随后等待帧。空格／回车要注意按钮焦点；不得用直接节点跳转或pressed.emit替代输入验收。
4. 自动播放通过点击游戏现有自动播放按钮打开，等待实际计时器推进，再点击关闭。
5. 检查实际渲染的Label/RichTextLabel、TextureRect.texture.resource_path、背景、分页和边界结算。以独立原稿对照说话人和文本；不能用运行数据自证原稿准确。
6. await RenderingServer.frame_post_draw后，用root.get_texture().get_image().save_png保存原生渲染截图。抽查实际图片及姓名标签，不只读JSON。
7. QA观察记录只用于验收，不作为可恢复游戏的会话快照。存档测试仍只能保存安全边界事实。

主脚本完整正文通过GUI输入，未直接修改内部节点推进。return_test的末尾UI补测有明确标注的隔离终点检查点，仅补验返回行为，不能冒充完整通关证据。

## 导出包也必须跑

本地通过后，用当前Windows Desktop预设导出一个**新的临时ZIP**：

```sh
<Godot绝对路径> --headless --path <项目绝对路径> \
  --export-release 'Windows Desktop' <新的临时目录>/HoshimiHospital.zip \
  --log-file <独立导出日志>
```

只有构建步骤用headless。必须等待构建进程退出0再打开ZIP；savepack显示DONE之后还可能仍在压缩ZIP。确认包内HoshimiHospital.exe和HoshimiHospital.pck文件名不变。将实际PCK解压到不含源码／素材的隔离目录，执行：

```sh
<Godot绝对路径> --path <隔离目录> --main-pack <实际PCK绝对路径> \
  --script <项目中同一个测试脚本绝对路径> --log-file <包内测试日志> \
  -- --out=<包内QA输出目录> --review=<独立双语审阅JSON绝对路径>
```

包内运行也不带headless。外部脚本仅是测试驱动；游戏scene/script/data/assets来自PCK的res://。同一脚本比较本地／包内逐页观察记录与截图哈希，不能只检查ZIP文件存在。

交付新发行包时另使用docs/export_validation.md和tools/export_release_checked.py规定的完整门禁。当前macOS运行Windows导出的PCK验证包内资源和逻辑；不能宣称Windows EXE、Windows字体及驱动已验收。

## 其它事件

先检索tools中已有专项测试并审查，复用相同原理。朝仓的演员日期、Lv2、Fam、周日约会条件不可复制到其它事件。若已有脚本只emit_signal或直接修改node_id，它只能提供逻辑／显示检查点，必须另补GUI输入完整播放。中文与英文分别运行，正式入口、隔离内容播放及演出检查点分别报告。

本次实测记录：docs/qa/miyuki_lv3_retest_2026-11-02/REPORT.md。
