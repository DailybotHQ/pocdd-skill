---
name: pocdd-archive
description: Archive a done POC out of the active set but keep it as a parity/regression oracle, moving it under .pocs/archive/. Use for "/poc archive <name>" after implementation.
version: "0.1.0"
documentation_url: https://github.com/DailybotHQ/pocdd-skill
user-invocable: true
allowed-tools: Bash, Read, Glob
---

# POCDD — Archive

Retain a POC as a parity oracle without cluttering the active list. Resolve it
with `pocdd_resolve <name>` from [`../shared/context.sh`](../shared/context.sh).

## Procedure

1. Confirm the POC exists and report its current phase.
2. Move it into an `archive/` subfolder of `.pocs/` (still gitignored):
   ```bash
   . "$(dirname "$0")/../shared/context.sh"
   dir="$(pocdd_dir)"; mkdir -p "$dir/archive"
   mv "$(pocdd_resolve <name>)" "$dir/archive/"
   ```
3. Report the new location and that it remains usable as a regression check
   ("did the provider change its JSON shape?") — runnable POCs especially.

Prefer **archive** over **remove** when the external API is volatile, the POC is
still useful for onboarding, or integration tests don't yet cover its signal.
