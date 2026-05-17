#!/usr/bin/env python3
import sys
import json
import os
import base64
import datetime


def main():
    raw = sys.stdin.read()
    try:
        data = json.loads(raw)
    except Exception:
        sys.exit(0)

    transcript_path = data.get("transcript_path", "")
    if not transcript_path or not os.path.exists(transcript_path):
        sys.exit(0)

    state_path = os.path.expanduser("~/.claude/save-image-state.json")
    state = set()
    if os.path.exists(state_path):
        try:
            state = set(json.loads(open(state_path, encoding="utf-8").read()).get("saved", []))
        except Exception:
            pass

    out_dir = os.path.expanduser("~/Pictures/claude-images")
    os.makedirs(out_dir, exist_ok=True)

    saved = []
    try:
        with open(transcript_path, encoding="utf-8") as f:
            lines = f.readlines()
    except Exception:
        sys.exit(0)

    for i, line in enumerate(lines):
        key = f"{transcript_path}::{i}"
        if key in state:
            continue
        try:
            entry = json.loads(line)
        except Exception:
            state.add(key)
            continue

        if entry.get("type") != "user":
            state.add(key)
            continue

        content = entry.get("message", {}).get("content", [])
        if not isinstance(content, list):
            state.add(key)
            continue

        for j, item in enumerate(content):
            if item.get("type") != "image":
                continue
            src = item.get("source", {})
            if src.get("type") != "base64":
                continue
            media = src.get("media_type", "image/png")
            ext = media.split("/")[-1].replace("jpeg", "jpg")
            ts = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
            fname = f"{ts}_{i}_{j}.{ext}"
            fpath = os.path.join(out_dir, fname)
            try:
                with open(fpath, "wb") as img:
                    img.write(base64.b64decode(src["data"]))
                saved.append(fpath)
            except Exception:
                pass

        state.add(key)

    try:
        with open(state_path, "w", encoding="utf-8") as f:
            json.dump({"saved": list(state)}, f)
    except Exception:
        pass

    if saved:
        paths = "\n".join(f"  - {p}" for p in saved)
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "UserPromptSubmit",
                "additionalContext": f"[save-image] Images saved to disk:\n{paths}"
            }
        }))


if __name__ == "__main__":
    main()
