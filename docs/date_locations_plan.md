# 约会地点场景规划与素材记录

更新：2026-10-12。已实装12处常驻＋4处季节限定约会地点；每个日期开放13处。酒店新版CG已注册为剧情专用背景，不进入普通约会池。

以下制作记录保留各批历史状态；当前接入情况以文末“接入验收”为准。

## 地点清单

| 地点 | 约会体验 | 素材 | 建议地点ID |
| --- | --- | --- | --- |
| 咖啡店 | 午后咖啡与甜点，适合轻松交谈 | 本批新绘 | `cafe` |
| 商店街 | 逛店与随性漫步，观察日常喜好 | 本批新绘 | `shopping_street` |
| 大型书店 | 选书与阅读，适合交流兴趣 | 本批新绘 | `bookstore` |
| 水族馆 | 蓝色水光与海洋生物，安静的新鲜体验 | 本批新绘 | `aquarium` |
| 意大利小餐馆 | 正式晚餐与温暖交谈 | 复用现有 | `restaurant_bar` |
| 河边公园 | 熟悉的河岸散步，适合自然相处 | 复用现有 | `riverside_park` |
| 美术馆 | 看展与审美交流，克制典雅 | 本批新绘 | `art_gallery` |
| 植物园温室 | 绿植、水景与阳光，舒缓放松 | 本批新绘 | `botanical_garden` |
| 电影院休息厅 | 映前休息、映后讨论，轻松共享体验 | 本批新绘 | `cinema` |
| 天文馆 | 星空与科学话题，安静浪漫 | 本批新绘 | `planetarium` |
| 爵士音乐酒吧 | 音乐、夜景与小酌，也可选择无酒精饮品 | 本批新绘 | `jazz_bar` |
| 海滨步道 | 落日、海风与散步，开阔浪漫 | 本批新绘 | `seaside_promenade` |

## 素材与状态

- 新CG由内置ImageGen生成，以既有意大利小餐馆背景作为画风参考，保存于 `assets/backgrounds/date_locations_v1/`。保留生成原文件，无裁切或二次压缩。
- 无前景人物、横向构图、不透明背景；画面右侧和下部为后续立绘与对话框预留空间。具体遮挡效果仍须接入后检查。
- 两处复用背景：`assets/backgrounds/v9/italian_trattoria.png` 与 `assets/backgrounds/v12/minato_riverside_walk.png`。
- [全部12处预览](date_locations_gallery.html)。逐图来源、完整提示词、尺寸和SHA-256见 [素材记录](../research/imports/date_locations_v1_2026-10-12.json)。
- 已检查12张PNG可读、均不透明；10张新图逐张检查构图并确认复制文件与生成源一致。
- 本批完成规划与CG制作，尚未将新图注册为游戏可选地点；现有地点配置与约会逻辑保持原状。未做游戏内立绘叠加测试。

## 下一步

- [x] 规划12个普通约会地点。
- [x] 复用2张、生成10张背景CG并记录来源。
- [ ] 用户审阅新CG，按反馈修订。
- [ ] 讨论各角色对地点的喜欢、普通、不喜欢及理由；本批未赋予角色任何好恶。
- [ ] 确定地点开放规则及交互内容后，接入背景展示、季节常服和中英文界面并验证。
- [x] 补绘酒店夜间客房CG：`assets/backgrounds/date_locations_v1/hotel_room_night.png`，作为第13张特殊场景背景，不计入12处普通地点。
- [ ] 酒店待审阅与独立剧情配置，不加入普通约会随机地点池。

场景描述仅用于美术与玩法规划，不作为新增剧情台词。

## 酒店背景补充（2026-10-12）

此前未找到酒店素材，现已用内置ImageGen参考本批咖啡店画风补绘夜间客房：双人床、暖光与城市夜景，无人物。PNG可读、不透明，原样复制且SHA-256一致。素材与提示词见`research/imports/hotel_date_background_2026-10-12.json`。尚未修改游戏地点注册、开放条件或剧情。

### 酒店修改稿 v2

按用户反馈调整为适合年轻成年情侣初次共度夜晚的日式精品love hotel：玫瑰色间接灯光、弧形软包床头、纱帘与双人沙发。修改稿保存于`assets/backgrounds/date_locations_v1/hotel_room_night_v2.png`，旧版保留，待用户审阅，未接入游戏。PNG可读、不透明，复制哈希一致。提示词及来源见`research/imports/hotel_date_background_v2_2026-10-12.json`。

## 四季限定约会背景（2026-10-12）

增加4处季节限定地点，现规划为12处常驻＋4处季节限定＋1处剧情专用酒店。月份为已确认的设计约定，尚未接入游戏筛选逻辑。

| 地点 | 开放月份 | CG路径 |
| --- | --- | --- |
| 赏樱日式庭院 | 3/4/5 | `assets/backgrounds/date_locations_v1/spring_sakura_garden.png` |
| 夏日沙滩 | 6/7/8 | `assets/backgrounds/date_locations_v1/summer_beach.png` |
| 红叶古寺 | 9/10/11 | `assets/backgrounds/date_locations_v1/autumn_maple_temple.png` |
| 冬日滑雪场 | 12/1/2 | `assets/backgrounds/date_locations_v1/winter_ski_resort.png` |

冬季选择木屋外观景露台，可搭配现有冬装。

- [x] 四张CG由内置ImageGen生成，逐张检查构图，PNG可读、不透明、源文件哈希一致。
- [x] 来源、尺寸与完整提示词保存于`research/imports/seasonal_date_backgrounds_2026-10-12.json`。
- [x] 用户授权四季CG导入。
- [x] 接入季节筛选、背景显示和中英文界面，验证跨年冬季条件。

本批未修改角色好恶、剧情、奖励或触发条件。

## 接入验收（2026-10-12）

- [x] 17处地点均有正式背景引用：12常驻、4季节限定、1酒店；旧酒店v1保留作历史稿，实际注册v2。
- [x] 四季通过`available_months`配置：春3/4/5，夏6/7/8，秋9/10/11，冬12/1/2。无月份限制的常驻地点全年开放。
- [x] 酒店`story_only: true`，使用背景ID `date_hotel`；未新增酒店剧情或开放条件。
- [x] 菜单两列展示当日13处地点，鼠标悬停或键盘焦点切换CG预览；隐藏非当季地点，直接调用入口也会拦截。
- [x] 普通约会展示对应CG和季节常服，按“结束约会”执行原有结算。既有首约剧情入口、台词、奖励、邀请条件保持不变。
- [x] `tools/seasonal_date_locations_test.gd`：中英文各覆盖全年365天，5510项通过；原生渲染同样通过，保存10张菜单及四季场景截图。
- [x] `tools/sunday_system_test.gd`：17项通过。测试夹具临时移除自动特殊事件，避免首周剧情代替医院地图；运行逻辑未改。
- [x] `python3 tools/validate_data.py`：689条数据通过。
- [x] `python3 tools/narrative_localization_test.py`：6901项、0失败。`python3 tools/localization_audit.py`通过，683/683 UI英文键完整；全项目仍有73处其他既有内容依赖中文回退，本批新增字段均有英文。
- [x] `git diff --check`通过。

验收资料：`docs/qa/date_locations_2026-10-12/`。本批没有新增剧情对白，场景使用既有周日约会总结原句；用户之前提供的剧情文本未改写。角色地点好恶仍待讨论。

## 地点喜好结算接入（2026-10-12）

21人各两处特别喜好已按用户批准映射接入，奖励为原有约会熟悉度×1.2并四舍五入；不喜欢暂不实现。未开放角色仅储备偏好，不改邀请池。完整表格及验收见`docs/date_location_preferences.md`。
