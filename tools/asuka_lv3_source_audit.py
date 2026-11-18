#!/usr/bin/env python3
"""Verbatim source audit for Asuka Shiromiya (`doc_asuka`) Relationship Lv3:
《本院长不接受反驳哦》 (`asuka_lv3_no_objections`).

Independently verifies:
1. 100% character-for-character verbatim match of every dialogue beat, narration
   paragraph, split action+dialogue line, and speaker ownership across BOTH
   Scene A opening variants (`first_sunday_date` A-1 -> @end and
   `prior_sunday_date` A-2 -> @end) against
   `research/source_scripts/HOSHIMI_ASUKA_LV3_NO_OBJECTIONS_V1_1.md`,
   allowing ONLY the 2 explicitly documented non-diegetic/markdown alignments
   (`al3_067` staging note removal and `al3_075` `**奶白色**` asterisk removal).
2. Graph integrity: 177 reachable nodes, unique choice IDs, both opening variants
   converging at `al3_012` and settling cleanly at `@end`.
3. Bilingual coverage (`zh_CN.json` and `en.json`) with zero CJK leaks in English.
4. Portrait, CG, and background technical checks (`1024x1536` RGBA, transparent
   corners, `mipmaps/generate=true` for all 8 sprites; `1376x768` + `.import` for
   mirror CG and both new backgrounds).
5. Family dark-thread & Lv4 spoiler redline checks (zero deceased-mother words,
   zero premature stepfather/remarriage spoilers in both zh_CN and en).
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT = ROOT / "research/source_scripts/HOSHIMI_ASUKA_LV3_NO_OBJECTIONS_V1_1.md"
EVENT_ID = "asuka_lv3_no_objections"
CJK_RE = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")


class Audit:
    def __init__(self) -> None:
        self.checks = 0
        self.failures: list[str] = []

    def check(self, cond: bool, msg: str) -> None:
        self.checks += 1
        if not cond:
            self.failures.append(msg)

    def equal(self, actual, expected, msg: str) -> None:
        self.checks += 1
        if actual != expected:
            self.failures.append(f"{msg}: expected {expected!r}, got {actual!r}")


def reconstruct_manuscript_paths(md_text: str) -> tuple[list[tuple[str, str]], list[tuple[str, str]]]:
    """Independently extract (speaker_label, text) sequences for path A-1 and path A-2."""
    lines = md_text.splitlines()
    start_idx = next(i for i, l in enumerate(lines) if l.strip().startswith("### Scene A｜"))
    end_idx = next(i for i, l in enumerate(lines) if l.strip().startswith("> **【事件结束｜原子性结算】**"))

    buckets: dict[str, list[tuple[str, str]]] = {"intro": [], "a1": [], "a2": [], "body": []}
    bucket_key = "intro"
    in_meta = False

    unbold_speakers = [
        ("她一边说", "城宮明日香"),
        ("坂口隆司仔细看了一眼", "坂口隆司"),
        ("空气安静了半秒，坂口隆司实在没绷住", "坂口隆司"),
        ("坂口隆司微微一怔", "坂口隆司"),
    ]

    for raw in lines[start_idx:end_idx]:
        s = raw.strip()
        if not s or s == "---":
            in_meta = False
            continue
        if s.startswith("### Scene "):
            in_meta = False
            continue
        if s.startswith("**【"):
            in_meta = True
            continue
        if in_meta and s.startswith("- "):
            continue
        in_meta = False

        if s.startswith("#### 【分支 A-1"):
            bucket_key = "a1"
            continue
        if s.startswith("#### 【分支 A-2"):
            bucket_key = "a2"
            continue
        if s.startswith("> **【分支汇合点】**"):
            bucket_key = "body"
            continue
        if s.startswith("> **【"):
            continue

        # Only the 2 documented non-diegetic / markdown cleanups:
        s_clean = s.replace("（仅在身前展示比划，并未换穿）", "").replace("**奶白色**", "奶白色")

        m_pure = re.match(r"^\*\*([^*]+)\*\*：(「.+」)$", s_clean)
        if m_pure:
            buckets[bucket_key].append((m_pure.group(1), m_pure.group(2)))
            continue

        m_bold_act = re.match(r"^\*\*([^*]+)\*\*（(.+?)）：(「.+」)$", s_clean)
        if m_bold_act:
            sp, act, q = m_bold_act.groups()
            buckets[bucket_key].append(("旁白", f"{sp}（{act}）："))
            buckets[bucket_key].append((sp, q))
            continue

        m_unbold = re.match(r"^(.+?)：(「[^「」]*」)$", s_clean)
        if m_unbold:
            pref, q = m_unbold.groups()
            sp = next((lbl for k, lbl in unbold_speakers if pref.startswith(k)), None)
            if sp is not None:
                buckets[bucket_key].append(("旁白", f"{pref}："))
                buckets[bucket_key].append((sp, q))
                continue

        buckets[bucket_key].append(("旁白", s_clean))

    path_a1 = buckets["intro"] + buckets["a1"] + buckets["body"]
    path_a2 = buckets["intro"] + buckets["a2"] + buckets["body"]
    return path_a1, path_a2


def walk_linear_path(node_map: dict[str, dict], start_id: str, a: Audit) -> list[dict]:
    out: list[dict] = []
    cur = start_id
    steps = 0
    while cur != "@end" and steps < 500:
        a.check(cur in node_map, f"Valid node target {cur}")
        if cur not in node_map:
            break
        nd = node_map[cur]
        out.append(nd)
        a.equal(len(nd["choices"]), 1, f"Node {cur} has single continue choice")
        ch = nd["choices"][0]
        a.equal(ch["effects"], {"affection": 0, "familiarity": 0}, f"Choice {ch['id']} zero stat delta")
        a.equal(ch["flags"], [], f"Choice {ch['id']} zero flag delta")
        cur = ch["next"]
        steps += 1
    a.equal(cur, "@end", f"Path from {start_id} reaches @end")
    return out


def main() -> int:
    a = Audit()
    a.check(MANUSCRIPT.is_file(), "Manuscript V1.1 exists")
    md_text = MANUSCRIPT.read_text(encoding="utf-8")
    exp_a1, exp_a2 = reconstruct_manuscript_paths(md_text)
    a.equal(len(exp_a1), 166, "Expected A-1 path length is 166 beats")
    a.equal(len(exp_a2), 166, "Expected A-2 path length is 166 beats")

    # Verify bundle, profile, relationship, backgrounds
    bundle = json.loads((ROOT / "data/staff/doc_asuka/bundle.json").read_text(encoding="utf-8"))
    extra_files = bundle.get("additional_character_event_files", [])
    a.check("lv2_events.json" in extra_files, "bundle.json preserves lv2_events.json")
    a.check("lv3_events.json" in extra_files, "bundle.json registers lv3_events.json")

    profile = json.loads((ROOT / "data/staff/doc_asuka/profile.json").read_text(encoding="utf-8"))
    for outfit_name in ("date_cardigan", "vintage_cream_gown"):
        a.check(outfit_name in profile["visuals"]["outfits"], f"profile.json registers {outfit_name} outfit")
    expected_portrait_keys = [
        "date_cardigan/neutral",
        "date_cardigan/smile",
        "date_cardigan/playful",
        "date_cardigan/nostalgic",
        "date_cardigan/laugh",
        "date_cardigan/shy",
        "vintage_cream_gown/neutral",
        "vintage_cream_gown/expectant",
        "vintage_cream_gown/shy_earnest",
        "vintage_cream_gown/blushing_happy",
    ]
    for pk in expected_portrait_keys:
        a.check(pk in profile["visuals"]["portraits"], f"profile.json registers {pk}")

    rel = json.loads((ROOT / "data/staff/doc_asuka/relationship.json").read_text(encoding="utf-8"))
    slot3 = next((s for s in rel["rank_slots"] if s["target_level"] == 3), {})
    a.equal(slot3.get("event_id"), EVENT_ID, "Lv3 rank slot event_id")
    a.equal(slot3.get("content_status"), "authored", "Lv3 rank slot content_status")
    a.equal(slot3.get("min_familiarity"), 40, "Lv3 rank slot min_familiarity")
    a.equal(slot3.get("cooldown_days"), 3, "Lv3 rank slot cooldown_days")
    a.equal(
        slot3.get("special_requirements"),
        [{"type": "player_attribute", "attribute": "charm", "minimum": 50}],
        "Lv3 rank slot charm >= 50 requirement",
    )

    bgs = {row["id"]: row for row in json.loads((ROOT / "data/backgrounds.json").read_text(encoding="utf-8"))}
    for bg_id in ("asuka_lv3_cafe_exterior_day", "asuka_lv3_archive_room_afternoon", "date_cafe", "hospital_courtyard_evening"):
        a.check(bg_id in bgs, f"backgrounds.json contains {bg_id}")

    events = json.loads((ROOT / "data/staff/doc_asuka/lv3_events.json").read_text(encoding="utf-8"))
    a.equal(len(events), 1, "lv3_events.json has 1 event")
    ev = events[0]
    a.equal(ev["id"], EVENT_ID, "event id")
    a.equal(ev["title"], "本院长不接受反驳哦", "event title")
    a.equal(ev["trigger_mode"], "sunday", "trigger_mode is sunday")
    a.equal(ev["consumes_sunday"], True, "consumes_sunday is True")
    a.equal(ev["date_location_id"], "cafe", "date_location_id is cafe")
    a.equal(ev["category"], "rank_up", "category is rank_up")
    a.equal(ev["target_level"], 3, "target_level is 3")
    a.check(ev.get("locks_saving") is True, "locks_saving is True")
    a.check(ev.get("hide_calendar_header") is True, "hide_calendar_header is True")
    a.check("asuka_lv3_complete" in ev.get("completion_story_flags", []), "completion_story_flags contains asuka_lv3_complete")
    a.equal(
        ev.get("opening_variants"),
        {"first_sunday_date": "al3_a1_001", "prior_sunday_date": "al3_a2_001"},
        "opening_variants registered",
    )

    nodes: list[dict] = ev["nodes"]
    a.equal(len(nodes), 177, "177 total nodes")
    node_map = {n["id"]: n for n in nodes}

    # Walk both opening variants and verify 100% verbatim match
    actual_a1 = walk_linear_path(node_map, ev["opening_variants"]["first_sunday_date"], a)
    actual_a2 = walk_linear_path(node_map, ev["opening_variants"]["prior_sunday_date"], a)
    a.equal(len(actual_a1), len(exp_a1), "A-1 node sequence count matches manuscript")
    a.equal(len(actual_a2), len(exp_a2), "A-2 node sequence count matches manuscript")

    for idx, (nd, (exp_spk, exp_txt)) in enumerate(zip(actual_a1, exp_a1), start=1):
        a.equal(nd["speaker_label"], exp_spk, f"A-1 #{idx} ({nd['id']}) speaker_label")
        a.equal(nd["text"], exp_txt, f"A-1 #{idx} ({nd['id']}) verbatim text")

    for idx, (nd, (exp_spk, exp_txt)) in enumerate(zip(actual_a2, exp_a2), start=1):
        a.equal(nd["speaker_label"], exp_spk, f"A-2 #{idx} ({nd['id']}) speaker_label")
        a.equal(nd["text"], exp_txt, f"A-2 #{idx} ({nd['id']}) verbatim text")

    # Verify convergence at al3_012 and key anchor lines
    a.equal(node_map["al3_a1_011"]["choices"][0]["next"], "al3_012", "A-1 converges to al3_012")
    a.equal(node_map["al3_a2_011"]["choices"][0]["next"], "al3_012", "A-2 converges to al3_012")
    a.equal(node_map["al3_091"]["text"], "「本院长不接受反驳哦！」", "Title anchor line in Scene E")
    a.equal(node_map["al3_145"]["text"], "「我问的是，穿着它的我，好不好看？」", "Emotional pivot question in Scene F")
    a.equal(node_map["al3_153"]["text"], "「……那么，这个意见，本院长就接受了。」", "Title callback acceptance line in Scene F")

    # Verify CG staging on al3_133..139 and standing vintage_cream_gown on al3_140..155
    for num in range(133, 140):
        nid = f"al3_{num:03d}"
        a.equal(node_map[nid].get("cg_path"), "assets/events/asuka_lv3_v1/vintage_cream_gown_mirror.png", f"{nid} uses mirror CG")
        a.equal(node_map[nid].get("cg_fit"), "cover", f"{nid} cg_fit is cover")
        a.check("event_portraits" not in node_map[nid], f"{nid} omits event_portraits during full-screen CG")
    for num in range(140, 156):
        nid = f"al3_{num:03d}"
        a.equal(node_map[nid]["outfit"], "vintage_cream_gown", f"{nid} uses vintage_cream_gown outfit")
        a.check(bool(node_map[nid].get("event_portraits")), f"{nid} stages vintage_cream_gown sprite")

    # Bilingual & dark-thread spoiler redline checks
    zh_strings = json.loads((ROOT / "data/localization/zh_CN.json").read_text(encoding="utf-8"))["strings"]
    en_strings = json.loads((ROOT / "data/localization/en.json").read_text(encoding="utf-8"))["strings"]

    prefix = f"collections.character_events.{EVENT_ID}."
    for suffix in ("title", "teaser", "gallery.caption"):
        k = prefix + suffix
        a.check(bool(zh_strings.get(k)), f"zh_CN has {k}")
        a.check(bool(en_strings.get(k)), f"en has {k}")
        a.check(not CJK_RE.search(en_strings.get(k, "")), f"en {k} has zero CJK")

    a.check(bool(zh_strings.get("ui.asuka.lv3.complete")), "zh_CN has ui.asuka.lv3.complete")
    a.check(bool(en_strings.get("ui.asuka.lv3.complete")), "en has ui.asuka.lv3.complete")
    a.check(not CJK_RE.search(en_strings.get("ui.asuka.lv3.complete", "")), "en ui.asuka.lv3.complete has zero CJK")

    all_zh_text: list[str] = []
    all_en_text: list[str] = []
    for nd in nodes:
        nid = nd["id"]
        tk = f"{prefix}nodes.{nid}.text"
        sk = f"{prefix}nodes.{nid}.speaker_label"
        ck = f"{prefix}nodes.{nid}.choices.c_{nid}.label"
        a.equal(zh_strings.get(tk), nd["text"], f"zh_CN matches {nid} text")
        a.check(bool(en_strings.get(tk, "").strip()), f"en has non-empty {nid} text")
        a.check(not CJK_RE.search(en_strings.get(tk, "")), f"en {nid} text has zero CJK")
        a.equal(zh_strings.get(sk), nd["speaker_label"], f"zh_CN matches {nid} speaker_label")
        a.check(bool(en_strings.get(sk, "").strip()), f"en has non-empty {nid} speaker_label")
        a.check(not CJK_RE.search(en_strings.get(sk, "")), f"en {nid} speaker_label has zero CJK")
        a.equal(zh_strings.get(ck), "继续", f"zh_CN choice label for {nid}")
        a.equal(en_strings.get(ck), "Continue", f"en choice label for {nid}")
        all_zh_text.append(nd["text"])
        all_en_text.append(en_strings.get(tk, "").lower())

    joined_zh = "\n".join(all_zh_text)
    joined_en = "\n".join(all_en_text)
    for bad_zh in ("病逝", "去世", "过世", "遗物", "遗照", "葬礼", "在天之灵", "亡母", "继父", "再婚"):
        a.check(bad_zh not in joined_zh, f"Forbidden zh spoiler/death term absent: {bad_zh}")
    for bad_en in ("passed away", "deceased", "late mother", "funeral", "stepfather", "remarried"):
        a.check(bad_en not in joined_en, f"Forbidden en spoiler/death term absent: {bad_en}")

    # Technical image & .import checks
    unique_portraits = sorted({profile["visuals"]["portraits"][k] for k in expected_portrait_keys})
    a.equal(len(unique_portraits), 8, "8 unique standing portrait PNGs")
    for rel in unique_portraits:
        p = ROOT / rel
        imp = ROOT / f"{rel}.import"
        a.check(p.is_file(), f"Portrait file exists: {rel}")
        a.check(imp.is_file(), f"Portrait .import exists: {rel}.import")
        if p.is_file():
            with Image.open(p) as im:
                a.equal(im.mode, "RGBA", f"{rel} mode is RGBA")
                a.equal(im.size, (1024, 1536), f"{rel} size is 1024x1536")
                tl_alpha = im.getpixel((0, 0))[3]
                tr_alpha = im.getpixel((im.width - 1, 0))[3]
                a.equal(tl_alpha, 0, f"{rel} top-left corner transparent")
                a.equal(tr_alpha, 0, f"{rel} top-right corner transparent")
        if imp.is_file():
            imp_txt = imp.read_text(encoding="utf-8")
            a.check("mipmaps/generate=true" in imp_txt, f"{rel}.import has mipmaps/generate=true")

    for rel in (
        "assets/events/asuka_lv3_v1/vintage_cream_gown_mirror.png",
        "assets/backgrounds/asuka_lv3_v1/cafe_exterior_day.png",
        "assets/backgrounds/asuka_lv3_v1/hospital_archive_room_afternoon.png",
    ):
        p = ROOT / rel
        imp = ROOT / f"{rel}.import"
        a.check(p.is_file(), f"Scene asset exists: {rel}")
        a.check(imp.is_file(), f"Scene asset .import exists: {rel}.import")
        if p.is_file():
            with Image.open(p) as im:
                a.equal(im.size, (1376, 768), f"{rel} size is 1376x768")

    if a.failures:
        for f in a.failures[:40]:
            print(f"FAIL: {f}", file=sys.stderr)
        print(f"ASUKA LV3 SOURCE AUDIT FAILED: {a.checks} checks; {len(a.failures)} failure(s)", file=sys.stderr)
        return 1

    print(f"ASUKA LV3 SOURCE AUDIT PASSED: {a.checks} checks; 0 failure(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
