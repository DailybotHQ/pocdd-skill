#!/usr/bin/env python3
"""
POC: <Feature name> (<source / issue id>)

POCDD file (runnable form). One feature, one file, under .pocs/ (gitignored).
Use this when the hard part is unknown external/runtime behavior (API, OAuth,
sync, time zones): the header is the spec, the body below is the proof.

Run from the repo root:

    python .pocs/<name>.py --help
    python .pocs/<name>.py --probe
    python .pocs/<name>.py --demo

Reference the codebase by path; never paste production code into this file.
Store any tokens under gitignored .pocs/ paths (prefer sandbox/test accounts).

phase: spike

Goal
----
<One paragraph: what this must prove/achieve, captured from the source.>

Context (current code)
----------------------
<Production paths this feature will extend, by path: repo/app/file.py:NN>

Implementation
--------------
Findings (past tense, with provenance — [ran it] / [code: path:line] /
[product decision] / [assumption - unverified]):
- <none yet>

Directives (imperative, each with a verifiable done-check):
- <none yet>

Remaining gaps
--------------
Worklist + progress bar. Done when empty. Tag each gap by owner and id.
Decisions never stop execution: record a default assumption + link, then keep going.
- G1 [agent] <investigation the agent can close itself>
- G2 [user]  <decision only a human can make> | assumption: <default> | affects: <directive>
"""
from __future__ import annotations

import argparse
import json
import sys


def probe() -> dict:
    """Cheapest call that proves connectivity / data shape. Replace me."""
    return {"ok": True, "note": "replace probe() with the real provider call"}


def demo() -> dict:
    """Happy-path demonstration of the core behavior. Replace me."""
    return {"ok": True, "note": "replace demo() with the real flow"}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="POCDD spike — <feature>")
    parser.add_argument("--probe", action="store_true", help="cheap connectivity / shape check")
    parser.add_argument("--demo", action="store_true", help="run the happy-path demo")
    parser.add_argument("--json", action="store_true", help="machine-readable output")
    args = parser.parse_args(argv)

    if args.probe:
        result = probe()
    elif args.demo:
        result = demo()
    else:
        parser.print_help()
        return 0

    if args.json:
        print(json.dumps(result, indent=2, default=str))
    else:
        for key, value in result.items():
            print(f"{key}: {value}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
