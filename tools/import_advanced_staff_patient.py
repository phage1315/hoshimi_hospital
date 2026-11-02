from pathlib import Path
import re,json
root=Path(__file__).resolve().parents[1]; src=(root/'docs/source/advanced_staff_patient_v1/author_v1_1.md').read_text()
def lines(section):
 out=[]
 for n,line in enumerate(section.splitlines()):
  m=re.search(r'(坂口|医护|小夜香|芹香)：[「](.*)[」]',line)
  if m: out.append({'speaker':'player' if m[1]=='坂口' else 'patient','text':m[2]})
 return out
def trans(rows, text):
 en=text.strip().splitlines(); assert len(rows)==len(en),(len(rows),len(en))
 for r,e in zip(rows,en): r['text_en']=e
 return rows
common=trans(lines(src.split('### 2.2 ')[1].split('### 2.3 ')[0]),'''First, let's be clear. We're arranging a real advanced operation today, not a demonstration model. You understand that?
I do.
The procedure is 〈本次术式〉. First we'll discuss its intended purpose, the key steps, anesthesia, and the hardest part. Then we'll talk about what you will experience as the patient.
Knowing there will be no irreversible consequences doesn't mean you won't be afraid. If you change your mind now, we won't schedule it.
...I know. Let me look at the team again.
Before we confirm the team, let me ask once more: is this your own decision?
Yes. Please take care of me tomorrow using the proper patient procedures.''')
end={'speaker':'player','text':'我会把今天的复盘和恢复建议交给你。等完全恢复，再回到原来的岗位。','text_en':"I'll give you today's review and recovery advice. Return to your usual duties once you've fully recovered."}
en_sayaka=[
'''When I was a school nurse, my favorite line was, 'It's fine. It won't hurt.'
Now you know you shouldn't promise that so casually.
That's why I really want someone to say it to me now. Even if I know they're just reassuring me.
Choose the team you think is safest. Tomorrow, this teacher will be a good patient too.''',
'''Dr. Sakaguchi, come give tomorrow's patient a few last words.
Last words?
I'm having 〈本次术式〉 tomorrow! Such a huge operation—can't you spend one good night with me before that?
An operation isn't an execution. Don't scare yourself like that.
I know. That's why I'm asking my boyfriend out, not begging a doctor to save me. Leave the stethoscope behind tonight, okay?
Hey, Doctor. Kiss me first today, okay?
You're still calling me Doctor?
Ah...habit. Then, Ryuji, kiss me again.
Is this okay?
Mm...yes. Your patient doesn't want medical instructions tonight.
What does she want to hear, then?
That you love me. ...Hold me a little tighter. Don't let me think about tomorrow morning.
...Ah, I wish I could just stay here with you. Let me be a little selfish tonight, okay?''',
'''...Wait. What time is it? No, don't tell me!
What's wrong?
A moment ago life felt wonderful. Now I remember that preparation checklist for tomorrow...aren't they coming for me at eight?!
You even wrote yourself a note not to be late.
That was the brave me from a few hours ago! I'm very annoyed with her now!
Forget it! Tomorrow there's a whole list of preparations, then I have to get naked on that operating table anyway. I'll just stay like this and wait for them!
The nurses will still put you in a patient gown tomorrow, as required.
I know! I don't mean it literally! ...But at dawn they'll wheel me in, and I'll be asleep under general anesthesia for more than ten hours!
I was so pleased with myself, being in love here. Suddenly it's time for such a huge operation. Ugh, I don't even know exactly what I'm afraid of.
I'll stay with you a while.
...Mm. And put that patient gown farther away. Seeing it makes me want to cry.''',
'''Do you know the most embarrassing part? Before the anesthesia even started, I was so nervous I forgot the deep-breathing method I taught my students.
But you made it through. The hardest steps are finished too.
Next time, can I add a line to the back of the preoperative instructions: 'Staff patients must not scare themselves'?
...Pretend you didn't hear that 'last words' remark last night.''',
'''Yesterday I wondered whether the operation would scare me senseless. I never imagined my head would be this clear now.
We didn't achieve the surgical goal. I'll explain exactly what went wrong.
Go ahead. I work in a hospital; I can understand the difficult parts too. ...But before you start, can I hold your hand for a while?
Tonight I don't want to be the teacher who's always comforting everyone else.''']
en_serika=[
'''I've read this scan. I understand every slice. But when I think about being wheeled in tomorrow, I realize imaging reports never have a field for 'how frightened the patient is.'
I can listen while you continue, or we can pause for a moment.
Let me finish first. It looked as though I was studying the images, but I was counting the hours until tomorrow morning...the more I counted, the more I wanted to run.
I agree. Let me be an ordinary patient tomorrow.''',
'''Ryuji, I'm really afraid of waking up tomorrow to find everyone in the operating room waiting for me.
We can postpone it.
No. I made this choice seriously. ...So tonight, could you stop speaking to me in your 'doctor addressing a patient' voice?
How would you like me to speak?
Like that day in Ochanomizu, when you listened as I got stuck halfway through playing. Sit here. Stay with me through this passage.
Stop counting the beats...there's no one we need to keep up with now.
All right. May I kiss you, then?
Mm...again.
Is this all right? Are you nervous?
I am. But this isn't the moment to be afraid of you.
I'm right here.
Then hold me. ...Don't let this little passage end yet.
Mm...I want another kiss. Don't rush to finish just yet.''',
'''...Ryuji, how long will tomorrow really be?
The procedure is expected to last more than ten hours. After anesthesia, you won't feel that time passing.
That sounds even scarier. More than ten hours under general anesthesia...like pressing pause and jumping straight from morning to evening.
The team will look after you throughout. Once you're asleep, you won't feel that time passing.
Rationally, that sounds like a very good deal. So why does it feel as though someone is secretly fast-forwarding part of my life?
...Will I be so nervous tomorrow that I press this? And the person who comes in will be the nurse taking me to surgery.
You can ask them to wait and explain things.
Then I need to practice saying, 'Please wait.' I'm afraid I won't even be able to say that.
I'll leave my clothes off for now. I was so happy a moment ago, and suddenly I have to get ready for major surgery. Let me catch my breath.
All right. I'm right here.
When I wake up, tell me yourself: 'It's over.' Don't just show me a long review form.''',
'''I always thought it was the operation I feared. Once I lay down, I realized I was more afraid of trying to take control of everything again.
You did what you needed to do: tell the team how you felt.
This time I didn't take over, and I didn't run away. ...Once I recover, I want to play that piece I got stuck on again.''',
'''I understand the reasons you're explaining. What really hurts is that I was unconscious for all those hours, only to wake up and learn things hadn't ended as expected.
You aren't responsible for what the team couldn't complete.
I know. The old me would probably have said, 'Let me do it next time.' Today I only want to say: please tell me honestly about every step.
And...don't end with 'It's all behind us.' It isn't yet.''']
data={'version':1,'common':common,'ending':end,'actors':{}}
for actor,number,ens,title_en in [('doc_sayaka','3.1',en_sayaka,'No One Can Cover the Infirmary This Time'),('doc_serika','3.2',en_serika,'A Rest Lasting More Than Ten Hours')]:
 section=src.split('### '+number+' ')[1].split('\n### ')[0]
 title=re.search('《(.*?)》',section)[1]
 chunks=re.split(r'\*\*Day [13] [^\n]+\*\*',section)[1:]
 assert len(chunks)==5
 phases={}
 for key,chunk,en in zip(['consult','night','after','success','failure'],chunks,ens):
  phases[key]=trans(lines(chunk),en)
  # Preserve staging separately from spoken lines for faithful audit/production.
  phases[key+'_staging']=re.findall(r'【(.*?)】',chunk)
 phases['dark']=phases['night'][5:];phases['night']=phases['night'][:5]
 phases['title']=title;phases['title_en']=title_en
 data['actors'][actor]=phases
repeat=src.split('### 5.6 ')[1].split('### 5.7 ')[0]
r=lines(repeat)
trans(r,'''This isn't your first advanced operation with me as your surgeon. Has your last experience affected today's decision?
Of course. That's why I want to explain what felt uncomfortable beforehand this time.
We'll still go over the procedure, team, and possible situations all over again.
I know. This is a new operation, not a replay of the last one.
Another major operation...Having been through it once, I understand even better how hard tomorrow will be.
How would you like to spend tonight?
Stay with me. Not to cancel out the risk. I just want to be with you before it happens.
...All right. Now I can get serious about being afraid of tomorrow.
This time I understood better what I needed, and why I was afraid. Thank you for listening to me again.
Having been through it before doesn't mean I won't be disappointed. Tell me the result; we can decide next time whether to try again.''')
data['repeat']={'consult':r[:4],'night':r[4:7],'after':r[7:8],'success':r[8:9],'failure':r[9:]}

# Authored stage directions are VN narration, in their original position.
staging_en = {
'doc_sayaka': [
"Sayaka flips to the last page of the surgical plan, trying to look casual, but keeps rubbing its corner with her finger.",
"She looks up with a brief smile, then nods seriously.",
"Special ward. Sayaka rolls the thick preoperative instructions beside the bed into a tube and pretends it is a microphone.",
"Sakaguchi puts away the chart, locks the door from inside, and takes off his white coat and outer clothes. Sayaka folds her patient gown at the edge of the bed, deliberately posing like a properly settled patient, but cannot help laughing. She pulls the reading lamp's cord; the light dims as their affectionate conversation continues.",
"In the dim light, she looks up from under the sheet, her teasing voice suddenly turning soft and affectionate.",
"The light comes on. Nestled comfortably beneath the sheet, Sayaka suddenly notices the preparation checklist beside the bed. Her smile freezes.",
"She lunges toward the chair for her patient gown, then crossly throws it back down.",
"She lifts a pillow to hide her face, her voice growing quieter.",
"She adds in a small voice.",
"Her smile slowly fades."],
'doc_serika': [
"Serika draws a short rhythm line in the notes she brought from imaging, then quickly covers it with her palm.",
"She pushes the report toward him.",
"Special ward. Her bass case rests beside the bed. She taps a rhythm softly with her knuckles without actually playing.",
"Sakaguchi closes the door and drapes his outer clothes over the chair. Serika leaves her patient gown at the foot of the bed and makes room beside her; the softly tapped rhythm finally stops. The camera rests on the night outside the window, and the light dims as their affectionate conversation continues.",
"In the dim light, she feels for Sakaguchi's hand and gives a quiet laugh.",
"Serika gazes at the ceiling from beneath the sheet, the smile still on her lips slowly fading.",
"She sits up clutching the sheet. After a rustle of fabric, she ends up holding only the nurse call button.",
"She looks at the clothes on the chair but does not reach for them.",
"Serika presses down on the edge of the blanket beside her."]}
for actor,number in [('doc_sayaka','3.1'),('doc_serika','3.2')]:
 section=src.split('### '+number+' ')[1].split('\n### ')[0]
 chunks=re.split(r'\*\*Day [13] [^\n]+\*\*',section)[1:]
 translations=iter(staging_en[actor]); phases=data['actors'][actor]
 for key,chunk in zip(['consult','night','after','success','failure'],chunks):
  spoken=iter(phases[key]+phases['dark'] if key=='night' else phases[key])
  rows=[]; spoken_count=0; dark=[]
  for raw in chunk.splitlines():
   stage=re.search(r'【(.*?)】',raw)
   # The dark-scene direction belongs with the eight dark-scene exchanges.
   dest=dark if key=='night' and spoken_count>=5 and (stage is None or stage[1].startswith('暗场')) else rows
   if stage: dest.append({'speaker':'narrator','text':stage[1],'text_en':next(translations)})
   if re.search(r'(坂口|医护|小夜香|芹香)：[「](.*)[」]',raw):
    dest.append(next(spoken)); spoken_count+=1
  phases[key]=rows
  if key=='night': phases['dark']=dark
repeat_narration=[
 {'speaker':'narrator','text':'特别病房。医护合上刚核对完的术前准备表。','text_en':'Special ward. She closes the preoperative preparation checklist she has just reviewed.'},
 {'speaker':'narrator','text':'她主动握手。灯灭、黑屏、时间推移。','text_en':'She reaches for his hand. The light goes out, the screen fades to black, and time passes.'}]
assert all(row['text'] in repeat for row in repeat_narration)
data['repeat']['night']=[repeat_narration[0]]+data['repeat']['night']+[repeat_narration[1]]

(root/'data/advanced_surgery/staff_patient/stories.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
# The whole manuscript is retained; future dialogue remains inactive pending real qualifications.
reserve=[]
for m in re.finditer(r'^### ([34]\.\d+) (.*?)(?=^### |^## |\Z)',src,re.M|re.S):
 if m[1] in ['3.1','3.2']:continue
 reserve.append({'section':m[1],'status':'inactive_author_source','source_text':m[2]})
(root/'docs/source/advanced_staff_patient_v1/inactive_sections.json').write_text(json.dumps(reserve,ensure_ascii=False,indent=2)+'\n')
print('Active bilingual lines:',sum(len(v) for a in data['actors'].values() for k,v in a.items() if isinstance(v,list) and not k.endswith('staging'))+len(common)+len(r)+1,'inactive sections:',len(reserve))
