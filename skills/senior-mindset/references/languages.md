# Choosing a language per component

Do not force one language for everything, and do not add a new one without a clear gain.

## How to decide

**No default weighting.** For each component, present a short pros/cons table of
2–3 candidates for *that* case, give a reasoned recommendation, and ask the user
(AskUserQuestion). Record the choice as an ADR.

Criteria to weigh:

1. **Efficiency** — CPU, memory, cold start, concurrency model, and what that costs on the chosen platform.
2. **Ecosystem** — libraries and SDKs that exist for this exact job.
3. **Developer pool and maintainability** — hiring, reviewing and onboarding. AI lowers
   the cost of writing any language, but humans still review, debug and own it.
4. **What the project already uses** — each extra language adds tooling, CI, and context switching.
5. **Platform fit** — e.g. Cloudflare Workers run JS/TS natively; Python and Rust (Wasm) with caveats.

## Matrix (starting point)

| Component | Strong candidates | Notes |
|---|---|---|
| Web frontend | TypeScript | No real alternative |
| Web backend / API | TypeScript, Go, Python | TS if the frontend is TS (shared types); Go for high concurrency and low memory; Python for data/ML-heavy APIs (FastAPI) |
| Worker / background jobs | Python, Go, Rust, TypeScript | See example below |
| CLI tool | Go, Rust, Python | Go/Rust → single static binary; Python → fastest to write, needs a runtime |
| Data / ML / scripts | Python | Ecosystem wins (pandas, polars, numpy, PyTorch) |
| High-performance / systems / Wasm | Rust, Go | Rust for max performance and memory safety; Go when "fast enough" with simpler code |
| Edge functions | TypeScript | Native runtime on Cloudflare/Vercel |
| Mobile | TypeScript (React Native), Kotlin, Swift, Dart | Cross-platform vs native trade-off |

## Example: image-processing worker (1M images/day)

| | Python | Go | Rust |
|---|---|---|---|
| Performance | Good with native libs (Pillow-SIMD, libvips bindings); GIL limits CPU parallelism → use processes | Very good; goroutines make concurrency easy | Best; no GC, predictable latency |
| Ecosystem | Excellent (imaging + ML) | Good (libvips bindings, `image` stdlib) | Good (`image`, libvips bindings), smaller |
| Dev speed | Fastest | Fast | Slowest (borrow checker) |
| Dev pool | Largest | Large | Smaller |
| Ops | Needs runtime + deps | Single binary, small container | Single binary, small container |

A reasonable recommendation: Go for the balance, Python if ML models are involved,
Rust if throughput per dollar is the main constraint. The user decides.
