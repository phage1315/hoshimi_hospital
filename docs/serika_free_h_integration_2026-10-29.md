# 御園芹香 Free H V1.1：内容与素材接入记录

## 当前状态

用户提供的 V1.1 ZIP、底图、九区热区、六种头像、二阶段及事后CG全部接入。注册状态已为 `ready`；Godot原生macOS窗口中英文完整Runner验收通过。正式预约仍须真实 `serika_lv4_stay` 完成事实、已有亲密资格和正常在场／日程条件，不绕过剧情前置。

原包三份文件逐字节归档在 `docs/source/serika_free_h_v1_1/`，包及图片 SHA256 见该目录 `import_manifest.json`。运行文件为 `data/staff/doc_serika/h_profile_v1_1.json`、`h_flow_v1_1.json`，均与源文件完全一致。Profile 的 schema 保持 1.3，Flow 的 patch 保持 1.3.4；人物稿件版本 V1.1 不替代接口版本。

## 接入内容

- 二阶段图片：`assets/h/doc_serika/scene_cg.png`；事后图片：`assets/h/doc_serika/aftercare_cg.png`。均为用户原始1584×1056 PNG，未裁切、重绘、压缩或修改内容，运行显示采用 contain。
- 专属住宅夜景从已生成的简朴住宅v2候选复制到 `assets/backgrounds/serika_home_v1/bedroom_night.png`，注册为 `serika_home_bedroom_night`，供本Profile使用。原Lv4事件正文、节点和资源映射未改。
- 共用适配器现在支持原小夜香1.3.2 Flow＋独立Finish sidecar，以及芹香原包1.3.4内嵌Finish配置。继续复用同一个Session，不复制另一套互动流程。
- 新角色使用自己提供的独立头像路径，不借用小夜香图集。小夜香保留原图集和裁切配置。
- 芹香唯一地点为 `home`，显示名为“芹香家”，固定邀请回应为“那今晚去我家吧。”；进入后从原稿四句中随机抽一句，本次会话内不重抽。固定地点跳过地点选择器。
- 已登记完成来源为特殊事件 `serika_lv4_stay`，沿用已有完成事实和 `unlock_intimacy_events`，不制造新的完成flag。正式内容状态已为ready，仅关系等级数字不能代替真实事件完成事实。
- 现行Lv4的固定547节点剧情不调用本Profile，正文和说话人无修改。重复互动不增加永久数值奖励，不增加可保存位置；不将会话快照、选择或演出进度写入存档。

## 原文和英文

原始Profile的70句对白和Flow文本未修改。英文保存在 `h_context_v1_1.json` 的现有上下文覆盖接口中。全部86条（Profile70、Flow11、现有全局Finish标签5）均有逐条中英审阅清单，另补芹香家地点名、预约回应和背景名的英文键。未制作新对白或追加场景内容。

`tools/serika_free_h_source_audit.py` 独立核对运行Profile/Flow与源包字节相等、译文数量／中文残留／审阅清单一致性、图片和源文件校验和。通用叙事审计不覆盖全部独立H Profile池，不能用通用审计替代该专属检查。

## 底图与头像更新（2026-10-29）

- 已原样导入 `assets/h/doc_serika/body_map.png`（1024×1536 RGBA）；显示框340×510，等比完整显示。
- `data/h/doc_serika/h_bodymap.json` 按此底图标定九区、十四个多边形，使用归一化坐标；双侧区域分别标定，重叠时沿用共用Session的精细区域优先规则。坐标经headless几何测试和原生窗口GUI输入及截图复核，状态为final。
- 已认可的 `portrait_neutral.png` 原样导入，1254×1254 RGBA透明背景。`portrait_flustered.png`、`portrait_pleased.png`、`portrait_delighted.png`、`portrait_peak.png` 已按用户文件原样导入（1280×1280）；`portrait_annoyed.png` 也已按用户文件原样补入（1280×1280）；六种头像完整。
- 首张annoyed生成未产生图片，用户随后决定自行提供全部五种差分，停止生成。没有更换构图或使用其他角色头像补位。
- 原图与导入文件字节和SHA256一致，记录见 `docs/source/serika_free_h_v1_1/bodymap_import_manifest.json`；可点击热区预览见 `docs/qa/serika_free_h/bodymap_preview.html`。
- Godot headless实际TextureRect及GUI点击回调测试104项、0失败，覆盖全部十四个多边形代表点、非交互背景、越界、纹理路径与实际显示尺寸；JSON Schema通过。原有400项内容/UI测试和220项源文/英文核对重跑通过。
- 原生macOS窗口已由测试脚本驱动真实UI回调跑通预约→入场→互动→结算→次日安全导览，并检查渲染截图；不是手工鼠标逐步游玩。当前为 `ready`。

## 本次验证

| 检查 | 结果 |
|---|---|
| 源包／英文／资产字节核对 | 220项、86条中英文本、0失败 |
| 芹香Godot headless内容与二阶段／事后UI | 400项、0失败；中英文×两种style，36组合反应、MAX一次、6句顺序／无放回抽样、手动结束／单次响应、两句事后、实际CG纹理路径和姓名牌 |
| 小夜香系统回归 | 61项、0失败 |
| 小夜香UI回归 | 54项、0失败 |
| 预约／离院／边界回归 | 108项、0失败；只使用独立临时测试文件，不写玩家槽位 |
| 通用叙事本地化 | 26,521项、0失败 |
| 通用本地化审计 | 通过；752/752 UI引用键完整，硬编码中文候选0 |

回归测试中修正两处既有陈旧夹具：模拟aftercare节点补必需的id；`_confirm_free_h_booking`调用补上现行selected_location参数。两处接口要求在本次改动前已存在；未放宽生产行为或存档边界。

日志见 `docs/qa/serika_free_h/`。后续已补齐annoyed并完成原生窗口自动驱动与截图复核，详见下方最终验收。Godot的系统证书读取及编辑器设置写入警告属于本地环境问题；三张新增图片的资源导入成功。

## flustered透明差分补入

用户指定采用附件2 `00027-1969242913-Picsart-BackgroundRemover.png`，原样导入为 `assets/h/doc_serika/portrait_flustered.png`（1280×1280 RGBA）。复用原Profile已有的flustered路径映射，不修改正文或交互规则。来源及校验和见 `docs/source/serika_free_h_v1_1/flustered_import_manifest.json`。annoyed、pleased、delighted、peak均已在后续批次导入。

## delighted／pleased／peak批次补入

按本轮附件顺序分别接入 `portrait_delighted.png`、`portrait_pleased.png`、`portrait_peak.png`。三张均为1280×1280 RGBA真实透明PNG，原样复制并复用原Profile映射；不改构图、透明度或正文。来源及校验和见 `docs/source/serika_free_h_v1_1/expression_batch_import_manifest.json`。

## 最终Runner验收（2026-10-29）

- annoyed：用户已提供的 `00025-551408964-Picsart-BackgroundRemover.png` 原样复制至 `assets/h/doc_serika/portrait_annoyed.png`；1280×1280 RGBA，SHA256及来源见 `annoyed_import_manifest.json`。
- 原生运行：Godot 4.5.1，macOS原生窗口，Apple M2 OpenGL Compatibility；`tools/serika_free_h_e2e_test.gd` 共179项、0失败，22张真实渲染截图保存在 `docs/qa/serika_free_h/native/`。同一完整流程headless157项、0失败。
- 中文gentle／英文intense两次生产路径：普通人物菜单预约→固定芹香家→下班转场→随机单句入场→真实热区GUI点击→六种实际反应头像→MAX手动选style→六句阶段文本→手动完成及确认→事后两句→次日医院导览。姓名与资源均来自芹香，未串用小夜香。
- 运行期间均禁止保存；结算只推进一天，预约及运行上下文清除，重复完成无效，关系／能力／事件完成事实不重复结算。次日医院导览恢复保存资格。测试没有写入玩家存档，也没有生成中途恢复文件。
- 夹具边界：测试只在独立内存GameState中设置已完成Lv4的业务事实及当天影像科在场事实；未在本次重跑从Lv0到Lv4的自然剧情链。正式代码仍检查真实Lv4完成与亲密资格。
- 六种表情及入场、二阶段、事后、返回页截图已复核：透明底无实色矩形、比例正常，文字和按钮可读；对白框覆盖图片下沿保持既有设计。
- 内容/UI400项、热区104项、预约回归108项、原文/英文220项（86条中英）、叙事本地化26521项均0失败；本地化审计752/752 UI键覆盖。
- 沙箱内原生窗口启动退出134；经受控权限提升后原生窗口成功运行。headless系统证书警告和编辑器设置写入警告不影响本次资源加载，原生完整流程日志无脚本错误。
