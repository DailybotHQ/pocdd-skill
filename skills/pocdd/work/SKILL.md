---
name: pocdd-work
description: Run the POCDD gap-closing loop on an existing POC file — close [agent] investigation gaps autonomously (at most gaps_per_pass per invocation), defer [user] decision gaps with a recorded assumption, and advance the file toward ready-to-implement without ever stopping execution. Use for "/poc work <name>" or "close the gaps".
version: "0.2.0"
documentation_url: https://github.com/DailybotHQ/pocdd-skill
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob, Edit, Write
---

# POCDD — Work (the gap-closing engine)

This is the heart of POCDD. Read [`../shared/conventions.md`](../shared/conventions.md)
first. Resolve the target with `pocdd_resolve <name>` from
[`../shared/context.sh`](../shared/context.sh).

**Budget:** close at most **2** `[agent]` gap(s) per `/poc work`
invocation (profile `mid`). Then stop, summarize, and invite another pass.

## The loop

1. **Load the POC fully** — Goal, Implementation, Remaining gaps, `phase`. Set
   `phase: shaping`.
2. **Work up to 2 `[agent]` gap(s)** in id order:
   - Do the investigation: run the script (for runnable POCs, with the relevant
     flags), read the referenced code paths, or diff output against expectations.
   - Capture the result as a **Finding** in **Implementation**, tagged with
     provenance (`[ran it]`, `[code: path:line]`, …).
   - Remove the gap from **Remaining gaps**. Add any **newly discovered** gaps.
   - If you hit the per-pass budget, **stop closing** further `[agent]` gaps.
3. **Defer every `[user]` gap — never stop.** For each decision gap you encounter:
   - Record a **default assumption** to proceed with.
   - **Link** the dependent Implementation (e.g. *"§4 assumes G3 = hourly"*).
   - Leave the gap in **Remaining gaps** (owner `[user]`); keep going.
4. **Re-derive the phase:**
   - any gaps left → stays `shaping`.
   - none left → `ready-to-implement`.
   - a gap proved the goal infeasible/too costly → `not-viable` (record the
     killer finding).
5. **Surface decisions in a batch.** At the end of the pass, present the open
   `[user]` gaps (with the assumption you ran with for each) and any remaining
   `[agent]` gaps still open after the budget. Resolving a gap may close it or
   spawn new gaps — re-run `/poc work` afterward.

## Rules

- **Execution never blocks on a human.** Decisions become deferred gaps, not stop
  points.
- Move proven knowledge *into Implementation* with provenance — don't leave
  findings buried in chat.
- Keep directives verifiable: every "what to do" gets a done-check.
- Reference codebase by path; never copy production code into the file.
- Report progress as a short summary: gaps closed this pass, findings added,
  decisions awaiting the developer, remaining `[agent]` gaps, new phase.
