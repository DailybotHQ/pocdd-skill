---
name: pocdd
description: POC Driven Development — own a complex feature in one self-contained file under .pocs/, shape it by closing gaps, then implement it into the product. Routes the /poc command surface (create, work, status, list, implement, archive, remove, clear, verify) based on intent. Use when the developer wants to start, shape, inspect, or ship a POC-driven feature.
version: "0.1.0"
documentation_url: https://github.com/DailybotHQ/POCDD
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob, Edit, Write
metadata: {"openclaw":{"emoji":"🧪","homepage":"https://github.com/DailybotHQ/POCDD","requires":{"anyBins":["git","bash"]}}}
---

# POCDD — POC Driven Development (Router)

**Models matter. Context matters more.**

POCDD builds a complex feature by first owning it in **one self-contained file**
under `.pocs/` — the *prompt*, the *spec*, and the *handoff* in a single artifact.
An agent shapes that file by **closing gaps** until nothing blocks the goal, then
the proven result is implemented into the product.

The full methodology and philosophy live in [`spec/POCDD.md`](spec/POCDD.md). The
operational contract every sub-skill relies on lives in
[`shared/conventions.md`](shared/conventions.md). **Read both before acting.**

---

## The model in one breath

```
/poc SOURCE → [ /poc work : close gaps in a loop ] → /poc implement → /poc archive | /poc remove
```

A POC file has exactly three sections — **Goal**, **Implementation**,
**Remaining gaps** — and a `phase:` header. It is *done* when Remaining gaps is
empty. Decisions the agent can't make become `[user]` gaps and **never stop
execution**.

---

## Routing — the `/poc` command surface

Map the developer's intent (or an explicit `/poc …` invocation) to one sub-skill:

| Intent / invocation | Sub-skill | Folder |
|---------------------|-----------|--------|
| "start a POC for X", `/poc <SOURCE>` | **pocdd-create** | [`create/`](create/SKILL.md) |
| "work the POC", "close the gaps", `/poc work <name>` | **pocdd-work** | [`work/`](work/SKILL.md) |
| "what's the status of <name>", `/poc status <name>` | **pocdd-status** | [`status/`](status/SKILL.md) |
| "list pocs", `/poc list` | **pocdd-list** | [`list/`](list/SKILL.md) |
| "implement <name>", `/poc implement <name>` | **pocdd-implement** | [`implement/`](implement/SKILL.md) |
| "archive <name>", `/poc archive <name>` | **pocdd-archive** | [`archive/`](archive/SKILL.md) |
| "remove <name>", `/poc remove <name>` | **pocdd-remove** | [`remove/`](remove/SKILL.md) |
| "clear pocs", `/poc clear` | **pocdd-clear** | [`clear/`](clear/SKILL.md) |
| "validate <name>", `/poc verify <name>` | **pocdd-verify** | [`verify/`](verify/SKILL.md) |

### Parsing rule (resolve ambiguity)

The reserved subcommands — `create`, `work`, `status`, `list`, `implement`,
`archive`, `remove`, `clear`, `verify` — **always take precedence**. Anything else
after `/poc` is treated as a **SOURCE** for creation:

- `/poc list` → list. `/poc work calendar` → work the `calendar` POC.
- `/poc "add holidays sync"` → create a new POC from that source.
- `/poc https://provider.dev/docs` → create from that URL.

(Bare `/poc create <SOURCE>` is also accepted and routes to **pocdd-create**.)

---

## Where POCs live

All POC files live under `.pocs/` at the repo root — **gitignored in its
entirety**. Resolve the directory with [`shared/context.sh`](shared/context.sh)
(`POCS_DIR` overrides the default). Never write POC files anywhere else, and never
commit `.pocs/`.
