# 诗织 Lv3 下篇 CG 接入验收（2026-11-12）

用户确认三张图接入。仅改演出与画廊映射，原稿、对白、说话人、选项、顺序、数值和存档契约不变。

## 映射

- slv3b_060–061：dinner_toast_pov_v2.png，主角主观视角晚餐举杯。
- slv3b_169–172：apartment_hesitant.png，握钥匙与欲言又止。
- slv3b_173–177：apartment_goodnight.png，晚安微笑；兼作下篇画廊封面。
- 062、178 恢复原演出。使用既有 cover 适配和首次 CG 切入 1 秒纯图机制。
- 三张源文件原样复制，1536×1024 RGB，Godot 无损导入。SHA256 见 research/imports/shiori_lv3_part_b_cg_2026-11-12.json。
- 导入器同步登记映射，但没有重跑整份导入器覆盖数据；仅定点修改已加载 JSON。已检查幂等性。

## 本轮实际验证

Godot 路径：/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot。

- python3 tools/shiori_lv3_source_audit.py：PASS，206+178 节点，原文 0 diffs，13/13 手术台词，双语覆盖及 CG 窗口通过。原晚安立绘由 CG 取代，保留素材，测试相应改为 41 张仍使用的立绘。
- python3 tools/narrative_localization_test.py：46247 checks，0 failures。
- python3 tools/localization_audit.py：退出 1；叙事 54592/54592、UI 801/801 覆盖通过，阻断为既有 voice_director.gd 5 行中文硬编码，未修改该文件。
- Godot --headless --path . --log-file /private/tmp/shiori-b-cg-import-20261112.log --editor --import --quit：退出 0，三张纹理导入；环境 CA 证书和编辑器设置目录写入警告见 import.log。
- Godot --headless --path . --log-file /private/tmp/shiori-b-cg-regression-20261112.log --script res://tools/shiori_lv3_test.gd：11371 checks，0 failures。含双语全分支、术中、关系结算、回想及存档边界；退出有 ObjectDB leak 警告，见 regression.log。
- Godot --path . --log-file /private/tmp/shiori-b-cg-native-run2-20261112.log --script res://tools/shiori_lv3_part_b_cg_preview.gd：原生 macOS/OpenGL，112 checks，0 failures，16 张截图于 run2/。中英文隔离内存定点进入 060 与 169，随后真实按钮中心合成鼠标输入推进 CG 窗口，验证首次隐藏/恢复对白、窗口结束清除 CG。抽看中文举杯对白、中文犹豫纯图和英文晚安对白截图。
- git diff --check：本次相关文本通过。

## 限制与调试记录

- 原生测试为定点窗口检查和合成 GUI 输入，不是全流程人工点击；未做导出包验证。
- 未读取或写入玩家槽位；app.saves.path 在挂入场景前设为 /private/tmp/ 独立路径，夹具仅驻内存。
- 沙箱原生启动首次退出 134；经执行权限审核启动成功。首轮鼠标坐标未指定 viewport-local，导致 8 个推进断言失败；修正 root.push_input(..., true) 后 run2 全部通过，首轮日志截图保留。
