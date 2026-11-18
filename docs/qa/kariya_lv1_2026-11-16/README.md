# 狩谷惠 Lv1《昨天卖肉的姑娘》实装验收

日期：2026-11-16。事件 ID：`kariya_lv1_butcher_shop_girl`。

## 交付

- 作者 V1.0 原稿原样归档 `research/source_scripts/HOSHIMI_KARIYA_MEGUMI_LV1_BUTCHER_SHOP_GIRL_V1_0.md`；运行 `data/staff/nurse_kariya_megumi/lv1_events.json`，133 节点（132 原文段／拆分页 + 1 无正文选项节点），3 条即时汇合分支。
- 中英文本同步；英文译稿 `research/translations/kariya_lv1_en.txt`。行动前缀与其后的直接对白拆成相邻页，保留所有文字和标点；明确发声的「噗——」归惠。纯角色名前缀作为姓名标签，不重复写入对白正文。逐字拼接审计覆盖全文、顺序与选项。
- 透明头像 `assets/characters/kariya_lv1_v1/makoto/{neutral,blank,panic,embarrassed}.png`（1448×1086），惠补充表情 `assets/characters/kariya_lv1_v1/megumi/{surprised,flustered}.png`（1024×1536）；全部 RGBA、顶角透明、mipmap 开启。内置 image_gen 生成，本地 BiRefNet 透明化；prompt、原图及 SHA 位于 `research/generated_candidates/kariya_lv1_makoto_v1/`。
- 双人 CG `assets/events/kariya_lv1_v1/butcher_misunderstanding.png`，对应 km1_048–052，并作画廊封面；最终版担架铺白床单。黑底短闪回复用 narrative_black，不新增肉店地图。
- 正式病房入口：已相识并完成 Lv0，熟悉度至少 10，游戏年度 6/1–11/30 普通周一至周五（排除节假日），09:00–11:59。保留原有 3 天里程碑冷却规则，不额外对 Lv0 添加冷却。正文 8:45 是场景时刻，不倒拨运行时钟；事件耗时 30 分钟，完成一次结算。
- 结尾关系 0→1，三选项零额外数值／flag；无弘子关系门槛或奖励，无普通手术队列或手术数值奖励。真琴作为 22 岁剧情配角记录于导入清单，不进入随机患者池。惠的器械资格台词原样保留，组队岗位不改。
- 萌惠旧肉店 Lv2 文档增加历史归属提示，原草稿不删除，替代剧本仍待作者。

## 实际验证

- `python3 tools/kariya_lv1_source_audit.py`：全文／选项逐字、顺序、133 节点、三条闭合分支、资源路径、零选项奖励 PASS。
- `.venv/bin/python` + `Draft202012Validator`：目标 `character_event` Schema PASS（明确补齐 auto_start 字段）。
- `python3 tools/narrative_localization_test.py`：52642 checks，0 failures。
- `python3 tools/localization_audit.py`：85682 translations；61006/61006 authored fields；841/841 UI keys；0 Chinese hard-code candidates；PASS。
- `python3 tools/staff_localization_test.py`：1209 isolated staff dialogue lines translated，PASS。
- Godot `--headless --path . --log-file /private/tmp/kariya-test-final.log --script res://tools/kariya_lv1_test.gd`：3610 checks，0 failures。日期／假日／熟悉度／相识门槛、三分支、无中途存档、仅完成事实恢复、30 分钟耗时稳定、不重复奖励通过。测试未写玩家存档；只在内存捕获与恢复安全边界事实。
- Godot `--path . --log-file /private/tmp/kariya-native-final.log --script res://tools/kariya_lv1_native_test.gd`：5448 checks，0 failures；中英各 A/B/C 全程通过真实窗口的合成 GUI 点击推进，18 张最终截图。隔离前置下点击医院导览“住院病房”进入正式调度；检查分支、分页、图片、结算、返回导览及画廊封面。人工查看中英文选项、CG、头像与透明边缘；第一轮头像被继续按钮遮挡，已缩小上移并完整复测。`initial/` 保留修订前截图。
- Godot `--headless --editor --import --quit` 已完成资源导入；沙箱外 editor_settings 保存报权限错误，随后原生实际资源加载全部成功。headless 系统证书查询有环境日志，不影响测试结果。
- `.venv/bin/python tools/validate_data.py` 全库仍因其他事件既有 Schema／重复 choice／时间窗等问题退出 1；本事件以独立 Schema 和目标引用检查通过。最终全库日志保存在 `global_validation.txt`；目标独立 Schema 通过不代表全库通过。

## 范围与限制

这是隔离业务前置下的正式入口与完整 GUI 合成点击测试，不是从新存档自然玩到六月、也不是人工鼠标通关。未测自动播放／键盘推进，未重打 Windows 包。没有改写作者剧情、角色岗位或玩家存档格式；没有 commit/push。
