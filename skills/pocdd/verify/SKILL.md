---
name: pocdd-verify
description: Validate that a POC file is well-formed against the POCDD conventions — status header, the three sections, gaps tagged by owner with ids, findings with provenance, and decision gaps carrying an assumption + link. Read-only pass/fail. Use for "/poc verify <name>".
version: "0.1.0"
documentation_url: https://github.com/DailybotHQ/POCDD
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob
---

# POCDD — Verify

Objective well-formedness check for a POC file, against
[`../shared/conventions.md`](../shared/conventions.md). Read-only.

## Run the check

```bash
bash "$(dirname "$0")/verify.sh" <name>    # or a path; omit to verify all
```

`verify.sh` resolves the POC via [`../shared/context.sh`](../shared/context.sh) and
asserts:

| Check | Requirement |
|-------|-------------|
| **Status header** | a `phase:` line with a valid value |
| **Goal** | a non-empty `Goal` section |
| **Implementation** | an `Implementation` section present |
| **Remaining gaps** | a `Remaining gaps` section present |
| **Gap tagging** | every listed gap has an id (`G<n>`) and an owner (`[agent]` / `[user]`) |
| **Done consistency** | `ready-to-implement` ⇒ no gaps; gaps present ⇒ not `ready-to-implement` |

It prints `PASS` / `FAIL` per file with the specific failing lines, and exits
non-zero if any file fails — so it can gate `/poc implement`.

## When it fails

Report the exact failures and route to `/poc work <name>` (to close/format gaps)
or `/poc create` (if the file is missing required sections entirely). Do not
auto-rewrite the file from `verify` — that is `work`'s job.
