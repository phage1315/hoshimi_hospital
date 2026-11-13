# 成美 Lv1–4／恋 Lv1–3 原生窗口验收

日期：2026-11-09。结论：本轮五篇固定事件的中文、英文原生窗口路径通过，未发现阻塞问题。共同 Lv2、Lv3 各算一篇，不重复算作两篇事件。

本轮只新增测试驱动和证据、更新交接文档，未修改游戏逻辑、剧情、翻译或美术。开工已检查交接及 Git 差异，保留既有未提交修改和用户正在使用的 Godot 编辑器。

## A. 静态／原文／双语审计

以下均为本轮实际重跑，退出码均为 0。详见 [static_results.json](static_results.json) 及同目录原始日志。

| 检查 | 结果 |
| --- | --- |
| `ren_narumi_lv1_source_audit.py` | 恋 220／成美 198 个节点，原文、说话人、分支、英文及素材引用通过 |
| `narumi_ren_shared_lv2_source_audit.py` | 294 个双语节点，0 失败 |
| `narumi_ren_shared_lv3_source_audit.py` | 478 个双语节点，0 失败 |
| `narumi_lv4_source_audit.py` | 148 个双语节点、72 个 H 对白池，0 失败；此处池检查属于静态审计 |
| `narrative_localization_test.py` | 40,366 项，0 失败 |
| `localization_audit.py` | 活跃正文 47,854/47,854；UI 799/799；UI 硬编码中文候选 0 |

## B. Godot headless 自动回归

Godot 4.5.1。四组脚本均退出 0，合计 79,173 项断言、0 失败。这些结果单独列示，不能替代下方可见窗口验收。

| 脚本 | 断言数 | 失败数 |
| --- | ---: | ---: |
| `ren_narumi_lv1_test.gd` | 23,118 | 0 |
| `narumi_ren_shared_lv2_test.gd` | 16,534 | 0 |
| `narumi_ren_shared_lv3_test.gd` | 30,240 | 0 |
| `narumi_lv4_test.gd` | 9,281 | 0 |

日志保留 macOS `get_system_ca_certificates` 环境提示；没有对应游戏脚本或资源加载失败。详见 [headless_results.json](headless_results.json) 和各脚本的日志。

## C. 可见原生窗口实际操作

**方法：原生窗口、合成 GUI 输入测试。** 未使用 `--headless`；Godot macOS 显示服务、OpenGL/Metal Compatibility 渲染器实际创建窗口。复用现有原生测试驱动的 `root.push_input()` 鼠标／空格／回车及截图函数，等待绘制完成后从真实 viewport 保存图片，再打开截图抽查。这不是人工点击，也不是 OS 级键鼠验收。

新增驱动：`tools/narumi_ren_story_native_test.gd`，继承现有 `narumi_ren_shared_lv2_native_test.gd`，复用测试夹具和 GUI 输入，不另建游戏流程。

命令（项目目录为当前工作目录）：

```sh
"/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot" \
  --path "/Users/ningye/Documents/Codex/2026-09-20/wo/outputs/hoshimi-hospital" \
  --script res://tools/narumi_ren_story_native_test.gd \
  --log-file "/Users/ningye/Documents/Codex/2026-09-20/wo/outputs/hoshimi-hospital/docs/qa/narumi_ren_native_2026-11-09/native_run1_engine.log" \
  -- --out=/Users/ningye/Documents/Codex/2026-09-20/wo/outputs/hoshimi-hospital/docs/qa/narumi_ren_native_2026-11-09/native_run1
```

### 路径与覆盖

前置条件在内存中用已有 `prepare_character_event_test_save()` 夹具准备，随后通过正式地点调度、下班按钮或周日邀请进入。没有直接修改当前节点或调用会话推进来替代 GUI 操作。

| 事件 | 实际入口 | 每种语言覆盖的不同节点 | 固定 CG |
| --- | --- | ---: | ---: |
| 成美 Lv1《履历之外》 | 医生共用办公室地点调度 | 198 | 1 |
| 恋 Lv1《夜勤病栋（1）》 | 主角办公室 → 下班按钮 | 220 | 1 |
| 成美／恋共同 Lv2 | 大厅地点调度 | 294 | 4 |
| 成美／恋共同 Lv3 | 检查室地点调度 | 478 | 4 |
| 成美 Lv4《下班以后》 | 周日邀请 → 成美 | 148 | 1 |

- 中文、英文分别完整走全 A 与全 B 路径：共 **20 条完整路径**；每种语言覆盖全部 **1,338 个不同节点**。Lv4 同时检查恋 Lv3／Lv4 条件分支。
- 实际反复访问节点 5,188 次；鼠标 1,893 次、空格 1,794 次、回车 1,792 次、自动推进检查 10 次。
- 每页检查实际对白与说话人，长句分页、一输入一页／一句、选择转向；英文可见文本无中文回退。
- 检查实际加载的角色、服装、表情、背景和 CG 路径；CG 出现与撤除、CG 期间不叠加普通立绘；检查患者头像与对话框接边。
- 每篇走完结算并返回医院导览，核对关系等级、时间、不得重复触发；Lv4 核对自由 H 解锁和周日次数只结算一次。
- 每篇每种语言打开已解锁画廊，点击回放、推进前三页、退出，确认时间和关系不变。此项是回放入口／退出抽测。

最终：**120,927 项断言，0 失败，进程退出 0**。原生独立日志中无 `ERROR`、`SCRIPT ERROR` 或 `WARNING`。详见 [native.json](native_run1/native.json)、[逐页观察](native_run1/observations.json)、[引擎日志](native_run1_engine.log)。

### 截图证据与视觉抽查

共保存 **206 张原生渲染截图**，覆盖 CG 切换、患者差分、服装、选项、结算及画廊。逐页自动核对之外，实际打开抽查全部 11 张固定 CG 的入口截图，以及美佳／弥生患者头像与返回导览截图：

| 内容 | 截图 |
| --- | --- |
| 成美 Lv1 两杯茶与手稿 | [中文](native_run1/zh_CN_narumi_lv1_beyond_the_resume_cg_nar1_142.png) |
| 恋 Lv1 夜班三明治 | [英文](native_run1/en_ren_lv1_night_ward_1_cg_ren1_201.png) |
| Lv2 手术台准备 | [英文](native_run1/en_narumi_ren_shared_lv2_sign_here_cg_nr2_130.png) |
| Lv2 铺巾 | [英文](native_run1/en_narumi_ren_shared_lv2_sign_here_cg_nr2_133.png) |
| Lv2 刀背接触 | [英文](native_run1/en_narumi_ren_shared_lv2_sign_here_cg_nr2_146.png) |
| Lv2 结尾互看 | [英文](native_run1/en_narumi_ren_shared_lv2_sign_here_cg_nr2_287.png) |
| Lv3 清醒手术群像 | [英文](native_run1/en_narumi_ren_shared_lv3_settled_accounts_cg_nr3_184.png) |
| Lv3 最新盆腔术野 | [中文](native_run1/zh_CN_narumi_ren_shared_lv3_settled_accounts_cg_nr3_192.png) |
| Lv3 组织保留 | [英文](native_run1/en_narumi_ren_shared_lv3_settled_accounts_cg_nr3_209.png) |
| Lv3 办公室群像 | [英文](native_run1/en_narumi_ren_shared_lv3_settled_accounts_cg_nr3_387.png) |
| 成美 Lv4 天台咖啡 | [英文](native_run1/en_narumi_lv4_after_work_cg_nar4_119.png) |
| 美佳患者头像接边 | [中文](native_run1/zh_CN_narumi_ren_shared_lv2_sign_here_patient_shimotsuki_mika_patient_patient_anxious.png) |
| 弥生患者头像接边 | [英文](native_run1/en_narumi_ren_shared_lv3_settled_accounts_patient_kunizuka_yayoi_operating_patient_or_tense.png) |
| Lv4 结算后导览 | [英文](native_run1/en_narumi_lv4_after_work_0_end_1_map.png) |

抽查未发现错人、空白图、患者头像悬空或文字溢出。盆腔 CG 按现有 `contain` 完整显示；其他 CG 按各自配置显示，常规对话框会覆盖画面下部。英文长旁白分多页显示，未截掉后续正文。

### 数据与存档隔离

- 主场景进入树之前，将 SaveStore 路径改为本轮唯一的 `/private/tmp/narumi_ren_native_unused_<PID>.json`；没有读取玩家槽位。
- 事件期间逐节点确认 `can_save_progress()` 为 false、`snapshot()` 为空；结束后只检查回到可存档安全界面，没有执行保存。
- 最终确认隔离存档文件未生成。QA 的 observations 是不可用于读档的测试证据，不属于游戏存档。
- 本轮保留用户编辑器；独立测试进程已正常退出。准备阶段一次无显式日志路径的 `--check-only` 被沙箱日志访问阻断；指定 `/private/tmp` 日志路径后语法检查退出 0，不计为成功游戏路径或本轮游戏缺陷。

## D. 未验证范围与素材缺口

- 原生窗口覆盖每个选项的两侧与全部节点，但未穷举 A/B 混合选择组合；混合组合由本轮现有 headless 回归检查。
- 画廊只做入口、前三页和退出；没有在画廊再完整重播五篇事件。
- 没有从新游戏连续培养角色到 Lv4，前置使用内存夹具；正式门槛没有改动。
- 没有重跑成美 H Runner／自由 H 完整交互；本次只验证固定 Lv4 事件及其解锁结果。
- 没有重新导出或执行实际 PCK／发布包对照测试；本结论仅适用于当前本地源码运行。
- 当前五篇已登记立绘与 11 张固定 CG 均可加载，未发现必需素材缺口；不据此宣称未登记的可选 CG 已齐全。
- 本轮窗口尺寸及默认缩放通过；未覆盖其他分辨率、操作系统输入法、窗口缩放与人工连续快速连击。
