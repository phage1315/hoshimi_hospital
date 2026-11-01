#!/usr/bin/env python3
"""Build a release, verify its isolated PCK against native project rendering, then deliver.
No player saves, source material edits, uploads, or publication. Keeps final output
names intact; refuses to replace an existing delivery. Requires a native display.
"""
import argparse
import hashlib
import json
import re
import shutil
import subprocess
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def fingerprint():
    digest = hashlib.sha256()
    for folder in ('godot', 'data'):
        for p in sorted((ROOT / folder).rglob('*')):
            if p.is_file() and p.suffix in {'.gd', '.tscn', '.tres', '.json'}:
                digest.update(str(p.relative_to(ROOT)).encode())
                digest.update(p.read_bytes())
    digest.update((ROOT / 'export_presets.cfg').read_bytes())
    return digest.hexdigest()

def run(command, log, cwd):
    print('RUN', log.name, flush=True)
    with log.open('w') as output:
        completed = subprocess.run(command, cwd=cwd, stdout=output,
                                   stderr=subprocess.STDOUT, timeout=2400)
    text = log.read_text(errors='replace')
    if completed.returncode or 'SCRIPT ERROR:' in text or re.search(r'^ERROR:', text, re.M):
        raise RuntimeError(f'Command failed or Godot reported errors: {log}')

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True, type=Path)
    parser.add_argument('--preset', default='Windows Desktop')
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--report', required=True, type=Path)
    args = parser.parse_args()
    godot = args.godot.resolve()
    destination = args.output.resolve()
    report = args.report.resolve()
    if destination.exists():
        raise RuntimeError('Output exists; choose a new delivery directory (keep HoshimiHospital.zip).')
    if destination.name != 'HoshimiHospital.zip':
        raise RuntimeError('Delivery must retain HoshimiHospital.zip, .exe and .pck names.')
    if report.exists() and any(report.iterdir()):
        raise RuntimeError('Use a new empty report directory so previous evidence is retained.')
    report.mkdir(parents=True, exist_ok=True)
    (report / '.gdignore').touch()  # QA screenshots must not become imported assets.
    # Guard the exact regression. Raw JSON/slot access in systems stays legitimate.
    for script in (ROOT / 'godot/ui').rglob('*.gd'):
        code = '\n'.join(line for line in script.read_text().splitlines()
                         if not line.lstrip().startswith('#'))
        if re.search(r'FileAccess\.file_exists\s*\(', code):
            raise RuntimeError(f'Raw file existence check in media UI needs review: {script}')
    before = fingerprint()
    harness = ROOT / 'tools/export_event_resource_test.gd'
    with tempfile.TemporaryDirectory(prefix='hoshimi_checked_release_') as scratch:
        stage = Path(scratch)
        package = stage / 'HoshimiHospital.zip'
        pack_root = stage / 'isolated_pack'
        pack_root.mkdir()
        # Source and packed runs use the exact same test script; only res:// changes.
        run([str(godot), '--path', str(ROOT), '--script', str(harness),
             '--log-file', str(report / 'local_engine.log'), '--',
             '--out=' + str(report / 'local')], report / 'local_stdout.log', ROOT)
        run([str(godot), '--headless', '--path', str(ROOT), '--export-release',
             args.preset, str(package), '--log-file', str(report / 'export_engine.log')],
            report / 'export_stdout.log', ROOT)
        with zipfile.ZipFile(package) as z:
            names = set(z.namelist())
            if 'HoshimiHospital.exe' not in names or 'HoshimiHospital.pck' not in names:
                raise RuntimeError(f'Incorrect delivery names: {sorted(names)}')
            with z.open('HoshimiHospital.pck') as source, (pack_root / 'HoshimiHospital.pck').open('wb') as target:
                shutil.copyfileobj(source, target, 8 * 1024 * 1024)
        run([str(godot), '--path', str(pack_root), '--main-pack',
             str(pack_root / 'HoshimiHospital.pck'), '--script', str(harness),
             '--log-file', str(report / 'packed_engine.log'), '--', '--packed',
             '--out=' + str(report / 'packed')], report / 'packed_stdout.log', pack_root)
        local = json.loads((report / 'local/results.json').read_text())
        packed = json.loads((report / 'packed/results.json').read_text())
        if local['failures'] or packed['failures']:
            raise RuntimeError('Resource/GUI assertions failed; inspect results.json.')
        differing = [field for field in ('resources', 'renders', 'gui')
                     if local[field] != packed[field]]
        if differing:
            raise RuntimeError(f'Editor/export mismatch: {differing}')
        def screenshot_hashes(folder):
            return {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
                    for p in folder.glob('*.png')}
        local_shots = screenshot_hashes(report / 'local')
        packed_shots = screenshot_hashes(report / 'packed')
        if not local_shots or local_shots != packed_shots:
            raise RuntimeError('Native screenshots differ between project and PCK; inspect before delivery.')
        if fingerprint() != before:
            raise RuntimeError('Production sources changed during validation; retry against one version.')
        destination.parent.mkdir(parents=True, exist_ok=True)
        # Never replace an existing delivery, even if one appeared during testing.
        with package.open('rb') as source, destination.open('xb') as target:
            shutil.copyfileobj(source, target, 8 * 1024 * 1024)
        summary = {'result': 'PASS', 'source_sha256': before,
                   'output': str(destination), 'zip_bytes': destination.stat().st_size,
                   'resource_count': local['resource_count'],
                   'affected_node_count': local['affected_node_count'],
                   'distinct_visual_configs': local['distinct_visual_configs'],
                   'gui_samples': len(local['gui']), 'identical_screenshots': len(local_shots),
                   'local_checks': local['checks'],
                   'packed_checks': packed['checks'],
                   'limitation': 'Native macOS engine runs the actual Windows PCK; Windows executable/platform rendering not exercised.'}
        (report / 'summary.json').write_text(json.dumps(summary, ensure_ascii=False, indent=2) + '\n')
        print(json.dumps(summary, ensure_ascii=False, indent=2), flush=True)

if __name__ == '__main__':
    main()
