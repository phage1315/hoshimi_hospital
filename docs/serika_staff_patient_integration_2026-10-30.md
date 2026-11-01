# 芹香 Staff-as-Patient 与首次手术 Callback：2026-10-30 实装记录

> 当前验收状态以文末「2026-10-31：剩余患者素材及原生完整流程验收」为准；早期的素材缺口和未做原生测试说明属于历史记录。

本轮执行用户确认的步骤 1–4。英文忠实翻译、Callback 15 分钟均已授权。没有改动 Lv5 主线、没有生成患者美术，也没有覆盖玩家存档。

## 当前状态与入口

- actor 使用现有 `doc_serika`（25 岁），Profile 位于 `data/staff_patient_profiles.json`；复用 `enigmatic_self_possessed_detail` 基础对白，专属覆盖优先。人格按稿为 `self_possessed / analytical / asks_for_details`，不改数值与手术机制。
- 邀约要求相识、共享 Staff-as-Patient 项目授权，以及真实已著作 Lv5 的完成事实、对应 rank_history 和 Lv5 等级。本轮最初接线时 Lv5 为 planned；同日后续已实装真实 `serika_lv5_lay_down_burden`，完成后按这些条件开放患者资格。没有创建假 Lv5 或用测试标记开放生产入口。详见 [Lv5实装与验收](serika_lv5_integration_2026-10-30.md)。
- 32 项术式沿用小夜香 V1.6 已批准白名单：普通 3 条随机，特殊每次 1 条。`MAJOR-GYN` 无批准匹配，单独保留。胆囊／脾／肾上腺沿用 A1。占床继续使用系统提示。
- 26 条核心回应、13×2 条准备变体有实际播放入口；另 2 条 hospitalization 回应只保留，不添加住院诊察场景。C1 样本／C2 50 池／C3 结束候选不激活，50 池继续使用原通用内容，未宣称已提供角色专属覆盖。

## 原文与英文

原始两份 Markdown 完整归档在 `docs/sources/serika_staff_patient/`。`locked_cn.json` 为机械提取的 8 条邀约、28 条回应、26 条变体、40 条 Callback 记录；`approved_en.json` 为用户授权的忠实英文译文（并非声称作者逐句审定）。`tools/serika_staff_patient_audit.py` 从原 Markdown 重新提取核对，防止只对照复制件自证。

Profile 中英文位于 `dialogue.zh_CN` / `dialogue.en`。Callback 数据为 `data/staff/doc_serika/staff_surgery_callback.json`，本地化前缀 `collections.character_events.serika_first_staff_surgery_callback`。标题、画廊标题、说话人标签、正文、继续按钮与关门演出提示均有英文；没有新增公告或奖励提示。

## 首次实际手术事实与存档

`GameState.finish_active_surgery()` 在真实完成出口、与协议训练次数分别记录 `staff_patient_first_completion_days[actor_id] = day_number()`，只写第一次。实际术式与约定不同仍属完成；取消／未开始／中止不登记。后续手术不重设日期。

该可选字典加入 v37 安全边界事实白名单；只含角色 ID 和完成日整数。旧档缺省为空，不从训练次数猜测历史日期。JSON 数字读回归一化为整数；负数、非整数、未来日或未知 Profile 拒绝，失败不改当前世界。已观看仍用现有 character_completions，耗时固定为实际结算的 15 分钟。没有持久化 pending 播放节点、对白页码、选择路径或临时表现。

## Callback 接线与表现

事件 ID：`serika_first_staff_surgery_callback`。`serika_staff_surgery_callback.gd` 只判定资格；既有地点事件队列负责开始。首次实际完成日之后的工作日（现行 weekday，排除周六、周日与节假日），09:00 至可完整结算 15 分钟的工作时间进入 `imaging` 才触发。不依赖随机出勤，未观看长期保留。排除正在住院的芹香及独占活动，日初强制角色事件优先，自动特殊事件继续由现行 UI 优先处理。

- 40 个数据节点对应原稿 001–040。39 条可见正文；040 是无文字自动控制节点，设置事件完成并返回影像室，不显示制作备注。
- 005 与其他【舞台】段是旁白，006 才是芹香台词。只移除舞台标签，不删改动作正文。
- 007 的两下捶胸用原文旁白表达，不加循环动画；016 严格使用转身拿复查影像的修订句。004 添加短舞台提示“关门”／“Door closes”，作为003后的动作反馈，不改对白。
- 018 保持一条逻辑对白，由现有 authored 分页显示；拼接后与原文相等。
- 背景为现有 `diagnostics`（地图地点为 `imaging`）。立绘仅使用芹香 `white_coat` 的 worried / angry / shy / soft_smile / cold；不出现其他同事。
- 033 私下原文“龙司”保留，英文 Ryuji；手术室称呼仍为“坂口医生”。
- 完成后绕过本次返回时的普通地点事件再抽取，回到正常影像室；下次主动进入仍按正常调度。没有关系／技能／XP／声望／H 权限奖励。

## 核心回应逐键映射

以下 CN 资源均为 `data/staff_patient_profiles.json → doc_serika.dialogue.zh_CN.reaction_lines.<key>`；英文同路径 `en`。

| Key | 实际窗口 | 说话人 | 状态 |
| --- | --- | --- | --- |
| `hospitalization_question` | 无 Staff 入院诊察窗口 | 无 | RESERVE；仅保存在原稿／Profile，运行患者记录排除 |
| `hospitalization_response` | 无 Staff 入院诊察窗口 | 无 | RESERVE；仅保存在原稿／Profile，运行患者记录排除 |
| `procedure_mismatch` | Preop.apply(kind=procedure) 的术式不一致反馈 | patient | 接入 |
| `explain_plan` | ward_visit / explain_plan → patient_reaction | patient（explain_plan 使用显式 reaction_speakers 覆盖） | 接入 |
| `brief_plan` | ward_visit / brief_plan → patient_reaction | patient | 接入 |
| `last_reassure` | operating_room / last_reassure → patient_reaction | patient | 接入 |
| `choose_general` | ready / choose_general → patient_reaction | patient | 接入 |
| `choose_epidural` | ready / choose_epidural → patient_reaction | patient | 接入 |
| `choose_local` | ready / choose_local → patient_reaction | patient | 接入 |
| `choose_none` | ready / choose_none → patient_reaction | patient | 接入 |
| `induction_reassure` | general_induction / induction_reassure → patient_reaction | patient | 接入 |
| `insist_without_anesthesia` | surgery_start_none / insist_without_anesthesia → patient_reaction | patient | 接入 |
| `assistant_stabilize_none` | assistant_ready / assistant_stabilize 按实际麻醉状态选分支 | staff 回复后追加具名患者行 | 接入 |
| `assistant_stabilize_local` | assistant_ready / assistant_stabilize 按实际麻醉状态选分支 | staff 回复后追加具名患者行 | 接入 |
| `assistant_stabilize_epidural` | assistant_ready / assistant_stabilize 按实际麻醉状态选分支 | staff 回复后追加具名患者行 | 接入 |
| `incision_ready` | Preop.current() → incision_ready，未进入 anesthetized | patient | 接入；既有切皮前窗口 |
| `incise_epidural` | incision_ready / incise_epidural → patient_reaction | patient | 接入 |
| `incise_local` | incision_ready / incise_local → patient_reaction | patient | 接入 |
| `incise_none` | incision_ready / incise_none → patient_reaction | patient | 接入 |
| `contact_pause` | operative_contact / contact_pause → patient_reaction | patient | 接入 |
| `contact_command` | operative_contact / contact_command → patient_reaction | patient | 接入 |
| `contact_continue` | operative_contact / contact_continue → patient_reaction | patient | 接入 |
| `ongoing_narrate` | ongoing_interaction / ongoing_narrate → patient_reaction | patient | 接入 |
| `ongoing_eye_contact` | ongoing_interaction / ongoing_eye_contact → patient_reaction | patient | 接入 |
| `ongoing_silent` | ongoing_interaction / ongoing_silent → patient_reaction | patient | 接入 |
| `closure_reassure` | closure_interaction / closure_reassure → patient_reaction | patient | 接入 |
| `closure_coach` | closure_interaction / closure_coach → patient_reaction | patient | 接入 |
| `closure_silent` | closure_interaction / closure_silent → patient_reaction | patient | 接入 |

## 准备变体逐组映射

每组 CN/EN 各两句；路径为相应 locale 的 `reaction_variants.<key>`，保留原顺序与组号。原有确定性变体选择逻辑不改。

| Key | 实际窗口 | 说话人 | 状态 |
| --- | --- | --- | --- |
| `ward_enema` | 病房准备的原有对应必要／非必要反馈 | patient | 两句均接入 |
| `ward_enema_unnecessary` | 病房准备的原有对应必要／非必要反馈 | patient | 两句均接入 |
| `ward_skin_prep` | 病房准备的原有对应必要／非必要反馈 | patient | 两句均接入 |
| `ward_skin_prep_unnecessary` | 病房准备的原有对应必要／非必要反馈 | patient | 两句均接入 |
| `ward_surgical_cap` | 病房准备的原有对应必要／非必要反馈 | patient | 两句均接入 |
| `operative_positioning_awake` | operative_preparation_reaction_id：清醒／无麻醉状态分支；anesthetized 返回空 | patient | 两句均接入 |
| `operative_positioning_none` | operative_preparation_reaction_id：清醒／无麻醉状态分支；anesthetized 返回空 | patient | 两句均接入 |
| `urinary_catheterization_awake` | operative_preparation_reaction_id：清醒／无麻醉状态分支；anesthetized 返回空 | patient | 两句均接入 |
| `urinary_catheterization_none` | operative_preparation_reaction_id：清醒／无麻醉状态分支；anesthetized 返回空 | patient | 两句均接入 |
| `skin_disinfection_awake` | operative_preparation_reaction_id：清醒／无麻醉状态分支；anesthetized 返回空 | patient | 两句均接入 |
| `skin_disinfection_none` | operative_preparation_reaction_id：清醒／无麻醉状态分支；anesthetized 返回空 | patient | 两句均接入 |
| `incision_marking_awake` | operative_preparation_reaction_id：清醒／无麻醉状态分支；anesthetized 返回空 | patient | 两句均接入 |
| `incision_marking_none` | operative_preparation_reaction_id：清醒／无麻醉状态分支；anesthetized 返回空 | patient | 两句均接入 |

## 验证与余项

- 原文／局部 Schema／资源引用审计：704 checks，0 failures。
- Godot headless 专项：5,112 checks，0 failures；中英各 39 条可见节点及控制结尾。包括 21 个真实 action handler、3 种助手反馈、错术式窗口、切皮前提示及麻醉禁言、所有变体可达、实际 speaker／表情资源加载、分页、排程、15分钟结算、临时文件存档去内部状态、删改节点与耗时后的回读稳定。
- 既有 Staff Patient 回归：142 checks，0 failures。修正旧测试中“病房演出中保存”的过时期望，改测拒绝中途保存以及安全边界住院事实恢复。
- 小夜香 V1.6 对白回归：2,344 checks，0 failures，确认没有影响原 Profile。
- `narrative_localization_test.py` 与 `localization_audit.py` 均通过。通用内容审计仍有既存的朝仓事件尺寸／重复choice、旧日程priority和芹香Lv3约会地点等问题；不为这些既存问题放宽 Schema。新 Callback 单独通过同一 character_event Schema 与资源核查。
- 尚未做本轮第5项：原生窗口视觉验收及患者素材补齐。当前缺患者袍、病房准备差分、患者手术台头像／专属触诊图；没有把医生手术头像或 H 图挪作患者素材，也未新增错误资源别名。正式解锁还需未来真实 Lv5 内容。


## 2026-10-31：作者提供的患者准备素材接入

本次按作者指定顺序接入 10 张原文件：病房准备立绘、洞巾、下刀前、剃毛、灌肠、戴手术帽、担架车、导尿、固定、消毒。完整路径、原文件尺寸及 SHA-256 见 `qa/serika_patient_assets_2026_10_31/import_manifest.json`。所有目标文件与原文件逐字节一致，未编辑或裁切图片。

- 病房准备立绘：1024×1520 RGBA，注册 `ward_preparation/shy`；患者记录中的 `examination/shy` 只作为现有手动病房准备的技术别名，不新增门诊检查流程，也不改变医生立绘。
- 其余九张 CG：1520×1024，患者专属池 `doc_serika`，复用现有准备动作触发。下刀前图绑定 `request_scalpel`，不绑定切皮完成动作。备皮／灌肠兼容已有必要及非必要动作。
- 新池使用 `image_fit: contain`，保持原比例完整显示；旧池默认行为不变。全麻完成后的准备 CG 继续按原规则隐藏。
- 只登记步骤名称并同步英文，没有新增、改写、删除剧情正文。
- 此次仅接入这 10 张作者交付文件。`assets/candidates/serika_patient_2026_10_30/` 中的其他患者素材仍应按各自登记状态处理，不据此宣称全部候选已接入。上方早期验收中关于素材及 Lv5 的文字是当时状态，不代表此刻的全部实现状态。

验证：

- 原文件与目标文件 SHA-256：10/10 一致。
- `tools/serika_patient_asset_test.gd`：Godot headless 中英双语 304 checks，0 failures；22 次清醒动作真实分发／CG 加载／返回，10 次全麻隐藏检查；实际病房准备视图加载新立绘。测试只使用隔离的内存住院记录。
- `tools/serika_staff_patient_test.gd`：5,124 checks，0 failures，中英共 78 个对白节点渲染。
- `tools/serika_staff_patient_audit.py`：706 checks，0 failures。
- `tools/narrative_localization_test.py`：29,665 checks，0 failures；`tools/localization_audit.py` 通过。全仓历史 source fallback 仍存在，本次新增标签均有英文。
- 本轮为资源与 headless 运行验证，未进行人工原生窗口视觉验收。Godot 输出既存 macOS CA 证书读取告警，未影响本轮测试结果。

## 2026-10-31：剩余患者素材及原生完整流程验收

按用户“接入并实机测试”的授权，把候选目录中的 19 张患者素材原样注册到生产资源：病房 6 张、仰卧手术台 4 张、截石位手术台 4 张、术中头像 4 张、全麻过场 1 张。与上一批病房准备立绘及 9 张准备 CG 合计，本轮所需患者素材均已有生产引用。19 张文件尺寸、源路径、目标路径及 SHA-256 见 `qa/serika_patient_assets_2026_10_31/remaining_assets_manifest.json`，均与来源逐字节一致。医生默认服装不变；不新增门诊检查流程，触诊底图继续复用通用素材。

新增 `tools/serika_patient_e2e_test.gd`，以 Godot 原生窗口分别运行中文和英文：

1. 用隔离内存 fixture 提供已相识、Lv5 完成及项目授权等前置，从芹香人物界面打开邀约；通过真实鼠标输入点击确认，检查术式选择和确认按钮布局。
2. 从住院记录继续进入普通术前流程，选择简短告知、手动病房准备、团队编组、全麻及阑尾切除。操作由 UI handler 驱动，CG／全麻过场通过实际按钮推进；手术结果和危机由真实 Runner 结算，没有直接赋值成功。
3. 点击结果页返回，检查出院及首次手术完成日事实；当天不可触发 callback。随后仅在内存中推进到下个工作日，从影像科触发 callback。
4. 中英各核对 39 条可见 callback 正文的本地化、说话人标签和实际表情资源，共 78 个节点；检查结尾返回影像科、结算 15 分钟、仅触发一次及安全边界事实回读。

原生结果：**1,689 checks，0 failures**，机器报告 `qa/serika_patient_assets_2026_10_31/e2e_native.json`。原生引擎日志无脚本错误。截图记录于 `/tmp/serika-e2e-{zh_CN,en}-{ward,result,callback-complete}.png`，已抽查中文病房与结果页面。

验证范围说明：这是原生窗口下的自动化完整流程，不是每个按钮均由人工点击；触诊阶段通过既有完成事件推进，未逐个点击热区；本次完整路线为全麻阑尾切除，未声称遍历全部术式、麻醉方式或详细解释分支。测试使用临时路径与内存状态，没有读取、覆盖玩家存档。前置由 fixture 提供，未重新游玩 Lv0–Lv5。

专项复核：素材测试 420 checks／0 failures（包括 22 次清醒 CG 分发、10 次全麻隐藏检查）；原文审计 706／0；叙事本地化 29,665／0；本地化审计通过，UI 754／754。

已知显示余项：`ward_visit` 初始病房探视页的通用 `prompt` 为空，芹香已批准数据也没有 `stage_prompts` 覆盖。因此该页只有操作选项、没有开场正文；选择后可正常显示专属回应。此项是现有文本缺口，不是立绘加载或对白绘制失败；本轮没有擅自补写。其余未获授权的 C1／C2／C3 专属内容仍保留原先范围说明。
