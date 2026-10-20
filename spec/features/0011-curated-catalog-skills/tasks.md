# SPEC-0011 tasks

One branch per task, stacked PRs. Executed through PLAN-0011.

- [x] T-0 Decide the open question with the user: project scope by default, skills in
  `.agents/skills/` with a Claude Code bridge (decided 2026-10-13; R-8, ADR-0005)
- [x] T-1 Criteria (`references/catalog.md`) + schema + validation script + CI step (AC-1, AC-2)
- [x] T-2 Build the initial lists **with the user**: ask for their skills and MCPs, propose researched
  candidates, approve entry by entry, record rejections (AC-1, AC-1b). Context7 is already
  approved (AC-1c), so it is not asked again
- [x] T-3 Vetted third-party skills installable with `npx skills`; marketplace listing optional (AC-4)
- [ ] T-4 Skill management flow in `SKILL.md`; headless test (AC-3)
- [ ] T-5 Release (minor), docs, changelogs; last PR carries `Closes-Spec: SPEC-0011`

## Review session (T-2, 2026-10-19 and 2026-10-20)

The user chose the areas to cover: frontend and web design, testing and the browser, office
documents, platforms and services. Candidates came only from vendors' own repositories, each checked
on GitHub and npm for licence, recent activity, a pinnable release or commit, and the official install
command. They were proposed in four batches of closed questions; every entry below was approved
explicitly.

| Entry | Kind | Decision |
|---|---|---|
| frontend-design (Anthropic, Apache-2.0) | skill | in, recommended |
| webapp-testing (Anthropic, Apache-2.0) | skill | in |
| vercel-react-best-practices (Vercel, MIT) | skill | in |
| web-design-guidelines (Vercel, MIT) | skill | in |
| cloudflare, wrangler, workers-best-practices, web-perf (Cloudflare, Apache-2.0) | skills | in, all recommended |
| docx, xlsx, pptx, pdf (Anthropic, proprietary) | skills | in **as an exception** to the open-licence criterion, recorded in each entry's `exception` |
| Context7 (Upstash, MIT) | MCP | in, recommended (approved earlier, AC-1c) |
| Playwright MCP (Microsoft, Apache-2.0) | MCP | in, recommended |
| Chrome DevTools MCP (Google, Apache-2.0) | MCP | in |
| GitHub MCP (GitHub, MIT) | MCP | in |
| Cloudflare Docs MCP (Cloudflare, Apache-2.0) | MCP | in, recommended |
| Sentry MCP | MCP | **rejected**: licence not declared (NOASSERTION); in `rejected` with the reason |

Checks made while writing the entries: `npx skills@1.7.2` installs a skill pinned to a commit
(`anthropics/skills#<sha> --skill frontend-design` wrote the copy and recorded the `ref`), and the
installable names were listed per source (`vercel-react-best-practices` differs from its folder).
Claude Code's MCP docs confirm `${VAR}` expansion in `.mcp.json` `url` and `headers`, so the GitHub
entry stores the variable name and never the token. Chrome DevTools installs with
`--no-usage-statistics` (minimal data). `check-catalog.py` passes.

## Install check (T-3, 2026-10-20)

Every skill entry's `install.npx-skills` command, run with `npx --yes skills@1.7.2 … -a claude-code
--copy -y` in an empty scratch repository (AC-4):

| Entry | `.claude/skills/<name>/SKILL.md` | `skills-lock.json` ref = the entry's pinned commit |
|---|---|---|
| frontend-design, webapp-testing, docx, xlsx, pptx, pdf (anthropics/skills) | yes | yes |
| vercel-react-best-practices, web-design-guidelines (vercel-labs/agent-skills) | yes | yes |
| cloudflare, wrangler, workers-best-practices, web-perf (cloudflare/skills) | yes | yes |

12 of 12 installed from their pinned commit. Listing them in this repository's marketplace is
optional (R-5) and not done: `npx skills` covers every agent, and a marketplace copy would be one
more thing to keep in step.
