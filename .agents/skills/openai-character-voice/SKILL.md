---
name: openai-character-voice
description: >-
  Create original OpenAI character Voice IDs, render audition WAVs, and batch-generate
  short Japanese character voice clips for Hoshimi Hospital using the fixed prefix-matchable
  runner `tools/voice_runner/hoshimi-voice`. Use whenever designing character voices,
  re-auditioning voice candidates, or generating short voice clip packs.
---

# Hoshimi Hospital OpenAI Character Voice Pipeline

Always read root [AGENTS.md](../../../AGENTS.md), [character_voice_ids.md](../../../docs/character_voice_ids.md), and the portable skill reference [docs/skills/openai-character-voice/SKILL.md](../../../docs/skills/openai-character-voice/SKILL.md) first.

## Mandatory Execution Rule (Prefix-Matchable Fixed Runner)

To ensure the user's **"Always Allow"** terminal permission grant works permanently without re-prompting on every new character or batch:

1. **NEVER** write one-off Python runner scripts in `scratch/` or invoke `python3 <changing_script.py>` outside the sandbox.
2. **NEVER** wrap the unsandboxed command with `env`, `PYTHONPATH=...`, `$VAR`, `~`, `$(...)`, or `&&` command chains.
3. **ALWAYS** split preparation and execution into two steps:
   - **Step 1 (Standard Sandbox, `BypassSandbox: false`)**: Write the JSON job manifest to a literal path (e.g. `/private/tmp/hoshimi_voice_job.json`) using `write_file`, and optionally validate with:
     ```sh
     tools/voice_runner/hoshimi-voice run /private/tmp/hoshimi_voice_job.json --dry-run
     ```
   - **Step 2 (Unsandboxed Network Call, `BypassSandbox: true`)**: Run **only** the fixed executable + `run` subcommand with a literal path:
     ```sh
     tools/voice_runner/hoshimi-voice run /private/tmp/hoshimi_voice_job.json
     ```
   `tools/voice_runner/hoshimi-voice` automatically uses `.venv/bin/python` (with `websocket-client` pre-installed) and reads `~/.config/hoshimi/openai-api-key` internally without echoing or exposing secrets.

See [tools/voice_runner/README.md](../../../tools/voice_runner/README.md) for the `candidates` and `clips` JSON schema and offline `metrics` subcommand.

## Key Acoustic & Safety Guidelines

- **Reuse Approved Voice IDs**: Check [character_voice_ids.md](../../../docs/character_voice_ids.md) first. Never create a new Voice ID when rendering lines for an already approved character; use a `"clips"` job pointing to `research/voice_candidates/<tag>/voice.json`.
- **No Auto-Retry on Voice Creation**: `POST /v1/audio/voices` is never auto-retried on timeout/error. Reconcile before creating a new `create_dir_name`.
- **Neutral `voice_name`**: Use neutral acoustic names (e.g. `Hoshimi Bell Bright Girl Soprano v7`); avoid franchise character names in `voice_name` (which can trigger HTTP 400).
- **Japanese Girlish Soprano Tuning**: Words like `Yamato-nadeshiko`, `warm`, `tender`, `caring`, `poise`, or `open resonance` pull OpenAI prompt voices down into `240–272 Hz`. For bright young girlish voices (`320–365 Hz`, `hf_clarity >= 0.26`), use `High-pitched / Very high-pitched, cute/petite, crystal-clear girlish soprano` with `light, crisp vocal weight` and `bright, ringing silver-bell resonance`, then verify with `tools/voice_runner/hoshimi-voice metrics <wav>`.
- **Punctuation in `text`**: GPT-Live (`gpt-live-1`) emits ASCII `?` rather than full-width `？` in `output_transcript.delta`; use `?` in Japanese question prompts if exact transcript matching is required.
