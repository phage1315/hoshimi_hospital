# 背景音乐接入（2026-11-11）

用户提供十六首 MP3（含随后补充的 surgery_1、lounge、prep、Midnight_on_the_Fire_Escape、roof、triage 和 Sunlight_on_the_Chart），按已确认用途原样复制至 `assets/audio/bgm/`。来源、字节数和 SHA256 见 `research/imports/bgm_2026-11-11.json`，原九份及补充文件均与 Downloads 原件一致；补充文件校验记录见 `research/imports/bgm_surgery_1_2026-11-11.json`。没有转码、剪辑、响度归一化或上传。

| 稳定音乐 ID | 原文件 | 当前入口 |
|---|---|---|
| title | title_screen.mp3 | 标题画面 |
| station | Sunlight_on_the_Chart.mp3 | 护士站地点及该场景中无覆盖的事件 |
| triage | triage.mp3 | 门诊看诊、检查 CG、结果及普通转诊页面 |
| lounge | lounge.mp3 | 医院休息室地点浏览页面，优先于四季曲 |
| roof | roof.mp3 | 医院天台地点浏览页面，优先于四季曲 |
| prep | prep.mp3 | 病房开始的术前流程、团队编组、更衣／刷手及入室转场 |
| spring | spring_theme.mp3 | 春日序章章节页及开场全部对白／选项；3–5 月医院导览及地点／办公室管理 |
| summer | summer_theme.mp3 | 6–8 月同上 |
| autumn | autumn_theme.mp3 | 9–11 月同上 |
| winter | winter_theme.mp3 | 12–2 月同上 |
| surgery_1 / surgery | surgery_1.mp3 / surgery_2.mp3 | 进入手术室后、手术视频／CG／扫荡结果；每台等概率抽取一首 |
| advanced_surgery | advance_surgery_1.mp3 | 高级手术运行 session（含团队登场，失败判定后静音）、教程的 advanced_surgery 演出节点及对应回想 |
| advanced_hope | Midnight_on_the_Fire_Escape.mp3 | 高级手术第一天接诊／编组、第三天成功复盘／结算，含首次教程和医护患者 |
| night | night_theme.mp3 | 下班同行（含邀约／告别）及一天结束 |
| ending | ending_theme.mp3 | 登记备用，不绑定现有页面，不循环 |

`godot/ui/music_director.gd` 是独立于页面的双播放器，`app.gd` 按当前展示上下文调度；默认 1.2 秒交叉淡化、整曲循环，同一曲目不重启。跨曲返回从头播放；没有逐曲恢复进度。保存／读取槽位菜单沿用当前音乐。快速切换会取消旧淡化任务并收束旧播放器。

未分配音乐的事件按当前场景选曲，无地点专属曲时使用季节曲。原稿中尚未绑定音频的 BGM 键保留原样并采用此回退；可通过独立覆盖表绑定。

标题设置及普通页面顶部“设置”均可调节 BGM，默认 65%，0 为静音。独立 BGM 总线不影响现有音效／视频声音。音量仅保存在已有 `title_preferences.cfg` 的 `audio.bgm_volume`；没有新增玩家存档字段，播放位置、当前曲目与淡化状态只在内存中。

## 实际验证

引擎为 `/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot`（4.5.1）。

- `--headless --path . --log-file /private/tmp/hoshimi-bgm-import-20261111.log --editor --import --quit`：退出 0，九首资源导入；环境 CA 提示和引擎目录 editor_settings 沙箱写入错误已记录，没有脚本解析错误。
- `--headless --path . --log-file /private/tmp/hoshimi-bgm-final-20261111.log --script res://tools/bgm_integration_test.gd`：59 项／0 失败，退出 0；仅系统 CA 环境提示，结果见 QA headless.log。
- `--path . --log-file /private/tmp/hoshimi-bgm-native3-20261111.log --script res://tools/bgm_integration_test.gd -- --native-preview`：原生窗口 59 项／0 失败，最终日志无脚本或资源错误。自动驱动设置窗口截图已目视核对，无裁切。
- `python3 tools/localization_audit.py`：退出 0，UI 800/800，硬编码中文候选 0。
- 九份源／目标 SHA256 对比通过；相关代码 `git diff --check` 通过。

专项覆盖九首加载、12 月份分配、真实标题／导览／结束页入口、保存菜单连续性、普通／高级手术上下文（隔离内存 fixture）、实际跨循环边界播放、连续快速切换后停止、音量持久化与双语设置。测试槽位与偏好全部重定向独立 `/private/tmp`，未读取或写入玩家槽位。测试早期夹具错误（空 preops、临时对象未清理、只改 locale 未加载译表）均修正后重跑；不是业务代码缺陷。

## 未验收范围

未人工试听整曲、未做响度均衡或音乐循环接缝听感验收；整曲循环不保证原曲作曲／混音层面的无缝。没有逐台普通／高级手术完整通关听音，也未验证导出包。本次未修改剧情原文、翻译或存档格式，因此没有叙事文本重审或存档迁移。

证据：`docs/qa/bgm_2026-11-11/`。保留原有其他 AI 的改动，未 commit 或 push。

## 补充：普通手术双曲随机池

2026-11-11 用户补充 `surgery_1.mp3`，原样复制及导入（179.23 秒）。普通手术第一次需要播放音乐时，按运行中的 Preop 对象身份选定一首，术中翻页／视频／CG 不重抽；新手术重新抽取，允许连续重复。扫荡结果沿用当前台选择或首次抽取，离开该台后清理。选曲使用独立 RandomNumberGenerator，不消耗游戏业务随机序列，不写入玩家存档。高级手术映射不变。

- 引擎 `--headless --path . --log-file /private/tmp/hoshimi-bgm-extra-import.log --editor --import --quit`：退出 0，无脚本解析错误；保留此前 CA／编辑器配置写入环境提示。
- 引擎 `--headless --path . --log-file /private/tmp/hoshimi-bgm-extra-test.log --script res://tools/bgm_integration_test.gd`：97 项／0 失败，退出 0。包括十首解码与循环配置、同台跨页面不重新消耗 RNG、32 个新会话固定种子覆盖两首且不会选到高级曲。
- 新文件源／目标 SHA256 一致，`git diff --check` 通过；日志为 `docs/qa/bgm_2026-11-11/surgery_pool_headless.log`。
- 本次补曲未重跑原生窗口或人工试听；前述原生 59 项仅是原九首版本证据。未更改 UI、剧情或存档契约。

## 补充：休息室专属曲

2026-11-11 原样接入 `assets/audio/bgm/lounge.mp3`，校验记录为 `research/imports/bgm_lounge_2026-11-11.json`。`app.gd` 仅在实际展示地点页面时记录运行中的地点 ID；音乐层对 `screen=location` 且地点为 `lounge` 使用专属循环音乐。休息室刷新及存档菜单不重启，离开后按目标场景选择音乐。未改休息室中角色剧情的音乐规则（尚未指定剧情仍静音）。不新增持久存档字段。

- Godot `--headless --path . --log-file /private/tmp/hoshimi-bgm-lounge-import.log --editor --import --quit`：退出 0，无脚本解析错误；已有 CA／编辑器配置写入环境提示仍存在。
- Godot `--headless --path . --log-file /private/tmp/hoshimi-bgm-lounge-test.log --script res://tools/bgm_integration_test.gd`：104 项／0 失败，退出 0；含十一首资源、正式休息室入口、页面刷新、保存菜单连续播放、返回导览与切换病房恢复季节曲。日志见 `docs/qa/bgm_2026-11-11/lounge_headless.log`。
- 源／目标 SHA256 一致，相关代码 diff 检查通过；本轮未做原生窗口、人工试听或导出验证。测试只使用独立临时偏好与槽位路径。

## 补充：病房准备／团队编组 prep.mp3

2026-11-11 用户指定术前准备曲，原样导入 `assets/audio/bgm/prep.mp3`（80.90 秒），源／目标校验记录见 `research/imports/bgm_prep_2026-11-11.json`。

音乐切换依据正式 Preop 当前阶段的 `scene`：病房开始流程、编组和准备阶段播放 prep，更衣／刷手和入室转场视频保持 prep；入室转场结束后显示 `operating_room` 场景，即开始该台普通手术随机曲。手术台触诊、麻醉等切口前操作已经使用手术曲，不再等待 incision_made。病房准备 CG 依据当前阶段保持相应曲目；高级手术入口规则不变。此处只读取现有场景数据，不改手术步骤或剧情文本。

- Godot `--headless --path . --log-file /private/tmp/hoshimi-bgm-prep-import.log --editor --import --quit`：退出 0，无脚本解析错误；已有 CA／编辑器偏好写入环境提示仍存在。
- Godot `--headless --path . --log-file /private/tmp/hoshimi-bgm-prep-test.log --script res://tools/bgm_integration_test.gd`：115 项／0 失败，退出 0。包含十二首资源；以正式 preop 模板的病房、team、preparation、changing、operating_room 阶段验证选曲，覆盖准备 CG／转场、无 incision_made 的入室切换、同台术中曲目稳定。日志 `docs/qa/bgm_2026-11-11/prep_headless.log`。
- 源／目标 SHA256 一致，git diff --check 通过。未做本轮原生窗口、人工试听、完整手术通关或导出验证；隔离测试不访问玩家槽位。没有存档格式修改，音乐状态仍仅在内存中。

## 补充：高级手术第一天与第三天成功曲

2026-11-11 原样接入 `Midnight_on_the_Fire_Escape.mp3`（177.61 秒），音乐 ID 为 `advanced_hope`，循环播放；源／目标一致性记录为 `research/imports/bgm_advanced_hope_2026-11-11.json`。

- 高级病例选择／第一天接诊、编组和已预约等待使用新曲；资格未开放页不播放。
- 第二天运行手术沿用 `advance_surgery_1.mp3`，成功结果在第二天不提前触发第三天曲；无运行 session 的第二天等待页保持静音。
- 第三天到达预约复盘日且 outcome 成功、成功结算摘要和首次完成后续剧情使用新曲。未到复盘日的旧预约不提前播放。
- session 已结束且失败、失败 outcome、失败结算／复盘对白均选择静音，经已有淡出停止播放；不会回退为第一天曲。
- 同一规则覆盖高级医护患者的接诊与成功／失败分支；其夜间剧情不套用接诊曲。固定首次教程第一／三天（既定成功剧情）及对应回想使用新曲，第二天手术节点保持原曲。没有修改任何作者文本或事件数据。

验证：最终引擎导入命令 `--headless --path . --log-file /private/tmp/hoshimi-bgm-hope-import-final.log --editor --import --quit`；专项 `--headless --path . --log-file /private/tmp/hoshimi-bgm-hope-test2.log --script res://tools/bgm_integration_test.gd` 为 135 项／0 失败、退出 0，覆盖十三首资源、真实普通／医护高级控制器的内存状态分支、正式教程章节与回想选曲。`python3 tools/narrative_localization_test.py` 44387 项／0 失败；`python3 tools/localization_audit.py` 68508 条、UI 800/800 通过。源码 diff 检查及源／目标 SHA256 一致性通过。证据为 QA 中 `advanced_hope_*.log`。

首次导入发现 GDScript `is preload(...)` 语法错误，已改为具名脚本常量并重跑通过；最终导入状态见交接记录。未重跑原生窗口、人工试听或导出包。测试只用独立临时槽位与偏好，未修改业务逻辑、存档格式或消耗游戏随机序列。

## 补充：天台 roof.mp3

2026-11-11 原样接入 `assets/audio/bgm/roof.mp3`，校验记录见 `research/imports/bgm_roof_2026-11-11.json`。音乐层对 `screen=location` 且地点 ID 为 `rooftop` 播放 roof（循环），刷新和存档菜单不中断；离开后选择目标场景的音乐。未改变天台中剧情事件的既有音乐规则，未修改剧情或存档格式。

- Godot `--headless --path . --log-file /private/tmp/hoshimi-bgm-roof-import.log --editor --import --quit`：退出 0，无脚本解析错误；已有 CA／编辑器配置写入环境提示仍存在。
- Godot `--headless --path . --log-file /private/tmp/hoshimi-bgm-roof-test.log --script res://tools/bgm_integration_test.gd`：142 项／0 失败，退出 0；覆盖十四首资源、正式天台入口、刷新／存档菜单连续性、切换休息室及返回季节导览。证据 `docs/qa/bgm_2026-11-11/roof_headless.log`。
- 源／目标 SHA256 一致，git diff --check 通过；本轮未做原生窗口、人工试听及导出验证。测试只使用隔离临时槽位／偏好路径，未访问玩家槽位。

## 修正：开场事件全程春日主题

2026-11-11 按用户实玩反馈，`opening_chapter` 与 `dialogue`（`data/dialogue/introduction.json` 的专用序章 UI）统一选择 spring。标题画面仍使用 title；章节页进入序章、翻页／选项切换、接回春季导览均不会重新启动同一首曲目。仅修改音乐路由，没有改剧情、译文或存档。

验证命令：引擎 `--headless --path . --log-file /private/tmp/hoshimi-bgm-opening-test.log --script res://tools/bgm_integration_test.gd`：236 项／0 失败、退出 0；覆盖中英各 28 个开场节点、分页及选项分支呈现，检查播放器身份与播放位置，章节页／开场／导览连续播放及返回标题换曲。`python3 tools/narrative_localization_test.py` 44387 项／0 失败；`python3 tools/localization_audit.py` 68508 条、UI800/800通过。git diff --check 通过。证据为 `docs/qa/bgm_2026-11-11/opening_*.log`。

测试使用独立临时槽位和偏好，无玩家槽位访问；仅有既有 headless 系统 CA 提示，无脚本错误。本轮没有原生窗口／人工听音／导出验证，未改音频文件。

## 补充：门诊看诊 triage.mp3

2026-11-11 原样接入 `assets/audio/bgm/triage.mp3`，校验记录为 `research/imports/bgm_triage_2026-11-11.json`。`encounter`（含问诊／检查／诊断／住院结果）、`examination_cg` 与普通 `referral` 页面循环播放 triage；刷新和保存菜单不重启，离开看诊恢复目的场景音乐。门诊地点浏览仍为季节曲，高级转诊不受此映射影响。

- Godot `--headless --path . --log-file /private/tmp/hoshimi-bgm-triage-import.log --editor --import --quit`：退出 0，无脚本解析错误；有既有 CA／编辑器配置写入环境提示。
- Godot `--headless --path . --log-file /private/tmp/hoshimi-bgm-triage-test.log --script res://tools/bgm_integration_test.gd`：265 项／0 失败、退出 0，覆盖十五首资源，正式 visit_sora 接诊以及 11 个实际会话动作至住院结果的显示和播放连续性，检查 CG／转诊／保存页路由，返回导览与门诊地点恢复季节曲。日志为 `docs/qa/bgm_2026-11-11/triage_headless.log`。
- 源／目标 SHA256 一致、git diff --check 通过。未改对白／业务／存档格式；测试只用隔离临时槽位和偏好路径。未做本轮原生窗口、人工试听或导出验证。

## 当前规则：护士站与通用事件地点回退（取代此前未指定事件静音的策略）

2026-11-11 按用户要求原样接入 `Sunlight_on_the_Chart.mp3`（177.55 秒），校验见 `research/imports/bgm_station_2026-11-11.json`。

- 地点专属曲：station／nurses_station → station；lounge／staff_lounge → lounge；rooftop → roof。其他地点默认当前游戏月份的季节主题。
- 事件依据 UI 实际显示的 background_id，而非启动事件时的地点或旧页面残留地点；场景切换同步换曲。人物、特殊事件及回想、白日梦、微事件、闲谈、惠惠等页面统一使用这一回退。不改变作者节点、对白或事件顺序。
- 开场春日、门诊看诊、准备／手术、下班同行／一天结束、高级手术第一天和第三天成功等已指定规则继续优先；高级失败仍明确静音。此前未指定曲目的高级等待／夜间叙事改用季节回退，成功曲仍不会提前播放。
- 存档菜单及特殊事件黑幕沿用正在播放的曲目；同曲请求不重播。

### 后续覆盖配置

新增 `data/audio/bgm_overrides.json`（由 MusicDirector 只读加载，不属于玩家存档），目前三个映射均为空：

- `events`：键为事件 ID，值为已登记音乐 ID，用于整段事件。
- `nodes`：普通事件键为 `事件ID/节点ID`；特殊事件可用 `事件ID/章节ID/节点ID`，避免不同章节同名节点互相影响。
- `bgm_keys`：将原稿已有 `bgm_key` 绑定到已登记音乐 ID。未绑定的原稿键不修改、不虚构音频，仍走地点／季节回退。
- 值 `""` 表示**明确静音**，不是缺少覆盖。节点覆盖优先于事件覆盖，再次为 bgm_key 绑定；无覆盖才走已有专项规则／地点／季节。单节点覆盖只对该节点生效，不隐式延续到后续节点。
- 加载时检查配置结构与音乐 ID；非法配置显式报错。事件级和节点级读取目前支持人物／特殊事件、其回想及白日梦；微事件和闲谈提供事件级覆盖。高级手术控制器的失败静音与日期规则独立保留。

所有显示背景、节点上下文与播放器状态只在内存中，未新增任何玩家存档字段；用户音量仍仅属界面偏好。

### 验证

- 引擎 `--headless --path . --log-file /private/tmp/hoshimi-bgm-station-import.log --editor --import --quit`：退出0，无脚本解析错误；保留已有 CA／编辑器配置写入环境提示。
- 引擎 `--headless --path . --log-file /private/tmp/hoshimi-bgm-station-final.log --script res://tools/bgm_integration_test.gd`：291项／0失败、退出0。包括十六首资源、正式护士站及 `intro_nurse_yui` 事件连续播放、隔离节点场景移动、事件／节点静音优先级、同名节点的章节区分、bgm_key绑定／未绑定回退、六类事件表面、四季回退、已有高级失败静音等回归。
- `python3 tools/narrative_localization_test.py`：44387项／0失败；`python3 tools/localization_audit.py`：68508条、UI800/800通过。源／目标 SHA256 一致，git diff --check通过。
- QA 证据 `docs/qa/bgm_2026-11-11/station_fallback_*.log`。本轮未做原生窗口、人工试听、全部事件通关或导出验证；未访问玩家槽位，测试只使用独立临时路径及内存夹具。
