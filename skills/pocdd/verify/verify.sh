#!/usr/bin/env bash
# POCDD well-formedness check. Verifies one POC (by name/path) or all POCs in
# .pocs/. Prints PASS/FAIL per file and exits non-zero if any file fails.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../shared/context.sh
. "$HERE/../shared/context.sh"

verify_one() {
  local f="$1" name errs=()
  name="$(basename "$f")"

  grep -Eqi '^[^[:alnum:]]*phase:[[:space:]]*(spike|shaping|ready-to-implement|not-viable)\b' "$f" \
    || errs+=("missing or invalid 'phase:' header (spike|shaping|ready-to-implement|not-viable)")

  grep -Eqi '(^|[^[:alpha:]])goal([^[:alpha:]]|$)' "$f" || errs+=("missing 'Goal' section")
  grep -Eqi 'implementation'                       "$f" || errs+=("missing 'Implementation' section")
  grep -Eqi 'remaining gaps'                        "$f" || errs+=("missing 'Remaining gaps' section")

  # Every gap reference (G<n>) must carry an [agent]/[user] owner on its line.
  local gap_lines owner_missing
  gap_lines="$(grep -En '\bG[0-9]+\b' "$f" || true)"
  if [ -n "$gap_lines" ]; then
    owner_missing="$(printf '%s\n' "$gap_lines" | grep -Ev '\[(agent|user)\]' || true)"
    if [ -n "$owner_missing" ]; then
      errs+=("gap line(s) missing [agent]/[user] owner, e.g. line $(printf '%s' "$owner_missing" | head -1 | cut -d: -f1)")
    fi
  fi

  # Done consistency: ready-to-implement implies no open owned gaps.
  if grep -Eqi 'phase:[[:space:]]*ready-to-implement' "$f"; then
    if grep -Eq '\bG[0-9]+\b.*\[(agent|user)\]' "$f"; then
      errs+=("phase is 'ready-to-implement' but open gaps remain")
    fi
  fi

  if [ "${#errs[@]}" -eq 0 ]; then
    printf 'PASS  %s\n' "$name"
    return 0
  fi
  printf 'FAIL  %s\n' "$name"
  local e
  for e in "${errs[@]}"; do printf '        - %s\n' "$e"; done
  return 1
}

targets=()
if [ "$#" -ge 1 ] && [ -n "${1:-}" ]; then
  p="$(pocdd_resolve "$1" 2>/dev/null || true)"
  if [ -n "$p" ]; then
    targets+=("$p")
  elif [ -f "$1" ]; then
    targets+=("$1")
  else
    echo "POC not found: $1" >&2
    exit 2
  fi
else
  while IFS= read -r line; do
    [ -n "$line" ] && targets+=("$line")
  done < <(pocdd_list)
fi

if [ "${#targets[@]}" -eq 0 ]; then
  echo "No POC files to verify."
  exit 0
fi

fail_total=0
for t in "${targets[@]}"; do
  verify_one "$t" || fail_total=$((fail_total + 1))
done

echo ""
if [ "$fail_total" -eq 0 ]; then
  echo "All POC files conform."
  exit 0
fi
echo "$fail_total file(s) failed."
exit 1
