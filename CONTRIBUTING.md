# Contributing to POCDD

Thanks for helping improve POCDD. This guide is for **humans working on the
repo**. The parallel [`AGENTS.md`](AGENTS.md) is the contract for AI agents
working on it — the two are consistent, so read whichever fits you.

## TL;DR

```bash
git clone https://github.com/DailybotHQ/pocdd-skill.git
cd pocdd-skill
git checkout -b feat/my-change
# … make your change …
./scripts/check.sh          # must pass before you push
git commit -m "feat: short description"
git push -u origin HEAD     # then open a PR into main
```

## What this repo is

An installable, cross-agent **agent skill** that implements the POCDD
methodology — Markdown plus a couple of small Bash helpers, following the
[Open Agent Skills](https://agentskills.io) standard, MIT-licensed. The agent
pack under `skills/pocdd/` is **generated** by `./configure` from
`build/fragments/`.

## The ship boundary (read this first)

**Only [`skills/pocdd/`](skills/pocdd/) ships.** Everything else — `README.md`,
`AGENTS.md`, `CONTRIBUTING.md`, `SECURITY.md`, `setup.sh`, `configure`, `build/`,
`scripts/`, `docs/`, `.github/` — is repository infrastructure. The skill must
run correctly for someone who installed **only** `skills/pocdd/`, so nothing
under it may reference those repo-dev files at runtime. `./scripts/check.sh`
enforces this.

## Making a change

| You're changing… | Also update… |
|---|---|
| A `/poc` command's behavior | the fragment under `build/fragments/skills/<cmd>/`, then `./configure --yes …` |
| The methodology (gaps, phases, three sections, done criteria) | `docs/POCDD.md` **and** `build/fragments/conventions/*.md.tmpl`, then regenerate |
| `gaps_per_pass` / profile / languages | `build/configure.sh` + `build/detect.sh`; regenerate the committed mid pack |
| Any `SKILL.md` frontmatter | keep the `version` in lockstep (also `VERSION` in `build/configure.sh`) |
| Anything user-visible | `CHANGELOG.md` |

Regenerate the committed default pack after fragment edits:

```bash
./configure --yes --lang python,md --gaps 2 --profile mid --layout single_root
```

### SKILL.md frontmatter contract

Every `SKILL.md` carries valid YAML frontmatter opening on line 1:

```yaml
---
name: pocdd[-<command>]          # router is "pocdd"; sub-skills "pocdd-<command>"
description: <when to use — this drives auto-routing; be specific>
version: "<x.y.z>"               # identical across every SKILL.md
documentation_url: https://github.com/DailybotHQ/pocdd-skill
user-invocable: true
allowed-tools: <minimal set>     # read-only skills omit Edit/Write
---
```

The `description` is load-bearing — it's how an agent decides to fire the skill.

## Checks

Run everything CI runs, locally, with one command:

```bash
./scripts/check.sh
```

It validates:

1. **Shell syntax** — `bash -n` on every script (and `shellcheck` if installed).
2. **Frontmatter** — required keys present and `version` in lockstep.
3. **Well-formedness** — `verify.sh` passes against the shipped templates.
4. **Ship boundary** — `skills/pocdd/` references nothing repo-dev at runtime.
5. **Light-context** — no mandatory full-spec load; `gaps_per_pass` baked in.
6. **Configure determinism** — identical `./configure --yes` mid runs match.
7. **Installation validation** — `setup.sh` links a loadable pack in an isolated HOME.

## Trying the skill locally

Symlink the skill into your agent's skills directory, then invoke `/poc`:

```bash
./setup.sh --host claude   # or: cursor, codex, copilot, gemini, windsurf, cline, opencode, antigravity
```

`.pocs/` (the per-developer working directory the skill creates) is gitignored —
never commit POC working state, tokens, or caches.

## Commit & PR conventions

- **Commits:** [Conventional Commits](https://www.conventionalcommits.org/) —
  `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`.
- **Language:** English everywhere.
- **PRs:** target `main`, keep them focused, and make sure `./scripts/check.sh`
  passes. Fill in the PR template. CI runs the same checks on every PR.

## Questions

Open an issue using one of the [issue templates](.github/ISSUE_TEMPLATE/). For
the design rationale behind the lean structure, see
[`docs/DESIGN.md`](docs/DESIGN.md).
