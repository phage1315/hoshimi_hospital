# 弘子×江美子白日梦美术接入验收（2026-11-04）

## 接入

- `F01_013`：被强拉进手术室 CG `hiroko_forced_into_or.png`。
- `F01_042`：开腹并撑开腹壁后的 CG `hiroko_or_laparotomy_open.png`。
- 9 个术中表情键映射到 `nervous / panic / indignant / crying / terrified / pain_scream / overwhelmed` 七个透明头像资源。

## 自动审计

- `daydream_three_source_audit.py`：3 篇原稿文本、顺序、人物路径、舞台标记和英文回退均为 0 问题。
- `daydream_mode_test.gd`：711 项，0 失败。
- `narrative_localization_test.py`：33016 项，0 失败。
- `localization_audit.py`：41950/41950 条正文和 796/796 个 UI 键覆盖。

## 可见窗口实机

使用 Godot 4.5.1 非 headless 窗口，从办公室白日梦入口按真实 Lv4 解锁条件进入弘子篇；中英文完整播放、重复进入并提前退出。共 116 个显示页、1206 项检查、0 失败。已实际使用鼠标、空格、回车与自动播放；验证逐页单步、说话人、人物资源、CG、文本容纳、禁止事件内存档、结束返回办公室，以及不改变时间与关系。

- [F01_013 强制进入手术室](local/zh_CN_FANTASY_HIROKO_EMIKO_OR_01_F01_013_0.png)
- [F01_038 痛苦喊叫差分](local/zh_CN_FANTASY_HIROKO_EMIKO_OR_01_F01_038_0.png)
- [F01_042 开腹后 CG](local/zh_CN_FANTASY_HIROKO_EMIKO_OR_01_F01_042_0.png)
- [F01_043 术中羞耻／哭泣差分](local/zh_CN_FANTASY_HIROKO_EMIKO_OR_01_F01_043_0.png)
- [原生测试记录](local/native.json)

原生日志未发现脚本错误或缺失资源。
