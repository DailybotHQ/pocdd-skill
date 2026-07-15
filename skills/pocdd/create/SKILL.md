---
name: pocdd-create
description: Create a new POC-driven feature file under .pocs/ from any source (a sentence, an issue, a document, a URL). Picks the file format by risk, writes the Goal, and seeds Remaining gaps including a failure-mode sweep. Use for "/poc <SOURCE>" or "start a POC for X".
version: "0.1.0"
documentation_url: https://github.com/DailybotHQ/POCDD
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob, Edit, Write
---

# POCDD — Create

Bootstrap one self-contained POC file from a **SOURCE**. First read
[`../shared/conventions.md`](../shared/conventions.md); the methodology is in
[`../spec/POCDD.md`](../spec/POCDD.md).

## Inputs

`SOURCE` is anything that defines the goal: a one-line sentence, an issue id/link,
a path to a document, or a provider URL. (`/poc create <SOURCE>` and bare
`/poc <SOURCE>` both arrive here.)

## Procedure

1. **Gather context from the SOURCE.** Read the file, fetch the URL, or read the
   issue. Distil it into a single **Goal** statement. If the source is just a
   sentence, use it verbatim as the goal.
2. **Choose the format by risk** (see conventions):
   - *Unknown external/runtime behavior* (API, OAuth, sync, time zones) →
     **runnable** file, copy [`../templates/poc.py`](../templates/poc.py)
     (use `.js`/other if that matches the production target language better).
   - *Internal/domain complexity* (refactor, wiring, product rules) → **`.md`**,
     copy [`../templates/poc.md`](../templates/poc.md).
   - When in doubt, prefer the runnable form if there is *any* external system to
     probe; otherwise `.md`.
3. **Name it by domain** — short `kebab`/`snake` name (e.g. `calendar`,
   `holidays-sync`). Never `test`.
4. **Resolve and create `.pocs/`:**
   ```bash
   . "$(dirname "$0")/../shared/context.sh"   # or source by absolute path
   dir="$(pocdd_ensure_dir)"
   ```
5. **Write the file** from the chosen template into `$dir/<name>.<ext>`, filling
   the **Goal** section and setting the header `phase: spike`.
6. **Seed Remaining gaps — the highest-value step.** Enumerate what must be
   *proven*, *decided*, or *handled* to reach the goal. Tag each `[agent]` or
   `[user]`, give stable ids `G1…`. **Always run the failure-mode sweep** for
   anything external (auth/token refresh, pagination, rate limits, partial
   failures, retries/idempotency, malformed data, time zones).
7. **Report**: the file path, format chosen (and why), and the seeded gap list
   split by owner. Suggest `/poc work <name>` next.

## Guardrails

- Never write outside `.pocs/`. Never commit `.pocs/`.
- Reference codebase by path; do not paste production code into the file.
- Do not invent product decisions — log them as `[user]` gaps.
