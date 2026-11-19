# 七瀬恋患者美术候选清单

## 第一阶段：基础图

- [x] `ward/neutral.png`
- [x] `intraoperative/tense.png`
- [x] `operating_table/awake.png`
- [x] `operating_table_lithotomy/awake.png`（短台与两侧独立腿托重构版）
- [x] `splash/general_anesthesia.png`
- [x] `advanced/abdominal.png`
- [x] `advanced/chest.png`（已按用户指定附件原样替换）
- [x] `advanced/lateral.png`
- [x] `advanced/prone.png`

当前 9/9 张基础图已确认。

## 第二阶段：14张差分

- [x] 病房：`smile`、`brave`、`worried`、`afraid`、`crying`
- [x] 术中头像：`pain`、`near_collapse`、`anesthetized`
- [x] 普通仰卧：`tense`、`afraid`、`anesthetized`
- [x] 截石位：`tense`、`afraid`、`anesthetized`

14/14 张差分已完成。截石位麻醉态包含透明麻醉面罩及完整连接右侧麻醉机的连续波纹管；普通仰卧麻醉态与术中头像麻醉态按槽位规范不含面罩。

## 待接入包

- [x] `prepared/nurse_haru/` 共23槽
- [x] 病房6张及术中头像4张已用本地 BiRefNet-ToonOut 离线透明化
- [x] 其余13张保留完整场景
- [x] 已复制正式 `assets/characters/nanase_ren_staff_patient_v1/nurse_haru/`
- [x] 已修改普通患者与高级手术美术映射
- [ ] 患者档案／双语对白尚未提供，生产入口保持锁定

## 版本保留

- `previous_v1/intraoperative/tense.png`：下缘带无菌巾的术中头像初版，仅供追溯；正式候选已改为画面内仅见裸肩、锁骨和上胸部，不出现无菌巾或其他布料。
- `previous_v1/operating_table_lithotomy/awake.png`：腿托距离较窄的初版，仅供追溯。
- `previous_v2/operating_table_lithotomy/awake.png`：短台与分离腿托已修正但仍穿短袖患者袍的中间版，仅供追溯；正式候选已按项目规范改为裸肩、高位铺巾完整覆盖胸部。
- `previous_v1/advanced/chest.png`：附件替换前的全覆盖 SFW 生成版，仅供追溯。

## 作者附件

- `author_supplied/advanced_chest.png`：用户指定的开胸高级手术体位图；与正式候选 `advanced/chest.png` 字节一致。
