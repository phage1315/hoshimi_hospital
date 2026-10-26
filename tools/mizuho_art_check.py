"""Read-only PNG checks for the Mizuho VN portrait pack (requires Pillow)."""
import hashlib
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / "assets/characters/mizuho_story_v1"


def main():
    manifest = json.loads((PACK / "manifest.json").read_text())
    hashes = set()
    failures = []
    for asset in manifest["assets"]:
        path = ROOT / asset["path"]
        try:
            with Image.open(path) as image:
                image.load()
                digest = hashlib.sha256(image.tobytes()).hexdigest()
                if digest in hashes:
                    failures.append(f"Duplicate pixel data: {asset['key']}")
                hashes.add(digest)
                if list(image.size) != asset["size"]:
                    failures.append(f"Canvas mismatch: {asset['key']}")
                if asset["transparent"]:
                    if image.mode != "RGBA":
                        failures.append(f"No RGBA: {asset['key']}")
                        continue
                    alpha = image.getchannel("A")
                    histogram = alpha.histogram()
                    total = image.width * image.height
                    clear = sum(histogram[:3]) / total
                    solid = sum(histogram[250:]) / total
                    if clear < 0.15 or solid < 0.15:
                        failures.append(f"Invalid alpha coverage: {asset['key']}")
                    for point in [(0, 0), (image.width - 1, 0), (0, image.height // 2), (image.width - 1, image.height // 2)]:
                        if alpha.getpixel(point) > 2:
                            failures.append(f"Opaque outer margin: {asset['key']} {point}")
                    print(f"{asset['key']}: {image.size}, clear={clear:.1%}, solid={solid:.1%}")
                else:
                    print(f"{asset['key']}: {image.size}, scene background")
        except (OSError, ValueError) as exc:
            failures.append(f"{asset['key']}: {exc}")
    print(f"Mizuho art: {len(manifest['assets'])} assets, {len(failures)} failures")
    for error in failures:
        print(error)
    raise SystemExit(bool(failures))


if __name__ == "__main__":
    main()
