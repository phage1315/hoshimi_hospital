#!/usr/bin/env python3
"""Independent verbatim manuscript, 9-path graph, V1.1 revision, localization, and asset audit
for Emiko Mido (`doc_emiko`) Relationship Lv4 event:
《御堂江美子的秘密》 / *Emiko Mido's Secret* (`emiko_lv4_emikos_secret`, V1.1).
"""

from __future__ import annotations

import hashlib
import itertools
import json
import re
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT = ROOT / "research/source_scripts/HOSHIMI_MIDO_EMIKO_LV4_EMIKOS_SECRET_V1_1.md"
EN_JSON = ROOT / "research/translations/emiko_lv4_en.json"
EVENTS_JSON = ROOT / "data/staff/doc_emiko/lv4_events.json"
BUNDLE_JSON = ROOT / "data/staff/doc_emiko/bundle.json"
PROFILE_JSON = ROOT / "data/staff/doc_emiko/profile.json"
RELATIONSHIP_JSON = ROOT / "data/staff/doc_emiko/relationship.json"
BACKGROUNDS_JSON = ROOT / "data/backgrounds.json"
ZH_LOCALE = ROOT / "data/localization/zh_CN.json"
EN_LOCALE = ROOT / "data/localization/en.json"
MANIFEST_JSON = ROOT / "research/imports/emiko_lv4_2026-11-15.json"

EVENT_ID = "emiko_lv4_emikos_secret"
EXPECTED_MANUSCRIPT_SHA256 = "e8080bb45477d56bea8bdde4f3842ffb483b82810c4847848d9efab69f8ddca9"
CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\u3040-\u30ff\uf900-\ufaff]")
BRACE_RE = re.compile(r"\{[A-Za-z_][A-Za-z0-9_]*\}")

# V1.0 superseded strings & user-authorized V1.1 appearance/weekday revisions
FORBIDDEN_ZH = [
    "现在全院都知道，空着的外科主任位置最后就在我们几个人之间定下来。",
    "**",
    "挽得利落端正",
    "原本周四上午",
    "冷冽的乌眸",
    "乌黑的眼眸",
]

checks = 0
failures: list[str] = []


def require(cond: bool, label: str) -> None:
    global checks
    checks += 1
    if not cond:
        failures.append(label)


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def parse_manuscript_buckets(md_text: str) -> tuple[dict[str, list[tuple[str, str]]], dict[str, str]]:
    sec2 = md_text.split("## 二、 完整中文 VN 剧本正文", 1)[1].split("**【御堂江美子 Relationship Lv4《御堂江美子的秘密》事件结束】**", 1)[0]
    buckets: dict[str, list[tuple[str, str]]] = {
        k: []
        for k in (
            "s1",
            "s2",
            "s3",
            "c1a",
            "c1b",
            "c1c",
            "s3r",
            "s4",
            "c2a",
            "c2b",
            "c2c",
            "s4r",
            "s5",
            "s6_1",
            "s6_2",
        )
    }
    choices_zh: dict[str, str] = {}
    mixed_prefixes = [
        ("对侧配合跟线剪线的坂口隆司", "坂口隆司"),
        ("坂口隆司", "坂口隆司"),
        ("御堂江美子", "御堂江美子"),
        ("头侧的利根川安琪", "利根川安琪"),
        ("利根川安琪", "利根川安琪"),
        ("听见双人清点的口令声，躺在头架布帘后一直忍着没吭声的二十七岁女警樱井真弓", "樱井真弓"),
        ("樱井真弓", "樱井真弓"),
    ]

    cur = ""
    in_meta = False
    cur_choice = ""

    for raw in sec2.splitlines():
        s = raw.strip()
        if s.startswith("### 【第一幕"):
            cur = "s1"
            in_meta = True
            continue
        if s.startswith("### 【第二幕"):
            cur = "s2"
            in_meta = True
            continue
        if s.startswith("### 【第三幕"):
            cur = "s3"
            in_meta = True
            continue
        if s.startswith("### 【第四幕"):
            cur = "s4"
            in_meta = True
            continue
        if s.startswith("### 【第五幕"):
            cur = "s5"
            in_meta = True
            continue
        if s.startswith("### 【第六幕"):
            cur = "s6"
            in_meta = True
            continue
        if in_meta:
            if s == "**【玩家可见正文】**":
                in_meta = False
            continue
        if s.startswith("#### 6.1"):
            cur = "s6_1"
            continue
        if s.startswith("#### 6.2"):
            cur = "s6_2"
            continue
        if s.startswith("> **【语义接入点") or s.startswith("> - "):
            continue
        if not s or s == "---" or s.startswith("*性质："):
            continue
        m_ch = re.match(r"^\*\*【选择 (\d+)：.+】\*\*$", s)
        if m_ch:
            cur_choice = f"c{m_ch.group(1)}"
            continue
        m_opt = re.match(r"^- \*\*选项 ([ABC])：(.+)\*\*$", s)
        if m_opt:
            choices_zh[f"choice_em4_{cur_choice}_{m_opt.group(1).lower()}"] = m_opt.group(2)
            continue
        m_br = re.match(r"^#### 【分支 ([ABC]) — .+】$", s)
        if m_br:
            cur = f"{cur_choice}{m_br.group(1).lower()}"
            continue
        if s.startswith("> **【主线汇合"):
            cur = {"c1": "s3r", "c2": "s4r"}[cur_choice]
            continue

        s = s.replace("**", "")
        m_pure = re.match(r"^(御堂江美子|坂口隆司|杉村弘子|利根川安琪|樱井真弓)：(「.+」)$", s)
        if m_pure:
            buckets[cur].append((m_pure.group(1), m_pure.group(2)))
            continue
        if "：「" in s:
            act, quote = s.split("：", 1)
            spk = None
            for pfx, target in mixed_prefixes:
                if act.startswith(pfx):
                    spk = target
                    break
            require(spk is not None, f"Mapped mixed speaker line: {s!r}")
            buckets[cur].append(("旁白", act + "："))
            buckets[cur].append((spk or "旁白", quote))
            continue
        buckets[cur].append(("旁白", s))

    return buckets, choices_zh


def main() -> int:
    for p in (
        MANUSCRIPT,
        EN_JSON,
        EVENTS_JSON,
        BUNDLE_JSON,
        PROFILE_JSON,
        RELATIONSHIP_JSON,
        BACKGROUNDS_JSON,
        ZH_LOCALE,
        EN_LOCALE,
        MANIFEST_JSON,
    ):
        require(p.is_file(), f"Required file exists: {p.relative_to(ROOT)}")
    if failures:
        print("FATAL missing files:", failures)
        return 1

    require(sha256_of(MANUSCRIPT) == EXPECTED_MANUSCRIPT_SHA256, "Source manuscript V1.1 SHA-256 matches verbatim copy")

    md_text = MANUSCRIPT.read_text(encoding="utf-8")
    buckets, choices_zh = parse_manuscript_buckets(md_text)
    total_beats = sum(len(v) for v in buckets.values())
    require(total_beats == 267, f"Manuscript parses to 267 beats (got {total_beats})")
    require(len(choices_zh) == 6, f"Manuscript parses to 6 choice options (got {len(choices_zh)})")

    events = json.loads(EVENTS_JSON.read_text(encoding="utf-8"))
    require(isinstance(events, list) and len(events) == 1, "lv4_events.json contains exactly 1 event")
    ev = events[0]
    require(ev["id"] == EVENT_ID, f"Event ID is {EVENT_ID}")
    require(ev["title"] == "御堂江美子的秘密", "Event title matches V1.1 manuscript")
    require(ev["trigger_mode"] == "after_work", "Trigger mode is after_work")
    require(ev["target_level"] == 4 and ev["chapter"] == 4, "Target level & chapter are 4")
    require(ev["benefit_id"] == "unlock_intimacy_events", "Lv4 benefit_id is unlock_intimacy_events")
    require(ev["locks_saving"] is True and ev["hide_calendar_header"] is True, "Event locks saving and hides calendar header")
    require(ev["minutes"] == 0 and ev["completion_day_offset"] == 1 and ev["completion_absolute_clock"] == 540, "Next-day 09:00 atomic completion clock")
    require(ev["completion_story_flags"] == ["emiko_lv4_complete"], "Completion flag is emiko_lv4_complete (zero chief-yield flags)")
    require(
        ev["conditions"] == {
            "min_day": 1,
            "max_day": 363,
            "min_affection": 0,
            "min_familiarity": 55,
            "required_events": ["emiko_lv3_today_i_lead"],
            "days_after_required_events": 3,
            "special_requirements": [
                {"type": "player_attribute", "attribute": "presence", "minimum": 30},
            ],
        },
        "Event conditions match Gate Matrix + max_day 363 (final two days excluded)",
    )

    bundle = json.loads(BUNDLE_JSON.read_text(encoding="utf-8"))
    require("lv4_events.json" in bundle.get("additional_character_event_files", []), "bundle.json registers lv4_events.json")

    rel = json.loads(RELATIONSHIP_JSON.read_text(encoding="utf-8"))
    lv4_slots = [s for s in rel["rank_slots"] if s["target_level"] == 4]
    require(len(lv4_slots) == 1, "relationship.json has exactly one target_level 4 slot")
    slot4 = lv4_slots[0]
    require(slot4["event_id"] == EVENT_ID and slot4["content_status"] == "authored", "Lv4 rank_slot is authored and linked")
    require(
        slot4["min_familiarity"] == 55
        and slot4["cooldown_days"] == 3
        and slot4["benefit_id"] == "unlock_intimacy_events"
        and slot4["special_requirements"] == [{"type": "player_attribute", "attribute": "presence", "minimum": 30}],
        "Lv4 rank_slot gate matches event conditions",
    )

    nodes_by_id = {n["id"]: n for n in ev["nodes"]}
    require(len(nodes_by_id) == 269, f"Event has 269 nodes (267 authored + 2 choice nodes), got {len(nodes_by_id)}")
    require(nodes_by_id["em4_s6_1_24"].get("action") == "launch_emiko_lv4_h", "em4_s6_1_24 carries launch_emiko_lv4_h H Runner placeholder hook")

    # Verify all 6 interactive choice labels match verbatim
    for ch_node_id, prefix in (("em4_choice_c1", "choice_em4_c1_"), ("em4_choice_c2", "choice_em4_c2_")):
        ch_node = nodes_by_id[ch_node_id]
        require(ch_node["presentation"] == "choice" and ch_node["text"] == "", f"{ch_node_id} is a pure choice node")
        for opt in ch_node["choices"]:
            cid = opt["id"]
            require(opt["label"] == choices_zh[cid], f"Verbatim choice label for {cid}")
            require(opt["effects"] == {"affection": 0, "familiarity": 0} and opt["flags"] == [], f"Zero stat/flag delta on {cid}")

    # Exhaustive 9-path (3 x 3) traversal & character-for-character comparison against manuscript
    for c1, c2 in itertools.product(("a", "b", "c"), ("a", "b", "c")):
        expected_seq: list[tuple[str, str]] = []
        expected_seq.extend(buckets["s1"])
        expected_seq.extend(buckets["s2"])
        expected_seq.extend(buckets["s3"])
        expected_seq.extend(buckets[f"c1{c1}"])
        expected_seq.extend(buckets["s3r"])
        expected_seq.extend(buckets["s4"])
        expected_seq.extend(buckets[f"c2{c2}"])
        expected_seq.extend(buckets["s4r"])
        expected_seq.extend(buckets["s5"])
        expected_seq.extend(buckets["s6_1"])
        expected_seq.extend(buckets["s6_2"])

        cur_id = ev["start"]
        actual_seq: list[tuple[str, str]] = []
        visited = 0
        saw_h_hook = False
        while cur_id != "@end":
            visited += 1
            if visited > 500:
                require(False, f"Cycle detected on path ({c1},{c2})")
                break
            node = nodes_by_id[cur_id]
            if node.get("action") == "launch_emiko_lv4_h":
                saw_h_hook = True
            if node["presentation"] == "choice":
                pick_suffix = c1 if cur_id == "em4_choice_c1" else c2
                picked = [ch for ch in node["choices"] if ch["id"].endswith(f"_{pick_suffix}")][0]
                cur_id = picked["next"]
                continue
            actual_seq.append((node["speaker_label"], node["text"]))
            cur_id = node["choices"][0]["next"]

        require(saw_h_hook, f"Path ({c1},{c2}) traverses H Runner placeholder hook on em4_s6_1_24")
        require(
            actual_seq == expected_seq,
            f"100% verbatim speaker+text match on path (c1={c1}, c2={c2}): len actual={len(actual_seq)} vs expected={len(expected_seq)}",
        )

    # Check V1.1 revision log anchors and absence of V1.0 superseded strings
    all_zh_text = "\n".join(n["text"] for n in ev["nodes"] if n["text"])
    for bad in FORBIDDEN_ZH:
        require(bad not in all_zh_text, f"Prohibited/V1.0 string absent from lv4_events.json: {bad!r}")
    require(
        "现在全院都在议论空着的外科主任位置。我有资格争，也打算争到底。" in all_zh_text,
        "V1.1 P1 chief-rivalry wording present verbatim in Scene 3",
    )
    require("二十七岁女警樱井真弓" in all_zh_text, "Scene 5 27-year-old Mayumi Sakurai wording present verbatim")
    require("手术台确实也是床，就是窄了点。" in all_zh_text, "Scene 6.1 operating-table banter line present verbatim before H hook")
    require("外科主任的位置，我半步都不会因为这种事让给你。" in all_zh_text, "Scene 6.2 unyielding Chief rivalry declaration present verbatim")
    require("她的长发依旧理得利落端正" in all_zh_text, "User-authorized revision 1 (em4_s2_02 loose hair smoothed) present")
    require("原本隔天上午有一台粘连较重的腹部再次手术" in all_zh_text, "User-authorized revision 2 (em4_s2_10 following morning) present")
    require("那双冷冽的眼眸里依然浮起了" in all_zh_text, "User-authorized revision 3 (em4_s5_21 cool eyes) present")
    require("那双冷冽的眼眸里重新燃起了" in all_zh_text, "User-authorized revision 4 (em4_s6_2_24 cool eyes) present")

    # Localization parity & zero CJK leak check
    zh_strings = json.loads(ZH_LOCALE.read_text(encoding="utf-8"))["strings"]
    en_strings = json.loads(EN_LOCALE.read_text(encoding="utf-8"))["strings"]
    prefix = f"collections.character_events.{EVENT_ID}."
    for meta_key in ("title", "teaser", "gallery.caption"):
        require(f"{prefix}{meta_key}" in zh_strings and f"{prefix}{meta_key}" in en_strings, f"Locale key {prefix}{meta_key} in zh_CN & en")
        require(not CJK_RE.search(en_strings[f"{prefix}{meta_key}"]), f"Zero CJK in en {prefix}{meta_key}")

    for ui_key in (
        "ui.emiko_lv4.h_placeholder.title",
        "ui.emiko_lv4.h_placeholder.subtitle",
        "ui.emiko_lv4.h_placeholder.body",
        "ui.emiko_lv4.h_placeholder.continue",
        "ui.free_h.location.doc_emiko_or",
    ):
        require(ui_key in zh_strings and ui_key in en_strings, f"UI locale key {ui_key} in zh_CN & en")
        require(not CJK_RE.search(en_strings[ui_key]), f"Zero CJK in en {ui_key}")

    for node in ev["nodes"]:
        nid = node["id"]
        sk = f"{prefix}nodes.{nid}.speaker_label"
        require(sk in zh_strings and sk in en_strings, f"Speaker label localized for {nid}")
        require(not CJK_RE.search(en_strings[sk]), f"Zero CJK in en speaker label for {nid}")
        if node["text"]:
            tk = f"{prefix}nodes.{nid}.text"
            require(zh_strings.get(tk) == node["text"], f"zh_CN locale text matches lv4_events.json for {nid}")
            require(tk in en_strings and len(en_strings[tk].strip()) > 0, f"en locale text non-empty for {nid}")
            require(not CJK_RE.search(en_strings[tk]), f"Zero CJK in en text for {nid}")
            require(
                set(BRACE_RE.findall(zh_strings[tk])) == set(BRACE_RE.findall(en_strings[tk])),
                f"Placeholder parity for {nid}",
            )
        for ch in node["choices"]:
            ck = f"{prefix}nodes.{nid}.choices.{ch['id']}.label"
            require(ck in zh_strings and ck in en_strings, f"Choice label localized for {nid}.{ch['id']}")
            require(not CJK_RE.search(en_strings[ck]), f"Zero CJK in en choice label for {nid}.{ch['id']}")

    # Scene 1 CG variant mounting + SHA-256 + schema purity
    cg_immersed = "assets/events/emiko_lv4_cg_v1/lv4_or_secret_immersed.png"
    cg_startled = "assets/events/emiko_lv4_cg_v1/lv4_or_secret_startled.png"
    require(ev["gallery"]["path"] == cg_immersed, "Gallery path points to Scene 1 immersed CG")
    for cg_rel, want_sha in (
        (cg_immersed, "4d95f806fedd4a7eb298b90c20adce76c6953229889b30f7837eee60c746c317"),
        (cg_startled, "165c547f2423a18e0c3dae78e71584ee0516acea17c742aa1f846f048826a7fd"),
    ):
        cg_p = ROOT / cg_rel
        require(cg_p.is_file(), f"Scene 1 CG exists: {cg_rel}")
        if cg_p.is_file():
            require(sha256_of(cg_p) == want_sha, f"Scene 1 CG SHA-256 matches original: {cg_rel}")
            with Image.open(cg_p) as im:
                require(im.size == (1536, 1024), f"Scene 1 CG is 1536x1024: {cg_rel} (got {im.size})")
    for i in range(9, 16):
        n = nodes_by_id[f"em4_s1_{i:02d}"]
        require(n.get("cg_path") == cg_immersed and n.get("cg_fit") == "contain" and not n.get("hide_portrait") and "event_portraits" not in n, f"em4_s1_{i:02d} mounts immersed CG cleanly")
    for i in range(16, 19):
        n = nodes_by_id[f"em4_s1_{i:02d}"]
        require(n.get("cg_path") == cg_startled and n.get("cg_fit") == "contain" and not n.get("hide_portrait") and "event_portraits" not in n, f"em4_s1_{i:02d} mounts startled CG cleanly")
    require("cg_path" not in nodes_by_id["em4_s1_08"] and "cg_path" not in nodes_by_id["em4_s1_19"], "Scene 1 CG window bounded cleanly to em4_s1_09..18")

    # Asset & background existence + RGBA alpha verification on portraits
    bgs = {b["id"]: b["path"] for b in json.loads(BACKGROUNDS_JSON.read_text(encoding="utf-8"))}
    used_bgs = {n["background_id"] for n in ev["nodes"]} | {ev["background_id"], ev["completion_background_id"]}
    for bg_id in sorted(used_bgs):
        require(bg_id in bgs and (ROOT / bgs[bg_id]).is_file(), f"Background {bg_id} exists on disk")

    used_portraits = {
        slot["path"]
        for n in ev["nodes"]
        for slot in n.get("event_portraits", [])
    }
    for rel_p in sorted(used_portraits):
        p = ROOT / rel_p
        require(p.is_file(), f"Portrait exists: {rel_p}")
        if p.is_file():
            with Image.open(p) as im:
                require(im.mode == "RGBA", f"Portrait is RGBA: {rel_p} (got {im.mode})")
                alpha_extrema = im.getchannel("A").getextrema()
                require(alpha_extrema[0] < 255, f"Portrait has transparent alpha background: {rel_p}")

    print(f"EMIKO LV4 SOURCE AUDIT: {checks} checks; {len(failures)} failure(s)")
    if failures:
        for f in failures:
            print("  FAIL:", f)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
