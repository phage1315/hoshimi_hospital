# 白日梦三事件测试入口验收

日期：2026-11-02

## 实装

- 标题画面 `开发者工具 · F10` → `事件测试中心` 新增唯一入口：`白日梦 · 三事件测试`。
- 入口打开专用三事件列表：弘子／江美子篇、千早篇、瑞穗篇。
- 开发测试入口使用干净内存状态并绕过正式解锁 gate，但不修改正式 gate。
- 列表、确认页、播放页及完成／退出都复用正式白日梦 View 和 VN Session。
- 完成或中途退出返回事件测试中心；测试期间禁止存档，不覆盖玩家存档。
- 新增中文与英文 UI 文本。

## A. 静态／双语

- `narrative_localization_test.py`：30631 checks，0 failures。
- `localization_audit.py`：通过；792/792 个引用的英文 UI key 已翻译。
- 两份 localization JSON 与 daydream index 均通过 JSON 解析。

## B. Headless

- `daydream_mode_test.gd`：400 checks，0 failures。
- `title_screen_ui_test.gd`：42 checks，0 failures。
- 覆盖：唯一入口、三按钮启用、逐一创建真实 Session、首篇完整结束返回测试中心、其余中途退出返回、仅内存稳定 read fact、事件内 snapshot 为空。

## C. 原生窗口

- 非 headless Godot 4.5.1，Compatibility/OpenGL 4.1 Metal。
- 路径：标题 → 开发者工具 → 事件测试中心 → 白日梦三事件测试。
- 中文和英文各启动三个真实事件，共 6 次：F01_001、F02_001、F03_001。
- 每次中途退出均返回事件测试中心，时间不变、未写已阅事实。
- 104 checks，0 failures；进程退出码 0。
- 合成 GUI 输入：鼠标 26 次、回车 2 次。
- `engine.log` 无 `ERROR`、`SCRIPT ERROR`、缺失资源或无效字典访问。

关键截图：

- `zh_CN_event_test_hub.png`
- `zh_CN_daydream_test_catalog.png`
- `zh_CN_FANTASY_HIROKO_EMIKO_OR_01_start.png`
- `zh_CN_FANTASY_CHIHAYA_PREOP_OR_01_start.png`
- `zh_CN_FANTASY_MIZUHO_OR_SOLO_01_start.png`

机器记录见 `native.json`。

## D. 未覆盖

- 本轮原生测试只验证入口、三个真实首节点和退出返回；三个事件的完整逐句播放不在本轮范围。千早篇已有独立完整原生窗口记录。
- 英文模式入口和正文加载已验证，但三个剧本正文仍沿用当前中文原文 fallback。
- 未执行导出 PCK／Windows 包内验证。
