# 千早白日梦手术室头像对齐复测

日期：2026-11-02

- 将 13 个 `intraoperative/*` 病房检查／手术室头像设为 `portrait_y = 272.0`。
- 1536×1024 横向头像实绘为 `(x=910, y=272, w=320, h=213.3333)`，底边约 `485.3333`，贴合对话框上沿并保持右对齐。
- 重新导入前后所有台词、说话人、顺序与选项字段一致。

## A. 静态／双语

- `narrative_localization_test.py`：30631 checks，0 failures。
- `localization_audit.py`：通过；英文正文仍为中文原文 fallback。

## B. Headless

- `daydream_mode_test.gd`：368 checks，0 failures。

## C. 原生窗口

- 非 headless Godot 4.5.1；真实办公室白日梦按钮入口，隔离内存前置。
- 中英文各完整播放 46 节点，共 92 页。
- 新增逐节点断言：实际纹理路径、Y 坐标、底边位置、右侧对齐。
- 987 checks，0 failures；进程退出码 0。
- 鼠标 32、空格 30、回车 30；完成返回、重复进入和中途退出通过。
- `engine.log` 无脚本错误或缺失资源。

关键截图：`zh_CN_F02_012_0.png`、`zh_CN_F02_022_0.png`。

## D. 未覆盖

- 自动播放计时器和导出包内运行不在本轮范围。
