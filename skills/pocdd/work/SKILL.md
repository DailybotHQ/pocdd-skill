---
name: pocdd-work
description: Run the POCDD gap-closing loop on an existing POC file — close [agent] investigation gaps autonomously, defer [user] decision gaps with a recorded assumption, and advance the file toward ready-to-implement without ever stopping execution. Use for "/poc work <name>" or "close the gaps".
version: "0.1.0"
documentation_url: https://github.com/DailybotHQ/POCDD
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob, Edit, Write
---

# POCDD — Work (the gap-closing engine)

This is the heart of POCDD. Read [`../shared/conventions.md`](../shared/conventions.md)
first. Resolve the target with `pocdd_resolve <name>` from
[`../shared/context.sh`](../shared/context.sh).

## The loop

1. **Load the POC fully** — Goal, Implementation, Remaining gaps, `phase`. Set
   `phase: shaping`.
2. **Work every `[agent]` gap autonomously.** For each, in id order:
   - Do the investigation: run the script (for runnable POCs, with the relevant
     flags), read the referenced code paths, or diff output against expectations.
   - Capture the result as a **Finding** in **Implementation**, tagged with
     provenance (`[ran it]`, `[code: path:line]`, …).
   - Remove the gap from **Remaining gaps**. Add any **newly discovered** gaps.
3. **Defer every `[user]` gap — never stop.** For each decision gap:
   - Record a **default assumption** to proceed with.
   - **Link** the dependent Implementation (e.g. *"§4 assumes G3 = hourly"*).
   - Leave the gap in **Remaining gaps** (owner `[user]`); keep working.
4. **Re-derive the phase:**
   - any gaps left → stays `shaping`.
   - none left → `ready-to-implement`.
   - a gap proved the goal infeasible/too costly → `not-viable` (record the
     killer finding).
5. **Surface decisions in a batch.** At the end of the pass, present the open
   `[user]` gaps (with the assumption you ran with for each) so the developer can
   resolve them in one go. Resolving a gap may close it or spawn new gaps —
   re-run the loop afterward.

## Rules

- **Execution never blocks on a human.** Decisions become deferred gaps, not stop
  points.
- Move proven knowledge *into Implementation* with provenance — don't leave
  findings buried in chat.
- Keep directives verifiable: every "what to do" gets a done-check.
- Reference codebase by path; never copy production code into the file.
- Report progress as a short summary: gaps closed, findings added, decisions
  awaiting the developer, new phase.
