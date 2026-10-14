# 同行回家：医护常服立绘 TODO

记录日期：2026-10-11

状态：21名角色两季常服已全部接入（2026-10-12），本轮常服补齐完成。2026-10-11 已完成七瀬恋制服修订及首张常服；保留 `docs/bug_backlog.md` 的未决问题及修复历史。

## 目标与当前实现

院外同行使用符合角色身份的常服立绘，避免在街景里继续穿护士服、白大褂或刷手服。

- `godot/ui/app.gd` 的 `after_work_outfit(actor, walk)` 按离院工作日选择：9–2月优先 `casual_winter/neutral`；无冬装或3–8月按 `after_work/neutral` → `casual/neutral` → 默认工作服 → `uniform` 回退。
- `show_after_work_walk()` 在邀请和结果阶段都使用上述选择器。已有常服者在医院邀请阶段就穿常服，接受同行后延续同套服装，无需新增换装对白。
- 只有 `phase=result` 且 `outcome=completed` 才显示院外街景；邀请、拒绝与跳过仍使用医院背景。补立绘不得改变这一条件。
- 当前已接入四季×昼夜共八张街景：春3–5月、夏6–8月、秋9–11月、冬12–2月，使用实际离院工作日/时段。七瀬恋、明日香、阿尔托莉雅、成美、弘子、詩織、小夜香、遥凑、佳織、江美子、阿库娅、樱花、美幸、美佳、安琪、萌惠、皐月、真奈美、千鹤、双叶、摩耶已接入9–2月冬装；其他角色无冬装映射时沿用原选择逻辑。

## 已接入常服的角色

### 已确认的触发规则与回归（2026-10-11）

- 用户明确要求：同行事件一触发就显示常服，不等接受邀请或进入院外街景才换装。
- 当前 `show_after_work_walk()` 已在所有阶段共用 `after_work_outfit()`，无须新增平行换装逻辑。本次补充代码约束注释及 `tools/after_work_outfit_test.gd` 固定此行为；不改原剧情、场景触发、奖励或角色素材映射。
- 全21名角色 × 中英文 × 普通/深夜 × 邀请/接受/拒绝/跳过的实际UI纹理与背景门槛验证：1,184项、0失败；当前7名使用常服，其余14名保留工作服回退。之后注册 `casual/neutral` 即可由同一选择器使用。
- 叙事本地化6,901项通过，本地化审计通过，diff空白检查通过。本次为无头运行时验证，不替代新素材的原生窗口视觉验收。

根据 `data/staff/index.json` 与各角色 `profile.json` 核对：21名注册医护/访客中，21名具有可用常服映射，文件均存在。下表统计独立文件，不将多个表情键共用一张图算作不同差分；原有6人未逐张进行视觉验收；本批七瀬恋已完成实际渲染验收。

| 角色 | 技术 ID | 独立常服图片数 | 备注 |
| --- | --- | ---: | --- |
| 伊吹摩耶 | `visiting_maya` | 2 | 两季neutral，运行时验收完成 |
| 佐仓双叶 | `visiting_futaba` | 2 | 成年版两季neutral，运行时验收完成 |
| 飯村真奈美 | `pharmacist_manami` | 2 | 春夏neutral＋秋冬neutral，运行时验收完成 |
| 石神千鹤 | `nurse_ishigami` | 2 | 原作参考两季neutral，运行时验收完成 |
| 折川皐月 | `nurse_satsuki` | 2 | 春夏neutral＋秋冬neutral，运行时验收完成 |
| 本庄萌惠 | `nurse_moe` | 2 | 春夏neutral＋秋冬neutral，运行时验收完成 |
| 利根川安琪 | `nurse_ange` | 2 | 原作常服高清重绘v2，两季neutral，运行时验收完成 |
| 中井美佳 | `nurse_rin` | 2 | 春夏neutral＋秋冬neutral，运行时验收完成 |
| 朝倉美幸 | `nurse_yui` | 2 | 春夏、秋冬均为颅顶修正版neutral，运行时验收完成 |
| 樱花 | `doc_sakura_anesthesiology` | 2 | 春夏领带版neutral＋秋冬neutral，已完成运行时验收 |
| 水城阿库娅 | `doc_aqua` | 2 | 春夏neutral＋秋冬neutral，已完成运行时验收 |
| 御堂江美子 | `doc_emiko` | 2 | 春夏neutral＋秋冬neutral，已完成运行时验收 |
| 深山佳織 | `doc_rei` | 2 | 春夏粉色套装neutral＋秋冬neutral，已完成运行时验收 |
| 神宮寺成美 | `doc_aoi` | 2 | 春夏neutral＋秋冬neutral，已完成运行时验收 |
| 城宮明日香 | `doc_asuka` | 2 | 春夏外出装neutral＋秋冬neutral；浴袍式旧文件保留 |
| 杉村弘子 | `nurse_hiroko` | 2 | 春夏neutral＋秋冬neutral |
| 阿尔托莉雅·潘德拉贡 | `doc_artoria` | 2 | 原casual的neutral与smile共用；新增秋冬neutral |
| 藤崎詩織 | `doc_shiori` | 2 | 春夏neutral与smile共用；秋冬neutral |
| 南条小夜香 | `doc_sayaka` | 4 | 春夏neutral、happy、shy；smile复用happy；秋冬neutral |
| 遥凑 | `doc_minato` | 5 | 春夏neutral、smile、amused、thoughtful；秋冬neutral |
| 七瀬恋 | `nurse_haru` | 2 | casual/neutral与casual_winter/neutral；9–2月风衣，3–8月原常服 |

## 常服基础图进度：原待补15名，现余0名

以下勾选表示基础图已完成制作、注册和运行时验收，不是仅在 `outfits` 中声明了 `casual`。先核查是否有未注册的可复用素材，再决定是否新制。

- [x] 神宮寺成美 — `doc_aoi`（2026-10-11，两季neutral）
- [x] 深山佳織 — `doc_rei`（2026-10-11，两季neutral）
- [x] 御堂江美子 — `doc_emiko`（2026-10-12，两季neutral）
- [x] 水城阿库娅 — `doc_aqua`（2026-10-12，两季neutral）
- [x] 樱花 — `doc_sakura_anesthesiology`（2026-10-12，两季neutral）
- [x] 七瀬恋 — `nurse_haru`（2026-10-11）
- [x] 中井美佳 — `nurse_rin`（2026-10-12，两季neutral）
- [x] 朝倉美幸 — `nurse_yui`（2026-10-12，两季颅顶修正版neutral）
- [x] 利根川安琪 — `nurse_ange`（2026-10-12，两季原作重绘v2 neutral）
- [x] 本庄萌惠 — `nurse_moe`（2026-10-12，两季neutral）
- [x] 石神千鹤 — `nurse_ishigami`（2026-10-12，两季neutral）
- [x] 折川皐月 — `nurse_satsuki`（2026-10-12，两季neutral）
- [x] 飯村真奈美 — `pharmacist_manami`（2026-10-12，两季neutral）
- [x] 伊吹摩耶 — `visiting_maya`（2026-10-12，两季neutral）
- [x] 佐仓双叶 — `visiting_futaba`（2026-10-12，成年版两季neutral）

注意：`assets/events/character_events/rei/ayako/casual_*` 属于特定剧情素材目录，不能仅凭位于深山事件目录就当作深山本人的常服注册；需先核对人物身份和用途。

## 建议制作顺序

以下是制作建议，具体服装、参考图和批次开始前再由用户确认。

1. 优先七瀬恋、神宮寺成美、朝倉美幸等常用同行角色，每人先补1张 `casual/neutral`。
2. 补齐其余缺图角色，形成全员常服基础覆盖。
3. 再补微笑、疲惫等表情差分；当前普通同行固定请求 `neutral`，增加文件并不意味着自动使用新表情，届时须单独确定表情映射。
4. 恋已完成秋冬外套；其余角色之后按需要扩展季节服装，不把八张背景机械扩成每人八套服装。

## 接入与验收清单

- [ ] 根据角色现有参考保持脸、发型、体型与画风一致；先确认服装设计，再批量制作。
- [ ] 使用透明背景立绘；沿用该角色现有画布、人物尺度和锚点，并核对同行界面的实际显示框，不另定一套不兼容尺寸。
- [ ] 注册到对应 `profile.json` 的 `visuals.portraits`，保证存在 `casual/neutral`；仅增加 `outfits` 声明不算接入完成。
- [ ] 保留原工作服与剧情专用素材，不改已有剧情正文、说话人、奖励或同行触发条件。
- [ ] 中英文邀请阶段均优先显示常服；接受同行进入街景后仍为同一角色、同一套衣服。
- [ ] 拒绝/跳过不进入街景；缺图角色保留安全回退，不能显示空白或串用他人素材。
- [ ] 检查四季昼夜背景下的人物缩放、边缘、脚部/下缘裁切及与按钮、对话框的遮挡关系。
- [ ] 运行并按需扩展 `tools/after_work_walk_test.gd`、`tools/after_work_seasons_test.gd`；运行 `python3 tools/validate_data.py`。
- [ ] 若改动玩家可见文本，同步检查英文并运行 `python3 tools/narrative_localization_test.py`、`python3 tools/localization_audit.py`。
- [ ] 记录实际完成角色、素材来源、测试结果与尚未完成的视觉验收，不把路径存在等同于画面合格。

## 后续另议：检查 CG 变化

- [ ] 普通检查增加多张变体、参考画风与防连续重复策略，另行确定批次和参考图。
- 普通检查的非全屏splash与至少0.5秒关闭保护已完成，见 `docs/examination_cg_pack_v1.md`；此项不重复开发。

## 2026-10-11 批次：七瀬恋

- 用户批准第二张正面粉色护士服样张，去围裙；常服依附件6的米白开衫、淡粉褶领内搭，明确批准深灰半裙。
- 内置 ImageGen 制作制服 `neutral/smile/serious/worried/surprised/tired` 六张及 `casual/neutral` 一张，均为1024×1536 RGBA，原始alpha保留。目录：`assets/characters/nurse_haru_refresh_v1/`。
- 仅替换本人的六个 `uniform` 映射并新增 `casual/neutral`；旧工作服文件保留，刷手服、无菌服、术中头像、岗位CG和剧情素材未改。剧情、奖励、触发条件、UI代码未改。
- 六张附件原件：`research/character_references/nurse_haru/refresh_2026-10-11/`。素材来源、哈希和原映射：`research/imports/nurse_haru_refresh_2026-10-11.json`；生成及修正提示词：相邻 `nurse_haru_refresh_prompts_2026-10-11.json`。
- 透明背景实测：预览中外围RGB光晕处alpha为0；按alpha合成后不显示。常服最终版恢复与制服一致的脸部位置。未采用位置漂移的中间版本。
- `nurse_haru_refresh_test.gd`：236项通过，覆盖中英文六种制服加载、常服优先选择、四季昼夜邀请/接受/拒绝/跳过的纹理及背景。Godot实际OpenGL渲染另行运行同一测试并通过，32张邀请/完成截图完成检查；八种街景无遮挡脸、手和按钮，裙子下部按既有布局位于对话框后，非完整全身展示。
- `after_work_walk_test.gd`：101项通过；`after_work_seasons_test.gd`：1900项通过；`validate_data.py`：635条记录通过。
- `narrative_localization_test.py`：6901项、0失败；`localization_audit.py` 正常结束，UI英文682/682，硬编码中文0；全局既有 authored coverage为13946/14019，本批未改玩家文本或英文表。
- 视觉证据：`docs/qa/nurse_haru_refresh_2026-10-11/`。本批完成仅适用于恋，其他14名仍待制作。

## 2026-10-11 追加批次：恋的秋冬风衣

- 用户选定B款，并指定9–2月穿冬装。B样图逐字节复制至 `assets/characters/nurse_haru_refresh_v1/casual_winter/neutral.png`，1024×1536 RGBA；A毛衣仅保留为未注册样图。
- 注册 `casual_winter` 服装及 `casual_winter/neutral`，选择器接收本次 `walk.workday`，避免模拟时间已推进到另一月份时选错。9、10、11、12、1、2月用风衣；3–8月用原常服。邀请及全部结果阶段一致；街景仍仅在接受完成后显示。
- 本次保留用户选定B原图，未重新生成；同画布与显示框，头部相对春夏常服约高20屏幕像素，未声称像素级锚点对齐。实际渲染无脸/手被按钮遮挡、无可见外围光晕；外套下摆按现有对话框布局遮挡。
- 验证：冬装专项16104项、恋专项236项、全员同行服装1184项、同行流程101项、四季1900项均0失败；数据验证635条通过；叙事本地化6901项通过；全局审计正常结束（既有source fallback覆盖差额仍保留）。
- Godot OpenGL中英文实际渲染通过，抽查9月邀请及12月夜间完成画面，证据位于 `docs/qa/nurse_haru_winter_2026-10-11/`。
- 素材来源/哈希见 `research/imports/nurse_haru_winter_2026-10-11.json`；本次未修改剧情、奖励、触发条件或其他角色服装数据。

## 2026-10-11 岗位CG追加批次

- [x] 明日香、阿尔托莉雅：助手医各1张。
- [x] 皐月：器械、巡回、病房各1张。
- 千鹤、樱花、摩耶、双叶按用户指定排除当前岗位CG补齐范围；常服待补清单不因此改变。
- 五张已生成、注册、中英文首次解锁/画廊/存档与实际渲染验收；详见两份岗位CG包文档及 `research/imports/staff_role_cgs_2026-10-11.json`。当前约定的五张缺口全部补齐。

## 秋冬常服样张：明日香、阿尔托莉雅（2026-10-11）

- 已按用户确认设计生成两张1024×1536 RGBA样图：明日香浅粉羊毛大衣＋米白高领＋深棕半裙；阿尔托莉雅海军蓝双排扣大衣＋米白高领，保留蓝发带。
- 存于 `research/character_references/winter_casual_samples_2026-10-11/`，含原图、合成预览、来源哈希和提示词。透明通道及合成预览已检查。
- 状态：用户已确认定稿；原样复制至 `assets/characters/winter_casual_v1/{doc_asuka,doc_artoria}/neutral.png` 并注册 `casual_winter/neutral`，9–2月自动使用。中英文运行时与实际渲染验收完成。
- 常服当前只需neutral：同行固定请求neutral，本批未添加表情差分。冬装专项扩展覆盖恋及本批两人：43928项零失败；全员同行服装1184项零失败；数据640条通过。图像未再生成或修改，画面中的手与下摆部分位于原有对话框之后，脸部无遮挡。
- 原有六人秋冬装现已全部补齐；明日香春夏外出装亦已完成，见下。

## 明日香春夏外出装样张（2026-10-11）

- 以已定稿秋冬立绘为参考，生成淡粉短袖圆领衬衫＋米白高腰半裙的neutral样张，保留长发、面部特征与双手置于身前的站姿。
- 样图、来源哈希与提示词：`research/character_references/doc_asuka/spring_summer_sample_2026-10-11/`。已检查1024×1536 RGBA及透明通道。
- 待用户确认后替换3–8月常服映射；当前尚未注册或进行游戏内验收，原春夏素材与秋冬映射保留。
- 用户指出首张头部偏大，已用内置ImageGen生成`neutral_v2.png`缩小头部比例的修正版，保留服装设计；1024×1536 RGBA透明通道已核对，来源与提示词存于同目录`manifest_v2.json`、`prompt_v2.txt`。两版均保留，修正版仍待确认，未接入游戏。

## 明日香春夏定稿接入（2026-10-11）

- 用户确认头身比修正版`neutral_v2.png`；逐字节复制至`assets/characters/spring_summer_casual_v1/doc_asuka/neutral.png`，替换本人`casual/neutral`映射。3–8月使用本图，9–2月继续使用现有秋冬装。原浴袍式素材文件保留，工作服未改。
- 定稿1024×1536 RGBA，透明通道有效；来源、哈希、原映射及验证记录见`research/imports/doc_asuka_spring_summer_2026-10-11.json`。上方“待确认”记录为本批历史状态，现已完成。
- 季节选择及中英文边界日期运行时43928项、全21人同行服装1184项均零失败；数据验证643条通过。Godot原生OpenGL渲染生成8张中英文普通/深夜邀请与完成截图，抽查中文邀请和英文深夜院外同行：透明边缘正常，脸部无遮挡，手及裙子下部按既有布局位于对话框后。截图保存于`docs/qa/doc_asuka_spring_summer_2026-10-11/`。
- 本次仅接入已批准图像与扩展截图入口，未改剧情、奖励、触发条件或玩家可见文本。

## 成美两季常服样张（2026-10-11）

- 已核对`doc_aoi`仅声明casual，无常服映射；未发现可直接复用的本人常服立绘。用户确认春夏米白短袖衬衫＋深灰蓝长裤、秋冬驼色风衣＋炭灰高领＋深色长裤设计。
- 内置ImageGen以现有`c1058-neutral-ai.png`为身份参考生成春夏neutral，再以春夏样图生成同姿势秋冬neutral；保留灰绿长卷发、绿眼、细框眼镜与绿珠项链。
- 两张均1024×1536 RGBA，透明通道已检查。样图、来源哈希和提示词保存于`research/character_references/doc_aoi/casual_samples_2026-10-11/`。
- 状态：等待用户确认样图，尚未注册，未进行游戏内验收；原工作服和数据保持不变。

## 成美两季常服定稿接入（2026-10-11）

- 用户批准两张样图原样接入：`assets/characters/spring_summer_casual_v1/doc_aoi/neutral.png`与`assets/characters/winter_casual_v1/doc_aoi/neutral.png`。新增casual/neutral、casual_winter/neutral映射及casual_winter服装声明。3–8月春夏装，9–2月秋冬装；邀请与全部结果阶段共用既有选择器。上方待确认条目为历史记录，现已完成。
- 来源、哈希、提示词和接入前visuals快照：`research/imports/doc_aoi_casual_2026-10-11.json`。样图逐字节复制，透明通道保留。
- 季节专项加入成美，55650项零失败；全21名中英文同行服装1184项零失败，当前8名常服、13名工作服回退；数据651条通过。
- 原生OpenGL运行生成16张中英文两季普通/深夜邀请和完成截图；抽查中文春夏邀请与英文秋冬夜间同行，身份、透明边缘和位置正常，脸与手无遮挡。下摆按既有布局位于对话框后。证据：`docs/qa/doc_aoi_casual_2026-10-11/`。
- 未改工作服、剧情、奖励、触发条件或玩家可见文本。

## 弘子、詩織秋冬样图（2026-10-11）

- 核对两人均有春夏casual/neutral，尚无casual_winter映射。本批以各自现有常服为身份、姿势与构图参考，使用内置ImageGen生成各一张neutral。
- 弘子：燕麦色厚针织＋灰粉围巾＋紫灰长裙，保留蓝色粗长辫与原站姿。詩織：米白短外套＋酒红高领针织＋深灰格裙及深色连裤袜，保留红长发、黄色发箍与抚发姿势。
- 两图1024×1536 RGBA，透明通道已检查。样图、来源哈希、提示词位于`research/character_references/hiroko_shiori_winter_samples_2026-10-11/`。
- 状态：样图待用户确认，尚未接入，尚未进行游戏内验收；原春夏图和工作服保持不变。

## 弘子、詩織秋冬定稿接入（2026-10-11）

- 用户批准两张样图，原样复制至`assets/characters/winter_casual_v1/{nurse_hiroko,doc_shiori}/neutral.png`并注册casual_winter/neutral及服装声明。9–2月使用冬装，3–8月保留原常服。上方待确认记录为历史状态，现已完成。
- 来源、哈希、提示词及验证记录：`research/imports/hiroko_shiori_winter_2026-10-11.json`。不修改原工作服、剧情、奖励或触发条件。
- 季节专项扩展至6名有冬装角色：74714项零失败；全员中英文同行服装1184项零失败；数据651条通过。
- Godot原生OpenGL生成16张中英文邀请及普通/深夜完成截图，抽查弘子中文邀请、詩織英文冬夜同行，透明边缘正常，脸部无遮挡；下摆与低位手按既有布局位于对话框后。证据：`docs/qa/hiroko_shiori_winter_2026-10-11/`。
- 当前8名已有常服，其中6名具备两季服装；小夜香、遥凑仍需冬装，另13名缺基础常服。

## 小夜香、遥凑秋冬样图（2026-10-11）

- 核对两人现有casual及表情映射，均尚无casual_winter。内置ImageGen以各自casual/neutral为身份、姿势和构图参考生成各一张冬装neutral。
- 小夜香：炭灰长外套＋黑色高领针织＋酒红半裙及深色连裤袜，保留红发、耳坠及交叠手臂姿势。遥凑：驼色宽松外套＋米白高领针织＋深色长裤，保留肩包、耳饰、项链及持包带姿势。
- 两图均1024×1536 RGBA，透明通道已核对。样图、来源哈希及提示词位于`research/character_references/sayaka_minato_winter_samples_2026-10-11/`。
- 状态：待用户确认样图，尚未注册或进行游戏内验收；已有常服差分、工作服和角色数据未改。

## 小夜香、遥凑秋冬定稿接入（2026-10-11）

- 用户批准两张样图原样接入`assets/characters/winter_casual_v1/{doc_sayaka,doc_minato}/neutral.png`，新增casual_winter/neutral及服装声明；9–2月冬装，3–8月原常服。已有春夏表情差分、工作服和剧情素材均保留。上方样图待确认记录为历史状态，现已完成。
- 来源、哈希、提示词、原春夏路径与验证记录见`research/imports/sayaka_minato_winter_2026-10-11.json`。
- 季节专项扩展至8名有冬装角色：87938项零失败；全员中英文同行服装1184项零失败；数据651条通过。
- 原生OpenGL生成16张中英文普通/深夜邀请及完成截图；抽查小夜香中文邀请和遥凑英文冬夜同行，透明边缘及人物显示正常、脸部无遮挡，下摆及低位手按原布局位于对话框后。证据：`docs/qa/sayaka_minato_winter_2026-10-11/`。
- 未改剧情、奖励、触发条件或玩家可见文本。当前8名已有常服者均具备两季服装，另13名仍待补基础常服。

## 深山佳織两季常服样图（2026-10-11）

- 用户批准春夏参考原作粉色套装重新绘制、秋冬深海军蓝长外套＋浅灰高领＋炭灰半裙和深色厚袜的设计。原作图仅作参考，未直接注册使用。
- 以`model_identity_master_purple.png`为身份基准，`official_v2_pink_suit.png`为服装参考，v20白大褂neutral为站姿参考；内置ImageGen生成春夏neutral，再以其生成同姿势秋冬neutral。保留紫色高马尾、红细发带、酒红眼和克制微笑。
- 两张均1024×1536 RGBA，透明通道已核对。样图、来源哈希、参考对应关系和提示词位于`research/character_references/doc_rei/casual_samples_2026-10-11/`。
- 状态：样图待用户确认，未注册、未进行游戏内验收。工作服、剧情及角色数据未改。

## 深山佳織两季定稿接入（2026-10-11）

- 用户批准两张新绘样图原样接入`assets/characters/spring_summer_casual_v1/doc_rei/neutral.png`与`assets/characters/winter_casual_v1/doc_rei/neutral.png`。注册casual/neutral、casual_winter/neutral及casual_winter声明；3–8月春夏粉色套装，9–2月秋冬深蓝外套。上方样图待确认记录为历史状态，现已完成。
- 原作粉色套装仅用作参考，没有直接注册；原工作服、剧情、奖励、触发条件和玩家可见文本未改。素材来源、哈希、提示词和接入前visuals见`research/imports/doc_rei_casual_2026-10-11.json`。
- 季节专项覆盖9名两季角色，92360项零失败；全21人中英文同行服装1184项零失败，当前9人常服、12人工作服回退；数据651条通过。
- Godot原生OpenGL生成16张中英文两季普通/深夜邀请及完成截图；抽查中文春夏邀请和英文秋冬夜间同行，透明边缘、身份及位置正常，脸部无遮挡，下摆按既有布局位于对话框后。截图：`docs/qa/doc_rei_casual_2026-10-11/`。
- 当前9名已具备两季常服，另12名仍待补基础常服。

## 御堂江美子两季常服样图（2026-10-12）

- 核对尚无casual映射；用户批准春夏酒红短袖缎面衬衫＋黑色高腰直筒半裙、秋冬黑色收腰长大衣＋酒红高领针织＋炭灰长裤的设计。
- 内置ImageGen以v14白大褂neutral为身份、姿势及构图参考生成春夏neutral，再以春夏样图生成秋冬neutral。保留银紫长卷发、遮眼刘海、成熟脸型、金项链和交叠手臂姿势。
- 两图1024×1536 RGBA，透明通道已检查；样图、来源哈希与提示词位于`research/character_references/doc_emiko/casual_samples_2026-10-12/`。
- 状态：待用户确认样图，尚未注册或进行游戏内验收；现有工作服和角色数据未改。

## 御堂江美子两季定稿接入（2026-10-12）

- 用户批准两套原样接入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/doc_emiko/neutral.png`；注册casual及casual_winter两套neutral。3–8月春夏、9–2月秋冬。上方待确认状态为历史记录，现已完成。
- 来源、哈希、提示词与接入前visuals：`research/imports/doc_emiko_casual_2026-10-12.json`。原工作服、剧情、奖励、触发条件及玩家可见文本未改。
- 季节专项95322项、全员同行服装1184项均零失败；数据654条通过。当前10人两季常服，11人仍回退工作服。
- 原生OpenGL生成16张中英文两季普通/深夜邀请及完成截图；抽查中文春夏邀请与英文冬夜同行，透明边缘正常、脸部无遮挡，下摆按既有对话框布局遮挡。证据：`docs/qa/doc_emiko_casual_2026-10-12/`。

## 阿库娅常服设计提案（待确认）

- 核对无常服映射，以v18白大褂neutral和`research/character_references/doc_aqua/01_character_reference.png`为身份参考。保留浅蓝长发、环形高马尾、蓝金发饰与蓝眼睛。
- 春夏建议：米白短袖上衣＋湖蓝高腰A字半裙，领口小薄荷绿蝴蝶结呼应原配色。秋冬建议：奶白短款连帽呢外套＋浅蓝高领针织＋深海军蓝半裙及深色厚袜，小薄荷绿围巾。
- 待用户确认后制作各一张neutral；目前未生成、未接入。

## 阿库娅两季制作与接入（2026-10-12）

- 用户明确批准设计并要求生成后直接接入。内置ImageGen以v18白大褂neutral为身份与姿势参考生成春夏，再以春夏图生成同姿势秋冬；保留浅蓝长发、环形高马尾、蓝金发饰、蓝眼睛和抚发姿势。
- 春夏米白短袖上衣、薄荷绿蝴蝶结及蓝色A字裙；秋冬奶白连帽短呢外套、浅蓝高领、薄荷绿围巾、深蓝裙与深色厚袜。均1024×1536 RGBA，透明通道已检查，原样复制至`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/doc_aqua/neutral.png`。
- 注册casual/neutral及casual_winter/neutral和两套服装声明；3–8月春夏、9–2月秋冬，沿用既有选择器。上方待确认提案为历史记录，现已完成。来源、哈希、提示词及接入前visuals见`research/imports/doc_aqua_casual_2026-10-12.json`。
- 季节专项96824项、全员同行服装1184项均零失败；数据654条通过。原生OpenGL生成16张中英文两季普通/深夜邀请及完成截图，抽查中文春夏邀请和英文冬夜同行：透明边缘正常、脸部无遮挡，低位手和裙摆按原对话框布局遮挡。证据：`docs/qa/doc_aqua_casual_2026-10-12/`。
- 原工作服、剧情、奖励、触发条件及玩家可见文本未改。当前11名已具备两季常服，另10名待补。

## 樱花两季常服样图（2026-10-12）

- 用户指定中性、典雅、冷淡风格并同意绘制提案。春夏冷灰短袖立领暗门襟衬衫＋墨蓝直筒长裤、细黑皮带及银色腕表；秋冬炭灰直肩长大衣＋浅灰高领＋黑色长裤、深靛蓝窄围巾。
- 内置ImageGen以v23白大褂neutral_v1为身份及姿势参考生成春夏，再以春夏图生成秋冬；保留深靛长发、酒红眼、冷静表情和双臂交叠姿势。
- 两张1024×1536 RGBA，透明通道已核对；样图、来源哈希及提示词位于`research/character_references/doc_sakura_anesthesiology/casual_samples_2026-10-12/`。
- 状态：待用户确认样图，未注册或进行游戏内验收；原工作服及数据未改。
- 春夏追加领带修正版：用户提出增加领带或领结，选择试绘深靛蓝细领带＋小尖领。内置ImageGen生成`spring_summer_tie_v2.png`，1024×1536 RGBA透明通道已核对；源图、哈希及提示词保存为同目录`manifest_tie_v2.json`、`prompt_tie_v2.txt`。保留无领带版，修正版待确认，尚未接入。

## 樱花两季定稿接入（2026-10-12）

- 用户确认春夏领带修正版和秋冬装导入。原样复制至`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/doc_sakura_anesthesiology/neutral.png`；注册casual/neutral、casual_winter/neutral及两套服装声明。3–8月小尖领配深靛蓝领带，9–2月炭灰大衣配围巾。无领带样图保留作历史参考。
- 来源、哈希、参考图清单与接入前visuals：`research/imports/doc_sakura_casual_2026-10-12.json`。上方待确认记录为历史状态，现已完成。
- 季节专项96866项、全员同行服装1184项均零失败；数据654条通过。Godot原生OpenGL生成16张中英文两季普通/深夜邀请和完成截图，抽查中文春夏邀请、英文冬夜同行：透明边缘正常，脸与双手无遮挡，裤腿和外套下摆按原对话框布局遮挡。证据：`docs/qa/doc_sakura_casual_2026-10-12/`。
- 未改工作服、剧情、奖励、触发条件或岗位资格。当前12人已具备两季常服，另9人待补。

## 朝倉美幸两季常服样图（2026-10-12）

- 用户授权设计与绘制一同完成后征求意见。核对仅声明casual，无常服映射。以v2制服neutral为身份参考，内置ImageGen生成春夏，再以其生成同姿势秋冬neutral。
- 春夏：鼠尾草绿短袖针织＋米白A字半裙、细棕腰带；秋冬：浅驼短呢外套＋奶油色高领＋深橄榄半裙、深棕厚袜。保留金棕及肩发、棕眼、成熟脸型与手轻靠下颌姿势，去掉护士帽及工作附件。
- 两图1024×1536 RGBA，透明通道已核对；样图、来源哈希和提示词位于`research/character_references/nurse_yui/casual_samples_2026-10-12/`。
- 状态：待用户确认，尚未注册或进行游戏内验收；工作服及角色数据未改。
- 用户指出摘帽后颅顶过扁，已用内置ImageGen重新塑造圆润颅顶及发根蓬度，生成`spring_summer_crown_v2.png`和`autumn_winter_crown_v2.png`。均1024×1536 RGBA，透明通道已核对；旧版保留。来源及提示词见同目录`manifest_crown_v2.json`与`prompts_crown_v2.json`。修正版待确认，未接入；生成中人物纵向位置有变化，实装前需核对两季锚点及实际显示，未声称像素级对齐。

## 朝倉美幸两季修正版接入（2026-10-12）

- 用户批准颅顶修正版导入。原样复制`spring_summer_crown_v2.png`、`autumn_winter_crown_v2.png`至`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/nurse_yui/neutral.png`，注册casual/neutral及casual_winter/neutral，追加casual_winter声明。3–8月春夏、9–2月秋冬。旧样图保留，上方待确认记录现已完成。
- 来源、哈希、提示词及接入前visuals见`research/imports/nurse_yui_casual_2026-10-12.json`。原工作服、剧情、奖励、触发条件和玩家文本未改。
- 季节专项95448项、全员同行服装1184项均零失败，数据661条通过。专项数量因新增冬装者减少无冬装回退遍历而变化。
- 原生OpenGL生成16张中英文两季普通/深夜邀请与完成截图；抽查中文春夏邀请、英文冬夜同行，透明边缘正常、脸部无遮挡。保留用户认可的原图，1152×720截图中冬装颅顶比春夏约高9屏幕像素，并非像素级锚点重合；未因此重新生成或改动定稿。裙摆及部分低位手按原对话框布局遮挡。证据：`docs/qa/nurse_yui_casual_2026-10-12/`。
- 当前13人已具备两季常服，另8人待补。

## 中井美佳两季常服样图（2026-10-12）

- 用户指定低调成熟女性风格并批准绘制。春夏米灰短袖垂感衬衫＋烟蓝直筒半裙、细深棕腰带；秋冬灰褐中长羊毛外套＋燕麦高领＋深咖长裤。
- 内置ImageGen以v2制服neutral为身份参考，去护士帽和文件夹，补自然圆润颅顶，保留深棕长辫、蓝灰眼睛及克制微笑；双手交握于身前。先生成春夏，再以其生成同姿势秋冬neutral。
- 两图1024×1536 RGBA，透明通道已核对。样图、来源哈希和提示词位于`research/character_references/nurse_rin/casual_samples_2026-10-12/`。
- 状态：待用户确认，尚未注册或进行游戏内验收；原工作服及角色数据未改。

## 中井美佳两季定稿接入（2026-10-12）

- 用户批准两套样图原样导入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/nurse_rin/neutral.png`，注册casual/neutral及casual_winter/neutral，追加casual_winter声明。3–8月春夏装，9–2月秋冬装，沿用既有同行选择器；上方待确认记录现已完成。
- 来源、SHA-256、提示词及接入前visuals见`research/imports/nurse_rin_casual_2026-10-12.json`。原工作服、剧情、奖励、触发条件和玩家文本未改。
- 季节专项92570项、全员同行服装1184项均零失败，数据661条通过。专项数量因新增冬装者减少无冬装回退遍历而变化。
- 原生OpenGL生成16张中英文两季普通/深夜邀请与完成截图；抽查中文春夏邀请、英文冬夜同行，透明边缘正常、脸及交握双手可见，两季头部位置一致，下装按原对话框布局遮挡。证据：`docs/qa/nurse_rin_casual_2026-10-12/`。
- 当前14人已具备两季常服，另7人待补：安琪、萌惠、千鹤、皐月、真奈美、摩耶、双叶。

## 利根川安琪两季常服样图（2026-10-12）

- 用户授权直接设计并绘制两季样图。核对仅声明casual，无常服映射，未发现可直接复用的常服素材。以v11制服neutral为身份参考、美佳春夏为画风和画布尺度参考；保留安琪金色长发、绿眼睛及自信神态，去帽后补自然圆润颅顶。
- 春夏墨绿短袖针织＋米白高腰直筒裤、细棕腰带及银色腕表；秋冬深海军蓝短呢外套＋奶油色高领＋炭灰长裤、酒红围巾。正面为主，一手扶腰，另一手自然垂下。
- 内置ImageGen先生成春夏，再以其生成同姿势秋冬。两图1024×1536 RGBA，透明通道已检查；样图、来源SHA-256及提示词：`research/character_references/nurse_ange/casual_samples_2026-10-12/`。
- 状态：待用户确认，未注册或进行游戏内验收。原工作服与角色数据未改；完成接入人数仍为14人。

## 安琪原作常服高清重绘（2026-10-12）

- 用户指定附件1为春夏、附件2为秋冬，替代上一轮原创设计。原设计保留为备选，未接入。
- 内置ImageGen按原作造型以星见高清画风重绘：春夏蓝白连衣裙、白领结、蓝白发带、浅灰蓝长袖套，并保留原图胸牌及文件夹；秋冬灰紫深色外套、黑色领边、黑手套和黑发带。保留金色高马尾及绿眼睛。
- 秋冬附件仅有上半身，下摆及深色裤装为依据上半身补绘；闭眼笑改为睁眼轻微微笑的neutral。两图1024×1536 RGBA，已检查透明通道；未进行游戏运行时验收。
- 附件原件、生成图、SHA-256与提示词归档：`research/character_references/nurse_ange/original_casual_redraw_2026-10-12/`。待用户确认，尚未注册，角色数据及原工作服未改。

- 原作版v2修订：按用户反馈移除春夏员工卡、挂绳、文件夹和钢笔，两季眼睛稍放大并向原作眼形靠拢，秋冬服装保留。修正版为同目录`spring_summer_v2.png`、`autumn_winter_v2.png`，1024×1536 RGBA透明通道已检查；来源与提示词见`manifest_v2.json`、`prompts_v2.json`。旧图保留，仍待确认接入。

## 安琪原作两季常服修正版接入（2026-10-12）

- 用户批准v2定稿导入：春夏去工作用品、两季眼睛修正版，原样复制至`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/nurse_ange/neutral.png`。注册casual/neutral及casual_winter/neutral，追加casual_winter声明。沿用3–8月春夏、9–2月秋冬选择逻辑。
- 来源、SHA-256、参考图归档、提示词与接入前visuals见`research/imports/nurse_ange_casual_2026-10-12.json`。上方待确认记录为历史状态，现已完成。旧样图及原工作服保留，剧情、奖励、触发条件与玩家文本未改。
- 季节专项88232项、全员同行1184项均零失败，数据661条通过。生成16张原生OpenGL中英文两季普通/深夜邀请及完成截图；抽查中文春夏邀请与英文冬夜同行，透明边缘正常、面部无遮挡、两季头部位置相近，下摆及春夏低位手按原对话框布局遮挡。证据：`docs/qa/nurse_ange_casual_2026-10-12/`。
- 当前15人具备两季常服，另6人待补：萌惠、千鹤、皐月、真奈美、摩耶、双叶。

## 本庄萌惠两季常服样图（2026-10-12）

- 用户授权直接设计并绘制两季样图。当前无casual映射；以v13制服neutral为身份参考、美佳春夏为高清画风及画布尺度参考，内置ImageGen先生成春夏，再以其生成同姿势秋冬。
- 保留绿色层次发型及尖翘发束、蓝眼睛和银色大眼镜，去护士帽与工作用品；温柔轻微微笑，一手轻靠胸前，另一手自然垂下。
- 春夏奶油白短袖圆领衬衫、浅杏针织马甲、雾蓝A字半裙及细棕腰带；秋冬浅驼牛角扣外套、米白毛衣、灰粉围巾、深棕半裙及厚袜。
- 两图1024×1536 RGBA，透明通道已检查；样图、来源SHA-256与提示词见`research/character_references/nurse_moe/casual_samples_2026-10-12/`。
- 状态：待用户确认，未注册或进行游戏内验收；原工作服与角色数据未改。已接入仍为15人。

## 本庄萌惠两季常服定稿接入（2026-10-12）

- 用户确认两套样图导入，原样复制至`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/nurse_moe/neutral.png`。注册casual/neutral和casual_winter/neutral及两套服装声明，沿用3–8月春夏、9–2月秋冬逻辑。
- 来源、SHA-256、提示词和接入前visuals见`research/imports/nurse_moe_casual_2026-10-12.json`。上方待确认状态现已完成；原工作服、剧情、奖励、触发条件与玩家文本未改。
- 季节专项82434项、全员同行1184项均零失败，数据661条通过。原生OpenGL生成16张中英文两季普通/深夜邀请及完成截图，抽查中文春夏邀请和英文冬夜同行：透明边缘正常、脸及眼镜无遮挡，两季头部位置一致，裙摆按既有对话框布局遮挡。截图：`docs/qa/nurse_moe_casual_2026-10-12/`。
- 当前16人具备两季常服，剩余5人：千鹤、皐月、真奈美、摩耶、双叶。

## 折川皐月两季常服样图（2026-10-12）

- 用户授权直接设计并绘制。当前无常服映射，以v24制服neutral为身份、姿势及画风参考，内置ImageGen先生成春夏，再以其生成秋冬。
- 保留深绿长直发、浅蓝灰眼和黑色矩形粗框眼镜、双手轻握站姿；去掉护士帽后补自然圆润颅顶，表情为温和neutral。
- 春夏淡紫灰短袖衬衫、小海军蓝领口系带、深海军蓝细褶半裙；秋冬浅灰长呢外套、灰紫高领针织、炭灰半裙和深色厚袜。
- 两图1024×1536 RGBA，透明通道已检查；样图、来源SHA-256及提示词见`research/character_references/nurse_satsuki/casual_samples_2026-10-12/`。
- 状态：待用户确认，未注册、未进行游戏内验收。原工作服及角色数据未改，已接入仍为16人。

## 折川皐月两季常服定稿接入（2026-10-12）

- 用户批准两套样图原样导入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/nurse_satsuki/neutral.png`，注册casual/neutral、casual_winter/neutral和对应服装声明。沿用3–8月春夏、9–2月秋冬选择逻辑。
- 来源、SHA-256、提示词和接入前visuals见`research/imports/nurse_satsuki_casual_2026-10-12.json`。上方待确认状态现已完成，原工作服、剧情、奖励、触发条件和岗位资格未改。
- 季节专项75176项、全员同行1184项均零失败，数据661条通过。原生OpenGL生成16张中英文两季普通/深夜邀请及完成截图；抽查中文春夏邀请、英文冬夜同行，透明边缘正常，脸及眼镜无遮挡，两季头部位置一致，低位手及裙摆按既有对话框布局遮挡。截图：`docs/qa/nurse_satsuki_casual_2026-10-12/`。
- 当前17人具备两季常服，剩余4人：千鹤、真奈美、摩耶、双叶。

## 飯村真奈美两季常服样图（2026-10-12）

- 用户指定成熟知性女性时尚风。核对仅声明casual、无常服映射，以v10药剂师neutral为身份及画风参考，内置ImageGen先生成春夏，再以其生成同姿势秋冬。
- 保留红色层次短发、绿眼与温和神态；去白大褂、胸牌、钢笔、文件夹，改为一手轻搭另一侧前臂的放松站姿。
- 春夏香槟色垂领短袖上衣、深青蓝高腰阔腿裤、细深棕腰带及小金耳饰和腕表；秋冬深咖长羊毛大衣、暖米色高领、炭黑长裤与细金项链。
- 两图1024×1536 RGBA，透明通道已检查；样图、来源SHA-256与提示词见`research/character_references/pharmacist_manami/casual_samples_2026-10-12/`。
- 状态：待用户确认，未注册、未进行游戏内验收。原工作服和角色数据未改，已接入仍为17人。

## 石神千鹤原作参考两季常服样图（2026-10-12）

- 用户提供原作常服肖像，授权据此补充。以附件为服装和银饰参考、v22制服neutral为星见高清画风及体型参考；内置ImageGen先生成春夏，再生成同姿势秋冬。
- 保留蓝黑长直发及跨脸长刘海、狭长紫眼、成熟神态、银色弯叶耳饰和镂空花形项链。春夏深紫黑立领中袖上衣、前襟小搭扣、炭黑直筒半裙；秋冬同色系长袖收腰呢外套、深紫针织内搭、半裙及深色厚袜。原附件未展示下装，下装与秋冬层次为延展设计。
- 两图1024×1536 RGBA，透明通道已检查；原附件、样图、SHA-256与提示词见`research/character_references/nurse_ishigami/casual_samples_2026-10-12/`。
- 状态：待用户确认，未注册或进行游戏内验收；原工作服、角色数据及岗位资格未改。真奈美两套样图仍待确认，已接入人数仍为17人。

## 真奈美、千鹤两季定稿接入（2026-10-12）

- 用户明确确认饭村真奈美和石神千鹤两人均导入。四张定稿原样复制至`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/{pharmacist_manami,nurse_ishigami}/neutral.png`，各注册casual/neutral、casual_winter/neutral及对应服装声明。沿用3–8月春夏、9–2月秋冬选择器。
- 来源、SHA-256、提示词与接入前visuals分别记录于`research/imports/pharmacist_manami_casual_2026-10-12.json`、`research/imports/nurse_ishigami_casual_2026-10-12.json`。上方待确认状态现已完成；原工作服、剧情、奖励、触发条件及岗位资格未改。
- 季节专项56280项、全员同行1184项均零失败，数据661条通过。原生OpenGL每人生成16张中英文两季普通/深夜邀请与完成截图，共32张；每人抽查中文春夏邀请与英文冬夜同行，透明边缘正常、脸部无遮挡，两季头部位置稳定，低位手及下摆按既有对话框布局遮挡。
- 截图分别位于`docs/qa/pharmacist_manami_casual_2026-10-12/`、`docs/qa/nurse_ishigami_casual_2026-10-12/`。当前19人具备两季常服，剩余摩耶、双叶2人。

## 成年双叶两季常服样图（2026-10-12）

- 用户要求体现25岁后医学专家身份，避免原作嘻哈少女服装，并批准绘制设计。项目年龄26岁；以v21成年白大褂neutral为身份及画风参考，内置ImageGen生成春夏，再生成同姿势秋冬。
- 保留橙色高马尾、齐刘海、灰眼和银色细框眼镜、成年脸型，放松站姿一手入袋，另一手自然垂下。去白大褂、胸牌、平板及工作附件。
- 春夏雾灰蓝敞穿衬衫、米白圆领内搭、炭灰直筒裤、深棕细腰带与简洁腕表；秋冬深橄榄绿长呢大衣、黑色高领、深灰直筒裤。画面裁至膝部，设计提案鞋款未绘入。
- 两图1024×1536 RGBA，透明通道已检查；样图、来源SHA-256和提示词见`research/character_references/visiting_futaba/casual_samples_2026-10-12/`。
- 状态：待用户确认，尚未注册或进行游戏内验收；原工作服、关系与角色数据未改，已接入仍为19人。

## 成年双叶两季常服定稿接入（2026-10-12）

- 用户批准两套定稿原样导入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/visiting_futaba/neutral.png`。注册casual/neutral、casual_winter/neutral及服装声明，沿用3–8月春夏、9–2月秋冬选择逻辑。
- 来源、SHA-256、提示词与接入前visuals见`research/imports/visiting_futaba_casual_2026-10-12.json`。上方待确认状态现已完成；工作服、剧情、奖励、触发条件、熟悉度及关系锁定未改。
- 季节专项44642项、全员同行1184项均零失败，数据661条通过。原生OpenGL生成16张中英文两季普通/深夜邀请及完成截图；抽查中文春夏邀请、英文冬夜同行，透明边缘正常、脸与眼镜无遮挡，两季头部位置稳定，低位手和下摆按原对话框布局遮挡。截图：`docs/qa/visiting_futaba_casual_2026-10-12/`。
- 当前20人已具备两季常服，仅剩摩耶待补。

## 摩耶两季常服样图（2026-10-12）

- 用户指定摩耶着装模仿憧憬的赤木律子，授权设计并绘制。以v20成年白大褂neutral为身份及画风参考，延续既有紫色立领与银色圆环元素；内置ImageGen先生成春夏，再生成同姿势秋冬。
- 保留棕色及肩层次发型、棕眼、银色细框眼镜、温和略拘谨神态，一手轻握另一侧手腕。去除白大褂、文件夹、钢笔及工作附件。
- 春夏蓝紫短袖立领拉链上衣、银色圆环拉链头、黑色直筒半裙、细腰带及银色腕表；秋冬炭灰修身长呢外套、深紫高领针织、黑色半裙与厚袜，小银色圆环吊坠呼应春夏设计。
- 两图1024×1536 RGBA，透明通道已检查；样图、SHA-256和提示词见`research/character_references/visiting_maya/casual_samples_2026-10-12/`。
- 状态：待用户确认，未注册或进行游戏内验收；原工作服及角色数据未改。已接入仍为20人，摩耶定稿接入后才算21人完成。

## 摩耶两季定稿接入及全员收尾（2026-10-12）

- 用户批准两套样图原样导入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/visiting_maya/neutral.png`，注册casual/neutral、casual_winter/neutral及服装声明，沿用3–8月春夏、9–2月秋冬选择器。
- 来源、SHA-256、提示词与接入前visuals见`research/imports/visiting_maya_casual_2026-10-12.json`。上方待确认状态现已完成；工作服、剧情、奖励、触发条件、熟悉度及关系锁定未改。
- 季节专项31544项、全员同行1184项均零失败；21名角色的casual/neutral和casual_winter/neutral映射及文件全部存在。中英文均21名常服、0名工作服回退。
- 原生OpenGL生成16张中英文两季普通/深夜邀请及完成截图；抽查中文春夏邀请与英文冬夜同行，透明边缘正常、脸和眼镜无遮挡，两季位置稳定，裙摆按既有对话框布局遮挡。证据：`docs/qa/visiting_maya_casual_2026-10-12/`。
- 本次全量`validate_data.py`未通过：患者`patient_yuko_asou`缺少术中立绘tense、pain、near_collapse、anesthetized四项。本次未修改该患者，问题独立于常服映射与运行时验收，保留当前工作区数据供对应工作处理，不宣称全量数据通过。
- 21名角色两季常服补齐与接入完成；全量患者数据问题另列如上，未扩展常服表情差分。
