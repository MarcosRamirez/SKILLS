#!/usr/bin/env python3
"""Report writing-rule violations in Castilian text: the double tilde, the simple tilde
used as "approximately", the em dash and the en dash.

Usage: check_writing.py FILE [FILE ...]      ('-' reads stdin)
Exit:  0 nothing found, 1 findings, 2 usage or unreadable file.

Skipped on purpose, so code does not raise false positives: fenced code blocks (``` and ~~~),
inline code spans, URLs, and tilde paths such as ~/dir or ~user/dir.
"""
import re
import sys

FORBIDDEN = {
    "\u2248": "double tilde (use ± for approximate amounts)",
    "~": "tilde used as approximately (use ± for approximate amounts)",
    "\u2014": "em dash (use comma, period, colon, parentheses or rewrite)",
    "\u2013": "en dash (use comma, period, colon, parentheses or rewrite)",
}

FENCE = re.compile(r"^\s*(`{3,}|~{3,})")
# Order matters: inline code and URLs first, then paths, then Markdown strikethrough.
MASKS = [
    re.compile(r"`[^`\n]*`"),
    re.compile(r"[a-zA-Z][a-zA-Z0-9+.-]*://\S+"),
    re.compile(r"(?<![\w])~[\w.-]*[/\\]\S*"),
    re.compile(r"~~[^~\n]+~~"),
]


def mask(line):
    """Replace skipped spans with spaces, keeping columns."""
    for pattern in MASKS:
        line = pattern.sub(lambda m: " " * len(m.group(0)), line)
    return line


def scan(text):
    findings = []
    fence = None
    for number, line in enumerate(text.splitlines(), 1):
        match = FENCE.match(line)
        if fence:
            if match and match.group(1)[0] == fence[0] and len(match.group(1)) >= len(fence):
                fence = None
            continue
        if match:
            fence = match.group(1)
            continue
        for column, char in enumerate(mask(line), 1):
            if char in FORBIDDEN:
                findings.append((number, column, char, FORBIDDEN[char]))
    return findings


def main(argv):
    if not argv:
        print("usage: check_writing.py FILE [FILE ...]  ('-' reads stdin)", file=sys.stderr)
        return 2
    status = 0
    for path in argv:
        try:
            if path == "-":
                text = sys.stdin.buffer.read().decode("utf-8")
            else:
                with open(path, encoding="utf-8") as handle:
                    text = handle.read()
        except (OSError, UnicodeDecodeError) as error:
            print(f"{path}: cannot read ({error})", file=sys.stderr)
            return 2
        name = "<stdin>" if path == "-" else path
        for number, column, char, reason in scan(text):
            print(f"{name}:{number}:{column}: {char} {reason}")
            status = 1
    return status


if __name__ == "__main__":
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    sys.exit(main(sys.argv[1:]))
