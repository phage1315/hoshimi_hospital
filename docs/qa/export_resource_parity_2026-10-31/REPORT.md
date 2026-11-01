# 事件立绘／CG在发行包缺失：根因与修复

2026-10-31；main/83859092 加现有未提交工作区。本轮只修复媒体存在性检查并新增发布回归，没有改剧本文字、说话人、顺序、图片内容、导出排除范围或玩家存档。

## P1 复现与根因

从用户目录 `v0.2_20261030/HoshimiHospital.zip` 提取实际 PCK，使用 Godot 4.5.1 原生窗口、独立 `/tmp` 工作目录和外部探针启动，游戏代码及资源全部来自包内。

《我就在这里》／当前数据标题《本人就在这里》 (`advanced_referral_tutorial_chisato`) 两项明确复现：

- `assets/events/advanced_referral_tutorial_chisato/chisato_postop_v1.png`
- `assets/events/advanced_referral_tutorial_chisato/cg_sayaka_holds_chisato_v1.png`

对两者：`FileAccess.file_exists=false`、`ResourceLoader.exists=true`、`load()!=null`，但显示树没有对应 TextureRect。代码跳过贴图后还落入空角色的 `visuals` 访问错误。证据：before.json、before.log、before_*.png、reproduction_probe.gd。

所以该缺陷不是此次 docs/qa 或 research 排除导致正式素材丢失，也不是压缩损坏。正式图片已按 Godot 导入格式在 PCK 内存在；错误地以原PNG文件存在性判断可加载性，使本地原文件存在时正常，导出后失效。

## 修复

`godot/ui/app.gd` 九处媒体判断改用 `ResourceLoader.exists()`：事件音效、事件CG、独立立绘、人物事件完成奖励可用性、岗位CG奖励、显式次要立绘、次要角色立绘、岗位画廊CG及人物画廊CG。

JSON及存档的 FileAccess 判断保留。没有把原PNG重新塞入包、取消已授权排除规则、改图或改剧情。

## 新增防回归

- `tools/export_event_resource_test.gd`：同一脚本用于工程与实际PCK；所有载入的正式内容媒体引用检查；全部显式事件媒体配置去重后四种语言／模式运行；人物奖励和岗位奖励／画廊检查；千束10种不同贴图在中英正文／回想中的真实页面与输入检查。
- `tools/export_release_checked.py`：本地原生测试 → 导出到临时目录 → 从实际ZIP提取PCK → 独立目录原生重测 → 精确比较资源、媒体控件及当前／下一页观测 → 确认生产源码未改变 → 才复制交付包。任一断言失败、SCRIPT ERROR、ERROR或两端差异均阻断交付；不覆盖已有输出。
- 静态门禁阻止 UI 再使用 FileAccess 原文件存在性检查；发布工作流说明见 `docs/export_validation.md`。

样本覆盖1,178个带显式媒体配置的节点，去重为280种显示配置；四种模式共1,120组显示观测。该数量不是全部事件数量，也不表示所有剧情分支重新完整验收。

## 运行与范围

本地：1,921项媒体引用、5,541检查、0失败；千束40组原生场景、鼠标／空格／回车／自动播放，记录前后页面的正文、姓名标签、资源路径、控件位置与尺寸。隔离内存设置节点仅是内容显示测试起点，不代表正式剧情入口自然养成通过。测试不读写玩家槽位，也不持久化会话快照。

初轮测试夹具修正：独立音效配置复用同一探针节点ID，触发游戏正常的去重；修正为逐场景清空临时音效键。初轮以120帧等待CG，未达到原稿2秒演出时间；改为按真实控件可用性等待并设10秒上限，不缩短游戏演出延时。初轮失败记录不当作游戏新缺陷。

两项本地化：叙事29,665检查0失败；UI英文754/754，审计无硬编码中文候选。没有更改翻译。

最终发行包对照结果由 `checked_release/summary.json` 和两侧 `results.json` 提供。原生PCK检查使用macOS引擎载入Windows包；尚未在Windows执行EXE，不宣称跨系统字体、驱动和全部剧情流程已经验收。

## 最终复验结果

实际发行PCK：5,542检查0失败（比本地多一项禁止松散PNG回退断言）。两端1,921项资源类型／尺寸、1,120组媒体显示观测、40组中英文正文／回想GUI记录完全一致；40对PNG的SHA-256逐张一致，见checked_release/screenshot_parity.json。抽查原生截图已确认千束立绘、CG、实际姓名和对白可见；对白覆盖CG为正常表现。

交付：`v0.2_20261031/HoshimiHospital.zip`，1,494,866,506字节，内部仍是HoshimiHospital.exe和HoshimiHospital.pck。原10月30日包未覆盖。summary.json记录本轮生产源码指纹。

发布脚本已进一步加入截图哈希一致门禁及QA目录.gdignore，防止新截图再进入Godot导入；本轮40对截图也已独立执行同样哈希核验。Windows EXE自身的运行仍待目标系统验证。本轮没有发现遗留的同类资源门槛错误，不等于所有剧情和全部平台全面验收通过。
