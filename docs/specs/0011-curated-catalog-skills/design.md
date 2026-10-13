# SPEC-0011 design

## Entry shape (draft)

```json
{
  "id": "web-design",
  "name": "Web design",
  "purpose": "Layout, typography and accessible UI for web pages",
  "proposeWhen": { "tasks": ["landing page", "ui", "web design"], "stack": ["astro", "next"] },
  "source": { "marketplace": "marcosramirez-skills", "plugin": "web-design", "upstream": "<repo>" },
  "install": "/plugin install web-design@marcosramirez-skills",
  "permissions": "none",
  "version": "1.2.0",
  "why": "…",
  "added": "2026-10-13"
}
```

- Validation script in Python (stdlib + a minimal schema check) so it runs in CI and locally.
- Proposal logic lives in `references/catalog.md`: match task words and stack signals, propose at most three.
