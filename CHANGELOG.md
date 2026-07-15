# Changelog

All notable changes to the POCDD skill pack are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); versioning is
[SemVer](https://semver.org/). The router and all sub-skills share one version.

## [Unreleased]

### Changed

- Corrected the repository URL from `DailybotHQ/POCDD` to `DailybotHQ/pocdd-skill`
  across every `SKILL.md` (`documentation_url` + router `homepage`), `AGENTS.md`,
  and the README install commands.
- Reworked the README for readability: badges, table of contents, a repository
  layout map, and a local-development section.
- `setup.sh` now self-clones into a cache dir (`POCDD_HOME`) when run outside a
  clone, enabling a `curl | bash` install.

### Added

- More install methods in the README: `pnpm dlx` / `yarn dlx` / `bunx` runners,
  a `curl | bash` one-liner, and an "ask your agent" prompt.

- `CONTRIBUTING.md` (human contributor guide) and `SECURITY.md`.
- `scripts/check.sh` — one command that runs every gate (shell syntax,
  `shellcheck`, `SKILL.md` frontmatter + version lockstep, template
  well-formedness, ship-boundary).
- GitHub Actions CI (`.github/workflows/ci.yml`) running `scripts/check.sh` on
  every push and PR.
- Pull request template and bug/feature issue templates under `.github/`.

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
