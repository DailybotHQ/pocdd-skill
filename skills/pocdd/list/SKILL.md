---
name: pocdd-list
description: List every POC in .pocs/ with its phase and gap counts (split by [agent]/[user]). Read-only. Use for "/poc list" or "show the pocs".
version: "0.1.0"
documentation_url: https://github.com/DailybotHQ/pocdd-skill
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob
---

# POCDD — List

Read-only overview of all POCs. Enumerate with `pocdd_list` from
[`../shared/context.sh`](../shared/context.sh):

```bash
. "$(dirname "$0")/../shared/context.sh"
pocdd_list
```

For each file, read its header/sections and print a compact table:

| POC | Format | Phase | `[agent]` gaps | `[user]` gaps |
|-----|--------|-------|----------------|----------------|

- **Format** = the extension (`.md` reasoned / `.py`,`.js`,… runnable).
- A POC with `0 / 0` gaps and phase `ready-to-implement` is ready for
  `/poc implement`.
- If `.pocs/` is empty or absent, say so and suggest `/poc <SOURCE>` to start one.

Do not modify any file.
