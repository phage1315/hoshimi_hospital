from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PREPARED = ROOT / "prepared" / "doc_aoi"
MANIFEST = json.loads((ROOT / "prepared_manifest.json").read_text(encoding="utf-8"))

expected = {item["key"]: item for item in MANIFEST["assets"]}
actual = {
    str(path.relative_to(PREPARED).with_suffix("")): path
    for path in PREPARED.rglob("*.png")
}

assert len(expected) == 23, len(expected)
assert set(actual) == set(expected), (sorted(set(expected) - set(actual)), sorted(set(actual) - set(expected)))

for key, item in expected.items():
    path = actual[key]
    with Image.open(path) as image:
        image.load()
        assert list(image.size) == item["size"], (key, image.size, item["size"])
        assert image.mode == item["mode"], (key, image.mode, item["mode"])
        if key.startswith("ward/") or key.startswith("intraoperative/"):
            assert image.mode == "RGBA", key
            assert image.getpixel((0, 0))[3] == 0, key
            assert image.getpixel((image.width - 1, 0))[3] == 0, key
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    assert digest == item["sha256"], (key, digest, item["sha256"])

source = ROOT / "author_supplied" / "advanced_chest.png"
prepared_chest = PREPARED / "advanced" / "chest.png"
assert source.read_bytes() == prepared_chest.read_bytes()
print("PASS: doc_aoi prepared patient art has exactly 23 verified slots")
