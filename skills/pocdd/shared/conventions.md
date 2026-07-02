# POCDD conventions (shared operational contract)

The authoritative methodology is [`../spec/POCDD.md`](../spec/POCDD.md). This file
is the terse contract every `/poc` sub-skill depends on — read it before acting on
any POC file.

## The artifact

- **One feature = one file** under `.pocs/` (gitignored). If it balloons, the
  "feature" is several — split it.
- **Format follows the risk:**
  - **runnable** (`.py` / `.js` / …) when the hard part is *unknown external or
    runtime behavior* (API, OAuth, sync math, time zones) — the header is the
    spec, the body is the proof.
  - **`.md`** when the hard part is *internal/domain complexity* (refactor,
    cross-module wiring, product rules) — no runtime to prove.
- The file **owns** goals, findings, decisions, contract, and what-to-do; it
  **references the codebase by path** (`repo/path/file.py:120`) — never pastes
  production code into itself.
- **Secrets stay out.** Tokens live under gitignored `.pocs/` paths; prefer
  sandbox/test accounts and short-lived, least-scope tokens.

## The three sections (every POC file has exactly these)

1. **Goal** — the target, captured from any source (sentence, issue, doc, URL).
2. **Implementation** — the proven solution design; grows as gaps close. Two
   clearly separated registers:
   - **Findings** (past tense), each tagged with provenance:
     `[ran it]`, `[code: path:line]`, `[product decision]`, `[assumption — unverified]`.
   - **Directives** (imperative), each with a **verifiable done-check** (a command,
     a test, a diff). Prescriptive on interfaces/acceptance, loose on implementation.
3. **Remaining gaps** — the worklist and the progress bar.

## Status header

Every POC file starts with a status line:

```
phase: spike | shaping | ready-to-implement | not-viable
```

## Gaps

- Give each gap a **stable id** (`G1`, `G2`, …) and tag it by **owner**:
  - `[agent]` — *investigation gap*; the agent closes it itself (run / read / prove).
  - `[user]` — *decision gap*; only a human can resolve it.
- **Decisions never stop execution.** When the agent hits a `[user]` gap it:
  1. records a **default assumption** to proceed with, and
  2. **links** the dependent work (e.g. *"Implementation §4 assumes G3 = hourly"*).
  Then it keeps going. When the user later resolves the gap differently, every
  linked section is flagged for revision.
- **Closing an `[agent]` gap** moves its proven result into **Implementation**
  (with provenance) and removes it from Remaining gaps. It may spawn new gaps.

## Seeding gaps (the highest-value step)

On create, enumerate the gaps you *don't yet know you have* — not just the obvious
ones. Always run a **failure-mode sweep** for anything touching an external system:
auth & token refresh, pagination, rate limits, partial failures, retries /
idempotency, malformed or missing data, time zones. A POC is only as good as its
gap list.

## Done

- **`ready-to-implement`** = Remaining gaps is empty: no `[agent]` gaps left to
  prove and no `[user]` gaps left to decide.
- **`not-viable`** is a valid terminal outcome: if a gap reveals the goal is
  infeasible or too costly, record the finding that killed it and stop.
