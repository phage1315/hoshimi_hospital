# Hoshimi Voice Runner (`tools/voice_runner/hoshimi-voice`)

Dedicated fixed-prefix CLI for OpenAI character voice creation, auditioning, and batch clip-pack rendering in **Hoshimi Hospital**.

## Why This Runner Exists (Auto-Approval Rule)

Previously, running temporary scripts via `python3 /path/to/different_script.py` or prefixing `PYTHONPATH=...` caused AI coding agents (Antigravity / Cursor / Claude / Codex) to re-prompt the user for terminal approval on every run, because generic `python3` invocations with changing script filenames or shell wrappers defeat binary+subcommand prefix matching.

By standardizing on a single executable binary + subcommand:

```sh
tools/voice_runner/hoshimi-voice run /private/tmp/hoshimi_voice_job.json
```

1. **Step 1 (Inside Sandbox)**: Write the JSON job specification file (e.g. `/private/tmp/hoshimi_voice_job.json` or `<scratch>/voice_job.json`) and optionally verify with `--dry-run`.
2. **Step 2 (Outside Sandbox — Single Prefix-Matchable Command)**: Invoke `tools/voice_runner/hoshimi-voice run <literal_json_path>` directly — **no** `python3`, **no** `env`/`PYTHONPATH`, **no** `&&` chains, **no** `$VAR` or `~` expansions (`runner.py` reads `~/.config/hoshimi/openai-api-key` internally by default).
3. Once the user clicks **"Always Allow" (始终允许)** once on `tools/voice_runner/hoshimi-voice run ...` (or adds `tools/voice_runner/hoshimi-voice` to Settings → Command Allowlist), all future voice jobs match the exact prefix `tools/voice_runner/hoshimi-voice run` and run without prompting again.

## Dependencies

Uses the repository's `.venv/bin/python` automatically (`websocket-client>=1.8.0` and `numpy>=2.0.0`, listed in `tools/requirements.txt`). Contains `.gdignore` so Godot ignores this directory.

## Job JSON Format

```json
{
  "workers": 2,
  "report_out": "/private/tmp/hoshimi_voice_report.json",
  "candidates": [
    {
      "actor_id": "nurse_hiroko",
      "version": "v8",
      "display_name": "杉村 弘子",
      "voice_name": "Hoshimi Bell Bright Girl Soprano v8",
      "zh_desc": "清亮透澈的银铃系少女高音",
      "prompt": "An original young adult Japanese female voice around age nineteen...",
      "sample_text": "おはようございます、坂口先生。",
      "sample_direction": "Very high-pitched, crisp, crystal-clear girlish soprano. No music or background noise.",
      "seconds": 14,
      "max_takes": 2
    }
  ],
  "clips": [
    {
      "clip_id": "ohayou",
      "voice_json": "research/voice_candidates/nurse_haru_v4/voice.json",
      "out_dir": "research/voice_candidates/nurse_haru_v4/clips/ohayou_v1",
      "final_wav_name": "ohayou.wav",
      "text": "おはようございます、坂口先生。",
      "direction": "Sweet, bright girlish morning greeting. No music or background noise.",
      "seconds": 12,
      "max_takes": 2
    }
  ]
}
```

## Subcommands

- `tools/voice_runner/hoshimi-voice run <job.json> [--dry-run]` — Execute candidate creation/auditioning and/or clip rendering from a JSON manifest.
- `tools/voice_runner/hoshimi-voice metrics <wav_file> [...]` — Measure offline acoustic metrics (`f0_median_hz`, `hf_clarity`, `peak_dbfs`, `duration_seconds`) inside the sandbox.
- `tools/voice_runner/hoshimi-voice create ...` / `render ...` — Direct passthroughs to `docs/skills/openai-character-voice/scripts/voice.py`.
