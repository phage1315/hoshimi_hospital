#!/usr/bin/env python3
"""Verbatim V1.1 Concept Lock importer for Saber Legendary Surgery (`surgery_master_whipple_vascular_reconstruction`)."""
from __future__ import annotations
import copy
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data/advanced_surgery"
SURG_SRC = ROOT / "research/source_scripts/HOSHIMI_SABER_LEGENDARY_MAIYA_SURGICAL_DESIGN_V1_1.md"
VN_SRC = ROOT / "research/source_scripts/HOSHIMI_SABER_LEGENDARY_MAIYA_THREE_DAY_VN_V1_1.md"
ID = "surgery_master_whipple_vascular_reconstruction"


def read_json(p: Path):
    return json.loads(p.read_text(encoding="utf-8"))


def write_json(p: Path, v):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(v, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def section(raw: str, start: str, end: str) -> str:
    return raw.split(start, 1)[1].split(end, 1)[0]


def clean_int(val: str) -> int:
    s = re.sub(r"\*", "", val).strip().replace("−", "-")
    if s in ("—", "-", ""):
        return 0
    return int(s)


def parse_ui_table(surg_raw: str) -> dict[str, list[str]]:
    blk = section(surg_raw, "## 7. 非剧情 UI 文本（中英对照）", "## 8. 美术资产清单")
    out = {}
    for line in blk.splitlines():
        if not line.startswith("|") or line.startswith("| Key") or line.startswith("|---"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) >= 3:
            out[cells[0]] = [cells[1], cells[2]]
    return out


def parse_procedure(surg_raw: str, ui_map: dict[str, list[str]]) -> dict:
    # 1. Stage base table (§1)
    st_blk = section(surg_raw, "## 1. WH01–WH18 手术阶段", "### 1.1 已批准的 18 阶段生理效果")
    stage_rows = []
    for line in st_blk.splitlines():
        if line.startswith("| WH"):
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            sid, kind, title_pair, mn, hp, diff, fhp, tag, stress_raw = cells
            cn_title, en_title = [x.strip() for x in title_pair.split("／", 1)]
            stress = stress_raw.split()[0].strip()
            stage_rows.append({
                "id": sid,
                "name": cn_title,
                "name_en": en_title,
                "kind": kind,
                "elapsed_time": clean_int(mn),
                "hp_base": clean_int(hp),
                "difficulty": clean_int(diff),
                "hp_failed_extra": clean_int(fhp),
                "specialty_tag": tag,
                "physio_stress": stress,
            })
    assert len(stage_rows) == 18

    # 2. Physiology & conditional_effects table (§1.1)
    ph_blk = section(surg_raw, "### 1.1 已批准的 18 阶段生理效果与 7 条条件效果", "## 2. 三个 S 阶段")
    phys_map = {}
    cond_count = 0
    for line in ph_blk.splitlines():
        if not line.startswith("| WH"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        sid, stab, vis, bleed, loss, cond_cell = cells
        cond_main = cond_cell.split("；")[0].strip()
        conds = []
        if cond_main not in ("—", "-"):
            m = re.match(r"^(Visibility|Bleeding)\s*(<|≥|>=)\s*(\d+)\s*→\s*(.+)$", cond_main)
            assert m, f"Unparsed conditional on {sid}: {cond_main}"
            metric_raw, op_raw, thresh_str, eff_str = m.groups()
            field = "visibility" if metric_raw == "Visibility" else "bleeding"
            op = "lt" if op_raw == "<" else "gte"
            eff = {}
            for part in eff_str.split(","):
                part = part.strip()
                em = re.match(r"^(Stability|Visibility|Bleeding|Blood Loss)\s*([+\-−]?\d+)$", part)
                assert em, f"Unparsed conditional effect part on {sid}: {part}"
                ename, eval_str = em.groups()
                ekey = {
                    "Stability": "stability",
                    "Visibility": "visibility",
                    "Bleeding": "bleeding",
                    "Blood Loss": "blood_loss",
                }[ename]
                eff[ekey] = clean_int(eval_str)
            conds.append({"when": {"field": field, "op": op, "value": int(thresh_str)}, "strategic_effects": eff})
            cond_count += 1
        phys_map[sid] = (
            {
                "stability": clean_int(stab),
                "visibility": clean_int(vis),
                "bleeding": clean_int(bleed),
                "blood_loss": clean_int(loss),
            },
            conds,
        )
    assert len(phys_map) == 18 and cond_count == 7, f"Expected 18 phys rows & 7 conds, got {len(phys_map)} & {cond_count}"

    # 3. Three S-stage options (§2)
    s_blk = section(surg_raw, "## 2. 三个 S 阶段：玩家明确选择", "### 危机检查点")
    s_options = {}
    for sid in ("WH05", "WH10", "WH17"):
        sub = s_blk.split(f"### {sid}：", 1)[1]
        sub = sub.split("### WH", 1)[0] if "### WH" in sub else sub.split("\n\n所有未明确列出", 1)[0]
        rows = {}
        for line in sub.splitlines():
            if line.startswith("|") and not line.startswith("| |") and not line.startswith("|---"):
                cells = [c.strip() for c in line.strip().strip("|").split("|")]
                rows[cells[0]] = (cells[1], cells[2])
        opts = []
        for idx, letter in enumerate(("A", "B")):
            cost_str = re.sub(r"\*", "", rows["附加成本"][idx])
            cm = re.match(r"^\+(\d+)\s*min；\+(\d+)\s*HP$", cost_str)
            assert cm, f"Unparsed cost on {sid}_{letter}: {cost_str}"
            dt, dhp = int(cm.group(1)), int(cm.group(2))
            eff_dict = {"elapsed_time": dt, "stability": 0, "visibility": 0, "bleeding": 0, "blood_loss": 0}
            eff_raw = re.sub(r"\*", "", rows["额外效果"][idx])
            for piece in eff_raw.split("；"):
                pm = re.match(r"^(Stability|Visibility|Bleeding|Blood Loss)\s*([+\-−]?\d+)$", piece.strip())
                assert pm, f"Unparsed S effect on {sid}_{letter}: {piece}"
                ekey = {
                    "Stability": "stability",
                    "Visibility": "visibility",
                    "Bleeding": "bleeding",
                    "Blood Loss": "blood_loss",
                }[pm.group(1)]
                eff_dict[ekey] = clean_int(pm.group(2))
            opts.append({
                "id": f"{sid}_{letter}",
                "label": rows["中文"][idx],
                "label_en": rows["English"][idx],
                "description": rows["说明 CN"][idx],
                "description_en": rows["Description EN"][idx],
                "hp_cost": dhp,
                "strategic_effects": eff_dict,
            })
        s_options[sid] = opts

    steps = []
    for sr in stage_rows:
        sid = sr["id"]
        peff, conds = phys_map[sid]
        peff = dict(peff)
        peff["elapsed_time"] = sr["elapsed_time"]
        step = {
            "id": sid,
            "name": sr["name"],
            "name_en": sr["name_en"],
            "kind": sr["kind"],
            "hp_base": sr["hp_base"],
            "difficulty": sr["difficulty"],
            "hp_failed_extra": sr["hp_failed_extra"],
            "specialty_tag": sr["specialty_tag"],
            "physio_stress": sr["physio_stress"],
            "strategic_effects": peff,
        }
        if conds:
            step["conditional_effects"] = conds
        if sid in s_options:
            step["options"] = s_options[sid]
        steps.append(step)

    assert sum(s["hp_base"] for s in steps) == 54
    assert sum(s["strategic_effects"]["elapsed_time"] for s in steps) == 729

    return {
        "id": ID,
        "name": ui_map["procedure_name"][0],
        "name_en": ui_map["procedure_name"][1],
        "full_name": ui_map["procedure_full_name"][0],
        "full_name_en": ui_map["procedure_full_name"][1],
        "duration_minutes": 729,
        "base_difficulty": 99,
        "training_ceiling": 100,
        "reward_tier": "advanced",
        "status": "implemented",
        "physiology_tuning_status": "V1_1_CONCEPT_LOCK_60K_MC_AND_GODOT_PARITY",
        "patient_notice": ui_map["case_description"][0],
        "patient_notice_en": ui_map["case_description"][1],
        "steps": steps,
        "crisis_checkpoints": [8, 12, 17],
        "crisis_chances": [0.18, 0.24, 0.20],
        "failure_condition": {"metric": "stability", "operator": "<=", "value": 0},
        "success_condition": {"metric": "progress", "operator": ">=", "value": 100},
        "dialogue_after_rescue": True,
    }


def parse_operative_dialogues(surg_raw: str, steps: list[dict]) -> dict[str, dict]:
    shared = {s["id"]: {"before_action": [], "after_resolution": []} for s in steps}
    sec3 = section(surg_raw, "## 3. 全阶段通用对白（每阶段 2 PRE + 1 POST）", "## 4. 第一助手对白")
    for lid, role, cn, en in re.findall(
        r"^- \*\*(WH\d+_(?:PRE|POST)\d+)｜([^*]+)\*\*｜CN(「.*?」)｜EN\s*(“.*?”)\s*$", sec3, re.M
    ):
        sid = lid[:4]
        group = "before_action" if "_PRE" in lid else "after_resolution"
        shared[sid][group].append({"id": lid, "speaker_role": role.strip(), "text": cn, "text_en": en})
    assert all(len(v["before_action"]) == 2 and len(v["after_resolution"]) == 1 for v in shared.values())

    def parse_as_cell(cell: str):
        m = re.match(r"^\*\*(AS\d+_[SG]_(?:PRE|POST))\*\*(「.*?」)／(“.*?”)$", cell.strip())
        assert m, f"Unparsed assistant cell: {cell}"
        return m.group(1), m.group(2), m.group(3)

    sec4_pre = section(surg_raw, "## 4. 第一助手对白：首次 Saber 专属／返场通用", "### 4.1 六个关键阶段的第一助手 POST 差分")
    as_pre = {}
    for line in sec4_pre.splitlines():
        if line.startswith("| WH"):
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            as_pre[cells[0]] = {"teaching": parse_as_cell(cells[1]), "standard": parse_as_cell(cells[2])}
    assert len(as_pre) == 18

    sec4_post = section(surg_raw, "### 4.1 六个关键阶段的第一助手 POST 差分", "### 4.2 Codex 阶段对白组装顺序")
    as_post = {}
    for line in sec4_post.splitlines():
        if line.startswith("| WH"):
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            as_post[cells[0]] = {"teaching": parse_as_cell(cells[1]), "standard": parse_as_cell(cells[2])}
    assert len(as_post) == 6

    sec5 = section(surg_raw, "## 5. 八个 P 阶段的专属精密失败回应", "### 5.1 危机对白与 POST 的组合")
    p_fail = {}
    for line in sec5.splitlines():
        if line.startswith("| WH"):
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            sid = cells[0].split()[0].strip()
            p_fail[sid] = {
                "id": f"{sid}_P_FAIL",
                "speaker_role": cells[1],
                "text": cells[2],
                "text_en": cells[3],
            }
    assert len(p_fail) == 8

    out = {}
    for mode in ("teaching", "standard"):
        stages = copy.deepcopy(shared)
        for sid, group_dict in stages.items():
            aid, acn, aen = as_pre[sid][mode]
            arow = {"id": aid, "speaker_role": "assistant_1", "text": acn, "text_en": aen}
            # §4.2 exact assembly order:
            # WH01 & WH18 have lead_surgeon at PRE02 -> [PRE01, PRE02, ASxx]
            # WH02..WH17 have lead_surgeon at PRE01 -> [PRE01, ASxx, PRE02]
            if sid in ("WH01", "WH18"):
                group_dict["before_action"].append(arow)
            else:
                group_dict["before_action"].insert(1, arow)
            if sid in as_post:
                pid, pcn, pen = as_post[sid][mode]
                group_dict["after_resolution"].append(
                    {"id": pid, "speaker_role": "assistant_1", "text": pcn, "text_en": pen}
                )
            if sid in p_fail:
                group_dict["precision_failed"] = [copy.deepcopy(p_fail[sid])]
            assert len(group_dict["before_action"]) == 3
            assert len(group_dict["after_resolution"]) in (1, 2)
        out[mode] = {"schema_version": "advanced_day2_dialogue_v2", "procedure_id": ID, "stages": stages}
    return out


def parse_vn_story(vn_raw: str, ui_map: dict[str, list[str]]) -> dict:
    speaker_map = {
        "旁白": ("narrator", None),
        "坂口隆司": ("PLAYER", None),
        "久宇舞弥": ("patient", None),
        "阿尔托莉雅": ("doc_artoria", None),
        "病房护士": ("ward_nurse", ("病房护士", "Ward Nurse")),
        "麻醉医师": ("anesthesiologist", ("麻醉医师", "Anesthesiologist")),
    }

    scene_bg = {
        "A": "clinic",
        "B": "diagnostics",
        "C": "artoria_office",
        "D": "ward",
        "E": "or_entrance",
        "F": "operating_room",
        "G": "ward",
        "H": "conference_room",
        "I": "shared_doctors_office",
    }

    # Parse all dialogue bullets & choice blocks in exact document order within Day 1 / Day 2 / Day 3
    day_sections = {
        "day1": section(vn_raw, "## Day 1｜术前日", "## Day 2｜手术日"),
        "day2": section(vn_raw, "## Day 2｜手术日", "## Day 3｜首次成功后"),
        "day3": section(vn_raw, "## Day 3｜首次成功后", "## 附录 A｜完整分支与入口表"),
    }

    # Choice metadata: prompt_line_id -> (choice_block_id, {letter: first_branch_line_id}, {last_branch_line_id: merge_line_id})
    choice_wiring = {
        "A25": ("A-C1", {"A": "A26A", "B": "A26B"}, {"A28A": "A29", "A28B": "A29"}),
        "C26": ("C-C2", {"A": "C27A", "B": "C27B", "C": "C27C"}, {"C28A": "C29", "C28B": "C29", "C28C": "C29"}),
        "G29": ("G-C3", {"A": "G30A", "B": "G30B"}, {"G31A": "G32", "G31B": "G32"}),
        "H30": ("H-C4", {"A": "H31A", "B": "H31B", "C": "H31C"}, {"H33A": "H35", "H33B": "H35", "H34C": "H35"}),
    }

    # Parse choice options verbatim from markdown
    parsed_choices = {}
    for cid in ("A-C1", "C-C2", "G-C3", "H-C4"):
        cblk = vn_raw.split(f"**【选择 {cid}｜", 1)[1].split("**【分支 A】**", 1)[0]
        opts = {}
        for letter, cn_opt, en_opt in re.findall(r"^- ([ABC])(「.*?」)／(“.*?”)\s*$", cblk, re.M):
            opts[letter] = (cn_opt, en_opt)
        parsed_choices[cid] = opts

    # Expressive portraits matching stage directions
    patient_portrait_by_scene = {
        "A": "casual/neutral",
        "B": "casual/neutral",
        "D": "ward/neutral",
        "E": "transfer",
        "F": "or_cap/calm",
        "G": "postop/neutral",
    }
    patient_portrait_overrides = {
        "B09": "casual/neutral",
        "D12": "ward/serious",
        "D15": "ward/serious",
        "D22": "ward/relieved",
        "D25": "ward/relieved",
        "G03": "postop/tired",
        "G05": "postop/tired",
        "G31A": "postop/relieved",
        "G31B": "postop/relieved",
        "G33": "postop/relieved",
    }
    artoria_portrait_overrides = {
        "C11": "white_coat/smile",
        "C30": "white_coat/smile",
        "D08": "white_coat/smile",
        "D26": "white_coat/smile",
        "F11": "scrubs_masked/neutral",
        "G09": "white_coat/smile",
        "G32": "white_coat/smile",
        "H18": "white_coat/smile",
        "H20": "white_coat/smile",
        "H32B": "white_coat/smile",
        "H34C": "white_coat/smile",
        "I05": "white_coat/smile",
        "I07": "white_coat/smile",
        "I14": "white_coat/smile",
    }
    scene_cg_overrides = {
        "E01": "transfer",
        "E02": "transfer",
        "E04": "transfer",
        "E05": "transfer",
        "E07": "transfer",
        "E09": "transfer",
        "E10": "transfer",
        "F01": "or_cap/calm",
        "F13": "anesthesia",
        "F14": "anesthesia",
    }

    chapters = {}
    chapter_defaults = {
        "day1": ("这一次，交给你", "This Time, I Entrust It to You", "clinic", "casual/neutral"),
        "day2": ("这一次，交给你", "This Time, I Entrust It to You", "or_entrance", "transfer"),
        "day3": ("这一次，交给你", "This Time, I Entrust It to You", "ward", "postop/neutral"),
    }

    for phase, blk in day_sections.items():
        lines = []
        for lid, who_cn, cn_txt, en_txt in re.findall(
            r"^- \*\*([A-I]\d+(?:_EX\d+|[ABC])?)｜([^*]+)\*\*｜CN(「.*?」)｜EN\s*(“.*?”)\s*$", blk, re.M
        ):
            scene_letter = lid[0]
            spk, spk_labels = speaker_map[who_cn.strip()]
            row = {
                "id": lid,
                "speaker": spk,
                "text": cn_txt,
                "text_en": en_txt,
                "background": scene_bg[scene_letter],
            }
            if spk_labels is not None:
                row["speaker_label"] = spk_labels[0]
                row["speaker_label_en"] = spk_labels[1]
            if spk == "patient":
                row["portrait"] = patient_portrait_overrides.get(lid, patient_portrait_by_scene[scene_letter])
            elif spk == "doc_artoria":
                row["staff_portrait"] = artoria_portrait_overrides.get(lid, "white_coat/neutral")
            if lid in scene_cg_overrides:
                row["scene_portrait"] = scene_cg_overrides[lid]

            if lid in choice_wiring:
                cid, branch_starts, _ = choice_wiring[lid]
                opts_map = parsed_choices[cid]
                row["choices"] = [
                    {
                        "id": f"{cid}_{letter}",
                        "label": opts_map[letter][0],
                        "label_en": opts_map[letter][1],
                        "next": branch_starts[letter],
                    }
                    for letter in sorted(branch_starts.keys())
                ]
            for _, _, merges in choice_wiring.values():
                if lid in merges:
                    row["next"] = merges[lid]
            lines.append(row)

        ctitle, ctitle_en, cbg, cport = chapter_defaults[phase]
        chapters[phase] = {
            "title": ctitle,
            "title_en": ctitle_en,
            "background": cbg,
            "portrait": cport,
            "lines": lines,
        }

    return {
        "title": "这一次，交给你",
        "title_en": "This Time, I Entrust It to You",
        "procedure_id": ID,
        "source_case_id": "SABER_LEGENDARY_MAIYA_V1_1",
        "runtime_case_id": "advanced_first_" + ID,
        "patient": {
            "id": "patient_maiya_hisau",
            "name": ui_map["patient_name"][0],
            "name_en": ui_map["patient_name"][1],
            "setting": "成年女性；沉着克制、习惯事先替所有人安排交接的患者。星见医院首次专属传奇病例。",
            "setting_en": "An adult woman—composed, methodical, and accustomed to preparing handovers for everyone else first. An authored legendary first case at Hoshimi Hospital.",
            "diagnosis": ui_map["diagnosis_short"][0],
            "diagnosis_en": ui_map["diagnosis_short"][1],
            "visuals": {
                "portraits": {
                    "ward": "assets/characters/maiya_hisau_legendary_v1/ward/neutral.png",
                    "ward/neutral": "assets/characters/maiya_hisau_legendary_v1/ward/neutral.png",
                    "ward/serious": "assets/characters/maiya_hisau_legendary_v1/ward/serious.png",
                    "ward/relieved": "assets/characters/maiya_hisau_legendary_v1/ward/relieved.png",
                    "casual/neutral": "assets/characters/maiya_hisau_legendary_v1/casual/neutral.png",
                    "postop": "assets/characters/maiya_hisau_legendary_v1/postop/neutral.png",
                    "postop/neutral": "assets/characters/maiya_hisau_legendary_v1/postop/neutral.png",
                    "postop/tired": "assets/characters/maiya_hisau_legendary_v1/postop/tired.png",
                    "postop/relieved": "assets/characters/maiya_hisau_legendary_v1/postop/relieved.png",
                    "or_cap/calm": "assets/characters/maiya_hisau_legendary_v1/or_cap/calm.png",
                    "transfer": "assets/characters/maiya_hisau_legendary_v1/transfer.png",
                    "anesthesia": "assets/characters/maiya_hisau_legendary_v1/anesthesia.png",
                    "splash/general_anesthesia": "assets/characters/maiya_hisau_legendary_v1/anesthesia.png",
                    "intraoperative/anesthetized": "assets/characters/maiya_hisau_legendary_v1/intraoperative/anesthetized.png",
                    "team_confirmation": "assets/characters/maiya_hisau_legendary_v1/team_confirmation.png",
                }
            },
        },
        **chapters,
    }


def build():
    surg_raw = SURG_SRC.read_text(encoding="utf-8")
    vn_raw = VN_SRC.read_text(encoding="utf-8")
    ui_map = parse_ui_table(surg_raw)
    proc = parse_procedure(surg_raw, ui_map)
    dialogues = parse_operative_dialogues(surg_raw, proc["steps"])
    story = parse_vn_story(vn_raw, ui_map)
    registry_entry = {
        "procedure_id": ID,
        "category": "LEGENDARY_STORY",
        "mentor": "doc_artoria",
        "required_rank": 5,
        "required_regular_clears": 5,
        "replay_eligible": True,
        "runtime_ready": True,
        "required_portraits": [
            "ward",
            "casual/neutral",
            "postop",
            "or_cap/calm",
            "transfer",
            "team_confirmation",
            "splash/general_anesthesia",
            "intraoperative/anesthetized",
        ],
        "ui_text": {
            "entry_title": ui_map["entry_title"],
            "legendary_rank_locked": ui_map["entry_locked_relationship"],
            "legendary_system_locked": ui_map["entry_locked_advanced"],
            "legendary_mentor_locked": ui_map["entry_locked_schedule"],
            "legendary_confirm": ui_map["first_story_start"],
            "legendary_cleared": ui_map["first_story_clear"],
            "replay_label": ui_map["replay_label"],
        },
    }
    return proc, story, dialogues, registry_entry, ui_map


def main():
    proc, story, dialogues, registry_entry, ui_map = build()

    # 1. Update legendary_procedures.json (preserve Mido at [0], upsert Saber)
    procs = read_json(DATA / "legendary_procedures.json")
    procs = [p for p in procs if p["id"] != ID]
    procs.append(proc)
    write_json(DATA / "legendary_procedures.json", procs)

    # 2. Update legendary_registry.json (preserve Mido at [0], upsert Saber)
    reg = read_json(DATA / "legendary_registry.json")
    reg = [r for r in reg if r["procedure_id"] != ID]
    reg.append(registry_entry)
    write_json(DATA / "legendary_registry.json", reg)

    # 3. Write story & operative dialogue files
    write_json(DATA / "stories" / f"{ID}.json", story)
    write_json(DATA / "dialogue_v2" / f"{ID}.json", dialogues["standard"])
    write_json(DATA / "dialogue_teaching" / f"{ID}.json", dialogues["teaching"])

    # 4. Register field_windows.json
    fw = read_json(DATA / "field_windows.json")
    fw[ID] = {
        "after_stage": "WH01",
        "before_stage": "WH18",
        "path": "assets/surgery/fields/saber_whipple_vascular.jpg",
        "incision_path": "assets/surgeries/advanced_fields_v1/whipple_incision.png",
        "closure_path": "assets/surgeries/advanced_fields_v1/whipple_closure.png",
        "aspect_ratio": [4, 3],
    }
    write_json(DATA / "field_windows.json", fw)

    # 5. Register replay_case_profiles.json
    rcp = read_json(DATA / "replay_case_profiles.json")
    rcp[ID] = {
        "diagnosis": ui_map["diagnosis_short"][0],
        "diagnosis_en": ui_map["diagnosis_short"][1],
    }
    write_json(DATA / "replay_case_profiles.json", rcp)

    # 6. Ensure `hepatopancreatobiliary` tag exists in ui_text.json (without touching `legendary_*` keys!)
    ui = read_json(DATA / "ui_text.json")
    if "hepatopancreatobiliary" not in ui:
        ui["hepatopancreatobiliary"] = ["肝胆胰操作（HPB）", "Hepatopancreatobiliary"]
        write_json(DATA / "ui_text.json", ui)

    # 7. Record import manifest
    write_json(
        ROOT / "research/imports/saber_legendary_v1_1.json",
        {
            "surgical_source": str(SURG_SRC.relative_to(ROOT)),
            "surgical_sha256": hashlib.sha256(SURG_SRC.read_bytes()).hexdigest(),
            "vn_source": str(VN_SRC.relative_to(ROOT)),
            "vn_sha256": hashlib.sha256(VN_SRC.read_bytes()).hexdigest(),
            "procedure_id": ID,
            "stages": len(proc["steps"]),
            "hp_base_total": sum(s["hp_base"] for s in proc["steps"]),
            "duration_minutes": proc["duration_minutes"],
            "conditional_effects_count": sum(len(s.get("conditional_effects", [])) for s in proc["steps"]),
            "crisis_checkpoints": proc["crisis_checkpoints"],
            "chapters": {k: len(story[k]["lines"]) for k in ("day1", "day2", "day3")},
            "choices": ["A-C1", "C-C2", "G-C3", "H-C4"],
            "runtime_ready": registry_entry["runtime_ready"],
        },
    )
    print(
        f"Imported {ID}: {len(proc['steps'])} stages (54 HP / 729 min / 7 conds); "
        f"story lines={ {k: len(story[k]['lines']) for k in ('day1', 'day2', 'day3')} }"
    )


if __name__ == "__main__":
    main()
