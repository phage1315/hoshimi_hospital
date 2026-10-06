#!/usr/bin/env python3
"""Deterministic terminology and pronoun cleanup for the narrative MT pass."""

from __future__ import annotations

import json
import re
from pathlib import Path
from collection_io import load_collection
from staff_bundles import load_staff_bundles

ROOT = Path(__file__).resolve().parents[1]
LOCALE = ROOT / "data/localization/en.json"
TARGETS = {
    "character_events": ROOT / "data/events/character_events/index.json",
    "micro_events": ROOT / "data/events/micro_events.json",
    "special_event_steps": ROOT / "data/events/special_event_steps/index.json",
}
FIELDS = {
    "name", "family_name", "given_name", "professional_name", "title", "subtitle",
    "description", "label", "text", "prompt", "response", "teaser", "caption",
    "announcement", "location_label", "speaker_label", "specialty", "personality",
    "presenting_complaint", "diagnosis", "intake_notes", "result", "summary", "section",
    "correction",
}
FEMALE_MARKERS = (
    "阿库娅", "佳織", "深山", "七瀬", "恋", "成美", "美佳", "美幸", "真奈美", "安琪",
    "弘子", "萌惠", "江美子", "御堂", "明日香", "阿尔托莉雅", "詩織", "诗织", "小夜香",
    "南条", "摩耶", "双叶", "彩子", "女医生", "女患者", "女护士",
    "皐月", "折川", "百合香", "御统",
)


def walk(value: object, path: str, out: dict[str, str]) -> None:
    if isinstance(value, dict):
        for field, child in value.items():
            child_path = f"{path}.{field}"
            if field in FIELDS and isinstance(child, str):
                out[child_path] = child
            walk(child, child_path, out)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            identity = str(child.get("id", index)) if isinstance(child, dict) else str(index)
            walk(child, f"{path}.{identity}", out)


def female_pronouns(text: str) -> str:
    substitutions = (
        (r"\bhimself\b", "herself"), (r"\bHimself\b", "Herself"),
        (r"\bhe's\b", "she's"), (r"\bHe's\b", "She's"),
        (r"\bhis\b", "her"), (r"\bHis\b", "Her"),
        (r"\bhim\b", "her"), (r"\bHim\b", "Her"),
        (r"\bhe\b", "she"), (r"\bHe\b", "She"),
    )
    for pattern, replacement in substitutions:
        text = re.sub(pattern, replacement, text)
    return text


def main() -> int:
    locale = json.loads(LOCALE.read_text(encoding="utf-8"))
    strings: dict[str, str] = locale["strings"]
    authored: dict[str, str] = {}
    manifest = json.loads((ROOT / "data/manifest.json").read_text(encoding="utf-8"))
    staff_collections, _bundles = load_staff_bundles(ROOT / "data", manifest["staff_bundles"])
    for collection, path in TARGETS.items():
        rows = load_collection(path) + staff_collections.get(collection, [])
        walk(rows, f"collections.{collection}", authored)

    for key, source in authored.items():
        if key not in strings:
            continue
        english_lines = strings[key].splitlines()
        source_lines = source.splitlines()
        if len(english_lines) == len(source_lines):
            fixed: list[str] = []
            for original, translated in zip(source_lines, english_lines):
                female_only = "她" in original and "他" not in original and "坂口" not in original
                female_patient = "患者" in original and "坂口" not in original and "男" not in original
                named_female = any(marker in original for marker in FEMALE_MARKERS) and "坂口" not in original and "他" not in original
                if female_only or female_patient or named_female:
                    translated = female_pronouns(translated)
                if "手术台" in original or "手術台" in original or "台上" in original:
                    translated = re.sub(r"\bon the stage\b", "on the operating table", translated, flags=re.I)
                    translated = re.sub(r"\bput back on the stage\b", "placed back on the operating table", translated, flags=re.I)
                fixed.append(translated)
            strings[key] = "\n".join(fixed)

    global_replacements = {
        "Sakaguchi Takashi": "Ryuji Sakaguchi",
        "Midang": "Mido",
        "Midou": "Mido",
        "Deputy Minister of Surgery": "Deputy Chief of Surgery",
        "operating room dressing room": "operating-room changing room",
        "light green sweatshirts and trousers": "light green scrubs",
        "Beside the pool": "At the scrub sink",
        "next menstrual cycle": "next menstrual period",
        "blood routine": "complete blood count",
        "the technology is very good": "his surgical technique is excellent",
        "Wutai": "Five cases",
        "What Five cases?": "Five cases of what?",
        "losing Ren": "a breakup",
        "opened up a man's abdominal cavity": "opened a woman's abdominal cavity",
        "everything about her looked healthy": "every structure inside looked healthy",
        "Then I discovered": "Then they discovered",
        "put back on the stage": "placed back on the operating table",
        "on the stage": "on the operating table",
        "Medicine is business.": "Medicine is serious work.",
        "Mido explained his judgment": "Mido explained her judgment",
        "Mido glanced at Sakaguchi and immediately returned to his original position": "Mido glanced at Sakaguchi and immediately returned to her original position",
        "Mido didn't rush to give an answer, he just asked": "Mido didn't rush to give an answer; she only asked",
        "Honjo lowered his head": "Honjo lowered her head",
        "Honjo raised his head": "Honjo raised her head",
        "the excitement on his face has long since disappeared": "the excitement on her face had long since disappeared",
        "Miyuki Asakura took off his gloves": "Miyuki Asakura took off her gloves",
        "Asakura raised his eyes": "Asakura looked up",
        "The blue-haired doctor straightened his back": "The blue-haired doctor straightened her back",
        "A petite blond doctor stood in the center, the pen in his hand": "A petite blond doctor stood in the center, the pen in her hand",
        "The blond doctor standing behind the desk looked very young, but his posture": "The blond doctor standing behind the desk looked very young, but her posture",
        "a petite figure suddenly poked his head out": "a petite figure suddenly poked her head out",
        "It was Moe Honjo whom I met": "It was Moe Honjo, whom Sakaguchi had met",
        "The real patient was visibly nervous when he walked in, his hands": "The real patient was visibly nervous when she walked in, her hands",
        "it was clear that he had been waiting for a while": "it was clear that she had been waiting for a while",
    }
    prefixes = tuple(f"collections.{name}." for name in TARGETS)
    for key, value in list(strings.items()):
        if not key.startswith(prefixes):
            continue
        for source, target in global_replacements.items():
            value = value.replace(source, target)
        strings[key] = value

    reviewed_titles = {
        "collections.character_events.aqua_intro_exam_chair.title": "New Equipment Trial",
        "collections.character_events.aqua_lv1_gyne_obsession.title": "Don't You Think It's Beautiful?",
        "collections.character_events.artoria_lv1_right_position.title": "Everyone in Their Right Place",
        "collections.character_events.asuka_adjacent_operation_reveal.title": "The Operation Next Door",
        "collections.character_events.asuka_mentions_artoria_rival.title": "Another Candidate for Chief Surgeon",
        "collections.character_events.asuka_scrub_sink_encounter.title": "The Woman at the Scrub Sink",
        "collections.character_events.emiko_intro_rumored_hands.title": "The Rumored Hands",
        "collections.character_events.emiko_lv1_first_operation.title": "Her Kind of Surgery",
        "collections.character_events.emiko_lv2_follow_my_lead.title": "This Time, I'll Follow Your Lead",
        "collections.character_events.emiko_office_denied.title": "An Answer from Outside the Door",
        "collections.character_events.hiroko_lv1_or_instrument_panic.title": "Don't Let Her See",
        "collections.character_events.hiroko_lv1_worth_it.title": "Something Worthwhile",
        "collections.character_events.hiroko_patient_escape.title": "Patient Escapes the Operating Room",
        "collections.character_events.intro_doc_artoria_deputy_office.title": "Office of the Deputy Chief of Surgery",
        "collections.character_events.intro_doc_asuka_director_office.title": "The Woman in the Director's Office",
        "collections.character_events.intro_doc_shiori_whole_patient.title": "The Whole Patient",
        "collections.character_events.intro_doc_shiori_whole_patient_ward.title": "The Consult Request in the Ward",
        "collections.character_events.intro_nurse_ange.title": "First Meeting with Anji Tonegawa",
        "collections.character_events.intro_nurse_hiroko.title": "Yesterday's Operating-Room Nurse",
        "collections.character_events.intro_nurse_moe.title": "The Next Day at the Nurses' Station",
        "collections.character_events.intro_pharmacist_manami.title": "First Visit to the Pharmacy",
        "collections.character_events.intro_visiting_futaba_body_does_not_believe.title": "The Body Still Doesn't Believe It",
        "collections.character_events.intro_visiting_maya_waveform_error.title": "The Wrong Waveform",
        "collections.character_events.moe_wrong_changing_room.title": "The Wrong Changing Room",
        "collections.character_events.sayaka_lv2_working_hours.title": "Working Hours",
        "collections.micro_events.haru_micro_after_gloves.title": "After the Gloves Come Off",
        "collections.micro_events.haru_micro_day_off_alarm.title": "An Alarm on a Day Off",
        "collections.micro_events.haru_micro_drink_temperature.title": "Just the Right Temperature",
        "collections.micro_events.haru_micro_missing_sound.title": "A Missing Sound at the Instrument Table",
        "collections.micro_events.haru_micro_name_timing.title": "When You Say Her Name",
        "collections.micro_events.haru_micro_one_quiet_minute.title": "One Quiet Minute",
        "collections.micro_events.haru_micro_patient_hands.title": "The Hands She Kept Clenched",
        "collections.micro_events.haru_micro_pocket_candy.title": "Candy in a Uniform Pocket",
        "collections.micro_events.haru_micro_thank_whom.title": "Who Deserves the Thanks?",
        "collections.micro_events.yui_micro_cafeteria_score.title": "Rating the New Cafeteria Menu",
        "collections.micro_events.yui_micro_dessert_bargain.title": "A Dessert Bargain",
        "collections.micro_events.yui_micro_handoff_code.title": "The Handoff Code",
        "collections.micro_events.yui_micro_if_i_were_patient.title": "If I Were the Patient",
        "collections.micro_events.yui_micro_last_train_stop.title": "The Last Stop",
        "collections.micro_events.yui_micro_long_procedure_name.title": "Hoshimi's Magic Abbreviations",
        "collections.micro_events.yui_micro_no_work_ten_minutes.title": "No Talking Shop for Ten Minutes",
        "collections.micro_events.yui_micro_notebook_question.title": "Questions in the Workflow Notebook",
        "collections.micro_events.yui_micro_red_keychain.title": "The Red Keychain",
        "collections.micro_events.yui_micro_steady_hands.title": "Our First Time Working This Procedure Together",
        "collections.special_event_steps.miyama_02_manga_artist_wrong_patient_main.title": "Research Gone Too Far",
        "collections.special_event_steps.or_acceptance_training_01_main.title": "New Operating Room Acceptance and Training",
    }
    strings.update(reviewed_titles)

    locale["strings"] = dict(sorted(strings.items()))
    LOCALE.write_text(json.dumps(locale, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
