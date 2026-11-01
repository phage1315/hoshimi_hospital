# 高级手术显示、输入与返场结算修复（2026-10-31）

## 根因与改动

- 返场崩溃：病例板将 replays 中的 Dictionary 原对象交给 view.record；返回／取消时 record.clear() 把注册病例清成 {}，再次 board() 读取 record.id 崩溃。病例板输出与选中病例现在均复制，界面释放选择改为 record = {}。完成与取消两条入口都覆盖；不清理或修改旧玩家存档。
- 救援结果空对白：operative_dialogue.current() 在任何 rescue_actor（包括自行修正 0）出现后返回 {}，而 UI 仍按索引摆出任意护士。现在保留当前阶段选定的 stage_entry 原文及其实际岗位说话人；未救援的失败仍显示原有 precision_failed。可选失败组缺少时保留 stage_entry。没有追加或改写角色台词。
- 成功／失败终止空樱花：原 Day2 包无专属终止对白；finished 时数据返回空，UI 却默认显示麻醉医生。现使用既有中英系统“手术完成／手术失败／终止”，不强行归给樱花。专属结束对白仍属作者内容缺口，本次未编造。终止状态不再残留“危机处理中”标题；阶段序号限制在总阶段数，避免 14/13。
- Day1／Day3：移除本页病房背景深色遮罩，保留原背景。线性故事及失败复盘注册现有 continue，支持空格、Enter、小键盘 Enter、点击对白框；每次 render 清除旧默认操作，编组／策略选择不继承剧情确认。原生事件输入检查每次只推进一行。
- Day3 失败复盘：使用实际参演医护的日常岗位服装，优先 default_outfit 的 serious／neutral，不再调用手术服选择器。

## Time-out 全量核查（补充用户反馈后）

遍历 27 名可编组医护、75 个岗位组合，中英各一次；合并同类主／副岗位后为 38 项。完整名单与原文见 [作者缺口清单](../../advanced_surgery_dialogue_gaps_2026-10-31.md)，机器输出见 timeout_inventory.json。

原先“仅深山、利根川、杉村缺专属确认”的核查范围过窄，只识别了通用 resolver，漏了角色旁白及岗位不匹配。现明确：11 条岗位确认建议补写，14 条已有个人回应可选细化，13 个岗位类别已有可用确认；另需作者提供樱花的成功／失败结束句各1条。用户选择交给写作 GPT，未补写新角色对白。

阿尔托莉雅已有助手 role_confirmation，已接入，原 assignment 是作者旁白而非临时通用句。中井巡回、樱花麻醉与千早／瑞穗 work.OR_02 也使用现成岗位确认原文。遥凑的 role_confirmation 自称主刀，不能误用在助手位；保留 assignment 旁白等待补稿。御堂、城宫只有旁白；本庄走低熟练度通用池；中井器械位缺适配确认，全部单列。

本庄低熟练度池6条岗位回复补忠实英文，原中文与普通 Surgery 代码不变。静态本地化审计此前不识别 responses 下语义动作键数组，已按实际 manifest 源数组收集可翻译叶节点；真实6键通过、不存在的数组索引仍拒绝，未豁免无效键。

## 验证

- tools/advanced_review_regression_test.gd：最终 headless 与原生 OpenGL 窗口均 3,008 检查、0 失败。覆盖四台术式中英 Day1／Day3输入、原文/说话人、手术结束显示、Time-out 全部可选人员英文残留、返场取消／成功／失败返回病例板、持久事实契约和 campaign 不变。
- tools/advanced_operative_dialogue_test.gd：headless 与原生窗口均 4,902 检查、0 失败。额外覆盖强制 Precision 失败、助手救援、调换岗位后的说话人、失败复盘、对白不影响 RNG／HP／结果。
- tools/advanced_team_ui_test.gd：388 检查、0 失败。
- narrative_localization_test.py：29,665 检查、0 失败。localization_audit.py：754/754 UI英文键，硬编码中文候选0；全库仍有历史源语言回退，非声称整个项目完全翻译。
- advanced_three_content_audit.py：3 术式、127 术中变体、70 句故事与原包一致。未改 Whipple 或三台新增术式的任何剧情原文。
- 截图见同目录：病房亮度、白大褂复盘、救援结果中英文正文、终止系统结果。测试存档路径仅 /tmp；未写玩家存档。

本轮没有调整 HP、Precision、助手额度、生理平衡、危机抽取／结算或普通 Surgery 实现。
