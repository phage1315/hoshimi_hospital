from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SLOT = "operating_table_lithotomy/anesthetized"
SHA256 = "f5528341e850d43488971fa4a83c7bedf35cef0c55211d1fc6b75379e2366450"

paths = [
    ROOT / "author_supplied" / "operating_table_lithotomy_anesthetized.png",
    ROOT / "operating_table_lithotomy" / "anesthetized.png",
    ROOT / "prepared" / "doc_rei" / "operating_table_lithotomy" / "anesthetized.png",
]

for path in paths:
    assert path.is_file(), path
    assert hashlib.sha256(path.read_bytes()).hexdigest() == SHA256, path
    with Image.open(path) as image:
        image.load()
        assert image.size == (1472, 1088), (path, image.size)
        assert image.mode == "RGBA", (path, image.mode)

assert paths[0].read_bytes() == paths[1].read_bytes() == paths[2].read_bytes()

manifest = json.loads((ROOT / "prepared_manifest.json").read_text(encoding="utf-8"))
record = next(item for item in manifest if item["key"] == SLOT)
assert record["size"] == [1472, 1088]
assert record["mode"] == "RGBA"
assert record["sha256"] == SHA256
assert record["source"] == "user_attachment"

prepared = ROOT / "prepared" / "doc_rei"
expected = {
    f"{group}/{expression}"
    for group, expressions in {
        "ward": ["neutral", "smile", "brave", "worried", "afraid", "crying"],
        "intraoperative": ["tense", "pain", "near_collapse", "anesthetized"],
        "operating_table": ["awake", "tense", "afraid", "anesthetized"],
        "operating_table_lithotomy": ["awake", "tense", "afraid", "anesthetized"],
        "splash": ["general_anesthesia"],
        "advanced": ["abdominal", "chest", "lateral", "prone"],
    }.items()
    for expression in expressions
}
actual = {str(path.relative_to(prepared).with_suffix("")) for path in prepared.glob("*/*.png")}
assert actual == expected
print("PASS: doc_rei lithotomy anesthesia replacement and exact 23-slot set verified")
