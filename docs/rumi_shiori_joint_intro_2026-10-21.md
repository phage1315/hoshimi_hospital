# 岩崎留美／米田栞共同相识接入记录

2026-10-21。事件 `intro_rumi_shiori_hiroko_monday_0900` 已接入，主数据位于 `data/staff/nurse_iwasaki_rumi/events.json`，两人共用一个事件。

## 原文与演出

用户交付原稿归档于 `research/character_references/rumi_shiori_2026-10-21/joint_intro/HOSHIMI_IWASAKI_RUMI_YONEDA_SHIORI_LV0_JOINT_INTRO_CN_CODEX_READY.md`。

35 节中文正文、标点、说话人及顺序逐句保留。另登记两个获授权的延期首句，单次仍播放 35 节；无玩家分支，节点的单一按钮仅推进正文。英文正文、姓名标签、标题、介绍及画廊说明已登记。按说话人切换现有制服立绘，旁白保留场上人物焦点；smile/neutral/serious/worried/closed_eye_smile 对应原稿情绪意图，未新增 CG。

## 触发与存档

- 弘子已正式相识即可，不需要 Lv1。
- 优先读取 `intro_nurse_hiroko` 的完成日期；无日期旧存档在首次读取时记录游戏日期，使用既有持久化 character_progress_counters 保存。
- 严格晚于基准日期的下一个周一 09:00 为最早时间；错过后持续待触发，在护士站正常访问窗口 09:00–17:00 进入时触发。
- 使用既有地点事件调度，priority=90；地点特殊事件及更高优先级角色事件先行，手术中不抢占。
- 原定周一上午用原始开头，其他上午及下午分别使用授权的时间中性版本。
- 共耗时 20 分钟，事件期间禁止手动存档，完成后返回护士站。

## 共同结算

增加可选字段 `introduction_actor_ids`，只在最终继续动作完成事件后统一登记两人 met、共同 event_history，清除 introduction_pending。不增加熟悉度、好感、经验或等级；弘子关系不变。已完成事件读档时可修复单边相识状态，不重复奖励、不重置已取得成长。旧存档若仅一人 met 且事件未完成，仍能进入联合事件。

`target_level=1` 是现有 character_event schema 的必填兼容字段；introduction 类别不会执行 rank-up，运行测试确认两人保持 Lv0。Lv1–Lv5 仍待用户剧本。

## 验证

- `tools/rumi_shiori_intro_audit.py`：35 节中文逐句、说话人、顺序及 2 个授权首句通过。
- `tools/rumi_shiori_intro_test.gd`：300 项中英文 Godot headless 检查通过；包括 UI 节点加载、日期边界、补触发、优先级、Episode Lock、统一结算、存档恢复及无重复奖励。
- `tools/character_event_test.gd`：180 项通过。
- `tools/narrative_save_lock_test.gd`：6 项通过。
- `tools/narrative_localization_test.py`：10,539 项，0 失败。
- `tools/localization_audit.py`：18,221/18,221 正文覆盖，732/732 UI 英文键覆盖，无硬编码中文候选。
- `tools/validate_data.py`：803 条记录通过。同步修正该检查器中摩耶／双叶旧年龄断言为用户已确认的 28／25，不改人物数据。

未执行 Windows 打包测试。
