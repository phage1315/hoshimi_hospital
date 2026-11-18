#!/usr/bin/env python3
"""Deterministic V1.2 importer for Miyama Kaori (`doc_rei`) Relationship Lv3:
《手术室之神》 / *The God of the Operating Room* (`miyama_03_or_god`).

Builds the 2-day event chain (`miyama_03_or_god_day1` + `miyama_03_or_god_main`, 353 total beats,
4 interactive RP/clinical choices, 2 full-screen CG reveals, seasonal casual & street switching,
and OR-cap / sterile / scrub staging) directly from the archived V1.2 manuscript:
  `research/source_scripts/HOSHIMI_MIYAMA_KAORI_LV3_OR_GOD_REVISED_V1_2.md`
applying ONLY the user-approved canon/season alignments and raw markdown cleanup.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_MD = ROOT / "research/source_scripts/HOSHIMI_MIYAMA_KAORI_LV3_OR_GOD_REVISED_V1_2.md"
TRANSLATIONS_EN = ROOT / "research/translations/miyama_lv3_en.json"
SPECIAL_EVENTS = ROOT / "data/staff/doc_rei/special_events.json"
SPECIAL_EVENT_STEPS = ROOT / "data/staff/doc_rei/special_event_steps.json"
RELATIONSHIP = ROOT / "data/staff/doc_rei/relationship.json"
LOCALIZATION_ZH = ROOT / "data/localization/zh_CN.json"
LOCALIZATION_EN = ROOT / "data/localization/en.json"

EVENT_ID = "miyama_03_or_god"
STEP_DAY1_ID = "miyama_03_or_god_day1"
STEP_MAIN_ID = "miyama_03_or_god_main"

ANNOUNCEMENT_ZH = (
    "接连两次荒唐的手术室乌龙后，深山佳織不动声色地把主刀排班往外推让——"
    "直到轮休日三号空置手术室里一场离谱的「患者位经验性排除」，迎头撞上了一台半分钟都耽误不起的真急诊。"
)
COMPLETION_HINT_ZH = (
    "深山佳織的关系等级已提升至 Lv3——"
    "「在我自己都开始怀疑判断的时候，你仍然敢把主刀的位置交给我。」"
)
CHAPTERS_ZH = [
    "第一天：天台的罐装黑咖啡",
    "第二天：手术室之神",
]

NUDE_GUARDED = "assets/events/character_events/rei/lv3/nude_guarded.png"
CG_EMERGENCY_COMMAND = "assets/events/character_events/rei/lv3/emergency_command_nude.png"
CG_SURGERY_REAR = "assets/events/character_events/rei/lv3/or_god_surgery_rear.png"

# Canonical speaker mapping -> (node.speaker, node.actor_id, zh_speaker_label, en_speaker_label)
SPEAKER_META: dict[str, tuple[str, str | None, str, str]] = {
    "旁白": ("narrator", None, "旁白", "Narrator"),
    "坂口隆司": ("player", None, "坂口隆司", "Ryuji Sakaguchi"),
    "深山佳織": ("actor", "doc_rei", "深山 佳織", "Kaori Miyama"),
    "杉村弘子": ("actor", "nurse_hiroko", "杉村 弘子", "Hiroko Sugimura"),
    "城宮明日香": ("actor", "doc_asuka", "城宮 明日香", "Asuka Shiromiya"),
    "本庄萌恵": ("actor", "nurse_moe", "本庄 萌惠", "Moe Honjo"),
    "利根川安琪": ("actor", "nurse_ange", "利根川 安琪", "Ange Tonegawa"),
    "南条小夜香": ("actor", "doc_sayaka", "南条 小夜香", "Sayaka Nanjo"),
    "急诊女患者": ("actor", "guest_kasumi_asou", "麻生华澄", "Kasumi Asou"),
    "本庄萌恵 ＆ 利根川安琪": (
        "actor",
        "nurse_moe",
        "本庄 萌惠 ＆ 利根川 安琪",
        "Moe Honjo & Ange Tonegawa",
    ),
}

# Exact user-approved alignments by node_id: (before, after)
APPROVED_ALIGNMENTS: dict[str, list[tuple[str, str]]] = {
    "s02_019": [("晚风拂过她利落的黑发。", "晚风拂过她利落的紫发。")],
    "s05_010": [("叠得整整齐齐的针织衫和长裤", "叠得整整齐齐的便服")],
    "s07_003": [("四十二岁成年女性", "二十三岁年轻女患者麻生华澄")],
    "s07_005": [("那双黑眸骤然沉静锐利下来", "那双紫红眼眸骤然沉静锐利下来")],
    "s07_007": [("角落收纳篮里的针织衫和长裤", "角落收纳篮里的私服衣物")],
    "s07_011": [
        ("那叠需要费工夫穿脱的针织衫和长裤", "那叠需要费工夫穿脱的私服"),
        ("完全收拢黑发的患者手术帽", "完全收拢紫发的患者手术帽"),
    ],
    "s07_013": [("四十二岁的女患者", "二十三岁的年轻女患者麻生华澄")],
    "s07_015": [("急诊女患者（声音发颤）：", "麻生华澄（声音发颤）：")],
    "s08_016": [("口罩上方那双黑眸", "口罩上方那双紫红眼眸")],
    "s09_016": [("帽檐严密包住黑发", "帽檐严密包住紫发")],
    "s10a_004": [("四十二岁女性", "麻生华澄，二十三岁女性")],
    "s10a_005": [("**右侧结肠旁沟边缘**", "右侧结肠旁沟边缘")],
    "s11_011": [("急诊女患者（眨了眨眼，脸上反而浮起了更深的困惑）：", "麻生华澄（眨了眨眼，脸上反而浮起了更深的困惑）：")],
    "s12_001": [
        ("晚上八点十分，秋夜的凉风吹过医院门外的银杏街道。", "晚上八点十分，微凉的夜风吹过医院门外的行道树街道。")
    ],
    "s12_042": [("浅笑（`small_smile`）：", "浅笑：")],
}


def read_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, payload: object) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def load_staff_portraits() -> dict[str, dict[str, str]]:
    result: dict[str, dict[str, str]] = {}
    for sid in ("doc_rei", "nurse_hiroko", "doc_asuka", "nurse_moe", "nurse_ange", "doc_sayaka"):
        prof = read_json(ROOT / f"data/staff/{sid}/profile.json")
        assert isinstance(prof, dict)
        pts = dict(prof["visuals"]["portraits"])
        for k, rel_path in pts.items():
            if not (ROOT / rel_path).is_file():
                raise FileNotFoundError(f"Missing portrait file for {sid} {k}: {rel_path}")
        result[sid] = pts
    for extra in (NUDE_GUARDED, CG_EMERGENCY_COMMAND, CG_SURGERY_REAR):
        if not (ROOT / extra).is_file():
            raise FileNotFoundError(f"Missing Lv3 event asset: {extra}")
    cameos = read_json(ROOT / "data/patients/cameo_patients.json")
    assert isinstance(cameos, list)
    kasumi = next((c for c in cameos if c.get("id") == "guest_kasumi_asou"), None)
    if kasumi is None:
        raise KeyError("Missing guest_kasumi_asou in data/patients/cameo_patients.json")
    kasumi_pts = dict(kasumi["visuals"])
    for k, rel_path in kasumi_pts.items():
        if not (ROOT / rel_path).is_file():
            raise FileNotFoundError(f"Missing guest_kasumi_asou portrait {k}: {rel_path}")
    result["guest_kasumi_asou"] = kasumi_pts
    return result


def infer_inline_speaker(prefix: str) -> str:
    rules = [
        ("坂口微微挑眉", "坂口隆司"),
        ("坂口隆司怔了一下", "坂口隆司"),
        ("刚签完报表匆匆赶上四楼的城宮明日香", "城宮明日香"),
        ("手术部护士利根川安琪", "利根川安琪"),
        ("咔哒两声脆响，本庄萌恵", "本庄萌恵"),
        ("然而安琪的下一句汇报", "利根川安琪"),
        ("躺在手术台上的女患者", "急诊女患者"),
        ("深山佳織此刻已彻底进入急诊抢救状态", "深山佳織"),
        ("见深山全神贯注核查片子与补液节奏，坂口隆司", "坂口隆司"),
        ("失去意识前嘴里还在面罩下困惑地小声嘟囔", "急诊女患者"),
        ("深山佳織伸出双手正要去接刷手皂液", "深山佳織"),
        ("城宮明日香站在刷手池边", "城宮明日香"),
        ("深山佳織垂在身侧的手指", "深山佳織"),
        ("城宮明日香迎着挚友紧绷的目光", "城宮明日香"),
        ("明日香顿了顿", "城宮明日香"),
        ("站在器械台对面的萌恵", "本庄萌恵"),
        ("深山佳織双臂平举配合穿戴", "深山佳織"),
        ("本庄萌恵看着眼前神色肃穆", "本庄萌恵"),
        ("察觉到坂口走近，深山佳織", "深山佳織"),
        ("深山佳織凝神审视着水肿的三角区", "深山佳織"),
        ("深山佳織点头赞同", "深山佳織"),
        ("深山佳織指尖隔着无菌纱布", "深山佳織"),
        ("深山佳織抬起眼睛看向对面的坂口隆司", "深山佳織"),
        ("深山佳織迎着他的视线", "深山佳織"),
        ("器械台边的本庄萌恵", "本庄萌恵"),
        ("南条小夜香神色一凛", "南条小夜香"),
        ("还有些迷迷糊糊的患者", "急诊女患者"),
        ("坂口隆司则忍住眼底的笑意", "坂口隆司"),
        ("深山佳織接过纸袋", "深山佳織"),
        ("深山佳織嘴角微抽了一下", "深山佳織"),
        ("站在一旁的坂口隆司", "坂口隆司"),
        ("深山佳織抬眼睨了他一下", "深山佳織"),
        ("深山佳織迎着老友戏谑的目光", "深山佳織"),
        ("她看着神色重新站稳的挚友", "城宮明日香"),
        ("深山佳織安静地听了半秒", "深山佳織"),
        ("城宮明日香表情一僵", "城宮明日香"),
        ("目送明日香笑着摆手走远，深山佳織", "深山佳織"),
        ("她轻轻吸了一口清凉的夜气", "深山佳織"),
        ("想起傍晚在三号手术室撞见的那荒唐一幕，坂口隆司", "坂口隆司"),
        ("她的目光望向前方车站暖黄色的顶棚灯光", "深山佳織"),
        ("坂口隆司微微有些意外", "坂口隆司"),
        ("她顿了半秒", "深山佳織"),
        ("深山佳織刷开检票闸机前转过身", "深山佳織"),
        ("起初的一秒钟里", "旁白"),
        ("深山佳織闭了一下眼", "深山佳織"),
    ]
    for marker, spk in rules:
        if marker in prefix:
            return spk
    raise AssertionError(f"Unrecognized inline speaker prefix: {prefix!r}")


def parse_manuscript() -> tuple[list[dict], dict[str, dict]]:
    raw_md = SOURCE_MD.read_text(encoding="utf-8")
    body = "## Scene 2｜" + raw_md.split("## Scene 2｜", 1)[1].split("> **【系统提示", 1)[0]

    beats: list[dict] = []
    choices: dict[str, dict] = {}
    scene_prefix = ""
    scene_counter = 0
    in_costume = False
    active_choice_num = ""
    pending_merge = False
    cur_branch_key = ""

    for raw_line in body.splitlines():
        s = raw_line.strip()
        if not s:
            continue
        if s == "---":
            in_costume = False
            continue
        m_scene = re.match(r"^## Scene (\d+)｜", s)
        if m_scene:
            in_costume = False
            num = int(m_scene.group(1))
            if num == 10:
                scene_prefix = "s10a"
            else:
                scene_prefix = f"s{num:02d}"
            scene_counter = 0
            continue
        m_stage = re.match(r"^### 【阶段 10-([1-6])：", s)
        if m_stage:
            in_costume = False
            stage_idx = int(m_stage.group(1))
            scene_prefix = f"s10{'abcdef'[stage_idx - 1]}"
            scene_counter = 0
            continue
        if s.startswith(
            (
                "**【场景】**",
                "**【时间】**",
                "**【在场角色】**",
                "**【团队岗位】**",
                "**【演出形式】**",
                "**【触发专属 CG：",
                "**【触发核心专属 CG：",
            )
        ):
            in_costume = False
            continue
        if s.startswith(("**【服装与状态】**", "**【服装与视觉资产】**")):
            in_costume = True
            continue
        if in_costume and s.startswith("- "):
            continue
        if s.startswith("*") and not s.startswith("**") and s.endswith("*"):
            continue

        m_ch_hdr = re.match(r"^\*\*【选择 (\d+)（.+）：.+】\*\*$", s)
        if m_ch_hdr:
            active_choice_num = m_ch_hdr.group(1)
            cur_branch_key = ""
            choices[active_choice_num] = {
                "host_id": beats[-1]["id"],
                "options": [],
                "branches": {},
                "merge_id": "",
            }
            continue

        m_opt = re.match(r"^- \*\*选项 ([ABC])：(「.+」)\*\*$", s)
        if m_opt:
            opt_letter = m_opt.group(1).lower()
            choices[active_choice_num]["options"].append((opt_letter, m_opt.group(2)))
            choices[active_choice_num]["branches"][opt_letter] = []
            continue

        m_br = re.match(r"^\*\*【选择选项 ([ABC]) 后的分支演出】\*\*$", s)
        if m_br:
            cur_branch_key = m_br.group(1).lower()
            continue

        if re.match(r"^\*\*【(?:分支汇合点：|阶段 10-[35] 汇合).+】\*\*$", s):
            cur_branch_key = ""
            pending_merge = True
            continue

        def record(spk: str, txt: str) -> None:
            nonlocal pending_merge
            nonlocal scene_counter
            scene_counter += 1
            nid = f"{scene_prefix}_{scene_counter:03d}"
            if nid in APPROVED_ALIGNMENTS:
                for old, new in APPROVED_ALIGNMENTS[nid]:
                    if old not in txt:
                        raise AssertionError(f"Expected {old!r} in {nid}: {txt!r}")
                    txt = txt.replace(old, new, 1)
            beats.append({"index": len(beats), "id": nid, "scene": scene_prefix, "speaker": spk, "text": txt})
            if cur_branch_key:
                choices[active_choice_num]["branches"][cur_branch_key].append(nid)
            if pending_merge:
                choices[active_choice_num]["merge_id"] = nid
                pending_merge = False

        # Bare dialogue line in Scene 11 (`s11_026`: Asuka walking down hallway)
        if s == "「哦？我还以为某位深山大医生准备就这个课题写篇论文呢。」":
            record("城宮明日香", s)
            continue

        m_dlg = re.fullmatch(r"\*\*([^*]+)\*\*：(「.+」)", s)
        if m_dlg:
            record(m_dlg.group(1).strip(), m_dlg.group(2).strip())
            continue

        m_paren = re.fullmatch(r"\*\*([^*]+)\*\*（([^）]+)）：(「.+」)", s)
        if m_paren:
            spk = m_paren.group(1).strip()
            act = m_paren.group(2).strip()
            record("旁白", f"{spk}（{act}）：")
            record(spk, m_paren.group(3).strip())
            continue

        m_mix = re.match(r"^(.+?)：(「[^「」]+」)$", s)
        if m_mix:
            pref, qt = m_mix.group(1), m_mix.group(2)
            spk = infer_inline_speaker(pref)
            record("旁白", pref + "：")
            record(spk, qt)
            continue

        if s.startswith(("#", "**", "- ")):
            raise AssertionError(f"Unrecognized manuscript line: {s!r}")

        record("旁白", s)

    if len(beats) != 353:
        raise AssertionError(f"Expected 353 beats, got {len(beats)}")
    if len(choices) != 4:
        raise AssertionError(f"Expected 4 choice blocks, got {len(choices)}")
    return beats, choices


def p_stand(actor_id: str, path: str, x: float = 965) -> dict:
    return {"id": actor_id, "path": path, "x": x, "bottom": 650, "width": 410, "height": 505}


def p_cap(path: str, x: float = 955, width: float = 445, height: float = 334) -> dict:
    return {"id": "doc_rei", "path": path, "x": x, "bottom": 540, "width": width, "height": height}


def p_kasumi_cap(path: str, x: float = 455, width: float = 445, height: float = 334) -> dict:
    return {"id": "guest_kasumi_asou", "path": path, "x": x, "bottom": 540, "width": width, "height": height}


def stage_node(node: dict, pts: dict[str, dict[str, str]]) -> None:
    nid = node["id"]
    scene = nid.split("_", 1)[0]
    num = int(nid.split("_", 1)[1])

    # Day 1 — Scene 2: Rooftop
    if scene == "s02":
        node["background_id"] = "rooftop"
        if num == 1:
            node["hide_portrait"] = True
            return
        node["actor_id"] = "doc_rei"
        node["outfit"] = "white_coat"
        if num <= 9:
            node["expression"] = "neutral"
        elif num <= 14:
            node["expression"] = "tired"
        elif num <= 17:
            node["expression"] = "competitive_smile"
        elif num <= 24:
            node["expression"] = "serious"
        elif num <= 27:
            node["expression"] = "neutral"
        else:
            node["expression"] = "smile"
        return

    # Scene 3: Nurses' station with Hiroko
    if scene == "s03":
        node["background_id"] = "nurses_station"
        node["actor_id"] = "nurse_hiroko"
        node["outfit"] = "uniform"
        if num in (1, 2, 10):
            node["expression"] = "neutral"
        elif 3 <= num <= 7:
            node["expression"] = "worried"
        elif num in (8, 9) or 11 <= num <= 17:
            node["expression"] = "surprised"
        else:
            node["expression"] = "smile"
        return

    # Scene 4: Outside & inside Director's office
    if scene == "s04":
        if num <= 12:
            node["background_id"] = "hallway"
            node["hide_portrait"] = True
        elif num <= 19:
            node["background_id"] = "hallway"
            node["actor_id"] = "doc_rei"
            node["outfit"] = "casual"
            node["seasonal_casual"] = True
            node["expression"] = "neutral"
        else:
            node["background_id"] = "director_office"
            node["actor_id"] = "doc_asuka"
            node["outfit"] = "white_coat"
            node["expression"] = "worried" if num in (20, 24, 25, 29, 30, 31, 32) else "neutral"
        return

    # Scene 5: Empty OR #3 — Patient-perspective empirical exclusion
    if scene == "s05":
        node["background_id"] = "or_entrance" if num <= 3 else "operating_room"
        if num <= 4:
            node["hide_portrait"] = True
        elif num <= 7:
            node["event_portraits"] = [
                p_stand("nurse_moe", pts["nurse_moe"]["uniform/worried"], 455),
                {"id": "doc_rei", "path": NUDE_GUARDED, "x": 965, "bottom": 540, "width": 320, "height": 500},
            ]
        elif num <= 11:
            moe_exp = "startled" if num <= 9 else "worried"
            node["event_portraits"] = [
                p_stand("nurse_moe", pts["nurse_moe"][f"uniform/{moe_exp}"], 455),
                p_cap(pts["doc_rei"]["or_cap/asleep"], 955),
            ]
        elif num <= 14:
            node["event_portraits"] = [p_cap(pts["doc_rei"]["or_cap/asleep"], 955, 456, 342)]
        elif num <= 16:
            node["event_portraits"] = [p_cap(pts["doc_rei"]["or_cap/drowsy"], 955, 456, 342)]
        elif num <= 18:
            node["event_portraits"] = [p_cap(pts["doc_rei"]["or_cap/embarrassed"], 955, 456, 342)]
        elif num <= 25:
            node["event_portraits"] = [p_cap(pts["doc_rei"]["or_cap/tense"], 955, 456, 342)]
        else:
            node["event_portraits"] = [p_cap(pts["doc_rei"]["or_cap/embarrassed"], 955, 456, 342)]
        return

    # Scene 6: Asuka walks into OR #3
    if scene == "s06":
        node["background_id"] = "operating_room"
        if num <= 4:
            node["event_portraits"] = [
                p_stand("doc_asuka", pts["doc_asuka"]["white_coat/worried"], 455),
                p_cap(pts["doc_rei"]["or_cap/embarrassed"], 955),
            ]
        elif num <= 6:
            node["event_portraits"] = [
                p_stand("doc_asuka", pts["doc_asuka"]["white_coat/neutral"], 375),
                p_stand("nurse_moe", pts["nurse_moe"]["uniform/startled"], 685),
                {"id": "doc_rei", "path": NUDE_GUARDED, "x": 1015, "bottom": 540, "width": 310, "height": 490},
            ]
        elif num <= 14:
            asuka_exp = "worried" if num <= 10 else "neutral"
            rei_exp = "embarrassed" if num in (11, 12, 14) else "tense"
            node["event_portraits"] = [
                p_stand("doc_asuka", pts["doc_asuka"][f"white_coat/{asuka_exp}"], 455),
                p_cap(pts["doc_rei"][f"or_cap/{rei_exp}"], 955),
            ]
        else:
            moe_exp = "worried" if num <= 16 else "embarrassed"
            node["event_portraits"] = [
                p_stand("doc_asuka", pts["doc_asuka"]["white_coat/neutral"], 455),
                p_stand("nurse_moe", pts["nurse_moe"][f"uniform/{moe_exp}"], 965),
            ]
        return

    # Scene 7: Ange bursts in with acute gallbladder perforation -> Emergency command CG in OR #2
    if scene == "s07":
        node["background_id"] = "operating_room"
        if num <= 4:
            node["event_portraits"] = [
                p_stand("nurse_ange", pts["nurse_ange"]["scrubs/worried"], 455),
                p_stand("doc_asuka", pts["doc_asuka"]["white_coat/worried"], 965),
            ]
        elif num <= 6:
            node["event_portraits"] = [
                p_stand("nurse_ange", pts["nurse_ange"]["scrubs/focused"], 455),
                p_cap(pts["doc_rei"]["or_cap/tense"], 955, 456, 342),
            ]
        elif num <= 10:
            node["event_portraits"] = [
                p_stand("nurse_moe", pts["nurse_moe"]["uniform/surprised"], 375),
                p_stand("nurse_ange", pts["nurse_ange"]["scrubs/worried"], 685),
                {"id": "doc_rei", "path": NUDE_GUARDED, "x": 1015, "bottom": 540, "width": 310, "height": 490},
            ]
        elif num <= 12:
            node["event_portraits"] = [p_cap(pts["doc_rei"]["or_cap/masked_focused"], 955, 456, 342)]
        elif num == 13:
            node["event_portraits"] = [
                p_stand("doc_sayaka", pts["doc_sayaka"]["sterile/focused"], 455),
                p_kasumi_cap(pts["guest_kasumi_asou"]["or_cap/tense"], 955, 456, 342),
            ]
        elif num <= 19:
            node["cg_path"] = CG_EMERGENCY_COMMAND
            node["cg_fit"] = "cover"
            node["cg_dialogue_delay_seconds"] = 1.0
            node["hide_portrait"] = True
        elif num <= 21:
            node["event_portraits"] = [
                p_kasumi_cap(pts["guest_kasumi_asou"]["or_cap/shocked_feverish"], 955, 456, 342),
            ]
        elif num <= 23:
            node["event_portraits"] = [
                p_kasumi_cap(pts["guest_kasumi_asou"]["or_cap/mask_drowsy"], 955, 456, 342),
            ]
        else:
            node["event_portraits"] = [
                p_stand("doc_asuka", pts["doc_asuka"]["white_coat/neutral"], 455),
                p_kasumi_cap(pts["guest_kasumi_asou"]["or_cap/anesthetized"], 955, 456, 342),
            ]
        return

    # Scene 8: Scrub sink hesitation & Choice 1
    if scene == "s08":
        node["background_id"] = "scrub_area"
        if num <= 8:
            asuka_exp = "worried"
        elif num <= 12:
            asuka_exp = "neutral"
        elif num <= 25:
            asuka_exp = "warm"
        else:
            asuka_exp = "smile"

        if num in (16, 17, 20, 21, 24, 25, 26, 27, 28):
            rei_exp = "masked_focused"
        else:
            rei_exp = "masked_hesitant"

        node["event_portraits"] = [
            p_stand("doc_asuka", pts["doc_asuka"][f"white_coat/{asuka_exp}"], 455),
            p_cap(pts["doc_rei"][f"or_cap/{rei_exp}"], 955),
        ]
        return

    # Scene 9: Scrubbing & gowning -> Rear sterile gown CG
    if scene == "s09":
        if num == 1:
            node["background_id"] = "changing"
            node["hide_portrait"] = True
        elif num <= 3:
            node["background_id"] = "scrub_area"
            node["event_portraits"] = [p_cap(pts["doc_rei"]["or_cap/masked_focused"], 955, 456, 342)]
        elif num <= 11:
            node["background_id"] = "operating_room"
            node["event_portraits"] = [
                p_stand("nurse_moe", pts["nurse_moe"]["sterile/worried"], 385),
                p_stand("nurse_ange", pts["nurse_ange"]["scrubs/focused"], 680),
                p_cap(pts["doc_rei"]["or_cap/masked_focused"], 1005, 420, 315),
            ]
        elif num <= 14:
            node["background_id"] = "operating_room"
            node["event_portraits"] = [
                p_stand("nurse_moe", pts["nurse_moe"]["sterile/focused"], 455),
                p_stand("doc_rei", pts["doc_rei"]["sterile/focused"], 965),
            ]
        else:
            node["background_id"] = "operating_room"
            node["cg_path"] = CG_SURGERY_REAR
            node["cg_fit"] = "cover"
            node["cg_dialogue_delay_seconds"] = 1.0
            node["hide_portrait"] = True
        return

    # Scene 10 (Stages 10a..10f): 6-Stage Emergency Open Cholecystectomy
    if scene in ("s10a", "s10b", "s10c", "s10d", "s10e", "s10f"):
        node["background_id"] = "operating_room"
        rei_sterile = pts["doc_rei"]["sterile/warm" if (scene == "s10f" and num >= 6) else "sterile/focused"]

        if nid == "s10f_004":
            node["event_portraits"] = [
                p_stand("nurse_moe", pts["nurse_moe"]["sterile/focused"], 375),
                p_stand("nurse_ange", pts["nurse_ange"]["scrubs/focused"], 685),
                p_stand("doc_rei", rei_sterile, 1005),
            ]
            return

        # Pair partner on the left dynamically with primary surgeon Miyama on the right
        if nid in ("s10a_001", "s10b_005", "s10c_014", "s10c_015", "s10e_001", "s10e_016", "s10e_021", "s10e_022"):
            sayaka_exp = "warm" if nid in ("s10c_014", "s10c_015") else "focused"
            left = p_stand("doc_sayaka", pts["doc_sayaka"][f"sterile/{sayaka_exp}"], 455)
        elif nid in ("s10a_003", "s10a_004", "s10b_003", "s10b_004", "s10d_002", "s10f_003", "s10f_005"):
            ange_exp = "worried" if nid in ("s10b_003", "s10b_004") else ("warm" if nid in ("s10d_002", "s10f_005") else "focused")
            left = p_stand("nurse_ange", pts["nurse_ange"][f"scrubs/{ange_exp}"], 455)
        elif nid in ("s10a_002", "s10a_007", "s10a_008", "s10b_007", "s10c_013", "s10d_003", "s10e_019", "s10e_020", "s10f_006"):
            moe_exp = "worried" if nid in ("s10e_019", "s10e_020") else "focused"
            left = p_stand("nurse_moe", pts["nurse_moe"][f"sterile/{moe_exp}"], 455)
        else:
            # Solo focus on Miyama across from first-assistant Sakaguchi (POV)
            node["event_portraits"] = [p_stand("doc_rei", rei_sterile, 965)]
            return

        node["event_portraits"] = [left, p_stand("doc_rei", rei_sterile, 965)]
        return

    # Scene 11: Post-op recovery gurney & OR hallway debrief
    if scene == "s11":
        if num <= 13:
            node["background_id"] = "pacu_recovery"
            if num == 1:
                kasumi_exp = "neutral"
            elif num <= 4 or num == 13:
                kasumi_exp = "drowsy_relieved"
            else:
                kasumi_exp = "confused"

            if num <= 5:
                rei_exp = "neutral"
            elif num <= 7:
                rei_exp = "worried"
            elif num <= 12:
                rei_exp = "focused"
            else:
                rei_exp = "warm"

            node["event_portraits"] = [
                p_stand("guest_kasumi_asou", pts["guest_kasumi_asou"][f"ward/{kasumi_exp}"], 455),
                p_stand("doc_rei", pts["doc_rei"][f"sterile/{rei_exp}"], 965),
            ]
        elif num == 14:
            node["background_id"] = "or_entrance"
            node["actor_id"] = "doc_rei"
            node["outfit"] = "scrubs"
            node["expression"] = "warm"
        elif num <= 22:
            node["background_id"] = "or_entrance"
            moe_exp = "embarrassed" if num <= 19 else "smile"
            rei_exp = "neutral" if num <= 21 else "warm"
            node["event_portraits"] = [
                p_stand("nurse_moe", pts["nurse_moe"][f"uniform/{moe_exp}"], 455),
                p_stand("doc_rei", pts["doc_rei"][f"scrubs/{rei_exp}"], 965),
            ]
        elif num <= 25:
            node["background_id"] = "or_entrance"
            node["actor_id"] = "doc_rei"
            node["outfit"] = "scrubs"
            node["expression"] = "warm"
        elif num <= 38:
            node["background_id"] = "or_entrance"
            if num <= 31:
                asuka_exp = "smile"
            elif num <= 34:
                asuka_exp = "warm"
            else:
                asuka_exp = "worried"
            rei_exp = "neutral" if num <= 32 else "warm"
            node["event_portraits"] = [
                p_stand("doc_asuka", pts["doc_asuka"][f"white_coat/{asuka_exp}"], 455),
                p_stand("doc_rei", pts["doc_rei"][f"scrubs/{rei_exp}"], 965),
            ]
        else:
            node["background_id"] = "or_entrance"
            node["actor_id"] = "doc_rei"
            node["outfit"] = "scrubs"
            node["expression"] = "warm"
        return

    # Scene 12: Seasonal night walk & train station farewell
    if scene == "s12":
        if num <= 25:
            node["background_id"] = "after_work_street_autumn_night"
            node["seasonal_street"] = True
        else:
            node["background_id"] = "shiori_lv2_station_plaza_night"

        if num in (1, 2, 44):
            node["hide_portrait"] = True
            return

        node["actor_id"] = "doc_rei"
        node["outfit"] = "casual"
        node["seasonal_casual"] = True
        small_smile_nums = {13, 14, 15, 16, 18, 19, 21, 22, 24, 25, 40, 42, 43}
        node["expression"] = "small_smile" if num in small_smile_nums else "neutral"
        return

    raise AssertionError(f"Unhandled scene for {nid}")


def build_steps(beats: list[dict], choices: dict[str, dict], pts: dict[str, dict[str, str]]) -> tuple[dict, dict]:
    # Build lookup maps for choice hosts & branch end jumps
    host_to_choice: dict[str, tuple[str, dict]] = {}
    branch_tail_to_merge: dict[str, str] = {}
    for cnum, cinfo in choices.items():
        host_to_choice[cinfo["host_id"]] = (cnum, cinfo)
        for _opt, b_ids in cinfo["branches"].items():
            branch_tail_to_merge[b_ids[-1]] = cinfo["merge_id"]

    day1_beats = [b for b in beats if b["scene"] == "s02"]
    main_beats = [b for b in beats if b["scene"] != "s02"]

    def compile_nodes(sub_beats: list[dict], finish_id: str, finish_label: str) -> list[dict]:
        compiled: list[dict] = []
        for pos, beat in enumerate(sub_beats):
            nid = beat["id"]
            role, default_actor, spk_zh, _spk_en = SPEAKER_META[beat["speaker"]]
            node: dict = {
                "id": nid,
                "presentation": "authored",
                "speaker": role,
                "speaker_label": spk_zh,
                "text": beat["text"],
                "expression": "neutral",
            }
            if default_actor is not None:
                node["actor_id"] = default_actor

            stage_node(node, pts)

            if nid in host_to_choice:
                cnum, cinfo = host_to_choice[nid]
                node["choices"] = [
                    {
                        "id": f"choice_{cnum}_{opt}",
                        "label": label,
                        "next": cinfo["branches"][opt][0],
                        "requirements": [],
                    }
                    for opt, label in cinfo["options"]
                ]
            elif nid in branch_tail_to_merge:
                node["choices"] = [
                    {
                        "id": f"continue_{nid}",
                        "label": "继续",
                        "next": branch_tail_to_merge[nid],
                        "requirements": [],
                    }
                ]
            elif pos == len(sub_beats) - 1:
                node["choices"] = [
                    {
                        "id": finish_id,
                        "label": finish_label,
                        "next": "@day_end",
                        "requirements": [],
                    }
                ]
            else:
                node["choices"] = [
                    {
                        "id": f"continue_{nid}",
                        "label": "继续",
                        "next": sub_beats[pos + 1]["id"],
                        "requirements": [],
                    }
                ]
            compiled.append(node)
        return compiled

    day1_nodes = compile_nodes(day1_beats, "finish_day1", "结束第一天")
    main_nodes = compile_nodes(main_beats, "finish_lv3", "结束")

    step_day1 = {
        "id": STEP_DAY1_ID,
        "title": "天台的罐装黑咖啡",
        "background_id": "rooftop",
        "start": day1_nodes[0]["id"],
        "scene_schedule": {
            "s02": {"clock": 1060, "day_offset": 0},
        },
        "nodes": day1_nodes,
    }

    main_schedule: dict[str, dict] = {
        "s03": {"clock": 630, "day_offset": 0},
        "s04": {"clock": 995, "day_offset": 0},
        "s05": {"clock": 1025, "day_offset": 0},
        "s06": {"clock": 1032, "day_offset": 0},
        "s07": {"clock": 1036, "day_offset": 0},
        "s08": {"clock": 1044, "day_offset": 0},
        "s09": {"clock": 1048, "day_offset": 0},
        "s10a": {"clock": 1052, "day_offset": 0},
        "s10b": {"clock": 1065, "day_offset": 0},
        "s10c": {"clock": 1085, "day_offset": 0},
        "s10d": {"clock": 1110, "day_offset": 0},
        "s10e": {"clock": 1120, "day_offset": 0},
        "s10f": {"clock": 1140, "day_offset": 0},
        "s11": {"clock": 1150, "day_offset": 0},
        "s12": {"clock": 1210, "day_offset": 0},
    }
    for n in range(14, 42):
        main_schedule[f"s11_{n:03d}"] = {"clock": 1165, "day_offset": 0}

    step_main = {
        "id": STEP_MAIN_ID,
        "title": "手术室之神",
        "background_id": "nurses_station",
        "start": main_nodes[0]["id"],
        "scene_schedule": main_schedule,
        "nodes": main_nodes,
    }

    return step_day1, step_main


def update_special_events() -> None:
    events = read_json(SPECIAL_EVENTS)
    assert isinstance(events, list)
    new_ev = {
        "id": EVENT_ID,
        "title": "手术室之神",
        "category": "character_special_event",
        "duration_days": 2,
        "consumes_full_day": True,
        "repeatable": False,
        "developer_only": False,
        "auto_schedule": True,
        "announcement": ANNOUNCEMENT_ZH,
        "completion_hint": COMPLETION_HINT_ZH,
        "unlock_requirements": [
            {
                "type": "days_after_special_event",
                "event_id": "miyama_02_manga_artist_wrong_patient",
                "days": 5,
            }
        ],
        "required_characters": [
            "PLAYER",
            "doc_rei",
            "doc_asuka",
            "nurse_moe",
            "nurse_ange",
        ],
        "prerequisite_events": [
            "miyama_02_manga_artist_wrong_patient",
        ],
        "event_chain": [
            STEP_DAY1_ID,
            STEP_MAIN_ID,
        ],
        "completion_flags": [
            "miyama_03_or_god_completed",
            "relationship_doc_rei_lv3",
            "miyama_primary_surgeon_confidence_restored",
            "miyama_or_god_gag_known_by_inner_circle",
        ],
        "completion_effects": {
            "completed_surgery_id": "surgery_open_cholecystectomy",
            "surgery_xp_bonus": 12,
            "reputation": 2,
        },
        "relationship_rewards": [
            {
                "actor_id": "doc_rei",
                "target_level": 3,
                "benefit_id": "",
                "allow_level_skip": False,
            }
        ],
        "gallery_unlock": True,
        "gallery_entry": {
            "id": EVENT_ID,
            "title": "手术室之神",
            "chapters": CHAPTERS_ZH,
        },
        "timing": {
            "trigger_day": 8,
            "priority": 205,
            "final_week_allowed": False,
            "sunday_start_allowed": False,
            "avoid_sunday_span": True,
        },
    }
    replaced = False
    for idx, item in enumerate(events):
        if item.get("id") == EVENT_ID:
            events[idx] = new_ev
            replaced = True
            break
    if not replaced:
        events.append(new_ev)
    write_json(SPECIAL_EVENTS, events)


def update_special_event_steps(step_day1: dict, step_main: dict) -> None:
    steps = read_json(SPECIAL_EVENT_STEPS)
    assert isinstance(steps, list)
    kept = [s for s in steps if s.get("id") not in (STEP_DAY1_ID, STEP_MAIN_ID)]
    kept.append(step_day1)
    kept.append(step_main)
    write_json(SPECIAL_EVENT_STEPS, kept)


def verify_relationship_slot() -> None:
    rel = read_json(RELATIONSHIP)
    assert isinstance(rel, dict)
    for slot in rel.get("rank_slots", []):
        if int(slot.get("target_level", -1)) == 3:
            assert slot.get("event_id") == EVENT_ID
            assert slot.get("content_status") == "authored"
            assert int(slot.get("min_familiarity", 0)) == 40
            assert int(slot.get("cooldown_days", 0)) == 3
            assert slot.get("special_requirements") == []
            return
    raise AssertionError("Missing target_level 3 slot in data/staff/doc_rei/relationship.json")


def update_localization(step_day1: dict, step_main: dict, choices_meta: dict[str, dict]) -> None:
    zh = read_json(LOCALIZATION_ZH)
    en = read_json(LOCALIZATION_EN)
    tr = read_json(TRANSLATIONS_EN)
    assert isinstance(zh, dict) and isinstance(en, dict) and isinstance(tr, dict)

    zh_strings: dict[str, str] = zh["strings"]
    en_strings: dict[str, str] = en["strings"]

    ev_prefix = f"collections.special_events.{EVENT_ID}"
    step1_prefix = f"collections.special_event_steps.{STEP_DAY1_ID}"
    step2_prefix = f"collections.special_event_steps.{STEP_MAIN_ID}"

    for target in (zh_strings, en_strings):
        stale = [
            k
            for k in target
            if k.startswith(ev_prefix + ".")
            or k.startswith(step1_prefix + ".")
            or k.startswith(step2_prefix + ".")
        ]
        for k in stale:
            del target[k]

    ev_en = tr["event"]
    zh_strings[f"{ev_prefix}.title"] = "手术室之神"
    zh_strings[f"{ev_prefix}.announcement"] = ANNOUNCEMENT_ZH
    zh_strings[f"{ev_prefix}.completion_hint"] = COMPLETION_HINT_ZH
    zh_strings[f"{ev_prefix}.gallery_entry.title"] = "手术室之神"
    zh_strings[f"{ev_prefix}.gallery_entry.chapters.0"] = CHAPTERS_ZH[0]
    zh_strings[f"{ev_prefix}.gallery_entry.chapters.1"] = CHAPTERS_ZH[1]

    en_strings[f"{ev_prefix}.title"] = ev_en["title"]
    en_strings[f"{ev_prefix}.announcement"] = ev_en["announcement"]
    en_strings[f"{ev_prefix}.completion_hint"] = ev_en["completion_hint"]
    en_strings[f"{ev_prefix}.gallery_entry.title"] = ev_en["gallery_title"]
    en_strings[f"{ev_prefix}.gallery_entry.chapters.0"] = ev_en["chapters"][0]
    en_strings[f"{ev_prefix}.gallery_entry.chapters.1"] = ev_en["chapters"][1]

    cameos = read_json(ROOT / "data/patients/cameo_patients.json")
    assert isinstance(cameos, list)
    kasumi = next(c for c in cameos if c.get("id") == "guest_kasumi_asou")
    cameo_prefix = "collections.cameo_patients.guest_kasumi_asou"
    zh_strings[f"{cameo_prefix}.canonical_name"] = str(kasumi["canonical_name"])
    zh_strings[f"{cameo_prefix}.public_name"] = str(kasumi["public_name"])
    zh_strings[f"{cameo_prefix}.notes"] = str(kasumi["notes"])
    en_strings[f"{cameo_prefix}.canonical_name"] = "Asou Kasumi"
    en_strings[f"{cameo_prefix}.public_name"] = "Asou Kasumi"
    en_strings[f"{cameo_prefix}.notes"] = (
        "A 23-year-old young adult woman (from Tokimeki Memorial 2), retaining her signature "
        "voluminous center-parted deep emerald long hair, warm brown eyes, and gentle, poised "
        "demeanor. Rushed through the ER green channel into OR #2 in Kaori Miyama's Lv3 event "
        "'The God of the Operating Room' with complicated acute cholecystitis, gallbladder "
        "perforation, and biliary peritonitis, she catches sight of Miyama hurrying into the "
        "outer prep zone while feverish before anesthesia and mistakes her for a fever-and-"
        "anesthetic hallucination. Appears strictly as a story cameo patient without unlocking "
        "romance or random patient-pool flows."
    )
    zh_strings["collections.backgrounds.pacu_recovery.label"] = "术后麻醉恢复室"
    en_strings["collections.backgrounds.pacu_recovery.label"] = "Post-Anesthesia Care Unit (PACU)"

    spk_zh_to_en = {v[2]: v[3] for v in SPEAKER_META.values()}
    choice_id_to_tr_key: dict[str, str] = {}
    for cnum, cinfo in choices_meta.items():
        host_id = cinfo["host_id"]
        for opt, _lbl in cinfo["options"]:
            choice_id_to_tr_key[f"choice_{cnum}_{opt}"] = f"{host_id}:{opt}"

    en_nodes: dict[str, str] = tr["nodes"]
    en_choices: dict[str, str] = tr["choices"]
    en_step_titles: dict[str, str] = tr["step_titles"]

    for step_prefix, step in ((step1_prefix, step_day1), (step2_prefix, step_main)):
        sid = step["id"]
        zh_strings[f"{step_prefix}.title"] = step["title"]
        en_strings[f"{step_prefix}.title"] = en_step_titles[sid]

        for node in step["nodes"]:
            nid = node["id"]
            if nid not in en_nodes or not str(en_nodes[nid]).strip():
                raise KeyError(f"Missing English node translation for {nid}")
            n_prefix = f"{step_prefix}.nodes.{nid}"
            spk_zh = node["speaker_label"]
            zh_strings[f"{n_prefix}.text"] = node["text"]
            zh_strings[f"{n_prefix}.speaker_label"] = spk_zh
            en_strings[f"{n_prefix}.text"] = str(en_nodes[nid])
            en_strings[f"{n_prefix}.speaker_label"] = spk_zh_to_en[spk_zh]

            for ch in node["choices"]:
                cid = ch["id"]
                c_key = f"{n_prefix}.choices.{cid}.label"
                zh_strings[c_key] = ch["label"]
                if cid.startswith("continue_"):
                    en_strings[c_key] = "Continue"
                elif cid == "finish_day1":
                    en_strings[c_key] = "End Day 1"
                elif cid == "finish_lv3":
                    en_strings[c_key] = "Finish"
                else:
                    tr_key = choice_id_to_tr_key[cid]
                    if tr_key not in en_choices or not str(en_choices[tr_key]).strip():
                        raise KeyError(f"Missing English choice translation for {cid} ({tr_key})")
                    en_strings[c_key] = str(en_choices[tr_key])

    write_json(LOCALIZATION_ZH, zh)
    write_json(LOCALIZATION_EN, en)


def main() -> None:
    pts = load_staff_portraits()
    beats, choices = parse_manuscript()
    step_day1, step_main = build_steps(beats, choices, pts)
    update_special_events()
    update_special_event_steps(step_day1, step_main)
    verify_relationship_slot()
    update_localization(step_day1, step_main, choices)
    print(
        f"Imported {EVENT_ID} V1.2: {STEP_DAY1_ID} ({len(step_day1['nodes'])} beats) + "
        f"{STEP_MAIN_ID} ({len(step_main['nodes'])} beats) = {len(beats)} beats; zh_CN + en synced."
    )


if __name__ == "__main__":
    main()
