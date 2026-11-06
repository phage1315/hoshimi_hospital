#!/usr/bin/env python3
"""Negative controls proving the full-project localization gate rejects fallback."""

from __future__ import annotations

import contextlib
import io
import json
import tempfile
from pathlib import Path

import localization_audit as audit


def run_with_english_change(change, expected: str) -> None:
    with tempfile.TemporaryDirectory() as temporary:
        locale_dir = Path(temporary)
        english = json.loads((audit.LOCALE_DIR / "en.json").read_text(encoding="utf-8"))
        chinese = (audit.LOCALE_DIR / "zh_CN.json").read_text(encoding="utf-8")
        change(english["strings"])
        (locale_dir / "en.json").write_text(json.dumps(english, ensure_ascii=False), encoding="utf-8")
        (locale_dir / "zh_CN.json").write_text(chinese, encoding="utf-8")
        original = audit.LOCALE_DIR
        try:
            audit.LOCALE_DIR = locale_dir
            errors = io.StringIO()
            with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(errors):
                status = audit.main()
            assert status == 1 and expected in errors.getvalue(), (status, expected, errors.getvalue()[:500])
        finally:
            audit.LOCALE_DIR = original


def main() -> None:
    key = "collections.staff.doc_aoi.rank"
    run_with_english_change(lambda strings: strings.pop(key), f"active authored translation missing: {key}")
    run_with_english_change(lambda strings: strings.__setitem__(key, "外科医师"), f"Chinese remains in translation: {key}")
    run_with_english_change(lambda strings: strings.__setitem__("ui.save.slot", "Slot %s"), "placeholder mismatch for ui.save.slot")
    with tempfile.TemporaryDirectory() as temporary:
        original = audit.ROOT
        try:
            audit.ROOT = Path(temporary)
            path = audit.ROOT / "data/daydreams/test.json"
            path.parent.mkdir(parents=True)
            path.write_text(json.dumps({"title": {"zh_CN": "测试", "en": "测试"}}, ensure_ascii=False), encoding="utf-8")
            assert any("inline English contains Chinese" in failure for failure in audit.strict_inline_locale_failures())
            path.write_text(json.dumps({"title": {"zh_CN": "测试"}}, ensure_ascii=False), encoding="utf-8")
            assert any("inline English missing" in failure for failure in audit.strict_inline_locale_failures())
            path.write_text(json.dumps({"title": {"zh_CN": "患者：{name}", "en": "Patient"}}, ensure_ascii=False), encoding="utf-8")
            assert any("inline English placeholder mismatch" in failure for failure in audit.strict_inline_locale_failures())
            path.unlink()
            path = audit.ROOT / "data/advanced_surgery/test.json"
            path.parent.mkdir(parents=True)
            path.write_text(json.dumps({"name": "手术"}, ensure_ascii=False), encoding="utf-8")
            assert any("inline English missing" in failure for failure in audit.strict_inline_locale_failures())
            path.write_text(json.dumps({"name": "手术", "name_en": "手术"}, ensure_ascii=False), encoding="utf-8")
            assert any("inline English contains Chinese" in failure for failure in audit.strict_inline_locale_failures())
            path.write_text(json.dumps({"name": "手术：{patient}", "name_en": "Surgery"}, ensure_ascii=False), encoding="utf-8")
            assert any("inline English placeholder mismatch" in failure for failure in audit.strict_inline_locale_failures())
        finally:
            audit.ROOT = original
    print("LOCALIZATION STRICT GATE: 9 negative controls passed")


if __name__ == "__main__":
    main()
