# 两项 P1 修复与 40 张原生截图

日期：2026-10-27。版本：main / f95636a22b16c7d2dfd99e9956e32c90b3dba21e，加已有未提交工作区及本次修复。保留原有修改，未提交或推送。

## 修复结果

1. **P1-01 石神初识文字裁切：已修复、复验通过。** `godot/ui/app.gd` 的原文分页加入实际字体、显式换行、空行、换行宽度和行间距的高度检查，同时满足正文与旧式回想容器。未修改台词、标点、说话人或素材。重点复验 `ishi0_011`、`ishi0_064`，中英文正文和回想均可完整分页。修改范围见 [独立差异](app_p1_only.diff)。
2. **P1-02 遥凑初识缺少 10 台手术门槛：已修复、复验通过。** 在 `data/events/special_events/minato_intro.json` 添加现有统一条件 `completed_surgeries / minimum: 10`。依据 `docs/design/HOSHIMI_HARUKA_MINATO_CHARACTER_BIBLE_UPDATED.md` 第 8 节；保留周日条件及优先级。通过周日医院 GUI 入口，中英文分别验证 0、9 台不触发，10 台触发。测试准备使用隔离内存，未在运行时覆写生产事件定义。

## 验证与范围

- [回归结果](regression_results.json)：323 项检查，0 失败；石神 64 节点完整内容路径 × 中英文 × 正文/回想共 4 条路线完成。使用 GUI 输入分发，鼠标 95 次、回车 88 次、空格 87 次、自动播放 4 次。正文结束到完成页、回想到画廊；本次四条路线为隔离内容播放，不冒充正式入口测试。
- 对全部石神节点及额外多行/长句样例核对分页拼接与原文完全相同；实际屏幕姓名、纹理和分页控件观测见 [逐页记录](regression_pages.jsonl)。显示与输入定向复验无新异常，既有说话人及立绘配置保持不变。本次没有重新完成全部原稿情绪与演出终审。
- [入口六组结果](minato_gate_results.json)；另覆盖两语言下日期 5/6/7/13、手术数 0/9/10/11 的资格组合，非周日不触发。此次入口回归不是重新完整播放遥凑全部剧情分支。
- [重点显示复验](reproduction_results.json)、[原生日志](text_recheck.log) 与本目录 `variant_*.png` 保留修复后证据。
- `python3 tools/narrative_localization_test.py`：18431 检查、0 失败，见 [日志](narrative_localization.log)。`python3 tools/localization_audit.py` 已运行，见 [日志](localization.log)。静态译文存在不代表此前已报告的译文语义问题已修复。
- `python3 tools/validate_data.py` 退出 1：仍报告素材路径 schema、特殊事件优先级、角色/出勤配置等范围外错误，详见 [完整日志](data_validation.log)。不将全库校验标为通过。
- 既有 P2（回想背景/时间、短信版式、小夜香 Lv5 英文修订同步）未修改。事件清单保留尚未完成的原稿终审及其他限制。

## 40 张游戏画面

[打开截图索引](screenshots/index.html) · [40 张打包下载](hoshimi_40_screenshots.zip) · [逐张清单](screenshots/manifest.json)

使用 Godot 原生窗口，按内容类别分层随机抽样：看诊、手术/术前、CG、事件、约会各 8 张；中文 20 张、英文 20 张。随机种子 4139303058898592147。40 张均为 1152×720 原生视口图像，图像哈希互不相同。索引支持按类别及语言筛选。

这是隔离内存中的多场景展示采样，部分诊疗阶段和事件节点直接准备内存状态后交由游戏实际界面渲染，不等同于自然游玩完整流程或正式入口验收。约会通过地点按钮进入。未读取或覆盖玩家槽位，未保存事件内部进度；清单是截图观测记录，不是可恢复会话。采样代码为 `tools/game_random_40_screens.gd`，运行记录见 [采样日志](capture_40.log)。采样完成后游戏保留在隔离会话标题界面。
