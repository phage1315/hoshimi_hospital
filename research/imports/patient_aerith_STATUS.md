# 爱丽丝·盖恩斯巴勒：重建状态

患者 ID：`patient_aerith`。年龄：22。状态：用户 v2 已原样入库、英文已补齐、已注册普通患者池；Godot 实机验收尚未完成。

## 已完成

- 按 `skills/add-patient/SKILL.md` 实读高卷杏参考后，用内置 ImageGen 逐键制作 20 张 SFW 图片；加用户原样提供的诊察图，共 21 个标准键。构图对照、全部表情差异、尺寸、RGB/RGBA、透明底及唯一哈希审计通过。
- 门诊红裙、病房浅蓝交领病号服、仰卧四态、截石位四态、头肩头像四态、全麻面罩特写均按各自规格保存。面罩仅出现在全麻特写。弃用双辫/高开衩等错误草稿，原件未删除。
- 可复用人格 `playful_defiant_detail`：27 条回应、13 组差分。正式患者包仅保留 7 条个人回应、4 组差分覆盖。与用户 v2 整份文件逐字节一致，未改写中文、标点、说话人或阶段顺序。
- 用户 v2 已补齐原先 34 个正文缺口。正式包为 `data/patients/patient_aerith/patient.json`，索引中恰好注册一次。
- 通用人格原有 53 条英文保持不变；新增 62 个患者英文键（名称 1、个人覆盖 15、门诊 4、标题 2、检查提示/回应 5、阶段正文 25、CG 标签/说明 10），均已写入 `data/localization/en.json`。保留门诊 `{line}` 占位符。
- 修正本地化审计未读取共享人格文件的问题，并将共享人格加入患者英文覆盖测试。
- 原样导入用户补充的 5 张全屏 CG（1584×1056 RGB）：诊察 1 张，动作池 4 张。专属绑定已进入正式 bundle 的 `exclusive_cg_pools`；铺巾匹配 `ack_disinfection`，下刀 CG 现绑定接过手术刀后的 `request_scalpel`。此前把它放在 `incise_*` 的绑定已于 2026-10-12 修正；详见 `research/imports/patient_incision_cg_binding_repair_2026-10-12.json`。铺巾和下刀图仅用于腹部/盆腔术式组的画面选择，不限制患者病例分配。

## 文件

- 正式入库记录：`research/imports/patient_aerith_registered_v2.json`
- 用户 v2 原文存档：`research/character_references/patient_aerith/user_bundle_v2.json`
- 历史未完成草稿：`research/imports/patient_aerith_2026-10-09.json`（保留溯源，不再表示当前状态）
- 用户原文：`research/character_references/patient_aerith/user_profile_v1.txt`
- 每次实际生成提示词、输入参考、最终文件：`research/imports/patient_aerith_portraits.json`
- 尺寸/Alpha/哈希与目视验收：`research/imports/patient_aerith_portrait_audit.json`
- 高卷杏与爱丽丝浅/深底并排审计图：`research/imports/patient_aerith_qa/`
- 5 张 CG 来源、逐文件哈希、触发说明及英文标签：`research/imports/patient_aerith_cg_2026-10-10.json`

## 验证

- `python3 tools/aerith_patient_draft_test.py`（保留旧命令名，现测试正式包）：通过完整 schema、v2 原文哈希、唯一注册、7/4 覆盖、27/13 合并、25 个阶段正文、21 张立绘与 5 张 CG 哈希、62 个英文键及中英文 Python loader 检查。动作选择和本地化顺序为静态模拟，并非 Godot 实测。
- PNG 解码、全部标准尺寸/模式、真实 Alpha、21 个唯一哈希、原样诊察附件哈希：通过。
- `python3 tools/patient_bundle_localization_test.py`：通过，1539 个英文条目、0 缺失。东川杏子、香田映见及蒂法的旧缺口已在先前任务补齐。
- `python3 tools/narrative_localization_test.py`：失败，36 项位于已有小夜香 Lv3 事件。
- `python3 tools/localization_audit.py`：失败，其他旧键、UI 覆盖/占位符和硬编码问题仍在；没有新增人格错误。
- `python3 tools/validate_data.py`：失败，既有术式/事件/关系/CG 引用等错误仍在。未修改这些无关内容。
- 未找到可用 Godot 可执行文件，未进行实际 UI 裁切或 Texture2D 运行时测试。
- CG 原图保持不变。现有全屏使用等比覆盖：在 1280×800 下，3:2 原图上下各约裁掉 33 个源像素，诊察图顶部头发可能受影响；未改变全局显示方式。

## 尚未验证的项目

没有待补中文正文。`incision_responses: {}` 按用户 v2 保留，沿用既有模板默认回应，不新增个人覆盖。

当前未找到 Godot 可执行文件；实际游戏流程、英文 UI 排版、Texture2D 加载和 CG 裁切仍待实机验证。全局校验的旧问题未在此次患者导入中改动。

`exclusive_cg_pools.examination` 为 1 个池，`ward_preparation` 为 4 个动作池，`surgery` 为空。这里 `ward_preparation` 是既有动作分发接口，包含手术室准备及实际切开动作，不意味着画面均发生在病房。诊察透明立绘与全屏 CG 分开保存。没有固定诊断、术式、麻醉、剧情或关系绑定。数值暂沿用高卷杏基线，不增加能力/抗痛加成。
