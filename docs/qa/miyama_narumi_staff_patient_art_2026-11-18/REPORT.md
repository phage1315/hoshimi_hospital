# 深山佳织／神宫寺成美 staff-as-patient 美术接入验收

日期：2026-11-18

## 接入范围

- `doc_rei`：23 张，运行目录 `assets/characters/miyama_staff_patient_v1/doc_rei/`
- `doc_aoi`：23 张，运行目录 `assets/characters/narumi_staff_patient_v1/doc_aoi/`
- 每人包含病房 6、术中头像 4、普通手术台 4、截石位 4、全麻过场 1、高级手术体位 4。
- 已登记角色画像键、角色素材清单和高级手术体位表；成美的替换前开胸 SFW 参考保留于 `assets/references/advanced_staff_patient_sfw_v1/doc_aoi/chest.png`。
- 本批次未新增患者档案、对白或解锁数据；两人的生产患者资格继续锁定。

## 实际验证

- 46/46 PNG 可由 Pillow 完整解码；两组运行文件与各自 `prepared/` 候选逐字节一致。
- 两组各 23 张；各有 11 张 RGBA。两人的 12 张病房立绘 `.png.import` 已启用 mipmap。
- Godot 4.5.1 `--editor --import --quit`：退出码 0；46 张新图和成美 SFW 参考均已生成导入资源。日志：`/private/tmp/rei-aoi-import-20261118.log`、`/private/tmp/rei-aoi-mipmap-import-20261118.log`。
- `patient_sfw_asset_test.gd -- --kind staff --id doc_rei`：23 required，0 missing，退出码 0。
- `patient_sfw_asset_test.gd -- --kind staff --id doc_aoi`：23 required，0 missing，退出码 0。
- `staff_patient_lv5_readiness_test.gd`：1420 checks，0 failures；报告确认 `doc_rei` 与 `doc_aoi` 均因缺少 `staff_patient_profile` 而保持未开放。深山另缺作者侧 `h_neutral`，未以替代素材填补。
- `advanced_staff_patient_test.gd`：2467 checks，0 failures。

## 已知的全仓既有问题

- `.venv/bin/python tools/validate_data.py` 仍被工作区现有剧情 schema／重复 choice 等大量错误阻断；输出未指向本次两位角色的图片映射。
- `python3 tools/advanced_staff_patient_source_audit.py` 仍在既有 `author_en.md` 公共对白精确匹配处失败，与本次图片导入无关。
- Godot 在本机仍报告系统 CA 与外部 `editor_settings-4.5.tres` 无法保存提示，但本次导入和目标测试均正常退出。
- 未执行原生窗口人工显示验收；由于两人尚无患者档案，正式入口仍不可进入。
