#!/usr/bin/env python3
"""Fill the remaining English narrative packs through a reviewable MT pass.

This script is intentionally limited to character events, micro events and
special-event step scripts. Stable localization keys, character names, format
placeholders and paragraph breaks are preserved. Existing reviewed English is
never overwritten unless --force is supplied.
"""

from __future__ import annotations

import argparse
import json
import re
import time
import urllib.parse
import urllib.request
from pathlib import Path
from collection_io import load_collection

ROOT = Path(__file__).resolve().parents[1]
LOCALE = ROOT / "data/localization/en.json"
TARGETS = {
    "character_events": ROOT / "data/events/character_events/index.json",
    "micro_events": ROOT / "data/events/micro_events.json",
    "special_event_steps": ROOT / "data/events/special_event_steps/index.json",
}
FIELDS = {
    "name", "family_name", "given_name", "professional_name", "title", "subtitle",
    "description", "label", "text", "prompt", "response", "teaser", "caption",
    "announcement", "location_label", "speaker_label", "specialty", "personality",
    "presenting_complaint", "diagnosis", "intake_notes", "result", "summary", "section",
    "correction",
}
HAN = re.compile(r"[\u3400-\u9fff]")
PLACEHOLDER = re.compile(r"%(?:0?\d+)?[sdif]")
SEPARATOR = "ZZZHOSHIMISEPARATORZZZ"

# Longest source forms must be replaced first. Tokens survive the translation
# endpoint and are restored after each batch.
GLOSSARY = {
    "星见医院": "Hoshimi Hospital",
    "星見医院": "Hoshimi Hospital",
    "御统百合香": "Yurika Mito",
    "折川皐月": "Satsuki Orikawa",
    "御统小姐": "Ms. Mito",
    "折川小姐": "Ms. Orikawa",
    "百合香": "Yurika",
    "皐月": "Satsuki",
    "御统": "Mito",
    "折川": "Orikawa",
    "片桐彩子": "Ayako Katagiri",
    "深山佳織": "Kaori Miyama",
    "深山 佳織": "Kaori Miyama",
    "七瀬恋": "Ren Nanase",
    "七瀬 恋": "Ren Nanase",
    "神宮寺成美": "Narumi Jinguji",
    "神宮寺 成美": "Narumi Jinguji",
    "中井美佳": "Mika Nakai",
    "中井 美佳": "Mika Nakai",
    "朝倉美幸": "Miyuki Asakura",
    "朝倉 美幸": "Miyuki Asakura",
    "飯村真奈美": "Manami Iimura",
    "飯村 真奈美": "Manami Iimura",
    "利根川安琪": "Anji Tonegawa",
    "利根川 安琪": "Anji Tonegawa",
    "杉村弘子": "Hiroko Sugimura",
    "杉村 弘子": "Hiroko Sugimura",
    "本庄萌惠": "Moe Honjo",
    "本庄 萌惠": "Moe Honjo",
    "御堂江美子": "Emiko Mido",
    "御堂 江美子": "Emiko Mido",
    "城宮明日香": "Asuka Shiromiya",
    "城宮 明日香": "Asuka Shiromiya",
    "藤崎詩織": "Shiori Fujisaki",
    "藤崎 詩織": "Shiori Fujisaki",
    "水城阿库娅": "Aqua Mizuki",
    "水城 阿库娅": "Aqua Mizuki",
    "南条小夜香": "Sayaka Nanjo",
    "南条 小夜香": "Sayaka Nanjo",
    "锦木千束": "Chisato Nishikigi",
    "锦木 千束": "Chisato Nishikigi",
    "伊吹摩耶": "Maya Ibuki",
    "伊吹 摩耶": "Maya Ibuki",
    "佐仓双叶": "Futaba Sakura",
    "佐仓 双叶": "Futaba Sakura",
    "阿尔托莉雅·潘德拉贡": "Artoria Pendragon",
    "坂口医生": "Dr. Sakaguchi",
    "坂口": "Sakaguchi",
    "彩子": "Ayako",
    "佳織": "Kaori",
    "恋": "Ren",
    "明日香": "Asuka",
    "诗织": "Shiori",
    "詩織": "Shiori",
    "阿库娅": "Aqua",
    "小夜香": "Sayaka",
    "摩耶": "Maya",
    "双叶": "Futaba",
}


def walk(value: object, path: str, out: list[tuple[str, str]]) -> None:
    if isinstance(value, dict):
        for field, child in value.items():
            child_path = f"{path}.{field}"
            if field in FIELDS and isinstance(child, str) and child.strip() and HAN.search(child):
                out.append((child_path, child))
            walk(child, child_path, out)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            identity = str(child.get("id", index)) if isinstance(child, dict) else str(index)
            walk(child, f"{path}.{identity}", out)


def protect(text: str) -> tuple[str, dict[str, str]]:
    protected = text
    restore: dict[str, str] = {}
    counter = 0
    for source, target in sorted(GLOSSARY.items(), key=lambda item: len(item[0]), reverse=True):
        if source not in protected:
            continue
        token = f"ZXQNAME{counter}ZXQ"
        counter += 1
        protected = protected.replace(source, token)
        restore[token] = target
    for match in list(PLACEHOLDER.finditer(protected)):
        value = match.group(0)
        if value in restore.values():
            continue
        token = f"ZXQFORMAT{counter}ZXQ"
        counter += 1
        protected = protected.replace(value, token, 1)
        restore[token] = value
    return protected, restore


def request_translation(text: str) -> str:
    payload = urllib.parse.urlencode({
        "client": "gtx", "sl": "zh-CN", "tl": "en", "dt": "t", "q": text,
    }).encode("utf-8")
    request = urllib.request.Request(
        "https://translate.googleapis.com/translate_a/single",
        data=payload,
        headers={"User-Agent": "Hoshimi-localization/1.0"},
    )
    for attempt in range(5):
        try:
            with urllib.request.urlopen(request, timeout=45) as response:
                data = json.loads(response.read().decode("utf-8"))
            return "".join(part[0] for part in data[0])
        except Exception:
            if attempt == 4:
                raise
            time.sleep(1.5 * (attempt + 1))
    raise RuntimeError("translation request failed")


def translate_batch(batch: list[tuple[str, str]]) -> dict[str, str]:
    sources: list[str] = []
    restorations: list[dict[str, str]] = []
    for _key, source in batch:
        value, restore = protect(source)
        sources.append(value)
        restorations.append(restore)
    translated = request_translation(f"\n{SEPARATOR}\n".join(sources))
    parts = translated.split(SEPARATOR)
    if len(parts) != len(batch):
        raise RuntimeError(f"batch boundary mismatch: {len(parts)} != {len(batch)}")
    result: dict[str, str] = {}
    for (key, _source), value, restore in zip(batch, parts, restorations):
        value = value.strip()
        for token, replacement in restore.items():
            value = value.replace(token, replacement)
            value = value.replace(token.lower(), replacement)
        result[key] = value
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()
    locale = json.loads(LOCALE.read_text(encoding="utf-8"))
    strings: dict[str, str] = locale["strings"]
    pending: list[tuple[str, str]] = []
    for collection, path in TARGETS.items():
        authored = load_collection(path)
        rows: list[tuple[str, str]] = []
        walk(authored, f"collections.{collection}", rows)
        pending.extend((key, value) for key, value in rows if args.force or key not in strings)
    print(f"Translating {len(pending)} narrative fields")
    batches: list[list[tuple[str, str]]] = []
    current: list[tuple[str, str]] = []
    size = 0
    for item in pending:
        cost = len(item[1]) + len(SEPARATOR) + 2
        if current and size + cost > 3200:
            batches.append(current)
            current, size = [], 0
        current.append(item)
        size += cost
    if current:
        batches.append(current)
    for index, batch in enumerate(batches, 1):
        strings.update(translate_batch(batch))
        print(f"Batch {index}/{len(batches)}: {len(batch)} fields")
        # Keep completed work recoverable if a later request is rate-limited.
        locale["strings"] = dict(sorted(strings.items()))
        LOCALE.write_text(json.dumps(locale, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        time.sleep(0.15)
    unresolved = [key for key, _source in pending if key not in strings or HAN.search(strings[key])]
    if unresolved:
        print("Unresolved English fields:")
        print("\n".join(unresolved))
        return 1
    print(f"Narrative translation complete: {len(pending)} fields")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
