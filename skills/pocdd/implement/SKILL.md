---
name: pocdd-implement
description: Port a ready-to-implement POC's Implementation section into the product, executing each directive against its acceptance check. Use for "/poc implement <name>" once the POC's gaps are closed.
version: "0.1.0"
documentation_url: https://github.com/DailybotHQ/pocdd-skill
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob, Edit, Write
---

# POCDD — Implement (the implementation stage)

Move the **proven** Implementation into the product. Read
[`../shared/conventions.md`](../shared/conventions.md) and the target POC first;
resolve it with `pocdd_resolve <name>`.

## Precondition

The POC should be `phase: ready-to-implement` (Remaining gaps empty). If it is
not, **stop and report**: list the open gaps and route to `/poc work <name>` or a
decision batch instead of porting on top of unresolved gaps.

## Porting order

Drive from the Implementation section's directives — each carries an acceptance
check; satisfy it.

1. **Lift datatypes and pure functions first** (the domain model, filter helpers,
   the core computation) into the appropriate production package.
2. **Wrap with framework boundaries** — views/endpoints, permissions, feature
   flags, settings.
3. **Mirror proven behavior** — each production capability maps to a Finding or a
   *documented* intentional difference. Preserve dedupe keys / external ids exactly
   as the POC justified them.
4. **UI last** — it consumes the stabilized contract.

## Verification & commits

- For each ported slice, run its acceptance check (the command/test/diff named in
  the directive). For runnable POCs, diff production output against the POC's.
- Commit per slice using the **host repo's** conventions (read its `AGENTS.md`);
  this skill does not impose its own commit rules on the product repo.
- After porting, if the POC was runnable, note that it can be kept as a **parity
  oracle** (`/poc archive <name>`) or removed (`/poc remove <name>`).
