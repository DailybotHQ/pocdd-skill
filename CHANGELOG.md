# Changelog

All notable changes to the POCDD skill pack are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); versioning is
[SemVer](https://semver.org/). The router and all sub-skills share one version.

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
