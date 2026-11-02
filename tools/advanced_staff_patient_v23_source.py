"""Strict reader for the author's archived bilingual V2.3 (no prose generation)."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
# Reserved Takano ID owns only a future script; it does not register an NPC.
ACTORS = [
 ('1.1','doc_sayaka','小夜香','Sayaka'),
 ('1.2','doc_serika','芹香','Serika'),
 ('1.3','doc_emiko','御堂','Mido'),
 ('1.4','doc_rei','佳織','Kaori'),
 ('1.5','doc_asuka','明日香','Asuka'),
 ('1.6','doc_artoria','阿尔托莉雅','Artoria'),
 ('1.7','nurse_hiroko','弘子','Hiroko'),
 ('1.8','nurse_satsuki','皐月','Satsuki'),
 ('1.9','doc_aqua','阿库娅','Aqua'),
 ('1.10','nurse_rin','美佳','Mika'),
 ('1.11','doc_aoi','成美','Narumi'),
 ('1.12','nurse_haru','恋','Ren'),
 ('1.13','doc_shiori','詩織','Shiori'),
 ('1.14','nurse_yui','美幸','Miyuki'),
 ('1.15','doc_minato','遥凑','Haruka'),
 ('2.1','nurse_moe','萌恵','Moe'),
 ('2.2','pharmacist_manami','真奈美','Manami'),
 ('2.3','nurse_iwasaki_rumi','留美','Rumi'),
 ('2.4','nurse_yoneda_shiori','栞','Shiori'),
 ('2.5','nurse_sonoda_itsumi','愛実','Itsumi'),
 ('2.6','nurse_kariya_megumi','狩谷','Kariya'),
 ('2.7','nurse_hikami_saeko','冴子','Saeko'),
 ('2.8','doc_takemi','武見','Takemi'),
 ('2.9','nurse_takano_miyo','鹰野护士','Nurse Takano'),
]
PHASES = ('consult','night','after','success','failure')
RUNTIME_PHASES = ('consult','night','dark','after','success','failure')

def rows(text, patient, english=False):
    result = []
    for raw in text.splitlines():
        line = raw.strip()
        if not line: continue
        left, right = ('[',']') if english else ('【','】')
        if line.startswith(left) and line.endswith(right):
            result.append({'speaker':'narrator','text':line[1:-1]})
            continue
        pattern = r'([^:]+): ["“](.*)["”]$' if english else r'([^：]+)：「(.*)」$'
        match = re.fullmatch(pattern,line)
        if match:
            player = 'Sakaguchi' if english else '坂口'
            assert match[1] in (player, patient), f'Unexpected speaker {match[1]}'
            result.append({'speaker':'player' if match[1]==player else 'patient','text':match[2]})
        elif line.startswith((left, patient, 'Sakaguchi:' if english else '坂口：')):
            raise AssertionError('Unparsed narrative line: '+line[:50])
    return result

def source_actors():
    sources = [(ROOT/f'docs/source/advanced_staff_patient_v2_3/author_{lang}.md').read_text() for lang in ('cn','en')]
    result = {}
    for section_id, actor, zh_name, en_name in ACTORS:
        localized = []
        titles = []
        for english, source in enumerate(sources):
            section = re.search(r'(?ms)^### '+re.escape(section_id)+r' (.*?)(?=^#{1,3} |\Z)',source)[1]
            title_pattern = r'\| \*(.*?)\*' if english else r'《(.*?)》'
            titles.append(re.search(title_pattern,section.splitlines()[0])[1])
            chunks = re.split(r'\*\*Day [13][^\n]+\*\*',section)[1:]
            assert len(chunks)==5, actor+' needs five authored sections'
            localized.append({phase:rows(chunk,en_name if english else zh_name,bool(english)) for phase,chunk in zip(PHASES,chunks)})
        entry = {'title':titles[0],'title_en':titles[1]}
        for phase in PHASES:
            cn,en=localized[0][phase],localized[1][phase]
            assert cn and len(cn)==len(en), f'{actor}/{phase}: bilingual length mismatch {len(cn)}/{len(en)}'
            assert [r['speaker'] for r in cn]==[r['speaker'] for r in en], actor+'/'+phase+': bilingual speaker mismatch'
            entry[phase]=[{**a,'text_en':b['text'].replace('`<Current Procedure>`','〈本次术式〉')} for a,b in zip(cn,en)]
            # 2026-11-02 user-approved one-word repair; preserve archived source.
            if actor == 'doc_aoi':
                for row in entry[phase]:
                    row['text_en'] = row['text_en'].replace("don't揉 me there so suddenly", "don't rub me there so suddenly")
        # Existing runner switches to the shoulder portrait after the authored
        # undressing narration. Mido has an extra exchange before that narration.
        split_at = 7 if actor=='doc_emiko' else 5
        assert entry['night'][split_at-1]['speaker']=='narrator'
        entry['dark']=entry['night'][split_at:]
        entry['night']=entry['night'][:split_at]
        entry['source_section']=section_id
        entry['source_group']='planned_route' if section_id.startswith('1.') else 'conditional_future'
        result[actor]=entry
    return result

if __name__=='__main__':
    import json
    path=ROOT/'data/advanced_surgery/staff_patient/stories.json'
    data=json.loads(path.read_text())
    assert data['version']=='2.3', 'Only the V2.3 file may be updated'
    data['actors']=source_actors()
    path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
    print('V2.3: 24 bilingual actor scripts imported; common/repeat and all unlock data untouched.')
