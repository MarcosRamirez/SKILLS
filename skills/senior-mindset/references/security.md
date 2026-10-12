# Security checklist (OWASP Top 10 applied to code)

Run through this before handing over any code that touches users, data or the network.

| OWASP | Check |
|---|---|
| **A01 Broken access control** | Authorization checked server-side on every request, per resource (no IDOR: verify the user owns `orderId`). Deny by default. |
| **A02 Cryptographic failures** | TLS everywhere. Passwords hashed with Argon2id or bcrypt. No home-made crypto. Sensitive data encrypted at rest when required. |
| **A03 Injection** | Parameterized queries / ORM only — never string-concatenated SQL. Escape output (XSS). No `eval`, no shell calls with user input. |
| **A04 Insecure design** | Threat-model the feature in `design.md` (who can abuse it, how). Rate limits on auth and expensive endpoints. |
| **A05 Security misconfiguration** | No debug mode or stack traces in prod. Security headers (CSP, HSTS, X-Content-Type-Options). CORS restricted to known origins. |
| **A06 Vulnerable components** | Pinned dependencies with a lockfile. Run `npm audit` / `pip-audit` / Dependabot. Prefer maintained libraries. |
| **A07 Auth failures** | Use a proven auth library/provider. MFA option. Secure, HttpOnly, SameSite cookies. Session expiry and rotation. Generic login error messages. |
| **A08 Integrity failures** | Verify webhooks (signatures). No deserialization of untrusted data. CI with protected branches. |
| **A09 Logging failures** | Log auth events, access denials and errors — **never** passwords, tokens, secrets or personal data. See [observability.md](observability.md). |
| **A10 SSRF** | Validate and allow-list outbound URLs built from user input. Block internal IP ranges. |

## Always

- Validate all input at the boundary (schema validation: Zod, Pydantic, etc.).
- Secrets in environment variables or a secret store; `.env*` in `.gitignore`.
- Least privilege for DB users, API keys and cloud roles.
- File uploads: check type and size, store outside the web root, random names.
