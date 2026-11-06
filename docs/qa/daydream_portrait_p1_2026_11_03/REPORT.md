# 三篇白日梦立绘 P1 修复与复验

日期：2026-11-03。保留工作区既有未提交改动；不修改原稿、对白、说话人、顺序、人物图片或玩家存档。

## A. 原稿、资源与双语审计

- 导入器把表情映射限定到角色；千早的差分只作用于千早，瑞穗的脚本键映射到其已有术中差分。弘子在手术室使用已登记的 `operating_patient/nervous`，其它角色按场景使用本人 Profile 中的制服、白大褂或无菌服。`hiroko_smile_clipboard`、`sayaka_smile_tease`、`sayaka_laugh` 使用已存在的本人近似立绘。
- 渲染器不再给缺少 `outfit` 的节点传入不存在的 `normal`，而取角色的 `visuals.default_outfit`。不变更普通角色事件的通用立绘逻辑。
- `python3 tools/daydream_three_source_audit.py --out docs/qa/daydream_portrait_p1_2026_11_03`：3 份原稿、138 节点；中文正文、说话人与顺序 0 差异；错人路径 0；角色立绘解析缺口 0。57 个角色发言节点均有现存文件。
- `python3 tools/narrative_localization_test.py`：30,756 项、0 失败；`python3 tools/localization_audit.py`：47,313 翻译项、UI 引用英文键 796/796。两项通用审计尚未覆盖白日梦独立目录的英文正文。

## B. Godot headless 回归

- Godot 4.5.1 `tools/daydream_mode_test.gd`：400 项、0 失败。
- `git diff --check` 对本轮脚本无空白错误。

## C. 可见窗口与实际 PCK

- 本地非 headless Godot：真实主场景、办公室按钮、目录、等级与篇章确认、三篇正文全程；中文及英文 UI 模式各一次。原生窗口合成 GUI 输入包含鼠标、空格、回车及自动播放。282 页，2,689 项检查、0 失败。完成后返回办公室，重复进入后中途退出；不消耗时间，不改变关系，事件仅记录已阅 ID。测试使用隔离内存前置，未写玩家存档。
- 每页断言显示的发言人与 TextureRect 路径属于当前角色。实际纹理审计：错人 0 页、缺图 0 页。检查了 `F01_012`、`F01_015`、`F01_038`、`F03_007`、`F03_010`、`F03_039`、千早 `F02_012` 等截图；布局无新遮挡。
- 首次沙箱内 `export-pack` 生成的包含损坏的 `project.binary`，不能算包内测试；失败日志保留在 `packed/engine.log`。在获准的本机环境重新导出独立 PCK 后，从无源码的隔离目录加载包内资源，原生窗口同样 2,689 项、0 失败。
- `parity.json`：本地与重新导出的 PCK 的 282 条逐页观察完全相同，284 对 PNG 文件名和 SHA256 全部相同。两次原生运行日志没有脚本错误或缺失资源。此项证明包内资源与逻辑一致，不代表 Windows EXE、字体或驱动已经验收。

## D. 仍未完成

- 三篇的英文标题、姓名及 138 个正文节点仍使用中文回退；因分页，实际英文 UI 模式有 141 页回退。`daydream_alignment_result_audit.py` 因此仍以退出码 1 报总体验收失败，即使立绘两项均为 0。不能标记英文剧情完成。
- 瑞穗 `F03_006` 的 `mizuho_or_laparotomy_open` 在本报告当日仍只有 CG 键。2026-11-04 用户已提供并指定图片，现已原样接入 `assets/events/daydream_v1/mizuho_or_laparotomy_open.png`；旁白节点 CG 渲染链及实际纹理路径已有专项回归。BGM/SFX/转场键尚未做播放专项验收。
- 弘子的手术室角色图目前复用一张 `operating_patient/nervous`；脚本中羞惧、哭泣、剧痛等表情没有逐键独立差分。瑞穗和千早的若干特殊表情也复用现有近似差分。资源可显示不等于表情素材已经精确齐全。
