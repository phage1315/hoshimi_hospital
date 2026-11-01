"""Registry-wide anesthesia contract and regression checks for missing/broken assets."""
import copy
import json
import tempfile
import unittest
from pathlib import Path
from patient_anesthesia_contract import anesthesia_asset_errors, REQUIRED_KEYS

ROOT = Path(__file__).resolve().parents[1]

class AnesthesiaAssetsTest(unittest.TestCase):
    def test_every_registered_patient(self):
        index = json.loads((ROOT / 'data/patients/index.json').read_text())
        self.assertTrue(index)
        for path in index:
            patient = json.loads((ROOT / 'data/patients' / path).read_text())['patient']
            with self.subTest(patient=patient['id']):
                self.assertEqual(anesthesia_asset_errors(patient, ROOT), [])
        print(f'Checked {len(index)} registered patients, {len(index) * len(REQUIRED_KEYS)} required assets')

    def test_missing_and_broken_assets_are_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'ok.png').write_bytes(b'\x89PNG\r\n\x1a\n')
            (root / 'broken.png').write_bytes(b'not a PNG')
            base = {'id': 'fixture', 'visuals': {'portraits': dict.fromkeys(REQUIRED_KEYS, 'ok.png')}}
            self.assertEqual(anesthesia_asset_errors(base, root), [])
            for key in REQUIRED_KEYS:
                for value in [None, '', 'missing.png', 'broken.png']:
                    with self.subTest(key=key, value=value):
                        patient = copy.deepcopy(base)
                        if value is None:
                            del patient['visuals']['portraits'][key]
                        else:
                            patient['visuals']['portraits'][key] = value
                        errors = anesthesia_asset_errors(patient, root)
                        self.assertEqual(len(errors), 1)
                        self.assertIn(key, errors[0])

if __name__ == '__main__':
    unittest.main()
