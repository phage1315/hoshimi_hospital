# 岩崎留美、米田栞正式注册与美术接入

日期：2026-10-21。状态：正式数据与美术已接入；联合初见剧本待用户提供。

## 人物与开放状态

- `nurse_iwasaki_rumi`：岩崎留美，20岁。技能按用户确认的15/44/72/66/52/62导入。
- `nurse_yoneda_shiori`：米田栞，18岁。技能按用户确认的10/46/60/68/45/57导入。
- 身高、体重、三围保存在档案外观字段；原始完整设定及对白保存在research的V2源包中。
- 初始均为未相识、Lv0、熟悉度0、好感0。Lv1–5为planned，没有虚构事件或自动晋级。
- 相识后支持专属护士、休息室、天台、普通下班同行及全部普通护士岗位。米田不在手术室自然刷新，手动编组不受影响。
- 当前没有周日约会资料、亲密事件或医护患者解锁；后续关系线待剧本。

## 美术

每人：制服5表情（neutral、smile、serious、worried、closed_eye_smile），洗手服4表情、无菌手术衣4表情（neutral、focused、warm、worried），春夏/秋冬常服各一张，术中头像一张，器械/巡回/病房岗位CG各一张。

合计：30张立绘（含20张新差分）、2张头像、6张岗位CG。手术帽沿用已确认的包裹发量造型。常服按3–8月春夏、9–2月秋冬切换。

- 立绘：`assets/characters/rumi_shiori_v1/<actor>/`
- 头像：`assets/characters/intraoperative_staff_avatars_v1/<actor>/neutral.png`
- 岗位CG：`assets/events/staff_surgery_v1/<actor>/`
- 来源、目标及SHA-256：两人的`data/staff/<actor>/assets_manifest.json`
- 本轮工具：内置imagegen。提示词、生成文件来源与输出：`research/character_references/rumi_shiori_2026-10-21/{expression_samples,role_samples}/`内各JSON。
- 基础图与常服按用户已批准版本复制；未覆盖其他角色素材。

## 对白映射

原文来源：`HOSHIMI_RUMI_SHIORI_FULL_DIALOGUES_V2_2026-10-21.zip`，以及用户补充的8句术前说明。206项中英双语条目及8句中文补充已逐句核对，未改字或标点。

- 补充说明接入档案顶层`preop_graphic_wrapper`四字段，英文已补齐。
- 诊断错误回应按原数组顺序映射：第一句→`diagnose_gastro`，第二句→`diagnose_observe`；正确诊断回应新增独立读取，旧角色无该资料时行为不变。
- 8类危机×普通/严重×3次尝试，依据真实severity和attempt读取；不改变触发率、处置成功率或奖励。
- 护士站、病房、器械和巡回日常工作回应登记为地点工作闲谈；手术具体步骤仍使用通用术式原文。
- 休息室、天台各3段；护理准备报告、术前说明后的支援报告和术后回应均有读取出口。
- 下班邀请、接受、婉拒、路上闲谈、告别保留对白与旁白归属；后两段使用独立继续页，不改变同行熟悉度及冷却。

## 验证

- 数据/schema/资源引用：802条记录通过。
- 新角色运行回归：690项，中英文均零失败；覆盖全部危机组合、编组资格、专属护士、诊断反馈、季节服装、PNG透明角点及导入纹理、老存档缺失新角色时的默认初始化。
- 原有诊断纠错回归：1287项零失败。
- 原有危机回归：41项零失败。
- 原有同行回归：101项零失败。
- 原有手术成长结算：64项零失败。
- `staff_localization_test.py`、`narrative_localization_test.py`、`localization_audit.py`通过。
- `rumi_shiori_dialogue_audit.py`核对全部提供对白原文。
- 原生Godot中英文两季截图：`docs/qa/rumi_shiori_registration/`；已抽查中文留美春夏、英文米田秋冬，无背景色块或对白遮挡。
- Headless运行有本机证书读取提示，不影响上述断言；不声称已进行Windows打包验收。

## 初见接入待办

待用户提供联合初见完整剧本。既定设计为与弘子正式相识之后的严格下一个周一09:00起，在护士站首次进入触发；错过保留。两人相识状态应在事件完成时一起写入，Lv仍为0。当前未建立空事件，也没有提前设置met。现有正式bundle与角色ID可供剧本直接引用。

## 2026-10-21 联合初见已接入

用户提供《护士站的两位同事》后，联合 Lv0 初见已完成中文原文接入、英文本地化和运行验证。此前“初见待剧本”的记录为历史状态；当前详见 [联合初见接入记录](rumi_shiori_joint_intro_2026-10-21.md)。新游戏仍保持两人未相识，完成事件后共同解锁，Lv1–Lv5 仍待剧本。
