# AGENTS.md — POCDD skill pack

Rules for agents working **on** this repository (not for using POCDD — that's the
`skills/pocdd/` content and the [`README.md`](README.md)).

## What this repo is

An installable, cross-agent **agent skill** that implements the POCDD methodology.
Markdown-only (plus small Bash/Python helpers), [Open Agent Skills](https://agentskills.io)
standard, MIT.

## Ship boundary (critical)

**Only `skills/pocdd/` ships.** Everything else — `README.md`, `AGENTS.md`,
`CLAUDE.md`, `CONTRIBUTING.md`, `SECURITY.md`, `setup.sh`, `CHANGELOG.md`,
`scripts/`, `docs/`, `.github/`, `.gitignore` — is repo-dev infrastructure and
must never be referenced by the skill at runtime. When in doubt, ask: "would a
user who installed only `skills/pocdd/` still have this?" (`scripts/check.sh`
enforces this boundary.)

## Skill layout

```
skills/pocdd/
├── SKILL.md            router — routes the /poc surface by intent
├── <command>/SKILL.md  one folder per /poc command (create, work, status, list,
│                        implement, archive, remove, clear, verify)
├── shared/             context.sh (resolves .pocs/), conventions.md (the contract)
├── spec/POCDD.md       the methodology + philosophy (canonical)
└── templates/          poc.md (reasoned) + poc.py (runnable)
```

## SKILL.md frontmatter contract

Every `SKILL.md` MUST carry valid YAML frontmatter:

```yaml
---
name: pocdd[-<command>]          # router is "pocdd"; sub-skills "pocdd-<command>"
description: <when to use — drives auto-routing; be specific>
version: "<x.y.z>"               # keep all skills in lockstep
documentation_url: https://github.com/DailybotHQ/pocdd-skill
user-invocable: true
allowed-tools: <minimal set>     # read-only skills omit Edit/Write
---
```

- The `description` is load-bearing — it's how agents decide to fire the skill.
- Keep `version` identical across the router and all sub-skills; bump together.

## Methodology source of truth

The methodology is `skills/pocdd/spec/POCDD.md` and the operational contract is
`skills/pocdd/shared/conventions.md`. If you change a rule (gap tagging,
provenance, the three sections, done criteria, the command set), update **both**
the spec and any sub-skill that references it, and record the decision in the
spec's "Design decisions" table.

## Conventions

- **Language:** English everywhere.
- **Commits:** Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:` …).
- **Shell:** POSIX-friendly Bash; `shared/context.sh` is *sourced*, so it must not
  enable `set -e`/`set -u` globally. Run `bash -n` on scripts before committing.
- **`.pocs/`** is gitignored — never commit POC working state, tokens, or caches.

## Pre-commit checklist

Run `./scripts/check.sh` — it covers 1–3 below (and is what CI runs). Then confirm 4.

1. Shell syntax (`bash -n`) + `shellcheck` on every script.
2. Every `SKILL.md` has complete, valid frontmatter with the lockstep `version`.
3. Nothing outside `skills/pocdd/` is required at runtime (ship boundary holds).
4. `CHANGELOG.md` updated for user-visible changes.
