#!/usr/bin/env python3
"""Read the stream-json output of `claude -p` and print facts the headless checks assert on.

Usage: python3 stream.py <command> <stream.jsonl> [argument]

Commands:
  info STREAM               key=value lines: model, version, cost, is_error, api_error_status,
                            subtype, terminal_reason, num_turns, outcome
                            (outcome: ok | usage_limit | not_logged_in | error | no_result)
  result STREAM             the final result text
  skills STREAM             one skill per line, from the Skill tool calls
  tools STREAM              one tool name per line, for every tool call
  tool-inputs STREAM NAME   one JSON input per line for the calls to NAME (exact name, or an MCP
                            tool whose name ends in "__NAME")
  bash STREAM               one JSON-encoded command per line, for every Bash tool call
  denials STREAM            "tool<TAB>JSON input" per permission denial in the result event
  plugins STREAM            "name<TAB>version<TAB>path" per plugin in the init event
  hash FILE...              "sha256<TAB>path" per file, or "absent<TAB>path" when it does not exist
  hash-tree DIR             "sha256<TAB>relative/path" per file under DIR, sorted, skipping .git/

Standard library only. Lines that are not JSON are ignored.
"""
import hashlib
import json
import re
import sys
from pathlib import Path

USAGE_LIMIT = re.compile(
    r"usage limit|rate.?limit|limit reached|hit your .*limit|\b429\b|quota", re.IGNORECASE
)
NOT_LOGGED_IN = re.compile(r"not logged in|please run /login|invalid api key|oauth token", re.IGNORECASE)


def events(stream_path):
    with open(stream_path, encoding="utf-8", errors="replace") as stream:
        for line in stream:
            line = line.strip()
            if not line.startswith("{"):
                continue
            try:
                yield json.loads(line)
            except ValueError:
                continue


def first(stream_path, event_type, subtype=None):
    for event in events(stream_path):
        if event.get("type") == event_type and (subtype is None or event.get("subtype") == subtype):
            return event
    return None


def last_result(stream_path):
    found = None
    for event in events(stream_path):
        if event.get("type") == "result":
            found = event
    return found


def tool_calls(stream_path):
    """Yield (name, input) for every tool_use block in assistant messages."""
    for event in events(stream_path):
        message = event.get("message")
        content = message.get("content") if isinstance(message, dict) else None
        if not isinstance(content, list):
            continue
        for block in content:
            if isinstance(block, dict) and block.get("type") == "tool_use":
                yield block.get("name", ""), block.get("input") or {}


def outcome_of(result):
    if result is None:
        return "no_result"
    if not result.get("is_error"):
        return "ok"
    text = str(result.get("result") or "")
    if result.get("api_error_status") == 429 or USAGE_LIMIT.search(text):
        return "usage_limit"
    if NOT_LOGGED_IN.search(text):
        return "not_logged_in"
    return "error"


def command_info(stream_path):
    init = first(stream_path, "system", "init") or {}
    result = last_result(stream_path)
    facts = {
        "model": init.get("model", ""),
        "version": init.get("claude_code_version", ""),
        "cost": f"{(result or {}).get('total_cost_usd') or 0:.4f}",
        "is_error": str(bool((result or {}).get("is_error"))).lower(),
        "api_error_status": (result or {}).get("api_error_status") or "",
        "subtype": (result or {}).get("subtype", ""),
        "terminal_reason": (result or {}).get("terminal_reason", ""),
        "num_turns": (result or {}).get("num_turns", ""),
        "outcome": outcome_of(result),
    }
    for key, value in facts.items():
        print(f"{key}={value}")


def command_result(stream_path):
    result = last_result(stream_path)
    print((result or {}).get("result") or "")


def command_skills(stream_path):
    for name, tool_input in tool_calls(stream_path):
        if name == "Skill":
            print(tool_input.get("skill") or tool_input.get("command") or json.dumps(tool_input))


def command_tools(stream_path):
    for name, _ in tool_calls(stream_path):
        print(name)


def command_tool_inputs(stream_path, wanted):
    for name, tool_input in tool_calls(stream_path):
        if name == wanted or name.endswith("__" + wanted):
            print(json.dumps(tool_input, ensure_ascii=False))


def command_bash(stream_path):
    for name, tool_input in tool_calls(stream_path):
        if name == "Bash":
            print(json.dumps(tool_input.get("command", ""), ensure_ascii=False))


def command_denials(stream_path):
    result = last_result(stream_path) or {}
    for denial in result.get("permission_denials") or []:
        print(f"{denial.get('tool_name', '')}\t{json.dumps(denial.get('tool_input'), ensure_ascii=False)}")


def command_plugins(stream_path):
    init = first(stream_path, "system", "init") or {}
    for plugin in init.get("plugins") or []:
        print(f"{plugin.get('name', '')}\t{plugin.get('version', '')}\t{plugin.get('path', '')}")


def command_hash(paths):
    for raw in paths:
        path = Path(raw)
        if path.is_file():
            print(f"{hashlib.sha256(path.read_bytes()).hexdigest()}\t{raw}")
        else:
            print(f"absent\t{raw}")


def command_hash_tree(root):
    """Every file under ROOT except the .git folder, so a scenario can prove nothing changed on disk."""
    base = Path(root)
    files = sorted(
        path for path in base.rglob("*")
        if path.is_file() and ".git" not in path.relative_to(base).parts
    )
    for path in files:
        print(f"{hashlib.sha256(path.read_bytes()).hexdigest()}\t{path.relative_to(base).as_posix()}")


COMMANDS = {
    "info": command_info,
    "result": command_result,
    "skills": command_skills,
    "tools": command_tools,
    "bash": command_bash,
    "denials": command_denials,
    "plugins": command_plugins,
}


def main(argv):
    sys.stdout.reconfigure(encoding="utf-8", newline="\n")
    if len(argv) >= 2 and argv[0] == "hash":
        command_hash(argv[1:])
        return 0
    if len(argv) == 2 and argv[0] == "hash-tree":
        command_hash_tree(argv[1])
        return 0
    if len(argv) == 3 and argv[0] == "tool-inputs":
        command_tool_inputs(argv[1], argv[2])
        return 0
    if len(argv) == 2 and argv[0] in COMMANDS:
        COMMANDS[argv[0]](argv[1])
        return 0
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
