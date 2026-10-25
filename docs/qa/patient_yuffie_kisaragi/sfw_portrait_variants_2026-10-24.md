# 尤菲·如月 SFW 立绘差分 QA（2026-10-24）

## 范围与依据

- 用户已确认基础图无问题，并授权制作 SFW 差分；按 `skills/generate-patient-portraits/references/portrait-matrix.md` 核对当前消费者与分支。
- 术式：`case_abdomen` → `surgery_appendix`，定位 `supine`；该患者可选全麻、硬膜外、局麻及无麻醉。故纳入病房表情、仰卧手术台状态和清醒术中头像差分。
- 不生成截石位：当前患者术式使用仰卧位。未生成麻醉 splash：属可选 CG，不在本次 SFW 立绘差分范围。
- 用户提供的身份/风格种子：`research/character_references/patient_yuffie_kisaragi/` 中记录的尤菲种子图；本批编辑源为已确认的尤菲基础立绘。所有输出均为独立单图，不是拼图。
- 后续按用户反馈仅修复病房五张差分背景；采用 ImageGen 透明背景编辑输出。用户复核并确认无光晕、可直接使用；其余状态图未改动。

## 差分逐项记录

所有项目的视觉检查均为通过：保留年轻尤菲的脸部设计和原姿势/构图；只改变表情。病房保持浅蓝病号服、无发带；手术台保持手术帽、仰卧铺巾与原场景；术中头像保持手术帽、露肩锁骨和透明背景，无衣物/器械/伤口新增。

| Runtime key | 消费者 / 纳入理由 | 编辑源与表情差分 | 输出规格 / alpha 通道 | 视觉结果 |
|---|---|---|---|---|
| `ward/smile` | 病房状态选择，低焦虑表情 | `ward/neutral.png`；明朗自然的笑容，明显区别于中性 | 1024×1536 PNG RGBA，alpha 通道存在 | pass |
| `ward/brave` | 病房状态选择 | `ward/neutral.png`；坚定、努力镇定 | 1024×1536 PNG RGBA，alpha 通道存在 | pass |
| `ward/worried` | 病房状态选择 | `ward/neutral.png`；轻度忧虑，紧张眉眼 | 1024×1536 PNG RGBA，alpha 通道存在 | pass |
| `ward/afraid` | 预览/显式状态消费者 | `ward/neutral.png`；明显害怕，强于担忧但无泪 | 1024×1536 PNG RGBA，alpha 通道存在 | pass |
| `ward/crying` | 病房高焦虑状态选择 | `ward/neutral.png`；可见泪水与哭泣表情 | 1024×1536 PNG RGBA，alpha 通道存在 | pass |
| `operating_table/tense` | 手术台清醒紧张状态 | `operating_table/awake.png`；紧绷、专注 | 1448×1086 PNG RGB，无 alpha（全场景图） | pass |
| `operating_table/afraid` | 恐惧/不匹配状态 | `operating_table/awake.png`；睁大眼、明显恐惧 | 1448×1086 PNG RGB，无 alpha（全场景图） | pass |
| `operating_table/anesthetized` | 全麻状态 | `operating_table/awake.png`；闭眼、放松；无面罩/管路 | 1448×1086 PNG RGB，无 alpha（全场景图） | pass |
| `intraoperative/pain` | 无麻醉/清醒术中疼痛状态 | `intraoperative/tense.png`；明确疼痛表情，无血/伤口 | 1448×1086 PNG RGBA，alpha 通道存在 | pass |
| `intraoperative/near_collapse` | 无麻醉后段清醒术中状态 | `intraoperative/tense.png`；疲惫、意识尚清，区别于疼痛 | 1448×1086 PNG RGBA，alpha 通道存在 | pass |

输出路径均对应 `assets/characters/patient_yuffie_kisaragi_v1/patient_yuffie_kisaragi/<state>/<expression>.png`；新生成的十个 runtime key 已写入 `data/patients/patient_yuffie_kisaragi/patient.json`。静态核对 15 个已映射立绘路径均存在。

## SHA-256

```text
c6c2f8209deca1526f6d4e9ca3718f26838c8c39f3938aabc7735f6c2e7aceef  ward/smile.png
5159e89d5f1031990f1954ef339093a4ed8d35b1e713ec648fb4c68670f4f683  ward/brave.png
8e12a937bdbbc148ecc30106348add3cc1e33e1a4bccd5aee9b8b40b3f6fff19  ward/worried.png
c69f9a2ecf110001fc7a82406b755e5af5e8feb4af63f6df0cf746092421c126  ward/afraid.png
c72ed19bccc48c610f8aa2124dc9b288b7109c22af7e77abb94d5917360b51cd  ward/crying.png
84d242d9cbe66d2e7fa6f14fcd4b2ea23d4583af2c57d0fca1e62cc295be9fe3  operating_table/tense.png
bca378f65143f272bd3a3bcc9a4f1a89fe7b1076bda9cfd7526c9ccc0c85f50e  operating_table/afraid.png
57f432f35405e1ad31779215c45503452cf635afe2b6c1ddcbb0e23c9cd12934  operating_table/anesthetized.png
648218c45be1c92d9cc742de3b21716f6e18cfe24ca84d058ef536e5e218b804  intraoperative/pain.png
588e0a1fd83dea18265a8eac6b0d91a9f9cdd70343e9ebc7367d34147d0e4889  intraoperative/near_collapse.png
```

## 验证

- `python3 tools/patient_data_import_test.py patient_yuffie_kisaragi`：通过。
- `python3 tools/patient_bundle_localization_test.py`：通过，0 failures。
- `python3 tools/validate_data.py`：通过，910 records。
- 静态资源检查：15 个映射路径全部存在；PNG 尺寸、格式与 alpha 通道符合对应图类规格。
- 当前环境未发现 Godot/Godot 4 可执行文件；尚未运行 `tools/portrait_test.gd`，因此实时 UI 显示与引擎纹理加载未验证。
