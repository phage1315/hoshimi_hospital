#!/usr/bin/env python3
"""Import the approved Kaori Miyama Lv0 script without altering its Chinese prose."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs/source/lv0_introductions/HOSHIMI_MIYAMA_KAORI_LV0_INTRO_WHITECOAT_SHARP_CN_REVIEW.md"
EVENTS = ROOT / "data/staff/doc_rei/events.json"
EN = {
"m0_0001":"The examination room is temporarily empty. The reports on the desk are stacked in date order, and the screen still shows the imaging she just finished checking.",
"m0_0002":"A young woman doctor stands at the workstation. Her white coat is neat, her posture composed, and her striking features are matched by a seriousness that leaves little room for anyone to bluff.",
"m0_0003":"Sakaguchi knocks twice at the door. She finishes writing the line in front of her before looking up and glancing at his name badge.",
"m0_0004":"Dr. Sakaguchi Ryuji?",
"m0_0005":"Yes. I’m Sakaguchi Ryuji, newly appointed here. It’s a pleasure to meet you. Sorry to interrupt.",
"m0_0006":"Kaori Miyama. I mainly work in surgery, and I’m currently also responsible for emergency cases. I look forward to working with you.",
"m0_0007":"Miyama gives him a slight nod and briefly shakes his hand. It is courteous, but she makes no attempt to extend the greeting into small talk.",
"m0_0008":"The director mentioned your record. Your overseas training is impressive.",
"m0_0009":"I’m grateful for the director’s trust. But a résumé is a résumé; I still have to start from the beginning when it comes to the work itself.",
"m0_0010":"That’s a sensible thing to say. Patients don’t become easier to handle just because your résumé looks good.",
"m0_0011":"That’s true.",
"m0_0012":"Especially at the operating table. Your clinical judgment can’t be answered for by your résumé.",
"m0_0013":"I understand. I hope we’ll have a chance to work together, Dr. Miyama.",
"m0_0014":"We certainly will. When that happens, I’ll care more about what you do than where you studied.",
"m0_0015":"That’s the fairest way to judge someone.",
"m0_0016":"Miyama studies him for a moment, the corner of her mouth lifting slightly as if his answer is acceptable. She closes the report folder and finally gives him her full attention.",
"m0_0017":"May I ask, Dr. Miyama—are you related to Professor Soichiro Miyama?",
"m0_0018":"Miyama is about to put down the folder when her fingers pause. Her smile fades.",
"m0_0019":"He’s my father.",
"m0_0020":"I see. I read some of his papers while I was overseas. He is a highly respected surgeon and professor.",
"m0_0021":"Thank you. My father’s research in that field is certainly worth studying.",
"m0_0022":"I imagine he influenced your decision to go into surgery.",
"m0_0023":"Of course. But if you’re wondering whether I’m capable, my father’s name won’t help me prove it.",
"m0_0024":"I’m sorry. I didn’t mean to let your family name stand in for my judgment of you.",
"m0_0025":"Good. I won’t spare you my own judgment just because the director praised you, either.",
"m0_0026":"As it should be.",
"m0_0027":"After all, when we work together in the operating room, neither of us can rely on a reputation to take responsibility for the other.",
"m0_0028":"She opens the folder again, her expression returning to its earlier, orderly calm.",
"m0_0029":"I trained at a medical school here in Japan, mainly in surgery, and now I also cover emergency cases. You spent years training overseas, so the clinical workflows you encountered must have been different. Would you tell me a little about how you approach a case?",
"m0_0030":"Of course. What would you like to discuss, Dr. Miyama?",
"m0_0031":"Suppose the emergency department sends over a case of abdominal pain, and the report says only, ‘Stable; recommend observation by surgery.’ Would you accept that conclusion at face value, Dr. Sakaguchi?",
"m0_0032":"No. I’d first confirm when the symptoms began, when the tests were done, and what changed afterward. Without that, the word ‘stable’ has no basis.",
"m0_0033":"Mm. At least you wouldn’t hear ‘stable’ and immediately relax.",
"m0_0034":"How would you handle it, Dr. Miyama?",
"m0_0035":"Start by laying out all the facts. When the pain began, when the tests were done, and what happened afterward; which risks have been ruled out, and which haven’t. If the information is incomplete, clarify it first. When it’s time to decide, don’t keep putting it off.",
"m0_0036":"You don’t like leaving the judgment to the next shift.",
"m0_0037":"What I don’t like is when everyone says ‘let’s wait and see’ even though someone needs to make a judgment. If surgery really is necessary, I’ll explain why and take responsibility for my decision.",
"m0_0038":"Understood. It sounds like working with you will be quite a challenge, Dr. Miyama.",
"m0_0039":"That depends on whether you can keep up. Next time we get a chance, I’ll see what you can do in the operating room.",
"m0_0040a":"Then I’ll answer with my performance.",
"m0_0041a":"Good. I’d rather trust what I’ve seen with my own eyes, too.",
"m0_0040b":"It sounds like you set a rather high bar for new colleagues.",
"m0_0041b":"For everyone. Myself included.",
"m0_0042":"Sakaguchi is about to reply when the examination-room door suddenly swings open.",
"m0_0043":"Dr. Miyama! The woman scheduled for your next operation got very agitated once she was on the table. She was crying and making a scene, saying she doesn’t want surgery and wants to cancel!",
"m0_0044":"Miyama listens without even raising an eyebrow, then turns to the last page of the report in her hand.",
"m0_0045":"Has her condition changed?",
"m0_0046":"No! We rechecked the surgical indications today, and the team is ready. She’s just suddenly frightened and refusing to go through with it.",
"m0_0047":"Give her a sedative and let her sleep. She signed the consent form, and the whole team is ready. She can’t just cancel like that... Besides, with her condition, she’s unlikely to survive without the operation.",
"m0_0048":"Understood. I’ll notify the operating room.",
"m0_0049":"The nurse turns and hurries away. Miyama closes the report and puts it back where it was.",
"m0_0050":"That’s enough for now. I have an operation to perform.",
"m0_0051":"Understood. Go ahead; sorry for taking up your time today.",
"m0_0052":"No need to apologize. I’ll remember our conversation today. We’ll see how you perform from here on.",
"m0_0053":"See you in the operating room next time, Dr. Sakaguchi.",
"m0_0054":"She gives Sakaguchi a slight nod. The hem of her white coat sways as she walks, and in a moment she has left the examination room, heading for the operating area.",
"m0_0055":"...What a decisive doctor.",
"m0_0056":"Sakaguchi watches the way she went, then looks down at the hospital information in his hands. Kaori Miyama is certainly a name he’ll remember.",
}

def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))

def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    marker = re.compile(r"【事件节点 (M0-[0-9]{4}[AB]?)｜([^】]+)】\s*\n(.*?)(?=\n\s*【事件节点|\n\s*【分支汇合|\n\s*【事件结束|\n\s*---)", re.S)
    rows = []
    for raw_id, role, block in marker.findall(source):
        content = next((line.strip() for line in block.splitlines() if line.strip()), "")
        if not content:
            raise ValueError(f"Empty dialogue node: {raw_id}")
        node_id = raw_id.lower().replace("-", "_")
        speaker = "narrator" if role == "旁白" else "player" if role.startswith("坂口") else "actor" if role == "深山佳織" else "actor"
        label = "手术室护士" if role == "手术室护士" else "坂口隆司·内心独白" if "内心独白" in role else ""
        prefix = re.match(r"^(?:旁白|深山佳織|坂口隆司(?:（心想）|·内心独白)?|手术室护士)：\s*", content)
        if prefix:
            content = content[prefix.end():]
        if content.startswith("「") and content.endswith("」"):
            content = content[1:-1]
        if content.startswith("「") and content.endswith("」"):
            content = content[1:-1]
        row = {"id": node_id, "speaker": speaker, "presentation": "authored", "text": content}
        if label: row["speaker_label"] = label
        if node_id in {"m0_0043", "m0_0046", "m0_0048"}:
            row.update({"hide_portrait": False, "actor_id": "nurse_sonoda_itsumi", "outfit": "scrubs"})
        if node_id in {"m0_0055", "m0_0056"}: row["hide_portrait"] = True
        rows.append(row)
    if len(rows) != 58:
        raise ValueError(f"Expected 58 authored dialogue nodes (54 shared plus 4 branch alternatives), parsed {len(rows)}")
    if set(EN) != {row["id"] for row in rows}:
        raise ValueError("English translation IDs do not match source node IDs")
    by_id = {row["id"]: row for row in rows}
    expression_changes = {
        "m0_0001":"neutral", "m0_0004":"smile", "m0_0010":"competitive_smile",
        "m0_0017":"neutral", "m0_0019":"serious", "m0_0020":"neutral",
        "m0_0023":"competitive_smile", "m0_0025":"neutral", "m0_0029":"neutral",
        "m0_0033":"smile", "m0_0037":"competitive_smile", "m0_0043":"neutral",
        "m0_0050":"neutral", "m0_0053":"competitive_smile",
    }
    expression = "neutral"
    for row in rows:
        expression = expression_changes.get(row["id"], expression)
        row["expression"] = expression
    choice_labels = {"zh_CN": ["到时候用实际表现回答。", "您的标准似乎很严格。"], "en": ["Then I’ll answer with my performance.", "It sounds like you set a rather high bar for new colleagues."]}
    choices = []
    for cid, index, target in [("answer_with_work",0,"m0_0040a"),("remark_on_standards",1,"m0_0040b")]:
        choices.append({"id":cid,"label":{"zh_CN":choice_labels["zh_CN"][index],"en":choice_labels["en"][index]},"next":target,"effects":{"affection":0,"familiarity":0},"flags":[]})
    by_id["m0_0039"]["choices"] = choices
    for branch in ["m0_0041a", "m0_0041b"]:
        by_id[branch]["next"] = "m0_0042"
    by_id["m0_0056"]["next"] = "@end"
    event = load_json(EVENTS)
    current = next(row for row in event if row.get("id") == "intro_doc_rei")
    nodes = []
    for index, authored in enumerate(rows):
        node = dict(authored)
        next_id = str(node.pop("next", rows[index + 1]["id"] if index + 1 < len(rows) else "@end"))
        if "choices" not in node:
            label = {"zh_CN":"继续  ▷", "en":"Continue  ▷"} if next_id != "@end" else {"zh_CN":"结束  ▷", "en":"Finish  ▷"}
            node["choices"] = [{"id":("continue_" if next_id != "@end" else "finish_")+node["id"],"label":label,"next":next_id,"effects":{"affection":0,"familiarity":0},"flags":[]}]
        nodes.append(node)
    current.update({"title":"先把事实说全","teaser":"深山佳織从检查结果上抬起头。","start":"m0_0001","hide_completion_portrait":True,"nodes":nodes})
    current.pop("script", None)
    current["gallery"]["caption"] = "先把事实说全"
    EVENTS.write_text(json.dumps(event, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    locale_en_path = ROOT / "data/localization/en.json"
    locale_zh_path = ROOT / "data/localization/zh_CN.json"
    en_doc, zh_doc = load_json(locale_en_path), load_json(locale_zh_path)
    for doc in [en_doc, zh_doc]:
        strings = doc.setdefault("strings", {})
        prefix = "collections.character_events.intro_doc_rei."
        active_keys = {prefix+"title", prefix+"teaser", prefix+"gallery.caption"}
        for row in rows:
            node_key = prefix + "nodes." + row["id"]
            active_keys.add(node_key + ".text")
            if row.get("speaker_label"):
                active_keys.add(node_key + ".speaker_label")
        for key in list(strings):
            if key.startswith(prefix+"nodes.") and key not in active_keys:
                strings.pop(key)
        strings[prefix+"title"] = "Give Me All the Facts First" if doc is en_doc else "先把事实说全"
        strings[prefix+"teaser"] = EN["m0_0001"] if doc is en_doc else "深山佳織从检查结果上抬起头。"
        strings[prefix+"gallery.caption"] = "Give Me All the Facts First" if doc is en_doc else "先把事实说全"
        for row in rows:
            key = prefix + "nodes." + row["id"]
            strings[key+".text"] = EN[row["id"]] if doc is en_doc else row["text"]
            if row.get("speaker_label"):
                strings[key+".speaker_label"] = ("Operating Room Nurse" if row["id"] in {"m0_0043", "m0_0046", "m0_0048"} else "Sakaguchi (thinking)") if doc is en_doc else row["speaker_label"]
    locale_en_path.write_text(json.dumps(en_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    locale_zh_path.write_text(json.dumps(zh_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Imported {len(rows)} authored beats; bilingual localization written.")

if __name__ == "__main__": main()
