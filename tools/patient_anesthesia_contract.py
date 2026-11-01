"""Required anesthesia art for every registered random patient, without image editing."""
from pathlib import Path

REQUIRED_KEYS = ('intraoperative/anesthetized', 'splash/general_anesthesia')

def anesthesia_asset_errors(patient, root):
    errors = []
    portraits = patient.get('visuals', {}).get('portraits', {})
    for key in REQUIRED_KEYS:
        relative = portraits.get(key, '')
        label = f"{patient.get('id', '?')}: required anesthesia asset {key}"
        if not isinstance(relative, str) or not relative.strip():
            errors.append(label + ' missing mapping')
            continue
        path = Path(root) / relative
        if not path.is_file():
            errors.append(label + ' missing file: ' + relative)
            continue
        with path.open('rb') as source:
            if source.read(8) != b'\x89PNG\r\n\x1a\n':
                errors.append(label + ' invalid PNG: ' + relative)
    return errors
