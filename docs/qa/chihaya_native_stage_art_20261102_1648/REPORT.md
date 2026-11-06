# 千早白日梦阶段美术映射原生窗口验收

日期：2026-11-02

## 修复范围

- F02_006–F02_009：保留病房睡衣差分。
- F02_011 完成脱衣和戴手术帽；F02_012 起改用千早 `intraoperative/*` 戴帽检查差分。
- F02_021–F02_042：把原稿的 `operating_room_night` 映射为正式 `operating_room` 背景。
- F02_022–F02_040 的千早对白按表情使用 `intraoperative/*` 手术室差分。
- F02_043：按原稿返回办公室背景。

没有修改台词、说话人、顺序、标点或选项。重新导入前后共 138 个白日梦节点的上述剧情字段逐项一致。

## A. 静态／原文／双语审计

- `python3 tools/narrative_localization_test.py`：30631 checks，0 failures。
- `python3 tools/localization_audit.py`：通过；英文正文当前仍按项目现状使用中文原文 fallback。

## B. Godot headless 自动回归

- `tools/daydream_mode_test.gd`：368 checks，0 failures。
- 首次未指定日志路径时 Godot 在默认 `user://logs` 轮转处崩溃；改用独立 `/private/tmp` 日志后正常退出并通过。该失败不是剧情或资源断言失败。

## C. 原生窗口实际路径

- 非 headless Godot 4.5.1，Compatibility/OpenGL 4.1 Metal。
- 真实主场景；隔离内存前置；从办公室“白日梦”按钮进入目录、确认和播放。
- 中文、英文各完整播放 46 节点，共 92 页；鼠标 32 次、空格 30 次、回车 30 次。
- 检查节点顺序、说话人、分页、文本边界、存档禁用、单次输入单页推进、完成返回、重复进入和中途退出。
- 909 checks，0 failures；进程退出码 0。
- 独立引擎日志无 `ERROR`、`SCRIPT ERROR`、缺失资源或无效字典访问。

关键实绘结果：

- F02_009：`ward.png` + `ward/afraid.png`（睡衣状态）。
- F02_012：`ward.png` + `intraoperative/shy.png`（脱衣戴帽后的病房检查状态）。
- F02_021：`operating_room.png`，旁白不借用角色立绘。
- F02_022：`operating_room.png` + `intraoperative/tense.png`。
- F02_043：`player_office.png`，旁白不借用角色立绘。

完整机器记录见 `native.json`；截图为本目录下 `zh_CN_F02_*.png`、`en_F02_*.png`。

## D. 尚未覆盖／素材边界

- 英文模式已实际加载并播放，但正文仍是中文原文 fallback，不是完整英译。
- 本轮没有测试自动播放计时器；鼠标、空格、回车均已覆盖。
- `intraoperative/*` 是项目现有的裸体戴帽上半身对白差分；当前没有独立的病房全身裸体差分。`operating_table/*` 是非透明的整幅建立镜头，本轮没有把它错误当作逐句透明立绘使用。
- 未进行导出 PCK／Windows 包内验证；本轮范围是本地项目的原生窗口验收。
