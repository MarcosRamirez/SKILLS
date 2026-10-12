# save-image

Saves images pasted in VS Code Claude Code to disk automatically.

## How it works

When you paste an image in the Claude Code chat (VS Code), it's stored as base64
in the session transcript. A background hook reads the transcript on each prompt
submit and saves any new images to `~/Pictures/claude-images/`.

**Note:** There's a 1-prompt delay — the image is saved on the *next* message you
send after pasting.

## Install

**Plugin (recommended)**: the hook registers itself, no `settings.json` editing:

```
/plugin marketplace add MarcosRamirez/SKILLS
/plugin install save-image@marcosramirez-skills
```

**Ask your agent**: paste this into Claude Code:

> Install the save-image skill from https://github.com/MarcosRamirez/SKILLS/tree/master/skills/save-image
> into ~/.claude/skills/save-image (copy the whole folder) and register its UserPromptSubmit hook
> `scripts/save-image-hook.py` in ~/.claude/settings.json.

**Manual**: copy `skills/save-image/` to `~/.claude/skills/save-image/` and register the hook
as shown in [SKILL.md](SKILL.md#hook-registration).

> Requires Python 3 on your PATH. Switching from a manual install to the plugin?
> Remove the hook entry from `settings.json` first, or images get saved twice.

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

- `SKILL.md` — Claude behavior spec
- `scripts/save-image-hook.py` — UserPromptSubmit hook (auto-save)
- `hooks/hooks.json` — registers the hook automatically when installed as a plugin
- `.claude-plugin/plugin.json` — plugin manifest
