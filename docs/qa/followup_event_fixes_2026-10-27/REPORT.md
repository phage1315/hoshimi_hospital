# 千束开场、武见立绘与芹香入口核查

2026-10-27；main/f95636a 加已有工作区。用户授权修复千束开场英文；芹香 Lv3 选择“保留瑞穗完整链条件，仅打开入口配置”。武见与深山本轮为核查说明，不改素材、剧情或布局。未提交、推送或访问玩家槽位。

## 已修改与验证

- 千束 `advanced_referral_tutorial_chisato_day1/opening`：只替换 en.json 对应正文键，按现行中文恢复“上午九点、坂口推门、桌上资料及封面”。中文、说话人、顺序和其他节点未改。本轮键级前后文本见 english_opening_change.json。
- 原生中文/英文 × 正文/回想共四组，每组四页，全部 GUI 推进到 asuka_people_arrived；排版空白以外无缺字。记录 opening_results.json，逐页截图 opening_*.png。
- `godot/systems/serika_lv3.gd` 的 PREREQUISITES_CONNECTED 改为 true。仍要求真实 Lv2 里程碑、mizuho_first_surgery_chain_complete、周日未使用、等级2、熟悉度40、冷却及空闲状态。没有新增写入瑞穗完成事实的生产路径，没有绕过剧情前置。
- 千早第三次手术 B 实现 Lv2；C 接续整链结尾及瑞穗预约。目前没有生产事件写入瑞穗首次手术完整链的完成 flag，所以当前正常游玩仍不能触发 Lv3。这符合用户本轮明确选择。
- 测试改用现有千早 A/B/C 的事件级完成事实，不再把 Lv2 rank slot 替换为虚构事件。正向入口测试仅在隔离内存模拟未来瑞穗完整链已完成，不能作为现在可自然抵达的证明。
- 原生 Lv3：12756 检查、0失败，415页正文、830页姓名/立绘核对（含回想），鼠标147次、回车551次、空格138次、自动播放2次。实际菜单在缺少瑞穗事实时不显示入口；正向条件下通过菜单按钮进入。证据 serika_native/results.json、serika_native/*.png、serika_native.log。
- Lv3 补充逻辑检查7551项、0失败；原稿审计208条原稿/207 VN节点及菜单通过。narrative_localization_test.py 为18431项、0失败；localization_audit.py 已执行。未由此宣称千束全文英文已逐句终审。

## 阿尔托莉雅在千束事件中的出场

现行数据共有11个 doc_artoria 角色节点：第一天4、第二天5、第三天2。第一天复核人员、备用资源、中止条件及完整站位演练；第二天负责室内资源和备用支援；第三天复盘团队配置。

节点：artoria_sets_scope、artoria_team_reply、artoria_requires_full_dry_run、artoria_position_reply；artoria_room_ready、artoria_releases_field、artoria_holds_reserve、artoria_not_talking_to_mido、observer_artoria；artoria_debrief_team、artoria_debrief_reply。

三个阶段的代表节点均在中英文原生窗口复查，立绘成功加载；中文第一天路径为 assets/characters/portrait_pack_v16/doc_artoria/white_coat/neutral.png。证据 display_observations.json 与 *artoria*.png。这是原有出场，没有新增剧情。

## 武见 T6 末段立绘

实机确认 t6_60 的 EventCast_doc_takemi 使用 assets/characters/takemi_tae_v1/white_coat/neutral.png，1280×800逻辑画布上位置(490,145)、框300×400。普通单人事件布局为450×500。原因是 T6 的 cast_actor_ids 虽只有一个人，也走统一多人布局；正文固定300×400、回想固定170×300。

t6_14、t6_60 中英文截图与精确控件记录已保存。不是错图或缩略图加载。t6_15 自报姓名时另用 first_meeting.png 的 inset CG，正文580×326；此处应与普通立绘区分。

建议只对武见 T6 的单人立绘布局设置合适的尺寸和位置；涉及视觉调整，按用户本轮“请看一下”先提供证据，尚未修改。没有移动、裁切或重绘素材。

## 深山 Lv1 的触诊占位

详见 [触诊占位解释](MIYAMA_LV1_PALPATION.md)。现有公共触诊/麻醉感觉测试已实现；事件内仍是固定说明和一键跳过。完成 flag 尚无功能入口读取。这三层现状需要分别理解。
