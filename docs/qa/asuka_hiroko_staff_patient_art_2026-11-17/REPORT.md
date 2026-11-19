# 明日香／弘子 Staff-as-Patient 美术数据接入

日期：2026-11-17

## 接入范围

- doc_asuka 与 nurse_hiroko 各23项标准患者美术。
- 两人的角色 profile.json 增加19项普通患者图键及5种患者图集类别。
- 两人的 assets_manifest.json 各登记23项运行素材。
- data/advanced_surgery/staff_patient/assets.json 各登记4种高级体位。
- 作者胸图保留独立SFW参考图；弘子6张病房立绘启用mipmap。
- 未新增 staff_patient_profiles.json 条目，未改对白、资格、解锁或玩家存档。

## 实际验证

- 导入器：tools/import_asuka_hiroko_staff_patient_art.py，两人均23/23。
- PNG与映射静态核对：两人各23 PNG解码、19普通图键、23清单条目、4高级体位通过。
- Godot资源导入：弘子23项及两张SFW参考图完成导入；6张病房图重导入后 mipmaps/generate=true。
- patient_sfw_asset_test.gd -- --kind staff --id doc_asuka：23项，0缺失。
- patient_sfw_asset_test.gd -- --kind staff --id nurse_hiroko：23项，0缺失。
- staff_patient_lv5_readiness_test.gd：1,420项，0失败；两人仍明确缺 staff_patient_profile 与作者项 h_neutral。
- advanced_staff_patient_test.gd：2,459项，0失败。
- narrative_localization_test.py：55,546项，0失败。
- localization_audit.py：91,536项，通过。
- validate_data.py：全库因既有剧情数据问题退出1；日志中无 doc_asuka、nurse_hiroko 或两套新患者素材路径的诊断。
- advanced_staff_patient_source_audit.py：既有 author_en.md common exact mismatch，退出1；本次未修改高级手术对白。

## 当前边界

美术数据已接入并可加载，但两人没有作者提供的双语患者档案及 h_neutral，因此仍未注册为可预约患者，也未进行原生完整患者流程验收。
