#!/usr/bin/env python3
"""Check the living documents: relative links resolve and no link points to a superseded ADR.
Links from files inside an `adr/` folder are history (the index, Supersedes lines) and are allowed.

Install at .github/scripts/check-docs.py (the project root is two folders up).

Usage: python3 .github/scripts/check-docs.py [file ...]
Exit 0 when clean, 1 with one `path:line: message` per finding.

Which documents: the files given as arguments; else the globs in the env var
DOCS_CHECK_FILES (comma or newline separated, relative to the project root);
else DEFAULT_PATTERNS below. Missing globs are ignored. Feature specs are left
out on purpose: they carry history.
An ADR is any .md file inside a folder named `adr` whose `Status:` starts with Superseded.
"""
import os
import re
import sys
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_PATTERNS = [
    "README.md", "AGENTS.md", "CLAUDE.md", "docs/**/*.md",
    "spec/constitution/*.md", "spec/INVENTORY.md", "spec/POSTMORTEMS.md",
]
FENCE = re.compile(r"^\s*(`{3,}|~{3,})")
CODE_SPAN = re.compile(r"(`+)(?:(?!\1).)+?\1")
LINK = re.compile(r"\[[^\]]*\]\(\s*<?([^)\s>]+)>?(?:\s+\"[^\"]*\")?\s*\)")
SKIP = re.compile(r"^(?:[a-zA-Z][a-zA-Z0-9+.-]*:|#|//)")


def documents(args):
    if args:
        return [Path(a).resolve() for a in args]
    configured = os.environ.get("DOCS_CHECK_FILES", "")
    patterns = [p.strip() for p in re.split(r"[,\n]", configured) if p.strip()] or DEFAULT_PATTERNS
    found = []
    for pattern in patterns:
        found += sorted(ROOT.glob(pattern))
    return found


def is_adr(target):
    return target.suffix == ".md" and target.parent.name == "adr" and target.name != "README.md"


def superseded(adr):
    try:
        for line in adr.read_text(encoding="utf-8").splitlines():
            m = re.match(r"^\s*(?:\*\*)?Status:?(?:\*\*)?:?\s*(.*)$", line)
            if m:
                return m.group(1).strip().startswith("Superseded")
    except OSError:
        pass
    return False


def links(path):
    """Yield (line number, target) outside fenced code and inline code spans."""
    fence = None
    for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        m = FENCE.match(line)
        if fence:
            if m and m.group(1)[0] == fence[0] and len(m.group(1)) >= len(fence):
                fence = None
            continue
        if m:
            fence = m.group(1)
            continue
        for found in LINK.finditer(CODE_SPAN.sub("", line)):
            yield n, found.group(1)


def main(args):
    findings = []
    for doc in documents(args):
        try:
            shown = doc.relative_to(ROOT).as_posix()
        except ValueError:
            shown = doc.as_posix()
        if not doc.is_file():
            findings.append(f"{shown}:1: document not found")
            continue
        for n, raw in links(doc):
            if SKIP.match(raw):
                continue
            rel = unquote(raw.split("#", 1)[0])
            if not rel:
                continue
            target = (doc.parent / rel).resolve()
            if not target.exists():
                findings.append(f"{shown}:{n}: broken link: {raw}")
            elif is_adr(target) and superseded(target) and doc.parent.name != "adr":
                findings.append(f"{shown}:{n}: link to superseded ADR: {raw}")
    for f in findings:
        print(f)
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
