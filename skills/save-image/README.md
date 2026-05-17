# save-image

Saves images pasted in VS Code Claude Code to disk automatically.

## How it works

When you paste an image in the Claude Code chat (VS Code), it's stored as base64
in the session transcript. A background hook reads the transcript on each prompt
submit and saves any new images to `~/Pictures/claude-images/`.

**Note:** There's a 1-prompt delay — the image is saved on the *next* message you
send after pasting.

## Usage

### Automatic
Just paste an image and send your next message. Claude will confirm where it was saved.

### Manual
```
/save-image
save this image
guardar imagen
guardar esta imagen as screenshot.png
```

## Output

Files land in `C:\Users\<you>\Pictures\claude-images\` with timestamp filenames:
```
2026-05-17_14-30-00_3_0.png
```

## Files

- `src/hooks/save-image-hook.py` — UserPromptSubmit hook (auto-save)
- `skills/save-image/SKILL.md` — Claude behavior spec
