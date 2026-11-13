#!/usr/bin/env python3
"""Create original prompt voices or render bounded GPT-Live samples. No automatic retries."""
import argparse
import struct
import base64
import hashlib
import json
import os
from pathlib import Path
import sys
import threading
import time
import urllib.error
import urllib.request
import wave


def write_json(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def read_key(path):
    key = Path(path).expanduser().read_text().strip() if path else os.environ.get('OPENAI_API_KEY', '').strip()
    if not key:
        raise ValueError('Missing API key: set OPENAI_API_KEY or use --key-file (path only).')
    return key


def safe_error(exc):
    # Never stringify network exceptions: they may include headers, cookies or credentials.
    return {'type': type(exc).__name__, 'http_status': getattr(exc, 'status_code', getattr(exc, 'code', None))}


def create_voice(payload, key, out):
    req = urllib.request.Request('https://api.openai.com/v1/audio/voices',
        data=json.dumps(payload).encode(),
        headers={'Authorization': 'Bearer ' + key, 'Content-Type': 'application/json'}, method='POST')
    # No automatic retry: a timeout may occur after the server creates the voice.
    with urllib.request.urlopen(req, timeout=60) as response:
        voice = json.load(response)
    if voice.get('object') != 'audio.voice' or not str(voice.get('id', '')).startswith('voice_'):
        raise ValueError('Unexpected voice response; reconcile server state before retrying.')
    write_json(out / 'voice.json', voice)
    return {'voice_id': voice['id'], 'created': True}


def render(config, key, out, duration, connect=None):
    if connect is None:
        import websocket
        connect = websocket.create_connection
    stop = threading.Event()
    sender = None
    ws = None
    events, pcm, transcript, errors = [], bytearray(), '', []
    usage, finalized = None, False
    try:
        ws = connect('wss://api.openai.com/v1/live/sessions',
            header=['Authorization: Bearer ' + key], timeout=20, suppress_origin=True)
        ws.send(json.dumps({'type': 'session.start', 'session': config}))
        ws.settimeout(1)
        deadline = time.monotonic() + 20
        started, closing = False, False
        while True:
            now = time.monotonic()
            if now >= deadline or (started and stop.is_set() and not closing):
                if started and not closing:
                    stop.set()
                    if sender:
                        sender.join(timeout=2)
                    ws.send(json.dumps({'type': 'session.close'}))
                    closing = True
                    deadline = time.monotonic() + 15
                else:
                    break
            try:
                raw = ws.recv()
            except Exception as exc:
                if type(exc).__name__ in ('WebSocketTimeoutException', 'TimeoutError'):
                    continue
                raise
            if not raw:
                break
            event = json.loads(raw)
            kind = event.get('type')
            if kind == 'session.output_audio.delta':
                pcm.extend(base64.b64decode(event['delta'], validate=True))
                continue
            # Keep provenance and usage, but scrub any accidental secret echo.
            events.append(json.loads(json.dumps(event).replace(key, '[REDACTED]')))
            if kind == 'session.started' and not started:
                started = True
                deadline = time.monotonic() + duration
                ws.send(json.dumps({'type': 'session.commentary.append', 'event_id': 'line_1',
                    'delegation_id': None, 'content': config['input'][0]['content'][0]['text']}))
                def silence():
                    while not stop.wait(0.1):
                        try:
                            ws.send(json.dumps({'type': 'session.input_audio.append',
                                'audio': base64.b64encode(bytes(4800)).decode()}))
                        except Exception as exc:
                            errors.append(safe_error(exc))
                            stop.set()
                            break
                sender = threading.Thread(target=silence, daemon=True)
                sender.start()
            elif kind == 'session.output_transcript.delta':
                transcript += event.get('delta', '')
            elif kind == 'error':
                errors.append({'type': 'APIError'})
                stop.set()
                if not started:
                    break
            elif kind == 'session.closed':
                usage, finalized = event.get('usage'), True
                break
    except Exception as exc:
        errors.append(safe_error(exc))
    finally:
        stop.set()
        if sender:
            sender.join(timeout=2)
        if ws:
            ws.close()
        write_json(out / 'events.json', events)
    if len(pcm) % 2:
        errors.append({'type': 'IncompletePCMSample'})
    elif pcm:
        with wave.open(str(out / 'raw.wav'), 'wb') as audio:
            audio.setnchannels(1)
            audio.setsampwidth(2)
            audio.setframerate(24000)
            audio.writeframes(pcm)
    peak = max((abs(x[0]) for x in struct.iter_unpack('<h', pcm)), default=0) if len(pcm) % 2 == 0 else 0
    return {'transcript': transcript.replace(key, '[REDACTED]'), 'peak_amplitude': peak, 'audio_seconds': len(pcm) / 48000,
        'session_finalized': finalized, 'usage': usage, 'errors': errors}


def make_config(voice, text, direction, language, model):
    if not str(voice.get('id', '')).startswith('voice_') or not voice.get('prompt'):
        raise ValueError('voice.json must contain the real saved ID and original prompt.')
    instruction = (f'Speak immediately in {language}. Say exactly this line once: '
        + json.dumps(text, ensure_ascii=False)
        + '. Do not translate, paraphrase, repeat, or add words. Then remain silent. '
        + 'Delivery direction: ' + direction)
    return {'model': model, 'instructions': voice['prompt'] + '\n' + instruction,
        'audio': {'format': {'type': 'audio/pcm', 'rate': 24000}, 'output': {'voice': {'id': voice['id']}}},
        'input': [{'type': 'message', 'role': 'developer', 'content': [{'type': 'input_text', 'text': instruction}]}],
        'store': False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['create', 'render'])
    parser.add_argument('--out', type=Path, required=True, help='New directory; existing directories are rejected.')
    parser.add_argument('--key-file', help='Secret file path, never the secret itself. Otherwise use environment.')
    parser.add_argument('--dry-run', action='store_true', help='Validate and write request without key/network.')
    parser.add_argument('--name')
    parser.add_argument('--prompt-file', type=Path)
    parser.add_argument('--voice-json', type=Path)
    parser.add_argument('--text-file', type=Path)
    parser.add_argument('--direction', default='Natural, clear and composed. No music or background noise.')
    parser.add_argument('--language', default='Japanese')
    parser.add_argument('--model', default='gpt-live-1', help='Render model; preserve user choice and verify compatibility.')
    parser.add_argument('--seconds', type=float, default=15, help='Active session window (5-60 seconds), then up to 15 seconds to close.')
    args = parser.parse_args()
    if not 5 <= args.seconds <= 60:
        parser.error('--seconds must be between 5 and 60')
    if args.mode == 'create':
        if not args.name or not args.prompt_file:
            parser.error('create requires --name and --prompt-file')
        prompt = args.prompt_file.read_text(encoding='utf-8').strip()
        if not prompt:
            parser.error('Voice description cannot be empty')
        payload = {'type': 'prompt', 'name': args.name, 'model': 'auto', 'prompt': prompt}
    else:
        if not args.voice_json or not args.text_file:
            parser.error('render requires --voice-json and --text-file')
        voice = json.loads(args.voice_json.read_text(encoding='utf-8'))
        # Strip only file-ending newlines. Preserve authored punctuation and internal whitespace.
        text = args.text_file.read_text(encoding='utf-8').rstrip('\r\n')
        if not text.strip():
            parser.error('Text cannot be empty')
        payload = make_config(voice, text, args.direction, args.language, args.model)
    key = None if args.dry_run else read_key(args.key_file)
    args.out.mkdir(parents=True, exist_ok=False)
    write_json(args.out / 'request.json', payload)
    if args.dry_run:
        print('Dry run: request saved; no key read and no network request.')
        return 0
    try:
        if args.mode == 'create':
            result = create_voice(payload, key, args.out)
            ok = True
        else:
            result = render(payload, key, args.out, args.seconds)
            result.update({'voice_id': voice['id'], 'text_requested': text, 'ai_generated': True,
                'transcript_exact_match': result['transcript'] == text, 'listening_review': 'pending_user'})
            raw = args.out / 'raw.wav'
            if raw.exists():
                result['sha256'] = hashlib.sha256(raw.read_bytes()).hexdigest()
            ok = result['session_finalized'] and result['transcript_exact_match'] and raw.exists() and result['peak_amplitude'] > 0 and not result['errors']
            result['technical_pass'] = bool(ok)
        write_json(args.out / 'result.json', result)
        print(json.dumps(result, ensure_ascii=False))
        return 0 if ok else 2
    except Exception as exc:
        error = safe_error(exc)
        write_json(args.out / 'error.json', error)
        print(json.dumps(error))
        return 2


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as exc:
        print(json.dumps(safe_error(exc)))
        sys.exit(2)
