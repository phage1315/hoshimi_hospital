#!/usr/bin/env python3
"""Import Emiko Mido (`doc_emiko`) Relationship Lv0 formal introduction event:
《传闻中的手》 (The Rumored Hands, ID: `emiko_intro_rumored_hands`, V1.2).

Updates:
- data/staff/doc_emiko/events.json (replaces `emiko_intro_rumored_hands` only; preserves Lv0 refusal & Lv1/Lv2 untouched)
- data/localization/zh_CN.json & data/localization/en.json (event strings + UI unlock hints 56 -> 70)
- research/imports/emiko_lv0_2026-11-14.json
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT_PATH = ROOT / "research/source_scripts/HOSHIMI_MIDO_EMIKO_LV0_RUMORED_HANDS_V1_2.md"
EN_TRANSLATION_PATH = ROOT / "research/translations/emiko_lv0_en.json"
EVENTS_PATH = ROOT / "data/staff/doc_emiko/events.json"
ZH_LOCALE_PATH = ROOT / "data/localization/zh_CN.json"
EN_LOCALE_PATH = ROOT / "data/localization/en.json"
MANIFEST_PATH = ROOT / "research/imports/emiko_lv0_2026-11-14.json"

EVENT_ID = "emiko_intro_rumored_hands"

SPEAKER_ROLE_MAP = {
    "旁白": ("narrator", "旁白"),
    "御堂江美子": ("actor", "御堂江美子"),
    "坂口隆司": ("player", "坂口隆司"),
}

EXPRESSION_MAP = {
    "em0_001": ("neutral", True),
    "em0_002": ("neutral", True),
    "em0_003": ("neutral", False),
    "em0_004": ("neutral", False),
    "em0_005": ("neutral", False),
    "em0_006": ("neutral", False),
    "em0_007": ("serious", False),
    "em0_008": ("serious", False),
    "em0_009": ("neutral", False),
    "em0_010": ("serious", False),
    "em0_011": ("serious", False),
    "em0_012": ("neutral", False),
    "em0_013": ("neutral", False),
    "em0_014": ("neutral", False),
    "em0_015": ("serious", False),
    "em0_016": ("serious", False),
    "em0_017": ("serious", False),
    "em0_018": ("serious", False),
    "em0_019": ("serious", False),
    "em0_020": ("serious", False),
    "em0_021": ("neutral", False),
    "em0_022": ("neutral", False),
    "em0_023": ("neutral", False),
    "em0_024": ("neutral", False),
    "em0_025": ("serious", False),
    "em0_026": ("serious", False),
    "em0_027": ("serious", False),
    "em0_028": ("neutral", False),
    "em0_029": ("neutral", False),
    "em0_030": ("serious", False),
    "em0_a_01": ("serious", False),
    "em0_a_02": ("neutral", False),
    "em0_a_03": ("smile", False),
    "em0_b_01": ("serious", False),
    "em0_c_01": ("serious", False),
    "em0_c_02": ("serious", False),
    "em0_032": ("neutral", False),
    "em0_033": ("serious", False),
    "em0_034": ("serious", False),
    "em0_035": ("serious", False),
    "em0_036": ("serious", False),
    "em0_037": ("serious", False),
    "em0_038": ("neutral", False),
    "em0_039": ("neutral", False),
    "em0_040": ("neutral", False),
}


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _parse_numbered_block(block_text: str) -> tuple[str, str, str]:
    """Parse a single numbered beat body into (role, speaker_label, verbatim_text)."""
    lines = [ln.rstrip() for ln in block_text.strip().splitlines() if ln.strip() and ln.strip() != "---"]
    header = lines[0].strip()
    m = re.match(r"^\*\*(.+?)\*\*$", header)
    if not m:
        raise ValueError(f"Expected **Speaker** header, got: {header!r}")
    sp_name = m.group(1)
    role, slabel = SPEAKER_ROLE_MAP[sp_name]
    body = "\n".join(ln.strip() for ln in lines[1:])
    if not body:
        raise ValueError(f"Empty body under speaker {sp_name!r}")
    return role, slabel, body


def _parse_branch_turns(block_text: str) -> list[tuple[str, str, str]]:
    """Parse multi-turn branch section into list of (role, speaker_label, verbatim_text)."""
    turns: list[tuple[str, str, str]] = []
    cur_speaker: str | None = None
    cur_lines: list[str] = []
    for raw in block_text.splitlines():
        s = raw.strip()
        if not s or s == "---" or s.startswith("*("):
            continue
        m = re.match(r"^\*\*(.+?)\*\*$", s)
        if m and m.group(1) in SPEAKER_ROLE_MAP:
            if cur_speaker is not None:
                role, slabel = SPEAKER_ROLE_MAP[cur_speaker]
                turns.append((role, slabel, "\n".join(cur_lines)))
            cur_speaker = m.group(1)
            cur_lines = []
        else:
            cur_lines.append(s)
    if cur_speaker is not None and cur_lines:
        role, slabel = SPEAKER_ROLE_MAP[cur_speaker]
        turns.append((role, slabel, "\n".join(cur_lines)))
    return turns


def parse_manuscript() -> tuple[dict[str, tuple[str, str, str]], dict[str, str]]:
    """Return (beats_by_node_id, choice_labels_zh)."""
    md = MANUSCRIPT_PATH.read_text(encoding="utf-8")

    sec2 = md.split("## 二、 完整中文 VN 剧本正文", 1)[1].split("## 三、 分支回应", 1)[0]
    sec3 = md.split("## 三、 分支回应", 1)[1].split("## 四、 回归主线与收尾", 1)[0]
    sec4 = md.split("## 四、 回归主线与收尾", 1)[1].split("## 五、 系统结算与后续 Gate 接线说明", 1)[0]

    beats: dict[str, tuple[str, str, str]] = {}
    choice_labels_zh: dict[str, str] = {}

    # Parse 01..31 from sec2
    parts2 = re.split(r"^### (\d{2})\s*$", sec2, flags=re.MULTILINE)
    for i in range(1, len(parts2), 2):
        num = int(parts2[i])
        body = parts2[i + 1]
        if num == 31:
            for opt_key, cid in [("选项 A", "choice_em0_face"), ("选项 B", "choice_em0_resume"), ("选项 C", "choice_em0_table")]:
                m_opt = re.search(rf"-\s*\*\*{opt_key}\*\*：(.+)$", body, flags=re.MULTILINE)
                if not m_opt:
                    raise ValueError(f"Missing {opt_key} in beat 31")
                choice_labels_zh[cid] = m_opt.group(1).strip()
        else:
            nid = f"em0_{num:03d}"
            beats[nid] = _parse_numbered_block(body)

    # Parse branches A, B, C from sec3
    branch_parts = re.split(r"^### 分支 ([ABC]) — .+$", sec3, flags=re.MULTILINE)
    for i in range(1, len(branch_parts), 2):
        letter = branch_parts[i].lower()
        turns = _parse_branch_turns(branch_parts[i + 1])
        for idx, turn in enumerate(turns, start=1):
            beats[f"em0_{letter}_{idx:02d}"] = turn

    # Parse 32..40 from sec4
    parts4 = re.split(r"^### (\d{2})\s*$", sec4, flags=re.MULTILINE)
    for i in range(1, len(parts4), 2):
        num = int(parts4[i])
        nid = f"em0_{num:03d}"
        beats[nid] = _parse_numbered_block(parts4[i + 1])

    return beats, choice_labels_zh


def build_event(beats: dict[str, tuple[str, str, str]], choice_labels_zh: dict[str, str]) -> dict:
    ordered_ids = (
        [f"em0_{n:03d}" for n in range(1, 31)]
        + ["em0_a_01", "em0_a_02", "em0_a_03", "em0_b_01", "em0_c_01", "em0_c_02"]
        + [f"em0_{n:03d}" for n in range(32, 41)]
    )
    if set(beats.keys()) != set(ordered_ids):
        raise ValueError(f"Node mismatch: {set(beats.keys()) ^ set(ordered_ids)}")

    next_target: dict[str, str] = {}
    for n in range(1, 30):
        next_target[f"em0_{n:03d}"] = f"em0_{n + 1:03d}"
    next_target["em0_a_01"] = "em0_a_02"
    next_target["em0_a_02"] = "em0_a_03"
    next_target["em0_a_03"] = "em0_032"
    next_target["em0_b_01"] = "em0_032"
    next_target["em0_c_01"] = "em0_c_02"
    next_target["em0_c_02"] = "em0_032"
    for n in range(32, 40):
        next_target[f"em0_{n:03d}"] = f"em0_{n + 1:03d}"
    next_target["em0_040"] = "@end"

    nodes: list[dict] = []
    for nid in ordered_ids:
        role, slabel, text = beats[nid]
        expr, hide_portrait = EXPRESSION_MAP[nid]
        if nid == "em0_030":
            choices = [
                {
                    "id": "choice_em0_face",
                    "label": choice_labels_zh["choice_em0_face"],
                    "next": "em0_a_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em0_resume",
                    "label": choice_labels_zh["choice_em0_resume"],
                    "next": "em0_b_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
                {
                    "id": "choice_em0_table",
                    "label": choice_labels_zh["choice_em0_table"],
                    "next": "em0_c_01",
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": [],
                },
            ]
        else:
            choices = [
                {
                    "id": f"continue_{nid}",
                    "label": "继续",
                    "next": next_target[nid],
                    "effects": {"affection": 0, "familiarity": 0},
                    "flags": ["emiko_intro_complete"] if nid == "em0_040" else [],
                }
            ]
        node_obj: dict = {
            "id": nid,
            "presentation": "authored",
            "speaker": role,
            "speaker_label": slabel,
            "text": text,
            "expression": expr,
            "choices": choices,
        }
        if hide_portrait:
            node_obj["hide_portrait"] = True
        nodes.append(node_obj)

    return {
        "id": EVENT_ID,
        "actor_id": "doc_emiko",
        "title": "传闻中的手",
        "chapter": 0,
        "location_id": "emiko_office",
        "trigger_mode": "location",
        "background_id": "emiko_office",
        "outfit": "white_coat",
        "minutes": 25,
        "teaser": "外科医长御堂江美子让人传话，叫坂口有空去她办公室一趟。",
        "time_start": 540,
        "time_end": 1019,
        "priority": 200,
        "category": "introduction",
        "locks_saving": True,
        "gallery": {
            "cg_id": "cg_emiko_intro_rumored_hands",
            "caption": "传闻中的手",
            "path": "",
            "show_on_complete": False,
        },
        "conditions": {
            "min_day": 1,
            "min_affection": 0,
            "min_familiarity": 0,
            "required_events": ["intro_doc_asuka_director_office"],
            "special_requirements": [
                {
                    "type": "player_attribute",
                    "attribute": "skill",
                    "minimum": 70,
                }
            ],
        },
        "start": "em0_001",
        "nodes": nodes,
        "auto_start": True,
        "target_level": 1,
        "benefit_id": "",
    }


def update_locales(event: dict, en_data: dict) -> None:
    zh_doc = json.loads(ZH_LOCALE_PATH.read_text(encoding="utf-8"))
    en_doc = json.loads(EN_LOCALE_PATH.read_text(encoding="utf-8"))
    zh_strings: dict[str, str] = zh_doc["strings"]
    en_strings: dict[str, str] = en_doc["strings"]

    prefix = f"collections.character_events.{EVENT_ID}."
    for k in [k for k in zh_strings if k.startswith(prefix)]:
        del zh_strings[k]
    for k in [k for k in en_strings if k.startswith(prefix)]:
        del en_strings[k]

    zh_strings[f"{prefix}title"] = event["title"]
    zh_strings[f"{prefix}teaser"] = event["teaser"]
    zh_strings[f"{prefix}gallery.caption"] = event["gallery"]["caption"]

    en_strings[f"{prefix}title"] = en_data["title"]
    en_strings[f"{prefix}teaser"] = en_data["teaser"]
    en_strings[f"{prefix}gallery.caption"] = en_data["gallery_caption"]

    speakers_en: dict[str, str] = en_data["speakers"]
    nodes_en: dict[str, str] = en_data["nodes"]
    choices_en: dict[str, str] = en_data["choices"]
    cont_en: str = en_data["continue_label"]

    for node in event["nodes"]:
        nid = node["id"]
        zh_strings[f"{prefix}nodes.{nid}.text"] = node["text"]
        zh_strings[f"{prefix}nodes.{nid}.speaker_label"] = node["speaker_label"]
        en_strings[f"{prefix}nodes.{nid}.text"] = nodes_en[nid]
        en_strings[f"{prefix}nodes.{nid}.speaker_label"] = speakers_en[node["speaker_label"]]
        for ch in node["choices"]:
            cid = ch["id"]
            zh_strings[f"{prefix}nodes.{nid}.choices.{cid}.label"] = ch["label"]
            en_strings[f"{prefix}nodes.{nid}.choices.{cid}.label"] = choices_en.get(cid, cont_en)

    # Fix outdated Surgery 56 UI unlock hints -> Surgery 70
    zh_strings["ui.unlock.emiko"] = "御堂江美子会在手术技术达到 70 后正式接见你。当前技术：%s。"
    zh_strings["ui.unlock.artoria_emiko"] = "先将手术技术提升至 70，在御堂外科医长办公室与御堂正式相识。"
    en_strings["ui.unlock.emiko"] = "Emiko Mido will formally receive you once Surgery reaches 70. Current Surgery: %s."
    en_strings["ui.unlock.artoria_emiko"] = "Raise Surgery to 70 and formally meet Mido in the Chief Surgeon's Office first."

    zh_doc["strings"] = dict(sorted(zh_strings.items()))
    en_doc["strings"] = dict(sorted(en_strings.items()))
    ZH_LOCALE_PATH.write_text(json.dumps(zh_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    EN_LOCALE_PATH.write_text(json.dumps(en_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    beats, choice_labels_zh = parse_manuscript()
    event = build_event(beats, choice_labels_zh)
    en_data = json.loads(EN_TRANSLATION_PATH.read_text(encoding="utf-8"))

    events = json.loads(EVENTS_PATH.read_text(encoding="utf-8"))
    replaced = False
    for idx, item in enumerate(events):
        if item.get("id") == EVENT_ID:
            events[idx] = event
            replaced = True
            break
    if not replaced:
        raise RuntimeError(f"Could not find {EVENT_ID} in {EVENTS_PATH}")

    EVENTS_PATH.write_text(json.dumps(events, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    update_locales(event, en_data)

    manifest = {
        "event_id": EVENT_ID,
        "version": "V1.2",
        "source_manuscript": str(MANUSCRIPT_PATH.relative_to(ROOT)),
        "source_manuscript_sha256": sha256_of(MANUSCRIPT_PATH),
        "english_translation": str(EN_TRANSLATION_PATH.relative_to(ROOT)),
        "english_translation_sha256": sha256_of(EN_TRANSLATION_PATH),
        "target_events_file": str(EVENTS_PATH.relative_to(ROOT)),
        "node_count": len(event["nodes"]),
        "choice_branches": ["choice_em0_face", "choice_em0_resume", "choice_em0_table"],
        "gate": {
            "required_events": ["intro_doc_asuka_director_office"],
            "skill_minimum": 70,
            "auto_follow_up": None,
        },
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Imported {EVENT_ID} ({len(event['nodes'])} nodes) cleanly.")


if __name__ == "__main__":
    main()
