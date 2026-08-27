<!--
POCDD file (reasoned form). One feature, one file, under .pocs/ (gitignored).
Use this when the hard part is internal/domain complexity (no runtime to prove).
Keep the three sections. Reference the codebase by path; never paste production code.
-->

phase: spike

# POC: <Feature name> (<source / issue id>)

## Goal

<One paragraph: what this must achieve, captured from the source. The fixed target
the loop drives toward.>

## Implementation

> The proven solution design — grows as gaps close. Two registers:
> **Findings** (past tense, with provenance) and **Directives** (imperative, each
> with a verifiable done-check). Reference code by path; do not copy it in.

### Findings

- _(none yet)_ <!-- e.g. "Manager X already filters Y. [code: repo/app/models.py:120]" -->

### Directives

- _(none yet)_ <!-- e.g. "Create <Service>.run() in repo/app/services.py. Done when: pytest test_x.py passes." -->

## Remaining gaps

> Worklist + progress bar. Done when empty. Tag every gap by owner and id.
> Decisions never stop execution: record a default assumption and link the
> affected Implementation, then keep going.

- `G1` `[agent]` <investigation the agent can close itself (run / read / prove)>
- `G2` `[user]` <decision only a human can make> — _assumption:_ <default in use>; _affects:_ <Implementation §>
