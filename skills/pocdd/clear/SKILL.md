---
name: pocdd-clear
description: Wipe the .pocs/ directory after confirmation. Use for "/poc clear". Destructive — always confirm and show what will be removed first.
version: "0.1.0"
documentation_url: https://github.com/DailybotHQ/POCDD
user-invocable: true
allowed-tools: Bash, Read, Glob
---

# POCDD — Clear

Empty the entire `.pocs/` directory. Resolve it with
[`../shared/context.sh`](../shared/context.sh).

## Procedure

1. **Show the full inventory first** — list every file (including `archive/` and
   any sidecar tokens) that will be removed:
   ```bash
   . "$(dirname "$0")/../shared/context.sh"
   dir="$(pocdd_dir)"; [ -d "$dir" ] && find "$dir" -type f | sort
   ```
2. **Confirm explicitly** — this deletes *all* POCs at once and cannot be undone.
   If the developer only wants one gone, route to `/poc remove <name>` instead.
3. On confirmation, remove the contents (keep the directory):
   ```bash
   rm -rf "$dir"/* "$dir"/.[!.]* 2>/dev/null || true
   ```
4. Report what was cleared. Remind that any in-flight feature work in those POCs
   is gone — re-bootstrap with `/poc <SOURCE>`.

> `.pocs/` is gitignored, so there is no git history to recover from. Treat this as
> a real deletion.
