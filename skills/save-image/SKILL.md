---
name: save-image
description: >
  Saves images pasted in Claude Code (VS Code) to disk. A background hook
  auto-saves images from the session transcript on the next prompt after paste.
  Manual trigger: /save-image or "save this image" / "guardar imagen" — Claude
  saves the image immediately using Python + base64. Use when user pastes a
  screenshot, diagram, or photo and wants it persisted to the filesystem.
license: MIT
compatibility: Requires Python 3. Auto-save hook designed for Claude Code (VS Code).
metadata:
  author: Marcos Ramírez
  homepage: https://marcosramirez.info
  blog: https://blog.marcosramirez.info
  dev: https://marcosramirez.dev
  version: "1.0.0"
allowed-tools: Bash Read
---

## How it works

Images pasted in Claude Code enter the session as base64 in the conversation
transcript (JSONL). A `UserPromptSubmit` hook reads the transcript on each
prompt, decodes any unsaved images, and writes them to disk. State is tracked
to prevent duplicates.

**Note:** There is a 1-prompt delay — the image saves when you send the *next*
message after pasting. This is unavoidable: the hook fires before the current
message is written to transcript.

## Auto-save (hook)

The hook at `scripts/save-image-hook.py` runs on every prompt submit.

- Reads `transcript_path` from hook stdin
- Scans transcript JSONL for user messages with `{"type":"image","source":{"type":"base64",...}}`
- Skips entries already tracked in `~/.claude/save-image-state.json`
- Decodes and writes each new image to `~/Pictures/claude-images/`
- Filename format: `YYYY-MM-DD_HH-MM-SS_{line}_{index}.{ext}`
- Returns `additionalContext` so Claude reports the saved path

## Manual trigger (/save-image)

When user says `/save-image`, "save this image", or "guardar imagen":

1. Ask for a filename if not specified. Default:
   `~/Pictures/claude-images/YYYY-MM-DD_HH-MM-SS.png`
2. Create the output directory if needed:
   ```bash
   python -c "import os; os.makedirs(os.path.expanduser('~/Pictures/claude-images'), exist_ok=True)"
   ```
3. Save the image using Bash:
   ```bash
   python -c "import base64, os; open(r'FULL_PATH', 'wb').write(base64.b64decode('BASE64_DATA'))"
   ```
4. Confirm: "Image saved to: PATH"

> Claude cannot extract raw bytes from images it sees visually. The manual
> trigger works best when the image is a file attachment (use Read to get the
> path) or when the user provides the base64 data directly.

## Edge cases

- **No transcript path in stdin**: hook exits silently (no-op).
- **Corrupt JSONL line**: line is marked as seen and skipped.
- **Duplicate paste**: state file prevents re-saving same transcript line.
- **Multiple images in one message**: each image gets its own file (`_{index}` suffix).
- **Non-base64 image source (URL type)**: skipped — only `"type":"base64"` supported.

## Hook registration

**Installed as a plugin?** Nothing to do: `hooks/hooks.json` registers the hook
automatically. Do not also add it to `settings.json`, or it runs twice.

**Manual install only.** Add to `~/.claude/settings.json`, replacing `<path-to>` with the
folder where you copied the skill:

```json
"hooks": {
  "UserPromptSubmit": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "python \"<path-to>/save-image/scripts/save-image-hook.py\"",
          "timeout": 10
        }
      ]
    }
  ]
}
```

## State file

`~/.claude/save-image-state.json` — tracks processed transcript lines.
Format: `{"saved": ["transcript_path::line_index", ...]}`.
Delete this file to reprocess all images from existing transcripts.
