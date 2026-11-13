# 高级术式数据与素材交付清单 V1

医护作为患者的高级手术另须遵循 [Staff-as-Patient / Lv5交付清单](staff_as_patient_checklist.md)：每名新开放角色必备腹部仰卧、胸部仰卧、侧卧、俯卧四种全麻手术台图，术式显式映射体位。

核验日期：2026-10-31。以当前 Whipple 已运行的内容包、Runner、资源映射为依据；这是新术式的作者／工程交付清单，不表示其他术式已经完成，也不是承诺仅放入 ZIP 就会自动导入。普通 Surgery 与 Advanced 分开，复用生理 effect／危机 resolver。

## 给写作 GPT 的简版

每台高级术式交付：**首次患者资料、Day 1 剧情、11–13阶段流程（约5–6个P）、逐阶段技术对白及失败回应、Day 3首次成功剧情、数值／危机配置、图片映射清单**。Whipple实际为13阶段、6个P、30条入场变体＋12条失败变体、前后剧情各12句；后续剧情不必强凑12句。

请从仓库提取下列当前文件作为样板，不依赖旧聊天或早期三阶段示例：

| 内容 | 当前样板／解析器 |
|---|---|
| 术式与阶段数值 | `data/advanced_surgery/procedures.json` 中 `surgery_open_whipple` 对象 |
| 双语岗位对白 | `data/advanced_surgery/dialogue/surgery_open_whipple.json` |
| 首次患者与前后剧情 | `data/advanced_surgery/stories/surgery_open_whipple.json` |
| 三阶段术野图片 | `data/advanced_surgery/field_windows.json` |
| 对白合法字段 | `godot/systems/advanced_operative_dialogue.gd` 的 `valid()` |
| 生理效果／危机接线 | `godot/systems/advanced_physiology.gd`、`advanced_surgery_session.gd` |
| 持久事实白名单 | `godot/systems/advanced_referral_facts.gd` |

目前没有一份覆盖高级内容包全部内容的统一 JSON Schema；不要虚构新的 schema 版本。对白明确使用 `advanced_day2_dialogue_v1`，其他数据以当前读取器和测试为准。发给写作 GPT 时应复制这些最新文件，或提供本清单与同一版本的数据摘录。

作者负责确定角色、诊断与剧情原文、说话人、顺序、首通与返场区别、素材及场景对应；提供英文或明确授权忠实翻译。数值可由作者提供，也可明确授权开发者制定待试玩测试值。涉及用户准备的 NSFW／术野素材，由作者提供成图；所需图片并非必须采用 NSFW表现。

## 一、术式与玩法数据

新增到 `procedures.json` 数组的术式对象：

| 字段 | 要求 |
|---|---|
| `id` | 稳定术式ID，和对白、故事、图片索引一致；不要改动已存在病例ID |
| `name`, `name_en` | 中英术式名称 |
| `duration_minutes` | 总耗时回退值；逐阶段显式时间优先，不能把两者重复加算 |
| `base_difficulty`, `training_ceiling`, `reward_tier`, `status` | 依当前术式格式；Whipple仍为prototype，不擅自宣称正式平衡完成 |
| `patient_notice`, `patient_notice_en` | 无首次故事资料时的病例说明；不能拿占位说明替代首次患者诊断 |
| `steps` | 有序阶段，当前建议11–13个；按实际阶段数量生成UI进度 |
| `crisis_checkpoints` | 阶段顺序的 **1起算序号**；Whipple `[5,10]` 对应W05／W10完成后 |
| `crisis_chances` | 与检查点对应的HP-only模拟概率；正式Full Physiology用普通危机resolver，不把这组概率再抽一次 |
| `physiology_tuning_status` | 测试平衡值标记 `P0_TUNING_PENDING_GAMEPLAY_APPROVAL` |
| `failure_condition`, `success_condition` | 普通生理条件表达式；参照现行Whipple，不自行新造条件语言 |

每个阶段填写：`id`, `name`, `name_en`, `kind`, `hp_base`, `difficulty`, `specialty_tag`, `hp_failed_extra`, `strategic_effects`, `physio_stress`。需要时附 `conditional_effects` 与 Strategy `options`。

- **F / L**：当前均为确定性步骤按钮；不要自行加入精细判定。
- **S**：两个合理的策略选项；各有 `id`, `label`, `label_en`, `description`, `description_en`, `strategic_effects`。阶段基础效果和选项增量各一次；不要在选项里重复填阶段已经计入的全部时间。
- **P**：主刀／第一助手／第二助手选择，概率和HP成本由现行Model计算。专科标签与实际助手登记表匹配。
- `strategic_effects` 可含 `elapsed_time`, `visibility`, `bleeding`, `blood_loss`, `stability`；这些是增减值。`progress`由桥接层按阶段处理，不需作者另造进度系统。
- `physio_stress`及条件字段使用现有resolver支持值。新标签／新危机机制必须单独确认。

必须保留的语义：HP为额外储备，不替代Stability；同阶段时间、生理效果、危机抽取只一次；Precision失败不额外追加出血／失血／稳定度惩罚；Strategy不增加随机判定。HP耗尽与生理失败均可终止。预估器是独立固定种子的HP-only模拟，不等于正式全生理胜率；当前1024次、显示按5个百分点取整，不能把同一个显示百分比误认为队伍没有变化。

## 二、首次患者与三天叙事

`stories/<procedure_id>.json` 使用：

```json
{
  "procedure_id": "surgery_new_procedure",
  "source_case_id": "作者病例编号",
  "runtime_case_id": "advanced_first_surgery_new_procedure",
  "patient": {
    "id": "patient_new_first_case",
    "name": "患者中文名",
    "name_en": "Patient name",
    "setting": "作者明确的人物设定",
    "diagnosis": "作者中文诊断",
    "diagnosis_en": "Faithful English diagnosis",
    "visuals": {"portraits": {}}
  },
  "day1": {"title": "标题", "title_en": "Title", "background": "clinic", "portrait": "ward", "lines": []},
  "day3": {"title": "标题", "title_en": "Title", "background": "ward", "portrait": "postop", "lines": []}
}
```

`lines`每条为 `{"speaker":"patient或PLAYER","text":"原文","text_en":"忠实英文"}`。当前首次剧情渲染仅支持患者与主角；要增加第三位说话人、分支、CG节点或条件对白，必须另做接口，不能静默把医护对白写成旁白。原文引号与标点保留。背景为已有背景ID；新背景须登记。

Day 1：首次患者VN → 一屏编组 → 确认排程。Day 2：全麻splash → 患者准备页 → 七岗位Time-out → 手术。Day 3：先完成结果结算，再播放首次成功VN。2026-11-11修正：正式新预约只在周一至周四普通工作日、16:00及之前接受，连续三个自然日完成；次日必须可正常手术，第三日允许周六复盘。三日中遇医院休诊日或既有预约／受保护剧情冲突时拒绝新预约，不跳日拼接。医护患者高级手术共用此排期。旧预约保留已记录日期，术后只向前推进到预约复盘日；历史结算日期与奖励不重写。

首次失败沿用 `dialogue/day3_failed.json` 全局四句与失败结算，不播放成功剧情。首次成功后返场使用随机患者，跳过专属首次Day1／Day3；Quick仍关闭。病例包不应重复实现奖励、解锁、存档或日历系统。

## 三、术中对白

文件 `dialogue/<procedure_id>.json`：

```json
{
  "schema_version": "advanced_day2_dialogue_v1",
  "procedure_id": "surgery_new_procedure",
  "stages": {
    "N01": {
      "stage_entry": [
        {"id":"N01_E1","speaker_role":"lead_surgeon","text":"作者原文一","text_en":"Author-approved English one"},
        {"id":"N01_E2","speaker_role":"scrub_primary","text":"作者原文二","text_en":"Author-approved English two"}
      ]
    }
  }
}
```

每阶段 `stage_entry` 2–3条变体，正常阶段只选其中1条；P节点另有 `precision_failed` 2–3条。Whipple完整42条；不要理解成每次手术连续读完42句。结果页保留本阶段选中的原文与说话人；失败／救援按已有契约处理，不重复抽对白或增加游戏随机数。

| `speaker_role` | 实际绑定 |
|---|---|
| `lead_surgeon` | 主角 |
| `assistant_1`, `assistant_2` | 本次第一／第二助手 |
| `scrub_primary`, `scrub_secondary` | 本次主／副器械护士 |
| `circulating_primary`, `circulating_secondary` | 本次主／副巡回护士 |
| `anesthesia` | 本次麻醉科医师 |
| `system` | 旁白，无借用角色立绘 |
| `acting_surgeon` | 仅用于 `precision_failed`，绑定失败操作的实际执行者 |

按术式和岗位写技术对白，不把默认编组姓名写死。全麻患者不参与术中对白。每条仅上述4字段，不夹带HP／生理效果；演出与判定数据分开。IDs唯一，阶段ID须在术式中存在。

## 四、图片清单（当前Whipple标准）

下表分辨率是现有交付规格／建议，不是硬性引擎限制。所有素材保持比例，不以裁切来勉强适配；作者原图不擅自加工。

| 图片 | 用途与映射 | 当前Whipple规格 | 新包交付建议 |
|---|---|---|---|
| 病房患者立绘 | `visuals.portraits.ward`；Day1、编组 | 1024×1536，透明PNG | 一张，沿用患者立绘画风，头到膝／既有构图，真实alpha |
| 术后患者差分 | `postop`；Day3 | 同系列透明PNG | 一张，可由病房立绘做恢复期表情／动作差分 |
| 全麻头部／splash | `intraoperative/anesthetized` 和 `splash/general_anesthesia` | 1672×941；同一图复用 | 一张16:9高清，闭眼、手术帽与呼吸管路；用于全麻过场及准备页头像 |
| 铺巾后的手术台图 | `team_confirmation` | 1672×941 | 一张16:9，脚左头右俯视，腹部洞巾开口、全麻与监护细节；准备页和岗位确认复用 |
| 切皮术野 | `field_windows.<id>.incision_path` | 1280×1024 | 一张；开始切皮、未进入腹腔；可复用合适通用资产 |
| 主要开放术野 | `field_windows.<id>.path` | 1280×1024 | 一张术式最有辨识度的术野，不要求每阶段一图 |
| 关腹术野 | `field_windows.<id>.closure_path` | 1280×1024 | 一张；末阶段关闭／缝合，可复用符合该切口的资产 |
| 背景 | Day1／Day3／手术室 | 复用已有诊室、病房、手术室 | 如无特殊场景，无需新画 |
| 医护立绘 | 从实际编组角色与岗位读取 | 复用现有无菌服／刷手服 | 不为每台术式重画完整团队；缺图时列缺口 |

完整Whipple现为 **4张患者相关图＋3张阶段术野图＝7张**，外加复用背景与医护。`incision_path`、`closure_path`、`team_confirmation`在读取器中可选，缺失时不应擅自拿另一个具名患者图顶替；若以“Whipple同等演出规格”交付，应补齐或明确授权复用。术野画布建议1280×1024或更高同等比例；当前窗口4:3，5:4图片会留边，不需强制改正方形。病例包可以完全采用SFW患者图；切口／术野图片可由作者交付或授权使用已有素材。

`field_windows.json` 示例：

```json
{
  "surgery_new_procedure": {
    "after_stage": "N01",
    "before_stage": "N13",
    "path": "assets/surgeries/new/field.png",
    "incision_path": "assets/surgeries/new/incision.png",
    "closure_path": "assets/surgeries/new/closure.png",
    "aspect_ratio": [4,3]
  }
}
```

现行语义：进入`after_stage`先显示切皮图；该动作结算后换开放术野；进入`before_stage`换关腹图；手术结束隐藏。字段名是既有历史契约，不能按字面误读为这两阶段完全不显示。图片路径基于项目根，不含临时目录。首次患者图仅用于该患者，不自动套到随机返场患者。

## 五、交付包与作者决定

建议一个包内放 `README`、术式JSON对象、故事JSON／中文审稿MD、术中对白JSON、素材目录与映射表。README注明版本、替代哪份旧稿、英文授权、尚缺素材、待确认数值；图片表列文件名、目标节点／用途、分辨率、是否透明、来源与授权。

作者必须决定：

1. 首次患者是谁、项目设定、诊断、手术原因及叙事边界。
2. Day1／Day3完整原文、标题、说话人、顺序；非标准分支单列。
3. 手术关键阶段与操作名称、专科要求，是否有额外设计。
4. 图片内容和节点映射，哪些必须专用、哪些允许复用。
5. 英文成稿或翻译授权；数值成稿或待试玩平衡授权。

开发负责：合法字段校验、稳定ID映射、现有resolver接线、双语接入、资源注册、一次结算、真实编组与图片显示、测试与差异报告。不得自行创作缺失剧情或把占位台词当成作者最终稿。

## 六、验收门槛

- 核对全部阶段／P节点、策略名称与效果、危机检查点、阶段时间；双惩罚与双危机抽取测试。
- 原文逐句审计：中文、引号标点、说话人、顺序一致；英文覆盖标题、正文、标签、提示与选项。
- 中英完整实机：Day1→编组→准备／Time-out→每阶段入场和结果→失败／成功Day3。轮换真实编组确认对白与立绘对应。
- 一屏编组：长姓名、未选／重复人选、冷却／资格、动态预估、固定确认按钮、重新排程不重复耗时。
- 图片加载／比例／切换／UI遮挡，实际使用患者身份正确。
- 首次失败锁定、首通、返场、奖励仅一次、日期实际结算；明确Quick未开放。
- 只保存病例、预约、结果等稳定事实。禁止保存阶段、HP、随机种子、助手已用次数、剧情游标／选择路径；普通Surgery行为不变。

现有工具参考：`tools/whipple_content_audit.py`（Whipple专用原稿核对，不能直接冒充新术式审计）、`tools/whipple_content_test.gd`、`tools/advanced_operative_dialogue_test.gd`、`tools/advanced_team_ui_test.gd`、`tools/advanced_surgery_test.gd`。所有叙事变更还须运行 `python3 tools/narrative_localization_test.py` 和 `python3 tools/localization_audit.py`。新术式需提供自己的原文基线与病例测试，不能只凭Whipple回归通过就宣称完成。

## 2026-11-01 发布与返场约束

新内容必须在 `data/advanced_surgery/release_manifest.json` 追加固定release_order。第5伊兹米、第6美纱已预留，不得越过未ready项。普通新病例最多三格；教学完成次月起1／15发放资格；周一已首通普通术式固定有放回抽两例。Advanced不提供Quick，返场完整手动三日。独立DEV可展示全部内容，不能用来断言正式池全量已开放。见[2026-11-01 V2实装与验收](advanced_referral_rules_v2_implementation_2026-11-01.md)。
