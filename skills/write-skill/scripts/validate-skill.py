#!/usr/bin/env python3
"""Validate an Agent Skill folder against the Agent Skills standard and this repo's budgets.

Checks, in two severities:

- errors (the standard): SKILL.md and its frontmatter exist, the name matches its folder and the
  naming rules, the description is present and at most 1024 characters, `metadata.version` is SemVer
  when present, `SKILL.md` stays under 500 lines and ~5000 tokens, relative links resolve, and
  `references/` holds files, not folders.
- warnings (this repo's target): the body over 100 lines or 800 words, the description over 500
  characters, a reference over 150 lines or linked from nowhere, duplicated headings, leftover TODO.

`npx skills-ref validate <folder>` remains the standard's own validator; this one adds the budgets
and the structure rules, so a skill ships when both pass.

Usage:
  python3 validate-skill.py <skill-dir> [--soft-lines N] [--soft-words N]
                            [--strict] [--json]

Exit: 0 clean, 1 with errors (or with warnings under --strict), 64 on a usage error.
"""
import argparse
import json
import math
import re
import sys
from pathlib import Path
from urllib.parse import unquote

NAME = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
SEMVER = re.compile(
    r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$"
)
LINK = re.compile(r"\[[^\]]*\]\(\s*<?([^)\s>]+)>?(?:\s+\"[^\"]*\")?\s*\)")
FENCE = re.compile(r"^\s*(`{3,}|~{3,})")
CODE_SPAN = re.compile(r"(`+)(?:(?!\1).)+?\1")
EXTERNAL = re.compile(r"^(?:[a-zA-Z][a-zA-Z0-9+.-]*:|#|//)")
HEADING = re.compile(r"^(#{1,6})\s+(.*\S)\s*$")

HARD_LINES = 500
HARD_TOKENS = 5000
HARD_DESCRIPTION = 1024
SOFT_DESCRIPTION = 500
SOFT_REFERENCE_LINES = 150


def read(path):
    return path.read_text(encoding="utf-8", errors="replace").replace("\r\n", "\n")


def split_frontmatter(text):
    """Return (header lines, body, body start line) or (None, text, 0)."""
    lines = text.split("\n")
    if not lines or lines[0].strip() != "---":
        return None, text, 0
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            return lines[1:i], "\n".join(lines[i + 1:]), i + 2
    return None, text, 0


def parse_fields(header):
    """A small YAML subset: scalars, folded/literal blocks and one level of metadata."""
    fields, meta = {}, {}
    key = None
    block = None
    buf = []
    parent = None

    def store():
        nonlocal key, block, parent
        if key is None:
            return
        if block == "folded":
            value = " ".join(part.strip() for part in buf).strip()
        elif block == "literal":
            value = "\n".join(buf).strip()
        else:
            value = " ".join(part.strip() for part in buf).strip()
        fields[key] = value.strip('"').strip("'")
        key, block = None, None
        buf.clear()
        parent = None

    for raw in header:
        if not raw.strip():
            continue
        indented = raw[:1] in (" ", "\t")
        line = raw.strip()
        if indented and key is not None:
            buf.append(line)
            continue
        if indented and parent == "metadata":
            found = re.match(r"^([A-Za-z0-9_.-]+):\s*(.*)$", line)
            if found:
                meta[found.group(1)] = found.group(2).strip().strip('"').strip("'")
            continue
        store()
        found = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if not found:
            parent = None
            continue
        name, value = found.group(1), found.group(2).strip()
        if value in (">", ">-", ">+", "|", "|-", "|+"):
            key, block = name, ("folded" if value.startswith(">") else "literal")
            continue
        if name == "metadata" and not value:
            parent = "metadata"
            continue
        key = name
        buf.append(value)
    store()
    return fields, meta


def body_lines(body):
    return len(body.rstrip("\n").split("\n")) if body.strip() else 0


def links_in(text):
    """Yield (line number, target) outside fenced code and inline code spans."""
    fence = None
    for number, line in enumerate(text.split("\n"), 1):
        fence_match = FENCE.match(line)
        if fence:
            if fence_match and fence_match.group(1)[0] == fence[0] and len(fence_match.group(1)) >= len(fence):
                fence = None
            continue
        if fence_match:
            fence = fence_match.group(1)
            continue
        for found in LINK.finditer(CODE_SPAN.sub("", line)):
            yield number, found.group(1)


def headings_in(body):
    fence = None
    for line in body.split("\n"):
        fence_match = FENCE.match(line)
        if fence:
            if fence_match and fence_match.group(1)[0] == fence[0] and len(fence_match.group(1)) >= len(fence):
                fence = None
            continue
        if fence_match:
            fence = fence_match.group(1)
            continue
        found = HEADING.match(line)
        if found:
            yield found.group(1), found.group(2).strip()


class Report:
    def __init__(self):
        self.findings = []

    def add(self, severity, where, message):
        self.findings.append((severity, where, message))

    def error(self, where, message):
        self.add("error", where, message)

    def warning(self, where, message):
        self.add("warning", where, message)

    def count(self, severity):
        return sum(1 for item in self.findings if item[0] == severity)


def validate(skill_dir, soft_lines, soft_words, report):
    skill_md = skill_dir / "SKILL.md"
    if not skill_dir.is_dir():
        report.error(str(skill_dir), "not a directory")
        return None
    if not skill_md.is_file():
        report.error(str(skill_md), "SKILL.md not found")
        return None

    text = read(skill_md)
    header, body, body_start = split_frontmatter(text)
    if header is None:
        report.error("SKILL.md:1", "no YAML frontmatter (the file must start with --- and close it)")
        return None

    fields, meta = parse_fields(header)
    name = fields.get("name", "")
    description = fields.get("description", "")
    version = meta.get("version", "")

    directory = skill_dir.resolve().name
    if not name:
        report.error("SKILL.md:1", "missing name")
    else:
        if name != directory:
            report.error("SKILL.md:1", f"name '{name}' does not match the folder name '{directory}'")
        if len(name) > 64:
            report.error("SKILL.md:1", f"name is {len(name)} characters, the maximum is 64")
        if not NAME.match(name):
            report.error("SKILL.md:1", f"name '{name}' must be lowercase letters, digits and single hyphens")

    if not description:
        report.error("SKILL.md:1", "missing description")
    elif len(description) > HARD_DESCRIPTION:
        report.error("SKILL.md:1", f"description is {len(description)} characters, the maximum is {HARD_DESCRIPTION}")
    elif len(description) > SOFT_DESCRIPTION:
        report.warning("SKILL.md:1", f"description is {len(description)} characters, the target is {SOFT_DESCRIPTION}")

    if not version:
        report.warning("SKILL.md:1", "no metadata.version (the standard does not require one)")
    elif not SEMVER.match(version):
        report.error("SKILL.md:1", f"metadata.version '{version}' is not SemVer")

    total_lines = len(text.rstrip("\n").split("\n"))
    if total_lines > HARD_LINES:
        report.error("SKILL.md:1", f"SKILL.md has {total_lines} lines, the standard's maximum is {HARD_LINES}")
    lines = body_lines(body)
    if lines > soft_lines:
        report.warning("SKILL.md", f"body has {lines} lines, the target is {soft_lines}")
    words = len(body.split())
    if words > soft_words:
        report.warning("SKILL.md", f"body has {words} words, the target is {soft_words}")
    tokens = math.ceil(len(body) / 4)
    if tokens > HARD_TOKENS:
        report.error("SKILL.md", f"body is ~{tokens} estimated tokens, the recommended maximum is {HARD_TOKENS}")

    linked = set()
    for number, target in links_in(body):
        where = f"SKILL.md:{body_start + number - 1}"
        if EXTERNAL.match(target):
            continue
        if "\\" in target:
            report.warning(where, f"backslashes in path: {target}")
        raw = target.split("#", 1)[0]
        if not raw:
            continue
        if raw.startswith("/") or re.match(r"^[A-Za-z]:", raw):
            report.warning(where, f"absolute path: {target}")
            continue
        resolved = (skill_dir / unquote(raw)).resolve()
        try:
            resolved.relative_to(skill_dir.resolve())
        except ValueError:
            report.warning(where, f"path leaves the skill folder: {target}")
        if not resolved.exists():
            report.error(where, f"broken link: {target}")
        linked.add(resolved)

    references = skill_dir / "references"
    if references.is_dir():
        for child in sorted(references.iterdir()):
            if child.is_dir():
                report.error(f"references/{child.name}", "no folders inside references/: keep one level deep")
        for file in sorted(references.glob("*.md")):
            shown = f"references/{file.name}"
            reference_text = read(file)
            count = body_lines(reference_text)
            if count > SOFT_REFERENCE_LINES:
                report.warning(shown, f"{count} lines, the target is {SOFT_REFERENCE_LINES}")
            if file.resolve() not in linked:
                report.warning(shown, "not linked from SKILL.md: dead weight unless something else reads it")
            for number, target in links_in(reference_text):
                if EXTERNAL.match(target):
                    continue
                raw = target.split("#", 1)[0]
                if not raw or raw.startswith("/") or re.match(r"^[A-Za-z]:", raw):
                    continue
                target_path = (file.parent / unquote(raw)).resolve()
                if target_path.suffix == ".md" and target_path.name != "SKILL.md":
                    report.error(f"{shown}:{number}", f"a reference links to another reference: {target}")

    seen = {}
    for level, title in headings_in(body):
        key = (level, title.lower())
        seen[key] = seen.get(key, 0) + 1
        if seen[key] == 2:
            report.warning("SKILL.md", f"duplicate heading: {title}")

    documents = [("SKILL.md", body)]
    if references.is_dir():
        documents += [(f"references/{file.name}", read(file)) for file in sorted(references.glob("*.md"))]
    for marker in ("TODO", "TBD", "FIXME"):
        for where, haystack in documents:
            if marker in haystack:
                report.warning(where, f"leftover {marker}")

    reference_count = len(list(references.glob("*.md"))) if references.is_dir() else 0
    return {"lines": total_lines, "body_lines": lines, "words": words, "tokens": tokens, "references": reference_count}


def main(argv):
    parser = argparse.ArgumentParser(add_help=True, description="Validate an Agent Skill folder.")
    parser.add_argument("skill", help="path to the skill folder")
    parser.add_argument("--soft-lines", type=int, default=100, help="body line target (default 100)")
    parser.add_argument("--soft-words", type=int, default=800, help="body word target (default 800)")
    parser.add_argument("--strict", action="store_true", help="warnings fail the run")
    parser.add_argument("--json", action="store_true", help="machine-readable output")
    try:
        args = parser.parse_args(argv)
    except SystemExit:
        return 64

    report = Report()
    summary = validate(Path(args.skill).resolve(), args.soft_lines, args.soft_words, report)
    errors, warnings = report.count("error"), report.count("warning")

    if args.json:
        print(json.dumps({
            "skill": str(Path(args.skill)),
            "errors": [{"where": w, "message": m} for s, w, m in report.findings if s == "error"],
            "warnings": [{"where": w, "message": m} for s, w, m in report.findings if s == "warning"],
            "summary": summary or {},
        }, indent=2))
    else:
        for severity, where, message in sorted(report.findings, key=lambda item: (item[0] != "error", item[1])):
            print(f"{where}: {severity}: {message}")
        if summary:
            print(
                f"{args.skill}: {summary['lines']} lines, {summary['body_lines']} in the body, "
                f"{summary['words']} words, ~{summary['tokens']} estimated tokens, "
                f"{summary['references']} references"
            )
        print(f"{errors} errors, {warnings} warnings")

    return 1 if errors or (args.strict and warnings) else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
