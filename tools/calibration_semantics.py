# Adapted from user-provided V2 validator, SHA256 b0d1a3a1814a66893da08a94dc2774504255497ff7b84581b4293420bacc8148
# Audited adaptations: response_role is presentation-only; dictionary key order
# is irrelevant, but conditional branch evaluation order must be preserved.
#!/usr/bin/env python3
"""READ-ONLY crosswalk validation of 817 proposed numeric changes.

The input runtime export must be made from the CURRENT authoritative Godot data.
This script never edits game code. It compares semantic conditions/effects rather
than raw JSON, while refusing unknown condition operators or state-changing keys.
"""
import json
import pathlib
EFFECT_KEYS = {'elapsed_time', 'blood_loss', 'bleeding', 'visibility', 'stability',
               'set_flags', 'clear_flags', 'add_complications'}
# Allowed NON-SEMANTIC keys; changes to numerical/effect payloads must still fail.
PRESENTATION_KEYS = {'text','title','label','description','notes','note','comment',
    'response_text','success_text','failure_text','feedback_text','dialogue','narration',
    'operative_record','transition_text','response','display_text','player_text',
    'flavor_text','filler_text','voice_line','speaker','expression','localization_key',
    'choice_text','hint_text','response_role'}
OP_ALIASES = {'<':'lt','<=':'lte','>':'gt','>=':'gte','==':'eq','!=':'neq',
    'lt':'lt','lte':'lte','gt':'gt','gte':'gte','eq':'eq','neq':'neq'}

class IdentityMismatch(ValueError): pass

def read(path):
    return json.loads(pathlib.Path(path).read_text(encoding='utf-8-sig'))

def assert_extras_cosmetic(obj, semantic, context):
    others=set(obj)-set(semantic)
    unsafe=others-PRESENTATION_KEYS
    if unsafe:raise IdentityMismatch(f'Unsupported keys {sorted(unsafe)} in {context}; cannot safely ignore them')

def canonical_condition(obj):
    """Canonical boolean expression. all:[x] == x, commutative all/any."""
    if not isinstance(obj,dict):raise IdentityMismatch(f'Condition must be object, got {obj!r}')
    operators=[x for x in ('all','any','not') if x in obj]
    if operators:
        if len(operators)!=1:raise IdentityMismatch(f'Ambiguous condition expression: {obj}')
        kind=operators[0]
        assert_extras_cosmetic(obj,{kind},'condition logical node')
        if kind=='not':return ('not',canonical_condition(obj[kind]))
        arr=obj[kind]
        if not isinstance(arr,list) or not arr:raise IdentityMismatch(f'Empty or invalid {kind} list: {obj}')
        children=[canonical_condition(it) for it in arr]
        flat=[]
        for child in children:
            if child[0]==kind:flat.extend(child[1])
            else:flat.append(child)
        uniq=sorted(set(flat),key=repr)
        if len(uniq)==1:return uniq[0]
        return (kind,tuple(uniq))
    required={'field','op','value'}
    if not required<=set(obj):raise IdentityMismatch(f'Unknown condition leaf schema: {obj}')
    assert_extras_cosmetic(obj,required,'condition leaf')
    op=OP_ALIASES.get(str(obj['op']))
    if op is None:raise IdentityMismatch(f'Unsupported condition operator: {obj["op"]}')
    value=obj['value']
    if isinstance(value,bool):value=('bool',value)
    elif isinstance(value,(int,float)) and not isinstance(value,bool):value=('number',float(value))
    elif isinstance(value,str):value=('string',value)
    else:raise IdentityMismatch(f'Unsupported condition value: {value!r}')
    return ('atom',str(obj['field']),op,value)

def canonical_effects(obj):
    if not isinstance(obj,dict):raise IdentityMismatch(f'Effects must be dictionary, got {obj!r}')
    assert_extras_cosmetic(obj,EFFECT_KEYS,'effects')
    result={}
    for key,val in obj.items():
        if key not in EFFECT_KEYS:continue
        if key in ('set_flags','clear_flags'):
            if not isinstance(val,list):raise IdentityMismatch(f'{key} must be a list')
            result[key]=tuple(sorted(set(val)))
        elif key=='add_complications':
            if not isinstance(val,list):raise IdentityMismatch('add_complications must be a list')
            normalized=[]
            for comp in val:
                if not isinstance(comp,dict) or 'id' not in comp or 'severity' not in comp:
                    raise IdentityMismatch(f'Invalid complication record: {comp!r}')
                assert_extras_cosmetic(comp,{'id','severity'},'complication record')
                normalized.append((comp['id'],comp['severity']))
            result[key]=tuple(sorted(normalized))
        else:
            if isinstance(val,bool) or not isinstance(val,(int,float)):
                raise IdentityMismatch(f'Non-numeric effect {key}={val!r}')
            result[key]=float(val)
    return result

def canonical_branch(branch):
    if not isinstance(branch,dict) or 'when' not in branch or 'strategic_effects' not in branch:
        raise IdentityMismatch(f'Incomplete conditional branch: {branch}')
    assert_extras_cosmetic(branch,{'when','strategic_effects'},'conditional branch')
    return canonical_condition(branch['when']),canonical_effects(branch['strategic_effects'])

def match_conditions(design,actual,where):
    """Compare semantics and cosmetic fields; preserve sequential branch order."""
    dvals=[canonical_branch(x) for x in design]
    avals=[canonical_branch(x) for x in actual]
    if len(dvals)!=len(avals):
        raise IdentityMismatch(f'{where}: conditional count differs design={len(dvals)}, runtime={len(avals)}')
    if dvals != avals:
        raise IdentityMismatch(f'{where}: conditional predicates/effects differ, design={dvals}, runtime={avals}')
    out={};used=set()
    for i,db in enumerate(dvals):
        candidates=[j for j,ab in enumerate(avals) if j not in used and ab==db]
        if len(candidates)!=1:
            raise IdentityMismatch(f'{where}: ambiguous conditional match for design branch {i}: {candidates}')
        j=candidates[0];used.add(j);out[i]=j
    return out

def verify(intents,options,mapping,runtime):
    issues=[];verified=[]
    cross={}
    for entry in mapping:
        key=entry.get('design_option_key')
        if not isinstance(key,str) or not key:
            issues.append('Crosswalk row without design_option_key');continue
        if key in cross:issues.append(f'Duplicate design mapping: {key}')
        cross[key]=entry
    target_keys={f"{p['procedure_id']}/{p['stage_index']}/{p['option']}" for p in intents}
    if target_keys!=set(cross):issues.append(f'Crosswalk keys missing {len(target_keys-set(cross))}, extra {len(set(cross)-target_keys)}')
    actual_by_key={}
    for pid,pr in runtime.get('procedures',{}).items():
        if not isinstance(pr,dict) or not isinstance(pr.get('stages'),list):
            issues.append(f'Malformed procedure {pid}');continue
        sids=set()
        for st in pr['stages']:
            sid=st.get('id')
            if not sid or sid in sids:issues.append(f'Missing/duplicate stage ID {pid}/{sid}')
            sids.add(sid);oids=set()
            for op in st.get('options',[]):
                oid=op.get('id')
                if not oid or oid in oids:issues.append(f'Missing/duplicate option ID {pid}/{sid}/{oid}')
                oids.add(oid)
                actual_by_key[(pid,sid,oid)]=(st,op)
    mapped_runtime=set();stage_cross={};validated_options={}
    for optkey in sorted(target_keys):
        ent=cross.get(optkey)
        if not ent:continue
        p=next((p for p in intents if f"{p['procedure_id']}/{p['stage_index']}/{p['option']}"==optkey),None)
        proc=p['canonical_procedure_id']
        sid=ent.get('runtime_stage_id');oid=ent.get('runtime_option_id')
        rkey=(proc,sid,oid)
        if rkey not in actual_by_key:
            issues.append(f'Runtime identity missing {rkey} mapped from {optkey}');continue
        if rkey in mapped_runtime:issues.append(f'Multiple design options map to runtime {rkey}')
        mapped_runtime.add(rkey)
        stagekey='/'.join(optkey.split('/')[:2])
        if stagekey in stage_cross and stage_cross[stagekey]!=sid:issues.append(f'Inconsistent stage map {stagekey}')
        stage_cross[stagekey]=sid
        st,op=actual_by_key[rkey]
        if op.get('correct') is False:issues.append(f'Incorrect option mapped {rkey}')
        o=options.get(optkey)
        if not o:issues.append(f'Missing design option hint {optkey}');continue
        try:
            dmain=canonical_effects(o['design_original_strategic_effects'])
            rmain=canonical_effects(op.get('strategic_effects',{}))
            if dmain!=rmain:
                raise IdentityMismatch(f'Main effects differ, design={dmain} runtime={rmain}')
            ci=match_conditions(o['design_original_conditional_effects'],op.get('conditional_effects',[]),str(rkey))
            validated_options[optkey]=(rkey,op,ci)
        except IdentityMismatch as exc:
            issues.append(f'Fingerprint conflict {rkey}: {exc}')
    for p in intents:
        key=f"{p['procedure_id']}/{p['stage_index']}/{p['option']}"
        if key not in validated_options:continue
        (proc,sid,oid),op,ci=validated_options[key]
        if p['branch']=='main':actual_effects=op.get('strategic_effects',{});rb='main'
        else:
            di=int(p['branch'].rsplit('_',1)[-1])
            if di not in ci:
                issues.append(f'No verified conditional mapping {key}/{p["branch"]}');continue
            ri=ci[di]
            actual_effects=op['conditional_effects'][ri]['strategic_effects'];rb=f'conditional_{ri}'
        if p['field'] not in actual_effects or actual_effects[p['field']]!=p['old']:
            issues.append(f'PATCH OLD conflict {proc}/{sid}/{oid}/{rb}.{p["field"]}: expected {p["old"]}, actual {actual_effects.get(p["field"])}')
            continue
        item=dict(p)
        item.update({'runtime_stage_id':sid,'runtime_option_id':oid,'runtime_branch':rb})
        item.pop('identity_status',None)
        verified.append(item)
    if len(verified)!=817:issues.append(f'Only {len(verified)} of 817 patch fields verified')
    if len(mapped_runtime)!=len(target_keys):issues.append(f'Only {len(mapped_runtime)} of {len(target_keys)} distinct option mappings verified')
    return issues,verified
