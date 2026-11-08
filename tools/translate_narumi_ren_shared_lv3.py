#!/usr/bin/env python3
"""Translate only the Narumi/Ren shared Lv3 event into English.

The source-to-node mapping remains owned by import_narumi_ren_shared_lv3.py.
This helper fills the reviewable translation sidecar and never touches other
events or sends project files/assets to the translation endpoint.
"""
from __future__ import annotations

import json
import re
import time
import argparse

from import_narumi_ren_shared_lv3 import TRANSLATIONS, parse_beats
import translate_english_narrative as mt


HAN = re.compile(r"[\u3400-\u9fff]")

EVENT_GLOSSARY = {
    "六合塚弥生": "Yayoi Kunizuka",
    "六合塚 弥生": "Yayoi Kunizuka",
    "比良坂竜二": "Ryuji Hirasaka",
    "比良坂 竜二": "Ryuji Hirasaka",
    "神宮寺成美": "Narumi Jinguji",
    "七瀬恋": "Ren Nanase",
    "中井美佳": "Mika Nakai",
    "城宮明日香": "Asuka Jogu",
    "水城阿库娅": "Aqua Mizuki",
    "深山佳織": "Kaori Miyama",
    "坂口隆司": "Ryuji Sakaguchi",
    "神宮寺医生": "Dr. Jinguji",
    "七瀬护士": "Nurse Nanase",
    "中井护士": "Nurse Nakai",
    "霜月美佳": "Mika Shimotsuki",
    "六合塚小姐": "Ms. Kunizuka",
    "比良坂医生": "Dr. Hirasaka",
    "神宮寺": "Jinguji",
    "六合塚": "Kunizuka",
    "比良坂": "Hirasaka",
    "成美": "Narumi",
    "弥生": "Yayoi",
    "美佳": "Mika",
    "明日香": "Asuka",
    "阿库娅": "Aqua",
    "佳織": "Kaori",
    "七瀬": "Nanase",
    "恋": "Ren",
    "硬膜外麻醉": "epidural anesthesia",
    "左侧卵巢子宫内膜异位囊肿": "left ovarian endometrioma",
    "卵巢子宫内膜异位囊肿": "ovarian endometrioma",
    "盆腔深部粘连": "deep pelvic adhesions",
    "卵巢皮质": "ovarian cortex",
    "无影灯": "surgical light",
    "平车": "gurney",
    "器械台": "instrument table",
    "巡回护士": "circulating nurse",
    "无菌铺巾": "sterile draping",
    "术野": "operative field",
    "关腹": "abdominal closure",
    "敷料": "dressing",
    "星见医院": "Hoshimi Hospital",
}

POSTEDIT = {
    "nr3_001": "The pelvic imaging report on the desk lay open to its third page.",
    "nr3_002": "Ryuji Sakaguchi studied the grayscale images on the lightbox and monitor, then enlarged one section.",
    "nr3_003": "The young woman seated across from him was Yayoi Kunizuka, age twenty-four. Her long hair was neatly arranged, and she wore a subdued knit cardigan. With both hands resting properly on her knees, she looked quiet and self-possessed, though the fatigue of living with chronic pain still showed between her brows.",
    "nr3_005": "\"More than two years. The attacks have become much more frequent over the past six months. Some days I can barely stay on my feet or make it through work.\"",
    "nr3_006": "\"How effective was the conservative drug treatment you received at the other hospital?\"",
    "nr3_008": "Sakaguchi opened the records from her previous examinations.",
    "nr3_009": "\"There is a clear endometriotic cyst on the left ovary, along with lesions near the deep posterior fornix. The MRI suggests fairly complex local adhesions.\"",
    "nr3_010": "Yayoi's fingers tightened slightly.",
    "nr3_012": "\"You do not have to decide this very minute. First, let me explain what continued medical management can do, what open surgery may resolve, and what surgery cannot promise to resolve completely.\"",
    "nr3_013": "Some of the tension left Yayoi's shoulders.",
    "nr3_016": "Her answer was decisive, as though she had already weighed the choice over and over before coming here.",
    "nr3_017": "Then she took a neatly sealed referral letter from her folder and slid it across the desk.",
    "nr3_018": "\"Actually... another doctor recommended that I make an appointment with you at Hoshimi Hospital.\"",
    "nr3_023": "\"That is a generous introduction. What is the doctor's name?\"",
    "nr3_024": "Yayoi paused, her calm gaze resting on Sakaguchi.",
    "nr3_026": "Sakaguchi's fingers paused as he unfolded the letter.",
    "nr3_027": "A familiar signature appeared at the bottom of the page.",
    "nr3_021": "\"A specialist in gynecology. I previously handled external data organization and research coordination for his group, and I also consulted him about my condition. He said Hoshimi Hospital had recently hired a highly versatile surgeon who returned from overseas.\"",
    "nr3_028": "During a ten-minute meeting in the director's office a few days earlier, Asuka Jogu's words echoed in Sakaguchi's mind—『Someone like Hirasaka might not readily believe Mika Shimotsuki's fabricated report... If he keeps probing Hoshimi by subtler means, he may approach your surgical clinic directly.』",
    "nr3_030": "Ryuji Sakaguchi kept his expression perfectly natural as he slipped the referral letter into the patient's chart.",
    "nr3_031": "\"Understood. I will keep the referral letter, but in this consulting room, we will discuss only your condition.\"",
    "nr3_032": "Yayoi Kunizuka raised her head slightly and gave him a surprised glance.",
    "nr3_033": "\"No matter who referred you, only one question matters here: what treatment do you need?\"",
    "nr3_034": "After the afternoon clinic ended, Sakaguchi brought Yayoi's pelvic films and admission assessment to the surgical office.",
    "nr3_035": "Narumi stood at the lightbox and studied the images for a long while.",
    "nr3_036": "\"Deep infiltrating lesions are far more difficult than an ordinary endometrioma. Judging only from her outpatient complaint, one might assume this was a simple ovarian cyst, but adhesions along the posterior wall and beneath the broad ligament have already distorted the left adnexa.\"",
    "nr3_042": "Ryuji Sakaguchi drew the referral letter from the bottom of the chart folder and set it gently on the desk in front of Narumi.",
    "nr3_043": "\"There is one more thing you need to know right away.\"",
    "nr3_045": "Her pen stopped in midair. Without writing another mark, she quietly set down the imaging report.",
    "nr3_046": "\"...Ryuji Hirasaka. What the director feared has happened after all.\"",
    "nr3_047": "\"Mika Shimotsuki's report claiming she had found no such people failed to dispel his suspicions completely.\"",
    "nr3_065": "The tension in Ren's shoulders eased, and she set the documents firmly on the desk.",
    "nr3_064": "\"Whatever Hirasaka may be plotting behind the scenes, once a patient is on Hoshimi's operating table, our only concern is treating her illness.\"",
    "nr3_068": "A determined glint crossed Narumi Jinguji's eyes, and she nodded softly.",
    "nr3_067": "\"Since he came openly through a legitimate referral, we will answer his move with an impeccable operation.\"",
    "nr3_073": "\"Yes. Let's report this to the director first.\"",
    "nr3_074": "After hearing the three of them out, Asuka closed the administrative papers she had been about to sign and set them aside.",
    "nr3_076": "\"And this time he learned to be clever. Instead of sending a sales representative to wander through the hospital, he referred a young woman who had handled data for his group and genuinely needed surgery for a complex gynecological condition.\"",
    "nr3_084": "\"I support the plan. The deep lesions are in a very difficult location. With Dr. Jinguji as first assistant, we will have a much better chance of preserving healthy ovarian tissue.\"",
    "nr3_088": "\"Ren, Narumi—you both understand that the moment you appear in her ward and operating room, you will be confirming with your own hands that the people Hirasaka is seeking are at Hoshimi.\"",
    "nr3_089": "Ren met Asuka's gaze and nodded without hesitation.",
    "nr3_086": "\"Director, I would also like permission to scrub in as the instrument nurse.\"",
    "nr3_092": "\"Absolutely not. This time she is a genuine patient, and I am responsible for the instruments and perioperative nursing. She is coming to the operating table to be treated, not interrogated.\"",
    "nr3_095": "\"Very well. The clinical roster will be determined by the needs of the case and each person's qualifications. I approve the three of you forming the team for this case, with the experienced Mika Nakai assigned as circulating nurse. The previous violation will remain in the internal record. I will not relax medical standards simply because you know the person behind this—but I trust your professionalism as doctors and nurses.\"",
    "nr3_098": "\"Thank you, Director.\"",
    "nr3_100": "Yayoi, now wearing a hospital gown, sat quietly on the edge of the bed. A novel with a worn, faded cover and several neatly folded pages of sheet music lay on the bedside table.",
    "nr3_107": "\"I noticed when I came in. You kept the book open, but you did not seem to turn a single page.\"",
    "nr3_116": "Yayoi Kunizuka raised her eyes and quietly studied the young nurse before her.",
    "nr3_124": "\"I know your name is Yayoi Kunizuka, you are twenty-four, and you are scheduled for surgery tomorrow morning.\"",
    "nr3_133": "\"More importantly, as your nurse tonight, I want to know whether you were staring at that book because you are still worried about tomorrow's operation but feel too embarrassed to ask us about it.\"",
    "nr3_134": "Yayoi regarded Ren in silence for a long moment.",
    "nr3_135": "Only the steady beeping of the monitor filled the ward. After a moment, the usually composed young woman lowered her voice almost to a whisper.",
    "nr3_139": "Moisture gathered in Yayoi's eyes. She drew a careful breath.",
    "nr3_145": "\"The surgeons need to explain that to you properly from a professional standpoint. I will contact Dr. Sakaguchi now and ask him and Dr. Jinguji to go over the details with you in person during tomorrow morning's preoperative discussion. All right?\"",
    "nr3_151": "Sakaguchi and Narumi spread the preoperative information sheets, including diagrams of the pelvic anatomy, in front of Yayoi.",
    "nr3_154": "\"Preserving healthy tissue and its blood supply will be our first priority. But in the interest of medical honesty, we cannot promise you an absolute outcome before we open the abdomen. The true extent of excision and adhesiolysis will depend on what we actually find during surgery.\"",
    "nr3_156": "\"Endometriosis does carry a long-term risk of recurrence. In a very small number of cases, densely infiltrating lesions must also be treated in stages to protect adjacent organs. Even so, removing the major existing lesions and releasing the adhesions under tension should significantly relieve your pain and improve your quality of life.\"",
    "nr3_157": "Yayoi listened with complete attention.",
    "nr3_160": "Yayoi gave a small nod.",
    "nr3_128": "\"Then what if I told you that, besides coming here for treatment with Dr. Hirasaka's referral letter, I also agreed to verify something for him?\"",
    "nr3_172": "\"If you know I came here to act as his eyes, why did you still volunteer to scrub in and help operate on me?\"",
    "nr3_176": "She looked up at the surgical light, not yet turned to full brightness, then saw Ren Nanase counting instruments beside the sterile instrument table and circulating nurse Mika Nakai preparing the monitors near the operating table.",
    "nr3_177": "Ren was already in a sterile gown, surgical cap, and mask. At the sound of the gurney, she turned toward Yayoi, her eyes crinkling in a reassuring smile.",
    "nr3_184": "Narumi Jinguji had completed Yayoi Kunizuka's epidural catheter placement and sensory-level check as planned. All preoperative preparations and sterile draping were ready. After scrubbing, gowning, and gloving, Narumi took her position as first assistant opposite Ryuji Sakaguchi.",
    "nr3_187": "Ryuji Sakaguchi looked toward Narumi at the first-assistant position and extended his right hand:",
    "nr3_188": "\"Let's begin. Scalpel.\"",
    "nr3_191": "Under epidural anesthesia, the awake Yayoi Kunizuka felt no sharp pain as the lower abdominal incision was opened layer by layer. Behind the anesthesia screen and drapes, she could hear only the faint clink of instruments and the steady breathing of the surgical team.",
    "nr3_197": "As the deep pelvic tissues were gently retracted, Yayoi Kunizuka felt a distinct dull pressure and pulling sensation deep in her lower abdomen beneath the drapes, and instinctively held her breath.",
    "nr3_198": "Circulating nurse Mika Nakai, stationed at the head of the table, immediately noticed the slight rise in Yayoi's heart rate and reassured her gently:",
    "nr3_199": "\"Ms. Kunizuka, the doctors are releasing the adhesions deep in your pelvis now. Some pressure and pulling inside your abdomen is normal. Just follow me and take slow, deep breaths.\"",
    "nr3_201": "Yayoi Kunizuka answered softly and listened quietly to the team at work beneath the drapes.",
    "nr3_202": "After their earlier experience operating together, Sakaguchi and Narumi needed almost no extra explanation as they exposed the confined deep pelvic operative field one layer at a time.",
    "nr3_203": "\"Wait. This dense nodule lies too close to the critical structure beneath it. We cannot continue along the same plane.\"",
    "nr3_204": "Sakaguchi stopped the dissecting scissors at once.",
    "nr3_206": "The instant Sakaguchi shifted his gaze, Ren Nanase had already placed fresh fine dissecting forceps and a small gauze pledget within his reach.",
    "nr3_207": "\"Dissecting forceps and a gauze pledget are ready.\"",
    "nr3_208": "\"Thank you. Perfect timing.\"",
    "nr3_214": "Narumi's eyes curved into a smile above her mask.",
    "nr3_217": "Lying on the operating table, Yayoi listened as the two surgeons repeatedly confirmed each tissue plane in their effort to preserve healthy ovarian tissue. Hidden in the shadow beneath the drapes, the corners of her eyes grew damp.",
    "nr3_227": "After abdominal closure and dressing, Mika Nakai removed the drapes and, together with an orderly, transferred the conscious and reassured Yayoi Kunizuka smoothly onto a gurney for transport back to the ward.",
    "nr3_229": "The numbness in Yayoi's lower limbs from the epidural had completely resolved. Ryuji Sakaguchi had just finished reviewing her postoperative vital-sign record and wound dressing; Narumi Jinguji and Ren Nanase stood beside the bed.",
    "nr3_231": "\"The operation was completed exactly as planned. We treated the deep adhesions and lesions appropriately, and your recovery is stable so far. We will continue to monitor you closely.\"",
    "nr3_238": "Yayoi shook her head. The calm candor she showed at work had returned to her eyes.",
    "nr3_239": "\"No. There is something I want to tell you clearly, face to face, right now.\"",
    "nr3_241": "\"When Dr. Hirasaka wrote the referral that brought me to Hoshimi Hospital, he did ask me to verify one thing for him: whether Narumi Jinguji and Ren Nanase were truly here.\"",
    "nr3_244": "Yayoi lightly gripped the edge of the blanket with both hands and looked directly at the three of them.",
    "nr3_249": "Yayoi blinked in surprise.",
    "nr3_265": "\"I have explicitly rejected every attempt by an outside organization to use a partnership to interfere with this hospital's staffing. But we all know he will not limit himself to official channels.\"",
    "nr3_262": "\"Ms. Kunizuka is still recovering in the ward, but as she promised before admission, she has already given Hirasaka an honest report. This morning he used a partner organization to inquire about Hoshimi's staffing. The question was very politely phrased—and very specific.\"",
    "nr3_276": "\"No. Dr. Sakaguchi's calculation is correct. Hirasaka has never been the sort to retreat merely because he is frightened, but no one is better at weighing gains and losses. If continuing the investigation carries a genuinely damaging risk while stopping gives him a coveted benefit for free, he will choose the course most profitable to him.\"",
    "nr3_277": "\"Exactly. On one side are the consequences of an independent review that could be triggered at any time; on the other is an immediate benefit that gives him a graceful way out. He will know which choice to make.\"",
    "nr3_280": "\"It sounds as though Dr. Jinguji has already decided what leverage to use against him.\"",
    "nr3_281": "The corner of Narumi's mouth curved faintly as a calm, incisive gleam crossed her eyes.",
    "nr3_282": "\"I have dealt with him for far too long not to know exactly what he fears—and what he covets.\"",
    "nr3_287": "\"These are the research notes, meeting minutes, and records from the special ward that I kept. They are not enough to secure a legal conviction on their own, but several of the irregular arrangements documented here would not survive a formal independent review.\"",
    "nr3_292": "Ren lowered her eyes. Sakaguchi listened in silence without interrupting.",
    "nr3_299": "\"Professor Shizuko Takamine, Professor Tsunehiko Kanbara, and Director Chikage Shirakawa.\"",
    "nr3_304": "\"Director Shirakawa and my mother have been close friends for years. She once said that if a young Hoshimi doctor suffered an injustice, she would at least hear the facts. We can ask those three senior colleagues to review the materials and hold them independently. As long as Hirasaka knows all three are prepared to intervene in a formal investigation if necessary, he will not dare act recklessly.\"",
    "nr3_306": "Kaori Miyama—Asuka's close friend, who also knew the circumstances behind Narumi and Ren's employment—entered the room.",
    "nr3_311": "\"Thank you, Kaori. For now, Professor Takamine and the other two senior colleagues will be enough. There is no need to involve my uncle yet.\"",
    "nr3_314": "Ren glanced toward the door and spoke quietly.",
    "nr3_307": "\"Sorry, Director. I just heard that you were discussing outside assistance.\"",
    "nr3_318": "\"The problem is that, now that we have a credible threat of independent review to keep Hirasaka from acting recklessly, we still need the other half: what research result can we offer as the price that makes him willing to stop? He is a gynecology specialist, so what he wants most is probably a project that can advance his academic standing...\"",
    "nr3_321": "\"Asuka! I came to return the portable drive I borrowed. I thought I heard something interesting as I passed the door. Are you looking for gynecological research? I have plenty!\"",
    "nr3_324": "Aqua had already set her computer on the desk and begun opening folders one after another.",
    "nr3_325": "\"This is a theoretical model for stratifying pelvic imaging; this one predicts tissue-recovery cycles statistically; and this... oh, this is the paper I said I would submit to an international conference last time.\"",
    "nr3_327": "Asuka had been about to send her back out, but the third document made her stop.",
    "nr3_339": "\"The ideas are fascinating, but most of the work focuses on imaging models and theoretical inference.\"",
    "nr3_348": "\"I do not know who you are negotiating with, but if you need to offer Hirasaka a research project, I can pull one from my draft folder. I have plenty more anyway.\"",
    "nr3_346": "\"I'm beginning to think that the research community's failure to discover you is its loss—and a serious failure on my part as director.\"",
    "nr3_350": "\"Thank you, Dr. Mizuki. But put your main project away for now.\"",
    "nr3_358": "Aqua read several pages closely and, unusually for her, did not interrupt at once. After a moment, she spoke with complete seriousness.",
    "nr3_361": "\"Wait. I was the one who suggested offering him a research benefit, but I never expected you to bring out this project. You spent years building it.\"",
    "nr3_352": "Narumi Jinguji took another neatly bound research draft from her folder. Its paper edges were worn from repeated handling, and the pages were densely covered in revision notes of several colors.",
    "nr3_359": "\"This clinical surgical stratification strategy... is far more grounded than my theoretical model. It was built piece by piece through years of work at the operating table.\"",
    "nr3_362": "Narumi Jinguji looked up at him, her gaze clear and composed:",
    "nr3_363": "\"I have thought it through. Then and now, I have always calculated the price I am willing to pay with clear eyes.\"",
    "nr3_365": "\"First, if we hand over Aqua's principal project, Hirasaka will immediately realize that Hoshimi has someone capable of producing new bargaining chips at any time. That would not be a truce; it would be inviting a predator through the door. Second, Hirasaka is a pelvic surgeon himself. He spent years trying—and failing—to establish a tissue-preserving layered approach for deep lesions. Only this unique clinical protocol, which cost me years of work, will convince him that he has gained the better end of the bargain. And only my willingness to surrender priority leadership over the project I kept in reserve will make him understand that I am determined to buy a permanent end to his interference.\"",
    "nr3_370": "\"Even at that price, the intellectual-property boundaries must be explicit. You may yield only priority leadership for the first validation and publication of the unpublished method framework and aggregate analysis. Your genuine original contribution must remain fully credited under ordinary research-collaboration standards, and neither the original research drafts nor the patients' source data can ever become bargaining goods.\"",
    "nr3_374": "\"How about this? Narumi's irreplaceable surgical strategy must remain the main course, but I can extract a limited postoperative-recovery assessment parameter table from my drafts and append it, saving him some statistical work during validation.\"",
    "nr3_384": "\"Exactly. The first layer is the private understanding: he immediately ends every investigation into Hoshimi Hospital, sends no one else to approach Narumi or Ren directly or indirectly, and does not harass Ms. Kunizuka or any of our current patients and colleagues.\"",
    "nr3_385": "\"In exchange, the former-hospital records bearing my signature will be entrusted to Professor Takamine and the other two senior colleagues for independent safekeeping. As long as he follows the rules, the material will never be made public. If he reaches out again, the three of them can initiate a formal professional review at any time.\"",
    "nr3_386": "\"The second layer is the formal research collaboration: subject to compliance review by neutral senior colleagues, Narumi will grant him leadership of the first validation and priority publication for the unpublished methodological framework and aggregate analysis of her stratified surgical strategy, together with Aqua's supporting parameter table. Narumi's genuine original contribution will be credited through the normal research-collaboration process, the original drafts will remain at Hoshimi, and no patient-identifying information will be involved.\"",
    "nr3_391": "Narumi Jinguji reached out and rested her hand gently over the back of Ren's hand:",
    "nr3_392": "\"We cannot appeal to his conscience, but we can make him calculate the costs and benefits. This time, we hold the leverage.\"",
    "nr3_394": "Ryuji Hirasaka did not come to Hoshimi in person. The screen displayed only a single line with the participant's name, while his voice came through the speaker.",
    "nr3_395": "\"It has been a long time, Dr. Jinguji. Nurse Nanase as well. I did not expect to find both of you doing so well.\"",
    "nr3_399": "\"I heard that Ms. Kunizuka underwent a highly successful operation at your hospital. Should I offer Hoshimi my thanks?\"",
    "nr3_401": "Asuka sent the research-collaboration summary to the other party through the conference sharing window.",
    "nr3_402": "\"You have confirmed that Narumi and Ren are here, and we know that you sent people to investigate them. These are the research-collaboration terms we can offer. Meanwhile, Professor Takamine, Professor Kanbara, and Director Shirakawa have been entrusted to hold the relevant former-hospital records independently.\"",
    "nr3_411": "\"If I hand over the original drafts and withdraw the old records held by those three senior colleagues, you will send a third person to Hoshimi tomorrow, won't you? Dr. Hirasaka, we know one another too well. Only if the old hospital records bearing even my own signature remain in Professor Takamine's hands, while priority publication leadership is transferred to you in stages through a normal collaboration process, will the tension remain balanced fairly.\"",
    "nr3_419": "\"...Ren. You have not said a word this whole time.\"",
    "nr3_426": "\"Very well. I have no interest in a bargain that harms us both. I accept your terms. From this moment on, I will stop investigating Hoshimi and send no one else after either of you. Kunizuka's errands for me end here as well. The research authorization and authorship will proceed through the normal academic-collaboration process.\"",
    "nr3_435": "Narumi gave a small nod.",
    "nr3_442": "\"Come back next month for your postoperative follow-up on the date shown here. If you feel any discomfort while recovering, contact the outpatient clinic at once.\"",
    "nr3_443": "Yayoi accepted the follow-up form and looked at the three of them, who were acting as though nothing unusual had happened. She blinked in surprise.",
    "nr3_455": "\"It is. The loss is heavy enough that I nearly stopped several times while preparing the handover summary last night.\"",
    "nr3_460": "\"Still, I made the calculation and signed this agreement myself, so I will honor it. I may have surrendered priority publication leadership, but I still have my clinical experience and the scalpel in my hand. What I have lost, I will earn back piece by piece at Hoshimi's operating tables.\"",
    "nr3_464": "\"Let me be clear in advance, Dr. Sakaguchi: the next time we are in the operating room, I will still point out every problem that needs to be addressed.\"",
    "nr3_466": "Narumi Jinguji looked at him, her voice softening:",
    "nr3_467": "\"And thank you for not lecturing me or treating us as people who can do nothing but accept protection.\"",
    "nr3_469": "A faint smile touched the corner of Narumi's lips.",
    "nr3_470": "\"...I like that answer.\"",
    "nr3_471": "The office door opened and Ren Nanase poked her head inside.",
    "nr3_472": "\"You two! If there is no urgent surgery right now, could you come to the lounge and help me with a very serious problem?\"",
    "nr3_474": "\"I bought three sandwiches for us. Then Dr. Mizuki heard there was food and followed me. She is standing outside the lounge with her laptop, saying she can show us three papers she just finished while we eat—and that this time she even remembered to submit them!\"",
    "nr3_475": "\"...Three papers?\"",
    "nr3_476": "Narumi laughed so hard that she had to steady herself against the bookshelf.",
    "nr3_477": "\"Let's go. We cannot let her put the sandwiches on top of her papers.\"",
    "nr3_478": "The three of them left the surgical office together and headed toward the lively staff lounge.",
    "choice_nr3_063_a": "No matter what Hirasaka may be plotting behind the scenes, once a patient is on Hoshimi's operating table, our only concern is treating her illness.",
    "choice_nr3_276_a": "That's right. On one side are the consequences of an independent review that could erupt at any time; on the other is a ready-made benefit that gives him a way out. He will know which to choose.",
    "choice_nr3_276_b": "It sounds as though Dr. Jinguji has already decided what leverage to use against him.",
    "choice_nr3_452_b": "Any surgeon would be furious at having to hand over a core project she spent years developing to someone like that.",
    "choice_nr3_063_b": "Since he came openly through a legitimate referral, we will answer his move with an impeccable operation.",
}


def source_rows() -> list[tuple[str, str]]:
    rows: list[tuple[str, str]] = []
    for beat in parse_beats():
        rows.append((beat["id"], beat["text"]))
        if len(beat["choices"]) == 2:
            rows.extend((choice["id"], choice["label"]) for choice in beat["choices"])
    return rows


def batches(rows: list[tuple[str, str]]) -> list[list[tuple[str, str]]]:
    result: list[list[tuple[str, str]]] = []
    current: list[tuple[str, str]] = []
    size = 0
    for row in rows:
        cost = len(row[1]) + len(mt.SEPARATOR) + 2
        if current and size + cost > 3000:
            result.append(current)
            current, size = [], 0
        current.append(row)
        size += cost
    if current:
        result.append(current)
    return result


def normalize(value: str) -> str:
    replacements = {
        "Asuka Shiromiya": "Asuka Jogu",
        "Ryuji Sakaguchi-sensei": "Dr. Sakaguchi",
        "Doctor Sakaguchi": "Dr. Sakaguchi",
        "Hoshimi hospital": "Hoshimi Hospital",
    }
    for old, new in replacements.items():
        value = value.replace(old, new)
    return value.strip()


def apply_postedit(values: dict[str, str], sources: list[tuple[str, str]]) -> None:
    source_by_key = dict(sources)
    female_prefixes = (
        "神宮寺成美", "七瀬恋", "六合塚弥生", "城宮明日香", "中井美佳",
        "水城阿库娅", "深山佳織", "成美", "恋", "弥生", "明日香", "美佳", "阿库娅", "佳織", "她",
    )
    for key, value in list(values.items()):
        source = source_by_key.get(key, "").lstrip("「『")
        if source.startswith(female_prefixes) and "他" not in source:
            value = re.sub(r"\bhe\b", "she", value, flags=re.IGNORECASE)
            value = re.sub(r"\bhis\b", "her", value, flags=re.IGNORECASE)
            value = re.sub(r"\bhimself\b", "herself", value, flags=re.IGNORECASE)
        values[key] = value
    values.update(POSTEDIT)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()
    mt.GLOSSARY.update(EVENT_GLOSSARY)
    existing = json.loads(TRANSLATIONS.read_text(encoding="utf-8"))
    all_rows = source_rows()
    pending = all_rows if args.force else [(key, text) for key, text in all_rows if not str(existing.get(key, "")).strip()]
    work = batches(pending)
    print(f"Translating {len(pending)} Lv3 fields in {len(work)} batches")
    for index, batch in enumerate(work, 1):
        translated = mt.translate_batch(batch)
        existing.update({key: normalize(value) for key, value in translated.items()})
        TRANSLATIONS.write_text(
            json.dumps(existing, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(f"Batch {index}/{len(work)}: {len(batch)} fields")
        time.sleep(0.15)
    apply_postedit(existing, all_rows)
    TRANSLATIONS.write_text(
        json.dumps(existing, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    unresolved = [key for key, _ in all_rows if not str(existing.get(key, "")).strip() or HAN.search(str(existing[key]))]
    if unresolved:
        print("Unresolved fields:")
        print("\n".join(unresolved))
        return 1
    print(f"Lv3 English sidecar complete: {len(all_rows)} fields")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
