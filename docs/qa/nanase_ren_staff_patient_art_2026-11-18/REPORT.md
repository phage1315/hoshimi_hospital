# 七瀬恋 staff-as-patient 美术接入验收

日期：2026-11-18  
角色：`nurse_haru`（七瀬恋）

## 接入范围

- 正式运行资源：`assets/characters/nanase_ren_staff_patient_v1/nurse_haru/`
- 标准23槽：病房6、术中头像4、普通手术台4、截石位4、全麻过场1、高级体位4。
- 高级开胸运行图采用用户指定附件；替换前SFW参考保留为 `assets/references/advanced_staff_patient_sfw_v1/nurse_haru/chest.png`。
- 修改 `data/staff/nurse_haru/profile.json`、`assets_manifest.json` 与 `data/advanced_surgery/staff_patient/assets.json`。
- 仅接入美术；未新增患者档案、对白、剧情或解锁资格。

## 验证结果

- 23份运行PNG与 `prepared/nurse_haru/` 逐字节一致；尺寸、模式与SHA-256均与 `prepared_manifest.json` 一致。
- Godot 4.5.1两轮 `--editor --import --quit` 均退出0；第二轮重新导入6张已开启mipmap的病房立绘。
- `patient_sfw_asset_test.gd -- --kind staff --id nurse_haru`：23 required / 0 missing。
- `staff_patient_lv5_readiness_test.gd`：1420 checks / 0 failures / 4 registered / 24 preloaded；`nurse_haru`仍缺 `staff_patient_profile` 与 `portrait:h_neutral`，未开放生产入口。
- `advanced_staff_patient_test.gd`：2471 checks / 0 failures。
- `narrative_localization_test.py`：57229 checks / 0 failures。
- `localization_audit.py`：93500 translations，全覆盖。
- `validate_data.py` 输出中过滤 `nurse_haru|七瀬|nanase_ren_staff_patient`：0条相关错误。

## 已知非本次问题

- `advanced_staff_patient_source_audit.py` 仍在既有 `Common exact author_en.md` 断言失败；本次未修改任何高级患者对白或作者稿。
- Godot日志仍含macOS系统CA证书读取提示及外部运行时 `editor_settings` 无法保存提示；资源导入和专项测试均正常退出。
- 尚未进行原生窗口患者流程显示验收；由于患者档案尚未提供，生产患者入口保持锁定。
