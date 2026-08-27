# Changelog

All notable changes to the POCDD skill pack are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); versioning is
[SemVer](https://semver.org/). The router and all sub-skills share one version.

## [Unreleased]

## [0.2.0] - 2026-08-04

### Added

- **Build-at-install configure** — `./configure` (and `build/configure.sh`)
  detects RAM/VRAM, stack languages, and repo layout; asks with recommendations;
  generates a slim `skills/pocdd/` pack baked with `gaps_per_pass`, conventions
  profile (`light|mid|full`), and only the selected language templates.
- `build/detect.sh` hardware/stack/layout probes; fragments under
  `build/fragments/` (authoring source of truth).
- JS and Go runnable POC templates (`poc.js`, `poc.go`) selectable via
  `--lang`.
- `setup.sh --configure` / `--skip-configure` and forwarded configure flags.
- `scripts/test-install.sh` — validates `setup.sh` in an isolated HOME (CI gate).
- Human-facing methodology at `docs/POCDD.md` (no longer inside the agent pack).

### Changed

- Agent pack is **generated**; committed default is **mid** (`python,md`,
  `gaps_per_pass=2`). Router requires only `shared/conventions.md` — no mandatory
  full-spec load.
- `/poc work` closes at most `gaps_per_pass` `[agent]` gaps per invocation.
- `verify.sh` scopes gap / ready-to-implement checks to the **Remaining gaps**
  section only.
- `scripts/check.sh` asserts light-context rules and configure determinism.
- Version lockstep bumped to **0.2.0**.

### Removed

- `skills/pocdd/spec/POCDD.md` from the shipped pack (moved to `docs/POCDD.md`).

## [0.1.0] - 2026-06-30

### Added

- Initial POCDD skill pack scaffold.
- Router (`skills/pocdd/SKILL.md`) for the `/poc` command surface with the
  reserved-subcommand-vs-SOURCE parsing rule.
- Sub-skills: `create`, `work` (gap-closing engine), `status`, `list`,
  `implement`, `archive`, `remove`, `clear`, `verify`.
- Shared `context.sh` (resolves the gitignored `.pocs/` directory, `POCS_DIR`
  override) and `conventions.md` (the operational contract).
- Methodology spec at `spec/POCDD.md`; `poc.md` / `poc.py` templates.
- `verify/verify.sh` well-formedness check.
- Repo scaffolding: `README.md`, `AGENTS.md` (+ `CLAUDE.md` symlink), `setup.sh`,
  `.gitignore`, `docs/DESIGN.md`.

### Changed (pre-0.2 polish)

- Corrected the repository URL from `DailybotHQ/POCDD` to `DailybotHQ/pocdd-skill`
  across every `SKILL.md` (`documentation_url` + router `homepage`), `AGENTS.md`,
  and the README install commands.
- Reworked the README for readability: badges, table of contents, a repository
  layout map, and a local-development section.
- `setup.sh` now self-clones into a cache dir (`POCDD_HOME`) when run outside a
  clone, enabling a `curl | bash` install.
- More install methods in the README: `pnpm dlx` / `yarn dlx` / `bunx` runners,
  a `curl | bash` one-liner, and an "ask your agent" prompt.
- `CONTRIBUTING.md` (human contributor guide) and `SECURITY.md`.
- `scripts/check.sh` — one command that runs every gate.
- GitHub Actions CI (`.github/workflows/ci.yml`) running `scripts/check.sh`.
- Pull request template and bug/feature issue templates under `.github/`.
