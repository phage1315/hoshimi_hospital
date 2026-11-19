from pathlib import Path
from PIL import Image
import hashlib
import json

root = Path("research/generated_candidates/miyama_staff_patient_v1")
prepared = root / "prepared/doc_rei"
records = []
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

for path in sorted(prepared.glob("*/*.png")):
    with Image.open(path) as image:
        image.load()
        key = str(path.relative_to(prepared).with_suffix(""))
        if path.parent.name in ("ward", "intraoperative"):
            assert image.mode == "RGBA", (key, image.mode)
            alpha = image.getchannel("A")
            for x in (0, image.width - 8):
                assert alpha.crop((x, 0, x + 8, 8)).getextrema() == (0, 0), key
        records.append(
            {
                "key": key,
                "path": str(path),
                "size": list(image.size),
                "mode": image.mode,
                "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            }
        )

assert {record["key"] for record in records} == expected
(root / "prepared_manifest.json").write_text(
    json.dumps(records, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
)
print("23 prepared PNG decoded and hashed; exact slot set verified; 10 transparent portraits")
