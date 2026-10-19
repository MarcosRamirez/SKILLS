#!/usr/bin/env python3
"""Check senior-mindset's curated catalog (SPEC-0011): skills.json and mcps.json.

Each file is validated against catalog.schema.json (the subset of JSON Schema it uses: type,
enum, pattern, minLength, minProperties, required, properties, additionalProperties, items and
local $ref), then against the rules a schema cannot say well (references/catalog.md):

- the file's `kind` matches its name, ids are unique, and no rejected id is also an entry;
- `source.ref` and `version` are pinned: not a moving name such as main, master, HEAD or latest;
- install commands carry no scope flags (the skill adds the scope the user picks), and a skill
  installs with `npx skills add`;
- no string looks like a secret (keys, tokens, private keys).

Usage: python3 .github/scripts/check-catalog.py [catalog-dir]   (exit 0 clean, 1 with findings)
"""
import json
import re
import sys
from pathlib import Path

DEFAULT_DIR = Path("skills/senior-mindset/catalog")
FILES = {"skills.json": "skills", "mcps.json": "mcps"}
MOVING_REFS = re.compile(r"(^|[\s@:/])(main|master|head|latest|develop|trunk)$", re.I)
SKILL_SCOPE_FLAGS = re.compile(r"(^|\s)(-g|--global|--copy)(\s|$)")
MCP_SCOPE_FLAGS = re.compile(r"(^|\s)(-s|--scope)(\s|=|$)")
SECRET = re.compile(
    r"AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{36}"
    r"|xox[baprs]-[A-Za-z0-9-]{10,}|sk-[A-Za-z0-9_-]{20,}|Bearer [A-Za-z0-9._-]{20,}"
)
JSON_TYPES = {"object": dict, "array": list, "string": str, "boolean": bool}


def resolve(schema, root):
    while "$ref" in schema:
        node = root
        for part in schema["$ref"].removeprefix("#/").split("/"):
            node = node[part]
        schema = node
    return schema


def validate(value, schema, root, where, findings):
    """Append "where: problem" for every way VALUE breaks SCHEMA."""
    schema = resolve(schema, root)
    expected = schema.get("type")
    if expected and not isinstance(value, JSON_TYPES[expected]):
        findings.append(f"{where}: expected {expected}, got {type(value).__name__}")
        return
    if "enum" in schema and value not in schema["enum"]:
        findings.append(f"{where}: {value!r} is not one of {schema['enum']}")
    if isinstance(value, str):
        if len(value) < schema.get("minLength", 0):
            findings.append(f"{where}: empty")
        if "pattern" in schema and not re.search(schema["pattern"], value):
            findings.append(f"{where}: {value!r} does not match {schema['pattern']}")
    if isinstance(value, dict):
        if len(value) < schema.get("minProperties", 0):
            findings.append(f"{where}: needs at least {schema['minProperties']} key(s)")
        for key in schema.get("required", []):
            if key not in value:
                findings.append(f"{where}: missing '{key}'")
        properties = schema.get("properties", {})
        extra = schema.get("additionalProperties", True)
        for key, item in value.items():
            if key in properties:
                validate(item, properties[key], root, f"{where}.{key}", findings)
            elif extra is False:
                findings.append(f"{where}: unknown key '{key}'")
            elif isinstance(extra, dict):
                validate(item, extra, root, f"{where}.{key}", findings)
    if isinstance(value, list) and "items" in schema:
        for index, item in enumerate(value):
            validate(item, schema["items"], root, f"{where}[{index}]", findings)


def strings(value, where):
    """Yield (where, text) for every string inside VALUE."""
    if isinstance(value, str):
        yield where, value
    elif isinstance(value, dict):
        for key, item in value.items():
            yield from strings(item, f"{where}.{key}")
    elif isinstance(value, list):
        for index, item in enumerate(value):
            yield from strings(item, f"{where}[{index}]")


def check_rules(data, kind, name, findings):
    entries = [e for e in data.get("entries", []) if isinstance(e, dict)]
    ids = [e.get("id") for e in entries]
    for duplicate in sorted({i for i in ids if ids.count(i) > 1}):
        findings.append(f"{name}: id '{duplicate}' appears more than once")
    for rejected in data.get("rejected", []):
        if isinstance(rejected, dict) and rejected.get("id") in ids:
            findings.append(f"{name}: '{rejected['id']}' is both an entry and rejected")
    for entry in entries:
        label = f"{name}: {entry.get('id', '?')}"
        ref = str(entry.get("source", {}).get("ref", ""))
        if MOVING_REFS.search(ref.strip()):
            findings.append(f"{label}: source.ref '{ref}' is not pinned")
        if MOVING_REFS.search(str(entry.get("version", "")).strip()):
            findings.append(f"{label}: version '{entry['version']}' is not pinned")
        install = entry.get("install", {}) if isinstance(entry.get("install"), dict) else {}
        for agent, command in install.items():
            flags = SKILL_SCOPE_FLAGS if kind == "skills" else MCP_SCOPE_FLAGS
            if isinstance(command, str) and flags.search(command):
                findings.append(f"{label}: install.{agent} carries a scope flag; the skill adds the scope")
        if kind == "skills" and not str(install.get("npx-skills", "")).startswith("npx skills add "):
            findings.append(f"{label}: install.npx-skills must start with 'npx skills add '")
    for where, text in strings(data, name):
        if SECRET.search(text):
            findings.append(f"{where}: looks like a secret; the catalog names secrets, never holds them")


def main(catalog_dir):
    findings = []
    schema_path = catalog_dir / "catalog.schema.json"
    try:
        schema = json.loads(schema_path.read_text(encoding="utf-8"))
    except (OSError, ValueError) as error:
        print(f"{schema_path}: {error}")
        return 1
    for file_name, kind in FILES.items():
        path = catalog_dir / file_name
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, ValueError) as error:
            findings.append(f"{path}: {error}")
            continue
        validate(data, schema, schema, file_name, findings)
        if isinstance(data, dict):
            if data.get("kind") != kind:
                findings.append(f"{file_name}: kind is {data.get('kind')!r}, expected {kind!r}")
            check_rules(data, kind, file_name, findings)
    for finding in findings:
        print(finding)
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main(Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_DIR))
