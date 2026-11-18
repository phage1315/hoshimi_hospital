#!/usr/bin/env python3
"""Import Asuka Shiromiya (`doc_asuka`) Relationship Lv1:
《院长也是外科医生》 (The Director Is Also a Surgeon).

Updates:
- data/staff/doc_asuka/profile.json (7 new 1024x1536 RGBA scrubs portraits + scrubs/smile)
- data/staff/doc_asuka/relationship.json (Lv1 authored slot + gate_event_id)
- data/staff/doc_asuka/events.json (Scene 1 preop + Scene 3 postop character events)
- data/localization/zh_CN.json & data/localization/en.json
- research/generated_candidates/asuka_lv1_scrubs_v1/generation.json
- research/imports/asuka_lv1_2026-11-13.json
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

PORTRAIT_PATHS = {
    "masked_bright": "assets/characters/asuka_lv1_v1/doc_asuka/scrubs/masked_bright.png",
    "masked_smile": "assets/characters/asuka_lv1_v1/doc_asuka/scrubs/masked_smile.png",
    "cap_smile": "assets/characters/asuka_lv1_v1/doc_asuka/scrubs/cap_smile.png",
    "cap_critique": "assets/characters/asuka_lv1_v1/doc_asuka/scrubs/cap_critique.png",
    "cap_shy": "assets/characters/asuka_lv1_v1/doc_asuka/scrubs/cap_shy.png",
    "hair_down_smile": "assets/characters/asuka_lv1_v1/doc_asuka/scrubs/hair_down_smile.png",
    "hair_down_wave": "assets/characters/asuka_lv1_v1/doc_asuka/scrubs/hair_down_wave.png",
}

SPEAKER_ZH = {
    "actor": "城宮明日香",
    "player": "坂口隆司",
    "narrator": "旁白",
}

SPEAKER_EN = {
    "actor": "Asuka Shiromiya",
    "player": "Takashi Sakaguchi",
    "narrator": "Narrator",
}

SCENE1_BEATS = [
    ("al1a_001", "narrator", None, "距离预定的划刀时间还有十分钟。坂口隆司核对完手头的术前同意书，刚拐进四楼刷手区，就听见最里侧的感应水龙头已经传来了哗哗的水声。"),
    ("al1a_002", "narrator", "masked_smile", "城宮明日香早就站在水池前了。平时散在肩头的长发已经被她利落地尽数收进手术帽里，露出光洁饱满的额角与一双神采奕奕的眼睛。见坂口走近，她弯起眉眼，举着沾满细腻泡沫的小臂朝他晃了晃手肘权当招呼。"),
    ("al1a_003", "actor", "masked_smile", "「来得正好呀，坂口医生。患者刚刚已经接进手术间核对信息了，器械台那边也清点得很顺利哦。」"),
    ("al1a_004", "narrator", "masked_bright", "坂口隆司走到相邻的水池前踩开踏板，挤出刷手液，看着身旁动作熟稔的年轻院长，忍不住笑了一下。"),
    ("al1a_005", "player", "masked_bright", "「明明今天是我主动勾了你的名字请你来搭把手……怎么算上今天这回，每次请你上台当助手，你不仅答应得比谁都痛快，来刷手池报到的速度比我这个主刀还要早？」"),
    ("al1a_006", "actor", "masked_smile", "「因为收到主刀医生的正式点名，当然要拿出合格第一助手的职业态度呀。」"),
    ("al1a_007", "player", "masked_bright", "「话是这么说……院长，你办公桌上那些财务报表和排班签批，今天不用管了？」"),
    ("al1a_008", "actor", "masked_smile", "「哼哼，小看人了吧？急着要签的文件我今天一早八点前就全部批完发回行政科了，眼下这段时间，日历上可是堂堂正正标着『临床外勤』四个大字的。」"),
    ("al1a_009", "narrator", "masked_bright", "温水冲净指缝与前臂的泡沫，明日香保持着双手高举过肘的标准无菌姿势，侧过脸看向坂口，口罩上方那双明亮的眸子里透着几分藏不住的轻快。"),
    ("al1a_010", "actor", "masked_bright", "「再说了，母亲把星见交给我的时候，可没规定当了院长就得把自己锁在办公桌后面天天盖章。我本来就是正经考出执业资格的外科医生嘛——比起对着一摞干巴巴的耗材预算表发呆，还是站在这里听见水声和监护仪的声音更让人精神百倍。」"),
    ("al1a_011", "player", "masked_bright", "「看来我们医院的院长，是真心喜欢待在手术室里。」"),
    ("al1a_012", "actor", "masked_smile", "「那当然啦。干净、有序、所有人都在专心做好同一件事，全院上下哪有比手术室更让人安心的地方？走吧，坂口主刀，别让里面的护士和患者等急了——今天第一助手的位置，请多指教咯。」"),
]

SCENE3_BEATS = [
    ("al1b_001", "narrator", None, "随着手术间的自动门在身后轻轻合拢，最后一针缝合收尾的紧绷感也跟着松弛了下来。"),
    ("al1b_002", "narrator", "cap_smile", "坂口隆司把脱下的乳胶手套丢进医疗回收桶，解开脑后的口罩系带，看了一眼身旁正把换下来的墨绿色无菌手术袍利落地反折收拢、准备放进布草回收袋里的城宮明日香。"),
    ("al1b_003", "narrator", "cap_smile", "哪怕刚在无影灯底下稳稳举了近一个钟头的拉钩，她的额角也只渗出一层极薄的细汗，神情非但不见疲惫，反而比早上在行政走廊里撞见时还要神采飞扬。"),
    ("al1b_004", "player", "cap_smile", "「今天视野给得非常舒服，省了我不少工夫。不过我还是有点好奇——明明已经是管着整座医院的院长了，就算不去临床也没人会挑你的理，怎么还这么喜欢亲自跑来跟台？」"),
    ("al1b_005", "narrator", "cap_smile", "明日香把折整齐的旧手术袍放进回收袋里，拍了拍手，转过身迎上坂口的目光，理所当然地弯起唇角笑了笑。"),
    ("al1b_006", "actor", "cap_smile", "「因为就是单纯地喜欢呀。」"),
    ("al1b_007", "player", "cap_smile", "「我还以为你会借机跟我讲上一段『深入临床一线有助于优化医院管理决策』之类的院长发言。」"),
    ("al1b_008", "actor", "cap_smile", "「要是去市医师会做年度汇报，我肯定会那么写进稿子里的——了解一线确实很重要嘛。不过在刚一起下台的搭档面前，哪用得着把自己的喜好包装得那么伟大？我就只是喜欢手术室里的空气，喜欢看一台手术干干净净地做成而已。」"),
    ("al1b_009", "narrator", "cap_critique", "说到这里，明日香低头看了一眼布草袋里那件刚脱下来的院内标准款无菌手术袍，秀气的眉头忽然微不可察地蹙了一下，抬起手指在自己的肩侧与后腰位置比划了半寸。"),
    ("al1b_010", "actor", "cap_critique", "「就是有一点我一直想说……坂口医生刚才抬手打结的时候，有没有觉得这批标准手术袍的袖笼裁得稍微偏低了一点？而且后背第二根系带的位置也比理想比例往下掉了一寸，系紧以后整件袍子的肩背线条就显得松松垮垮的，不够利落。」"),
    ("al1b_011", "narrator", "cap_critique", "坂口隆司愣了两秒，低头看了看自己刚才同样穿了半天、却压根没留心过长成什么样的回收布草袋。"),
    ("al1b_012", "player", "cap_critique", "「……无菌手术袍只要不透水、不掉絮、尺寸合身不就行了？你刚在台上拉钩的时候，居然还有工夫注意手术袍的肩线和系带比例？」"),
    ("al1b_013", "actor", "cap_critique", "「什么叫『居然』呀！外科医生一上台少说也要穿一两个钟头，剪裁合不合身、抬手臂顺不顺畅，还有穿在身上整个人看起来专不专业、好不好看，本来就全都是正经学问好不好？」"),
    ("al1b_014", "narrator", "cap_critique", "她微扬起下巴，一本正经地替自己的审美标准辩护了两句，完全不觉得研究无菌服版型有什么稀奇。"),
    ("al1b_015", "player", "cap_smile", "「好好，算我外行了，院长。」"),
    ("al1b_016", "narrator", "cap_shy", "听到最后那两个字，正准备抬手摘手术帽的明日香动作忽然停了一下。她偏过头打量了坂口一眼，语气比刚才放轻了几分，带着一点年轻人特有的坦率与小小的别扭。"),
    ("al1b_017", "actor", "cap_shy", "「……那个，坂口医生。」"),
    ("al1b_018", "player", "cap_shy", "「嗯？还有哪台排班要交代？」"),
    ("al1b_019", "actor", "cap_shy", "「不是排班的事啦。就是……我们好歹也一起站过手术台、配合得这么熟了，私底下聊天的时候，你能不能别老是一口一个『院长』地叫我？」"),
    ("al1b_020", "player", "cap_shy", "「不叫院长？」"),
    ("al1b_021", "actor", "cap_shy", "「嗯。在全院大会或者外院来访的时候叫『院长』当然没办法，可平时连走个走廊、洗个手都听熟悉的人这么叫，总觉得像在跟长辈说话一样，我到现在都还有点不太习惯呢。」"),
    ("al1b_022", "narrator", "hair_down_smile", "她把手术帽摘下来，轻轻抖开柔顺的长发，眉眼明朗地看着坂口说道："),
    ("al1b_023", "actor", "hair_down_smile", "「没外人办公事的时候，你像医局里的前辈平辈那样叫我『城宮君』，或者干脆直接叫我『明日香』都可以哦。」"),
    ("al1b_024", "narrator", "hair_down_smile", "坂口隆司微微一怔，随即失笑点了点头。"),
    ("al1b_025", "player", "hair_down_smile", "「明白了。私底下我尽量改口叫『明日香』或者『城宮君』——不过平时在科室里听大家都这么喊惯了，万一哪天嘴快又顺口叫成了『院长』，你可别见怪。」"),
    ("al1b_026", "actor", "hair_down_smile", "「噗，那有什么好计较的，本来也不是给你下行政规定嘛。你叫得顺口就好，工作场合照旧叫院长也完全没问题！」"),
    ("al1b_027", "narrator", "hair_down_wave", "她把用过的手术帽丢进回收桶，脚步轻快地朝女更衣室的方向退开两步，回过头朝坂口挥了挥手，笑容干净而明快。"),
    ("al1b_028", "actor", "hair_down_wave", "「我去换回白大褂继续批剩下的件啦。下次有合适的手术需要第一助手，还记得叫我哦——回见啦，坂口君！」"),
]


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def build_nodes(beats: list[tuple[str, str, str | None, str]], final_label: str, final_effects: dict, final_flags: list[str]) -> list[dict]:
    nodes: list[dict] = []
    for i, (node_id, speaker, portrait_slot, text) in enumerate(beats):
        is_last = i == len(beats) - 1
        choice_id = f"finish_{node_id}" if is_last else f"continue_{node_id}"
        choice_label = final_label if is_last else "继续"
        node: dict = {
            "id": node_id,
            "presentation": "authored",
            "speaker": speaker,
            "speaker_label": SPEAKER_ZH[speaker],
            "expression": portrait_slot if portrait_slot is not None else "neutral",
            "text": text,
            "choices": [
                {
                    "id": choice_id,
                    "label": choice_label,
                    "next": "@end" if is_last else beats[i + 1][0],
                    "effects": final_effects if is_last else {"affection": 0, "familiarity": 0},
                    "flags": final_flags if is_last else [],
                }
            ],
        }
        if portrait_slot is None:
            node["hide_portrait"] = True
        else:
            node["event_portraits"] = [
                {
                    "id": "doc_asuka",
                    "path": PORTRAIT_PATHS[portrait_slot],
                    "x": 985,
                    "bottom": 556,
                    "width": 320,
                    "height": 480,
                }
            ]
        nodes.append(node)
    return nodes


def main() -> None:
    translations = json.loads((ROOT / "research/translations/asuka_lv1_en.json").read_text(encoding="utf-8"))

    # 1. Update data/staff/doc_asuka/profile.json
    profile_path = ROOT / "data/staff/doc_asuka/profile.json"
    profile = json.loads(profile_path.read_text(encoding="utf-8"))
    portraits = profile["visuals"]["portraits"]
    for slot, rel_path in PORTRAIT_PATHS.items():
        portraits[f"scrubs/{slot}"] = rel_path
    portraits["scrubs/smile"] = PORTRAIT_PATHS["hair_down_smile"]
    profile_path.write_text(json.dumps(profile, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # 2. Update data/staff/doc_asuka/relationship.json
    rel_file = ROOT / "data/staff/doc_asuka/relationship.json"
    rel_data = json.loads(rel_file.read_text(encoding="utf-8"))
    for slot in rel_data["rank_slots"]:
        if slot["target_level"] == 1:
            slot["event_id"] = "asuka_lv1_director_surgeon_postop"
            slot["content_status"] = "authored"
            slot["gate_event_id"] = "asuka_lv1_director_surgeon_preop"
    rel_file.write_text(json.dumps(rel_data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # 3. Build Scene 1 & Scene 3 events in data/staff/doc_asuka/events.json
    preop_event = {
        "id": "asuka_lv1_director_surgeon_preop",
        "actor_id": "doc_asuka",
        "title": "院长也是外科医生·刷手池前",
        "chapter": 1,
        "location_id": "or",
        "trigger_mode": "preop_stage",
        "preop_stage_id": "changing",
        "preop_required_flags": ["hands_ready"],
        "background_id": "scrub_area",
        "outfit": "scrubs",
        "minutes": 6,
        "teaser": "四楼手术部刷手池前，担任第一助手的明日香已经先一步开始刷手了。",
        "time_start": 0,
        "time_end": 1439,
        "priority": 180,
        "category": "contextual",
        "auto_start": True,
        "target_level": 1,
        "benefit_id": "",
        "gallery": {
            "cg_id": "asuka_lv1_director_surgeon_preop",
            "caption": "术前刷手池边，明日香举着沾满泡沫的小臂向主刀坂口轻快问候。",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 10,
            "required_events": ["intro_doc_asuka_director_office"],
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "charm",
                    "minimum": 10,
                }
            ],
        },
        "start": "al1a_001",
        "nodes": build_nodes(
            SCENE1_BEATS,
            "与明日香一同推门进入手术间",
            {"affection": 0, "familiarity": 0},
            ["asuka_lv1_preop_seen"],
        ),
    }

    postop_event = {
        "id": "asuka_lv1_director_surgeon_postop",
        "actor_id": "doc_asuka",
        "title": "院长也是外科医生",
        "chapter": 1,
        "location_id": "or",
        "trigger_mode": "preop_stage",
        "preop_stage_id": "post_surgery_return",
        "background_id": "or_entrance",
        "outfit": "scrubs",
        "minutes": 10,
        "teaser": "手术顺利结束后，在退更缓冲通道里与明日香聊起她对手术室与无菌服的执着。",
        "time_start": 0,
        "time_end": 1439,
        "priority": 220,
        "category": "bond",
        "auto_start": True,
        "target_level": 1,
        "benefit_id": "unlock_asuka_surgical_team",
        "completion_story_flags": [
            "asuka_lv1_complete",
            "asuka_lv1_director_surgeon_complete",
        ],
        "gallery": {
            "cg_id": "asuka_lv1_director_surgeon_postop",
            "caption": "同台手术结束后的缓冲通道里，摘下手术帽的明日香微笑着请坂口私下不必总叫她院长。",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 10,
            "required_events": [
                "intro_doc_asuka_director_office",
                "asuka_lv1_director_surgeon_preop",
            ],
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "charm",
                    "minimum": 10,
                }
            ],
        },
        "start": "al1b_001",
        "nodes": build_nodes(
            SCENE3_BEATS,
            "目送明日香轻快离开",
            {"affection": 2, "familiarity": 0},
            ["asuka_lv1_complete", "asuka_lv1_gown_tailoring_hint", "asuka_private_first_name_ok"],
        ),
    }

    events_path = ROOT / "data/staff/doc_asuka/events.json"
    events = json.loads(events_path.read_text(encoding="utf-8"))
    events = [
        e for e in events
        if e.get("id") not in {"asuka_lv1_director_surgeon_preop", "asuka_lv1_director_surgeon_postop"}
    ]
    events.extend([preop_event, postop_event])
    events_path.write_text(json.dumps(events, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # 4. Update data/localization/zh_CN.json and data/localization/en.json
    zh_path = ROOT / "data/localization/zh_CN.json"
    en_path = ROOT / "data/localization/en.json"
    zh = json.loads(zh_path.read_text(encoding="utf-8"))
    en = json.loads(en_path.read_text(encoding="utf-8"))
    zh_strings = zh["strings"]
    en_strings = en["strings"]

    for ev in (preop_event, postop_event):
        ev_id = ev["id"]
        en_ev = translations["events"][ev_id]
        base = f"collections.character_events.{ev_id}"
        zh_strings[f"{base}.title"] = ev["title"]
        en_strings[f"{base}.title"] = en_ev["title"]
        zh_strings[f"{base}.teaser"] = ev["teaser"]
        en_strings[f"{base}.teaser"] = en_ev["teaser"]
        zh_strings[f"{base}.gallery.caption"] = ev["gallery"]["caption"]
        en_strings[f"{base}.gallery.caption"] = en_ev["gallery_caption"]

        for i, node in enumerate(ev["nodes"]):
            nid = node["id"]
            is_last = i == len(ev["nodes"]) - 1
            nbase = f"{base}.nodes.{nid}"
            zh_strings[f"{nbase}.text"] = node["text"]
            en_strings[f"{nbase}.text"] = en_ev["nodes"][nid]
            zh_strings[f"{nbase}.speaker_label"] = node["speaker_label"]
            en_strings[f"{nbase}.speaker_label"] = SPEAKER_EN[node["speaker"]]
            choice = node["choices"][0]
            cid = choice["id"]
            zh_strings[f"{nbase}.choices.{cid}.label"] = choice["label"]
            en_strings[f"{nbase}.choices.{cid}.label"] = en_ev["final_choice"] if is_last else "Continue"

    zh_path.write_text(json.dumps(zh, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    en_path.write_text(json.dumps(en, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # 5. Update generation.json and import manifest
    gen_dir = ROOT / "research/generated_candidates/asuka_lv1_scrubs_v1"
    gen_manifest = {
        "actor_id": "doc_asuka",
        "event": "HOSHIMI_ASUKA_LV1_DIRECTOR_IS_ALSO_A_SURGEON_V1",
        "date": "2026-11-13",
        "stage1_bases": {
            "pose1_scrub_masked": "pose1_scrub_masked_base_raw.png",
            "pose2_scrub_cap_unmasked": "pose2_scrub_cap_unmasked_base_raw.png",
            "pose3_scrub_hair_down": "pose3_scrub_hair_down_base_raw.png",
        },
        "stage2_variants": {
            "masked_smile": "pose1_scrub_masked_smile_raw.jpg",
            "cap_critique": "pose2_scrub_cap_critique_raw.jpg",
            "cap_shy": "pose2_scrub_cap_shy_raw.jpg",
            "hair_down_wave": "pose3_scrub_hair_down_wave_raw.jpg",
        },
        "matted_outputs": {
            slot: {
                "path": rel_path,
                "sha256": sha256_of(ROOT / rel_path),
            }
            for slot, rel_path in PORTRAIT_PATHS.items()
        },
    }
    (gen_dir / "generation.json").write_text(json.dumps(gen_manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    import_record = {
        "date": "2026-11-13",
        "actor_id": "doc_asuka",
        "source_script": "research/source_scripts/HOSHIMI_ASUKA_LV1_DIRECTOR_IS_ALSO_A_SURGEON_V1.md",
        "source_script_sha256": sha256_of(ROOT / "research/source_scripts/HOSHIMI_ASUKA_LV1_DIRECTOR_IS_ALSO_A_SURGEON_V1.md"),
        "events": ["asuka_lv1_director_surgeon_preop", "asuka_lv1_director_surgeon_postop"],
        "approved_time_generalizations": [
            {
                "node_id": "al1a_003",
                "original": "「早呀，坂口医生。患者刚刚已经接进手术间核对信息了，器械台那边也清点得很顺利哦。」",
                "generalized": "「来得正好呀，坂口医生。患者刚刚已经接进手术间核对信息了，器械台那边也清点得很顺利哦。」",
            },
            {
                "node_id": "al1a_008",
                "original": "「哼哼，小看人了吧？急着要签的文件我今天早上八点前就全部批完发回行政科了，上午剩下的时间，日历上可是堂堂正正标着『临床外勤』四个大字的。」",
                "generalized": "「哼哼，小看人了吧？急着要签的文件我今天一早八点前就全部批完发回行政科了，眼下这段时间，日历上可是堂堂正正标着『临床外勤』四个大字的。」",
            },
            {
                "node_id": "al1b_028",
                "original": "「我去换回白大褂继续批下午的件啦。下次有合适的手术需要第一助手，还记得叫我哦——回见啦，坂口君！」",
                "generalized": "「我去换回白大褂继续批剩下的件啦。下次有合适的手术需要第一助手，还记得叫我哦——回见啦，坂口君！」",
            },
        ],
        "portraits": gen_manifest["matted_outputs"],
    }
    import_path = ROOT / "research/imports/asuka_lv1_2026-11-13.json"
    import_path.parent.mkdir(parents=True, exist_ok=True)
    import_path.write_text(json.dumps(import_record, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Imported Asuka Lv1: {len(SCENE1_BEATS)} preop beats + {len(SCENE3_BEATS)} postop beats + {len(PORTRAIT_PATHS)} RGBA portraits.")


if __name__ == "__main__":
    main()
