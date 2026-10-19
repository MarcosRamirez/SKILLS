# CI tests

Tests for the release scripts and the docs check (SPEC-0029). They need only `bash`, `git` and
`python3`: no network, no model, no credentials.

```bash
bash tests/ci/run.sh          # all suites, with a summary; exit 1 if any fails
bash tests/ci/test-check-docs.sh   # one suite
```

Every suite builds its fixtures in a temp folder (removed at exit) and tests the scripts of the
checkout it lives in, so a run tests the code you have now. Git identities are set per scratch
repository; no global git config is needed.

| Suite | Tests | Covers |
|---|---|---|
| `test-close-specs.sh` | `skills/senior-mindset/templates/release-automation/close-specs.sh` and the id extraction of `.github/workflows/on-merge.yml` | closing features and fixes (single file or folder, plan, roadmap row), number collisions across `spec/features` and `spec/fixes`, `SPEC_DIRS` / `FEATURES_DIR`, idempotence, invalid ids and `PR_NUMBER`, several ids in one PR, the commit-message ids and the `ids="specs"` fallback under `pipefail` |
| `test-tag-skill-releases.sh` | `.github/scripts/tag-skill-releases.sh` | refusing a version when only the version and changelog changed since the previous tag, first tags, `TARGET_SHA`, nearest tag in the history, CRLF `SKILL.md`, `git diff` failures, and real tagging against a scratch bare remote with the fake `gh` in `fakebin/` |
| `test-check-docs.sh` | `.github/scripts/check-docs.py` and `skills/senior-mindset/templates/docs-check/check-docs.py` | clean tree, broken links, links to superseded ADRs, links inside code fences and spans, the `adr/` folder exemption, files as arguments, `DOCS_CHECK_FILES` (template) |
| `test-check-versions.sh` | `.github/scripts/check-versions.py` | marketplace entry vs `SKILL.md` name and `metadata.version`, non-SemVer and missing versions, CRLF, skill folders without an entry, external entries, this checkout |

`fakebin/gh` records its arguments in `$GH_CALLS_LOG` and does nothing else. Only the tag suite puts
it on `PATH`, and only for the real-mode cases.

When a script changes, change its suite in the same pull request.
