# Security Policy

POCDD is a Markdown-plus-Bash agent skill — it has no server, no network calls of
its own, and no runtime dependencies. The security surface is therefore small,
but two things are worth calling out.

## Never put secrets in a POC

The skill creates a `.pocs/` working directory at your repo root. While closing
gaps, an agent may run code, hit APIs, or read config to prove behavior. Keep
credentials out of the POC file itself:

- `.pocs/` is **gitignored in its entirety** — do not remove that ignore rule and
  do not commit POC working state.
- Reference secrets by **environment variable name**, never by value, inside a POC.
- Provide real tokens through your normal environment (e.g. a local `.env` that is
  itself gitignored), not by pasting them into `.pocs/*.md` or `.pocs/*.py`.
- Prefer **scoped, short-lived, non-production** credentials when a gap requires a
  live call.

If a secret does land in a POC file, treat it as compromised: rotate it, and note
that `.pocs/` being gitignored means it was not pushed — but scrub it anyway.

## Supported versions

This is a pre-1.0 skill; only the latest `main` is supported. Fixes ship on
`main` and are noted in [`CHANGELOG.md`](CHANGELOG.md).

## Reporting a vulnerability

Please **do not** open a public issue for a security problem. Instead, email
**security@dailybot.com** with:

- a description of the issue and its impact,
- steps to reproduce (or a proof of concept),
- any suggested remediation.

We'll acknowledge your report, keep you updated on the fix, and credit you if
you'd like once it's resolved.
