#!/usr/bin/env python3
"""Check that each marketplace entry carries the version of its skill (ADR-0006).

A skill's version lives in `metadata.version` of its SKILL.md frontmatter. The Claude Code
marketplace entry in `.claude-plugin/marketplace.json` repeats it, because `claude plugin update`
compares that one. This check fails when they differ, when a version is not SemVer, when an
entry's name differs from the skill's `name:`, or when a skill folder has no marketplace entry.

Usage: python3 .github/scripts/check-versions.py [repo-root]   (exit 0 clean, 1 with findings)
"""
import json
import re
import sys
from pathlib import Path

SEMVER = re.compile(r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$")


def frontmatter(skill_md):
    """Return (name, metadata.version) from a SKILL.md frontmatter, '' when missing."""
    text = skill_md.read_text(encoding="utf-8").replace("\r\n", "\n")
    match = re.match(r"---\n(.*?)\n---", text, re.S)
    name = version = ""
    in_metadata = False
    for line in match.group(1).splitlines() if match else []:
        if re.match(r"\S", line):
            in_metadata = line.startswith("metadata:")
            if line.startswith("name:"):
                name = line.split(":", 1)[1].strip().strip("\"'")
        elif in_metadata and re.match(r"\s+version:", line):
            version = line.split(":", 1)[1].strip().strip("\"'")
    return name, version


def main(root):
    findings = []
    marketplace = root / ".claude-plugin" / "marketplace.json"
    entries = json.loads(marketplace.read_text(encoding="utf-8")).get("plugins", [])
    covered = set()
    for entry in entries:
        source = entry.get("source", "")
        if not isinstance(source, str) or not source.startswith("./"):
            continue  # an external plugin: its version is not ours to check
        skill_dir = (root / source).resolve()
        covered.add(skill_dir)
        label = f"marketplace entry '{entry.get('name', '?')}'"
        skill_md = skill_dir / "SKILL.md"
        if not skill_md.is_file():
            findings.append(f"{label}: {source}/SKILL.md not found")
            continue
        name, version = frontmatter(skill_md)
        if not version:
            findings.append(f"{source}/SKILL.md: no metadata.version in the frontmatter")
        elif not SEMVER.match(version):
            findings.append(f"{source}/SKILL.md: metadata.version '{version}' is not SemVer")
        if entry.get("name") != name:
            findings.append(f"{label}: name differs from SKILL.md name '{name}'")
        if entry.get("version") != version:
            findings.append(f"{label}: version '{entry.get('version')}' differs from SKILL.md metadata.version '{version}'")
    for skill_md in sorted((root / "skills").glob("*/SKILL.md")):
        if skill_md.parent.resolve() not in covered:
            findings.append(f"{skill_md.parent.relative_to(root).as_posix()}: no entry in .claude-plugin/marketplace.json")
    for finding in findings:
        print(finding)
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main(Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()))
