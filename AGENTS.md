# AGENTS.md — POCDD skill pack

Rules for agents working **on** this repository (not for using POCDD — that's the
generated `skills/pocdd/` content and the [`README.md`](README.md)).

## What this repo is

An installable, cross-agent **agent skill** that implements the POCDD methodology.
Markdown-only (plus small Bash/Python helpers), [Open Agent Skills](https://agentskills.io)
standard, MIT.

## Ship boundary (critical)

**Only `skills/pocdd/` ships.** Everything else — `README.md`, `AGENTS.md`,
`CLAUDE.md`, `CONTRIBUTING.md`, `SECURITY.md`, `setup.sh`, `configure`, `build/`,
`CHANGELOG.md`, `scripts/`, `docs/`, `.github/`, `.gitignore` — is repo-dev
infrastructure and must never be referenced by the skill at runtime. When in
doubt, ask: "would a user who installed only `skills/pocdd/` still have this?"
(`scripts/check.sh` enforces this boundary.)

## Source vs generated

```
build/                      # authoring sources (NOT loaded by agents)
├── configure.sh            # interactive generator
├── detect.sh               # RAM/VRAM + stack + layout probes
└── fragments/              # SKILL.md templates, conventions, language templates

skills/pocdd/               # GENERATED pack (what agents load; committed default = mid)
├── SKILL.md                # router — requires conventions only
├── <command>/SKILL.md
├── shared/                 # context.sh + conventions.md (profile-baked)
├── templates/              # only languages selected at configure time
└── .generated              # profile marker

docs/POCDD.md               # full methodology (human-facing; not in the pack)
```

Edit fragments under `build/`, then regenerate:

```bash
./configure --yes --lang python,md --gaps 2 --profile mid --layout single_root
```

Never hand-edit `skills/pocdd/` as the long-term source of truth — it will be
overwritten by configure.

## SKILL.md frontmatter contract

Every `SKILL.md` MUST carry valid YAML frontmatter:

```yaml
---
name: pocdd[-<command>]          # router is "pocdd"; sub-skills "pocdd-<command>"
description: <when to use — drives auto-routing; be specific>
version: "<x.y.z>"               # keep all skills in lockstep (also VERSION in configure.sh)
documentation_url: https://github.com/DailybotHQ/pocdd-skill
user-invocable: true
allowed-tools: <minimal set>     # read-only skills omit Edit/Write
---
```

- The `description` is load-bearing — it's how agents decide to fire the skill.
- Keep `version` identical across the router and all sub-skills; bump together
  (and bump `VERSION` in `build/configure.sh`).

## Methodology source of truth

- **Human / philosophy:** [`docs/POCDD.md`](docs/POCDD.md)
- **Agent operational contract:** generated `skills/pocdd/shared/conventions.md`
  (from `build/fragments/conventions/{light,mid,full}.md.tmpl`)

If you change a rule (gap tagging, provenance, the three sections, done criteria,
the command set, gaps-per-pass behavior), update the fragments **and**
`docs/POCDD.md`, then regenerate the pack.

## Conventions

- **Language:** English everywhere.
- **Commits:** Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:` …).
- **Shell:** POSIX-friendly Bash; `shared/context.sh` is *sourced*, so it must not
  enable `set -e`/`set -u` globally. Run `bash -n` on scripts before committing.
- **`.pocs/`** and **`.pocdd/`** are gitignored — never commit POC working state,
  tokens, caches, or local machine profiles.

## Pre-commit checklist

Run `./scripts/check.sh` — it covers the gates below (and is what CI runs). Then
confirm CHANGELOG for user-visible changes.

1. Shell syntax (`bash -n`) + `shellcheck` on every script.
2. Every `SKILL.md` has complete, valid frontmatter with the lockstep `version`.
3. Nothing outside `skills/pocdd/` is required at runtime (ship boundary holds).
4. Pack stays light: router must not mandate loading full methodology; `configure
   --yes` is deterministic for the committed mid defaults.
5. Installation validation (`scripts/test-install.sh`) — `setup.sh` links a loadable pack.
