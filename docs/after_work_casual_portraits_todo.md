# 同行回家：医护常服立绘 TODO

记录日期：2026-10-11

状态：待制作与接入。本次仅记录 TODO，不生成图片、不修改游戏逻辑；保留 `docs/bug_backlog.md` 的未决问题及修复历史。

## 目标与当前实现

院外同行使用符合角色身份的常服立绘，避免在街景里继续穿护士服、白大褂或刷手服。

- `godot/ui/app.gd` 的 `after_work_outfit()` 已按 `after_work/neutral` → `casual/neutral` → 默认工作服 → `uniform` 顺序选择服装。
- `show_after_work_walk()` 在邀请和结果阶段都使用上述选择器。已有常服者在医院邀请阶段就穿常服，接受同行后延续同套服装，无需新增换装对白。
- 只有 `phase=result` 且 `outcome=completed` 才显示院外街景；邀请、拒绝与跳过仍使用医院背景。补立绘不得改变这一条件。
- 当前已接入四季×昼夜共八张街景：春3–5月、夏6–8月、秋9–11月、冬12–2月，使用实际离院工作日/时段。服装目前尚无季节选择逻辑。

## 已接入常服的角色

根据 `data/staff/index.json` 与各角色 `profile.json` 核对：21名注册医护/访客中，6名具有可用常服映射，文件均存在。下表统计独立文件，不将多个表情键共用一张图算作不同差分；未逐张进行视觉验收。

| 角色 | 技术 ID | 独立常服图片数 | 备注 |
| --- | --- | ---: | --- |
| 城宮明日香 | `doc_asuka` | 1 | neutral |
| 杉村弘子 | `nurse_hiroko` | 1 | neutral |
| 阿尔托莉雅·潘德拉贡 | `doc_artoria` | 1 | neutral与smile共用图片 |
| 藤崎詩織 | `doc_shiori` | 1 | neutral与smile共用图片 |
| 南条小夜香 | `doc_sayaka` | 3 | neutral、happy、shy；smile复用happy |
| 遥凑 | `doc_minato` | 4 | neutral、smile、amused、thoughtful |

## 待补常服基础图：15名

以下勾选表示基础图已完成制作、注册和运行时验收，不是仅在 `outfits` 中声明了 `casual`。先核查是否有未注册的可复用素材，再决定是否新制。

- [ ] 神宮寺成美 — `doc_aoi`
- [ ] 深山佳織 — `doc_rei`
- [ ] 御堂江美子 — `doc_emiko`
- [ ] 水城阿库娅 — `doc_aqua`
- [ ] 樱花 — `doc_sakura_anesthesiology`
- [ ] 七瀬恋 — `nurse_haru`
- [ ] 中井美佳 — `nurse_rin`
- [ ] 朝倉美幸 — `nurse_yui`
- [ ] 利根川安琪 — `nurse_ange`
- [ ] 本庄萌惠 — `nurse_moe`
- [ ] 石神千鹤 — `nurse_ishigami`
- [ ] 折川皐月 — `nurse_satsuki`
- [ ] 飯村真奈美 — `pharmacist_manami`
- [ ] 伊吹摩耶 — `visiting_maya`
- [ ] 佐仓双叶 — `visiting_futaba`

注意：`assets/events/character_events/rei/ayako/casual_*` 属于特定剧情素材目录，不能仅凭位于深山事件目录就当作深山本人的常服注册；需先核对人物身份和用途。

## 建议制作顺序

以下是制作建议，具体服装、参考图和批次开始前再由用户确认。

1. 优先七瀬恋、神宮寺成美、朝倉美幸等常用同行角色，每人先补1张 `casual/neutral`。
2. 补齐其余缺图角色，形成全员常服基础覆盖。
3. 再补微笑、疲惫等表情差分；当前普通同行固定请求 `neutral`，增加文件并不意味着自动使用新表情，届时须单独确定表情映射。
4. 再考虑冬季外套，之后按需要扩展季节服装；不要把八张背景机械扩成每人八套服装，也不要宣称现有常服已随季节切换。

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
