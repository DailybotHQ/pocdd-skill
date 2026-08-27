#!/usr/bin/env bash
# POCDD configure — build a slim, customized skills/pocdd/ pack at install time.
#
# Interactive (asks with recommendations):
#   ./configure
#   ./build/configure.sh
#
# Non-interactive:
#   ./configure --yes
#   ./configure --lang python,md --gaps 1 --layout single_root --profile light
#
# Portable Bash (no associative arrays) for macOS bash 3.2.
set -euo pipefail

VERSION="0.2.0"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
FRAG="$HERE/fragments"
# shellcheck source=detect.sh
. "$HERE/detect.sh"

OUT="${POCDD_OUT:-$ROOT/skills/pocdd}"
PROFILE_DIR="${POCDD_PROFILE_DIR:-$ROOT/.pocdd}"
DETECT_ROOT="${POCDD_DETECT_ROOT:-$PWD}"

YES=0
LANGS=""
GAPS=""
LAYOUT=""
PROFILE=""

usage() {
  cat <<'EOF'
usage: ./configure [options]

Build a customized skills/pocdd/ pack for this machine and stack.

Options:
  --yes                 Accept all recommendations (non-interactive)
  --lang <list>         Comma list: python,js,go,md  (default: detected)
  --gaps <N>            Gaps per /poc work pass (1–3)
  --layout <name>       monorepo_repositories|monorepo_apps|monorepo_packages|src_root|single_root
  --profile <name>      light|mid|full  (default: from RAM/VRAM recommendation)
  --out <dir>           Output pack directory (default: skills/pocdd)
  --detect-root <dir>   Directory to scan for stack/layout (default: cwd)
  -h, --help            Show this help
EOF
}

ask() {
  # ask <prompt> <default> → prints answer
  local prompt="$1" default="$2" reply=""
  if [ "$YES" -eq 1 ]; then
    printf '%s\n' "$default"
    return 0
  fi
  if [ -t 0 ]; then
    printf '%s [%s]: ' "$prompt" "$default" >&2
    read -r reply || true
  fi
  if [ -z "${reply:-}" ]; then
    printf '%s\n' "$default"
  else
    printf '%s\n' "$reply"
  fi
}

contains_lang() {
  case ",$1," in
    *",$2,"*) return 0 ;;
    *) return 1 ;;
  esac
}

template_choices_block() {
  local langs="$1" block=""
  if contains_lang "$langs" python; then
    block="${block}     - Python: copy [\`../templates/poc.py\`](../templates/poc.py)"$'\n'
  fi
  if contains_lang "$langs" js; then
    block="${block}     - JS/TS: copy [\`../templates/poc.js\`](../templates/poc.js)"$'\n'
  fi
  if contains_lang "$langs" go; then
    block="${block}     - Go: copy [\`../templates/poc.go\`](../templates/poc.go)"$'\n'
  fi
  if contains_lang "$langs" md; then
    block="${block}     - Markdown: copy [\`../templates/poc.md\`](../templates/poc.md)"$'\n'
  fi
  if [ -z "$block" ]; then
    block="     - Markdown: copy [\`../templates/poc.md\`](../templates/poc.md)"$'\n'
  fi
  printf '%s' "$block"
}

# Substitute {{PLACEHOLDERS}} — prefers python3 for multiline-safe replaces.
render_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if command -v python3 >/dev/null 2>&1; then
    VERSION="$VERSION" GAPS="$GAPS" PROFILE="$PROFILE" LANGS="$LANGS" \
    LAYOUT_HINT="$LAYOUT_HINT" STACK_COMMANDS="$STACK_COMMANDS" \
    TEMPLATE_CHOICES="$TEMPLATE_CHOICES" \
    python3 - "$src" "$dest" <<'PY'
import os, sys
src, dest = sys.argv[1], sys.argv[2]
text = open(src, encoding="utf-8").read()
repl = {
    "{{VERSION}}": os.environ["VERSION"],
    "{{GAPS_PER_PASS}}": os.environ["GAPS"],
    "{{PROFILE}}": os.environ["PROFILE"],
    "{{STACK_LANGS}}": os.environ["LANGS"],
    "{{LAYOUT_HINT}}": os.environ.get("LAYOUT_HINT", ""),
    "{{STACK_COMMANDS}}": os.environ.get("STACK_COMMANDS", ""),
    "{{TEMPLATE_CHOICES}}": os.environ.get("TEMPLATE_CHOICES", ""),
}
for k, v in repl.items():
    text = text.replace(k, v)
open(dest, "w", encoding="utf-8").write(text)
PY
  else
    # Scalar-only fallback; multiline fields must avoid special sed chars
    sed -e "s|{{VERSION}}|${VERSION}|g" \
        -e "s|{{GAPS_PER_PASS}}|${GAPS}|g" \
        -e "s|{{PROFILE}}|${PROFILE}|g" \
        -e "s|{{STACK_LANGS}}|${LANGS}|g" \
        "$src" >"$dest"
    # Best-effort: leave placeholders if no python — warn
    if grep -q '{{LAYOUT_HINT}}\|{{STACK_COMMANDS}}\|{{TEMPLATE_CHOICES}}' "$dest"; then
      echo "warning: python3 recommended for full substitution; some placeholders left in $dest" >&2
    fi
  fi
}

generate_pack() {
  local dest="$1"
  echo "Generating pack → $dest (profile=$PROFILE gaps=$GAPS langs=$LANGS layout=$LAYOUT)"

  rm -rf "$dest"
  mkdir -p "$dest/shared" "$dest/templates" "$dest/verify"
  mkdir -p "$dest/create" "$dest/work" "$dest/status" "$dest/list"
  mkdir -p "$dest/implement" "$dest/archive" "$dest/remove" "$dest/clear"

  LAYOUT_HINT="$(pocdd_layout_hint "$LAYOUT")"
  STACK_COMMANDS="$(pocdd_stack_commands "$LANGS")"
  TEMPLATE_CHOICES="$(template_choices_block "$LANGS")"
  export LAYOUT_HINT STACK_COMMANDS TEMPLATE_CHOICES

  render_file "$FRAG/skills/SKILL.md.tmpl" "$dest/SKILL.md"
  render_file "$FRAG/skills/create/SKILL.md.tmpl" "$dest/create/SKILL.md"
  render_file "$FRAG/skills/work/SKILL.md.tmpl" "$dest/work/SKILL.md"
  render_file "$FRAG/skills/status/SKILL.md.tmpl" "$dest/status/SKILL.md"
  render_file "$FRAG/skills/list/SKILL.md.tmpl" "$dest/list/SKILL.md"
  render_file "$FRAG/skills/implement/SKILL.md.tmpl" "$dest/implement/SKILL.md"
  render_file "$FRAG/skills/archive/SKILL.md.tmpl" "$dest/archive/SKILL.md"
  render_file "$FRAG/skills/remove/SKILL.md.tmpl" "$dest/remove/SKILL.md"
  render_file "$FRAG/skills/clear/SKILL.md.tmpl" "$dest/clear/SKILL.md"
  render_file "$FRAG/skills/verify/SKILL.md.tmpl" "$dest/verify/SKILL.md"

  case "$PROFILE" in
    light) render_file "$FRAG/conventions/light.md.tmpl" "$dest/shared/conventions.md" ;;
    full)  render_file "$FRAG/conventions/full.md.tmpl"  "$dest/shared/conventions.md" ;;
    *)     render_file "$FRAG/conventions/mid.md.tmpl"   "$dest/shared/conventions.md" ;;
  esac

  cp "$FRAG/shared/context.sh" "$dest/shared/context.sh"
  cp "$FRAG/shared/verify.sh" "$dest/verify/verify.sh"
  chmod +x "$dest/verify/verify.sh"

  # Templates for selected languages
  contains_lang "$LANGS" md && cp "$FRAG/templates/poc.md" "$dest/templates/poc.md"
  contains_lang "$LANGS" python && cp "$FRAG/templates/poc.py" "$dest/templates/poc.py"
  contains_lang "$LANGS" js && cp "$FRAG/templates/poc.js" "$dest/templates/poc.js"
  contains_lang "$LANGS" go && cp "$FRAG/templates/poc.go" "$dest/templates/poc.go"
  # Always ensure at least poc.md exists
  if [ ! -f "$dest/templates/poc.md" ] && [ ! -f "$dest/templates/poc.py" ] \
     && [ ! -f "$dest/templates/poc.js" ] && [ ! -f "$dest/templates/poc.go" ]; then
    cp "$FRAG/templates/poc.md" "$dest/templates/poc.md"
  fi

  # Marker so agents/check know this pack was generated
  cat >"$dest/.generated" <<EOF
version=$VERSION
profile=$PROFILE
gaps_per_pass=$GAPS
langs=$LANGS
layout=$LAYOUT
EOF

  echo "Done."
}

write_profile() {
  mkdir -p "$PROFILE_DIR"
  cat >"$PROFILE_DIR/profile.json" <<EOF
{
  "version": "$VERSION",
  "profile": "$PROFILE",
  "gaps_per_pass": $GAPS,
  "langs": "$LANGS",
  "layout": "$LAYOUT",
  "ram_gib": ${RAM_GIB:-null},
  "vram_gib": ${VRAM_GIB:-null}
}
EOF
  echo "Wrote $PROFILE_DIR/profile.json"
}

# --- args ---------------------------------------------------------------------

while [ "$#" -gt 0 ]; do
  case "$1" in
    --yes) YES=1; shift ;;
    --lang) LANGS="${2:-}"; shift 2 ;;
    --gaps) GAPS="${2:-}"; shift 2 ;;
    --layout) LAYOUT="${2:-}"; shift 2 ;;
    --profile) PROFILE="${2:-}"; shift 2 ;;
    --out) OUT="${2:-}"; shift 2 ;;
    --detect-root) DETECT_ROOT="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

# --- detect & recommend -------------------------------------------------------

RAM_GIB="$(pocdd_detect_ram_gib 2>/dev/null || true)"
VRAM_GIB="$(pocdd_detect_vram_gib 2>/dev/null || true)"
REC="$(pocdd_recommend_model "${RAM_GIB:-}" "${VRAM_GIB:-}")"
REC_GAPS="$(printf '%s' "$REC" | awk '{print $1}')"
REC_PROFILE="$(printf '%s' "$REC" | awk '{print $2}')"
REC_LANGS="$(pocdd_detect_langs "$DETECT_ROOT")"
REC_LAYOUT="$(pocdd_detect_layout "$DETECT_ROOT")"

echo "POCDD configure"
echo "---------------"
if [ -n "${RAM_GIB:-}" ]; then
  echo "Detected RAM (available/total approx): ${RAM_GIB} GiB"
else
  echo "Detected RAM: (unknown)"
fi
if [ -n "${VRAM_GIB:-}" ]; then
  echo "Detected discrete VRAM: ${VRAM_GIB} GiB"
else
  echo "Detected discrete VRAM: (none / unknown — iGPU counts as none)"
fi
echo "Recommended: gaps_per_pass=${REC_GAPS}, profile=${REC_PROFILE}"
echo "Recommended languages: ${REC_LANGS}"
echo "Recommended layout: ${REC_LAYOUT}"
echo ""

if [ -z "$LANGS" ]; then
  LANGS="$(ask "POC languages (python,js,go,md — comma list)" "$REC_LANGS")"
fi
if [ -z "$GAPS" ]; then
  GAPS="$(ask "Gaps per /poc work pass (1-3)" "$REC_GAPS")"
fi
if [ -z "$PROFILE" ]; then
  PROFILE="$(ask "Conventions profile (light|mid|full)" "$REC_PROFILE")"
fi
if [ -z "$LAYOUT" ]; then
  LAYOUT="$(ask "Repo layout (monorepo_repositories|monorepo_apps|monorepo_packages|src_root|single_root)" "$REC_LAYOUT")"
fi

# Validate
case "$GAPS" in
  1|2|3) ;;
  *) echo "error: --gaps must be 1, 2, or 3 (got: $GAPS)" >&2; exit 2 ;;
esac
case "$PROFILE" in
  light|mid|full) ;;
  *) echo "error: --profile must be light, mid, or full (got: $PROFILE)" >&2; exit 2 ;;
esac

# Normalize langs: strip spaces
LANGS="$(printf '%s' "$LANGS" | tr -d ' ')"

# JSON nulls for missing hardware
if [ -z "${RAM_GIB:-}" ]; then RAM_GIB=null; fi
if [ -z "${VRAM_GIB:-}" ]; then VRAM_GIB=null; fi

generate_pack "$OUT"
write_profile

echo ""
echo "Next: ./setup.sh   # symlink skills/pocdd into your agent(s)"
echo "Re-run ./configure anytime to retune for another machine or stack."
