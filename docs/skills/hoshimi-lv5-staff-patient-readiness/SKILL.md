---
name: hoshimi-lv5-staff-patient-readiness
description: 核对《星见医院》某位医护开启 Lv5 staff as patient 的剧情、数据、双语患者对白和完整美术缺口；给出可由 Codex 制作的 SFW 图片确认清单，并在确认后协助接入与验收。
---

# Lv5 医护作为患者：逐角色开通核验

本 skill 处理**某个角色**的开通盘点、素材制作清单和接入。先报告真实缺口与来源；不要根据预置剧本、等级数字、文件存在或旧报告直接宣称正式可用。用户只要求盘点时不要改生产数据或生成图片。用户确认 SFW 清单并授权发送参考图给图像服务后，才开始相应生成；本地已有素材的集成无需再次索取授权。

## 找到现行事实

1. 确认项目目录含 `project.godot`，读 `AGENTS.md`／`agents.md` 和 `git status --short`。优先用用户指定的角色 ID；否则从 `data/staff/*/profile.json` 确定 ID。年龄等身份事实仅取项目数据，不凭 SFW 参考图推断。
2. 读该角色 `data/staff/<id>/profile.json`、`relationship.json`、Lv5 事件定义及其原稿／导入登记。逐项分清：已提供、已入库、已映射、Godot 可加载、原生窗口已显示。搜索当前附件、Downloads 指定文件和已有项目资产；不要把旧缺口清单直接转述。
3. 读当前 `godot/systems/staff_patient_registry.gd`、`game_state.gd` 的 `staff_patient_unlocked()`、`godot/systems/advanced_staff_patient.gd`、`tools/staff_patient_lv5_readiness.gd` 和 `tools/patient_sfw_asset_test.gd`。以下数量是现行项目基线；若代码变化，以运行接口为准。

## 必交内容与数据

- **Lv5 固定剧情**：最终原稿、稳定事件 ID、完整节点／选项／说话人／顺序、前置和结算、中文与英文标题、正文、姓名、选项、完成提示及画廊文案。`relationship.json` 的 Lv5 槽须指向 `authored` 事件；真实完成事实、rank history、所需全局 flag 均可由游戏结算。不能用测试中手设 Lv5 取代生产解锁。
- **医护患者档案**：`data/staff_patient_profiles.json` 中的角色配置，含所需完成等级与 flags、性格／对白组、称呼上下文、允许流程、必要的 portrait aliases；`data/staff/<id>/profile.json` 提供年龄、姓名、患者图路径。沿用共享术前／手术 Runner，不复制角色专用流程。
- **普通手术患者对白**：检查角色实际作者稿与 `staff_patient_profiles.json` 的中英 `dialogue`：邀请及术式定制邀请、病房开场、术前反应、麻醉／术中反应、变体、现有交互池覆盖、图文说明和团队特殊回应。不要把某个角色的 28 条、50 池等数量当全员通用门槛；按该角色原稿的 ID 与现行共享钩子逐条对照。没有对应钩子的作者稿标成“原文已有、运行钩子未接”，不能静默编写或错位接入。称呼用显式上下文，不全局替换“医生”。
- **高级手术**：`data/advanced_surgery/staff_patient/stories.json` 的角色 `title/title_en` 与 `consult/night/dark/after/success/failure` 六段中英非空，核对逐句说话人和顺序；预置的 V2.3 不等于正式开放。`data/advanced_surgery/staff_patient/assets.json` 为该角色登记四体位路径、来源和摘要；`procedure_poses.json` 覆盖所有其病例板能提供的 `runtime_ready` 术式。高级入口还需要 Free H 资格、全局批准、已 CLEAR 的常规高级术式与合法日期／团队。
- **存档**：只记录安全边界结算后的稳定事件事实、时间、经验及预约业务事实。事件节点、选项、对白页和术中 session 不持久化。

## 美术矩阵：先列缺口再制作

对照项目的 `docs/staff_as_patient_checklist.md` 和本角色最终剧本节点。基础 SFW **23 项**：`ward` 六态（neutral/smile/brave/worried/afraid/crying）；`operating_table` 全台四态（awake/tense/afraid/anesthetized）；`operating_table_lithotomy` 截石位全台四态；`intraoperative` 裸肩头肩四态（tense/pain/near_collapse/anesthetized）；`splash/general_anesthesia` 一张横图；高级全麻台面 `abdominal/chest/lateral/prone` 四张。台面全图、术中头像、全麻 splash 是三个不同槽位；表情不可用一张 neutral 静默顶替。构图规格以项目现有患者及用户具体要求为准。

另外核对高级夜间段落的 `h_neutral`，通常可复用角色已批准的 Free H neutral；原稿实际引用的背景、CG、术野、头像和差分逐节点列出。`ward_preparation/shy`、`examination/shy` 等全裸检查／病房准备图及用户指定运行 CG 属作者交付项，**不计入 23 项 SFW**。某项如果剧情没有引用，标为可选；已引用则不能用“可选”掩盖缺口。普通共享术野通常复用，不强求每位患者单独制作。用户指定的 NSFW 替换图按原文件接入，保留 SFW 参考和来源记录。

输出一张**可确认的 SFW 制作清单**：每行写槽位、当前状态、参考图是否存在、目标构图、需要的表情、将放的路径；只列确实缺失且可生成的项目。用户确认清单和必要参考图发送授权后，才调用 `imagegen`；若用户只要缺口，停在清单。不得擅自把用户图改画为替代版。

## 检查和接入

用项目已知 Godot 绝对路径或用户提供路径，不因 PATH 无 `godot` 停止。macOS 本地运行时各 Godot 命令加独立的 `--log-file /private/tmp/<unique>.log`，避免沙盒下 `user://logs` 打开失败；保留日志并区分引擎证书提示与项目脚本错误。先运行：

```sh
godot --headless --path <project> --script res://tools/patient_sfw_asset_test.gd -- --kind staff --id <actor_id>
godot --headless --path <project> --script res://tools/staff_patient_lv5_readiness_test.gd
godot --headless --path <project> --script res://tools/advanced_staff_patient_test.gd
python3 tools/advanced_staff_patient_source_audit.py
python3 tools/narrative_localization_test.py
python3 tools/localization_audit.py
```

`patient_sfw_asset_test.gd` 给出逐键 SFW 缺失／不可加载；`--all --inventory` 仅盘点，退出 0 不代表通过。`staff_patient_lv5_readiness_test.gd` 将逐人报告写入 `/tmp/hoshimi_staff_patient_lv5_readiness.json`，阅读目标角色 `missing`；未注册角色可预置文本但不能开放。上述测试还不能证明原稿忠实、患者对白逐句覆盖或视觉构图，须另与原文及资源截图核对。

导入时先归档原稿、明确文件→槽位映射、原样复制图片并登记尺寸／Alpha／SHA-256；按角色档案、患者配置、高级脚本／体位清单接入。完成后用 `hoshimi-native-playtest` 方法在隔离内存前置下跑真实邀请→病房→普通手术及高级病例板→三日事件→结算，中英文分别截图；报告成功、失败、重复预约中实际验收了哪些。不得改玩家存档或放宽正式解锁来让测试通过。

## 交付格式

按 **剧情／数据／对白／SFW 必需美术／作者交付或可选美术／生产入口／测试** 分组列出每项状态与文件位置。对每项标“缺文件、已有未映射、映射但不可加载、已加载待视觉验收、已验收”之一；单列可由 Codex 制作的 SFW 清单请用户确认。只有剧情原文与英文、共享接口、全部必需资源、正式解锁及窗口路径都通过，才称该角色已开放完成。
