# POCDD — POC Driven Development

**Models matter. Context matters more.**

POCDD is a methodology — and an installable agent skill — for building complex
product features with AI agents. For each feature you own **one self-contained
file** under `.pocs/`: the *prompt*, the *spec*, and the *handoff* in a single
artifact. An agent **closes gaps** in that file until nothing blocks the goal, then
the proven result is implemented into the product.

- **License:** MIT
- **Format:** [Open Agent Skills](https://agentskills.io) standard (Markdown-only)
- **Methodology:** [`skills/pocdd/spec/POCDD.md`](skills/pocdd/spec/POCDD.md)

> Inspired by [DeepWorkPlan](https://github.com/DailybotHQ/deepworkplan-skill),
> built lean for a single methodology and one command surface.

---

## The idea in one breath

A POC file has exactly three sections — **Goal**, **Implementation**, **Remaining
gaps** — and a `phase:` header. It is *done* when Remaining gaps is empty.
Decisions the agent can't make become `[user]` gaps and **never stop execution**:
the agent records a default assumption, links the affected work, and keeps going.

```
/poc SOURCE → [ /poc work : close gaps in a loop ] → /poc implement → /poc archive | /poc remove
```

## The `/poc` commands

| Command | What it does |
|---------|--------------|
| `/poc SOURCE` | Create a POC from any source (sentence, issue, doc, URL); picks format by risk and seeds gaps |
| `/poc work <name>` | Run the gap-closing loop (the engine) |
| `/poc status <name>` | Detailed status of one POC (gaps split by `[agent]`/`[user]`) |
| `/poc list` | List all POCs with phase + gap counts |
| `/poc verify <name>` | Validate a POC file is well-formed (pass/fail) |
| `/poc implement <name>` | Port a ready POC into the product |
| `/poc archive <name>` | Archive a done POC as a parity oracle |
| `/poc remove <name>` | Delete a single POC |
| `/poc clear` | Wipe the `.pocs/` directory |

**Parsing:** the reserved subcommands above take precedence; anything else after
`/poc` is treated as a SOURCE (e.g. `/poc "add holidays sync"`).

## Install

### `npx skills` (cross-agent, recommended)

```bash
npx skills add DailybotHQ/POCDD
```

### Git clone + setup

```bash
git clone https://github.com/DailybotHQ/POCDD.git ~/POCDD
cd ~/POCDD && ./setup.sh           # auto-detect installed agents
./setup.sh --host claude           # or target one agent explicitly
```

`setup.sh` symlinks `skills/pocdd/` into your agent's skills directory so the
router and every `/poc` sub-command are discoverable.

### Invoke

Describe what you want and the agent routes to the right sub-skill, or call a
command directly:

- "start a POC for Google Calendar OOO sync" → **pocdd-create**
- "work the calendar poc" / "close the gaps" → **pocdd-work**
- "what's left on calendar?" → **pocdd-status**

## The `.pocs/` convention

All POC files live under `.pocs/` at the repo root — **gitignored in its
entirety**. POC files are per-developer working state, not committed source; the
durable record is this methodology plus whatever graduates into `docs/` and the
product. Override the location with `POCS_DIR`.

## What ships

Only [`skills/pocdd/`](skills/pocdd/) is the product. Everything else
(`README.md`, `AGENTS.md`, `setup.sh`, `docs/`) is repository infrastructure.

## Contributing

See [`AGENTS.md`](AGENTS.md) for the rules that govern work on the skill (ship
boundary, `SKILL.md` frontmatter contract, versioning, commit format). Background
on the layout is in [`docs/DESIGN.md`](docs/DESIGN.md).

## Powered by Dailybot

[Dailybot](https://dailybot.com) keeps people and agents visible — async
check-ins, AI summaries, and progress reporting — so long-running agents never go
dark.
