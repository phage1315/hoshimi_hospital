#!/usr/bin/env python3
"""Deterministic importer for Katagiri Ayako's 30-day return arc ("Hoshimi Hospital Story", V1.1).

Reads the 4 canonical V1.1 manuscripts from research/source_scripts/:
  1. HOSHIMI_AYAKO_RETURN_01_OPENING_V1_1.md   (Opening Scene A-D)
  2. HOSHIMI_AYAKO_RETURN_02_WEEK1_WEEK2_V1_1.md (Week 1 Scene 1A-1C + Week 2 Scene 2A-2B)
  3. HOSHIMI_AYAKO_RETURN_03_WEEK3_WEEK4_END_V1_1.md (Week 3 + Week 4 + Departure)
  4. HOSHIMI_AYAKO_RETURN_04_AMBIENT_POOL_V1_1.md (Ambient Encounters 01-10)

Outputs:
  - data/events/special_events/ayako_return.json (16 partial-day special events)
  - data/events/special_event_steps/ayako_return.json (16 authored step graphs)
  - Syncs data/localization/zh_CN.json and data/localization/en.json when research/translations/ayako_return_en.json exists.
"""

from __future__ import annotations

import argparse
import json
import re
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from staff_bundles import load_staff_bundles  # noqa: E402

VOL1 = ROOT / "research/source_scripts/HOSHIMI_AYAKO_RETURN_01_OPENING_V1_1.md"
VOL2 = ROOT / "research/source_scripts/HOSHIMI_AYAKO_RETURN_02_WEEK1_WEEK2_V1_1.md"
VOL3 = ROOT / "research/source_scripts/HOSHIMI_AYAKO_RETURN_03_WEEK3_WEEK4_END_V1_1.md"
VOL4 = ROOT / "research/source_scripts/HOSHIMI_AYAKO_RETURN_04_AMBIENT_POOL_V1_1.md"

OUT_EVENTS = ROOT / "data/events/special_events/ayako_return.json"
OUT_STEPS = ROOT / "data/events/special_event_steps/ayako_return.json"
EN_PACK = ROOT / "research/translations/ayako_return_en.json"
LOCALE_ZH = ROOT / "data/localization/zh_CN.json"
LOCALE_EN = ROOT / "data/localization/en.json"

CG_BADGE = "assets/events/character_events/rei/ayako_return/cg_01_nurse_badge.png"
CG_STORYBOARD = "assets/events/character_events/rei/ayako_return/cg_02_storyboard.png"

AYAKO_PORTRAITS = {
    "casual/neutral": "assets/characters/guest_ayako/casual/neutral.png",
    "casual/shocked": "assets/characters/guest_ayako/casual/shocked.png",
    "casual/warm_smile": "assets/characters/guest_ayako/casual/warm_smile.png",
    "nurse_observer/pre_badge": "assets/characters/guest_ayako/nurse_observer/pre_badge.png",
    "nurse_observer/cheerful": "assets/characters/guest_ayako/nurse_observer/cheerful.png",
    "nurse_observer/excited": "assets/characters/guest_ayako/nurse_observer/excited.png",
    "nurse_observer/curious": "assets/characters/guest_ayako/nurse_observer/curious.png",
    "nurse_observer/puzzled": "assets/characters/guest_ayako/nurse_observer/puzzled.png",
    "nurse_observer/protest_blush": "assets/characters/guest_ayako/nurse_observer/protest_blush.png",
    "nurse_observer/startled": "assets/characters/guest_ayako/nurse_observer/startled.png",
    "nurse_observer/idea_spark": "assets/characters/guest_ayako/nurse_observer/idea_spark.png",
    "nurse_observer/warm_smile": "assets/characters/guest_ayako/nurse_observer/warm_smile.png",
}

SPEAKER_INFO = {
    "坂口隆司": ("player", "", ""),
    "片桐彩子": ("actor", "story_guest_ayako", "nurse_observer"),
    "女患者": ("actor", "", ""),
    "深山佳織": ("actor", "doc_rei", "white_coat"),
    "藤崎詩織": ("actor", "doc_shiori", "white_coat"),
    "城宮明日香": ("actor", "doc_asuka", "director_suit"),
    "七瀬恋": ("actor", "nurse_haru", "uniform"),
    "朝倉美幸": ("actor", "nurse_yui", "uniform"),
    "石神千鹤": ("actor", "nurse_ishigami", "uniform"),
    "御堂江美子": ("actor", "doc_emiko", "white_coat"),
    "阿尔托莉雅": ("actor", "doc_artoria", "white_coat"),
    "水城阿库娅": ("actor", "doc_aqua", "white_coat"),
    "飯村真奈美": ("actor", "pharmacist_manami", "pharmacist"),
    "本庄萌恵": ("actor", "nurse_moe", "uniform"),
    "杉村弘子": ("actor", "nurse_hiroko", "uniform"),
    "岩崎留美": ("actor", "nurse_iwasaki_rumi", "uniform"),
    "米田栞": ("actor", "nurse_yoneda_shiori", "uniform"),
    "神宮寺成美": ("actor", "doc_aoi", "white_coat"),
    "南条小夜香": ("actor", "doc_sayaka", "white_coat"),
}

SUBJECT_PATTERNS: list[tuple[str, str]] = [
    ("坂口隆司", "坂口隆司"),
    ("片桐彩子", "片桐彩子"),
    ("深山佳織", "深山佳織"),
    ("藤崎詩織", "藤崎詩織"),
    ("城宮明日香", "城宮明日香"),
    ("七瀬恋", "七瀬恋"),
    ("朝倉美幸", "朝倉美幸"),
    ("石神千鹤", "石神千鹤"),
    ("御堂江美子", "御堂江美子"),
    ("阿尔托莉雅", "阿尔托莉雅"),
    ("外科副部长", "阿尔托莉雅"),
    ("水城阿库娅", "水城阿库娅"),
    ("飯村真奈美", "飯村真奈美"),
    ("本庄萌恵", "本庄萌恵"),
    ("杉村弘子", "杉村弘子"),
    ("岩崎留美", "岩崎留美"),
    ("米田栞", "米田栞"),
    ("神宮寺成美", "神宮寺成美"),
    ("南条小夜香", "南条小夜香"),
    ("女患者", "女患者"),
    ("萌恵", "本庄萌恵"),
    ("彩子", "片桐彩子"),
    ("明日香", "城宮明日香"),
    ("深山", "深山佳織"),
    ("藤崎", "藤崎詩織"),
    ("坂口", "坂口隆司"),
]


def load_staff_portraits() -> dict[str, dict[str, str]]:
    manifest = json.loads((ROOT / "data/manifest.json").read_text(encoding="utf-8"))
    cols, _ = load_staff_bundles(ROOT / "data", manifest["staff_bundles"])
    result: dict[str, dict[str, str]] = {"story_guest_ayako": dict(AYAKO_PORTRAITS)}
    for staff in cols["staff"]:
        result[staff["id"]] = dict(staff.get("visuals", {}).get("portraits", {}))
    return result


STAFF_PORTRAITS = load_staff_portraits()
PNG_SIZE_CACHE: dict[str, tuple[int, int]] = {}


def png_size(rel_path: str) -> tuple[int, int]:
    if rel_path not in PNG_SIZE_CACHE:
        full = ROOT / rel_path
        if not full.is_file():
            raise FileNotFoundError(f"Missing portrait/CG file: {rel_path}")
        with full.open("rb") as f:
            header = f.read(24)
        w, h = struct.unpack(">II", header[16:24])
        PNG_SIZE_CACHE[rel_path] = (w, h)
    return PNG_SIZE_CACHE[rel_path]


def strip_md_inline(text: str) -> str:
    s = re.sub(r"\*\*([^*]+)\*\*", r"\1", text)
    s = re.sub(r"\*([^*]+)\*", r"\1", s)
    return s


def infer_speaker(prefix: str, last_female_speaker: str) -> str:
    # Inspect the final sentence/semicolon segment first.
    tail = re.split(r"[。；]", prefix)[-1].strip()
    clauses = [c.strip() for c in tail.split("，") if c.strip()]
    # Skip subordinate "趁着…/目送…/看着…/被…/说着" lead-ins if a second clause names the actor.
    search_clauses = clauses
    if len(clauses) >= 2 and clauses[0].startswith(("趁着", "目送", "看着", "被", "说着", "三十秒一到", "话一出口")):
        search_clauses = clauses[1:] + clauses[:1]
    for clause in search_clauses:
        for token, canonical in SUBJECT_PATTERNS:
            idx = clause.find(token)
            if idx != -1 and idx <= 8:
                # Guard against object references like "对坂口感叹" or "朝坂口隆司淡然颔首" when another subject led.
                before = clause[:idx]
                if any(prep in before for prep in ("朝", "对", "向", "看", "替", "帮", "给", "和", "与", "跟")):
                    continue
                return canonical
        for token, canonical in SUBJECT_PATTERNS:
            if token in clause:
                idx = clause.find(token)
                before = clause[:idx]
                if any(prep in before for prep in ("朝", "对", "向", "看", "替", "帮", "给")):
                    continue
                return canonical
    if tail.startswith(("她", "说完，她")):
        if not last_female_speaker:
            raise ValueError(f"Cannot resolve pronoun speaker for prefix: {prefix}")
        return last_female_speaker
    raise ValueError(f"Could not infer speaker from prefix: {prefix!r}")


def extract_section(md: str, start_marker: str, end_marker: str | None) -> str:
    i = md.index(start_marker)
    j = md.index(end_marker, i + len(start_marker)) if end_marker else len(md)
    return md[i:j]


def parse_raw_blocks(section_md: str) -> list[str]:
    """Group consecutive non-blank lines into paragraphs/blockquotes while keeping headings/markers standalone."""
    blocks: list[str] = []
    buf: list[str] = []

    def flush() -> None:
        if buf:
            blocks.append("\n".join(buf))
            buf.clear()

    in_yaml = False
    for raw in section_md.splitlines():
        s = raw.strip()
        if s.startswith("```"):
            flush()
            in_yaml = not in_yaml
            continue
        if in_yaml:
            continue
        if not s:
            flush()
            continue
        if (
            s.startswith("#")
            or s == "---"
            or s.startswith("**【")
            or s.startswith("- **选项 ")
            or s.startswith("*性质：")
        ):
            flush()
            blocks.append(s)
            continue
        buf.append(s)
    flush()
    return blocks


def pick_ayako_expr(outfit: str, text: str, context_text: str) -> str:
    combined = text + " " + context_text
    if outfit == "casual":
        if any(k in combined for k in ("送、送给我", "睁大眼睛", "猛地一拍脑门")):
            return "shocked"
        if any(k in combined for k in ("太棒啦", "一言为定", "灿烂", "眉眼弯弯", "舍不得", "完全恢复啦")):
            return "warm_smile"
        return "neutral"
    if outfit == "nurse_observer_pre":
        return "pre_badge"
    # nurse_observer (with oversized badge)
    if any(
        k in combined
        for k in (
            "欲哭无泪",
            "大了一圈",
            "地狱笑话",
            "脸颊「腾」地一红",
            "黑历史",
            "涨红了脸",
            "心虚地小声嘀咕",
            "我擦、我今晚回去绝对擦干净",
            "红到了护士帽檐底下",
            "羞耻细节",
            "满脸通红",
            "捂着发烫的脸颊",
            "躲到藤崎詩織身后",
        )
    ):
        return "protest_blush"
    if any(
        k in combined
        for k in (
            "石、石神护士长好",
            "马上收",
            "魂飞魄散",
            "「呀！」",
            "在、在！！御堂医长",
            "吓、吓死我了",
            "浑身一激灵",
            "汗毛倒竖",
            "不、不是新护士",
            "吓了一跳",
            "后脑勺上长眼睛了吗",
            "什么时候绕到我后面来",
            "坂、坂口医生早安",
            "吓死我了……城宮院长",
        )
    ):
        return "startled"
    if any(
        k in combined
        for k in (
            "原来不能擦汗",
            "目瞪口呆",
            "怎么一眼看穿",
            "片桐彩子一愣",
            "「诶？」",
            "肩膀一垮",
            "小声嘟囔",
            "奇怪……袖带",
            "不是因为我违反取材规定",
            "愿意给我当场外医疗顾问吗",
            "哪里没洗干净吗",
            "给我的吗",
        )
    ):
        return "puzzled"
    if any(
        k in combined
        for k in (
            "越明白这部漫画该画什么了",
            "战友的笔记本",
            "太完美了",
            "纵深透视一下子全清楚了",
            "满眼星星",
            "眼底重新亮起了兴奋的光芒",
            "一点都不白酸",
            "四格素材",
        )
    ):
        return "idea_spark"
    if any(
        k in combined
        for k in (
            "Lucky",
            "正式驻院打扰啦",
            "第一批主要角色原型设定图",
            "拜托拜托嘛",
            "经典高光分镜",
            "大丰收",
            "太好了！连最冷静的坂口医生",
        )
    ):
        return "excited"
    if any(
        k in combined
        for k in (
            "挠了挠脸颊",
            "眉眼弯弯地轻声说道",
            "迎着三人的目光灿烂一笑",
            "先把早上那罐热咖啡",
            "摸了摸鼻尖",
            "捧着热罐子一脸感动",
            "夕阳余晖里",
            "声音比刚才放轻了几分",
            "交考卷前的紧张",
        )
    ):
        return "warm_smile"
    if any(
        k in combined
        for k in (
            "狂草速记",
            "静音滑轮",
            "小声嘀咕",
            "托着腮帮子",
            "野生动物直觉",
            "沙沙游走",
            "动态褶皱",
            "野生医生自然生态观察",
            "上半身努力往前探",
            "刷刷勾勒",
        )
    ):
        return "curious"
    return "cheerful"


def pick_staff_expr(actor_id: str, outfit: str, text: str, context_text: str) -> str:
    combined = text + " " + context_text
    avail = {
        k.split("/", 1)[1]
        for k in STAFF_PORTRAITS.get(actor_id, {})
        if k.startswith(outfit + "/")
    }

    def choose(*candidates: str) -> str:
        for c in candidates:
            if c in avail:
                return c
        return "neutral" if "neutral" in avail else sorted(avail)[0]

    if actor_id == "doc_rei":
        if any(k in combined for k in ("满意", "向上弯了一下", "画得很好", "对视了一眼")):
            return choose("smile", "neutral")
        if any(k in combined for k in ("冻住了", "怔了一秒", "顿在了嘴边")):
            return choose("surprised", "neutral")
        if any(k in combined for k in ("按了按眉心", "揉了揉太阳穴", "怀念她老老实实")):
            return choose("tired", "neutral")
        if any(
            k in combined
            for k in (
                "绷直",
                "眼神一凛",
                "冷冷",
                "皱",
                "警觉",
                "青筋",
                "涂掉",
                "我听见了",
                "微凛",
            )
        ):
            return choose("serious", "neutral")
        return choose("neutral")

    if actor_id == "doc_shiori":
        if any(k in combined for k in ("脸色微变", "吓了一跳", "一怔")):
            return choose("worried", "neutral")
        if any(
            k in combined
            for k in (
                "笑",
                "眉眼微弯",
                "眉眼自然地弯",
                "忍俊不禁",
                "柔和",
                "温柔",
                "惊喜",
            )
        ):
            return choose("smile", "neutral")
        return choose("neutral")

    if actor_id == "doc_asuka":
        if any(k in combined for k in ("惊讶",)):
            return choose("surprised", "neutral")
        if any(k in combined for k in ("笑", "唇角微扬", "弯起眼睛", "满意", "眨了眨眼")):
            return choose("smile", "warm", "neutral")
        return choose("neutral")

    if actor_id in ("nurse_haru", "nurse_yui"):
        if any(k in combined for k in ("笑", "弯起", "忍俊不禁", "温和")):
            return choose("smile", "neutral")
        if any(k in combined for k in ("站直身子", "核对")):
            return choose("serious", "neutral")
        return choose("neutral")

    if actor_id == "nurse_ishigami":
        if any(k in combined for k in ("扫过", "停顿", "落向")):
            return choose("observing", "serious", "neutral")
        return choose("serious", "neutral")

    if actor_id == "doc_emiko":
        if any(k in combined for k in ("似笑非笑", "勾起一抹")):
            return choose("smile", "neutral")
        return choose("serious", "neutral")

    if actor_id == "doc_artoria":
        if any(k in combined for k in ("温和地提醒",)):
            return choose("smile", "neutral")
        return choose("serious", "neutral")

    if actor_id == "doc_aqua":
        if any(k in combined for k in ("遗憾地鼓起腮帮子",)):
            return choose("troubled", "worried", "neutral")
        if any(k in combined for k in ("亮了起来", "恍然大悟", "观摩")):
            return choose("excited", "joyful", "smile", "neutral")
        return choose("smile", "neutral")

    if actor_id == "pharmacist_manami":
        if any(k in combined for k in ("打趣", "促狭", "封口费")):
            return choose("pharm_playful", "pharm_smile", "neutral")
        if any(k in combined for k in ("笑", "眉眼弯弯")):
            return choose("pharm_bright", "pharm_smile", "neutral")
        return choose("pharm_smile", "neutral")

    if actor_id == "nurse_moe":
        if any(k in combined for k in ("耳根一红", "脸颊微红", "不好意思")):
            return choose("shy", "embarrassed", "smile")
        if any(k in combined for k in ("眼睛亮晶晶", "鼓起勇气")):
            return choose("cheerful", "warm", "smile")
        return choose("worried", "neutral")

    if actor_id == "nurse_hiroko":
        if any(k in combined for k in ("笑", "温和")):
            return choose("smile", "closed_eye_smile", "neutral")
        return choose("neutral")

    if actor_id == "nurse_iwasaki_rumi":
        if any(k in combined for k in ("哈哈一笑", "眉开眼笑")):
            return choose("closed_eye_smile", "smile", "neutral")
        return choose("smile", "neutral")

    if actor_id == "nurse_yoneda_shiori":
        if any(k in combined for k in ("红透", "结结巴巴", "红着耳根")):
            return choose("worried", "neutral")
        if any(k in combined for k in ("亮晶晶",)):
            return choose("smile", "neutral")
        return choose("neutral")

    if actor_id == "doc_aoi":
        if any(k in combined for k in ("唇角微弯", "挺准的")):
            return choose("smile", "neutral")
        return choose("neutral")

    if actor_id == "doc_sayaka":
        if any(k in combined for k in ("坏笑", "狡黠", "相当不错嘛")):
            return choose("teasing", "smile", "neutral")
        return choose("smile", "warm", "neutral")

    return choose("neutral")


def build_event_portraits(
    visible_cast: list[tuple[str, str]],
    active_actor: str,
    text: str,
    context_text: str,
) -> list[dict]:
    """Build up to 3 calibrated event_portraits entries so proportions match across 1024x1536 and 1159x1358 packs."""
    if not visible_cast:
        return []
    selected = list(visible_cast)
    if len(selected) > 3:
        # Keep Ayako (if present), active_actor (if present), and the most relevant companions up to 3.
        keep: list[tuple[str, str]] = []
        for item in selected:
            if item[0] == "story_guest_ayako" or item[0] == active_actor:
                keep.append(item)
        for item in selected:
            if len(keep) >= 3:
                break
            if item not in keep:
                keep.append(item)
        # Preserve original left-to-right staging order.
        selected = [item for item in selected if item in keep][:3]

    # If a pair mixes 1024x1536 and 1159x1358, place the wider 1159x1358 sprite on the right slot (x=1085)
    # so its container stays well clear of the choice button area (x<=715).
    if len(selected) == 2:
        p0_map = STAFF_PORTRAITS[selected[0][0]]
        o0 = "nurse_observer" if selected[0][1] == "nurse_observer_pre" else selected[0][1]
        sample0 = next(v for k, v in p0_map.items() if k.startswith(o0 + "/"))
        w0, _ = png_size(sample0)
        p1_map = STAFF_PORTRAITS[selected[1][0]]
        o1 = "nurse_observer" if selected[1][1] == "nurse_observer_pre" else selected[1][1]
        sample1 = next(v for k, v in p1_map.items() if k.startswith(o1 + "/"))
        w1, _ = png_size(sample1)
        if w0 > 1100 and w1 <= 1100:
            selected = [selected[1], selected[0]]

    count = len(selected)
    xs_by_count = {
        1: [985],
        2: [840, 1090],
        3: [790, 965, 1140],
    }[count]

    out: list[dict] = []
    for idx, (actor_id, outfit_tag) in enumerate(selected):
        focus_text = text if actor_id == active_actor else ""
        focus_ctx = context_text if (actor_id == active_actor or not active_actor) else ""
        if actor_id == "story_guest_ayako":
            expr = pick_ayako_expr(outfit_tag, focus_text or text, focus_ctx or context_text)
            real_outfit = "nurse_observer" if outfit_tag == "nurse_observer_pre" else outfit_tag
            rel_path = AYAKO_PORTRAITS[f"{real_outfit}/{expr}"]
        else:
            expr = pick_staff_expr(actor_id, outfit_tag, focus_text, focus_ctx)
            rel_path = STAFF_PORTRAITS[actor_id][f"{outfit_tag}/{expr}"]

        pw, _ph = png_size(rel_path)
        is_wide = pw > 1100
        if count == 1:
            width, height, bottom = (485, 555, 695) if is_wide else (330, 475, 625)
        elif count == 2:
            width, height, bottom = (465, 535, 695) if is_wide else (305, 445, 615)
        else:
            width, height, bottom = (425, 490, 690) if is_wide else (280, 410, 610)

        out.append(
            {
                "id": actor_id,
                "path": rel_path,
                "x": xs_by_count[idx],
                "width": width,
                "height": height,
                "bottom": bottom,
            }
        )
    return out


def compile_event_step(
    *,
    step_id: str,
    step_title: str,
    prefix_code: str,
    section_md: str,
    default_bg: str,
    default_clock: int,
    scene_configs: dict[str, tuple[str, int, list[tuple[str, str]]]],
    cast_transitions: list[tuple[str, list[tuple[str, str]]]],
    cg_spans: list[tuple[str, str, str]] | None = None,
) -> dict:
    """ deterministically parse a markdown event section into a special_event_step dict."""
    blocks = parse_raw_blocks(section_md)
    nodes: list[dict] = []
    scene_schedule: dict[str, dict[str, int]] = {}

    cur_scene = next(iter(scene_configs.keys()))
    cur_bg, cur_clock, cur_cast = (
        scene_configs[cur_scene][0],
        scene_configs[cur_scene][1],
        list(scene_configs[cur_scene][2]),
    )
    active_cg = ""
    cg_spans = cg_spans or []

    mode = "main"  # main | choice_A | choice_B | cond_serika | cond_minato | shiori_4 | shiori_3
    last_main: dict | None = None
    last_branch: dict[str, dict | None] = {
        "choice_A": None,
        "choice_B": None,
        "cond_serika": None,
        "cond_minato": None,
        "shiori_4": None,
        "shiori_3": None,
    }
    first_branch: dict[str, str] = {}
    branch_nodes: dict[str, list[dict]] = {
        "cond_serika": [],
        "cond_minato": [],
        "shiori_4": [],
        "shiori_3": [],
    }
    choice_host: dict | None = None
    choice_labels: list[str] = []
    awaiting_choice_merge = False
    awaiting_cond_merge = False
    last_female_speaker = ""
    pending_context = ""

    def link(prev: dict | None, target_id: str) -> None:
        if prev is not None and not prev["choices"]:
            prev["choices"] = [
                {
                    "id": f"continue_{prev['id']}",
                    "label": "继续",
                    "next": target_id,
                    "requirements": [],
                }
            ]

    def emit_node(speaker_name: str, raw_text: str, force_hide_portrait: bool = False) -> dict:
        nonlocal last_main, awaiting_choice_merge, awaiting_cond_merge, last_female_speaker, active_cg

        clean_text = strip_md_inline(raw_text)

        # Apply cast transitions triggered on or before this beat's text
        for trigger_substr, new_cast in cast_transitions:
            if trigger_substr in clean_text:
                cur_cast[:] = list(new_cast)

        # Apply CG span start
        for start_sub, _end_sub, cg_file in cg_spans:
            if start_sub in clean_text:
                active_cg = cg_file

        idx = len(nodes) + 1
        node_id = f"{prefix_code}_{idx:03d}"
        scene_schedule[node_id] = {"clock": cur_clock}

        if speaker_name == "旁白":
            sp_kind, act_id, outfit = ("narrator", "", "")
        else:
            sp_kind, act_id, outfit = SPEAKER_INFO[speaker_name]
            if speaker_name != "坂口隆司":
                last_female_speaker = speaker_name

        # Determine active actor expression for schema required `expression` field
        ayako_outfit_in_cast = next((o for a, o in cur_cast if a == "story_guest_ayako"), "nurse_observer")
        if act_id == "story_guest_ayako":
            expr = pick_ayako_expr(ayako_outfit_in_cast, clean_text, pending_context)
        elif act_id:
            expr = pick_staff_expr(act_id, outfit, clean_text, pending_context)
        else:
            expr = "neutral"

        node: dict = {
            "id": node_id,
            "presentation": "authored",
            "speaker": sp_kind,
            "text": clean_text,
            "expression": expr,
            "background_id": cur_bg,
            "choices": [],
        }
        if speaker_name != "旁白":
            node["speaker_label"] = speaker_name
        if act_id and act_id != "story_guest_ayako":
            node["actor_id"] = act_id
            node["outfit"] = outfit

        if active_cg:
            node["cg_path"] = active_cg
            node["cg_fit"] = "cover"
            node["hide_portrait"] = True
            node["event_portraits"] = []
        elif force_hide_portrait or not cur_cast:
            node["hide_portrait"] = True
            node["event_portraits"] = []
        else:
            # Ensure speaking staff character is temporarily included if in room (e.g. Week 2 Serika/Minato not in room, Emiko/Artoria are)
            portraits = build_event_portraits(cur_cast, act_id, clean_text, pending_context)
            node["hide_portrait"] = False
            node["event_portraits"] = portraits

        # End CG span AFTER rendering the end beat
        for _start_sub, end_sub, cg_file in cg_spans:
            if active_cg == cg_file and end_sub in clean_text:
                active_cg = ""

        # Attach requirements for conditional modes
        if mode == "cond_serika":
            node["requirements"] = [{"type": "staff_unlocked", "actor_id": "doc_serika"}]
            branch_nodes["cond_serika"].append(node)
        elif mode == "cond_minato":
            node["requirements"] = [{"type": "staff_unlocked", "actor_id": "doc_minato"}]
            branch_nodes["cond_minato"].append(node)
        elif mode == "shiori_4":
            node["requirements"] = [{"type": "relationship_level", "actor_id": "doc_shiori", "minimum": 4}]
            branch_nodes["shiori_4"].append(node)
        elif mode == "shiori_3":
            branch_nodes["shiori_3"].append(node)

        nodes.append(node)

        # Graph wiring
        if mode in ("choice_A", "choice_B"):
            slot = 0 if mode == "choice_A" else 1
            if choice_host is None or len(choice_host["choices"]) != 2:
                raise ValueError(f"Choice mode {mode} without host at {node_id}")
            if not choice_host["choices"][slot]["next"]:
                choice_host["choices"][slot]["next"] = node_id
            link(last_branch[mode], node_id)
            last_branch[mode] = node
            return node

        if mode in ("cond_serika", "cond_minato"):
            if mode not in first_branch:
                first_branch[mode] = node_id
                if mode == "cond_serika":
                    link(last_main, node_id)
                elif mode == "cond_minato":
                    if last_branch["cond_serika"] is not None:
                        link(last_branch["cond_serika"], node_id)
                    else:
                        link(last_main, node_id)
            else:
                link(last_branch[mode], node_id)
            last_branch[mode] = node
            return node

        if mode == "shiori_4":
            if "shiori_4" not in first_branch:
                first_branch["shiori_4"] = node_id
                link(last_main, node_id)
            else:
                link(last_branch["shiori_4"], node_id)
            last_branch["shiori_4"] = node
            return node

        if mode == "shiori_3":
            if "shiori_3" not in first_branch:
                first_branch["shiori_3"] = node_id
            else:
                link(last_branch["shiori_3"], node_id)
            last_branch["shiori_3"] = node
            return node

        # mode == "main"
        if awaiting_choice_merge:
            link(last_branch["choice_A"], node_id)
            link(last_branch["choice_B"], node_id)
            last_branch["choice_A"] = None
            last_branch["choice_B"] = None
            awaiting_choice_merge = False
        elif awaiting_cond_merge:
            if last_branch["cond_minato"] is not None:
                link(last_branch["cond_minato"], node_id)
            elif last_branch["cond_serika"] is not None:
                link(last_branch["cond_serika"], node_id)
            else:
                link(last_main, node_id)
            # Fill fallback_next on conditional snippets
            minato_entry = first_branch.get("cond_minato", node_id)
            for cn in branch_nodes["cond_serika"]:
                cn["fallback_next"] = minato_entry
            for cn in branch_nodes["cond_minato"]:
                cn["fallback_next"] = node_id
            awaiting_cond_merge = False
        else:
            link(last_main, node_id)
        last_main = node
        return node

    in_visible_body = False
    for block in blocks:
        if block.startswith("## 【Scene "):
            m_sc = re.match(r"^## 【(Scene [0-9A-Z]+)", block)
            if m_sc and m_sc.group(1) in scene_configs:
                cur_scene = m_sc.group(1)
                cur_bg, cur_clock, scene_cast = scene_configs[cur_scene]
                cur_cast = list(scene_cast)
                in_visible_body = False
                if awaiting_choice_merge:
                    # Merge happens on the first beat of the next scene!
                    pass
            continue

        if block.startswith("## 【Ambient "):
            in_visible_body = False
            continue

        if block == "**【玩家可见正文】**":
            in_visible_body = True
            continue

        if not in_visible_body:
            continue

        if block == "---":
            if mode in ("choice_A", "choice_B"):
                # Wait for explicit Option B or merge/next scene
                pass
            continue

        if block.startswith("*性质："):
            continue

        if block.startswith("**【选择："):
            choice_host = last_main
            choice_labels = []
            continue

        if block.startswith("- **选项 "):
            m_opt = re.match(r"^- \*\*选项 [AB]：(「.+」)\*\*$", block)
            if not m_opt or choice_host is None:
                raise ValueError(f"Malformed choice option in {step_id}: {block}")
            choice_labels.append(m_opt.group(1))
            if len(choice_labels) == 2:
                choice_host["choices"] = [
                    {
                        "id": f"choice_{choice_host['id']}_{i + 1}",
                        "label": lbl,
                        "next": "",
                        "requirements": [],
                    }
                    for i, lbl in enumerate(choice_labels)
                ]
            continue

        if block == "**【选项 A 回应】**":
            mode = "choice_A"
            continue
        if block == "**【选项 B 回应】**":
            mode = "choice_B"
            continue
        if block in ("**【主线汇合收尾】**", "**【主线收束与轻量高关系微差分】**"):
            mode = "main"
            awaiting_choice_merge = True
            continue

        # Scene transition directly after Option B (Opening Scene A -> Scene B, Week 1 Scene 1B -> Scene 1C)
        if mode == "choice_B" and last_branch["choice_B"] is not None and block.startswith("**【"):
            pass

        if block.startswith("**【条件附加段落 A："):
            mode = "cond_serika"
            continue
        if block.startswith("**【条件附加段落 B："):
            mode = "cond_minato"
            continue
        if block == "**【主线继续】**":
            mode = "main"
            awaiting_cond_merge = True
            continue

        if block.startswith("**【条件分支：当 `relationship_shiori >= 4`"):
            mode = "shiori_4"
            continue
        if block.startswith("**【条件分支：当 `relationship_shiori == 3`"):
            mode = "shiori_3"
            continue

        # Skip closing system banner lines like **【回访开场事件结束｜...】**
        if block.startswith("**【") and block.endswith("】**"):
            continue

        # If we just entered a new scene right after choice_B without an explicit 主线汇合 header:
        if mode == "choice_B" and cur_scene in ("Scene B", "Scene 1C") and last_branch["choice_B"] is not None:
            # Wait: check if we already switched scenes!
            pass

        # Blockquote handling (`> ...`)
        if block.startswith(">"):
            bq_lines = [re.sub(r"^>\s*", "", ln).strip() for ln in block.splitlines()]
            pending_context = ""
            emit_node("旁白", "\n".join(bq_lines))
            continue

        # Multi-line non-blockquote paragraph (e.g. Week 2B L328-330)
        if "\n" in block:
            joined = "\n".join(ln.strip() for ln in block.splitlines())
            pending_context = ""
            emit_node("旁白", joined)
            continue

        # Unprefixed standalone quote lines
        if block == "「——当·然·是回来继续画漫画啦！！」":
            pending_context = "元气满满门外"
            emit_node("片桐彩子", block, force_hide_portrait=True)
            pending_context = ""
            continue
        if block in ("「唰啦。」", "「咔哒、哐当。」"):
            pending_context = ""
            emit_node("旁白", block)
            continue

        # Direct speaker line: `Speaker：「Quote」`
        m_direct = re.match(r"^([^：「」\s]+)：(「.+」)$", block)
        if m_direct and m_direct.group(1) in SPEAKER_INFO:
            emit_node(m_direct.group(1), m_direct.group(2))
            pending_context = ""
            continue

        # Mixed action/whisper prefix + trailing spoken quote: `Prefix：「Quote」`
        # Note: use `「[^「」]+」$` or allow nested `『...』` inside `「...」`!
        m_mixed = re.match(r"^(.+?)：(「[^「」]+」)$", block)
        if m_mixed:
            prefix_part, quote_part = m_mixed.group(1), m_mixed.group(2)
            inferred = infer_speaker(strip_md_inline(prefix_part), last_female_speaker)
            pending_context = strip_md_inline(prefix_part)
            emit_node("旁白", prefix_part + "：")
            emit_node(inferred, quote_part)
            pending_context = ""
            continue

        # Pure narration paragraph
        pending_context = strip_md_inline(block)
        emit_node("旁白", block)

    # Finalize terminal choices (`@day_end`)
    if branch_nodes["shiori_4"] and branch_nodes["shiori_3"]:
        shiori_3_start = first_branch["shiori_3"]
        for sn in branch_nodes["shiori_4"]:
            sn["fallback_next"] = shiori_3_start
        branch_nodes["shiori_4"][-1]["choices"] = [
            {
                "id": f"finish_{branch_nodes['shiori_4'][-1]['id']}",
                "label": "结束今日取材记录",
                "next": "@day_end",
                "requirements": [],
            }
        ]
        branch_nodes["shiori_3"][-1]["choices"] = [
            {
                "id": f"finish_{branch_nodes['shiori_3'][-1]['id']}",
                "label": "结束今日取材记录",
                "next": "@day_end",
                "requirements": [],
            }
        ]
    else:
        if not nodes:
            raise ValueError(f"No nodes parsed for {step_id}")
        nodes[-1]["choices"] = [
            {
                "id": f"finish_{nodes[-1]['id']}",
                "label": "结束本段取材记录",
                "next": "@day_end",
                "requirements": [],
            }
        ]

    return {
        "id": step_id,
        "title": step_title,
        "background_id": default_bg,
        "start": nodes[0]["id"],
        "scene_schedule": scene_schedule,
        "nodes": nodes,
    }


def fix_scene_boundary_choice_merges(md: str) -> str:
    """Insert internal merge marker when a Scene header immediately follows an Option B response block."""
    # In Opening (Scene A -> Scene B) and Week 1 (Scene 1B -> Scene 1C), Option B merges straight into the next Scene.
    return re.sub(
        r"(\*\*【选项 B 回应】\*\*[\s\S]*?\n---\n\n)(## 【Scene (?:B|1C) )",
        r"\1**【主线汇合收尾】**\n\n\2",
        md,
    )


def build_all() -> tuple[list[dict], list[dict]]:
    v1 = fix_scene_boundary_choice_merges(VOL1.read_text(encoding="utf-8"))
    v2 = fix_scene_boundary_choice_merges(VOL2.read_text(encoding="utf-8"))
    v3 = VOL3.read_text(encoding="utf-8")
    v4 = VOL4.read_text(encoding="utf-8")

    # Need to emit **【主线汇合收尾】** before ## 【Scene B / 1C while still inside visible body:
    # Actually in compile_event_step, ## 【Scene resets in_visible_body=False until **【玩家可见正文】**.
    # Putting **【主线汇合收尾】** right AFTER **【玩家可见正文】** of Scene B and Scene 1C merges choice_A & choice_B cleanly into Scene B / 1C's first node!
    v1 = v1.replace("**【主线汇合收尾】**\n\n## 【Scene B ", "## 【Scene B ").replace(
        "## 【Scene B — 她这次为什么回来：《星见医院物语（暂定）》】",
        "## 【Scene B — 她这次为什么回来：《星见医院物语（暂定）》】",
    )
    # Cleanest: inject `**【主线汇合收尾】**` right after `**【玩家可见正文】**` in Scene B (Vol 1) and Scene 1C (Vol 2)!
    v1 = re.sub(
        r"(## 【Scene B [^\n]+\n[\s\S]*?\*\*【玩家可见正文】\*\*\n)",
        r"\1\n**【主线汇合收尾】**\n",
        VOL1.read_text(encoding="utf-8"),
        count=1,
    )
    v2 = re.sub(
        r"(## 【Scene 1C [^\n]+\n[\s\S]*?\*\*【玩家可见正文】\*\*\n)",
        r"\1\n**【主线汇合收尾】**\n",
        VOL2.read_text(encoding="utf-8"),
        count=1,
    )

    steps: list[dict] = []

    # 1. OPENING
    sec_open = extract_section(v1, "## 【Scene A ", "# 三、 后续 30 天驻留")
    steps.append(
        compile_event_step(
            step_id="ayako_return_00_opening_main",
            step_title="她真的又来了",
            prefix_code="ayr00",
            section_md=sec_open,
            default_bg="staff_lounge",
            default_clock=540,
            scene_configs={
                "Scene A": ("staff_lounge", 540, [("doc_shiori", "white_coat")]),
                "Scene B": (
                    "staff_lounge",
                    545,
                    [
                        ("story_guest_ayako", "casual"),
                        ("doc_shiori", "white_coat"),
                        ("doc_rei", "white_coat"),
                    ],
                ),
                "Scene C": (
                    "director_office",
                    555,
                    [
                        ("doc_asuka", "director_suit"),
                        ("story_guest_ayako", "casual"),
                        ("doc_rei", "white_coat"),
                        ("doc_shiori", "white_coat"),
                    ],
                ),
                "Scene D": (
                    "director_office",
                    565,
                    [
                        ("story_guest_ayako", "nurse_observer_pre"),
                        ("doc_shiori", "white_coat"),
                        ("doc_asuka", "director_suit"),
                    ],
                ),
            },
            cast_transitions=[
                ("抱着一摞急诊留观夹路过门口的深山佳織", [("doc_shiori", "white_coat"), ("doc_rei", "white_coat")]),
                (
                    "只见门边探出一颗扎着标志性银紫色高束发的脑袋",
                    [
                        ("story_guest_ayako", "casual"),
                        ("doc_shiori", "white_coat"),
                        ("doc_rei", "white_coat"),
                    ],
                ),
                (
                    "看着她一溜烟钻进附属更衣间的背影",
                    [("doc_asuka", "director_suit"), ("doc_rei", "white_coat"), ("doc_shiori", "white_coat")],
                ),
                (
                    "对准彩子左胸口袋上方，「咔哒」一声稳稳夹好",
                    [
                        ("story_guest_ayako", "nurse_observer"),
                        ("doc_asuka", "director_suit"),
                        ("doc_rei", "white_coat"),
                        ("doc_shiori", "white_coat"),
                    ],
                ),
            ],
            cg_spans=[
                ("休息室里的坂口、深山与藤崎同时把目光投向了彩子的左胸口", "拿我的阑尾开地狱笑话对不对", CG_BADGE),
            ],
        )
    )

    # 2. WEEK 1
    sec_w1 = extract_section(v2, "## 【Scene 1A ", "# 第二部分：Week 2")
    steps.append(
        compile_event_step(
            step_id="ayako_return_01_week1_nurses_main",
            step_title="真正的护士工作",
            prefix_code="ayr01",
            section_md=sec_w1,
            default_bg="nurses_station",
            default_clock=810,
            scene_configs={
                "Scene 1A": (
                    "nurses_station",
                    810,
                    [
                        ("story_guest_ayako", "nurse_observer"),
                        ("nurse_haru", "uniform"),
                        ("nurse_yui", "uniform"),
                    ],
                ),
                "Scene 1B": (
                    "hallway",
                    885,
                    [
                        ("story_guest_ayako", "nurse_observer"),
                        ("nurse_haru", "uniform"),
                        ("nurse_yui", "uniform"),
                    ],
                ),
                "Scene 1C": (
                    "nurses_station",
                    930,
                    [
                        ("story_guest_ayako", "nurse_observer"),
                        ("nurse_haru", "uniform"),
                        ("nurse_yui", "uniform"),
                    ],
                ),
            },
            cast_transitions=[
                (
                    "看护部长石神千鹤手里夹着一份全院护理巡查夹",
                    [
                        ("nurse_ishigami", "uniform"),
                        ("story_guest_ayako", "nurse_observer"),
                        ("nurse_haru", "uniform"),
                        ("nurse_yui", "uniform"),
                    ],
                ),
                (
                    "直到那道冷艳挺拔的背影彻底消失在楼梯口",
                    [
                        ("story_guest_ayako", "nurse_observer"),
                        ("nurse_haru", "uniform"),
                        ("nurse_yui", "uniform"),
                    ],
                ),
            ],
        )
    )

    # 3. WEEK 2
    sec_w2 = extract_section(v2, "## 【Scene 2A ", "# 附：Codex 工程实装")
    steps.append(
        compile_event_step(
            step_id="ayako_return_02_week2_sketches_main",
            step_title="你们医院的人都很奇怪",
            prefix_code="ayr02",
            section_md=sec_w2,
            default_bg="staff_lounge",
            default_clock=1030,
            scene_configs={
                "Scene 2A": (
                    "staff_lounge",
                    1030,
                    [
                        ("story_guest_ayako", "nurse_observer"),
                        ("doc_shiori", "white_coat"),
                        ("doc_rei", "white_coat"),
                    ],
                ),
                "Scene 2B": (
                    "staff_lounge",
                    1045,
                    [
                        ("story_guest_ayako", "nurse_observer"),
                        ("doc_shiori", "white_coat"),
                        ("doc_rei", "white_coat"),
                    ],
                ),
            },
            cast_transitions=[
                (
                    "刚结束下午大手术巡查的外科医长御堂江美子迈步走了进来",
                    [
                        ("doc_emiko", "white_coat"),
                        ("doc_artoria", "white_coat"),
                        ("story_guest_ayako", "nurse_observer"),
                    ],
                ),
                (
                    "两人一前一后走出休息室大门",
                    [
                        ("story_guest_ayako", "nurse_observer"),
                        ("doc_shiori", "white_coat"),
                        ("doc_rei", "white_coat"),
                    ],
                ),
            ],
        )
    )

    # 4. WEEK 3
    sec_w3 = extract_section(v3, "## 【Scene 3A ", "# 第二部分：Week 4")
    steps.append(
        compile_event_step(
            step_id="ayako_return_03_week3_shiori_main",
            step_title="诗织，以前也是这样吗？",
            prefix_code="ayr03",
            section_md=sec_w3,
            default_bg="hospital_courtyard_evening",
            default_clock=1040,
            scene_configs={
                "Scene 3A": (
                    "hospital_courtyard_evening",
                    1040,
                    [("story_guest_ayako", "nurse_observer"), ("doc_shiori", "white_coat")],
                ),
                "Scene 3B": (
                    "hospital_courtyard_evening",
                    1045,
                    [("story_guest_ayako", "nurse_observer"), ("doc_shiori", "white_coat")],
                ),
            },
            cast_transitions=[
                ("银紫色的高束发与白色护士帽一晃一晃地消失在了长廊拐角", [("doc_shiori", "white_coat")]),
            ],
        )
    )

    # 5. WEEK 4
    sec_w4 = extract_section(v3, "## 【Scene 4A ", "# 第三部分：驻留结束离院事件")
    steps.append(
        compile_event_step(
            step_id="ayako_return_04_week4_storyboard_main",
            step_title="星见医院物语",
            prefix_code="ayr04",
            section_md=sec_w4,
            default_bg="staff_lounge",
            default_clock=1050,
            scene_configs={
                "Scene 4A": (
                    "staff_lounge",
                    1050,
                    [
                        ("story_guest_ayako", "nurse_observer"),
                        ("doc_shiori", "white_coat"),
                        ("doc_rei", "white_coat"),
                    ],
                ),
                "Scene 4B": (
                    "staff_lounge",
                    1055,
                    [
                        ("story_guest_ayako", "nurse_observer"),
                        ("doc_shiori", "white_coat"),
                        ("doc_rei", "white_coat"),
                    ],
                ),
            },
            cast_transitions=[],
            cg_spans=[
                ("预想中的无影灯、手术刀与惊悚大特写", "几双脱下无菌手套的手又重新聚回了自动贩卖机前", CG_STORYBOARD),
            ],
        )
    )

    # 6. DEPARTURE
    sec_dep = extract_section(v3, "## 【Scene 5A ", "# 附：Codex 工程实装")
    steps.append(
        compile_event_step(
            step_id="ayako_return_05_departure_main",
            step_title="留作纪念的胸牌",
            prefix_code="ayr05",
            section_md=sec_dep,
            default_bg="director_office",
            default_clock=540,
            scene_configs={
                "Scene 5A": (
                    "director_office",
                    540,
                    [
                        ("doc_asuka", "director_suit"),
                        ("story_guest_ayako", "casual"),
                        ("doc_rei", "white_coat"),
                        ("doc_shiori", "white_coat"),
                    ],
                ),
                "Scene 5B": (
                    "lobby",
                    555,
                    [
                        ("story_guest_ayako", "casual"),
                        ("doc_shiori", "white_coat"),
                        ("doc_rei", "white_coat"),
                    ],
                ),
            },
            cast_transitions=[
                ("汇入了门外熙攘的街景之中", [("doc_shiori", "white_coat"), ("doc_rei", "white_coat")]),
            ],
        )
    )

    # 7. AMBIENT 01 - 10
    ambient_defs = [
        (
            "ayako_amb_01_badge_reflex",
            "胸牌的标准使用方法",
            "amb01",
            "## 【Ambient 01 ",
            "## 【Ambient 02 ",
            "hallway",
            840,
            [("story_guest_ayako", "nurse_observer")],
            [],
            "location",
            "ward",
            ["PLAYER"],
        ),
        (
            "ayako_amb_02_gyn_danger_sense",
            "妇科走廊的危险直觉",
            "amb02",
            "## 【Ambient 02 ",
            "## 【Ambient 03 ",
            "gynecology_exam_room",
            840,
            [("story_guest_ayako", "nurse_observer")],
            [
                ("妇科主任水城阿库娅端着一只铺着无菌布的不锈钢器械托盘", [("story_guest_ayako", "nurse_observer"), ("doc_aqua", "white_coat")]),
            ],
            "location",
            "gynecology_exam",
            ["PLAYER", "doc_aqua"],
        ),
        (
            "ayako_amb_03_postop_vending_sketch",
            "下台五分钟的灵魂速写",
            "amb03",
            "## 【Ambient 03 ",
            "## 【Ambient 04 ",
            "or_entrance",
            1050,
            [("doc_rei", "white_coat")],
            [
                ("只见盆栽旁边的矮凳上", [("story_guest_ayako", "nurse_observer"), ("doc_rei", "white_coat")]),
                ("头也没回地往电梯口走去", [("story_guest_ayako", "nurse_observer")]),
            ],
            "after_work",
            "",
            ["PLAYER", "doc_rei"],
        ),
        (
            "ayako_amb_04_lightning_corridor",
            "自带背景闪电的走廊",
            "amb04",
            "## 【Ambient 04 ",
            "## 【Ambient 05 ",
            "hallway",
            545,
            [("story_guest_ayako", "nurse_observer")],
            [
                (
                    "左侧的外科医长御堂江美子身姿高挑",
                    [
                        ("doc_emiko", "white_coat"),
                        ("doc_artoria", "white_coat"),
                        ("story_guest_ayako", "nurse_observer"),
                    ],
                ),
                ("等到两位外科女强人的背影一前一后消失在走廊尽头", [("story_guest_ayako", "nurse_observer")]),
            ],
            "location",
            "ward",
            ["PLAYER", "doc_emiko", "doc_artoria"],
        ),
        (
            "ayako_amb_05_cool_drug_name",
            "听起来很厉害的药名",
            "amb05",
            "## 【Ambient 05 ",
            "## 【Ambient 06 ",
            "pharmacy",
            1025,
            [("story_guest_ayako", "nurse_observer"), ("pharmacist_manami", "pharmacist")],
            [
                ("看着干脆利落拉下窗口百叶帘准备下班的真奈美", [("story_guest_ayako", "nurse_observer")]),
            ],
            "after_work",
            "",
            ["PLAYER", "pharmacist_manami"],
        ),
        (
            "ayako_amb_06_two_thick_notebooks",
            "两本写满的笔记本",
            "amb06",
            "## 【Ambient 06 ",
            "## 【Ambient 07 ",
            "nurses_station",
            795,
            [("story_guest_ayako", "nurse_observer")],
            [
                ("刚核对完护理车路过的十八岁新人护士本庄萌恵", [("story_guest_ayako", "nurse_observer"), ("nurse_moe", "uniform")]),
                (
                    "正巧和坂口隆司一起走过来的杉村弘子",
                    [
                        ("story_guest_ayako", "nurse_observer"),
                        ("nurse_moe", "uniform"),
                        ("nurse_hiroko", "uniform"),
                    ],
                ),
            ],
            "location",
            "station",
            ["PLAYER", "nurse_moe", "nurse_hiroko"],
        ),
        (
            "ayako_amb_07_dynamic_uniform_folds",
            "动态衣褶的最佳模特",
            "amb07",
            "## 【Ambient 07 ",
            "## 【Ambient 08 ",
            "hallway",
            900,
            [
                ("story_guest_ayako", "nurse_observer"),
                ("nurse_iwasaki_rumi", "uniform"),
                ("nurse_yoneda_shiori", "uniform"),
            ],
            [],
            "location",
            "ward",
            ["PLAYER", "nurse_iwasaki_rumi", "nurse_yoneda_shiori"],
        ),
        (
            "ayako_amb_08_observed_observer",
            "逃不过法眼的观察者",
            "amb08",
            "## 【Ambient 08 ",
            "## 【Ambient 09 ",
            "staff_lounge",
            870,
            [
                ("story_guest_ayako", "nurse_observer"),
                ("doc_sayaka", "white_coat"),
                ("doc_aoi", "white_coat"),
            ],
            [],
            "location",
            "lounge",
            ["PLAYER", "doc_aoi", "doc_sayaka"],
        ),
        (
            "ayako_amb_09_director_uniform_audit",
            "院长大人的版型抽查",
            "amb09",
            "## 【Ambient 09 ",
            "## 【Ambient 10 ",
            "lobby",
            550,
            [("story_guest_ayako", "nurse_observer"), ("doc_asuka", "director_suit")],
            [],
            "location",
            "lobby",
            ["PLAYER", "doc_asuka"],
        ),
        (
            "ayako_amb_10_yellow_line_honor_student",
            "四楼黄线外的模范生",
            "amb10",
            "## 【Ambient 10 ",
            "# 三、 全四卷统合",
            "or_entrance",
            1035,
            [
                ("story_guest_ayako", "nurse_observer"),
                ("doc_shiori", "white_coat"),
                ("doc_rei", "white_coat"),
            ],
            [],
            "location",
            "or",
            ["PLAYER", "doc_rei", "doc_shiori"],
        ),
    ]

    for (
        amb_id,
        amb_title,
        pcode,
        s_mark,
        e_mark,
        bg,
        clk,
        init_cast,
        trans,
        _tmode,
        _loc,
        _req_chars,
    ) in ambient_defs:
        sec_amb = extract_section(v4, s_mark, e_mark)
        steps.append(
            compile_event_step(
                step_id=f"{amb_id}_main",
                step_title=amb_title,
                prefix_code=pcode,
                section_md=sec_amb,
                default_bg=bg,
                default_clock=clk,
                scene_configs={"Scene Amb": (bg, clk, init_cast)},
                cast_transitions=trans,
            )
        )

    # Build special_events list
    events: list[dict] = [
        {
            "id": "ayako_return_00_opening",
            "title": "她真的又来了",
            "category": "story_special_event",
            "duration_days": 1,
            "consumes_full_day": false_val(),
            "settled_minutes": 25,
            "cg_dialogue_delay_seconds": 1.0,
            "repeatable": False,
            "developer_only": False,
            "auto_schedule": True,
            "mandatory_auto_start": True,
            "trigger_mode": "day_start",
            "announcement": "半年前误入手术台的漫画家片桐彩子，正式向星见医院递交了三十天驻院取材申请。",
            "completion_hint": "片桐彩子已在星见医院开启为期 30 天的漫画取材驻留（Day 1 / 30）。后续每周固定取材事件与院内短偶遇将随日程自然推进。",
            "unlock_requirements": [
                {"type": "special_event_completed", "event_id": "miyama_02_manga_artist_wrong_patient"},
                {"type": "days_after_special_event", "event_id": "miyama_02_manga_artist_wrong_patient", "days": 180},
                {"type": "story_flag", "flag": "ayako_shiori_reconnected", "value": True},
                {"type": "relationship_level", "actor_id": "doc_rei", "minimum": 3},
                {"type": "relationship_level", "actor_id": "doc_shiori", "minimum": 3},
                {"type": "calendar_range", "start_date": "2025-04-01", "end_date": "2026-02-01"},
            ],
            "required_characters": ["PLAYER", "doc_rei", "doc_shiori", "doc_asuka"],
            "prerequisite_events": ["miyama_02_manga_artist_wrong_patient"],
            "event_chain": ["ayako_return_00_opening_main"],
            "completion_flags": [
                "ayako_return_opening_completed",
                "ayako_research_residency_active",
                "ayako_ambient_pool_enabled",
            ],
            "gallery_unlock": True,
            "gallery_entry": {
                "id": "ayako_return_00_opening",
                "title": "星见医院物语·她真的又来了",
                "chapters": ["完整回放"],
            },
            "timing": {
                "trigger_day": 185,
                "priority": 80,
                "final_week_allowed": False,
                "sunday_start_allowed": False,
            },
        },
        {
            "id": "ayako_return_01_week1_nurses",
            "title": "真正的护士工作",
            "category": "story_special_event",
            "duration_days": 1,
            "consumes_full_day": False,
            "settled_minutes": 20,
            "repeatable": False,
            "developer_only": False,
            "auto_schedule": False,
            "mandatory_auto_start": False,
            "trigger_mode": "location",
            "location_id": "station",
            "completion_hint": "片桐彩子完成了第一周的病栋护理跟班见学（Week 1 / 4）。",
            "unlock_requirements": [
                {"type": "story_flag", "flag": "ayako_research_residency_active", "value": True},
                {"type": "days_after_special_event", "event_id": "ayako_return_00_opening", "days": 5},
            ],
            "required_characters": ["PLAYER", "nurse_haru", "nurse_yui"],
            "prerequisite_events": ["ayako_return_00_opening"],
            "event_chain": ["ayako_return_01_week1_nurses_main"],
            "completion_flags": ["ayako_return_week1_completed"],
            "gallery_unlock": True,
            "gallery_entry": {
                "id": "ayako_return_01_week1_nurses",
                "title": "星见医院物语·真正的护士工作",
                "chapters": ["完整回放"],
            },
            "timing": {
                "trigger_day": 190,
                "priority": 80,
                "final_week_allowed": True,
                "sunday_start_allowed": False,
            },
        },
        {
            "id": "ayako_return_02_week2_sketches",
            "title": "你们医院的人都很奇怪",
            "category": "story_special_event",
            "duration_days": 1,
            "consumes_full_day": False,
            "settled_minutes": 25,
            "repeatable": False,
            "developer_only": False,
            "auto_schedule": False,
            "mandatory_auto_start": False,
            "trigger_mode": "after_work",
            "completion_hint": "片桐彩子的全院角色设定草图引发了一场外科双王抓包骚动，驻留取材推进至后半程（Week 2 / 4）。",
            "unlock_requirements": [
                {"type": "story_flag", "flag": "ayako_research_residency_active", "value": True},
                {"type": "special_event_completed", "event_id": "ayako_return_01_week1_nurses"},
                {"type": "days_after_special_event", "event_id": "ayako_return_00_opening", "days": 12},
            ],
            "required_characters": ["PLAYER", "doc_rei", "doc_shiori"],
            "prerequisite_events": ["ayako_return_01_week1_nurses"],
            "event_chain": ["ayako_return_02_week2_sketches_main"],
            "completion_flags": ["ayako_return_week2_completed"],
            "gallery_unlock": True,
            "gallery_entry": {
                "id": "ayako_return_02_week2_sketches",
                "title": "星见医院物语·你们医院的人都很奇怪",
                "chapters": ["完整回放"],
            },
            "timing": {
                "trigger_day": 197,
                "priority": 80,
                "final_week_allowed": True,
                "sunday_start_allowed": False,
            },
        },
        {
            "id": "ayako_return_03_week3_shiori",
            "title": "诗织，以前也是这样吗？",
            "category": "story_special_event",
            "duration_days": 1,
            "consumes_full_day": False,
            "settled_minutes": 20,
            "repeatable": False,
            "developer_only": False,
            "auto_schedule": False,
            "mandatory_auto_start": False,
            "trigger_mode": "after_work",
            "completion_hint": "傍晚中庭的一壶红茶，映照出藤崎詩織与学生时代截然不同的松弛变化（Week 3 / 4）。",
            "unlock_requirements": [
                {"type": "story_flag", "flag": "ayako_research_residency_active", "value": True},
                {"type": "special_event_completed", "event_id": "ayako_return_02_week2_sketches"},
                {"type": "days_after_special_event", "event_id": "ayako_return_00_opening", "days": 19},
            ],
            "required_characters": ["PLAYER", "doc_shiori"],
            "prerequisite_events": ["ayako_return_02_week2_sketches"],
            "event_chain": ["ayako_return_03_week3_shiori_main"],
            "completion_flags": ["ayako_return_week3_completed"],
            "gallery_unlock": True,
            "gallery_entry": {
                "id": "ayako_return_03_week3_shiori",
                "title": "星见医院物语·诗织，以前也是这样吗？",
                "chapters": ["完整回放"],
            },
            "timing": {
                "trigger_day": 204,
                "priority": 80,
                "final_week_allowed": True,
                "sunday_start_allowed": False,
            },
        },
        {
            "id": "ayako_return_04_week4_storyboard",
            "title": "星见医院物语",
            "category": "story_special_event",
            "duration_days": 1,
            "consumes_full_day": False,
            "settled_minutes": 25,
            "cg_dialogue_delay_seconds": 1.0,
            "repeatable": False,
            "developer_only": False,
            "auto_schedule": False,
            "mandatory_auto_start": False,
            "trigger_mode": "after_work",
            "completion_hint": "片桐彩子完成了《星见医院物语》第一话三十二页分镜初稿（Week 4 / 4）。三十天驻留即将迎来尾声。",
            "unlock_requirements": [
                {"type": "story_flag", "flag": "ayako_research_residency_active", "value": True},
                {"type": "special_event_completed", "event_id": "ayako_return_03_week3_shiori"},
                {"type": "days_after_special_event", "event_id": "ayako_return_00_opening", "days": 26},
            ],
            "required_characters": ["PLAYER", "doc_rei", "doc_shiori"],
            "prerequisite_events": ["ayako_return_03_week3_shiori"],
            "event_chain": ["ayako_return_04_week4_storyboard_main"],
            "completion_flags": ["ayako_return_week4_completed"],
            "gallery_unlock": True,
            "gallery_entry": {
                "id": "ayako_return_04_week4_storyboard",
                "title": "星见医院物语·第一话分镜",
                "chapters": ["完整回放"],
            },
            "timing": {
                "trigger_day": 211,
                "priority": 80,
                "final_week_allowed": True,
                "sunday_start_allowed": False,
            },
        },
        {
            "id": "ayako_return_05_departure",
            "title": "留作纪念的胸牌",
            "category": "story_special_event",
            "duration_days": 1,
            "consumes_full_day": False,
            "settled_minutes": 20,
            "repeatable": False,
            "developer_only": False,
            "auto_schedule": True,
            "mandatory_auto_start": True,
            "trigger_mode": "day_start",
            "announcement": "片桐彩子为期三十天的驻院取材期已满，今天她带着洗净熨平的护士制服前来院长室道别。",
            "completion_hint": "片桐彩子带着获赠留念的护士制服与特制大胸牌圆满离院，《星见医院物语》正式进入连载筹备阶段。",
            "unlock_requirements": [
                {"type": "story_flag", "flag": "ayako_research_residency_active", "value": True},
                {"type": "special_event_completed", "event_id": "ayako_return_04_week4_storyboard"},
                {"type": "days_after_special_event", "event_id": "ayako_return_00_opening", "days": 29},
            ],
            "required_characters": ["PLAYER", "doc_rei", "doc_shiori", "doc_asuka"],
            "prerequisite_events": ["ayako_return_04_week4_storyboard"],
            "event_chain": ["ayako_return_05_departure_main"],
            "completion_flags": [
                "ayako_return_departure_completed",
                "ayako_return_hoshimi_manga_completed",
                "ayako_research_residency_completed",
                "ayako_hospital_manga_project_started",
                "ayako_nurse_uniform_gifted",
                "ayako_research_badge_gifted",
                "ayako_finale_party_eligible",
            ],
            "gallery_unlock": True,
            "gallery_entry": {
                "id": "ayako_return_05_departure",
                "title": "星见医院物语·留作纪念的胸牌",
                "chapters": ["完整回放"],
            },
            "timing": {
                "trigger_day": 214,
                "priority": 80,
                "final_week_allowed": True,
                "sunday_start_allowed": False,
            },
        },
    ]

    for (
        amb_id,
        amb_title,
        _pcode,
        _s_mark,
        _e_mark,
        _bg,
        _clk,
        _init_cast,
        _trans,
        tmode,
        loc,
        req_chars,
    ) in ambient_defs:
        extra_reqs: list[dict] = [
            {"type": "story_flag", "flag": "ayako_research_residency_active", "value": True},
            {"type": "story_flag", "flag": "ayako_ambient_pool_enabled", "value": True},
        ]
        for ch in req_chars:
            if ch not in ("PLAYER", "doc_rei", "doc_shiori", "doc_asuka"):
                extra_reqs.append({"type": "staff_unlocked", "actor_id": ch})
        ev_obj: dict = {
            "id": amb_id,
            "title": amb_title,
            "category": "story_special_event",
            "duration_days": 1,
            "consumes_full_day": False,
            "settled_minutes": 15,
            "repeatable": False,
            "developer_only": False,
            "auto_schedule": False,
            "mandatory_auto_start": False,
            "trigger_mode": tmode,
            "unlock_requirements": extra_reqs,
            "required_characters": req_chars,
            "prerequisite_events": ["ayako_return_00_opening"],
            "event_chain": [f"{amb_id}_main"],
            "completion_flags": [f"{amb_id}_completed"],
            "gallery_unlock": True,
            "gallery_entry": {
                "id": amb_id,
                "title": f"取材随笔·{amb_title}",
                "chapters": ["完整回放"],
            },
            "timing": {
                "trigger_day": 186,
                "priority": 75,
                "final_week_allowed": True,
                "sunday_start_allowed": False,
            },
        }
        if tmode == "location":
            ev_obj["location_id"] = loc
        events.append(ev_obj)

    return events, steps


def false_val() -> bool:
    return False


TRANSLATABLE_FIELDS = {
    "title",
    "announcement",
    "completion_hint",
    "speaker_label",
    "text",
    "label",
    "chapters",
}
HAN_RE = re.compile(r"[\u3400-\u9fff]")


def collect_active_zh_strings(events: list[dict], steps: list[dict]) -> dict[str, str]:
    out: dict[str, str] = {}

    def walk(val: object, path: str) -> None:
        if isinstance(val, dict):
            for f, child in val.items():
                cp = f"{path}.{f}"
                if isinstance(child, str) and child.strip() and (f in TRANSLATABLE_FIELDS or HAN_RE.search(child)):
                    if f in TRANSLATABLE_FIELDS:
                        out[cp] = child
                walk(child, cp)
        elif isinstance(val, list):
            for i, child in enumerate(val):
                ident = str(child.get("id", i)) if isinstance(child, dict) else str(i)
                cp = f"{path}.{ident}"
                if isinstance(child, str) and child.strip() and path.rsplit(".", 1)[-1] in TRANSLATABLE_FIELDS:
                    out[cp] = child
                walk(child, cp)

    walk(events, "collections.special_events")
    walk(steps, "collections.special_event_steps")
    return out


def sync_locales(zh_entries: dict[str, str]) -> None:
    zh_doc = json.loads(LOCALE_ZH.read_text(encoding="utf-8"))
    en_doc = json.loads(LOCALE_EN.read_text(encoding="utf-8"))
    zh_strings: dict[str, str] = zh_doc["strings"]
    en_strings: dict[str, str] = en_doc["strings"]

    # Remove any stale keys from previous runs for ayako_return_* / ayako_amb_*
    for store in (zh_strings, en_strings):
        stale = [
            k
            for k in store
            if ".ayako_return_" in k or ".ayako_amb_" in k
        ]
        for k in stale:
            del store[k]

    zh_strings["ui.special_event.complete_evening"] = "%s 已完成。\n日期：%s  今日班表已结束"
    for k, v in zh_entries.items():
        zh_strings[k] = v

    if EN_PACK.is_file():
        en_pack = json.loads(EN_PACK.read_text(encoding="utf-8"))
        en_map: dict[str, str] = en_pack.get("strings", en_pack)
        en_strings["ui.special_event.complete_evening"] = en_map.get(
            "ui.special_event.complete_evening",
            "%s completed.\nDate: %s  Shift finished for today",
        )
        missing = []
        for k in zh_entries:
            if k in en_map and str(en_map[k]).strip():
                en_strings[k] = str(en_map[k])
            else:
                missing.append(k)
        if missing:
            print(f"WARNING: {len(missing)} English keys missing in {EN_PACK.name}")
    else:
        en_strings["ui.special_event.complete_evening"] = "%s completed.\nDate: %s  Shift finished for today"

    LOCALE_ZH.write_text(json.dumps(zh_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    LOCALE_EN.write_text(json.dumps(en_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dump-zh", type=Path, default=None, help="Write active Chinese key->source JSON to path")
    args = parser.parse_args()

    events, steps = build_all()
    OUT_EVENTS.write_text(json.dumps(events, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    OUT_STEPS.write_text(json.dumps(steps, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    zh_entries = collect_active_zh_strings(events, steps)
    if args.dump_zh is not None:
        args.dump_zh.parent.mkdir(parents=True, exist_ok=True)
        args.dump_zh.write_text(json.dumps(zh_entries, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    sync_locales(zh_entries)
    total_nodes = sum(len(s["nodes"]) for s in steps)
    print(f"Generated {len(events)} events, {len(steps)} steps, {total_nodes} nodes, {len(zh_entries)} locale keys.")
    for s in steps:
        print(f"  {s['id']:40s} -> {len(s['nodes']):3d} nodes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
