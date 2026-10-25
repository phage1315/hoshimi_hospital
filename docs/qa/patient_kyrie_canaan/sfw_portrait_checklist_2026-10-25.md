# 琪里耶·卡南 SFW 立绘缺口清单（2026-10-25）

范围：补齐患者 SFW 立绘矩阵。用户已确认四张新基准图，并认可当前生成的表情差分；旧运行资源保留，新的 18 张病房/手术台/截石位/术中立绘以 v2 单独接入。

身份参考：`research/character_references/patient_kyrie_canaan/seed_2026-10-25_02.png`（角色身份/画风）；项目构图参考采用 `patient_ann` 同类立绘。病人数据为 19 岁；本批严格 SFW。

## 覆盖依据

- 仰卧手术台：琪里耶 fallback 手术 `surgery_appendix` 的 `positioning.primary_position` 为 `supine`，且 `preop_view.gd` 对所有手术使用仰卧手术台默认图。
- 截石位：`preop_view.gd:operating_table_outfit()` 对 `primary_position == lithotomy` 选择 `operating_table_lithotomy/*`；`app.gd` 也有截石位患者预览入口。按用户明确要求纳入，不依赖阑尾手术本身为截石位。
- 病房与术中：患者流程/预览可达；按普通患者矩阵保留全部表情键。
- 全麻 splash 为可选全屏 CG，不属于本次 SFW 立绘缺口；`examination/shy` 是单独供应的肖像，本次不重做。

## 逐键清单

| Runtime key | 状态 | 规格 / 当前检查 |
|---|---|---|
| `outpatient/neutral` | 保留 | 已接入；本轮不改动。 |
| `ward/neutral` | 已接入 | 1024×1536 RGBA；站姿、蓝色系带病号服及透明背景符合矩阵。 |
| `ward/smile` | 已接入 | neutral 构图锁定；温和微笑。 |
| `ward/brave` | 已接入 | neutral 构图锁定；坚定、努力镇定。 |
| `ward/worried` | 已接入 | neutral 构图锁定；担忧。 |
| `ward/afraid` | 已接入 | neutral 构图锁定；明显恐惧。 |
| `ward/crying` | 已接入 | neutral 构图锁定；明显泪水/哭泣。 |
| `operating_table/awake` | 已接入 | 1448×1086 RGB；全台俯视、脚趾完整可见、手术帽及不透明手术单。 |
| `operating_table/tense` | 已接入 | 仰卧基准构图；清醒紧张。 |
| `operating_table/afraid` | 已接入 | 仰卧基准构图；清醒恐惧。 |
| `operating_table/anesthetized` | 已接入 | 仰卧基准构图；闭眼放松，无面罩。 |
| `operating_table_lithotomy/awake` | 已接入 | 1448×1086 RGB；完整台面、截石位腿托与肢体、遮盖单；全不透明源转 RGB。 |
| `operating_table_lithotomy/tense` | 已接入 | 截石位构图锁定；清醒紧张。 |
| `operating_table_lithotomy/afraid` | 已接入 | 截石位构图锁定；清醒恐惧。 |
| `operating_table_lithotomy/anesthetized` | 已接入 | 截石位构图锁定；闭眼放松，无面罩。 |
| `intraoperative/tense` | 已接入 | 1448×1086 RGBA；透明底头肩像、一次性帽、露肩/锁骨。 |
| `intraoperative/pain` | 已接入 | 锁定术中构图；清楚疼痛表情，无伤口/血液。 |
| `intraoperative/near_collapse` | 已接入 | 锁定术中构图；疲惫、接近极限但仍清醒。 |
| `intraoperative/anesthetized` | 已接入 | 锁定术中构图；闭眼放松，无面罩/气管管路。 |
| `examination/shy` | 单独供应，保留 | 不属于本轮生成矩阵。 |
| `splash/general_anesthesia` | 可选，不计缺口 | 全屏 CG，不属于必需 SFW 立绘矩阵。 |

## 当前基准预览与技术证据

基准图和差分已逐张检查；最终运行文件证据如下（SHA-256 对应接入的 PNG）：

| Key | 尺寸/模式 | SHA-256 | QA |
|---|---|---|---|---|
| `ward/neutral` | 1024×1536 RGBA | `500194a4a274c371208a66b010787f8cf5e52cd659b6f592195bb48569aaf5ca` | 透明；角点 alpha 0。 |
| `ward/smile` | 1024×1536 RGBA | `a31ba170f1512eb60157b6507865013ef1f8d687d79a51a01d428be3835f68af` | 透明；表达温和微笑。 |
| `ward/brave` | 1024×1536 RGBA | `9114b3dae4a8a662c817a5ea0f1cc8d3fc7451bc7dbf08c208883dc02f25d976` | 透明；坚定表情。 |
| `ward/worried` | 1024×1536 RGBA | `47a846621c944c4aea4a9b7fa751e0c518e49da6035ac290e186fa69ac328435` | 透明；担忧表情。 |
| `ward/afraid` | 1024×1536 RGBA | `1a6e31313a06d73119d96ef60c760c60328b9cafa42fd39ebf5a110ea4d4fae8` | 透明；恐惧与担忧可区分。 |
| `ward/crying` | 1024×1536 RGBA | `a0944b268bdc2fcc5004ccd8e24fa14f90d71bcaab36556930ac3ed140591f5a` | 透明；可见泪水。 |
| `operating_table/awake` | 1448×1086 RGB | `74a2ce939e1658ac30a1609c7246fec5603ebf16f2801775eb5ed27e370127e0` | 全台及脚部完整。 |
| `operating_table/tense` | 1448×1086 RGB | `5abe573a47208029909c4b05ded101e0a34c8e3a92e4d4498fcec222e42fe0f4` | 清醒紧张。 |
| `operating_table/afraid` | 1448×1086 RGB | `d504b3eb478f6a2689af4d0dee91f7b7024161b8df4add08b510e1eb3ee494c5` | 清醒恐惧。 |
| `operating_table/anesthetized` | 1448×1086 RGB | `52595abb61545f465dd61a81f4a3335bdd7600809038c4259f5bb6adb53a48b1` | 闭眼、无面罩。 |
| `operating_table_lithotomy/awake` | 1448×1086 RGB | `d500d48ee581d9e60fa278ca408607461c658b2e8d5ba4bea3514fc8b746168e` | 截石位/腿托及完整台面。 |
| `operating_table_lithotomy/tense` | 1448×1086 RGB | `ff593b4aa86c118daccf4ca2bdb6c26ccbcfed9be4193103456271970b326aa5` | 清醒紧张。 |
| `operating_table_lithotomy/afraid` | 1448×1086 RGB | `748570dfd3ed498e500d24edeb16ac4b72f79c0639668ed6096b788538e2a2bc` | 清醒恐惧。 |
| `operating_table_lithotomy/anesthetized` | 1448×1086 RGB | `7364d841d80b015170eccd5546a8cdd650cb6f4f3023d182e67ed98cbf3e871d` | 闭眼、无面罩。 |
| `intraoperative/tense` | 1448×1086 RGBA | `024d541028b1efcecfd7e4a1c1bbea6bceed01ff98652f671cf94f80e256c056` | 真透明；浅色底复核。 |
| `intraoperative/pain` | 1448×1086 RGBA | `722df1b5b1d7ac95ce3d7ec4265b7feed9914eb8c39a47782717a4911607909c` | 真透明；无伤口/血液。 |
| `intraoperative/near_collapse` | 1448×1086 RGBA | `c5d877cf3a5e8433fcd41084da2543f96215a1b1c5a4724debd8ca9be42e64d5` | 真透明；疲惫仍清醒。 |
| `intraoperative/anesthetized` | 1448×1086 RGBA | `adeaef435fa2d427c1eefd29c7d73f0433ee5267d0c5eb3813a9eecfa2c1aed5` | 真透明；闭眼、无设备。 |

## 接入与验证

- 资源目录：`assets/characters/patient_kyrie_canaan_v2/patient_kyrie_canaan/`；旧 v1 文件未覆盖或删除。
- `patient.json` 的 18 个病房/仰卧/截石位/术中键均指向 v2；门诊、检查与 splash 映射保持原样。
- `python3 tools/patient_data_import_test.py patient_kyrie_canaan`：通过，患者 bundle 唯一且 encounter/preop 解析成功。
- `python3 tools/validate_data.py`：通过，922 records/schema/reference checks。
- Godot CLI 未安装在当前环境；纹理导入与 `tools/portrait_test.gd` 运行时测试尚未执行。

用户确认四张基准后，才生成其余 14 个依赖表情；通过逐张 T3 检查后再复制到版本化运行资源并更新 `patient.visuals.portraits` 映射。最后运行资源导入及 `tools/portrait_test.gd`；不以 JSON/路径测试替代视觉验收。
