# 毛利兰 SFW 立绘差分（2026-10-20）

用户确认门诊与病房基础图可用，并要求沿用现有 SFW 图完成全部差分。共接入患者立绘矩阵20个槽位：门诊1、病房6、仰卧手术台4、截石位4、术中4、全麻后splash 1。另有用户提供的 `examination/shy` 独立保留，不计入这20项。生成时仅使用用户提供的SFW参考图1–6及本表中的SFW基础图；附件7裸体图未用于本批SFW生成。

差分生成原则：以对应患者基础图作为编辑目标，保持其构图、体位、背景、服饰/遮盖与既有画风，只变更状态表情；术中差分沿用术中基础头像。每个条目均单独输出。用户明确确认门诊/病房基础图没有光晕，按其确认采用。截石位的一次生成请求未得到可用输出，随后仅以批准的SFW截石位基础图重试并成功；失败输出未导入。

生成输出根目录：`/Users/ningye/.codex/generated_images/01a123d3-05f7-71e1-8a5b-e2399c44430b/`。以下 SHA-256 为复制后的运行时文件校验值；运行时文件与该生成输出逐项复制。

| 槽位 | 生成输出文件 | 运行时文件 | 尺寸 / alpha | SHA-256 |
|---|---|---|---|---|
| outpatient/neutral | `exec-3a3588d5-a2d5-43c8-a043-5b2208cadfdd.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/outpatient/neutral.png` | 1024×1536 / 有 | `3b04306da227612c7962520268624b874f6a2717c9e5c4d893f32e507f21a9a0` |
| ward/neutral | `exec-d4f45eeb-0847-4e32-aa4e-6bbd6fe043ec.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/ward/neutral.png` | 1024×1536 / 有 | `4ae97319ba2919b4599a8acf549e776d8787af69c3046a35908d360924011909` |
| ward/smile | `exec-51d03561-29f2-489e-a2ab-e05faae17b19.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/ward/smile.png` | 1024×1536 / 有 | `73353f5602e00cc75cffda332fece869bd464eb59a44ca400a6c07ac63c76563` |
| ward/brave | `exec-6624ed22-12f5-42e6-8f9c-a3c23d5ec3de.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/ward/brave.png` | 1024×1536 / 有 | `b0b1ed4204c63f09f24ba923300a9b078e5a03f96a5a5748a0a857d858c12632` |
| ward/worried | `exec-2e0f5fd0-dfaa-4d75-b763-3ff123ad74e3.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/ward/worried.png` | 1024×1536 / 有 | `4ca5ad4f7682880ff4ba0596642d4a891f465311bc2abbb78fb8aeed9c3f33db` |
| ward/afraid | `exec-c5112665-bf8c-405b-969f-29ee26c788f5.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/ward/afraid.png` | 1024×1536 / 有 | `cf7f2f526a89cf46495ced36695f9e009300e2bf4e7d1859035117ec65e4f08c` |
| ward/crying | `exec-154789fa-5ecd-4245-9ab2-265813dd69ca.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/ward/crying.png` | 1024×1536 / 有 | `12794ec4c83ceeb0923bec301ebd2db1506d8cc5320e750a9503c9a2e089b05d` |
| operating_table/awake | `exec-ceeddcee-405b-47a1-93eb-96640d2ecc31.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/operating_table/awake.png` | 1448×1086 / 无 | `02c6c8dee1327a463321baf7039eacb31db42da883b7de03c38780681afeffd9` |
| operating_table/tense | `exec-d03601de-c496-429e-8ab1-85415e145c7e.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/operating_table/tense.png` | 1448×1086 / 无 | `dcb593483ed1bb4ad5d5c93845e6d9e1f0c787d7af82bdb11c5f33ca45e53ec2` |
| operating_table/afraid | `exec-52bb9f28-e1a0-4aa3-8fb2-b466948ccb7a.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/operating_table/afraid.png` | 1448×1086 / 无 | `98c76194764820644f2a3765cd366828a2181d6127d95c736ce294bcd8b89e8a` |
| operating_table/anesthetized | `exec-71d63e62-867c-4568-aeda-9189cc78735c.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/operating_table/anesthetized.png` | 1448×1086 / 无 | `14f5c96225ae6ed952305395136dcab29d005451deb3dda12143d871b51d1561` |
| operating_table_lithotomy/awake | `exec-a9f37e36-5f12-4b47-9e86-11ee6b4c70d6.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/operating_table_lithotomy/awake.png` | 1448×1086 / 无 | `8777ebdd8635717f43c7853104002dc67d358cb31e71e1c5f99d03b4e026de9a` |
| operating_table_lithotomy/tense | `exec-dafc82b3-bf66-4f24-a975-97f453350979.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/operating_table_lithotomy/tense.png` | 1448×1086 / 无 | `58ccaa293e598a1871011f0539f9c9676952d2e3b606a60cb48d9d988a0afca9` |
| operating_table_lithotomy/afraid | `exec-23188870-1b3b-44e3-b3e0-cb7dfcf51737.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/operating_table_lithotomy/afraid.png` | 1448×1086 / 无 | `975b925b3a2879f54a1bcbd741644d61a448a3142fa25bf5dd897ab23e2f6ad4` |
| operating_table_lithotomy/anesthetized | `exec-ff7328eb-1fda-44f4-bd69-766103996814.png` | `assets/characters/patient_mouri_ran_v1/patient_mouri_ran/operating_table_lithotomy/anesthetized.png` | 1448×1086 / 无 | `4aaff0eb6bbb4ac9b82dc14a0ee849d06869641a83b13679b498a1445ddf519c` |
| intraoperative/tense | `exec-ee6161fd-5036-4aa5-9775-4f5ad3cc4e71.png` | `assets/characters/intraoperative_portraits_v1/patient_mouri_ran/tense.png` | 1448×1086 / 有 | `30f7013195741f62722398c222fe0aa0a4a82628ed3b6811e83f4591935dec2a` |
| intraoperative/pain | `exec-eb2afb00-a139-4634-9e0e-1de0f7e575cf.png` | `assets/characters/intraoperative_portraits_v1/patient_mouri_ran/pain.png` | 1448×1086 / 有 | `2b51bca5e2ac677466cbeeda754f29dc9fce789c9d63de64cb7a3f9700a1d390` |
| intraoperative/near_collapse | `exec-32a37d54-264c-452f-9d84-a1c55efecf96.png` | `assets/characters/intraoperative_portraits_v1/patient_mouri_ran/near_collapse.png` | 1448×1086 / 有 | `77a0f24db4a8cb37ccba6db8cde5722f1b236bb288e1f5b25883e54250d1e01e` |
| intraoperative/anesthetized | `exec-1e26ba8f-f2c6-4835-a932-371c4bde7a26.png` | `assets/characters/intraoperative_portraits_v1/patient_mouri_ran/anesthetized.png` | 1448×1086 / 有 | `6f79145b0b0f63580e2b6e02630ed91341d8f1a0f37513eddc97ad67287dc8a7` |
| splash/general_anesthesia | `exec-256db131-50fc-463d-8809-530c00b59830.png` | `assets/events/anesthesia_v1/patient_mouri_ran/general.png` | 1672×941 / 无 | `84c179ed4e4bcadf163b603800528b65632f008483abe857db163c63c949a26e` |

检查记录：20个目标文件均存在、PNG可读，尺寸和alpha通道属性符合对应资源类别；差分输出逐张核对并通过。Godot命令行不可用，因此本次未能执行Godot纹理导入及 `tools/portrait_test.gd` 引擎/UI smoke test；其余患者数据和引用测试已运行。可在项目打开Godot后补跑引擎级检查。
