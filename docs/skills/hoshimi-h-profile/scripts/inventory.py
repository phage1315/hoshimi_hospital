#!/usr/bin/env python3
"""Read-only new-actor Profile 1.3 asset inventory; not a Runner/content validator."""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys

EXPRESSIONS = ('neutral', 'annoyed', 'pleased', 'flustered', 'delighted', 'peak')
ZONES = ('lips', 'cheeks', 'neck', 'breasts', 'nipples', 'navel', 'torso_other', 'genitals', 'thighs')

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', required=True, type=Path)
    for key in ('profile', 'context', 'bodymap'):
        parser.add_argument('--'+key, required=True)
    parser.add_argument('--source-manifest', help='Optional JSON with files entries or one source/destination/sha256 entry')
    args = parser.parse_args()
    repo = args.repo.resolve()
    errors, assets, seen = [], [], {}
    def fail(message): errors.append(message)
    def path_in_repo(raw):
        value = str(raw)
        if value.startswith('res://'): value = value[6:]
        path = Path(value)
        path = (repo/path).resolve() if not path.is_absolute() else path.resolve()
        if not path.is_relative_to(repo): raise ValueError('Runtime asset outside repository: '+value)
        return path
    def read(raw):
        value = json.loads(path_in_repo(raw).read_text(encoding='utf-8'))
        if not isinstance(value, dict): raise ValueError('Expected JSON object: '+str(raw))
        return value
    p, c, b = read(args.profile), read(args.context), read(args.bodymap)
    actor = p.get('actor_id')
    if not isinstance(actor,str) or not actor or '__' in actor: fail('Missing finalized actor_id')
    if actor == 'doc_sayaka': fail('Legacy Sayaka atlas needs its dedicated Registry validator; this inventory targets new actors')
    if p.get('schema_version') != '1.3': fail('Expected authored Profile schema 1.3')
    if c.get('schema_version') != '1.0' or c.get('actor_id') != actor: fail('Context version or actor mismatch')
    if p.get('adult_confirmed') is not True: fail('adult_confirmed is unresolved; check project identity facts')
    pa = p.get('assets', {})
    ca = c.get('base', {}).get('assets', {})
    if not isinstance(pa,dict) or not isinstance(ca,dict): raise ValueError('assets must be dictionaries')
    def add(slot, raw):
        if not isinstance(raw,str) or not raw or '__' in raw:
            fail('Missing finalized asset path: '+slot); return None
        path = path_in_repo(raw)
        if path in seen:
            seen[path]['slots'].append(slot); return path
        row = {'slots':[slot], 'path':str(path.relative_to(repo)), 'exists':path.is_file()}
        seen[path] = row; assets.append(row)
        if not path.is_file(): fail('Missing file: '+row['path']); return path
        data = path.read_bytes(); row['sha256'] = hashlib.sha256(data).hexdigest()
        if data.startswith(b'\x89PNG\r\n\x1a\n') and len(data) >= 33:
            width,height,depth,color = struct.unpack('>IIBB',data[16:26])
            row.update(width=width,height=height,png_bit_depth=depth,png_color_type=color)
            row['alpha_note'] = 'Alpha-capable PNG; actual transparency not verified without Pillow' if color in (4,6) else 'No direct alpha channel; palette transparency requires decoder inspection'
            try:
                from PIL import Image
            except ImportError:
                pass
            else:
                with Image.open(path) as im:
                    im.load(); alpha = im.convert('RGBA').getchannel('A')
                    row['alpha_range'] = list(alpha.getextrema())
                    row['fully_transparent_pixels'] = alpha.histogram()[0]
                    row['alpha_note'] = 'Decoded alpha measured'
        return path
    expressions = pa.get('portrait_expressions', {})
    if not isinstance(expressions,dict): raise ValueError('portrait_expressions must be a dictionary')
    for key in EXPRESSIONS: add('portrait.'+key, expressions.get(key))
    for slot in ('body_map_image','scene_cg','aftercare_cg'): add('profile.'+slot,pa.get(slot))
    for slot in ('body_map','h_stage','after_cg'):
        spec = ca.get(slot,{})
        if not isinstance(spec,dict): raise ValueError('Context asset must be a dictionary: '+slot)
        if slot == 'body_map' or spec: add('context.'+slot,spec.get('path'))
    region_path = pa.get('body_map_regions')
    if not isinstance(region_path,str) or not region_path or path_in_repo(region_path) != path_in_repo(args.bodymap):
        fail('Profile body_map_regions does not match supplied bodymap file')
    body = ca.get('body_map',{})
    if not body.get('layout_id'): fail('Missing layout_id')
    for key,field in [('width','image_width'),('height','image_height')]:
        value = body.get(key)
        if not isinstance(value,int) or value <= 0 or value != b.get(field): fail('Bodymap dimension mismatch: '+key)
    refs = [pa.get('body_map_image'),body.get('path'),b.get('base_image')]
    if all(isinstance(x,str) and x for x in refs):
        resolved = [path_in_repo(x) for x in refs]
        if len(set(resolved)) != 1: fail('Profile, Context and bodymap point at different base images')
        measured = seen.get(resolved[1],{})
        for key in ('width','height'):
            if key in measured and measured[key] != body.get(key): fail('Actual image size differs from registered '+key)
    else: fail('Incomplete base image references')
    polygons = 0
    hotspots = b.get('hotspots',{})
    if not isinstance(hotspots,dict): raise ValueError('hotspots must be a dictionary')
    for zone in ZONES:
        region = hotspots.get(zone)
        if not isinstance(region,list) or not region: fail('Missing hotspot region: '+zone); continue
        for polygon in region:
            polygons += 1
            valid = isinstance(polygon,list) and len(polygon) >= 3
            if valid:
                valid = all(isinstance(pt,list) and len(pt)==2 and all(isinstance(n,(int,float)) and not isinstance(n,bool) and 0<=n<=1 for n in pt) for pt in polygon)
            if not valid: fail('Invalid normalized polygon: '+zone)
    backgrounds = json.loads((repo/'data/backgrounds.json').read_text(encoding='utf-8'))
    if not isinstance(backgrounds,list): raise ValueError('Expected background registry array')
    def background(slot,spec):
        if not isinstance(spec,dict): fail('Invalid background: '+slot); return
        identity = spec.get('id')
        match = [x for x in backgrounds if x.get('id') == identity]
        if len(match) != 1: fail('Unresolved background ID: '+slot); return
        add(slot,match[0].get('path'))
    background('background.base',ca.get('background',{}))
    for location,layer in c.get('locations',{}).items():
        for slot,spec in layer.get('assets',{}).items():
            if slot == 'background': background('background.location.'+location,spec)
            elif slot in ('body_map','h_stage','after_cg'): add('location.'+location+'.'+slot,spec.get('path'))
    if args.source_manifest:
        manifest=read(args.source_manifest)
        items=manifest.get('files',[manifest])
        for item in items:
            if not isinstance(item,dict) or 'destination' not in item: continue
            destination=path_in_repo(item['destination'])
            if not destination.is_file(): fail('Manifest destination missing: '+str(destination)); continue
            digest=hashlib.sha256(destination.read_bytes()).hexdigest()
            if item.get('sha256') != digest: fail('Manifest hash differs: '+str(destination))
            source=Path(item.get('source',''))
            if str(item.get('source','')):
                if not source.is_absolute(): source=repo/source
                if source.is_file() and source.read_bytes()!=destination.read_bytes(): fail('Source bytes differ: '+str(destination))
    report={'actor_id':actor,'assets':assets,'hotspot_regions':len(hotspots),'hotspot_polygons':polygons,'errors':errors,'scope':'File inventory and basic mapping only; no dialogue, Flow, full schema, production unlock or visual approval'}
    print(json.dumps(report,ensure_ascii=False,indent=2))
    return 1 if errors else 0

if __name__=='__main__':
    try: sys.exit(main())
    except (OSError,ValueError,KeyError,TypeError,AttributeError) as exc:
        print(json.dumps({'error':str(exc),'scope':'inventory incomplete'},ensure_ascii=False),file=sys.stderr)
        sys.exit(2)
