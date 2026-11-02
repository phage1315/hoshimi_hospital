# Hoshimi Hospital | Staff-as-Patient Advanced 3-Day Special Event: Full 24-Character Script & Codex Implementation Contract (English Version)

**Version:** V2.3 Final Creative Draft / Codex Handoff (2026-11-01 — Updated with `100%-50%-0%` XP decay, Thursday / 10:00 scheduling window, zero patient cooldown vs. 14-day assistant intervention cooldown, and expanded Day 3 post-op callbacks to pre-op intimacy and playful teasing for all 24 staff members)

**Nature:** Pre-written scripts for all 24 adult in-hospital medical staff members who currently hold or may hold qualification in the future. Currently, only Sayaka and Serika are confirmed unlockable in live builds; assets and scripts for the remaining 22 characters are stored as preloaded resources and must not be unlocked solely by the existence of this document.

**Coverage:** Day 1 Consultation and Special Pre-Op Night for a staff member's first Advanced Staff Surgery, Day 2 Runner wiring, Day 3 outcome branches (Success / Target Not Met), as well as scheduling windows, cooldowns, XP decay, reputation overrides, and repeat surgery rules. Unapproved Lv5 routes, special Quests, and Legendary procedures remain unaffected.

---

## 0. Writing Baseline: Senior Medical Staff Becoming Advanced Patients

These are not "frail women being wheeled helplessly into an operating theater." They perform surgeries, manage wards, read surgical risk charts, and spend their days coaching patients through major operations; now, they themselves must undergo a formal,十-plus-hour advanced surgery under general anesthesia.

Under the laws of Hoshimi Hospital, this operation **is like undergoing a 100% realistic extreme surgical simulation—except every single step on the operating table is identical to a real major surgery: her skin and muscle layers will truly be incised blade by blade, she will truly bleed, diseased or designated tissues will truly be exposed and resected, and she will truly be sutured layer by layer; the sole difference is that Hoshimi's special recovery guarantee ensures zero permanent harm and rapid post-operative recovery.**

What makes it even more nerve-wracking is the hospital's ironclad rule of **"Locked Upon Signing"**: before putting pen to paper in the consultation room, she is completely free to decline; however, once she signs her name, snaps on the patient wristband, and locks in the hospital's most elite operating room roster, **the major surgical workflow becomes strictly irrevocable**. From the moment the morning nurse walks in for pre-op prep, to lying down on the table for anesthesia induction, being cut open for over ten hours, and waking up to hear the results—even if she is terrified to tears at midnight, wants to bolt from the room, or wishes she could swallow the consent form whole, last-minute cancellation is out of the question. Rationally, she knows she is 100% safe; physically, in the quiet late-night hours after shared pleasure, her body trembles and throws tantrums—especially right after sharing a blissful night with her lover.

**The comedy and tension of this script** come from how they absurdly juxtapose the deeply private, undignified present moment with tomorrow's rigorous major operation: in the afterglow of lovemaking, some suddenly want to steal back and tear up the signed consent form, only to sulk and refuse to put their clothes back on once reminded the schedule is locked, declaring they will wait naked until the morning shift nurses arrive for prep; some hide their wristbands under the covers in tears, begging Sakaguchi to plead with tomorrow's nurses on their behalf before resigning themselves to their fate; others treat ten-plus hours of general anesthesia as a slice of life everyone else is secretly skipping past them. And when they **wake up on Day 3**: if the surgery succeeded, they feel embarrassed recalling how they threw tantrums naked, picked at their wristbands, or tried to run away on the pre-op night, while fondly savoring the lingering warmth of being held and filled by Sakaguchi; if the surgery fell short of its target, they smugly claim "See! I knew something felt off that night!", teasing Sakaguchi ("Did you exhaust all your stamina on me in bed the night before and go soft at the operating table?"), yet as they recall the intense caresses and climaxes of that night, they relent and admit, "Still, considering how good you made me feel that night, taking the knife was well worth it."

### Unified Staging Boundaries for the Adult Intimate Night

* She and Sakaguchi are consenting adult lovers. Inviting him to stay the night is **her personal wish**, not a condition of the consent form or a quid pro quo for surgery. This segment is a fixed VN event and does not launch the H Runner.
* In each character's personalized night scene, both explicitly express their desire for intimacy tonight. Sakaguchi checks the door lock, sets aside his white coat, and removes his clothes; she actively takes off her hospital gown and bra/panties, leaving folded or scattered garments visible beside the bed. Through embraces, kisses, the dipping mattress, dimmed lights, character-specific intimate touches, and layered vocal reactions / gasps / pauses / H-responses during deep union, the player unmistakably experiences that substantive sexual intimacy took place that night. When they speak again under the sheets afterward, it is **the post-coital afterglow**, not "maybe they just cuddled to sleep."
* Each character's **[Intimate Voices After Lights Dim]** preserves a complete progression (from embracing and kissing, skin-to-skin contact, and penetration to the climax and afterglow), including natural vocalizations ("Mmn... / Ah... / Kya... / Haah...") and action narration; **never use a copy-pasted mechanical Q&A template**. Only after the camera and lines finish does the screen fade completely to black, advance the clock, and transition to the aftermath.
* If the player selects **"Skip Special Night"**, skip the intimate sequence and aftermath text, atomically marking the special night as completed per existing rules without affecting Day 2 or Day 3. The daytime consultation must never be skipped alongside the night scene.
* Declaring afterward, "I'll just stay naked until morning and go straight onto the table," is absurd pillow talk inside a private room. **On Day 2, she still puts on a patient gown, completes identity verification, dons a surgical cap, and undergoes all prep and draping required by the procedure configuration**—pillow talk never alters medical workflow.

### Common Day 1 Consultation (Played Before Individual Character Branches)

[Advanced Surgery Consultation Room. The camera pans from the team assembly interface to the surgical plan. The Patient field displays the name of the Staff member sitting across the desk.]

Sakaguchi: "The procedure is `<Current Procedure>`. This is a full-scale advanced operation executed to exact clinical standards, not a mock drill. Take a look through the prep items, team roster, and estimated duration first."

[The Procedure configuration supplies the accurate procedure name, pre-op prep, risks, and estimated duration; general anesthesia is mandatory across the board, without inventing organs or nursing steps not in the data.]

Sakaguchi: "Under general anesthesia, you won't experience the surgery while awake; our hospital's special recovery mechanism also guarantees you will heal completely afterward with zero permanent damage. However, the operation itself is completely real—incision, hemostasis, resection, and closure will all be carried out on your body from start to finish."

Sakaguchi: "Before you put pen to paper, you are free to put this on hold. But the moment you sign your name and snap on that wristband, the hospital's OR schedule and prep workflow are officially locked—there is no canceling halfway until the surgery is over. Have you thought it through?"

[Displays a valid Grand OR team roster. The Staff patient herself cannot occupy any team slot. Upon confirming signature, proceed to the character's individual **[Day 1 | Consultation]**, then transition to the Special Ward at night.]

### Common Framework for Day 2 & Day 3

**Day 2:** Executes the existing Advanced Surgery Runner as normal; the patient is under mandatory general anesthesia, allowing pre-induction and post-awakening reactions, but zero conscious dialogue, field viewing, or awareness of progress during anesthesia. Actual surgical steps are governed by the existing Procedure configuration.

**Day 3:** Reads the persisted `SUCCESS` / `FAILED` result from Day 2 and plays the mutually exclusive personal branch; Day 3 does not launch a second night H scene, but naturally callbacks her pre-op panic and intimate afterglow during the debriefing (shyly savoring the memory on Success; teasing the attending surgeon while admitting the night before made it all worthwhile on Target Not Met). Finally, executes an idempotent one-time settlement using the Staff-overridden XP and Reputation rules.

---

## 1. Confirmed Planned Staff Routes: 15 Full Scripts

### 1.1 Sayaka Nanjo | *Even the School Nurse Wants to Cry Today*

**Day 1 | Consultation**

[Sayaka flips through the surgical plan with a crisp rustle; by the last few pages, her fingers slow down.]

Sayaka: "I actually laughed when I first saw the 'Estimated Duration.' Are the girls planning to cut me open and fuss over me from morning all the way till dinnertime?"

Sakaguchi: "There's still time to close the folder before you sign."

Sayaka: "No way am I closing it. I just didn't expect to become the whole hospital's full-day project. ...Alright, signed and wristband snapped on. Make sure our colleagues don't skip the part where they coax me tomorrow just because I'm a teacher."

**Day 1 | Special Ward, Pre-Op Night**

[The moment she sees Sakaguchi, she sits on the edge of the bed and pats the space beside her, even more direct than usual.]

Sayaka: "Tomorrow I'm really having that huge operation. Dr. Sakaguchi, this is your last chance to put on a good performance."

Sakaguchi: "In what capacity?"

Sayaka: "As my boyfriend, obviously. Don't just stand there telling me 'general anesthesia is perfectly safe' tonight. What I want today is you."

[She tugs him over to make sure no one will barge in, grinning as she watches him lock the door and strip off his white coat and clothes. She tosses her hospital gown onto the chair back, slips off her pink panties, slides naked under the sheet, and tilts her head while patting the pillow beside her.]

Sayaka: "See? The patient is lying down nice and obediently. And right now is definitely not the time for a surgical time-out."

[He leans in to kiss her. The lights dim as the two embrace closely on the bed.]

Sayaka: "Why are you looking at me with such a serious face... You're making me blush!"

Sayaka: "...Mmn. Kiss me again. And no calling me 'Teacher' tonight."

Sakaguchi: "Sayaka."

Sayaka: "Ah... That's how you should call me."

Sayaka: "I was scared out of my wits a minute ago—funny how I feel like laughing now."

Sayaka: "Hey, don't stop to give medical instructions... Tonight we aren't doctor and patient."

Sayaka: "Nnh... Come closer. Let me spoil myself a little longer."

Sayaka: "This feels so good. I wish tonight would never end."

Sayaka: "Your little patient is being so good, lying down on the table tomorrow so you can perform a real major surgery on her—shouldn't you use what's down here to give me a proper reward tonight?"

Sayaka: "Ah, aah...!! Come inside, I want you... Hurry...!!"

[The screen fades completely to black as time passes. When the light returns, the hospital gown and panties she tossed aside earlier are draped across the edge of the bed.]

**Day 1 | Aftermath**

[Flushed and glowing, Sayaka rolls around happily in the sheets—until she glances up, spots tomorrow's pre-op prep sheet clipped to the headboard, and freezes.]

Sayaka: "...Wait a second. What am I doing tomorrow again?"

Sakaguchi: "`<Current Procedure>`."

Sayaka: "Aaaah! Did you have to answer so clearly at a time like this?!"

[She yanks the sheet up, leaving only a pair of resentful eyes peeking out.]

Sayaka: "A minute ago I felt so good I forgot everything, and in a few hours I have to put on a cap, lie stark naked on that operating table, sleep under general anesthesia for over ten hours, and have my belly cut open and worked over inside and out! How did I ever agree to this during the day?! Who signed for me?!"

Sakaguchi: "You did, in person. And the OR roster is locked—even if you cried to the Director right now, it can't be canceled."

Sayaka: "That brave lady who signed her name has clocked out for the night! She strongly demands to withdraw her application!"

Sakaguchi: "Request denied. The nurses will be here with the gurney at eight sharp tomorrow morning."

Sayaka: "Uu... You're so heartless! You just finished sleeping with your girlfriend, and now you put your attending surgeon face right back on!"

[She grabs her panties and patient gown, hesitates for a long moment, then slaps them back onto the foot of the bed.]

Sayaka: "There's no escaping it anyway, right? Then I'm not putting them back on tonight! They're going to strip me bare for prep tomorrow morning either way, so I'll just stay naked until morning! If they want to wheel me onto the table, they can wheel me straight out of these covers!"

Sakaguchi: "...Want me to go borrow a gurney right now?"

Sayaka: "Don't you dare!"

[She laughs until she hiccups, then her eyes suddenly turn red as the plastic wristband brushes against the corner of the duvet.]

Sayaka: "This isn't fair. I know I'll be asleep under general anesthesia, and I know I'll be bouncing around good as new in a couple of days, but when I think about actually taking such a big knife tomorrow with zero chance of running away... why am I still so scared I want to cry?"

[She pulls his hand under the sheet and presses it tightly against her bare chest.]

Sayaka: "Don't give me a sensible answer yet. Since you won't let me desert, you have to let me be completely unreasonable tonight—I'll go back to being an obedient patient after sunrise."

**Day 3 | Success**

Sayaka: "You know what? When the girls were wheeling me into the OR, I nearly left fingernail marks in the side rails, screaming 'Teacher doesn't want to go in!' inside my head. Now that I'm awake in one piece, thinking back to how I threw my panties to the foot of the bed naked and cried for you to cancel my application two nights ago... it's way too embarrassing!"

Sakaguchi: "Who was it that said 'that brave lady has clocked out for the night'?"

Sayaka: "No quoting me! ...Still, when I remember how tightly you held me under the covers that night and made me go weak all over, even after taking the knife for over ten hours, my heart still feels all warm and sweet. Come on, tell me how you got past the hardest step."

**Day 3 | Target Not Met**

Sayaka: "See! I told you my eyelid was twitching when I looked at the prep sheet two nights ago! Crying to desert was pure foresight—we really didn't finish as planned!"

Sakaguchi: "I'll give you a full, honest debriefing. There's no irreversible harm, but I did fail to reach the target this time."

Sayaka: "Hmph. Confess, Dr. Sakaguchi—did you wear me out so hard in bed the night before surgery that you drained all your own stamina and waist strength, and that's why your hands went soft at the operating table the next day?"

[She pokes the back of Sakaguchi's hand with her finger; seeing his serious expression, she bursts into a giggle and blushes, lacing her fingers with his.]

Sayaka: "Alright, I'm just teasing you. Even though falling short is a little disappointing, whenever I think back to how you touched every inch of me two nights ago and drove all the way to my deepest spot until I came again and again... taking this knife was still well worth the ticket price. Hand over the report—your little patient can handle it."

---

### 1.2 Serika Misono | *The Ten-Plus Hours She Cannot See*

**Day 1 | Consultation**

[Serika stares at the patient wristband, turning it a full circle around her wrist. The imaging reports on the desk remain unopened.]

Serika: "I've memorized the files over the past few days. Yet the moment this wristband snapped shut and locked away every exit, it suddenly hit me... I really am not here to read scans for you this time."

Sakaguchi: "Once you sign now, tomorrow's schedule is set in stone."

Serika: "Yes, I'm not changing my mind. Just don't say 'you understand the procedure anyway' in front of me—that'll only make me try harder to act tough."

**Day 1 | Special Ward, Pre-Op Night**

[Serika sits by the window, holding a glass of water she hasn't touched in one hand. When Sakaguchi enters, she speaks before looking up at him.]

Serika: "Don't ask me what I've diagnosed tonight. Let me go a little while without having to judge anything."

Sakaguchi: "May I sit beside you?"

Serika: "Sit closer. ...It took everything I had not to sneak back to the reading room on duty instead of waiting for you in this ward."

[She watches him close the door, quietly making sure the latch clicks shut. Sakaguchi removes his white coat and clothes. Turning her back, Serika unbuttons her hospital gown and slips off her simple pale-blue bra and panties, folding them neatly beside the nightstand; she instinctively crosses an arm over her chest, then lifts the sheet herself, ears burning as she invites him in.]

Serika: "Don't look at my hands shaking. Right now it isn't because of tomorrow... it's because of you."

[The lights dim. They kiss and embrace, hot skin pressing flush beneath the covers.]

Serika: "...I almost said 'thank you, Doctor' just now. How embarrassing."

Serika: "Takashi. Mmn... Is it okay if I call you that?"

Sakaguchi: "Say it again."

Serika: "Takashi... You're being mean. ...Nnh, don't touch right there all of a sudden..."

Serika: "Haah... Don't laugh at me yet. Let me lean on you... hold me tighter."

Serika: "It's strange. Right now I don't want to know anything... I just want you to come all the way inside me so I know you're really here."

[Sakaguchi lowers himself, slowly uniting with her. Serika clutches his shoulders tightly, tilting her neck back with muffled, breathless whimpers.]

Serika: "Ah...! Nnh, mmn... Takashi... So deep... You're filling me up completely..."

Serika: "Don't stop... It's okay if you're a little rougher... Ah, haah... Takashi, Takashi...! I-I'm coming... mmaah...!"

[The streetlight outside the window dims and brightens; the screen fades completely to black as time skips forward. When the light returns, half of the neatly folded pale-blue underwear beside the nightstand has slipped onto the carpet.]

**Day 1 | Aftermath**

[With damp redness still lingering at the corners of her eyes, Serika faces away from Sakaguchi as she slowly pulls up the sheet, steadying her uneven breaths. Outside the room, the faint click of gurney wheels rolling over floor tiles echoes down the hall.]

Serika: "...What was that sound?"

Sakaguchi: "A night-shift gurney."

Serika: "Ah. ...I'll be hearing that tomorrow morning too, won't I."

[She tries to follow up with a joke, but her voice catches.]

Serika: "When you were holding me just now, every single second felt so vivid. Yet tomorrow... they'll put me under general anesthesia and cut me open for real for over ten hours. To the patient, it's closing her eyes and opening them; to all of you standing around the operating table, it's more than half a day. Why does it feel like the whole hospital is secretly living through all those hours while only I get paused?"

Sakaguchi: "Are you afraid of losing that time?"

Serika: "...I don't know. If I hadn't signed my name already, I might have snuck back to the reading room to hide. But the wristband is locked on, so no matter how scared I am tomorrow, I have to lie down on that table."

[She pulls the hospital gown off the chair back, glances at her panties on the carpet, and leaves the gown spread across her knees for a long time without putting it on.]

Serika: "A little while ago, all I cared about was holding onto you, needing no answers at all. Now, even knowing there won't be any permanent harm, I don't even dare put this gown back on... as if putting it on means admitting there's really no escaping tomorrow morning."

[She suddenly glares at him unreasonably, shoves the hospital gown aside, and curls back into his arms stark naked.]

Serika: "I'm not putting it on tonight. They have to change and prep me per protocol tomorrow morning anyway... When the surgery is over and I wake up, will you tell me 'I'm here' in your own voice? Don't just stand at the foot of the bed holding a chart like you're delivering film scans."

Sakaguchi: "I'll be right here."

Serika: "Mmn. ...And if I grab the nurse's sleeve tomorrow morning and refuse to get on the gurney, don't laugh at me right away."

**Day 3 | Success**

Serika: "So ten-plus hours really can vanish just like that. When I first woke up, I thought the anesthesia hadn't even started... Looking back now, hearing a gurney in the hall on the night before surgery and getting so scared I refused to put my clothes on, curling up naked in your arms throwing a tantrum—that was way too pathetic of me."

Sakaguchi: "It's all done, and the result is excellent. And I was right here the whole time."

Serika: "...Yes, you were the first thing I saw when I opened my eyes. Truth is, right before my eyes closed under anesthesia, all I could think about was the warmth of being held so tightly and filled to the brim by you two nights ago... With that memory in my body, those ten-plus blank hours didn't feel so frightening after all. You can hand me the report now."

**Day 3 | Target Not Met**

Serika: "The first thing I said when I woke up was actually 'Has it not started yet?' Only to find out it's already over, and didn't finish as planned... Looks like my heart racing when I heard the gurney two nights ago and wanting to hide in the reading room wasn't entirely my imagination."

Sakaguchi: "I'm sorry. I'll walk you through everything that happened."

Serika: "Don't make that face... If we have to assign blame, maybe it's because on the night before surgery, the attending surgeon spent all his energy bullying his patient in bed instead of saving his strength?"

[She cracks an extraordinarily rare deadpan joke, the tips of her ears turning pink as her fingertips lightly hook around Sakaguchi's.]

Serika: "...Still, I don't regret signing that form. When you came into my deepest place two nights ago, I felt genuinely safe and wonderful. For that night alone, lying on this operating table was worth it. Go ahead—read me the operative note."

---

### 1.3 Emiko Mido | *A Sick Leave Without Command Authority*

**Day 1 | Consultation**

[Discovering her name is absent from every single slot on the surgical team roster, Mido nearly reaches out to edit it.]

Mido: "An irritatingly empty roster. I don't hold a single position on this team?"

Sakaguchi: "You're the patient. And once you sign, even if you lose your temper at the OR doors tomorrow, you can't take back the lead surgeon's spot."

Mido: "I can see that! ...You'd better wipe off that look that says you finally get to make me shut up. Hand me the signature page."

**Day 1 | Special Ward, Pre-Op Night**

[She switches off her work communicator and shuts it inside the drawer as if disposing of hazardous material.]

Mido: "One standing order for tonight: you are forbidden from discussing surgical plans in bed."

Sakaguchi: "Since it's an order, may I file an appeal?"

Mido: "Appeal denied. Tonight I want to be your lover, not your consultation subject."

[She clicks the door lock shut herself; turning around to see Sakaguchi still wearing his white coat, she points at it impatiently.]

Mido: "Take that off too. Don't make me feel like I'm undergoing a department chief's inspection in my own ward."

[He removes all his clothes. Mido crisply unbuttons her patient gown, takes off her black lace-trimmed bra and panties, sets them aside, and sits upright in the center of the bed stark naked; suddenly finding her own posture ridiculous, her ears warm, and she reaches out to pull him down.]

Mido: "I haven't issued the next command. You should be smart enough to know you can kiss me now."

[The bedside lamp dims; as their lips entangle, the usually commanding senior surgeon's breathing gradually loses its composure.]

Mido: "...Mmn. That last line wasn't an order... Your hand—you can move it lower."

Mido: "Closer. Ah... Stop asking for permission... I'm already lying bare in front of you like this."

Sakaguchi: "Emiko, I want you."

Mido: "...Finally, a satisfactory line out of you. ...Nnh, I'm already wet down there, so stop just testing me with your fingers!"

Mido: "Tonight I don't want to be the one who always knows what to do... Hurry up and come inside me, let me forget about managing anything..."

[The instant Sakaguchi drives deep inside her, Mido sucks in a sharp breath, her poised waistline arching tautly as both arms lock around his back.]

Mido: "Aah—! Haah, mmn...! So hot... Hitting the deepest spot right from the start... Are you getting back at me for lecturing you at work...?!"

Mido: "D-Don't stop... Just hold me tight like this...! Ah, nnh... Takashi... I won't act tough anymore, I'm coming... aah...!"

[The screen fades completely to black as the clock advances. Beside the bed, her black lingerie lies half-covered by the crumpled hospital gown.]

**Day 1 | Aftermath**

[Limply leaning against the headboard with residual tremors in her chest, Mido makes no move to dress for a long while, trying to regain her usual composure. The wall clock ticks forward a notch.]

Mido: "...I've just realized an unacceptable fact."

Sakaguchi: "Which is?"

Mido: "Beneath you just now, I couldn't even control my own voice; and tomorrow, once I'm under general anesthesia, I won't even be able to utter a single 'hold' for over ten hours! A surgical chief accustomed to making the final call is about to become a patient lying on the table unable to say a word while being cut open and sutured."

[Irritated, she tugs the corner of the duvet up to cover the kiss marks on her skin.]

Mido: "They say there's a recovery guarantee, that I'll wake up good as new. So what? Just thinking about the nurses putting a cap on me, positioning my limbs, catheterizing and prepping me tomorrow morning—with the schedule locked so I can't even cancel—makes me want to bolt from this bed right now!"

Sakaguchi: "Too bad Dr. Mido signed the form herself this afternoon. Even the Director can't approve a discharge for you now."

Mido: "I don't need your reminder! I'm scared, but I have no intention of revoking my decision!"

[After a brief silence, she glares at the hospital gown and black panties on the floor.]

Mido: "...Patient Emiko Mido hereby declares that effective immediately, she is ceasing cooperation with all non-essential attire. Since they have to prep me from scratch at dawn anyway, I shall remain on standby naked under these covers!"

Sakaguchi: "Is that an official bulletin?"

Mido: "No! ...It's me acting spoiled and throwing a tantrum in bed with you. Can't you even tell that much?"

[She takes his hand again; her fingertips are cool.]

Mido: "If I scowl and say 'don't touch me' tomorrow morning, ask me what I'm actually afraid of first. Don't let everyone assume I only know how to bark orders."

**Day 3 | Success**

Mido: "A respectable surgical score. ...As for the night before surgery, when I sat naked under the covers declaring I was 'ceasing cooperation with all non-essential attire' and threatening to bolt from the bed—I order you to delete that from your memory immediately."

Sakaguchi: "Seeing Chief Mido act spoiled in bed was actually quite a rare treat."

Mido: "Shut up! ...Still, handing over command completely to you that night and not having to manage a single thing beneath you... felt addictively good. Since you performed up to standard both in bed and at the operating table, I won't deduct any points from you this time."

**Day 3 | Target Not Met**

Mido: "I knew it! On the night before surgery, I felt inexplicably restless handing over all command authority—and sure enough, something went sideways on the table!"

Sakaguchi: "I've logged the decision chain and termination point. The responsibility for this one is mine."

Mido: "Of course it's yours! In fact, I'd like to interrogate you, Takashi Sakaguchi—did you get so carried away pressing me into the mattress the night before surgery, focusing entirely on driving into my deepest spot until I begged, that your wrists ran out of strength when holding the scalpel the next day?"

[She lets out a cool snort and turns her head away, though the tips of her ears flush pink before she reaches out to tug his sleeve.]

Mido: "...Forget it. Professionally, I approve of the call to abort safely; and looking back, the pleasure of being held in your arms and thoroughly undone two nights ago... was worth taking this knife for you. Hand over the debriefing report."

---

### 1.4 Kaori Miyama | *Incurable Pre-Op Night Syndrome*

**Day 1 | Consultation**

[Kaori jots down three questions in the margin, asks them all, then scribbles a fourth line in the blank space: *'Why do I want to run away right now even knowing there's no refund after signing?'*]

Kaori: "Can I count item four as an official question too?"

Sakaguchi: "Sure. Though once you sign, even if you try to run tomorrow, the gurney team will intercept you."

Kaori: "Good. If you left me an exit, I'd definitely agonize over it until sunrise. ...Signed! Even though I'm 100% going to regret this for the next several hours."

**Day 1 | Special Ward, Pre-Op Night**

[As if discussing an indisputable clinical matter, she leads Sakaguchi to the door.]

Kaori: "I've thought about it all day and came up with a temporary therapy. Stay here with me tonight, and stop flipping through charts."

Sakaguchi: "What's the expected efficacy?"

Kaori: "No guaranteed efficacy. I just want to spend a passionate night with the man I love—can't you spare me the follow-up questions when it's my turn?"

[Smiling, Sakaguchi locks the door and strips off his white coat and clothes. Kaori unbuttons her hospital gown and tosses it along with her simple white cotton bra and panties to the foot of the bed, lying down naked first with rare boldness and patting the pillow with a flushed face.]

Kaori: "Look, I'm already positioned. And you're forbidden from describing me with medical terminology right now."

[She hooks her arms around his neck and kisses him. The lights dim as the two entwine closely between the sheets.]

Kaori: "Still smiling? ...Am I really that clumsy at acting spoiled?"

Kaori: "Mmn... Your hands are so hot... When you touch my chest, my heart races like it's about to set off a monitor alarm."

Sakaguchi: "You're adorable tonight."

Kaori: "Ah... Saying that at a moment like this leaves me zero room to argue... Nnh, down there... don't just tease me with your fingers..."

Kaori: "Kiss me again. ...Takashi, hurry and come inside me—I want to use your heat to crowd every anxious thought right out of my head."

[Sakaguchi covers her body, pressing steadily and powerfully into her depths. Kaori's waist shudders violently, her usually crisp voice shattering into breathless gasps.]

Kaori: "Kyaa...! Mmn, nnh...! T-Too deep... You reached all the way in at once..."

Kaori: "So good... I'm very satisfied with this temporary therapy tonight... Ah, nnh... You can go a little faster... Tonight I want to be a little greedy... Aah, I'm coming...!"

[The dim scene lingers briefly before fading completely to black as the clock advances. When the light returns, the hospital gown and white panties she tossed aside last night lie scattered at the foot of the bed.]

**Day 1 | Aftermath**

[Sweaty and languid under the sheet, Kaori stretches comfortably—then suddenly bursts into a laugh of pure despair.]

Kaori: "Uh-oh. The therapy has a severe rebound effect."

Sakaguchi: "What kind of rebound?"

Kaori: "While I was climaxing just now, I completely forgot about tomorrow's `<Current Procedure>`! Now that my head is clear again, thinking about ten-plus hours of general anesthesia, being cut open for real, bleeding, and being sewed back up with my signature locked in so I can't back out—I seriously want to jump out the window. Ah, figuratively speaking, of course!"

[She bonks her own forehead with the pillow.]

Kaori: "I know every single layer that surgery cuts through way too well. The more I know, the more I wish I could induce amnesia until tomorrow night."

Sakaguchi: "At least under general anesthesia, you won't feel those hours passing."

Kaori: "Right, so am I supposed to cheer? 'Hooray, I get to lose ten-plus hours of consciousness while everyone opens up my torso'?"

[Spotting her panties and hospital gown at the foot of the bed, she self-righteously tucks her bare shoulders back under the covers.]

Kaori: "I'm not putting them back on tonight. Our colleagues have to change, inspect, and prep me tomorrow morning anyway. Since canceling isn't an option anymore, you might as well treat me as a stark-naked patient who's already entered pre-op standby!"

Sakaguchi: "Standby hours haven't started yet."

Kaori: "Stop nitpicking my treatment regimen!"

[Halfway through their laughter, she suddenly lowers her head.]

Kaori: "...I really am scared. Not of losing face, and not of your surgical skill. Just the thought of lying there completely unable to move or call a stop."

[She rests her forehead against his shoulder.]

Kaori: "Sit with me a little longer. The patient isn't ready to return to reality yet."

**Day 3 | Success**

Kaori: "Set the report aside for a second. Now that I'm wide awake, remembering how I bonked my head with a pillow two nights ago yelling about jumping out the window, and kicked my panties to the foot of the bed refusing to dress... I wish I could crawl into a hole!"

Sakaguchi: "And what's your final clinical evaluation of that 'temporary therapy'?"

Kaori: "Efficacy exceeded all expectations! Right up until they put the oxygen mask over my face on the table yesterday, my body still felt like it was holding onto the heat of you filling me up. Now I'm ready to see the report—right after you let me gloat for ten seconds that I didn't desert!"

**Day 3 | Target Not Met**

Kaori: "I told you my 'therapy rebound' two nights ago was a clinical warning sign! My heart was drumming like crazy back then, and sure enough, we hit a snag at a critical step!"

Sakaguchi: "We did run into a variable at a key juncture. Let me walk you through the debriefing."

Kaori: "Before we debrief, allow me to raise a reasonable suspicion—Lead Surgeon Sakaguchi, did you work so hard in my hospital bed the night before surgery satisfying me that you burned through all your own focus under my covers?"

[She flicks his cuff with her finger, then blushes and lets out a soft sigh, leaning back against the pillow.]

Kaori: "Forget it. Even though falling short is frustrating, having you touch every inch of me two nights ago and drive deep inside until I couldn't think at all genuinely cured my pre-op panic. For the efficacy of that night alone, lying on that table wasn't a waste. Tell me—which step gave us trouble?"

---

### 1.5 Asuka Shiromiya | *The Director Lodges a Protest Against Hospital Gowns*

**Day 1 | Consultation**

[Asuka picks up her surgical cap, inspects it for three seconds, and sets it back down.]

Asuka: "This cap is well designed. I thought I'd love it."

Sakaguchi: "You don't look too fond of it right now."

Asuka: "What I'm not fond of is picturing myself wearing it on the operating table, bound hand and foot by the very 'no cancellation after signing' rule I approved myself. ...How strange, I even commissioned a satisfaction survey for these caps. Hand it over—the Director will sign."

**Day 1 | Special Ward, Pre-Op Night**

[On the ward table lie the documents she approved that afternoon. She flips them face-down with a solemn expression.]

Asuka: "The Director officially declares that all hospital business in the Special Ward is suspended for the night. Only private visitors are permitted to remain."

Sakaguchi: "Am I a private visitor?"

Asuka: "You're the man I love. If you fail inspection, you'll be escorted out."

[Holding back a smile, she watches Sakaguchi lock the door and take off his white coat and clothes; unhurriedly unbuttoning her patient gown, she slips off her champagne-silk bra and panties, deliberately fussing with the pillows stark naked as if inspecting a guest suite before suddenly yanking him down to the bedside.]

Asuka: "Inspection passed. ...From here on, we only take orders from your girlfriend."

[She plants a kiss on his cheek; the lights dim, and the rustle of sheets and quickening breaths soon fill the bed.]

Asuka: "Wait—saying 'Yes, Director' is strictly prohibited! ...Nnh, how did your hand go straight to my chest..."

Asuka: "...Mmn. Now you may compliment how pretty I am... including how I feel inside."

Sakaguchi: "You're always gorgeous."

Asuka: "Kya... Since when did you get so smooth with words... Ah, I'm already soaked down there... Don't just rub against the entrance without coming in..."

Asuka: "Come closer. This bed belongs to just the two of us tonight... Hurry up and fill me all the way up, Takashi..."

[Sakaguchi sinks his hips and drives all the way to the hilt in one stroke; Asuka lets out a sweet cry, wrapping her legs around his waist as her body sways with his thrusts.]

Asuka: "Aah—! Haah, so deep...! I think I've already forgotten I'm staying in a hospital... My head is completely full of you..."

Asuka: "Nnh, ah...! Don't stop yet, okay? Tonight I'm authorizing myself to be completely spoiled... I-I'm coming! Takashi—aah...!"

[Full fade to black as time advances. Her champagne-silk lingerie hangs over the back of the chair.]

**Day 1 | Aftermath**

[Sinking lazily into the pillows like a well-fed cat with the flush of lovemaking still on her cheeks, Asuka slowly turns her gaze toward the ceiling fixture.]

Asuka: "...I just thought of a severe flaw in our institutional policies."

Sakaguchi: "Still managing the hospital at this hour?"

Asuka: "Who was it that enacted the rule stating 'once informed consent is signed and prep workflow begins, a patient may not cancel surgery at the last minute'? ...Pretty sure I signed off on that myself! And I bought those shadowless lamps in the OR too—tomorrow they're going to shine down on me being cut open for over ten hours, **while I'm under general anesthesia with zero chance to back out or even admire them!**"

Sakaguchi: "...Does the Director wish to amend the hospital charter? Too bad the administration office has clocked out for the night."

Asuka: "Darn it! Talk about being hoisted by my own petard! I demand an emotional refund!"

[She lifts the sheet to reach for her hospital gown and panties, then ferociously shoves them away.]

Asuka: "Forget it, I'm not getting dressed tonight! I sweated so much with you just now, and the nurses have to put me through a whole complex prep routine tomorrow morning anyway. Since the Director has zero chance of escaping tomorrow and has to lie naked on the operating table no matter what, I'm staying in full-nude standby mode right now!"

Sakaguchi: "I doubt the nursing department recognizes that standby mode."

Asuka: "Then they can drop their complaints in the Director's suggestion box for me to process after I wake up from general anesthesia!"

[She pats the pillow laughing, until her laughter gradually quiets down.]

Asuka: "...Say, Takashi. Tomorrow they're really going to wheel me under that lamp and cut me open from start to finish, aren't they?"

Sakaguchi: "Yes. And if you feel scared before induction, you don't have to put on the Director's front in front of the girls."

Asuka: "My legs are already jelly just thinking about it. Tomorrow, don't you dare pretend you can't tell I'm terrified just because I'm the Director."

**Day 3 | Success**

Asuka: "Patient Feedback Item One: Waking up from general anesthesia and remembering how I lay naked in bed cursing the hospital charter I wrote myself and yelling about 'full-nude standby mode'... the Director's dignity is in absolute shambles!"

Sakaguchi: "Would the Director like me to classify that record?"

Asuka: "Obviously! ...As for Patient Feedback Item Two: the bedside service provided by a certain private visitor on the night before surgery was exemplary—my waist still feels tingly just thinking about it. Since that night felt so amazing and the surgery succeeded without a hitch, I hereby reward you with a direct debriefing, no written self-criticism required!"

**Day 3 | Target Not Met**

Asuka: "Hmph, I knew it! Two nights ago when I was staring at the ceiling wanting to rewrite the hospital charter because I felt trapped by my own rules, I had a hunch this operation wouldn't let me off easy!"

Sakaguchi: "I called a halt for safety rather than forcing it."

Asuka: "Stopping in time was the right call, but I still need to investigate the lead surgeon's off-duty accountability—Takashi, did you spend way too long fooling around with the Director two nights ago and use up all your best moves in bed, leaving you a breath short under the shadowless lamp?"

[She puffs her cheeks and glares at him, before her lips curve into a fond smile and she hooks her fingers around his wrist.]

Asuka: "Still, I'll waive my claim for an emotional refund. Considering how thoroughly you pampered and loved me in your arms on the night before surgery, just savoring that night makes this hospital stay a net profit for the Director. Come on, report the surgical details honestly."

---

### 1.6 Artoria Pendragon | *Present in Person, Stripped of Command*

**Day 1 | Consultation**

[After reading the surgical plan, she rests both hands on her knees, motionless for a long while.]

Artoria: "I finally understand why everyone keeps asking if I have any further questions. Once I sign my name, I must take my place on the operating table tomorrow no matter what—my questions are so numerous that asking them all would still bring no peace of mind."

Sakaguchi: "Then there's no need to feign peace of mind."

Artoria: "I consent to participate. ...Tomorrow, please treat me as an ordinary patient rather than a general arriving to inspect the troops."

**Day 1 | Special Ward, Pre-Op Night**

[The corners of the duvet are folded with military precision. Artoria sits upright as though preparing to deliver a pre-battle address.]

Artoria: "There is a personal matter tonight that I find harder to broach than requesting a relief column from you."

Sakaguchi: "Tell me."

Artoria: "Please stay. I wish to be close to you, and would rather not face tomorrow morning alone."

[She insists on closing the door firmly herself while Sakaguchi locks it and removes his outer clothes. With the solemnity of unbuckling armor, she takes off her hospital gown, unfastens her white blue-trimmed bra and panties, folds them neatly at the head of the bed, and squares the pillow once more. As Sakaguchi stands by the bed looking at her unshielded body, her ears turn bright red.]

Artoria: "...Am I acting as though I'm preparing for an inspection again? Forgive me. Come here."

[He sits down; she initiates the kiss and embrace as the lights dim.]

Artoria: "There is no need for salutes tonight. Nor any need to await permission... Nnh, your hand..."

Artoria: "Mmn... Touching me like this feels wonderful... My body is far more honest than I anticipated."

Sakaguchi: "Artoria."

Artoria: "Ah... If you call my name like that while touching me there... I shall lose my everyday composure entirely..."

Artoria: "Kiss me once more. I am not issuing a command... I am begging you to come inside me right now..."

[Sakaguchi parts her tense thighs and sinks slowly into her wet, tight warmth. The ever-dignified knight lets out a fractured whimper, her fingers digging into the muscles of his back.]

Artoria: "Mmn—! Ah, haah...! So hot... Tonight, let me lean on you without having to watch over anyone else..."

Artoria: "Nnh, ah...! You're pressing so deep... Takashi... I am truly happy... Ah, I can't hold back anymore... Hold me tight just like this—mmaah...!"

[Full fade to black as time passes. When the light returns, only the stack of white underwear at the headboard retains its neat shape.]

**Day 1 | Aftermath**

[Breathing unevenly with a flush still lingering across her chest, she suddenly sits upright, staring blankly at her neatly folded clothes.]

Artoria: "Wait. For tomorrow's campaign, the military pledge is already signed and I must attend in person—yet I am to lose consciousness completely during the most decisive ten-plus hours?"

Sakaguchi: "The operation is under general anesthesia."

Artoria: "A campaign in which the principal figure knows nothing and holds no authority even to order a retreat! Losing my composure in your arms just now is one thing, but tomorrow the nurses will change my clothes, position my body, verify everything, and put me to sleep to be cut open—without even a chance to protest that 'this posture lacks dignity'!"

Sakaguchi: "You're free to lodge your protest inside this room right now."

Artoria: "Then I hereby protest! ...I protest how terrified I still am even after signing my name."

[Pulling the sheet up to cover her bare chest, she sits bolt upright to make a pronouncement.]

Artoria: "Inasmuch as formal attire preparation is scheduled for tomorrow morning, tonight's dress obligations are temporarily suspended. All undergarments and patient gowns shall remain where they are while I stand by beneath the sheets."

Sakaguchi: "That sounded like a real military order."

Artoria: "Of course it's fake! ...Please allow me to preserve a shred of laughable dignity for the night."

[She tries to maintain a composed front, but her fingertips brush against Sakaguchi's hand.]

Artoria: "During those hours under anesthesia, I can do nothing for myself. ...Tomorrow morning, right before my eyes close, will you call my name one more time?"

**Day 3 | Success**

Artoria: "You accomplished the mission splendidly. Looking back now, sitting stark naked under the sheet two nights ago issuing a phony military order to 'suspend dress obligations' and protesting because I was afraid of losing consciousness... is deeply mortifying."

Sakaguchi: "Though the Artoria of that night was remarkably honest."

Artoria: "Ahem... Takashi, I forbid you from bringing up how I begged you to enter me back then. Still, it was precisely because I experienced the bliss of giving myself completely to you that night that I could entrust those ten-plus hours to your team in peace. Thank you, my lead surgeon."

**Day 3 | Target Not Met**

Artoria: "I understand why the operation had to be halted. It seems my unease on the night before surgery about 'the principal figure losing consciousness and command' proved somewhat prophetic."

Sakaguchi: "We didn't reach the target this time. The responsibility rests with me."

Artoria: "I have no intention of faulting your judgment. Only... Takashi, could it be that our entanglement in this bed two nights ago grew so intense that your stamina was depleted before taking the field the next day?"

[Seeing Sakaguchi's slightly stunned expression, her ears flush red and she gently clasps his palm.]

Artoria: "...Please disregard that last remark as an immature jest. Even if the surgery fell short of full victory, whenever I recall the warmth of laying down all my burdens in your arms and becoming one with you on that pre-op night, I do not regret signing that consent form in the slightest. Now, please deliver the battle report."

---

### 1.7 Hiroko Sugimura | *Hide the Sheets Before Shift Handover*

**Day 1 | Consultation**

[After reading the team roster, Hiroko flips the top page face-down and refuses to look at it again.]

Hiroko: "The roster is fine. The prep sheet is fine too. ...Now what do I do? Normally, when my patients sign the form and realize there's no backing out, none of them are also expected to evaluate the nurses' station."

Sakaguchi: "You don't have to evaluate them today."

Hiroko: "Right. Hand me the pen. Once I sign, I'll head straight to the ward and try my best not to meddle."

**Day 1 | Special Ward, Pre-Op Night**

[Hiroko has tidied the room to near-perfection, the bedsheet smoothed without a single crease.]

Hiroko: "This is hopeless. I'm supposed to be resting, yet I've fluffed and straightened the pillow seven times."

Sakaguchi: "Want me to mess it up for you?"

Hiroko: "...Yes, please. Stay with me tonight—it's fine if you mess it up a little."

[Blushing at her own words, she reaches out to pull Sakaguchi inside. He locks the door and removes his uniform and clothes; changing out of her hospital gown, she unfastens her deep-violet bra and panties, starts to fold them out of habit, then finally blushes and leaves them on the chair untouched, slipping her mature, curvesome body under the covers.]

Hiroko: "How rare for me. I actually want to leave things untidy on purpose."

[She pulls him down onto the bed and kisses him softly. The lights dim.]

Hiroko: "Mmn... No rush—let me take the lead for once tonight."

Hiroko: "Why are your hands so warm... You're making my waist go weak. ...Ah, that didn't sound like something I'd usually say."

Sakaguchi: "I love hearing it."

Hiroko: "Then... kiss me again. And don't call me 'Senpai' tonight—hearing that will make me want to go inspect the instrument trays."

Hiroko: "...Nnh, down there... You've already gotten me this wet... Don't hold back, come inside me, Sakaguchi-kun..."

[As the two join completely, the pristine bedsheet rapidly crumples beneath their deep rhythm. Hiroko covers her mouth, yet high, breathless moans still slip between her fingers.]

Hiroko: "Ah, nnh...! Yes, hold me just like this... It's been so long since I let myself be this selfish..."

Hiroko: "N-No... Thrusting that hard right there... the bedsheet is going to be a total wreck... Ah, haah... I don't care anymore, I'm coming... Sakaguchi-kun—!"

[Full fade to black as the clock advances.]

**Day 1 | Aftermath**

[Still panting in the afterglow, Hiroko bolts upright in Sakaguchi's arms, staring wide-eyed at the crumpled, slightly stained bedsheet beneath them.]

Hiroko: "We're doomed."

Sakaguchi: "What's wrong?"

Hiroko: "We got way too carried away just now! Who's assigned to pick me up tomorrow morning? If it's the junior nurses I trained, and they walk in to see this wrecked bed and my underwear tossed on the chair, they'll remember every lecture I ever gave them!"

[Stark naked, she grabs the edge of the sheet to smooth it out; the moment Sakaguchi shifts, the other side wrinkles again.]

Hiroko: "Don't move! ...No, wait, you can move. Goodness, what am I even doing?"

Sakaguchi: "You have a ten-plus-hour major surgery tomorrow."

Hiroko: "I know! And the form is signed, so even if I'm mortified tomorrow morning, there's no escaping it! Tomorrow those girls will do my full pre-op prep, help me onto the table, and once the anesthesia starts, I won't be able to help at all—just lie there while you cut me open!"

[Giving up on retrieving her panties from the chair, she pulls the entire sheet over her head, her voice muffled from underneath.]

Hiroko: "Forget it—I'm not getting dressed, and I'm not making the bed! Do you know how many times I've told patients who wanted to back out after signing to 'just relax'? ...Now that I'm the one with no exit, those two words sound awful."

Sakaguchi: "Then let's leave the bed messy tonight."

Hiroko: "Okay. ...But if the nurses ask what happened to this bed tomorrow morning, you're answering for me."

Sakaguchi: "And what should I tell them?"

Hiroko: "'Sugimura-senpai rested very well tonight.' Not a single word more."

**Day 3 | Success**

Hiroko: "When the girls wheeled my gurney out and asked if I needed anything else, I was still worrying about the crumpled bedsheet and the underwear we left on the chair two nights ago, and ended up blurting out 'Please hold my hand'... Thinking back now, hiding naked under the sheet refusing to dress was so unbecoming of a senior nurse."

Sakaguchi: "Though Hiroko seemed to thoroughly enjoy the process of messing up that bedsheet that night."

Hiroko: "Sakaguchi-kun! ...Honestly, my body still warms up just thinking about it. Thanks to how tenderly you held me that night, I made it through all ten-plus hours smoothly. When I return to duty, I'll never lecture my juniors over a wrinkled sheet again."

**Day 3 | Target Not Met**

Hiroko: "See? Two nights ago when I was panicking over the crumpled bedsheet and feeling all flustered inside, I had a vague premonition this operation wouldn't go smoothly."

Sakaguchi: "Nobody skipped a single verification step, but we did fail to reach the intended goal this time."

Hiroko: "I know when a team has to call a halt. Still, Sakaguchi-kun... could it be that you focused so hard on 'messing up the bedsheets' inside me in the ward two nights ago that you wore yourself out before standing at the operating table the next day?"

[She covers her mouth with a soft laugh, her disappointment melting into gentle affection as she lays her hand over the back of Sakaguchi's.]

Hiroko: "I'm just teasing. Even though it's a shame the surgery didn't finish, whenever I recall how I got to be selfish for once on the pre-op night and was loved by you until I forgot everything else... these three days weren't wasted at all. Come on, tell me how it went."

---

### 1.8 Satsuki Orikawa | *Who Surrenders First: Me or the Hospital Gown?* (★ Heightened Cold-Feet Tension)

**Day 1 | Consultation**

[Satsuki folds the pre-op information sheet neatly, though her knuckles gripping the pen turn white.]

Satsuki: "Dr. Sakaguchi... um, once I sign my name here, even if I burst into tears on the gurney tomorrow morning, the surgery won't be canceled no matter what, right?"

Sakaguchi: "Right. Once signed, the schedule is locked until the operation is completed."

Satsuki: "...Okay. Honestly, if you told me I could back out anytime, I'd definitely desert tomorrow morning. So while I still have my courage... I've signed it!"

**Day 1 | Special Ward, Pre-Op Night**

[Sitting in the corner of the bed hugging her knees, Satsuki actually reaches out her hand first when she sees Sakaguchi enter.]

Satsuki: "I practiced how to say this all day. ...Will you stay with me tonight? I really want to kiss you."

Sakaguchi: "You don't need to recite a script."

Satsuki: "Th-Then I'll just do what I'm feeling."

[She leads him inside and whispers for him to lock the door. Sakaguchi removes his clothes; Satsuki slowly unbuttons her hospital gown and, blushing scarlet, slips off her floral-print white cotton bra and panties, clutching the sheet tightly against her trembling bare body as she musters the courage to make room for him beside her.]

Satsuki: "I'm doing this because I want to. Come here... really."

[Closing her eyes first, she kisses him softly as the room dims.]

Satsuki: "Ah... Sorry, the moment your hand touched my chest, I still jumped a little..."

Satsuki: "Mmn. Try again, I want to learn not to flinch... Haah, nnh..."

Sakaguchi: "Take your time, Satsuki."

Satsuki: "I know... Just don't stay so far away from me. ...Kya! Your fingers—they touched down there... I don't mean I dislike it, it's just a little too sensitive..."

Satsuki: "I really love you. I didn't practice that line... So please, come inside me, Dr. Sakaguchi..."

[Sakaguchi gently parts her legs and sinks slowly inside. Satsuki lets out a tiny gasp, physiological tears brimming at the corners of her eyes as both arms lock around his neck, refusing to let go.]

Satsuki: "Mmn...! Ah, nnh... So full... You're filling me up all the way inside... Being held like this makes me feel not the least bit lonely..."

Satsuki: "Ah, haah... It's okay if you go even deeper... Right now, I feel like I finally dare to keep looking right at you... I-I'm coming... uwaah...!"

[The screen fades completely to black, skipping forward a moment later.]

**Day 1 | Aftermath**

[Limp against Sakaguchi's chest, Satsuki buries her flushed face into the pillow. The next second, her patient gown and floral panties slip off the back of the chair, making her flinch from head to toe.]

Satsuki: "Kya! ...I-It's just my clothes."

Sakaguchi: "Who did you think it was?"

Satsuki: "I thought it was the senior nurses coming to escort me to the OR tomorrow morning! Uu, this is terrible—while you were holding me just now I wasn't scared of anything, but the second it gets quiet, any tiny noise makes me think I'm about to be wheeled in to go under the knife..."

[Looking down at the patient wristband around her wrist, her fingers suddenly claw at the disposable plastic snap lock, her voice thick with tears.]

Satsuki: "Dr. Sakaguchi... Th-This wristband is snapped on so tight, it won't come off at all... Tomorrow is a real ten-plus-hour surgery where you cut me open, where I'll really bleed and have my insides laid wide open... I'm suddenly so scared—c-can't we secretly void that consent form I signed today...?"

Sakaguchi: "There's no voiding it now, Satsuki. The OR and tomorrow morning's nursing team are already scheduled—you're the first case on the board tomorrow."

[Catching her hand clawing at the wristband, Sakaguchi pulls her trembling naked body back into his embrace. Satsuki sniffles, her tears pattering against his collarbone, yet she presses closer against him as if strangely relieved.]

Satsuki: "Uu... I knew there was no backing out... Not even Dr. Sakaguchi will let me run away. Even knowing I'll wake up without any lasting harm, just realizing that no matter how hard I cry tomorrow morning I still have to lie down obediently and be cut open makes my legs so weak I don't even dare put my hospital gown back on..."

Sakaguchi: "If you're scared tomorrow morning, you don't have to pretend to be brave."

Satsuki: "...Okay. Since there's no escaping it anyway, if I burst into tears tomorrow morning, please don't tell me 'don't be scared,' alright? Just hold my hand down and tell everyone I'll cooperate obediently. As for tonight... let the hospital gown lose to me just once, and hold me naked like this until sunrise."

**Day 3 | Success**

Satsuki: "Right before entering the OR I really cried until I hiccuped, and my seniors wiped my tears while lifting me onto the operating table... Now that it's safely over, remembering how I jumped at my own falling panties two nights ago and cried while clawing at my wristband begging you to void my consent form makes my whole face burn..."

Sakaguchi: "Not scared anymore?"

Satsuki: "No! And... whenever I remember lying stark naked in Dr. Sakaguchi's arms that night and having even my deepest place gently filled by you, I feel so glad you didn't let me desert back then. Now I can finally listen to the report happily!"

**Day 3 | Target Not Met**

Satsuki: "Uu... I knew jumping out of my skin when my clothes fell two nights ago was a premonition that I'd hear this result today..."

Sakaguchi: "It didn't fall short because you were scared—it was due to objective intraoperative conditions."

Satsuki: "I know... Um, Dr. Sakaguchi, c-could it be that you spent too long coaxing me in bed two nights ago and held me so late into the night that your legs went weak when holding the scalpel the next day, just like mine...?"

[Mustering her courage to make a tiny joke, she immediately buries half her blushing face under the covers, reaching out one hand to tug the corner of his coat.]

Satsuki: "I'm sorry, I shouldn't make silly jokes... Truth is, even if the surgery didn't finish, just remembering how you touched my chest that night and came inside me so I didn't feel lonely at all makes taking this knife feel completely worth it. Once I wipe my tears, will you read me the report?"

---

### 1.9 Aqua Mizuki | *One Last Unreasonable Tantrum Before General Anesthesia*

**Day 1 | Consultation**

[Aqua asks about every single pre-op preparation item, her expression growing paler than when she walked in.]

Aqua: "Weird. Every time I clarify an item, my heart panics even more. This pre-op briefing is a total failure."

Sakaguchi: "Once you sign, there's no revoking it."

Aqua: "Of course I'm signing! Just remember tomorrow, if you see me playing dead on the operating table, that's an animal's instinctive tonic immobility when facing inescapable danger—the general anesthesia hasn't started yet."

**Day 1 | Special Ward, Pre-Op Night**

[Aqua flips her pillow over and over as if searching for the most scientifically optimal side in the world.]

Aqua: "The human brain is a nuisance. I understand why every step tomorrow is rational, yet it still refuses to shut up."

Sakaguchi: "Taking the night off from being a scientist?"

Aqua: "Yes. Tonight I want you to kiss me and go all the way with me. This request requires zero literature citations."

[She leads him to the bed and points at the door lock. Sakaguchi removes his clothes; Aqua briskly sheds her hospital gown, unhooks her aqua-blue sporty bra, kicks it along with her panties to the foot of the bed, and shoves the textbook she nearly brought for review far away. Sitting naked on the mattress, she pulls him close with a mischievous grin.]

Aqua: "No need to explain the steps to me this time. ...Let's verify it directly with our bodies. Come here."

[The lights dim as urgent kisses and caresses send the temperature under the covers soaring.]

Aqua: "Mmn... Right now I strongly endorse your manual technique... Haah, pinching my nipples like that is making them tingle..."

Aqua: "Ah... Don't laugh right when I'm gasping for air!"

Sakaguchi: "I didn't say a word."

Aqua: "Then stop just using your hands... I'm already a soaked mess down there, and you clearly felt it, didn't you?"

Aqua: "Don't call me Chief or Doctor tonight... Hurry up and come inside me so my brain goes on strike completely!"

[Sakaguchi sinks his hips and drives in; Aqua's long legs pull taut as her attempt at a rational tone shatters into high-pitched gasps.]

Aqua: "Aah—! Mmn, so deep...! So this is what it feels like to think about nothing at all and just have you pressing against my deepest spot..."

Aqua: "You haven't said you love me yet... Ah, I heard it! Hold me tighter, thrust harder! I-I'm going to break... aaah...!"

[Fade to black as time advances.]

**Day 1 | Aftermath**

[Sprawled across the pillow slick with sweat, she reaches under the pillow and pulls out the pre-op sheet, looking baffled as to why she hid it there herself.]

Aqua: "Why is this thing under here? ...Wait, oh god, tomorrow's surgery!"

Sakaguchi: "Didn't you say we weren't discussing it tonight?"

Aqua: "In theory, yes! While dopamine and endorphins were flooding my system just now I wasn't scared of anything, but the second post-coital clarity hits—it's ten-plus hours of general anesthesia! All of you will be busy wielding scalpels and retractors inside me, while Chief Mizuki on the table knows nothing! Hey, Takashi, can't we hack into the hospital system right now and delete tomorrow's surgical booking?!"

Sakaguchi: "Permissions are locked, Chief Mizuki."

Aqua: "Uwaaah! What a garbage system! Leaving me zero room for buyer's remorse!"

[She shields her flushed face with the textbook, then tosses it aside and glances at the aqua-blue panties at the foot of the bed.]

Aqua: "Since it can't be deleted, I hereby resign from the medical profession for the next twelve hours! Medical common sense is temporarily null and void! No panties! No hospital gown! No educational lectures! When the nurses come to prep me tomorrow morning, they can prep me however they like!"

Sakaguchi: "...You're probably going to make twenty demands tomorrow morning."

Aqua: "I am! And every single one of them will be scientifically sound!"

[Lowering her voice suddenly, she tucks her bare shoulders into his embrace.]

Aqua: "Except for one unreasonable request. ...Tomorrow morning when they hold me down on the table for general anesthesia induction, I know I'm going to panic at that sensation of consciousness sinking away with nowhere to run. Please ask the anesthesiologist to chat with me first instead of starting the countdown right away."

Sakaguchi: "I'll let her know."

Aqua: "...Sigh. If I'd known how terrifying it feels after signing, I would've stuck to being your unruly girlfriend in bed instead of this unlucky patient."

**Day 3 | Success**

Aqua: "Right before anesthesia, I was actually debating escape routes in my head, and blacked out mid-argument! Waking up now and remembering how I begged to hack the system to delete my booking two nights ago, then sat there naked declaring my 'twelve-hour resignation from the medical profession'... my academic image as Chief is ruined!"

Sakaguchi: "Well, the dopamine and endorphins had just worn off."

Aqua: "Hey, no using my own words against me! ...Still, I have to admit, the clinical experience of having you pinch my sensitive spots on the pre-op night and drive deep inside until my brain went on strike was top-tier. Since that night felt incredible and the operation went smoothly, Chief Mizuki grants you permission to begin the debriefing!"

**Day 3 | Target Not Met**

Aqua: "I knew it! Two nights ago when I pulled the pre-op sheet from under the pillow and clamored to delete the surgical booking, my sixth sense had already detected a catch with this operation!"

Sakaguchi: "The call to abort was made by the book. Once you've rested up, we'll look into alternative approaches."

Aqua: "I know the theory, but as Chief I must raise a scientific inquiry—Takashi, did you put so much effort into 'verifying your manual technique' in bed two nights ago and make me climax so many times that the lead surgeon overdrew his own physical reserves?"

[She shoots Sakaguchi a wicked grin, then softens and leans into his chest, twirling the corner of his white coat around her finger.]

Aqua: "Alright, I'll stop teasing you. Even though falling short makes me want to hurl medical textbooks, the moment I savor how good it felt beneath you two nights ago without a single thought in my head... Chief Mizuki still came out ahead on this deal. Hand me my water first, then tell me which step stalled."

---

### 1.10 Mika Nakai | *The Perfect Nurse Caught by Morning Rounds*

**Day 1 | Consultation**

[Mika reads the form with a smile and confirms every question gracefully. Only when Sakaguchi reminds her that signing locks the schedule does she rest her fingers on the edge of the page.]

Mika: "...Give me just one more minute. I don't have any questions left, yet I feel like the moment I finish signing, tomorrow morning will arrive far too quickly."

Sakaguchi: "Take your time. Put pen to paper when you're ready."

Mika: "Thank you. ...There, signed. How rare—to think the day would come when I personally sign myself onto the operating table."

**Day 1 | Special Ward, Pre-Op Night**

[Adjusting her hair before the mirror, Mika has kept the room looking as pristine as if it were unoccupied. Spotting Sakaguchi in the reflection, she smiles at him.]

Mika: "Welcome. Tonight there's no nurse here to arrange everything neatly for us."

Sakaguchi: "Disappointed?"

Mika: "Not at all. Tonight I was hoping to toss the word 'neat' right out the window. ...Will you stay with me? Simply because I want you."

[Sakaguchi locks the door and removes his clothes. Even while taking off her hospital gown and beige lace bra and panties, Mika habitually folds each piece neatly; at the very end, she deliberately shoves the folded stack of lingerie askew, standing bare with the smile of someone who just pulled off a prank.]

Mika: "Did you see that? I just committed a violation of bedside management standards."

[She pulls him onto the bed and kisses his lips softly. The lights dim.]

Mika: "Mmn... I didn't expect you to look at me undressed with eyes like that."

Mika: "Can you stop being so polite tonight? ...Kiss me again, and let your hands be a little more forward."

Sakaguchi: "You don't need to be polite either."

Mika: "Ah, you caught me... Nnh, down there... You've already touched me until I'm soaked..."

Mika: "Let me hold you. Don't ask me about tomorrow right now... Just come straight inside and mess me up even more..."

[Sakaguchi sinks his hips, pushing deep into her warm body. Mika's composed everyday smile melts instantly into a trembling sigh as her fingers clutch the bedsheet.]

Mika: "...Ah! Nnh, haah... Yes, I'm so happy tonight... When you press against my deepest spot like that, I forget how to act like a lady at all..."

Mika: "If you hear me cry out, keep it a secret between the two of us... Ah, nnh... Harder—I don't want this night to end yet... aah...!"

[Full fade to black as time advances.]

**Day 1 | Aftermath**

[Resting against the pillow dewy with sweat, Mika reflexively smiles toward the ward door as though someone had knocked. The hallway outside is dead silent.]

Sakaguchi: "Who are you smiling at?"

Mika: "At the morning-shift nurse coming to pick me up tomorrow. I have to practice my opening line in advance: 'The patient is in good condition; please proceed with pre-op prep at your convenience.'"

Sakaguchi: "Is that a line a patient is supposed to say?"

Mika: "I know it isn't. ...But since I've already signed and can't cancel, if I don't make a joke out of it, I'm afraid tomorrow morning I'll actually grab her sleeve and beg, 'Can't you wait a little longer before wheeling me in?'"

[She keeps smiling, though her hand resting on the duvet trembles faintly.]

Mika: "The girls would probably be shocked. Nurse Nakai, who loves teaching everyone how to soothe anxious patients, was moaning so shamelessly in bed a minute ago, and tomorrow she'll be the one who least wants to get on that operating table."

Sakaguchi: "Then let them see that you get scared too."

Mika: "How interesting. I always want everyone to think I'm easygoing and composed, yet right now you're the only one I want to show my messiest side to."

[Glancing at the beige lingerie and hospital gown she shoved askew on the chair, she lets out a soft hum.]

Mika: "If they walk into this room tomorrow morning and see me still hiding naked under the covers... I have no intention of explaining why it's such a mess."

Sakaguchi: "Want me to tidy it up for you?"

Mika: "No. ...Leave it as it is. Tonight I never intended to be a perfect nurse anyway."

[Suddenly she squeezes his hand tightly, as if dropping the act at last.]

Mika: "I'm honestly scared out of my mind right now. Don't tell a soul."

**Day 3 | Success**

Mika: "When the nurse came for me, I didn't use that polished line I practiced—I just said 'Please go a little slowly.' Now that the surgery is safely over, thinking back to how I deliberately shoved my underwear into a mess two nights ago and smiled at an empty door practicing lines... even I feel embarrassed."

Sakaguchi: "Only I got to see the Mika who stopped acting like a lady that night."

Mika: "Hehe, how dare you bring that up... Still, whenever I recall being held in your arms and undone so thoroughly that I couldn't hold back my voice, I think dropping the perfect-nurse act once in a while is rather nice. Thank you, Takashi."

**Day 3 | Target Not Met**

Mika: "See? Two nights ago when my hands wouldn't stop trembling and I felt tomorrow was coming too fast, my feminine intuition really was warning me this surgery wouldn't be so easy."

Sakaguchi: "I'm sorry we couldn't complete it as planned this time."

Mika: "No need to apologize. If we must look for a cause... could it be that on the night before surgery, Dr. Sakaguchi followed my request in bed a little too well—being 'impolite with his hands and going so deep and hard'—that he used up tomorrow's surgical stamina ahead of schedule?"

[Her eyes crinkle with a teasing smile before she turns the visiting bouquet aside and gently presses her warm palm against his cheek.]

Mika: "I'm only teasing you. Even though the outcome is a little disappointing, as long as I savor how completely I let myself go beneath you two nights ago, lying on this operating table for you was worth every bit of it. Come on, walk me through the debriefing."

---

### 1.11 Narumi Jinguji | *The One Who Said "You Just Sleep Right Through It"*

**Day 1 | Consultation**

[Narumi circles the phrase *"soothe and wait as appropriate based on patient comfort prior to induction"* on the plan and hands it back to Sakaguchi.]

Narumi: "Keep this line in. Since signing means there's no backing out, I know very well I'll probably cling to you guys at the very last minute outside the OR doors."

Sakaguchi: "You don't need to apologize in advance for that."

Narumi: "Good. And I won't use 'I'm a doctor myself' as an excuse to pretend I'm naturally immune to fear."

**Day 1 | Special Ward, Pre-Op Night**

[Narumi puts her phone on silent without even checking the last work message.]

Narumi: "Tonight I'm not looking after anyone. I just want you to keep me company, like any ordinary couple."

Sakaguchi: "Then I'm off rounds tonight too."

Narumi: "Now you're talking. ...I want to be close to you—don't make me phrase a wish like a medical chart entry."

[She switches off the overhead light herself. Sakaguchi locks the door and removes his clothes; unfastening her hospital gown generously, she slips off her burgundy bra and panties and pushes both of their clothes over by the door, as if shutting work outside for good. Naked and warm, she pulls him down beside her.]

Narumi: "Get over here. Right now I don't need an attending surgeon sitting with straight posture."

[They kiss in the dim glow; the lamp goes dark, and heavy breaths quickly entwine across the bed.]

Narumi: "...Mmn. Finally, someone is just calling my name and touching my body tonight."

Narumi: "Kiss me again. ...Ah, don't揉 me there so suddenly... I won't be able to keep my voice down..."

Sakaguchi: "Narumi, I love you."

Narumi: "I want to hear that line again... Say it to me while you come inside."

[Answering her invitation, Sakaguchi sinks his hips inside her; Narumi lets out a husky, sensual groan, wrapping her legs tightly around his waist to meet every deep stroke.]

Narumi: "Nnh, ah...! So deep... Just hold me hard like this tonight... Right now I don't feel scared of anything at all, how hopeless of me..."

Narumi: "Don't let go... Faster, let me ride this high a little longer... Ah, mmn... I love you too... I-I'm coming—aah...!"

[Full fade to black as time passes. By the door lies a tangled heap of burgundy lingerie and his white coat.]

**Day 1 | Aftermath**

[With damp hair spilling across her shoulders, Narumi buries her flushed face in the pillow and laughs for a long moment before speaking to the ceiling.]

Narumi: "'It's general anesthesia—you just sleep right through it.'"

Sakaguchi: "Whose line are you quoting?"

Narumi: "My own! How many patients who signed the form and couldn't back out have I said that to? Good grief, now that I'm the one being cut open for over ten hours tomorrow, I realize how punchable that line sounds."

[Sitting up, she scrambles to wrap the sheet around her bare body.]

Narumi: "Tomorrow I really have to sleep for over ten hours while you guys work on me with scalpels, then wake up waiting for your verdict. Yet look at me—right now I don't even dare walk over to the door to pick up my panties and hospital gown. Even though I was having the time of my life beneath you a minute ago!"

Sakaguchi: "It's not like you just found out the surgical schedule is locked."

Narumi: "I know! I know it crystal clear! That's precisely why I want to curse myself!"

[She suddenly points an accusing finger at Sakaguchi.]

Narumi: "I'm staying naked in this bed until morning! And if I panic tomorrow morning and say 'I don't want to go in,' even though protocol says you have to wheel me in anyway, you are strictly forbidden from brushing me off with 'you'll just sleep right through it.' Or I'll have it out with you when I wake up!"

Sakaguchi: "What would you like me to say instead?"

Narumi: "Tell me you'll make every incision count. Tell me someone will stay with me before induction. ...And let me hold onto you for a minute, even if it sounds completely unprofessional."

[Holding out her hand, her throat catches, her smile shrinking.]

Narumi: "Turns out what's truly awful about that comforting line is how it skips right over the hours a person spends terrified with nowhere to run."

**Day 3 | Success**

Narumi: "Now I can admit it firsthand: 'You just sleep right through it' really isn't good enough. Though waking up and looking back at two nights ago—how I lay naked refusing to pick up my panties by the door and fiercely threatened to fall out with you if you said the wrong line... that was way too embarrassing."

Sakaguchi: "Well, someone had just nearly fainted from pleasure beneath me a few minutes earlier."

Narumi: "Don't bring that up! ...Still, the feeling of you coming inside me while telling me you loved me that night still makes my lower belly warm just thinking about it. With that night under my belt, taking the knife for ten-plus hours actually felt pretty blissful."

**Day 3 | Target Not Met**

Narumi: "See? I told you there was a reason I couldn't bring myself to pick up my hospital gown by the door two nights ago and felt so on edge. Turns out it really isn't as simple as 'sleep once and everything's done.'"

Sakaguchi: "We couldn't complete the target this time. Let me explain the exact reasons first."

Narumi: "Of course I'll listen to the reasons. But before that... Dr. Sakaguchi, did you use up every ounce of your strength holding me so fiercely in bed on the night before surgery that you couldn't hold out at the operating table the next day?"

[She shoots him a sidelong glance with a chuckle, then reaches out her cool fingers to clasp his palm, her tone softening.]

Narumi: "Don't take it to heart, I'm just ribbing you. Even though falling short is disappointing, whenever I remember having every inch of me caressed two nights ago and climaxing while hearing you say you loved me... playing the patient this time wasn't a loss at all. Tell me, how did you make the call to stop?"

---

### 1.12 Ren Nanase | *The Gurney Is Rolling the Wrong Way*

**Day 1 | Consultation**

[Out of habit, Ren stands beside the consultation desk ready to hand files to Sakaguchi, only realizing upon hearing "Please have a seat" that she is the one being cared for today.]

Ren: "How strange. I even needed a reminder just to sit down and listen to the risks. Tomorrow when I actually lie down on the table with zero chance of canceling, I probably won't even know where to put my hands."

Sakaguchi: "The nurses will help you."

Ren: "...I know. Then this time it's my turn to be in everyone's care."

**Day 1 | Special Ward, Pre-Op Night**

[Seeing Sakaguchi enter, Ren instinctively asks "Are you tired?" before bursting into laughter at herself.]

Ren: "Ah, there I go worrying about others again. ...Tonight, will you worry about me instead?"

Sakaguchi: "What would you like?"

Ren: "I want you to stay, and I want you to hold me. Not because being a patient entitles me to it... but because I love you."

[Sakaguchi locks the door and takes off his uniform and clothes; changing out of her hospital gown and pale-pink cotton bra and panties, Ren starts to place them beside the collection basket for the nurses out of habit, then shakes her head and shyly tosses them beside the bed—for the first time not wanting to tidy up for anyone. Naked, she lifts the sheet and invites him to sit.]

Ren: "No making beds for anyone else tonight. I'm lying down myself... Come join me."

[She kisses him first as the bedside lamp dims.]

Ren: "Mmn... I thought I'd be too shy for this."

Ren: "Ah, having you caress me all the way down from my chest like that... is still so embarrassing. Don't laugh at me."

Sakaguchi: "I'm not laughing."

Ren: "Then kiss me again... please. ...Nnh, I'm already wet down there... And it's definitely not because you're operating on me tomorrow..."

[Sakaguchi gently covers her and presses slowly inside. Ren sucks in a breath, her sensitive body tensing instantly as both hands grip his forearms.]

Ren: "Ah...! Nnh, haah... So full... Tonight I won't say thank you, I'll only say I love you..."

Ren: "I'm so happy... It's so hot and full inside... Can we stay connected just like this all night? ...Ah, mmn... Hold me tighter, I want to keep this feeling inside me until tomorrow morning... I-I'm coming... aah...!"

[Fade to black as time passes.]

**Day 1 | Aftermath**

[Late at night, a cart rolls down the hallway outside. Still basking in the afterglow in Sakaguchi's arms, Ren suddenly bolts upright and blurts out:]

Ren: "Coming through on this side, gurney passing—"

[She freezes, the sheet sliding off her bare shoulders.]

Ren: "...Wait, tomorrow morning the one being wheeled down the hall is me!"

Sakaguchi: "Finally remembered?"

Ren: "It's a ten-plus-hour major surgery under general anesthesia! A minute ago you had my mind completely blank, and now it hits me: usually I'm standing at the head of the bed telling patients who want to cry after signing 'Off we go,' and tomorrow I'll be the one stripped bare in a surgical gown waiting to be cut open and sutured blade by blade. The direction is completely backwards!"

[She glances at her pale-pink panties scattered beside the bed without picking them up, clutching the sheet tightly as tears spill down her cheeks without warning.]

Ren: "I don't want to put my clothes back on tonight—there's no escaping tomorrow anyway, and my seniors will strip me bare to inspect and prep me all over again... I really want to pin a note to my gown saying: 'Even though I signed and can't cancel, please wheel me gently, I really might cry.' ...But if I wrote that, my seniors would think I'm joking!"

Sakaguchi: "You can tell them directly."

Ren: "I know, I just can't tell myself 'don't be scared.' Hearing those two words only makes me want to cry harder."

[After a moment's thought, she burrows naked back into his arms.]

Ren: "Tomorrow morning I don't want to be a sensible nurse. Even if I have to get on the operating table, I want to be a patient who can ask them to hold my hand for a moment. ...Will you help me remember that?"

**Day 3 | Success**

Ren: "I walk that hallway with gurneys every single day, yet lying flat looking up at the ceiling felt like passing through it for the very first time. Now that the surgery is safely finished, remembering how I sat up naked at midnight yelling 'Gurney passing, coming through!' and cried about pinning a note to my gown... I'm too embarrassed to face anyone!"

Sakaguchi: "Though when you said that night you wanted to 'keep the feeling of staying connected until morning,' it stayed with you, didn't it?"

Ren: "Uu, don't quote my exact words back to me... Still, the reassurance of having you caress me all the way down from my chest and hold me so close really carried me through the fear before anesthesia. Thank you, Takashi."

**Day 3 | Target Not Met**

Ren: "The first thing I asked when I opened my eyes was 'Do we have to wheel me back for a redo?' ...Looks like bursting into tears when I heard the cart at midnight two nights ago and feeling uneasy about the direction being reversed really was a premonition that today wouldn't go smoothly."

Sakaguchi: "I'm sorry, Ren. We couldn't complete the surgery as planned this time."

Ren: "Don't look so grim... If we really want to settle accounts, could it be that you indulged my selfishness in bed for too long on the night before surgery—holding me so tight and pressing so deep—that you wore yourself out for the operating table the next day?"

[Blushing, she teases him softly before lacing her fingers with his and pressing his hand against her cheek.]

Ren: "I'm only joking. Even though I'm a little sad, whenever I remember lying in your arms two nights ago not having to look after anyone else and being loved by you alone, taking this knife wasn't a loss at all. Come on, tell me why we had to stop."

---

### 1.13 Shiori Fujisaki | *Nobody Asked You to Take the Knife Gracefully* (★ Perfectionist Cold-Feet Tension)

**Day 1 | Consultation**

[Shiori holds the pen with impeccable posture, though her palm is damp enough to slip.]

Shiori: "When you told me there's no leaving halfway once I sign, and that I don't need to act like a 'model patient'... I actually felt a little aggrieved."

Sakaguchi: "Why is that?"

Shiori: "Because I was genuinely trying to figure out how to be terrified gracefully, given that I have to take the knife for over ten hours tomorrow no matter what. ...Forget it, I'll sign. I can afford to be ungracefully terrified just once."

**Day 1 | Special Ward, Pre-Op Night**

[Shiori lets her hair down, placing her headband inside a small case.]

Shiori: "Look—tonight I'm nothing like my usual self."

Sakaguchi: "I love you all the same."

Shiori: "Then stay the night with me. Tonight I want to be loved by you without having to try so hard."

[Smiling, she closes the door while Sakaguchi locks it and removes his outer clothes; changing out of her hospital gown, she blushes as she unfastens her pure-white lace bra and panties, leaving them unfolded for once and using only the sheet to shield her slender naked body as she pats the other side of the mattress.]

Shiori: "Let's get one thing straight first—don't ask me if I look pretty like this. ...Come here."

[They embrace and kiss as the bedside lamp dims to the glow outside the window.]

Shiori: "Ah... So even when I initiate, I still blush like this... Nnh, don't grip me quite so hard..."

Shiori: "Mmn, kiss me again, and don't compliment my poise... Tonight I don't want to be poised at all."

Sakaguchi: "Then I'll just say I love you."

Shiori: "...That I like hearing. ...Haah, down there... You've already gotten me wet... Tonight I don't want to look in a mirror, I only want to look at you."

[Sakaguchi parts her thighs and sinks slowly into her tight warmth. Shiori lets out a clear, bashful gasp, her usually composed expression melting completely into pleasure.]

Shiori: "Kyaa...! Ah, when you push inside while looking right into my eyes like that, you make me blush all over again...!"

Shiori: "Closer... deeper... Make me forget I have to wear a patient cap tomorrow... Nnh, ah... No, I'm coming... Hold me tight just like this—aah...!"

[Fade to black as time passes.]

**Day 1 | Aftermath**

[Leaning against the pillow with flushed cheeks and uneven breaths, Shiori spots the headband case on the table and lets out a sudden gasp.]

Shiori: "Wait! When I put on the surgical cap tomorrow, all of my hair has to be tucked inside, right?"

Sakaguchi: "Right."

Shiori: "And changing gowns, verification, skin prep, catheterization... and then I have to sleep under that shadowless lamp for over ten hours while you cut my belly open and sew it back up?!"

Sakaguchi: "Yes."

Shiori: "Good heavens! In your arms just now, I could still choose how to smile and how to kiss you; but when I realize that tomorrow I don't even get a say in how my hair is tucked away or when I get cut open—and I'm not even allowed to say 'I'm not feeling up to it today, let's reschedule'... Takashi, can't I really claim I have a fever and cancel tomorrow's surgery?!"

Sakaguchi: "I just personally verified your body temperature and vital signs a moment ago. You're in peak health—no cancellations."

[Pouting as she hugs the headband case, Shiori's eyes slowly rim with red.]

Shiori: "How can you be so strictly impartial... When the nurse who always compliments how pretty I am comes to wheel me away tomorrow morning and sees me wanting to run with nowhere to go, crying in bed, what am I supposed to do? The gentler she is, the more mortified I'll feel."

Sakaguchi: "Then go ahead and cry. Nobody grades your poise on the operating table."

Shiori: "Easy for you to say... Right now I don't even dare put my underwear and hospital gown back on, as if the moment I dress, the eight-o'clock gurney will burst through the door."

[Pushing the white panties and gown beside the bed further away, she burrows naked back under the sheet.]

Shiori: "Since you refuse to let me desert, tonight ends right here—no more 'graceful Dr. Fujisaki,' I'm staying naked in your arms! Tomorrow morning they can come collect whatever kind of patient I happen to be!"

[She pauses, her voice dropping.]

Shiori: "...Still, tomorrow in front of the nurses, will you call me Shiori too? I think I'll need to hear a familiar voice."

**Day 3 | Success**

Shiori: "Right before entering the OR I really cried terribly, and the nurse simply said, 'It's alright, we'll wait until your breathing steadies before wheeling you in.' Now that the surgery is over, remembering how I hugged my headband case two nights ago begging you to let me fake a fever to cancel, and pushed my panties away to cling to you naked... how utterly unladylike."

Sakaguchi: "I thought the unpoised Shiori of that night was breathtaking."

Shiori: "Dummy, stop teasing me about the noises I made that night! ...Still, savoring how you looked into my eyes while pressing deep inside me that night made me happier than being called pretty a hundred times over. Now I'm ready to hear the report."

**Day 3 | Target Not Met**

Shiori: "See? Two nights ago when I stared at my headband case panicking and desperately wanted to fake a fever to cancel the surgery, my intuition already knew things wouldn't go smoothly this time."

Sakaguchi: "I'm sorry, Shiori. We couldn't complete the target this time."

Shiori: "Hmph, am I allowed to harbor a suspicion—that a certain lead surgeon got so carried away 'verifying my body temperature and vital signs' in bed two nights ago, spending all his energy making me blush and cry out, that he underperformed on the table the next day?"

[She shoots him a coy look, then lets out a soft sigh and takes his hand.]

Shiori: "Alright, I don't blame you. Even though falling short is disappointing, whenever I remember lying in your arms two nights ago without having to play the model lady and being held so tightly by you, taking this knife was still worthwhile. Tell me why we had to stop."

---

### 1.14 Miyuki Asakura | *Karma Catches Up with the Sharp-Tongued Senior*

**Day 1 | Consultation**

[Miyuki taps her fingertips against the prep checklist, faster and faster.]

Miyuki: "I've explained this sheet to other girls so many times, yet now that I'm the one who has no way out after signing, the more I look at it, the more I hate it. Those junior nurses had better not tell me 'Relax, it'll be over before you know it' tomorrow."

Sakaguchi: "Haven't you used that exact line before?"

Miyuki: "...Precisely because I use it all the time to coax girls who want to bolt, I know how punchable it sounds. Here, signed—this senior has zero regrets."

**Day 1 | Special Ward, Pre-Op Night**

[She sits at the foot of the bed as if waiting for Sakaguchi to arrive late so she can lecture him.]

Miyuki: "So you finally showed up. Here I thought you were going to abandon your girlfriend in the ward and go home to sleep."

Sakaguchi: "Did I receive an invitation or a formal complaint?"

Miyuki: "An invitation! I want to fool around with you all night—is that so hard to figure out? Get over here."

[Sakaguchi locks the door and removes his clothes. Stripping off her hospital gown and crimson lace bra and panties in one go, she tosses them onto the chair and pats the mattress stark naked. Catching his gaze on her body, she actually blushes a little.]

Miyuki: "What are you staring at! If you dare start a sentence with 'Senpai' right now, I'm kicking you out."

[Laughing, they kiss as the lights dim, the mattress soon rocking with their heated movements.]

Miyuki: "Mmn... Finally dropping the polite act... Nnh, your hands certainly aren't holding back on my chest!"

Miyuki: "Ah... Dummy, stop rubbing right there on purpose to make me laugh!"

Sakaguchi: "Who's usually the one teasing first?"

Miyuki: "Tonight isn't your turn to strike back. ...Kiss me again, and hurry up and put that thing inside me—I'm tired of waiting."

[Sakaguchi thrusts his hips deep inside; Miyuki's bossy tone shatters instantly as her legs lock tightly around his waist.]

Miyuki: "Aah—! Nnh, no fair, why are you only this aggressive at times like this...?!"

Miyuki: "Mmn, haah... Hold me tighter! I have no intention of saving face for you tonight... Ah, don't hit right there, you're going to make me scream...!"

Miyuki: "Alright, don't stop... Let me act spoiled and feel good to my heart's content tonight, and I'll lecture you tomorrow... Ah, I'm coming—aah...!"

[Full fade to black as the clock advances. Her crimson lace panties dangle from the back of the chair.]

**Day 1 | Aftermath**

[Sprawled lazily across the pillow with a smile still on her lips, Miyuki suddenly snatches up the pre-op prep sheet.]

Miyuki: "...I have an extremely important announcement."

Sakaguchi: "What is it?"

Miyuki: "Tomorrow morning, whichever junior nurse dares tell me 'Once you've signed you can't cancel, so relax, it'll only take a second' is getting a one-hour special training session from me the day I'm discharged!"

Sakaguchi: "That's word-for-word what you say when holding down patients who try to run in the wards."

Miyuki: "Shut up! I know! It's called instant karma!"

[She snatches up her hospital gown and panties, then slaps them right back onto the chair the next second.]

Miyuki: "Forget it, whatever happens happens! I worked up a sweat fooling around with you just now, and for a surgery that huge tomorrow, they have to scrub me clean inside and out anyway—changing gowns, catheterizing, and positioning are all their job. I'm lying here naked until morning, and if they wheel me onto the table naked, so what!"

Sakaguchi: "...Should I announce that at tomorrow morning's handover meeting?"

Miyuki: "Say one word and we're through! ...Even if that is literally what I just said."

[She laughs until she's out of breath, then tugs the sheet and suddenly freezes.]

Miyuki: "Takashi, tomorrow I really have to lie there waiting for general anesthesia, don't I? Over ten hours of being cut open for real... It starts on their say-so, I don't even have the right to call it off halfway, and once I'm asleep I can't even curse."

[She grabs his arm, her bluster deflating.]

Miyuki: "Darn it. Let me be scared all I want tonight—in front of my juniors tomorrow morning, I still want to act tough a little."

**Day 3 | Success**

Miyuki: "Listen up. I admit those junior nurses of yours did a great job, and I also admit I nearly clung to the bedsheet before anesthesia. Looking back now, slamming my panties onto the chair two nights ago and stubbornly yelling about 'instant karma' was beyond mortifying!"

Sakaguchi: "Should we include that episode in your new-hire training manual?"

Miyuki: "Don't you dare! ...Still, come to think of it, having you thrust so aggressively into my deepest spot that night and letting me spoil myself rotten still leaves my waist weak just remembering it. Since you serviced this senior so thoroughly in bed and performed beautifully with the scalpel, I'll give you top marks this time."

**Day 3 | Target Not Met**

Miyuki: "Tch, I told you staring at that prep sheet two nights ago and feeling like instant karma was coming for me was spot on! We really didn't finish it!"

Sakaguchi: "I brought the report. Falling short this time is on me."

Miyuki: "Hey, Takashi, fess up—did you get way too rough with me in the ward the night before surgery, focusing entirely on bullying me in bed and spending all your best strength on my belly, so your grip on the scalpel went weak the next day?"

[Narrowing her eyes, she pokes his chest with her fingertip before bursting into a giggle and looping her arms around his neck.]

Miyuki: "Forget it. Considering how well you fed your girlfriend two nights ago and made me feel so good I forgot how to lecture anyone, taking this knife wasn't a bad deal for this senior. Let me take the day off today and read me the report."

---

### 1.15 Minato Haruka | *Do Not Remind the Patient She Is Being Operated On*

**Day 1 | Consultation**

[Haruka pulls out a pen and taps her own wristband.]

Haruka: "I stuck a memo on myself prohibiting entry to the staff locker room tomorrow. Yet outside the consultation room door just now, I still reflexively wanted to ask if I'm first assistant today."

Sakaguchi: "You're not standing beside the table this time—and once you sign, there's no swapping places with the assistant."

Haruka: "Right, I'm lying on the table being cut open by you guys. ...Whoa, saying it out loud makes it ten times scarier. Let me sign right now before I forget where I put my courage a second from now."

**Day 1 | Special Ward, Pre-Op Night**

[A sticky note on the wall reads *"Today I am the patient."* Haruka stares at it for a long while, then suddenly peels it off.]

Haruka: "This note doesn't matter. Tonight, remembering you is enough. ...Can you stay with me? This is an invitation from your lover."

Sakaguchi: "How long would you like me to stay?"

Haruka: "Until I stop looking for sticky notes."

[Sakaguchi locks the door and removes his uniform and clothes; changing out of her hospital gown and pale-yellow star-patterned cotton bra and panties, she holds them in her arms first, forgets where they go, and blushes as she tosses them into the bedside basket. Naked, she lifts the sheet and smiles, patting the space beside her.]

Haruka: "I promise I won't stick your name to the pillow tonight."

[They kiss as the lights dim.]

Haruka: "Mmn... I don't need to write down the warmth of your palm to remember it."

Haruka: "Ah... Calling my name like that while touching my chest makes me feel shy all over..."

Sakaguchi: "I love you."

Haruka: "Say it again, I want to memorize it with my body... Nnh, I'm already wet down there, so hurry and come inside..."

[Sakaguchi covers her body and presses slowly to the hilt. Haruka's eyes widen before she lets out a soft gasp, wrapping both arms tightly around his neck.]

Haruka: "Ah...! Nnh, haah... So full... Even if I forget something tomorrow, I must never forget the feeling of being filled up by you tonight..."

Haruka: "Don't laugh, I mean it seriously... Ah, mmn... Pressing right there feels so good... No looking for pens right now, just hold me tight... I-I'm coming—aah...!"

[Full fade to black as the clock advances.]

**Day 1 | Aftermath**

[Half-asleep, Haruka reaches toward the nightstand, touches the surgical booking slip, and wakes up instantly.]

Haruka: "Uh-oh! Did I forget tomorrow's schedule? Actually, what if I just forget it on purpose—if I don't show up at the OR, won't they be unable to find the patient?"

Sakaguchi: "You're already checked into the Special Ward. Tomorrow morning the nurses will wheel you out directly by bed number—forgetting won't cancel the surgery."

Haruka: "Uu... Even my forgetfulness trick doesn't work?! It's a ten-plus-hour major surgery under general anesthesia! A minute ago I felt so good my head went completely blank... and now that I remember I'm really going to be cut open, bleed, and get sewed back up tomorrow, I don't even want to reach into the basket for my panties!"

[Sitting up stark naked, she grabs a pen and sticks up a fresh note.]

Haruka: "'Tomorrow morning: Do NOT wear white coat, do NOT fake amnesia to escape, do NOT operate on yourself.'"

Sakaguchi: "At least the last item doesn't need to be written down."

Haruka: "See? I'm so scared I'm writing nonsense! Since they have to change me again tomorrow morning anyway, I'm just staying naked under the covers tonight!"

[She sticks up another note.]

Haruka: "'If scared to tears by the sound of the gurney, no explanation required.' ...Would sticking this on the door be too embarrassing?"

Sakaguchi: "I'll remember it for you."

[She sticks the note to her own forehead, topples over laughing, then slowly quiets down.]

Haruka: "Truth is, I'm not afraid of forgetting the steps. I'm afraid of closing my eyes tomorrow and only finding out after I wake up what everyone went through inside my body for over ten hours."

[Crumpling the sticky note into a ball, she shrinks back under the covers and takes his hand.]

Haruka: "Don't write this last part down. Tomorrow morning, please stand somewhere I can see you."

**Day 3 | Success**

Haruka: "Look, I even remember today's date! ...Though waking up now and seeing the sticky note I wrote naked at midnight two nights ago saying 'Do NOT fake amnesia to escape'—and remembering how I left my panties in the basket refusing to dress—is way too silly! Hurry and peel it off for me!"

Sakaguchi: "Do you still remember saying you wanted to 'memorize the feeling of being filled up with your body' that night?"

Haruka: "Crystal clear! I couldn't forget that even without a sticky note... Just remembering the warmth of your palms and how deep you pressed inside me that night makes me so glad we finished this major surgery."

**Day 3 | Target Not Met**

Haruka: "I knew waking up at midnight two nights ago wanting to fake amnesia to skip the OR was my body sensing ahead of time that this surgery would hit a bump!"

Sakaguchi: "You don't have to force yourself to write a full log today. Let me tell you why we stopped first."

Haruka: "Okay, I should jot it down... Though Takashi, could Reason #1 be: the attending surgeon went so hard with the patient in bed on the night before surgery that he left my head blank and forgot his own stamina under my covers?"

[Tilting her head, she blinks mischievously before blushing and pulling his hand against her cheek.]

Haruka: "Just kidding. Even though falling short this time is a little disappointing, the feeling of being held tight by you two nights ago and memorizing with my body how much you love me is something I won't forget for the rest of my life. For that night alone, lying on the table was worth it."

---

## 2. Future Conditional Characters: 9 Full Standby Scripts (Preloaded Assets Only, Do Not Enable Yet)

**Standby Authorization Notice:** The following content may only be enabled in the future if and when the respective character has genuinely completed "adult mutual romantic relationship + H qualification + Lv5 Staff-as-Patient authorization + Sayaka C04 global approval" and is active on the current hospital roster. Writing these scripts does not constitute default approval of their future routes; characters explicitly excluded by the author are omitted. Personal routes for Moe, Rumi, Shiori, etc. remain governed by their official Character Bibles.

### 2.1 Moe Honjo | *Please Allow Me Five Minutes to Be Scared* (★ Heightened Cold-Feet Tension)

**Day 1 | Consultation**

[Moe listens intently, then draws a big circle next to "Prep Time" and swallows nervously.]

Moe: "D-Does prep really start this early? And you said once I sign, even if I'm shaking with fear tomorrow morning, the surgery can't be canceled anymore..."

Sakaguchi: "Yes. If you haven't made up your mind yet, we can hold off on signing."

Moe: "N-No, I want to sign! Precisely because I'm such a coward, if I don't block off my own escape route right now, I'll definitely run away the second I see the OR doors tomorrow... Please hand me the pen!"

**Day 1 | Special Ward, Pre-Op Night**

[Moe sits in the center of the bed with both hands on her knees, as if having resolved a monumental decision.]

Moe: "Tonight I want to ask for it myself... I want you to stay, and I want to be close to you. Not because I'm having surgery tomorrow—I wanted to all along."

Sakaguchi: "I'd love to."

Moe: "Then I won't start with 'Sorry to bother you' tonight."

[She reaches out to close the door while Sakaguchi locks it and removes his outer clothes. Blushing crimson, she changes out of her hospital gown and slips off her strawberry-print white cotton bra and panties, leaving a small pile of clothes beside the bed; seeing Sakaguchi still standing, she shyly pats the sheet and earnestly makes room for him.]

Moe: "I'm all undressed and ready. ...Wait, I mean for tonight! I'm still not ready for tomorrow's thing at all."

[Smiling, they kiss as the lights dim.]

Moe: "Ah... The moment you touched me, did I squeak too loudly just now?"

Moe: "Mmn, kiss me again... and touch me down there too... I really want you to."

Sakaguchi: "Nobody's rushing you."

Moe: "Then I'll take it slow... Nnh, I'm already soaked down there... I didn't know I could get this excited..."

[Sakaguchi gently sinks his hips inside; Moe's petite frame shudders as both arms wrap tightly around his back, her voice brimming with honest joy and bashfulness.]

Moe: "Aah—! I-It's in... So hot, so full... Hold me tighter, tonight I just want to stay connected with you forever..."

Moe: "Stop calling me a good girl, right now I'm the one asking you to thrust into me hard... Ah, mmn... This feels so wonderful, I don't want to think about ward shifts at all tonight... I-I'm coming—aah...!"

[Full fade to black as time advances.]

**Day 1 | Aftermath**

[Panting with rosy cheeks, Moe giggles while pulling the sheet high up over her bare chest—until she hears someone in the hallway outside ask "Which room number?"]

Moe: "...Kyaa! A-Are they here to take me to surgery already?!"

Sakaguchi: "No, that's just night rounds. Your pre-op prep isn't until tomorrow morning."

Moe: "Uu... That scared the life out of me! Being with you felt so good just now that I completely forgot I'm having `<Current Procedure>` tomorrow... Over ten hours of major surgery under general anesthesia, where you really cut my belly open, make me bleed, and cut things out inside..."

[Looking down at her bare body under the sheet, tears suddenly well up in her eyes as her small hands clutch Sakaguchi's arm.]

Moe: "Dr. Sakaguchi... W-Was I too impulsive during the day? I'm suddenly so terrified, my stomach is cramping up... Can't we tell my seniors tomorrow morning that Moe got cold feet and cancel it just this once...?"

Sakaguchi: "No can do, Moe. The consent form is already filed—once the prep cart rolls in tomorrow morning, even if you hide under the covers, your seniors will scoop you right onto the gurney."

Moe: "Uuu... How could you... Even knowing it won't leave permanent damage and I'll heal in a couple of days, just realizing there's really no escaping tomorrow and I have to lie on that table and be cut open makes me too scared to even reach for my strawberry panties beside the bed..."

[Sniffling, she ducks her head into Sakaguchi's chest, pressing her naked body flush against him.]

Moe: "Since begging won't get it canceled... I'm not putting my panties or hospital gown back on tonight! My seniors have to change me, prep my skin, and catheterize me tomorrow morning anyway. I'm definitely going to cry tomorrow morning, so even if you won't call off the surgery, you have to make my seniors wait five minutes for me to finish crying before wheeling me in..."

**Day 3 | Success**

Moe: "That morning, Sugimura-senpai patted my head to coax me while helping me into my surgical gown and lifting me onto the gurney. Now that I'm safely awake, remembering how I heard night rounds at midnight two nights ago and clutched your arm crying to cancel the surgery—while refusing to put on my strawberry panties... I'm so ashamed I could die!"

Sakaguchi: "How do you feel now?"

Moe: "Now I'm super happy! And... whenever I remember begging you to touch me that night and being filled with your warmth from head to toe, I'm so glad you didn't let me back out. Thank you, Dr. Sakaguchi."

**Day 3 | Target Not Met**

Moe: "Uu... I knew my stomach cramping up at midnight two nights ago and crying to back out was my body sensing ahead of time that this surgery wouldn't go smoothly..."

Sakaguchi: "We didn't reach the final goal, but the team aborted safely in time. Let me explain why."

Moe: "Okay... Um, Dr. Sakaguchi, I don't know if I should ask this... Could it be because I was too greedy in bed two nights ago and kept clinging to you asking you to thrust harder, draining all of Dr. Sakaguchi's strength before the surgery the next day...?"

[Blushing furiously as she asks timidly, she quickly clasps Sakaguchi's hand and gives it a little shake.]

Moe: "I-I'm sorry, I was just trying to make a joke! Even though I'm a little sad the surgery didn't finish, whenever I remember how good and happy it felt being held in your arms two nights ago, I don't regret taking this knife one bit!"

---

### 2.2 Manami Iimura | *Pharmacology Cannot Cure Self-Induced Panic*

**Day 1 | Consultation**

[Checking the anesthesia medication sheet, Manami pauses her pen when she reaches her own name.]

Manami: "This medication regimen is impeccably rational. So rational that once I sign my name and have zero room to back out tomorrow, I might get so scared I want to burn down the pharmacy."

Sakaguchi: "Anything else you need to verify?"

Manami: "...No, let's just sign. I'll get all my questions out before signing, because when they wheel me onto the table tomorrow I probably won't even be able to speak straight."

**Day 1 | Special Ward, Pre-Op Night**

[She places a sheet of paper at the head of the bed with *"No Mentioning Medications Tonight"* written at the top.]

Manami: "Here's a completely unscientific intervention I'm dying to test: you staying the night."

Sakaguchi: "No control group needed?"

Manami: "None. If you dare suggest a second participant, I'm kicking you out right now. ...I'm inviting my boyfriend."

[Sakaguchi locks the door and removes his clothes. Changing out of her hospital gown, Manami slips off her mint-green bra and panties, sticks the *"No Mentioning Medications"* note to the headboard, and gleefully lifts the sheet stark naked to let him in.]

Manami: "Tonight you're only allowed to call my name—writing prescriptions is strictly prohibited."

[They kiss as the lights dim, the sound of hot, damp touches soon rising beneath the covers.]

Manami: "Mmn... I suspect I'm going to love this therapy... Your hands are so hot..."

Manami: "Ah... You didn't even banter back, your hand went straight down there..."

Sakaguchi: "I just want to kiss you and make you mine."

Manami: "Then come on... I'm already wet, no need for further pre-clinical trials..."

[The instant Sakaguchi drives inside, Manami lets out a sweet nasal moan, her hips arching involuntarily to meet him.]

Manami: "Ah...! Nnh, so deep... Right now I don't want to calculate half-lives or guess what time it is tomorrow..."

Manami: "Mmn, haah... When you thrust in like that, I forget every single symptom... Don't draw any conclusions tonight, just hold me tighter... Ah, I'm coming—aah...!"

[Full fade to black as time advances.]

**Day 1 | Aftermath**

[Stretching languidly, Manami slowly counts on her fingers.]

Manami: "It just occurred to me: does ten-plus hours of general anesthesia tomorrow count as paying off tonight's stamina expenditure and this year's sleep debt in one lump sum?"

Sakaguchi: "Anesthesia isn't sleep."

Manami: "I know that! Can't a girl crack an absurd joke for her own sanity?"

[She suddenly bolts upright, her eyes landing on the locked medication and surgical schedule at the head of the bed.]

Manami: "Wait a second—tomorrow I really have to take that full anesthesia protocol and get cut open by you guys for over ten hours! Once that IV push goes in, before I can even yell 'Wait, I changed my mind,' I'll be handing my entire body over to your scalpels!"

Sakaguchi: "The anesthesia team will run through verification with you first, though the surgery itself definitely can't be canceled."

Manami: "Yeah, I know there's no backing out. ...Still, a minute ago I was feeling heavenly in your arms, and now just remembering I'm guaranteed to take the knife tomorrow turns my hands and feet ice-cold."

[She grabs her hospital gown and mint-green panties at random, then silently pushes them aside.]

Manami: "Forget it, I'm leaving these off and staying naked until morning. They have to change me per pre-op protocol tomorrow morning anyway. I hereby declare this patient has entered a 'Please Stop Explaining Science to Me' state."

Sakaguchi: "How long does that state last?"

Manami: "Until I wake up tomorrow! ...Ah, hearing myself say that made me scared all over again."

[Flopping back onto the pillow, she presses her cheek against his chest.]

Manami: "Just keep your hand right here. Tonight, this is the only effective treatment for my overactive imagination."

**Day 3 | Success**

Manami: "Experimental conclusion: understanding the pharmacokinetics of anesthesia and actually having the guts to be put under when you can't run away are two completely different things! Waking up now and remembering how my hands and feet went ice-cold two nights ago, refusing to put on my mint-green panties and declaring a 'Stop Explaining Science to Me' state... what an embarrassment to pharmacists everywhere."

Sakaguchi: "Though that 'unscientific intervention' worked pretty well that night, didn't it?"

Manami: "More than well... Just remembering how you touched me straight down there and drove deep inside until I forgot every symptom beat any sedative in the dispensary. I'm very satisfied with the outcome—just don't you dare write about me shaking before induction in the case report!"

**Day 3 | Target Not Met**

Manami: "I knew staring at the medication sheet two nights ago with ice-cold hands and feeling uneasy about being knocked out for ten-plus hours was my pharmacist's intuition sounding the alarm early!"

Sakaguchi: "I won't brush you off with 'reversible side effects'—I'll give you the full debriefing report."

Manami: "At least you're honest. Before that, though, let me analyze the external contributing factors to this clinical incident—Dr. Sakaguchi, did you skip pre-clinical trials on me a little too vigorously two nights ago and go so hard all night that the lead surgeon burned through all his blood sugar and stamina in my hospital bed?"

[She lets out a teasing laugh, then lazily pulls his hand over to press against her cheek.]

Manami: "Alright, I'm just ribbing you. Even though falling short is disappointing, whenever I savor the rush of being possessed by you two nights ago and losing track of time completely, taking this knife was still a great deal. Once I catch my breath, let's go over the report together."

---

### 2.3 Rumi Iwasaki | *A Surgical Party Missing Its Guest of Honor*

**Day 1 | Consultation**

[Reading the team roster, Rumi claps her hands and bursts out laughing.]

Rumi: "Unreal! To perform `<Current Procedure>` on me, you assembled the most deluxe all-star lineup in the hospital. You couldn't snag VIP treatment like this on a regular shift if you tried!"

Sakaguchi: "Once you sign, the guest of honor isn't allowed to walk out halfway through tomorrow's party."

Rumi: "Signing! ...Just wait till I finish signing before you take the sheet away—staring at 'Estimated Duration: 10+ Hours' is giving me the hiccups."

**Day 1 | Special Ward, Pre-Op Night**

[Using a paper cup from the nightstand as a microphone, she mimics an MC.]

Rumi: "Welcome to 'Rumi Iwasaki's Final Night of Pre-Op Freedom'! Our sole special guest: tomorrow's lead surgeon and tonight's boyfriend!"

Sakaguchi: "Can I decline to appear on the show?"

Rumi: "No way! Tonight I want to be with you. ...And I mean that for real, don't treat it as a bit."

[Tossing the paper cup into the bin, she pulls him over to lock the door herself. Sakaguchi removes his clothes; flinging her hospital gown and vibrant bright-orange bra and panties onto the chair back, she takes an exaggerated bow stark naked and dives grinning under the sheet.]

Rumi: "Special guest, please take the bed—no MC script tonight, we're jumping straight to the main event!"

[She reaches up to kiss him as the ward lights dim.]

Rumi: "...Mmn. Whoa, your hands really don't hold back when touching a girl."

Rumi: "Ah... Stop tickling me and touch the sensitive spots directly... Are you trying to make me laugh to death?"

Sakaguchi: "I'm being serious."

Rumi: "Then I'll be serious too. ...I really, really love you... Nnh, I'm already this wet down there, so hurry up and come inside!"

[Sakaguchi sinks his hips and buries himself to the hilt in one stroke; Rumi's bubbly laughter instantly turns into a high-pitched gasp as her legs lock tightly around his waist.]

Rumi: "Aah—! S-So deep...! When I said I love you just now, I didn't say it loud enough... Haah, mmn...!"

Rumi: "Tonight I'm not here to put on a brave show... Hold me tight, thrust into me harder... Let me pretend tomorrow doesn't exist for five minutes... Ah, I'm coming—aaah...!"

[Full fade to black as time passes.]

**Day 1 | Aftermath**

[Lying drenched in sweat in the center of the bed, Rumi raises one hand to take a curtain call—until her eyes land on the *"Tomorrow's Surgical Booking (Locked)"* sign on the wall.]

Rumi: "...Ah! Crap! The main feature is still tomorrow! And tickets are non-refundable!"

Sakaguchi: "Didn't you say tonight was the Night of Freedom?"

Rumi: "Then what's tomorrow?! The whole hospital throws a ten-plus-hour live-blade surgical party where the guest of honor gets powered down under general anesthesia, has her belly cut open and worked on all day, and wakes up to listen to everyone else recap the event?! What kind of variety show is that?!"

[Stark naked, she snatches up her hospital gown and bright-orange panties, holding them high overhead like a podium speech.]

Rumi: "Since tickets are non-refundable, I hereby declare I'm not getting dressed tonight! I just felt amazing for hours, and tomorrow the girls have to put me through a full pre-op prep routine anyway. I'm staying naked right here until morning—when they show up, they can load me onto the gurney and wheel me straight onto the table naked! See if I care!"

Sakaguchi: "Are you sure you want the morning-shift nurses to hear that quote?"

Rumi: "...No! If you dare tell them, I'm firing you from the production crew!"

[Halfway through her laugh, she notices her hand holding the clothes is trembling.]

Rumi: "...Darn it. I meant to deliver that joke way funnier."

Sakaguchi: "I thought it was pretty funny."

Rumi: "Then why are you still watching me shake? I know there's zero permanent damage, and I know I won't feel a thing under general anesthesia... but just thinking about actually being wheeled through the OR doors tomorrow morning for such a huge operation with nowhere to run, I'm probably going to bawl like an idiot."

[Dropping the clothes, she grabs hold of him.]

Rumi: "Don't you dare applaud me ahead of time. Save it for after I wake up."

**Day 3 | Success**

Rumi: "Even though I couldn't hear whether you guys threw me a 'surprise party' on the table, the result is seriously awesome! Waking up now and remembering how I held my panties overhead naked giving a speech two nights ago—only for my hands to shake until I nearly cried—is the biggest black mark on this MC's career!"

Sakaguchi: "The ratings for that 'Night of Freedom' special were through the roof, though."

Rumi: "You bet they were! Just remembering how you touched my sensitive spots directly that night and drove inside until I forgot all my lines still makes my whole body burn. Come on, now you can applaud your leading lady and deliver the box-office report!"

**Day 3 | Target Not Met**

Rumi: "Whoa, talk about tough luck! I told you my hands were shaking when I saw 'Non-Refundable' on the wall two nights ago—turns out this MC's sixth sense already knew the main feature was going to flop!"

Sakaguchi: "I'm sorry, Rumi. We couldn't bring it across the finish line this time."

Rumi: "Hey, Sole Special Guest Mr. Sakaguchi, I have a strong suspicion—did you jump into the main event a little too hard during our 'Night of Freedom' broadcast two nights ago, pinning me down and thrusting for so long that you left all your surgical stamina in my bed?"

[She laughs and slaps Sakaguchi's arm, before quieting down and blushing as she squeezes his hand.]

Rumi: "Alright, just messing with you! Even though it's a bummer the main feature didn't finish, lying in your arms two nights ago without having to put on a brave show and getting loved so thoroughly more than paid for the ticket! Come on, tell me seriously where we hit a snag."

---

### 2.4 Shiori Yoneda | *A Patient Has the Right to Sniffle* (★ Heightened Cold-Feet Tension)

**Day 1 | Consultation**

[Shiori asks through the prep sheet line by line, her fingers twisting the hem of her uniform until she whispers one last question.]

Shiori: "Dr. Sakaguchi... I know that once I sign my name, tomorrow's surgery can never be canceled. B-But if I get so scared on the gurney tomorrow morning that I can't speak, or even try to shrink back, will everyone get mad at me and think, 'Didn't you already sign the consent form'?"

Sakaguchi: "The surgery won't be canceled, but nobody will get mad at you. Everyone will hold your hand and wait until you catch your breath."

Shiori: "...Okay. As long as you won't think I'm a nuisance. I'll sign now."

**Day 1 | Special Ward, Pre-Op Night**

[Shiori has rolled a hand towel into a cylinder, kneading it endlessly in her hands.]

Shiori: "I just practiced saying 'I'm not scared' fifteen times. And didn't succeed once."

Sakaguchi: "No need to practice tonight."

Shiori: "Then I'd like to ask you to stay with me. I want to kiss you, and spend a night that makes me forget all about the hospital."

[She looks up, waiting for Sakaguchi's nod. He locks the door and removes all his clothes; blushing deeply, Shiori unbuttons her hospital gown, slips off her white lace-trimmed cotton bra and panties, sets the towel aside, and sits under the sheet shielding her body shyly as she earnestly pats the space beside her.]

Shiori: "I'm not joking, okay? ...Come here now."

[She kisses him first as the lights dim.]

Shiori: "Mmn... Finally I don't have to practice any standard lines."

Shiori: "Ah... Don't suddenly call me Shiori while touching me there... You'll make me bashful."

Sakaguchi: "What should I call you, then?"

Shiori: "...Keep calling me Shiori. I love it when you call me that... Nnh, I'm already wet down there... Tonight I'm the one who wants you to come inside."

[Sakaguchi enters her gently yet firmly; Shiori lets out a soft cry, tears glistening at the corners of her eyes as both hands cling tightly to his shoulders.]

Shiori: "Kya...! Nnh, haah... So deep, so hot... Hold me tighter... I'm so happy right now..."

Shiori: "Tonight I won't say 'I'm not scared' anymore... I just want you to keep pressing inside me like this... Ah, mmn... I-I'm coming! Don't turn the light on right away... uwaah...!"

[Full fade to black as time advances.]

**Day 1 | Aftermath**

[Panting with crimson cheeks, Shiori suddenly lifts her head from the pillow.]

Shiori: "Wait a second. That felt so good just now, I almost thought we were at an ordinary inn on our honeymoon."

Sakaguchi: "This is the Special Ward."

Shiori: "Which means tomorrow morning they're really coming to pick me up, run through that impossibly long prep sheet... and wheel me onto the operating table for over ten hours of general anesthesia, cutting me open for real for a huge operation..."

[Her breathing quickens instantly;stark naked, she curls into a tiny ball deep under the covers, the rims of her eyes turning bright red.]

Shiori: "Dr. Sakaguchi... What do I do? During the day I thought I could handle it, but now when I think about actually being cut open and bleeding tomorrow, having my insides operated on, my stomach goes ice-cold with fear... I-If I say I want to cancel right now, it's definitely too late, isn't it?"

Sakaguchi: "Too late, Shiori. The consent form is locked in the filing cabinet—at eight tomorrow morning, nobody can call off the surgery."

Shiori: "Uu... I knew you'd say that... This afternoon I acted tough and said 'I can take it,' and now all I want is to lock you inside this room so tomorrow morning's nurses can't open the door and take me..."

[Spotting her patient gown and lace-trimmed panties on the floor, she pulls the sheet over her eyes in a sulk.]

Shiori: "Since there's zero chance of escaping... I'm not putting my panties or hospital gown back on tonight! Once I put them on, I'll have to lie there like a resigned, obedient patient waiting to be wheeled away. At least until sunrise when they hold me down on the gurney, I have the right to hide naked in your arms and sniffle, don't I?"

Sakaguchi: "You do. You can cry as long as you like."

Shiori: "Alright then, I hereby revoke the rule stating 'Shiori Yoneda is not allowed to cry tonight.'"

[Before she even finishes the sentence, she is already sniffling under the sheet; held tightly by Sakaguchi through the duvet, she laughs through her tears a moment later.]

Shiori: "...Too late. That rule failed to execute from the very start."

**Day 3 | Success**

Shiori: "At the OR doors I really got so scared I grabbed the side rails, and the older nurses waited until I finished crying a little before wheeling me inside. Now that I'm safely awake, remembering how I mistook this ward for a honeymoon inn two nights ago, then hid naked under the sheet sniffling and wanting to lock you in the room... it's so embarrassing..."

Sakaguchi: "Though I recall someone being remarkably brave when she invited me inside her that night."

Shiori: "Kya... Dr. Sakaguchi, no bringing that line up! Still, whenever I remember how warm it felt having you call me 'Shiori' while holding me so deep two nights ago, I actually feel a little proud of myself. Thank you for staying with me."

**Day 3 | Target Not Met**

Shiori: "Uu... I knew my stomach going ice-cold two nights ago and crying to cancel the surgery was because my heart already sensed things wouldn't go quite right this time..."

Sakaguchi: "I know it's hard on you. We couldn't complete the target this time—let me explain everything clearly."

Shiori: "Okay... Um, Dr. Sakaguchi, please don't be mad at me for asking... Could it be because I kept you in our imaginary 'honeymoon inn' for so long two nights ago that you used up all your strength on me, and couldn't hold out at the operating table the next day...?"

[With red-rimmed eyes, she shyly cracks a tiny joke before obediently reaching out both hands to clasp his palm.]

Shiori: "I just wanted to make you smile... Truth is, even if the surgery didn't finish, whenever I remember you touching me there two nights ago and filling me up so warmly, I don't feel wronged taking this knife at all. Once I stop shaking, can we read the chart together?"

---

### 2.5 Itsumi Sonoda | *Come In, the Patient Is Not Ready Yet* (★ Heightened Cold-Feet Tension)

**Day 1 | Consultation**

[Holding up her wristband for a look, Itsumi suddenly laughs.]

Itsumi: "My name is printed so clearly. Normally when I fasten these onto patients who've signed the form, I smile and coax them with 'No backing out now, hang in there!' Now that it's fastened around my own wrist, my first instinct is to hide it up my sleeve."

Sakaguchi: "Still time to change your mind before signing."

Itsumi: "Not changing it! ...Just remember, I'm signing to agree to the surgery—not promising I'll still be able to smile when they wheel me onto the table tomorrow."

**Day 1 | Special Ward, Pre-Op Night**

[She greets Sakaguchi at the door, beaming as if she has a surprise gift waiting for him.]

Itsumi: "No rounds allowed tonight. You have one job only—being my boyfriend and staying the night with me."

Sakaguchi: "Today's patient sounds mighty resolute."

Itsumi: "Because it's what I want for myself! ...Come on in."

[He locks the door and removes his clothes. Taking off her hospital gown and cherry-blossom pink matching bra and panties, Itsumi sets them on the chair, straightens the sheet, and plants a light kiss on his cheek stark naked before slipping shyly into bed.]

Itsumi: "Now we can kiss longer and go deeper. ...Doctor, please get in bed."

[The lights dim, leaving only their entwined silhouettes and quickening breaths.]

Itsumi: "Mmn... Don't laugh, I had a really pretty line prepared... Nnh, don't suddenly knead my chest like that..."

Itsumi: "Ah... Your touch made me forget the whole line."

Sakaguchi: "Then you don't need to say it."

Itsumi: "No way, I at least have to say this much: I love you... and I'm already wet and ready for you down there."

[Sakaguchi sinks his hips into her wet warmth; Itsumi lets out a sweet moan, actively lifting her legs to wrap around his waist.]

Itsumi: "Aah—! So full... Kiss me again, okay? ...Mmn, when you press this deep inside me, tonight suddenly feels so long and blissful..."

Itsumi: "Let's leave tomorrow for tomorrow... Thrust a little harder, come with me one more time... Ah, nnh... I-I'm coming—aah...!"

[Full fade to black as time passes.]

**Day 1 | Aftermath**

[Rolling over languidly in the afterglow, Itsumi faces the ward door and suddenly practices a line out loud:]

Itsumi: "'Come in, the patient is ready.' ...Ah! Why did I say that?!"

Sakaguchi: "Will you still say that tomorrow morning?"

Itsumi: "Definitely not! It felt so good in your arms just now that I completely forgot I'm having `<Current Procedure>` tomorrow! That's over ten hours of real-blade major surgery where my skin and muscles get cut open, bleed, get resected, and get sutured back up layer by layer!"

[She bolts upright and grabs Sakaguchi's arm, shaking it with a half-joking, half-earnest plea.]

Itsumi: "Takashi... Can't we really call the scheduling office and tell them Itsumi suddenly feels unwell, so we're canceling tomorrow's operation? There's nothing wrong with my body, and we know I'll heal completely afterward, so why do I have to go take this knife?!"

Sakaguchi: "Because you signed the form yourself. You know Hoshimi's rules better than anyone—once you're on tomorrow morning's OR board, even if the patient rolls around on the mattress, she gets wheeled in on time."

Itsumi: "Uu... How did I ever think that hospital rule was reasonable?! Now that I'm the one strapped to the chopping block, it's completely inhumane!"

[Glancing at her cherry-blossom pink underwear and hospital gown on the chair back, she shrinks back under the covers stark naked, moisture glistening at the corners of her eyes.]

Itsumi: "Since begging won't get it canceled... I don't want to put my panties or hospital gown back on tonight at all! They're going to strip me bare for prep tomorrow morning anyway. If they push the door open tomorrow morning and ask 'Are you ready?', I'm definitely going to bawl and yell 'Not ready at all!' And you're not allowed to laugh at me!"

**Day 3 | Success**

Itsumi: "When I woke up, my first words were still almost 'Come in'! Now that the surgery is over, remembering how I shook your arm two nights ago begging you to fake a sick call to the scheduling office, and lay naked cursing the hospital rules as inhumane... I'm too mortified to go back to the nurses' station!"

Sakaguchi: "Well, when someone was in bed begging me to 'come with her one more time' that night, she certainly didn't sound unwell."

Itsumi: "Takashi! Stop quoting what I said back then! ...Still, savoring the bliss of having you knead my chest and press all the way to my deepest spot that night makes taking the knife for ten-plus hours completely worth it. Thank you for taking care of me all day!"

**Day 3 | Target Not Met**

Itsumi: "See?! Two nights ago when I refused to put my cherry-blossom pink panties back on and cried for you to cancel the surgery with the scheduling office, I knew this operation wouldn't be a walk in the park!"

Sakaguchi: "I'm sorry, Itsumi. We really couldn't reach the target this time."

Itsumi: "I wanted to crack a joke to lighten the mood... like asking our Lead Surgeon Sakaguchi whether holding me down in bed two nights ago 'kissing too long and going too deep'—and coming with me so many times—overdrew all his strength for the operating table the next day?"

[She bursts into a giggle; though her eyes are still slightly red, she reaches out to pull Sakaguchi's palm under the covers against her skin.]

Itsumi: "Alright, I'll stop teasing you. Even though falling short is a little sad, whenever I remember feeling so good beneath you two nights ago that I forgot all my lines, taking this knife wasn't a loss at all. Come on, tell me the whole story."

---

### 2.6 Megumi Kariya | *Fear Outside the Price Quote* (★ Pragmatic Cold-Feet Tension)

**Day 1 | Consultation**

[Kariya verifies the sick-leave and compensation terms first, then stares motionless at the estimated surgical duration and the *"Irrevocable Upon Signing"* clause on the plan.]

Kariya: "All terms are clear. ...Just one question: why does knowing I can't breach the contract once I sign make these ten-plus hours look like ten-plus years?"

Sakaguchi: "Being scared is normal. You can still run the numbers before putting pen to paper."

Kariya: "No need to run them again, I've made my decision. Let me sign right now, or if I stare at it two seconds longer, I might actually get cold feet."

**Day 1 | Special Ward, Pre-Op Night**

[Closing her ledger, she actually shoves it into the deepest corner of the ward drawer.]

Kariya: "Let's get one thing straight first. Wanting you to stay tonight isn't part of the contract, and has zero connection to tomorrow's compensation."

Sakaguchi: "It's your personal invitation."

Kariya: "It's because I love you. ...Do you need me to put that in writing to confirm?"

[Sakaguchi locks the door and removes his clothes. Changing out of her hospital gown, Kariya unfastens her practical navy-blue bra and panties and tosses them beside the bed; she tries to strike a bold pose stark naked first, only to burst out laughing in embarrassment and pull up the sheet while waving him over.]

Kariya: "Tonight I'm not quoting prices, and you're not allowed to haggle. Get over here."

[She kisses him first as the lights dim.]

Kariya: "Mmn... Tonight I genuinely don't want to count a single yen... Nnh, where do you think your hand is wandering..."

Kariya: "Ah... How dare you rub me down there while asking if it's worth the price?!"

Sakaguchi: "Is it worth it?"

Kariya: "...Worth it. Tenout-of-ten worth it! Alright, stop asking and hurry up and come inside!"

[Sakaguchi drives all the way to the hilt in one stroke; Kariya sucks in a sharp breath, her shrewd, brisk tone shattering instantly into breathless gasps.]

Kariya: "Aah—! Haah, so deep...! Kiss me again, I don't want to sleep yet... There's no timecard tonight, you can do it as long as you want..."

Kariya: "To think you're making me feel this good... What a terrible bargain, I can't even hold my voice back... Ah, mmn... I love you anyway... I-I'm coming—aah...!"

[Full fade to black as time advances.]

**Day 1 | Aftermath**

[Panting and limp, Kariya reaches for the drawer, touches her ledger, and suddenly hesitates to open it.]

Kariya: "I just realized I signed the most absurd money-losing deal of my life."

Sakaguchi: "Counting money again?"

Kariya: "Not money! Tomorrow I'm handing over ten-plus hours to you guys while I sleep under general anesthesia, letting you cut me open for real on the table, bleed, resect, and suture me back up! On paper, knowing I'll heal completely afterward without lifting a finger sounds like easy street! Yet now that my head is clear, just thinking about being wheeled in tomorrow morning for such a huge knife has my heart jumping out of my throat!"

[Shoving the ledger back inside, she sits naked under the sheet and clutches Sakaguchi's wrist.]

Kariya: "Dr. Sakaguchi... um, what if I say right now that I waive the stipend—and I'll even pay the penalty fee out of pocket—can we cancel tomorrow's surgery...?"

Sakaguchi: "Hoshimi's surgical consent form doesn't have a penalty-fee cancellation clause. Once signed, you have to get on that operating table tomorrow."

Kariya: "...I knew it! What a loan-shark hospital! You won't even let me buy my way out! Tomorrow morning the nurses will wheel me onto the table, and once the anesthesia hits I won't even be able to get a word in—what a rip-off!"

[Glaring at her navy-blue panties and hospital gown beside the bed, she flops back under the covers in a huff.]

Kariya: "Since I can't cancel, I'm not getting dressed tonight! I sweated buckets just now, and they have to change and prep me tomorrow morning anyway—saving the effort of putting my panties back on counts as recouping a little labor cost! Let them see tomorrow morning that the patient herself has gone on strike!"

Sakaguchi: "That won't reduce a single medical prep step tomorrow morning."

Kariya: "Are you really going to deduct overhead from my tiny bit of self-consolation?!"

[She laughs indignantly, before slowly leaning against Sakaguchi's side, her voice dropping.]

Kariya: "Even knowing it won't leave permanent damage, realizing there's no way out still makes my palms sweat with fear. ...You really can't put a price tag on a feeling like this."

**Day 3 | Success**

Kariya: "Everything written in the contract was honored. Waking up safely now and auditing the books, remembering how I got so scared two nights ago that I offered to pay a penalty fee to cancel the surgery—and lay naked calling the hospital a loan shark—completely bankrupted my shrewd image!"

Sakaguchi: "So did this transaction end up in the black or in the red?"

Kariya: "A massive windfall, obviously! Just remembering how you rubbed me down there in bed on the pre-op night asking 'Is it worth it?' and drove inside until I couldn't hold my voice back—that pleasure alone was priceless. Let me lean on you and savor the return on investment for a minute, we'll settle the ledger tomorrow."

**Day 3 | Target Not Met**

Kariya: "I told you touching my ledger two nights ago and feeling like this was an absurdly bad deal was my business intuition talking—sure enough, the surgery really didn't finish!"

Sakaguchi: "All guarantees and prior arrangements stand as agreed. Falling short of the surgical target is the medical team's responsibility."

Kariya: "Of course they stand! Still, Dr. Sakaguchi, let's audit our internal books—when you heard 'there's no timecard tonight, do it as long as you want' two nights ago, did you overdraw so much stamina inside me that your surgical precision took a haircut at the table the next day?"

[Raising an eyebrow with a shrewd tease, she sees Sakaguchi's wry look and blushes, bursting into laughter as she hooks her finger around his.]

Kariya: "Alright, I won't dock your performance bonus. Even though falling short is disappointing, whenever I savor how good you made me feel two nights ago until I didn't care about counting a single yen... taking this knife was still well worth it. Hand over the report."

---

### 2.7 Saeko Hikami | *The Subject Was Absent from the Scene*

**Day 1 | Consultation**

[After reviewing every verification item, Saeko caps her pen without a change in expression.]

Saeko: "I used to think I was quite skilled at observing people's expressions when facing surgery. Only today, upon signing my own name and cutting off every avenue of retreat, did I learn that one's own expression is the hardest to manage."

Sakaguchi: "Do you need more time?"

Saeko: "No. ...Or rather, I do, but I have no intention of solving it through delay. I'm signing for this operation."

**Day 1 | Special Ward, Pre-Op Night**

[Standing with her back to the ward door looking out the window, Saeko turns around slowly when she hears Sakaguchi enter.]

Saeko: "How curious. Tomorrow is my operation, yet tonight all I want is for you to ask no questions at all."

Sakaguchi: "Not a single question?"

Saeko: "You may only ask 'Do I want to kiss you?' ...And the answer is yes. Will you stay?"

[Giving a slight nod, she watches him lock the door and remove his clothes. Unhurriedly unbuttoning her hospital gown, Saeko slips off her cool silver-grey satin bra and panties, places her clothes neatly aside, and sits naked on the bed, raising a hand to invite him closer.]

Saeko: "Tonight you don't need to know a thing. Knowing how badly I want to become one with you is enough."

[They kiss as the lights dim.]

Saeko: "Mmn... I thought I would be more reserved once completely undressed."

Saeko: "Ah... Don't rush to speak, move your hand a little lower... I'm already wet down there."

Sakaguchi: "Saeko."

Saeko: "...When you call my name like that, it makes me want to smile... Nnh, hurry and come inside..."

[As Sakaguchi sinks deep to her core, the usually composed investigator arches her insteps tautly, her cool voice instantly thick with nasal tremors.]

Saeko: "Aah—! Nnh, haah... Right now there's no need to observe anyone, including my own undone expression..."

Saeko: "Mmn, ah... You're pressing so deep... Don't ask what I'm thinking tonight... I truly feel wonderful, truly happy... Ah, I can't—I'm coming—aah...!"

[Full fade to black as time advances.]

**Day 1 | Aftermath**

[Her chest rising and falling softly, Saeko stares at the curtain with damp eyes before letting out a quiet laugh after a long silence.]

Saeko: "I've composed tomorrow's patient testimony."

Sakaguchi: "Testimony?"

Saeko: "'After signing an irrevocable consent form, the subject observed a row of familiar faces in the operating room the following morning. Consciousness was lost following anesthesia induction. For over ten hours, every detail regarding the incision, resection, and suturing of her own body was relayed solely through third-party accounts.'"

Sakaguchi: "You'll receive the complete operative record."

Saeko: "Of course. It isn't the record I doubt."

[Lifting the sheet, her gaze falls upon the silver-grey lingerie and hospital gown beside the bed.]

Saeko: "It's just... beneath you a moment ago, I could choose whether to let you see me lose my composure. Tomorrow I put on a patient cap, undergo prep and general anesthesia without even the right to call a halt and walk away, and cannot even know how disheveled I look."

[With complete deadpan seriousness, she pulls the sheet up over her bare shoulders.]

Saeko: "Perhaps I shall refrain from putting my underwear and patient gown back on tonight. Since the morning shift takes over prep tomorrow, I hereby officially announce my withdrawal from image management effective immediately."

Sakaguchi: "Is that your latest testimony?"

Saeko: "No. ...That's just a foolish remark spoken to you alone."

[For the first time, she looks up at him with nowhere left to hide.]

Saeko: "I know there is zero irreversible risk. Yet knowing there is no retreat tomorrow morning still frightens me. ...If I ask 'Could we go a little slower?' tomorrow morning, don't press me for a reason right away."

**Day 3 | Success**

Saeko: "I had prepared quite a few lines in advance, yet upon waking, the only words that came out were 'Is it over?' Looking back calmly now, sitting naked two nights ago solemnly announcing my 'withdrawal from image management' and acting spoiled because there was no way out... hardly fits my usual conduct."

Sakaguchi: "That 'patient testimony' was remarkably endearing, though."

Saeko: "Spare me your teasing... Still, whenever I recall becoming one with you that night and the bliss of not even caring about my own undone expression, those ten-plus blank hours don't feel quite so long. Thank you, Takashi."

**Day 3 | Target Not Met**

Saeko: "It seems staring at the curtains two nights ago feeling restless, with a premonition that I would look disheveled on the table tomorrow, wasn't an unfounded intuition after all."

Sakaguchi: "I've brought the operative records. We couldn't complete it as planned this time."

Saeko: "Based on my on-site investigation, there is one lead I must rule out—Lead Surgeon Sakaguchi, did you exert yourself a little too thoroughly making me feel good in the Special Ward on the night before surgery, pouring all your energy into my deepest place and causing a technical deviation at the table the next day?"

[Meeting Sakaguchi's eyes with a faint smile, a blush of recollection warms her cool brow as she gently clasps his hand.]

Saeko: "Just a small jest. Although falling short of the surgical target is regrettable, whenever I savor the feeling of letting myself go completely beneath you two nights ago... I lay on this operating table without a single regret. Come, read me the record."

---

### 2.8 Tae Takemi | *Even the OR Ghost Fears the Needle*

**Day 1 | Consultation**

[Takemi carelessly draws a circle next to the procedure name with her pen, though her fingertips keep tapping the desk.]

Takemi: "I'd love to watch how the lead surgeon handles that tricky step. Too bad the second I go under general anesthesia tomorrow, I won't even get to watch—let alone change my mind halfway, climb off the table, and lecture you on how to cut."

Sakaguchi: "You won't be present as an operator, and once you sign, there's no getting off the table until closure is finished."

Takemi: "I know. ...No punishment could be better suited for a mouthy doctor. Alright, I'm signing."

**Day 1 | Special Ward, Pre-Op Night**

[Lounging lazily against the headboard, Takemi raises an eyebrow as she watches Sakaguchi walk in.]

Takemi: "Today I'm the patient. You didn't come to inspect my incision before making it, did you?"

Sakaguchi: "We haven't operated yet."

Takemi: "Perfect. Then stay the night and keep your girlfriend company. ...And don't you dare log this as pre-op sedation."

[He locks the door and removes his clothes; lazily unbuttoning her hospital gown, Takemi slips off her alluring purple-black lace bra and panties, tosses them onto the chair, and generously displays her mature naked body as she lifts the sheet, urging him closer with her eyes before chuckling.]

Takemi: "Had enough of a look? Get over here. Skip the physical exam tonight and get straight to business."

[They embrace and kiss as the lights dim.]

Takemi: "Mmn... You sure know how to coax a woman, putting your hands in the exact right spots from the start."

Takemi: "Ah... Don't make me moan too sweetly, it's not my style... Nnh, I'm plenty wet down there already, stop stalling..."

Sakaguchi: "Then I won't hold back."

Takemi: "Who asked you to hold back? ...Hurry up and come inside, and kiss me again."

[Sakaguchi sinks his hips and drives all the way to the hilt; Takemi lets out a low, sultry gasp, hooking her long legs around his waist as she tilts her head back amidst the fierce rhythm.]

Takemi: "Aah—! Haah, there's no OR ghost tonight, just me getting thoroughly wrecked by you..."

Takemi: "Nnh, ah... Pleasure like this is quite the luxury... Harder—I won't get a chance to pester you on the table tomorrow... Ah, I'm coming, leave the lights off—aah...!"

[Full fade to black as time skips forward.]

**Day 1 | Aftermath**

[Leaning against the headboard with flushed cheeks, she suddenly laughs as if recalling a brilliant joke, her bare shoulders shaking.]

Takemi: "You know what? That underground doctor who loves staring into wide-open surgical fields just got worked over in bed by you, and tomorrow she gets forcibly powered down under general anesthesia for over ten hours while you guys cut her belly open."

Sakaguchi: "Not being able to watch really bothers you, doesn't it?"

Takemi: "What bothers me more is that once the consent form is signed, there's no calling a halt—you guys will be doing all that work inside my body while I'm asleep, and I have to wait until I wake up just to hear your report. I'm alive, yet I don't even get a chance to nitpick on the spot."

[Reaching out to snag her hospital gown and purple-black panties, she unfolds them halfway before tossing them right back.]

Takemi: "Forget it, I'm leaving the clothes off. The nurses are doing formal prep tomorrow morning anyway, so tonight I might as well lie here naked as an unmoving 'living specimen.'"

Sakaguchi: "That joke is a little ominous."

Takemi: "I know nothing irreversible will happen! ...Knowing it's 100% safe while having zero avenues of retreat—and still getting this jittery—is what makes it so laughable."

[Pulling the sheet up, she casts a cool glance toward the door.]

Takemi: "When they wheel the gurney in tomorrow morning, I doubt I'll even manage a decentwisecrack. The scariest part isn't the scalpel—it's the fact that I'll actually shut my mouth obediently and wait for the needle."

Sakaguchi: "You can tell everyone beforehand that you're scared."

Takemi: "I could. ...For tonight, though, just lend me your shoulder and don't force me to be an expressive model patient."

**Day 3 | Success**

Takemi: "I still want to argue with you over a few of those surgical steps, right after I finish this glass of water. ...Tch, waking up now and remembering how I tossed my panties aside naked two nights ago calling myself a 'living specimen' and asking to borrow your shoulder out of fear... how pathetic. Breathe a word of that outside and you're dead."

Sakaguchi: "All I remember is how enthusiastic that 'living specimen' was in bed."

Takemi: "Getting cheeky with me now? ...Forget it. Whenever I savor getting thoroughly wrecked by you that night and indulging in a whole night of luxury pleasure, those ten-plus hours of 'forced shutdown' were a pretty fair trade. Come on, let's hear your operative report."

**Day 3 | Target Not Met**

Takemi: "Hmph, I knew feeling restless two nights ago—figuring something would go sideways if I was asleep and couldn't nitpick on the spot—was right on the money. You really had to call a halt!"

Sakaguchi: "Calling a halt was the right move by clinical safety standards."

Takemi: "I have no issue with the call itself. Though tell me, my grand lead surgeon—did you get so rough with me in bed on the night before surgery, pouring all your stamina into making me moan sweetly, that your hands went soft once you stepped into the OR the next day?"

[Curling her lips into a half-smile, she lazily reaches out to hook her finger around his necktie and tugs it down slightly.]

Takemi: "Drop the repentant face. Even if falling short leaves me unsatisfied, the sheer pleasure I tasted beneath you on the pre-op night more than paid for my time on that operating table. Once I'm recovered, get ready for a brutal case conference."

---

### 2.9 Miyo Takano (In-Hospital Nurse) | *The Name in the Patient Field Is Mine*

**Day 1 | Consultation**

[Glancing down at her wristband, Nurse Takano suddenly requests one more verification of her name and identity.]

Nurse Takano: "Would you read it out loud one more time? I want to hear you confirm who it is that's signing away her right to get off the table tomorrow."

Sakaguchi: "It's you in person. Not just a name on a chart."

Nurse Takano: "...Thank you. Hearing that actually puts me a little more at ease. I'll sign now."

**Day 1 | Special Ward, Pre-Op Night**

[She gazes at the patient nameplate by the door as if looking at a calling card that shouldn't exist here.]

Nurse Takano: "When you called this name during the day, you were scheduling a patient; call it once more right now—I want to know if it sounds different."

Sakaguchi: "Miyo."

Nurse Takano: "...It does. Stay with me and be my lover tonight. Don't put me back in the patient column until morning."

[Sakaguchi locks the door and removes his clothes. Slowly changing out of her hospital gown, she unfastens her lavender lace bra and panties, places her clothes in the most inconspicuous corner of the room, and sits naked on the edge of the bed, reaching out to take his hand.]

Nurse Takano: "See? Tonight's me won't vanish. ...Come closer and feel me properly."

[They kiss softly as the lights dim.]

Nurse Takano: "Mmn... Call my name again, and let your hands be a little bolder."

Nurse Takano: "Ah... How are you touching me until I'm reduced to an ordinary woman with zero self-control..."

Sakaguchi: "You're my lover."

Nurse Takano: "...What a lovely answer. ...Nnh, I'm already soaked down there... Don't ask me what I observed today, just come straight inside."

[Sakaguchi sinks his hips into her warm, tight depths; Takano lets out a long, lingering sigh, wrapping both arms tightly around his neck.]

Nurse Takano: "Aah—! Haah, so deep... Kiss me again, let me revel in this joy for a while..."

Nurse Takano: "I want to remember every heartbeat as you press inside me... Ah, mmn... Miyo belongs entirely to you right now... I-I'm coming—aah...!"

[Full fade to black as time skips forward.]

**Day 1 | Aftermath**

[Nestled in Sakaguchi's arms with flushed cheeks, she stares at the *"Surgery Tomorrow"* sign at the head of the bed and lets out a sudden laugh.]

Nurse Takano: "I just thought of something terribly funny. Tomorrow, over a dozen people will spend ten-plus hours bustling around a patient named Miyo, cutting her open and sewing her back up for real, while the one person who ought to know what's happening most sleeps right through it under general anesthesia."

Sakaguchi: "You'll know the result when you wake up."

Nurse Takano: "It isn't about the result. Beneath you just now, I could ask for how deep and how long I wanted it; tomorrow the schedule is locked, the nurses will change my gown, put on my cap, and position my body, and I don't even have the right to say 'let's call it off today'—only a few brief minutes before anesthesia to look at you closely."

[Smiling toward the lavender underwear and hospital gown in the corner, she suddenly shrinks back under the covers as if in a sulk.]

Nurse Takano: "Perhaps I'll just stay naked like this tonight. Since I must undergo full prep tomorrow anyway, I might as well leave my clothes off and wait for the morning nurses to deliver me to the operating table. Absurd, isn't it?"

Sakaguchi: "A little."

Nurse Takano: "...I actually considered it seriously for three whole seconds."

[She laughs at herself, before her laughter trails off.]

Nurse Takano: "Tomorrow morning, if I suddenly grab the nurse's hand and say 'I don't want to go in yet'—even though protocol says they must wheel me in—will you explain to them that I'm not usually this difficult?"

Sakaguchi: "Perhaps no explanation is needed. They only need to know you're scared."

Nurse Takano: "...You're right. For tonight, just remember me as I am right now."

**Day 3 | Success**

Nurse Takano: "Someone called my name before anesthesia, and someone called it when I woke up; the ten-plus hours in between felt as though everyone were keeping a slice of my life in safekeeping for me. Waking up now and remembering how I seriously considered staying naked for three seconds waiting for the morning nurses, and was scared enough to cling to someone's hand... is rather embarrassing."

Sakaguchi: "After all, the Miyo of that night had zero self-control."

Nurse Takano: "Hehe, you still remember that line... Still, whenever I recall every heartbeat as you pressed inside me that night and the lingering warmth that filled my body completely, I feel this slice of life kept in safekeeping was wonderfully complete."

**Day 3 | Target Not Met**

Nurse Takano: "It seems staring at the 'Surgery Tomorrow' sign two nights ago feeling uneasy, regretting that I would sleep through everything without knowing, was a faint premonition that this outcome would leave a small regret."

Sakaguchi: "I'm sorry, Miyo. We couldn't complete it as planned this time—I'll give you the detailed report."

Nurse Takano: "I'm in no rush to play the detached observer. I was just wondering... did Dr. Sakaguchi get a little too bold in bed on the night before surgery, focusing so hard on granting every wish of mine for 'how deep and how long' that his spirits flagged at the operating table the next day?"

[Tilting her head with a soft laugh, her fingers caress the back of his hand with unmistakable fondness.]

Nurse Takano: "I'm only teasing. Although thinking about how the goal wasn't reached during those ten-plus hours makes me a little sad, as long as I savor the caresses and climaxes I felt so vividly in your arms on the pre-op night... Miyo doesn't regret lying on this operating table one bit."

---

## 3. Character Roster, Current Authorization & Exclusion List

| Group | Characters | Script Section | In-Game Qualification |
| :--- | :--- | :--- | :--- |
| **Currently Enabled** | Sayaka Nanjo, Serika Misono | §1.1, §1.2 | Displayed only when existing personal Lv5, H qualification, and Sayaka C04 global approval conditions are genuinely met in the save |
| **Future Confirmed Staff Lv5 Routes (13)** | Emiko Mido, Kaori Miyama, Asuka Shiromiya, Artoria Pendragon, Hiroko Sugimura, Satsuki Orikawa, Aqua Mizuki, Mika Nakai, Narumi Jinguji, Ren Nanase, Shiori Fujisaki, Miyuki Asakura, Minato Haruka | §1.3–§1.15 | Scripts complete, but candidate entry must remain hidden until their respective personal authorizations are implemented |
| **Future Conditional Standby Routes (9)** | Moe Honjo, Manami Iimura, Rumi Iwasaki, Shiori Yoneda, Itsumi Sonoda, Megumi Kariya, Saeko Hikami, Tae Takemi, Miyo Takano (In-Hospital Nurse) | §2.1–§2.9 | Preloaded assets only; does not automatically enable Lv5, H, Staff-as-Patient, or hospital recruitment status |

**Explicitly Excluded:** Ange Tonegawa (professional Lv5 route, no H / no Staff-as-Patient), Chizuru Ishigami (management trust route, no Staff-as-Patient), Sakura (Anesthesiology Chief support role, unapproved for adult romance / Staff-as-Patient). Hozumi Saeki is an optional training patient, not hospital Staff; visitors and regular patients without formal 5-level Staff romance routes are likewise excluded. Pay special attention that In-Hospital Nurse Miyo Takano and her future identically named twin sister are **two distinct actors** and must never be conflated by display name.

In this document, **"pre-written for the future" indicates content completion only** and does not constitute a canon decision that all such characters will inevitably become Sakaguchi's lovers. If a character's official Character Bible conflicts with the assumptions herein, discrepancies must be audited and adjudicated by the author before future activation; Codex must never silently alter character settings just to wire up a script.

---

## 4. Advanced Staff Surgery Integration Contract (For Codex)

This contract specifies **expected behavior** without inventing class names, signals, fields, or APIs in the Godot project. Codex must first inspect the current implementation and the latest Advanced Referral / Board rules; if legacy docs conflict with post-2026-10-31 standalone Advanced unlocks, first-clears, or encore rules, prioritize the currently approved version and live codebase, reporting any discrepancies before implementation.

### 4.1 Three-Phase Boundaries, Scheduling Windows & Duration

| Phase | Existing Advanced Surgery Gameplay | Additions in This Spec |
| :--- | :--- | :--- |
| **Day 1 Pre-Op** | Select Staff patient, unlocked procedure, and valid Grand OR team; formal pre-op consultation, signing irrevocable consent, and existing Day 1 time consumption | Common Consultation + Character Consultation; fixed Special Ward VN event that night |
| **Day 2 Surgery** | **Runs the existing Advanced Surgery Runner as-is under mandatory general anesthesia** | Uses the Staff character as Patient context, adapting her patient expressions / intraoperative reactions without rewriting medical logic |
| **Day 3 Post-Op** | Reads outcome, post-op debriefing, existing Day 3 time consumption and settlement | Mutually exclusive `SUCCESS` / `FAILED` personal dialogue (with pre-op H callbacks and teasing); Staff XP (`100%-50%-0%`) and Reputation (`+0/-0`) overrides |

* **Scheduling Time Window (Strictly Aligned with Regular Advanced Surgeries):**
  * **Weekly Limit:** Can be scheduled **no later than Thursday** within a given week (ensuring Day 1 Pre-Op, Day 2 Surgery, and Day 3 Post-Op Debriefing all complete within valid operable days of the week).
  * **Daily Limit:** Must be initiated **no later than 10:00** on the day of scheduling; once past 10:00, Advanced Staff Surgery scheduling is unavailable for that day.
* **Temporal Accuracy:** "Day 1 / 2 / 3" denote the **three existing phases** of an Advanced Episode, not a mandate from this document to redefine the Calendar into three consecutive natural days. When phases fall on adjacent operable days, lines referencing "tomorrow / tomorrow morning / at dawn / in a few hours" are accurate as written. If the existing calendar can insert a Sunday, holiday, or non-operable day between Day 1 and Day 2, **verify current Advanced Episode scheduling first** rather than arbitrarily banning dates or altering global scheduling.
* The March 30–31 non-operable endgame constraint applies per existing rules; never allow creation of an episode that cannot be settled before the calendar ends.

### 4.2 Simultaneous Gate Checks & Cooldown Rules

1. **Global Gate:** Sayaka Nanjo Lv5 Part C *"The Director's Approval"* (`C04`) must have been genuinely played through and persisted. Merely reaching Lv5 does not grant global approval.
2. **Personal Gate:** The actor must genuinely exist in the current Staff registry, be an adult currently available in the hospital, have settled her personal Staff-as-Patient Lv5 authorization, and satisfy existing H / intimacy qualifications without being on the exclusion list.
3. **Procedure Gate:** Only **regular Advanced / Extreme procedures** that the player has **already successfully first-cleared in the formal Runner on a regular Advanced patient**, marked as mastered, and fully configured for Runner execution may be selected. Staff practice cannot reverse-unlock un-cleared procedures.
4. **Procedure Exclusions:** Kaori Miyazono's fixed Quest, the Four Legendary Procedures, special tutorial procedures, the Hiroko / Ren dual-uterus surgery, and any other story-only procedures must never auto-unlock in the regular Staff practice menu unless individually approved by the author in the future.
5. **Scheduling & Slot Occupancy Check:**
   * Must satisfy the **no later than Thursday, no later than 10:00** scheduling window, with no other active Advanced Surgery episode in progress.
   * The same Staff member cannot simultaneously occupy the Patient slot and any team role (Assistant Surgeon, Scrub Nurse, Circulating Nurse, Anesthesiologist, etc.), nor take on other clinical tasks during hospitalization, surgery, and recovery.
6. **Cooldown Rules (Zero Patient Cooldown vs. 14-Day Assistant Intervention Cooldown):**
   * **A Staff member acting as the Patient has NO patient cooldown** (once Day 3 post-op settlement completes, she is immediately free to return to duty or be selected as a patient again).
   * **A doctor participating as an Assistant Surgeon who uses an active Intervention during the surgery triggers the standard 14-day cooldown rule.** This rule applies identically across **formal Advanced Surgeries, weekly Encore Advanced Surgeries, and Staff-as-Patient Advanced Practice Surgeries**.
7. **Exclusion Priority:** Characters who are non-romanceable / non-Staff-as-Patient, have left the hospital, have not yet joined, or have not completed their personal route must never appear as candidates even if their script text is preloaded.

**Current UI Acceptance Anchor:** At present, only Serika and Sayaka (in saves where both global and personal Gates are met) should appear as selectable; the remaining 22 characters exist strictly as preloaded script resources.

### 4.3 Preventing Pollution of the Advanced Board, Weekly Encores & Top-Tier Procedures

| Aspect | Regular Advanced Referral / Encore | Staff Advanced Practice |
| :--- | :--- | :--- |
| **Patient Source** | Normal referral / encore patient pool | User-specified qualified named Staff member |
| **Scheduling Window** | Latest Thursday, latest 10:00 | **Identical: Latest Thursday, latest 10:00** |
| **Procedures** | Current new case or valid encore | Only already first-cleared regular Advanced / Extreme Procedures |
| **Day 2 Execution** | Advanced Runner | **The exact same Advanced Runner**, with Patient context swapped to Staff |
| **Global Success/Failure State** | Advances first-clear, queue, and encore logic | **Must NOT alter mastered first-clear status**, set `FAILED_LOCKED`, or grant new first-clears |
| **Monday Encore & New Case Slots** | Governed by regular Advanced rules | Does not refresh, consume, or count toward regular Advanced patient queues |
| **Staff Patient's Own Role XP** | N/A | Receives zero role training XP for being on the sheet; she is the Patient on the table |
| **Professional Reputation** | Regular Advanced resolver | **`SUCCESS +0`, `FAILED -0`; strictly invariant** |
| **Surgery / Leadership / Team Training XP** | Regular Advanced Runner XP formula | Reuses regular formula, multiplied by **`100% -> 50% -> 0%` decay based on prior successes for the same `Staff × Procedure` pair** |
| **Cooldown Rules** | Assistant Intervention triggers 14-day cooldown | **Zero cooldown for the Staff Patient; Assistant Surgeons using Intervention trigger the exact same 14-day cooldown** |

### 4.4 Exact Event Wiring for Day 1 VN

**Recommended Event Segment Sequence (Semantic order, not Godot key names):**

1. `CONSULT_COMMON`: Plays §0 Common Consultation, populating the localized display name, actual risks, general anesthesia prep, and "locked upon signing" rule for the selected Procedure.
2. `CONSULT_CHARACTER`: Plays the selected Staff member's **[Day 1 | Consultation]**.
3. `PREP_LIST_OPTIONAL`: If Procedure data explicitly includes complex pre-op prep, displays the actual prep list and a few brief lines of reaction without inventing steps unmatched to the procedure.
4. `NIGHT_RESERVATION`: Resolves any existing Free H booking conflict for that night and obtains player confirmation for the Special Night (see §4.5).
5. `NIGHT_INTRO`: Special Ward; the character invites Sakaguchi, both consent, and the scene stages locking the door, undressing, and getting into bed per her script.
6. `NIGHT_INTIMATE_VOICES`: **After dimming the lights, sequentially displays all of the character's intimate dialogue lines.** Camera may focus on the edge of the bed, nightlight, curtains, or discarded clothing; never jump the clock before her lines finish playing.
7. `NIGHT_FADE`: Full fade to black and time passage, making it unmistakable that substantive intimacy occurred that night; no H Runner, no second fee, and no stat farming.
8. `NIGHT_AFTER`: Plays the character's **[Day 1 | Aftermath]**, transitioning from post-coital bliss to sudden panic, cold feet, or absurd tantrums upon realizing tomorrow's major surgery cannot be canceled. Lights out in the ward without consuming an extra calendar day.
9. `DAY2_RUNNER`: Runs the existing Advanced Runner under mandatory general anesthesia. Tracks whether any participating Assistant Surgeon used an active Intervention (applying the 14-day assistant cooldown if used).
10. `DAY3_RESULT`: Plays the character's mutually exclusive **[Day 3 | Success]** or **[Day 3 | Target Not Met]** branch (including callbacks to her pre-op panic, savoring the pre-op night's H, and playful teasing on failure).
11. `SETTLE_ONCE`: Reuses atomic settlement, overrides Staff XP (`100% -> 50% -> 0%`) and Reputation (`+0/-0`), increments success count on `SUCCESS`, and closes the episode.

### 4.5 Relationship with Existing Free H Bookings & Skip Button

* Tonight is a **fixed VN special event** locked to the Special Ward; it does not pop up a Free H location picker or launch the H Runner. Existing Free H Scheduling principles ("at most one private booking per day" and "confirming a new booking overwrites the old one without penalty") remain in force.
* If Day 1 already has a private night booking with someone else, **warn the player of the conflict before final Day 1 surgery confirmation**, allowing them to either cancel the Staff Advanced Surgery application or confirm overwriting tonight's prior booking with this Special Night. An existing Free H booking with the **same character** is likewise merged and replaced so two night scenes never play back-to-back.
* Provide two options: **"Watch Full Pre-Op Special Night"** / **"Skip Pre-Op Special Night"**. Skipping bypasses only `NIGHT_INTRO`, `NIGHT_INTIMATE_VOICES`, `NIGHT_FADE`, and `NIGHT_AFTER`, while **still atomically marking tonight's scheduled intimate event as completed**, consuming no extra time, preserving Day 2 / Day 3, and granting no duplicate regular H stat gains.
* Per existing fixed VN rules, default Charm / Reputation bonus is `+0`; the pre-op night is not a secondary stat farm.

### 4.6 First-Time / Repeat Play & XP Decay Settlement (`100% -> 50% -> 0%`)

**Core Rule:** The same Staff member may repeatedly undergo different or identical unlocked regular Advanced surgeries (zero patient cooldown); however, XP rewards strictly follow a **three-tier decay based on prior successful completions of the exact same `Staff × Procedure` combination**:

* **1st Success (`prior_success_count == 0`): `100%` XP (`×1.0`)**
* **2nd Success (`prior_success_count == 1`): `50%` XP (`×0.5`)**
* **3rd & Subsequent Successes (`prior_success_count >= 2`): `0%` XP (`×0.0`)**

Additional Notes:
* If the same Staff member switches to **another first-cleared Advanced Procedure she has not yet successfully undergone**, that new combination starts fresh at `100%` for its 1st success, `50%` for its 2nd, and `0%` from the 3rd onward.
* Each character's full-length "First Advanced Staff Special Night" script (`actor_has_seen_first_advanced_staff_night`) plays **only once per playthrough per character**; switching to a new Procedure must not replay her first-time surgical panic as if it were her maiden operation.
* Failures follow existing Advanced failure XP rules; a failed run does not increment `prior_success_count` for that pair and never distributes success XP.
* Professional Reputation is **strictly `+0 / -0` across all outcomes** (success, failure, rescue, abort).
* Day 3 settlement must be strictly idempotent; reopening the screen, reviewing dialogue logs, or reloading a save must never grant duplicate XP or increment counters twice.

**Short Night Version for Repeat Advanced Staff Surgeries (Shared across all characters on their 2nd+ Advanced Staff operation):**

[Special Ward. She sets the surgical plan down on the table.]

Staff Member: "I used to think that once I'd been through a major operation like this once, I wouldn't be scared a second time."

Sakaguchi: "And the verdict?"

Staff Member: "The verdict is that seeing a signed wristband that can't be canceled only makes me know even more clearly what I'm afraid of. ...Will you stay with me tonight too?"

[Both explicitly consent. Door locked, private undressing, embrace and kiss as lights dim; brief non-explicit affectionate lines confirm the night together before a full fade to black.]

Staff Member: "...That felt wonderful. Now I finally have a little courage to face tomorrow again."

* **Day 3 Repeat Success Line:** "This time I felt much more composed than the first time—and I still remember the warmth of being in your arms two nights ago crystal clear. Thank you, everyone."
* **Day 3 Repeat Target Not Met Line:** "Even though it wasn't my first time, falling short is still a little frustrating... Forget it, considering how wonderfully you coaxed me in bed on the pre-op night, hand over the chart first."

### 4.7 Episode State, Save/Load & Asset Fallback

1. **Before Confirmation:** Verify that the current day is **Monday through Thursday and the time is no later than 10:00**; previewing the patient, regular Advanced procedure, team, and Calendar and then backing out consumes no time, alters no bookings, and sets no "first night seen" flags.
2. **At Confirmation (Locked Upon Signing):** Persist the unique episode ID, actor ID, Procedure ID, valid Grand OR full team, three-phase schedule, and player choice regarding any prior booking conflict, then launch Day 1. **Once confirmed, there is no player-accessible cancel button in either the UI or game logic.** Staff member occupancy spans hospitalization, surgery, and post-op recovery; never release her back to OR duty slots at the start of Day 3 dialogue before settlement completes.
3. **Night State:** `PENDING -> PLAYING -> COMPLETED` (semantic). Whether watched in full or skipped, it completes once; reloading a save returns to the exact node without losing the night scene or double-claiming rewards.
4. **Day 2:** Enters the existing Runner with the locked patient and team; HP, Precision, crisis rescue, and failure evaluation follow existing persistence and idempotency safeguards. The Staff patient is barred from occupying any role on her own surgical team. **If a participating Assistant Surgeon triggers an active Intervention during the Runner, apply the standard 14-day cooldown to that assistant; apply zero patient cooldown to the Staff patient.**
5. **End of Day 2:** Persists outcome awaiting Day 3. Failure must never re-lock an already mastered regular Procedure, nor affect regular Advanced first-clear counts, weekly encore pools, or standalone Quests.
6. **Day 3:** Plays the corresponding outcome script first, then in a single atomic settlement step applies the `100% -> 50% -> 0%` XP multiplier, updates the `Staff × Procedure` success counter and first-night flag, and releases the active episode and staff occupancy.
7. **Asset Fallback:** Every character has a complete playable script. When dedicated CGs, backgrounds, or voice clips are absent, run using the standard ward background, existing character expressions, fade-to-blacks, and narration.

### 4.8 Optional Staging for Complex Pre-Op Prep

Only when the selected Procedure's actual configuration requires complex preparation may Day 1 insert a brief "this prep sheet is way too long" VN beat:

[The nurse hands the checklist generated from actual Procedure data to the patient. The camera displays only items genuinely present in the data.]

Staff Member: "I used to watch patients sign sheets like this every day and thought nothing of it. Why does it look so long when I'm holding it in my own hands with no way to back out?"

Sakaguchi: "If there's anything you want clarified first, ask today."

Staff Member: "I will. ...Though can I put it out of sight for tonight? I've already developed a personal grudge against this piece of paper."

Characters may show **in-character embarrassment, bravado, panic, or absurd complaints** toward real configured steps (skin prep, catheterization, bowel prep, positioning, anesthesia verification), but unconfigured steps must never be injected; actual execution remains on Day 2. General anesthesia, compliant prep, surgical caps, and sterile draping remain mandatory on Day 2 regardless of any pillow talk on Day 1 night.

### 4.9 Continuity Protection Checklist

* **Serika:** Zero references to bass guitars, gig bags, performances, or instrument shopping anywhere in this script. At this point in the timeline she **has not purchased a bass**, nor would she bring one to a hospital ward.
* **Sayaka:** Personal Lv5 `C04` is the global Staff-as-Patient approval key; her fixed Lv5 event is never re-settled by Advanced practice, and the Advanced Special Night is never force-triggered at the end of Lv5.
* **Hiroko / Ren:** The fixed Lv5 dual-uterus surgery is a standalone special event, not a generic Advanced Staff surgery; Ren's personal Staff practice entry opens only after her fixed Lv5 event settles.
* **Mido / Artoria:** Grants no new Department Chief votes, no alternative gates for `Surgery >= 90` / `Leadership >= 90`, and no direct election or ending flags.
* **Aqua / Takemi:** Tutorial, Master, and Legendary procedures do not auto-convert into free Staff Advanced practice from this system.
* **Mika Nakai / Saeko Hikami / Takano:** Never reveals Mika's past, Saeko's client, or the Takano twin secret; Nurse Takano and the future patient Takano must be strictly isolated by distinct actor IDs.
* **Rumi / Shiori Yoneda / Itsumi:** Future adult romance and Staff routes remain subject to final lock; these standby scripts do not invalidate their existing interpersonal bonds.
* **Kariya:** Training stipends, statutory leave, and intimate invitations are strictly independent and never exchanged as conditions of performance.
* **Ange / Ishigami / Sakura:** Continue participating in hospital and team duties per existing rules without Staff-as-Patient scripts.

### 4.10 Minimum QA Acceptance Matrix

| ID | Test Action | Expected Result |
| :---: | :--- | :--- |
| **01** | Load save where only Serika & Sayaka have Staff unlocked | Advanced Staff menu displays only those two; remaining 22 exist as preloaded text only |
| **02** | Sayaka `C04` not yet completed | Global Staff practice entry remains closed even if personal relationship level is met |
| **03** | Attempt scheduling on Fri/Sat/Sun, or after 10:00 on Mon–Thu | **Scheduling rejected**; strictly enforces latest Thursday, latest 10:00 window |
| **04** | Preview on Day 1 then back out before signing | Consumes zero time, occupies zero team members, preserves original Free H booking |
| **05** | Free H booked with another character for tonight | Prompts to overwrite or cancel; never plays two night events |
| **06** | Free H booked with the same character for tonight | Merges and replaces with the Special Night; triggers once only |
| **07** | Watch Sayaka & Serika first night and Day 3 in full | Door lock, undressing, active invitation, ≥5 dimmed-light intimate lines, post-coital no-cancel tension, and Day 3 H callback / teasing branches play in exact order |
| **08** | Static inspection of the remaining 22 standby scripts | Each contains Consultation, Night/Aftermath, Day 3 Success & Target Not Met (with H callbacks and teasing), without leaking protected character secrets |
| **09** | Click "Skip Pre-Op Special Night" | Skips only night intimacy & aftermath text; advances normally to Day 2 & Day 3 with zero bonus stats |
| **10** | Attempt invalid / Legendary / Quest / un-cleared regular Advanced procedure | Selection rejected; does not alter first-clear flags or Monday encore queues |
| **11** | Assign Staff patient to a Grand OR team slot on her own surgery | Team builder rejects conflict; she cannot be both Patient and Assistant/Nurse |
| **12** | Run formal Advanced Runner under general anesthesia | Patient reacts only pre-induction and post-awakening; zero conscious dialogue during general anesthesia |
| **13** | Day 2 `SUCCESS` | Day 3 plays Success branch only, settles once atomically, Reputation strictly `+0` |
| **14** | Day 2 `FAILED` or rescue failure | Day 3 plays Target Not Met branch (teasing Sakaguchi while affirming the pre-op night made it worthwhile), Reputation strictly `-0`; mastered procedures remain unlocked |
| **15** | 1st success on a given `Staff × Procedure` pair | Multiplies valid base training XP by **`1.0` (100%)** |
| **16** | 2nd success on the same `Staff × Procedure` pair | Multiplies valid base training XP by **`0.5` (50%)** |
| **17** | 3rd+ success on the same `Staff × Procedure` pair | Multiplies valid base training XP by **`0.0` (0%)**; switching the same Staff to a newly paired first-cleared Procedure starts at `1.0` |
| **18** | Cooldown check: Staff Patient vs. Assistant Intervention | **Staff Patient has 0 cooldown post-settlement**; any Assistant Surgeon who used an active Intervention triggers the **14-day cooldown** (matching formal/encore Advanced rules) |
| **19** | 2nd / 3rd Advanced surgery on the same character | Plays the shared Short Night Version instead of replaying her first-time long night; does not affect `100%` XP on a new Procedure pair |
| **20** | Reopen Day 3, reload save, or review logs | Zero duplicate XP, cooldowns, first-night flags, or settlements |
| **21** | Approaching March 30–31 endgame | Blocks creation of any 3-phase surgery that cannot settle on an operable day |
| **22** | Nurse Takano and Patient Takano coexist | Patient events, Staff Gates, and sprites remain strictly isolated by actor ID |
| **23** | Regular weekly 2-slot Advanced Encore active | Staff practice does not masquerade as a new regular patient, alter encore frequency, or grant new first-clears |

---

## 5. Real Engineering Facts Codex Must Verify Before Delivery

1. The persistence key for Sayaka `C04`, the exact `actor_id` strings for the two currently enabled Staff members, and the authorization source for each future character (never treat display names in this doc as raw field names).
2. Post-2026-10-31 Advanced Referral / standalone first-clear / encore rules and the live Procedure registry; enumerate which regular Advanced procedures are genuinely **first-cleared and runner-ready**.
3. Reuse the exact "latest Thursday, latest 10:00" validation function used by regular Advanced Surgeries at the Staff Advanced Practice entry point.
4. Verify that the 14-day cooldown write logic for Assistant Surgeons using active Intervention applies consistently across formal Advanced, Encore, and Staff Practice runs, while ensuring the Patient slot never writes a cooldown to the Staff patient.
5. Verify that `actor_procedure_success_count` cleanly supports the three-tier multiplier (`0 -> 100%`, `1 -> 50%`, `>= 2 -> 0%`).
6. Verify the real interface for Free H booking conflict resolution and end-of-shift fulfillment, ensuring Skip, completion flags, and save/load restoration wire cleanly into existing nightly scheduling.
7. Verify Day 2 outcome persistence, Day 3 idempotent settlement, and the Reputation `+0/-0` override bypass. Test-run at least one full cycle each for Sayaka and Serika covering Success, Failure, Skip, Repeat (`100% -> 50% -> 0%` decay), Assistant Intervention cooldown, booking conflict, and save/load re-entry.