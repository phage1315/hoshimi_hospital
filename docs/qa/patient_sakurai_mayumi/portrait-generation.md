# 樱井真弓 SFW 患者立绘生成记录

## 范围与来源

- 患者：`patient_sakurai_mayumi`（27岁），现有已索引患者档案；只变更肖像资源和肖像映射。
- 使用内置 ImageGen。身份/风格种子：用户提供的面部表情图、制服正反面设定图；病房拼图仅用于最初基础图参考。手术台、截石位、术中构图分别对照同类 `patient_ann` 参考图。
- 用户种子文件：`/var/folders/t6/9dg502qd74vdq35hjs973jf40000gn/T/codex-clipboard-eb982e4a-fab7-4942-8452-9d46d5c85ae0.png`（表情/身份）、`/var/folders/t6/9dg502qd74vdq35hjs973jf40000gn/T/codex-clipboard-7ba98cc0-c1e9-4e86-92ff-0e3b5783f8b5.png`（制服正反设定）。
- 同类构图参考：`assets/characters/patient_ann_v1/patient_ann/outpatient/neutral.png`、`ward/neutral.png`、`operating_table/awake.png`、`operating_table_lithotomy/awake.png`；术中参考 `assets/characters/intraoperative_portraits_v1/patient_ann/tense.png`；全麻场景参考 `assets/events/anesthesia_v1/patient_ann/general.png`。
- 用户确认基础图“基本没问题，可以差分”；后续指出 `ward/brave`、`ward/worried`、`ward/afraid`、`ward/crying` 带背景光晕，分别重做这四张的透明背景，保留人物、对应表情、服装与构图。
- 每个状态为单独生成的 PNG，不从其他表情复制或裁剪。一次病房批次因输出审查失败未被计入；随后移除拼图参考并调整为明确全着装的病房肖像，成功生成并纳入下列资产。
- 变体共用提示要点：锁定同类基础图的人物身份、姿势、服装、构图、尺度与背景，只改变该状态对应的面部表情/眼神；手术台服装保持遮盖；不加文字、血迹或伤口。各状态差异按 `skills/generate-patient-portraits/references/portrait-matrix.md` 定义。

## 运行时映射与 T3 记录

所有文件均为 PNG，已逐张查看生成结果并核对路径、PNG 尺寸、颜色类型和 SHA-256。透明图像的 alpha 统计来自 PNG 解码；病房差分预览也分别与浅色和深色底色合成检查。RGBA 的 alpha 存在，但部分输出把柔和渐变作为半透明背景绘入；按用户对基础图的确认保留原样。

| 运行时键 | 项目文件 | 尺寸 / 模式 | Alpha（零 / 部分 / 全不透明像素数） | SHA-256 |
|---|---|---:|---:|---|
| `outpatient/neutral` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/outpatient/neutral.png` | 1024×1536 RGBA | 832220 / 740644 / 0 | `8117bd5ed9011c45fa1cd5e097506784b4663a374b3c866d526a1b2eeb793846` |
| `ward/neutral` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/ward/neutral.png` | 1024×1536 RGBA | 731940 / 840924 / 0 | `712910d2cc40b260a56fb20248221e0fbcfc63d38c8d659b3814e765657f39ba` |
| `ward/smile` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/ward/smile.png` | 1024×1536 RGBA | 734008 / 838856 / 0 | `ba2800442ec6fe7523ae859086a315a5b58daaecb6488395f17fb6150e66e82d` |
| `ward/brave` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/ward/brave.png` | 1024×1536 RGBA | 735417 / 837447 / 0 | `30874ffc7cd8820233888e3b5bab0778fc823b6490a78d680aa390c21ed2387d` |
| `ward/worried` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/ward/worried.png` | 1024×1536 RGBA | 727032 / 845832 / 0 | `713dd6962f986317a1fe509104b8686e90a739f3cc6c7658b7dfb0049a4b05bd` |
| `ward/afraid` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/ward/afraid.png` | 1024×1536 RGBA | 734404 / 838460 / 0 | `8f718c7c8773654ac04bd78193e5b2747d32ca5cc3921cea39cde63785cc7dc2` |
| `ward/crying` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/ward/crying.png` | 1024×1536 RGBA | 734383 / 838481 / 0 | `a3f8aaebf2f3947ee32b7b0b6703e5c5bc2e2ab4e723f231e943f5328c31803f` |
| `operating_table/awake` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/operating_table/awake.png` | 1448×1086 RGB | 不适用 | `c45df6c97b207b3b49708abd05c14344c6a2661d070a48c9b216b2e8c1067997` |
| `operating_table/tense` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/operating_table/tense.png` | 1448×1086 RGB | 不适用 | `7efd5c63f2c582415e4ee39bfa25f0d42858de7134794383a375576ac3c62487` |
| `operating_table/afraid` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/operating_table/afraid.png` | 1448×1086 RGB | 不适用 | `35b66eedaa3df857e8f8dd0082e51c8f79c7476b09dd91be0882932146cef7f7` |
| `operating_table/anesthetized` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/operating_table/anesthetized.png` | 1448×1086 RGB | 不适用 | `ef775d93e4e934f7e52dfaeb7e9600b044ab9fe8ab2d0c29759e89f7ea286199` |
| `operating_table_lithotomy/awake` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/operating_table_lithotomy/awake.png` | 1448×1086 RGB | 不适用 | `b938e3c50361c272bf4ec7df6d7367a60b08a1cccdc02a0d013c7b76e9f30869` |
| `operating_table_lithotomy/tense` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/operating_table_lithotomy/tense.png` | 1448×1086 RGB | 不适用 | `10a70b38260d39f7d15448245a9ee856e62a5ad6e3592ab1576cb433c08d0f0e` |
| `operating_table_lithotomy/afraid` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/operating_table_lithotomy/afraid.png` | 1448×1086 RGB | 不适用 | `5f795b8031a43c076194090484cd0621e0a419d867edae6ca0be920d24fa9d81` |
| `operating_table_lithotomy/anesthetized` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/operating_table_lithotomy/anesthetized.png` | 1448×1086 RGB | 不适用 | `8046cbdd66387bc8dd39f779dbb8fb3c9f6ec5997609cfbafc58d30696e32e88` |
| `intraoperative/tense` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/intraoperative/tense.png` | 1448×1086 RGBA | 855996 / 715656 / 876 | `bd92d9c62bd72410f53ec740e8e30354f6815c516fc9b22c9573952f324fb565` |
| `intraoperative/pain` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/intraoperative/pain.png` | 1448×1086 RGBA | 857269 / 713827 / 1432 | `362b00852747854c5b81d3b4a7c42f57ce761412f6134e8802c1858cf6afa333` |
| `intraoperative/near_collapse` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/intraoperative/near_collapse.png` | 1448×1086 RGBA | 856382 / 714990 / 1156 | `045aa7772e5309b3c93592fd19edea3495bd92bca2fc8976f6ef7376d1789443` |
| `intraoperative/anesthetized` | `assets/characters/patient_sakurai_mayumi_v1/patient_sakurai_mayumi/intraoperative/anesthetized.png` | 1448×1086 RGBA | 855189 / 716341 / 998 | `39de6ab733c13b9c7b9900035eb6f6a2f706e8c6cb568787d805bb7c67126294` |
| `splash/general_anesthesia` | `assets/events/anesthesia_v1/patient_sakurai_mayumi/general.png` | 1672×941 RGB | 不适用 | `8308fa1229b39545ccd521756f2b479de0a4dbcd3622ad6d07fca87b85860547` |

## 检查结果

- T0：`python3 tools/validate_data.py` 通过（884 records）。
- T1：`python3 tools/patient_data_import_test.py patient_sakurai_mayumi` 通过；档案唯一、profile 合并并可生成对应 encounter/preop。
- T3：20 个键均已落入项目目录，映射路径存在；逐张检查身份、状态、构图和手术遮盖。四张病房情绪差分 `brave/worried/afraid/crying` 的背景已重做为透明，浅/深底色合成都已复核；相关 alpha 统计与 SHA-256 如上。
- T4 / Godot 纹理导入与 `tools/portrait_test.gd`：当前环境没有 `godot`/`godot4` 可执行文件，运行时 UI 显示检查未执行。
- 只生成参考矩阵中已确认可达的 20 个 SFW 立绘键；未生成可选全屏 CG，也未改动患者对白或其他数据。
