#!/usr/bin/env node
/**
 * POC: <Feature name> (<source / issue id>)
 *
 * POCDD file (runnable form). One feature, one file, under .pocs/ (gitignored).
 * Use when the hard part is unknown external/runtime behavior (API, OAuth,
 * sync, time zones): the header is the spec, the body below is the proof.
 *
 * Run from the repo root:
 *
 *     node .pocs/<name>.js --help
 *     node .pocs/<name>.js --probe
 *     node .pocs/<name>.js --demo
 *
 * Reference the codebase by path; never paste production code into this file.
 * Store any tokens under gitignored .pocs/ paths (prefer sandbox/test accounts).
 *
 * phase: spike
 *
 * Goal
 * ----
 * <One paragraph: what this must prove/achieve, captured from the source.>
 *
 * Context (current code)
 * ----------------------
 * <Production paths this feature will extend, by path: path/to/file.ext:NN>
 *
 * Implementation
 * --------------
 * Findings (past tense, with provenance — [ran it] / [code: path:line] /
 * [product decision] / [assumption - unverified]):
 * - <none yet>
 *
 * Directives (imperative, each with a verifiable done-check):
 * - <none yet>
 *
 * Remaining gaps
 * --------------
 * Worklist + progress bar. Done when empty. Tag each gap by owner and id.
 * Decisions never stop execution: record a default assumption + link, then keep going.
 * - G1 [agent] <investigation the agent can close itself>
 * - G2 [user]  <decision only a human can make> | assumption: <default> | affects: <directive>
 */

"use strict";

function probe() {
  return { ok: true, note: "replace probe() with the real provider call" };
}

function demo() {
  return { ok: true, note: "replace demo() with the real flow" };
}

function main(argv) {
  const args = argv.slice(2);
  const asJson = args.includes("--json");
  let result = null;

  if (args.includes("--probe")) {
    result = probe();
  } else if (args.includes("--demo")) {
    result = demo();
  } else {
    console.log("POCDD spike — <feature>");
    console.log("  --probe   cheap connectivity / shape check");
    console.log("  --demo    run the happy-path demo");
    console.log("  --json    machine-readable output");
    return 0;
  }

  if (asJson) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    for (const [key, value] of Object.entries(result)) {
      console.log(`${key}: ${value}`);
    }
  }
  return 0;
}

process.exit(main(process.argv));
