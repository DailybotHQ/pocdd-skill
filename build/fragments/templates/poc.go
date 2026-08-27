// POC: <Feature name> (<source / issue id>)
//
// POCDD file (runnable form). One feature, one file, under .pocs/ (gitignored).
// Use when the hard part is unknown external/runtime behavior (API, OAuth,
// sync, time zones): the header is the spec, the body below is the proof.
//
// Run from the repo root:
//
//     go run .pocs/<name>.go -probe
//     go run .pocs/<name>.go -demo
//
// Reference the codebase by path; never paste production code into this file.
// Store any tokens under gitignored .pocs/ paths (prefer sandbox/test accounts).
//
// phase: spike
//
// Goal
// ----
// <One paragraph: what this must prove/achieve, captured from the source.>
//
// Context (current code)
// ----------------------
// <Production paths this feature will extend, by path: path/to/file.ext:NN>
//
// Implementation
// --------------
// Findings (past tense, with provenance — [ran it] / [code: path:line] /
// [product decision] / [assumption - unverified]):
// - <none yet>
//
// Directives (imperative, each with a verifiable done-check):
// - <none yet>
//
// Remaining gaps
// --------------
// Worklist + progress bar. Done when empty. Tag each gap by owner and id.
// Decisions never stop execution: record a default assumption + link, then keep going.
// - G1 [agent] <investigation the agent can close itself>
// - G2 [user]  <decision only a human can make> | assumption: <default> | affects: <directive>

package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
)

func probe() map[string]any {
	return map[string]any{"ok": true, "note": "replace probe() with the real provider call"}
}

func demo() map[string]any {
	return map[string]any{"ok": true, "note": "replace demo() with the real flow"}
}

func main() {
	probeFlag := flag.Bool("probe", false, "cheap connectivity / shape check")
	demoFlag := flag.Bool("demo", false, "run the happy-path demo")
	jsonFlag := flag.Bool("json", false, "machine-readable output")
	flag.Parse()

	var result map[string]any
	switch {
	case *probeFlag:
		result = probe()
	case *demoFlag:
		result = demo()
	default:
		fmt.Println("POCDD spike — <feature>")
		flag.PrintDefaults()
		os.Exit(0)
	}

	if *jsonFlag {
		enc := json.NewEncoder(os.Stdout)
		enc.SetIndent("", "  ")
		_ = enc.Encode(result)
		return
	}
	for k, v := range result {
		fmt.Printf("%s: %v\n", k, v)
	}
}
