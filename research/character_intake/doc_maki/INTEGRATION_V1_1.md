# 麻纪 V1.1 基础医生接入（未完整验收）

已注册 `data/staff/doc_maki/bundle.json`；保留作者原文与中英台词。21岁、六维48/65/72/68/56/45，limited，初始affection/familiarity/level=0、met=false、route=colleague。可攻略，无永久同事锁。

## 解锁契约

未来 `maki_lv0_onboarding` 事件完成，并结算 `met=true` 后即可进入普通手术助手、高级一助／二助候选。不需要Lv1，不新增高级技能限制；不能独立主刀。仅设置met或仅注册文件不能解锁。当前没有生产Lv0事件，因此正常新游戏仍不可招募。

休息室采用现有fixed_locations机制（非保证每次必在场），天台采用现有rooftop随机机制；默认白大褂。Lv1–5均planned、event_id为空，熟悉度未定为0，沿用3天冷却和Lv4/5未激活权益占位；并无实际剧情或权益开放。

## 未完成项

- 作者V1.1缺少limited医生要求的 `intraoperative_correction` 中英专属回应。用户明确选择自行补充；未复制通用回应到角色数据。现有引擎仍有全局fallback，不能据此声称专属台词齐全。
- 尚无date profile及约会对白，生产校验对此失败；未擅自编写。此缺口在Lv0–5事件之外，若要求完整恋爱日常还需作者交付。
- 独立术中HUD头像标记needed，当前沿用引擎显示回退；未生成新头像。
- Lv0–5正式事件、原生窗口验收、存读档回归尚未完成。

## 实际验证

- `python3 tools/maki_source_audit.py` 通过：档案原值（presence单独工程映射）、台词、中英翻译、原稿SHA及CG逐字节一致。
- Godot `tools/maki_staff_test.gd` 中英合计56检查0失败：解锁前后、仅相识不解锁、普通/高级候选、主刀排除、原文分配回应、CG一次奖励、14立绘与CG加载。仅内存fixture，无玩家存档。
- Godot editor import退出0；宿主证书/editor settings沙箱报错仍存在，不能称无错误导入。
- `python3 tools/narrative_localization_test.py` 47340检查0失败；`python3 tools/staff_localization_test.py` 1208条通过。
- `.venv/bin/python tools/validate_data.py` 未通过：麻纪剩余date profile和correction两项，另外包含仓库已有其他角色/事件问题。
- `python3 tools/localization_audit.py` 未通过：voice_director.gd已有5行硬编码中文；英文覆盖55700/55700。
- `git diff --check` 通过。未进行全仓通过声明、原生手工点击或正式事件完成声明。

## 维护

`tools/import_maki_staff.py` 是本次导入映射，不应在未来人工扩写后盲目重跑覆盖数据。补充稿需另存原文，再定向修改correction/日期资料及相应本地化和测试。源稿在research/source_scripts，导入记录在research/imports/maki_staff_v1_1.json。
