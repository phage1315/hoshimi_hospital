# v0.1 朋友试玩版导出

项目使用 Godot 4.5.1 Standard 和 Compatibility 渲染器。仓库已提供 `Windows Desktop` 与 `macOS` 两个 release 导出预设；公开试玩版本号为 `0.1.0`。

## 一次性准备

1. 用 Godot 4.5.1 打开工程。
2. 选择 **Editor → Manage Export Templates**。
3. 安装与编辑器完全相同版本的 Export Templates。至少安装 Windows x86_64 与 macOS；如果模板管理器提供 ICU Data，也一并安装以保证中日韩文字支持。
4. 选择 **Project → Export**，确认可以看到 `Windows Desktop` 和 `macOS` 两个预设。

工程使用系统字体回退顺序 `PingFang SC → Noto Sans CJK SC → Microsoft YaHei → sans-serif`。常规 Windows 10/11 和 macOS 测试机不需要额外安装字体。

## 图形界面导出

在 **Project → Export** 中选择预设并点击 **Export Project**：

- Windows 输出为 `exports/HoshimiHospital-v0.1-Windows/HoshimiHospital.exe`。不要只发送 EXE；同目录生成的 PCK 也必须一起发送。将整个文件夹压缩成 ZIP。
- macOS 输出为 `exports/HoshimiHospital-v0.1-macOS.zip`。ZIP 内含 Universal 2 `.app`，可在 Intel 和 Apple Silicon Mac 上运行。

## 一键导出

安装模板后，可在终端运行：

```sh
cd /Users/ningye/Documents/Codex/2026-09-20/wo/outputs/hoshimi-hospital
./tools/build_playtest_v0_1.sh
```

如果 Godot 不在 `/Applications/Godot.app`：

```sh
GODOT_BIN="/你的路径/Godot.app/Contents/MacOS/Godot" ./tools/build_playtest_v0_1.sh
```

脚本会生成两个可直接上传的 ZIP，并打印 SHA-256 校验值。

## 发给朋友时

Windows 玩家解压整个文件夹后运行 `HoshimiHospital.exe`。当前试玩版未进行 Windows 商业代码签名，SmartScreen 可能显示未知发布者；Godot 预设没有把 PCK 嵌入 EXE，以降低杀毒软件误报并保留以后签名的可能。

macOS 试玩包使用 ad-hoc 签名而未公证。朋友若被 Gatekeeper 阻止，可先把应用移到“应用程序”，在 Finder 中按住 Control 点击应用并选择“打开”。正式公开发布时应使用 Apple Developer ID 签名和公证。

## 发布前检查

- 在真实 Windows 10/11 机器上打开一次，检查中文字体、视频、音频、保存和读取。
- 在另一台 Mac 上解压并打开，检查 Gatekeeper 提示与存档。
- 从标题开始完成至少一次门诊、住院、术前、手术与结算。
- 不要把项目源码目录或 `.godot` 缓存发给试玩者，只发送两个 ZIP。
