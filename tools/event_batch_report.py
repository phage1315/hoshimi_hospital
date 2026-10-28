"""Build a QA evidence index; statuses deliberately separate execution from acceptance."""
import json,collections
from pathlib import Path
Q=Path(__file__).resolve().parents[1]/'docs/qa/event_batch_first20_rows_2026-10-27'
def read(name):return json.loads((Q/name).read_text())
scope=read('scope.json');main=read('runtime_results.json');boundary=read('boundary_results.json');audit=read('observation_audit.json');visual=read('visual_audit.json');entries=read('entry_results.json');extra=read('extra_results.json');clinical=read('clinical_entry_results.json');source=read('source_expectations.json')
coverage={(x['event'],x['locale'],x['replay']):x for x in audit['coverage']}
speaker={x['event'] for x in audit['unique_issues'] if x['kind']=='source_speaker_mismatch'}
rows=[]
for r in scope:
 eid=r['id'];entry=next(x for x in entries if x['event']==eid and x['locale']=='zh_CN')
 mode='地点入口已触发（内存前置）' if entry['entry_started'] else '未确认'
 if r['type']=='special_events':mode='日始正式调度已触发（内存前置）'
 if eid=='hiroko_lv1_or_instrument_panic':mode='萌熟悉度9拒绝/10允许，地点入口触发'
 if eid=='ange_lv5_call_me_main':mode='受项目授权flag门槛限制；只验内容'
 if entry['mode']=='preop_stage':
  rs=[x for x in clinical if x['event']==eid];mode='临床阶段夹具入口已触发' if all(x['entry_started'] for x in rs) else '临床入口未完成；见专门日志'
 cv=[]
 for loc in ['zh_CN','en']:
  a=coverage[eid,loc,False];b=coverage[eid,loc,True];cv.append(f"{a['observed_nodes']}/{a['defined_nodes']} · {b['observed_nodes']}/{b['defined_nodes']}")
 display='场景说明重叠 P2' if eid=='manami_lv1_sneeze' else '英文拆词 P2' if eid=='miyama_03_or_god' else '配置路径/几何检查未发现偏差'
 ownership='姓名错误 P2' if eid in speaker else '映射页未见姓名错误；全文原稿审计有限'
 provenance=f"独立映射 {len(source.get(eid,{}))} 节点" if eid in source else '仅设计/修订或缺最终逐句稿'
 flow='已播放；间歇输入停滞待查' if eid=='hiroko_lv1_worth_it' else '已播放；入口与结算范围见日志'
 if eid=="miyama_03_or_god":
  flow="已播放；原稿关系段等缺失 P1；固定对白流程认可";ownership="why姓名错误 P2";provenance="原稿已补核，不通过；见 MIYAMA_LV3_SOURCE_ADDENDUM.md"
 rows.append(f"| {r['title']} `{eid}` | 是 / 是 | {cv[0]} | {cv[1]} | {mode} | {flow} | {display} | {ownership}；{provenance} |")
counts=collections.Counter(x['outcome'] for x in main['routes']);bcounts=collections.Counter(x['outcome'] for x in boundary['routes'])
text='''# 前20行事件中英文原生 QA（39 个独立事件）

本报告是当前工作区的测试记录，不是“全部通过”的验收单。中文与英文分别执行；正式入口、隔离内容播放、原稿一致性分别判定。游戏代码、剧情、素材均未修改。

## 版本与安全范围

- 分支 `main`，HEAD `f95636a22b16c7d2dfd99e9956e32c90b3dba21e`，以接手时的未提交工作区为实际测试版本。`worktree_before.txt`、`baseline_hashes.json` 记录基线，`baseline_drift.json` 记录复查。
- 已阅读 agents.md、2026-10-26 交接、architecture 现行规则、save_boundary_v37、bug_backlog。旧验收不作为此次运行证据。
- Godot 4.5.1，macOS 原生窗口，OpenGL 4.1 / Apple M2；不是 headless 播放。GUI 输入通过窗口 Viewport 分发鼠标按下/抬起、空格、回车；自动播放通过实际按钮开启。
- 每个进程在挂载主场景前将 SaveStore 路径改到唯一、未写入的临时路径。没有读取/覆盖玩家槽位，没有生成测试存档，没有输出用于恢复游戏的会话快照。JSONL 为屏幕观察记录，包含节点标识仅用于问题定位，不能恢复会话。
- 新增的 tools/event_batch_* 均为测试工具；没有提交、推送、发布或删除资源。

## 三项分别结论

1. **事件流：有条件完成播放验证，不能总体验收通过。** 正文与回想按实际 GUI 翻页、选择、合流和结束；遍历每个选择边的最小路线集，不是所有历史选择的笛卡尔组合。正式入口使用完整生产注册表和调度器，前置为透明记录的隔离内存已结算事实；不是从新游戏自然养成至此的证明。安琪 Lv5 主事件保留门槛受限状态。弘子《值得的事情》首轮英文出现5次输入停滞，独立复验全部路线完成，原因仍未确证。
2. **显示与交互：不通过。** 真奈美 Lv1 场景说明与副标题重叠；英文旧分页把单词拆开。控件高度告警单列为风险，未把5像素测量差直接当作截字证据。CG对白框覆盖属于预期，不列缺陷。
3. **说话人与立绘：不通过。** 已确认实际姓名标签错误，见下文。资源路径、衣服/表情配置、多人和副立绘位置、隐藏/恢复的运行观察与配置比较未见偏差；这不代表配置符合全部原稿情绪。独立原稿映射只覆盖已能可靠提取的节点，缺稿与修订版本不明的事件不能获得全文通过结论。

## 已确认问题（均未修复）

### P2 姓名标签被旧分页说话人推断覆盖

- 真奈美 Lv0 `im0_0003` 等20个角色对白节点，原稿/配置为真奈美，屏幕为 `旁白 / Narrator`。正文和回想、中英均复现。原稿是 `docs/source/lv0_introductions/HOSHIMI_IIMURA_MANAMI_LV0_PHARMACY_INTRO_CN_REVIEW.md`；原文未缺引号，导入的对白本身已按原稿审计，不能为了显示正确擅自改原句。
- 安琪 Lv1主 `beat_006/008/018/033` 接班护士→安琪；Lv2主及后续患者→安琪；Lv3后续弘子→安琪；Lv5后续患者/弘子→安琪。自动独立映射因“嗯”等重复短句只纳入明确唯一匹配，完整证据节点见 `observation_audit.json`。
- 深山 Lv2 `s08_013 / s11_003 / s12_018` 彩子内心，原稿和明确标签为彩子，实际 `旁白 / Narrator`。不是要求画面角色必须发言，而是原稿归属被覆盖。
- 定位：`godot/ui/app.gd` 的 `dialogue_page_presentation` 及正文/回想调用。最小建议：使明确归属优先于引号推断，逐页保留原归属；不要通过修改对白或换图修复。需用户授权后实施。
- 截图：[真奈美中文](zh_CN_intro_pharmacist_manami_repro_im0_0003_main.png)、[安琪英文](en_ange_lv1_handover_main_repro_beat_006_main.png)、[彩子英文回想](en_miyama_02_manga_artist_wrong_patient_repro_s08_013_replay.png)。对应中英/正文/回想四种截图均在本目录，以 `repro_` 搜索。

### P2 真奈美 Lv1 场景字幕压住页眉副标题

- `im1_s1_a01` 开场“下午 / Afternoon”，正文及回想、中英都与人物/事件类型副标题重叠。
- 定位：app.gd `scene_caption` 固定 `(60,140)`，与页眉副标题占用同一高度。
- 最小建议：调整场景说明这一UI控件的位置或预留独立行；不移动、裁切或修改用户原图。
- 截图：[英文正文](en_manami_lv1_sneeze_formal_entry.png)、[中文回想](zh_CN_manami_lv1_sneeze_replay_im1_s1_a01.png)。

### P2 英文旧分页拆开单词

- 深山 Lv3 `gown` 第0页结尾 `Sh`，第1页开头 `e did not ...`，把 `She` 拆成两页。正文/回想均复现。文本仍在后页，不报告为丢字。
- 定位：旧 `dialogue_pages/dialogue_hard_wrap`，与已存在的 authored 英文按单词边界分页不同。
- 最小建议：统一使用保留单词边界且保留字符的分页算法，复验长度和姓名归属；不改变原文。
- 截图：[英文正文](en_miyama_03_or_god_repro_gown_main.png)，完整页文字见 `pages.jsonl` / `reproduction_pages.jsonl`。

## 尚未归因的现象、预期行为与测试修正

- 《值得的事情》英文主线 `patient_update/late_training/one_patient` 和回想 `opening` 首轮停滞。`hiroko_recheck_results.json` 独立重跑全部完成；保留原始 `native.log` 与 `stall_` 截图。不能称稳定输入通过，也不能据单次批处理失败直接改游戏。
- `text_overflow` 是 RichTextLabel content_height 大于容器5像素的测量告警，截图未证明所有告警都造成可见字符丢失；完整列表保留。必须与已确认的拆词问题区分。
- 安琪 Lv5 主事件的 `staff_as_patient_program_authorized` 为有效现行门槛；测试没有将其打开。显示“内容播放完成”不表示正式路线开放。
- 真奈美 Lv1、美幸 Lv1完成后直接返回地图/护士站为专用流程；美幸返回可能立即触发更高优先级的未完事件，日志保留实际下一活动。
- 御堂绘美子 Lv0配置有3天后13:00自动转入Lv1，故账面跳时不能按“25分钟”孤立判断为错误；该链的跨事件完整演出尚不能由每事件重置测试替代。
- 初次回想夹具未设置完成事实引发锁定弹窗，已修正并保留 `harness_pilot/`；时间边界夹具的 set_test_time 会被夹取且需扣除已完成事件耗时，已修正，初次结果保留 `entry_first_probe.json`。未据测试错误修改游戏。
- 临床夹具初版漏了刷手动作及使用了错误的术后按钮匹配，另一次漏处理更衣视频遮罩，按GUI关闭转场、重新获取刷手按钮后中英文入口均触发。修正的是测试脚本；原始记录 `clinical_entry_initial_probe.json` 保留。

## 每事件清单

“是/是”仅指已在原生窗口运行中文/英文。共1581个定义节点已分别在中文/英文正文和回想观察到。节点列为“正文观察数/定义数 · 回想观察数/定义数”，不等于逐句原稿验收通过。具体选择边、运行路线、页面、返回界面在 JSON/JSONL 中。

| 事件 | 实机 中/英 | 中文节点 正文·回想 | 英文节点 正文·回想 | 入口 | 事件流 | 显示交互 | 说话人与立绘/原稿 |
|---|---|---|---|---|---|---|---|
'''+ '\n'.join(rows)+'''

## 原稿与尚未覆盖范围

- 独立来源及SHA256见 `source_provenance.json`；逐句映射见 `source_expectations.json`。深山Lv0、美幸Lv1、真奈美Lv0/Lv1有明确审稿；安琪使用最终实装设计中的逐句段落，深山Lv2使用V8中可明确归属的句子。两项既有 source audit 已复用执行。
- 深山Lv1设计明确是详细设计草案，不能自动当作完整最终对白稿；Lv3原稿已由用户补充，核对发现重大差异及新增姓名错误，见 [Lv3补核报告](MIYAMA_LV3_SOURCE_ADDENDUM.md)。部分早期介绍/偶遇缺最终逐句原稿。已询问本地原稿位置，未取得补充前不能宣称全39项原文逐句一致。
- 弘子Lv1设计稿与现数据存在候选文字差异，缺最终修订链证明；`hiroko_source_differences.json` 仅为待核对候选，不能当已确认擅改数量。
- 完整自然养成前置、全部冷却交叉组合、所有日程优先级组合、临床从入院至术后的完整路径没有穷举；入口夹具和内容路线必须分别理解。
- 部分完成返回涉及跨日或自动后继事件，`boundary_results.json` 记录到达界面；未沿每条后继跨事件链持续跑完。所有事件的提前退出回想已独立检查；主事件强制退出/进程关闭后重启不属于事件中途恢复契约，未读写任何玩家存档。
- 未以素材加载成功替代情绪验收。只有原稿明确、素材映射明确的范围可据原稿下结论，其余表情意图待核；没有改图或生成替代素材。

## 运行证据

'''+f"- 第一轮：{len(main['routes'])} 条路线、{main['pages']} 页面观察；结果 {dict(counts)}。输入计数 {main['inputs']}。\n- 分支回想/结算补测：{len(boundary['routes'])} 条路线，结果 {dict(bcounts)}；详见 `boundary_results.json`。\n- 配置视觉路径/几何：{visual['page_checks']} 页，比较发现 {len(visual['issues'])} 项。独立原稿姓名检查计数见 `observation_audit.json`，不扩大为全文原稿覆盖。\n"+'''- `python3 tools/narrative_localization_test.py`：18383 checks，0 failures。`python3 tools/localization_audit.py` 已运行，日志保留；全仓仍有source fallback，不将覆盖率数字等同于本批运行完成。
- `entry_results.json` / `extra_results.json`：正式调度、前置、优先级、画廊标签/选项、回想退出；`clinical_entry_results.json`：临床阶段入口；`reproduction_results.json`：问题定点复现。
- `native.log`、`boundary_native.log`、`pages.jsonl`、`boundary_pages.jsonl`：运行与页面观察；`observation_audit.json`：每节点覆盖和说话人；`visual_audit.json`：背景/立绘/CG路径及几何；`source_audit.log`：独立文本映射检查。
- PNG截图全部保存在本目录，文件名包含语言、事件ID、节点或用途。`repro_` 为定点复现，不能替代从入口到该节点的完整路线；其他路线日志提供相应播放证据。
'''
(Q/'REPORT.md').write_text(text)
print(Q/'REPORT.md')
