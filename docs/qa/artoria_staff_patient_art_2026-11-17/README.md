# Saber 患者美术接入 — 2026-11-17

用户明确限定仅接入美术；患者对白和档案由用户稍后处理。

## 接入
- profile.json 注册19个患者portrait键及五个outfit组；高级assets.json登记四体位，含用户原样胸部图。
- assets_manifest.json追加23项；runtime_manifest.json更新映射状态。SFW胸部参考复制到assets/references/advanced_staff_patient_sfw_v1/doc_artoria/chest.png（.gdignore）。
- Free H neutral资源已存在，advanced_presentation通过现有Free H profile复用，无须重复绘制/别名。
- ward_preparation/shy尚缺，为额外作者可选素材。examination/shy不是staff-as-patient强制项。没有替换或伪造这些图片。

## 实际验证
- patient_sfw_asset_test.gd -- --kind staff --id doc_artoria：23项、0缺失、退出0。
- staff_patient_lv5_readiness_test.gd：1415项、0失败；Artoria报告仅缺staff_patient_profile。
- narrative_localization_test.py：55546项、0失败；localization_audit.py通过（91536项，UI845/845）。本轮未修改对白。
- advanced_staff_patient_source_audit.py：失败于Common exact author_en.md；本轮未改故事或译稿。
- advanced_staff_patient_test.gd：1280项、5失败，Accept valid episode: calendar；本轮未改日历或预约逻辑。此回归不能宣称通过。
- validate_data.py全库失败；日志无artoria或staff_patient/assets相关错误，其他角色hidden-portrait及time-window错误未修改。
- Godot环境有系统CA提示。未做原生患者流程测试；患者registry保持未注册，不声称已开放。
