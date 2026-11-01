# 导出资源与事件显示验收

2026-10-31 现行要求：编辑器内事件测试通过，不能单独作为发行包验收。正式交付必须验证实际打包资源，并把本地与包内的媒体和界面观测对照。GUI 直接导出的包仅是候选产物。

## 检查命令

在项目根目录运行（Godot 路径按本机实际安装调整）：

```sh
python3 tools/export_release_checked.py \
  --godot /Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot \
  --output v0.2_20261031/HoshimiHospital.zip \
  --report docs/qa/export_resource_parity_2026-10-31/checked_release
```

已有交付包或报告目录不覆盖；再次运行时使用新目录，但 ZIP、EXE、PCK 必须保持 HoshimiHospital 原名。脚本不发布、不读取玩家槽位、不删素材。中间构建保存在系统临时目录，仅在全部门禁通过后复制至交付路径。

## 门禁

1. 阻止 UI 再引入 `FileAccess.file_exists()` 原文件检查；媒体通过 ResourceLoader 解析导入映射。系统层 JSON 和存档文件仍使用 FileAccess，不做全局替换。
2. 运行 `export_event_resource_test.gd` 原生窗口测试本地工程：加载正式内容引用的媒体，检查各事件显式 CG／立绘／次要角色／音效配置，检查完成奖励和画廊。
3. 正文及回想分别用中文／英文检查千束全部不同资源场景，使用鼠标、空格、回车及自动播放推进，记录当前/下一页媒体、控件尺寸、位置、姓名标签和正文，并截图。
4. 按当前 Windows 预设实际导出 ZIP。提取其中原始 PCK 到独立临时目录，以 `--main-pack` 启动同一测试脚本。脚本在项目外，游戏代码与资源均来自包内；断言原 PNG 不存在，防止误用本地松散资源掩盖缺陷。
5. 本地与包内的资源类型／尺寸、事件显示配置、实际界面文字／姓名／下一页状态逐项一致。截图还须逐张SHA-256完全一致；任何加载、显示断言失败、SCRIPT ERROR、ERROR、两端差异或测试期间生产源码变化都会使门禁失败。源码指纹不一致时必须重测，不把混合版本报告签成通过。

报告只记录观测，不含可恢复会话快照。测试中设置的已完成事件／岗位解锁仅用于隔离内存画廊夹具，不写入玩家进度。

## 范围限制

这是资源导入及导出显示一致性门禁，不替代剧情原稿、全分支、正式入口、结算和安全边界验收。所有资源引用检查不等于所有剧情全流程运行。macOS 原生引擎可加载 Windows 包的 PCK，验证包内代码及导入映射；它不等于 Windows EXE 已启动，也不覆盖 Windows 字体、驱动或操作系统差异。Windows 发行还需在目标系统执行对应实机验收。

禁止以将全部原 PNG 放回发行包、取消 QA/research 排除或降低贴图质量的方式掩盖错误。不要把 `.godot/imported` 与源资源大小重复计算。
