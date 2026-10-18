#!/usr/bin/env python3
"""A stand-in for the AskUserQuestion tool, served as a stdio MCP server for headless runs.

Headless `claude -p` has no question tool. This server offers one with the same name and input
schema, so the skill reaches its question step, and it answers the way a run without a user does:

- STUB_MODE=error (default): the call fails, like a client that cannot show the question;
- STUB_MODE=no-answer: the call succeeds but carries no answer.

When STUB_LOG is set, each call's arguments are appended to that file (keep it outside the
repository). Standard library only.
"""
import json
import os
import sys

PROTOCOL_VERSION = "2024-11-05"
MODE = os.environ.get("STUB_MODE", "error")
LOG_PATH = os.environ.get("STUB_LOG")

DESCRIPTION = (
    "Asks the user multiple choice questions to gather information, clarify ambiguity, or get "
    "decisions. Users can always select 'Other' to type a custom answer. 1-4 questions, 2-4 "
    "options each. If you recommend a specific option, make it the first option and add "
    "'(Recommended)' to its label."
)
OPTION_SCHEMA = {
    "type": "object",
    "properties": {"label": {"type": "string"}, "description": {"type": "string"}},
    "required": ["label", "description"],
}
QUESTION_SCHEMA = {
    "type": "object",
    "properties": {
        "question": {"type": "string"},
        "header": {"type": "string", "maxLength": 12},
        "multiSelect": {"type": "boolean"},
        "options": {"type": "array", "minItems": 2, "maxItems": 4, "items": OPTION_SCHEMA},
    },
    "required": ["question", "header", "options", "multiSelect"],
}
INPUT_SCHEMA = {
    "type": "object",
    "properties": {"questions": {"type": "array", "minItems": 1, "maxItems": 4, "items": QUESTION_SCHEMA}},
    "required": ["questions"],
}


def reply(request_id, result=None, error=None):
    message = {"jsonrpc": "2.0", "id": request_id}
    if error is not None:
        message["error"] = error
    else:
        message["result"] = result
    sys.stdout.write(json.dumps(message) + "\n")
    sys.stdout.flush()


def log_call(arguments):
    if not LOG_PATH:
        return
    with open(LOG_PATH, "a", encoding="utf-8") as log:
        log.write(json.dumps(arguments, ensure_ascii=False) + "\n")


def answer_question(arguments):
    log_call(arguments)
    if MODE == "no-answer":
        return {"content": [{"type": "text", "text": "(no answer given)"}]}
    return {"isError": True, "content": [{"type": "text", "text": "Error: no UI available to show the question."}]}


def handle(message):
    request_id = message.get("id")
    method = message.get("method")
    if request_id is None:
        return  # a notification, such as notifications/initialized
    if method == "initialize":
        reply(request_id, {
            "protocolVersion": PROTOCOL_VERSION,
            "capabilities": {"tools": {}},
            "serverInfo": {"name": "question-stub", "version": "1"},
        })
    elif method == "tools/list":
        reply(request_id, {"tools": [{"name": "AskUserQuestion", "description": DESCRIPTION, "inputSchema": INPUT_SCHEMA}]})
    elif method == "tools/call":
        reply(request_id, answer_question(message.get("params", {}).get("arguments", {})))
    elif method == "ping":
        reply(request_id, {})
    else:
        reply(request_id, error={"code": -32601, "message": f"method not found: {method}"})


def main():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            message = json.loads(line)
        except ValueError:
            continue
        handle(message)


if __name__ == "__main__":
    main()
