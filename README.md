# POCDD — POC Driven Development

**Models matter. Context matters more.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Format: Open Agent Skills](https://img.shields.io/badge/format-Open%20Agent%20Skills-blue.svg)](https://agentskills.io)
[![CI](https://github.com/DailybotHQ/pocdd-skill/actions/workflows/ci.yml/badge.svg)](https://github.com/DailybotHQ/pocdd-skill/actions/workflows/ci.yml)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

POCDD is a methodology — and an installable agent skill — for building complex
product features with AI agents. For each feature you own **one self-contained
file** under `.pocs/`: the *prompt*, the *spec*, and the *handoff* in a single
artifact. An agent **closes gaps** in that file until nothing blocks the goal, then
the proven result is implemented into the product.

- **License:** [MIT](LICENSE)
- **Format:** [Open Agent Skills](https://agentskills.io) standard (Markdown-only)
- **Methodology:** [`docs/POCDD.md`](docs/POCDD.md) (human-facing)
- **Agent pack:** generated `skills/pocdd/` — slim by design; tune with `./configure`

---

## Contents

- [The idea in one breath](#the-idea-in-one-breath)
- [The `/poc` commands](#the-poc-commands)
- [Install](#install)
- [Configure (light pack / Ollama)](#configure-light-pack--ollama)
- [How to use](#how-to-use)
- [The `.pocs/` convention](#the-pocs-convention)
- [Repository layout](#repository-layout)
- [Local development](#local-development)
- [What ships](#what-ships)
- [Contributing](#contributing)

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
| `/poc work <name>` | Run the gap-closing loop (at most `gaps_per_pass` `[agent]` gaps per call) |
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

Six install paths, from easiest to most manual. All leave `skills/pocdd/` discoverable
by your agent. If you're unsure, use **Method 2** (`npx skills add`) or **Method 1**
(ask your agent).

### Quick comparison

| Method | When to use | TL;DR |
|--------|-------------|-------|
| 1. Ask your agent | Zero ceremony — paste a prompt | *"Install POCDD from `DailybotHQ/pocdd-skill`"* |
| 2. `npx skills add` (recommended) | Any agent, Node available | `npx skills add DailybotHQ/pocdd-skill` |
| 3. curl `setup.sh` | No Node, want a one-liner | `curl …/setup.sh \| bash` |
| 4. Git clone + `setup.sh` | Explicit control, optional `./configure` | `git clone … && ./setup.sh` |
| 5. Manual per-agent | One agent, no symlink script | clone/symlink into `~/.<agent>/skills/pocdd` |
| 6. Try without installing | One-off session, no disk write | `npx skills use DailybotHQ/pocdd-skill@pocdd` |

The published pack is the **committed mid default** (Python + Markdown templates,
`gaps_per_pass=2`). To retune after install, clone the repo and run `./configure`.

### Method 1 — Ask your agent (prompt install)

Paste one of these into **any** coding agent that can run shell commands or clone
repos (Cursor, Claude Code, Codex, Copilot, Windsurf, Cline, Gemini CLI, OpenClaw,
Antigravity, …):

**Short**

> Install the POCDD agent skill: run `npx skills add DailybotHQ/pocdd-skill`.

**Full (recommended)**

> Install the POCDD agent skill from
> https://github.com/DailybotHQ/pocdd-skill (Open Agent Skills standard).
> Prefer `npx skills add DailybotHQ/pocdd-skill` (or `pnpm dlx` / `yarn dlx` /
> `bunx` with the same command). If Node isn't available, clone the repo and run
> `./setup.sh`. On a low-RAM or Ollama machine, also run `./configure` so the pack
> stays light (`gaps_per_pass=1`). Then I can use `/poc` commands.

**Point at the skill file**

> Fetch https://raw.githubusercontent.com/DailybotHQ/pocdd-skill/main/skills/pocdd/SKILL.md
> and install this skill pack into my agent's skills directory.

Agents with WebFetch can read the repo README or `SKILL.md` and follow the install
steps themselves — same pattern as conversational installs for other Open Agent
Skills packs.

### Method 2 — `skills` CLI (cross-agent, recommended)

Uses the [skills.sh](https://skills.sh) CLI ([Vercel skills](https://github.com/vercel-labs/skills)).
Auto-detects installed agents and links `skills/pocdd/` into each one's skills dir.

```bash
npx     skills add DailybotHQ/pocdd-skill   # npm
pnpm dlx skills add DailybotHQ/pocdd-skill  # pnpm
yarn dlx skills add DailybotHQ/pocdd-skill  # yarn
bunx    skills add DailybotHQ/pocdd-skill   # bun
```

Useful flags:

| Flag | Purpose |
|------|---------|
| `--list` | Show skills in the repo without installing |
| `-a <agents>` | Install for specific agents only (comma-separated) |
| `-g, --global` | Install globally (`~/.<agent>/skills/`) instead of project-level |
| `--copy` | Copy files instead of symlinking |
| `-y` | Skip prompts (CI-friendly) |
| `--all` | Shorthand for `--skill '*' --agent '*' -y` |

Per-agent examples (`-a` names match the [Skills CLI](https://github.com/vercel-labs/skills) registry):

```bash
# One agent
npx skills add DailybotHQ/pocdd-skill -a claude-code -y
npx skills add DailybotHQ/pocdd-skill -a cursor -y
npx skills add DailybotHQ/pocdd-skill -a codex -y
npx skills add DailybotHQ/pocdd-skill -a windsurf -y
npx skills add DailybotHQ/pocdd-skill -a github-copilot -y
npx skills add DailybotHQ/pocdd-skill -a cline -y
npx skills add DailybotHQ/pocdd-skill -a gemini-cli -y
npx skills add DailybotHQ/pocdd-skill -a opencode -y
npx skills add DailybotHQ/pocdd-skill -a openclaw -y
npx skills add DailybotHQ/pocdd-skill -a antigravity -y

# Several agents at once
npx skills add DailybotHQ/pocdd-skill -a claude-code,cursor,codex -y

# Every agent the CLI knows about
npx skills add DailybotHQ/pocdd-skill --all
```

**Supported clients** (non-exhaustive — the CLI also supports Amp, Continue, Crush,
Devin, Junie, Kilo, Roo, Trae, Zed, and [many more](https://skills.sh)):
Claude Code, Cursor, OpenAI Codex, Windsurf, GitHub Copilot, Cline, Gemini CLI,
OpenCode, OpenClaw, Antigravity.

**Project vs global:** project install drops the pack under the repo (e.g.
`.agents/skills/pocdd/` when the repo uses an `.agents/` harness, or the agent's
project skills path). Global install (`-g`) puts it in `~/.<agent>/skills/pocdd`.

Update later: `npx skills update DailybotHQ/pocdd-skill` · Uninstall:
`npx skills remove pocdd`

### Method 3 — curl (no Node required)

```bash
curl -fsSL https://raw.githubusercontent.com/DailybotHQ/pocdd-skill/main/setup.sh | bash
# one agent:
curl -fsSL https://raw.githubusercontent.com/DailybotHQ/pocdd-skill/main/setup.sh | bash -s -- --host cursor
```

`setup.sh` accepts `--host` values: `claude`, `cursor`, `codex`, `windsurf`,
`copilot`, `cline`, `gemini`, `opencode`, `antigravity` (maps to each agent's
`~/.<agent>/skills/` path — see Method 5 table).

### Method 4 — Git clone + `setup.sh`

```bash
git clone https://github.com/DailybotHQ/pocdd-skill.git ~/pocdd-skill
cd ~/pocdd-skill
./configure          # recommended on Ollama / low-RAM — asks with recommendations
./setup.sh           # symlink into detected agents
./setup.sh --host claude
```

`setup.sh` can also run configure for you: `./setup.sh --configure --yes`.

### Method 5 — Manual per-agent

Symlink or clone into the agent's skills directory. POCDD ships as **one** router
pack (`skills/pocdd/`); link that folder as `pocdd`:

```bash
# Example: Claude Code
ln -sfn ~/pocdd-skill/skills/pocdd ~/.claude/skills/pocdd

# Example: Cursor
ln -sfn ~/pocdd-skill/skills/pocdd ~/.cursor/skills/pocdd
```

| Agent | Skills path | `setup.sh --host` | `skills add -a` |
|-------|-------------|-------------------|-----------------|
| Claude Code | `~/.claude/skills/pocdd` | `claude` | `claude-code` |
| Cursor | `~/.cursor/skills/pocdd` | `cursor` | `cursor` |
| OpenAI Codex | `~/.codex/skills/pocdd` | `codex` | `codex` |
| Windsurf | `~/.codeium/windsurf/skills/pocdd` | `windsurf` | `windsurf` |
| GitHub Copilot | `~/.copilot/skills/pocdd` | `copilot` | `github-copilot` |
| Cline | `~/.cline/skills/pocdd` | `cline` | `cline` |
| Gemini CLI | `~/.gemini/skills/pocdd` | `gemini` | `gemini-cli` |
| OpenCode | `~/.config/opencode/skills/pocdd` | `opencode` | `opencode` |
| Antigravity | `~/.antigravity/skills/pocdd` | `antigravity` | `antigravity` |
| OpenClaw | workspace or `~/.openclaw/skills/pocdd` | — | `openclaw` |

### Method 6 — Try without installing

Generate a one-shot prompt that loads the skill for a single session (no symlink):

```bash
npx skills use DailybotHQ/pocdd-skill@pocdd
npx skills use DailybotHQ/pocdd-skill --skill pocdd --agent claude-code
```

### Verify

Restart the agent session (skills are discovered at session start). Then ask:
*"what pocdd skills are available?"* — you should see `pocdd` (and sub-skills if
your agent surfaces them). Or check disk:

```bash
ls -la ~/.cursor/skills/pocdd   # adjust path for your agent
```

### Invoke

- "start a POC for Google Calendar OOO sync" → **pocdd-create**
- "work the calendar poc" / "close the gaps" → **pocdd-work**
- "what's left on calendar?" → **pocdd-status**

## Configure (light pack / Ollama)

`./configure` **builds** `skills/pocdd/` from `build/fragments/` for *this*
machine and stack. It asks three questions and offers a recommendation for each:

| Question | Detection | Recommendation |
|----------|-----------|----------------|
| **POC languages** | `pyproject.toml` / `package.json` / `go.mod` | Detected stack + Markdown |
| **Gaps per `/poc work` pass** | RAM (`MemAvailable`) + discrete VRAM (`nvidia-smi` / `rocm-smi`) | See table below |
| **Repo layout** | `repositories/`, `apps/`, `packages/`, `src/` | Cite-path hint baked into conventions |

**RAM / VRAM → gaps + profile**

| Hardware | `gaps_per_pass` | conventions profile |
|----------|-----------------|---------------------|
| RAM &lt; 8 GiB, or no discrete VRAM and RAM &lt; 12 GiB | **1** | `light` |
| RAM &lt; 16 GiB | **2** | `mid` |
| else, or discrete VRAM ≥ 8 GiB | **3** | `full` |

Examples:

```bash
./configure                          # interactive
./configure --yes                    # accept all recommendations
./configure --yes --lang python,md --gaps 1 --profile light --layout single_root
```

Answers are saved under `.pocdd/profile.json` (gitignored). Re-run anytime.

> **Tip — cheap enough for small models.** Seed gaps once with a stronger model
> (or carefully by hand) at `/poc create`, then let a small local model close
> **one gap per pass** after `./configure` chooses `gaps=1`.

## How to use

**1. Create** a POC from any source:

```
/poc "sync Google Calendar out-of-office into Dailybot time-off"
```

**2. Shape it** — run the gap-closing engine (budget = your configured
`gaps_per_pass`):

```
/poc work calendar
```

**3. Resolve decisions, then loop** until Remaining gaps is empty
(`ready-to-implement`) — or the POC concludes `not-viable`.

**4. Inspect any time:** `/poc status`, `/poc list`, `/poc verify`.

**5. Implement**, then `/poc archive` or `/poc remove`.

## The `.pocs/` convention

All POC files live under `.pocs/` at the repo root — **gitignored in its
entirety**. Override with `POCS_DIR`.

## Repository layout

```text
pocdd-skill/
├── build/                   # authoring sources → ./configure generates the pack
│   ├── configure.sh
│   ├── detect.sh
│   └── fragments/
├── configure                # wrapper → build/configure.sh
├── skills/pocdd/            # ← generated product (what agents load)
├── docs/POCDD.md            # full methodology (human-facing)
├── docs/DESIGN.md
├── scripts/check.sh
├── setup.sh
└── …
```

## Local development

```bash
./configure --yes --lang python,md --gaps 2 --profile mid --layout single_root
./scripts/check.sh          # includes installation validation (setup.sh in a temp HOME)
```

See [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`AGENTS.md`](AGENTS.md).

## What ships

Only [`skills/pocdd/`](skills/pocdd/) is the product. `build/`, `docs/`, `setup.sh`,
`configure`, and the rest are repository infrastructure and are **not** what
`npx skills` installs as runtime agent context (the CLI copies/links the skill
folder; configure lives in the clone for retuning).

## Contributing

Start with [`CONTRIBUTING.md`](CONTRIBUTING.md). Design rationale:
[`docs/DESIGN.md`](docs/DESIGN.md).

## Powered by Dailybot

[Dailybot](https://dailybot.com) keeps people and agents visible — async
check-ins, AI summaries, and progress reporting — so long-running agents never go
dark.
