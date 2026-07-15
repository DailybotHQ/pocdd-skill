---
name: pocdd-status
description: Report the status of a single POC file — phase, findings, and remaining gaps split by [agent]/[user], plus what is blocking and the suggested next action. Read-only. Use for "/poc status <name>" or "what's left on <name>".
version: "0.1.0"
documentation_url: https://github.com/DailybotHQ/pocdd-skill
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob
---

# POCDD — Status

Read-only deep status of one POC. Resolve it with `pocdd_resolve <name>` from
[`../shared/context.sh`](../shared/context.sh), then read the file.

## Report

- **Phase** — `spike | shaping | ready-to-implement | not-viable`.
- **Findings** — count, and a one-line digest of the most load-bearing ones.
- **Remaining gaps** — split into `[agent]` (the engine can close these) and
  `[user]` (awaiting a human decision), each by id and one-line summary.
- **Blocking now** — the `[user]` gaps and, for each, the default assumption the
  POC is currently running with.
- **Next action** — concretely: `/poc work <name>` if `[agent]` gaps remain;
  "resolve N decisions" if only `[user]` gaps remain; `/poc implement <name>` if
  `ready-to-implement`.

Do not modify the file.
