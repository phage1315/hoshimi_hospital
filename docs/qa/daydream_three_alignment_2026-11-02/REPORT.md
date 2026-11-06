# 三篇办公室白日梦：立绘与对白对应实机验收

日期：2026-11-02。main，HEAD 4bb15479；保留既有工作区改动。关键文件哈希见version.json。使用hoshimi-native-playtest技能；没有修改剧情、生产映射、角色图或玩家存档，没有重新运行导入器。

## 结论

**本轮验收不通过。** 三篇能从办公室按钮进入并完整播放，但弘子／瑞穗篇存在错人和角色立绘缺失；英文正文未翻译。中文与英文UI模式均实际运行，不能把后者称为英文剧情完成。

| 事件 | 原稿节点 | 事件流／输入 | 显示及人物对应 |
|---|---:|---|---|
| FANTASY_HIROKO_EMIKO_OR_01 | 50 | 本轮完整播放、退出返回通过 | 5个节点显示千早；22个角色发言节点无立绘，不通过 |
| FANTASY_CHIHAYA_PREOP_OR_01 | 46 | 本轮完整播放、退出返回通过 | 未发现错人、缺图或姓名错配；特殊情绪采用现有差分近似，英文未完成 |
| FANTASY_MIZUHO_OR_SOLO_01 | 42 | 本轮完整播放、退出返回通过 | 8个节点显示千早；6个角色发言节点无立绘；CG未接入，不通过 |

## 方法和范围

真实Godot4.5.1可见原生窗口、合成Viewport GUI输入，不是headless显示验收，不声称人工或OS级键鼠操作。隔离内存按实际gate准备Lv4和必要相识／返院完成事实；未读取玩家存档。真实办公室按钮→目录→等级确认→篇章确认→正文，不使用测试中心绕过gate，也不是从新游戏自然达到Lv4。

每篇两种locale，各自完整顺序播放并逐页检查实际姓名Label、正文RichTextLabel、纹理路径和位置，截图全部对白页；鼠标、空格、回车轮换，每篇每语言测试一次自动播放开关。结束返回办公室，重复进入后中途退出。断言不消费时间、不改变关系，已阅仅记录事件ID。未逐项比较所有XP／正史flag；未运行周日办公室、取消确认或磁盘保存恢复专项。本事件无额外剧情选项分支。

原稿依据为Downloads中的三个source_file，见source_audit.json的绝对路径及SHA256：HOSHIMI_FANTASY_01_HIROKO_EMIKO_OR_V1.md、HOSHIMI_FANTASY_02_CHIHAYA_PREOP_OR_V1_2.md、HOSHIMI_FANTASY_03_MIZUHO_OR_SOLO_V1.md。独立文本审计138节点，中文正文、标点、归属及顺序0差异。后续千早图像／位置调整按当前已指定映射检查，不重导旧稿覆盖。

## P1-01：弘子／瑞穗对白显示千早

**预期：** 当前说话角色与原稿相符的本人资源；没有对应表情时明确登记缺口，不借用另一角色图片。

**实际：** 姓名标签分别为杉村弘子／瑞穗，CharacterEventPortrait实际加载patient_chihaya_second_surgery_v1下的千早病房／术中图。不是标签错字或上一句残留，而是当前节点明确指定错路径。

- 弘子：F01_012、F01_014、F01_021、F01_024、F01_030。
- 瑞穗：F03_010、F03_018、F03_021、F03_023、F03_025、F03_027、F03_032、F03_035。
- 例：F01_012与F03_010均加载assets/characters/patient_chihaya_second_surgery_v1/intraoperative/surprised.png；F01_014与F03_018加载千早ward/afraid.png。
- 复现：达到对应真实关系门槛后在办公室打开白日梦、选择对应篇章并推进到上述节点。两种locale均复现。
- 截图：zh_CN_FANTASY_HIROKO_EMIKO_OR_01_F01_012_0.png、zh_CN_FANTASY_MIZUHO_OR_SOLO_01_F03_010_0.png及相应英文UI截图。

**根因：** tools/import_daydream_scripts.py的EXPRESSION_PATHS是千早专用映射，却在parse中只按表情键匹配，不检查speaker／event。多个剧本使用同名表情键，导致生成的index.json直接串人。

**最小修复建议（未实施）：** 映射按actor_id与expression联合限定；局部修正13个错误节点并保留其他已确认调整。具体本人差分须依据已有授权映射或补充确认，不凭键名猜图、不重新全量导入覆盖。新增source_audit及实际画面结果审计已能报出此错。

## P1-02：28个角色发言节点完全无立绘

**实际：** 非旁白、非主角发言，画面只有背景与对白框；原稿有角色出镜／表情指令，运行纹理树没有角色图。

- 弘子篇22处：F01_005、007、009、010、015、016、017、018、020、026、027、028、031、034、035、036、038、040、043、046、047、050。
- 瑞穗篇6处：F03_007、013、015、030、039、042。
- 涉及江美子、弘子、真奈美、美佳、瑞穗、小夜香，不能只补主角一人。
- 示例截图：zh_CN_FANTASY_HIROKO_EMIKO_OR_01_F01_010_0.png（弘子）、zh_CN_FANTASY_MIZUHO_OR_SOLO_01_F03_039_0.png（小夜香）。

**根因：** daydream_view.gd给未填写outfit的节点传入normal；这些角色Profile没有normal/*映射。add_portrait严格查该服装／表情，找不到就返回。SPRITE和多数EXPR仅保留键，尚无实际资源绑定。

**最小修复建议（未实施）：** 优先明确各场景的角色、服装、表情映射；通用默认服装应取角色真实default_outfit，而不是不存在的normal。仅修默认值能恢复部分普通出场，但不能据此把手术场景的普通制服称为符合原稿；缺失差分须另列。

旁白／主角节点按当前白日梦实现清空普通立绘，本轮不将此机制本身报为错人，也不机械要求所有发言者都有立绘。

## 其它未完成与验收限制

- **P2／素材与接入缺口：** F03_006声明cg_key=mizuho_or_laparotomy_open，但无cg_path、无实际CG纹理。当前show_scene只在非旁白／非主角分支调用角色视觉，单纯补路径也需检查旁白节点的CG显示链。没有授权映射时不借用别的图。本轮不宣称CG切入／恢复通过。
- **P2／英文未完成：** 三篇138个节点的英文正文及姓名仍为中文；标题也是中文。实际英文界面仅通用按钮等翻译。标准narrative_localization_test仍显示通过，因为白日梦独立目录没有进入其现有叙事集合扫描；本轮专用检查已明确失败，不能引用通用审计结果掩盖缺译。
- BGM／SFX／TRANSITION在数据里保留键，但本轮未验证音频播放；不能视为对应演出已接通。
- 千早篇16处显式立绘请求均加载预期本人／千鹤资源；原稿多个特殊情绪共用现有crying／surprised等差分。资源对应通过不代表这些键各有独立精确表情。千鹤按现有指定复用普通制服图，没有文件夹专用图。本轮不新增、修改或评价图片。

## 测试与证据

本地native.json：2431项运行检查0失败，282页（每语言弘子52页／千早46页／瑞穗43页）；输入mouse92、space92、enter92、auto6。它只表示原稿当前数据按序渲染和输入正常，**不是立绘语义验收通过**。

实际纹理对应审计alignment_findings.json：FAIL，26个错人页面观察、58个缺图页面观察（包含两语言及分页），对应13个错人节点、28个缺图节点；141个英文模式页面回退中文。

本地保存282张正文页面截图、2张最终返回截图；每篇返回均做断言，但返回截图同locale文件名覆盖，只保留每语言最后一篇返回。日志无引擎ERROR／SCRIPT ERROR，问题是内容映射而非崩溃。

标准静态审计本轮重跑：narrative_localization_test.py 30631项0失败；localization_audit.py 792/792英文UI键、硬编码中文候选0、47311翻译。其范围不等于白日梦英文完整。

复用并扩展tools/chihaya_daydream_native_test.gd新增tools/daydream_three_alignment_native_test.gd；原有测试未覆盖。新增tools/daydream_three_source_audit.py和tools/daydream_alignment_result_audit.py，分别从原稿及实际画面资源检测错误，当前预期退出1，不放宽断言让问题变绿。

运行入口：Godot --path <项目> --script tools/daydream_three_alignment_native_test.gd --log-file <独立日志> -- --out=<绝对QA目录>；随后python3 tools/daydream_alignment_result_audit.py <QA目录>/native.json。

包内结果见parity.json及packed/；使用当前Windows Desktop预设实际export-pack产生独立临时PCK，再由macOS原生Godot加载同一外部驱动。此为包内资源／逻辑测试，不是Windows EXE、Windows字体与驱动验收，不生成或发布正式发行ZIP。

### 包内最终结果

实际PCK原生复测同为2431项流程检查0失败，282条逐页观察与本地完全一致，284对PNG的SHA256全部相同。画面语义审计在两边均FAIL，错人／缺图清单一致；关键生产文件在记录版本至复测完成期间无变化。问题不是导出遗漏，而是当前数据和演出配置在两种运行方式中一致地出错。
