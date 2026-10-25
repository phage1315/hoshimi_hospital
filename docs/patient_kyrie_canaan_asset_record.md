# 琪里耶·卡南（patient_kyrie_canaan）素材记录

- 患者数据原包副本：`research/character_references/patient_kyrie_canaan/user_bundle_v1.json`；该文件及患者数据、对白均未因本轮重制而改变。
- 第一批种子图保留在 `seed_01.png`、`seed_02.png`、`seed_03.png`；新一批四张种子图另存于 `seed_2026-10-25_01.png` 至 `seed_2026-10-25_04.png`。两批均作为历史参考保留。
- 按用户新授权，以2026-10-25四张新种子图重制并替换项目中的上一批17张患者SFW图。当前矩阵：门诊 `outpatient/neutral`；病房 `ward/neutral, smile, brave, worried, afraid, crying`；查体 `examination/shy`；仰卧手术台 `operating_table/awake, tense, afraid, anesthetized`；术中头像 `intraoperative/tense, pain, near_collapse, anesthetized`；全麻 splash `splash/general_anesthesia`。患者包映射仍指向同一运行时路径。
- 新一批的病房图为浅蓝病号服透明头像，手术台图以被单覆盖，术中图限定头颈肩且着高领无菌衣；门诊保留深色双排扣服装、棕色手套和蓝色帽饰。图像均未包含种子中的游戏标志/文字。
- 当前已接入17张。项目所述21张矩阵还包括4张截石位手术台表情；此前生成请求被图像服务拦截，未尝试绕过，本轮继续使用现有运行时回退逻辑，不声称拥有专属截石位图。
- 所有17个登记路径均存在；新一批源图与运行时文件可用 `shasum -a 256` 复核。英文locale和患者数据未改动。
- 英文文本登记于 `data/localization/en.json`；源患者包中文字符串未改写。`examination`、`ward_preparation`、`surgery` 专属 CG 池及 `diagnosis_reactions` 在来源数据中为空，按原数据保留，不视为必需 SFW 立绘槽。
- 验证：`python3 tools/validate_data.py` 通过（922 records）；`python3 tools/patient_bundle_localization_test.py` 通过（3131 English entries，0 failures）。本环境未运行 Godot，因此未做运行时场景验收。

## 2026-10-25 美术复核修正

- 用户指出此前除门诊/常服及病房/病号服外的图均不合格。本轮仅替换 `examination/shy`、`operating_table/*` 四态、`intraoperative/*` 四态及全麻 splash，共10张；门诊与病房7张保持原样，患者数据和路径映射不变。
- 手术台四态改为明确可见的仰卧手术床场景：一次性无纺布松紧褶边手术帽包住大部分头发；患者不穿衣，露出颈部、锁骨与肩部，胸部及身体由不透明手术单完整遮盖。四态分别为清醒、紧张、害怕及麻醉。
- 术中头像四态统一为透明底头颈肩构图，使用同款一次性褶边手术帽；移除高领/衣物，只保留裸露肩颈。查体差分为散发无帽的害羞表情，胸部以下由检查单遮盖。全麻 splash 为戴帽、面罩麻醉、手术单遮盖身体的临床场景。
- 十张替换图直接写入原登记路径；登记数量仍为17张，CG池与英文文本不变。最终路径、格式和映射仍由患者 `visuals.portraits` 提供。

## 2026-10-25 SFW 基准与表情差分批次

- 用户确认新的四张基准图并认可表情差分。本批在不改动对白/患者设定的前提下，完成病房 `neutral/smile/brave/worried/afraid/crying`、仰卧手术台 `awake/tense/afraid/anesthetized`、截石位手术台 `awake/tense/afraid/anesthetized`、术中透明头像 `tense/pain/near_collapse/anesthetized`，共18张。
- 新图存入 `assets/characters/patient_kyrie_canaan_v2/patient_kyrie_canaan/`，患者包中上述18个映射切换至 v2；原 v1 运行资源未覆盖、未删除。门诊、查体及 splash 映射保持原有路径。当前完整矩阵为21个图像键：18张本批病房/手术场景图，加3张保留图。
- 仰卧与截石位差分保持各自基准构图；麻醉态闭眼放松。病房与术中图保留 alpha 通道；截石位全身图源 alpha 全不透明，因此以 RGB 保存。逐文件格式、尺寸与 SHA-256 记录见 `docs/qa/patient_kyrie_canaan/sfw_portrait_checklist_2026-10-25.md`。
- 本批自动验证：`python3 tools/patient_data_import_test.py patient_kyrie_canaan` 通过；`python3 tools/validate_data.py` 通过（922 records）。当前环境没有 Godot CLI，尚未运行 Godot 纹理导入及 `tools/portrait_test.gd` 运行时检查。
