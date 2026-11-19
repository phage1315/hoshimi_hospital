# 江美子患者美术接入验收

- 19患者立绘键、5组outfits、23条素材manifest及4高级体位登记完成；胸部作者原件不改，SFW参考独立保留。
- `patient_sfw_asset_test.gd -- --kind staff --id doc_emiko`：23项、0缺失，退出0。
- `staff_patient_lv5_readiness_test.gd`：1415项、0失败，退出0；江美子missing仅staff_patient_profile，ready=false，符合仅接美术范围。
- `.venv/bin/python tools/validate_data.py`：全库存在其他内容错误（完整见validate_data.log），无doc_emiko/emiko_staff_patient相关报错；不声称全库通过。
- 数据前后比较通过：既有立绘、非visuals角色字段、旧manifest条目、其他角色高级图片映射均未变。git diff --check通过。
- Godot使用wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot，headless，独立/private/tmp日志；环境CA提示仍有。
- 未修改患者对白、staff_patient_profiles、资格、剧情或存档；未执行原生患者显示测试。没有以素材接入宣称患者开放。
