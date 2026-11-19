#!/usr/bin/env python3
"""Verbatim V1.2 importer. User's 2026-11-18 art/specialty overrides are separate."""
import copy, hashlib, json, re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'data/advanced_surgery'
SOURCE = ROOT / 'research/source_scripts/HOSHIMI_MIDO_LEGENDARY_MURAKAMI_AI_V1_2.md'
ID = 'surgery_master_aortic_root_ascending_replacement'

def read(p): return json.loads(p.read_text())
def write(p, v):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(v, ensure_ascii=False, indent=2)+'\n')
def section(raw, start, end): return raw.split(start,1)[1].split(end,1)[0]
def table(block): return [[x.strip() for x in line.strip().strip('|').split('|')] for line in block.splitlines() if line.startswith('| MR')]
def pair(cell):
    cn,en=cell.split(' / ',1)
    return cn,en

def build():
    raw=SOURCE.read_text()
    titles={r[0]:(r[1],r[2]) for r in table(section(raw,'**17 个阶段 UI 标题**','**演出时序定案**'))}
    durations={r[0]:int(r[3]) for r in table(section(raw,'| ID | kind 候选','**基线总时长'))}
    numeric=table(section(raw,'| Stage | kind | hp_base','约束：'))
    # Authored HP/P/time unchanged; initial engineering physiology deltas, separately auditable.
    effects=[(0,0,0,0),(-2,-5,2,3),(0,6,1,2),(-3,0,0,1),(-2,0,0,0),(0,4,1,2),(-2,-3,2,4),(-1,3,0,1),(-2,-2,1,3),(-3,-3,1,3),(0,2,0,0),(-3,-4,2,4),(-3,-3,2,4),(-2,-2,1,3),(-4,2,-2,1),(-3,0,-1,0),(2,4,-3,1)]
    proc=dict(id=ID,name='保留主动脉瓣的主动脉根部再植入（David 术式）＋升主动脉人工血管置换',name_en='Valve-Sparing Aortic Root Reimplantation (David Procedure) and Ascending Aortic Graft Replacement',duration_minutes=645,base_difficulty=99,training_ceiling=100,reward_tier='advanced',status='implemented',physiology_tuning_status='INITIAL_FULL_PHYSIOLOGY_REGRESSION_768_RUNS',patient_notice='体育教师村上愛没有明显心脏症状，但影像显示主动脉根部扩张至约 5.3 厘米，升主动脉亦扩张。评估后计划实施保瓣根部重建及升主动脉置换。',patient_notice_en='PE teacher Ai Murakami has no obvious cardiac symptoms, yet imaging shows a dilated aortic root measuring about 5.3 cm, along with ascending aortic enlargement. The team plans valve-sparing root reconstruction and ascending aortic replacement after evaluation.',steps=[],crisis_checkpoints=[5,13,16],crisis_chances=[.12,.12,.12],failure_condition={'metric':'stability','operator':'<=','value':0},success_condition={'metric':'progress','operator':'>=','value':100},dialogue_after_rescue=True)
    for i,r in enumerate(numeric):
        sid,kind,hp,diff,extra,tag,stress,_=r
        e=dict(zip(['stability','visibility','bleeding','blood_loss'],effects[i]));e['elapsed_time']=durations[sid]
        proc['steps'].append(dict(id=sid,name=titles[sid][0],name_en=titles[sid][1],kind=kind,hp_base=int(hp),difficulty=int(diff) if diff!='—' else 0,hp_failed_extra=int(extra) if extra!='—' else 0,specialty_tag=tag,physio_stress=stress,strategic_effects=e))
    for r in table(section(raw,'| Stage／Option ID','**医疗语义锁定**')):
        oid,cn,en,desc,t,hp,st,vi,bl,loss=r
        zhdesc,endesc=desc.split(' / ',1)
        step=next(s for s in proc['steps'] if s['id']==oid[:4])
        step.setdefault('options',[]).append(dict(id=oid,label=cn,label_en=en,description=zhdesc,description_en=endesc,hp_cost=int(hp),strategic_effects=dict(elapsed_time=int(t),stability=int(st),visibility=int(vi),bleeding=int(bl),blood_loss=int(loss))))
    assert len(proc['steps'])==17 and sum(s['hp_base'] for s in proc['steps'])==54 and sum(durations.values())==645
    stories={}
    for phase,start,end,title,en,bg,portrait in [
        ('day1','## 2. Day 1','## 2.5','没有症状的风险','A Risk Without Symptoms','clinic','ward'),
        ('day2','## 2.5','## 3. Day 2','手术室门口','At the Operating Room Door','operating_room','transfer'),
        ('day3','## 6. Day 3','### Day 3 失败','比教练更严格','Stricter Than a Coach','ward','postop')]:
        block=section(raw,start,end)
        rows=[dict(speaker={'村上愛':'patient','坂口':'PLAYER','御堂':'doc_emiko'}[who],text=cn,text_en=enline) for who,cn,enline in re.findall(r'\*\*(村上愛|坂口|御堂)\*\*：(.*?)\s*\nEN: (.*)',block)]
        stories[phase]=dict(title=title,title_en=en,background=bg,portrait=portrait,lines=rows)
    for i in [5,7,9,12,14,21]: stories['day1']['lines'][i]['portrait']='ward/serious'
    for i in [16,18]: stories['day1']['lines'][i]['portrait']='ward/nervous'
    for i in [2,9,11,13]: stories['day3']['lines'][i]['portrait']='postop/smile'
    stories['day3']['lines'][0]['portrait']='postop/pain'
    story=dict(title="把心脏交还给跑道",title_en="Back to the Starting Line",procedure_id=ID,source_case_id='MIDO_LEGENDARY_MURAKAMI_AI_V1_2',runtime_case_id='advanced_first_'+ID,patient=dict(id='patient_murakami_ai',name='村上愛',name_en='Ai Murakami',setting='成人；体育教师；曾为马拉松选手。星见 AU 首次专属病例。',setting_en='An adult PE teacher and former marathon runner. An authored first case in the Hoshimi alternate universe.',diagnosis='主动脉根部及近端升主动脉瘤（未破裂、未夹层）；三叶式主动脉瓣，瓣叶适合保留',diagnosis_en='Aortic root and proximal ascending aortic aneurysms (unruptured, without dissection); tricuspid native aortic valve with suitable leaflets for preservation',visuals={'portraits':{}}),**stories)
    oldpath=DATA/'stories'/f'{ID}.json'
    if oldpath.exists(): story['patient']['visuals']=read(oldpath)['patient']['visuals']
    shared={s['id']:{'before_action':[],'after_resolution':[]} for s in proc['steps']}
    for lid,role,cn,en in re.findall(r'^- (MR\d+_(?:PRE|POST)\d+)｜([^｜]+)｜([^｜]+)｜(.*)$',section(raw,'## 4. Day 2','## 5. 两套'),re.M):
        shared[lid[:4]]['before_action' if '_PRE' in lid else 'after_resolution'].append(dict(id=lid,speaker_role=role,text=cn,text_en=en))
    pre=table(section(raw,'| Stage | 首通：御堂教学 FIRST_ASSIST_PRE','**高价值节点'))
    post=table(section(raw,'| Stage | 首通：御堂教学 FIRST_ASSIST_POST','**句数控制**'))
    failed=table(section(raw,'| P stage |','**播放优先级**'))
    replies=table(section(raw,'### 5.1','实现时保留'))
    dialogues={}
    for mode,col in [('teaching',1),('standard',2)]:
        stages=copy.deepcopy(shared)
        for rows,group,suffix in [(pre,'before_action','FIRST_ASSIST_PRE'),(post,'after_resolution','FIRST_ASSIST_POST'),(failed,'precision_failed','FAILED')]:
            for r in rows:
                sid=r[0];cn,en=pair(r[col]); row=dict(id=f'{sid}_{suffix}_{mode.upper()}',speaker_role='assistant_1',text=cn,text_en=en)
                if group=='before_action': stages[sid][group].insert(1,row)
                else: stages[sid].setdefault(group,[]).append(row)
        if mode=='teaching':
            for r in replies:
                cn,en=pair(r[1]); row=stages[r[0]]['before_action'][2]
                row.update(id=r[0]+'_PRE02_TEACHING',text=cn,text_en=en)
        assert all(len(s['before_action'])==3 and len(s['after_resolution']) in [1,2] for s in stages.values())
        dialogues[mode]=dict(schema_version='advanced_day2_dialogue_v2',procedure_id=ID,stages=stages)
    return proc,story,dialogues

def main():
    proc,story,dialogues=build()
    ui=read(DATA/'ui_text.json')
    keys={'解锁／入口开放':'legendary_available','锁定：高级转诊未开放':'legendary_system_locked','锁定：普通高级术式不足':'legendary_clears_locked','锁定：关系不足':'legendary_rank_locked','锁定：资源未准备好':'legendary_assets_locked','锁定：第一助手无法排班':'legendary_mentor_locked','首通确认':'legendary_confirm','首通成功提示':'legendary_cleared','首通失败提示':'legendary_failed','返场入口说明':'legendary_replay'}
    for line in section(SOURCE.read_text(),'## 6.6','## 7.').splitlines():
        if not line.startswith('|'): continue
        cells=[c.strip() for c in line.strip().strip('|').split('|')]
        if cells[0] in keys: ui[keys[cells[0]]]=[v.replace('{remaining}','%d') for v in cells[1:3]]
    write(DATA/'ui_text.json',ui)
    write(DATA/'legendary_procedures.json',[proc])
    write(DATA/'stories'/f'{ID}.json',story)
    write(DATA/'dialogue_v2'/f'{ID}.json',dialogues['standard'])
    write(DATA/'dialogue_teaching'/f'{ID}.json',dialogues['teaching'])
    write(ROOT/'research/imports/mido_legendary_v1_2.json',dict(source=str(SOURCE.relative_to(ROOT)),sha256=hashlib.sha256(SOURCE.read_bytes()).hexdigest(),procedure_id=ID,chapters={k:len(story[k]['lines']) for k in ['day1','day2','day3']},overrides=['One author-supplied main field; reuse thoracic incision/closure. No extra field variants.','Rei cardiovascular, Asuka and Maki abdominal specialists; preserve actual skill values.'],runtime_ready=read(DATA/'legendary_registry.json')[0]['runtime_ready']))
    print('Imported 17 stages; chapters', {k:len(story[k]['lines']) for k in ['day1','day2','day3']})
if __name__=='__main__': main()
