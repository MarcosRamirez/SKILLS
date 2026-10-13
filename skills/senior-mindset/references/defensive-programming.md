# Defensive programming

Assume every input is wrong, every resource can run out, and every external call can fail
or hang, until the code proves otherwise. Defensive code fails **early, loudly and safely**,
instead of corrupting data or failing deep inside with a cryptic error.

## 1. Trust boundaries: validate once, at the edge

Never trust data that crosses a boundary:
- user input (forms, query strings, headers, cookies);
- CLI args and env vars;
- files and uploads;
- responses from external APIs and webhooks;
- messages from queues;
- data in a database written by another system.

- Validate **shape, type, range and size** with a schema: Zod, Valibot, Pydantic, `encoding/json` + validation, serde.
- **Allow-lists over deny-lists** for formats, file types, redirect URLs and sort fields.
- **Normalize before checking:** trim, Unicode normalization, resolved paths (`realpath`).
  A path check on `../../etc/passwd` must run on the resolved path.
- Parse into typed values ("parse, don't validate"). After the boundary, code receives a
  `ValidatedOrder`, not a `dict` that might contain anything.
- Client-side validation is for UX only; the server always re-validates.

```ts
const UploadRequest = z.object({
  fileName: z.string().min(1).max(255).regex(/^[\w.\- ]+$/),
  sizeBytes: z.number().int().positive().max(MAX_UPLOAD_BYTES),
  mimeType: z.enum(["image/png", "image/jpeg", "application/pdf"]),
});
const request = UploadRequest.parse(body); // throws a 400-mapped error on bad input
```

## 2. Guard clauses and fail fast

Check preconditions at the top of a function and return or throw early. The happy path
stays flat and readable.

```python
def transfer(source: Account, target: Account, amount_cents: int) -> None:
    if amount_cents <= 0:
        raise InvalidAmount(amount_cents)
    if source.id == target.id:
        raise SameAccountTransfer(source.id)
    if source.balance_cents < amount_cents:
        raise InsufficientFunds(source.id, amount_cents)

    source.withdraw(amount_cents)
    target.deposit(amount_cents)
```

- **Validation vs assertion:** bad *input* is an expected error (return a 4xx, show a message).
  A broken *invariant* is a bug (`assert` / panic / throw an internal error, plus a log).
  Do not use asserts for user input; they may be stripped in production (`python -O`).
- Exhaustive handling: `switch` on unions/enums with a default that throws
  (`assertNever` in TS, `match` with `case _: raise` in Python).
- No silent fallbacks. `user.email ?? ""` hides a bug; decide explicitly what a missing value means.

## 3. Check resources before acting

Before an operation that consumes a resource, check that the resource is there, and fail
with a clear message if it is not:

| Operation | Check first |
|---|---|
| Write or upload a file | Free disk space ≥ file size + margin; size within limit; target directory exists and is writable |
| Load data into memory | Size or row count within a limit; otherwise stream or paginate |
| Call a quota-limited API | Remaining quota / rate-limit headers; back off before hitting 429 |
| Spawn work (threads, jobs) | Pool or queue capacity; reject or queue when full |
| Allocate from a pool | DB connections, file handles: bounded pools with acquire timeouts |

```python
import os, shutil, tempfile

SAFETY_MARGIN_BYTES = 100 * 1024 * 1024  # keep 100 MB free

def save_upload(data: bytes, target_path: str) -> None:
    target_dir = os.path.dirname(os.path.abspath(target_path))
    free_bytes = shutil.disk_usage(target_dir).free
    if free_bytes < len(data) + SAFETY_MARGIN_BYTES:
        raise InsufficientStorage(needed=len(data), free=free_bytes)

    # Write to a temp file in the same directory, then rename atomically:
    # a failure midway never leaves a half-written file at target_path.
    fd, temp_path = tempfile.mkstemp(dir=target_dir)
    try:
        with os.fdopen(fd, "wb") as temp_file:
            temp_file.write(data)
            temp_file.flush()
            os.fsync(temp_file.fileno())
        os.replace(temp_path, target_path)
    except OSError:
        os.unlink(temp_path)
        raise  # ENOSPC can still happen: the disk may fill after the check
```

Node equivalent of the space check: `const { bavail, bsize } = await fs.promises.statfs(dir); const freeBytes = bavail * bsize;`

**A check is not a guarantee (TOCTOU).** Between "there is space" and "write", another
process can fill the disk, delete the directory or take the last connection. The check
gives a fast, friendly error; **the operation must still handle failure** (`ENOSPC`,
`EACCES`, timeouts) and leave no partial state behind.

## 4. External calls: assume they fail or hang

- **Timeout on every network call**: HTTP, DB, cache, queue. No library default of "forever".
- **Retries only for transient errors** (timeouts, 429, 503), with exponential backoff, jitter
  and a maximum number of attempts. Retry only idempotent operations, or use an `Idempotency-Key`.
- **Circuit breaker** for dependencies that fail repeatedly: stop calling, fail fast, probe later.
- **Validate responses** like any other input: a third-party API can change shape without notice.
- Decide the behavior when a dependency is down (degrade, queue for later, or fail clearly), and write it in the plan's `## Design`.

## 5. Limits everywhere

Every unbounded thing is a denial-of-service waiting to happen:
- request body size, upload size, JSON depth;
- page size (`limit` with a maximum), results per query;
- loop iterations driven by input, and recursion depth;
- string lengths, array lengths, number of items per batch;
- regexes on user input: avoid catastrophic backtracking (no nested quantifiers like `(a+)+`), or use a linear-time engine (RE2).

## 6. Failure handling and cleanup

- **Never swallow errors** (`catch {}` / `except: pass`). Handle, add context and rethrow, or let it propagate.
- **Release resources on every path:** `try/finally`, `with` (Python), `using` / `await using`
  (TS), `defer` (Go), RAII (Rust).
- **Transactions for multi-step writes:** all or nothing.
- **Error messages:** generic and helpful for the user ("Not enough storage to save the file");
  details, IDs and context in the logs. No stack traces, secrets or internals in responses.
- **Defensive copies / immutability:** do not let callers mutate internal state through
  returned references; prefer immutable data for values passed around.

## 7. Do not overdo it

- Validate at boundaries, not in every private function. After parsing into typed values,
  internal code can trust them.
- Do not guard against things the type system already rules out.
- One clear check beats five redundant ones. Defensive code must stay readable: if the guards
  bury the logic, move validation to the boundary or into a value object.

## Self-review questions

- What happens with empty, huge, malformed, negative or duplicated input?
- What happens if the disk is full, the network is down, or the dependency is slow?
- What is left behind if this fails halfway?
- Is every external call bounded by a timeout, and every collection by a limit?
