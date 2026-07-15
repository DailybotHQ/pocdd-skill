---
name: pocdd-remove
description: Delete a single POC file from .pocs/ after confirmation. Use for "/poc remove <name>". Destructive — always confirm first.
version: "0.1.0"
documentation_url: https://github.com/DailybotHQ/pocdd-skill
user-invocable: true
allowed-tools: Bash, Read, Glob
---

# POCDD — Remove

Delete one POC. Resolve it with `pocdd_resolve <name>` from
[`../shared/context.sh`](../shared/context.sh).

## Procedure

1. Resolve the file and **show what will be deleted** (path + phase). If the name
   is ambiguous or not found, stop and list the candidates from `pocdd_list`.
2. **Confirm with the developer** before deleting — this is destructive.
3. Delete the file:
   ```bash
   rm -i "$(pocdd_resolve <name>)"
   ```
4. If the POC had a sidecar token/cache (e.g. `.pocs/.<name>_token.json`,
   `__pycache__`), mention it and offer to remove it too — but never delete
   credentials without saying so.

Prefer `/poc archive <name>` when the POC still has signal. Use **remove** only
when it duplicated the product 1:1 with nothing extra to offer.
