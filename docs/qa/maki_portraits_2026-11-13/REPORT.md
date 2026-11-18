# 麻纪透明立绘与作者交付包验收

2026-11-13。四套基础立绘已获用户批准；内置image_gen生成10张完整表情差分，随后本地BiRefNet-ToonOut抠图。

- 14张立绘：casual 3、interview 4、white_coat 4、sterile 3。1024×1536 RGBA，透明角检查14/14通过，输出SHA-256见matting_results.json。
- 已检查整套contact_sheet.jpg，以及白大褂／手术服基础、常服focused、面试focused、手术服worried的深浅背景与边缘放大QA。没有发现明显残留背景或主体缺失。生成差分有轻微像素漂移，未做原生切换验收。
- 首次助手CG原样复制到assets/events/maki_first_assistant_v1/assistant_confirmation.png，1536×1024保留背景。
- matting命令：`.venv/bin/python tools/portrait_matting.py <raw> -o <output> --target-size 1024x1536 --resize-mode keep --qa-sheet <qa>`；14份输入输出见matting_results.json。
- Godot路径：`/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot`。执行`--headless --path . --log-file /private/tmp/maki-assets-import-{1,2}-20261113.log --editor --import --quit`两次：首次导入后为本批14张PNG开启mipmaps/generate，再重新导入；均退出0。日志import_1.txt、import_2.txt含macOS证书与沙箱外editor_settings写入错误，不能称日志全净。
- 专项加载：`--headless --path . --log-file /private/tmp/maki-assets-load-20261113.log --script res://docs/qa/maki_portraits_2026-11-13/load_assets.gd`：14张立绘＋1张CG实际Texture2D加载及尺寸检查通过、退出0；仍有宿主证书警告。未访问GameState或玩家存档。
- 作者交付schema使用Draft202012Validator.check_schema与validate检查通过，空白模板仅为draft，不是已写剧本。zip完整性检查通过；运行schema未改。第一次检查误用系统python缺PIL，后改用项目.venv完成检查。
- 未新增剧情正文或生产角色登记，故不运行剧情本地化审计。未做原生显示／实际事件／编队解锁验收，不宣称新人已可用。
