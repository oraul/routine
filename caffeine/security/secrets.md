# caffeine: security/secrets
<!-- caffeine-topic: security/secrets -->
<!-- caffeine-applies: any -->
<!-- caffeine-source: https://owasp.org/www-project-secrets-management-cheat-sheet/ -->
<!-- caffeine-reviewed: 2026-08-12 -->
<!-- caffeine-mode: doc-only -->

Language-agnostic, doc-only: the teaching half of the convention
harness. Loaded when your task's manifest names `security/secrets`. The
target's own security policy outranks this guide where they conflict.
The mechanical half is `bin/routine-convention-check`, which greps every
commit for known credential shapes — this doc is the judgment it cannot
have.

## The boundary, annotated

```text
config/
  app.example.env      # committed: KEY NAMES ONLY, placeholder values —
                       #   the shape of the config is public, the values
                       #   never are.
  app.env              # NEVER committed (.gitignore'd from birth):
                       #   real values, injected at deploy time from the
                       #   platform's secret store.
#
# The rule that survives every framework: code references NAMES
# (ENV["STRIPE_KEY"]); values exist only in the runtime environment.
# A secret in a committed file is public the moment it is pushed —
# private repos leak through forks, CI logs, and laptops.
```

## Judgment

- **What counts as a secret**: API keys, tokens, passwords, private
  keys, connection strings with credentials, session-signing secrets,
  webhook signing secrets, personal names and account identifiers where
  the project's rules say so (this repo's do). When unsure, treat it as
  one — the cost asymmetry is total.
- **Leak response is rotate-first.** A pushed secret is compromised the
  moment it leaves the machine: rotate the credential FIRST, then
  rewrite history — a rewrite without rotation is theater, because
  clones and caches already have the old bytes.
- **Scanning catches shapes, not judgment.** `routine-convention-check`
  and platform scanners match known prefixes (`ghp_`, `sk-`, `AKIA…`,
  key blocks); they cannot recognize a bespoke internal token, a
  base64-wrapped credential, or a customer's email in a fixture. The
  grep is the floor; this doc is the bar.
- **Test fixtures lie well.** Fixture credentials must be structurally
  invalid on sight (`test-key-not-real`, `example.invalid` domains) —
  a "fake" that matches the real format will someday be a real one
  pasted in a hurry.
- **Logs are an exfiltration path.** Never log a credential, a full
  request header set, or a signed URL; redact at the logging seam, not
  at each call site.
