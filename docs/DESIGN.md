# DESIGN — why POCDD is shaped this way

This is the *why* behind the layout. The *what* is [`../README.md`](../README.md);
the methodology is [`POCDD.md`](POCDD.md).

## One thesis

For an AI agent, **context is the scarce resource**, so a feature is best owned by
**one bounded artifact**. POCDD makes that artifact the unit of everything: the
prompt to start from, the spec to shape, and the handoff to implement from.

## Why build-at-install (`./configure`)

Shipping one pack that both fits a 10 GiB Ollama laptop and a high-RAM cloud agent
means either bloating the small machine or starving the large one. Instead:

1. **Author** full fragments under `build/fragments/`.
2. **Configure** once per machine: detect stack, RAM/VRAM, and repo layout; ask
   with recommendations; bake `gaps_per_pass`, conventions profile
   (`light|mid|full`), and language templates into `skills/pocdd/`.
3. **Agents load only the generated pack** — short conventions, no mandatory
   philosophy doc, capped gap-closing loop.

| Signal | Recommendation |
|--------|----------------|
| RAM &lt; 8 GiB, or no discrete VRAM and RAM &lt; 12 GiB | `gaps=1`, `light` |
| RAM &lt; 16 GiB | `gaps=2`, `mid` |
| else / VRAM ≥ 8 GiB | `gaps=3`, `full` |

The committed default pack is **mid** (`python,md`, gaps=2) so
`npx skills add` works without configure. Low-RAM / Ollama users should run
`./configure` (or `./setup.sh --configure`).

## Why one file per feature (under `.pocs/`)

- A single self-contained file fits an agent's working context — read one thing to
  get oriented, then open only the few paths a step needs.
- It is tool-agnostic and resumable: any agent (Cursor, Claude, Copilot, …) can
  pick it up cold.
- It is **gitignored** because POC files are per-developer working state, not
  source. The durable record is the methodology plus whatever graduates into
  `docs/` and the product.

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
- **`gaps_per_pass`** keeps each `/poc work` invocation inside a small model's
  context window; re-run until the list is empty.

## Why a router + one folder per command

Mirrors the Open Agent Skills pattern: a router `SKILL.md` maps intent to a
sub-skill, and each `/poc` command is its own folder so it is independently
discoverable and 1:1 with the command surface. Simple commands stay small; the
real weight is in `work/` (the gap-closing engine).
