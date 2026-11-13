"""Offline behavioral tests. Never contacts OpenAI or reads a real key."""
import base64
import contextlib
import io
import json
from pathlib import Path
import struct
import sys
import tempfile
import unittest
from unittest.mock import patch
import urllib.error
import wave
import voice


class FakeSocket:
    def __init__(self, text='おはようございます。', closed=True, silent=False):
        pcm = struct.pack('<h', 0 if silent else 1200) * 2400
        self.events = [ {'type': 'session.started'},
            {'type': 'session.output_audio.delta', 'delta': base64.b64encode(pcm).decode()},
            {'type': 'session.output_transcript.delta', 'delta': text}]
        if closed:
            self.events.append({'type': 'session.closed', 'usage': {'seconds': 0.1}})
        self.sent, self.closed = [], False
    def send(self, value):
        self.sent.append(json.loads(value))
    def settimeout(self, seconds):
        pass
    def recv(self):
        return json.dumps(self.events.pop(0)) if self.events else ''
    def close(self):
        self.closed = True


class VoiceTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.identity = {'object': 'audio.voice', 'id': 'voice_test', 'prompt': 'Original adult voice'}
    def tearDown(self):
        self.tmp.cleanup()
    def config(self):
        return voice.make_config(self.identity, 'おはようございます。', 'calm', 'Japanese', 'gpt-live-1')
    def run_cli(self, args):
        with patch.object(sys, 'argv', ['voice.py'] + args), contextlib.redirect_stdout(io.StringIO()):
            return voice.main()
    def test_dry_run_never_reads_key_or_network(self):
        prompt = self.root/'prompt.txt'
        prompt.write_text('Original adult voice')
        with patch.object(voice, 'read_key', side_effect=AssertionError('key read')):
            self.assertEqual(self.run_cli(['create', '--name', 'Test', '--prompt-file', str(prompt),
                '--out', str(self.root/'dry'), '--dry-run']), 0)
        self.assertFalse((self.root/'dry/voice.json').exists())
    def test_existing_output_not_overwritten(self):
        prompt = self.root/'prompt.txt'; prompt.write_text('Adult voice')
        with self.assertRaises(FileExistsError):
            self.run_cli(['create', '--name', 'Test', '--prompt-file', str(prompt),
                '--out', str(self.root), '--dry-run'])
    def test_create_retains_actual_id(self):
        response = io.BytesIO(json.dumps(self.identity).encode())
        with patch.object(voice.urllib.request, 'urlopen', return_value=response) as call:
            result = voice.create_voice({'type': 'prompt'}, 'fake-secret', self.root)
        self.assertEqual(call.call_count, 1)
        self.assertEqual(result['voice_id'], 'voice_test')
        self.assertEqual(json.loads((self.root/'voice.json').read_text()), self.identity)
    def test_create_timeout_not_retried(self):
        with patch.object(voice.urllib.request, 'urlopen', side_effect=TimeoutError('fake-secret')) as call:
            with self.assertRaises(TimeoutError):
                voice.create_voice({}, 'fake-secret', self.root)
        self.assertEqual(call.call_count, 1)
        self.assertNotIn('fake-secret', str(voice.safe_error(TimeoutError('fake-secret'))))
    def test_render_saves_audio_transcript_usage_and_closes(self):
        ws = FakeSocket()
        result = voice.render(self.config(), 'fake-secret', self.root, 5, connect=lambda *a, **k: ws)
        self.assertTrue(result['session_finalized'])
        self.assertEqual(result['transcript'], 'おはようございます。')
        self.assertEqual(result['usage']['seconds'], .1)
        self.assertTrue(ws.closed)
        self.assertEqual(ws.sent[0]['type'], 'session.start')
        self.assertEqual(ws.sent[1]['type'], 'session.commentary.append')
        with wave.open(str(self.root/'raw.wav')) as audio:
            self.assertEqual((audio.getnchannels(), audio.getsampwidth(), audio.getframerate()), (1, 2, 24000))
            self.assertEqual(audio.getnframes(), 2400)
    def test_disconnect_does_not_claim_final_usage(self):
        ws = FakeSocket(closed=False)
        result = voice.render(self.config(), 'fake-secret', self.root, 5, connect=lambda *a, **k: ws)
        self.assertFalse(result['session_finalized'])
        self.assertIsNone(result['usage'])
    def test_silence_detectable(self):
        ws = FakeSocket(silent=True)
        result = voice.render(self.config(), 'fake-secret', self.root, 5, connect=lambda *a, **k: ws)
        self.assertEqual(result['peak_amplitude'], 0)
    def test_api_failure_does_not_echo_headers(self):
        def fail(*args, **kwargs):
            raise RuntimeError('Authorization: Bearer fake-secret')
        result = voice.render(self.config(), 'fake-secret', self.root, 5, connect=fail)
        self.assertTrue(result['errors'])
        self.assertNotIn('fake-secret', json.dumps(result))
        self.assertFalse((self.root/'raw.wav').exists())
    def test_deadline_requests_close_and_waits_for_usage(self):
        class DeadlineSocket(FakeSocket):
            def recv(self):
                if self.events:
                    self.events.clear()
                    return json.dumps({'type': 'session.started'})
                if any(e['type'] == 'session.close' for e in self.sent):
                    return json.dumps({'type': 'session.closed', 'usage': {'seconds': 5}})
                raise TimeoutError()
        ws = DeadlineSocket()
        clock = iter(range(100))
        with patch.object(voice.time, 'monotonic', side_effect=lambda: next(clock)):
            result = voice.render(self.config(), 'fake-secret', self.root, 5, connect=lambda *a, **k: ws)
        self.assertTrue(result['session_finalized'])
        self.assertEqual(sum(e['type'] == 'session.close' for e in ws.sent), 1)
        self.assertTrue(ws.closed)

    def test_render_cli_marks_mismatch_as_failure(self):
        identity = self.root/'voice.json'; voice.write_json(identity, self.identity)
        text = self.root/'line.txt'; text.write_text('おはようございます。\n')
        def fake_render(config, key, out, duration):
            return voice_render(config, key, out, duration, connect=lambda *a, **k: FakeSocket(text='Wrong line'))
        voice_render = voice.render
        with patch.object(voice, 'read_key', return_value='fake-secret'), patch.object(voice, 'render', side_effect=fake_render):
            code = self.run_cli(['render', '--voice-json', str(identity), '--text-file', str(text), '--out', str(self.root/'take')])
        self.assertEqual(code, 2)
        result = json.loads((self.root/'take/result.json').read_text())
        self.assertFalse(result['technical_pass'])
        self.assertEqual(result['text_requested'], 'おはようございます。')

if __name__ == '__main__':
    unittest.main()
