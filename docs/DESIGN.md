# DESIGN — why POCDD is shaped this way

This is the *why* behind the layout. The *what* is [`../README.md`](../README.md);
the methodology is [`../skills/pocdd/spec/POCDD.md`](../skills/pocdd/spec/POCDD.md).

## One thesis

For an AI agent, **context is the scarce resource**, so a feature is best owned by
**one bounded artifact**. POCDD makes that artifact the unit of everything: the
prompt to start from, the spec to shape, and the handoff to implement from.

## Why one file per feature (under `.pocs/`)

- A single self-contained file fits an agent's working context — read one thing to
  get oriented, then open only the few paths a step needs.
- It is tool-agnostic and resumable: any agent (Cursor, Claude, Copilot, …) can
  pick it up cold.
- It is **gitignored** because POC files are per-developer working state, not
  source. The durable record is the methodology plus whatever graduates into
  `docs/` and the product. (This mirrors DeepWorkPlan's `.dwp/`.)

## Why three sections + typed gaps

- **Goal / Implementation / Remaining gaps** is the smallest structure that still
  separates *what we want*, *what we've proven*, and *what's left* — so an agent
  always knows where to look.
- Gaps are **typed by owner** (`[agent]` vs `[user]`) because "done = no gaps" is
  only meaningful if you distinguish what the agent can close from what needs a
  human. The gap list doubles as the progress bar.
- Decisions become **deferred gaps with a recorded assumption + link** so the
  agent never blocks on a human, yet "continue past a decision" stays traceable
  instead of becoming silent rework.

## Why a router + one folder per command

Mirrors the Open Agent Skills pattern: a router `SKILL.md` maps intent to a
sub-skill, and each `/poc` command is its own folder so it is independently
discoverable and 1:1 with the command surface. Simple commands stay small; the
real weight is in `work/` (the gap-closing engine).

## Inspired by DeepWorkPlan, intentionally leaner

[DeepWorkPlan](https://github.com/DailybotHQ/deepworkplan-skill) proved the
"repo-as-harness, skill-as-methodology" pattern. POCDD borrows the router +
sub-skill structure, the frontmatter contract, the `shared/context.sh` path
resolution, and the ship-boundary discipline — but **drops** onboarding, authoring,
refine/resume, addons, and archetypes. POCDD is one methodology with one command
surface; the structure stays small on purpose.
